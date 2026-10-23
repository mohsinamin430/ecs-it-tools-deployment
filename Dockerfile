ARG NODE_VERSION=20-alpine@sha256:fb4cd12c85ee03686f6af5362a0b0d56d50c58a04632e6c0fb8363f609372293
ARG NGINX_VERSION=alpine3.22@sha256:5aea7cc516b419e3526f47dd1531be31a56a046cfe44754d94f9383e13e2ee99

#STAGE 1
FROM node:${NODE_VERSION} AS builder

##AS builder

#set workdir
WORKDIR /app

#install dependencies
COPY /app/package*.json /app/yarn.lock ./
RUN yarn install --frozen-lockfile

#cache dependencies
COPY /app . 

RUN yarn build


## STAGE 2
FROM nginxinc/nginx-unprivileged:${NGINX_VERSION} AS runner

COPY /app/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx --from=builder /app/build /usr/share/nginx/html

#change to non-root
USER nginx

#expose port
EXPOSE 8080

ENTRYPOINT ["nginx", "-c", "/etc/nginx/nginx.conf"]
CMD ["-g", "daemon off;"] 
