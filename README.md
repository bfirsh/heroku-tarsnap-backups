# Heroku Tarsnap Backups

Heroku has built-in backups for Postgres. That's fine if you accidentally delete some data and want to restore it. But what if you forget to update your credit card and Heroku deletes all your data? Or, what if Heroku screw up somehow?

This app lets you make off-site backups of Heroku apps to [Tarsnap](https://www.tarsnap.com/). It runs as a "sidecar" app alongside another Heroku app. You connect any Postgres databases or Bucketeer S3 buckets you want backed up, then the app will automatically back up everything inside them. It also rotates the backups so you don't spend loads of money storing old ones.

## Installing

Clone this repository, then run:

    $ heroku create your-app-backup

(Replacing `your-app-backup` with the name of the app.)

Run these commands to set up the app:

    $ heroku stack:set container
    $ heroku addons:create scheduler:standard

Deploy the app to Heroku:

    $ git push heroku master

Heroku assumes apps have a long-running service. This app only runs with a schedule, so we can turn that off to save money:

    $ heroku scale web=0

### Configuring

First, set a config variable with the name of the app. This should probably be the same name as the Heroku app, and will be used in the name of the backups on Tarsnap:

    $ heroku config:set APP_NAME=your-app-backup

Next, [create a Tarsnap account and add some credit.](https://www.tarsnap.com/)

You then need to generate a Tarsnap key with the Tarsnap client. On Mac, run `brew install tarsnap`. On other platforms, [see these instructions](https://www.tarsnap.com/download.html). Then, substituting in your app name and Tarsnap account:

    $ tarsnap-keygen --keyfile tarsnap.key --user your-tarsnap-account@example.com --machine your-app-backup

This will create a `tarsnap.key` file. **Keep this key safe. If you lose this file, you can't recover any of your backups.**

Next, upload this key to your Heroku app:

    $ heroku config:add TARSNAP_KEY="$(cat tarsnap.key)"

(Note: Even though this key is on Heroku, you must still keep a local copy too. If Heroku have some kind of catastrophic failure, you won't be able to recover your key, therefore you won't be able to recover your backups. This defeats the whole point of having an off-site backup!)

### Connecting up your app

You now need to connect the app you want to back up to the sidecar backup app you have created. [Heroku lets you connect addons to multiple apps, so that is how we are going to achieve this.](https://devcenter.heroku.com/articles/managing-add-ons#using-the-dashboard-attaching-an-add-on-to-another-app)

These commands assume the app you want to back up is called `your-app` and the sidecar backup app is `your-app-backup`. Substitute as appropriate.

To connect Heroku Postgres:

    $ heroku addons:attach -a your-app-backup your-app::DATABASE

To connect Bucketeer S3 buckets:

    $ heroku addons:attach -a your-app-backup your-app::BUCKETEER

### Testing

To test everything works, run:

    $ heroku run bin/backup

It should back up everything you attached. To check it has actually created, run:

    $ heroku run bin/list

You should see an archive listed there.

### Setting up a schedule

Set up the schedule for your backups:

    $ heroku addons:open scheduler

Then, in the web interface, click "Add new job". In the command, enter `bin/backup`. For the schedule, select either hourly or daily depending on how many backups you want to make, then whatever time you want. Click "Save".

That's it! Your Heroku app is now being backed up.

## Restoring backups

See gitbook.

## Configuration reference

### `TARSNAPPER_DELTAS`

Default: `1h 1d 7d 30d 360d 18000d`

This option allows you to customise how many backups are kept when they are rotated. The default means keep hourly backups for a day, daily backups for a week, weekly for a month, monthly for a year, yearly forever. See [the Tarsnapper docs for more details](https://github.com/miracle2k/tarsnapper).
