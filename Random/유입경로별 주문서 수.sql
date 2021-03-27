with a as
(
select order_id, 
	ref_page_id
from visit_TB
where year||month||day >= '20201201' and year||month||day <= '20210120' 
    and page_id = '결제하기'
group by order_id, ref_page_id
),


b as
(
select id, 
	purchase_date, 
        purchase_confirm_date 
from order_TB
)

select a.ref_page_id,
    count(distinct id) as "생성 주문서 수",
    count(distinct case when purchase_date is not null then id else 0 end) as "결제 주문서 수",
    count(distinct case when purchase_confirm_date is not null then id else 0 end) as "구매 확정 주문서 수",
    
    count(distinct case when purchase_date is not null then id else 0 end) / (count(distinct id)::decimal) *100 as "결제/생성 비중",
    count(distinct case when purchase_confirm_date is not null then id else 0 end) / (count(distinct id)::decimal) *100 as "구매 확정/생성 비중",
    count(distinct case when purchase_confirm_date is not null then id else 0 end) / 
    (count(distinct case when purchase_date is not null then id else 0 end)::decimal) *100 as "구매 확정/결제 비중"   
from b 
	join a on a.order_id = b.id
group by a.ref_page_id
order by a.ref_page_id asc
