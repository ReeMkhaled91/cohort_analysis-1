select * from clean_pandas
--- cohort analysis prepration
select CustomerID , 
min(invoicedate) as first_date,
Datefromparts(year(min(invoicedate)),month(min(invoicedate)),1) as cohort_date
into #cohort
from clean_pandas
group by CustomerID

select * from #cohort

--- create cohort index
select r.* ,
cohort_index = year_diffrance *12 + month_diffrance
into #cohort_rt
from 
  (select m.*,
  year_diffrance = invoice_year - cohort_year ,
  month_diffrance = invoice_month - cohort_month
  from(
  select c.* , h.cohort_date,
    year(c.invoicedate) as invoice_year,
    month(c.invoicedate) as invoice_month,
    year(h.cohort_date) as cohort_year,
    month(h.cohort_date) as cohort_month
     from clean_pandas c left join #cohort h
     on c.CustomerID = h.CustomerID) m) r

select * from #cohort_rt

select distinct(cohort_index) from #cohort_rt order by cohort_index desc

-- make the cohort table
select * 
into #pivot
from (
   select distinct customerid ,
   cohort_date ,
   cohort_index
   from #cohort_rt) n
pivot (
  count(customerid)
  for cohort_index in ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) as pivot_tab
  order by cohort_date


--- display retention table
select *
from #pivot
order by cohort_date

--- retention % rate table 
select cohort_date,
1.0*[0]/[0] *100 as [0],
1.0*[1]/[0]*100 as [1],
 1.0*[2]/[0] *100 as [2],
 1.0*[3]/[0]*100 as [3],
 1.0*[4]/[0] *100 as '4',
 1.0*[5]/[0]*100 as'5',
 1.0*[6]/[0] *100 as '6',
 1.0*[7]/[0]*100 as'7',
 1.0*[8]/[0] *100 as '8',
 1.0*[9]/[0]*100 as'9',
 1.0*[10]/[0] *100 as '10',
 1.0*[11]/[0]*100 as '11',
 1.0*[12]/[0]*100 as '12'
  from #pivot
  order by cohort_date


