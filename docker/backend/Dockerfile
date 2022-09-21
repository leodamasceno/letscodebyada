FROM alpine:3.13 AS download
WORKDIR /app
RUN apk update \
    && apk add --no-cache git
RUN git clone https://github.com/letscodebyada/desafio-devops.git

FROM maven:3.8-jdk-11-slim AS build
COPY --from=download /app/desafio-devops/backend/app/ /app/
RUN mvn -f /app/pom.xml clean package

FROM gcr.io/distroless/java:11 AS run
COPY --from=build /app/target/letscodebyada-0.0.1-SNAPSHOT.jar /app/
ENTRYPOINT ["java","-jar","/app/letscodebyada-0.0.1-SNAPSHOT.jar"]