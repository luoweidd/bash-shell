#!/bin/bash

find /DB_backup/Mysql_backup/ -mtime +90 -print -delete
find /DB_backup/Mongo_backup/ -mtime +90 -print -delete
