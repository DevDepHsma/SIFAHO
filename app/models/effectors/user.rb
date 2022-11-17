# == Schema Information

# Table name: users

#  username                 :string, default: "", null: false
#  encrypted_password       :string, default: "", null: false
#  reset_password_token     :string
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer, default: 0, null: false
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :inet
#  last_sign_in_ip          :inet
#  created_at               :datetime, null: false
#  updated_at               :datetime, null: false
#  sector_id                :bigint
#  status                   :integer, default: 0

class User < ApplicationRecord
  include PgSearch::Model
  devise :rememberable, :trackable, :database_authenticatable
  devise :ldap_authenticatable, authentication_keys: [:username]

  enum status: { permission_req: 0, active: 1, inactive: 2 }
  # Relaciones
  has_many :permission_users
  has_many :permissions, through: :permission_users
  has_many :user_sectors
  has_many :sectors, through: :user_sectors
  belongs_to :sector, optional: true
  has_many :establishments, through: :sectors
  has_one :profile, dependent: :destroy
  has_one :professional, dependent: :destroy
  has_many :external_order_comments
  has_many :reports, dependent: :destroy
  has_many :permission_requests, dependent: :destroy
  has_many :inpatient_prescription_products
  has_many :user_roles, dependent: :delete_all
  has_many :roles, through: :user_roles

  accepts_nested_attributes_for :profile, :professional
  accepts_nested_attributes_for :permission_users, allow_destroy: true, update_only: true,
                                                   reject_if: :permission_exists?
  accepts_nested_attributes_for :user_roles, allow_destroy: true, update_only: true, reject_if: :role_exists?
  accepts_nested_attributes_for :user_sectors, allow_destroy: true, update_only: true, reject_if: :sector_exists?

  validates :username, presence: true, uniqueness: true
  validate :validate_max_sectors

  # validates_with CustomValidators::UserValidator, on: :update

  after_create :create_profile
  after_save :verify_profile

  # Delegaciones
  delegate :full_name, :first_name, :dni, :email, to: :profile
  delegate :name, :applicant_internal_orders, :applicant_external_orders, :provider_internal_orders,
           :provider_external_orders, :establishment_short_name,
           to: :sector, prefix: :sector, allow_nil: true
  delegate :establishment_name, to: :sector, allow_nil: true
  delegate :establishment, to: :sector
  delegate :full_info, to: :professional, prefix: true, allow_nil: true

  def create_profile
    # first_name = Devise::LDAP::Adapter.get_ldap_param("Test", "givenname").first # Uncomment in test
    if Rails.env.test?
      profile = Profile.new(user: self, first_name: 'Test', last_name: 'Reimann', email: 'reimann@example.com',
                            dni: 0o00001111)
    else
      # Comment in production
      first_name = Devise::LDAP::Adapter.get_ldap_param(username, 'givenname').first.encode('Windows-1252',
                                                                                            invalid: :replace,
                                                                                            undef: :replace)
      last_name = Devise::LDAP::Adapter.get_ldap_param(username, 'sn').first.encode('Windows-1252',
                                                                                    invalid: :replace,
                                                                                    undef: :replace)
      email = if Devise::LDAP::Adapter.get_ldap_param(username,
                                                      'mail').present?
                Devise::LDAP::Adapter.get_ldap_param(username,
                                                     'mail').first
              else
                'Sin email'
              end
      dni = if Devise::LDAP::Adapter.get_ldap_param(username,
                                                    'uid').present?
              Devise::LDAP::Adapter.get_ldap_param(username,
                                                   'uid').first
            else
              'Sin DNI'
            end
      profile = Profile.new(user: self, first_name: first_name, last_name: last_name, email: email, dni: dni)
    end

    profile.avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'profile-placeholder.jpg')),
                          filename: 'profile-placeholder.jpg', content_type: 'image/jpg')
    profile.save!
  end

  def verify_profile
    unless profile.present?
      create_profile # Comment in development
    end
    if !sector.present? && sectors.present?
      self.sector = sectors.first
      save
    end
  end

  def valid_password?(password)
    Devise::Encryptor.compare(self.class, encrypted_password, password)
  end

  # HACK: for remember_token
  def authenticatable_salt
    Digest::SHA1.hexdigest(username)[0, 29]
  end

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: %i[
      search_username
      search_by_fullname
      sorted_by
    ]
  )

  pg_search_scope :search_username,
                  against: :username,
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_by_fullname,
                  associated_against: { profile: %i[first_name last_name] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("users.created_at #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_sector_id, lambda { |an_id|
    where(sector_id: [*an_id])
  }

  def update_user_permissions!(user_params, aproved_by)
    ActiveRecord::Base.transaction do
      update!(user_params.except(:permission_request_id))
      user_sectors.first.active! unless user_sectors.active.any?
      if user_params[:permission_request_id].present?
        permission_request = PermissionRequest.find(user_params[:permission_request_id])
        permission_request.aproved_by_id = aproved_by.id
        permission_request.done!
      end
      active!
      self
    end
  end

  def build_permissions_from_role(roles_attributes)
    roles_attributes.each do |role_attr|
      user_roles.build(role_attr[1].except(:_destroy)) if role_attr[1]['_destroy'] == 'false'
      user_roles.build(role_attr[1].except(:_destroy)) if role_attr[1]['_destroy'] == 'true'
    end
    self
  end

  def full_name
    if profile.present?
      profile.full_name
    else
      username
    end
  end

  def name_and_sector
    "#{full_name} | #{sector.name}"
  end

  def sector_and_establishment
    "#{sector_name} #{establishment_name}"
  end

  def has_permission?(permissions_target)
    permissions.any? do |permission|
      permission.name == permissions_target.to_s && permission.permission_users.any? { |pu| pu.sector_id == sector_id }
    end
  end

  def has_permissions_any?(*permissions_target)
    permissions.joins(:permission_users).where(name: permissions_target, 'permission_users.sector_id': sector_id).any?
  end

  def role_exists?(attributes)
    user_roles.exists?(role_id: attributes[:role_id], sector_id: attributes[:sector_id])
  end

  def permission_exists?(attributes)
    permission_users.exists?(permission_id: attributes[:permission_id], sector_id: attributes[:sector_id])
  end

  def sector_exists?(attributes)
    user_sectors.exists?(sector_id: attributes[:sector_id])
  end

  private

  def validate_max_sectors
    max_sectors = 3
    errors.add(:max_sectors, "supera el máximo de #{max_sectors}.") if user_sectors.size > max_sectors
  end
end
