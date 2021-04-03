library(readxl)
library(writexl)
library(dplyr)
library(tidyr)
library(countrycode)

rm(list = ls())

excel_path = "../raw_data/2020_Country_and_Territory_Ratings_and_Statuses_FIW1973-2020.xlsx"
sheet = "Country Ratings, Statuses "

years = read_excel(excel_path,
                   range = paste0(sheet, "!B2:EL2"),
                   col_names = FALSE)[1,]

years = unlist(years)

curr_year = NA
for (i in 1:length(years)) {
  year = years[i]
  if (!is.na(year)) {
    curr_year = regmatches(year, gregexpr("[[:digit:]]+", year))[[1]][1]
  }
  year = curr_year
  years[i] = year
}

labels = c("PR", "CL", "Status")
headers = paste0(labels, "_", years)
headers = c("Country", headers)

dat = read_excel(excel_path,
                 sheet = "Country Ratings, Statuses ",
                 range = "A4:EL208",
                 col_names = FALSE)
names(dat) = headers
# Remove that odd entry "Serbia and Montenegro"
dat = dat[dat$Country != "Serbia and Montenegro", ]

col_count = length(names(dat))
dat = gather(dat,
             IndicatorYear,
             Value,
             names(dat)[2:col_count],
             factor_key = TRUE)
dat = separate(dat,
               IndicatorYear,
               c("Indicator", "Year"),
               "_")

dat = spread(dat, Indicator, Value)
dat$Code = countrycode(
  dat$Country,
  origin = 'country.name',
  destination = 'iso3c',
  custom_match = c(
    'Czechoslovakia' = 'CZE',
    'Kosovo' = 'XKX',
    'Micronesia' = 'FSM',
    'Yugoslavia' = 'YUG'
  )
)

dat = dat[, names(dat) != "Status"]
names(dat)[2] = "Political.Rights"
names(dat)[3] = "Civil.Liberties"

write.csv(dat, file = "../data/2020_Freedom_in_the_World_1972-2019.csv")
write_xlsx(dat, "../data/2020_Freedom_in_the_World_1972-2019.xlsx")