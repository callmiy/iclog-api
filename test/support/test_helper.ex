defmodule Iclog.TestHelper do

  @datetime_format_str "{WDshort} {0D}/{Mshort}/{YY} {0h12}:{m} {AM}"
  @utc_tz "Etc/UTC"
  @iso_extended "{ISO:Extended:Z}"

  def normalize_time(time) do
    %{time | microsecond: {0, 0} }
  end

  def datetime_format_str do
    @datetime_format_str
  end

  def timex_ecto_date_to_local_datime_tz(date) do
    date
    |> Timex.to_datetime(@utc_tz)  #This is the only way I have found to force Timex to respect local timezone
    |> Timex.to_datetime(Timex.Timezone.local())
  end

  def timex_ecto_date_to_local_tz_formatted(date) do
    date_ = timex_ecto_date_to_local_datime_tz(date)

    date_str = date_
    |> Timex.format!(datetime_format_str())
    {date_, date_str}
  end

  def format_iso_extended(date) do
    Timex.format!(date, @iso_extended)
  end

  def iso_extended do
    @iso_extended
  end
end