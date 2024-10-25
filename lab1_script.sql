

CREATE TYPE species AS ENUM (
'клен канадский', 
'клен обыкновенный', 
'красный клен', 
'береза', 
'гималайская береза',
'сосна');


CREATE TABLE tree (
    "species" species,
    plant_date timestamp not null,
    cut_date timestamp
) INHERITS (park_item);

CREATE TABLE statue (
    material varchar(40)
) INHERITS (park_item);