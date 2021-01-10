##### setup_project.R #####

# This is code to *always* be run when opening the project or knitting a notebook.
# So this is setup code that applies to *all* project activities.
# Typically this setup loads libraries and sources function definitions.

# If there are groups of notebooks or single notebooks that need extra setup
# those setups will be run after the project setup.

##### Mandatory setup for *.Rmd files #####

# .Rprofile automatically sources this project setup script on project open.
# Interactive analyses shouldn't have to source this because they use the R session from opening the project.
# Documents to be knitted will have to explicitly source this script because (by default) they run in new R sessions.

# The first chunk of every *.Rmd file has to be like the following chunk
# in order to source this project setup script.

# ```{r setup}
# # Set up the project environment, because each Rmd file is knit in a new R session
# library(here)
# source(here::here("code", "setup_project.R"))
# ```

##### Set up debugging #####

# Interactive debugging can only be done running in the R console session.
# By default, knitting of Rmarkdown documents occurs in a new R session.
# To interactively debug a notebook, build it to use the console R session with:
# workflowr::wflow_build('analysis/file'.Rmd, local = TRUE)")

# To enable debugging run the next line in the R console session:
# DEBUG <- TRUE
# If DEBUG ever has a value other than TRUE or FALSE bad things *might* happen.

# It is expected that DEBUG will primarily be used to prevent execution of some code chunks.
# This will primarily be used to avoid long-running computations.
# However, it *may* be used directly in the chunk code.

# Set DEBUG to FALSE if it doesn't already exist.
if(!exists("DEBUG")) DEBUG <- FALSE

##### Load libraries #####

library(here) # for constructing file paths relative to project root
library(tictoc) # for timing the operations
# suppressPackageStartupMessages(
  library(tidyverse) # for "tidy" operations
# )

# ##### Load utility functions #####
#
# # Utility functions used across the analyses
# source(here::here("code", "util.R"))

##### Miscellaneous setup #####

if(DEBUG) cat("\n*** setup_project.R ***\n")

# # number of threads available for parallel processing
# n_threads <- 7

##### Set file paths #####

source(here::here("code", "file_paths.R"))
