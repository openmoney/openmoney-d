FROM node:8

COPY ./openmoney-api /opt/om
COPY ./dockerbits/openmoney-api/entrypoint.sh /opt/om/entrypoint.sh

WORKDIR /opt/om

RUN npm install

ENTRYPOINT ["/opt/om/entrypoint.sh"]
