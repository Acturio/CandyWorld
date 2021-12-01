
library(DBI)
library(RPostgres)

con <- DBI::dbConnect(
    drv = RPostgres::Postgres(),
    dbname = 'test',
    host = "db",
    user = 'acturio',
    password = '4ctur10',
    port = 5432
)
