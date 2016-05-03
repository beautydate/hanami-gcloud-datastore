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

    class TestDevice
      include Hanami::Entity
      attributes :id
    end

    class TestDeviceRepository
      include Hanami::Repository
    end

    @mapper = Hanami::Model::Mapper.new do
      collection :test_users do
        entity TestUser

        attribute :id,   String
        attribute :name, String
        attribute :age,  Integer
      end

      collection :test_devices do
        entity TestDevice

        attribute :id, String
      end
    end.load!

    @adapter = Hanami::Model::Adapters::Gcloud::DatastoreAdapter.new(
      @mapper
    )
  end

  after do
    Object.send(:remove_const, :TestUser)
    Object.send(:remove_const, :TestUserRepository)
    Object.send(:remove_const, :TestDevice)
    Object.send(:remove_const, :TestDeviceRepository)
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
    let(:entity) { TestUser.new(name: 'test', age: 30) }

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
    let(:entity) { TestUser.new(name: 'test', age: 30) }

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
    let(:entity) { TestUser.new(name: 'test', age: 30) }

    it 'when no entity are persisted' do
      @adapter.find(collection, -8).must_equal nil
    end

    it 'when entity are persisted' do
      result = @adapter.create(collection, entity)

      @adapter.find(collection, result.id).must_equal result
    end
  end

  describe '#delete' do
    let(:entity) { TestUser.new(name: 'test', age: 30) }

    it 'when entity are persisted' do
      subject = @adapter.create(collection, entity)

      @adapter.delete(collection, subject).must_equal true

      @adapter.find(collection, subject.id).must_equal nil
    end
  end

  describe '#clear' do
    it 'raises an error' do
      -> { @adapter.clear(collection) }.must_raise NotImplementedError
    end
  end
end
