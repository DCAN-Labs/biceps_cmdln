FROM ubuntu:24.04

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    apt-utils \
                    autoconf \
                    build-essential \
                    bzip2 \
                    ca-certificates \
                    curl \
                    gcc \
                    git \
                    gnupg \
                    libtool \
                    lsb-release \
                    pkg-config \
                    unzip \
                    wget \
                    xvfb \
                    default-jre \
                    zlib1g \
                    libglu1-mesa \
                    libxi-dev \
                    libxmu-dev \
                    libglu1-mesa-dev \
                    pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

#Download hcp workbench software and add it to the local path
RUN mkdir /wb_code
RUN wget https://s3.msi.umn.edu/leex6144-public/workbench-linux64-v1.5.0.zip -O /wb_code/workbench-linux64-v1.5.0.zip \
    && cd /wb_code && unzip -q ./workbench-linux64-v1.5.0.zip \
    && rm /wb_code/workbench-linux64-v1.5.0.zip
ENV PATH="${PATH}:/wb_code/workbench/bin_linux64"


#Setup MCR - this grabs v912 of MCR that was downloaded from the matlab
#website, installed at MSI, and then zipped. If you want to use a
#different version of matlab then download the corresponding version
#of MCR, install it, zip it, and upload the new path to a public bucket
#on S3
RUN mkdir /mcr_path
RUN wget https://s3.msi.umn.edu/leex6144-public/v912.zip -O /mcr_path/mcr.zip \
    && cd /mcr_path && unzip -q ./mcr.zip \
    && rm /mcr_path/mcr.zip


#Download the unique code for this project
RUN mkdir /code
RUN wget https://s3.msi.umn.edu/leex6144-public/biceps_cmdln_compiled_v1_2.zip -O /code/code.zip \
    && cd /code \
    && unzip -q ./code.zip \
    && rm /code/code.zip

#Export paths (make sure LD_LIBRARY_PATH is set to the correct version)
ENV MCR_PATH=/mcr_path/v912
ENV LD_LIBRARY_PATH ="${LD_LIBRARY_PATH}:/mcr_path/v912/runtime/glnxa64:/mcr_path/v912/bin/glnxa64:/mcr_path/v912/sys/os/glnxa64:/mcr_path/v912/extern/bin/glnxa64"

#Set permissions
RUN chmod 555 -R /mcr_path /code

#Add code dir to path
ENV PATH="${PATH}:/code"

#Define entrypoint
ENTRYPOINT ["/code/run_biceps_cmdln.sh", "$MCR_PATH"]