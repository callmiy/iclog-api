defmodule IclogWeb.Schema do
  use Absinthe.Schema

  import_types IclogWeb.Schema.Types
  import_types IclogWeb.Schema.Observation
  import_types IclogWeb.Schema.ObservationMeta
  import_types IclogWeb.Schema.Meal
  import_types IclogWeb.Schema.Sleep

  query do
    import_fields :observation_query
    import_fields :observation_meta_query
    import_fields :meal_query
    import_fields :sleep_queries
  end

  mutation do
    import_fields :observation_mutations
    import_fields :meal_mutations
    import_fields :sleep_mutations
  end
end