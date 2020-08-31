#' @name plot_colors
#' @title plot_colors
#' @importFrom dplyr %>%
#' @param data dataframe containing enduse column of type chr.
#' @return Vector of hex codes
#' @export

#get vector of hex codes to be used within scale_color_manual()
#colors match category of enduse (e.g. light = yellow)
plot_colors <- function(data){

  #initialize hex code vectors
  yellows <- c("#F4D700", "#D6B700")
  reds <- c("#BF3100", "#EA3D00", "#862300")
  blues <- c("#257BA0", "#4EACDB", "#035372")
  others  <- c("#AF3B8B", "#80A135", "#FD8B01", "#D37BB8", "#A5C858", "#FEAC48", "#842C69", "#5C7426", "#C76D01")


  #modify dataset to create column mapping color to enduse by category
  data <- data %>%
    dplyr::group_by(enduse) %>%
    dplyr::summarize() %>%
    dplyr::mutate(color = dplyr::case_when(
      stringr::str_detect(enduse, "(Heat Recovery|Exterior Light)") ~ "other",
      stringr::str_detect(enduse, "(Cool|Fan|Heat Rejection|Refrig)") ~ "blue", #cooling
      stringr::str_detect(enduse, "(Heat)") ~ "red", #heating
      stringr::str_detect(enduse, "Light") ~ "yellow", #lighting
      TRUE ~ "other"))


  #iterate through enduses, determine color category, and add corresponding hex to color_vec
  #then remove hex from original vec to not have repeats
  color_vec <- c()
  for(color in data$color){
    if(color == "yellow"){
      color_vec <- c(color_vec, yellows[1])
      yellows <- yellows[-1]
    }else if(color == "blue"){
      color_vec <- c(color_vec, blues[1])
      blues <- blues[-1]
    }else if(color == "red"){
      color_vec <- c(color_vec, reds[1])
      reds <- reds[-1]
    }else{
      color_vec <- c(color_vec, others[1])
      others <- others[-1]
    }

  }

  return(color_vec)
}



#' @name plot_linetypes
#' @title plot_linetypes
#' @importFrom dplyr %>%
#' @param data dataset with "fuel" column. Column must be character or factor, and have either "Electricity" or "Gas"
#' @param plot_aes designates whether output is line type (line) or pattern (pattern)
#' @return Vector of linetypes or patterns
#' @export

plot_linetypes <- function(data, plot_aes){
  data <- data %>%
    dplyr::group_by(enduse, fuel) %>%
    dplyr::summarize() %>%
    dplyr::mutate(linetype = dplyr::case_when(
      fuel == "Electricity" && plot_aes == "line" ~ "solid",
      fuel == "Gas" && plot_aes == "line" ~ "22",
      fuel == "Electricity" && plot_aes == "pattern" ~ "none",
      fuel == "Gas" && plot_aes == "pattern" ~ "stripe",
    )) %>%
    dplyr::arrange(fuel, enduse)

  return(data$linetype)
}
