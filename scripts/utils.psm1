Write-Host "imported utils!!!"

function resetError() { $global:LASTEXITCODE = 0 }

function checkError() { if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } }


function readLocalServicePrincipal() {
    param($spFile)

    resetError

    $p = 'secret-sp-' + $spFile + '.json'
    $tmp = Get-Content -Path $p
    checkError
    $sp = ConvertFrom-Json -InputObject ([System.string]::Concat($tmp))
    checkError

    $sp
}


function readLocalAccount() {
    param($subFile)

    resetError

    $p = 'secret-account-' + $subFile + '.json'
    $tmp = Get-Content -Path $p
    checkError
    $sp = ConvertFrom-Json -InputObject ([System.string]::Concat($tmp))
    checkError

    $sp
}