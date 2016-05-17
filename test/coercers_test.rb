require 'test_helper'

describe Hanami::Gcloud::Datastore::Coercers::Key do
  let(:parent_parent) do
    key = Gcloud::Datastore::Key.new('ParentParent', 'parent-parent')
    key.project = 'project'
    key
  end

  let(:parent) do
    key = Gcloud::Datastore::Key.new('Parent', 'parent')
    key.namespace = 'namespace-parent'
    key.parent = parent_parent
    key.project = 'project'
    key
  end

  let(:entity) do
    key = Gcloud::Datastore::Key.new('Kind', 'id')
    key.parent = parent
    key.namespace = 'namespace'
    key.project = 'project'
    key
  end

  let(:parametrized_parent_parent) do
    [parent_parent.kind, parent_parent.name, { 'project' => parent_parent.project }]
  end

  let(:encoded_parent_parent) do
    Base64.encode64(parametrized_parent_parent.to_json)
  end

  let(:parametrized_parent) do
    [
      parent.kind,
      parent.name,
      {
        'parent' => parametrized_parent_parent,
        'namespace' => 'namespace-parent',
        'project' => parent.project
      },
    ]
  end

  let(:encoded_parent) do
    Base64.encode64(parametrized_parent.to_json)
  end

  let(:parametrized_entity) do
    [
      'Kind',
      'id',
      {
        'parent' => parametrized_parent,
        'namespace' => 'namespace',
        'project' => entity.project
      }
    ]
  end

  let(:encoded_entity) do
    Base64.encode64(parametrized_entity.to_json)
  end

  describe '.create' do
    let(:key_parent_parent) { ['ParentParent', 'parent-parent', 'project' => 'project'] }
    let(:key_parent) { ['Parent', 'parent', 'parent' => key_parent_parent, 'namespace' => 'namespace-parent', 'project' => 'project'] }
    let(:key_entity) { ['Kind', 'id', 'parent' => key_parent, 'namespace' => 'namespace', 'project' => 'project'] }

    it 'simple kind and name' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.create(*key_parent_parent)
      subject.must_equal encoded_parent_parent
    end

    it 'with kind, name and one level of parent' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.create(*key_parent)
      subject.must_equal encoded_parent
    end

    it 'with kind, name and two levels of parent' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.create(*key_entity)
      subject.must_equal encoded_entity
    end
  end

  describe '.dump' do
    it 'simple kind and name' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.dump(encoded_parent_parent)

      subject.kind.must_equal parent_parent.kind
      subject.name.must_equal parent_parent.name
      subject.project.must_equal parent_parent.project
      subject.namespace.must_be_nil
    end

    it 'with kind, name and one level of parent' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.dump(encoded_parent)

      subject.kind.must_equal parent.kind
      subject.name.must_equal parent.name
      subject.project.must_equal parent.project
      subject.namespace.must_equal parent.namespace

      subject.parent.kind.must_equal parent_parent.kind
      subject.parent.name.must_equal parent_parent.name
      subject.parent.project.must_equal parent_parent.project
      subject.parent.namespace.must_be_nil
    end

    it 'with kind, name and two levels of parent' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.dump(encoded_entity)

      subject.kind.must_equal entity.kind
      subject.name.must_equal entity.name
      subject.project.must_equal entity.project
      subject.namespace.must_equal entity.namespace

      subject.parent.kind.must_equal parent.kind
      subject.parent.name.must_equal parent.name
      subject.parent.project.must_equal parent.project
      subject.parent.namespace.must_equal parent.namespace

      subject.parent.parent.kind.must_equal parent_parent.kind
      subject.parent.parent.name.must_equal parent_parent.name
      subject.parent.parent.project.must_equal parent_parent.project
      subject.parent.parent.namespace.must_be_nil
    end
  end

  describe '.load' do
    it 'simple kind and name' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.load(parent_parent)
      subject.must_equal encoded_parent_parent
    end

    it 'with kind, name and one level of parent' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.load(parent)
      subject.must_equal encoded_parent
    end

    it 'with kind, name and two levels of parent' do
      subject = Hanami::Gcloud::Datastore::Coercers::Key.load(entity)
      subject.must_equal encoded_entity
    end
  end
end
