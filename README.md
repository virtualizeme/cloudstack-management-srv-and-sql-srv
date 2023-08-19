# Auto install script Apache Cloudstack Management Server - Ubuntu Server 22.0.4

Skrypt bash do instalacji Apache Cloudstack. Testowane na Ubuntu Server 22.0.4
Skrypt wykonuje polecenia w CLI w celu szybkiej pomocy i wsparcia do instalacji kontrolera zarządzania infrastrukturą chmury Cloudstack.


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
