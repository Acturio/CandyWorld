
library(DBI)
library(RPostgres)
library(dplyr)

con <- DBI::dbConnect(
    drv = RPostgres::Postgres(),
    dbname = 'health',
    host = "db",
    user = 'postgres',
    password = 'postgres',
    port = 5432
)

DBI::dbListTables(conn = con)

data <- tbl(con, "heart")
data_collect <- collect(data)
