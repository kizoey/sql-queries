-- total 거래건수
with tb_product as(
    select id, uid, name  
    from product_info_TB
    where left(category_id, 6) = '700600'),

-- 거래방법1
tb_bunp as(
    select count(case when tb_product.name like '%{{검색어}}%' then 1 end) as "bunp_cnt"
    from 거래방법1_TB tb1
        join tb_product on tb_product.id = tb1.pid
    where updated_at >= '{{From when}}' 
        and updated_at < '{{To when}}'),


-- 거래방법2
tb_bunpay as(
    select count(case when tb_product.name like '%{{검색어}}%' then 1 end) as "bunpay_cnt"
    from 거래방법2_TB tb2
        join tb_product on tb_product.id = tb2.pid
    where updated_at >= '{{From when}}' 
        and updated_at < '{{To when}}'),


-- 거래방법3
tb_sold as(
    select count(case when tb_product.name like '%{{검색어}}%' then 1 end) as "sold_cnt"
    from 거래방법3_TB tb3
        join tb_product on tb_product.id = tb3.pid
    where updated_at >= '{{From when}}' 
        and updated_at < '{{To when}}'
        and type = 'unverified_sold'),
    
  
-- 거래방법4
tb_transfer as(
    select count(case when tb_product.name like '%{{검색어}}%' then 1 end) as "transfer_cnt"
    from 거래방법4_TB tb4
        join tb_product on tb_product.id = tb4.pid
    where updated_at >= '{{From when}}' 
        and updated_at < '{{To when}}')
    
    
select *
from tb_bunp
union all 
select *
from tb_bunpay
union all
select *
from tb_sold
union all
select *
from tb_transfer
