# README

A driver-finding API for Go-Jek.  
Written using Ruby on Rails and PostgreSQL & PostGIS by [Chu Qing Hao](http://qinghao1.com).  
A live version is up at **128.199.155.167**

## Tech Stack
I chose Rails and Postgres because of my familiarity with them.
[PostGIS](http://postgis.net) is used with Postgres to enable fast
k-nearest-neighbors search and other spatial operations (for future features).

## Required software
### Development Environment
- Ruby (2.5.0)
- Rails (5.1.4)
- PostgreSQL (10.1)
- PostGIS (2.4.3)

### Production Environment
- The above, plus
- rvm
- nginx

## Testing
Enable Travis CI on your repo for automated testing.

## Deployment instructions
(Refer to [this guide from DigitalOcean](https://www.digitalocean.com/community/tutorials/deploying-a-rails-app-on-ubuntu-14-04-with-capistrano-nginx-and-puma))

0. Set up a (private) Git repo of this project and add deploy key
1. Set up production server
    1. Create user *deploy@server_ip*
    2. Setup ssh keys for development computer for user *deploy* 
    3. Create Postgres database *gojek_production*
    4. Connect to it and execute 

            CREATE EXTENSION PostGIS;

    5. Create user *gojek* with password *passw*
2. Change the appropriate values in /config/deploy.rb, then push to repo
    1. Server IP and port
    2. Repo URL
3. On development computer, run

        bundle exec cap production deploy:initial

4. SSH into production server and run the following commands:  

        sudo rm /etc/nginx/sites-enabled/default

        sudo ln -nfs "/home/deploy/apps/gojek/current/config/nginx.conf" "/etc/nginx/sites-enabled/appname"

        sudo service nginx restart

5. You should be good to go! (Hopefully)

## Load Testing and Infrastructure requirements
In project folder, run

    gem install gas_load_tester rest-client
    ruby load_testing.rb
Results should be printed to console. Unfortunately, I'm not able to test the driver PUT location API completely due to lacking hardware.

Based on my testing with 128.199.155.167 (the cheapest DigitalOcean VM with 1GB 1vCPU), the customer API can respond in around 100ms under full load. However, the driver API takes around 400ms to respond for 100 request per second (the maximum I can test).

Thus, better infrastructure is required to improve the driver API speed. Unfortunately, I cannot provide a precise requirement. However, a newer and more powerful server should be preferred.

## Improvements
To improve driver API performance, we can cache and batch insert records into the database. However, I couldn't implement this in time.
