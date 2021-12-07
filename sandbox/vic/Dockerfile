FROM rstudio/plumber
#MAINTAINER Docker User <docker@user.org>

RUN R -e "install.packages(c('tidyverse', 'tidymodels'))"

#RUN mkdir /home/rstudio/data
#RUN mkdir /home/rstudio/models
#RUN mkdir /home/rstudio/src

# copia todo del directorio actual al contenedor
COPY data/ /
COPY *.Rds /
COPY *.R /

# Abre el puerto 8000 & 8787
EXPOSE  8000

# Cuando el contendeor inicia, corre el archivo main.R
ENTRYPOINT ["Rscript", "run.R"]

#CMD ["plumber.R"]