-- '중고폰매입' 검색 유저 정보 추출
with tb_info as(
    select distinct uid as "유저ID",
            case
            when gender = 0 or gender = 2 then '여성'
            when gender = 1 then '남성' end as "성별",
            case
            when 2020 - birth_year::integer between 10 and 19 then '10대'
            when 2020 - birth_year::integer between 20 and 29 then '20대'
            when 2020 - birth_year::integer between 30 and 39 then '30대'
            when 2020 - birth_year::integer between 40 and 49 then '40대'
            when 2020 - birth_year::integer >= 50 then '50대 이상' end as "연령대"
    from identification_TB
),


-- 각 유저별 검색량
tb_search as(
    select
        a.user_id as "user_id",
        two_weeks_ago_search_count,
        one_week_ago_search_count
    from
    (
        select user_id, search_term, count(*) as one_week_ago_search_count
        from search_TB
        where
            year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
            and year||month||day < to_char(current_date, 'YYYYMMDD')
        group by 1,2
        having search_term in ('중고폰매입')
    ) a
    left join
    (
        select user_id, search_term, count(*) as two_weeks_ago_search_count
        from search_TB
        where
            year||month||day >= to_char(dateadd(week, -2, current_date), 'YYYYMMDD')
            and year||month||day < to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
        group by 1,2
    ) b
    on a.search_term = b.search_term
    and a.user_id = b.user_id
)


select 유저ID,
        성별,
        연령대,
        sum(tb_search.two_weeks_ago_search_count) as "전전주 검색량",
        sum(tb_search.one_week_ago_search_count) as "전주 검색량"
from tb_info
    join tb_search on tb_info.유저ID = tb_search.user_id
group by 1,2,3
order by 1 asc


--중고폰관련 판매자여부
tb_phoneseller as(
    select uid
    from product_info_TB
    where name like '%중고폰매입%'
        or name like '%중고폰%매입%'
)

select 유저ID,
        성별,
        연령대,
        case when tb_phoneseller.uid = 유저ID then 1 else 0 end as "판매자여부"
from tb_info
    left join tb_phoneseller on tb_info.유저ID = tb_phoneseller.uid
group by 1,2,3,4
order by 1 asc
