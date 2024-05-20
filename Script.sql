
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

-- reversed
select bt.* from building b   
right join building_type bt on b.type_id = bt.id
where b.id is null;

-- Запрос 4 Владелец (владельцы) участка максимальной площади
-- all
select distinct  o.* from "owner" o
join plot_owner_link link ON link.owner_id = o.id 
join plot as p1 on p1.id = link.plot_id 
where p1.square >= all 
(select p2.square from plot p2);

-- max
select distinct  o.* from "owner" o
join plot_owner_link link ON link.owner_id = o.id 
join plot as p1 on p1.id = link.plot_id 
where p1.square =  
(select max(p2.square) from plot p2);

-- Владельцы участков c числом типов построек больше среднего
-- подсчитывать уник типа построек
-- правильный подсчет среднего
select distinct o.* from "owner" o
join plot_owner_link link ON link.owner_id = o.id 
join plot as p1 on p1.id  = link.plot_id 
join building b on b.plot_id  = p1.id 
group by o.id, p1.id
having count(distinct b.type_id) > (
select avg(cnt) from (
select count(distinct b.type_id) as cnt from plot p1
left join building b on b.plot_id = p1.id 
group by p1.id) q);


select p1.*,count(o.id),count(distinct o.id) from "owner" o
join plot_owner_link link ON link.owner_id = o.id 
join plot as p1 on p1.id  = link.plot_id 
join building b on b.plot_id  = p1.id 
group by p1.id


select avg(cnt) from (select count(bt.*) as cnt from "owner" o
join plot_owner_link link ON link.owner_id = o.id 
join plot as p1 on p1.id  = link.plot_id 
join building b on b.plot_id  = p1.id 
join building_type bt on bt.id = b.type_id 
group by o.id) q

-- Владельцы, оплатившие в 2023 году , все типы взносов
-- 2023 год
-- not exists
select o.* from "owner" o
where not exists (
	select * from payment_type pt 
	where not exists(
		select * from payment p 
		where p.owner_id = o.id
		and p.type_id = pt.id
		and date_part('year', p.date_time)=2023))

-- агр функция	
select o.*, count(distinct p.type_id) from "owner" o
	join payment p 
		on p.owner_id = o.id
		where date_part('year', p.date_time)=2023
		group by o.id 
		having count(distinct p.type_id) = 
		(select count(pt.id) from payment_type pt);
		
	
		
-- Участки, на которых нет беседок, но есть туалеты или бани
		
-- not in вариант
select p.* from plot p
join building b 
on b.plot_id = p.id 
join building_type bt 
on bt.id = b.type_id 
where bt."name" in ('Туалет', 'Баня')
and p.id not in (
	select p.id from plot p
	join building b 
	on b.plot_id = p.id 
	join building_type bt 
	on bt.id = b.type_id 
	where bt."name" in ('Беседка'));

-- except вариант
select p.* from plot p
join building b 
on b.plot_id = p.id 
join building_type bt 
on bt.id = b.type_id 
where bt."name" in ('Туалет', 'Баня')
except  
	select p.* from plot p
	join building b 
	on b.plot_id = p.id 
	join building_type bt 
	on bt.id = b.type_id 
	where bt."name" in ('Беседка');

-- left join вариант
select p1.* from plot p1
join building b1 
on b1.plot_id = p1.id 
join building_type bt1 
on bt1.id = b1.type_id  

left join (select p2.* from plot p2
join building b2 
on b2.plot_id = p2.id 
join building_type bt2
on bt2.id = b2.type_id  
and bt2."name" = 'Беседка') q 
on q.id = p1.id

where bt1."name" in ('Туалет', 'Баня')
and q.id is null;



--INSERT INTO public.building  VALUES ('test', 1, 1);



