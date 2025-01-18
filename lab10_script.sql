-- тест функции для оператора
select specia_is_similar('клен канадский', 'клен обыкновенный');
select specia_is_similar('береза', 'клен обыкновенный');

drop operator ~ (species, species);

-- создание оператора
create OPERATOR ~ (
	leftarg = species,
	rightarg = species,
	procedure = specia_is_similar
);

-- тест оператора
select 'клен канадский'::species ~ 'клен обыкновенный'::species as is_similar;
select 'береза'::species ~ 'клен обыкновенный'::species as is_similar;

-- финальная функция - подсчет кол-ва разных похожих пород в выборке 
select count_unique_similar(array[
	'клен канадский'::species, 
	'клен обыкновенный'::species, 
	'клен канадский'::species,
	'береза'::species,
	'гималайская береза'::species,
	'сосна'::species]);

-- аккумулирующая функция 
select unnest(species_acc(array['сосна'::species], 'гималайская береза'));

select unnest(species_acc(array['сосна'::species], NULL));

-- создание агрегатной функции
CREATE AGGREGATE unique_by_similar(species) (
    SFUNC = species_acc, -- функция, собирающая массив
    STYPE = species[], -- тип данных состояния
    FINALFUNC = count_unique_similar, -- финализируюшая функция
   	INITCOND = "{}"); -- начальный пустой массив
   	

select unique_by_similar(tree.species) from tree;

--а.	аллеи, на которых встречаются разные виды кленов (клен в названии)
-- к наследнику
select a.*,
count(t.id) as tree_count, -- кол-во деревьев
unique_by_similar(t."species") as species_count -- кол-во пород
from alley a join tree t on t.alley_id = a.id 
where lower(t."name") like '%клен%' -- в имени содержится клен
and exists(
	select t2.id from tree t2 
	where t2.alley_id = a.id 
	and t2."species" ~ t."species" 
	and t2.id != t.id) -- на аллее есть другие клены (подобные деревья)
group by a.id
having unique_by_similar(t."species") = 1; -- в выборку одной группы попали строго подобные породы



--б.	аллеи, на которых есть и статуи и фонтаны
-- к главной таблице и наследнику
SELECT a.* FROM alley a
where (
-- счет уникальных номеров таблиц для элементов на аллее
	SELECT count(distinct i.tableoid) FROM park_item i 
	left JOIN fountain f ON f.id = i.id -- фонтаны
	left join statue s on s.id = i.id -- статуи
	where i.alley_id = a.id -- на аллее
	and (f.id is not null or s.id is not null) -- нашлась либо статуя либо фонтан
) >= 2; -- как минимум два типа - нашлось и то и другое

--в.	дерево, которое было посажено позже всех
-- к наследнику
select t.* from tree t
where t.plant_date = 
	(select max(t2.plant_date) from tree t2);

--select count(t.id) as cnt from tree t
--group by t."species" limit 1;

--г.	порода, деревьев которой больше всего
-- к наследнику
--select t."species", count(t.id) as cnt from tree t
--group by t."species"
--order by cnt desc limit 1;

select t."species", count(t.id) as cnt from tree t
group by t."species"
having count(t.id) = (select count(t.id) as cnt from tree t
	group by t."species"
	order by cnt desc limit 1)
order by cnt desc;


--д.	аллея, на которой нет фонтанов
-- к главной таблице
	select a.* from alley a -- все аллеи
except
	--исключая аллеи на которых есть фонтаны
	select distinct a2.* from alley a2 
	join park_item pi2 
	on pi2.alley_id = a2.id 
	and pi2.tableoid = 'fountain'::regclass::oid
order by id;

SELECT
     json_agg(a)       
FROM alley a

SELECT
     json_agg(i), (select relname from pg_class where oid = i.tableoid) as name
FROM park_item i
group by i.id
--join park_item it on it.alley_id = a.id

SELECT
     json_agg(t)       
FROM tree t
group by alley_id 
order by alley_id

select a.*,i.*,i.tableoid from alley a 
join park_item i on i.alley_id = a.id;

-- запрос к наследнику
select * from tree;

-- запрос к родителю
select * from only park_item;

-- запрос к наследнику и родителю
select pi.*, t.* from park_item pi
join tree t on pi.id = t.id;

-- запрос к родителю, но данные всех наследников
select * from park_item;




