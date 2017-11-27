defmodule IclogWeb.Feature.SleepListTest do
  @moduledoc false

  use Iclog.FeatureCase

  alias Iclog.Observable.Sleep

  @now Timex.shift(Timex.now(), hours: -1)
  @navigate_to "/#/sleeps"
  @detail_link_class "sleep-list-to-sleep-detail-link"

  @tag :integration
  # @tag :no_headless
  test "List sleeps", _meta do
    %Sleep{
      id: id_first,
      start: start_first_,
      end: end_first_,
    } = insert(:sleep, start: @now)

    ten_sleeps = insert_list(10, :sleep)

    %Sleep{
      id: id_last,
      start: start_last_,
      end: end_last_,
    } = List.last ten_sleeps

    navigate_to @navigate_to

    {start_first, _} = timex_ecto_date_to_local_tz(start_first_)
    start_first_regex = Regex.compile!(
      Timex.format!(start_first, list_date_date_regex()), "s"
    )

    {start_last, _} = timex_ecto_date_to_local_tz(start_last_)
    start_last_regex = Regex.compile!(
      Timex.format!(start_last, list_date_date_regex()), "s"
    )

    {_end_first, _} = timex_ecto_date_to_local_tz(end_first_)

    {end_last, _} = timex_ecto_date_to_local_tz(end_last_)
    end_last_regex = Regex.compile!(
      Timex.format!(end_last, list_date_date_regex()), "s"
    )

    # Last sleep start to be inserted is visible in page
    assert wait_for_condition(
      true,
      fn() ->
        visible_in_page?(start_last_regex)
      end
    )

     # And Last sleep end to be inserted is visible in page
    assert visible_in_page?(end_last_regex)

    # But first sleep start to be inserted is not visible in page
    refute visible_in_page?(start_first_regex)

    # link to go to detail page of last sleep is present in page
    assert element?(:css, "a[href$='/sleeps/#{id_last}']")

    # But link to go to detail page of first sleep is not present in page
    refute element?(:css, "a[href$='/sleeps/#{id_first}']")

    # There are a total of 10 such links
    assert length(
      find_all_elements(:class, @detail_link_class)
    ) == 10

    # text indicating pagination is visible in page
    assert visible_in_page?(@pagination_regex)

    next_page_arrow = find_element :id, @next_page_arrow_id
    click next_page_arrow

    # link to go to detail page of last sleep is no longer present in page
    refute wait_for_condition(
      false,
      fn() -> element?(:css, "a[href$='/sleeps/#{id_last}']") end
    )

    # But link to go to detail page of first sleep is now present in page
    assert element?(:css, "a[href$='/sleeps/#{id_first}']")
  end
end