set time zone 'Asia/Seoul';

-- 성별, 연령대별 유저ID 추출
with tb_info as
(
    select uid as "UID"
    from app_visit_user_TB
    where case
            when'%{{성별}}%' = '%남성%' then gender = 'male'
            when '%{{성별}}%' = '%여성%' then gender = 'female'
            when '%{{성별}}%' = '%무관%' then (gender = 'male' or gender = 'female') end
        and 2021 - birth_year::integer between '{{최소나이}}' and '{{최대나이}}'
        and visit_date >= '{{ 앱실행기간.start }}'
        and visit_date <= '{{ 앱실행기간.end }}'
)


-- 시별 활동 트렌드
    select year||'-'||month||'-'||day as "날짜", 
        case extract(dow from to_date(year||month||day, 'YYYYMMDD'))
        when 0 then '일요일'
        when 1 then '월요일'
        when 2 then '화요일'
        when 3 then '수요일'
        when 4 then '목요일'
        when 5 then '금요일'
        when 6 then '토요일'
    end as "요일",
        hour as "시간대" ,
        count(tb_info.UID)/count(distinct tb_info.UID)::decimal as "평균앱실행수"
    from launch_TB launch
        join tb_info on launch.user_id = tb_info.UID
    where year||'-'||month||'-'||day >= '{{ 앱실행기간.start }}'
        and year||'-'||month||'-'||day <= '{{ 앱실행기간.end }}'
    group by 1,2,3)
    group by 1,2,3
    order by 1,2,3 asc
