Remove-Module -Name utils
Import-Module .\scripts\utils.psm1 -Force

az login

[string] $subscription = 'sopi-mpn-02'
[string] $org = 'https://dev.azure.com/softwarepioniere2'
[string] $project = 'sopi-devops-master'
[string] $resourceGroupName = 'rg-sopi2-devops-master'
[string] $storageAccountName = 'sopi2devopsmaster'
[string] $keyVaultName = 'kv-sopi2-devops-master2'
[string] $principalName = "sopi2-devops-master"

$account = setSubscription -subscription $subscription
$subscriptionId = $account.id
Write-Host "SubscriptionId: $subscriptionId"
$rg = createResourceGroup -resourceGroupName $resourceGroupName
$sta = createStorageAccount -resourceGroupName $resourceGroupName -storageAccountName $storageAccountName -containerName 'terraform'
$kv = createKeyVault -resourceGroupName $resourceGroupName -keyVaultName $keyVaultName

$userName = $account.user.name
Write-Host "UserName: $userName"
createKeyVaultPolicyUpn -resourceGroupName $resourceGroupName -keyVaultName $keyVaultName -objectid $userName

# devops pat
'xx' | Out-File "secret-azure-devops-pat.txt"
$pat = Get-Content -Path "secret-azure-devops-pat.txt"
saveKeyVaultSecret -keyVaultName $keyVaultName -secret 'Azure-DevOps-PAT' -value $pat

# create project
$proj = createDevOpsProject -org $org -project $project

# clone the new project
$cloneUrl = (az repos show --org $org --project $project --repo  $project --query 'remoteUrl' --output tsv)
Write-Host "CloneUrl: $cloneUrl"
git clone $cloneUrl ..\$storageAccountName


# master service principalname
$sp = createServicePrincipal -principalName $principalName -subscriptionId $subscriptionId
createKeyVaultPolicySpn -resourceGroupName $resourceGroupName -keyVaultName $keyVaultName -objectid $($sp.appId) -getlistset
Write-Host $sp
saveServicePrincipalInKeyVault -keyVaultName $keyVaultName -sp $sp
