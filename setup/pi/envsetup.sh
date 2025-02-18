#!/bin/bash -eu

if [ "${BASH_SOURCE[0]}" = "$0" ]
then
  echo "$0 must be sourced, not executed"
  exit 1
fi

function read_setup_variables {
  if [ -z "${setup_file+x}" ]
  then
    local -r setup_file=/root/teslausb_setup_variables.conf
  fi
  if [ -e $setup_file ]
  then
    # "shellcheck" doesn't realize setup_file is effectively a constant
    # shellcheck disable=SC1090
    source $setup_file
  else
    echo "couldn't find $setup_file"
    return 1
  fi

  # TODO: change this "declare" to "local" when github updates
  # to a newer shellcheck.
  declare -A newnamefor

  newnamefor[archiveserver]=ARCHIVE_SERVER
  newnamefor[camsize]=CAM_SIZE
  newnamefor[musicsize]=MUSIC_SIZE
  newnamefor[sharename]=SHARE_NAME
  newnamefor[musicsharename]=MUSIC_SHARE_NAME
  newnamefor[shareuser]=SHARE_USER
  newnamefor[sharepassword]=SHARE_PASSWORD
  newnamefor[tesla_email]=TESLA_EMAIL
  newnamefor[tesla_password]=TESLA_PASSWORD
  newnamefor[tesla_vin]=TESLA_VIN
  newnamefor[timezone]=TIME_ZONE
  newnamefor[usb_drive]=USB_DRIVE
  newnamefor[archivedelay]=ARCHIVE_DELAY
  newnamefor[trigger_file_saved]=TRIGGER_FILE_SAVED
  newnamefor[trigger_file_sentry]=TRIGGER_FILE_SENTRY
  newnamefor[trigger_file_any]=TRIGGER_FILE_ANY
  newnamefor[pushover_enabled]=PUSHOVER_ENABLED
  newnamefor[pushover_user_key]=PUSHOVER_USER_KEY
  newnamefor[pushover_app_key]=PUSHOVER_APP_KEY
  newnamefor[gotify_enabled]=GOTIFY_ENABLED
  newnamefor[gotify_domain]=GOTIFY_DOMAIN
  newnamefor[gotify_app_token]=GOTIFY_APP_TOKEN
  newnamefor[gotify_priority]=GOTIFY_PRIORITY
  newnamefor[ifttt_enabled]=IFTTT_ENABLED
  newnamefor[ifttt_event_name]=IFTTT_EVENT_NAME
  newnamefor[ifttt_key]=IFTTT_KEY
  newnamefor[sns_enabled]=SNS_ENABLED
  newnamefor[aws_region]=AWS_REGION
  newnamefor[aws_access_key_id]=AWS_ACCESS_KEY_ID
  newnamefor[aws_secret_key]=AWS_SECRET_ACCESS_KEY
  newnamefor[aws_sns_topic_arn]=AWS_SNS_TOPIC_ARN

  local oldname
  for oldname in "${!newnamefor[@]}"
  do
    local newname=${newnamefor[$oldname]}
    if [[ -z ${!newname+x} ]] && [[ -n ${!oldname+x} ]]
    then
      local value=${!oldname}
      export $newname="$value"
      unset $oldname
    fi
  done

  # set defaults for things not set in the config
  REPO=${REPO:-MarMed}
  SNAPSHOTS_ENABLED=${SNAPSHOTS_ENABLED:-true}
  if [ "$SNAPSHOTS_ENABLED" != "true" ]
  then
    BRANCH="no-snapshots"
    if declare -F setup_progress > /dev/null
    then
      setup_progress "WARNING: using '$BRANCH' branch because SNAPSHOTS_ENABLED is not true"
    else
      echo "WARNING: using '$BRANCH' branch because SNAPSHOTS_ENABLED is not true"
    fi
  else
    BRANCH=${BRANCH:-main-dev}
  fi
  CONFIGURE_ARCHIVING=${CONFIGURE_ARCHIVING:-true}
  UPGRADE_PACKAGES=${UPGRADE_PACKAGES:-false}
  export TESLAUSB_HOSTNAME=${TESLAUSB_HOSTNAME:-arlousb}
  SAMBA_ENABLED=${SAMBA_ENABLED:-false}
  SAMBA_GUEST=${SAMBA_GUEST:-false}
  INCREASE_ROOT_SIZE=${INCREASE_ROOT_SIZE:-0}
  export CAM_SIZE=${CAM_SIZE:-90%}
  export MUSIC_SIZE=${MUSIC_SIZE:-0}
  export USB_DRIVE=${USB_DRIVE:-''}
  export USE_EXFAT=${USE_EXFAT:-false}
}

read_setup_variables

if [ -t 0 ]
then
  if ! declare -F log > /dev/null 
  then
    function log { echo "$@"; }
    export -f log
  fi
  complete -W "diagnose upgrade install" setup-teslausb
fi

function isRaspberryPi {
  grep -q "Raspberry Pi" /sys/firmware/devicetree/base/model
}

function isPi4 {
  grep -q "Raspberry Pi 4" /sys/firmware/devicetree/base/model
}
export -f isPi4

function isPi2 {
  grep -q "Raspberry Pi Zero 2" /sys/firmware/devicetree/base/model
}
export -f isPi2

function isRockPi4 {
  grep -q "ROCK Pi 4" /sys/firmware/devicetree/base/model
}
export -f isRockPi4

if isRaspberryPi
then
  STATUSLED=/sys/class/leds/led0
elif isRockPi4
then
  STATUSLED=/sys/class/leds/user-led2
else
  STATUSLED=/tmp/fakeled
fi

if [ ! -d "$STATUSLED" ]
then
  STATUSLED=/tmp/fakeled
  rm -rf "$STATUSLED"
  mkdir -p "$STATUSLED"
fi

