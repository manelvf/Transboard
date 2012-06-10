# encoding: UTF-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))


require 'rubygems'
require 'mongo'
require 'haml'
require 'mongo_mapper'
require 'sinatra'
require "sinatra/reloader" 
require 'sinatra/flash'
require 'sinatra-authentication'
require 'fast_gettext'
require 'pony'


# add user to authentification
class MmUser
  key :name, String, :unique=>true
end

require File.dirname(__FILE__) + '/language_codes.rb'
require File.dirname(__FILE__) + '/model.rb'
require File.dirname(__FILE__) + '/upload.rb'


ENV['RACK_ENV'] = 'development'

module Rack
  Flash = true
end

require File.dirname(__FILE__) + '/config.rb'

enable :sessions, :logging

set :enviroment, :development
set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + "views/auth/"
set :public_folder, File.dirname(__FILE__) + '/static'



use Rack::Session::Cookie, :secret => "*** Transboard ***"



def _(value) 
  FastGettext.add_text_domain('transboard',:path=>'locale', :type=>:po)
  FastGettext.text_domain = 'transboard'
  FastGettext.available_locales = ['de','en','fr','es','gl_ES','en_US','en_UK'] # only allow these locales to be set (optional)
  FastGettext.locale = 'en'
  #puts value
  newValue =  FastGettext::Translation::_(value)
  puts newValue
  return newValue
end


#Mongoid.load!(File.dirname(__FILE__) + "/mongoid.yml")


#
# Views
#


get '/' do

  unless logged_in?
    projectTotal = Document.all(:status => { "$not" => /deleted/ }).length

    haml :index, :format=>:html5, :locals => {
      :projectTotal => projectTotal,
      :switches => {
        :dashboard => false,
        :create_new_project => false,
      },
      :linkswitches => {
        :create_new_project => true
      }
    }
  else
    redirect '/dashboard'
  end

end


get '/create_new_project' do
  login_required

  haml :upload, :format=>:html5, :locals => {
      :create_new_project_active=>"active",
      :switches => {
      },
      :linkSwitches => {
        :projects => true,
        :dashboard => true,
      }
    }
end


post '/uploadFile' do

  if params['myFile'].nil?
    flash[:uploadError] = 'please indicate a File'
    redirect '/create_new_project'
  end

  r = Upload::saveUpload(params, current_user.id)

  if not r[:errors].nil?
    flash[:uploadError] = r[:errors]
    redirect '/create_new_project'
  elsif (r[:length] <= 0)
    flash[:uploadError] = 'Empty file'
    redirect '/create_new_project'
  else
    flash[:stringsLoaded] = r[:length].to_s + " strings loaded"
    redirect '/editproject/' + r[:docId]
  end

end


get "/editproject/:id" do
  login_required

  doc = Model::getDocument(params[:id])
  #puts doc

  haml :edit, :format=>:html5, :locals => {
    :doc=>doc,
    :switches=>{},
    :linkSwitches=>{
        :projects => true,
        :dashboard => true,
        :create_new_project =>true
    }
  }
end


# add a proposal to a line
post "/addline" do

  #l = Line.find(params[:id]) # line id
  #puts l 
  prop = {:msgstr=>params[:text], :authorId=>current_user.id}
  
  doc = Model::getDocument(params[:docId])
  p = doc.lines.find(params[:id]).proposals << Proposal.new(prop)

  doc.save

  return "OK"
end


# vote a proposal
post "/vote" do

  doc = Model::getDocument(params[:docId])
  lines = doc.lines.find(params[:lineId])
  prop = lines.proposals.find(params[:propId])

  # search same author votes
  prop.votes.each do |vote|

    if (vote[:authorId] == current_user.id.to_s)
      return "VOTED"
    end
  end

  prop.votes << Vote.new({:authorId => current_user.id})
  doc.save

  return "OK"

end


# Edit project options View
get "/projectoptions/:id" do
  login_required

  doc = Model::getDocument(params[:id])

  haml :projectoptions, :format=>:html5, :locals => {
    :doc=>doc,
    :switches=>{},
    :linkSwitches=>{
        :projects => true,
        :dashboard => true,
        :create_new_project =>true
    }
  }
end


# delete a project
get "/delete/:id" do
  Document.update(params[:id], {:status=>"deleted"})
  return "OK"
end


# show all projects where user is listed as author or collaborator
get "/dashboard" do
  projects = Document.all(:status => { "$not" => /deleted/ })
  
  authorNames = {}

  projects.each do |p|
    if (p[:authorId].length > 8)
      a = $db.collection("mm_users").find(:_id => BSON::ObjectId(p[:authorId]))
      #puts a
      puts a.first["email"]

      unless a.first.nil?
        puts "aaaaaaaaaaaaaaaaaaaa"
        #puts a.first
        #puts a.first.inspect
        authorNames[p["id"]] = a.first["email"]
      end
    end
  end
  puts authorNames.inspect

  haml :list, :format=>:html5, :locals => {
    :authorNames => authorNames,
    :projects=>projects,
    :switches=>{:dashboard=>true},
    :linkSwitches=>{
      :projects => true,
      :dashboard => true,
      :create_new_project =>true
    }
  }
end



get "/projects" do
  projects = Document.all()
  haml :list, :format=>:html5, :locals => {
    :projects=>projects,
    :projects_active=>"active"
  }
end


# ask to collaborate in a project
get "/askcollaborate:id" do
  doc = Model::getDocument(params[:id])

  doc.collaborations << Collaboration.new({:authorId=>current_user.id,
                                          :status=>"pending" })  

  return "OK"
end


# download a translation file
get "/download/:id" do
  content_type 'text/plain', :charset => 'utf-8'
  attachment 'translation.po'

  d = Document.find(params[:id])

  s = ""

  d.lines.each do |line|
    s += line.msgid + "\n"
  end

  return s
end


###############
# Static Pages
#
##############

get "/about" do
  haml :about, :format=>:html5, :locals => {}
end


