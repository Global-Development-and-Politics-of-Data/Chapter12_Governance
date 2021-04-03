library(writexl)

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

dat.wjp.corruption$CodeYear = paste0(dat.wjp.corruption$Code, dat.wjp.corruption$Year)

#### Extract corruption from WGI
dat.wgi.corruption = dat.wgi[dat.wgi$Indicator == "ControlofCorruption", ][-1]
dat.wgi.corruption$CodeYear = paste0(dat.wgi.corruption$Code, dat.wgi.corruption$Year)
dat.wgi.corruption = dat.wgi.corruption[,!(names(dat.wgi.corruption) %in% c("Country.Territory", "Code", "Year", "NumSrc", "Rank", "Indicator", "Lower", "Upper", "StdErr"))]

names(dat.wgi.corruption) = c("WGI.Estimate", "CodeYear")


#### Extract corruption from CPIA



dat.merged = merge(x = dat.wjp.corruption, y = dat.wgi.corruption, by = "CodeYear", all = TRUE)

write.csv(dat.merged, file = "../data/Combined_Corruption_Index_data.csv")
write_xlsx(dat.merged, "../data/Combined_Corruption_Index_data.xlsx")
