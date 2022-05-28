# Makefile for DAP

CC=gcc
AR=ar
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

lib: $(LIB)

$(LIB): $(LOBJS)
	@echo "\e[1mBuilding DAP library\e[0m"
	$(AR) $(AFLAGS) $@ $(LOBJS)

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
