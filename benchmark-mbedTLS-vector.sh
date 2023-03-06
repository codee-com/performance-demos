#!/bin/bash -e
# This script builds and runs the serial and OpenMP vectorized versions of MbedTLS
# gathering the Ki/s and printing a table with the corresponding speedups.
# Either gcc, clang or icc can be used to build; it can chosen through the CC variable.

function printRunComm(){
    ## Print the command
    printf "\n$ $@\n"
    ## Run the command
    $@
}

# Check that all required commands are available
for cmd in git cmake printf pwreport pwdirectives bc; do
    command -v $cmd >/dev/null 2>&1 || { printf >&2 "$cmd is required but it's not installed. Aborting.\n"; exit 1; }
done

if command -v ninja --version >/dev/null 2>/dev/null ; then
    GENERATOR_="Ninja"
    CALL_GENERATOR="ninja"
else if command -v make --version >/dev/null 2>/dev/null ; then
        GENERATOR_="Unix Makefiles"
        CALL_GENERATOR="make"
    else 
        printf "Ninja or Makefile is required but it's not installed. Aborting.\n"; exit 1;
    fi
fi

# Set locate for decimal point separator
export LC_NUMERIC="en_US.UTF-8"

# Check current directory
if git rev-parse --git-dir > /dev/null 2>&1; then
  : # This is a valid git repository
else
  : # this is not a git repository
  printf "Invalid git directory.\n"
  printf "Please, clone directly the repository from https://github.com/teamappentra/performance-demos.git \n"
  exit;
fi

# Print CPU information if the command is available
if command -v lscpu >/dev/null 2>&1; then
    lscpu
    printf "\n"
fi

# Varialbes configuration
# Num warmup runs
if [ -z "$RUNS_WARMUP" ]; then
  RUNS_WARMUP=0
fi  
# Num runs
if [ -z "$RUNS" ]; then
  RUNS=2
fi


# Print compiler information
${CC:-cc} --version

# Compiler_flags
IS_ICC=$(${CC:-cc} --version 2> /dev/null | grep 'icc' || true)
if [ -z "$IS_ICC" ]; then
    EXTRA_FLAGS="$CFLAGS -fopenmp-simd"
else
    EXTRA_FLAGS="$CFLAGS -qopenmp-simd"
fi

printf "\n"

printf "##################################################\n"
printf "Wellcome to Codee's interactive demo with MBedTLS\n"
printf "##################################################\n"
printf "Seven steps:\n"
printf "  1. Build original MBbedTLS code\n"
printf "  2. Codee's screening report for the whole suite\n"
printf "  3. Vectorize the code with Codee's pwdirectives tool\n"
printf "  4. Build the vectorized version\n"
printf "  5. Verify the correctness\n"
printf "  6. Verify the speedup\n"

read -p "Press enter to start"

printf "\n"
printf "##################################################\n"
printf "0/6. Getting the MBedTLS code ...\n"
printf "##################################################\n"

tSource0=$(date +%s%3N)
git submodule update --init -- "MbedTLS/v3.1.0"
cd "MbedTLS/v3.1.0/"
tSource1=$(date +%s%3N)

#===============================================================================

printf "\nPre-cleaning the build . . .\n"
# Support for old git versions
git checkout -- library/
rm -rf build buildVec

printf "\nDone.\n"

#===============================================================================

printf "##################################################\n"
printf "1/6. Building original MBedTLS code ...\n"
printf "##################################################\n"

tBuild0=$(date +%s%3N)

# Support for old cmake versions
mkdir build
(
  cd build
  cmake \
  -DENABLE_TESTING=On \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DUSE_SHARED_MBEDTLS_LIBRARY=On \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -DMBEDTLS_FATAL_WARNINGS=Off \
  -H. ../ \
  -G "$GENERATOR_"

  $CALL_GENERATOR
)

tBuild1=$(date +%s%3N)


#===============================================================================
printf "\nStep 1 done.\n"
printf "##################################################\n"
printf "2/6. Generating the Codee's Screening Report for the whole suite ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

tScreening0=$(date +%s%3N)
printRunComm "pwreport --screening --config build/compile_commands.json --show-progress $CODEE_FLAGS"
tScreening1=$(date +%s%3N)

#===============================================================================
printf "\nStep 2 done.\n"
printf "##################################################\n"
printf "3/6. Vectorizing the code with Codee's pwdirectives tool ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

tBuild2=$(date +%s%3N)

printRunComm "pwdirectives --auto --simd omp --in-place --config build/compile_commands.json library/aes.c:mbedtls_aes_crypt_xts --brief $CODEE_FLAGS"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_cbc algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

printRunComm "pwdirectives --auto --simd omp --in-place --config build/compile_commands.json library/aes.c:mbedtls_aes_crypt_cbc --brief $CODEE_FLAGS"


printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

printRunComm "pwdirectives --auto --simd omp --in-place --config build/compile_commands.json library/cmac.c:cmac_xor_block --brief $CODEE_FLAGS"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cbc algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

printRunComm "pwdirectives --auto --simd omp --in-place --config build/compile_commands.json library/aria.c:mbedtls_aria_crypt_cbc --brief $CODEE_FLAGS"

tBuild3=$(date +%s%3N)

#===============================================================================
printf "\nStep 3 done.\n"
printf "##################################################\n"
printf "4/6. Building the vectorized version ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

tBuild4=$(date +%s%3N)

# Support for old cmake versions
mkdir buildVec
(
  cd buildVec
  cmake \
  -DENABLE_TESTING=On \
  -DCMAKE_C_COMPILER=${CC:-cc} \
  -DUSE_SHARED_MBEDTLS_LIBRARY=On \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
  -DCMAKE_C_FLAGS="$EXTRA_FLAGS" \
  -DMBEDTLS_FATAL_WARNINGS=Off \
  -H. ../ \
  -G "$GENERATOR_"

  $CALL_GENERATOR
)

tBuild5=$(date +%s%3N)

#===============================================================================
printf "\nStep 4 done.\n"
printf "##################################################\n"
printf "5/6. Verifying the correctness ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

tBuild6=$(date +%s%3N)

cd "build/tests/"

printf "\naes_xts original algorithm\n"
./test_suite_aes.xts | grep 'PASSED'

printf "\naes_cbc original algorithm\n"
./test_suite_aes.cbc | grep 'PASSED'

printf "\ncmac original algorithm\n"
./test_suite_cmac | grep 'PASSED'

printf "\naria (cbc) original algorithm\n"
./test_suite_aria | grep 'PASSED'

cd ../..

tBuild7=$(date +%s%3N)

cd "buildVec/tests/"

printf "\naes_xts vectorized algorithm\n"
./test_suite_aes.xts | grep 'PASSED'

printf "\naes_cbc vectorized algorithm\n"
./test_suite_aes.cbc | grep 'PASSED'

printf "\ncmac vectorized algorithm\n"
./test_suite_cmac | grep 'PASSED'

printf "\naria (cbc) original algorithm\n"
./test_suite_aria | grep 'PASSED'

cd ../..
tBuild8=$(date +%s%3N)

#===============================================================================

printf "\nStep 5 done.\n"
printf "##################################################\n"
printf "6/6. Verifying the speedup ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

tDeploy0=$(date +%s%3N)
for (( i=1; i<=$RUNS_WARMUP; i++ ))
do
    build/programs/test/benchmark aes_xts > /dev/null
done
for (( i=1; i<=$RUNS; i++ ))
do
    aes_xts_ORIGINAL=$(build/programs/test/benchmark aes_xts)
    aes_xts_128_ORIGINAL_A[$i]=$(echo "$aes_xts_ORIGINAL" | grep 'AES-XTS-128' | tr -s ' ' | cut -d ' ' -f 4)
    aes_xts_256_ORIGINAL_A[$i]=$(echo "$aes_xts_ORIGINAL" | grep 'AES-XTS-256' | tr -s ' ' | cut -d ' ' -f 4)
done
#--------------------------------------------------------------------------------
for (( i=1; i<=$RUNS_WARMUP; i++ ))
do
    build/programs/test/benchmark aes_cbc > /dev/null
done
for (( i=1; i<=$RUNS; i++ ))
do
    aes_cbc_ORIGINAL=$(build/programs/test/benchmark aes_cbc)
    aes_cbc_128_ORIGINAL_A[$i]=$(echo "$aes_cbc_ORIGINAL" | grep 'AES-CBC-128' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cbc_192_ORIGINAL_A[$i]=$(echo "$aes_cbc_ORIGINAL" | grep 'AES-CBC-192' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cbc_256_ORIGINAL_A[$i]=$(echo "$aes_cbc_ORIGINAL" | grep 'AES-CBC-256' | tr -s ' ' | cut -d ' ' -f 4)
done
#--------------------------------------------------------------------------------
for (( i=1; i<=$RUNS_WARMUP; i++ ))
do
    build/programs/test/benchmark aes_cmac  > /dev/null
done
for (( i=1; i<=$RUNS; i++ ))
do
    aes_cmac_ORIGINAL=$(build/programs/test/benchmark aes_cmac)
    aes_cmac_128_ORIGINAL_A[$i]=$(echo "$aes_cmac_ORIGINAL" | grep 'AES-CMAC-128' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cmac_192_ORIGINAL_A[$i]=$(echo "$aes_cmac_ORIGINAL" | grep 'AES-CMAC-192' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cmac_256_ORIGINAL_A[$i]=$(echo "$aes_cmac_ORIGINAL" | grep 'AES-CMAC-256' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cmac_PRF_128_ORIGINAL_A[$i]=$(echo "$aes_cmac_ORIGINAL" | grep 'AES-CMAC-PRF-128' | tr -s ' ' | cut -d ' ' -f 4)
done
#--------------------------------------------------------------------------------
for (( i=1; i<=$RUNS_WARMUP; i++ ))
do
    build/programs/test/benchmark aria  > /dev/null
done
for (( i=1; i<=$RUNS; i++ ))
do
    aria_cbc_ORIGINAL=$(build/programs/test/benchmark aria)
    aria_cbc_128_ORIGINAL_A[$i]=$(echo "$aria_cbc_ORIGINAL" | grep 'ARIA-CBC-128' | tr -s ' ' | cut -d ' ' -f 4)
    aria_cbc_192_ORIGINAL_A[$i]=$(echo "$aria_cbc_ORIGINAL" | grep 'ARIA-CBC-192' | tr -s ' ' | cut -d ' ' -f 4)
    aria_cbc_256_ORIGINAL_A[$i]=$(echo "$aria_cbc_ORIGINAL" | grep 'ARIA-CBC-256' | tr -s ' ' | cut -d ' ' -f 4)
done
#--------------------------------------------------------------------------------
printf "original done\n"
#--------------------------------------------------------------------------------
tDeploy1=$(date +%s%3N)
for (( i=1; i<=$RUNS_WARMUP; i++ ))
do
    buildVec/programs/test/benchmark aes_xts > /dev/null
done
for (( i=1; i<=$RUNS; i++ ))
do
    aes_xts_VECTORIZED=$(buildVec/programs/test/benchmark aes_xts)
    aes_xts_128_VECTORIZED_A[$i]=$(echo "$aes_xts_VECTORIZED" | grep 'AES-XTS-128' | tr -s ' ' | cut -d ' ' -f 4)
    aes_xts_256_VECTORIZED_A[$i]=$(echo "$aes_xts_VECTORIZED" | grep 'AES-XTS-256' | tr -s ' ' | cut -d ' ' -f 4)
done
#--------------------------------------------------------------------------------
for (( i=1; i<=$RUNS_WARMUP; i++ ))
do
    buildVec/programs/test/benchmark aes_cbc > /dev/null
done
for (( i=1; i<=$RUNS; i++ ))
do
    aes_cbc_VECTORIZED=$(buildVec/programs/test/benchmark aes_cbc)
    aes_cbc_128_VECTORIZED_A[$i]=$(echo "$aes_cbc_VECTORIZED" | grep 'AES-CBC-128' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cbc_192_VECTORIZED_A[$i]=$(echo "$aes_cbc_VECTORIZED" | grep 'AES-CBC-192' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cbc_256_VECTORIZED_A[$i]=$(echo "$aes_cbc_VECTORIZED" | grep 'AES-CBC-256' | tr -s ' ' | cut -d ' ' -f 4)
done
#--------------------------------------------------------------------------------
for (( i=1; i<=$RUNS_WARMUP; i++ ))
do
    buildVec/programs/test/benchmark aes_cmac > /dev/null
done
for (( i=1; i<=$RUNS; i++ ))
do
    aes_cmac_VECTORIZED=$(buildVec/programs/test/benchmark aes_cmac)
    aes_cmac_128_VECTORIZED_A[$i]=$(echo "$aes_cmac_VECTORIZED" | grep 'AES-CMAC-128' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cmac_192_VECTORIZED_A[$i]=$(echo "$aes_cmac_VECTORIZED" | grep 'AES-CMAC-192' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cmac_256_VECTORIZED_A[$i]=$(echo "$aes_cmac_VECTORIZED" | grep 'AES-CMAC-256' | tr -s ' ' | cut -d ' ' -f 4)
    aes_cmac_PRF_128_VECTORIZED_A[$i]=$(echo "$aes_cmac_VECTORIZED" | grep 'AES-CMAC-PRF-128' | tr -s ' ' | cut -d ' ' -f 4)
done
#--------------------------------------------------------------------------------
for (( i=1; i<=$RUNS_WARMUP; i++ ))
do
    buildVec/programs/test/benchmark aria > /dev/null
done
for (( i=1; i<=$RUNS; i++ ))
do
    aria_cbc_VECTORIZED=$(buildVec/programs/test/benchmark aria)
    aria_cbc_128_VECTORIZED_A[$i]=$(echo "$aria_cbc_VECTORIZED" | grep 'ARIA-CBC-128' | tr -s ' ' | cut -d ' ' -f 4)
    aria_cbc_192_VECTORIZED_A[$i]=$(echo "$aria_cbc_VECTORIZED" | grep 'ARIA-CBC-192' | tr -s ' ' | cut -d ' ' -f 4)
    aria_cbc_256_VECTORIZED_A[$i]=$(echo "$aria_cbc_VECTORIZED" | grep 'ARIA-CBC-256' | tr -s ' ' | cut -d ' ' -f 4)
done
#--------------------------------------------------------------------------------
printf "vectorized done\n"
tDeploy2=$(date +%s%3N)
#===============================================================================

tSource=$(bc -l <<< "($tSource1 - $tSource0) /1000")
tBuildO=$(bc -l <<< "($tBuild1 - $tBuild0) /1000")
tScreening=$(bc -l <<< "($tScreening1 - $tScreening0) /1000")
tCodee=$(bc -l <<< "($tBuild3 - $tBuild2) /1000")
tBuildC=$(bc -l <<< "($tBuild5 - $tBuild4) /1000")
tTestO=$(bc -l <<< "($tBuild7 - $tBuild6) /1000")
tTestC=$(bc -l <<< "($tBuild8 - $tBuild7) /1000")
tDeployO=$(bc -l <<< "(($tDeploy1 - $tDeploy0)/($RUNS+$RUNS_WARMUP)) /1000")
tDeployC=$(bc -l <<< "(($tDeploy2 - $tDeploy1)/($RUNS+$RUNS_WARMUP)) /1000")


printf "\nStep               \tWithout Codee\t\tWith Codee\n"
printf "=====================\t=============\t\t==========\n"
printf "CI: SS: Clone        \t%.3f s \t\t%.3f s\n" $tSource $tSource
printf "CI: BS: pwdirectives \t----- s \t\t%.3f s\n" $tCodee
printf "CI: BS: make all     \t%.3f s \t\t%.3f s\n" $tBuildO $tBuildC
printf "CI: BS: Test aes/cmac\t%.3f s \t\t%.3f s\n" $tTestO $tTestC
printf "CI: DS: Benchmark    \t%.3f s \t\t%.3f s\n" $tDeployO $tDeployC

aes_xts_128_ORIGINAL=0
aes_xts_128_VECTORIZED=0
aes_xts_256_ORIGINAL=0
aes_xts_256_VECTORIZED=0
aes_cbc_128_ORIGINAL=0
aes_cbc_128_VECTORIZED=0
aes_cbc_192_ORIGINAL=0
aes_cbc_192_VECTORIZED=0
aes_cbc_256_ORIGINAL=0
aes_cbc_256_VECTORIZED=0
aes_cmac_128_ORIGINAL=0
aes_cmac_128_VECTORIZED=0
aes_cmac_192_ORIGINAL=0
aes_cmac_192_VECTORIZED=0
aes_cmac_256_ORIGINAL=0
aes_cmac_256_VECTORIZED=0
aes_cmac_PRF_128_ORIGINAL=0
aes_cmac_PRF_128_VECTORIZED=0
aria_cbc_128_ORIGINAL=0
aria_cbc_128_VECTORIZED=0
aria_cbc_192_ORIGINAL=0
aria_cbc_192_VECTORIZED=0
aria_cbc_256_ORIGINAL=0
aria_cbc_256_VECTORIZED=0
for (( i=1; i<=$RUNS; i++ ))
do
    aes_xts_128_ORIGINAL=$(bc -l <<< "$aes_xts_128_ORIGINAL + ${aes_xts_128_ORIGINAL_A[$i]}")
    aes_xts_128_VECTORIZED=$(bc -l <<< "$aes_xts_128_VECTORIZED + ${aes_xts_128_VECTORIZED_A[$i]}")
    aes_xts_256_ORIGINAL=$(bc -l <<< "$aes_xts_256_ORIGINAL + ${aes_xts_256_ORIGINAL_A[$i]}")
    aes_xts_256_VECTORIZED=$(bc -l <<< "$aes_xts_256_VECTORIZED + ${aes_xts_256_VECTORIZED_A[$i]}")
    aes_cbc_128_ORIGINAL=$(bc -l <<< "$aes_cbc_128_ORIGINAL + ${aes_cbc_128_ORIGINAL_A[$i]}")
    aes_cbc_128_VECTORIZED=$(bc -l <<< "$aes_cbc_128_VECTORIZED + ${aes_cbc_128_VECTORIZED_A[$i]}")
    aes_cbc_192_ORIGINAL=$(bc -l <<< "$aes_cbc_192_ORIGINAL + ${aes_cbc_192_ORIGINAL_A[$i]}")
    aes_cbc_192_VECTORIZED=$(bc -l <<< "$aes_cbc_192_VECTORIZED + ${aes_cbc_192_VECTORIZED_A[$i]}")
    aes_cbc_256_ORIGINAL=$(bc -l <<< "$aes_cbc_256_ORIGINAL + ${aes_cbc_256_ORIGINAL_A[$i]}")
    aes_cbc_256_VECTORIZED=$(bc -l <<< "$aes_cbc_256_VECTORIZED + ${aes_cbc_256_VECTORIZED_A[$i]}")
    aes_cmac_128_ORIGINAL=$(bc -l <<< "$aes_cmac_128_ORIGINAL + ${aes_cmac_128_ORIGINAL_A[$i]}")
    aes_cmac_128_VECTORIZED=$(bc -l <<< "$aes_cmac_128_VECTORIZED + ${aes_cmac_128_VECTORIZED_A[$i]}")
    aes_cmac_192_ORIGINAL=$(bc -l <<< "$aes_cmac_192_ORIGINAL + ${aes_cmac_192_ORIGINAL_A[$i]}")
    aes_cmac_192_VECTORIZED=$(bc -l <<< "$aes_cmac_192_VECTORIZED + ${aes_cmac_192_VECTORIZED_A[$i]}")
    aes_cmac_256_ORIGINAL=$(bc -l <<< "$aes_cmac_256_ORIGINAL + ${aes_cmac_256_ORIGINAL_A[$i]}")
    aes_cmac_256_VECTORIZED=$(bc -l <<< "$aes_cmac_256_VECTORIZED + ${aes_cmac_256_VECTORIZED_A[$i]}")
    aes_cmac_PRF_128_ORIGINAL=$(bc -l <<< "$aes_cmac_PRF_128_ORIGINAL + ${aes_cmac_PRF_128_ORIGINAL_A[$i]}")
    aes_cmac_PRF_128_VECTORIZED=$(bc -l <<< "$aes_cmac_PRF_128_VECTORIZED + ${aes_cmac_PRF_128_VECTORIZED_A[$i]}")
    aria_cbc_128_ORIGINAL=$(bc -l <<< "$aria_cbc_128_ORIGINAL + ${aria_cbc_128_ORIGINAL_A[$i]}")
    aria_cbc_128_VECTORIZED=$(bc -l <<< "$aria_cbc_128_VECTORIZED + ${aria_cbc_128_VECTORIZED_A[$i]}")
    aria_cbc_192_ORIGINAL=$(bc -l <<< "$aria_cbc_192_ORIGINAL + ${aria_cbc_192_ORIGINAL_A[$i]}")
    aria_cbc_192_VECTORIZED=$(bc -l <<< "$aria_cbc_192_VECTORIZED + ${aria_cbc_192_VECTORIZED_A[$i]}")
    aria_cbc_256_ORIGINAL=$(bc -l <<< "$aria_cbc_256_ORIGINAL + ${aria_cbc_256_ORIGINAL_A[$i]}")
    aria_cbc_256_VECTORIZED=$(bc -l <<< "$aria_cbc_256_VECTORIZED + ${aria_cbc_256_VECTORIZED_A[$i]}")
done 
aes_xts_128_ORIGINAL=$(bc -l <<< "$aes_xts_128_ORIGINAL / $RUNS")
aes_xts_128_VECTORIZED=$(bc -l <<< "$aes_xts_128_VECTORIZED / $RUNS")
aes_xts_256_ORIGINAL=$(bc -l <<< "$aes_xts_256_ORIGINAL / $RUNS")
aes_xts_256_VECTORIZED=$(bc -l <<< "$aes_xts_256_VECTORIZED / $RUNS")
aes_cbc_128_ORIGINAL=$(bc -l <<< "$aes_cbc_128_ORIGINAL / $RUNS")
aes_cbc_128_VECTORIZED=$(bc -l <<< "$aes_cbc_128_VECTORIZED / $RUNS")
aes_cbc_192_ORIGINAL=$(bc -l <<< "$aes_cbc_192_ORIGINAL / $RUNS")
aes_cbc_192_VECTORIZED=$(bc -l <<< "$aes_cbc_192_VECTORIZED / $RUNS")
aes_cbc_256_ORIGINAL=$(bc -l <<< "$aes_cbc_256_ORIGINAL / $RUNS")
aes_cbc_256_VECTORIZED=$(bc -l <<< "$aes_cbc_256_VECTORIZED / $RUNS")
aes_cmac_128_ORIGINAL=$(bc -l <<< "$aes_cmac_128_ORIGINAL / $RUNS")
aes_cmac_128_VECTORIZED=$(bc -l <<< "$aes_cmac_128_VECTORIZED / $RUNS")
aes_cmac_192_ORIGINAL=$(bc -l <<< "$aes_cmac_192_ORIGINAL / $RUNS")
aes_cmac_192_VECTORIZED=$(bc -l <<< "$aes_cmac_192_VECTORIZED / $RUNS")
aes_cmac_256_ORIGINAL=$(bc -l <<< "$aes_cmac_256_ORIGINAL / $RUNS")
aes_cmac_256_VECTORIZED=$(bc -l <<< "$aes_cmac_256_VECTORIZED / $RUNS")
aes_cmac_PRF_128_ORIGINAL=$(bc -l <<< "$aes_cmac_PRF_128_ORIGINAL / $RUNS")
aes_cmac_PRF_128_VECTORIZED=$(bc -l <<< "$aes_cmac_PRF_128_VECTORIZED / $RUNS")
aria_cbc_128_ORIGINAL=$(bc -l <<< "$aria_cbc_128_ORIGINAL / $RUNS")
aria_cbc_128_VECTORIZED=$(bc -l <<< "$aria_cbc_128_VECTORIZED / $RUNS")
aria_cbc_192_ORIGINAL=$(bc -l <<< "$aria_cbc_192_ORIGINAL / $RUNS")
aria_cbc_192_VECTORIZED=$(bc -l <<< "$aria_cbc_192_VECTORIZED / $RUNS")
aria_cbc_256_ORIGINAL=$(bc -l <<< "$aria_cbc_256_ORIGINAL / $RUNS")
aria_cbc_256_VECTORIZED=$(bc -l <<< "$aria_cbc_256_VECTORIZED / $RUNS")

printf "\n"
printf "Benchmarking setup:\n"
printf " - $RUNS_WARMUP warmup runs\n"
printf " - $RUNS runs\n"

SEPARATOR="                    "
printRow() { # Params: Code, Serial, Multi
    local SPEEDUP=$(bc -l <<< "(($3-$2)/$2)*100")
    local i="$1"
    local j="%.f KiB/s"
    local k="%.f KiB/s"
    local l="%.2f%%"
    LC_NUMERIC="en_US.UTF-8" printf "$i${SEPARATOR:1:20-${#i}}$j${SEPARATOR:1:17-${#j}}$k${SEPARATOR:1:17-${#k}}$l${SEPARATOR:1:20-${#l}}\n" $2 $3 $SPEEDUP
}
i="Algorithm"
j="Original"
k="Optimized"
l="Speedup"
printf "\n$i${SEPARATOR:1:20-${#i}}$j${SEPARATOR:1:20-${#j}}$k${SEPARATOR:1:20-${#k}}$l${SEPARATOR:1:20-${#l}}\n"
i="================"
j="============"
k="======="
printf "$i${SEPARATOR:1:20-${#i}}$j${SEPARATOR:1:20-${#j}}$j${SEPARATOR:1:20-${#j}}$k${SEPARATOR:1:20-${#k}}\n"

printRow "AES-XTS-128" $aes_xts_128_ORIGINAL $aes_xts_128_VECTORIZED
printRow "AES-XTS-256" $aes_xts_256_ORIGINAL $aes_xts_256_VECTORIZED
printRow "AES-CBC-128" $aes_cbc_128_ORIGINAL $aes_cbc_128_VECTORIZED
printRow "AES-CBC-192" $aes_cbc_192_ORIGINAL $aes_cbc_192_VECTORIZED
printRow "AES-CBC-256" $aes_cbc_256_ORIGINAL $aes_cbc_256_VECTORIZED
printRow "AES-CMAC-128" $aes_cmac_128_ORIGINAL $aes_cmac_128_VECTORIZED
printRow "AES-CMAC-192" $aes_cmac_192_ORIGINAL $aes_cmac_192_VECTORIZED
printRow "AES-CMAC-256" $aes_cmac_256_ORIGINAL $aes_cmac_256_VECTORIZED
printRow "AES-CMAC-PRF-128" $aes_cmac_PRF_128_ORIGINAL $aes_cmac_PRF_128_VECTORIZED
printRow "ARIA-CBC-128" $aria_cbc_128_ORIGINAL $aria_cbc_128_VECTORIZED
printRow "ARIA-CBC-192" $aria_cbc_192_ORIGINAL $aria_cbc_192_VECTORIZED
printRow "ARIA-CBC-256" $aria_cbc_256_ORIGINAL $aria_cbc_256_VECTORIZED
