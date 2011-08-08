require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "om"

describe "OM::XML::DynamicNode" do
  
  before(:each) do
    @sample = OM::Samples::ModsArticle.from_xml( fixture( File.join("test_dummy_mods.xml") ) )
    @article = OM::Samples::ModsArticle.from_xml( fixture( File.join("mods_articles","hydrangea_article1.xml") ) )
  end
  
  describe "dynamically created nodes" do

    it "should return build an array of values from the nodeset corresponding to the given term" do
      expected_values = ["Berners-Lee", "Jobs", "Wozniak", "Klimt"]
      result = @sample.person.last_name
      result.length.should == expected_values.length
      expected_values.each {|v| result.should include(v)}
    end

    it "should find elements two deep" do
      #TODO reimplement so that method_missing with name is only called once.  Create a new method for name.
      @article.name.name_content.val.should == ["Describes a person"]
      @article.name.name_content.should == ["Describes a person"]
    end

    it "should not find elements that don't  exist" do
      lambda {@article.name.hedgehog}.should raise_exception NoMethodError
    end

    it "should allow you to call methods on the return value" do
      @article.name.name_content.first.should == "Describes a person"
    end

    it "Should work with proxies" do
      @article.title.should == ["ARTICLE TITLE HYDRANGEA ARTICLE 1", "Artikkelin otsikko Hydrangea artiklan 1", "TITLE OF HOST JOURNAL"]
      @article.title.main_title_lang.should == ['eng']

      @article.title[1].to_pointer.should == [{:title => 1}]
      # You're actually looking to run either of these internally:
      # @article.find_by_terms("//oxns:mods/oxns:titleInfo[2]/oxns:title").text # get the title value from the second titleInfo node
      # @article.find_by_terms("//oxns:mods/oxns:titleInfo/oxns:title")[1].text # get the second title from the array of all titles in the document
      @article.title[1].xpath.should == "//oxns:titleInfo/oxns:title[2]" # this is wrong.
      @article.title[1].should == "Artikkelin otsikko Hydrangea artiklan 1"
    end

    it "Should be addressable as an array" do
      @article.update_values( {[{:journal=>0}, {:issue=>3}, :pages, :start]=>{"0"=>"434"} })

      @article.subject.topic[1].to_pointer == [:subject, {:topic => 1}]
      @article.journal[0].issue.length.should == 2
      @article.journal[0].issue[1].pages.length.should == 1
      @article.journal[0].issue[1].pages.start.length.should == 1
      @article.journal[0].issue[1].pages.start.first.should == "434"

      @article.subject.topic[1].should == ["TOPIC 2"]
      ### TODO why doesn't this work?
      
      @article.term_values(:subject, {:topic => 1}).should == "TOPIC 2"
    end

    it "should append nodes at the specified index if possible" do
      @article.journal.title_info = ["all", "for", "the"]
      @article.journal.title_info[3] = 'glory'
      @article.term_values(:journal, :title_info).should == ["all", "for", "the", "glory"]
    end
  
  end
end
