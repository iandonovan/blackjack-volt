require 'spec_helper'

describe Player do
  it { is_expected.to respond_to(:wins) }
  it { is_expected.to respond_to(:losses) }
  it { is_expected.to respond_to(:cards) }
end
