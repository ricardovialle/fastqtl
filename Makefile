#PLEASE SPECIFY THE R path here where you built the R math library standalone 
RMATH=../R-3.2.0/src

#compiler
CXX=g++

#internal paths
VPATH=$(shell for file in `find src -name *.cpp`; do echo $$(dirname $$file); done)
PATH_TABX=lib/Tabix
PATH_EIGN=lib/Eigen

#compiler flags
CXXFLAG_OPTI=-O3 -D_FAST_CORRELATION
CXXFLAG_DEBG=-g
CXXFLAG_WARN=-Wall -Wextra -Wno-sign-compare
CXXFLAG_MACX=-mmacosx-version-min=10.7 -stdlib=libc++

#linker flags
LDFLAG_OPTI=-O3
LDFLAG_DEBG=-g
LDFLAG_MACX=-mmacosx-version-min=10.7 -stdlib=libc++

#includes
INC_BASE=-Isrc -I$(PATH_TABX) -I$(PATH_EIGN)
INC_MATH=-I$(RMATH)/include/
INC_MACX=-I/usr/local/include/

#libraries
LIB_BASE=-lm -lboost_iostreams -lboost_program_options -lz -lgsl -lgslcblas
#LIB_BASE=-lm -lz -lboost_iostreams -lboost_program_options -lgsl -lblas -I/gscmnt/gc2719/halllab/src/boost_1_57_0/include -L/gscmnt/gc2719/halllab/src/boost_1_57_0/lib
LIB_MATH=$(RMATH)/nmath/standalone/libRmath.a
LIB_TABX=$(PATH_TABX)/libtabix.a
LIB_MACX=-L/usr/local/lib/

#files (binary, objects, headers & sources)
FILE_BIN=bin/fastQTL
FILE_O=$(shell for file in `find src -name *.cpp`; do echo obj/$$(basename $$file .cpp).o; done)
FILE_H=$(shell find src -name *.h)
FILE_CPP=$(shell find src -name *.cpp)

#default
all: linux

#linux release
linux: CXXFLAG=$(CXXFLAG_OPTI) $(CXXFLAG_WARN)
linux: IFLAG=$(INC_BASE) $(INC_MATH)
linux: LIB=$(LIB_MATH) $(LIB_TABX) $(LIB_BASE)
linux: LDFLAG=$(LDFLAG_OPTI)  
linux: $(FILE_BIN)

#macos release
macos: CXXFLAG=$(CXXFLAG_OPTI) $(CXXFLAG_WARN) $(CXXFLAG_MACX)
macos: IFLAG=$(INC_BASE) $(INC_MACX) $(INC_MATH)
macos: LIB=$(LIB_MACX) $(LIB_MATH) $(LIB_TABX) $(LIB_BASE)
macos: LDFLAG=$(LDFLAG_OPTI) $(LDFLAG_MACX)  
macos: $(FILE_BIN)

#debug release
debug: CXXFLAG=$(CXXFLAG_DEBG) $(CXXFLAG_WARN)
debug: IFLAG=$(INC_BASE) $(INC_MATH)
debug: LIB=$(LIB_MATH) $(LIB_TABX) $(LIB_BASE)
debug: LDFLAG=$(LDFLAG_DEBG)
debug: $(FILE_BIN)

#compilation
$(LIB_TABX):
	cd $(PATH_TABX) && make && cd ../..

$(FILE_BIN): $(FILE_O) $(LIB_TABX)
	$(CXX) $(LDFLAG) $^ $(LIB) -o $@

obj/%.o: %.cpp $(FILE_H)
	$(CXX) $(CXXFLAG) -o $@ -c $< $(IFLAG)

clean: 
	rm -f obj/*.o $(FILE_BIN)

cleanall: clean 
	cd $(PATH_TABX) && make clean && cd ../..	
