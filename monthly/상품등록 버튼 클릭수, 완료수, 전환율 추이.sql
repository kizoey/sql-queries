-- 상품등록 버튼 클릭수
with tb_click as(
    select to_char(date_trunc('month', (to_date(year||month||day, 'YYYYMMDD'))), 'YYYY-MM') as "month1",
            count(page_id) as "버튼클릭수"
    from visit_TB
    where page_id = '상품등록'
        and year||month||day >= '20200801'
        and year||month||day < '20210201'
    group by 1),


-- 상품등록 완료수 (product_info TB참조)
tb_complete as(
    select to_char(create_date, 'YYYY-MM') as "month2",
        count(distinct id) as "완료수"
    from product_info_TB
    where create_date >= '20200801'
        and create_date < '20210201'
    group by 1)


-- 전환율 추가(클릭 -> 완료)
select month1 as "Month",
        버튼클릭수,
        tb_complete.완료수,
        (tb_complete.완료수/버튼클릭수::decimal)*100 as "전환율"
from tb_click
    left join tb_complete on tb_click.month1 = tb_complete.month2
group by 1,2,3,4
order by 1 asc
