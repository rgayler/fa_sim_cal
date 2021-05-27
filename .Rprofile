## Activate the renv package to manage the project's package library
source("renv/activate.R")

## Attach the libraries we will always need to work in the console
if(interactive())
  suppressPackageStartupMessages(
    {
      library(targets)
      library(workflowr)
      library(here)
    }
  )

# Check the project build status when opening the project
if(interactive())
  message("Run 'wflow_build(\"analysis/m_00_status.Rmd\")' to see the project status")
