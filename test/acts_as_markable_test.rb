require 'test_helper'

class ActsAsMarkableTest < ActiveSupport::TestCase

  # Config tests

  test "a drink's markable_marks[:favorite] should not be nil" do
    assert_not_nil Drink.__markable_marks[:favorite]
  end

  test "a food's markable_marks[:favorite] should not be nil" do
    assert_not_nil Food.__markable_marks[:favorite]
    assert_not_nil Food.__markable_marks[:hated]
  end

  test "a food's markable_marks[:favorite][:allowed_markers] should be :all" do
    assert_equal :all, Food.__markable_marks[:favorite][:allowed_markers]
  end

  test "a drink's markable_marks[:favorite][:allowed_markers] should be [:admin]" do
    assert_equal [:admin], Drink.__markable_marks[:favorite][:allowed_markers]
  end

  test "a user favorite 2 types of food and 1 drink, favorite_foods should contain both foods, favorite_drinks should contain 1 drink" do
    admin1 = Admin.create :name => 'Admin1'
    food1 = Food.create :name => 'Food1'
    food2 = Food.create :name => 'Food2'
    drink1 = Drink.create :name => 'Drink1'

    admin1.favorite_foods << [food1, food2]
    admin1.favorite_drinks << drink1

    assert_equal [food1, food2], admin1.favorite_foods
    assert_equal [drink1], admin1.favorite_drinks
  end

  # Methods

  test "food.mark_as" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    assert_equal [], f1.users_have_marked_as(:favorite)
    f1.mark_as :favorite, u1
    assert_equal [ u1 ], f1.users_have_marked_as(:favorite)
    assert_equal [ f1 ], u1.favorite_foods
    f2.mark_as :favorite, [u1, u2]
    assert_equal [ u1, u2 ], f2.users_have_marked_as(:favorite)
    assert_equal [ f1, f2 ], u1.favorite_foods
    assert_equal [ f2 ], u2.favorite_foods
  end

  test "food.users_have_marked_as_favorite" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    assert_equal [], f1.users_have_marked_as_favorite
    f1.users_have_marked_as_favorite << u1
    assert_equal [ u1 ], f1.users_have_marked_as_favorite
    assert_equal [ f1 ], u1.favorite_foods
    f2.users_have_marked_as_favorite << [u1, u2]
    assert_equal [ u1, u2 ], f2.users_have_marked_as_favorite
    assert_equal [ f1, f2 ], u1.favorite_foods
    assert_equal [ f2 ], u2.favorite_foods
  end

  test "food.users_have_marked_as" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    assert_equal [], f1.users_have_marked_as(:favorite)
    f1.users_have_marked_as(:favorite) << u1
    assert_equal [ u1 ], f1.users_have_marked_as(:favorite)
    assert_equal [ f1 ], u1.favorite_foods
    f2.users_have_marked_as(:favorite) << [u1, u2]
    assert_equal [ u1, u2 ], f2.users_have_marked_as(:favorite)
    assert_equal [ f1, f2 ], u1.favorite_foods
    assert_equal [ f2 ], u2.favorite_foods
  end

  test "Food.marked_as" do
    u1, u2 = get(User, 2)
    f1, f2, f3 = get(Food, 3)
    assert_equal [], Food.marked_as(:favorite)
    u1.favorite_foods << [ f1, f3 ]
    u2.favorite_foods << f2
    assert_equal [ f1, f2, f3 ], Food.marked_as(:favorite)
    assert_equal [ f1, f3 ], Food.marked_as(:favorite, :by => u1)
    assert_equal [ f2 ], Food.marked_as(:favorite, :by => u2)
  end

  test "Food.marked_as_favorite" do
    u1, u2 = get(User, 2)
    f1, f2, f3 = get(Food, 3)
    assert_equal [], Food.marked_as_favorite
    u1.favorite_foods << [ f1, f3 ]
    u2.favorite_foods << f2
    assert_equal [ f1, f2, f3 ], Food.marked_as_favorite
    assert_equal [ f1, f3 ], Food.marked_as_favorite(:by => u1)
    assert_equal [ f2 ], Food.marked_as_favorite(:by => u2)
  end

  test "food.marked_as?" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)

    assert !f1.marked_as_favorite?

    u1.favorite_foods << [f1]
    u2.favorite_foods << [f2]

    assert f1.marked_as?(:favorite)
    assert f1.marked_as_favorite?
    assert f1.marked_as_favorite?(:by => u1)
    assert !f1.marked_as_favorite?(:by => u2)
  end

  test "admin should have proper methods" do
    admin = Admin.create :name => 'Admin'
    assert_nothing_raised(NoMethodError) {
      admin.favorite_foods
    }
    assert_nothing_raised(NoMethodError) {
      admin.favorite_drinks
    }
  end

  test "a drink marked as favorite with << by user, should be in favorite_drinks list of this user" do
    admin1 = Admin.create :name => 'Admin1'
    drink1 = Drink.create :name => 'Drink1'
    admin1.favorite_drinks << drink1
    assert_equal [drink1], admin1.favorite_drinks
  end

  test "a drink marked as favorite with mark_as by user, should be in favorite_drinks list of this user" do
    admin1 = Admin.create :name => 'Admin1'
    drink1 = Drink.create :name => 'Drink1'
    admin1.set_mark :favorite, drink1
    assert_equal [drink1], admin1.favorite_drinks
  end

  test "user.mark_as_favorite should mark food as favorite" do
    user1 = User.create :name => 'User1'
    food1 = Food.create :name => 'Food1'
    food2 = Food.create :name => 'Food2'
    user1.mark_as_favorite [food1, food2]

    assert_equal [food1, food2], user1.favorite_foods
  end

  test "user.mark_as_favorite should not mark drink as favorite" do
    user1 = User.create :name => 'User1'
    drink1 = Drink.create :name => 'Drink1'

    assert_raise(Markable::NotAllowedMarker) {
      user1.mark_as_favorite drink1
    }
  end

  test "admin.mark_as_favorite" do
    admin1 = Admin.create :name => 'Admin1'
    food1 = Food.create :name => 'Food1'
    drink1 = Drink.create :name => 'Drink1'
    admin1.mark_as_favorite [food1, drink1]
  end

  test "food.remove_mark" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    u1.favorite_foods << [f1, f2]
    u2.favorite_foods << [f1, f2]
    assert_equal [f1, f2], u1.favorite_foods
    assert_equal [f1, f2], u2.favorite_foods
    f1.unmark :favorite, :by => u1
    assert_equal [u2], f1.users_have_marked_as_favorite
    assert_equal [u1, u2], f2.users_have_marked_as_favorite
    f2.unmark :favorite
    assert_equal [u2], f1.users_have_marked_as_favorite
    assert_equal [], f2.users_have_marked_as_favorite
  end
  test "food.users_have_marked_as_favorite.delete" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    u1.favorite_foods << [f1, f2]
    u2.favorite_foods << [f1, f2]
    assert_equal [f1, f2], u1.favorite_foods
    assert_equal [f1, f2], u2.favorite_foods
    f1.users_have_marked_as_favorite.delete(u1)
    f2.users_have_marked_as_favorite.delete(u2)
    assert_equal [u2], f1.users_have_marked_as_favorite
    assert_equal [u1], f2.users_have_marked_as_favorite
  end

  # Errors

  test "markables can't be marked by not allowed markers" do
    marker = User.create :name => 'marker'
    markable = Drink.create :name => 'markable'

    assert_raise(NoMethodError) {
      marker.favorite_drinks
    }
    assert_raise(NoMethodError) {
      markable.users_have_marked_as_favorite
    }
    assert_raise(Markable::NotAllowedMarker) {
      markable.admins_have_marked_as_favorite << marker
    }
    assert_raise(Markable::NotAllowedMarker) {
      markable.mark_as :favorite, marker
    }
  end

  test "markables can be marked by allowed markers" do
    marker = User.create :name => 'marker'
    markable = Food.create :name => 'markable'

    markable.users_have_marked_as_favorite << marker
    assert_equal [ markable ], marker.favorite_foods
    assert_equal [ marker ], markable.users_have_marked_as_favorite
  end
end
