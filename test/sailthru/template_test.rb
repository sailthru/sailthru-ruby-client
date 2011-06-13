$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class TemplateTest < Test::Unit::TestCase
  context "API Call: template" do
    setup do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'template')
    end

    should "be able to get template information when template name is valid" do
      valid_template_name = 'default'
      params = {'template' => valid_template_name}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'template_valid_get.json')
      response = @sailthru_client.get_template(valid_template_name)
      assert_equal valid_template_name, response['name']
    end

    should "be able to get error message when template name is invalid" do
      invalid_template_name = 'invalid_template'
      params = {'template' => invalid_template_name}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'template_invalid_get.json')
      response = @sailthru_client.get_template(invalid_template_name)
      assert_equal 14, response['error']
    end

    should "be able to save template with given template name" do
      valid_template_name = 'my-template-new'
      from_email = 'praj@sailthru.com'
      from_name = 'prajwal tuladhar'
      stub_post(@api_call_url, 'template_save.json')
      response = @sailthru_client.save_template(valid_template_name, {'from_email'=> 'praj@sailthru.com', 'from_name'=> from_name})
      assert_equal valid_template_name, response['name']
      assert_equal from_email, response['from_email']
      assert_equal from_name, response['from_name']
    end
    
    should "be able to delete a template with valid template name" do
      template_name = 'my-template'
      params = {'template' => template_name}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_delete(@api_call_url + '?' + query_string, 'template_delete_valid.json')
      response = @sailthru_client.delete_template(template_name)
      assert_equal template_name, response['template']
    end
    
    should "not be able to delete a template with invalid template name" do
      template_name = 'my-template'
      params = {'template' => template_name}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_delete(@api_call_url + '?' + query_string, 'blast_delete_invalid.json')
      response = @sailthru_client.delete_template(template_name)
      assert_not_nil response['error']
      assert_not_nil response['errormsg']
    end
  end
end
