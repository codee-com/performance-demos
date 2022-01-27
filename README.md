# Parallelware Analyzer performance demos

This repository serves to showcase the performance gains achieved with the help of Parallelware Analyzer.

## Quick start for CPUs

Just follow this simple steps on your computer:
- First, clone this repository as usual.
- Second, run the `benchmark-omp-multi.sh` script to measure performance gain using OpenMP multi-threading on your CPU.
- Third, take a look at the output, which should look as follows:

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

Note that your computer must meet the following technical requirements: 
- Compilers: `gcc` or `clang` to build OpenMP multi-threading versions.
- Other tools: `unzip` or `sed` to run and benchmark the examples codes.

## Structure of this repository

The top-level folder of the repository is organized as follows. Different code examples from several scientific and engineering domains are benchmarked. There is one folder for each example code:
- ATMUX: Sparse matrix-vector multiplication.
- CANNY: Image edge detection.
- COULOMB: Computation of the electric potential created by a set of charges in an n x n 2D plane.
- HACCmk: Short force evaluation kernel of the HACC application.
- MATMUL: Matrix multiplication.
- NPB CG: Conjugate Gradient, irregular memory access and communication-
- PI: PI number approximation.

Inside each one of them, the `serial` subfolder corresponds to the original sequential (ie. non-parallelized) code. Additionally, one or more subfolders corresponding to performance-optimized versions are provided. The `pwa-omp-multi` folder corresponds to an OpenMP multi-threaded version generated by Parallelware Analyzer, which requires an OpenMP compiler like `gcc` or `clang` properly installed. The `pwa-acc-offload` folder corresponds to an OpenACC GPU offloading version generated by Parallelware Analyzer, which requires and OpenACC compiler like `nvc` properly installed. 

The top-level folder also contains a `Makefile` to build, run and even invoke Parallelware Analyzer to create the parallel versions of the code:
- `make` and `make run`: will build and run all the codes.
- `make build`: will just build the codes without running them.
- `make parallelize`: will invoke Parallelware Analyzer to create the same parallel versions provided. These will be generated in the top folder of each example having the same suffix as the corresponding subfolder containing the already parallelized provided version.
You can also use those same commands inside any of the subfolders to run only a specific example or version.

Finally, the top-level folder also provides scripts to automate the benchmarking of the codes included in this repository on your computer:
- Run the `benchmark-omp-multi.sh` script to benchmark the OpenMP multi-threaded versions.
- Run the `benchmark-acc-gpu.sh` script to benchmark the OpenACC GPU offloading versions.
- Invoke `make parallelize` to automatically generate the parallel versions using Parallelware Analyzer. (Note that this is not required as they are already in the repository, this is provided so you can reproduce how they were created.)

Overtime, this repository will be updated with more example codes representative of different scientific and engineering domains.


## Example output

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
