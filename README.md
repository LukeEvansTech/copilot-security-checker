# copilot-security-checker

A PowerShell module for assessing a Microsoft 365 tenant's readiness for, and ongoing security posture around, Microsoft 365 Copilot.

The module focuses on the controls that materially change Copilot's blast radius:

- Sensitivity-label coverage on the content Copilot will ground on.
- SharePoint oversharing risk (anyone-links, broad permissions).
- Restricted SharePoint search status.
- Microsoft Purview audit logging readiness for Copilot interactions.

## Status

Early — public seed of an ongoing project. Cmdlets surface the right data shape; some checks emit the structure with TODO markers where a deeper Graph call is still being wired.

## Install

PowerShell Gallery publication is pending while the module stabilises. For now:

```powershell
git clone https://github.com/LukeEvansTech/copilot-security-checker.git
cd copilot-security-checker
Import-Module ./src/CopilotSecurityChecker.psd1
```

## Quick start

```powershell
Connect-MgGraph -Scopes 'Sites.Read.All','InformationProtectionPolicy.Read','AuditLog.Read.All'
Test-CopilotReadiness | Format-List
```

## Cmdlets

| Cmdlet | Description |
| ------ | ----------- |
| `Test-CopilotReadiness` | High-level orchestrator. Runs the sub-checks below and returns a single readiness object with traffic-light scoring. |
| `Get-CopilotOversharingRisk` | Counts SharePoint sites with anyone-link sharing enabled or broad permission grants. |
| `Get-CopilotSensitivityCoverage` | Returns the percentage of items in scope that carry a sensitivity label (sampled per workload). |

Each cmdlet supports `-Verbose` for diagnostic output.

## Requirements

- PowerShell 7.4 or later.
- [Microsoft.Graph](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation) PowerShell SDK.
- Graph permissions as listed in the quick-start example.

## Contributing

PRs welcome — see [CONTRIBUTING](.github/CONTRIBUTING.md). Run the Pester suite locally before opening a PR:

```powershell
Invoke-Pester ./tests
```

## Licence

[MIT](LICENSE).
