
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 c0 2b 80 00 	movl   $0x802bc0,(%esp)
  80004e:	e8 3e 01 00 00       	call   800191 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 4e 15 00 00       	call   8015a6 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 38 2c 80 00 	movl   $0x802c38,(%esp)
  800065:	e8 27 01 00 00       	call   800191 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 e8 2b 80 00 	movl   $0x802be8,(%esp)
  800073:	e8 19 01 00 00       	call   800191 <cprintf>
	sys_yield();
  800078:	e8 d8 13 00 00       	call   801455 <sys_yield>
	sys_yield();
  80007d:	e8 d3 13 00 00       	call   801455 <sys_yield>
	sys_yield();
  800082:	e8 ce 13 00 00       	call   801455 <sys_yield>
	sys_yield();
  800087:	e8 c9 13 00 00       	call   801455 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 c0 13 00 00       	call   801455 <sys_yield>
	sys_yield();
  800095:	e8 bb 13 00 00       	call   801455 <sys_yield>
	sys_yield();
  80009a:	e8 b6 13 00 00       	call   801455 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 b0 13 00 00       	call   801455 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  8000ac:	e8 e0 00 00 00       	call   800191 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 5e 14 00 00       	call   801517 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
	...

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
  8000c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000d2:	e8 00 14 00 00       	call   8014d7 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	89 c2                	mov    %eax,%edx
  8000de:	c1 e2 07             	shl    $0x7,%edx
  8000e1:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000e8:	a3 08 50 80 00       	mov    %eax,0x805008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 f6                	test   %esi,%esi
  8000ef:	7e 07                	jle    8000f8 <libmain+0x38>
		binaryname = argv[0];
  8000f1:	8b 03                	mov    (%ebx),%eax
  8000f3:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8000f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000fc:	89 34 24             	mov    %esi,(%esp)
  8000ff:	e8 3c ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800104:	e8 0b 00 00 00       	call   800114 <exit>
}
  800109:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80010c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80011a:	e8 ec 1c 00 00       	call   801e0b <close_all>
	sys_env_destroy(0);
  80011f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800126:	e8 ec 13 00 00       	call   801517 <sys_env_destroy>
}
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    
  80012d:	00 00                	add    %al,(%eax)
	...

00800130 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800139:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800140:	00 00 00 
	b.cnt = 0;
  800143:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800150:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800154:	8b 45 08             	mov    0x8(%ebp),%eax
  800157:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800161:	89 44 24 04          	mov    %eax,0x4(%esp)
  800165:	c7 04 24 ab 01 80 00 	movl   $0x8001ab,(%esp)
  80016c:	e8 cb 01 00 00       	call   80033c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800181:	89 04 24             	mov    %eax,(%esp)
  800184:	e8 63 0d 00 00       	call   800eec <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 87 ff ff ff       	call   800130 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 14             	sub    $0x14,%esp
  8001b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b5:	8b 03                	mov    (%ebx),%eax
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001be:	83 c0 01             	add    $0x1,%eax
  8001c1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c8:	75 19                	jne    8001e3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ca:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d1:	00 
  8001d2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 0f 0d 00 00       	call   800eec <sys_cputs>
		b->idx = 0;
  8001dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    
  8001ed:	00 00                	add    %al,(%eax)
	...

008001f0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	8b 55 0c             	mov    0xc(%ebp),%edx
  800207:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800213:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800216:	b9 00 00 00 00       	mov    $0x0,%ecx
  80021b:	39 d1                	cmp    %edx,%ecx
  80021d:	72 07                	jb     800226 <printnum_v2+0x36>
  80021f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800222:	39 d0                	cmp    %edx,%eax
  800224:	77 5f                	ja     800285 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800226:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80022a:	83 eb 01             	sub    $0x1,%ebx
  80022d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800239:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80023d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800240:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800243:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800246:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800251:	00 
  800252:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80025b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025f:	e8 ec 26 00 00       	call   802950 <__udivdi3>
  800264:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800267:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80026a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80026e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	89 54 24 04          	mov    %edx,0x4(%esp)
  800279:	89 f2                	mov    %esi,%edx
  80027b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027e:	e8 6d ff ff ff       	call   8001f0 <printnum_v2>
  800283:	eb 1e                	jmp    8002a3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800285:	83 ff 2d             	cmp    $0x2d,%edi
  800288:	74 19                	je     8002a3 <printnum_v2+0xb3>
		while (--width > 0)
  80028a:	83 eb 01             	sub    $0x1,%ebx
  80028d:	85 db                	test   %ebx,%ebx
  80028f:	90                   	nop
  800290:	7e 11                	jle    8002a3 <printnum_v2+0xb3>
			putch(padc, putdat);
  800292:	89 74 24 04          	mov    %esi,0x4(%esp)
  800296:	89 3c 24             	mov    %edi,(%esp)
  800299:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80029c:	83 eb 01             	sub    $0x1,%ebx
  80029f:	85 db                	test   %ebx,%ebx
  8002a1:	7f ef                	jg     800292 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b9:	00 
  8002ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002bd:	89 14 24             	mov    %edx,(%esp)
  8002c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002c7:	e8 b4 27 00 00       	call   802a80 <__umoddi3>
  8002cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d0:	0f be 80 60 2c 80 00 	movsbl 0x802c60(%eax),%eax
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002dd:	83 c4 4c             	add    $0x4c,%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5e                   	pop    %esi
  8002e2:	5f                   	pop    %edi
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e8:	83 fa 01             	cmp    $0x1,%edx
  8002eb:	7e 0e                	jle    8002fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	8b 52 04             	mov    0x4(%edx),%edx
  8002f9:	eb 22                	jmp    80031d <getuint+0x38>
	else if (lflag)
  8002fb:	85 d2                	test   %edx,%edx
  8002fd:	74 10                	je     80030f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
  80030d:	eb 0e                	jmp    80031d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800325:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	3b 50 04             	cmp    0x4(%eax),%edx
  80032e:	73 0a                	jae    80033a <sprintputch+0x1b>
		*b->buf++ = ch;
  800330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800333:	88 0a                	mov    %cl,(%edx)
  800335:	83 c2 01             	add    $0x1,%edx
  800338:	89 10                	mov    %edx,(%eax)
}
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 6c             	sub    $0x6c,%esp
  800345:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800348:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80034f:	eb 1a                	jmp    80036b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800351:	85 c0                	test   %eax,%eax
  800353:	0f 84 66 06 00 00    	je     8009bf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	ff 55 08             	call   *0x8(%ebp)
  800366:	eb 03                	jmp    80036b <vprintfmt+0x2f>
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036b:	0f b6 07             	movzbl (%edi),%eax
  80036e:	83 c7 01             	add    $0x1,%edi
  800371:	83 f8 25             	cmp    $0x25,%eax
  800374:	75 db                	jne    800351 <vprintfmt+0x15>
  800376:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80037a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800386:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80038b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800392:	be 00 00 00 00       	mov    $0x0,%esi
  800397:	eb 06                	jmp    80039f <vprintfmt+0x63>
  800399:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80039d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	0f b6 17             	movzbl (%edi),%edx
  8003a2:	0f b6 c2             	movzbl %dl,%eax
  8003a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a8:	8d 47 01             	lea    0x1(%edi),%eax
  8003ab:	83 ea 23             	sub    $0x23,%edx
  8003ae:	80 fa 55             	cmp    $0x55,%dl
  8003b1:	0f 87 60 05 00 00    	ja     800917 <vprintfmt+0x5db>
  8003b7:	0f b6 d2             	movzbl %dl,%edx
  8003ba:	ff 24 95 40 2e 80 00 	jmp    *0x802e40(,%edx,4)
  8003c1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8003c6:	eb d5                	jmp    80039d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003cb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8003ce:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003d1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003d4:	83 ff 09             	cmp    $0x9,%edi
  8003d7:	76 08                	jbe    8003e1 <vprintfmt+0xa5>
  8003d9:	eb 40                	jmp    80041b <vprintfmt+0xdf>
  8003db:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8003df:	eb bc                	jmp    80039d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003e4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8003e7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8003eb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ee:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003f1:	83 ff 09             	cmp    $0x9,%edi
  8003f4:	76 eb                	jbe    8003e1 <vprintfmt+0xa5>
  8003f6:	eb 23                	jmp    80041b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003fb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003fe:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800401:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800403:	eb 16                	jmp    80041b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800405:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800408:	c1 fa 1f             	sar    $0x1f,%edx
  80040b:	f7 d2                	not    %edx
  80040d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800410:	eb 8b                	jmp    80039d <vprintfmt+0x61>
  800412:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800419:	eb 82                	jmp    80039d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80041b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041f:	0f 89 78 ff ff ff    	jns    80039d <vprintfmt+0x61>
  800425:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800428:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80042b:	e9 6d ff ff ff       	jmp    80039d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800430:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800433:	e9 65 ff ff ff       	jmp    80039d <vprintfmt+0x61>
  800438:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 55 14             	mov    %edx,0x14(%ebp)
  800444:	8b 55 0c             	mov    0xc(%ebp),%edx
  800447:	89 54 24 04          	mov    %edx,0x4(%esp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 04 24             	mov    %eax,(%esp)
  800450:	ff 55 08             	call   *0x8(%ebp)
  800453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800456:	e9 10 ff ff ff       	jmp    80036b <vprintfmt+0x2f>
  80045b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	89 c2                	mov    %eax,%edx
  80046b:	c1 fa 1f             	sar    $0x1f,%edx
  80046e:	31 d0                	xor    %edx,%eax
  800470:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800472:	83 f8 0f             	cmp    $0xf,%eax
  800475:	7f 0b                	jg     800482 <vprintfmt+0x146>
  800477:	8b 14 85 a0 2f 80 00 	mov    0x802fa0(,%eax,4),%edx
  80047e:	85 d2                	test   %edx,%edx
  800480:	75 26                	jne    8004a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800482:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800486:	c7 44 24 08 71 2c 80 	movl   $0x802c71,0x8(%esp)
  80048d:	00 
  80048e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800491:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800495:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800498:	89 1c 24             	mov    %ebx,(%esp)
  80049b:	e8 a7 05 00 00       	call   800a47 <printfmt>
  8004a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a3:	e9 c3 fe ff ff       	jmp    80036b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ac:	c7 44 24 08 7a 31 80 	movl   $0x80317a,0x8(%esp)
  8004b3:	00 
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004be:	89 14 24             	mov    %edx,(%esp)
  8004c1:	e8 81 05 00 00       	call   800a47 <printfmt>
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c9:	e9 9d fe ff ff       	jmp    80036b <vprintfmt+0x2f>
  8004ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 d9                	mov    %ebx,%ecx
  8004d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004d8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 30                	mov    (%eax),%esi
  8004e6:	85 f6                	test   %esi,%esi
  8004e8:	75 05                	jne    8004ef <vprintfmt+0x1b3>
  8004ea:	be 7a 2c 80 00       	mov    $0x802c7a,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8004ef:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004f3:	7e 06                	jle    8004fb <vprintfmt+0x1bf>
  8004f5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8004f9:	75 10                	jne    80050b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fb:	0f be 06             	movsbl (%esi),%eax
  8004fe:	85 c0                	test   %eax,%eax
  800500:	0f 85 a2 00 00 00    	jne    8005a8 <vprintfmt+0x26c>
  800506:	e9 92 00 00 00       	jmp    80059d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80050f:	89 34 24             	mov    %esi,(%esp)
  800512:	e8 74 05 00 00       	call   800a8b <strnlen>
  800517:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80051a:	29 c2                	sub    %eax,%edx
  80051c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80051f:	85 d2                	test   %edx,%edx
  800521:	7e d8                	jle    8004fb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800523:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800527:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80052a:	89 d3                	mov    %edx,%ebx
  80052c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80052f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800532:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800535:	89 ce                	mov    %ecx,%esi
  800537:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053b:	89 34 24             	mov    %esi,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	83 eb 01             	sub    $0x1,%ebx
  800544:	85 db                	test   %ebx,%ebx
  800546:	7f ef                	jg     800537 <vprintfmt+0x1fb>
  800548:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80054b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80054e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800551:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800558:	eb a1                	jmp    8004fb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x23f>
  800560:	8d 50 e0             	lea    -0x20(%eax),%edx
  800563:	83 fa 5e             	cmp    $0x5e,%edx
  800566:	76 13                	jbe    80057b <vprintfmt+0x23f>
					putch('?', putdat);
  800568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800576:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80057b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80057e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 ef 01             	sub    $0x1,%edi
  80058b:	0f be 06             	movsbl (%esi),%eax
  80058e:	85 c0                	test   %eax,%eax
  800590:	74 05                	je     800597 <vprintfmt+0x25b>
  800592:	83 c6 01             	add    $0x1,%esi
  800595:	eb 1a                	jmp    8005b1 <vprintfmt+0x275>
  800597:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80059a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a1:	7f 1f                	jg     8005c2 <vprintfmt+0x286>
  8005a3:	e9 c0 fd ff ff       	jmp    800368 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a8:	83 c6 01             	add    $0x1,%esi
  8005ab:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005b1:	85 db                	test   %ebx,%ebx
  8005b3:	78 a5                	js     80055a <vprintfmt+0x21e>
  8005b5:	83 eb 01             	sub    $0x1,%ebx
  8005b8:	79 a0                	jns    80055a <vprintfmt+0x21e>
  8005ba:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005bd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005c0:	eb db                	jmp    80059d <vprintfmt+0x261>
  8005c2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005cb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005db:	83 eb 01             	sub    $0x1,%ebx
  8005de:	85 db                	test   %ebx,%ebx
  8005e0:	7f ec                	jg     8005ce <vprintfmt+0x292>
  8005e2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005e5:	e9 81 fd ff ff       	jmp    80036b <vprintfmt+0x2f>
  8005ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ed:	83 fe 01             	cmp    $0x1,%esi
  8005f0:	7e 10                	jle    800602 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 08             	lea    0x8(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 18                	mov    (%eax),%ebx
  8005fd:	8b 70 04             	mov    0x4(%eax),%esi
  800600:	eb 26                	jmp    800628 <vprintfmt+0x2ec>
	else if (lflag)
  800602:	85 f6                	test   %esi,%esi
  800604:	74 12                	je     800618 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 18                	mov    (%eax),%ebx
  800611:	89 de                	mov    %ebx,%esi
  800613:	c1 fe 1f             	sar    $0x1f,%esi
  800616:	eb 10                	jmp    800628 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 18                	mov    (%eax),%ebx
  800623:	89 de                	mov    %ebx,%esi
  800625:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	75 1e                	jne    80064b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80062d:	85 f6                	test   %esi,%esi
  80062f:	78 1a                	js     80064b <vprintfmt+0x30f>
  800631:	85 f6                	test   %esi,%esi
  800633:	7f 05                	jg     80063a <vprintfmt+0x2fe>
  800635:	83 fb 00             	cmp    $0x0,%ebx
  800638:	76 11                	jbe    80064b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80063a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80063d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800641:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80064b:	85 f6                	test   %esi,%esi
  80064d:	78 13                	js     800662 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800652:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800655:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800658:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065d:	e9 da 00 00 00       	jmp    80073c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800662:	8b 45 0c             	mov    0xc(%ebp),%eax
  800665:	89 44 24 04          	mov    %eax,0x4(%esp)
  800669:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800670:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800673:	89 da                	mov    %ebx,%edx
  800675:	89 f1                	mov    %esi,%ecx
  800677:	f7 da                	neg    %edx
  800679:	83 d1 00             	adc    $0x0,%ecx
  80067c:	f7 d9                	neg    %ecx
  80067e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800681:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800687:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068c:	e9 ab 00 00 00       	jmp    80073c <vprintfmt+0x400>
  800691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800694:	89 f2                	mov    %esi,%edx
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 47 fc ff ff       	call   8002e5 <getuint>
  80069e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006a1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006ac:	e9 8b 00 00 00       	jmp    80073c <vprintfmt+0x400>
  8006b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006bb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8006c5:	89 f2                	mov    %esi,%edx
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ca:	e8 16 fc ff ff       	call   8002e5 <getuint>
  8006cf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006d2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8006dd:	eb 5d                	jmp    80073c <vprintfmt+0x400>
  8006df:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006fe:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800711:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800714:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071f:	eb 1b                	jmp    80073c <vprintfmt+0x400>
  800721:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800724:	89 f2                	mov    %esi,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 b7 fb ff ff       	call   8002e5 <getuint>
  80072e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800731:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800740:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800743:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800746:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80074a:	77 09                	ja     800755 <vprintfmt+0x419>
  80074c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80074f:	0f 82 ac 00 00 00    	jb     800801 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800755:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800758:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80075c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075f:	83 ea 01             	sub    $0x1,%edx
  800762:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800766:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80076e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800772:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800775:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800778:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80077b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80077f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800786:	00 
  800787:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80078a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80078d:	89 0c 24             	mov    %ecx,(%esp)
  800790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800794:	e8 b7 21 00 00       	call   802950 <__udivdi3>
  800799:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80079c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80079f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b4:	e8 37 fa ff ff       	call   8001f0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007d2:	00 
  8007d3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8007d6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8007d9:	89 14 24             	mov    %edx,(%esp)
  8007dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e0:	e8 9b 22 00 00       	call   802a80 <__umoddi3>
  8007e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e9:	0f be 80 60 2c 80 00 	movsbl 0x802c60(%eax),%eax
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8007f6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007fa:	74 54                	je     800850 <vprintfmt+0x514>
  8007fc:	e9 67 fb ff ff       	jmp    800368 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800801:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800805:	8d 76 00             	lea    0x0(%esi),%esi
  800808:	0f 84 2a 01 00 00    	je     800938 <vprintfmt+0x5fc>
		while (--width > 0)
  80080e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800811:	83 ef 01             	sub    $0x1,%edi
  800814:	85 ff                	test   %edi,%edi
  800816:	0f 8e 5e 01 00 00    	jle    80097a <vprintfmt+0x63e>
  80081c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80081f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800822:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800825:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800828:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80082b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80082e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800832:	89 1c 24             	mov    %ebx,(%esp)
  800835:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800838:	83 ef 01             	sub    $0x1,%edi
  80083b:	85 ff                	test   %edi,%edi
  80083d:	7f ef                	jg     80082e <vprintfmt+0x4f2>
  80083f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800842:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800845:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800848:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80084b:	e9 2a 01 00 00       	jmp    80097a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800850:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800853:	83 eb 01             	sub    $0x1,%ebx
  800856:	85 db                	test   %ebx,%ebx
  800858:	0f 8e 0a fb ff ff    	jle    800368 <vprintfmt+0x2c>
  80085e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800861:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800864:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800867:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800872:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800874:	83 eb 01             	sub    $0x1,%ebx
  800877:	85 db                	test   %ebx,%ebx
  800879:	7f ec                	jg     800867 <vprintfmt+0x52b>
  80087b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80087e:	e9 e8 fa ff ff       	jmp    80036b <vprintfmt+0x2f>
  800883:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800886:	8b 45 14             	mov    0x14(%ebp),%eax
  800889:	8d 50 04             	lea    0x4(%eax),%edx
  80088c:	89 55 14             	mov    %edx,0x14(%ebp)
  80088f:	8b 00                	mov    (%eax),%eax
  800891:	85 c0                	test   %eax,%eax
  800893:	75 2a                	jne    8008bf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800895:	c7 44 24 0c 94 2d 80 	movl   $0x802d94,0xc(%esp)
  80089c:	00 
  80089d:	c7 44 24 08 7a 31 80 	movl   $0x80317a,0x8(%esp)
  8008a4:	00 
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008af:	89 0c 24             	mov    %ecx,(%esp)
  8008b2:	e8 90 01 00 00       	call   800a47 <printfmt>
  8008b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ba:	e9 ac fa ff ff       	jmp    80036b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8008bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c2:	8b 13                	mov    (%ebx),%edx
  8008c4:	83 fa 7f             	cmp    $0x7f,%edx
  8008c7:	7e 29                	jle    8008f2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8008c9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8008cb:	c7 44 24 0c cc 2d 80 	movl   $0x802dcc,0xc(%esp)
  8008d2:	00 
  8008d3:	c7 44 24 08 7a 31 80 	movl   $0x80317a,0x8(%esp)
  8008da:	00 
  8008db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	89 04 24             	mov    %eax,(%esp)
  8008e5:	e8 5d 01 00 00       	call   800a47 <printfmt>
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ed:	e9 79 fa ff ff       	jmp    80036b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8008f2:	88 10                	mov    %dl,(%eax)
  8008f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f7:	e9 6f fa ff ff       	jmp    80036b <vprintfmt+0x2f>
  8008fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800905:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800909:	89 14 24             	mov    %edx,(%esp)
  80090c:	ff 55 08             	call   *0x8(%ebp)
  80090f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800912:	e9 54 fa ff ff       	jmp    80036b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800917:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80091a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800925:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800928:	8d 47 ff             	lea    -0x1(%edi),%eax
  80092b:	80 38 25             	cmpb   $0x25,(%eax)
  80092e:	0f 84 37 fa ff ff    	je     80036b <vprintfmt+0x2f>
  800934:	89 c7                	mov    %eax,%edi
  800936:	eb f0                	jmp    800928 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800943:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800946:	89 54 24 08          	mov    %edx,0x8(%esp)
  80094a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800951:	00 
  800952:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800955:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800958:	89 04 24             	mov    %eax,(%esp)
  80095b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095f:	e8 1c 21 00 00       	call   802a80 <__umoddi3>
  800964:	89 74 24 04          	mov    %esi,0x4(%esp)
  800968:	0f be 80 60 2c 80 00 	movsbl 0x802c60(%eax),%eax
  80096f:	89 04 24             	mov    %eax,(%esp)
  800972:	ff 55 08             	call   *0x8(%ebp)
  800975:	e9 d6 fe ff ff       	jmp    800850 <vprintfmt+0x514>
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800981:	8b 74 24 04          	mov    0x4(%esp),%esi
  800985:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800988:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80098c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800993:	00 
  800994:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800997:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80099a:	89 04 24             	mov    %eax,(%esp)
  80099d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a1:	e8 da 20 00 00       	call   802a80 <__umoddi3>
  8009a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009aa:	0f be 80 60 2c 80 00 	movsbl 0x802c60(%eax),%eax
  8009b1:	89 04 24             	mov    %eax,(%esp)
  8009b4:	ff 55 08             	call   *0x8(%ebp)
  8009b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ba:	e9 ac f9 ff ff       	jmp    80036b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009bf:	83 c4 6c             	add    $0x6c,%esp
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	83 ec 28             	sub    $0x28,%esp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	74 04                	je     8009db <vsnprintf+0x14>
  8009d7:	85 d2                	test   %edx,%edx
  8009d9:	7f 07                	jg     8009e2 <vsnprintf+0x1b>
  8009db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e0:	eb 3b                	jmp    800a1d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8009e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a01:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	c7 04 24 1f 03 80 00 	movl   $0x80031f,(%esp)
  800a0f:	e8 28 f9 ff ff       	call   80033c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a25:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 82 ff ff ff       	call   8009c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a4d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a54:	8b 45 10             	mov    0x10(%ebp),%eax
  800a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	89 04 24             	mov    %eax,(%esp)
  800a68:	e8 cf f8 ff ff       	call   80033c <vprintfmt>
	va_end(ap);
}
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    
	...

00800a70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a7e:	74 09                	je     800a89 <strlen+0x19>
		n++;
  800a80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a87:	75 f7                	jne    800a80 <strlen+0x10>
		n++;
	return n;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a95:	85 c9                	test   %ecx,%ecx
  800a97:	74 19                	je     800ab2 <strnlen+0x27>
  800a99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a9c:	74 14                	je     800ab2 <strnlen+0x27>
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800aa3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa6:	39 c8                	cmp    %ecx,%eax
  800aa8:	74 0d                	je     800ab7 <strnlen+0x2c>
  800aaa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800aae:	75 f3                	jne    800aa3 <strnlen+0x18>
  800ab0:	eb 05                	jmp    800ab7 <strnlen+0x2c>
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	53                   	push   %ebx
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ac9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800acd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ad0:	83 c2 01             	add    $0x1,%edx
  800ad3:	84 c9                	test   %cl,%cl
  800ad5:	75 f2                	jne    800ac9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	83 ec 08             	sub    $0x8,%esp
  800ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ae4:	89 1c 24             	mov    %ebx,(%esp)
  800ae7:	e8 84 ff ff ff       	call   800a70 <strlen>
	strcpy(dst + len, src);
  800aec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aef:	89 54 24 04          	mov    %edx,0x4(%esp)
  800af3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800af6:	89 04 24             	mov    %eax,(%esp)
  800af9:	e8 bc ff ff ff       	call   800aba <strcpy>
	return dst;
}
  800afe:	89 d8                	mov    %ebx,%eax
  800b00:	83 c4 08             	add    $0x8,%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b14:	85 f6                	test   %esi,%esi
  800b16:	74 18                	je     800b30 <strncpy+0x2a>
  800b18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b1d:	0f b6 1a             	movzbl (%edx),%ebx
  800b20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b23:	80 3a 01             	cmpb   $0x1,(%edx)
  800b26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	39 ce                	cmp    %ecx,%esi
  800b2e:	77 ed                	ja     800b1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b42:	89 f0                	mov    %esi,%eax
  800b44:	85 c9                	test   %ecx,%ecx
  800b46:	74 27                	je     800b6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b48:	83 e9 01             	sub    $0x1,%ecx
  800b4b:	74 1d                	je     800b6a <strlcpy+0x36>
  800b4d:	0f b6 1a             	movzbl (%edx),%ebx
  800b50:	84 db                	test   %bl,%bl
  800b52:	74 16                	je     800b6a <strlcpy+0x36>
			*dst++ = *src++;
  800b54:	88 18                	mov    %bl,(%eax)
  800b56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b59:	83 e9 01             	sub    $0x1,%ecx
  800b5c:	74 0e                	je     800b6c <strlcpy+0x38>
			*dst++ = *src++;
  800b5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b61:	0f b6 1a             	movzbl (%edx),%ebx
  800b64:	84 db                	test   %bl,%bl
  800b66:	75 ec                	jne    800b54 <strlcpy+0x20>
  800b68:	eb 02                	jmp    800b6c <strlcpy+0x38>
  800b6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b6c:	c6 00 00             	movb   $0x0,(%eax)
  800b6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b7e:	0f b6 01             	movzbl (%ecx),%eax
  800b81:	84 c0                	test   %al,%al
  800b83:	74 15                	je     800b9a <strcmp+0x25>
  800b85:	3a 02                	cmp    (%edx),%al
  800b87:	75 11                	jne    800b9a <strcmp+0x25>
		p++, q++;
  800b89:	83 c1 01             	add    $0x1,%ecx
  800b8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b8f:	0f b6 01             	movzbl (%ecx),%eax
  800b92:	84 c0                	test   %al,%al
  800b94:	74 04                	je     800b9a <strcmp+0x25>
  800b96:	3a 02                	cmp    (%edx),%al
  800b98:	74 ef                	je     800b89 <strcmp+0x14>
  800b9a:	0f b6 c0             	movzbl %al,%eax
  800b9d:	0f b6 12             	movzbl (%edx),%edx
  800ba0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	53                   	push   %ebx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	74 23                	je     800bd8 <strncmp+0x34>
  800bb5:	0f b6 1a             	movzbl (%edx),%ebx
  800bb8:	84 db                	test   %bl,%bl
  800bba:	74 25                	je     800be1 <strncmp+0x3d>
  800bbc:	3a 19                	cmp    (%ecx),%bl
  800bbe:	75 21                	jne    800be1 <strncmp+0x3d>
  800bc0:	83 e8 01             	sub    $0x1,%eax
  800bc3:	74 13                	je     800bd8 <strncmp+0x34>
		n--, p++, q++;
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bcb:	0f b6 1a             	movzbl (%edx),%ebx
  800bce:	84 db                	test   %bl,%bl
  800bd0:	74 0f                	je     800be1 <strncmp+0x3d>
  800bd2:	3a 19                	cmp    (%ecx),%bl
  800bd4:	74 ea                	je     800bc0 <strncmp+0x1c>
  800bd6:	eb 09                	jmp    800be1 <strncmp+0x3d>
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5d                   	pop    %ebp
  800bdf:	90                   	nop
  800be0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800be1:	0f b6 02             	movzbl (%edx),%eax
  800be4:	0f b6 11             	movzbl (%ecx),%edx
  800be7:	29 d0                	sub    %edx,%eax
  800be9:	eb f2                	jmp    800bdd <strncmp+0x39>

00800beb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bf5:	0f b6 10             	movzbl (%eax),%edx
  800bf8:	84 d2                	test   %dl,%dl
  800bfa:	74 18                	je     800c14 <strchr+0x29>
		if (*s == c)
  800bfc:	38 ca                	cmp    %cl,%dl
  800bfe:	75 0a                	jne    800c0a <strchr+0x1f>
  800c00:	eb 17                	jmp    800c19 <strchr+0x2e>
  800c02:	38 ca                	cmp    %cl,%dl
  800c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c08:	74 0f                	je     800c19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	0f b6 10             	movzbl (%eax),%edx
  800c10:	84 d2                	test   %dl,%dl
  800c12:	75 ee                	jne    800c02 <strchr+0x17>
  800c14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c25:	0f b6 10             	movzbl (%eax),%edx
  800c28:	84 d2                	test   %dl,%dl
  800c2a:	74 18                	je     800c44 <strfind+0x29>
		if (*s == c)
  800c2c:	38 ca                	cmp    %cl,%dl
  800c2e:	75 0a                	jne    800c3a <strfind+0x1f>
  800c30:	eb 12                	jmp    800c44 <strfind+0x29>
  800c32:	38 ca                	cmp    %cl,%dl
  800c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c38:	74 0a                	je     800c44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c3a:	83 c0 01             	add    $0x1,%eax
  800c3d:	0f b6 10             	movzbl (%eax),%edx
  800c40:	84 d2                	test   %dl,%dl
  800c42:	75 ee                	jne    800c32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	89 1c 24             	mov    %ebx,(%esp)
  800c4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c60:	85 c9                	test   %ecx,%ecx
  800c62:	74 30                	je     800c94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c6a:	75 25                	jne    800c91 <memset+0x4b>
  800c6c:	f6 c1 03             	test   $0x3,%cl
  800c6f:	75 20                	jne    800c91 <memset+0x4b>
		c &= 0xFF;
  800c71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c74:	89 d3                	mov    %edx,%ebx
  800c76:	c1 e3 08             	shl    $0x8,%ebx
  800c79:	89 d6                	mov    %edx,%esi
  800c7b:	c1 e6 18             	shl    $0x18,%esi
  800c7e:	89 d0                	mov    %edx,%eax
  800c80:	c1 e0 10             	shl    $0x10,%eax
  800c83:	09 f0                	or     %esi,%eax
  800c85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c87:	09 d8                	or     %ebx,%eax
  800c89:	c1 e9 02             	shr    $0x2,%ecx
  800c8c:	fc                   	cld    
  800c8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c8f:	eb 03                	jmp    800c94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c91:	fc                   	cld    
  800c92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c94:	89 f8                	mov    %edi,%eax
  800c96:	8b 1c 24             	mov    (%esp),%ebx
  800c99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ca1:	89 ec                	mov    %ebp,%esp
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	83 ec 08             	sub    $0x8,%esp
  800cab:	89 34 24             	mov    %esi,(%esp)
  800cae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800cbd:	39 c6                	cmp    %eax,%esi
  800cbf:	73 35                	jae    800cf6 <memmove+0x51>
  800cc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc4:	39 d0                	cmp    %edx,%eax
  800cc6:	73 2e                	jae    800cf6 <memmove+0x51>
		s += n;
		d += n;
  800cc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cca:	f6 c2 03             	test   $0x3,%dl
  800ccd:	75 1b                	jne    800cea <memmove+0x45>
  800ccf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cd5:	75 13                	jne    800cea <memmove+0x45>
  800cd7:	f6 c1 03             	test   $0x3,%cl
  800cda:	75 0e                	jne    800cea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800cdc:	83 ef 04             	sub    $0x4,%edi
  800cdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ce2:	c1 e9 02             	shr    $0x2,%ecx
  800ce5:	fd                   	std    
  800ce6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce8:	eb 09                	jmp    800cf3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cea:	83 ef 01             	sub    $0x1,%edi
  800ced:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cf0:	fd                   	std    
  800cf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cf3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cf4:	eb 20                	jmp    800d16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfc:	75 15                	jne    800d13 <memmove+0x6e>
  800cfe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d04:	75 0d                	jne    800d13 <memmove+0x6e>
  800d06:	f6 c1 03             	test   $0x3,%cl
  800d09:	75 08                	jne    800d13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d0b:	c1 e9 02             	shr    $0x2,%ecx
  800d0e:	fc                   	cld    
  800d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d11:	eb 03                	jmp    800d16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d13:	fc                   	cld    
  800d14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d16:	8b 34 24             	mov    (%esp),%esi
  800d19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d1d:	89 ec                	mov    %ebp,%esp
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d27:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
  800d38:	89 04 24             	mov    %eax,(%esp)
  800d3b:	e8 65 ff ff ff       	call   800ca5 <memmove>
}
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	8b 75 08             	mov    0x8(%ebp),%esi
  800d4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d51:	85 c9                	test   %ecx,%ecx
  800d53:	74 36                	je     800d8b <memcmp+0x49>
		if (*s1 != *s2)
  800d55:	0f b6 06             	movzbl (%esi),%eax
  800d58:	0f b6 1f             	movzbl (%edi),%ebx
  800d5b:	38 d8                	cmp    %bl,%al
  800d5d:	74 20                	je     800d7f <memcmp+0x3d>
  800d5f:	eb 14                	jmp    800d75 <memcmp+0x33>
  800d61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d6b:	83 c2 01             	add    $0x1,%edx
  800d6e:	83 e9 01             	sub    $0x1,%ecx
  800d71:	38 d8                	cmp    %bl,%al
  800d73:	74 12                	je     800d87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d75:	0f b6 c0             	movzbl %al,%eax
  800d78:	0f b6 db             	movzbl %bl,%ebx
  800d7b:	29 d8                	sub    %ebx,%eax
  800d7d:	eb 11                	jmp    800d90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7f:	83 e9 01             	sub    $0x1,%ecx
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	85 c9                	test   %ecx,%ecx
  800d89:	75 d6                	jne    800d61 <memcmp+0x1f>
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d9b:	89 c2                	mov    %eax,%edx
  800d9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800da0:	39 d0                	cmp    %edx,%eax
  800da2:	73 15                	jae    800db9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800da4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800da8:	38 08                	cmp    %cl,(%eax)
  800daa:	75 06                	jne    800db2 <memfind+0x1d>
  800dac:	eb 0b                	jmp    800db9 <memfind+0x24>
  800dae:	38 08                	cmp    %cl,(%eax)
  800db0:	74 07                	je     800db9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800db2:	83 c0 01             	add    $0x1,%eax
  800db5:	39 c2                	cmp    %eax,%edx
  800db7:	77 f5                	ja     800dae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 04             	sub    $0x4,%esp
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dca:	0f b6 02             	movzbl (%edx),%eax
  800dcd:	3c 20                	cmp    $0x20,%al
  800dcf:	74 04                	je     800dd5 <strtol+0x1a>
  800dd1:	3c 09                	cmp    $0x9,%al
  800dd3:	75 0e                	jne    800de3 <strtol+0x28>
		s++;
  800dd5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd8:	0f b6 02             	movzbl (%edx),%eax
  800ddb:	3c 20                	cmp    $0x20,%al
  800ddd:	74 f6                	je     800dd5 <strtol+0x1a>
  800ddf:	3c 09                	cmp    $0x9,%al
  800de1:	74 f2                	je     800dd5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800de3:	3c 2b                	cmp    $0x2b,%al
  800de5:	75 0c                	jne    800df3 <strtol+0x38>
		s++;
  800de7:	83 c2 01             	add    $0x1,%edx
  800dea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800df1:	eb 15                	jmp    800e08 <strtol+0x4d>
	else if (*s == '-')
  800df3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dfa:	3c 2d                	cmp    $0x2d,%al
  800dfc:	75 0a                	jne    800e08 <strtol+0x4d>
		s++, neg = 1;
  800dfe:	83 c2 01             	add    $0x1,%edx
  800e01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e08:	85 db                	test   %ebx,%ebx
  800e0a:	0f 94 c0             	sete   %al
  800e0d:	74 05                	je     800e14 <strtol+0x59>
  800e0f:	83 fb 10             	cmp    $0x10,%ebx
  800e12:	75 18                	jne    800e2c <strtol+0x71>
  800e14:	80 3a 30             	cmpb   $0x30,(%edx)
  800e17:	75 13                	jne    800e2c <strtol+0x71>
  800e19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e1d:	8d 76 00             	lea    0x0(%esi),%esi
  800e20:	75 0a                	jne    800e2c <strtol+0x71>
		s += 2, base = 16;
  800e22:	83 c2 02             	add    $0x2,%edx
  800e25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e2a:	eb 15                	jmp    800e41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e2c:	84 c0                	test   %al,%al
  800e2e:	66 90                	xchg   %ax,%ax
  800e30:	74 0f                	je     800e41 <strtol+0x86>
  800e32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e37:	80 3a 30             	cmpb   $0x30,(%edx)
  800e3a:	75 05                	jne    800e41 <strtol+0x86>
		s++, base = 8;
  800e3c:	83 c2 01             	add    $0x1,%edx
  800e3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e48:	0f b6 0a             	movzbl (%edx),%ecx
  800e4b:	89 cf                	mov    %ecx,%edi
  800e4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e50:	80 fb 09             	cmp    $0x9,%bl
  800e53:	77 08                	ja     800e5d <strtol+0xa2>
			dig = *s - '0';
  800e55:	0f be c9             	movsbl %cl,%ecx
  800e58:	83 e9 30             	sub    $0x30,%ecx
  800e5b:	eb 1e                	jmp    800e7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e60:	80 fb 19             	cmp    $0x19,%bl
  800e63:	77 08                	ja     800e6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e65:	0f be c9             	movsbl %cl,%ecx
  800e68:	83 e9 57             	sub    $0x57,%ecx
  800e6b:	eb 0e                	jmp    800e7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e70:	80 fb 19             	cmp    $0x19,%bl
  800e73:	77 15                	ja     800e8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e75:	0f be c9             	movsbl %cl,%ecx
  800e78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e7b:	39 f1                	cmp    %esi,%ecx
  800e7d:	7d 0b                	jge    800e8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e7f:	83 c2 01             	add    $0x1,%edx
  800e82:	0f af c6             	imul   %esi,%eax
  800e85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e88:	eb be                	jmp    800e48 <strtol+0x8d>
  800e8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e90:	74 05                	je     800e97 <strtol+0xdc>
		*endptr = (char *) s;
  800e92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e9b:	74 04                	je     800ea1 <strtol+0xe6>
  800e9d:	89 c8                	mov    %ecx,%eax
  800e9f:	f7 d8                	neg    %eax
}
  800ea1:	83 c4 04             	add    $0x4,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	00 00                	add    %al,(%eax)
	...

00800eac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	89 1c 24             	mov    %ebx,(%esp)
  800eb5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebe:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec3:	89 d1                	mov    %edx,%ecx
  800ec5:	89 d3                	mov    %edx,%ebx
  800ec7:	89 d7                	mov    %edx,%edi
  800ec9:	51                   	push   %ecx
  800eca:	52                   	push   %edx
  800ecb:	53                   	push   %ebx
  800ecc:	54                   	push   %esp
  800ecd:	55                   	push   %ebp
  800ece:	56                   	push   %esi
  800ecf:	57                   	push   %edi
  800ed0:	54                   	push   %esp
  800ed1:	5d                   	pop    %ebp
  800ed2:	8d 35 da 0e 80 00    	lea    0x800eda,%esi
  800ed8:	0f 34                	sysenter 
  800eda:	5f                   	pop    %edi
  800edb:	5e                   	pop    %esi
  800edc:	5d                   	pop    %ebp
  800edd:	5c                   	pop    %esp
  800ede:	5b                   	pop    %ebx
  800edf:	5a                   	pop    %edx
  800ee0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ee1:	8b 1c 24             	mov    (%esp),%ebx
  800ee4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ee8:	89 ec                	mov    %ebp,%esp
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	89 1c 24             	mov    %ebx,(%esp)
  800ef5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	89 c3                	mov    %eax,%ebx
  800f06:	89 c7                	mov    %eax,%edi
  800f08:	51                   	push   %ecx
  800f09:	52                   	push   %edx
  800f0a:	53                   	push   %ebx
  800f0b:	54                   	push   %esp
  800f0c:	55                   	push   %ebp
  800f0d:	56                   	push   %esi
  800f0e:	57                   	push   %edi
  800f0f:	54                   	push   %esp
  800f10:	5d                   	pop    %ebp
  800f11:	8d 35 19 0f 80 00    	lea    0x800f19,%esi
  800f17:	0f 34                	sysenter 
  800f19:	5f                   	pop    %edi
  800f1a:	5e                   	pop    %esi
  800f1b:	5d                   	pop    %ebp
  800f1c:	5c                   	pop    %esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5a                   	pop    %edx
  800f1f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f20:	8b 1c 24             	mov    (%esp),%ebx
  800f23:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f27:	89 ec                	mov    %ebp,%esp
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	89 1c 24             	mov    %ebx,(%esp)
  800f34:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3d:	b8 13 00 00 00       	mov    $0x13,%eax
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	89 cb                	mov    %ecx,%ebx
  800f47:	89 cf                	mov    %ecx,%edi
  800f49:	51                   	push   %ecx
  800f4a:	52                   	push   %edx
  800f4b:	53                   	push   %ebx
  800f4c:	54                   	push   %esp
  800f4d:	55                   	push   %ebp
  800f4e:	56                   	push   %esi
  800f4f:	57                   	push   %edi
  800f50:	54                   	push   %esp
  800f51:	5d                   	pop    %ebp
  800f52:	8d 35 5a 0f 80 00    	lea    0x800f5a,%esi
  800f58:	0f 34                	sysenter 
  800f5a:	5f                   	pop    %edi
  800f5b:	5e                   	pop    %esi
  800f5c:	5d                   	pop    %ebp
  800f5d:	5c                   	pop    %esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5a                   	pop    %edx
  800f60:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800f61:	8b 1c 24             	mov    (%esp),%ebx
  800f64:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
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
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7e:	b8 12 00 00 00       	mov    $0x12,%eax
  800f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
  800f89:	89 df                	mov    %ebx,%edi
  800f8b:	51                   	push   %ecx
  800f8c:	52                   	push   %edx
  800f8d:	53                   	push   %ebx
  800f8e:	54                   	push   %esp
  800f8f:	55                   	push   %ebp
  800f90:	56                   	push   %esi
  800f91:	57                   	push   %edi
  800f92:	54                   	push   %esp
  800f93:	5d                   	pop    %ebp
  800f94:	8d 35 9c 0f 80 00    	lea    0x800f9c,%esi
  800f9a:	0f 34                	sysenter 
  800f9c:	5f                   	pop    %edi
  800f9d:	5e                   	pop    %esi
  800f9e:	5d                   	pop    %ebp
  800f9f:	5c                   	pop    %esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5a                   	pop    %edx
  800fa2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800fa3:	8b 1c 24             	mov    (%esp),%ebx
  800fa6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800faa:	89 ec                	mov    %ebp,%esp
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	89 1c 24             	mov    %ebx,(%esp)
  800fb7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc0:	b8 11 00 00 00       	mov    $0x11,%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	89 df                	mov    %ebx,%edi
  800fcd:	51                   	push   %ecx
  800fce:	52                   	push   %edx
  800fcf:	53                   	push   %ebx
  800fd0:	54                   	push   %esp
  800fd1:	55                   	push   %ebp
  800fd2:	56                   	push   %esi
  800fd3:	57                   	push   %edi
  800fd4:	54                   	push   %esp
  800fd5:	5d                   	pop    %ebp
  800fd6:	8d 35 de 0f 80 00    	lea    0x800fde,%esi
  800fdc:	0f 34                	sysenter 
  800fde:	5f                   	pop    %edi
  800fdf:	5e                   	pop    %esi
  800fe0:	5d                   	pop    %ebp
  800fe1:	5c                   	pop    %esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5a                   	pop    %edx
  800fe4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800fe5:	8b 1c 24             	mov    (%esp),%ebx
  800fe8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fec:	89 ec                	mov    %ebp,%esp
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	89 1c 24             	mov    %ebx,(%esp)
  800ff9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ffd:	b8 10 00 00 00       	mov    $0x10,%eax
  801002:	8b 7d 14             	mov    0x14(%ebp),%edi
  801005:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801008:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100b:	8b 55 08             	mov    0x8(%ebp),%edx
  80100e:	51                   	push   %ecx
  80100f:	52                   	push   %edx
  801010:	53                   	push   %ebx
  801011:	54                   	push   %esp
  801012:	55                   	push   %ebp
  801013:	56                   	push   %esi
  801014:	57                   	push   %edi
  801015:	54                   	push   %esp
  801016:	5d                   	pop    %ebp
  801017:	8d 35 1f 10 80 00    	lea    0x80101f,%esi
  80101d:	0f 34                	sysenter 
  80101f:	5f                   	pop    %edi
  801020:	5e                   	pop    %esi
  801021:	5d                   	pop    %ebp
  801022:	5c                   	pop    %esp
  801023:	5b                   	pop    %ebx
  801024:	5a                   	pop    %edx
  801025:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801026:	8b 1c 24             	mov    (%esp),%ebx
  801029:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80102d:	89 ec                	mov    %ebp,%esp
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 28             	sub    $0x28,%esp
  801037:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80103a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80103d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801042:	b8 0f 00 00 00       	mov    $0xf,%eax
  801047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104a:	8b 55 08             	mov    0x8(%ebp),%edx
  80104d:	89 df                	mov    %ebx,%edi
  80104f:	51                   	push   %ecx
  801050:	52                   	push   %edx
  801051:	53                   	push   %ebx
  801052:	54                   	push   %esp
  801053:	55                   	push   %ebp
  801054:	56                   	push   %esi
  801055:	57                   	push   %edi
  801056:	54                   	push   %esp
  801057:	5d                   	pop    %ebp
  801058:	8d 35 60 10 80 00    	lea    0x801060,%esi
  80105e:	0f 34                	sysenter 
  801060:	5f                   	pop    %edi
  801061:	5e                   	pop    %esi
  801062:	5d                   	pop    %ebp
  801063:	5c                   	pop    %esp
  801064:	5b                   	pop    %ebx
  801065:	5a                   	pop    %edx
  801066:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801067:	85 c0                	test   %eax,%eax
  801069:	7e 28                	jle    801093 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801076:	00 
  801077:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  80107e:	00 
  80107f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801086:	00 
  801087:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  80108e:	e8 71 16 00 00       	call   802704 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801093:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801096:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801099:	89 ec                	mov    %ebp,%esp
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	89 1c 24             	mov    %ebx,(%esp)
  8010a6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010af:	b8 15 00 00 00       	mov    $0x15,%eax
  8010b4:	89 d1                	mov    %edx,%ecx
  8010b6:	89 d3                	mov    %edx,%ebx
  8010b8:	89 d7                	mov    %edx,%edi
  8010ba:	51                   	push   %ecx
  8010bb:	52                   	push   %edx
  8010bc:	53                   	push   %ebx
  8010bd:	54                   	push   %esp
  8010be:	55                   	push   %ebp
  8010bf:	56                   	push   %esi
  8010c0:	57                   	push   %edi
  8010c1:	54                   	push   %esp
  8010c2:	5d                   	pop    %ebp
  8010c3:	8d 35 cb 10 80 00    	lea    0x8010cb,%esi
  8010c9:	0f 34                	sysenter 
  8010cb:	5f                   	pop    %edi
  8010cc:	5e                   	pop    %esi
  8010cd:	5d                   	pop    %ebp
  8010ce:	5c                   	pop    %esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5a                   	pop    %edx
  8010d1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010d2:	8b 1c 24             	mov    (%esp),%ebx
  8010d5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d9:	89 ec                	mov    %ebp,%esp
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	89 1c 24             	mov    %ebx,(%esp)
  8010e6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ef:	b8 14 00 00 00       	mov    $0x14,%eax
  8010f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f7:	89 cb                	mov    %ecx,%ebx
  8010f9:	89 cf                	mov    %ecx,%edi
  8010fb:	51                   	push   %ecx
  8010fc:	52                   	push   %edx
  8010fd:	53                   	push   %ebx
  8010fe:	54                   	push   %esp
  8010ff:	55                   	push   %ebp
  801100:	56                   	push   %esi
  801101:	57                   	push   %edi
  801102:	54                   	push   %esp
  801103:	5d                   	pop    %ebp
  801104:	8d 35 0c 11 80 00    	lea    0x80110c,%esi
  80110a:	0f 34                	sysenter 
  80110c:	5f                   	pop    %edi
  80110d:	5e                   	pop    %esi
  80110e:	5d                   	pop    %ebp
  80110f:	5c                   	pop    %esp
  801110:	5b                   	pop    %ebx
  801111:	5a                   	pop    %edx
  801112:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801113:	8b 1c 24             	mov    (%esp),%ebx
  801116:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80111a:	89 ec                	mov    %ebp,%esp
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 28             	sub    $0x28,%esp
  801124:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801127:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80112a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801134:	8b 55 08             	mov    0x8(%ebp),%edx
  801137:	89 cb                	mov    %ecx,%ebx
  801139:	89 cf                	mov    %ecx,%edi
  80113b:	51                   	push   %ecx
  80113c:	52                   	push   %edx
  80113d:	53                   	push   %ebx
  80113e:	54                   	push   %esp
  80113f:	55                   	push   %ebp
  801140:	56                   	push   %esi
  801141:	57                   	push   %edi
  801142:	54                   	push   %esp
  801143:	5d                   	pop    %ebp
  801144:	8d 35 4c 11 80 00    	lea    0x80114c,%esi
  80114a:	0f 34                	sysenter 
  80114c:	5f                   	pop    %edi
  80114d:	5e                   	pop    %esi
  80114e:	5d                   	pop    %ebp
  80114f:	5c                   	pop    %esp
  801150:	5b                   	pop    %ebx
  801151:	5a                   	pop    %edx
  801152:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 28                	jle    80117f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801162:	00 
  801163:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  80117a:	e8 85 15 00 00       	call   802704 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80117f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801182:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801185:	89 ec                	mov    %ebp,%esp
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	89 1c 24             	mov    %ebx,(%esp)
  801192:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801196:	b8 0d 00 00 00       	mov    $0xd,%eax
  80119b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80119e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a7:	51                   	push   %ecx
  8011a8:	52                   	push   %edx
  8011a9:	53                   	push   %ebx
  8011aa:	54                   	push   %esp
  8011ab:	55                   	push   %ebp
  8011ac:	56                   	push   %esi
  8011ad:	57                   	push   %edi
  8011ae:	54                   	push   %esp
  8011af:	5d                   	pop    %ebp
  8011b0:	8d 35 b8 11 80 00    	lea    0x8011b8,%esi
  8011b6:	0f 34                	sysenter 
  8011b8:	5f                   	pop    %edi
  8011b9:	5e                   	pop    %esi
  8011ba:	5d                   	pop    %ebp
  8011bb:	5c                   	pop    %esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5a                   	pop    %edx
  8011be:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011bf:	8b 1c 24             	mov    (%esp),%ebx
  8011c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011c6:	89 ec                	mov    %ebp,%esp
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	83 ec 28             	sub    $0x28,%esp
  8011d0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011d3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011db:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e6:	89 df                	mov    %ebx,%edi
  8011e8:	51                   	push   %ecx
  8011e9:	52                   	push   %edx
  8011ea:	53                   	push   %ebx
  8011eb:	54                   	push   %esp
  8011ec:	55                   	push   %ebp
  8011ed:	56                   	push   %esi
  8011ee:	57                   	push   %edi
  8011ef:	54                   	push   %esp
  8011f0:	5d                   	pop    %ebp
  8011f1:	8d 35 f9 11 80 00    	lea    0x8011f9,%esi
  8011f7:	0f 34                	sysenter 
  8011f9:	5f                   	pop    %edi
  8011fa:	5e                   	pop    %esi
  8011fb:	5d                   	pop    %ebp
  8011fc:	5c                   	pop    %esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5a                   	pop    %edx
  8011ff:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801200:	85 c0                	test   %eax,%eax
  801202:	7e 28                	jle    80122c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801204:	89 44 24 10          	mov    %eax,0x10(%esp)
  801208:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80120f:	00 
  801210:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  801217:	00 
  801218:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80121f:	00 
  801220:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  801227:	e8 d8 14 00 00       	call   802704 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80122c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80122f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801232:	89 ec                	mov    %ebp,%esp
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	83 ec 28             	sub    $0x28,%esp
  80123c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80123f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
  801247:	b8 0a 00 00 00       	mov    $0xa,%eax
  80124c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124f:	8b 55 08             	mov    0x8(%ebp),%edx
  801252:	89 df                	mov    %ebx,%edi
  801254:	51                   	push   %ecx
  801255:	52                   	push   %edx
  801256:	53                   	push   %ebx
  801257:	54                   	push   %esp
  801258:	55                   	push   %ebp
  801259:	56                   	push   %esi
  80125a:	57                   	push   %edi
  80125b:	54                   	push   %esp
  80125c:	5d                   	pop    %ebp
  80125d:	8d 35 65 12 80 00    	lea    0x801265,%esi
  801263:	0f 34                	sysenter 
  801265:	5f                   	pop    %edi
  801266:	5e                   	pop    %esi
  801267:	5d                   	pop    %ebp
  801268:	5c                   	pop    %esp
  801269:	5b                   	pop    %ebx
  80126a:	5a                   	pop    %edx
  80126b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80126c:	85 c0                	test   %eax,%eax
  80126e:	7e 28                	jle    801298 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801270:	89 44 24 10          	mov    %eax,0x10(%esp)
  801274:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80127b:	00 
  80127c:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80128b:	00 
  80128c:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  801293:	e8 6c 14 00 00       	call   802704 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801298:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80129b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80129e:	89 ec                	mov    %ebp,%esp
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	83 ec 28             	sub    $0x28,%esp
  8012a8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012ab:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8012b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012be:	89 df                	mov    %ebx,%edi
  8012c0:	51                   	push   %ecx
  8012c1:	52                   	push   %edx
  8012c2:	53                   	push   %ebx
  8012c3:	54                   	push   %esp
  8012c4:	55                   	push   %ebp
  8012c5:	56                   	push   %esi
  8012c6:	57                   	push   %edi
  8012c7:	54                   	push   %esp
  8012c8:	5d                   	pop    %ebp
  8012c9:	8d 35 d1 12 80 00    	lea    0x8012d1,%esi
  8012cf:	0f 34                	sysenter 
  8012d1:	5f                   	pop    %edi
  8012d2:	5e                   	pop    %esi
  8012d3:	5d                   	pop    %ebp
  8012d4:	5c                   	pop    %esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5a                   	pop    %edx
  8012d7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	7e 28                	jle    801304 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012e0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012e7:	00 
  8012e8:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  8012ef:	00 
  8012f0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012f7:	00 
  8012f8:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  8012ff:	e8 00 14 00 00       	call   802704 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801304:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801307:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80130a:	89 ec                	mov    %ebp,%esp
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 28             	sub    $0x28,%esp
  801314:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801317:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80131a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80131f:	b8 07 00 00 00       	mov    $0x7,%eax
  801324:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801327:	8b 55 08             	mov    0x8(%ebp),%edx
  80132a:	89 df                	mov    %ebx,%edi
  80132c:	51                   	push   %ecx
  80132d:	52                   	push   %edx
  80132e:	53                   	push   %ebx
  80132f:	54                   	push   %esp
  801330:	55                   	push   %ebp
  801331:	56                   	push   %esi
  801332:	57                   	push   %edi
  801333:	54                   	push   %esp
  801334:	5d                   	pop    %ebp
  801335:	8d 35 3d 13 80 00    	lea    0x80133d,%esi
  80133b:	0f 34                	sysenter 
  80133d:	5f                   	pop    %edi
  80133e:	5e                   	pop    %esi
  80133f:	5d                   	pop    %ebp
  801340:	5c                   	pop    %esp
  801341:	5b                   	pop    %ebx
  801342:	5a                   	pop    %edx
  801343:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801344:	85 c0                	test   %eax,%eax
  801346:	7e 28                	jle    801370 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801348:	89 44 24 10          	mov    %eax,0x10(%esp)
  80134c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801353:	00 
  801354:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  80135b:	00 
  80135c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801363:	00 
  801364:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  80136b:	e8 94 13 00 00       	call   802704 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801370:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801373:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801376:	89 ec                	mov    %ebp,%esp
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 28             	sub    $0x28,%esp
  801380:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801383:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801386:	8b 7d 18             	mov    0x18(%ebp),%edi
  801389:	0b 7d 14             	or     0x14(%ebp),%edi
  80138c:	b8 06 00 00 00       	mov    $0x6,%eax
  801391:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801394:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801397:	8b 55 08             	mov    0x8(%ebp),%edx
  80139a:	51                   	push   %ecx
  80139b:	52                   	push   %edx
  80139c:	53                   	push   %ebx
  80139d:	54                   	push   %esp
  80139e:	55                   	push   %ebp
  80139f:	56                   	push   %esi
  8013a0:	57                   	push   %edi
  8013a1:	54                   	push   %esp
  8013a2:	5d                   	pop    %ebp
  8013a3:	8d 35 ab 13 80 00    	lea    0x8013ab,%esi
  8013a9:	0f 34                	sysenter 
  8013ab:	5f                   	pop    %edi
  8013ac:	5e                   	pop    %esi
  8013ad:	5d                   	pop    %ebp
  8013ae:	5c                   	pop    %esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5a                   	pop    %edx
  8013b1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	7e 28                	jle    8013de <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013c1:	00 
  8013c2:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  8013c9:	00 
  8013ca:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013d1:	00 
  8013d2:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  8013d9:	e8 26 13 00 00       	call   802704 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8013de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013e4:	89 ec                	mov    %ebp,%esp
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	83 ec 28             	sub    $0x28,%esp
  8013ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013f1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801401:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801404:	8b 55 08             	mov    0x8(%ebp),%edx
  801407:	51                   	push   %ecx
  801408:	52                   	push   %edx
  801409:	53                   	push   %ebx
  80140a:	54                   	push   %esp
  80140b:	55                   	push   %ebp
  80140c:	56                   	push   %esi
  80140d:	57                   	push   %edi
  80140e:	54                   	push   %esp
  80140f:	5d                   	pop    %ebp
  801410:	8d 35 18 14 80 00    	lea    0x801418,%esi
  801416:	0f 34                	sysenter 
  801418:	5f                   	pop    %edi
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	5c                   	pop    %esp
  80141c:	5b                   	pop    %ebx
  80141d:	5a                   	pop    %edx
  80141e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80141f:	85 c0                	test   %eax,%eax
  801421:	7e 28                	jle    80144b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801423:	89 44 24 10          	mov    %eax,0x10(%esp)
  801427:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80142e:	00 
  80142f:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  801436:	00 
  801437:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80143e:	00 
  80143f:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  801446:	e8 b9 12 00 00       	call   802704 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80144b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80144e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801451:	89 ec                	mov    %ebp,%esp
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	89 1c 24             	mov    %ebx,(%esp)
  80145e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801462:	ba 00 00 00 00       	mov    $0x0,%edx
  801467:	b8 0c 00 00 00       	mov    $0xc,%eax
  80146c:	89 d1                	mov    %edx,%ecx
  80146e:	89 d3                	mov    %edx,%ebx
  801470:	89 d7                	mov    %edx,%edi
  801472:	51                   	push   %ecx
  801473:	52                   	push   %edx
  801474:	53                   	push   %ebx
  801475:	54                   	push   %esp
  801476:	55                   	push   %ebp
  801477:	56                   	push   %esi
  801478:	57                   	push   %edi
  801479:	54                   	push   %esp
  80147a:	5d                   	pop    %ebp
  80147b:	8d 35 83 14 80 00    	lea    0x801483,%esi
  801481:	0f 34                	sysenter 
  801483:	5f                   	pop    %edi
  801484:	5e                   	pop    %esi
  801485:	5d                   	pop    %ebp
  801486:	5c                   	pop    %esp
  801487:	5b                   	pop    %ebx
  801488:	5a                   	pop    %edx
  801489:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80148a:	8b 1c 24             	mov    (%esp),%ebx
  80148d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801491:	89 ec                	mov    %ebp,%esp
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	89 1c 24             	mov    %ebx,(%esp)
  80149e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014af:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b2:	89 df                	mov    %ebx,%edi
  8014b4:	51                   	push   %ecx
  8014b5:	52                   	push   %edx
  8014b6:	53                   	push   %ebx
  8014b7:	54                   	push   %esp
  8014b8:	55                   	push   %ebp
  8014b9:	56                   	push   %esi
  8014ba:	57                   	push   %edi
  8014bb:	54                   	push   %esp
  8014bc:	5d                   	pop    %ebp
  8014bd:	8d 35 c5 14 80 00    	lea    0x8014c5,%esi
  8014c3:	0f 34                	sysenter 
  8014c5:	5f                   	pop    %edi
  8014c6:	5e                   	pop    %esi
  8014c7:	5d                   	pop    %ebp
  8014c8:	5c                   	pop    %esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5a                   	pop    %edx
  8014cb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8014cc:	8b 1c 24             	mov    (%esp),%ebx
  8014cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014d3:	89 ec                	mov    %ebp,%esp
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	89 1c 24             	mov    %ebx,(%esp)
  8014e0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014ee:	89 d1                	mov    %edx,%ecx
  8014f0:	89 d3                	mov    %edx,%ebx
  8014f2:	89 d7                	mov    %edx,%edi
  8014f4:	51                   	push   %ecx
  8014f5:	52                   	push   %edx
  8014f6:	53                   	push   %ebx
  8014f7:	54                   	push   %esp
  8014f8:	55                   	push   %ebp
  8014f9:	56                   	push   %esi
  8014fa:	57                   	push   %edi
  8014fb:	54                   	push   %esp
  8014fc:	5d                   	pop    %ebp
  8014fd:	8d 35 05 15 80 00    	lea    0x801505,%esi
  801503:	0f 34                	sysenter 
  801505:	5f                   	pop    %edi
  801506:	5e                   	pop    %esi
  801507:	5d                   	pop    %ebp
  801508:	5c                   	pop    %esp
  801509:	5b                   	pop    %ebx
  80150a:	5a                   	pop    %edx
  80150b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80150c:	8b 1c 24             	mov    (%esp),%ebx
  80150f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801513:	89 ec                	mov    %ebp,%esp
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	83 ec 28             	sub    $0x28,%esp
  80151d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801520:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801523:	b9 00 00 00 00       	mov    $0x0,%ecx
  801528:	b8 03 00 00 00       	mov    $0x3,%eax
  80152d:	8b 55 08             	mov    0x8(%ebp),%edx
  801530:	89 cb                	mov    %ecx,%ebx
  801532:	89 cf                	mov    %ecx,%edi
  801534:	51                   	push   %ecx
  801535:	52                   	push   %edx
  801536:	53                   	push   %ebx
  801537:	54                   	push   %esp
  801538:	55                   	push   %ebp
  801539:	56                   	push   %esi
  80153a:	57                   	push   %edi
  80153b:	54                   	push   %esp
  80153c:	5d                   	pop    %ebp
  80153d:	8d 35 45 15 80 00    	lea    0x801545,%esi
  801543:	0f 34                	sysenter 
  801545:	5f                   	pop    %edi
  801546:	5e                   	pop    %esi
  801547:	5d                   	pop    %ebp
  801548:	5c                   	pop    %esp
  801549:	5b                   	pop    %ebx
  80154a:	5a                   	pop    %edx
  80154b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80154c:	85 c0                	test   %eax,%eax
  80154e:	7e 28                	jle    801578 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801550:	89 44 24 10          	mov    %eax,0x10(%esp)
  801554:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80155b:	00 
  80155c:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  801563:	00 
  801564:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80156b:	00 
  80156c:	c7 04 24 fd 2f 80 00 	movl   $0x802ffd,(%esp)
  801573:	e8 8c 11 00 00       	call   802704 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801578:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80157b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80157e:	89 ec                	mov    %ebp,%esp
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    
	...

00801584 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80158a:	c7 44 24 08 0b 30 80 	movl   $0x80300b,0x8(%esp)
  801591:	00 
  801592:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801599:	00 
  80159a:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  8015a1:	e8 5e 11 00 00       	call   802704 <_panic>

008015a6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	57                   	push   %edi
  8015aa:	56                   	push   %esi
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  8015af:	c7 04 24 fb 17 80 00 	movl   $0x8017fb,(%esp)
  8015b6:	e8 a1 11 00 00       	call   80275c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015bb:	ba 08 00 00 00       	mov    $0x8,%edx
  8015c0:	89 d0                	mov    %edx,%eax
  8015c2:	cd 30                	int    $0x30
  8015c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	79 20                	jns    8015eb <fork+0x45>
		panic("sys_exofork: %e", envid);
  8015cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015cf:	c7 44 24 08 2c 30 80 	movl   $0x80302c,0x8(%esp)
  8015d6:	00 
  8015d7:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8015de:	00 
  8015df:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  8015e6:	e8 19 11 00 00       	call   802704 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8015eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8015f0:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8015f5:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8015fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8015fe:	75 20                	jne    801620 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801600:	e8 d2 fe ff ff       	call   8014d7 <sys_getenvid>
  801605:	25 ff 03 00 00       	and    $0x3ff,%eax
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	c1 e2 07             	shl    $0x7,%edx
  80160f:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801616:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80161b:	e9 d0 01 00 00       	jmp    8017f0 <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801620:	89 d8                	mov    %ebx,%eax
  801622:	c1 e8 16             	shr    $0x16,%eax
  801625:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801628:	a8 01                	test   $0x1,%al
  80162a:	0f 84 0d 01 00 00    	je     80173d <fork+0x197>
  801630:	89 d8                	mov    %ebx,%eax
  801632:	c1 e8 0c             	shr    $0xc,%eax
  801635:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801638:	f6 c2 01             	test   $0x1,%dl
  80163b:	0f 84 fc 00 00 00    	je     80173d <fork+0x197>
  801641:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801644:	f6 c2 04             	test   $0x4,%dl
  801647:	0f 84 f0 00 00 00    	je     80173d <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  80164d:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  801650:	89 c2                	mov    %eax,%edx
  801652:	c1 ea 0c             	shr    $0xc,%edx
  801655:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801658:	f6 c2 01             	test   $0x1,%dl
  80165b:	0f 84 dc 00 00 00    	je     80173d <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  801661:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801667:	0f 84 8d 00 00 00    	je     8016fa <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  80166d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801670:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801677:	00 
  801678:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80167c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80167f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801683:	89 44 24 04          	mov    %eax,0x4(%esp)
  801687:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168e:	e8 e7 fc ff ff       	call   80137a <sys_page_map>
               if(r<0)
  801693:	85 c0                	test   %eax,%eax
  801695:	79 1c                	jns    8016b3 <fork+0x10d>
                 panic("map failed");
  801697:	c7 44 24 08 3c 30 80 	movl   $0x80303c,0x8(%esp)
  80169e:	00 
  80169f:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8016a6:	00 
  8016a7:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  8016ae:	e8 51 10 00 00       	call   802704 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  8016b3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8016ba:	00 
  8016bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016c9:	00 
  8016ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d5:	e8 a0 fc ff ff       	call   80137a <sys_page_map>
               if(r<0)
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	79 5f                	jns    80173d <fork+0x197>
                 panic("map failed");
  8016de:	c7 44 24 08 3c 30 80 	movl   $0x80303c,0x8(%esp)
  8016e5:	00 
  8016e6:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8016ed:	00 
  8016ee:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  8016f5:	e8 0a 10 00 00       	call   802704 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  8016fa:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801701:	00 
  801702:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801706:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801709:	89 54 24 08          	mov    %edx,0x8(%esp)
  80170d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801711:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801718:	e8 5d fc ff ff       	call   80137a <sys_page_map>
               if(r<0)
  80171d:	85 c0                	test   %eax,%eax
  80171f:	79 1c                	jns    80173d <fork+0x197>
                 panic("map failed");
  801721:	c7 44 24 08 3c 30 80 	movl   $0x80303c,0x8(%esp)
  801728:	00 
  801729:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801730:	00 
  801731:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  801738:	e8 c7 0f 00 00       	call   802704 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80173d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801743:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801749:	0f 85 d1 fe ff ff    	jne    801620 <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80174f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801756:	00 
  801757:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80175e:	ee 
  80175f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801762:	89 04 24             	mov    %eax,(%esp)
  801765:	e8 7e fc ff ff       	call   8013e8 <sys_page_alloc>
        if(r < 0)
  80176a:	85 c0                	test   %eax,%eax
  80176c:	79 1c                	jns    80178a <fork+0x1e4>
            panic("alloc failed");
  80176e:	c7 44 24 08 47 30 80 	movl   $0x803047,0x8(%esp)
  801775:	00 
  801776:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80177d:	00 
  80177e:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  801785:	e8 7a 0f 00 00       	call   802704 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80178a:	c7 44 24 04 a8 27 80 	movl   $0x8027a8,0x4(%esp)
  801791:	00 
  801792:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801795:	89 14 24             	mov    %edx,(%esp)
  801798:	e8 2d fa ff ff       	call   8011ca <sys_env_set_pgfault_upcall>
        if(r < 0)
  80179d:	85 c0                	test   %eax,%eax
  80179f:	79 1c                	jns    8017bd <fork+0x217>
            panic("set pgfault upcall failed");
  8017a1:	c7 44 24 08 54 30 80 	movl   $0x803054,0x8(%esp)
  8017a8:	00 
  8017a9:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8017b0:	00 
  8017b1:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  8017b8:	e8 47 0f 00 00       	call   802704 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  8017bd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8017c4:	00 
  8017c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017c8:	89 04 24             	mov    %eax,(%esp)
  8017cb:	e8 d2 fa ff ff       	call   8012a2 <sys_env_set_status>
        if(r < 0)
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	79 1c                	jns    8017f0 <fork+0x24a>
            panic("set status failed");
  8017d4:	c7 44 24 08 6e 30 80 	movl   $0x80306e,0x8(%esp)
  8017db:	00 
  8017dc:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8017e3:	00 
  8017e4:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  8017eb:	e8 14 0f 00 00       	call   802704 <_panic>
        return envid;
	//panic("fork not implemented");
}
  8017f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017f3:	83 c4 3c             	add    $0x3c,%esp
  8017f6:	5b                   	pop    %ebx
  8017f7:	5e                   	pop    %esi
  8017f8:	5f                   	pop    %edi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 24             	sub    $0x24,%esp
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801805:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801807:	89 da                	mov    %ebx,%edx
  801809:	c1 ea 0c             	shr    $0xc,%edx
  80180c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  801813:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801817:	74 08                	je     801821 <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801819:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80181f:	75 1c                	jne    80183d <pgfault+0x42>
           panic("pgfault error");
  801821:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  801828:	00 
  801829:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801830:	00 
  801831:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  801838:	e8 c7 0e 00 00       	call   802704 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80183d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801844:	00 
  801845:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80184c:	00 
  80184d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801854:	e8 8f fb ff ff       	call   8013e8 <sys_page_alloc>
  801859:	85 c0                	test   %eax,%eax
  80185b:	79 20                	jns    80187d <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  80185d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801861:	c7 44 24 08 8e 30 80 	movl   $0x80308e,0x8(%esp)
  801868:	00 
  801869:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801870:	00 
  801871:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  801878:	e8 87 0e 00 00       	call   802704 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  80187d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801883:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80188a:	00 
  80188b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80188f:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801896:	e8 0a f4 ff ff       	call   800ca5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  80189b:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018a2:	00 
  8018a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8018a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018ae:	00 
  8018af:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018b6:	00 
  8018b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018be:	e8 b7 fa ff ff       	call   80137a <sys_page_map>
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	79 20                	jns    8018e7 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  8018c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018cb:	c7 44 24 08 a1 30 80 	movl   $0x8030a1,0x8(%esp)
  8018d2:	00 
  8018d3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8018da:	00 
  8018db:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  8018e2:	e8 1d 0e 00 00       	call   802704 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8018e7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018ee:	00 
  8018ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f6:	e8 13 fa ff ff       	call   80130e <sys_page_unmap>
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	79 20                	jns    80191f <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  8018ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801903:	c7 44 24 08 b2 30 80 	movl   $0x8030b2,0x8(%esp)
  80190a:	00 
  80190b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801912:	00 
  801913:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  80191a:	e8 e5 0d 00 00       	call   802704 <_panic>
	//panic("pgfault not implemented");
}
  80191f:	83 c4 24             	add    $0x24,%esp
  801922:	5b                   	pop    %ebx
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    
	...

00801930 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	05 00 00 00 30       	add    $0x30000000,%eax
  80193b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	89 04 24             	mov    %eax,(%esp)
  80194c:	e8 df ff ff ff       	call   801930 <fd2num>
  801951:	05 20 00 0d 00       	add    $0xd0020,%eax
  801956:	c1 e0 0c             	shl    $0xc,%eax
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	57                   	push   %edi
  80195f:	56                   	push   %esi
  801960:	53                   	push   %ebx
  801961:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801964:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801969:	a8 01                	test   $0x1,%al
  80196b:	74 36                	je     8019a3 <fd_alloc+0x48>
  80196d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801972:	a8 01                	test   $0x1,%al
  801974:	74 2d                	je     8019a3 <fd_alloc+0x48>
  801976:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80197b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801980:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801985:	89 c3                	mov    %eax,%ebx
  801987:	89 c2                	mov    %eax,%edx
  801989:	c1 ea 16             	shr    $0x16,%edx
  80198c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80198f:	f6 c2 01             	test   $0x1,%dl
  801992:	74 14                	je     8019a8 <fd_alloc+0x4d>
  801994:	89 c2                	mov    %eax,%edx
  801996:	c1 ea 0c             	shr    $0xc,%edx
  801999:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80199c:	f6 c2 01             	test   $0x1,%dl
  80199f:	75 10                	jne    8019b1 <fd_alloc+0x56>
  8019a1:	eb 05                	jmp    8019a8 <fd_alloc+0x4d>
  8019a3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8019a8:	89 1f                	mov    %ebx,(%edi)
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8019af:	eb 17                	jmp    8019c8 <fd_alloc+0x6d>
  8019b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8019b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8019bb:	75 c8                	jne    801985 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8019bd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8019c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8019c8:	5b                   	pop    %ebx
  8019c9:	5e                   	pop    %esi
  8019ca:	5f                   	pop    %edi
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    

008019cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	83 f8 1f             	cmp    $0x1f,%eax
  8019d6:	77 36                	ja     801a0e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019d8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8019dd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	c1 ea 16             	shr    $0x16,%edx
  8019e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019ec:	f6 c2 01             	test   $0x1,%dl
  8019ef:	74 1d                	je     801a0e <fd_lookup+0x41>
  8019f1:	89 c2                	mov    %eax,%edx
  8019f3:	c1 ea 0c             	shr    $0xc,%edx
  8019f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019fd:	f6 c2 01             	test   $0x1,%dl
  801a00:	74 0c                	je     801a0e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a05:	89 02                	mov    %eax,(%edx)
  801a07:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801a0c:	eb 05                	jmp    801a13 <fd_lookup+0x46>
  801a0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a1b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a22:	8b 45 08             	mov    0x8(%ebp),%eax
  801a25:	89 04 24             	mov    %eax,(%esp)
  801a28:	e8 a0 ff ff ff       	call   8019cd <fd_lookup>
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	78 0e                	js     801a3f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a37:	89 50 04             	mov    %edx,0x4(%eax)
  801a3a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	83 ec 10             	sub    $0x10,%esp
  801a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801a4f:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a59:	be 44 31 80 00       	mov    $0x803144,%esi
		if (devtab[i]->dev_id == dev_id) {
  801a5e:	39 08                	cmp    %ecx,(%eax)
  801a60:	75 10                	jne    801a72 <dev_lookup+0x31>
  801a62:	eb 04                	jmp    801a68 <dev_lookup+0x27>
  801a64:	39 08                	cmp    %ecx,(%eax)
  801a66:	75 0a                	jne    801a72 <dev_lookup+0x31>
			*dev = devtab[i];
  801a68:	89 03                	mov    %eax,(%ebx)
  801a6a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801a6f:	90                   	nop
  801a70:	eb 31                	jmp    801aa3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a72:	83 c2 01             	add    $0x1,%edx
  801a75:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	75 e8                	jne    801a64 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a7c:	a1 08 50 80 00       	mov    0x805008,%eax
  801a81:	8b 40 48             	mov    0x48(%eax),%eax
  801a84:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8c:	c7 04 24 c8 30 80 00 	movl   $0x8030c8,(%esp)
  801a93:	e8 f9 e6 ff ff       	call   800191 <cprintf>
	*dev = 0;
  801a98:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	53                   	push   %ebx
  801aae:	83 ec 24             	sub    $0x24,%esp
  801ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ab4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	89 04 24             	mov    %eax,(%esp)
  801ac1:	e8 07 ff ff ff       	call   8019cd <fd_lookup>
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 53                	js     801b1d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad4:	8b 00                	mov    (%eax),%eax
  801ad6:	89 04 24             	mov    %eax,(%esp)
  801ad9:	e8 63 ff ff ff       	call   801a41 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 3b                	js     801b1d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801ae2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ae7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aea:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801aee:	74 2d                	je     801b1d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801af0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801af3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801afa:	00 00 00 
	stat->st_isdir = 0;
  801afd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b04:	00 00 00 
	stat->st_dev = dev;
  801b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b17:	89 14 24             	mov    %edx,(%esp)
  801b1a:	ff 50 14             	call   *0x14(%eax)
}
  801b1d:	83 c4 24             	add    $0x24,%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	53                   	push   %ebx
  801b27:	83 ec 24             	sub    $0x24,%esp
  801b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b34:	89 1c 24             	mov    %ebx,(%esp)
  801b37:	e8 91 fe ff ff       	call   8019cd <fd_lookup>
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 5f                	js     801b9f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4a:	8b 00                	mov    (%eax),%eax
  801b4c:	89 04 24             	mov    %eax,(%esp)
  801b4f:	e8 ed fe ff ff       	call   801a41 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b54:	85 c0                	test   %eax,%eax
  801b56:	78 47                	js     801b9f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b5b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801b5f:	75 23                	jne    801b84 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b61:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b66:	8b 40 48             	mov    0x48(%eax),%eax
  801b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b71:	c7 04 24 e8 30 80 00 	movl   $0x8030e8,(%esp)
  801b78:	e8 14 e6 ff ff       	call   800191 <cprintf>
  801b7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b82:	eb 1b                	jmp    801b9f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b87:	8b 48 18             	mov    0x18(%eax),%ecx
  801b8a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b8f:	85 c9                	test   %ecx,%ecx
  801b91:	74 0c                	je     801b9f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9a:	89 14 24             	mov    %edx,(%esp)
  801b9d:	ff d1                	call   *%ecx
}
  801b9f:	83 c4 24             	add    $0x24,%esp
  801ba2:	5b                   	pop    %ebx
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 24             	sub    $0x24,%esp
  801bac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801baf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb6:	89 1c 24             	mov    %ebx,(%esp)
  801bb9:	e8 0f fe ff ff       	call   8019cd <fd_lookup>
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 66                	js     801c28 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bcc:	8b 00                	mov    (%eax),%eax
  801bce:	89 04 24             	mov    %eax,(%esp)
  801bd1:	e8 6b fe ff ff       	call   801a41 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	78 4e                	js     801c28 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bda:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bdd:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801be1:	75 23                	jne    801c06 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801be3:	a1 08 50 80 00       	mov    0x805008,%eax
  801be8:	8b 40 48             	mov    0x48(%eax),%eax
  801beb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf3:	c7 04 24 09 31 80 00 	movl   $0x803109,(%esp)
  801bfa:	e8 92 e5 ff ff       	call   800191 <cprintf>
  801bff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801c04:	eb 22                	jmp    801c28 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c09:	8b 48 0c             	mov    0xc(%eax),%ecx
  801c0c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c11:	85 c9                	test   %ecx,%ecx
  801c13:	74 13                	je     801c28 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c15:	8b 45 10             	mov    0x10(%ebp),%eax
  801c18:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c23:	89 14 24             	mov    %edx,(%esp)
  801c26:	ff d1                	call   *%ecx
}
  801c28:	83 c4 24             	add    $0x24,%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	53                   	push   %ebx
  801c32:	83 ec 24             	sub    $0x24,%esp
  801c35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3f:	89 1c 24             	mov    %ebx,(%esp)
  801c42:	e8 86 fd ff ff       	call   8019cd <fd_lookup>
  801c47:	85 c0                	test   %eax,%eax
  801c49:	78 6b                	js     801cb6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c55:	8b 00                	mov    (%eax),%eax
  801c57:	89 04 24             	mov    %eax,(%esp)
  801c5a:	e8 e2 fd ff ff       	call   801a41 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 53                	js     801cb6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c63:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c66:	8b 42 08             	mov    0x8(%edx),%eax
  801c69:	83 e0 03             	and    $0x3,%eax
  801c6c:	83 f8 01             	cmp    $0x1,%eax
  801c6f:	75 23                	jne    801c94 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c71:	a1 08 50 80 00       	mov    0x805008,%eax
  801c76:	8b 40 48             	mov    0x48(%eax),%eax
  801c79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c81:	c7 04 24 26 31 80 00 	movl   $0x803126,(%esp)
  801c88:	e8 04 e5 ff ff       	call   800191 <cprintf>
  801c8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801c92:	eb 22                	jmp    801cb6 <read+0x88>
	}
	if (!dev->dev_read)
  801c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c97:	8b 48 08             	mov    0x8(%eax),%ecx
  801c9a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c9f:	85 c9                	test   %ecx,%ecx
  801ca1:	74 13                	je     801cb6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ca3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb1:	89 14 24             	mov    %edx,(%esp)
  801cb4:	ff d1                	call   *%ecx
}
  801cb6:	83 c4 24             	add    $0x24,%esp
  801cb9:	5b                   	pop    %ebx
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	57                   	push   %edi
  801cc0:	56                   	push   %esi
  801cc1:	53                   	push   %ebx
  801cc2:	83 ec 1c             	sub    $0x1c,%esp
  801cc5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cda:	85 f6                	test   %esi,%esi
  801cdc:	74 29                	je     801d07 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801cde:	89 f0                	mov    %esi,%eax
  801ce0:	29 d0                	sub    %edx,%eax
  801ce2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce6:	03 55 0c             	add    0xc(%ebp),%edx
  801ce9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ced:	89 3c 24             	mov    %edi,(%esp)
  801cf0:	e8 39 ff ff ff       	call   801c2e <read>
		if (m < 0)
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	78 0e                	js     801d07 <readn+0x4b>
			return m;
		if (m == 0)
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	74 08                	je     801d05 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cfd:	01 c3                	add    %eax,%ebx
  801cff:	89 da                	mov    %ebx,%edx
  801d01:	39 f3                	cmp    %esi,%ebx
  801d03:	72 d9                	jb     801cde <readn+0x22>
  801d05:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801d07:	83 c4 1c             	add    $0x1c,%esp
  801d0a:	5b                   	pop    %ebx
  801d0b:	5e                   	pop    %esi
  801d0c:	5f                   	pop    %edi
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 20             	sub    $0x20,%esp
  801d17:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d1a:	89 34 24             	mov    %esi,(%esp)
  801d1d:	e8 0e fc ff ff       	call   801930 <fd2num>
  801d22:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d25:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d29:	89 04 24             	mov    %eax,(%esp)
  801d2c:	e8 9c fc ff ff       	call   8019cd <fd_lookup>
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 05                	js     801d3c <fd_close+0x2d>
  801d37:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d3a:	74 0c                	je     801d48 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801d3c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801d40:	19 c0                	sbb    %eax,%eax
  801d42:	f7 d0                	not    %eax
  801d44:	21 c3                	and    %eax,%ebx
  801d46:	eb 3d                	jmp    801d85 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4f:	8b 06                	mov    (%esi),%eax
  801d51:	89 04 24             	mov    %eax,(%esp)
  801d54:	e8 e8 fc ff ff       	call   801a41 <dev_lookup>
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 16                	js     801d75 <fd_close+0x66>
		if (dev->dev_close)
  801d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d62:	8b 40 10             	mov    0x10(%eax),%eax
  801d65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	74 07                	je     801d75 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801d6e:	89 34 24             	mov    %esi,(%esp)
  801d71:	ff d0                	call   *%eax
  801d73:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d75:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d80:	e8 89 f5 ff ff       	call   80130e <sys_page_unmap>
	return r;
}
  801d85:	89 d8                	mov    %ebx,%eax
  801d87:	83 c4 20             	add    $0x20,%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	e8 27 fc ff ff       	call   8019cd <fd_lookup>
  801da6:	85 c0                	test   %eax,%eax
  801da8:	78 13                	js     801dbd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801daa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801db1:	00 
  801db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db5:	89 04 24             	mov    %eax,(%esp)
  801db8:	e8 52 ff ff ff       	call   801d0f <fd_close>
}
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    

00801dbf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	83 ec 18             	sub    $0x18,%esp
  801dc5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dc8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801dcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dd2:	00 
  801dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd6:	89 04 24             	mov    %eax,(%esp)
  801dd9:	e8 79 03 00 00       	call   802157 <open>
  801dde:	89 c3                	mov    %eax,%ebx
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 1b                	js     801dff <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801de4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801deb:	89 1c 24             	mov    %ebx,(%esp)
  801dee:	e8 b7 fc ff ff       	call   801aaa <fstat>
  801df3:	89 c6                	mov    %eax,%esi
	close(fd);
  801df5:	89 1c 24             	mov    %ebx,(%esp)
  801df8:	e8 91 ff ff ff       	call   801d8e <close>
  801dfd:	89 f3                	mov    %esi,%ebx
	return r;
}
  801dff:	89 d8                	mov    %ebx,%eax
  801e01:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e04:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e07:	89 ec                	mov    %ebp,%esp
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    

00801e0b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	53                   	push   %ebx
  801e0f:	83 ec 14             	sub    $0x14,%esp
  801e12:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801e17:	89 1c 24             	mov    %ebx,(%esp)
  801e1a:	e8 6f ff ff ff       	call   801d8e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e1f:	83 c3 01             	add    $0x1,%ebx
  801e22:	83 fb 20             	cmp    $0x20,%ebx
  801e25:	75 f0                	jne    801e17 <close_all+0xc>
		close(i);
}
  801e27:	83 c4 14             	add    $0x14,%esp
  801e2a:	5b                   	pop    %ebx
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 58             	sub    $0x58,%esp
  801e33:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801e36:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801e39:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801e3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e3f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e46:	8b 45 08             	mov    0x8(%ebp),%eax
  801e49:	89 04 24             	mov    %eax,(%esp)
  801e4c:	e8 7c fb ff ff       	call   8019cd <fd_lookup>
  801e51:	89 c3                	mov    %eax,%ebx
  801e53:	85 c0                	test   %eax,%eax
  801e55:	0f 88 e0 00 00 00    	js     801f3b <dup+0x10e>
		return r;
	close(newfdnum);
  801e5b:	89 3c 24             	mov    %edi,(%esp)
  801e5e:	e8 2b ff ff ff       	call   801d8e <close>

	newfd = INDEX2FD(newfdnum);
  801e63:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801e69:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6f:	89 04 24             	mov    %eax,(%esp)
  801e72:	e8 c9 fa ff ff       	call   801940 <fd2data>
  801e77:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e79:	89 34 24             	mov    %esi,(%esp)
  801e7c:	e8 bf fa ff ff       	call   801940 <fd2data>
  801e81:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801e84:	89 da                	mov    %ebx,%edx
  801e86:	89 d8                	mov    %ebx,%eax
  801e88:	c1 e8 16             	shr    $0x16,%eax
  801e8b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e92:	a8 01                	test   $0x1,%al
  801e94:	74 43                	je     801ed9 <dup+0xac>
  801e96:	c1 ea 0c             	shr    $0xc,%edx
  801e99:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ea0:	a8 01                	test   $0x1,%al
  801ea2:	74 35                	je     801ed9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ea4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801eab:	25 07 0e 00 00       	and    $0xe07,%eax
  801eb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801eb4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801eb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ec2:	00 
  801ec3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ec7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ece:	e8 a7 f4 ff ff       	call   80137a <sys_page_map>
  801ed3:	89 c3                	mov    %eax,%ebx
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 3f                	js     801f18 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ed9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801edc:	89 c2                	mov    %eax,%edx
  801ede:	c1 ea 0c             	shr    $0xc,%edx
  801ee1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ee8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801eee:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ef2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ef6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801efd:	00 
  801efe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f09:	e8 6c f4 ff ff       	call   80137a <sys_page_map>
  801f0e:	89 c3                	mov    %eax,%ebx
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 04                	js     801f18 <dup+0xeb>
  801f14:	89 fb                	mov    %edi,%ebx
  801f16:	eb 23                	jmp    801f3b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f18:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f23:	e8 e6 f3 ff ff       	call   80130e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f36:	e8 d3 f3 ff ff       	call   80130e <sys_page_unmap>
	return r;
}
  801f3b:	89 d8                	mov    %ebx,%eax
  801f3d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801f40:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801f43:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801f46:	89 ec                	mov    %ebp,%esp
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    
	...

00801f4c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	83 ec 18             	sub    $0x18,%esp
  801f52:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f55:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f58:	89 c3                	mov    %eax,%ebx
  801f5a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801f5c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801f63:	75 11                	jne    801f76 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f65:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f6c:	e8 5f 08 00 00       	call   8027d0 <ipc_find_env>
  801f71:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f76:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f7d:	00 
  801f7e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801f85:	00 
  801f86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f8a:	a1 00 50 80 00       	mov    0x805000,%eax
  801f8f:	89 04 24             	mov    %eax,(%esp)
  801f92:	e8 84 08 00 00       	call   80281b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f9e:	00 
  801f9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801faa:	e8 ea 08 00 00       	call   802899 <ipc_recv>
}
  801faf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fb2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fb5:	89 ec                	mov    %ebp,%esp
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    

00801fb9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc2:	8b 40 0c             	mov    0xc(%eax),%eax
  801fc5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801fd2:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd7:	b8 02 00 00 00       	mov    $0x2,%eax
  801fdc:	e8 6b ff ff ff       	call   801f4c <fsipc>
}
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fec:	8b 40 0c             	mov    0xc(%eax),%eax
  801fef:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ff4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff9:	b8 06 00 00 00       	mov    $0x6,%eax
  801ffe:	e8 49 ff ff ff       	call   801f4c <fsipc>
}
  802003:	c9                   	leave  
  802004:	c3                   	ret    

00802005 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80200b:	ba 00 00 00 00       	mov    $0x0,%edx
  802010:	b8 08 00 00 00       	mov    $0x8,%eax
  802015:	e8 32 ff ff ff       	call   801f4c <fsipc>
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	53                   	push   %ebx
  802020:	83 ec 14             	sub    $0x14,%esp
  802023:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802026:	8b 45 08             	mov    0x8(%ebp),%eax
  802029:	8b 40 0c             	mov    0xc(%eax),%eax
  80202c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802031:	ba 00 00 00 00       	mov    $0x0,%edx
  802036:	b8 05 00 00 00       	mov    $0x5,%eax
  80203b:	e8 0c ff ff ff       	call   801f4c <fsipc>
  802040:	85 c0                	test   %eax,%eax
  802042:	78 2b                	js     80206f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802044:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80204b:	00 
  80204c:	89 1c 24             	mov    %ebx,(%esp)
  80204f:	e8 66 ea ff ff       	call   800aba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802054:	a1 80 60 80 00       	mov    0x806080,%eax
  802059:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80205f:	a1 84 60 80 00       	mov    0x806084,%eax
  802064:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80206a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80206f:	83 c4 14             	add    $0x14,%esp
  802072:	5b                   	pop    %ebx
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    

00802075 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	83 ec 18             	sub    $0x18,%esp
  80207b:	8b 45 10             	mov    0x10(%ebp),%eax
  80207e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802083:	76 05                	jbe    80208a <devfile_write+0x15>
  802085:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  80208a:	8b 55 08             	mov    0x8(%ebp),%edx
  80208d:	8b 52 0c             	mov    0xc(%edx),%edx
  802090:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  802096:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  80209b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8020ad:	e8 f3 eb ff ff       	call   800ca5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  8020b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8020b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8020bc:	e8 8b fe ff ff       	call   801f4c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    

008020c3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	53                   	push   %ebx
  8020c7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  8020ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8020d0:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  8020d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d8:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  8020dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8020e7:	e8 60 fe ff ff       	call   801f4c <fsipc>
  8020ec:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	78 17                	js     802109 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  8020f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020f6:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8020fd:	00 
  8020fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802101:	89 04 24             	mov    %eax,(%esp)
  802104:	e8 9c eb ff ff       	call   800ca5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802109:	89 d8                	mov    %ebx,%eax
  80210b:	83 c4 14             	add    $0x14,%esp
  80210e:	5b                   	pop    %ebx
  80210f:	5d                   	pop    %ebp
  802110:	c3                   	ret    

00802111 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802111:	55                   	push   %ebp
  802112:	89 e5                	mov    %esp,%ebp
  802114:	53                   	push   %ebx
  802115:	83 ec 14             	sub    $0x14,%esp
  802118:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80211b:	89 1c 24             	mov    %ebx,(%esp)
  80211e:	e8 4d e9 ff ff       	call   800a70 <strlen>
  802123:	89 c2                	mov    %eax,%edx
  802125:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80212a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802130:	7f 1f                	jg     802151 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802132:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802136:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80213d:	e8 78 e9 ff ff       	call   800aba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802142:	ba 00 00 00 00       	mov    $0x0,%edx
  802147:	b8 07 00 00 00       	mov    $0x7,%eax
  80214c:	e8 fb fd ff ff       	call   801f4c <fsipc>
}
  802151:	83 c4 14             	add    $0x14,%esp
  802154:	5b                   	pop    %ebx
  802155:	5d                   	pop    %ebp
  802156:	c3                   	ret    

00802157 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802157:	55                   	push   %ebp
  802158:	89 e5                	mov    %esp,%ebp
  80215a:	83 ec 28             	sub    $0x28,%esp
  80215d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802160:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802163:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802166:	89 34 24             	mov    %esi,(%esp)
  802169:	e8 02 e9 ff ff       	call   800a70 <strlen>
  80216e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802173:	3d 00 04 00 00       	cmp    $0x400,%eax
  802178:	7f 6d                	jg     8021e7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80217a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217d:	89 04 24             	mov    %eax,(%esp)
  802180:	e8 d6 f7 ff ff       	call   80195b <fd_alloc>
  802185:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  802187:	85 c0                	test   %eax,%eax
  802189:	78 5c                	js     8021e7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80218b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  802193:	89 34 24             	mov    %esi,(%esp)
  802196:	e8 d5 e8 ff ff       	call   800a70 <strlen>
  80219b:	83 c0 01             	add    $0x1,%eax
  80219e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8021ad:	e8 f3 ea ff ff       	call   800ca5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8021b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ba:	e8 8d fd ff ff       	call   801f4c <fsipc>
  8021bf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  8021c1:	85 c0                	test   %eax,%eax
  8021c3:	79 15                	jns    8021da <open+0x83>
             fd_close(fd,0);
  8021c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021cc:	00 
  8021cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d0:	89 04 24             	mov    %eax,(%esp)
  8021d3:	e8 37 fb ff ff       	call   801d0f <fd_close>
             return r;
  8021d8:	eb 0d                	jmp    8021e7 <open+0x90>
        }
        return fd2num(fd);
  8021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dd:	89 04 24             	mov    %eax,(%esp)
  8021e0:	e8 4b f7 ff ff       	call   801930 <fd2num>
  8021e5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8021e7:	89 d8                	mov    %ebx,%eax
  8021e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8021ec:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021ef:	89 ec                	mov    %ebp,%esp
  8021f1:	5d                   	pop    %ebp
  8021f2:	c3                   	ret    
	...

00802200 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802206:	c7 44 24 04 50 31 80 	movl   $0x803150,0x4(%esp)
  80220d:	00 
  80220e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802211:	89 04 24             	mov    %eax,(%esp)
  802214:	e8 a1 e8 ff ff       	call   800aba <strcpy>
	return 0;
}
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    

00802220 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	53                   	push   %ebx
  802224:	83 ec 14             	sub    $0x14,%esp
  802227:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80222a:	89 1c 24             	mov    %ebx,(%esp)
  80222d:	e8 da 06 00 00       	call   80290c <pageref>
  802232:	89 c2                	mov    %eax,%edx
  802234:	b8 00 00 00 00       	mov    $0x0,%eax
  802239:	83 fa 01             	cmp    $0x1,%edx
  80223c:	75 0b                	jne    802249 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80223e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802241:	89 04 24             	mov    %eax,(%esp)
  802244:	e8 b9 02 00 00       	call   802502 <nsipc_close>
	else
		return 0;
}
  802249:	83 c4 14             	add    $0x14,%esp
  80224c:	5b                   	pop    %ebx
  80224d:	5d                   	pop    %ebp
  80224e:	c3                   	ret    

0080224f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80224f:	55                   	push   %ebp
  802250:	89 e5                	mov    %esp,%ebp
  802252:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802255:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80225c:	00 
  80225d:	8b 45 10             	mov    0x10(%ebp),%eax
  802260:	89 44 24 08          	mov    %eax,0x8(%esp)
  802264:	8b 45 0c             	mov    0xc(%ebp),%eax
  802267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226b:	8b 45 08             	mov    0x8(%ebp),%eax
  80226e:	8b 40 0c             	mov    0xc(%eax),%eax
  802271:	89 04 24             	mov    %eax,(%esp)
  802274:	e8 c5 02 00 00       	call   80253e <nsipc_send>
}
  802279:	c9                   	leave  
  80227a:	c3                   	ret    

0080227b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802281:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802288:	00 
  802289:	8b 45 10             	mov    0x10(%ebp),%eax
  80228c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802290:	8b 45 0c             	mov    0xc(%ebp),%eax
  802293:	89 44 24 04          	mov    %eax,0x4(%esp)
  802297:	8b 45 08             	mov    0x8(%ebp),%eax
  80229a:	8b 40 0c             	mov    0xc(%eax),%eax
  80229d:	89 04 24             	mov    %eax,(%esp)
  8022a0:	e8 0c 03 00 00       	call   8025b1 <nsipc_recv>
}
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    

008022a7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8022a7:	55                   	push   %ebp
  8022a8:	89 e5                	mov    %esp,%ebp
  8022aa:	56                   	push   %esi
  8022ab:	53                   	push   %ebx
  8022ac:	83 ec 20             	sub    $0x20,%esp
  8022af:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8022b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b4:	89 04 24             	mov    %eax,(%esp)
  8022b7:	e8 9f f6 ff ff       	call   80195b <fd_alloc>
  8022bc:	89 c3                	mov    %eax,%ebx
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	78 21                	js     8022e3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8022c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022c9:	00 
  8022ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d8:	e8 0b f1 ff ff       	call   8013e8 <sys_page_alloc>
  8022dd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	79 0a                	jns    8022ed <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  8022e3:	89 34 24             	mov    %esi,(%esp)
  8022e6:	e8 17 02 00 00       	call   802502 <nsipc_close>
		return r;
  8022eb:	eb 28                	jmp    802315 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8022ed:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8022f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8022f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802302:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802305:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802308:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230b:	89 04 24             	mov    %eax,(%esp)
  80230e:	e8 1d f6 ff ff       	call   801930 <fd2num>
  802313:	89 c3                	mov    %eax,%ebx
}
  802315:	89 d8                	mov    %ebx,%eax
  802317:	83 c4 20             	add    $0x20,%esp
  80231a:	5b                   	pop    %ebx
  80231b:	5e                   	pop    %esi
  80231c:	5d                   	pop    %ebp
  80231d:	c3                   	ret    

0080231e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802324:	8b 45 10             	mov    0x10(%ebp),%eax
  802327:	89 44 24 08          	mov    %eax,0x8(%esp)
  80232b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80232e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802332:	8b 45 08             	mov    0x8(%ebp),%eax
  802335:	89 04 24             	mov    %eax,(%esp)
  802338:	e8 79 01 00 00       	call   8024b6 <nsipc_socket>
  80233d:	85 c0                	test   %eax,%eax
  80233f:	78 05                	js     802346 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802341:	e8 61 ff ff ff       	call   8022a7 <alloc_sockfd>
}
  802346:	c9                   	leave  
  802347:	c3                   	ret    

00802348 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802348:	55                   	push   %ebp
  802349:	89 e5                	mov    %esp,%ebp
  80234b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80234e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802351:	89 54 24 04          	mov    %edx,0x4(%esp)
  802355:	89 04 24             	mov    %eax,(%esp)
  802358:	e8 70 f6 ff ff       	call   8019cd <fd_lookup>
  80235d:	85 c0                	test   %eax,%eax
  80235f:	78 15                	js     802376 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802361:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802364:	8b 0a                	mov    (%edx),%ecx
  802366:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80236b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802371:	75 03                	jne    802376 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802373:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802376:	c9                   	leave  
  802377:	c3                   	ret    

00802378 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80237e:	8b 45 08             	mov    0x8(%ebp),%eax
  802381:	e8 c2 ff ff ff       	call   802348 <fd2sockid>
  802386:	85 c0                	test   %eax,%eax
  802388:	78 0f                	js     802399 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80238a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80238d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802391:	89 04 24             	mov    %eax,(%esp)
  802394:	e8 47 01 00 00       	call   8024e0 <nsipc_listen>
}
  802399:	c9                   	leave  
  80239a:	c3                   	ret    

0080239b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80239b:	55                   	push   %ebp
  80239c:	89 e5                	mov    %esp,%ebp
  80239e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a4:	e8 9f ff ff ff       	call   802348 <fd2sockid>
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	78 16                	js     8023c3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8023ad:	8b 55 10             	mov    0x10(%ebp),%edx
  8023b0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023bb:	89 04 24             	mov    %eax,(%esp)
  8023be:	e8 6e 02 00 00       	call   802631 <nsipc_connect>
}
  8023c3:	c9                   	leave  
  8023c4:	c3                   	ret    

008023c5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ce:	e8 75 ff ff ff       	call   802348 <fd2sockid>
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	78 0f                	js     8023e6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8023d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023de:	89 04 24             	mov    %eax,(%esp)
  8023e1:	e8 36 01 00 00       	call   80251c <nsipc_shutdown>
}
  8023e6:	c9                   	leave  
  8023e7:	c3                   	ret    

008023e8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f1:	e8 52 ff ff ff       	call   802348 <fd2sockid>
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	78 16                	js     802410 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8023fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8023fd:	89 54 24 08          	mov    %edx,0x8(%esp)
  802401:	8b 55 0c             	mov    0xc(%ebp),%edx
  802404:	89 54 24 04          	mov    %edx,0x4(%esp)
  802408:	89 04 24             	mov    %eax,(%esp)
  80240b:	e8 60 02 00 00       	call   802670 <nsipc_bind>
}
  802410:	c9                   	leave  
  802411:	c3                   	ret    

00802412 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802418:	8b 45 08             	mov    0x8(%ebp),%eax
  80241b:	e8 28 ff ff ff       	call   802348 <fd2sockid>
  802420:	85 c0                	test   %eax,%eax
  802422:	78 1f                	js     802443 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802424:	8b 55 10             	mov    0x10(%ebp),%edx
  802427:	89 54 24 08          	mov    %edx,0x8(%esp)
  80242b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80242e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802432:	89 04 24             	mov    %eax,(%esp)
  802435:	e8 75 02 00 00       	call   8026af <nsipc_accept>
  80243a:	85 c0                	test   %eax,%eax
  80243c:	78 05                	js     802443 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80243e:	e8 64 fe ff ff       	call   8022a7 <alloc_sockfd>
}
  802443:	c9                   	leave  
  802444:	c3                   	ret    
	...

00802450 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	53                   	push   %ebx
  802454:	83 ec 14             	sub    $0x14,%esp
  802457:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802459:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802460:	75 11                	jne    802473 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802462:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802469:	e8 62 03 00 00       	call   8027d0 <ipc_find_env>
  80246e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802473:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80247a:	00 
  80247b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802482:	00 
  802483:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802487:	a1 04 50 80 00       	mov    0x805004,%eax
  80248c:	89 04 24             	mov    %eax,(%esp)
  80248f:	e8 87 03 00 00       	call   80281b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802494:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80249b:	00 
  80249c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8024a3:	00 
  8024a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024ab:	e8 e9 03 00 00       	call   802899 <ipc_recv>
}
  8024b0:	83 c4 14             	add    $0x14,%esp
  8024b3:	5b                   	pop    %ebx
  8024b4:	5d                   	pop    %ebp
  8024b5:	c3                   	ret    

008024b6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8024b6:	55                   	push   %ebp
  8024b7:	89 e5                	mov    %esp,%ebp
  8024b9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8024bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8024c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8024cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8024cf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8024d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8024d9:	e8 72 ff ff ff       	call   802450 <nsipc>
}
  8024de:	c9                   	leave  
  8024df:	c3                   	ret    

008024e0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8024e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8024ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8024f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8024fb:	e8 50 ff ff ff       	call   802450 <nsipc>
}
  802500:	c9                   	leave  
  802501:	c3                   	ret    

00802502 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802502:	55                   	push   %ebp
  802503:	89 e5                	mov    %esp,%ebp
  802505:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802508:	8b 45 08             	mov    0x8(%ebp),%eax
  80250b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802510:	b8 04 00 00 00       	mov    $0x4,%eax
  802515:	e8 36 ff ff ff       	call   802450 <nsipc>
}
  80251a:	c9                   	leave  
  80251b:	c3                   	ret    

0080251c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80251c:	55                   	push   %ebp
  80251d:	89 e5                	mov    %esp,%ebp
  80251f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802522:	8b 45 08             	mov    0x8(%ebp),%eax
  802525:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80252a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80252d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802532:	b8 03 00 00 00       	mov    $0x3,%eax
  802537:	e8 14 ff ff ff       	call   802450 <nsipc>
}
  80253c:	c9                   	leave  
  80253d:	c3                   	ret    

0080253e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80253e:	55                   	push   %ebp
  80253f:	89 e5                	mov    %esp,%ebp
  802541:	53                   	push   %ebx
  802542:	83 ec 14             	sub    $0x14,%esp
  802545:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802548:	8b 45 08             	mov    0x8(%ebp),%eax
  80254b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802550:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802556:	7e 24                	jle    80257c <nsipc_send+0x3e>
  802558:	c7 44 24 0c 5c 31 80 	movl   $0x80315c,0xc(%esp)
  80255f:	00 
  802560:	c7 44 24 08 68 31 80 	movl   $0x803168,0x8(%esp)
  802567:	00 
  802568:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80256f:	00 
  802570:	c7 04 24 7d 31 80 00 	movl   $0x80317d,(%esp)
  802577:	e8 88 01 00 00       	call   802704 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80257c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802580:	8b 45 0c             	mov    0xc(%ebp),%eax
  802583:	89 44 24 04          	mov    %eax,0x4(%esp)
  802587:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80258e:	e8 12 e7 ff ff       	call   800ca5 <memmove>
	nsipcbuf.send.req_size = size;
  802593:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802599:	8b 45 14             	mov    0x14(%ebp),%eax
  80259c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8025a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8025a6:	e8 a5 fe ff ff       	call   802450 <nsipc>
}
  8025ab:	83 c4 14             	add    $0x14,%esp
  8025ae:	5b                   	pop    %ebx
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	56                   	push   %esi
  8025b5:	53                   	push   %ebx
  8025b6:	83 ec 10             	sub    $0x10,%esp
  8025b9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8025bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8025bf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8025c4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8025ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8025cd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025d2:	b8 07 00 00 00       	mov    $0x7,%eax
  8025d7:	e8 74 fe ff ff       	call   802450 <nsipc>
  8025dc:	89 c3                	mov    %eax,%ebx
  8025de:	85 c0                	test   %eax,%eax
  8025e0:	78 46                	js     802628 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8025e2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025e7:	7f 04                	jg     8025ed <nsipc_recv+0x3c>
  8025e9:	39 c6                	cmp    %eax,%esi
  8025eb:	7d 24                	jge    802611 <nsipc_recv+0x60>
  8025ed:	c7 44 24 0c 89 31 80 	movl   $0x803189,0xc(%esp)
  8025f4:	00 
  8025f5:	c7 44 24 08 68 31 80 	movl   $0x803168,0x8(%esp)
  8025fc:	00 
  8025fd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802604:	00 
  802605:	c7 04 24 7d 31 80 00 	movl   $0x80317d,(%esp)
  80260c:	e8 f3 00 00 00       	call   802704 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802611:	89 44 24 08          	mov    %eax,0x8(%esp)
  802615:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80261c:	00 
  80261d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802620:	89 04 24             	mov    %eax,(%esp)
  802623:	e8 7d e6 ff ff       	call   800ca5 <memmove>
	}

	return r;
}
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	83 c4 10             	add    $0x10,%esp
  80262d:	5b                   	pop    %ebx
  80262e:	5e                   	pop    %esi
  80262f:	5d                   	pop    %ebp
  802630:	c3                   	ret    

00802631 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802631:	55                   	push   %ebp
  802632:	89 e5                	mov    %esp,%ebp
  802634:	53                   	push   %ebx
  802635:	83 ec 14             	sub    $0x14,%esp
  802638:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80263b:	8b 45 08             	mov    0x8(%ebp),%eax
  80263e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802643:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802647:	8b 45 0c             	mov    0xc(%ebp),%eax
  80264a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80264e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802655:	e8 4b e6 ff ff       	call   800ca5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80265a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802660:	b8 05 00 00 00       	mov    $0x5,%eax
  802665:	e8 e6 fd ff ff       	call   802450 <nsipc>
}
  80266a:	83 c4 14             	add    $0x14,%esp
  80266d:	5b                   	pop    %ebx
  80266e:	5d                   	pop    %ebp
  80266f:	c3                   	ret    

00802670 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
  802673:	53                   	push   %ebx
  802674:	83 ec 14             	sub    $0x14,%esp
  802677:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80267a:	8b 45 08             	mov    0x8(%ebp),%eax
  80267d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802682:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802686:	8b 45 0c             	mov    0xc(%ebp),%eax
  802689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80268d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802694:	e8 0c e6 ff ff       	call   800ca5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802699:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80269f:	b8 02 00 00 00       	mov    $0x2,%eax
  8026a4:	e8 a7 fd ff ff       	call   802450 <nsipc>
}
  8026a9:	83 c4 14             	add    $0x14,%esp
  8026ac:	5b                   	pop    %ebx
  8026ad:	5d                   	pop    %ebp
  8026ae:	c3                   	ret    

008026af <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8026af:	55                   	push   %ebp
  8026b0:	89 e5                	mov    %esp,%ebp
  8026b2:	83 ec 18             	sub    $0x18,%esp
  8026b5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8026b8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8026bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026be:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8026c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8026c8:	e8 83 fd ff ff       	call   802450 <nsipc>
  8026cd:	89 c3                	mov    %eax,%ebx
  8026cf:	85 c0                	test   %eax,%eax
  8026d1:	78 25                	js     8026f8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8026d3:	be 10 70 80 00       	mov    $0x807010,%esi
  8026d8:	8b 06                	mov    (%esi),%eax
  8026da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026de:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8026e5:	00 
  8026e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026e9:	89 04 24             	mov    %eax,(%esp)
  8026ec:	e8 b4 e5 ff ff       	call   800ca5 <memmove>
		*addrlen = ret->ret_addrlen;
  8026f1:	8b 16                	mov    (%esi),%edx
  8026f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8026f6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8026f8:	89 d8                	mov    %ebx,%eax
  8026fa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8026fd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802700:	89 ec                	mov    %ebp,%esp
  802702:	5d                   	pop    %ebp
  802703:	c3                   	ret    

00802704 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802704:	55                   	push   %ebp
  802705:	89 e5                	mov    %esp,%ebp
  802707:	56                   	push   %esi
  802708:	53                   	push   %ebx
  802709:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80270c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80270f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  802715:	e8 bd ed ff ff       	call   8014d7 <sys_getenvid>
  80271a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80271d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802721:	8b 55 08             	mov    0x8(%ebp),%edx
  802724:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802728:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80272c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802730:	c7 04 24 a0 31 80 00 	movl   $0x8031a0,(%esp)
  802737:	e8 55 da ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80273c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802740:	8b 45 10             	mov    0x10(%ebp),%eax
  802743:	89 04 24             	mov    %eax,(%esp)
  802746:	e8 e5 d9 ff ff       	call   800130 <vcprintf>
	cprintf("\n");
  80274b:	c7 04 24 54 2c 80 00 	movl   $0x802c54,(%esp)
  802752:	e8 3a da ff ff       	call   800191 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802757:	cc                   	int3   
  802758:	eb fd                	jmp    802757 <_panic+0x53>
	...

0080275c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80275c:	55                   	push   %ebp
  80275d:	89 e5                	mov    %esp,%ebp
  80275f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802762:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802769:	75 30                	jne    80279b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80276b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802772:	00 
  802773:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80277a:	ee 
  80277b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802782:	e8 61 ec ff ff       	call   8013e8 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802787:	c7 44 24 04 a8 27 80 	movl   $0x8027a8,0x4(%esp)
  80278e:	00 
  80278f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802796:	e8 2f ea ff ff       	call   8011ca <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80279b:	8b 45 08             	mov    0x8(%ebp),%eax
  80279e:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8027a3:	c9                   	leave  
  8027a4:	c3                   	ret    
  8027a5:	00 00                	add    %al,(%eax)
	...

008027a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027a9:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8027ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027b0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8027b3:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8027b7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8027bb:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8027be:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8027c0:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8027c4:	83 c4 08             	add    $0x8,%esp
        popal
  8027c7:	61                   	popa   
        addl $0x4,%esp
  8027c8:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8027cb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8027cc:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8027cd:	c3                   	ret    
	...

008027d0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027d0:	55                   	push   %ebp
  8027d1:	89 e5                	mov    %esp,%ebp
  8027d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8027d6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8027dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8027e1:	39 ca                	cmp    %ecx,%edx
  8027e3:	75 04                	jne    8027e9 <ipc_find_env+0x19>
  8027e5:	b0 00                	mov    $0x0,%al
  8027e7:	eb 12                	jmp    8027fb <ipc_find_env+0x2b>
  8027e9:	89 c2                	mov    %eax,%edx
  8027eb:	c1 e2 07             	shl    $0x7,%edx
  8027ee:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8027f5:	8b 12                	mov    (%edx),%edx
  8027f7:	39 ca                	cmp    %ecx,%edx
  8027f9:	75 10                	jne    80280b <ipc_find_env+0x3b>
			return envs[i].env_id;
  8027fb:	89 c2                	mov    %eax,%edx
  8027fd:	c1 e2 07             	shl    $0x7,%edx
  802800:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802807:	8b 00                	mov    (%eax),%eax
  802809:	eb 0e                	jmp    802819 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80280b:	83 c0 01             	add    $0x1,%eax
  80280e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802813:	75 d4                	jne    8027e9 <ipc_find_env+0x19>
  802815:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802819:	5d                   	pop    %ebp
  80281a:	c3                   	ret    

0080281b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80281b:	55                   	push   %ebp
  80281c:	89 e5                	mov    %esp,%ebp
  80281e:	57                   	push   %edi
  80281f:	56                   	push   %esi
  802820:	53                   	push   %ebx
  802821:	83 ec 1c             	sub    $0x1c,%esp
  802824:	8b 75 08             	mov    0x8(%ebp),%esi
  802827:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80282a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80282d:	85 db                	test   %ebx,%ebx
  80282f:	74 19                	je     80284a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802831:	8b 45 14             	mov    0x14(%ebp),%eax
  802834:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802838:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80283c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802840:	89 34 24             	mov    %esi,(%esp)
  802843:	e8 41 e9 ff ff       	call   801189 <sys_ipc_try_send>
  802848:	eb 1b                	jmp    802865 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80284a:	8b 45 14             	mov    0x14(%ebp),%eax
  80284d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802851:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802858:	ee 
  802859:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80285d:	89 34 24             	mov    %esi,(%esp)
  802860:	e8 24 e9 ff ff       	call   801189 <sys_ipc_try_send>
           if(ret == 0)
  802865:	85 c0                	test   %eax,%eax
  802867:	74 28                	je     802891 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802869:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80286c:	74 1c                	je     80288a <ipc_send+0x6f>
              panic("ipc send error");
  80286e:	c7 44 24 08 c4 31 80 	movl   $0x8031c4,0x8(%esp)
  802875:	00 
  802876:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80287d:	00 
  80287e:	c7 04 24 d3 31 80 00 	movl   $0x8031d3,(%esp)
  802885:	e8 7a fe ff ff       	call   802704 <_panic>
           sys_yield();
  80288a:	e8 c6 eb ff ff       	call   801455 <sys_yield>
        }
  80288f:	eb 9c                	jmp    80282d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802891:	83 c4 1c             	add    $0x1c,%esp
  802894:	5b                   	pop    %ebx
  802895:	5e                   	pop    %esi
  802896:	5f                   	pop    %edi
  802897:	5d                   	pop    %ebp
  802898:	c3                   	ret    

00802899 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802899:	55                   	push   %ebp
  80289a:	89 e5                	mov    %esp,%ebp
  80289c:	56                   	push   %esi
  80289d:	53                   	push   %ebx
  80289e:	83 ec 10             	sub    $0x10,%esp
  8028a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8028a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8028aa:	85 c0                	test   %eax,%eax
  8028ac:	75 0e                	jne    8028bc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8028ae:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8028b5:	e8 64 e8 ff ff       	call   80111e <sys_ipc_recv>
  8028ba:	eb 08                	jmp    8028c4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8028bc:	89 04 24             	mov    %eax,(%esp)
  8028bf:	e8 5a e8 ff ff       	call   80111e <sys_ipc_recv>
        if(ret == 0){
  8028c4:	85 c0                	test   %eax,%eax
  8028c6:	75 26                	jne    8028ee <ipc_recv+0x55>
           if(from_env_store)
  8028c8:	85 f6                	test   %esi,%esi
  8028ca:	74 0a                	je     8028d6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  8028cc:	a1 08 50 80 00       	mov    0x805008,%eax
  8028d1:	8b 40 78             	mov    0x78(%eax),%eax
  8028d4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  8028d6:	85 db                	test   %ebx,%ebx
  8028d8:	74 0a                	je     8028e4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  8028da:	a1 08 50 80 00       	mov    0x805008,%eax
  8028df:	8b 40 7c             	mov    0x7c(%eax),%eax
  8028e2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8028e4:	a1 08 50 80 00       	mov    0x805008,%eax
  8028e9:	8b 40 74             	mov    0x74(%eax),%eax
  8028ec:	eb 14                	jmp    802902 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8028ee:	85 f6                	test   %esi,%esi
  8028f0:	74 06                	je     8028f8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8028f2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8028f8:	85 db                	test   %ebx,%ebx
  8028fa:	74 06                	je     802902 <ipc_recv+0x69>
              *perm_store = 0;
  8028fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802902:	83 c4 10             	add    $0x10,%esp
  802905:	5b                   	pop    %ebx
  802906:	5e                   	pop    %esi
  802907:	5d                   	pop    %ebp
  802908:	c3                   	ret    
  802909:	00 00                	add    %al,(%eax)
	...

0080290c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80290c:	55                   	push   %ebp
  80290d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80290f:	8b 45 08             	mov    0x8(%ebp),%eax
  802912:	89 c2                	mov    %eax,%edx
  802914:	c1 ea 16             	shr    $0x16,%edx
  802917:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80291e:	f6 c2 01             	test   $0x1,%dl
  802921:	74 20                	je     802943 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802923:	c1 e8 0c             	shr    $0xc,%eax
  802926:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80292d:	a8 01                	test   $0x1,%al
  80292f:	74 12                	je     802943 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802931:	c1 e8 0c             	shr    $0xc,%eax
  802934:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802939:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80293e:	0f b7 c0             	movzwl %ax,%eax
  802941:	eb 05                	jmp    802948 <pageref+0x3c>
  802943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802948:	5d                   	pop    %ebp
  802949:	c3                   	ret    
  80294a:	00 00                	add    %al,(%eax)
  80294c:	00 00                	add    %al,(%eax)
	...

00802950 <__udivdi3>:
  802950:	55                   	push   %ebp
  802951:	89 e5                	mov    %esp,%ebp
  802953:	57                   	push   %edi
  802954:	56                   	push   %esi
  802955:	83 ec 10             	sub    $0x10,%esp
  802958:	8b 45 14             	mov    0x14(%ebp),%eax
  80295b:	8b 55 08             	mov    0x8(%ebp),%edx
  80295e:	8b 75 10             	mov    0x10(%ebp),%esi
  802961:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802964:	85 c0                	test   %eax,%eax
  802966:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802969:	75 35                	jne    8029a0 <__udivdi3+0x50>
  80296b:	39 fe                	cmp    %edi,%esi
  80296d:	77 61                	ja     8029d0 <__udivdi3+0x80>
  80296f:	85 f6                	test   %esi,%esi
  802971:	75 0b                	jne    80297e <__udivdi3+0x2e>
  802973:	b8 01 00 00 00       	mov    $0x1,%eax
  802978:	31 d2                	xor    %edx,%edx
  80297a:	f7 f6                	div    %esi
  80297c:	89 c6                	mov    %eax,%esi
  80297e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802981:	31 d2                	xor    %edx,%edx
  802983:	89 f8                	mov    %edi,%eax
  802985:	f7 f6                	div    %esi
  802987:	89 c7                	mov    %eax,%edi
  802989:	89 c8                	mov    %ecx,%eax
  80298b:	f7 f6                	div    %esi
  80298d:	89 c1                	mov    %eax,%ecx
  80298f:	89 fa                	mov    %edi,%edx
  802991:	89 c8                	mov    %ecx,%eax
  802993:	83 c4 10             	add    $0x10,%esp
  802996:	5e                   	pop    %esi
  802997:	5f                   	pop    %edi
  802998:	5d                   	pop    %ebp
  802999:	c3                   	ret    
  80299a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029a0:	39 f8                	cmp    %edi,%eax
  8029a2:	77 1c                	ja     8029c0 <__udivdi3+0x70>
  8029a4:	0f bd d0             	bsr    %eax,%edx
  8029a7:	83 f2 1f             	xor    $0x1f,%edx
  8029aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8029ad:	75 39                	jne    8029e8 <__udivdi3+0x98>
  8029af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8029b2:	0f 86 a0 00 00 00    	jbe    802a58 <__udivdi3+0x108>
  8029b8:	39 f8                	cmp    %edi,%eax
  8029ba:	0f 82 98 00 00 00    	jb     802a58 <__udivdi3+0x108>
  8029c0:	31 ff                	xor    %edi,%edi
  8029c2:	31 c9                	xor    %ecx,%ecx
  8029c4:	89 c8                	mov    %ecx,%eax
  8029c6:	89 fa                	mov    %edi,%edx
  8029c8:	83 c4 10             	add    $0x10,%esp
  8029cb:	5e                   	pop    %esi
  8029cc:	5f                   	pop    %edi
  8029cd:	5d                   	pop    %ebp
  8029ce:	c3                   	ret    
  8029cf:	90                   	nop
  8029d0:	89 d1                	mov    %edx,%ecx
  8029d2:	89 fa                	mov    %edi,%edx
  8029d4:	89 c8                	mov    %ecx,%eax
  8029d6:	31 ff                	xor    %edi,%edi
  8029d8:	f7 f6                	div    %esi
  8029da:	89 c1                	mov    %eax,%ecx
  8029dc:	89 fa                	mov    %edi,%edx
  8029de:	89 c8                	mov    %ecx,%eax
  8029e0:	83 c4 10             	add    $0x10,%esp
  8029e3:	5e                   	pop    %esi
  8029e4:	5f                   	pop    %edi
  8029e5:	5d                   	pop    %ebp
  8029e6:	c3                   	ret    
  8029e7:	90                   	nop
  8029e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8029ec:	89 f2                	mov    %esi,%edx
  8029ee:	d3 e0                	shl    %cl,%eax
  8029f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8029f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8029f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8029fb:	89 c1                	mov    %eax,%ecx
  8029fd:	d3 ea                	shr    %cl,%edx
  8029ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a03:	0b 55 ec             	or     -0x14(%ebp),%edx
  802a06:	d3 e6                	shl    %cl,%esi
  802a08:	89 c1                	mov    %eax,%ecx
  802a0a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802a0d:	89 fe                	mov    %edi,%esi
  802a0f:	d3 ee                	shr    %cl,%esi
  802a11:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a15:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a1b:	d3 e7                	shl    %cl,%edi
  802a1d:	89 c1                	mov    %eax,%ecx
  802a1f:	d3 ea                	shr    %cl,%edx
  802a21:	09 d7                	or     %edx,%edi
  802a23:	89 f2                	mov    %esi,%edx
  802a25:	89 f8                	mov    %edi,%eax
  802a27:	f7 75 ec             	divl   -0x14(%ebp)
  802a2a:	89 d6                	mov    %edx,%esi
  802a2c:	89 c7                	mov    %eax,%edi
  802a2e:	f7 65 e8             	mull   -0x18(%ebp)
  802a31:	39 d6                	cmp    %edx,%esi
  802a33:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a36:	72 30                	jb     802a68 <__udivdi3+0x118>
  802a38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a3b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a3f:	d3 e2                	shl    %cl,%edx
  802a41:	39 c2                	cmp    %eax,%edx
  802a43:	73 05                	jae    802a4a <__udivdi3+0xfa>
  802a45:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802a48:	74 1e                	je     802a68 <__udivdi3+0x118>
  802a4a:	89 f9                	mov    %edi,%ecx
  802a4c:	31 ff                	xor    %edi,%edi
  802a4e:	e9 71 ff ff ff       	jmp    8029c4 <__udivdi3+0x74>
  802a53:	90                   	nop
  802a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a58:	31 ff                	xor    %edi,%edi
  802a5a:	b9 01 00 00 00       	mov    $0x1,%ecx
  802a5f:	e9 60 ff ff ff       	jmp    8029c4 <__udivdi3+0x74>
  802a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a68:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802a6b:	31 ff                	xor    %edi,%edi
  802a6d:	89 c8                	mov    %ecx,%eax
  802a6f:	89 fa                	mov    %edi,%edx
  802a71:	83 c4 10             	add    $0x10,%esp
  802a74:	5e                   	pop    %esi
  802a75:	5f                   	pop    %edi
  802a76:	5d                   	pop    %ebp
  802a77:	c3                   	ret    
	...

00802a80 <__umoddi3>:
  802a80:	55                   	push   %ebp
  802a81:	89 e5                	mov    %esp,%ebp
  802a83:	57                   	push   %edi
  802a84:	56                   	push   %esi
  802a85:	83 ec 20             	sub    $0x20,%esp
  802a88:	8b 55 14             	mov    0x14(%ebp),%edx
  802a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a8e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802a91:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a94:	85 d2                	test   %edx,%edx
  802a96:	89 c8                	mov    %ecx,%eax
  802a98:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802a9b:	75 13                	jne    802ab0 <__umoddi3+0x30>
  802a9d:	39 f7                	cmp    %esi,%edi
  802a9f:	76 3f                	jbe    802ae0 <__umoddi3+0x60>
  802aa1:	89 f2                	mov    %esi,%edx
  802aa3:	f7 f7                	div    %edi
  802aa5:	89 d0                	mov    %edx,%eax
  802aa7:	31 d2                	xor    %edx,%edx
  802aa9:	83 c4 20             	add    $0x20,%esp
  802aac:	5e                   	pop    %esi
  802aad:	5f                   	pop    %edi
  802aae:	5d                   	pop    %ebp
  802aaf:	c3                   	ret    
  802ab0:	39 f2                	cmp    %esi,%edx
  802ab2:	77 4c                	ja     802b00 <__umoddi3+0x80>
  802ab4:	0f bd ca             	bsr    %edx,%ecx
  802ab7:	83 f1 1f             	xor    $0x1f,%ecx
  802aba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802abd:	75 51                	jne    802b10 <__umoddi3+0x90>
  802abf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802ac2:	0f 87 e0 00 00 00    	ja     802ba8 <__umoddi3+0x128>
  802ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802acb:	29 f8                	sub    %edi,%eax
  802acd:	19 d6                	sbb    %edx,%esi
  802acf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ad5:	89 f2                	mov    %esi,%edx
  802ad7:	83 c4 20             	add    $0x20,%esp
  802ada:	5e                   	pop    %esi
  802adb:	5f                   	pop    %edi
  802adc:	5d                   	pop    %ebp
  802add:	c3                   	ret    
  802ade:	66 90                	xchg   %ax,%ax
  802ae0:	85 ff                	test   %edi,%edi
  802ae2:	75 0b                	jne    802aef <__umoddi3+0x6f>
  802ae4:	b8 01 00 00 00       	mov    $0x1,%eax
  802ae9:	31 d2                	xor    %edx,%edx
  802aeb:	f7 f7                	div    %edi
  802aed:	89 c7                	mov    %eax,%edi
  802aef:	89 f0                	mov    %esi,%eax
  802af1:	31 d2                	xor    %edx,%edx
  802af3:	f7 f7                	div    %edi
  802af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802af8:	f7 f7                	div    %edi
  802afa:	eb a9                	jmp    802aa5 <__umoddi3+0x25>
  802afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b00:	89 c8                	mov    %ecx,%eax
  802b02:	89 f2                	mov    %esi,%edx
  802b04:	83 c4 20             	add    $0x20,%esp
  802b07:	5e                   	pop    %esi
  802b08:	5f                   	pop    %edi
  802b09:	5d                   	pop    %ebp
  802b0a:	c3                   	ret    
  802b0b:	90                   	nop
  802b0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b10:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b14:	d3 e2                	shl    %cl,%edx
  802b16:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b19:	ba 20 00 00 00       	mov    $0x20,%edx
  802b1e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802b21:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802b24:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b28:	89 fa                	mov    %edi,%edx
  802b2a:	d3 ea                	shr    %cl,%edx
  802b2c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b30:	0b 55 f4             	or     -0xc(%ebp),%edx
  802b33:	d3 e7                	shl    %cl,%edi
  802b35:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b39:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b3c:	89 f2                	mov    %esi,%edx
  802b3e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802b41:	89 c7                	mov    %eax,%edi
  802b43:	d3 ea                	shr    %cl,%edx
  802b45:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b49:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802b4c:	89 c2                	mov    %eax,%edx
  802b4e:	d3 e6                	shl    %cl,%esi
  802b50:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b54:	d3 ea                	shr    %cl,%edx
  802b56:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b5a:	09 d6                	or     %edx,%esi
  802b5c:	89 f0                	mov    %esi,%eax
  802b5e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802b61:	d3 e7                	shl    %cl,%edi
  802b63:	89 f2                	mov    %esi,%edx
  802b65:	f7 75 f4             	divl   -0xc(%ebp)
  802b68:	89 d6                	mov    %edx,%esi
  802b6a:	f7 65 e8             	mull   -0x18(%ebp)
  802b6d:	39 d6                	cmp    %edx,%esi
  802b6f:	72 2b                	jb     802b9c <__umoddi3+0x11c>
  802b71:	39 c7                	cmp    %eax,%edi
  802b73:	72 23                	jb     802b98 <__umoddi3+0x118>
  802b75:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b79:	29 c7                	sub    %eax,%edi
  802b7b:	19 d6                	sbb    %edx,%esi
  802b7d:	89 f0                	mov    %esi,%eax
  802b7f:	89 f2                	mov    %esi,%edx
  802b81:	d3 ef                	shr    %cl,%edi
  802b83:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b87:	d3 e0                	shl    %cl,%eax
  802b89:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b8d:	09 f8                	or     %edi,%eax
  802b8f:	d3 ea                	shr    %cl,%edx
  802b91:	83 c4 20             	add    $0x20,%esp
  802b94:	5e                   	pop    %esi
  802b95:	5f                   	pop    %edi
  802b96:	5d                   	pop    %ebp
  802b97:	c3                   	ret    
  802b98:	39 d6                	cmp    %edx,%esi
  802b9a:	75 d9                	jne    802b75 <__umoddi3+0xf5>
  802b9c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802b9f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802ba2:	eb d1                	jmp    802b75 <__umoddi3+0xf5>
  802ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ba8:	39 f2                	cmp    %esi,%edx
  802baa:	0f 82 18 ff ff ff    	jb     802ac8 <__umoddi3+0x48>
  802bb0:	e9 1d ff ff ff       	jmp    802ad2 <__umoddi3+0x52>
