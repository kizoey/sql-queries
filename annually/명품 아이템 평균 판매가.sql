with tb_product as(
    select id
    from product_info_TB
    where left(category_id, 6) = '000XXX'
        and (name like '%롤렉스%데이져스트%' or name like '%로렉스%데이져스트%'
            or name like '%롤렉스%데이저스트%' or name like '%로렉스%데이저스트%')),

-- 거래방법2
tb_bunpay as(
    select sum(total_price) as "bunpay_mon",
            count(pid) as "bunpay_cnt"
    from 거래방법2_TB tb2
        join tb_product on tb_product.id = tb2.pid
    where updated_at >= '20200101'
        and updated_at < '20210101'
        and total_price >= 4000000),


-- 거래방법3
tb_transfer as(
    select sum(total_price) as "transfer_mon",
            count(pid) as "transfer_cnt"
    from 거래방법3_TB tb4
        join tb_product on tb_product.id = tb4.pid
    where updated_at >= '20200101'
        and updated_at < '20210101'
        and total_price >= 4000000)
    

select bunpay_mon, bunpay_cnt 
from tb_bunpay
union all 
select transfer_mon, transfer_cnt 
from tb_transfer
