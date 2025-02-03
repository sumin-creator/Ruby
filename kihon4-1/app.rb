# coding: utf-8
require 'sinatra'
require 'sinatra/activerecord'

set :database, { adapter: 'sqlite3', database: './research_db.db' }

class Lab < ActiveRecord::Base
  self.table_name = 'labs'
  has_many :lab_members, foreign_key: 'lab_id'
end

class LabMember < ActiveRecord::Base
  self.table_name = 'lab_members'
  belongs_to :lab, foreign_key: 'lab_id'
end

get '/lab_search' do
  lab_name = params['lab_name']
  if lab_name
    lab = Lab.find_by(lab_name: lab_name)
    if lab
      @lab_name = lab_name
      @members = lab.lab_members
      erb :lab_search
    else
      @error_message = "Lab not found"
      erb :error
    end
  else
    @error_message = "Please provide a lab_name parameter"
    erb :error
  end
end

get '/member_search' do
  member_name = params['member_name']
  if member_name
    member = LabMember.find_by(member_name: member_name)
    if member && member.lab
      @member_name = member_name
      @lab_members = member.lab.lab_members.where.not(member_name: member_name)
      erb :member_search
    else
      @error_message = "Member not found"
      erb :error
    end
  else
    @error_message = "Please provide a member_name parameter"
    erb :error
  end
end
