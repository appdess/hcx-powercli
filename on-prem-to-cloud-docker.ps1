<#
.SYNOPSIS HCX-Migration Script in docker with external input
.NOTES  Author:  Alex Dess
.NOTES  Site:    alexdess.cloud

# Pass variables to the runtime, adjusted so you need to only pass PW + VM to be migrated!
docker run -e "vmName=MigrateVM-11" -e "onpremHCXPassword=VMware1" -it adess/hcx-migration

#>
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null


#Change this values to your ENVironment!
$vmName = (Get-ChildItem ENV:vmName).Value
$onpremHCXPassword = (Get-ChildItem ENV:onpremHCXPassword).Value
$onpremHCX = "172.30.0.171" # This is the IP or FQDN your on-prem HCX
$onpremHCXUser = "administrator@vsphere.local"
$HCXNetworkCloud = "L2E_vds-emea-stretched-0-1b039c1f"
$HCXNetworkOnPrem = "vds-emea-stretched"

Write-Host -ForegroundColor magenta "you submitted the following variables"
Write-Host "onpremHCX=$onpremHCX"
Write-Host "onpremHCXUser=$onpremHCXUser"
Write-Host "onpremHCXPassword=$onpremHCXPassword"
Write-Host "HCXNetworkCloud=$HCXNetworkCloud"
Write-Host "HCXNetworkOnPrem=$HCXNetworkOnPrem"
Write-Host "vmName=$vmName"

Connect-HCXServer $onpremHCX -user $onpremHCXUser -password $onpremHCXPassword

$vm = Get-HCXVM -Name $vmName
$hcxCloud = Get-HCXSite -Destination
$hcxOnprem = Get-HCXSite -Source
$cloudCompute = Get-HCXContainer -Name Compute-ResourcePool -Site $hcxCloud
$cloudDS = Get-HCXDatastore -Name WorkloadDatastore -Site $hcxCloud
$cloudNet = Get-HCXNetwork -Name $HCXNetworkCloud -Site $hcxCloud
$onpremNet = Get-HCXNetwork -Name $HCXNetworkOnPrem -Site $SourceSite
$netmapCloud = New-HCXNetworkMapping -sourceNetwork $onpremNet -DestinationNetwork $cloudNet

# setup our migration
$newMigration = New-HCXMigration -DestinationSite $hcxCloud -MigrationType vMotion -SourceSite $hcxOnprem -TargetComputeContainer $cloudCompute -TargetDatastore $cloudDS -NetworkMapping $netmapCloud -VM $vm


# Actual Migration
Start-HCXMigration -Migration $newMigration -confirm:$false
