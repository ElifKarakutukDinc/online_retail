/*
Stockcode is a text field and it is not easy to compare with each other to find. Regarding to this
we will assign incremental id column for each stockcode and store the unique code, description and id
columns in a table.
*/

drop table IF EXISTS stock_number;

create table stock_number (stockcode varchar(15), description varchar(2048), id serial);

insert into stock_number (stockcode,description)
select distinct stockcode,description
from retail
where unitprice >0 and quantity >0; --using only valid transactions and exluding minus ones.

create index ix5 on stock_number(id);

/*
Quality check - 1: Is there any null description?
select
case
	when length(ltrim(rtrim(description))) = 0 then 'empty_description'
	else 'non_empty_description' end control,
count(1) as cnt
from stock_number
group by 1;
non_empty_description	4161
Quality check - 2: Is there any null stockcode?
select
case
	when length(ltrim(rtrim(stockcode))) = 0 then 'empty_stockcode'
	else 'non_empty_stockcode' end control,
count(1) as cnt
from stock_number
group by 1;
non_empty_stockcode	4161
Quality check - 3: Are there any duplicate descriptions for a single stockcode?
select stockcode
from stock_number
group by 1
having count(1) > 2
select distinct description
from retail
where stockcode = '23209'
*/

/*
As we found out some stockcodes have more than one description. It can be an issue of using same stockcode
for different products or changing descriptions over time.
In order to continue our analysis we need to delete these stockcodes from our unique table.
 */

delete from stock_number
where stockcode in (select stockcode
from stock_number
group by 1
having count(1) > 2);

/*
At some transactions same stockcode, product, can be purchased more than once and not grouped at invoice.
For our use case which is which products were bought together, we need to get unique products per invoice.
select *
from retail
where invoiceno = '548708' and	stockcode = '22859'
invoiceno	stockcode	description	quantity	invoicedate
548708	22859	EASTER TIN BUNNY BOUQUET	2	2011-04-03 12:41:00
548708	22859	EASTER TIN BUNNY BOUQUET	1	2011-04-03 12:41:00
*/

--Creating unique invoice, stockcode and description table

drop table if exists retail_unique;

with retail_unique_0 as (
select distinct invoiceno, stockcode, description
from retail),

stockcode_desc as (select stockcode ,description 
from (
select distinct stockcode , description, RANK() OVER (
    PARTITION BY stockcode 
    ORDER BY stockcode asc,description desc
)
from retail_unique_0) A
where rank = 1)

select distinct x.invoiceno, y.stockcode, y.description
into retail_unique
from retail as x
inner join stockcode_desc y 
on (x.stockcode = y.stockcode);

create index ix6 on retail_unique(invoiceno);
create index ix7 on retail_unique(stockcode);

--Joining stock number updated table with unique retail table

drop table if exists retail_stock_updated;

select rt.*, sn.id as stock_id
into retail_stock_updated
from retail_unique as rt
left join stock_number as sn
on (rt.stockcode = sn.stockcode);

create index ix1 on retail_stock_updated(stock_id);
create index ix2 on retail_stock_updated(invoiceno);
create index ix8 on retail_stock_updated(stockcode);

/*
Quality check - 1: Duplicate row check?
select invoiceno, stockcode,description,stock_id
from retail_stock_updated
group by 1,2,3,4
having count(1) > 1
select *
from retail_stock_updated
limit 10;
 */

--Creating bought together item list.
drop table if exists market_basket;

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

/*
Quality check - 1: Checking null product ids.
select *
from market_basket
where product_1 is null;
select *
from market_basket
where product_2 is null;
select *
from market_basket
order by 3 desc
limit 10;
 */

/*
We have millions of items bought combinations. Since it is more important to show only the highest frequent
transactions we will only get most important 50 transactions.
 */

drop table if exists market_basket_top_50;

select *
into market_basket_top_50
from market_basket
order by 3 desc
limit 50;

drop table if exists market_basket_description;

--Joining transactions with descriptions

select distinct mb.*, rs_1.description as product_1_description, rs_2.description product_2_description
into market_basket_description
from market_basket_top_50 as mb
left join stock_number as rs_1
on (mb.product_1 = rs_1.id)
left join stock_number as rs_2
on (mb.product_2 = rs_2.id);

--Final Table:

select *
from market_basket_description
order by TRANS_COUNT desc
limit 50;
