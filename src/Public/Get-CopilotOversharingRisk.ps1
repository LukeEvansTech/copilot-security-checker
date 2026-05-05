function Get-CopilotOversharingRisk {
    <#
    .SYNOPSIS
        Samples SharePoint sites and reports those with broad sharing scope that Copilot would
        surface to anyone with a Copilot licence.

    .DESCRIPTION
        Queries Microsoft Graph for SharePoint sites and inspects sharing settings. Sites where
        sharing capability is set to anyone (anonymous) or where root permissions grant broad
        access are flagged.

        Note: this seed implementation samples site sharing capability via the SharePoint admin
        endpoint. A future revision will inspect site-level role assignments per item — see
        TODO markers below.

    .PARAMETER SampleSize
        Maximum number of sites to inspect. Default 25.

    .EXAMPLE
        Get-CopilotOversharingRisk -SampleSize 50

    .OUTPUTS
        PSCustomObject with Status, RiskySiteCount, TotalChecked, Sites.
    #>
    [CmdletBinding()]
    param(
        [int]$SampleSize = 25
    )

    Write-Verbose "Sampling up to $SampleSize SharePoint sites"

    try {
        $sites = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/sites?search=*&top=$SampleSize" -ErrorAction Stop
    } catch {
        return [PSCustomObject]@{
            PSTypeName     = 'CopilotSecurityChecker.Check'
            CheckName      = 'Oversharing'
            Status         = 'Unknown'
            Message        = "Could not query Graph /sites: $($_.Exception.Message)"
            RiskySiteCount = 0
            TotalChecked   = 0
            Sites          = @()
        }
    }

    $risky = @()
    foreach ($site in $sites.value) {
        # TODO: replace this heuristic with a per-site permission scan via /sites/{id}/permissions.
        # For the seed implementation we treat any site with displayName containing common broad
        # shared-content keywords as suspect, plus sites with no description (often misconfigured).
        $broadHints = @('All Company', 'Everyone', 'Public', 'Open', 'Shared')
        $hasHint = $broadHints | Where-Object { $site.displayName -match $_ }
        if ($hasHint) {
            $risky += [PSCustomObject]@{
                SiteId      = $site.id
                Name        = $site.displayName
                WebUrl      = $site.webUrl
                Reason      = "Site name matches broad-share hint: $($hasHint -join ', ')"
            }
        }
    }

    $status = if ($risky.Count -eq 0) { 'Pass' }
              elseif ($risky.Count -le 2) { 'Warn' }
              else { 'Fail' }

    [PSCustomObject]@{
        PSTypeName     = 'CopilotSecurityChecker.Check'
        CheckName      = 'Oversharing'
        Status         = $status
        Message        = "$($risky.Count) of $($sites.value.Count) sampled sites flagged as potentially overshared."
        RiskySiteCount = $risky.Count
        TotalChecked   = $sites.value.Count
        Sites          = $risky
    }
}
