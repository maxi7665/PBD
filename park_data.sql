--INSERT INTO public.alley VALUES (1, 1);
--INSERT INTO public.alley VALUES (2, 2);
--INSERT INTO public.alley VALUES (3, 3);
--INSERT INTO public.alley VALUES (4, 4);
--INSERT INTO public.alley VALUES (5, 5);
--INSERT INTO public.alley VALUES (6, 6);
--INSERT INTO public.alley VALUES (7, 7);


--
-- TOC entry 4835 (class 0 OID 24593)
-- Dependencies: 221
-- Data for Name: fountain; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fountain(alley_id, is_swimming_allowed, name) VALUES (1, false, 'Фонтан 1');
INSERT INTO public.fountain(alley_id, is_swimming_allowed, name) VALUES (2, true, 'Фонтан 2');
INSERT INTO public.fountain(alley_id, is_swimming_allowed, name) VALUES (6, false, 'Фонтан 3');


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

INSERT INTO public.statue(alley_id, material, name) VALUES (7, 'gypsum', 'Венера Милосская');
INSERT INTO public.statue(alley_id, material, name) VALUES (6, 'bronze', 'Иосиф Сталин (отец народов)');
INSERT INTO public.statue(alley_id, material, name) VALUES (6, 'bronze', 'Радищев');


--
-- TOC entry 4837 (class 0 OID 24601)
-- Dependencies: 223
-- Data for Name: tree; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tree(alley_id, species, plant_date, cut_date, name) VALUES (3, 'клен канадский', '2024-09-28 00:00:00', '2024-10-28 00:00:00', 'Клен');
INSERT INTO public.tree(alley_id, species, plant_date, cut_date, name) VALUES (4, 'клен обыкновенный', '2024-09-27 00:00:00', '2024-10-27 00:00:00', 'Клен');
INSERT INTO public.tree(alley_id, species, plant_date, cut_date, name) VALUES (5, 'красный клен', '2024-09-26 00:00:00', '2024-10-26 00:00:00', 'Клен');
INSERT INTO public.tree(alley_id, species, plant_date, cut_date, name) VALUES (6, 'береза', '2024-09-25 00:00:00', '2024-10-25 00:00:00', 'Береза');
INSERT INTO public.tree(alley_id, species, plant_date, cut_date, name) VALUES (7, 'сосна', '2024-08-25 00:00:00', '2024-10-24 00:00:00', 'Сосна');
INSERT INTO public.tree(alley_id, species, plant_date, cut_date, name) VALUES (4, 'красный клен', '2024-09-26 00:00:00', '2024-10-26 00:00:00', 'Клен');


CREATE TRIGGER check_id before insert or update ON public.park_item FOR EACH ROW EXECUTE FUNCTION public.park_item_check_id();

CREATE TRIGGER check_id before insert or update ON public.fountain FOR EACH ROW EXECUTE FUNCTION public.park_item_check_id();

CREATE TRIGGER check_id before insert or update ON public.tree FOR EACH ROW EXECUTE FUNCTION public.park_item_check_id();

CREATE TRIGGER check_id before insert or update ON public.statue FOR EACH ROW EXECUTE FUNCTION public.park_item_check_id();



