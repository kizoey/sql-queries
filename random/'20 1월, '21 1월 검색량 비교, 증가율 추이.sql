with dec as(
select search_term like '%{{검색어}}%' as search_term1,
        count(case when search_term like '%{{검색어}}%' then 1 end) as "검색량1"
from search_TB
where year||month||day >= '20201201' 
    and year||month||day < '20210101'
group by 1),


jan as(
select search_term like '%{{검색어}}%' as search_term2,
        count(case when search_term like '%{{검색어}}%' then 1 end) as "검색량2"
from search_TB
where year||month||day >= '20210101' 
    and year||month||day < '20210201'
group by 1)


select sum(dec.검색량1) as "cnt1",
        sum(jan.검색량2) as "cnt2",
        ((cnt2-cnt1)/cnt1::decimal)*100 as "증가율"
from dec join jan on dec.search_term1 = jan.search_term2
