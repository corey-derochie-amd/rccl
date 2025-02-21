/*************************************************************************
 * Copyright (c) 2024 Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE.txt and NOTICES.txt for license information
 ************************************************************************/

#ifndef MSCCLPP_NCCL_H_
#define MSCCLPP_NCCL_H_

#include "nccl.h"
#include <unordered_map>
#include <unordered_set>

typedef struct mscclppComm* mscclppComm_t;

typedef ncclUniqueId mscclppUniqueId;

/* A ncclUniqueId and a mscclppUniqueId will always be created together and used alternatively. This maps between them. */
extern std::unordered_map<ncclUniqueId, mscclppUniqueId> mscclpp_uniqueIdMap;
extern std::unordered_map<mscclppUniqueId, std::unordered_set<ncclUniqueId>> mscclpp_uniqueIdReverseMap;
extern std::unordered_map<mscclppComm_t, mscclppUniqueId> mscclpp_commToUniqueIdMap;
extern std::unordered_map<ncclComm_t, ncclUniqueId> ncclCommToUniqueIdMap;

extern "C" {
  /* See ncclGetUniqueId. */
  __attribute__ ((visibility("hidden")))
  ncclResult_t  mscclpp_ncclGetUniqueId(mscclppUniqueId* uniqueId);

  /* See ncclCommInitRank. */
  __attribute__ ((visibility("hidden")))
  ncclResult_t  mscclpp_ncclCommInitRank(mscclppComm_t* comm, int nranks, mscclppUniqueId commId, int rank);

  /* See ncclCommDestroy. */
  __attribute__ ((visibility("hidden")))
  ncclResult_t  mscclpp_ncclCommDestroy(mscclppComm_t comm);

  /* See ncclAllReduce. */
  __attribute__ ((visibility("hidden")))
  ncclResult_t  mscclpp_ncclAllReduce(const void* sendbuff, void* recvbuff, size_t count,
      ncclDataType_t datatype, ncclRedOp_t op, mscclppComm_t comm, hipStream_t stream);

  /* See ncclAllGather. */
  __attribute__ ((visibility("hidden")))
  ncclResult_t  mscclpp_ncclAllGather(const void* sendbuff, void* recvbuff, size_t sendcount,
      ncclDataType_t datatype, mscclppComm_t comm, hipStream_t stream);

  __attribute__ ((visibility("hidden")))
  ncclResult_t mscclpp_ncclCommRegister(mscclppComm_t comm, void* buff, size_t size, void** handle);

  __attribute__ ((visibility("hidden")))
  ncclResult_t mscclpp_ncclCommDeregister(mscclppComm_t comm, void* handle);

  __attribute__ ((visibility("hidden")))
  bool mscclpp_BuffIsRegistered(mscclppComm_t comm, const void* buff);

  __attribute__ ((visibility("hidden")))
  size_t mscclpp_BufferSize(mscclppComm_t comm, void* handle);

  __attribute__ ((visibility("hidden")))
  ncclResult_t mscclpp_ncclMemAlloc(void** ptr, size_t size);

  __attribute__ ((visibility("hidden")))
  ncclResult_t mscclpp_ncclMemFree(void* ptr);
}

namespace std {
  template <>
  struct hash<ncclUniqueId> {
    size_t operator ()(const ncclUniqueId& uniqueId) const noexcept;
  };
}

bool operator ==(const ncclUniqueId& a, const ncclUniqueId& b);

bool mscclppCommCompatible(ncclComm_t comm);

#endif
