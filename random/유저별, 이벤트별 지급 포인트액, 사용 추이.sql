-- 지급받은 포인트 TB
with tb_give as(
    select uid as "give_uid",
            id as "give_id",
            amount as "give_amount",
            parent_id as "parent_iid"
    from pay_point_TB
    where parent_id is NULL
        and created_at >= '{{From When}}' 
        and created_at <= '{{To When}} 23:59:59'
        and title = '{{지급 포인트 타이틀}}'
),


-- 지급받은 포인트 집계 TB
tb_give_sum as(
    select give_uid,
            sum(give_amount) as "sum_give_amount"
    from tb_give
    group by 1
),


-- 사용한 포인트 TB
tb_use as(
    select uid as "use_uid",
            parent_id as "parent_id",
            abs(amount) as "use_amount"
    from service1_quicket.pay_point pay
        right join tb_give on tb_give.give_id = pay.parent_id
    where (status = 'used'
        or status = 'usage')
        and parent_id is NOT NULL
),


-- 사용한 포인트 집계 TB
tb_use_sum as(
    select use_uid,
            sum(use_amount) as "sum_use_amount",
            count(*) as "sum_use_count"
    from tb_use
    group by 1
)


-- UID 매칭키로 지급받은 포인트 집계 TB, 사용한 포인트 집계 TB LEFT JOIN
select
    give_uid as "UID",
    sum_give_amount as "지급받은 포인트액",
    case when tb_use_sum.sum_use_amount is NOT NULL then tb_use_sum.sum_use_amount else 0 end as "소진 포인트액",
    ((case when tb_use_sum.sum_use_amount is NOT NULL then tb_use_sum.sum_use_amount else 0 end) / sum_give_amount::decimal ) *100 as "소진율(%)",
    case when tb_use_sum.sum_use_count is NOT NULL then tb_use_sum.sum_use_count else 0 end as "포인트 사용 횟수"
from tb_give_sum
    left join tb_use_sum on tb_give_sum.give_uid = tb_use_sum.use_uid
order by 4 desc, 1 asc
