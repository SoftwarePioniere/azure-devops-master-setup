Write-Host "Imported Utils!!!"

function resetError() { $global:LASTEXITCODE = 0 }

function checkError() { if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } }

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
            --certificate-permissions create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers, update `
            --key-permissions backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify, wrapKey `
            --secret-permissions backup, delete, get, list, purge, recover, restore, set `
            --storage-permissions backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas, update

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
            --certificate-permissions get, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers, update `
            --key-permissions backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify, wrapKey `
            --secret-permissions backup, delete, get, list, purge, recover, restore, set `
            --storage-permissions backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas, update

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
    param($keyVaultName, $sp, $acc)
    
    saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($sp.name)-id" -value $($sp.appId)
    saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($sp.name)-password" -value $($sp.password)
    saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($sp.name)-tenant-id" -value $($sp.tenant)
    saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($sp.name)-subscription-name" -value $($acc.name)
    saveKeyVaultSecret -keyVaultName $keyVaultName -secret "sp-$($sp.name)-subscription-id" -value $($acc.id)
}

function createServicePrincipal() {
    param($principalName, $subscriptionId)
    resetError

    # create rbac sp   
    Write-Host $principalName
    # $tmp = (az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscriptionId" --name $principalName --years 10)
    $tmp = (az ad sp create-for-rbac --skip-assignment --name $principalName --years 10)
    checkError
    
    $guid = (New-Guid).Guid
    Write-Host $guid
    $tmp = az ad sp credential reset --name $principalName --password $guid
    checkError

    Write-Host $tmp
    $principal = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
   
    # save to local file
    $principal | ConvertTo-Json | Out-File "secret-sp-$principalName.json"
    $principal | ConvertTo-Json | Write-Host

    return $principal
}


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