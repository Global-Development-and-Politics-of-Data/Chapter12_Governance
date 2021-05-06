# R Scripts
- **process_wgi_data.R** - R script to process World Governance Indicators. Extracts all 6 indicators data from separate sheets in Excel file, combines them in one data set, reshapes to long format, and exports user-friendly data into Excel format and CSV format
- **process_wjp_data.R** - R script to process World Justice Project data. Extracts different years of data from different excel sheets, converts each year of data into unified format, combines and reshape data into long format, then exports user-friendly data into Excel format and CSV format
- **process_cpia_data.R** - R script to process Country Policy And Institutional Assessment data. Reshapes data into long format and exports user-friendly data into Excel format and CSV format
- **process_fiw_data.R** - R script to process Freedom in the World data. Converts data into right format, reshape data from wide format to long by year, then exports user-friendly data into Excel format and CSV format
- **construct_corruption_data.R** - R script to combine corruption related indicators from WGI, WJP, and CPIA into one composite data file in the data folder (data/Combined_Corruption_Index_data)
- **construct_rule_of_law_data.R** - R script to combine rule of law related indicators from WGI, WJP, and CPIA into one composite data file in the data folder (data/Combined_Rule_of_Law_Index_data)
- **construct_regulatory_data.R** - R script to combine regulatory related indicators from WGI, WJP, and CPIA into one composite data file in the data folder (data/Combined_Regulatory_Index_data)

## Getting Started with R
### Why R?
RStudio is an open-source tool for programming in R. RStudio is a flexible tool that helps you create readable analyses, and keeps your code, images, comments, and plots together in one place. It’s worth knowing about the capabilities of RStudio for data analysis and programming in R.

### Installation
1. Download R https://cran.r-project.org/
- MAC OS X
  
    Select the Download R for (Mac) OSX option.
Look for the most up-to-date version of R (new versions are released frequently and appear toward the top of the page) and click the .pkg file to download.
Open the .pkg file and follow the standard instructions for installing applications on MAC OS X.
Drag and drop the R application into the Applications folder.

- Windows

    Select the Download R for Windows option.
Select base, since this is our first installation of R on our computer.
Follow the standard instructions for installing programs for Windows. If we are asked to select Customize Startup or Accept Default Startup Options, choose the default options.

- Linux/Ubuntu

    Select the Download R for Linux option.
Select the Ubuntu option.
Alternatively, select the Linux package management system relevant to you if you are not using Ubuntu.

2. Install RStudio 
   
   Now that R is installed, we can install RStudio. Navigate to the [RStudio downloads page](https://www.rstudio.com/products/rstudio/download/). When we reach the RStudio downloads page, let’s click the “Download” button of the **RStudio Desktop Free** option

### Tutorial and Sample R scripts
- **Chapter 12 Data Module - Corrption.R**
- **Chapter 12 Data Module - Regulatory Quality.R**
- **Chapter 12 Data Module - Rule of Law.R**

Additional R resources for beginner: https://thatdatatho.com/r-resources-beginner-advanced/
