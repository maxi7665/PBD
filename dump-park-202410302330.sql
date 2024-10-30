--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-10-30 23:30:40

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4843 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 859 (class 1247 OID 24577)
-- Name: species; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.species AS ENUM (
    'клен канадский',
    'клен обыкновенный',
    'красный клен',
    'береза',
    'гималайская береза',
    'сосна'
);


ALTER TYPE public.species OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 24645)
-- Name: count_unique_similar(public.species[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.count_unique_similar("values" public.species[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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

		--select distinct unnest("values") into specs;

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

				--raise info '% % % ', current_specia, inner_current_specia, array_length(distinct_values, 1);

			end loop;

			

			--raise info '% %', group_count, array_length(distinct_values, 1);

		end loop;


		--raise info '%', array_length(distinct_values, 1);

		return group_count;

		 

	END;
$$;


ALTER FUNCTION public.count_unique_similar("values" public.species[]) OWNER TO postgres;

--
-- TOC entry 224 (class 1255 OID 24639)
-- Name: specia_is_similar(public.species, public.species); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.specia_is_similar(first public.species, second public.species) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.specia_is_similar(first public.species, second public.species) OWNER TO postgres;

--
-- TOC entry 225 (class 1255 OID 24646)
-- Name: species_acc(public.species[], public.species); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.species_acc(arr public.species[], next public.species) RETURNS public.species[]
    LANGUAGE plpgsql
    AS $$
	declare 
		ret species[];
	BEGIN
		ret = array_append(arr, next);

		return ret;
	END;
$$;


ALTER FUNCTION public.species_acc(arr public.species[], next public.species) OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 24642)
-- Name: species_count_similar(public.species[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.species_count_similar("values" public.species[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	declare
		specs RECORD;
		spec RECORD;
	BEGIN

		select distinct unnest("values") into specs;

		for spec in select distinct * from unnest("values") loop
		  	raise info '%', spec;
		end loop;

		raise info '%', array_dims("values");

		return count(specs);

		 

	END;
$$;


ALTER FUNCTION public.species_count_similar("values" public.species[]) OWNER TO postgres;

--
-- TOC entry 875 (class 1255 OID 24647)
-- Name: unique_by_similar(public.species); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.unique_by_similar(public.species) (
    SFUNC = public.species_acc,
    STYPE = public.species[],
    INITCOND = '{}',
    FINALFUNC = public.count_unique_similar
);


ALTER AGGREGATE public.unique_by_similar(public.species) OWNER TO postgres;

--
-- TOC entry 1675 (class 2617 OID 24641)
-- Name: ~; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR public.~ (
    FUNCTION = public.specia_is_similar,
    LEFTARG = public.species,
    RIGHTARG = public.species
);


ALTER OPERATOR public.~ (public.species, public.species) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 24589)
-- Name: alley; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alley (
    id integer NOT NULL,
    num integer
);


ALTER TABLE public.alley OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24592)
-- Name: alley_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alley_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alley_id_seq OWNER TO postgres;

--
-- TOC entry 4845 (class 0 OID 0)
-- Dependencies: 220
-- Name: alley_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alley_id_seq OWNED BY public.alley.id;


--
-- TOC entry 218 (class 1259 OID 16520)
-- Name: park_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.park_item (
    id integer NOT NULL,
    alley_id integer,
    name character varying(45)
);


ALTER TABLE public.park_item OWNER TO postgres;

--
-- TOC entry 4846 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE park_item; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.park_item IS 'Главная таблица элементов парка';


--
-- TOC entry 4847 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN park_item.alley_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.park_item.alley_id IS 'id аллеи';


--
-- TOC entry 221 (class 1259 OID 24593)
-- Name: fountain; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fountain (
    is_swimming_allowed boolean
)
INHERITS (public.park_item);


ALTER TABLE public.fountain OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16519)
-- Name: park_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.park_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.park_item_id_seq OWNER TO postgres;

--
-- TOC entry 4848 (class 0 OID 0)
-- Dependencies: 217
-- Name: park_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.park_item_id_seq OWNED BY public.park_item.id;


--
-- TOC entry 222 (class 1259 OID 24597)
-- Name: statue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.statue (
    material character varying(40)
)
INHERITS (public.park_item);


ALTER TABLE public.statue OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24601)
-- Name: tree; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tree (
    species public.species,
    plant_date timestamp without time zone NOT NULL,
    cut_date timestamp without time zone
)
INHERITS (public.park_item);


ALTER TABLE public.tree OWNER TO postgres;

--
-- TOC entry 4668 (class 2604 OID 24605)
-- Name: alley id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alley ALTER COLUMN id SET DEFAULT nextval('public.alley_id_seq'::regclass);


--
-- TOC entry 4669 (class 2604 OID 24606)
-- Name: fountain id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fountain ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4667 (class 2604 OID 24607)
-- Name: park_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4670 (class 2604 OID 24608)
-- Name: statue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statue ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4671 (class 2604 OID 24609)
-- Name: tree id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tree ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4833 (class 0 OID 24589)
-- Dependencies: 219
-- Data for Name: alley; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.alley VALUES (1, 1);
INSERT INTO public.alley VALUES (2, 2);
INSERT INTO public.alley VALUES (3, 3);
INSERT INTO public.alley VALUES (4, 4);
INSERT INTO public.alley VALUES (5, 5);
INSERT INTO public.alley VALUES (6, 6);
INSERT INTO public.alley VALUES (7, 7);


--
-- TOC entry 4835 (class 0 OID 24593)
-- Dependencies: 221
-- Data for Name: fountain; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fountain VALUES (1, 1, false, 'Фонтан 1');
INSERT INTO public.fountain VALUES (2, 2, true, 'Фонтан 2');
INSERT INTO public.fountain VALUES (10, 6, false, 'Фонтан 3');


--
-- TOC entry 4832 (class 0 OID 16520)
-- Dependencies: 218
-- Data for Name: park_item; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4836 (class 0 OID 24597)
-- Dependencies: 222
-- Data for Name: statue; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.statue VALUES (3, 7, 'gypsum', 'Венера Милосская');
INSERT INTO public.statue VALUES (4, 6, 'bronze', 'Иосиф Сталин (отец народов)');
INSERT INTO public.statue VALUES (5, 6, 'bronze', 'Радищев');


--
-- TOC entry 4837 (class 0 OID 24601)
-- Dependencies: 223
-- Data for Name: tree; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tree VALUES (6, 3, 'клен канадский', '2024-09-28 00:00:00', '2024-10-28 00:00:00', 'Клен');
INSERT INTO public.tree VALUES (7, 4, 'клен обыкновенный', '2024-09-27 00:00:00', '2024-10-27 00:00:00', 'Клен');
INSERT INTO public.tree VALUES (8, 5, 'красный клен', '2024-09-26 00:00:00', '2024-10-26 00:00:00', 'Клен');
INSERT INTO public.tree VALUES (9, 6, 'береза', '2024-09-25 00:00:00', '2024-10-25 00:00:00', 'Береза');
INSERT INTO public.tree VALUES (11, 7, 'сосна', '2024-08-25 00:00:00', '2024-10-24 00:00:00', 'Сосна');
INSERT INTO public.tree VALUES (12, 4, 'красный клен', '2024-09-26 00:00:00', '2024-10-26 00:00:00', 'Клен');


--
-- TOC entry 4849 (class 0 OID 0)
-- Dependencies: 220
-- Name: alley_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alley_id_seq', 7, true);


--
-- TOC entry 4850 (class 0 OID 0)
-- Dependencies: 217
-- Name: park_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.park_item_id_seq', 12, true);


--
-- TOC entry 4675 (class 2606 OID 24611)
-- Name: alley alley_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alley
    ADD CONSTRAINT alley_pk PRIMARY KEY (id);


--
-- TOC entry 4677 (class 2606 OID 24633)
-- Name: fountain fountain_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fountain
    ADD CONSTRAINT fountain_unique UNIQUE (id);


--
-- TOC entry 4673 (class 2606 OID 16525)
-- Name: park_item park_item_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item
    ADD CONSTRAINT park_item_pk PRIMARY KEY (id);


--
-- TOC entry 4679 (class 2606 OID 24637)
-- Name: statue statue_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statue
    ADD CONSTRAINT statue_unique UNIQUE (id);


--
-- TOC entry 4681 (class 2606 OID 24635)
-- Name: tree tree_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tree
    ADD CONSTRAINT tree_unique UNIQUE (id);


--
-- TOC entry 4683 (class 2606 OID 24612)
-- Name: fountain fountain_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fountain
    ADD CONSTRAINT fountain_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4682 (class 2606 OID 24617)
-- Name: park_item park_item_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item
    ADD CONSTRAINT park_item_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4684 (class 2606 OID 24622)
-- Name: statue statue_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statue
    ADD CONSTRAINT statue_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4685 (class 2606 OID 24627)
-- Name: tree tree_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tree
    ADD CONSTRAINT tree_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4844 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2024-10-30 23:30:40

--
-- PostgreSQL database dump complete
--

