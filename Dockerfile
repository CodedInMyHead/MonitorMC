FROM openjdk:17
COPY ./server-files/server.jar ./setup/server.jar
COPY ./server-files/start.sh /startup/start.sh

ENTRYPOINT [ "/startup/start.sh" ]