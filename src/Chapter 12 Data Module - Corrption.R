##### CHAPTER 12: GOVERNANCE - DATA MODULE #####

# In this next section, you will be given a scenario, which presents you with a specific motivation for choosing, visualizing, 
# and presenting data in a specific way. Your goal will be to choose an indicator that shows off your country in the best light. 
# This exercise will allow you to investigate and compare data together in order to decide which indicator presents your country most 
# advantageously regarding an aspect of governance. By being placed in a situation where you are incentivized to cherry-pick through 
# data, you will learn how easily data can be manipulated to tell different stories. After this exercise, we hope you will look at data 
# visualizations and comparative statistics with a new sense of understanding, and be able to question the motivations and intentions 
# behind the data that might be painting a specific picture. 

# You will make a line graph in R showing a governance trend in your country over a period of 5 years. Then, you 
# will prepare a short presentation where you will show how your country is improving and why your data is reliable. In this section, 
# you will ask the following questions: 
#  1)	How can we examine specific data in R? 
#  2)	How do we create a simple line graph using ggplot in R? 
#  3)	How can the cherry-picking of data happen?

# For the following exercise, read each scenario thoroughly. Then, use R or Excel to import the Governance Chapter data set. 
# Examine each indicator carefully and decide which one is best to use for your scenario. (Remember, some indicators are composite 
# indicators, which means they are made up of several other indicators also in the data set that were combined into one variable. 
# You can choose either the more basic indicators or a composite indicator.) You will find the basic information about the indicator 
# you chose and create a simple line graph showing the trajectory of your country. 

# Then, plan a short presentation where you present your data and best argument to the class. After you finish the presentation, 
# discuss: What led you to pick one indicator over another? What critiques might data-savvy nay-sayers voice about why your 
# presentation? How would you respond? 
 
###### Scenarios #####

### Control of Corruption ###

# Chose one of the following countries: 
# Ecuador 
# Singapore
# Tanzania

# You are on the Tourism Board in your country.  
# Your department is planning a presentation to convince FIFA to allow your country to host the next World Cup. 
# The last time you applied, your country was rejected because of high levels of corruption. Now, your boss has asked you to 
# create a presentation that shows how much your country’s ranking on control of corruption has improved in the last few years. 

# You will be able to use the code provided in this R document to complete this section, but feel free to use any other outside 
# information you have. 

# First, lets clear the environment. This makes sure that there aren't any other variables, datasets, or anything else in the background 
# that might interfere with a new project. 
# (Hint: To run code, just highlight the code you want to run and click on the "Run" button in the upper right-hand corner of this R screen.)
rm(list = ls())

# Then, set the working directory. Your working directory is the folder you want to save all your datasets and visualizations to. It is also 
# usually the folder you save other data you want to use in. 
# Copy the full file path of the folder you want to save your work to. You can do this by using the "Get Info" option in the folder settings. 
# (IMPORTANT NOTE: Searching for information and how-tos online is part of being an excellenet data analyst! Feel free to look up how to do anything 
# you don't understand or want more information on.)
setwd("~/...")

# Download the data from Github
# First, make sure "curl" is installed on your computer. 
if(!require("curl")) install.packages("curl")
# Now, let's call the "curl" package, which tells R that you want to use commands from that specific library.
library(curl)
# Finally, download the Chapter 12 Corruption dataset from our GitHub. It will be called "corruption_data".
corruption_data <- read.csv(curl("https://raw.githubusercontent.com/Global-Development-and-Politics-of-Data/Chapter12_Governance/main/data/Combined_Corruption_Index_data.csv"))

# Now you can examine the data for your country. Using a subset is a great way to do this. 
if(!require("data.table")) install.packages("data.table")
library(data.table) 
corr_subset <- subset(corruption_data, Country == "...") 
# Note: You can also subset certain years by using the code: years_subset <- subset(corruption_data, Year >= 2014)

# Let's create some different line graphs and see how they look: 
if(!require("ggplot2")) install.packages("ggplot2")
library(ggplot2)

# The basic ggplot syntax is: 
# ggplot(data = , aes(x = , y = , color = , linetype = )) +  geom() + [other specifications]
# - data = the dataset you want to work with
# - aes = stands for aesthetic. Here, you will specify the details of the graph. 
# - geom = specifies what type of graph you want to create 
# - other features can include the title, color scheme, etc. 

# (Hint: You can use the command "summary" to find out more information about your data and also copy and paste variable names.)
summary(corr_subset)

# Make your plot
ggplot(data = corr_subset,
       aes(y = ... , x = Year)) + geom_line(color = "blue") + geom_point(size = 2, color = "red") +
  labs(title = "Best Plot Ever", subtitle = "Absence of Corruption in Ecuador", x = "Year", y = "Levels of Corruption")

# Which indicator do you think represents your country best? 
# Remember to give your graph a descriptive title and labels. Feel free to look online for other ways to personalize your graph 
# in terms of background, color, line size, and other features. 

# When you are ready, save your graph to your working directory. 
ggsave(".../corruption_graph.png", width = 3, height = 2, dpi = 300, p1)

