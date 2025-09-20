class AccountMemberPolicy < ApplicationPolicy
  attr_reader :account

  def initialize(context, record)
    super(context[:user], record, context[:account])
  end

  def create?
    return false if account.blank?
    return false if current_plan.blank?
    return false unless user_can_manage_members?

    current_member_count = account.members.where.not(id: nil).size
    limit = current_plan.member_limit.to_i
    current_member_count < limit
  end

  def edit?
    create?
  end

  def destroy?
    account.owner == user || user == record
  end

  private

  def current_plan
    account.plan
  end

  def user_can_manage_members?
    return true if account.owner == user

    member = account.members.find_by(user: user)
    member&.collaborator_or_higher?
  end

  class Scope
    attr_reader :user, :scope, :account

    def initialize(context, scope)
      @user = context[:user]
      @account = context[:account]
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
