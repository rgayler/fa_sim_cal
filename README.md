# Frequency-Aware Similarity Calibration

Given a collection of records which are each "about" one entity,
[entity resolution][] is the process of determining which records probably refer to the same entity.
It is only used in contexts where there is no uniquely identifying entity key on the records,
so the process is forced to rely on record attributes that are associated with identity, 
but not uniquely determined by identity
(e.g. height, weight, and eye colour as attributes of persons).

This inference of two records refering to the same entity is inherently probabilistic 
because it is always possible that multiple entities
might have identical values on the available record attributes,
and are therefore functionally identical.
So, given a pair of records, 
we are interested in the probability that they refer to the same entity.

Entity resolution is typically conceptualised in terms of the [similarity][] between records,
and similarity is *assumed* to be monotonic with the probability of referring to the same entity.
This project investigates the value of empirically determining 
the relationship between similarity and probability of co-reference.
Determining the precise relationship between similarity and probability of co-reference
can be seen as an example of [calibration][].

We also investigate whether that calibration varies as a function of other measurable quantities,
such as the frequency in the collection of the record attribute values being compared,
and if so, whether that information can be exploited to yield better entity resolution.
Entity resolution typically uses a small number of fixed similarity functions (e.g. edit distance between strings)
that are defined without reference to the specific pair of records being compared.
Incorporation of other predicttors, which are functions of the specific records being compared,
into the calibration function
can be seen as similar in spirit to having a customised similarity function for every pair of records.
This parallels the practice of using model calibration functions to better combine ensembles of models.

This project is the joint work of:

* [Ross W. Gayler](https://www.rossgayler.com/)
* [Peter Christen](https://users.cecs.anu.edu.au/~Peter.Christen/)

## Project structure

* All the computational work and document preparation
  is done with the [R][] statistical computing envireonmemt
  and the [Rstudio][] integrated development environment.
* The entire research project is contained in a directory
  that corresponds to an RStudio R project.
* We are using the {[workflowr][]} [R][] package 
  to structure the project so that the work is computationally reproducible
  and all the materials and outputs are openly accessible.
  * The project code is shared publicly on GitHub at https://github.com/rgayler/fa_sim_cal
  * The website automatically generated from the rendered project documents is at https://rgayler.github.io/fa_sim_cal/

* [`{workflowr}`](https://github.com/jdblischak/workflowr) only manages a subset of the files,
so you will need to manually stage and commit any other files
that need to be mirrored on GitHub.

* There are three key source documents:
  * `analysis/skeleton.Rmd` contains the outline of the final paper
  and meta-level notes about the content of the paper and the simulations to support the paper.
  * `analysis/simulation.Rmd` contains the outline of the final paper
  and meta-level notes about the content of the paper and the simulations to support the paper.
  * `paper/paper.Rmd` contains the final output paper.

*Refer to John Blischak's https://github.com/jdblischak/singleCellSeq 
(created before he developed  [`{workflowr}`](https://github.com/jdblischak/workflowr)) 
for ideas on project organisation.*

## Installation

* All detailed setup instructions and notes go in this project-level `READ.md` file.
  * The `README.md` files in the subdirectories only state the purpose of each directory
and the files in that directory.












[entity resolution]: https://en.wikipedia.org/wiki/Record_linkage

[similarity]: https://en.wikipedia.org/wiki/Similarity_measure

[calibration]: https://en.wikipedia.org/wiki/Calibration_(statistics)

[R]: https://www.r-project.org/

[RStudio]: https://www.r-project.org/

[workflowr]: https://github.com/jdblischak/workflowr
