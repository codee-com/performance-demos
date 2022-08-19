#!/bin/bash -e

# Check that all required commands are available
for cmd in git cmake ninja printf pwreport pwdirectives; do
    command -v $cmd >/dev/null 2>&1 || { printf >&2 "$cmd is required but it's not installed. Aborting."; exit 1; }
done

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

# Print compiler information
${CC:-cc} --version
printf "\n"

printf "##################################################\n"
printf "Wellcome to Codee's interactive demo with MBedTLS\n"
printf "##################################################\n"
printf "Seven steps:\n"
printf "  1. Generate the compile_commads.json and build the neccesary files for the analysis\n"
printf "  2. Codee's screening report for the whole suite\n"
printf "  3. Codee's screening report for the most important algorightms\n"
printf "  4. Vectorize the code with Codee's pwdirectives tool\n"
printf "  5. Build the vectorized version\n"
printf "  6. Verify the correctness of the vectorized version\n"
printf "  7. Verify the speedup of the vectorized version\n"

read -p "Press enter to start"
printf "\n"
git submodule update --init -- "MbedTLS/v3.1.0"
cd "MbedTLS/v3.1.0/"

#===============================================================================

printf "\nPre-cleaning the build . . .\n"

git restore library/
rm -rf build buildVec

printf "\nDone.\n"

#===============================================================================

printf "##################################################\n"
printf "1/7. Generating Compile_commands.json and building the neccesary files for the analysis ...\n"
printf "##################################################\n"

rm -rf build
cmake \
-DENABLE_TESTING=On \
-DUSE_SHARED_MBEDTLS_LIBRARY=On \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
-Bbuild \
./ \
-G Ninja

cmake --build build

#===============================================================================
printf "\nStep 1 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "2/7. Generating the Codee's Screening Report for the whole suite ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

pwreport --screening --level 2 --config build/compile_commands.json --show-progress --brief

#===============================================================================
printf "\nStep 2 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "3/7. Generating the Codee's Screening Report for the most important algorithms ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

pwreport --screening --level 3 --config build/compile_commands.json --show-progress --brief library/aes.c library/cmac.c

#===============================================================================
printf "\nStep 3 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "4/7. Vectorizing the code with Codee's pwdirectives tool ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

pwdirectives --auto --simd omp --in-place --config build/compile_commands.json library/aes.c:mbedtls_aes_crypt_xts
printf "\nDiff between the original and the vectorized versions:\n"
(
  set +e
  git --no-pager diff library/aes.c
  exit 0
)
printf "\n"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

pwdirectives --auto --simd omp --in-place --config build/compile_commands.json library/cmac.c:cmac_xor_block
printf "\nDiff between the original and the vectorized versions:\n"
(
  set +e
  git --no-pager diff library/cmac.c
  exit 0
)
printf "\n"

#===============================================================================
printf "\nStep 4 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "5/7. Building the vectorized version ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

rm -rf buildVec

cmake \
-DENABLE_TESTING=On \
-DUSE_SHARED_MBEDTLS_LIBRARY=On \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
-DCMAKE_C_FLAGS="-fopenmp-simd" \
-DMBEDTLS_FATAL_WARNINGS=Off \
-BbuildVec \
./ \
-G Ninja

cmake --build buildVec

#===============================================================================
printf "\nStep 5 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "6/7. Verifying the correctness of the vectorized version ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

cd "buildVec/tests/"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
./test_suite_aes.xts

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
./test_suite_cmac

#===============================================================================

printf "\nStep 6 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "7/7. Verifying the speedup of the vectorized version ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"
cd ../..

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
build/programs/test/benchmark aes_xts
printf "original done\n"
printf "************************************************************\n"
buildVec/programs/test/benchmark aes_xts
printf "vectorized done\n"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
build/programs/test/benchmark aes_cmac
printf "original done\n"
printf "************************************************************\n"
buildVec/programs/test/benchmark aes_cmac
printf "vectorized done\n"

#===============================================================================

printf "\nDone.\n"
