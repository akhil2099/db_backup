--
-- PostgreSQL database dump
--

-- Dumped from database version 14.15
-- Dumped by pg_dump version 14.15

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cars; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.cars (
    brand character varying(255),
    model character varying(255),
    year integer
);


ALTER TABLE public.cars OWNER TO root;

--
-- Data for Name: cars; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.cars (brand, model, year) FROM stdin;
Ford	Mustang	1964
Audi	Q3	1997
Kia	Seltos	2002
\.


--
-- PostgreSQL database dump complete
--

