#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : 202202020147-git
# @Author        : Jason Hempstead
# @Contact       : jason@casjaysdev.com
# @License       : WTFPL
# @ReadME        : entrypoint-mongodb.sh --help
# @Copyright     : Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @Created       : Wednesday, Feb 02, 2022 01:47 EST
# @File          : entrypoint-mongodb.sh
# @Description   :
# @TODO          :
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename "$0")"
VERSION="202202020147-git"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"
SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
if [[ "$1" == "--debug" ]]; then shift 1 && set -xo pipefail && export SCRIPT_OPTS="--debug" && export _DEBUG="on"; fi
trap 'exitCode=${exitCode:-$?};[ -n "$DOCKER_ENTRYPOINT_TEMP_FILE" ] && [ -f "$DOCKER_ENTRYPOINT_TEMP_FILE" ] && rm -Rf "$DOCKER_ENTRYPOINT_TEMP_FILE" &>/dev/null' EXIT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

export TZ="${TZ:-America/New_York}"
export HOSTNAME="${HOSTNAME:-casjaysdev-mongodb}"

cat <<EOF >/config/env.sh
ME_CONFIG_EDITORTHEME="${ME_CONFIG_EDITORTHEME:-dracula}"
ME_CONFIG_MONGODB_URL="$ME_CONFIG_MONGODB_URL:-mongodb://localhost:27017}"
ME_CONFIG_MONGODB_ENABLE_ADMIN="${ME_CONFIG_MONGODB_ENABLE_ADMIN:-true}"
ME_CONFIG_BASICAUTH_USERNAME="${ME_CONFIG_BASICAUTH_USERNAME:-}"
ME_CONFIG_BASICAUTH_PASSWORD="${ME_CONFIG_BASICAUTH_PASSWORD:-}"
ME_CONFIG_BASICAUTH_USERNAME_FILE="${ME_CONFIG_BASICAUTH_USERNAME_FILE:-}"
ME_CONFIG_BASICAUTH_PASSWORD_FILE="${ME_CONFIG_BASICAUTH_PASSWORD_FILE:-}"
ME_CONFIG_MONGODB_ADMINUSERNAME_FILE="${ME_CONFIG_MONGODB_ADMINUSERNAME_FILE:-}"
ME_CONFIG_MONGODB_ADMINPASSWORD_FILE="${ME_CONFIG_MONGODB_ADMINPASSWORD_FILE:-}"
ME_CONFIG_MONGODB_AUTH_USERNAME_FILE="${ME_CONFIG_MONGODB_AUTH_USERNAME_FILE:-}"
ME_CONFIG_MONGODB_AUTH_PASSWORD_FILE="${ME_CONFIG_MONGODB_AUTH_PASSWORD_FILE:-}"
ME_CONFIG_MONGODB_CA_FILE="${ME_CONFIG_MONGODB_CA_FILE:-}"
VCAP_APP_HOST="${VCAP_APP_HOST:-0.0.0.0}"
VCAP_APP_PORT="${VCAP_APP_PORT:-19054}"
EOF

[ -n "${TZ}" ] && echo "${TZ}" >/etc/timezone
[ -n "${HOSTNAME}" ] && echo "${HOSTNAME}" >/etc/hostname
[ -n "${HOSTNAME}" ] && echo "127.0.0.1 $HOSTNAME localhost" >/etc/hosts
[ -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
[ -f "/config/env.sh" ] && . "/config/env.sh"
[ -f "/config/mongo-express.js" ] &&
  cp -Rfv "/config/mongo-express.js" "/usr/share/mongo-express/config.js" ||
  cp -Rfv "/usr/share/mongo-express/config.default.js" "/config/mongo-express.js"

case "$1" in
healthcheck)
  if netstat -taupln | grep 'node' | grep -q '19054' && netstat -taupln | grep 'mongo' | grep -q '27017'; then
    echo "OK"
    exit 0
  else
    echo "FAIL"
    exit 10
  fi
  ;;

bash | shell | sh)
  exec /bin/bash -l
  ;;

*)
  cd /usr/share/mongo-express && node /usr/share/mongo-express/app.js &
  exec mongodb "$@"
  ;;
esac
