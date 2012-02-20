# Markable

Markable allows you to easily create a marking system in your rails application.

##Installation

Add to your Gemfile

```
gem 'markable'
```

Run

```
bundle install
rails generate markable:migration
rake db:migrate
```

## Methods
``` ruby
class User < ActiveRecord::Base
  acts_as_marker
end
class Food < ActiveRecord::Base
  markable :as => :favorite
end
```

``` ruby
# Getters

user.favorite_foods # => [food1, food2, …]
user.foods_marked_as :favorite # => [food1, food2, …]
user.foods_marked_as_favorite # => [food1, food2, …]

food.users_have_marked_as :favorite # => [user1, user2, …]
food.users_have_marked_as_favorite # => [user1, user2, …]

Food.marked_as :favorite # => [food1, food2, …]
Food.marked_as :favorite, :by => user1 # => [food1, food2, …]
Food.marked_as_favorite # => [food1, food2, …]
Food.marked_as_favorite :by => user1 # => [food1, food2, …]

# Setters
user.favorite_foods << [food1, food2]
user.foods_marked_as(:favorite) << [food1, food2]
user.foods_marked_as_favorite << [food1, food2]
user.set_mark_to :favorite, [food1, food2]

food.users_have_marked_as(:favorite) << [user1, user2]
food.users_have_marked_as_favorite << [user1, user2]
food.mark_as :favorite, [user1, user2]

```

##Usage examples

### Favorites
``` ruby
class User < ActiveRecord::Base
  acts_as_marker
end
class Food < ActiveRecord::Base
  markable :as => :favorite
end
class Drink < ActiveRecord::Base
  markable :as => :favorite
end

jonh = User.find_by_name 'John'
carl = User.find_by_name 'Carl'

pizza = Food.find_by_name 'Pizza'

cake = Food.find_by_name 'Cake'
cola = Drink.find_by_name 'Cola'


jonh.mark_as_favorite [ pizza, cola ]
john.favorite_foods # => [ pizza ]
john.favorite_drinks # => [ cola ]

john.favorite_foods << cake
john.favorite_foods # => [ pizza, cake ]

john.favorite_foods.delete pizza
john.favorite_foods # => [ cake ]

carl.set_mark_to :favorite, pizza

pizza.users_have_marked_as_favorite # => [ john, carl ]
Food.marked_as :favorite # => [ pizza, cake ]
Food.marked_as :favorite, :by => carl # => [ pizza ]
```
### Friends
``` ruby
class User < ActiveRecord::Base
  acts_as_marker
  markable :as => :friendly, :by => :user
end

john = User.find_by_name 'John'
carl = User.find_by_name 'Carl'

john.friendly_users << carl
carl.friendly_users << john
```
### Followers
``` ruby
class User < ActiveRecord::Base
  acts_as_marker
  markable :as => :following, :by => :user
end

john = User.find_by_name 'John'
carl = User.find_by_name 'Carl'

carl.mark_as :following, john
john.following_users # => [ carl ]
```
### Restricted access to markables
``` ruby
class Boy < ActiveRecord::Base
  acts_as_marker
end
class Girl < ActiveRecord::Base
  acts_as_marker
end

class Car < ActiveRecord::Base
  markable :as => :driving, :by => :boy
end
class Dress < ActiveRecord::Base
  markable :as => :wearing, :by => :girl
end

john = Boy.find_by_name 'John'
sally = Girl.find_by_name 'Sally'

ferrari = Car.find_by_name 'Ferrari'
red_dress = Dress.find_by_name 'Red Dress'

john.driving_cars << ferrari # ok
sally.wearing_dresses << red_dress # ok

john.driving_cars << red_dress # error
sally.wearing_dresses << ferrari # error
john.wearing_dresses # error
sally.set_mark_to :driving, ferrari # error
```

## License

The MIT License

Copyright (c) 2012 Alex Chrome

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

