#!/bin/bash

mkdir -p /run/lock
service apache2 restart
pcscd

exec bash
