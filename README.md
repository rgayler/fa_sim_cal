# Frequency-Aware Similarity Calibration

This is an open, shareable, reproducible, computational research project on entity resolution.

It is the joint work of:

* [Ross W. Gayler][]
* [Peter Christen][]

Given a collection of records which are each "about" one entity,
[entity resolution][] is the process of determining which records *probably* refer to the same entity.
It is used in contexts where there is no uniquely identifying entity key on the records,
so the process is forced to rely on record attributes that are associated with identity, 
but not uniquely determined by identity
(e.g. height, weight, and eye colour as attributes of persons).

This inference of two records referring to the same entity is inherently probabilistic 
because it is always possible that multiple entities
might have identical values on the available record attributes,
and are therefore functionally identical.
So, given a pair of records, 
we are interested in the *probability* that they refer to the same entity.

Entity resolution is typically conceptualised in terms of the [similarity][] between records,
and similarity is *assumed* to be monotonic with the probability of referring to the same entity.
This project investigates the value of empirically determining 
the relationship between similarity and probability of co-reference.
Determining the precise relationship between similarity and probability of co-reference
can be seen as an example of [calibration][].

We also investigate whether that calibration varies as a function 
of other measurable quantities of the specific records being compared.
For example, we could look at the frequency in the collection of the record attribute values being compared,
and see whether that information can be exploited to yield better entity resolution.

Entity resolution typically uses a small number of fixed similarity functions (e.g. edit distance between strings)
that are defined without reference to the specific pair of records being compared.
Incorporation of other predictors, which are functions of the specific records being compared,
into the calibration function
can be seen as similar in spirit to having a customised similarity function for every pair of records.
This parallels the practice of using subpopulation-specific model calibration functions 
to better combine model estimates across multiple subpopulations.

## Project organisation

This is an open, shareable, reproducible, computational research project. 

* All the computational work and document preparation
  is done with the [R][] statistical computing environment
  and the [Rstudio][] integrated development environment.

* The entire research project is contained in a single directory
  that corresponds to an RStudio R project.

* We are using the [`workflowr`][] package 
  to structure the project so that the work is computationally reproducible
  and all the materials and outputs are available
  via an openly accessible, automatically generated website.

* The project code and documents are shared publicly on GitHub at https://github.com/rgayler/fa_sim_cal

* The website automatically generated by `worklowr` from the rendered project documents 
  is at https://rgayler.github.io/fa_sim_cal/

* We use the [`renv`][] package to manage the package versions used by the project

## Project directory structure

### `workflowr` directories

* [`workflowr`][] creates a set of standard directories.
  See the package documentation for details on how these directories are used.
  The brief purposes are:
  * `analysis` - [`rmarkdown`][] analysis notebooks
  * `code` - R code not in analysis notebooks
  * `data` - raw data and associated metadata
  * `docs` - automatically generated website
  * `output` - generated data and other objects

* [`workflowr`][] only manages the subset of files that it knows about,
so you will need to manually stage and commit any other files
that need to be mirrored on GitHub.

* If any files in `data` and `output` are more than trivially small,
  they are not shared via Git and GitHub.
  * `.gitignore` is used to keep them out of Git.
  * There will be a separate mechanism (e.g. [Zenodo][]) for sharing those large files.

### `manuscripts` directory  

The analysis notebooks are for capturing all the analytical work that was done,
including exploratory work and abandoned directions.
They contain both the code and enough interpretation/explanation
to make sense of the results.

The notebooks will be too verbose,
and inappropriately structured/formatted for publication.
Publishable documents are written separately
and kept in the `manuscripts` directory.

* `manuscripts` - contains a directory for each manuscript/document/presentation

Each manuscript/document/presentation is prepared and formatted 
using a package like [`rticles`][] or[`bookdown`][].
Each document is prepared in a separate subdirectory of `manuscripts`
that contains all the necessary infrastructure files (templates, bibliographies, etc.).

### `renv` directory

The [`renv`][] package keeps track of the packages (and their versions) used by the project.
It allows anyone to reinstate the same packages and versions in their local copy of the project.

* `renv` - contains the information need by `renv` to reinstate the local package environment

## Key documents

There are two key content documents:

* `docs/index.html` (also on the website as https://rgayler.github.io/fa_sim_cal/index.html)
  contains the table of contents for the project.
  There are links to all the analysis notebooks and publication documents.
* `docs/idea.html` (also on the website as https://rgayler.github.io/fa_sim_cal/idea.html)
  explains the idea on which this project is based.

## How to

* All detailed setup instructions and notes go in this project-level `READ.md` file.
* The `README.md` files in the subdirectories only state the purpose of each directory
  and the files in that directory.

### Installation

This assumes that you already have current versions
of R and RStudio installed.

1. Clone the project repository https://github.com/rgayler/fa_sim_cal from GitHub

2. Open the cloned repository as an RStudio project

You can combine steps 1 and 2 using RStudio
by creating a new project from the GitHub repository:  
`File | New Project... | Version Control | Git | Create Project`

When you open the project you will get warning messages 
about packages not being installed.
This is because you need to use the [`renv`][] package
to reinstate the packages that are used by the project.

3. Install [`renv`][] in that project if it is not already installed

4. Use `renv` to install all the needed packages in the project-specific library:
   ```
   renv::restore()
   ```

### Get data

Any files in `data` and `output` that are more than trivially small
are not shared via Git and GitHub.
They will be shared via a separate, yet to be determined,  mechanism (e.g. [Zenodo][]).

For the immediate purposes of this project 
the raw data files should be downloadable from the internet
and any processed data can be locally regenerated.
In the longer term, the raw data should be bundled with the project somehow
so that there is no dependency on continued data availability via the internet.

### Analysis & website publication

The analysis notebooks follow the `workflowr` workflow.
See the [getting started][] vignette for an introduction.

* Create a new analysis notebook:
  ```
  workflowr::wflow_open("analysis/new_notebook_name.Rmd")
  ```

* Build the website locally:
  ```
  workflowr::wflow_build()
  ```

* Publish the website online.
  This will only work if you have `push` authorisation
  for the GitHub remote repository.
  ```
  workflowr::wflow_publish("analysis/*.Rmd" "A commit message")
  ```

* Add `mathjax = "local"` as an argument to `workflowr::wflow_html` in `analysis/_site.yml`
  so that the MathJax JavaScript library is bundled with the website in `docs/`
  rather than being loaded from a remote server when the website is viewed.
  This removes the dependency on the remote server being available.
  See https://github.com/jdblischak/workflowr/issues/211
  ```
  output:
    workflowr::wflow_html:
      mathjax: "local"
  ```

* Bibliography records for citations in the `analysis/` notebooks
  are stored in `analysis/references.bib`.
  * Rstudio provides convenient [features for managing citations][].

* The reference style sheet for citations in the `analysis/` notebooks
  is stored in `analysis/some_style_name.csl`.
  
See the R Markdown [citation guide][] for more details.

### `renv` collaboration

The `renv` package is used to keep track of the installed packages and their versions.
See the `renv` [collaboration guide][] or the workflow
for synchronising package environments between collaborators.

### Manuscript preparation

* Each publishable document is managed in a separate subdirectory of `manuscripts`.

* The `manuscripts` directory is not managed by [`workflowr`][],
  so must be manually managed with respect to Git.

* Each publishable R Markdown document is prepared and formatted 
  using a package like [`rticles`][] or[`bookdown`][],
  so the details may vary between documents.

* The publishable R Markdown documents should avoid heavy computation.
  It is generally better if heavy computation is done in analysis notebooks
  and the results stored in the `output` directory.
  Those results can then be picked up by the publishable R Markdown document.

* Each rendered publishable document
  will be created in its subdirectory of `manuscripts`.
  * The rendered document needs to also exist in the `docs/` directory
    so that it can be referenced from the generated web pages, locally and on GitHub.
    (See https://github.com/jdblischak/workflowr/issues/209)
  * This can be done by creating a symlink to the rendered document.


[Ross W. Gayler]: https://www.rossgayler.com/
[Peter Christen]: https://users.cecs.anu.edu.au/~Peter.Christen/

[entity resolution]: https://en.wikipedia.org/wiki/Record_linkage

[similarity]: https://en.wikipedia.org/wiki/Similarity_measure

[calibration]: https://en.wikipedia.org/wiki/Calibration_(statistics)

[R]: https://www.r-project.org/

[RStudio]: https://www.r-project.org/

[`workflowr`]: https://github.com/jdblischak/workflowr

[`renv`]: https://rstudio.github.io/renv/

[`rmarkdown`]: https://rmarkdown.rstudio.com/

[`rticles`]: https://github.com/rstudio/rticles

[`bookdown`]: https://github.com/rstudio/bookdown

[Zenodo]: https://about.zenodo.org/

[getting started]: https://jdblischak.github.io/workflowr/articles/wflow-01-getting-started.html#add-a-new-analysis-file

[citation guide]: https://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html

[collaboration guide]: https://rstudio.github.io/renv/articles/collaborating.html

[features for managing citations]: https://blog.rstudio.com/2020/11/09/rstudio-1-4-preview-citations/
