CREATE OR REPLACE FUNCTION public.specia_is_similar(first species, second species)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
	BEGIN

		if first = second then
			return true;
		end if;

		if (first in ('клен канадский', 'клен обыкновенный', 'красный клен') 
		and second in ('клен канадский', 'клен обыкновенный', 'красный клен'))
		or (first in ('береза', 'гималайская береза') 
		and second in ('береза', 'гималайская береза'))  then

			return true;
		end if;

		return false;
	END;
$function$
;


-- создание оператора
create OPERATOR ~ (
	leftarg = species,
	rightarg = species,
	procedure = specia_is_similar
);


CREATE OR REPLACE FUNCTION public.species_acc(arr species[], next species)
 RETURNS species[]
 LANGUAGE plpgsql
AS $function$
	declare 
		ret species[];
	BEGIN

		if (next != NULL) then
			ret = array_append(arr, next);
		else
			ret = arr;
		end if;

		return ret;
	END;
$function$
;


CREATE OR REPLACE FUNCTION public.count_unique_similar("values" species[])
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
	declare
		distinct_values species[];
		current_specia species;
		inner_current_specia species;

		specs RECORD;
		spec RECORD;

		similar_count int4;
		group_count int4;
		i int4;
	BEGIN

		group_count = 0;

		-- уникальные значения в массиве
		for spec in select distinct * from unnest("values") as val loop

		  	distinct_values = array_append(
				distinct_values, 
				spec.val::species);

		end loop;

		group_count = 0;

		-- удаляем поэлементно с расчетом кол-ва подобных
		while array_length(distinct_values, 1) > 0 loop

			current_specia = distinct_values[1];

			group_count = group_count + 1;

			i = 1;

		  	while i <= array_length(distinct_values, 1) loop

				inner_current_specia = distinct_values[i];

				

				-- если вид подобен текущему - удаляем
				if  inner_current_specia ~ current_specia then

					distinct_values = array_remove(distinct_values, inner_current_specia); 	

				else

					i = i + 1;
				
				end if;

			end loop;

		end loop;



		return group_count;

		 

	END;
$function$
;

-- создание агрегатной функции
CREATE AGGREGATE unique_by_similar(species) (
    SFUNC = species_acc, -- функция, собирающая массив
    STYPE = species[], -- тип данных состояния
    FINALFUNC = count_unique_similar, -- финализируюшая функция
    INITCOND = "{}"); -- начальный пустой массив
