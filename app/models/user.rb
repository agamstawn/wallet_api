class User < ApplicationRecord
  include Walletable
  has_many :sessions, dependent: :destroy

  ITERATIONS = 100_000

  attr_reader :password

  before_validation { self.email = email.to_s.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, if: :password_required?
  validates :password_digest, presence: true

  # Password hashing memakai PBKDF2-HMAC-SHA256 dari OpenSSL (stdlib Ruby), tanpa gem.
  def password=(plain)
    @password = plain
    return if plain.blank?
    salt = SecureRandom.hex(16)
    self.password_digest = "#{salt}$#{hash_password(plain, salt)}"
  end

  def authenticate(plain)
    salt, digest = password_digest.to_s.split("$", 2)
    return false if salt.blank? || digest.blank?
    expected = hash_password(plain.to_s, salt)
    ActiveSupport::SecurityUtils.secure_compare(expected, digest) ? self : false
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def hash_password(plain, salt)
    OpenSSL::PKCS5.pbkdf2_hmac(plain, salt, ITERATIONS, 32, "sha256").unpack1("H*")
  end
end
