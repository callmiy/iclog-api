defmodule Iclog.Factory.SleepCommentStrategy do
  use ExMachina.Strategy, function_name: :create

  alias Iclog.Repo
  alias Iclog.Observable.Sleep

  def handle_create(%{sleep: %Sleep{} = sleep, text: text} = _record, _opts) do
    ca = Ecto.build_assoc sleep, :comments, %{text: text}
    Repo.insert! ca
  end
end

defmodule Iclog.Factory.SleepComment do
  use ExMachina
  use Iclog.Factory.SleepCommentStrategy

  def comment_factory do
    %{text: sequence("Nice sleep-")}
  end
end