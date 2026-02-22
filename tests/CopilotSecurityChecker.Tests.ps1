#Requires -Modules Pester

BeforeAll {
    $modulePath = Resolve-Path (Join-Path $PSScriptRoot '..' 'src' 'CopilotSecurityChecker.psd1')
    Import-Module $modulePath -Force
}

Describe 'CopilotSecurityChecker module manifest' {
    It 'has the expected exported functions' {
        $module = Get-Module CopilotSecurityChecker
        $module.ExportedFunctions.Keys | Should -Contain 'Test-CopilotReadiness'
        $module.ExportedFunctions.Keys | Should -Contain 'Get-CopilotOversharingRisk'
        $module.ExportedFunctions.Keys | Should -Contain 'Get-CopilotSensitivityCoverage'
    }
}

Describe 'Get-CopilotSensitivityCoverage' {
    Context 'when no Graph context is available' {
        BeforeAll {
            Mock -ModuleName CopilotSecurityChecker Invoke-MgGraphRequest {
                throw 'Authentication needed'
            }
        }

        It 'returns Status = Unknown rather than throwing' {
            $result = Get-CopilotSensitivityCoverage
            $result.Status     | Should -Be 'Unknown'
            $result.LabelCount | Should -Be 0
        }
    }

    Context 'when no labels are configured' {
        BeforeAll {
            Mock -ModuleName CopilotSecurityChecker Invoke-MgGraphRequest {
                return @{ value = @() }
            }
        }

        It 'returns Status = Fail' {
            $result = Get-CopilotSensitivityCoverage
            $result.Status     | Should -Be 'Fail'
            $result.LabelCount | Should -Be 0
        }
    }

    Context 'when three or more labels are configured' {
        BeforeAll {
            Mock -ModuleName CopilotSecurityChecker Invoke-MgGraphRequest {
                return @{
                    value = @(
                        @{ id = '1'; name = 'Public';       description = ''; sensitivity = 0 }
                        @{ id = '2'; name = 'Internal';     description = ''; sensitivity = 1 }
                        @{ id = '3'; name = 'Confidential'; description = ''; sensitivity = 2 }
                    )
                }
            }
        }

        It 'returns Status = Pass' {
            $result = Get-CopilotSensitivityCoverage
            $result.Status     | Should -Be 'Pass'
            $result.LabelCount | Should -Be 3
        }
    }
}
