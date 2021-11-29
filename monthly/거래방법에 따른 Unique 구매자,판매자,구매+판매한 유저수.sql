with tb1 as(
            select date_trunc('month', date) as "month", 
                buyer_id, 
                b.user_id as "seller_id"
            from(select * 거래방법1_TB where date >= '20200101' and date < '20210101'
                union
                select * from 거래방법2_TB where date >= '20200101' and date < '20210101') a
JOIN 
상품정보_TB b on a.pid=b.id)

select month_cnt, buyer_cnt, seller_cnt, total_cnt
from(
        select month as "month_cnt", 
                count(distinct buyer_id) as "buyer_cnt", 
                count(distinct seller_id)as "seller_cnt" from tb1
        group by month) tb2
JOIN

    (
        select month, count(distinct total) as "total_cnt"
        from (select month, buyer_id as "total" from tb1 intersect
            select month, seller_id as "total" from tb1)
            group by month) tb3
            on tb2.month_cnt = tb3.month
    order by month asc
