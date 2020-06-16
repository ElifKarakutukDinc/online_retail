
drop table stock_number;
create table stock_number (stockcode varchar(15), description varchar(2048), id serial);

insert into stock_number (stockcode,description) select distinct stockcode,description from retail;

create index ix5 on stock_number(id);

drop table retail_stock_updated;
select rt.*, sn.id as stock_id
into retail_stock_updated
from retail as rt
inner join stock_number as sn
on (rt.stockcode = sn.stockcode);

select count(1) from retail;

select count(1) from retail_stock_updated;

create index ix1 on retail_stock_updated(stock_id);
create index ix2 on retail_stock_updated(invoiceno);

select *
from retail_stock_updated
limit 10;

drop table market_basket;
SELECT
PRODUCT_1,
PRODUCT_2,
COUNT(invoiceno) TRANS_COUNT
into market_basket
FROM
(
SELECT
a.invoiceno,
a.stock_id PRODUCT_1,
b.stock_id PRODUCT_2
FROM retail_stock_updated a,
retail_stock_updated b
WHERE a.invoiceno=b.invoiceno
and a.stock_id <> b.stock_id
and a.stock_id < b.stock_id
) Temp
GROUP BY PRODUCT_1,PRODUCT_2;

create index ix3 on market_basket(PRODUCT_1);
create index ix4 on market_basket(PRODUCT_2);

select *
from market_basket
order by 3 desc
limit 10;

select *
into market_basket_top_50
from market_basket
order by 3 desc
limit 50;

select distinct mb.*, rs_1.description as product_1_description, rs_2.description product_2_description
into market_basket_description
from market_basket_top_50 as mb
left join stock_number as rs_1
on (mb.product_1 = rs_1.id)
left join stock_number as rs_2
on (mb.product_2 = rs_1.id);

select *
from market_basket_description
order by TRANS_COUNT desc


