-- 1,2,3차 카테고리별 연령, 성별 거래액/거래건수 추이 (번개페이+번프+Verified)

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


-- 1,2,3차 카테고리 선정
tb_product as(
    select id as "product_id",
            uid,
            case 
                when left(p.category_id, 3) = '410' then '뷰티_미용'
                when left(p.category_id, 3) = '400' then '패션잡화'
…
 when p.category_id = '910800008' then '인형/피규어'
               else 'NO_CATEGORY' end as category_3rd
    from service1_quicket.product_info p
),


-- 번개프로미스
tb_bunp as(
    select date_trunc('quarter', updated_at) as "bunp_quarter",
            tb_product.category_1st as "bunp_1st_category",
            tb_product.category_2nd as "bunp_2nd_category",
            tb_product.category_3rd as "bunp_3rd_category",
            tb_info.성별 as "sex_bunp",
            tb_info.연령 as "age_bunp",
            count(pid) as "bunp_buy",
            sum(total_price) as "bunp_buy_mon"
    from workspace.redash_gmv_revenue_bunp tb2
        join tb_info on tb2.buyer_id = tb_info.user_id
        join tb_product on tb2.pid = tb_product.product_id
    where updated_at >= '20200101' 
    group by 1,2,3,4,5,6
),


-- 번개페이
tb_bunpay as(
    select date_trunc('quarter', updated_at) as "bunpay_quarter",
            tb_product.category_1st as "bunpay_1st_category",
            tb_product.category_2nd as "bunpay_2nd_category",
            tb_product.category_3rd as "bunpay_3rd_category",
            tb_info.성별 as "sex_bunpay",
            tb_info.연령 as "age_bunpay",
            count(pid) as "bunpay_buy",
            sum(total_price) as "bunpay_buy_mon"
    from workspace.redash_gmv_revenue_bunpay tb2
        join tb_info on tb2.buyer_id = tb_info.user_id
        join tb_product on tb2.pid = tb_product.product_id
    where updated_at >= '20200101' 
    group by 1,2,3,4,5,6
),


-- transfer
tb_transfer as(
    select date_trunc('quarter', updated_at) as "transfer_quarter",
            tb_product.category_1st as "transfer_1st_category",
            tb_product.category_2nd as "transfer_2nd_category",
            tb_product.category_3rd as "transfer_3rd_category",
            tb_info.성별 as "sex_transfer",
            tb_info.연령 as "age_transfer",
            count(pid) as "transfer_buy",
            sum(total_price) as "transfer_buy_mon"
    from workspace.redash_gmv_revenue_transfer tb2
        join tb_info on tb2.buyer_id = tb_info.user_id
        join tb_product on tb2.pid = tb_product.product_id
    where updated_at >= '20200101' 
    group by 1,2,3,4,5,6
)


-- 거래건수+거래액 추출
select case when left(bunp_quarter, 10) = '2020-01-01' then '2020_1Q'
            when left(bunp_quarter, 10) = '2020-04-01' then '2020_2Q'
            when left(bunp_quarter, 10) = '2020-07-01' then '2020_3Q'
            when left(bunp_quarter, 10) = '2020-10-01' then '2020_4Q'
            else '2021_1Q' end as "분기",
    bunp_1st_category as "1차카테고리",
    bunp_2nd_category as "2차카테고리",
    bunp_3rd_category as "3차카테고리",
    sex_bunp as "성별",
    age_bunp as "연령대",

    sum(coalesce(tb_bunpay.bunpay_buy,0)) as "번개페이 거래건수",
    sum(coalesce(tb_bunpay.bunpay_buy_mon,0)) as "번개페이 거래액",
    
    sum(coalesce(bunp_buy,0)) as "번개프로미스 거래건수",
    sum(coalesce(bunp_buy_mon,0)) as "번개프로미스 거래액",
    
    sum(coalesce(tb_bunpay.bunpay_buy,0) + coalesce(bunp_buy,0) + coalesce(tb_transfer.transfer_buy,0)) as "Verified 거래건수",
    sum(coalesce(tb_bunpay.bunpay_buy_mon,0) + coalesce(bunp_buy_mon,0) + coalesce(tb_transfer.transfer_buy_mon,0)) as "Verified 거래액"
from tb_bunp
    left join tb_bunpay on tb_bunp.bunp_quarter = tb_bunpay.bunpay_quarter 
        and tb_bunp.bunp_1st_category = tb_bunpay.bunpay_1st_category 
        and tb_bunp.bunp_2nd_category = tb_bunpay.bunpay_2nd_category
        and tb_bunp.bunp_3rd_category = tb_bunpay.bunpay_3rd_category
        and tb_bunp.sex_bunp = tb_bunpay.sex_bunpay 
        and tb_bunp.age_bunp = tb_bunpay.age_bunpay
    left join tb_transfer on tb_bunp.bunp_quarter = tb_transfer.transfer_quarter
        and tb_bunp.bunp_1st_category = tb_transfer.transfer_1st_category 
        and tb_bunp.bunp_2nd_category = tb_transfer.transfer_2nd_category
        and tb_bunp.bunp_3rd_category = tb_transfer.transfer_3rd_category
        and tb_bunp.sex_bunp = tb_transfer.sex_transfer 
        and tb_bunp.age_bunp = tb_transfer.age_transfer
group by 1,2,3,4,5,6
order by 1,2,3,4,5,6 asc
