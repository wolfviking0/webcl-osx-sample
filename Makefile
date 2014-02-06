#
#  Makefile
#
#  Created by Anthony Liot.
#  Copyright (c) 2013 Anthony Liot. All rights reserved.
#

CURRENT_ROOT:=$(PWD)/

EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)../webcl-translator/emscripten

CXX = $(EMSCRIPTEN_ROOT)/em++

CC = $(EMSCRIPTEN_ROOT)/emcc

CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

DEB=0
VAL=0

ifeq ($(VAL),1)
PREFIX = val_
VALIDATOR = '[""]' # Enable validator without parameter
$(info ************  Mode VALIDATOR : Enabled ************)
else
PREFIX = 
VALIDATOR = '[]' # disable validator
$(info ************  Mode VALIDATOR : Disabled ************)
endif

DEBUG = -O0 -s CL_VALIDATOR=$(VAL) -s CL_VAL_PARAM=$(VALIDATOR) -s CL_PRINT_TRACE=1 -s DISABLE_EXCEPTION_CATCHING=0 -s WARN_ON_UNDEFINED_SYMBOLS=1 -s CL_DEBUG=1 -s CL_GRAB_TRACE=1 -s CL_CHECK_VALID_OBJECT=1

NO_DEBUG = -02 -s CL_VALIDATOR=$(VAL) -s CL_VAL_PARAM=$(VALIDATOR) -s WARN_ON_UNDEFINED_SYMBOLS=0  -s CL_DEBUG=0 -s CL_GRAB_TRACE=0 -s CL_PRINT_TRACE=0 -s CL_CHECK_VALID_OBJECT=0

ifeq ($(DEB),1)
MODE=$(DEBUG)
EMCCDEBUG = EMCC_DEBUG
$(info ************  Mode DEBUG : Enabled ************)
else
MODE=$(NO_DEBUG)
EMCCDEBUG = EMCCDEBUG
$(info ************  Mode DEBUG : Disabled ************)
endif

$(info )
$(info )

#----------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------#
# BUILD
#----------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------#		


all: all_1 all_2 all_3

all_1: \
	hello_sample \
	transpose_sample \
	histogram_sample \

all_2: \
	trajectories_sample \
	scan_sample \
	reduce_sample \

all_3: \
	noise_sample \
	qjulia_sample \
	galaxies_sample \

hello_sample: 
	$(call chdir,OpenCL_Hello_World_Example/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) hello.c $(MODE) \
	-o ../build/$(PREFIX)osx_hello.js
	
transpose_sample: 
	$(call chdir,OpenCL_Matrix_Transpose_Example/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CC) transpose.c $(MODE) -s TOTAL_MEMORY=1024*1024*30 \
	--preload-file transpose_kernel.cl \
	-o ../build/$(PREFIX)osx_transpose.js

histogram_sample: 
	$(call chdir,gpu_histogram/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CC) gpu_histogram.c $(MODE) -s TOTAL_MEMORY=1024*1024*100 \
	--preload-file gpu_histogram_buffer.cl \
	--preload-file gpu_histogram_image.cl \
	-o ../build/$(PREFIX)osx_histogram.js

trajectories_sample: 
	$(call chdir,Trajectories/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) \
	Sources/Main/Trajectories.cpp \
	Sources/OpenCL/Sources/OpenCLBuffer.cpp \
	Sources/OpenCL/Sources/OpenCLFile.cpp \
	Sources/OpenCL/Sources/OpenCLKernel.cpp \
	Sources/OpenCL/Sources/OpenCLProgram.cpp \
	Sources/Trajectory/Trajectory.cpp \
	-I./Sources/Trajectory/ \
	-I./Sources/Main/ \
	-I./Sources/OpenCL/Headers/ \
	$(MODE) \
	--preload-file Sources/Kernel/TrajectoriesKernel.cl \
	-o ../build/$(PREFIX)osx_trajectories.js

scan_sample: 
	$(call chdir,OpenCL_Parallel_Prefix_Sum_Example/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CC) scan.c $(MODE) -s TOTAL_MEMORY=1024*1024*30 \
	--preload-file scan_kernel.cl \
	-o ../build/$(PREFIX)osx_scan.js

reduce_sample: 
	$(call chdir,OpenCL_Parallel_Reduction_Example/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CC) reduce.c $(MODE) -s TOTAL_MEMORY=1024*1024*50 \
	--preload-file reduce_float_kernel.cl \
	--preload-file reduce_float2_kernel.cl \
	--preload-file reduce_float4_kernel.cl \
	--preload-file reduce_int_kernel.cl \
	--preload-file reduce_int2_kernel.cl \
	--preload-file reduce_int4_kernel.cl \
	-o ../build/$(PREFIX)osx_reduce.js

noise_sample: 
	$(call chdir,OpenCL_Procedural_Noise_Example/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CC) noise.c  -s GL_FFP_ONLY=1 -s LEGACY_GL_EMULATION=1 $(MODE) \
	--preload-file noise_kernel.cl \
	-o ../build/$(PREFIX)osx_noise.js

qjulia_sample: 
	$(call chdir,OpenCL_RayTraced_Quaternion_Julia-Set_Example/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CC) qjulia.c  -s GL_FFP_ONLY=1 -s LEGACY_GL_EMULATION=1 $(MODE) \
	--preload-file qjulia_kernel.cl \
	-o ../build/$(PREFIX)osx_qjulia.js	

galaxies_sample: 
	$(call chdir,OpenCL_NBody_Simulation_Example/)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) \
	counter.cpp \
	data.cpp \
	graphics.cpp \
	hud.cpp \
	main.cpp \
	nbody.cpp \
	randomize.cpp \
	simulation.cpp \
	types.cpp \
	-D__JAVASCRIPT__ \
	-s TOTAL_MEMORY=1024*1024*100 \
	 -s GL_FFP_ONLY=1 -s LEGACY_GL_EMULATION=1 $(MODE) \
	--preload-file nbody.fsh \
	--preload-file nbody.vsh \
	--preload-file star.png \
	--preload-file nbody_gpu.cl \
	--preload-file nbody_cpu.cl \
	--preload-file bodies_16k.dat \
	--preload-file bodies_24k.dat \
	--preload-file bodies_32k.dat \
	--preload-file bodies_64k.dat \
	--preload-file bodies_80k.dat \
	-o ../build/$(PREFIX)osx_galaxies.js

galaxies_sample_osx: 
	$(call chdir,OpenCL_NBody_Simulation_Example/)
	clang++ -02 \
	counter.cpp \
	data.cpp \
	graphics.cpp \
	hud.cpp \
	main.cpp \
	nbody.cpp \
	randomize.cpp \
	simulation.cpp \
	types.cpp \
	-I./ -I$(EMCC)/system/include/ -framework OpenCL -framework OpenGL -framework GLUT \
	-o galaxies.out

clean:
	$(call chdir,build/)
	rm -rf tmp/	
	mkdir tmp
	cp memoryprofiler.js tmp/
	cp settings.js tmp/
	rm -f *.data
	rm -f *.js
	rm -f *.map
	cp tmp/memoryprofiler.js ./
	cp tmp/settings.js ./
	rm -rf tmp/
	$(CXX) --clear-cache

	
	
