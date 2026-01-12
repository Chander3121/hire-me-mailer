namespace :backfill do
  desc "Assign all existing EmailTemplate and EmailLog records to a user by id or email. Usage: rake backfill:assign_user['user@example.com'] or rake backfill:assign_user[123]"
  task :assign_user, [ :identifier ] => :environment do |_t, args|
    identifier = args[:identifier]
    if identifier.blank?
      puts "Please provide a user id or email: rake backfill:assign_user['user@example.com']"
      exit 1
    end

    user = if identifier.to_s =~ /\A\d+\z/
      User.find_by(id: identifier.to_i)
    else
      User.find_by(email: identifier.to_s)
    end

    unless user
      puts "User not found for #{identifier}"
      exit 1
    end

    email_templates_updated = EmailTemplate.where(user_id: nil).update_all(user_id: user.id)
    email_logs_updated = EmailLog.where(user_id: nil).update_all(user_id: user.id)

    puts "Assigned #{email_templates_updated} templates and #{email_logs_updated} logs to user #{user.email} (id=#{user.id})"
  end
end
