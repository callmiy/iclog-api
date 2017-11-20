defmodule IclogWeb.ObservationChannel do
  use IclogWeb, :channel

  alias IclogWeb.Schema

  def join("observation:observation", %{"params" => params, "query" => query}, socket) do
    {_, reply} = respond(query, params)
    {:ok, reply, socket}
  end

  def handle_in( "new_observation", %{ "with_meta" => _, "query" => mutation, "params" => params }, socket) do
    {:reply, respond(mutation, params), socket}
  end
  def handle_in( "new_observation", %{ "query" => mutation, "params" => params }, socket) do
    {:reply, respond(mutation, params), socket}
  end
  def handle_in( "search_metas_by_title", %{"query" => query, "params" => params }, socket) do
    {:reply, respond(query, params), socket}
  end
  def handle_in( "list_observations", %{"query" => query, "params" => params }, socket) do
    {:reply, respond(query, params), socket}
  end
  def handle_in( "get_observation", %{"query" => query, "params" => params }, socket) do
    {:reply, respond(query, params), socket}
  end
  def handle_in( "update_observation", %{"query" => query, "params" => params }, socket) do
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
