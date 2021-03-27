-- 월별로 앱실행 1회 이상인 유저 연령/성별 따라 앱실행일수
-- 2020.01~2021.03 15개월간 매월 시행하지 않았더라도 월별로 집계

set time zone 'Asia/Seoul';

-- 유저 성별, 연령대 정보 (20.01.01 방문한 유저부터)
with tb_info as(
    select uid as "UID",
            case when b.gender = 'male' then '남성' 
                when b.gender = 'female' then '여성'
                else NULL end as "성별", 
            case
                when 2021 - b.birth_year::integer < 25 then '25 under'
                when 2021 - b.birth_year::integer between 25 and 34 then '2534'
                when 2021 - b.birth_year::integer between 35 and 44 then '3544'
                when 2021 - b.birth_year::integer >= 45 then '45+'
                else NULL end as "연령"
    from warehouse.app_visit_user b
    where visit_date >= '20200101'
            and uid is NOT NULL
            and gender is NOT NULL
            and birth_year is NOT NULL
    group by 1,2,3
),


-- 유저별, 월별 앱 평균실행횟수
tb_access as
(
select user_id,
        dating,
        count(distinct visit_date) as "visitdays"
from(
    select uid as "user_id",
            to_char(visit_date, 'YYYY-MM') as "dating",
            visit_date
    from warehouse.app_visit_user
    where visit_date >= '20200101'
    group by 1,2,3
    )
    where visit_date is NOT NULL
    group by 1,2
)


-- 앱실행 1회 이상 유저의 연령/성별 앱실행일수
select dating as "월",
        tb_info.성별 as "성별",
        tb_info.연령 as "연령",
        avg(visitdays) as "월평균 실행일수"
from tb_access
    right join tb_info on tb_info.UID = tb_access.user_id
group by 1,2,3
order by 1,2,3 asc
