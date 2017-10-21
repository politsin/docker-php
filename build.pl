#!/usr/bin/perl

use strict;
use warnings;
chdir("/opt/docker-php");
system("docker build -t docker-php:1.8 .");
system("docker tag docker-php:1.8 docker-php:latest");
