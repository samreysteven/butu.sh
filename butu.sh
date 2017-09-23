#!/bin/sh
 
rpm -Uih https://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
curl -L https://get.rvm.io | bash -s stable
rvm install 2.0.0
rvm use 2.0.0@global --default
 
# for chinese user, if you have a wonderful speed ignore this part
# to have a faster download speed
# switch gem source to ruby.taobao.org
# see http://ruby.taobao.org/ for more
gem source -r https://rubygems.org/
gem source -a http://ruby.taobao.org/
gem sources -l
 
### install bundler and rails
gem install bundler
gem install rails
 
### install dep-packages
yum -y update
yum -y install wget curl gcc libxml2-devel libxslt-devel make openssh-server libyaml-devel postfix libicu-devel libcurl-devel libcurl readline-devel readline glibc glibc-devel openssl-devel openssl mysql++-devel postgresql-devel zlib-devel git
yum -y install redis
yum -y install mysql-devel mysql-server mysql
yum -y install nginx
 
chkconfig nginx on
chkconfig mysqld on
chkconfig redis on
 
### start redis server
### otherwise the `Background Jobs` page says "Internal Server Error"
service redis start
 
### mysql
service mysqld start
/usr/bin/mysql_secure_installation

 
### add user
mysql -u root -p
CREATE DATABASE IF NOT EXISTS `gitlab_ci_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
CREATE USER 'gitlab_ci'@'localhost' IDENTIFIED BY '${PASSWORD}';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlab_ci_production`.* TO 'gitlab_ci'@'localhost';
 
### user gitlab_ci
useradd --comment 'GitLab CI' -m gitlab_ci
 
### get gitlab-ci
cd /home/gitlab_ci/
git clone https://github.com/gitlabhq/gitlab-ci.git
cd gitlab-ci
 
### prepare
git checkout 2-2-stable
mkdir -p tmp/pids
mkdir -p tmp/sockets
chmod -R 755 tmp/
 
### AGAIN for chinese users.
### modify Gemfile.
### change the first line `source ...` into
### `source 'http://ruby.taobao.org/'`
vim Gemfile
 
### install
bundle --without development test
 
### database config
cp config/database.yml.mysql config/database.yml
vim config/database.yml
# - change the username and password for mysql user gitlab_ci
 
bundle exec rake db:setup RAILS_ENV=production
 
### install crontab job for user gitlab_ci
su gitlab_ci
bundle exec whenever -w RAILS_ENV=production
exit
 
### the service script
### ### ATTENSION ###
### gitlab-ci must start up after mysql and redis
### 
### so if you found gitlab_ci service starts BEFORE mysql or redis.
### please check mysql and redis service and change the start order of service gitlab_ci
###
### for example, insert this in startup script to the second line:
### `# chkconfig: - 70 30`
###
### then `chkconfig --del gitlab_ci; chkconfig -add gitlab_ci`
 
wget https://raw.github.com/gitlabhq/gitlab-ci/2-2-stable/lib/support/init.d/gitlab_ci -P /etc/init.d/
chmod +x /etc/init.d/gitlab_ci
chkconfig gitlab_ci on
 
### give the permissions back to user gitlab_ci
chown -R gitlab_ci:gitlab_ci /home/gitlab_ci
 
### nginx config
cd /etc/nginx
mkdir sites-available sites-enabled
sudo wget https://raw.github.com/gitlabhq/gitlab-ci/2-2-stable/lib/support/nginx/gitlab_ci -P /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/gitlab_ci /etc/nginx/sites-enabled/gitlab_ci
vim /etc/nginx/sites-available/gitlab_ci
# - change the server_name of this server
# - dont forget delete default_server after `listen 80`
service nginx start
 
### disable user gitlab_ci login
usermod -s /sbin/nologin gitlab_ci
 
### make sure user `gitlab_ci` can execute commands by sudo without tty started
### because the init.d script needs `sudo -u gitlab_ci ...` to launch
### replace `Defaults    requiretty` by this line in file `/etc/sudoers`:
### `Defaults:gitlab_ci !requiretty`


# info
echo -e "\e[0;35m---------------------info ByJack-------------------------"
echo " "
echo -e "\e[0;35m    >>>>> Login Panel By Your IP Only <<<<<\e[0;0m"
echo ""
echo "            Database Host: Jack localhost"
echo ""
echo "            Database Name: Jack"
echo ""
echo "            Database User: JackComunity"
echo ""
echo "            Database Pass: xxxXxxx"
echo ""
echo -e "\e[0;35m---------------------info ByJack-------------------------"
echo "Service Autoscript Created By jack"  | tee -a log-install.txt
echo "-----------------------------------------"  | tee -a log-install.txt
echo "Telegram Channel : http://telegram.me/TICGH "  | tee -a log-install.txt
echo "SySteM CreaTeD bY Jack Freemiumm OpLovers " | tee -a log-install.txt
echo "Download client at http://$myip/client.tar"  | tee -a log-install.txt
echo "Webmin     : http://$myip:10000 " | tee -a log-install.txt
echo "Squid3     : 80, 8000, 8080, 3128"  | tee -a log-install.txt
echo "OpenSSH    : 22, 143"  | tee -a log-install.txt
echo "Dropbear   : 109, 110, 443"  | tee -a log-install.txt
echo "Timezone   : Asia/Kuala_Lumpur"  | tee -a log-install.txt
echo "Fail2Ban :          [on]"   | tee -a log-install.txt
echo "Anti Doss :         [on]"   | tee -a log-install.txt
echo "Anti Retorrent :    [on]"   | tee -a log-install.txt
echo "Root Hunter :       [on]"  | tee -a log-install.txt
echo "VPS AutoRestart: 12.00am"   | tee -a log-install.txt
echo " [ Unsupported Operating System ]" | tee -a log-install.txt
echo "[ A   U   T   O  -  E   X   I   T ]" | tee -a log-install.txt
echo "   [ SMS/Telegram/freemiumm ]" | tee -a log-install.txt
echo "----------------------------------------"
echo "------Thank you for choice us--------"
echo "========================================"  | tee -a log-install.txt
echo "      PLEASE REBOOT TAKE EFFECT !"
echo "========================================"  | tee -a log-install.txt
cat /dev/null > ~/.bash_history && history -c
rm -f /root/iplist.txt

rm -f /root/update

rm -f /root/debian7latest.sh

rm -f /root/debian7latest.sh.x

rm -f /root/ddos-deflate-master.zip

rm -f /root/.bash_history && history -c
