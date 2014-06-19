require 'sailthru/helpers'

require 'net/http'
require 'net/http/post/multipart'
require 'uri'
require 'cgi'
require 'json'

module Sailthru
  class Client
    DEFAULT_API_URI = 'https://api.sailthru.com'

    include Helpers

    attr_accessor :verify_ssl

    # params:
    #   api_key, String
    #   secret, String
    #   api_uri, String
    #
    # Instantiate a new client; constructor optionally takes overrides for key/secret/uri and proxy server settings.
    def initialize(api_key=nil, secret=nil, api_uri=nil, proxy_host=nil, proxy_port=nil, opts={})
      @api_key = api_key || Sailthru.api_key || raise(ArgumentError, "You must provide an API key or call Sailthru.credentials() first")
      @secret  = secret || Sailthru.secret || raise(ArgumentError, "You must provide your secret or call Sailthru.credentials() first")
      @api_uri = api_uri.nil? ? DEFAULT_API_URI : api_uri
      @proxy_host = proxy_host
      @proxy_port = proxy_port
      @verify_ssl = true
      @opts = opts
    end

    # params:
    #   template_name, String
    #   email, String
    #   vars, Hash
    #   options, Hash
    #     replyto: override Reply-To header
    #     test: send as test email (subject line will be marked, will not count towards stats)
    # returns:
    #   Hash, response data from server
    def send_email(template_name, email, vars={}, options = {}, schedule_time = nil, limit = {})
      post = {}
      post[:template] = template_name
      post[:email] = email
      post[:vars] = vars if vars.length >= 1
      post[:options] = options if options.length >= 1
      post[:schedule_time] = schedule_time if !schedule_time.nil?
      post[:limit] = limit if limit.length >= 1
      api_post(:send, post)
    end

    def multi_send(template_name, emails, vars={}, options = {}, schedule_time = nil, evars = {})
      post = {}
      post[:template] = template_name
      post[:email] = emails
      post[:vars] = vars if vars.length >= 1
      post[:options] = options if options.length >= 1
      post[:schedule_time] = schedule_time if !schedule_time.nil?
      post[:evars] = evars if evars.length >= 1
      api_post(:send, post)
    end

    # params:
    #   send_id, Fixnum
    # returns:
    #   Hash, response data from server
    #
    # Get the status of a send.
    def get_send(send_id)
      api_get(:send, {:send_id => send_id.to_s})
    end

    def cancel_send(send_id)
      api_delete(:send, {:send_id => send_id.to_s})
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

    # Schedule a mass mail blast from template
    def schedule_blast_from_template(template, list, schedule_time, options={})
      post = options ? options : {}
      post[:copy_template] = template
      post[:list] = list
      post[:schedule_time] = schedule_time
      api_post(:blast, post)
    end

    # Schedule a mass mail blast from previous blast
    def schedule_blast_from_blast(blast_id, schedule_time, options={})
      post = options ? options : {}
      post[:copy_blast] = blast_id
      #post[:name] = name
      post[:schedule_time] = schedule_time
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
    #   options, hash
    # returns:
    #   Hash, response data from server
    #
    # Get information on a previously scheduled email blast
    def get_blast(blast_id, options={})
      options[:blast_id] = blast_id.to_s
      api_get(:blast, options)
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
    #   options, Hash mapping optional parameters
    # returns:
    #   Hash, response data from server
    #
    # Set replacement vars and/or list subscriptions for an email address.
    def set_email(email, vars = {}, lists = {}, templates = {}, options = {})
      data = options
      data[:email] = email
      data[:vars] = vars unless vars.empty?
      data[:lists] = lists unless lists.empty?
      data[:templates] = templates unless templates.empty?
      api_post(:email, data)
    end

    # params:
    #   new_email, String
    #   old_email, String
    #   options, Hash mapping optional parameters
    # returns:
    #   Hash of response data.
    #
    # change a user's email address.
    def change_email(new_email, old_email, options = {})
      data = options
      data[:email] = new_email
      data[:change_email] = old_email
      api_post(:email, data)
    end

    # params:
    #   template_name, String
    # returns:
    #   Hash of response data.
    #
    # Get a template.
    def get_template(template_name)
      api_get(:template, {:template => template_name})
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
      api_post(:template, data)
    end

    # params:
    #   template_name, String
    # returns:
    #   Hash of response data.
    #
    # Delete a template.
    def delete_template(template_name)
      api_delete(:template, {:template => template_name})
    end

    # params:
    #   params, Hash
    #   request, String
    # returns:
    #   boolean, Returns true if the incoming request is an authenticated verify post.
    def receive_verify_post(params, request)
      if request.post?
        [:action, :email, :send_id, :sig].each { |key| return false unless params.has_key?(key) }

        return false unless params[:action] == :verify

        sig = params.delete(:sig)
        params.delete(:controller)
        return false unless sig == get_signature_hash(params, @secret)

        _send = get_send(params[:send_id])
        return false unless _send.has_key?(:email)

        return false unless _send[:email] == params[:email]

        return true
      else
        return false
      end
    end

    # params:
    #   params, Hash
    #   request, String
    # returns:
    #   TrueClass or FalseClass, Returns true if the incoming request is an authenticated optout post.
    def receive_optout_post(params, request)
      if request.post?
        [:action, :email, :sig].each { |key| return false unless params.has_key?(key) }

        return false unless params[:action] == 'optout'

        sig = params.delete(:sig)
        params.delete(:controller)
        return false unless sig == get_signature_hash(params, @secret)
        return true
      else
        return false
      end
    end

    # params:
    #   params, Hash
    #   request, String
    # returns:
    #   TrueClass or FalseClass, Returns true if the incoming request is an authenticated hardbounce post.
    def receive_hardbounce_post(params, request)
      if request.post?
        [:action, :email, :sig].each { |key| return false unless params.has_key?(key) }

        return false unless params[:action] == 'hardbounce'

        sig = params.delete(:sig)
        params.delete(:controller)
        return false unless sig == get_signature_hash(params, @secret)
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
    #   options, Hash
    # returns:
    #   hash, response from server
    #
    # Record that a user has made a purchase, or has added items to their purchase total.
    def purchase(email, items, incomplete = nil, message_id = nil, options = {})
      data = options
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
      api_get(:stats, data)
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
      api_get(:stats, data)
    end

    # params
    #   template, String
    #   start_date, String
    #   end_date, String
    #   options, Hash
    #
    # returns:
    #   hash, response from server
    # Retrieve information about a particular blast or aggregated information from all of blasts over a specified date range
    def stats_send(template = nil, start_date = nil, end_date = nil, options = {})
      data = options
      if template != nil
        data[:template] = template
      end
      if start_date != nil
        data[:start_date] = start_date
      end
      if end_date != nil
        data[:end_date] = end_date
      end
      data[:stat] = 'send'
      api_get(:stats, data)
    end

    # params
    #   title, String
    #   url, String
    #   date, String
    #   tags, Array or Comma separated string
    #   vars, Hash
    #   options, Hash
    #
    # Push a new piece of content to Sailthru, triggering any applicable alerts.
    # http://docs.sailthru.com/api/content
    def push_content(title, url, date = nil, tags = nil, vars = {}, options = {})
      data = options
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
    #
    # Get information about a list.
    def get_list(list)
      api_get(:list, {:list => list})
    end

    # params
    #
    # Get information about all lists
    def get_lists
      api_get(:list, {})
    end

    # params
    #   list, String
    #   options, Hash
    # Create a list, or update a list.
    def save_list(list, options = {})
      data = options
      data[:list] = list
      api_post(:list, data)
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

    # params
    #   job, String
    #   options, hash
    #   report_email, String
    #   postback_url, String
    #   binary_key, String
    #
    # interface for making request to job call
    def process_job(job, options = {}, report_email = nil, postback_url = nil, binary_key = nil)
      data = options
      data['job'] = job
      if !report_email.nil?
        data['report_email'] = report_email
      end

      if !postback_url.nil?
        data['postback_url'] = postback_url
      end
      api_post(:job, data, binary_key)
    end

    # params
    #   emails, String | Array
    # implementation for import_job
    def process_import_job(list, emails, report_email = nil, postback_url = nil, options = {})
      data = options
      data['list'] = list
      data['emails'] = Array(emails).join(',')
      process_job(:import, data, report_email, postback_url)
    end

    # implementation for import job using file upload
    def process_import_job_from_file(list, file_path, report_email = nil, postback_url = nil, options = {})
      data = options
      data['list'] = list
      data['file'] = file_path
      process_job(:import, data, report_email, postback_url, 'file')
    end

    # implementation for update job using file upload
    def process_update_job_from_file(file_path, report_email = nil, postback_url = nil, options = {})
      data = options
      data['file'] = file_path
      process_job(:update, data, report_email, postback_url, 'file')
    end

    # implementation for snapshot job
    def process_snapshot_job(query = {}, report_email = nil, postback_url = nil, options = {})
      data = options
      data['query'] = query
      process_job(:snapshot, data, report_email, postback_url)
    end

    # implementation for export list job
    def process_export_list_job(list, report_email = nil, postback_url = nil, options = {})
      data = options
      data['list'] = list
      process_job(:export_list_data, data, report_email, postback_url)
    end

    # get status of a job
    def get_job_status(job_id)
      api_get(:job, {'job_id' => job_id})
    end

    # Get user by Sailthru ID
    def get_user_by_sid(id, fields = {})
      api_get(:user, {'id' => id, 'fields' => fields})
    end

    # Get user by specified key
    def get_user_by_key(id, key, fields = {})
      data = {
          'id' => id,
          'key' => key,
          'fields' => fields
      }
      api_get(:user, data)
    end

    # Create new user, or update existing user
    def save_user(id, options = {})
      data = options
      data['id'] = id
      api_post(:user, data)
    end

    # params
    # Get an existing trigger
    def get_triggers
      api_get(:trigger, {})
    end

    # params
    #   template, String
    #   trigger_id, String
    # Get an existing trigger
    def get_trigger_by_template(template, trigger_id = nil)
      data = {}
      data['template'] = template
      if trigger_id != nil then data['trigger_id'] = trigger_id end
      api_get(:trigger, data)
    end

    # params
    #   event, String
    # Get an existing trigger
    def get_trigger_by_event(event)
      data = {}
      data['event'] = event
      api_get(:trigger, data)
    end

    # params
    #   template, String
    #   time, String
    #   time_unit, String
    #   event, String
    #   zephyr, String
    # Create or update a trigger
    def post_template_trigger(template, time, time_unit, event, zephyr)
      data = {}
      data['template'] = template
      data['time'] = time
      data['time_unit'] = time_unit
      data['event'] = event
      data['zephyr'] = zephyr
      api_post(:trigger, data)
    end

    # params
    #   template, String
    #   time, String
    #   time_unit, String
    #   zephyr, String
    # Create or update a trigger
    def post_event_trigger(event, time, time_unit, zephyr)
      data = {}
      data['time'] = time
      data['time_unit'] = time_unit
      data['event'] = event
      data['zephyr'] = zephyr
      api_post(:trigger, data)
    end

    # params
    #   id, String
    #   event, String
    #   options, Hash (Can contain vars, Hash and/or key)
    # Notify Sailthru of an Event
    def post_event(id, event, options = {})
      data = options
      data['id'] = id
      data['event'] = event
      api_post(:event, data)
    end

    # Perform API GET request
    def api_get(action, data)
      api_request(action, data, 'GET')
    end

    # Perform API POST request
    def api_post(action, data, binary_key = nil)
      api_request(action, data, 'POST', binary_key)
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
    def api_request(action, data, request_type, binary_key = nil)
      if !binary_key.nil?
        binary_key_data = data[binary_key]
        data.delete(binary_key)
      end

      if data[:format].nil? || data[:format] == 'json'
        data = prepare_json_payload(data)
      else
        data[:api_key] = @api_key
        data[:format] ||= 'json'
        data[:sig] = get_signature_hash(data, @secret)
      end

      if !binary_key.nil?
        data[binary_key] = binary_key_data
      end
      _result = http_request("#{@api_uri}/#{action}", data, request_type, binary_key)

      # NOTE: don't do the unserialize here
      if data[:format] == 'json'
        begin
          unserialized = JSON.parse(_result)
          return unserialized ? unserialized : _result
        rescue JSON::JSONError => e
          return {'error' => e}
        end
      end
      _result
    end

    # set up our post request
    def set_up_post_request(uri, data, headers, binary_key = nil)
      if !binary_key.nil?
        binary_data = data[binary_key]

        if binary_data.is_a?(StringIO)
          data[binary_key] = UploadIO.new(
            binary_data, "text/plain", "local.path"
          )
        else
          data[binary_key] = UploadIO.new(
            File.open(binary_data), "text/plain"
          )
        end

        req = Net::HTTP::Post::Multipart.new(uri.path, data)
      else
        req = Net::HTTP::Post.new(uri.path, headers)
        req.set_form_data(data)
      end
      req
    end

    # params:
    #   uri, String
    #   data, Hash
    #   method, String "GET" or "POST"
    # returns:
    #   String, body of response
    def http_request(uri, data, method = 'POST', binary_key = nil)
      data = flatten_nested_hash(data, false)

      if method != 'POST'
        uri += "?" + data.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
      end

      req = nil
      headers = {"User-Agent" => "Sailthru API Ruby Client #{VERSION}"}

      _uri  = URI.parse(uri)

      if method == 'POST'
        req = set_up_post_request(
          _uri, data, headers, binary_key
        )

      else
        request_uri = "#{_uri.path}?#{_uri.query}"
        if method == 'DELETE'
          req = Net::HTTP::Delete.new(request_uri, headers)
        else
          req = Net::HTTP::Get.new(request_uri, headers)
        end
      end

      begin
        http = Net::HTTP::Proxy(@proxy_host, @proxy_port).new(_uri.host, _uri.port)

        if _uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @verify_ssl != true  # some openSSL client doesn't work without doing this
          http.ssl_timeout = @opts[:http_ssl_timeout] || 5
        end
        http.open_timeout = @opts[:http_open_timeout] || 5
        http.read_timeout = @opts[:http_read_timeout] || 10
        http.close_on_empty_response = @opts[:http_close_on_empty_response] || true

        response = http.start do
          http.request(req)
        end

      rescue Timeout::Error, Errno::ETIMEDOUT => e
        raise UnavailableError, "Timed out: #{_uri}"
      rescue => e
        raise ClientError, "Unable to open stream to #{_uri}: #{e.message}"
      end

      response.body || raise(ClientError, "No response received from stream: #{_uri}")
    end

    def http_multipart_request(uri, data)
      Net::HTTP::Post::Multipart.new url.path,
        "file" => UploadIO.new(data['file'], "application/octet-stream")
    end

    def prepare_json_payload(data)
      payload = {
        :api_key => @api_key,
        :format => 'json', #<3 XML
        :json => data.to_json
      }
      payload[:sig] = get_signature_hash(payload, @secret)
      payload
    end
  end
end
