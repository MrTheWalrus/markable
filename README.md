# Markable

Do your users want to add food, drinks, books, movies, and many
other stuff to favorites?

_— How should I name this table — users_foods or foods_users?_<br/>
_— Damn, I forget to add ```:id => false``` to migration again!_<br/>
_— Holy sh*t! I have to create a lot of tables for this relations!_

Nope, you don't have to create relations or think about migrations — **markable** will handle this.

Should your users be able to add each other to friends? Or do you want to
make a twitter-like followers system?

_— Oh… Self-relation again…_

Nope, **markable** can handle it too!



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

## Usage

At first you should define markers — these are models which will mark
other models.

If User can mark Food as favorite, then User — is a marker.

``` ruby
class User < ActiveRecord::Base
  acts_as_marker
end
```

Then you should define markables

``` ruby
class Food < ActiveRecord::Base
  markable_as :favorite
end
```

Thats it! Now you can mark pizza as a favorite food of your user

``` ruby
user.set_mark :favorite, pizza
# or
user.mark_as_favorite pizza
# or
user.favorite_foods << pizza
```

_— Also I hate broccoli!_

As you wish! Just a little change to your Food model

``` ruby
class Food < ActiveRecord::Base
  markable_as [ :hated, :favorite ]
end
```

and The World will know, what kind of food do you hate.

``` ruby
user.hated_foods << broccoli
```

You can easily get list of all food marked as favorite by your user

``` ruby
user.foods_marked_as :favorite
# or
user.foods_marked_as_favorite
# or
user.favorite_foods
```

Also you can get a list of all users, who loves pizza too!

``` ruby
pizza.users_have_marked_as :favorite
# or
pizza.users_have_marked_as_favorite
```

And all food loved by users

``` ruby
Food.marked_as :favorite
# or
Food.marked_as_favorite
```

_— Hmm… What kind of food my friends likes?_

``` ruby
Food.marked_as_favorite :by => [ user1, user2, user3 ]
```

_— Hey! I have found a users who loves pizza too — I want to be friends with them!_

No problem! Just make User markable as friendly!

``` ruby
class User < ActiveRecord::Base
  acts_as_marker
  markable_as :friendly, :by => :user
end
```

And now you can add all pizza-lovers to your friends

``` ruby
user.friendly_users << pizza.users_have_marked_as_favorite
```

Piece of cake!

## All Methods
``` ruby
class User < ActiveRecord::Base
  acts_as_marker
end
class Food < ActiveRecord::Base
  markable_as :favorite
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
user.mark_as_favorite [food1, food2]
user.set_mark :favorite, [food1, food2]

food.users_have_marked_as(:favorite) << [user1, user2]
food.users_have_marked_as_favorite << [user1, user2]
food.mark_as :favorite, [user1, user2]

# Removals
food.unmark :favorite
food.unmark :favorite, :by => user1
food.users_have_marked_as(:favorite).delete [food1, food2]
food.users_have_marked_as_favorite.delete [food1, food2]
user.remove_mark :favorite, [food1, food2]
user.favorite_foods.delete [food1, food2]

# Check
food.marked_as? :favorite
food.marked_as_favorite?
```

##Usage examples

You can find some usage examples at wiki page: [Usage examples](https://github.com/chrome/markable/wiki/Usage-examples)

## License

The MIT License

Copyright (c) 2012 Alex Chrome

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

