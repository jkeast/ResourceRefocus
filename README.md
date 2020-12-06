
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Resource Refocus R Data Visualization Package for 8760 Building End-Use Level Data <img src="Resource-Refocus-Secondary-Logo-RGB-Borderless.png" align="right" height=130/>

## Guide to Using Functions

### Set Up

Run the following code to install the package

``` r
# install.packages("devtools")
# devtools::install_github("jkeast/ResourceRefocus")

library(ResourceRefocus)
```

To ensure the fonts are consistent with the Resource Refocus style
guide, make sure the “Muli” and “Roboto” fonts are installed to your
computer and install and library the `extrafont` package. Then, for each
font family run `ttf_import("[Path to font]")` and finally

``` r
extrafont::loadfonts(device = "win")
```

<!-- badges: start -->

<!-- badges: end -->

### Getting Data Ready for Plotting

I wrote a couple of functions to transform model outputs into a workable
format for plotting:

  - `simpleCap()` capitalizes the first letter of each word (for
    labeling purposes)
  - `clean_enduse()` modifies the names of enduse columns to be visually
    appealing (for labeling purposes)
  - `to_remove()` determines if there is an enduse equalling sum of
    others and removes it
  - `convert()` converts energy from original units to kWh
  - `clean_data()` utilizes the above functions and some existing R
    functions to make the data completely ready for plotting

`clean_data()` is automatically called by all plotting functions, but
can also be used on its own if ever helpful. To utilize it, call
`clean_data()` with the path to a csv of your data. E.g:

``` r
library(ResourceRefocus)
data <- clean_data("data/sample_baseline_design.csv")
#> Parsed with column specification:
#> cols(
#>   `Date/Time` = col_character(),
#>   `Misc_Loads:InteriorEquipment:Electricity [J](Hourly)` = col_double(),
#>   `Electricity:Facility [J](Hourly)` = col_double(),
#>   `Res_lighting:InteriorLights:Electricity [J](Hourly)` = col_double(),
#>   `NonRes_lighting:InteriorLights:Electricity [J](Hourly)` = col_double(),
#>   `ExteriorLights:Electricity [J](Hourly)` = col_double(),
#>   `Cooling:Electricity [J](Hourly)` = col_double(),
#>   `Heating:Electricity [J](Hourly)` = col_double(),
#>   `Fans:Electricity [J](Hourly)` = col_double(),
#>   `Appliances:InteriorEquipment:Electricity [J](Hourly)` = col_double(),
#>   `DHW:NaturalGas [J](Hourly)` = col_double()
#> )
#> Parsed with column specification:
#> cols(
#>   `Date/Time` = col_character(),
#>   `tonne CO2-e/MWh` = col_double(),
#>   `tonne CO2-e/therm` = col_double()
#> )
#> Joining, by = "Date/Time"
#> `clean_data()` converting energy from joules to kWh. Override with conversion_factor if input in other units.
#> `clean_data()` converting energy with conversion factor of 105480400, dividing original energy values by this factor. Override with conversion_factor if incorrect.
#> `clean_data()` converting energy from joules to kWh. Override with conversion_factor if input in other units.
#> `to_remove()` removing row summing electric end uses from data.
head(data)
#> # A tibble: 6 x 8
#> # Groups:   Hour, month, enduse [6]
#>    Hour month enduse             fuel           kWh mean_CO2e sum_kWh sum_CO2e
#>   <dbl> <fct> <chr>              <chr>        <dbl>     <dbl>   <dbl>    <dbl>
#> 1     1 Jan   Appliances         Electricity 1.99     0.316    63.5    10.1   
#> 2     1 Jan   Cooling            Electricity 0.178    0.0294    5.69    0.940 
#> 3     1 Jan   Domestic Hot Water NaturalGas  1.99     0.316    63.5    10.1   
#> 4     1 Jan   Exterior Lights    Electricity 0.189    0.0298    6.05    0.954 
#> 5     1 Jan   Fans               Electricity 0.0177   0.00290   0.568   0.0928
#> 6     1 Jan   Heating            Electricity 0.851    0.139    27.2     4.44
```

In addition to the path to a csv, `clean_data()` has a number of other
arguments:

  - `by_month`: designates whether to summarize data by month (the
    default) or omit month (NULL)
  - `by_enduse`: designates whether to summarize data by enduse (the
    default) or omit enduse (NULL)
  - `by_hour`: designates whether to summarize data by hour (the
    default) or omit hour (NULL)
  - `by_fuel`: designates whether to summarize data by fuel (the
    default) or omit fuel (NULL)

Each of these arguments shape how granular the summaries are. The
default for the function is to include all these variables, so you need
to indicate which you want the function to NOT consider. For example, if
you want to just focus on energy usage by month – ignoring end-use, hour
of the day, and fuel – you can set `by_enduse`, `by_hour`, and `by_fuel`
to NULL.

``` r
data <- clean_data("data/sample_baseline_design.csv", by_enduse = NULL, by_hour = NULL, by_fuel = NULL)
head(data)
#> # A tibble: 6 x 5
#>   month   kWh mean_CO2e sum_kWh sum_CO2e
#>   <fct> <dbl>     <dbl>   <dbl>    <dbl>
#> 1 Jan    2.84    0.339   19611.    2341.
#> 2 Feb    2.75    0.266   16657.    1607.
#> 3 Mar    2.74    0.162   18351.    1084.
#> 4 Apr    2.67    0.112   17285.     723.
#> 5 May    2.74    0.0938  18370.     628.
#> 6 Jun    2.70    0.119   17520.     770.
```

You can also use these arguments in conjunction, say to focus on end-use
and hour of the day:

``` r
data <- clean_data("data/sample_baseline_design.csv", by_fuel = NULL, by_month = NULL)
head(data)
#> # A tibble: 6 x 6
#> # Groups:   Hour [1]
#>    Hour enduse                kWh mean_CO2e sum_kWh sum_CO2e
#>   <dbl> <chr>               <dbl>     <dbl>   <dbl>    <dbl>
#> 1     1 Appliances         1.88     0.239     688.     87.6 
#> 2     1 Cooling            1.09     0.141     399.     51.6 
#> 3     1 Domestic Hot Water 1.88     0.239     688.     87.6 
#> 4     1 Exterior Lights    0.140    0.0183     51.3     6.72
#> 5     1 Fans               0.0358   0.00465    13.1     1.70
#> 6     1 Heating            0.224    0.0300     82.2    11.0
```

`clean_data()` also passes a `conversion_factor` argument to the
`convert()` function. This is what you should use if the source data is
in some units other than Joules — just supply `clean_data()` with the
correct factor to convert from the original units to kWh. For example,
say our original units are kBtu. We would want to divide the energy by
3.412 to convert to kWh:

``` r
data <- clean_data("data/sample_baseline_design.csv", conversion_factor = 3.412)
#> Parsed with column specification:
#> cols(
#>   `Date/Time` = col_character(),
#>   `Misc_Loads:InteriorEquipment:Electricity [J](Hourly)` = col_double(),
#>   `Electricity:Facility [J](Hourly)` = col_double(),
#>   `Res_lighting:InteriorLights:Electricity [J](Hourly)` = col_double(),
#>   `NonRes_lighting:InteriorLights:Electricity [J](Hourly)` = col_double(),
#>   `ExteriorLights:Electricity [J](Hourly)` = col_double(),
#>   `Cooling:Electricity [J](Hourly)` = col_double(),
#>   `Heating:Electricity [J](Hourly)` = col_double(),
#>   `Fans:Electricity [J](Hourly)` = col_double(),
#>   `Appliances:InteriorEquipment:Electricity [J](Hourly)` = col_double(),
#>   `DHW:NaturalGas [J](Hourly)` = col_double()
#> )
#> Parsed with column specification:
#> cols(
#>   `Date/Time` = col_character(),
#>   `tonne CO2-e/MWh` = col_double(),
#>   `tonne CO2-e/therm` = col_double()
#> )
#> Joining, by = "Date/Time"
#> `clean_data()` converting energy with conversion factor of 3.412, dividing original energy values by this factor. Override with conversion_factor if incorrect.
#> `clean_data()` converting energy with conversion factor of 105480400, dividing original energy values by this factor. Override with conversion_factor if incorrect.
#> `clean_data()` converting energy from joules to kWh. Override with conversion_factor if input in other units.
#> `to_remove()` removing row summing electric end uses from data.
head(data)
#> # A tibble: 6 x 8
#> # Groups:   Hour, month, enduse [6]
#>    Hour month enduse            fuel             kWh mean_CO2e  sum_kWh sum_CO2e
#>   <dbl> <fct> <chr>             <chr>          <dbl>     <dbl>    <dbl>    <dbl>
#> 1     1 Jan   Appliances        Electricity 2094375.   333752.   6.70e7   1.07e7
#> 2     1 Jan   Cooling           Electricity  187742.    30982.   6.01e6   9.91e5
#> 3     1 Jan   Domestic Hot Wat~ NaturalGas  2094375.   333752.   6.70e7   1.07e7
#> 4     1 Jan   Exterior Lights   Electricity  199399.    31447.   6.38e6   1.01e6
#> 5     1 Jan   Fans              Electricity   18724.     3060.   5.99e5   9.79e4
#> 6     1 Jan   Heating           Electricity  898006.   146337.   2.87e7   4.68e6
```

As you can see, the function also sends a message reminding you which
conversion factor you used.

### Using the plotting functions

#### Compare different models

`plot_comps()` shows the comparison of a baseline model to proposed. It
takes the following arguments:

  - `baseline`: character string of path to csv containing baseline data
  - `proposed`: character string of path to csv containing proposed data
  - `title`: character string of desired plot title. Default is NULL
  - `bw`: boolean designating whether to plot in color (FALSE, default),
    or black and white (TRUE)

and passes `by_month` and `conversion_factor` to `clean_data()`, which
it calls automatically.

``` r
plot_comps("data/sample_baseline_design.csv", "data/sample_proposed_design_w-pumpsMeter.csv", title = "Placeholder Title")
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

``` r
plot_comps("data/sample_baseline_design.csv", "data/sample_proposed_design_w-pumpsMeter.csv", title = "Placeholder Title", result = "Emissions")
```

<img src="man/figures/README-unnamed-chunk-8-2.png" width="100%" />

``` r
plot_comps("data/sample_baseline_design.csv", "data/sample_proposed_design_w-pumpsMeter.csv", by_month = NULL, title = "Placeholder Title")
```

<img src="man/figures/README-unnamed-chunk-8-3.png" width="100%" />

``` r
plot_comps("data/sample_baseline_design.csv", "data/sample_proposed_design_w-pumpsMeter.csv", by_month = NULL, title = "Placeholder Title", result = "Emissions")
```

<img src="man/figures/README-unnamed-chunk-8-4.png" width="100%" />

``` r
plot_comps("data/sample_baseline_design.csv", "data/sample_proposed_design_w-pumpsMeter.csv", by_month = NULL, title = "Placeholder Title", bw = TRUE)
```

<img src="man/figures/README-unnamed-chunk-8-5.png" width="100%" />

#### Plot End-use Averages

`plot_enduse_avgs()` shows average hourly energy projections stratified
by end-use. It takes the following arguments:

  - `csv`: character string of path to csv containing model outputs
  - `title`: character string of desired plot title. Default is NULL
  - `bw`: boolean designating whether to plot in color (FALSE, default),
    or black and white (TRUE)

and passes `by_month` and `conversion_factor` to `clean_data()`, which
it calls automatically.

``` r
plot_enduse_avgs("data/sample_baseline_design.csv", title = "Placeholder Title")
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

``` r
plot_enduse_avgs("data/sample_baseline_design.csv", by_month = NULL, title = "Placeholder Title")
```

<img src="man/figures/README-unnamed-chunk-9-2.png" width="100%" />

``` r
plot_enduse_avgs("data/sample_baseline_design.csv", by_month = NULL, title = "Placeholder Title", result = "Emissions")
```

<img src="man/figures/README-unnamed-chunk-9-3.png" width="100%" />

``` r
plot_enduse_avgs("data/sample_baseline_design.csv", title = "Placeholder Title", by_month = NULL, bw = TRUE)
```

<img src="man/figures/README-unnamed-chunk-9-4.png" width="100%" />

#### Plot Dual-Fuel Averages

`plot_dualfuel_avgs()` shows average hourly energy projections from a
dual-fuel model stratified by end-use. It takes the following arguments:

  - `csv`: character string of path to csv containing model outputs
  - `title`: character string of desired plot title. Default is NULL

and passes `by_month` and `conversion_factor` to `clean_data()`, which
it calls automatically.

``` r
plot_dualfuel_avgs("data/sample_baseline_dual-fuel_design.csv", title = "Placeholder Title", by_month = NULL)
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

``` r
plot_dualfuel_avgs("data/sample_baseline_dual-fuel_design.csv", title = "Placeholder Title", result = "Emissions", by_month = NULL)
```

<img src="man/figures/README-unnamed-chunk-10-2.png" width="100%" />

#### End Use Averages Barcharts

`plot_stacked_enduses()` creates barcharts to show average energy
projections. If provided with two paths to csvs it will compare the two
models. It can also stratify the data by month and/or visualize a
dual-fuel model. It takes the following arguments:

  - `baseline`: character string of path to csv containing data
  - `proposed`: character string of path to csv containing data to
    compare, or NULL (default)
  - `title`: character string of desired plot title. Default is NULL
  - `by_fuel`: designates whether plotting dual-fuel (default) or not
    (NULL)

and passes `by_month` and `conversion_factor` to `clean_data()`, which
it calls automatically.

``` r
plot_stacked_enduses("data/sample_baseline_design.csv", "data/sample_proposed_design_w-pumpsMeter.csv", title = "Placeholder Title", by_month = NULL, by_fuel = NULL)
#> Warning: Ignoring unknown parameters: identity
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

``` r
plot_stacked_enduses("data/sample_baseline_design.csv", "data/sample_proposed_design_w-pumpsMeter.csv", title = "Placeholder Title", by_month = NULL, by_fuel = NULL, result = "Emissions")
#> Warning: Ignoring unknown parameters: identity
```

<img src="man/figures/README-unnamed-chunk-11-2.png" width="100%" />

``` r
plot_stacked_enduses("data/sample_baseline_design.csv", "data/sample_proposed_design_w-pumpsMeter.csv", title = "Placeholder Title", by_fuel = NULL)
#> Warning: Ignoring unknown parameters: identity
```

<img src="man/figures/README-unnamed-chunk-11-3.png" width="100%" />

``` r
plot_stacked_enduses("data/sample_baseline_dual-fuel_design.csv", title = "Placeholder Title", by_month = NULL)
#> Warning: Ignoring unknown parameters: identity

#> Warning: Ignoring unknown parameters: identity
```

<img src="man/figures/README-unnamed-chunk-11-4.png" width="100%" />

``` r
plot_stacked_enduses("data/sample_baseline_dual-fuel_design.csv", title = "Placeholder Title")
#> Warning: Ignoring unknown parameters: identity

#> Warning: Ignoring unknown parameters: identity
```

<img src="man/figures/README-unnamed-chunk-11-5.png" width="100%" />
