#!/bin/bash

mkdir -p /run/lock
service apache2 restart

exec bash
