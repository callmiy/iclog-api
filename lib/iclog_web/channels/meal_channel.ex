defmodule IclogWeb.MealChannel do
  use IclogWeb, :channel

  alias IclogWeb.Schema

  def join("meal:meal", %{"params" => params, "query" => query}, socket) do
    {:ok, val} = respond(query, params)
    {:ok, val, socket}
  end

  def handle_in("new_meal", %{ "query" => mutation, "params" => params}, socket) do
    with {:ok, %{data: %{"meal" => data}} } <- respond(mutation, params) do
      broadcast socket, "meal_created", %{data: %{"meal" => data}}
      {:reply, {:ok,  %{"id" => data["id"]} }, socket}
    else
      error -> {:reply, error, socket}
    end
  end
  def handle_in("list_meals", %{"query" => query, "params" => params}, socket) do
    {:reply, respond(query, params), socket}
  end
  def handle_in( "get_meal", %{"query" => query, "params" => params }, socket) do
    {:reply, respond(query, params), socket}
  end
  def handle_in("update_meal", %{"query" => mutation, "params" => params}, socket) do
    with {:ok, %{data: %{"mealUpdate" => data}} } <- respond(mutation, params) do
      broadcast socket, "meal_updated", Map.delete(data, "comments")
      {:reply, {:ok, %{data: %{"mealUpdate" => data}} }, socket}
    else
      error -> {:reply, error, socket}
    end
  end

  defp respond(query, params) do
    respond Absinthe.run(query, Schema, variables: params)
  end
  defp respond({:ok, %{errors: error}}) do
    {:error, %{errors: error}}
  end
  defp respond({:ok, data}) do
    {:ok, data}
  end
end
