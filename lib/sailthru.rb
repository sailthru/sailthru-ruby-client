require 'net/http'
require 'uri'
require 'cgi'
require 'rubygems'
require 'json'
require 'md5'

module Sailthru

  class SailthruClientException < Exception
  end

  module Helpers
    # params:
    #   params, Hash
    # returns:
    #   Array, values of each item in the Hash (and nested hashes)
    #
    # Extracts the values of a set of parameters, recursing into nested assoc arrays.
    def extract_param_values(params)
      values = []
      params.each do |k, v|
        if v.class == Hash
          values.concat extract_param_values(v)
       elsif v.class == Array
          temp_hash = Hash.new()
          v.each_with_index do |v_,i_|
            temp_hash[i_.to_s] = v_
          end
          values.concat extract_param_values(temp_hash)
        else
          values.push v.to_s
        end
      end
      return values
    end

    # params:
    #   params, Hash
    #   secret, String
    # returns:
    #   String
    #
    # Returns the unhashed signature string (secret + sorted list of param values) for an API call.
    def get_signature_string(params, secret)
      return secret + extract_param_values(params).sort.join("")
    end


    # params:
    #   params, Hash
    #   secret, String
    # returns:
    #   String
    #
    # Returns an MD5 hash of the signature string for an API call.
    def get_signature_hash(params, secret)
      MD5.md5(get_signature_string(params, secret)).to_s # debuggin
    end


    # Flatten nested hash for GET / POST request.
    def flatten_nested_hash(hash, brackets = true)
      f = {}
      hash.each do |key, value|
        _key = brackets ? "[#{key}]" : key.to_s
        if value.class == Hash
          flatten_nested_hash(value).each do |k, v|
            f["#{_key}#{k}"] = v
          end
        elsif value.class == Array
          temp_hash = Hash.new()
          value.each_with_index do |v, i|
             temp_hash[i.to_s] = v
          end
          flatten_nested_hash(temp_hash).each do |k, v|
            f["#{_key}#{k}"] = v
          end

        else
          f[_key] = value
        end
      end
      return f
    end
  end

  class SailthruClient

    include Helpers
    
    VERSION = '1.01'

    # params:
    #   api_key, String
    #   secret, String
    #   api_uri, String
    #
    # Instantiate a new client; constructor optionally takes overrides for key/secret/uri.
    def initialize(api_key, secret, api_uri)
      @api_key = api_key
      @secret  = secret
      @api_uri = api_uri
    end

    # params:
    #   template_name, String
    #   email, String
    #   replacements, Hash
    #   options, Hash
    #     replyto: override Reply-To header
    #     test: send as test email (subject line will be marked, will not count towards stats)
    # returns:
    #   Hash, response data from server
    def send(template_name, email, vars={}, options = {}, schedule_time = nil)
      post = {}
      post[:template] = template_name
      post[:email] = email
      post[:options] = options

      if vars.length > 0
        post[:vars] = vars
      end
      
      if schedule_time != nil
          post[:schedule_time] = schedule_time
      end
      return self.api_post(:send, post)
    end


    def multi_send(template_name, emails, vars={}, options = {}, schedule_time = nil)
      post = {}
      post[:template] = template_name
      post[:email] = emails
      post[:options] = options

      if schedule_time != nil
          post[:schedule_time] = schedule_time
      end

      if vars.length > 0
        post[:vars] = vars
      end

      return self.api_post(:send, post)
    end


    # params:
    #   send_id, Fixnum
    # returns:
    #   Hash, response data from server
    #
    # Get the status of a send.
    def get_send(send_id)
      self.api_get(:send, {:send_id => send_id.to_s})
    end

    
    def cancel_send(send_id)
      self.api_delete(:send, {:send_id => send_id.to_s})
    end

    # params:
    #   name, String
    #   list, String
    #   schedule_time, String
    #   from_name, String
    #   from_email, String
    #   subject, String
    #   content_html, String
    #   content_text, String
    #   options, Hash
    # returns:
    #   Hash, response data from server
    #
    # Schedule a mass mail blast
    def schedule_blast(name, list, schedule_time, from_name, from_email, subject, content_html, content_text, options = {})
      post = options ? options : {}
      post[:name] = name
      post[:list] = list
      post[:schedule_time] = schedule_time
      post[:from_name] = from_name
      post[:from_email] = from_email
      post[:subject] = subject
      post[:content_html] = content_html
      post[:content_text] = content_text
      self.api_post(:blast, post)
    end


    # params:
    #   blast_id, Fixnum
    # returns:
    #   Hash, response data from server
    #
    # Get information on a previously scheduled email blast
    def get_blast(blast_id)
      self.api_get(:blast, {:blast_id => blast_id.to_s})
    end

    # params:
    #   email, String
    # returns:
    #   Hash, response data from server
    #
    # Return information about an email address, including replacement vars and lists.
    def get_email(email)
      self.api_get(:email, {:email => email})
    end

    # params:
    #   email, String
    #   vars, Hash
    #   lists, Hash mapping list name => 1 for subscribed, 0 for unsubscribed
    # returns:
    #   Hash, response data from server
    #
    # Set replacement vars and/or list subscriptions for an email address.
    def set_email(email, vars = {}, lists = {}, templates = {})
      data = {:email => email}
      data[:vars] = vars unless vars.empty?
      data[:lists] = lists unless lists.empty?
      data[:templates] = templates unless templates.empty?
      self.api_post(:email, data)
    end

    # params:
    #  email, String
    #  password, String
    #  with_names, Boolean
    # returns:
    #  Hash, response data from server
    #
    # Fetch email contacts from an address book at one of the major email providers (aol/gmail/hotmail/yahoo)
    # Use the with_names parameter if you want to fetch the contact names as well as emails
    def import_contacts(email, password, with_names = false)
      data = { :email => email, :password => password }
      data[:names] = 1 if with_names
      self.api_post(:contacts, data)
    end


    # params:
    #   template_name, String
    # returns:
    #   Hash of response data.
    #
    # Get a template.
    def get_template(template_name)
      self.api_get(:template, {:template => template_name})
    end


    # params:
    #   template_name, String
    #   template_fields, Hash
    # returns:
    #   Hash containg response from the server.
    #
    # Save a template.
    def save_template(template_name, template_fields)
      data = template_fields
      data[:template] = template_name
      self.api_post(:template, data)
    end


    # params:
    #   params, Hash
    #   request, String
    # returns:
    #   TrueClass or FalseClass, Returns true if the incoming request is an authenticated verify post.
    def receive_verify_post(params, request)
      if request.post?
        [:action, :email, :send_id, :sig].each { |key| return false unless params.has_key?(key) }

        return false unless params[:action] == :verify

        sig = params[:sig]
        params.delete(:sig)
        return false unless sig == get_signature_hash(params, @secret)

        _send = self.get_send(params[:send_id])
        return false unless _send.has_key?(:email)

        return false unless _send[:email] == params[:email]

        return true
      else
        return false
      end
    end


    # Record that a user has made a purchase, or has added items to their purchase total.
    def purchase(email, items, incomplete = nil, message_id = nil)
      data = {}
      data[:email] = email
      data[:items] = items
      if incomplete != nil
        data[:incomplete] = incomplete.to_i
      end
      if message_id != nil
        data[:message_id] = message_id
      end
      api_post(:purchase, data)
    end


    protected

    # Perform API GET request
    def api_get(action, data)
      api_request(action, data, 'GET')
    end

    # Perform API POST request
    def api_post(action, data)
      api_request(action, data, 'POST')
    end

    #Perform API DELETE request
    def api_delete(action, data)
      api_request(action, data, 'DELETE')
    end

    # params:
    #   action, String
    #   data, Hash
    #   request, String "GET" or "POST"
    # returns:
    #   Hash
    #
    # Perform an API request, using the shared-secret auth hash.
    #
    def api_request(action, data, request_type)
      data[:api_key] = @api_key
      data[:format] ||= 'json'
      data[:sig] = get_signature_hash(data, @secret)
      _result = self.http_request("#{@api_uri}/#{action}", data, request_type)


      # NOTE: don't do the unserialize here
      unserialized = JSON.parse(_result)
      return unserialized ? unserialized : _result
    end


    # params:
    #   uri, String
    #   data, Hash
    #   method, String "GET" or "POST"
    # returns:
    #   String, body of response
    def http_request(uri, data, method = 'POST')
      data = flatten_nested_hash(data, false)
      if method == 'POST'
        post_data = data
      else
        uri += "?" + data.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
      end
      req = nil
      headers = {"User-Agent" => "Sailthru API Ruby Client #{VERSION}"}
      
      _uri  = URI.parse(uri)
      if method == 'POST'
        req = Net::HTTP::Post.new(_uri.path, headers)
        req.set_form_data(data)
      else
        request_uri = "#{_uri.path}?#{_uri.query}"
        if method == 'DELETE'
          req = Net::HTTP::Delete.new(request_uri, headers)
        else
          req = Net::HTTP::Get.new(request_uri, headers)
        end
      end

      begin
        response = Net::HTTP.start(_uri.host, _uri.port) {|http|
          http.request(req)
        }
      rescue Exception => e
        raise SailthruClientException.new("Unable to open stream: #{_uri.to_s}");
      end

      if response.body
        return response.body
      else
        raise SailthruClientException.new("No response received from stream: #{_uri.to_s}")
      end
    end    
  end
end