#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "inout.h"

int
main(int argc, char **argv) {
	char c = 'A';
	for (;;) {
		_outbyte(c);
		usleep(100000);
		c++;
		if (c == 'Z' + 1) {
			c = 'A';
		}
	}
}
