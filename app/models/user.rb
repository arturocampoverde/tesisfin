class User < ActiveRecord::Base
rolify
  
authenticates_with_sorcery!

attr_accessible :username, :email, :usu_estado, :password, :password_confirmation



has_and_belongs_to_many  :users_roles
belongs_to :persona  

validates_presence_of :username 
validates_uniqueness_of :username

  validates :email,
            :presence => true,
            :allow_blank => true,
            :uniqueness => true,
            :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }

  #validates_presence_of :email

 
validates_presence_of :password, :on => :create
validates_confirmation_of :password


  

  
end  
