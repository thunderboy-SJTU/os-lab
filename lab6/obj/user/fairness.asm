
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
  80003c:	e8 a6 14 00 00       	call   8014e7 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 08 40 80 00 84 	cmpl   $0xeec00084,0x804008
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
  800065:	e8 ff 15 00 00       	call   801669 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  80007c:	e8 18 01 00 00       	call   800199 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 cc 00 c0 ee       	mov    0xeec000cc,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 d1 27 80 00 	movl   $0x8027d1,(%esp)
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
  8000be:	e8 28 15 00 00       	call   8015eb <ipc_send>
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
  8000da:	e8 08 14 00 00       	call   8014e7 <sys_getenvid>
  8000df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e4:	89 c2                	mov    %eax,%edx
  8000e6:	c1 e2 07             	shl    $0x7,%edx
  8000e9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000f0:	a3 08 40 80 00       	mov    %eax,0x804008
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
  800122:	e8 94 1a 00 00       	call   801bbb <close_all>
	sys_env_destroy(0);
  800127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012e:	e8 f4 13 00 00       	call   801527 <sys_env_destroy>
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
  80026f:	e8 dc 22 00 00       	call   802550 <__udivdi3>
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
  8002d7:	e8 a4 23 00 00       	call   802680 <__umoddi3>
  8002dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e0:	0f be 80 f2 27 80 00 	movsbl 0x8027f2(%eax),%eax
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
  8003ca:	ff 24 95 e0 29 80 00 	jmp    *0x8029e0(,%edx,4)
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
  800487:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  80048e:	85 d2                	test   %edx,%edx
  800490:	75 26                	jne    8004b8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800492:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800496:	c7 44 24 08 03 28 80 	movl   $0x802803,0x8(%esp)
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
  8004bc:	c7 44 24 08 76 2c 80 	movl   $0x802c76,0x8(%esp)
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
  8004fa:	be 0c 28 80 00       	mov    $0x80280c,%esi
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
  8007a4:	e8 a7 1d 00 00       	call   802550 <__udivdi3>
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
  8007f0:	e8 8b 1e 00 00       	call   802680 <__umoddi3>
  8007f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f9:	0f be 80 f2 27 80 00 	movsbl 0x8027f2(%eax),%eax
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
  8008a5:	c7 44 24 0c 28 29 80 	movl   $0x802928,0xc(%esp)
  8008ac:	00 
  8008ad:	c7 44 24 08 76 2c 80 	movl   $0x802c76,0x8(%esp)
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
  8008db:	c7 44 24 0c 60 29 80 	movl   $0x802960,0xc(%esp)
  8008e2:	00 
  8008e3:	c7 44 24 08 76 2c 80 	movl   $0x802c76,0x8(%esp)
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
  80096f:	e8 0c 1d 00 00       	call   802680 <__umoddi3>
  800974:	89 74 24 04          	mov    %esi,0x4(%esp)
  800978:	0f be 80 f2 27 80 00 	movsbl 0x8027f2(%eax),%eax
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
  8009b1:	e8 ca 1c 00 00       	call   802680 <__umoddi3>
  8009b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ba:	0f be 80 f2 27 80 00 	movsbl 0x8027f2(%eax),%eax
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

00800f3b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  800f48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4d:	b8 13 00 00 00       	mov    $0x13,%eax
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	89 cb                	mov    %ecx,%ebx
  800f57:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800f71:	8b 1c 24             	mov    (%esp),%ebx
  800f74:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f78:	89 ec                	mov    %ebp,%esp
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 08             	sub    $0x8,%esp
  800f82:	89 1c 24             	mov    %ebx,(%esp)
  800f85:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8e:	b8 12 00 00 00       	mov    $0x12,%eax
  800f93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f96:	8b 55 08             	mov    0x8(%ebp),%edx
  800f99:	89 df                	mov    %ebx,%edi
  800f9b:	51                   	push   %ecx
  800f9c:	52                   	push   %edx
  800f9d:	53                   	push   %ebx
  800f9e:	54                   	push   %esp
  800f9f:	55                   	push   %ebp
  800fa0:	56                   	push   %esi
  800fa1:	57                   	push   %edi
  800fa2:	54                   	push   %esp
  800fa3:	5d                   	pop    %ebp
  800fa4:	8d 35 ac 0f 80 00    	lea    0x800fac,%esi
  800faa:	0f 34                	sysenter 
  800fac:	5f                   	pop    %edi
  800fad:	5e                   	pop    %esi
  800fae:	5d                   	pop    %ebp
  800faf:	5c                   	pop    %esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5a                   	pop    %edx
  800fb2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800fb3:	8b 1c 24             	mov    (%esp),%ebx
  800fb6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fba:	89 ec                	mov    %ebp,%esp
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 08             	sub    $0x8,%esp
  800fc4:	89 1c 24             	mov    %ebx,(%esp)
  800fc7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd0:	b8 11 00 00 00       	mov    $0x11,%eax
  800fd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdb:	89 df                	mov    %ebx,%edi
  800fdd:	51                   	push   %ecx
  800fde:	52                   	push   %edx
  800fdf:	53                   	push   %ebx
  800fe0:	54                   	push   %esp
  800fe1:	55                   	push   %ebp
  800fe2:	56                   	push   %esi
  800fe3:	57                   	push   %edi
  800fe4:	54                   	push   %esp
  800fe5:	5d                   	pop    %ebp
  800fe6:	8d 35 ee 0f 80 00    	lea    0x800fee,%esi
  800fec:	0f 34                	sysenter 
  800fee:	5f                   	pop    %edi
  800fef:	5e                   	pop    %esi
  800ff0:	5d                   	pop    %ebp
  800ff1:	5c                   	pop    %esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5a                   	pop    %edx
  800ff4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800ff5:	8b 1c 24             	mov    (%esp),%ebx
  800ff8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ffc:	89 ec                	mov    %ebp,%esp
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	89 1c 24             	mov    %ebx,(%esp)
  801009:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80100d:	b8 10 00 00 00       	mov    $0x10,%eax
  801012:	8b 7d 14             	mov    0x14(%ebp),%edi
  801015:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	51                   	push   %ecx
  80101f:	52                   	push   %edx
  801020:	53                   	push   %ebx
  801021:	54                   	push   %esp
  801022:	55                   	push   %ebp
  801023:	56                   	push   %esi
  801024:	57                   	push   %edi
  801025:	54                   	push   %esp
  801026:	5d                   	pop    %ebp
  801027:	8d 35 2f 10 80 00    	lea    0x80102f,%esi
  80102d:	0f 34                	sysenter 
  80102f:	5f                   	pop    %edi
  801030:	5e                   	pop    %esi
  801031:	5d                   	pop    %ebp
  801032:	5c                   	pop    %esp
  801033:	5b                   	pop    %ebx
  801034:	5a                   	pop    %edx
  801035:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801036:	8b 1c 24             	mov    (%esp),%ebx
  801039:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80103d:	89 ec                	mov    %ebp,%esp
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 28             	sub    $0x28,%esp
  801047:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80104a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80104d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801052:	b8 0f 00 00 00       	mov    $0xf,%eax
  801057:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105a:	8b 55 08             	mov    0x8(%ebp),%edx
  80105d:	89 df                	mov    %ebx,%edi
  80105f:	51                   	push   %ecx
  801060:	52                   	push   %edx
  801061:	53                   	push   %ebx
  801062:	54                   	push   %esp
  801063:	55                   	push   %ebp
  801064:	56                   	push   %esi
  801065:	57                   	push   %edi
  801066:	54                   	push   %esp
  801067:	5d                   	pop    %ebp
  801068:	8d 35 70 10 80 00    	lea    0x801070,%esi
  80106e:	0f 34                	sysenter 
  801070:	5f                   	pop    %edi
  801071:	5e                   	pop    %esi
  801072:	5d                   	pop    %ebp
  801073:	5c                   	pop    %esp
  801074:	5b                   	pop    %ebx
  801075:	5a                   	pop    %edx
  801076:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	7e 28                	jle    8010a3 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801086:	00 
  801087:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801096:	00 
  801097:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80109e:	e8 11 14 00 00       	call   8024b4 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8010a3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010a6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010a9:	89 ec                	mov    %ebp,%esp
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	89 1c 24             	mov    %ebx,(%esp)
  8010b6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bf:	b8 15 00 00 00       	mov    $0x15,%eax
  8010c4:	89 d1                	mov    %edx,%ecx
  8010c6:	89 d3                	mov    %edx,%ebx
  8010c8:	89 d7                	mov    %edx,%edi
  8010ca:	51                   	push   %ecx
  8010cb:	52                   	push   %edx
  8010cc:	53                   	push   %ebx
  8010cd:	54                   	push   %esp
  8010ce:	55                   	push   %ebp
  8010cf:	56                   	push   %esi
  8010d0:	57                   	push   %edi
  8010d1:	54                   	push   %esp
  8010d2:	5d                   	pop    %ebp
  8010d3:	8d 35 db 10 80 00    	lea    0x8010db,%esi
  8010d9:	0f 34                	sysenter 
  8010db:	5f                   	pop    %edi
  8010dc:	5e                   	pop    %esi
  8010dd:	5d                   	pop    %ebp
  8010de:	5c                   	pop    %esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5a                   	pop    %edx
  8010e1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010e2:	8b 1c 24             	mov    (%esp),%ebx
  8010e5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010e9:	89 ec                	mov    %ebp,%esp
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 08             	sub    $0x8,%esp
  8010f3:	89 1c 24             	mov    %ebx,(%esp)
  8010f6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ff:	b8 14 00 00 00       	mov    $0x14,%eax
  801104:	8b 55 08             	mov    0x8(%ebp),%edx
  801107:	89 cb                	mov    %ecx,%ebx
  801109:	89 cf                	mov    %ecx,%edi
  80110b:	51                   	push   %ecx
  80110c:	52                   	push   %edx
  80110d:	53                   	push   %ebx
  80110e:	54                   	push   %esp
  80110f:	55                   	push   %ebp
  801110:	56                   	push   %esi
  801111:	57                   	push   %edi
  801112:	54                   	push   %esp
  801113:	5d                   	pop    %ebp
  801114:	8d 35 1c 11 80 00    	lea    0x80111c,%esi
  80111a:	0f 34                	sysenter 
  80111c:	5f                   	pop    %edi
  80111d:	5e                   	pop    %esi
  80111e:	5d                   	pop    %ebp
  80111f:	5c                   	pop    %esp
  801120:	5b                   	pop    %ebx
  801121:	5a                   	pop    %edx
  801122:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801123:	8b 1c 24             	mov    (%esp),%ebx
  801126:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80112a:	89 ec                	mov    %ebp,%esp
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	83 ec 28             	sub    $0x28,%esp
  801134:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801137:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80113f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	89 cb                	mov    %ecx,%ebx
  801149:	89 cf                	mov    %ecx,%edi
  80114b:	51                   	push   %ecx
  80114c:	52                   	push   %edx
  80114d:	53                   	push   %ebx
  80114e:	54                   	push   %esp
  80114f:	55                   	push   %ebp
  801150:	56                   	push   %esi
  801151:	57                   	push   %edi
  801152:	54                   	push   %esp
  801153:	5d                   	pop    %ebp
  801154:	8d 35 5c 11 80 00    	lea    0x80115c,%esi
  80115a:	0f 34                	sysenter 
  80115c:	5f                   	pop    %edi
  80115d:	5e                   	pop    %esi
  80115e:	5d                   	pop    %ebp
  80115f:	5c                   	pop    %esp
  801160:	5b                   	pop    %ebx
  801161:	5a                   	pop    %edx
  801162:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801163:	85 c0                	test   %eax,%eax
  801165:	7e 28                	jle    80118f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801167:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801172:	00 
  801173:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80117a:	00 
  80117b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80118a:	e8 25 13 00 00       	call   8024b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80118f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801192:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801195:	89 ec                	mov    %ebp,%esp
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	89 1c 24             	mov    %ebx,(%esp)
  8011a2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011a6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011ab:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b7:	51                   	push   %ecx
  8011b8:	52                   	push   %edx
  8011b9:	53                   	push   %ebx
  8011ba:	54                   	push   %esp
  8011bb:	55                   	push   %ebp
  8011bc:	56                   	push   %esi
  8011bd:	57                   	push   %edi
  8011be:	54                   	push   %esp
  8011bf:	5d                   	pop    %ebp
  8011c0:	8d 35 c8 11 80 00    	lea    0x8011c8,%esi
  8011c6:	0f 34                	sysenter 
  8011c8:	5f                   	pop    %edi
  8011c9:	5e                   	pop    %esi
  8011ca:	5d                   	pop    %ebp
  8011cb:	5c                   	pop    %esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5a                   	pop    %edx
  8011ce:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011cf:	8b 1c 24             	mov    (%esp),%ebx
  8011d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011d6:	89 ec                	mov    %ebp,%esp
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	83 ec 28             	sub    $0x28,%esp
  8011e0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011e3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011eb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f6:	89 df                	mov    %ebx,%edi
  8011f8:	51                   	push   %ecx
  8011f9:	52                   	push   %edx
  8011fa:	53                   	push   %ebx
  8011fb:	54                   	push   %esp
  8011fc:	55                   	push   %ebp
  8011fd:	56                   	push   %esi
  8011fe:	57                   	push   %edi
  8011ff:	54                   	push   %esp
  801200:	5d                   	pop    %ebp
  801201:	8d 35 09 12 80 00    	lea    0x801209,%esi
  801207:	0f 34                	sysenter 
  801209:	5f                   	pop    %edi
  80120a:	5e                   	pop    %esi
  80120b:	5d                   	pop    %ebp
  80120c:	5c                   	pop    %esp
  80120d:	5b                   	pop    %ebx
  80120e:	5a                   	pop    %edx
  80120f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801210:	85 c0                	test   %eax,%eax
  801212:	7e 28                	jle    80123c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801214:	89 44 24 10          	mov    %eax,0x10(%esp)
  801218:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80121f:	00 
  801220:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801227:	00 
  801228:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80122f:	00 
  801230:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801237:	e8 78 12 00 00       	call   8024b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80123c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80123f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801242:	89 ec                	mov    %ebp,%esp
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 28             	sub    $0x28,%esp
  80124c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80124f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801252:	bb 00 00 00 00       	mov    $0x0,%ebx
  801257:	b8 0a 00 00 00       	mov    $0xa,%eax
  80125c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125f:	8b 55 08             	mov    0x8(%ebp),%edx
  801262:	89 df                	mov    %ebx,%edi
  801264:	51                   	push   %ecx
  801265:	52                   	push   %edx
  801266:	53                   	push   %ebx
  801267:	54                   	push   %esp
  801268:	55                   	push   %ebp
  801269:	56                   	push   %esi
  80126a:	57                   	push   %edi
  80126b:	54                   	push   %esp
  80126c:	5d                   	pop    %ebp
  80126d:	8d 35 75 12 80 00    	lea    0x801275,%esi
  801273:	0f 34                	sysenter 
  801275:	5f                   	pop    %edi
  801276:	5e                   	pop    %esi
  801277:	5d                   	pop    %ebp
  801278:	5c                   	pop    %esp
  801279:	5b                   	pop    %ebx
  80127a:	5a                   	pop    %edx
  80127b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80127c:	85 c0                	test   %eax,%eax
  80127e:	7e 28                	jle    8012a8 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801280:	89 44 24 10          	mov    %eax,0x10(%esp)
  801284:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80128b:	00 
  80128c:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801293:	00 
  801294:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80129b:	00 
  80129c:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  8012a3:	e8 0c 12 00 00       	call   8024b4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012a8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ae:	89 ec                	mov    %ebp,%esp
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	83 ec 28             	sub    $0x28,%esp
  8012b8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012bb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c3:	b8 09 00 00 00       	mov    $0x9,%eax
  8012c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ce:	89 df                	mov    %ebx,%edi
  8012d0:	51                   	push   %ecx
  8012d1:	52                   	push   %edx
  8012d2:	53                   	push   %ebx
  8012d3:	54                   	push   %esp
  8012d4:	55                   	push   %ebp
  8012d5:	56                   	push   %esi
  8012d6:	57                   	push   %edi
  8012d7:	54                   	push   %esp
  8012d8:	5d                   	pop    %ebp
  8012d9:	8d 35 e1 12 80 00    	lea    0x8012e1,%esi
  8012df:	0f 34                	sysenter 
  8012e1:	5f                   	pop    %edi
  8012e2:	5e                   	pop    %esi
  8012e3:	5d                   	pop    %ebp
  8012e4:	5c                   	pop    %esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5a                   	pop    %edx
  8012e7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	7e 28                	jle    801314 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  8012ff:	00 
  801300:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801307:	00 
  801308:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80130f:	e8 a0 11 00 00       	call   8024b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801314:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801317:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80131a:	89 ec                	mov    %ebp,%esp
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 28             	sub    $0x28,%esp
  801324:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801327:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80132a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132f:	b8 07 00 00 00       	mov    $0x7,%eax
  801334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801337:	8b 55 08             	mov    0x8(%ebp),%edx
  80133a:	89 df                	mov    %ebx,%edi
  80133c:	51                   	push   %ecx
  80133d:	52                   	push   %edx
  80133e:	53                   	push   %ebx
  80133f:	54                   	push   %esp
  801340:	55                   	push   %ebp
  801341:	56                   	push   %esi
  801342:	57                   	push   %edi
  801343:	54                   	push   %esp
  801344:	5d                   	pop    %ebp
  801345:	8d 35 4d 13 80 00    	lea    0x80134d,%esi
  80134b:	0f 34                	sysenter 
  80134d:	5f                   	pop    %edi
  80134e:	5e                   	pop    %esi
  80134f:	5d                   	pop    %ebp
  801350:	5c                   	pop    %esp
  801351:	5b                   	pop    %ebx
  801352:	5a                   	pop    %edx
  801353:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801354:	85 c0                	test   %eax,%eax
  801356:	7e 28                	jle    801380 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801358:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801363:	00 
  801364:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80136b:	00 
  80136c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801373:	00 
  801374:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80137b:	e8 34 11 00 00       	call   8024b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801380:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801383:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801386:	89 ec                	mov    %ebp,%esp
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	83 ec 28             	sub    $0x28,%esp
  801390:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801393:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801396:	8b 7d 18             	mov    0x18(%ebp),%edi
  801399:	0b 7d 14             	or     0x14(%ebp),%edi
  80139c:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013aa:	51                   	push   %ecx
  8013ab:	52                   	push   %edx
  8013ac:	53                   	push   %ebx
  8013ad:	54                   	push   %esp
  8013ae:	55                   	push   %ebp
  8013af:	56                   	push   %esi
  8013b0:	57                   	push   %edi
  8013b1:	54                   	push   %esp
  8013b2:	5d                   	pop    %ebp
  8013b3:	8d 35 bb 13 80 00    	lea    0x8013bb,%esi
  8013b9:	0f 34                	sysenter 
  8013bb:	5f                   	pop    %edi
  8013bc:	5e                   	pop    %esi
  8013bd:	5d                   	pop    %ebp
  8013be:	5c                   	pop    %esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5a                   	pop    %edx
  8013c1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	7e 28                	jle    8013ee <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ca:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013d1:	00 
  8013d2:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  8013d9:	00 
  8013da:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013e1:	00 
  8013e2:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  8013e9:	e8 c6 10 00 00       	call   8024b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8013ee:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013f4:	89 ec                	mov    %ebp,%esp
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 28             	sub    $0x28,%esp
  8013fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801401:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801404:	bf 00 00 00 00       	mov    $0x0,%edi
  801409:	b8 05 00 00 00       	mov    $0x5,%eax
  80140e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801411:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801414:	8b 55 08             	mov    0x8(%ebp),%edx
  801417:	51                   	push   %ecx
  801418:	52                   	push   %edx
  801419:	53                   	push   %ebx
  80141a:	54                   	push   %esp
  80141b:	55                   	push   %ebp
  80141c:	56                   	push   %esi
  80141d:	57                   	push   %edi
  80141e:	54                   	push   %esp
  80141f:	5d                   	pop    %ebp
  801420:	8d 35 28 14 80 00    	lea    0x801428,%esi
  801426:	0f 34                	sysenter 
  801428:	5f                   	pop    %edi
  801429:	5e                   	pop    %esi
  80142a:	5d                   	pop    %ebp
  80142b:	5c                   	pop    %esp
  80142c:	5b                   	pop    %ebx
  80142d:	5a                   	pop    %edx
  80142e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80142f:	85 c0                	test   %eax,%eax
  801431:	7e 28                	jle    80145b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801433:	89 44 24 10          	mov    %eax,0x10(%esp)
  801437:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80143e:	00 
  80143f:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801446:	00 
  801447:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80144e:	00 
  80144f:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801456:	e8 59 10 00 00       	call   8024b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80145b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80145e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801461:	89 ec                	mov    %ebp,%esp
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	89 1c 24             	mov    %ebx,(%esp)
  80146e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801472:	ba 00 00 00 00       	mov    $0x0,%edx
  801477:	b8 0c 00 00 00       	mov    $0xc,%eax
  80147c:	89 d1                	mov    %edx,%ecx
  80147e:	89 d3                	mov    %edx,%ebx
  801480:	89 d7                	mov    %edx,%edi
  801482:	51                   	push   %ecx
  801483:	52                   	push   %edx
  801484:	53                   	push   %ebx
  801485:	54                   	push   %esp
  801486:	55                   	push   %ebp
  801487:	56                   	push   %esi
  801488:	57                   	push   %edi
  801489:	54                   	push   %esp
  80148a:	5d                   	pop    %ebp
  80148b:	8d 35 93 14 80 00    	lea    0x801493,%esi
  801491:	0f 34                	sysenter 
  801493:	5f                   	pop    %edi
  801494:	5e                   	pop    %esi
  801495:	5d                   	pop    %ebp
  801496:	5c                   	pop    %esp
  801497:	5b                   	pop    %ebx
  801498:	5a                   	pop    %edx
  801499:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80149a:	8b 1c 24             	mov    (%esp),%ebx
  80149d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014a1:	89 ec                	mov    %ebp,%esp
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	89 1c 24             	mov    %ebx,(%esp)
  8014ae:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c2:	89 df                	mov    %ebx,%edi
  8014c4:	51                   	push   %ecx
  8014c5:	52                   	push   %edx
  8014c6:	53                   	push   %ebx
  8014c7:	54                   	push   %esp
  8014c8:	55                   	push   %ebp
  8014c9:	56                   	push   %esi
  8014ca:	57                   	push   %edi
  8014cb:	54                   	push   %esp
  8014cc:	5d                   	pop    %ebp
  8014cd:	8d 35 d5 14 80 00    	lea    0x8014d5,%esi
  8014d3:	0f 34                	sysenter 
  8014d5:	5f                   	pop    %edi
  8014d6:	5e                   	pop    %esi
  8014d7:	5d                   	pop    %ebp
  8014d8:	5c                   	pop    %esp
  8014d9:	5b                   	pop    %ebx
  8014da:	5a                   	pop    %edx
  8014db:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8014dc:	8b 1c 24             	mov    (%esp),%ebx
  8014df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014e3:	89 ec                	mov    %ebp,%esp
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    

008014e7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	89 1c 24             	mov    %ebx,(%esp)
  8014f0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014fe:	89 d1                	mov    %edx,%ecx
  801500:	89 d3                	mov    %edx,%ebx
  801502:	89 d7                	mov    %edx,%edi
  801504:	51                   	push   %ecx
  801505:	52                   	push   %edx
  801506:	53                   	push   %ebx
  801507:	54                   	push   %esp
  801508:	55                   	push   %ebp
  801509:	56                   	push   %esi
  80150a:	57                   	push   %edi
  80150b:	54                   	push   %esp
  80150c:	5d                   	pop    %ebp
  80150d:	8d 35 15 15 80 00    	lea    0x801515,%esi
  801513:	0f 34                	sysenter 
  801515:	5f                   	pop    %edi
  801516:	5e                   	pop    %esi
  801517:	5d                   	pop    %ebp
  801518:	5c                   	pop    %esp
  801519:	5b                   	pop    %ebx
  80151a:	5a                   	pop    %edx
  80151b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80151c:	8b 1c 24             	mov    (%esp),%ebx
  80151f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801523:	89 ec                	mov    %ebp,%esp
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 28             	sub    $0x28,%esp
  80152d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801530:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801533:	b9 00 00 00 00       	mov    $0x0,%ecx
  801538:	b8 03 00 00 00       	mov    $0x3,%eax
  80153d:	8b 55 08             	mov    0x8(%ebp),%edx
  801540:	89 cb                	mov    %ecx,%ebx
  801542:	89 cf                	mov    %ecx,%edi
  801544:	51                   	push   %ecx
  801545:	52                   	push   %edx
  801546:	53                   	push   %ebx
  801547:	54                   	push   %esp
  801548:	55                   	push   %ebp
  801549:	56                   	push   %esi
  80154a:	57                   	push   %edi
  80154b:	54                   	push   %esp
  80154c:	5d                   	pop    %ebp
  80154d:	8d 35 55 15 80 00    	lea    0x801555,%esi
  801553:	0f 34                	sysenter 
  801555:	5f                   	pop    %edi
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	5c                   	pop    %esp
  801559:	5b                   	pop    %ebx
  80155a:	5a                   	pop    %edx
  80155b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80155c:	85 c0                	test   %eax,%eax
  80155e:	7e 28                	jle    801588 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801560:	89 44 24 10          	mov    %eax,0x10(%esp)
  801564:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80156b:	00 
  80156c:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801573:	00 
  801574:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80157b:	00 
  80157c:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801583:	e8 2c 0f 00 00       	call   8024b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801588:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80158b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80158e:	89 ec                	mov    %ebp,%esp
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    
	...

008015a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8015a6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8015ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b1:	39 ca                	cmp    %ecx,%edx
  8015b3:	75 04                	jne    8015b9 <ipc_find_env+0x19>
  8015b5:	b0 00                	mov    $0x0,%al
  8015b7:	eb 12                	jmp    8015cb <ipc_find_env+0x2b>
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	c1 e2 07             	shl    $0x7,%edx
  8015be:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8015c5:	8b 12                	mov    (%edx),%edx
  8015c7:	39 ca                	cmp    %ecx,%edx
  8015c9:	75 10                	jne    8015db <ipc_find_env+0x3b>
			return envs[i].env_id;
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	c1 e2 07             	shl    $0x7,%edx
  8015d0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8015d7:	8b 00                	mov    (%eax),%eax
  8015d9:	eb 0e                	jmp    8015e9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8015db:	83 c0 01             	add    $0x1,%eax
  8015de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8015e3:	75 d4                	jne    8015b9 <ipc_find_env+0x19>
  8015e5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8015e9:	5d                   	pop    %ebp
  8015ea:	c3                   	ret    

008015eb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	57                   	push   %edi
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 1c             	sub    $0x1c,%esp
  8015f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8015fd:	85 db                	test   %ebx,%ebx
  8015ff:	74 19                	je     80161a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801601:	8b 45 14             	mov    0x14(%ebp),%eax
  801604:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801608:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80160c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801610:	89 34 24             	mov    %esi,(%esp)
  801613:	e8 81 fb ff ff       	call   801199 <sys_ipc_try_send>
  801618:	eb 1b                	jmp    801635 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80161a:	8b 45 14             	mov    0x14(%ebp),%eax
  80161d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801621:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801628:	ee 
  801629:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80162d:	89 34 24             	mov    %esi,(%esp)
  801630:	e8 64 fb ff ff       	call   801199 <sys_ipc_try_send>
           if(ret == 0)
  801635:	85 c0                	test   %eax,%eax
  801637:	74 28                	je     801661 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801639:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80163c:	74 1c                	je     80165a <ipc_send+0x6f>
              panic("ipc send error");
  80163e:	c7 44 24 08 ab 2b 80 	movl   $0x802bab,0x8(%esp)
  801645:	00 
  801646:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80164d:	00 
  80164e:	c7 04 24 ba 2b 80 00 	movl   $0x802bba,(%esp)
  801655:	e8 5a 0e 00 00       	call   8024b4 <_panic>
           sys_yield();
  80165a:	e8 06 fe ff ff       	call   801465 <sys_yield>
        }
  80165f:	eb 9c                	jmp    8015fd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801661:	83 c4 1c             	add    $0x1c,%esp
  801664:	5b                   	pop    %ebx
  801665:	5e                   	pop    %esi
  801666:	5f                   	pop    %edi
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	56                   	push   %esi
  80166d:	53                   	push   %ebx
  80166e:	83 ec 10             	sub    $0x10,%esp
  801671:	8b 75 08             	mov    0x8(%ebp),%esi
  801674:	8b 45 0c             	mov    0xc(%ebp),%eax
  801677:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80167a:	85 c0                	test   %eax,%eax
  80167c:	75 0e                	jne    80168c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80167e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801685:	e8 a4 fa ff ff       	call   80112e <sys_ipc_recv>
  80168a:	eb 08                	jmp    801694 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 9a fa ff ff       	call   80112e <sys_ipc_recv>
        if(ret == 0){
  801694:	85 c0                	test   %eax,%eax
  801696:	75 26                	jne    8016be <ipc_recv+0x55>
           if(from_env_store)
  801698:	85 f6                	test   %esi,%esi
  80169a:	74 0a                	je     8016a6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80169c:	a1 08 40 80 00       	mov    0x804008,%eax
  8016a1:	8b 40 78             	mov    0x78(%eax),%eax
  8016a4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  8016a6:	85 db                	test   %ebx,%ebx
  8016a8:	74 0a                	je     8016b4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  8016aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8016af:	8b 40 7c             	mov    0x7c(%eax),%eax
  8016b2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8016b4:	a1 08 40 80 00       	mov    0x804008,%eax
  8016b9:	8b 40 74             	mov    0x74(%eax),%eax
  8016bc:	eb 14                	jmp    8016d2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8016be:	85 f6                	test   %esi,%esi
  8016c0:	74 06                	je     8016c8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8016c2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8016c8:	85 db                	test   %ebx,%ebx
  8016ca:	74 06                	je     8016d2 <ipc_recv+0x69>
              *perm_store = 0;
  8016cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    
  8016d9:	00 00                	add    %al,(%eax)
  8016db:	00 00                	add    %al,(%eax)
  8016dd:	00 00                	add    %al,(%eax)
	...

008016e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016eb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	89 04 24             	mov    %eax,(%esp)
  8016fc:	e8 df ff ff ff       	call   8016e0 <fd2num>
  801701:	05 20 00 0d 00       	add    $0xd0020,%eax
  801706:	c1 e0 0c             	shl    $0xc,%eax
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	57                   	push   %edi
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
  801711:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801714:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801719:	a8 01                	test   $0x1,%al
  80171b:	74 36                	je     801753 <fd_alloc+0x48>
  80171d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801722:	a8 01                	test   $0x1,%al
  801724:	74 2d                	je     801753 <fd_alloc+0x48>
  801726:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80172b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801730:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801735:	89 c3                	mov    %eax,%ebx
  801737:	89 c2                	mov    %eax,%edx
  801739:	c1 ea 16             	shr    $0x16,%edx
  80173c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80173f:	f6 c2 01             	test   $0x1,%dl
  801742:	74 14                	je     801758 <fd_alloc+0x4d>
  801744:	89 c2                	mov    %eax,%edx
  801746:	c1 ea 0c             	shr    $0xc,%edx
  801749:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80174c:	f6 c2 01             	test   $0x1,%dl
  80174f:	75 10                	jne    801761 <fd_alloc+0x56>
  801751:	eb 05                	jmp    801758 <fd_alloc+0x4d>
  801753:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801758:	89 1f                	mov    %ebx,(%edi)
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80175f:	eb 17                	jmp    801778 <fd_alloc+0x6d>
  801761:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801766:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80176b:	75 c8                	jne    801735 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80176d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801773:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	83 f8 1f             	cmp    $0x1f,%eax
  801786:	77 36                	ja     8017be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801788:	05 00 00 0d 00       	add    $0xd0000,%eax
  80178d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801790:	89 c2                	mov    %eax,%edx
  801792:	c1 ea 16             	shr    $0x16,%edx
  801795:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80179c:	f6 c2 01             	test   $0x1,%dl
  80179f:	74 1d                	je     8017be <fd_lookup+0x41>
  8017a1:	89 c2                	mov    %eax,%edx
  8017a3:	c1 ea 0c             	shr    $0xc,%edx
  8017a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017ad:	f6 c2 01             	test   $0x1,%dl
  8017b0:	74 0c                	je     8017be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b5:	89 02                	mov    %eax,(%edx)
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8017bc:	eb 05                	jmp    8017c3 <fd_lookup+0x46>
  8017be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 a0 ff ff ff       	call   80177d <fd_lookup>
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 0e                	js     8017ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e7:	89 50 04             	mov    %edx,0x4(%eax)
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 10             	sub    $0x10,%esp
  8017f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8017ff:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801804:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801809:	be 40 2c 80 00       	mov    $0x802c40,%esi
		if (devtab[i]->dev_id == dev_id) {
  80180e:	39 08                	cmp    %ecx,(%eax)
  801810:	75 10                	jne    801822 <dev_lookup+0x31>
  801812:	eb 04                	jmp    801818 <dev_lookup+0x27>
  801814:	39 08                	cmp    %ecx,(%eax)
  801816:	75 0a                	jne    801822 <dev_lookup+0x31>
			*dev = devtab[i];
  801818:	89 03                	mov    %eax,(%ebx)
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80181f:	90                   	nop
  801820:	eb 31                	jmp    801853 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801822:	83 c2 01             	add    $0x1,%edx
  801825:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801828:	85 c0                	test   %eax,%eax
  80182a:	75 e8                	jne    801814 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80182c:	a1 08 40 80 00       	mov    0x804008,%eax
  801831:	8b 40 48             	mov    0x48(%eax),%eax
  801834:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183c:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  801843:	e8 51 e9 ff ff       	call   800199 <cprintf>
	*dev = 0;
  801848:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80184e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	5b                   	pop    %ebx
  801857:	5e                   	pop    %esi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	53                   	push   %ebx
  80185e:	83 ec 24             	sub    $0x24,%esp
  801861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	89 04 24             	mov    %eax,(%esp)
  801871:	e8 07 ff ff ff       	call   80177d <fd_lookup>
  801876:	85 c0                	test   %eax,%eax
  801878:	78 53                	js     8018cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801884:	8b 00                	mov    (%eax),%eax
  801886:	89 04 24             	mov    %eax,(%esp)
  801889:	e8 63 ff ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 3b                	js     8018cd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801892:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801897:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80189e:	74 2d                	je     8018cd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018aa:	00 00 00 
	stat->st_isdir = 0;
  8018ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b4:	00 00 00 
	stat->st_dev = dev;
  8018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018c7:	89 14 24             	mov    %edx,(%esp)
  8018ca:	ff 50 14             	call   *0x14(%eax)
}
  8018cd:	83 c4 24             	add    $0x24,%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 24             	sub    $0x24,%esp
  8018da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e4:	89 1c 24             	mov    %ebx,(%esp)
  8018e7:	e8 91 fe ff ff       	call   80177d <fd_lookup>
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 5f                	js     80194f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fa:	8b 00                	mov    (%eax),%eax
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	e8 ed fe ff ff       	call   8017f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801904:	85 c0                	test   %eax,%eax
  801906:	78 47                	js     80194f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801908:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80190b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80190f:	75 23                	jne    801934 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801911:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801916:	8b 40 48             	mov    0x48(%eax),%eax
  801919:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	c7 04 24 e4 2b 80 00 	movl   $0x802be4,(%esp)
  801928:	e8 6c e8 ff ff       	call   800199 <cprintf>
  80192d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801932:	eb 1b                	jmp    80194f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801937:	8b 48 18             	mov    0x18(%eax),%ecx
  80193a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80193f:	85 c9                	test   %ecx,%ecx
  801941:	74 0c                	je     80194f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801943:	8b 45 0c             	mov    0xc(%ebp),%eax
  801946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194a:	89 14 24             	mov    %edx,(%esp)
  80194d:	ff d1                	call   *%ecx
}
  80194f:	83 c4 24             	add    $0x24,%esp
  801952:	5b                   	pop    %ebx
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	53                   	push   %ebx
  801959:	83 ec 24             	sub    $0x24,%esp
  80195c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801962:	89 44 24 04          	mov    %eax,0x4(%esp)
  801966:	89 1c 24             	mov    %ebx,(%esp)
  801969:	e8 0f fe ff ff       	call   80177d <fd_lookup>
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 66                	js     8019d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197c:	8b 00                	mov    (%eax),%eax
  80197e:	89 04 24             	mov    %eax,(%esp)
  801981:	e8 6b fe ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801986:	85 c0                	test   %eax,%eax
  801988:	78 4e                	js     8019d8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80198a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80198d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801991:	75 23                	jne    8019b6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801993:	a1 08 40 80 00       	mov    0x804008,%eax
  801998:	8b 40 48             	mov    0x48(%eax),%eax
  80199b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80199f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a3:	c7 04 24 05 2c 80 00 	movl   $0x802c05,(%esp)
  8019aa:	e8 ea e7 ff ff       	call   800199 <cprintf>
  8019af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019b4:	eb 22                	jmp    8019d8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8019bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c1:	85 c9                	test   %ecx,%ecx
  8019c3:	74 13                	je     8019d8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d3:	89 14 24             	mov    %edx,(%esp)
  8019d6:	ff d1                	call   *%ecx
}
  8019d8:	83 c4 24             	add    $0x24,%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 24             	sub    $0x24,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ef:	89 1c 24             	mov    %ebx,(%esp)
  8019f2:	e8 86 fd ff ff       	call   80177d <fd_lookup>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 6b                	js     801a66 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a05:	8b 00                	mov    (%eax),%eax
  801a07:	89 04 24             	mov    %eax,(%esp)
  801a0a:	e8 e2 fd ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 53                	js     801a66 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a13:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a16:	8b 42 08             	mov    0x8(%edx),%eax
  801a19:	83 e0 03             	and    $0x3,%eax
  801a1c:	83 f8 01             	cmp    $0x1,%eax
  801a1f:	75 23                	jne    801a44 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a21:	a1 08 40 80 00       	mov    0x804008,%eax
  801a26:	8b 40 48             	mov    0x48(%eax),%eax
  801a29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a31:	c7 04 24 22 2c 80 00 	movl   $0x802c22,(%esp)
  801a38:	e8 5c e7 ff ff       	call   800199 <cprintf>
  801a3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a42:	eb 22                	jmp    801a66 <read+0x88>
	}
	if (!dev->dev_read)
  801a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a47:	8b 48 08             	mov    0x8(%eax),%ecx
  801a4a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a4f:	85 c9                	test   %ecx,%ecx
  801a51:	74 13                	je     801a66 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a53:	8b 45 10             	mov    0x10(%ebp),%eax
  801a56:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a61:	89 14 24             	mov    %edx,(%esp)
  801a64:	ff d1                	call   *%ecx
}
  801a66:	83 c4 24             	add    $0x24,%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	57                   	push   %edi
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 1c             	sub    $0x1c,%esp
  801a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a78:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8a:	85 f6                	test   %esi,%esi
  801a8c:	74 29                	je     801ab7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a8e:	89 f0                	mov    %esi,%eax
  801a90:	29 d0                	sub    %edx,%eax
  801a92:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a96:	03 55 0c             	add    0xc(%ebp),%edx
  801a99:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a9d:	89 3c 24             	mov    %edi,(%esp)
  801aa0:	e8 39 ff ff ff       	call   8019de <read>
		if (m < 0)
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 0e                	js     801ab7 <readn+0x4b>
			return m;
		if (m == 0)
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	74 08                	je     801ab5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801aad:	01 c3                	add    %eax,%ebx
  801aaf:	89 da                	mov    %ebx,%edx
  801ab1:	39 f3                	cmp    %esi,%ebx
  801ab3:	72 d9                	jb     801a8e <readn+0x22>
  801ab5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801ab7:	83 c4 1c             	add    $0x1c,%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5f                   	pop    %edi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 20             	sub    $0x20,%esp
  801ac7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801aca:	89 34 24             	mov    %esi,(%esp)
  801acd:	e8 0e fc ff ff       	call   8016e0 <fd2num>
  801ad2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ad5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ad9:	89 04 24             	mov    %eax,(%esp)
  801adc:	e8 9c fc ff ff       	call   80177d <fd_lookup>
  801ae1:	89 c3                	mov    %eax,%ebx
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	78 05                	js     801aec <fd_close+0x2d>
  801ae7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801aea:	74 0c                	je     801af8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801aec:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801af0:	19 c0                	sbb    %eax,%eax
  801af2:	f7 d0                	not    %eax
  801af4:	21 c3                	and    %eax,%ebx
  801af6:	eb 3d                	jmp    801b35 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801af8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aff:	8b 06                	mov    (%esi),%eax
  801b01:	89 04 24             	mov    %eax,(%esp)
  801b04:	e8 e8 fc ff ff       	call   8017f1 <dev_lookup>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 16                	js     801b25 <fd_close+0x66>
		if (dev->dev_close)
  801b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b12:	8b 40 10             	mov    0x10(%eax),%eax
  801b15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	74 07                	je     801b25 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801b1e:	89 34 24             	mov    %esi,(%esp)
  801b21:	ff d0                	call   *%eax
  801b23:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b25:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b30:	e8 e9 f7 ff ff       	call   80131e <sys_page_unmap>
	return r;
}
  801b35:	89 d8                	mov    %ebx,%eax
  801b37:	83 c4 20             	add    $0x20,%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	89 04 24             	mov    %eax,(%esp)
  801b51:	e8 27 fc ff ff       	call   80177d <fd_lookup>
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 13                	js     801b6d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b61:	00 
  801b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b65:	89 04 24             	mov    %eax,(%esp)
  801b68:	e8 52 ff ff ff       	call   801abf <fd_close>
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	83 ec 18             	sub    $0x18,%esp
  801b75:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b78:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b82:	00 
  801b83:	8b 45 08             	mov    0x8(%ebp),%eax
  801b86:	89 04 24             	mov    %eax,(%esp)
  801b89:	e8 79 03 00 00       	call   801f07 <open>
  801b8e:	89 c3                	mov    %eax,%ebx
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 1b                	js     801baf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9b:	89 1c 24             	mov    %ebx,(%esp)
  801b9e:	e8 b7 fc ff ff       	call   80185a <fstat>
  801ba3:	89 c6                	mov    %eax,%esi
	close(fd);
  801ba5:	89 1c 24             	mov    %ebx,(%esp)
  801ba8:	e8 91 ff ff ff       	call   801b3e <close>
  801bad:	89 f3                	mov    %esi,%ebx
	return r;
}
  801baf:	89 d8                	mov    %ebx,%eax
  801bb1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bb4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bb7:	89 ec                	mov    %ebp,%esp
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	53                   	push   %ebx
  801bbf:	83 ec 14             	sub    $0x14,%esp
  801bc2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801bc7:	89 1c 24             	mov    %ebx,(%esp)
  801bca:	e8 6f ff ff ff       	call   801b3e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801bcf:	83 c3 01             	add    $0x1,%ebx
  801bd2:	83 fb 20             	cmp    $0x20,%ebx
  801bd5:	75 f0                	jne    801bc7 <close_all+0xc>
		close(i);
}
  801bd7:	83 c4 14             	add    $0x14,%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 58             	sub    $0x58,%esp
  801be3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801be6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801be9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801bec:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	89 04 24             	mov    %eax,(%esp)
  801bfc:	e8 7c fb ff ff       	call   80177d <fd_lookup>
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	85 c0                	test   %eax,%eax
  801c05:	0f 88 e0 00 00 00    	js     801ceb <dup+0x10e>
		return r;
	close(newfdnum);
  801c0b:	89 3c 24             	mov    %edi,(%esp)
  801c0e:	e8 2b ff ff ff       	call   801b3e <close>

	newfd = INDEX2FD(newfdnum);
  801c13:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801c19:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c1f:	89 04 24             	mov    %eax,(%esp)
  801c22:	e8 c9 fa ff ff       	call   8016f0 <fd2data>
  801c27:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c29:	89 34 24             	mov    %esi,(%esp)
  801c2c:	e8 bf fa ff ff       	call   8016f0 <fd2data>
  801c31:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801c34:	89 da                	mov    %ebx,%edx
  801c36:	89 d8                	mov    %ebx,%eax
  801c38:	c1 e8 16             	shr    $0x16,%eax
  801c3b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c42:	a8 01                	test   $0x1,%al
  801c44:	74 43                	je     801c89 <dup+0xac>
  801c46:	c1 ea 0c             	shr    $0xc,%edx
  801c49:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c50:	a8 01                	test   $0x1,%al
  801c52:	74 35                	je     801c89 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c54:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c5b:	25 07 0e 00 00       	and    $0xe07,%eax
  801c60:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c67:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c72:	00 
  801c73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c7e:	e8 07 f7 ff ff       	call   80138a <sys_page_map>
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 3f                	js     801cc8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8c:	89 c2                	mov    %eax,%edx
  801c8e:	c1 ea 0c             	shr    $0xc,%edx
  801c91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c98:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c9e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ca2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ca6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cad:	00 
  801cae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb9:	e8 cc f6 ff ff       	call   80138a <sys_page_map>
  801cbe:	89 c3                	mov    %eax,%ebx
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 04                	js     801cc8 <dup+0xeb>
  801cc4:	89 fb                	mov    %edi,%ebx
  801cc6:	eb 23                	jmp    801ceb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801cc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ccc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd3:	e8 46 f6 ff ff       	call   80131e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801cd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce6:	e8 33 f6 ff ff       	call   80131e <sys_page_unmap>
	return r;
}
  801ceb:	89 d8                	mov    %ebx,%eax
  801ced:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cf0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cf3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cf6:	89 ec                	mov    %ebp,%esp
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    
	...

00801cfc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 18             	sub    $0x18,%esp
  801d02:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d05:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d0c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801d13:	75 11                	jne    801d26 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d15:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d1c:	e8 7f f8 ff ff       	call   8015a0 <ipc_find_env>
  801d21:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d26:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d2d:	00 
  801d2e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801d35:	00 
  801d36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d3a:	a1 00 40 80 00       	mov    0x804000,%eax
  801d3f:	89 04 24             	mov    %eax,(%esp)
  801d42:	e8 a4 f8 ff ff       	call   8015eb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d4e:	00 
  801d4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5a:	e8 0a f9 ff ff       	call   801669 <ipc_recv>
}
  801d5f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d62:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d65:	89 ec                	mov    %ebp,%esp
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	8b 40 0c             	mov    0xc(%eax),%eax
  801d75:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d82:	ba 00 00 00 00       	mov    $0x0,%edx
  801d87:	b8 02 00 00 00       	mov    $0x2,%eax
  801d8c:	e8 6b ff ff ff       	call   801cfc <fsipc>
}
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d9f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801da4:	ba 00 00 00 00       	mov    $0x0,%edx
  801da9:	b8 06 00 00 00       	mov    $0x6,%eax
  801dae:	e8 49 ff ff ff       	call   801cfc <fsipc>
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc5:	e8 32 ff ff ff       	call   801cfc <fsipc>
}
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	53                   	push   %ebx
  801dd0:	83 ec 14             	sub    $0x14,%esp
  801dd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd9:	8b 40 0c             	mov    0xc(%eax),%eax
  801ddc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801de1:	ba 00 00 00 00       	mov    $0x0,%edx
  801de6:	b8 05 00 00 00       	mov    $0x5,%eax
  801deb:	e8 0c ff ff ff       	call   801cfc <fsipc>
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 2b                	js     801e1f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801df4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dfb:	00 
  801dfc:	89 1c 24             	mov    %ebx,(%esp)
  801dff:	e8 c6 ec ff ff       	call   800aca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e04:	a1 80 50 80 00       	mov    0x805080,%eax
  801e09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e0f:	a1 84 50 80 00       	mov    0x805084,%eax
  801e14:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e1f:	83 c4 14             	add    $0x14,%esp
  801e22:	5b                   	pop    %ebx
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 18             	sub    $0x18,%esp
  801e2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e33:	76 05                	jbe    801e3a <devfile_write+0x15>
  801e35:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e3d:	8b 52 0c             	mov    0xc(%edx),%edx
  801e40:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801e46:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801e4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e56:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801e5d:	e8 53 ee ff ff       	call   800cb5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801e62:	ba 00 00 00 00       	mov    $0x0,%edx
  801e67:	b8 04 00 00 00       	mov    $0x4,%eax
  801e6c:	e8 8b fe ff ff       	call   801cfc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	53                   	push   %ebx
  801e77:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e80:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801e85:	8b 45 10             	mov    0x10(%ebp),%eax
  801e88:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e92:	b8 03 00 00 00       	mov    $0x3,%eax
  801e97:	e8 60 fe ff ff       	call   801cfc <fsipc>
  801e9c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 17                	js     801eb9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801ea2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ead:	00 
  801eae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb1:	89 04 24             	mov    %eax,(%esp)
  801eb4:	e8 fc ed ff ff       	call   800cb5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801eb9:	89 d8                	mov    %ebx,%eax
  801ebb:	83 c4 14             	add    $0x14,%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	53                   	push   %ebx
  801ec5:	83 ec 14             	sub    $0x14,%esp
  801ec8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801ecb:	89 1c 24             	mov    %ebx,(%esp)
  801ece:	e8 ad eb ff ff       	call   800a80 <strlen>
  801ed3:	89 c2                	mov    %eax,%edx
  801ed5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801eda:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ee0:	7f 1f                	jg     801f01 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801ee2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ee6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801eed:	e8 d8 eb ff ff       	call   800aca <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801ef2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef7:	b8 07 00 00 00       	mov    $0x7,%eax
  801efc:	e8 fb fd ff ff       	call   801cfc <fsipc>
}
  801f01:	83 c4 14             	add    $0x14,%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    

00801f07 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 28             	sub    $0x28,%esp
  801f0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f10:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f13:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801f16:	89 34 24             	mov    %esi,(%esp)
  801f19:	e8 62 eb ff ff       	call   800a80 <strlen>
  801f1e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801f23:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f28:	7f 6d                	jg     801f97 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801f2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2d:	89 04 24             	mov    %eax,(%esp)
  801f30:	e8 d6 f7 ff ff       	call   80170b <fd_alloc>
  801f35:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 5c                	js     801f97 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801f43:	89 34 24             	mov    %esi,(%esp)
  801f46:	e8 35 eb ff ff       	call   800a80 <strlen>
  801f4b:	83 c0 01             	add    $0x1,%eax
  801f4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f56:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f5d:	e8 53 ed ff ff       	call   800cb5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801f62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f65:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6a:	e8 8d fd ff ff       	call   801cfc <fsipc>
  801f6f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801f71:	85 c0                	test   %eax,%eax
  801f73:	79 15                	jns    801f8a <open+0x83>
             fd_close(fd,0);
  801f75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f7c:	00 
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	89 04 24             	mov    %eax,(%esp)
  801f83:	e8 37 fb ff ff       	call   801abf <fd_close>
             return r;
  801f88:	eb 0d                	jmp    801f97 <open+0x90>
        }
        return fd2num(fd);
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	89 04 24             	mov    %eax,(%esp)
  801f90:	e8 4b f7 ff ff       	call   8016e0 <fd2num>
  801f95:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801f97:	89 d8                	mov    %ebx,%eax
  801f99:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f9c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f9f:	89 ec                	mov    %ebp,%esp
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    
	...

00801fb0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801fb6:	c7 44 24 04 4c 2c 80 	movl   $0x802c4c,0x4(%esp)
  801fbd:	00 
  801fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc1:	89 04 24             	mov    %eax,(%esp)
  801fc4:	e8 01 eb ff ff       	call   800aca <strcpy>
	return 0;
}
  801fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 14             	sub    $0x14,%esp
  801fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801fda:	89 1c 24             	mov    %ebx,(%esp)
  801fdd:	e8 2a 05 00 00       	call   80250c <pageref>
  801fe2:	89 c2                	mov    %eax,%edx
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe9:	83 fa 01             	cmp    $0x1,%edx
  801fec:	75 0b                	jne    801ff9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801fee:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ff1:	89 04 24             	mov    %eax,(%esp)
  801ff4:	e8 b9 02 00 00       	call   8022b2 <nsipc_close>
	else
		return 0;
}
  801ff9:	83 c4 14             	add    $0x14,%esp
  801ffc:	5b                   	pop    %ebx
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802005:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80200c:	00 
  80200d:	8b 45 10             	mov    0x10(%ebp),%eax
  802010:	89 44 24 08          	mov    %eax,0x8(%esp)
  802014:	8b 45 0c             	mov    0xc(%ebp),%eax
  802017:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
  80201e:	8b 40 0c             	mov    0xc(%eax),%eax
  802021:	89 04 24             	mov    %eax,(%esp)
  802024:	e8 c5 02 00 00       	call   8022ee <nsipc_send>
}
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802031:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802038:	00 
  802039:	8b 45 10             	mov    0x10(%ebp),%eax
  80203c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802040:	8b 45 0c             	mov    0xc(%ebp),%eax
  802043:	89 44 24 04          	mov    %eax,0x4(%esp)
  802047:	8b 45 08             	mov    0x8(%ebp),%eax
  80204a:	8b 40 0c             	mov    0xc(%eax),%eax
  80204d:	89 04 24             	mov    %eax,(%esp)
  802050:	e8 0c 03 00 00       	call   802361 <nsipc_recv>
}
  802055:	c9                   	leave  
  802056:	c3                   	ret    

00802057 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	56                   	push   %esi
  80205b:	53                   	push   %ebx
  80205c:	83 ec 20             	sub    $0x20,%esp
  80205f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802064:	89 04 24             	mov    %eax,(%esp)
  802067:	e8 9f f6 ff ff       	call   80170b <fd_alloc>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 21                	js     802093 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802072:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802079:	00 
  80207a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802081:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802088:	e8 6b f3 ff ff       	call   8013f8 <sys_page_alloc>
  80208d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80208f:	85 c0                	test   %eax,%eax
  802091:	79 0a                	jns    80209d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802093:	89 34 24             	mov    %esi,(%esp)
  802096:	e8 17 02 00 00       	call   8022b2 <nsipc_close>
		return r;
  80209b:	eb 28                	jmp    8020c5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80209d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8020b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bb:	89 04 24             	mov    %eax,(%esp)
  8020be:	e8 1d f6 ff ff       	call   8016e0 <fd2num>
  8020c3:	89 c3                	mov    %eax,%ebx
}
  8020c5:	89 d8                	mov    %ebx,%eax
  8020c7:	83 c4 20             	add    $0x20,%esp
  8020ca:	5b                   	pop    %ebx
  8020cb:	5e                   	pop    %esi
  8020cc:	5d                   	pop    %ebp
  8020cd:	c3                   	ret    

008020ce <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 79 01 00 00       	call   802266 <nsipc_socket>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 05                	js     8020f6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8020f1:	e8 61 ff ff ff       	call   802057 <alloc_sockfd>
}
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8020fe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802101:	89 54 24 04          	mov    %edx,0x4(%esp)
  802105:	89 04 24             	mov    %eax,(%esp)
  802108:	e8 70 f6 ff ff       	call   80177d <fd_lookup>
  80210d:	85 c0                	test   %eax,%eax
  80210f:	78 15                	js     802126 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802111:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802114:	8b 0a                	mov    (%edx),%ecx
  802116:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80211b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  802121:	75 03                	jne    802126 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802123:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80212e:	8b 45 08             	mov    0x8(%ebp),%eax
  802131:	e8 c2 ff ff ff       	call   8020f8 <fd2sockid>
  802136:	85 c0                	test   %eax,%eax
  802138:	78 0f                	js     802149 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80213a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80213d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802141:	89 04 24             	mov    %eax,(%esp)
  802144:	e8 47 01 00 00       	call   802290 <nsipc_listen>
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802151:	8b 45 08             	mov    0x8(%ebp),%eax
  802154:	e8 9f ff ff ff       	call   8020f8 <fd2sockid>
  802159:	85 c0                	test   %eax,%eax
  80215b:	78 16                	js     802173 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80215d:	8b 55 10             	mov    0x10(%ebp),%edx
  802160:	89 54 24 08          	mov    %edx,0x8(%esp)
  802164:	8b 55 0c             	mov    0xc(%ebp),%edx
  802167:	89 54 24 04          	mov    %edx,0x4(%esp)
  80216b:	89 04 24             	mov    %eax,(%esp)
  80216e:	e8 6e 02 00 00       	call   8023e1 <nsipc_connect>
}
  802173:	c9                   	leave  
  802174:	c3                   	ret    

00802175 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80217b:	8b 45 08             	mov    0x8(%ebp),%eax
  80217e:	e8 75 ff ff ff       	call   8020f8 <fd2sockid>
  802183:	85 c0                	test   %eax,%eax
  802185:	78 0f                	js     802196 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80218a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80218e:	89 04 24             	mov    %eax,(%esp)
  802191:	e8 36 01 00 00       	call   8022cc <nsipc_shutdown>
}
  802196:	c9                   	leave  
  802197:	c3                   	ret    

00802198 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80219e:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a1:	e8 52 ff ff ff       	call   8020f8 <fd2sockid>
  8021a6:	85 c0                	test   %eax,%eax
  8021a8:	78 16                	js     8021c0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8021aa:	8b 55 10             	mov    0x10(%ebp),%edx
  8021ad:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b8:	89 04 24             	mov    %eax,(%esp)
  8021bb:	e8 60 02 00 00       	call   802420 <nsipc_bind>
}
  8021c0:	c9                   	leave  
  8021c1:	c3                   	ret    

008021c2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cb:	e8 28 ff ff ff       	call   8020f8 <fd2sockid>
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 1f                	js     8021f3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8021d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8021d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e2:	89 04 24             	mov    %eax,(%esp)
  8021e5:	e8 75 02 00 00       	call   80245f <nsipc_accept>
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	78 05                	js     8021f3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8021ee:	e8 64 fe ff ff       	call   802057 <alloc_sockfd>
}
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    
	...

00802200 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	53                   	push   %ebx
  802204:	83 ec 14             	sub    $0x14,%esp
  802207:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802209:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  802210:	75 11                	jne    802223 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802212:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802219:	e8 82 f3 ff ff       	call   8015a0 <ipc_find_env>
  80221e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802223:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80222a:	00 
  80222b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802232:	00 
  802233:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802237:	a1 04 40 80 00       	mov    0x804004,%eax
  80223c:	89 04 24             	mov    %eax,(%esp)
  80223f:	e8 a7 f3 ff ff       	call   8015eb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802244:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80224b:	00 
  80224c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802253:	00 
  802254:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80225b:	e8 09 f4 ff ff       	call   801669 <ipc_recv>
}
  802260:	83 c4 14             	add    $0x14,%esp
  802263:	5b                   	pop    %ebx
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80226c:	8b 45 08             	mov    0x8(%ebp),%eax
  80226f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802274:	8b 45 0c             	mov    0xc(%ebp),%eax
  802277:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80227c:	8b 45 10             	mov    0x10(%ebp),%eax
  80227f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802284:	b8 09 00 00 00       	mov    $0x9,%eax
  802289:	e8 72 ff ff ff       	call   802200 <nsipc>
}
  80228e:	c9                   	leave  
  80228f:	c3                   	ret    

00802290 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802296:	8b 45 08             	mov    0x8(%ebp),%eax
  802299:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80229e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8022a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8022ab:	e8 50 ff ff ff       	call   802200 <nsipc>
}
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8022c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8022c5:	e8 36 ff ff ff       	call   802200 <nsipc>
}
  8022ca:	c9                   	leave  
  8022cb:	c3                   	ret    

008022cc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8022da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022dd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8022e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022e7:	e8 14 ff ff ff       	call   802200 <nsipc>
}
  8022ec:	c9                   	leave  
  8022ed:	c3                   	ret    

008022ee <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022ee:	55                   	push   %ebp
  8022ef:	89 e5                	mov    %esp,%ebp
  8022f1:	53                   	push   %ebx
  8022f2:	83 ec 14             	sub    $0x14,%esp
  8022f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802300:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802306:	7e 24                	jle    80232c <nsipc_send+0x3e>
  802308:	c7 44 24 0c 58 2c 80 	movl   $0x802c58,0xc(%esp)
  80230f:	00 
  802310:	c7 44 24 08 64 2c 80 	movl   $0x802c64,0x8(%esp)
  802317:	00 
  802318:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80231f:	00 
  802320:	c7 04 24 79 2c 80 00 	movl   $0x802c79,(%esp)
  802327:	e8 88 01 00 00       	call   8024b4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80232c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802330:	8b 45 0c             	mov    0xc(%ebp),%eax
  802333:	89 44 24 04          	mov    %eax,0x4(%esp)
  802337:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80233e:	e8 72 e9 ff ff       	call   800cb5 <memmove>
	nsipcbuf.send.req_size = size;
  802343:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802349:	8b 45 14             	mov    0x14(%ebp),%eax
  80234c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802351:	b8 08 00 00 00       	mov    $0x8,%eax
  802356:	e8 a5 fe ff ff       	call   802200 <nsipc>
}
  80235b:	83 c4 14             	add    $0x14,%esp
  80235e:	5b                   	pop    %ebx
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    

00802361 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	56                   	push   %esi
  802365:	53                   	push   %ebx
  802366:	83 ec 10             	sub    $0x10,%esp
  802369:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80236c:	8b 45 08             	mov    0x8(%ebp),%eax
  80236f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802374:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80237a:	8b 45 14             	mov    0x14(%ebp),%eax
  80237d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802382:	b8 07 00 00 00       	mov    $0x7,%eax
  802387:	e8 74 fe ff ff       	call   802200 <nsipc>
  80238c:	89 c3                	mov    %eax,%ebx
  80238e:	85 c0                	test   %eax,%eax
  802390:	78 46                	js     8023d8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802392:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802397:	7f 04                	jg     80239d <nsipc_recv+0x3c>
  802399:	39 c6                	cmp    %eax,%esi
  80239b:	7d 24                	jge    8023c1 <nsipc_recv+0x60>
  80239d:	c7 44 24 0c 85 2c 80 	movl   $0x802c85,0xc(%esp)
  8023a4:	00 
  8023a5:	c7 44 24 08 64 2c 80 	movl   $0x802c64,0x8(%esp)
  8023ac:	00 
  8023ad:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8023b4:	00 
  8023b5:	c7 04 24 79 2c 80 00 	movl   $0x802c79,(%esp)
  8023bc:	e8 f3 00 00 00       	call   8024b4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023c5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8023cc:	00 
  8023cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d0:	89 04 24             	mov    %eax,(%esp)
  8023d3:	e8 dd e8 ff ff       	call   800cb5 <memmove>
	}

	return r;
}
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    

008023e1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	53                   	push   %ebx
  8023e5:	83 ec 14             	sub    $0x14,%esp
  8023e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8023eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ee:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8023f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023fe:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802405:	e8 ab e8 ff ff       	call   800cb5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80240a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802410:	b8 05 00 00 00       	mov    $0x5,%eax
  802415:	e8 e6 fd ff ff       	call   802200 <nsipc>
}
  80241a:	83 c4 14             	add    $0x14,%esp
  80241d:	5b                   	pop    %ebx
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    

00802420 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	53                   	push   %ebx
  802424:	83 ec 14             	sub    $0x14,%esp
  802427:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80242a:	8b 45 08             	mov    0x8(%ebp),%eax
  80242d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802432:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802436:	8b 45 0c             	mov    0xc(%ebp),%eax
  802439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80243d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802444:	e8 6c e8 ff ff       	call   800cb5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802449:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80244f:	b8 02 00 00 00       	mov    $0x2,%eax
  802454:	e8 a7 fd ff ff       	call   802200 <nsipc>
}
  802459:	83 c4 14             	add    $0x14,%esp
  80245c:	5b                   	pop    %ebx
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    

0080245f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	83 ec 18             	sub    $0x18,%esp
  802465:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802468:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80246b:	8b 45 08             	mov    0x8(%ebp),%eax
  80246e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802473:	b8 01 00 00 00       	mov    $0x1,%eax
  802478:	e8 83 fd ff ff       	call   802200 <nsipc>
  80247d:	89 c3                	mov    %eax,%ebx
  80247f:	85 c0                	test   %eax,%eax
  802481:	78 25                	js     8024a8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802483:	be 10 60 80 00       	mov    $0x806010,%esi
  802488:	8b 06                	mov    (%esi),%eax
  80248a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80248e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802495:	00 
  802496:	8b 45 0c             	mov    0xc(%ebp),%eax
  802499:	89 04 24             	mov    %eax,(%esp)
  80249c:	e8 14 e8 ff ff       	call   800cb5 <memmove>
		*addrlen = ret->ret_addrlen;
  8024a1:	8b 16                	mov    (%esi),%edx
  8024a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8024a6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8024a8:	89 d8                	mov    %ebx,%eax
  8024aa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8024ad:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8024b0:	89 ec                	mov    %ebp,%esp
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    

008024b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
  8024b7:	56                   	push   %esi
  8024b8:	53                   	push   %ebx
  8024b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8024bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8024bf:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8024c5:	e8 1d f0 ff ff       	call   8014e7 <sys_getenvid>
  8024ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8024d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e0:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  8024e7:	e8 ad dc ff ff       	call   800199 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8024ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8024f3:	89 04 24             	mov    %eax,(%esp)
  8024f6:	e8 3d dc ff ff       	call   800138 <vcprintf>
	cprintf("\n");
  8024fb:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  802502:	e8 92 dc ff ff       	call   800199 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802507:	cc                   	int3   
  802508:	eb fd                	jmp    802507 <_panic+0x53>
	...

0080250c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80250c:	55                   	push   %ebp
  80250d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80250f:	8b 45 08             	mov    0x8(%ebp),%eax
  802512:	89 c2                	mov    %eax,%edx
  802514:	c1 ea 16             	shr    $0x16,%edx
  802517:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80251e:	f6 c2 01             	test   $0x1,%dl
  802521:	74 20                	je     802543 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802523:	c1 e8 0c             	shr    $0xc,%eax
  802526:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80252d:	a8 01                	test   $0x1,%al
  80252f:	74 12                	je     802543 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802531:	c1 e8 0c             	shr    $0xc,%eax
  802534:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802539:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80253e:	0f b7 c0             	movzwl %ax,%eax
  802541:	eb 05                	jmp    802548 <pageref+0x3c>
  802543:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802548:	5d                   	pop    %ebp
  802549:	c3                   	ret    
  80254a:	00 00                	add    %al,(%eax)
  80254c:	00 00                	add    %al,(%eax)
	...

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	57                   	push   %edi
  802554:	56                   	push   %esi
  802555:	83 ec 10             	sub    $0x10,%esp
  802558:	8b 45 14             	mov    0x14(%ebp),%eax
  80255b:	8b 55 08             	mov    0x8(%ebp),%edx
  80255e:	8b 75 10             	mov    0x10(%ebp),%esi
  802561:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802564:	85 c0                	test   %eax,%eax
  802566:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802569:	75 35                	jne    8025a0 <__udivdi3+0x50>
  80256b:	39 fe                	cmp    %edi,%esi
  80256d:	77 61                	ja     8025d0 <__udivdi3+0x80>
  80256f:	85 f6                	test   %esi,%esi
  802571:	75 0b                	jne    80257e <__udivdi3+0x2e>
  802573:	b8 01 00 00 00       	mov    $0x1,%eax
  802578:	31 d2                	xor    %edx,%edx
  80257a:	f7 f6                	div    %esi
  80257c:	89 c6                	mov    %eax,%esi
  80257e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802581:	31 d2                	xor    %edx,%edx
  802583:	89 f8                	mov    %edi,%eax
  802585:	f7 f6                	div    %esi
  802587:	89 c7                	mov    %eax,%edi
  802589:	89 c8                	mov    %ecx,%eax
  80258b:	f7 f6                	div    %esi
  80258d:	89 c1                	mov    %eax,%ecx
  80258f:	89 fa                	mov    %edi,%edx
  802591:	89 c8                	mov    %ecx,%eax
  802593:	83 c4 10             	add    $0x10,%esp
  802596:	5e                   	pop    %esi
  802597:	5f                   	pop    %edi
  802598:	5d                   	pop    %ebp
  802599:	c3                   	ret    
  80259a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a0:	39 f8                	cmp    %edi,%eax
  8025a2:	77 1c                	ja     8025c0 <__udivdi3+0x70>
  8025a4:	0f bd d0             	bsr    %eax,%edx
  8025a7:	83 f2 1f             	xor    $0x1f,%edx
  8025aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8025ad:	75 39                	jne    8025e8 <__udivdi3+0x98>
  8025af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8025b2:	0f 86 a0 00 00 00    	jbe    802658 <__udivdi3+0x108>
  8025b8:	39 f8                	cmp    %edi,%eax
  8025ba:	0f 82 98 00 00 00    	jb     802658 <__udivdi3+0x108>
  8025c0:	31 ff                	xor    %edi,%edi
  8025c2:	31 c9                	xor    %ecx,%ecx
  8025c4:	89 c8                	mov    %ecx,%eax
  8025c6:	89 fa                	mov    %edi,%edx
  8025c8:	83 c4 10             	add    $0x10,%esp
  8025cb:	5e                   	pop    %esi
  8025cc:	5f                   	pop    %edi
  8025cd:	5d                   	pop    %ebp
  8025ce:	c3                   	ret    
  8025cf:	90                   	nop
  8025d0:	89 d1                	mov    %edx,%ecx
  8025d2:	89 fa                	mov    %edi,%edx
  8025d4:	89 c8                	mov    %ecx,%eax
  8025d6:	31 ff                	xor    %edi,%edi
  8025d8:	f7 f6                	div    %esi
  8025da:	89 c1                	mov    %eax,%ecx
  8025dc:	89 fa                	mov    %edi,%edx
  8025de:	89 c8                	mov    %ecx,%eax
  8025e0:	83 c4 10             	add    $0x10,%esp
  8025e3:	5e                   	pop    %esi
  8025e4:	5f                   	pop    %edi
  8025e5:	5d                   	pop    %ebp
  8025e6:	c3                   	ret    
  8025e7:	90                   	nop
  8025e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025ec:	89 f2                	mov    %esi,%edx
  8025ee:	d3 e0                	shl    %cl,%eax
  8025f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8025f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8025f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8025fb:	89 c1                	mov    %eax,%ecx
  8025fd:	d3 ea                	shr    %cl,%edx
  8025ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802603:	0b 55 ec             	or     -0x14(%ebp),%edx
  802606:	d3 e6                	shl    %cl,%esi
  802608:	89 c1                	mov    %eax,%ecx
  80260a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80260d:	89 fe                	mov    %edi,%esi
  80260f:	d3 ee                	shr    %cl,%esi
  802611:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802615:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802618:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80261b:	d3 e7                	shl    %cl,%edi
  80261d:	89 c1                	mov    %eax,%ecx
  80261f:	d3 ea                	shr    %cl,%edx
  802621:	09 d7                	or     %edx,%edi
  802623:	89 f2                	mov    %esi,%edx
  802625:	89 f8                	mov    %edi,%eax
  802627:	f7 75 ec             	divl   -0x14(%ebp)
  80262a:	89 d6                	mov    %edx,%esi
  80262c:	89 c7                	mov    %eax,%edi
  80262e:	f7 65 e8             	mull   -0x18(%ebp)
  802631:	39 d6                	cmp    %edx,%esi
  802633:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802636:	72 30                	jb     802668 <__udivdi3+0x118>
  802638:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80263b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80263f:	d3 e2                	shl    %cl,%edx
  802641:	39 c2                	cmp    %eax,%edx
  802643:	73 05                	jae    80264a <__udivdi3+0xfa>
  802645:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802648:	74 1e                	je     802668 <__udivdi3+0x118>
  80264a:	89 f9                	mov    %edi,%ecx
  80264c:	31 ff                	xor    %edi,%edi
  80264e:	e9 71 ff ff ff       	jmp    8025c4 <__udivdi3+0x74>
  802653:	90                   	nop
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	31 ff                	xor    %edi,%edi
  80265a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80265f:	e9 60 ff ff ff       	jmp    8025c4 <__udivdi3+0x74>
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80266b:	31 ff                	xor    %edi,%edi
  80266d:	89 c8                	mov    %ecx,%eax
  80266f:	89 fa                	mov    %edi,%edx
  802671:	83 c4 10             	add    $0x10,%esp
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
	...

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	57                   	push   %edi
  802684:	56                   	push   %esi
  802685:	83 ec 20             	sub    $0x20,%esp
  802688:	8b 55 14             	mov    0x14(%ebp),%edx
  80268b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80268e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802691:	8b 75 0c             	mov    0xc(%ebp),%esi
  802694:	85 d2                	test   %edx,%edx
  802696:	89 c8                	mov    %ecx,%eax
  802698:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80269b:	75 13                	jne    8026b0 <__umoddi3+0x30>
  80269d:	39 f7                	cmp    %esi,%edi
  80269f:	76 3f                	jbe    8026e0 <__umoddi3+0x60>
  8026a1:	89 f2                	mov    %esi,%edx
  8026a3:	f7 f7                	div    %edi
  8026a5:	89 d0                	mov    %edx,%eax
  8026a7:	31 d2                	xor    %edx,%edx
  8026a9:	83 c4 20             	add    $0x20,%esp
  8026ac:	5e                   	pop    %esi
  8026ad:	5f                   	pop    %edi
  8026ae:	5d                   	pop    %ebp
  8026af:	c3                   	ret    
  8026b0:	39 f2                	cmp    %esi,%edx
  8026b2:	77 4c                	ja     802700 <__umoddi3+0x80>
  8026b4:	0f bd ca             	bsr    %edx,%ecx
  8026b7:	83 f1 1f             	xor    $0x1f,%ecx
  8026ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8026bd:	75 51                	jne    802710 <__umoddi3+0x90>
  8026bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8026c2:	0f 87 e0 00 00 00    	ja     8027a8 <__umoddi3+0x128>
  8026c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026cb:	29 f8                	sub    %edi,%eax
  8026cd:	19 d6                	sbb    %edx,%esi
  8026cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8026d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026d5:	89 f2                	mov    %esi,%edx
  8026d7:	83 c4 20             	add    $0x20,%esp
  8026da:	5e                   	pop    %esi
  8026db:	5f                   	pop    %edi
  8026dc:	5d                   	pop    %ebp
  8026dd:	c3                   	ret    
  8026de:	66 90                	xchg   %ax,%ax
  8026e0:	85 ff                	test   %edi,%edi
  8026e2:	75 0b                	jne    8026ef <__umoddi3+0x6f>
  8026e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e9:	31 d2                	xor    %edx,%edx
  8026eb:	f7 f7                	div    %edi
  8026ed:	89 c7                	mov    %eax,%edi
  8026ef:	89 f0                	mov    %esi,%eax
  8026f1:	31 d2                	xor    %edx,%edx
  8026f3:	f7 f7                	div    %edi
  8026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f8:	f7 f7                	div    %edi
  8026fa:	eb a9                	jmp    8026a5 <__umoddi3+0x25>
  8026fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 f2                	mov    %esi,%edx
  802704:	83 c4 20             	add    $0x20,%esp
  802707:	5e                   	pop    %esi
  802708:	5f                   	pop    %edi
  802709:	5d                   	pop    %ebp
  80270a:	c3                   	ret    
  80270b:	90                   	nop
  80270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802710:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802714:	d3 e2                	shl    %cl,%edx
  802716:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802719:	ba 20 00 00 00       	mov    $0x20,%edx
  80271e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802721:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802724:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802728:	89 fa                	mov    %edi,%edx
  80272a:	d3 ea                	shr    %cl,%edx
  80272c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802730:	0b 55 f4             	or     -0xc(%ebp),%edx
  802733:	d3 e7                	shl    %cl,%edi
  802735:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802739:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80273c:	89 f2                	mov    %esi,%edx
  80273e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802741:	89 c7                	mov    %eax,%edi
  802743:	d3 ea                	shr    %cl,%edx
  802745:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802749:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80274c:	89 c2                	mov    %eax,%edx
  80274e:	d3 e6                	shl    %cl,%esi
  802750:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802754:	d3 ea                	shr    %cl,%edx
  802756:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80275a:	09 d6                	or     %edx,%esi
  80275c:	89 f0                	mov    %esi,%eax
  80275e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802761:	d3 e7                	shl    %cl,%edi
  802763:	89 f2                	mov    %esi,%edx
  802765:	f7 75 f4             	divl   -0xc(%ebp)
  802768:	89 d6                	mov    %edx,%esi
  80276a:	f7 65 e8             	mull   -0x18(%ebp)
  80276d:	39 d6                	cmp    %edx,%esi
  80276f:	72 2b                	jb     80279c <__umoddi3+0x11c>
  802771:	39 c7                	cmp    %eax,%edi
  802773:	72 23                	jb     802798 <__umoddi3+0x118>
  802775:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802779:	29 c7                	sub    %eax,%edi
  80277b:	19 d6                	sbb    %edx,%esi
  80277d:	89 f0                	mov    %esi,%eax
  80277f:	89 f2                	mov    %esi,%edx
  802781:	d3 ef                	shr    %cl,%edi
  802783:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802787:	d3 e0                	shl    %cl,%eax
  802789:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80278d:	09 f8                	or     %edi,%eax
  80278f:	d3 ea                	shr    %cl,%edx
  802791:	83 c4 20             	add    $0x20,%esp
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    
  802798:	39 d6                	cmp    %edx,%esi
  80279a:	75 d9                	jne    802775 <__umoddi3+0xf5>
  80279c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80279f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8027a2:	eb d1                	jmp    802775 <__umoddi3+0xf5>
  8027a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a8:	39 f2                	cmp    %esi,%edx
  8027aa:	0f 82 18 ff ff ff    	jb     8026c8 <__umoddi3+0x48>
  8027b0:	e9 1d ff ff ff       	jmp    8026d2 <__umoddi3+0x52>
