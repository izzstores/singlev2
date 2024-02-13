#!/bin/bash
clear
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\e[0m'

purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
cd
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [[ -e /etc/debian_version ]]; then
	source /etc/os-release
	OS=$ID # debian or ubuntu
elif [[ -e /etc/centos-release ]]; then
	source /etc/os-release
	OS=centos
fi
localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi
# // Checking Os Architecture
if [[ $( uname -m | awk '{print $1}' ) == "x86_64" ]]; then
    echo -e "${OK} Your Architecture Is Supported ( ${green}$( uname -m )${NC} )"
else
    echo -e "${EROR} Your Architecture Is Not Supported ( ${YELLOW}$( uname -m )${NC} )"
    exit 1
fi
# // Checking System
if [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "ubuntu" ]]; then
    echo -e "${OK} Your OS Is Supported ( ${green}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
elif [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "debian" ]]; then
    echo -e "${OK} Your OS Is Supported ( ${green}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
else
    echo -e "${EROR} Your OS Is Not Supported ( ${YELLOW}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
    exit 1
fi

# // IP Address Validating
if [[ $IP == "" ]]; then
    echo -e "${EROR} IP Address ( ${YELLOW}Not Detected${NC} )"
else
    echo -e "${OK} IP Address ( ${green}$IP${NC} )"
fi

# // Validate Successfull
echo ""
read -p "$( echo -e "Press ${GRAY}[ ${NC}${green}Enter${NC} ${GRAY}]${NC} For Starting Installation") "
function make_folder() {
echo -e " membuat Folder Xray "
mkdir -p /etc/xray
mkdir -p /var/lib/xdxl
mkdir -p /var/log/trojan-go/
mkdir -p "/usr/bin/trojan-go"
mkdir -p "/etc/trojan-go"
mkdir -p /home/vps/public_html
mkdir -p /root/.acme.sh
mkdir -p /var/log/xray
mkdir -p /etc/bot
mkdir -p /etc/xray/limit
mkdir -p /etc/xray/limit/vmess
mkdir -p /etc/xray/limit/vless
mkdir -p /etc/xray/limit/trojan
mkdir -p /etc/xray/limit/ssh
mkdir -p /etc/xray/limit/vmess/ip
mkdir -p /etc/xray/limit/vless/ip
mkdir -p /etc/xray/limit/trojan/ip
mkdir -p /etc/xray/limit/ssh/ip
touch /etc/xray/domain
touch /etc/bot/.bot.db
echo "IP=" >> /var/lib/xdx/ipvps.conf
}
make_folder

secs_to_human() {
    echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

coreselect=''

echo -e "[ ${green}INFO${NC} ] Preparing the install file"
apt install git curl -y >/dev/null 2>&1
apt install python -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Aight good ... installation file is ready"
sleep 2
echo -ne "[ ${green}INFO${NC} ] Check permission : "

sudo apt update -y
sudo apt update -y
sudo apt dist-upgrade -y
sudo apt-get remove --purge ufw firewalld -y 
sudo apt-get remove --purge exim4 -y
sudo apt install -y screen curl jq bzip2 at gzip coreutils rsyslog iftop \
 htop zip unzip net-tools sed gnupg gnupg1 \
 bc sudo apt-transport-https build-essential dirmngr libxml-parser-perl neofetch screenfetch git lsof \
 openssl openvpn easy-rsa fail2ban tmux \
 stunnel4 vnstat squid3 \
 dropbear  libsqlite3-dev \
 socat cron bash-completion ntpdate xz-utils sudo apt-transport-https \
 gnupg2 dnsutils lsb-release chrony
sudo apt install -y libnss3-dev libnspr4-dev pkg-config libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev libcurl4-nss-dev flex bison make libnss3-tools libevent-dev xl2tpd pptpd
sudo apt-get install nodejs -y

/etc/init.d/vnstat restart
wget -q https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc >/dev/null 2>&1 && make >/dev/null 2>&1 && make install >/dev/null 2>&1
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz >/dev/null 2>&1
rm -rf /root/vnstat-2.6 >/dev/null 2>&1

function pasang_domain() {
clear
echo -e "-----------------------------------"
echo -e "Masukan Domain Kamu !"
echo -e "-----------------------------------"
echo " "
read -rp "Input ur domain : " -e pp
if [ -z $pp ]; then
echo -e " Input Dengan Benar !"
pasang_domain
else
echo "$pp" > /etc/xray/domain
echo "$pp" > /root/domain
echo "IP=$pp" > /var/lib/xdxl/ipvps.conf
fi
}
pasang_domain
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "$green      Install SSH / WS               $NC"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
sleep 2
clear
wget https://raw.githubusercontent.com/izzstores/singlev2/SUDEV/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
# install backup
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "$green      Install backup             $NC"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
sleep 2
clear
wget https://raw.githubusercontent.com/izzstores/singlev2/SUDEV/backup/set-br && chmod +x set-br.sh && ./set-br.sh
#Instal Xray
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "$green          Install XRAY              $NC"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
sleep 2
clear
wget https://raw.githubusercontent.com/izzstores/singlev2/SUDEV/xray/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh

cd
wget -O /usr/local/bin/ws-dropbear https://raw.githubusercontent.com/bracoli/v4/main/sshws/dropbear-ws.py
wget -O /usr/local/bin/ws-stunnel https://raw.githubusercontent.com/bracoli/v4/main/sshws/ws-stunnel
chmod +x /usr/local/bin/ws-dropbear
chmod +x /usr/local/bin/ws-stunnel
wget -O /etc/systemd/system/ws-dropbear.service https://raw.githubusercontent.com/bracoli/v4/main/sshws/service-wsdropbear && chmod +x /etc/systemd/system/ws-dropbear.service
wget -O /etc/systemd/system/ws-stunnel.service https://raw.githubusercontent.com/bracoli/v4/main/sshws/ws-stunnel.service && chmod +x /etc/systemd/system/ws-stunnel.service
systemctl daemon-reload
systemctl enable ws-dropbear.service
systemctl start ws-dropbear.service
systemctl restart ws-dropbear.service
systemctl enable ws-stunnel.service
systemctl start ws-stunnel.service
systemctl restart ws-stunnel.service

cd
wget -q https://raw.githubusercontent.com/izzstores/singlev2/SUDEV/xray/menu.zip
unzip menu.zip
chmod +x menu/*
mv menu/* /usr/local/sbin/
rm -rf menu menu.zip

clear
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
menu
END
chmod 644 /root/.profile

if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
if [ ! -f "/etc/log-create-user.log" ]; then
echo "Log All Account " > /etc/log-create-user.log
fi
history -c
echo $serverV > /opt/.ver
aureb=$(cat /home/re_otm)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
curl -sS ifconfig.me > /etc/myipvps
clear
echo " "
echo "=====================-[ PROJECT VPN TUNNELING ]-===================="
echo ""
echo "   >>> Service & Port"
echo "   - OpenSSH		: 22"
echo "   - SSH Websocket	: 80"
echo "   - SSH SSL Websocket	: 443"
echo "   - Stunnel4		: 447, 777"
echo "   - Dropbear		: 109, 143"
echo "   - Badvpn		: 7100-7300"
echo "   - Nginx		: 81"
echo "   - Vmess TLS		: 443"
echo "   - Vmess None TLS	: 80"
echo "   - Vless TLS		: 443"
echo "   - Vless None TLS	: 80"
echo "   - Trojan GRPC		: 443"
echo "   - Trojan WS		: 443"
echo "   - Trojan Go		: 443"
echo "" 
echo "   >>> Server Information & Other Features" 
echo "   - Timezone		: Asia/Jakarta (GMT +7)" 
echo "   - Fail2Ban		: [ON]" 
echo "   - Dflate		: [ON]" 
echo "   - IPtables		: [ON]" 
echo "   - Auto-Reboot		: [ON]" 
echo "   - IPv6			: [OFF]" 
echo "   - Autoreboot On	: $aureb:00 $gg GMT +7"
echo "   - AutoKill Multi Login User"
echo "   - Auto Delete Expired Account"
echo "   - Fully automatic script"
echo "   - VPS settings"
echo "   - Admin Control"
echo "   - Change port"
echo "   - Full Orders For Various Services"
echo ""
echo "===============-[ PROJECT VPN TUNNELING ]-==============="
echo -e ""
echo ""
echo ""
rm /root/main.sh >/dev/null 2>&1
rm /root/ins-xray.sh >/dev/null 2>&1
rm /root/insshws.sh >/dev/null 2>&1
secs_to_human "$(($(date +%s) - ${start}))"
echo -e "
"
echo -ne "[ ${yell}WARNING${NC} ] Do you want to reboot now ? (y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi

