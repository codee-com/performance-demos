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
for cmd in cmake exec printf grep cut tr bc pwdirectives unzip sed; do
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
if command -v ${CC:-cc} &>/dev/null; then
  ${CC:-cc} --version
fi
printf "\n"

printf "##################################################\n"
printf "Cleaning ... \n"
printf "##################################################\n"
# MATMUL
rm -rf MATMUL/serial/build MATMUL/serial/buildInt
git checkout -- MATMUL/serial/main.c

printf "\n\n"

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 1/1: MATMUL... \n"
printf "##################################################\n"

cd MATMUL/serial

printf "\nStep 1: Geting Codee checkers report\n"

printRunComm "pwreport --checks main.c:matmul \
 --brief $CODEE_FLAGS -- -I include/"

printf "\nStep 2: Compiling serial code\n"
if command -v ${CC:-cc} &>/dev/null; then
  cmake . \
    -DCMAKE_C_COMPILER=${CC:-cc} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_BUILD_TYPE=Release \
    -B build \
    -G "$GENERATOR_"

  $CALL_GENERATOR -C build
else
  printf "Skpipped. Compiler not found.\n"
fi

printf "\nStep 3: Optimizing code using loop interchange\n"

printRunComm "pwdirectives --memory loop-interchange main.c:16:9 \
 -i --brief $CODEE_FLAGS -- -I include/"

printf "\nStep 4: Compiling optimized code\n"
if command -v ${CC:-cc} &>/dev/null; then
  cmake . \
    -DCMAKE_C_COMPILER=${CC:-cc} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_BUILD_TYPE=Release \
    -B buildInt \
    -G "$GENERATOR_"

  $CALL_GENERATOR -C buildInt
else
  printf "Skpipped. Compiler not found.\n"
fi

printf "\nStep 5: Executing serial code ..................."

if command -v ${CC:-cc} &>/dev/null; then
  MATMUL_SERIAL=$(multipleRuns "build/matmul 1500 | grep \"time (s)=\" | cut -b 11-")
  printf " done"
else
  printf "Skpipped. Compiler not found.\n"
fi

printf "\nStep 6: Executing optimized code ................"

if command -v ${CC:-cc} &>/dev/null; then
  MATMUL_OMP_MULTI=$(multipleRuns "buildInt/matmul 1500 | grep \"time (s)=\" | cut -b 11-")
  printf " done\n\n\n"
else
  printf "Skpipped. Compiler not found.\n"
fi

cd ../..

printf "##################################################\n"
printf "Benchmarking optimized codes\n"
printf "##################################################\n"
printRow() { # Params: Code, Serial, Multi
  local SPEEDUP=$(bc -l <<<"$2/$3")
  local REDUCTION=$(bc -l <<<"($2-$3)/$2*100")
  local EXTRA_TAB="" && ((${#1} < 8)) && EXTRA_TAB="\t"
  LC_NUMERIC="en_US.UTF-8" printf "%s\t$EXTRA_TAB%.2f\t$EXTRA_TAB%.2f\t$EXTRA_TAB%.2f%% (%.2fx)\n" $1 $2 $3 $REDUCTION $SPEEDUP
}

if command -v ${CC:-cc} &>/dev/null; then
  printf "\n"
  printf "Benchmarking setup:\n"
  printf " - $RUNS_WARMUP warmup runs\n"
  printf " - $RUNS runs\n"

  printf "\nCode           \tOriginal \tOptimized  \tSpeedup\n"
  printf "===============\t========\t=========\t==============\n"

  printRow "MATMUL" $MATMUL_SERIAL $MATMUL_OMP_MULTI
else
  printf "Skpipped. Compiler not found.\n"
fi
