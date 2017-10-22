
obj/user/testbss.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  800041:	e8 ff 01 00 00       	call   800245 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	b8 01 00 00 00       	mov    $0x1,%eax
  80004b:	ba 20 40 80 00       	mov    $0x804020,%edx
  800050:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  800057:	74 04                	je     80005d <umain+0x29>
  800059:	b0 00                	mov    $0x0,%al
  80005b:	eb 06                	jmp    800063 <umain+0x2f>
  80005d:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800061:	74 20                	je     800083 <umain+0x4f>
			panic("bigarray[%d] isn't cleared!\n", i);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 3b 22 80 	movl   $0x80223b,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  80007e:	e8 09 01 00 00       	call   80018c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 d0                	jne    80005d <umain+0x29>
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800092:	ba 20 40 80 00       	mov    $0x804020,%edx
  800097:	89 04 82             	mov    %eax,(%edx,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009a:	83 c0 01             	add    $0x1,%eax
  80009d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a2:	75 f3                	jne    800097 <umain+0x63>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a9:	ba 20 40 80 00       	mov    $0x804020,%edx
  8000ae:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  8000b5:	74 04                	je     8000bb <umain+0x87>
  8000b7:	b0 00                	mov    $0x0,%al
  8000b9:	eb 05                	jmp    8000c0 <umain+0x8c>
  8000bb:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  8000be:	74 20                	je     8000e0 <umain+0xac>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 e0 21 80 	movl   $0x8021e0,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  8000db:	e8 ac 00 00 00       	call   80018c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e0:	83 c0 01             	add    $0x1,%eax
  8000e3:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000e8:	75 d1                	jne    8000bb <umain+0x87>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ea:	c7 04 24 08 22 80 00 	movl   $0x802208,(%esp)
  8000f1:	e8 4f 01 00 00       	call   800245 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f6:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000fd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800100:	c7 44 24 08 67 22 80 	movl   $0x802267,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 58 22 80 00 	movl   $0x802258,(%esp)
  800117:	e8 70 00 00 00       	call   80018c <_panic>

0080011c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
  800122:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800125:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800128:	8b 75 08             	mov    0x8(%ebp),%esi
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80012e:	e8 5f 13 00 00       	call   801492 <sys_getenvid>
  800133:	25 ff 03 00 00       	and    $0x3ff,%eax
  800138:	89 c2                	mov    %eax,%edx
  80013a:	c1 e2 07             	shl    $0x7,%edx
  80013d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800144:	a3 20 40 c0 00       	mov    %eax,0xc04020
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800149:	85 f6                	test   %esi,%esi
  80014b:	7e 07                	jle    800154 <libmain+0x38>
		binaryname = argv[0];
  80014d:	8b 03                	mov    (%ebx),%eax
  80014f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800154:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800158:	89 34 24             	mov    %esi,(%esp)
  80015b:	e8 d4 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800160:	e8 0b 00 00 00       	call   800170 <exit>
}
  800165:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800168:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80016b:	89 ec                	mov    %ebp,%esp
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    
	...

00800170 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800176:	e8 a0 18 00 00       	call   801a1b <close_all>
	sys_env_destroy(0);
  80017b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800182:	e8 4b 13 00 00       	call   8014d2 <sys_env_destroy>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
	...

0080018c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800194:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800197:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80019d:	e8 f0 12 00 00       	call   801492 <sys_getenvid>
  8001a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b8:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  8001bf:	e8 81 00 00 00       	call   800245 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 11 00 00 00       	call   8001e4 <vcprintf>
	cprintf("\n");
  8001d3:	c7 04 24 56 22 80 00 	movl   $0x802256,(%esp)
  8001da:	e8 66 00 00 00       	call   800245 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001df:	cc                   	int3   
  8001e0:	eb fd                	jmp    8001df <_panic+0x53>
	...

008001e4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f4:	00 00 00 
	b.cnt = 0;
  8001f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800201:	8b 45 0c             	mov    0xc(%ebp),%eax
  800204:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800208:	8b 45 08             	mov    0x8(%ebp),%eax
  80020b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800215:	89 44 24 04          	mov    %eax,0x4(%esp)
  800219:	c7 04 24 5f 02 80 00 	movl   $0x80025f,(%esp)
  800220:	e8 d7 01 00 00       	call   8003fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800225:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	e8 6f 0d 00 00       	call   800fac <sys_cputs>

	return b.cnt;
}
  80023d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80024b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	e8 87 ff ff ff       	call   8001e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	53                   	push   %ebx
  800263:	83 ec 14             	sub    $0x14,%esp
  800266:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800269:	8b 03                	mov    (%ebx),%eax
  80026b:	8b 55 08             	mov    0x8(%ebp),%edx
  80026e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800272:	83 c0 01             	add    $0x1,%eax
  800275:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800277:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027c:	75 19                	jne    800297 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80027e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800285:	00 
  800286:	8d 43 08             	lea    0x8(%ebx),%eax
  800289:	89 04 24             	mov    %eax,(%esp)
  80028c:	e8 1b 0d 00 00       	call   800fac <sys_cputs>
		b->idx = 0;
  800291:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	83 c4 14             	add    $0x14,%esp
  80029e:	5b                   	pop    %ebx
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    
	...

008002b0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8002d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002db:	39 d1                	cmp    %edx,%ecx
  8002dd:	72 07                	jb     8002e6 <printnum_v2+0x36>
  8002df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e2:	39 d0                	cmp    %edx,%eax
  8002e4:	77 5f                	ja     800345 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8002e6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002ea:	83 eb 01             	sub    $0x1,%ebx
  8002ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002f9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800300:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800303:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800306:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80030a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800311:	00 
  800312:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80031b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031f:	e8 2c 1c 00 00       	call   801f50 <__udivdi3>
  800324:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800327:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80032a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80032e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	89 54 24 04          	mov    %edx,0x4(%esp)
  800339:	89 f2                	mov    %esi,%edx
  80033b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033e:	e8 6d ff ff ff       	call   8002b0 <printnum_v2>
  800343:	eb 1e                	jmp    800363 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800345:	83 ff 2d             	cmp    $0x2d,%edi
  800348:	74 19                	je     800363 <printnum_v2+0xb3>
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	90                   	nop
  800350:	7e 11                	jle    800363 <printnum_v2+0xb3>
			putch(padc, putdat);
  800352:	89 74 24 04          	mov    %esi,0x4(%esp)
  800356:	89 3c 24             	mov    %edi,(%esp)
  800359:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80035c:	83 eb 01             	sub    $0x1,%ebx
  80035f:	85 db                	test   %ebx,%ebx
  800361:	7f ef                	jg     800352 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800363:	89 74 24 04          	mov    %esi,0x4(%esp)
  800367:	8b 74 24 04          	mov    0x4(%esp),%esi
  80036b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800372:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800379:	00 
  80037a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80037d:	89 14 24             	mov    %edx,(%esp)
  800380:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800383:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800387:	e8 f4 1c 00 00       	call   802080 <__umoddi3>
  80038c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800390:	0f be 80 ab 22 80 00 	movsbl 0x8022ab(%eax),%eax
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039d:	83 c4 4c             	add    $0x4c,%esp
  8003a0:	5b                   	pop    %ebx
  8003a1:	5e                   	pop    %esi
  8003a2:	5f                   	pop    %edi
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a8:	83 fa 01             	cmp    $0x1,%edx
  8003ab:	7e 0e                	jle    8003bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b2:	89 08                	mov    %ecx,(%eax)
  8003b4:	8b 02                	mov    (%edx),%eax
  8003b6:	8b 52 04             	mov    0x4(%edx),%edx
  8003b9:	eb 22                	jmp    8003dd <getuint+0x38>
	else if (lflag)
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	74 10                	je     8003cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	eb 0e                	jmp    8003dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d4:	89 08                	mov    %ecx,(%eax)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ee:	73 0a                	jae    8003fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f3:	88 0a                	mov    %cl,(%edx)
  8003f5:	83 c2 01             	add    $0x1,%edx
  8003f8:	89 10                	mov    %edx,(%eax)
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	56                   	push   %esi
  800401:	53                   	push   %ebx
  800402:	83 ec 6c             	sub    $0x6c,%esp
  800405:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800408:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80040f:	eb 1a                	jmp    80042b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800411:	85 c0                	test   %eax,%eax
  800413:	0f 84 66 06 00 00    	je     800a7f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	ff 55 08             	call   *0x8(%ebp)
  800426:	eb 03                	jmp    80042b <vprintfmt+0x2f>
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042b:	0f b6 07             	movzbl (%edi),%eax
  80042e:	83 c7 01             	add    $0x1,%edi
  800431:	83 f8 25             	cmp    $0x25,%eax
  800434:	75 db                	jne    800411 <vprintfmt+0x15>
  800436:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80043a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800446:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80044b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800452:	be 00 00 00 00       	mov    $0x0,%esi
  800457:	eb 06                	jmp    80045f <vprintfmt+0x63>
  800459:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80045d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	0f b6 17             	movzbl (%edi),%edx
  800462:	0f b6 c2             	movzbl %dl,%eax
  800465:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800468:	8d 47 01             	lea    0x1(%edi),%eax
  80046b:	83 ea 23             	sub    $0x23,%edx
  80046e:	80 fa 55             	cmp    $0x55,%dl
  800471:	0f 87 60 05 00 00    	ja     8009d7 <vprintfmt+0x5db>
  800477:	0f b6 d2             	movzbl %dl,%edx
  80047a:	ff 24 95 80 24 80 00 	jmp    *0x802480(,%edx,4)
  800481:	b9 01 00 00 00       	mov    $0x1,%ecx
  800486:	eb d5                	jmp    80045d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800488:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80048b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80048e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800491:	8d 7a d0             	lea    -0x30(%edx),%edi
  800494:	83 ff 09             	cmp    $0x9,%edi
  800497:	76 08                	jbe    8004a1 <vprintfmt+0xa5>
  800499:	eb 40                	jmp    8004db <vprintfmt+0xdf>
  80049b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80049f:	eb bc                	jmp    80045d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004a4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8004a7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8004ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ae:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004b1:	83 ff 09             	cmp    $0x9,%edi
  8004b4:	76 eb                	jbe    8004a1 <vprintfmt+0xa5>
  8004b6:	eb 23                	jmp    8004db <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004bb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004be:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004c1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8004c3:	eb 16                	jmp    8004db <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8004c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004c8:	c1 fa 1f             	sar    $0x1f,%edx
  8004cb:	f7 d2                	not    %edx
  8004cd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8004d0:	eb 8b                	jmp    80045d <vprintfmt+0x61>
  8004d2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004d9:	eb 82                	jmp    80045d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8004db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004df:	0f 89 78 ff ff ff    	jns    80045d <vprintfmt+0x61>
  8004e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004e8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8004eb:	e9 6d ff ff ff       	jmp    80045d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8004f3:	e9 65 ff ff ff       	jmp    80045d <vprintfmt+0x61>
  8004f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 55 0c             	mov    0xc(%ebp),%edx
  800507:	89 54 24 04          	mov    %edx,0x4(%esp)
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	ff 55 08             	call   *0x8(%ebp)
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800516:	e9 10 ff ff ff       	jmp    80042b <vprintfmt+0x2f>
  80051b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 c2                	mov    %eax,%edx
  80052b:	c1 fa 1f             	sar    $0x1f,%edx
  80052e:	31 d0                	xor    %edx,%eax
  800530:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800532:	83 f8 0f             	cmp    $0xf,%eax
  800535:	7f 0b                	jg     800542 <vprintfmt+0x146>
  800537:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  80053e:	85 d2                	test   %edx,%edx
  800540:	75 26                	jne    800568 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800542:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800546:	c7 44 24 08 bc 22 80 	movl   $0x8022bc,0x8(%esp)
  80054d:	00 
  80054e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800551:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800555:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800558:	89 1c 24             	mov    %ebx,(%esp)
  80055b:	e8 a7 05 00 00       	call   800b07 <printfmt>
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800563:	e9 c3 fe ff ff       	jmp    80042b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800568:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80056c:	c7 44 24 08 c5 22 80 	movl   $0x8022c5,0x8(%esp)
  800573:	00 
  800574:	8b 45 0c             	mov    0xc(%ebp),%eax
  800577:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057b:	8b 55 08             	mov    0x8(%ebp),%edx
  80057e:	89 14 24             	mov    %edx,(%esp)
  800581:	e8 81 05 00 00       	call   800b07 <printfmt>
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800589:	e9 9d fe ff ff       	jmp    80042b <vprintfmt+0x2f>
  80058e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800591:	89 c7                	mov    %eax,%edi
  800593:	89 d9                	mov    %ebx,%ecx
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 50 04             	lea    0x4(%eax),%edx
  8005a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a4:	8b 30                	mov    (%eax),%esi
  8005a6:	85 f6                	test   %esi,%esi
  8005a8:	75 05                	jne    8005af <vprintfmt+0x1b3>
  8005aa:	be c8 22 80 00       	mov    $0x8022c8,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8005af:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005b3:	7e 06                	jle    8005bb <vprintfmt+0x1bf>
  8005b5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8005b9:	75 10                	jne    8005cb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bb:	0f be 06             	movsbl (%esi),%eax
  8005be:	85 c0                	test   %eax,%eax
  8005c0:	0f 85 a2 00 00 00    	jne    800668 <vprintfmt+0x26c>
  8005c6:	e9 92 00 00 00       	jmp    80065d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005cf:	89 34 24             	mov    %esi,(%esp)
  8005d2:	e8 74 05 00 00       	call   800b4b <strnlen>
  8005d7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005da:	29 c2                	sub    %eax,%edx
  8005dc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005df:	85 d2                	test   %edx,%edx
  8005e1:	7e d8                	jle    8005bb <vprintfmt+0x1bf>
					putch(padc, putdat);
  8005e3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8005e7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005ea:	89 d3                	mov    %edx,%ebx
  8005ec:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ef:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8005f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005f5:	89 ce                	mov    %ecx,%esi
  8005f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fb:	89 34 24             	mov    %esi,(%esp)
  8005fe:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	83 eb 01             	sub    $0x1,%ebx
  800604:	85 db                	test   %ebx,%ebx
  800606:	7f ef                	jg     8005f7 <vprintfmt+0x1fb>
  800608:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80060b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800611:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800618:	eb a1                	jmp    8005bb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x23f>
  800620:	8d 50 e0             	lea    -0x20(%eax),%edx
  800623:	83 fa 5e             	cmp    $0x5e,%edx
  800626:	76 13                	jbe    80063b <vprintfmt+0x23f>
					putch('?', putdat);
  800628:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800636:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80063b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 ef 01             	sub    $0x1,%edi
  80064b:	0f be 06             	movsbl (%esi),%eax
  80064e:	85 c0                	test   %eax,%eax
  800650:	74 05                	je     800657 <vprintfmt+0x25b>
  800652:	83 c6 01             	add    $0x1,%esi
  800655:	eb 1a                	jmp    800671 <vprintfmt+0x275>
  800657:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80065a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800661:	7f 1f                	jg     800682 <vprintfmt+0x286>
  800663:	e9 c0 fd ff ff       	jmp    800428 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800668:	83 c6 01             	add    $0x1,%esi
  80066b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80066e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800671:	85 db                	test   %ebx,%ebx
  800673:	78 a5                	js     80061a <vprintfmt+0x21e>
  800675:	83 eb 01             	sub    $0x1,%ebx
  800678:	79 a0                	jns    80061a <vprintfmt+0x21e>
  80067a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80067d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800680:	eb db                	jmp    80065d <vprintfmt+0x261>
  800682:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800685:	8b 75 0c             	mov    0xc(%ebp),%esi
  800688:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80068b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800692:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800699:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069b:	83 eb 01             	sub    $0x1,%ebx
  80069e:	85 db                	test   %ebx,%ebx
  8006a0:	7f ec                	jg     80068e <vprintfmt+0x292>
  8006a2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006a5:	e9 81 fd ff ff       	jmp    80042b <vprintfmt+0x2f>
  8006aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ad:	83 fe 01             	cmp    $0x1,%esi
  8006b0:	7e 10                	jle    8006c2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 08             	lea    0x8(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 18                	mov    (%eax),%ebx
  8006bd:	8b 70 04             	mov    0x4(%eax),%esi
  8006c0:	eb 26                	jmp    8006e8 <vprintfmt+0x2ec>
	else if (lflag)
  8006c2:	85 f6                	test   %esi,%esi
  8006c4:	74 12                	je     8006d8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 18                	mov    (%eax),%ebx
  8006d1:	89 de                	mov    %ebx,%esi
  8006d3:	c1 fe 1f             	sar    $0x1f,%esi
  8006d6:	eb 10                	jmp    8006e8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 18                	mov    (%eax),%ebx
  8006e3:	89 de                	mov    %ebx,%esi
  8006e5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	75 1e                	jne    80070b <vprintfmt+0x30f>
                               if((long long)num > 0){
  8006ed:	85 f6                	test   %esi,%esi
  8006ef:	78 1a                	js     80070b <vprintfmt+0x30f>
  8006f1:	85 f6                	test   %esi,%esi
  8006f3:	7f 05                	jg     8006fa <vprintfmt+0x2fe>
  8006f5:	83 fb 00             	cmp    $0x0,%ebx
  8006f8:	76 11                	jbe    80070b <vprintfmt+0x30f>
                                   putch('+',putdat);
  8006fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006fd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800701:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800708:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80070b:	85 f6                	test   %esi,%esi
  80070d:	78 13                	js     800722 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800712:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800718:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071d:	e9 da 00 00 00       	jmp    8007fc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800733:	89 da                	mov    %ebx,%edx
  800735:	89 f1                	mov    %esi,%ecx
  800737:	f7 da                	neg    %edx
  800739:	83 d1 00             	adc    $0x0,%ecx
  80073c:	f7 d9                	neg    %ecx
  80073e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800741:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800747:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074c:	e9 ab 00 00 00       	jmp    8007fc <vprintfmt+0x400>
  800751:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800754:	89 f2                	mov    %esi,%edx
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 47 fc ff ff       	call   8003a5 <getuint>
  80075e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800761:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800764:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800767:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80076c:	e9 8b 00 00 00       	jmp    8007fc <vprintfmt+0x400>
  800771:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800777:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800782:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800785:	89 f2                	mov    %esi,%edx
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
  80078a:	e8 16 fc ff ff       	call   8003a5 <getuint>
  80078f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800792:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800795:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800798:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80079d:	eb 5d                	jmp    8007fc <vprintfmt+0x400>
  80079f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007be:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 50 04             	lea    0x4(%eax),%edx
  8007c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ca:	8b 10                	mov    (%eax),%edx
  8007cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007d4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007da:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007df:	eb 1b                	jmp    8007fc <vprintfmt+0x400>
  8007e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 b7 fb ff ff       	call   8003a5 <getuint>
  8007ee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007f1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800800:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800803:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800806:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80080a:	77 09                	ja     800815 <vprintfmt+0x419>
  80080c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80080f:	0f 82 ac 00 00 00    	jb     8008c1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800815:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800818:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80081c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80081f:	83 ea 01             	sub    $0x1,%edx
  800822:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800826:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80082e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800832:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800835:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800838:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80083b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80083f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800846:	00 
  800847:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80084a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80084d:	89 0c 24             	mov    %ecx,(%esp)
  800850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800854:	e8 f7 16 00 00       	call   801f50 <__udivdi3>
  800859:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80085c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80085f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800863:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	e8 37 fa ff ff       	call   8002b0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80087c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800880:	8b 74 24 04          	mov    0x4(%esp),%esi
  800884:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800887:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800892:	00 
  800893:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800896:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800899:	89 14 24             	mov    %edx,(%esp)
  80089c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a0:	e8 db 17 00 00       	call   802080 <__umoddi3>
  8008a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a9:	0f be 80 ab 22 80 00 	movsbl 0x8022ab(%eax),%eax
  8008b0:	89 04 24             	mov    %eax,(%esp)
  8008b3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8008b6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008ba:	74 54                	je     800910 <vprintfmt+0x514>
  8008bc:	e9 67 fb ff ff       	jmp    800428 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8008c1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008c5:	8d 76 00             	lea    0x0(%esi),%esi
  8008c8:	0f 84 2a 01 00 00    	je     8009f8 <vprintfmt+0x5fc>
		while (--width > 0)
  8008ce:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008d1:	83 ef 01             	sub    $0x1,%edi
  8008d4:	85 ff                	test   %edi,%edi
  8008d6:	0f 8e 5e 01 00 00    	jle    800a3a <vprintfmt+0x63e>
  8008dc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008df:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008e2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8008e5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8008e8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008eb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8008ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8008f8:	83 ef 01             	sub    $0x1,%edi
  8008fb:	85 ff                	test   %edi,%edi
  8008fd:	7f ef                	jg     8008ee <vprintfmt+0x4f2>
  8008ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800902:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800905:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800908:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80090b:	e9 2a 01 00 00       	jmp    800a3a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800910:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800913:	83 eb 01             	sub    $0x1,%ebx
  800916:	85 db                	test   %ebx,%ebx
  800918:	0f 8e 0a fb ff ff    	jle    800428 <vprintfmt+0x2c>
  80091e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800921:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800924:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800927:	89 74 24 04          	mov    %esi,0x4(%esp)
  80092b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800932:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800934:	83 eb 01             	sub    $0x1,%ebx
  800937:	85 db                	test   %ebx,%ebx
  800939:	7f ec                	jg     800927 <vprintfmt+0x52b>
  80093b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80093e:	e9 e8 fa ff ff       	jmp    80042b <vprintfmt+0x2f>
  800943:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8d 50 04             	lea    0x4(%eax),%edx
  80094c:	89 55 14             	mov    %edx,0x14(%ebp)
  80094f:	8b 00                	mov    (%eax),%eax
  800951:	85 c0                	test   %eax,%eax
  800953:	75 2a                	jne    80097f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800955:	c7 44 24 0c e4 23 80 	movl   $0x8023e4,0xc(%esp)
  80095c:	00 
  80095d:	c7 44 24 08 c5 22 80 	movl   $0x8022c5,0x8(%esp)
  800964:	00 
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
  800968:	89 54 24 04          	mov    %edx,0x4(%esp)
  80096c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096f:	89 0c 24             	mov    %ecx,(%esp)
  800972:	e8 90 01 00 00       	call   800b07 <printfmt>
  800977:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80097a:	e9 ac fa ff ff       	jmp    80042b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80097f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800982:	8b 13                	mov    (%ebx),%edx
  800984:	83 fa 7f             	cmp    $0x7f,%edx
  800987:	7e 29                	jle    8009b2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800989:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80098b:	c7 44 24 0c 1c 24 80 	movl   $0x80241c,0xc(%esp)
  800992:	00 
  800993:	c7 44 24 08 c5 22 80 	movl   $0x8022c5,0x8(%esp)
  80099a:	00 
  80099b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	89 04 24             	mov    %eax,(%esp)
  8009a5:	e8 5d 01 00 00       	call   800b07 <printfmt>
  8009aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ad:	e9 79 fa ff ff       	jmp    80042b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8009b2:	88 10                	mov    %dl,(%eax)
  8009b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009b7:	e9 6f fa ff ff       	jmp    80042b <vprintfmt+0x2f>
  8009bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009c9:	89 14 24             	mov    %edx,(%esp)
  8009cc:	ff 55 08             	call   *0x8(%ebp)
  8009cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8009d2:	e9 54 fa ff ff       	jmp    80042b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8009eb:	80 38 25             	cmpb   $0x25,(%eax)
  8009ee:	0f 84 37 fa ff ff    	je     80042b <vprintfmt+0x2f>
  8009f4:	89 c7                	mov    %eax,%edi
  8009f6:	eb f0                	jmp    8009e8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a03:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a06:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a11:	00 
  800a12:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a15:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a1f:	e8 5c 16 00 00       	call   802080 <__umoddi3>
  800a24:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a28:	0f be 80 ab 22 80 00 	movsbl 0x8022ab(%eax),%eax
  800a2f:	89 04 24             	mov    %eax,(%esp)
  800a32:	ff 55 08             	call   *0x8(%ebp)
  800a35:	e9 d6 fe ff ff       	jmp    800910 <vprintfmt+0x514>
  800a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a41:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a45:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a4c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a53:	00 
  800a54:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a57:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a5a:	89 04 24             	mov    %eax,(%esp)
  800a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a61:	e8 1a 16 00 00       	call   802080 <__umoddi3>
  800a66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6a:	0f be 80 ab 22 80 00 	movsbl 0x8022ab(%eax),%eax
  800a71:	89 04 24             	mov    %eax,(%esp)
  800a74:	ff 55 08             	call   *0x8(%ebp)
  800a77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7a:	e9 ac f9 ff ff       	jmp    80042b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a7f:	83 c4 6c             	add    $0x6c,%esp
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	83 ec 28             	sub    $0x28,%esp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a93:	85 c0                	test   %eax,%eax
  800a95:	74 04                	je     800a9b <vsnprintf+0x14>
  800a97:	85 d2                	test   %edx,%edx
  800a99:	7f 07                	jg     800aa2 <vsnprintf+0x1b>
  800a9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aa0:	eb 3b                	jmp    800add <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aa5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ab3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aba:	8b 45 10             	mov    0x10(%ebp),%eax
  800abd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac8:	c7 04 24 df 03 80 00 	movl   $0x8003df,(%esp)
  800acf:	e8 28 f9 ff ff       	call   8003fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800add:	c9                   	leave  
  800ade:	c3                   	ret    

00800adf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800ae5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800ae8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
  800aef:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	89 04 24             	mov    %eax,(%esp)
  800b00:	e8 82 ff ff ff       	call   800a87 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b0d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b14:	8b 45 10             	mov    0x10(%ebp),%eax
  800b17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	89 04 24             	mov    %eax,(%esp)
  800b28:	e8 cf f8 ff ff       	call   8003fc <vprintfmt>
	va_end(ap);
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    
	...

00800b30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b3e:	74 09                	je     800b49 <strlen+0x19>
		n++;
  800b40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b47:	75 f7                	jne    800b40 <strlen+0x10>
		n++;
	return n;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
  800b4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b55:	85 c9                	test   %ecx,%ecx
  800b57:	74 19                	je     800b72 <strnlen+0x27>
  800b59:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b5c:	74 14                	je     800b72 <strnlen+0x27>
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b63:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b66:	39 c8                	cmp    %ecx,%eax
  800b68:	74 0d                	je     800b77 <strnlen+0x2c>
  800b6a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b6e:	75 f3                	jne    800b63 <strnlen+0x18>
  800b70:	eb 05                	jmp    800b77 <strnlen+0x2c>
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b77:	5b                   	pop    %ebx
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b8d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	84 c9                	test   %cl,%cl
  800b95:	75 f2                	jne    800b89 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b97:	5b                   	pop    %ebx
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 08             	sub    $0x8,%esp
  800ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ba4:	89 1c 24             	mov    %ebx,(%esp)
  800ba7:	e8 84 ff ff ff       	call   800b30 <strlen>
	strcpy(dst + len, src);
  800bac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800baf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bb3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bb6:	89 04 24             	mov    %eax,(%esp)
  800bb9:	e8 bc ff ff ff       	call   800b7a <strcpy>
	return dst;
}
  800bbe:	89 d8                	mov    %ebx,%eax
  800bc0:	83 c4 08             	add    $0x8,%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd4:	85 f6                	test   %esi,%esi
  800bd6:	74 18                	je     800bf0 <strncpy+0x2a>
  800bd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bdd:	0f b6 1a             	movzbl (%edx),%ebx
  800be0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be3:	80 3a 01             	cmpb   $0x1,(%edx)
  800be6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be9:	83 c1 01             	add    $0x1,%ecx
  800bec:	39 ce                	cmp    %ecx,%esi
  800bee:	77 ed                	ja     800bdd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c02:	89 f0                	mov    %esi,%eax
  800c04:	85 c9                	test   %ecx,%ecx
  800c06:	74 27                	je     800c2f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c08:	83 e9 01             	sub    $0x1,%ecx
  800c0b:	74 1d                	je     800c2a <strlcpy+0x36>
  800c0d:	0f b6 1a             	movzbl (%edx),%ebx
  800c10:	84 db                	test   %bl,%bl
  800c12:	74 16                	je     800c2a <strlcpy+0x36>
			*dst++ = *src++;
  800c14:	88 18                	mov    %bl,(%eax)
  800c16:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c19:	83 e9 01             	sub    $0x1,%ecx
  800c1c:	74 0e                	je     800c2c <strlcpy+0x38>
			*dst++ = *src++;
  800c1e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c21:	0f b6 1a             	movzbl (%edx),%ebx
  800c24:	84 db                	test   %bl,%bl
  800c26:	75 ec                	jne    800c14 <strlcpy+0x20>
  800c28:	eb 02                	jmp    800c2c <strlcpy+0x38>
  800c2a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c2c:	c6 00 00             	movb   $0x0,(%eax)
  800c2f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c3e:	0f b6 01             	movzbl (%ecx),%eax
  800c41:	84 c0                	test   %al,%al
  800c43:	74 15                	je     800c5a <strcmp+0x25>
  800c45:	3a 02                	cmp    (%edx),%al
  800c47:	75 11                	jne    800c5a <strcmp+0x25>
		p++, q++;
  800c49:	83 c1 01             	add    $0x1,%ecx
  800c4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c4f:	0f b6 01             	movzbl (%ecx),%eax
  800c52:	84 c0                	test   %al,%al
  800c54:	74 04                	je     800c5a <strcmp+0x25>
  800c56:	3a 02                	cmp    (%edx),%al
  800c58:	74 ef                	je     800c49 <strcmp+0x14>
  800c5a:	0f b6 c0             	movzbl %al,%eax
  800c5d:	0f b6 12             	movzbl (%edx),%edx
  800c60:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	53                   	push   %ebx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	74 23                	je     800c98 <strncmp+0x34>
  800c75:	0f b6 1a             	movzbl (%edx),%ebx
  800c78:	84 db                	test   %bl,%bl
  800c7a:	74 25                	je     800ca1 <strncmp+0x3d>
  800c7c:	3a 19                	cmp    (%ecx),%bl
  800c7e:	75 21                	jne    800ca1 <strncmp+0x3d>
  800c80:	83 e8 01             	sub    $0x1,%eax
  800c83:	74 13                	je     800c98 <strncmp+0x34>
		n--, p++, q++;
  800c85:	83 c2 01             	add    $0x1,%edx
  800c88:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c8b:	0f b6 1a             	movzbl (%edx),%ebx
  800c8e:	84 db                	test   %bl,%bl
  800c90:	74 0f                	je     800ca1 <strncmp+0x3d>
  800c92:	3a 19                	cmp    (%ecx),%bl
  800c94:	74 ea                	je     800c80 <strncmp+0x1c>
  800c96:	eb 09                	jmp    800ca1 <strncmp+0x3d>
  800c98:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5d                   	pop    %ebp
  800c9f:	90                   	nop
  800ca0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca1:	0f b6 02             	movzbl (%edx),%eax
  800ca4:	0f b6 11             	movzbl (%ecx),%edx
  800ca7:	29 d0                	sub    %edx,%eax
  800ca9:	eb f2                	jmp    800c9d <strncmp+0x39>

00800cab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb5:	0f b6 10             	movzbl (%eax),%edx
  800cb8:	84 d2                	test   %dl,%dl
  800cba:	74 18                	je     800cd4 <strchr+0x29>
		if (*s == c)
  800cbc:	38 ca                	cmp    %cl,%dl
  800cbe:	75 0a                	jne    800cca <strchr+0x1f>
  800cc0:	eb 17                	jmp    800cd9 <strchr+0x2e>
  800cc2:	38 ca                	cmp    %cl,%dl
  800cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc8:	74 0f                	je     800cd9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cca:	83 c0 01             	add    $0x1,%eax
  800ccd:	0f b6 10             	movzbl (%eax),%edx
  800cd0:	84 d2                	test   %dl,%dl
  800cd2:	75 ee                	jne    800cc2 <strchr+0x17>
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce5:	0f b6 10             	movzbl (%eax),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	74 18                	je     800d04 <strfind+0x29>
		if (*s == c)
  800cec:	38 ca                	cmp    %cl,%dl
  800cee:	75 0a                	jne    800cfa <strfind+0x1f>
  800cf0:	eb 12                	jmp    800d04 <strfind+0x29>
  800cf2:	38 ca                	cmp    %cl,%dl
  800cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf8:	74 0a                	je     800d04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	0f b6 10             	movzbl (%eax),%edx
  800d00:	84 d2                	test   %dl,%dl
  800d02:	75 ee                	jne    800cf2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	89 1c 24             	mov    %ebx,(%esp)
  800d0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d20:	85 c9                	test   %ecx,%ecx
  800d22:	74 30                	je     800d54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d2a:	75 25                	jne    800d51 <memset+0x4b>
  800d2c:	f6 c1 03             	test   $0x3,%cl
  800d2f:	75 20                	jne    800d51 <memset+0x4b>
		c &= 0xFF;
  800d31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	c1 e3 08             	shl    $0x8,%ebx
  800d39:	89 d6                	mov    %edx,%esi
  800d3b:	c1 e6 18             	shl    $0x18,%esi
  800d3e:	89 d0                	mov    %edx,%eax
  800d40:	c1 e0 10             	shl    $0x10,%eax
  800d43:	09 f0                	or     %esi,%eax
  800d45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d47:	09 d8                	or     %ebx,%eax
  800d49:	c1 e9 02             	shr    $0x2,%ecx
  800d4c:	fc                   	cld    
  800d4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d4f:	eb 03                	jmp    800d54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d51:	fc                   	cld    
  800d52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d54:	89 f8                	mov    %edi,%eax
  800d56:	8b 1c 24             	mov    (%esp),%ebx
  800d59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d61:	89 ec                	mov    %ebp,%esp
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
  800d6b:	89 34 24             	mov    %esi,(%esp)
  800d6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d7d:	39 c6                	cmp    %eax,%esi
  800d7f:	73 35                	jae    800db6 <memmove+0x51>
  800d81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d84:	39 d0                	cmp    %edx,%eax
  800d86:	73 2e                	jae    800db6 <memmove+0x51>
		s += n;
		d += n;
  800d88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d8a:	f6 c2 03             	test   $0x3,%dl
  800d8d:	75 1b                	jne    800daa <memmove+0x45>
  800d8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d95:	75 13                	jne    800daa <memmove+0x45>
  800d97:	f6 c1 03             	test   $0x3,%cl
  800d9a:	75 0e                	jne    800daa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d9c:	83 ef 04             	sub    $0x4,%edi
  800d9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800da2:	c1 e9 02             	shr    $0x2,%ecx
  800da5:	fd                   	std    
  800da6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da8:	eb 09                	jmp    800db3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800daa:	83 ef 01             	sub    $0x1,%edi
  800dad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800db0:	fd                   	std    
  800db1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800db3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800db4:	eb 20                	jmp    800dd6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800db6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dbc:	75 15                	jne    800dd3 <memmove+0x6e>
  800dbe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc4:	75 0d                	jne    800dd3 <memmove+0x6e>
  800dc6:	f6 c1 03             	test   $0x3,%cl
  800dc9:	75 08                	jne    800dd3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800dcb:	c1 e9 02             	shr    $0x2,%ecx
  800dce:	fc                   	cld    
  800dcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd1:	eb 03                	jmp    800dd6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dd3:	fc                   	cld    
  800dd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dd6:	8b 34 24             	mov    (%esp),%esi
  800dd9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ddd:	89 ec                	mov    %ebp,%esp
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800de7:	8b 45 10             	mov    0x10(%ebp),%eax
  800dea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	89 04 24             	mov    %eax,(%esp)
  800dfb:	e8 65 ff ff ff       	call   800d65 <memmove>
}
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	8b 75 08             	mov    0x8(%ebp),%esi
  800e0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e11:	85 c9                	test   %ecx,%ecx
  800e13:	74 36                	je     800e4b <memcmp+0x49>
		if (*s1 != *s2)
  800e15:	0f b6 06             	movzbl (%esi),%eax
  800e18:	0f b6 1f             	movzbl (%edi),%ebx
  800e1b:	38 d8                	cmp    %bl,%al
  800e1d:	74 20                	je     800e3f <memcmp+0x3d>
  800e1f:	eb 14                	jmp    800e35 <memcmp+0x33>
  800e21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e2b:	83 c2 01             	add    $0x1,%edx
  800e2e:	83 e9 01             	sub    $0x1,%ecx
  800e31:	38 d8                	cmp    %bl,%al
  800e33:	74 12                	je     800e47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e35:	0f b6 c0             	movzbl %al,%eax
  800e38:	0f b6 db             	movzbl %bl,%ebx
  800e3b:	29 d8                	sub    %ebx,%eax
  800e3d:	eb 11                	jmp    800e50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e3f:	83 e9 01             	sub    $0x1,%ecx
  800e42:	ba 00 00 00 00       	mov    $0x0,%edx
  800e47:	85 c9                	test   %ecx,%ecx
  800e49:	75 d6                	jne    800e21 <memcmp+0x1f>
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e5b:	89 c2                	mov    %eax,%edx
  800e5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e60:	39 d0                	cmp    %edx,%eax
  800e62:	73 15                	jae    800e79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e68:	38 08                	cmp    %cl,(%eax)
  800e6a:	75 06                	jne    800e72 <memfind+0x1d>
  800e6c:	eb 0b                	jmp    800e79 <memfind+0x24>
  800e6e:	38 08                	cmp    %cl,(%eax)
  800e70:	74 07                	je     800e79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e72:	83 c0 01             	add    $0x1,%eax
  800e75:	39 c2                	cmp    %eax,%edx
  800e77:	77 f5                	ja     800e6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e8a:	0f b6 02             	movzbl (%edx),%eax
  800e8d:	3c 20                	cmp    $0x20,%al
  800e8f:	74 04                	je     800e95 <strtol+0x1a>
  800e91:	3c 09                	cmp    $0x9,%al
  800e93:	75 0e                	jne    800ea3 <strtol+0x28>
		s++;
  800e95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e98:	0f b6 02             	movzbl (%edx),%eax
  800e9b:	3c 20                	cmp    $0x20,%al
  800e9d:	74 f6                	je     800e95 <strtol+0x1a>
  800e9f:	3c 09                	cmp    $0x9,%al
  800ea1:	74 f2                	je     800e95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ea3:	3c 2b                	cmp    $0x2b,%al
  800ea5:	75 0c                	jne    800eb3 <strtol+0x38>
		s++;
  800ea7:	83 c2 01             	add    $0x1,%edx
  800eaa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eb1:	eb 15                	jmp    800ec8 <strtol+0x4d>
	else if (*s == '-')
  800eb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eba:	3c 2d                	cmp    $0x2d,%al
  800ebc:	75 0a                	jne    800ec8 <strtol+0x4d>
		s++, neg = 1;
  800ebe:	83 c2 01             	add    $0x1,%edx
  800ec1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ec8:	85 db                	test   %ebx,%ebx
  800eca:	0f 94 c0             	sete   %al
  800ecd:	74 05                	je     800ed4 <strtol+0x59>
  800ecf:	83 fb 10             	cmp    $0x10,%ebx
  800ed2:	75 18                	jne    800eec <strtol+0x71>
  800ed4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ed7:	75 13                	jne    800eec <strtol+0x71>
  800ed9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800edd:	8d 76 00             	lea    0x0(%esi),%esi
  800ee0:	75 0a                	jne    800eec <strtol+0x71>
		s += 2, base = 16;
  800ee2:	83 c2 02             	add    $0x2,%edx
  800ee5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eea:	eb 15                	jmp    800f01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eec:	84 c0                	test   %al,%al
  800eee:	66 90                	xchg   %ax,%ax
  800ef0:	74 0f                	je     800f01 <strtol+0x86>
  800ef2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ef7:	80 3a 30             	cmpb   $0x30,(%edx)
  800efa:	75 05                	jne    800f01 <strtol+0x86>
		s++, base = 8;
  800efc:	83 c2 01             	add    $0x1,%edx
  800eff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f08:	0f b6 0a             	movzbl (%edx),%ecx
  800f0b:	89 cf                	mov    %ecx,%edi
  800f0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f10:	80 fb 09             	cmp    $0x9,%bl
  800f13:	77 08                	ja     800f1d <strtol+0xa2>
			dig = *s - '0';
  800f15:	0f be c9             	movsbl %cl,%ecx
  800f18:	83 e9 30             	sub    $0x30,%ecx
  800f1b:	eb 1e                	jmp    800f3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f20:	80 fb 19             	cmp    $0x19,%bl
  800f23:	77 08                	ja     800f2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f25:	0f be c9             	movsbl %cl,%ecx
  800f28:	83 e9 57             	sub    $0x57,%ecx
  800f2b:	eb 0e                	jmp    800f3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f30:	80 fb 19             	cmp    $0x19,%bl
  800f33:	77 15                	ja     800f4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f35:	0f be c9             	movsbl %cl,%ecx
  800f38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f3b:	39 f1                	cmp    %esi,%ecx
  800f3d:	7d 0b                	jge    800f4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f3f:	83 c2 01             	add    $0x1,%edx
  800f42:	0f af c6             	imul   %esi,%eax
  800f45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f48:	eb be                	jmp    800f08 <strtol+0x8d>
  800f4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f50:	74 05                	je     800f57 <strtol+0xdc>
		*endptr = (char *) s;
  800f52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f5b:	74 04                	je     800f61 <strtol+0xe6>
  800f5d:	89 c8                	mov    %ecx,%eax
  800f5f:	f7 d8                	neg    %eax
}
  800f61:	83 c4 04             	add    $0x4,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	00 00                	add    %al,(%eax)
	...

00800f6c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 08             	sub    $0x8,%esp
  800f72:	89 1c 24             	mov    %ebx,(%esp)
  800f75:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f83:	89 d1                	mov    %edx,%ecx
  800f85:	89 d3                	mov    %edx,%ebx
  800f87:	89 d7                	mov    %edx,%edi
  800f89:	51                   	push   %ecx
  800f8a:	52                   	push   %edx
  800f8b:	53                   	push   %ebx
  800f8c:	54                   	push   %esp
  800f8d:	55                   	push   %ebp
  800f8e:	56                   	push   %esi
  800f8f:	57                   	push   %edi
  800f90:	54                   	push   %esp
  800f91:	5d                   	pop    %ebp
  800f92:	8d 35 9a 0f 80 00    	lea    0x800f9a,%esi
  800f98:	0f 34                	sysenter 
  800f9a:	5f                   	pop    %edi
  800f9b:	5e                   	pop    %esi
  800f9c:	5d                   	pop    %ebp
  800f9d:	5c                   	pop    %esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5a                   	pop    %edx
  800fa0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fa1:	8b 1c 24             	mov    (%esp),%ebx
  800fa4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fa8:	89 ec                	mov    %ebp,%esp
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	89 1c 24             	mov    %ebx,(%esp)
  800fb5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	89 c3                	mov    %eax,%ebx
  800fc6:	89 c7                	mov    %eax,%edi
  800fc8:	51                   	push   %ecx
  800fc9:	52                   	push   %edx
  800fca:	53                   	push   %ebx
  800fcb:	54                   	push   %esp
  800fcc:	55                   	push   %ebp
  800fcd:	56                   	push   %esi
  800fce:	57                   	push   %edi
  800fcf:	54                   	push   %esp
  800fd0:	5d                   	pop    %ebp
  800fd1:	8d 35 d9 0f 80 00    	lea    0x800fd9,%esi
  800fd7:	0f 34                	sysenter 
  800fd9:	5f                   	pop    %edi
  800fda:	5e                   	pop    %esi
  800fdb:	5d                   	pop    %ebp
  800fdc:	5c                   	pop    %esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5a                   	pop    %edx
  800fdf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fe0:	8b 1c 24             	mov    (%esp),%ebx
  800fe3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe7:	89 ec                	mov    %ebp,%esp
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    

00800feb <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	89 1c 24             	mov    %ebx,(%esp)
  800ff4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff8:	b8 10 00 00 00       	mov    $0x10,%eax
  800ffd:	8b 7d 14             	mov    0x14(%ebp),%edi
  801000:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801003:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801006:	8b 55 08             	mov    0x8(%ebp),%edx
  801009:	51                   	push   %ecx
  80100a:	52                   	push   %edx
  80100b:	53                   	push   %ebx
  80100c:	54                   	push   %esp
  80100d:	55                   	push   %ebp
  80100e:	56                   	push   %esi
  80100f:	57                   	push   %edi
  801010:	54                   	push   %esp
  801011:	5d                   	pop    %ebp
  801012:	8d 35 1a 10 80 00    	lea    0x80101a,%esi
  801018:	0f 34                	sysenter 
  80101a:	5f                   	pop    %edi
  80101b:	5e                   	pop    %esi
  80101c:	5d                   	pop    %ebp
  80101d:	5c                   	pop    %esp
  80101e:	5b                   	pop    %ebx
  80101f:	5a                   	pop    %edx
  801020:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801021:	8b 1c 24             	mov    (%esp),%ebx
  801024:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801028:	89 ec                	mov    %ebp,%esp
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 28             	sub    $0x28,%esp
  801032:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801035:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801038:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801045:	8b 55 08             	mov    0x8(%ebp),%edx
  801048:	89 df                	mov    %ebx,%edi
  80104a:	51                   	push   %ecx
  80104b:	52                   	push   %edx
  80104c:	53                   	push   %ebx
  80104d:	54                   	push   %esp
  80104e:	55                   	push   %ebp
  80104f:	56                   	push   %esi
  801050:	57                   	push   %edi
  801051:	54                   	push   %esp
  801052:	5d                   	pop    %ebp
  801053:	8d 35 5b 10 80 00    	lea    0x80105b,%esi
  801059:	0f 34                	sysenter 
  80105b:	5f                   	pop    %edi
  80105c:	5e                   	pop    %esi
  80105d:	5d                   	pop    %ebp
  80105e:	5c                   	pop    %esp
  80105f:	5b                   	pop    %ebx
  801060:	5a                   	pop    %edx
  801061:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801062:	85 c0                	test   %eax,%eax
  801064:	7e 28                	jle    80108e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801066:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801071:	00 
  801072:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  801079:	00 
  80107a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801081:	00 
  801082:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  801089:	e8 fe f0 ff ff       	call   80018c <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80108e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801091:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801094:	89 ec                	mov    %ebp,%esp
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 08             	sub    $0x8,%esp
  80109e:	89 1c 24             	mov    %ebx,(%esp)
  8010a1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010aa:	b8 11 00 00 00       	mov    $0x11,%eax
  8010af:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b2:	89 cb                	mov    %ecx,%ebx
  8010b4:	89 cf                	mov    %ecx,%edi
  8010b6:	51                   	push   %ecx
  8010b7:	52                   	push   %edx
  8010b8:	53                   	push   %ebx
  8010b9:	54                   	push   %esp
  8010ba:	55                   	push   %ebp
  8010bb:	56                   	push   %esi
  8010bc:	57                   	push   %edi
  8010bd:	54                   	push   %esp
  8010be:	5d                   	pop    %ebp
  8010bf:	8d 35 c7 10 80 00    	lea    0x8010c7,%esi
  8010c5:	0f 34                	sysenter 
  8010c7:	5f                   	pop    %edi
  8010c8:	5e                   	pop    %esi
  8010c9:	5d                   	pop    %ebp
  8010ca:	5c                   	pop    %esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5a                   	pop    %edx
  8010cd:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010ce:	8b 1c 24             	mov    (%esp),%ebx
  8010d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d5:	89 ec                	mov    %ebp,%esp
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	83 ec 28             	sub    $0x28,%esp
  8010df:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010e2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ea:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f2:	89 cb                	mov    %ecx,%ebx
  8010f4:	89 cf                	mov    %ecx,%edi
  8010f6:	51                   	push   %ecx
  8010f7:	52                   	push   %edx
  8010f8:	53                   	push   %ebx
  8010f9:	54                   	push   %esp
  8010fa:	55                   	push   %ebp
  8010fb:	56                   	push   %esi
  8010fc:	57                   	push   %edi
  8010fd:	54                   	push   %esp
  8010fe:	5d                   	pop    %ebp
  8010ff:	8d 35 07 11 80 00    	lea    0x801107,%esi
  801105:	0f 34                	sysenter 
  801107:	5f                   	pop    %edi
  801108:	5e                   	pop    %esi
  801109:	5d                   	pop    %ebp
  80110a:	5c                   	pop    %esp
  80110b:	5b                   	pop    %ebx
  80110c:	5a                   	pop    %edx
  80110d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80110e:	85 c0                	test   %eax,%eax
  801110:	7e 28                	jle    80113a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801112:	89 44 24 10          	mov    %eax,0x10(%esp)
  801116:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80111d:	00 
  80111e:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  801125:	00 
  801126:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80112d:	00 
  80112e:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  801135:	e8 52 f0 ff ff       	call   80018c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80113a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80113d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801140:	89 ec                	mov    %ebp,%esp
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	89 1c 24             	mov    %ebx,(%esp)
  80114d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801151:	b8 0d 00 00 00       	mov    $0xd,%eax
  801156:	8b 7d 14             	mov    0x14(%ebp),%edi
  801159:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80115c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115f:	8b 55 08             	mov    0x8(%ebp),%edx
  801162:	51                   	push   %ecx
  801163:	52                   	push   %edx
  801164:	53                   	push   %ebx
  801165:	54                   	push   %esp
  801166:	55                   	push   %ebp
  801167:	56                   	push   %esi
  801168:	57                   	push   %edi
  801169:	54                   	push   %esp
  80116a:	5d                   	pop    %ebp
  80116b:	8d 35 73 11 80 00    	lea    0x801173,%esi
  801171:	0f 34                	sysenter 
  801173:	5f                   	pop    %edi
  801174:	5e                   	pop    %esi
  801175:	5d                   	pop    %ebp
  801176:	5c                   	pop    %esp
  801177:	5b                   	pop    %ebx
  801178:	5a                   	pop    %edx
  801179:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80117a:	8b 1c 24             	mov    (%esp),%ebx
  80117d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801181:	89 ec                	mov    %ebp,%esp
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 28             	sub    $0x28,%esp
  80118b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80118e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801191:	bb 00 00 00 00       	mov    $0x0,%ebx
  801196:	b8 0b 00 00 00       	mov    $0xb,%eax
  80119b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119e:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a1:	89 df                	mov    %ebx,%edi
  8011a3:	51                   	push   %ecx
  8011a4:	52                   	push   %edx
  8011a5:	53                   	push   %ebx
  8011a6:	54                   	push   %esp
  8011a7:	55                   	push   %ebp
  8011a8:	56                   	push   %esi
  8011a9:	57                   	push   %edi
  8011aa:	54                   	push   %esp
  8011ab:	5d                   	pop    %ebp
  8011ac:	8d 35 b4 11 80 00    	lea    0x8011b4,%esi
  8011b2:	0f 34                	sysenter 
  8011b4:	5f                   	pop    %edi
  8011b5:	5e                   	pop    %esi
  8011b6:	5d                   	pop    %ebp
  8011b7:	5c                   	pop    %esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5a                   	pop    %edx
  8011ba:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	7e 28                	jle    8011e7 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8011d2:	00 
  8011d3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011da:	00 
  8011db:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  8011e2:	e8 a5 ef ff ff       	call   80018c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011e7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ed:	89 ec                	mov    %ebp,%esp
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	83 ec 28             	sub    $0x28,%esp
  8011f7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011fa:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801202:	b8 0a 00 00 00       	mov    $0xa,%eax
  801207:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120a:	8b 55 08             	mov    0x8(%ebp),%edx
  80120d:	89 df                	mov    %ebx,%edi
  80120f:	51                   	push   %ecx
  801210:	52                   	push   %edx
  801211:	53                   	push   %ebx
  801212:	54                   	push   %esp
  801213:	55                   	push   %ebp
  801214:	56                   	push   %esi
  801215:	57                   	push   %edi
  801216:	54                   	push   %esp
  801217:	5d                   	pop    %ebp
  801218:	8d 35 20 12 80 00    	lea    0x801220,%esi
  80121e:	0f 34                	sysenter 
  801220:	5f                   	pop    %edi
  801221:	5e                   	pop    %esi
  801222:	5d                   	pop    %ebp
  801223:	5c                   	pop    %esp
  801224:	5b                   	pop    %ebx
  801225:	5a                   	pop    %edx
  801226:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801227:	85 c0                	test   %eax,%eax
  801229:	7e 28                	jle    801253 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801236:	00 
  801237:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  80123e:	00 
  80123f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801246:	00 
  801247:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  80124e:	e8 39 ef ff ff       	call   80018c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801253:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801256:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801259:	89 ec                	mov    %ebp,%esp
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	83 ec 28             	sub    $0x28,%esp
  801263:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801266:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801269:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126e:	b8 09 00 00 00       	mov    $0x9,%eax
  801273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801276:	8b 55 08             	mov    0x8(%ebp),%edx
  801279:	89 df                	mov    %ebx,%edi
  80127b:	51                   	push   %ecx
  80127c:	52                   	push   %edx
  80127d:	53                   	push   %ebx
  80127e:	54                   	push   %esp
  80127f:	55                   	push   %ebp
  801280:	56                   	push   %esi
  801281:	57                   	push   %edi
  801282:	54                   	push   %esp
  801283:	5d                   	pop    %ebp
  801284:	8d 35 8c 12 80 00    	lea    0x80128c,%esi
  80128a:	0f 34                	sysenter 
  80128c:	5f                   	pop    %edi
  80128d:	5e                   	pop    %esi
  80128e:	5d                   	pop    %ebp
  80128f:	5c                   	pop    %esp
  801290:	5b                   	pop    %ebx
  801291:	5a                   	pop    %edx
  801292:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801293:	85 c0                	test   %eax,%eax
  801295:	7e 28                	jle    8012bf <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801297:	89 44 24 10          	mov    %eax,0x10(%esp)
  80129b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012a2:	00 
  8012a3:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8012aa:	00 
  8012ab:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012b2:	00 
  8012b3:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  8012ba:	e8 cd ee ff ff       	call   80018c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012bf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012c5:	89 ec                	mov    %ebp,%esp
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	83 ec 28             	sub    $0x28,%esp
  8012cf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012d2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012da:	b8 07 00 00 00       	mov    $0x7,%eax
  8012df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e5:	89 df                	mov    %ebx,%edi
  8012e7:	51                   	push   %ecx
  8012e8:	52                   	push   %edx
  8012e9:	53                   	push   %ebx
  8012ea:	54                   	push   %esp
  8012eb:	55                   	push   %ebp
  8012ec:	56                   	push   %esi
  8012ed:	57                   	push   %edi
  8012ee:	54                   	push   %esp
  8012ef:	5d                   	pop    %ebp
  8012f0:	8d 35 f8 12 80 00    	lea    0x8012f8,%esi
  8012f6:	0f 34                	sysenter 
  8012f8:	5f                   	pop    %edi
  8012f9:	5e                   	pop    %esi
  8012fa:	5d                   	pop    %ebp
  8012fb:	5c                   	pop    %esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5a                   	pop    %edx
  8012fe:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ff:	85 c0                	test   %eax,%eax
  801301:	7e 28                	jle    80132b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801303:	89 44 24 10          	mov    %eax,0x10(%esp)
  801307:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80130e:	00 
  80130f:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  801326:	e8 61 ee ff ff       	call   80018c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80132b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80132e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801331:	89 ec                	mov    %ebp,%esp
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 28             	sub    $0x28,%esp
  80133b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80133e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801341:	8b 7d 18             	mov    0x18(%ebp),%edi
  801344:	0b 7d 14             	or     0x14(%ebp),%edi
  801347:	b8 06 00 00 00       	mov    $0x6,%eax
  80134c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801352:	8b 55 08             	mov    0x8(%ebp),%edx
  801355:	51                   	push   %ecx
  801356:	52                   	push   %edx
  801357:	53                   	push   %ebx
  801358:	54                   	push   %esp
  801359:	55                   	push   %ebp
  80135a:	56                   	push   %esi
  80135b:	57                   	push   %edi
  80135c:	54                   	push   %esp
  80135d:	5d                   	pop    %ebp
  80135e:	8d 35 66 13 80 00    	lea    0x801366,%esi
  801364:	0f 34                	sysenter 
  801366:	5f                   	pop    %edi
  801367:	5e                   	pop    %esi
  801368:	5d                   	pop    %ebp
  801369:	5c                   	pop    %esp
  80136a:	5b                   	pop    %ebx
  80136b:	5a                   	pop    %edx
  80136c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80136d:	85 c0                	test   %eax,%eax
  80136f:	7e 28                	jle    801399 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801371:	89 44 24 10          	mov    %eax,0x10(%esp)
  801375:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80137c:	00 
  80137d:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  801384:	00 
  801385:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80138c:	00 
  80138d:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  801394:	e8 f3 ed ff ff       	call   80018c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801399:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80139c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139f:	89 ec                	mov    %ebp,%esp
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 28             	sub    $0x28,%esp
  8013a9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013ac:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013af:	bf 00 00 00 00       	mov    $0x0,%edi
  8013b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c2:	51                   	push   %ecx
  8013c3:	52                   	push   %edx
  8013c4:	53                   	push   %ebx
  8013c5:	54                   	push   %esp
  8013c6:	55                   	push   %ebp
  8013c7:	56                   	push   %esi
  8013c8:	57                   	push   %edi
  8013c9:	54                   	push   %esp
  8013ca:	5d                   	pop    %ebp
  8013cb:	8d 35 d3 13 80 00    	lea    0x8013d3,%esi
  8013d1:	0f 34                	sysenter 
  8013d3:	5f                   	pop    %edi
  8013d4:	5e                   	pop    %esi
  8013d5:	5d                   	pop    %ebp
  8013d6:	5c                   	pop    %esp
  8013d7:	5b                   	pop    %ebx
  8013d8:	5a                   	pop    %edx
  8013d9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	7e 28                	jle    801406 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013e9:	00 
  8013ea:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  801401:	e8 86 ed ff ff       	call   80018c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801406:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801409:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80140c:	89 ec                	mov    %ebp,%esp
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	89 1c 24             	mov    %ebx,(%esp)
  801419:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
  801422:	b8 0c 00 00 00       	mov    $0xc,%eax
  801427:	89 d1                	mov    %edx,%ecx
  801429:	89 d3                	mov    %edx,%ebx
  80142b:	89 d7                	mov    %edx,%edi
  80142d:	51                   	push   %ecx
  80142e:	52                   	push   %edx
  80142f:	53                   	push   %ebx
  801430:	54                   	push   %esp
  801431:	55                   	push   %ebp
  801432:	56                   	push   %esi
  801433:	57                   	push   %edi
  801434:	54                   	push   %esp
  801435:	5d                   	pop    %ebp
  801436:	8d 35 3e 14 80 00    	lea    0x80143e,%esi
  80143c:	0f 34                	sysenter 
  80143e:	5f                   	pop    %edi
  80143f:	5e                   	pop    %esi
  801440:	5d                   	pop    %ebp
  801441:	5c                   	pop    %esp
  801442:	5b                   	pop    %ebx
  801443:	5a                   	pop    %edx
  801444:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801445:	8b 1c 24             	mov    (%esp),%ebx
  801448:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80144c:	89 ec                	mov    %ebp,%esp
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	89 1c 24             	mov    %ebx,(%esp)
  801459:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80145d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801462:	b8 04 00 00 00       	mov    $0x4,%eax
  801467:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80146a:	8b 55 08             	mov    0x8(%ebp),%edx
  80146d:	89 df                	mov    %ebx,%edi
  80146f:	51                   	push   %ecx
  801470:	52                   	push   %edx
  801471:	53                   	push   %ebx
  801472:	54                   	push   %esp
  801473:	55                   	push   %ebp
  801474:	56                   	push   %esi
  801475:	57                   	push   %edi
  801476:	54                   	push   %esp
  801477:	5d                   	pop    %ebp
  801478:	8d 35 80 14 80 00    	lea    0x801480,%esi
  80147e:	0f 34                	sysenter 
  801480:	5f                   	pop    %edi
  801481:	5e                   	pop    %esi
  801482:	5d                   	pop    %ebp
  801483:	5c                   	pop    %esp
  801484:	5b                   	pop    %ebx
  801485:	5a                   	pop    %edx
  801486:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801487:	8b 1c 24             	mov    (%esp),%ebx
  80148a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80148e:	89 ec                	mov    %ebp,%esp
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	89 1c 24             	mov    %ebx,(%esp)
  80149b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80149f:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a9:	89 d1                	mov    %edx,%ecx
  8014ab:	89 d3                	mov    %edx,%ebx
  8014ad:	89 d7                	mov    %edx,%edi
  8014af:	51                   	push   %ecx
  8014b0:	52                   	push   %edx
  8014b1:	53                   	push   %ebx
  8014b2:	54                   	push   %esp
  8014b3:	55                   	push   %ebp
  8014b4:	56                   	push   %esi
  8014b5:	57                   	push   %edi
  8014b6:	54                   	push   %esp
  8014b7:	5d                   	pop    %ebp
  8014b8:	8d 35 c0 14 80 00    	lea    0x8014c0,%esi
  8014be:	0f 34                	sysenter 
  8014c0:	5f                   	pop    %edi
  8014c1:	5e                   	pop    %esi
  8014c2:	5d                   	pop    %ebp
  8014c3:	5c                   	pop    %esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5a                   	pop    %edx
  8014c6:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014c7:	8b 1c 24             	mov    (%esp),%ebx
  8014ca:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014ce:	89 ec                	mov    %ebp,%esp
  8014d0:	5d                   	pop    %ebp
  8014d1:	c3                   	ret    

008014d2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 28             	sub    $0x28,%esp
  8014d8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014db:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014eb:	89 cb                	mov    %ecx,%ebx
  8014ed:	89 cf                	mov    %ecx,%edi
  8014ef:	51                   	push   %ecx
  8014f0:	52                   	push   %edx
  8014f1:	53                   	push   %ebx
  8014f2:	54                   	push   %esp
  8014f3:	55                   	push   %ebp
  8014f4:	56                   	push   %esi
  8014f5:	57                   	push   %edi
  8014f6:	54                   	push   %esp
  8014f7:	5d                   	pop    %ebp
  8014f8:	8d 35 00 15 80 00    	lea    0x801500,%esi
  8014fe:	0f 34                	sysenter 
  801500:	5f                   	pop    %edi
  801501:	5e                   	pop    %esi
  801502:	5d                   	pop    %ebp
  801503:	5c                   	pop    %esp
  801504:	5b                   	pop    %ebx
  801505:	5a                   	pop    %edx
  801506:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801507:	85 c0                	test   %eax,%eax
  801509:	7e 28                	jle    801533 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80150b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80150f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801516:	00 
  801517:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  80151e:	00 
  80151f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801526:	00 
  801527:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  80152e:	e8 59 ec ff ff       	call   80018c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801533:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801536:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801539:	89 ec                	mov    %ebp,%esp
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    
  80153d:	00 00                	add    %al,(%eax)
	...

00801540 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	8b 45 08             	mov    0x8(%ebp),%eax
  801546:	05 00 00 00 30       	add    $0x30000000,%eax
  80154b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	89 04 24             	mov    %eax,(%esp)
  80155c:	e8 df ff ff ff       	call   801540 <fd2num>
  801561:	05 20 00 0d 00       	add    $0xd0020,%eax
  801566:	c1 e0 0c             	shl    $0xc,%eax
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	57                   	push   %edi
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801574:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801579:	a8 01                	test   $0x1,%al
  80157b:	74 36                	je     8015b3 <fd_alloc+0x48>
  80157d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801582:	a8 01                	test   $0x1,%al
  801584:	74 2d                	je     8015b3 <fd_alloc+0x48>
  801586:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80158b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801590:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801595:	89 c3                	mov    %eax,%ebx
  801597:	89 c2                	mov    %eax,%edx
  801599:	c1 ea 16             	shr    $0x16,%edx
  80159c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80159f:	f6 c2 01             	test   $0x1,%dl
  8015a2:	74 14                	je     8015b8 <fd_alloc+0x4d>
  8015a4:	89 c2                	mov    %eax,%edx
  8015a6:	c1 ea 0c             	shr    $0xc,%edx
  8015a9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8015ac:	f6 c2 01             	test   $0x1,%dl
  8015af:	75 10                	jne    8015c1 <fd_alloc+0x56>
  8015b1:	eb 05                	jmp    8015b8 <fd_alloc+0x4d>
  8015b3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8015b8:	89 1f                	mov    %ebx,(%edi)
  8015ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015bf:	eb 17                	jmp    8015d8 <fd_alloc+0x6d>
  8015c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015cb:	75 c8                	jne    801595 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8015d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5f                   	pop    %edi
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	83 f8 1f             	cmp    $0x1f,%eax
  8015e6:	77 36                	ja     80161e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015e8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8015ed:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	c1 ea 16             	shr    $0x16,%edx
  8015f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015fc:	f6 c2 01             	test   $0x1,%dl
  8015ff:	74 1d                	je     80161e <fd_lookup+0x41>
  801601:	89 c2                	mov    %eax,%edx
  801603:	c1 ea 0c             	shr    $0xc,%edx
  801606:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80160d:	f6 c2 01             	test   $0x1,%dl
  801610:	74 0c                	je     80161e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801612:	8b 55 0c             	mov    0xc(%ebp),%edx
  801615:	89 02                	mov    %eax,(%edx)
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80161c:	eb 05                	jmp    801623 <fd_lookup+0x46>
  80161e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80162e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801632:	8b 45 08             	mov    0x8(%ebp),%eax
  801635:	89 04 24             	mov    %eax,(%esp)
  801638:	e8 a0 ff ff ff       	call   8015dd <fd_lookup>
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 0e                	js     80164f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801641:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801644:	8b 55 0c             	mov    0xc(%ebp),%edx
  801647:	89 50 04             	mov    %edx,0x4(%eax)
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	56                   	push   %esi
  801655:	53                   	push   %ebx
  801656:	83 ec 10             	sub    $0x10,%esp
  801659:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80165f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801664:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801669:	be cc 26 80 00       	mov    $0x8026cc,%esi
		if (devtab[i]->dev_id == dev_id) {
  80166e:	39 08                	cmp    %ecx,(%eax)
  801670:	75 10                	jne    801682 <dev_lookup+0x31>
  801672:	eb 04                	jmp    801678 <dev_lookup+0x27>
  801674:	39 08                	cmp    %ecx,(%eax)
  801676:	75 0a                	jne    801682 <dev_lookup+0x31>
			*dev = devtab[i];
  801678:	89 03                	mov    %eax,(%ebx)
  80167a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80167f:	90                   	nop
  801680:	eb 31                	jmp    8016b3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801682:	83 c2 01             	add    $0x1,%edx
  801685:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801688:	85 c0                	test   %eax,%eax
  80168a:	75 e8                	jne    801674 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80168c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801691:	8b 40 48             	mov    0x48(%eax),%eax
  801694:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169c:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  8016a3:	e8 9d eb ff ff       	call   800245 <cprintf>
	*dev = 0;
  8016a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 24             	sub    $0x24,%esp
  8016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ce:	89 04 24             	mov    %eax,(%esp)
  8016d1:	e8 07 ff ff ff       	call   8015dd <fd_lookup>
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 53                	js     80172d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e4:	8b 00                	mov    (%eax),%eax
  8016e6:	89 04 24             	mov    %eax,(%esp)
  8016e9:	e8 63 ff ff ff       	call   801651 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 3b                	js     80172d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8016f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fa:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8016fe:	74 2d                	je     80172d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801700:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801703:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170a:	00 00 00 
	stat->st_isdir = 0;
  80170d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801714:	00 00 00 
	stat->st_dev = dev;
  801717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801724:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801727:	89 14 24             	mov    %edx,(%esp)
  80172a:	ff 50 14             	call   *0x14(%eax)
}
  80172d:	83 c4 24             	add    $0x24,%esp
  801730:	5b                   	pop    %ebx
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	53                   	push   %ebx
  801737:	83 ec 24             	sub    $0x24,%esp
  80173a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801740:	89 44 24 04          	mov    %eax,0x4(%esp)
  801744:	89 1c 24             	mov    %ebx,(%esp)
  801747:	e8 91 fe ff ff       	call   8015dd <fd_lookup>
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 5f                	js     8017af <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801753:	89 44 24 04          	mov    %eax,0x4(%esp)
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175a:	8b 00                	mov    (%eax),%eax
  80175c:	89 04 24             	mov    %eax,(%esp)
  80175f:	e8 ed fe ff ff       	call   801651 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801764:	85 c0                	test   %eax,%eax
  801766:	78 47                	js     8017af <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801768:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80176b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80176f:	75 23                	jne    801794 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801771:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801776:	8b 40 48             	mov    0x48(%eax),%eax
  801779:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  801788:	e8 b8 ea ff ff       	call   800245 <cprintf>
  80178d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801792:	eb 1b                	jmp    8017af <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	8b 48 18             	mov    0x18(%eax),%ecx
  80179a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80179f:	85 c9                	test   %ecx,%ecx
  8017a1:	74 0c                	je     8017af <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017aa:	89 14 24             	mov    %edx,(%esp)
  8017ad:	ff d1                	call   *%ecx
}
  8017af:	83 c4 24             	add    $0x24,%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 24             	sub    $0x24,%esp
  8017bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c6:	89 1c 24             	mov    %ebx,(%esp)
  8017c9:	e8 0f fe ff ff       	call   8015dd <fd_lookup>
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 66                	js     801838 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017dc:	8b 00                	mov    (%eax),%eax
  8017de:	89 04 24             	mov    %eax,(%esp)
  8017e1:	e8 6b fe ff ff       	call   801651 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 4e                	js     801838 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017ed:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017f1:	75 23                	jne    801816 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f3:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8017f8:	8b 40 48             	mov    0x48(%eax),%eax
  8017fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	c7 04 24 90 26 80 00 	movl   $0x802690,(%esp)
  80180a:	e8 36 ea ff ff       	call   800245 <cprintf>
  80180f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801814:	eb 22                	jmp    801838 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801816:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801819:	8b 48 0c             	mov    0xc(%eax),%ecx
  80181c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801821:	85 c9                	test   %ecx,%ecx
  801823:	74 13                	je     801838 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801825:	8b 45 10             	mov    0x10(%ebp),%eax
  801828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80182c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	89 14 24             	mov    %edx,(%esp)
  801836:	ff d1                	call   *%ecx
}
  801838:	83 c4 24             	add    $0x24,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	53                   	push   %ebx
  801842:	83 ec 24             	sub    $0x24,%esp
  801845:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801848:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	89 1c 24             	mov    %ebx,(%esp)
  801852:	e8 86 fd ff ff       	call   8015dd <fd_lookup>
  801857:	85 c0                	test   %eax,%eax
  801859:	78 6b                	js     8018c6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80185b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801865:	8b 00                	mov    (%eax),%eax
  801867:	89 04 24             	mov    %eax,(%esp)
  80186a:	e8 e2 fd ff ff       	call   801651 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 53                	js     8018c6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801873:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801876:	8b 42 08             	mov    0x8(%edx),%eax
  801879:	83 e0 03             	and    $0x3,%eax
  80187c:	83 f8 01             	cmp    $0x1,%eax
  80187f:	75 23                	jne    8018a4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801881:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801886:	8b 40 48             	mov    0x48(%eax),%eax
  801889:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	c7 04 24 ad 26 80 00 	movl   $0x8026ad,(%esp)
  801898:	e8 a8 e9 ff ff       	call   800245 <cprintf>
  80189d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018a2:	eb 22                	jmp    8018c6 <read+0x88>
	}
	if (!dev->dev_read)
  8018a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a7:	8b 48 08             	mov    0x8(%eax),%ecx
  8018aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018af:	85 c9                	test   %ecx,%ecx
  8018b1:	74 13                	je     8018c6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	89 14 24             	mov    %edx,(%esp)
  8018c4:	ff d1                	call   *%ecx
}
  8018c6:	83 c4 24             	add    $0x24,%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	57                   	push   %edi
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 1c             	sub    $0x1c,%esp
  8018d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ea:	85 f6                	test   %esi,%esi
  8018ec:	74 29                	je     801917 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018ee:	89 f0                	mov    %esi,%eax
  8018f0:	29 d0                	sub    %edx,%eax
  8018f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f6:	03 55 0c             	add    0xc(%ebp),%edx
  8018f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018fd:	89 3c 24             	mov    %edi,(%esp)
  801900:	e8 39 ff ff ff       	call   80183e <read>
		if (m < 0)
  801905:	85 c0                	test   %eax,%eax
  801907:	78 0e                	js     801917 <readn+0x4b>
			return m;
		if (m == 0)
  801909:	85 c0                	test   %eax,%eax
  80190b:	74 08                	je     801915 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80190d:	01 c3                	add    %eax,%ebx
  80190f:	89 da                	mov    %ebx,%edx
  801911:	39 f3                	cmp    %esi,%ebx
  801913:	72 d9                	jb     8018ee <readn+0x22>
  801915:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801917:	83 c4 1c             	add    $0x1c,%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5f                   	pop    %edi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	83 ec 20             	sub    $0x20,%esp
  801927:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80192a:	89 34 24             	mov    %esi,(%esp)
  80192d:	e8 0e fc ff ff       	call   801540 <fd2num>
  801932:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801935:	89 54 24 04          	mov    %edx,0x4(%esp)
  801939:	89 04 24             	mov    %eax,(%esp)
  80193c:	e8 9c fc ff ff       	call   8015dd <fd_lookup>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	85 c0                	test   %eax,%eax
  801945:	78 05                	js     80194c <fd_close+0x2d>
  801947:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80194a:	74 0c                	je     801958 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80194c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801950:	19 c0                	sbb    %eax,%eax
  801952:	f7 d0                	not    %eax
  801954:	21 c3                	and    %eax,%ebx
  801956:	eb 3d                	jmp    801995 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801958:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195f:	8b 06                	mov    (%esi),%eax
  801961:	89 04 24             	mov    %eax,(%esp)
  801964:	e8 e8 fc ff ff       	call   801651 <dev_lookup>
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 16                	js     801985 <fd_close+0x66>
		if (dev->dev_close)
  80196f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801972:	8b 40 10             	mov    0x10(%eax),%eax
  801975:	bb 00 00 00 00       	mov    $0x0,%ebx
  80197a:	85 c0                	test   %eax,%eax
  80197c:	74 07                	je     801985 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80197e:	89 34 24             	mov    %esi,(%esp)
  801981:	ff d0                	call   *%eax
  801983:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801985:	89 74 24 04          	mov    %esi,0x4(%esp)
  801989:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801990:	e8 34 f9 ff ff       	call   8012c9 <sys_page_unmap>
	return r;
}
  801995:	89 d8                	mov    %ebx,%eax
  801997:	83 c4 20             	add    $0x20,%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	89 04 24             	mov    %eax,(%esp)
  8019b1:	e8 27 fc ff ff       	call   8015dd <fd_lookup>
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 13                	js     8019cd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019c1:	00 
  8019c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c5:	89 04 24             	mov    %eax,(%esp)
  8019c8:	e8 52 ff ff ff       	call   80191f <fd_close>
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 18             	sub    $0x18,%esp
  8019d5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019d8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019e2:	00 
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	89 04 24             	mov    %eax,(%esp)
  8019e9:	e8 79 03 00 00       	call   801d67 <open>
  8019ee:	89 c3                	mov    %eax,%ebx
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 1b                	js     801a0f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8019f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	89 1c 24             	mov    %ebx,(%esp)
  8019fe:	e8 b7 fc ff ff       	call   8016ba <fstat>
  801a03:	89 c6                	mov    %eax,%esi
	close(fd);
  801a05:	89 1c 24             	mov    %ebx,(%esp)
  801a08:	e8 91 ff ff ff       	call   80199e <close>
  801a0d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a0f:	89 d8                	mov    %ebx,%eax
  801a11:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a14:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a17:	89 ec                	mov    %ebp,%esp
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 14             	sub    $0x14,%esp
  801a22:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a27:	89 1c 24             	mov    %ebx,(%esp)
  801a2a:	e8 6f ff ff ff       	call   80199e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a2f:	83 c3 01             	add    $0x1,%ebx
  801a32:	83 fb 20             	cmp    $0x20,%ebx
  801a35:	75 f0                	jne    801a27 <close_all+0xc>
		close(i);
}
  801a37:	83 c4 14             	add    $0x14,%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	83 ec 58             	sub    $0x58,%esp
  801a43:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a46:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a49:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a4c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	89 04 24             	mov    %eax,(%esp)
  801a5c:	e8 7c fb ff ff       	call   8015dd <fd_lookup>
  801a61:	89 c3                	mov    %eax,%ebx
  801a63:	85 c0                	test   %eax,%eax
  801a65:	0f 88 e0 00 00 00    	js     801b4b <dup+0x10e>
		return r;
	close(newfdnum);
  801a6b:	89 3c 24             	mov    %edi,(%esp)
  801a6e:	e8 2b ff ff ff       	call   80199e <close>

	newfd = INDEX2FD(newfdnum);
  801a73:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a79:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7f:	89 04 24             	mov    %eax,(%esp)
  801a82:	e8 c9 fa ff ff       	call   801550 <fd2data>
  801a87:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a89:	89 34 24             	mov    %esi,(%esp)
  801a8c:	e8 bf fa ff ff       	call   801550 <fd2data>
  801a91:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801a94:	89 da                	mov    %ebx,%edx
  801a96:	89 d8                	mov    %ebx,%eax
  801a98:	c1 e8 16             	shr    $0x16,%eax
  801a9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801aa2:	a8 01                	test   $0x1,%al
  801aa4:	74 43                	je     801ae9 <dup+0xac>
  801aa6:	c1 ea 0c             	shr    $0xc,%edx
  801aa9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ab0:	a8 01                	test   $0x1,%al
  801ab2:	74 35                	je     801ae9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ab4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801abb:	25 07 0e 00 00       	and    $0xe07,%eax
  801ac0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ac4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ac7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801acb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ad2:	00 
  801ad3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ad7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ade:	e8 52 f8 ff ff       	call   801335 <sys_page_map>
  801ae3:	89 c3                	mov    %eax,%ebx
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 3f                	js     801b28 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ae9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aec:	89 c2                	mov    %eax,%edx
  801aee:	c1 ea 0c             	shr    $0xc,%edx
  801af1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801af8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801afe:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b02:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b06:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b0d:	00 
  801b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b19:	e8 17 f8 ff ff       	call   801335 <sys_page_map>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 04                	js     801b28 <dup+0xeb>
  801b24:	89 fb                	mov    %edi,%ebx
  801b26:	eb 23                	jmp    801b4b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b33:	e8 91 f7 ff ff       	call   8012c9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b46:	e8 7e f7 ff ff       	call   8012c9 <sys_page_unmap>
	return r;
}
  801b4b:	89 d8                	mov    %ebx,%eax
  801b4d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b50:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b53:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b56:	89 ec                	mov    %ebp,%esp
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    
	...

00801b5c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 18             	sub    $0x18,%esp
  801b62:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b65:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b68:	89 c3                	mov    %eax,%ebx
  801b6a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b6c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b73:	75 11                	jne    801b86 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b75:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b7c:	e8 8f 02 00 00       	call   801e10 <ipc_find_env>
  801b81:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b86:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b8d:	00 
  801b8e:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  801b95:	00 
  801b96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b9a:	a1 00 40 80 00       	mov    0x804000,%eax
  801b9f:	89 04 24             	mov    %eax,(%esp)
  801ba2:	e8 b4 02 00 00       	call   801e5b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ba7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bae:	00 
  801baf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bba:	e8 1a 03 00 00       	call   801ed9 <ipc_recv>
}
  801bbf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bc2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bc5:	89 ec                	mov    %ebp,%esp
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd5:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdd:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801be2:	ba 00 00 00 00       	mov    $0x0,%edx
  801be7:	b8 02 00 00 00       	mov    $0x2,%eax
  801bec:	e8 6b ff ff ff       	call   801b5c <fsipc>
}
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	8b 40 0c             	mov    0xc(%eax),%eax
  801bff:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801c04:	ba 00 00 00 00       	mov    $0x0,%edx
  801c09:	b8 06 00 00 00       	mov    $0x6,%eax
  801c0e:	e8 49 ff ff ff       	call   801b5c <fsipc>
}
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c20:	b8 08 00 00 00       	mov    $0x8,%eax
  801c25:	e8 32 ff ff ff       	call   801b5c <fsipc>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	53                   	push   %ebx
  801c30:	83 ec 14             	sub    $0x14,%esp
  801c33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c36:	8b 45 08             	mov    0x8(%ebp),%eax
  801c39:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3c:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c41:	ba 00 00 00 00       	mov    $0x0,%edx
  801c46:	b8 05 00 00 00       	mov    $0x5,%eax
  801c4b:	e8 0c ff ff ff       	call   801b5c <fsipc>
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 2b                	js     801c7f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c54:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801c5b:	00 
  801c5c:	89 1c 24             	mov    %ebx,(%esp)
  801c5f:	e8 16 ef ff ff       	call   800b7a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c64:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801c69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c6f:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801c74:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c7f:	83 c4 14             	add    $0x14,%esp
  801c82:	5b                   	pop    %ebx
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 18             	sub    $0x18,%esp
  801c8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c93:	76 05                	jbe    801c9a <devfile_write+0x15>
  801c95:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  801c9d:	8b 52 0c             	mov    0xc(%edx),%edx
  801ca0:	89 15 00 50 c0 00    	mov    %edx,0xc05000
        fsipcbuf.write.req_n = n;
  801ca6:	a3 04 50 c0 00       	mov    %eax,0xc05004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801cab:	89 44 24 08          	mov    %eax,0x8(%esp)
  801caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb6:	c7 04 24 08 50 c0 00 	movl   $0xc05008,(%esp)
  801cbd:	e8 a3 f0 ff ff       	call   800d65 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc7:	b8 04 00 00 00       	mov    $0x4,%eax
  801ccc:	e8 8b fe ff ff       	call   801b5c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	53                   	push   %ebx
  801cd7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce0:	a3 00 50 c0 00       	mov    %eax,0xc05000
        fsipcbuf.read.req_n = n;
  801ce5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce8:	a3 04 50 c0 00       	mov    %eax,0xc05004
        r = fsipc(FSREQ_READ,NULL);
  801ced:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf2:	b8 03 00 00 00       	mov    $0x3,%eax
  801cf7:	e8 60 fe ff ff       	call   801b5c <fsipc>
  801cfc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 17                	js     801d19 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801d02:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d06:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801d0d:	00 
  801d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d11:	89 04 24             	mov    %eax,(%esp)
  801d14:	e8 4c f0 ff ff       	call   800d65 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	83 c4 14             	add    $0x14,%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	53                   	push   %ebx
  801d25:	83 ec 14             	sub    $0x14,%esp
  801d28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d2b:	89 1c 24             	mov    %ebx,(%esp)
  801d2e:	e8 fd ed ff ff       	call   800b30 <strlen>
  801d33:	89 c2                	mov    %eax,%edx
  801d35:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d3a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d40:	7f 1f                	jg     801d61 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d46:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  801d4d:	e8 28 ee ff ff       	call   800b7a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d52:	ba 00 00 00 00       	mov    $0x0,%edx
  801d57:	b8 07 00 00 00       	mov    $0x7,%eax
  801d5c:	e8 fb fd ff ff       	call   801b5c <fsipc>
}
  801d61:	83 c4 14             	add    $0x14,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 28             	sub    $0x28,%esp
  801d6d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d70:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d73:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801d76:	89 34 24             	mov    %esi,(%esp)
  801d79:	e8 b2 ed ff ff       	call   800b30 <strlen>
  801d7e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801d83:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d88:	7f 6d                	jg     801df7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801d8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8d:	89 04 24             	mov    %eax,(%esp)
  801d90:	e8 d6 f7 ff ff       	call   80156b <fd_alloc>
  801d95:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d97:	85 c0                	test   %eax,%eax
  801d99:	78 5c                	js     801df7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9e:	a3 00 54 c0 00       	mov    %eax,0xc05400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801da3:	89 34 24             	mov    %esi,(%esp)
  801da6:	e8 85 ed ff ff       	call   800b30 <strlen>
  801dab:	83 c0 01             	add    $0x1,%eax
  801dae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db6:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  801dbd:	e8 a3 ef ff ff       	call   800d65 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801dc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dc5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dca:	e8 8d fd ff ff       	call   801b5c <fsipc>
  801dcf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	79 15                	jns    801dea <open+0x83>
             fd_close(fd,0);
  801dd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ddc:	00 
  801ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de0:	89 04 24             	mov    %eax,(%esp)
  801de3:	e8 37 fb ff ff       	call   80191f <fd_close>
             return r;
  801de8:	eb 0d                	jmp    801df7 <open+0x90>
        }
        return fd2num(fd);
  801dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ded:	89 04 24             	mov    %eax,(%esp)
  801df0:	e8 4b f7 ff ff       	call   801540 <fd2num>
  801df5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801df7:	89 d8                	mov    %ebx,%eax
  801df9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801dfc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801dff:	89 ec                	mov    %ebp,%esp
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    
	...

00801e10 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e16:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801e1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e21:	39 ca                	cmp    %ecx,%edx
  801e23:	75 04                	jne    801e29 <ipc_find_env+0x19>
  801e25:	b0 00                	mov    $0x0,%al
  801e27:	eb 12                	jmp    801e3b <ipc_find_env+0x2b>
  801e29:	89 c2                	mov    %eax,%edx
  801e2b:	c1 e2 07             	shl    $0x7,%edx
  801e2e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801e35:	8b 12                	mov    (%edx),%edx
  801e37:	39 ca                	cmp    %ecx,%edx
  801e39:	75 10                	jne    801e4b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801e3b:	89 c2                	mov    %eax,%edx
  801e3d:	c1 e2 07             	shl    $0x7,%edx
  801e40:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801e47:	8b 00                	mov    (%eax),%eax
  801e49:	eb 0e                	jmp    801e59 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e4b:	83 c0 01             	add    $0x1,%eax
  801e4e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e53:	75 d4                	jne    801e29 <ipc_find_env+0x19>
  801e55:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    

00801e5b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	57                   	push   %edi
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	83 ec 1c             	sub    $0x1c,%esp
  801e64:	8b 75 08             	mov    0x8(%ebp),%esi
  801e67:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801e6d:	85 db                	test   %ebx,%ebx
  801e6f:	74 19                	je     801e8a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801e71:	8b 45 14             	mov    0x14(%ebp),%eax
  801e74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e78:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e7c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e80:	89 34 24             	mov    %esi,(%esp)
  801e83:	e8 bc f2 ff ff       	call   801144 <sys_ipc_try_send>
  801e88:	eb 1b                	jmp    801ea5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801e8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e91:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801e98:	ee 
  801e99:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e9d:	89 34 24             	mov    %esi,(%esp)
  801ea0:	e8 9f f2 ff ff       	call   801144 <sys_ipc_try_send>
           if(ret == 0)
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	74 28                	je     801ed1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801ea9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eac:	74 1c                	je     801eca <ipc_send+0x6f>
              panic("ipc send error");
  801eae:	c7 44 24 08 d4 26 80 	movl   $0x8026d4,0x8(%esp)
  801eb5:	00 
  801eb6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801ebd:	00 
  801ebe:	c7 04 24 e3 26 80 00 	movl   $0x8026e3,(%esp)
  801ec5:	e8 c2 e2 ff ff       	call   80018c <_panic>
           sys_yield();
  801eca:	e8 41 f5 ff ff       	call   801410 <sys_yield>
        }
  801ecf:	eb 9c                	jmp    801e6d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801ed1:	83 c4 1c             	add    $0x1c,%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	83 ec 10             	sub    $0x10,%esp
  801ee1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801eea:	85 c0                	test   %eax,%eax
  801eec:	75 0e                	jne    801efc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801eee:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801ef5:	e8 df f1 ff ff       	call   8010d9 <sys_ipc_recv>
  801efa:	eb 08                	jmp    801f04 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801efc:	89 04 24             	mov    %eax,(%esp)
  801eff:	e8 d5 f1 ff ff       	call   8010d9 <sys_ipc_recv>
        if(ret == 0){
  801f04:	85 c0                	test   %eax,%eax
  801f06:	75 26                	jne    801f2e <ipc_recv+0x55>
           if(from_env_store)
  801f08:	85 f6                	test   %esi,%esi
  801f0a:	74 0a                	je     801f16 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801f0c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f11:	8b 40 78             	mov    0x78(%eax),%eax
  801f14:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801f16:	85 db                	test   %ebx,%ebx
  801f18:	74 0a                	je     801f24 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801f1a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f1f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f22:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801f24:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f29:	8b 40 74             	mov    0x74(%eax),%eax
  801f2c:	eb 14                	jmp    801f42 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801f2e:	85 f6                	test   %esi,%esi
  801f30:	74 06                	je     801f38 <ipc_recv+0x5f>
              *from_env_store = 0;
  801f32:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801f38:	85 db                	test   %ebx,%ebx
  801f3a:	74 06                	je     801f42 <ipc_recv+0x69>
              *perm_store = 0;
  801f3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	5b                   	pop    %ebx
  801f46:	5e                   	pop    %esi
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    
  801f49:	00 00                	add    %al,(%eax)
  801f4b:	00 00                	add    %al,(%eax)
  801f4d:	00 00                	add    %al,(%eax)
	...

00801f50 <__udivdi3>:
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	57                   	push   %edi
  801f54:	56                   	push   %esi
  801f55:	83 ec 10             	sub    $0x10,%esp
  801f58:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  801f5e:	8b 75 10             	mov    0x10(%ebp),%esi
  801f61:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f64:	85 c0                	test   %eax,%eax
  801f66:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801f69:	75 35                	jne    801fa0 <__udivdi3+0x50>
  801f6b:	39 fe                	cmp    %edi,%esi
  801f6d:	77 61                	ja     801fd0 <__udivdi3+0x80>
  801f6f:	85 f6                	test   %esi,%esi
  801f71:	75 0b                	jne    801f7e <__udivdi3+0x2e>
  801f73:	b8 01 00 00 00       	mov    $0x1,%eax
  801f78:	31 d2                	xor    %edx,%edx
  801f7a:	f7 f6                	div    %esi
  801f7c:	89 c6                	mov    %eax,%esi
  801f7e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801f81:	31 d2                	xor    %edx,%edx
  801f83:	89 f8                	mov    %edi,%eax
  801f85:	f7 f6                	div    %esi
  801f87:	89 c7                	mov    %eax,%edi
  801f89:	89 c8                	mov    %ecx,%eax
  801f8b:	f7 f6                	div    %esi
  801f8d:	89 c1                	mov    %eax,%ecx
  801f8f:	89 fa                	mov    %edi,%edx
  801f91:	89 c8                	mov    %ecx,%eax
  801f93:	83 c4 10             	add    $0x10,%esp
  801f96:	5e                   	pop    %esi
  801f97:	5f                   	pop    %edi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    
  801f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fa0:	39 f8                	cmp    %edi,%eax
  801fa2:	77 1c                	ja     801fc0 <__udivdi3+0x70>
  801fa4:	0f bd d0             	bsr    %eax,%edx
  801fa7:	83 f2 1f             	xor    $0x1f,%edx
  801faa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801fad:	75 39                	jne    801fe8 <__udivdi3+0x98>
  801faf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801fb2:	0f 86 a0 00 00 00    	jbe    802058 <__udivdi3+0x108>
  801fb8:	39 f8                	cmp    %edi,%eax
  801fba:	0f 82 98 00 00 00    	jb     802058 <__udivdi3+0x108>
  801fc0:	31 ff                	xor    %edi,%edi
  801fc2:	31 c9                	xor    %ecx,%ecx
  801fc4:	89 c8                	mov    %ecx,%eax
  801fc6:	89 fa                	mov    %edi,%edx
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	5e                   	pop    %esi
  801fcc:	5f                   	pop    %edi
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    
  801fcf:	90                   	nop
  801fd0:	89 d1                	mov    %edx,%ecx
  801fd2:	89 fa                	mov    %edi,%edx
  801fd4:	89 c8                	mov    %ecx,%eax
  801fd6:	31 ff                	xor    %edi,%edi
  801fd8:	f7 f6                	div    %esi
  801fda:	89 c1                	mov    %eax,%ecx
  801fdc:	89 fa                	mov    %edi,%edx
  801fde:	89 c8                	mov    %ecx,%eax
  801fe0:	83 c4 10             	add    $0x10,%esp
  801fe3:	5e                   	pop    %esi
  801fe4:	5f                   	pop    %edi
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    
  801fe7:	90                   	nop
  801fe8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fec:	89 f2                	mov    %esi,%edx
  801fee:	d3 e0                	shl    %cl,%eax
  801ff0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ff3:	b8 20 00 00 00       	mov    $0x20,%eax
  801ff8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801ffb:	89 c1                	mov    %eax,%ecx
  801ffd:	d3 ea                	shr    %cl,%edx
  801fff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802003:	0b 55 ec             	or     -0x14(%ebp),%edx
  802006:	d3 e6                	shl    %cl,%esi
  802008:	89 c1                	mov    %eax,%ecx
  80200a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80200d:	89 fe                	mov    %edi,%esi
  80200f:	d3 ee                	shr    %cl,%esi
  802011:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802015:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802018:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80201b:	d3 e7                	shl    %cl,%edi
  80201d:	89 c1                	mov    %eax,%ecx
  80201f:	d3 ea                	shr    %cl,%edx
  802021:	09 d7                	or     %edx,%edi
  802023:	89 f2                	mov    %esi,%edx
  802025:	89 f8                	mov    %edi,%eax
  802027:	f7 75 ec             	divl   -0x14(%ebp)
  80202a:	89 d6                	mov    %edx,%esi
  80202c:	89 c7                	mov    %eax,%edi
  80202e:	f7 65 e8             	mull   -0x18(%ebp)
  802031:	39 d6                	cmp    %edx,%esi
  802033:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802036:	72 30                	jb     802068 <__udivdi3+0x118>
  802038:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80203b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80203f:	d3 e2                	shl    %cl,%edx
  802041:	39 c2                	cmp    %eax,%edx
  802043:	73 05                	jae    80204a <__udivdi3+0xfa>
  802045:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802048:	74 1e                	je     802068 <__udivdi3+0x118>
  80204a:	89 f9                	mov    %edi,%ecx
  80204c:	31 ff                	xor    %edi,%edi
  80204e:	e9 71 ff ff ff       	jmp    801fc4 <__udivdi3+0x74>
  802053:	90                   	nop
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80205f:	e9 60 ff ff ff       	jmp    801fc4 <__udivdi3+0x74>
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80206b:	31 ff                	xor    %edi,%edi
  80206d:	89 c8                	mov    %ecx,%eax
  80206f:	89 fa                	mov    %edi,%edx
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
	...

00802080 <__umoddi3>:
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	57                   	push   %edi
  802084:	56                   	push   %esi
  802085:	83 ec 20             	sub    $0x20,%esp
  802088:	8b 55 14             	mov    0x14(%ebp),%edx
  80208b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80208e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802091:	8b 75 0c             	mov    0xc(%ebp),%esi
  802094:	85 d2                	test   %edx,%edx
  802096:	89 c8                	mov    %ecx,%eax
  802098:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80209b:	75 13                	jne    8020b0 <__umoddi3+0x30>
  80209d:	39 f7                	cmp    %esi,%edi
  80209f:	76 3f                	jbe    8020e0 <__umoddi3+0x60>
  8020a1:	89 f2                	mov    %esi,%edx
  8020a3:	f7 f7                	div    %edi
  8020a5:	89 d0                	mov    %edx,%eax
  8020a7:	31 d2                	xor    %edx,%edx
  8020a9:	83 c4 20             	add    $0x20,%esp
  8020ac:	5e                   	pop    %esi
  8020ad:	5f                   	pop    %edi
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    
  8020b0:	39 f2                	cmp    %esi,%edx
  8020b2:	77 4c                	ja     802100 <__umoddi3+0x80>
  8020b4:	0f bd ca             	bsr    %edx,%ecx
  8020b7:	83 f1 1f             	xor    $0x1f,%ecx
  8020ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020bd:	75 51                	jne    802110 <__umoddi3+0x90>
  8020bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8020c2:	0f 87 e0 00 00 00    	ja     8021a8 <__umoddi3+0x128>
  8020c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cb:	29 f8                	sub    %edi,%eax
  8020cd:	19 d6                	sbb    %edx,%esi
  8020cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8020d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d5:	89 f2                	mov    %esi,%edx
  8020d7:	83 c4 20             	add    $0x20,%esp
  8020da:	5e                   	pop    %esi
  8020db:	5f                   	pop    %edi
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    
  8020de:	66 90                	xchg   %ax,%ax
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	75 0b                	jne    8020ef <__umoddi3+0x6f>
  8020e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e9:	31 d2                	xor    %edx,%edx
  8020eb:	f7 f7                	div    %edi
  8020ed:	89 c7                	mov    %eax,%edi
  8020ef:	89 f0                	mov    %esi,%eax
  8020f1:	31 d2                	xor    %edx,%edx
  8020f3:	f7 f7                	div    %edi
  8020f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f8:	f7 f7                	div    %edi
  8020fa:	eb a9                	jmp    8020a5 <__umoddi3+0x25>
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 20             	add    $0x20,%esp
  802107:	5e                   	pop    %esi
  802108:	5f                   	pop    %edi
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    
  80210b:	90                   	nop
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802114:	d3 e2                	shl    %cl,%edx
  802116:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802119:	ba 20 00 00 00       	mov    $0x20,%edx
  80211e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802121:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802124:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802128:	89 fa                	mov    %edi,%edx
  80212a:	d3 ea                	shr    %cl,%edx
  80212c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802130:	0b 55 f4             	or     -0xc(%ebp),%edx
  802133:	d3 e7                	shl    %cl,%edi
  802135:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802139:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80213c:	89 f2                	mov    %esi,%edx
  80213e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802141:	89 c7                	mov    %eax,%edi
  802143:	d3 ea                	shr    %cl,%edx
  802145:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802149:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80214c:	89 c2                	mov    %eax,%edx
  80214e:	d3 e6                	shl    %cl,%esi
  802150:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802154:	d3 ea                	shr    %cl,%edx
  802156:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80215a:	09 d6                	or     %edx,%esi
  80215c:	89 f0                	mov    %esi,%eax
  80215e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802161:	d3 e7                	shl    %cl,%edi
  802163:	89 f2                	mov    %esi,%edx
  802165:	f7 75 f4             	divl   -0xc(%ebp)
  802168:	89 d6                	mov    %edx,%esi
  80216a:	f7 65 e8             	mull   -0x18(%ebp)
  80216d:	39 d6                	cmp    %edx,%esi
  80216f:	72 2b                	jb     80219c <__umoddi3+0x11c>
  802171:	39 c7                	cmp    %eax,%edi
  802173:	72 23                	jb     802198 <__umoddi3+0x118>
  802175:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802179:	29 c7                	sub    %eax,%edi
  80217b:	19 d6                	sbb    %edx,%esi
  80217d:	89 f0                	mov    %esi,%eax
  80217f:	89 f2                	mov    %esi,%edx
  802181:	d3 ef                	shr    %cl,%edi
  802183:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802187:	d3 e0                	shl    %cl,%eax
  802189:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80218d:	09 f8                	or     %edi,%eax
  80218f:	d3 ea                	shr    %cl,%edx
  802191:	83 c4 20             	add    $0x20,%esp
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	39 d6                	cmp    %edx,%esi
  80219a:	75 d9                	jne    802175 <__umoddi3+0xf5>
  80219c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80219f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8021a2:	eb d1                	jmp    802175 <__umoddi3+0xf5>
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	0f 82 18 ff ff ff    	jb     8020c8 <__umoddi3+0x48>
  8021b0:	e9 1d ff ff ff       	jmp    8020d2 <__umoddi3+0x52>
