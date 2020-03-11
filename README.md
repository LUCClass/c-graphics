

# C-Language Graphics Engine


In this project, you're going to be developing a graphics engine in C. This
graphics library will be writing directly to video memory, similar to the
assembly-language graphics projects we've done in previous homeworks.

The code in this project runs on the bare metal with no operating system, so you
won't have standard features available like `printf`. I have included some basic
functions in `stage1main.c` and `clibfuncs.c` which you can call. In particular,
there is a function called `setPixel` that draws a pixel on the screen at a
given (x,y) coordinate.


## Functions to Write

Your job in this activity is to write some functions that draw things on the
screen. 

### drawLine

This function draws a line on the screen. You can use [Bresenham's Line
Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm) to figure
out which pixels need to be filled in. Refer to the Wikipedia article the get
pseudocode for the algorithm, which you can translate into C.

### Bit Blit

Games like Mario, Pac Man, etc. draw images called sprites on the screen.  The
Mario character, for example, is a fixed image that the game draws at an
arbitrary (x,y) location on the screen. When the user presses a key, the game
changes the character's location accordingly and redraws the sprite. Bit blit
(short for bit block transfer) is the method the game uses to copy the image of
the character to the video buffer.

#### Color Pallette

The BIOS has a special pallette of 256 colors that it can draw. If you want to
draw a sprite on the screen, you need to make sure that the sprite is
represented in the right color pallette. You can do this within Photoshop.

1. [Download the BIOS color
pallette](http://neilklingensmith.com/teaching/loyola/cs264-s2020/activities)

2. Open an image in Photoshop.

3. Go to Image > Mode > Indexed Color... and under the Palette dropdown select
Custom... Choose the palette file that you downloaded in step 1.

4. Save the file as a jpeg or something.

5. [Use an online converter](https://littlevgl.com/image-to-c-array) to convert
the image into a C array.

6. Paste the C array into a C file and compile it. If you create a new C file,
you'll need to add it to the `OBJS` list in the Makefile.



#### Copying your Image to the Video Buffer




