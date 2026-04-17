--Задание 1
 --Факт: В ноябре и декабре 2022 года была опробована альтернативная стратегия привлечения клиентов.
 --Проверьте следующую гипотезу: в ноябре и декабре 2022 года из-за более дорогой и таргетированной 
   рекламы мы приобрели более “лояльных” игроков, которые больше времени посвящают нашей игре.

select case when date_trunc('month', reg_date) in ('2022-11-01','2022-12-01') 
            then 'nov_dec_2022_cohort' else 'another_cohort' end as cohort 
       , sum(round(extract(epoch from end_session - start_session)/60))/count(*) as avg_len_min 
from skygame.game_sessions s 
   join skygame.users u 
     on u.id_user = s.id_user
where end_session - start_session > interval '5 minute'
group by cohort

----------------------------------------------------------------------------

--Задание 2
 -- Рассчитайте, сколько пользователей нам принесет одна будущая среднестатистическая когорта в результате
 
-- K-factor
select count(r.id_user)/count(distinct u.id_user) as avg_ref 
       , sum(ref_reg)/count(ref_reg)*100 as part_ref_reg
       , count(r.id_user)/count(distinct u.id_user)*sum(ref_reg)/count(ref_reg) as k_faktor
from  skygame.users u 
   full  join skygame.referral r 
     on u.id_user = r.id_user


--средний объем для каждой когорты
select date_trunc('month', reg_date) as cohort
      , count(distinct id_user) as cnt_user 
from skygame.users u
group by cohort
order by cohort


--прогноз объема новых регистраций
with k_faktor as 
( select count(r.id_user)*1.0/count(distinct u.id_user)*sum(ref_reg)*1.0/count(ref_reg) as k_faktor
  from skygame.users u 
     left join skygame.referral r 
       on u.id_user = r.id_user
),
cohort as 
( select avg(cnt_user) as avg_user 
  from(select date_trunc('month', reg_date) as cohort
            , count(distinct id_user) as cnt_user 
       from skygame.users u
       group by cohort
       order by cohort) avg_user
)

select (select* from k_faktor) * (select* from cohort )as new_cohort 