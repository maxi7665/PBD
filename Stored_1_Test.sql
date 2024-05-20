-- Хранимые процедуры

--begin;

-- 1. Добавление нового элемента с обновлением справочника
call add_building(1, 'Открытая беседка', 'Беседка');
call add_building(1, 'Закрытая беседка', 'Беседка 1');

select * from building b where b.plot_id = 1;
select * from building_type bt ;

-- 2. Функция 
select get_plot_num();

-- 3. Процедура для каскадного удаления
call remove_building_type('Беседка 1');

-- 4. Процедура удаления с очисткой справочника

call remove_building();

--rollback;