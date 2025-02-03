# coding: utf-8
require 'active_record'

ActiveRecord::Base.establish_connection(
  "adapter" =>"sqlite3",
"database" => "./research_db.db"
)

class Lab < ActiveRecord::Base
  self.table_name = 'labs'
  has_many :lab_members, foreign_key: 'lab_id'
end

class LabMember < ActiveRecord::Base
  self.table_name = 'lab_members'
  belongs_to :lab, foreign_key: 'lab_id'
end

lab_name = gets.chomp

begin
  lab = Lab.find_by(lab_name: lab_name)

  if lab
    members = lab.lab_members
    members.each do |member|
      puts member.member_name
    end
  else
    puts "labs not found"
  end
rescue ActiveRecord::ActiveRecordError => e
  puts "Error: #{e.message}"
end

