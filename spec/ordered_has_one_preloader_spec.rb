require 'spec_helper'

describe OrderedHasOnePreloader do
  let!(:user){ User.create(name: 'foo') }
  let!(:titles){ [Title.create(name: 'master', user: user, priority: 1),
                  Title.create(name: 'owner', user: user, priority: 5),
                  Title.create(name: 'rocker', user: user, priority: 3),
                  Title.create(name: 'ruler', user: nil, priority: 0)] }

  it 'works for single order column' do
    users = User.preload(:latest_title).to_a
    expect(ActiveRecord::Base.connection).not_to receive(:select_all)
    expect(users.map(&:latest_title)).to eq titles.values_at(2)
  end

  it 'works for dual order column' do
    users = User.preload(:least_significant_title).to_a
    expect(ActiveRecord::Base.connection).not_to receive(:select_all)
    expect(users.map(&:least_significant_title)).to eq titles.values_at(0)
  end
end
