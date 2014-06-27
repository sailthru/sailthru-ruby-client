require 'test_helper'

class ReceivePostCallbackTest < Minitest::Test
  describe "API helpers: validate post callbacks" do
    before do
      @api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::Client.new(@api_key, @secret, @api_url)
    end

    it "can validate a verify callback" do
      valid_send_id = "TT1ClGdj2bRHAAP6"
      get_send_params = {
        'send_id' => valid_send_id
      }
      query_string = create_json_payload(@api_key, @secret, get_send_params)
      stub_get(sailthru_api_call_url(@api_url, 'send') + '?' + query_string , 'send_get_valid.json')

      params = {
        :email => 'praj@sailthru.com',
        :action => :verify,
        :send_id => valid_send_id,
        :api_key => @api_key
      }
      params[:sig] = get_signature_hash(params, @secret)
      assert @sailthru_client.receive_verify_post(params, mock(:post? => true))
    end

    it "can validate a opt-out callback" do
      params = {
        :email => 'ian@sailthru.com',
        :mode => 'all',
        :optout => '0',
        :action => 'optout',
        :api_key => @api_key
      }
      params[:sig] = get_signature_hash(params, @secret)
      assert @sailthru_client.receive_optout_post(params, mock(:post? => true))
    end

    it "can validate a hardbounce callback" do
      params = {
        :email => 'ian@sailthru.com',
        :action => 'hardbounce',
        :send_id => 'TT1ClGdj2bRHAAP6',
        :api_key => @api_key
      }
      params[:sig] = get_signature_hash(params, @secret)
      assert @sailthru_client.receive_hardbounce_post(params, mock(:post? => true))
    end

  end
end
