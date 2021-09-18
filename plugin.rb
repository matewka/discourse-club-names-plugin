# name: club-names-plugin
# about: Plugin for displaying user full names only to members of the same club (group)
# version: 0.0.1
# authors: CelPal

after_initialize {
  require_dependency 'basic_user_serializer'

  class ::BasicUserSerializer
    attributes :name

    def name
      if object&.id == scope.user&.id
        return _old_name_method
      else
        # TODO: make this list editable
        clubGroups = Array['ksi']

        if scope.user
          ownGroups = GroupUser.where(user_id: scope.user.id)
                               .map { |gu| gu.group_id }
                               .map { |group_id| Group.find_by(id: group_id) }
                               .filter { |group| clubGroups.include? group.name }

          if ownGroups.length > 0
            ownGroupsIds = ownGroups.map { |g| g.id }

            if GroupUser.exists?(user_id: user.id, group_id: ownGroupsIds)
              return _old_name_method
            end
          end
        end
      end

      return ''
    end

    private def _old_name_method
      return Hash === user ? user[:name] : user.try(:name)
    end
  end
}
