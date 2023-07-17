FROM openjdk:17
COPY ./image/server.jar ./setup/server.jar
COPY ./image-files/start.sh /startup/start.sh

ENTRYPOINT [ "/startup/start.sh" ]