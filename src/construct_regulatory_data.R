library(writexl)
library(dplyr)
library(tidyr)

rm(list = ls())

dat.wjp = read.csv("../data/2020_WJP_Rule_Of_Law_2013-2020.csv")
dat.wgi = read.csv("../data/2020_Worldwide_Governance_Indicators_1996-2019.csv")
dat.cpia = read.csv("../data/2020_Country_Policy_Institutional_Assessments_2005-2019.csv")

#### Extract Regulatory from WJP

dat.wjp.regulatory = dat.wjp[, c(2:3, 7, 38:43)]
names(dat.wjp.regulatory) = c(
  "Country",
  "Code",
  "Year",
  "WJP.6.Regulatory_Enforcement",
  "WJP.6.1.Gov_Regulation_Effective",
  "WJP.6.2.Gov_Regulation_No_Improper_Effect",
  "WJP.6.3.Admin_Process_No_Delay",
  "WJP.6.4.Due_Process_Respected",
  "WJP.6.5.Gov_No_Expropriate_without_Pay"
)

dat.wjp.regulatory$CodeYear = paste0(dat.wjp.regulatory$Code, ".", dat.wjp.regulatory$Year)
dat.wjp.regulatory = dat.wjp.regulatory[,!(names(dat.wjp.regulatory) %in% c("Code", "Year"))]

#### Extract Regulatory from WGI
dat.wgi.regulatory = dat.wgi[dat.wgi$Indicator == "RegulatoryQuality", ][-1]
dat.wgi.regulatory$CodeYear = paste0(dat.wgi.regulatory$Code, ".", dat.wgi.regulatory$Year)
dat.wgi.regulatory = dat.wgi.regulatory[,!(names(dat.wgi.regulatory) %in% c("Code", "Year", "NumSrc", "Rank", "Indicator", "Lower", "Upper", "StdErr"))]
dat.wgi.regulatory = dat.wgi.regulatory[!is.na(dat.wgi.regulatory$Estimate), ]
names(dat.wgi.regulatory) = c("Country", "WGI.Regulatory_Quality", "CodeYear")


#### Extract Regulatory from CPIA
dat.cpia.regulatory = dat.cpia[dat.cpia$Indicator %in% c("BREG", "PADM"), ][-1]
dat.cpia.regulatory = dat.cpia.regulatory[, names(dat.cpia.regulatory) != "Indicator.Description"]
dat.cpia.regulatory = dat.cpia.regulatory[!is.na(dat.cpia.regulatory$Value),]
dat.cpia.regulatory = spread(dat.cpia.regulatory, Indicator, Value)
dat.cpia.regulatory$CodeYear = paste0(dat.cpia.regulatory$Code, ".", dat.cpia.regulatory$Year)
dat.cpia.regulatory = dat.cpia.regulatory[, !(names(dat.cpia.regulatory) %in% c("Code", "Year"))]
names(dat.cpia.regulatory)[2] = "CPIA.Business_Regulation"
names(dat.cpia.regulatory)[3] = "CPIA.Public_Administration"

dat.merged = merge(x = dat.wjp.regulatory, y = dat.wgi.regulatory, by = "CodeYear", all = TRUE)
dat.merged$Country.x = ifelse(is.na(dat.merged$Country.x), dat.merged$Country.y, dat.merged$Country.x)
dat.merged = dat.merged[, (names(dat.merged) != "Country.y")]
names(dat.merged)[2] = "Country"
dat.merged = merge(x = dat.merged, y = dat.cpia.regulatory, by = "CodeYear", all = TRUE)
dat.merged$Country.x = ifelse(is.na(dat.merged$Country.x), dat.merged$Country.y, dat.merged$Country.x)
dat.merged = dat.merged[, (names(dat.merged) != "Country.y")]
names(dat.merged)[2] = "Country"

dat.merged = separate(dat.merged, CodeYear, c("Code", "Year"), "[.]")

dat.merged = dat.merged %>%
  group_by(Code) %>%
  arrange(Country) %>%
  mutate(Country = Country[1])
dat.merged = dat.merged[, (names(dat.merged) != "CodeYear")]


write.csv(dat.merged, file = "../data/Combined_Regulatory_Index_data.csv")
write_xlsx(dat.merged, "../data/Combined_Regulatory_Index_data.xlsx")
