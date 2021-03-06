FROM rocker/r-ubuntu:18.04

# Because I always forget
# docker run --rm -ti jumpingrivers/base-image /bin/bash
RUN apt-get update -qq && \
  apt-get -y upgrade && \
  apt-get -y --no-install-recommends install \
  ## Taken from rocker/verse. Some already installed
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  #libmariadbd-dev \
  #libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  libcurl4-openssl-dev \
  libmysqlclient-dev \
  ## used by some base R plots
  ghostscript \
  ## used to build rJava and other packages
  libbz2-dev libicu-dev liblzma-dev \
  ## system dependency of hunspell (devtools)
  libhunspell-dev \
  ## system dependency of hadley/pkgdown
  libmagick++-dev \
  ## for V8-based javascript wrappers
  libv8-dev \
  ## R CMD Check wants qpdf to check pdf sizes, or throws a Warning
  qpdf \
  ## For building PDF manuals
  texinfo \
  ## for git via ssh key
  ssh \
  ## just because
  less vim \
  ## parallelization
  libzmq3-dev libopenmpi-dev \
  ## spatial
  libudunits2-dev libgdal-dev \
  ## Tex
  texlive texlive-xetex texlive-generic-recommended latexmk pandoc \
  ## Fonts
  fonts-linuxlibertine fonts-roboto texlive-fonts-extra lmodern \
  # curl for tagging step
  curl git \
  # python
  python3-pip python3-venv python3-setuptools libffi-dev \
  # ffmpeg for animations in slides
  ffmpeg \
  # ssl for R packages
  libssl-dev \
  # Anacondoa stuff
  wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 \
  # Graphvis for python analytics notes
  graphviz \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Needed for gert
# Can add above due to conflicts
RUN add-apt-repository ppa:cran/libgit2 \
    && apt-get update \
    && apt-get -y --no-install-recommends install libgit2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Anaconda stuff
RUN python3 -m pip install setuptools virtualenv wheel poetry && \
    wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Update script
RUN ln -s /usr/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r

RUN Rscript -e "install.packages('Rcpp', repos = 'https://cran.rstudio.com')"
# Add RSPM option header for binary packages
# HTTPUserAgent for within R
# download.file.extra for Rscript
RUN echo "options( \
    repos = \
      c(CRAN = 'https://packagemanager.rstudio.com/all/__linux__/bionic/latest', \
        jrpublic = 'https://rstudio.jumpingrivers.cloud/package-manager/jumpingrivers/latest',\
        jrpackages = 'https://jr-packages.github.io/drat/'), \
    HTTPUserAgent = sprintf('R/%s R (%s)', getRversion(),               \
                               paste(getRversion(), R.version['platform'], \
                                     R.version['arch'], R.version['os'])), \
    download.file.extra = sprintf('--header \"User-Agent: R (%s)\"',    \
                                paste(getRversion(), R.version['platform'], \
                                      R.version['arch'], R.version['os'])))" >> /usr/lib/R/etc/Rprofile.site

