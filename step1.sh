#!/bin/sh
echo "Welcome to Deploy Rails!\n"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

read -p "Your app's name in deploy.rb: " app_name

read -p "Account for deploy (deploy): " deploy_user
deploy_user=${deploy_user:-deploy}

read -p "That account's password: " deploy_password

read -p "Your public SSH key for login: " ssh_key

echo "Installing software..."
apt-get install sudo git-core curl wget nginx postgresql postgresql-server-dev-9.4 imagemagick nodejs gawk g++ gcc make libc6-dev libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgmp-dev libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev -y

echo "Adding a deploy account..."

useradd -m -p $(echo $deploy_password | openssl passwd -1 -stdin) $deploy_user
adduser $deploy_user sudo

echo "Installing ssh keys..."

echo $ssh_key >> ~/.ssh/authorized_keys
runas -l  $deploy_user -c 'echo $ssh_key >> ~/.ssh/authorized_keys'

echo "Creating role and db in postgres..."

database_password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};)

sudo -u postgres -H -- psql -c "create user $app_name with password '$database_password'; create database ${app_name}_production owner $app_name;"

sed -i '1s/^/export http_${app_name}_database_password=${database_password}\n/' /home/$deploy_user/.bashrc

echo "Creating directory for deploy..."

mkdir /var/www/$app_name
chown $deploy_user:$deploy_user /var/www/$app_name

echo "Updating configs..."

rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default
service nginx restart

rm /etc/ssh/sshd_config
wget https://raw.githubusercontent.com/yurijmi/deploy_rails/master/conf/sshd_config /etc/ssh/sshd_config
service ssh restart

rm /etc/postgresql/9.4/main/pg_hba.conf
wget https://raw.githubusercontent.com/yurijmi/deploy_rails/master/conf/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
service postgresql restart

echo "Run this as $deploy_user: \curl -sSL https://raw.githubusercontent.com/yurijmi/deploy_rails/master/step2.sh | bash -s"

exit
