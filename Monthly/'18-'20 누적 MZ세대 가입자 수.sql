select join_month, 
	sum(join_count) over (order by join_month rows unbounded preceding) as cumulative_join_count
from((
	select join_month, 
    		count(*) as join_count
	from((
		select id, birth_year
		from identification_TB
		where birth_year >= 1985 and birth_year <= 2001
		) a
	left join
	(select id, 
    		to_char(join_date, 'YYYY-MM') as join_month
	from user_TB
	where to_char(join_date, 'YYYY') = '2018') b
	on a.id = b.id
	)
group by 1
order by 1 asc
)

union

select join_month, 
	sum(join_count) over (order by join_month rows unbounded preceding) as cumulative_join_count
from((
	select join_month, 
    		count(*) as join_count
	from((
		select id, birth_year
		from identification_TB
		where birth_year >= 1986 and birth_year <= 2002
		) a
	left join
	(select id, 
    		to_char(join_date, 'YYYY-MM') as join_month
	from user_TB
	where to_char(join_date, 'YYYY') = '2019') b
	on a.id = b.id
	)
group by 1
order by 1 asc
)

union

select join_month, 
	sum(join_count) over (order by join_month rows unbounded preceding) as cumulative_join_count
from((
	select join_month, 
    		count(*) as join_count
	from((
		select id, birth_year
		from identification_TB
		where birth_year >= 1987 and birth_year <= 2003
		) a
	left join
	(select id, 
    		to_char(join_date, 'YYYY-MM') as join_month
	from user_TB
	where to_char(join_date, 'YYYY') = '2020') b
	on a.id = b.id
	)
group by 1
order by 1 asc
)
