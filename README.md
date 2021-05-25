# ROccuPy: Fast Multi-Species Occupancy Detection Modelling in R

This package wraps the code in
[OccuPy](https://github.com/martiningram/occu_py), which uses variational
inference to fit large multi-species occupancy detection models. It is intended
to provide easy usage of that package from R.

## How to install

To install the package, you can first install it from GitHub as any other R
package:

```R
devtools::install_github('https://github.com/martiningram/roccupy')
```

Once this is done, please load the package and install the python requirements
as follows:

```R
library(roccupy)

# Use TRUE if a GPU is available (highly recommended), and FALSE otherwise.
install_occu_py(gpu=TRUE)
```

Please note that this requires a working setup of `reticulate`. If you need help
setting that up, please follow the steps in [the reticulate
documentation](https://rstudio.github.io/reticulate/). If there are problems,
please raise an issue.

## How to use: Multi-species occupancy detection

The main function in the package is `msod_vi`, which fits the model. Here is an
example:

```R
fit_model <- msod_vi(env_formula = "bio1 + bio2",
                     obs_formula = "log_duration + daytime",
                     X_env = X_env,
                     X_checklist = X_checklist, 
                     y_checklist = y_checklist,
                     checklist_cell_ids = checklist_cell_ids)
```

Here, `env_formula` and `obs_formula` are formulas, which are likely
familiar. Note that these are `patsy` formulas, not standard R ones, so they may
not support all features. Please see the [patsy
documentation](https://patsy.readthedocs.io/en/latest/formulas.html) for more
details. Interactions and polynomial terms have been tested and should work;
more advanced features may work but have not been tested. For more information
about the other arguments, please see the package documentation.

This returns a model fit object that can be used together with `predict` to
predict probabilities at new sites / checklists and `coef`, which returns draws
of the estimated coefficients. The arguments of these functions are documented.

There is also a vignette called `ebird-example` which walks through fitting a
model to a subset of eBird (8,000 checklists, 32 species). Note that it is fast
to build if a GPU is available (less than a minute), but considerably slower if
not (about 20 minutes), so patience is advised if no GPU is available. The
vignette rendered in PDF format is also available here:
https://github.com/martiningram/roccupy/blob/main/vignettes/ebird-example.pdf .

Note that if you would like to build the vignette yourself, you will need the
`ggplot2`, `ggrepel` packages, as well as a working installation of LaTeX for
use with RMarkdown (e.g. tinytex).

## How to use: Single-species occupancy detection

This package also contains code to efficiently fit _single-species_ occupancy
detection models, making use of automatic differentiation. The code for this is
very similar:

```R
fit_model <- ssod_ml(env_formula = "bio1 + bio2",
                     obs_formula = "log_duration + daytime",
                     X_env = X_env,
                     X_checklist = X_checklist, 
                     y_checklist = y_checklist,
                     checklist_cell_ids = checklist_cell_ids)
```

The only difference to `msod_vi` is that here, `y_checklist` is expected to be a
DataFrame with a single column.

A vignette comparing the results of `ssod_ml` to those made by the package
`unmarked` is included. The vignette also discusses how to convert from the more
common "wide" format used by `unmarked` and other packages to the "long" format
used in `roccupy`. It should be quick to build regardless of whether or not a
GPU is available, but is also available here:
https://github.com/martiningram/roccupy/blob/main/vignettes/compare_with_unmarked.pdf

## Questions

If there are any problems, please raise an issue!
