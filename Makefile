APP      = mainFMA
CC       = gcc
ASM      = nasm
CPPFLAGS = -Wall \
			-Werror \
			-pedantic \
			-std=c99 \
			-fno-omit-frame-pointer \
			-m64 \
			-ggdb \
			-O0 
LDFLAGS  = 
ASMFLAGS = -g -f elf64

SRCS     = mainFMA.c
ASMSRCS  = asmFMA.s
OBJS     = $(SRCS:.c=.o)
ASMOBJS  = $(ASMSRCS:.s=.o)

all: $(APP)

perf: $(APP)
	perf stat ./$(APP)

report: $(APP)
	perf record -g ./$(APP)
	perf report -g 'graph,0.5,caller' --sort comm,dso,sym

valgrind: $(APP)
	valgrind --show-leak-kinds=all  --leak-check=full -v ./$(APP)

tiny: $(APP)
	xz -z -9 $(APP)
	echo "#!"/bin/sh >$(APP)
	echo 'a=/tmp/I;tail -n+3 $$0|xzcat >$$a;chmod +x $$a;$$a;rm $$a;exit' >>$(APP)
	cat $(APP).xz >>$(APP)
	chmod +x $(APP)
	rm $(APP).xz

%.o: %.c
	$(CC) $(CPPFLAGS) -c $< -o $@

%.o: %.s
	$(ASM) $(ASMFLAGS) -o $@ $<

$(APP):	$(ASMOBJS) $(OBJS)
	$(CC) $(ASMOBJS) $(OBJS) $(LDFLAGS) -o$(APP)

clean:
	rm -f *.o *~ $(APP) perf.data*
