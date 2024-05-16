$vmName = "vulnerableVM"
$vdiPath = "Fedora.vdi"
$guestPath = "VBoxGuestAdditions.iso"
$memory = "4096"
$cpu = "4"

$USERNAME = "root"
$PASSWORD = "osboxes.org"

# Check if VM with the same name already exists and delete it
$existingVM = VBoxManage.exe list vms | Select-String -Pattern "$vmName"
if ($existingVM) {
    Write-Host "Deleting existing VM"
    VBoxManage.exe unregistervm $vmName --delete
}

if (-Not (Test-Path -Path ".\Fedora.vdi")) {
    Expand-Archive -Path .\Fedora.zip -DestinationPath .
}

# Create VM and attach VDI
Write-Host "Creating VM"
VBoxManage.exe createvm --name $vmName --register
VBoxManage.exe storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage.exe storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vdiPath

VBoxManage.exe modifyvm $vmName --memory $memory --cpus $cpu

VBoxManage.exe modifyvm $vmName --nic1 nat
VBoxManage.exe modifyvm $vmName --natpf1 "guestssh,tcp,,2222,,22"

$hostonlyif = (VBoxManage.exe hostonlyif create) -replace ".*'([^']+)'.*", '$1'
VBoxManage.exe hostonlyif ipconfig $hostonlyif --ip "192.168.69.1" --netmask "255.255.255.0"

VboxManage.exe modifyvm $vmName --nic2 hostonly --hostonlyadapter2 $hostonlyif

VBoxManage.exe sharedfolder add $vmName --name "shared" --hostpath "shared" --automount

# Start VM
Write-Host "Starting VM"
VBoxManage.exe startvm $vmName --type headless

# Wait for VM to boot up
Start-Sleep -Seconds 140

# Run shell script on VM
Write-Host "Running script on VM:"

#VBoxManage.exe guestcontrol $vmName execute --image "/bin/sh" --username $USERNAME --password $PASSWORD --wait-exit --wait-stdout -- "sudo dnf install -y kernel-devel gcc perl make bzip2 dkms elfutils-libelf-devel"
#VBoxManage.exe guestcontrol $vmName run "/bin/sh" --username $USERNAME --password $PASSWORD --verbose --wait-stdout --wait-stderr -- -c "sudo dnf install -y virtualbox-guest-additions"
#Start-Sleep -Seconds 180
#VBoxManage.exe controlvm $vmName reset

#VBoxManage.exe guestcontrol "vulnerableVM" run "/bin/sh" --username "root" --password "osboxes.org" --verbose --wait-stdout --wait-stderr -- -c "sudo dnf install -y virtualbox-guest-additions"