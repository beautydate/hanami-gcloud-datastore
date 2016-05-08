require 'test_helper'

describe Hanami::Model::Adapters::Gcloud::DatastoreAdapter do
  before do
    class TestUser
      include Hanami::Entity
      attributes :id, :name, :age
    end

    class TestUserRepository
      include Hanami::Repository
    end

    @mapper = Hanami::Model::Mapper.new do
      collection :test_users do
        entity TestUser

        attribute :id,   String
        attribute :name, String
        attribute :age,  Integer, as: :Age
      end
    end.load!

    @adapter = Hanami::Model::Adapters::Gcloud::DatastoreAdapter.new(
      @mapper, nil, {}
    )

    while entity = @adapter.last(collection)
      @adapter.delete(collection, entity)
    end
  end

  after do
    while entity = @adapter.last(collection)
      @adapter.delete(collection, entity)
    end

    Object.send(:remove_const, :TestUser)
    Object.send(:remove_const, :TestUserRepository)
  end

  let(:collection) { :test_users }

  describe '#create' do
    let(:entity) { TestUser.new(name: 'test', age: 30) }

    it 'stores the entity and assigns an id' do
      result = @adapter.create(collection, entity)

      result.id.wont_be_nil
      @adapter.find(collection, result.id).must_equal result
    end
  end

  describe '#update' do
    let(:entity) { TestUser.new(id: 2, name: 'test', age: 30) }

    it 'updates the entity' do
      old_entity = @adapter.create(collection, entity)

      old_entity.name.must_equal 'test'
      old_entity.age.must_equal 30

      old_entity.name = 'test #2'
      old_entity.age = 40
      new_entity = @adapter.update(collection, old_entity)

      new_entity.id.must_equal old_entity.id
      new_entity.name.must_equal 'test #2'
      new_entity.age.must_equal 40
    end
  end

  describe '#persist' do
    let(:entity) { TestUser.new(id: 3, name: 'test', age: 30) }

    it 'updates the entity' do
      old_entity = @adapter.persist(collection, entity)

      old_entity.name.must_equal 'test'
      old_entity.age.must_equal 30

      old_entity.name = 'test #2'
      old_entity.age = 40
      new_entity = @adapter.persist(collection, old_entity)

      new_entity.id.must_equal old_entity.id
      new_entity.name.must_equal 'test #2'
      new_entity.age.must_equal 40
    end
  end

  describe '#find' do
    let(:entity) { TestUser.new(id: 4, name: 'test', age: 30) }

    it 'when no entity are persisted' do
      @adapter.find(collection, -8).must_equal nil
    end

    it 'when entity are persisted' do
      result = @adapter.create(collection, entity)

      @adapter.find(collection, result.id).must_equal result
    end
  end

  describe '#delete' do
    let(:entity) { TestUser.new(id: 5, name: 'test', age: 30) }

    it 'when entity are persisted' do
      subject = @adapter.create(collection, entity)

      @adapter.delete(collection, subject).must_equal true

      @adapter.find(collection, subject.id).must_equal nil
    end
  end

  describe '#query' do
    let(:entity_1) { TestUser.new(id: 31, name: 'test #1', age: 31) }
    let(:entity_2) { TestUser.new(id: 32, name: 'test #2', age: 32) }
    let(:entity_3) { TestUser.new(id: 33, name: 'test #3', age: 33) }
    let(:entity_4) { TestUser.new(id: 34, name: 'test #4', age: 34) }

    it 'when operator is equal' do
      entities = [entity_1, entity_2, entity_3, entity_4]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.query(collection).where(name: 'test #1').all

      result.count.must_equal 1

      result.first.name.must_equal entity_1.name
      result.first.age.must_equal entity_1.age
    end

    it 'when operator is less than' do
      entities = [entity_1, entity_2, entity_3, entity_4]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.query(collection).where { age < 33 }.all

      result.count.must_equal 2

      result.first.name.must_equal entity_1.name
      result.first.age.must_equal entity_1.age

      result.last.name.must_equal entity_2.name
      result.last.age.must_equal entity_2.age
    end

    it 'when operator is less than or equal' do
      entities = [entity_1, entity_2, entity_3, entity_4]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.query(collection).where { age <= 33 }.all

      result.count.must_equal 3

      result[0].name.must_equal entity_1.name
      result[0].age.must_equal entity_1.age

      result[1].name.must_equal entity_2.name
      result[1].age.must_equal entity_2.age

      result[2].name.must_equal entity_3.name
      result[2].age.must_equal entity_3.age
    end

    it 'when operator is greater than' do
      entities = [entity_1, entity_2, entity_3, entity_4]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.query(collection).where { age > 33 }.all

      result.count.must_equal 1

      result[0].name.must_equal entity_4.name
      result[0].age.must_equal entity_4.age
    end

    it 'when operator is greater than or equal' do
      entities = [entity_1, entity_2, entity_3, entity_4]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.query(collection).where { age >= 33 }.all

      result.count.must_equal 2

      result = @adapter.query(collection).where { age >= 33 }.all

      result[0].name.must_equal entity_3.name
      result[0].age.must_equal entity_3.age

      result[1].name.must_equal entity_4.name
      result[1].age.must_equal entity_4.age
    end

    it 'limiting result' do
      entities = [entity_1, entity_2, entity_3]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.query(collection).order(:age).limit(1).all
      result.count.must_equal 1
      result.first.id.must_equal entity_1.id

      result = @adapter.query(collection).order(:age).limit(1).offset(1).all
      result.count.must_equal 1
      result.first.id.must_equal entity_2.id
    end

    it 'ordering result' do
      entities = [entity_3, entity_1, entity_2]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.query(collection).order(:age).all

      result[0].id.must_equal entity_1.id
      result[1].id.must_equal entity_2.id
      result[2].id.must_equal entity_3.id
    end

    it 'selecting attributes' do
      entities = [entity_1]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.query(collection).select(:age).all

      result[0].id.must_equal entity_1.id
      result[0].name.must_be_nil
      result[0].age.must_equal entity_1.age
    end
  end

  describe '#first' do
    it 'returns nil when collection is empty' do
      result = @adapter.first(collection)
      result.must_be_nil
    end

    it 'returns first element based on key order' do
      entity_1 = TestUser.new(id: 31, name: 'test #1', age: 31)
      entity_2 = TestUser.new(id: 32, name: 'test #2', age: 32)
      entity_3 = TestUser.new(id: 33, name: 'test #3', age: 33)

      entities = [entity_3, entity_1, entity_2]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.first(collection)

      result.id.must_equal entity_1.id
    end
  end

  describe '#last' do
    it 'returns nil when collection is empty' do
      result = @adapter.last(collection)

      result.must_be_nil
    end

    it 'returns last element based on key order' do
      entity_1 = TestUser.new(id: 31, name: 'test #1', age: 31)
      entity_2 = TestUser.new(id: 32, name: 'test #2', age: 32)
      entity_3 = TestUser.new(id: 33, name: 'test #3', age: 33)

      entities = [entity_3, entity_1, entity_2]
      added_entities = entities.map { |e| @adapter.create(collection, e) }

      result = @adapter.last(collection)

      result.id.must_equal entity_3.id
    end
  end

  describe '#clear' do
    it 'raises an error' do
      -> { @adapter.clear(collection) }.must_raise NotImplementedError
    end
  end

  describe '#fetch' do
    it 'raises an error' do
      -> { @adapter.fetch(collection) }.must_raise NotImplementedError
    end
  end

  describe '#execute' do
    it 'raises an error' do
      -> { @adapter.execute(collection) }.must_raise NotImplementedError
    end
  end
end
