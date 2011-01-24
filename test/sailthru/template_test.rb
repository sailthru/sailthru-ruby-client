$:.unshift File.join(File.dirname(__FILE__),'..')
require 'test_helper'

class TemplateTest < Test::Unit::TestCase
  context "API Call: template" do
    setup do
      api_url = 'http://api.sailthru.com'
      @sailthru_client = Sailthru::SailthruClient.new("my_api_key", "my_secret", api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'template')
    end

    should "be able to get template information when template name is valid" do
      valid_template_name = 'default'
      stub_get(@api_call_url + '?format=json&api_key=my_api_key&template=' + valid_template_name + '&sig=23a108917794dd66c9e46fcc19ffa48b', 'template_valid_get.json')
      response = @sailthru_client.get_template(valid_template_name)
      assert_equal valid_template_name, response['name']
    end

    should "be able to get error message when template name is invalid" do
      invalid_template_name = 'invalid_template'
      stub_get(@api_call_url + '?format=json&api_key=my_api_key&template=' + invalid_template_name + '&sig=953692626fb11e044f969a1fed4ec071', 'template_invalid_get.json')
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
  end
end
