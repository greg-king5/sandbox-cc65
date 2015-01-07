/*
  !!DESCRIPTION!! increment/decrement
  !!ORIGIN!!      LCC 4.1 Testsuite
  !!LICENCE!!     own, freely distributeable for non-profit. read CPYRIGHT.LCC
*/

#include <stdio.h>

int main(void)
{
    printf("disassemble this program to check the generated code.\n");
    return 0;
}

void memchar() {
	char x, *p;

	&x, &p;
	x = *p++;
	x = *++p;
	x = *p--;
	x = *--p;
}

void memint() {
	int x, *p;

	&x, &p;
	x = *p++;
	x = *++p;
	x = *p--;
	x = *--p;
}

void regchar() {
	register char x, *p;

	x = *p++;
	x = *++p;
	x = *p--;
	x = *--p;
}

void regint() {
	register int x, *p;

	x = *p++;
	x = *++p;
	x = *p--;
	x = *--p;
}
