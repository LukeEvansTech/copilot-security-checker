@{
    RootModule        = 'CopilotSecurityChecker.psm1'
    ModuleVersion     = '0.0.1'
    GUID              = 'b6d4e9f1-2e4b-4c2a-9f63-1a1c2c87b4d7'
    Author            = 'Luke Evans'
    CompanyName       = 'LukeEvansTech'
    Copyright         = '(c) 2026 Luke Evans. All rights reserved.'
    Description       = 'Assess a Microsoft 365 tenant''s readiness for and security posture around Microsoft 365 Copilot.'
    PowerShellVersion = '7.4'
    RequiredModules   = @(
        @{ ModuleName = 'Microsoft.Graph.Authentication'; ModuleVersion = '2.10.0' }
    )
    FunctionsToExport = @(
        'Test-CopilotReadiness',
        'Get-CopilotOversharingRisk',
        'Get-CopilotSensitivityCoverage'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData = @{
        PSData = @{
            Tags        = @('Microsoft365', 'Copilot', 'Security', 'Compliance', 'Purview', 'SharePoint')
            LicenseUri  = 'https://github.com/LukeEvansTech/copilot-security-checker/blob/main/LICENSE'
            ProjectUri  = 'https://github.com/LukeEvansTech/copilot-security-checker'
            ReleaseNotes = 'Initial public seed. See CHANGELOG.md.'
        }
    }
}
