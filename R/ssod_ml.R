#' Fit SSOD model
#'
#' Fits a single-species occupancy detection (SSOD) model using maximum
#' likelihood.
#'
#' @param env_formula Formula to use for the environment / suitability part of
#'     the model. Should be a string compatible with the patsy python package.
#' @param obs_formula Formula to use for the observation / detection part of the
#'     model. Again, should be supported by patsy.
#' @param X_env A DataFrame containing the environmental covariates. Dimensions
#'     (n_sites, n_env_covariates).
#' @param X_checklist A DataFrame containing the observation
#'     covariates. Dimensions (n_checklists, n_obs_covariates).
#' @param y_checklist A DataFrame specifying whether each species was or was not
#'     observed for each visit (checklist). As this is a single-species model,
#'     it must have only a single column, ideally named after the species of
#'     interest.
#' @param checklist_cell_ids A vector specifying which site (aka cell) each
#'     checklist belongs to. E.g. if checklist_cell_ids[2] = 3, the second
#'     checklist was made at site 3. Note that sites are number from 0, so this
#'     this would be the _fourth_ site -- i.e. the one whose environmental
#'     variables are in X_env[4, ] using R indexing!
#'
#' @return The fitted ssod_maxlik object.
#' 
#' @export
ssod_ml <- function(env_formula, obs_formula, X_env, X_checklist, y_checklist,
                    checklist_cell_ids) {

    stopifnot(dim(y_checklist)[2] == 1)

    cur_py_obj <- occu_py$max_lik_occu$MaxLikOccu(env_formula, obs_formula)

    cur_py_obj$fit(X_env, X_checklist, y_checklist,
                   reticulate::np_array(checklist_cell_ids, dtype="int64"))

    cur_result <- list(python_obj=cur_py_obj)
    
    class(cur_result) <- 'ssod_maxlik'

    cur_result

}

#' Extract coefficients of fitted SSOD model
#'
#' @param obj The fitted SSOD model.
#'
#' @return A list with two names: `env_coefs`, containing the coefficients
#' driving suitability (often referred to by the Greek letter Psi), and
#' `obs_coefs`, containing the coefficients driving observation.
#'
#' @export
#' @method coef ssod_maxlik
coef.ssod_maxlik <- function(obj) {

    env_coefs <- obj$python_obj$fit_results[[1]]$env_coefs
    obs_coefs <- obj$python_obj$fit_results[[1]]$obs_coefs

    list(env_coefs=reticulate::py_to_r(env_coefs),
         obs_coefs=reticulate::py_to_r(obs_coefs))

}

#' Summarise the SSOD model
#'
#' @param obj The fitted SSOD model
#'
#' @return Nothing, but prints the coefficients and the gradient norm at the
#' optimum. If the gradient norm is large, this may signal lack of
#' convergence. Ideally, it should be as close to zero as possible.
#'
#' @export
#' @method summary ssod_maxlik
summary.ssod_maxlik <- function(obj) {

    final_grad_norm <- sqrt(sum(obj$opt_result$jac)^2)
    print(paste0('Optimisation finished with final gradient norm of ', 
                 final_grad_norm))

    print('The estimated coefficients are:')
    print(coef(obj))

}

#' Predict using SSOD model
#'
#' Predicts the probability that a site is suitable, or that a species is
#' detected, given environmental and detection covariates.
#'
#' @param obj The fitted SSOD model.
#' @param X_env_new The new environmental covariates to predict suitability for.
#' @param X_obs_new The new observation covariates to use for prediction. Can be
#'     NULL if only environmental suitability is of interest.
#' @param type The type of prediction to make. If type = 'env', the probability
#'     of presence is returned, and X_obs_new can be NULL. If type = 'obs', the
#'     probability of detection is returned (i.e., species is present _and_
#'     detected), and X_obs_new must be provided.
#'
#' @return A DataFrame with one column, filled with the predicted probabilities.
#' 
#' @export
#' @method predict ssod_maxlik
predict.ssod_maxlik <- function(obj, X_env_new, X_obs_new = NULL, type = 'env')
{

    cur_py_obj <- obj$python_obj

    if (is.null(X_obs_new)) {
        stopifnot(type == 'env')
    }

    if (type == 'env') {
        env_preds <- cur_py_obj$predict_marginal_probabilities_direct(X_env_new)
        return(env_preds)
    } else {
        obs_preds <- cur_py_obj$predict_marginal_probabilities_obs(
            X_env_new, X_obs_new)
        return(obs_preds)
    }

}
