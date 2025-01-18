--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2025-01-17 14:41:57

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
-- TOC entry 5 (class 2615 OID 16389)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4897 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 857 (class 1247 OID 16398)
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
-- TOC entry 224 (class 1255 OID 24687)
-- Name: park_item_before_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.park_item_before_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE 
		is_found boolean;
	BEGIN

		select exists(select * from park_item i 
			where i.id == NEW.id) 
			into is_found;

		if (is_found = true) then
			RAISE EXCEPTION 'duplicate ids';		
		end if;

		return new;

	

	END;
$$;


ALTER FUNCTION public.park_item_before_insert() OWNER TO postgres;

--
-- TOC entry 225 (class 1255 OID 24688)
-- Name: park_item_check_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.park_item_check_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE 
		is_found boolean;
	BEGIN

		select exists(select * from park_item i 
			where i.id = NEW.id) 
			into is_found;

		if (is_found = true) then
			RAISE EXCEPTION 'duplicate ids';		
		end if;

		return new;

	

	END;
$$;


ALTER FUNCTION public.park_item_check_id() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 16416)
-- Name: alley; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alley (
    id integer NOT NULL,
    num integer
);


ALTER TABLE public.alley OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16415)
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
-- TOC entry 4899 (class 0 OID 0)
-- Dependencies: 220
-- Name: alley_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alley_id_seq OWNED BY public.alley.id;


--
-- TOC entry 217 (class 1259 OID 16390)
-- Name: park_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.park_item (
    id integer NOT NULL,
    alley_id integer,
    name character varying
);


ALTER TABLE public.park_item OWNER TO postgres;

--
-- TOC entry 4900 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE park_item; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.park_item IS 'Главная таблица элементов парка';


--
-- TOC entry 4901 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN park_item.alley_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.park_item.alley_id IS 'id аллеи';


--
-- TOC entry 223 (class 1259 OID 16436)
-- Name: fountain; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fountain (
    is_swimming_allowed boolean
)
INHERITS (public.park_item);


ALTER TABLE public.fountain OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16393)
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
-- TOC entry 4902 (class 0 OID 0)
-- Dependencies: 218
-- Name: park_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.park_item_id_seq OWNED BY public.park_item.id;


--
-- TOC entry 222 (class 1259 OID 16432)
-- Name: statue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.statue (
    material character varying(40)
)
INHERITS (public.park_item);


ALTER TABLE public.statue OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16411)
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
-- TOC entry 4719 (class 2604 OID 16419)
-- Name: alley id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alley ALTER COLUMN id SET DEFAULT nextval('public.alley_id_seq'::regclass);


--
-- TOC entry 4721 (class 2604 OID 16439)
-- Name: fountain id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fountain ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4717 (class 2604 OID 16394)
-- Name: park_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4720 (class 2604 OID 16435)
-- Name: statue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statue ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4718 (class 2604 OID 16414)
-- Name: tree id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tree ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4889 (class 0 OID 16416)
-- Dependencies: 221
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
-- TOC entry 4891 (class 0 OID 16436)
-- Dependencies: 223
-- Data for Name: fountain; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fountain VALUES (2, 1, false, 'Фонтан 1');
INSERT INTO public.fountain VALUES (3, 2, true, 'Фонтан 2');


--
-- TOC entry 4885 (class 0 OID 16390)
-- Dependencies: 217
-- Data for Name: park_item; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4890 (class 0 OID 16432)
-- Dependencies: 222
-- Data for Name: statue; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.statue VALUES (5, 7, 'gypsum', 'Венера Милосская');
INSERT INTO public.statue VALUES (6, 6, 'bronze', 'Иосиф Сталин (отец народов)');
INSERT INTO public.statue VALUES (7, 6, 'bronze', 'Радищев');


--
-- TOC entry 4887 (class 0 OID 16411)
-- Dependencies: 219
-- Data for Name: tree; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tree VALUES (8, 3, 'клен канадский', '2024-09-28 00:00:00', '2024-10-28 00:00:00', 'Клен');
INSERT INTO public.tree VALUES (9, 4, 'клен обыкновенный', '2024-09-27 00:00:00', '2024-10-27 00:00:00', 'Клен');
INSERT INTO public.tree VALUES (10, 5, 'красный клен', '2024-09-26 00:00:00', '2024-10-26 00:00:00', 'Клен');
INSERT INTO public.tree VALUES (11, 6, 'береза', '2024-09-25 00:00:00', '2024-10-25 00:00:00', 'Береза');
INSERT INTO public.tree VALUES (12, 7, 'сосна', '2024-08-25 00:00:00', '2024-10-24 00:00:00', 'Сосна');
INSERT INTO public.tree VALUES (13, 4, 'красный клен', '2024-09-26 00:00:00', '2024-10-26 00:00:00', 'Клен');


--
-- TOC entry 4903 (class 0 OID 0)
-- Dependencies: 220
-- Name: alley_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alley_id_seq', 1, false);


--
-- TOC entry 4904 (class 0 OID 0)
-- Dependencies: 218
-- Name: park_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.park_item_id_seq', 15, true);


--
-- TOC entry 4727 (class 2606 OID 16421)
-- Name: alley alley_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alley
    ADD CONSTRAINT alley_pk PRIMARY KEY (id);


--
-- TOC entry 4731 (class 2606 OID 24694)
-- Name: fountain fountain_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fountain
    ADD CONSTRAINT fountain_unique UNIQUE (id);


--
-- TOC entry 4723 (class 2606 OID 16396)
-- Name: park_item park_item_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item
    ADD CONSTRAINT park_item_pk PRIMARY KEY (id);


--
-- TOC entry 4729 (class 2606 OID 24700)
-- Name: statue statue_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statue
    ADD CONSTRAINT statue_unique UNIQUE (id);


--
-- TOC entry 4725 (class 2606 OID 24692)
-- Name: tree tree_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tree
    ADD CONSTRAINT tree_unique UNIQUE (id);


--
-- TOC entry 4739 (class 2620 OID 24696)
-- Name: fountain check_id; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_id BEFORE INSERT OR UPDATE ON public.fountain FOR EACH ROW EXECUTE FUNCTION public.park_item_check_id();


--
-- TOC entry 4736 (class 2620 OID 24695)
-- Name: park_item check_id; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_id BEFORE INSERT OR UPDATE ON public.park_item FOR EACH ROW EXECUTE FUNCTION public.park_item_check_id();


--
-- TOC entry 4738 (class 2620 OID 24698)
-- Name: statue check_id; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_id BEFORE INSERT OR UPDATE ON public.statue FOR EACH ROW EXECUTE FUNCTION public.park_item_check_id();


--
-- TOC entry 4737 (class 2620 OID 24697)
-- Name: tree check_id; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_id BEFORE INSERT OR UPDATE ON public.tree FOR EACH ROW EXECUTE FUNCTION public.park_item_check_id();


--
-- TOC entry 4735 (class 2606 OID 16445)
-- Name: fountain fountain_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fountain
    ADD CONSTRAINT fountain_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4732 (class 2606 OID 16422)
-- Name: park_item park_item_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item
    ADD CONSTRAINT park_item_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4734 (class 2606 OID 16440)
-- Name: statue statue_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statue
    ADD CONSTRAINT statue_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4733 (class 2606 OID 16427)
-- Name: tree tree_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tree
    ADD CONSTRAINT tree_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4898 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2025-01-17 14:41:57

--
-- PostgreSQL database dump complete
--

