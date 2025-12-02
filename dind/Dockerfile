FROM alpine:latest
RUN apk update && apk add --no-cache iputils
CMD ["ping", "-c", "10", "8.8.8.8"]