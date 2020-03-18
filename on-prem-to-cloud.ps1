# Reads the input - provide it like  ".\on-prem-to-cloud.ps1 Migrate-VM11"
param($vmname)


$onpremHCX = "172.30.0.171" # This is your on-prem HCX
$onpremHCXUser = "administrator@vsphere.local"
$onpremHCXPassword = "VMware1!"
$HCXNetworkCloud = "L2E_vds-emea-stretched-0-1b039c1f"
$HCXNetworkOnPrem = "vds-emea-stretched"
Connect-HCXServer $onpremHCX -user $onpremHCXUser -password $onpremHCXPassword


$vm = Get-HCXVM -Name $vmname
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
