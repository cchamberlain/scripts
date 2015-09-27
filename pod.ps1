[CmdletBinding()]
param (
  [parameter(HelpMessage="Enable tracing messages.")]
  [switch]$POD_TRACE,

  [parameter(HelpMessage="Enable debugging messages.")]
  [switch]$POD_DEBUG=$POD_TRACE,

  [parameter(HelpMessage="Enable logging messages.")]
  [switch]$POD_LOG=$POD_DEBUG,

  [parameter(HelpMessage="Stores the execution working directory.")]
  [string]$ExecutionDirectory=$PWD,

  [parameter(Position=0,HelpMessage="Enter a file path to process or execute from pod root.")]
  [string]$Deploy=$PWD,

  [parameter(HelpMessage="Compare two directories recursively for differences.")]
  [alias("d")]
  [string[]]$Diff,

  [parameter(HelpMessage="Omit output for results from left side (for diffs).")]
  [switch]$NoLeft,

  [parameter(HelpMessage="Omit output for results from right side (for diffs).")]
  [switch]$NoRight,

  [parameter(HelpMessage="Rollback a pod delta archive.")]
  [alias("r")]
  [string]$Rollback,

  [parameter(HelpMessage="Generate a deployment pod at specified path.")]
  [alias("g")]
  [switch]$Generate,

  [parameter(HelpMessage="Path to podfile configuration to use.")]
  [alias("c")]
  [string]$PodfilePath=(Join-Path $PWD podfile.json),

  [parameter(HelpMessage="Export a summary to path.")]
  [alias("s")]
  [string]$ExportSummary,

  [parameter(HelpMessage="Machine / PowerShell parsable output.")]
  [alias("p")]
  [switch]$Porcelain
)

### DEFINITIONS ###
$POD_SEMVER_MAJOR = 0
$POD_SEMVER_MINOR = 3
$POD_SEMVER_PATCH = 0
$POD_VERSION  = "$POD_SEMVER_MAJOR.$POD_SEMVER_MINOR.$POD_SEMVER_PATCH"
$POD_USAGE    = "usage: pod [-d|-Diff path/to/left,path/to/right [-NoLeft|-NoRight]] [-g|-Generate] [-c|-PodfilePath path/to/podfile] [-p|-Porcelain] [path/to/pod]"
$POD_STAMP    = "$(get-date -f yyyyMMdd\THHmmss)"
### END DEFINITIONS ###

###############################################################################
# PODFILE FORMAT
# DEFAULT: PODFILE IN ROOT OF POD PACKAGE
#
# { "targets":  [ { "name":     "SERVER_ONE"
#                 , "root":     "path/to/server/one/root"
#                 , "archive":  "path/to/archive/one/root"
#                 }
#               , { "name":     "SERVER_TWO"
#                 , "root":     "/abs/path/to/server/root/two/root"
#                 , "archive":  "//unc-server/path/to/archive/two/root"
#                 }
#               ]
# }
###############################################################################


### FUNCTION DEFINITIONS ###

# PRINTS DEBUG INFORMATION IF POD_LOG=$TRUE or POD_DEBUG=$TRUE or POD_TRACE=$TRUE #
function Log {
  [CmdletBinding()]
  param (
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
    if($POD_LOG -or $POD_DEBUG -or $POD_TRACE) {
      foreach($Message in $Messages) {
        if($POD_TRACE -and $TraceFlag) {
          Write-Host "|TRACE|$Message|" -ForegroundColor "Magenta"
        }
        elseif($POD_DEBUG -and $DebugFlag) {
          Write-Host "|DEBUG|$Message|" -ForegroundColor "Magenta" -BackgroundColor "Black"
        }
        elseif($POD_LOG -and $LogFlag) {
          Write-Host "|LOG|$Message|" -ForegroundColor "Black" -BackgroundColor "Magenta"
        }
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
  Exit
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
  Write-Host "$POD_STAMP" -NoNewLine -ForegroundColor "Yellow"
  Write-Host "] ==" -ForegroundColor "Cyan"
  Write-Host ""
}

# PRINTS USAGE INFORMATION FOR APP #
function PrintUsage {
  [CmdletBinding()]
  param (
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
      Write-Host "`t$POD_USAGE"
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

function RecursiveDiff {
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
}

function ResolvePodfile {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to podfile.json.")]
    [alias("p")]
    [string]$PodfilePath
  )
  PROCESS {
    ResolvePath path/to/podfile $PodfilePath
  }
}

function RequirePodfile {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$TRUE,Position=0,HelpMessage="Path to podfile.json.")]
    [alias("p")]
    [string]$PodfilePath
  )
  PROCESS {
    RequirePath path/to/podfile $PodfilePath leaf
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
    $PodfilePath = RequirePodfile $PodfilePath
    $PodfileJson = cat $PodfilePath | Out-String
    ConvertFrom-Json $PodfileJson
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
    ConvertTo-Json $PodfileJson
    $PodfilePath = RequirePodfile $PodfilePath
    $PodfileJson = cat $PodfilePath | Out-String

  }
}

function NewPodFile {
  [CmdletBinding(
    SupportsShouldProcess=$TRUE,
    ConfirmImpact="High"
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
{ "targets":  [
                { "name": "$Name"
                , "root": "$ServerRoot"
                , "archive": "$ArchiveRoot"
                }
              ]
}
"@ -replace "\\","\\\\"
    $PodfileJson >$PodfilePath
    Print -s "Podfile successfully written to $PodfilePath"
  }
}

### END FUNCTION DEFINITIONS ###

$PodfilePath = ResolvePodfile $PodfilePath

Log "START" -d
PrintHeader

### DIFF ###

if($Diff) {
  Print "== DIFF MODE ==" -s -a 1
  if($Diff.length -ne 2) {
    Print -x "Recursive diff requires passing exactly 2 path parameters separated by comma, you passed $($Diff.length)." -f
  }
  Print "Recursively diffing $($Diff[0]) and $($Diff[1])..." -a 1
  RecursiveDiff $Diff[0] $Diff[1]
  SafeExit
}

### END DIFF ###

### ROLLBACK ###

if($Rollback) {
  Print "== ROLLBACK MODE ==" -s -a 1
  Print -x "Rollback mode is not yet implemented." -f
  SafeExit
}

### END ROLLBACK ###

### GENERATE ###

if($Generate) {
  Print "== GENERATE MODE ==" -s -a 1
  if(!(Test-Path $PodfilePath -PathType leaf)) {
    Print -w "No podfile exists at $PodfilePath, creating one..."
    NewPodFile $PodfilePath
  }
  ReadPodfile $PodfilePath

  SafeExit
}

### END GENERATE ###

### DEPLOY ###

Print "== DEPLOYMENT MODE ==" -s -a 1

Log "CONFIGURE BASIC PATHS" -d
$POD_ROOT         = RequirePath /path/to/pod $Deploy container
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
$ETC_ARCHIVE_PATH = RequirePath pod/etc/archive $ETC_ARCHIVE_PATH leaf
$ETC_TARGET_PATH  = RequirePath pod/etc/target $ETC_TARGET_PATH leaf

Log "FILES_ROOT`t`t-> $FILES_ROOT"
Log "ETC_ROOT`t`t-> $ETC_ROOT"
Log "ETC_DELETE_PATH`t-> $ETC_DELETE_PATH"
Log "ETC_ARCHIVE_PATH`t-> $ETC_ARCHIVE_PATH"
Log "ETC_TARGET_PATH`t-> $ETC_TARGET_PATH"

Log "SET WORKING DIRECTORY TO POD ROOT" -d
SetWorkDir path/to/pod $POD_ROOT

Log "READ ETC CONFIGURATIONS" -d
$DELETE_PATHS = cat $ETC_DELETE_PATH | ? {$_}
$TARGET_ROOT  = cat $ETC_TARGET_PATH | ? {ResolvePath pod/etc/target $_ container}
$ARCHIVE_PARENT_ROOT = cat $ETC_ARCHIVE_PATH | ? {ResolvePath pod/etc/archive $_}
$ARCHIVE_ROOT =  Join-Path $ARCHIVE_PARENT_ROOT "archive-$POD_STAMP"

Log "ETC RAW CONFIGURATIONS READ" -d
Log "DELETE_PATHS`t-> $DELETE_PATHS" -d
Log "TARGET_ROOT`t-> $TARGET_ROOT" -d
Log "ARCHIVE_ROOT`t-> $ARCHIVE_ROOT" -d

Log "VALIDATE PATHS SPECIFIED IN ETC FILES" -d
#$TARGET_ROOT  = RequirePath pod/etc/target $TARGET_ROOT container
$TARGET_ROOT  = ResolvePath pod/etc/target $TARGET_ROOT container
$ARCHIVE_ROOT = ResolvePath pod/etc/archive $ARCHIVE_ROOT
Log "TARGET_ROOT`t-> $TARGET_ROOT"
Log "ARCHIVE_ROOT`t-> $ARCHIVE_ROOT"

Log "JOIN ARCHIVE PATHS" -d
$ARCHIVE_DELETED_ROOT   = Join-Path $ARCHIVE_ROOT D
$ARCHIVE_MODIFIED_ROOT  = Join-Path $ARCHIVE_ROOT M
$ARCHIVE_ADDED_PATH     = Join-Path $ARCHIVE_ROOT added

Log "VALIDATE ARCHIVE PATHS" -d
$ARCHIVE_DELETED_ROOT   = ResolvePath pod/etc/archive $ARCHIVE_DELETED_ROOT
$ARCHIVE_MODIFIED_ROOT  = ResolvePath pod/etc/archive $ARCHIVE_MODIFIED_ROOT
$ARCHIVE_ADDED_PATH     = ResolvePath pod/etc/archive $ARCHIVE_ADDED_PATH

Log "ARCHIVE_DELETED_ROOT`t-> $ARCHIVE_DELETED_ROOT" -d
Log "ARCHIVE_MODIFIED_ROOT`t-> $ARCHIVE_MODIFIED_ROOT" -d
Log "ARCHIVE_ADDED_PATH`t-> $ARCHIVE_ADDED_PATH" -d

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

SafeExit
