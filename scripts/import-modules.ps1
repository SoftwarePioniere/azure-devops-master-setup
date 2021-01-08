Write-Host "PSScriptRoot: $PSScriptRoot"

if (Get-Module -Name az_utils) {
  Remove-Module -Name az_utils
}
Import-Module "$PSScriptRoot\az_utils.psm1" -Force


if (Get-Module -Name azdo_utils) {
  Remove-Module -Name azdo_utils
}  
Import-Module "$PSScriptRoot\azdo_utils.psm1" -Force

if (Get-Module -Name tf_utils) {
  Remove-Module -Name tf_utils
}
Import-Module "$PSScriptRoot\tf_utils.psm1" -Force

if (Get-Module -Name utils) {
  Remove-Module -Name utils
}
Import-Module "$PSScriptRoot\utils.psm1" -Force


Get-Command -Module az_utils, azdo_utils, tf_utils, utils | Sort-Object -Property Name | Format-Table
