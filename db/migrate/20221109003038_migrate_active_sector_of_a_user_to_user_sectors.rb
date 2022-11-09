class MigrateActiveSectorOfAUserToUserSectors < ActiveRecord::Migration[5.2]
  def up
    User.all.each do |user|
      s_id = user.sector_id
      next unless s_id.present?

      user_sector = user.user_sectors.where(sector_id: s_id).first
      if user_sector.nil?
        user.user_sectors.build(sector_id: s_id, status: 'active')
        user.save!
      else
        user_sector.active!
      end
    end
  end

  def down
    # nothing to do
  end
end
