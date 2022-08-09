#!/bin/bash -e
# This script builds and runs the serial and OpenACC GPU offload versions of the codes
# gathering runtimes and printing a table with the corresponding speedups.
# nvc is required to build.

# Check that all required commands are available
for cmd in nvc make exec printf make grep cut tr bc; do
    command -v $cmd >/dev/null 2>&1 || { echo >&2 "$cmd is required but it's not installed. Aborting."; exit 1; }
done

# Set locate for decimal point separator and disable stderr output to filter out compiler warnings
LC_NUMERIC=C
exec 2> /dev/null

# Print CPU information if the command is available
if command -v lscpu >/dev/null 2>&1; then
    lscpu
    printf "\n"
fi

# Print GPU information if the command is available
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi
    printf "\n"
fi

# Print compiler information
nvc --version
printf "\n"

printf "Cleaning ... \n"
make clean -C COULOMB
make clean -C MATMUL
make clean -C PI

printf "Executing 1/3: COULOMB... "
COULOMB_SERIAL=$(make run -C COULOMB/serial | grep "time (s)=" | cut -b 11-)
printf "serial done"
COULOMB_ACC_OFFLOAD=$(make run -C COULOMB/pwa-acc-offload | grep "time (s)=" | cut -b 11-)
printf ", offloaded done.\n"

printf "Executing 2/3: MATMUL... "
MATMUL_SERIAL=$(make run -C MATMUL/serial | grep "time (s)=" | cut -b 11-)
printf "serial done"
MATMUL_ACC_OFFLOAD=$(make run -C MATMUL/pwa-acc-offload | grep "time (s)=" | cut -b 11-)
printf ", offloaded done.\n"

printf "Executing 3/3: PI... "
PI_SERIAL=$(make run -C PI/serial | grep "time (s)=" | cut -b 11-)
printf "serial done"
PI_ACC_OFFLOAD=$(make run -C PI/pwa-acc-offload | grep "time (s)=" | cut -b 11-)
printf ", offloaded done.\n"

printf "Cleaning ... \n"
make clean -C COULOMB
make clean -C MATMUL
make clean -C PI

printf "\nCode           \tSerial \tOffload\tSpeedup\tTime reduced\n"
printf "===============\t=======\t=======\t=======\t============\n"

printRow() { # Params: Code, Serial, Multi
    local SPEEDUP=$(bc -l <<< "$2/$3")
    local EXTRA_TAB="" && (( ${#1} < 8 )) && EXTRA_TAB="\t"
    local REDUCTION=$(bc -l <<< "($2-$3)/$2*100")
    printf "%s\t$EXTRA_TAB%.2f\t%.2f\t%.2fx\t%.2f%%\n" $1 $2 $3 $SPEEDUP $REDUCTION
}

printRow "COULOMB" $COULOMB_SERIAL $COULOMB_ACC_OFFLOAD
printRow "MATMUL" $MATMUL_SERIAL $MATMUL_ACC_OFFLOAD
printRow "PI" $PI_SERIAL $PI_ACC_OFFLOAD
