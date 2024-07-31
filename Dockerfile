FROM alpine:3.11.3

# Allow configuration before things start up.
COPY conf/entrypoint /
ENTRYPOINT ["/entrypoint"]
CMD ["postfix"]

RUN apk update; apk add --no-cache \
    bash curl grep wget unzip sed \
    mailx postfix \
    openssl \
    shadow \
    ripmime

# Install plugins.

COPY conf/.plugins/bats /tmp/bats
RUN /tmp/bats/install.sh

COPY conf/.plugins/runner /tmp/runner
RUN /tmp/runner/install.sh

# Install local tools.
COPY conf/*.sh /usr/local/bin/

# This may come in handy.
ONBUILD ARG DOCKER_USER
ONBUILD ENV DOCKER_USER=$DOCKER_USER

ENV DESTINATION=merkator-api.com

RUN	mkdir -p     /var/spool/postfix/ /var/spool/postfix/pid /var/mail; \
    chown root   /var/spool/postfix/ /var/spool/postfix/pid; \
    chmod a+rwxt /var/mail; \
    # Allow mail clients from connected Docker containers
    postconf -e mynetworks_style=subnet; \
    # Encrypt outgoing mail
    postconf -e smtp_tls_security_level=may; \
    # Disable SMTPUTF8, because libraries (ICU) are missing in alpine
    postconf -e smtputf8_enable=no; \
    # Update aliases database. It's not used, but postfix complains if the .db
    # file is missing
    postalias /etc/postfix/aliases

EXPOSE 25

# Extension template, as required by `dg component`.
COPY template /template/
# Make this an extensible base component; see
# https://github.com/merkatorgis/docker4gis/tree/npm-package/docs#extending-base-components.
COPY conf/.docker4gis /.docker4gis
COPY build.sh /.docker4gis/build.sh
COPY run.sh /.docker4gis/run.sh
ONBUILD COPY conf /tmp/conf
ONBUILD RUN touch /tmp/conf/args
ONBUILD RUN cp /tmp/conf/args /.docker4gis
