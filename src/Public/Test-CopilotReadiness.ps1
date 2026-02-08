function Test-CopilotReadiness {
    <#
    .SYNOPSIS
        Runs a battery of Copilot security-readiness checks and returns a consolidated report.

    .DESCRIPTION
        Calls the individual Get- and Test- cmdlets, aggregates their results, and emits a single
        report object with overall readiness and per-check status.

        Connect to Microsoft Graph first:
            Connect-MgGraph -Scopes 'Sites.Read.All','InformationProtectionPolicy.Read','AuditLog.Read.All'

    .PARAMETER SharePointSampleSize
        Number of SharePoint sites to sample for sharing analysis. Defaults to 25.

    .EXAMPLE
        Test-CopilotReadiness | Format-List

    .OUTPUTS
        PSCustomObject with properties: GeneratedAt, Tenant, Overall, Checks (array).
    #>
    [CmdletBinding()]
    param(
        [int]$SharePointSampleSize = 25
    )

    $context = Get-MgContext -ErrorAction SilentlyContinue
    if (-not $context) {
        throw 'Not connected to Microsoft Graph. Run Connect-MgGraph first.'
    }

    Write-Verbose "Running readiness checks for tenant $($context.TenantId)"

    $checks = @(
        Get-CopilotOversharingRisk -SampleSize $SharePointSampleSize
        Get-CopilotSensitivityCoverage
    )

    $statusOrder = @{ 'Pass' = 0; 'Warn' = 1; 'Fail' = 2; 'Unknown' = 3 }
    $worst = ($checks.Status | Sort-Object { $statusOrder[$_] } -Descending)[0]

    [PSCustomObject]@{
        PSTypeName  = 'CopilotSecurityChecker.Report'
        GeneratedAt = (Get-Date).ToUniversalTime()
        Tenant      = $context.TenantId
        Overall     = $worst
        Checks      = $checks
    }
}
