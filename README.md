
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {inser}

<!-- badges: start -->

[![pipeline
status](https://forge.thinkr.fr/ifremer-lorient/inser/badges/main/pipeline.svg)](https://forge.thinkr.fr/ifremer-lorient/inser/-/commits/main)
[![coverage
report](https://forge.thinkr.fr/ifremer-lorient/inser/badges/main/coverage.svg)](http://ifremer-lorient.pages.thinkr.fr/inser/coverage.html)
<!-- badges: end -->

The goal of {inser} is to automate the production of selectivity notes.

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

remotes::install_git("https://forge.thinkr.fr/ifremer-lorient/inser/")
```

## Package Documentation

The package documentation website can be found here:
<https://ifremer-lorient.pages.thinkr.fr/inser/>