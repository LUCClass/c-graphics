
#ifndef __CLIBFUNCS_H__
#define __CLIBFUNCS_H__

/*
 * Definitions
 *
 */
#define NULL ((void*)0)


/*
 * Typedefs
 *
 */
typedef unsigned int size_t;


/*
 * Function prototypes
 *
 *
 */

char * strcpy ( char * destination, const char * source );
int toupper(int c);
int strncmp ( const char * str1, const char * str2, size_t n );
int strcmp ( const char * str1, const char * str2 );
void *memset(void *s, int c, size_t n);
void * memcpy(void * __restrict dest, const void * __restrict src, size_t num);
size_t strlen(const char *str);
int tolower(int c);
int isdig(int c);

#endif

