# VBoxManage Command Cheat Sheet

## Algemene opdrachten

- `VBoxManage list vms`: Lijst van alle virtuele machines.
- `VBoxManage showvminfo <VM Name or UUID>`: Toont informatie over een specifieke VM.
- `VBoxManage startvm <VM Name or UUID>`: Start een virtuele machine.
- `VBoxManage controlvm <VM Name or UUID> poweroff`: Schakelt een virtuele machine uit.
- `VBoxManage controlvm <VM Name or UUID> reset`: Herstart een virtuele machine.
- `VBoxManage unregistervm <VM Name or UUID> --delete`: Verwijder een VM inclusief de bestanden.
- `VBoxManage modifyvm <VM Name or UUID> --name <New Name>`: Wijzigt de naam van een virtuele machine.
- `VBoxManage snapshot <VM Name or UUID> take <Snapshot Name>`: Maakt een snapshot van een virtuele machine.
- `VBoxManage snapshot <VM Name or UUID> restore <Snapshot Name>`: Herstelt een virtuele machine naar een eerder gemaakte snapshot.
- `VBoxManage snapshot <VM Name or UUID> delete <Snapshot Name or UUID>`: Verwijdert een snapshot.

## Opdrachten voor hardware-instellingen

- **Geheugen en CPU's:**
  - `VBoxManage modifyvm <VM Name or UUID> --memory <Memory in MB>`: Wijzigt de hoeveelheid toegewezen geheugen aan een VM.
  - `VBoxManage modifyvm <VM Name or UUID> --cpus <Number of CPUs>`: Wijzigt het aantal virtuele CPU's voor een VM.

- **Netwerk:**
  - `VBoxManage modifyvm <VM Name or UUID> --nic<1-N> bridged`: Schakelt de bridged mode in voor netwerkadapter 1-N.
  - `VBoxManage modifyvm <VM Name or UUID> --natpf<1-N> "rule name,protocol,host IP,host port,guest IP,guest port"`: Voegt een port forwarding regel toe.

## Beheer van opslag

- `VBoxManage createhd --filename <Path to VDI file> --size <Size in MB>`: Maakt een nieuwe virtuele harde schijf.
- `VBoxManage storagectl <VM Name or UUID> --name "SATA Controller" --add sata`: Voegt een SATA-controller toe aan een VM.
- `VBoxManage storageattach <VM Name or UUID> --storagectl "SATA Controller" --port <Port Number> --device <Device Number> --type hdd --medium <Path to VDI file>`: Koppelt een VDI-bestand aan een VM.

## Importeren en exporteren van VM's

- `VBoxManage import <Appliance File>`: Importeert een VM vanuit een OVA-bestand.
- `VBoxManage export <VM Name or UUID> --output <Output File>`: Exporteert een VM naar een OVA-bestand.

## Aanmaken van een virtuele machine

- `VBoxManage createvm --name <VM Name> --ostype <OS Type> --register --basefolder <Base Folder>`: Maakt een nieuwe virtuele machine aan.
  - `<VM Name>`: Naam van de virtuele machine.
  - `<OS Type>`: Type van het besturingssysteem, bijv. "Linux26_64" voor een 64-bit Linux.
  - `<Base Folder>`: De basismap waarin de VM-bestanden worden opgeslagen, typisch iets als `/home/gebruikersnaam/VirtualBox VMs/`.

## Gebruik van ISO's van osboxes.org

Om een ISO van osboxes.org te gebruiken, download de ISO van de website en sla deze op op je computer. Vervolgens kun je deze ISO koppelen aan de virtuele machine met de volgende opdracht:

- `VBoxManage storageattach <VM Name or UUID> --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium <Path to ISO File>`: Koppelt de ISO aan de virtuele machine.

