defmodule IclogWeb.Feature.SleepDetailTest do
  use Iclog.FeatureCase

  alias Iclog.Observable.Sleep
  alias Iclog.Comment

  @comment_text "Comx"
  @comment_text_regex ~r/.*Comx.*/
  @view_title_regex ~r/.*Details.*/
  @add_comment_icon_id "detail-sleep-add-comment-toggle"
  @add_comment_control_id "sleep-add-comment"
  @new_comment_text "Coy"
  @new_comment_text_regex ~r/.*Coy.*/
  @add_comment_submit_icon_id "sleep-detail-add-comment-submit"
  @edit_sleep_icon_id "detail-sleep-show-edit-display"
  @edit_sleep_start_id "detail-sleep-edit-start"
  @edit_sleep_end_id "detail-sleep-edit-end"
  @edit_sleep_view_title_regex ~r/.*Edit.*/
  @comment_display_class "viewing-comment"
  @edit_sleep_add_comment_icon_id "comment-edit-view-helper-reveal-composite-comment-id"
  @edit_sleep_comment_id "detail-sleep-comment"
  @card_title_class "card-title"
  @edit_sleep_submit_btn_id "edit-sleep-submit-btn"

  @tag :integration
  # @tag :no_headless
  test "Detail view with comment", _meta do
    %Sleep{
      id: id_,
      start: start_,
      end: end_,
    } = sleep = insert(:sleep)

    %Comment{inserted_at: inserted_at_} =
      SleepCommentFactory.create :comment,
        sleep: sleep, text: @comment_text

    # When we visit detail page
    navigate_to "/#/sleeps/#{id_}"

    {start_time, start_str} = timex_ecto_date_to_local_tz_formatted start_
    start_regex = Regex.compile! ".*#{start_str}.*"

    {end_time, end_str} = timex_ecto_date_to_local_tz_formatted end_
    end_regex = Regex.compile! ".*#{end_str}.*"

    duration = Timex.diff end_time, start_time, :hours
    duration_regex = Regex.compile! ".*#{duration} hrs.*"

    {_, inserted_at_str} = timex_ecto_date_to_local_tz_formatted inserted_at_
    inserted_at_regex = Regex.compile! ".*#{inserted_at_str}.*"

    # The page subtitle is visible
    assert wait_for_condition(
      true,
      fn() -> visible_in_page?(@view_title_regex) end
    )

    # And sleep start is visible in page
    assert wait_for_condition(
      true,
      fn() -> visible_in_page?(start_regex) end
    )

    # And sleep end is visible in page
    assert visible_in_page?(end_regex)

    # And sleep duration is visible in page
    assert visible_in_page?(duration_regex)

    # And comment time is visible in page
    visible_in_page?(inserted_at_regex)

    # And comment text is visible in page
    assert visible_in_page?(@comment_text_regex)

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
    %Sleep{
      id: id_,
      start: start_,
      end: end_,
    } = insert(:sleep)

    # When we visit sleep detail page
    navigate_to "/#/sleeps/#{id_}"

    {start_time, start_str} = timex_ecto_date_to_local_tz_formatted start_
    {end_time, end_str} = timex_ecto_date_to_local_tz_formatted end_

    # And click on edit icon
    click {:id, @edit_sleep_icon_id}

    # Then start time is visible in page
    start_control = find_element :id, @edit_sleep_start_id
    assert attribute_value(start_control, "value") == start_str

    # And end time is visible in page
    end_control = find_element :id, @edit_sleep_end_id
    assert attribute_value(end_control, "value") == end_str

    # And view title is visible in page
    assert visible_in_page?(@edit_sleep_view_title_regex)

    # And no comment is visible in page
    refute element?(:class, @comment_display_class)

    # When start time field is edited
    card_title = find_element :class, @card_title_class
    new_start_time = Timex.shift start_time, days: 1
    click start_control
    datetime_picker_select_date new_start_time.day, card_title

    # And end time field is edited
    new_end_time = Timex.shift end_time, days: 1
    click end_control
    datetime_picker_select_date new_end_time.day, card_title

    # And comment field is edited
    click {:id, @edit_sleep_add_comment_icon_id}
    fill_field {:id, @edit_sleep_comment_id}, @new_comment_text

    # When form is submitted
    click {:id, @edit_sleep_submit_btn_id}

    # A message appears showing update was successful
    assert wait_for_condition(
      true,
      fn() ->
        visible_in_page?(@success_click_to_dismiss_regex)
      end
    )

    # And comment is visible in page
    assert element?(:class, @comment_display_class)

    # And sleep is updated in the database
    sleep = Sleep.get!(id_)
    {_, start_str_db} = timex_ecto_date_to_local_tz_formatted sleep.start
    {_, start_str_new} = timex_ecto_date_to_local_tz_formatted new_start_time
    assert start_str_db == start_str_new

    {_, end_str_db} = timex_ecto_date_to_local_tz_formatted sleep.end
    {_, end_str_new} = timex_ecto_date_to_local_tz_formatted new_end_time
    assert end_str_db == end_str_new
  end
end