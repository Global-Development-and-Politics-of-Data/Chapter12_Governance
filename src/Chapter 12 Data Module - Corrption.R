##### CHAPTER 12: GOVERNANCE - DATA MODULE #####

# See the Data Module Instruction page for instructions. 

###### Scenario #####

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
  labs(title = "Best Plot Ever", subtitle = "...r", x = "Year", y = "Level of Corruption")

# Which indicator do you think represents your country best? 
# Remember to give your graph a descriptive title and labels. Feel free to look online for other ways to personalize your graph 
# in terms of background, color, line size, and other features. 

# When you are ready, save your graph to your working directory. 
ggsave(".../corruption_graph.png", width = 3, height = 2, dpi = 300, p1)

