/*
We calculated RFM values. At M calculation, there is no positive and negative value for the same invoice number. 
Since the minus quantity is not necessary for our analysis, we have removed these values from our query.
*/

with customer_table as (
select distinct customerid
from retail
where customerid is not null),

Recency as (
select customerid, ((select max(invoicedate) from retail)::TIMESTAMP::DATE - max(invoicedate)::TIMESTAMP::DATE ) as R
from retail
where customerid is not null
group by 1), 

Frequency as (
select customerid, count(distinct invoiceno) as F
from retail
where customerid is not null
group by 1),

Money as (
select customerid, Sum(quantity*unitprice) as M 
from retail
where customerid is not null and quantity>0
group by 1)

select ct.customerid, R,F, coalesce(M,0) as M
from customer_table as ct
left join Money on(ct.customerid=Money.customerid) 
left join Recency on(Recency.customerid=ct.customerid) 
left join Frequency on (Frequency.customerid=ct.customerid); 

