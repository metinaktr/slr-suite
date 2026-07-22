# ==============================================================================
# TCCM and bibliometric dictionary configuration
# ==============================================================================
source(here::here("R", "dictionaries.R"))

TCCM_DICTIONARIES <- read_tccm_dictionaries(
  here::here("config", "tccm_dictionaries.yaml")
)

message(">> [CONFIG] Academic dictionaries were loaded successfully from YAML.")
