FROM ubuntu:18.04
LABEL maintainer="Rennan Marujo <rennanmarujo@gmail.com>"

USER root

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        'curl' \
        'gdal-bin' \
        'python-dev' \
        'python-gdal' \
        'python-pip' \
        'libxmu6' \
        'openjdk-11-jdk' \
        'unzip' \
        'wget' \
        'xserver-xorg' && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Set the working directory to /app
WORKDIR /app

# Install Sen2cor Version 2.8.0
RUN wget http://step.esa.int/thirdparties/sen2cor/2.8.0/Sen2Cor-02.08.00-Linux64.run && \
    chmod +x Sen2Cor-02.08.00-Linux64.run && \
    bash /app/Sen2Cor-02.08.00-Linux64.run --target /home && \
    rm /app/Sen2Cor-02.08.00-Linux64.run

ENV PATH $PATH:/home/bin/

# Setting environment variables
ENV PYTHONUNBUFFERED 1

#Set sen2cor params
COPY sen2cor_2.8.0/2.8/cfg/L2A_GIPP.xml /root/sen2cor/2.8/cfg/L2A_GIPP.xml

# cloud masking FMASK 4
COPY Fmask_4_2_Linux.install .
RUN chmod +x Fmask_4_2_Linux.install && \
    ./Fmask_4_2_Linux.install -mode silent -agreeToLicense yes && \
    rm Fmask_4_2_Linux.install

ENV MCR_CACHE_ROOT="/tmp/mcr-cache"

WORKDIR /work

COPY run_sen2cor_fmask.sh /usr/local/bin/run_sen2cor_fmask.sh
RUN chmod +x /usr/local/bin/run_sen2cor_fmask.sh

ENTRYPOINT ["/usr/local/bin/run_sen2cor_fmask.sh"]
CMD ["--help"]
