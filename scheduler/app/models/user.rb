require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :roles
  
  acts_as_urlnameable :login, :overwrite => true
  acts_as_messageable
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email, :name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => true
  #validates_uniqueness_of   :identity_url, :on => :save
  #validates_presence_of     :identity_url
  
  before_save :encrypt_password
  before_create :make_activation_code 
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :identity_url, :name
  
  has_many :authorships, :dependent => :destroy
  has_many :programs, :through => :authorships

  def to_param
    self.urlname
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    self.make_admin_if_first_user
    save(false)
  end
  
  def self.administrators
    find(:all).select { |u| u.has_role?('admin') }
  end
  
  def self.editors
    find(:all).select { |u| u.has_role?('editor') }
  end

  def self.authors
    find(:all).select { |u| u.is_author? }
  end
  
  def self.find_author_by_urlname(urlname)
    u = find_by_urlname(urlname)
    if u.is_author? 
      u 
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  # TODO Replace this with actual password generator
  def generate_password
    self.password = "1234"
  end
  
  def self.get(identity_url)
    find(:first, :conditions => ["identity_url = ?", identity_url])
  end
  
  # Gives a role to the user
  def give_role(name)
    r = Role.new(:name => name, :user => self)
    self.roles << r
    save(false)
  end
  
  # Takes a role from the user
  def take_role(name)
    r = self.roles.find_by_name(name)
    r.destroy unless r.nil?
    save(false)
  end
  
  # Returns true if the user has any authorships
  def is_author?
    !self.authorships.empty?
  end
  
  # Takes a name and tests if the user is an author for that program
  def is_author_of?(name)
    self.is_author? and !self.programs.find_by_name(name).nil?
  end
  
  def mailboxes
    [{ :id => 'inbox', :name => 'Inbox' }, 
     { :id => 'sentbox', :name => 'Sentbox' }, 
     { :id => 'trash', :name => 'Trash' }]
  end
  
  # Requirement for the 'Declarative Authorization' plugin
  # Returns an array of symbols with roles associated with the user
  def role_symbols
     (roles || []).map {|r| r.name.to_sym} + [self.is_author? ? :author : []].flatten
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.user do
      xml.tag!(:id, self.urlname, :type => 'string')
      xml.tag!(:name, self.name, :type => 'string')
    end
  end

  protected
  
  def make_admin_if_first_user
    if User.count == 1
      self.give_role('admin')
    end
  end
  
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

end
