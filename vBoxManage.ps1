# Variabelen declareren, sommige hiervan zijn gemeenschappelijk voor beide vm's
$vmName = "vulnerableVM"
$kaliName = "kaliVM"

$vdiPath = "debian.vdi"
$kaliPath = "kali.vdi"
$guestPath = "VBoxGuestAdditions.iso"

$memory = "2048"
$cpu = "2"

$USERNAME = "osboxes"
$PASSWORD = "osboxes.org"

# Er wordt gecontroleerd of er al een VM bestaat in Virtualbox met de naam vulnerableVM of kaliVM. Als dit het geval is wordt die eerst verwijderd
$existingVM = VBoxManage.exe list vms | Select-String -Pattern "$vmName"
if ($existingVM) {
    Write-Host "Deleting existing Debian VM"
    VBoxManage.exe unregistervm $vmName --delete
}
$existingKaliVM = VBoxManage.exe list vms | Select-String -Pattern "$kaliName"
if ($existingKaliVM) {
    Write-Host "Deleting existing Kali VM"
    VBoxManage.exe unregistervm $kaliName --delete
}

# Er wordt gecontroleerd of er al een vdi aanwezig is in de root directory met de correcte naam. Als dit niet het geval is worden de respectievelijke zips met de vdi uitgepakt. Dit wordt zo gedaan omdat de vdi in de root directory na koppelen aan een vm niet meer bruikbaar is (door aanpassingen, mee verwijderen met de vm, ...)
if (-Not (Test-Path -Path ".\debian.vdi")) {
    Expand-Archive -Path .\debian.zip -DestinationPath .
}
if (-Not (Test-Path -Path ".\Kali.vdi")) {
    Expand-Archive -Path .\Kali.zip -DestinationPath .
}

# De VM's worden aangemaakt
Write-Host "Creating VM"
VBoxManage.exe createvm --name $vmName --register
VBoxManage.exe createvm --name $kaliName --register

# Voor beide VM's wordt een SATA controller aangemaakt en de .vdi van osboxes wordt gekoppeld. Bij de Debian VM wordt ook de Guest Additions .iso gekoppeld
VBoxManage.exe storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage.exe storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vdiPath
VBoxManage.exe storageattach $vmName --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $guestPath

VBoxManage.exe storagectl $kaliName --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage.exe storageattach $kaliName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $kaliPath

# Aan beide VM's worden geheugen en vCPU cores toegekend a.d.h.v. eerder gedefineerde variabelen.
VBoxManage.exe modifyvm $vmName --memory $memory --cpus $cpu
VBoxManage.exe modifyvm $kaliName --memory $memory --cpus $cpu

# Beide VM's krijgen een nat adapter om toegang te hebben tot het internet. Op elke VM worden ook enkele port forwards ingesteld. Wanneer de host only interfaces op punt staan hoeft dit eigenlijk niet meer
# Op beide VM's worden poorten 22 opengezet naar de host poort 3022 om een SSH verbinding te kunnen maken
# Op de Debian VM wordt ook poort 8080 en 8443 opengezet voor de Unifi service
VBoxManage.exe modifyvm $vmName --nic1 nat
VBoxManage.exe modifyvm $vmName --natpf1 "ssh,tcp,,3022,,22"
VBoxManage.exe modifyvm $vmName --nic1 nat
VBoxManage.exe modifyvm $vmName --natpf1 "unifi communication,tcp,,8080,,8080"
VBoyxManage.exe modifyvm $vmName --nic1 nat
VBoxManage.exe modifyvm $vmName --natpf1 "unifi gui,tcp,,8443,,8443"

VBoxManage.exe modifyvm $kaliName --nic1 nat
VBoxManage.exe modifyvm $kaliName --natpf1 "ssh,tcp,,4022,,22"

# Er wordt een host only interface aangemaakt die er voor zorgt dat communicatie tussen de host en de vm's mogelijk is. Ook communicatie tussen de VM's onderling is mogelijk.
$hostonlyif = (VBoxManage.exe hostonlyif create) -replace ".*'([^']+)'.*", '$1'
VBoxManage.exe hostonlyif ipconfig $hostonlyif --ip "192.168.69.1" --netmask "255.255.255.0"
VBoxManage.exe dhcpserver add --netname $hostonlyif --ip "192.168.69.1" --netmask "255.255.255.0" --lowerip "192.168.69.10" --upperip "192.168.69.20" --enable

VboxManage.exe modifyvm $vmName --nic2 hostonly --hostonlyadapter2 $hostonlyif
VboxManage.exe modifyvm $kaliName --nic2 hostonly --hostonlyadapter2 $hostonlyif

# Er wordt een gedeelde map aangemaakt tussen de host (/shared in de root directory) en de Debian VM
VBoxManage.exe sharedfolder add $vmName --name "shared" --hostpath "shared" --automount

# De VM's worden opgestart
VBoxManage.exe startvm $vmName --type headless
VBoxManage.exe startvm $kaliName --type headless