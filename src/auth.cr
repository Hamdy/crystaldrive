require "jwt"
require "base64"
class CrystalDrive::Token
    def self.generate_token(username, email, locale, viewmode, permissions, lockpassword, commands)
        now = Time.utc.to_unix
        exp = now + 172800
        JWT.encode(
            {
                "user" => {
                    "id" => username,
                    "locale" => locale,
                    "viewmode" => viewmode,
                    "perm" => permissions,
                    "lockpassword" => lockpassword,
                    "commands" => commands,
                    "email" => email,
                },
                "exp" => exp,
                "iat" => now,
                "iss" => "Crystal Drive"
            },
            
            ENV["SECRET_KEY"], JWT::Algorithm::HS256)
    end

    def self.is_valid?(token, username, email)
        begin
            payload, _ = JWT.decode(token, ENV["SECRET_KEY"], JWT::Algorithm::HS256)
            return true unless payload["user"]["id"] != username || payload["user"]["email"] != email
        rescue JWT::ExpiredSignatureError
        rescue JWT::VerificationError
        end
        return false
    end
end
