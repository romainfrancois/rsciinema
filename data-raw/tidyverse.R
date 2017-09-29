library(tidyverse)
library(devtools)

tidyverse <- tidyverse_packages()

packages <- as_tibble(installed.packages())

base <- packages %>%
  filter(Priority == "base") %>%
  pull(Package)

recommended <- packages %>%
  filter(Priority == "recommended") %>%
  pull(Package)

use_data(base, recommended, tidyverse, internal = TRUE, overwrite = TRUE)


