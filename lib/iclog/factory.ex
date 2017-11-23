defmodule Iclog.Factory do
  use ExMachina.Ecto, repo: Iclog.Repo

  alias Iclog.Observable.Observation
  alias Iclog.Observable.ObservationMeta
  alias Iclog.Observable.Meal
  alias Iclog.Observable.Sleep

  def observation_meta_factory do
    %ObservationMeta{
      title: sequence("some title"),
      intro: sequence("some intro"),
    }
  end

  def observation_factory do
    %Observation{
      comment: sequence("some comment"),
      observation_meta: build(:observation_meta),
    }
  end

  def observation_no_meta_factory do
    %Observation{
      comment: sequence("some comment")
    }
  end

  def meal_factory do
    make_one_meal()
  end

  def meal_with_comment_factory do
    meal = make_one_meal()
    comment = Ecto.build_assoc meal, :comments, %{text: sequence("Nice meal-")}
    %{meal | comments: [comment]}
  end


  def sleep_factory do
    make_one_sleep()
  end

  def sleep_with_comment_factory do
    sleep = make_one_sleep()
    comment = Ecto.build_assoc sleep, :comments, %{text: sequence("Nice sleep-")}
    %{sleep | comments: [comment]}
  end

  defp make_one_sleep do
    start = Timex.now()
    end_ = Timex.shift(start, hours: 4)

    %Sleep{
      start: sequence(:sleep_start, &Timex.shift(start, days: String.to_integer("#{&1}") - 1 )),
      end: sequence(:sleep_end, &Timex.shift(end_, days: String.to_integer("#{&1}") - 1 ))
    }
  end

  defp make_one_meal do
    %Meal{
      meal: sequence("meal-"),
      time: Timex.now()
    }
  end
end