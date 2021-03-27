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


-- 내폰시세진입
tb_visit_a as
(
    select visit_id_a
    from(
        select distinct user_id as "visit_id_a"
        from visit_TB
        where page_id = '내폰시세진입'
            and year||month||day >= '20201023'
            and device_type = 'a') v
    join tb_android on tb_android.유저IDA = v.visit_id_a
),


-- 내폰시세조회
tb_look_a as
(
    select look_id_a
    from(
        select distinct user_id as "look_id_a"
        from visit_TB
        where page_id = '내폰시세조회'
            and year||month||day >= '20201023'
            and device_type = 'a') v
    join tb_android on tb_android.유저IDA = v.look_id_a
),


-- 내폰시세신청완료
tb_use_a as
(
    select use_id_a
    from(
        select distinct user_id as "use_id_a"
        from visit_TB
        where page_id = '내폰시세신청완료'
            and year||month||day >= '20201023'
            and device_type = 'a') v
    join tb_android on tb_android.유저IDA = v.use_id_a
)

-- 최종 3가지 항목 OS별 유저 수 (Android)
select 'search' as type,
	count(distinct tb_android.유저IDA)
from tb_android

union all

select 'visit' as type,
	count(distinct visit_id_a)
from tb_visit_a

union all

select 'look' as type,
	count(distinct look_id_a)
from tb_look_a

union all

select 'use' as type,
	count(distinct use_id_a)
from tb_use_a
