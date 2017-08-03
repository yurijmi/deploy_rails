#!/bin/bash
echo "Welcome to Deploy Rails!"
echo ""

if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as deploy" 1>&2
   exit 1
fi

read -p "Your app's name in deploy.rb: " app_name
read -p "Ruby version to install (2.4.1):" ruby_ver
ruby_ver=${ruby_ver:-2.4.1}

echo "Installing rvm..."

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm requirements
echo "rvm_trust_rvmrcs_flag=1" >> .rvmrc

echo "Installing ruby..."

curl -o ~/.gemrc https://raw.githubusercontent.com/yurijmi/deploy_rails/master/conf/.gemrc
curl -o ~/.irbrc https://raw.githubusercontent.com/yurijmi/deploy_rails/master/conf/.irbrc

rvm install $ruby_ver
rvm use $ruby_ver --default
rvm rubygems current

echo "Installing bundler..."

gem install bundler

echo "Preparing SSH..."

ssh -T git@github.com
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""

echo "Setting environment variables..."

curl -o /tmp/secret.rb https://raw.githubusercontent.com/yurijmi/deploy_rails/master/secret.rb
secret_key=$(ruby /tmp/secret.rb)
rm /tmp/secret.rb

sed -i "1s/^/export http_${app_name}_secret_key_base=${secret_key}\n/" ~/.bashrc

echo "Copy this to GitHub:"
cat ~/.ssh/id_rsa.pub

echo "Deploy 'em now ;)"

exit
