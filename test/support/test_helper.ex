defmodule Iclog.TestHelper do
  def normalize_time(time) do
    %{time | microsecond: {0, 0} }
  end
end