require 'sequel/core'
require 'forwardable'
require 'hanami/utils/kernel'

module Hanami
  module Model
    module Adapters
      module Gcloud
        module Datastore
          # Query the database with a powerful API.
          #
          # All the methods are chainable, it allows advanced composition of
          # Datastore conditions.
          #
          # @example
          #
          #   query.where(language: 'ruby')
          #        .and(framework: 'hanami').all
          #
          # It implements Ruby's `Enumerable` and borrows some methods from `Array`.
          # Expect a query to act like them.
          #
          # @since 0.1.0
          class Query
            include Enumerable
            extend  Forwardable

            def_delegators :all, :each, :to_s, :empty?

            # @attr_reader conditions [Array] an accumulator for the called
            #   methods
            #
            # @since 0.1.0
            # @api private
            attr_reader :conditions

            # Initialize a query
            #
            # @param collection [Hanami::Model::Adapters::Gcloud::Datastore::Collection]
            #   the collection to query
            #
            # @param blk [Proc] an optional block that gets yielded in the
            #   context of the current query
            #
            # @return [Hanami::Model::Adapters::Gcloud::Datastore::Query]
            def initialize(dataset, collection, &blk)
              @dataset, @collection = dataset, collection
              @conditions = []

              instance_eval(&blk) if block_given?
            end

            # Apply all the conditions and returns a filtered collection.
            #
            # This operation is idempotent, and the returned result didn't
            # fetched the records yet.
            #
            # @return [Hanami::Model::Adapters::Gcloud::Datastore::Collection]
            #
            # @since 0.1.0
            def scoped
              scope = @dataset.query(@collection.kind)

              conditions.each do |(method,*args)|
                scope = scope.public_send(method, *args)
              end

              scope
            end

            alias_method :run, :scoped

            def where(condition = nil, &blk)
              _push_to_conditions(:where, condition || blk)
              self
            end

            def all
              @collection.deserialize(@dataset.run(scoped))
            end

            def _push_to_conditions(condition_type, condition)
              raise ArgumentError.new('You need to specify a condition') if condition.nil?

              case condition
              when Hash
                condition.each_pair do |field, value|
                  conditions.push([
                    condition_type,
                    field.to_s, '=', value
                  ])
                end
              when Proc
                condition = Sequel.virtual_row(&condition)
                conditions.push([
                  condition_type,
                  condition.args[0].value.to_s, condition.op, condition.args[1]
                ])
              else
                raise ArgumentError.new('This type is unsupported type for condition')
              end
            end
          end
        end
      end
    end
  end
end
