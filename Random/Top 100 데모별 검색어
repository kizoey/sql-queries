-- 검색어
with tb_search as
    (
    select search_term as "검색어",
            count(*) as "검색량",
            rank() over (order by 검색량 desc) as "순위"
    from search_TB a
        join identification_TB b on a.user_id = b.uid
    where to_date(year||month||day, 'YYYYMMDD') >= '{{From when}}'
    and to_date(year||month||day, 'YYYYMMDD') < '{{To when}}'
    and case
            when '%{{성별}}%' = '%남성%' then b.gender = 1
            when '%{{성별}}%' = '%여성%' then (b.gender = 0 or b.gender = 2)
            when '%{{성별}}%' = '%무관%' then (b.gender = 0 or b.gender = 1 or b.gender = 2) end
    and 2021 - b.birth_year::integer between '{{최소나이}}' and '{{최대나이}}'
    group by 1
    order by 2 desc
    limit 100
    ),


-- 카테고리
tb_category as
    (
    select ref_term as "참고어", 
            name as "카테고리"
    from
        (
        select ref_term, 
                name, 
                row_number() over (partition by ref_term order by cnt desc) as "순번"
        from
            (
            select ref_term, 
                    c.name, 
                    sum(cnt) as cnt
            from
                (
                select content_id,
                       ref_term,
                       count(*) as cnt
                from view_TB a
                where to_date(year||month||day, 'YYYYMMDD') >= '{{From when}}' 
                        and to_date(year||month||day, 'YYYYMMDD') < '{{To when}}'
                        and event_action = 'view_content'
                group by 1, 2
                ) a
            join product_info_TB b on a.content_id = b.id
            join categories_TB c on left(b.category_id, 3) = c.category
        group by 1, 2
            )
        )
    where 순번 = 1
    )
    

-- 순위,검색어,카테고리,검색량
select 순위,
        검색어,
        tb_category.카테고리,
        검색량
from tb_search
    left join tb_category on tb_search.검색어 = tb_category.참고어
order by 1 asc
