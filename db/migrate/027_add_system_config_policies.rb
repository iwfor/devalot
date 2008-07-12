class AddSystemConfigPolicies < ActiveRecord::Migration
  def self.up
    Policy.new(
      :name => 'host',
      :description => 'Domain name.  Needed for emailed URLs.',
      :value => 'fill.me.in',
      :value_type => 'str'
    ).save!
    Policy.new(
      :name => 'port',
      :description => 'Port.  Needed for emailed URLs',
      :value => '80',
      :value_type => 'int'
    ).save!
    Policy.new(
      :name => 'pdf_generator',
      :description => 'Enable PDF generator.  Requires HTMLDOC command line tool installed.',
      :value => 'false',
      :value_type => 'bool'
    ).save!
    Policy.new(
      :name => 'watch_emails',
      :description => 'Enable watch emailer.  Requires adding script/helpers/cron_email.rb to crontab.',
      :value => 'false',
      :value_type => 'bool'
    ).save!
  end

  def self.down
    ['host', 'port', 'pdf_generator', 'watch_emails'].each do |policy|
      x = Policy.find(:first, :conditions => { :policy_type => nil, :name => policy })
      x.destroy unless x.blank?
    end
  end
end
