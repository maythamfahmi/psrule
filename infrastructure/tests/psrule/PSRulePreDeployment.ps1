<#
.SYNOPSIS
Run PSRule tests based of the source code.
.PARAMETER TestPath
Path to the PSRule tests.
Defaults to the root folder in the the repository.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]$TestPath = "$PSScriptRoot/../",
    [Parameter(Mandatory=$false)]
    [ValidateSet("", "dev", "qatest", "prod")]
    [string]$Environment = "dev"
)

# Retrieve required modules
$desiredModules = @(
    @{
        Name    = 'PSRule'
        Version = 'Latest'
    },
    @{
        Name    = 'PSRule.Rules.Azure'
        Version = 'Latest'
    },
    @{
        Name    = 'PSRule.Rules.CAF'
        Version = 'Latest'
    }
    @{
        Name    = 'PowerShell-yaml'
        Version = 'Latest'
    }
)
foreach ($module in $desiredModules) {
    # Get installed versions of the module
    $currentVersionsInstalled = Get-Module -ListAvailable $module.Name

    # Find the desired version and check if it is installed
    if ($module.Version -eq 'Latest') {
        $AvailableVersions = Find-Module -Name $module.Name
        $LatestModuleAvailable = $AvailableVersions[0]
        $desiredVersion = $LatestModuleAvailable.Version
        $desiredVersionIsInstalled = $LatestModuleAvailable.Version -in $currentVersionsInstalled.Version
    }
    else {
        $desiredVersion = $module.Version
        $desiredVersionIsInstalled = $module.Version -in $currentVersionsInstalled.Version
    }

    # Install the module version if it is not installed
    if (!$desiredVersionIsInstalled) {
        $splat = @{
            # Skipping publisher check as it has been changed in versions for PSRule.Rules.Azure
            Name               = $module.Name
            RequiredVersion    = $desiredVersion
            Force              = $true
            ErrorAction        = 'Stop'
            SkipPublisherCheck = $true
            Repository         = 'PSGallery'
            Scope              = 'CurrentUser'
        }
        Install-Module @splat
    }
}

# Perform tests
$splat = @{
    ErrorAction = 'stop'
    Force       = $true
}
$env = $Environment -eq "" ? "" : ".$($Environment)"
$RootPath = $PSScriptRoot
$rulesFolder = (Get-Item "$RootPath/../psrule/.ps-rule/" @splat)
$FolderToTest = (Get-Item $TestPath @splat)
$optionsFile = (Get-Item "$RootPath/../psrule/ps-rule$($env).yaml" @splat)

# Save current location and change to the test folder
Push-Location $TestPath -StackName 'cwd'

$splat = @{
    InputPath = $FolderToTest.FullName
    Option    = $optionsFile.FullName
    Path      = $rulesFolder.FullName
}
$splat

Assert-PSRule @splat

# Restore location to the original
Pop-Location -StackName 'cwd'
