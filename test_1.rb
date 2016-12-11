# User Model
class User < ApplicationRecord
  has_many :purchases
  validates :email, presence: true, uniqueness: true
end

# Purchase Model
class Purchase < ApplicationRecord
   PURCHASE_STATUS = { :draft => "DRAFT",
                       :completed => "COMPLETED",
                       :cancelled => "CANCELLED" }
  belongs_to :user
  validates :status, presence: true, inclusion: { in: PURCHASE_STATUS.values }
end

# Migration
class CreateModels < ActiveRecord::Migration
  def change
    create_table :users do |t|
      #id, email, name
      t.string :email, null: false
      t.string :name
    end
    add_index :users, :email, unique: true

    create_table :purchases do |t|
      #id, user_id, status, purchased_at
      t.references :user, null: false
      t.string :status
      t.datetime :purchased_at
    end
  end
end

# User Controller
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      ApplicationMailer.welcome(@user).deliver
      format.html { redirect_to @user, notice: 'User was successfully created.' }
      format.json { render :show, status: :created, location: @user }
    else
      format.html { render :new }
      format.json { render json: @user.errors, status: :unprocessable_entity }
    end
  end

  private
  # Only allow a trusted parameters
  def user_params
    params.require(:user).permit(:email, :name)
  end
end

# Mailer
class ApplicationMailer < ActionMailer::Base
  default from: "test@gmail.com"

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'welcome mail')
  end
end

# Testting User Model
RSpec.describe User, type: :model do
  it "should have a unique email" do
    User.create!(:email=>"test@gmail.com")
    user = User.new(:email=>"test@gmail.com")
    user.should_not be_valid
  end
end

# Testing Purchase Model
RSpec.describe Purchase, type: :model do
  describe "#Status" do
    it "fails validation if no status present" do
      purchase = FactoryGirl.build(:purchase, :status => nil)
      expect(purchase).not_to be_valid
    end

    it "fails validation if status not valid" do
      purchase = FactoryGirl.build(:purchase, :status => "dummystatus")
      expect(purchase).not_to be_valid
    end

    it "saves with valid params" do
      purchase = FactoryGirl.build(:purchase, :status => Purchase::PURCHASE_STATUS.values.first)
      expect(purchase).to be_valid
    end
  end
end

# Testing User controller create action
describe "User create" do
  context "with valid attributes" do
    it "creates a new UsersController" do
      expect{
        post :create, user: Factory.attributes_for(:user)
      }.to change(User,:count).by(1)
    end

    it "redirects to the new user" do
      post :create, user: Factory.attributes_for(:user)
      response.should redirect_to User.last
    end
  end

  context "with invalid attributes" do
    it "does not save the new user" do
      expect{
        post :create, user: Factory.attributes_for(:invalid_user)
      }.to_not change(User,:count)
    end

    it "re-renders the new user" do
      post :create, user: Factory.attributes_for(:invalid_user)
      response.should render_template :new
    end
  end
end

# Testing Application Mailer
RSpec.describe ApplicationMailer do
  let(:user) {FactoryGirl.build(:user, :email => "customer@gmail.com")}

  it 'sends an email' do
    expect { ApplicationMailer.welcome(user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end

# Tasks
(1) Fill database migrations (to create tables for Users & Purchases), write validations and add additional business logic in models if required.
    Keep in mind that:
    (a) Each User must have a unique email address
    (b) Possible User status values are: draft, completed, cancelled
(2) Add some logic to :create action inside UsersController.
  Let's pretend that there was a request with all required User attributes already sent from :new form and now :create action gets called to handle such request, to:
    (a) Create a new User (based on params received in request) and save him in database if possible.
    (b) If User gets saved in database, send him Welcome Email with some greetings. *Use ApplicationMailer for that. Add there new :welcome action to send such emails. No need to write any html, back-end logic will be just enough.
    (c) Handle negative cases (for [2.a] task) if User is not valid and it is not possible to save him in database.
    (d) You are allowed to use any best practices or patterns you know and prefer. Any additional solutions/ideas for best customer experience are a big plus.
    (e) Cover Models and Controller with Unit tests (Minitest syntax) OR with Unit specs (RSpec syntax).
