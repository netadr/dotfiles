function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

if ((Get-Command "winget.exe" -ErrorAction SilentlyContinue) -eq $null) { 
	Write-Host "Run " + "Invoke-WebRequest https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | Invoke-Expression" + " in an elevated PowerShell instance."
	exit	
}

winget install --accept-source-agreements twpayne.chezmoi
Refresh-Path
chezmoi init --apply netadr
