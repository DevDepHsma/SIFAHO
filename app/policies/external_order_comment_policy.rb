class ExternalOrderCommentPolicy < ApplicationPolicy
  def show?
    index?
  end
end