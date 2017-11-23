defmodule IclogWeb.SleepChannel do
  use IclogWeb, :channel

  alias IclogWeb.Schema

  def join("sleep:sleep", %{"params" => params, "query" => query}, socket) do
    {:ok, val} = respond(query, params)
    {:ok, val, socket}
  end

  def handle_in("new_sleep", %{ "query" => mutation, "params" => params}, socket) do
    with {:ok, %{data: %{"sleep" => data}} } <- respond(mutation, params) do
      broadcast socket, "sleep_created", %{data: %{"sleep" => data}}
      {:reply, {:ok,  %{"id" => data["id"]} }, socket}
    else
      error -> {:reply, error, socket}
    end
  end
  def handle_in("list_sleeps", %{"query" => query, "params" => params}, socket) do
    {:reply, respond(query, params), socket}
  end
  def handle_in( "get_sleep", %{"query" => query, "params" => params }, socket) do
    {:reply, respond(query, params), socket}
  end
  def handle_in("update_sleep", %{"query" => mutation, "params" => params}, socket) do
    with {:ok, %{data: %{"sleepUpdate" => data}} } <- respond(mutation, params) do
      broadcast socket, "sleep_updated", Map.delete(data, "comments")
      {:reply, {:ok, %{data: %{"sleepUpdate" => data}} }, socket}
    else
      error -> {:reply, error, socket}
    end
  end
  def handle_in( "comment_sleep", %{"query" => query, "params" => params }, socket) do
    {:reply, respond(query, params), socket}
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
