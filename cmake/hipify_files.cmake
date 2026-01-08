# MIT License
#
# Copyright (c) 2020 Advanced Micro Devices, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Hipify source files (copy of source generated into hipify directory)
find_program(hipify-perl_executable hipify-perl)
if(NOT hipify-perl_executable)
  message(FATAL_ERROR "hipify-perl not found")
endif()

function(hipify_files SRC_FILES HIPIFY_DIR HIP_SOURCES_OUT)
  set(HIP_SOURCES "${${HIP_SOURCES_OUT}}")
  ## Loop over each source file to hipify
  foreach(SRC_FILE ${SRC_FILES})
    # Check that file exists
    if (NOT EXISTS ${SRC_FILE})
      message(FATAL_ERROR "Unable to find file listed in CMakeLists.txt: ${SRC_FILE}")
    endif()

    file(RELATIVE REL_SRC_FILE ${CMAKE_SOURCE_DIR} ${SRC_FILE})

    # Establish hipified copy of the source file
    set(HIP_FILE "${HIPIFY_DIR}/${REL_SRC_FILE}")
    get_filename_component(HIP_FILE_DIR ${HIP_FILE} DIRECTORY)

    # Make sure the file name is unique and there is no duplicate
    add_file_unique(HIP_SOURCES ${HIP_FILE})

    # Convert .cu files to .cpp so that they get processed properly
    string(REPLACE "\.cuh" "\.h" HIP_FILE ${HIP_FILE})
    string(REPLACE "\.cu" "\.cu.cpp" HIP_FILE ${HIP_FILE})
    list(APPEND HIP_SOURCES ${HIP_FILE})

    # Create a custom command to create hipified source code
    if (FAULT_INJECTION)
      add_custom_command(
        OUTPUT ${HIP_FILE}
        COMMAND mkdir -p ${HIP_FILE_DIR}
                && ${hipify-perl_executable} -quiet-warnings ${CMAKE_SOURCE_DIR}/${SRC_FILE} -o ${HIP_FILE}
                && ${CMAKE_COMMAND} -E env bash ${CMAKE_CURRENT_SOURCE_DIR}/cmake/scripts/add_unroll.sh ${HIP_FILE}
                && ${CMAKE_COMMAND} -E env bash ${CMAKE_CURRENT_SOURCE_DIR}/cmake/scripts/add_faults.sh ${HIP_FILE}
        MAIN_DEPENDENCY ${SRC_FILE}
        COMMENT "Hipifying ${SRC_FILE} -> ${HIP_FILE}"
      )
    else()
      add_custom_command(
        OUTPUT ${HIP_FILE}
        COMMAND mkdir -p ${HIP_FILE_DIR}
                && ${hipify-perl_executable} -quiet-warnings ${CMAKE_SOURCE_DIR}/${SRC_FILE} -o ${HIP_FILE}
                && ${CMAKE_COMMAND} -E env bash ${CMAKE_CURRENT_SOURCE_DIR}/cmake/scripts/add_unroll.sh ${HIP_FILE}
        MAIN_DEPENDENCY ${SRC_FILE}
        COMMENT "Hipifying ${SRC_FILE} -> ${HIP_FILE}"
      )
    endif()
  endforeach()

  set(${HIP_SOURCES_OUT} "${HIP_SOURCES}" PARENT_SCOPE)
endfunction()
