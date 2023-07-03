#!/bin/bash


#################################################################################
# 1. Przygotowanie serwera Ubuntu oraz statyczne parametry sieciowe
apt update && sudo apt upgrade -y

# Sprawdzenie dostepnych i aktywnych interfejsow sieciowych, pomijając interfejs loopback
interfaces=($(ip -o link show | awk '!/^[0-9]+: lo:/ {print $2}' | cut -d':' -f1))

# Wybranie pierwszego aktywnego interfejsu jako domyślny
default_interface="${interfaces[0]}"

# Pobierz nazwę interfejsu od użytkownika lub użyj domyślnego interfejsu
read -p "Podaj nazwę interfejsu sieciowego (domyślnie: $default_interface) ENTER pozostawi domyslny: " user_interface
interface="${user_interface:-$default_interface}"

# Pobranie adresu IP od użytkownika
read -p "Podaj nowy adres IP: " ip_address

# Pobranie maski podsieci od użytkownika
read -p "Podaj maskę podsieci (np. 24): " subnet_mask

# Pobranie adresu bramy od użytkownika
read -p "Podaj adres bramy: " gateway

# Pobranie adres serwera DNS od użytkownika
read -p "Podaj adres serwera DNS: " dns_server

# Tworzenie pliku konfiguracyjnego dla interfejsu sieciowego
echo "network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      addresses: [$ip_address/$subnet_mask]
      routes:
          - to: default
            via: $gateway
      nameservers:
        addresses: [$dns_server]" | sudo tee /etc/netplan/99-static.yaml > /dev/null




# Pobranie nazwy hosta od użytkownika
read -p "Podaj nową nazwę hosta (hostname): " hostname

# Ustawienie nowej nazwy hosta - widoczna bedzie po przelogowaniu
hostnamectl set-hostname "$hostname"

clear
echo "Ustawiono statyczny adres IP: $ip_address/$subnet_mask"
echo "Ustawiono adres IP brany: $gateway"
echo "Ustawiono adres DNS: $dns_server"
echo "Zmieniono nazwę hosta na: $hostname"
echo "Wprowadzono do konfiguracji statyczne parametry sieciowe, naciśnij dowolny klawisz, aby kontynuować..."
# Oczekuj na dowolne naciśnięcie klawisza przez użytkownika
read -n 1 -s -r


#################################################################################
# 2. Instalacja zależności przydatnych dla Cloudstack dla serwera Ubuntu w wersji minimal
apt install -y openntpd openssh-server sudo vim htop tar intel-microcode


#################################################################################
# 3. Pobierz i skonfiguruj CloudStack
mkdir -p /etc/apt/keyrings
wget -O- http://packages.shapeblue.com/release.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/cloudstack.gpg > /dev/null
echo deb [signed-by=/etc/apt/keyrings/cloudstack.gpg] http://packages.shapeblue.com/cloudstack/upstream/debian/4.18 / > /etc/apt/sources.list.d/cloudstack.list
apt-get update -y
apt-get install -y cloudstack-management mysql-server
apt-get install -y cloudstack-usage 


#################################################################################
# 4. Konfiguracja hasła uzytkownika root bazy SQL (domyslnie jest puste)
# Pobierz nowe hasło od użytkownika
read -s -p "Podaj nowe hasło dla użytkownika root w MySQL - PRZECHOWUJ JE BEZPIECZNIE!!: " sqladmin_password
echo
# Zmień hasło dla użytkownika root w MySQL
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$sqladmin_password'; FLUSH PRIVILEGES;"
echo "Hasło dla użytkownika root w MySQL zostało zmienione bedzie uzyte w konfiguracji bazy dla Cloudstack."

# Dopisanie konfiguracji bazy po [mysqld] w pliku konfiguracyjnym
sed -i '/^\[mysqld\]$/a\server_id = 1\nsql-mode="STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,ERROR_FOR_DIVISION_BY_ZERO,NO_ZERO_DATE,NO_ZERO_IN_DATE,NO_ENGINE_SUBSTITUTION"\ninnodb_rollback_on_timeout=1\ninnodb_lock_wait_timeout=600\nmax_connections=1000\nlog-bin=mysql-bin\nbinlog-format = '\''ROW'\''' /etc/mysql/mysql.conf.d/mysqld.cnf

echo "Dopisano konfiguracje bazy cloudstack do pliku konfiguracyjnego."
systemctl restart mysql

# Konfiguracja bazy SQL dla cloudstack w oparciu o wprowadzone haslo root oraz IP hosta
clear
cloudstack-setup-databases cloud:cloud@localhost --deploy-as=root:$sqladmin_password -i $ip_address
echo "Skonfigurowano baze SQL dla Cloudstack, naciśnij dowolny klawisz, aby kontynuować..."
# Oczekuj na dowolne naciśnięcie klawisza przez użytkownika
read -n 1 -s -r

#################################################################################
# 5. Uruchomienie konfiguratora instalacyjnego menedżera chmury CloudStack
clear
cloudstack-setup-management
echo "Skonfigurowano Cloudstack Mgmt Server, naciśnij dowolny klawisz, aby kontynuować..."
# Oczekuj na dowolne naciśnięcie klawisza przez użytkownika
read -n 1 -s -r
# Zakończono instalację Apache CloudStack
clear
echo "Zakończono instalację Apache CloudStack. WebUI znajduje sie pod adresem http://'$ip_address':8080 "
# Wyświetl komunikat
echo "Uruchomi sie polecenie 'netplan apply' z nowymi parametrami sieciowymi, sesja SSH zostanie przerwana"
echo "Naciśnij dowolny klawisz, aby kontynuować..."
# Oczekuj na dowolne naciśnięcie klawisza przez użytkownika
read -n 1 -s -r
netplan apply
