# Deploy Rails
A set of scripts for preparing a VDS for rails app deploy

## How To

On a fresh machine:

1. SSH as root
2. ```apt-get install curl```
3. ```bash <(curl -s https://raw.githubusercontent.com/yurijmi/deploy_rails/master/step1.sh)```
4. Follow the script
5. SSH as deploy or whatever you've chosen
6. ```bash <(curl -s https://raw.githubusercontent.com/yurijmi/deploy_rails/master/step2.sh)```
7. You're awesome and good to go!

## Environmental variables

Don't forget to change your environmental variables in ```secrets.yml``` and ```database.yml```.

```<%= ENV.fetch('http_%APP_NAME%_database_password') %>``` for ```database.yml```

```<%= ENV.fetch('http_%APP_NAME%_secret_key_base') %>``` for ```secrets.yml```
