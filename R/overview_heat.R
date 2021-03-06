#' @title overview_heat
#'
#' @description This function plots a heat map to visualize the
#'     coverage of the time-scope-units of the data. Options include total
#'     number of cases per time-scope-unit or relative number in percentage.
#' @param dat Your dataset
#' @param id Your scope (e.g., country codes or individual IDs)
#' @param time Your time (e.g., time periods given by years, months, ...)
#' @param perc If FALSE (default) plot returns the total number of observations
#'     per time-scope-unit. If TRUE it returns the number of observations per
#'     time-scope-unit in percentage
#' @param exp_total Expected total number of observations (i.e. maximum)
#'     for time unit.
#' @param xaxis Label of your x axis ("Time frame" is default)
#' @param yaxis Label of your y axis ("Sample" is default)
#' @param col_low Hex color code for the lowest value (default is "#dceaf2")
#' @param col_high Hex color code for the lowest value (default is "#2A5773")
#' @return A ggplot figure that presents sample coverage visually
#' @examples
#' data(toydata)
#' overview_heat(toydata, ccode, year, perc = TRUE, exp_total = 12)
#' @export
#' @importFrom dplyr "%>%"
#' @importFrom ggplot2 ggplot

overview_heat <-
  function(dat,
           id,
           time,
           perc = FALSE,
           exp_total,
           xaxis = "Time frame",
           yaxis = "Sample",
           col_low = "#dceaf2",
           col_high = "#2A5773") {
    # if( perc==TRUE & is.na(exp_total)) stop('Argument `exp_total` is empty.
    # Please add a value (>0) that indicates XX' )

    dat <- dat
    id <- dplyr::enquo(id)
    time <- dplyr::enquo(time)

    # Set theme ---------------------------------------------------------------
    theme_plot <- ggplot2::theme(
      # get rid of panel grids
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      # Change plot and panel background
      plot.background = ggplot2::element_rect(fill = "white"),
      panel.background = ggplot2::element_rect(fill = "white"),
      # Change legend
      legend.direction = "horizontal",
      legend.position = "none",
      legend.background = ggplot2::element_rect(fill = "black", color = NA),
      legend.key = ggplot2::element_rect(color = "black", fill = "black"),
      legend.title = ggplot2::element_blank(),
      # Change text
      plot.caption = ggplot2::element_text(size = 5),
      axis.text = ggplot2::element_text(
        face = "plain",
        color = "black",
        size = 8
      ),
      text = ggplot2::element_text(
        size = 8,
        face = "plain"
      )
    )

    # No percentages ----------------------------------------------------------
    if (perc == FALSE) {
      # Generate a count
      dat_agg <- dat %>%
        dplyr::group_by(!!id, !!time) %>%
        dplyr::mutate(count = dplyr::n())

      # Plot the result
      plot <-
        ggplot2::ggplot(dat_agg, ggplot2::aes(factor(!!time), !!id)) +
        ggplot2::geom_tile(ggplot2::aes(fill = count), colour = "white") +
        ggplot2::geom_text(ggplot2::aes(label = round(n, 1)), size = 3.3) +
        ggplot2::scale_fill_gradient(low = col_low, high = col_high) +
        ggplot2::ylab(yaxis) +
        ggplot2::xlab(xaxis) +
        theme_plot

      return(plot)
    }

    # Add percentages ---------------------------------------------------------
    if (perc == TRUE) {
      # Generate a count
      dat_agg <- dat %>%
        dplyr::group_by(!!id, !!time) %>%
        dplyr::mutate(count = dplyr::n(),
                      total = count / exp_total)

      # Plot the result
      plot_perc <-
        ggplot2::ggplot(dat_agg, ggplot2::aes(factor(!!time), !!id)) +
        ggplot2::geom_tile(ggplot2::aes(fill = count), colour = "white") +
        ggplot2::geom_text(ggplot2::aes(label = paste(round(100 * total, 2),
                                                      "%", sep = "")),
                           size = 3.3) +
        ggplot2::scale_fill_gradient(low = col_low, high = col_high) +
        ggplot2::ylab(yaxis) +
        ggplot2::xlab(xaxis) +
        theme_plot

      return(plot_perc)
    }
  }
