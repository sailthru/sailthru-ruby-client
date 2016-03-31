require 'test_helper'
require 'mocha/setup'

class FileUploadTest < Minitest::Test

  describe "File Upload Functionality" do

    before do
      @secret = 'my_secret'
      @api_key = 'my_api_key'
      @sailthru_client = Sailthru::Client.new(
        @api_key, @secret, 'http://api.sailthru.com'
      )
      @api_call_url = sailthru_api_call_url(
        'http://api.sailthru.com', 'job'
      )
    end

    it "can upload a file of data" do
      Net::HTTP::Post::Multipart.expects(:new).with(
          instance_of(String),
          has_entries({
            "file" => instance_of(UploadIO)
          })
        )
      Net::HTTP.stubs(:Proxy).returns(Net::HTTP)
      Net::HTTP.any_instance.stubs(
          :request => stub(
            "body" => JSON.unparse({"job_id" => "123"}),
            "[]" => nil
          )
        )

      data = {
        "job" => "update",
        "file" => fixture_file_path('user_update_post_valid.json')
      }
      response = @sailthru_client.api_post(
        :job, data, 'file'
      )
      refute_nil response['job_id']
    end

    it "can upload a string of data" do
      Net::HTTP::Post::Multipart.expects(:new).with(
          instance_of(String),
          has_entries({
            "file" => instance_of(UploadIO)
          })
        )
      Net::HTTP.stubs(:Proxy).returns(Net::HTTP)
      Net::HTTP.any_instance.stubs(
          :request => stub(
            "body" => JSON.unparse({"job_id" => "123"}),
            "[]" => nil
          )
        )

      email = {
        "email" => "dan.langevin@lifebooker.com",
        "vars" => {
          "first_name" => "Dan"
        }
      }
      data = {
        "job" => "update",
        "file" => StringIO.new(JSON.unparse(email))
      }

      response = @sailthru_client.api_post(
        :job, data, 'file'
      )
      refute_nil response['job_id']
    end

  end
end
