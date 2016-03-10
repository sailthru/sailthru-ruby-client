require 'test_helper'

class TemplateTest < Minitest::Test
  describe "API Call: template" do
    before do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::Client.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'template')
    end

    it "can get template information when template name is valid" do
      valid_template_name = 'default'
      params = {'template' => valid_template_name}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'template_valid_get.json')
      response = @sailthru_client.get_template(valid_template_name)
      assert_equal valid_template_name, response['name']
    end

    it "can get error message when template name is invalid" do
      invalid_template_name = 'invalid_template'
      params = {'template' => invalid_template_name}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'template_invalid_get.json')
      response = @sailthru_client.get_template(invalid_template_name)
      assert_equal 14, response['error']
    end

    it "can get a list of all existing templates" do
      query_string = create_json_payload(@api_key, @secret, {})
      stub_get(@api_call_url + '?' + query_string, 'templates_get.json')
      response = @sailthru_client.get_templates  
      assert response['templates'][0].has_key?('template_id')
      refute_nil response['templates'][0]['template_id']
    end

    it "can save template with given template name" do
      valid_template_name = 'my-template-new'
      from_email = 'praj@sailthru.com'
      from_name = 'prajwal tuladhar'
      stub_post(@api_call_url, 'template_save.json')
      response = @sailthru_client.save_template(valid_template_name, {'from_email'=> 'praj@sailthru.com', 'from_name'=> from_name})
      assert_equal valid_template_name, response['name']
      assert_equal from_email, response['from_email']
      assert_equal from_name, response['from_name']
    end

    it "can save template with test_vars" do
      valid_template_name = 'my-template-test-vars'
      valid_test_vars = "{\"firstName\":\"Lindsay\"}"
      stub_post(@api_call_url, 'template_save_test_vars.json')
      response = @sailthru_client.save_template(valid_template_name, {'test_vars'=> valid_test_vars})
      assert_equal valid_template_name, response['name']
      assert_equal valid_test_vars, response['test_vars']
    end

    it "can delete a template with valid template name" do
      template_name = 'my-template'
      params = {'template' => template_name}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_delete(@api_call_url + '?' + query_string, 'template_delete_valid.json')
      response = @sailthru_client.delete_template(template_name)
      assert_equal template_name, response['template']
    end

    it "cannot delete a template with invalid template name" do
      template_name = 'my-template'
      params = {'template' => template_name}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_delete(@api_call_url + '?' + query_string, 'blast_delete_invalid.json')
      response = @sailthru_client.delete_template(template_name)
      refute_nil response['error']
      refute_nil response['errormsg']
    end
  end
end
