Voter Verifier
====================

TODO: brief qualitative/historical intro

Voter Record Data
------------------
Where's the voter data? Well, this project is BYOD. For more details about what this means and what the Voter Verifier assumes about the data it matches against, see the [data readme](./DATA_README.md).

Requirements
------------
1. ElasticSearch 1.7 (support for newer versions coming soon)

    It's pretty likely ElasticSearch 2.4 will also work, which is available on Homebrew, but it hasn't been tested. For ElasticSearch 1.7, download the binaries and install following the [installation instructions](https://www.elastic.co/guide/en/elasticsearch/reference/1.7/_installation.html). Repositories are available for both [APT and YUM](https://www.elastic.co/guide/en/elasticsearch/reference/1.7/setup-repositories.html).

1. Ruby 2.3+
1. bundler 1.16.3

Getting Started
---------------
1. Build your index and doc type

    The way this was tooled before was not open-source-able. It should be re-tooled. In the meantime, you'll need to use whatever method you prefer to build an ElasticSearch index and doc type that matches the specifications in [elasticsearch.md](./elasticsearch.md). There are two json files in `data/` that will help some: [elasticsearch_index_mapping.json](./data/elasticsearch_index_mapping.json) and [elasticsearch_index_settings.json](./data/elasticsearch_index_settings.json). The worst part will be the synonym filters, which need to be substituted into `elasticsearch_index_settings.json` from `data/address_synonyms.txt` and `data/first_name_synonyms.txt`. You'll need the name of the index and the doc type in a later step. The index name and doc type the queries will use are configurable, but have a default of `voter_verifier` for the index and `voter_record` for the doc type.

1. Start your ElasticSearch cluster

1. Index your data

    This is a BYOD situation, so you're kind of on your own here. End goal is to have voter record data loaded into the newly-created index.

1. Clone the repo

    ```bash
    $ git clone git@github.com:civiccc/voter-verifier
    ```

1. Install dependencies

    In most cases, `--without development test` will be enough.

    ```bash
    $ bundle install --without development test
    ```

1. Set configuration environment variables

    If you used the default index name and doc type, only the ElasticSearch hostname needs to be set:

    Host names of the ElasticSearch cluster(s) to use as a comma-separated list. Default: `localhost:9200`.

    ```bash
    $ export VOTER_VERIFIER_ES_HOSTS=localhost:9200,localhost:9201
    ```

    *Other available options are:*

    Port the server will listen on. Default: `9095`.

    ```bash
    $ export VOTER_VERIFIER_PORT=9095
    ```

    Timeout for ElasticSearch queries, in seconds. Default: `15`.

    ```bash
    $ export VOTER_VERIFIER_ES_TIMEOUT=15
    ```

    Number of retries for ElasticSearch queries. Default: `1`.

    ```bash
    $ export VOTER_VERIFIER_ES_RETRIES=15
    ```

    Index name for ElasticSearch queries. Default: `voter_verifier`.

    ```bash
    $ export VOTER_VERIFIER_ES_INDEX=voter_verifier
    ```

    Doc type for ElasticSearch queries. Default: `voter_record`.

    ```bash
    $ export VOTER_VERIFIER_ES_DOC_TYPE=15
    ```

1. Run the server

    ```bash
    $ rake thrift_server:run
    ```

1. That's it! (for the server-side, hopefully?)

### Important: Deployment Guidance
Because this started life as an internal service on a private network, there is no notion of authentication or authorization. There are considerations in request headers for conveying identity claims at some point, but there's nothing validating any of it in the gem at this time. This is best deployed in a manner such that all traffic is trusted. Any use cases intended for general public users should use another service as a reverse proxy and handle authentication, authorization, rate limiting, etc., there. Figuring out how best to leave a lot of flexibility in use cases while still encouraging strong privacy protections is a big part of the development roadmap (term used very loosely). So if you're interested...check out the [contributing](#contributing) section.

Ruby Client
------------
To get an `irb` session with the application context (and thus the Ruby client), run:

```bash
$ bin/console
```

```ruby
> transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', <SERVER PORT>))
> protocol = Thrift::BinaryProtocol.new(transport)
> client = ThriftDefs::VoterVerifier::Service::Client.new(protocol)
> headers = ThriftDefs::RequestTypes::Headers.new(request_id: SecureRandom.uuid)
> request = ThriftDefs::RequestTypes::Search.new(
  first_name: 'John',
  last_name: 'Smith',
  zip_code: '94105'
)
> client.search(headers, request)
=> <ThriftDefs::VoterRecordTypes::VoterRecords voter_records:[<ThriftDefs::VoterRecordTypes::VoterRecord first_name: 'John', last_name: 'Smith'...>...]>
```

Need a client in a different language? It's definitely possible to generate a client in any language Thrift [targets](https://thrift.apache.org/docs/Languages). At this time, you'll need to edit the Thrift IDL (in [thrift/types](./thrift/types)) to add proper [namespace declarations](https://diwakergupta.github.io/thrift-missing-guide/#_namespaces) for your target language. Then you can compile the client by running:

```bash
$ for thrift_file in $(find thrift/types -name *.thrift -print) do
>  echo "Processing $thrift_file"
>  thrift --gen <language>:namespaced -o out_dir -strict $thrift_file
> done
```

You'll then see a `gen-*` directory in the specified `out_dir` containing the generated code.

Diving a Little Deeper
----------------------
(It'd be nice to have a docs page that has an API reference and gets into all the details...did I mention we'd love [contributors](#contributing)?)

### Server type
For historical reasons due to the origin of this codebase, there is currently only a [Thrift](https://thrift.apache.org/) server. But there is a Ruby client included, so this shouldn't feel much different than interacting with a RESTful JSON-over-HTTP API by using a Ruby-based API client or SDK. Hopefully it doesn't take long to offer this additionally as both a stand-alone Rails app and an Engine plug-in ([contributors welcome!](#contributing)).

### ElasticSearch Index
Read all about the underlying [ElasticSearch index](./elasticsearch.md) required to power the service.

Contributing
-------------
Civic Code Collective wouldn't be much of a collective without you! Got an idea to make Voter Verifier better, stronger or faster? Clone it, branch it and hack it. When it's done, open up a PR. Want to help but don't know where to start? Head on over to the [issues page](https://github.com/civiccc/voter-verifier/issues) and see if something calls your name. Documentation and test cases are always great contributions.

It's recommended, but not required, to do development for this repo within a Docker container using [dock](https://github.com/brigade/dock). This is definitely not required currently, as the dock integration is super broken. That could be your first contribution! Hopefully we remember to update this `README` as part of that.

Be sure to also have a glance at the [Code of Conduct](./contributing.md).

### Using Docker and Dock
TODO

### The Old-Fashioned Way
1. Install and configure ElasticSearch

    (see [Getting Started](#getting-started) above).

1. Install Thrift 0.9+

    #### Homebrew (MacOS)

    $ brew install thrift

    #### Linux

    This time Linux users have more work: [Debian](https://thrift.apache.org/docs/install/debian) | [CentOS](https://thrift.apache.org/docs/install/centos)

1. Clone the repo

    ```bash
    $ git clone git@github.com:civiccc/voter-verifier-rb
    ```

1. Install dependencies (including development + test)

    ```bash
    $ bundle install
    ```

1. run the server

    ```bash
    $ VOTER_VERIFIER_ENV=development rake thrift_server:run
    ```

    or to see other available tasks, run:

    ```bash
    $ rake -T
    ```

Opening an application console
---------------------------------------

To run an `irb` console with application context loaded, run:

```bash
$ bin/console
irb(main):001:0 >
```

License
-------
Voter Verifier is released under the [Apache 2.0 license](https://opensource.org/licenses/Apache-2.0).
