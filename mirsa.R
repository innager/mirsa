#==============================================================================#
#------------------------------------------------------------------------------#
#                      Mixed radix incrementing algorithm                      #
#------------------------------------------------------------------------------#
#==============================================================================#

#' Mixed radix system algorithm 
#' 
#' @description Generates multiplicities for multisets using incrementing in
#'   mixed radix numeral systems.
#' @param dmax a vector of largest digits at each position.
#' @param summax an integer value for the maximum sum of multiplicities (maximum
#'   cardinality of a multiset).
#' @return A matrix where each column represents a multiset by a sequence of its
#'   multiplicities.
#'   
mirsa <- function(dmax, summax = NULL) {
  if (is.null(summax)) {
    summax <- sum(dmax)
  }
  k    <- length(dmax)  
  vmax <- limseq(dmax, summax)
  v    <- rep(0, k)
  sumv <- 0
  vmat <- v
  i    <- k
  while (!all(v == vmax)) {
    while (v[i] == dmax[i] || sumv == summax) {
      sumv <- sumv - v[i]
      v[i] <- 0
      i <- i - 1
    } 
    v[i] <- v[i] + 1
    sumv <- sumv + 1
    i <- k
    vmat <- cbind(vmat, v)      
  }
  dimnames(vmat) <- NULL 
  return(vmat)
}

#' @inherit mirsa
#' @details This version includes the smallest digit at each position explicitly
#'   (instead of adjusting \code{dmax} and \code{summax} before running
#'   \code{MIRSA}).
#' @param dmin a vector of smallest digits at each position.
#'
mirsa2 <- function(dmax, dmin = 0, summax = NULL) {
  if (is.null(summax)) {
    summax <- sum(dmax)
  }
  k    <- length(dmax)    
  if (length(dmin) == 1) dmin <- rep(dmin, k)
  vmax <- limseq2(dmax, dmin, summax)
  v    <- dmin
  sumv <- sum(dmin)
  vmat <- v
  i    <- k
  while (!all(v == vmax)) {
    while (v[i] == dmax[i] || sumv == summax) {
      sumv <- sumv - v[i] + dmin[i]      
      v[i] <- dmin[i]      
      i <- i - 1
    } 
    v[i] <- v[i] + 1
    sumv <- sumv + 1
    i <- k
    vmat <- cbind(vmat, v)      
  }
  dimnames(vmat) <- NULL 
  return(vmat)
}

#' Weighted version of the algorithm
#'
#' @inherit mirsa description return
#' @param wsummax an integer value for the maximum weighted sum of
#'   multiplicities.
#' @param eq a logical value. If \code{TRUE}, the weighted sum is equal to
#'   \code{wsummax}; if \code{FALSE} - less than or equal to \code{wsummax}.
#'   
mirsaW <- function(wsummax, eq = FALSE) {
  k    <- wsummax - eq
  v    <- rep(0, k)
  sumv <- 0
  vmat <- v
  i    <- k
  while (v[1] == 0) {
    w <- wsummax - i + 1                  # weight of the position
    if (sumv + w > wsummax) {
      sumv <- sumv - v[i]*w
      v[i] <- 0
      i <- i - 1
    } else {
      v[i] <- v[i] + 1
      sumv <- sumv + w
      i <- k
      vmat <- cbind(vmat, v)      
    }
  }
  if (eq) {
    vmat <- rbind(vmat, wsummax - colSums(vmat*wsummax:2))
  }
  dimnames(vmat) <- NULL
  return(vmat)
}

#' Sorted digits version fo the algorithm
#' 
#' @description Generates strictly increasing sequences of length \code{k} with
#'   elements in \code{1:n} using incrementing in mixed radix numeral systems.
#' 
#' @param n an integer value, the maximum index.
#' @param k an integer value, the length of each sequence. 
#' 
#' @return A matrix where each column is a sequence of indices. 
#'
mirsaS <- function(n, k) {
  v    <- 1:k
  vmax <- (n - k + 1):n
  vmat <- v
  i    <- k
  while (v[1] != vmax[1]) {
    while (v[i] == vmax[i]) {
      i <- i - 1
    } 
    v[i:k] <- v[i] + 1L:(k - i + 1)
    i <- k
    vmat <- cbind(vmat, v)      
  }
  dimnames(vmat) <- NULL 
  return(vmat)
}

#' Permutations of integers from \code{1} to \code{n}
#' 
#' @param n an integer value. 
#' 
#' @return A matrix where each column is a permutation of integers \code{1:n}. 
#' 
perm <- function(n) {
  if (n == 1) {
    return(matrix(1))
  }
  nc  <- factorial(n)
  v   <- 1:n
  vmat <- matrix(v, n, nc)
  
  for (j in 2:nc) {
    i <- n - 1    
    while (v[i] > v[i + 1]) {
      i <- i - 1
    }
    vsort <- sort(v[i:n])
    ii <- which(vsort == v[i]) + 1
    v[i] <- vsort[ii]
    v[(i + 1):n] <- vsort[-ii]
    vmat[, j] <- v
  }
  return(vmat)
}

#' Limit sequence for \code{mirsa}
#' 
#' @description Calculate a sequence of multiplicities that corresponds to the
#'   largest number in a given numeral system satisfying \code{summax}
#'   condition.
#' @inheritParams mirsa
#' @return An integer vector.
#'   
limseq <- function(dmax, summax) {
  extraout <- pmin(0, summax - cumsum(dmax))
  pmax(dmax + extraout, 0)
}

#' @inherit limseq
#' @inheritParams mirsa2
#' @details A wrapper of \code{limseq} to include a vector of smallest digits at
#'   each position.
#'   
limseq2 <- function(dmax, dmin, summax) {
  limseq(dmax - dmin, summax - sum(dmin)) + dmin
}

