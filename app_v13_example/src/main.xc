/*
 * Swallow v13 example - prints out some node IDs, can configure a peripheral
 * board if you want it to.
 *
 * Copyright (c) 2014, Steve Kerrison, All rights reserved
 * This software is freely distributable under a derivative of the
 * University of Illinois/NCSA Open Source License posted in
 * LICENSE.txt and at <http://github.xcore.com/>
 */ 

#include <platform.h>
#include <print.h>
#include <xscope.h>
#include "swallow_xlinkboot.h"

#define NCORES 16

/*
 * Prints the node ID and logical ID as two 16-bit values 
 * Does so in the logical core order.
 */
void example_ids(unsigned logical_id, chanend tokin, chanend tokout) {
  unsigned id = get_local_tile_id();
  xscope_register(0);
  xscope_config_io(XSCOPE_IO_BASIC);
  // 
  if (logical_id == 0) {
    printhex(id);
    printchar(' ');
    printintln(logical_id);
    tokout <: (char)0;
    tokin :> char _;
  } else {
    tokin :> char _;
    printhex(id);
    printchar(' ');
    printintln(logical_id);
    tokout <: (char)0;
  }
  return;
}


int main(void) {
  chan toks[NCORES];
  par {
    PERIPHERALS_TOP_INIT(1) //No semicolon - MC-main syntax is a bit strict!
    par (unsigned i = 0; i < NCORES; i += 1) {
      on tile[i]: example_ids(i,toks[i],toks[(i+1)%NCORES]);
    }
  }
  return 0;
}
