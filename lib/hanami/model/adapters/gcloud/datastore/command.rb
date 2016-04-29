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
            def initialize(query)
              @collection = query.scoped
            end

            # Creates an entity for the given hanami entity.
            #
            # @param entity [Object] the entity to persist
            #
            # @see Hanami::Model::Adapters::Gcloud::Dataset::Collection#insert
            #
            # @return the primary key of the just created record.
            #
            # @api private
            # @since 0.1.0
            def create(entity)
              @collection.insert(entity)
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
          end
        end
      end
    end
  end
end