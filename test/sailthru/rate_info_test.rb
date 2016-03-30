require 'test_helper'

class RateInfoTest < Minitest::Test
    describe "get_last_rate_limit_info() (All API Calls)" do
        before do
            @api_url = 'http://api.sailthru.com'
            @secret = 'my_secret'
            @api_key = 'my_api_key'
            @sailthru_client = Sailthru::Client.new(@api_key, @secret, @api_url)
        end

        it "returns rate limit info for a given endpoint and method" do
            # perform a /send GET request
            api_call_url = sailthru_api_call_url(@api_url, 'send')
            valid_send_id = "TT1ClGdj2bRHAAP6"
            params = {
                    'send_id' => valid_send_id
            }
            query_string = create_json_payload(@api_key, @secret, params)
            rate_headers = get_rate_info_headers(3, 2, Time.now.to_i)
            stub_get(api_call_url + '?' + query_string , 'send_get_valid.json', rate_headers)
            response = @sailthru_client.get_send(valid_send_id)
            assert_equal valid_send_id, response['send_id']

            # verify the subsequent rate info for /send GET
            rate_info = @sailthru_client.get_last_rate_limit_info(:send, :get)
            assert_equal rate_headers[:x_rate_limit_limit], rate_info[:limit]
            assert_equal rate_headers[:x_rate_limit_remaining], rate_info[:remaining]
            assert_equal rate_headers[:x_rate_limit_reset], rate_info[:reset]
        end

        it "can return distinct rate limit info for different endpoints" do
            # perform a /send GET request
            send_api_call_url = sailthru_api_call_url(@api_url, 'send')
            valid_send_id = "TT1ClGdj2bRHAAP6"
            send_query_string = create_json_payload(@api_key, @secret, { 'send_id' => valid_send_id })
            send_rate_headers = get_rate_info_headers(3, 2, Time.now.to_i + 10)
            stub_get(send_api_call_url + '?' + send_query_string , 'send_get_valid.json', send_rate_headers)
            response = @sailthru_client.get_send(valid_send_id)
            assert_equal valid_send_id, response['send_id']

            # perform a /list GET request -- and have this endpoint return different rate info
            list_api_call_url = sailthru_api_call_url(@api_url, 'list')
            list = 'list1'
            list_query_string = create_json_payload(@api_key, @secret, {'list' => list})
            list_rate_headers = get_rate_info_headers(5, 4, Time.now.to_i + 8)
            stub_get(list_api_call_url + '?' + list_query_string, 'list_get_valid.json', list_rate_headers)
            response = @sailthru_client.get_list(list)
            assert_equal(response['list'], list)

            # verify the rate info for each call
            send_rate_info = @sailthru_client.get_last_rate_limit_info(:send, :get)
            assert_equal send_rate_headers[:x_rate_limit_limit], send_rate_info[:limit]
            assert_equal send_rate_headers[:x_rate_limit_remaining], send_rate_info[:remaining]
            assert_equal send_rate_headers[:x_rate_limit_reset], send_rate_info[:reset]

            list_rate_info = @sailthru_client.get_last_rate_limit_info(:list, :get)
            assert_equal list_rate_headers[:x_rate_limit_limit], list_rate_info[:limit]
            assert_equal list_rate_headers[:x_rate_limit_remaining], list_rate_info[:remaining]
            assert_equal list_rate_headers[:x_rate_limit_reset], list_rate_info[:reset]
        end

        it "can return distinct rate limit info for different methods" do
            api_call_url = sailthru_api_call_url(@api_url, 'send')

            # perform a /send GET request
            valid_send_id = "TT1ClGdj2bRHAAP6"
            get_query_string = create_json_payload(@api_key, @secret, { 'send_id' => valid_send_id })
            get_rate_headers = get_rate_info_headers(3, 2, Time.now.to_i + 10)
            stub_get(api_call_url + '?' + get_query_string , 'send_get_valid.json', get_rate_headers)
            response = @sailthru_client.get_send(valid_send_id)
            assert_equal valid_send_id, response['send_id']

            # perform a /send POST request -- and have this method return different rate info
            template_name = 'default'
            email = 'example@example.com'
            post_rate_headers = get_rate_info_headers(5, 4, Time.now.to_i + 8)
            stub_post(api_call_url, 'send_get_valid.json', post_rate_headers)
            response = @sailthru_client.send_email template_name, email, {"name" => "Unix",  "myvar" => [1111,2,3], "mycomplexvar" => {"tags" => ["obama", "aaa", "c"]}}
            assert_equal template_name, response['template']

            # verify the rate info for each call
            get_rate_info = @sailthru_client.get_last_rate_limit_info(:send, :get)
            assert_equal get_rate_headers[:x_rate_limit_limit], get_rate_info[:limit]
            assert_equal get_rate_headers[:x_rate_limit_remaining], get_rate_info[:remaining]
            assert_equal get_rate_headers[:x_rate_limit_reset], get_rate_info[:reset]

            post_rate_info = @sailthru_client.get_last_rate_limit_info(:send, :post)
            assert_equal post_rate_headers[:x_rate_limit_limit], post_rate_info[:limit]
            assert_equal post_rate_headers[:x_rate_limit_remaining], post_rate_info[:remaining]
            assert_equal post_rate_headers[:x_rate_limit_reset], post_rate_info[:reset]
        end
    end
end