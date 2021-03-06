% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_asciicast.R
\name{read_asciicast}
\alias{read_asciicast}
\title{read an asciicast file}
\usage{
read_asciicast(file)
}
\arguments{
\item{file}{asciicast file}
}
\value{
a tibble with columns time and text, and attributes
}
\description{
read an asciicast file
}
\examples{
\dontrun{
 read_asciicast( system.file("resources", "mapscii.json", package = "rsciinema") )
}

}
