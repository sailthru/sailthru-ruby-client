require 'digest/md5'

module Sailthru
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
          temp_hash = {}
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
          temp_hash = {}
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
end
