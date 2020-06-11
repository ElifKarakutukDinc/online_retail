--f bucket
with min_max AS (
    SELECT 
        min(f) AS min_val,
        max(f) AS max_val
    FROM rfm),

f_min_max as(
SELECT 
    min(f) min_f,
    max(f) max_f,
    width_bucket(f, min_val, max_val, 4) AS f_bucket
FROM rfm, min_max  
GROUP BY 3),


bucket_table as (
select customerid, 
	CASE
            WHEN RFM.f between min_f and max_f THEN 1 end  bucket
from RFM, f_min_max
where f_bucket=1
union 
select customerid, 
	CASE
            WHEN RFM.f between min_f and max_f THEN 2 end  bucket
from RFM, f_min_max
where f_bucket=2
union select customerid, 
	CASE
            WHEN RFM.f between min_f and max_f THEN 3 end  bucket
from RFM, f_min_max
where f_bucket=3
union 
select customerid, 
	CASE
            WHEN RFM.f between min_f and max_f THEN 4 end  bucket
from RFM, f_min_max
where f_bucket=4) 

select *
from bucket_table 
where bucket is not null;

