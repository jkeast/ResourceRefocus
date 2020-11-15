# Cleaning data


#' @name simple_cap
#' @title simple_cap
#' @param x a character string
#' @return string with first letter capitalized
#' @export
#combine with map to capitalize first letter of each word
#base of function taken from https://stackoverflow.com/questions/6364783/capitalize-the-first-letter-of-both-words-in-a-two-word-string
simple_cap <- function(x) {
  s <- stringr::str_split(x, " ")[[1]]
  stringr::str_c(toupper(stringr::str_sub(s, 1, 1)), stringr::str_sub(s, 2),
                 sep="", collapse=" ")
}



#' @name clean_enduse
#' @title clean_enduse
#' @importFrom dplyr %>%
#' @param data a dataframe with an enduse column (column name must match exactly). Column type must be chr.
#' @return dataframe with cleaned enduse column
#' @export

clean_enduse <- function(data){
  data %>%
    dplyr::mutate(enduse = stringr::str_extract(enduse, "[\\w-]*(?=:)"), #take all before :
                  enduse = stringr::str_replace(enduse, "_", " "),

                  #add space before uppercase letter when directly after lowercase
                  enduse = dplyr::case_when(
                    stringr::str_detect(enduse, "(?<=[a-z])[A-Z]") ~
                      stringr::str_c(stringr::str_split(enduse, "(?<=[a-z])[A-Z]", simplify = TRUE)[, 1], " ",
                                     stringr::str_split(enduse, "[a-z](?=[A-Z])", simplify = TRUE)[, 2]),
                    TRUE ~ enduse),

                  #Water Systems -> DHW
                  enduse = dplyr::case_when(
                    enduse == "Water Systems" | enduse == "DHW" ~ "Domestic Hot Water",
                    TRUE ~ enduse
                  ),

                  #capitalize first letter of each word
                  enduse=purrr::map_chr(enduse, simple_cap))
}



#' @name to_remove
#' @title to_remove
#' @importFrom dplyr %>%
#' @param data a dataframe with a fuel column (column name must match exactly). Column type must be chr.
#' @return String with enduse fuel to remove or NULL
#' @export

to_remove <- function(data){
  data2 <- data %>%
    dplyr::group_by(fuel) %>%
    dplyr::summarize(mean_kWh = sum(value))

  #extract sums and round (accounts for slight differences)
  electricity <- signif(dplyr::filter(data2, fuel == "Electricity")$mean_kWh, 5)
  facility <- signif(dplyr::filter(data2, fuel == "Facility")$mean_kWh, 5)

  #determine if "facility" equals sum of electric end uses
  if(electricity == facility){
    message("`to_remove()` removing column summing electric end uses from data.")
    return("Facility")
  }else{
    return(NULL)
  }
}


#' @name convert
#' @title convert
#' @param num a numeric representing energy use
#' @param conversion_factor a numeric representing the conversion factor from num's units to kWh. Default is 3600000. 0 throws an error.
#' @return Energy in kWh
#' @export


convert <- function(num, conversion_factor = 3600000){
  if(conversion_factor == 3600000){
    message("`clean_data()` converting energy from joules to kWh. Override with conversion_factor if input in other units.")}
  else if(conversion_factor != 0){
    message("`clean_data()` converting energy with conversion factor of ", conversion_factor,", dividing original energy values by this factor. Override with conversion_factor if incorrect.")
  }else{
    stop("`clean_data()` cannot convert with conversion factor of 0. Override with conversion_factor.")
  }
  return(num/conversion_factor)
}




#' @name clean_data
#' @title clean_data
#' @importFrom dplyr %>%
#' @param csv character string of path to csv
#' @param by_month designates whether to summarize data by month (the default) or omit month (NULL)
#' @param by_enduse designates whether to summarize data by enduse (the default) or omit enduse (NULL)
#' @param by_hour designates whether to summarize data by hour (the default) or omit hour (NULL)
#' @param by_fuel designates whether to summarize data by fuel (the default) or omit fuel (NULL)
#' @param ... passes arguments to convert()
#' @return Cleaned dataframe
#' @export

clean_data <- function(csv, by_month = month, by_enduse = enduse, by_hour = Hour, by_fuel = fuel, ...) {
  data <- readr::read_csv(csv) %>%

    #transform to long data
    reshape2::melt(id.vars = c("Date/Time"), variable.name = "enduse") %>%


    dplyr::mutate(
           #month is first two digits in Date/Time column
           month = factor(month.abb[readr::parse_number(stringr::str_extract(`Date/Time`, "\\d\\d"))], levels = month.abb),

           #hour is first two digits directly preceding ":"
           Hour = readr::parse_number(stringr::str_extract(`Date/Time`, "\\d\\d(?=:)")),

           fuel = stringr::str_extract(enduse, "[\\w]*(?= \\[)"),

           #convert units appropriately
           value = convert(value, ...))

  remove <- to_remove(data)

  data <- data %>%
    dplyr::filter(!fuel %in% c(remove)) %>%
    #clean all enduses
    clean_enduse()


    #select/group by month and enduse unless otherwise specified
 data %>% dplyr::select(value, {{by_hour}}, {{by_month}}, {{by_enduse}}, {{by_fuel}}) %>%
    dplyr::group_by({{by_hour}}, {{by_month}}, {{by_enduse}}, {{by_fuel}}) %>%
    dplyr::summarize(mean_kWh = mean(value)) %>%
    mutate(enduse = case_when(
      enduse %in% unique(filter(data, fuel == "Electricity")$enduse) & fuel == "Gas" ~ str_c(enduse, "-Gas"),  
      TRUE ~ enduse
    ))

}
