require 'net/http'
require 'uri'
require 'cgi'
require 'rubygems'
require 'json'
require 'digest/md5'

module Sailthru

  Version = VERSION = '1.04'

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
      Digest::MD5.hexdigest(get_signature_string(params, secret)).to_s
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

    def verify_purchase_items (items)
      if items.class == Array and !items.empty?
        required_item_fields = ['qty', 'title', 'price', 'id', 'url'].sort
        items.each do |v|
          keys = v.keys.sort
          return false if keys != required_item_fields
        end
        return true
      end
      return false
    end
  end

  class SailthruClient

    include Helpers

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
      api_post(:blast, post)
    end


    # params
    #   blast_id, Fixnum | String
    #   name, String
    #   list, String
    #   schedule_time, String
    #   from_name, String
    #   from_email, String
    #   subject, String
    #   content_html, String
    #   content_text, String
    #   options, hash
    #
    # updates existing blast
    def update_blast(blast_id, name = nil, list = nil, schedule_time = nil, from_name = nil, from_email = nil, subject = nil, content_html = nil, content_text = nil, options = {})
      data = options ? options : {}
      data[:blast_id] = blast_id
      if name != nil
        data[:name] = name
      end
      if list !=  nil
        data[:list] = list
      end
      if schedule_time != nil
        data[:schedule_time] = schedule_time
      end
      if from_name != nil
        data[:from_name] = from_name
      end
      if from_email != nil
        data[:from_email] = from_email
      end
      if subject != nil
        data[:subject] = subject
      end
      if content_html != nil
        data[:content_html] = content_html
      end
      if content_text != nil
        data[:content_text] = content_text
      end
      api_post(:blast, data)
    end


    # params:
    #   blast_id, Fixnum | String
    # returns:
    #   Hash, response data from server
    #
    # Get information on a previously scheduled email blast
    def get_blast(blast_id)
      api_get(:blast, {:blast_id => blast_id.to_s})
    end

    # params:
    #   blast_id, Fixnum | String
    #
    # Cancel a scheduled Blast
    def cancel_blast(blast_id)
      api_post(:blast, {:blast_id => blast_id, :schedule_time => ''})
    end

    # params:
    #   blast_id, Fixnum | String
    #
    # Delete a Blast
    def delete_blast(blast_id)
      api_delete(:blast, {:blast_id => blast_id})
    end

    # params:
    #   email, String
    # returns:
    #   Hash, response data from server
    #
    # Return information about an email address, including replacement vars and lists.
    def get_email(email)
      api_get(:email, {:email => email})
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

    # params:
    #   email, String
    #   items, String
    #   incomplete, Integer
    #   message_id, String
    # returns:
    #   hash, response from server
    #
    # Record that a user has made a purchase, or has added items to their purchase total.
    def purchase(email, items, incomplete = nil, message_id = nil)
      data = {}
      data[:email] = email

      if verify_purchase_items(items)
        data[:items] = items
      end

      if incomplete != nil
        data[:incomplete] = incomplete.to_i
      end

      if message_id != nil
        data[:message_id] = message_id
      end
      api_post(:purchase, data)
    end


    # <b>DEPRECATED:</b> Please use either stats_list or stats_blast
    # params:
    #   stat, String
    #
    #  returns:
    #   hash, response from server
    # Request various stats from Sailthru.
    def get_stats(stat)
      warn "[DEPRECATION] `get_stats` is deprecated. Please use `stats_list` and `stats_blast` instead"
      api_get(:stats, {:stat => stat})
    end


    # params
    #   list, String
    #   date, String
    #
    # returns:
    #   hash, response from server
    # Retrieve information about your subscriber counts on a particular list, on a particular day.
    def stats_list(list = nil, date = nil)
      data = {}
      if list != nil
        data[:list] = list
      end
      if date != nil
        data[:date] = date
      end
      data[:stat] = 'list'

      stats(data)
    end


    # params
    #   blast_id, String
    #   start_date, String
    #   end_date, String
    #   options, Hash
    #
    # returns:
    #   hash, response from server
    # Retrieve information about a particular blast or aggregated information from all of blasts over a specified date range
    def stats_blast(blast_id = nil, start_date = nil, end_date = nil, options = {})
      data = options
      if blast_id != nil
        data[:blast_id] = blast_id
      end
      if start_date != nil
        data[:start_date] = start_date
      end
      if end_date != nil
        data[:end_date] = end_date
      end
      data[:stat] = 'blast'
      stats(data)
    end


    # params
    #   title, String
    #   url, String
    #   date, String
    #   tags, Array or Comma separated string
    #   vars, Hash
    #
    # Push a new piece of content to Sailthru, triggering any applicable alerts.
    # http://docs.sailthru.com/api/content
    def push_content(title, url, date = nil, tags = nil, vars = {})
      data = {}
      data[:title] = title
      data[:url] = url
      if date != nil
        data[:date] = date
      end
      if tags != nil
        if tags.class == Array
          tags = tags.join(',')
        end
        data[:tags] = tags
      end
      if vars.length > 0
        data[:vars] = vars
      end
      api_post(:content, data)
    end

    # params
    #   list, String
    #   format, String
    #
    # Download a list. Obviously, this can potentially be a very large download.
    # 'txt' is default format since, its more compact as compare to others
    def get_list(list, format = 'txt')
      return api_get(:list, {:list => list, :format => format})
    end


    # params
    #   list, String
    #   emails, String | Array
    # Upload a list. The list import job is queued and will happen shortly after the API request.
    def save_list(list, emails)
      data = {}
      data[:list] = list
      data[:emails] = (emails.class == Array) ? emails.join(',') : emails
     return api_post(:list, data)
    end


    # params
    #   list, String
    #
    # Deletes a list
    def delete_list(list)
      api_delete(:list, {:list => list})
    end

    # params
    #   email, String
    #   hid_only, Boolean
    #
    # gets horizon data
    def get_horizon(email, hid_only = false)
      data = {}
      data[:email] = email
     if hid_only == true
        data[:hid_only] = 1
     end
      api_get(:horizon, data)
    end


    # params
    #   email, String
    #   tags, String | Array
    #
    # sets horizon data
    def set_horizon(email, tags)
      data = {}
      data[
      :email] = email
      data[:tags] = (tags.class == Array) ? tags.join(',') : tags
      api_post(:horizon, data)
    end

    # params
    #   email, String
    #
    # get user alert data
    def get_alert(email)
      api_get(:alert, {:email => email})
    end

    # params
    #   email, String
    #   type, String
    #   template, String
    #   _when, String
    #   options, hash
    #
    # Add a new alert to a user. You can add either a realtime or a summary alert (daily/weekly).
    # _when is only required when alert type is weekly or daily
    def save_alert(email, type, template, _when = nil, options = {})
      data = options
      data[:email] = email
      data[:type] = type
      data[:template] = template
      if (type == 'weekly' || type == 'daily')
        data[:when] = _when
      end
      api_post(:alert, data)
    end


    # params
    #   email, String
    #   alert_id, String
    #
    # delete user alert
    def delete_alert(email, alert_id)
      data = {:email => email, :alert_id => alert_id}
      api_delete(:alert, data)
    end

    # Make Stats API Request
    def stats(data)
      api_get(:stats, data)
    end

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
    
    protected

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
     if data[:format] == 'json'
        begin
           unserialized = JSON.parse(_result)
          return unserialized ? unserialized : _result
        rescue JSON::JSONError => e
          return {'error' => e}
        end
     end
     return _result
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
