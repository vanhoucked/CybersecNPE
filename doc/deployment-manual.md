# Deployment handleiding

De volledige GitHub repository met alle scripts, handleidingen en documentatie is beschikbaar via [https://github.com/vanhoucked/CybersecNPE.git](https://github.com/vanhoucked/CybersecNPE.git)

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

## Unifi installatie
1. Verander de permissies door het commando **sudo chmod +777 /media/sf_shared** uit te voeren.

2. Navigeer naar de shared folder met het commando **cd /media/sf_shared**.

3. Voer daar het bash script uit met het commando **./script.ssh**

    > In sommige gevallen worden de Virtualbox Guest Additions niet correct geïnstalleerd waardoor de gedeelde map geen bestanden bevat. Ga in dat geval verder met onderstaande stappen. Anders kan er naar stap 7 gegaan worden.

4. Download het easy install script van Glenn Rietveld door het commando **wget https://get.glennr.nl/unifi/install/unifi-6.4.54.sh** uit te voeren.

    > Er wordt hier bewust voor een oudere versie van de Unifi controller nl. 6.4.54. gekozen omdat hier de Log4J exploit nog niet gepatched is.

    > Unifi kan ook manueel geïnstalleerd worden. De repository bevindt zich op https://dl.ui.com/unifi/6.4.54/UniFi-installer.exe. Hier wordt echter gebruik gemaakt van een script dat ook alle dependencies zoals de database en java installeert.

5. Voer het script uit door in de map waar het gedownload werd het commando **yes | sudo bash unifi-6.4.54.sh** uit te voeren.

6. Voer **y** in wanneer het script hierom vraagt.

7. Als de shared folder wel het script *script.sh* bevat. Voer deze dan uit door eerst te navigeren naar de map met het commando **cd /media/sf_shared** om er naarda het script uit te voeren met het commando **./script.sh**

### Unifi controller configuratie
1. Ga naar de controller webgui door in de zoekbalk van uw webbrowser **https://localhost:8443** in te geven.






## Mogelijke verbeteringen aan het script
- De installatie van de guest additions moet gefinetuned worden. Momenteel wordt de lokale .iso gekoppeld aan de VM om deze dan uit te voeren maar af en toe faalt de installatie. Waarschijnlijk door dependencies die niet geïnstalleerd zijn.

- Er bestaan mogelijkheden om de SSH verbinding automatisch te laten gebeuren. Er werd eerst gebruik gemaakt van het New-PSSession commando maar hier kwam ik op vast te zitten door het plain text wachtwoord.

- Om veiligheidsredenen zou het root wachtwoord van osboxes aangepast moeten worden en moet de ssh verbinding met een private keypair gebeuren.

- Momenteel is er geen DHCP server ingesteld voor de host only interface. Daardoor moet er met port forwarding op de nat interface gewerkt worden voor communicatie met de host en met een intnet interface voor communicatie tussen de VM's onderling.

## Gevolgen van deze exploit
De Unifi controller is software die alle netwerkapparaten van de Unifi lijn van Ubiquiti beheert. Dit betreft switchen, WiFi access points, routers, ... Deze draait wereldwijd op servers, lokale cloudkeys of dreammachine's. Met de Log4J exploit kan een aanvaller toegang krijgen tot de controller en zo alle netwerk instellingen aanpassen.

Wanneer er via de Unifi controller toegang is tot een router zoals de Dreammachine kan een aanvaller Firewall of IDS instellingen aanpassen om zo ook toegang te verschaffen tot andere systemen binnen het netwerk.

## Mitigation
Een voor de hand liggende oplossing is natuurlijk om de controller up te daten naar de nieuwste versie waar de exploit gepatched is. Alle versies na 6.4.54 hebben de Log4J patch.

Daarnaast is het aangeraden om de toegang tot de controller te beperken. Veel netwerk administrators zetten deze open in de firewall om van overal toegang te hebben tot de instellingen. Er bestaan echter enkele manieren om dit op een veilige manier te verwezelijken.

Enerzijds kan er gezorgd worden dat de Unifi controller enkel in het netwerk benaderbaar is. Dit is in veel gevallen echter niet gewenst. Via een VPN kan er wel op een veilige manier verbinding gemaakt worden met het netwerk om zo de controller aan te spreken. Anderzijds kan er als er dan toch poorten in de firewall opengezet moeten worden voor gezorgd worden dat deze enkel verkeer vanaf een vastgelegd IP-adres accepteren.