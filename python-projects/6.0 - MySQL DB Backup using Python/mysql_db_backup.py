#!/usr/local/bin/python3

import configparser
import os
import time
import getpass

# input cred. and dbs
HOST='localhost'
PORT='3306'
DB_USER='usradmin'
DB_PASS='Mypasswd123!'
databases=('db1','db2','db3')

def get_dump(database):
    filestamp = time.strftime('%Y-%m-%d-%I')
    # D:/xampp/mysql/bin/mysqldump for xamp windows
    # old fmt: os.popen("mysqldump -h %s -P %s -u %s -p%s %s > %s.sql" % (HOST,PORT,DB_USER,DB_PASS,database,database+"_"+filestamp))
    os.popen(f"mysqldump -h {HOST} -P {PORT} -u {DB_USER} -p{DB_PASS} {database} > {database}_{filestamp}.sql")
    print("\n|***| Database has been dumped to "+database+"_"+filestamp+".sql |***| ")


if __name__=="__main__":
    for database in databases:
        get_dump(database)