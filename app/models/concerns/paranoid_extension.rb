# ParanoidExtension implements soft deletion for ActiveRecord objects
module ParanoidExtension
  extend ActiveSupport::Concern

  included do
    acts_as_paranoid column: :active, sentinel_value: true

    def paranoia_restore_attributes
      {
        deleted_at: nil,
        active: true,
      }
    end

    def paranoia_destroy_attributes
      {
        deleted_at: current_time_from_proper_timezone,
        active: nil,
      }
    end
  end
end
