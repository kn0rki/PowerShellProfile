Start-Steroids
<#
function connect-exserver
{
    param
    (
        [String]
        [Parameter(Mandatory=$true)]
        $server
    )
    
    $exsession = New-PSSession      -ConfigurationName 'Microsoft.Exchange' 
    -ConnectionUri "http://$server/Powershell" 
    -Credential (Get-Credential) 
    -Authentication Kerberos
    Import-PSSession $exsession
}

if (‘Invoke-ScriptAnalyzer’ -notin ($psise.CurrentPowerShellTab.AddOnsMenu.Submenus.DisplayName)) {
    $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Invoke-ScriptAnalyzer',{AnalyzeScript},$null) | Out-Null
}
function AnalyzeScript {
    if (Test-Path ($psISE.CurrentFile.FullPath)) {
        Write-Host “`nChecking script:” $psISE.CurrentFile.FullPath -ForegroundColor Cyan
        $Report = Invoke-ScriptAnalyzer $psISE.CurrentFile.FullPath
        foreach ($group in ($Report | Sort-Object Line | Group-Object RuleName)) {
            switch ($group.Group[0].Severity) {
                Error {Write-Host “`nError:” ($group.Name) -ForegroundColor Red}
                Warning {Write-Host “`nWarning:” ($group.Name) -ForegroundColor Yellow}
                Information {Write-Host “`nInformation:” ($group.Name) -ForegroundColor Green}
            }
            foreach ($M in ($group.Group | Group-Object Message | Sort-Object Count -Descending)) {
                if ($M.Group.Count -gt 1) {
                    Write-Host $M.Name ‘Lines:’ ($M.Group.Line -join ‘, ‘) (‘(‘+$M.Group.Count+’)’)
                } else {
                    Write-Host $M.Name ‘Line:’ ($M.Group[0].Line)
                }
            }
        }
    }
}


#Script Browser Begin
#Version: 1.3.2
Add-Type -Path 'G:\Programme\Microsoft Corporation\Microsoft Script Browser\System.Windows.Interactivity.dll'
Add-Type -Path 'G:\Programme\Microsoft Corporation\Microsoft Script Browser\ScriptBrowser.dll'
Add-Type -Path 'G:\Programme\Microsoft Corporation\Microsoft Script Browser\BestPractices.dll'
$scriptBrowser = $psISE.CurrentPowerShellTab.VerticalAddOnTools.Add('Script Browser', [ScriptExplorer.Views.MainView], $true)
$scriptAnalyzer = $psISE.CurrentPowerShellTab.VerticalAddOnTools.Add('Script Analyzer', [BestPractices.Views.BestPracticesView], $true)
$psISE.CurrentPowerShellTab.VisibleVerticalAddOnTools.SelectedAddOnTool = $scriptBrowser
#Script Browser End

#Module Browser Begin
#Version: 1.0.0
Add-Type -Path 'G:\Programme\Microsoft Module Browser\ModuleBrowser.dll'
$moduleBrowser = $psISE.CurrentPowerShellTab.VerticalAddOnTools.Add('Module Browser', [ModuleBrowser.Views.MainView], $true)
$psISE.CurrentPowerShellTab.VisibleVerticalAddOnTools.SelectedAddOnTool = $moduleBrowser
#Module Browser End
$PSLogPath = ('{0}{1}\Documents\WindowsPowerShell\log\{2:yyyyMMdd}-{3}.log' -f $env:HOMEDRIVE, $env:HOMEPATH,  (Get-Date), $PID)
Add-Content -Value "# $(Get-Date) $env:username $env:computername" -Path $PSLogPath
Add-Content -Value "# $(Get-Location)" -Path $PSLogPath

function prompt
{
    $LastCmd = Get-History -Count 1
    if($LastCmd)
    {
        $lastId = $LastCmd.Id
       
        Add-Content -Value "# $($LastCmd.StartExecutionTime)" -Path $PSLogPath
        Add-Content -Value "$($LastCmd.CommandLine)" -Path $PSLogPath
        Add-Content -Value '' -Path $PSLogPath
    }

    $nextCommand = $lastId + 1
    $currentDirectory = Split-Path (Get-Location) -Leaf
    $host.UI.RawUI.WindowTitle = Get-Location
    "$nextCommand PS:$currentDirectory>"
} 
#>
Clear-Host