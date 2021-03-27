select to_char(date_trunc('month', (to_date(year||month||day, 'YYYYMMDD'))), 'YYYY-MM') as "month",
        count(event_action) as "찜수"
from wishlist_TB a
    join product_info_TB b on a.content_id = b.id
where b.name like '%{{검색어}}%'
    and event_action = 'add_to_wishlist'
    and to_date(year||month||day, 'YYYYMMDD') >= '{{From when}}' 
    and to_date(year||month||day, 'YYYYMMDD') < '{{To when}}'
    and (case
        when '%{{카테고리}}%' = '%뷰티/미용%' then left(b.category_id, 3) = '410'
        when '%{{카테고리}}%' = '%패션잡화%' then left(b.category_id, 3) = '400'
        when '%{{카테고리}}%' = '%디지털/가전%' then left(b.category_id, 3) = '600'
        when '%{{카테고리}}%' = '%여성의류%' then left(b.category_id, 3) = '310'
        when '%{{카테고리}}%' = '%남성의류%' then left(b.category_id, 3) = '320'
        when '%{{카테고리}}%' = '%구인구직%' then left(b.category_id, 3) = '240'
        when '%{{카테고리}}%' = '%차량/오토바이%' then left(b.category_id, 3) = '750'
        when '%{{카테고리}}%' = '%스포츠/레저%' then left(b.category_id, 3) = '700'
        when '%{{카테고리}}%' = '%유아동/출산%' then left(b.category_id, 3) = '500'
        when '%{{카테고리}}%' = '%지역서비스%' then left(b.category_id, 3) = '220'
        when '%{{카테고리}}%' = '%스타굿즈%' then left(b.category_id, 3) = '910'
        when '%{{카테고리}}%' = '%도서/티켓/취미/애완%' then left(b.category_id, 3) = '900'
        when '%{{카테고리}}%' = '%생활/문구/가구/식품%' then left(b.category_id, 3) = '800'
        when '%{{카테고리}}%' = '%구패션의류%' then left(b.category_id, 3) = '300'
        when '%{{카테고리}}%' = '%원룸/함께살아요%' then left(b.category_id, 3) = '230'
        when '%{{카테고리}}%' = '%재능%' then left(b.category_id, 3) = '210'
        when '%{{카테고리}}%' = '%기타%' then left(b.category_id, 3) = '999'
        when '%{{카테고리}}%' = '%커뮤니티%' then left(b.category_id, 3) = '100'
        when '%{{카테고리}}%' = '%번개나눔%' then left(b.category_id, 3) = '200'
        end)
group by 1
order by 1 asc
