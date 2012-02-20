require 'test_helper'

class MarkableTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Markable
  end

  test "a drink's markable_as[:favorite] should not be nil" do
    assert_not_nil Drink.markable_as[:favorite]
  end

  test "a food's markable_as[:favorite] should not be nil" do
    assert_not_nil Food.markable_as[:favorite]
  end

  test "a food's markable_as[:favorite][:allowed_markers] should be :all" do
    assert_equal :all, Food.markable_as[:favorite][:allowed_markers]
  end

  test "a drink's markable_as[:favorite][:allowed_markers] should be [:admin]" do
    assert_equal [:admin], Drink.markable_as[:favorite][:allowed_markers]
  end

  test "user should have proper methods" do
    user = User.create :name => 'User'
    assert_raise(NoMethodError) {
      user.favorite_drinks
    }
    assert_nothing_raised(NoMethodError) {
      user.favorite_foods
    }

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
    admin1.set_mark_to :favorite, drink1
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

    assert_raise(Markable::WrongMarkableType) {
      user1.mark_as_favorite drink1
    }
  end

  test "admin.mark_as_favorite" do
    admin1 = Admin.create :name => 'Admin1'
    food1 = Food.create :name => 'Food1'
    drink1 = Drink.create :name => 'Drink1'
    admin1.mark_as_favorite [food1, drink1]
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

  test "wrong markable type should raise exception" do
    admin1 = Admin.create :name => 'Admin1'
    food1 = Food.create :name => 'Food1'
    food2 = Food.create :name => 'Food2'
    drink1 = Drink.create :name => 'Drink1'
    assert_raise(Markable::WrongMarkableType) {
      admin1.favorite_foods << [food1, drink1]
    }
    assert_raise(Markable::WrongMarkableType) {
      admin1.favorite_foods << [drink1, food1]
    }
    assert_raise(Markable::WrongMarkableType) {
      admin1.favorite_foods << [food1, drink1, food2]
    }
    assert_nothing_raised(Markable::WrongMarkableType) {
      admin1.favorite_foods << [food1]
    }
  end

  test "collection from food side" do
    admin1 = Admin.create :name => 'Admin1'
    admin2 = Admin.create :name => 'Admin2'
    food1 = Food.create :name => 'Food1'

    admin1.favorite_foods << food1
    admin2.favorite_foods << food1

    assert_equal [admin1, admin2], food1.admins_have_marked_as_favorite
  end

  test "have_marker" do
    admin1 = Admin.create :name => 'Admin1'
    admin2 = Admin.create :name => 'Admin2'
    admin3 = Admin.create :name => 'Admin3'
    drink = Drink.create :name => 'Drink'

    admin1.favorite_drinks << drink
    assert_equal [admin1], drink.have_marked_as_by(:favorite, Admin)
    drink.have_marked_as_by(:favorite, Admin) << admin2
    assert_equal [admin1, admin2], drink.have_marked_as_by(:favorite, Admin)

  end


  # marking process

  test "markers can mark allowed markables" do
    marker = User.create :name => 'marker'
    markable = Food.create :name => 'markable'

    marker.favorite_foods << markable
    assert_equal [ markable ], marker.favorite_foods
    assert_equal [ marker ], markable.users_have_marked_as_favorite
  end

  test "markers can't mark not allowed markables" do
    marker = User.create :name => 'marker'
    markable = Drink.create :name => 'markable'

    assert_raise(NoMethodError) {
      marker.favorite_drinks
    }
    assert_raise(NoMethodError) {
      markable.users_have_marked_as_favorite
    }
    assert_raise(Markable::WrongMarkableType) {
      marker.favorite_foods << markable
    }
    assert_raise(Markable::WrongMarkableType) {
      marker.set_mark_to :favorite, markable
    }
  end

  test "markables can be marked by allowed markers" do
    marker = User.create :name => 'marker'
    markable = Food.create :name => 'markable'

    markable.users_have_marked_as_favorite << marker
    assert_equal [ markable ], marker.favorite_foods
    assert_equal [ marker ], markable.users_have_marked_as_favorite
  end

  test "markables can't be marked by not allowed markers" do
    marker = User.create :name => 'marker'
    markable = Drink.create :name => 'markable'

    assert_raise(NoMethodError) {
      marker.favorite_drinks
    }
    assert_raise(NoMethodError) {
      markable.users_have_marked_as_favorite
    }
    assert_raise(Markable::WrongMarkableType) {
      markable.admins_have_marked_as_favorite << marker
    }
    assert_raise(Markable::WrongMarkableType) {
      markable.mark_as :favorite, marker
    }
  end

  test "marker can't mark not markable" do
    marker1 = User.create :name => 'marker'
    marker2 = User.create :name => 'marker'

    assert_raise(Markable::WrongMarkableType) {
      marker1.set_mark_to :favorite, marker2
    }
    assert_raise(Markable::WrongMarkableType) {
      marker1.set_mark_to :favorite, 'STRING'
    }
    assert_raise(Markable::WrongMarkableType) {
      marker1.favorite_foods << marker2
    }
    assert_raise(Markable::WrongMarkableType) {
      marker1.favorite_foods << 'STRING'
    }
  end

end
