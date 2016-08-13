#!/usr/bin/perl

use strict;
use warnings;
chdir("/opt/docker-php");
system("docker build -t docker-php .");