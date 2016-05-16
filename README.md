# Hanami::Gcloud::Datastore

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hanami-gcloud-datastore'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hanami-gcloud-datastore

## Repository supporting...

**WARNING**: For some queries it's necessary [create indexes](https://cloud.google.com/datastore/docs/concepts/indexes#index_configuration) to work correctly.

- [x] .persist(entity) – Create or update an entity
- [x] .create(entity) – Create a record for the given entity
- [x] .update(entity) – Update the record corresponding to the given entity
- [x] .delete(entity) – Delete the record corresponding to the given entity
- [x] .all - Fetch all the entities from the collection
- [x] .find - Fetch an entity from the collection by its ID
- [x] .first - Fetch the first entity from the collection
- [x] .last - Fetch the last entity from the collection
- [x] ~~.clear - Delete all the records from the collection~~ **unsupported**
- [x] .query - Fabricates a query object
  - [x] .where
  - [x] .order
  - [x] .select
  - [x] .group
  - [x] .limit
  - [x] .offset

## Testing

To run tests locally is necessary download the gcd and run:

```bash
curl -O https://storage.googleapis.com/gcd/tools/gcd-grpc-1.0.0.zip
unzip gcd-grpc-1.0.0.zip
cd gcd
./gcd.sh create data
./gcd.sh start data
export DATASTORE_EMULATOR_HOST=localhost:8080
export DATASTORE_DATASET=testing-project
export DATASTORE_PROJECT_ID=testing-project
rake test
```

We need improvement in tests to not receive error randomly. ):

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/b2beauty/hanami-gcloud-datastore.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

