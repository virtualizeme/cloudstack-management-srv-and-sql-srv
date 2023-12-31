# Auto install script and Guide to install Apache Cloudstack Management Server on Ubuntu Server 22.0.4

![Logo](https://github.com/virtualizeme/auto-install-script-cloudstack-management-srv/blob/main/small-scale-deployment.webp)

Skrypt bash do instalacji Apache Cloudstack. Testowane na Ubuntu Server 22.0.4
Skrypt wykonuje polecenia w CLI w celu szybkiej pomocy i wsparcia do instalacji kontrolera zarządzania infrastrukturą chmury Cloudstack.

## Spis treści
* [Instalacja Apache Cloudstack Mgmt Server - step by step](https://github.com/virtualizeme/cloudstack-management-srv/blob/main/mgmt-server-install-guide.md)
* [Instalacja samodzielnego serwera SQL dla Apache Cloudstack Mgmt Server - step by step](https://github.com/virtualizeme/cloudstack-management-srv/blob/main/sql-standalone-server-install-guide.md)
* [Instalacja NFS Server - na potrzeby secondary storage dla Apache Cloudstack](https://github.com/virtualizeme/auto-install-script-cloudstack-management-srv/blob/main/nfs-server-secondary-storage-install.md)

## Użycie

* Pobierz plik `cloudstack-installer-ubuntu.sh` z repozytorium

```bash
  wget https://github.com/virtualizeme/apache_cloudstack/blob/main/cloudstack-installer-ubuntu.sh
```

* nadaj uprawnienia do wykonywania dla skryptu

```bash
  chmod +x cloudstack-installer-ubuntu.sh

```


* Możesz uruchomić skrypt używając `sudo` jako zwykly user z uprawnieniami lub jako root

```bash
  sudo ./cloudstack-installer-ubuntu.sh
```
lub
```bash
  ./cloudstack-installer-ubuntu.sh
```
## Roadmap

- Podzielenie skryptu na grupy wykonywania poprzez `menu` wyboru

- Możliwość jednorazowej instalacji Cloudstack oraz serwera NFS lokalnie lub zdalnie na wskazanym przez użytkownika serwerze
- Możliwość podania jednorazowo parametrów swojego środowiska vCenter i poprzez Cloudmonkey CLI do Cloudstack 

🔗 **Find me elsewhere**
- [GitHub](https://github.com/virtualizeme)
- [YouTube](https://www.youtube.com/@virtualizeMe)
