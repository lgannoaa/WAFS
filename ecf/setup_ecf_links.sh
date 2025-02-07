#!/bin/bash

set -eu

# Get the root of the cloned WAFS directory
readonly DIR_ROOT=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}")")/.." && pwd -P)

ECF_DIR="${DIR_ROOT}/ecf"

# Function that loops over forecast hours and
# creates link between the master and target
function link_master_to_fhr() {
  local tmpl=$1               # Name of the master template
  local fhrs=$2               # Array of forecast hours
  local clean_only=${3:-"NO"} # Clean only flag to remove existing links
  local fhr3 master target
  for fhr in ${fhrs[@]}; do
    fhr3=$(printf %03d ${fhr})
    master="${tmpl}_master.ecf"
    target="${tmpl}_f${fhr3}.ecf"
    rm -f "${target}"
    case "${clean_only}" in
    "YES")
      continue
      ;;
    *)
      ln -sf "${master}" "${target}"
      ;;
    esac
  done
}

CLEAN=${1:-${CLEAN:-"NO"}} # Remove links only; do not create links (YES)

# JWAFS_UPP
cd "${ECF_DIR}/scripts/upp"
echo "Linking upp ..."
# Add a link for analysis
rm -f jwafs_upp_anl.ecf
if [[ "${CLEAN}" != "YES" ]]; then
  ln -sf jwafs_upp_master.ecf jwafs_upp_anl.ecf
fi
seq0="0"                    # 000
seq1=$(seq -s ' ' 6 1 24)   # 006 -> 024; 1-hourly
seq2=$(seq -s ' ' 27 3 48)  # 027 -> 048; 3-hourly
seq3=$(seq -s ' ' 54 6 120) # 054 -> 120; 6-hourly
fhrs="${seq0} ${seq1} ${seq2} ${seq3}"
link_master_to_fhr "jwafs_upp" "${fhrs}" "${CLEAN}"

# JWAFS_GRIB2
cd "${ECF_DIR}/scripts/grib2/1p25"
echo "Linking grib2/1p25 ..."
seq1="0"                   # 000
seq2=$(seq -s ' ' 6 3 36)  # 006 -> 036; 3-hourly
seq3=$(seq -s ' ' 42 6 72) # 042 -> 072; 6-hourly
fhrs="${seq1} ${seq2} ${seq3}"
link_master_to_fhr "jwafs_grib2_1p25" "${fhrs}" "${CLEAN}"

# JWAFS_GRIB2_0P25
cd "${ECF_DIR}/scripts/grib2/0p25"
echo "Linking grib2/0p25 ..."
seq1=$(seq -s ' ' 6 1 24)   # 006 -> 024; 1-hourly
seq2=$(seq -s ' ' 27 3 48)  # 027 -> 048; 3-hourly
seq3=$(seq -s ' ' 54 6 120) # 054 -> 120; 6-hourly
fhrs="${seq1} ${seq2} ${seq3}"
link_master_to_fhr "jwafs_grib2_0p25" "${fhrs}" "${CLEAN}"

# JWAFS_BLENDING_0P25

# JWAFS_GCIP
cd "${ECF_DIR}/scripts/gcip"
echo "Linking gcip ..."
fhrs="0 3" # 000, 003
link_master_to_fhr "jwafs_gcip" "${fhrs}" "${CLEAN}"

# JWAFS_GRIB
cd "${ECF_DIR}/scripts/grib"
echo "Linking grib ..."
seq1=$(seq -s ' ' 12 6 48) # 012 -> 048; 6-hourly
seq2="60 72"               # 060, 072
fhrs="${seq1} ${seq2}"
link_master_to_fhr "jwafs_grib" "${fhrs}" "${CLEAN}"
