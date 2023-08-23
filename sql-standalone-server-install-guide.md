# Instalacja serwera mySQL dla Apache Cloudstackl jako autonomicznego serwisu na potrzeby Cloudstack - Ubuntu Server 22.0.4

## przygotowanie ubuntu server jako serwera mySQL dla Apache Cloudstack Managament Server
- instlacja paczek, podobnie jak w cloudstack managament server
```
apt-get install openntpd openssh-server sudo vim htop tar
```
```
apt-get install intel-microcode
```
- zmiany w pliku `/etc/hostname` w mgmt server oraz sql server np. cs-mgmt oraz sql-cs
- zmiany w pliku `/etc/hosts` w mgmt server oraz sql server ze wskazaniem rozwiazania nazwy, przykladowo dla `192.168.100.10` dla nazwy `cs-mgmt` oraz `192.168.100.11` dla nazwy `sql-cs`
- instalacja paczki mysql
```
apt-get install mysql-server
```
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

- logujemy sie jako root systemu ubuntu do swojej bazy wykonujac polecenie `mysql`
- nastepnie musimy tworzyc nadac uprawnienia dla naszego przyszlego uzytkownika ktorym bedziemy laczyc sie z cloudstack managament server gdzie ponizej wskazujemy rowniez hosta ktory bedzie sie laczyc tym uzytkownikiem do podlaczenia z baza danych
```
CREATE USER 'cloud'@'cs-mgmt' IDENTIFIED BY 'twoje_haslo';
```
nadajemy uprawnienia stworzonemu uzytkownikowi bazy do konkretnej bazy `cloud` i wszystkich jej rekordow `.*`
```
GRANT ALL PRIVILEGES ON cloud.* TO 'cloud'@'cs-mgmt';
```
zatwierdzamy uprawnienia
```
FLUSH PRIVILEGES;
```
wychodzimy z bazy
```
exit;
```

## Podlaczenie Apache Cloudstack Managament Server do osobnego mySQL server
```
cloudstack-setup-databases cloud:cloud@cs-mgmt --deploy-as=cloud:<haslo wprowadzone przy tworzenia usera bazy> -i <adres ip serwera mgmt>
```
- uruchamianie Apache Cloudstack Management Server
```
cloudstack-setup-management
```


🔗 **Find me elsewhere**
- [GitHub](https://github.com/virtualizeme)
- [YouTube](https://www.youtube.com/@virtualizeMe)
