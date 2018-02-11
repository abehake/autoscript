#!/bin/bash
#
# Original script by AAPOO
# Modified by Hake
# =================================

# update
apt-get update

# upgrade
apt-get upgrade -y  -q

# install certificates
apt-get install ca-certificates

# install figlet
apt-get install figlet

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# detail
country=ID
state=Terengganu
locality=.
organization=.
organizationalunit=.
commonname=Hake
email=.

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/abehake/script/master/sources.list.debian7"
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# update
apt-get update

# install webserver
apt-get -y install nginx

# install essential package
apt-get -y install nano iptables dnsutils openvpn screen whois ngrep unzip unrar

# install neofetch
echo "deb http://dl.bintray.com/dawidd6/neofetch jessie main" | sudo tee -a /etc/apt/sources.list
curl -L "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" -o Release-neofetch.key && sudo apt-key add Release-neofetch.key && rm Release-neofetch.key
apt-get update
apt-get install neofetch

echo "clear" >> .bashrc
echo echo -e ================================================= >> .bashrc
echo 'figlet -k "<AAPOO>"' >> .bashrc
echo echo -e ================================================= >> .bashrc
echo 'echo -e "● Selamat datang ke autoscript AAPOO"' >> .bashrc
echo 'echo -e "● Credit to Hake"' >> .bashrc
echo 'echo -e "● Taip Menu"' >> .bashrc
echo echo -e ------------------------------------------------- >> .bashrc
echo 'echo -e ""' >> .bashrc

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/abehake/script/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by Hake</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/abehake/script/master/vps.conf"
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "https://raw.githubusercontent.com/abehake/script/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/abehake/script/master/1194.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables_yg_baru_dibikin.conf
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/abehake/script/master/iptables"
chmod +x /etc/network/if-up.d/iptables
service openvpn restart

# konfigurasi openvpn
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn "https://raw.githubusercontent.com/abehake/script/master/client-1194.conf"
sed -i $MYIP2 /etc/openvpn/client.ovpn;
cp client.ovpn /home/vps/public_html/

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/abehake/script/master/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/abehake/script/master/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# setting port ssh
cd
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 443 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# blockir torrent
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 1024:65534 -j DROP
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP


# install fail2ban
apt-get -y install fail2ban;
service fail2ban restart

# install squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/abehake/script/master/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
wget -O webmin-current.deb "http://www.webmin.com/download/deb/webmin-current.deb"
dpkg -i --force-all webmin-current.deb;
apt-get -y -f install;
rm /root/webmin-current.deb
service webmin restart

# install ddos deflate
apt-get -y install dnsutils dsniff
wget https://raw.githubusercontent.com/abehake/script/master/ddos-deflate-master.zip
unzip ddos-deflate-master.zip
cd ddos-deflate-master
./install.sh

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
pid = /stunnel.pid
client = no	
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 442
connect = 127.0.0.1:443
connect = 127.0.0.1:109
connect = 127.0.0.1:110
connect = 127.0.0.1:80

;[squid]
;accept = 8080
;connect = 127.0.0.1:3128
END

#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

#konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

# download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/abehake/script/master/menu.sh"
wget -O new "https://raw.githubusercontent.com/abehake/script/master/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/abehake/script/master/trial.sh"
wget -O delete "https://raw.githubusercontent.com/abehake/script/master/hapus.sh"
wget -O login "https://raw.githubusercontent.com/abehake/script/master/user-login.sh"
wget -O dropbear "https://raw.githubusercontent.com/abehake/script/master/userlimit.sh"
wget -O ssh "https://raw.githubusercontent.com/abehake/script/master/userlimitssh.sh"
wget -O list "https://raw.githubusercontent.com/abehake/script/master/user-list.sh"
wget -O resvis "https://raw.githubusercontent.com/abehake/script/master/resvis.sh"
wget -O speedtest "https://raw.githubusercontent.com/abehake/script/master/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/abehake/script/master/info.sh"
wget -O about "https://raw.githubusercontent.com/abehake/script/master/about.sh"

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x new
chmod +x trial
chmod +x delete
chmod +x login
chmod +x dropbear
chmod +x ssh
chmod +x list
chmod +x resvis
chmod +x speedtest
chmod +x info
chmod +x about

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
service nginx start
service openvpn restart
service cron restart
service ssh restart
service stuunel4 restart
service dropbear restart
service squid3 restart
service fail2ban restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Autoscript AAPOO:" | tee log-install.txt
echo "==========================================="  | tee -a log-install.txt
echo "|                [Service]"  | tee -a log-install.txt
echo "|------------------------------------------"  | tee -a log-install.txt
echo "|● OpenSSH   : 22, 143"  | tee -a log-install.txt
echo "|● Dropbear  : 80, 443"  | tee -a log-install.txt
echo "|● Ssl       : 443"  | tee -a log-install.txt
echo "|● Squid3    : 8080, 3128 (limit to IP SSH)"  | tee -a log-install.txt
echo "|● OpenVPN   : TCP 1194"  | tee -a log-install.txt
echo "|● config vpn: http://$MYIP:81/client.ovpn)"  | tee -a log-install.txt
echo "|● badvpn    : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "|● nginx     : 81"  | tee -a log-install.txt
echo "|● Webmin    : http://$MYIP:10000"  | tee -a log-install.txt
echo "|● Timezone  : Asia/Kuala Lumpur (GMT +8)"  | tee -a log-install.txt
echo "|● IPv6      : [off]"  | tee -a log-install.txt
echo "-------------------------------------------"  | tee -a log-install.txt
echo "|● Fail2ban"  | tee -a log-install.txt
echo "|● Ddos Deflate"  | tee -a log-install.txt
echo "|● BlockirTorrent"  | tee -a log-install.txt
echo "|● VPS AUTO REBOOT PADA PUKUL 12 MALAM"  | tee -a log-install.txt
echo "-------------------------------------------"  | tee -a log-install.txt
echo "|● AUTOSCRIPT AAPOO by HAKE"  | tee -a log-install.txt
echo "|● Channel (https://telegram.me/Interpass)"  | tee -a log-install.txt
echo "|● Log Instalasi --> /root/log-install.txt"  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
cd
rm -f /root/debian7.sh
