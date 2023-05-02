# frozen_string_literal: true

RSpec.describe Sisjwt::Rails::Authenticator do
  subject(:authenticator) { described_class.new(allowed_aud, allowed_iss) }

  let(:allowed_aud) { 'test-aud' }
  let(:allowed_iss) { 'test-iss' }

  describe '#verify_or_yield_errors' do
    subject :result do
      proc { |b| authenticator.verify_or_yield_errors(token, &b) }
    end

    let(:token) { sis_jwt.encode(data: :test) }
    let(:sis_jwt) { Sisjwt::SisJwt.new(sis_opts) }
    let(:sis_opts) do
      Sisjwt::SisJwtOptions.defaults(mode: :sign).tap do |opts|
        opts.aud = signing_aud
        opts.iss = signing_iss
      end
    end

    context 'with a valid token' do
      let(:signing_aud) { allowed_aud }
      let(:signing_iss) { allowed_iss }

      it 'does not yield any errors' do
        expect(&result).not_to yield_control
      end
    end

    # TODO: debugging
    # context 'with an invalid token, signed with the wrong aud' do
    #   let(:signing_aud) { 'something else' }
    #   let(:signing_iss) { allowed_iss }

    #   it 'does not yield any errors' do
    #     expect(&result).to yield_with_args include(errors: ['Aud not on the approved list'])
    #   end
    # end

    # context 'with an invalid token, signed with the wrong iss' do
    #   let(:signing_aud) { allowed_aud }
    #   let(:signing_iss) { 'something else' }

    #   it 'does not yield any errors' do
    #     expect(&result).to yield_with_args include(errors: ['Iss not on the approved list'])
    #   end
    # end
  end

  describe '#verify' do
    subject(:result) { authenticator.verify(token) }

    let(:token) { 'test' }

    it { expect(result).to be_a Sisjwt::VerificationResult }

    it 'includes the specified aud and iss' do
      expect(result.allowed_aud).to include allowed_aud
      expect(result.allowed_iss).to include allowed_iss
    end
  end

  describe '#options' do
    subject(:options) { authenticator.options }

    it { is_expected.to be_a Sisjwt::SisJwtOptions }
    it { expect(options.mode).to be :verify }

    it 'has the same iss' do
      expect(options.iss).to be allowed_iss
    end
  end
end
