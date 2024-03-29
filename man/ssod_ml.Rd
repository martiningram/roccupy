% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ssod_ml.R
\name{ssod_ml}
\alias{ssod_ml}
\title{Fit SSOD model}
\usage{
ssod_ml(
  env_formula,
  obs_formula,
  X_env,
  X_checklist,
  y_checklist,
  checklist_cell_ids
)
}
\arguments{
\item{env_formula}{Formula to use for the environment / suitability part of
the model. Should be a string compatible with the patsy python package.}

\item{obs_formula}{Formula to use for the observation / detection part of the
model. Again, should be supported by patsy.}

\item{X_env}{A DataFrame containing the environmental covariates. Dimensions
(n_sites, n_env_covariates).}

\item{X_checklist}{A DataFrame containing the observation
covariates. Dimensions (n_checklists, n_obs_covariates).}

\item{y_checklist}{A DataFrame specifying whether each species was or was not
observed for each visit (checklist). As this is a single-species model,
it must have only a single column, ideally named after the species of
interest.}

\item{checklist_cell_ids}{A vector specifying which site (aka cell) each
checklist belongs to. E.g. if checklist_cell_ids[2] = 3, the second
checklist was made at site 3. Note that sites are number from 0, so this
this would be the _fourth_ site -- i.e. the one whose environmental
variables are in X_env[4, ] using R indexing!}
}
\value{
The fitted ssod_maxlik object.
}
\description{
Fits a single-species occupancy detection (SSOD) model using maximum
likelihood.
}
