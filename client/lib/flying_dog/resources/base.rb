require 'ladon/resource/base'

module FlyingDog
  class ResourceBase < Ladon::Resource::Base
    self.base_url = 'http://127.0.0.1:4070'

    def self.base_url
      self == ResourceBase ? super : ResourceBase.base_url
    end
  end
end
