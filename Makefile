EMSCRIPTEN_ROOT:=../../webcl-translator/emscripten

CXX = $(EMSCRIPTEN_ROOT)/emcc

CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

DEB=0
VAL=0

ifeq ($(VAL),1)
PRELOAD = --preload-file-validator
$(info ************  Mode VALIDATOR : Enabled ************)
else
PRELOAD = --preload-file
$(info ************  Mode VALIDATOR : Disabled ************)
endif

DEBUG = -O0 -s OPENCL_VALIDATOR=$(VAL) -s OPENCL_PRINT_TRACE=1 -s DISABLE_EXCEPTION_CATCHING=0 -s WARN_ON_UNDEFINED_SYMBOLS=1 -s OPENCL_PROFILE=1 -s OPENCL_DEBUG=1 -s OPENCL_GRAB_TRACE=1 -s OPENCL_CHECK_VALID_OBJECT=1

NO_DEBUG = -03 -s OPENCL_VALIDATOR=$(VAL) -s WARN_ON_UNDEFINED_SYMBOLS=0 -s OPENCL_PROFILE=1 -s OPENCL_DEBUG=0 -s OPENCL_GRAB_TRACE=0 -s OPENCL_PRINT_TRACE=0 -s OPENCL_CHECK_VALID_OBJECT=0

ifeq ($(DEB),1)
MODE=$(DEBUG)
$(info ************  Mode DEBUG : Enabled ************)
else
MODE=$(NO_DEBUG)
$(info ************  Mode DEBUG : Disabled ************)
endif

$(info )
$(info )


#----------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------#
# BUILD
#----------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------#		


all: \
	hello_sample \
	transpose_sample \
	scan_sample \
	reduce_sample \	
	noise_sample \
	qjulia_sample \
	
hello_sample: 
	$(call chdir,OpenCL_Hello_World_Example/)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) hello.c $(MODE) \
	-o ../build/hello.js
	
transpose_sample: 
	$(call chdir,OpenCL_Matrix_Transpose_Example/)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) transpose.c $(MODE) \
	$(PRELOAD) transpose_kernel.cl \
	-o ../build/transpose.js

scan_sample: 
	$(call chdir,OpenCL_Parallel_Prefix_Sum_Example/)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) scan.c $(MODE) \
	$(PRELOAD) scan_kernel.cl \
	-o ../build/scan.js

reduce_sample: 
	$(call chdir,OpenCL_Parallel_Reduction_Example/)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) reduce.c $(MODE) \
	$(PRELOAD) reduce_float_kernel.cl \
	$(PRELOAD) reduce_float2_kernel.cl \
	$(PRELOAD) reduce_float4_kernel.cl \
	$(PRELOAD) reduce_int_kernel.cl \
	$(PRELOAD) reduce_int2_kernel.cl \
	$(PRELOAD) reduce_int4_kernel.cl \
	-o ../build/reduce.js

noise_sample: 
	$(call chdir,OpenCL_Procedural_Noise_Example/)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) noise.c -s LEGACY_GL_EMULATION=1 $(MODE) \
	$(PRELOAD) noise_kernel.cl \
	-o ../build/noise.js

qjulia_sample: 
	$(call chdir,OpenCL_RayTraced_Quaternion_Julia-Set_Example/)
	JAVA_HEAP_SIZE=8096m EMCC_DEBUG=1 $(CXX) qjulia.c -s LEGACY_GL_EMULATION=1 $(MODE) \
	$(PRELOAD) qjulia_kernel.cl \
	-o ../build/qjulia.js	

clean:
	$(call chdir,build/)
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

	
	