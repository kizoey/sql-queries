-- 연령/성별 상품등록 유저수

-- 성별, 연령대별 유저ID 추출
with tb_info as(
    select id as "user_id",
            case when b.gender = 1 then '남성' 
                when b.gender = 0 or gender = 2 then '여성'
                else NULL end as "성별", 
            case
                when 2021 - b.birth_year::integer < 25 then '25 under'
                when 2021 - b.birth_year::integer between 25 and 34 then '2534'
                when 2021 - b.birth_year::integer between 35 and 44 then '3544'
                when 2021 - b.birth_year::integer >= 45 then '45+'
                else NULL end as "연령"
    from service1_quicket.user_ a
        join service1_quicket.user_identification_v2 b on a.id = b.uid
    where b.gender is NOT NULL
        and b.birth_year is NOT NULL
),


-- 상품등록 유저수
tb_product as(
    select date_trunc('quarter', create_date) as "quarter",
            tb_info.성별 as "성별",
            tb_info.연령 as "연령",
            count(distinct uid) as "user_cnt"
    from service1_quicket.product_info pi 
        join tb_info on tb_info.user_id = pi.uid
    where create_date >= '20200101'
    group by 1,2,3
)

-- 분기별, 연령/성별 상품등록 유저수
select case when left(quarter, 10) = '2020-01-01' then '2020_1Q'
            when left(quarter, 10) = '2020-04-01' then '2020_2Q'
            when left(quarter, 10) = '2020-07-01' then '2020_3Q'
            when left(quarter, 10) = '2020-10-01' then '2020_4Q'
            else '2021_1Q' end as "분기",
        성별,
        연령,
        sum(user_cnt) as "상품등록 유저수"
from tb_product
group by 1,2,3
order by 1,2,3 asc
