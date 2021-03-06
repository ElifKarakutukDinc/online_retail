--r bucket
with min_max AS (
    SELECT 
        min(r) AS min_val,
        max(r) AS max_val
    FROM rfm),

r_min_max as(
SELECT 
    min(r) min_r,
    max(r) max_r,
    width_bucket(r, min_val, max_val, 4) AS r_bucket
FROM rfm, min_max  
GROUP BY 3),


bucket_table as (
select customerid, 
	CASE
            WHEN RFM.r between min_r and max_r THEN 1 end  bucket
from RFM, r_min_max
where r_bucket=5
union 
select customerid, 
	CASE
            WHEN RFM.r between min_r and max_r THEN 2 end  bucket
from RFM, r_min_max
where r_bucket=4
union select customerid, 
	CASE
            WHEN RFM.r between min_r and max_r THEN 3 end  bucket
from RFM, r_min_max
where r_bucket=3
union 
select customerid, 
	CASE
            WHEN RFM.r between min_r and max_r THEN 4 end  bucket
from RFM, r_min_max
where r_bucket=2
union 
select customerid, 
	CASE
            WHEN RFM.r between min_r and max_r THEN 5 end  bucket
from RFM, r_min_max
where r_bucket=1) 

select *
from bucket_table 
where bucket is not null;

