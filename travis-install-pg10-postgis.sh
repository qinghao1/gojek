# See https://github.com/travis-ci/travis-ci/issues/8537

set -ex

echo "Installing Postgres 10"
sudo service postgresql stop
sudo apt-get install -q postgresql-10 postgresql-client-10
sudo apt-get install -q -y postgresql-10-postgis-2.4-scripts postgresql-10-postgis-2.4 postgis
sudo cp /etc/postgresql/{9.6,10}/main/pg_hba.conf
export PGPORT=5433

echo "Restarting Postgres 10"
sudo service postgresql restart