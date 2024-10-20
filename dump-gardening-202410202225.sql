--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-10-20 22:25:47

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
-- TOC entry 4862 (class 0 OID 0)
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
-- TOC entry 4864 (class 0 OID 0)
-- Dependencies: 229
-- Name: plot_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plot_pk_seq OWNED BY public.plot.id;


--
-- TOC entry 4676 (class 2604 OID 16491)
-- Name: plot id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot ALTER COLUMN id SET DEFAULT nextval('public.plot_pk_seq'::regclass);


--
-- TOC entry 4844 (class 0 OID 16393)
-- Dependencies: 217
-- Data for Name: building; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.building (id, name, plot_id, type_id) FROM stdin;
1	Главный дом	1	1
2	Туалет	1	2
3	Финская баня	1	3
5	Открытая беседка	1	5
6	Дом	2	1
7	Русская баня	2	3
8	Дом у дороги	3	1
9	Туалет	3	2
10	Дом из бруса	4	1
11	Баня	5	3
12	Дом кирпичный	5	1
\.


--
-- TOC entry 4846 (class 0 OID 16397)
-- Dependencies: 219
-- Data for Name: building_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.building_type (id, name) FROM stdin;
1	Жилой дом
2	Туалет
3	Баня
4	Сарай
5	Беседка
\.


--
-- TOC entry 4848 (class 0 OID 16401)
-- Dependencies: 221
-- Data for Name: owner; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.owner (id, surname, first_name, last_name) FROM stdin;
1	Иванов	Дмитрий	Петрович
2	Петров	Иван	Дмитриевич
5	Иванов	Петр	Дмитриевич
4	Дмитриев	Иван	Алексеевич
6	Петров	Дмитрий	Петрович
3	Дмитриева	Анастасия	Ивановна
\.


--
-- TOC entry 4850 (class 0 OID 16405)
-- Dependencies: 223
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment (id, sum, date_time, type_id, owner_id) FROM stdin;
1	500000	2023-05-16 13:00:00	1	1
4	500000	2023-05-16 13:00:00	1	4
5	500000	2023-05-16 13:00:00	1	6
2	500000	2023-04-16 13:00:00	1	2
3	500000	2023-03-16 13:00:00	1	3
6	500000	2023-05-16 13:00:00	2	6
11	500001	2023-05-16 13:00:00	2	6
12	50000	2023-05-16 13:00:00	2	6
\.


--
-- TOC entry 4852 (class 0 OID 16409)
-- Dependencies: 225
-- Data for Name: payment_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_type (id, purpose) FROM stdin;
1	Ежегодный взнос
2	ЖКХ
\.


--
-- TOC entry 4854 (class 0 OID 16413)
-- Dependencies: 227
-- Data for Name: plot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plot (line, number, square, price, id) FROM stdin;
1	1	1000	100000000	1
2	2	1500	150000000	2
1	3	800	80000000	3
2	4	1100	110000000	4
2	5	1120	112000000	5
2	6	1048	300000000	6
\.


--
-- TOC entry 4855 (class 0 OID 16417)
-- Dependencies: 228
-- Data for Name: plot_owner_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plot_owner_link (plot_id, owner_id) FROM stdin;
1	1
2	2
3	3
4	4
5	5
5	6
\.


--
-- TOC entry 4865 (class 0 OID 0)
-- Dependencies: 218
-- Name: building_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.building_id_seq', 20, true);


--
-- TOC entry 4866 (class 0 OID 0)
-- Dependencies: 220
-- Name: building_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.building_type_id_seq', 13, true);


--
-- TOC entry 4867 (class 0 OID 0)
-- Dependencies: 222
-- Name: owner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.owner_id_seq', 7, true);


--
-- TOC entry 4868 (class 0 OID 0)
-- Dependencies: 224
-- Name: payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_id_seq', 13, true);


--
-- TOC entry 4869 (class 0 OID 0)
-- Dependencies: 226
-- Name: payment_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_type_id_seq', 2, true);


--
-- TOC entry 4870 (class 0 OID 0)
-- Dependencies: 229
-- Name: plot_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plot_pk_seq', 6, true);


--
-- TOC entry 4678 (class 2606 OID 16421)
-- Name: building building_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_pk PRIMARY KEY (id);


--
-- TOC entry 4680 (class 2606 OID 16423)
-- Name: building_type building_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building_type
    ADD CONSTRAINT building_type_pk PRIMARY KEY (id);


--
-- TOC entry 4682 (class 2606 OID 16425)
-- Name: owner owner_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.owner
    ADD CONSTRAINT owner_pk PRIMARY KEY (id);


--
-- TOC entry 4684 (class 2606 OID 16427)
-- Name: payment payment_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pk PRIMARY KEY (id);


--
-- TOC entry 4686 (class 2606 OID 16429)
-- Name: payment_type payment_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_type
    ADD CONSTRAINT payment_type_pk PRIMARY KEY (id);


--
-- TOC entry 4690 (class 2606 OID 16431)
-- Name: plot_owner_link plot_owner_link_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_pk PRIMARY KEY (plot_id, owner_id);


--
-- TOC entry 4688 (class 2606 OID 16479)
-- Name: plot plot_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot
    ADD CONSTRAINT plot_pk PRIMARY KEY (id);


--
-- TOC entry 4697 (class 2620 OID 16501)
-- Name: payment after_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_insert BEFORE INSERT OR UPDATE ON public.payment FOR EACH ROW EXECUTE FUNCTION public.payment_after_insert();


--
-- TOC entry 4698 (class 2620 OID 16494)
-- Name: payment before_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert BEFORE INSERT OR UPDATE ON public.payment FOR EACH ROW EXECUTE FUNCTION public.payment_before_insert();


--
-- TOC entry 4691 (class 2606 OID 16434)
-- Name: building building_building_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_building_type_fk FOREIGN KEY (type_id) REFERENCES public.building_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4692 (class 2606 OID 16485)
-- Name: building building_plot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_plot_fk FOREIGN KEY (plot_id) REFERENCES public.plot(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4693 (class 2606 OID 16444)
-- Name: payment payment_owner_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_owner_fk FOREIGN KEY (owner_id) REFERENCES public.owner(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4694 (class 2606 OID 16449)
-- Name: payment payment_payment_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_type_fk FOREIGN KEY (type_id) REFERENCES public.payment_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4695 (class 2606 OID 16454)
-- Name: plot_owner_link plot_owner_link_owner_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_owner_fk FOREIGN KEY (owner_id) REFERENCES public.owner(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4696 (class 2606 OID 16480)
-- Name: plot_owner_link plot_owner_link_plot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_plot_fk FOREIGN KEY (plot_id) REFERENCES public.plot(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4863 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2024-10-20 22:25:47

--
-- PostgreSQL database dump complete
--

