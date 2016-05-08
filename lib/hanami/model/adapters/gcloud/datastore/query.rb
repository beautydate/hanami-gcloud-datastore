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
            def initialize(dataset, collection, mapped_collection, &blk)
              @dataset = dataset
              @collection = collection
              @mapped_collection = mapped_collection
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

            # Adds a `WHERE` condition.
            #
            # It accepts a `Hash` with only one pair.
            # The key must be the name of the column expressed as a `Symbol`.
            # The value is the one used by the query
            #
            # @param condition [Hash]
            #
            # @return self
            #
            # @since 0.1.0
            #
            # @example Fixed value
            #
            #   query.where(language: 'ruby')
            #
            # @example Multiple conditions
            #
            #   query.where(language: 'ruby')
            #        .where(framework: 'hanami')
            #
            # @example Expressions
            #
            #   query.where{ age > 10 }
            def where(condition = nil, &blk)
              _push_to_conditions(:where, condition || blk)
              self
            end

            alias_method :and, :where

            # Limit the number of entities to return.
            #
            # This operation is performed at the datastore level with `LIMIT`.
            #
            # @param number [Fixnum]
            #
            # @return self
            #
            # @since 0.1.0
            #
            # @example
            #
            #   query.limit(1)
            def limit(number)
              conditions.push([:limit, number])
              self
            end

            # Specify an `OFFSET` clause.
            #
            # @param number [Fixnum]
            #
            # @return self
            #
            # @since 0.1.0
            #
            # @example
            #
            #   query.limit(1).offset(10)
            def offset(number)
              conditions.push([:offset, number])
              self
            end

            # Specify the ascending order of the entities, sorted by the given
            # columns.
            #
            # @param columns [Array<Symbol>] the column names
            #
            # @return self
            #
            # @since 0.1.0
            def order(name, direction = :asc)
              conditions.push([:order, _mapped_attribute(name), direction])
              self
            end

            # Group by the specified columns.
            #
            # @param columns [Array<Symbol>]
            #
            # @return self
            #
            # @since 0.1.0
            #
            # @example Single column
            #
            #   query.group(:name)
            #
            # @example Multiple columns
            #
            #   query.group(:name, :year)
            def group(*columns)
              conditions.push([:group_by, *columns.map { |c| _mapped_attribute(c) }])
              self
            end

            # Select only the specified columns.
            #
            # By default a query selects all the columns of a entity.
            #
            # @param columns [Array<Symbol>]
            #
            # @return self
            #
            # @since 0.1.0
            #
            # @example Single column
            #
            #   query.select(:name)
            #
            # @example Multiple columns
            #
            #   query.select(:name, :year)
            def select(*columns)
              conditions.push([:select, *columns.map { |c| _mapped_attribute(c) }])
              self
            end

            # Resolves the query by fetching entities from the datastore and
            # translating them into entities.
            #
            # @return [Array] a collection of entities
            #
            # @since 0.1.0
            def all
              @collection.deserialize(@dataset.run(scoped))
            end

            private

            def _mapped_attribute(attribute)
              @mapped_collection.attributes[attribute].mapped.to_s
            end

            def _push_to_conditions(condition_type, condition)
              raise ArgumentError.new('You need to specify a condition') if condition.nil?

              case condition
              when Hash
                condition.each_pair do |field, value|
                  conditions.push([
                    condition_type,
                    _mapped_attribute(field), '=', value
                  ])
                end
              when Proc
                condition = Sequel.virtual_row(&condition)
                conditions.push([
                  condition_type,
                  _mapped_attribute(condition.args[0].value), condition.op, condition.args[1]
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
