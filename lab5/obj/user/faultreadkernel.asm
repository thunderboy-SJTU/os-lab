
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 21 80 00 	movl   $0x802100,(%esp)
  80004a:	e8 d6 00 00 00       	call   800125 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800066:	e8 07 13 00 00       	call   801372 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	89 c2                	mov    %eax,%edx
  800072:	c1 e2 07             	shl    $0x7,%edx
  800075:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80007c:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800081:	85 f6                	test   %esi,%esi
  800083:	7e 07                	jle    80008c <libmain+0x38>
		binaryname = argv[0];
  800085:	8b 03                	mov    (%ebx),%eax
  800087:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	89 34 24             	mov    %esi,(%esp)
  800093:	e8 9c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800098:	e8 0b 00 00 00       	call   8000a8 <exit>
}
  80009d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a3:	89 ec                	mov    %ebp,%esp
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ae:	e8 48 18 00 00       	call   8018fb <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 f3 12 00 00       	call   8013b2 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000d4:	00 00 00 
	b.cnt = 0;
  8000d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f9:	c7 04 24 3f 01 80 00 	movl   $0x80013f,(%esp)
  800100:	e8 d7 01 00 00       	call   8002dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800105:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80010b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800115:	89 04 24             	mov    %eax,(%esp)
  800118:	e8 6f 0d 00 00       	call   800e8c <sys_cputs>

	return b.cnt;
}
  80011d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80012b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 04 24             	mov    %eax,(%esp)
  800138:	e8 87 ff ff ff       	call   8000c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	53                   	push   %ebx
  800143:	83 ec 14             	sub    $0x14,%esp
  800146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	8b 55 08             	mov    0x8(%ebp),%edx
  80014e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800152:	83 c0 01             	add    $0x1,%eax
  800155:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800157:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015c:	75 19                	jne    800177 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80015e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800165:	00 
  800166:	8d 43 08             	lea    0x8(%ebx),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 1b 0d 00 00       	call   800e8c <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800177:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017b:	83 c4 14             	add    $0x14,%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
	...

00800190 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 07                	jb     8001c6 <printnum_v2+0x36>
  8001bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c2:	39 d0                	cmp    %edx,%eax
  8001c4:	77 5f                	ja     800225 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8001c6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001ca:	83 eb 01             	sub    $0x1,%ebx
  8001cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001d9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001dd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001e0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001e3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f1:	00 
  8001f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ff:	e8 7c 1c 00 00       	call   801e80 <__udivdi3>
  800204:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800207:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80020a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	89 54 24 04          	mov    %edx,0x4(%esp)
  800219:	89 f2                	mov    %esi,%edx
  80021b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021e:	e8 6d ff ff ff       	call   800190 <printnum_v2>
  800223:	eb 1e                	jmp    800243 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800225:	83 ff 2d             	cmp    $0x2d,%edi
  800228:	74 19                	je     800243 <printnum_v2+0xb3>
		while (--width > 0)
  80022a:	83 eb 01             	sub    $0x1,%ebx
  80022d:	85 db                	test   %ebx,%ebx
  80022f:	90                   	nop
  800230:	7e 11                	jle    800243 <printnum_v2+0xb3>
			putch(padc, putdat);
  800232:	89 74 24 04          	mov    %esi,0x4(%esp)
  800236:	89 3c 24             	mov    %edi,(%esp)
  800239:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80023c:	83 eb 01             	sub    $0x1,%ebx
  80023f:	85 db                	test   %ebx,%ebx
  800241:	7f ef                	jg     800232 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800243:	89 74 24 04          	mov    %esi,0x4(%esp)
  800247:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800252:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800259:	00 
  80025a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025d:	89 14 24             	mov    %edx,(%esp)
  800260:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800263:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800267:	e8 44 1d 00 00       	call   801fb0 <__umoddi3>
  80026c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800270:	0f be 80 31 21 80 00 	movsbl 0x802131(%eax),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027d:	83 c4 4c             	add    $0x4c,%esp
  800280:	5b                   	pop    %ebx
  800281:	5e                   	pop    %esi
  800282:	5f                   	pop    %edi
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800288:	83 fa 01             	cmp    $0x1,%edx
  80028b:	7e 0e                	jle    80029b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	8b 52 04             	mov    0x4(%edx),%edx
  800299:	eb 22                	jmp    8002bd <getuint+0x38>
	else if (lflag)
  80029b:	85 d2                	test   %edx,%edx
  80029d:	74 10                	je     8002af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ad:	eb 0e                	jmp    8002bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ce:	73 0a                	jae    8002da <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d3:	88 0a                	mov    %cl,(%edx)
  8002d5:	83 c2 01             	add    $0x1,%edx
  8002d8:	89 10                	mov    %edx,(%eax)
}
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 6c             	sub    $0x6c,%esp
  8002e5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002e8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002ef:	eb 1a                	jmp    80030b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	0f 84 66 06 00 00    	je     80095f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8002f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	ff 55 08             	call   *0x8(%ebp)
  800306:	eb 03                	jmp    80030b <vprintfmt+0x2f>
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030b:	0f b6 07             	movzbl (%edi),%eax
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	83 f8 25             	cmp    $0x25,%eax
  800314:	75 db                	jne    8002f1 <vprintfmt+0x15>
  800316:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80031a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800326:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80032b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800332:	be 00 00 00 00       	mov    $0x0,%esi
  800337:	eb 06                	jmp    80033f <vprintfmt+0x63>
  800339:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80033d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	0f b6 17             	movzbl (%edi),%edx
  800342:	0f b6 c2             	movzbl %dl,%eax
  800345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	83 ea 23             	sub    $0x23,%edx
  80034e:	80 fa 55             	cmp    $0x55,%dl
  800351:	0f 87 60 05 00 00    	ja     8008b7 <vprintfmt+0x5db>
  800357:	0f b6 d2             	movzbl %dl,%edx
  80035a:	ff 24 95 20 23 80 00 	jmp    *0x802320(,%edx,4)
  800361:	b9 01 00 00 00       	mov    $0x1,%ecx
  800366:	eb d5                	jmp    80033d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800368:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80036b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80036e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800371:	8d 7a d0             	lea    -0x30(%edx),%edi
  800374:	83 ff 09             	cmp    $0x9,%edi
  800377:	76 08                	jbe    800381 <vprintfmt+0xa5>
  800379:	eb 40                	jmp    8003bb <vprintfmt+0xdf>
  80037b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80037f:	eb bc                	jmp    80033d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800381:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800384:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800387:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80038b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80038e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800391:	83 ff 09             	cmp    $0x9,%edi
  800394:	76 eb                	jbe    800381 <vprintfmt+0xa5>
  800396:	eb 23                	jmp    8003bb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800398:	8b 55 14             	mov    0x14(%ebp),%edx
  80039b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80039e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003a1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8003a3:	eb 16                	jmp    8003bb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8003a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003a8:	c1 fa 1f             	sar    $0x1f,%edx
  8003ab:	f7 d2                	not    %edx
  8003ad:	21 55 d8             	and    %edx,-0x28(%ebp)
  8003b0:	eb 8b                	jmp    80033d <vprintfmt+0x61>
  8003b2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003b9:	eb 82                	jmp    80033d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8003bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003bf:	0f 89 78 ff ff ff    	jns    80033d <vprintfmt+0x61>
  8003c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8003c8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8003cb:	e9 6d ff ff ff       	jmp    80033d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8003d3:	e9 65 ff ff ff       	jmp    80033d <vprintfmt+0x61>
  8003d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 50 04             	lea    0x4(%eax),%edx
  8003e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	89 04 24             	mov    %eax,(%esp)
  8003f0:	ff 55 08             	call   *0x8(%ebp)
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8003f6:	e9 10 ff ff ff       	jmp    80030b <vprintfmt+0x2f>
  8003fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 50 04             	lea    0x4(%eax),%edx
  800404:	89 55 14             	mov    %edx,0x14(%ebp)
  800407:	8b 00                	mov    (%eax),%eax
  800409:	89 c2                	mov    %eax,%edx
  80040b:	c1 fa 1f             	sar    $0x1f,%edx
  80040e:	31 d0                	xor    %edx,%eax
  800410:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800412:	83 f8 0f             	cmp    $0xf,%eax
  800415:	7f 0b                	jg     800422 <vprintfmt+0x146>
  800417:	8b 14 85 80 24 80 00 	mov    0x802480(,%eax,4),%edx
  80041e:	85 d2                	test   %edx,%edx
  800420:	75 26                	jne    800448 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800422:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800426:	c7 44 24 08 42 21 80 	movl   $0x802142,0x8(%esp)
  80042d:	00 
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800435:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800438:	89 1c 24             	mov    %ebx,(%esp)
  80043b:	e8 a7 05 00 00       	call   8009e7 <printfmt>
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	e9 c3 fe ff ff       	jmp    80030b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800448:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044c:	c7 44 24 08 4b 21 80 	movl   $0x80214b,0x8(%esp)
  800453:	00 
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045b:	8b 55 08             	mov    0x8(%ebp),%edx
  80045e:	89 14 24             	mov    %edx,(%esp)
  800461:	e8 81 05 00 00       	call   8009e7 <printfmt>
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800469:	e9 9d fe ff ff       	jmp    80030b <vprintfmt+0x2f>
  80046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800471:	89 c7                	mov    %eax,%edi
  800473:	89 d9                	mov    %ebx,%ecx
  800475:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800478:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 30                	mov    (%eax),%esi
  800486:	85 f6                	test   %esi,%esi
  800488:	75 05                	jne    80048f <vprintfmt+0x1b3>
  80048a:	be 4e 21 80 00       	mov    $0x80214e,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80048f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800493:	7e 06                	jle    80049b <vprintfmt+0x1bf>
  800495:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800499:	75 10                	jne    8004ab <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049b:	0f be 06             	movsbl (%esi),%eax
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	0f 85 a2 00 00 00    	jne    800548 <vprintfmt+0x26c>
  8004a6:	e9 92 00 00 00       	jmp    80053d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004af:	89 34 24             	mov    %esi,(%esp)
  8004b2:	e8 74 05 00 00       	call   800a2b <strnlen>
  8004b7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004ba:	29 c2                	sub    %eax,%edx
  8004bc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	7e d8                	jle    80049b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8004c3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8004c7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004ca:	89 d3                	mov    %edx,%ebx
  8004cc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004cf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8004d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004d5:	89 ce                	mov    %ecx,%esi
  8004d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004db:	89 34 24             	mov    %esi,(%esp)
  8004de:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 eb 01             	sub    $0x1,%ebx
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7f ef                	jg     8004d7 <vprintfmt+0x1fb>
  8004e8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ee:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8004f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004f8:	eb a1                	jmp    80049b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004fe:	74 1b                	je     80051b <vprintfmt+0x23f>
  800500:	8d 50 e0             	lea    -0x20(%eax),%edx
  800503:	83 fa 5e             	cmp    $0x5e,%edx
  800506:	76 13                	jbe    80051b <vprintfmt+0x23f>
					putch('?', putdat);
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800516:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	eb 0d                	jmp    800528 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80051b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800528:	83 ef 01             	sub    $0x1,%edi
  80052b:	0f be 06             	movsbl (%esi),%eax
  80052e:	85 c0                	test   %eax,%eax
  800530:	74 05                	je     800537 <vprintfmt+0x25b>
  800532:	83 c6 01             	add    $0x1,%esi
  800535:	eb 1a                	jmp    800551 <vprintfmt+0x275>
  800537:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80053a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800541:	7f 1f                	jg     800562 <vprintfmt+0x286>
  800543:	e9 c0 fd ff ff       	jmp    800308 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 c6 01             	add    $0x1,%esi
  80054b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80054e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800551:	85 db                	test   %ebx,%ebx
  800553:	78 a5                	js     8004fa <vprintfmt+0x21e>
  800555:	83 eb 01             	sub    $0x1,%ebx
  800558:	79 a0                	jns    8004fa <vprintfmt+0x21e>
  80055a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80055d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800560:	eb db                	jmp    80053d <vprintfmt+0x261>
  800562:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800565:	8b 75 0c             	mov    0xc(%ebp),%esi
  800568:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80056b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800572:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800579:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057b:	83 eb 01             	sub    $0x1,%ebx
  80057e:	85 db                	test   %ebx,%ebx
  800580:	7f ec                	jg     80056e <vprintfmt+0x292>
  800582:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800585:	e9 81 fd ff ff       	jmp    80030b <vprintfmt+0x2f>
  80058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058d:	83 fe 01             	cmp    $0x1,%esi
  800590:	7e 10                	jle    8005a2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 08             	lea    0x8(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 18                	mov    (%eax),%ebx
  80059d:	8b 70 04             	mov    0x4(%eax),%esi
  8005a0:	eb 26                	jmp    8005c8 <vprintfmt+0x2ec>
	else if (lflag)
  8005a2:	85 f6                	test   %esi,%esi
  8005a4:	74 12                	je     8005b8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 18                	mov    (%eax),%ebx
  8005b1:	89 de                	mov    %ebx,%esi
  8005b3:	c1 fe 1f             	sar    $0x1f,%esi
  8005b6:	eb 10                	jmp    8005c8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 18                	mov    (%eax),%ebx
  8005c3:	89 de                	mov    %ebx,%esi
  8005c5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	75 1e                	jne    8005eb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8005cd:	85 f6                	test   %esi,%esi
  8005cf:	78 1a                	js     8005eb <vprintfmt+0x30f>
  8005d1:	85 f6                	test   %esi,%esi
  8005d3:	7f 05                	jg     8005da <vprintfmt+0x2fe>
  8005d5:	83 fb 00             	cmp    $0x0,%ebx
  8005d8:	76 11                	jbe    8005eb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8005da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8005e8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8005eb:	85 f6                	test   %esi,%esi
  8005ed:	78 13                	js     800602 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ef:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8005f2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8005f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fd:	e9 da 00 00 00       	jmp    8006dc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800602:	8b 45 0c             	mov    0xc(%ebp),%eax
  800605:	89 44 24 04          	mov    %eax,0x4(%esp)
  800609:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800610:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800613:	89 da                	mov    %ebx,%edx
  800615:	89 f1                	mov    %esi,%ecx
  800617:	f7 da                	neg    %edx
  800619:	83 d1 00             	adc    $0x0,%ecx
  80061c:	f7 d9                	neg    %ecx
  80061e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800621:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062c:	e9 ab 00 00 00       	jmp    8006dc <vprintfmt+0x400>
  800631:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800634:	89 f2                	mov    %esi,%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 47 fc ff ff       	call   800285 <getuint>
  80063e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800641:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80064c:	e9 8b 00 00 00       	jmp    8006dc <vprintfmt+0x400>
  800651:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800657:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800662:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800665:	89 f2                	mov    %esi,%edx
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
  80066a:	e8 16 fc ff ff       	call   800285 <getuint>
  80066f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800672:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800678:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80067d:	eb 5d                	jmp    8006dc <vprintfmt+0x400>
  80067f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800685:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800689:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800690:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800693:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800697:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 04             	lea    0x4(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006b4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006bf:	eb 1b                	jmp    8006dc <vprintfmt+0x400>
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c4:	89 f2                	mov    %esi,%edx
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 b7 fb ff ff       	call   800285 <getuint>
  8006ce:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006d1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006e0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006e6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8006ea:	77 09                	ja     8006f5 <vprintfmt+0x419>
  8006ec:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8006ef:	0f 82 ac 00 00 00    	jb     8007a1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8006f5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006f8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8006fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ff:	83 ea 01             	sub    $0x1,%edx
  800702:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800706:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80070e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800712:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800715:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800718:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80071b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80071f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800726:	00 
  800727:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80072a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80072d:	89 0c 24             	mov    %ecx,(%esp)
  800730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800734:	e8 47 17 00 00       	call   801e80 <__udivdi3>
  800739:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80073c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80073f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800743:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800747:	89 04 24             	mov    %eax,(%esp)
  80074a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	e8 37 fa ff ff       	call   800190 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800759:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800760:	8b 74 24 04          	mov    0x4(%esp),%esi
  800764:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800772:	00 
  800773:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800776:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800779:	89 14 24             	mov    %edx,(%esp)
  80077c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800780:	e8 2b 18 00 00       	call   801fb0 <__umoddi3>
  800785:	89 74 24 04          	mov    %esi,0x4(%esp)
  800789:	0f be 80 31 21 80 00 	movsbl 0x802131(%eax),%eax
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800796:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80079a:	74 54                	je     8007f0 <vprintfmt+0x514>
  80079c:	e9 67 fb ff ff       	jmp    800308 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007a1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007a5:	8d 76 00             	lea    0x0(%esi),%esi
  8007a8:	0f 84 2a 01 00 00    	je     8008d8 <vprintfmt+0x5fc>
		while (--width > 0)
  8007ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007b1:	83 ef 01             	sub    $0x1,%edi
  8007b4:	85 ff                	test   %edi,%edi
  8007b6:	0f 8e 5e 01 00 00    	jle    80091a <vprintfmt+0x63e>
  8007bc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007bf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007c2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8007c5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007c8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007cb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8007ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d2:	89 1c 24             	mov    %ebx,(%esp)
  8007d5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	85 ff                	test   %edi,%edi
  8007dd:	7f ef                	jg     8007ce <vprintfmt+0x4f2>
  8007df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007e5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007e8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007eb:	e9 2a 01 00 00       	jmp    80091a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8007f0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007f3:	83 eb 01             	sub    $0x1,%ebx
  8007f6:	85 db                	test   %ebx,%ebx
  8007f8:	0f 8e 0a fb ff ff    	jle    800308 <vprintfmt+0x2c>
  8007fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800801:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800804:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800807:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800812:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800814:	83 eb 01             	sub    $0x1,%ebx
  800817:	85 db                	test   %ebx,%ebx
  800819:	7f ec                	jg     800807 <vprintfmt+0x52b>
  80081b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80081e:	e9 e8 fa ff ff       	jmp    80030b <vprintfmt+0x2f>
  800823:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8d 50 04             	lea    0x4(%eax),%edx
  80082c:	89 55 14             	mov    %edx,0x14(%ebp)
  80082f:	8b 00                	mov    (%eax),%eax
  800831:	85 c0                	test   %eax,%eax
  800833:	75 2a                	jne    80085f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800835:	c7 44 24 0c 68 22 80 	movl   $0x802268,0xc(%esp)
  80083c:	00 
  80083d:	c7 44 24 08 4b 21 80 	movl   $0x80214b,0x8(%esp)
  800844:	00 
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
  800848:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084f:	89 0c 24             	mov    %ecx,(%esp)
  800852:	e8 90 01 00 00       	call   8009e7 <printfmt>
  800857:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80085a:	e9 ac fa ff ff       	jmp    80030b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80085f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800862:	8b 13                	mov    (%ebx),%edx
  800864:	83 fa 7f             	cmp    $0x7f,%edx
  800867:	7e 29                	jle    800892 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800869:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80086b:	c7 44 24 0c a0 22 80 	movl   $0x8022a0,0xc(%esp)
  800872:	00 
  800873:	c7 44 24 08 4b 21 80 	movl   $0x80214b,0x8(%esp)
  80087a:	00 
  80087b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 5d 01 00 00       	call   8009e7 <printfmt>
  80088a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088d:	e9 79 fa ff ff       	jmp    80030b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800892:	88 10                	mov    %dl,(%eax)
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800897:	e9 6f fa ff ff       	jmp    80030b <vprintfmt+0x2f>
  80089c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80089f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a9:	89 14 24             	mov    %edx,(%esp)
  8008ac:	ff 55 08             	call   *0x8(%ebp)
  8008af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8008b2:	e9 54 fa ff ff       	jmp    80030b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8008cb:	80 38 25             	cmpb   $0x25,(%eax)
  8008ce:	0f 84 37 fa ff ff    	je     80030b <vprintfmt+0x2f>
  8008d4:	89 c7                	mov    %eax,%edi
  8008d6:	eb f0                	jmp    8008c8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008df:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008e3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008e6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008f1:	00 
  8008f2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8008f5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8008f8:	89 04 24             	mov    %eax,(%esp)
  8008fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ff:	e8 ac 16 00 00       	call   801fb0 <__umoddi3>
  800904:	89 74 24 04          	mov    %esi,0x4(%esp)
  800908:	0f be 80 31 21 80 00 	movsbl 0x802131(%eax),%eax
  80090f:	89 04 24             	mov    %eax,(%esp)
  800912:	ff 55 08             	call   *0x8(%ebp)
  800915:	e9 d6 fe ff ff       	jmp    8007f0 <vprintfmt+0x514>
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800921:	8b 74 24 04          	mov    0x4(%esp),%esi
  800925:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800928:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80092c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800933:	00 
  800934:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800937:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80093a:	89 04 24             	mov    %eax,(%esp)
  80093d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800941:	e8 6a 16 00 00       	call   801fb0 <__umoddi3>
  800946:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094a:	0f be 80 31 21 80 00 	movsbl 0x802131(%eax),%eax
  800951:	89 04 24             	mov    %eax,(%esp)
  800954:	ff 55 08             	call   *0x8(%ebp)
  800957:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80095a:	e9 ac f9 ff ff       	jmp    80030b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80095f:	83 c4 6c             	add    $0x6c,%esp
  800962:	5b                   	pop    %ebx
  800963:	5e                   	pop    %esi
  800964:	5f                   	pop    %edi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	83 ec 28             	sub    $0x28,%esp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800973:	85 c0                	test   %eax,%eax
  800975:	74 04                	je     80097b <vsnprintf+0x14>
  800977:	85 d2                	test   %edx,%edx
  800979:	7f 07                	jg     800982 <vsnprintf+0x1b>
  80097b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800980:	eb 3b                	jmp    8009bd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800985:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800989:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80098c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099a:	8b 45 10             	mov    0x10(%ebp),%eax
  80099d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	c7 04 24 bf 02 80 00 	movl   $0x8002bf,(%esp)
  8009af:	e8 28 f9 ff ff       	call   8002dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009c5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	89 04 24             	mov    %eax,(%esp)
  8009e0:	e8 82 ff ff ff       	call   800967 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009ed:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 cf f8 ff ff       	call   8002dc <vprintfmt>
	va_end(ap);
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    
	...

00800a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a1e:	74 09                	je     800a29 <strlen+0x19>
		n++;
  800a20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a27:	75 f7                	jne    800a20 <strlen+0x10>
		n++;
	return n;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a35:	85 c9                	test   %ecx,%ecx
  800a37:	74 19                	je     800a52 <strnlen+0x27>
  800a39:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a3c:	74 14                	je     800a52 <strnlen+0x27>
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a43:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a46:	39 c8                	cmp    %ecx,%eax
  800a48:	74 0d                	je     800a57 <strnlen+0x2c>
  800a4a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a4e:	75 f3                	jne    800a43 <strnlen+0x18>
  800a50:	eb 05                	jmp    800a57 <strnlen+0x2c>
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a69:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a6d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a70:	83 c2 01             	add    $0x1,%edx
  800a73:	84 c9                	test   %cl,%cl
  800a75:	75 f2                	jne    800a69 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	89 1c 24             	mov    %ebx,(%esp)
  800a87:	e8 84 ff ff ff       	call   800a10 <strlen>
	strcpy(dst + len, src);
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a93:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a96:	89 04 24             	mov    %eax,(%esp)
  800a99:	e8 bc ff ff ff       	call   800a5a <strcpy>
	return dst;
}
  800a9e:	89 d8                	mov    %ebx,%eax
  800aa0:	83 c4 08             	add    $0x8,%esp
  800aa3:	5b                   	pop    %ebx
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab4:	85 f6                	test   %esi,%esi
  800ab6:	74 18                	je     800ad0 <strncpy+0x2a>
  800ab8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800abd:	0f b6 1a             	movzbl (%edx),%ebx
  800ac0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ac6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	39 ce                	cmp    %ecx,%esi
  800ace:	77 ed                	ja     800abd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae2:	89 f0                	mov    %esi,%eax
  800ae4:	85 c9                	test   %ecx,%ecx
  800ae6:	74 27                	je     800b0f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800ae8:	83 e9 01             	sub    $0x1,%ecx
  800aeb:	74 1d                	je     800b0a <strlcpy+0x36>
  800aed:	0f b6 1a             	movzbl (%edx),%ebx
  800af0:	84 db                	test   %bl,%bl
  800af2:	74 16                	je     800b0a <strlcpy+0x36>
			*dst++ = *src++;
  800af4:	88 18                	mov    %bl,(%eax)
  800af6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af9:	83 e9 01             	sub    $0x1,%ecx
  800afc:	74 0e                	je     800b0c <strlcpy+0x38>
			*dst++ = *src++;
  800afe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b01:	0f b6 1a             	movzbl (%edx),%ebx
  800b04:	84 db                	test   %bl,%bl
  800b06:	75 ec                	jne    800af4 <strlcpy+0x20>
  800b08:	eb 02                	jmp    800b0c <strlcpy+0x38>
  800b0a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b0c:	c6 00 00             	movb   $0x0,(%eax)
  800b0f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1e:	0f b6 01             	movzbl (%ecx),%eax
  800b21:	84 c0                	test   %al,%al
  800b23:	74 15                	je     800b3a <strcmp+0x25>
  800b25:	3a 02                	cmp    (%edx),%al
  800b27:	75 11                	jne    800b3a <strcmp+0x25>
		p++, q++;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b2f:	0f b6 01             	movzbl (%ecx),%eax
  800b32:	84 c0                	test   %al,%al
  800b34:	74 04                	je     800b3a <strcmp+0x25>
  800b36:	3a 02                	cmp    (%edx),%al
  800b38:	74 ef                	je     800b29 <strcmp+0x14>
  800b3a:	0f b6 c0             	movzbl %al,%eax
  800b3d:	0f b6 12             	movzbl (%edx),%edx
  800b40:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	53                   	push   %ebx
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	74 23                	je     800b78 <strncmp+0x34>
  800b55:	0f b6 1a             	movzbl (%edx),%ebx
  800b58:	84 db                	test   %bl,%bl
  800b5a:	74 25                	je     800b81 <strncmp+0x3d>
  800b5c:	3a 19                	cmp    (%ecx),%bl
  800b5e:	75 21                	jne    800b81 <strncmp+0x3d>
  800b60:	83 e8 01             	sub    $0x1,%eax
  800b63:	74 13                	je     800b78 <strncmp+0x34>
		n--, p++, q++;
  800b65:	83 c2 01             	add    $0x1,%edx
  800b68:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b6b:	0f b6 1a             	movzbl (%edx),%ebx
  800b6e:	84 db                	test   %bl,%bl
  800b70:	74 0f                	je     800b81 <strncmp+0x3d>
  800b72:	3a 19                	cmp    (%ecx),%bl
  800b74:	74 ea                	je     800b60 <strncmp+0x1c>
  800b76:	eb 09                	jmp    800b81 <strncmp+0x3d>
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5d                   	pop    %ebp
  800b7f:	90                   	nop
  800b80:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b81:	0f b6 02             	movzbl (%edx),%eax
  800b84:	0f b6 11             	movzbl (%ecx),%edx
  800b87:	29 d0                	sub    %edx,%eax
  800b89:	eb f2                	jmp    800b7d <strncmp+0x39>

00800b8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b95:	0f b6 10             	movzbl (%eax),%edx
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	74 18                	je     800bb4 <strchr+0x29>
		if (*s == c)
  800b9c:	38 ca                	cmp    %cl,%dl
  800b9e:	75 0a                	jne    800baa <strchr+0x1f>
  800ba0:	eb 17                	jmp    800bb9 <strchr+0x2e>
  800ba2:	38 ca                	cmp    %cl,%dl
  800ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ba8:	74 0f                	je     800bb9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	0f b6 10             	movzbl (%eax),%edx
  800bb0:	84 d2                	test   %dl,%dl
  800bb2:	75 ee                	jne    800ba2 <strchr+0x17>
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc5:	0f b6 10             	movzbl (%eax),%edx
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	74 18                	je     800be4 <strfind+0x29>
		if (*s == c)
  800bcc:	38 ca                	cmp    %cl,%dl
  800bce:	75 0a                	jne    800bda <strfind+0x1f>
  800bd0:	eb 12                	jmp    800be4 <strfind+0x29>
  800bd2:	38 ca                	cmp    %cl,%dl
  800bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bd8:	74 0a                	je     800be4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 10             	movzbl (%eax),%edx
  800be0:	84 d2                	test   %dl,%dl
  800be2:	75 ee                	jne    800bd2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	89 1c 24             	mov    %ebx,(%esp)
  800bef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c00:	85 c9                	test   %ecx,%ecx
  800c02:	74 30                	je     800c34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0a:	75 25                	jne    800c31 <memset+0x4b>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 20                	jne    800c31 <memset+0x4b>
		c &= 0xFF;
  800c11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	c1 e3 08             	shl    $0x8,%ebx
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	c1 e6 18             	shl    $0x18,%esi
  800c1e:	89 d0                	mov    %edx,%eax
  800c20:	c1 e0 10             	shl    $0x10,%eax
  800c23:	09 f0                	or     %esi,%eax
  800c25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c27:	09 d8                	or     %ebx,%eax
  800c29:	c1 e9 02             	shr    $0x2,%ecx
  800c2c:	fc                   	cld    
  800c2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c2f:	eb 03                	jmp    800c34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c31:	fc                   	cld    
  800c32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	8b 1c 24             	mov    (%esp),%ebx
  800c39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c41:	89 ec                	mov    %ebp,%esp
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
  800c4b:	89 34 24             	mov    %esi,(%esp)
  800c4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c5d:	39 c6                	cmp    %eax,%esi
  800c5f:	73 35                	jae    800c96 <memmove+0x51>
  800c61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c64:	39 d0                	cmp    %edx,%eax
  800c66:	73 2e                	jae    800c96 <memmove+0x51>
		s += n;
		d += n;
  800c68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6a:	f6 c2 03             	test   $0x3,%dl
  800c6d:	75 1b                	jne    800c8a <memmove+0x45>
  800c6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c75:	75 13                	jne    800c8a <memmove+0x45>
  800c77:	f6 c1 03             	test   $0x3,%cl
  800c7a:	75 0e                	jne    800c8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c7c:	83 ef 04             	sub    $0x4,%edi
  800c7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c82:	c1 e9 02             	shr    $0x2,%ecx
  800c85:	fd                   	std    
  800c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c88:	eb 09                	jmp    800c93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c8a:	83 ef 01             	sub    $0x1,%edi
  800c8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c90:	fd                   	std    
  800c91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c93:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c94:	eb 20                	jmp    800cb6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c9c:	75 15                	jne    800cb3 <memmove+0x6e>
  800c9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca4:	75 0d                	jne    800cb3 <memmove+0x6e>
  800ca6:	f6 c1 03             	test   $0x3,%cl
  800ca9:	75 08                	jne    800cb3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800cab:	c1 e9 02             	shr    $0x2,%ecx
  800cae:	fc                   	cld    
  800caf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb1:	eb 03                	jmp    800cb6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cb3:	fc                   	cld    
  800cb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cb6:	8b 34 24             	mov    (%esp),%esi
  800cb9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cbd:	89 ec                	mov    %ebp,%esp
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	89 04 24             	mov    %eax,(%esp)
  800cdb:	e8 65 ff ff ff       	call   800c45 <memmove>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ceb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf1:	85 c9                	test   %ecx,%ecx
  800cf3:	74 36                	je     800d2b <memcmp+0x49>
		if (*s1 != *s2)
  800cf5:	0f b6 06             	movzbl (%esi),%eax
  800cf8:	0f b6 1f             	movzbl (%edi),%ebx
  800cfb:	38 d8                	cmp    %bl,%al
  800cfd:	74 20                	je     800d1f <memcmp+0x3d>
  800cff:	eb 14                	jmp    800d15 <memcmp+0x33>
  800d01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d0b:	83 c2 01             	add    $0x1,%edx
  800d0e:	83 e9 01             	sub    $0x1,%ecx
  800d11:	38 d8                	cmp    %bl,%al
  800d13:	74 12                	je     800d27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d15:	0f b6 c0             	movzbl %al,%eax
  800d18:	0f b6 db             	movzbl %bl,%ebx
  800d1b:	29 d8                	sub    %ebx,%eax
  800d1d:	eb 11                	jmp    800d30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1f:	83 e9 01             	sub    $0x1,%ecx
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
  800d27:	85 c9                	test   %ecx,%ecx
  800d29:	75 d6                	jne    800d01 <memcmp+0x1f>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d40:	39 d0                	cmp    %edx,%eax
  800d42:	73 15                	jae    800d59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d48:	38 08                	cmp    %cl,(%eax)
  800d4a:	75 06                	jne    800d52 <memfind+0x1d>
  800d4c:	eb 0b                	jmp    800d59 <memfind+0x24>
  800d4e:	38 08                	cmp    %cl,(%eax)
  800d50:	74 07                	je     800d59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d52:	83 c0 01             	add    $0x1,%eax
  800d55:	39 c2                	cmp    %eax,%edx
  800d57:	77 f5                	ja     800d4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6a:	0f b6 02             	movzbl (%edx),%eax
  800d6d:	3c 20                	cmp    $0x20,%al
  800d6f:	74 04                	je     800d75 <strtol+0x1a>
  800d71:	3c 09                	cmp    $0x9,%al
  800d73:	75 0e                	jne    800d83 <strtol+0x28>
		s++;
  800d75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d78:	0f b6 02             	movzbl (%edx),%eax
  800d7b:	3c 20                	cmp    $0x20,%al
  800d7d:	74 f6                	je     800d75 <strtol+0x1a>
  800d7f:	3c 09                	cmp    $0x9,%al
  800d81:	74 f2                	je     800d75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d83:	3c 2b                	cmp    $0x2b,%al
  800d85:	75 0c                	jne    800d93 <strtol+0x38>
		s++;
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d91:	eb 15                	jmp    800da8 <strtol+0x4d>
	else if (*s == '-')
  800d93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d9a:	3c 2d                	cmp    $0x2d,%al
  800d9c:	75 0a                	jne    800da8 <strtol+0x4d>
		s++, neg = 1;
  800d9e:	83 c2 01             	add    $0x1,%edx
  800da1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da8:	85 db                	test   %ebx,%ebx
  800daa:	0f 94 c0             	sete   %al
  800dad:	74 05                	je     800db4 <strtol+0x59>
  800daf:	83 fb 10             	cmp    $0x10,%ebx
  800db2:	75 18                	jne    800dcc <strtol+0x71>
  800db4:	80 3a 30             	cmpb   $0x30,(%edx)
  800db7:	75 13                	jne    800dcc <strtol+0x71>
  800db9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi
  800dc0:	75 0a                	jne    800dcc <strtol+0x71>
		s += 2, base = 16;
  800dc2:	83 c2 02             	add    $0x2,%edx
  800dc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dca:	eb 15                	jmp    800de1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dcc:	84 c0                	test   %al,%al
  800dce:	66 90                	xchg   %ax,%ax
  800dd0:	74 0f                	je     800de1 <strtol+0x86>
  800dd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dda:	75 05                	jne    800de1 <strtol+0x86>
		s++, base = 8;
  800ddc:	83 c2 01             	add    $0x1,%edx
  800ddf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800de1:	b8 00 00 00 00       	mov    $0x0,%eax
  800de6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de8:	0f b6 0a             	movzbl (%edx),%ecx
  800deb:	89 cf                	mov    %ecx,%edi
  800ded:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800df0:	80 fb 09             	cmp    $0x9,%bl
  800df3:	77 08                	ja     800dfd <strtol+0xa2>
			dig = *s - '0';
  800df5:	0f be c9             	movsbl %cl,%ecx
  800df8:	83 e9 30             	sub    $0x30,%ecx
  800dfb:	eb 1e                	jmp    800e1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800dfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e00:	80 fb 19             	cmp    $0x19,%bl
  800e03:	77 08                	ja     800e0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e05:	0f be c9             	movsbl %cl,%ecx
  800e08:	83 e9 57             	sub    $0x57,%ecx
  800e0b:	eb 0e                	jmp    800e1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e10:	80 fb 19             	cmp    $0x19,%bl
  800e13:	77 15                	ja     800e2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e15:	0f be c9             	movsbl %cl,%ecx
  800e18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e1b:	39 f1                	cmp    %esi,%ecx
  800e1d:	7d 0b                	jge    800e2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e1f:	83 c2 01             	add    $0x1,%edx
  800e22:	0f af c6             	imul   %esi,%eax
  800e25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e28:	eb be                	jmp    800de8 <strtol+0x8d>
  800e2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e30:	74 05                	je     800e37 <strtol+0xdc>
		*endptr = (char *) s;
  800e32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e3b:	74 04                	je     800e41 <strtol+0xe6>
  800e3d:	89 c8                	mov    %ecx,%eax
  800e3f:	f7 d8                	neg    %eax
}
  800e41:	83 c4 04             	add    $0x4,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	00 00                	add    %al,(%eax)
	...

00800e4c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	89 1c 24             	mov    %ebx,(%esp)
  800e55:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e59:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e63:	89 d1                	mov    %edx,%ecx
  800e65:	89 d3                	mov    %edx,%ebx
  800e67:	89 d7                	mov    %edx,%edi
  800e69:	51                   	push   %ecx
  800e6a:	52                   	push   %edx
  800e6b:	53                   	push   %ebx
  800e6c:	54                   	push   %esp
  800e6d:	55                   	push   %ebp
  800e6e:	56                   	push   %esi
  800e6f:	57                   	push   %edi
  800e70:	54                   	push   %esp
  800e71:	5d                   	pop    %ebp
  800e72:	8d 35 7a 0e 80 00    	lea    0x800e7a,%esi
  800e78:	0f 34                	sysenter 
  800e7a:	5f                   	pop    %edi
  800e7b:	5e                   	pop    %esi
  800e7c:	5d                   	pop    %ebp
  800e7d:	5c                   	pop    %esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5a                   	pop    %edx
  800e80:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e81:	8b 1c 24             	mov    (%esp),%ebx
  800e84:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	89 c3                	mov    %eax,%ebx
  800ea6:	89 c7                	mov    %eax,%edi
  800ea8:	51                   	push   %ecx
  800ea9:	52                   	push   %edx
  800eaa:	53                   	push   %ebx
  800eab:	54                   	push   %esp
  800eac:	55                   	push   %ebp
  800ead:	56                   	push   %esi
  800eae:	57                   	push   %edi
  800eaf:	54                   	push   %esp
  800eb0:	5d                   	pop    %ebp
  800eb1:	8d 35 b9 0e 80 00    	lea    0x800eb9,%esi
  800eb7:	0f 34                	sysenter 
  800eb9:	5f                   	pop    %edi
  800eba:	5e                   	pop    %esi
  800ebb:	5d                   	pop    %ebp
  800ebc:	5c                   	pop    %esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5a                   	pop    %edx
  800ebf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ec0:	8b 1c 24             	mov    (%esp),%ebx
  800ec3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ec7:	89 ec                	mov    %ebp,%esp
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	89 1c 24             	mov    %ebx,(%esp)
  800ed4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed8:	b8 10 00 00 00       	mov    $0x10,%eax
  800edd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	51                   	push   %ecx
  800eea:	52                   	push   %edx
  800eeb:	53                   	push   %ebx
  800eec:	54                   	push   %esp
  800eed:	55                   	push   %ebp
  800eee:	56                   	push   %esi
  800eef:	57                   	push   %edi
  800ef0:	54                   	push   %esp
  800ef1:	5d                   	pop    %ebp
  800ef2:	8d 35 fa 0e 80 00    	lea    0x800efa,%esi
  800ef8:	0f 34                	sysenter 
  800efa:	5f                   	pop    %edi
  800efb:	5e                   	pop    %esi
  800efc:	5d                   	pop    %ebp
  800efd:	5c                   	pop    %esp
  800efe:	5b                   	pop    %ebx
  800eff:	5a                   	pop    %edx
  800f00:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800f01:	8b 1c 24             	mov    (%esp),%ebx
  800f04:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f08:	89 ec                	mov    %ebp,%esp
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 28             	sub    $0x28,%esp
  800f12:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	89 df                	mov    %ebx,%edi
  800f2a:	51                   	push   %ecx
  800f2b:	52                   	push   %edx
  800f2c:	53                   	push   %ebx
  800f2d:	54                   	push   %esp
  800f2e:	55                   	push   %ebp
  800f2f:	56                   	push   %esi
  800f30:	57                   	push   %edi
  800f31:	54                   	push   %esp
  800f32:	5d                   	pop    %ebp
  800f33:	8d 35 3b 0f 80 00    	lea    0x800f3b,%esi
  800f39:	0f 34                	sysenter 
  800f3b:	5f                   	pop    %edi
  800f3c:	5e                   	pop    %esi
  800f3d:	5d                   	pop    %ebp
  800f3e:	5c                   	pop    %esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5a                   	pop    %edx
  800f41:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f42:	85 c0                	test   %eax,%eax
  800f44:	7e 28                	jle    800f6e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  800f69:	e8 76 0d 00 00       	call   801ce4 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f6e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f71:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f74:	89 ec                	mov    %ebp,%esp
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	89 1c 24             	mov    %ebx,(%esp)
  800f81:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8a:	b8 11 00 00 00       	mov    $0x11,%eax
  800f8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f92:	89 cb                	mov    %ecx,%ebx
  800f94:	89 cf                	mov    %ecx,%edi
  800f96:	51                   	push   %ecx
  800f97:	52                   	push   %edx
  800f98:	53                   	push   %ebx
  800f99:	54                   	push   %esp
  800f9a:	55                   	push   %ebp
  800f9b:	56                   	push   %esi
  800f9c:	57                   	push   %edi
  800f9d:	54                   	push   %esp
  800f9e:	5d                   	pop    %ebp
  800f9f:	8d 35 a7 0f 80 00    	lea    0x800fa7,%esi
  800fa5:	0f 34                	sysenter 
  800fa7:	5f                   	pop    %edi
  800fa8:	5e                   	pop    %esi
  800fa9:	5d                   	pop    %ebp
  800faa:	5c                   	pop    %esp
  800fab:	5b                   	pop    %ebx
  800fac:	5a                   	pop    %edx
  800fad:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800fae:	8b 1c 24             	mov    (%esp),%ebx
  800fb1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb5:	89 ec                	mov    %ebp,%esp
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 28             	sub    $0x28,%esp
  800fbf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fc2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fca:	b8 0e 00 00 00       	mov    $0xe,%eax
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 28                	jle    80101a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff6:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  801005:	00 
  801006:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80100d:	00 
  80100e:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  801015:	e8 ca 0c 00 00       	call   801ce4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80101a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80101d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801020:	89 ec                	mov    %ebp,%esp
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 08             	sub    $0x8,%esp
  80102a:	89 1c 24             	mov    %ebx,(%esp)
  80102d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801031:	b8 0d 00 00 00       	mov    $0xd,%eax
  801036:	8b 7d 14             	mov    0x14(%ebp),%edi
  801039:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	51                   	push   %ecx
  801043:	52                   	push   %edx
  801044:	53                   	push   %ebx
  801045:	54                   	push   %esp
  801046:	55                   	push   %ebp
  801047:	56                   	push   %esi
  801048:	57                   	push   %edi
  801049:	54                   	push   %esp
  80104a:	5d                   	pop    %ebp
  80104b:	8d 35 53 10 80 00    	lea    0x801053,%esi
  801051:	0f 34                	sysenter 
  801053:	5f                   	pop    %edi
  801054:	5e                   	pop    %esi
  801055:	5d                   	pop    %ebp
  801056:	5c                   	pop    %esp
  801057:	5b                   	pop    %ebx
  801058:	5a                   	pop    %edx
  801059:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80105a:	8b 1c 24             	mov    (%esp),%ebx
  80105d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801061:	89 ec                	mov    %ebp,%esp
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 28             	sub    $0x28,%esp
  80106b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80106e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801071:	bb 00 00 00 00       	mov    $0x0,%ebx
  801076:	b8 0b 00 00 00       	mov    $0xb,%eax
  80107b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107e:	8b 55 08             	mov    0x8(%ebp),%edx
  801081:	89 df                	mov    %ebx,%edi
  801083:	51                   	push   %ecx
  801084:	52                   	push   %edx
  801085:	53                   	push   %ebx
  801086:	54                   	push   %esp
  801087:	55                   	push   %ebp
  801088:	56                   	push   %esi
  801089:	57                   	push   %edi
  80108a:	54                   	push   %esp
  80108b:	5d                   	pop    %ebp
  80108c:	8d 35 94 10 80 00    	lea    0x801094,%esi
  801092:	0f 34                	sysenter 
  801094:	5f                   	pop    %edi
  801095:	5e                   	pop    %esi
  801096:	5d                   	pop    %ebp
  801097:	5c                   	pop    %esp
  801098:	5b                   	pop    %ebx
  801099:	5a                   	pop    %edx
  80109a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	7e 28                	jle    8010c7 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  8010c2:	e8 1d 0c 00 00       	call   801ce4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010ca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cd:	89 ec                	mov    %ebp,%esp
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 28             	sub    $0x28,%esp
  8010d7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010da:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ed:	89 df                	mov    %ebx,%edi
  8010ef:	51                   	push   %ecx
  8010f0:	52                   	push   %edx
  8010f1:	53                   	push   %ebx
  8010f2:	54                   	push   %esp
  8010f3:	55                   	push   %ebp
  8010f4:	56                   	push   %esi
  8010f5:	57                   	push   %edi
  8010f6:	54                   	push   %esp
  8010f7:	5d                   	pop    %ebp
  8010f8:	8d 35 00 11 80 00    	lea    0x801100,%esi
  8010fe:	0f 34                	sysenter 
  801100:	5f                   	pop    %edi
  801101:	5e                   	pop    %esi
  801102:	5d                   	pop    %ebp
  801103:	5c                   	pop    %esp
  801104:	5b                   	pop    %ebx
  801105:	5a                   	pop    %edx
  801106:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801107:	85 c0                	test   %eax,%eax
  801109:	7e 28                	jle    801133 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801116:	00 
  801117:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  80111e:	00 
  80111f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801126:	00 
  801127:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  80112e:	e8 b1 0b 00 00       	call   801ce4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801133:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801136:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801139:	89 ec                	mov    %ebp,%esp
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	83 ec 28             	sub    $0x28,%esp
  801143:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801146:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801149:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114e:	b8 09 00 00 00       	mov    $0x9,%eax
  801153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801156:	8b 55 08             	mov    0x8(%ebp),%edx
  801159:	89 df                	mov    %ebx,%edi
  80115b:	51                   	push   %ecx
  80115c:	52                   	push   %edx
  80115d:	53                   	push   %ebx
  80115e:	54                   	push   %esp
  80115f:	55                   	push   %ebp
  801160:	56                   	push   %esi
  801161:	57                   	push   %edi
  801162:	54                   	push   %esp
  801163:	5d                   	pop    %ebp
  801164:	8d 35 6c 11 80 00    	lea    0x80116c,%esi
  80116a:	0f 34                	sysenter 
  80116c:	5f                   	pop    %edi
  80116d:	5e                   	pop    %esi
  80116e:	5d                   	pop    %ebp
  80116f:	5c                   	pop    %esp
  801170:	5b                   	pop    %ebx
  801171:	5a                   	pop    %edx
  801172:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801173:	85 c0                	test   %eax,%eax
  801175:	7e 28                	jle    80119f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801177:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801182:	00 
  801183:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  80118a:	00 
  80118b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801192:	00 
  801193:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  80119a:	e8 45 0b 00 00       	call   801ce4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80119f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011a2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011a5:	89 ec                	mov    %ebp,%esp
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 28             	sub    $0x28,%esp
  8011af:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011b2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ba:	b8 07 00 00 00       	mov    $0x7,%eax
  8011bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c5:	89 df                	mov    %ebx,%edi
  8011c7:	51                   	push   %ecx
  8011c8:	52                   	push   %edx
  8011c9:	53                   	push   %ebx
  8011ca:	54                   	push   %esp
  8011cb:	55                   	push   %ebp
  8011cc:	56                   	push   %esi
  8011cd:	57                   	push   %edi
  8011ce:	54                   	push   %esp
  8011cf:	5d                   	pop    %ebp
  8011d0:	8d 35 d8 11 80 00    	lea    0x8011d8,%esi
  8011d6:	0f 34                	sysenter 
  8011d8:	5f                   	pop    %edi
  8011d9:	5e                   	pop    %esi
  8011da:	5d                   	pop    %ebp
  8011db:	5c                   	pop    %esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5a                   	pop    %edx
  8011de:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	7e 28                	jle    80120b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8011ee:	00 
  8011ef:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011fe:	00 
  8011ff:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  801206:	e8 d9 0a 00 00       	call   801ce4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80120b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80120e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801211:	89 ec                	mov    %ebp,%esp
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 28             	sub    $0x28,%esp
  80121b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80121e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801221:	8b 7d 18             	mov    0x18(%ebp),%edi
  801224:	0b 7d 14             	or     0x14(%ebp),%edi
  801227:	b8 06 00 00 00       	mov    $0x6,%eax
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
  80124f:	7e 28                	jle    801279 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801251:	89 44 24 10          	mov    %eax,0x10(%esp)
  801255:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80125c:	00 
  80125d:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  801264:	00 
  801265:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80126c:	00 
  80126d:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  801274:	e8 6b 0a 00 00       	call   801ce4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801279:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80127c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80127f:	89 ec                	mov    %ebp,%esp
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	83 ec 28             	sub    $0x28,%esp
  801289:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80128c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80128f:	bf 00 00 00 00       	mov    $0x0,%edi
  801294:	b8 05 00 00 00       	mov    $0x5,%eax
  801299:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80129c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129f:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a2:	51                   	push   %ecx
  8012a3:	52                   	push   %edx
  8012a4:	53                   	push   %ebx
  8012a5:	54                   	push   %esp
  8012a6:	55                   	push   %ebp
  8012a7:	56                   	push   %esi
  8012a8:	57                   	push   %edi
  8012a9:	54                   	push   %esp
  8012aa:	5d                   	pop    %ebp
  8012ab:	8d 35 b3 12 80 00    	lea    0x8012b3,%esi
  8012b1:	0f 34                	sysenter 
  8012b3:	5f                   	pop    %edi
  8012b4:	5e                   	pop    %esi
  8012b5:	5d                   	pop    %ebp
  8012b6:	5c                   	pop    %esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5a                   	pop    %edx
  8012b9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	7e 28                	jle    8012e6 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012c9:	00 
  8012ca:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  8012d1:	00 
  8012d2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012d9:	00 
  8012da:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  8012e1:	e8 fe 09 00 00       	call   801ce4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ec:	89 ec                	mov    %ebp,%esp
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	89 1c 24             	mov    %ebx,(%esp)
  8012f9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801302:	b8 0c 00 00 00       	mov    $0xc,%eax
  801307:	89 d1                	mov    %edx,%ecx
  801309:	89 d3                	mov    %edx,%ebx
  80130b:	89 d7                	mov    %edx,%edi
  80130d:	51                   	push   %ecx
  80130e:	52                   	push   %edx
  80130f:	53                   	push   %ebx
  801310:	54                   	push   %esp
  801311:	55                   	push   %ebp
  801312:	56                   	push   %esi
  801313:	57                   	push   %edi
  801314:	54                   	push   %esp
  801315:	5d                   	pop    %ebp
  801316:	8d 35 1e 13 80 00    	lea    0x80131e,%esi
  80131c:	0f 34                	sysenter 
  80131e:	5f                   	pop    %edi
  80131f:	5e                   	pop    %esi
  801320:	5d                   	pop    %ebp
  801321:	5c                   	pop    %esp
  801322:	5b                   	pop    %ebx
  801323:	5a                   	pop    %edx
  801324:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801325:	8b 1c 24             	mov    (%esp),%ebx
  801328:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80132c:	89 ec                	mov    %ebp,%esp
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
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
  80133d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801342:	b8 04 00 00 00       	mov    $0x4,%eax
  801347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134a:	8b 55 08             	mov    0x8(%ebp),%edx
  80134d:	89 df                	mov    %ebx,%edi
  80134f:	51                   	push   %ecx
  801350:	52                   	push   %edx
  801351:	53                   	push   %ebx
  801352:	54                   	push   %esp
  801353:	55                   	push   %ebp
  801354:	56                   	push   %esi
  801355:	57                   	push   %edi
  801356:	54                   	push   %esp
  801357:	5d                   	pop    %ebp
  801358:	8d 35 60 13 80 00    	lea    0x801360,%esi
  80135e:	0f 34                	sysenter 
  801360:	5f                   	pop    %edi
  801361:	5e                   	pop    %esi
  801362:	5d                   	pop    %ebp
  801363:	5c                   	pop    %esp
  801364:	5b                   	pop    %ebx
  801365:	5a                   	pop    %edx
  801366:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801367:	8b 1c 24             	mov    (%esp),%ebx
  80136a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80136e:	89 ec                	mov    %ebp,%esp
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	89 1c 24             	mov    %ebx,(%esp)
  80137b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80137f:	ba 00 00 00 00       	mov    $0x0,%edx
  801384:	b8 02 00 00 00       	mov    $0x2,%eax
  801389:	89 d1                	mov    %edx,%ecx
  80138b:	89 d3                	mov    %edx,%ebx
  80138d:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013a7:	8b 1c 24             	mov    (%esp),%ebx
  8013aa:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ae:	89 ec                	mov    %ebp,%esp
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 28             	sub    $0x28,%esp
  8013b8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013bb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013c3:	b8 03 00 00 00       	mov    $0x3,%eax
  8013c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013cb:	89 cb                	mov    %ecx,%ebx
  8013cd:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	7e 28                	jle    801413 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8013f6:	00 
  8013f7:	c7 44 24 08 c0 24 80 	movl   $0x8024c0,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 dd 24 80 00 	movl   $0x8024dd,(%esp)
  80140e:	e8 d1 08 00 00       	call   801ce4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801413:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801416:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801419:	89 ec                	mov    %ebp,%esp
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    
  80141d:	00 00                	add    %al,(%eax)
	...

00801420 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	05 00 00 00 30       	add    $0x30000000,%eax
  80142b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	89 04 24             	mov    %eax,(%esp)
  80143c:	e8 df ff ff ff       	call   801420 <fd2num>
  801441:	05 20 00 0d 00       	add    $0xd0020,%eax
  801446:	c1 e0 0c             	shl    $0xc,%eax
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	57                   	push   %edi
  80144f:	56                   	push   %esi
  801450:	53                   	push   %ebx
  801451:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801454:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801459:	a8 01                	test   $0x1,%al
  80145b:	74 36                	je     801493 <fd_alloc+0x48>
  80145d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801462:	a8 01                	test   $0x1,%al
  801464:	74 2d                	je     801493 <fd_alloc+0x48>
  801466:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80146b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801470:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801475:	89 c3                	mov    %eax,%ebx
  801477:	89 c2                	mov    %eax,%edx
  801479:	c1 ea 16             	shr    $0x16,%edx
  80147c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80147f:	f6 c2 01             	test   $0x1,%dl
  801482:	74 14                	je     801498 <fd_alloc+0x4d>
  801484:	89 c2                	mov    %eax,%edx
  801486:	c1 ea 0c             	shr    $0xc,%edx
  801489:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80148c:	f6 c2 01             	test   $0x1,%dl
  80148f:	75 10                	jne    8014a1 <fd_alloc+0x56>
  801491:	eb 05                	jmp    801498 <fd_alloc+0x4d>
  801493:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801498:	89 1f                	mov    %ebx,(%edi)
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80149f:	eb 17                	jmp    8014b8 <fd_alloc+0x6d>
  8014a1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014ab:	75 c8                	jne    801475 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014ad:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8014b3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5f                   	pop    %edi
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	83 f8 1f             	cmp    $0x1f,%eax
  8014c6:	77 36                	ja     8014fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014c8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014cd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	c1 ea 16             	shr    $0x16,%edx
  8014d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014dc:	f6 c2 01             	test   $0x1,%dl
  8014df:	74 1d                	je     8014fe <fd_lookup+0x41>
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	c1 ea 0c             	shr    $0xc,%edx
  8014e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ed:	f6 c2 01             	test   $0x1,%dl
  8014f0:	74 0c                	je     8014fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f5:	89 02                	mov    %eax,(%edx)
  8014f7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8014fc:	eb 05                	jmp    801503 <fd_lookup+0x46>
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80150e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801512:	8b 45 08             	mov    0x8(%ebp),%eax
  801515:	89 04 24             	mov    %eax,(%esp)
  801518:	e8 a0 ff ff ff       	call   8014bd <fd_lookup>
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 0e                	js     80152f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801521:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801524:	8b 55 0c             	mov    0xc(%ebp),%edx
  801527:	89 50 04             	mov    %edx,0x4(%eax)
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 10             	sub    $0x10,%esp
  801539:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80153f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801544:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801549:	be 68 25 80 00       	mov    $0x802568,%esi
		if (devtab[i]->dev_id == dev_id) {
  80154e:	39 08                	cmp    %ecx,(%eax)
  801550:	75 10                	jne    801562 <dev_lookup+0x31>
  801552:	eb 04                	jmp    801558 <dev_lookup+0x27>
  801554:	39 08                	cmp    %ecx,(%eax)
  801556:	75 0a                	jne    801562 <dev_lookup+0x31>
			*dev = devtab[i];
  801558:	89 03                	mov    %eax,(%ebx)
  80155a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80155f:	90                   	nop
  801560:	eb 31                	jmp    801593 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801562:	83 c2 01             	add    $0x1,%edx
  801565:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801568:	85 c0                	test   %eax,%eax
  80156a:	75 e8                	jne    801554 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80156c:	a1 04 40 80 00       	mov    0x804004,%eax
  801571:	8b 40 48             	mov    0x48(%eax),%eax
  801574:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801578:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157c:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  801583:	e8 9d eb ff ff       	call   800125 <cprintf>
	*dev = 0;
  801588:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80158e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 24             	sub    $0x24,%esp
  8015a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ae:	89 04 24             	mov    %eax,(%esp)
  8015b1:	e8 07 ff ff ff       	call   8014bd <fd_lookup>
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 53                	js     80160d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c4:	8b 00                	mov    (%eax),%eax
  8015c6:	89 04 24             	mov    %eax,(%esp)
  8015c9:	e8 63 ff ff ff       	call   801531 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 3b                	js     80160d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8015d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015da:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8015de:	74 2d                	je     80160d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ea:	00 00 00 
	stat->st_isdir = 0;
  8015ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015f4:	00 00 00 
	stat->st_dev = dev;
  8015f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801604:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801607:	89 14 24             	mov    %edx,(%esp)
  80160a:	ff 50 14             	call   *0x14(%eax)
}
  80160d:	83 c4 24             	add    $0x24,%esp
  801610:	5b                   	pop    %ebx
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	53                   	push   %ebx
  801617:	83 ec 24             	sub    $0x24,%esp
  80161a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801620:	89 44 24 04          	mov    %eax,0x4(%esp)
  801624:	89 1c 24             	mov    %ebx,(%esp)
  801627:	e8 91 fe ff ff       	call   8014bd <fd_lookup>
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 5f                	js     80168f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801630:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801633:	89 44 24 04          	mov    %eax,0x4(%esp)
  801637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163a:	8b 00                	mov    (%eax),%eax
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	e8 ed fe ff ff       	call   801531 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801644:	85 c0                	test   %eax,%eax
  801646:	78 47                	js     80168f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801648:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80164b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80164f:	75 23                	jne    801674 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801651:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801656:	8b 40 48             	mov    0x48(%eax),%eax
  801659:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80165d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801661:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  801668:	e8 b8 ea ff ff       	call   800125 <cprintf>
  80166d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801672:	eb 1b                	jmp    80168f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801677:	8b 48 18             	mov    0x18(%eax),%ecx
  80167a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80167f:	85 c9                	test   %ecx,%ecx
  801681:	74 0c                	je     80168f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801683:	8b 45 0c             	mov    0xc(%ebp),%eax
  801686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168a:	89 14 24             	mov    %edx,(%esp)
  80168d:	ff d1                	call   *%ecx
}
  80168f:	83 c4 24             	add    $0x24,%esp
  801692:	5b                   	pop    %ebx
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	83 ec 24             	sub    $0x24,%esp
  80169c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a6:	89 1c 24             	mov    %ebx,(%esp)
  8016a9:	e8 0f fe ff ff       	call   8014bd <fd_lookup>
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 66                	js     801718 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bc:	8b 00                	mov    (%eax),%eax
  8016be:	89 04 24             	mov    %eax,(%esp)
  8016c1:	e8 6b fe ff ff       	call   801531 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 4e                	js     801718 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016cd:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8016d1:	75 23                	jne    8016f6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d8:	8b 40 48             	mov    0x48(%eax),%eax
  8016db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e3:	c7 04 24 2d 25 80 00 	movl   $0x80252d,(%esp)
  8016ea:	e8 36 ea ff ff       	call   800125 <cprintf>
  8016ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8016f4:	eb 22                	jmp    801718 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8016fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801701:	85 c9                	test   %ecx,%ecx
  801703:	74 13                	je     801718 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801705:	8b 45 10             	mov    0x10(%ebp),%eax
  801708:	89 44 24 08          	mov    %eax,0x8(%esp)
  80170c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801713:	89 14 24             	mov    %edx,(%esp)
  801716:	ff d1                	call   *%ecx
}
  801718:	83 c4 24             	add    $0x24,%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	53                   	push   %ebx
  801722:	83 ec 24             	sub    $0x24,%esp
  801725:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801728:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172f:	89 1c 24             	mov    %ebx,(%esp)
  801732:	e8 86 fd ff ff       	call   8014bd <fd_lookup>
  801737:	85 c0                	test   %eax,%eax
  801739:	78 6b                	js     8017a6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801745:	8b 00                	mov    (%eax),%eax
  801747:	89 04 24             	mov    %eax,(%esp)
  80174a:	e8 e2 fd ff ff       	call   801531 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 53                	js     8017a6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801753:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801756:	8b 42 08             	mov    0x8(%edx),%eax
  801759:	83 e0 03             	and    $0x3,%eax
  80175c:	83 f8 01             	cmp    $0x1,%eax
  80175f:	75 23                	jne    801784 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801761:	a1 04 40 80 00       	mov    0x804004,%eax
  801766:	8b 40 48             	mov    0x48(%eax),%eax
  801769:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80176d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801771:	c7 04 24 4a 25 80 00 	movl   $0x80254a,(%esp)
  801778:	e8 a8 e9 ff ff       	call   800125 <cprintf>
  80177d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801782:	eb 22                	jmp    8017a6 <read+0x88>
	}
	if (!dev->dev_read)
  801784:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801787:	8b 48 08             	mov    0x8(%eax),%ecx
  80178a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80178f:	85 c9                	test   %ecx,%ecx
  801791:	74 13                	je     8017a6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801793:	8b 45 10             	mov    0x10(%ebp),%eax
  801796:	89 44 24 08          	mov    %eax,0x8(%esp)
  80179a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	89 14 24             	mov    %edx,(%esp)
  8017a4:	ff d1                	call   *%ecx
}
  8017a6:	83 c4 24             	add    $0x24,%esp
  8017a9:	5b                   	pop    %ebx
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	57                   	push   %edi
  8017b0:	56                   	push   %esi
  8017b1:	53                   	push   %ebx
  8017b2:	83 ec 1c             	sub    $0x1c,%esp
  8017b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ca:	85 f6                	test   %esi,%esi
  8017cc:	74 29                	je     8017f7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017ce:	89 f0                	mov    %esi,%eax
  8017d0:	29 d0                	sub    %edx,%eax
  8017d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d6:	03 55 0c             	add    0xc(%ebp),%edx
  8017d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017dd:	89 3c 24             	mov    %edi,(%esp)
  8017e0:	e8 39 ff ff ff       	call   80171e <read>
		if (m < 0)
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 0e                	js     8017f7 <readn+0x4b>
			return m;
		if (m == 0)
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	74 08                	je     8017f5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ed:	01 c3                	add    %eax,%ebx
  8017ef:	89 da                	mov    %ebx,%edx
  8017f1:	39 f3                	cmp    %esi,%ebx
  8017f3:	72 d9                	jb     8017ce <readn+0x22>
  8017f5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017f7:	83 c4 1c             	add    $0x1c,%esp
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	5f                   	pop    %edi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	56                   	push   %esi
  801803:	53                   	push   %ebx
  801804:	83 ec 20             	sub    $0x20,%esp
  801807:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80180a:	89 34 24             	mov    %esi,(%esp)
  80180d:	e8 0e fc ff ff       	call   801420 <fd2num>
  801812:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801815:	89 54 24 04          	mov    %edx,0x4(%esp)
  801819:	89 04 24             	mov    %eax,(%esp)
  80181c:	e8 9c fc ff ff       	call   8014bd <fd_lookup>
  801821:	89 c3                	mov    %eax,%ebx
  801823:	85 c0                	test   %eax,%eax
  801825:	78 05                	js     80182c <fd_close+0x2d>
  801827:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80182a:	74 0c                	je     801838 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80182c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801830:	19 c0                	sbb    %eax,%eax
  801832:	f7 d0                	not    %eax
  801834:	21 c3                	and    %eax,%ebx
  801836:	eb 3d                	jmp    801875 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801838:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183f:	8b 06                	mov    (%esi),%eax
  801841:	89 04 24             	mov    %eax,(%esp)
  801844:	e8 e8 fc ff ff       	call   801531 <dev_lookup>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 16                	js     801865 <fd_close+0x66>
		if (dev->dev_close)
  80184f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801852:	8b 40 10             	mov    0x10(%eax),%eax
  801855:	bb 00 00 00 00       	mov    $0x0,%ebx
  80185a:	85 c0                	test   %eax,%eax
  80185c:	74 07                	je     801865 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80185e:	89 34 24             	mov    %esi,(%esp)
  801861:	ff d0                	call   *%eax
  801863:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801865:	89 74 24 04          	mov    %esi,0x4(%esp)
  801869:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801870:	e8 34 f9 ff ff       	call   8011a9 <sys_page_unmap>
	return r;
}
  801875:	89 d8                	mov    %ebx,%eax
  801877:	83 c4 20             	add    $0x20,%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	89 04 24             	mov    %eax,(%esp)
  801891:	e8 27 fc ff ff       	call   8014bd <fd_lookup>
  801896:	85 c0                	test   %eax,%eax
  801898:	78 13                	js     8018ad <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80189a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018a1:	00 
  8018a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a5:	89 04 24             	mov    %eax,(%esp)
  8018a8:	e8 52 ff ff ff       	call   8017ff <fd_close>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 18             	sub    $0x18,%esp
  8018b5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018b8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018c2:	00 
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	89 04 24             	mov    %eax,(%esp)
  8018c9:	e8 79 03 00 00       	call   801c47 <open>
  8018ce:	89 c3                	mov    %eax,%ebx
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 1b                	js     8018ef <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8018d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018db:	89 1c 24             	mov    %ebx,(%esp)
  8018de:	e8 b7 fc ff ff       	call   80159a <fstat>
  8018e3:	89 c6                	mov    %eax,%esi
	close(fd);
  8018e5:	89 1c 24             	mov    %ebx,(%esp)
  8018e8:	e8 91 ff ff ff       	call   80187e <close>
  8018ed:	89 f3                	mov    %esi,%ebx
	return r;
}
  8018ef:	89 d8                	mov    %ebx,%eax
  8018f1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018f4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018f7:	89 ec                	mov    %ebp,%esp
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 14             	sub    $0x14,%esp
  801902:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801907:	89 1c 24             	mov    %ebx,(%esp)
  80190a:	e8 6f ff ff ff       	call   80187e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80190f:	83 c3 01             	add    $0x1,%ebx
  801912:	83 fb 20             	cmp    $0x20,%ebx
  801915:	75 f0                	jne    801907 <close_all+0xc>
		close(i);
}
  801917:	83 c4 14             	add    $0x14,%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	83 ec 58             	sub    $0x58,%esp
  801923:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801926:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801929:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80192c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80192f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801932:	89 44 24 04          	mov    %eax,0x4(%esp)
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
  801939:	89 04 24             	mov    %eax,(%esp)
  80193c:	e8 7c fb ff ff       	call   8014bd <fd_lookup>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	85 c0                	test   %eax,%eax
  801945:	0f 88 e0 00 00 00    	js     801a2b <dup+0x10e>
		return r;
	close(newfdnum);
  80194b:	89 3c 24             	mov    %edi,(%esp)
  80194e:	e8 2b ff ff ff       	call   80187e <close>

	newfd = INDEX2FD(newfdnum);
  801953:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801959:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80195c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	e8 c9 fa ff ff       	call   801430 <fd2data>
  801967:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801969:	89 34 24             	mov    %esi,(%esp)
  80196c:	e8 bf fa ff ff       	call   801430 <fd2data>
  801971:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801974:	89 da                	mov    %ebx,%edx
  801976:	89 d8                	mov    %ebx,%eax
  801978:	c1 e8 16             	shr    $0x16,%eax
  80197b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801982:	a8 01                	test   $0x1,%al
  801984:	74 43                	je     8019c9 <dup+0xac>
  801986:	c1 ea 0c             	shr    $0xc,%edx
  801989:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801990:	a8 01                	test   $0x1,%al
  801992:	74 35                	je     8019c9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801994:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80199b:	25 07 0e 00 00       	and    $0xe07,%eax
  8019a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019b2:	00 
  8019b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019be:	e8 52 f8 ff ff       	call   801215 <sys_page_map>
  8019c3:	89 c3                	mov    %eax,%ebx
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 3f                	js     801a08 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019cc:	89 c2                	mov    %eax,%edx
  8019ce:	c1 ea 0c             	shr    $0xc,%edx
  8019d1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019d8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8019de:	89 54 24 10          	mov    %edx,0x10(%esp)
  8019e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019ed:	00 
  8019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f9:	e8 17 f8 ff ff       	call   801215 <sys_page_map>
  8019fe:	89 c3                	mov    %eax,%ebx
  801a00:	85 c0                	test   %eax,%eax
  801a02:	78 04                	js     801a08 <dup+0xeb>
  801a04:	89 fb                	mov    %edi,%ebx
  801a06:	eb 23                	jmp    801a2b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a08:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a13:	e8 91 f7 ff ff       	call   8011a9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a26:	e8 7e f7 ff ff       	call   8011a9 <sys_page_unmap>
	return r;
}
  801a2b:	89 d8                	mov    %ebx,%eax
  801a2d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a30:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a33:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a36:	89 ec                	mov    %ebp,%esp
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    
	...

00801a3c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 18             	sub    $0x18,%esp
  801a42:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a45:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a48:	89 c3                	mov    %eax,%ebx
  801a4a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a4c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a53:	75 11                	jne    801a66 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a55:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801a5c:	e8 df 02 00 00       	call   801d40 <ipc_find_env>
  801a61:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a66:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a6d:	00 
  801a6e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a75:	00 
  801a76:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a7a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a7f:	89 04 24             	mov    %eax,(%esp)
  801a82:	e8 04 03 00 00       	call   801d8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a87:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a8e:	00 
  801a8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9a:	e8 6a 03 00 00       	call   801e09 <ipc_recv>
}
  801a9f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801aa2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801aa5:	89 ec                	mov    %ebp,%esp
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac7:	b8 02 00 00 00       	mov    $0x2,%eax
  801acc:	e8 6b ff ff ff       	call   801a3c <fsipc>
}
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  801adc:	8b 40 0c             	mov    0xc(%eax),%eax
  801adf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae9:	b8 06 00 00 00       	mov    $0x6,%eax
  801aee:	e8 49 ff ff ff       	call   801a3c <fsipc>
}
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801afb:	ba 00 00 00 00       	mov    $0x0,%edx
  801b00:	b8 08 00 00 00       	mov    $0x8,%eax
  801b05:	e8 32 ff ff ff       	call   801a3c <fsipc>
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 14             	sub    $0x14,%esp
  801b13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b21:	ba 00 00 00 00       	mov    $0x0,%edx
  801b26:	b8 05 00 00 00       	mov    $0x5,%eax
  801b2b:	e8 0c ff ff ff       	call   801a3c <fsipc>
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 2b                	js     801b5f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b34:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b3b:	00 
  801b3c:	89 1c 24             	mov    %ebx,(%esp)
  801b3f:	e8 16 ef ff ff       	call   800a5a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b44:	a1 80 50 80 00       	mov    0x805080,%eax
  801b49:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b4f:	a1 84 50 80 00       	mov    0x805084,%eax
  801b54:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801b5a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801b5f:	83 c4 14             	add    $0x14,%esp
  801b62:	5b                   	pop    %ebx
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 18             	sub    $0x18,%esp
  801b6b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b73:	76 05                	jbe    801b7a <devfile_write+0x15>
  801b75:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  801b7d:	8b 52 0c             	mov    0xc(%edx),%edx
  801b80:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801b86:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b96:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801b9d:	e8 a3 f0 ff ff       	call   800c45 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba7:	b8 04 00 00 00       	mov    $0x4,%eax
  801bac:	e8 8b fe ff ff       	call   801a3c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bba:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbd:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801bc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd2:	b8 03 00 00 00       	mov    $0x3,%eax
  801bd7:	e8 60 fe ff ff       	call   801a3c <fsipc>
  801bdc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 17                	js     801bf9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801be2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bed:	00 
  801bee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf1:	89 04 24             	mov    %eax,(%esp)
  801bf4:	e8 4c f0 ff ff       	call   800c45 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801bf9:	89 d8                	mov    %ebx,%eax
  801bfb:	83 c4 14             	add    $0x14,%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	53                   	push   %ebx
  801c05:	83 ec 14             	sub    $0x14,%esp
  801c08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c0b:	89 1c 24             	mov    %ebx,(%esp)
  801c0e:	e8 fd ed ff ff       	call   800a10 <strlen>
  801c13:	89 c2                	mov    %eax,%edx
  801c15:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801c1a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801c20:	7f 1f                	jg     801c41 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801c22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c26:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c2d:	e8 28 ee ff ff       	call   800a5a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801c32:	ba 00 00 00 00       	mov    $0x0,%edx
  801c37:	b8 07 00 00 00       	mov    $0x7,%eax
  801c3c:	e8 fb fd ff ff       	call   801a3c <fsipc>
}
  801c41:	83 c4 14             	add    $0x14,%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 28             	sub    $0x28,%esp
  801c4d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c50:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c53:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801c56:	89 34 24             	mov    %esi,(%esp)
  801c59:	e8 b2 ed ff ff       	call   800a10 <strlen>
  801c5e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c63:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c68:	7f 6d                	jg     801cd7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801c6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6d:	89 04 24             	mov    %eax,(%esp)
  801c70:	e8 d6 f7 ff ff       	call   80144b <fd_alloc>
  801c75:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 5c                	js     801cd7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801c83:	89 34 24             	mov    %esi,(%esp)
  801c86:	e8 85 ed ff ff       	call   800a10 <strlen>
  801c8b:	83 c0 01             	add    $0x1,%eax
  801c8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c96:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c9d:	e8 a3 ef ff ff       	call   800c45 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801ca2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca5:	b8 01 00 00 00       	mov    $0x1,%eax
  801caa:	e8 8d fd ff ff       	call   801a3c <fsipc>
  801caf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	79 15                	jns    801cca <open+0x83>
             fd_close(fd,0);
  801cb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cbc:	00 
  801cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc0:	89 04 24             	mov    %eax,(%esp)
  801cc3:	e8 37 fb ff ff       	call   8017ff <fd_close>
             return r;
  801cc8:	eb 0d                	jmp    801cd7 <open+0x90>
        }
        return fd2num(fd);
  801cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccd:	89 04 24             	mov    %eax,(%esp)
  801cd0:	e8 4b f7 ff ff       	call   801420 <fd2num>
  801cd5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801cd7:	89 d8                	mov    %ebx,%eax
  801cd9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cdc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cdf:	89 ec                	mov    %ebp,%esp
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    
	...

00801ce4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	56                   	push   %esi
  801ce8:	53                   	push   %ebx
  801ce9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801cec:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cef:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801cf5:	e8 78 f6 ff ff       	call   801372 <sys_getenvid>
  801cfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cfd:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d01:	8b 55 08             	mov    0x8(%ebp),%edx
  801d04:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d10:	c7 04 24 70 25 80 00 	movl   $0x802570,(%esp)
  801d17:	e8 09 e4 ff ff       	call   800125 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d20:	8b 45 10             	mov    0x10(%ebp),%eax
  801d23:	89 04 24             	mov    %eax,(%esp)
  801d26:	e8 99 e3 ff ff       	call   8000c4 <vcprintf>
	cprintf("\n");
  801d2b:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  801d32:	e8 ee e3 ff ff       	call   800125 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d37:	cc                   	int3   
  801d38:	eb fd                	jmp    801d37 <_panic+0x53>
  801d3a:	00 00                	add    %al,(%eax)
  801d3c:	00 00                	add    %al,(%eax)
	...

00801d40 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d46:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801d4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d51:	39 ca                	cmp    %ecx,%edx
  801d53:	75 04                	jne    801d59 <ipc_find_env+0x19>
  801d55:	b0 00                	mov    $0x0,%al
  801d57:	eb 12                	jmp    801d6b <ipc_find_env+0x2b>
  801d59:	89 c2                	mov    %eax,%edx
  801d5b:	c1 e2 07             	shl    $0x7,%edx
  801d5e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801d65:	8b 12                	mov    (%edx),%edx
  801d67:	39 ca                	cmp    %ecx,%edx
  801d69:	75 10                	jne    801d7b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d6b:	89 c2                	mov    %eax,%edx
  801d6d:	c1 e2 07             	shl    $0x7,%edx
  801d70:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801d77:	8b 00                	mov    (%eax),%eax
  801d79:	eb 0e                	jmp    801d89 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d7b:	83 c0 01             	add    $0x1,%eax
  801d7e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d83:	75 d4                	jne    801d59 <ipc_find_env+0x19>
  801d85:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	57                   	push   %edi
  801d8f:	56                   	push   %esi
  801d90:	53                   	push   %ebx
  801d91:	83 ec 1c             	sub    $0x1c,%esp
  801d94:	8b 75 08             	mov    0x8(%ebp),%esi
  801d97:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801d9d:	85 db                	test   %ebx,%ebx
  801d9f:	74 19                	je     801dba <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801da1:	8b 45 14             	mov    0x14(%ebp),%eax
  801da4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801db0:	89 34 24             	mov    %esi,(%esp)
  801db3:	e8 6c f2 ff ff       	call   801024 <sys_ipc_try_send>
  801db8:	eb 1b                	jmp    801dd5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801dba:	8b 45 14             	mov    0x14(%ebp),%eax
  801dbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dc1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801dc8:	ee 
  801dc9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dcd:	89 34 24             	mov    %esi,(%esp)
  801dd0:	e8 4f f2 ff ff       	call   801024 <sys_ipc_try_send>
           if(ret == 0)
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	74 28                	je     801e01 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801dd9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ddc:	74 1c                	je     801dfa <ipc_send+0x6f>
              panic("ipc send error");
  801dde:	c7 44 24 08 94 25 80 	movl   $0x802594,0x8(%esp)
  801de5:	00 
  801de6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801ded:	00 
  801dee:	c7 04 24 a3 25 80 00 	movl   $0x8025a3,(%esp)
  801df5:	e8 ea fe ff ff       	call   801ce4 <_panic>
           sys_yield();
  801dfa:	e8 f1 f4 ff ff       	call   8012f0 <sys_yield>
        }
  801dff:	eb 9c                	jmp    801d9d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	56                   	push   %esi
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 10             	sub    $0x10,%esp
  801e11:	8b 75 08             	mov    0x8(%ebp),%esi
  801e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	75 0e                	jne    801e2c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e1e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e25:	e8 8f f1 ff ff       	call   800fb9 <sys_ipc_recv>
  801e2a:	eb 08                	jmp    801e34 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e2c:	89 04 24             	mov    %eax,(%esp)
  801e2f:	e8 85 f1 ff ff       	call   800fb9 <sys_ipc_recv>
        if(ret == 0){
  801e34:	85 c0                	test   %eax,%eax
  801e36:	75 26                	jne    801e5e <ipc_recv+0x55>
           if(from_env_store)
  801e38:	85 f6                	test   %esi,%esi
  801e3a:	74 0a                	je     801e46 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e3c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e41:	8b 40 78             	mov    0x78(%eax),%eax
  801e44:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801e46:	85 db                	test   %ebx,%ebx
  801e48:	74 0a                	je     801e54 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801e4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e52:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801e54:	a1 04 40 80 00       	mov    0x804004,%eax
  801e59:	8b 40 74             	mov    0x74(%eax),%eax
  801e5c:	eb 14                	jmp    801e72 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801e5e:	85 f6                	test   %esi,%esi
  801e60:	74 06                	je     801e68 <ipc_recv+0x5f>
              *from_env_store = 0;
  801e62:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801e68:	85 db                	test   %ebx,%ebx
  801e6a:	74 06                	je     801e72 <ipc_recv+0x69>
              *perm_store = 0;
  801e6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	5b                   	pop    %ebx
  801e76:	5e                   	pop    %esi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    
  801e79:	00 00                	add    %al,(%eax)
  801e7b:	00 00                	add    %al,(%eax)
  801e7d:	00 00                	add    %al,(%eax)
	...

00801e80 <__udivdi3>:
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	83 ec 10             	sub    $0x10,%esp
  801e88:	8b 45 14             	mov    0x14(%ebp),%eax
  801e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  801e8e:	8b 75 10             	mov    0x10(%ebp),%esi
  801e91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e94:	85 c0                	test   %eax,%eax
  801e96:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801e99:	75 35                	jne    801ed0 <__udivdi3+0x50>
  801e9b:	39 fe                	cmp    %edi,%esi
  801e9d:	77 61                	ja     801f00 <__udivdi3+0x80>
  801e9f:	85 f6                	test   %esi,%esi
  801ea1:	75 0b                	jne    801eae <__udivdi3+0x2e>
  801ea3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea8:	31 d2                	xor    %edx,%edx
  801eaa:	f7 f6                	div    %esi
  801eac:	89 c6                	mov    %eax,%esi
  801eae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801eb1:	31 d2                	xor    %edx,%edx
  801eb3:	89 f8                	mov    %edi,%eax
  801eb5:	f7 f6                	div    %esi
  801eb7:	89 c7                	mov    %eax,%edi
  801eb9:	89 c8                	mov    %ecx,%eax
  801ebb:	f7 f6                	div    %esi
  801ebd:	89 c1                	mov    %eax,%ecx
  801ebf:	89 fa                	mov    %edi,%edx
  801ec1:	89 c8                	mov    %ecx,%eax
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	5e                   	pop    %esi
  801ec7:	5f                   	pop    %edi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    
  801eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ed0:	39 f8                	cmp    %edi,%eax
  801ed2:	77 1c                	ja     801ef0 <__udivdi3+0x70>
  801ed4:	0f bd d0             	bsr    %eax,%edx
  801ed7:	83 f2 1f             	xor    $0x1f,%edx
  801eda:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801edd:	75 39                	jne    801f18 <__udivdi3+0x98>
  801edf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ee2:	0f 86 a0 00 00 00    	jbe    801f88 <__udivdi3+0x108>
  801ee8:	39 f8                	cmp    %edi,%eax
  801eea:	0f 82 98 00 00 00    	jb     801f88 <__udivdi3+0x108>
  801ef0:	31 ff                	xor    %edi,%edi
  801ef2:	31 c9                	xor    %ecx,%ecx
  801ef4:	89 c8                	mov    %ecx,%eax
  801ef6:	89 fa                	mov    %edi,%edx
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	5e                   	pop    %esi
  801efc:	5f                   	pop    %edi
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    
  801eff:	90                   	nop
  801f00:	89 d1                	mov    %edx,%ecx
  801f02:	89 fa                	mov    %edi,%edx
  801f04:	89 c8                	mov    %ecx,%eax
  801f06:	31 ff                	xor    %edi,%edi
  801f08:	f7 f6                	div    %esi
  801f0a:	89 c1                	mov    %eax,%ecx
  801f0c:	89 fa                	mov    %edi,%edx
  801f0e:	89 c8                	mov    %ecx,%eax
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	5e                   	pop    %esi
  801f14:	5f                   	pop    %edi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    
  801f17:	90                   	nop
  801f18:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f1c:	89 f2                	mov    %esi,%edx
  801f1e:	d3 e0                	shl    %cl,%eax
  801f20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f23:	b8 20 00 00 00       	mov    $0x20,%eax
  801f28:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f2b:	89 c1                	mov    %eax,%ecx
  801f2d:	d3 ea                	shr    %cl,%edx
  801f2f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f33:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f36:	d3 e6                	shl    %cl,%esi
  801f38:	89 c1                	mov    %eax,%ecx
  801f3a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f3d:	89 fe                	mov    %edi,%esi
  801f3f:	d3 ee                	shr    %cl,%esi
  801f41:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f45:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f4b:	d3 e7                	shl    %cl,%edi
  801f4d:	89 c1                	mov    %eax,%ecx
  801f4f:	d3 ea                	shr    %cl,%edx
  801f51:	09 d7                	or     %edx,%edi
  801f53:	89 f2                	mov    %esi,%edx
  801f55:	89 f8                	mov    %edi,%eax
  801f57:	f7 75 ec             	divl   -0x14(%ebp)
  801f5a:	89 d6                	mov    %edx,%esi
  801f5c:	89 c7                	mov    %eax,%edi
  801f5e:	f7 65 e8             	mull   -0x18(%ebp)
  801f61:	39 d6                	cmp    %edx,%esi
  801f63:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f66:	72 30                	jb     801f98 <__udivdi3+0x118>
  801f68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f6b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f6f:	d3 e2                	shl    %cl,%edx
  801f71:	39 c2                	cmp    %eax,%edx
  801f73:	73 05                	jae    801f7a <__udivdi3+0xfa>
  801f75:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801f78:	74 1e                	je     801f98 <__udivdi3+0x118>
  801f7a:	89 f9                	mov    %edi,%ecx
  801f7c:	31 ff                	xor    %edi,%edi
  801f7e:	e9 71 ff ff ff       	jmp    801ef4 <__udivdi3+0x74>
  801f83:	90                   	nop
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	31 ff                	xor    %edi,%edi
  801f8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801f8f:	e9 60 ff ff ff       	jmp    801ef4 <__udivdi3+0x74>
  801f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f98:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801f9b:	31 ff                	xor    %edi,%edi
  801f9d:	89 c8                	mov    %ecx,%eax
  801f9f:	89 fa                	mov    %edi,%edx
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
	...

00801fb0 <__umoddi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	57                   	push   %edi
  801fb4:	56                   	push   %esi
  801fb5:	83 ec 20             	sub    $0x20,%esp
  801fb8:	8b 55 14             	mov    0x14(%ebp),%edx
  801fbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fbe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801fc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc4:	85 d2                	test   %edx,%edx
  801fc6:	89 c8                	mov    %ecx,%eax
  801fc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fcb:	75 13                	jne    801fe0 <__umoddi3+0x30>
  801fcd:	39 f7                	cmp    %esi,%edi
  801fcf:	76 3f                	jbe    802010 <__umoddi3+0x60>
  801fd1:	89 f2                	mov    %esi,%edx
  801fd3:	f7 f7                	div    %edi
  801fd5:	89 d0                	mov    %edx,%eax
  801fd7:	31 d2                	xor    %edx,%edx
  801fd9:	83 c4 20             	add    $0x20,%esp
  801fdc:	5e                   	pop    %esi
  801fdd:	5f                   	pop    %edi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    
  801fe0:	39 f2                	cmp    %esi,%edx
  801fe2:	77 4c                	ja     802030 <__umoddi3+0x80>
  801fe4:	0f bd ca             	bsr    %edx,%ecx
  801fe7:	83 f1 1f             	xor    $0x1f,%ecx
  801fea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801fed:	75 51                	jne    802040 <__umoddi3+0x90>
  801fef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801ff2:	0f 87 e0 00 00 00    	ja     8020d8 <__umoddi3+0x128>
  801ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffb:	29 f8                	sub    %edi,%eax
  801ffd:	19 d6                	sbb    %edx,%esi
  801fff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802002:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802005:	89 f2                	mov    %esi,%edx
  802007:	83 c4 20             	add    $0x20,%esp
  80200a:	5e                   	pop    %esi
  80200b:	5f                   	pop    %edi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    
  80200e:	66 90                	xchg   %ax,%ax
  802010:	85 ff                	test   %edi,%edi
  802012:	75 0b                	jne    80201f <__umoddi3+0x6f>
  802014:	b8 01 00 00 00       	mov    $0x1,%eax
  802019:	31 d2                	xor    %edx,%edx
  80201b:	f7 f7                	div    %edi
  80201d:	89 c7                	mov    %eax,%edi
  80201f:	89 f0                	mov    %esi,%eax
  802021:	31 d2                	xor    %edx,%edx
  802023:	f7 f7                	div    %edi
  802025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802028:	f7 f7                	div    %edi
  80202a:	eb a9                	jmp    801fd5 <__umoddi3+0x25>
  80202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	83 c4 20             	add    $0x20,%esp
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
  80203b:	90                   	nop
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802044:	d3 e2                	shl    %cl,%edx
  802046:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802049:	ba 20 00 00 00       	mov    $0x20,%edx
  80204e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802051:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802054:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802058:	89 fa                	mov    %edi,%edx
  80205a:	d3 ea                	shr    %cl,%edx
  80205c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802060:	0b 55 f4             	or     -0xc(%ebp),%edx
  802063:	d3 e7                	shl    %cl,%edi
  802065:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802069:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80206c:	89 f2                	mov    %esi,%edx
  80206e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802071:	89 c7                	mov    %eax,%edi
  802073:	d3 ea                	shr    %cl,%edx
  802075:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802079:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80207c:	89 c2                	mov    %eax,%edx
  80207e:	d3 e6                	shl    %cl,%esi
  802080:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802084:	d3 ea                	shr    %cl,%edx
  802086:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80208a:	09 d6                	or     %edx,%esi
  80208c:	89 f0                	mov    %esi,%eax
  80208e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802091:	d3 e7                	shl    %cl,%edi
  802093:	89 f2                	mov    %esi,%edx
  802095:	f7 75 f4             	divl   -0xc(%ebp)
  802098:	89 d6                	mov    %edx,%esi
  80209a:	f7 65 e8             	mull   -0x18(%ebp)
  80209d:	39 d6                	cmp    %edx,%esi
  80209f:	72 2b                	jb     8020cc <__umoddi3+0x11c>
  8020a1:	39 c7                	cmp    %eax,%edi
  8020a3:	72 23                	jb     8020c8 <__umoddi3+0x118>
  8020a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020a9:	29 c7                	sub    %eax,%edi
  8020ab:	19 d6                	sbb    %edx,%esi
  8020ad:	89 f0                	mov    %esi,%eax
  8020af:	89 f2                	mov    %esi,%edx
  8020b1:	d3 ef                	shr    %cl,%edi
  8020b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020b7:	d3 e0                	shl    %cl,%eax
  8020b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020bd:	09 f8                	or     %edi,%eax
  8020bf:	d3 ea                	shr    %cl,%edx
  8020c1:	83 c4 20             	add    $0x20,%esp
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	39 d6                	cmp    %edx,%esi
  8020ca:	75 d9                	jne    8020a5 <__umoddi3+0xf5>
  8020cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8020d2:	eb d1                	jmp    8020a5 <__umoddi3+0xf5>
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	0f 82 18 ff ff ff    	jb     801ff8 <__umoddi3+0x48>
  8020e0:	e9 1d ff ff ff       	jmp    802002 <__umoddi3+0x52>
