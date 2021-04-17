library(writexl)
library(dplyr)
library(tidyr)

rm(list = ls())

dat.wjp = read.csv("../data/2020_WJP_Rule_Of_Law_2013-2020.csv")
dat.wgi = read.csv("../data/2020_Worldwide_Governance_Indicators_1996-2019.csv")
dat.cpia = read.csv("../data/2020_Country_Policy_Institutional_Assessments_2005-2019.csv")

#### Extract rule of law from WJP
dat.wjp.meta = dat.wjp[, 2:3]
dat.wjp.meta$Year = dat.wjp$Year
dat.wjp.rule_of_law = dat.wjp[, c(34, 44, 52)]
dat.wjp.rule_of_law = merge(dat.wjp.meta,
                           dat.wjp.rule_of_law,
                           by.x = 0,
                           by.y = 0)[-1]
names(dat.wjp.rule_of_law) = c(
  "Country",
  "Code",
  "Year",
  "WJP.5.Order_and_Security",
  "WJP.7.Civil_Justice",
  "WJP.8.Criminal_Justice"
)

dat.wjp.rule_of_law$CodeYear = paste0(dat.wjp.rule_of_law$Code, ".", dat.wjp.rule_of_law$Year)
dat.wjp.rule_of_law = dat.wjp.rule_of_law[,!(names(dat.wjp.rule_of_law) %in% c("Code", "Year"))]

#### Extract rule_of_law from WGI
dat.wgi.rule_of_law = dat.wgi[dat.wgi$Indicator == "RuleofLaw", ][-1]
dat.wgi.rule_of_law$CodeYear = paste0(dat.wgi.rule_of_law$Code, ".", dat.wgi.rule_of_law$Year)
dat.wgi.rule_of_law = dat.wgi.rule_of_law[,!(names(dat.wgi.rule_of_law) %in% c("Code", "Year", "NumSrc", "Rank", "Indicator", "Lower", "Upper", "StdErr"))]
dat.wgi.rule_of_law = dat.wgi.rule_of_law[!is.na(dat.wgi.rule_of_law$Estimate), ]
names(dat.wgi.rule_of_law) = c("Country", "WGI.Rule_of_Law", "CodeYear")


#### Extract rule_of_law from CPIA
dat.cpia.rule_of_law = dat.cpia[dat.cpia$Indicator == "PROP", ][-1]
dat.cpia.rule_of_law$CodeYear = paste0(dat.cpia.rule_of_law$Code, ".", dat.cpia.rule_of_law$Year)
dat.cpia.rule_of_law = dat.cpia.rule_of_law[, names(dat.cpia.rule_of_law) %in% c("CodeYear", "Value", "Country")]
names(dat.cpia.rule_of_law)[2] = "CPIA.Rule_Based_Governance"
dat.cpia.rule_of_law = dat.cpia.rule_of_law[!is.na(dat.cpia.rule_of_law$CPIA.Rule_Based_Governance), ]


dat.merged = merge(x = dat.wjp.rule_of_law, y = dat.wgi.rule_of_law, by = "CodeYear", all = TRUE)
dat.merged$Country.x = ifelse(is.na(dat.merged$Country.x), dat.merged$Country.y, dat.merged$Country.x)
dat.merged = dat.merged[, (names(dat.merged) != "Country.y")]
names(dat.merged)[2] = "Country"
dat.merged = merge(x = dat.merged, y = dat.cpia.rule_of_law, by = "CodeYear", all = TRUE)
dat.merged$Country.x = ifelse(is.na(dat.merged$Country.x), dat.merged$Country.y, dat.merged$Country.x)
dat.merged = dat.merged[, (names(dat.merged) != "Country.y")]
names(dat.merged)[2] = "Country"

dat.merged = separate(dat.merged, CodeYear, c("Code", "Year"), "[.]")

dat.merged = dat.merged %>%
  group_by(Code) %>%
  arrange(Country) %>%
  mutate(Country = Country[1])
dat.merged = dat.merged[, (names(dat.merged) != "CodeYear")]


write.csv(dat.merged, file = "../data/Combined_Rule_of_Law_Index_data.csv")
write_xlsx(dat.merged, "../data/Combined_Rule_of_Law_Index_data.xlsx")
