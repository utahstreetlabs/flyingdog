require 'flying_dog/resources/base'

module FlyingDog
  class IdentitiesResource < ResourceBase
    def self.provider_identity_url(provider, uid)
      "/providers/#{provider}/identities/#{uid}"
    end

    def self.fire_provider_identity_query(provider, uid, options = {})
      url = self.provider_identity_url(provider, uid)
      resp = fire_get(url, options)
      resp
    end

    def self.fire_provider_identity_put(provider, uid, attributes, options = {})
      url = self.provider_identity_url(provider, uid)
      fire_put(url, attributes, options)
    end

    def self.fire_provider_identity_delete(provider, uid, options = {})
      url = self.provider_identity_url(provider, uid)
      fire_delete(url, options)
    end
  end
end
