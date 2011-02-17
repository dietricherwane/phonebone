require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fakeweb'

describe Scrapper do
  before(:each) do
    FakeWeb.register_uri(:get, "http://example.com/test", :body => '<h2>Parcourir</h2><div id="browseLine" class="redLine"></div><div class="cols3"><ul><li><a href="./alimentation/">Alimentation</a></li></ul><div class="clear">')
    @example_test_text = '<h2>Parcourir</h2><div id="browseLine" class="redLine"></div><div class="cols3"><ul><li><a href="./alimentation/">Alimentation</a></li></ul><div class="clear">'
    @scrapper = Scrapper.new
    @rg1 = /<\/div><div class="cols3"><ul><li>/
    @rg2 = /<div class="clear">/
    @rg_link_lv1 = /<a href=".*?">/
  end

  describe "fetch_url" do
    it "should retrieve in a variable html text of http://example.com/test" do
      @html_text = @scrapper.fetch_url('http://example.com/test')
      @html_text.should == @example_test_text
    end
  end

  describe "retrieve_links_list" do
    it "should retrieve in a variable html text between regexs $rg1 and $rg2" do
      @links_list = @scrapper.retrieve_links_list(@scrapper.fetch_url('http://example.com/test'), @rg1, @rg2)
      @links_list.should == '<a href="./alimentation/">Alimentation</a></li></ul>'
    end
  end

  describe "table_of_links" do
    it "should retrieve in table texts like a given regex among a list of links" do
      @table_of_links = @scrapper.table_of_links(@rg_link_lv1, @scrapper.retrieve_links_list(@scrapper.fetch_url('http://example.com/test'), @rg1, @rg2))
      @table_of_links.should == ['http://togophonebook.com/alimentation/']
    end
  end

  describe "retrieve_location_data" do
    it "should retrieve in a hash name, country, address, phone-number, fax-number, email, webpage of locations on http://example.com/test" do
      @retrieve_location_data = @scrapper.retrieve_location_data('http://example.com/test')
      @retrieve_location_data.has_key?('SOCA TOGO - JAGO, GINO, POMO').should be_true
      @retrieve_location_data['SOCA TOGO - JAGO, GINO, POMO']['country'].should == 'Togo'
      @retrieve_location_data['SOCA TOGO - JAGO, GINO, POMO']['address'].should == '313 Bvd du 13 Janvier, Immeuble Avenida, BP 8480'
      @retrieve_location_data['SOCA TOGO - JAGO, GINO, POMO']['phone-number'].should == ['220 31 24']
      @retrieve_location_data['SOCA TOGO - JAGO, GINO, POMO']['fax-number'].should == ['220 31 25']
      @retrieve_location_data['SOCA TOGO - JAGO, GINO, POMO']['e-mail'].should == ['http://togophonebook.com/c/e/106520/948.gif', 'http://togophonebook.com/c/e/106520/949.gif']
      @retrieve_location_data['SOCA TOGO - JAGO, GINO, POMO']['web-page'].should == []
    end
  end
end