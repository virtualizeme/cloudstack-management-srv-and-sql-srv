#!/bin/bash
set -e

prepare_network() {
    apt update && apt upgrade -y

    local interfaces=($(ip -o link show | awk '!/^[0-9]+: lo:/ {print $2}' | cut -d':' -f1))
    local default_interface="${interfaces[0]}"
    read -p "Podaj nazwę interfejsu sieciowego (domyślnie: $default_interface) ENTER pozostawi domyslny: " user_interface
    interface="${user_interface:-$default_interface}"

    read -p "Podaj nowy adres IP: " ip_address
    read -p "Podaj maskę podsieci (np. 24): " subnet_mask
    read -p "Podaj adres bramy: " gateway
    read -p "Podaj adres serwera DNS: " dns_server

    cat > /etc/netplan/99-static.yaml << EOF
network:
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
        addresses: [$dns_server]
EOF

    read -p "Podaj nową nazwę hosta (hostname): " hostname
    hostnamectl set-hostname "$hostname"
}

install_dependencies() {
    apt install -y openntpd openssh-server sudo vim htop tar intel-microcode
}

setup_cloudstack() {
    mkdir -p /etc/apt/keyrings
    wget -O- http://packages.shapeblue.com/release.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/cloudstack.gpg > /dev/null
    echo deb [signed-by=/etc/apt/keyrings/cloudstack.gpg] http://packages.shapeblue.com/cloudstack/upstream/debian/4.18 / > /etc/apt/sources.list.d/cloudstack.list
    apt-get update -y
    apt-get install -y cloudstack-management mysql-server cloudstack-usage 
}

configure_sql() {
    read -s -p "Podaj nowe hasło dla użytkownika root w MySQL - PRZECHOWUJ JE BEZPIECZNIE!!: " sqladmin_password
    echo
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$sqladmin_password'; FLUSH PRIVILEGES;"
    
    sed -i '/^\[mysqld\]$/a\server_id = 1\nsql-mode="STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,ERROR_FOR_DIVISION_BY_ZERO,NO_ZERO_DATE,NO_ZERO_IN_DATE,NO_ENGINE_SUBSTITUTION"\ninnodb_rollback_on_timeout=1\ninnodb_lock_wait_timeout=600\nmax_connections=1000\nlog-bin=mysql-bin\nbinlog-format = '\''ROW'\''' /etc/mysql/mysql.conf.d/mysqld.cnf

    systemctl restart mysql
    cloudstack-setup-databases cloud:cloud@localhost --deploy-as=root:$sqladmin_password -i $ip_address
}

main() {
    prepare_network
    install_dependencies
    setup_cloudstack
    configure_sql
    cloudstack-setup-management
    netplan apply
}

main
