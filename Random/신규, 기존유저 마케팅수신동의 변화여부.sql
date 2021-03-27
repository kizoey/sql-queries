select
    date_trunc('day', updated_at) as updated_day,
    count(distinct case when push_agreement = 'false' 
            and (datediff('day', join_date, updated_day) >= 0
            or datediff('day', join_date, updated_day) <= '{{일수 이내}}')
        then uid end) as "신규_true_to_false",
        
    count(distinct case when push_agreement = 'true' 
            and (datediff('day', join_date, updated_day) >= 0
            or datediff('day', join_date, updated_day) <= '{{일수 이내}}')
        then uid end) as "신규_false_to_true",
        
    count(distinct case when push_agreement = 'false' 
            and datediff('day', join_date, updated_day) > '{{일수 이내}}'
        then uid end) as "기존_true_to_false",
        
    count(distinct case when push_agreement = 'true' 
            and datediff('day', join_date, updated_day) > '{{일수 이내}}'
        then uid end) as "기존_false_to_true"
from
    (
    select
        uid,
        prev_push_agreement,
        push_agreement,
        updated_at,
        u.join_date
    from
        (
        select
            json_extract_path_text(message, 'user_id') as uid, 
            json_extract_path_text(message, 'push_agreement') as push_agreement, 
            convert_timezone('UTC', 'KST', server_time::timestamp) as updated_at,
            lag(push_agreement, 1) over(order by uid, updated_at asc) as prev_push_agreement,
            lag(uid, 1) over(order by uid, updated_at asc) as prev_uid,
            lag(updated_at, 1) over(order by uid, updated_at asc) as prev_updated_at
        from agreement_TB
         ) i
        join user_TB u on i.uid = u.id
    where uid = prev_uid and prev_push_agreement != push_agreement
    )
group by 1
order by 1 asc
