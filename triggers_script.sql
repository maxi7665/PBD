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
-- TOC entry 4702 (class 2620 OID 16516)
-- Name: building after_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_delete AFTER DELETE ON public.building FOR EACH ROW EXECUTE FUNCTION public.building_after_delete();


--
-- TOC entry 4704 (class 2620 OID 16508)
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
