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

## TODO

- Define how will work [ancestor](http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore/Key.html#parent-instance_method) and [key](http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore/Key.html#id-instance_method) (including key with `id` or `name`).
- Improve documentation about how to run tests using emulator.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/b2beauty/hanami-gcloud-datastore.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

