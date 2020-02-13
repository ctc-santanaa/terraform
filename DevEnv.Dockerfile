FROM ubuntu:18.04

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "Updating package manager and add basic commands" \
    && apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog \
    && apt-get -y install iproute2 procps lsb-release wget curl git

RUN echo "Add default locale en_*" \
    && apt-get -y install language-pack-en

RUN echo "Acquiring Menlo Certificate" \
    # Setup a directory for ssl certs to be added. The directory name matters - ubuntu tools will copy out of this location to install the certs into the environment
    && mkdir -p /usr/local/share/ca-certificates \
    # Get a copy of the menlo certificate
    && wget --no-check-certificate https://certrequest.chicagotrading.com/pkidata/menlo.cer \
    # Convert the Base-64 encoded certificate into a certificate that openssl can read directly
    && openssl x509 -inform PEM -in menlo.cer -out menlo.crt \
    # Copy the converted certificate over to the pickup directory
    && cp menlo.crt /usr/local/share/ca-certificates/ \
    # Clean up the certificate crumbs in your local directory
    && rm menlo.cer menlo.crt

RUN echo "Acquiring CTC Root Certificates" \
    # Get the 3 CTC certificate that make up the certificate chain for whitelisted sites that don't go through menlo
    && wget --no-check-certificate https://certrequest.chicagotrading.com/pkidata/CTC%20Innovations%20LLC%20-%20Issuing%20CA%201.crt -O /usr/local/share/ca-certificates/CTCInnovationsLLCIssuingCA1.crt \
    && wget --no-check-certificate https://certrequest.chicagotrading.com/pkidata/CTC%20Innovations%20LLC%20-%20Issuing%20CA%202.crt -O /usr/local/share/ca-certificates/CTCInnovationsLLCIssuingCA2.crt \
    && wget --no-check-certificate https://certrequest.chicagotrading.com/pkidata/CTC%20Innovations%20LLC%20-%20Root%20CA.crt -O /usr/local/share/ca-certificates/CTCInnovationsLLCRootCA.crt

RUN echo "Adding Menlo and CTC Root Certificates to OS trust" \
    # Get ubuntu to recognize the certificates when reaching out to internet properties
    && update-ca-certificates

RUN echo "Get Menlo HTTP Proxy Information" \
    # Get menlo proxy information so that we can tell commandline tools to use the proxy
    && `curl -s https://pac.menlosecurity.com/chicagotrading-e63f7c11c375/ssl-wpad.dat | awk '/PROXY .*; PROXY/{print "export https_proxy=http://"$3"/"}' | sed 's/;//' | head -1` \
    # Add the proxy to your bash script and to npm
    && echo "export https_proxy=$https_proxy" >> ~/.bashrc \
    && ln -s ~/.bashrc ~/.bash_profile \
    && echo "https-proxy=$https_proxy" >> ~/.npmrc

RUN echo "Disable apt secure certificate checks" \
    # If you run into issues with apt-secure, there doesn't seem to be a reasonable workaround so you will have to disable SSL (which really sucks)
    && echo 'Acquire::https::Verify-Peer "false";' > 80ssl-exceptions \
    && echo 'Acquire::https::Verify-Host "false";' >> 80ssl-exceptions \
    && cp 80ssl-exceptions /etc/apt/apt.conf.d/ \
    && rm 80ssl-exceptions

RUN echo "Create a cert chain for pip with CTC and Menlo certificates" \
    # If you run into issues with pip installing for python, fix it this way:
    && mkdir -p /usr/share/ca-certificates/extra \
    && openssl x509 -inform DES -in /usr/local/share/ca-certificates/CTCInnovationsLLCRootCA.crt -outform PEM -out /usr/share/ca-certificates/extra/CTCInnovationsLLCRootCA.pem \
    && openssl x509 -inform DES -in /usr/local/share/ca-certificates/CTCInnovationsLLCIssuingCA1.crt -outform PEM -out /usr/share/ca-certificates/extra/CTCInnovationsLLCIssuingCA1.pem \
    && openssl x509 -inform DES -in /usr/local/share/ca-certificates/CTCInnovationsLLCIssuingCA2.crt -outform PEM -out /usr/share/ca-certificates/extra/CTCInnovationsLLCIssuingCA2.pem \
    && openssl x509 -in /usr/local/share/ca-certificates/menlo.crt -outform PEM -out /usr/share/ca-certificates/extra/menlo.pem \
    && cat /usr/share/ca-certificates/extra/*.pem > ctc_chain.pem \
    && cp ctc_chain.pem /usr/share/ca-certificates/extra/ \
    && rm ctc_chain.pem \
    # If you already have pip installed:
    # pip config set global.cert /usr/share/ca-certificates/extra/ctc_chain.pem
    && mkdir ~/.pip \
    && echo "[global]" > ~/.pip/pip.conf \
    && echo "cert=/usr/share/ca-certificates/extra/ctc_chain.pem" >> ~/.pip/pip.conf

RUN echo "Getting miniconda" \
    && wget --no-check-certificate --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh

RUN echo "Installing miniconda" \
    && bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

ENV PATH /opt/conda/bin:$PATH

RUN echo "Disable ssl_verify for Conda" \
    && conda config --set ssl_verify False \
    && conda install --name base pylint --yes

COPY requirements.txt .

RUN echo "Install python packages" \
   && pip install -r requirements.txt

RUN echo "Allow docker in docker build commands to run" \
    && apt-get install -y docker.io

RUN echo "Helpful for interactive container shells" \
    && echo "set -o vi" >> ~/.bashrc \
    && echo "export EDITOR=vi" >> ~/.bashrc

RUN echo "Avoid filemode issues with devcontainers" \
    && git config --global core.filemode false

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog