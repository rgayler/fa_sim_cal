##### setup_01.R #####

# This is setup code for the 01*.Rmd notebooks (get, check, clean the entity data).
# Typically this setup loads libraries and sources function definitions.

# This setup must be run after the project setup.
# If there are groups of 01 notebooks or single notebooks that need extra setup
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
#
# # Set up for the 01*.Rmd notebooks
# source(here::here("code", "setup_01.R"))
# ```

##### Load libraries #####

library(fst) # for fast, compressed dataframe storage
library(magrittr) # for piping
library(dplyr) # for tidy data manipulation
library(stringr) # for string manipulation
library(skimr) # for compact summary statistics
library(knitr) # for formatted rendering of tables
library(glue) # for convenient string interpolation

# ##### Load utility functions #####
#
# # Utility functions used across the analyses
# source(here::here("code", "util.R"))
