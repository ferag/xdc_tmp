#!/bin/bash

echo Start at $(date)

cd "$MODEL_PATH" || exit 2

echo Listing directory content:
ls -latr
echo "*************"

chmod 777 ./*.sh

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
$exedir/delwaq1 $argfile -p "$procfile"

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
    $exedir/delwaq2 $argfile

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

echo End at $(date)

sleep 5
