
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  800046:	c7 04 24 5e 00 80 00 	movl   $0x80005e,(%esp)
  80004d:	e8 12 15 00 00       	call   801564 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800052:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800059:	00 00 00 
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 18             	sub    $0x18,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800067:	8b 50 04             	mov    0x4(%eax),%edx
  80006a:	83 e2 07             	and    $0x7,%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	8b 00                	mov    (%eax),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  80007e:	e8 e2 00 00 00       	call   800165 <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 2f 14 00 00       	call   8014b7 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 67 14 00 00       	call   8014f7 <sys_env_destroy>
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a6:	e8 0c 14 00 00       	call   8014b7 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	89 c2                	mov    %eax,%edx
  8000b2:	c1 e2 07             	shl    $0x7,%edx
  8000b5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000bc:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c1:	85 f6                	test   %esi,%esi
  8000c3:	7e 07                	jle    8000cc <libmain+0x38>
		binaryname = argv[0];
  8000c5:	8b 03                	mov    (%ebx),%eax
  8000c7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 68 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0b 00 00 00       	call   8000e8 <exit>
}
  8000dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    
	...

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ee:	e8 c8 19 00 00       	call   801abb <close_all>
	sys_env_destroy(0);
  8000f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fa:	e8 f8 13 00 00       	call   8014f7 <sys_env_destroy>
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800114:	00 00 00 
	b.cnt = 0;
  800117:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800121:	8b 45 0c             	mov    0xc(%ebp),%eax
  800124:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800128:	8b 45 08             	mov    0x8(%ebp),%eax
  80012b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	c7 04 24 7f 01 80 00 	movl   $0x80017f,(%esp)
  800140:	e8 d7 01 00 00       	call   80031c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800145:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800155:	89 04 24             	mov    %eax,(%esp)
  800158:	e8 6f 0d 00 00       	call   800ecc <sys_cputs>

	return b.cnt;
}
  80015d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80016b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80016e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	89 04 24             	mov    %eax,(%esp)
  800178:	e8 87 ff ff ff       	call   800104 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	53                   	push   %ebx
  800183:	83 ec 14             	sub    $0x14,%esp
  800186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800189:	8b 03                	mov    (%ebx),%eax
  80018b:	8b 55 08             	mov    0x8(%ebp),%edx
  80018e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800192:	83 c0 01             	add    $0x1,%eax
  800195:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800197:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019c:	75 19                	jne    8001b7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80019e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a5:	00 
  8001a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a9:	89 04 24             	mov    %eax,(%esp)
  8001ac:	e8 1b 0d 00 00       	call   800ecc <sys_cputs>
		b->idx = 0;
  8001b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bb:	83 c4 14             	add    $0x14,%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    
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
  80023f:	e8 4c 23 00 00       	call   802590 <__udivdi3>
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
  8002a7:	e8 14 24 00 00       	call   8026c0 <__umoddi3>
  8002ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b0:	0f be 80 26 28 80 00 	movsbl 0x802826(%eax),%eax
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
  80039a:	ff 24 95 00 2a 80 00 	jmp    *0x802a00(,%edx,4)
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
  800457:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	75 26                	jne    800488 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 37 28 80 	movl   $0x802837,0x8(%esp)
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
  80048c:	c7 44 24 08 7e 2c 80 	movl   $0x802c7e,0x8(%esp)
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
  8004ca:	be 40 28 80 00       	mov    $0x802840,%esi
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
  800774:	e8 17 1e 00 00       	call   802590 <__udivdi3>
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
  8007c0:	e8 fb 1e 00 00       	call   8026c0 <__umoddi3>
  8007c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c9:	0f be 80 26 28 80 00 	movsbl 0x802826(%eax),%eax
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
  800875:	c7 44 24 0c 5c 29 80 	movl   $0x80295c,0xc(%esp)
  80087c:	00 
  80087d:	c7 44 24 08 7e 2c 80 	movl   $0x802c7e,0x8(%esp)
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
  8008ab:	c7 44 24 0c 94 29 80 	movl   $0x802994,0xc(%esp)
  8008b2:	00 
  8008b3:	c7 44 24 08 7e 2c 80 	movl   $0x802c7e,0x8(%esp)
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
  80093f:	e8 7c 1d 00 00       	call   8026c0 <__umoddi3>
  800944:	89 74 24 04          	mov    %esi,0x4(%esp)
  800948:	0f be 80 26 28 80 00 	movsbl 0x802826(%eax),%eax
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
  800981:	e8 3a 1d 00 00       	call   8026c0 <__umoddi3>
  800986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098a:	0f be 80 26 28 80 00 	movsbl 0x802826(%eax),%eax
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

00800f0b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  800f18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1d:	b8 13 00 00 00       	mov    $0x13,%eax
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
  800f25:	89 cb                	mov    %ecx,%ebx
  800f27:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800f41:	8b 1c 24             	mov    (%esp),%ebx
  800f44:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f48:	89 ec                	mov    %ebp,%esp
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 08             	sub    $0x8,%esp
  800f52:	89 1c 24             	mov    %ebx,(%esp)
  800f55:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5e:	b8 12 00 00 00       	mov    $0x12,%eax
  800f63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f66:	8b 55 08             	mov    0x8(%ebp),%edx
  800f69:	89 df                	mov    %ebx,%edi
  800f6b:	51                   	push   %ecx
  800f6c:	52                   	push   %edx
  800f6d:	53                   	push   %ebx
  800f6e:	54                   	push   %esp
  800f6f:	55                   	push   %ebp
  800f70:	56                   	push   %esi
  800f71:	57                   	push   %edi
  800f72:	54                   	push   %esp
  800f73:	5d                   	pop    %ebp
  800f74:	8d 35 7c 0f 80 00    	lea    0x800f7c,%esi
  800f7a:	0f 34                	sysenter 
  800f7c:	5f                   	pop    %edi
  800f7d:	5e                   	pop    %esi
  800f7e:	5d                   	pop    %ebp
  800f7f:	5c                   	pop    %esp
  800f80:	5b                   	pop    %ebx
  800f81:	5a                   	pop    %edx
  800f82:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800f83:	8b 1c 24             	mov    (%esp),%ebx
  800f86:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f8a:	89 ec                	mov    %ebp,%esp
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 08             	sub    $0x8,%esp
  800f94:	89 1c 24             	mov    %ebx,(%esp)
  800f97:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa0:	b8 11 00 00 00       	mov    $0x11,%eax
  800fa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fab:	89 df                	mov    %ebx,%edi
  800fad:	51                   	push   %ecx
  800fae:	52                   	push   %edx
  800faf:	53                   	push   %ebx
  800fb0:	54                   	push   %esp
  800fb1:	55                   	push   %ebp
  800fb2:	56                   	push   %esi
  800fb3:	57                   	push   %edi
  800fb4:	54                   	push   %esp
  800fb5:	5d                   	pop    %ebp
  800fb6:	8d 35 be 0f 80 00    	lea    0x800fbe,%esi
  800fbc:	0f 34                	sysenter 
  800fbe:	5f                   	pop    %edi
  800fbf:	5e                   	pop    %esi
  800fc0:	5d                   	pop    %ebp
  800fc1:	5c                   	pop    %esp
  800fc2:	5b                   	pop    %ebx
  800fc3:	5a                   	pop    %edx
  800fc4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800fc5:	8b 1c 24             	mov    (%esp),%ebx
  800fc8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fcc:	89 ec                	mov    %ebp,%esp
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 08             	sub    $0x8,%esp
  800fd6:	89 1c 24             	mov    %ebx,(%esp)
  800fd9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fdd:	b8 10 00 00 00       	mov    $0x10,%eax
  800fe2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	51                   	push   %ecx
  800fef:	52                   	push   %edx
  800ff0:	53                   	push   %ebx
  800ff1:	54                   	push   %esp
  800ff2:	55                   	push   %ebp
  800ff3:	56                   	push   %esi
  800ff4:	57                   	push   %edi
  800ff5:	54                   	push   %esp
  800ff6:	5d                   	pop    %ebp
  800ff7:	8d 35 ff 0f 80 00    	lea    0x800fff,%esi
  800ffd:	0f 34                	sysenter 
  800fff:	5f                   	pop    %edi
  801000:	5e                   	pop    %esi
  801001:	5d                   	pop    %ebp
  801002:	5c                   	pop    %esp
  801003:	5b                   	pop    %ebx
  801004:	5a                   	pop    %edx
  801005:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801006:	8b 1c 24             	mov    (%esp),%ebx
  801009:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80100d:	89 ec                	mov    %ebp,%esp
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	83 ec 28             	sub    $0x28,%esp
  801017:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80101a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80101d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801022:	b8 0f 00 00 00       	mov    $0xf,%eax
  801027:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102a:	8b 55 08             	mov    0x8(%ebp),%edx
  80102d:	89 df                	mov    %ebx,%edi
  80102f:	51                   	push   %ecx
  801030:	52                   	push   %edx
  801031:	53                   	push   %ebx
  801032:	54                   	push   %esp
  801033:	55                   	push   %ebp
  801034:	56                   	push   %esi
  801035:	57                   	push   %edi
  801036:	54                   	push   %esp
  801037:	5d                   	pop    %ebp
  801038:	8d 35 40 10 80 00    	lea    0x801040,%esi
  80103e:	0f 34                	sysenter 
  801040:	5f                   	pop    %edi
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	5c                   	pop    %esp
  801044:	5b                   	pop    %ebx
  801045:	5a                   	pop    %edx
  801046:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801047:	85 c0                	test   %eax,%eax
  801049:	7e 28                	jle    801073 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80104f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801056:	00 
  801057:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  80105e:	00 
  80105f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801066:	00 
  801067:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  80106e:	e8 41 13 00 00       	call   8023b4 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801073:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801076:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801079:	89 ec                	mov    %ebp,%esp
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	89 1c 24             	mov    %ebx,(%esp)
  801086:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108a:	ba 00 00 00 00       	mov    $0x0,%edx
  80108f:	b8 15 00 00 00       	mov    $0x15,%eax
  801094:	89 d1                	mov    %edx,%ecx
  801096:	89 d3                	mov    %edx,%ebx
  801098:	89 d7                	mov    %edx,%edi
  80109a:	51                   	push   %ecx
  80109b:	52                   	push   %edx
  80109c:	53                   	push   %ebx
  80109d:	54                   	push   %esp
  80109e:	55                   	push   %ebp
  80109f:	56                   	push   %esi
  8010a0:	57                   	push   %edi
  8010a1:	54                   	push   %esp
  8010a2:	5d                   	pop    %ebp
  8010a3:	8d 35 ab 10 80 00    	lea    0x8010ab,%esi
  8010a9:	0f 34                	sysenter 
  8010ab:	5f                   	pop    %edi
  8010ac:	5e                   	pop    %esi
  8010ad:	5d                   	pop    %ebp
  8010ae:	5c                   	pop    %esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5a                   	pop    %edx
  8010b1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010b2:	8b 1c 24             	mov    (%esp),%ebx
  8010b5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b9:	89 ec                	mov    %ebp,%esp
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	83 ec 08             	sub    $0x8,%esp
  8010c3:	89 1c 24             	mov    %ebx,(%esp)
  8010c6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010cf:	b8 14 00 00 00       	mov    $0x14,%eax
  8010d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d7:	89 cb                	mov    %ecx,%ebx
  8010d9:	89 cf                	mov    %ecx,%edi
  8010db:	51                   	push   %ecx
  8010dc:	52                   	push   %edx
  8010dd:	53                   	push   %ebx
  8010de:	54                   	push   %esp
  8010df:	55                   	push   %ebp
  8010e0:	56                   	push   %esi
  8010e1:	57                   	push   %edi
  8010e2:	54                   	push   %esp
  8010e3:	5d                   	pop    %ebp
  8010e4:	8d 35 ec 10 80 00    	lea    0x8010ec,%esi
  8010ea:	0f 34                	sysenter 
  8010ec:	5f                   	pop    %edi
  8010ed:	5e                   	pop    %esi
  8010ee:	5d                   	pop    %ebp
  8010ef:	5c                   	pop    %esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5a                   	pop    %edx
  8010f2:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010f3:	8b 1c 24             	mov    (%esp),%ebx
  8010f6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010fa:	89 ec                	mov    %ebp,%esp
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	83 ec 28             	sub    $0x28,%esp
  801104:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801107:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80110a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801114:	8b 55 08             	mov    0x8(%ebp),%edx
  801117:	89 cb                	mov    %ecx,%ebx
  801119:	89 cf                	mov    %ecx,%edi
  80111b:	51                   	push   %ecx
  80111c:	52                   	push   %edx
  80111d:	53                   	push   %ebx
  80111e:	54                   	push   %esp
  80111f:	55                   	push   %ebp
  801120:	56                   	push   %esi
  801121:	57                   	push   %edi
  801122:	54                   	push   %esp
  801123:	5d                   	pop    %ebp
  801124:	8d 35 2c 11 80 00    	lea    0x80112c,%esi
  80112a:	0f 34                	sysenter 
  80112c:	5f                   	pop    %edi
  80112d:	5e                   	pop    %esi
  80112e:	5d                   	pop    %ebp
  80112f:	5c                   	pop    %esp
  801130:	5b                   	pop    %ebx
  801131:	5a                   	pop    %edx
  801132:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801133:	85 c0                	test   %eax,%eax
  801135:	7e 28                	jle    80115f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801142:	00 
  801143:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  80114a:	00 
  80114b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801152:	00 
  801153:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  80115a:	e8 55 12 00 00       	call   8023b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80115f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801162:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801165:	89 ec                	mov    %ebp,%esp
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	89 1c 24             	mov    %ebx,(%esp)
  801172:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801176:	b8 0d 00 00 00       	mov    $0xd,%eax
  80117b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80117e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	51                   	push   %ecx
  801188:	52                   	push   %edx
  801189:	53                   	push   %ebx
  80118a:	54                   	push   %esp
  80118b:	55                   	push   %ebp
  80118c:	56                   	push   %esi
  80118d:	57                   	push   %edi
  80118e:	54                   	push   %esp
  80118f:	5d                   	pop    %ebp
  801190:	8d 35 98 11 80 00    	lea    0x801198,%esi
  801196:	0f 34                	sysenter 
  801198:	5f                   	pop    %edi
  801199:	5e                   	pop    %esi
  80119a:	5d                   	pop    %ebp
  80119b:	5c                   	pop    %esp
  80119c:	5b                   	pop    %ebx
  80119d:	5a                   	pop    %edx
  80119e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80119f:	8b 1c 24             	mov    (%esp),%ebx
  8011a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011a6:	89 ec                	mov    %ebp,%esp
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 28             	sub    $0x28,%esp
  8011b0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011b3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c6:	89 df                	mov    %ebx,%edi
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
  8011e2:	7e 28                	jle    80120c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8011ef:	00 
  8011f0:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  8011f7:	00 
  8011f8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011ff:	00 
  801200:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  801207:	e8 a8 11 00 00       	call   8023b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80120c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80120f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801212:	89 ec                	mov    %ebp,%esp
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  801222:	bb 00 00 00 00       	mov    $0x0,%ebx
  801227:	b8 0a 00 00 00       	mov    $0xa,%eax
  80122c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122f:	8b 55 08             	mov    0x8(%ebp),%edx
  801232:	89 df                	mov    %ebx,%edi
  801234:	51                   	push   %ecx
  801235:	52                   	push   %edx
  801236:	53                   	push   %ebx
  801237:	54                   	push   %esp
  801238:	55                   	push   %ebp
  801239:	56                   	push   %esi
  80123a:	57                   	push   %edi
  80123b:	54                   	push   %esp
  80123c:	5d                   	pop    %ebp
  80123d:	8d 35 45 12 80 00    	lea    0x801245,%esi
  801243:	0f 34                	sysenter 
  801245:	5f                   	pop    %edi
  801246:	5e                   	pop    %esi
  801247:	5d                   	pop    %ebp
  801248:	5c                   	pop    %esp
  801249:	5b                   	pop    %ebx
  80124a:	5a                   	pop    %edx
  80124b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	7e 28                	jle    801278 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801250:	89 44 24 10          	mov    %eax,0x10(%esp)
  801254:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80125b:	00 
  80125c:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80126b:	00 
  80126c:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  801273:	e8 3c 11 00 00       	call   8023b4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801278:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80127b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80127e:	89 ec                	mov    %ebp,%esp
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 28             	sub    $0x28,%esp
  801288:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80128b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80128e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801293:	b8 09 00 00 00       	mov    $0x9,%eax
  801298:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129b:	8b 55 08             	mov    0x8(%ebp),%edx
  80129e:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	7e 28                	jle    8012e4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012c7:	00 
  8012c8:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  8012cf:	00 
  8012d0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012d7:	00 
  8012d8:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  8012df:	e8 d0 10 00 00       	call   8023b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012e4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012e7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ea:	89 ec                	mov    %ebp,%esp
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	83 ec 28             	sub    $0x28,%esp
  8012f4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012f7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ff:	b8 07 00 00 00       	mov    $0x7,%eax
  801304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801307:	8b 55 08             	mov    0x8(%ebp),%edx
  80130a:	89 df                	mov    %ebx,%edi
  80130c:	51                   	push   %ecx
  80130d:	52                   	push   %edx
  80130e:	53                   	push   %ebx
  80130f:	54                   	push   %esp
  801310:	55                   	push   %ebp
  801311:	56                   	push   %esi
  801312:	57                   	push   %edi
  801313:	54                   	push   %esp
  801314:	5d                   	pop    %ebp
  801315:	8d 35 1d 13 80 00    	lea    0x80131d,%esi
  80131b:	0f 34                	sysenter 
  80131d:	5f                   	pop    %edi
  80131e:	5e                   	pop    %esi
  80131f:	5d                   	pop    %ebp
  801320:	5c                   	pop    %esp
  801321:	5b                   	pop    %ebx
  801322:	5a                   	pop    %edx
  801323:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801324:	85 c0                	test   %eax,%eax
  801326:	7e 28                	jle    801350 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801328:	89 44 24 10          	mov    %eax,0x10(%esp)
  80132c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801333:	00 
  801334:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  80133b:	00 
  80133c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801343:	00 
  801344:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  80134b:	e8 64 10 00 00       	call   8023b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801350:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801353:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801356:	89 ec                	mov    %ebp,%esp
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	83 ec 28             	sub    $0x28,%esp
  801360:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801363:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801366:	8b 7d 18             	mov    0x18(%ebp),%edi
  801369:	0b 7d 14             	or     0x14(%ebp),%edi
  80136c:	b8 06 00 00 00       	mov    $0x6,%eax
  801371:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801374:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801377:	8b 55 08             	mov    0x8(%ebp),%edx
  80137a:	51                   	push   %ecx
  80137b:	52                   	push   %edx
  80137c:	53                   	push   %ebx
  80137d:	54                   	push   %esp
  80137e:	55                   	push   %ebp
  80137f:	56                   	push   %esi
  801380:	57                   	push   %edi
  801381:	54                   	push   %esp
  801382:	5d                   	pop    %ebp
  801383:	8d 35 8b 13 80 00    	lea    0x80138b,%esi
  801389:	0f 34                	sysenter 
  80138b:	5f                   	pop    %edi
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	5c                   	pop    %esp
  80138f:	5b                   	pop    %ebx
  801390:	5a                   	pop    %edx
  801391:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801392:	85 c0                	test   %eax,%eax
  801394:	7e 28                	jle    8013be <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801396:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013a1:	00 
  8013a2:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  8013a9:	00 
  8013aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013b1:	00 
  8013b2:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  8013b9:	e8 f6 0f 00 00       	call   8023b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8013be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013c4:	89 ec                	mov    %ebp,%esp
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 28             	sub    $0x28,%esp
  8013ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013d1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8013d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e7:	51                   	push   %ecx
  8013e8:	52                   	push   %edx
  8013e9:	53                   	push   %ebx
  8013ea:	54                   	push   %esp
  8013eb:	55                   	push   %ebp
  8013ec:	56                   	push   %esi
  8013ed:	57                   	push   %edi
  8013ee:	54                   	push   %esp
  8013ef:	5d                   	pop    %ebp
  8013f0:	8d 35 f8 13 80 00    	lea    0x8013f8,%esi
  8013f6:	0f 34                	sysenter 
  8013f8:	5f                   	pop    %edi
  8013f9:	5e                   	pop    %esi
  8013fa:	5d                   	pop    %ebp
  8013fb:	5c                   	pop    %esp
  8013fc:	5b                   	pop    %ebx
  8013fd:	5a                   	pop    %edx
  8013fe:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013ff:	85 c0                	test   %eax,%eax
  801401:	7e 28                	jle    80142b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801403:	89 44 24 10          	mov    %eax,0x10(%esp)
  801407:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80140e:	00 
  80140f:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  801416:	00 
  801417:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80141e:	00 
  80141f:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  801426:	e8 89 0f 00 00       	call   8023b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80142b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80142e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801431:	89 ec                	mov    %ebp,%esp
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    

00801435 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	89 1c 24             	mov    %ebx,(%esp)
  80143e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801442:	ba 00 00 00 00       	mov    $0x0,%edx
  801447:	b8 0c 00 00 00       	mov    $0xc,%eax
  80144c:	89 d1                	mov    %edx,%ecx
  80144e:	89 d3                	mov    %edx,%ebx
  801450:	89 d7                	mov    %edx,%edi
  801452:	51                   	push   %ecx
  801453:	52                   	push   %edx
  801454:	53                   	push   %ebx
  801455:	54                   	push   %esp
  801456:	55                   	push   %ebp
  801457:	56                   	push   %esi
  801458:	57                   	push   %edi
  801459:	54                   	push   %esp
  80145a:	5d                   	pop    %ebp
  80145b:	8d 35 63 14 80 00    	lea    0x801463,%esi
  801461:	0f 34                	sysenter 
  801463:	5f                   	pop    %edi
  801464:	5e                   	pop    %esi
  801465:	5d                   	pop    %ebp
  801466:	5c                   	pop    %esp
  801467:	5b                   	pop    %ebx
  801468:	5a                   	pop    %edx
  801469:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80146a:	8b 1c 24             	mov    (%esp),%ebx
  80146d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801471:	89 ec                	mov    %ebp,%esp
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	89 1c 24             	mov    %ebx,(%esp)
  80147e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801482:	bb 00 00 00 00       	mov    $0x0,%ebx
  801487:	b8 04 00 00 00       	mov    $0x4,%eax
  80148c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148f:	8b 55 08             	mov    0x8(%ebp),%edx
  801492:	89 df                	mov    %ebx,%edi
  801494:	51                   	push   %ecx
  801495:	52                   	push   %edx
  801496:	53                   	push   %ebx
  801497:	54                   	push   %esp
  801498:	55                   	push   %ebp
  801499:	56                   	push   %esi
  80149a:	57                   	push   %edi
  80149b:	54                   	push   %esp
  80149c:	5d                   	pop    %ebp
  80149d:	8d 35 a5 14 80 00    	lea    0x8014a5,%esi
  8014a3:	0f 34                	sysenter 
  8014a5:	5f                   	pop    %edi
  8014a6:	5e                   	pop    %esi
  8014a7:	5d                   	pop    %ebp
  8014a8:	5c                   	pop    %esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5a                   	pop    %edx
  8014ab:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8014ac:	8b 1c 24             	mov    (%esp),%ebx
  8014af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014b3:	89 ec                	mov    %ebp,%esp
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	89 1c 24             	mov    %ebx,(%esp)
  8014c0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014ce:	89 d1                	mov    %edx,%ecx
  8014d0:	89 d3                	mov    %edx,%ebx
  8014d2:	89 d7                	mov    %edx,%edi
  8014d4:	51                   	push   %ecx
  8014d5:	52                   	push   %edx
  8014d6:	53                   	push   %ebx
  8014d7:	54                   	push   %esp
  8014d8:	55                   	push   %ebp
  8014d9:	56                   	push   %esi
  8014da:	57                   	push   %edi
  8014db:	54                   	push   %esp
  8014dc:	5d                   	pop    %ebp
  8014dd:	8d 35 e5 14 80 00    	lea    0x8014e5,%esi
  8014e3:	0f 34                	sysenter 
  8014e5:	5f                   	pop    %edi
  8014e6:	5e                   	pop    %esi
  8014e7:	5d                   	pop    %ebp
  8014e8:	5c                   	pop    %esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5a                   	pop    %edx
  8014eb:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014ec:	8b 1c 24             	mov    (%esp),%ebx
  8014ef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014f3:	89 ec                	mov    %ebp,%esp
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 28             	sub    $0x28,%esp
  8014fd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801500:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801503:	b9 00 00 00 00       	mov    $0x0,%ecx
  801508:	b8 03 00 00 00       	mov    $0x3,%eax
  80150d:	8b 55 08             	mov    0x8(%ebp),%edx
  801510:	89 cb                	mov    %ecx,%ebx
  801512:	89 cf                	mov    %ecx,%edi
  801514:	51                   	push   %ecx
  801515:	52                   	push   %edx
  801516:	53                   	push   %ebx
  801517:	54                   	push   %esp
  801518:	55                   	push   %ebp
  801519:	56                   	push   %esi
  80151a:	57                   	push   %edi
  80151b:	54                   	push   %esp
  80151c:	5d                   	pop    %ebp
  80151d:	8d 35 25 15 80 00    	lea    0x801525,%esi
  801523:	0f 34                	sysenter 
  801525:	5f                   	pop    %edi
  801526:	5e                   	pop    %esi
  801527:	5d                   	pop    %ebp
  801528:	5c                   	pop    %esp
  801529:	5b                   	pop    %ebx
  80152a:	5a                   	pop    %edx
  80152b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80152c:	85 c0                	test   %eax,%eax
  80152e:	7e 28                	jle    801558 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801530:	89 44 24 10          	mov    %eax,0x10(%esp)
  801534:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80153b:	00 
  80153c:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  801543:	00 
  801544:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80154b:	00 
  80154c:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  801553:	e8 5c 0e 00 00       	call   8023b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801558:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80155b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80155e:	89 ec                	mov    %ebp,%esp
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    
	...

00801564 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80156a:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  801571:	75 30                	jne    8015a3 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801573:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80157a:	00 
  80157b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801582:	ee 
  801583:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158a:	e8 39 fe ff ff       	call   8013c8 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80158f:	c7 44 24 04 b0 15 80 	movl   $0x8015b0,0x4(%esp)
  801596:	00 
  801597:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159e:	e8 07 fc ff ff       	call   8011aa <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    
  8015ad:	00 00                	add    %al,(%eax)
	...

008015b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8015b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8015b1:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  8015b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8015b8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8015bb:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8015bf:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8015c3:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8015c6:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8015c8:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8015cc:	83 c4 08             	add    $0x8,%esp
        popal
  8015cf:	61                   	popa   
        addl $0x4,%esp
  8015d0:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8015d3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8015d4:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8015d5:	c3                   	ret    
	...

008015e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015eb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8015f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f9:	89 04 24             	mov    %eax,(%esp)
  8015fc:	e8 df ff ff ff       	call   8015e0 <fd2num>
  801601:	05 20 00 0d 00       	add    $0xd0020,%eax
  801606:	c1 e0 0c             	shl    $0xc,%eax
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	57                   	push   %edi
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801614:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801619:	a8 01                	test   $0x1,%al
  80161b:	74 36                	je     801653 <fd_alloc+0x48>
  80161d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801622:	a8 01                	test   $0x1,%al
  801624:	74 2d                	je     801653 <fd_alloc+0x48>
  801626:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80162b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801630:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801635:	89 c3                	mov    %eax,%ebx
  801637:	89 c2                	mov    %eax,%edx
  801639:	c1 ea 16             	shr    $0x16,%edx
  80163c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80163f:	f6 c2 01             	test   $0x1,%dl
  801642:	74 14                	je     801658 <fd_alloc+0x4d>
  801644:	89 c2                	mov    %eax,%edx
  801646:	c1 ea 0c             	shr    $0xc,%edx
  801649:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80164c:	f6 c2 01             	test   $0x1,%dl
  80164f:	75 10                	jne    801661 <fd_alloc+0x56>
  801651:	eb 05                	jmp    801658 <fd_alloc+0x4d>
  801653:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801658:	89 1f                	mov    %ebx,(%edi)
  80165a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80165f:	eb 17                	jmp    801678 <fd_alloc+0x6d>
  801661:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801666:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80166b:	75 c8                	jne    801635 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80166d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801673:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5f                   	pop    %edi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	83 f8 1f             	cmp    $0x1f,%eax
  801686:	77 36                	ja     8016be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801688:	05 00 00 0d 00       	add    $0xd0000,%eax
  80168d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801690:	89 c2                	mov    %eax,%edx
  801692:	c1 ea 16             	shr    $0x16,%edx
  801695:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80169c:	f6 c2 01             	test   $0x1,%dl
  80169f:	74 1d                	je     8016be <fd_lookup+0x41>
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	c1 ea 0c             	shr    $0xc,%edx
  8016a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ad:	f6 c2 01             	test   $0x1,%dl
  8016b0:	74 0c                	je     8016be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b5:	89 02                	mov    %eax,(%edx)
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8016bc:	eb 05                	jmp    8016c3 <fd_lookup+0x46>
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	89 04 24             	mov    %eax,(%esp)
  8016d8:	e8 a0 ff ff ff       	call   80167d <fd_lookup>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 0e                	js     8016ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e7:	89 50 04             	mov    %edx,0x4(%eax)
  8016ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 10             	sub    $0x10,%esp
  8016f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8016ff:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801704:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801709:	be 48 2c 80 00       	mov    $0x802c48,%esi
		if (devtab[i]->dev_id == dev_id) {
  80170e:	39 08                	cmp    %ecx,(%eax)
  801710:	75 10                	jne    801722 <dev_lookup+0x31>
  801712:	eb 04                	jmp    801718 <dev_lookup+0x27>
  801714:	39 08                	cmp    %ecx,(%eax)
  801716:	75 0a                	jne    801722 <dev_lookup+0x31>
			*dev = devtab[i];
  801718:	89 03                	mov    %eax,(%ebx)
  80171a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80171f:	90                   	nop
  801720:	eb 31                	jmp    801753 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801722:	83 c2 01             	add    $0x1,%edx
  801725:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801728:	85 c0                	test   %eax,%eax
  80172a:	75 e8                	jne    801714 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80172c:	a1 08 40 80 00       	mov    0x804008,%eax
  801731:	8b 40 48             	mov    0x48(%eax),%eax
  801734:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173c:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  801743:	e8 1d ea ff ff       	call   800165 <cprintf>
	*dev = 0;
  801748:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80174e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 24             	sub    $0x24,%esp
  801761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801764:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	e8 07 ff ff ff       	call   80167d <fd_lookup>
  801776:	85 c0                	test   %eax,%eax
  801778:	78 53                	js     8017cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	8b 00                	mov    (%eax),%eax
  801786:	89 04 24             	mov    %eax,(%esp)
  801789:	e8 63 ff ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 3b                	js     8017cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801792:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801797:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80179e:	74 2d                	je     8017cd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017aa:	00 00 00 
	stat->st_isdir = 0;
  8017ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b4:	00 00 00 
	stat->st_dev = dev;
  8017b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017c7:	89 14 24             	mov    %edx,(%esp)
  8017ca:	ff 50 14             	call   *0x14(%eax)
}
  8017cd:	83 c4 24             	add    $0x24,%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 24             	sub    $0x24,%esp
  8017da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e4:	89 1c 24             	mov    %ebx,(%esp)
  8017e7:	e8 91 fe ff ff       	call   80167d <fd_lookup>
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 5f                	js     80184f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fa:	8b 00                	mov    (%eax),%eax
  8017fc:	89 04 24             	mov    %eax,(%esp)
  8017ff:	e8 ed fe ff ff       	call   8016f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	85 c0                	test   %eax,%eax
  801806:	78 47                	js     80184f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801808:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80180b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80180f:	75 23                	jne    801834 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801811:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801816:	8b 40 48             	mov    0x48(%eax),%eax
  801819:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	c7 04 24 ec 2b 80 00 	movl   $0x802bec,(%esp)
  801828:	e8 38 e9 ff ff       	call   800165 <cprintf>
  80182d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801832:	eb 1b                	jmp    80184f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801837:	8b 48 18             	mov    0x18(%eax),%ecx
  80183a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80183f:	85 c9                	test   %ecx,%ecx
  801841:	74 0c                	je     80184f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801843:	8b 45 0c             	mov    0xc(%ebp),%eax
  801846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184a:	89 14 24             	mov    %edx,(%esp)
  80184d:	ff d1                	call   *%ecx
}
  80184f:	83 c4 24             	add    $0x24,%esp
  801852:	5b                   	pop    %ebx
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	53                   	push   %ebx
  801859:	83 ec 24             	sub    $0x24,%esp
  80185c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	89 1c 24             	mov    %ebx,(%esp)
  801869:	e8 0f fe ff ff       	call   80167d <fd_lookup>
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 66                	js     8018d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801872:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187c:	8b 00                	mov    (%eax),%eax
  80187e:	89 04 24             	mov    %eax,(%esp)
  801881:	e8 6b fe ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801886:	85 c0                	test   %eax,%eax
  801888:	78 4e                	js     8018d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80188d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801891:	75 23                	jne    8018b6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801893:	a1 08 40 80 00       	mov    0x804008,%eax
  801898:	8b 40 48             	mov    0x48(%eax),%eax
  80189b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	c7 04 24 0d 2c 80 00 	movl   $0x802c0d,(%esp)
  8018aa:	e8 b6 e8 ff ff       	call   800165 <cprintf>
  8018af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018b4:	eb 22                	jmp    8018d8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8018bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018c1:	85 c9                	test   %ecx,%ecx
  8018c3:	74 13                	je     8018d8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d3:	89 14 24             	mov    %edx,(%esp)
  8018d6:	ff d1                	call   *%ecx
}
  8018d8:	83 c4 24             	add    $0x24,%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 24             	sub    $0x24,%esp
  8018e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	89 1c 24             	mov    %ebx,(%esp)
  8018f2:	e8 86 fd ff ff       	call   80167d <fd_lookup>
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	78 6b                	js     801966 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801902:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801905:	8b 00                	mov    (%eax),%eax
  801907:	89 04 24             	mov    %eax,(%esp)
  80190a:	e8 e2 fd ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 53                	js     801966 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801913:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801916:	8b 42 08             	mov    0x8(%edx),%eax
  801919:	83 e0 03             	and    $0x3,%eax
  80191c:	83 f8 01             	cmp    $0x1,%eax
  80191f:	75 23                	jne    801944 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801921:	a1 08 40 80 00       	mov    0x804008,%eax
  801926:	8b 40 48             	mov    0x48(%eax),%eax
  801929:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801931:	c7 04 24 2a 2c 80 00 	movl   $0x802c2a,(%esp)
  801938:	e8 28 e8 ff ff       	call   800165 <cprintf>
  80193d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801942:	eb 22                	jmp    801966 <read+0x88>
	}
	if (!dev->dev_read)
  801944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801947:	8b 48 08             	mov    0x8(%eax),%ecx
  80194a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80194f:	85 c9                	test   %ecx,%ecx
  801951:	74 13                	je     801966 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801953:	8b 45 10             	mov    0x10(%ebp),%eax
  801956:	89 44 24 08          	mov    %eax,0x8(%esp)
  80195a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801961:	89 14 24             	mov    %edx,(%esp)
  801964:	ff d1                	call   *%ecx
}
  801966:	83 c4 24             	add    $0x24,%esp
  801969:	5b                   	pop    %ebx
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	57                   	push   %edi
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	83 ec 1c             	sub    $0x1c,%esp
  801975:	8b 7d 08             	mov    0x8(%ebp),%edi
  801978:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	bb 00 00 00 00       	mov    $0x0,%ebx
  801985:	b8 00 00 00 00       	mov    $0x0,%eax
  80198a:	85 f6                	test   %esi,%esi
  80198c:	74 29                	je     8019b7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80198e:	89 f0                	mov    %esi,%eax
  801990:	29 d0                	sub    %edx,%eax
  801992:	89 44 24 08          	mov    %eax,0x8(%esp)
  801996:	03 55 0c             	add    0xc(%ebp),%edx
  801999:	89 54 24 04          	mov    %edx,0x4(%esp)
  80199d:	89 3c 24             	mov    %edi,(%esp)
  8019a0:	e8 39 ff ff ff       	call   8018de <read>
		if (m < 0)
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 0e                	js     8019b7 <readn+0x4b>
			return m;
		if (m == 0)
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	74 08                	je     8019b5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019ad:	01 c3                	add    %eax,%ebx
  8019af:	89 da                	mov    %ebx,%edx
  8019b1:	39 f3                	cmp    %esi,%ebx
  8019b3:	72 d9                	jb     80198e <readn+0x22>
  8019b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019b7:	83 c4 1c             	add    $0x1c,%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5f                   	pop    %edi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	56                   	push   %esi
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 20             	sub    $0x20,%esp
  8019c7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8019ca:	89 34 24             	mov    %esi,(%esp)
  8019cd:	e8 0e fc ff ff       	call   8015e0 <fd2num>
  8019d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019d9:	89 04 24             	mov    %eax,(%esp)
  8019dc:	e8 9c fc ff ff       	call   80167d <fd_lookup>
  8019e1:	89 c3                	mov    %eax,%ebx
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 05                	js     8019ec <fd_close+0x2d>
  8019e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8019ea:	74 0c                	je     8019f8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8019ec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8019f0:	19 c0                	sbb    %eax,%eax
  8019f2:	f7 d0                	not    %eax
  8019f4:	21 c3                	and    %eax,%ebx
  8019f6:	eb 3d                	jmp    801a35 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8019f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ff:	8b 06                	mov    (%esi),%eax
  801a01:	89 04 24             	mov    %eax,(%esp)
  801a04:	e8 e8 fc ff ff       	call   8016f1 <dev_lookup>
  801a09:	89 c3                	mov    %eax,%ebx
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 16                	js     801a25 <fd_close+0x66>
		if (dev->dev_close)
  801a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a12:	8b 40 10             	mov    0x10(%eax),%eax
  801a15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	74 07                	je     801a25 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801a1e:	89 34 24             	mov    %esi,(%esp)
  801a21:	ff d0                	call   *%eax
  801a23:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a25:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a30:	e8 b9 f8 ff ff       	call   8012ee <sys_page_unmap>
	return r;
}
  801a35:	89 d8                	mov    %ebx,%eax
  801a37:	83 c4 20             	add    $0x20,%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	89 04 24             	mov    %eax,(%esp)
  801a51:	e8 27 fc ff ff       	call   80167d <fd_lookup>
  801a56:	85 c0                	test   %eax,%eax
  801a58:	78 13                	js     801a6d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801a5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a61:	00 
  801a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a65:	89 04 24             	mov    %eax,(%esp)
  801a68:	e8 52 ff ff ff       	call   8019bf <fd_close>
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 18             	sub    $0x18,%esp
  801a75:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a78:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a82:	00 
  801a83:	8b 45 08             	mov    0x8(%ebp),%eax
  801a86:	89 04 24             	mov    %eax,(%esp)
  801a89:	e8 79 03 00 00       	call   801e07 <open>
  801a8e:	89 c3                	mov    %eax,%ebx
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 1b                	js     801aaf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	89 1c 24             	mov    %ebx,(%esp)
  801a9e:	e8 b7 fc ff ff       	call   80175a <fstat>
  801aa3:	89 c6                	mov    %eax,%esi
	close(fd);
  801aa5:	89 1c 24             	mov    %ebx,(%esp)
  801aa8:	e8 91 ff ff ff       	call   801a3e <close>
  801aad:	89 f3                	mov    %esi,%ebx
	return r;
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ab4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ab7:	89 ec                	mov    %ebp,%esp
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	83 ec 14             	sub    $0x14,%esp
  801ac2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801ac7:	89 1c 24             	mov    %ebx,(%esp)
  801aca:	e8 6f ff ff ff       	call   801a3e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801acf:	83 c3 01             	add    $0x1,%ebx
  801ad2:	83 fb 20             	cmp    $0x20,%ebx
  801ad5:	75 f0                	jne    801ac7 <close_all+0xc>
		close(i);
}
  801ad7:	83 c4 14             	add    $0x14,%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 58             	sub    $0x58,%esp
  801ae3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ae6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ae9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801aec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801aef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af6:	8b 45 08             	mov    0x8(%ebp),%eax
  801af9:	89 04 24             	mov    %eax,(%esp)
  801afc:	e8 7c fb ff ff       	call   80167d <fd_lookup>
  801b01:	89 c3                	mov    %eax,%ebx
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 e0 00 00 00    	js     801beb <dup+0x10e>
		return r;
	close(newfdnum);
  801b0b:	89 3c 24             	mov    %edi,(%esp)
  801b0e:	e8 2b ff ff ff       	call   801a3e <close>

	newfd = INDEX2FD(newfdnum);
  801b13:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b19:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1f:	89 04 24             	mov    %eax,(%esp)
  801b22:	e8 c9 fa ff ff       	call   8015f0 <fd2data>
  801b27:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b29:	89 34 24             	mov    %esi,(%esp)
  801b2c:	e8 bf fa ff ff       	call   8015f0 <fd2data>
  801b31:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801b34:	89 da                	mov    %ebx,%edx
  801b36:	89 d8                	mov    %ebx,%eax
  801b38:	c1 e8 16             	shr    $0x16,%eax
  801b3b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b42:	a8 01                	test   $0x1,%al
  801b44:	74 43                	je     801b89 <dup+0xac>
  801b46:	c1 ea 0c             	shr    $0xc,%edx
  801b49:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b50:	a8 01                	test   $0x1,%al
  801b52:	74 35                	je     801b89 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b54:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b5b:	25 07 0e 00 00       	and    $0xe07,%eax
  801b60:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b72:	00 
  801b73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7e:	e8 d7 f7 ff ff       	call   80135a <sys_page_map>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 3f                	js     801bc8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	c1 ea 0c             	shr    $0xc,%edx
  801b91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b98:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b9e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ba2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ba6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bad:	00 
  801bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb9:	e8 9c f7 ff ff       	call   80135a <sys_page_map>
  801bbe:	89 c3                	mov    %eax,%ebx
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 04                	js     801bc8 <dup+0xeb>
  801bc4:	89 fb                	mov    %edi,%ebx
  801bc6:	eb 23                	jmp    801beb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801bc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd3:	e8 16 f7 ff ff       	call   8012ee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801bd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be6:	e8 03 f7 ff ff       	call   8012ee <sys_page_unmap>
	return r;
}
  801beb:	89 d8                	mov    %ebx,%eax
  801bed:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801bf0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801bf3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801bf6:	89 ec                	mov    %ebp,%esp
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    
	...

00801bfc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 18             	sub    $0x18,%esp
  801c02:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c05:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c08:	89 c3                	mov    %eax,%ebx
  801c0a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c0c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c13:	75 11                	jne    801c26 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c15:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c1c:	e8 ef 07 00 00       	call   802410 <ipc_find_env>
  801c21:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c26:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c2d:	00 
  801c2e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c35:	00 
  801c36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3a:	a1 00 40 80 00       	mov    0x804000,%eax
  801c3f:	89 04 24             	mov    %eax,(%esp)
  801c42:	e8 14 08 00 00       	call   80245b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c4e:	00 
  801c4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5a:	e8 7a 08 00 00       	call   8024d9 <ipc_recv>
}
  801c5f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c62:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c65:	89 ec                	mov    %ebp,%esp
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	8b 40 0c             	mov    0xc(%eax),%eax
  801c75:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c82:	ba 00 00 00 00       	mov    $0x0,%edx
  801c87:	b8 02 00 00 00       	mov    $0x2,%eax
  801c8c:	e8 6b ff ff ff       	call   801bfc <fsipc>
}
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c99:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c9f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca9:	b8 06 00 00 00       	mov    $0x6,%eax
  801cae:	e8 49 ff ff ff       	call   801bfc <fsipc>
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801cc5:	e8 32 ff ff ff       	call   801bfc <fsipc>
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	53                   	push   %ebx
  801cd0:	83 ec 14             	sub    $0x14,%esp
  801cd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	8b 40 0c             	mov    0xc(%eax),%eax
  801cdc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce6:	b8 05 00 00 00       	mov    $0x5,%eax
  801ceb:	e8 0c ff ff ff       	call   801bfc <fsipc>
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 2b                	js     801d1f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cf4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cfb:	00 
  801cfc:	89 1c 24             	mov    %ebx,(%esp)
  801cff:	e8 96 ed ff ff       	call   800a9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d04:	a1 80 50 80 00       	mov    0x805080,%eax
  801d09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d0f:	a1 84 50 80 00       	mov    0x805084,%eax
  801d14:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d1f:	83 c4 14             	add    $0x14,%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 18             	sub    $0x18,%esp
  801d2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d33:	76 05                	jbe    801d3a <devfile_write+0x15>
  801d35:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  801d3d:	8b 52 0c             	mov    0xc(%edx),%edx
  801d40:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801d46:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801d4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d56:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801d5d:	e8 23 ef ff ff       	call   800c85 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801d62:	ba 00 00 00 00       	mov    $0x0,%edx
  801d67:	b8 04 00 00 00       	mov    $0x4,%eax
  801d6c:	e8 8b fe ff ff       	call   801bfc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	53                   	push   %ebx
  801d77:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d80:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801d85:	8b 45 10             	mov    0x10(%ebp),%eax
  801d88:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801d8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d92:	b8 03 00 00 00       	mov    $0x3,%eax
  801d97:	e8 60 fe ff ff       	call   801bfc <fsipc>
  801d9c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	78 17                	js     801db9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801da2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dad:	00 
  801dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db1:	89 04 24             	mov    %eax,(%esp)
  801db4:	e8 cc ee ff ff       	call   800c85 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801db9:	89 d8                	mov    %ebx,%eax
  801dbb:	83 c4 14             	add    $0x14,%esp
  801dbe:	5b                   	pop    %ebx
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    

00801dc1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	53                   	push   %ebx
  801dc5:	83 ec 14             	sub    $0x14,%esp
  801dc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801dcb:	89 1c 24             	mov    %ebx,(%esp)
  801dce:	e8 7d ec ff ff       	call   800a50 <strlen>
  801dd3:	89 c2                	mov    %eax,%edx
  801dd5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801dda:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801de0:	7f 1f                	jg     801e01 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801de2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801de6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ded:	e8 a8 ec ff ff       	call   800a9a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801df2:	ba 00 00 00 00       	mov    $0x0,%edx
  801df7:	b8 07 00 00 00       	mov    $0x7,%eax
  801dfc:	e8 fb fd ff ff       	call   801bfc <fsipc>
}
  801e01:	83 c4 14             	add    $0x14,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 28             	sub    $0x28,%esp
  801e0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e10:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e13:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801e16:	89 34 24             	mov    %esi,(%esp)
  801e19:	e8 32 ec ff ff       	call   800a50 <strlen>
  801e1e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801e23:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e28:	7f 6d                	jg     801e97 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801e2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2d:	89 04 24             	mov    %eax,(%esp)
  801e30:	e8 d6 f7 ff ff       	call   80160b <fd_alloc>
  801e35:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 5c                	js     801e97 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801e43:	89 34 24             	mov    %esi,(%esp)
  801e46:	e8 05 ec ff ff       	call   800a50 <strlen>
  801e4b:	83 c0 01             	add    $0x1,%eax
  801e4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e56:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e5d:	e8 23 ee ff ff       	call   800c85 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801e62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e65:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6a:	e8 8d fd ff ff       	call   801bfc <fsipc>
  801e6f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801e71:	85 c0                	test   %eax,%eax
  801e73:	79 15                	jns    801e8a <open+0x83>
             fd_close(fd,0);
  801e75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e7c:	00 
  801e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e80:	89 04 24             	mov    %eax,(%esp)
  801e83:	e8 37 fb ff ff       	call   8019bf <fd_close>
             return r;
  801e88:	eb 0d                	jmp    801e97 <open+0x90>
        }
        return fd2num(fd);
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	89 04 24             	mov    %eax,(%esp)
  801e90:	e8 4b f7 ff ff       	call   8015e0 <fd2num>
  801e95:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801e97:	89 d8                	mov    %ebx,%eax
  801e99:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e9c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e9f:	89 ec                	mov    %ebp,%esp
  801ea1:	5d                   	pop    %ebp
  801ea2:	c3                   	ret    
	...

00801eb0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801eb6:	c7 44 24 04 54 2c 80 	movl   $0x802c54,0x4(%esp)
  801ebd:	00 
  801ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec1:	89 04 24             	mov    %eax,(%esp)
  801ec4:	e8 d1 eb ff ff       	call   800a9a <strcpy>
	return 0;
}
  801ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 14             	sub    $0x14,%esp
  801ed7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801eda:	89 1c 24             	mov    %ebx,(%esp)
  801edd:	e8 6a 06 00 00       	call   80254c <pageref>
  801ee2:	89 c2                	mov    %eax,%edx
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee9:	83 fa 01             	cmp    $0x1,%edx
  801eec:	75 0b                	jne    801ef9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801eee:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ef1:	89 04 24             	mov    %eax,(%esp)
  801ef4:	e8 b9 02 00 00       	call   8021b2 <nsipc_close>
	else
		return 0;
}
  801ef9:	83 c4 14             	add    $0x14,%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f05:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f0c:	00 
  801f0d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f10:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f21:	89 04 24             	mov    %eax,(%esp)
  801f24:	e8 c5 02 00 00       	call   8021ee <nsipc_send>
}
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f38:	00 
  801f39:	8b 45 10             	mov    0x10(%ebp),%eax
  801f3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f47:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4a:	8b 40 0c             	mov    0xc(%eax),%eax
  801f4d:	89 04 24             	mov    %eax,(%esp)
  801f50:	e8 0c 03 00 00       	call   802261 <nsipc_recv>
}
  801f55:	c9                   	leave  
  801f56:	c3                   	ret    

00801f57 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	56                   	push   %esi
  801f5b:	53                   	push   %ebx
  801f5c:	83 ec 20             	sub    $0x20,%esp
  801f5f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f64:	89 04 24             	mov    %eax,(%esp)
  801f67:	e8 9f f6 ff ff       	call   80160b <fd_alloc>
  801f6c:	89 c3                	mov    %eax,%ebx
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 21                	js     801f93 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f72:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f79:	00 
  801f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f88:	e8 3b f4 ff ff       	call   8013c8 <sys_page_alloc>
  801f8d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	79 0a                	jns    801f9d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801f93:	89 34 24             	mov    %esi,(%esp)
  801f96:	e8 17 02 00 00       	call   8021b2 <nsipc_close>
		return r;
  801f9b:	eb 28                	jmp    801fc5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 1d f6 ff ff       	call   8015e0 <fd2num>
  801fc3:	89 c3                	mov    %eax,%ebx
}
  801fc5:	89 d8                	mov    %ebx,%eax
  801fc7:	83 c4 20             	add    $0x20,%esp
  801fca:	5b                   	pop    %ebx
  801fcb:	5e                   	pop    %esi
  801fcc:	5d                   	pop    %ebp
  801fcd:	c3                   	ret    

00801fce <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fd4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fd7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fde:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 79 01 00 00       	call   802166 <nsipc_socket>
  801fed:	85 c0                	test   %eax,%eax
  801fef:	78 05                	js     801ff6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801ff1:	e8 61 ff ff ff       	call   801f57 <alloc_sockfd>
}
  801ff6:	c9                   	leave  
  801ff7:	c3                   	ret    

00801ff8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ffe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802001:	89 54 24 04          	mov    %edx,0x4(%esp)
  802005:	89 04 24             	mov    %eax,(%esp)
  802008:	e8 70 f6 ff ff       	call   80167d <fd_lookup>
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 15                	js     802026 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802011:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802014:	8b 0a                	mov    (%edx),%ecx
  802016:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80201b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  802021:	75 03                	jne    802026 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802023:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802026:	c9                   	leave  
  802027:	c3                   	ret    

00802028 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80202e:	8b 45 08             	mov    0x8(%ebp),%eax
  802031:	e8 c2 ff ff ff       	call   801ff8 <fd2sockid>
  802036:	85 c0                	test   %eax,%eax
  802038:	78 0f                	js     802049 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80203a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802041:	89 04 24             	mov    %eax,(%esp)
  802044:	e8 47 01 00 00       	call   802190 <nsipc_listen>
}
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802051:	8b 45 08             	mov    0x8(%ebp),%eax
  802054:	e8 9f ff ff ff       	call   801ff8 <fd2sockid>
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 16                	js     802073 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80205d:	8b 55 10             	mov    0x10(%ebp),%edx
  802060:	89 54 24 08          	mov    %edx,0x8(%esp)
  802064:	8b 55 0c             	mov    0xc(%ebp),%edx
  802067:	89 54 24 04          	mov    %edx,0x4(%esp)
  80206b:	89 04 24             	mov    %eax,(%esp)
  80206e:	e8 6e 02 00 00       	call   8022e1 <nsipc_connect>
}
  802073:	c9                   	leave  
  802074:	c3                   	ret    

00802075 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80207b:	8b 45 08             	mov    0x8(%ebp),%eax
  80207e:	e8 75 ff ff ff       	call   801ff8 <fd2sockid>
  802083:	85 c0                	test   %eax,%eax
  802085:	78 0f                	js     802096 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802087:	8b 55 0c             	mov    0xc(%ebp),%edx
  80208a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80208e:	89 04 24             	mov    %eax,(%esp)
  802091:	e8 36 01 00 00       	call   8021cc <nsipc_shutdown>
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80209e:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a1:	e8 52 ff ff ff       	call   801ff8 <fd2sockid>
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 16                	js     8020c0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8020aa:	8b 55 10             	mov    0x10(%ebp),%edx
  8020ad:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b8:	89 04 24             	mov    %eax,(%esp)
  8020bb:	e8 60 02 00 00       	call   802320 <nsipc_bind>
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cb:	e8 28 ff ff ff       	call   801ff8 <fd2sockid>
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	78 1f                	js     8020f3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8020d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e2:	89 04 24             	mov    %eax,(%esp)
  8020e5:	e8 75 02 00 00       	call   80235f <nsipc_accept>
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	78 05                	js     8020f3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8020ee:	e8 64 fe ff ff       	call   801f57 <alloc_sockfd>
}
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    
	...

00802100 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	53                   	push   %ebx
  802104:	83 ec 14             	sub    $0x14,%esp
  802107:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802109:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  802110:	75 11                	jne    802123 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802112:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802119:	e8 f2 02 00 00       	call   802410 <ipc_find_env>
  80211e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802123:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80212a:	00 
  80212b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802132:	00 
  802133:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802137:	a1 04 40 80 00       	mov    0x804004,%eax
  80213c:	89 04 24             	mov    %eax,(%esp)
  80213f:	e8 17 03 00 00       	call   80245b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802144:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80214b:	00 
  80214c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802153:	00 
  802154:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80215b:	e8 79 03 00 00       	call   8024d9 <ipc_recv>
}
  802160:	83 c4 14             	add    $0x14,%esp
  802163:	5b                   	pop    %ebx
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    

00802166 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80216c:	8b 45 08             	mov    0x8(%ebp),%eax
  80216f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802174:	8b 45 0c             	mov    0xc(%ebp),%eax
  802177:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80217c:	8b 45 10             	mov    0x10(%ebp),%eax
  80217f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802184:	b8 09 00 00 00       	mov    $0x9,%eax
  802189:	e8 72 ff ff ff       	call   802100 <nsipc>
}
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802196:	8b 45 08             	mov    0x8(%ebp),%eax
  802199:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80219e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021a1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8021a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8021ab:	e8 50 ff ff ff       	call   802100 <nsipc>
}
  8021b0:	c9                   	leave  
  8021b1:	c3                   	ret    

008021b2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8021b2:	55                   	push   %ebp
  8021b3:	89 e5                	mov    %esp,%ebp
  8021b5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8021c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8021c5:	e8 36 ff ff ff       	call   802100 <nsipc>
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8021da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021dd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8021e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8021e7:	e8 14 ff ff ff       	call   802100 <nsipc>
}
  8021ec:	c9                   	leave  
  8021ed:	c3                   	ret    

008021ee <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021ee:	55                   	push   %ebp
  8021ef:	89 e5                	mov    %esp,%ebp
  8021f1:	53                   	push   %ebx
  8021f2:	83 ec 14             	sub    $0x14,%esp
  8021f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802200:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802206:	7e 24                	jle    80222c <nsipc_send+0x3e>
  802208:	c7 44 24 0c 60 2c 80 	movl   $0x802c60,0xc(%esp)
  80220f:	00 
  802210:	c7 44 24 08 6c 2c 80 	movl   $0x802c6c,0x8(%esp)
  802217:	00 
  802218:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80221f:	00 
  802220:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  802227:	e8 88 01 00 00       	call   8023b4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80222c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802230:	8b 45 0c             	mov    0xc(%ebp),%eax
  802233:	89 44 24 04          	mov    %eax,0x4(%esp)
  802237:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80223e:	e8 42 ea ff ff       	call   800c85 <memmove>
	nsipcbuf.send.req_size = size;
  802243:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802249:	8b 45 14             	mov    0x14(%ebp),%eax
  80224c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802251:	b8 08 00 00 00       	mov    $0x8,%eax
  802256:	e8 a5 fe ff ff       	call   802100 <nsipc>
}
  80225b:	83 c4 14             	add    $0x14,%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    

00802261 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	56                   	push   %esi
  802265:	53                   	push   %ebx
  802266:	83 ec 10             	sub    $0x10,%esp
  802269:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80226c:	8b 45 08             	mov    0x8(%ebp),%eax
  80226f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802274:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80227a:	8b 45 14             	mov    0x14(%ebp),%eax
  80227d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802282:	b8 07 00 00 00       	mov    $0x7,%eax
  802287:	e8 74 fe ff ff       	call   802100 <nsipc>
  80228c:	89 c3                	mov    %eax,%ebx
  80228e:	85 c0                	test   %eax,%eax
  802290:	78 46                	js     8022d8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802292:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802297:	7f 04                	jg     80229d <nsipc_recv+0x3c>
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	7d 24                	jge    8022c1 <nsipc_recv+0x60>
  80229d:	c7 44 24 0c 8d 2c 80 	movl   $0x802c8d,0xc(%esp)
  8022a4:	00 
  8022a5:	c7 44 24 08 6c 2c 80 	movl   $0x802c6c,0x8(%esp)
  8022ac:	00 
  8022ad:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8022b4:	00 
  8022b5:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8022bc:	e8 f3 00 00 00       	call   8023b4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8022c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022c5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8022cc:	00 
  8022cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d0:	89 04 24             	mov    %eax,(%esp)
  8022d3:	e8 ad e9 ff ff       	call   800c85 <memmove>
	}

	return r;
}
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    

008022e1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8022e1:	55                   	push   %ebp
  8022e2:	89 e5                	mov    %esp,%ebp
  8022e4:	53                   	push   %ebx
  8022e5:	83 ec 14             	sub    $0x14,%esp
  8022e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8022eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ee:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8022f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022fe:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802305:	e8 7b e9 ff ff       	call   800c85 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80230a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802310:	b8 05 00 00 00       	mov    $0x5,%eax
  802315:	e8 e6 fd ff ff       	call   802100 <nsipc>
}
  80231a:	83 c4 14             	add    $0x14,%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5d                   	pop    %ebp
  80231f:	c3                   	ret    

00802320 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	53                   	push   %ebx
  802324:	83 ec 14             	sub    $0x14,%esp
  802327:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80232a:	8b 45 08             	mov    0x8(%ebp),%eax
  80232d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802332:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802336:	8b 45 0c             	mov    0xc(%ebp),%eax
  802339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802344:	e8 3c e9 ff ff       	call   800c85 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802349:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80234f:	b8 02 00 00 00       	mov    $0x2,%eax
  802354:	e8 a7 fd ff ff       	call   802100 <nsipc>
}
  802359:	83 c4 14             	add    $0x14,%esp
  80235c:	5b                   	pop    %ebx
  80235d:	5d                   	pop    %ebp
  80235e:	c3                   	ret    

0080235f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80235f:	55                   	push   %ebp
  802360:	89 e5                	mov    %esp,%ebp
  802362:	83 ec 18             	sub    $0x18,%esp
  802365:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802368:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80236b:	8b 45 08             	mov    0x8(%ebp),%eax
  80236e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802373:	b8 01 00 00 00       	mov    $0x1,%eax
  802378:	e8 83 fd ff ff       	call   802100 <nsipc>
  80237d:	89 c3                	mov    %eax,%ebx
  80237f:	85 c0                	test   %eax,%eax
  802381:	78 25                	js     8023a8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802383:	be 10 60 80 00       	mov    $0x806010,%esi
  802388:	8b 06                	mov    (%esi),%eax
  80238a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80238e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802395:	00 
  802396:	8b 45 0c             	mov    0xc(%ebp),%eax
  802399:	89 04 24             	mov    %eax,(%esp)
  80239c:	e8 e4 e8 ff ff       	call   800c85 <memmove>
		*addrlen = ret->ret_addrlen;
  8023a1:	8b 16                	mov    (%esi),%edx
  8023a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8023a6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8023a8:	89 d8                	mov    %ebx,%eax
  8023aa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8023ad:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8023b0:	89 ec                	mov    %ebp,%esp
  8023b2:	5d                   	pop    %ebp
  8023b3:	c3                   	ret    

008023b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8023b4:	55                   	push   %ebp
  8023b5:	89 e5                	mov    %esp,%ebp
  8023b7:	56                   	push   %esi
  8023b8:	53                   	push   %ebx
  8023b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8023bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8023bf:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8023c5:	e8 ed f0 ff ff       	call   8014b7 <sys_getenvid>
  8023ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8023d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8023d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e0:	c7 04 24 a4 2c 80 00 	movl   $0x802ca4,(%esp)
  8023e7:	e8 79 dd ff ff       	call   800165 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8023ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f3:	89 04 24             	mov    %eax,(%esp)
  8023f6:	e8 09 dd ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  8023fb:	c7 04 24 44 2c 80 00 	movl   $0x802c44,(%esp)
  802402:	e8 5e dd ff ff       	call   800165 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802407:	cc                   	int3   
  802408:	eb fd                	jmp    802407 <_panic+0x53>
  80240a:	00 00                	add    %al,(%eax)
  80240c:	00 00                	add    %al,(%eax)
	...

00802410 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802410:	55                   	push   %ebp
  802411:	89 e5                	mov    %esp,%ebp
  802413:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802416:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80241c:	b8 01 00 00 00       	mov    $0x1,%eax
  802421:	39 ca                	cmp    %ecx,%edx
  802423:	75 04                	jne    802429 <ipc_find_env+0x19>
  802425:	b0 00                	mov    $0x0,%al
  802427:	eb 12                	jmp    80243b <ipc_find_env+0x2b>
  802429:	89 c2                	mov    %eax,%edx
  80242b:	c1 e2 07             	shl    $0x7,%edx
  80242e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802435:	8b 12                	mov    (%edx),%edx
  802437:	39 ca                	cmp    %ecx,%edx
  802439:	75 10                	jne    80244b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80243b:	89 c2                	mov    %eax,%edx
  80243d:	c1 e2 07             	shl    $0x7,%edx
  802440:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802447:	8b 00                	mov    (%eax),%eax
  802449:	eb 0e                	jmp    802459 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80244b:	83 c0 01             	add    $0x1,%eax
  80244e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802453:	75 d4                	jne    802429 <ipc_find_env+0x19>
  802455:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802459:	5d                   	pop    %ebp
  80245a:	c3                   	ret    

0080245b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80245b:	55                   	push   %ebp
  80245c:	89 e5                	mov    %esp,%ebp
  80245e:	57                   	push   %edi
  80245f:	56                   	push   %esi
  802460:	53                   	push   %ebx
  802461:	83 ec 1c             	sub    $0x1c,%esp
  802464:	8b 75 08             	mov    0x8(%ebp),%esi
  802467:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80246a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80246d:	85 db                	test   %ebx,%ebx
  80246f:	74 19                	je     80248a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802471:	8b 45 14             	mov    0x14(%ebp),%eax
  802474:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802478:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80247c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802480:	89 34 24             	mov    %esi,(%esp)
  802483:	e8 e1 ec ff ff       	call   801169 <sys_ipc_try_send>
  802488:	eb 1b                	jmp    8024a5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80248a:	8b 45 14             	mov    0x14(%ebp),%eax
  80248d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802491:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802498:	ee 
  802499:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80249d:	89 34 24             	mov    %esi,(%esp)
  8024a0:	e8 c4 ec ff ff       	call   801169 <sys_ipc_try_send>
           if(ret == 0)
  8024a5:	85 c0                	test   %eax,%eax
  8024a7:	74 28                	je     8024d1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8024a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024ac:	74 1c                	je     8024ca <ipc_send+0x6f>
              panic("ipc send error");
  8024ae:	c7 44 24 08 c8 2c 80 	movl   $0x802cc8,0x8(%esp)
  8024b5:	00 
  8024b6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8024bd:	00 
  8024be:	c7 04 24 d7 2c 80 00 	movl   $0x802cd7,(%esp)
  8024c5:	e8 ea fe ff ff       	call   8023b4 <_panic>
           sys_yield();
  8024ca:	e8 66 ef ff ff       	call   801435 <sys_yield>
        }
  8024cf:	eb 9c                	jmp    80246d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8024d1:	83 c4 1c             	add    $0x1c,%esp
  8024d4:	5b                   	pop    %ebx
  8024d5:	5e                   	pop    %esi
  8024d6:	5f                   	pop    %edi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    

008024d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024d9:	55                   	push   %ebp
  8024da:	89 e5                	mov    %esp,%ebp
  8024dc:	56                   	push   %esi
  8024dd:	53                   	push   %ebx
  8024de:	83 ec 10             	sub    $0x10,%esp
  8024e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8024e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8024ea:	85 c0                	test   %eax,%eax
  8024ec:	75 0e                	jne    8024fc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8024ee:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8024f5:	e8 04 ec ff ff       	call   8010fe <sys_ipc_recv>
  8024fa:	eb 08                	jmp    802504 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8024fc:	89 04 24             	mov    %eax,(%esp)
  8024ff:	e8 fa eb ff ff       	call   8010fe <sys_ipc_recv>
        if(ret == 0){
  802504:	85 c0                	test   %eax,%eax
  802506:	75 26                	jne    80252e <ipc_recv+0x55>
           if(from_env_store)
  802508:	85 f6                	test   %esi,%esi
  80250a:	74 0a                	je     802516 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80250c:	a1 08 40 80 00       	mov    0x804008,%eax
  802511:	8b 40 78             	mov    0x78(%eax),%eax
  802514:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802516:	85 db                	test   %ebx,%ebx
  802518:	74 0a                	je     802524 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80251a:	a1 08 40 80 00       	mov    0x804008,%eax
  80251f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802522:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802524:	a1 08 40 80 00       	mov    0x804008,%eax
  802529:	8b 40 74             	mov    0x74(%eax),%eax
  80252c:	eb 14                	jmp    802542 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80252e:	85 f6                	test   %esi,%esi
  802530:	74 06                	je     802538 <ipc_recv+0x5f>
              *from_env_store = 0;
  802532:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802538:	85 db                	test   %ebx,%ebx
  80253a:	74 06                	je     802542 <ipc_recv+0x69>
              *perm_store = 0;
  80253c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802542:	83 c4 10             	add    $0x10,%esp
  802545:	5b                   	pop    %ebx
  802546:	5e                   	pop    %esi
  802547:	5d                   	pop    %ebp
  802548:	c3                   	ret    
  802549:	00 00                	add    %al,(%eax)
	...

0080254c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80254f:	8b 45 08             	mov    0x8(%ebp),%eax
  802552:	89 c2                	mov    %eax,%edx
  802554:	c1 ea 16             	shr    $0x16,%edx
  802557:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80255e:	f6 c2 01             	test   $0x1,%dl
  802561:	74 20                	je     802583 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802563:	c1 e8 0c             	shr    $0xc,%eax
  802566:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80256d:	a8 01                	test   $0x1,%al
  80256f:	74 12                	je     802583 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802571:	c1 e8 0c             	shr    $0xc,%eax
  802574:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802579:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80257e:	0f b7 c0             	movzwl %ax,%eax
  802581:	eb 05                	jmp    802588 <pageref+0x3c>
  802583:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802588:	5d                   	pop    %ebp
  802589:	c3                   	ret    
  80258a:	00 00                	add    %al,(%eax)
  80258c:	00 00                	add    %al,(%eax)
	...

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	89 e5                	mov    %esp,%ebp
  802593:	57                   	push   %edi
  802594:	56                   	push   %esi
  802595:	83 ec 10             	sub    $0x10,%esp
  802598:	8b 45 14             	mov    0x14(%ebp),%eax
  80259b:	8b 55 08             	mov    0x8(%ebp),%edx
  80259e:	8b 75 10             	mov    0x10(%ebp),%esi
  8025a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025a4:	85 c0                	test   %eax,%eax
  8025a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8025a9:	75 35                	jne    8025e0 <__udivdi3+0x50>
  8025ab:	39 fe                	cmp    %edi,%esi
  8025ad:	77 61                	ja     802610 <__udivdi3+0x80>
  8025af:	85 f6                	test   %esi,%esi
  8025b1:	75 0b                	jne    8025be <__udivdi3+0x2e>
  8025b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	f7 f6                	div    %esi
  8025bc:	89 c6                	mov    %eax,%esi
  8025be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8025c1:	31 d2                	xor    %edx,%edx
  8025c3:	89 f8                	mov    %edi,%eax
  8025c5:	f7 f6                	div    %esi
  8025c7:	89 c7                	mov    %eax,%edi
  8025c9:	89 c8                	mov    %ecx,%eax
  8025cb:	f7 f6                	div    %esi
  8025cd:	89 c1                	mov    %eax,%ecx
  8025cf:	89 fa                	mov    %edi,%edx
  8025d1:	89 c8                	mov    %ecx,%eax
  8025d3:	83 c4 10             	add    $0x10,%esp
  8025d6:	5e                   	pop    %esi
  8025d7:	5f                   	pop    %edi
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    
  8025da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e0:	39 f8                	cmp    %edi,%eax
  8025e2:	77 1c                	ja     802600 <__udivdi3+0x70>
  8025e4:	0f bd d0             	bsr    %eax,%edx
  8025e7:	83 f2 1f             	xor    $0x1f,%edx
  8025ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8025ed:	75 39                	jne    802628 <__udivdi3+0x98>
  8025ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8025f2:	0f 86 a0 00 00 00    	jbe    802698 <__udivdi3+0x108>
  8025f8:	39 f8                	cmp    %edi,%eax
  8025fa:	0f 82 98 00 00 00    	jb     802698 <__udivdi3+0x108>
  802600:	31 ff                	xor    %edi,%edi
  802602:	31 c9                	xor    %ecx,%ecx
  802604:	89 c8                	mov    %ecx,%eax
  802606:	89 fa                	mov    %edi,%edx
  802608:	83 c4 10             	add    $0x10,%esp
  80260b:	5e                   	pop    %esi
  80260c:	5f                   	pop    %edi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    
  80260f:	90                   	nop
  802610:	89 d1                	mov    %edx,%ecx
  802612:	89 fa                	mov    %edi,%edx
  802614:	89 c8                	mov    %ecx,%eax
  802616:	31 ff                	xor    %edi,%edi
  802618:	f7 f6                	div    %esi
  80261a:	89 c1                	mov    %eax,%ecx
  80261c:	89 fa                	mov    %edi,%edx
  80261e:	89 c8                	mov    %ecx,%eax
  802620:	83 c4 10             	add    $0x10,%esp
  802623:	5e                   	pop    %esi
  802624:	5f                   	pop    %edi
  802625:	5d                   	pop    %ebp
  802626:	c3                   	ret    
  802627:	90                   	nop
  802628:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80262c:	89 f2                	mov    %esi,%edx
  80262e:	d3 e0                	shl    %cl,%eax
  802630:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802633:	b8 20 00 00 00       	mov    $0x20,%eax
  802638:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80263b:	89 c1                	mov    %eax,%ecx
  80263d:	d3 ea                	shr    %cl,%edx
  80263f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802643:	0b 55 ec             	or     -0x14(%ebp),%edx
  802646:	d3 e6                	shl    %cl,%esi
  802648:	89 c1                	mov    %eax,%ecx
  80264a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80264d:	89 fe                	mov    %edi,%esi
  80264f:	d3 ee                	shr    %cl,%esi
  802651:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802655:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80265b:	d3 e7                	shl    %cl,%edi
  80265d:	89 c1                	mov    %eax,%ecx
  80265f:	d3 ea                	shr    %cl,%edx
  802661:	09 d7                	or     %edx,%edi
  802663:	89 f2                	mov    %esi,%edx
  802665:	89 f8                	mov    %edi,%eax
  802667:	f7 75 ec             	divl   -0x14(%ebp)
  80266a:	89 d6                	mov    %edx,%esi
  80266c:	89 c7                	mov    %eax,%edi
  80266e:	f7 65 e8             	mull   -0x18(%ebp)
  802671:	39 d6                	cmp    %edx,%esi
  802673:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802676:	72 30                	jb     8026a8 <__udivdi3+0x118>
  802678:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80267b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80267f:	d3 e2                	shl    %cl,%edx
  802681:	39 c2                	cmp    %eax,%edx
  802683:	73 05                	jae    80268a <__udivdi3+0xfa>
  802685:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802688:	74 1e                	je     8026a8 <__udivdi3+0x118>
  80268a:	89 f9                	mov    %edi,%ecx
  80268c:	31 ff                	xor    %edi,%edi
  80268e:	e9 71 ff ff ff       	jmp    802604 <__udivdi3+0x74>
  802693:	90                   	nop
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	31 ff                	xor    %edi,%edi
  80269a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80269f:	e9 60 ff ff ff       	jmp    802604 <__udivdi3+0x74>
  8026a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8026ab:	31 ff                	xor    %edi,%edi
  8026ad:	89 c8                	mov    %ecx,%eax
  8026af:	89 fa                	mov    %edi,%edx
  8026b1:	83 c4 10             	add    $0x10,%esp
  8026b4:	5e                   	pop    %esi
  8026b5:	5f                   	pop    %edi
  8026b6:	5d                   	pop    %ebp
  8026b7:	c3                   	ret    
	...

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	89 e5                	mov    %esp,%ebp
  8026c3:	57                   	push   %edi
  8026c4:	56                   	push   %esi
  8026c5:	83 ec 20             	sub    $0x20,%esp
  8026c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8026cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8026d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026d4:	85 d2                	test   %edx,%edx
  8026d6:	89 c8                	mov    %ecx,%eax
  8026d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8026db:	75 13                	jne    8026f0 <__umoddi3+0x30>
  8026dd:	39 f7                	cmp    %esi,%edi
  8026df:	76 3f                	jbe    802720 <__umoddi3+0x60>
  8026e1:	89 f2                	mov    %esi,%edx
  8026e3:	f7 f7                	div    %edi
  8026e5:	89 d0                	mov    %edx,%eax
  8026e7:	31 d2                	xor    %edx,%edx
  8026e9:	83 c4 20             	add    $0x20,%esp
  8026ec:	5e                   	pop    %esi
  8026ed:	5f                   	pop    %edi
  8026ee:	5d                   	pop    %ebp
  8026ef:	c3                   	ret    
  8026f0:	39 f2                	cmp    %esi,%edx
  8026f2:	77 4c                	ja     802740 <__umoddi3+0x80>
  8026f4:	0f bd ca             	bsr    %edx,%ecx
  8026f7:	83 f1 1f             	xor    $0x1f,%ecx
  8026fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8026fd:	75 51                	jne    802750 <__umoddi3+0x90>
  8026ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802702:	0f 87 e0 00 00 00    	ja     8027e8 <__umoddi3+0x128>
  802708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270b:	29 f8                	sub    %edi,%eax
  80270d:	19 d6                	sbb    %edx,%esi
  80270f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802715:	89 f2                	mov    %esi,%edx
  802717:	83 c4 20             	add    $0x20,%esp
  80271a:	5e                   	pop    %esi
  80271b:	5f                   	pop    %edi
  80271c:	5d                   	pop    %ebp
  80271d:	c3                   	ret    
  80271e:	66 90                	xchg   %ax,%ax
  802720:	85 ff                	test   %edi,%edi
  802722:	75 0b                	jne    80272f <__umoddi3+0x6f>
  802724:	b8 01 00 00 00       	mov    $0x1,%eax
  802729:	31 d2                	xor    %edx,%edx
  80272b:	f7 f7                	div    %edi
  80272d:	89 c7                	mov    %eax,%edi
  80272f:	89 f0                	mov    %esi,%eax
  802731:	31 d2                	xor    %edx,%edx
  802733:	f7 f7                	div    %edi
  802735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802738:	f7 f7                	div    %edi
  80273a:	eb a9                	jmp    8026e5 <__umoddi3+0x25>
  80273c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 c8                	mov    %ecx,%eax
  802742:	89 f2                	mov    %esi,%edx
  802744:	83 c4 20             	add    $0x20,%esp
  802747:	5e                   	pop    %esi
  802748:	5f                   	pop    %edi
  802749:	5d                   	pop    %ebp
  80274a:	c3                   	ret    
  80274b:	90                   	nop
  80274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802750:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802754:	d3 e2                	shl    %cl,%edx
  802756:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802759:	ba 20 00 00 00       	mov    $0x20,%edx
  80275e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802761:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802764:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802768:	89 fa                	mov    %edi,%edx
  80276a:	d3 ea                	shr    %cl,%edx
  80276c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802770:	0b 55 f4             	or     -0xc(%ebp),%edx
  802773:	d3 e7                	shl    %cl,%edi
  802775:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802779:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80277c:	89 f2                	mov    %esi,%edx
  80277e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802781:	89 c7                	mov    %eax,%edi
  802783:	d3 ea                	shr    %cl,%edx
  802785:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802789:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80278c:	89 c2                	mov    %eax,%edx
  80278e:	d3 e6                	shl    %cl,%esi
  802790:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802794:	d3 ea                	shr    %cl,%edx
  802796:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80279a:	09 d6                	or     %edx,%esi
  80279c:	89 f0                	mov    %esi,%eax
  80279e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8027a1:	d3 e7                	shl    %cl,%edi
  8027a3:	89 f2                	mov    %esi,%edx
  8027a5:	f7 75 f4             	divl   -0xc(%ebp)
  8027a8:	89 d6                	mov    %edx,%esi
  8027aa:	f7 65 e8             	mull   -0x18(%ebp)
  8027ad:	39 d6                	cmp    %edx,%esi
  8027af:	72 2b                	jb     8027dc <__umoddi3+0x11c>
  8027b1:	39 c7                	cmp    %eax,%edi
  8027b3:	72 23                	jb     8027d8 <__umoddi3+0x118>
  8027b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027b9:	29 c7                	sub    %eax,%edi
  8027bb:	19 d6                	sbb    %edx,%esi
  8027bd:	89 f0                	mov    %esi,%eax
  8027bf:	89 f2                	mov    %esi,%edx
  8027c1:	d3 ef                	shr    %cl,%edi
  8027c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027c7:	d3 e0                	shl    %cl,%eax
  8027c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027cd:	09 f8                	or     %edi,%eax
  8027cf:	d3 ea                	shr    %cl,%edx
  8027d1:	83 c4 20             	add    $0x20,%esp
  8027d4:	5e                   	pop    %esi
  8027d5:	5f                   	pop    %edi
  8027d6:	5d                   	pop    %ebp
  8027d7:	c3                   	ret    
  8027d8:	39 d6                	cmp    %edx,%esi
  8027da:	75 d9                	jne    8027b5 <__umoddi3+0xf5>
  8027dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8027df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8027e2:	eb d1                	jmp    8027b5 <__umoddi3+0xf5>
  8027e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e8:	39 f2                	cmp    %esi,%edx
  8027ea:	0f 82 18 ff ff ff    	jb     802708 <__umoddi3+0x48>
  8027f0:	e9 1d ff ff ff       	jmp    802712 <__umoddi3+0x52>
