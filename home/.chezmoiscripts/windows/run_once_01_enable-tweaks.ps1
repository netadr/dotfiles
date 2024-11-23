# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
		$commandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
		Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $commandLine
		Exit
	}
}

Write-Host "Disabling Windows Defender SpyNet..."
$spynet = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
if (!(Test-Path -Path $spynet)) {
    New-Item -Path $spynet
}
Set-ItemProperty -Path $spynet -Name SpynetReporting -Type DWord -Value 0
Set-ItemProperty -Path $spynet -Name SubmitSamplesConsent -Type DWord -Value 2

Write-Host "Disabling Windows Firewall (calm down, we use simplewall...)"
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False

$base = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall"
if (!(Test-Path -Path $base)) {
    New-Item -Path $base
}

$standard = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile"
if (!(Test-Path -Path $standard)) {	
	New-Item -Path $standard
}
Set-ItemProperty -Path $standard -Name EnableFirewall -Type DWord -Value 0

$domain = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
if (!(Test-Path -Path $domain)) {	
	New-Item -Path $domain
}
Set-ItemProperty -Path $domain -Name EnableFirewall -Type DWord -Value 0

Write-Host "Disabling DataCollection..."
$telemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path -Path $telemetry)) {	
	New-Item -Path $telemetry
}
Set-ItemProperty -Path $telemetry -Name AllowTelemetry -Type DWord -Value 0

Write-Host "Enabling good explorer.exe..."
$advanced = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $advanced -Name Hidden -Type DWord -Value 1
Set-ItemProperty -Path $advanced -Name HideFileExt -Type DWord -Value 0

$contextMenu = "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
New-Item -Force -Path $contextMenu
Set-ItemProperty -Path $contextMenu -Name "(Default)" -Value ""

$explorer = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
if (!(Test-Path -Path $explorer)) {	
	New-Item -Path $explorer
}
Set-ItemProperty -Path $explorer -Name DisableSearchBoxSuggestions -Type DWord -Value 1
