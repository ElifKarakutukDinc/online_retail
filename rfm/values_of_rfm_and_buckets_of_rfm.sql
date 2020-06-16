--Values of RFM and Buckets of RFM
select rfm.customerid, r,f,m, rb.bucket as r_bucket, fb.bucket as f_bucket, mb.bucket as m_bucket
into rfm_bucket
from rfm 
left join r_bucket rb on (rb.customerid= rfm.customerid)
left join f_bucket fb on (fb.customerid= rfm.customerid)
left join m_bucket mb on (mb.customerid= rfm.customerid);