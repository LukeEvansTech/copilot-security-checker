#Requires -Version 7.4
#Requires -Modules @{ ModuleName = 'Microsoft.Graph.Authentication'; ModuleVersion = '2.10.0' }

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Dot-source the public functions
$publicFunctions = Get-ChildItem -Path "$PSScriptRoot/Public" -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($file in $publicFunctions) {
    . $file.FullName
}

Export-ModuleMember -Function @(
    'Test-CopilotReadiness',
    'Get-CopilotOversharingRisk',
    'Get-CopilotSensitivityCoverage'
)
