require 'gcloud/datastore'
require 'hanami/model/adapters/abstract'
require 'hanami/model/adapters/implementation'
require 'hanami/model/adapters/gcloud/datastore/collection'
require 'hanami/model/adapters/gcloud/datastore/command'
require 'hanami/model/adapters/gcloud/datastore/query'

module Hanami
  module Model
    module Adapters
      module Gcloud
        # Adapter for Gcloud Datastore
        #
        # @api private
        # @since 0.1.0
        class DatastoreAdapter < Abstract
          include Implementation

          # Initialize the adapter.
          #
          # Hanami::Model uses Gcloud::Datastore.
          # For a complete reference of the connection please see:
          # http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore.html
          #
          # @param mapper [Object] the database mapper
          #
          # @return [Hanami::Model::Adapters::Gcloud::DatastoreAdapter]
          #
          # @see Hanami::Model::Mapper
          #
          # @api private
          # @since 0.1.0
          def initialize(mapper)
            super

            @connection = ::Gcloud.datastore

            @collections = {}
          end

          # Creates a entity in the datastore for the given hanami entity.
          # It assigns the `id` attribute, in case of success.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param entity [#id=] the entity to create
          #
          # @return [Object] the entity
          #
          # @api private
          # @since 0.1.0
          def create(collection, entity)
            command(
              query(collection)
            ).create(entity)
          end

          # Returns a unique record from the given collection, with the given
          # id.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param id [Object] the identity of the object.
          #
          # @return [Object] the entity or nil if not found
          #
          # @api private
          # @since 0.1.0
          def find(collection, id)
            command(
              query(collection)
            ).find(id)
          end

          # Fabricates a command for the given query.
          #
          # @param query [Hanami::Model::Adapters::Gcloud::Datastore::Query] the
          #   query object to act on.
          #
          # @return [Hanami::Model::Adapters::Gcloud::Datastore::Command]
          #
          # @see Hanami::Model::Adapters::Gcloud::Datastore::Command
          #
          # @api private
          # @since 0.1.0
          def command(query)
            Datastore::Command.new(query)
          end

          # Fabricates a query
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param blk [Proc] a block of code to be executed in the context of
          #   the query.
          #
          # @return [Hanami::Model::Adapters::Gcloud::Datastore::Query]
          #
          # @see Hanami::Model::Adapters::Gcloud::Datastore::Query
          #
          # @api private
          # @since 0.1.0
          def query(collection, context = nil, &blk)
            Datastore::Query.new(_collection(collection), context, &blk)
          end

          private

          # Returns a collection from the given name.
          #
          # @param name [Symbol] a name of the collection (it must be mapped).
          #
          # @return [Hanami::Model::Adapters::Gcloud::Datastore::Collection]
          #
          # @see Hanami::Model::Adapters::Gcloud::Datastore::Collection
          #
          # @api private
          # @since 0.1.0
          def _collection(name)
            Datastore::Collection.new(@connection, _mapped_collection(name))
          end
        end
      end
    end
  end
end
