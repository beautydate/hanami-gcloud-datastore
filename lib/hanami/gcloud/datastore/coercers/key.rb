require 'hanami/model/coercer'
require 'base64'
require 'json'
require 'google/cloud/datastore/key'

module Hanami
  module Gcloud
    module Datastore
      module Coercers
        class Key < Hanami::Model::Coercer
          def initialize(value)
            @value = value
          end

          def self.dump(value)
            new(value).dump
          end

          def dump
            deserialize_key(*JSON.parse(Base64.decode64(@value)))
          rescue
            nil
          end

          def self.load(value)
            new(value).load
          end

          def load
            Base64.encode64(serialize_key(@value).to_json.to_s)
          end

          def self.create(*value)
            new(value).create
          end

          def create
            Base64.encode64(@value.to_json.to_s)
          end

          private

          def serialize_key(value)
            _key = [value.kind, value.id || value.name]

            opts = {}
            opts['parent']    = serialize_key(value.parent) if !value.parent.nil?
            opts['namespace'] = value.namespace if !value.namespace.nil? && !value.namespace.empty?
            opts['project']   = value.project if !value.project.nil?
            _key << opts if !opts.empty?

            _key
          end

          def deserialize_key(kind, id, opts = {})
            key = Google::Cloud::Datastore::Key.new kind, id
            key.namespace = opts['namespace'] if opts.include? 'namespace'
            key.project = opts['project'] if opts.include? 'project'
            key.parent = deserialize_key(*opts['parent']) if opts.include? 'parent'
            key
          end
        end
      end
    end
  end
end
