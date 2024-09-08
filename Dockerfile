# Start with the official RStudio image
FROM rocker/rstudio:4.4.1

# Avoid user interaction with tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libxt-dev \
    xorg-dev \
    libreadline-dev \
    libbz2-dev \
    liblzma-dev \
    zlib1g-dev \
    gfortran \
    software-properties-common \
    bash \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    pkg-config \
    libtiff5-dev \
    libjpeg-dev \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Download and install Miniconda to /opt/conda, a directory accessible by the rstudio user
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh && \
    bash Miniconda3-latest-Linux-aarch64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-aarch64.sh

# Add Conda to the PATH and initialize Conda globally for all users
ENV PATH="/opt/conda/bin:$PATH"
RUN /opt/conda/bin/conda init bash && \
    echo ". /opt/conda/etc/profile.d/conda.sh" > /etc/profile.d/conda.sh

# Install renv
RUN R -e "install.packages('renv', repos='http://cran.rstudio.com/')"

# Reset DEBIAN_FRONTEND variable
ENV DEBIAN_FRONTEND=

# Set the working directory
WORKDIR /home/rstudio/

# Expose ports for RStudio and JupyterLab
EXPOSE 8787 8888

# Set up the password for rstudio user
ENV PASSWORD=1234
RUN echo "rstudio:${PASSWORD}" | chpasswd && adduser rstudio sudo

# Start RStudio Server
CMD ["/init"]