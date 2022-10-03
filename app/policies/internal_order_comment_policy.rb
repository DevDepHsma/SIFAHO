class InternalOrderCommentPolicy < ApplicationPolicy
  def show?
    index?
  end
end