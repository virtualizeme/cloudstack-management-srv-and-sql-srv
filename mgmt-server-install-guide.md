# Instalacja Apache Cloudstack Management Server (mySQL include) - Ubuntu Server 22.0.4 - dla infrastruktry VMWARE
## zalecam instalację na wersji Ubuntu minimal


### przygotowanie systemu operacyjnego
- zeby proces instalacji byl troche wygodniejszy, w swiezej instalacji Ubuntu nadaj haslo dla konta root `passwd root` jezeli laczysz sie przez `ssh`, zmień w pliku konfiguracyjnym serwisu ssh w `/etc/ssh/sshd_config` mozliwosc zalogowania sie jako root lub zrob to przez wygenerowana pare kluczy

- zainstaluj podstawowe paczki
```
apt-get install openntpd openssh-server sudo vim htop tar
```

- w przypadku instalacji bare metal lub na VM z wlaczonym wsparciem sprzetowym wirtualizacji - jezeli VM jest na vmware to opcjonalnie
```
apt-get install intel-microcode
```

- po swiezej instalacji serwera Ubuntu w wersji 22.0.4 jezeli nie podales statycznego adresu IP podczas instlacji w kreatorze, musisz przejsc do pliku konfiguracjyjnego znajdujacego sie w `/etc/netplan/00-installer-config.yaml`. W przypadku wdrożenia chmury na infrastrukturze VMWARE nie ma konieczności tworzenia nowego pliku `yaml` jezeli w tym folderze znajduje sie tylko ten plik, gdyż nie bedziemy tworzyc konfiguracji bridge i vlan itp. to za nas juz bedzie robic srodowisko wirtualne oparte o VMWARE. Jednak MGMT serwer wymaga statycznego adresu IP, `00-installer-config.yaml` z ustawien DHCP zmieniamy na ponizsze (parametry sa przykladowe dopasuj do swojego srodowiska)
```
network:
  renderer: networkd
  ethernets:
    ens33:
      addresses:
        - 192.168.1.247/24
      nameservers:
        addresses: [4.2.2.2, 8.8.8.8]
      routes:
        - to: default
          via: 192.168.1.1
  version: 2
```
po zapisaniu zmian w pliku
```
netplan generate
netplan apply
reboot
```

### instalacja Apache mgmt server z lokalnym serwerm mySQL

- dodajemy source liste oraz zbior kluczy `apt` w celu potwierdzenia autentycznosci zrodla pobierania paczek do instalacji
```
mkdir -p /etc/apt/keyrings
wget -O- http://packages.shapeblue.com/release.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/cloudstack.gpg > /dev/null
```
- tutaj zwroc uwage na wersje ktora wybierasz, taka zostanie pozniej zainstalowana
```
echo deb [signed-by=/etc/apt/keyrings/cloudstack.gpg] http://packages.shapeblue.com/cloudstack/upstream/debian/4.18 / > /etc/apt/sources.list.d/cloudstack.list
```
- robimy update naszej listy paczek apt
```
apt-get update -y
```
- instalujemy paczki Apache Cloudstack Management Server oraz serwera mySQL
```
apt-get install cloudstack-management mysql-server
```
- dodatkowo po zakonczeniu instalacji powyzszych paczek instalujemy
```
apt-get install cloudstack-usage
```

#### podstawowa konfiguracja serwera mySQL pod Management Server

- przechodzimy do edycji pliku konfiguracyjnego bazy SQL `/etc/mysql/mysql.conf.d/mysqld.cnf` pod linia zawierajaca wpis `[mysqld]` dodajemy ponizsze ustawienia
```
server_id = 1
sql-mode="STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,ERROR_FOR_DIVISION_BY_ZERO,NO_ZERO_DATE,NO_ZERO_IN_DATE,NO_ENGINE_SUBSTITUTION"
innodb_rollback_on_timeout=1
innodb_lock_wait_timeout=600
max_connections=1000
log-bin=mysql-bin
binlog-format = 'ROW'
```
nastepnie wykonujemy restart serwisu bazy `systemctl restart mysql`

- kolejnym krokiem jest polaczenie sie do lokalnej bazy danych w celu utworzenia uzytkownika `cloud` i bazy `cloud` na potrzeby Cloudstack, ale mozesz wprowadzic swoje parametry
UWAGA!!! mySQL po swiezej instalacji posiada konto administratora bazy `root`(nie mylic z `root` twojego systemu ubuntu) z pustym haslem, wystarczy dokonac pierwszego logowania do bazy zeby ustawic haslo dla konta root twojej bazy
```
cloudstack-setup-databases cloud:cloud@localhost --deploy-as=root:<root haslo, domyslnie puste> -i <adres ip serwera mgmt>
```
- uruchamianie Apache Cloudstack Management Server
```
cloudstack-setup-management
```
- sprawdzenie czy serwis wstal bez bledow
```
systemctl status cloudstack-management
```
- tutaj mozesz na zywo patrzec logi co sie dzieje z serwisem, przydatne kiedy podlaczasz infrastrukture ktora Cloudstack ma zarzadzac - bez wzgledu czy to KVM czy VMWARE
```
tail -f /var/log/cloudstack/management/management-server.log
```
### Twoja pierwsza chmura zostala uruchomiona pod adresem IP twojego Cloudstack MGMT Serwera
### `http://192.168.1.10(i.e. twojego interfejsu mgmt):8080/client`
### domyslne kredki: login `admin` pass `password`



🔗 **Find me elsewhere**
- [GitHub](https://github.com/virtualizeme)
- [YouTube](https://www.youtube.com/@virtualizeMe)

