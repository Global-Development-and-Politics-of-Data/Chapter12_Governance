library(readxl)
library(writexl)
library(tidyr)

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

write.csv(dat, file = "../data/2020_Worldwide_Governance_Indicators_1996-2019.csv")
write_xlsx(dat, "../data/2020_Worldwide_Governance_Indicators_1996-2019.xlsx")

dat.2018 = dat[dat$Year == 2018, ]
# Save year 2018 data in Excel for
write_xlsx(dat.2018, "../data/2018_Worldwide_Governance_Indicators.xlsx")
