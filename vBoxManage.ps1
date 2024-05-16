$vmName = "vulnerableVM"
$vdiPath = "debian.vdi"
$memory = "4096"
$cpu = "4"

$USERNAME = "osboxes"
$PASSWORD = "osboxes.org"

$existingVM = VBoxManage.exe list vms | Select-String -Pattern "$vmName"
if ($existingVM) {
    Write-Host "Deleting existing VM"
    VBoxManage.exe unregistervm $vmName --delete
}

if (-Not (Test-Path -Path ".\debian.vdi")) {
    Expand-Archive -Path .\Fedora.zip -DestinationPath .
}

Write-Host "Creating VM"
VBoxManage.exe createvm --name $vmName --register
VBoxManage.exe storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage.exe storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vdiPath

VBoxManage.exe modifyvm $vmName --memory $memory --cpus $cpu

VBoxManage.exe modifyvm $vmName --nic1 nat
VBoxManage.exe modifyvm $vmName --natpf1 "guestssh,tcp,,3022,,22"

$hostonlyif = (VBoxManage.exe hostonlyif create) -replace ".*'([^']+)'.*", '$1'
VBoxManage.exe hostonlyif ipconfig $hostonlyif --ip "192.168.69.1" --netmask "255.255.255.0"

VboxManage.exe modifyvm $vmName --nic2 hostonly --hostonlyadapter2 $hostonlyif

VBoxManage.exe sharedfolder add $vmName --name "shared" --hostpath "shared" --automount

VBoxManage.exe startvm $vmName --type headless
Start-Sleep -Seconds 140