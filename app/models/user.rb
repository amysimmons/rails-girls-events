# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string
#  email                  :string
#  track                  :string
#  previous_attendance    :string
#  programming_experience :text
#  reason                 :text
#  tshirt_size            :string
#  admin_status           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  under_18               :boolean
#  user_status            :string
#  gender                 :string
#  dietary_requirements   :json
#

class User < ActiveRecord::Base
  validates :name, :email, :track, :previous_attendance, :programming_experience,
            :reason, :tshirt_size, :gender, presence: true
  validates_inclusion_of :under_18, in: [true, false]


  # relations
  acts_as_commentable
  has_many :votes

  def count_up_votes
    @votes = Vote.all
    @votes.select{|vote| vote.user_id == self.id && vote.vote_type == 'up'}.count
  end

  def count_down_votes
    @votes = Vote.all
    @votes.select{|vote| vote.user_id == self.id && vote.vote_type == 'down'}.count
  end

  def age
    if under_18
      'Under 18'
    else
      'Over 18'
    end
  end

  def send_application_thanks
    UserMailer.application_received(self).deliver
  end

  def needs_admin_response?
    admin_status == 'applied' || admin_status == 'deferred'
  end

  def send_admin_status_email
    puts "EMAIL_LOG: Trying to send admin email"
    puts "EMAIL_LOG: admin_status: #{admin_status}"
    case admin_status
    when 'approved'
      puts "EMAIL_LOG: trying to send approved email"
      UserMailer.application_success(self).deliver
    when 'deferred'
      puts "EMAIL_LOG: trying to send deferred email"
      UserMailer.application_deferred(self).deliver
    when 'rejected'
      puts "EMAIL_LOG: trying to send rejected email"
      UserMailer.application_rejected(self).deliver
    end
  end

  # TODO: move to helpers - it's only relevant for the views
  def admin_status_icon
    case admin_status
    when 'applied'
      'fa-exclamation-triangle'
    when 'approved'
      'fa-check'
    when 'deferred'
      'fa-clock-o'
    when 'rejected'
      'fa-times'
    end
  end

  # TODO: move to helpers - it's only relevant for the views
  def user_status_icon
    case user_status
    when 'accepted'
      'fa-check'
    when 'declined'
      'fa-times'
    end
  end

#FOR the data page
  def self.approved_count
    User.where(:admin_status => 'approved').count
  end

  def self.deferred_count
    User.where(:admin_status => 'deferred').count
  end

  def self.rejected_count
    User.where(:admin_status => 'rejected').count
  end

  def self.accepted_count
    User.where(:user_status => 'accepted').count
  end

  def self.declined_count
    User.where(:user_status => 'declined').count
  end

  def self.beginner_count
    User.where(:track => 'beginner', :user_status => 'accepted').count
  end

  def self.next_count
    User.where(:track => 'next', :user_status => 'accepted').count
  end

  def self.has_dietary_requirement
    users = User.where(:user_status => 'accepted')
    users_without_nil = users.select{|u| !u[:dietary_requirements].nil?}
    users_without_nil.select {|u|u[:dietary_requirements].to_a.exclude? 'none'}
  end

  def self.xs_count
    User.where(:tshirt_size => 'XS', :user_status => 'accepted').count
  end

  def self.s_count
    User.where(:tshirt_size => 'S', :user_status => 'accepted').count
  end

  def self.m_count
    User.where(:tshirt_size => 'M', :user_status => 'accepted').count
  end

  def self.l_count
    User.where(:tshirt_size => 'L', :user_status => 'accepted').count
  end

  def self.xl_count
    User.where(:tshirt_size => 'XL', :user_status => 'accepted').count
  end
end
