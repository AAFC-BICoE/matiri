*matiri*
======
* Parallel MySql backup script storing backup info in Sqlite3 database.

**Features:**
* **Parallel**: each database on the server to be backed up is done separately, in parallel (concurrency settable: default: 3)
* **Compressed**: Each database backup compressed
* **Checksummed**: SHA256 of each compressed backup file stored and the archive of all files
* **Archived**: All database backups tar'ed together into single file
* **Recorded**: Backup information stored in Sqlite3 database


MySql Credentials
--------------------
*matiri* invokes a script called `mysql.sh` (must be in same directory as *matiri* script) to obtain MySql server host, port number, userid and password.
A default implementation is supplied but should be modified to be more secure.

Running
------------
1. Alter the `mysql.sh` to have the right credentials
2. Alter the *matiri* script to have the appropriate backup destination location directory: `$BASE_DESTINATION_DIR` default value=`/tmp/backups`
3 Alter the *matiri* script to have the appropriate concurrency: `$CONCURRENCY_LEVEL`  default value=`3	
4. Start *matiri*


Directory Structure
--------------------
All backup files are grouped by month.
    `$BASE_DESTINATION_DIR/YYYY/MM`

Four files are produced:

1. `mysql_backup_YYYY-MM-DD_ID.tar`
    * tar of database backup files (see below)
2. `mysql_backup_YYYY-MM-DD_ID.tar.sha256`
    *  sha256 of #1
3. `mysql_backup_YYYY-MM-DD_ID.meta`
    *  Info about the backup (redundant with Sqlite3 information)
4. `mysql_backup_YYYY-MM-DD_ID.err`
    * stderr output from backup process

## Database Backup files

The above (#1) `tar` file is made up of:
&nbsp;&nbsp;&nbsp;For each database being backed up, two files are produced:

1. database__DBNAME.gz.
    * gzip of mysqldump output
2. database__DBNAME.gz.sha256
    * SHA256 of #1



Dependencies
----------------
1. [Sqlite3](https://www.sqlite.org/sqlite.html)
2. [mysqldump](https://dev.mysql.com/doc/refman/5.5/en/mysqldump.html) (Tested on mysqldump  Ver 10.13 Distrib 5.5.34, for Linux (x86_64))
3. Standard Linux tools (tar, gzip, date, awk, xargs, sha256sum)


Sqlite3 Database 
--------------------------
Default sqlite location: `$BASE_DESTINATION_DIR/backups.sqlite3.db`

* Each time *matiri* is run, an entry in the `'backup_event'` table is created.
* The record is added, indicating a backup_event was started, with the `'completed'` column set to `-999 `(not completed)
* For each of the databases to be backed up:
    * A database record is added before the database backup starts, with the `backup_event` `id` as the forign key `'backup_id'`. The 'completed' column set to `-999` (not completed).
    * If this database backup completes successfully, the record is updated with the `'completed'` column set to `0` (completed), the end_time is set, the size (`'bytes'`) and the SHA256 of the backup file are recorded.
* If the backup event has successfully executed, the backup_event is updated with the 'completed' column set to 0 (completed), the end_time is set, the size ('bytes') and the SHA256 of the tar file are recorded.

Database schema:

```sql

    CREATE TABLE backup_event (id INTEGER PRIMARY KEY, completed int NOT NULL, comments text, 
           host varchar(255) NOT NULL, port int NOT NULL, 
           start_time DATETIME not null, end_time DATETIME not null, 
           user varchar(64), bytes bigint NOT NULL, file text, sha256 char(64) NOT NULL, 
           error default NULL);


    CREATE TABLE database (id INTEGER PRIMARY KEY,  completed int NOT NULL, backup_id INTEGER, 
           database varchar(255) NOT NULL, file text, 
           start_time DATETIME not null, end_time DATETIME not null, 
           bytes bigint NOT NULL, sha256 char(64) NOT NULL, 
           error default NULL, FOREIGN KEY(backup_id) REFERENCES backup(id));

    CREATE INDEX backup_start_time on backup(start_time);

    CREATE INDEX database_start_time on database(start_time);

```

## Perusing Sqlite3 Backup Database
Using the Sqlite3 [command line tool](https://www.sqlite.org/sqlite.html)

```
sqlite> select * from backup_event;
id|completed|comments|host|port|start_time|end_time|user|bytes|file|sha256|error
12|0||localhost|3306|2013-11-23 17:23:15|2013-11-23 17:23:15|backups|20480|/home/newtong/backups/2013/11/mysql_backup_2013-11-23_12.tar|6f216d2a4811382b66b25480328b385bab54e7531f73bf2aa5262b00b030017c|
13|0||localhost|3306|2013-11-23 17:23:26|2013-11-23 17:23:27|backups|20480|/home/newtong/backups/2013/11/mysql_backup_2013-11-23_13.tar|da5721440c8577a3b250232ba2e901350ea9a34876212312a5b9a28206ae6d33|
14|0||localhost|3306|2013-11-23 17:23:50|2013-11-23 17:23:51|backups|20480|/home/newtong/backups/2013/11/mysql_backup_2013-11-23_14.tar|f2a9b41e4157da803d79cf385db17dad1d273e48b352eba2cd0209eaf90fa2e9|
15|0||localhost|3306|2013-11-23 17:24:08|2013-11-23 17:24:15|backups|29399040|/home/newtong/backups/2013/11/mysql_backup_2013-11-23_15.tar|8ef6dbdb3537361e48bce1d3eeb3c114d25ebf8d7eb808312384035221f20e32|

sqlite> select * from database where backup_id = 15;
id|completed|backup_id|database|file|start_time|end_time|bytes|sha256|error
61|0|15|performance_schema|database__performance_schema.gz|2013-11-23 17:24:09|2013-11-23 17:24:15|1100|2e7ea55832e3fbb62ee1370a1f0b6ffef2415aba79a129b419181195588b6c27|
62|0|15|information_schema|database__information_schema.gz|2013-11-23 17:24:09|2013-11-23 17:24:15|395504|694688b16377916f31f9dbe2a8647928a6cbb4cd5419767b3335c5ca7e5e5f37|
63|0|15|mysql|database__mysql.gz|2013-11-23 17:24:09|2013-11-23 17:24:15|142109|a72789bedfdcc73ea419750fd4904fd1c859e175f23be208b58d1c262e45eae5|
64|0|15|specify_dao_live|database__specify_dao_live.gz|2013-11-23 17:24:09|2013-11-23 17:24:15|28842782|1d91517672bae1ae39294d3e4f819e79eb6d0c4325d9c30d2d78303c34e189cd|
sqlite> 
```



## TODOs
0. Command line parameters for backup location and dynamically setting credentials (mysql.sh) script
1. Better docs here and in scripts
2. Fix scripts to better adhere to the Google bash style guide
3. Alternate compression: {p}bzip2 should be easy;
4. Scripts to both delete old backups files and remove entries from the Sqlite3 db (keep in sync)
5. Simple web server app to peruse backup information in Sqlite3 DB
6. Explanation of the Sqlite3 fields stored.

Name
---------------
Named after the [Matiri River](https://en.wikipedia.org/wiki/Matiri_River), New Zealand. 
I have been very close on several occasions but never have seen the river.

Acknowledgements
-------------
Partially developed at Agriculture and Agri-Food Canada, Ottawa, Ontario.