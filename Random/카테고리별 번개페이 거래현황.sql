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


-- 신규 구매
tb_first as(
    select date_first,
            sum(total_price) as "신규구매결제완료금액",
            count(distinct buyer_id) as "신규구매결제완료자수",
            count(mast.id) as "신규결제건수",
            sum(total_price)/count(distinct buyer_id) as "인당신규결제완료금액",
            count(mast.id)/count(distinct buyer_id) as "인당신규결제완료건수",
            sum(total_price)/count(mast.id) as "신규결제건당결제금액"
    from(
        select date_trunc('{{계산 기준(월/주/일)}}', setl_done_date) as "date_first",
                total_price,
                buyer_id,
                id,
                row_number() over (partition by buyer_id order by setl_done_date asc) as "row"
    from order_mast_TB
    where setl_done_date is NOT NULL
        and setl_done_date >= '{{From When}}' 
        and setl_done_date <= '{{To When}} 23:59:59') mast
        join order_item_TB item on mast.id = item.order_mast_id
        join tb_product on item.pid = tb_product.product_id
    where row = 1
    group by 1
    order by 1 asc
),


-- 재구매 (신규 구매를 제외한 모든 구매)
tb_second as(
    select date_second,
            sum(total_price) as "재구매결제완료금액",
            count(distinct buyer_id) as "재구매결제완료자수",
            count(mast.id) as "재구매결제건수",
            sum(total_price)/count(distinct buyer_id) as "인당재구매결제완료금액",
            count(mast.id)/count(distinct buyer_id)::decimal as "인당재구매결제완료건수",
            sum(total_price)/count(mast.id) as "재구매결제건당결제금액"
    from(
        select date_trunc('{{계산 기준(월/주/일)}}', setl_done_date) as "date_second",
                total_price,
                buyer_id,
                id,
                row_number() over (partition by buyer_id order by setl_done_date asc) as "row"
    from order_mast_TB
    where setl_done_date is NOT NULL
            and setl_done_date >= '{{From When}}' 
        and setl_done_date <= '{{To When}} 23:59:59') mast
        join service1_quicket.order_item item on mast.id = item.order_mast_id
        join tb_product on item.pid = tb_product.product_id
    where row != 1
    group by 1
    order by 1 asc
),


-- 신규구매+재구매
tb_total as(
    select date_trunc('{{계산 기준(월/주/일)}}', setl_done_date) as "date_total",
            count(distinct buyer_id) as "결제완료자수",
            sum(total_price)/count(distinct buyer_id) as "인당결제완료금액",
            count(mast.id)/count(distinct buyer_id)::decimal as "인당결제완료건수",
            sum(total_price)/count(mast.id) as "결제건당결제금액"
    from service1_quicket.order_mast mast
        join order_item_TB item on mast.id = item.order_mast_id
        join tb_product on item.pid = tb_product.product_id
    where setl_done_date is NOT NULL
        and setl_done_date >= '{{From When}}' 
        and setl_done_date <= '{{To When}} 23:59:59'
    group by 1
    order by 1 asc
)


select left(date_total,10) as "일자", 
        sum(결제완료자수) as "결제완료자수", 
        sum(tb_first.신규구매결제완료금액) as "신규구매 결제완료금액",
        sum(tb_first.신규구매결제완료자수) as "신규구매 결제완료자수",
        sum(tb_second.재구매결제완료금액) as "재구매 결제완료금액",
        sum(tb_second.재구매결제완료자수) as "재구매 결제완료자수",
        
        sum(tb_first.신규결제건수) as "신규 결제건수",
        sum(tb_second.재구매결제건수) as "재구매 결제건수",
        sum(tb_first.신규결제건수 + tb_second.재구매결제건수) as "총 결제건수",
        
        sum(인당결제완료금액) as "인당 결제완료금액",
        sum(tb_first.인당신규결제완료금액) as "인당 신규 결제완료금액",
        sum(tb_second.인당재구매결제완료금액) as "인당 재구매 결제완료금액",
        
        sum(인당결제완료건수) as "인당 결제완료건수",
        sum(tb_first.인당신규결제완료건수) as "인당 신규 결제완료건수",
        sum(tb_second.인당재구매결제완료건수) as "인당 재구매 결제완료건수",
        
        sum(결제건당결제금액) as "결제건당 결제금액",
        sum(tb_first.신규결제건당결제금액) as "신규 결제건당 결제금액",
        sum(tb_second.재구매결제건당결제금액) as "재구매 결제건당 결제금액"
from tb_total
    left join tb_first on tb_total.date_total = tb_first.date_first
    left join tb_second on tb_total.date_total = tb_second.date_second
group by 1
order by 1 asc
