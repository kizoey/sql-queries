set time zone 'Asia/Seoul';

-- 유저 정보(UID, 가입일)
with tb_info as(
    select id as "user_id",
        join_date
    from user_TB
),

tb_product as(
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
group by 1 
order by 1 asc
)


select UID, 
        가입일,
        sum(total_price) as "누적구매금액",
        count(pid) as "누적구매횟수",
        avg(total_price) as "평균구매금액",
        min(updated_at) as "최초구매날짜",
        max(updated_at) as "재구매마지막날짜",
        datediff('day', min(updated_at), max(updated_at))/(count(UID)-1)::decimal as "재구매주기"
from(
    select *
    from(
        select tb_info.user_id as "UID",
            to_char(tb_info.join_date, 'YYYY-MM-DD') as "가입일",
            total_price,
            pid,
            updated_at
        from bunpay_TB bunpay
            join tb_product on bunpay.pid = tb_product.product_id
            join tb_info on bunpay.buyer_id = tb_info.user_id
        ) y
    where y.updated_at >= '{{From When}}' 
        and y.updated_at <= '{{To When}} 23:59:59'
    )
group by 1,2
having min(updated_at) != max(updated_at)
order by 8 desc
