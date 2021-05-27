test_that("fitting works", {
  
  data(eBird)
  
  X_checklist <- eBird$X_checklist
  y <- eBird$y_checklist[, c('Antrostomus vociferus'), drop=FALSE]
  X_env <- eBird$X_env
  ids <- eBird$checklist_cell_ids
  
  to_use_env <- c('bio1', 'bio2')
  to_use_obs <- c('log_duration')
  
  env_formula <- 'bio1 + bio2'
  obs_formula <- 'log_duration'
  
  X_env_to_use <- data.frame(scale(X_env[, to_use_env]))
  
  result <- ssod_ml(env_formula, obs_formula, X_env_to_use, 
                    X_checklist[, to_use_obs, drop=FALSE], y, ids)
  
  coefs <- coef(result)
  
  target_env_coefs <- c(-2.7550364, -0.4214421, -0.1897166)
  target_obs_coefs <- c(-1.4173224, -0.3063458)
  
  # Check that summary runs:
  summary(result)
  
  # These should be close to the following:
  env_coefs_as_expected <- sum((coefs$env - target_env_coefs)^2) < 1e-3
  obs_coefs_as_expected <- sum((coefs$obs - target_obs_coefs)^2) < 1e-3
  
  expect_true(env_coefs_as_expected)
  expect_true(obs_coefs_as_expected)
  
})


test_that("predictions make sense", {
  
  # TODO: It might be nice to put this shared code into a 
  # separate function somehow.
  data(eBird)
  
  X_checklist <- eBird$X_checklist
  y <- eBird$y_checklist[, c('Antrostomus vociferus'), drop=FALSE]
  X_env <- eBird$X_env
  ids <- eBird$checklist_cell_ids
  
  to_use_env <- c('bio1', 'bio2')
  to_use_obs <- c('log_duration')
  
  env_formula <- 'bio1 + bio2'
  obs_formula <- 'log_duration'
  
  X_env_to_use <- data.frame(scale(X_env[, to_use_env]))
  
  result <- ssod_ml(env_formula, obs_formula, X_env_to_use, 
                    X_checklist[, to_use_obs, drop=FALSE], y, ids)
  
  # Actual test:
  X_env_to_pred <- X_env_to_use[ids + 1, ] 
  X_obs_to_pred <- X_checklist
  
  pred_probs_env <- predict(result, X_env_to_pred, type='env')
  pred_probs_obs <- predict(result, X_env_to_pred, X_obs_to_pred, type='obs')
  
  # The probabilities of presence should all be greater or equal to the
  # probability of observing the species:
  expect_true(all(pred_probs_env >= pred_probs_obs))
  
})