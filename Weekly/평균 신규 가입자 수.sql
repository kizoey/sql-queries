select
    date_trunc('week', tb.join_date) as "가입 주", 
    avg(user_count) as "신규 가입자 수"
from
    (
        select
        	date_trunc('day', date) as join_date,
        	count(*) as user_count
        from
            user_TB
        where join_date >= '2020-08-24' and join_date < '2021-01-11'
        group by 1
        order by join_date asc
    ) tb
group by 1
order by 1 asc
