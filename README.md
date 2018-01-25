# README

A driver-finding API for Go-Jek.  
Written using Ruby on Rails and PostgreSQL & PostGIS by [Chu Qing Hao](qinghao1.com).  
A live version is up at _128.199.155.167_

## Tech Stack
I chose Rails and Postgres because of my familiarity with them.
[PostGIS](postgis.net) is used with Postgres to enable fast
k-nearest-neighbors search and other spatial operations (if needed eventually).

## Required software
### Development Environment
- Ruby (2.5.0)
- Rails (5.1.4)
- PostgreSQL (10.1)
- PostGIS (2.4.3)

### Deployment Environment
- The above, plus
- rvm
- nginx

## Testing
Simply run  

	rails test

## Deployment instructions
(Refer to [this guide from DigitalOcean](https://www.digitalocean.com/community/tutorials/deploying-a-rails-app-on-ubuntu-14-04-with-capistrano-nginx-and-puma))

0. Set up a (private) Git repo of this project and add deploy key
1. Set up production server
    1. Create user *deploy@server_ip*
    2. Setup ssh keys for development computer for user *deploy* 
    3. Create Postgres database *gojek_production*
    4. Connect to it and execute 

        CREATE EXTENSION PostGIS;

    5. Create user *gojek* with password *passw* (or change in database.yml file)
2. Change the appropriate values in /config/deploy.rb, then push to repo
    1. Server IP and port
    2. Repo URL
3. On development computer, run

        bundle exec cap production deploy:initial

4. SSH into production server and run the following commands:  

	sudo rm /etc/nginx/sites-enabled/default

	sudo ln -nfs "/home/deploy/apps/appname/current/config/nginx.conf" "/etc/nginx/sites-enabled/appname"

	sudo service nginx restart

5. You should be good to go! (Hopefully)

## Infrastructure requirements
Unfortunately, I do not have the means to test the API to give a precise requirement. However, a newer and more powerful server should be preferred.
