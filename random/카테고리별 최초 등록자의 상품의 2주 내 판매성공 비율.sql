-- 특정 가입일자 이후인 uid 추출
with tb_user as
(
    select id as "유저ID"
    from user_TB
    where join_date >= '{{ 신규가입일 }}'
),


-- uid, 카테고리별로 최초등록일자 출력
tb_product as
(
    select uid as "user_id",
            left(category_id, 3) as "categories", 
            date_trunc('day', min(create_date)) as "first_register_date"
    from product_info_TB
    where user_id in (select * from tb_user)
    group by 1,2
),


-- uid, 카테고리별로 최초등록날에 등록된 상품 출력
tb_first as
(
    select user_id,
            c.id as "product_id",
            d.name as "category",
            first_register_date
    from tb_product
        join product_info_TB c
            on tb_product.user_id = c.uid
            and categories = left(c.category_id, 3)
            and first_register_date = date_trunc('day', c.create_date)
        join categories_TB d on categories = d.category  
),


--  판매 성공 일자 추출 (Verified)
tb_revenue1 as
(
    select pid, updated_at from 거래방법1_gmv_TB union all
    select pid, updated_at from 거래방법2_gmv_TB union all
    select pid, updated_at from 거래방법3_gmv_TB
),


--  판매 성공 일자 추출 (Total)
tb_revenue2 as
(
    select pid, updated_at from 거래방법1_gmv_TB union all
    select pid, updated_at from 거래방법2_gmv_TB union all
    select pid, updated_at from 거래방법3_gmv_TB union all
    select pid, updated_at from 거래방법4_gmv_TB where type = 'unverified_sold' 
),


-- Verified 판매 성공한 유저ID
tb_veri as
(
    select 'verified' as type, category, count(distinct user_id) as user_count
    from tb_first tf
    join tb_revenue1 tr on tf.product_id = tr.pid
    where updated_at >= tf.first_register_date and updated_at <= dateadd(day, '{{며칠 내}}', tf.first_register_date)
    group by 1, 2
),


-- Total 판매 성공한 유저ID
tb_total as
(
    select 'total' as type, category, count(distinct user_id) as user_count
    from tb_first tf
    join tb_revenue2 tr on tf.product_id = tr.pid
    where updated_at >= tf.first_register_date and updated_at <= dateadd(week, 2, tf.first_register_date)
    group by 1, 2
)


-- 판매 성공 비율 추출
select rv.category, total_user_count, user_count, ( user_count / total_user_count::decimal ) * 100 as "비중(%)"
from
    (
    select * from tb_veri union all
    select * from tb_total
    ) rv
join 
    (
    select category, count(distinct user_id) as total_user_count
    from tb_first
    group by 1
    ) tf on rv.category = tf.category
where rv.type = 'total'
order by 4 desc
