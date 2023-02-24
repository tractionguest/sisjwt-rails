# frozen_string_literal: true

RSpec.describe Sisjwt::Rails::RequestToken do
  let(:service) { described_class.new(request) }
  let(:request) { Struct.new(:headers).new(headers) }

  describe '#token!' do
    subject(:token) { service.token! }

    context 'when the Authorization header is a bearer token' do
      let(:headers) { { 'Authorization' => 'Bearer some-token' } }

      it { is_expected.to eq 'some-token' }
    end

    context 'when the bearer token contains spaces' do
      let(:headers) { { 'Authorization' => 'Bearer token with spaces' } }

      it { expect { token }.to raise_error Sisjwt::Rails::TokenMissingError }
    end

    context 'when the request has no Authorization header' do
      let(:headers) { {} }

      it { expect { token }.to raise_error Sisjwt::Rails::TokenMissingError }
    end

    context 'when the Authorization header is not a bearer token' do
      let(:headers) { { 'Authorization' => 'something else' } }

      it { expect { token }.to raise_error Sisjwt::Rails::TokenMissingError }
    end
  end

  describe '#token' do
    subject(:token) { service.token }

    context 'when the Authorization header is a bearer token' do
      let(:headers) { { 'Authorization' => 'Bearer some-token' } }

      it { is_expected.to eq 'some-token' }
    end

    context 'when the bearer token contains spaces' do
      let(:headers) { { 'Authorization' => 'Bearer token with spaces' } }

      it { is_expected.to be_nil }
    end

    context 'when the request has no Authorization header' do
      let(:headers) { {} }

      it { is_expected.to be_nil }
    end

    context 'when the Authorization header is not a bearer token' do
      let(:headers) { { 'Authorization' => 'something else' } }

      it { is_expected.to be_nil }
    end
  end
end
