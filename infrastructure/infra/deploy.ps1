[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [String]$environment,

    [Parameter(Mandatory = $false)]
    [String]$location,

    [Parameter(Mandatory = $false)]
    [String]$tenantId,

    [Parameter(Mandatory = $false)]
    [String]$subscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$resourceGroupName,

    [Parameter(Mandatory = $false)]
    [String]$TemplateFilePath,

    [Parameter(Mandatory = $false)]
    [bool]$Debugging = $false,

    [Parameter(Mandatory = $false)]
    [bool]$BicepParam = $true

)

# Set Az Context
if (![string]::IsNullOrEmpty($tenantId) -And ![string]::IsNullOrEmpty($subscriptionId)) {
    Write-Verbose "Setting Azure Context to subscription: $subscriptionId in tenant: $tenantId"
    Set-AzContext -Tenant $tenantId -Subscription $subscriptionId -ErrorAction "Stop" | Out-Null
}

$TemplateFileName = "main.bicep"
if ($BicepParam) {
    $ParameterFileName = "main.$($environment.ToLower()).bicepparam"
}
else {
    $ParameterFileName = "main.$($environment.ToLower()).parameters.json"
}

$TemplateFile = "$TemplateFilePath\$TemplateFileName"
$TemplateParameterFile = "$TemplateFilePath\$ParameterFileName"

Write-Output "----------------------------------"
Write-Output "Template File Information"
Write-Output $TemplateFile
Write-Output $TemplateParameterFile
Write-Output "----------------------------------"


# Deploying
Write-Verbose "Deploying infrastructure"
$splat = @{
    Name                  = "Infra-omilon-coworker-$($environment)-$((Get-Date).Ticks)"
    TemplateFile          = $TemplateFile
    TemplateParameterFile = $TemplateParameterFile
    ErrorAction           = "stop"
    Location              = $location
    Verbose               = $true
    Debug                 = $Debugging
}
if ($resourceGroupName) {
    $splat.Add("ResourceGroupName", $resourceGroupName)
    New-AzResourceGroupDeployment @splat
}
else {
    New-AzDeployment @splat
}