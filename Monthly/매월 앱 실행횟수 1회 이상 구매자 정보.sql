-- visit TB 정보
with tb_info as
(
    select distinct uid as "UID",
            to_char(join_date, 'YYYY-MM-DD') as "가입일자",
            case when gender = 'male' then 'M'
                when gender = 'female' then 'F' end as "성별",
            birth_year as "출생년도",
            count(distinct date_trunc('month', visit_date)) as "count_visit_month"
    from app_visit_user_TB
    where visit_date >= '{{ 앱실행기간.start }}'
        and visit_date < '{{ 앱실행기간.end }}'
    having count_visit_month = datediff('month', '{{ 앱실행기간.start }}', '{{ 앱실행기간.end }}')
),


-- 앱 평균실행횟수
tb_access as
(
    select uid as "user_iid",
            to_char(visit_date, 'YYYY-MM') as "dating",
            count(distinct visit_date) as "visitdays"
    from app_visit_user_TB
    where
        visit_date >= '{{ 앱실행기간.start }}'
        and visit_date < '{{ 앱실행기간.end }}'
    group by 1,2
),


-- 검색수
tb_search as
(
    select user_id,
            count(search_term) as "총검색수"
    from search_TB
    where to_date(year||month||day, 'YYYYMMDD') >= '{{ 앱실행기간.start }}'
        and to_date(year||month||day, 'YYYYMMDD') < '{{ 앱실행기간.end }}'
    group by 1
),


-- 구매액(거래방법1)
tb_bunpay_mon as
(
    select buyer_id,
            sum(total_price) as "bunpay_mon"
    from 거래방법1_TB
    where updated_at >= '{{ 앱실행기간.start }}'
        and updated_at < '{{ 앱실행기간.end }}'
    group by 1
),


-- 구매건수(거래방법1)
tb_bunpay_cnt as
(
    select buyer_id,
            count(pid) as "bunpay_cnt"
    from 거래방법1_TB
    where updated_at >= '{{ 앱실행기간.start }}'
        and updated_at < '{{ 앱실행기간.end }}'
    group by 1
),


-- 구매액(거래방법2)
tb_bunp_mon as
(
    select buyer_id,
            sum(total_price) as "bunp_mon"
    from 거래방법2_TB
    where updated_at >= '{{ 앱실행기간.start }}'
        and updated_at < '{{ 앱실행기간.end }}'
    group by 1
),


-- 구매건수(거래방법2)
tb_bunp_cnt as
(
    select buyer_id,
            count(pid) as "bunp_cnt"
    from 거래방법2_TB
    where updated_at >= '{{ 앱실행기간.start }}'
        and updated_at < '{{ 앱실행기간.end }}'
    group by 1)
    
    
-- 최종 Output 추출
select UID,
        가입일자,
        성별,
        출생년도,
        avg(tb_access.visitdays) as "월평균 실행일수",
        sum(tb_search.총검색수) as "총 검색 수",
        sum(tb_bunpay_mon.bunpay_mon) as "구매액(번개페이)",
        sum(tb_bunpay_cnt.bunpay_cnt) as "구매건수(번개페이)",
        sum(tb_bunp_mon.bunp_mon) as "구매액(번프)",
        sum(tb_bunp_cnt.bunp_cnt) as "구매건수(번프)"
from tb_info
    left join tb_access on tb_info.UID = tb_access.user_iid
    left join tb_search on tb_info.UID = tb_search.user_id
    left join tb_bunpay_mon on tb_info.UID = tb_bunpay_mon.buyer_id
    left join tb_bunpay_cnt on tb_info.UID = tb_bunpay_cnt.buyer_id
    left join tb_bunp_mon on tb_info.UID = tb_bunp_mon.buyer_id
    left join tb_bunp_cnt on tb_info.UID = tb_bunp_cnt.buyer_id
group by 1,2,3,4
