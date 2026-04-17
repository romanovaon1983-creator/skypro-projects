--Задание 1
--Отдел маркетинга проводил акцию, по которой более частый заход в игру позволял получить больше бесплатных кристаллов. Акция длилась первые три недели марта 2023 года.
--Видим ли мы позитивные результаты этой акции на графиках маркетинговых клиентских метрик?
--Постройте отдельные запросы для вычисления:
--MAU (Monthly Active Users),

select date_trunc('month', reg_date) as mm 
     , count(distinct id_user)
from skygame.users
group by mm
order by mm
---------------------------------------------------
--WAU (Weekly Active Users),

select date_trunc('week', reg_date) as week 
     , count(distinct id_user)
from skygame.users
group by week
order by week
--------------------------------------------------
--DAU (Daily Active Users).

select date_trunc('day', reg_date) as dd 
     , count(distinct id_user)
from skygame.users
group by dd
order by dd
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Задание 2
--Выгрузить топ-25 игроков, которые провели больше всего времени в игре. Учитывайте только те игровые сессии, в которых есть время завершения сессии.
--В своей выгрузке учитывайте только тех, кто был зарегистрирован в 2022 году.

select gs.id_user
      ,sum(end_session - start_session) as time_session
from   skygame.game_sessions gs
  join skygame.users us
    on gs.id_user=us.id_user
   and date_part('year', reg_date) = 2022
   and end_session is not null
group by gs.id_user
order by time_session desc
limit 25

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Задание 3
--Выведите суммарное количество подобных записей и долю подобных строк среди всех строк.

select sum(case when end_session is null then 1.0             
          else 0.0 end) as cnt_null
   ,  sum(case when end_session is null then 1.0  
          else 0.0 end)/count (*)  as part_null         
from   skygame.game_sessions gs 
  join skygame.users us 
    on gs.id_user=us.id_user 
-------------------------------------------------    
--Правда ли, что большая часть проблемных записей с незаполненным полем end_session прилетает именно с ios? 
----Да, большая часть проблемных записей с незаполненным полем end_session прилетает именно с ios
---------------------------------------------------

-- Постройте долю проблемных записей для каждого device_type.

select dev_type
     , sum(case when end_session is null then 1.0             
           else 0.0 end) as cnt_null
     ,  sum(case when end_session is null then 1.0  
           else 0.0 end)/count (*) as part_null         
from   skygame.game_sessions gs 
  join skygame.users us 
    on gs.id_user=us.id_user
group by dev_type

----------------------------------------------------
-- Какой процент проблемных записей приходится на iOS, а какой — на Android?

select sum(case when  dev_type = 'ios' then 1.0    
          else 0.0 end) as cnt_null_ios
     , sum(case when  dev_type = 'ios' then 1.0   
          else 0.0 end)/count (*) * 100 as perc_null_ios 
     , sum(case when dev_type = 'android' then 1.0  
           else 0.0 end) as cnt_null_android
     , sum(case when  dev_type = 'android' then 1.0  
           else 0.0 end)/count (*) * 100 as perc_null_android       
from   skygame.game_sessions gs 
  join skygame.users us 
    on gs.id_user=us.id_user
    and end_session is null

    