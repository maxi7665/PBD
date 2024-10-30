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
-- к главной таблице

--в.	дерево, которое было посажено позже всех
-- к наследнику

--г.	порода, деревьев которой больше всего
-- к наследнику

--д.	аллея, на которой нет фонтанов
-- к главной таблице

