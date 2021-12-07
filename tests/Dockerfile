# Installar RStudio con tidyverse
FROM rocker/tidyverse:4.1

# Instala las librerías necesarias para plumber
RUN apt-get update --allow-releaseinfo-change && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev \
  libsodium-dev

# instala plumber
RUN R -e "install.packages(c('plumber', 'tidymodels'))"

RUN mkdir /home/rstudio/data
RUN mkdir /home/rstudio/models
RUN mkdir /home/rstudio/src

# copia todo del directorio actual al contenedor
COPY data/ /home/rstudio/
COPY *.Rds /home/rstudio/models/
COPY *.R /home/rstudio/src/

# Abre el puerto 8000 & 8787
EXPOSE 8787 8000

# Cuando el contendeor inicia, corre el archivo main.R
ENTRYPOINT ["Rscript", "/home/rstudio/src/run.R"]
