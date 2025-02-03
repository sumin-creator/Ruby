# coding: utf-8
require 'webrick'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: './research_db.db'
)

class Lab < ActiveRecord::Base
  self.table_name = 'labs'
  has_many :lab_members, foreign_key: 'lab_id'
end

class LabMember < ActiveRecord::Base
  self.table_name = 'lab_members'
  belongs_to :lab, foreign_key: 'lab_id'
end

srv = WEBrick::HTTPServer.new(
  DocumentRoot: './',
  BindAddress: '127.0.0.1',
  Port: 2000
)

srv.mount_proc('/lab_search') do |req, res|
  lab_name = req.query['lab_name']
  res.content_type = 'text/html'
  
  if lab_name
    lab = Lab.find_by(lab_name: lab_name)
    
    if lab
      members = lab.lab_members
      res.body = "<html><head><title>#{lab_name}</title></head><body>"
      res.body += "<h1>#{lab_name}</h1><ul>"
      members.each do |member|
        res.body += "<li>#{member.member_name} - #{member.position}</li>"
      end
      res.body += "</ul></body></html>"
    else
      res.body = "<html><head><title>Error</title></head><body><h1>lab not found</h1></body></html>"
    end
  else
    res.body = "<html><head><title>Error</title></head><body><h1>lab_name parameters</h1></body></html>"
  end
end

srv.mount_proc('/member_search') do |req, res|
  member_name = req.query['member_name']
  res.content_type = 'text/html'
  
  if member_name
    member = LabMember.find_by(member_name: member_name)
    
    if member && member.lab
      lab_members = member.lab.lab_members.where.not(member_name: member_name)
      res.body = "<html><head><title>#{member_name} and other members</title></head><body>"
      res.body += "<h1>#{member_name} and other members</h1><ul>"
      lab_members.each do |other_member|
        res.body += "<li>#{other_member.member_name} - #{other_member.position}</li>"
      end
      res.body += "</ul></body></html>"
    else
      res.body = "<html><head><title>Error</title></head><body><h1>member not found</h1></body></html>"
    end
  else
    res.body = "<html><head><title>Error</title></head><body><h1>member_name parameter</h1></body></html>"
  end
end

trap("INT") { srv.shutdown }

puts "Server is running at http://127.0.0.1:2000"
srv.start
