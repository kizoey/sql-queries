with tb_product as(
    select id, uid, name
    from product_info_TB
    where(case
        when '%{{카테고리}}%' = '%뷰티/미용%' then left(category_id, 3) = '410'
        when '%{{카테고리}}%' = '%패션잡화%' then left(category_id, 3) = '400'
        when '%{{카테고리}}%' = '%디지털/가전%' then left(category_id, 3) = '600'
        when '%{{카테고리}}%' = '%여성의류%' then left(category_id, 3) = '310'
        when '%{{카테고리}}%' = '%남성의류%' then left(category_id, 3) = '320'
        when '%{{카테고리}}%' = '%구인구직%' then left(category_id, 3) = '240'
        when '%{{카테고리}}%' = '%차량/오토바이%' then left(category_id, 3) = '750'
        when '%{{카테고리}}%' = '%스포츠/레저%' then left(category_id, 3) = '700'
        when '%{{카테고리}}%' = '%유아동/출산%' then left(category_id, 3) = '500'
        when '%{{카테고리}}%' = '%지역서비스%' then left(category_id, 3) = '220'
        when '%{{카테고리}}%' = '%스타굿즈%' then left(category_id, 3) = '910'
        when '%{{카테고리}}%' = '%도서/티켓/취미/애완%' then left(category_id, 3) = '900'
        when '%{{카테고리}}%' = '%생활/문구/가구/식품%' then left(category_id, 3) = '800'
        when '%{{카테고리}}%' = '%구패션의류%' then left(category_id, 3) = '300'
        when '%{{카테고리}}%' = '%원룸/함께살아요%' then left(category_id, 3) = '230'
        when '%{{카테고리}}%' = '%재능%' then left(category_id, 3) = '210'
        when '%{{카테고리}}%' = '%기타%' then left(category_id, 3) = '999'
        when '%{{카테고리}}%' = '%커뮤니티%' then left(category_id, 3) = '100'
        when '%{{카테고리}}%' = '%번개나눔%' then left(category_id, 3) = '200'
        end)),
  

-- 거래방법1  
tb_bunp as(
    select to_char(updated_at, 'YYYY-MM') as "monthone",
            sum(total_price) as "bunp_mon"
    from 거래방법1_TB tb1
        join tb_product on tb_product.id = tb1.pid
    where updated_at >= '{{From when}}' 
        and updated_at < '{{To when}}'
        and tb_product.name like '%{{검색어}}%'
    group by 1),


-- 거래방법2
tb_bunpay as(
    select to_char(updated_at, 'YYYY-MM') as "monthtwo",
            sum(total_price) as "bunpay_mon"
    from 거래방법2_TB tb2
        join tb_product on tb_product.id = tb2.pid
    where updated_at >= '{{From when}}' 
        and updated_at < '{{To when}}'
        and tb_product.name like '%{{검색어}}%'
    group by 1),


-- 거래방법3
tb_sold as(
    select to_char(updated_at, 'YYYY-MM') as "monththree",
            sum(total_price) as "sold_mon"
    from 거래방법3_TB tb3
        join tb_product on tb_product.id = tb3.pid
    where updated_at >= '{{From when}}' 
        and updated_at < '{{To when}}'
        and type = 'unverified_sold'
        and tb_product.name like '%{{검색어}}%'
    group by 1),


-- 거래방법4
tb_transfer as(
    select to_char(updated_at, 'YYYY-MM') as "monthfour",
            sum(total_price) as "transfer_mon"
    from 거래방법4_TB tb4
        join tb_product on tb_product.id = tb4.pid
    where updated_at >= '{{From when}}' 
        and updated_at < '{{To when}}'
        and tb_product.name like '%{{검색어}}%'
    group by 1)
    

select monthone as "Month", 
        (bunp_mon + tb_bunpay.bunpay_mon + tb_sold.sold_mon + tb_transfer.transfer_mon) as "Total_Mon"
from tb_bunp
    left join tb_bunpay on tb_bunp.monthone = tb_bunpay.monthtwo
    left join tb_sold on tb_bunp.monthone = tb_sold.monththree
    left join tb_transfer on tb_bunp.monthone = tb_transfer.monthfour
group by 1,2
order by 1 asc
