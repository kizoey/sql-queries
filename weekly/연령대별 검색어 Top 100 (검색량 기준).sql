set time zone 'Asia/Seoul';

-- 검색어(1824)
with tb_search_1824 as
    (
    select search_term as "age1_검색어",
            count(*) as "age1_검색량",
            row_number() over (order by age1_검색량 desc) as "age1_순위"
    from bun_log_db.app_event_type_search a
        join service1_quicket.user_identification_v2 b on a.user_id = b.uid
    where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
        and year||month||day < to_char(current_date, 'YYYYMMDD')
        and 2021 - b.birth_year >= 18
        and 2021 - b.birth_year < 25
    group by 1
    order by 2 desc
    limit 100
    ),


-- 검색어(2534)
tb_search_2534 as
    (
    select search_term as "age2_검색어",
            count(*) as "age2_검색량",
            row_number() over (order by age2_검색량 desc) as "age2_순위"
    from bun_log_db.app_event_type_search a
        join service1_quicket.user_identification_v2 b on a.user_id = b.uid
    where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
        and year||month||day < to_char(current_date, 'YYYYMMDD')
        and 2021 - b.birth_year >= 25
        and 2021 - b.birth_year < 35
    group by 1
    order by 2 desc
    limit 100
    ),


-- 검색어(3544)
tb_search_3544 as
    (
    select search_term as "age3_검색어",
            count(*) as "age3_검색량",
            row_number() over (order by age3_검색량 desc) as "age3_순위"
    from bun_log_db.app_event_type_search a
        join service1_quicket.user_identification_v2 b on a.user_id = b.uid
    where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
        and year||month||day < to_char(current_date, 'YYYYMMDD')
        and 2021 - b.birth_year >= 35
        and 2021 - b.birth_year < 45
    group by 1
    order by 2 desc
    limit 100
    ),
    
    
-- 검색어(4554)
tb_search_4554 as
    (
    select search_term as "age4_검색어",
            count(*) as "age4_검색량",
            row_number() over (order by age4_검색량 desc) as "age4_순위"
    from bun_log_db.app_event_type_search a
        join service1_quicket.user_identification_v2 b on a.user_id = b.uid
    where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
        and year||month||day < to_char(current_date, 'YYYYMMDD')
        and 2021 - b.birth_year >= 45
        and 2021 - b.birth_year < 55
    group by 1
    order by 2 desc
    limit 100
    ),
    
    
-- 검색어(55+)
tb_search_55 as
    (
    select search_term as "age5_검색어",
            count(*) as "age5_검색량",
            row_number() over (order by age5_검색량 desc) as "age5_순위"
    from bun_log_db.app_event_type_search a
        join service1_quicket.user_identification_v2 b on a.user_id = b.uid
    where year||month||day >= to_char(dateadd(week, -1, current_date), 'YYYYMMDD')
        and year||month||day < to_char(current_date, 'YYYYMMDD')
        and 2021 - b.birth_year >= 55
    group by 1
    order by 2 desc
    limit 100
    ),
    

-- 카테고리(1824)
tb_category_1824 as
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
    

-- 카테고리(2534)
tb_category_2534 as
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

 
-- 카테고리(3544) 
tb_category_3544 as
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
    
    
-- 카테고리(4554)
tb_category_4554 as
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
    
 
-- 카테고리(55+)  
tb_category_55 as
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
    

-- 순위, 검색어, 카테고리, 검색량 (전 연령대)
select age1_순위 as "순위",
        age1_검색어 as "1824_검색어",
        tb_category_1824.카테고리 as "1824_카테고리",
        age1_검색량 as "1824_검색량",
        
        tb_search_2534.age2_검색어 as "2534_검색어",
        tb_category_2534.카테고리 as "2534_카테고리",
        tb_search_2534.age2_검색량 as "2534_검색량",
        
        tb_search_3544.age3_검색어 as "3544_검색어",
        tb_category_3544.카테고리 as "3544_카테고리",
        tb_search_3544.age3_검색량 as "3544_검색량",
        
        tb_search_4554.age4_검색어 as "4554_검색어",
        tb_category_4554.카테고리 as "4554_카테고리",
        tb_search_4554.age4_검색량 as "4554_검색량",
        
        tb_search_55.age5_검색어 as "55+_검색어",
        tb_category_55.카테고리 as "55+_카테고리",
        tb_search_55.age5_검색량 as "55+_검색량"
from tb_search_1824
    join tb_search_2534 on tb_search_1824.age1_순위 = tb_search_2534.age2_순위
    join tb_search_3544 on tb_search_1824.age1_순위 = tb_search_3544.age3_순위
    join tb_search_4554 on tb_search_1824.age1_순위 = tb_search_4554.age4_순위
    join tb_search_55 on tb_search_1824.age1_순위 = tb_search_55.age5_순위
    
    join tb_category_1824 on tb_search_1824.age1_검색어 = tb_category_1824.참고어
    join tb_category_2534 on tb_search_2534.age2_검색어 = tb_category_2534.참고어
    join tb_category_3544 on tb_search_3544.age3_검색어 = tb_category_3544.참고어
    join tb_category_4554 on tb_search_4554.age4_검색어 = tb_category_4554.참고어
    join tb_category_55 on tb_search_55.age5_검색어 = tb_category_55.참고어
order by 1 asc
