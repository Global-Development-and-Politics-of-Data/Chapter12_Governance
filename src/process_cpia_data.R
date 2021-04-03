library(readxl)
library(writexl)
library(dplyr)

rm(list = ls())

cpia_excel_path = "../raw_data/2020_Country_Policy_and_Institutional_Assessments.xlsx"

dat = read_excel(cpia_excel_path, sheet = "Data")

extract_indicator_shortname = function(x, out) {
  long_name = x[4]
  short_name = strsplit(long_name, "[.]")[[1]][3]
  out = short_name
}

dat$`Indicator Code` = apply(dat, 1, extract_indicator_shortname)

dat = reshape(
  dat,
  direction = "long",
  varying = names(dat)[5:19],
  v.names = "Value",
  idvar = c("Country Code", "Indicator Code"),
  timevar = "Year",
  times = names(dat)[5:19]
)

names(dat) = c("Country",
               "Code",
               "Indicator.Description",
               "Indicator",
               "Year",
               "Value")

dat = dat %>%
  group_by(Code) %>%
  arrange(Year, .by_group = TRUE)

write.csv(dat, file = "../data/2020_Country_Policy_Institutional_Assessments_2005-2019.csv")
write_xlsx(dat, "../data/2020_Country_Policy_Institutional_Assessments_2005-2019.xlsx")