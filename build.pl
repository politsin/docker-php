#!/usr/bin/perl

use strict;
use warnings;
chdir("/opt/image-docker-php");
system("docker build -t docker-php:1.2 .");
