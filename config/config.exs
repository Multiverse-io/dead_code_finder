import Config

config :dead_code_finder, :applications, [:dead_code_finder]

import_config "#{config_env()}.exs"
