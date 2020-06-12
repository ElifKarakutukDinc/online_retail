with bucket_table as (
select customerid, 
	CASE
            WHEN rfm_total_score between 1 and 5 THEN 1 end  bucket
from rfm_bucket  
where rfm_total_score=1
union 
select customerid, 
	CASE
            WHEN rfm_total_score between 6 and 10 THEN 2 end  bucket
from rfm_bucket 
where rfm_total_score=2
union select customerid, 
	CASE
            WHEN rfm_total_score between 11 and 15 THEN 3 end  bucket
from rfm_bucket
where rfm_total_score=3)

select rfm.customerid, r,f,m, rb.bucket as r_bucket, fb.bucket as f_bucket, mb.bucket as m_bucket, (rb.bucket+fb.bucket+mb.bucket) as rfm_total_score
from rfm 
left join rfm_bucket rfmb on (rfm.customerid =rfmb.customerid)
left join bucket_table bt on (rfm.customerid =bt.customerid); 


