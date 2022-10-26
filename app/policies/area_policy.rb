class AreaPolicy < ApplicationPolicy
  def index?
    false
  end

  def tree_view?
    false
  end

  def show?
    index?
  end

  def create?
    false
  end

  def create_applicant?
    new_applicant?
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end
end
  