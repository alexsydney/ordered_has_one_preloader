require 'bundler'
Bundler.setup
Bundler.require

require 'active_record'
require 'database_cleaner'
require 'ordered_has_one_preloader'

ActiveRecord::Base.logger = Logger.new(File.expand_path("../test.log", __FILE__))
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :people do |t|
    t.string :name
  end
  create_table :articles do |t|
    t.string :name
    t.integer :person_id
    t.float :rating
  end
  create_table :tags do |t|
    t.string :name
    t.integer :article_id
  end
end

class Person < ActiveRecord::Base
  has_many :articles, inverse_of: :person
  has_one :latest_article, -> { order(id: :desc) }, class_name: 'Article'
  has_one :least_rated_article, -> { order(:rating).order(:id) }, class_name: 'Article'
  has_one :latest_report, -> { report.order(id: :desc) }, class_name: 'Article'
  has_one :latest_article_with_tag, -> { has_tag.order(id: :desc) }, class_name: 'Article'
  has_one :latest_tag, through: :latest_article_with_tag, source: :tag, class_name: 'Tag'
end

class Article < ActiveRecord::Base
  belongs_to :person, inverse_of: :articles
  has_one :tag, inverse_of: :article
  scope :has_tag, -> { joins(:tag) }
  scope :report, -> { where(name: 'report') }
end

class Tag < ActiveRecord::Base
  belongs_to :article, inverse_of: :tag
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end

