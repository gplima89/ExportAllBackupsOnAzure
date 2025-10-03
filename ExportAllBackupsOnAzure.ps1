
# Connect to Azure with error handling
# Attempt to authenticate to Azure. If it fails, print an error and exit.
try {
    Connect-AzAccount -ErrorAction Stop # Connect to Azure, stop on error
    Write-Host "✅ Connected to Azure successfully."
} catch {
    Write-Error "❌ Failed to connect to Azure. $_" # Print error if connection fails
    exit
}


# Define KQL queries to retrieve Recovery Services Vaults and their count
$vaultsQuery = @"
Resources
| where type == 'microsoft.recoveryservices/vaults'
| project name, resourceGroup, subscriptionId, location, id
"@
$CountQuery = @"
Resources
| where type == 'microsoft.recoveryservices/vaults'
| count
"@


# Initialize variables for paginated query
$Counter = 1000 # Number of results to fetch per page
$Skip = 0 # Offset for pagination
$QueryTemp = $null # Temporary storage for query results
$vaults = @() # Array to store all vaults

# Get the total number of Recovery Services Vaults
$TotalAZGraph = Search-AzGraph -Query $CountQuery -UseTenantScope
$TotalAZGraph = $TotalAZGraph | Select-Object -ExpandProperty Count

# Paginate through all vaults if more than $Counter exist
while ($Skip -lt $TotalAZGraph) {
    if ($skip -eq 0) {
        $QueryTemp = Search-AzGraph -Query $vaultsQuery -first $Counter -UseTenantScope # First page
    }
    else {
        $QueryTemp = Search-AzGraph -Query $vaultsQuery -first $Counter -Skip $Skip -UseTenantScope # Subsequent pages
    }
    $vaults += $QueryTemp # Add results to vaults array
    $Skip += 1000 # Increment offset
}

# Exit if no vaults found
if (-not $vaults) {
    Write-Warning "No Recovery Services Vaults found."
    exit
}


# Get unique subscription IDs from the vaults
$uniqueSubs = $vaults | Select-Object -ExpandProperty subscriptionId -Unique

# Prepare an array to store the final results
$results = @()

# Loop through each subscription to process its vaults
foreach ($subId in $uniqueSubs) {
    $currentContext = Get-AzContext # Get the current Azure context
    if ($currentContext.SubscriptionId -ne $subId) {
        try {
            Set-AzContext -SubscriptionId $subId -ErrorAction Stop # Switch to the target subscription
            Write-Host "🔄 Switched context to subscription: $subId"
        } catch {
            Write-Warning "⚠️ Failed to switch to subscription $subId. Skipping..."
            continue # Skip this subscription if unable to switch
        }
    }

    # Filter vaults for the current subscription
    $vaultsInSub = $null
    $vaultsInSub = $vaults | Where-Object { $_.subscriptionId -eq $subId }

    # Loop through each vault in the subscription
    foreach ($vault in $vaultsInSub) {
        $vaultName = $vault.name # Vault name
        $vaultRG = $vault.resourceGroup # Vault resource group
        $vaultId = $vault.id # Vault resource ID
        $location = $vault.location # Vault location
        $VaultPolicies = @() # Array for backup policies
        $containers = $null 

        # Get all backup containers of type AzureVM in the vault
        $containers = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -VaultId $vaultId -ErrorAction SilentlyContinue

        # Loop through each backup container (VM)
        foreach ($container in $containers) {
            $friendlyName = $container.FriendlyName # VM name

            # Get backup item for the container (VM)
            $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType "AzureVM" -VaultId $vaultId -ErrorAction SilentlyContinue

            # Get vault info and set context for backup policy queries
            $vaultinfo = Get-AzRecoveryServicesVault -ResourceGroupName $vaultRG -Name $vaultName
            Set-AzRecoveryServicesVaultContext -Vault $vaultinfo
            $VaultPolicies = $null
            $VaultPolicies = Get-AzRecoveryServicesBackupProtectionPolicy # Get all backup policies
            $PolicyInfo = $null
            $PolicyInfo = $VaultPolicies | where-object {$_.Id -eq $backupItem.PolicyId} # Find policy for this backup item

            # If backup item exists, add its info to results
            if ($backupItem) {
                $results += [PSCustomObject]@{
                    VMName         = $friendlyName # Name of the VM
                    ResourceGroup  = $vaultRG # Resource group
                    SubscriptionId = $subId # Subscription ID
                    Location       = $location # Azure region
                    VaultName      = $vaultName # Vault name
                    BackupType     = $backupItem.BackupManagementType # Type of backup
                    Policy         = $backupItem.ProtectionPolicyName # Policy name
                    PolicySchedule = $PolicyInfo.SchedulePolicy.ScheduleRunFrequency # Policy schedule frequency
                    SnapshotRet    = $PolicyInfo.SnapshotRetentionInDays # Snapshot retention
                    isDailySchedule     = $PolicyInfo.RetentionPolicy.IsDailyScheduleEnabled # Daily schedule enabled
                    isWeeklySchedule    = $PolicyInfo.RetentionPolicy.IsWeeklyScheduleEnabled # Weekly schedule enabled
                    isMonthlySchedule   = $PolicyInfo.RetentionPolicy.IsMonthlyScheduleEnabled # Monthly schedule enabled
                    isYearlySchedule    = $PolicyInfo.RetentionPolicy.IsYearlyScheduleEnabled # Yearly schedule enabled
                    DailySchedule       = $PolicyInfo.RetentionPolicy.DailySchedule.DurationCountInDays # Daily schedule duration
                    WeeklySchedule      = $PolicyInfo.RetentionPolicy.WeeklySchedule.DurationCountInWeeks # Weekly schedule duration
                    MonthlySchedule     = $PolicyInfo.RetentionPolicy.MonthlySchedule.DurationCountInMonths # Monthly schedule duration
                    YearlySchedule      = $PolicyInfo.RetentionPolicy.YearlySchedule.DurationCountInYears     # Yearly schedule duration
                    WorkloadType   = "AzureVM" # Workload type
                }
                $results[-1] # Output the last result (for debugging)
            }
        }
    }
}


# Export the results array to a CSV file
$results | Export-Csv -Path "AzureBackupInventory_AllTypes.csv" -NoTypeInformation
Write-Host "📁 Exported results to AzureBackupInventory_AllTypes.csv"
