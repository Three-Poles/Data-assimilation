ComDA Version 1.0

Name: Common Software for Nonlinear and Non-Gaussian Land Data Assimilation

Developer: Feng Liu, Liangxu Wang, Xin Li and Chunlin Huang

Email: liufeng@lzb.ac.cn (Feng Liu), wangliangxu@shnu.edu.cn (Liangxu Wang), xinli@itpcas.ac.cn (Xin Li), huangcl@lzb.ac.cn (Chunlin Huang).
First available: May 2019

Required hardware: Any computer with a multithread CPU that runs the Linux (Ubuntu with version 10.04 or higher is better) operating system. 

Required software: main program language is standard C++ (ANSI 98). 

Components libraries include IT++ (http://itpp.sourceforge.net/), LAPACK (http://www.netlib.org/lapack/) and Armadillo (http://arma.sourceforge.net/), OpenMP (http://www.openmp.org) and MPI (http://www.mpich.org/).

Cost: ComDA is freely available and can be downloaded from the GitHub repository (https://github.com/uniliufeng/ComDA).

References:
Liu F, Wang L, Li X, Huang C. 2019. ComDA: A Common Software for Nonlinear and Non-Gaussian Land Data Assimilation

Introducation:
ComDA is to achieve a fast, easy-to-use, and multidisciplinary application-oriented assimilation platform. ComDA integrates many algorithms (including diverse Kalman and particle filters) and multiple models and observation operators (e.g., CoLM, SiB2 and AIEM, Q/h), and provides the general interfaces for accepting more operators. Using mixed-language programming and parallel computing technologies (OpenMP, MPI and CUDA), ComDA can assimilate various land surface variables and remote sensing observations. ComDA can be applied in multidisciplinary data assimilation studies.

Examples (running the following commond on the terminal):

1. Regular test (EnKF+Lorenz)
g++ -I../include enkf_lorenz_arma.cpp ../src/model/lorenz.cpp ../src/model/model.cpp ../src/util/time.cpp ../src/da/ensemblekalmanfilter.cpp ../src/da/filter.cpp -I../external/dSFMT  -DDSFMT_MEXP=19937 ../external/dSFMT/dSFMT.c ../src/util/exception.cpp ../src/util/random.cpp -larmadillo -o test

2. Parallel computing test (mpich is necessary, enkf & colm & mpi)
# compiling
mpic++ -I./ -I../include colm_da_mpi.cpp ../src/model/commonlandmodel.cpp ../src/util/exception.cpp ../src/util/time.cpp ../src/util/landgrid.cpp ../src/model/model.cpp cldas_mpi.cpp -o colm/colmdampi -I../external/dSFMT  -DDSFMT_MEXP=19937 ../external/dSFMT/dSFMT.c ../src/obs/radiancetransfermodel.cpp ../src/obs/qhmodel.cpp ../src/util/random.cpp ../src/da/enkf.cpp ../src/util/permittivity.cpp -larmadillo -g
# running
mpiexec -n 4 -f /home/mpi_share/mpi_config_file ./colm/colmdampi
