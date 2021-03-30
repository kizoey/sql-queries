-- 상품 등록 유저 대상) 1인당 상품 등록수

-- 상품 등록 유저, 등록한 상품, 분기
with tb_info as(
    select user_id, "성별", birth_year
    from
        (
        select user_id, "성별", birth_year, row_number() over(partition by user_id order by updated_at desc) as rnum
        from
            (
            select uid as "user_id",
                    case when gender = 0 then '여성'
                        when gender = 1 then '남성'
                        else NULL end as "성별", 
                    birth_year,
                    updated_at
            from
                (
                select uid, gender, birth_year, updated_at from service1_quicket.user_identification union
                select uid, gender, birth_year, deleted_at from service1_quicket.user_identification_deleted
                )
            where gender is NOT NULL
            and birth_year is NOT NULL    
            union
            select uid as "user_id",
                    case when gender = 1 then '남성' 
                        when gender = 0 or gender = 2 then '여성'
                        else NULL end as "성별", 
                    birth_year,
                    updated_at
            from
                (
                select uid, gender, birth_year, updated_at from service1_quicket.user_identification_v2 union
                select uid, gender, birth_year, deleted_at from service1_quicket.user_identification_v2_deleted
                )
            where gender is NOT NULL
            and birth_year is NOT NULL
            )
        )
    where rnum = 1
),


tb_product as(
    select date_trunc('quarter', create_date) as "quarter",
            case
                when tb_info.성별 is not null then tb_info.성별
                when tb_info.성별 is null then 'NA' end as "성별",
            case
                when birth_year is not null and (extract(year from create_date)+1) - tb_info.birth_year::integer < 25 then '25 under'
                when birth_year is not null and (extract(year from create_date)+1) - tb_info.birth_year::integer between 25 and 34 then '2534'
                when birth_year is not null and (extract(year from create_date)+1) - tb_info.birth_year::integer between 35 and 44 then '3544'
                when birth_year is not null and (extract(year from create_date)+1) - tb_info.birth_year::integer >= 45 then '45+'
                when birth_year is null then 'NA' end as "연령",
            count(id) as "item_cnt",
            count(distinct uid) as "user_cnt"
    from service1_quicket.product_info pi 
        left join tb_info on tb_info.user_id = pi.uid
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
        sum(item_cnt) as "총 상품등록수",
        sum(user_cnt) as "상품등록 유저수",
        sum(item_cnt)/sum(user_cnt)::decimal as "1인당 상품 등록수"
from tb_product
group by 1,2,3
order by 1,2,3 asc
