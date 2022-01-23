# build stage
FROM peaceiris/hugo:v0.92.0-mod as builder
COPY . /src
WORKDIR /src
RUN HUGO_ENV=production hugo -v -s .
# RUN hugo
RUN pwd
RUN ls


# production stage
FROM nginx:1.19-alpine as prod
COPY --from=builder /src/nginx.conf /etc/nginx/conf.d
COPY --from=builder /src/public /usr/share/nginx/html

