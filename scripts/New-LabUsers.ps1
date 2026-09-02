Import-Module ActiveDirectory

$Users = Import-Csv "C:\Scripts\new-users.csv"
$UserOU = "OU=Users List,DC=ad,DC=nlaur,DC=com"

$DefaultPassword = Read-Host "Enter temporary password" -AsSecureString

foreach ($User in $Users) {

    $Username = $User.Username
    $FullName = "$($User.FirstName) $($User.LastName)"

    # Check whether the account already exists
    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Warning "$Username already exists. Skipping."
        continue
    }

    try {

        New-ADUser `
            -Name $FullName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@ad.nlaur.com" `
            -Department $User.Department `
            -Path $UserOU `
            -AccountPassword $DefaultPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Created user: $Username"

        if ($User.Group) {
            Add-ADGroupMember `
                -Identity $User.Group `
                -Members $Username

            Write-Host "Added $Username to $($User.Group)"
        }
    }
    catch {
        Write-Error "Failed to provision $Username : $($_.Exception.Message)"
    }
}