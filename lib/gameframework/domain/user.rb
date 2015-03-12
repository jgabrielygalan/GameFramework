class User
	include Mongoid::Document
	field :_id, as: :name
	field :password_salt, type: String
	field :password_hash, type: String

	attr_accessor :password

	before_save :prepare_password

	def prepare_password
		unless password.blank?
			self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
			self.password_hash = encrypt_password(password)
		end
	end

	def encrypt_password(pass)
		Digest::SHA1.hexdigest([pass, password_salt].join)
	end

	def self.authenticate(login, pass)
		user = find(login)
		return user if user && user.password_matches?(pass)
	end
	
	def password_matches?(pass)
		self.password_hash == encrypt_password(pass)
	end	
end