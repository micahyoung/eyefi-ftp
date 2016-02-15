#!/bin/bash

LISTEN_PORT=${LISTEN_PORT:?"LISTEN_PORT must be set"}
PASV_IP=${EYEFI_IP:?"EYEFI_IP must be set"}
PASV_MIN_PORT=${PASV_MIN_PORT:?"PASV_MIN_PORT must be set"}
PASV_MAX_PORT=${PASV_MAX_PORT:?"PASV_MAX_PORT must be set"}
EYEFI_USERNAME=${EYEFI_USERNAME:?"EYEFI_USERNAME must be set"}
EYEFI_PASSWORD=${EYEFI_PASSWORD:?"EYEFI_PASSWORD must be set"}
EYEFI_DIR=${EYEFI_DIR:?"EYEFI_DIR must be set"}

useradd -d $EYEFI_DIR -p `openssl passwd -1 $EYEFI_PASSWORD` -s /bin/sh $EYEFI_USERNAME 

mkdir -p /var/run/vsftpd/empty
touch /var/log/vsftpd.log

cat > /etc/vsftpd.conf << EOF
listen=YES
listen_port=$LISTEN_PORT
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
log_ftp_protocol=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/private/vsftpd.pem
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
debug_ssl=YES
force_dot_files=YES
pasv_enable=YES
pasv_address=$PASV_IP
pasv_min_port=$PASV_MIN_PORT
pasv_max_port=$PASV_MAX_PORT
pasv_promiscuous=NO
port_enable=YES
port_promiscuous=NO
require_ssl_reuse=NO
EOF

mkdir /etc/vsftpd
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/CN=US" \
  -keyout /etc/ssl/private/vsftpd.pem \
  -out /etc/ssl/private/vsftpd.pem

tail -f /var/log/vsftpd.log &
/usr/sbin/vsftpd
