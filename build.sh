#!/bin/bash

# cd /opt/build/docker-php
docker build . -t synstd/php
docker tag synstd/php synstd/php:8.1
docker tag synstd/php synstd/php:8.1.250
docker push synstd/php
docker push synstd/php:8.1
docker push synstd/php:8.1.250
