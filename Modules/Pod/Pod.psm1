[CmdletBinding()]
PARAM()

### DEFINITIONS ###
$POD_SEMVER_MAJOR = 0
$POD_SEMVER_MINOR = 3
$POD_SEMVER_PATCH = 2
$POD_VERSION  = "$POD_SEMVER_MAJOR.$POD_SEMVER_MINOR.$POD_SEMVER_PATCH"

### END DEFINITIONS ###

### FUNCTIONS ###

function Get-TimeStamp {
  "$(get-date -f yyyyMMdd\THHmmss)"
}

# PRINTS DEBUG INFORMATION IF POD_LOG=$TRUE or POD_DEBUG=$TRUE or POD_TRACE=$TRUE #
function Log {
  [CmdletBinding(DefaultParameterSetName="Deploy")]
  PARAM(
    [parameter(Position=0,HelpMessage="Array of messages to print.")]
    [string[]]$Messages,

    [parameter(HelpMessage="Specifies information is trace level.")]
    [alias("t")]
    [switch]$TraceFlag,

    [parameter(HelpMessage="Specifies information is debug level.")]
    [alias("d")]
    [switch]$DebugFlag,

    [parameter(HelpMessage="Specifies information is log level.")]
    [alias("l")]
    [switch]$LogFlag = !$TraceFlag -and !$DebugFlag
  )
  PROCESS {
    foreach($Message in $Messages) {
      if($TraceFlag) {
        Write-Verbose "|TRACE|$Message|"
      }
      elseif($DebugFlag) {
        Write-Verbose "|DEBUG|$Message|"
      }
      elseif($LogFlag) {
        Write-Verbose "|LOG|$Message|"
      }
    }
  }
}

# SETS WORKING DIRECTORY FOR .NET #
function SetWorkDir($PathName, $TestPath) {
  Log "SetWorkDir $PathName $TestPath" -t
  $AbsPath = NormalizePath $PathName $TestPath
  Log "SetWorkDir`t-> AbsPath=$AbsPath" -d
  Set-Location $AbsPath
  [System.IO.Directory]::SetCurrentDirectory($AbsPath)
}

# SETS WORKING DIRECTORY FOR .NET TO CURRENT SCRIPT DIRECTORY #
function SetWorkDirCurrent() {
  Log "SetWorkDirCurrent" -t
  $CurrentPath = (Get-Location -PSProvider FileSystem).ProviderPath
  Log "SetWorkDirCurrent`t-> CurrentPath=$CurrentPath" -t
  SetWorkDir working/directory $CurrentPath | Out-Null
}

# RESTORES THE EXECUTION WORKING DIRECTORY AND EXITS #
function SafeExit() {
  SetWorkDir /path/to/execution/directory $ExecutionDirectory
  Log "EXIT" -d
  Break
}

# PRINT A MESSAGE TO SCREEN WITH FORMATTING #
function Print {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Message to print.")]
    [string]$Message,

    [parameter(HelpMessage="Specifies a success.")]
    [alias("s")]
    [switch]$SuccessFlag,

    [parameter(HelpMessage="Specifies a warning.")]
    [alias("w")]
    [switch]$WarningFlag,

    [parameter(HelpMessage="Specifies an error.")]
    [alias("e")]
    [switch]$ErrorFlag,

    [parameter(HelpMessage="Specifies a fatal error.")]
    [alias("f")]
    [switch]$FatalFlag,

    [parameter(HelpMessage="Specifies an info message.")]
    [alias("i")]
    [switch]$InfoFlag = !$SuccessFlag -and !$WarningFlag -and !$ErrorFlag -and !$FatalFlag,

    [parameter(HelpMessage="Specifies blank lines to print before.")]
    [alias("b")]
    [int]$LinesBefore=0,

    [parameter(HelpMessage="Specifies blank lines to print after.")]
    [alias("a")]
    [int]$LinesAfter=0,

    [parameter(HelpMessage="Specifies if program should exit.")]
    [alias("x")]
    [switch]$ExitAfter
  )
  PROCESS {
    if(!$Porcelain) {
      if($LinesBefore -ne 0) {
        foreach($i in 0..$LinesBefore) { Write-Host "" }
      }
      if($InfoFlag) { Write-Host "$Message" }
      if($SuccessFlag) { Write-Host "$Message" -ForegroundColor "Green" }
      if($WarningFlag) { Write-Host "$Message" -ForegroundColor "Yellow" }
      if($ErrorFlag) { Write-Host "$Message" -ForegroundColor "Red" }
      if($FatalFlag) { Write-Host "$Message" -ForegroundColor "Red" -BackgroundColor "Black" }
      if($LinesAfter -ne 0) {
        foreach($i in 0..$LinesAfter) { Write-Host "" }
      }
    }
    if($ExitAfter) { SafeExit }
  }
}

# PRINTS HEADER INFORMATION FOR APP #
function PrintHeader {
  if($Porcelain) {
    return
  }
  Log "PrintHeader" -t

  Write-Host ""
  Write-Host "== " -NoNewLine -ForegroundColor "Cyan"
  Write-Host "pod (version $POD_VERSION) [" -NoNewLine -ForegroundColor "Cyan"
  Write-Host "$ExecutionStamp" -NoNewLine -ForegroundColor "Yellow"
  Write-Host "] ==" -ForegroundColor "Cyan"
  Write-Host ""
}

# PRINTS USAGE INFORMATION FOR APP #
function PrintUsage {
  [CmdletBinding()]
  param (
    [parameter(HelpMessage="Module to print usage for.")]
    [string]$Module="Pod",

    [parameter(Position=0,HelpMessage="Optional array of errors to print.")]
    [string[]]$ErrorMessages,

    [parameter(HelpMessage="Specifies where the error occurred.")]
    [alias("s")]
    [string]$ErrorSource,

    [parameter(HelpMessage="Specifies if program should exit.")]
    [alias("x")]
    [switch]$ExitAfter
  )
  PROCESS {
    if(!$Porcelain) {
      Log "PrintUsage" -t
      Write-Host "== USAGE ==" -ForegroundColor "Cyan"
      Get-Help $Module
      if($ErrorMessages) {
        Write-Host ""
        Write-Host "`t" -NoNewLine
        Write-Host "== Errors ==" -ForegroundColor "Red" -BackgroundColor "Black"
        if($ErrorSource) {
          Write-Host "`t" -NoNewLine
          Write-Host "Error Source: [$ErrorSource]" -ForegroundColor "Red"
        }
        foreach($ErrorMessage in $ErrorMessages) {
          Write-Host "`t" -NoNewLine
          Write-Host "Error: [$ErrorMessage]" -ForegroundColor "Red"
        }
      }
      Write-Host ""
    }
    if($ExitAfter) {
      SafeExit
    }
  }
}

# VALIDATES STRING MIGHT BE A PATH #
function ValidatePath($PathName, $TestPath) {
  Log "ValidatePath $PathName $TestPath" -t
  If([string]::IsNullOrWhiteSpace($TestPath)) {
    PrintUsage "$PathName is not a path" -s "ValidatePath $PathName $TestPath" -x
  }
}

# NORMALIZES RELATIVE OR ABSOLUTE PATH TO ABSOLUTE PATH #
function NormalizePath($PathName, $TestPath) {
  Log "NormalizePath $PathName $TestPath" -t
  ValidatePath "$PathName" "$TestPath"
  $TestPath = [System.IO.Path]::Combine((pwd).Path, $TestPath)
  $NormalizedPath = [System.IO.Path]::GetFullPath($TestPath)
  Log "NormalizePath`t-> NormalizedPath=$NormalizedPath" -t
  return $NormalizedPath
}


# VALIDATES STRING MIGHT BE A PATH AND RETURNS ABSOLUTE PATH #
function ResolvePath($PathName, $TestPath) {
  Log "ResolvePath $PathName $TestPath" -t
  ValidatePath "$PathName" "$TestPath"
  $ResolvedPath = NormalizePath $PathName $TestPath
  Log "ResolvePath`t-> ResolvedPath=$ResolvedPath" -t
  return $ResolvedPath
}

# VALIDATES STRING RESOLVES TO A PATH AND RETURNS ABSOLUTE PATH #
function RequirePath($PathName, $TestPath, $PathType) {
  Log "RequirePath $PathName $TestPath $PathType" -t
  ValidatePath $PathName $TestPath
  If(!(Test-Path $TestPath -PathType $PathType)) {
    PrintUsage "$PathName ($TestPath) does not exist as a $PathType" -s "RequirePath $PathName $TestPath $PathType" -x
  }
  $ResolvedPath = Resolve-Path $TestPath
  Log "RequirePath`t-> ResolvedPath=$ResolvedPath" -t
  return $ResolvedPath
}

# Like mkdir -p -> creates a directory recursively if it doesn't exist #
function MakeDirP {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path create.")]
    [string]$Path
  )
  PROCESS {
    New-Item -path $Path -itemtype Directory -force | Out-Null
  }
}

# Like cp -rf -> Copies file or directory (recursive / force) and ensures destination exists first #
function CopyPath {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to copy from.")]
    [alias("f")]
    [string]$FromPath,

    [parameter(Mandatory=$TRUE,Position=1,HelpMessage="Path to copy to.")]
    [alias("t")]
    [string]$ToPath
  )
  PROCESS {
    New-Item -path $ToPath -itemtype file -force | Out-Null
    cp $FromPath $ToPath -recurse -force
  }
}

# Like cp -rf -> Copies file or directory (recursive / force) and ensures destination exists first #
function MakePath {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to copy from.")]
    [alias("b")]
    [string]$BasePath,

    [parameter(Position=1,HelpMessage="Path to copy to.")]
    [alias("r")]
    [string]$RelativePath
  )
  PROCESS {
    if($RelativePath) {
      $FullPath = Join-Path $BasePath $RelativePath
      Write-Host "Creating path at $FullPath..."
      New-Item -path $FullPath -itemtype file -force | Out-Null
      return $FullPath
    }
    else {
      Write-Host "Creating path at $BasePath..."
      New-Item -path $BasePath -itemtype file -force | Out-Null
      $BasePath
    }
  }
}

# INLINE IF STATEMENT #
function IIf($If, $IfTrue, $IfFalse) {
  Log "IIf $If $IfTrue $IfFalse" -t
  If ($If -IsNot "Boolean") {$_ = $If}
  If ($If) {If ($IfTrue -is "ScriptBlock") {&$IfTrue} Else {$IfTrue}}
  Else {If ($IfFalse -is "ScriptBlock") {&$IfFalse} Else {$IfFalse}}
}

# GETS ALL FOLDERS IN A PATH RECURSIVELY #
function GetFolders {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to get directories for.")]
    [string]$Path
  )
  PROCESS {
    ls $Path -r | where { $_.PSIsContainer }
  }
}

# GETS ALL FILES IN A PATH RECURSIVELY #
function GetFiles {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to get files for.")]
    [string]$Path
  )
  PROCESS {
    ls $Path -r | where { !$_.PSIsContainer }
  }
}

# GETS ALL FILES WITH CALCULATED HASH PROPERTY RELATIVE TO A ROOT DIRECTORY RECURSIVELY #
# RETURNS LIST OF @{RelativePath, Hash, FullName}
function GetFilesWithHash {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to get directories for.")]
    [string]$Path,

    [parameter(HelpMessage="The hash algorithm to use.")]
    [string]$Algorithm="MD5"
  )
  PROCESS {
    $OriginalPath = $PWD
    SetWorkDir path/to/diff $Path
    GetFiles $Path | select @{N="RelativePath";E={$_.FullName | Resolve-Path -Relative}},
                            @{N="Hash";E={(Get-FileHash $_.FullName -Algorithm $Algorithm | select Hash).Hash}},
                            FullName
    SetWorkDir path/to/original $OriginalPath
  }
}

# COMPARE TWO DIRECTORIES RECURSIVELY #
# RETURNS LIST OF @{RelativePath, Hash, FullName}
function DiffDirectories {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Directory to compare left.")]
    [alias("l")]
    [string]$LeftPath,

    [parameter(Mandatory=$TRUE,Position=1,HelpMessage="Directory to compare right.")]
    [alias("r")]
    [string]$RightPath
  )
  PROCESS {
    $LeftHash = GetFilesWithHash $LeftPath
    $RightHash = GetFilesWithHash $RightPath
    diff -ReferenceObject $LeftHash -DifferenceObject $RightHash -Property RelativePath,Hash
  }
}

function ReadPodfile {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to podfile.json.")]
    [alias("p")]
    [string]$PodfilePath
  )
  PROCESS {
    $PodfilePath = RequirePath path/to/podfile $PodfilePath leaf
    $PodfileJson = cat $PodfilePath | Out-String
    ConvertFrom-Json $PodfileJson
  }
}

function ReadPodbuild{
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to podbuild.json.")]
    [alias("p")]
    [string]$PodbuildPath
  )
  PROCESS {
    $PodbuildPath = RequirePath path/to/podbuild $PodbuildPath leaf
    $PodbuildJson = cat $PodbuildPath | Out-String
    ConvertFrom-Json $PodbuildJson
  }
}

function SavePodfile {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to podfile.json.")]
    [alias("p")]
    [string]$PodfilePath,

    [parameter(Mandatory=$TRUE,Position=1,HelpMessage="Podfile content object.")]
    [alias("c")]
    [Object[]]$PodfileContent
  )
  PROCESS {
    $PodfileJson = ConvertTo-Json $PodfileContent
    $PodfilePath = ResolvePath $PodfilePath
    $PodfileJson >$PodfilePath
    Print -s "Podfile successfully written to $PodfilePath"
  }
}

function New-Podfile {
  [CmdletBinding(
    SupportsShouldProcess=$TRUE,
    ConfirmImpact="Medium"
  )]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to podfile.json.")]
    [alias("p")]
    [string]$PodfilePath,

    [parameter(Mandatory=$TRUE,Position=1,HelpMessage="Name of server root.")]
    [alias("n")]
    [string]$Name,

    [parameter(Mandatory=$TRUE,Position=2,HelpMessage="The path to the server root.")]
    [alias("t")]
    [string]$ServerRoot,

    [parameter(Mandatory=$TRUE,Position=3,HelpMessage="The path to the server archive.")]
    [alias("a")]
    [string]$ArchiveRoot
  )
  PROCESS {
    if(!$pscmdlet.ShouldProcess($PodfilePath)) {
      Print -x -e "Podfile was not created. Goodbye."
    }
    $ServerRoot = ResolvePath path/to/server/root $ServerRoot
    $ArchiveRoot = ResolvePath path/to/archive/root $ArchiveRoot
    $PodfileJson = @"
{ "targets":  [ { "name": "$Name"
                , "root": "$ServerRoot"
                , "archive": "$ArchiveRoot"
                }
              ]
}
"@ -replace "\\","\\"
    $PodfileJson >$PodfilePath
    Print -s "Podfile successfully written to $PodfilePath"
  }
}

function Test-Svn {
  [CmdletBinding()]
  PARAM(
    [parameter(Position=0,HelpMessage="SVN path to test")]
    [alias("p")]
    [string]$Path=$PWD
  )
  PROCESS {
    $statusRaw=$(svn status --depth=empty $Path 2>&1)
    if($statusRaw -like "*is not a working copy*") {
      $FALSE
    }
    else {
      $TRUE
    }
  }
}

function Test-Git {
  [CmdletBinding()]
  PARAM(
    [parameter(Position=0,HelpMessage="GIT path to test")]
    [alias("p")]
    [string]$Path=$PWD
  )
  PROCESS {
    $statusRaw=$(git status --porcelain $Path 2>&1)
    if($statusRaw -like "*Not a git repository*") {
      $FALSE
    }
    else {
      if($statusRaw) {
        Write-Host "Git is currently dirty.  Commit first."
        $FALSE
      }
      else {
        $TRUE
      }
    }
  }
}

function Export-PodSvn {
  [CmdletBinding()]
  PARAM(
    [parameter(HelpMessage="SVN path to export (supports subpaths)")]
    [alias("t")]
    [string]$ExportTargetPath=$PWD,

    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to pod root")]
    [alias("p")]
    [string]$PodRoot,

    [parameter(HelpMessage="First revision in range to get")]
    [alias("f")]
    [string]$RevisionFirst="COMMITTED",

    [parameter(HelpMessage="Last revision in range to get")]
    [alias("l")]
    [string]$RevisionLast="BASE"
  )
  PROCESS {
    $PodRoot = ResolvePath path/to/pod $PodRoot

    if(!(Test-Svn $ExportTargetPath)) {
      Print -f -x "$ExportTargetPath is not an SVN repository or subpath. Cannot export."
    }
    $RevisionRange = "${RevisionFirst}:${RevisionLast}"
    Print "Exporting revisions [$RevisionRange] from SVN [$ExportTargetPath] to pod [$PodRoot]..."

    $FilesRoot = Join-Path $PodRoot files
    $EtcRoot = Join-Path $PodRoot etc
    $EtcDeletedPath = Join-Path $EtcRoot delete
    if(Test-Path $FilesRoot) {
      Print -w "Deleting old files root at [$FilesRoot]"
      rmdir -force $FilesRoot
    }
    if(Test-Path $EtcRoot) {
      Print -w "Deleting old files root at [$EtcRoot]"
      rmdir -force $EtcRoot
    }
    MakeDirP $FilesRoot
    MakeDirP $EtcRoot
    # ON SERVER
    # svnlook changed OR svnlook diff

    $OriginalPath = $PWD
    SetWorkDir path/to/svn $ExportTargetPath

    # http://svnbook.red-bean.com/en/1.7/svn.tour.revs.specifiers.html
    $LogRaw=svn diff --summarize -r $RevisionRange
    $ModifiedPaths = ($LogRaw | where { $_.StartsWith("M") }) -replace "^[MDA]\s*",""
    $AddedPaths = ($LogRaw | where { $_.StartsWith("A") }) -replace "^[MDA]\s*",""
    $DeletedPaths = ($LogRaw | where { $_.StartsWith("D") }) -replace "^[MDA]\s*",""

    Write-Host "MODIFIED: $ModifiedPaths"
    Write-Host "ADDED: $AddedPaths"
    Write-Host "DELETED: $DeletedPaths"

    $ModifiedExportResult = $ModifiedPaths | %{svn export --native-eol CRLF --force -r $RevisionLast $_ $(MakePath $FilesRoot $_)}
    $AddedExportResult =  $AddedPaths | %{svn export --native-eol CRLF --force -r $RevisionLast $_ $(MakePath $FilesRoot $_)}
    $DeletedPaths | %{$_ >>$EtcDeletedPath}

    SetWorkDir path/to/original $OriginalPath
  }
}

function Export-PodGit {
  [CmdletBinding()]
  PARAM(
    [parameter(HelpMessage="Git path to export (supports subpaths)")]
    [alias("t")]
    [string]$ExportTargetPath=$PWD,

    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to pod root")]
    [alias("p")]
    [string]$PodRoot,

    [parameter(HelpMessage="First revision in range to get")]
    [alias("f")]
    [string]$RevisionFirst="HEAD~1",

    [parameter(HelpMessage="Last revision in range to get")]
    [alias("l")]
    [string]$RevisionLast="HEAD"
  )
  PROCESS {
    $PodRoot = ResolvePath path/to/pod $PodRoot

    if(!(Test-Git $ExportTargetPath)) {
      Print -f -x "$ExportTargetPath is not an GIT repository or subpath. Cannot export."
    }

    Print "Exporting revisions [$RevisionFirst..$RevisionLast] from GIT [$ExportTargetPath] to pod [$PodRoot]..."

    $FilesRoot = Join-Path $PodRoot files
    $EtcRoot = Join-Path $PodRoot etc
    $EtcDeletedPath = Join-Path $EtcRoot delete
    if(Test-Path $FilesRoot) {
      Print -w "Deleting old files root at [$FilesRoot]"
      rmdir -force $FilesRoot
    }
    if(Test-Path $EtcRoot) {
      Print -w "Deleting old files root at [$EtcRoot]"
      rmdir -force $EtcRoot
    }
    MakeDirP $FilesRoot
    MakeDirP $EtcRoot

    $OriginalPath = $PWD
    SetWorkDir path/to/git $ExportTargetPath
    Print "Checking out $RevisionLast..."
    git checkout $RevisionLast | Out-Null

    # http://svnbook.red-bean.com/en/1.7/svn.tour.revs.specifiers.html
    $LogRaw=$(git diff --name-status --relative $RevisionFirst $RevisionLast)
    $ModifiedPaths = ($LogRaw | where { $_.StartsWith("M") }) -replace "^[MDA]\s*",""
    $AddedPaths = ($LogRaw | where { $_.StartsWith("A") }) -replace "^[MDA]\s*",""
    $DeletedPaths = ($LogRaw | where { $_.StartsWith("D") }) -replace "^[MDA]\s*",""

    Write-Host "MODIFIED: $ModifiedPaths"
    Write-Host "ADDED: $AddedPaths"
    Write-Host "DELETED: $DeletedPaths"

    $ModifiedExportResult = $ModifiedPaths | %{CopyPath $_ $(MakePath $FilesRoot $_)}
    $AddedExportResult =  $AddedPaths | %{CopyPath $_ $(MakePath $FilesRoot $_)}
    $DeletedPaths | %{$_ >>$EtcDeletedPath}

    SetWorkDir path/to/original $OriginalPath
  }
}

### END FUNCTIONS ###

### EXPORTED FUNCTIONS ###


<###############################################################################
PODFILE.JSON FORMAT
PURPOSE: DEFINES THE WHERE
DESC: PODFILE IN ROOT OF POD PACKAGE DEFINES WHERE TO DEPLOY AND ARCHIVE
RUNS ON: LOCAL, BUILD SERVER, WEB SERVER

{ "targets":  [ { "name":     "SERVER_ONE"
                , "root":     "path/to/server/one/root"
                , "archive":  "path/to/archive/one/root"
                }
              , { "name":     "SERVER_TWO"
                , "root":     "/abs/path/to/server/root/two/root"
                , "archive":  "\\\\unc-server\\path\\to\\archive\\two\\root"
                }
              ]
}
###############################################################################>

<###############################################################################
PODBUILD.JSON FORMAT
PURPOSE: DEFINES THE HOW
DESC: PODBUILD DEFINES CONFIGURATION AND BUILD STEPS FOR POD EXPORT
RUNS ON: LOCAL, BUILD SERVER

{
  "export": { "target":     "C:\\repo\\WebApp"
            , "podfile":    "\\\\shared\\podfiles\\podfile.WebApp.json"
            , "podroot":    "C:\\pods\\webapp"
            , "svn":        true
            , "git":        false
            , "revisions":  [ "PREV", "COMMITTED" ]
            }
, "pre":    [ { "name":     "LOG_EXPORT"
              , "command":  "Log-Export \"Running Pod-Export...\""
              }
            ]
, "post":   [ { "name":     "TRANSFORM_WEBAPP_DEV"
              , "command":  "cp -force web.dev.config web.config"
              , "location": "TixWebApp"
              }
            , { "name":     "BUILD_WEBAPP"
              , "command":  "Build-Net TixWebApp"
              }
            , { "name":     "UPLOAD_S3"
              , "command":  "Upload-S3"
              , "location": "$PodRoot"
              }
            ]
}
###############################################################################>


Add-Type -Language CSharp @"
public class CommandDefinition {
  public string Name { get; set; }
  public string Command { get; set; }
  public string Location { get; set; }

  public CommandDefinition(string name, string command, string location="") {
    Name = name;
    Command = command;
    Location = location;
  }
}
"@

Function New-CommandDefinition {
  [CmdletBinding()]
  PARAM(
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="The name of the command.")]
    [string]$Name,

    [parameter(Mandatory=$TRUE,Position=1,HelpMessage="The command to execute.")]
    [string]$Command,

    [parameter(Position=2,HelpMessage="The path to execute the command in.")]
    [string]$Location
  )
  PROCESS {
    if($Location) {
      New-Object -TypeName CommandDefinition -ArgumentList $Name,$Command,$Location
    }
    else {
      New-Object -TypeName CommandDefinition -ArgumentList $Name,$Command
    }
  }
}

Function Export-Pod {
  [CmdletBinding(DefaultParameterSetName="Export")]
  PARAM(
    [parameter(ParameterSetName="Export",Position=0,HelpMessage="The podbuild.json file to use for export")]
    [alias("podbuild")]
    [string]$PodbuildPath,

    [parameter(ParameterSetName="Export",Position=1,HelpMessage="Path to export pods to")]
    [alias("pod")]
    [string]$PodRoot,

    [parameter(ParameterSetName="Export",HelpMessage="The target path to export from source control")]
    [alias("t","target")]
    [string]$ExportTargetPath,

    [parameter(ParameterSetName="Export",HelpMessage="Path to podfile configuration to use")]
    [alias("podfile")]
    [string]$PodfilePath,

    [parameter(Mandatory=$TRUE,ParameterSetName="Export",HelpMessage="'git' or 'svn' export strategy.")]
    [ValidateSet("git","svn")]
    [alias("s")]
    [string]$Strategy,

    [parameter(ParameterSetName="Export",HelpMessage="Used for SVN / GIT integration")]
    [ValidateCount(0,2)]
    [alias("r","revs")]
    [string[]]$Revisions,

    [parameter(ParameterSetName="Export",HelpMessage="Commands to run prior to export")]
    [alias("pre")]
    [CommandDefinition[]]$PreCommands,

    [parameter(ParameterSetName="Export",HelpMessage="Commands to run post export")]
    [alias("post")]
    [CommandDefinition[]]$PostCommands,

    [parameter(HelpMessage="Machine / PowerShell parsable output")]
    [alias("p")]
    [switch]$Porcelain
  )
  BEGIN {
    $ExecutionDirectory = $PWD
    $ExecutionStamp = Get-TimeStamp
  }
  PROCESS {
    switch($pscmdlet.ParameterSetName) {
      "Export" {
        if($PodbuildPath) {
          $Podbuild = ReadPodbuild $PodbuildPath
          if($Podbuild.target) {

          }
          return
        }

        if(!$ExportTargetPath) {
          $ExportTargetPath = $PWD
        }
        $PodfileExportPath = ResolvePath path/to/podfile/export (Join-Path $PodRoot podfile.json)
        if(!$PodfilePath) { $PodfilePath=$PodfileExportPath }
        $PodfilePath = ResolvePath path/to/podfile $PodfilePath
        if(!$UseGit -and !$UseSvn) {
          if(Test-Git $ExportTargetPath) {
            Print "git detected at [$ExportTargetPath] -> enabling UseGit strategy"
            $UseGit = $TRUE
          }
          elseif(Test-Svn $ExportTargetPath) {
            Print "svn detected at [$ExportTargetPath] -> enabling UseGit strategy"
            $UseSvn = $TRUE
          }
          else {
            Print -f "-Export flag requires -UseGit or -UseSvn strategy flag"
            return
          }
        }
        if($Revisions) {
          if($Revisions.Count -ne 2) {
            Print -f "-Revisions requires 2 revisions (range) to export"
            return
          }
          $RevisionFirst = $Revisions[0]
          $RevisionsLast = $Revisions[1]
        }
      }
    }

    if(!(Test-Path $PodfilePath -PathType leaf)) {
      Print -w "No podfile exists at $PodfilePath, creating one..."
      New-PodFile $PodfilePath -Confirm
    }
    if($PodfilePath -ne $PodfileExportPath) {
      CopyPath $PodfilePath $PodfileExportPath
    }
    $Podfile = ReadPodfile $PodfileExportPath
    Print -s "-- PODFILE --"
    $Podfile

    if($UseSvn) {
      if($Revisions) {
        $ExportOutput = Export-PodSvn -ExportTargetPath $ExportTargetPath -RevisionFirst $RevisionFirst -RevisionLast $RevisionLast $PodRoot
      }
      else {
        $ExportOutput = Export-PodSvn -ExportTargetPath $ExportTargetPath $PodRoot
      }
    }
    if($UseGit) {
      if($RevisionLast) {
        $ExportOutput = Export-PodGit -ExportTargetPath $ExportTargetPath -RevisionFirst $RevisionFirst -RevisionLast $RevisionLast $PodRoot
      }
      else {
        $ExportOutput = Export-PodGit -ExportTargetPath $ExportTargetPath $PodRoot
      }
    }
    Print -s "-- EXPORT OUTPUT --"
    $ExportOutput
  }
  END {
    SafeExit
  }
}

function Pod {
  [CmdletBinding(DefaultParameterSetName="Deploy")]
  PARAM(
    [parameter(ParameterSetName="Deploy",Position=0,HelpMessage="Pod package directory path")]
    [parameter(ParameterSetName="Rollback",Position=0,HelpMessage="Pod package directory path")]
    [alias("pod")]
    [string]$PodRoot,

    [parameter(ParameterSetName="Deploy",HelpMessage="Path to podfile configuration to use")]
    [parameter(ParameterSetName="Rollback",HelpMessage="Path to podfile configuration to use")]
    [alias("podfile")]
    [string]$PodfilePath,

    [parameter(ParameterSetName="Rollback",HelpMessage="Rollback a pod delta archive")]
    [alias("r", "rb")]
    [switch]$Rollback,

    [parameter(HelpMessage="Machine / PowerShell parsable output")]
    [alias("p")]
    [switch]$Porcelain
  )
  BEGIN {
    $ExecutionDirectory=$PWD
    $ExecutionStamp = Get-TimeStamp
  }
  PROCESS {

    ### VALIDATION ###

    switch($pscmdlet.ParameterSetName) {
      "Deploy" {
        if(!$PodRoot) { $PodRoot = $PWD }
        if(!$PodfilePath) { $PodfilePath=(Join-Path $PodRoot podfile.json) }
        $PodfilePath = ResolvePath path/to/podfile $PodfilePath
      }
      "Rollback" {
        if(!$PodRoot) { $PodRoot = $PWD }
        if(!$PodfilePath) { $PodfilePath=(Join-Path $PodRoot podfile.json) }
        $PodfilePath = ResolvePath path/to/podfile $PodfilePath
      }
    }

    ### END VALIDATION ###

    Log "START" -d
    PrintHeader
    Print -s -a 1 "== $($pscmdlet.ParameterSetName) Mode =="

    ### END DIFF ###

    ### ROLLBACK ###

    if($Rollback) {
      Print -x "Rollback mode is not yet implemented." -f
      SafeExit
    }

    ### END ROLLBACK ###

    ### DEPLOY ###

    Log "CONFIGURE BASIC PATHS" -d
    $POD_ROOT         = RequirePath /path/to/pod $PodRoot container
    $FILES_ROOT       = Join-Path $POD_ROOT files
    $ETC_ROOT         = Join-Path $POD_ROOT etc
    $ETC_DELETE_PATH  = Join-Path $ETC_ROOT delete
    $ETC_ARCHIVE_PATH = Join-Path $ETC_ROOT archive
    $ETC_TARGET_PATH  = Join-Path $ETC_ROOT target

    Log "POD_ROOT`t`t-> $POD_ROOT"

    if(!(Test-Path $ETC_ROOT)) {
      PrintUsage "In deployment mode, pod must be run from a pod package directory or be passed the path to one." -x
    }

    Log "SET WORKING DIRECTORY TO CURRENT" -d
    SetWorkDirCurrent

    Log "REQUIRE TOP LEVEL POD PATHS" -d
    $FILES_ROOT       = RequirePath pod/files $FILES_ROOT container
    $ETC_ROOT         = RequirePath pod/etc $ETC_ROOT container
    $ETC_DELETE_PATH  = RequirePath pod/etc/delete $ETC_DELETE_PATH leaf

    Log "FILES_ROOT`t`t-> $FILES_ROOT"
    Log "ETC_ROOT`t`t-> $ETC_ROOT"
    Log "ETC_DELETE_PATH`t-> $ETC_DELETE_PATH"
    Log "ETC_ARCHIVE_PATH`t-> $ETC_ARCHIVE_PATH"
    Log "ETC_TARGET_PATH`t-> $ETC_TARGET_PATH"

    Log "SET WORKING DIRECTORY TO POD ROOT" -d
    SetWorkDir path/to/pod $POD_ROOT

    Log "READ PODFILE" -d
    $Podfile = ReadPodFile $PodfilePath
    $Target = $Podfile.targets[0]

    Log "READ ETC CONFIGURATIONS" -d
    $DELETE_PATHS = cat $ETC_DELETE_PATH | ? {$_}

    #$TARGET_ROOT  = cat $ETC_TARGET_PATH | ? {ResolvePath pod/etc/target $_ container}
    #$ARCHIVE_PARENT_ROOT = cat $ETC_ARCHIVE_PATH | ? {ResolvePath pod/etc/archive $_}
    $TARGET_NAME = $Target.name
    $TARGET_ROOT = ResolvePath podfile/target $Target.root container
    $ARCHIVE_PARENT_ROOT = ResolvePath podfile/archive $Target.archive container

    Log "TARGET_ROOT`t-> $TARGET_ROOT"
    Log "ARCHIVE_ROOT`t-> $ARCHIVE_ROOT"

    $ARCHIVE_ROOT =  Join-Path $ARCHIVE_PARENT_ROOT "archive-$ExecutionStamp"

    Log "ETC RAW CONFIGURATIONS READ" -d
    Log "DELETE_PATHS`t-> $DELETE_PATHS" -d
    Log "TARGET_ROOT`t-> $TARGET_ROOT" -d
    Log "ARCHIVE_ROOT`t-> $ARCHIVE_ROOT" -d

    Log "VALIDATE PATHS SPECIFIED IN ETC FILES" -d

    Log "JOIN ARCHIVE PATHS" -d
    $ARCHIVE_PODFILE_PATH   = Join-Path $ARCHIVE_ROOT podfile.json
    $ARCHIVE_DELETED_ROOT   = Join-Path $ARCHIVE_ROOT D
    $ARCHIVE_MODIFIED_ROOT  = Join-Path $ARCHIVE_ROOT M
    $ARCHIVE_ADDED_PATH     = Join-Path $ARCHIVE_ROOT added

    Log "VALIDATE ARCHIVE PATHS" -d

    $ARCHIVE_PODFILE_PATH   = ResolvePath podfile/archive $ARCHIVE_PODFILE_PATH
    $ARCHIVE_DELETED_ROOT   = ResolvePath podfile/archive $ARCHIVE_DELETED_ROOT
    $ARCHIVE_MODIFIED_ROOT  = ResolvePath podfile/archive $ARCHIVE_MODIFIED_ROOT
    $ARCHIVE_ADDED_PATH     = ResolvePath podfile/archive $ARCHIVE_ADDED_PATH

    Log "ARCHIVE_PODFILE_PATH`t-> $ARCHIVE_PODFILE_PATH" -d
    Log "ARCHIVE_DELETED_ROOT`t-> $ARCHIVE_DELETED_ROOT" -d
    Log "ARCHIVE_MODIFIED_ROOT`t-> $ARCHIVE_MODIFIED_ROOT" -d
    Log "ARCHIVE_ADDED_PATH`t-> $ARCHIVE_ADDED_PATH" -d

    New-Item -path $ARCHIVE_PODFILE_PATH -itemtype file -force | Out-Null
    cp $PodfilePath $ARCHIVE_PODFILE_PATH -recurse -force

    Write-Host "`tTARGET`t-> $TARGET_ROOT"
    Write-Host "`tARCHIVE`t-> $ARCHIVE_ROOT"
    Write-Host "`tFILES`t-> $FILES_ROOT"

    $FoldersToDelete  = $DELETE_PATHS | % { IIf (Test-Path (Join-Path $TARGET_ROOT $_) -PathType container) {$_} } | ? {$_}
    $FilesToDelete    = $DELETE_PATHS | % { IIf (Test-Path (Join-Path $TARGET_ROOT $_) -PathType leaf) {$_} } | ? {$_}
    Log "FoldersToDelete`t-> $FoldersToDelete"
    Log "FilesToDelete`t-> $FilesToDelete"

    SetWorkDir FILES_ROOT $FILES_ROOT
    Log "GETTING LIST OF FILES TO DEPLOY" -d
    $DeployFiles = ls -recurse | where {!$_.psIsContainer -eq $true} | foreach -Process {$_.FullName | Resolve-Path -Relative}
    Log "DeployFiles`t-> $DeployFiles"

    Write-Host ""
    Write-Host "== Archiving Deletion Folders ==" -ForegroundColor "Yellow"
    foreach ($ExistingPath In $FoldersToDelete) {
      $FromPath = Join-Path $TARGET_ROOT $ExistingPath
      $ToPath = Join-Path $ARCHIVE_DELETED_ROOT $ExistingPath
      Write-Host "`tCopying folder $FromPath to $ToPath"
      New-Item -path $ToPath -itemtype directory -force | Out-Null
      cp $FromPath $ToPath -container -recurse -force
    }

    Write-Host ""
    Write-Host "== Archiving Deletion Files ==" -ForegroundColor "Yellow"
    foreach ($ExistingPath In $FilesToDelete) {
      $FromPath = Join-Path $TARGET_ROOT $ExistingPath
      $ToPath = Join-Path $ARCHIVE_DELETED_ROOT $ExistingPath
      Write-Host "`tCopying file $FromPath to $ToPath"
      New-Item -path $ToPath -itemtype file -force | Out-Null
      cp $FromPath $ToPath -recurse -force
    }

    Write-Host ""
    Write-Host "== Deleting Files ==" -ForegroundColor "Red"
    foreach ($ExistingPath In $FilesToDelete) {
      $DeletePath = Join-Path $TARGET_ROOT $ExistingPath
      Write-Host "`tDeleting file $DeletePath"
      rm $DeletePath
    }

    Write-Host ""
    Write-Host "== Deleting Folders ==" -ForegroundColor "Red"
    foreach ($ExistingPath In $FoldersToDelete) {
      $DeletePath = Join-Path $TARGET_ROOT $ExistingPath
      Write-Host "`tDeleting folder $DeletePath"
      IIf (Test-Path $DeletePath) {rm $DeletePath -recurse -force}
    }

    Write-Host ""
    Write-Host "== Deploying Files ==" -ForegroundColor "Green"
    New-Item -path $ARCHIVE_ADDED_PATH -itemtype file -force | Out-Null
    foreach ($DeployPath In $DeployFiles) {
      $FromPath = Join-Path $FILES_ROOT $DeployPath
      $ToPath = Join-Path $TARGET_ROOT $DeployPath
      if(Test-Path $ToPath -PathType leaf) {
        $ArchivePath = Join-Path $ARCHIVE_MODIFIED_ROOT $DeployPath
        Write-Host "`tArchiving file $ToPath -> $ArchivePath"
        New-Item -path $ArchivePath -itemtype file -force | Out-Null
        cp $ToPath $ArchivePath -recurse -force
      }
      else {
        $DeployPath >> $ARCHIVE_ADDED_PATH
      }
      Write-Host "`tDeploying file $FromPath -> $ToPath"
      New-Item -path $ToPath -itemtype file -force | Out-Null
      cp $FromPath $ToPath -recurse -force
    }

    $DeletedFolderCount = ($FoldersToDelete | measure).Count
    $DeletedFileCount = ($FilesToDelete | measure).Count
    $DeployedFileCount = ($DeployFiles | measure).Count

    Write-Host ""
    Write-Host "== Deployment Complete ==" -ForegroundColor "Green" -BackgroundColor "Black"
    Write-Host "`tFolders Deleted: $DeletedFolderCount" -ForegroundColor "Red"
    Write-Host "`tFiles Deleted: $DeletedFileCount" -ForegroundColor "Red"
    Write-Host "`tFiles Deployed: $DeployedFileCount" -ForegroundColor "Green"
    Write-Host "`tArchive Location: $ARCHIVE_ROOT" -ForegroundColor "Magenta"

    ### END DEPLOY ###
  }
  END {
    SafeExit
  }
}


function RDiff {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Directory to compare left.")]
    [alias("l")]
    [string]$LeftPath,

    [parameter(Mandatory=$TRUE,Position=1,HelpMessage="Directory to compare right.")]
    [alias("r")]
    [string]$RightPath,

    [parameter(HelpMessage="Omit output for results from left side (for diffs)")]
    [switch]$NoLeft,

    [parameter(HelpMessage="Omit output for results from right side (for diffs)")]
    [switch]$NoRight,

    [parameter(HelpMessage="Export a summary to path")]
    [alias("s")]
    [string]$ExportSummary,

    [parameter(HelpMessage="Machine / PowerShell parsable output")]
    [alias("p")]
    [switch]$Porcelain
  )
  BEGIN {
    $ExecutionDirectory=$PWD
  }
  PROCESS {
    $LeftPath   = RequirePath path/to/left $LeftPath container
    $RightPath  = RequirePath path/to/right $RightPath container
    $Diff       = DiffDirectories $LeftPath $RightPath
    $LeftDiff   = $Diff | where {$_.SideIndicator -eq "<="} | select RelativePath,Hash
    $RightDiff   = $Diff | where {$_.SideIndicator -eq "=>"} | select RelativePath,Hash
    if($ExportSummary) {
      $ExportSummary = ResolvePath path/to/summary/dir $ExportSummary
      MakeDirP $ExportSummary
      $SummaryPath = Join-Path $ExportSummary summary.txt
      $LeftCsvPath = Join-Path $ExportSummary left.csv
      $RightCsvPath = Join-Path $ExportSummary right.csv

      $LeftMeasure = $LeftDiff | measure
      $RightMeasure = $RightDiff | measure

      "== DIFF SUMMARY ==" > $SummaryPath
      "" >> $SummaryPath
      "-- DIRECTORIES --" >> $SummaryPath
      "`tLEFT -> $LeftPath" >> $SummaryPath
      "`tRIGHT -> $RightPath" >> $SummaryPath
      "" >> $SummaryPath
      "-- DIFF COUNT --" >> $SummaryPath
      "`tLEFT -> $($LeftMeasure.Count)" >> $SummaryPath
      "`tRIGHT -> $($RightMeasure.Count)" >> $SummaryPath
      "" >> $SummaryPath
      $Diff | Format-Table >> $SummaryPath

      $LeftDiff | Export-Csv $LeftCsvPath -f
      $RightDiff | Export-Csv $RightCsvPath -f
    }
    if(!$NoLeft -and !$NoRight) {
      $Diff
    }
    elseif(!$NoLeft -and $NoRight) {
      $LeftDiff
    }
    elseif(!$NoRight -and $NoLeft) {
      $RightDiff
    }
    else {
      Print -w "Both -NoRight and -NoLeft were passed.  Results have been omitted."
    }
  }
  END {
    SafeExit
  }
}

### END EXPORTED FUNCTIONS ###
