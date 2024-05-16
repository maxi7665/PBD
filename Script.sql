
-- запрос 1: номера участков владельцев с отчеством, заканчивающимся на «ич», но не начинающиеся на букву «А»
select distinct p.*  from plot p
join plot_owner_link link ON p.id = link.plot_id 
join "owner" o on link.owner_id = o.id 
where o.last_name like '%ич'
and o.last_name not like 'А%';

-- запрос 2: участки, на которых зарегистрировано более 1 типа постройки
select distinct p.* from plot p
join building b1 ON b1.plot_id = p.id 
join building_type btype1 on btype1.id = b1.type_id
join building b2 on b2.plot_id = p.id 
join building_type btype2 on btype2.id = b2.type_id
where b2.id != b1.id
and btype2.id != btype1.id;


-- запрос 3 Тип (типы) построек, которые отсутствуют на участках
select bt.* from building_type bt 
left join building b on b.type_id = bt.id 
where b.id is null;

-- Запрос 4 Владелец (владельцы) участка максимальной площади
select o.* from "owner" o
join plot_owner_link link ON link.owner_id = o.id 
join plot as p1 on p1.id = link.plot_id 
left join plot as p2 
on p2.square > p1.square
where p2.id is null
group by o.id;


--INSERT INTO public.building  VALUES ('test', 1, 1);