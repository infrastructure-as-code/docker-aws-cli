FROM alpine:latest
ENV AWSCLI_VERSION "1.16.310"
RUN apk -v --no-cache --update add \
        python \
        py-pip \
        groff \
        less \
        mailcap \
        && \
    pip --no-cache-dir install --upgrade awscli==${AWSCLI_VERSION} && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*
VOLUME /root/.aws
VOLUME /project
WORKDIR /project
