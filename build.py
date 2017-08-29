#!/usr/bin/python

import os
if os.path.exists('/opt/docker-php'):
  os.chdir('/opt/docker-php')
  os.system('docker build -t docker-php:1.7 .')
  os.system('docker tag docker-php:1.7 docker-php:latest')
