select age_group as "연령대", 
	count(*) as "유저 수"
from
  (select distinct id,
  case
  	when 2021 - birth_year::integer between 10 and 19 then '10대'
  	when 2021 - birth_year::integer between 20 and 29 then '20대'
  	when 2021 - birth_year::integer between 30 and 39 then '30대'
  	when 2021 - birth_year::integer between 40 and 49 then '40대'
  	when 2021 - birth_year::integer between 50 and 59 then '50대'
  	when 2021 - birth_year::integer > 59 then '60대 이상'
  	else null end as age_group
  from identification_TB) t1
	right join user_TB t2 on t1.id = t2.id
group by 1
order by 1 asc
