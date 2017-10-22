
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
  80004d:	e8 0e 14 00 00       	call   801460 <set_pgfault_handler>
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
  800077:	c7 04 24 c0 21 80 00 	movl   $0x8021c0,(%esp)
  80007e:	e8 e2 00 00 00       	call   800165 <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 2a 13 00 00       	call   8013b2 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 62 13 00 00       	call   8013f2 <sys_env_destroy>
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
  8000a6:	e8 07 13 00 00       	call   8013b2 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	89 c2                	mov    %eax,%edx
  8000b2:	c1 e2 07             	shl    $0x7,%edx
  8000b5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000bc:	a3 04 40 80 00       	mov    %eax,0x804004
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
  8000ee:	e8 c8 18 00 00       	call   8019bb <close_all>
	sys_env_destroy(0);
  8000f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fa:	e8 f3 12 00 00       	call   8013f2 <sys_env_destroy>
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
  80023f:	e8 fc 1c 00 00       	call   801f40 <__udivdi3>
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
  8002a7:	e8 c4 1d 00 00       	call   802070 <__umoddi3>
  8002ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b0:	0f be 80 e6 21 80 00 	movsbl 0x8021e6(%eax),%eax
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
  80039a:	ff 24 95 c0 23 80 00 	jmp    *0x8023c0(,%edx,4)
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
  800457:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	75 26                	jne    800488 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 f7 21 80 	movl   $0x8021f7,0x8(%esp)
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
  80048c:	c7 44 24 08 00 22 80 	movl   $0x802200,0x8(%esp)
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
  8004ca:	be 03 22 80 00       	mov    $0x802203,%esi
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
  800774:	e8 c7 17 00 00       	call   801f40 <__udivdi3>
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
  8007c0:	e8 ab 18 00 00       	call   802070 <__umoddi3>
  8007c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c9:	0f be 80 e6 21 80 00 	movsbl 0x8021e6(%eax),%eax
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
  800875:	c7 44 24 0c 1c 23 80 	movl   $0x80231c,0xc(%esp)
  80087c:	00 
  80087d:	c7 44 24 08 00 22 80 	movl   $0x802200,0x8(%esp)
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
  8008ab:	c7 44 24 0c 54 23 80 	movl   $0x802354,0xc(%esp)
  8008b2:	00 
  8008b3:	c7 44 24 08 00 22 80 	movl   $0x802200,0x8(%esp)
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
  80093f:	e8 2c 17 00 00       	call   802070 <__umoddi3>
  800944:	89 74 24 04          	mov    %esi,0x4(%esp)
  800948:	0f be 80 e6 21 80 00 	movsbl 0x8021e6(%eax),%eax
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
  800981:	e8 ea 16 00 00       	call   802070 <__umoddi3>
  800986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098a:	0f be 80 e6 21 80 00 	movsbl 0x8021e6(%eax),%eax
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
  800f92:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  800f99:	00 
  800f9a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fa1:	00 
  800fa2:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  800fa9:	e8 f6 0d 00 00       	call   801da4 <_panic>
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
  80103e:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  801045:	00 
  801046:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80104d:	00 
  80104e:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  801055:	e8 4a 0d 00 00       	call   801da4 <_panic>

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
  8010eb:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010fa:	00 
  8010fb:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  801102:	e8 9d 0c 00 00       	call   801da4 <_panic>

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
  801157:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  80116e:	e8 31 0c 00 00       	call   801da4 <_panic>

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
  8011c3:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  8011da:	e8 c5 0b 00 00       	call   801da4 <_panic>

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
  80122f:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  801236:	00 
  801237:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80123e:	00 
  80123f:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  801246:	e8 59 0b 00 00       	call   801da4 <_panic>

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
  80129d:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012ac:	00 
  8012ad:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  8012b4:	e8 eb 0a 00 00       	call   801da4 <_panic>

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
  80130a:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  801311:	00 
  801312:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801319:	00 
  80131a:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  801321:	e8 7e 0a 00 00       	call   801da4 <_panic>

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
  801437:	c7 44 24 08 60 25 80 	movl   $0x802560,0x8(%esp)
  80143e:	00 
  80143f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801446:	00 
  801447:	c7 04 24 7d 25 80 00 	movl   $0x80257d,(%esp)
  80144e:	e8 51 09 00 00       	call   801da4 <_panic>

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

00801460 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801466:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  80146d:	75 30                	jne    80149f <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80146f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801476:	00 
  801477:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80147e:	ee 
  80147f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801486:	e8 38 fe ff ff       	call   8012c3 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80148b:	c7 44 24 04 ac 14 80 	movl   $0x8014ac,0x4(%esp)
  801492:	00 
  801493:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80149a:	e8 06 fc ff ff       	call   8010a5 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80149f:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a2:	a3 08 40 80 00       	mov    %eax,0x804008
}
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    
  8014a9:	00 00                	add    %al,(%eax)
	...

008014ac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014ad:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  8014b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014b4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8014b7:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8014bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8014bf:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8014c2:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8014c4:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8014c8:	83 c4 08             	add    $0x8,%esp
        popal
  8014cb:	61                   	popa   
        addl $0x4,%esp
  8014cc:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8014cf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8014d0:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8014d1:	c3                   	ret    
	...

008014e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014eb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	89 04 24             	mov    %eax,(%esp)
  8014fc:	e8 df ff ff ff       	call   8014e0 <fd2num>
  801501:	05 20 00 0d 00       	add    $0xd0020,%eax
  801506:	c1 e0 0c             	shl    $0xc,%eax
}
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	57                   	push   %edi
  80150f:	56                   	push   %esi
  801510:	53                   	push   %ebx
  801511:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801514:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801519:	a8 01                	test   $0x1,%al
  80151b:	74 36                	je     801553 <fd_alloc+0x48>
  80151d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801522:	a8 01                	test   $0x1,%al
  801524:	74 2d                	je     801553 <fd_alloc+0x48>
  801526:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80152b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801530:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801535:	89 c3                	mov    %eax,%ebx
  801537:	89 c2                	mov    %eax,%edx
  801539:	c1 ea 16             	shr    $0x16,%edx
  80153c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80153f:	f6 c2 01             	test   $0x1,%dl
  801542:	74 14                	je     801558 <fd_alloc+0x4d>
  801544:	89 c2                	mov    %eax,%edx
  801546:	c1 ea 0c             	shr    $0xc,%edx
  801549:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80154c:	f6 c2 01             	test   $0x1,%dl
  80154f:	75 10                	jne    801561 <fd_alloc+0x56>
  801551:	eb 05                	jmp    801558 <fd_alloc+0x4d>
  801553:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801558:	89 1f                	mov    %ebx,(%edi)
  80155a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80155f:	eb 17                	jmp    801578 <fd_alloc+0x6d>
  801561:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801566:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80156b:	75 c8                	jne    801535 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80156d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801573:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801578:	5b                   	pop    %ebx
  801579:	5e                   	pop    %esi
  80157a:	5f                   	pop    %edi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    

0080157d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801580:	8b 45 08             	mov    0x8(%ebp),%eax
  801583:	83 f8 1f             	cmp    $0x1f,%eax
  801586:	77 36                	ja     8015be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801588:	05 00 00 0d 00       	add    $0xd0000,%eax
  80158d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801590:	89 c2                	mov    %eax,%edx
  801592:	c1 ea 16             	shr    $0x16,%edx
  801595:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80159c:	f6 c2 01             	test   $0x1,%dl
  80159f:	74 1d                	je     8015be <fd_lookup+0x41>
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	c1 ea 0c             	shr    $0xc,%edx
  8015a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ad:	f6 c2 01             	test   $0x1,%dl
  8015b0:	74 0c                	je     8015be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b5:	89 02                	mov    %eax,(%edx)
  8015b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8015bc:	eb 05                	jmp    8015c3 <fd_lookup+0x46>
  8015be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015c3:	5d                   	pop    %ebp
  8015c4:	c3                   	ret    

008015c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d5:	89 04 24             	mov    %eax,(%esp)
  8015d8:	e8 a0 ff ff ff       	call   80157d <fd_lookup>
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 0e                	js     8015ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e7:	89 50 04             	mov    %edx,0x4(%eax)
  8015ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    

008015f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	56                   	push   %esi
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 10             	sub    $0x10,%esp
  8015f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8015ff:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801604:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801609:	be 08 26 80 00       	mov    $0x802608,%esi
		if (devtab[i]->dev_id == dev_id) {
  80160e:	39 08                	cmp    %ecx,(%eax)
  801610:	75 10                	jne    801622 <dev_lookup+0x31>
  801612:	eb 04                	jmp    801618 <dev_lookup+0x27>
  801614:	39 08                	cmp    %ecx,(%eax)
  801616:	75 0a                	jne    801622 <dev_lookup+0x31>
			*dev = devtab[i];
  801618:	89 03                	mov    %eax,(%ebx)
  80161a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80161f:	90                   	nop
  801620:	eb 31                	jmp    801653 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801622:	83 c2 01             	add    $0x1,%edx
  801625:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801628:	85 c0                	test   %eax,%eax
  80162a:	75 e8                	jne    801614 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80162c:	a1 04 40 80 00       	mov    0x804004,%eax
  801631:	8b 40 48             	mov    0x48(%eax),%eax
  801634:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163c:	c7 04 24 8c 25 80 00 	movl   $0x80258c,(%esp)
  801643:	e8 1d eb ff ff       	call   800165 <cprintf>
	*dev = 0;
  801648:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80164e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 24             	sub    $0x24,%esp
  801661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801664:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166b:	8b 45 08             	mov    0x8(%ebp),%eax
  80166e:	89 04 24             	mov    %eax,(%esp)
  801671:	e8 07 ff ff ff       	call   80157d <fd_lookup>
  801676:	85 c0                	test   %eax,%eax
  801678:	78 53                	js     8016cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	8b 00                	mov    (%eax),%eax
  801686:	89 04 24             	mov    %eax,(%esp)
  801689:	e8 63 ff ff ff       	call   8015f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 3b                	js     8016cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801692:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801697:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80169e:	74 2d                	je     8016cd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016aa:	00 00 00 
	stat->st_isdir = 0;
  8016ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b4:	00 00 00 
	stat->st_dev = dev;
  8016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c7:	89 14 24             	mov    %edx,(%esp)
  8016ca:	ff 50 14             	call   *0x14(%eax)
}
  8016cd:	83 c4 24             	add    $0x24,%esp
  8016d0:	5b                   	pop    %ebx
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 24             	sub    $0x24,%esp
  8016da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e4:	89 1c 24             	mov    %ebx,(%esp)
  8016e7:	e8 91 fe ff ff       	call   80157d <fd_lookup>
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 5f                	js     80174f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fa:	8b 00                	mov    (%eax),%eax
  8016fc:	89 04 24             	mov    %eax,(%esp)
  8016ff:	e8 ed fe ff ff       	call   8015f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	85 c0                	test   %eax,%eax
  801706:	78 47                	js     80174f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801708:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80170b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80170f:	75 23                	jne    801734 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801711:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801716:	8b 40 48             	mov    0x48(%eax),%eax
  801719:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801721:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  801728:	e8 38 ea ff ff       	call   800165 <cprintf>
  80172d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801732:	eb 1b                	jmp    80174f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801737:	8b 48 18             	mov    0x18(%eax),%ecx
  80173a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80173f:	85 c9                	test   %ecx,%ecx
  801741:	74 0c                	je     80174f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801743:	8b 45 0c             	mov    0xc(%ebp),%eax
  801746:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174a:	89 14 24             	mov    %edx,(%esp)
  80174d:	ff d1                	call   *%ecx
}
  80174f:	83 c4 24             	add    $0x24,%esp
  801752:	5b                   	pop    %ebx
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	83 ec 24             	sub    $0x24,%esp
  80175c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801762:	89 44 24 04          	mov    %eax,0x4(%esp)
  801766:	89 1c 24             	mov    %ebx,(%esp)
  801769:	e8 0f fe ff ff       	call   80157d <fd_lookup>
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 66                	js     8017d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177c:	8b 00                	mov    (%eax),%eax
  80177e:	89 04 24             	mov    %eax,(%esp)
  801781:	e8 6b fe ff ff       	call   8015f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801786:	85 c0                	test   %eax,%eax
  801788:	78 4e                	js     8017d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80178a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80178d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801791:	75 23                	jne    8017b6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801793:	a1 04 40 80 00       	mov    0x804004,%eax
  801798:	8b 40 48             	mov    0x48(%eax),%eax
  80179b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80179f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a3:	c7 04 24 cd 25 80 00 	movl   $0x8025cd,(%esp)
  8017aa:	e8 b6 e9 ff ff       	call   800165 <cprintf>
  8017af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8017b4:	eb 22                	jmp    8017d8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8017bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017c1:	85 c9                	test   %ecx,%ecx
  8017c3:	74 13                	je     8017d8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d3:	89 14 24             	mov    %edx,(%esp)
  8017d6:	ff d1                	call   *%ecx
}
  8017d8:	83 c4 24             	add    $0x24,%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 24             	sub    $0x24,%esp
  8017e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ef:	89 1c 24             	mov    %ebx,(%esp)
  8017f2:	e8 86 fd ff ff       	call   80157d <fd_lookup>
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 6b                	js     801866 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801805:	8b 00                	mov    (%eax),%eax
  801807:	89 04 24             	mov    %eax,(%esp)
  80180a:	e8 e2 fd ff ff       	call   8015f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 53                	js     801866 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801813:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801816:	8b 42 08             	mov    0x8(%edx),%eax
  801819:	83 e0 03             	and    $0x3,%eax
  80181c:	83 f8 01             	cmp    $0x1,%eax
  80181f:	75 23                	jne    801844 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801821:	a1 04 40 80 00       	mov    0x804004,%eax
  801826:	8b 40 48             	mov    0x48(%eax),%eax
  801829:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80182d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801831:	c7 04 24 ea 25 80 00 	movl   $0x8025ea,(%esp)
  801838:	e8 28 e9 ff ff       	call   800165 <cprintf>
  80183d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801842:	eb 22                	jmp    801866 <read+0x88>
	}
	if (!dev->dev_read)
  801844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801847:	8b 48 08             	mov    0x8(%eax),%ecx
  80184a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80184f:	85 c9                	test   %ecx,%ecx
  801851:	74 13                	je     801866 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801853:	8b 45 10             	mov    0x10(%ebp),%eax
  801856:	89 44 24 08          	mov    %eax,0x8(%esp)
  80185a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801861:	89 14 24             	mov    %edx,(%esp)
  801864:	ff d1                	call   *%ecx
}
  801866:	83 c4 24             	add    $0x24,%esp
  801869:	5b                   	pop    %ebx
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	57                   	push   %edi
  801870:	56                   	push   %esi
  801871:	53                   	push   %ebx
  801872:	83 ec 1c             	sub    $0x1c,%esp
  801875:	8b 7d 08             	mov    0x8(%ebp),%edi
  801878:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80187b:	ba 00 00 00 00       	mov    $0x0,%edx
  801880:	bb 00 00 00 00       	mov    $0x0,%ebx
  801885:	b8 00 00 00 00       	mov    $0x0,%eax
  80188a:	85 f6                	test   %esi,%esi
  80188c:	74 29                	je     8018b7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80188e:	89 f0                	mov    %esi,%eax
  801890:	29 d0                	sub    %edx,%eax
  801892:	89 44 24 08          	mov    %eax,0x8(%esp)
  801896:	03 55 0c             	add    0xc(%ebp),%edx
  801899:	89 54 24 04          	mov    %edx,0x4(%esp)
  80189d:	89 3c 24             	mov    %edi,(%esp)
  8018a0:	e8 39 ff ff ff       	call   8017de <read>
		if (m < 0)
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 0e                	js     8018b7 <readn+0x4b>
			return m;
		if (m == 0)
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	74 08                	je     8018b5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018ad:	01 c3                	add    %eax,%ebx
  8018af:	89 da                	mov    %ebx,%edx
  8018b1:	39 f3                	cmp    %esi,%ebx
  8018b3:	72 d9                	jb     80188e <readn+0x22>
  8018b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018b7:	83 c4 1c             	add    $0x1c,%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5f                   	pop    %edi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 20             	sub    $0x20,%esp
  8018c7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018ca:	89 34 24             	mov    %esi,(%esp)
  8018cd:	e8 0e fc ff ff       	call   8014e0 <fd2num>
  8018d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018d9:	89 04 24             	mov    %eax,(%esp)
  8018dc:	e8 9c fc ff ff       	call   80157d <fd_lookup>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 05                	js     8018ec <fd_close+0x2d>
  8018e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8018ea:	74 0c                	je     8018f8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8018ec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8018f0:	19 c0                	sbb    %eax,%eax
  8018f2:	f7 d0                	not    %eax
  8018f4:	21 c3                	and    %eax,%ebx
  8018f6:	eb 3d                	jmp    801935 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ff:	8b 06                	mov    (%esi),%eax
  801901:	89 04 24             	mov    %eax,(%esp)
  801904:	e8 e8 fc ff ff       	call   8015f1 <dev_lookup>
  801909:	89 c3                	mov    %eax,%ebx
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 16                	js     801925 <fd_close+0x66>
		if (dev->dev_close)
  80190f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801912:	8b 40 10             	mov    0x10(%eax),%eax
  801915:	bb 00 00 00 00       	mov    $0x0,%ebx
  80191a:	85 c0                	test   %eax,%eax
  80191c:	74 07                	je     801925 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  80191e:	89 34 24             	mov    %esi,(%esp)
  801921:	ff d0                	call   *%eax
  801923:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801925:	89 74 24 04          	mov    %esi,0x4(%esp)
  801929:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801930:	e8 b4 f8 ff ff       	call   8011e9 <sys_page_unmap>
	return r;
}
  801935:	89 d8                	mov    %ebx,%eax
  801937:	83 c4 20             	add    $0x20,%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194b:	8b 45 08             	mov    0x8(%ebp),%eax
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	e8 27 fc ff ff       	call   80157d <fd_lookup>
  801956:	85 c0                	test   %eax,%eax
  801958:	78 13                	js     80196d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80195a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801961:	00 
  801962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801965:	89 04 24             	mov    %eax,(%esp)
  801968:	e8 52 ff ff ff       	call   8018bf <fd_close>
}
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	83 ec 18             	sub    $0x18,%esp
  801975:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801978:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80197b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801982:	00 
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	89 04 24             	mov    %eax,(%esp)
  801989:	e8 79 03 00 00       	call   801d07 <open>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	85 c0                	test   %eax,%eax
  801992:	78 1b                	js     8019af <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801994:	8b 45 0c             	mov    0xc(%ebp),%eax
  801997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199b:	89 1c 24             	mov    %ebx,(%esp)
  80199e:	e8 b7 fc ff ff       	call   80165a <fstat>
  8019a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8019a5:	89 1c 24             	mov    %ebx,(%esp)
  8019a8:	e8 91 ff ff ff       	call   80193e <close>
  8019ad:	89 f3                	mov    %esi,%ebx
	return r;
}
  8019af:	89 d8                	mov    %ebx,%eax
  8019b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019b7:	89 ec                	mov    %ebp,%esp
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	53                   	push   %ebx
  8019bf:	83 ec 14             	sub    $0x14,%esp
  8019c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8019c7:	89 1c 24             	mov    %ebx,(%esp)
  8019ca:	e8 6f ff ff ff       	call   80193e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8019cf:	83 c3 01             	add    $0x1,%ebx
  8019d2:	83 fb 20             	cmp    $0x20,%ebx
  8019d5:	75 f0                	jne    8019c7 <close_all+0xc>
		close(i);
}
  8019d7:	83 c4 14             	add    $0x14,%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 58             	sub    $0x58,%esp
  8019e3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019e6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019e9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8019ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8019ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	89 04 24             	mov    %eax,(%esp)
  8019fc:	e8 7c fb ff ff       	call   80157d <fd_lookup>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	85 c0                	test   %eax,%eax
  801a05:	0f 88 e0 00 00 00    	js     801aeb <dup+0x10e>
		return r;
	close(newfdnum);
  801a0b:	89 3c 24             	mov    %edi,(%esp)
  801a0e:	e8 2b ff ff ff       	call   80193e <close>

	newfd = INDEX2FD(newfdnum);
  801a13:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a19:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	e8 c9 fa ff ff       	call   8014f0 <fd2data>
  801a27:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a29:	89 34 24             	mov    %esi,(%esp)
  801a2c:	e8 bf fa ff ff       	call   8014f0 <fd2data>
  801a31:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801a34:	89 da                	mov    %ebx,%edx
  801a36:	89 d8                	mov    %ebx,%eax
  801a38:	c1 e8 16             	shr    $0x16,%eax
  801a3b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a42:	a8 01                	test   $0x1,%al
  801a44:	74 43                	je     801a89 <dup+0xac>
  801a46:	c1 ea 0c             	shr    $0xc,%edx
  801a49:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a50:	a8 01                	test   $0x1,%al
  801a52:	74 35                	je     801a89 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a54:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a5b:	25 07 0e 00 00       	and    $0xe07,%eax
  801a60:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a72:	00 
  801a73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7e:	e8 d2 f7 ff ff       	call   801255 <sys_page_map>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 3f                	js     801ac8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a8c:	89 c2                	mov    %eax,%edx
  801a8e:	c1 ea 0c             	shr    $0xc,%edx
  801a91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a98:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a9e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801aa2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801aa6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aad:	00 
  801aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab9:	e8 97 f7 ff ff       	call   801255 <sys_page_map>
  801abe:	89 c3                	mov    %eax,%ebx
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	78 04                	js     801ac8 <dup+0xeb>
  801ac4:	89 fb                	mov    %edi,%ebx
  801ac6:	eb 23                	jmp    801aeb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ac8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801acc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad3:	e8 11 f7 ff ff       	call   8011e9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ad8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae6:	e8 fe f6 ff ff       	call   8011e9 <sys_page_unmap>
	return r;
}
  801aeb:	89 d8                	mov    %ebx,%eax
  801aed:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801af0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801af3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801af6:	89 ec                	mov    %ebp,%esp
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    
	...

00801afc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 18             	sub    $0x18,%esp
  801b02:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b05:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b08:	89 c3                	mov    %eax,%ebx
  801b0a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b0c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b13:	75 11                	jne    801b26 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b15:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b1c:	e8 df 02 00 00       	call   801e00 <ipc_find_env>
  801b21:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b26:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b2d:	00 
  801b2e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b35:	00 
  801b36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b3a:	a1 00 40 80 00       	mov    0x804000,%eax
  801b3f:	89 04 24             	mov    %eax,(%esp)
  801b42:	e8 04 03 00 00       	call   801e4b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b4e:	00 
  801b4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5a:	e8 6a 03 00 00       	call   801ec9 <ipc_recv>
}
  801b5f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b62:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b65:	89 ec                	mov    %ebp,%esp
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	8b 40 0c             	mov    0xc(%eax),%eax
  801b75:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b82:	ba 00 00 00 00       	mov    $0x0,%edx
  801b87:	b8 02 00 00 00       	mov    $0x2,%eax
  801b8c:	e8 6b ff ff ff       	call   801afc <fsipc>
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b9f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba9:	b8 06 00 00 00       	mov    $0x6,%eax
  801bae:	e8 49 ff ff ff       	call   801afc <fsipc>
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc5:	e8 32 ff ff ff       	call   801afc <fsipc>
}
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 14             	sub    $0x14,%esp
  801bd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd9:	8b 40 0c             	mov    0xc(%eax),%eax
  801bdc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801be1:	ba 00 00 00 00       	mov    $0x0,%edx
  801be6:	b8 05 00 00 00       	mov    $0x5,%eax
  801beb:	e8 0c ff ff ff       	call   801afc <fsipc>
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	78 2b                	js     801c1f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bf4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bfb:	00 
  801bfc:	89 1c 24             	mov    %ebx,(%esp)
  801bff:	e8 96 ee ff ff       	call   800a9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c04:	a1 80 50 80 00       	mov    0x805080,%eax
  801c09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c0f:	a1 84 50 80 00       	mov    0x805084,%eax
  801c14:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c1a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c1f:	83 c4 14             	add    $0x14,%esp
  801c22:	5b                   	pop    %ebx
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 18             	sub    $0x18,%esp
  801c2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c33:	76 05                	jbe    801c3a <devfile_write+0x15>
  801c35:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  801c3d:	8b 52 0c             	mov    0xc(%edx),%edx
  801c40:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801c46:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801c4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c56:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801c5d:	e8 23 f0 ff ff       	call   800c85 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801c62:	ba 00 00 00 00       	mov    $0x0,%edx
  801c67:	b8 04 00 00 00       	mov    $0x4,%eax
  801c6c:	e8 8b fe ff ff       	call   801afc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	53                   	push   %ebx
  801c77:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c80:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801c85:	8b 45 10             	mov    0x10(%ebp),%eax
  801c88:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c92:	b8 03 00 00 00       	mov    $0x3,%eax
  801c97:	e8 60 fe ff ff       	call   801afc <fsipc>
  801c9c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 17                	js     801cb9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801ca2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cad:	00 
  801cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb1:	89 04 24             	mov    %eax,(%esp)
  801cb4:	e8 cc ef ff ff       	call   800c85 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	83 c4 14             	add    $0x14,%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 14             	sub    $0x14,%esp
  801cc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801ccb:	89 1c 24             	mov    %ebx,(%esp)
  801cce:	e8 7d ed ff ff       	call   800a50 <strlen>
  801cd3:	89 c2                	mov    %eax,%edx
  801cd5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801cda:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ce0:	7f 1f                	jg     801d01 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801ce2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ced:	e8 a8 ed ff ff       	call   800a9a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf7:	b8 07 00 00 00       	mov    $0x7,%eax
  801cfc:	e8 fb fd ff ff       	call   801afc <fsipc>
}
  801d01:	83 c4 14             	add    $0x14,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 28             	sub    $0x28,%esp
  801d0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d10:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d13:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801d16:	89 34 24             	mov    %esi,(%esp)
  801d19:	e8 32 ed ff ff       	call   800a50 <strlen>
  801d1e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801d23:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d28:	7f 6d                	jg     801d97 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801d2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2d:	89 04 24             	mov    %eax,(%esp)
  801d30:	e8 d6 f7 ff ff       	call   80150b <fd_alloc>
  801d35:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d37:	85 c0                	test   %eax,%eax
  801d39:	78 5c                	js     801d97 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801d43:	89 34 24             	mov    %esi,(%esp)
  801d46:	e8 05 ed ff ff       	call   800a50 <strlen>
  801d4b:	83 c0 01             	add    $0x1,%eax
  801d4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d56:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d5d:	e8 23 ef ff ff       	call   800c85 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d65:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6a:	e8 8d fd ff ff       	call   801afc <fsipc>
  801d6f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801d71:	85 c0                	test   %eax,%eax
  801d73:	79 15                	jns    801d8a <open+0x83>
             fd_close(fd,0);
  801d75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d7c:	00 
  801d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d80:	89 04 24             	mov    %eax,(%esp)
  801d83:	e8 37 fb ff ff       	call   8018bf <fd_close>
             return r;
  801d88:	eb 0d                	jmp    801d97 <open+0x90>
        }
        return fd2num(fd);
  801d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8d:	89 04 24             	mov    %eax,(%esp)
  801d90:	e8 4b f7 ff ff       	call   8014e0 <fd2num>
  801d95:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801d97:	89 d8                	mov    %ebx,%eax
  801d99:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d9c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d9f:	89 ec                	mov    %ebp,%esp
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    
	...

00801da4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801dac:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801daf:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801db5:	e8 f8 f5 ff ff       	call   8013b2 <sys_getenvid>
  801dba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbd:	89 54 24 10          	mov    %edx,0x10(%esp)
  801dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  801dc4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801dc8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd0:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  801dd7:	e8 89 e3 ff ff       	call   800165 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ddc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de0:	8b 45 10             	mov    0x10(%ebp),%eax
  801de3:	89 04 24             	mov    %eax,(%esp)
  801de6:	e8 19 e3 ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  801deb:	c7 04 24 04 26 80 00 	movl   $0x802604,(%esp)
  801df2:	e8 6e e3 ff ff       	call   800165 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801df7:	cc                   	int3   
  801df8:	eb fd                	jmp    801df7 <_panic+0x53>
  801dfa:	00 00                	add    %al,(%eax)
  801dfc:	00 00                	add    %al,(%eax)
	...

00801e00 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e06:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801e0c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e11:	39 ca                	cmp    %ecx,%edx
  801e13:	75 04                	jne    801e19 <ipc_find_env+0x19>
  801e15:	b0 00                	mov    $0x0,%al
  801e17:	eb 12                	jmp    801e2b <ipc_find_env+0x2b>
  801e19:	89 c2                	mov    %eax,%edx
  801e1b:	c1 e2 07             	shl    $0x7,%edx
  801e1e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801e25:	8b 12                	mov    (%edx),%edx
  801e27:	39 ca                	cmp    %ecx,%edx
  801e29:	75 10                	jne    801e3b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801e2b:	89 c2                	mov    %eax,%edx
  801e2d:	c1 e2 07             	shl    $0x7,%edx
  801e30:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801e37:	8b 00                	mov    (%eax),%eax
  801e39:	eb 0e                	jmp    801e49 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e3b:	83 c0 01             	add    $0x1,%eax
  801e3e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e43:	75 d4                	jne    801e19 <ipc_find_env+0x19>
  801e45:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	57                   	push   %edi
  801e4f:	56                   	push   %esi
  801e50:	53                   	push   %ebx
  801e51:	83 ec 1c             	sub    $0x1c,%esp
  801e54:	8b 75 08             	mov    0x8(%ebp),%esi
  801e57:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801e5d:	85 db                	test   %ebx,%ebx
  801e5f:	74 19                	je     801e7a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801e61:	8b 45 14             	mov    0x14(%ebp),%eax
  801e64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e6c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e70:	89 34 24             	mov    %esi,(%esp)
  801e73:	e8 ec f1 ff ff       	call   801064 <sys_ipc_try_send>
  801e78:	eb 1b                	jmp    801e95 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801e7a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e81:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801e88:	ee 
  801e89:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e8d:	89 34 24             	mov    %esi,(%esp)
  801e90:	e8 cf f1 ff ff       	call   801064 <sys_ipc_try_send>
           if(ret == 0)
  801e95:	85 c0                	test   %eax,%eax
  801e97:	74 28                	je     801ec1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801e99:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9c:	74 1c                	je     801eba <ipc_send+0x6f>
              panic("ipc send error");
  801e9e:	c7 44 24 08 34 26 80 	movl   $0x802634,0x8(%esp)
  801ea5:	00 
  801ea6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801ead:	00 
  801eae:	c7 04 24 43 26 80 00 	movl   $0x802643,(%esp)
  801eb5:	e8 ea fe ff ff       	call   801da4 <_panic>
           sys_yield();
  801eba:	e8 71 f4 ff ff       	call   801330 <sys_yield>
        }
  801ebf:	eb 9c                	jmp    801e5d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801ec1:	83 c4 1c             	add    $0x1c,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
  801ece:	83 ec 10             	sub    $0x10,%esp
  801ed1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801eda:	85 c0                	test   %eax,%eax
  801edc:	75 0e                	jne    801eec <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801ede:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801ee5:	e8 0f f1 ff ff       	call   800ff9 <sys_ipc_recv>
  801eea:	eb 08                	jmp    801ef4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801eec:	89 04 24             	mov    %eax,(%esp)
  801eef:	e8 05 f1 ff ff       	call   800ff9 <sys_ipc_recv>
        if(ret == 0){
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	75 26                	jne    801f1e <ipc_recv+0x55>
           if(from_env_store)
  801ef8:	85 f6                	test   %esi,%esi
  801efa:	74 0a                	je     801f06 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801efc:	a1 04 40 80 00       	mov    0x804004,%eax
  801f01:	8b 40 78             	mov    0x78(%eax),%eax
  801f04:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801f06:	85 db                	test   %ebx,%ebx
  801f08:	74 0a                	je     801f14 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801f0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f0f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f12:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801f14:	a1 04 40 80 00       	mov    0x804004,%eax
  801f19:	8b 40 74             	mov    0x74(%eax),%eax
  801f1c:	eb 14                	jmp    801f32 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801f1e:	85 f6                	test   %esi,%esi
  801f20:	74 06                	je     801f28 <ipc_recv+0x5f>
              *from_env_store = 0;
  801f22:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801f28:	85 db                	test   %ebx,%ebx
  801f2a:	74 06                	je     801f32 <ipc_recv+0x69>
              *perm_store = 0;
  801f2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    
  801f39:	00 00                	add    %al,(%eax)
  801f3b:	00 00                	add    %al,(%eax)
  801f3d:	00 00                	add    %al,(%eax)
	...

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	57                   	push   %edi
  801f44:	56                   	push   %esi
  801f45:	83 ec 10             	sub    $0x10,%esp
  801f48:	8b 45 14             	mov    0x14(%ebp),%eax
  801f4b:	8b 55 08             	mov    0x8(%ebp),%edx
  801f4e:	8b 75 10             	mov    0x10(%ebp),%esi
  801f51:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f54:	85 c0                	test   %eax,%eax
  801f56:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801f59:	75 35                	jne    801f90 <__udivdi3+0x50>
  801f5b:	39 fe                	cmp    %edi,%esi
  801f5d:	77 61                	ja     801fc0 <__udivdi3+0x80>
  801f5f:	85 f6                	test   %esi,%esi
  801f61:	75 0b                	jne    801f6e <__udivdi3+0x2e>
  801f63:	b8 01 00 00 00       	mov    $0x1,%eax
  801f68:	31 d2                	xor    %edx,%edx
  801f6a:	f7 f6                	div    %esi
  801f6c:	89 c6                	mov    %eax,%esi
  801f6e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801f71:	31 d2                	xor    %edx,%edx
  801f73:	89 f8                	mov    %edi,%eax
  801f75:	f7 f6                	div    %esi
  801f77:	89 c7                	mov    %eax,%edi
  801f79:	89 c8                	mov    %ecx,%eax
  801f7b:	f7 f6                	div    %esi
  801f7d:	89 c1                	mov    %eax,%ecx
  801f7f:	89 fa                	mov    %edi,%edx
  801f81:	89 c8                	mov    %ecx,%eax
  801f83:	83 c4 10             	add    $0x10,%esp
  801f86:	5e                   	pop    %esi
  801f87:	5f                   	pop    %edi
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    
  801f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f90:	39 f8                	cmp    %edi,%eax
  801f92:	77 1c                	ja     801fb0 <__udivdi3+0x70>
  801f94:	0f bd d0             	bsr    %eax,%edx
  801f97:	83 f2 1f             	xor    $0x1f,%edx
  801f9a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f9d:	75 39                	jne    801fd8 <__udivdi3+0x98>
  801f9f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801fa2:	0f 86 a0 00 00 00    	jbe    802048 <__udivdi3+0x108>
  801fa8:	39 f8                	cmp    %edi,%eax
  801faa:	0f 82 98 00 00 00    	jb     802048 <__udivdi3+0x108>
  801fb0:	31 ff                	xor    %edi,%edi
  801fb2:	31 c9                	xor    %ecx,%ecx
  801fb4:	89 c8                	mov    %ecx,%eax
  801fb6:	89 fa                	mov    %edi,%edx
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	5e                   	pop    %esi
  801fbc:	5f                   	pop    %edi
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    
  801fbf:	90                   	nop
  801fc0:	89 d1                	mov    %edx,%ecx
  801fc2:	89 fa                	mov    %edi,%edx
  801fc4:	89 c8                	mov    %ecx,%eax
  801fc6:	31 ff                	xor    %edi,%edi
  801fc8:	f7 f6                	div    %esi
  801fca:	89 c1                	mov    %eax,%ecx
  801fcc:	89 fa                	mov    %edi,%edx
  801fce:	89 c8                	mov    %ecx,%eax
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	5e                   	pop    %esi
  801fd4:	5f                   	pop    %edi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    
  801fd7:	90                   	nop
  801fd8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fdc:	89 f2                	mov    %esi,%edx
  801fde:	d3 e0                	shl    %cl,%eax
  801fe0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fe3:	b8 20 00 00 00       	mov    $0x20,%eax
  801fe8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801feb:	89 c1                	mov    %eax,%ecx
  801fed:	d3 ea                	shr    %cl,%edx
  801fef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801ff3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801ff6:	d3 e6                	shl    %cl,%esi
  801ff8:	89 c1                	mov    %eax,%ecx
  801ffa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801ffd:	89 fe                	mov    %edi,%esi
  801fff:	d3 ee                	shr    %cl,%esi
  802001:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802005:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802008:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80200b:	d3 e7                	shl    %cl,%edi
  80200d:	89 c1                	mov    %eax,%ecx
  80200f:	d3 ea                	shr    %cl,%edx
  802011:	09 d7                	or     %edx,%edi
  802013:	89 f2                	mov    %esi,%edx
  802015:	89 f8                	mov    %edi,%eax
  802017:	f7 75 ec             	divl   -0x14(%ebp)
  80201a:	89 d6                	mov    %edx,%esi
  80201c:	89 c7                	mov    %eax,%edi
  80201e:	f7 65 e8             	mull   -0x18(%ebp)
  802021:	39 d6                	cmp    %edx,%esi
  802023:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802026:	72 30                	jb     802058 <__udivdi3+0x118>
  802028:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80202b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80202f:	d3 e2                	shl    %cl,%edx
  802031:	39 c2                	cmp    %eax,%edx
  802033:	73 05                	jae    80203a <__udivdi3+0xfa>
  802035:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802038:	74 1e                	je     802058 <__udivdi3+0x118>
  80203a:	89 f9                	mov    %edi,%ecx
  80203c:	31 ff                	xor    %edi,%edi
  80203e:	e9 71 ff ff ff       	jmp    801fb4 <__udivdi3+0x74>
  802043:	90                   	nop
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80204f:	e9 60 ff ff ff       	jmp    801fb4 <__udivdi3+0x74>
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80205b:	31 ff                	xor    %edi,%edi
  80205d:	89 c8                	mov    %ecx,%eax
  80205f:	89 fa                	mov    %edi,%edx
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
	...

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	57                   	push   %edi
  802074:	56                   	push   %esi
  802075:	83 ec 20             	sub    $0x20,%esp
  802078:	8b 55 14             	mov    0x14(%ebp),%edx
  80207b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80207e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802081:	8b 75 0c             	mov    0xc(%ebp),%esi
  802084:	85 d2                	test   %edx,%edx
  802086:	89 c8                	mov    %ecx,%eax
  802088:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80208b:	75 13                	jne    8020a0 <__umoddi3+0x30>
  80208d:	39 f7                	cmp    %esi,%edi
  80208f:	76 3f                	jbe    8020d0 <__umoddi3+0x60>
  802091:	89 f2                	mov    %esi,%edx
  802093:	f7 f7                	div    %edi
  802095:	89 d0                	mov    %edx,%eax
  802097:	31 d2                	xor    %edx,%edx
  802099:	83 c4 20             	add    $0x20,%esp
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    
  8020a0:	39 f2                	cmp    %esi,%edx
  8020a2:	77 4c                	ja     8020f0 <__umoddi3+0x80>
  8020a4:	0f bd ca             	bsr    %edx,%ecx
  8020a7:	83 f1 1f             	xor    $0x1f,%ecx
  8020aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020ad:	75 51                	jne    802100 <__umoddi3+0x90>
  8020af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8020b2:	0f 87 e0 00 00 00    	ja     802198 <__umoddi3+0x128>
  8020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bb:	29 f8                	sub    %edi,%eax
  8020bd:	19 d6                	sbb    %edx,%esi
  8020bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8020c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c5:	89 f2                	mov    %esi,%edx
  8020c7:	83 c4 20             	add    $0x20,%esp
  8020ca:	5e                   	pop    %esi
  8020cb:	5f                   	pop    %edi
  8020cc:	5d                   	pop    %ebp
  8020cd:	c3                   	ret    
  8020ce:	66 90                	xchg   %ax,%ax
  8020d0:	85 ff                	test   %edi,%edi
  8020d2:	75 0b                	jne    8020df <__umoddi3+0x6f>
  8020d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d9:	31 d2                	xor    %edx,%edx
  8020db:	f7 f7                	div    %edi
  8020dd:	89 c7                	mov    %eax,%edi
  8020df:	89 f0                	mov    %esi,%eax
  8020e1:	31 d2                	xor    %edx,%edx
  8020e3:	f7 f7                	div    %edi
  8020e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e8:	f7 f7                	div    %edi
  8020ea:	eb a9                	jmp    802095 <__umoddi3+0x25>
  8020ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	83 c4 20             	add    $0x20,%esp
  8020f7:	5e                   	pop    %esi
  8020f8:	5f                   	pop    %edi
  8020f9:	5d                   	pop    %ebp
  8020fa:	c3                   	ret    
  8020fb:	90                   	nop
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802104:	d3 e2                	shl    %cl,%edx
  802106:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802109:	ba 20 00 00 00       	mov    $0x20,%edx
  80210e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802111:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802114:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802118:	89 fa                	mov    %edi,%edx
  80211a:	d3 ea                	shr    %cl,%edx
  80211c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802120:	0b 55 f4             	or     -0xc(%ebp),%edx
  802123:	d3 e7                	shl    %cl,%edi
  802125:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802129:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80212c:	89 f2                	mov    %esi,%edx
  80212e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802131:	89 c7                	mov    %eax,%edi
  802133:	d3 ea                	shr    %cl,%edx
  802135:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802139:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80213c:	89 c2                	mov    %eax,%edx
  80213e:	d3 e6                	shl    %cl,%esi
  802140:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802144:	d3 ea                	shr    %cl,%edx
  802146:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80214a:	09 d6                	or     %edx,%esi
  80214c:	89 f0                	mov    %esi,%eax
  80214e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802151:	d3 e7                	shl    %cl,%edi
  802153:	89 f2                	mov    %esi,%edx
  802155:	f7 75 f4             	divl   -0xc(%ebp)
  802158:	89 d6                	mov    %edx,%esi
  80215a:	f7 65 e8             	mull   -0x18(%ebp)
  80215d:	39 d6                	cmp    %edx,%esi
  80215f:	72 2b                	jb     80218c <__umoddi3+0x11c>
  802161:	39 c7                	cmp    %eax,%edi
  802163:	72 23                	jb     802188 <__umoddi3+0x118>
  802165:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802169:	29 c7                	sub    %eax,%edi
  80216b:	19 d6                	sbb    %edx,%esi
  80216d:	89 f0                	mov    %esi,%eax
  80216f:	89 f2                	mov    %esi,%edx
  802171:	d3 ef                	shr    %cl,%edi
  802173:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802177:	d3 e0                	shl    %cl,%eax
  802179:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80217d:	09 f8                	or     %edi,%eax
  80217f:	d3 ea                	shr    %cl,%edx
  802181:	83 c4 20             	add    $0x20,%esp
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	39 d6                	cmp    %edx,%esi
  80218a:	75 d9                	jne    802165 <__umoddi3+0xf5>
  80218c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80218f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802192:	eb d1                	jmp    802165 <__umoddi3+0xf5>
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	0f 82 18 ff ff ff    	jb     8020b8 <__umoddi3+0x48>
  8021a0:	e9 1d ff ff ff       	jmp    8020c2 <__umoddi3+0x52>
