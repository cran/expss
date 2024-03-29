#' Options for controlling behavior of the package
#'
#' All options can be set with \code{options(option.name = option.value)} or
#' with special functions (see below). You can get value of option with
#' \code{getOption("option.name").}
#' \itemize{
#' \item{\code{expss.digits} }{ Number of digits after decimal separator which
#' will be shown for tables. This parameter is supported in the
#' \link[expss]{as.datatable_widget}, \link[expss]{htmlTable.etable} and \code{print}
#' methods. \code{NULL} is default and means one digit. \code{NA} means no
#' rounding. There is a convenience function for this option:
#' \code{expss_digits}.}
#' \item{\code{expss.round_half_to_even} }{ Determines which rounding we will use.
#'  Default rounding is as with R \code{round}: "half to even". For rounding "half to largest" 
#'  set this option to FALSE. This parameter is supported in the \link[expss]{as.datatable_widget},
#'  \link[expss]{htmlTable.etable}, \code{print} and in significance testing
#' methods. \code{NULL} is default and means R default rounding. \code{NA} means no
#' rounding. Parameter does not affect calculations, only table representation. 
#' There is a convenience function for this option:
#' \code{expss_round_half_to_even}.}
#' \item{\code{expss.enable_value_labels_support} }{By default, all labelled
#' variables will use labels as labels for factor levels when \link{factor} is
#' called. So, any function which calls \link{factor}/\link{as.factor} will use
#' value labels. In details this option changes behavior of two methods for
#' class \code{labelled} - \code{as.character} and \code{unique} - on which
#' \code{factor} depends entirely. If you have compatibility problems set this
#' option to zero: \code{options(expss.enable_value_labels_support = 0)}.
#' Additionally there is an option for extreme value labels support:
#' \code{options(expss.enable_value_labels_support = 2)}. With this value
#' \code{factor}/\code{as.factor} will take into account empty levels. See
#' example. It is recommended to turn off this option immediately after usage
#' because \code{unique.labelled} will give weird result. Labels without values
#' will be added to unique values.  There are shortcuts for these options:
#' \code{expss_enable_value_labels_support()},
#' \code{expss_enable_value_labels_support_extreme()} and
#' \code{expss_disable_value_labels_support()}.}
#' \item{\code{expss.output} }{ By default tables are printed in the console.
#' You can change this behavior by setting this option. There are five possible
#' values: \code{'rnotebook'}, \code{'viewer'}, \code{'commented'},
#' \code{'raw'} or \code{'huxtable'}. First option is useful when you run your code in the R Notebook
#' - output will be rendered to nice HTML. The second option will render tables
#' to RStudio viewer. \code{knitr} is supported automatically via
#' \code{knit_print} method. \code{'commented'} prints default output to the
#' console with comment symbol (\code{#}) at the beginning of the each line.
#' With comment symbol you can easily copy and paste your output into the
#' script. Option \code{raw} disables any formatting and all tables are printed
#' as data.frames. Option \code{huxtable} print output via the huxtable library.
#' Shortcuts for options: \code{expss_output_default()},
#' \code{expss_output_raw()}, \code{expss_output_viewer()},
#' \code{expss_output_commented()}, \code{expss_output_rnotebook()} and
#' \code{expss_output_huxtable()}.}
#' \item{\code{expss_fix_encoding_on}/\code{expss_fix_encoding_off} }{ If you
#' expreience problems with character encoding in RStudio Viewer/RNotebooks under Windows
#' try \code{expss_fix_encoding_on()}. In some cases, it can help.}
#' }
#'
#' @param digits integer. Number of digits after decimal point. \code{NULL} is
#'   default and means 1 digit. \code{NA} means no rounding.
#' @param round_half_to_even logical. Default is TRUE which means
#'  default R rounding: "half to even". For rounding "half to largest" 
#'  set this option to FALSE.
#' @param ... list of parameters for \code{huxtable::set_default_properties}.
#'   See \link[huxtable]{set_default_properties}.
#' @param label character vector of length 5. Default labels for \link{fre}.
#' @name expss.options
#' @examples
#'
#' # example of different levels of value labels support
#' my_scale = c(1, 2, 2, 2)
#' # note that we have label 'Hard to say' for which there are no values in 'my_scale'
#' val_lab(my_scale) = num_lab("
#'                             1 Yes
#'                             2 No
#'                             3 Hard to say
#'                             ")
#' # disable labels support
#' expss_disable_value_labels_support()
#' table(my_scale) # there is no labels in the result
#' unique(my_scale)
#' # default value labels support
#' expss_enable_value_labels_support()
#' # table with labels but there are no label "Hard to say"
#' table(my_scale)
#' unique(my_scale)
#' # extreme value labels support
#' expss_enable_value_labels_support_extreme()
#' # now we see "Hard to say" with zero counts
#' table(my_scale)
#' # weird 'unique'! There is a value 3 which is absent in 'my_scale'
#' unique(my_scale)
#' # return immediately to defaults to avoid issues
#' expss_enable_value_labels_support()
#' @rdname expss.options
#' @export
expss_digits = function(digits = NULL){
    options(expss.digits = digits)
}


#' @rdname expss.options
#' @export
get_expss_digits = function(){
    digits = getOption("expss.digits")
    digits = if_null(digits, 1)
    digits
}

#' @rdname expss.options
#' @export
expss_round_half_to_even = function(round_half_to_even = TRUE){
    options(expss.round_half_to_even = round_half_to_even)
}


#' @rdname expss.options
#' @export
get_expss_rounding = function(){
    rounding = getOption("expss.round_half_to_even")
    rounding = if_null(rounding, TRUE)
    rounding
}



#' @rdname expss.options
#' @export
expss_enable_value_labels_support = function(){
    options(expss.enable_value_labels_support = NULL)
}

#' @rdname expss.options
#' @export
expss_enable_value_labels_support_extreme = function(){
    options(expss.enable_value_labels_support = 2)
}

#' @rdname expss.options
#' @export
expss_disable_value_labels_support = function(){
    options(expss.enable_value_labels_support = 0)
}

#' @rdname expss.options
#' @export
expss_output_default = function(){
    options(expss.output = "")
}

#' @rdname expss.options
#' @export
expss_output_commented = function(){
    options(expss.output = "commented")
}

#' @rdname expss.options
#' @export
expss_output_raw = function(){
    options(expss.output = "raw")
}

#' @rdname expss.options
#' @export
expss_output_viewer = function(){
    options(expss.output = "viewer")
}

#' @rdname expss.options
#' @export
expss_output_rnotebook = function(){
    options(expss.output = "rnotebook")
}


#' @rdname expss.options
#' @export
expss_output_huxtable = function(...){
    requireNamespace("huxtable", quietly = TRUE) ||
        stop("'expss_output_huxtable': 'huxtable' package is required for this function. Please, install it with 'install.packages('huxtable')'.")
    huxtable::set_default_properties(border =  1)
    if(length(list(...))>0) huxtable::set_default_properties(...)
    options(expss.output = "huxtable")
}

#' @rdname expss.options
#' @export
expss_fix_encoding_on = function(){
    options(expss.fix_encoding = TRUE)
}

#' @rdname expss.options
#' @export
expss_fix_encoding_off = function(){
    options(expss.fix_encoding = NULL)
}

#' @rdname expss.options
#' @export
expss_fre_stat_lab = function(label = c("Count", "Valid percent", "Percent", "Responses, %", "Cumulative responses, %")){
    options(expss.fre_stat_lab = label)
}
