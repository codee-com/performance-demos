#!/bin/bash -e
# This script builds and runs the serial and OpenMP multi-threaded versions of the codes
# gathering runtimes and printing a table with the corresponding speedups.
# Either gcc, clang or icc can be used to build; it can chosen through the CC variable.

function printRunComm() {
  set -e # Force to exit if the command fails
  ## Print the command
  printf "\n$ $@\n"
  ## Run the command
  $@
}

# Variables configuration
# Num warmup runs
if [ -z "$RUNS_WARMUP" ]; then
  RUNS_WARMUP=0
fi
# Num runs
if [ -z "$RUNS" ]; then
  RUNS=2
fi

# This function runs $RUNS_WARMUP warm up runs and $RUNS effective runs of the given command ($1)
# Returns the average time of the effective runs
function multipleRuns() {
  set -e # Force to exit if the command fails
  local sum=0
  local aux=""
  local avg=0
  for ((i = 1; i <= $RUNS_WARMUP; i++)); do
    $(eval $1)
  done
  for ((i = 1; i <= $RUNS; i++)); do
    aux="$(eval $1)"
    sum="$(bc -l <<<"$sum + $aux")"
  done
  avg=$(bc -l <<<"$sum / $RUNS")
  echo "$avg"
}

# Check that all required commands are available
for cmd in ${CC:-cc} cmake exec printf grep cut tr bc codee unzip sed; do
  command -v $cmd >/dev/null 2>&1 || {
    printf >&2 "$cmd is required but it's not installed. Aborting.\n"
    exit 1
  }
done

if command -v ninja --version >/dev/null 2>/dev/null; then
  GENERATOR_="Ninja"
  CALL_GENERATOR="ninja"
else
  if command -v make --version >/dev/null 2>/dev/null; then
    GENERATOR_="Unix Makefiles"
    CALL_GENERATOR="make -j 2"
  else
    printf "Ninja or Makefile is required but it's not installed. Aborting.\n"
    exit 1
  fi
fi

# Set locate for decimal point separator and disable stderr output to filter out compiler warnings
export LC_NUMERIC="en_US.UTF-8"
exec 2>/dev/null

# Print CPU information if the command is available
if command -v lscpu >/dev/null 2>&1; then
  lscpu
  printf "\n"
fi

# Print compiler information
${CC:-cc} --version
printf "\n"

printf "##################################################\n"
printf "Cleaning ... \n"
printf "##################################################\n"
# ATMUX
rm -rf ATMUX/serial/build ATMUX/serial/buildOmp
git checkout -- ATMUX/serial/atmux.c
# CANNY
rm -rf CANNY/serial/build CANNY/serial/buildOmp CANNY/serial/testvecs/
git checkout -- CANNY/serial/canny.c
# COULOMB
rm -rf COULOMB/serial/build COULOMB/serial/buildOmp
git checkout -- COULOMB/serial/coulomb.c
# HACCmk
rm -rf HACCmk/serial/build HACCmk/serial/buildOmp
git checkout -- HACCmk/serial/main.c
# MATMUL
rm -rf MATMUL/serial/build MATMUL/serial/buildOmp
git checkout -- MATMUL/serial/main.c
# NPB_CG
rm -rf NPB_CG/serial/build NPB_CG/serial/buildOmp
git checkout -- NPB_CG/serial/CG/cg.c
# PI
rm -rf PI/serial/build PI/serial/buildOmp
git checkout -- PI/serial/pi.c

printf "\n\n"

printf "##################################################\n"
printf "Executing 1/7: ATMUX... \n"
printf "##################################################\n"

cd ATMUX/serial
printf "\nStep 1: Compiling serial code\n"

cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B build \
  -G "$GENERATOR_"

$CALL_GENERATOR -C build

printf "\nStep 2: Optimizing code with multithreading\n"

printRunComm "codee rewrite --multi omp-for --explicit-privatization y atmux.c:22:5 \
 --config build/compile_commands.json -i --brief $CODEE_FLAGS"
sed -i 's/\/\* y start \*\//0/g' "atmux.c"
sed -i 's/\/\* y length \*\//n/g' "atmux.c"

printf "\nStep 3: Compiling optimized code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B buildOmp \
  -G "$GENERATOR_"

$CALL_GENERATOR -C buildOmp

printf "\nStep 4: Executing serial code ..................."
# multipleRuns "build/atmux 10000 | grep \"time (s)=\" | cut -b 11-"
ATMUX_SERIAL=$(multipleRuns "build/atmux 10000 | grep \"time (s)=\" | cut -b 11-")
printf " done"

printf "\nStep 5: Executing optimized code ................"
ATMUX_OMP_MULTI=$(multipleRuns "buildOmp/atmux 10000 | grep \"time (s)=\" | cut -b 11-")
printf " done\n\n\n"

cd ../..

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 2/7: CANNY... \n"
printf "##################################################\n"

cd CANNY/serial
unzip -u ../15360_8640.zip
printf "\nStep 1: Compiling serial code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B build \
  -G "$GENERATOR_"

$CALL_GENERATOR -C build

printf "\nStep 2: Optimizing code with multithreading\n"

printRunComm "codee rewrite --multi omp-for canny.c:474:4,492:4 \
 --config build/compile_commands.json -i --brief $CODEE_FLAGS"

printf "\nStep 3: Compiling optimized code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B buildOmp \
  -G "$GENERATOR_"

$CALL_GENERATOR -C buildOmp

printf "\nStep 4: Executing serial code ..................."
CANNY_SERIAL=$(multipleRuns "build/canny testvecs/input/15360_8640.pgm 0.5 0.7 0.9 | grep \"Total time:\" | cut -b 13-")
printf " done"

printf "\nStep 5: Executing optimized code ................"
CANNY_OMP_MULTI=$(multipleRuns "buildOmp/canny testvecs/input/15360_8640.pgm 0.5 0.7 0.9 | grep \"Total time:\" | cut -b 13-")
printf " done\n\n\n"

cd ../..

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 3/7: COULOMB... \n"
printf "##################################################\n"

cd COULOMB/serial
printf "\nStep 1: Compiling serial code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B build \
  -G "$GENERATOR_"

$CALL_GENERATOR -C build

printf "\nStep 2: Optimizing code with multithreading\n"

printRunComm "codee rewrite --multi omp-for coulomb.c:26:2 \
 --config build/compile_commands.json -i --brief $CODEE_FLAGS"

printf "\nStep 3: Compiling optimized code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B buildOmp \
  -G "$GENERATOR_"

$CALL_GENERATOR -C buildOmp

printf "\nStep 4: Executing serial code ..................."
COULOMB_SERIAL=$(multipleRuns "build/coulomb 400 | grep \"time (s)=\" | cut -b 11-")
printf " done"

printf "\nStep 5: Executing optimized code ................"
COULOMB_OMP_MULTI=$(multipleRuns "buildOmp/coulomb 400 | grep \"time (s)=\" | cut -b 11-")
printf " done\n\n\n"

cd ../..

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 4/7: HACCmk... \n"
printf "##################################################\n"

cd HACCmk/serial
printf "\nStep 1: Compiling serial code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B build \
  -G "$GENERATOR_"

$CALL_GENERATOR -C build

printf "\nStep 2: Optimizing code with multithreading\n"

printRunComm "codee rewrite --multi omp-for --config compile_commands.json main.c:132:7 \
  -i --brief $CODEE_FLAGS"

printf "\nStep 3: Compiling optimized code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B buildOmp \
  -G "$GENERATOR_"

$CALL_GENERATOR -C buildOmp

printf "\nStep 4: Executing serial code ..................."
HACC_SERIAL=$(multipleRuns "build/main | grep \"Kernel elapsed time, s:\" | tr -s ' ' | cut -d ' ' -f 5")
printf " done"

printf "\nStep 5: Executing optimized code ................"
HACC_OMP_MULTI=$(multipleRuns "buildOmp/main | grep \"Kernel elapsed time, s:\" | tr -s ' ' | cut -d ' ' -f 5")
printf " done\n\n\n"

cd ../..

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 5/7: MATMUL... \n"
printf "##################################################\n"

cd MATMUL/serial
printf "\nStep 1: Compiling serial code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B build \
  -G "$GENERATOR_"

$CALL_GENERATOR -C build

printf "\nStep 2: Optimizing code with multithreading\n"

printRunComm "codee rewrite --multi omp-for main.c:15:5 \
 --config build/compile_commands.json -i --brief $CODEE_FLAGS"

printf "\nStep 3: Compiling optimized code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B buildOmp \
  -G "$GENERATOR_"

$CALL_GENERATOR -C buildOmp

printf "\nStep 4: Executing serial code ..................."
MATMUL_SERIAL=$(multipleRuns "build/matmul 1500 | grep \"time (s)=\" | cut -b 11-")
printf " done"

printf "\nStep 5: Executing optimized code ................"
MATMUL_OMP_MULTI=$(multipleRuns "buildOmp/matmul 1500 | grep \"time (s)=\" | cut -b 11-")
printf " done\n\n\n"

cd ../..

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 6/7: NPB_CG... \n"
printf "##################################################\n"

cd NPB_CG/serial
printf "\nStep 1: Compiling serial code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B build \
  -G "$GENERATOR_"

$CALL_GENERATOR -C build

printf "\nStep 2: Optimizing code with multithreading\n"

printRunComm "codee rewrite --multi omp-for CG/cg.c:458:5 \
  --config build/compile_commands.json -i --brief $CODEE_FLAGS"

printf "\nStep 3: Compiling optimized code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B buildOmp \
  -G "$GENERATOR_"

$CALL_GENERATOR -C buildOmp

printf "\nStep 4: Executing serial code ..................."
NPB_CG_SERIAL=$(multipleRuns "build/bin/cg.B.x | grep \"Time in seconds\" | tr -s ' ' | cut -d ' ' -f 6")
printf " done"

printf "\nStep 5: Executing optimized code ................"
NPB_CG_OMP_MULTI=$(multipleRuns "buildOmp/bin/cg.B.x | grep \"Time in seconds\" | tr -s ' ' | cut -d ' ' -f 6")
printf " done\n\n\n"

cd ../..

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 7/7: PI... \n"
printf "##################################################\n"

cd PI/serial
printf "\nStep 1: Compiling serial code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B build \
  -G "$GENERATOR_"

$CALL_GENERATOR -C build

printf "\nStep 2: Optimizing code with multithreading\n"

printRunComm "codee rewrite --multi omp-for pi.c:31:5 \
 --config build/compile_commands.json -i --brief $CODEE_FLAGS"

printf "\nStep 3: Compiling optimized code\n"
cmake . \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -B buildOmp \
  -G "$GENERATOR_"

$CALL_GENERATOR -C buildOmp

printf "\nStep 4: Executing serial code ..................."
PI_SERIAL=$(multipleRuns "build/pi 1000000000 | grep \"time (s)=\" | cut -b 11-")
printf " done"

printf "\nStep 5: Executing optimized code ................"
PI_OMP_MULTI=$(multipleRuns "buildOmp/pi 1000000000 | grep \"time (s)=\" | cut -b 11-")
printf " done\n\n\n"

cd ../..

printf "##################################################\n"
printf "Benchmarking optimized codes\n"
printf "##################################################\n"
printf "\n"
printf "Benchmarking setup:\n"
printf " - $RUNS_WARMUP warmup runs\n"
printf " - $RUNS runs\n"

printf "\nCode           \tOriginal \tOptimized  \tSpeedup\n"
printf "===============\t========\t=========\t==============\n"

printRow() { # Params: Code, Serial, Multi
  local SPEEDUP=$(bc -l <<<"$2/$3")
  local REDUCTION=$(bc -l <<<"($2-$3)/$2*100")
  local EXTRA_TAB="" && ((${#1} < 8)) && EXTRA_TAB="\t"
  LC_NUMERIC="en_US.UTF-8" printf "%s\t$EXTRA_TAB%.2f\t$EXTRA_TAB%.2f\t$EXTRA_TAB%.2f%% (%.2fx)\n" $1 $2 $3 $REDUCTION $SPEEDUP
}

printRow "ATMUX" $ATMUX_SERIAL $ATMUX_OMP_MULTI
printRow "CANNY" $CANNY_SERIAL $CANNY_OMP_MULTI
printRow "COULOMB" $COULOMB_SERIAL $COULOMB_OMP_MULTI
printRow "HACCmk" $HACC_SERIAL $HACC_OMP_MULTI
printRow "MATMUL" $MATMUL_SERIAL $MATMUL_OMP_MULTI
printRow "NPB_CG" $NPB_CG_SERIAL $NPB_CG_OMP_MULTI
printRow "PI" $PI_SERIAL $PI_OMP_MULTI
