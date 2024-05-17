# Deployment handleiding

## VBoxManage
1. Download [Debian 10 Buster - Server](https://sourceforge.net/projects/osboxes/files/v/vb/14-D-b/10/CLI/64bit.7z/download) en [Kali Linux 2022.1 (All Tools)](https://sourceforge.net/projects/osboxes/files/v/vb/25-Kl-l-x/2022.1/64bit.7z/download)

Er werd voor Debian gekezen omdat Unifi hier native op draait. Daarnaast werd er specifiek voor deze versies gekozen omdat deze recent en lightweight zijn.

2. Verplaats de vdi's naar de root directory van het vBoxManage.ps1 script. Hernoem de bestanden respectievelijk naar *Debian.vdi* en *Kali.vdi*

3. Voer het vBoxManage.ps1 script uit door in de root directory een terminal te openen en daar het commando **./vBoxManage.ps1** uit te voeren.

## VirtualBox Guest Additions
1. Start een SSH verbinding met de Debian VM door in een terminal het commando **ssh osboxes@localhost -p 3022** uit te voeren. Wanneer erom wordt gevraagd, geef dan het wachtwoord **osboxes.org** in. Als er wordt gevraagd om de fingerprint van de host te accepteren. Voer dan **yes** in.

    > Het invoeren van een plain text wachtwoord is niet veilig. Aangezien het hier om een demo-omgeving gaat met een algemeen gekend wachtwoord kunnen we dit toch gebruiken. In een productieomgeving moet er echter met een secret key-pair gewerkt worden.

2. Eenmaal een SSH verbinding tot stand gebracht werd, voer volgende commando's sequentieel uit om de Guest Additions iso te koppelen aan de VM en deze dan te installeren. We doen dit zodat de VM toegang heeft tot de gedeelde map. Als erom gevraagd wordt, geef dan het wachtwoord **osboxes.org** in.

    **sudo mount /dev/dvd /mnt**
    **cd /mnt**
    **./VBoxLinuxAdditions.run**

    > Deze commando's kunnen eventueel automatisch uitgevoerd worden met het VBoxManage guestcontrol commando.

