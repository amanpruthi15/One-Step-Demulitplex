#!/bin/bash
set -euo pipefail

###############################################################################
# Argument check
###############################################################################
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <working_directory> <SampleSheet.csv>"
    exit 1
fi

WORKDIR=$(realpath "$1")
SAMPLESHEET=$(realpath "$2")

###############################################################################
# Logging setup (sudo-safe)
###############################################################################
TODAY=$(date +%F)
LOGFILE="${WORKDIR}/${TODAY}_demux.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOGFILE}"
}

# Capture all stderr explicitly
exec 2> >(while read -r line; do log "ERROR: $line"; done)

###############################################################################
# Start
###############################################################################
log "Starting demultiplexing pipeline"

if [ ! -d "${WORKDIR}" ]; then
    log "ERROR: Working directory does not exist: ${WORKDIR}"
    exit 1
fi

if [ ! -f "${SAMPLESHEET}" ]; then
    log "ERROR: SampleSheet not found: ${SAMPLESHEET}"
    exit 1
fi

log "Working directory: ${WORKDIR}"
log "SampleSheet: ${SAMPLESHEET}"

###############################################################################
# SampleSheet processing
###############################################################################
SS_FILENAME=$(basename "${SAMPLESHEET}")
SS_BASE="${SS_FILENAME%.csv}"
RUN_NAME=$(echo "${SS_BASE}" | sed 's/_SampleSheet$//')

DEMUX_SS="${TODAY}_${RUN_NAME}_SampleSheet_Demux.csv"
CONFIG_FILE="${TODAY}_${RUN_NAME}.config"

log "Creating demultiplexed SampleSheet: ${DEMUX_SS}"

grep -v '^NoLaneSplitting,TRUE' "${SAMPLESHEET}" > "${WORKDIR}/${DEMUX_SS}"

if grep -q 'NoLaneSplitting' "${WORKDIR}/${DEMUX_SS}"; then
    log "ERROR: NoLaneSplitting line still present after filtering"
    exit 1
fi

log "SampleSheet cleanup successful"

###############################################################################
# Config file creation
###############################################################################
log "Generating config file: ${CONFIG_FILE}"

cat <<EOF > "${WORKDIR}/${CONFIG_FILE}"
#Input Directory
input_path=${WORKDIR}

#Output Directory
output_path=${WORKDIR}/output

#Sample sheet file name
data=${DEMUX_SS}

#Container Name
c_name=bcl-convert

#Login user
user=norwalk1
EOF

chmod +x "${WORKDIR}/${CONFIG_FILE}"

log "Config file created successfully"

###############################################################################
# Run BCL Convert
###############################################################################
log "Launching BCL Convert container"

bash /home/norwalk1/software/apruthi/docker-bcl-convert.sh "${WORKDIR}/${CONFIG_FILE}"

log "BCL Convert finished successfully"
log "Demultiplexing pipeline completed"
