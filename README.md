# Codee performance demos

This repository serves to showcase the performance gains achieved with the help of Codee. It provides scripts to benchmark well-known codes using the following software performance optimizations:
* Vectorization and memory optimizations (Codee¹ installation is required).
* Multi-threading (Codee¹ installation is required)

*¹ Make sure that you have the latest Codee version. Please, [`contact us at codee.com`](https://www.codee.com/contact-us/).*

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
Algorithm           Original            Optimized           Speedup             
================    ============        ============        =======             
AES-XTS-128         643489 KiB/s        776161 KiB/s        20.62%
AES-XTS-256         548813 KiB/s        657782 KiB/s        19.86%
AES-CBC-128         696037 KiB/s        999719 KiB/s        43.63%
AES-CBC-192         639160 KiB/s        895191 KiB/s        40.06%
AES-CBC-256         597265 KiB/s        793017 KiB/s        32.77%
AES-CMAC-128        697767 KiB/s        890682 KiB/s        27.65%
AES-CMAC-192        650263 KiB/s        817205 KiB/s        25.67%
AES-CMAC-256        605284 KiB/s        753294 KiB/s        24.45%
AES-CMAC-PRF-128    701772 KiB/s        898686 KiB/s        28.06%
ARIA-CBC-128        156054 KiB/s        165035 KiB/s        5.76%
ARIA-CBC-192        137057 KiB/s        145434 KiB/s        6.11%
ARIA-CBC-256        119480 KiB/s        127936 KiB/s        7.08%
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
