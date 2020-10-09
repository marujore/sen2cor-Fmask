#!/bin/bash
set -e
shopt -s nullglob
if [ $1 == "--help" ]; then
    echo "Usage: \
    docker run --rm \
    -v /path/to/input/:/mnt/input-dir \
    -v /path/to/output:/mnt/output-dir \
    -v /path/to/CCI4SEN2COR:/home/lib/python2.7/site-packages/sen2cor/aux_data \
    -v /path/to/sen2cor_2.5.5/2.5/cfg:/root/sen2cor/2.5/cfg \
    -t sen2cor_2.5.5-fmask_4.2 <SENTINEL-2.SAFE>"
    exit 0
fi

# Set default directories to the INDIR and OUTDIR
# You can customize it using INDIR=/my/custom OUTDIR=/my/out run_sen2cor_fmask.sh
if [ -z "${INDIR}" ]; then
    INDIR=/mnt/input-dir
fi

if [ -z "${OUTDIR}" ]; then
    OUTDIR=/mnt/output-dir/
fi

## SENTINEL-2
SAFENAME_L1C=$1
SAFENAME_L2A_PATTERN=${SAFENAME_L1C//L1C/L2A}
SAFEDIR_L1C=${INDIR}/${SAFENAME_L1C}

WORKDIR=/work
# Ensure that workdir/sceneid is clean
if [ -d "${WORKDIR}/${SAFENAME_L1C}" ]; then
    rm -r ${WORKDIR}/${SAFENAME_L1C}
fi
cp -r ${SAFEDIR_L1C} ${WORKDIR}

# Process Sen2cor
cd ${WORKDIR}
/home/bin/L2A_Process ${SAFENAME_L1C}

for entry in `ls ${WORKDIR}`; do
    if [[ $entry == "$SAFENAME_L2A_PATTERN"* ]]; then
        SAFENAME_L2A=$entry
    fi
done

##FMASK
cd ${WORKDIR}/${SAFENAME_L1C}/GRANULE
for entry in `ls ${WORKDIR}/${SAFENAME_L1C}/GRANULE`; do
    GRANULE_SCENE_L1C=${WORKDIR}/${SAFENAME_L1C}/GRANULE/${entry}
    GRANULE_ID_L1C=$entry
done
GRANULE_ID_L2A=${GRANULE_ID_L1C//L1C/L2A}
GRANULE_SCENE_L2A=${WORKDIR}/${SAFENAME_L2A}/GRANULE/$GRANULE_ID_L2A

MCROOT=/usr/local/MATLAB/MATLAB_Runtime/v96
cd ${GRANULE_SCENE_L1C}
/usr/GERS/Fmask_4_2/application/run_Fmask_4_2.sh $MCROOT "$@"

## Copy outputs from workdir
OUT_PATTERNS="${GRANULE_SCENE_L1C}/FMASK_DATA/*_Fmask4*.tif"
if ls $OUT_PATTERNS* 1> /dev/null 2>&1; then
    for f in $OUT_PATTERNS; do
        FMASK_NAME="$(basename -- $f)"
        gdalwarp -tr 10 10 -r near -overwrite -co "COMPRESS=PACKBITS" $f ${GRANULE_SCENE_L2A}/IMG_DATA/$FMASK_NAME
    done
else
    # if Fmask does not exist set image values to 4 (cloud) and keeps nodata as nodata
    echo "Generating synthetic 100% Cloud Fmask"
    cd ${GRANULE_SCENE_L1C}/IMG_DATA/
    for entry in `ls ${GRANULE_SCENE_L1C}/IMG_DATA/`; do
        echo $entry
        if [[ $entry == *"B04.jp2" ]]; then
            REFIMG=${GRANULE_SCENE_L1C}/IMG_DATA/${entry}
        fi
    done
    gdal_calc.py -A $REFIMG --outfile=${GRANULE_SCENE_L2A}/IMG_DATA/${GRANULE_ID_L1C}_Fmask4.tif --calc="4*(A>-9999)"
fi

cp -r ${WORKDIR}/${SAFENAME_L2A} $OUTDIR
rm -r $WORKDIR/${SAFENAME_L2A}
rm -r $WORKDIR/${SAFENAME_L1C}
exit 0
