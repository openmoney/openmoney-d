FROM node:8

COPY . /opt/om

WORKDIR /opt/om

RUN npm install

ENTRYPOINT ["/opt/om/entrypoint.sh"]
