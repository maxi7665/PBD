--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-10-21 00:37:56

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
-- TOC entry 5 (class 2615 OID 16388)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4871 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 230 (class 1255 OID 16389)
-- Name: add_building(integer, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_building(IN p_id integer, IN building_name character varying, IN type_name character varying)
    LANGUAGE plpgsql
    AS $$

declare
  	type_id int;
	begin	
		
	
	IF not exists (select id from building_type
	where building_type."name" = type_name) 
	THEN
	    INSERT INTO building_type ("name")	    
	    VALUES(type_name)
	   	returning id into type_id;
   	ELSE   
   		select id from building_type 
		where building_type.name = type_name 
		into type_id;    	
  	END IF;
  
  	insert into building ("name", plot_id, type_id) 
  	values (building_name, p_id, type_id);	

	END;
$$;


ALTER PROCEDURE public.add_building(IN p_id integer, IN building_name character varying, IN type_name character varying) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16515)
-- Name: building_after_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.building_after_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE
   		building_count integer;
	BEGIN

		select count(*) from building b
		where b.plot_id = OLD.plot_id
		into building_count;

		if (building_count = 0) then

			RAISE INFO 'There are no buildings left on the plot № %', OLD.plot_id;

		end if;

		return OLD;

	END;
$$;


ALTER FUNCTION public.building_after_delete() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16390)
-- Name: get_plot_num(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_plot_num() RETURNS integer
    LANGUAGE plpgsql
    AS $$
	declare plot_num integer;
	BEGIN
		select count(id) from plot into plot_num;
	
		return plot_num;
	END;
$$;


ALTER FUNCTION public.get_plot_num() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16510)
-- Name: owner_after_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.owner_after_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		
		if (length(NEW.surname) < 1) then

			RAISE EXCEPTION 'The "surname" field must be filled';
		
		end if;

		if (length(NEW.first_name) < 1) then

			RAISE EXCEPTION 'The "first_name" field must be filled';
		
		end if;
		
		return NEW;

	END;
$$;


ALTER FUNCTION public.owner_after_update() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16500)
-- Name: payment_after_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.payment_after_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN

		RAISE INFO 'Payment inserted: %', current_query();

		return new;
	END;
$$;


ALTER FUNCTION public.payment_after_insert() OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16493)
-- Name: payment_before_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.payment_before_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare
   		payment_count integer;
	BEGIN

		select count(*)
		into payment_count 
		from public.payment p
			where p.sum = new.sum
				and p.date_time = new.date_time
				and p.type_id = new.type_id
				and p.owner_id = new.owner_id;

		if (payment_count > 0) then
			RAISE EXCEPTION 'duplicate payments found';	
		end if;

		return new;

	END;
$$;


ALTER FUNCTION public.payment_before_insert() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16502)
-- Name: payment_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.payment_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		if (OLD.id != NEW.id) then

		end if;
	END;
$$;


ALTER FUNCTION public.payment_before_update() OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 16513)
-- Name: plot_before_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.plot_before_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN

		delete from building
		where plot_id = OLD.id;

		delete from plot_owner_link
		where plot_id = OLD.id;
		

		return OLD;
	END;
$$;


ALTER FUNCTION public.plot_before_delete() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 16505)
-- Name: plot_before_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.plot_before_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN

		-- обновить связанные таблицы, если изменился идентификатор
		if (OLD.id != NEW.id) then
			
			ALTER TABLE building DISABLE TRIGGER ALL;

			update building
				set plot_id = NEW.id
				where plot_id = OLD.id;

			ALTER TABLE building ENABLE TRIGGER ALL;

			ALTER TABLE plot_owner_link DISABLE TRIGGER ALL;

			update plot_owner_link
				set plot_id = NEW.id
				where plot_id = OLD.id;

			ALTER TABLE plot_owner_link ENABLE TRIGGER ALL;

		end if;

		return NEW;
	END;
$$;


ALTER FUNCTION public.plot_before_update() OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 16391)
-- Name: remove_building(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.remove_building(IN building_id integer)
    LANGUAGE plpgsql
    AS $$
	declare
		removed_type_id int4;
	begin
		
		delete from building		
		where building.id = building_id
		returning type_id into removed_type_id;
	
		if not exists (
		select b.id from building b 
		where b.type_id = removed_type_id)
			then
			
			delete from building_type 
			where building_type.id = removed_type_id;
		end if;
	
	END;
$$;


ALTER PROCEDURE public.remove_building(IN building_id integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 16392)
-- Name: remove_building_type(character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.remove_building_type(IN type_name character varying)
    LANGUAGE plpgsql
    AS $$
	begin
		
		delete from building
		using building_type 
		where building.type_id = building_type.id 
		and building_type."name" = type_name;
	
		delete from building_type 
		where building_type."name" = type_name;
	
	END;
$$;


ALTER PROCEDURE public.remove_building_type(IN type_name character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16393)
-- Name: building; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.building (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    plot_id integer NOT NULL,
    type_id integer NOT NULL
);


ALTER TABLE public.building OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16396)
-- Name: building_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.building ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.building_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 219 (class 1259 OID 16397)
-- Name: building_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.building_type (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.building_type OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16400)
-- Name: building_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.building_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.building_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 16401)
-- Name: owner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.owner (
    id integer NOT NULL,
    surname character varying(100) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL
);


ALTER TABLE public.owner OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16404)
-- Name: owner_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.owner ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.owner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 16405)
-- Name: payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment (
    id integer NOT NULL,
    sum integer NOT NULL,
    date_time timestamp without time zone NOT NULL,
    type_id integer NOT NULL,
    owner_id integer NOT NULL
);


ALTER TABLE public.payment OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16408)
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.payment ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 16409)
-- Name: payment_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_type (
    id integer NOT NULL,
    purpose character varying(100) NOT NULL
);


ALTER TABLE public.payment_type OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16412)
-- Name: payment_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.payment_type ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payment_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 227 (class 1259 OID 16413)
-- Name: plot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plot (
    line integer NOT NULL,
    number integer NOT NULL,
    square real NOT NULL,
    price integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.plot OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16417)
-- Name: plot_owner_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plot_owner_link (
    plot_id integer NOT NULL,
    owner_id integer NOT NULL
);


ALTER TABLE public.plot_owner_link OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16490)
-- Name: plot_pk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plot_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plot_pk_seq OWNER TO postgres;

--
-- TOC entry 4873 (class 0 OID 0)
-- Dependencies: 229
-- Name: plot_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plot_pk_seq OWNED BY public.plot.id;


--
-- TOC entry 4681 (class 2604 OID 16491)
-- Name: plot id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot ALTER COLUMN id SET DEFAULT nextval('public.plot_pk_seq'::regclass);


--
-- TOC entry 4853 (class 0 OID 16393)
-- Dependencies: 217
-- Data for Name: building; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (6, 'Дом', 2, 1);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (7, 'Русская баня', 2, 3);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (8, 'Дом у дороги', 3, 1);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (9, 'Туалет', 3, 2);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (11, 'Баня', 5, 3);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (12, 'Дом кирпичный', 5, 1);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (1, 'Главный дом', 11, 1);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (2, 'Туалет', 11, 2);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (3, 'Финская баня', 11, 3);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (5, 'Открытая беседка', 11, 5);


--
-- TOC entry 4855 (class 0 OID 16397)
-- Dependencies: 219
-- Data for Name: building_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (1, 'Жилой дом');
INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (2, 'Туалет');
INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (3, 'Баня');
INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (4, 'Сарай');
INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (5, 'Беседка');


--
-- TOC entry 4857 (class 0 OID 16401)
-- Dependencies: 221
-- Data for Name: owner; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.owner OVERRIDING SYSTEM VALUE VALUES (1, 'Иванов', 'Дмитрий', 'Петрович');
INSERT INTO public.owner OVERRIDING SYSTEM VALUE VALUES (2, 'Петров', 'Иван', 'Дмитриевич');
INSERT INTO public.owner OVERRIDING SYSTEM VALUE VALUES (5, 'Иванов', 'Петр', 'Дмитриевич');
INSERT INTO public.owner OVERRIDING SYSTEM VALUE VALUES (4, 'Дмитриев', 'Иван', 'Алексеевич');
INSERT INTO public.owner OVERRIDING SYSTEM VALUE VALUES (6, 'Петров', 'Дмитрий', 'Петрович');
INSERT INTO public.owner OVERRIDING SYSTEM VALUE VALUES (3, 'Дмитриева', 'Анастасия', 'Ивановна');


--
-- TOC entry 4859 (class 0 OID 16405)
-- Dependencies: 223
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (1, 500000, '2023-05-16 13:00:00', 1, 1);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (4, 500000, '2023-05-16 13:00:00', 1, 4);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (5, 500000, '2023-05-16 13:00:00', 1, 6);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (2, 500000, '2023-04-16 13:00:00', 1, 2);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (3, 500000, '2023-03-16 13:00:00', 1, 3);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (6, 500000, '2023-05-16 13:00:00', 2, 6);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (11, 500001, '2023-05-16 13:00:00', 2, 6);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (12, 50000, '2023-05-16 13:00:00', 2, 6);


--
-- TOC entry 4861 (class 0 OID 16409)
-- Dependencies: 225
-- Data for Name: payment_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.payment_type OVERRIDING SYSTEM VALUE VALUES (1, 'Ежегодный взнос');
INSERT INTO public.payment_type OVERRIDING SYSTEM VALUE VALUES (2, 'ЖКХ');


--
-- TOC entry 4863 (class 0 OID 16413)
-- Dependencies: 227
-- Data for Name: plot; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (2, 2, 1500, 150000000, 2);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (1, 3, 800, 80000000, 3);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (2, 4, 1100, 110000000, 4);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (2, 5, 1120, 112000000, 5);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (2, 6, 1048, 300000000, 6);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (1, 1, 1000, 100000000, 11);


--
-- TOC entry 4864 (class 0 OID 16417)
-- Dependencies: 228
-- Data for Name: plot_owner_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.plot_owner_link VALUES (2, 2);
INSERT INTO public.plot_owner_link VALUES (3, 3);
INSERT INTO public.plot_owner_link VALUES (4, 4);
INSERT INTO public.plot_owner_link VALUES (5, 5);
INSERT INTO public.plot_owner_link VALUES (5, 6);
INSERT INTO public.plot_owner_link VALUES (11, 1);


--
-- TOC entry 4874 (class 0 OID 0)
-- Dependencies: 218
-- Name: building_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.building_id_seq', 24, true);


--
-- TOC entry 4875 (class 0 OID 0)
-- Dependencies: 220
-- Name: building_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.building_type_id_seq', 13, true);


--
-- TOC entry 4876 (class 0 OID 0)
-- Dependencies: 222
-- Name: owner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.owner_id_seq', 7, true);


--
-- TOC entry 4877 (class 0 OID 0)
-- Dependencies: 224
-- Name: payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_id_seq', 13, true);


--
-- TOC entry 4878 (class 0 OID 0)
-- Dependencies: 226
-- Name: payment_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_type_id_seq', 2, true);


--
-- TOC entry 4879 (class 0 OID 0)
-- Dependencies: 229
-- Name: plot_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plot_pk_seq', 7, true);


--
-- TOC entry 4683 (class 2606 OID 16421)
-- Name: building building_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_pk PRIMARY KEY (id);


--
-- TOC entry 4685 (class 2606 OID 16423)
-- Name: building_type building_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building_type
    ADD CONSTRAINT building_type_pk PRIMARY KEY (id);


--
-- TOC entry 4687 (class 2606 OID 16425)
-- Name: owner owner_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.owner
    ADD CONSTRAINT owner_pk PRIMARY KEY (id);


--
-- TOC entry 4689 (class 2606 OID 16427)
-- Name: payment payment_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pk PRIMARY KEY (id);


--
-- TOC entry 4691 (class 2606 OID 16429)
-- Name: payment_type payment_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_type
    ADD CONSTRAINT payment_type_pk PRIMARY KEY (id);


--
-- TOC entry 4695 (class 2606 OID 16431)
-- Name: plot_owner_link plot_owner_link_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_pk PRIMARY KEY (plot_id, owner_id);


--
-- TOC entry 4693 (class 2606 OID 16479)
-- Name: plot plot_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot
    ADD CONSTRAINT plot_pk PRIMARY KEY (id);


--
-- TOC entry 4702 (class 2620 OID 16516)
-- Name: building after_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_delete AFTER DELETE ON public.building FOR EACH ROW EXECUTE FUNCTION public.building_after_delete();


--
-- TOC entry 4704 (class 2620 OID 16517)
-- Name: payment after_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_insert AFTER INSERT ON public.payment FOR EACH ROW EXECUTE FUNCTION public.payment_after_insert();


--
-- TOC entry 4703 (class 2620 OID 16511)
-- Name: owner after_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_update AFTER UPDATE ON public.owner FOR EACH ROW EXECUTE FUNCTION public.owner_after_update();


--
-- TOC entry 4706 (class 2620 OID 16514)
-- Name: plot before_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_delete BEFORE DELETE ON public.plot FOR EACH ROW EXECUTE FUNCTION public.plot_before_delete();


--
-- TOC entry 4705 (class 2620 OID 16507)
-- Name: payment before_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert BEFORE INSERT ON public.payment FOR EACH ROW EXECUTE FUNCTION public.payment_before_insert();


--
-- TOC entry 4707 (class 2620 OID 16506)
-- Name: plot before_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_update BEFORE UPDATE ON public.plot FOR EACH ROW EXECUTE FUNCTION public.plot_before_update();


--
-- TOC entry 4696 (class 2606 OID 16434)
-- Name: building building_building_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_building_type_fk FOREIGN KEY (type_id) REFERENCES public.building_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4697 (class 2606 OID 16485)
-- Name: building building_plot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_plot_fk FOREIGN KEY (plot_id) REFERENCES public.plot(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4698 (class 2606 OID 16444)
-- Name: payment payment_owner_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_owner_fk FOREIGN KEY (owner_id) REFERENCES public.owner(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4699 (class 2606 OID 16449)
-- Name: payment payment_payment_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_type_fk FOREIGN KEY (type_id) REFERENCES public.payment_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4700 (class 2606 OID 16454)
-- Name: plot_owner_link plot_owner_link_owner_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_owner_fk FOREIGN KEY (owner_id) REFERENCES public.owner(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4701 (class 2606 OID 16480)
-- Name: plot_owner_link plot_owner_link_plot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_plot_fk FOREIGN KEY (plot_id) REFERENCES public.plot(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4872 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2024-10-21 00:37:56

--
-- PostgreSQL database dump complete
--

