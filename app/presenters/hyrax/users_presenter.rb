module Hyrax
  class UsersPresenter

    attr_reader :query, :authentication_key

    def initialize(query:, authentication_key:)
      @query = query
      @authentication_key = authentication_key
    end

    # @return [Array] an array of Users
    def users
      @users = search(query)
    end

    def user_count
      ::User.not_batch_or_audit_user.count
    end

    def repository_admin_count
      count_admin = 0
      users.each do |user|
        count_admin +=1 if is_admin?(user)
      end
      count_admin
    end

    def user_roles(user)
      roles = user.groups
      return roles if roles.any?
      return ['']
    end

    protected

    def is_admin?(user)
      user.groups.include? 'admin'
    end

    # Returns a list of users excluding the system users and guest_users
    # @param query [String] the query string
    def search(query)
      clause = query.blank? ? nil : "%" + query.downcase + "%"
      base = ::User.where(*base_query)
      unless clause.blank?
        base = base.where("#{authentication_key} like lower(?) OR display_name like lower(?)", clause, clause)
      end
      base.registered.not_batch_or_audit_user
    end

    # You can override base_query to return a list of arguments
    def base_query
      [nil]
    end
  end
end