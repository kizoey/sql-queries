-- 2020+2021 더해주기 (상태변경)
with tb_status as(
    select status, pid, server_time from status_change_2020_TB where month >= '11'
    union all
    select status, pid, server_time from status_change_2021_TB
),


-- 2020+2021 더해주기 (번프)
tb_bunp1 as(
    select bunp_id, server_time from bunp_2020_TB where month >= '11'
    union all
    select bunp_id, server_time from bunp_2021_TB
),

-- 번프 최초로 생긴 pid
tb_bunp2 as(
    select seller_pid, min(convert_timezone('UTC', 'KST', server_time::timestamp)) as "bunp_time"
    from promise_TB prom
        join tb_bunp1 on prom.id = tb_bunp1.bunp_id
    group by 1
),

-- 번개페이 최초로 생긴 pid
tb_bunpay as(
    select pid, min(setl_done_date) as "bunpay_time"
    from order_item_TB it
        join order_mast_TB mast on it.order_mast_id = mast.id
    group by 1
),
 
-- 상품카테고리 조건 만족
tb_product as(
    select create_date,
        id as "product_id"
    from product_info_TB
    where category_id = '600700001'
        and create_date >= '20201125'
        and create_date <= '20201218'
),


-- 번프 최초 일자 5일 이후
tb_bunp3 as(
    select product_id
    from tb_product
        join tb_bunp2 on tb_product.product_id = tb_bunp2.seller_pid
    where datediff('day', create_date::timestamp, tb_bunp2.bunp_time::timestamp) > 5
),

-- 번프 이력 현재까지 없는 pid
tb_bunp4 as(
    select product_id
    from tb_product
        left join tb_bunp2 on tb_product.product_id = tb_bunp2.seller_pid
    where tb_bunp2.bunp_time is NULL
),


-- 번개페이 결제 최초 일자 5일 이후
tb_bunpay3 as(
    select product_id
    from tb_product
        join tb_bunpay on tb_product.product_id = tb_bunpay.pid
    where datediff('day', create_date::timestamp, tb_bunpay.bunpay_time::timestamp) > 5
),

-- 번개페이 결제 없는 pid
tb_bunpay4 as(
    select product_id
    from tb_product
        left join tb_bunpay on tb_product.product_id = tb_bunpay.pid
    where tb_bunpay.bunpay_time is NULL
),


-- 5일차에도 status=0
-- case1: 5일차까지 status 변경이력 있음 (5일차에는 0인 경우)
tb_status3 as(
    select pid
    from(
        select pid, status
        from(
            select pid, status,
                row_number() over(partition by pid order by convert_timezone('UTC', 'KST', server_time::timestamp) desc) as "num"
            from tb_status
                join tb_product on tb_product.product_id = tb_status.pid
            where datediff('day', tb_product.create_date::timestamp, convert_timezone('UTC', 'KST', server_time::timestamp)) <= 5)
        where num = 1
        )
    where status = 0
),


-- case2: 5일차까지 한결같이 0인 경우 (5일차에 계속 0인 경우)
tb_status4 as(
    select product_id
    from tb_product
        left join tb_status on tb_product.product_id = tb_status.pid
    where (case when tb_status.pid is not null then 
        datediff('day', create_date::timestamp, convert_timezone('UTC', 'KST', tb_status.server_time::timestamp)) end) <= 5
        or tb_status.pid is null
),


-- 번프(OR로 묶기)
tb_bunp5 as(
    select product_id::varchar from tb_bunp3
    union
    select product_id::varchar from tb_bunp4
),

--번페(OR로 묶기)
tb_bunpay5 as(
    select product_id::varchar from tb_bunpay3
    union
    select product_id::varchar from tb_bunpay4
),

-- status(OR로 묶기)
tb_status5 as(
    select pid::varchar from tb_status3
    union
    select product_id::varchar from tb_status4
),

tb_final as(
    select * from tb_bunp5
    intersect
    select * from tb_bunpay5
    intersect
    select * from tb_status5
)


select distinct uid as "등록유저"
from product_info_TB
where id in (select * from tb_final)
order by 1
