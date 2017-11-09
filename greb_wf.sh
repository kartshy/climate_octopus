echo "Sample workflow for a toy climate model"
cd greb-ucm-master
./greb.x ../output/test1

cd ../greb-ucm-reader
./greb.analyser.x ../output/test1 control
./greb.analyser.x ../output/test1 scenario
