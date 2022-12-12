# Determine whether a single number is valid according to Luhn
# Input as string or integer

validate_luhn <- function(x) {
  valid <- function(x) {
    if (x == TRUE) {
      message("Input is valid!")
      invisible(TRUE)
    } else {
      message("Input is invalid!")
      invisible(FALSE)
    }
  }
  
  string <- gsub(" ", "", as.character(x))
  
  if (grepl("\\D", string)) {
    message("Input is not valid as it contains non-numeric characters")
    return(valid(FALSE))
  }
  
  num <- as.numeric(strsplit(string, "")[[1]])
  
  if (length(num) <= 1)
    return(valid(FALSE))
  
  sum <- 0
  parity <- length(num) %% 2
  
  for (i in seq_along(num)) {
    if (i %% 2 == parity) {
      sum <- sum + num[i]
    } else if (num[i] > 4) {
      sum <- sum + 2 * num[i] - 9
    } else {
      sum <- sum + 2 * num[i]
    }
  }
  
  if (sum %% 10 == 0)
    return(valid(TRUE))
  else
    return(valid(FALSE))
}
