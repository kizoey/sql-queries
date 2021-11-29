select date_trunc('week', join_date) as "week_cnt",
	count(distinct user_id)
from user_TB
where join_date >= '20190101' 
	and segment = '경로1'
group by week_cnt
order by week_cnt asc
