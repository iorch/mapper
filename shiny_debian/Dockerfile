FROM debian:latest
MAINTAINER Jorge Martínez "j.martinezortega@gmail.com"

RUN apt-get update &&\
  apt-get upgrade -y &&\
  apt-get install -y \
  aptitude \
  locales


RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN aptitude install -y \
  libgdal-dev \
  libgdal1-dev \
  libproj-dev \
  libgdal1h \
  libdap-dev \
  postgres \
  postgis \
  wget \
  gdebi-core \
  r-base \
  r-base-dev

ADD scripts /scripts

RUN . /scripts/psql.sh

RUN  R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')" &&\
  R -e "install.packages('leaflet', repos='http://cran.rstudio.com/')" &&\
  R -e "install.packages('RPostgreSQL', repos='http://cran.rstudio.com/')" &&\
  R -e "install.packages('rjson', repos='http://cran.rstudio.com/')" &&\
  wget http://cran.r-project.org/src/contrib/RJSONIO_1.3-0.tar.gz &&\
  R CMD INSTALL --configure-args="--with-local-libjson=yes" RJSONIO_1.3-0.tar.gz &&\
  R -e "install.packages('rstudioapi', repos='http://cran.rstudio.com/')" &&\
  R -e "install.packages('devtools', repos='http://cran.rstudio.com/')" &&\
  R -e "library('devtools'); devtools::install_github('ShinyDash', 'trestletech')" &&\
  R -e "install.packages('rgdal', repos='http://cran.rstudio.com/')" &&\
  R -e "install.packages('DT', repos='http://cran.rstudio.com/')" &&\
  R -e "install.packages(c('assertthat','lazyeval'), repos='http://mran.revolutionanalytics.com')" &&\
  R -e "install.packages('http://cran.r-project.org/src/contrib/Archive/dplyr/dplyr_0.4.1.tar.gz', repos=NULL)"&&\
  R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"

RUN wget --no-verbose http://ftp.us.debian.org/debian/pool/main/o/openssl/libssl0.9.8_0.9.8o-4squeeze14_amd64.deb && \
  dpkg -i libssl0.9.8_0.9.8o-4squeeze14_amd64.deb && \
  rm -f libssl0.9.8_0.9.8o-4squeeze14_amd64.deb

RUN wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.0.721-amd64.deb \
  && gdebi --n shiny-server-1.4.0.721-amd64.deb \
  && mkdir -p /srv/shiny-server \
  && cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/.

ADD tomalapp /srv/shiny-server/tomalapp

ADD start.sh /start.sh

CMD ["/start.sh"]
