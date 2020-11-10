Write-Host "imported azdo_utils !!!"

function installDevOpsExtensions() {
  param($org)

  # install terraform extension in azuredevops
  az devops extension install `
  --extension-id 'custom-terraform-tasks' `
  --publisher-id 'ms-devlabs' `
  --organization $org    

  az devops extension install `
  --extension-id 'printAllVariables' `
  --publisher-id 'ShaykiAbramczyk' `
  --organization $org    

}


function createDevOpsProject() {
  param($org, $project)
  resetError

  Write-Host "az devops project create $project"
  # create azure devops project
  $tmp = az devops project create `
      --name $project `
      --visibility private `
      --organization $org

  checkError

  $x = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  $x | ConvertTo-Json | Write-Host

  return $x

}

function createAzureServiceEndpoint() {
  param($org, $project, $principal, $account, $prefix, $subscription)
  
  [string] $serviceConnectionName = "az-$prefix-$subscription"

  # store client secret fot automation
  $env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$principal.password
  # create service connection in azure devops
  az devops service-endpoint azurerm create `
      --azure-rm-service-principal-id $principal.appId `
      --azure-rm-subscription-id $account.id `
      --azure-rm-subscription-name $account.name `
      --azure-rm-tenant-id $account.tenantId `
      --name $serviceConnectionName `
      --organization $org `
      --project $project


}

function createGithubServiceEndpoint() {
  param($org, $project, $pat, $url, $name)

  $env:AZURE_DEVOPS_EXT_GITHUB_PAT=$pat

  # connect github
  az devops service-endpoint github create `
      --github-url $url `
      --name $name `
      --organization $org `
      --project $project

}


function createDevOpsArmVariableGroup() {
  # store username and password in azure devops variable group

  param($org, $project, $principal, $account, $prefix, $subscription)
      
  $vargroupName = "$subscription-arm"
  Write-Host "vargroupName: $vargroupName"

  $tmp = az pipelines variable-group create `
      --name $vargroupName `
      --authorize true `
      --description 'Variables for Azure Resource Manager Service connection' `
      --organization $org `
      --project $project `
      --variables "ARM_SUBSCRIPTION=$subscription" `
      --authorize true
  Write-Host $tmp

  $groupId = (az pipelines variable-group list `
          --group-name $vargroupName `
          --organization $org `
          --project $project `
          --query '[0].id' `
          --output tsv)
  Write-Host $groupId


  $tmp = az pipelines variable-group variable create `
      --group-id $groupId `
      --name ARM_SERVICE_CONNECTION `
      --value $principal.name `
      --organization $org `
      --project $project
  Write-Host $tmp

  $tmp = az pipelines variable-group variable create `
      --group-id $groupId `
      --name ARM_CLIENT_ID `
      --value $principal.appId `
      --organization $org `
      --project $project
  Write-Host $tmp    

  $tmp = az pipelines variable-group variable create `
      --group-id $groupId `
      --name ARM_TENANT_ID `
      --value $principal.tenant `
      --organization $org `
      --project $project
  Write-Host $tmp

  $tmp = az pipelines variable-group variable create `
      --group-id $groupId `
      --name ARM_SUBSCRIPTION_ID `
      --value $account.id `
      --organization $org `
      --project $project
  Write-Host $tmp

  $tmp = az pipelines variable-group variable create `
      --group-id $groupId `
      --name ARM_CLIENT_SECRET `
      --value $principal.password `
      --organization $org `
      --project $project
  Write-Host $tmp        
  # --secret true `
  
  return $groupId
}


function createEnvVariableGroup() {

  param($org, $project, $envx, $appname)
      
  $vargroupName = "$appname-$envx"
  Write-Host "vargroupName: $vargroupName"

  $tmp = az pipelines variable-group create `
      --name $vargroupName `
      --authorize true `
      --description 'Variables for App Environment' `
      --organization $org `
      --project $project `
      --variables "EnvironmentShortcut=$envx" `
      --authorize true 
  Write-Host $tmp

  $groupId = (az pipelines variable-group list `
          --group-name $vargroupName `
          --organization $org `
          --project $project `
          --query '[0].id' `
          --output tsv)

  return $groupId

}

function saveVarInGroup() {
  param($org, $project, $groupId, $name, $value, $secret = 'false')

  $tmp = (az pipelines variable-group variable list --group-id $groupId --organization $org --project $project)
  Write-Host $tmp
  
  $xx = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  $a = $xx[$name]
  
  $isnull = $false
  Write-Host "entry val: $a"

  # $isnull ??= $true
  Write-Host $a ?? "Is null? True!"
  Write-Host "Isnull: $isnull"
  

  # if ($isnull) {

      $tmp = az pipelines variable-group variable update `
      --group-id $groupId `
      --name $name `
      --value `"$value`" `
      --organization $org `
      --project $project `
      --secret $secret

      Write-Host $tmp

  # } else {

      $tmp = az pipelines variable-group variable create `
      --group-id $groupId `
      --name $name `
      --value `"$value`" `
      --organization $org `
      --project $project `
      --secret $secret

      Write-Host $tmp

  # }    
}
