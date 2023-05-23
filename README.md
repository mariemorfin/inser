
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {inser}

<!-- badges: start -->

[![R-CMD-check](https://github.com/ThinkR-open/inser/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ThinkR-open/inser/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The {inser} package generates a synthetic sheet of fishing gear
selectivity indicators from catch comparison data. These data can be
obtained from three types of experimental protocols: ‘twin’, ‘single
paired’ or ‘independent’ sampling for which a test gear is compared to a
standard gear.

## Installation

In order to install the package you first need to create a gitlab token.

Go to User Settings \> Access Tokens.

Give your token an explicit name.

Choose no expiration date.

Choose `api` as scope.

Save your token in your .Renviron file. (`usethis::edit_r_environ()`)
like so:

    FORGE_THINKR_TOKEN=<put your gitlab token here>

Then run this code:

``` r
install.packages(c("git2r", "remotes"))

options(
  remotes.git_credentials = git2r::cred_user_pass(
    username = "gitlab-ci-token", 
    password = Sys.getenv("FORGE_THINKR_TOKEN")
  )
)

remotes::install_git(
  url = "https://forge.thinkr.fr/ifremer-lorient/inser/",
  upgrade = FALSE,
  dependencies = TRUE,
  build_vignettes = TRUE
)
```

## Package Documentation

The package documentation website can be found here:
<https://ifremer-lorient.pages.thinkr.fr/inser/>
