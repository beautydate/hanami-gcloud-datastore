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
          # @see http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/v0.20.1/google/cloud/datastore/dataset
          # @see http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/v0.20.1/google/cloud/datastore/query
          class Collection
            # Initialize a collection
            #
            # @param dataset [Google::Cloud::Datastore::Dataset] the dataset that maps
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
              # binding.pry
              persist_entity = @dataset.entity key_for(entity)
              _serialize(entity).each_pair do |key, value|
                if key != @mapped_collection.identity
                  persist_entity[key.to_s] = value
                end
              end

              saved = @dataset.save(persist_entity).first
              entity.id = identity_coercer.load(saved.key)
              entity
            end

            # Finds an entity for the given hanami entity
            #
            # @api private
            # @since 0.1.0
            def find(id)
              if _id = identity_coercer.dump(id)
                entity = @dataset.find _id
              end

              return nil if entity.nil?
              _deserialize(entity)
            end

            # Returns first entity
            #
            # @api private
            # @since 0.1.0
            def first
              fetch_one(:asc)
            end

            # Returns last entity
            #
            # @api private
            # @since 0.1.0
            def last
              fetch_one(:desc)
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
              Hanami::Utils::String.new(@mapped_collection.name).
                classify.
                singularize.
                to_s
            end

            def deserialize(entities)
              entities.map do |entity|
                _deserialize(entity)
              end
            end

            private

            def fetch_one(order = :asc)
              query = @dataset.query(kind).order('__key__', order).limit(1)
              entity = @dataset.run(query).first
              return nil if entity.nil?
              _deserialize(entity)
            end

            def identity_coercer
              @mapped_collection.attributes[@mapped_collection.identity].send(:coercer)
            end

            # Return datastore key for entity
            #
            # @return [Google::Cloud::Datastore::Key] entity key
            #
            # @api private
            # @since 0.1.0
            def key_for(entity)
              if _id = entity.public_send(@mapped_collection.identity)
                return identity_coercer.dump(_id)
              end

              @dataset.key kind, nil
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
                @mapped_collection.attributes.inject({}) do |hash, (key, element)|
                  if key == @mapped_collection.identity
                    hash[key] = identity_coercer.load(entity.key)
                  else
                    hash[key] = element.send(:coercer).load(entity.properties[element.mapped.to_s])
                  end

                  hash
                end
              )
            end
          end
        end
      end
    end
  end
end
