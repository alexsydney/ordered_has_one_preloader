require 'spec_helper'

describe OrderedHasOnePreloader do
  let!(:person){ Person.create(name: 'somebody') }
  let!(:articles){ [Article.create(name: 'news', person: person, rating: 2.0),
                  Article.create(name: 'report', person: person, rating: 5.0),
                  Article.create(name: 'poem', person: person, rating: 1.0),
                  Article.create(name: 'diary', person: person, rating: 3.0),
                  Article.create(name: 'memo', person: nil, rating: 2.5)] }
  let!(:tags){ [Tag.create(name: 'worthless', article: articles[1]),
                Tag.create(name: 'rocks', article: articles[2])] }

  it 'works for single order column' do
    people = Person.preload(:latest_article).to_a
    expect(ActiveRecord::Base.connection).not_to receive(:select_all)
    expect(people.map(&:latest_article)).to eq articles.values_at(3)
  end

  it 'works for double order column' do
    people = Person.preload(:least_rated_article).to_a
    expect(ActiveRecord::Base.connection).not_to receive(:select_all)
    expect(people.map(&:least_rated_article)).to eq articles.values_at(2)
  end

  it "works with where condition which uses bind_values" do
    people = Person.preload(:latest_report).to_a
    expect(ActiveRecord::Base.connection).not_to receive(:select_all)
    expect(people.map(&:latest_report)).to eq articles.values_at(1)
  end

  it "works with through association" do
    people = Person.preload(:latest_tag).to_a
    expect(ActiveRecord::Base.connection).not_to receive(:select_all)
    expect(people.map(&:latest_tag)).to eq tags.values_at(1)
  end
end
