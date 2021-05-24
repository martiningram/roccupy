#' @export
occu_py <- NULL

#' @export
ml_tools <- NULL

#' @export
numpyro <- NULL

.onLoad <- function(libname, pkgname) {

    occu_py <<- reticulate::import('occu_py', delay_load = TRUE)
    ml_tools <<- reticulate::import('ml_tools', delay_load = TRUE)
    numpyro <<- reticulate::import('numpyro', delay_load = TRUE)

}

#' Installs the python requirements of the package.
#'
#' @param gpu Whether or not to install the GPU version of the package. Note
#' that using the GPU version is highly recommended.
#' 
#' @export
install_occu_py <- function(gpu = TRUE) {

    reticulate::py_install("git+https://github.com/martiningram/ml_tools.git", pip=TRUE)
    reticulate::py_install("git+https://github.com/martiningram/jax_advi.git", pip=TRUE)
    reticulate::py_install("git+https://github.com/pyro-ppl/numpyro@8bb94f170de3f6c276fe61e4c92cd4e21de70a4b", pip=TRUE)
    reticulate::py_install("scikit-learn", pip=TRUE)
    reticulate::py_install("matplotlib", pip=TRUE)
    reticulate::py_install("pandas", pip=TRUE)
    reticulate::py_install("arviz", pip=TRUE)
    reticulate::py_install("patsy", pip=TRUE)
    reticulate::py_install("'pystan<3'", pip=TRUE)

    if (gpu) {
        
        reticulate::py_install("jax==0.2.8 jaxlib==0.1.57+cuda101 -f https://storage.googleapis.com/jax-releases/jax_releases.html", pip=TRUE)

    } else {

        reticulate::py_install("jax==0.2.8 jaxlib==0.1.57", pip=TRUE)

    }

}

#' Set whether to use the GPU or not
#'
#' If use of a GPU is desired (and this is highly recommended), this function
#' must be called at the start of the program.
#'
#' @param use_gpu Whether or not to use the GPU.
#' 
#' @export
set_gpu <- function(use_gpu = TRUE) {

    if (use_gpu) {
        numpyro$set_platform('gpu')
    } else {
        numpyro$set_platform('cpu')
    }

}
