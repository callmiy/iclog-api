defmodule IclogWeb.Feature.MealNewTest do
  use Iclog.FeatureCase

  alias Iclog.Observable.Meal

  @navigate_to "/#/meals/new"
  @submit_btn_name "new-meal-submit-btn"
  @meal_text "Meal1"
  @meal_control_error_text "Meal must be at least 3 characters."
  @meal_control_error_id "new-meal-input-error-id"
  @meal_control_id "new-meal-input"
  @page_title_meal "Meal"
  @time_control_id "new-meal-time"
  @page_title_class "page-title"
  @now Timex.now()

  @tag :integration
  # @tag :no_headless
  test "Create a meal without comment", _meta do
    navigate_to @navigate_to
    assert visible_text({:class, @page_title_class}) == @page_title_meal
    :timer.sleep 80

    # Meal text input is completed.
    meal_control = find_element(:id, @meal_control_id)
    control_validate_string_lenght(%{
      field: meal_control,
      invalid_text: "so",
      string_len: 3,
      error_id: @meal_control_error_id,
      valid_text: @meal_text,
      error_text: @meal_control_error_text
    })

    # Time input is completed.
    time = Timex.shift @now, days: 1
    click {:id, @time_control_id}
    datetime_picker_select_date time.day, meal_control

    # Submit button is clicked
    submit_btn = find_element(:name, @submit_btn_name)
    assert element_enabled?(submit_btn)
    click submit_btn

    :timer.sleep 100

    # Meal is created
    assert wait_for_condition(
      true,
      fn() ->
        case Meal.list() do
          [] ->
            false
          [%Meal{meal: meal}] ->
            meal == @meal_text
        end
      end
    )

    assert visible_in_page?(@success_msg_regex)
  end
end