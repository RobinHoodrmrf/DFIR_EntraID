# Import the AzureAD module
Import-Module AzureAD

# Connect to Azure AD with admin credentials
function Connect-AzureADAccount {
    try {
        Connect-AzureAD
    }
    catch {
        Write-Host "Error connecting to Azure AD: $_"
        return $false
    }
    return $true
}

# Get User ID from User Principal Name (UPN) (decided this was the easiest way to work)
function Get-UserIdFromUPN {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserPrincipalName
    )

    try {
        $user = Get-AzureADUser -Filter "UserPrincipalName eq '$UserPrincipalName'"
        return $user.ObjectId
    }
    catch {
        Write-Host "Failed to find user with UPN $UserPrincipalName - $_"
        return $null
    }
}

# Actions to be taken on each user
function ProcessUserActions {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory=$true)]
        [string]$UserId
    )

    $action = Read-Host "Select action for ${UserPrincipalName}: 1 for Revoke Sessions, 2 for Reset Password, 3 for Both, 4 for Disable User, 5 for None"
    switch ($action) {
        "1" {
            Revoke-AzureADUserSessions -UserId $UserId
        }
        "2" {
            Reset-UserPassword -UserId $UserId
        }
        "3" {
            Revoke-AzureADUserSessions -UserId $UserId
            Reset-UserPassword -UserId $UserId
        }
        "4" {
            Disable-AzureADUser -UserId $UserId
        }
        "5" {
            Write-Host "No action taken for $UserPrincipalName."
        }
        default {
            Write-Host "Invalid selection. No action taken for $UserPrincipalName."
        }
    }
}

# Revoke user sessions
function Revoke-AzureADUserSessions {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserId
    )
    
    try {
        Revoke-AzureADUserAllRefreshToken -ObjectId $UserId
        Write-Host "Sessions revoked for user ID: $UserId"
    }
    catch {
        Write-Host "Failed to revoke sessions for user ID: $UserId - $_"
    }
}

# Reset user password
function Reset-UserPassword {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserId
    )

    $newPassword = "TemporaryPassword123!" # Define a temporary password or generate a random one
    try {
        Set-AzureADUserPassword -ObjectId $UserId -Password $newPassword -ForceChangePasswordNextLogin $true
        Write-Host "Password reset for user ID: $UserId. New temporary password: $newPassword"
    }
    catch {
        Write-Host "Failed to reset password for user ID: $UserId - $_"
    }
}

# Disable a user account
function Disable-AzureADUser {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserId
    )

    try {
        Set-AzureADUser -ObjectId $UserId -AccountEnabled $false
        Write-Host "User account disabled for user ID: $UserId"
    }
    catch {
        Write-Host "Failed to disable user account for user ID: $UserId - $_"
    }
}

# Main script
if (Connect-AzureADAccount) {
    $userInput = Read-Host "Enter the user principal names (UPNs) to process (comma-separated)"
    $userUPNs = $userInput -split "," | ForEach-Object { $_.Trim() }
    foreach ($UPN in $userUPNs) {
        $userId = Get-UserIdFromUPN -UserPrincipalName $UPN
        if ($null -ne $userId) {
            ProcessUserActions -UserPrincipalName $UPN -UserId $userId
        } else {
            Write-Host "No valid user ID found for $UPN."
        }
    }
} else {
    Write-Host "Failed to connect to Azure AD. Exiting script."
}
