#!/bin/bash -e
# This script builds and runs the serial and OpenMP multi-threaded versions of the codes
# gathering runtimes and printing a table with the corresponding speedups.
# Either gcc or clang can be used to build; it can chosen through the CC variable.

function printRunComm(){
    ## Print the command    
    printf "\n$ $@\n"
    ## Run the command
    $@
}

# Check that all required commands are available
for cmd in ${CC:-cc} make exec printf make grep cut tr bc pwdirectives; do
    command -v $cmd >/dev/null 2>&1 || { printf >&2 "$cmd is required but it's not installed. Aborting.\n"; exit 1; }
done

# Set locate for decimal point separator and disable stderr output to filter out compiler warnings
export LC_NUMERIC="en_US.UTF-8"
exec 2> /dev/null

# Print CPU information if the command is available
if command -v lscpu >/dev/null 2>&1; then
    lscpu
    printf "\n"
fi

# Print compiler information
${CC:-cc} --version
printf "\n"

ATMUX_OMP_MULTI_TARGET="atmux-pwa-omp-multi"
ATMUX_OMP_MULTI_FILE="$ATMUX_OMP_MULTI_TARGET.c"

CANNY_OMP_MULTI_TARGET="canny-pwa-omp-multi"
CANNY_OMP_MULTI_FILE="$CANNY_OMP_MULTI_TARGET.c"

COULOMB_OMP_MULTI_TARGET="coulomb-pwa-omp-multi"
COULOMB_OMP_MULTI_FILE="$COULOMB_OMP_MULTI_TARGET.c"

HACC_OMP_MULTI_TARGET="main-pwa-omp-multi"
HACC_OMP_MULTI_FILE="$HACC_OMP_MULTI_TARGET.c"

MATMUL_OMP_MULTI_TARGET="main-pwa-omp-multi"
MATMUL_OMP_MULTI_FILE="$MATMUL_OMP_MULTI_TARGET.c"

NPB_CG_OMP_MULTI_TARGET="cg-pwa-omp-multi"
NPB_CG_OMP_MULTI_FILE="$NPB_CG_OMP_MULTI_TARGET.c"

PI_OMP_MULTI_TARGET="pi-pwa-omp-multi"
PI_OMP_MULTI_FILE="$PI_OMP_MULTI_TARGET.c"

printf "##################################################\n"
printf "Cleaning ... \n"
printf "##################################################\n"
make clean --no-print-directory -C ATMUX/serial
make clean --no-print-directory -C ATMUX/serial FILE=$ATMUX_OMP_MULTI_FILE TARGET=$ATMUX_OMP_MULTI_TARGET 
rm -f "ATMUX/serial/$ATMUX_OMP_MULTI_FILE"
make clean --no-print-directory -C CANNY/serial
make clean --no-print-directory -C CANNY/serial FILE=$CANNY_OMP_MULTI_FILE TARGET=$CANNY_OMP_MULTI_TARGET 
rm -f "CANNY/serial/$CANNY_OMP_MULTI_FILE"
make clean --no-print-directory -C COULOMB/serial
make clean --no-print-directory -C COULOMB/serial FILE=$COULOMB_OMP_MULTI_FILE TARGET=$COULOMB_OMP_MULTI_TARGET  
rm -f "COULOMB/serial/$COULOMB_OMP_MULTI_FILE"
make clean --no-print-directory -C HACCmk/serial
make clean --no-print-directory -C HACCmk/serial FILE=$HACC_OMP_MULTI_FILE TARGET=$HACC_OMP_MULTI_TARGET 
rm -f "HACCmk/serial/$HACC_OMP_MULTI_FILE"
make clean --no-print-directory -C MATMUL/serial
make clean --no-print-directory -C MATMUL/serial FILE=$MATMUL_OMP_MULTI_FILE TARGET=$MATMUL_OMP_MULTI_TARGET 
rm -f "MATMUL/serial/$MATMUL_OMP_MULTI_FILE"
make clean --no-print-directory -C NPB_CG/serial
make clean --no-print-directory -C NPB_CG/serial FILE=$NPB_CG_OMP_MULTI_FILE TARGET=$NPB_CG_OMP_MULTI_TARGET
rm -f "NPB_CG/serial/CG/$NPB_CG_OMP_MULTI_FILE"
make clean --no-print-directory -C PI/serial
make clean --no-print-directory -C PI/serial FILE=$PI_OMP_MULTI_FILE TARGET=$PI_OMP_MULTI_TARGET 
rm -f "PI/serial/$PI_OMP_MULTI_FILE"

printf "\n\n"

printf "##################################################\n"
printf "Executing 1/7: ATMUX... \n"
printf "##################################################\n"

printf "\nStep 1: Executing serial code ..................."
ATMUX_SERIAL=$(make run -C ATMUX/serial | grep "time (s)=" | cut -b 11-)
printf " done"

printf "\nStep 2: Optimizing code with multithreading ..... done\n"

printRunComm "pwdirectives --omp multi --explicit-privatization y ATMUX/serial/atmux.c:atmux:22:5 \
 --target-compiler-cc ${CC:-cc} -o ATMUX/serial/$ATMUX_OMP_MULTI_FILE --brief -- -I ATMUX/serial/lib/"
sed -i 's/\/\* y start \*\//0/g' "ATMUX/serial/$ATMUX_OMP_MULTI_FILE"
sed -i 's/\/\* y length \*\//n/g' "ATMUX/serial/$ATMUX_OMP_MULTI_FILE"

printf "\nStep 3: Executing optimized code ................"
ATMUX_OMP_MULTI=$(make run -C ATMUX/serial FILE=$ATMUX_OMP_MULTI_FILE TARGET=$ATMUX_OMP_MULTI_TARGET | grep "time (s)=" | cut -b 11-)
printf " done\n\n\n"

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 2/7: CANNY... \n"
printf "##################################################\n"

printf "\nStep 1: Executing serial code ..................."
CANNY_SERIAL=$(make run -C CANNY/serial | grep "Total time:" | cut -b 13-)
printf " done"

printf "\nStep 2: Optimizing code with multithreading ..... done\n"

printRunComm "pwdirectives --omp multi CANNY/serial/canny.c:gaussian_smooth:492:4 \
 --target-compiler-cc ${CC:-cc} -o CANNY/serial/$CANNY_OMP_MULTI_FILE --brief"

printRunComm "pwdirectives --omp multi CANNY/serial/$CANNY_OMP_MULTI_FILE:gaussian_smooth:474:4 \
 --target-compiler-cc ${CC:-cc} -i --brief"


printf "\nStep 3: Executing optimized code ................"
CANNY_OMP_MULTI=$(make run -C CANNY/serial FILE=$CANNY_OMP_MULTI_FILE TARGET=$CANNY_OMP_MULTI_TARGET | grep "Total time:" | cut -b 13-)
printf " done\n\n\n"

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 3/7: COULOMB... \n"
printf "##################################################\n"

printf "\nStep 1: Executing serial code ..................."
COULOMB_SERIAL=$(make run -C COULOMB/serial | grep "time (s)=" | cut -b 11-)
printf " done"

printf "\nStep 2: Optimizing code with multithreading ..... done\n"

printRunComm "pwdirectives --omp multi COULOMB/serial/coulomb.c:coulomb:26:2 \
 --target-compiler-cc ${CC:-cc} -o COULOMB/serial/$COULOMB_OMP_MULTI_FILE --brief"

printf "\nStep 3: Executing optimized code ................"
COULOMB_OMP_MULTI=$(make run -C COULOMB/serial FILE=$COULOMB_OMP_MULTI_FILE TARGET=$COULOMB_OMP_MULTI_TARGET  | grep "time (s)=" | cut -b 11-)
printf " done\n\n\n"

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 4/7: HACCmk... \n"
printf "##################################################\n"

printf "\nStep 1: Executing serial code ..................."
HACC_SERIAL=$(make run -C HACCmk/serial | grep "Kernel elapsed time, s:" | tr -s ' ' | cut -d ' ' -f 5)
printf " done"

printf "\nStep 2: Optimizing code with multithreading ..... done\n"

printRunComm "pwdirectives --omp multi --config HACCmk/serial/pw.json HACCmk/serial/main.c:main:132:7 
 --target-compiler-cc ${CC:-cc} -o HACCmk/serial/$HACC_OMP_MULTI_FILE --brief"

printf "\nStep 3: Executing optimized code ................"
HACC_OMP_MULTI=$(make run -C HACCmk/serial FILE=$HACC_OMP_MULTI_FILE TARGET=$HACC_OMP_MULTI_TARGET | grep "Kernel elapsed time, s:" | tr -s ' ' | cut -d ' ' -f 5)
printf " done\n\n\n"

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 5/7: MATMUL... \n"
printf "##################################################\n"

printf "\nStep 1: Executing serial code ..................."
MATMUL_SERIAL=$(make run -C MATMUL/serial | grep "time (s)=" | cut -b 11-)
printf " done"

printf "\nStep 2: Optimizing code with multithreading ..... done\n"

printRunComm " pwdirectives --omp multi MATMUL/serial/main.c:matmul:15:5 \
 --target-compiler-cc ${CC:-cc} -o MATMUL/serial/$MATMUL_OMP_MULTI_FILE --brief -- -I MATMUL/serial/include"

printf "\nStep 3: Executing optimized code ................"
MATMUL_OMP_MULTI=$(make run -C MATMUL/serial FILE=$MATMUL_OMP_MULTI_FILE TARGET=$MATMUL_OMP_MULTI_TARGET | grep "time (s)=" | cut -b 11-)
printf " done\n\n\n"

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 6/7: NPB_CG... \n"
printf "##################################################\n"

printf "\nStep 1: Executing serial code ..................."
NPB_CG_SERIAL=$(make run -C NPB_CG/serial | grep "Time in seconds" | tr -s ' ' | cut -d ' ' -f 6)
printf " done"

printf "\nStep 2: Optimizing code with multithreading ..... done\n"

printRunComm "pwdirectives --omp multi NPB_CG/serial/CG/cg.c:conj_grad:458:5 \
 --target-compiler-cc ${CC:-cc} -o NPB_CG/serial/CG/$NPB_CG_OMP_MULTI_FILE --brief -- -I NPB_CG/serial/common"

printf "\nStep 3: Executing optimized code ................"
NPB_CG_OMP_MULTI=$(make run -C NPB_CG/serial FILE=$NPB_CG_OMP_MULTI_FILE TARGET=$NPB_CG_OMP_MULTI_TARGET | grep "Time in seconds" | tr -s ' ' | cut -d ' ' -f 6)
printf " done\n\n\n"

# ---------------------------------------------------------
printf "##################################################\n"
printf "Executing 7/7: PI... \n"
printf "##################################################\n"

printf "\nStep 1: Executing serial code ..................."
PI_SERIAL=$(make run -C PI/serial | grep "time (s)=" | cut -b 11-)
printf " done"

printf "\nStep 2: Optimizing code with multithreading ..... done\n"

printRunComm "pwdirectives --omp multi PI/serial/pi.c:main:31:5 \
 --target-compiler-cc ${CC:-cc} -o PI/serial/$PI_OMP_MULTI_FILE --brief"


printf "\nStep 3: Executing optimized code ................"
PI_OMP_MULTI=$(make run -C PI/serial FILE=$PI_OMP_MULTI_FILE TARGET=$PI_OMP_MULTI_TARGET | grep "time (s)=" | cut -b 11-)
printf " done\n\n\n"

printf "##################################################\n"
printf "Benchmarking optimized codes\n"
printf "##################################################\n"


printf "\nCode           \tOriginal \tOptimized  \tSpeedup\n"
printf "===============\t========\t=========\t==============\n"

printRow() { # Params: Code, Serial, Multi
    local SPEEDUP=$(bc -l <<< "$2/$3")
    local REDUCTION=$(bc -l <<< "($2-$3)/$2*100")
    local EXTRA_TAB="" && (( ${#1} < 8 )) && EXTRA_TAB="\t"
    LC_NUMERIC="en_US.UTF-8" printf "%s\t$EXTRA_TAB%.2f\t$EXTRA_TAB%.2f\t$EXTRA_TAB%.2f%% (%.2fx)\n" $1 $2 $3 $REDUCTION $SPEEDUP
}

printRow "ATMUX" $ATMUX_SERIAL $ATMUX_OMP_MULTI
printRow "CANNY" $CANNY_SERIAL $CANNY_OMP_MULTI
printRow "COULOMB" $COULOMB_SERIAL $COULOMB_OMP_MULTI
printRow "HACCmk" $HACC_SERIAL $HACC_OMP_MULTI
printRow "MATMUL" $MATMUL_SERIAL $MATMUL_OMP_MULTI
printRow "NPB_CG" $NPB_CG_SERIAL $NPB_CG_OMP_MULTI
printRow "PI" $PI_SERIAL $PI_OMP_MULTI
