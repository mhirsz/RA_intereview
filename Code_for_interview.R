 # The script explores AACT information about clinical phase 2/3, first registered in 2019,
 # with overall status completed. A summary table: Summary_of_studies.csv is generated.

library(RPostgreSQL)
library(tidyverse)

drv <- dbDriver('PostgreSQL')     # obtain a driver for PostgreSQL resources

  ## To connect to AACT, please, insert your own credentials
con <- dbConnect(drv, dbname ="aact",host="aact-db.ctti-clinicaltrials.org", port=5432, 
                 user="", password="")    

 ## selection of a few rows and all columns for exploring the data set
header <- dbGetQuery(con, "select * from studies limit 5") 
 
## selection of columns of interest
sort(names(header)) 

 ## exploration of chosen columns of interest
phases <- dbGetQuery(con, "select distinct phase from studies") 
phases  # selection of phase 2 & 3

study_type <- dbGetQuery(con, "select distinct study_type from studies
              where phase in ('Phase 2','Phase 3','Phase 2/Phase 3')")
study_type  # all phase2/3 studies are interventional (no need to include in further queries)

status <- dbGetQuery(con, "select distinct overall_status from studies 
              where phase in ('Phase 2','Phase 3','Phase 2/Phase 3')")
status  # selection of completed studies

baseline_pop<- dbGetQuery(con, "select distinct baseline_population from studies 
              where phase in ('Phase 2','Phase 3','Phase 2/Phase 3')")
baseline_pop  # NOT INCLUDED (too many levels)

n_arms <- dbGetQuery(con, "select count (number_of_arms) from studies 
              where phase in ('Phase 2','Phase 3','Phase 2/Phase 3') group by number_of_arms")
n_arms

enrollment <- dbGetQuery(con, "select distinct enrollment from studies 
              where phase in ('Phase 2','Phase 3','Phase 2/Phase 3')")
enrollment  # number of patients enrolled in trials

 ## Complete SQL query
selected_studies <- dbGetQuery(con, "select phase, enrollment, number_of_arms from studies where 
  phase in ('Phase 2','Phase 3','Phase 2/Phase 3') and
  overall_status = 'Completed' and study_first_submitted_date > '2018-12-31' and
                                   study_first_submitted_date< '2020-01-01'")
 
 ## To explore which summary is the most informative 
hist(selected_studies$number_of_arms) 

 ## Summarising data from the selected studies
selected_studies %>% group_by(phase) %>% summarise(N=n(),
      Proportion_with_1_arm = sum(number_of_arms==1)/n(), 
      Total_enrollment = sum(enrollment)) %>% 
  write.csv("Summary_of_studies.csv")









