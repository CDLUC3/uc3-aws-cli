#! /bin/sh

cd

rm -rf merritt-docker merritt-docker-prv

git clone git@github.com:CDLUC3/merritt-docker.git
git clone git@github.com:cdlib/merritt-docker-prv.git

cp -r merritt-docker-prv/* merritt-docker/mrt-services/no-track

cd merritt-docker
git submodule update --remote --recursive -- .

cd ../merritt-docker/mrt-dependencies
sudo docker-compose build
cd ../mrt-services
sudo docker-compose build