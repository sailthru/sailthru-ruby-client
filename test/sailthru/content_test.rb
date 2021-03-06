require 'test_helper'

class ContentTest < Minitest::Test
  describe "API Call: content" do
    before do
      api_url = 'http://api.sailthru.com'
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::Client.new(@api_key, @secret, api_url)
      @api_call_url = sailthru_api_call_url(api_url, 'content')
    end

    describe '#save_content' do
      describe 'creating a content' do
        before do
          id = 'http://example.com/hello-world'
          options = {
            keys: {
              sku: "123abc"
            },
            title: "Product Name Here",
            description: "Product info text goes here.",
            price: 2099,
            inventory: 42,
            date: "2016-06-20 14:30:00 -0400",
            tags: "blue, jeans, size-m",
            vars: {
              var1: "var 1 value"
            },
            images: {
              full: {
                url: "http://example.com/images/product.jpg"
              }
            },
            site_name: "Store"
          }

          stub_post(@api_call_url, 'content_valid.json')

          @response = @sailthru_client.save_content(id, options)
          @last_request_params = CGI::parse(FakeWeb.last_request.body)
          @expected_form_params = options.merge({id: id})
        end

        it 'POST to the correct url' do
          refute_nil @response['content']
        end

        it 'POST with the correct parameters' do
          form_data = JSON.parse(@last_request_params["json"][0], symbolize_names: true)
          assert_equal(form_data, @expected_form_params)
        end
      end

      describe 'updating content by url and sending tags as array' do
        before do
          id = 'http://example.com/hello-world'
          options = {
            tags: ['tag1', 'tag2'],
          }

          stub_post(@api_call_url, 'content_valid.json')

          @response = @sailthru_client.save_content(id, options)
          @last_request_params = CGI::parse(FakeWeb.last_request.body)
          @expected_form_params = options.merge({id: id})
        end

        it 'POST to the correct url' do
          refute_nil @response['content']
        end

        it 'POST form_data tags as string separated by ","' do
          form_data = JSON.parse(@last_request_params["json"][0], symbolize_names: true)
          assert_equal(form_data[:tags], 'tag1,tag2')
        end
      end

      describe 'updating content searching by sku key instead of url' do
        before do
          id = '123abc'
          options = {
            key: 'sku',
            title: "New Product Name Here",
          }

          stub_post(@api_call_url, 'content_valid.json')

          @response = @sailthru_client.save_content(id, options)
          @last_request_params = CGI::parse(FakeWeb.last_request.body)
          @expected_form_params = options.merge({id: id})
        end

        it 'POST to the correct url' do
          refute_nil @response['content']
        end

        it 'POST with the correct parameters' do
          form_data = JSON.parse(@last_request_params["json"][0], symbolize_names: true)
          assert_equal(form_data, @expected_form_params)
        end
      end
    end

    describe '#push_content: DEPRECATED IN FAVOUR OF save_content' do
      describe 'create content item' do
        before do
          title = 'Product Name here'
          url = "http://example.com/product"
          tags = "blue, jeans, size-m"
          date = nil
          vars = {
            var1: 'var 1 value'
          }
          options = {
            keys: {
              sku: "123abc"
            },
            description: "Product info text goes here.",
            price: 2099,
            inventory: 42,
            images: {
              full: {
                url: "http://example.com/images/product.jpg"
              }
            },
            site_name: "Store"
          }

          stub_post(@api_call_url, 'content_valid.json')
          @response = @sailthru_client.push_content(title, url, date, tags, vars, options)

          @last_request_params = CGI::parse(FakeWeb.last_request.body)

          @expected_form_params = options.merge({
            title: title,
            url: url,
            vars: vars,
            tags: tags,
          })
        end

        it 'POST to the correct url' do
          refute_nil @response['content']
        end

        it 'POST with the correct parameters' do
          form_data = JSON.parse(@last_request_params["json"][0], symbolize_names: true)
          assert_equal(form_data, @expected_form_params)
        end
      end

      describe 'create content item with tags as array' do
        before do
          title = 'Product Name here'
          url = "http://example.com/product"
          tags = ['blue', 'jeans', 'size-m']

          stub_post(@api_call_url, 'content_valid.json')
          @response = @sailthru_client.push_content(title, url, nil, tags)

          @last_request_params = CGI::parse(FakeWeb.last_request.body)
        end

        it 'POST to the correct url' do
          refute_nil @response['content']
        end

        it 'POST form_data tags as string separated by ","' do
          form_data = JSON.parse(@last_request_params["json"][0], symbolize_names: true)
          assert_equal(form_data[:tags], 'blue,jeans,size-m')
        end
      end
    end
  end
end
