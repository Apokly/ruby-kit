require 'spec_helper'

describe 'Api' do
  before do
    @data = {}
    @data['refs'] = [
      Prismic::Ref.new('ref1', 'label1'),
      Prismic::Ref.new('ref2', 'label2'),
      Prismic::Ref.new('ref30', 'label3'),
      Prismic::Ref.new('ref3', 'label3', true),
      Prismic::Ref.new('ref4', 'label4'),
    ]
    @data['forms'] = {
      'form1' => Prismic::Form.new('form1', {}, nil, nil, nil, nil),
      'form2' => Prismic::Form.new('form2', {}, nil, nil, nil, nil),
      'form3' => Prismic::Form.new('form3', {}, nil, nil, nil, nil),
      'form4' => Prismic::Form.new('form4', {}, nil, nil, nil, nil),
    }
    @api = Prismic::Api.new(@data)
  end

  describe 'refs' do
    it "returns a map with an element from each type" do
      @api.refs['label2'].ref.should == 'ref2'
    end

    it "returns a map with the correct number of elements" do
      @api.refs.size.should == 4
    end
  end

  describe 'forms' do
    it "returns a map of { String => SearchForm }" do
      @api.forms['form1'].should be_kind_of (Prismic::SearchForm)
    end

    it "sets SearchForm.api to the correct value" do
      @api.forms['form2'].api.should be_kind_of (Prismic::Api)
    end

    it "sets SearchForm.form to the correct value" do
      @api.forms['form2'].form.name.should == 'form2'
    end

    it "sets SearchForm.data to the correct value" do
      @api.forms['form2'].data.should == {}
    end

    it "returns a map with the correct number of elements" do
      @api.forms.size.should == 4
    end
  end

  describe 'master' do
    it "returns a Ref" do
      @api.master.should be_kind_of (Prismic::Ref)
    end

    it "returns the first master" do
      @api.master.label.should == 'label3'
    end

    it "throws an exception if no master was found" do
      expect {
        Prismic::Api.new({ 'refs' => [] })
      }.to raise_error Prismic::Api::NoMasterFoundException
    end
  end

  describe 'parse_api_response' do
    before do
      data = File.read("#{File.dirname(__FILE__)}/responses_mocks/api.json")
      @parsed_response = Prismic::Api.parse_api_response(data)
    end

    it "returns a hash" do
      @parsed_response.should be_kind_of Hash
    end

    describe "parsing refs" do
      it "returns a hash containing a an array" do
        @parsed_response['refs'].should be_kind_of Array
      end

      it "returns a hash containing a an array whose size is 2" do
        @parsed_response['refs'].size.should == 2
      end

      it "returns a hash containing a an array of Ref objects" do
        @parsed_response['refs'][0].should be_kind_of Prismic::Ref
      end

      it "fills the Ref objects with the correct ref data" do
        @parsed_response['refs'][1].ref.should == 'foo'
      end

      it "fills the Ref objects with the correct ref label" do
        @parsed_response['refs'][1].label.should == 'bar'
      end

      it "fills the Ref objects with the correct ref master?" do
        @parsed_response['refs'][1].master?.should == false
      end
    end

    describe "parsing bookmarks" do
      it "returns a hash" do
        @parsed_response['bookmarks'].should be_kind_of Hash
      end

      it "returns a hash of size 3" do
        @parsed_response['bookmarks'].size.should == 3
      end

      it "retuns a hash containing the bookmarks" do
        @parsed_response['bookmarks']['about'].should == 'Ue0EDd_mqb8Dhk3j'
      end
    end

    describe "parsing types" do
      it "returns a hash" do
        @parsed_response['types'].should be_kind_of Hash
      end

      it "returns a hash of size 6" do
        @parsed_response['types'].size.should == 6
      end

      it "retuns a hash containing the types" do
        @parsed_response['types']['blog-post'].should == 'Blog post'
      end
    end

    describe "parsing tags" do
      it "returns an array" do
        @parsed_response['tags'].should be_kind_of Array
      end

      it "returns a hash of size 4" do
        @parsed_response['tags'].size.should == 4
      end

      it "retuns a hash containing the types" do
        @parsed_response['tags'].should include 'Cupcake'
      end
    end

    describe "parsing forms" do
      it "returns a hash" do
        @parsed_response['forms'].should be_kind_of Hash
      end

      it "returns a hash of size 10" do
        @parsed_response['forms'].size.should == 10
      end

      it "returns a hash of Form objects" do
        @parsed_response['forms']['pies'].should be_kind_of Prismic::Form
      end

      it "correctly fills objects names" do
        @parsed_response['forms']['pies'].name.should == 'Little Pies'
      end

      it "correctly fills objects method" do
        @parsed_response['forms']['pies'].form_method.should == 'GET'
      end

      it "correctly fills objects rel" do
        @parsed_response['forms']['pies'].rel.should == 'collection'
      end

      it "correctly fills objects enctype" do
        @parsed_response['forms']['pies'].enctype.should ==
          'application/x-www-form-urlencoded'
      end

      it "correctly fills objects action" do
        @parsed_response['forms']['pies'].action.should ==
          'http://lesbonneschoses.wroom.io/api/documents/search'
      end

      describe "filling objects fields" do
        it "creates all the fields" do
          @parsed_response['forms']['pies'].fields.size.should == 2
        end

        it "fills the fields with the type info" do
          @parsed_response['forms']['pies'].fields['ref'].field_type.should == 'String'
        end

        it "fills the fields with the default info" do
          @parsed_response['forms']['pies'].fields['q'].default.should ==
            '[[at(document.tags, ["Pie"])][any(document.type, ["product"])]]'
        end
      end
    end
  end
end

describe 'Form' do
  describe 'default_data' do
    it 'creates a map of default fields data' do
      form = Prismic::Form.new(nil, {}, nil, nil, nil, nil)

      form.fields = {"foo1" => nil}
      default_data = form.default_data
      default_data.should be_empty

      form = Prismic::Form.new(nil, {}, nil, nil, nil, nil)
      form.fields = {"foo1" => "bar1",
                     "foo2" => "bar2",
                     "foo3" => nil,
                     "foo4" => "bar4"}
      default_data = form.default_data
      default_data.size.should == 3
    end
  end
end
