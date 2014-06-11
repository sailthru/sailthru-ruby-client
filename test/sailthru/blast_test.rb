require 'test_helper'

class BlastTest < Minitest::Test
  describe "API Call: blast" do
    before do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::SailthruClient.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'blast')
    end

    it "can get the status of a blast when blast_id is valid" do
      valid_blast_id = '665215'
      params = {'blast_id' => valid_blast_id}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'blast_get_valid.json')
      response = @sailthru_client.get_blast(valid_blast_id)
      refute_nil response['name']
      assert_equal valid_blast_id, response['blast_id'].to_s
    end

    it "can get blast error message when blast_id is invalid" do
      invalid_blast_id = '88787'
      params = {'blast_id' => invalid_blast_id}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_get(@api_call_url + '?' + query_string, 'blast_get_invalid.json')
      response =  @sailthru_client.get_blast(invalid_blast_id)
      refute_nil response['error']
      refute_nil response['errormsg']
    end

    it "can schedule blast with given blast name, list, schedule_time, from name, from email, subject, content html, content text" do
      blast_name = 'Default Blast 222'
      list = 'default-list'
      schedule_time = '+3 hours'
      from_name = 'Daily Newsletter'
      from_email = 'praj@sailthru.com'
      subject = 'Hello World!'
      content_html = '<p>Hello World</p>'
      content_text= 'Hello World'
      stub_post(@api_call_url, 'blast_post_valid.json')
      response = @sailthru_client.schedule_blast(blast_name, list, schedule_time, from_name, from_email, subject, content_html, content_text)
      assert_equal blast_name, response['name']
      assert_equal list, response['list']
      assert_equal from_email, response['from_email']
      assert_equal from_name, response['from_name']
    end

    it "cannot schedule blast with invalid email" do
      blast_name = 'Default Blast 222'
      list = 'default-list'
      schedule_time = '+3 hours'
      from_name = 'Daily Newsletter'
      from_email_invalid = 'praj@'
      subject = 'Hello World!'
      content_html = '<p>Hello World</p>'
      content_text= 'Hello World'
      stub_post(@api_call_url, 'blast_post_invalid_email.json')
      response = @sailthru_client.schedule_blast(blast_name, list, schedule_time, from_name, from_email_invalid, subject, content_html, content_text)
      refute_nil response['error']
      refute_nil response['errormsg']
    end

    it "cannot schedule blast with invalid list" do
      blast_name = 'Default Blast 222'
      list_invalid = 'this-list-does-not-exist'
      schedule_time = '+3 hours'
      from_name = 'Daily Newsletter'
      from_email = 'praj@'
      subject = 'Hello World!'
      content_html = '<p>Hello World</p>'
      content_text= 'Hello World'
      stub_post(@api_call_url, 'blast_post_invalid_list.json')
      response = @sailthru_client.schedule_blast(blast_name, list_invalid, schedule_time, from_name, from_email, subject, content_html, content_text)
      refute_nil response['error']
      refute_nil response['errormsg']
    end

    it "can update blast with valid blast_id" do
      blast_id = 42499
      name = 'blast name changed'
      from_name = 'prajwal tuladhar'
      stub_post(@api_call_url, 'blast_post_update_valid.json')
      response = @sailthru_client.update_blast(blast_id = blast_id, from_name = from_name)
      assert_equal(name, response['name'])
    end

    it "can delete valid blast" do
      blast_id = 42499
      params = {'blast_id' => blast_id}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_delete(@api_call_url + '?' + query_string, 'blast_delete_valid.json')
      response = @sailthru_client.delete_blast(blast_id)
      assert_equal(blast_id, response['blast_id'])
    end

    it "cannot delete invalid blast" do
      invalid_blast_id = '88787'
      params = {'blast_id' => invalid_blast_id}
      query_string = create_json_payload(@api_key, @secret, params)
      stub_delete(@api_call_url + '?' + query_string, 'blast_delete_invalid.json')
      response = @sailthru_client.delete_blast(invalid_blast_id)
      refute_nil response['error']
      refute_nil response['errormsg']
    end

    it "can cancel a valid blast" do
      blast_id = 42499
      stub_post(@api_call_url, 'blast_post_update_valid.json')
      response = @sailthru_client.cancel_blast(blast_id)
      assert_equal(blast_id, response['blast_id'])
    end

  end
end
