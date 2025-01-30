# Introduction PSRule for Azure

About PSRule and PSRule for Azure in relation to Well Architected Framework.

Reading: 

 - https://www.linkedin.com/pulse/navigating-azure-frameworks-well-architected-waf-vs-caf-ranapurwala-jafcf

 - https://rios.engineer/azure-spring-clean-azure-best-practice-for-bicep-with-psrule/

## What and how to install

```
Install-Module -Name PSRule
Install-Module -Name PSRule.Rules.Azure
Install-Module -Name PSRule.Rules.CAF
Install-Module -Name PowerShell-yaml
```

## How to run

```
$workingFolder = "C:\Workspace\Clients\FellowMind\demo-psrule\infrastructure"
Assert-PSRule -Path $workingFolder\tests\psrule\.ps-rule\ -InputPath $workingFolder -Option $workingFolder\tests\psrule\ps-rule.dev.yaml
```

## Complete command line

Use our own test code:

```
 .\tests\psrule\PSRulePreDeployment.ps1 .\
```

## Example of Raw and Compliance Solution

Hands on demo

## Using it with Azure DevOps Pipeline

```
- task: PowerShell@2
displayName: PSRule
inputs:
    targetType: filePath
    filePath: "$(System.DefaultWorkingDirectory)/${{ variables.projectFolder }}/tests/psrule/PSRulePreDeployment.ps1"
    errorActionPreference: stop
    failOnStderr: true
continueOnError: false

- task: PublishTestResults@2
displayName: Publish Test Results
inputs:
    testResultsFormat: "NUnit"
    testResultsFiles: "**/TEST-*.xml"
```

### Test Results

The test results of the PSRule are published in the pipeline for documentation and code quality.

## Environment configuration

By using environment, it is possible to have different ps-rule configuration for different environment.

## Security by Design and ISO27001

By following PSRule for Azure you validate a lot of controls that matters for ISO27001 compliance. Which mean it is easier to document ISO27001 compliance for customer if required.


Reference:

 - [PSRule](https://microsoft.github.io/PSRule/stable//)
 - [PSRule for Azure](https://azure.github.io/PSRule.Rules.Azure/)
 - [PSRule projects](https://microsoft.github.io/PSRule/v2/related-projects/)
 - [PSRule CAF](https://github.com/microsoft/PSRule.Rules.CAF)
 - [PSRule features](https://azure.github.io/PSRule.Rules.Azure/features/)