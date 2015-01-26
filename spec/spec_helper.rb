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
  create_table :titles do |t|
    t.string :name
    t.integer :user_id
    t.integer :priority
  end
  create_table :users do |t|
    t.string :name
  end
end

class User < ActiveRecord::Base
  has_many :titles, inverse_of: :user
  has_one :latest_title, -> { order(id: :desc) }, class_name: 'Title'
  has_one :least_significant_title, -> { order(:priority).order(:id) }, class_name: 'Title'
end

class Title < ActiveRecord::Base
  belongs_to :user, inverse_of: :titles
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

