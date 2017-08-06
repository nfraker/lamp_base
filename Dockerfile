FROM ubuntu:latest
MAINTAINER Nick Fraker <nickdontspam@gmail.com>

# Setup environment
EXPOSE 80 443
CMD ["/bin/sh", "-c", "/startup.sh"]
ENV TERM=xterm LANG=C.UTF-8 

# Update & install
RUN apt-get update -y &&\ 
DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common &&\
add-apt-repository ppa:ondrej/php -y &&\
apt-get update -y && \
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 \
                   libapache2-mod-php5.6 \
                   php5.6 \
                   php5.6-mcrypt \
                   php5.6-mysql \
                   php5.6-gd \
                   php5.6-curl \
                   php5.6-dev \
                   php5.6-memcache \
                   php5.6-pspell \
                   php5.6-snmp \
                   php5.6-mbstring \
                   php5.6-dom \
                   php5.6-xmlrpc \
                   php5.6-cli \
                   snmp \
                   vim \
                   bash-completion \
                   mysql-client \
                   mysql-server \
                   supervisor \
                   passwd \
                   composer \
                   unzip &&\
apt-get clean &&\

ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load &&\
unlink /etc/apache2/mods-enabled/autoindex.load &&\
sed -i 's/Options.*/Options FollowSymLinks/g' /etc/apache2/apache2.conf &&\
sed -i 's/AllowOverride.*/AllowOverride All/g' /etc/apache2/apache2.conf &&\

# Start services
echo "service networking start && service mysql start && exec apache2ctl -D FOREGROUND" > /startup.sh &&\
chmod +x /startup.sh &&\
mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 &&\
chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 &&\

# Force resolv.conf
echo "nameserver 172.17.0.1" > /etc/resolv.conf &&\
echo "nameserver 8.8.8.8" >> /etc/resolv.conf &&\
echo "nameserver 8.8.4.4" >> /etc/resolv.conf &&\

# Fix some problematic MySQL configs
rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld && \
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
chmod 777 /var/run/mysqld && \
sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf && \
mysqld --initialize-insecure && \

echo "UPDATE mysql.user SET Host='%' ; FLUSH PRIVILEGES ;" > /tmp/fix.sql && \
mysql -u root << /tmp/fix.sql && \
rm /tmp/fix.sql && \

# Forward Apache logs to stdout
ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
ln -sf /proc/self/fd/1 /var/log/apache2/error.log

# Put this at the end due to how Docker locks mounted volumes
VOLUME /var/lib/mysql
