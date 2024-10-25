--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-10-25 21:32:37

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4796 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 16520)
-- Name: park_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.park_item (
    id integer NOT NULL,
    alley_id integer
);


ALTER TABLE public.park_item OWNER TO postgres;

--
-- TOC entry 4797 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE park_item; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.park_item IS 'Главная таблица элементов парка';


--
-- TOC entry 4798 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN park_item.alley_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.park_item.alley_id IS 'id аллеи';


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
-- TOC entry 4799 (class 0 OID 0)
-- Dependencies: 217
-- Name: park_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.park_item_id_seq OWNED BY public.park_item.id;


--
-- TOC entry 4641 (class 2604 OID 16523)
-- Name: park_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item ALTER COLUMN id SET DEFAULT nextval('public.park_item_id_seq'::regclass);


--
-- TOC entry 4790 (class 0 OID 16520)
-- Dependencies: 218
-- Data for Name: park_item; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4800 (class 0 OID 0)
-- Dependencies: 217
-- Name: park_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.park_item_id_seq', 1, false);


--
-- TOC entry 4643 (class 2606 OID 16525)
-- Name: park_item park_item_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.park_item
    ADD CONSTRAINT park_item_pk PRIMARY KEY (id);


-- Completed on 2024-10-25 21:32:37

--
-- PostgreSQL database dump complete
--

