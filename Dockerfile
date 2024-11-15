FROM alpine as builder

ARG GITHUB_TOKEN

RUN apk add --no-cache ca-certificates git tar xz bash curl make unzip tzdata && update-ca-certificates

WORKDIR /app/bin

RUN curl -s https://sh-install.vercel.app/abcfy2/aria2-static-build?as=aria2c | bash

RUN curl -s https://sh-install.vercel.app/divyam234/rclone-mod?private=1 | bash 

RUN curl -s -LO "https://www.7-zip.org/a/7z2301-linux-x64.tar.xz" && mkdir ./7zip && \
    tar -xJf ./7z2301-linux-x64.tar.xz -C ./7zip && mv ./7zip/7zzs 7z && rm -rf ./7zip ./7z2301-linux-x64.tar.xz

FROM alpine

RUN apk add --no-cache bash curl jq findutils grep

RUN adduser -D -u 1000 -h /home/user user

WORKDIR /app

RUN chown -R user:user /app

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --chown=user:user scripts/ ./scripts/

COPY --from=builder --chown=user:user /app/bin/ /usr/bin/

USER user

ENV ARIA2_CONF_DIR /app/scripts

RUN mkdir -p /app/downloads

ENV ARIA2_DOWNLOAD_DIR /app/downloads

ENV SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt

RUN chmod +x /app/scripts/**/*.sh /app/scripts/*.sh

ENTRYPOINT [ ". /scripts/start.sh" ]
