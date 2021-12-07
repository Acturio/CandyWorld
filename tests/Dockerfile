# Installar RStudio con tidyverse
FROM rocker/tidyverse:4.1

# Instala las librerías necesarias para plumber
RUN apt-get update --allow-releaseinfo-change && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev \
  libsodium-dev

# instala plumber
RUN R -e "install.packages(c('plumber', 'tidymodels'))"

# copia todo del directorio actual al contenedor
COPY / /

# Abre el puerto 80 
EXPOSE 80

# Cuando el contendeor inicia, corre el archivo main.R 
ENTRYPOINT ["Rscript", "main.R"]
