# Azure Recovery Services Backup Inventory Script

This repository contains a PowerShell script (`ExportAllBackupsOnAzure.ps1`) that inventories all Azure Recovery Services Vaults and their associated Azure VM backup configurations across all subscriptions in your tenant. The script exports the results to a CSV file for easy analysis and reporting.

## Features

- Authenticates to Azure and enumerates all Recovery Services Vaults using Azure Resource Graph.
- Iterates through all subscriptions and vaults to collect backup container (VM) information.
- Retrieves backup policy details, retention schedules, and backup types for each VM.
- Outputs a comprehensive CSV report (`AzureBackupInventory_AllTypes.csv`) with all relevant backup configuration details.
- Includes robust error handling and context switching for multi-subscription environments.

## Prerequisites

- PowerShell 7.x or later (recommended)
- Azure PowerShell modules:
  - `Az.Accounts`
  - `Az.ResourceGraph`
  - `Az.RecoveryServices`
- Sufficient permissions to read Recovery Services Vaults and backup items across all subscriptions.

## Installation

1. Clone this repository or download the `listazurebackups.ps1` script.
2. Install the required PowerShell modules if not already present:

   ```powershell
   Install-Module -Name Az.Accounts -Scope CurrentUser
   Install-Module -Name Az.ResourceGraph -Scope CurrentUser
   Install-Module -Name Az.RecoveryServices -Scope CurrentUser
   ```

## Usage

1. Open a PowerShell terminal.
2. Run the script:

   ```powershell
   .\listazurebackups.ps1
   ```

3. The script will prompt for Azure authentication if not already logged in.
4. Upon completion, the results will be exported to `AzureBackupInventory_AllTypes.csv` in the current directory.

## Output

The CSV file includes the following columns:
- VMName
- ResourceGroup
- SubscriptionId
- Location
- VaultName
- BackupType
- Policy
- PolicySchedule
- SnapshotRet
- isDailySchedule
- isWeeklySchedule
- isMonthlySchedule
- isYearlySchedule
- DailySchedule
- WeeklySchedule
- MonthlySchedule
- YearlySchedule
- WorkloadType

## Notes

- The script is designed for environments with multiple subscriptions and large numbers of vaults/VMs.
- Only Azure VM backup containers are included by default. You can modify the script to include other workload types if needed.
- For large tenants, the script paginates through results to avoid query limits.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions, issues, and feature requests are welcome! Please open an issue or submit a pull request.

## Author

- [Guil Lima] (https://github.com/gplima89)# AI Security with Microsoft Solutions

This repository contains materials for a presentation and a practical demo on securing AI workloads using Microsoft Azure solutions.

## Presentation: Security for AI using Microsoft Solutions

This presentation provides a comprehensive overview of the AI security landscape and Microsoft's holistic approach to securing AI. It covers key Microsoft Azure services and their role in protecting AI workloads.

**Key Topics:**
- The AI Security Landscape: Understanding the importance and top concerns for AI adoption.
- Microsoft's Holistic Approach: How Microsoft secures and governs AI with industry-leading cybersecurity and compliance solutions.
- Azure AI Foundry: Securing generative AI models through data protection, zero-trust architecture, and malware mitigation.
- Azure Network Security: Implementing robust network controls for AI workloads using Virtual Networks, Private Endpoints, NSGs, Azure Firewall, and WAF.
- Azure API Management (APIM): Leveraging APIM's AI gateway capabilities for securing and managing AI APIs, including token limits, monitoring, and content safety.

## Demo: Securing AI Endpoints with Azure API Management

An interactive web application demonstrating how Azure API Management can be used to protect Azure OpenAI endpoints from common threats and manage API access.

**Demo Features:**
- **Content Safety Policy:** Automatically blocks harmful or malicious prompts (e.g., prompt injection attempts).
- **Token Limit Policy:** Enforces rate limits on API usage to prevent abuse and manage costs.
- **Usage Monitoring:** Provides real-time tracking of API requests, token consumption, and blocked attempts.

**Technologies Used:**
- **Backend:** Flask (Python) for API endpoints and business logic.
- **Frontend:** HTML, Tailwind CSS, and JavaScript for an interactive user interface and real-time dashboard.
- **Charting:** Chart.js for visualizing token usage and security statistics.

## Getting Started

### Presentation

The presentation slides are available as an interactive web presentation. (Link will be provided separately).

### Demo Application

To run the demo application locally:

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd ai_security_demo
    ```
2.  **Set up the Python environment:**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```
3.  **Run the Flask application:**
    ```bash
    python src/main.py
    ```
    The application will be accessible at `http://localhost:5000`.

4.  **Interact with the demo:**
    Open your web browser to `http://localhost:5000` and use the chat interface to test safe messages, harmful content, and rate limiting.

## Demo Implementation Details

For detailed instructions on how to implement the security policies demonstrated in the demo within an Azure environment, refer to the `demo_instructions.md` file included in this repository.

## Author

Guil Lima (Microsoft Cloud Solution Architect)


