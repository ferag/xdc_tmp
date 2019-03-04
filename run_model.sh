#!/bin/bash
env
mkdir -p /onedata/output

ONECLIENT_AUTHORIZATION_TOKEN="$INPUT_ONEDATA_TOKEN" PROVIDER_HOSTNAME="$ONEDATA_PROVIDERS" oneclient --no_check_certificate --authentication token -o rw /onedata/output || exit 1

echo Start at $(date)

OUTPUTDIR="/onedata/output/$ONEDATA_SPACE/$MODEL_PATH"

mkdir -p "$OUTPUTDIR" # create if it does not exists
mkdir -p /data
TEMPW=$(mktemp -d --tmpdir="/data" workspace.XXXXXXXXXX)

WORKDIR="$TEMPW"

# Extract input
echo Extracting input

mv $OUTPUTDIR/* $WORKDIR || exit 1
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

mv ./*.nc "$OUTPUTDIR"
mv ./*.mdf "$OUTPUTDIR"
mv ./*.txt "$OUTPUTDIR"
mv ./*.inp "$OUTPUTDIR"
mv ./*.lga "$OUTPUTDIR"
mv ./*.lsp "$OUTPUTDIR"
mv ./*.lst "$OUTPUTDIR"

echo Output file: "$OUTPUTDIR"/"$OUTPUT_FILENAMES"

cd -

echo Cleaning temp workspace
rm -rf "$WORKDIR"/* && rm -rf "$WORKDIR"

echo Onedata metadata attachment

BEGIN_DATE=$(echo $MODEL_PATH| cut -d'_' -f 2)
END_DATE=$(echo $MODEL_PATH| cut -d'_' -f 3 | cut -d'/' -f 1)

TITLE=$(echo $MODEL_PATH| cut -d'/' -f 2)
TITLE=$TITLE/$OUTPUT_FILENAMES

curl --tlsv1.2 -X PUT -H "X-Auth-Token: $INPUT_ONEDATA_TOKEN" -H 'Content-type: application/json' -d '{"eml:eml":{"dataset":{"title":"'"$TITLE"'","comment":"model","dataTable":{"dataTable":{"physical":{"size":{"@unit":"bytes","#text":"1231"},"objectName":"'"$TITLE"'","dataFormat":{"textFormat":{"simpleDelimited":{"fieldDelimiter":" "},"numHeaderLines":"1","attributeOrientation":"column"}},"characterEncoding":"ASCII"},"entityName":"'"$TITLE"'","attributeList":"","@id":"'"$TITLE"'"},"FileName":"'"$TITLE"'"},"coverage":{"temporalCoverage":{"rangeOfDates":{"endDate":{"calendarDate":"'"$BEGIN_DATE"'"},"beginDate":{"calendarDate":"'"$END_DATE"'"}}},"geographicCoverage":{"westBoundingCoordinate":"41.91","southBoundingCoordinate":"-2.83","northBoundingCoordinate":"-2.83","geographicDescription":"CdP","eastBoundingCoordinate":"41.91","@id":"id"}}},"access":{"allow":{"principal":"public","permission":"read"},"@order":"allowFirst","@authSystem":"knb"},"@xmlns:eml":"eml://ecoinformatics.org/eml-2.1.1","@system":"knb"}}' "https://$ONEDATA_PROVIDERS/api/v3/oneprovider/metadata/$ONEDATA_SPACE/$MODEL_PATH$OUTPUT_FILENAMES" -v
   
echo End at $(date)

sleep 5

umount /onedata/output || exit 1
