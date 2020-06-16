--control of quantities minus values 
select invoiceno from (
select invoiceno, case when quantity<0 then 1 else 0 end count 
from retail 
group by 1, 2
order by 1 ) a
group by 1 
having count(*)>1