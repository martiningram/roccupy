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

## How to use

The main function in the package is `msod_vi`, which fits the model. It returns
a model fit object that can be used together with `predict` to predict
probabilities at new sites / checklists and `coef`, which returns draws of the
estimated coefficients. The arguments of these functions are documented.

There is also a vignette called `ebird-example` which walks through fitting a
model to a subset of eBird. Note that it is fast to build if a GPU is available
(less than a minute), but considerably slower if not (about 20 minutes), so
patience is advised if no GPU is available.
