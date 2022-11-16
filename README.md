# Codee performance demos

This repository serves to showcase the performance gains achieved with the help of Codee. It provides scripts to benchmark well-known codes using the following software performance optimizations:
* Vectorization and memory optimizations (Codee installation is required).
* Multi-threading (Codee installation is optional)

## Quick start: Take advantage of vectorization and memory optimizations with Codee
This is the recommended way to get started with Codee. It takes advantage of Codee’s “auto” mode, which identifies vectorization and memory optimization opportunities that complement the capabilities provided by the compiler and annotates the source code with compiler pragmas that enable vectorization explicitly. The following real-world codes are used:
* [MbedTLS](https://tls.mbed.org/), an open-source portable and flexible TLS C library.

Just follow these simple steps on your computer:
* First, clone this repository as usual.
* Second, run the 7-step script [`benchmark-mbedTLS-vector.sh`](benchmark-mbedTLS-vector.sh), to measure the performance gain using OpenMP vectorization on your CPU.
  * To run the script, it is necessary to have this software installed in the system: `git`, `cmake`, `ninja`, `printf`.
  * The script handles the download of MbedTLS 3.1.0 (a internet connection is required to download MbedTLS for the first time).
  * A valid Codee license and package is required. Please, [`contact us at codee.com`](https://www.codee.com/contact-us/).
* Third, take a look at the information displayed in the screen, as the script invokes Codee to get an screening report of the project, uses Codee’s “auto” mode to annotate the source code with compiler pragmas and verifies the correctness and speedup of the auto-generated optimized code.

The following output corresponds to an execution on a laptop running Ubuntu 21.04 and equipped with an AMD Ryzen 4800H CPU and 16 GBs of RAM, using gcc 10.3:

```
$ ./benchmark-mbedTLS-vector.sh
...
Algorithm           Original          Optimized         Speedup             
================    ============      ============      =======             
AES-XTS-128         613506 KiB/s      774841 KiB/s      26.30%              
AES-XTS-256         542305 KiB/s      652312 KiB/s      20.29%              
AES-CMAC-128        660392 KiB/s      887986 KiB/s      34.46%              
AES-CMAC-192        601832 KiB/s      822032 KiB/s      36.59%              
AES-CMAC-256        556624 KiB/s      738438 KiB/s      32.66%              
AES-CMAC-PRF-128    648914 KiB/s      874481 KiB/s      34.76%              
ARIA-CBC-128        152955 KiB/s      159800 KiB/s      4.48%              
ARIA-CBC-192        132988 KiB/s      138426 KiB/s      4.09%              
ARIA-CBC-256        119809 KiB/s      122843 KiB/s      2.53%  
```


## Quick start: Take advantage of multi-threading with Codee
Codee also provides capabilities to take advantage of multi-threading in modern CPUs. The following real-world codes are used:
* ATMUX: Sparse matrix-vector multiplication.
* CANNY: Image edge detection.
* COULOMB: Computation of the electric potential created by a set of charges in an n x n 2D plane.
* HACCmk: Short force evaluation kernel of the HACC application.
* MATMUL: Matrix multiplication.
* NPB CG: Conjugate Gradient, irregular memory access and communication-
* PI: PI number approximation.

Just follow these simple steps on your computer:
* First, clone this repository as usual.
* Second, run the `benchmark-omp-multi.sh` script to measure performance gain using OpenMP multi-threading on your CPU.
  * To run the script, it is necessary to have this software installed in the system: compilers `gcc` or `clang` to build OpenMP multi-threading versions; `unzip` or `sed` to run and benchmark the example codes.
  * A valid Codee license and package is required. Please, [`contact us at codee.com`](https://www.codee.com/contact-us/).

The following output corresponds to an execution on a laptop running Ubuntu 21.04 and equipped with an AMD Ryzen 4800H CPU and 16 GBs of RAM:

```
$ ./benchmark-omp-multi.sh
...
Code           	Original    Optimized    Speedup
===============	========    =========    ==============
ATMUX           0.29        0.13         53.93% (2.17x)
CANNY           11.72       6.99         40.32% (1.68x)
COULOMB         8.35        1.07         87.22% (7.82x)
HACCmk          36.86       10.74        70.86% (3.43x)
MATMUL          6.36        1.24         80.55% (5.14x)
NPB_CG          44.33       20.25        54.32% (2.19x)
PI              3.29        0.46         86.11% (7.20x)
```
