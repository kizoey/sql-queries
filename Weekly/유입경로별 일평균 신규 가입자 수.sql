select web.join_date,
       web,
       app_경로1,
       app_경로2
from
  (select date_trunc('week', join_date) as join_date,
          (sum(case
                  when id is NULL then 0
                  else 1
              end)/7) as web
   from user_TB
   where join_date >= '20190101'
     and device = 'w'
   group by 1) web
join
  (select date_trunc('week', u.join_date) as join_date,
          (sum(case
                  when media_source is NULL then 1
                  else 0
              end)/7) as app_경로1
          (sum(case
                  when media_source is NOT NULL then 1
                  else 0
              end)/7) as app_경로2
   from user_TB u
   left join
     (select media_source,
             customer_user_id,
             event_time
      from event_TB au
      where year || month || day >= '20190101'
        and event_name in ('af_complete_registration',
                           'user_signup')
        and media_source not in ('m.bunjang.co.kr') ) au 
   on u.id = au.customer_user_id
   where u.join_date >= '20190101'
     and u.device in ('a',
                      'i')
   group by 1) app ON web.join_date = app.join_date
order by 1 asc
