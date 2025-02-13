FROM alpine as builder

ARG GITHUB_TOKEN

RUN apk add --no-cache ca-certificates git tar xz bash curl make unzip tzdata && update-ca-certificates

WORKDIR /app/bin

RUN curl -s "https://instl.vercel.app/abcfy2/aria2-static-build?move=0" | bash

RUN curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "https://instl.vercel.app/divyam234/rclone-mod?move=0" | bash 

RUN curl -s "https://instl.vercel.app/divyam234/static-builds?include=7z&move=0" | bash

FROM alpine

RUN apk add --no-cache bash curl jq findutils grep

RUN adduser -D -u 1000 -h /home/user user

WORKDIR /app

RUN chown -R user:user /app

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --chown=user:user scripts/ ./scripts/

COPY --from=builder --chown=user:user /app/bin/ /usr/bin/

RUN mv /usr/bin/7zzs /usr/bin/7z

USER user

WORKDIR /app

ENV ARIA2_CONF_DIR /app/scripts

RUN mkdir -p /app/downloads

ENV ARIA2_DOWNLOAD_DIR /app/downloads

ENV SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt

RUN chmod +x ./scripts/*.sh
