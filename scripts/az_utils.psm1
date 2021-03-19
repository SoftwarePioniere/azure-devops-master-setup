Write-Host "imported az_utils!!!"

function setSubscription() {
  param($subscription)
  resetError

  $tmp =  (az account set --subscription $subscription)
  checkError

  $tmp = (az account show)
  checkError

  $account = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))

  # save to local file
  $account | ConvertTo-Json | Out-File "secret-account-$subscription.json"
  $account | ConvertTo-Json | Write-Host
  return $account
}


function createResourceGroup() {
  param($resourceGroupName)
  resetError

  $location = 'westeurope'
  Write-Host "az group create --name $resourceGroupName --location $location"
  $tmp = az group create --name $resourceGroupName --location $location
  checkError

  $rg = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  $rg | ConvertTo-Json | Write-Host

  return $rg
}


function createStorageAccount() {
  param($resourceGroupName, $storageAccountName, $containerName)
  resetError

  Write-Host "az storage account create --resource-group $resourceGroupName --name $storageAccountName"
  $tmp = az storage account create --resource-group $resourceGroupName `
      --name $storageAccountName `
      --sku Standard_LRS `
      --encryption-services blob
  checkError
  
  $sta = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))

  $storageAccountKey = $(az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query [0].value -o tsv)
  checkError

  Write-Host "az storage container create --name $containerName"
  $tmp = az storage container create `
      --name $containerName `
      --account-name $storageAccountName `
      --account-key $storageAccountKey
  checkError

  $cont = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))

  $ret = @{ 
      StorageAccount = $sta
      Container = $cont
  }
  $ret | ConvertTo-Json | Write-Host
  $ret | ConvertTo-Json | Out-File "secret-storageaccount-$storageAccountName.json"

  return $ret
}

function createKeyVault() {
  param($resourceGroupName, $keyVaultName)
  resetError

  Write-Host "az keyvault create: $keyVaultName"
  $tmp = az keyvault create `
      --name $keyVaultName `
      --resource-group $resourceGroupName `
      --enabled-for-deployment true `
      --enabled-for-template-deployment true `
      --enable-soft-delete false
  checkError

  $kv = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  $kv | ConvertTo-Json | Write-Host
  $kv | ConvertTo-Json | Out-File "secret-keyvault-$keyVaultName.json"

  return $kv
}


function createKeyVaultPolicyUpn() {
  param($resourceGroupName, $keyVaultName, $objectid, [switch] $getlistset)
  resetError

  if ($getlistset) {
      Write-Host "az keyvault set-policy: $keyVaultName $objectid getlistset"
      $tmp = az keyvault set-policy `
          --name $keyVaultName `
          --resource-group $resourceGroupName `
          --upn $objectid `
          --secret-permissions get list set `
          --certificate-permissions get list `
          --key-permissions get list   
  }
  else {

      Write-Host "az keyvault set-policy: $keyVaultName $objectid ALL"
      $tmp = az keyvault set-policy `
          --name $keyVaultName `
          --resource-group $resourceGroupName `
          --upn $objectid `
          --secret-permissions delete get list purge recover restore set `
          --certificate-permissions backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers purge recover restore setissuers update `
          --key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey `
          --storage-permissions backup delete deletesas get getsas list listsas purge recover regeneratekey restore set setsas update

  }
  checkError

  $kv = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  $kv | ConvertTo-Json | Write-Host

  return $kv
}


function createKeyVaultPolicySpn() {
  param($resourceGroupName, $keyVaultName, $objectid, [switch] $getlistset)
  resetError

  if ($getlistset) {
      Write-Host "az keyvault set-policy: $keyVaultName $objectid getlistset"
      $tmp = az keyvault set-policy `
          --name $keyVaultName `
          --resource-group $resourceGroupName `
          --spn $objectid `
          --secret-permissions get list set `
          --certificate-permissions get list `
          --key-permissions get list 
  }
  else {

      Write-Host "az keyvault set-policy: $keyVaultName $objectid ALL"
      $tmp = az keyvault set-policy `
          --name $keyVaultName `
          --resource-group $resourceGroupName `
          --spn $objectid `
          --secret-permissions delete get list purge recover restore set `
          --certificate-permissions backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers purge recover restore setissuers update `
          --key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey `
          --storage-permissions backup delete deletesas get getsas list listsas purge recover regeneratekey restore set setsas update

  }
  checkError

  $kv = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  $kv | ConvertTo-Json | Write-Host

  return $kv
}

function createKeyVaultPolicy() {
  param($resourceGroupName, $keyVaultName, $objectid, [switch] $getlistset)
  resetError

  if ($getlistset) {
      Write-Host "az keyvault set-policy: $keyVaultName $objectid getlistset"
      $tmp = az keyvault set-policy `
          --name $keyVaultName `
          --resource-group $resourceGroupName `
          --object-id $objectid `
          --secret-permissions get list set    
  }
  
  checkError

  $kv = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  $kv | ConvertTo-Json | Write-Host

  return $kv
}

function saveKeyVaultSecret() {
  param($keyVaultName, $secret, $value)
  resetError

  Write-Host "az keyvault secret set: $keyVaultName $secret"
  $tmp = az keyvault secret set `
      --vault-name $keyVaultName `
      --name $secret `
      --value $value

  checkError

  $kv = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  $kv | ConvertTo-Json | Write-Host

  return $kv
}

function saveServicePrincipalInKeyVault() {
  param($keyVaultName, $sp, $acc, $keyvaultprefix)
  
  Write-Host "saveServicePrincipalInKeyVault: $keyVaultName | $keyvaultprefix"

  # $sp.name
  saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($keyvaultprefix)-id" -value $($sp.appId)
  saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($keyvaultprefix)-password" -value $($sp.password)
  saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($keyvaultprefix)-tenant-id" -value $($sp.tenant)
  saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($keyvaultprefix)-subscription-name" -value $($acc.name)
  saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($keyvaultprefix)-subscription-id" -value $($acc.id)
}


function createSubPrincipal() {
  param($subscription, $principalName)
  Write-Host "createSubPrincipal: $subscription | $principalName"
  resetError

  $sub = setSubscription -subscription $subscription
  checkError

  $sp = createServicePrincipal -principalName $principalName
  checkError

  assignSpSubscriptionRole -sub $sub -sp $sp -role 'Contributor'
  checkError

  assignSpSubscriptionRole -sub $sub -sp $sp -role 'User Access Administrator'
  checkError
}

function createServicePrincipal() {
  param($principalName)
  resetError

  # create rbac sp   
  Write-Host $principalName
  $tmp = (az ad sp create-for-rbac --skip-assignment --name $principalName --years 10)
  checkError
  
  $guid = (New-Guid).Guid
  Write-Host $guid
  $tmp = az ad sp credential reset --name $principalName --password $guid --years 10
  checkError

  Write-Host $tmp
  $principal = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
 
  # save to local file
  $principal | ConvertTo-Json | Out-File "secret-sp-$principalName.json"
  $principal | ConvertTo-Json | Write-Host

  return $principal
}



function writeServicePrincipalToKeyVault() {
  param($keyVaultName, $accountFile, $spFile, $keyvaultprefix)
  resetError

  $p = 'secret-sp-' + $spFile + '.json'
  $tmp = Get-Content -Path $p
  checkError
  $sp = ConvertFrom-Json -InputObject ([System.string]::Concat($tmp))
  checkError

  $sp | ConvertTo-Json | Write-Host

  $p = 'secret-account-' + $accountFile + '.json'
  $tmp = Get-Content -Path $p
  checkError
  $acc = ConvertFrom-Json -InputObject ([System.string]::Concat($tmp))
  checkError

  $acc | ConvertTo-Json | Write-Host

  if (!$keyvaultprefix) {
    Write-Host "setting default prefix to sp.name"
    $keyvaultprefix = $sp.name
  }

  saveServicePrincipalInKeyVault -keyVaultName $keyVaultName -sp $sp -acc $acc -keyvaultprefix $keyvaultprefix

}

function assignSpSubscriptionRole() {
  param($sub, $sp, $role) 
  resetError

  $scope = "/subscriptions/$($sub.id)"

  "   az role assignment create --assignee $sp.appId --role 'Contributor' --scope $scope" | Write-Host
  az role assignment create --assignee $sp.appId --role 'Contributor' --scope $scope
  checkError
}



function assignSpSubscriptionOwner() {
  param($sub, $sp) 
  resetError
  
  "   az role assignment create --assignee $sp.appId --role 'Owner' --subscription $sub" | Write-Host
  az role assignment create --assignee $sp.appId --role 'Owner' --subscription $sub
  checkError
}


function getKeyVaultSecret() {
  param($keyVaultName, $secret)
  resetError

  Write-Host "  az keyvault secret show: $keyVaultName $secret"
  $tmp = az keyvault secret show `
    --vault-name $keyVaultName `
    --name $secret -o tsv --query 'value'


  return $tmp
}