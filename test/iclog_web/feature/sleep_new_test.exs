defmodule IclogWeb.Feature.SleepNewTest do
  use Iclog.FeatureCase

  alias Iclog.Observable.Sleep
  alias Iclog.Comment

  @navigate_to "/#/sleeps/new"
  @submit_btn_name "new-sleep-submit-btn"
  @page_title_sleep "Sleep"
  @page_title_class "page-title"
  @comment_box_show_id "new-sleep-sleep-comment-toggle"
  @comment_box_id "new-sleep-comment"
  @comment_text "Nix"

  @tag :integration
  # @tag :no_headless
  test "Create a sleep without comment", _meta do
    navigate_to @navigate_to
    assert visible_text({:class, @page_title_class}) == @page_title_sleep

    # Submit button is clicked
    click find_element(:name, @submit_btn_name)

    :timer.sleep 50

    # Sleep is created
    assert wait_for_condition(
      true,
      fn() ->
        case Sleep.list() do
          [] ->
            false
          [%Sleep{id: _id}] ->
            true
        end
      end
    )

    # And success message is visible in page
    assert wait_for_condition(
      true,
      fn() -> visible_in_page?(@success_msg_regex) end
    )
  end

  @tag :integration
  # @tag :no_headless
  test "Create a sleep with comment", _meta do
    navigate_to @navigate_to

    # Comment box reveal icon is cliked
    click find_element(:id, @comment_box_show_id)
    comment_control = find_element :id, @comment_box_id

    # when comment box is completed
    fill_field comment_control, ""
    type_text @comment_text, 20

    # And submit button is clicked
    click find_element(:name, @submit_btn_name)

    :timer.sleep 50

    # Sleep is created
    assert wait_for_condition(
      true,
      fn() ->
        case Sleep.list_all() do
          [] ->
            false
          [%Sleep{comments: [%Comment{text: text}] }] ->
            text == @comment_text
        end
      end
    )

    # And success message is visible in page
    assert wait_for_condition(
      true,
      fn() -> visible_in_page?(@success_msg_regex) end
    )
  end
end
