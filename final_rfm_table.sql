select *,
case 
WHEN total_rfm_score between 1 and 5 THEN 1 
WHEN total_rfm_score between 6 and 10 THEN 2
WHEN total_rfm_score between 11 and 15 THEN 3
end  bucket
into final_rfm_table
from rfm_bucket  