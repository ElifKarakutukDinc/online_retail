--m bucket
drop table m_bucket ;
with min_max AS (
    SELECT 
        min(m) AS min_val,
        max(m) AS max_val
    FROM rfm),

m_min_max as(
SELECT 
    min(m) min_m,
    max(m) max_m,
    width_bucket(m, min_val, max_val, 4) AS m_bucket
FROM rfm, min_max  
GROUP BY 3),


bucket_table as (
select customerid, 
	CASE
            WHEN RFM.m between min_m and max_m THEN 1 end  bucket
from RFM, m_min_max
where m_bucket=1
union 
select customerid, 
	CASE
            WHEN RFM.m between min_m and max_m THEN 2 end  bucket
from RFM, m_min_max
where m_bucket=2
union select customerid, 
	CASE
            WHEN RFM.m between min_m and max_m THEN 3 end  bucket
from RFM, m_min_max
where m_bucket=3
union 
select customerid, 
	CASE
            WHEN RFM.m between min_m and max_m THEN 4 end  bucket
from RFM, m_min_max
where m_bucket=4
union 
select customerid, 
	CASE
            WHEN RFM.m between min_m and max_m THEN 5 end  bucket
from RFM, m_min_max
where m_bucket=5) 

select *
into m_bucket
from bucket_table 
where bucket is not null;
