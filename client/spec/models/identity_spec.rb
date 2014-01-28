require 'spec_helper'
require 'flying_dog/models/identity'
require 'ostruct'

describe FlyingDog::Identity do
  let(:uid) { '1234567890' }
  let(:user_id) { 1 }
  let(:token) { 'cafebebe' }
  let(:expires_at) { 1349386037 }
  let(:new_token) { 'deadbeef' }
  let(:new_expires_at) { 1349386050 }
  let(:scope) { 'email' }
  let(:oauth) do
    OpenStruct.new(credentials: OpenStruct.new(token: new_token, expires_at: new_expires_at), scope: scope)
  end
  # let(:attrs) { { user_id: user_id, token: token, scope: scope, provider: provider, uid: uid } }
  let(:identity) { FlyingDog::Identity.new(provider, uid, {user_id: user_id, token: token, expires_at: expires_at}) }

  describe '#initialize' do
    subject { identity }
    context 'facebook' do
      let(:provider) { :facebook }
      its(:adapter) { should be_an_instance_of(FlyingDog::FacebookIdentityAdapter) }
    end

    context 'tumblr' do
      let(:provider) { :tumblr }
      its(:adapter) { should be_an_instance_of(FlyingDog::IdentityAdapter) }
    end
  end

  describe '#update_from_oauth!' do
    before do
      FlyingDog::IdentitiesResource.expects(:fire_provider_identity_put).
        with(provider, uid, is_a(Hash), {raise_on_error: true})
    end
    subject do
      identity.update_from_oauth!(oauth)
      identity
    end

    context 'for facebook' do
      let(:provider) { :facebook }

      context 'with a new tmp_token' do
        its(:tmp_token) { should == new_token }
        its(:tmp_token_expires_at) { should == new_expires_at }
        its(:scope) { should == scope }
      end

      context 'with the same tmp_token but new expiry' do
        before do
          oauth.credentials.token = token
        end
        its(:tmp_token) { should == token }
        its(:tmp_token_expires_at) { should == new_expires_at }
      end
    end

    context 'for tumblr' do
      let(:provider) { :tumblr }
      its(:token) { should == new_token }
      its(:scope) { should == scope }
    end
  end

  context 'finding identity by provider and id' do
    let(:provider) { :facebook }
    let(:uid) { '123454321' }

    describe '::find_by_provider_id' do
      it 'ignores service errors' do
        FlyingDog::IdentitiesResource.expects(:fire_provider_identity_query).with(provider, uid, {}).returns(nil)
        expect(FlyingDog::Identity.find_by_provider_id(provider, uid)).to be_nil
      end
    end

    describe '::find_by_provider_id!' do
      let(:exception) { Exception.new }

      it 'raises errors' do
        FlyingDog::IdentitiesResource.expects(:fire_provider_identity_query).
          with(provider, uid, raise_on_error: true).
          raises(exception)
        expect { FlyingDog::Identity.find_by_provider_id!(provider, uid) }.to raise_exception(exception)
      end
    end
  end
end
