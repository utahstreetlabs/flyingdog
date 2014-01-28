require 'ladon/model'
require 'flying_dog/resources/identities_resource'
require 'flying_dog/jobs'

module FlyingDog
  class Identity < Ladon::Model
    attr_reader :adapter, :sync_class

    def initialize(provider, uid, attrs)
      super(attrs && attrs.merge(provider: provider, uid: uid))
      @adapter = IdentityAdapter.for_provider(provider)
      changed_attributes.clear
    end

    def update!(attrs)
      self.attributes = attrs
      self.save!
    end

    def update_from_oauth!(oauth)
      update!(@adapter.attrs_from_oauth(user_id, oauth))
    end

    def save!
      IdentitiesResource.fire_provider_identity_put(provider, uid, attributes, raise_on_error: true)
      @sync_class = @adapter.sync_class(self)
      changed_attributes.clear
      @persisted = true
    end

    def delete!
      IdentitiesResource.fire_provider_identity_delete(provider, uid, raise_on_error: true)
      @persisted = false
    end

    def valid_user_association?
      user_id && user_id > 0
    end

    def self.create!(provider, uid, attrs)
      instance = new(provider, uid, attrs)
      instance.save!
      instance
    end

    def self.create_from_oauth!(user_id, provider, oauth)
      attrs = IdentityAdapter.for_provider(provider).attrs_from_oauth(user_id, oauth)
      self.create!(provider, oauth.uid, IdentityAdapter.for_provider(provider).attrs_from_oauth(user_id, oauth))
    end

    def self.find_by_provider_id(provider, uid, options = {})
      attrs = IdentitiesResource.fire_provider_identity_query(provider, uid, options)
      attrs && new(provider, uid, attrs.merge(persisted: true))
    end

    def self.find_by_provider_id!(provider, uid, options = {})
      find_by_provider_id(provider, uid, options.merge(raise_on_error: true))
    end
  end

  class IdentityAdapter
    def attrs_from_oauth(user_id, oauth)
      { user_id: user_id, token: oauth.credentials.token, scope: oauth.scope, secret: oauth.credentials.secret }
    end

    def sync_class(identity)
      nil
    end

    def self.for_provider(provider)
      (provider == :facebook ? FacebookIdentityAdapter : self).new
    end
  end

  class FacebookIdentityAdapter
    def attrs_from_oauth(user_id, oauth)
      { user_id: user_id, tmp_token: oauth.credentials.token, tmp_token_expires_at: oauth.credentials.expires_at,
        scope: oauth.scope }
    end

    def sync_class(identity)
      if identity.tmp_token_changed? || identity.tmp_token_expires_at_changed?
        FlyingDog::Jobs::ExchangeFacebookToken
      elsif identity.code_changed?
        FlyingDog::Jobs::ExchangeFacebookCode
      end
    end
  end
end
