# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
Location.create([{:name => 'Soca Togo'}, {:name => 'Agri Togo'}])
Library.create([{:name => 'SOCA TOGO - JAGO, GINO, POMO', :address => '313 Bvd du 13 Janvier, Immeuble Avenida, BP 8480', :telephone => '220 31 24', :fax => '220 31 24', :email => 'http://togophonebook.com/c/e/106520/948.gif'}, {:name => 'SOCA TOGO - JAGO', :address => 'Immeuble Avenida, BP 8480', :telephone => '265 32 94', :fax => '265 2 87', :email => 'http://togophonebook.com/c/e/106520/8.gif'}, {:name => 'AGRI TOGO 2000', :address => '134, Av.de la Libération, BP 4890', :telephone => '222 47 71'}])
