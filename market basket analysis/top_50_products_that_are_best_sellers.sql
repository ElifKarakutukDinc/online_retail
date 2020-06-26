--Top 50 products that are best sellers. there were different names of same stockcode. We combined names by stockcodes. 

with stockcode_desc as (select stockcode ,description 
from (
select distinct stockcode , description, RANK() OVER (
    PARTITION BY stockcode 
    ORDER BY stockcode asc,description desc
)
from retail_unique) A
where rank = 1)

select stc.*, sum(quantity ) as total_quantity
from retail r 
left join stockcode_desc stc on (r.stockcode = stc.stockcode) 
group by 1,2
order by 3 desc
limit 50;
