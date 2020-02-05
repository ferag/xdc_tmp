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
$exedir/d_hydro.exe $argfile > "$OUTPUTDIR"/model_output.log

#cd -

inpfile=test_1.inp

currentdir=`pwd`
echo $currentdir
argfile=$currentdir/$inpfile

    #
    # Set the directory containing delwaq1 and delwaq2 and
    # the directory containing the proc_def and bloom files here
    #
exedir=$D3D_BIN/bin/lnx64/waq/bin
procfile=$D3D_BIN/bin/lnx64/waq/default/proc_def

    #
    # Run delwaq 1
    #
$exedir/delwaq1 $argfile -p "$procfile" > "$OUTPUTDIR"/delwaq1_output.log

    #
    # Wait for any key to run delwaq 2
    #
if [ $? == 0 ]
  then
    echo ""
    echo "Delwaq1 did run without errors."

    #
    # Run delwaq 2
    #
    echo ""
    $exedir/delwaq2 $argfile > "$OUTPUTDIR"/delwaq2_output.log

    if [ $? -eq 0 ]
      then
        echo ""
        echo "Delwaq2 did run without errors."
      else
        echo ""
        echo "Delwaq2 did not run correctly."
    fi
else
    echo ""
    echo "Delwaq1 did not run correctly, ending calculation"
fi

#mv ./*.map "$OUTPUTDIR"
#mv ./*.ada "$OUTPUTDIR"
mv ./*.nc "$OUTPUTDIR"
mv ./*.mdf "$OUTPUTDIR"
mv ./*.txt "$OUTPUTDIR"
mv ./*.inp "$OUTPUTDIR"
mv ./*.lga "$OUTPUTDIR"
mv ./*.lsp "$OUTPUTDIR"
mv ./*.lst "$OUTPUTDIR"

echo Output file: "$OUTPUTDIR"/"$OUTPUT_FILENAMES"

echo Onedata metadata attachment

BEGIN_DATE=$(echo $MODEL_PATH| cut -d'_' -f 2)
END_DATE=$(echo $MODEL_PATH| cut -d'_' -f 3 | cut -d'/' -f 1)
REGION=$(echo $MODEL_PATH| cut -d'/' -f 1) 

TITLE=$(echo $MODEL_PATH| cut -d'/' -f 2)
TITLE=$TITLE/$OUTPUT_FILENAMES

curl --tlsv1.2 -X PUT -H "X-Auth-Token: $INPUT_ONEDATA_TOKEN" -H 'Content-type: application/json' -d '{"eml:eml":{"dataset":{"title":"'"$TITLE"'","comment":"model","dataTable":{"dataTable":{"physical":{"size":{"@unit":"bytes","#text":"1231"},"objectName":"'"$TITLE"'","dataFormat":{"textFormat":{"simpleDelimited":{"fieldDelimiter":" "},"numHeaderLines":"1","attributeOrientation":"column"}},"characterEncoding":"ASCII"},"entityName":"'"$TITLE"'","attributeList":"","@id":"'"$TITLE"'"},"FileName":"'"$TITLE"'"},"coverage":{"temporalCoverage":{"rangeOfDates":{"endDate":{"calendarDate":"'"$END_DATE"'"},"beginDate":{"calendarDate":"'"$BEGIN_DATE"'"}}},"geographicCoverage":{"westBoundingCoordinate":"41.91","southBoundingCoordinate":"-2.83","northBoundingCoordinate":"-2.83","geographicDescription":"'"$REGION"'","eastBoundingCoordinate":"41.91","@id":"id"}}},"access":{"allow":{"principal":"public","permission":"read"},"@order":"allowFirst","@authSystem":"knb"},"@xmlns:eml":"eml://ecoinformatics.org/eml-2.1.1","@system":"knb"}}' "https://$ONEDATA_PROVIDERS/api/v3/oneprovider/metadata/json/$ONEDATA_SPACE/$MODEL_PATH$OUTPUT_FILENAMES" -vs 2>&1 | less > "$OUTPUTDIR"/metadata.log

TITLE=$(echo $MODEL_PATH| cut -d'/' -f 2)
OUTPUT_WAQ_FILENAME=test_1_map.nc
TITLE=$TITLE/$OUTPUT_WAQ_FILENAME

curl --tlsv1.2 -X PUT -H "X-Auth-Token: $INPUT_ONEDATA_TOKEN" -H 'Content-type: application/json' -d '{"eml:eml":{"dataset":{"title":"'"$TITLE"'","comment":"model","dataTable":{"dataTable":{"physical":{"size":{"@unit":"bytes","#text":"1231"},"objectName":"'"$TITLE"'","dataFormat":{"textFormat":{"simpleDelimited":{"fieldDelimiter":" "},"numHeaderLines":"1","attributeOrientation":"column"}},"characterEncoding":"ASCII"},"entityName":"'"$TITLE"'","attributeList":"","@id":"'"$TITLE"'"},"FileName":"'"$TITLE"'"},"coverage":{"temporalCoverage":{"rangeOfDates":{"endDate":{"calendarDate":"'"$END_DATE"'"},"beginDate":{"calendarDate":"'"$BEGIN_DATE"'"}}},"geographicCoverage":{"westBoundingCoordinate":"41.91","southBoundingCoordinate":"-2.83","northBoundingCoordinate":"-2.83","geographicDescription":"'"$REGION"'","eastBoundingCoordinate":"41.91","@id":"id"}}},"access":{"allow":{"principal":"public","permission":"read"},"@order":"allowFirst","@authSystem":"knb"},"@xmlns:eml":"eml://ecoinformatics.org/eml-2.1.1","@system":"knb"}}' "https://$ONEDATA_PROVIDERS/api/v3/oneprovider/metadata/json/$ONEDATA_SPACE/$MODEL_PATH$OUTPUT_WAQ_FILENAME" -vs 2>&1 | less > "$OUTPUTDIR"/metadata_waq.log

echo Cleaning temp workspace
rm -rf "$WORKDIR"/* && rm -rf "$WORKDIR"

echo End at $(date)

sleep 5

umount /onedata/output || exit 1
