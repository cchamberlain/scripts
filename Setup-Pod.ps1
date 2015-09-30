<#

.SYNOPSIS

Used for setup and deployment of pod script.

.DESCRIPTION

This script is used for everything related to setup of pod script in an environment.  It also bundles the various pod modules into a single file for easy deployments.

.PARAMETER ModulePath

The path to the script module directory of the computer.

.EXAMPLE

Set all environment variables and export modules to the module path.
Setup-Pod -SetEnvPSModulePath -SetEnvPath -ExportModules

.NOTES

This script can be used to install and deploy the latest pod script to a server and can then be discarded.

#>
[CmdletBinding(DefaultParameterSetName="None")]
param (
  [parameter(Position=0,HelpMessage="Path where script modules are located")]
  [string]$ModulePath="$Env:ProgramFiles\WindowsPowerShell\Modules",

  [parameter(ParameterSetName="Setup",HelpMessage="Sets the PSModulePath environment variable for use with pod modules (development)")]
  [alias("m")]
  [switch]$SetEnvPSModulePath,

  [parameter(ParameterSetName="Setup",HelpMessage="Sets the PATH environment variable for use with pod")]
  [alias("p")]
  [switch]$SetEnvPath,

  [parameter(ParameterSetName="Setup",HelpMessage="scripts to the module path")]
  [alias("x")]
  [switch]$ExportModules
)

switch($pscmdlet.ParameterSetName) {
  "None" {
    Write-Host "Error: [You must specify one or more setup switches: [-m|-SetEnvPSModulePath,-p|-SetEnvPath,-x|-ExportModules]]" -ForegroundColor "Red"
    Exit
  }
  "Setup" {
  }
}

function AppendEnvVariable {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="The environment variable to append to")]
    [string]$EnvVariable,

    [parameter(Mandatory=$TRUE,Position=1,HelpMessage="The value to append")]
    [string]$AppendValue
  )
  PROCESS {
    $EnvValue = [Environment]::GetEnvironmentVariable($EnvVariable)
    if($EnvValue -like "*$AppendValue*") {
      Write-Host "warning: [Environment variable '$EnvVariable' already contains value $AppendValue. Skipping...]" -ForegroundColor "Yellow"
      return
    }
    Write-Host "Appending environment variable '$EnvVariable' with $AppendValue"
    $EnvValue += ";$AppendValue"
    [Environment]::SetEnvironmentVariable($EnvVariable,$EnvValue)
  }
}

function NotifyEnvironmentChanged {
  [CmdletBinding()]
  param (
    [parameter(Position=0,HelpMessage="The value that changed.")]
    [string]$ChangedName="Environment"
  )
  PROCESS {
    if (-not ("win32.nativemethods" -as [type])) {
      # import sendmessagetimeout from win32
      add-type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@
    }

    $HWND_BROADCAST = [intptr]0xffff;
    $WM_SETTINGCHANGE = 0x1a;
    $result = [uintptr]::zero
    [win32.nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [uintptr]::Zero, $ChangedName, 2, 5000, [ref]$result) | Out-Null
  }
}

if($SetEnvPSModulePath) {
  Write-Host "== SET PSModulePath ==" -ForegroundColor "Green"
  Write-Host ""
  AppendEnvVariable PSModulePath $ModulePath
}

if($SetEnvPath) {
  Write-Host "== SET PATH ==" -ForegroundColor "Green"
  Write-Host ""
  AppendEnvVariable Path $ModulePath
}

if($SetEnvPSModulePath -or $SetEnvPath) {
  NotifyEnvironmentChanged
}

if($ExportModules) {
  Write-Host "== EXPORT MODULES ==" -ForegroundColor "Green"
  Write-Host ""

  if(!(Test-Path $ModulePath -pathtype container)) {
    Write-Host "Creating module directory at $ModulePath..."
    New-Item -path $ModulePath -itemtype directory -force | Out-Null
  }
  $FromPath = Resolve-Path (Join-Path Modules Pod)
  $ToPath = Resolve-Path $ModulePath
  Write-Host "Copying module folder at $FromPath to $ToPath..."
  cp $FromPath $ToPath -recurse -force
  Write-Host "Modules successfully exported!" -ForegroundColor "Green"
  Import-Module Pod -force
}
