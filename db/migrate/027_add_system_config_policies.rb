class AddSystemConfigPolicies < ActiveRecord::Migration
  def self.up
    Policy.new(
      :name => 'host',
      :description => 'Domain name for emailed URLs',
      :value => 'fill.me.in',
      :value_type => 'str'
    ).save!
    Policy.new(
      :name => 'port',
      :description => 'Port for emailed URLs',
      :value => '80',
      :value_type => 'int'
    ).save!
    Policy.new(
      :name => 'pdf_generator',
      :description => 'Enable PDF generator.  Requires HTMLDOC command line tool installed.',
      :value => '80',
      :value_type => 'bool'
    ).save!
  end

  def self.down
    ['host', 'port', 'pdf_generator'].each do |policy|
      x = Policy.find(:first, :conditions => { :policy_type => nil, :name => policy })
      x.destroy unless x.blank?
    end
  end
end
