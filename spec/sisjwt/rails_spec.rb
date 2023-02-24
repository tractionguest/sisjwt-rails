# frozen_string_literal: true

RSpec.describe Sisjwt::Rails do
  describe '.configuration' do
    subject(:configuration) { described_class.configuration }

    it { is_expected.to be_a Hash }

    it 'automatically creates new entries' do
      expect(configuration['new key']).to be_a Hash
    end
  end
end
