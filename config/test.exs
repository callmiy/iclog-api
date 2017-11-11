use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :iclog, IclogWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :iclog, Iclog.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "iclog_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :iclog, :sql_sandbox, true
config :wallaby,
  screenshot_on_failure: true
  # phantomjs: "C:\\Users\\maneptha\\AppData\\Roaming\\npm\\phantomjs.cmd"
  # driver: Wallaby.Experimental.Chrome