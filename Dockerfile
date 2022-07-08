FROM rockylinux AS source

RUN rm -Rf /et/yum.repos.d/* && \
  curl -q -LSsf https://github.com/rpm-devel/casjay-release/raw/main/casjay.rh8.repo -o /etc/yum.repos.d/casjay.repo

RUN dnf update -y && \
  dnf install -y \
  bash \
  curl && \
  yum clean all && \
  rm -Rf /etc/yum.repos.d/* 

COPY ./bin/. /usr/local/bin/
COPY ./config/. /config/
COPY ./data/. /data/

RUN  dnf module enable nodejs && \
  dnf install -y mongodb-org nodejs npm && \
  git clone https://github.com/mongo-express/mongo-express /usr/share/mongo-express && \
  cd /usr/share/mongo-express && \
  npm install


COPY ./bin/. /usr/local/bin/
COPY ./config/mongod.conf /etc/mongod.conf
COPY ./config/mongo-express.js /usr/share/mongo-express/config.js

COPY --from=source /. /

ARG BUILD_DATE="$(date +'%Y-%m-%d %H:%M')" 

LABEL \
  org.label-schema.name="mongodb" \
  org.label-schema.description="mongodb and mongo-express web interface" \
  org.label-schema.url="https://github.com/casjaysdev/mongodb" \
  org.label-schema.vcs-url="https://github.com/casjaysdev/mongodb" \
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
