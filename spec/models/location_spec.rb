require "rails_helper"

RSpec.describe Location do
  subject(:instance) { described_class.new(latitude:, longitude:, postal_code:) }

  let(:latitude) { nil }
  let(:longitude) { nil }
  let(:postal_code) { nil }

  it { is_expected.to have_attributes(latitude:, longitude:, postal_code:) }
end
