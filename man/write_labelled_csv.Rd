% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_labelled.R
\name{write_labelled_csv}
\alias{write_labelled_csv}
\alias{write_labelled_csv2}
\alias{write_labelled_tab}
\alias{write_labelled_tab2}
\alias{write_labelled_xlsx}
\alias{write_labelled_fst}
\alias{read_labelled_csv}
\alias{read_labelled_csv2}
\alias{read_labelled_tab}
\alias{read_labelled_tab2}
\alias{read_labelled_xlsx}
\alias{read_labelled_fst}
\alias{write_labelled_spss}
\alias{write_labels_spss}
\alias{write_labels}
\alias{create_dictionary}
\alias{apply_dictionary}
\alias{old_write_labelled_csv}
\alias{old_read_labelled_csv}
\title{Write labelled data to file or export file to SPSS syntax.}
\usage{
write_labelled_csv(
  x,
  filename,
  remove_new_lines = TRUE,
  single_file = TRUE,
  ...
)

write_labelled_csv2(
  x,
  filename,
  remove_new_lines = TRUE,
  single_file = TRUE,
  ...
)

write_labelled_tab(
  x,
  filename,
  remove_new_lines = TRUE,
  single_file = TRUE,
  ...
)

write_labelled_tab2(
  x,
  filename,
  remove_new_lines = TRUE,
  single_file = TRUE,
  ...
)

write_labelled_xlsx(
  x,
  filename,
  data_sheet = "data",
  dict_sheet = "dictionary",
  remove_repeated = FALSE,
  use_references = TRUE
)

write_labelled_fst(x, filename, ...)

read_labelled_csv(filename, undouble_quotes = TRUE, ...)

read_labelled_csv2(filename, undouble_quotes = TRUE, ...)

read_labelled_tab(filename, undouble_quotes = TRUE, ...)

read_labelled_tab2(filename, undouble_quotes = TRUE, ...)

read_labelled_xlsx(filename, data_sheet = 1, dict_sheet = "dictionary")

read_labelled_fst(filename, ...)

write_labelled_spss(
  x,
  filename,
  fileEncoding = "",
  remove_new_lines = TRUE,
  ...
)

write_labels_spss(x, filename)

write_labels(x, filename, fileEncoding = "")

create_dictionary(x, remove_repeated = FALSE, use_references = TRUE)

apply_dictionary(x, dict)

old_write_labelled_csv(
  x,
  filename,
  fileEncoding = "",
  remove_new_lines = TRUE,
  ...
)

old_read_labelled_csv(filename, fileEncoding = "", undouble_quotes = TRUE, ...)
}
\arguments{
\item{x}{data.frame to be written/data.frame whose labels to be written}

\item{filename}{the name of the file which the data are to be read from/write to.}

\item{remove_new_lines}{A logical indicating should we replace new lines with spaces in
the character variables. TRUE by default.}

\item{single_file}{logical. TRUE by default. Should we write labels into the
same file as data? If it is FALSE dictionary will be written in the
separate file.}

\item{...}{additional arguments for
\link[data.table]{fwrite}/\link[data.table]{fread}, e. g. column separator,
decimal separator, encoding and etc.}

\item{data_sheet}{character "data" by default. Where data will be placed in the '*.xlsx' file.}

\item{dict_sheet}{character "dictionary" by default. Where dictionary will be placed in the '*.xlsx' file.}

\item{remove_repeated}{logical. FALSE by default. If TRUE then we remove
repeated variable names. It makes a dictionary to look nicer for humans but
less convenient for usage.}

\item{use_references}{logical. When TRUE (default) then if the variable has
the same value labels as the previous variable, we use reference to this
variable. It makes dictionary significantly more compact for datasets
with many variables with the same value labels.}

\item{undouble_quotes}{A logical indicating should we undouble quotes which
were escaped by doubling. TRUE by default. Argument
will be removed when data.table issue #1109 will be fixed.}

\item{fileEncoding}{character string: if non-empty declares the encoding to 
be used on a file (not a connection) so the character data can be 
re-encoded as they are written. Used for writing dictionary. See
\link[base:connections]{file}.}

\item{dict}{data.frame with labels - a result of \code{create_dictionary}.}
}
\value{
Functions for writing invisibly return NULL. Functions for reading
  return labelled data.frame.
}
\description{
\itemize{
\item{\code{write_labelled_csv} and \code{read_labelled_csv}}{ writes csv
file with labels. By default labels are stored in the commented lines at the
beginning of the file before the data part. \code{*_csv2} write and read data
with a semicolon separator and comma as decimal delimiter. \code{*_tab/*_tab2}
write and read data with 'tab' separator and "."/"," as decimal delimiter. }
\item{\code{write_labelled_xlsx} and \code{read_labelled_xlsx}}{ write and
read labelled 'xlsx' format. It is a simple Excel file with data and labels on
separate sheets. It can help you with labelled data exchange in the
corporate environment.}
\item{\code{write_labelled_fst} and \code{read_labelled_fst}}{ write and read
labelled data in the 'fst' format. See \href{https://www.fstpackage.org/}{Fst Package}.
Data and labels are stored in the separate files. With 'fst' format you can
read and write a huge amount of data very quickly.}
\item{write_labelled_spss}{ write 'csv' file with SPSS syntax for reading it.
You can use it for the data exchange with SPSS.}
\item{\code{create_dictionary} and \code{apply_dictionary}}{ make data.frame
with dictionary, e. g. variable and value labels for each variable. See
format description in the 'Details' section.}
\item{\code{write_labels} and \code{write_labels_spss}}{ Write R code and
SPSS syntax for labelling data. It allows to extract labels from *.sav files
that come without accompanying syntax. }
\item{\code{old_write_labelled_csv} and \code{old_read_labelled_csv}}{ Read
and write labelled 'csv' in format of the 'expss' version before 0.9.0.
}
}
}
\details{
Dictionary is a data.frame with the following columns:
\itemize{
\item{variable}{ variable name in the data set. It can be omitted
(\code{NA}). In this case name from the previous row will be taken.}
\item{value}{ code for label in the column \code{'label'}.}
\item{label}{ in most cases it is value label but its meaning can be changed
by the column \code{'meta'}.}
\item{meta}{ if it is NA then we have value label in the \code{'label'}
column. If it is \code{'varlab'}, then there is a variable label in the
\code{'label'} column and column \code{'value'} is ignored. If it is
\code{'reference'}, then there is a variable name in the \code{'label'}
column and we use value labels from this variable, column \code{'value'} is
ignored.}
}
}
\examples{
\dontrun{
data(mtcars)
mtcars = mtcars \%>\% 
    apply_labels(
        mpg = "Miles/(US) gallon",
        cyl = "Number of cylinders",
        disp = "Displacement (cu.in.)",
        hp = "Gross horsepower",
        drat = "Rear axle ratio",
        wt = "Weight (lb/1000)",
        qsec = "1/4 mile time",
        vs = "Engine",
        vs = c("V-engine" = 0, 
                "Straight engine" = 1),
        am = "Transmission",
        am = c(automatic = 0, 
                manual=1),
        gear = "Number of forward gears",
        carb = "Number of carburetors"
    )

write_labelled_csv(mtcars, "mtcars.csv")
new_mtcars = read_labelled_csv("mtcars.csv")
str(new_mtcars)

# identically, for xlsx
write_labelled_xlsx(mtcars, "mtcars.xlsx")
new_mtcars = read_labelled_xlsx("mtcars.xlsx")
str(new_mtcars)

# to SPSS syntax
write_labelled_spss(mtcars, "mtcars.csv")

}
}
