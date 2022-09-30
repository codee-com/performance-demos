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

The following output corresponds to an execution on a laptop running Ubuntu 21.04 and equipped with an AMD Ryzen 4800H CPU and 16 GBs of RAM, using gcc 10.3:

```
$ ./benchmark-mbedTLS-vector.sh
```
```
...
##################################################
4/5. Verifying the correctness ...
##################################################
Press enter to continue

aes_xts original algorithm
PASSED (47 / 47 tests (0 skipped))

cmac original algorithm
PASSED (19 / 19 tests (0 skipped))

aes_xts vectorized algorithm
PASSED (47 / 47 tests (0 skipped))

cmac vectorized algorithm
PASSED (19 / 19 tests (0 skipped))

Step 4 done.
=============================================================

##################################################
5/5. Verifying the speedup ...
##################################################

Press enter to continue
original done
vectorized done

Step                   	Without Codee		With Codee
=====================	=============		==========
CI: SS: Clone        	29.641 s 		29.641 s
CI: BS: pwdirectives 	----- s 		0.196 s
CI: BS: make all     	8.892 s 		8.922 s
CI: BS: Test aes/cmac	0.007 s 		0.006 s
CI: DS: Benchmark    	6.015 s 		6.012 s

Algorithm       	Original 	Vectorized 	Speedup
================	========	==========	=======
AES-XTS-128 	    564781		777016		37.58%
AES-XTS-256         529037		653561		23.54%
AES-CMAC-128		684210		910813		33.12%
AES-CMAC-192		633934		819417		29.26%
AES-CMAC-256		588439		753144		27.99%
AES-CMAC-PRF-128	681805		805037		18.07%


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

