#!/bin/bash
env
mkdir -p /onedata/output

ONECLIENT_AUTHORIZATION_TOKEN="$INPUT_ONEDATA_TOKEN" PROVIDER_HOSTNAME="$ONEDATA_PROVIDERS" oneclient --no_check_certificate --authentication token -o rw /onedata/output || exit 1

echo Start at $(date)

OUTPUTDIR="/onedata/output/$ONEDATA_SPACE/$MODEL_PATH"

mkdir -p "$OUTPUTDIR" # create if it does not exists
TEMPW=$(mktemp -d --tmpdir="/data" workspace.XXXXXXXXXX)

WORKDIR="$TEMPW"

# Extract input
echo Extracting input

cp $OUTPUTDIR/* $WORKDIR || exit 1
cd "$WORKDIR" || exit 2

echo Listing directory content:
ls -latr
echo "*************"

chmod 777 ./*.sh

echo Editing $D3D_PARAM with value $D3D_VALUE

echo Run test
# Run Rscript
# ./run_delwaq.sh > log.txt  || exit 1
inpfile=$INPUT_CONFIG_FILE

currentdir=`pwd`
echo $currentdir
argfile=$currentdir/$inpfile

    #
    # Set the directory containing delwaq1 and delwaq2 and
    # the directory containing the proc_def and bloom files here
    #
exedir=$D3D_BIN/bin/lnx64/flow2d3d/bin

    #
    # No adaptions needed below
    #

    # Set some (environment) parameters
export LD_LIBRARY_PATH=$exedir:$LD_LIBRARY_PATH

    # Run
$exedir/d_hydro.exe $argfile

cp ./*.nc "$OUTPUTDIR"
cp ./*.mdf "$OUTPUTDIR"
cp ./*.txt "$OUTPUTDIR"
cp ./*.inp "$OUTPUTDIR"
cp ./*.lga "$OUTPUTDIR"
cp ./*.lsp "$OUTPUTDIR"
cp ./*.lst "$OUTPUTDIR"

echo Output file: "$OUTPUTDIR"/"$OUTPUT_FILENAMES"

cd -

echo Cleaning temp workspace
rm -rf "$WORKDIR"/* && rm -rf "$WORKDIR"


echo End at $(date)

sleep 5

umount /onedata/output || exit 1
