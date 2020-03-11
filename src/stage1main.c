

#include <stdint.h>
#include "clibfuncs.h"


#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200



int setPixel(int x, int y, unsigned char color) {

    unsigned char *screenBuffer = (unsigned char*)0xa0000;
    screenBuffer[x+SCREEN_WIDTH*y] = color;

    return 0;
}

void delay(){
    unsigned int d = 0;

    for(d = 0; d < 0x3fffff; d++);
}


void main(){

    while(1){

    }
}




