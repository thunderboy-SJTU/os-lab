
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 40 21 80 00 	movl   $0x802140,(%esp)
  80004e:	e8 1e 01 00 00       	call   800171 <cprintf>
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 5; i++) {
		sys_yield();
  800058:	e8 d3 12 00 00       	call   801330 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 60 21 80 00 	movl   $0x802160,(%esp)
  800074:	e8 f8 00 00 00       	call   800171 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 40 80 00       	mov    0x804004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 8c 21 80 00 	movl   $0x80218c,(%esp)
  800094:	e8 d8 00 00 00       	call   800171 <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000b2:	e8 fb 12 00 00       	call   8013b2 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	89 c2                	mov    %eax,%edx
  8000be:	c1 e2 07             	shl    $0x7,%edx
  8000c1:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000c8:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cd:	85 f6                	test   %esi,%esi
  8000cf:	7e 07                	jle    8000d8 <libmain+0x38>
		binaryname = argv[0];
  8000d1:	8b 03                	mov    (%ebx),%eax
  8000d3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000dc:	89 34 24             	mov    %esi,(%esp)
  8000df:	e8 50 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e4:	e8 0b 00 00 00       	call   8000f4 <exit>
}
  8000e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ec:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ef:	89 ec                	mov    %ebp,%esp
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    
	...

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000fa:	e8 3c 18 00 00       	call   80193b <close_all>
	sys_env_destroy(0);
  8000ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800106:	e8 e7 12 00 00       	call   8013f2 <sys_env_destroy>
}
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    
  80010d:	00 00                	add    %al,(%eax)
	...

00800110 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800119:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800120:	00 00 00 
	b.cnt = 0;
  800123:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800130:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800134:	8b 45 08             	mov    0x8(%ebp),%eax
  800137:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	c7 04 24 8b 01 80 00 	movl   $0x80018b,(%esp)
  80014c:	e8 cb 01 00 00       	call   80031c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800151:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800161:	89 04 24             	mov    %eax,(%esp)
  800164:	e8 63 0d 00 00       	call   800ecc <sys_cputs>

	return b.cnt;
}
  800169:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800177:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 04 24             	mov    %eax,(%esp)
  800184:	e8 87 ff ff ff       	call   800110 <vcprintf>
	va_end(ap);

	return cnt;
}
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	83 ec 14             	sub    $0x14,%esp
  800192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800195:	8b 03                	mov    (%ebx),%eax
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80019e:	83 c0 01             	add    $0x1,%eax
  8001a1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a8:	75 19                	jne    8001c3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001aa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b1:	00 
  8001b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 0f 0d 00 00       	call   800ecc <sys_cputs>
		b->idx = 0;
  8001bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c7:	83 c4 14             	add    $0x14,%esp
  8001ca:	5b                   	pop    %ebx
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    
  8001cd:	00 00                	add    %al,(%eax)
	...

008001d0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8001f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001fb:	39 d1                	cmp    %edx,%ecx
  8001fd:	72 07                	jb     800206 <printnum_v2+0x36>
  8001ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800202:	39 d0                	cmp    %edx,%eax
  800204:	77 5f                	ja     800265 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800206:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80020a:	83 eb 01             	sub    $0x1,%ebx
  80020d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800219:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80021d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800220:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800223:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800226:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80022a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800231:	00 
  800232:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80023b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023f:	e8 7c 1c 00 00       	call   801ec0 <__udivdi3>
  800244:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800247:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80024a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800252:	89 04 24             	mov    %eax,(%esp)
  800255:	89 54 24 04          	mov    %edx,0x4(%esp)
  800259:	89 f2                	mov    %esi,%edx
  80025b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025e:	e8 6d ff ff ff       	call   8001d0 <printnum_v2>
  800263:	eb 1e                	jmp    800283 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800265:	83 ff 2d             	cmp    $0x2d,%edi
  800268:	74 19                	je     800283 <printnum_v2+0xb3>
		while (--width > 0)
  80026a:	83 eb 01             	sub    $0x1,%ebx
  80026d:	85 db                	test   %ebx,%ebx
  80026f:	90                   	nop
  800270:	7e 11                	jle    800283 <printnum_v2+0xb3>
			putch(padc, putdat);
  800272:	89 74 24 04          	mov    %esi,0x4(%esp)
  800276:	89 3c 24             	mov    %edi,(%esp)
  800279:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80027c:	83 eb 01             	sub    $0x1,%ebx
  80027f:	85 db                	test   %ebx,%ebx
  800281:	7f ef                	jg     800272 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800283:	89 74 24 04          	mov    %esi,0x4(%esp)
  800287:	8b 74 24 04          	mov    0x4(%esp),%esi
  80028b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800292:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800299:	00 
  80029a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80029d:	89 14 24             	mov    %edx,(%esp)
  8002a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002a7:	e8 44 1d 00 00       	call   801ff0 <__umoddi3>
  8002ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b0:	0f be 80 b5 21 80 00 	movsbl 0x8021b5(%eax),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002bd:	83 c4 4c             	add    $0x4c,%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c8:	83 fa 01             	cmp    $0x1,%edx
  8002cb:	7e 0e                	jle    8002db <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d2:	89 08                	mov    %ecx,(%eax)
  8002d4:	8b 02                	mov    (%edx),%eax
  8002d6:	8b 52 04             	mov    0x4(%edx),%edx
  8002d9:	eb 22                	jmp    8002fd <getuint+0x38>
	else if (lflag)
  8002db:	85 d2                	test   %edx,%edx
  8002dd:	74 10                	je     8002ef <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 02                	mov    (%edx),%eax
  8002e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ed:	eb 0e                	jmp    8002fd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800305:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	3b 50 04             	cmp    0x4(%eax),%edx
  80030e:	73 0a                	jae    80031a <sprintputch+0x1b>
		*b->buf++ = ch;
  800310:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800313:	88 0a                	mov    %cl,(%edx)
  800315:	83 c2 01             	add    $0x1,%edx
  800318:	89 10                	mov    %edx,(%eax)
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
  800322:	83 ec 6c             	sub    $0x6c,%esp
  800325:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800328:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80032f:	eb 1a                	jmp    80034b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800331:	85 c0                	test   %eax,%eax
  800333:	0f 84 66 06 00 00    	je     80099f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800339:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	ff 55 08             	call   *0x8(%ebp)
  800346:	eb 03                	jmp    80034b <vprintfmt+0x2f>
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	0f b6 07             	movzbl (%edi),%eax
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	83 f8 25             	cmp    $0x25,%eax
  800354:	75 db                	jne    800331 <vprintfmt+0x15>
  800356:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80035a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800366:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80036b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800372:	be 00 00 00 00       	mov    $0x0,%esi
  800377:	eb 06                	jmp    80037f <vprintfmt+0x63>
  800379:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80037d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	0f b6 17             	movzbl (%edi),%edx
  800382:	0f b6 c2             	movzbl %dl,%eax
  800385:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800388:	8d 47 01             	lea    0x1(%edi),%eax
  80038b:	83 ea 23             	sub    $0x23,%edx
  80038e:	80 fa 55             	cmp    $0x55,%dl
  800391:	0f 87 60 05 00 00    	ja     8008f7 <vprintfmt+0x5db>
  800397:	0f b6 d2             	movzbl %dl,%edx
  80039a:	ff 24 95 a0 23 80 00 	jmp    *0x8023a0(,%edx,4)
  8003a1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8003a6:	eb d5                	jmp    80037d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003ab:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8003ae:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003b1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003b4:	83 ff 09             	cmp    $0x9,%edi
  8003b7:	76 08                	jbe    8003c1 <vprintfmt+0xa5>
  8003b9:	eb 40                	jmp    8003fb <vprintfmt+0xdf>
  8003bb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8003bf:	eb bc                	jmp    80037d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003c4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8003c7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8003cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ce:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003d1:	83 ff 09             	cmp    $0x9,%edi
  8003d4:	76 eb                	jbe    8003c1 <vprintfmt+0xa5>
  8003d6:	eb 23                	jmp    8003fb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003db:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003de:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003e1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8003e3:	eb 16                	jmp    8003fb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8003e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003e8:	c1 fa 1f             	sar    $0x1f,%edx
  8003eb:	f7 d2                	not    %edx
  8003ed:	21 55 d8             	and    %edx,-0x28(%ebp)
  8003f0:	eb 8b                	jmp    80037d <vprintfmt+0x61>
  8003f2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003f9:	eb 82                	jmp    80037d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8003fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ff:	0f 89 78 ff ff ff    	jns    80037d <vprintfmt+0x61>
  800405:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800408:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80040b:	e9 6d ff ff ff       	jmp    80037d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800410:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800413:	e9 65 ff ff ff       	jmp    80037d <vprintfmt+0x61>
  800418:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 50 04             	lea    0x4(%eax),%edx
  800421:	89 55 14             	mov    %edx,0x14(%ebp)
  800424:	8b 55 0c             	mov    0xc(%ebp),%edx
  800427:	89 54 24 04          	mov    %edx,0x4(%esp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	89 04 24             	mov    %eax,(%esp)
  800430:	ff 55 08             	call   *0x8(%ebp)
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800436:	e9 10 ff ff ff       	jmp    80034b <vprintfmt+0x2f>
  80043b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8d 50 04             	lea    0x4(%eax),%edx
  800444:	89 55 14             	mov    %edx,0x14(%ebp)
  800447:	8b 00                	mov    (%eax),%eax
  800449:	89 c2                	mov    %eax,%edx
  80044b:	c1 fa 1f             	sar    $0x1f,%edx
  80044e:	31 d0                	xor    %edx,%eax
  800450:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800452:	83 f8 0f             	cmp    $0xf,%eax
  800455:	7f 0b                	jg     800462 <vprintfmt+0x146>
  800457:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	75 26                	jne    800488 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 c6 21 80 	movl   $0x8021c6,0x8(%esp)
  80046d:	00 
  80046e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800471:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800475:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800478:	89 1c 24             	mov    %ebx,(%esp)
  80047b:	e8 a7 05 00 00       	call   800a27 <printfmt>
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800483:	e9 c3 fe ff ff       	jmp    80034b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800488:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048c:	c7 44 24 08 cf 21 80 	movl   $0x8021cf,0x8(%esp)
  800493:	00 
  800494:	8b 45 0c             	mov    0xc(%ebp),%eax
  800497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049b:	8b 55 08             	mov    0x8(%ebp),%edx
  80049e:	89 14 24             	mov    %edx,(%esp)
  8004a1:	e8 81 05 00 00       	call   800a27 <printfmt>
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a9:	e9 9d fe ff ff       	jmp    80034b <vprintfmt+0x2f>
  8004ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b1:	89 c7                	mov    %eax,%edi
  8004b3:	89 d9                	mov    %ebx,%ecx
  8004b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 50 04             	lea    0x4(%eax),%edx
  8004c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c4:	8b 30                	mov    (%eax),%esi
  8004c6:	85 f6                	test   %esi,%esi
  8004c8:	75 05                	jne    8004cf <vprintfmt+0x1b3>
  8004ca:	be d2 21 80 00       	mov    $0x8021d2,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8004cf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004d3:	7e 06                	jle    8004db <vprintfmt+0x1bf>
  8004d5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8004d9:	75 10                	jne    8004eb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004db:	0f be 06             	movsbl (%esi),%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	0f 85 a2 00 00 00    	jne    800588 <vprintfmt+0x26c>
  8004e6:	e9 92 00 00 00       	jmp    80057d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ef:	89 34 24             	mov    %esi,(%esp)
  8004f2:	e8 74 05 00 00       	call   800a6b <strnlen>
  8004f7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004fa:	29 c2                	sub    %eax,%edx
  8004fc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004ff:	85 d2                	test   %edx,%edx
  800501:	7e d8                	jle    8004db <vprintfmt+0x1bf>
					putch(padc, putdat);
  800503:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800507:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80050a:	89 d3                	mov    %edx,%ebx
  80050c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80050f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800512:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800515:	89 ce                	mov    %ecx,%esi
  800517:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051b:	89 34 24             	mov    %esi,(%esp)
  80051e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	83 eb 01             	sub    $0x1,%ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ef                	jg     800517 <vprintfmt+0x1fb>
  800528:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80052b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80052e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800531:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800538:	eb a1                	jmp    8004db <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80053e:	74 1b                	je     80055b <vprintfmt+0x23f>
  800540:	8d 50 e0             	lea    -0x20(%eax),%edx
  800543:	83 fa 5e             	cmp    $0x5e,%edx
  800546:	76 13                	jbe    80055b <vprintfmt+0x23f>
					putch('?', putdat);
  800548:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800556:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800559:	eb 0d                	jmp    800568 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80055b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800562:	89 04 24             	mov    %eax,(%esp)
  800565:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800568:	83 ef 01             	sub    $0x1,%edi
  80056b:	0f be 06             	movsbl (%esi),%eax
  80056e:	85 c0                	test   %eax,%eax
  800570:	74 05                	je     800577 <vprintfmt+0x25b>
  800572:	83 c6 01             	add    $0x1,%esi
  800575:	eb 1a                	jmp    800591 <vprintfmt+0x275>
  800577:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80057a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800581:	7f 1f                	jg     8005a2 <vprintfmt+0x286>
  800583:	e9 c0 fd ff ff       	jmp    800348 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 c6 01             	add    $0x1,%esi
  80058b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80058e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800591:	85 db                	test   %ebx,%ebx
  800593:	78 a5                	js     80053a <vprintfmt+0x21e>
  800595:	83 eb 01             	sub    $0x1,%ebx
  800598:	79 a0                	jns    80053a <vprintfmt+0x21e>
  80059a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80059d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005a0:	eb db                	jmp    80057d <vprintfmt+0x261>
  8005a2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005a8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005ab:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bb:	83 eb 01             	sub    $0x1,%ebx
  8005be:	85 db                	test   %ebx,%ebx
  8005c0:	7f ec                	jg     8005ae <vprintfmt+0x292>
  8005c2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005c5:	e9 81 fd ff ff       	jmp    80034b <vprintfmt+0x2f>
  8005ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cd:	83 fe 01             	cmp    $0x1,%esi
  8005d0:	7e 10                	jle    8005e2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 08             	lea    0x8(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 18                	mov    (%eax),%ebx
  8005dd:	8b 70 04             	mov    0x4(%eax),%esi
  8005e0:	eb 26                	jmp    800608 <vprintfmt+0x2ec>
	else if (lflag)
  8005e2:	85 f6                	test   %esi,%esi
  8005e4:	74 12                	je     8005f8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 18                	mov    (%eax),%ebx
  8005f1:	89 de                	mov    %ebx,%esi
  8005f3:	c1 fe 1f             	sar    $0x1f,%esi
  8005f6:	eb 10                	jmp    800608 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 18                	mov    (%eax),%ebx
  800603:	89 de                	mov    %ebx,%esi
  800605:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800608:	83 f9 01             	cmp    $0x1,%ecx
  80060b:	75 1e                	jne    80062b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80060d:	85 f6                	test   %esi,%esi
  80060f:	78 1a                	js     80062b <vprintfmt+0x30f>
  800611:	85 f6                	test   %esi,%esi
  800613:	7f 05                	jg     80061a <vprintfmt+0x2fe>
  800615:	83 fb 00             	cmp    $0x0,%ebx
  800618:	76 11                	jbe    80062b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80061a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80061d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800621:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800628:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80062b:	85 f6                	test   %esi,%esi
  80062d:	78 13                	js     800642 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800632:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800638:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063d:	e9 da 00 00 00       	jmp    80071c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800642:	8b 45 0c             	mov    0xc(%ebp),%eax
  800645:	89 44 24 04          	mov    %eax,0x4(%esp)
  800649:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800650:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800653:	89 da                	mov    %ebx,%edx
  800655:	89 f1                	mov    %esi,%ecx
  800657:	f7 da                	neg    %edx
  800659:	83 d1 00             	adc    $0x0,%ecx
  80065c:	f7 d9                	neg    %ecx
  80065e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800661:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066c:	e9 ab 00 00 00       	jmp    80071c <vprintfmt+0x400>
  800671:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	89 f2                	mov    %esi,%edx
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 47 fc ff ff       	call   8002c5 <getuint>
  80067e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800681:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800687:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80068c:	e9 8b 00 00 00       	jmp    80071c <vprintfmt+0x400>
  800691:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800694:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800697:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80069b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8006a5:	89 f2                	mov    %esi,%edx
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 16 fc ff ff       	call   8002c5 <getuint>
  8006af:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006b2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8006bd:	eb 5d                	jmp    80071c <vprintfmt+0x400>
  8006bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006de:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 50 04             	lea    0x4(%eax),%edx
  8006e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006f4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ff:	eb 1b                	jmp    80071c <vprintfmt+0x400>
  800701:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800704:	89 f2                	mov    %esi,%edx
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
  800709:	e8 b7 fb ff ff       	call   8002c5 <getuint>
  80070e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800711:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800717:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800720:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800723:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800726:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80072a:	77 09                	ja     800735 <vprintfmt+0x419>
  80072c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80072f:	0f 82 ac 00 00 00    	jb     8007e1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800735:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800738:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80073c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80073f:	83 ea 01             	sub    $0x1,%edx
  800742:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800746:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80074e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800752:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800755:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800758:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80075b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80075f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800766:	00 
  800767:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80076a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80076d:	89 0c 24             	mov    %ecx,(%esp)
  800770:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800774:	e8 47 17 00 00       	call   801ec0 <__udivdi3>
  800779:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80077c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80077f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800783:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	e8 37 fa ff ff       	call   8001d0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007b2:	00 
  8007b3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8007b6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8007b9:	89 14 24             	mov    %edx,(%esp)
  8007bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007c0:	e8 2b 18 00 00       	call   801ff0 <__umoddi3>
  8007c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c9:	0f be 80 b5 21 80 00 	movsbl 0x8021b5(%eax),%eax
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8007d6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007da:	74 54                	je     800830 <vprintfmt+0x514>
  8007dc:	e9 67 fb ff ff       	jmp    800348 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007e1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007e5:	8d 76 00             	lea    0x0(%esi),%esi
  8007e8:	0f 84 2a 01 00 00    	je     800918 <vprintfmt+0x5fc>
		while (--width > 0)
  8007ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007f1:	83 ef 01             	sub    $0x1,%edi
  8007f4:	85 ff                	test   %edi,%edi
  8007f6:	0f 8e 5e 01 00 00    	jle    80095a <vprintfmt+0x63e>
  8007fc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007ff:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800802:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800805:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800808:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80080b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80080e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800812:	89 1c 24             	mov    %ebx,(%esp)
  800815:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800818:	83 ef 01             	sub    $0x1,%edi
  80081b:	85 ff                	test   %edi,%edi
  80081d:	7f ef                	jg     80080e <vprintfmt+0x4f2>
  80081f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800822:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800825:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800828:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80082b:	e9 2a 01 00 00       	jmp    80095a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800830:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800833:	83 eb 01             	sub    $0x1,%ebx
  800836:	85 db                	test   %ebx,%ebx
  800838:	0f 8e 0a fb ff ff    	jle    800348 <vprintfmt+0x2c>
  80083e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800841:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800844:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800847:	89 74 24 04          	mov    %esi,0x4(%esp)
  80084b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800852:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800854:	83 eb 01             	sub    $0x1,%ebx
  800857:	85 db                	test   %ebx,%ebx
  800859:	7f ec                	jg     800847 <vprintfmt+0x52b>
  80085b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80085e:	e9 e8 fa ff ff       	jmp    80034b <vprintfmt+0x2f>
  800863:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 00                	mov    (%eax),%eax
  800871:	85 c0                	test   %eax,%eax
  800873:	75 2a                	jne    80089f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800875:	c7 44 24 0c ec 22 80 	movl   $0x8022ec,0xc(%esp)
  80087c:	00 
  80087d:	c7 44 24 08 cf 21 80 	movl   $0x8021cf,0x8(%esp)
  800884:	00 
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
  800888:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088f:	89 0c 24             	mov    %ecx,(%esp)
  800892:	e8 90 01 00 00       	call   800a27 <printfmt>
  800897:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089a:	e9 ac fa ff ff       	jmp    80034b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80089f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a2:	8b 13                	mov    (%ebx),%edx
  8008a4:	83 fa 7f             	cmp    $0x7f,%edx
  8008a7:	7e 29                	jle    8008d2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8008a9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8008ab:	c7 44 24 0c 24 23 80 	movl   $0x802324,0xc(%esp)
  8008b2:	00 
  8008b3:	c7 44 24 08 cf 21 80 	movl   $0x8021cf,0x8(%esp)
  8008ba:	00 
  8008bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	e8 5d 01 00 00       	call   800a27 <printfmt>
  8008ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cd:	e9 79 fa ff ff       	jmp    80034b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8008d2:	88 10                	mov    %dl,(%eax)
  8008d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d7:	e9 6f fa ff ff       	jmp    80034b <vprintfmt+0x2f>
  8008dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008e9:	89 14 24             	mov    %edx,(%esp)
  8008ec:	ff 55 08             	call   *0x8(%ebp)
  8008ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8008f2:	e9 54 fa ff ff       	jmp    80034b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800905:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800908:	8d 47 ff             	lea    -0x1(%edi),%eax
  80090b:	80 38 25             	cmpb   $0x25,(%eax)
  80090e:	0f 84 37 fa ff ff    	je     80034b <vprintfmt+0x2f>
  800914:	89 c7                	mov    %eax,%edi
  800916:	eb f0                	jmp    800908 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800918:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800923:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800926:	89 54 24 08          	mov    %edx,0x8(%esp)
  80092a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800931:	00 
  800932:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800935:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800938:	89 04 24             	mov    %eax,(%esp)
  80093b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80093f:	e8 ac 16 00 00       	call   801ff0 <__umoddi3>
  800944:	89 74 24 04          	mov    %esi,0x4(%esp)
  800948:	0f be 80 b5 21 80 00 	movsbl 0x8021b5(%eax),%eax
  80094f:	89 04 24             	mov    %eax,(%esp)
  800952:	ff 55 08             	call   *0x8(%ebp)
  800955:	e9 d6 fe ff ff       	jmp    800830 <vprintfmt+0x514>
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800961:	8b 74 24 04          	mov    0x4(%esp),%esi
  800965:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800968:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80096c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800973:	00 
  800974:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800977:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80097a:	89 04 24             	mov    %eax,(%esp)
  80097d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800981:	e8 6a 16 00 00       	call   801ff0 <__umoddi3>
  800986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098a:	0f be 80 b5 21 80 00 	movsbl 0x8021b5(%eax),%eax
  800991:	89 04 24             	mov    %eax,(%esp)
  800994:	ff 55 08             	call   *0x8(%ebp)
  800997:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80099a:	e9 ac f9 ff ff       	jmp    80034b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80099f:	83 c4 6c             	add    $0x6c,%esp
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	83 ec 28             	sub    $0x28,%esp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8009b3:	85 c0                	test   %eax,%eax
  8009b5:	74 04                	je     8009bb <vsnprintf+0x14>
  8009b7:	85 d2                	test   %edx,%edx
  8009b9:	7f 07                	jg     8009c2 <vsnprintf+0x1b>
  8009bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c0:	eb 3b                	jmp    8009fd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8009c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009da:	8b 45 10             	mov    0x10(%ebp),%eax
  8009dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e8:	c7 04 24 ff 02 80 00 	movl   $0x8002ff,(%esp)
  8009ef:	e8 28 f9 ff ff       	call   80031c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a05:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	89 04 24             	mov    %eax,(%esp)
  800a20:	e8 82 ff ff ff       	call   8009a7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a2d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a34:	8b 45 10             	mov    0x10(%ebp),%eax
  800a37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	89 04 24             	mov    %eax,(%esp)
  800a48:	e8 cf f8 ff ff       	call   80031c <vprintfmt>
	va_end(ap);
}
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    
	...

00800a50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a5e:	74 09                	je     800a69 <strlen+0x19>
		n++;
  800a60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a67:	75 f7                	jne    800a60 <strlen+0x10>
		n++;
	return n;
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a75:	85 c9                	test   %ecx,%ecx
  800a77:	74 19                	je     800a92 <strnlen+0x27>
  800a79:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a7c:	74 14                	je     800a92 <strnlen+0x27>
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a83:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a86:	39 c8                	cmp    %ecx,%eax
  800a88:	74 0d                	je     800a97 <strnlen+0x2c>
  800a8a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a8e:	75 f3                	jne    800a83 <strnlen+0x18>
  800a90:	eb 05                	jmp    800a97 <strnlen+0x2c>
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a97:	5b                   	pop    %ebx
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800aad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ab0:	83 c2 01             	add    $0x1,%edx
  800ab3:	84 c9                	test   %cl,%cl
  800ab5:	75 f2                	jne    800aa9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	53                   	push   %ebx
  800abe:	83 ec 08             	sub    $0x8,%esp
  800ac1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac4:	89 1c 24             	mov    %ebx,(%esp)
  800ac7:	e8 84 ff ff ff       	call   800a50 <strlen>
	strcpy(dst + len, src);
  800acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800ad6:	89 04 24             	mov    %eax,(%esp)
  800ad9:	e8 bc ff ff ff       	call   800a9a <strcpy>
	return dst;
}
  800ade:	89 d8                	mov    %ebx,%eax
  800ae0:	83 c4 08             	add    $0x8,%esp
  800ae3:	5b                   	pop    %ebx
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af4:	85 f6                	test   %esi,%esi
  800af6:	74 18                	je     800b10 <strncpy+0x2a>
  800af8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800afd:	0f b6 1a             	movzbl (%edx),%ebx
  800b00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b03:	80 3a 01             	cmpb   $0x1,(%edx)
  800b06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	39 ce                	cmp    %ecx,%esi
  800b0e:	77 ed                	ja     800afd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b22:	89 f0                	mov    %esi,%eax
  800b24:	85 c9                	test   %ecx,%ecx
  800b26:	74 27                	je     800b4f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b28:	83 e9 01             	sub    $0x1,%ecx
  800b2b:	74 1d                	je     800b4a <strlcpy+0x36>
  800b2d:	0f b6 1a             	movzbl (%edx),%ebx
  800b30:	84 db                	test   %bl,%bl
  800b32:	74 16                	je     800b4a <strlcpy+0x36>
			*dst++ = *src++;
  800b34:	88 18                	mov    %bl,(%eax)
  800b36:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b39:	83 e9 01             	sub    $0x1,%ecx
  800b3c:	74 0e                	je     800b4c <strlcpy+0x38>
			*dst++ = *src++;
  800b3e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b41:	0f b6 1a             	movzbl (%edx),%ebx
  800b44:	84 db                	test   %bl,%bl
  800b46:	75 ec                	jne    800b34 <strlcpy+0x20>
  800b48:	eb 02                	jmp    800b4c <strlcpy+0x38>
  800b4a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b4c:	c6 00 00             	movb   $0x0,(%eax)
  800b4f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b5e:	0f b6 01             	movzbl (%ecx),%eax
  800b61:	84 c0                	test   %al,%al
  800b63:	74 15                	je     800b7a <strcmp+0x25>
  800b65:	3a 02                	cmp    (%edx),%al
  800b67:	75 11                	jne    800b7a <strcmp+0x25>
		p++, q++;
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b6f:	0f b6 01             	movzbl (%ecx),%eax
  800b72:	84 c0                	test   %al,%al
  800b74:	74 04                	je     800b7a <strcmp+0x25>
  800b76:	3a 02                	cmp    (%edx),%al
  800b78:	74 ef                	je     800b69 <strcmp+0x14>
  800b7a:	0f b6 c0             	movzbl %al,%eax
  800b7d:	0f b6 12             	movzbl (%edx),%edx
  800b80:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	53                   	push   %ebx
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	74 23                	je     800bb8 <strncmp+0x34>
  800b95:	0f b6 1a             	movzbl (%edx),%ebx
  800b98:	84 db                	test   %bl,%bl
  800b9a:	74 25                	je     800bc1 <strncmp+0x3d>
  800b9c:	3a 19                	cmp    (%ecx),%bl
  800b9e:	75 21                	jne    800bc1 <strncmp+0x3d>
  800ba0:	83 e8 01             	sub    $0x1,%eax
  800ba3:	74 13                	je     800bb8 <strncmp+0x34>
		n--, p++, q++;
  800ba5:	83 c2 01             	add    $0x1,%edx
  800ba8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bab:	0f b6 1a             	movzbl (%edx),%ebx
  800bae:	84 db                	test   %bl,%bl
  800bb0:	74 0f                	je     800bc1 <strncmp+0x3d>
  800bb2:	3a 19                	cmp    (%ecx),%bl
  800bb4:	74 ea                	je     800ba0 <strncmp+0x1c>
  800bb6:	eb 09                	jmp    800bc1 <strncmp+0x3d>
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5d                   	pop    %ebp
  800bbf:	90                   	nop
  800bc0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc1:	0f b6 02             	movzbl (%edx),%eax
  800bc4:	0f b6 11             	movzbl (%ecx),%edx
  800bc7:	29 d0                	sub    %edx,%eax
  800bc9:	eb f2                	jmp    800bbd <strncmp+0x39>

00800bcb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd5:	0f b6 10             	movzbl (%eax),%edx
  800bd8:	84 d2                	test   %dl,%dl
  800bda:	74 18                	je     800bf4 <strchr+0x29>
		if (*s == c)
  800bdc:	38 ca                	cmp    %cl,%dl
  800bde:	75 0a                	jne    800bea <strchr+0x1f>
  800be0:	eb 17                	jmp    800bf9 <strchr+0x2e>
  800be2:	38 ca                	cmp    %cl,%dl
  800be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800be8:	74 0f                	je     800bf9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bea:	83 c0 01             	add    $0x1,%eax
  800bed:	0f b6 10             	movzbl (%eax),%edx
  800bf0:	84 d2                	test   %dl,%dl
  800bf2:	75 ee                	jne    800be2 <strchr+0x17>
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c05:	0f b6 10             	movzbl (%eax),%edx
  800c08:	84 d2                	test   %dl,%dl
  800c0a:	74 18                	je     800c24 <strfind+0x29>
		if (*s == c)
  800c0c:	38 ca                	cmp    %cl,%dl
  800c0e:	75 0a                	jne    800c1a <strfind+0x1f>
  800c10:	eb 12                	jmp    800c24 <strfind+0x29>
  800c12:	38 ca                	cmp    %cl,%dl
  800c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c18:	74 0a                	je     800c24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	0f b6 10             	movzbl (%eax),%edx
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 ee                	jne    800c12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	89 1c 24             	mov    %ebx,(%esp)
  800c2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c40:	85 c9                	test   %ecx,%ecx
  800c42:	74 30                	je     800c74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4a:	75 25                	jne    800c71 <memset+0x4b>
  800c4c:	f6 c1 03             	test   $0x3,%cl
  800c4f:	75 20                	jne    800c71 <memset+0x4b>
		c &= 0xFF;
  800c51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	c1 e3 08             	shl    $0x8,%ebx
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	c1 e6 18             	shl    $0x18,%esi
  800c5e:	89 d0                	mov    %edx,%eax
  800c60:	c1 e0 10             	shl    $0x10,%eax
  800c63:	09 f0                	or     %esi,%eax
  800c65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c67:	09 d8                	or     %ebx,%eax
  800c69:	c1 e9 02             	shr    $0x2,%ecx
  800c6c:	fc                   	cld    
  800c6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c6f:	eb 03                	jmp    800c74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c71:	fc                   	cld    
  800c72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c74:	89 f8                	mov    %edi,%eax
  800c76:	8b 1c 24             	mov    (%esp),%ebx
  800c79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c81:	89 ec                	mov    %ebp,%esp
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	83 ec 08             	sub    $0x8,%esp
  800c8b:	89 34 24             	mov    %esi,(%esp)
  800c8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c9d:	39 c6                	cmp    %eax,%esi
  800c9f:	73 35                	jae    800cd6 <memmove+0x51>
  800ca1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ca4:	39 d0                	cmp    %edx,%eax
  800ca6:	73 2e                	jae    800cd6 <memmove+0x51>
		s += n;
		d += n;
  800ca8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800caa:	f6 c2 03             	test   $0x3,%dl
  800cad:	75 1b                	jne    800cca <memmove+0x45>
  800caf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cb5:	75 13                	jne    800cca <memmove+0x45>
  800cb7:	f6 c1 03             	test   $0x3,%cl
  800cba:	75 0e                	jne    800cca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800cbc:	83 ef 04             	sub    $0x4,%edi
  800cbf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cc2:	c1 e9 02             	shr    $0x2,%ecx
  800cc5:	fd                   	std    
  800cc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc8:	eb 09                	jmp    800cd3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cca:	83 ef 01             	sub    $0x1,%edi
  800ccd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cd0:	fd                   	std    
  800cd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cd3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cd4:	eb 20                	jmp    800cf6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cdc:	75 15                	jne    800cf3 <memmove+0x6e>
  800cde:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ce4:	75 0d                	jne    800cf3 <memmove+0x6e>
  800ce6:	f6 c1 03             	test   $0x3,%cl
  800ce9:	75 08                	jne    800cf3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800ceb:	c1 e9 02             	shr    $0x2,%ecx
  800cee:	fc                   	cld    
  800cef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf1:	eb 03                	jmp    800cf6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cf3:	fc                   	cld    
  800cf4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cf6:	8b 34 24             	mov    (%esp),%esi
  800cf9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cfd:	89 ec                	mov    %ebp,%esp
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d07:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	89 04 24             	mov    %eax,(%esp)
  800d1b:	e8 65 ff ff ff       	call   800c85 <memmove>
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	8b 75 08             	mov    0x8(%ebp),%esi
  800d2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d31:	85 c9                	test   %ecx,%ecx
  800d33:	74 36                	je     800d6b <memcmp+0x49>
		if (*s1 != *s2)
  800d35:	0f b6 06             	movzbl (%esi),%eax
  800d38:	0f b6 1f             	movzbl (%edi),%ebx
  800d3b:	38 d8                	cmp    %bl,%al
  800d3d:	74 20                	je     800d5f <memcmp+0x3d>
  800d3f:	eb 14                	jmp    800d55 <memcmp+0x33>
  800d41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d4b:	83 c2 01             	add    $0x1,%edx
  800d4e:	83 e9 01             	sub    $0x1,%ecx
  800d51:	38 d8                	cmp    %bl,%al
  800d53:	74 12                	je     800d67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d55:	0f b6 c0             	movzbl %al,%eax
  800d58:	0f b6 db             	movzbl %bl,%ebx
  800d5b:	29 d8                	sub    %ebx,%eax
  800d5d:	eb 11                	jmp    800d70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	83 e9 01             	sub    $0x1,%ecx
  800d62:	ba 00 00 00 00       	mov    $0x0,%edx
  800d67:	85 c9                	test   %ecx,%ecx
  800d69:	75 d6                	jne    800d41 <memcmp+0x1f>
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d7b:	89 c2                	mov    %eax,%edx
  800d7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d80:	39 d0                	cmp    %edx,%eax
  800d82:	73 15                	jae    800d99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d88:	38 08                	cmp    %cl,(%eax)
  800d8a:	75 06                	jne    800d92 <memfind+0x1d>
  800d8c:	eb 0b                	jmp    800d99 <memfind+0x24>
  800d8e:	38 08                	cmp    %cl,(%eax)
  800d90:	74 07                	je     800d99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d92:	83 c0 01             	add    $0x1,%eax
  800d95:	39 c2                	cmp    %eax,%edx
  800d97:	77 f5                	ja     800d8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 04             	sub    $0x4,%esp
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800daa:	0f b6 02             	movzbl (%edx),%eax
  800dad:	3c 20                	cmp    $0x20,%al
  800daf:	74 04                	je     800db5 <strtol+0x1a>
  800db1:	3c 09                	cmp    $0x9,%al
  800db3:	75 0e                	jne    800dc3 <strtol+0x28>
		s++;
  800db5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db8:	0f b6 02             	movzbl (%edx),%eax
  800dbb:	3c 20                	cmp    $0x20,%al
  800dbd:	74 f6                	je     800db5 <strtol+0x1a>
  800dbf:	3c 09                	cmp    $0x9,%al
  800dc1:	74 f2                	je     800db5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc3:	3c 2b                	cmp    $0x2b,%al
  800dc5:	75 0c                	jne    800dd3 <strtol+0x38>
		s++;
  800dc7:	83 c2 01             	add    $0x1,%edx
  800dca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dd1:	eb 15                	jmp    800de8 <strtol+0x4d>
	else if (*s == '-')
  800dd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 0a                	jne    800de8 <strtol+0x4d>
		s++, neg = 1;
  800dde:	83 c2 01             	add    $0x1,%edx
  800de1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de8:	85 db                	test   %ebx,%ebx
  800dea:	0f 94 c0             	sete   %al
  800ded:	74 05                	je     800df4 <strtol+0x59>
  800def:	83 fb 10             	cmp    $0x10,%ebx
  800df2:	75 18                	jne    800e0c <strtol+0x71>
  800df4:	80 3a 30             	cmpb   $0x30,(%edx)
  800df7:	75 13                	jne    800e0c <strtol+0x71>
  800df9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dfd:	8d 76 00             	lea    0x0(%esi),%esi
  800e00:	75 0a                	jne    800e0c <strtol+0x71>
		s += 2, base = 16;
  800e02:	83 c2 02             	add    $0x2,%edx
  800e05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e0a:	eb 15                	jmp    800e21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	84 c0                	test   %al,%al
  800e0e:	66 90                	xchg   %ax,%ax
  800e10:	74 0f                	je     800e21 <strtol+0x86>
  800e12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e17:	80 3a 30             	cmpb   $0x30,(%edx)
  800e1a:	75 05                	jne    800e21 <strtol+0x86>
		s++, base = 8;
  800e1c:	83 c2 01             	add    $0x1,%edx
  800e1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e21:	b8 00 00 00 00       	mov    $0x0,%eax
  800e26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e28:	0f b6 0a             	movzbl (%edx),%ecx
  800e2b:	89 cf                	mov    %ecx,%edi
  800e2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e30:	80 fb 09             	cmp    $0x9,%bl
  800e33:	77 08                	ja     800e3d <strtol+0xa2>
			dig = *s - '0';
  800e35:	0f be c9             	movsbl %cl,%ecx
  800e38:	83 e9 30             	sub    $0x30,%ecx
  800e3b:	eb 1e                	jmp    800e5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e40:	80 fb 19             	cmp    $0x19,%bl
  800e43:	77 08                	ja     800e4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e45:	0f be c9             	movsbl %cl,%ecx
  800e48:	83 e9 57             	sub    $0x57,%ecx
  800e4b:	eb 0e                	jmp    800e5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e50:	80 fb 19             	cmp    $0x19,%bl
  800e53:	77 15                	ja     800e6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e55:	0f be c9             	movsbl %cl,%ecx
  800e58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e5b:	39 f1                	cmp    %esi,%ecx
  800e5d:	7d 0b                	jge    800e6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e5f:	83 c2 01             	add    $0x1,%edx
  800e62:	0f af c6             	imul   %esi,%eax
  800e65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e68:	eb be                	jmp    800e28 <strtol+0x8d>
  800e6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e70:	74 05                	je     800e77 <strtol+0xdc>
		*endptr = (char *) s;
  800e72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e7b:	74 04                	je     800e81 <strtol+0xe6>
  800e7d:	89 c8                	mov    %ecx,%eax
  800e7f:	f7 d8                	neg    %eax
}
  800e81:	83 c4 04             	add    $0x4,%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	00 00                	add    %al,(%eax)
	...

00800e8c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	89 1c 24             	mov    %ebx,(%esp)
  800e95:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e99:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea3:	89 d1                	mov    %edx,%ecx
  800ea5:	89 d3                	mov    %edx,%ebx
  800ea7:	89 d7                	mov    %edx,%edi
  800ea9:	51                   	push   %ecx
  800eaa:	52                   	push   %edx
  800eab:	53                   	push   %ebx
  800eac:	54                   	push   %esp
  800ead:	55                   	push   %ebp
  800eae:	56                   	push   %esi
  800eaf:	57                   	push   %edi
  800eb0:	54                   	push   %esp
  800eb1:	5d                   	pop    %ebp
  800eb2:	8d 35 ba 0e 80 00    	lea    0x800eba,%esi
  800eb8:	0f 34                	sysenter 
  800eba:	5f                   	pop    %edi
  800ebb:	5e                   	pop    %esi
  800ebc:	5d                   	pop    %ebp
  800ebd:	5c                   	pop    %esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5a                   	pop    %edx
  800ec0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	8b 1c 24             	mov    (%esp),%ebx
  800ec4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ec8:	89 ec                	mov    %ebp,%esp
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	89 1c 24             	mov    %ebx,(%esp)
  800ed5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 c3                	mov    %eax,%ebx
  800ee6:	89 c7                	mov    %eax,%edi
  800ee8:	51                   	push   %ecx
  800ee9:	52                   	push   %edx
  800eea:	53                   	push   %ebx
  800eeb:	54                   	push   %esp
  800eec:	55                   	push   %ebp
  800eed:	56                   	push   %esi
  800eee:	57                   	push   %edi
  800eef:	54                   	push   %esp
  800ef0:	5d                   	pop    %ebp
  800ef1:	8d 35 f9 0e 80 00    	lea    0x800ef9,%esi
  800ef7:	0f 34                	sysenter 
  800ef9:	5f                   	pop    %edi
  800efa:	5e                   	pop    %esi
  800efb:	5d                   	pop    %ebp
  800efc:	5c                   	pop    %esp
  800efd:	5b                   	pop    %ebx
  800efe:	5a                   	pop    %edx
  800eff:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f00:	8b 1c 24             	mov    (%esp),%ebx
  800f03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f07:	89 ec                	mov    %ebp,%esp
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 08             	sub    $0x8,%esp
  800f11:	89 1c 24             	mov    %ebx,(%esp)
  800f14:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f18:	b8 10 00 00 00       	mov    $0x10,%eax
  800f1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	51                   	push   %ecx
  800f2a:	52                   	push   %edx
  800f2b:	53                   	push   %ebx
  800f2c:	54                   	push   %esp
  800f2d:	55                   	push   %ebp
  800f2e:	56                   	push   %esi
  800f2f:	57                   	push   %edi
  800f30:	54                   	push   %esp
  800f31:	5d                   	pop    %ebp
  800f32:	8d 35 3a 0f 80 00    	lea    0x800f3a,%esi
  800f38:	0f 34                	sysenter 
  800f3a:	5f                   	pop    %edi
  800f3b:	5e                   	pop    %esi
  800f3c:	5d                   	pop    %ebp
  800f3d:	5c                   	pop    %esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5a                   	pop    %edx
  800f40:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800f41:	8b 1c 24             	mov    (%esp),%ebx
  800f44:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f48:	89 ec                	mov    %ebp,%esp
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 28             	sub    $0x28,%esp
  800f52:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f55:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	89 df                	mov    %ebx,%edi
  800f6a:	51                   	push   %ecx
  800f6b:	52                   	push   %edx
  800f6c:	53                   	push   %ebx
  800f6d:	54                   	push   %esp
  800f6e:	55                   	push   %ebp
  800f6f:	56                   	push   %esi
  800f70:	57                   	push   %edi
  800f71:	54                   	push   %esp
  800f72:	5d                   	pop    %ebp
  800f73:	8d 35 7b 0f 80 00    	lea    0x800f7b,%esi
  800f79:	0f 34                	sysenter 
  800f7b:	5f                   	pop    %edi
  800f7c:	5e                   	pop    %esi
  800f7d:	5d                   	pop    %ebp
  800f7e:	5c                   	pop    %esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5a                   	pop    %edx
  800f81:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7e 28                	jle    800fae <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f91:	00 
  800f92:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  800f99:	00 
  800f9a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fa1:	00 
  800fa2:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  800fa9:	e8 76 0d 00 00       	call   801d24 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800fae:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fb1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb4:	89 ec                	mov    %ebp,%esp
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	89 1c 24             	mov    %ebx,(%esp)
  800fc1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fca:	b8 11 00 00 00       	mov    $0x11,%eax
  800fcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd2:	89 cb                	mov    %ecx,%ebx
  800fd4:	89 cf                	mov    %ecx,%edi
  800fd6:	51                   	push   %ecx
  800fd7:	52                   	push   %edx
  800fd8:	53                   	push   %ebx
  800fd9:	54                   	push   %esp
  800fda:	55                   	push   %ebp
  800fdb:	56                   	push   %esi
  800fdc:	57                   	push   %edi
  800fdd:	54                   	push   %esp
  800fde:	5d                   	pop    %ebp
  800fdf:	8d 35 e7 0f 80 00    	lea    0x800fe7,%esi
  800fe5:	0f 34                	sysenter 
  800fe7:	5f                   	pop    %edi
  800fe8:	5e                   	pop    %esi
  800fe9:	5d                   	pop    %ebp
  800fea:	5c                   	pop    %esp
  800feb:	5b                   	pop    %ebx
  800fec:	5a                   	pop    %edx
  800fed:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800fee:	8b 1c 24             	mov    (%esp),%ebx
  800ff1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff5:	89 ec                	mov    %ebp,%esp
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 28             	sub    $0x28,%esp
  800fff:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801002:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801005:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80100f:	8b 55 08             	mov    0x8(%ebp),%edx
  801012:	89 cb                	mov    %ecx,%ebx
  801014:	89 cf                	mov    %ecx,%edi
  801016:	51                   	push   %ecx
  801017:	52                   	push   %edx
  801018:	53                   	push   %ebx
  801019:	54                   	push   %esp
  80101a:	55                   	push   %ebp
  80101b:	56                   	push   %esi
  80101c:	57                   	push   %edi
  80101d:	54                   	push   %esp
  80101e:	5d                   	pop    %ebp
  80101f:	8d 35 27 10 80 00    	lea    0x801027,%esi
  801025:	0f 34                	sysenter 
  801027:	5f                   	pop    %edi
  801028:	5e                   	pop    %esi
  801029:	5d                   	pop    %ebp
  80102a:	5c                   	pop    %esp
  80102b:	5b                   	pop    %ebx
  80102c:	5a                   	pop    %edx
  80102d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80102e:	85 c0                	test   %eax,%eax
  801030:	7e 28                	jle    80105a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801032:	89 44 24 10          	mov    %eax,0x10(%esp)
  801036:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80103d:	00 
  80103e:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  801045:	00 
  801046:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80104d:	00 
  80104e:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  801055:	e8 ca 0c 00 00       	call   801d24 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80105a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80105d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801060:	89 ec                	mov    %ebp,%esp
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 08             	sub    $0x8,%esp
  80106a:	89 1c 24             	mov    %ebx,(%esp)
  80106d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801071:	b8 0d 00 00 00       	mov    $0xd,%eax
  801076:	8b 7d 14             	mov    0x14(%ebp),%edi
  801079:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80107c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107f:	8b 55 08             	mov    0x8(%ebp),%edx
  801082:	51                   	push   %ecx
  801083:	52                   	push   %edx
  801084:	53                   	push   %ebx
  801085:	54                   	push   %esp
  801086:	55                   	push   %ebp
  801087:	56                   	push   %esi
  801088:	57                   	push   %edi
  801089:	54                   	push   %esp
  80108a:	5d                   	pop    %ebp
  80108b:	8d 35 93 10 80 00    	lea    0x801093,%esi
  801091:	0f 34                	sysenter 
  801093:	5f                   	pop    %edi
  801094:	5e                   	pop    %esi
  801095:	5d                   	pop    %ebp
  801096:	5c                   	pop    %esp
  801097:	5b                   	pop    %ebx
  801098:	5a                   	pop    %edx
  801099:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80109a:	8b 1c 24             	mov    (%esp),%ebx
  80109d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010a1:	89 ec                	mov    %ebp,%esp
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	83 ec 28             	sub    $0x28,%esp
  8010ab:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010ae:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010be:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c1:	89 df                	mov    %ebx,%edi
  8010c3:	51                   	push   %ecx
  8010c4:	52                   	push   %edx
  8010c5:	53                   	push   %ebx
  8010c6:	54                   	push   %esp
  8010c7:	55                   	push   %ebp
  8010c8:	56                   	push   %esi
  8010c9:	57                   	push   %edi
  8010ca:	54                   	push   %esp
  8010cb:	5d                   	pop    %ebp
  8010cc:	8d 35 d4 10 80 00    	lea    0x8010d4,%esi
  8010d2:	0f 34                	sysenter 
  8010d4:	5f                   	pop    %edi
  8010d5:	5e                   	pop    %esi
  8010d6:	5d                   	pop    %ebp
  8010d7:	5c                   	pop    %esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5a                   	pop    %edx
  8010da:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	7e 28                	jle    801107 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8010ea:	00 
  8010eb:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010fa:	00 
  8010fb:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  801102:	e8 1d 0c 00 00       	call   801d24 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801107:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80110a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80110d:	89 ec                	mov    %ebp,%esp
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	83 ec 28             	sub    $0x28,%esp
  801117:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80111a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801122:	b8 0a 00 00 00       	mov    $0xa,%eax
  801127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112a:	8b 55 08             	mov    0x8(%ebp),%edx
  80112d:	89 df                	mov    %ebx,%edi
  80112f:	51                   	push   %ecx
  801130:	52                   	push   %edx
  801131:	53                   	push   %ebx
  801132:	54                   	push   %esp
  801133:	55                   	push   %ebp
  801134:	56                   	push   %esi
  801135:	57                   	push   %edi
  801136:	54                   	push   %esp
  801137:	5d                   	pop    %ebp
  801138:	8d 35 40 11 80 00    	lea    0x801140,%esi
  80113e:	0f 34                	sysenter 
  801140:	5f                   	pop    %edi
  801141:	5e                   	pop    %esi
  801142:	5d                   	pop    %ebp
  801143:	5c                   	pop    %esp
  801144:	5b                   	pop    %ebx
  801145:	5a                   	pop    %edx
  801146:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801147:	85 c0                	test   %eax,%eax
  801149:	7e 28                	jle    801173 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801156:	00 
  801157:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  80116e:	e8 b1 0b 00 00       	call   801d24 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801173:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801176:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801179:	89 ec                	mov    %ebp,%esp
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 28             	sub    $0x28,%esp
  801183:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801186:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118e:	b8 09 00 00 00       	mov    $0x9,%eax
  801193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801196:	8b 55 08             	mov    0x8(%ebp),%edx
  801199:	89 df                	mov    %ebx,%edi
  80119b:	51                   	push   %ecx
  80119c:	52                   	push   %edx
  80119d:	53                   	push   %ebx
  80119e:	54                   	push   %esp
  80119f:	55                   	push   %ebp
  8011a0:	56                   	push   %esi
  8011a1:	57                   	push   %edi
  8011a2:	54                   	push   %esp
  8011a3:	5d                   	pop    %ebp
  8011a4:	8d 35 ac 11 80 00    	lea    0x8011ac,%esi
  8011aa:	0f 34                	sysenter 
  8011ac:	5f                   	pop    %edi
  8011ad:	5e                   	pop    %esi
  8011ae:	5d                   	pop    %ebp
  8011af:	5c                   	pop    %esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5a                   	pop    %edx
  8011b2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	7e 28                	jle    8011df <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  8011da:	e8 45 0b 00 00       	call   801d24 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011e2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e5:	89 ec                	mov    %ebp,%esp
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	83 ec 28             	sub    $0x28,%esp
  8011ef:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011f2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fa:	b8 07 00 00 00       	mov    $0x7,%eax
  8011ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801202:	8b 55 08             	mov    0x8(%ebp),%edx
  801205:	89 df                	mov    %ebx,%edi
  801207:	51                   	push   %ecx
  801208:	52                   	push   %edx
  801209:	53                   	push   %ebx
  80120a:	54                   	push   %esp
  80120b:	55                   	push   %ebp
  80120c:	56                   	push   %esi
  80120d:	57                   	push   %edi
  80120e:	54                   	push   %esp
  80120f:	5d                   	pop    %ebp
  801210:	8d 35 18 12 80 00    	lea    0x801218,%esi
  801216:	0f 34                	sysenter 
  801218:	5f                   	pop    %edi
  801219:	5e                   	pop    %esi
  80121a:	5d                   	pop    %ebp
  80121b:	5c                   	pop    %esp
  80121c:	5b                   	pop    %ebx
  80121d:	5a                   	pop    %edx
  80121e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80121f:	85 c0                	test   %eax,%eax
  801221:	7e 28                	jle    80124b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801223:	89 44 24 10          	mov    %eax,0x10(%esp)
  801227:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80122e:	00 
  80122f:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  801236:	00 
  801237:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80123e:	00 
  80123f:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  801246:	e8 d9 0a 00 00       	call   801d24 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80124b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80124e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801251:	89 ec                	mov    %ebp,%esp
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	83 ec 28             	sub    $0x28,%esp
  80125b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80125e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801261:	8b 7d 18             	mov    0x18(%ebp),%edi
  801264:	0b 7d 14             	or     0x14(%ebp),%edi
  801267:	b8 06 00 00 00       	mov    $0x6,%eax
  80126c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80126f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801272:	8b 55 08             	mov    0x8(%ebp),%edx
  801275:	51                   	push   %ecx
  801276:	52                   	push   %edx
  801277:	53                   	push   %ebx
  801278:	54                   	push   %esp
  801279:	55                   	push   %ebp
  80127a:	56                   	push   %esi
  80127b:	57                   	push   %edi
  80127c:	54                   	push   %esp
  80127d:	5d                   	pop    %ebp
  80127e:	8d 35 86 12 80 00    	lea    0x801286,%esi
  801284:	0f 34                	sysenter 
  801286:	5f                   	pop    %edi
  801287:	5e                   	pop    %esi
  801288:	5d                   	pop    %ebp
  801289:	5c                   	pop    %esp
  80128a:	5b                   	pop    %ebx
  80128b:	5a                   	pop    %edx
  80128c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80128d:	85 c0                	test   %eax,%eax
  80128f:	7e 28                	jle    8012b9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801291:	89 44 24 10          	mov    %eax,0x10(%esp)
  801295:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80129c:	00 
  80129d:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012ac:	00 
  8012ad:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  8012b4:	e8 6b 0a 00 00       	call   801d24 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8012b9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012bf:	89 ec                	mov    %ebp,%esp
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 28             	sub    $0x28,%esp
  8012c9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012cc:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8012d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8012d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012df:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e2:	51                   	push   %ecx
  8012e3:	52                   	push   %edx
  8012e4:	53                   	push   %ebx
  8012e5:	54                   	push   %esp
  8012e6:	55                   	push   %ebp
  8012e7:	56                   	push   %esi
  8012e8:	57                   	push   %edi
  8012e9:	54                   	push   %esp
  8012ea:	5d                   	pop    %ebp
  8012eb:	8d 35 f3 12 80 00    	lea    0x8012f3,%esi
  8012f1:	0f 34                	sysenter 
  8012f3:	5f                   	pop    %edi
  8012f4:	5e                   	pop    %esi
  8012f5:	5d                   	pop    %ebp
  8012f6:	5c                   	pop    %esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5a                   	pop    %edx
  8012f9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	7e 28                	jle    801326 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801302:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801309:	00 
  80130a:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  801311:	00 
  801312:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801319:	00 
  80131a:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  801321:	e8 fe 09 00 00       	call   801d24 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801326:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801329:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80132c:	89 ec                	mov    %ebp,%esp
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	89 1c 24             	mov    %ebx,(%esp)
  801339:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80133d:	ba 00 00 00 00       	mov    $0x0,%edx
  801342:	b8 0c 00 00 00       	mov    $0xc,%eax
  801347:	89 d1                	mov    %edx,%ecx
  801349:	89 d3                	mov    %edx,%ebx
  80134b:	89 d7                	mov    %edx,%edi
  80134d:	51                   	push   %ecx
  80134e:	52                   	push   %edx
  80134f:	53                   	push   %ebx
  801350:	54                   	push   %esp
  801351:	55                   	push   %ebp
  801352:	56                   	push   %esi
  801353:	57                   	push   %edi
  801354:	54                   	push   %esp
  801355:	5d                   	pop    %ebp
  801356:	8d 35 5e 13 80 00    	lea    0x80135e,%esi
  80135c:	0f 34                	sysenter 
  80135e:	5f                   	pop    %edi
  80135f:	5e                   	pop    %esi
  801360:	5d                   	pop    %ebp
  801361:	5c                   	pop    %esp
  801362:	5b                   	pop    %ebx
  801363:	5a                   	pop    %edx
  801364:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801365:	8b 1c 24             	mov    (%esp),%ebx
  801368:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80136c:	89 ec                	mov    %ebp,%esp
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	89 1c 24             	mov    %ebx,(%esp)
  801379:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80137d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801382:	b8 04 00 00 00       	mov    $0x4,%eax
  801387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138a:	8b 55 08             	mov    0x8(%ebp),%edx
  80138d:	89 df                	mov    %ebx,%edi
  80138f:	51                   	push   %ecx
  801390:	52                   	push   %edx
  801391:	53                   	push   %ebx
  801392:	54                   	push   %esp
  801393:	55                   	push   %ebp
  801394:	56                   	push   %esi
  801395:	57                   	push   %edi
  801396:	54                   	push   %esp
  801397:	5d                   	pop    %ebp
  801398:	8d 35 a0 13 80 00    	lea    0x8013a0,%esi
  80139e:	0f 34                	sysenter 
  8013a0:	5f                   	pop    %edi
  8013a1:	5e                   	pop    %esi
  8013a2:	5d                   	pop    %ebp
  8013a3:	5c                   	pop    %esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5a                   	pop    %edx
  8013a6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8013a7:	8b 1c 24             	mov    (%esp),%ebx
  8013aa:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ae:	89 ec                	mov    %ebp,%esp
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	89 1c 24             	mov    %ebx,(%esp)
  8013bb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8013c9:	89 d1                	mov    %edx,%ecx
  8013cb:	89 d3                	mov    %edx,%ebx
  8013cd:	89 d7                	mov    %edx,%edi
  8013cf:	51                   	push   %ecx
  8013d0:	52                   	push   %edx
  8013d1:	53                   	push   %ebx
  8013d2:	54                   	push   %esp
  8013d3:	55                   	push   %ebp
  8013d4:	56                   	push   %esi
  8013d5:	57                   	push   %edi
  8013d6:	54                   	push   %esp
  8013d7:	5d                   	pop    %ebp
  8013d8:	8d 35 e0 13 80 00    	lea    0x8013e0,%esi
  8013de:	0f 34                	sysenter 
  8013e0:	5f                   	pop    %edi
  8013e1:	5e                   	pop    %esi
  8013e2:	5d                   	pop    %ebp
  8013e3:	5c                   	pop    %esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5a                   	pop    %edx
  8013e6:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013e7:	8b 1c 24             	mov    (%esp),%ebx
  8013ea:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ee:	89 ec                	mov    %ebp,%esp
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 28             	sub    $0x28,%esp
  8013f8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013fb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801403:	b8 03 00 00 00       	mov    $0x3,%eax
  801408:	8b 55 08             	mov    0x8(%ebp),%edx
  80140b:	89 cb                	mov    %ecx,%ebx
  80140d:	89 cf                	mov    %ecx,%edi
  80140f:	51                   	push   %ecx
  801410:	52                   	push   %edx
  801411:	53                   	push   %ebx
  801412:	54                   	push   %esp
  801413:	55                   	push   %ebp
  801414:	56                   	push   %esi
  801415:	57                   	push   %edi
  801416:	54                   	push   %esp
  801417:	5d                   	pop    %ebp
  801418:	8d 35 20 14 80 00    	lea    0x801420,%esi
  80141e:	0f 34                	sysenter 
  801420:	5f                   	pop    %edi
  801421:	5e                   	pop    %esi
  801422:	5d                   	pop    %ebp
  801423:	5c                   	pop    %esp
  801424:	5b                   	pop    %ebx
  801425:	5a                   	pop    %edx
  801426:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801427:	85 c0                	test   %eax,%eax
  801429:	7e 28                	jle    801453 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80142b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80142f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801436:	00 
  801437:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  80143e:	00 
  80143f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801446:	00 
  801447:	c7 04 24 5d 25 80 00 	movl   $0x80255d,(%esp)
  80144e:	e8 d1 08 00 00       	call   801d24 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801453:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801456:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801459:	89 ec                	mov    %ebp,%esp
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    
  80145d:	00 00                	add    %al,(%eax)
	...

00801460 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	05 00 00 00 30       	add    $0x30000000,%eax
  80146b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	89 04 24             	mov    %eax,(%esp)
  80147c:	e8 df ff ff ff       	call   801460 <fd2num>
  801481:	05 20 00 0d 00       	add    $0xd0020,%eax
  801486:	c1 e0 0c             	shl    $0xc,%eax
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	57                   	push   %edi
  80148f:	56                   	push   %esi
  801490:	53                   	push   %ebx
  801491:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801494:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801499:	a8 01                	test   $0x1,%al
  80149b:	74 36                	je     8014d3 <fd_alloc+0x48>
  80149d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014a2:	a8 01                	test   $0x1,%al
  8014a4:	74 2d                	je     8014d3 <fd_alloc+0x48>
  8014a6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8014ab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8014b0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	89 c2                	mov    %eax,%edx
  8014b9:	c1 ea 16             	shr    $0x16,%edx
  8014bc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8014bf:	f6 c2 01             	test   $0x1,%dl
  8014c2:	74 14                	je     8014d8 <fd_alloc+0x4d>
  8014c4:	89 c2                	mov    %eax,%edx
  8014c6:	c1 ea 0c             	shr    $0xc,%edx
  8014c9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8014cc:	f6 c2 01             	test   $0x1,%dl
  8014cf:	75 10                	jne    8014e1 <fd_alloc+0x56>
  8014d1:	eb 05                	jmp    8014d8 <fd_alloc+0x4d>
  8014d3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8014d8:	89 1f                	mov    %ebx,(%edi)
  8014da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8014df:	eb 17                	jmp    8014f8 <fd_alloc+0x6d>
  8014e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014eb:	75 c8                	jne    8014b5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014ed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8014f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801500:	8b 45 08             	mov    0x8(%ebp),%eax
  801503:	83 f8 1f             	cmp    $0x1f,%eax
  801506:	77 36                	ja     80153e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801508:	05 00 00 0d 00       	add    $0xd0000,%eax
  80150d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801510:	89 c2                	mov    %eax,%edx
  801512:	c1 ea 16             	shr    $0x16,%edx
  801515:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80151c:	f6 c2 01             	test   $0x1,%dl
  80151f:	74 1d                	je     80153e <fd_lookup+0x41>
  801521:	89 c2                	mov    %eax,%edx
  801523:	c1 ea 0c             	shr    $0xc,%edx
  801526:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80152d:	f6 c2 01             	test   $0x1,%dl
  801530:	74 0c                	je     80153e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801532:	8b 55 0c             	mov    0xc(%ebp),%edx
  801535:	89 02                	mov    %eax,(%edx)
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80153c:	eb 05                	jmp    801543 <fd_lookup+0x46>
  80153e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80154e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	e8 a0 ff ff ff       	call   8014fd <fd_lookup>
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 0e                	js     80156f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801561:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801564:	8b 55 0c             	mov    0xc(%ebp),%edx
  801567:	89 50 04             	mov    %edx,0x4(%eax)
  80156a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	56                   	push   %esi
  801575:	53                   	push   %ebx
  801576:	83 ec 10             	sub    $0x10,%esp
  801579:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80157c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80157f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801584:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801589:	be e8 25 80 00       	mov    $0x8025e8,%esi
		if (devtab[i]->dev_id == dev_id) {
  80158e:	39 08                	cmp    %ecx,(%eax)
  801590:	75 10                	jne    8015a2 <dev_lookup+0x31>
  801592:	eb 04                	jmp    801598 <dev_lookup+0x27>
  801594:	39 08                	cmp    %ecx,(%eax)
  801596:	75 0a                	jne    8015a2 <dev_lookup+0x31>
			*dev = devtab[i];
  801598:	89 03                	mov    %eax,(%ebx)
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80159f:	90                   	nop
  8015a0:	eb 31                	jmp    8015d3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015a2:	83 c2 01             	add    $0x1,%edx
  8015a5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	75 e8                	jne    801594 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b1:	8b 40 48             	mov    0x48(%eax),%eax
  8015b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bc:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  8015c3:	e8 a9 eb ff ff       	call   800171 <cprintf>
	*dev = 0;
  8015c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 24             	sub    $0x24,%esp
  8015e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ee:	89 04 24             	mov    %eax,(%esp)
  8015f1:	e8 07 ff ff ff       	call   8014fd <fd_lookup>
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 53                	js     80164d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801604:	8b 00                	mov    (%eax),%eax
  801606:	89 04 24             	mov    %eax,(%esp)
  801609:	e8 63 ff ff ff       	call   801571 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 3b                	js     80164d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801612:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80161e:	74 2d                	je     80164d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801620:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801623:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80162a:	00 00 00 
	stat->st_isdir = 0;
  80162d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801634:	00 00 00 
	stat->st_dev = dev;
  801637:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801644:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801647:	89 14 24             	mov    %edx,(%esp)
  80164a:	ff 50 14             	call   *0x14(%eax)
}
  80164d:	83 c4 24             	add    $0x24,%esp
  801650:	5b                   	pop    %ebx
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	53                   	push   %ebx
  801657:	83 ec 24             	sub    $0x24,%esp
  80165a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801660:	89 44 24 04          	mov    %eax,0x4(%esp)
  801664:	89 1c 24             	mov    %ebx,(%esp)
  801667:	e8 91 fe ff ff       	call   8014fd <fd_lookup>
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 5f                	js     8016cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801670:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801673:	89 44 24 04          	mov    %eax,0x4(%esp)
  801677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167a:	8b 00                	mov    (%eax),%eax
  80167c:	89 04 24             	mov    %eax,(%esp)
  80167f:	e8 ed fe ff ff       	call   801571 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801684:	85 c0                	test   %eax,%eax
  801686:	78 47                	js     8016cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801688:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80168b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80168f:	75 23                	jne    8016b4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801691:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801696:	8b 40 48             	mov    0x48(%eax),%eax
  801699:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80169d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a1:	c7 04 24 8c 25 80 00 	movl   $0x80258c,(%esp)
  8016a8:	e8 c4 ea ff ff       	call   800171 <cprintf>
  8016ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b2:	eb 1b                	jmp    8016cf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8016b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b7:	8b 48 18             	mov    0x18(%eax),%ecx
  8016ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016bf:	85 c9                	test   %ecx,%ecx
  8016c1:	74 0c                	je     8016cf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ca:	89 14 24             	mov    %edx,(%esp)
  8016cd:	ff d1                	call   *%ecx
}
  8016cf:	83 c4 24             	add    $0x24,%esp
  8016d2:	5b                   	pop    %ebx
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    

008016d5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 24             	sub    $0x24,%esp
  8016dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e6:	89 1c 24             	mov    %ebx,(%esp)
  8016e9:	e8 0f fe ff ff       	call   8014fd <fd_lookup>
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 66                	js     801758 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	8b 00                	mov    (%eax),%eax
  8016fe:	89 04 24             	mov    %eax,(%esp)
  801701:	e8 6b fe ff ff       	call   801571 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801706:	85 c0                	test   %eax,%eax
  801708:	78 4e                	js     801758 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80170d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801711:	75 23                	jne    801736 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801713:	a1 04 40 80 00       	mov    0x804004,%eax
  801718:	8b 40 48             	mov    0x48(%eax),%eax
  80171b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	c7 04 24 ad 25 80 00 	movl   $0x8025ad,(%esp)
  80172a:	e8 42 ea ff ff       	call   800171 <cprintf>
  80172f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801734:	eb 22                	jmp    801758 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801739:	8b 48 0c             	mov    0xc(%eax),%ecx
  80173c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801741:	85 c9                	test   %ecx,%ecx
  801743:	74 13                	je     801758 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801745:	8b 45 10             	mov    0x10(%ebp),%eax
  801748:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	89 14 24             	mov    %edx,(%esp)
  801756:	ff d1                	call   *%ecx
}
  801758:	83 c4 24             	add    $0x24,%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 24             	sub    $0x24,%esp
  801765:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176f:	89 1c 24             	mov    %ebx,(%esp)
  801772:	e8 86 fd ff ff       	call   8014fd <fd_lookup>
  801777:	85 c0                	test   %eax,%eax
  801779:	78 6b                	js     8017e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801785:	8b 00                	mov    (%eax),%eax
  801787:	89 04 24             	mov    %eax,(%esp)
  80178a:	e8 e2 fd ff ff       	call   801571 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 53                	js     8017e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801793:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801796:	8b 42 08             	mov    0x8(%edx),%eax
  801799:	83 e0 03             	and    $0x3,%eax
  80179c:	83 f8 01             	cmp    $0x1,%eax
  80179f:	75 23                	jne    8017c4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017a6:	8b 40 48             	mov    0x48(%eax),%eax
  8017a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	c7 04 24 ca 25 80 00 	movl   $0x8025ca,(%esp)
  8017b8:	e8 b4 e9 ff ff       	call   800171 <cprintf>
  8017bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8017c2:	eb 22                	jmp    8017e6 <read+0x88>
	}
	if (!dev->dev_read)
  8017c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c7:	8b 48 08             	mov    0x8(%eax),%ecx
  8017ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017cf:	85 c9                	test   %ecx,%ecx
  8017d1:	74 13                	je     8017e6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	89 14 24             	mov    %edx,(%esp)
  8017e4:	ff d1                	call   *%ecx
}
  8017e6:	83 c4 24             	add    $0x24,%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	57                   	push   %edi
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 1c             	sub    $0x1c,%esp
  8017f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801800:	bb 00 00 00 00       	mov    $0x0,%ebx
  801805:	b8 00 00 00 00       	mov    $0x0,%eax
  80180a:	85 f6                	test   %esi,%esi
  80180c:	74 29                	je     801837 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80180e:	89 f0                	mov    %esi,%eax
  801810:	29 d0                	sub    %edx,%eax
  801812:	89 44 24 08          	mov    %eax,0x8(%esp)
  801816:	03 55 0c             	add    0xc(%ebp),%edx
  801819:	89 54 24 04          	mov    %edx,0x4(%esp)
  80181d:	89 3c 24             	mov    %edi,(%esp)
  801820:	e8 39 ff ff ff       	call   80175e <read>
		if (m < 0)
  801825:	85 c0                	test   %eax,%eax
  801827:	78 0e                	js     801837 <readn+0x4b>
			return m;
		if (m == 0)
  801829:	85 c0                	test   %eax,%eax
  80182b:	74 08                	je     801835 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80182d:	01 c3                	add    %eax,%ebx
  80182f:	89 da                	mov    %ebx,%edx
  801831:	39 f3                	cmp    %esi,%ebx
  801833:	72 d9                	jb     80180e <readn+0x22>
  801835:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801837:	83 c4 1c             	add    $0x1c,%esp
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5f                   	pop    %edi
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	56                   	push   %esi
  801843:	53                   	push   %ebx
  801844:	83 ec 20             	sub    $0x20,%esp
  801847:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80184a:	89 34 24             	mov    %esi,(%esp)
  80184d:	e8 0e fc ff ff       	call   801460 <fd2num>
  801852:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801855:	89 54 24 04          	mov    %edx,0x4(%esp)
  801859:	89 04 24             	mov    %eax,(%esp)
  80185c:	e8 9c fc ff ff       	call   8014fd <fd_lookup>
  801861:	89 c3                	mov    %eax,%ebx
  801863:	85 c0                	test   %eax,%eax
  801865:	78 05                	js     80186c <fd_close+0x2d>
  801867:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80186a:	74 0c                	je     801878 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80186c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801870:	19 c0                	sbb    %eax,%eax
  801872:	f7 d0                	not    %eax
  801874:	21 c3                	and    %eax,%ebx
  801876:	eb 3d                	jmp    8018b5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801878:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187f:	8b 06                	mov    (%esi),%eax
  801881:	89 04 24             	mov    %eax,(%esp)
  801884:	e8 e8 fc ff ff       	call   801571 <dev_lookup>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 16                	js     8018a5 <fd_close+0x66>
		if (dev->dev_close)
  80188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801892:	8b 40 10             	mov    0x10(%eax),%eax
  801895:	bb 00 00 00 00       	mov    $0x0,%ebx
  80189a:	85 c0                	test   %eax,%eax
  80189c:	74 07                	je     8018a5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80189e:	89 34 24             	mov    %esi,(%esp)
  8018a1:	ff d0                	call   *%eax
  8018a3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b0:	e8 34 f9 ff ff       	call   8011e9 <sys_page_unmap>
	return r;
}
  8018b5:	89 d8                	mov    %ebx,%eax
  8018b7:	83 c4 20             	add    $0x20,%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	89 04 24             	mov    %eax,(%esp)
  8018d1:	e8 27 fc ff ff       	call   8014fd <fd_lookup>
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 13                	js     8018ed <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8018da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018e1:	00 
  8018e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e5:	89 04 24             	mov    %eax,(%esp)
  8018e8:	e8 52 ff ff ff       	call   80183f <fd_close>
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 18             	sub    $0x18,%esp
  8018f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801902:	00 
  801903:	8b 45 08             	mov    0x8(%ebp),%eax
  801906:	89 04 24             	mov    %eax,(%esp)
  801909:	e8 79 03 00 00       	call   801c87 <open>
  80190e:	89 c3                	mov    %eax,%ebx
  801910:	85 c0                	test   %eax,%eax
  801912:	78 1b                	js     80192f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801914:	8b 45 0c             	mov    0xc(%ebp),%eax
  801917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191b:	89 1c 24             	mov    %ebx,(%esp)
  80191e:	e8 b7 fc ff ff       	call   8015da <fstat>
  801923:	89 c6                	mov    %eax,%esi
	close(fd);
  801925:	89 1c 24             	mov    %ebx,(%esp)
  801928:	e8 91 ff ff ff       	call   8018be <close>
  80192d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80192f:	89 d8                	mov    %ebx,%eax
  801931:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801934:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801937:	89 ec                	mov    %ebp,%esp
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	53                   	push   %ebx
  80193f:	83 ec 14             	sub    $0x14,%esp
  801942:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801947:	89 1c 24             	mov    %ebx,(%esp)
  80194a:	e8 6f ff ff ff       	call   8018be <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80194f:	83 c3 01             	add    $0x1,%ebx
  801952:	83 fb 20             	cmp    $0x20,%ebx
  801955:	75 f0                	jne    801947 <close_all+0xc>
		close(i);
}
  801957:	83 c4 14             	add    $0x14,%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	83 ec 58             	sub    $0x58,%esp
  801963:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801966:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801969:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80196c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80196f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801972:	89 44 24 04          	mov    %eax,0x4(%esp)
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	89 04 24             	mov    %eax,(%esp)
  80197c:	e8 7c fb ff ff       	call   8014fd <fd_lookup>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	85 c0                	test   %eax,%eax
  801985:	0f 88 e0 00 00 00    	js     801a6b <dup+0x10e>
		return r;
	close(newfdnum);
  80198b:	89 3c 24             	mov    %edi,(%esp)
  80198e:	e8 2b ff ff ff       	call   8018be <close>

	newfd = INDEX2FD(newfdnum);
  801993:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801999:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80199c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80199f:	89 04 24             	mov    %eax,(%esp)
  8019a2:	e8 c9 fa ff ff       	call   801470 <fd2data>
  8019a7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8019a9:	89 34 24             	mov    %esi,(%esp)
  8019ac:	e8 bf fa ff ff       	call   801470 <fd2data>
  8019b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8019b4:	89 da                	mov    %ebx,%edx
  8019b6:	89 d8                	mov    %ebx,%eax
  8019b8:	c1 e8 16             	shr    $0x16,%eax
  8019bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019c2:	a8 01                	test   $0x1,%al
  8019c4:	74 43                	je     801a09 <dup+0xac>
  8019c6:	c1 ea 0c             	shr    $0xc,%edx
  8019c9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019d0:	a8 01                	test   $0x1,%al
  8019d2:	74 35                	je     801a09 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019d4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019db:	25 07 0e 00 00       	and    $0xe07,%eax
  8019e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f2:	00 
  8019f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fe:	e8 52 f8 ff ff       	call   801255 <sys_page_map>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 3f                	js     801a48 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0c:	89 c2                	mov    %eax,%edx
  801a0e:	c1 ea 0c             	shr    $0xc,%edx
  801a11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a18:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a1e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a22:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a2d:	00 
  801a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a39:	e8 17 f8 ff ff       	call   801255 <sys_page_map>
  801a3e:	89 c3                	mov    %eax,%ebx
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 04                	js     801a48 <dup+0xeb>
  801a44:	89 fb                	mov    %edi,%ebx
  801a46:	eb 23                	jmp    801a6b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a48:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a53:	e8 91 f7 ff ff       	call   8011e9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a66:	e8 7e f7 ff ff       	call   8011e9 <sys_page_unmap>
	return r;
}
  801a6b:	89 d8                	mov    %ebx,%eax
  801a6d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a70:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a73:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a76:	89 ec                	mov    %ebp,%esp
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    
	...

00801a7c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 18             	sub    $0x18,%esp
  801a82:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a85:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a88:	89 c3                	mov    %eax,%ebx
  801a8a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a8c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a93:	75 11                	jne    801aa6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a95:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801a9c:	e8 df 02 00 00       	call   801d80 <ipc_find_env>
  801aa1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aa6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801aad:	00 
  801aae:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ab5:	00 
  801ab6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aba:	a1 00 40 80 00       	mov    0x804000,%eax
  801abf:	89 04 24             	mov    %eax,(%esp)
  801ac2:	e8 04 03 00 00       	call   801dcb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ac7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ace:	00 
  801acf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ad3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ada:	e8 6a 03 00 00       	call   801e49 <ipc_recv>
}
  801adf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ae2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ae5:	89 ec                	mov    %ebp,%esp
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aef:	8b 45 08             	mov    0x8(%ebp),%eax
  801af2:	8b 40 0c             	mov    0xc(%eax),%eax
  801af5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b02:	ba 00 00 00 00       	mov    $0x0,%edx
  801b07:	b8 02 00 00 00       	mov    $0x2,%eax
  801b0c:	e8 6b ff ff ff       	call   801a7c <fsipc>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b24:	ba 00 00 00 00       	mov    $0x0,%edx
  801b29:	b8 06 00 00 00       	mov    $0x6,%eax
  801b2e:	e8 49 ff ff ff       	call   801a7c <fsipc>
}
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b40:	b8 08 00 00 00       	mov    $0x8,%eax
  801b45:	e8 32 ff ff ff       	call   801a7c <fsipc>
}
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 14             	sub    $0x14,%esp
  801b53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b61:	ba 00 00 00 00       	mov    $0x0,%edx
  801b66:	b8 05 00 00 00       	mov    $0x5,%eax
  801b6b:	e8 0c ff ff ff       	call   801a7c <fsipc>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 2b                	js     801b9f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b74:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b7b:	00 
  801b7c:	89 1c 24             	mov    %ebx,(%esp)
  801b7f:	e8 16 ef ff ff       	call   800a9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b84:	a1 80 50 80 00       	mov    0x805080,%eax
  801b89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b8f:	a1 84 50 80 00       	mov    0x805084,%eax
  801b94:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801b9a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801b9f:	83 c4 14             	add    $0x14,%esp
  801ba2:	5b                   	pop    %ebx
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 18             	sub    $0x18,%esp
  801bab:	8b 45 10             	mov    0x10(%ebp),%eax
  801bae:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bb3:	76 05                	jbe    801bba <devfile_write+0x15>
  801bb5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bba:	8b 55 08             	mov    0x8(%ebp),%edx
  801bbd:	8b 52 0c             	mov    0xc(%edx),%edx
  801bc0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801bc6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801bcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801bdd:	e8 a3 f0 ff ff       	call   800c85 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801be2:	ba 00 00 00 00       	mov    $0x0,%edx
  801be7:	b8 04 00 00 00       	mov    $0x4,%eax
  801bec:	e8 8b fe ff ff       	call   801a7c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	8b 40 0c             	mov    0xc(%eax),%eax
  801c00:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801c05:	8b 45 10             	mov    0x10(%ebp),%eax
  801c08:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c12:	b8 03 00 00 00       	mov    $0x3,%eax
  801c17:	e8 60 fe ff ff       	call   801a7c <fsipc>
  801c1c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	78 17                	js     801c39 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801c22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c26:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c2d:	00 
  801c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c31:	89 04 24             	mov    %eax,(%esp)
  801c34:	e8 4c f0 ff ff       	call   800c85 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801c39:	89 d8                	mov    %ebx,%eax
  801c3b:	83 c4 14             	add    $0x14,%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	53                   	push   %ebx
  801c45:	83 ec 14             	sub    $0x14,%esp
  801c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c4b:	89 1c 24             	mov    %ebx,(%esp)
  801c4e:	e8 fd ed ff ff       	call   800a50 <strlen>
  801c53:	89 c2                	mov    %eax,%edx
  801c55:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801c5a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801c60:	7f 1f                	jg     801c81 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801c62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c66:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c6d:	e8 28 ee ff ff       	call   800a9a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801c72:	ba 00 00 00 00       	mov    $0x0,%edx
  801c77:	b8 07 00 00 00       	mov    $0x7,%eax
  801c7c:	e8 fb fd ff ff       	call   801a7c <fsipc>
}
  801c81:	83 c4 14             	add    $0x14,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	83 ec 28             	sub    $0x28,%esp
  801c8d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c90:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c93:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801c96:	89 34 24             	mov    %esi,(%esp)
  801c99:	e8 b2 ed ff ff       	call   800a50 <strlen>
  801c9e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ca3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ca8:	7f 6d                	jg     801d17 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cad:	89 04 24             	mov    %eax,(%esp)
  801cb0:	e8 d6 f7 ff ff       	call   80148b <fd_alloc>
  801cb5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 5c                	js     801d17 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801cc3:	89 34 24             	mov    %esi,(%esp)
  801cc6:	e8 85 ed ff ff       	call   800a50 <strlen>
  801ccb:	83 c0 01             	add    $0x1,%eax
  801cce:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cdd:	e8 a3 ef ff ff       	call   800c85 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801ce2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cea:	e8 8d fd ff ff       	call   801a7c <fsipc>
  801cef:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	79 15                	jns    801d0a <open+0x83>
             fd_close(fd,0);
  801cf5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cfc:	00 
  801cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d00:	89 04 24             	mov    %eax,(%esp)
  801d03:	e8 37 fb ff ff       	call   80183f <fd_close>
             return r;
  801d08:	eb 0d                	jmp    801d17 <open+0x90>
        }
        return fd2num(fd);
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	89 04 24             	mov    %eax,(%esp)
  801d10:	e8 4b f7 ff ff       	call   801460 <fd2num>
  801d15:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801d17:	89 d8                	mov    %ebx,%eax
  801d19:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d1c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d1f:	89 ec                	mov    %ebp,%esp
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    
	...

00801d24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	56                   	push   %esi
  801d28:	53                   	push   %ebx
  801d29:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801d2c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d2f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d35:	e8 78 f6 ff ff       	call   8013b2 <sys_getenvid>
  801d3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d3d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d41:	8b 55 08             	mov    0x8(%ebp),%edx
  801d44:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d48:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d50:	c7 04 24 f0 25 80 00 	movl   $0x8025f0,(%esp)
  801d57:	e8 15 e4 ff ff       	call   800171 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d60:	8b 45 10             	mov    0x10(%ebp),%eax
  801d63:	89 04 24             	mov    %eax,(%esp)
  801d66:	e8 a5 e3 ff ff       	call   800110 <vcprintf>
	cprintf("\n");
  801d6b:	c7 04 24 e4 25 80 00 	movl   $0x8025e4,(%esp)
  801d72:	e8 fa e3 ff ff       	call   800171 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d77:	cc                   	int3   
  801d78:	eb fd                	jmp    801d77 <_panic+0x53>
  801d7a:	00 00                	add    %al,(%eax)
  801d7c:	00 00                	add    %al,(%eax)
	...

00801d80 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d86:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801d8c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d91:	39 ca                	cmp    %ecx,%edx
  801d93:	75 04                	jne    801d99 <ipc_find_env+0x19>
  801d95:	b0 00                	mov    $0x0,%al
  801d97:	eb 12                	jmp    801dab <ipc_find_env+0x2b>
  801d99:	89 c2                	mov    %eax,%edx
  801d9b:	c1 e2 07             	shl    $0x7,%edx
  801d9e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801da5:	8b 12                	mov    (%edx),%edx
  801da7:	39 ca                	cmp    %ecx,%edx
  801da9:	75 10                	jne    801dbb <ipc_find_env+0x3b>
			return envs[i].env_id;
  801dab:	89 c2                	mov    %eax,%edx
  801dad:	c1 e2 07             	shl    $0x7,%edx
  801db0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801db7:	8b 00                	mov    (%eax),%eax
  801db9:	eb 0e                	jmp    801dc9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dbb:	83 c0 01             	add    $0x1,%eax
  801dbe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dc3:	75 d4                	jne    801d99 <ipc_find_env+0x19>
  801dc5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    

00801dcb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	57                   	push   %edi
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	83 ec 1c             	sub    $0x1c,%esp
  801dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801dda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801ddd:	85 db                	test   %ebx,%ebx
  801ddf:	74 19                	je     801dfa <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801de1:	8b 45 14             	mov    0x14(%ebp),%eax
  801de4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801de8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801df0:	89 34 24             	mov    %esi,(%esp)
  801df3:	e8 6c f2 ff ff       	call   801064 <sys_ipc_try_send>
  801df8:	eb 1b                	jmp    801e15 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801dfa:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e01:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801e08:	ee 
  801e09:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e0d:	89 34 24             	mov    %esi,(%esp)
  801e10:	e8 4f f2 ff ff       	call   801064 <sys_ipc_try_send>
           if(ret == 0)
  801e15:	85 c0                	test   %eax,%eax
  801e17:	74 28                	je     801e41 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801e19:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e1c:	74 1c                	je     801e3a <ipc_send+0x6f>
              panic("ipc send error");
  801e1e:	c7 44 24 08 14 26 80 	movl   $0x802614,0x8(%esp)
  801e25:	00 
  801e26:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801e2d:	00 
  801e2e:	c7 04 24 23 26 80 00 	movl   $0x802623,(%esp)
  801e35:	e8 ea fe ff ff       	call   801d24 <_panic>
           sys_yield();
  801e3a:	e8 f1 f4 ff ff       	call   801330 <sys_yield>
        }
  801e3f:	eb 9c                	jmp    801ddd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801e41:	83 c4 1c             	add    $0x1c,%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	56                   	push   %esi
  801e4d:	53                   	push   %ebx
  801e4e:	83 ec 10             	sub    $0x10,%esp
  801e51:	8b 75 08             	mov    0x8(%ebp),%esi
  801e54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	75 0e                	jne    801e6c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e5e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e65:	e8 8f f1 ff ff       	call   800ff9 <sys_ipc_recv>
  801e6a:	eb 08                	jmp    801e74 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e6c:	89 04 24             	mov    %eax,(%esp)
  801e6f:	e8 85 f1 ff ff       	call   800ff9 <sys_ipc_recv>
        if(ret == 0){
  801e74:	85 c0                	test   %eax,%eax
  801e76:	75 26                	jne    801e9e <ipc_recv+0x55>
           if(from_env_store)
  801e78:	85 f6                	test   %esi,%esi
  801e7a:	74 0a                	je     801e86 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e81:	8b 40 78             	mov    0x78(%eax),%eax
  801e84:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801e86:	85 db                	test   %ebx,%ebx
  801e88:	74 0a                	je     801e94 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801e8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e8f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e92:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801e94:	a1 04 40 80 00       	mov    0x804004,%eax
  801e99:	8b 40 74             	mov    0x74(%eax),%eax
  801e9c:	eb 14                	jmp    801eb2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801e9e:	85 f6                	test   %esi,%esi
  801ea0:	74 06                	je     801ea8 <ipc_recv+0x5f>
              *from_env_store = 0;
  801ea2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801ea8:	85 db                	test   %ebx,%ebx
  801eaa:	74 06                	je     801eb2 <ipc_recv+0x69>
              *perm_store = 0;
  801eac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    
  801eb9:	00 00                	add    %al,(%eax)
  801ebb:	00 00                	add    %al,(%eax)
  801ebd:	00 00                	add    %al,(%eax)
	...

00801ec0 <__udivdi3>:
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	57                   	push   %edi
  801ec4:	56                   	push   %esi
  801ec5:	83 ec 10             	sub    $0x10,%esp
  801ec8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  801ece:	8b 75 10             	mov    0x10(%ebp),%esi
  801ed1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801ed9:	75 35                	jne    801f10 <__udivdi3+0x50>
  801edb:	39 fe                	cmp    %edi,%esi
  801edd:	77 61                	ja     801f40 <__udivdi3+0x80>
  801edf:	85 f6                	test   %esi,%esi
  801ee1:	75 0b                	jne    801eee <__udivdi3+0x2e>
  801ee3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee8:	31 d2                	xor    %edx,%edx
  801eea:	f7 f6                	div    %esi
  801eec:	89 c6                	mov    %eax,%esi
  801eee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ef1:	31 d2                	xor    %edx,%edx
  801ef3:	89 f8                	mov    %edi,%eax
  801ef5:	f7 f6                	div    %esi
  801ef7:	89 c7                	mov    %eax,%edi
  801ef9:	89 c8                	mov    %ecx,%eax
  801efb:	f7 f6                	div    %esi
  801efd:	89 c1                	mov    %eax,%ecx
  801eff:	89 fa                	mov    %edi,%edx
  801f01:	89 c8                	mov    %ecx,%eax
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	5e                   	pop    %esi
  801f07:	5f                   	pop    %edi
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    
  801f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f10:	39 f8                	cmp    %edi,%eax
  801f12:	77 1c                	ja     801f30 <__udivdi3+0x70>
  801f14:	0f bd d0             	bsr    %eax,%edx
  801f17:	83 f2 1f             	xor    $0x1f,%edx
  801f1a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f1d:	75 39                	jne    801f58 <__udivdi3+0x98>
  801f1f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f22:	0f 86 a0 00 00 00    	jbe    801fc8 <__udivdi3+0x108>
  801f28:	39 f8                	cmp    %edi,%eax
  801f2a:	0f 82 98 00 00 00    	jb     801fc8 <__udivdi3+0x108>
  801f30:	31 ff                	xor    %edi,%edi
  801f32:	31 c9                	xor    %ecx,%ecx
  801f34:	89 c8                	mov    %ecx,%eax
  801f36:	89 fa                	mov    %edi,%edx
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	5e                   	pop    %esi
  801f3c:	5f                   	pop    %edi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    
  801f3f:	90                   	nop
  801f40:	89 d1                	mov    %edx,%ecx
  801f42:	89 fa                	mov    %edi,%edx
  801f44:	89 c8                	mov    %ecx,%eax
  801f46:	31 ff                	xor    %edi,%edi
  801f48:	f7 f6                	div    %esi
  801f4a:	89 c1                	mov    %eax,%ecx
  801f4c:	89 fa                	mov    %edi,%edx
  801f4e:	89 c8                	mov    %ecx,%eax
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	5e                   	pop    %esi
  801f54:	5f                   	pop    %edi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    
  801f57:	90                   	nop
  801f58:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f5c:	89 f2                	mov    %esi,%edx
  801f5e:	d3 e0                	shl    %cl,%eax
  801f60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f63:	b8 20 00 00 00       	mov    $0x20,%eax
  801f68:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f6b:	89 c1                	mov    %eax,%ecx
  801f6d:	d3 ea                	shr    %cl,%edx
  801f6f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f73:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f76:	d3 e6                	shl    %cl,%esi
  801f78:	89 c1                	mov    %eax,%ecx
  801f7a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f7d:	89 fe                	mov    %edi,%esi
  801f7f:	d3 ee                	shr    %cl,%esi
  801f81:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f85:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f8b:	d3 e7                	shl    %cl,%edi
  801f8d:	89 c1                	mov    %eax,%ecx
  801f8f:	d3 ea                	shr    %cl,%edx
  801f91:	09 d7                	or     %edx,%edi
  801f93:	89 f2                	mov    %esi,%edx
  801f95:	89 f8                	mov    %edi,%eax
  801f97:	f7 75 ec             	divl   -0x14(%ebp)
  801f9a:	89 d6                	mov    %edx,%esi
  801f9c:	89 c7                	mov    %eax,%edi
  801f9e:	f7 65 e8             	mull   -0x18(%ebp)
  801fa1:	39 d6                	cmp    %edx,%esi
  801fa3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fa6:	72 30                	jb     801fd8 <__udivdi3+0x118>
  801fa8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801faf:	d3 e2                	shl    %cl,%edx
  801fb1:	39 c2                	cmp    %eax,%edx
  801fb3:	73 05                	jae    801fba <__udivdi3+0xfa>
  801fb5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801fb8:	74 1e                	je     801fd8 <__udivdi3+0x118>
  801fba:	89 f9                	mov    %edi,%ecx
  801fbc:	31 ff                	xor    %edi,%edi
  801fbe:	e9 71 ff ff ff       	jmp    801f34 <__udivdi3+0x74>
  801fc3:	90                   	nop
  801fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc8:	31 ff                	xor    %edi,%edi
  801fca:	b9 01 00 00 00       	mov    $0x1,%ecx
  801fcf:	e9 60 ff ff ff       	jmp    801f34 <__udivdi3+0x74>
  801fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801fdb:	31 ff                	xor    %edi,%edi
  801fdd:	89 c8                	mov    %ecx,%eax
  801fdf:	89 fa                	mov    %edi,%edx
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
	...

00801ff0 <__umoddi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	57                   	push   %edi
  801ff4:	56                   	push   %esi
  801ff5:	83 ec 20             	sub    $0x20,%esp
  801ff8:	8b 55 14             	mov    0x14(%ebp),%edx
  801ffb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ffe:	8b 7d 10             	mov    0x10(%ebp),%edi
  802001:	8b 75 0c             	mov    0xc(%ebp),%esi
  802004:	85 d2                	test   %edx,%edx
  802006:	89 c8                	mov    %ecx,%eax
  802008:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80200b:	75 13                	jne    802020 <__umoddi3+0x30>
  80200d:	39 f7                	cmp    %esi,%edi
  80200f:	76 3f                	jbe    802050 <__umoddi3+0x60>
  802011:	89 f2                	mov    %esi,%edx
  802013:	f7 f7                	div    %edi
  802015:	89 d0                	mov    %edx,%eax
  802017:	31 d2                	xor    %edx,%edx
  802019:	83 c4 20             	add    $0x20,%esp
  80201c:	5e                   	pop    %esi
  80201d:	5f                   	pop    %edi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    
  802020:	39 f2                	cmp    %esi,%edx
  802022:	77 4c                	ja     802070 <__umoddi3+0x80>
  802024:	0f bd ca             	bsr    %edx,%ecx
  802027:	83 f1 1f             	xor    $0x1f,%ecx
  80202a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80202d:	75 51                	jne    802080 <__umoddi3+0x90>
  80202f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802032:	0f 87 e0 00 00 00    	ja     802118 <__umoddi3+0x128>
  802038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203b:	29 f8                	sub    %edi,%eax
  80203d:	19 d6                	sbb    %edx,%esi
  80203f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802045:	89 f2                	mov    %esi,%edx
  802047:	83 c4 20             	add    $0x20,%esp
  80204a:	5e                   	pop    %esi
  80204b:	5f                   	pop    %edi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    
  80204e:	66 90                	xchg   %ax,%ax
  802050:	85 ff                	test   %edi,%edi
  802052:	75 0b                	jne    80205f <__umoddi3+0x6f>
  802054:	b8 01 00 00 00       	mov    $0x1,%eax
  802059:	31 d2                	xor    %edx,%edx
  80205b:	f7 f7                	div    %edi
  80205d:	89 c7                	mov    %eax,%edi
  80205f:	89 f0                	mov    %esi,%eax
  802061:	31 d2                	xor    %edx,%edx
  802063:	f7 f7                	div    %edi
  802065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802068:	f7 f7                	div    %edi
  80206a:	eb a9                	jmp    802015 <__umoddi3+0x25>
  80206c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 c8                	mov    %ecx,%eax
  802072:	89 f2                	mov    %esi,%edx
  802074:	83 c4 20             	add    $0x20,%esp
  802077:	5e                   	pop    %esi
  802078:	5f                   	pop    %edi
  802079:	5d                   	pop    %ebp
  80207a:	c3                   	ret    
  80207b:	90                   	nop
  80207c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802080:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802084:	d3 e2                	shl    %cl,%edx
  802086:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802089:	ba 20 00 00 00       	mov    $0x20,%edx
  80208e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802091:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802094:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802098:	89 fa                	mov    %edi,%edx
  80209a:	d3 ea                	shr    %cl,%edx
  80209c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8020a3:	d3 e7                	shl    %cl,%edi
  8020a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020ac:	89 f2                	mov    %esi,%edx
  8020ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8020b1:	89 c7                	mov    %eax,%edi
  8020b3:	d3 ea                	shr    %cl,%edx
  8020b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020bc:	89 c2                	mov    %eax,%edx
  8020be:	d3 e6                	shl    %cl,%esi
  8020c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020c4:	d3 ea                	shr    %cl,%edx
  8020c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020ca:	09 d6                	or     %edx,%esi
  8020cc:	89 f0                	mov    %esi,%eax
  8020ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8020d1:	d3 e7                	shl    %cl,%edi
  8020d3:	89 f2                	mov    %esi,%edx
  8020d5:	f7 75 f4             	divl   -0xc(%ebp)
  8020d8:	89 d6                	mov    %edx,%esi
  8020da:	f7 65 e8             	mull   -0x18(%ebp)
  8020dd:	39 d6                	cmp    %edx,%esi
  8020df:	72 2b                	jb     80210c <__umoddi3+0x11c>
  8020e1:	39 c7                	cmp    %eax,%edi
  8020e3:	72 23                	jb     802108 <__umoddi3+0x118>
  8020e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020e9:	29 c7                	sub    %eax,%edi
  8020eb:	19 d6                	sbb    %edx,%esi
  8020ed:	89 f0                	mov    %esi,%eax
  8020ef:	89 f2                	mov    %esi,%edx
  8020f1:	d3 ef                	shr    %cl,%edi
  8020f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020f7:	d3 e0                	shl    %cl,%eax
  8020f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020fd:	09 f8                	or     %edi,%eax
  8020ff:	d3 ea                	shr    %cl,%edx
  802101:	83 c4 20             	add    $0x20,%esp
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	39 d6                	cmp    %edx,%esi
  80210a:	75 d9                	jne    8020e5 <__umoddi3+0xf5>
  80210c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80210f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802112:	eb d1                	jmp    8020e5 <__umoddi3+0xf5>
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	0f 82 18 ff ff ff    	jb     802038 <__umoddi3+0x48>
  802120:	e9 1d ff ff ff       	jmp    802042 <__umoddi3+0x52>
