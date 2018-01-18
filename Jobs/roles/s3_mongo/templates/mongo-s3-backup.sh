#!/bin/bash
 
#Force file syncronization and lock writes
mongo admin --eval "printjson(db.fsyncLock())"
 
MONGODUMP_PATH="/usr/bin/mongodump"
MONGO_DATABASE="telecmi" #replace with your database name
 
TIMESTAMP=`date +%F-%H%M`
S3_BUCKET_NAME="telecmi-bucket" #replace with your bucket name on Amazon S3
S3_BUCKET_PATH="mongodb-backups"
 
# Create backup
$MONGODUMP_PATH -d $MONGO_DATABASE
 
# Add timestamp to backup
mv dump mongodb-$HOSTNAME-$TIMESTAMP
tar cf mongodb-$HOSTNAME-$TIMESTAMP.tar mongodb-$HOSTNAME-$TIMESTAMP
 
# Upload to S3
s3cmd put mongodb-$HOSTNAME-$TIMESTAMP.tar s3://$S3_BUCKET_NAME/$S3_BUCKET_PATH/mongodb-$HOSTNAME-$TIMESTAMP.tar
 
#Unlock database writes
mongo admin --eval "printjson(db.fsyncUnlock())"
#Delete local files
rm -rf mongodb-*



