library(readxl)
#read the data set
df<- read_excel("Online Retail.xlsx")

library(tidyverse)

#clean the data set 
#remove duplicates
df <-distinct(df)

#remove errors and nulls
df <-df %>% 
  filter(df$Quantity > 0 & df$UnitPrice > 0.12)
df <-df %>% 
  drop_na(CustomerID)

# explore data after cleaning 
glimpse(df)

#create cohort colms to help in analysis

df$invoice_year <-as.numeric(format(df$InvoiceDate,'%Y'))
df        
df$invoice_month <-as.numeric(format(df$InvoiceDate,'%m'))

#first purchase date for each customer
df <- df %>% 
  group_by(CustomerID) %>% 
  mutate(customr_first_ac = min(InvoiceDate)) %>% 
  ungroup()
#create time colms to help us create cohort table
df$coh_year <- as.numeric(format(df$customr_first_ac,"%Y"))
df$coh_month <- as.numeric(format(df$customr_first_ac,"%m"))        

df$year_diff <- df$invoice_year-df$coh_year
df$month_diff <- df$invoice_month -df$coh_month
df

#create cohort_index
df$cohort_index <- df$year_diff*12 + df$month_diff
unique(df$cohort_index)


df$cus_first_ac <- ymd(format(df$customr_first_ac,"%Y-%m-01"))
#group the data with the cohort index
df2 <- df %>% 
  group_by(cus_first_ac,cohort_index) %>% 
  summarise( customer_number=n_distinct(CustomerID))

View(df2)

# finally create cohort table 
cohort_table <-pivot_wider(df2,names_from = cohort_index ,
                           values_from =customer_number, values_fill= 0)
cohort_table

#create cohort table percentage %(Retention rate %)
cohort_table_pcts<-tibble("cohort_date" = cohort_table$cus_first_ac ,
                             signif( cohort_table[,2:ncol(cohort_table)]
                            /cohort_table[["0"]],2))

cohort_table_pcts 

#prepare the data for plotting
data<-data.frame(df2)
data

ggplot(data,aes(x= cohort_index, y= reorder(cus_first_ac,desc(cus_first_ac))))+
  geom_tile(aes(fill = customer_number))+
  scale_fill_continuous(guide= FALSE)+
  geom_text(aes( label = customer_number), color = "white" )+
  xlab("cohort_age")+ ylab("cohort")
  
#prepare for percentage plot
pct_table <- cohort_table_pcts %>% 
  pivot_longer(!cohort_date,names_to ="cohort_index", 
               values_to ="customer_pct")

View(pct_table)
data2 <- data.frame(pct_table)

class(data2$cohort_index) 

data2$cohort_index <- as.numeric(data2$cohort_index)

class(data2$cohort_index)

#percentage plot

ggplot(data2,aes(x= cohort_index, y= reorder(cohort_date,desc(cohort_date))))+
  geom_tile(aes(fill = customer_pct))+
  scale_fill_continuous(guide= FALSE)+
  geom_text(aes( label = customer_pct), color = "white" )+
  xlab("cohort_age")+ ylab("cohort")

 
  
  
       
  

