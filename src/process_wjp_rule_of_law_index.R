library(readxl)
library(writexl)
library(tidyr)
library(tibble)
library(dplyr)

rm(list = ls())

wjp_file_path = "../raw_data/2020_wjp_rule_of_law_index_historical_data.xlsx"
wjp_excel = read_excel(wjp_file_path)
sheets = excel_sheets(wjp_file_path)[-1]

extrat_num_from_string = function(string, as_numeric = FALSE) {
  strings = regmatches(string, gregexpr("[[:digit:]]+\\.*[[:digit:]]*", string))[[1]]
  result = "0"
  if (length(strings) > 0) {
    result = strings[length(strings)]
  }
  if (as_numeric) {
    result = as.numeric(result)
  }
  result
}

dat = NULL
for (i in 1:length(sheets)) {
  print(sheets[i])
  if (i == 1) {
    temp = read_excel(wjp_file_path, sheet = sheets[i])
  }
  else {
    temp = read_excel(wjp_file_path, sheet = sheets[i], col_names = FALSE)
    temp = temp[!is.na(temp$...1), ]
    temp.transpose = as.data.frame(t(temp), stringsAsFactors = FALSE)
    temp = temp.transpose[-1, ]
    colnames(temp) = as.list(temp.transpose[1, ])
  }
  
  # Process colnames
  col_names = colnames(temp)
  for (j in 1:length(col_names)) {
    if (extrat_num_from_string(col_names[j], TRUE) != 0) {
      colnames(temp)[j] = extrat_num_from_string(col_names[j], FALSE)
    }
  }
  
  year = extrat_num_from_string(sheets[i], TRUE)
  temp = add_column(temp, "Year" = year, .before = "1")
  
  if (i == 1) {
    sub_temp = temp[, c("1", "2", "3", "4", "5", "6", "7", "8")]
    colnames(sub_temp)
    temp = add_column(temp,
                      "Overall Score" = rowMeans(sub_temp, na.rm = TRUE),
                      .after = "Income Group")
    temp = add_column(temp, Abbreviation = NA, .after = "Country")
    
    for (name_idx in 1:length(names(temp))) {
      name = names(temp)[name_idx]
      if (!is.na(as.numeric(name))) {
        name.num = as.numeric(name)
        if (name.num >= 3 && name.num < 4) {
          name.num = name.num + 2
          names(temp)[name_idx] = name.num
        }
        else if (name.num >= 5 && name.num < 6) {
          name.num = name.num - 2
          names(temp)[name_idx] = name.num
        }
        
        if (grepl(".", name, fixed = TRUE)) {
          name = as.numeric(name)
          if (name < 2) {
            name = name - 0.1
            names(temp)[name_idx] = name
          }
        }
      }
    }
    
    dat = temp
  }
  else {
    for (name_idx in 1:length(names(temp))) {
      name = names(temp)[name_idx]
      if (grepl(": ", name, fixed = TRUE)) {
        pos = gregexpr(pattern = ": ", name)[[1]][1] + 2
        name = substr(name, pos, nchar(name))
        names(temp)[name_idx] = name
      } else if (name == "Country Code") {
        names(temp)[name_idx] = "Abbreviation"
      }
    }
    
    dat = rbind(dat, temp)
  }
}


dat = dat %>%
  group_by(Country) %>%
  arrange(Abbreviation) %>%
  mutate(Abbreviation = Abbreviation[1])

# Add back names
name_map = list(
  "1" = "Factor 1:Constraints on Government Powers",
  "1.1" = "1.1 Government powers are effectively limited by the legislature",
  "1.2" = "1.2 Government powers are effectively limited by the judiciary",
  "1.3" = "1.3 Government powers are effectively limited by independent auditing and review",
  "1.4" = "1.4 Government officials are sanctioned for misconduct",
  "1.5" = "1.5 Government powers are subject to non-governmental checks",
  "1.6" = "1.6 Transition of power is subject to the law",
  "2" = "Factor 2:Absence of Corruption",
  "2.1" = "2.1 Government officials in the executive branch do not use public office for private gain",
  "2.2" = "2.2 Government officials in the judicial branch do not use public office for private gain",
  "2.3" = "2.3 Government officials in the police and the military do not use public office for private gain",
  "2.4" = "2.4 Government officials in the legislative branch do not use public office for private gain",
  "3" = "Factor 3:Open Government ",
  "3.1" = "3.1 The laws are publicized and accessible",
  "3.2" = "3.2 The laws are stable",
  "3.3" = "3.3 Right to petition the government and public participation",
  "3.4" = "3.4 Official information is available on request",
  "4" = "Factor 4:Fundamental Rights",
  "4.1" = "4.1 Equal treatment and absence of discrimination",
  "4.2" = "4.2 The right to life and security of the person is effectively guaranteed",
  "4.3" = "4.3 Due process of law and rights of the accused",
  "4.4" = "4.4 Freedom of opinion and expression is effectively guaranteed",
  "4.5" = "4.5 Freedom of belief and religion is effectively guaranteed",
  "4.6" = "4.6 Freedom from arbitrary interference with privacy is effectively guaranteed",
  "4.7" = "4.7 Freedom of assembly and association is effectively guaranteed",
  "4.8" = "4.8 Fundamental labor rights are effectively guaranteed",
  "5" = "Factor 5:Order and Security",
  "5.1" = "5.1 Crime is effectively controlled",
  "5.2" = "5.2 Civil conflict is effectively limited",
  "5.3" = "5.3 People do not resort to violence to redress personal grievances",
  "6" = "Factor 6:Regulatory Enforcement",
  "6.1" = "6.1 Government regulations are effectively enforced",
  "6.2" = "6.2 Government regulations are applied and enforced without improper influence",
  "6.3" = "6.3 Administrative proceedings are conducted without unreasonable delay",
  "6.4" = "6.4 Due process is respected in administrative proceedings",
  "6.5" = "6.5 The Government does not expropriate without adequate compensation",
  "7" = "Factor 7:Civil Justice",
  "7.1" = "7.1 People can access and afford civil justice",
  "7.2" = "7.2 Civil justice is free of discrimination",
  "7.3" = "7.3 Civil justice is free of corruption",
  "7.4" = "7.4 Civil justice is free of improper government influence",
  "7.5" = "7.5 Civil justice is not subject to unreasonable delays",
  "7.6" = "7.6 Civil justice is effectively enforced",
  "7.7" = "7.7 ADR is accessible,
  impartial,
  and effective",
  "8" = "Factor 8:Criminal Justice",
  "8.1" = "8.1 Criminal investigation system is effective",
  "8.2" = "8.2 Criminal adjudication system is timely and effective",
  "8.3" = "8.3 Correctional system is effective in reducing criminal behavior",
  "8.4" = "8.4 Criminal system is impartial",
  "8.5" = "8.5 Criminal system is free of corruption",
  "8.6" = "8.6 Criminal system is free of improper government influence",
  "8.7" = "8.7 Due process of law and rights of the accused"
)

dat.1 = dat[, 1:6]
dat.2 = dat[, 7:length(names(dat))]
dat.2 = dat.2[, order(names(dat.2))]
dat = merge(dat.1, dat.2, by.x = 0, by.y = 0)[, -1]

for (i in 1:length(names(dat))) {
  if (names(dat)[i] %in% names(name_map)) {
    names(dat)[i] = name_map[names(dat)[i]]
  }
}

dat = dat %>%
  group_by(Country) %>%
  arrange(Year, .by_group = TRUE)

write.csv(dat, file = "../data/2020_WJP_Rule_Of_Law_2013-2020.csv")
write_xlsx(dat, "../data/2020_WJP_Rule_Of_Law_2013-2020.xlsx")
