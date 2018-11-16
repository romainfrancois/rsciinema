
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rsciinema

The goal of rsciinema is to provide an R analog to asciinema
<https://asciinema.org/> with the correct highlighting and output, with
bindings for Shiny and RMarkdown. \#\# Installation

You can install the released version of rsciinema from
[CRAN](https://CRAN.R-project.org) with:

``` r
remotes::install_github("romainfrancois/rsciinema")
```

## Example

This is a basic example of making an output scene:

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(rsciinema)
data = asciicast( "# a comment\niris %>% \n  dplyr::group_by(Species) %>%\n  dplyr::summarise_all(mean) \n # a new line" )
asciinema(data = data)
```

<img src="man/figures/README-example-1.png" width="100%" />

You can also write out the file

``` r
tfile = tempfile(fileext = ".cast")
write_asciicast(data, tfile)
asciinema( tfile )
```

<img src="man/figures/README-unnamed-chunk-1-1.png" width="100%" />
