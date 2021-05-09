library(readxl)
library(writexl)
library(tidyr)
library(corrplot)
library(latticeExtra)

rm(list = ls())
# Q1 and Q2: We have save the raw data sets in both Dropbox and GitHub.

# Q3: Load data in excel file
dat = NULL
sheets = c(
  "VoiceandAccountability",
  "Political StabilityNoViolence",
  "GovernmentEffectiveness",
  "RegulatoryQuality",
  "RuleofLaw",
  "ControlofCorruption"
)
newNames = c(
  "VoiceandAccountability",
  "PoliticalStability",
  "GovernmentEffectiveness",
  "RegulatoryQuality",
  "RuleofLaw",
  "ControlofCorruption"
)
for (i in 1:length(sheets)) {
  years = read_excel(
    "../raw_data/2020_Worldwide_Governance_Indicators_1996-2019t.xlsx",
    range = paste0(sheets[i], "!C14:DX14"),
    col_names = FALSE,
    col_types = "numeric"
  )
  temp = read_excel(
    "../raw_data/2020_Worldwide_Governance_Indicators_1996-2019t.xlsx",
    range = paste0(sheets[i], "!A15:DX229")
  )
  colnames_temp = colnames(temp)
  col_idx = 1
  for (colname in colnames_temp[3:length(colnames_temp)]) {
    mod = col_idx %% 6
    year = years[[1, col_idx]]
    if (mod == 1) {
      colnames(temp)[col_idx + 2] = paste0("Estimate.", year)
    } else if (mod == 2) {
      colnames(temp)[col_idx + 2] = paste0("StdErr.", year)
    } else if (mod == 3) {
      colnames(temp)[col_idx + 2] = paste0("NumSrc.", year)
    } else if (mod == 4) {
      colnames(temp)[col_idx + 2] = paste0("Rank.", year)
    } else if (mod == 5) {
      colnames(temp)[col_idx + 2] = paste0("Lower.", year)
    } else {
      colnames(temp)[col_idx + 2] = paste0("Upper.", year)
    }
    col_idx = col_idx + 1
  }
  
  temp = gather(temp, key, value, Estimate.1996:Upper.2019) %>%
    separate(col = key,
             into = c("key", "Year"),
             convert = TRUE) %>%
    spread(key, value)
  temp$Indicator = newNames[i]
  if (i == 1) {
    dat = temp
  } else {
    dat = rbind(dat, temp)
  }
}
rm(
  list = c(
    "temp",
    "years",
    "col_idx",
    "colname",
    "colnames_temp",
    "mod",
    "newNames",
    "sheets",
    "year",
    "i"
  )
)

# Convert to numeric
dat[, c(3:9)] <- sapply(dat[, c(3:9)], as.numeric)

# write.csv(dat, file = "../data/2020_Worldwide_Governance_Indicators_1996-2019.csv")
# write_xlsx(dat, "../data/2020_Worldwide_Governance_Indicators_1996-2019.xlsx")

names(dat)[1] = "Country"

## China plot percentile over year
dat.china = dat[dat$Code=="CHN",]
dat.china = dat.china[names(dat.china) %in% c("Country", "Code", "Year", "Rank", "Indicator")] %>% 
  spread(Indicator, Rank)
xyplot(
  ControlofCorruption + GovernmentEffectiveness + RegulatoryQuality + RuleofLaw + VoiceandAccountability ~ Year,
  dat.china,
  type = "l",
  lwd = "2",
  auto.key=T,
  ylab = "Percentile",
  scales = list(tick.number = 11)
)

## Further analysis
# Perform a correlation test on the 2010 to 2019 data
dat.2010_19 = dat[dat$Year >= 2010,]
dat.2010_19 = dat.2010_19[names(dat.2010_19) %in% c("Country", "Code", "Year", "Estimate", "Indicator")]
dat.2010_19 = spread(dat.2010_19, Indicator, Estimate)
dat.2010_19 = dat.2010_19[!is.na(dat.2010_19$ControlofCorruption),]
dat.2010_19 = dat.2010_19[!is.na(dat.2010_19$VoiceandAccountability),]
dat.2010_19 = dat.2010_19[!is.na(dat.2010_19$PoliticalStability),]
dat.2010_19$CodeYear = paste0(dat.2010_19$Code, dat.2010_19$Year)
M = cor(dat.2010_19[c(4:9)])
corrplot(M, type="lower", method="shade")

# Introduce GDP data from World Bank
dat.gdp = read.csv("../raw_data/2020_Worldwide_GDP.csv")
temp = gather(dat.gdp, key, GDP, X1960:X2020)
temp = temp[!is.na(temp$GDP),]
temp = temp[temp$GDP != "",]
temp$GDP = as.numeric(temp$GDP)
temp$Year = as.numeric(substr(temp$key, 2, 5))
temp = temp[temp$Year >= 2010, ]
dat.gdp.2010_19 = temp[names(temp) %in% c("Country.Code", "Year", "GDP")]
dat.gdp.2010_19$CodeYear = paste0(dat.gdp.2010_19$Country.Code, dat.gdp.2010_19$Year)
dat.2010_19.merge = merge(dat.2010_19,
                       dat.gdp.2010_19,
                       by = "CodeYear")

M = cor(dat.2010_19.merge[c(5:10, 12)])
corrplot(M, type="lower", method="shade") 
# From the heat map we can see GDP has relatively higher correlation with 
# GovernmentEffectiveness (GE) and RuleofLaw

# Check correlation on country level
library(dplyr)
temp = dat.2010_19.merge %>%
  group_by(Country) %>%
  summarize(Correlation=cor(GovernmentEffectiveness, GDP))

# Show countries that have high correlation between GE and GDP
temp[abs(temp$Correlation) >= 0.7,]

# Check percentage based on common cutoff for correlation test
temp$corr_level = ifelse(abs(temp$Correlation)>0.9, "(0.9-1) Very High", "(0.7-0.9) High")
temp$corr_level = ifelse(abs(temp$Correlation)<=0.7, "(0.5-0.7) Moderate", temp$corr_level)
temp$corr_level = ifelse(abs(temp$Correlation)<=0.5, "(0.3-0.5) Low", temp$corr_level)
temp$corr_level = ifelse(abs(temp$Correlation)<=0.3, "(0-0.3) Negligible", temp$corr_level)
percent_table = round(table(temp$corr_level) / length(temp$corr_level) * 100, 0)

# Plot distribution
bp = barplot(
  percent_table,
  space = 1,
  col = c("LightCyan", "PaleTurquoise", "PaleTurquoise", "DeepSkyBlue", "DeepSkyBlue"),
  ylim = c(0, 30),
  ylab = "Percentage (%)",
  xlab = "Correlation Level",
  main = "Distribution of Correlation between Goveronment Effectiveness and GDP",
  sub = "Source: World Bank Data 2010-2019"
)
text(bp, 0, paste0(percent_table, "%"), cex = 1, pos = 3)


#### Check Fiji (FJI)
dat.2010_19.FJI = dat.2010_19.merge[dat.2010_19.merge$Code == "FJI",]
names(dat.2010_19.FJI)[4] = "Year"

p1 = xyplot(
  ControlofCorruption + GovernmentEffectiveness + RegulatoryQuality + RuleofLaw ~ Year,
  dat.2010_19.FJI,
  type = "l",
  lwd = 2,
  ylab = "WGI Estimate"
)

p2 = xyplot(GDP ~ Year, dat.2010_19.FJI, type = "l", lwd=3, col="orange")

doubleYScale(
  p1,
  p2,
  text = c(
    "ControlofCorruption",
    "GovernmentEffectiveness",
    "RegulatoryQuality",
    "RuleofLaw",
    "GDP"
  ),
  add.ylab2 = TRUE,
  use.style = FALSE
)
