require "kemal"
require "kemal-session"
require "kemal-session-bcdb"

require "threebot"

module CrystalDrive::Init
    include Threebot

    if !ENV.has_key?("SECRET_KEY")
        raise "Missing Environment Variable SECRET_KEY"
      end

    Kemal::Session.config do |config|
        config.cookie_name = "redis_test"
        config.secret = "a_secret"
        config.engine = Kemal::Session::BcdbEngine.new(unixsocket= "/tmp/bcdb.sock", namespace = "kemal_sessions", key_prefix = "kemal:session:")
        config.timeout = Time::Span.new hours: 240, minutes: 0, seconds: 0
    end

        # workaround until kemal really supports 0.35
    class HTTP::Server::Response
        class Output
        # original definition since Crystal 0.35.0
        def close
            return if closed?
    
            unless response.wrote_headers?
            response.content_length = @out_count
            end
    
            ensure_headers_written
    
            super
    
            if @chunked
            @io << "0\r\n\r\n"
            @io.flush
            end
        end
    
        # patch from https://github.com/kemalcr/kemal/pull/576
        def close
            # ameba:disable Style/NegatedConditionsInUnless
            unless response.wrote_headers? && !response.headers.has_key?("Content-Range")
            response.content_length = @out_count
            end
    
            ensure_headers_written
    
            previous_def
        end
        end
    end

    

    # After successful login with 3 bot
    def threebot_login(env, email, username)
        token = CrystalDrive::Token.generate_token(username, email, "en", "mosaic", {"admin" => true, "execute" => true, "create" => true, "rename" => true, "modify" => true, "delete" => true,  "share" => true}, false, Array(String).new)
        env.session.string("token", token)
        env.session.string("username", username)
        env.session.string("email", email)
        token
    end
end