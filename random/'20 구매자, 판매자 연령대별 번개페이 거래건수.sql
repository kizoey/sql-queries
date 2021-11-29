with tb1 as(select row_number() over (order by b.buyer_id asc) as "no", 
    b.buyer_id, 
    a.uid as "seller_id", 
    a.id as "product_id" 
from product_info_TB a
	join bunpay_TB b on a.id = b.pid 
where b.updated_at >= '20200101' and b.updated_at < '20210101')

select 
case
	when 2020 - c.birth_year::integer between 10 and 19 then '10대'
	when 2020 - c.birth_year::integer between 20 and 29 then '20대'
	when 2020 - c.birth_year::integer between 30 and 39 then '30대'
	when 2020 - c.birth_year::integer between 40 and 49 then '40대'
	when 2020 - c.birth_year::integer >= 50 then '50대 이상'
end as "구매자 연령대", 
case
	when 2020 - d.birth_year::integer between 10 and 19 then '10대'
	when 2020 - d.birth_year::integer between 20 and 29 then '20대'
	when 2020 - d.birth_year::integer between 30 and 39 then '30대'
	when 2020 - d.birth_year::integer between 40 and 49 then '40대'
	when 2020 - d.birth_year::integer >= 50 then '50대 이상'
end as "판매자 연령대",
count(*) as "페이 거래 건수" from tb1 
	left join identification_TB c on c.uid = tb1.buyer_id
	left join identification_TB d on d.uid = tb1.seller_id
group by 1,2
order by 1,2 asc
