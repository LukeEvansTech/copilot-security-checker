# copilot-security-checker

PowerShell module to assess a Microsoft 365 tenant's readiness for, and ongoing security posture around, Microsoft 365 Copilot.

See [README on GitHub](https://github.com/LukeEvansTech/copilot-security-checker) for installation and quick start.

## Cmdlets

| Cmdlet                                                                        | Description                                     |
| ----------------------------------------------------------------------------- | ----------------------------------------------- |
| [`Test-CopilotReadiness`](cmdlets/test-copilotreadiness.md)                   | Run all checks and emit a consolidated report.  |
| [`Get-CopilotOversharingRisk`](cmdlets/get-copilotoversharingrisk.md)         | Sample SharePoint sites for over-broad sharing. |
| [`Get-CopilotSensitivityCoverage`](cmdlets/get-copilotsensitivitycoverage.md) | Inspect the sensitivity-label catalogue.        |
