select
    a.search_term "검색어",
    two_weeks_ago_search_count as "전전주 검색량",
    one_week_ago_search_count as "전주 검색량",
    ((one_week_ago_search_count::FLOAT4 / COALESCE(two_weeks_ago_search_count, 1)::FLOAT4) - 1) * 100 AS "증가율(%)"
from
(
    select search_term, count(*) as one_week_ago_search_count
    from search_TB
    where
        year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
        and year||month||day < to_char(current_date, 'YYYYMMDD')
    group by search_term
    having search_term in (‘검색어’)
) a
left join
(
    select search_term, count(*) as two_weeks_ago_search_count
    from search_TB
    where
        year||month||day >= to_char(dateadd(week, -2, current_date), 'YYYYMMDD')
        and year||month||day < to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
    group by search_term
) b
on a.search_term = b.search_term
