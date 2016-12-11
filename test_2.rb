class User < ApplicationRecord
  #id, email, name
  has_many :purchases
end

class Purchase < ApplicationRecord
  #id, user_id, status, purchased_at
  belongs_to :user
end

# It return the emails of users who made purchases in last 7 days and are completed.
def find_user_emails
  Purchase.where(status: 'COMPLETED').where('purchased_at >= ?', Time.zone.now - 7.days).find_in_batches do |batch|
    ids = batch.map(&:user_id)
    @user_emails = User.where(id: ids).pluck(:email)
  end
  return @user_emails
end


# Tasks
(1) Find all completed Purchases and purchased in last 7 days
(2) Find only Users with purchases found in task (1)
(3) Return only emails of Users found in task (2)
