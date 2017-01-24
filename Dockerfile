FROM ubuntu:14.04

LABEL authors="Tarciso Braz (tarcisobraz@copin.ufcg.edu.br)"

# Installing git and R
RUN echo "deb http://lib.stat.cmu.edu/R/CRAN/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y --force-yes install git r-base wget unzip

# Installing required libs
RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security main restricted" >> /etc/apt/sources.list
RUN echo "deb-src http://security.ubuntu.com/ubuntu trusty-security main restricted" >> /etc/apt/sources.list
RUN apt-get -y install libssl-dev libcurl4-openssl-dev

# Cloning git repository
RUN git clone https://github.com/analytics-ufcg/gps2trip.git /home/gps2trip

# Install busminer packages with dependencies
RUN R -e 'install.packages("devtools", repos = "http://cran.rstudio.com/"); library(devtools); install_github("analytics-ufcg/busminer")'

