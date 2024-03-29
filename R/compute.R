#' Modify data.frame/modify subset of the data.frame
#' 
#' \itemize{
#' \item{\code{compute}}{ evaluates expression \code{expr} in the context of data.frame 
#' \code{data} and return original data possibly modified.}
#' \item{\code{calculate}}{ evaluates expression \code{expr} in the context of 
#' data.frame \code{data} and return value of the evaluated expression. Function \code{use_labels} is shortcut for \code{calculate} with
#' argument \code{use_labels} set to \code{TRUE}. When \code{use_labels} is TRUE
#' there is a special shortcut for entire data.frame - \code{..data}.}
#' \item{\code{do_if}}{ modifies only rows for which \code{cond} equals to
#' TRUE. Other rows remain unchanged. Newly created variables also will have
#' values only in rows for which \code{cond} have TRUE. There will be NA's in
#' other rows. This function tries to mimic SPSS "DO IF(). ... END IF."
#' statement.}
#' }
#' Full-featured \code{\%to\%} is available in the expressions for addressing
#' range of variables.
#' There is a special constant \code{.N} which equals to number of cases in 
#' \code{data} for usage in expression inside \code{compute}/\code{calculate}. 
#' Inside \code{do_if} \code{.N} gives number of rows which will be affected by 
#' expressions. For parametrization (variable substitution) see \link{..} or 
#' examples. Sometimes it is useful to create new empty variable inside compute.
#' You can use \code{.new_var} function for this task. This function creates
#' variable of length \code{.N} filled with NA. See examples.
#' \code{modify} is an alias for \code{compute}, \code{modify_if} is
#' an alias for \code{do_if} and \code{calc} is an alias for \code{calculate}.
#' 
#' @param data data.frame/list of data.frames. If \code{data} is list of
#'   data.frames then expression \code{expr} will be evaluated inside each
#'   data.frame separately.
#' @param ... expressions that should be evaluated in the context of data.frame
#'   \code{data}. It can be arbitrary code in curly brackets or assignments. See
#'   examples.
#' @param expr expression that should be evaluated in the context of data.frame \code{data}
#' @param cond logical vector or expression. Expression will be evaluated in the context of the data.  
#' @param use_labels logical. Experimental feature. If it equals to \code{TRUE} 
#'   then we will try to replace variable names with labels. So many base R
#'   functions which show variable names will show labels.
#'
#' @return \code{compute} and \code{do_if} functions return modified 
#'   data.frame/list of modified data.frames, \code{calculate} returns value of
#'   the evaluated expression/list of values.
#' @examples
#' 
#' dfs = data.frame(
#'     test = 1:5,
#'     a = rep(10, 5),
#'     b_1 = rep(11, 5),
#'     b_2 = rep(12, 5),
#'     b_3 = rep(13, 5),
#'     b_4 = rep(14, 5),
#'     b_5 = rep(15, 5) 
#' )
#' 
#' 
#' # compute sum of b* variables and attach it to 'dfs'
#' let(dfs, 
#'     b_total = sum_row(b_1 %to% b_5),
#'     b_total = set_var_lab(b_total, "Sum of b"),
#'     random_numbers = runif(.N) # .N usage
#' ) %>% print()
#' 
#' # calculate sum of b* variables and return it
#' query(dfs, sum_row(b_1 %to% b_5))
#' 
#' 
#' # set values to existing/new variables
#' let(dfs, 
#'     columns('new_b{1:5}') := b_1 %to% b_5
#' ) %>% print()
#' 
#' 
#' # conditional modification
#' let_if(dfs, test %in% 2:4, 
#'     a = a + 1,    
#'     b_total = sum_row(b_1 %to% b_5),
#'     random_numbers = runif(.N) # .N usage
#' ) %>% print()
#' 
#' 
#' # variable substitution
#' name1 = "a"
#' name2 = "new_var"
#' 
#' let(dfs, 
#'      (name2) := get(name1)*2    
#' ) %>% print()
#' 
#' 
#' # 'use_labels' examples. Utilization of labels in base R.
#' data(mtcars)
#' mtcars = apply_labels(mtcars,
#'                       mpg = "Miles/(US) gallon",
#'                       cyl = "Number of cylinders",
#'                       disp = "Displacement (cu.in.)",
#'                       hp = "Gross horsepower",
#'                       drat = "Rear axle ratio",
#'                       wt = "Weight (lb/1000)",
#'                       qsec = "1/4 mile time",
#'                       vs = "Engine",
#'                       vs = c("V-engine" = 0,
#'                              "Straight engine" = 1),
#'                       am = "Transmission",
#'                       am = c("Automatic" = 0,
#'                              "Manual"=1),
#'                       gear = "Number of forward gears",
#'                       carb = "Number of carburetors"
#' )
#' 
#' use_labels(mtcars, table(am, vs))
#' 
#' \dontrun{
#' use_labels(mtcars, plot(mpg, hp))
#' }
#' 
#' mtcars %>% 
#'        use_labels(lm(mpg ~ disp + hp + wt)) %>% 
#'        summary()
#' 
#' @export
compute =  function (data, ...) {
    .Deprecated(msg = "'compute'/'modify' is deprecated and will be removed in the next version. Please, use 'let' from maditr package.")
    UseMethod("compute")
}

#' @export
compute.list = function (data, ...) {

    for(each in seq_along(data)){
        data[[each]] = eval.parent(substitute(compute(data[[each]], ...)))
    }
    data
}

#' @export
compute.data.frame = function (data, ...) {
    # based on 'within' from base R by R Core team
    dots = substitute(list(...))
    dots = get_named_expressions(dots)
    e = evalq(environment(), data, parent.frame())
    prepare_env(e, n = nrow(data), column_names = colnames(data))
    for(i in seq_along(dots)){
        curr_name = names(dots)[i]
        expr = dots[[i]]
        if(curr_name != ""){
            curr_name = paste0("`", curr_name, "`")
            lhs_expr = parse(text = curr_name)
            expr = bquote(.(lhs_expr[[1]])<-.(expr))
        }
        eval(expr, envir = e, enclos = baseenv())
    }
    clear_env(e)
    l = as.list(e, all.names = TRUE)
    l = l[!vapply(l, is.null, NA, USE.NAMES = FALSE)]
    del = setdiff(names(data), names(l))
    if(length(del)){
        data[, del] = NULL
    }
    nrows = vapply(l, NROW, 1, USE.NAMES = FALSE)
    wrong_rows = nrows!=1L & nrows!=nrow(data)
    if(any(wrong_rows)){
        er_message = utils::head(paste0("'", names(l)[wrong_rows], "' has ", nrows[wrong_rows], " rows"), 5)
        er_message = paste(er_message, collapse = ", ")
        stop(paste0("Bad number of rows: ", er_message, " instead of ", nrow(data), " rows."))
    }
    
    new_vars = rev(names(l)[!(names(l) %in% names(data))])
    nl = c(names(data), new_vars)
    data[nl] = l[nl]
    data
}


#' @export
compute.data.table = function (data, ...) {
    dots = substitute(list(...))
    dots = get_named_expressions(dots)
    e = evalq(environment(), list(), parent.frame())
    orig_names = colnames(data)
    prepare_env(e, n = nrow(data), column_names = orig_names)
    binding = function(var_name){
        var_name
        function(v) {
            if (missing(v)){
                return(data[[var_name]])
            } else {
                data.table::set(data, j = var_name, value = v)
            }
            invisible(v)
        }
    }
    for(j in names(data)){
        makeActiveBinding(j, binding(j), e)
    }
    for(i in seq_along(dots)){
        curr_name = names(dots)[i]
        expr = dots[[i]]
        if(curr_name != ""){
            lhs_expr = parse(text = curr_name)
            if(length(lhs_expr)!=1){
                stop(paste0("'compute': incorrect expression '", curr_name, "'."))
            }
            expr = bquote(.(lhs_expr[[1]])<-.(expr))
        }
        eval(expr, envir = e, enclos = baseenv())
    }
    clear_env(e)
    remove_active_bindings(e)
    l = as.list(e, all.names = TRUE)
    l = l[!vapply(l, is.null, NA, USE.NAMES = FALSE)]
    if(length(l)>0){
        nrows = vapply(l, NROW, 1, USE.NAMES = FALSE)
        wrong_rows = nrows!=1L & nrows!=nrow(data)
        if(any(wrong_rows)){
            er_message = utils::head(paste0("'", names(l)[wrong_rows], "' has ", nrows[wrong_rows], " rows"), 5)
            er_message = paste(er_message, collapse = ", ")
            stop(paste0("Bad number of rows: ", er_message, " instead of ", nrow(data), " rows."))
        }
        
        new_vars = rev(names(l)[!(names(l) %in% names(data))])
        data[,(new_vars) := l[new_vars] ]
        # data.table::set(data, j = new_vars, value = l[new_vars]) # doesn't work :(  
    }
    invisible(data)
}

remove_active_bindings = function(env){
    binding_names = ls(envir = env, all.names = TRUE, sorted = FALSE)
    for(i in binding_names){
        if(bindingIsActive(i, env = env)){
            rm(list = i, envir = env)
        }
    }
    invisible(env)
}





#' @export
#' @rdname compute
modify = compute 


#' @export
#' @rdname compute
do_if = function (data, cond, ...){
    .Deprecated(msg = "'do_if'/'modify_if' is deprecated and will be removed in the next version. Please, use 'let_if' from maditr package.")
    UseMethod("do_if")
}


#' @export
#' @rdname compute
modify_if = do_if 


#' @export
do_if.data.frame = function (data, cond, ...) {
    # based on 'within' from base R by R Core team
    cond = substitute(cond)
    dots = substitute(list(...))
    dots = get_named_expressions(dots)
    e = evalq(environment(), data, parent.frame())
    prepare_env(e, n = NROW(data), column_names = colnames(data))
    cond = calc_cond(cond, envir = e)
    if(is.logical(cond)) {
        cond_integer = which(cond)
    } else {
        cond_integer = cond
    }    
    e = evalq(environment(), list(), parent.frame())
    orig_names = colnames(data)
    number_of_rows = length(cond_integer)
    prepare_env(e, n = length(cond_integer), column_names = orig_names)
    if(is.data.table(data)){
        set_var = function(var_name, v){
            data.table::set(data, i = cond_integer, j = var_name, value = v)    
        }
    } else {
        set_var = function(var_name, v){
            if(is.matrix(data[[var_name]]) || is.data.frame(data[[var_name]])){
                data[[var_name]][cond_integer, ] <<- v 
            } else {
                data[[var_name]][cond_integer] <<- v
            }                
        }
    }
    binding = function(var_name){
        var_name
        function(v) {
            if (missing(v)){
                return(universal_subset(data[[var_name]], cond_integer, drop = FALSE))
            } else {
                nrows = NROW(v)
                if(nrows!=1 && nrows!=number_of_rows){
                    stop(paste0("Bad number of rows in '", var_name, "': ",  nrows,
                                " instead of ",
                                number_of_rows, " rows."))    
                }
                set_var(var_name, v)
            }
            invisible(v)
        }
    }
    for(j in names(data)){
        makeActiveBinding(j, binding(j), e)
    }
    for(i in seq_along(dots)){
        curr_name = names(dots)[i]
        expr = dots[[i]]
        if(curr_name != ""){
            lhs_expr = parse(text = curr_name)
            if(length(lhs_expr)!=1){
                stop(paste0("'do_if': incorrect expression '", curr_name, "'."))
            }
            expr = bquote(.(lhs_expr[[1]])<-.(expr))
        }
        eval(expr, envir = e, enclos = baseenv())
    }
    clear_env(e)
    remove_active_bindings(e)
    l = as.list(e, all.names = TRUE)
    if(length(l)>0){
        nrows = vapply(l, NROW, 1, USE.NAMES = FALSE)
        wrong_rows = nrows!=1L & nrows!= number_of_rows
        if(any(wrong_rows)){
            er_message = utils::head(paste0("'", names(l)[wrong_rows], 
                                            "' has ", nrows[wrong_rows], " rows"), 5)
            er_message = paste(er_message, collapse = ", ")
            stop(paste0("Bad number of rows: ", er_message, " instead of ",
                        number_of_rows, " rows."))
        }
        
        new_vars = rev(names(l)[!(names(l) %in% names(data))])
        if(is.data.table(data)){
            data[cond_integer, (new_vars) := l[new_vars] ]
            # data.table::set(data, j = new_vars, value = l[new_vars]) # doesn't work :(     
        } else {
            for(i in new_vars){
                data[[i]] = NA 
                data[[i]][cond_integer] = l[[i]]                 
            }
        }
    }
    if(is.data.table(data)){
        invisible(data)
    } else {
        data    
    }
    
}



#' @export
do_if.list = function (data, cond, ...) {
    for(each in seq_along(data)){
        data[[each]] = eval.parent(substitute(do_if(data[[each]], cond, ...)))
    }
    data
}

########

#' @export
#' @rdname compute
calculate =  function (data, expr, use_labels = FALSE) {
    UseMethod("calculate")
}

#' @export
#' @rdname compute
use_labels =  function (data, expr) {
    expr = substitute(expr)
    all_labs = all_labels(data)
    if(length(all_labs)>0){
        if(anyDuplicated(names(all_labs))){
            dupl = duplicated(names(all_labs)) | duplicated(names(all_labs), fromLast = TRUE)
            all_labs = all_labs[dupl]
            names(all_labs) = paste(names(all_labs), colnames(data)[all_labs])
            for(each in seq_along(all_labs)){
                var_lab(data[[all_labs[each]]]) = names(all_labs)[each]
            }
        }
        substitution_list = extract_var_labs_as_list_with_symbols(data)
        expr = substitute_symbols(expr, c(substitution_list, list(..data = names2labels(data))))
        data = names2labels(data) 
    }
    eval(expr = expr, envir = data, enclos = parent.frame())
}



#' @export
calculate.data.frame = function (data, expr, use_labels = FALSE) {
    # based on 'within' from base R by R Core team
    expr = substitute(expr)
    e = evalq(environment(), data, parent.frame())
    prepare_env(e, n = nrow(data), column_names = colnames(data))
    eval(expr, envir = e, enclos = baseenv())
}

#' @export
calculate.list = function (data, expr, use_labels = FALSE) {
    for(each in seq_along(data)){
        data[[each]] = eval.parent(substitute(calculate(data[[each]], expr, use_labels = use_labels)))
    }
    data
}

all_labels = function(data){
    res = lapply(data, function(x) {
        new_name = var_lab(x)
        if(!is.null(new_name) && !is.na(new_name) && new_name!=""){
            new_name
        } else {
            NULL
        }
    }) 
    indexes = seq_along(data)
    indexes = indexes[lengths(res)>0]
    res = res[lengths(res)>0]
    setNames(indexes, unlist(res))
}

extract_var_labs_as_list_with_symbols = function(data){
    res = lapply(data, function(x) {
        new_name = var_lab(x)
        if(!is.null(new_name) && !is.na(new_name) && new_name!=""){
            as.symbol(new_name)
        } else {
            NULL
        }
        })
    names(res) = colnames(data)
    res[lengths(res)>0]
}

#' @export
#' @rdname compute
calc = calculate


calculate_internal = function(data, expr, parent){
    e = evalq(environment(), data, parent)
    prepare_env(e, n = nrow(data), column_names = colnames(data))
    eval(expr, envir = e, enclos = baseenv())
}

