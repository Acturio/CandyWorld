!#/usr/bin/bash

#Tenemos que estar posicionados en la carpeta src (data_1/heart.csv tiene que estar tmb en src)
cd src

#Instalación de docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

#Carga imagen de postgres
docker pull postgres:13.3

#Carga de imagen de R
docker pull rocker/tidyverse:4.1

#Docker compose
#nano docker-compose.yml
docker-compose up --build

#VIDEO
#Entramos a Postgres
docker exec -it src_db_1 psql -U postgres

#Creo una DB llamada datos
CREATE DATABASE datos;

#Cramos tabla
CREATE TABLE heart (id smallint not null, title character varying(200) not null, description character varying (1000) not null)

#Con esto vemos los esquemas o tablas
 \d

#Hacemos el copy del csv
\copy heart (id, title, description) FROM '/var/lib/postgresql/data_1/' CSV HEADER DELIMITER ',';


#Insertamos un nuevo registro
INSERT INTO heart (id, title, description) VALUES (1, 'Postgres', 'haciendo pruebas');
#Revisamos el nuevo registro creado
SELECT * FROM heart;

#Para salir de postgres
\q

#Para conectarte a la base se datos
\c




#curl -o prueba.zip https://www.inegi.org.mx/contenidos/masiva/denue/denue_00_23_csv.zip


