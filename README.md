Example Service
====================

This repository should provide a good base for any Thrift-RPC service you may wish to build and deploy at Brigade.

From a clean copy of this directory, you'll have a couple things you'll need to change:
- [ ] Replace example-service/example_service in all files with your own name
- [ ] Replace the thrift-shop service object in the server file with the type
  corresponding to your service
- [ ] Delete migrations in db/migrate and create your own
- [ ] Remove old models and specs
- [ ] Create your own Service (in app/) and Handler (in app/lib/)
- [ ] Set up arcanus (the password in this repo is "password": change it!)
- [ ] Set up skylight (see `service_utilities` gem for usage)
- [ ] When copying over files, make sure you copy over the log directory with its
  .gitkeep file
- [ ] Replace the service enum in config/initializers/service_utilities.rb with your service
- [ ] Search for the port numbers 11999 and 21999 and replace them with the port
  numbers you've registered for the service in proximo (make sure to include
  hidden files in your search)
- [ ] Update to the latest version of ThriftShop

Installation
------------

Development for this repo is done within a Docker container using `dock`.

***REMOVED***
***REMOVED***

Now you can get started:

```bash
gerrit clone example-service
cd example-service
dock
```

Opening an application console
---------------------------------------

To run an `irb` console with all application loaded, run:

```bash
bin/console
```

Note that this may be chained with cluster_console below to access a staging/prod app console.

Deployment
----------

To deploy the app, run:

```bash
ARCANUS_PASSWORD=... jenkins/deploy [staging | production]
```

Deploy configuration is contained in the [`deploy.yaml`](deploy.yaml) file.

Opening a console in staging/production
---------------------------------------

Sometimes you want to run some one-off code or debug using the container
environment. Simply run:

```
script/cluster_console [staging | production] [command]
```

...to open a container in the specified environment. The `command` is optional;
by default a `bash` shell is spawned. `bin/console` may be passed to open an
application shell in staging or production.
