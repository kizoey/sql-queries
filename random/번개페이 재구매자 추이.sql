select left(t.일자, 10) as "일자",
        count(distinct t.buyer_id) as "재구매자수"
from(
    select date_trunc('{{계산 기준(월/주/일)}}', setl_done_date) as "일자",
        buyer_id,
        setl_done_date,
        row_number() over (partition by buyer_id order by setl_done_date) as row
    from order_mast_TB mast
    where setl_done_date is NOT NULL
) t
where t.row != 1
    and t.setl_done_date >= '{{From When}}' 
    and t.setl_done_date <= '{{To When}} 23:59:59'
group by 1
order by 1 asc
