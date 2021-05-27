test_that("fitting works", {
  
  data(eBird)
  
  X_checklist <- eBird$X_checklist
  y <- eBird$y_checklist[, c('Antrostomus vociferus', 'Calypte anna'), drop=FALSE]
  X_env <- eBird$X_env
  ids <- eBird$checklist_cell_ids
  
  to_use_env <- c('bio1', 'bio2')
  to_use_obs <- c('log_duration')
  
  env_formula <- 'bio1 + bio2'
  obs_formula <- 'log_duration'
  
  X_env_to_use <- data.frame(scale(X_env[, to_use_env]))
  
  result <- msod_vi(env_formula, obs_formula, X_env_to_use, 
                    X_checklist[, to_use_obs, drop=FALSE], y, ids, M=100L,
                    verbose=FALSE)
  
  coef_draws <- coef(result)
  
  # Check a few of these against what is expected
  intercept_mean_expected <- -1.389902
  intercept_mean_actual <- colMeans(coef_draws$env_intercepts)['Antrostomus vociferus']
  expect_true(abs(intercept_mean_expected - intercept_mean_actual) < 1e-2)
  
  obs_slope_expected <- 0.6327933
  obs_slope_means <- lapply(coef_draws$obs_slopes, colMeans)
  obs_slope_actual <- obs_slope_means$`Calypte anna`['log_duration']
  
  expect_true(abs(obs_slope_actual - obs_slope_expected) < 1e-2)
  
})



test_that("predictions are reasonable", {
  
  data(eBird)
  
  X_checklist <- eBird$X_checklist
  y <- eBird$y_checklist[, c('Antrostomus vociferus', 'Calypte anna'), drop=FALSE]
  X_env <- eBird$X_env
  ids <- eBird$checklist_cell_ids
  
  to_use_env <- c('bio1', 'bio2')
  to_use_obs <- c('log_duration')
  
  env_formula <- 'bio1 + bio2'
  obs_formula <- 'log_duration'
  
  X_env_to_use <- data.frame(scale(X_env[, to_use_env]))
  
  result <- msod_vi(env_formula, obs_formula, X_env_to_use, 
                    X_checklist[, to_use_obs, drop=FALSE], y, ids, M=20L, 
                    verbose=FALSE)
  
  X_env_to_pred <- X_env_to_use[ids + 1, ] 
  X_obs_to_pred <- X_checklist
  
  pred_probs_env <- predict(result, X_env_to_pred, type='env')
  pred_probs_obs <- predict(result, X_env_to_pred, X_obs_to_pred, type='obs')
  
  # The probabilities of presence should all be greater or equal to the
  # probability of observing the species:
  expect_true(all(pred_probs_env >= pred_probs_obs)) 
  
  # Also make sure saving and restoring works as expected:
  save_model(result, 'saved_model')
  restored <- restore_model('saved_model')
  
  obs_preds_new <- predict(restored, X_env_to_pred, X_obs_to_pred, type='obs')
  
  expect_true(all(obs_preds_new == pred_probs_obs))
  
})
