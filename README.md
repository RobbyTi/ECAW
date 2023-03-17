
<!-- README.md is generated from README.Rmd. Please edit that file -->

# A survey of registration practices among observational researchers using preexisting datasets

The repository contains the data and the analysis for the research paper
titled “A survey of registration practices among observational
researchers using preexisting datasets”. Other materials belonging to
the project can be found on the project’s OSF page at
<https://osf.io/x2dpn/>.

## Folder structure

The `data/` folder contains all the datafiles and the corresponding
codebooks that are needed to reproduce the results of the project.

The `preprocessing/` folder contains all the data preprocessing files in
rmarkdowns. Within this folder you can find the following files:

- `ecaw_source_raw_preprocessing.Rmd` file contains the code necessary
  for the transformation of the source data (the datafile downloaded
  directly from Qualtrics as is) to the raw datafile (datafile with
  standard naming). We also made sure that the raw datafile does not
  contain any information that can be used to indetify any of the
  respondents.
- `ecaw_raw_processed_preprocessing.Rmd` file contains the code that
  cleans the dataset and transforms is into tidy format ready for the
  analysis.

The `manuscript/` folder contains the manuscript and supplementary
materials documents with the analysis code embedded in them.

The `R/` folder contains any custom R functions and their documentation.
