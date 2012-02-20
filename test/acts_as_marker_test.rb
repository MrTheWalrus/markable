require 'test_helper'

class ActsAsMarkerTest < ActiveSupport::TestCase
  test "a_users_marker_name_should_be_user" do
    assert_equal :user, User.marker_name
  end

  # markers
  test "user.favorite_foods" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    assert_equal [], u1.favorite_foods
    u1.favorite_foods << f1
    assert_equal [ f1 ], u1.favorite_foods
    u2.favorite_foods << [f1, f2]
    assert_equal [ f1, f2 ], u2.favorite_foods
  end

  test "user.foods_marked_as" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    assert_equal [], u1.foods_marked_as(:favorite)
    u1.foods_marked_as(:favorite) << f1
    assert_equal [ f1 ], u1.foods_marked_as(:favorite)
    u2.foods_marked_as(:favorite) << [f1, f2]
    assert_equal [ f1, f2 ], u2.foods_marked_as(:favorite)
  end

  test "user.foods_marked_as_favorite" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    assert_equal [], u1.foods_marked_as_favorite
    u1.foods_marked_as_favorite << f1
    assert_equal [ f1 ], u1.foods_marked_as_favorite
    u2.foods_marked_as_favorite << [f1, f2]
    assert_equal [ f1, f2 ], u2.foods_marked_as_favorite
  end

  test "user.set_mark_to" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    assert_equal [], u1.favorite_foods
    u1.set_mark_to :favorite, f1
    assert_equal [ f1 ], u1.favorite_foods
    u2.set_mark_to :favorite, [f1, f2]
    assert_equal [ f1, f2 ], u2.favorite_foods
  end

  # markables
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

#removals
#user1.remove_mark_from :favorite, food1
#user1.favorite_foods.delete food1
#food1.remove_mark :favorite
#food1.remove_mark :favorite, :by => user1
#food1.users_have_marked_as_favorite.delete user1
  test "user.remove_mark_from" do
    u1 = get(User)
    f1, f2 = get(Food, 2)
    u1.favorite_foods << [f1, f2]
    assert_equal [f1, f2], u1.favorite_foods
    u1.remove_mark_from :favorite, f1
    assert_equal [f2], u1.favorite_foods
  end
  test "user.favorite_foods.delete" do
    u1 = get(User)
    f1, f2 = get(Food, 2)
    u1.favorite_foods << [f1, f2]
    assert_equal [f1, f2], u1.favorite_foods
    u1.favorite_foods.delete f1
    assert_equal [f2], u1.favorite_foods
  end
  test "food.remove_mark" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    u1.favorite_foods << [f1, f2]
    u2.favorite_foods << [f1, f2]
    assert_equal [f1, f2], u1.favorite_foods
    assert_equal [f1, f2], u2.favorite_foods
    f1.remove_mark :favorite, :by => u1
    assert_equal [u2], f1.users_have_marked_as_favorite
    assert_equal [u1, u2], f2.users_have_marked_as_favorite
    f2.remove_mark :favorite
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

  ####
  test "errors in mark removal" do
    u1, u2 = get(User, 2)
    f1, f2 = get(Food, 2)
    u1.favorite_foods << [f1, f2]
    u2.favorite_foods << [f1, f2]
    assert_equal [f1, f2], u1.favorite_foods
    assert_equal [f1, f2], u2.favorite_foods

    assert_raise(Markable::WrongMarkableType) {
      f1.users_have_marked_as_favorite.delete(f2)
    }
    assert_raise(Markable::WrongMarkableType) {
      f1.users_have_marked_as_favorite.delete('STRING')
    }
    assert_raise(NoMethodError) {
      u1.users_have_marked_as_favorite.delete(u2)
    }

    assert_raise(Markable::WrongMarkableType) {
      f1.remove_mark :favorite, :by => f2
    }
    assert_raise(Markable::WrongMarkableType) {
      f1.remove_mark :favorite, :by => 'STRING'
    }
    assert_raise(Markable::WrongMarkableType, NoMethodError) {
      u1.remove_mark :favorite, :by => f1
    }

    assert_raise(Markable::WrongMarkableType) {
      u1.favorite_foods.delete u2
    }
    assert_raise(Markable::WrongMarkableType) {
      u1.favorite_foods.delete 'STRING'
    }
    assert_raise(NoMethodError) {
      f1.favorite_foods.delete f2
    }

  end

  def get(model, n = 1)
    result = []
    n.times do
      result.push model.create
    end
    return result.count > 1 ? result : result[0]
  end
end
