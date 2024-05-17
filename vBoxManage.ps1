$vmName = "vulnerableVM"
$kaliName = "kaliVM"

$vdiPath = "debian.vdi"
$kaliPath = "kali.vdi"
$guestPath = "VBoxGuestAdditions.iso"

$memory = "2048"
$cpu = "2"

$USERNAME = "osboxes"
$PASSWORD = "osboxes.org"

$existingVM = VBoxManage.exe list vms | Select-String -Pattern "$vmName"
if ($existingVM) {
    Write-Host "Deleting existing Debian VM"
    VBoxManage.exe unregistervm $vmName --delete
}

if (-Not (Test-Path -Path ".\debian.vdi")) {
    Expand-Archive -Path .\debian.zip -DestinationPath .
}

$existingKaliVM = VBoxManage.exe list vms | Select-String -Pattern "$kaliName"
if ($existingKaliVM) {
    Write-Host "Deleting existing Kali VM"
    VBoxManage.exe unregistervm $kaliName --delete
}

if (-Not (Test-Path -Path ".\Kali.vdi")) {
    Expand-Archive -Path .\Kali.zip -DestinationPath .
}

Write-Host "Creating VM"
VBoxManage.exe createvm --name $vmName --register
VBoxManage.exe createvm --name $kaliName --register

VBoxManage.exe storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage.exe storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vdiPath
VBoxManage.exe storageattach $vmName --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $guestPath

VBoxManage.exe storagectl $kaliName --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage.exe storageattach $kaliName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $kaliPath

VBoxManage.exe modifyvm $vmName --memory $memory --cpus $cpu
VBoxManage.exe modifyvm $kaliName --memory $memory --cpus $cpu

VBoxManage.exe modifyvm $vmName --nic1 nat
VBoxManage.exe modifyvm $vmName --natpf1 "ssh,tcp,,3022,,22"
VBoxManage.exe modifyvm $vmName --nic1 nat
VBoxManage.exe modifyvm $vmName --natpf2 "unifi communication,tcp,,8080,,8080"
VBoxManage.exe modifyvm $vmName --nic1 nat
VBoxManage.exe modifyvm $vmName --natpf3 "unifi gui,tcp,,8443,,8443"
VBoxManage.exe modifyvm $kaliName --nic1 nat
VBoxManage.exe modifyvm $kaliName --natpf1 "ssh,tcp,,3022,,22"

$hostonlyif = (VBoxManage.exe hostonlyif create) -replace ".*'([^']+)'.*", '$1'
VBoxManage.exe hostonlyif ipconfig $hostonlyif --ip "192.168.69.1" --netmask "255.255.255.0"

VboxManage.exe modifyvm $vmName --nic2 hostonly --hostonlyadapter2 $hostonlyif
VboxManage.exe modifyvm $kaliName --nic2 hostonly --hostonlyadapter2 $hostonlyif

VBoxManage.exe modifyvm $vmName --nic3 intnet
VBoxManage.exe modifyvm $kaliName --nic3 intnet

VBoxManage.exe sharedfolder add $vmName --name "shared" --hostpath "shared" --automount

VBoxManage.exe startvm $vmName --type headless
VBoxManage.exe startvm $kaliName --type headless