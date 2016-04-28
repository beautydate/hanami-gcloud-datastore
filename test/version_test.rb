require 'test_helper'

describe Hanami::Gcloud::Datastore::VERSION do
  it 'returns current version' do
    ::Hanami::Gcloud::Datastore::VERSION.must_equal '0.1.0'
  end
end
