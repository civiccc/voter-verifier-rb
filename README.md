Verification Service
====================

TODO: Fill this out with meaningful info as service gets implemented

Installation
------------

Development for this repo is done within a Docker container using `dock`.

***REMOVED***
***REMOVED***

Now you can get started:

```bash
gerrit clone verification-service
cd verification-service
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
