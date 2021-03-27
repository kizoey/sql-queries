-- 연령/성별 1인당 거래액/거래건수 추이 (번개페이+번개프로미스+Verified)

-- Verified: 번개페이+번개프로미스+Transfer
with tb_gmv as(
    select *
    from(
        select * from workspace.redash_gmv_revenue_bunp union all
        select * from workspace.redash_gmv_revenue_bunpay union all
        select * from workspace.redash_gmv_revenue_transfer
        )
    where updated_at >= '20200101'
),


-- 성별, 연령대별 유저ID 추출
tb_info as(
    select uid as "user_id",
            case when b.gender = 1 then '남성' 
                when b.gender = 0 or gender = 2 then '여성'
                else NULL end as "성별", 
            case
                when 2021 - b.birth_year::integer < 25 then '25 under'
                when 2021 - b.birth_year::integer between 25 and 34 then '2534'
                when 2021 - b.birth_year::integer between 35 and 44 then '3544'
                when 2021 - b.birth_year::integer >= 45 then '45+'
                else NULL end as "연령"
    from service1_quicket.user_identification_v2 b
    where b.gender is NOT NULL
        and b.birth_year is NOT NULL
),


-- 번개프로미스
tb_bunp as(
    select date_trunc('quarter', updated_at) as "bunp_quarter",
            tb_info.성별 as "sex_bunp",
            tb_info.연령 as "age_bunp",
            count(pid) as "bunp_buy",
            count(distinct buyer_id) as "bunp_buy_uid",
            sum(total_price) as "bunp_buy_mon"
    from workspace.redash_gmv_revenue_bunp tb2
        join tb_info on tb2.buyer_id = tb_info.user_id
    where updated_at >= '20200101'
    group by 1,2,3
),


-- 번개페이
tb_bunpay as(
    select date_trunc('quarter', updated_at) as "bunpay_quarter",
            tb_info.성별 as "sex_bunpay",
            tb_info.연령 as "age_bunpay",
            count(pid) as "bunpay_buy",
            count(distinct buyer_id) as "bunpay_buy_uid",
            sum(total_price) as "bunpay_buy_mon"
    from workspace.redash_gmv_revenue_bunpay tb2
        join tb_info on tb2.buyer_id = tb_info.user_id
    where updated_at >= '20200101' 
    group by 1,2,3
),


-- Verified
tb_verified as(
    select date_trunc('quarter', updated_at) as "verified_quarter",
            tb_info.성별 as "sex_verified",
            tb_info.연령 as "age_verified",
            count(pid) as "verified_buy",
            count(distinct buyer_id) as "verified_buy_uid",
            sum(total_price) as "verified_buy_mon"
    from tb_gmv
        join tb_info on tb_gmv.buyer_id = tb_info.user_id
    group by 1,2,3
)


-- 1인당 거래건수+거래액 추출
select case when left(bunp_quarter, 10) = '2020-01-01' then '2020_1Q'
            when left(bunp_quarter, 10) = '2020-04-01' then '2020_2Q'
            when left(bunp_quarter, 10) = '2020-07-01' then '2020_3Q'
            when left(bunp_quarter, 10) = '2020-10-01' then '2020_4Q'
            else '2021_1Q' end as "분기",
    sex_bunp as "성별",
    age_bunp as "연령대",

    sum(tb_bunpay.bunpay_buy)/sum(tb_bunpay.bunpay_buy_uid)::decimal as "1인당 번개페이 거래건수",
    sum(tb_bunpay.bunpay_buy_mon)/sum(tb_bunpay.bunpay_buy_uid)::integer as "1인당 번개페이 거래액",
    
    sum(tb_bunp.bunp_buy)/sum(tb_bunp.bunp_buy_uid)::decimal as "1인당 번개프로미스 거래건수",
    sum(tb_bunp.bunp_buy_mon)/sum(tb_bunp.bunp_buy_uid)::integer as "1인당 번개프로미스 거래액",
    
    sum(verified_buy)/sum(verified_buy_uid)::decimal as "1인당 Verified 거래건수",
    sum(verified_buy_mon)/sum(verified_buy_uid)::integer as "1인당 Verified 거래액"

from tb_bunp
    left join tb_bunpay on tb_bunp.bunp_quarter = tb_bunpay.bunpay_quarter 
        and tb_bunp.sex_bunp = tb_bunpay.sex_bunpay 
        and tb_bunp.age_bunp = tb_bunpay.age_bunpay
    left join tb_verified on tb_bunp.bunp_quarter = tb_verified.verified_quarter
        and tb_bunp.sex_bunp = tb_verified.sex_verified
        and tb_bunp.age_bunp = tb_verified.age_verified
group by 1,2,3
order by 1,2,3 asc
