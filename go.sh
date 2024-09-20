#!/bin/bash

echo ======================================================================================================
echo ======================================================================================================
echo ======================================================================================================

RCCL_REPO=~/rccl
TEST_REPO=~/rccl-tests
RCCL_HOME=${RCCL_REPO}/build/release
#RCCL_HOME=/opt/rocm
#MPI_PATH=/home/nilenegi/mpich/install
MPI_PATH=/home/nilenegi/ompi/install
PATH=/home/cderochi/cmake_install/bin:${PATH}

build=0
run=0
no_lib=0
perf=0
unit=0
print_debug=0
use_make=0
opt=0
while getopts 'brnpudmf:' flag; do
    case "${flag}" in
        b) build=1;;
        r) run=1;;
        n) no_lib=1;;
        p) perf=1;;
        u) unit=1;;
        d) print_debug=1;;
        m) use_make=1;;
        f) opt=${OPTARG};;
    esac
done

if [ $build == 1 ]; then
    if [ $no_lib == 0 ]; then
        echo ======================================================================================================
        echo Building RCCL...
        echo ======================================================================================================
        cd ${RCCL_REPO}/
        if [ $use_make == 0 ]; then
            flags="-lj64"
            if [ $unit == 1 ]; then
                flags="${flags} -t" # --openmp-test-enable"
            fi
            ./install.sh ${flags}
        fi
        cd ${RCCL_HOME}/
        if [ $use_make == 1 ]; then
            make -j$(nproc)
        fi
        #mkdir -p lib
        #mkdir -p lib2
        #cp ./librccl.so* ./lib/
        #cp ./libmscclpp_nccl.so* ./lib2/
    fi

    if [ $perf == 1 ]; then
        echo ======================================================================================================
        echo Building perf tests...
        echo ======================================================================================================
        cd ${TEST_REPO}/
        if [ $use_make == 0 ]; then
            ./install.sh -m --mpi_home ${MPI_PATH} --rccl_home ${RCCL_HOME}
        else
            cd build/
            make NCCL_HOME=${RCCL_HOME} CUSTOM_RCCL_LIB=${RCCL_HOME}/librccl.so MPI=1 MPI_HOME=${MPI_PATH} -j$(nproc)
        fi
    fi
fi

if [ $run == 1 ]; then
    export NCCL_DEBUG=VERSION
    if [ $print_debug == 1 ]; then
        export NCCL_DEBUG=INFO
        export NCCL_DEBUG_SUBSYS=INIT,COLL
        export UT_VERBOSE=1
    fi

    if [ $perf == 1 ]; then
        echo ======================================================================================================
        echo Running perf tests...
        echo ======================================================================================================
        cd ${TEST_REPO}/build
        #cd /home/nusislam/rccl-test-new/rccl-tests/build
        export PATH=${MPI_PATH}/bin:${PATH}
        #export LD_LIBRARY_PATH_1=${MPI_PATH}/lib:${RCCL_HOME}/lib:/opt/rocm/lib:${LD_LIBRARY_PATH}
        #export LD_LIBRARY_PATH_2=${MPI_PATH}/lib:${RCCL_HOME}/lib2:/opt/rocm/lib:${LD_LIBRARY_PATH}
        export LD_LIBRARY_PATH=${MPI_PATH}/lib:${RCCL_HOME}:${LD_LIBRARY_PATH}
        #export LD_PRELOAD_1=${RCCL_HOME}/lib/librccl.so:/opt/rocm/lib/libhsa-runtime64.so.1:${LD_PRELOAD}
        #export LD_PRELOAD_2=${RCCL_HOME}/lib2/libmscclpp_nccl.so:${LD_PRELOAD}
        #export LD_PRELOAD=${RCCL_REPO}/ext/mscclpp/lib/libmscclpp_nccl.so:${LD_PRELOAD}
        export HIP_FORCE_DEV_KERNARG=1
        export HSA_ENABLE_IPC_MODE_LEGACY=1
        export M1=$((1024*1024))
        export M2=$((2*1024*1024))
        export M4=$((4*1024*1024))
        export M8=$((8*1024*1024))
        export M16=$((16*1024*1024))
        export M64=$((64*1024*1024))

        set -x
        #mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000
        #mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000 -d half
        #mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000
        #mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000 -d half
        #mpirun -np 8 ./alltoall_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #mpirun -np 8 ./alltoall_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #mpirun -np 8 ./alltoallv_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #mpirun -np 8 ./alltoallv_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #mpirun -np 8 ./broadcast_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #mpirun -np 8 ./broadcast_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #mpirun -np 8 ./gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #mpirun -np 8 ./gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #mpirun -np 8 ./reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #mpirun -np 8 ./reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #mpirun -np 8 ./reduce_scatter_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #mpirun -np 8 ./reduce_scatter_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #mpirun -np 8 ./scatter_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #mpirun -np 8 ./scatter_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #mpirun -np 8 ./sendrecv_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #mpirun -np 8 ./sendrecv_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half

        #./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000 -t 8
        #./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000 -d half -t 8
        #./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000 -t 8
        #./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000 -d half -t 8
        #./alltoall_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #./alltoall_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half -t 8
        #./alltoallv_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #./alltoallv_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half -t 8
        #./broadcast_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #./broadcast_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half -t 8
        #./gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #./gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half -t 8
        #./reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #./reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half -t 8
        #./reduce_scatter_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #./reduce_scatter_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half -t 8
        #./scatter_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #./scatter_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half -t 8
        #./sendrecv_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #./sendrecv_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half -t 8

        #for i in $(seq 1 10); do
        #    ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -t 8
        #    res=$?
        #    if [[ $res -ne 0 ]]; then
        #        break
        #    fi
        #done

        #./all_reduce_perf -t 8 -b 1K -e 64M -f 2 -g 1 -w 50 -n 100
        #./all_reduce_perf -t 8 -b 8K -e 8K -f 2 -g 1 -w 50 -n 100
        #./all_reduce_perf -t 8 -b 384 -e 384 -f 2 -g 1 -w 50 -n 100 -d int8 -o prod
        #mpirun -np 8 ./all_reduce_perf -b 384 -e 384 -f 2 -g 1 -w 50 -n 100 -d int8 -o prod
        #mpirun -np 8 ./all_reduce_perf -b 8K -e 8K -f 2 -g 1 -w 0 -n 1
        
        #LD_LIBRARY_PATH=${LD_LIBRARY_PATH_1}  RCCL_ENABLE_MSCCLPP=0                             mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #LD_LIBRARY_PATH=${LD_LIBRARY_PATH_1} RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M64 mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M64 mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000
        #LD_LIBRARY_PATH=${LD_LIBRARY_PATH_1} RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M64 mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M1 mpirun -np 8 ./all_gather_perf -b 2K -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #LD_LIBRARY_PATH=${LD_LIBRARY_PATH_1} LD_PRELOAD=${LD_PRELOAD_1}   mpirun -np 8 ./all_gather_perf -b 128 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000
        #LD_LIBRARY_PATH=${LD_LIBRARY_PATH_1} LD_PRELOAD=${LD_PRELOAD_1}   mpirun -np 7 ./all_gather_perf -b 128 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000 : -np 1 strace -s9999 -efile ./all_gather_perf -b 128 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000
        #echo LD_LIBRARY_PATH=${LD_LIBRARY_PATH_2} LD_PRELOAD=${LD_PRELOAD_2}   mpirun -np 8 ./all_gather_perf -b 128 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #GPU_MAX_HW_QUEUES=16 LD_LIBRARY_PATH=${LD_LIBRARY_PATH_2} LD_PRELOAD=${LD_PRELOAD_2}   ./all_gather_perf -b 128 -e 1G -f 2 -t 8 -g 1 -w 50 -G 2 -n 1000
        
        #RCCL_ENABLE_MSCCLPP=0                             rocprof --hip-trace -o ~/prof/prof.csv mpirun -np 8 ./all_reduce_perf -b 1K -e 1K -f 2 -g 1 -w 0 -n 1
        
        #RCCL_ENABLE_MSCCLPP=0                             mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #RCCL_ENABLE_MSCCLPP=0 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_reduce_perf -b 32 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_reduce_perf -b 8K -e 8K -f 2 -g 1 -w 0 -G 2 -n 1
        #RCCL_ENABLE_MSCCLPP=0 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_reduce_perf -b 32 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_reduce_perf -b 32 -e 1G -f 2 -g 1 -w 50 -G 2 -n 1000
        #for i in $(seq 1 10); do
            #RCCL_ENABLE_MSCCLPP=0                             mpirun -np 8 ./all_reduce_perf -b 32 -e 32M -f 2 -g 1 -w 50 -G 2 -n 100
            RCCL_ENABLE_MSCCLPP=0                             mpirun -np 8 ./all_gather_perf -b 16M -e 16M -f 2 -g 1 -w 50 -G 2 -n 1000
            #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_gather_perf -b 32 -e 32M -f 2 -g 1 -w 50 -G 2 -n 100
            #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M2  mpirun -np 8 ./all_gather_perf -b 32 -e 32M -f 2 -g 1 -w 50 -G 2 -n 100
            #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M4  mpirun -np 8 ./all_gather_perf -b 32 -e 32M -f 2 -g 1 -w 50 -G 2 -n 100
            #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M8  mpirun -np 8 ./all_gather_perf -b 32 -e 32M -f 2 -g 1 -w 50 -G 2 -n 100
            RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M16 mpirun -np 8 ./all_gather_perf -b 16M -e 16M -f 2 -g 1 -w 50 -G 2 -n 1000
        #    res=$?
        #    if [[ $res -ne 0 ]]; then
        #        break
        #    fi
        #done
        #mpirun -np 8 --bind-to numa --mca pml ucx --mca btl ^openib -x LD_LIBRARY_PATH=${LD_LIBRARY_PATH} -x RCCL_ENABLE_MSCCLPP=1 -x HIP_FORCE_DEV_KERNARG=1 ./all_reduce_perf -b 8 -e 1G -f 2 -g 1 -n 100 -w 50 -G 2
        #RCCL_ENABLE_MSCCLPP=0                             mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M64 mpirun -np 8 ./all_reduce_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #RCCL_ENABLE_MSCCLPP=0                             mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M64 mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100
        #RCCL_ENABLE_MSCCLPP=0                             mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M1  mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        #RCCL_ENABLE_MSCCLPP=1 RCCL_MSCCLPP_THRESHOLD=$M64 mpirun -np 8 ./all_gather_perf -b 1 -e 1G -f 2 -g 1 -w 50 -G 2 -n 100 -d half
        set +x
    fi

    if [ $unit == 1 ]; then
        echo ======================================================================================================
        echo Running unit tests...
        echo ======================================================================================================
        cd ${RCCL_HOME}/test/
        export UT_MULTITHREAD=1
        export UT_PROCESS_MASK=1

        set -x
        #UT_MIN_GPUS=8 UT_DATATYPES=ncclInt8 UT_PROCESS_MASK=1 ./rccl-UnitTests --gtest_filter="AllReduce.InPlace"
        #UT_MIN_GPUS=8 UT_PROCESS_MASK=1 ./rccl-UnitTests --gtest_filter="AllReduce.InPlace"
        #UT_PROCESS_MASK=1 ./rccl-UnitTests --gtest_filter="AllReduce.*"
        #UT_MIN_GPUS=8 ./rccl-UnitTests --gtest_filter="AllReduce.InPlace"
        #./rccl-UnitTests --gtest_filter="AllReduce.*"
        for i in $(seq 1 1); do
            UT_VERBOSE=1 ./rccl-UnitTests --gtest_filter="AllReduce.*" --gtest_break_on_failure
            res=$?
            if [[ $res -ne 0 ]]; then
                break
            fi
        done
        #./rccl-UnitTests --gtest_filter="AllReduce.*"
        set +x
    fi
fi

echo ======================================================================================================
echo ======================================================================================================
echo ======================================================================================================
echo ======================================================================================================
