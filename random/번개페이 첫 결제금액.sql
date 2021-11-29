select left(dating, 10) as "일자",
        case 
        when left(pi.category_id, 3) = '410' then '뷰티_미용'
        ...
        else 'no_category' end as "1차카테고리",
        sum(total_price) as "결재액",
        count(o.pid) as "결제건수",
        avg(total_price) as "인당 평균 결제금액"
from(
    select date_trunc('{{계산 기준(주/일)}}', t.setl_done_date) as "dating",
            pid,
            total_price
    from 
        (
            select buyer_id, 
                    total_price,
                    setl_done_date,
                    id as "pid",
                    row_number() over (partition by buyer_id order by setl_done_date) as row
            from order_mast_TB
            where setl_done_date is NOT NULL
        ) t
    where t.row = 1
        and t.setl_done_date >= '{{From When}}' 
        and t.setl_done_date <= '{{To When}} 23:59:59'
    ) o
    join order_item_TB item on o.pid = item.order_mast_id
    join product_info_TB pi on item.pid = pi.id
group by 1,2
order by 1 asc
