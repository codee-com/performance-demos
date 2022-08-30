#!/bin/bash -e
export LC_NUMERIC="en_US.UTF-8"

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
printf "  1. Build original MBbedTLS code\n"
printf "  2. Vectorize the code with Codee's pwdirectives tool\n"
printf "  3. Build the vectorized version\n"
printf "  4. Verify the correctness\n"
printf "  5. Verify the speedup\n"

read -p "Press enter to start"

printf "\n"
printf "##################################################\n"
printf "0/5. Getting the MBedTLS code ...\n"
printf "##################################################\n"

tSource0=$(date +%s%3N)
git submodule update --init -- "MbedTLS/v3.1.0"
cd "MbedTLS/v3.1.0/"
tSource1=$(date +%s%3N)

#===============================================================================

printf "\nPre-cleaning the build . . .\n"

git restore library/
rm -rf build buildVec

printf "\nDone.\n"

#===============================================================================

printf "##################################################\n"
printf "1/5. Building original MBedTLS code ...\n"
printf "##################################################\n"

tBuild0=$(date +%s%3N)

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

tBuild1=$(date +%s%3N)

#===============================================================================
printf "\nStep 1 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "2/5. Vectorizing the code with Codee's pwdirectives tool ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

tBuild2=$(date +%s%3N)

pwdirectives --auto --simd omp --in-place --config build/compile_commands.json library/aes.c:mbedtls_aes_crypt_xts

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

pwdirectives --auto --simd omp --in-place --config build/compile_commands.json library/cmac.c:cmac_xor_block


tBuild3=$(date +%s%3N)

#===============================================================================
printf "\nStep 2 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "3/5. Building the vectorized version ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

tBuild4=$(date +%s%3N)

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

tBuild5=$(date +%s%3N)

#===============================================================================
printf "\nStep 3 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "4/5. Verifying the correctness ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

tBuild6=$(date +%s%3N)

cd "build/tests/"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
./test_suite_aes.xts

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
./test_suite_cmac

cd ../..

tBuild7=$(date +%s%3N)

cd "buildVec/tests/"

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
./test_suite_aes.xts

printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
./test_suite_cmac

cd ../..
tBuild8=$(date +%s%3N)

#===============================================================================

printf "\nStep 4 done.\n"
printf "=============================================================\n\n"
printf "##################################################\n"
printf "5/5. Verifying the speedup ...\n"
printf "##################################################\n"
read -p "Press enter to continue"
printf "\n"

tDeploy0=$(date +%s%3N)
printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
build/programs/test/benchmark aes_xts
printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
build/programs/test/benchmark aes_cmac
printf "original done\n"

tDeploy1=$(date +%s%3N)
printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "aes_xts algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
buildVec/programs/test/benchmark aes_xts
printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
printf "cmac algorithm\n"
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
buildVec/programs/test/benchmark aes_cmac
printf "vectorized done\n"
tDeploy2=$(date +%s%3N)
#===============================================================================

tSource=$(bc -l <<< "($tSource1 - $tSource0) /1000")
tBuildO=$(bc -l <<< "($tBuild1 - $tBuild0) /1000")
tCodee=$(bc -l <<< "($tBuild3 - $tBuild2) /1000")
tBuildC=$(bc -l <<< "($tBuild5 - $tBuild4) /1000")
tTestO=$(bc -l <<< "($tBuild7 - $tBuild6) /1000")
tTestC=$(bc -l <<< "($tBuild8 - $tBuild7) /1000")
tDeployO=$(bc -l <<< "($tDeploy1 - $tDeploy0) /1000")
tDeployC=$(bc -l <<< "($tDeploy2 - $tDeploy1) /1000")

printf "\nStep               \tWithout Codee\tWith Codee\n"
printf "=====================\t=============\t==========\n"
printf "CI: SS: Clone        \t%.3f s\t\t%.3f s\n" $tSource $tSource
printf "CI: BS: pwdirectives \t--- s\t\t%.3f s\n" $tCodee
printf "CI: BS: make all     \t%.3f s\t\t%.3f s\n" $tBuildO $tBuildC
printf "CI: BS: Test aes/cmac\t%.3f s\t\t%.3f s\n" $tTestO $tTestC
printf "CI: DS: Benchmark    \t%.3f s\t\t%.3f s\n" $tDeployO $tDeployC
