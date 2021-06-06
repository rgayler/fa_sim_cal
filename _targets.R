library(targets)
library(tarchetypes) # for tar_knitr_deps_expr()
library(here) # construct file paths relative to project root
library(fs) # file system operations

# My main computer supports 32 threads, so why not use them?
#
# Uncomment the following code and use tar_make_future(workers = 30L) to make the targets
# in parallel sessions on the local machine.
#
library(future)
future::plan("multicore")
# multicore is *not* recommended in Rstudio sessions, but "multisession" doesn't seem to work for me
#
# Unfortunately, in this project you typically only need to recompute a small number of targets
# so the target-level parallelism doesn't help much.
# In this project, it would probably be more helpful to aim for multithreading *within* each target.

# Define custom functions and other global objects in `R/functions.R`.
# All the functions to calculate the targets are defined here.
source(here::here("R", "functions.R"))


# Set target-specific options such as packages.
# It is recommended to load here all the packages required by functions managed only by {targets}.
# Packages required by {workflowr} notebooks should be loaded in those notebooks
# so they can be run manually (rather than exclusively by {targets}).
options(tidyverse.quiet = TRUE)
tar_option_set(
  packages = c(
    "dplyr", "magrittr", "stringr", "tidyr", "vroom"
  ),
  format = "qs"
)

# list of target objects
list(

  # CORE pipeline targets ----

  # Path to raw entity data file
  tar_target(
    c_raw_entity_data_file,
    here::here("data", "VR_Snapshot_20081104.xz"),
    format = "file"
  ),

  # Clean entity data
  tar_target(
    c_clean_entity_data,
    raw_entity_data_make_clean(c_raw_entity_data_file)
  ),

  # Parked for later stages of the pipeline
  # # arbitrary lower and upper bound on useful block size
  # blk_sz_min <- 50
  # blk_sz_max <- 50e3


  # META pipeline targets ----

  # Any META steps that are straight computation (not Rmd notebooks)
  # are treated exactly like CORE targets.
  #
  # Each META pipeline should have leaves that are the rendering
  # of one or more {workflowr} Rmd notebooks.
  # These notebooks are part-managed by {targets}
  # and part-managed by {workflowr}.
  #
  # For the moment, I only get {targets} to monitor the input Rmd files
  # and any data dependencies (via tar_read and tar_load).
  # That is, I do NOT include the rendered HTML outputs
  # as files to be watched by {targets}.
  # This means I am only relying on {targets} to rebuild the reports if
  # any upstream dependencies, including the Rmd file, change.
  #
  # The targets defined here use workflowr::wflow_build()
  # to render the Rmd file.
  # Because the target is not monitoring the rendered HTML output
  # it can't tell whether the report has been rendered.
  # However, {workflowr} *does* monitor the relationship
  # between the Rmd and HTML file,
  # so wflow_status() knows whether the rendering is up to date.
  # (If I included the rendered HTML report as a dependency
  # targets would flag the report as invalidated if I manually
  # rebuilt or published the report with workflowr.)
  #
  # The user needs to manually execute wflow_publish()
  # to publish the report.
  # NOTE when {workflowr} is run manually (not via {targets})
  # the usual setup done by _targets.R (e.g. loading packages)
  # *won't* have been done.
  # So the {workflowr} Rmd notebooks must do all their own setup
  # on the assumption they are run manually.
  #
  # I should really develop a tarchetype tar_wflow_build like tar_render,
  # but I don't feel up to that yet,
  # so I will take the more long-winded tar_target approach

  # The special {workflowr} Rmd files (index.Rmd, about.Rmd, license.Rmd)
  # don't generally need to have targets defined here
  # because they don't generally have any upstream dependencies.
  # I am relying entirely on {workflowr} to track these files.

  ## m_01 Read the raw entity data and clean it ----

  # Report investigating how to read the raw entity data
  tar_target(
    m_01_1_read_raw_entity_data,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_1_read_raw_entity_data.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_1_read_raw_entity_data.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track the input Rmd file (and not the rendered HTML file).
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_1_read_raw_entity_data.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  ),

  # Report investigating how to exclude unwanted rows
  tar_target(
    m_01_2_exclusions,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_2_exclusions.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read,
        raw_entity_data_excl_status, raw_entity_data_excl_test
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_2_exclusions.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track the input Rmd file (and not the rendered HTML file).
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_2_exclusions.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  ),

  # Report investigating variable to drop because of no variation
  tar_target(
    m_01_3_drop_novar,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_3_drop_novar.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read,
        raw_entity_data_excl_status, raw_entity_data_excl_test,
        raw_entity_data_drop_novar
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_3_drop_novar.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track the input Rmd file (and not the rendered HTML file).
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_3_drop_novar.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  ),

  # Report investigating how to parse the date columns
  tar_target(
    m_01_4_parse_dates,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_4_parse_dates.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read,
        raw_entity_data_excl_status, raw_entity_data_excl_test,
        raw_entity_data_drop_novar,
        raw_entity_data_parse_dates
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_4_parse_dates.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track the input Rmd file (and not the rendered HTML file).
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_4_parse_dates.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  ),

  # Report investigating the administrative variables
  tar_target(
    m_01_5_check_admin,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_5_check_admin.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read,
        raw_entity_data_excl_status, raw_entity_data_excl_test,
        raw_entity_data_drop_novar,
        raw_entity_data_parse_dates,
        raw_entity_data_drop_admin
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_5_check_admin.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track the input Rmd file (and not the rendered HTML file).
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_5_check_admin.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  ),

  # Report investigating the residential variables
  tar_target(
    m_01_6_check_resid,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_6_check_resid.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read,
        raw_entity_data_excl_status, raw_entity_data_excl_test,
        raw_entity_data_drop_novar,
        raw_entity_data_parse_dates,
        raw_entity_data_drop_admin
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_6_check_resid.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track only the input Rmd file
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_6_check_resid.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  ),

  # Report investigating the demographic variables
  tar_target(
    m_01_7_check_demog,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_7_check_demog.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read,
        raw_entity_data_excl_status, raw_entity_data_excl_test,
        raw_entity_data_drop_novar,
        raw_entity_data_parse_dates,
        raw_entity_data_drop_admin,
        raw_entity_data_drop_demog
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_7_check_demog.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track only the input Rmd file
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_7_check_demog.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  ),

  # Report investigating the name variables
  tar_target(
    m_01_8_check_name,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_8_check_name.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read,
        raw_entity_data_excl_status, raw_entity_data_excl_test,
        raw_entity_data_drop_novar,
        raw_entity_data_parse_dates,
        raw_entity_data_drop_admin,
        raw_entity_data_drop_demog
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_8_check_name.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track only the input Rmd file
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_8_check_name.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  ),

  # Report investigating of cleaning the name variables
  tar_target(
    m_01_9_clean_vars,
    command = {
      # Scan for targets of tar_read() and tar_load()
      !!tar_knitr_deps_expr(here("analysis", "m_01_9_clean_vars.Rmd"))
      # Explicitly mention any functions used from R/functions.R
      list(
        raw_entity_data_read,
        raw_entity_data_excl_status, raw_entity_data_excl_test,
        raw_entity_data_drop_novar,
        raw_entity_data_parse_dates,
        raw_entity_data_drop_admin,
        raw_entity_data_drop_demog,
        raw_entity_data_clean_age, raw_entity_data_clean_preprocess_char, raw_entity_data_clean_all_names,
        raw_entity_data_clean_last_name, raw_entity_data_clean_middle_name, raw_entity_data_clean_first_name,
        raw_entity_data_clean_postprocess_names, raw_entity_data_clean_all,
        raw_entity_data_make_clean
      )

      # Build the report
      workflowr::wflow_build(
        here("analysis", "m_01_9_clean_vars.Rmd"),
        make = TRUE, update = FALSE, clean_fig_files = TRUE, delete_cache = TRUE # too much?
      )

      # Track only the input Rmd file
      # Make the path relative to keep the project portable.
      fs::path_rel(here("analysis", "m_01_9_clean_vars.Rmd"))
    },
    # Track the files returned by the command
    format = "file"
  )

  ## m_02 xxx ----


  ## m_03 yyy ----


    # PUBLICATIONS targets ----

  # These should probably be dealt with by tarchetypes::tar_render.
  # I have not yet done this.


)
