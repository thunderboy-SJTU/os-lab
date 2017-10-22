
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 97 00 00 00       	call   8000c8 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 a1 13 00 00       	call   8013e2 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 40 80 00 84 	cmpl   $0xeec00084,0x804004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 ef 14 00 00       	call   801559 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 60 21 80 00 	movl   $0x802160,(%esp)
  80007c:	e8 18 01 00 00       	call   800199 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 cc 00 c0 ee       	mov    0xeec000cc,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 71 21 80 00 	movl   $0x802171,(%esp)
  800097:	e8 fd 00 00 00       	call   800199 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	bb cc 00 c0 ee       	mov    $0xeec000cc,%ebx
  8000a1:	8b 03                	mov    (%ebx),%eax
  8000a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b2:	00 
  8000b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ba:	00 
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 18 14 00 00       	call   8014db <ipc_send>
  8000c3:	eb dc                	jmp    8000a1 <umain+0x6d>
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
  8000ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000d1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000da:	e8 03 13 00 00       	call   8013e2 <sys_getenvid>
  8000df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e4:	89 c2                	mov    %eax,%edx
  8000e6:	c1 e2 07             	shl    $0x7,%edx
  8000e9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000f0:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f5:	85 f6                	test   %esi,%esi
  8000f7:	7e 07                	jle    800100 <libmain+0x38>
		binaryname = argv[0];
  8000f9:	8b 03                	mov    (%ebx),%eax
  8000fb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800100:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800104:	89 34 24             	mov    %esi,(%esp)
  800107:	e8 28 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80010c:	e8 0b 00 00 00       	call   80011c <exit>
}
  800111:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800114:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800117:	89 ec                	mov    %ebp,%esp
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    
	...

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800122:	e8 84 19 00 00       	call   801aab <close_all>
	sys_env_destroy(0);
  800127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012e:	e8 ef 12 00 00       	call   801422 <sys_env_destroy>
}
  800133:	c9                   	leave  
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800141:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800148:	00 00 00 
	b.cnt = 0;
  80014b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800152:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800155:	8b 45 0c             	mov    0xc(%ebp),%eax
  800158:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800163:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	c7 04 24 b3 01 80 00 	movl   $0x8001b3,(%esp)
  800174:	e8 d3 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800179:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800183:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800189:	89 04 24             	mov    %eax,(%esp)
  80018c:	e8 6b 0d 00 00       	call   800efc <sys_cputs>

	return b.cnt;
}
  800191:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80019f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	89 04 24             	mov    %eax,(%esp)
  8001ac:	e8 87 ff ff ff       	call   800138 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    

008001b3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	53                   	push   %ebx
  8001b7:	83 ec 14             	sub    $0x14,%esp
  8001ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001bd:	8b 03                	mov    (%ebx),%eax
  8001bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c6:	83 c0 01             	add    $0x1,%eax
  8001c9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001cb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d0:	75 19                	jne    8001eb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d9:	00 
  8001da:	8d 43 08             	lea    0x8(%ebx),%eax
  8001dd:	89 04 24             	mov    %eax,(%esp)
  8001e0:	e8 17 0d 00 00       	call   800efc <sys_cputs>
		b->idx = 0;
  8001e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001eb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ef:	83 c4 14             	add    $0x14,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    
	...

00800200 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 4c             	sub    $0x4c,%esp
  800209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80020c:	89 d6                	mov    %edx,%esi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80021a:	8b 45 10             	mov    0x10(%ebp),%eax
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800220:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800223:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800226:	b9 00 00 00 00       	mov    $0x0,%ecx
  80022b:	39 d1                	cmp    %edx,%ecx
  80022d:	72 07                	jb     800236 <printnum_v2+0x36>
  80022f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800232:	39 d0                	cmp    %edx,%eax
  800234:	77 5f                	ja     800295 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800236:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80023a:	83 eb 01             	sub    $0x1,%ebx
  80023d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800241:	89 44 24 08          	mov    %eax,0x8(%esp)
  800245:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800249:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80024d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800250:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800253:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800256:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80025a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800261:	00 
  800262:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80026b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026f:	e8 7c 1c 00 00       	call   801ef0 <__udivdi3>
  800274:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800277:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80027a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80027e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800282:	89 04 24             	mov    %eax,(%esp)
  800285:	89 54 24 04          	mov    %edx,0x4(%esp)
  800289:	89 f2                	mov    %esi,%edx
  80028b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028e:	e8 6d ff ff ff       	call   800200 <printnum_v2>
  800293:	eb 1e                	jmp    8002b3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800295:	83 ff 2d             	cmp    $0x2d,%edi
  800298:	74 19                	je     8002b3 <printnum_v2+0xb3>
		while (--width > 0)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	90                   	nop
  8002a0:	7e 11                	jle    8002b3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8002a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a6:	89 3c 24             	mov    %edi,(%esp)
  8002a9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8002ac:	83 eb 01             	sub    $0x1,%ebx
  8002af:	85 db                	test   %ebx,%ebx
  8002b1:	7f ef                	jg     8002a2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c9:	00 
  8002ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002cd:	89 14 24             	mov    %edx,(%esp)
  8002d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002d7:	e8 44 1d 00 00       	call   802020 <__umoddi3>
  8002dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e0:	0f be 80 92 21 80 00 	movsbl 0x802192(%eax),%eax
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ed:	83 c4 4c             	add    $0x4c,%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f8:	83 fa 01             	cmp    $0x1,%edx
  8002fb:	7e 0e                	jle    80030b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 02                	mov    (%edx),%eax
  800306:	8b 52 04             	mov    0x4(%edx),%edx
  800309:	eb 22                	jmp    80032d <getuint+0x38>
	else if (lflag)
  80030b:	85 d2                	test   %edx,%edx
  80030d:	74 10                	je     80031f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
  80031d:	eb 0e                	jmp    80032d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031f:	8b 10                	mov    (%eax),%edx
  800321:	8d 4a 04             	lea    0x4(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 02                	mov    (%edx),%eax
  800328:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800335:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	3b 50 04             	cmp    0x4(%eax),%edx
  80033e:	73 0a                	jae    80034a <sprintputch+0x1b>
		*b->buf++ = ch;
  800340:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800343:	88 0a                	mov    %cl,(%edx)
  800345:	83 c2 01             	add    $0x1,%edx
  800348:	89 10                	mov    %edx,(%eax)
}
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 6c             	sub    $0x6c,%esp
  800355:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800358:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80035f:	eb 1a                	jmp    80037b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800361:	85 c0                	test   %eax,%eax
  800363:	0f 84 66 06 00 00    	je     8009cf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80036c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800370:	89 04 24             	mov    %eax,(%esp)
  800373:	ff 55 08             	call   *0x8(%ebp)
  800376:	eb 03                	jmp    80037b <vprintfmt+0x2f>
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037b:	0f b6 07             	movzbl (%edi),%eax
  80037e:	83 c7 01             	add    $0x1,%edi
  800381:	83 f8 25             	cmp    $0x25,%eax
  800384:	75 db                	jne    800361 <vprintfmt+0x15>
  800386:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80038a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800396:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80039b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a2:	be 00 00 00 00       	mov    $0x0,%esi
  8003a7:	eb 06                	jmp    8003af <vprintfmt+0x63>
  8003a9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8003ad:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	0f b6 17             	movzbl (%edi),%edx
  8003b2:	0f b6 c2             	movzbl %dl,%eax
  8003b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b8:	8d 47 01             	lea    0x1(%edi),%eax
  8003bb:	83 ea 23             	sub    $0x23,%edx
  8003be:	80 fa 55             	cmp    $0x55,%dl
  8003c1:	0f 87 60 05 00 00    	ja     800927 <vprintfmt+0x5db>
  8003c7:	0f b6 d2             	movzbl %dl,%edx
  8003ca:	ff 24 95 80 23 80 00 	jmp    *0x802380(,%edx,4)
  8003d1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8003d6:	eb d5                	jmp    8003ad <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003db:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8003de:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003e1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003e4:	83 ff 09             	cmp    $0x9,%edi
  8003e7:	76 08                	jbe    8003f1 <vprintfmt+0xa5>
  8003e9:	eb 40                	jmp    80042b <vprintfmt+0xdf>
  8003eb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8003ef:	eb bc                	jmp    8003ad <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003f4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8003f7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8003fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003fe:	8d 7a d0             	lea    -0x30(%edx),%edi
  800401:	83 ff 09             	cmp    $0x9,%edi
  800404:	76 eb                	jbe    8003f1 <vprintfmt+0xa5>
  800406:	eb 23                	jmp    80042b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800408:	8b 55 14             	mov    0x14(%ebp),%edx
  80040b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80040e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800411:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800413:	eb 16                	jmp    80042b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800415:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800418:	c1 fa 1f             	sar    $0x1f,%edx
  80041b:	f7 d2                	not    %edx
  80041d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800420:	eb 8b                	jmp    8003ad <vprintfmt+0x61>
  800422:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800429:	eb 82                	jmp    8003ad <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80042b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80042f:	0f 89 78 ff ff ff    	jns    8003ad <vprintfmt+0x61>
  800435:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800438:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80043b:	e9 6d ff ff ff       	jmp    8003ad <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800440:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800443:	e9 65 ff ff ff       	jmp    8003ad <vprintfmt+0x61>
  800448:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 50 04             	lea    0x4(%eax),%edx
  800451:	89 55 14             	mov    %edx,0x14(%ebp)
  800454:	8b 55 0c             	mov    0xc(%ebp),%edx
  800457:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	89 04 24             	mov    %eax,(%esp)
  800460:	ff 55 08             	call   *0x8(%ebp)
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800466:	e9 10 ff ff ff       	jmp    80037b <vprintfmt+0x2f>
  80046b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	89 c2                	mov    %eax,%edx
  80047b:	c1 fa 1f             	sar    $0x1f,%edx
  80047e:	31 d0                	xor    %edx,%eax
  800480:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800482:	83 f8 0f             	cmp    $0xf,%eax
  800485:	7f 0b                	jg     800492 <vprintfmt+0x146>
  800487:	8b 14 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%edx
  80048e:	85 d2                	test   %edx,%edx
  800490:	75 26                	jne    8004b8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800492:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800496:	c7 44 24 08 a3 21 80 	movl   $0x8021a3,0x8(%esp)
  80049d:	00 
  80049e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004a8:	89 1c 24             	mov    %ebx,(%esp)
  8004ab:	e8 a7 05 00 00       	call   800a57 <printfmt>
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b3:	e9 c3 fe ff ff       	jmp    80037b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bc:	c7 44 24 08 ac 21 80 	movl   $0x8021ac,0x8(%esp)
  8004c3:	00 
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ce:	89 14 24             	mov    %edx,(%esp)
  8004d1:	e8 81 05 00 00       	call   800a57 <printfmt>
  8004d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d9:	e9 9d fe ff ff       	jmp    80037b <vprintfmt+0x2f>
  8004de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e1:	89 c7                	mov    %eax,%edi
  8004e3:	89 d9                	mov    %ebx,%ecx
  8004e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004e8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 50 04             	lea    0x4(%eax),%edx
  8004f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f4:	8b 30                	mov    (%eax),%esi
  8004f6:	85 f6                	test   %esi,%esi
  8004f8:	75 05                	jne    8004ff <vprintfmt+0x1b3>
  8004fa:	be af 21 80 00       	mov    $0x8021af,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8004ff:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800503:	7e 06                	jle    80050b <vprintfmt+0x1bf>
  800505:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800509:	75 10                	jne    80051b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	0f be 06             	movsbl (%esi),%eax
  80050e:	85 c0                	test   %eax,%eax
  800510:	0f 85 a2 00 00 00    	jne    8005b8 <vprintfmt+0x26c>
  800516:	e9 92 00 00 00       	jmp    8005ad <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80051f:	89 34 24             	mov    %esi,(%esp)
  800522:	e8 74 05 00 00       	call   800a9b <strnlen>
  800527:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80052a:	29 c2                	sub    %eax,%edx
  80052c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80052f:	85 d2                	test   %edx,%edx
  800531:	7e d8                	jle    80050b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800533:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800537:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80053a:	89 d3                	mov    %edx,%ebx
  80053c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80053f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800542:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800545:	89 ce                	mov    %ecx,%esi
  800547:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054b:	89 34 24             	mov    %esi,(%esp)
  80054e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800551:	83 eb 01             	sub    $0x1,%ebx
  800554:	85 db                	test   %ebx,%ebx
  800556:	7f ef                	jg     800547 <vprintfmt+0x1fb>
  800558:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80055b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80055e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800561:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800568:	eb a1                	jmp    80050b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80056a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80056e:	74 1b                	je     80058b <vprintfmt+0x23f>
  800570:	8d 50 e0             	lea    -0x20(%eax),%edx
  800573:	83 fa 5e             	cmp    $0x5e,%edx
  800576:	76 13                	jbe    80058b <vprintfmt+0x23f>
					putch('?', putdat);
  800578:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800586:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	eb 0d                	jmp    800598 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80058b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80058e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800598:	83 ef 01             	sub    $0x1,%edi
  80059b:	0f be 06             	movsbl (%esi),%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 05                	je     8005a7 <vprintfmt+0x25b>
  8005a2:	83 c6 01             	add    $0x1,%esi
  8005a5:	eb 1a                	jmp    8005c1 <vprintfmt+0x275>
  8005a7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005aa:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b1:	7f 1f                	jg     8005d2 <vprintfmt+0x286>
  8005b3:	e9 c0 fd ff ff       	jmp    800378 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b8:	83 c6 01             	add    $0x1,%esi
  8005bb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005be:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005c1:	85 db                	test   %ebx,%ebx
  8005c3:	78 a5                	js     80056a <vprintfmt+0x21e>
  8005c5:	83 eb 01             	sub    $0x1,%ebx
  8005c8:	79 a0                	jns    80056a <vprintfmt+0x21e>
  8005ca:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005cd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005d0:	eb db                	jmp    8005ad <vprintfmt+0x261>
  8005d2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005db:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005eb:	83 eb 01             	sub    $0x1,%ebx
  8005ee:	85 db                	test   %ebx,%ebx
  8005f0:	7f ec                	jg     8005de <vprintfmt+0x292>
  8005f2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005f5:	e9 81 fd ff ff       	jmp    80037b <vprintfmt+0x2f>
  8005fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fd:	83 fe 01             	cmp    $0x1,%esi
  800600:	7e 10                	jle    800612 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 08             	lea    0x8(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	8b 18                	mov    (%eax),%ebx
  80060d:	8b 70 04             	mov    0x4(%eax),%esi
  800610:	eb 26                	jmp    800638 <vprintfmt+0x2ec>
	else if (lflag)
  800612:	85 f6                	test   %esi,%esi
  800614:	74 12                	je     800628 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	8b 18                	mov    (%eax),%ebx
  800621:	89 de                	mov    %ebx,%esi
  800623:	c1 fe 1f             	sar    $0x1f,%esi
  800626:	eb 10                	jmp    800638 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 18                	mov    (%eax),%ebx
  800633:	89 de                	mov    %ebx,%esi
  800635:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800638:	83 f9 01             	cmp    $0x1,%ecx
  80063b:	75 1e                	jne    80065b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80063d:	85 f6                	test   %esi,%esi
  80063f:	78 1a                	js     80065b <vprintfmt+0x30f>
  800641:	85 f6                	test   %esi,%esi
  800643:	7f 05                	jg     80064a <vprintfmt+0x2fe>
  800645:	83 fb 00             	cmp    $0x0,%ebx
  800648:	76 11                	jbe    80065b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80064a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80064d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800651:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800658:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80065b:	85 f6                	test   %esi,%esi
  80065d:	78 13                	js     800672 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800662:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800665:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800668:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066d:	e9 da 00 00 00       	jmp    80074c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800672:	8b 45 0c             	mov    0xc(%ebp),%eax
  800675:	89 44 24 04          	mov    %eax,0x4(%esp)
  800679:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800680:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800683:	89 da                	mov    %ebx,%edx
  800685:	89 f1                	mov    %esi,%ecx
  800687:	f7 da                	neg    %edx
  800689:	83 d1 00             	adc    $0x0,%ecx
  80068c:	f7 d9                	neg    %ecx
  80068e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800691:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800697:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069c:	e9 ab 00 00 00       	jmp    80074c <vprintfmt+0x400>
  8006a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a4:	89 f2                	mov    %esi,%edx
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 47 fc ff ff       	call   8002f5 <getuint>
  8006ae:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006b1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006bc:	e9 8b 00 00 00       	jmp    80074c <vprintfmt+0x400>
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006cb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8006d5:	89 f2                	mov    %esi,%edx
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 16 fc ff ff       	call   8002f5 <getuint>
  8006df:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006e2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8006ed:	eb 5d                	jmp    80074c <vprintfmt+0x400>
  8006ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800700:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800703:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800707:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8d 50 04             	lea    0x4(%eax),%edx
  800717:	89 55 14             	mov    %edx,0x14(%ebp)
  80071a:	8b 10                	mov    (%eax),%edx
  80071c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800721:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800724:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80072f:	eb 1b                	jmp    80074c <vprintfmt+0x400>
  800731:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800734:	89 f2                	mov    %esi,%edx
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
  800739:	e8 b7 fb ff ff       	call   8002f5 <getuint>
  80073e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800741:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800750:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800753:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800756:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80075a:	77 09                	ja     800765 <vprintfmt+0x419>
  80075c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80075f:	0f 82 ac 00 00 00    	jb     800811 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800765:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800768:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80076c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80076f:	83 ea 01             	sub    $0x1,%edx
  800772:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800776:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80077e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800782:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800785:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800788:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80078b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80078f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800796:	00 
  800797:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80079a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80079d:	89 0c 24             	mov    %ecx,(%esp)
  8007a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a4:	e8 47 17 00 00       	call   801ef0 <__udivdi3>
  8007a9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8007ac:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8007af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	e8 37 fa ff ff       	call   800200 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007d4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007e2:	00 
  8007e3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8007e6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8007e9:	89 14 24             	mov    %edx,(%esp)
  8007ec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f0:	e8 2b 18 00 00       	call   802020 <__umoddi3>
  8007f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f9:	0f be 80 92 21 80 00 	movsbl 0x802192(%eax),%eax
  800800:	89 04 24             	mov    %eax,(%esp)
  800803:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800806:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80080a:	74 54                	je     800860 <vprintfmt+0x514>
  80080c:	e9 67 fb ff ff       	jmp    800378 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800811:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800815:	8d 76 00             	lea    0x0(%esi),%esi
  800818:	0f 84 2a 01 00 00    	je     800948 <vprintfmt+0x5fc>
		while (--width > 0)
  80081e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800821:	83 ef 01             	sub    $0x1,%edi
  800824:	85 ff                	test   %edi,%edi
  800826:	0f 8e 5e 01 00 00    	jle    80098a <vprintfmt+0x63e>
  80082c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80082f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800832:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800835:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800838:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80083b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80083e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800842:	89 1c 24             	mov    %ebx,(%esp)
  800845:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800848:	83 ef 01             	sub    $0x1,%edi
  80084b:	85 ff                	test   %edi,%edi
  80084d:	7f ef                	jg     80083e <vprintfmt+0x4f2>
  80084f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800852:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800855:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800858:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80085b:	e9 2a 01 00 00       	jmp    80098a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800860:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800863:	83 eb 01             	sub    $0x1,%ebx
  800866:	85 db                	test   %ebx,%ebx
  800868:	0f 8e 0a fb ff ff    	jle    800378 <vprintfmt+0x2c>
  80086e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800871:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800874:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800877:	89 74 24 04          	mov    %esi,0x4(%esp)
  80087b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800882:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800884:	83 eb 01             	sub    $0x1,%ebx
  800887:	85 db                	test   %ebx,%ebx
  800889:	7f ec                	jg     800877 <vprintfmt+0x52b>
  80088b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80088e:	e9 e8 fa ff ff       	jmp    80037b <vprintfmt+0x2f>
  800893:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800896:	8b 45 14             	mov    0x14(%ebp),%eax
  800899:	8d 50 04             	lea    0x4(%eax),%edx
  80089c:	89 55 14             	mov    %edx,0x14(%ebp)
  80089f:	8b 00                	mov    (%eax),%eax
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	75 2a                	jne    8008cf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8008a5:	c7 44 24 0c c8 22 80 	movl   $0x8022c8,0xc(%esp)
  8008ac:	00 
  8008ad:	c7 44 24 08 ac 21 80 	movl   $0x8021ac,0x8(%esp)
  8008b4:	00 
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bf:	89 0c 24             	mov    %ecx,(%esp)
  8008c2:	e8 90 01 00 00       	call   800a57 <printfmt>
  8008c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ca:	e9 ac fa ff ff       	jmp    80037b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8008cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008d2:	8b 13                	mov    (%ebx),%edx
  8008d4:	83 fa 7f             	cmp    $0x7f,%edx
  8008d7:	7e 29                	jle    800902 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8008d9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8008db:	c7 44 24 0c 00 23 80 	movl   $0x802300,0xc(%esp)
  8008e2:	00 
  8008e3:	c7 44 24 08 ac 21 80 	movl   $0x8021ac,0x8(%esp)
  8008ea:	00 
  8008eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	e8 5d 01 00 00       	call   800a57 <printfmt>
  8008fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008fd:	e9 79 fa ff ff       	jmp    80037b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800902:	88 10                	mov    %dl,(%eax)
  800904:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800907:	e9 6f fa ff ff       	jmp    80037b <vprintfmt+0x2f>
  80090c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80090f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800912:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800915:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800919:	89 14 24             	mov    %edx,(%esp)
  80091c:	ff 55 08             	call   *0x8(%ebp)
  80091f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800922:	e9 54 fa ff ff       	jmp    80037b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800927:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80092a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800935:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800938:	8d 47 ff             	lea    -0x1(%edi),%eax
  80093b:	80 38 25             	cmpb   $0x25,(%eax)
  80093e:	0f 84 37 fa ff ff    	je     80037b <vprintfmt+0x2f>
  800944:	89 c7                	mov    %eax,%edi
  800946:	eb f0                	jmp    800938 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800953:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800956:	89 54 24 08          	mov    %edx,0x8(%esp)
  80095a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800961:	00 
  800962:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800965:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80096f:	e8 ac 16 00 00       	call   802020 <__umoddi3>
  800974:	89 74 24 04          	mov    %esi,0x4(%esp)
  800978:	0f be 80 92 21 80 00 	movsbl 0x802192(%eax),%eax
  80097f:	89 04 24             	mov    %eax,(%esp)
  800982:	ff 55 08             	call   *0x8(%ebp)
  800985:	e9 d6 fe ff ff       	jmp    800860 <vprintfmt+0x514>
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800991:	8b 74 24 04          	mov    0x4(%esp),%esi
  800995:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800998:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80099c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009a3:	00 
  8009a4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009a7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009aa:	89 04 24             	mov    %eax,(%esp)
  8009ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b1:	e8 6a 16 00 00       	call   802020 <__umoddi3>
  8009b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ba:	0f be 80 92 21 80 00 	movsbl 0x802192(%eax),%eax
  8009c1:	89 04 24             	mov    %eax,(%esp)
  8009c4:	ff 55 08             	call   *0x8(%ebp)
  8009c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ca:	e9 ac f9 ff ff       	jmp    80037b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009cf:	83 c4 6c             	add    $0x6c,%esp
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	83 ec 28             	sub    $0x28,%esp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8009e3:	85 c0                	test   %eax,%eax
  8009e5:	74 04                	je     8009eb <vsnprintf+0x14>
  8009e7:	85 d2                	test   %edx,%edx
  8009e9:	7f 07                	jg     8009f2 <vsnprintf+0x1b>
  8009eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f0:	eb 3b                	jmp    800a2d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009f5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8009f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a03:	8b 45 14             	mov    0x14(%ebp),%eax
  800a06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a11:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a18:	c7 04 24 2f 03 80 00 	movl   $0x80032f,(%esp)
  800a1f:	e8 28 f9 ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a35:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a38:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	89 04 24             	mov    %eax,(%esp)
  800a50:	e8 82 ff ff ff       	call   8009d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a5d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a64:	8b 45 10             	mov    0x10(%ebp),%eax
  800a67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	e8 cf f8 ff ff       	call   80034c <vprintfmt>
	va_end(ap);
}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    
	...

00800a80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a8e:	74 09                	je     800a99 <strlen+0x19>
		n++;
  800a90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a97:	75 f7                	jne    800a90 <strlen+0x10>
		n++;
	return n;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa5:	85 c9                	test   %ecx,%ecx
  800aa7:	74 19                	je     800ac2 <strnlen+0x27>
  800aa9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aac:	74 14                	je     800ac2 <strnlen+0x27>
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ab3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab6:	39 c8                	cmp    %ecx,%eax
  800ab8:	74 0d                	je     800ac7 <strnlen+0x2c>
  800aba:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800abe:	75 f3                	jne    800ab3 <strnlen+0x18>
  800ac0:	eb 05                	jmp    800ac7 <strnlen+0x2c>
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	53                   	push   %ebx
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ad9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800add:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ae0:	83 c2 01             	add    $0x1,%edx
  800ae3:	84 c9                	test   %cl,%cl
  800ae5:	75 f2                	jne    800ad9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	53                   	push   %ebx
  800aee:	83 ec 08             	sub    $0x8,%esp
  800af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800af4:	89 1c 24             	mov    %ebx,(%esp)
  800af7:	e8 84 ff ff ff       	call   800a80 <strlen>
	strcpy(dst + len, src);
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aff:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b03:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b06:	89 04 24             	mov    %eax,(%esp)
  800b09:	e8 bc ff ff ff       	call   800aca <strcpy>
	return dst;
}
  800b0e:	89 d8                	mov    %ebx,%eax
  800b10:	83 c4 08             	add    $0x8,%esp
  800b13:	5b                   	pop    %ebx
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b21:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b24:	85 f6                	test   %esi,%esi
  800b26:	74 18                	je     800b40 <strncpy+0x2a>
  800b28:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b2d:	0f b6 1a             	movzbl (%edx),%ebx
  800b30:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b33:	80 3a 01             	cmpb   $0x1,(%edx)
  800b36:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b39:	83 c1 01             	add    $0x1,%ecx
  800b3c:	39 ce                	cmp    %ecx,%esi
  800b3e:	77 ed                	ja     800b2d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 75 08             	mov    0x8(%ebp),%esi
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b52:	89 f0                	mov    %esi,%eax
  800b54:	85 c9                	test   %ecx,%ecx
  800b56:	74 27                	je     800b7f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b58:	83 e9 01             	sub    $0x1,%ecx
  800b5b:	74 1d                	je     800b7a <strlcpy+0x36>
  800b5d:	0f b6 1a             	movzbl (%edx),%ebx
  800b60:	84 db                	test   %bl,%bl
  800b62:	74 16                	je     800b7a <strlcpy+0x36>
			*dst++ = *src++;
  800b64:	88 18                	mov    %bl,(%eax)
  800b66:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b69:	83 e9 01             	sub    $0x1,%ecx
  800b6c:	74 0e                	je     800b7c <strlcpy+0x38>
			*dst++ = *src++;
  800b6e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b71:	0f b6 1a             	movzbl (%edx),%ebx
  800b74:	84 db                	test   %bl,%bl
  800b76:	75 ec                	jne    800b64 <strlcpy+0x20>
  800b78:	eb 02                	jmp    800b7c <strlcpy+0x38>
  800b7a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b7c:	c6 00 00             	movb   $0x0,(%eax)
  800b7f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b8e:	0f b6 01             	movzbl (%ecx),%eax
  800b91:	84 c0                	test   %al,%al
  800b93:	74 15                	je     800baa <strcmp+0x25>
  800b95:	3a 02                	cmp    (%edx),%al
  800b97:	75 11                	jne    800baa <strcmp+0x25>
		p++, q++;
  800b99:	83 c1 01             	add    $0x1,%ecx
  800b9c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b9f:	0f b6 01             	movzbl (%ecx),%eax
  800ba2:	84 c0                	test   %al,%al
  800ba4:	74 04                	je     800baa <strcmp+0x25>
  800ba6:	3a 02                	cmp    (%edx),%al
  800ba8:	74 ef                	je     800b99 <strcmp+0x14>
  800baa:	0f b6 c0             	movzbl %al,%eax
  800bad:	0f b6 12             	movzbl (%edx),%edx
  800bb0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	53                   	push   %ebx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	74 23                	je     800be8 <strncmp+0x34>
  800bc5:	0f b6 1a             	movzbl (%edx),%ebx
  800bc8:	84 db                	test   %bl,%bl
  800bca:	74 25                	je     800bf1 <strncmp+0x3d>
  800bcc:	3a 19                	cmp    (%ecx),%bl
  800bce:	75 21                	jne    800bf1 <strncmp+0x3d>
  800bd0:	83 e8 01             	sub    $0x1,%eax
  800bd3:	74 13                	je     800be8 <strncmp+0x34>
		n--, p++, q++;
  800bd5:	83 c2 01             	add    $0x1,%edx
  800bd8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bdb:	0f b6 1a             	movzbl (%edx),%ebx
  800bde:	84 db                	test   %bl,%bl
  800be0:	74 0f                	je     800bf1 <strncmp+0x3d>
  800be2:	3a 19                	cmp    (%ecx),%bl
  800be4:	74 ea                	je     800bd0 <strncmp+0x1c>
  800be6:	eb 09                	jmp    800bf1 <strncmp+0x3d>
  800be8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5d                   	pop    %ebp
  800bef:	90                   	nop
  800bf0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf1:	0f b6 02             	movzbl (%edx),%eax
  800bf4:	0f b6 11             	movzbl (%ecx),%edx
  800bf7:	29 d0                	sub    %edx,%eax
  800bf9:	eb f2                	jmp    800bed <strncmp+0x39>

00800bfb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c05:	0f b6 10             	movzbl (%eax),%edx
  800c08:	84 d2                	test   %dl,%dl
  800c0a:	74 18                	je     800c24 <strchr+0x29>
		if (*s == c)
  800c0c:	38 ca                	cmp    %cl,%dl
  800c0e:	75 0a                	jne    800c1a <strchr+0x1f>
  800c10:	eb 17                	jmp    800c29 <strchr+0x2e>
  800c12:	38 ca                	cmp    %cl,%dl
  800c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c18:	74 0f                	je     800c29 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	0f b6 10             	movzbl (%eax),%edx
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 ee                	jne    800c12 <strchr+0x17>
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c35:	0f b6 10             	movzbl (%eax),%edx
  800c38:	84 d2                	test   %dl,%dl
  800c3a:	74 18                	je     800c54 <strfind+0x29>
		if (*s == c)
  800c3c:	38 ca                	cmp    %cl,%dl
  800c3e:	75 0a                	jne    800c4a <strfind+0x1f>
  800c40:	eb 12                	jmp    800c54 <strfind+0x29>
  800c42:	38 ca                	cmp    %cl,%dl
  800c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c48:	74 0a                	je     800c54 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	0f b6 10             	movzbl (%eax),%edx
  800c50:	84 d2                	test   %dl,%dl
  800c52:	75 ee                	jne    800c42 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 0c             	sub    $0xc,%esp
  800c5c:	89 1c 24             	mov    %ebx,(%esp)
  800c5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c63:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c67:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c70:	85 c9                	test   %ecx,%ecx
  800c72:	74 30                	je     800ca4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7a:	75 25                	jne    800ca1 <memset+0x4b>
  800c7c:	f6 c1 03             	test   $0x3,%cl
  800c7f:	75 20                	jne    800ca1 <memset+0x4b>
		c &= 0xFF;
  800c81:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c84:	89 d3                	mov    %edx,%ebx
  800c86:	c1 e3 08             	shl    $0x8,%ebx
  800c89:	89 d6                	mov    %edx,%esi
  800c8b:	c1 e6 18             	shl    $0x18,%esi
  800c8e:	89 d0                	mov    %edx,%eax
  800c90:	c1 e0 10             	shl    $0x10,%eax
  800c93:	09 f0                	or     %esi,%eax
  800c95:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c97:	09 d8                	or     %ebx,%eax
  800c99:	c1 e9 02             	shr    $0x2,%ecx
  800c9c:	fc                   	cld    
  800c9d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c9f:	eb 03                	jmp    800ca4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ca1:	fc                   	cld    
  800ca2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ca4:	89 f8                	mov    %edi,%eax
  800ca6:	8b 1c 24             	mov    (%esp),%ebx
  800ca9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cad:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cb1:	89 ec                	mov    %ebp,%esp
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 08             	sub    $0x8,%esp
  800cbb:	89 34 24             	mov    %esi,(%esp)
  800cbe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cc8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ccb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ccd:	39 c6                	cmp    %eax,%esi
  800ccf:	73 35                	jae    800d06 <memmove+0x51>
  800cd1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cd4:	39 d0                	cmp    %edx,%eax
  800cd6:	73 2e                	jae    800d06 <memmove+0x51>
		s += n;
		d += n;
  800cd8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cda:	f6 c2 03             	test   $0x3,%dl
  800cdd:	75 1b                	jne    800cfa <memmove+0x45>
  800cdf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ce5:	75 13                	jne    800cfa <memmove+0x45>
  800ce7:	f6 c1 03             	test   $0x3,%cl
  800cea:	75 0e                	jne    800cfa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800cec:	83 ef 04             	sub    $0x4,%edi
  800cef:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cf2:	c1 e9 02             	shr    $0x2,%ecx
  800cf5:	fd                   	std    
  800cf6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf8:	eb 09                	jmp    800d03 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cfa:	83 ef 01             	sub    $0x1,%edi
  800cfd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d00:	fd                   	std    
  800d01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d03:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d04:	eb 20                	jmp    800d26 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d0c:	75 15                	jne    800d23 <memmove+0x6e>
  800d0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d14:	75 0d                	jne    800d23 <memmove+0x6e>
  800d16:	f6 c1 03             	test   $0x3,%cl
  800d19:	75 08                	jne    800d23 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d1b:	c1 e9 02             	shr    $0x2,%ecx
  800d1e:	fc                   	cld    
  800d1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d21:	eb 03                	jmp    800d26 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d23:	fc                   	cld    
  800d24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d26:	8b 34 24             	mov    (%esp),%esi
  800d29:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d2d:	89 ec                	mov    %ebp,%esp
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d37:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	89 04 24             	mov    %eax,(%esp)
  800d4b:	e8 65 ff ff ff       	call   800cb5 <memmove>
}
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d61:	85 c9                	test   %ecx,%ecx
  800d63:	74 36                	je     800d9b <memcmp+0x49>
		if (*s1 != *s2)
  800d65:	0f b6 06             	movzbl (%esi),%eax
  800d68:	0f b6 1f             	movzbl (%edi),%ebx
  800d6b:	38 d8                	cmp    %bl,%al
  800d6d:	74 20                	je     800d8f <memcmp+0x3d>
  800d6f:	eb 14                	jmp    800d85 <memcmp+0x33>
  800d71:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d76:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d7b:	83 c2 01             	add    $0x1,%edx
  800d7e:	83 e9 01             	sub    $0x1,%ecx
  800d81:	38 d8                	cmp    %bl,%al
  800d83:	74 12                	je     800d97 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d85:	0f b6 c0             	movzbl %al,%eax
  800d88:	0f b6 db             	movzbl %bl,%ebx
  800d8b:	29 d8                	sub    %ebx,%eax
  800d8d:	eb 11                	jmp    800da0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d8f:	83 e9 01             	sub    $0x1,%ecx
  800d92:	ba 00 00 00 00       	mov    $0x0,%edx
  800d97:	85 c9                	test   %ecx,%ecx
  800d99:	75 d6                	jne    800d71 <memcmp+0x1f>
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dab:	89 c2                	mov    %eax,%edx
  800dad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800db0:	39 d0                	cmp    %edx,%eax
  800db2:	73 15                	jae    800dc9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800db4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800db8:	38 08                	cmp    %cl,(%eax)
  800dba:	75 06                	jne    800dc2 <memfind+0x1d>
  800dbc:	eb 0b                	jmp    800dc9 <memfind+0x24>
  800dbe:	38 08                	cmp    %cl,(%eax)
  800dc0:	74 07                	je     800dc9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dc2:	83 c0 01             	add    $0x1,%eax
  800dc5:	39 c2                	cmp    %eax,%edx
  800dc7:	77 f5                	ja     800dbe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dda:	0f b6 02             	movzbl (%edx),%eax
  800ddd:	3c 20                	cmp    $0x20,%al
  800ddf:	74 04                	je     800de5 <strtol+0x1a>
  800de1:	3c 09                	cmp    $0x9,%al
  800de3:	75 0e                	jne    800df3 <strtol+0x28>
		s++;
  800de5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800de8:	0f b6 02             	movzbl (%edx),%eax
  800deb:	3c 20                	cmp    $0x20,%al
  800ded:	74 f6                	je     800de5 <strtol+0x1a>
  800def:	3c 09                	cmp    $0x9,%al
  800df1:	74 f2                	je     800de5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800df3:	3c 2b                	cmp    $0x2b,%al
  800df5:	75 0c                	jne    800e03 <strtol+0x38>
		s++;
  800df7:	83 c2 01             	add    $0x1,%edx
  800dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e01:	eb 15                	jmp    800e18 <strtol+0x4d>
	else if (*s == '-')
  800e03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e0a:	3c 2d                	cmp    $0x2d,%al
  800e0c:	75 0a                	jne    800e18 <strtol+0x4d>
		s++, neg = 1;
  800e0e:	83 c2 01             	add    $0x1,%edx
  800e11:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e18:	85 db                	test   %ebx,%ebx
  800e1a:	0f 94 c0             	sete   %al
  800e1d:	74 05                	je     800e24 <strtol+0x59>
  800e1f:	83 fb 10             	cmp    $0x10,%ebx
  800e22:	75 18                	jne    800e3c <strtol+0x71>
  800e24:	80 3a 30             	cmpb   $0x30,(%edx)
  800e27:	75 13                	jne    800e3c <strtol+0x71>
  800e29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
  800e30:	75 0a                	jne    800e3c <strtol+0x71>
		s += 2, base = 16;
  800e32:	83 c2 02             	add    $0x2,%edx
  800e35:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e3a:	eb 15                	jmp    800e51 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e3c:	84 c0                	test   %al,%al
  800e3e:	66 90                	xchg   %ax,%ax
  800e40:	74 0f                	je     800e51 <strtol+0x86>
  800e42:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e47:	80 3a 30             	cmpb   $0x30,(%edx)
  800e4a:	75 05                	jne    800e51 <strtol+0x86>
		s++, base = 8;
  800e4c:	83 c2 01             	add    $0x1,%edx
  800e4f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e58:	0f b6 0a             	movzbl (%edx),%ecx
  800e5b:	89 cf                	mov    %ecx,%edi
  800e5d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e60:	80 fb 09             	cmp    $0x9,%bl
  800e63:	77 08                	ja     800e6d <strtol+0xa2>
			dig = *s - '0';
  800e65:	0f be c9             	movsbl %cl,%ecx
  800e68:	83 e9 30             	sub    $0x30,%ecx
  800e6b:	eb 1e                	jmp    800e8b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e6d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e70:	80 fb 19             	cmp    $0x19,%bl
  800e73:	77 08                	ja     800e7d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e75:	0f be c9             	movsbl %cl,%ecx
  800e78:	83 e9 57             	sub    $0x57,%ecx
  800e7b:	eb 0e                	jmp    800e8b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e7d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e80:	80 fb 19             	cmp    $0x19,%bl
  800e83:	77 15                	ja     800e9a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e85:	0f be c9             	movsbl %cl,%ecx
  800e88:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e8b:	39 f1                	cmp    %esi,%ecx
  800e8d:	7d 0b                	jge    800e9a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e8f:	83 c2 01             	add    $0x1,%edx
  800e92:	0f af c6             	imul   %esi,%eax
  800e95:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e98:	eb be                	jmp    800e58 <strtol+0x8d>
  800e9a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ea0:	74 05                	je     800ea7 <strtol+0xdc>
		*endptr = (char *) s;
  800ea2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ea7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800eab:	74 04                	je     800eb1 <strtol+0xe6>
  800ead:	89 c8                	mov    %ecx,%eax
  800eaf:	f7 d8                	neg    %eax
}
  800eb1:	83 c4 04             	add    $0x4,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	00 00                	add    %al,(%eax)
	...

00800ebc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	89 1c 24             	mov    %ebx,(%esp)
  800ec5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ec9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ece:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed3:	89 d1                	mov    %edx,%ecx
  800ed5:	89 d3                	mov    %edx,%ebx
  800ed7:	89 d7                	mov    %edx,%edi
  800ed9:	51                   	push   %ecx
  800eda:	52                   	push   %edx
  800edb:	53                   	push   %ebx
  800edc:	54                   	push   %esp
  800edd:	55                   	push   %ebp
  800ede:	56                   	push   %esi
  800edf:	57                   	push   %edi
  800ee0:	54                   	push   %esp
  800ee1:	5d                   	pop    %ebp
  800ee2:	8d 35 ea 0e 80 00    	lea    0x800eea,%esi
  800ee8:	0f 34                	sysenter 
  800eea:	5f                   	pop    %edi
  800eeb:	5e                   	pop    %esi
  800eec:	5d                   	pop    %ebp
  800eed:	5c                   	pop    %esp
  800eee:	5b                   	pop    %ebx
  800eef:	5a                   	pop    %edx
  800ef0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ef1:	8b 1c 24             	mov    (%esp),%ebx
  800ef4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ef8:	89 ec                	mov    %ebp,%esp
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	89 1c 24             	mov    %ebx,(%esp)
  800f05:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 c3                	mov    %eax,%ebx
  800f16:	89 c7                	mov    %eax,%edi
  800f18:	51                   	push   %ecx
  800f19:	52                   	push   %edx
  800f1a:	53                   	push   %ebx
  800f1b:	54                   	push   %esp
  800f1c:	55                   	push   %ebp
  800f1d:	56                   	push   %esi
  800f1e:	57                   	push   %edi
  800f1f:	54                   	push   %esp
  800f20:	5d                   	pop    %ebp
  800f21:	8d 35 29 0f 80 00    	lea    0x800f29,%esi
  800f27:	0f 34                	sysenter 
  800f29:	5f                   	pop    %edi
  800f2a:	5e                   	pop    %esi
  800f2b:	5d                   	pop    %ebp
  800f2c:	5c                   	pop    %esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5a                   	pop    %edx
  800f2f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f30:	8b 1c 24             	mov    (%esp),%ebx
  800f33:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f37:	89 ec                	mov    %ebp,%esp
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	89 1c 24             	mov    %ebx,(%esp)
  800f44:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f48:	b8 10 00 00 00       	mov    $0x10,%eax
  800f4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	51                   	push   %ecx
  800f5a:	52                   	push   %edx
  800f5b:	53                   	push   %ebx
  800f5c:	54                   	push   %esp
  800f5d:	55                   	push   %ebp
  800f5e:	56                   	push   %esi
  800f5f:	57                   	push   %edi
  800f60:	54                   	push   %esp
  800f61:	5d                   	pop    %ebp
  800f62:	8d 35 6a 0f 80 00    	lea    0x800f6a,%esi
  800f68:	0f 34                	sysenter 
  800f6a:	5f                   	pop    %edi
  800f6b:	5e                   	pop    %esi
  800f6c:	5d                   	pop    %ebp
  800f6d:	5c                   	pop    %esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5a                   	pop    %edx
  800f70:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800f71:	8b 1c 24             	mov    (%esp),%ebx
  800f74:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f78:	89 ec                	mov    %ebp,%esp
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 28             	sub    $0x28,%esp
  800f82:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f85:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f95:	8b 55 08             	mov    0x8(%ebp),%edx
  800f98:	89 df                	mov    %ebx,%edi
  800f9a:	51                   	push   %ecx
  800f9b:	52                   	push   %edx
  800f9c:	53                   	push   %ebx
  800f9d:	54                   	push   %esp
  800f9e:	55                   	push   %ebp
  800f9f:	56                   	push   %esi
  800fa0:	57                   	push   %edi
  800fa1:	54                   	push   %esp
  800fa2:	5d                   	pop    %ebp
  800fa3:	8d 35 ab 0f 80 00    	lea    0x800fab,%esi
  800fa9:	0f 34                	sysenter 
  800fab:	5f                   	pop    %edi
  800fac:	5e                   	pop    %esi
  800fad:	5d                   	pop    %ebp
  800fae:	5c                   	pop    %esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5a                   	pop    %edx
  800fb1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	7e 28                	jle    800fde <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fba:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  800fd9:	e8 b6 0e 00 00       	call   801e94 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800fde:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fe1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe4:	89 ec                	mov    %ebp,%esp
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	89 1c 24             	mov    %ebx,(%esp)
  800ff1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffa:	b8 11 00 00 00       	mov    $0x11,%eax
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	89 cb                	mov    %ecx,%ebx
  801004:	89 cf                	mov    %ecx,%edi
  801006:	51                   	push   %ecx
  801007:	52                   	push   %edx
  801008:	53                   	push   %ebx
  801009:	54                   	push   %esp
  80100a:	55                   	push   %ebp
  80100b:	56                   	push   %esi
  80100c:	57                   	push   %edi
  80100d:	54                   	push   %esp
  80100e:	5d                   	pop    %ebp
  80100f:	8d 35 17 10 80 00    	lea    0x801017,%esi
  801015:	0f 34                	sysenter 
  801017:	5f                   	pop    %edi
  801018:	5e                   	pop    %esi
  801019:	5d                   	pop    %ebp
  80101a:	5c                   	pop    %esp
  80101b:	5b                   	pop    %ebx
  80101c:	5a                   	pop    %edx
  80101d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80101e:	8b 1c 24             	mov    (%esp),%ebx
  801021:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801025:	89 ec                	mov    %ebp,%esp
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 28             	sub    $0x28,%esp
  80102f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801032:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801035:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	89 cb                	mov    %ecx,%ebx
  801044:	89 cf                	mov    %ecx,%edi
  801046:	51                   	push   %ecx
  801047:	52                   	push   %edx
  801048:	53                   	push   %ebx
  801049:	54                   	push   %esp
  80104a:	55                   	push   %ebp
  80104b:	56                   	push   %esi
  80104c:	57                   	push   %edi
  80104d:	54                   	push   %esp
  80104e:	5d                   	pop    %ebp
  80104f:	8d 35 57 10 80 00    	lea    0x801057,%esi
  801055:	0f 34                	sysenter 
  801057:	5f                   	pop    %edi
  801058:	5e                   	pop    %esi
  801059:	5d                   	pop    %ebp
  80105a:	5c                   	pop    %esp
  80105b:	5b                   	pop    %ebx
  80105c:	5a                   	pop    %edx
  80105d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80105e:	85 c0                	test   %eax,%eax
  801060:	7e 28                	jle    80108a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801062:	89 44 24 10          	mov    %eax,0x10(%esp)
  801066:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80106d:	00 
  80106e:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  801085:	e8 0a 0e 00 00       	call   801e94 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80108a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80108d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801090:	89 ec                	mov    %ebp,%esp
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	89 1c 24             	mov    %ebx,(%esp)
  80109d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010a6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010af:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b2:	51                   	push   %ecx
  8010b3:	52                   	push   %edx
  8010b4:	53                   	push   %ebx
  8010b5:	54                   	push   %esp
  8010b6:	55                   	push   %ebp
  8010b7:	56                   	push   %esi
  8010b8:	57                   	push   %edi
  8010b9:	54                   	push   %esp
  8010ba:	5d                   	pop    %ebp
  8010bb:	8d 35 c3 10 80 00    	lea    0x8010c3,%esi
  8010c1:	0f 34                	sysenter 
  8010c3:	5f                   	pop    %edi
  8010c4:	5e                   	pop    %esi
  8010c5:	5d                   	pop    %ebp
  8010c6:	5c                   	pop    %esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5a                   	pop    %edx
  8010c9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010ca:	8b 1c 24             	mov    (%esp),%ebx
  8010cd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d1:	89 ec                	mov    %ebp,%esp
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 28             	sub    $0x28,%esp
  8010db:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010de:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f1:	89 df                	mov    %ebx,%edi
  8010f3:	51                   	push   %ecx
  8010f4:	52                   	push   %edx
  8010f5:	53                   	push   %ebx
  8010f6:	54                   	push   %esp
  8010f7:	55                   	push   %ebp
  8010f8:	56                   	push   %esi
  8010f9:	57                   	push   %edi
  8010fa:	54                   	push   %esp
  8010fb:	5d                   	pop    %ebp
  8010fc:	8d 35 04 11 80 00    	lea    0x801104,%esi
  801102:	0f 34                	sysenter 
  801104:	5f                   	pop    %edi
  801105:	5e                   	pop    %esi
  801106:	5d                   	pop    %ebp
  801107:	5c                   	pop    %esp
  801108:	5b                   	pop    %ebx
  801109:	5a                   	pop    %edx
  80110a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	7e 28                	jle    801137 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801113:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80111a:	00 
  80111b:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  801122:	00 
  801123:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80112a:	00 
  80112b:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  801132:	e8 5d 0d 00 00       	call   801e94 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801137:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80113a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113d:	89 ec                	mov    %ebp,%esp
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	83 ec 28             	sub    $0x28,%esp
  801147:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80114a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80114d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801152:	b8 0a 00 00 00       	mov    $0xa,%eax
  801157:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115a:	8b 55 08             	mov    0x8(%ebp),%edx
  80115d:	89 df                	mov    %ebx,%edi
  80115f:	51                   	push   %ecx
  801160:	52                   	push   %edx
  801161:	53                   	push   %ebx
  801162:	54                   	push   %esp
  801163:	55                   	push   %ebp
  801164:	56                   	push   %esi
  801165:	57                   	push   %edi
  801166:	54                   	push   %esp
  801167:	5d                   	pop    %ebp
  801168:	8d 35 70 11 80 00    	lea    0x801170,%esi
  80116e:	0f 34                	sysenter 
  801170:	5f                   	pop    %edi
  801171:	5e                   	pop    %esi
  801172:	5d                   	pop    %ebp
  801173:	5c                   	pop    %esp
  801174:	5b                   	pop    %ebx
  801175:	5a                   	pop    %edx
  801176:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801177:	85 c0                	test   %eax,%eax
  801179:	7e 28                	jle    8011a3 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801186:	00 
  801187:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  80118e:	00 
  80118f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801196:	00 
  801197:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  80119e:	e8 f1 0c 00 00       	call   801e94 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011a3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011a6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011a9:	89 ec                	mov    %ebp,%esp
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	83 ec 28             	sub    $0x28,%esp
  8011b3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011b6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011be:	b8 09 00 00 00       	mov    $0x9,%eax
  8011c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c9:	89 df                	mov    %ebx,%edi
  8011cb:	51                   	push   %ecx
  8011cc:	52                   	push   %edx
  8011cd:	53                   	push   %ebx
  8011ce:	54                   	push   %esp
  8011cf:	55                   	push   %ebp
  8011d0:	56                   	push   %esi
  8011d1:	57                   	push   %edi
  8011d2:	54                   	push   %esp
  8011d3:	5d                   	pop    %ebp
  8011d4:	8d 35 dc 11 80 00    	lea    0x8011dc,%esi
  8011da:	0f 34                	sysenter 
  8011dc:	5f                   	pop    %edi
  8011dd:	5e                   	pop    %esi
  8011de:	5d                   	pop    %ebp
  8011df:	5c                   	pop    %esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5a                   	pop    %edx
  8011e2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	7e 28                	jle    80120f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011eb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801202:	00 
  801203:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  80120a:	e8 85 0c 00 00       	call   801e94 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80120f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801212:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801215:	89 ec                	mov    %ebp,%esp
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 28             	sub    $0x28,%esp
  80121f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801222:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122a:	b8 07 00 00 00       	mov    $0x7,%eax
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	8b 55 08             	mov    0x8(%ebp),%edx
  801235:	89 df                	mov    %ebx,%edi
  801237:	51                   	push   %ecx
  801238:	52                   	push   %edx
  801239:	53                   	push   %ebx
  80123a:	54                   	push   %esp
  80123b:	55                   	push   %ebp
  80123c:	56                   	push   %esi
  80123d:	57                   	push   %edi
  80123e:	54                   	push   %esp
  80123f:	5d                   	pop    %ebp
  801240:	8d 35 48 12 80 00    	lea    0x801248,%esi
  801246:	0f 34                	sysenter 
  801248:	5f                   	pop    %edi
  801249:	5e                   	pop    %esi
  80124a:	5d                   	pop    %ebp
  80124b:	5c                   	pop    %esp
  80124c:	5b                   	pop    %ebx
  80124d:	5a                   	pop    %edx
  80124e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80124f:	85 c0                	test   %eax,%eax
  801251:	7e 28                	jle    80127b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801253:	89 44 24 10          	mov    %eax,0x10(%esp)
  801257:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80125e:	00 
  80125f:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  801266:	00 
  801267:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80126e:	00 
  80126f:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  801276:	e8 19 0c 00 00       	call   801e94 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80127b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80127e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801281:	89 ec                	mov    %ebp,%esp
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	83 ec 28             	sub    $0x28,%esp
  80128b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80128e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801291:	8b 7d 18             	mov    0x18(%ebp),%edi
  801294:	0b 7d 14             	or     0x14(%ebp),%edi
  801297:	b8 06 00 00 00       	mov    $0x6,%eax
  80129c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80129f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a5:	51                   	push   %ecx
  8012a6:	52                   	push   %edx
  8012a7:	53                   	push   %ebx
  8012a8:	54                   	push   %esp
  8012a9:	55                   	push   %ebp
  8012aa:	56                   	push   %esi
  8012ab:	57                   	push   %edi
  8012ac:	54                   	push   %esp
  8012ad:	5d                   	pop    %ebp
  8012ae:	8d 35 b6 12 80 00    	lea    0x8012b6,%esi
  8012b4:	0f 34                	sysenter 
  8012b6:	5f                   	pop    %edi
  8012b7:	5e                   	pop    %esi
  8012b8:	5d                   	pop    %ebp
  8012b9:	5c                   	pop    %esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5a                   	pop    %edx
  8012bc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	7e 28                	jle    8012e9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012cc:	00 
  8012cd:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  8012d4:	00 
  8012d5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012dc:	00 
  8012dd:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  8012e4:	e8 ab 0b 00 00       	call   801e94 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8012e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ef:	89 ec                	mov    %ebp,%esp
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	83 ec 28             	sub    $0x28,%esp
  8012f9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012fc:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801304:	b8 05 00 00 00       	mov    $0x5,%eax
  801309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80130c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130f:	8b 55 08             	mov    0x8(%ebp),%edx
  801312:	51                   	push   %ecx
  801313:	52                   	push   %edx
  801314:	53                   	push   %ebx
  801315:	54                   	push   %esp
  801316:	55                   	push   %ebp
  801317:	56                   	push   %esi
  801318:	57                   	push   %edi
  801319:	54                   	push   %esp
  80131a:	5d                   	pop    %ebp
  80131b:	8d 35 23 13 80 00    	lea    0x801323,%esi
  801321:	0f 34                	sysenter 
  801323:	5f                   	pop    %edi
  801324:	5e                   	pop    %esi
  801325:	5d                   	pop    %ebp
  801326:	5c                   	pop    %esp
  801327:	5b                   	pop    %ebx
  801328:	5a                   	pop    %edx
  801329:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80132a:	85 c0                	test   %eax,%eax
  80132c:	7e 28                	jle    801356 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80132e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801332:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801339:	00 
  80133a:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  801341:	00 
  801342:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801349:	00 
  80134a:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  801351:	e8 3e 0b 00 00       	call   801e94 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801356:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801359:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80135c:	89 ec                	mov    %ebp,%esp
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	89 1c 24             	mov    %ebx,(%esp)
  801369:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80136d:	ba 00 00 00 00       	mov    $0x0,%edx
  801372:	b8 0c 00 00 00       	mov    $0xc,%eax
  801377:	89 d1                	mov    %edx,%ecx
  801379:	89 d3                	mov    %edx,%ebx
  80137b:	89 d7                	mov    %edx,%edi
  80137d:	51                   	push   %ecx
  80137e:	52                   	push   %edx
  80137f:	53                   	push   %ebx
  801380:	54                   	push   %esp
  801381:	55                   	push   %ebp
  801382:	56                   	push   %esi
  801383:	57                   	push   %edi
  801384:	54                   	push   %esp
  801385:	5d                   	pop    %ebp
  801386:	8d 35 8e 13 80 00    	lea    0x80138e,%esi
  80138c:	0f 34                	sysenter 
  80138e:	5f                   	pop    %edi
  80138f:	5e                   	pop    %esi
  801390:	5d                   	pop    %ebp
  801391:	5c                   	pop    %esp
  801392:	5b                   	pop    %ebx
  801393:	5a                   	pop    %edx
  801394:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801395:	8b 1c 24             	mov    (%esp),%ebx
  801398:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80139c:	89 ec                	mov    %ebp,%esp
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	89 1c 24             	mov    %ebx,(%esp)
  8013a9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8013b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bd:	89 df                	mov    %ebx,%edi
  8013bf:	51                   	push   %ecx
  8013c0:	52                   	push   %edx
  8013c1:	53                   	push   %ebx
  8013c2:	54                   	push   %esp
  8013c3:	55                   	push   %ebp
  8013c4:	56                   	push   %esi
  8013c5:	57                   	push   %edi
  8013c6:	54                   	push   %esp
  8013c7:	5d                   	pop    %ebp
  8013c8:	8d 35 d0 13 80 00    	lea    0x8013d0,%esi
  8013ce:	0f 34                	sysenter 
  8013d0:	5f                   	pop    %edi
  8013d1:	5e                   	pop    %esi
  8013d2:	5d                   	pop    %ebp
  8013d3:	5c                   	pop    %esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5a                   	pop    %edx
  8013d6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8013d7:	8b 1c 24             	mov    (%esp),%ebx
  8013da:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013de:	89 ec                	mov    %ebp,%esp
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	89 1c 24             	mov    %ebx,(%esp)
  8013eb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f4:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f9:	89 d1                	mov    %edx,%ecx
  8013fb:	89 d3                	mov    %edx,%ebx
  8013fd:	89 d7                	mov    %edx,%edi
  8013ff:	51                   	push   %ecx
  801400:	52                   	push   %edx
  801401:	53                   	push   %ebx
  801402:	54                   	push   %esp
  801403:	55                   	push   %ebp
  801404:	56                   	push   %esi
  801405:	57                   	push   %edi
  801406:	54                   	push   %esp
  801407:	5d                   	pop    %ebp
  801408:	8d 35 10 14 80 00    	lea    0x801410,%esi
  80140e:	0f 34                	sysenter 
  801410:	5f                   	pop    %edi
  801411:	5e                   	pop    %esi
  801412:	5d                   	pop    %ebp
  801413:	5c                   	pop    %esp
  801414:	5b                   	pop    %ebx
  801415:	5a                   	pop    %edx
  801416:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801417:	8b 1c 24             	mov    (%esp),%ebx
  80141a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80141e:	89 ec                	mov    %ebp,%esp
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	83 ec 28             	sub    $0x28,%esp
  801428:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80142b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80142e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801433:	b8 03 00 00 00       	mov    $0x3,%eax
  801438:	8b 55 08             	mov    0x8(%ebp),%edx
  80143b:	89 cb                	mov    %ecx,%ebx
  80143d:	89 cf                	mov    %ecx,%edi
  80143f:	51                   	push   %ecx
  801440:	52                   	push   %edx
  801441:	53                   	push   %ebx
  801442:	54                   	push   %esp
  801443:	55                   	push   %ebp
  801444:	56                   	push   %esi
  801445:	57                   	push   %edi
  801446:	54                   	push   %esp
  801447:	5d                   	pop    %ebp
  801448:	8d 35 50 14 80 00    	lea    0x801450,%esi
  80144e:	0f 34                	sysenter 
  801450:	5f                   	pop    %edi
  801451:	5e                   	pop    %esi
  801452:	5d                   	pop    %ebp
  801453:	5c                   	pop    %esp
  801454:	5b                   	pop    %ebx
  801455:	5a                   	pop    %edx
  801456:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801457:	85 c0                	test   %eax,%eax
  801459:	7e 28                	jle    801483 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80145b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80145f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801466:	00 
  801467:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  80146e:	00 
  80146f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801476:	00 
  801477:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  80147e:	e8 11 0a 00 00       	call   801e94 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801483:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801486:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801489:	89 ec                	mov    %ebp,%esp
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    
  80148d:	00 00                	add    %al,(%eax)
	...

00801490 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801496:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80149c:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a1:	39 ca                	cmp    %ecx,%edx
  8014a3:	75 04                	jne    8014a9 <ipc_find_env+0x19>
  8014a5:	b0 00                	mov    $0x0,%al
  8014a7:	eb 12                	jmp    8014bb <ipc_find_env+0x2b>
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	c1 e2 07             	shl    $0x7,%edx
  8014ae:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8014b5:	8b 12                	mov    (%edx),%edx
  8014b7:	39 ca                	cmp    %ecx,%edx
  8014b9:	75 10                	jne    8014cb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	c1 e2 07             	shl    $0x7,%edx
  8014c0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8014c7:	8b 00                	mov    (%eax),%eax
  8014c9:	eb 0e                	jmp    8014d9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014cb:	83 c0 01             	add    $0x1,%eax
  8014ce:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014d3:	75 d4                	jne    8014a9 <ipc_find_env+0x19>
  8014d5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	57                   	push   %edi
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 1c             	sub    $0x1c,%esp
  8014e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8014ed:	85 db                	test   %ebx,%ebx
  8014ef:	74 19                	je     80150a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8014f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801500:	89 34 24             	mov    %esi,(%esp)
  801503:	e8 8c fb ff ff       	call   801094 <sys_ipc_try_send>
  801508:	eb 1b                	jmp    801525 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80150a:	8b 45 14             	mov    0x14(%ebp),%eax
  80150d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801511:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801518:	ee 
  801519:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80151d:	89 34 24             	mov    %esi,(%esp)
  801520:	e8 6f fb ff ff       	call   801094 <sys_ipc_try_send>
           if(ret == 0)
  801525:	85 c0                	test   %eax,%eax
  801527:	74 28                	je     801551 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801529:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80152c:	74 1c                	je     80154a <ipc_send+0x6f>
              panic("ipc send error");
  80152e:	c7 44 24 08 4b 25 80 	movl   $0x80254b,0x8(%esp)
  801535:	00 
  801536:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80153d:	00 
  80153e:	c7 04 24 5a 25 80 00 	movl   $0x80255a,(%esp)
  801545:	e8 4a 09 00 00       	call   801e94 <_panic>
           sys_yield();
  80154a:	e8 11 fe ff ff       	call   801360 <sys_yield>
        }
  80154f:	eb 9c                	jmp    8014ed <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801551:	83 c4 1c             	add    $0x1c,%esp
  801554:	5b                   	pop    %ebx
  801555:	5e                   	pop    %esi
  801556:	5f                   	pop    %edi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	83 ec 10             	sub    $0x10,%esp
  801561:	8b 75 08             	mov    0x8(%ebp),%esi
  801564:	8b 45 0c             	mov    0xc(%ebp),%eax
  801567:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80156a:	85 c0                	test   %eax,%eax
  80156c:	75 0e                	jne    80157c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80156e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801575:	e8 af fa ff ff       	call   801029 <sys_ipc_recv>
  80157a:	eb 08                	jmp    801584 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80157c:	89 04 24             	mov    %eax,(%esp)
  80157f:	e8 a5 fa ff ff       	call   801029 <sys_ipc_recv>
        if(ret == 0){
  801584:	85 c0                	test   %eax,%eax
  801586:	75 26                	jne    8015ae <ipc_recv+0x55>
           if(from_env_store)
  801588:	85 f6                	test   %esi,%esi
  80158a:	74 0a                	je     801596 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80158c:	a1 04 40 80 00       	mov    0x804004,%eax
  801591:	8b 40 78             	mov    0x78(%eax),%eax
  801594:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801596:	85 db                	test   %ebx,%ebx
  801598:	74 0a                	je     8015a4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80159a:	a1 04 40 80 00       	mov    0x804004,%eax
  80159f:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015a2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8015a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a9:	8b 40 74             	mov    0x74(%eax),%eax
  8015ac:	eb 14                	jmp    8015c2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8015ae:	85 f6                	test   %esi,%esi
  8015b0:	74 06                	je     8015b8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8015b2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8015b8:	85 db                	test   %ebx,%ebx
  8015ba:	74 06                	je     8015c2 <ipc_recv+0x69>
              *perm_store = 0;
  8015bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    
  8015c9:	00 00                	add    %al,(%eax)
  8015cb:	00 00                	add    %al,(%eax)
  8015cd:	00 00                	add    %al,(%eax)
	...

008015d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015db:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8015e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e9:	89 04 24             	mov    %eax,(%esp)
  8015ec:	e8 df ff ff ff       	call   8015d0 <fd2num>
  8015f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8015f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	57                   	push   %edi
  8015ff:	56                   	push   %esi
  801600:	53                   	push   %ebx
  801601:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801604:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801609:	a8 01                	test   $0x1,%al
  80160b:	74 36                	je     801643 <fd_alloc+0x48>
  80160d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801612:	a8 01                	test   $0x1,%al
  801614:	74 2d                	je     801643 <fd_alloc+0x48>
  801616:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80161b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801620:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801625:	89 c3                	mov    %eax,%ebx
  801627:	89 c2                	mov    %eax,%edx
  801629:	c1 ea 16             	shr    $0x16,%edx
  80162c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80162f:	f6 c2 01             	test   $0x1,%dl
  801632:	74 14                	je     801648 <fd_alloc+0x4d>
  801634:	89 c2                	mov    %eax,%edx
  801636:	c1 ea 0c             	shr    $0xc,%edx
  801639:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80163c:	f6 c2 01             	test   $0x1,%dl
  80163f:	75 10                	jne    801651 <fd_alloc+0x56>
  801641:	eb 05                	jmp    801648 <fd_alloc+0x4d>
  801643:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801648:	89 1f                	mov    %ebx,(%edi)
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80164f:	eb 17                	jmp    801668 <fd_alloc+0x6d>
  801651:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801656:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80165b:	75 c8                	jne    801625 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80165d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801663:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5f                   	pop    %edi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	83 f8 1f             	cmp    $0x1f,%eax
  801676:	77 36                	ja     8016ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801678:	05 00 00 0d 00       	add    $0xd0000,%eax
  80167d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801680:	89 c2                	mov    %eax,%edx
  801682:	c1 ea 16             	shr    $0x16,%edx
  801685:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80168c:	f6 c2 01             	test   $0x1,%dl
  80168f:	74 1d                	je     8016ae <fd_lookup+0x41>
  801691:	89 c2                	mov    %eax,%edx
  801693:	c1 ea 0c             	shr    $0xc,%edx
  801696:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80169d:	f6 c2 01             	test   $0x1,%dl
  8016a0:	74 0c                	je     8016ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a5:	89 02                	mov    %eax,(%edx)
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8016ac:	eb 05                	jmp    8016b3 <fd_lookup+0x46>
  8016ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	e8 a0 ff ff ff       	call   80166d <fd_lookup>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 0e                	js     8016df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d7:	89 50 04             	mov    %edx,0x4(%eax)
  8016da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 10             	sub    $0x10,%esp
  8016e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8016ef:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8016f4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016f9:	be e0 25 80 00       	mov    $0x8025e0,%esi
		if (devtab[i]->dev_id == dev_id) {
  8016fe:	39 08                	cmp    %ecx,(%eax)
  801700:	75 10                	jne    801712 <dev_lookup+0x31>
  801702:	eb 04                	jmp    801708 <dev_lookup+0x27>
  801704:	39 08                	cmp    %ecx,(%eax)
  801706:	75 0a                	jne    801712 <dev_lookup+0x31>
			*dev = devtab[i];
  801708:	89 03                	mov    %eax,(%ebx)
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80170f:	90                   	nop
  801710:	eb 31                	jmp    801743 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801712:	83 c2 01             	add    $0x1,%edx
  801715:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801718:	85 c0                	test   %eax,%eax
  80171a:	75 e8                	jne    801704 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80171c:	a1 04 40 80 00       	mov    0x804004,%eax
  801721:	8b 40 48             	mov    0x48(%eax),%eax
  801724:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172c:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  801733:	e8 61 ea ff ff       	call   800199 <cprintf>
	*dev = 0;
  801738:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80173e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	53                   	push   %ebx
  80174e:	83 ec 24             	sub    $0x24,%esp
  801751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801754:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	89 04 24             	mov    %eax,(%esp)
  801761:	e8 07 ff ff ff       	call   80166d <fd_lookup>
  801766:	85 c0                	test   %eax,%eax
  801768:	78 53                	js     8017bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801771:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801774:	8b 00                	mov    (%eax),%eax
  801776:	89 04 24             	mov    %eax,(%esp)
  801779:	e8 63 ff ff ff       	call   8016e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 3b                	js     8017bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801782:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80178e:	74 2d                	je     8017bd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801790:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801793:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80179a:	00 00 00 
	stat->st_isdir = 0;
  80179d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a4:	00 00 00 
	stat->st_dev = dev;
  8017a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017aa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017b7:	89 14 24             	mov    %edx,(%esp)
  8017ba:	ff 50 14             	call   *0x14(%eax)
}
  8017bd:	83 c4 24             	add    $0x24,%esp
  8017c0:	5b                   	pop    %ebx
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 24             	sub    $0x24,%esp
  8017ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d4:	89 1c 24             	mov    %ebx,(%esp)
  8017d7:	e8 91 fe ff ff       	call   80166d <fd_lookup>
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 5f                	js     80183f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ea:	8b 00                	mov    (%eax),%eax
  8017ec:	89 04 24             	mov    %eax,(%esp)
  8017ef:	e8 ed fe ff ff       	call   8016e1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 47                	js     80183f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017fb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017ff:	75 23                	jne    801824 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801801:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801806:	8b 40 48             	mov    0x48(%eax),%eax
  801809:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  801818:	e8 7c e9 ff ff       	call   800199 <cprintf>
  80181d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801822:	eb 1b                	jmp    80183f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801824:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801827:	8b 48 18             	mov    0x18(%eax),%ecx
  80182a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80182f:	85 c9                	test   %ecx,%ecx
  801831:	74 0c                	je     80183f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801833:	8b 45 0c             	mov    0xc(%ebp),%eax
  801836:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183a:	89 14 24             	mov    %edx,(%esp)
  80183d:	ff d1                	call   *%ecx
}
  80183f:	83 c4 24             	add    $0x24,%esp
  801842:	5b                   	pop    %ebx
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	53                   	push   %ebx
  801849:	83 ec 24             	sub    $0x24,%esp
  80184c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801852:	89 44 24 04          	mov    %eax,0x4(%esp)
  801856:	89 1c 24             	mov    %ebx,(%esp)
  801859:	e8 0f fe ff ff       	call   80166d <fd_lookup>
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 66                	js     8018c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801862:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801865:	89 44 24 04          	mov    %eax,0x4(%esp)
  801869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186c:	8b 00                	mov    (%eax),%eax
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	e8 6b fe ff ff       	call   8016e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801876:	85 c0                	test   %eax,%eax
  801878:	78 4e                	js     8018c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80187d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801881:	75 23                	jne    8018a6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801883:	a1 04 40 80 00       	mov    0x804004,%eax
  801888:	8b 40 48             	mov    0x48(%eax),%eax
  80188b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801893:	c7 04 24 a5 25 80 00 	movl   $0x8025a5,(%esp)
  80189a:	e8 fa e8 ff ff       	call   800199 <cprintf>
  80189f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018a4:	eb 22                	jmp    8018c8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8018ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018b1:	85 c9                	test   %ecx,%ecx
  8018b3:	74 13                	je     8018c8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c3:	89 14 24             	mov    %edx,(%esp)
  8018c6:	ff d1                	call   *%ecx
}
  8018c8:	83 c4 24             	add    $0x24,%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5d                   	pop    %ebp
  8018cd:	c3                   	ret    

008018ce <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 24             	sub    $0x24,%esp
  8018d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018df:	89 1c 24             	mov    %ebx,(%esp)
  8018e2:	e8 86 fd ff ff       	call   80166d <fd_lookup>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 6b                	js     801956 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f5:	8b 00                	mov    (%eax),%eax
  8018f7:	89 04 24             	mov    %eax,(%esp)
  8018fa:	e8 e2 fd ff ff       	call   8016e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 53                	js     801956 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801903:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801906:	8b 42 08             	mov    0x8(%edx),%eax
  801909:	83 e0 03             	and    $0x3,%eax
  80190c:	83 f8 01             	cmp    $0x1,%eax
  80190f:	75 23                	jne    801934 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801911:	a1 04 40 80 00       	mov    0x804004,%eax
  801916:	8b 40 48             	mov    0x48(%eax),%eax
  801919:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	c7 04 24 c2 25 80 00 	movl   $0x8025c2,(%esp)
  801928:	e8 6c e8 ff ff       	call   800199 <cprintf>
  80192d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801932:	eb 22                	jmp    801956 <read+0x88>
	}
	if (!dev->dev_read)
  801934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801937:	8b 48 08             	mov    0x8(%eax),%ecx
  80193a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80193f:	85 c9                	test   %ecx,%ecx
  801941:	74 13                	je     801956 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801943:	8b 45 10             	mov    0x10(%ebp),%eax
  801946:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801951:	89 14 24             	mov    %edx,(%esp)
  801954:	ff d1                	call   *%ecx
}
  801956:	83 c4 24             	add    $0x24,%esp
  801959:	5b                   	pop    %ebx
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	57                   	push   %edi
  801960:	56                   	push   %esi
  801961:	53                   	push   %ebx
  801962:	83 ec 1c             	sub    $0x1c,%esp
  801965:	8b 7d 08             	mov    0x8(%ebp),%edi
  801968:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
  801970:	bb 00 00 00 00       	mov    $0x0,%ebx
  801975:	b8 00 00 00 00       	mov    $0x0,%eax
  80197a:	85 f6                	test   %esi,%esi
  80197c:	74 29                	je     8019a7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80197e:	89 f0                	mov    %esi,%eax
  801980:	29 d0                	sub    %edx,%eax
  801982:	89 44 24 08          	mov    %eax,0x8(%esp)
  801986:	03 55 0c             	add    0xc(%ebp),%edx
  801989:	89 54 24 04          	mov    %edx,0x4(%esp)
  80198d:	89 3c 24             	mov    %edi,(%esp)
  801990:	e8 39 ff ff ff       	call   8018ce <read>
		if (m < 0)
  801995:	85 c0                	test   %eax,%eax
  801997:	78 0e                	js     8019a7 <readn+0x4b>
			return m;
		if (m == 0)
  801999:	85 c0                	test   %eax,%eax
  80199b:	74 08                	je     8019a5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80199d:	01 c3                	add    %eax,%ebx
  80199f:	89 da                	mov    %ebx,%edx
  8019a1:	39 f3                	cmp    %esi,%ebx
  8019a3:	72 d9                	jb     80197e <readn+0x22>
  8019a5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019a7:	83 c4 1c             	add    $0x1c,%esp
  8019aa:	5b                   	pop    %ebx
  8019ab:	5e                   	pop    %esi
  8019ac:	5f                   	pop    %edi
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 20             	sub    $0x20,%esp
  8019b7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8019ba:	89 34 24             	mov    %esi,(%esp)
  8019bd:	e8 0e fc ff ff       	call   8015d0 <fd2num>
  8019c2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 9c fc ff ff       	call   80166d <fd_lookup>
  8019d1:	89 c3                	mov    %eax,%ebx
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 05                	js     8019dc <fd_close+0x2d>
  8019d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8019da:	74 0c                	je     8019e8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8019dc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8019e0:	19 c0                	sbb    %eax,%eax
  8019e2:	f7 d0                	not    %eax
  8019e4:	21 c3                	and    %eax,%ebx
  8019e6:	eb 3d                	jmp    801a25 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8019e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ef:	8b 06                	mov    (%esi),%eax
  8019f1:	89 04 24             	mov    %eax,(%esp)
  8019f4:	e8 e8 fc ff ff       	call   8016e1 <dev_lookup>
  8019f9:	89 c3                	mov    %eax,%ebx
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	78 16                	js     801a15 <fd_close+0x66>
		if (dev->dev_close)
  8019ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a02:	8b 40 10             	mov    0x10(%eax),%eax
  801a05:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	74 07                	je     801a15 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801a0e:	89 34 24             	mov    %esi,(%esp)
  801a11:	ff d0                	call   *%eax
  801a13:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a15:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a20:	e8 f4 f7 ff ff       	call   801219 <sys_page_unmap>
	return r;
}
  801a25:	89 d8                	mov    %ebx,%eax
  801a27:	83 c4 20             	add    $0x20,%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	89 04 24             	mov    %eax,(%esp)
  801a41:	e8 27 fc ff ff       	call   80166d <fd_lookup>
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 13                	js     801a5d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801a4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a51:	00 
  801a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a55:	89 04 24             	mov    %eax,(%esp)
  801a58:	e8 52 ff ff ff       	call   8019af <fd_close>
}
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 18             	sub    $0x18,%esp
  801a65:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a68:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a72:	00 
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	89 04 24             	mov    %eax,(%esp)
  801a79:	e8 79 03 00 00       	call   801df7 <open>
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	85 c0                	test   %eax,%eax
  801a82:	78 1b                	js     801a9f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	89 1c 24             	mov    %ebx,(%esp)
  801a8e:	e8 b7 fc ff ff       	call   80174a <fstat>
  801a93:	89 c6                	mov    %eax,%esi
	close(fd);
  801a95:	89 1c 24             	mov    %ebx,(%esp)
  801a98:	e8 91 ff ff ff       	call   801a2e <close>
  801a9d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a9f:	89 d8                	mov    %ebx,%eax
  801aa1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801aa4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801aa7:	89 ec                	mov    %ebp,%esp
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 14             	sub    $0x14,%esp
  801ab2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801ab7:	89 1c 24             	mov    %ebx,(%esp)
  801aba:	e8 6f ff ff ff       	call   801a2e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801abf:	83 c3 01             	add    $0x1,%ebx
  801ac2:	83 fb 20             	cmp    $0x20,%ebx
  801ac5:	75 f0                	jne    801ab7 <close_all+0xc>
		close(i);
}
  801ac7:	83 c4 14             	add    $0x14,%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	83 ec 58             	sub    $0x58,%esp
  801ad3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ad6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ad9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801adc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801adf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae9:	89 04 24             	mov    %eax,(%esp)
  801aec:	e8 7c fb ff ff       	call   80166d <fd_lookup>
  801af1:	89 c3                	mov    %eax,%ebx
  801af3:	85 c0                	test   %eax,%eax
  801af5:	0f 88 e0 00 00 00    	js     801bdb <dup+0x10e>
		return r;
	close(newfdnum);
  801afb:	89 3c 24             	mov    %edi,(%esp)
  801afe:	e8 2b ff ff ff       	call   801a2e <close>

	newfd = INDEX2FD(newfdnum);
  801b03:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b09:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b0f:	89 04 24             	mov    %eax,(%esp)
  801b12:	e8 c9 fa ff ff       	call   8015e0 <fd2data>
  801b17:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b19:	89 34 24             	mov    %esi,(%esp)
  801b1c:	e8 bf fa ff ff       	call   8015e0 <fd2data>
  801b21:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801b24:	89 da                	mov    %ebx,%edx
  801b26:	89 d8                	mov    %ebx,%eax
  801b28:	c1 e8 16             	shr    $0x16,%eax
  801b2b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b32:	a8 01                	test   $0x1,%al
  801b34:	74 43                	je     801b79 <dup+0xac>
  801b36:	c1 ea 0c             	shr    $0xc,%edx
  801b39:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b40:	a8 01                	test   $0x1,%al
  801b42:	74 35                	je     801b79 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b44:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b4b:	25 07 0e 00 00       	and    $0xe07,%eax
  801b50:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b62:	00 
  801b63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b6e:	e8 12 f7 ff ff       	call   801285 <sys_page_map>
  801b73:	89 c3                	mov    %eax,%ebx
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 3f                	js     801bb8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7c:	89 c2                	mov    %eax,%edx
  801b7e:	c1 ea 0c             	shr    $0xc,%edx
  801b81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b88:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b8e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b92:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b9d:	00 
  801b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba9:	e8 d7 f6 ff ff       	call   801285 <sys_page_map>
  801bae:	89 c3                	mov    %eax,%ebx
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	78 04                	js     801bb8 <dup+0xeb>
  801bb4:	89 fb                	mov    %edi,%ebx
  801bb6:	eb 23                	jmp    801bdb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801bb8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc3:	e8 51 f6 ff ff       	call   801219 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801bc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd6:	e8 3e f6 ff ff       	call   801219 <sys_page_unmap>
	return r;
}
  801bdb:	89 d8                	mov    %ebx,%eax
  801bdd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801be0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801be3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801be6:	89 ec                	mov    %ebp,%esp
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    
	...

00801bec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	83 ec 18             	sub    $0x18,%esp
  801bf2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801bf5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801bfc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c03:	75 11                	jne    801c16 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c05:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c0c:	e8 7f f8 ff ff       	call   801490 <ipc_find_env>
  801c11:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c16:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c1d:	00 
  801c1e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c25:	00 
  801c26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c2a:	a1 00 40 80 00       	mov    0x804000,%eax
  801c2f:	89 04 24             	mov    %eax,(%esp)
  801c32:	e8 a4 f8 ff ff       	call   8014db <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c3e:	00 
  801c3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4a:	e8 0a f9 ff ff       	call   801559 <ipc_recv>
}
  801c4f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c52:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c55:	89 ec                	mov    %ebp,%esp
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c62:	8b 40 0c             	mov    0xc(%eax),%eax
  801c65:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c72:	ba 00 00 00 00       	mov    $0x0,%edx
  801c77:	b8 02 00 00 00       	mov    $0x2,%eax
  801c7c:	e8 6b ff ff ff       	call   801bec <fsipc>
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c89:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c8f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c94:	ba 00 00 00 00       	mov    $0x0,%edx
  801c99:	b8 06 00 00 00       	mov    $0x6,%eax
  801c9e:	e8 49 ff ff ff       	call   801bec <fsipc>
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cab:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb0:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb5:	e8 32 ff ff ff       	call   801bec <fsipc>
}
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	53                   	push   %ebx
  801cc0:	83 ec 14             	sub    $0x14,%esp
  801cc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	8b 40 0c             	mov    0xc(%eax),%eax
  801ccc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd6:	b8 05 00 00 00       	mov    $0x5,%eax
  801cdb:	e8 0c ff ff ff       	call   801bec <fsipc>
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	78 2b                	js     801d0f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ce4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ceb:	00 
  801cec:	89 1c 24             	mov    %ebx,(%esp)
  801cef:	e8 d6 ed ff ff       	call   800aca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cf4:	a1 80 50 80 00       	mov    0x805080,%eax
  801cf9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cff:	a1 84 50 80 00       	mov    0x805084,%eax
  801d04:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d0a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d0f:	83 c4 14             	add    $0x14,%esp
  801d12:	5b                   	pop    %ebx
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 18             	sub    $0x18,%esp
  801d1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d1e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d23:	76 05                	jbe    801d2a <devfile_write+0x15>
  801d25:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  801d2d:	8b 52 0c             	mov    0xc(%edx),%edx
  801d30:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801d36:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801d3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d46:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801d4d:	e8 63 ef ff ff       	call   800cb5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801d52:	ba 00 00 00 00       	mov    $0x0,%edx
  801d57:	b8 04 00 00 00       	mov    $0x4,%eax
  801d5c:	e8 8b fe ff ff       	call   801bec <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	53                   	push   %ebx
  801d67:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d70:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801d75:	8b 45 10             	mov    0x10(%ebp),%eax
  801d78:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801d7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d82:	b8 03 00 00 00       	mov    $0x3,%eax
  801d87:	e8 60 fe ff ff       	call   801bec <fsipc>
  801d8c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 17                	js     801da9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801d92:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d96:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d9d:	00 
  801d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da1:	89 04 24             	mov    %eax,(%esp)
  801da4:	e8 0c ef ff ff       	call   800cb5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801da9:	89 d8                	mov    %ebx,%eax
  801dab:	83 c4 14             	add    $0x14,%esp
  801dae:	5b                   	pop    %ebx
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	53                   	push   %ebx
  801db5:	83 ec 14             	sub    $0x14,%esp
  801db8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801dbb:	89 1c 24             	mov    %ebx,(%esp)
  801dbe:	e8 bd ec ff ff       	call   800a80 <strlen>
  801dc3:	89 c2                	mov    %eax,%edx
  801dc5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801dca:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801dd0:	7f 1f                	jg     801df1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801dd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dd6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ddd:	e8 e8 ec ff ff       	call   800aca <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801de2:	ba 00 00 00 00       	mov    $0x0,%edx
  801de7:	b8 07 00 00 00       	mov    $0x7,%eax
  801dec:	e8 fb fd ff ff       	call   801bec <fsipc>
}
  801df1:	83 c4 14             	add    $0x14,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    

00801df7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 28             	sub    $0x28,%esp
  801dfd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e00:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e03:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801e06:	89 34 24             	mov    %esi,(%esp)
  801e09:	e8 72 ec ff ff       	call   800a80 <strlen>
  801e0e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801e13:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e18:	7f 6d                	jg     801e87 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801e1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1d:	89 04 24             	mov    %eax,(%esp)
  801e20:	e8 d6 f7 ff ff       	call   8015fb <fd_alloc>
  801e25:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e27:	85 c0                	test   %eax,%eax
  801e29:	78 5c                	js     801e87 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801e33:	89 34 24             	mov    %esi,(%esp)
  801e36:	e8 45 ec ff ff       	call   800a80 <strlen>
  801e3b:	83 c0 01             	add    $0x1,%eax
  801e3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e42:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e46:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e4d:	e8 63 ee ff ff       	call   800cb5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801e52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e55:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5a:	e8 8d fd ff ff       	call   801bec <fsipc>
  801e5f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801e61:	85 c0                	test   %eax,%eax
  801e63:	79 15                	jns    801e7a <open+0x83>
             fd_close(fd,0);
  801e65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e6c:	00 
  801e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e70:	89 04 24             	mov    %eax,(%esp)
  801e73:	e8 37 fb ff ff       	call   8019af <fd_close>
             return r;
  801e78:	eb 0d                	jmp    801e87 <open+0x90>
        }
        return fd2num(fd);
  801e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7d:	89 04 24             	mov    %eax,(%esp)
  801e80:	e8 4b f7 ff ff       	call   8015d0 <fd2num>
  801e85:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801e87:	89 d8                	mov    %ebx,%eax
  801e89:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e8c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e8f:	89 ec                	mov    %ebp,%esp
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    
	...

00801e94 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
  801e99:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801e9c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e9f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ea5:	e8 38 f5 ff ff       	call   8013e2 <sys_getenvid>
  801eaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ead:	89 54 24 10          	mov    %edx,0x10(%esp)
  801eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  801eb4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801eb8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ebc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec0:	c7 04 24 e8 25 80 00 	movl   $0x8025e8,(%esp)
  801ec7:	e8 cd e2 ff ff       	call   800199 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ecc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ed3:	89 04 24             	mov    %eax,(%esp)
  801ed6:	e8 5d e2 ff ff       	call   800138 <vcprintf>
	cprintf("\n");
  801edb:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  801ee2:	e8 b2 e2 ff ff       	call   800199 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ee7:	cc                   	int3   
  801ee8:	eb fd                	jmp    801ee7 <_panic+0x53>
  801eea:	00 00                	add    %al,(%eax)
  801eec:	00 00                	add    %al,(%eax)
	...

00801ef0 <__udivdi3>:
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	57                   	push   %edi
  801ef4:	56                   	push   %esi
  801ef5:	83 ec 10             	sub    $0x10,%esp
  801ef8:	8b 45 14             	mov    0x14(%ebp),%eax
  801efb:	8b 55 08             	mov    0x8(%ebp),%edx
  801efe:	8b 75 10             	mov    0x10(%ebp),%esi
  801f01:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f04:	85 c0                	test   %eax,%eax
  801f06:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801f09:	75 35                	jne    801f40 <__udivdi3+0x50>
  801f0b:	39 fe                	cmp    %edi,%esi
  801f0d:	77 61                	ja     801f70 <__udivdi3+0x80>
  801f0f:	85 f6                	test   %esi,%esi
  801f11:	75 0b                	jne    801f1e <__udivdi3+0x2e>
  801f13:	b8 01 00 00 00       	mov    $0x1,%eax
  801f18:	31 d2                	xor    %edx,%edx
  801f1a:	f7 f6                	div    %esi
  801f1c:	89 c6                	mov    %eax,%esi
  801f1e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801f21:	31 d2                	xor    %edx,%edx
  801f23:	89 f8                	mov    %edi,%eax
  801f25:	f7 f6                	div    %esi
  801f27:	89 c7                	mov    %eax,%edi
  801f29:	89 c8                	mov    %ecx,%eax
  801f2b:	f7 f6                	div    %esi
  801f2d:	89 c1                	mov    %eax,%ecx
  801f2f:	89 fa                	mov    %edi,%edx
  801f31:	89 c8                	mov    %ecx,%eax
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    
  801f3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f40:	39 f8                	cmp    %edi,%eax
  801f42:	77 1c                	ja     801f60 <__udivdi3+0x70>
  801f44:	0f bd d0             	bsr    %eax,%edx
  801f47:	83 f2 1f             	xor    $0x1f,%edx
  801f4a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f4d:	75 39                	jne    801f88 <__udivdi3+0x98>
  801f4f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f52:	0f 86 a0 00 00 00    	jbe    801ff8 <__udivdi3+0x108>
  801f58:	39 f8                	cmp    %edi,%eax
  801f5a:	0f 82 98 00 00 00    	jb     801ff8 <__udivdi3+0x108>
  801f60:	31 ff                	xor    %edi,%edi
  801f62:	31 c9                	xor    %ecx,%ecx
  801f64:	89 c8                	mov    %ecx,%eax
  801f66:	89 fa                	mov    %edi,%edx
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    
  801f6f:	90                   	nop
  801f70:	89 d1                	mov    %edx,%ecx
  801f72:	89 fa                	mov    %edi,%edx
  801f74:	89 c8                	mov    %ecx,%eax
  801f76:	31 ff                	xor    %edi,%edi
  801f78:	f7 f6                	div    %esi
  801f7a:	89 c1                	mov    %eax,%ecx
  801f7c:	89 fa                	mov    %edi,%edx
  801f7e:	89 c8                	mov    %ecx,%eax
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	5e                   	pop    %esi
  801f84:	5f                   	pop    %edi
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    
  801f87:	90                   	nop
  801f88:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f8c:	89 f2                	mov    %esi,%edx
  801f8e:	d3 e0                	shl    %cl,%eax
  801f90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f93:	b8 20 00 00 00       	mov    $0x20,%eax
  801f98:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f9b:	89 c1                	mov    %eax,%ecx
  801f9d:	d3 ea                	shr    %cl,%edx
  801f9f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fa3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801fa6:	d3 e6                	shl    %cl,%esi
  801fa8:	89 c1                	mov    %eax,%ecx
  801faa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801fad:	89 fe                	mov    %edi,%esi
  801faf:	d3 ee                	shr    %cl,%esi
  801fb1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fb5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fbb:	d3 e7                	shl    %cl,%edi
  801fbd:	89 c1                	mov    %eax,%ecx
  801fbf:	d3 ea                	shr    %cl,%edx
  801fc1:	09 d7                	or     %edx,%edi
  801fc3:	89 f2                	mov    %esi,%edx
  801fc5:	89 f8                	mov    %edi,%eax
  801fc7:	f7 75 ec             	divl   -0x14(%ebp)
  801fca:	89 d6                	mov    %edx,%esi
  801fcc:	89 c7                	mov    %eax,%edi
  801fce:	f7 65 e8             	mull   -0x18(%ebp)
  801fd1:	39 d6                	cmp    %edx,%esi
  801fd3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fd6:	72 30                	jb     802008 <__udivdi3+0x118>
  801fd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fdb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fdf:	d3 e2                	shl    %cl,%edx
  801fe1:	39 c2                	cmp    %eax,%edx
  801fe3:	73 05                	jae    801fea <__udivdi3+0xfa>
  801fe5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801fe8:	74 1e                	je     802008 <__udivdi3+0x118>
  801fea:	89 f9                	mov    %edi,%ecx
  801fec:	31 ff                	xor    %edi,%edi
  801fee:	e9 71 ff ff ff       	jmp    801f64 <__udivdi3+0x74>
  801ff3:	90                   	nop
  801ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	b9 01 00 00 00       	mov    $0x1,%ecx
  801fff:	e9 60 ff ff ff       	jmp    801f64 <__udivdi3+0x74>
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80200b:	31 ff                	xor    %edi,%edi
  80200d:	89 c8                	mov    %ecx,%eax
  80200f:	89 fa                	mov    %edi,%edx
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
	...

00802020 <__umoddi3>:
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	83 ec 20             	sub    $0x20,%esp
  802028:	8b 55 14             	mov    0x14(%ebp),%edx
  80202b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80202e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802031:	8b 75 0c             	mov    0xc(%ebp),%esi
  802034:	85 d2                	test   %edx,%edx
  802036:	89 c8                	mov    %ecx,%eax
  802038:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80203b:	75 13                	jne    802050 <__umoddi3+0x30>
  80203d:	39 f7                	cmp    %esi,%edi
  80203f:	76 3f                	jbe    802080 <__umoddi3+0x60>
  802041:	89 f2                	mov    %esi,%edx
  802043:	f7 f7                	div    %edi
  802045:	89 d0                	mov    %edx,%eax
  802047:	31 d2                	xor    %edx,%edx
  802049:	83 c4 20             	add    $0x20,%esp
  80204c:	5e                   	pop    %esi
  80204d:	5f                   	pop    %edi
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    
  802050:	39 f2                	cmp    %esi,%edx
  802052:	77 4c                	ja     8020a0 <__umoddi3+0x80>
  802054:	0f bd ca             	bsr    %edx,%ecx
  802057:	83 f1 1f             	xor    $0x1f,%ecx
  80205a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80205d:	75 51                	jne    8020b0 <__umoddi3+0x90>
  80205f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802062:	0f 87 e0 00 00 00    	ja     802148 <__umoddi3+0x128>
  802068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206b:	29 f8                	sub    %edi,%eax
  80206d:	19 d6                	sbb    %edx,%esi
  80206f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802075:	89 f2                	mov    %esi,%edx
  802077:	83 c4 20             	add    $0x20,%esp
  80207a:	5e                   	pop    %esi
  80207b:	5f                   	pop    %edi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    
  80207e:	66 90                	xchg   %ax,%ax
  802080:	85 ff                	test   %edi,%edi
  802082:	75 0b                	jne    80208f <__umoddi3+0x6f>
  802084:	b8 01 00 00 00       	mov    $0x1,%eax
  802089:	31 d2                	xor    %edx,%edx
  80208b:	f7 f7                	div    %edi
  80208d:	89 c7                	mov    %eax,%edi
  80208f:	89 f0                	mov    %esi,%eax
  802091:	31 d2                	xor    %edx,%edx
  802093:	f7 f7                	div    %edi
  802095:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802098:	f7 f7                	div    %edi
  80209a:	eb a9                	jmp    802045 <__umoddi3+0x25>
  80209c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	83 c4 20             	add    $0x20,%esp
  8020a7:	5e                   	pop    %esi
  8020a8:	5f                   	pop    %edi
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    
  8020ab:	90                   	nop
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020b4:	d3 e2                	shl    %cl,%edx
  8020b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8020be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8020c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	d3 ea                	shr    %cl,%edx
  8020cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8020d3:	d3 e7                	shl    %cl,%edi
  8020d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020dc:	89 f2                	mov    %esi,%edx
  8020de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8020e1:	89 c7                	mov    %eax,%edi
  8020e3:	d3 ea                	shr    %cl,%edx
  8020e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020ec:	89 c2                	mov    %eax,%edx
  8020ee:	d3 e6                	shl    %cl,%esi
  8020f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020f4:	d3 ea                	shr    %cl,%edx
  8020f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020fa:	09 d6                	or     %edx,%esi
  8020fc:	89 f0                	mov    %esi,%eax
  8020fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802101:	d3 e7                	shl    %cl,%edi
  802103:	89 f2                	mov    %esi,%edx
  802105:	f7 75 f4             	divl   -0xc(%ebp)
  802108:	89 d6                	mov    %edx,%esi
  80210a:	f7 65 e8             	mull   -0x18(%ebp)
  80210d:	39 d6                	cmp    %edx,%esi
  80210f:	72 2b                	jb     80213c <__umoddi3+0x11c>
  802111:	39 c7                	cmp    %eax,%edi
  802113:	72 23                	jb     802138 <__umoddi3+0x118>
  802115:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802119:	29 c7                	sub    %eax,%edi
  80211b:	19 d6                	sbb    %edx,%esi
  80211d:	89 f0                	mov    %esi,%eax
  80211f:	89 f2                	mov    %esi,%edx
  802121:	d3 ef                	shr    %cl,%edi
  802123:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802127:	d3 e0                	shl    %cl,%eax
  802129:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80212d:	09 f8                	or     %edi,%eax
  80212f:	d3 ea                	shr    %cl,%edx
  802131:	83 c4 20             	add    $0x20,%esp
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	39 d6                	cmp    %edx,%esi
  80213a:	75 d9                	jne    802115 <__umoddi3+0xf5>
  80213c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80213f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802142:	eb d1                	jmp    802115 <__umoddi3+0xf5>
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	0f 82 18 ff ff ff    	jb     802068 <__umoddi3+0x48>
  802150:	e9 1d ff ff ff       	jmp    802072 <__umoddi3+0x52>
