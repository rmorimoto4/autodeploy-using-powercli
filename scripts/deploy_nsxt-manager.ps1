#Credentials
$vcenter="172.16.xx.xx"
$vcsa_user="administrator@vsphere.local"
$vcsa_password="VMware1!"

#Connect
Connect-VIServer $vcenter -User $vcsa_user -Password $vcsa_password –force

#Setting
$ova_file = "C:\work\xxxxx.ova"
$ovf_config = Get-OvfConfiguration $ova_file

#Config Parameter
$ovf_config.DeploymentOption.Value = "small" #Size
$ovf_config.NetworkMapping.Network_1.Value = "pg-xxxx" # Portgroup
$ovf_config.Common.nsx_hostname.Value = "nsxt-mgr01" # Hostname
$ovf_config.IpAssignment.IpProtocol.Value = "IPv4" # Ip protocol
$ovf_config.Common.nsx_ip_0.Value ="172.16.xx.xx" # Mgmt ip
$ovf_config.Common.nsx_netmask_0.Value ="255.255.255.0" # Netmask
$ovf_config.Common.nsx_gateway_0.Value ="172.16.xx.xx" # Gateway
$ovf_config.Common.nsx_passwd_0.Value = "VMware1!VMware1!" # Root User Password
$ovf_config.Common.nsx_cli_passwd_0.Value = "VMware1!VMware1!" # Admin User Password
$ovf_config.Common.nsx_cli_audit_passwd_0.Value = "VMware1!VMware1!" # Audit User Password
$ovf_config.Common.nsx_role.Value = "NSX Manager" # Role
$ovf_config.Common.nsx_dns1_0.Value ="172.16.xx.xx" # DNS
$ovf_config.Common.nsx_domain_0.Value = "xxxx" # Domain search list
$ovf_config.Common.nsx_ntp_0.Value = "172.16.xx.xx" # NTP
$ovf_config.Common.nsx_isSSHEnabled.Value = $true  # SSH
$ovf_config.Common.nsx_allowSSHRootLogin.Value = $true # Root SSH

#Deploy Parameter
$vm_name = "nsxt-mgr01"
$host_name = "xxxxx"
$vm_host = (Get-VMHost -Name $host_name)
$datastore = "xxxxx"

#Deploy
$vm_host | Import-VApp -Source $ova_file -Name $vm_name -Datastore $datastore -DiskStorageFormat "Thin" -OvfConfiguration $ovf_config -Force
$vm = Get-VM $vm_name

#Setting after Deployment
$vm | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemReservationGB 0 -CpuReservationMhz 0 #Release resource reservation

#Power on
$vm | Start-VM

#Disconnect
Disconnect-VIServer -Server $vcenter -Confirm:$false
