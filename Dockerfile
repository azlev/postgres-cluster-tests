FROM postgres:11.8

RUN apt-get update && apt-get install -y curl
RUN curl https://dl.2ndquadrant.com/default/release/get/deb | bash
RUN apt-get install -y postgresql-11-repmgr

