#' @export
occu_py <- NULL

#' @export
ml_tools <- NULL

#' @export
np <- NULL

#' @export
jax <- NULL 


.onLoad <- function(libname, pkgname) {

    occu_py <<- reticulate::import('occu_py', delay_load = TRUE)
    ml_tools <<- reticulate::import('ml_tools', delay_load = TRUE)
    np <<- reticulate::import('numpy', delay_load = TRUE)
    jax <<- reticulate::import('jax', delay_load = TRUE)

}

#' Installs the python requirements of the package.
#'
#' @param gpu Whether or not to install the GPU version of the package. Note
#' that using the GPU version is highly recommended.
#' 
#' @export
install_occu_py <- function(gpu = FALSE) {

    reticulate::py_install(
        "git+https://github.com/martiningram/ml_tools.git", pip=TRUE)
    reticulate::py_install(
        "git+https://github.com/martiningram/jax_advi.git", pip=TRUE)
    reticulate::py_install("scikit-learn", pip=TRUE)
    reticulate::py_install("matplotlib", pip=TRUE)
    reticulate::py_install("pandas", pip=TRUE)
    reticulate::py_install("arviz", pip=TRUE)
    reticulate::py_install("patsy", pip=TRUE)
    reticulate::py_install("tqdm", pip=TRUE)
    reticulate::py_install('git+https://github.com/martiningram/occu_py.git', pip=TRUE)

    if (gpu) {
        
        # reticulate::py_install(
        #     "jax==0.2.8 jaxlib==0.1.57+cuda101 -f https://storage.googleapis.com/jax-releases/jax_releases.html", 
        #     pip=TRUE)
	# TODO: Test this on a GPU machine
        reticulate::py_install("jax[cuda]==0.3.14 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html", pip=TRUE)


    } else {

        reticulate::py_install("jax[cpu]==0.3.14", pip=TRUE)
        reticulate::py_install("jaxlib==0.3.14", pip=TRUE)

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
        jax$config$update('jax_platform_name', 'gpu')
    } else {
        jax$config$update('jax_platform_name', 'cpu')
    }

}
