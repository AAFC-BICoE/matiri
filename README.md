matiri
======
* Parallel MySql backup script storing backup info in Sqlite3 database.

Features
* Parallel: each database on the server to be backed up is done individually, in parallel (level settable)
* Each database backup compressed
* SHA256 of each compressed backup file stored
* All database backups tar'ed together into single file
* SHA256 of single tar file stored
* Backup information & databases backed-up information stored in Sqlite3 database and metadata file


MySql Credentials
--------------------
matiri calls a script called mysql.sh to obtain MySql server host, port number, userid and password.
A default implementation is supplied but should be modified to be more secure.

Running
------------
1. Alter the mysql.sh to have the right credentials
2. Alter the matiri script to have the appropriate backup destination location: $BASE_DESTINATION_DIR
3. Start matiri


Directory Structure
--------------------
All backup files are grouped by month.
$BASE_DESTINATION_DIR/YYYY/MM

Four files a produced:
1. mysql_backup_YYYY-MM-DD_ID.tar
* tar of backup files (see below)
2. mysql_backup_YYYY-MM-DD_ID.tar.sha256
*  sha256 of #1
3. mysql_backup_YYYY-MM-DD_ID.meta
*  Info about the backup (redundant with Sqlite3 information)
4. mysql_backup_YYYY-MM-DD_ID.err
* stderr output from backup 

Dependencies
----------------
1. Sqlite3 
2. mysqldump 
3. Standard Linux tools (tar, gzip, date, awk, xargs, sha256sum)


Sqlite3 Database 
--------------------------
Default sqlite location: $BASE_DESTINATION_DIR/backups.sqlite3.db

* Each time matiri is run, an entry in the 'backup_event' table is created.
* The record is added, indicating a backup_event was started, with the 'completed' column set to -999 (not completed)
* For each of the databases to be backed up
* * A database record is added before the database backup starts, with the backup_event ID as the forign key 'backup_id'. The 'completed' column set to -999 (not completed).
* * If this database backup completes successfully, the record is updated with the 'completed' column set to 0 (completed), the end_time is set, the size ('bytes') and the SHA256 of the backup file are recorded.
* If the backup event has successfully executed, the backup_event is updated with the 'completed' column set to 0 (completed), the end_time is set, the size ('bytes') and the SHA256 of the tar file are recorded.

Database schema:
    CREATE TABLE backup_event (id INTEGER PRIMARY KEY, completed int NOT NULL, comments text, host varchar(255) NOT NULL, port int NOT NULL, start_time DATETIME not null, end_time DATETIME not null, user varchar(64), bytes bigint NOT NULL, file text, sha256 char(64) NOT NULL, error default NULL);
    CREATE INDEX backup_start_time on backup(start_time);
    CREATE TABLE database (id INTEGER PRIMARY KEY,  completed int NOT NULL, backup_id INTEGER, database varchar(255) NOT NULL, file text, start_time DATETIME not null, end_time DATETIME not null, bytes bigint NOT NULL, sha256 char(64) NOT NULL, error default NULL, FOREIGN KEY(backup_id) REFERENCES backup(id));
    CREATE INDEX database_start_time on database(start_time);


## TODOs
0. Command line parameters for backup location and dynamically setting credentials (mysql.sh) script
1. Better docs here and in scripts
2. Fix scripts to better adhere to the Google bash style guide
3. Alternate compression: {p}bzip2 should be easy;
4. Scripts to both delete old backups files and remove entries from the Sqlite3 db (keep in sync)
5. Simple web server app to peruse backup information in Sqlite3 DB
