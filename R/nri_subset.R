setMethod("subset", signature(x = "Nri"), 
                 definition = function(x, subset, ...)
{
  subset <- substitute(subset)
  return(.subset.nri(x, subset, ...))
}
)


.subset.nri <- function(x, e, fuzzy = FALSE, ...)
{
  target <- data.frame(id.nri = x@dimnames$Sample)
  if (nrow(SI(x)) == nrow(target))
    target <- cbind(target, SI(x))

  if (!fuzzy)
  {
    dupl <- duplicated(names(target))
    if (any(dupl))
    {
      dupl_col <- c(1:length(dupl))*(-1)
      target_rm <- dupl_col[dupl]*(-1)
      for (i in target_rm)
        dupl_col[names(target)==names(target)[target_rm]] <- dupl_col[names(target)==names(target)[target_rm]] * (-1)
      dupl_col <- dupl_col[dupl_col>0]
      target_rm <- vector(mode="numeric", length=0)
      for (i in 1:(length(dupl_col)-1))
      {
        for (k in (i+1):length(dupl_col))
        {
          if (names(target)[dupl_col[i]]==names(target)[dupl_col[k]])
          {
            if (any(target[,dupl_col[i]]!=target[,dupl_col[k]]))
            {
              warning("Column names not unique")
            } else {
              target_rm <- c(target_rm,dupl_col[k]*(-1))
            }
          }
        }
      }
      if (length(target_rm)>0)
        target <- target[, target_rm]
    }
  } else {
    col_names <- as.character(e[2])
    names(target)[agrep(col_names, names(target), ...)] <- col_names
  }

  r <- eval(e, envir = target, enclos = parent.frame())

  if (!is.logical(r)) 
    stop("'subset' must evaluate to logical")
  r <- r & !is.na(r)
  
  x@nri <- distMat3D(x@nri[,,r])
  
  x@dimnames$Sample <- x@dimnames$Sample[r]

  if (nrow(SI(x)) == nrow(target))
    SI(x) <- SI(x, i = r) 
  e_str <- gsub("\"", "'", as.character(paste(enquote(e)))[2])
  if (length(e_str) == 1)
  {
    usagehistory(x) <- paste("Subset of nri-values (", e_str, ")", sep = "")  
  } else {
    usagehistory(x) <- "Subset of nri-values"
  }
  return(x)
}



