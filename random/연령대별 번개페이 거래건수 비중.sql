select age_group, 
	count(distinct t2.pid)
from(
	select uid,
		case
		when 2020 - birth_year::integer between 10 and 19 then '10대'
		when 2020 - birth_year::integer between 20 and 29 then '20대'
		when 2020 - birth_year::integer between 30 and 39 then '30대'
		when 2020 - birth_year::integer between 40 and 49 then '40대'
		when 2020 - birth_year::integer >= 50 then '50대 이상'
		else null end as age_group
	from identification_TB) t1
	right join gmv_TB t2 on t1.uid = t2.buyer_id
where updated_at >= '20200101' and updated_at < '20210101'
group by 1
order by 1 asc
