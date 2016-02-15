FROM ubuntu

COPY dependencies.sh .
RUN ./dependencies.sh

COPY run.sh .
ENTRYPOINT ./run.sh

ENV LISTEN_PORT 21
ENV PASV_MIN_PORT 49000
ENV PASV_MAX_PORT 49010
