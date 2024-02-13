#!/bin/bash
clear
figlet "Restore" | lolcat
echo "This Feature Can Only Be Used According To Vps Data With This Autoscript"
echo "Please input link to your vps data backup file."
echo "You can check it on your email if you run backup data vps before."
read -rp "Link File: " -e url
wget -O backup.zip "$url"
unzip backup.zip
rm -f backup.zip
sleep 1
echo Start Restore

cp passwd /etc/
cp group /etc/
cp shadow /etc/
cp gshadow /etc/
cp -r xray /etc/xray
cp -r nsdomain /etc/
cp -r slowdns /etc/slowdns
cp -r vps/public_html /etc/public_html
strt
rm -rf /root/backup
rm -f backup.zip
echo "Restore Berhasil!!!" | lolcat
sleep 2 
reboot
