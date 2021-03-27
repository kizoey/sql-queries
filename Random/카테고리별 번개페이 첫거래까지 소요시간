with tb_product as(
    select id as "product_id",
            case 
        when left(category_id, 3) = '410' then '뷰티_미용'
        ...
        else 'no_category' end as "category_1st"
    from product_info_TB
    group by 1,2
    order by 1 asc
)


select
    to_char(date_trunc('{{계산 기준(주/일)}}', o.updated_at), 'YYYY-MM-DD') as "일자",
    tb_product.category_1st as "1차카테고리",
    count(case when datediff('day', u.join_date, o.updated_at) = 0 then 1 end) as "D+0",
    count(case when datediff('day', u.join_date, o.updated_at) between 1 and 3 then 1 end) as "D+1~D+3",
    count(case when datediff('day', u.join_date, o.updated_at) between 4 and 7 then 1 end) as "D+4~D+7",
    count(case when datediff('day', u.join_date, o.updated_at) between 8 and 15 then 1 end) as "D+8~D+15",
    count(case when datediff('day', u.join_date, o.updated_at) between 16 and 30 then 1 end) as "D+16~D+30",
    count(case when datediff('day', u.join_date, o.updated_at) between 31 and 90 then 1 end) as "D+31~D+90",
    count(case when datediff('day', u.join_date, o.updated_at) between 91 and 180 then 1 end) as "D+91~D+180",
    count(case when datediff('day', u.join_date, o.updated_at) between 181 and 365 then 1 end) as "D+181~D+365",
    count(case when datediff('day', u.join_date, o.updated_at) between 366 and 730 then 1 end) as "D+366~D+730",
    count(case when datediff('day', u.join_date, o.updated_at) > 730 then 1 end) as "D+730~",
    avg(case when datediff('day', u.join_date, o.updated_at) between 0 and 730 then datediff('days', u.join_date, o.updated_at) end)::decimal,
    median(case when datediff('day', u.join_date, o.updated_at) between 0 and 730 then datediff('days', u.join_date, o.updated_at) end)::decimal
from
    (
        select r_p.buyer_id, r_p.updated_at, r_p.id
        from
            (select buyer_id, 
                    id,
                    setl_done_date as updated_at, 
                    row_number() over (partition by buyer_id order by setl_done_date asc) as row_number_pay
            from order_mast_TB
            where setl_done_date is NOT NULL
            ) r_p
        where r_p.row_number_pay = 1
    ) o
    join user_TB u on o.buyer_id = u.id
    join order_item_TB i on o.id = i.order_mast_id
    join tb_product on i.pid = tb_product.product_id
where o.updated_at >= '{{From When}}' 
    and o.updated_at <= '{{To When}} 23:59:59'
group by 1,2
order by 1 asc
