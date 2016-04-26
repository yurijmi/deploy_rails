#!/bin/bash
echo "Welcome to Deploy Rails!\n"

if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as deploy" 1>&2
   exit 1
fi

read -p "Your app's name in deploy.rb: " app_name

echo "Installing rvm..."

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm requirements

echo "Installing ruby..."

wget https://raw.githubusercontent.com/yurijmi/deploy_rails/master/conf/.gemrc ~/.gemrc

rvm install 2.3.0
rvm use 2.3.0 --default
rvm rubygems current

echo "Installing gems..."

gem install rails bundler paperclip puma
gem install pg -- --with-pg-config=/usr/bin/pg_config

echo "Preparing SSH..."

ssh -T git@github.com
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""

echo "Setting environment variables..."

secret_key=$(rake secret)

sed -i '1s/^/export http_${app_name}_secret_key_base=${secret_key}\n/' ~/.bashrc

echo "Copy this to GitHub:"
cat ~/.ssh/id_rsa.pub

echo "Deploy 'em now ;)"

exit
