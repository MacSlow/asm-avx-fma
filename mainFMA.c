////////////////////////////////////////////////////////////////////////////////
//
// how to compile/assemble/link:
//   nasm -f elf64 asmFMA.s -o asmFMA.o
//   gcc -O0 -ggdb asmFMA.o mainFMA.c -o mainFMA
//   xz -z -9 mainFMA
//   echo "#!"/bin/sh >mainFMA
//   echo "a=/tmp/I;tail -n+3 $0|xzcat >$a;chmod +x $a;$a;rm $a;exit" >>mainFMA
//
////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>

extern int asmHasFMA ();
extern int asmHasAVX512F ();
extern int asmHasAVX512_IFMA ();
extern void asmFunc (float* ptr);

int main (int argc, char** argv)
{
	if (!asmHasFMA ()) {
		printf ("Your CPU does NOT have AVX2's FMA capability!\n");
		return 1;
	} else {
		printf ("Your CPU does have AVX2's FMA capability.\n");

		float values[16];
		asmFunc (values);

		for (int i = 0; i < 16; ++i) {
			printf ("%d. result: %f\n", i+1, values[i]);
		}
	}

	if (!asmHasAVX512F ()) {
		printf ("Your CPU does NOT have AVX512F capability!\n");
		return 2;
	} else {
		printf ("Your CPU does have AVX512F capability.\n");
	}

	return 0;
}

