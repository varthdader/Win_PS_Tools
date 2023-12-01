Import-Module ActiveDirectory

# Mandatory Banner
Write-Host 'Powershell' $PsVersionTable.PSVersion '-' (Get-date)
Write-Host 'Auditing DC Sync Operations for Non-Standard Users'
Write-Host ''

# Modify Domain to Match Domain to be Audited
cd 'AD:DC=CLIENT-DOMAIN,DC=LOCAL'

# DS Events to Monitor For
# DS-Replication-Get-Changes-All = '1131f6ad-9c07-11d1-f79f-00c04fc2dcd2'
# DS-Replication-Get-Changes-In-Filtered-Set = '89e95b76-444d-4c62-991a-0facbeda640c'
# DS-Replication-Get-Changes = '1131f6aa-9c07-11d1-f79f-00c04fc2dcd2'

$AllReplACLs = (Get-AcL).Access | Where-Object `
{$_.ObjectType -eq '1131f6ad-9c07-11d1-f79f-00c04fc2dcd2' -or `
        $_.ObjectType -eq '89e95b76-444d-4c62-991a-0facbeda640c' -or `
        $_.ObjectType -eq '1131f6aa-9c07-11d1-f79f-00c04fc2dcd2'}

# This Filter will exclude well-lknow Administrator Groups.
# Administrator, Domain Admins, Enterprise Admins, And Domain Controllers.

foreach ($ACL in $AllReplACLs)
{
    $user = New-Object System.Security.Principal.NTAccount($ACL.IdentityReference)
    $SID = $user.Translate([System.Security.Principal.SecurityIdentifier])
    $RID = $SID.ToString().Split("-")[7]
    if([int]$RID -gt 1000)
    {
        Write-Host "Permission to Sync AD objects granted to:" $ACL.IdentityReference
    }
}
