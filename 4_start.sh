#! /bin/bash

TOM_INS=/opt/new_project

# 启动服务
cd $TOM_INS/center-server
./start.sh

sleep 3

cd $TOM_INS/db-server
./start.sh

sleep 3

cd $TOM_INS/gate-server
./start.sh

cd $TOM_INS/hall-server
./start.sh

cd $TOM_INS/log-server
./start.sh

cd $TOM_INS/game-baccara
./start.sh

cd $TOM_INS/game-goodstart
./start.sh

cd $TOM_INS/game-bullfight
./start.sh

cd $TOM_INS/game-dragontiger
./start.sh

cd $TOM_INS/game-red-black
./start.sh

cd $TOM_INS/game-glodflower
./start.sh

cd $TOM_INS/game-robtaurus
./start.sh

cd $TOM_INS/game-fores
./start.sh

cd $TOM_INS/game-gragontiles
./start.sh

cd $TOM_INS/game-cqssc
./start.sh

cd $TOM_INS/game-fruit-machine
./start.sh

cd $TOM_INS/game-gemstorm
./start.sh
cd $TOM_INS/game-cqeverycolor
./start.sh

cd $TOM_INS/game-classicLandords
./start.sh


sleep 3

# 显示服务启动状态
echo "服务启动完成"
ps -ef | grep java | wc -l
