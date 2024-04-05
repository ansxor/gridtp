# frozen_string_literal: true

module GridTP
  GRIDTP_VERSION = 'gridtp/1.0.0'

  class VersionError < RuntimeError
    def initialize(msg='The version of GridTP in this message is incompatible')
      super(msg)
    end
  end
  
  class Body
    attr_accessor :data_type, :data, :size

    def initialize(data_type, data, size)
      @data_type = data_type
      @data = data
      @size = size
    end
  end
  
  class Message
    PREPEND = '#!/'

    class MessageParseError < RuntimeError
    end

    attr_reader :body
    
    def self.get_header_data(header)
      unless header.start_with?(PREPEND)
        raise MessageParseError, "Header doesn't start with correct prepend (#{PREPEND})"
      end

      header[PREPEND.length..-1].strip
    end

    def self.verify_version(version)
      version == GridTP::GRIDTP_VERSION
    end
  end

  class Request < Message
  end

  class Response < Message
  end
end
