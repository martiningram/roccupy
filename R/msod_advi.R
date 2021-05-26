#' Fit MSOD model
#'
#' Fits a multi-species occupancy detection (MSOD) model using variational
#' inference.
#'
#' @param env_formula Formula to use for the environment / suitability part of
#' the model. Should be a string compatible with the patsy python package.
#' @param obs_formula Formula to use for the observation / detection part of the
#' model. Again, should be supported by patsy.
#' @param X_env A DataFrame containing the environmental covariates. Dimensions
#' (n_sites, n_env_covariates).
#' @param X_checklist A DataFrame containing the observation
#' covariates. Dimensions (n_checklists, n_obs_covariates).
#' @param y_checklist A DataFrame specifying whether each species was or was not
#' observed for each visit (checklist). Dimensions (n_checklists, n_species).
#' @param checklist_cell_ids A vector specifying which site (aka cell) each
#' checklist belongs to. E.g. if checklist_cell_ids[2] = 3, the second checklist
#' was made at site 3. Note that sites are number from 0, so this would be the
#' _fourth_ site!
#' @param M The number of fixed draws to use in the variational
#' approximations. Should be set as large as possible, though M > 100 is
#' unlikely to change results.
#' @param n_draws The number of draws to make from the approximate posterior.
#' @param verbose Whether or not to print the progress of the optimisation.
#'
#' @return The fitted msod_advi object.
#'
#' @export
msod_vi <- function(env_formula, obs_formula, X_env, X_checklist, y_checklist,
                    checklist_cell_ids, M = 20L, n_draws = 1000L,
                    verbose = TRUE) {

    # Instantiate the python object
    model_obj <- occu_py$multi_species_occu_advi$MultiSpeciesOccuADVI(
        env_formula, obs_formula, M, n_draws, verbose)

                                        # Fit the model
    model_obj$fit(X_env, X_checklist, y_checklist, checklist_cell_ids)

    draw_dfs <- model_obj$get_draw_dfs()

    result <- list(python_model = model_obj, draws = draw_dfs)

    class(result) <- 'msod_advi'

    result

}

#' Predict using MSOD model
#'
#' Predicts the probability that a site is suitable, or that a species is
#' detected, given environmental and detection covariates.
#'
#' @param obj The fitted MSOD model.
#' @param X_env_new The new environmental covariates to predict suitability for.
#' @param X_obs_new The new observation covariates to use for prediction. Can be
#'     NULL if only environmental suitability is of interest.
#' @param type The type of prediction to make. If type = 'env', the probability
#'     of presence is returned, and X_obs_new can be NULL. If type = 'obs', the
#'     probability of detection is returned (i.e., species is present _and_
#'     detected), and X_obs_new must be provided.
#'
#' @return A DataFrame with one column for each species, filled with the
#'     predicted probabilities.
#' 
#' @export
#' @method predict msod_advi
predict.msod_advi <- function(obj, X_env_new, X_obs_new = NULL, type = 'env')
{

    if (is.null(X_obs_new)) {
        stopifnot(type == 'env')
    }

    if (type == 'env') {
        env_preds <- obj$python_model$predict_marginal_probabilities_direct(
            X_env_new)
        return(env_preds)
    } else {
        obs_preds <- obj$python_model$predict_marginal_probabilities_obs(
            X_env_new, X_obs_new)
        return(obs_preds)
    }

} 

#' Retrieve draws for coefficients in MSOD model
#'
#' Returns draws of the estimated parameters.
#'
#' @param obj The fitted MSOD model.
#'
#' @return A list containing the following fields: (1) `env_intercepts`, a
#' DataFrame of draws of the suitability intercepts for each species; (2)
#' `env_slopes`, a list mapping from species names to DataFrames of draws for
#' each suitability covariate; (3) `obs_slopes`, a list mapping from species
#' names to DataFrames of draws for each observation covariate; (4)
#' obs_prior_means, draws from the group prior means estimated for the
#' observation process; (5) obs_prior_sds, draws from the group prior standard
#' deviations for the observation process.
#'
#' @export
#' @method coef msod_advi
coef.msod_advi <- function(obj) {

    draws <- obj$draws

    # Make sure these are R objects
    draws$env_intercepts <- py_to_r(draws$env_intercepts)

    draws$env_slopes <- lapply(draws$env_slopes, py_to_r)
    draws$obs_slopes <- lapply(draws$obs_slopes, py_to_r)

    draws$obs_prior_sds <- py_to_r(draws$obs_prior_sds)
    draws$obs_prior_means <- py_to_r(draws$obs_prior_means)

    draws

}

#' Save the fitted MSOD model to disk
#'
#' @param obj The fitted MSOD model object.
#' @param save_dir The folder to save the model to.
#' @export
save_model <- function(obj, save_dir) {

    obj$python_model$save_model(save_dir)

}

#' Restore the fitted MSOD model from disk
#'
#' @param save_dir The directory the MSOD model was saved to.
#' @export
restore_model <- function(save_dir) {

    python_model <- occu_py$multi_species_occu_advi$MultiSpeciesOccuADVI(NA, NA)
    python_model$restore_model(save_dir)

    draws <- python_model$get_draw_dfs()

    result <- list(python_model = python_model, draws = draws)

    class(result) <- 'msod_advi'

    result

}
