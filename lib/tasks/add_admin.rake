namespace :data do
  desc "Add admin user"
  task add_admin: :environment do
    admin_user = AdminUser.create!(email: ENV["ADMIN_EMAIL"], password: ENV["ADMIN_PASSWORD"], password_confirmation: ENV["ADMIN_PASSWORD"])
    Rails.logger.info(admin_user.id)
  end
end
