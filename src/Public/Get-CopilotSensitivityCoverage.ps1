function Get-CopilotSensitivityCoverage {
    <#
    .SYNOPSIS
        Reports the configured sensitivity-label catalogue and a TODO placeholder for the
        per-item coverage measurement.

    .DESCRIPTION
        Calls the Microsoft Graph informationProtection endpoint to enumerate the sensitivity
        labels configured in the tenant. The seed implementation reports label count and their
        priorities. A future revision will sample SharePoint and OneDrive items to compute
        per-label coverage rates.

    .EXAMPLE
        Get-CopilotSensitivityCoverage

    .OUTPUTS
        PSCustomObject with Status, LabelCount, Labels.
    #>
    [CmdletBinding()]
    param()

    try {
        $labels = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/informationProtection/policy/labels' -ErrorAction Stop
    } catch {
        return [PSCustomObject]@{
            PSTypeName = 'CopilotSecurityChecker.Check'
            CheckName  = 'SensitivityCoverage'
            Status     = 'Unknown'
            Message    = "Could not enumerate sensitivity labels: $($_.Exception.Message)"
            LabelCount = 0
            Labels     = @()
        }
    }

    $labelList = @($labels.value | ForEach-Object {
        [PSCustomObject]@{
            Id          = $_.id
            Name        = $_.name
            Description = $_.description
            Sensitivity = $_.sensitivity
        }
    })

    if ($labelList.Count -eq 0) {
        $status = 'Fail'
        $message = 'No sensitivity labels are configured. Copilot grounding cannot honour DLP boundaries without labels.'
    } elseif ($labelList.Count -lt 3) {
        $status = 'Warn'
        $message = "Only $($labelList.Count) sensitivity label(s) configured — most tenants need at least Public, Internal, Confidential, and Restricted."
    } else {
        $status = 'Pass'
        $message = "$($labelList.Count) sensitivity labels configured."
    }

    [PSCustomObject]@{
        PSTypeName = 'CopilotSecurityChecker.Check'
        CheckName  = 'SensitivityCoverage'
        Status     = $status
        Message    = $message
        LabelCount = $labelList.Count
        Labels     = $labelList
    }
}
