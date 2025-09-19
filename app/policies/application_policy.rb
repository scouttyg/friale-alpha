class ApplicationPolicy
  attr_reader :user, :record, :account

  def initialize(user, record, account = nil)
    @user = user
    @record = record
    @account = account
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
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

  def destroy?
    false
  end

  private

  def account
    # For new records, use the account passed in the record
    # For existing records, use the account they belong to
    @account ||= record.try(:account) || record.try(:account_id)
  end
end
