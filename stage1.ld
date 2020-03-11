
/* OUTPUT_ARCH(m68k) */
ENTRY(stage1)
SEARCH_DIR(.)

MEMORY
{
  ram (rwx) : ORIGIN = 0x07E00, LENGTH = 655K
}
SECTIONS
{
  STAGE1START = 0x7e00 ;

  .text STAGE1START :
  {
    . = ALIGN(4) ;
    *(.text.startup)
    *(.text)
  } >ram

  .data :
  {
    . = ALIGN(4) ;
    _start_data = . ;
    *(.data)
    _end_data = ADDR(.data) + SIZEOF(.data) ;
  } >ram
  .rodata :
  {
    . = ALIGN(8) ;
    *(.rodata)
  } >ram
  .bss :
  {
    _start_bss = . ;
    *(.bss)
    _end_bss = ADDR(.bss) + SIZEOF(.bss) ;
    _end = .;
    __end = .;
  } >ram
/*
  .stack : ALIGN(8)
  {
    _STACK_BOTTOM = . ;
    . += __STACKSIZE ;
    _STACK = . ;
  } >ram
*/
}
