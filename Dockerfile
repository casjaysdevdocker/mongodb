FROM rockylinux AS source

ARG NODE_VERSION="16"

RUN cat <<EOF >/etc/yum.repos.d/mongodb-org-5.0.repo
[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/5.0/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc

EOF

RUN dnf module enable nodejs:$NODE_VERSION -y && \
  curl -q -LSsf https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo && \
  rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg && \
  dnf update -y && \
  dnf install -y \
  bash \
  curl \
  wget \
  mongodb-org \
  nodejs \
  npm \
  sudo \
  yarn \
  git && \
  git clone https://github.com/mongo-express/mongo-express /usr/share/mongo-express && \
  cd /usr/share/mongo-express && npm install

RUN yum clean all && \
  rm -Rf /etc/yum.repos.d/*

COPY ./bin/. /usr/local/bin/
COPY ./config/mongod.conf /etc/mongod.conf
COPY ./config/mongo-express.js /usr/share/mongo-express/config.js

FROM scratch
COPY --from=source /. /

ARG BUILD_DATE="$(date +'%Y-%m-%d %H:%M')" 

LABEL \
  org.label-schema.name="mongodb" \
  org.label-schema.description="mongodb and mongo-express web interface" \
  org.label-schema.url="https://github.com/casjaysdev/mongodb" \
  org.label-schema.vcs-url="https://github.com/dockerize-it/mongodb" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.version=$BUILD_DATE \
  org.label-schema.vcs-ref=$BUILD_DATE \
  org.label-schema.license="MIT" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="CasjaysDev" \
  maintainer="CasjaysDev <docker-admin@casjaysdev.com>" 

ENV ME_CONFIG_EDITORTHEME="dracula" \
  ME_CONFIG_MONGODB_URL="mongodb://localhost:27017" \
  ME_CONFIG_MONGODB_ENABLE_ADMIN="true" \
  VCAP_APP_HOST="0.0.0.0"

EXPOSE 27017 19054

HEALTHCHECK CMD [ "/usr/local/bin/entrypoint-mongodb.sh","healthcheck" ]
ENTRYPOINT [ "/usr/local/bin/entrypoint-mongodb.sh"" ]
CMD [ "/bin/bash", "-l" ]
