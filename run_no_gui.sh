#!/usr/bin/env bash

jar_path=${HOME}/contiki/tools/cooja/dist/cooja.jar
simulation_path=""

echo "WARNING: the binary files (.sky, for example) must be in the same directory as the .csc file"
echo "WARNING: if the binary files are not found in the same directory as the simulation file, the motes won't compile!"

if [ "$#" -eq 1 ]; then
    simulation_path=$1
    echo "Assuming cooja.jar path as: ${jar_path}"
    echo "simulation .csc path set as: ${simulation_path}"
elif [ "$#" -eq 2 ]; then
    simulation_path=$1
    jar_path=$2
    echo "cooja.jar path set as: ${jar_path}"
    echo "simulation .csc path set as: ${simulation_path}"
elif [ "$#" -eq 0 ]; then
    echo "Script requires at least the simulation .csc path"
    return
fi

rm -rf *.log
rm -rf *.testlog

for i in {1..10}
do
  java -jar ${jar_path} -nogui=${simulation_path} -contiki=${HOME}/contiki
  sed -i '/test/Id' "COOJA.testlog"
  mv "COOJA.testlog" "exec_${i}.log"
  sed -i '3,$'"s/.*/$i|&/" "exec_${i}.log"
  if (($i > 1)); then
    sed -i '1,2d' "exec_${i}.log"
  else
    sed -i '1d' "exec_${i}.log"
  fi
  cat "exec_${i}.log" >> "all_logs.log"
done

sed -i 1's/.*/EXEC|&/' "all_logs.log"
