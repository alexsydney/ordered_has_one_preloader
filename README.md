# OrderedHasOnePreloader

Handles preloading of ordered `has_one` association.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ordered_has_one_preloader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ordered_has_one_preloader

## Usage

Just add `preload` clause to your AR query and everything will work fine.

```ruby
class User < ActiveRecord::Base
  has_many :titles, inverse_of: :user
  has_one :latest_title, -> { order(id: :desc) }, class_name: 'Title'
end

class Title < ActiveRecord::Base
  belongs_to :user, inverse_of: :titles
end

@users = User.preload(:latest_title).all
# -> SELECT "users".* FROM "users"
# -> SELECT "titles".* FROM "titles" INNER JOIN (
#      SELECT (
#        SELECT  id FROM "titles"
#        WHERE "users"."id" = "titles"."user_id"
#        ORDER BY "titles"."id" DESC LIMIT 1
#      ) id
#      FROM "users" WHERE "users"."id" = 1
#    ) users_subquery ON "titles"."id" = users_subquery."id"
#    WHERE "titles"."user_id" IN (1)

@users.first.latest_title # no extra query is issued
```

## Contributing

1. Fork it ( https://github.com/mshibuya/ordered_has_one_preloader/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
