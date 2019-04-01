# How to build?
#
# docker build -f ./Dockerfile -t pipeline:<version> .
#
# How to run?
#
# docker run -d -p <host_port>:<container/port_in_pipeline_config> --volume <local>:/data \
#    --name pipeline pipeline:<version>
#
# If using a config section (e.g. gRPC dialin, Influx metrics) with
# user/pass, and do not yet have user/pass credentials in
# configuration file, you will need to replace -d with -ti, and pass
# '-pem <rsa>' RSA key in order to start interactively to provide
# user/pass. (This will generate new config with encryted password
# which can be used in subsequent runs to avoid interactive u/p.)
#
# Command line option --volume data is an option. Without it,
# default config which terminates TCP streams in :5432, and dumps
# to /data/dump.txt will be set up. For any real deployment, a pipeline.conf
# should be provided, so volume should be mounted. If the /data
# volume is mapped locally, the directory must contain pipeline.conf
# to use. If you do need to debug, add the following options at
# the end of run:
#
#   -debug -log=/data/pipeline.log -config=/data/pipeline.conf
#
# How to delete?
#  docker rm -v -f pipeline
#
# ----------------------------------------------------

FROM debian:stable-slim

RUN mkdir -p /data
RUN mkdir -p /starter_config

# Stage default configuration, metrics spec and example setup
COPY ./pipeline /pipeline
COPY ./pipeline.conf /starter_config/pipeline.config
COPY ./metrics.json /starter_config/metrics.json
COPY ./private.pem /starter_config/private.pem

VOLUME ["/data"]
EXPOSE 5432

WORKDIR /
ENTRYPOINT ["/pipeline"]
CMD ["-log=/data/pipeline.log","-config=/data/pipeline.conf","-pem=/conf/private.pem"]
