/*************************************************************************
 * Copyright (c) 2024 Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE.txt and NOTICES.txt for license information
 ************************************************************************/

#include "mscclpp/mscclpp_nccl.h"
#include "debug.h"
#include <dlfcn.h>

std::unordered_map<ncclUniqueId, mscclppUniqueId> mscclpp_uniqueIdMap;
std::unordered_map<mscclppUniqueId, std::unordered_set<ncclUniqueId>> mscclpp_uniqueIdReverseMap;
std::unordered_map<mscclppComm_t, mscclppUniqueId> mscclpp_commToUniqueIdMap;
std::unordered_map<ncclComm_t, ncclUniqueId> ncclCommToUniqueIdMap;

#ifdef COMPILE_MSCCLPP_SHARED

static thread_local void* libmscclpp_nccl_handle = nullptr;
static inline void init_libmscclpp_nccl() {
  if (libmscclpp_nccl_handle == nullptr) {
    INFO(NCCL_INIT, "Loading libmscclpp_nccl.so...");
    libmscclpp_nccl_handle = dlopen("libmscclpp_nccl.so", RTLD_LAZY);
  }
}

#define DECLARE_FP(NAME) \
using fn_##NAME##_t = decltype(&(NAME)); \
static thread_local fn_##NAME##_t fp_##NAME = nullptr
#define DECLARE_NCCL_FP(NAME) \
using fn_##NAME##_t = decltype(&(mscclpp_##NAME)); \
static thread_local fn_##NAME##_t fp_##NAME = nullptr

#define LOAD_CALL_RETURN(NAME, ARGS...) \
  if (fp_##NAME == nullptr) { \
    init_libmscclpp_nccl(); \
    INFO(NCCL_INIT, "Loading %s...", #NAME); \
    fp_##NAME = (fn_##NAME##_t)dlsym(libmscclpp_nccl_handle, #NAME); \
  } return (*fp_##NAME)(ARGS)

DECLARE_NCCL_FP(ncclGetUniqueId);
DECLARE_NCCL_FP(ncclCommInitRank);
DECLARE_NCCL_FP(ncclCommDestroy);
DECLARE_NCCL_FP(ncclAllReduce);
DECLARE_NCCL_FP(ncclAllGather);
DECLARE_NCCL_FP(ncclCommRegister);
DECLARE_NCCL_FP(ncclCommDeregister);
DECLARE_FP(mscclpp_BuffIsRegistered);
DECLARE_FP(mscclpp_BufferSize);
DECLARE_NCCL_FP(ncclMemAlloc);
DECLARE_NCCL_FP(ncclMemFree);

ncclResult_t mscclpp_ncclGetUniqueId(mscclppUniqueId* uniqueId) {
 LOAD_CALL_RETURN(ncclGetUniqueId, uniqueId);
}

ncclResult_t  mscclpp_ncclCommInitRank(mscclppComm_t* comm, int nranks, mscclppUniqueId commId, int rank) {
  LOAD_CALL_RETURN(ncclCommInitRank, comm, nranks, commId, rank);
}

ncclResult_t  mscclpp_ncclCommDestroy(mscclppComm_t comm) {
  LOAD_CALL_RETURN(ncclCommDestroy, comm);
}

ncclResult_t  mscclpp_ncclAllReduce(const void* sendbuff, void* recvbuff, size_t count,
    ncclDataType_t datatype, ncclRedOp_t op, mscclppComm_t comm, hipStream_t stream) {
  LOAD_CALL_RETURN(ncclAllReduce, sendbuff, recvbuff, count, datatype, op, comm, stream);
}

ncclResult_t  mscclpp_ncclAllGather(const void* sendbuff, void* recvbuff, size_t sendcount,
    ncclDataType_t datatype, mscclppComm_t comm, hipStream_t stream) {
  LOAD_CALL_RETURN(ncclAllGather, sendbuff, recvbuff, sendcount, datatype, comm, stream);
}

ncclResult_t mscclpp_ncclCommRegister(mscclppComm_t comm, void* buff, size_t size, void** handle) {
  LOAD_CALL_RETURN(ncclCommRegister, comm, buff, size, handle);
}

ncclResult_t mscclpp_ncclCommDeregister(mscclppComm_t comm, void* handle) {
  LOAD_CALL_RETURN(ncclCommDeregister, comm, handle);
}

bool mscclpp_BuffIsRegistered(mscclppComm_t comm, const void* buff) {
  LOAD_CALL_RETURN(mscclpp_BuffIsRegistered, comm, buff);
}

size_t mscclpp_BufferSize(mscclppComm_t comm, void* handle) {
  LOAD_CALL_RETURN(mscclpp_BufferSize, comm, handle);
}

ncclResult_t mscclpp_ncclMemAlloc(void** ptr, size_t size) {
  LOAD_CALL_RETURN(ncclMemAlloc, ptr, size);
}

ncclResult_t mscclpp_ncclMemFree(void* ptr) {
  LOAD_CALL_RETURN(ncclMemFree, ptr);
}

#endif
