#
#  Makefile
#  Licence : https://github.com/wolfviking0/webcl-translator/blob/master/LICENSE
#
#  Created by Anthony Liot.
#  Copyright (c) 2013 Anthony Liot. All rights reserved.
#

# Default parameter
DEB  		= 0
VAL  		= 0
NAT  		= 0
ORIG 		= 0
FAST 		= 1
NODEJS 	= 0

# Chdir function
CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

# Current Folder
CURRENT_ROOT:=$(PWD)

# Emscripten Folder
EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)/../webcl-translator/emscripten

# Native build
ifeq ($(NAT),1)
$(info ************ NATIVE : NO DEPENDENCIES  ************)

CXX = clang++
CC  = clang

BUILD_FOLDER = $(CURRENT_ROOT)/bin/
EXTENSION = .out

ifeq ($(DEB),1)
$(info ************ NATIVE : DEBUG = 1        ************)

CFLAGS = -O0 -framework OpenCL -framework OpenGL -framework GLUT -framework CoreFoundation -framework AppKit -framework IOKit -framework CoreVideo -framework CoreGraphics

else
$(info ************ NATIVE : DEBUG = 0        ************)

CFLAGS = -O2 -framework OpenCL -framework OpenGL -framework GLUT -framework CoreFoundation -framework AppKit -framework IOKit -framework CoreVideo -framework CoreGraphics

endif

# Emscripten build
else
ifeq ($(ORIG),1)
$(info ************ EMSCRIPTEN : SUBMODULE     = 0 ************)

EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)/../emscripten
else
$(info ************ EMSCRIPTEN : SUBMODULE     = 1 ************)
endif

CXX = $(EMSCRIPTEN_ROOT)/em++
CC  = $(EMSCRIPTEN_ROOT)/emcc

PRELOAD_FILE = --preload-file
BUILD_FOLDER = $(CURRENT_ROOT)/js/
EXTENSION = .js
GLOBAL =

ifeq ($(DEB),1)
$(info ************ EMSCRIPTEN : DEBUG         = 1 ************)

GLOBAL += EMCC_DEBUG=1

CFLAGS = -s OPT_LEVEL=1 -s DEBUG_LEVEL=1 -s CL_PRINT_TRACE=1 -s WARN_ON_UNDEFINED_SYMBOLS=1 -s CL_DEBUG=1 -s CL_GRAB_TRACE=1 -s CL_CHECK_VALID_OBJECT=1
else
$(info ************ EMSCRIPTEN : DEBUG         = 0 ************)

CFLAGS = -s OPT_LEVEL=3 -s DEBUG_LEVEL=0 -s CL_PRINT_TRACE=0 -s DISABLE_EXCEPTION_CATCHING=0 -s WARN_ON_UNDEFINED_SYMBOLS=1 -s CL_DEBUG=0 -s CL_GRAB_TRACE=0 -s CL_CHECK_VALID_OBJECT=0
endif

ifeq ($(NODEJS),1)
$(info ************ EMSCRIPTEN : NODE JS       = 1 ************)

PREFIX = node_

PRELOAD_FILE = --embed-file

else
$(info ************ EMSCRIPTEN : NODE JS       = 0 ************)
endif

ifeq ($(VAL),1)
$(info ************ EMSCRIPTEN : VALIDATOR     = 1 ************)

PREFIX = val_

CFLAGS += -s CL_VALIDATOR=1
else
$(info ************ EMSCRIPTEN : VALIDATOR     = 0 ************)
endif

ifeq ($(FAST),1)
$(info ************ EMSCRIPTEN : FAST_COMPILER = 1 ************)

GLOBAL += EMCC_FAST_COMPILER=1
else
$(info ************ EMSCRIPTEN : FAST_COMPILER = 0 ************)
endif

endif

SOURCES_hello					=	hello.c
SOURCES_transpose			=	transpose.c
SOURCES_trajectories	=	Sources/Main/Trajectories.cpp Sources/OpenCL/Sources/OpenCLBuffer.cpp Sources/OpenCL/Sources/OpenCLFile.cpp Sources/OpenCL/Sources/OpenCLKernel.cpp Sources/OpenCL/Sources/OpenCLProgram.cpp Sources/Trajectory/Trajectory.cpp
SOURCES_scan					=	scan.c
SOURCES_reduce				=	reduce.c
SOURCES_noise					=	noise.c
SOURCES_qjulia				=	qjulia.c

INCLUDES_hello				=	-I./
INCLUDES_transpose		=	-I./
INCLUDES_trajectories	= -I./Sources/Trajectory/ -I./Sources/Main/ -I./Sources/OpenCL/Headers/
INCLUDES_scan					=	-I./
INCLUDES_reduce				=	-I./
INCLUDES_noise				=	-I./
INCLUDES_qjulia				=	-I./

ifeq ($(NAT),0)

KERNEL_hello				=
KERNEL_transpose		= 	$(PRELOAD_FILE) transpose_kernel.cl
KERNEL_trajectories	= 	$(PRELOAD_FILE) Sources/Kernel/TrajectoriesKernel.cl
KERNEL_scan					= 	$(PRELOAD_FILE) scan_kernel.cl
KERNEL_reduce				= 	$(PRELOAD_FILE) reduce_float_kernel.cl $(PRELOAD_FILE) reduce_float2_kernel.cl $(PRELOAD_FILE) reduce_float4_kernel.cl $(PRELOAD_FILE) reduce_int_kernel.cl $(PRELOAD_FILE) reduce_int2_kernel.cl $(PRELOAD_FILE) reduce_int4_kernel.cl
KERNEL_noise				= 	$(PRELOAD_FILE) noise_kernel.cl
KERNEL_qjulia				= 	$(PRELOAD_FILE) qjulia_kernel.cl

CFLAGS_hello				=
CFLAGS_transpose		=	-s TOTAL_MEMORY=1024*104*250
CFLAGS_trajectories	=
CFLAGS_scan					=	-s TOTAL_MEMORY=1024*104*250
CFLAGS_reduce				=	-s TOTAL_MEMORY=1024*104*350
CFLAGS_noise				=	-s GL_FFP_ONLY=1 -s LEGACY_GL_EMULATION=1
CFLAGS_qjulia				=	-s GL_FFP_ONLY=1 -s LEGACY_GL_EMULATION=1

VALPARAM_hello				=	-s CL_VAL_PARAM='[""]'
VALPARAM_transpose		=	-s CL_VAL_PARAM='[""]'
VALPARAM_trajectories	=	-s CL_VAL_PARAM='[""]'
VALPARAM_scan					=	-s CL_VAL_PARAM='[""]'
VALPARAM_reduce				=	-s CL_VAL_PARAM='[""]'
VALPARAM_noise				=	-s CL_VAL_PARAM='[""]'
VALPARAM_qjulia				=	-s CL_VAL_PARAM='[""]'

else

COPY_hello					=
COPY_transpose			= 	cp transpose_kernel.cl $(BUILD_FOLDER) &&
COPY_trajectories		= 	mkdir -p $(BUILD_FOLDER)Sources/Kernel/ && cp Sources/Kernel/TrajectoriesKernel.cl $(BUILD_FOLDER)Sources/Kernel/ &&
COPY_scan						= 	cp scan_kernel.cl $(BUILD_FOLDER) &&
COPY_reduce					= 	cp reduce_float_kernel.cl $(BUILD_FOLDER) && cp reduce_float2_kernel.cl $(BUILD_FOLDER) && cp reduce_float4_kernel.cl $(BUILD_FOLDER) && cp reduce_int_kernel.cl $(BUILD_FOLDER) && cp reduce_int2_kernel.cl $(BUILD_FOLDER) && cp reduce_int4_kernel.cl $(BUILD_FOLDER) &&
COPY_noise					= 	cp noise_kernel.cl $(BUILD_FOLDER) &&
COPY_qjulia					= 	cp qjulia_kernel.cl $(BUILD_FOLDER) &&

endif

.PHONY:
	all clean

all: \
	all_1 all_2 all_3

all_1: \
	hello_sample transpose_sample

all_2: \
	trajectories_sample scan_sample reduce_sample

all_3: \
	noise_sample qjulia_sample

# Create build folder is necessary))
mkdir:
	mkdir -p $(BUILD_FOLDER);

hello_sample: mkdir
	$(call chdir,OpenCL_Hello_World_Example/)
	$(COPY_hello) 				$(GLOBAL) $(CC)	 $(CFLAGS) $(CFLAGS_hello)				$(INCLUDES_hello)					$(SOURCES_hello)					$(VALPARAM_hello) 				$(KERNEL_hello) 				-o $(BUILD_FOLDER)$(PREFIX)hello$(EXTENSION)

transpose_sample: mkdir
	$(call chdir,OpenCL_Matrix_Transpose_Example/)
	$(COPY_transpose) 		$(GLOBAL) $(CC)  $(CFLAGS) $(CFLAGS_transpose)		$(INCLUDES_juliagpu)			$(SOURCES_transpose)			$(VALPARAM_transpose) 		$(KERNEL_transpose) 		-o $(BUILD_FOLDER)$(PREFIX)transpose$(EXTENSION)

trajectories_sample: mkdir
	$(call chdir,Trajectories/)
	$(COPY_trajectories) 	$(GLOBAL) $(CXX) $(CFLAGS) $(CFLAGS_trajectories)	$(INCLUDES_trajectories)	$(SOURCES_trajectories)		$(VALPARAM_trajectories) 	$(KERNEL_trajectories) 	-o $(BUILD_FOLDER)$(PREFIX)trajectories$(EXTENSION)

scan_sample: mkdir
	$(call chdir,OpenCL_Parallel_Prefix_Sum_Example/)
	$(COPY_scan) 					$(GLOBAL) $(CC)  $(CFLAGS) $(CFLAGS_scan)					$(INCLUDES_scan)					$(SOURCES_scan)						$(VALPARAM_scan) 					$(KERNEL_scan) 					-o $(BUILD_FOLDER)$(PREFIX)scan$(EXTENSION)

reduce_sample: mkdir
	$(call chdir,OpenCL_Parallel_Reduction_Example/)
	$(COPY_reduce) 				$(GLOBAL) $(CC)  $(CFLAGS) $(CFLAGS_reduce)				$(INCLUDES_reduce)				$(SOURCES_reduce)					$(VALPARAM_reduce) 				$(KERNEL_reduce) 				-o $(BUILD_FOLDER)$(PREFIX)reduce$(EXTENSION)

noise_sample: mkdir
	$(call chdir,OpenCL_Procedural_Noise_Example/)
	$(COPY_noise) 				$(GLOBAL) $(CC)  $(CFLAGS) $(CFLAGS_noise)				$(INCLUDES_noise)					$(SOURCES_noise)					$(VALPARAM_noise) 				$(KERNEL_noise) 				-o $(BUILD_FOLDER)$(PREFIX)noise$(EXTENSION)

qjulia_sample: mkdir
	$(call chdir,OpenCL_RayTraced_Quaternion_Julia-Set_Example/)
	$(COPY_qjulia) 				$(GLOBAL) $(CC)  $(CFLAGS) $(CFLAGS_qjulia)				$(INCLUDES_qjulia)				$(SOURCES_qjulia)					$(VALPARAM_qjulia)		 		$(KERNEL_qjulia) 				-o $(BUILD_FOLDER)$(PREFIX)qjulia$(EXTENSION)

clean:
	rm -rf bin/
	mkdir -p bin/
	mkdir -p tmp/
	cp js/memoryprofiler.js tmp/ && cp js/settings.js tmp/ && cp js/index.html tmp/
	rm -rf js/
	mkdir js/
	cp tmp/memoryprofiler.js js/ && cp tmp/settings.js js/ && cp tmp/index.html js/
	rm -rf tmp/
	$(EMSCRIPTEN_ROOT)/emcc --clear-cache

