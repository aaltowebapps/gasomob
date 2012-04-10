#!/bin/bash
NODE_ENV=production
echo Kill previous process...
sudo killall -u gaso node
echo Start gaso app...
sudo -u gaso nohup coffee app &
exit 0