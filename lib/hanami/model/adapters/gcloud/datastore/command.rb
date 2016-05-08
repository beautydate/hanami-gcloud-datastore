module Hanami
  module Model
    module Adapters
      module Gcloud
        module Datastore
          # Execute a command for the given query.
          #
          # @see Hanami::Model::Adapters::Gcloud::Datastore::Query
          #
          # @api private
          # @since 0.1.0
          class Command
            # Initialize a command
            #
            # @param query [Hanami::Model::Adapters::Gcloud::Datastore::Query]
            #
            # @api private
            # @since 0.1.0
            def initialize(collection)
              @collection = collection
            end

            # Creates an entity for the given hanami entity.
            #
            # @param entity [Object] the entity to persist
            #
            # @see Hanami::Model::Adapters::Gcloud::Dataset::Collection#persist
            #
            # @return the primary key of the just created record.
            #
            # @api private
            # @since 0.1.0
            def create(entity)
              @collection.persist(entity)
            end

            # Updates an entity for the given hanami entity.
            #
            # @param entity [Object] the entity to persist
            #
            # @see Hanami::Model::Adapters::Gcloud::Dataset::Collection#persist
            #
            # @api private
            # @since 0.1.0
            def update(entity)
              @collection.persist(entity)
            end

            # Persists an entity for the given hanami entity.
            #
            # @param entity [Object] the entity to persist
            #
            # @see Hanami::Model::Adapters::Gcloud::Dataset::Collection#persist
            #
            # @api private
            # @since 0.1.0
            def persist(entity)
              @collection.persist(entity)
            end

            # Finds an entity for the given hanami entity.
            #
            # @param id [Integer] the id of entity
            #
            # @see Hanami::Model::Adapters::Gcloud::Dataset::Collection#find
            #
            # @return the entity
            #
            # @api private
            # @since 0.1.0
            def find(id)
              @collection.find(id)
            end

            # Returns first entity from datastore
            #
            # @return the entity
            #
            # @api private
            # @since 0.1.0
            def first
              @collection.first
            end

            # Returns last entity from datastore
            #
            # @return the entity
            #
            # @api private
            # @since 0.1.0
            def last
              @collection.last
            end

            # Deletes datastore entity.
            #
            # @param entity [Object] the entity to delete
            #
            # @see Hanami::Model::Adapters::Gcloud::DatastoreAdapter#delete
            #
            # @api private
            # @since 0.1.0
            def delete(entity)
              @collection.delete(entity)
            end
          end
        end
      end
    end
  end
end