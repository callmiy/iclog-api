defmodule IclogWeb.Feature.MealListTest do
  @moduledoc false

  use Iclog.FeatureCase

  alias Iclog.Observable.Meal

  @pagination_regex ~r/.*Page 1 of 2.*/
  @meal_text "The very first meal"
  @navigate_to "/#/meals"
  @detail_link_class "meal-list-to-meal-detail-link"
  @next_page_arrow_id "pagination-next-page-arrow"

  @tag :integration
  # @tag :no_headless
  test "List meals", _meta do
    %Meal{
      id: id_first,
      meal: meal_text_first,
      time: time_first_
    } = insert(:meal, meal: @meal_text)

    ten_meals = insert_list(10, :meal)

    %Meal{
      id: id_last,
      meal: meal_text_last,
      time: time_last_,
    } = List.last ten_meals

    navigate_to @navigate_to

    {time_first, _} = timex_ecto_date_to_local_tz(time_first_)
    _time_first_regex = Timex.format!(time_first, list_date_date_regex())
    meal_text_first_regex = ".*#{meal_text_first}.*"

    {time_last, _} = timex_ecto_date_to_local_tz(time_last_)
    time_last_regex = Timex.format!(time_last, list_date_date_regex())
    meal_text_last_regex = ".*#{meal_text_last}.*"

     # Last meal_text to be inserted is visible in page
     assert wait_for_condition(
      true,
      fn() ->
        visible_in_page?(Regex.compile! meal_text_last_regex)
      end
    )

    # But first meal_text is not visible
    refute visible_in_page?(Regex.compile! meal_text_first_regex)

    # Last meal datetime is visible on page
    assert visible_in_page?(Regex.compile! time_last_regex, "s")

    # link to go to detail page of last meal is present in page
    assert element?(:css, "a[href$='/meals/#{id_last}']")

    # But link to go to detail page of first meal is not present in page
    refute element?(:css, "a[href$='/meals/#{id_first}']")

    # There are a total of 10 such links
    assert length(
      find_all_elements(:class, @detail_link_class)
    ) == 10

    # text indicating pagination is visible in page
    assert visible_in_page?(@pagination_regex)

    next_page_arrow = find_element :id, @next_page_arrow_id
    click next_page_arrow

    # link to go to detail page of last meal is no longer present in page
    refute wait_for_condition(
      false,
      fn() -> element?(:css, "a[href$='/meals/#{id_last}']") end
    )

    # But link to go to detail page of first meal is now present in page
    assert element?(:css, "a[href$='/meals/#{id_first}']")
  end
end