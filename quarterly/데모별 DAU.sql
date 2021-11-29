-- identification_v1, deleted, v2, deleted 가져오기 (성별, 연령대 정보)
with tb_info as(
    select user_id, "성별", birth_year as "year_birth"
    from
        (
        select user_id, "성별", birth_year, row_number() over(partition by user_id order by updated_at desc) as rnum
        from
            (
            select uid as "user_id",
                    case when gender = 0 then 'female'
                        when gender = 1 then 'male'
                        else NULL end as "성별", 
                    birth_year,
                    updated_at
            from
                (
                select uid, gender, birth_year, updated_at from identification_v1_TB union
                select uid, gender, birth_year, deleted_at from identification_v1_deleted_TB
                )
            where gender is NOT NULL
            and birth_year is NOT NULL    
            union
            select uid as "user_id",
                    case when gender = 1 then 'male' 
                        when gender = 0 or gender = 2 then 'female'
                        else NULL end as "성별", 
                    birth_year,
                    updated_at
            from
                (
                select uid, gender, birth_year, updated_at from identification_v2_TB union
                select uid, gender, birth_year, deleted_at from identification_v2_deleted_TB
                )
            where gender is NOT NULL
            and birth_year is NOT NULL
            )
        )
    where rnum = 1
)


-- 분기별, 성별, 연령대별 DAU
select
    visit_date,
    case
                when tb_info.성별 is not null then tb_info.성별
                when tb_info.성별 is null then 'NA' end as "sex_group",
            case
                when year_birth is not null and (extract(year from visit_date)+1) - tb_info.year_birth::integer < 25 then '25 under'
                when year_birth is not null and (extract(year from visit_date)+1) - tb_info.year_birth::integer between 25 and 34 then '2534'
                when year_birth is not null and (extract(year from visit_date)+1) - tb_info.year_birth::integer between 35 and 44 then '3544'
                when year_birth is not null and (extract(year from visit_date)+1) - tb_info.year_birth::integer >= 45 then '45+'
                when year_birth is null then 'NA' end as "age_group",
    count(distinct uid) as cnt
from
    (
        select
            visit_date,
            uid,
            birth_year,
            gender
        from warehouse.app_visit_user_TB
        where visit_date > '20200104'
        and visit_date < '20210401'
    ) visit
left join tb_info on tb_info.user_id = visit.uid
group by 3,2,1
order by 3,2,1 asc
