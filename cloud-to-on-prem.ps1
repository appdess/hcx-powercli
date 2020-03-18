# ------------- VARIABLES SECTION  ------------- 
$cloudHCX = "10.56.224.25" # This is your Cloud HCX
$cloudHCXUser = "cloudadmin@vmc.local"
$cloudHCXPassword = "zM*7Myx6QBAsnF-"
$HCXNetworkCloud = "L2E_vds-emea-stretched-0-1b039c1f"
$HCXNetworkOnPrem = "vds-emea-stretched"
Connect-HCXServer $cloudHCX -user $cloudHCXUser -password $cloudHCXPassword

$vm = Get-HCXVM -Name MigrateVM-11
$hcxCloud = Get-HCXSite -Destination
$hcxOnprem = Get-HCXSite -Source
$cloudCompute = Get-HCXContainer -Name Compute-ResourcePool -Site $hcxCloud
$onpremCompute = Get-HCXContainer -Name VSAN-Cluster -Site $hcxOnprem
$cloudDS = Get-HCXDatastore -Name WorkloadDatastore -Site $hcxCloud
$onpremdDS = Get-HCXDatastore -Name vsanDatastore -Site $hcxCloud
$cloudNet = Get-HCXNetwork -Name $HCXNetworkCloud -Site $hcxCloud
$onpremNet = Get-HCXNetwork -Name $HCXNetworkOnPrem -Site $SourceSite
$netmapCloud = New-HCXNetworkMapping -sourceNetwork $onpremNet -DestinationNetwork $cloudNet
$netmapOnPrem = New-HCXNetworkMapping -sourceNetwork $cloudNet -DestinationNetwork $sourceNet
# ------------- END VARIABLES  ------------- 

Connect-HCXServer $onpremHCX -user $onpremHCXUser -password $onpremHCXPassword
Connect-HCXServer $cloudHCX -user $cloudHCXUser -password $cloudHCXPassword

$netmapCloud = New-HCXNetworkCloudMapping -sourceNetwork $onpremNet -DestinationNetwork $cloudNet
$netmapOnPrem = New-HCXNetworkCloudMapping -sourceNetwork $onpremNet -DestinationNetwork $cloudNet

# Store output into cmdlet:
$newMigration = New-HCXMigration -DestinationSite $hcxCloud -MigrationType vMotion -SourceSite $hcxOnprem -TargetComputeContainer $cloudCompute -TargetDatastore $cloudDS -TargetNetwork $cloudNet -VM $vm

$newMigration = New-HCXMigration -DestinationSite $hcxCloud -MigrationType vMotion -SourceSite $hcxOnprem -TargetComputeContainer $cloudCompute -TargetDatastore $cloudDS -NetworkMapping $netmapCloud -VM $vm

$newMigration = New-HCXMigration -DestinationSite $hcxOnprem -MigrationType vMotion -SourceSite $hcxCloud -TargetComputeContainer $onpremCompute -TargetDatastore $onpremdDS -NetworkMapping $netmapOnPrem -VM $vm

# Test-Migration:
# Test-HCXMigration -Migration $newMigration

# Actual Migration
Start-HCXMigration -Migration $newMigration -confirm:$false
