# Codee performance demos

This repository serves to showcase the performance gains achieved with the help
of Codee.
It provides scripts to benchmark well-known codes using the following software
performance optimizations:
* Single-core optimizations without vectorization (Codee¹ installation is required).
* Vectorization (Codee¹ installation is required).
* Multi-threading (Codee¹ installation is required)

*¹ Make sure that you have the latest Codee version. Please,
[`contact us at codee.com`](https://www.codee.com/contact-us/).*

## Quick start: Take advantage of single-core optimizations with Codee
Codee provides capabilities to take advantage of single-core optimizations in
modern CPUs.
The following real-world code is used:
* MATMUL: Matrix multiplication.

Just follow these simple steps on your computer:
* First, clone this repository as usual.
* Second, run the `benchmark-single-core-optimizations.sh` script to measure
performance gain using single-core optimizations.
  * The script support multiple setups using environment variables:
    * Use `$CC` to set the desired compiler
    * Use `$CODEE_FLAGS` if you need extra codee flags (i.e:--brief)
    * Use `$RUNS_WARMUP` to set the number of warm up runs for each project (default to 0)
    * Use `$RUNS` to set the number of effective runs for each project (default to 2)
  * To run the script, it is necessary to have this software installed in the system:
  compilers `gcc`, `clang` or `icc/icx` to build the codes; `git`, `cmake`,
  `ninja` or `makefile`, `printf` to run and benchmark the example codes.
  * A valid Codee license and package is required. Please,
  [`contact us at codee.com`](https://www.codee.com/contact-us/).

The following output corresponds to an execution on a laptop running Ubuntu
20.04 and equipped with an AMD Ryzen 4800H CPU and 16 GBs of RAM, using gcc 9.4,
RUNS_WARMUP=0 and RUNS=5:
```
$ CC=gcc-9 RUNS_WARMUP=0 RUNS=5 ./benchmark-single-core-optimizations.sh
...
Code           	Original  Optimized Speedup
===============	========  =========	==============
MATMUL          7.33      2.22      69.66% (3.30x)

```

## Quick start: Take advantage of vectorization with Codee
Codee provides capabilities to take advantage of vectorization. The following
real-world code are used:
* [MbedTLS](https://tls.mbed.org/), an open-source portable and flexible TLS C library.

Just follow these simple steps on your computer:
* First, clone this repository as usual.
* Second, run the 6-step script [`benchmark-mbedTLS-vector.sh`](benchmark-mbedTLS-vector.sh),
to measure the performance gain using OpenMP vectorization on your CPU.
  * The script support multiple setups using environment variables:
    * Use `$CC` to set the desired compiler
    * Use `$CODEE_FLAGS` if you need extra codee flags (i.e:--brief)
    * Use `$RUNS_WARMUP` to set the number of warm up runs for each algorithm (default to 0)
    * Use `$RUNS` to set the number of effective runs for each project (default to 2)
  * To run the script, it is necessary to have this software installed in the system:
  compilers `gcc`, `clang` or `icc/icx` to build OpenMP SIMD, `git`, `cmake`,
  `ninja` or `makefile`, `printf` to run and benchmark the example codes.
  * The script handles the download of MbedTLS 3.1.0 (a internet connection is
  required to download MbedTLS for the first time).
  * A valid Codee license and package is required. Please,
  [`contact us at codee.com`](https://www.codee.com/contact-us/).
* Third, take a look at the information displayed in the screen, as the script
invokes Codee to get an screening report of the project, uses Codee’s “auto”
mode to annotate the source code with compiler pragmas and verifies the
correctness and speedup of the auto-generated optimized code.

The following output corresponds to an execution on a laptop running Ubuntu
20.04 and equipped with an AMD Ryzen 4800H CPU and 16 GBs of RAM, using gcc 9.4,
RUNS_WARMUP=0 and RUNS=5:

```
$ CC=gcc-9 RUNS_WARMUP=0 RUNS=5 ./benchmark-mbedTLS-vector.sh
...
Code                Original            Optimized           Speedup
================    ============        ============        =======
AES-XTS-128         617065 KiB/s        768781 KiB/s        24.59%
AES-XTS-256         549189 KiB/s        647942 KiB/s        17.98%
AES-CBC-128         692068 KiB/s        994648 KiB/s        43.72%
AES-CBC-192         641447 KiB/s        892314 KiB/s        39.11%
AES-CBC-256         597373 KiB/s        806997 KiB/s        35.09%
AES-CMAC-128        684999 KiB/s        907921 KiB/s        32.54%
AES-CMAC-192        636645 KiB/s        826985 KiB/s        29.90%
AES-CMAC-256        601418 KiB/s        749999 KiB/s        24.71%
AES-CMAC-PRF-128    683107 KiB/s        902479 KiB/s        32.11%
ARIA-CBC-128        156077 KiB/s        166914 KiB/s        6.94%
ARIA-CBC-192        137090 KiB/s        145931 KiB/s        6.45%
ARIA-CBC-256        122725 KiB/s        129255 KiB/s        5.32%
```


## Quick start: Take advantage of multi-threading with Codee
Codee also provides capabilities to take advantage of multi-threading in modern
CPUs. The following real-world codes are used:
* ATMUX: Sparse matrix-vector multiplication.
* CANNY: Image edge detection.
* COULOMB: Computation of the electric potential created by a set of charges in
an n x n 2D plane.
* HACCmk: Short force evaluation kernel of the HACC application.
* MATMUL: Matrix multiplication.
* NPB CG: Conjugate Gradient, irregular memory access and communication-
* PI: PI number approximation.

Just follow these simple steps on your computer:
* First, clone this repository as usual.
* Second, run the `benchmark-omp-multi.sh` script to measure performance gain
using OpenMP multi-threading on your CPU.
  * The script support multiple setups using environment variables:
    * Use `$CC` to set the desired compiler
    * Use `$CODEE_FLAGS` if you need extra codee flags (i.e:--brief)
    * Use `$RUNS_WARMUP` to set the number of warm up runs for each project (default to 0)
    * Use `$RUNS` to set the number of effective runs for each project (default to 2)
  * To run the script, it is necessary to have this software installed in the
  system: compilers `gcc`, `clang` or `icc/icx` to build OpenMP multi-threading
  versions; `unzip`, `sed`, `git`, `cmake`, `ninja` or `makefile`, `printf` to
  run and benchmark the example codes.
  * A valid Codee license and package is required. Please,
  [`contact us at codee.com`](https://www.codee.com/contact-us/).

The following output corresponds to an execution on a laptop running Ubuntu
20.04 and equipped with an AMD Ryzen 4800H CPU and 16 GBs of RAM, using gcc 9.4,
RUNS_WARMUP=0 and RUNS=5:

```
$ CC=gcc-9 RUNS_WARMUP=0 RUNS=5 ./benchmark-omp-multi.sh
...
Code           	Original  Optimized Speedup
===============	========  =========	==============
ATMUX           0.79      0.19      76.04% (4.17x)
CANNY           12.12     6.83      43.63% (1.77x)
COULOMB         8.32      1.06      87.25% (7.84x)
HACCmk          35.88     7.91      77.96% (4.54x)
MATMUL          5.27      0.98      81.33% (5.35x)
NPB_CG          34.43     9.70      71.84% (3.55x)
PI              3.28      0.43      86.91% (7.64x)

```
