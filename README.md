# Heroku Tarsnap Backups

Heroku has built-in backups for Postgres. That's fine if you accidentally delete some data and want to restore it. But what if you forget to update your credit card and Heroku delete all your data? What if somebody maliciously deletes your backups?

This app lets you make off-site backups of Heroku apps to Tarsnap. It will backup any Postgres databases or Bucketeer S3 buckets attached to it.

## Installing

Clone this repository, then run:

    $ heroku create --manifest your-app-backup


