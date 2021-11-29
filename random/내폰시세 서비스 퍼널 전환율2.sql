-- 업자
with tb_seller as
(
    select uid as "seller_id"
    from product_info_TB
    where left(category_id,6) = '600700'
        and name like '%매입%'
),

-- Android (20-10-23) 3개월전부터 중고폰매입 검색 유저 (업자제외)
tb_android as
(
    select 유저IDA
    from (
        select distinct user_id as "유저IDA"
        from search_TB
        where year||month||day >= to_char(dateadd(month, -3, '20201023'), 'YYYYMMDD')
            and device_type = 'a'
            and search_term in ('중고폰매입', '중고폰 매입', '폰매입', '폰 매입', '휴대폰매입', '휴대폰 매입',
                                '핸드폰매입', '핸드폰 매입', '스마트폰매입', '스마트폰 매입')
        ) s
    left join tb_seller on s.유저IDA = tb_seller.seller_id
    where tb_seller.seller_id is NULL
),

-- 배송완료
tb_ship_a as
(
    select ship_id_a
    from(
        select distinct uid as "ship_id_a"
        from purchase_order_TB
        where status in ('SHIPPING', 'ARRIVED', 'INSPECTION', 'ESTIMATED', 'ACCEPT', 'COMPLETE')
            and created_at >= '20201023'
            and device_type = 'A') v
    join tb_android on tb_android.유저IDA = v.ship_id_a
),

-- 매입완료
tb_complete_a as
(
    select complete_id_a
    from(
        select distinct uid as "complete_id_a"
        from purchase_order_TB
        where status = 'COMPLETE'
            and created_at >= '20201023'
            and device_type = 'A') v
    join tb_android on tb_android.유저IDA = v.complete_id_a
)

select 'ship' as status, 
	count(ship_id_a)
from tb_ship_a

union all 

select 'complete' as status, 
	count(complete_id_a)
from tb_complete_a
