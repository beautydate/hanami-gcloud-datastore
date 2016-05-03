module Hanami
  module Model
    module Adapters
      module Gcloud
        module Datastore
          # Maps a Datastore dataset and perfoms manipulations on it.
          #
          # @api private
          # @since 0.1.0
          #
          # @see http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore/Dataset.html
          # @see http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore/Query.html
          class Collection
            # Initialize a collection
            #
            # @param dataset [Gcloud::Datastore::Dataset] the dataset that maps
            #   a table or a subset of it.
            # @param mapped_collection [Hanami::Model::Mapping::Collection] a
            #   mapped collection
            #
            # @return [Hanami::Model::Adapters::Gcloud::Datastore::Collection]
            #
            # @api private
            # @since 0.1.0
            def initialize(dataset, mapped_collection)
              @dataset, @mapped_collection = dataset, mapped_collection
            end

            # Persists an entity for the given hanami entity and assigns an id.
            #
            # @param entity [Object] the entity to persist
            #
            # @see Hanami::Model::Adapters::Gcloud::Datastore::Command#create
            #
            # @api private
            # @since 0.1.0
            def persist(entity)
              persist_entity = @dataset.entity key_for(entity)
              _serialize(entity).each_pair do |key, value|
                persist_entity[key.to_s] = value
              end

              entity.id = @dataset.save(persist_entity).first.key.id
              entity
            end

            # Finds an entity for the given hanami entity and assigns an id.
            #
            # @param entity [Object] the entity to persist
            #
            # @return the primary key of the created record
            #
            # @api private
            # @since 0.1.0
            def find(id)
              entity = @dataset.find kind, id
              return nil if entity.nil?
              _deserialize(entity)
            end

            # Deletes an entity
            #
            # @param entity [Object] the entity to delete
            #
            # @api private
            # @since 0.1.0
            def delete(entity)
              @dataset.delete key_for(entity)
            end

            # Return datastore kind name for entity
            #
            # @return [String] entity Kind
            #
            # @api private
            # @since 0.1.0
            def kind
              @mapped_collection.entity.to_s
            end

            private

            # Return datastore key for entity
            #
            # @return [Gcloud::Datastore::Key] entity key
            #
            # @api private
            # @since 0.1.0
            def key_for(entity)
              @dataset.key kind, entity.id
            end

            # Serialize the given entity before to persist in the datastore.
            #
            # @return [Hash] the serialized entity
            #
            # @api private
            # @since 0.1.0
            def _serialize(entity)
              @mapped_collection.serialize(entity)
            end

            # Deserialize the given datastore entity to return
            #
            # @return [Hash] the deserialized entity
            #
            # @api private
            # @since 0.1.0
            def _deserialize(entity)
              @mapped_collection.entity.new(
                entity.properties.to_h.merge(id: entity.key.id)
              )
            end
          end
        end
      end
    end
  end
end
