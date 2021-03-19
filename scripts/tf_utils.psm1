Write-Host "imported tf_utils!!!"

function resetError() { $global:LASTEXITCODE = 0 }


function checkError() { if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } }


function addTfServicePrincipal() {
  param($token, $workspaceId, $sp, $prefix)

  $attributes  =
  @{
      key         =  "$($prefix)ARM_TENANT_ID".ToLower()
      value       =  $sp.tenant
      category    = "terraform"
  }
  addTfVar -token $token -workspaceId $workspaceId -atts $attributes

  $attributes  =
  @{
      key         =  "$($prefix)ARM_CLIENT_SECRET".ToLower()
      value       =  $sp.password
      category    = "terraform"
  }
  addTfVar -token $token -workspaceId $workspaceId -atts $attributes

  $attributes  =
  @{
      key         =  "$($prefix)ARM_CLIENT_ID".ToLower()
      value       =  $sp.appId
      category    = "terraform"
  }
  addTfVar -token $token -workspaceId $workspaceId -atts $attributes

}


function addTfSubscription() {
  param($token, $workspaceId, $sub, $prefix)

  $attributes  =
  @{
      key         =  "$($prefix)ARM_SUBSCRIPTION_ID".ToLower()
      value       =  $sub.id.ToString()
      category    = "terraform"
  }
  addTfVar -token $token -workspaceId $workspaceId -atts $attributes
}


function addTfAzDoToken() {
  param($token, $workspaceId, $pat, $prefix)

  $attributes  =
  @{
      key         =  "$($prefix)AZDO_TOKEN".ToLower()
      value       =  $pat
      category    = "terraform"
  }
  addTfVar -token $token -workspaceId $workspaceId -atts $attributes
}


function addTfTfeToken() {
  param($token, $workspaceId, $tfe, $prefix)

  $attributes  =
  @{
      key         =  "$($prefix)TFE_TOKEN".ToLower()
      value       =  $tfe
      category    = "terraform"
  }
  addTfVar -token $token -workspaceId $workspaceId -atts $attributes
}


function addTfVar() {
  param($token, $workspaceId, $atts)
  resetError

  $headers = @{
      'Authorization' = "Bearer $token"
      'Content-Type' = 'application/vnd.api+json'
  }


  $param = @{
      Uri     = "https://app.terraform.io/api/v2/workspaces/$workspaceId/vars"
      Method  = "Post"
      Headers = $headers
      Body = @{
          data =
          @{
              type        = "vars"
              attributes  = $atts
          }
      } | ConvertTo-Json -Depth 10
  }
  $res = Invoke-RestMethod @param
  checkError
  $res | ConvertTo-Json | Write-Host
}

function addTfVar2() {
param($token, $workspaceId, $key, $value, $category)
resetError

$headers = @{
  'Authorization' = "Bearer $token"
  'Content-Type' = 'application/vnd.api+json'
}

$attributes  = @{
    key         = $key
    value       = $value
    category    = $category
}

$param = @{
    Uri     = "https://app.terraform.io/api/v2/workspaces/$workspaceId/vars"
    Method  = "Post"
    Headers = $headers
    Body = @{
        data =
        @{
            type        = "vars"
            attributes  = $attributes
        }
    } | ConvertTo-Json -Depth 10
}
$res = Invoke-RestMethod @param
checkError
$res | ConvertTo-Json | Write-Host
}


function createTfWorkspace() {
  param($org, $token, $workspace)
  resetError

  $headers = @{
      'Authorization' = "Bearer $token"
      'Content-Type' = 'application/vnd.api+json'
  }

  $param = @{
      Uri     = "https://app.terraform.io/api/v2/organizations/$org/workspaces"
      Method  = "Post"
      Headers = $headers
      Body = @{
          data =
          @{
              type        = "workspaces"
              attributes  =
              @{
                  name            =  $workspace
                  'auto-apply'    = 'true'
              }
          }
      } | ConvertTo-Json
  }

  $res = Invoke-RestMethod @param
  checkError
  $res   | ConvertTo-Json | Write-Host

  $res
}


function createTfWorkspace2() {
    param($org, $token, $attributes)
    resetError

    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type' = 'application/vnd.api+json'
    }

    $param = @{
        Uri     = "https://app.terraform.io/api/v2/organizations/$org/workspaces"
        Method  = "Post"
        Headers = $headers
        Body = @{
            data =
            @{
                type        = "workspaces"
                attributes  = $attributes
            }
        } | ConvertTo-Json -Depth 10
    }

    $res = Invoke-RestMethod @param
    checkError
    $res   | ConvertTo-Json | Write-Host

    $res
}


function createTfWorkspace3() {
    param($org, $token, $workspace, $workingDir, $repoIdentifier, $oauthTokenId)
    resetError

    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type' = 'application/vnd.api+json'
    }

    $param = @{
        Uri     = "https://app.terraform.io/api/v2/organizations/$org/workspaces"
        Method  = "Post"
        Headers = $headers
        Body = @{
            data =
            @{
                type        = "workspaces"
                attributes  =
                @{
                    'name'              = $workspace
                    'working-directory' = $workingDir
                    'auto-apply'        = 'true'
                    'vcs-repo'  = @{
                        'identifier'        = $repoIdentifier
                        'oauth-token-id'    = $oauthTokenId
                      }
                }
            }
        } | ConvertTo-Json -Depth 10
    }

    $param   | ConvertTo-Json | Write-Host
    $res = Invoke-RestMethod @param
    checkError
    $res   | ConvertTo-Json | Write-Host

    $res
}


function deleteTfWorkspace() {
  param($org, $token, $id)
  resetError

  $headers = @{
      'Authorization' = "Bearer $token"
      'Content-Type' = 'application/vnd.api+json'
  }

  $param = @{
      Uri     = "https://app.terraform.io/api/v2/workspaces/$id"
      Method  = "delete"
      Headers = $headers
  }

  $res = Invoke-RestMethod @param
  checkError
  $res   | ConvertTo-Json | Write-Host

  $res
}


function getTfWorkspace() {
    param($org, $token, $workspace)
    resetError
    Write-Host "getTfWorkspace: $org, $workspace"

    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type' = 'application/vnd.api+json'
    }

    $param = @{
        Uri     = "https://app.terraform.io/api/v2/organizations/$org/workspaces/$workspace"
        Method  = "Get"
        Headers = $headers
    }

    $res = Invoke-RestMethod @param
    checkError
    # $res | ConvertTo-Json | Write-Host
    Write-Host " $($res.data.id)"
    
    $res
}


function getTfWorkspaceVars() {
  param($token, $workspaceId, [switch] $writeEnv)
  resetError
  Write-Host "getTfWorkspaceVars: $workspaceId"

  $headers = @{
      'Authorization' = "Bearer $token"
      'Content-Type' = 'application/vnd.api+json'
  }

  $param = @{
      Uri     = "https://app.terraform.io/api/v2/workspaces/$workspaceId/vars"
      Method  = "Get"
      Headers = $headers
  }
  $res = Invoke-RestMethod @param
  checkError
  # $res | ConvertTo-Json -Depth 10 | Write-Host
 
  $ret = @{};

  foreach ($v in $res.data) {
    Write-Host "  $($v.attributes.key) "
    $ret.Add($v.attributes.key, $v.attributes.value)

    if ($writeEnv) {
      Write-Host "    writing env var"
      # $env:$($v.attributes.key) $v.attributes.value
      Set-Item -Path "Env:$($v.attributes.key)" -Value $v.attributes.value
      # [Environment]::SetEnvironmentVariable($v.attributes.key, $v.attributes.value, 'User')
    }
  }

  return $ret
}

function updateTfVar() {
    param($token, $workspaceId, $atts)
    resetError

    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type' = 'application/vnd.api+json'
    }


    $param = @{
        Uri     = "https://app.terraform.io/api/v2/workspaces/$workspaceId/vars"
        Method  = "Patch"
        Headers = $headers
        Body = @{
            data =
            @{
                type        = "vars"
                attributes  = $atts
            }
        } | ConvertTo-Json
    }
    $res = Invoke-RestMethod @param
    checkError
    $res| Write-Host
}


function writeTfTemplate() {
  $file = 'main.tf.txt'

  $tmp = (az account show)
  $account = (ConvertFrom-Json -InputObject  ([System.string]::Concat($tmp)))
  # $subscriptionId = $account.id

  'locals {' | Out-File $file
  '    backend_subscription_id   = "' + $account.id + '"' | Add-Content $file
  '    backend_tenant_id      = "' + $account.tenantId + '"' | Add-Content $file
  '    devops_url             = "' + $org + '"' | Add-Content $file
  '    backend_resource_group_name     = "' + $resourceGroupName + '"' | Add-Content $file
  '    backend_storage_account_name    = "' + $storageAccountName + '"' | Add-Content $file
  '    backend_key                     = "devops-master-config.tfstate" ' | Add-Content $file
  '    project_name                    = "' + $project + '"' | Add-Content $file
  '    keyvault_name                   = "' + $keyVaultName + '"' | Add-Content $file
  '}'  | Add-Content $file

  ''  | Add-Content $file

  'terraform {' | Add-Content $file
  '   backend "azurerm" { ' | Add-Content $file
  '       resource_group_name  = "' + $resourceGroupName + '"' | Add-Content $file
  '       storage_account_name = "' + $storageAccountName + '"' | Add-Content $file
  '       container_name       = "terraform"  ' | Add-Content $file
  '       key                  = "devops-master-config.tfstate" ' | Add-Content $file
  '   }'  | Add-Content $file
  '}'  | Add-Content $file
}


