class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include Paper::Roles::User
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  field :name
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :null => false, :default => ""
  field :encrypted_password, :type => String, :null => false, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  
  ## Encryptable
  # field :password_salt, :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  
  def self.find_by_email(email)
    self.where(:email => email).first
  end
  
  def self.create_owner
    
    user = self.find_by_email(Paper.config.owner.email) || self.new
    
    user.name                  = Paper.config.owner.name
    user.email                 = Paper.config.owner.email
    user.password              = Paper.config.owner.password
    user.password_confirmation = Paper.config.owner.password
    
    Paper::Roles::User::ROLES.each { |role| user.add_role(role) }
     
    user.save
  end
  
  def is_owner?
    self.email == Paper.config.owner.email
  end
  
  # wether the user 'u' can delete this user
  # always false if this user is the owner
  def can_delete?(u)
    u && !is_owner? && u.has_role?(:delete_users)
  end
end
