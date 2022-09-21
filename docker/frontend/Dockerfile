FROM alpine:3.13 AS download
WORKDIR /app
RUN apk update \
    && apk add --no-cache git
RUN git clone https://github.com/letscodebyada/desafio-devops.git

FROM node:16.10.0-stretch-slim AS run
ARG BACKEND_ENDPOINT
WORKDIR /app
COPY --from=download /app/desafio-devops/frontend/app/ /app/
RUN sed -i "s/localhost:8080/${BACKEND_ENDPOINT}/g" /app/src/environments/environment.ts
RUN npm install
RUN npm i -g @angular/cli
CMD ng serve --host 0.0.0.0 --port 4200 --disable-host-check