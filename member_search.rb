# coding: utf-8
require 'active_record'

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
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

member_name = gets.chomp

begin
  member = LabMember.find_by(member_name: member_name)

  if member
    lab_members = member.lab.lab_members.where.not(member_name: member_name)

    if lab_members.any?
      lab_members.each do |other_member|
        puts other_member.member_name
      end
    else
      puts "no other member"
    end
  else
    puts "member not found"
  end
rescue ActiveRecord::ActiveRecordError => e
  puts "Error: #{e.message}"
end

