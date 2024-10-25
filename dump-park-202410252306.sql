--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-10-25 23:06:18

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
-- TOC entry 4885 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 855 (class 1247 OID 16398)
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
-- TOC entry 4887 (class 0 OID 0)
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
    alley_id integer
);


ALTER TABLE public.park_item OWNER TO postgres;

--
-- TOC entry 4888 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE park_item; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.park_item IS 'Главная таблица элементов парка';


--
-- TOC entry 4889 (class 0 OID 0)
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
-- TOC entry 4890 (class 0 OID 0)
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
-- TOC entry 4717 (class 2604 OID 16419)
-- Name: alley id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alley ALTER COLUMN id SET DEFAULT nextval('public.alley_id_seq'::regclass);


--
-- TOC entry 4719 (class 2604 OID 16439)
-- Name: fountain id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fountain ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4715 (class 2604 OID 16394)
-- Name: park_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4718 (class 2604 OID 16435)
-- Name: statue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statue ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4716 (class 2604 OID 16414)
-- Name: tree id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tree ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4877 (class 0 OID 16416)
-- Dependencies: 221
-- Data for Name: alley; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4879 (class 0 OID 16436)
-- Dependencies: 223
-- Data for Name: fountain; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4873 (class 0 OID 16390)
-- Dependencies: 217
-- Data for Name: park_item; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4878 (class 0 OID 16432)
-- Dependencies: 222
-- Data for Name: statue; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4875 (class 0 OID 16411)
-- Dependencies: 219
-- Data for Name: tree; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4891 (class 0 OID 0)
-- Dependencies: 220
-- Name: alley_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alley_id_seq', 1, false);


--
-- TOC entry 4892 (class 0 OID 0)
-- Dependencies: 218
-- Name: park_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.park_item_id_seq', 1, false);


--
-- TOC entry 4723 (class 2606 OID 16421)
-- Name: alley alley_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alley
    ADD CONSTRAINT alley_pk PRIMARY KEY (id);


--
-- TOC entry 4721 (class 2606 OID 16396)
-- Name: park_item park_item_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item
    ADD CONSTRAINT park_item_pk PRIMARY KEY (id);


--
-- TOC entry 4727 (class 2606 OID 16445)
-- Name: fountain fountain_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fountain
    ADD CONSTRAINT fountain_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4724 (class 2606 OID 16422)
-- Name: park_item park_item_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item
    ADD CONSTRAINT park_item_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4726 (class 2606 OID 16440)
-- Name: statue statue_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statue
    ADD CONSTRAINT statue_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4725 (class 2606 OID 16427)
-- Name: tree tree_alley_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tree
    ADD CONSTRAINT tree_alley_fk FOREIGN KEY (alley_id) REFERENCES public.alley(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 4886 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2024-10-25 23:06:18

--
-- PostgreSQL database dump complete
--

