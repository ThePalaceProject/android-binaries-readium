#!/bin/sh

fatal()
{
  echo "fatal: $1" 1>&2
  echo
  echo "dumping log: " 1>&2
  echo
  cat .travis/pre.txt
  exit 1
}

info()
{
  echo "info: $1" 1>&2
}

mkdir -p .travis || fatal "could not create .travis"

WORKING_DIRECTORY=$(pwd) || fatal "could not save working directory"

info "dumping environment"
export ANDROID_SDK_ROOT="${ANDROID_HOME}"
env | sort -u

#------------------------------------------------------------------------
# Download avdmanager

info "downloading avdmanager"

SDKMANAGER="/usr/local/android-sdk/tools/bin/sdkmanager"

yes | "${SDKMANAGER}" tools \
  >> .travis/pre.txt 2>&1 \
  || fatal "could not download avdmanager"

info "avdmanager: $(which avdmanager)"

COMPONENTS="
build-tools;28.0.3
platform-tools
platforms;android-28
ndk-bundle
tools
"

for COMPONENT in ${COMPONENTS}
do
  info "downloading ${COMPONENT}"

  yes | "${SDKMANAGER}" "${COMPONENT}" \
    >> .travis/pre.txt 2>&1 \
    || fatal "could not download emulator"
done

info "updating all"

yes | "${SDKMANAGER}" --update \
  >> .travis/pre.txt 2>&1 \
  || fatal "could not update platform"

info "agreeing to licenses"

yes | "${SDKMANAGER}" --licenses \
  >> .travis/pre.txt 2>&1 \
  || fatal "could not agree to licenses"

