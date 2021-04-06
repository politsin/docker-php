#!/usr/bin/python

import os

ver = "8.0"
img = "synst/php7"
repo = "docker-php"

# go to build dir
if os.path.exists('/opt/docker-php'):
    os.chdir('/opt/docker-php')
    os.system("docker build -f Dockerfile -t %s:%s ." % (img, ver))
    os.system("docker tag %s:%s %s:latest" % (img, ver, img))

# get travis repo
if os.environ['REPO']:
    repo = os.environ['REPO']
    bild = os.environ['TRAVIS_BUILD_NUMBER']
    os.system("docker build -f Dockerfile -t %s ." % (repo))
    os.system("docker tag %s %s:latest" % (repo, repo))
    os.system("docker tag %s %s:%s" % (repo, repo, ver))
    os.system("docker tag %s %s:%s.%s" % (repo, repo, ver, bild))
