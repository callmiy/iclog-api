defmodule IclogWeb.Feature.MealDetailTest do
  use Iclog.FeatureCase

  alias Iclog.Observable.Meal
  alias Iclog.Comment

  @meal_text "Mealx"
  @comment_text "Comx"
  @meal_text_regex ~r/.*Comx.*/
  @view_title_regex ~r/.*Details.*/
  @comment_text_regex ~r/.*Comx.*/
  @add_comment_icon_id "detail-meal-add-comment-toggle"
  @add_comment_control_id "meal-add-comment"
  @new_comment_text "Comy"
  @new_comment_text_regex ~r/.*Comy.*/
  @add_comment_submit_icon_id "meal-detail-add-comment-submit"
  @edit_meal_text_id "edit-meal-input"
  @edit_meal_time_id "detail-meal-edit-time"
  @edit_meal_icon_id "detail-meal-show-edit-display"
  @new_meal_text "Mey"
  @edit_meal_add_comment_icon_id "comment-edit-view-helper-reveal-composite-comment-id"
  @edit_meal_comment_id "edit-meal-comment"
  @edit_meal_submit_btn_id "edit-meal-submit-btn"
  @edit_meal_view_title_regex ~r/.*Edit meal.*/
  @comment_display_class "viewing-comment"

  @tag :integration
  # @tag :no_headless
  test "Detail view with comment", _meta do
    %Meal{
      id: id_,
      time: time_
    } = meal = insert(:meal, meal: @meal_text)

    %Comment{inserted_at: inserted_at_} =
      MealCommentFactory.create :comment,
        meal: meal, text: @comment_text

    # When we visit meal detail page
    navigate_to "/#/meals/#{id_}"

    {_time, time_str}= timex_ecto_date_to_local_tz_formatted time_
    time_regex = Regex.compile! ".*#{time_str}.*"

    {_inserted_at, inserted_at_str}= timex_ecto_date_to_local_tz_formatted inserted_at_
    inserted_at_regex = Regex.compile! ".*#{inserted_at_str}.*"

    # The page subtitle is visible
    assert wait_for_condition(
      true,
      fn() -> visible_in_page?(@view_title_regex) end
    )

    # And the meal text is visible
    assert wait_for_condition(
      true,
      fn() -> visible_in_page?(@meal_text_regex) end
    )

    # And meal time is visible in page
    assert visible_in_page?(time_regex)

    # And comment text is visible in page
    assert visible_in_page?(@comment_text_regex)
    # And meal comment time is visible in page
    assert visible_in_page?(inserted_at_regex)

    # When add comment icon is clicked
    click {:id, @add_comment_icon_id}

    # Add comment box is revealed
    add_comment_control = find_element :id, @add_comment_control_id

    # When add comment box is completed
    click add_comment_control
    type_text @new_comment_text, 1

    # And the form submitted
    click {:id, @add_comment_submit_icon_id}

    # Comment added is now visible in page
    assert wait_for_condition(
      true,
      fn() -> visible_in_page?(@new_comment_text_regex) end
    )
  end

  @tag :integration
  # @tag :no_headless
  test "Edit view", _meta do
    %Meal{
      id: id_,
      time: time_
    } = _meal = insert(:meal, meal: @meal_text)

    # When we visit meal detail page
    navigate_to "/#/meals/#{id_}"

    {time, time_str} = timex_ecto_date_to_local_tz_formatted time_

    # And click on edit icon
    click {:id, @edit_meal_icon_id}

    # Meal text is visible
    meal_control = find_element :id, @edit_meal_text_id
    assert wait_for_condition(
      true,
      fn() ->
        attribute_value(meal_control, "value") == @meal_text
      end
    )

    # And meal time is visible in page
    time_control = find_element :id, @edit_meal_time_id
    assert attribute_value(time_control, "value") == time_str

    # And view title is visible in page
    assert visible_in_page?(@edit_meal_view_title_regex)

    # And no comment is visible in page
    refute element?(:class, @comment_display_class)

    # When meal text box is edited
    fill_field meal_control, ""
    fill_field meal_control, @new_meal_text

    # And time field is edited
    new_time = Timex.shift time, days: 1
    click time_control
    datetime_picker_select_date new_time.day, meal_control

    # And comment field is edited
    click {:id, @edit_meal_add_comment_icon_id}
    fill_field {:id, @edit_meal_comment_id}, @new_comment_text

    # When form is submitted
    click {:id, @edit_meal_submit_btn_id}

    # A message appears showing update was successful
    assert wait_for_condition(
      true,
      fn() ->
        visible_in_page?(@success_click_to_dismiss_regex)
      end
    )

    # And comment is visible in page
    assert element?(:class, @comment_display_class)

    # And meal is updated in the database
    meal = Meal.get!(id_)

    assert meal.meal == @new_meal_text

    {_, time_str_db} = timex_ecto_date_to_local_tz_formatted meal.time
    {_, time_str_new} = timex_ecto_date_to_local_tz_formatted new_time
    assert time_str_db == time_str_new
  end
end