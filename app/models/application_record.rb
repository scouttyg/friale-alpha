class ApplicationRecord < ActiveRecord::Base
  include Hashid::Rails
  primary_abstract_class

  scope :oldest_first, -> { order(id: :asc) }
  scope :newest_first, -> { order(id: :desc) }

  scope :created_after, ->(date_time = 1.week.ago) { where("#{table_name}.created_at > ?", date_time) }
  scope :created_before, ->(date_time = 1.week.ago) { where("#{table_name}.created_at < ?", date_time) }
  scope :created_between, lambda { |start_date, end_date|
    where("#{table_name}.created_at >= :start_date AND #{table_name}.created_at < :end_date", start_date: start_date, end_date: end_date)
  }

  scope :updated_after, ->(date_time = 1.week.ago) { where("#{table_name}.updated_at > ?", date_time) }
  scope :updated_before, ->(date_time = 1.week.ago) { where("#{table_name}.updated_at < ?", date_time) }
  scope :updated_between, lambda { |start_date, end_date|
    where("#{table_name}.updated_at >= :start_date AND #{table_name}.updated_at < :end_date", start_date: start_date, end_date: end_date)
  }

  def self.ransackable_attributes(_auth_object = nil)
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    authorizable_ransackable_associations
  end
end
