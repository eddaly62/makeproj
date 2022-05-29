# Makefile for DAP
#
# Usage:
# make and make all - build everything for ARM target, debug config.
# make lib - build DAP library for ARM target, debug config.
# make graph - build doc files
# make test - build test apps for ARM target, debug config.
# make release - build everything, ARM target, no debug or gdb support, release config.
# make local - build everything, local target (X86), debug config.
# make clean - remove all generated files.
#
# Notes:
# 1) May need to change the CC and AR to use the target dev tool set,
#    change the path to were you located the tool set of your target.
# 2) May need to change TLIB to use the c librarys of your target,
#    path to iso image of your target. You need this foir your test app builds.
# 3) To build graph docs you will need to have graphviz installed.
#    To install graphviz:
#       sudo apt install graphviz

CC=/home/gdc419/gcc-linaro/bin/arm-none-linux-gnueabihf-gcc
AR=/home/gdc419/gcc-linaro/bin/arm-none-linux-gnueabihf-ar
CFLAGS=-g -Wall -o0 -DDEBUG
AFLAGS=-cvrs

# Library build
BIN=dap
LSRC=src
LSRCS=$(wildcard $(LSRC)/dap*.c)
LOBJ=obj
LOBJS=$(patsubst $(LSRC)/%.c, $(LOBJ)/%.o, $(LSRCS))
LIBDIR=bin
LIB=$(LIBDIR)/$(BIN).a

# Test builds
TSRC=src
TSRCS=$(wildcard $(TSRC)/test*.c)
TBIN=bin
TBINS=$(patsubst $(TSRC)/%.c, $(TBIN)/%, $(TSRCS))
#TODO needs to point to ARM iso image
TLIBS =bin/dap.a -lpthread

# Graph file build
# Options for flags: for pdf output use Tpdf, for jpg output use Tjpg
GSRC=graph
GSRCS=$(wildcard $(GSRC)/*.dot)
GG=dot
GFLAGS=-Tsvg
GEXT=svg
GBINS=$(patsubst $(GSRC)/%.dot, $(GSRC)/%.$(GEXT), $(GSRCS))


all: lib test graph
release: CFLAGS=-Wall -o0
release: clean lib test graph
local: CC=gcc
local: AR=ar
local: TLIBS=bin/dap.a -lpthread
local: lib test graph

lib: $(LIB)

$(LIB): $(LOBJS)
	@echo "\e[1mBuilding DAP library\e[0m"
	$(AR) $(AFLAGS) $@ $(LOBJS)
	file $@

$(LOBJ)/%.o: $(LSRC)/%.c
	@echo "\e[1mCompile $< \e[0m"
	$(CC) $(CFLAGS) -c $< -o $@


test: $(TBINS)

$(TBIN)/%: $(TSRC)/%.c
	@echo "\e[1mBuilding Test program $< \e[0m"
	$(CC) $(CFLAGS) $< -o $@ $(TLIBS)


# creates doc files
# may need to install graphviz
# sudo apt install graphviz
graph: $(GBINS)

$(GSRC)/%.$(GEXT): $(GSRC)/%.dot
	@echo "\e[1mBuilding Graph $< \e[0m"
	$(GG) $< $(GFLAGS) > $@

clean:
	@echo "\e[1mClean everything\e[0m"
	$(RM) -r obj/*
	$(RM) -r bin/*
	$(RM) -r graph/*.svg

help:
	@echo "\e[1mUsage:\e[0m"
	@echo "make and make all - build everything for ARM target, debug config."
	@echo "make lib - build DAP library for ARM target, debug config"
	@echo "make graph - build doc files"
	@echo "make test - build test apps for ARM target, debug config."
	@echo "make release - build everything, ARM target, no debug or gdb support, release config."
	@echo "make local - build everything, local x86 target, debug config."
	@echo "make clean - remove all generated files."

