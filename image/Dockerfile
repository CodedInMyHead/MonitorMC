FROM openjdk:17
COPY ./server.jar ./setup/server.jar
COPY ./start.sh /startup/start.sh

ENTRYPOINT [ "/startup/start.sh" ]