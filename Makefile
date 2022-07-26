# Makefile for dapterm
#
# Usage:
# make and make all - build everything for ARM target, debug config.
# make graph - build doc files
# make release - build everything, ARM target, no debug or gdb support, release config.
# make releasescp - same as make release and copies test releases to target
# make local - build everything, local target (X86), debug config.
# make clean - remove all generated files.
# make allscp - same as "make all" and "make" and copies test builds to remote target
# make first - run this the first time you checkout the project
# make help - displays make options
#
# Notes:
# 1) May need to change the XPREFIX and XPATH to use the target dev tool set,
#    change the path to were you located the tool set of your target.
# 2) May need to change TLIBS to use the c librarys of your target,
#    path to iso image of your target. You need this for your test app builds.
# 3) Will need to change HOST and TARGET with you targets specifics.
#    These settings support copying your test apps to the target
# 4) To build graph docs you will need to have graphviz installed.
#    To install graphviz:
#       sudo apt install graphviz
# 5) Naming Rules:
#    a. All DAP files begin with a dap prefix and end with a .c or .h.
#    b. All test files begin with test prefix and end with a .c
#    c. All graph files end with a .dot
# 6) Set CFLAGS to -g3 or -ggdb so you can debug with preprocessor symbols in gdb

ALLEGRO_FLAGS=-I/usr/local/include/allegro5
ALLEGRO_LIBS=-L/usr/local/lib/ -Wl,-R/usr/local/lib -lallegro_primitives -lallegro_image -lallegro -lallegro_color -lallegro_main -lallegro_font
OTHER_LIBS=-lpthread

XPREFIX=arm-none-linux-gnueabihf-
XPATH=/home/gdc419/gcc-linaro/bin
CC=$(XPATH)/$(XPREFIX)gcc
AR=$(XPATH)/$(XPREFIX)ar
CFLAGS=-Wall -O0 -ggdb -DDEBUG
SOFLAGS=-fPIC -shared

# Font Library Build (for testing)
FBIN=gdcfonts
FSRC=fonts
FSRCS=$(wildcard $(FSRC)/font*.c)
FOBJ=obj
FOBJS=$(patsubst $(FSRC)/%.c, $(FOBJ)/%.o, $(FSRCS))
FLIBDIR=bin
FLIB=$(FLIBDIR)/lib$(FBIN).so

# Library build
BIN=dapterm
LSRC=src
LSRCS=$(wildcard $(LSRC)/dap*.c)
LOBJ=obj
LOBJS=$(patsubst $(LSRC)/%.c, $(LOBJ)/%.o, $(LSRCS))
LIBDIR=bin
LIB=$(LIBDIR)/lib$(BIN).so

# Test builds
TSRC=src
TSRCS=$(wildcard $(TSRC)/test*.c)
TBIN=bin
TBINS=$(patsubst $(TSRC)/%.c, $(TBIN)/%, $(TSRCS))
TLIBS =-L/srv/nfs/Apalis-iMX6_Console-Image-Tezi_3.0b4.254/lib/ -lpthread bin/libdapterm.so

# Copy to target
HOST=~/Projects/$(BIN)
TARGET=root@192.168.20.60:/home/root/
CTT=scp
CP=off

# Graph file build
# Options for GFLAGS: for pdf output use Tpdf, for jpg output use Tjpg
GSRC=graph
GSRCS=$(wildcard $(GSRC)/*.dot)
GG=dot
GFLAGS=-Tsvg
GEXT=svg
GBINS=$(patsubst $(GSRC)/%.dot, $(GSRC)/%.$(GEXT), $(GSRCS))

all: lib fonts test graph
allscp: CP=on
allscp: lib fonts test graph
release: CFLAGS=-Wall -O0
release: clean lib fonts test graph
releasescp: CP=on
releasescp: CFLAGS=-Wall -O0
releasescp: clean lib fonts test graph
local: CC=gcc
local: TLIBS=bin/libdapterm.so -lpthread
local: lib fonts test graph


lib: $(LIB)

$(LIB): $(LOBJS)
	@echo "\e[1mBuilding $@ library\e[0m"
	$(CC) -o $@ $(SOFLAGS) $(LOBJS) $(ALLEGRO_FLAGS) $(ALLEGRO_LIBS) $(OTHER_LIBS)

$(LOBJ)/%.o: $(LSRC)/%.c
	@echo "\e[1mCompiling $< \e[0m"
	$(CC) $(CFLAGS) $(SOFLAGS) -c $< -o $@ $(ALLEGRO_FLAGS) $(ALLEGRO_LIBS) $(OTHER_LIBS)


fonts: $(FLIB)

$(FLIB): $(FOBJS)
	@echo "\e[1mBuilding $@ font library\e[0m"
	$(CC) -o $@ $(SOFLAGS) $(FOBJS)

$(FOBJ)/%.o: $(FSRC)/%.c
	@echo "\e[1mCompiling $< \e[0m"
	$(CC) $(CFLAGS) $(SOFLAGS) -c $< -o $@


test: $(TBINS)

$(TBIN)/%: $(TSRC)/%.c $(LIB)
	@echo "\e[1mBuilding Test program $< \e[0m"
	$(CC)  -o $@ $^ $(CFLAGS) $(FLIB) $(TLIBS) $(ALLEGRO_FLAGS) $(ALLEGRO_LIBS)
	$(if $(findstring on,$(CP)), $(CTT) $(HOST)/$@ $(TARGET), @echo "$@ not copied to remote")

# creates doc files
# will need to install graphviz
# sudo apt install graphviz
graph: $(GBINS)

$(GSRC)/%.$(GEXT): $(GSRC)/%.dot
	@echo "\e[1mBuilding Graph $< \e[0m"
	$(GG) $< $(GFLAGS) > $@

clean:
	@echo "\e[1mClean everything\e[0m"
	$(RM) -r obj/*
	$(RM) -r bin/*
	$(RM) -r graph/*.$(GEXT)

help:
	@echo "\e[1mUsage:\e[0m"
	@echo "make and make all - build everything for ARM target, debug config."
	@echo "make graph - build doc files"
	@echo "make release - build everything, ARM target, no debug or gdb support, release config."
	@echo "make releasescp - same as "make release" and copies test builds to remote target."
	@echo "make local - build everything, local x86 target, debug config."
	@echo "make clean - remove all generated files."
	@echo "make allscp - same as "make all" and "make" and copies test builds to remote target"
	@echo "make first - run this the first time you checkout the project"

first:
	mkdir -p obj
	mkdir -p bin
	mkdir -p fonts
	mkdir -p graph
