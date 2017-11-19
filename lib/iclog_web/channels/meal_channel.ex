defmodule IclogWeb.MealChannel do
  use IclogWeb, :channel

  alias IclogWeb.Schema

  def join("meal:meal", %{"params" => params, "query" => query}, socket) do
    {_, {:ok, val}, _} = respond(query, params, socket)
    {:ok, val, socket}
  end

  def handle_in(
      "new_meal",
      %{ "query" => mutation, "params" => params },
      socket) do
    respond(mutation, params, socket, "meal_created")
  end
  def handle_in(
      "list_meals",
      %{"query" => query, "params" => params },
      socket) do
    respond(query, params, socket)
  end
  def handle_in(
      "get_meal",
      %{"query" => query, "params" => params },
      socket) do
    respond(query, params, socket)
  end
  def handle_in(
      "update_meal",
      %{"query" => query, "params" => params },
      socket) do

    respond(query, params, socket, "meal_updated")
  end

  defp respond(query, params, socket, broadcast_name \\ nil) do
    response Absinthe.run(query, Schema, variables: params), socket, broadcast_name
  end
  defp response({:ok, %{errors: error}}, socket, _broadcast_name) do
    {:reply, {:error, %{errors: error}}, socket}
  end
  defp response({:ok, data}, socket, broadcast_name \\ nil) do
    if broadcast_name do
      broadcast socket, broadcast_name, data
    end
    {:reply, {:ok, data}, socket}
  end
end
