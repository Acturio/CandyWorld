CREATE DATABASE health;
\connect health
CREATE TABLE IF NOT EXISTS heart (
    id smallint not null, 
    title character varying(200) not null, 
    description character varying (1000) not null
);
\copy heart (id, title, description) FROM '/var/lib/postgresql/pg_data/' CSV HEADER DELIMITER ',' ;