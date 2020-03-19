FROM python:3.6.2-stretch

RUN DEBIAN_FRONTEND=interactive \
    && apt-get -y update \
    && apt-get -y install voikko-fi python-libvoikko unzip

WORKDIR /usr/src/app

RUN cp /usr/lib/python3/dist-packages/libvoikko.py /usr/src/app/
RUN wget http://www.puimula.org/htp/testing/voikko-snapshot/dict-morpho.zip
RUN unzip dict-morpho.zip -d ~/.voikko

COPY app.py /usr/src/app/

CMD BASH
