# Przygotowanie serwera NFS dla Cloudstack Management Server - testowane na ubuntu server 22.0.4
- Serwer NFS, może być na lokalnej maszynie gdzie CS MGMT Srv, jednak zalecam przygotować osobną maszyne
- Jezeli zamierzamy pobierac, udostepniac, wysylac szablony (templates OVA,OVF), ISO, repliki (z poziomu vmware czy API CS) wieksze niz 50G zalecam dopilnowac zeby virtualna maszyna lub fizyczny serwer NFS posiadały przepustowosc na karcie sieciowej 10Gbit
- Jezeli nie mamy powyzszych mozliwosci w CS MGMT SRV w global settings wyszukajcie `full clone` i ustawcie `false`

## Instalacja serwera NFS:

- Instalacja paczek na potrzeby uruchomienia serwera NFS
```
apt-get install nfs-kernel-server quota
```

- Tworzenie eksportu tj. folderu który bedzie udostepniony przez NFS:
```
echo "/export  *(rw,async,no_root_squash,no_subtree_check)" > /etc/exports
mkdir -p /export/primary /export/secondary
exportfs -a
```

- Podstawowa konfiguracja i restart serwera NFS:
```
sed -i -e 's/^RPCMOUNTDOPTS="--manage-gids"$/RPCMOUNTDOPTS="-p 892 --manage-gids"/g' /etc/default/nfs-kernel-server
sed -i -e 's/^STATDOPTS=$/STATDOPTS="--port 662 --outgoing-port 2020"/g' /etc/default/nfs-common
echo "NEED_STATD=yes" >> /etc/default/nfs-common
sed -i -e 's/^RPCRQUOTADOPTS=$/RPCRQUOTADOPTS="-p 875"/g' /etc/default/quota
service nfs-kernel-server restart
```

🔗 **Find me elsewhere**
- [GitHub](https://github.com/virtualizeme)
- [YouTube](https://www.youtube.com/virtualizeme)
