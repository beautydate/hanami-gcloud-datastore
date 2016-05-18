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

## To use

### Create entity and repository

```ruby
class User
  include Hanami::Entity
  attributes :id, :name, :age
end

class UserRepository
  include Hanami::Repository
end
```

### Configure your mapping

**Important**: Use our `coerce` for your key.

```ruby
collection :users do
  entity     User
  repository UserRepository

  attribute :id,   Hanami::Gcloud::Datastore::Coercers::Key
  attribute :name, String
  attribute :age,  Integer, as: :Age
end
```

### Now... use! (:

```ruby
# getting first
UserRepository.first
# => nil

# creating an user
user = User.new(name: 'Leonardo', age: 7)
user = UserRepository.create(user)
# => #<User:0x007fef032a3920 @id="WyJVc2VyIiwyMix7InByb2plY3QiOiJ0ZXN0aW5nLXByb2plY3QifV0=\n" @name="Leonardo" @age=7>

# getting the user
user = UserRepository.find(user.id)
# => #<User:0x007fef02c0cc10 @id="WyJVc2VyIiwyMyx7InByb2plY3QiOiJ0ZXN0aW5nLXByb2plY3QifV0=\n" @name="Leonardo" @age=7>

# composite key
id = Hanami::Gcloud::Datastore::Coercers::Key.create('User', '1', namespace: 'my-namespace')
# => "WyJVc2VyIiwiMSIseyJuYW1lc3BhY2UiOiJteS1uYW1lc3BhY2UifV0=\n"
user = User.new(id: id, name: 'Leonardo', age: 7)
user = UserRepository.persist(user)
# => #<User:0x007fef032a3920 @id="WyJVc2VyIiwyMix7InByb2plY3QiOiJ0ZXN0aW5nLXByb2plY3QifV0=\n" @name="Leonardo" @age=7>
```

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

