; AVX2, Fused Multiply Add:
;
;  vfmadd231ps a, b, c -> a = b * c + a
;  vfmadd213ps a, b, c -> a = a * b + c
;  vfmadd132ps a, b, c -> a = a * c + b
;

section .data
	align 32
	values1: dd 1.0, 2.0, 3.0, 4.0, 4.0, 2.0, 1.0, 5.0
	values2: dd 3.0, 8.0, 3.0, 4.0, 5.0, 1.0, 1.0, 3.0
	values3: dd 3.0, 2.0, 3.0, 4.0, 2.0, 6.0, 7.0, 4.0
	values4: dd 4.0, 2.0, 3.0, 4.0, 5.0, 8.0, 8.0, 3.0
	values5: dd 5.0, 4.0, 3.0, 4.0, 8.0, 8.0, 7.0, 8.0
	values6: dd 6.0, 3.0, 3.0, 4.0, 5.0, 2.0, 7.0, 9.0

section .text
global asmHasFMA
global asmHasAVX512F
global asmHasAVX512_IFMA
global asmFunc

asmHasFMA:
	mov eax, 0x00000001
	cpuid
	xor eax, eax
	bt ecx, 12
	adc eax, eax
	ret

; EBX...
;  Bit 05: AVX2
;  Bit 16: AVX512F
;  Bit 17: AVX512DQ
;  Bit 21: AVX512_IFMA
;  Bit 26: AVX512PF (intel Xeon Phi only)
;  Bit 27: AVX512ER (intel Xeon Phi only)
;  Bit 28: AVX512CD
;  Bit 30: AVX512BW
;  Bit 31: AVX512VL
; ECX...
;  Bit 01: AVX512_VBMI
;  Bit 06: AVX512_VBMI2
;  Bit 11: AVX512_VNNI
;  Bit 12: AVX512_BITALG
;  Bit 14: AVX512_VPOPCNTDQ
; EDX...
;  Bit 02: AVX512_4VNNIW (intel Xeon Phi only)
;  Bit 03: AVX512_4FMAPS (intel Xeon Phi only)
;  Bit 08: AVX512_VP2INTERSECT
asmHasAVX512F:
	mov eax, 0x00000007
	cpuid
	xor eax, eax
	bt ebx, 16
	adc eax, eax
	ret

asmHasAVX512_IFMA:
	mov eax, 0x00000007
	cpuid
	xor eax, eax
	bt ebx, 21
	adc eax, eax
	ret

asmFunc:
	vmovaps ymm1, [rel values1]
	vmovaps ymm2, [rel values2]
	vmovaps ymm3, [rel values3]
	vmovaps ymm4, [rel values4]
	vmovaps ymm5, [rel values5]
	vmovaps ymm6, [rel values6]
	vaddps ymm0, ymm1, ymm2
	vfmadd231ps ymm1, ymm2, ymm3 ; ymm1 = ymm2 * ymm3 + ymm1
	vfmadd231ps ymm4, ymm5, ymm6 ; ymm4 = ymm5 * ymm6 + ymm4
	vfmadd213ps ymm1, ymm2, ymm3 ; ymm1 = ymm1 * ymm2 + ymm3
	vfmadd213ps ymm4, ymm5, ymm6 ; ymm4 = ymm4 * ymm5 + ymm6
	vfmadd132ps ymm1, ymm2, ymm3 ; ymm1 = ymm1 * ymm3 + ymm2
	vfmadd132ps ymm4, ymm5, ymm6 ; ymm4 = ymm4 * ymm6 + ymm5
	vmovups [rdi], ymm1
	vmovups [rdi+32], ymm4
	ret
