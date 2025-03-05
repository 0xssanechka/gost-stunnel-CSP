FROM debian:11-slim
WORKDIR /etc/stunnel/

EXPOSE 8080/tcp

ENV PATH="/opt/cprocsp/bin/amd64:/opt/cprocsp/sbin/amd64:${PATH}"

# dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates opensc openssl procps tzdata tar gzip curl wget lsb-base socat \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# install cryptopro csp
COPY cprocsp/linux-amd64_deb.tgz /tmp/linux-amd64_deb.tgz
RUN set -x \
    && tar -xzvf /tmp/linux-amd64_deb.tgz -C /tmp \
    && /tmp/linux-amd64_deb/install.sh cprocsp-stunnel \
    && rm -rf /tmp/*

COPY conf/ /etc/stunnel/
COPY bin/entrypoint.sh /entrypoint.sh
COPY bin/stunnel-socat.sh /stunnel-socat.sh

RUN chmod +x /stunnel-socat.sh

ARG STUNNEL_CERTIFICATE_PIN_CODE="123456"
# Экспорт сертификата
RUN set -x \
    # импорт CA
    && certmgr -install -file /etc/stunnel/CA.crt -store mCA \
    # импорт сертификата с закрытым ключом
    && certmgr -install -pfx -file /etc/stunnel/certificate.pfx -pin "${STUNNEL_CERTIFICATE_PIN_CODE}" -silent \
    # определение контейнера-хранилища закрытых ключей
    && containerName=$(csptest -keys -enum -verifyc -fqcn -un | grep 'HDIMAGE' | awk -F'|' '{print $2}' | head -1) \
    # установка сертификата клиента
    && certmgr -install -cont "${containerName}" -silent \
    # экспорт сертификата для stunnel
    && certmgr -export -dest /etc/stunnel/client.crt -container "${containerName}"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["stunnel_thread", "/etc/stunnel/stunnel.conf"]
