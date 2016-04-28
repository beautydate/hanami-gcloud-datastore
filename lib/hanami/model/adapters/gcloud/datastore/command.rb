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

            # Creates a entity for the given hanami entity.
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
          end
        end
      end
    end
  end
end