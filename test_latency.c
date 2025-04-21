#include <stdio.h>
#include <stdint.h>
#include <x86intrin.h>
// #include <immintrin.h>

uint64_t measure_latency(void (*func)(void)) {
    uint64_t start = __rdtsc(); 
    func(); 
    uint64_t end = __rdtsc(); 
    return end - start; 
}

void xorps_example() {
    __m128 a = _mm_set_ps1(1.0f); 
    __m128 b = _mm_set_ps1(2.0f);
    a = _mm_xor_ps(a, b); 
}

void pxor_example() {
    __m128i a = _mm_set1_epi32(1); 
    __m128i b = _mm_set1_epi32(2);
    a = _mm_xor_si128(a, b); 
}

void movsd_example() {
    double val = 3.141592653589793;
    __m128d a;
    a = _mm_set_sd(val);
}

void movq_example() {
    long long int val = 1234567890123456;
    __m128i a;
    a = _mm_set_epi64x(val, val);
}

int main() {
    // Measure latency of XORPS
    uint64_t xorps_latency = measure_latency(xorps_example);
    printf("XORPS latency: %llu cycles\n", xorps_latency);

    // Measure latency of PXOR
    uint64_t pxor_latency = measure_latency(pxor_example);
    printf("PXOR latency: %llu cycles\n", pxor_latency);

    // Measure latency of MOVSD
    uint64_t movsd_latency = measure_latency(movsd_example);
    printf("MOVSD latency: %llu cycles\n", movsd_latency);

    // Measure latency of MOVQ
    uint64_t movq_latency = measure_latency(movq_example);
    printf("MOVQ latency: %llu cycles\n", movq_latency);
    return 0;
}
