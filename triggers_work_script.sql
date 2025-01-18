ALTER TABLE public.plot ADD id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL;

update plot set id_2  = id;

ALTER TABLE plot
ALTER COLUMN id TYPE int;

ALTER TABLE public.plot ALTER CONSTRAINT plot_pk PRIMARY KEY (id);

CREATE SEQUENCE plot_pk_seq OWNED BY plot.id;
SELECT setval('plot_pk_seq', coalesce(max(id), 0) + 1, false) FROM plot;
ALTER TABLE plot ALTER COLUMN id SET DEFAULT nextval('plot_pk_seq');


-- новый ключ в таблице построек
update plot set id_2  = id;

ALTER TABLE plot
ALTER COLUMN id TYPE int;

ALTER TABLE public.plot ALTER CONSTRAINT plot_pk PRIMARY KEY (id);

CREATE SEQUENCE plot_pk_seq OWNED BY plot.id;
SELECT setval('plot_pk_seq', coalesce(max(id), 0) + 1, false) FROM plot;
ALTER TABLE plot ALTER COLUMN id SET DEFAULT nextval('plot_pk_seq');



CREATE TRIGGER after_update AFTER UPDATE ON "owner"
    FOR EACH ROW EXECUTE PROCEDURE owner_after_update();
   
CREATE TRIGGER before_delete BEFORE DELETE ON plot
    FOR EACH ROW EXECUTE PROCEDURE plot_before_delete();
   
   
CREATE TRIGGER after_delete AFTER DELETE ON building
    FOR EACH ROW EXECUTE PROCEDURE building_after_delete();

select exists(select * from building b
		where b.plot_id = 11)
		into building_count;

select *  from building_count;
    
   
-- ТРИГГЕРЫ 1,2
insert into payment(sum, date_time, type_id, owner_id) values (50000, '2023-05-17 13:00:00.000', 2, 6);



-- триггер 3

update plot set id = 11 where id = 1;


-- триггер 5

delete from plot where id = 7;

-- триггер 6

delete from building where id = 28;


-- триггер 7
update owner set "first_name"='Настя' where id=3;








