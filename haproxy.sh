# shell script to setup HAProxy server with roundrobin algorythm in Rocky linux
#!/bin/bash

# Update system
sudo yum update -y

# install Haproxy packege
sudo yum install haproxy -y 

# stop haproxy service
sudo systemctl stop haproxy

# configure haproxy.conf file
cd /etc/haproxy
sudo mv haproxy.cfg haproxy.cfg.backup

# add configuration
sudo bash -c 'cat <<EOT >> /etc/haproxy/haproxy.cfg
global
   log /dev/log local0
   log /dev/log local1 notice
   chroot /var/lib/haproxy
   stats timeout 30s
   user haproxy
   group haproxy
   daemon

defaults
   log global
   mode http
   option httplog
   option dontlognull
   timeout connect 5000
   timeout client 50000
   timeout server 50000

frontend http_front
   bind *:80
   stats uri /haproxy?stats
   default_backend http_back

backend http_back
   balance roundrobin
   server server_name1 192.168.116.144:8080 check
   server server_name2 192.168.116.145:80 check
EOT'


# test haproxy configuration
sudo haproxy -f /etc/haproxy/haproxy.cfg -c

# start haproxy service 
sudo systemctl start haproxy

echo "Completed"
