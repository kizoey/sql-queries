-- 연령/성별 거래액/거래건수 추이 (번개페이+번개프로미스+Verified)

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


-- 번개프로미스
tb_bunp as(
    select date_trunc('quarter', updated_at) as "bunp_quarter",
            tb_info.성별 as "sex_bunp",
            tb_info.연령 as "age_bunp",
            count(pid) as "bunp_buy",
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
            sum(total_price) as "bunpay_buy_mon"
    from workspace.redash_gmv_revenue_bunpay tb2
        join tb_info on tb2.buyer_id = tb_info.user_id
    where updated_at >= '20200101' 
    group by 1,2,3
),


-- transfer
tb_transfer as(
    select date_trunc('quarter', updated_at) as "transfer_quarter",
            tb_info.성별 as "sex_transfer",
            tb_info.연령 as "age_transfer",
            count(pid) as "transfer_buy",
            sum(total_price) as "transfer_buy_mon"
    from workspace.redash_gmv_revenue_transfer tb2
        join tb_info on tb2.buyer_id = tb_info.user_id
    where updated_at >= '20200101' 
    group by 1,2,3
)


-- 거래건수+거래액 추출
select case when left(bunp_quarter, 10) = '2020-01-01' then '2020_1Q'
            when left(bunp_quarter, 10) = '2020-04-01' then '2020_2Q'
            when left(bunp_quarter, 10) = '2020-07-01' then '2020_3Q'
            when left(bunp_quarter, 10) = '2020-10-01' then '2020_4Q'
            else '2021_1Q' end as "분기",
    sex_bunp as "성별",
    age_bunp as "연령대",
    
    sum(tb_bunpay.bunpay_buy) as "번개페이 거래건수",
    sum(tb_bunpay.bunpay_buy_mon) as "번개페이 거래액",
    sum(tb_bunpay.bunpay_buy_mon)/sum(tb_bunpay.bunpay_buy)::integer as "번개페이 AOV",
    
    sum(bunp_buy) as "번개프로미스 거래건수",
    sum(bunp_buy_mon) as "번개프로미스 거래액",
    sum(bunp_buy_mon)/sum(bunp_buy)::integer as "번개프로미스 AOV",
    
    sum(bunp_buy + tb_bunpay.bunpay_buy + coalesce(tb_transfer.transfer_buy,0)) as "Verified 거래건수",
    sum(bunp_buy_mon + tb_bunpay.bunpay_buy_mon + coalesce(tb_transfer.transfer_buy_mon,0)) as "Verified 거래액",
    sum(bunp_buy_mon + tb_bunpay.bunpay_buy_mon + coalesce(tb_transfer.transfer_buy_mon,0))/sum(bunp_buy + tb_bunpay.bunpay_buy + coalesce(tb_transfer.transfer_buy,0))::integer as "Verified AOV"

from tb_bunp
    left join tb_bunpay on tb_bunp.bunp_quarter = tb_bunpay.bunpay_quarter 
        and tb_bunp.sex_bunp = tb_bunpay.sex_bunpay 
        and tb_bunp.age_bunp = tb_bunpay.age_bunpay
    left join tb_transfer on tb_bunp.bunp_quarter = tb_transfer.transfer_quarter
        and tb_bunp.sex_bunp = tb_transfer.sex_transfer 
        and tb_bunp.age_bunp = tb_transfer.age_transfer
group by 1,2,3
order by 1,2,3 asc
