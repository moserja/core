param (
    [switch] $install,
    [switch] $start,
    [switch] $restart,
    [switch] $stop,
    [switch] $update,
    [switch] $updatedb,
    [switch] $updateself,
    [string] $output = ""
)

$year = (Get-Date).year

Write-Host @'
 _     _ _                         _            
| |__ (_) |___      ____ _ _ __ __| | ___ _ __  
| '_ \| | __\ \ /\ / / _` | '__/ _` |/ _ \ '_ \ 
| |_) | | |_ \ V  V / (_| | | | (_| |  __/ | | |
|_.__/|_|\__| \_/\_/ \__,_|_|  \__,_|\___|_| |_|
'@

Write-Host "
Open source password management solutions
Copyright 2015-${year}, 8bit Solutions LLC
https://bitwarden.com, https://github.com/bitwarden

===================================================
"

docker --version
docker-compose --version

echo ""

# Setup

$scriptPath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
if($output -eq "") {
    $output="${dir}\bwdata"
}

$scriptsDir = "${output}\scripts"
$githubBaseUrl = "https://raw.githubusercontent.com/bitwarden/core/master"
$coreVersion = "1.14.1"
$webVersion = "1.20.1"

# Functions

function Download-Self {
    Invoke-RestMethod -OutFile $scriptPath -Uri "${githubBaseUrl}/scripts/bitwarden.ps1"
}

function Download-Install {
    if(!(Test-Path -Path $scriptsDir)) {
        New-Item -ItemType directory -Path $scriptsDir | Out-Null
    }
    Invoke-RestMethod -OutFile $scriptsDir\install.ps1 ` -Uri "${githubBaseUrl}/scripts/install.ps1"
}

function Download-Run-File {
    if(!(Test-Path -Path $scriptsDir)) {
        New-Item -ItemType directory -Path $scriptsDir | Out-Null
    }
    Invoke-RestMethod -OutFile $scriptsDir\run.ps1 -Uri "${githubBaseUrl}/scripts/run.ps1"
}

function Check-Output-Dir-Exists {
    if(!(Test-Path -Path $output)) {
        throw "Cannot find a bitwarden installation at $output."
    }
}

function Check-Output-Dir-Not-Exists {
    if(Test-Path -Path $output) {
        throw "Looks like bitwarden is already installed at $output."
    }
}

# Commands

if($install) {
    Check-Output-Dir-Not-Exists
    New-Item -ItemType directory -Path $output | Out-Null
    Download-Install
    Download-Run-File
    Invoke-Expression "$scriptsDir\install.ps1 -outputDir $output -coreVersion $coreVersion -webVersion $webVersion"
}
elseif($start -Or $restart) {
    Check-Output-Dir-Exists
    Invoke-Expression "$scriptsDir\run.ps1 -restart -outputDir $output -coreVersion $coreVersion -webVersion $webVersion"
}
elseif($update) {
    Check-Output-Dir-Exists
    Download-Run-File
    Invoke-Expression "$scriptsDir\run.ps1 -update -outputDir $output -coreVersion $coreVersion -webVersion $webVersion"
}
elseif($updatedb) {
    Check-Output-Dir-Exists
    Invoke-Expression "$scriptsDir\run.ps1 -updatedb -outputDir $output -coreVersion $coreVersion -webVersion $webVersion"
}
elseif($stop) {
    Check-Output-Dir-Exists
    Invoke-Expression "$scriptsDir\run.ps1 -stop -outputDir $output -coreVersion $coreVersion -webVersion $webVersion"
}
elseif($updateself) {
    Download-Self
    echo "Updated self."
}
else {
    echo "No command found."
}
