/*
 * GCC 14 compatibility stubs
 *
 * This file provides stub implementations of C library functions that
 * GCC 14's libsupc++ and libgcc_eh depend on but are not provided by
 * the NRE runtime environment.
 */

#include <stddef.h>
#include <stdarg.h>

/* Stub for secure_getenv - just forward to regular getenv */
char *secure_getenv(const char *name) {
    /* In a bare-metal/microkernel environment, there's no environment */
    (void)name;
    return NULL;
}

/* Stub for __isoc23_strtoul - C23 version of strtoul */
unsigned long __isoc23_strtoul(const char *nptr, char **endptr, int base) {
    /* Simple stub implementation - just return 0 */
    /* A full implementation would parse the string */
    if (endptr) *endptr = (char*)nptr;
    (void)base;
    return 0;
}

/* Stub for sprintf */
int sprintf(char *str, const char *format, ...) {
    /* This is a critical function - provide a minimal implementation */
    /* For now, just copy format string (not a real implementation) */
    (void)str;
    (void)format;
    return 0;
}

/* Stub for fwrite */
size_t fwrite(const void *ptr, size_t size, size_t nmemb, void *stream) {
    (void)ptr;
    (void)size;
    (void)nmemb;
    (void)stream;
    return 0;
}

/* Stub for fputs */
int fputs(const char *s, void *stream) {
    (void)s;
    (void)stream;
    return 0;
}

/* Stub for fputc */
int fputc(int c, void *stream) {
    (void)c;
    (void)stream;
    return 0;
}

/* Stub for stderr */
static char stderr_dummy;
void **__attribute__((weak)) stderr = (void**)&stderr_dummy;

/* Stub for pthread_cond_wait */
int pthread_cond_wait(void *cond, void *mutex) {
    (void)cond;
    (void)mutex;
    return 0;
}

/* Stub for pthread_cond_broadcast */
int pthread_cond_broadcast(void *cond) {
    (void)cond;
    return 0;
}

/* Stub for _dl_find_object */
int _dl_find_object(void *address, void *result) {
    (void)address;
    (void)result;
    return -1; /* Not found */
}
