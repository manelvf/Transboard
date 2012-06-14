# encoding: UTF-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))


require 'rubygems'
require 'mongo'
require 'mongo_mapper'

require File.dirname(__FILE__) + '/../model.rb'
require File.dirname(__FILE__) + '/../config.rb'


n = Document.destroy_all({:status=>"deleted"})
puts n


