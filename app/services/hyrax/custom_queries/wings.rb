module Hyrax
  module CustomQueries
    class Wings
      # Holds custom queries for wings
      # Use:
      # Hyrax.query_service.custom_queries.find_many_by_alternate_ids(alternate_ids: ids, use_valkyrie: true)

      def self.queries
        [:find_many_by_alternate_ids]
      end

      attr_reader :query_service
      delegate :resource_factory, to: :query_service

      def initialize(query_service:)
        @query_service = query_service
      end

      # implements a combination of two Valkyrie queries:
      # => find_many_by_ids & find_by_alternate_identifier
      # @param [Enumerator<#to_s>] ids
      # @param [boolean] defaults to true; optionally return ActiveFedora::Base objects if false
      # @return [Array<Valkyrie::Resource>, Array<ActiveFedora::Base>]
      def find_many_by_alternate_ids(alternate_ids:, use_valkyrie: true)
        af_objects = ActiveFedora::Base.find(alternate_ids.map(&:to_s))
        return af_objects unless use_valkyrie == true

        af_objects.map do |af_object|
          resource_factory.to_resource(object: af_object)
        end
      end
    end
  end
end
