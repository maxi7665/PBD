--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 15.3

-- Started on 2024-10-14 22:24:43

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 241 (class 1255 OID 18070)
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
-- TOC entry 227 (class 1255 OID 18084)
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
-- TOC entry 240 (class 1255 OID 18089)
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
-- TOC entry 228 (class 1255 OID 18085)
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
-- TOC entry 217 (class 1259 OID 17964)
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
-- TOC entry 216 (class 1259 OID 17963)
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
-- TOC entry 219 (class 1259 OID 17972)
-- Name: building_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.building_type (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.building_type OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17971)
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
-- TOC entry 221 (class 1259 OID 17980)
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
-- TOC entry 220 (class 1259 OID 17979)
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
-- TOC entry 224 (class 1259 OID 17993)
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
-- TOC entry 223 (class 1259 OID 17992)
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
-- TOC entry 226 (class 1259 OID 17999)
-- Name: payment_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_type (
    id integer NOT NULL,
    purpose character varying(100) NOT NULL
);


ALTER TABLE public.payment_type OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17998)
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
-- TOC entry 215 (class 1259 OID 17958)
-- Name: plot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plot (
    id integer NOT NULL,
    line integer NOT NULL,
    number integer NOT NULL,
    square real NOT NULL,
    price integer NOT NULL
);


ALTER TABLE public.plot OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 17957)
-- Name: plot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.plot ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.plot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 17987)
-- Name: plot_owner_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plot_owner_link (
    plot_id integer NOT NULL,
    owner_id integer NOT NULL
);


ALTER TABLE public.plot_owner_link OWNER TO postgres;

--
-- TOC entry 3371 (class 0 OID 17964)
-- Dependencies: 217
-- Data for Name: building; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (1, 'Главный дом', 1, 1);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (2, 'Туалет', 1, 2);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (3, 'Финская баня', 1, 3);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (5, 'Открытая беседка', 1, 5);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (6, 'Дом', 2, 1);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (7, 'Русская баня', 2, 3);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (8, 'Дом у дороги', 3, 1);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (9, 'Туалет', 3, 2);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (10, 'Дом из бруса', 4, 1);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (11, 'Баня', 5, 3);
INSERT INTO public.building OVERRIDING SYSTEM VALUE VALUES (12, 'Дом кирпичный', 5, 1);


--
-- TOC entry 3373 (class 0 OID 17972)
-- Dependencies: 219
-- Data for Name: building_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (1, 'Жилой дом');
INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (2, 'Туалет');
INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (3, 'Баня');
INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (4, 'Сарай');
INSERT INTO public.building_type OVERRIDING SYSTEM VALUE VALUES (5, 'Беседка');


--
-- TOC entry 3375 (class 0 OID 17980)
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
-- TOC entry 3378 (class 0 OID 17993)
-- Dependencies: 224
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (1, 500000, '2023-05-16 13:00:00', 1, 1);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (4, 500000, '2023-05-16 13:00:00', 1, 4);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (5, 500000, '2023-05-16 13:00:00', 1, 6);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (2, 500000, '2023-04-16 13:00:00', 1, 2);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (3, 500000, '2023-03-16 13:00:00', 1, 3);
INSERT INTO public.payment OVERRIDING SYSTEM VALUE VALUES (6, 500000, '2023-05-16 13:00:00', 2, 6);


--
-- TOC entry 3380 (class 0 OID 17999)
-- Dependencies: 226
-- Data for Name: payment_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.payment_type OVERRIDING SYSTEM VALUE VALUES (1, 'Ежегодный взнос');
INSERT INTO public.payment_type OVERRIDING SYSTEM VALUE VALUES (2, 'ЖКХ');


--
-- TOC entry 3369 (class 0 OID 17958)
-- Dependencies: 215
-- Data for Name: plot; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (1, 1, 1, 1000, 100000000);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (2, 2, 2, 1500, 150000000);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (3, 1, 3, 800, 80000000);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (4, 2, 4, 1100, 110000000);
INSERT INTO public.plot OVERRIDING SYSTEM VALUE VALUES (5, 2, 5, 1120, 112000000);


--
-- TOC entry 3376 (class 0 OID 17987)
-- Dependencies: 222
-- Data for Name: plot_owner_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.plot_owner_link VALUES (1, 1);
INSERT INTO public.plot_owner_link VALUES (2, 2);
INSERT INTO public.plot_owner_link VALUES (3, 3);
INSERT INTO public.plot_owner_link VALUES (4, 4);
INSERT INTO public.plot_owner_link VALUES (5, 5);
INSERT INTO public.plot_owner_link VALUES (5, 6);


--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 216
-- Name: building_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.building_id_seq', 20, true);


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 218
-- Name: building_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.building_type_id_seq', 13, true);


--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 220
-- Name: owner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.owner_id_seq', 7, true);


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 223
-- Name: payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_id_seq', 6, true);


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 225
-- Name: payment_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_type_id_seq', 2, true);


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 214
-- Name: plot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plot_id_seq', 5, true);


--
-- TOC entry 3209 (class 2606 OID 17970)
-- Name: building building_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_pk PRIMARY KEY (id);


--
-- TOC entry 3211 (class 2606 OID 17978)
-- Name: building_type building_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building_type
    ADD CONSTRAINT building_type_pk PRIMARY KEY (id);


--
-- TOC entry 3213 (class 2606 OID 17986)
-- Name: owner owner_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.owner
    ADD CONSTRAINT owner_pk PRIMARY KEY (id);


--
-- TOC entry 3217 (class 2606 OID 17997)
-- Name: payment payment_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pk PRIMARY KEY (id);


--
-- TOC entry 3219 (class 2606 OID 18005)
-- Name: payment_type payment_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_type
    ADD CONSTRAINT payment_type_pk PRIMARY KEY (id);


--
-- TOC entry 3215 (class 2606 OID 17991)
-- Name: plot_owner_link plot_owner_link_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_pk PRIMARY KEY (plot_id, owner_id);


--
-- TOC entry 3207 (class 2606 OID 17962)
-- Name: plot plot_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot
    ADD CONSTRAINT plot_pk PRIMARY KEY (id);


--
-- TOC entry 3220 (class 2606 OID 18011)
-- Name: building building_building_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_building_type_fk FOREIGN KEY (type_id) REFERENCES public.building_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3221 (class 2606 OID 18006)
-- Name: building building_plot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.building
    ADD CONSTRAINT building_plot_fk FOREIGN KEY (plot_id) REFERENCES public.plot(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3224 (class 2606 OID 18031)
-- Name: payment payment_owner_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_owner_fk FOREIGN KEY (owner_id) REFERENCES public.owner(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3225 (class 2606 OID 18026)
-- Name: payment payment_payment_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_type_fk FOREIGN KEY (type_id) REFERENCES public.payment_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3222 (class 2606 OID 18021)
-- Name: plot_owner_link plot_owner_link_owner_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_owner_fk FOREIGN KEY (owner_id) REFERENCES public.owner(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3223 (class 2606 OID 18016)
-- Name: plot_owner_link plot_owner_link_plot_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plot_owner_link
    ADD CONSTRAINT plot_owner_link_plot_fk FOREIGN KEY (plot_id) REFERENCES public.plot(id) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2024-10-14 22:24:46

--
-- PostgreSQL database dump complete
--

