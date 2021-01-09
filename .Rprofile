## Activate the renv package to manage the project's package library
source("renv/activate.R")

## This makes sure that R loads the workflowr package
## automatically, everytime the project is loaded
if (requireNamespace("workflowr", quietly = TRUE)) {
  message("Loading .Rprofile for the current workflowr project")
  library("workflowr")
} else {
  message("workflowr package not installed, please run install.packages(\"workflowr\") to use the workflowr functions")
}

## Launching the project from RStudio ensures that the R project directory is used as the working directory

## Load the here package so it is available before running setup scripts
library(here)

## Do project-wide setup
## This is any setup needed by *all* work in the project
## Groups of analyses or single analyses may require their own setup in addition to this
source(here::here("code", "setup_project.R"))

## Give reminders on what to do and project status on opening the project
message("\nExecute workflowr functions from the R console, never from within an Rmd document.")
message()
message("Preview the current website - workflowr::wflow_view()")
message("Rebuild the entire website for previewing - workflowr::wflow_build(republish = TRUE)")
message("Rebuild some analyses for previewing - workflowr::wflow_build(c('analysis/file1.Rmd', 'analysis/file2.Rmd'))")
message("Rebuild a single analysis for debugging in the R console - workflowr::wflow_build('analysis/file'.Rmd, local = TRUE)")
message("Commit changes, build website, commit pages - workflowr::wflow_publish(c('analysis/file1.Rmd', 'analysis/file2.Rmd')), message = 'Commit message')")
message("Preview what will happen when you publish the website - workflowr::wflow_publish(dry_run = TRUE)")
message()

message("renv status")
renv::status()
message()

message("workflowr status")
workflowr::wflow_status()
message()
