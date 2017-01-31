module Hyrax
  class UsersPresenter
    # @return [Array] an array of Users
    def users
      @users = User.all
    end

    def user_count
      users.count
    end

    def repository_administrator_count
      count_admins = 0
      users.each do |user|
         count_admins +=1 if user.user_groups.include? 'admin'
      end
      count_admins
    end

    def users_roles

    end
  end
end
