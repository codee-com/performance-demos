# Codee performance demos

This repository serves to showcase the performance gains achieved with the help of Codee. It provides scripts to benchmark well-known codes using the following software performance optimizations:
* Vectorization and memory optimizations (Codee installation is required).
* Multi-threading (Codee installation is optional)
* Offloading (Codee installation is optional)

## Quick start: Take advantage of vectorization and memory optimizations with Codee
This is the recommended way to get started with Codee. It takes advantage of Codee’s “auto” mode, which identifies vectorization and memory optimization opportunities that complement the capabilities provided by the compiler and annotates the source code with compiler pragmas that enable vectorization explicitly. The following real-world codes are used:
* [MbedTLS](https://tls.mbed.org/), an open-source portable and flexible TLS C library.

Just follow these simple steps on your computer:
* First, clone this repository as usual.
* Second, run the 7-step script [`benchmark-mbedTLS-vector.sh`](benchmark-mbedTLS-vector.sh), to measure the performance gain using OpenMP vectorization on your CPU.
  * To run the script, it is necessary to have this software installed in the system: `git`, `cmake`, `ninja`, `printf`.
  * The script handles the download of MbedTLS 3.1.0 (a internet connection is required to download MbedTLS for the first time).
  * A valid Codee license and package is required. Please, [`contact us at codee.com`](https://www.codee.com/contact-us/).
* Third, take a look at the information displayed in the screen, as the script invokes Codee to get an screening report of the project, uses Codee’s “auto” mode to annotate the source code with compiler pragmas and verifies the correctness and speedup of the auto-generate optimized code.

The following output corresponds to an execution on a laptop running Ubuntu 21.04 and equipped with an AMD Ryzen 4800H CPU and 16 GBs of RAM:

```
$ ./benchmark-mbedTLS-vector.sh
```
```
...
##################################################
7/7. Verifying the speedup of the vectorized version ...
##################################################
Press enter to continue


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
aes_xts algorithm
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  AES-XTS-128              :     634280 KiB/s,          4 cycles/byte
  AES-XTS-256              :     548513 KiB/s,          5 cycles/byte

original done
************************************************************

  AES-XTS-128              :     782770 KiB/s,          3 cycles/byte
  AES-XTS-256              :     657988 KiB/s,          4 cycles/byte

vectorized done

...

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

The following output corresponds to an execution on a laptop running Ubuntu 21.04 and equipped with an AMD Ryzen 4800H CPU and 16 GBs of RAM:

```
$ ./benchmark-omp-multi.sh
...
Code            Serial  Multi   Speedup Time reduced
=============== ======= ======= ======= ============
ATMUX           0.30    0.12    2.48x   59.68%
CANNY           11.83   6.55    1.81x   44.63%
COULOMB         8.45    1.11    7.63x   86.90%
HACCmk          38.17   12.42   3.07x   67.45%
MATMUL          5.49    1.04    5.28x   81.07%
NPB_CG          34.99   10.21   3.43x   70.82%
PI              3.33    0.46    7.30x   86.30%
```


## Quick start: Take advantage of offloading with Codee
Codee also provides capabilities to take advantage of multi-threading in modern CPUs. The following real-world codes are used:
* COULOMB: Computation of the electric potential created by a set of charges in an n x n 2D plane.
* MATMUL: Matrix multiplication.
* PI: PI number approximation.

Just follow these simple steps on your computer:
* First, clone this repository as usual.
* Second, run the `benchmark-acc-offload.sh` script to measure performance gain using OpenACC offloading on your GPU.
  * To run the script, it is necessary to have this software installed in the system: compilers `nvc` to build OpenACC offloadding versions; `unzip` or `sed` to run and benchmark the example codes.

A similar output would be obtained from the scripts, assuming you have properly setup the GPU software stack on your computer.

