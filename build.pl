#!/usr/bin/perl

use strict;
use warnings;
chdir("/opt/image-docker-php");
system("docker build -t docker-php:1.5 .");
system("docker tag docker-php:1.5 docker-php:latest");
