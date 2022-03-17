#!/bin/bash

# Install required packages
yum update -y
amazon-linux-extras install epel -y
yum install yum-plugin-copr -y

yum -y install gcc libpcap-devel pcre-devel libyaml-devel file-devel \
  zlib-devel jansson-devel nss-devel libcap-ng-devel libnet-devel tar make \
  libnetfilter_queue-devel lua-devel libmaxminddb-devel rustc cargo \
  lz4-devel llvm11 elfutils-libelf-devel libbpf-devel jq tmux

pip3 install pyyaml

cd /tmp/
curl -sL https://openinfosecfoundation.org/download/suricata-6.0.4.tar.gz -o suricata.tar.gz
tar -xvzf suricata.tar.gz
cd suricata-*

sed -i 's:/sbin/:/bin/:' etc/suricata.service.in
sed -r -i 's:#(EnvironmentFile=-/etc/sysconfig/suricata):\1:' etc/suricata.service.in

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
  --enable-nfqueue --enable-lua --enable-geoip \
  --enable-http2-decompression --enable-ebpf

make && make install-full
ldconfig

# enable suricata service
cp ./etc/suricata.service /etc/systemd/system/
systemctl enable suricata

cd /tmp && rm -rf suricata-*

# Add source and run suricata-update
suricata-update enable-source et/open
suricata-update

# Start suricata
sed -r -i 's:(- flow):#\1:1'  /etc/suricata/suricata.yaml
echo "OPTIONS=-i eth0 udp port 4789" > /etc/sysconfig/suricata
systemctl start suricata.service

# Add ec2-user to suricata group
usermod -a -G suricata ec2-user
usermod -a -G suricata ssm-user

# Add read-write permissions to /var/log/suricata and /var/lib/suricata
chmod -R g+rw /var/log/suricata/
chmod -R g+rw /var/lib/suricata/

# cron and logrotate
cat <<EOF > /etc/logrotate.d/suricata
/var/log/suricata/*.log
/var/log/suricata/*.json
{
    rotate 1
    missingok
    compress
    nodelaycompress
    hourly
    maxsize 1k
    create
    notifempty
    nosharedscripts
    lastaction
            /bin/kill -HUP \$(cat /var/run/suricata.pid 2>/dev/null) 2>/dev/null || true
    endscript
}
EOF
mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
systemctl restart crond
echo "0 */12 * * * suricata-update --reload-command 'suricatasc -c ruleset-reload-nonblocking'" >> /tmp/suricron
crontab /tmp/suricron
rm /tmp/suricron

# Health checks
yum install libmaxminddb -y
yum install httpd -y

# Add index.html for health check
touch /var/www/html/index.html
cat <<EOT >> /var/www/html/index.html
<html>
  <head>
    <title>Amazon Traffic Mirror</title>
  </head>
  <body bgcolor=black>
  </body>
</html>
EOT

systemctl enable httpd
systemctl start httpd

yum remove zlib-devel pcre2-devel make gcc sqlite-devel \
  openssl-devel libevent-devel systemd-devel \
  file-devel glibc-devel jansson-devel keyutils-libs-devel \
  krb5-devel libcap-ng-devel libcom_err-devel libmaxminddb-devel \
  libnet-devel libnetfilter_queue-devel libnfnetlink-devel \
  libpcap-devel libselinux-devel libsepol-devel libverto-devel \
  libyaml-devel lua-devel lz4-devel nspr-devel nss-devel nss-softokn-devel \
  nss-softokn-freebl-devel nss-util-devel pcre-devel python-devel \
  cryptsetup rust llvm11 perl rpcbind postfix -y
