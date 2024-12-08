# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
		$commandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
		Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $commandLine
		Exit
	}
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

if ((Get-Command "winget.exe" -ErrorAction SilentlyContinue) -eq $null) { 
	Invoke-WebRequest https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | Invoke-Expression
	Refresh-Path
}

winget install --accept-source-agreements twpayne.chezmoi
Refresh-Path

chezmoi init --apply netadr
