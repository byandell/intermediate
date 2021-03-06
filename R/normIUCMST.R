#' Normal IUCMST
#' 
#' @param models Object with model information
#' @param Zscores Calculated Z scores from \code{calcZ}
#' @param ... additional paramters
#' 
#' @export
#' @importFrom stats pnorm
#' 
normIUCMST <- function(models,
                             Zscores = calcZ(models, ...),
                             ...) {

  if(length(models$LR) == 1)
    return(data.frame(ref = names(models$LR),
                     alt = "",
                     pv = 1))
  
  # Expand to data frame with ref, alt, Z.
  Zscores <- left_right(Zscores)
  
  # Add p-value
  Zscores$pv <- stats::pnorm(Zscores$Z, lower.tail = FALSE)

  comp_pv(Zscores)
}
comp_pv <- function(object) {
  # Compare reference model with all others and get max pvalue.
  dplyr::mutate(
    dplyr::ungroup(
      dplyr::summarize(
        dplyr::group_by(
          dplyr::mutate(object,
                        ref = factor(.data$ref, unique(.data$ref))),
          .data$ref),
        alt = .data$alt[which.max(.data$pv)][1],
        pv = max(.data$pv))),
    ref = as.character(.data$ref))
}
