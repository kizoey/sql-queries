set time zone 'Asia/Seoul';

-- 검색어(남성)
with tb_search_men as
    (
    select search_term as "남성_검색어",
            count(*) as "남성_검색량",
            row_number() over (order by 남성_검색량 desc) as "남성_순위"
    from bun_log_db.app_event_type_search a
        join service1_quicket.user_identification_v2 b on a.user_id = b.uid
    where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
                and year||month||day < to_char(current_date, 'YYYYMMDD')
        and b.gender = 0
    group by 1
    order by 2 desc
    limit 100
    ),


-- 검색어(여성)
tb_search_women as
    (
    select search_term as "여성_검색어",
            count(*) as "여성_검색량",
            row_number() over (order by 여성_검색량 desc) as "여성_순위"
    from bun_log_db.app_event_type_search a
        join service1_quicket.user_identification_v2 b on a.user_id = b.uid
    where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
                and year||month||day < to_char(current_date, 'YYYYMMDD')
        and (b.gender = 0 or b.gender = 2)
    group by 1
    order by 2 desc
    limit 100
    ),


-- 카테고리
tb_category_m as
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
                from bun_log_db.app_event_type_view a
                where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
                        and year||month||day < to_char(current_date, 'YYYYMMDD')
                        and event_action = 'view_content'
                group by 1, 2
                ) a
            join service1_quicket.product_info b on a.content_id = b.id
            join service1_quicket.categories c on left(b.category_id, 3) = c.category
        group by 1, 2
            )
        )
    where 순번 = 1
    ),
    
tb_category_w as
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
                from bun_log_db.app_event_type_view a
                where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
                        and year||month||day < to_char(current_date, 'YYYYMMDD')
                        and event_action = 'view_content'
                group by 1, 2
                ) a
            join service1_quicket.product_info b on a.content_id = b.id
            join service1_quicket.categories c on left(b.category_id, 3) = c.category
        group by 1, 2
            )
        )
    where 순번 = 1
    )
    

-- 순위, 검색어, 카테고리, 검색량 (남성+여성)
select 남성_순위 as "순위",
        남성_검색어,
        tb_category_m.카테고리 as "남성_카테고리",
        남성_검색량,
        tb_search_women.여성_검색어,
        tb_category_w.카테고리 as "여성_카테고리",
        tb_search_women.여성_검색량
from tb_search_men
    join tb_search_women on tb_search_men.남성_순위 = tb_search_women.여성_순위
    join tb_category_m on tb_search_men.남성_검색어 = tb_category_m.참고어
    join tb_category_w on tb_search_women.여성_검색어 = tb_category_w.참고어
order by 1 asc
