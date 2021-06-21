FROM node:12.10.0-stretch

RUN mkdir -p /tmp/workspace/Docker/be
WORKDIR /tmp/workspace/Docker/be

ONBUILD ARG NODE_ENV
ONBUILD ENV NODE_ENV $NODE_ENV

COPY . /tmp/workspace/Docker/be/

RUN cd /tmp/workspace/Docker/be && npm install && npm cache clean --force
RUN pwd && npm run build && ls 
RUN cd /tmp/workspace/Docker/be && ls

CMD ["npm","start"]
