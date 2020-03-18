<#
.SYNOPSIS HCX-Migration Script in docker with external input
.NOTES  Author:  Alex Dess
.NOTES  Site:    alexdess.cloud
.NOTES  Reference: TBD!!
.NOTES  Docker Command: docker run --rm -it --entrypoint='/usr/bin/pwsh' \
    -v /Users/adess/scripts:/tmp/scripts vmware/powerclicore /tmp/scripts/on-prem-to-cloud-docker.ps1 -onpremHCX 172.30.0.171 -onpremHCXUser administrator@vsphere.local -onpremHCXPassword VMware1! -HCXNetworkCloud L2E_vds-emea-stretched-0-1b039c1f -HCXNetworkOnPrem vds-emea-stretched -vmName MigrateVM-11
#>
param(
    [Parameter(Mandatory=$true)]
    [String]$onpremHCX,

    [Parameter(Mandatory=$true)]
    [String]$onpremHCXUser,

    [Parameter(Mandatory=$true)]
    [String]$onpremHCXPassword,

    [Parameter(Mandatory=$true)]
    [String]$HCXNetworkCloud

    [Parameter(Mandatory=$true)]
    [String]$HCXNetworkOnPrem

    [Parameter(Mandatory=$true)]
    [String]$vmName
)

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

Write-Host -ForegroundColor magenta "you submitted the following variables"
Write-Host "onpremHCX=$onpremHCX"
Write-Host "onpremHCXUser=$onpremHCXUser"
Write-Host "onpremHCXPassword=$onpremHCXPassword"
Write-Host "HCXNetworkCloud=$HCXNetworkCloud"
Write-Host "HCXNetworkOnPrem=$HCXNetworkOnPrem"
Write-Host "vmName=$vmName"

<#
$onpremHCX = "172.30.0.171" # This is your on-prem HCX
$onpremHCXUser = "administrator@vsphere.local"
$onpremHCXPassword = "VMware1!"
$HCXNetworkCloud = "L2E_vds-emea-stretched-0-1b039c1f"
$HCXNetworkOnPrem = "vds-emea-stretched"
#>

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
