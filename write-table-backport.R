write.table <- function (x, file = "", append = F, quote = T, sep = " ", 
  eol = "\n", na = "NA", dec = ".", row.names = T, col.names = T, 
  qmethod = c("escape", "double")) 
{

  if (is.logical(quote) && quote) 
    quote <- which(unlist(lapply(x, function(x) is.character(x) || 
        is.factor(x))))

  i <- is.na(x)
  x <- as.matrix(x)
  if (any(i)) 
    x[i] <- na
  p <- ncol(x)
  d <- dimnames(x)
  if (is.logical(quote)) 
    quote <- if (quote) 
      1:p
  else NULL
  else if (is.numeric(quote)) {
    if (any(quote < 1 | quote > p)) 
      stop("invalid numbers in quote")
  }
  else stop("invalid quote specification")
  rn <- F
 
  if (!is.null(quote) && (p < ncol(x))) 
    quote <- c(0, quote) + 1
  if (is.logical(col.names)) 
    col.names <- if (is.na(col.names) && rn) 
      c("", d[[2]])
  else if (col.names) 
    d[[2]]
  else NULL
  else {
    col.names <- as.character(col.names)
    if (length(col.names) != p) 
      stop("invalid col.names specification")
  }
  if (!is.null(col.names)) {
    if (append) 
      warning("appending column names to file")
    if (!is.null(quote)) 
      col.names <- paste("\"", col.names, "\"", sep = "")
    cat(col.names, file = file, sep = rep(sep, p - 1), append = append)
    cat(eol, file = file, append = T)
    append <- T
  }
  qstring <- switch(qmethod, escape = "\\\\\"", double = "\"\"")
  for (i in quote) x[, i] <- paste("\"", gsub("\"", qstring, 
    x[, i]), "\"", sep = "")
  cat(t(x), file = file, sep = c(rep(sep, ncol(x) - 1), eol), 
    append = append)
}
