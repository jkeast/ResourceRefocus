library(ResourceRefocus)

test_that("simple cap works", {
  expect_equal(simple_cap("hello world"), "Hello World")
  expect_equal(simple_cap("this is a test"), "This Is A Test")
  expect_equal(simple_cap("hELLO"), "HELLO")
})


sample_data <- tibble::tribble(
  ~enduse,
  "Electricity:Facility [J](Hourly)",
  "Res_lighting:InteriorLights:Electricity [J](Hourly)",
  "ExteriorLights:Electricity [J](Hourly)",
  "DHW:NaturalGas [J](Hourly)"
)

 test_that("clean enduse works", {
   expect_equal(clean_enduse(sample_data)$enduse, c("Electricity", "Res Lighting", "Exterior Lights", "Domestic Hot Water"))
 })

 baseline_sample <- clean_data("data/sample_baseline_design.csv", by_month = NULL, by_enduse = NULL, by_hour = NULL)
 proposed_sample <- clean_data("data/sample_proposed_design_w-pumpsMeter.csv", by_month = NULL, by_enduse = NULL, by_hour = NULL)
 dualfuel_sample <- clean_data("data/sample_baseline_dual-fuel_design.csv", by_month = NULL, by_enduse = NULL, by_hour = NULL)

 test_that("to remove works", {
   expect_equal(baseline_sample$fuel, c("Electricity", "NaturalGas"))
   expect_equal(proposed_sample$fuel, c("Electricity"))
   expect_equal(dualfuel_sample$fuel, c("Electricity", "Gas"))
 })


 test_that("conversion works", {
   expect_message(convert(1), "`clean_data()` converting energy from joules to kWh. Override with conversion_factor if input in other units.", fixed = TRUE)
   expect_equal(convert(1), 1/3600000)
   expect_equal(convert(2, 2), 2/2)
   expect_message(convert(2, 2), "`clean_data()` converting energy with conversion factor of 2, dividing original energy values by this factor. Override with conversion_factor if incorrect.", fixed = TRUE)
   expect_error(convert(1, 0), "`clean_data()` cannot convert with conversion factor of 0. Override with conversion_factor.", fixed = TRUE)
 })


 csv <- "data/sample_baseline_design.csv"

 test_that("clean data works", {
   expect_equal(ncol(clean_data(csv)), 8)
   expect_equal(ncol(clean_data(csv, by_month = NULL)), 7)
   expect_equal(ncol(clean_data(csv, by_month = NULL, by_fuel = NULL)), 6)
   expect_equal(ncol(clean_data(csv, by_month = NULL, by_fuel = NULL, by_enduse = NULL)), 5)
   expect_equal(nrow(clean_data(csv)), length(unique(clean_data(csv)$month)) * length(unique(clean_data(csv)$enduse)) * length(unique(clean_data(csv)$Hour)))




 })
