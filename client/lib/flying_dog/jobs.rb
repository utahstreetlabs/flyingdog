module FlyingDog
  module Jobs
    class Base < Ladon::Job
      def self.include_ladon_context?
        false
      end

      def self.work(uid); end
    end

    # We get fresh tokens out of facebook using two different approaches.
    # 1) +ExchangeFacebookToken+
    #    We have a (probably) short-lived token from facebook, which we can trade for a long-lived token.
    #    Usually received via the omniauth oauth blob when a user hits "connect with facebook"
    #    A short-lived token *can* be used for connections to the graph, we just want one with a longer expiry.
    #    See https://developers.facebook.com/roadmap/offline-access-removal (scenario 4)
    # 2) +ExchangeFacebookCode+
    #    We have a 'code' from facebook, which *cannot* be used for connections to the graph api.
    #    We can exchange this code for a proper (long-lived) token and then use the token.
    #    We get these from signed requests (https://developers.facebook.com/docs/authentication/signed_request/)
    #    which we receive in js callbacks in the brooklyn UI.  Usually because a user is logging in via
    #    username/password but we also want to take the opportunity to refresh their token.
    #    See http://developers.facebook.com/docs/authentication/server-side (section #4) for the code exchange model.
    class ExchangeFacebookToken < Base
      @queue = :auth
    end
    class ExchangeFacebookCode < Base
      @queue = :auth
    end
  end
end
