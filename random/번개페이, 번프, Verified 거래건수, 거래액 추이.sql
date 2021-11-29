-- 1,2차 카테고리의 product_id (상품ID) 불러오기
with tb_product as(
    select id as "product_id"
    from product_info_TB
    where
        (case
        when '%{{1차카테고리}}%' = '%전체%' then left(category_id, 3) in 
            ('410', '400', '600', '310', '320', '240', '750', '700', '500', '220', '910', '900', '800', '300', '230', '210', '999', '100', '200')
        when '%{{1차카테고리}}%' = '%뷰티/미용%' then left(category_id, 3) = '410'
        ….
end)
        and 
    (
    case when '%{{2차카테고리}}%' = '%커뮤니티%' then left(category_id, 6) = '100'
        when '%{{2차카테고리}}%' = '%커뮤니티 > 수다방%' then left(category_id, 6) = '100200'
       ….
end
    )
),

-- 거래건수 
tb_bunpay as(
    select date_trunc('{{계산 기준(월/주/일)}}', updated_at) as "month_bunpay",
            sum(total_price) as "bunpay_mon",
            count(pid) as "bunpay_cnt"
    from bunpay_TB tb1
        join tb_product on tb_product.product_id = tb1.pid
    where updated_at >= '{{From When}}' 
        and updated_at <= '{{To When}} 23:59:59'
    group by 1
    order by 1 asc
    ),
    

-- 거래건수 (번프)
tb_bunp as(
    select date_trunc('{{계산 기준(월/주/일)}}', updated_at) as "month_bunp",
            sum(total_price) as "bunp_mon",
            count(pid) as "bunp_cnt"
    from bunp_TB tb2
        join tb_product on tb_product.product_id = tb2.pid
    where updated_at >= '{{From When}}' 
        and updated_at <= '{{To When}} 23:59:59'
    group by 1
    order by 1 asc
    )


-- 전체 피처 불러오기
select left(month_bunpay, 10) as "Date",
    case when sum(bunpay_mon) is NOT NULL then sum(bunpay_mon) else 0 end as "번개페이총거래액",
    case when sum(bunpay_cnt) is NOT NULL then sum(bunpay_cnt) else 0 end as "번개페이건수",

    case when sum(bunp_mon) is NOT NULL then sum(bunp_mon) else 0 end as "번프총거래액",
    case when sum(bunp_cnt) is NOT NULL then sum(bunp_cnt) else 0 end as "번프건수",

    case when sum(bunpay_mon + bunp_mon) is NOT NULL then sum(bunpay_mon + bunp_mon) else 0 end as "Verified총거래액",
    case when sum(bunpay_cnt + bunp_cnt) is NOT NULL then sum(bunpay_cnt + bunp_cnt) else 0 end as "Verified건수"
from tb_bunpay
    left join tb_bunp on tb_bunpay.month_bunpay = tb_bunp.month_bunp
group by 1
order by 1 asc
