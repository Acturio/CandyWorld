CREATE DATABASE health;
\connect health
CREATE TABLE IF NOT EXISTS heart (
    Age            int,      
    Sex            varchar(50),  
    ChestPainType  varchar(50),
    RestingBP      numeric,  
    Cholesterol    numeric,
    FastingBS      numeric, 
    RestingECG     varchar(50),
    MaxHR          numeric,
    ExerciseAngina varchar(50),
    Oldpeak        numeric, 
    ST_Slope       varchar(50),
    HeartDisease   varchar(50)
);
\copy heart (Age, Sex, ChestPainType, RestingBP, Cholesterol, FastingBS, RestingECG, MaxHR, ExerciseAngina, Oldpeak, ST_Slope, HeartDisease) FROM '/var/lib/postgresql/pg_data/' CSV HEADER DELIMITER ',' ;

