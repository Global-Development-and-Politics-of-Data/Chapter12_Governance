library(writexl)
library(dplyr)
library(tidyr)

rm(list = ls())

dat.wjp = read.csv("../data/2020_WJP_Rule_Of_Law_2013-2020.csv")
dat.wgi = read.csv("../data/2020_Worldwide_Governance_Indicators_1996-2019.csv")
dat.cpia = read.csv("../data/2020_Country_Policy_Institutional_Assessments_2005-2019.csv")

#### Extract corruption from WJP
dat.wjp.meta = dat.wjp[, 2:3]
dat.wjp.meta$Year = dat.wjp$Year
dat.wjp.corruption = dat.wjp[, 15:19]
dat.wjp.corruption = merge(dat.wjp.meta,
                           dat.wjp.corruption,
                           by.x = 0,
                           by.y = 0)[-1]
names(dat.wjp.corruption) = c(
  "Country",
  "Code",
  "Year",
  "WJP.Factor.2.Absence.of.Corruption",
  "WJP.X2.1.Government.officials.in.the.executive.branch.do.not.use.public.office.for.private.gain",
  "WJP.X2.2.Government.officials.in.the.judicial.branch.do.not.use.public.office.for.private.gain",
  "WJP.X2.3.Government.officials.in.the.police.and.the.military.do.not.use.public.office.for.private.gain",
  "WJP.X2.4.Government.officials.in.the.legislative.branch.do.not.use.public.office.for.private.gain"
)

dat.wjp.corruption$CodeYear = paste0(dat.wjp.corruption$Code, ".", dat.wjp.corruption$Year)
dat.wjp.corruption = dat.wjp.corruption[,!(names(dat.wjp.corruption) %in% c("Code", "Year"))]
dat.wjp.corruption = dat.wjp.corruption[!is.na(dat.wjp.corruption$WJP.Factor.2.Absence.of.Corruption), ]

#### Extract corruption from WGI
dat.wgi.corruption = dat.wgi[dat.wgi$Indicator == "ControlofCorruption", ][-1]
dat.wgi.corruption$CodeYear = paste0(dat.wgi.corruption$Code, ".", dat.wgi.corruption$Year)
dat.wgi.corruption = dat.wgi.corruption[,!(names(dat.wgi.corruption) %in% c("Code", "Year", "NumSrc", "Rank", "Indicator", "Lower", "Upper", "StdErr"))]
dat.wgi.corruption = dat.wgi.corruption[!is.na(dat.wgi.corruption$WGI.Estimate), ]
names(dat.wgi.corruption) = c("Country", "WGI.Estimate", "CodeYear")


#### Extract corruption from CPIA
dat.cpia.corruption = dat.cpia[dat.cpia$Indicator == "TRAN", ][-1]
dat.cpia.corruption$CodeYear = paste0(dat.cpia.corruption$Code, ".", dat.cpia.corruption$Year)
dat.cpia.corruption = dat.cpia.corruption[, names(dat.cpia.corruption) %in% c("CodeYear", "Value", "Country")]
names(dat.cpia.corruption)[2] = "CPIA.transparency.accountability.corruption"
dat.cpia.corruption = dat.cpia.corruption[!is.na(dat.cpia.corruption$CPIA.transparency.accountability.corruption), ]


dat.merged = merge(x = dat.wjp.corruption, y = dat.wgi.corruption, by = "CodeYear", all = TRUE)
dat.merged$Country.x = ifelse(is.na(dat.merged$Country.x), dat.merged$Country.y, dat.merged$Country.x)
dat.merged = dat.merged[, (names(dat.merged) != "Country.y")]
names(dat.merged)[2] = "Country"
dat.merged = merge(x = dat.merged, y = dat.cpia.corruption, by = "CodeYear", all = TRUE)
dat.merged$Country.x = ifelse(is.na(dat.merged$Country.x), dat.merged$Country.y, dat.merged$Country.x)
dat.merged = dat.merged[, (names(dat.merged) != "Country.y")]
names(dat.merged)[2] = "Country"

dat.merged = separate(dat.merged, CodeYear, c("Code", "Year"), "[.]")

dat.merged = dat.merged %>%
  group_by(Code) %>%
  arrange(Country) %>%
  mutate(Country = Country[1])
dat.merged = dat.merged[, (names(dat.merged) != "CodeYear")]


write.csv(dat.merged, file = "../data/Combined_Corruption_Index_data.csv")
write_xlsx(dat.merged, "../data/Combined_Corruption_Index_data.xlsx")
