FROM ubuntu:20.04

ARG BUILD_DATE

ENV NODE_PORT	9633

ENV GUAPCOIN_VERSION					2.3.2
ENV GUAPCOIN_DOWNLOAD_URL				https://github.com/guapcrypto/Guap-v$GUAPCOIN_VERSION-MN/releases/download/v$GUAPCOIN_VERSION/Guapcoin-$GUAPCOIN_VERSION-Ubuntu20.04-daemon.tar.gz
ENV GUAPCOIN_BOOTSTRAP_DOWNLOAD_URL		https://github.com/guapcrypto/Guap-v$GUAPCOIN_VERSION-MN/releases/download/v$GUAPCOIN_VERSION/bootstrap.zip

# basic build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.name="Guapcoin" \
    org.label-schema.vendor="GUAP Foundation" \
    org.label-schema.version=$GUAPCOIN_VERSION \
    org.label-schema.description="Guapcoin for docker" \
    org.label-schema.url="https://guapcoin.org/"
	
# create guapcoin group and system user (because of -r)
RUN groupadd -r guapcoin && useradd --no-log-init -r -m -g guapcoin guapcoin

# update and add system packages
RUN set -eux; \
	apt-get update; \
	apt-get install --yes --no-install-recommends \
		ca-certificates \
		curl \
		dnsutils \
		unzip; \
    rm -rf /var/lib/apt/lists/*;
	
# wallet and daemon
RUN set -eux; \
	curl -SLO "$GUAPCOIN_DOWNLOAD_URL"; \
	tar -xzvf Guapcoin-$GUAPCOIN_VERSION-Ubuntu20.04-daemon.tar.gz -C /usr/local/bin; \
	rm Guapcoin-$GUAPCOIN_VERSION-Ubuntu20.04-daemon.tar.gz; \
	chmod a+x \
		/usr/local/bin/guapcoin-cli \
		/usr/local/bin/guapcoind \
		/usr/local/bin/guapcoin-tx; \
	\
# smoke test
	guapcoind -version | grep "Guapcoin Daemon version v${GUAPCOIN_VERSION}.0"; \
	guapcoin-cli -version | grep "Guapcoin RPC client version v${GUAPCOIN_VERSION}.0"
		
WORKDIR /home/guapcoin

# use our guapcoin user
USER guapcoin
	
# copy files
COPY entrypoint.sh /usr/local/bin/
COPY start-unprivileged.sh /usr/local/bin/

# entrypoint
ENTRYPOINT ["entrypoint.sh"]

# expose the masternode port
EXPOSE ${NODE_PORT}

# healthcheck
# guapcoin-cli getmasternodestatus returns exit status code 1 when unhealthy
#HEALTHCHECK --interval=1m --timeout=5s --retries=3 CMD guapcoin-cli getmasternodestatus || exit 1
#HEALTHCHECK --interval=1m --timeout=5s --retries=3 CMD guapcoin-cli getstakingstatus | grep staking_status | grep true || exit 1

# default parameter
CMD ["start-unprivileged.sh"]