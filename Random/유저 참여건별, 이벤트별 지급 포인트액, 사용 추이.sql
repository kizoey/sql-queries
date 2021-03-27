set time zone 'Asia/Seoul';

-- 지급받은 포인트 TB
with tb_give as(
    select id as "give_id",
            uid as "give_uid",
            parent_id as "parent_iid",
            amount as "give_amount",
            created_at as "지급일",
            expire_at as "만료일"
    from pay_point_TB
    where parent_id is NULL
        and created_at >= '{{From When}}' 
        and created_at <= '{{To When}} 23:59:59'
        and title = '{{지급 포인트 타이틀}}'
),


-- 지급받은 포인트 집계 TB
tb_give_sum as(
    select give_id,
            give_uid,
            지급일,
            만료일,
            sum(give_amount) as "sum_give_amount"
    from tb_give
    group by 1,2,3,4
),


-- 사용한 포인트 TB
tb_use as(
    select id as "use_id",
            uid as "use_uid",
            abs(amount) as "use_amount",
            parent_id as "parent_id"
        from service1_quicket.pay_point pay
            right join tb_give on tb_give.give_id = pay.parent_id
    where (status = 'used'
        or status = 'usage')
        and parent_id is NOT NULL
),


-- 사용한 포인트 집계 TB
tb_use_sum as(
    select parent_id,
            sum(use_amount) as "sum_use_amount",
            count(*) as "sum_use_count"
    from tb_use
    group by 1
)


-- 지급+사용TB left join
select give_uid as "UID",
        left(date_trunc('day', 지급일), 10) as "포인트 지급일",
        left(date_trunc('day', 만료일), 10) as "포인트 만료일",
        (case when datediff('day', current_date, 만료일) > 0 then datediff('day', current_date, 만료일) else -1 end) as "만료까지 남은 일자",
        sum_give_amount as "지급받은 포인트액",
         case when tb_use_sum.sum_use_amount is NOT NULL then tb_use_sum.sum_use_amount else 0 end as "소진 포인트액",
        ((case when tb_use_sum.sum_use_amount is NOT NULL then tb_use_sum.sum_use_amount else 0 end) / sum_give_amount::decimal ) *100 as "소진율(%)",
        case when tb_use_sum.sum_use_count is NOT NULL then tb_use_sum.sum_use_count else 0 end as "포인트 사용 횟수"
from tb_give_sum
    left join tb_use_sum on tb_give_sum.give_id = tb_use_sum.parent_id
order by 7 desc, 1 asc
