#' @name plot_enduse_avgs
#' @title plot_enduse_avgs
#' @importFrom ggplot2 aes
#' @param csv character string of path to csv
#' @param title character string of desired plot title. Default is NULL
#' @param bw boolean designating whether to plot in color (FALSE, default), or black and white (TRUE)
#' @param ... passes arguments to clean_data()
#' @return line plot with enduse averages
#' @export

plot_enduse_avgs <- function(csv, title = NULL, bw = FALSE, ...){

  data <- clean_data(csv, by_fuel = NULL, ...)

  #create line plot
  ggplot2::ggplot(data, aes(x=Hour, y=mean_kWh, color=enduse)) +
    {if(bw)aes(linetype=enduse)} +
    ggplot2::geom_line(size = 1.05) +
    ggplot2::theme_bw() +

    #add month as facet if in data
    {if("month" %in% colnames(data))ggplot2::facet_wrap(~month)} +

    #make breaks align with day breaks and clean labels
    ggplot2::scale_x_continuous(breaks=c(1, 6, 12, 18, 24))+
    ggplot2::labs(title = title, subtitle = "Average Hourly Consumption by End Use", y = "kWh", color = NULL, linetype = NULL) +

    #customize fonts to those in RR style guide
    ggplot2::theme(text = ggplot2::element_text(family = "Muli"),
          plot.title=ggplot2::element_text(family = "Roboto Slab", face="bold"))+

    #customize colors
    {if(bw)ggplot2::scale_color_grey(start = 0, end = .8)} +
    {if(!bw)ggplot2::scale_color_manual(values = plot_colors(data))}
}



#' @name plot_comps
#' @title plot_comps
#' @importFrom dplyr %>%
#' @importFrom ggplot2 aes
#' @param baseline character string of path to csv containing baseline data
#' @param proposed character string of path to csv containing proposed data
#' @param title character string of desired plot title. Default is NULL
#' @param bw boolean designating whether to plot in color (FALSE, default), or black and white (TRUE)
#' @param ... passes arguments to clean_data()
#' @return line plot comparing two models
#' @export

plot_comps <- function(baseline, proposed, title = NULL, bw = FALSE, ...){

  #combine baseline and proposed datasets
  data <- clean_data(baseline, by_fuel = NULL, by_enduse = NULL, ...) %>%
    dplyr::mutate(model = "Baseline") %>%
    rbind(dplyr::mutate(clean_data(proposed, by_fuel = NULL, by_enduse = NULL, ...), model = "Proposed"))

  #create line plot
  ggplot2::ggplot(data, aes(x=Hour, y=mean_kWh)) + ggplot2::geom_line(size = 1.05) +
    {if(bw)aes(linetype=model)}+
    {if(!bw)aes(color=model)}+
    ggplot2::theme_bw() +

    #add month as facet if in data
    {if("month" %in% colnames(data))ggplot2::facet_wrap(~month)} +

    #make breaks align with day breaks and clean labels
    ggplot2::scale_x_continuous(breaks=c(1, 6, 12, 18, 24))+
    ggplot2::labs(title = title, subtitle = "Average Hourly Total Consumption", y = "kWh", color = NULL, linetype = NULL)+

    #customize fonts to those in RR style guide
    ggplot2::theme(text = ggplot2::element_text(family = "Muli"),
          plot.title=ggplot2::element_text(family = "Roboto Slab", face="bold")) +

    #customize colors to those in RR style guide
    {if(!bw)ggplot2::scale_color_manual(values = c("#257BA0", "#93B83D"))}
}



#' @name plot_dualfuel_avgs
#' @title plot_dualfuel_avgs
#' @importFrom dplyr %>%
#' @importFrom ggplot2 aes
#' @param csv character string of path to csv
#' @param title character string of desired plot title. Default is NULL
#' @param ... passes arguments to clean_data()
#' @return line plot of dual-fuel models
#' @export

plot_dualfuel_avgs <- function(csv, title = NULL, ...){
  #convert to kBtu
  data <- clean_data(csv, ...) %>%
    dplyr::mutate(mean_kBtu = mean_kWh*3.412) %>%
    dplyr::select(-c(mean_kWh))

  #group end uses by fuel for legend
  data_order <- data %>%
    dplyr::group_by(fuel, enduse) %>%
    dplyr::summarize() %>%
    dplyr::arrange(desc(fuel), enduse)

  data$enduse <- factor(data$enduse, levels = data_order$enduse)
  data$fuel <- factor(data$fuel, levels = c("Gas", "Electricity"))

  #create line plot
  ggplot2::ggplot(data, aes(x=Hour, y=mean_kBtu, color=enduse, linetype = fuel)) +
    ggplot2::geom_line(size = 1.05) +
    ggplot2::theme_bw() +

    #add month as facet if in data
    {if("month" %in% colnames(data))ggplot2::facet_wrap(~month)} +

    #make breaks align with day breaks and clean labels
    ggplot2::scale_x_continuous(breaks=c(1, 6, 12, 18, 24))+
    ggplot2::labs(title = "title", subtitle = "Average Hourly Consumption by End Use --- Dual-Fuel Model", y = "kBtu", color = NULL, linetype = NULL) +

    #customize fonts to those in RR style guide
    ggplot2::theme(text = ggplot2::element_text(family = "Muli"),
          plot.title=ggplot2::element_text(family = "Roboto Slab", face="bold"))+

    #set plot linetype to match fuel
    ggplot2::scale_linetype_manual(values = c("22","solid"))+

    #customize colors
    ggplot2::scale_color_manual(values = plot_colors(data))+
    ggplot2::guides(linetype = ggplot2::guide_legend(order = 1), color = ggplot2::guide_legend(order = 2, override.aes = list(linetype = plot_linetypes(data, "line"))))
}


#' @name plot_stacked_enduses
#' @title plot_stacked_enduses
#' @importFrom dplyr %>%
#' @importFrom ggplot2 aes
#' @param baseline character string of path to csv containing data
#' @param proposed character string of path to csv containing data to compare, or NULL (default)
#' @param title character string of desired plot title. Default is NULL
#' @param ... passes arguments to clean_data()
#' @return Stacked barchart of enduses
#' @export

plot_stacked_enduses <- function(baseline, proposed = NULL, title = NULL, by_fuel = fuel, ...){

  devtools::install_github("coolbutuseless/ggpattern")

  data <- clean_data(baseline, by_hour = NULL, by_fuel = {{by_fuel}}, ...)%>%
    dplyr::mutate(model = "Baseline") %>%

    #bind with comparison data if applicable
    `if`(!is.null(proposed), rbind(., dplyr::mutate(clean_data(proposed, by_hour = NULL, by_fuel = {{by_fuel}}, ...), model = "Proposed")), .) %>%


    #convert to kBtu for dual-fuel
    dplyr::mutate(mean_energy = dplyr::case_when(
      !is.null({{by_fuel}}) ~ mean_kWh*3.412,
      TRUE ~ mean_kWh)) %>%
    dplyr::select(-c(mean_kWh))

  #orders from lease energy intensive to most
  enduse_order <- data %>%
    dplyr::group_by(enduse, {{by_fuel}}) %>%
    dplyr::summarize(energy = mean(mean_energy)) %>%
    dplyr::arrange({{by_fuel}}, energy)
  data$enduse <- factor(data$enduse, levels = enduse_order$enduse)

  ggplot2::ggplot(data, aes(x=model, y=mean_energy, fill=enduse, color = enduse))+
    ggplot2::geom_col(identity="stat")+

    #add pattern if dual-fuel
    {if("fuel" %in% colnames(data))ggpattern::geom_col_pattern(aes(pattern = fuel), identity="stat", pattern_fill = "white", pattern_color=NA, pattern_spacing = .02, pattern_density = .1, size = 1.2)}+
    {if("fuel" %in% colnames(data))ggpattern::scale_pattern_manual(values = c("none", "stripe"))}+
    ggplot2::scale_fill_manual(values = plot_colors(data))+
    ggplot2::scale_color_manual(values = plot_colors(data))+

    {if("month" %in% colnames(data))ggplot2::facet_wrap(~month)} +
    ggplot2::theme_bw()+
    ggplot2::labs(title = title, x="Model", y = "kWh", fill = NULL, color = NULL, pattern = NULL) +

    {if("fuel" %in% colnames(data))ggplot2::labs(y="kBtu")}+
    ggplot2::theme(text = ggplot2::element_text(family = "Muli"),
          plot.title=ggplot2::element_text(family = "Roboto Slab", face="bold"))+
    {if("fuel" %in% colnames(data))ggplot2::guides(fill = ggplot2::guide_legend(override.aes = list(pattern = plot_linetypes(data, "pattern"))))}
}
