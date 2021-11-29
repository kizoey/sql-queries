with tb1 as(
select content_id, 
	to_date(year||month||day, 'YYYYMMDD') as "weekly"
from view_TB 
where page_id = '상품상세'
	and year||month||day = '20201228'),
 
pi as(
select id,
	case
	when left(category_id, 3) = '000' then '1차카테고리명'
	when….
	else 'no_category' end as category_1st,
    
	case
	when left(category_id, 6) = '000XXX' then '2차카테고리명'
	when…
	else 'no_category' end as category_2nd,
    
    case
	when category_id = '000XXXYYY' then '3차카테고리명'
	when…
	else 'no_category' end as category_3rd
from
       product_info_TB)
       
select date_trunc('week', tb1.weekly) as "주차별",
	count(distinct tb1.content_id) as "상품상세조회수",
	category_1st,
	category_2nd,
	category_3rd from pi join tb1 on tb1.content_id=pi.id
group by 1,3,4,5
order by 1 asc
