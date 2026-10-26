# frozen_string_literal: true

require 'rubygems'
require 'sailthru-client'
require 'sailthru'
require 'socket'
require 'timeout'

def check(condition, message)
  raise message unless condition
end

installed_path = Gem.loaded_specs.fetch('sailthru-client').full_gem_path
check(installed_path.start_with?(File.join(ENV.fetch('GEM_HOME'), '')),
  "Client loaded outside the isolated installation: #{installed_path}")

server = TCPServer.new('127.0.0.1', 0)
server_thread = nil

begin
  # Use a real loopback HTTP exchange, without the unit suite's HTTP mocks.
  server_thread = Thread.new do
    connection = nil
    begin
      Timeout.timeout(10) do
        connection = server.accept
        method, endpoint = connection.gets.split(' ', 3)
        check(method == 'POST', 'Expected a POST request')
        check(endpoint == '/user', 'Expected the /user endpoint')

        headers = {}
        while (line = connection.gets) && line != "\r\n"
          key, value = line.split(':', 2)
          headers[key.downcase] = value.strip
        end
        body = connection.read(Integer(headers.fetch('content-length')))
        params = URI.decode_www_form(body).to_h
        check(params.fetch('api_key') == 'smoke-key', 'API key was not preserved')
        check(params.fetch('format') == 'json', 'Expected the JSON response format')
        check(JSON.parse(params.fetch('json')) == { 'id' => 'smoke@example.com' },
          'User payload was not preserved')
        check(params.fetch('sig').match?(/\A[a-f0-9]{32}\z/),
          'Missing or malformed signature')

        response = JSON.generate('ok' => true)
        connection.write("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n" \
          "Content-Length: #{response.bytesize}\r\nConnection: close\r\n\r\n#{response}")
      end
    ensure
      connection.close if connection
    end
  end

  Timeout.timeout(20) do
    client = Sailthru::Client.new('smoke-key', 'smoke-secret',
      "http://127.0.0.1:#{server.addr[1]}")
    response = client.api_post(:user, { 'id' => 'smoke@example.com' })
    server_thread.value
    check(response == { 'ok' => true }, 'Client did not parse the expected response')
  end
  puts 'Packaged client loaded and completed a local API request.'
ensure
  server.close
  server_thread.kill if server_thread && server_thread.alive?
  server_thread.join if server_thread
end
