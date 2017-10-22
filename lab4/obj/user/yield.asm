
obj/user/yield:     file format elf32-i386


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
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 a0 16 80 00 	movl   $0x8016a0,(%esp)
  80004e:	e8 16 01 00 00       	call   800169 <cprintf>
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 5; i++) {
		sys_yield();
  800058:	e8 26 12 00 00       	call   801283 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  800074:	e8 f0 00 00 00       	call   800169 <cprintf>
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
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 ec 16 80 00 	movl   $0x8016ec,(%esp)
  800094:	e8 d0 00 00 00       	call   800169 <cprintf>
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
  8000b2:	e8 4e 12 00 00       	call   801305 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	89 c2                	mov    %eax,%edx
  8000be:	c1 e2 07             	shl    $0x7,%edx
  8000c1:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000c8:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cd:	85 f6                	test   %esi,%esi
  8000cf:	7e 07                	jle    8000d8 <libmain+0x38>
		binaryname = argv[0];
  8000d1:	8b 03                	mov    (%ebx),%eax
  8000d3:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8000fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800101:	e8 3f 12 00 00       	call   801345 <sys_env_destroy>
}
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800111:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800118:	00 00 00 
	b.cnt = 0;
  80011b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800122:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012c:	8b 45 08             	mov    0x8(%ebp),%eax
  80012f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800133:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013d:	c7 04 24 83 01 80 00 	movl   $0x800183,(%esp)
  800144:	e8 d3 01 00 00       	call   80031c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800149:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800159:	89 04 24             	mov    %eax,(%esp)
  80015c:	e8 6b 0d 00 00       	call   800ecc <sys_cputs>

	return b.cnt;
}
  800161:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80016f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800172:	89 44 24 04          	mov    %eax,0x4(%esp)
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 87 ff ff ff       	call   800108 <vcprintf>
	va_end(ap);

	return cnt;
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	53                   	push   %ebx
  800187:	83 ec 14             	sub    $0x14,%esp
  80018a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018d:	8b 03                	mov    (%ebx),%eax
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800196:	83 c0 01             	add    $0x1,%eax
  800199:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a0:	75 19                	jne    8001bb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001a2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a9:	00 
  8001aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 17 0d 00 00       	call   800ecc <sys_cputs>
		b->idx = 0;
  8001b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	83 c4 14             	add    $0x14,%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    
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
  80023f:	e8 dc 11 00 00       	call   801420 <__udivdi3>
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
  8002a7:	e8 a4 12 00 00       	call   801550 <__umoddi3>
  8002ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b0:	0f be 80 15 17 80 00 	movsbl 0x801715(%eax),%eax
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
  80039a:	ff 24 95 60 18 80 00 	jmp    *0x801860(,%edx,4)
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
  800452:	83 f8 08             	cmp    $0x8,%eax
  800455:	7f 0b                	jg     800462 <vprintfmt+0x146>
  800457:	8b 14 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	75 26                	jne    800488 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 26 17 80 	movl   $0x801726,0x8(%esp)
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
  80048c:	c7 44 24 08 2f 17 80 	movl   $0x80172f,0x8(%esp)
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
  8004ca:	be 32 17 80 00       	mov    $0x801732,%esi
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
  800774:	e8 a7 0c 00 00       	call   801420 <__udivdi3>
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
  8007c0:	e8 8b 0d 00 00       	call   801550 <__umoddi3>
  8007c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c9:	0f be 80 15 17 80 00 	movsbl 0x801715(%eax),%eax
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
  800875:	c7 44 24 0c cc 17 80 	movl   $0x8017cc,0xc(%esp)
  80087c:	00 
  80087d:	c7 44 24 08 2f 17 80 	movl   $0x80172f,0x8(%esp)
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
  8008ab:	c7 44 24 0c 04 18 80 	movl   $0x801804,0xc(%esp)
  8008b2:	00 
  8008b3:	c7 44 24 08 2f 17 80 	movl   $0x80172f,0x8(%esp)
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
  80093f:	e8 0c 0c 00 00       	call   801550 <__umoddi3>
  800944:	89 74 24 04          	mov    %esi,0x4(%esp)
  800948:	0f be 80 15 17 80 00 	movsbl 0x801715(%eax),%eax
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
  800981:	e8 ca 0b 00 00       	call   801550 <__umoddi3>
  800986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098a:	0f be 80 15 17 80 00 	movsbl 0x801715(%eax),%eax
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

00800f0b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 28             	sub    $0x28,%esp
  800f11:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f14:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f24:	8b 55 08             	mov    0x8(%ebp),%edx
  800f27:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 28                	jle    800f6d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f49:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800f50:	00 
  800f51:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  800f58:	00 
  800f59:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f60:	00 
  800f61:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  800f68:	e8 43 04 00 00       	call   8013b0 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f6d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f73:	89 ec                	mov    %ebp,%esp
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	89 1c 24             	mov    %ebx,(%esp)
  800f80:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f89:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f91:	89 cb                	mov    %ecx,%ebx
  800f93:	89 cf                	mov    %ecx,%edi
  800f95:	51                   	push   %ecx
  800f96:	52                   	push   %edx
  800f97:	53                   	push   %ebx
  800f98:	54                   	push   %esp
  800f99:	55                   	push   %ebp
  800f9a:	56                   	push   %esi
  800f9b:	57                   	push   %edi
  800f9c:	54                   	push   %esp
  800f9d:	5d                   	pop    %ebp
  800f9e:	8d 35 a6 0f 80 00    	lea    0x800fa6,%esi
  800fa4:	0f 34                	sysenter 
  800fa6:	5f                   	pop    %edi
  800fa7:	5e                   	pop    %esi
  800fa8:	5d                   	pop    %ebp
  800fa9:	5c                   	pop    %esp
  800faa:	5b                   	pop    %ebx
  800fab:	5a                   	pop    %edx
  800fac:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800fad:	8b 1c 24             	mov    (%esp),%ebx
  800fb0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb4:	89 ec                	mov    %ebp,%esp
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 28             	sub    $0x28,%esp
  800fbe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fc1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fce:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd1:	89 cb                	mov    %ecx,%ebx
  800fd3:	89 cf                	mov    %ecx,%edi
  800fd5:	51                   	push   %ecx
  800fd6:	52                   	push   %edx
  800fd7:	53                   	push   %ebx
  800fd8:	54                   	push   %esp
  800fd9:	55                   	push   %ebp
  800fda:	56                   	push   %esi
  800fdb:	57                   	push   %edi
  800fdc:	54                   	push   %esp
  800fdd:	5d                   	pop    %ebp
  800fde:	8d 35 e6 0f 80 00    	lea    0x800fe6,%esi
  800fe4:	0f 34                	sysenter 
  800fe6:	5f                   	pop    %edi
  800fe7:	5e                   	pop    %esi
  800fe8:	5d                   	pop    %ebp
  800fe9:	5c                   	pop    %esp
  800fea:	5b                   	pop    %ebx
  800feb:	5a                   	pop    %edx
  800fec:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	7e 28                	jle    801019 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  801014:	e8 97 03 00 00       	call   8013b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801019:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80101c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80101f:	89 ec                	mov    %ebp,%esp
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 08             	sub    $0x8,%esp
  801029:	89 1c 24             	mov    %ebx,(%esp)
  80102c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801030:	b8 0c 00 00 00       	mov    $0xc,%eax
  801035:	8b 7d 14             	mov    0x14(%ebp),%edi
  801038:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80103b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
  801041:	51                   	push   %ecx
  801042:	52                   	push   %edx
  801043:	53                   	push   %ebx
  801044:	54                   	push   %esp
  801045:	55                   	push   %ebp
  801046:	56                   	push   %esi
  801047:	57                   	push   %edi
  801048:	54                   	push   %esp
  801049:	5d                   	pop    %ebp
  80104a:	8d 35 52 10 80 00    	lea    0x801052,%esi
  801050:	0f 34                	sysenter 
  801052:	5f                   	pop    %edi
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	5c                   	pop    %esp
  801056:	5b                   	pop    %ebx
  801057:	5a                   	pop    %edx
  801058:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801059:	8b 1c 24             	mov    (%esp),%ebx
  80105c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801060:	89 ec                	mov    %ebp,%esp
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 28             	sub    $0x28,%esp
  80106a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80106d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801070:	bb 00 00 00 00       	mov    $0x0,%ebx
  801075:	b8 0a 00 00 00       	mov    $0xa,%eax
  80107a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107d:	8b 55 08             	mov    0x8(%ebp),%edx
  801080:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80109a:	85 c0                	test   %eax,%eax
  80109c:	7e 28                	jle    8010c6 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a2:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010b9:	00 
  8010ba:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  8010c1:	e8 ea 02 00 00       	call   8013b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cc:	89 ec                	mov    %ebp,%esp
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 28             	sub    $0x28,%esp
  8010d6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010d9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e1:	b8 09 00 00 00       	mov    $0x9,%eax
  8010e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ec:	89 df                	mov    %ebx,%edi
  8010ee:	51                   	push   %ecx
  8010ef:	52                   	push   %edx
  8010f0:	53                   	push   %ebx
  8010f1:	54                   	push   %esp
  8010f2:	55                   	push   %ebp
  8010f3:	56                   	push   %esi
  8010f4:	57                   	push   %edi
  8010f5:	54                   	push   %esp
  8010f6:	5d                   	pop    %ebp
  8010f7:	8d 35 ff 10 80 00    	lea    0x8010ff,%esi
  8010fd:	0f 34                	sysenter 
  8010ff:	5f                   	pop    %edi
  801100:	5e                   	pop    %esi
  801101:	5d                   	pop    %ebp
  801102:	5c                   	pop    %esp
  801103:	5b                   	pop    %ebx
  801104:	5a                   	pop    %edx
  801105:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801106:	85 c0                	test   %eax,%eax
  801108:	7e 28                	jle    801132 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801115:	00 
  801116:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  80111d:	00 
  80111e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801125:	00 
  801126:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  80112d:	e8 7e 02 00 00       	call   8013b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801132:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801135:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801138:	89 ec                	mov    %ebp,%esp
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 28             	sub    $0x28,%esp
  801142:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801145:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801148:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114d:	b8 07 00 00 00       	mov    $0x7,%eax
  801152:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801155:	8b 55 08             	mov    0x8(%ebp),%edx
  801158:	89 df                	mov    %ebx,%edi
  80115a:	51                   	push   %ecx
  80115b:	52                   	push   %edx
  80115c:	53                   	push   %ebx
  80115d:	54                   	push   %esp
  80115e:	55                   	push   %ebp
  80115f:	56                   	push   %esi
  801160:	57                   	push   %edi
  801161:	54                   	push   %esp
  801162:	5d                   	pop    %ebp
  801163:	8d 35 6b 11 80 00    	lea    0x80116b,%esi
  801169:	0f 34                	sysenter 
  80116b:	5f                   	pop    %edi
  80116c:	5e                   	pop    %esi
  80116d:	5d                   	pop    %ebp
  80116e:	5c                   	pop    %esp
  80116f:	5b                   	pop    %ebx
  801170:	5a                   	pop    %edx
  801171:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801172:	85 c0                	test   %eax,%eax
  801174:	7e 28                	jle    80119e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801176:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801181:	00 
  801182:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  801189:	00 
  80118a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801191:	00 
  801192:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  801199:	e8 12 02 00 00       	call   8013b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80119e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011a4:	89 ec                	mov    %ebp,%esp
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	83 ec 28             	sub    $0x28,%esp
  8011ae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011b1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011b4:	8b 7d 18             	mov    0x18(%ebp),%edi
  8011b7:	0b 7d 14             	or     0x14(%ebp),%edi
  8011ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8011bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c8:	51                   	push   %ecx
  8011c9:	52                   	push   %edx
  8011ca:	53                   	push   %ebx
  8011cb:	54                   	push   %esp
  8011cc:	55                   	push   %ebp
  8011cd:	56                   	push   %esi
  8011ce:	57                   	push   %edi
  8011cf:	54                   	push   %esp
  8011d0:	5d                   	pop    %ebp
  8011d1:	8d 35 d9 11 80 00    	lea    0x8011d9,%esi
  8011d7:	0f 34                	sysenter 
  8011d9:	5f                   	pop    %edi
  8011da:	5e                   	pop    %esi
  8011db:	5d                   	pop    %ebp
  8011dc:	5c                   	pop    %esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5a                   	pop    %edx
  8011df:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	7e 28                	jle    80120c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011ef:	00 
  8011f0:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  8011f7:	00 
  8011f8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011ff:	00 
  801200:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  801207:	e8 a4 01 00 00       	call   8013b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80120c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80120f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801212:	89 ec                	mov    %ebp,%esp
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 28             	sub    $0x28,%esp
  80121c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80121f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801222:	bf 00 00 00 00       	mov    $0x0,%edi
  801227:	b8 05 00 00 00       	mov    $0x5,%eax
  80122c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	8b 55 08             	mov    0x8(%ebp),%edx
  801235:	51                   	push   %ecx
  801236:	52                   	push   %edx
  801237:	53                   	push   %ebx
  801238:	54                   	push   %esp
  801239:	55                   	push   %ebp
  80123a:	56                   	push   %esi
  80123b:	57                   	push   %edi
  80123c:	54                   	push   %esp
  80123d:	5d                   	pop    %ebp
  80123e:	8d 35 46 12 80 00    	lea    0x801246,%esi
  801244:	0f 34                	sysenter 
  801246:	5f                   	pop    %edi
  801247:	5e                   	pop    %esi
  801248:	5d                   	pop    %ebp
  801249:	5c                   	pop    %esp
  80124a:	5b                   	pop    %ebx
  80124b:	5a                   	pop    %edx
  80124c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80124d:	85 c0                	test   %eax,%eax
  80124f:	7e 28                	jle    801279 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801251:	89 44 24 10          	mov    %eax,0x10(%esp)
  801255:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80125c:	00 
  80125d:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  801264:	00 
  801265:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80126c:	00 
  80126d:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  801274:	e8 37 01 00 00       	call   8013b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801279:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80127c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80127f:	89 ec                	mov    %ebp,%esp
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	89 1c 24             	mov    %ebx,(%esp)
  80128c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801290:	ba 00 00 00 00       	mov    $0x0,%edx
  801295:	b8 0b 00 00 00       	mov    $0xb,%eax
  80129a:	89 d1                	mov    %edx,%ecx
  80129c:	89 d3                	mov    %edx,%ebx
  80129e:	89 d7                	mov    %edx,%edi
  8012a0:	51                   	push   %ecx
  8012a1:	52                   	push   %edx
  8012a2:	53                   	push   %ebx
  8012a3:	54                   	push   %esp
  8012a4:	55                   	push   %ebp
  8012a5:	56                   	push   %esi
  8012a6:	57                   	push   %edi
  8012a7:	54                   	push   %esp
  8012a8:	5d                   	pop    %ebp
  8012a9:	8d 35 b1 12 80 00    	lea    0x8012b1,%esi
  8012af:	0f 34                	sysenter 
  8012b1:	5f                   	pop    %edi
  8012b2:	5e                   	pop    %esi
  8012b3:	5d                   	pop    %ebp
  8012b4:	5c                   	pop    %esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5a                   	pop    %edx
  8012b7:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012b8:	8b 1c 24             	mov    (%esp),%ebx
  8012bb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012bf:	89 ec                	mov    %ebp,%esp
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	89 1c 24             	mov    %ebx,(%esp)
  8012cc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d5:	b8 04 00 00 00       	mov    $0x4,%eax
  8012da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e0:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8012fa:	8b 1c 24             	mov    (%esp),%ebx
  8012fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801301:	89 ec                	mov    %ebp,%esp
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	89 1c 24             	mov    %ebx,(%esp)
  80130e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801312:	ba 00 00 00 00       	mov    $0x0,%edx
  801317:	b8 02 00 00 00       	mov    $0x2,%eax
  80131c:	89 d1                	mov    %edx,%ecx
  80131e:	89 d3                	mov    %edx,%ebx
  801320:	89 d7                	mov    %edx,%edi
  801322:	51                   	push   %ecx
  801323:	52                   	push   %edx
  801324:	53                   	push   %ebx
  801325:	54                   	push   %esp
  801326:	55                   	push   %ebp
  801327:	56                   	push   %esi
  801328:	57                   	push   %edi
  801329:	54                   	push   %esp
  80132a:	5d                   	pop    %ebp
  80132b:	8d 35 33 13 80 00    	lea    0x801333,%esi
  801331:	0f 34                	sysenter 
  801333:	5f                   	pop    %edi
  801334:	5e                   	pop    %esi
  801335:	5d                   	pop    %ebp
  801336:	5c                   	pop    %esp
  801337:	5b                   	pop    %ebx
  801338:	5a                   	pop    %edx
  801339:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80133a:	8b 1c 24             	mov    (%esp),%ebx
  80133d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801341:	89 ec                	mov    %ebp,%esp
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 28             	sub    $0x28,%esp
  80134b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80134e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801351:	b9 00 00 00 00       	mov    $0x0,%ecx
  801356:	b8 03 00 00 00       	mov    $0x3,%eax
  80135b:	8b 55 08             	mov    0x8(%ebp),%edx
  80135e:	89 cb                	mov    %ecx,%ebx
  801360:	89 cf                	mov    %ecx,%edi
  801362:	51                   	push   %ecx
  801363:	52                   	push   %edx
  801364:	53                   	push   %ebx
  801365:	54                   	push   %esp
  801366:	55                   	push   %ebp
  801367:	56                   	push   %esi
  801368:	57                   	push   %edi
  801369:	54                   	push   %esp
  80136a:	5d                   	pop    %ebp
  80136b:	8d 35 73 13 80 00    	lea    0x801373,%esi
  801371:	0f 34                	sysenter 
  801373:	5f                   	pop    %edi
  801374:	5e                   	pop    %esi
  801375:	5d                   	pop    %ebp
  801376:	5c                   	pop    %esp
  801377:	5b                   	pop    %ebx
  801378:	5a                   	pop    %edx
  801379:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80137a:	85 c0                	test   %eax,%eax
  80137c:	7e 28                	jle    8013a6 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80137e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801382:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801389:	00 
  80138a:	c7 44 24 08 e4 19 80 	movl   $0x8019e4,0x8(%esp)
  801391:	00 
  801392:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801399:	00 
  80139a:	c7 04 24 01 1a 80 00 	movl   $0x801a01,(%esp)
  8013a1:	e8 0a 00 00 00       	call   8013b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8013a6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013a9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ac:	89 ec                	mov    %ebp,%esp
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	56                   	push   %esi
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8013b8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8013bb:	a1 08 20 80 00       	mov    0x802008,%eax
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	74 10                	je     8013d4 <_panic+0x24>
		cprintf("%s: ", argv0);
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	c7 04 24 0f 1a 80 00 	movl   $0x801a0f,(%esp)
  8013cf:	e8 95 ed ff ff       	call   800169 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013d4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013da:	e8 26 ff ff ff       	call   801305 <sys_getenvid>
  8013df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f5:	c7 04 24 18 1a 80 00 	movl   $0x801a18,(%esp)
  8013fc:	e8 68 ed ff ff       	call   800169 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801401:	89 74 24 04          	mov    %esi,0x4(%esp)
  801405:	8b 45 10             	mov    0x10(%ebp),%eax
  801408:	89 04 24             	mov    %eax,(%esp)
  80140b:	e8 f8 ec ff ff       	call   800108 <vcprintf>
	cprintf("\n");
  801410:	c7 04 24 14 1a 80 00 	movl   $0x801a14,(%esp)
  801417:	e8 4d ed ff ff       	call   800169 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80141c:	cc                   	int3   
  80141d:	eb fd                	jmp    80141c <_panic+0x6c>
	...

00801420 <__udivdi3>:
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	57                   	push   %edi
  801424:	56                   	push   %esi
  801425:	83 ec 10             	sub    $0x10,%esp
  801428:	8b 45 14             	mov    0x14(%ebp),%eax
  80142b:	8b 55 08             	mov    0x8(%ebp),%edx
  80142e:	8b 75 10             	mov    0x10(%ebp),%esi
  801431:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801434:	85 c0                	test   %eax,%eax
  801436:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801439:	75 35                	jne    801470 <__udivdi3+0x50>
  80143b:	39 fe                	cmp    %edi,%esi
  80143d:	77 61                	ja     8014a0 <__udivdi3+0x80>
  80143f:	85 f6                	test   %esi,%esi
  801441:	75 0b                	jne    80144e <__udivdi3+0x2e>
  801443:	b8 01 00 00 00       	mov    $0x1,%eax
  801448:	31 d2                	xor    %edx,%edx
  80144a:	f7 f6                	div    %esi
  80144c:	89 c6                	mov    %eax,%esi
  80144e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801451:	31 d2                	xor    %edx,%edx
  801453:	89 f8                	mov    %edi,%eax
  801455:	f7 f6                	div    %esi
  801457:	89 c7                	mov    %eax,%edi
  801459:	89 c8                	mov    %ecx,%eax
  80145b:	f7 f6                	div    %esi
  80145d:	89 c1                	mov    %eax,%ecx
  80145f:	89 fa                	mov    %edi,%edx
  801461:	89 c8                	mov    %ecx,%eax
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	5e                   	pop    %esi
  801467:	5f                   	pop    %edi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    
  80146a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801470:	39 f8                	cmp    %edi,%eax
  801472:	77 1c                	ja     801490 <__udivdi3+0x70>
  801474:	0f bd d0             	bsr    %eax,%edx
  801477:	83 f2 1f             	xor    $0x1f,%edx
  80147a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80147d:	75 39                	jne    8014b8 <__udivdi3+0x98>
  80147f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801482:	0f 86 a0 00 00 00    	jbe    801528 <__udivdi3+0x108>
  801488:	39 f8                	cmp    %edi,%eax
  80148a:	0f 82 98 00 00 00    	jb     801528 <__udivdi3+0x108>
  801490:	31 ff                	xor    %edi,%edi
  801492:	31 c9                	xor    %ecx,%ecx
  801494:	89 c8                	mov    %ecx,%eax
  801496:	89 fa                	mov    %edi,%edx
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    
  80149f:	90                   	nop
  8014a0:	89 d1                	mov    %edx,%ecx
  8014a2:	89 fa                	mov    %edi,%edx
  8014a4:	89 c8                	mov    %ecx,%eax
  8014a6:	31 ff                	xor    %edi,%edi
  8014a8:	f7 f6                	div    %esi
  8014aa:	89 c1                	mov    %eax,%ecx
  8014ac:	89 fa                	mov    %edi,%edx
  8014ae:	89 c8                	mov    %ecx,%eax
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	5e                   	pop    %esi
  8014b4:	5f                   	pop    %edi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    
  8014b7:	90                   	nop
  8014b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014bc:	89 f2                	mov    %esi,%edx
  8014be:	d3 e0                	shl    %cl,%eax
  8014c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8014c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8014c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8014cb:	89 c1                	mov    %eax,%ecx
  8014cd:	d3 ea                	shr    %cl,%edx
  8014cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014d3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8014d6:	d3 e6                	shl    %cl,%esi
  8014d8:	89 c1                	mov    %eax,%ecx
  8014da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8014dd:	89 fe                	mov    %edi,%esi
  8014df:	d3 ee                	shr    %cl,%esi
  8014e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014eb:	d3 e7                	shl    %cl,%edi
  8014ed:	89 c1                	mov    %eax,%ecx
  8014ef:	d3 ea                	shr    %cl,%edx
  8014f1:	09 d7                	or     %edx,%edi
  8014f3:	89 f2                	mov    %esi,%edx
  8014f5:	89 f8                	mov    %edi,%eax
  8014f7:	f7 75 ec             	divl   -0x14(%ebp)
  8014fa:	89 d6                	mov    %edx,%esi
  8014fc:	89 c7                	mov    %eax,%edi
  8014fe:	f7 65 e8             	mull   -0x18(%ebp)
  801501:	39 d6                	cmp    %edx,%esi
  801503:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801506:	72 30                	jb     801538 <__udivdi3+0x118>
  801508:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80150b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80150f:	d3 e2                	shl    %cl,%edx
  801511:	39 c2                	cmp    %eax,%edx
  801513:	73 05                	jae    80151a <__udivdi3+0xfa>
  801515:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801518:	74 1e                	je     801538 <__udivdi3+0x118>
  80151a:	89 f9                	mov    %edi,%ecx
  80151c:	31 ff                	xor    %edi,%edi
  80151e:	e9 71 ff ff ff       	jmp    801494 <__udivdi3+0x74>
  801523:	90                   	nop
  801524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801528:	31 ff                	xor    %edi,%edi
  80152a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80152f:	e9 60 ff ff ff       	jmp    801494 <__udivdi3+0x74>
  801534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801538:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80153b:	31 ff                	xor    %edi,%edi
  80153d:	89 c8                	mov    %ecx,%eax
  80153f:	89 fa                	mov    %edi,%edx
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	5e                   	pop    %esi
  801545:	5f                   	pop    %edi
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    
	...

00801550 <__umoddi3>:
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	57                   	push   %edi
  801554:	56                   	push   %esi
  801555:	83 ec 20             	sub    $0x20,%esp
  801558:	8b 55 14             	mov    0x14(%ebp),%edx
  80155b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801561:	8b 75 0c             	mov    0xc(%ebp),%esi
  801564:	85 d2                	test   %edx,%edx
  801566:	89 c8                	mov    %ecx,%eax
  801568:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80156b:	75 13                	jne    801580 <__umoddi3+0x30>
  80156d:	39 f7                	cmp    %esi,%edi
  80156f:	76 3f                	jbe    8015b0 <__umoddi3+0x60>
  801571:	89 f2                	mov    %esi,%edx
  801573:	f7 f7                	div    %edi
  801575:	89 d0                	mov    %edx,%eax
  801577:	31 d2                	xor    %edx,%edx
  801579:	83 c4 20             	add    $0x20,%esp
  80157c:	5e                   	pop    %esi
  80157d:	5f                   	pop    %edi
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    
  801580:	39 f2                	cmp    %esi,%edx
  801582:	77 4c                	ja     8015d0 <__umoddi3+0x80>
  801584:	0f bd ca             	bsr    %edx,%ecx
  801587:	83 f1 1f             	xor    $0x1f,%ecx
  80158a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80158d:	75 51                	jne    8015e0 <__umoddi3+0x90>
  80158f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801592:	0f 87 e0 00 00 00    	ja     801678 <__umoddi3+0x128>
  801598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159b:	29 f8                	sub    %edi,%eax
  80159d:	19 d6                	sbb    %edx,%esi
  80159f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	89 f2                	mov    %esi,%edx
  8015a7:	83 c4 20             	add    $0x20,%esp
  8015aa:	5e                   	pop    %esi
  8015ab:	5f                   	pop    %edi
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    
  8015ae:	66 90                	xchg   %ax,%ax
  8015b0:	85 ff                	test   %edi,%edi
  8015b2:	75 0b                	jne    8015bf <__umoddi3+0x6f>
  8015b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b9:	31 d2                	xor    %edx,%edx
  8015bb:	f7 f7                	div    %edi
  8015bd:	89 c7                	mov    %eax,%edi
  8015bf:	89 f0                	mov    %esi,%eax
  8015c1:	31 d2                	xor    %edx,%edx
  8015c3:	f7 f7                	div    %edi
  8015c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c8:	f7 f7                	div    %edi
  8015ca:	eb a9                	jmp    801575 <__umoddi3+0x25>
  8015cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015d0:	89 c8                	mov    %ecx,%eax
  8015d2:	89 f2                	mov    %esi,%edx
  8015d4:	83 c4 20             	add    $0x20,%esp
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    
  8015db:	90                   	nop
  8015dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015e4:	d3 e2                	shl    %cl,%edx
  8015e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8015ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8015f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015f8:	89 fa                	mov    %edi,%edx
  8015fa:	d3 ea                	shr    %cl,%edx
  8015fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801600:	0b 55 f4             	or     -0xc(%ebp),%edx
  801603:	d3 e7                	shl    %cl,%edi
  801605:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801609:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80160c:	89 f2                	mov    %esi,%edx
  80160e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801611:	89 c7                	mov    %eax,%edi
  801613:	d3 ea                	shr    %cl,%edx
  801615:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801619:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	d3 e6                	shl    %cl,%esi
  801620:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801624:	d3 ea                	shr    %cl,%edx
  801626:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80162a:	09 d6                	or     %edx,%esi
  80162c:	89 f0                	mov    %esi,%eax
  80162e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801631:	d3 e7                	shl    %cl,%edi
  801633:	89 f2                	mov    %esi,%edx
  801635:	f7 75 f4             	divl   -0xc(%ebp)
  801638:	89 d6                	mov    %edx,%esi
  80163a:	f7 65 e8             	mull   -0x18(%ebp)
  80163d:	39 d6                	cmp    %edx,%esi
  80163f:	72 2b                	jb     80166c <__umoddi3+0x11c>
  801641:	39 c7                	cmp    %eax,%edi
  801643:	72 23                	jb     801668 <__umoddi3+0x118>
  801645:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801649:	29 c7                	sub    %eax,%edi
  80164b:	19 d6                	sbb    %edx,%esi
  80164d:	89 f0                	mov    %esi,%eax
  80164f:	89 f2                	mov    %esi,%edx
  801651:	d3 ef                	shr    %cl,%edi
  801653:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801657:	d3 e0                	shl    %cl,%eax
  801659:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80165d:	09 f8                	or     %edi,%eax
  80165f:	d3 ea                	shr    %cl,%edx
  801661:	83 c4 20             	add    $0x20,%esp
  801664:	5e                   	pop    %esi
  801665:	5f                   	pop    %edi
  801666:	5d                   	pop    %ebp
  801667:	c3                   	ret    
  801668:	39 d6                	cmp    %edx,%esi
  80166a:	75 d9                	jne    801645 <__umoddi3+0xf5>
  80166c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80166f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801672:	eb d1                	jmp    801645 <__umoddi3+0xf5>
  801674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801678:	39 f2                	cmp    %esi,%edx
  80167a:	0f 82 18 ff ff ff    	jb     801598 <__umoddi3+0x48>
  801680:	e9 1d ff ff ff       	jmp    8015a2 <__umoddi3+0x52>
