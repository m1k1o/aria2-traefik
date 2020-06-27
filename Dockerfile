FROM alpine:3.6

ENV PUID 1000
ENV PGID 1000

# Default settings
ENV MAX_OVERALL_DOWNLOAD_LIMIT 0
ENV MAX_OVERALL_UPLOAD_LIMIT 32K
ENV MAX_CONCURRENT_DOWNLOADS 10
ENV MAX_CONNECTION_PER_SERVER 16
ENV MIN_SPLIT_SIZE 10M
ENV SPLIT 10

RUN apk add --no-cache aria2 darkhttpd s6

ADD webui /webui
ADD aria2.conf /conf/aria2.conf.tmpl
ADD start.sh /conf/start.sh

VOLUME ["/downloads"]

EXPOSE 8080

CMD ["/conf/start.sh"]
