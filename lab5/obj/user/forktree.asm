
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 38             	sub    $0x38,%esp
  80003a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80003d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800043:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800047:	89 1c 24             	mov    %ebx,(%esp)
  80004a:	e8 61 0a 00 00       	call   800ab0 <strlen>
  80004f:	83 f8 02             	cmp    $0x2,%eax
  800052:	7f 41                	jg     800095 <forkchild+0x61>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800054:	89 f0                	mov    %esi,%eax
  800056:	0f be f0             	movsbl %al,%esi
  800059:	89 74 24 10          	mov    %esi,0x10(%esp)
  80005d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800061:	c7 44 24 08 c0 25 80 	movl   $0x8025c0,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  800070:	00 
  800071:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800074:	89 04 24             	mov    %eax,(%esp)
  800077:	e8 e3 09 00 00       	call   800a5f <snprintf>
	if (fork() == 0) {
  80007c:	e8 61 14 00 00       	call   8014e2 <fork>
  800081:	85 c0                	test   %eax,%eax
  800083:	75 10                	jne    800095 <forkchild+0x61>
		forktree(nxt);
  800085:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 0f 00 00 00       	call   80009f <forktree>
		exit();
  800090:	e8 bb 00 00 00       	call   800150 <exit>
	}
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <forktree>:

void
forktree(const char *cur)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 14             	sub    $0x14,%esp
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  8000a9:	e8 64 13 00 00       	call   801412 <sys_getenvid>
  8000ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b6:	c7 04 24 c5 25 80 00 	movl   $0x8025c5,(%esp)
  8000bd:	e8 0b 01 00 00       	call   8001cd <cprintf>

	forkchild(cur, '0');
  8000c2:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8000c9:	00 
  8000ca:	89 1c 24             	mov    %ebx,(%esp)
  8000cd:	e8 62 ff ff ff       	call   800034 <forkchild>
	forkchild(cur, '1');
  8000d2:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8000d9:	00 
  8000da:	89 1c 24             	mov    %ebx,(%esp)
  8000dd:	e8 52 ff ff ff       	call   800034 <forkchild>
}
  8000e2:	83 c4 14             	add    $0x14,%esp
  8000e5:	5b                   	pop    %ebx
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <umain>:

void
umain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000ee:	c7 04 24 d5 25 80 00 	movl   $0x8025d5,(%esp)
  8000f5:	e8 a5 ff ff ff       	call   80009f <forktree>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800105:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800108:	8b 75 08             	mov    0x8(%ebp),%esi
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80010e:	e8 ff 12 00 00       	call   801412 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	89 c2                	mov    %eax,%edx
  80011a:	c1 e2 07             	shl    $0x7,%edx
  80011d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800124:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800129:	85 f6                	test   %esi,%esi
  80012b:	7e 07                	jle    800134 <libmain+0x38>
		binaryname = argv[0];
  80012d:	8b 03                	mov    (%ebx),%eax
  80012f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800138:	89 34 24             	mov    %esi,(%esp)
  80013b:	e8 a8 ff ff ff       	call   8000e8 <umain>

	// exit gracefully
	exit();
  800140:	e8 0b 00 00 00       	call   800150 <exit>
}
  800145:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800148:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80014b:	89 ec                	mov    %ebp,%esp
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800156:	e8 f0 1b 00 00       	call   801d4b <close_all>
	sys_env_destroy(0);
  80015b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800162:	e8 eb 12 00 00       	call   801452 <sys_env_destroy>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800175:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017c:	00 00 00 
	b.cnt = 0;
  80017f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800186:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800189:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
  800193:	89 44 24 08          	mov    %eax,0x8(%esp)
  800197:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a1:	c7 04 24 e7 01 80 00 	movl   $0x8001e7,(%esp)
  8001a8:	e8 cf 01 00 00       	call   80037c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ad:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 67 0d 00 00       	call   800f2c <sys_cputs>

	return b.cnt;
}
  8001c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001d3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	89 04 24             	mov    %eax,(%esp)
  8001e0:	e8 87 ff ff ff       	call   80016c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 14             	sub    $0x14,%esp
  8001ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f1:	8b 03                	mov    (%ebx),%eax
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001fa:	83 c0 01             	add    $0x1,%eax
  8001fd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800204:	75 19                	jne    80021f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800206:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80020d:	00 
  80020e:	8d 43 08             	lea    0x8(%ebx),%eax
  800211:	89 04 24             	mov    %eax,(%esp)
  800214:	e8 13 0d 00 00       	call   800f2c <sys_cputs>
		b->idx = 0;
  800219:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80021f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800223:	83 c4 14             	add    $0x14,%esp
  800226:	5b                   	pop    %ebx
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    
  800229:	00 00                	add    %al,(%eax)
  80022b:	00 00                	add    %al,(%eax)
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 4c             	sub    $0x4c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80024a:	8b 45 10             	mov    0x10(%ebp),%eax
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800250:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800253:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800256:	b9 00 00 00 00       	mov    $0x0,%ecx
  80025b:	39 d1                	cmp    %edx,%ecx
  80025d:	72 07                	jb     800266 <printnum_v2+0x36>
  80025f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800262:	39 d0                	cmp    %edx,%eax
  800264:	77 5f                	ja     8002c5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800266:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80026a:	83 eb 01             	sub    $0x1,%ebx
  80026d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800271:	89 44 24 08          	mov    %eax,0x8(%esp)
  800275:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800279:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80027d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800280:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800283:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800286:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800291:	00 
  800292:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80029b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029f:	e8 9c 20 00 00       	call   802340 <__udivdi3>
  8002a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b9:	89 f2                	mov    %esi,%edx
  8002bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002be:	e8 6d ff ff ff       	call   800230 <printnum_v2>
  8002c3:	eb 1e                	jmp    8002e3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8002c5:	83 ff 2d             	cmp    $0x2d,%edi
  8002c8:	74 19                	je     8002e3 <printnum_v2+0xb3>
		while (--width > 0)
  8002ca:	83 eb 01             	sub    $0x1,%ebx
  8002cd:	85 db                	test   %ebx,%ebx
  8002cf:	90                   	nop
  8002d0:	7e 11                	jle    8002e3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8002d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d6:	89 3c 24             	mov    %edi,(%esp)
  8002d9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8002dc:	83 eb 01             	sub    $0x1,%ebx
  8002df:	85 db                	test   %ebx,%ebx
  8002e1:	7f ef                	jg     8002d2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f9:	00 
  8002fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002fd:	89 14 24             	mov    %edx,(%esp)
  800300:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800303:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800307:	e8 64 21 00 00       	call   802470 <__umoddi3>
  80030c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800310:	0f be 80 e0 25 80 00 	movsbl 0x8025e0(%eax),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80031d:	83 c4 4c             	add    $0x4c,%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800328:	83 fa 01             	cmp    $0x1,%edx
  80032b:	7e 0e                	jle    80033b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800332:	89 08                	mov    %ecx,(%eax)
  800334:	8b 02                	mov    (%edx),%eax
  800336:	8b 52 04             	mov    0x4(%edx),%edx
  800339:	eb 22                	jmp    80035d <getuint+0x38>
	else if (lflag)
  80033b:	85 d2                	test   %edx,%edx
  80033d:	74 10                	je     80034f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	8d 4a 04             	lea    0x4(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 02                	mov    (%edx),%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
  80034d:	eb 0e                	jmp    80035d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 04             	lea    0x4(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800365:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	3b 50 04             	cmp    0x4(%eax),%edx
  80036e:	73 0a                	jae    80037a <sprintputch+0x1b>
		*b->buf++ = ch;
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	88 0a                	mov    %cl,(%edx)
  800375:	83 c2 01             	add    $0x1,%edx
  800378:	89 10                	mov    %edx,(%eax)
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
  800382:	83 ec 6c             	sub    $0x6c,%esp
  800385:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800388:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80038f:	eb 1a                	jmp    8003ab <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800391:	85 c0                	test   %eax,%eax
  800393:	0f 84 66 06 00 00    	je     8009ff <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800399:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	ff 55 08             	call   *0x8(%ebp)
  8003a6:	eb 03                	jmp    8003ab <vprintfmt+0x2f>
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	83 c7 01             	add    $0x1,%edi
  8003b1:	83 f8 25             	cmp    $0x25,%eax
  8003b4:	75 db                	jne    800391 <vprintfmt+0x15>
  8003b6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8003ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003c6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8003cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d2:	be 00 00 00 00       	mov    $0x0,%esi
  8003d7:	eb 06                	jmp    8003df <vprintfmt+0x63>
  8003d9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8003dd:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	0f b6 17             	movzbl (%edi),%edx
  8003e2:	0f b6 c2             	movzbl %dl,%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	8d 47 01             	lea    0x1(%edi),%eax
  8003eb:	83 ea 23             	sub    $0x23,%edx
  8003ee:	80 fa 55             	cmp    $0x55,%dl
  8003f1:	0f 87 60 05 00 00    	ja     800957 <vprintfmt+0x5db>
  8003f7:	0f b6 d2             	movzbl %dl,%edx
  8003fa:	ff 24 95 c0 27 80 00 	jmp    *0x8027c0(,%edx,4)
  800401:	b9 01 00 00 00       	mov    $0x1,%ecx
  800406:	eb d5                	jmp    8003dd <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800408:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80040b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80040e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800411:	8d 7a d0             	lea    -0x30(%edx),%edi
  800414:	83 ff 09             	cmp    $0x9,%edi
  800417:	76 08                	jbe    800421 <vprintfmt+0xa5>
  800419:	eb 40                	jmp    80045b <vprintfmt+0xdf>
  80041b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80041f:	eb bc                	jmp    8003dd <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800421:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800424:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800427:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80042b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80042e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800431:	83 ff 09             	cmp    $0x9,%edi
  800434:	76 eb                	jbe    800421 <vprintfmt+0xa5>
  800436:	eb 23                	jmp    80045b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800438:	8b 55 14             	mov    0x14(%ebp),%edx
  80043b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80043e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800441:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800443:	eb 16                	jmp    80045b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800445:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800448:	c1 fa 1f             	sar    $0x1f,%edx
  80044b:	f7 d2                	not    %edx
  80044d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800450:	eb 8b                	jmp    8003dd <vprintfmt+0x61>
  800452:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800459:	eb 82                	jmp    8003dd <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80045b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045f:	0f 89 78 ff ff ff    	jns    8003dd <vprintfmt+0x61>
  800465:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800468:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80046b:	e9 6d ff ff ff       	jmp    8003dd <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800470:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800473:	e9 65 ff ff ff       	jmp    8003dd <vprintfmt+0x61>
  800478:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 55 0c             	mov    0xc(%ebp),%edx
  800487:	89 54 24 04          	mov    %edx,0x4(%esp)
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	89 04 24             	mov    %eax,(%esp)
  800490:	ff 55 08             	call   *0x8(%ebp)
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800496:	e9 10 ff ff ff       	jmp    8003ab <vprintfmt+0x2f>
  80049b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	89 c2                	mov    %eax,%edx
  8004ab:	c1 fa 1f             	sar    $0x1f,%edx
  8004ae:	31 d0                	xor    %edx,%eax
  8004b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b2:	83 f8 0f             	cmp    $0xf,%eax
  8004b5:	7f 0b                	jg     8004c2 <vprintfmt+0x146>
  8004b7:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	75 26                	jne    8004e8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c6:	c7 44 24 08 f1 25 80 	movl   $0x8025f1,0x8(%esp)
  8004cd:	00 
  8004ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004d8:	89 1c 24             	mov    %ebx,(%esp)
  8004db:	e8 a7 05 00 00       	call   800a87 <printfmt>
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	e9 c3 fe ff ff       	jmp    8003ab <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ec:	c7 44 24 08 fa 25 80 	movl   $0x8025fa,0x8(%esp)
  8004f3:	00 
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fe:	89 14 24             	mov    %edx,(%esp)
  800501:	e8 81 05 00 00       	call   800a87 <printfmt>
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	e9 9d fe ff ff       	jmp    8003ab <vprintfmt+0x2f>
  80050e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800511:	89 c7                	mov    %eax,%edi
  800513:	89 d9                	mov    %ebx,%ecx
  800515:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800518:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 30                	mov    (%eax),%esi
  800526:	85 f6                	test   %esi,%esi
  800528:	75 05                	jne    80052f <vprintfmt+0x1b3>
  80052a:	be fd 25 80 00       	mov    $0x8025fd,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80052f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800533:	7e 06                	jle    80053b <vprintfmt+0x1bf>
  800535:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800539:	75 10                	jne    80054b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053b:	0f be 06             	movsbl (%esi),%eax
  80053e:	85 c0                	test   %eax,%eax
  800540:	0f 85 a2 00 00 00    	jne    8005e8 <vprintfmt+0x26c>
  800546:	e9 92 00 00 00       	jmp    8005dd <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054f:	89 34 24             	mov    %esi,(%esp)
  800552:	e8 74 05 00 00       	call   800acb <strnlen>
  800557:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80055a:	29 c2                	sub    %eax,%edx
  80055c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80055f:	85 d2                	test   %edx,%edx
  800561:	7e d8                	jle    80053b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800563:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800567:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80056a:	89 d3                	mov    %edx,%ebx
  80056c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80056f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800572:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800575:	89 ce                	mov    %ecx,%esi
  800577:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057b:	89 34 24             	mov    %esi,(%esp)
  80057e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	83 eb 01             	sub    $0x1,%ebx
  800584:	85 db                	test   %ebx,%ebx
  800586:	7f ef                	jg     800577 <vprintfmt+0x1fb>
  800588:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80058b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80058e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800591:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800598:	eb a1                	jmp    80053b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80059e:	74 1b                	je     8005bb <vprintfmt+0x23f>
  8005a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a3:	83 fa 5e             	cmp    $0x5e,%edx
  8005a6:	76 13                	jbe    8005bb <vprintfmt+0x23f>
					putch('?', putdat);
  8005a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	eb 0d                	jmp    8005c8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c2:	89 04 24             	mov    %eax,(%esp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c8:	83 ef 01             	sub    $0x1,%edi
  8005cb:	0f be 06             	movsbl (%esi),%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	74 05                	je     8005d7 <vprintfmt+0x25b>
  8005d2:	83 c6 01             	add    $0x1,%esi
  8005d5:	eb 1a                	jmp    8005f1 <vprintfmt+0x275>
  8005d7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005da:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	7f 1f                	jg     800602 <vprintfmt+0x286>
  8005e3:	e9 c0 fd ff ff       	jmp    8003a8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e8:	83 c6 01             	add    $0x1,%esi
  8005eb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005f1:	85 db                	test   %ebx,%ebx
  8005f3:	78 a5                	js     80059a <vprintfmt+0x21e>
  8005f5:	83 eb 01             	sub    $0x1,%ebx
  8005f8:	79 a0                	jns    80059a <vprintfmt+0x21e>
  8005fa:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005fd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800600:	eb db                	jmp    8005dd <vprintfmt+0x261>
  800602:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800605:	8b 75 0c             	mov    0xc(%ebp),%esi
  800608:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80060b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800612:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800619:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061b:	83 eb 01             	sub    $0x1,%ebx
  80061e:	85 db                	test   %ebx,%ebx
  800620:	7f ec                	jg     80060e <vprintfmt+0x292>
  800622:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800625:	e9 81 fd ff ff       	jmp    8003ab <vprintfmt+0x2f>
  80062a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062d:	83 fe 01             	cmp    $0x1,%esi
  800630:	7e 10                	jle    800642 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 08             	lea    0x8(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 18                	mov    (%eax),%ebx
  80063d:	8b 70 04             	mov    0x4(%eax),%esi
  800640:	eb 26                	jmp    800668 <vprintfmt+0x2ec>
	else if (lflag)
  800642:	85 f6                	test   %esi,%esi
  800644:	74 12                	je     800658 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 18                	mov    (%eax),%ebx
  800651:	89 de                	mov    %ebx,%esi
  800653:	c1 fe 1f             	sar    $0x1f,%esi
  800656:	eb 10                	jmp    800668 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 04             	lea    0x4(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)
  800661:	8b 18                	mov    (%eax),%ebx
  800663:	89 de                	mov    %ebx,%esi
  800665:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800668:	83 f9 01             	cmp    $0x1,%ecx
  80066b:	75 1e                	jne    80068b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80066d:	85 f6                	test   %esi,%esi
  80066f:	78 1a                	js     80068b <vprintfmt+0x30f>
  800671:	85 f6                	test   %esi,%esi
  800673:	7f 05                	jg     80067a <vprintfmt+0x2fe>
  800675:	83 fb 00             	cmp    $0x0,%ebx
  800678:	76 11                	jbe    80068b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80067a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80067d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800681:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800688:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80068b:	85 f6                	test   %esi,%esi
  80068d:	78 13                	js     8006a2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800692:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069d:	e9 da 00 00 00       	jmp    80077c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8006a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b3:	89 da                	mov    %ebx,%edx
  8006b5:	89 f1                	mov    %esi,%ecx
  8006b7:	f7 da                	neg    %edx
  8006b9:	83 d1 00             	adc    $0x0,%ecx
  8006bc:	f7 d9                	neg    %ecx
  8006be:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006c1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cc:	e9 ab 00 00 00       	jmp    80077c <vprintfmt+0x400>
  8006d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d4:	89 f2                	mov    %esi,%edx
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 47 fc ff ff       	call   800325 <getuint>
  8006de:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006e1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006ec:	e9 8b 00 00 00       	jmp    80077c <vprintfmt+0x400>
  8006f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006fb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800702:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800705:	89 f2                	mov    %esi,%edx
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	e8 16 fc ff ff       	call   800325 <getuint>
  80070f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800712:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800718:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80071d:	eb 5d                	jmp    80077c <vprintfmt+0x400>
  80071f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800725:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800729:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 50 04             	lea    0x4(%eax),%edx
  800747:	89 55 14             	mov    %edx,0x14(%ebp)
  80074a:	8b 10                	mov    (%eax),%edx
  80074c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800751:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800754:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80075f:	eb 1b                	jmp    80077c <vprintfmt+0x400>
  800761:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800764:	89 f2                	mov    %esi,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 b7 fb ff ff       	call   800325 <getuint>
  80076e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800771:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800777:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800780:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800783:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800786:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80078a:	77 09                	ja     800795 <vprintfmt+0x419>
  80078c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80078f:	0f 82 ac 00 00 00    	jb     800841 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800795:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800798:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80079c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079f:	83 ea 01             	sub    $0x1,%edx
  8007a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007aa:	8b 44 24 08          	mov    0x8(%esp),%eax
  8007ae:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8007b2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8007b5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8007b8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007c6:	00 
  8007c7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007ca:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007cd:	89 0c 24             	mov    %ecx,(%esp)
  8007d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d4:	e8 67 1b 00 00       	call   802340 <__udivdi3>
  8007d9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8007dc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8007df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	e8 37 fa ff ff       	call   800230 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	8b 74 24 04          	mov    0x4(%esp),%esi
  800804:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800807:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800812:	00 
  800813:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800816:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800819:	89 14 24             	mov    %edx,(%esp)
  80081c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800820:	e8 4b 1c 00 00       	call   802470 <__umoddi3>
  800825:	89 74 24 04          	mov    %esi,0x4(%esp)
  800829:	0f be 80 e0 25 80 00 	movsbl 0x8025e0(%eax),%eax
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800836:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80083a:	74 54                	je     800890 <vprintfmt+0x514>
  80083c:	e9 67 fb ff ff       	jmp    8003a8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800841:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800845:	8d 76 00             	lea    0x0(%esi),%esi
  800848:	0f 84 2a 01 00 00    	je     800978 <vprintfmt+0x5fc>
		while (--width > 0)
  80084e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800851:	83 ef 01             	sub    $0x1,%edi
  800854:	85 ff                	test   %edi,%edi
  800856:	0f 8e 5e 01 00 00    	jle    8009ba <vprintfmt+0x63e>
  80085c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80085f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800862:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800865:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800868:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80086b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80086e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800872:	89 1c 24             	mov    %ebx,(%esp)
  800875:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800878:	83 ef 01             	sub    $0x1,%edi
  80087b:	85 ff                	test   %edi,%edi
  80087d:	7f ef                	jg     80086e <vprintfmt+0x4f2>
  80087f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800882:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800885:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800888:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80088b:	e9 2a 01 00 00       	jmp    8009ba <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800890:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800893:	83 eb 01             	sub    $0x1,%ebx
  800896:	85 db                	test   %ebx,%ebx
  800898:	0f 8e 0a fb ff ff    	jle    8003a8 <vprintfmt+0x2c>
  80089e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8008a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008b2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008b4:	83 eb 01             	sub    $0x1,%ebx
  8008b7:	85 db                	test   %ebx,%ebx
  8008b9:	7f ec                	jg     8008a7 <vprintfmt+0x52b>
  8008bb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008be:	e9 e8 fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
  8008c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	8d 50 04             	lea    0x4(%eax),%edx
  8008cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cf:	8b 00                	mov    (%eax),%eax
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	75 2a                	jne    8008ff <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8008d5:	c7 44 24 0c 18 27 80 	movl   $0x802718,0xc(%esp)
  8008dc:	00 
  8008dd:	c7 44 24 08 fa 25 80 	movl   $0x8025fa,0x8(%esp)
  8008e4:	00 
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ef:	89 0c 24             	mov    %ecx,(%esp)
  8008f2:	e8 90 01 00 00       	call   800a87 <printfmt>
  8008f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008fa:	e9 ac fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8008ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800902:	8b 13                	mov    (%ebx),%edx
  800904:	83 fa 7f             	cmp    $0x7f,%edx
  800907:	7e 29                	jle    800932 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800909:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80090b:	c7 44 24 0c 50 27 80 	movl   $0x802750,0xc(%esp)
  800912:	00 
  800913:	c7 44 24 08 fa 25 80 	movl   $0x8025fa,0x8(%esp)
  80091a:	00 
  80091b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	e8 5d 01 00 00       	call   800a87 <printfmt>
  80092a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092d:	e9 79 fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800932:	88 10                	mov    %dl,(%eax)
  800934:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800937:	e9 6f fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
  80093c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80093f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800945:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800949:	89 14 24             	mov    %edx,(%esp)
  80094c:	ff 55 08             	call   *0x8(%ebp)
  80094f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800952:	e9 54 fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800957:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800965:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800968:	8d 47 ff             	lea    -0x1(%edi),%eax
  80096b:	80 38 25             	cmpb   $0x25,(%eax)
  80096e:	0f 84 37 fa ff ff    	je     8003ab <vprintfmt+0x2f>
  800974:	89 c7                	mov    %eax,%edi
  800976:	eb f0                	jmp    800968 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800983:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800986:	89 54 24 08          	mov    %edx,0x8(%esp)
  80098a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800991:	00 
  800992:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800995:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800998:	89 04 24             	mov    %eax,(%esp)
  80099b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099f:	e8 cc 1a 00 00       	call   802470 <__umoddi3>
  8009a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a8:	0f be 80 e0 25 80 00 	movsbl 0x8025e0(%eax),%eax
  8009af:	89 04 24             	mov    %eax,(%esp)
  8009b2:	ff 55 08             	call   *0x8(%ebp)
  8009b5:	e9 d6 fe ff ff       	jmp    800890 <vprintfmt+0x514>
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009c1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009c5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009d3:	00 
  8009d4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009d7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009da:	89 04 24             	mov    %eax,(%esp)
  8009dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e1:	e8 8a 1a 00 00       	call   802470 <__umoddi3>
  8009e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ea:	0f be 80 e0 25 80 00 	movsbl 0x8025e0(%eax),%eax
  8009f1:	89 04 24             	mov    %eax,(%esp)
  8009f4:	ff 55 08             	call   *0x8(%ebp)
  8009f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009fa:	e9 ac f9 ff ff       	jmp    8003ab <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009ff:	83 c4 6c             	add    $0x6c,%esp
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	83 ec 28             	sub    $0x28,%esp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a13:	85 c0                	test   %eax,%eax
  800a15:	74 04                	je     800a1b <vsnprintf+0x14>
  800a17:	85 d2                	test   %edx,%edx
  800a19:	7f 07                	jg     800a22 <vsnprintf+0x1b>
  800a1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a20:	eb 3b                	jmp    800a5d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a25:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a33:	8b 45 14             	mov    0x14(%ebp),%eax
  800a36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a41:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a48:	c7 04 24 5f 03 80 00 	movl   $0x80035f,(%esp)
  800a4f:	e8 28 f9 ff ff       	call   80037c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a57:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a65:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	89 04 24             	mov    %eax,(%esp)
  800a80:	e8 82 ff ff ff       	call   800a07 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a8d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a94:	8b 45 10             	mov    0x10(%ebp),%eax
  800a97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	89 04 24             	mov    %eax,(%esp)
  800aa8:	e8 cf f8 ff ff       	call   80037c <vprintfmt>
	va_end(ap);
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    
	...

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	80 3a 00             	cmpb   $0x0,(%edx)
  800abe:	74 09                	je     800ac9 <strlen+0x19>
		n++;
  800ac0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac7:	75 f7                	jne    800ac0 <strlen+0x10>
		n++;
	return n;
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad5:	85 c9                	test   %ecx,%ecx
  800ad7:	74 19                	je     800af2 <strnlen+0x27>
  800ad9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800adc:	74 14                	je     800af2 <strnlen+0x27>
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ae3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae6:	39 c8                	cmp    %ecx,%eax
  800ae8:	74 0d                	je     800af7 <strnlen+0x2c>
  800aea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800aee:	75 f3                	jne    800ae3 <strnlen+0x18>
  800af0:	eb 05                	jmp    800af7 <strnlen+0x2c>
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800af7:	5b                   	pop    %ebx
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b10:	83 c2 01             	add    $0x1,%edx
  800b13:	84 c9                	test   %cl,%cl
  800b15:	75 f2                	jne    800b09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b17:	5b                   	pop    %ebx
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 08             	sub    $0x8,%esp
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b24:	89 1c 24             	mov    %ebx,(%esp)
  800b27:	e8 84 ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b33:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	e8 bc ff ff ff       	call   800afa <strcpy>
	return dst;
}
  800b3e:	89 d8                	mov    %ebx,%eax
  800b40:	83 c4 08             	add    $0x8,%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b54:	85 f6                	test   %esi,%esi
  800b56:	74 18                	je     800b70 <strncpy+0x2a>
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b5d:	0f b6 1a             	movzbl (%edx),%ebx
  800b60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b63:	80 3a 01             	cmpb   $0x1,(%edx)
  800b66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	39 ce                	cmp    %ecx,%esi
  800b6e:	77 ed                	ja     800b5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b82:	89 f0                	mov    %esi,%eax
  800b84:	85 c9                	test   %ecx,%ecx
  800b86:	74 27                	je     800baf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b88:	83 e9 01             	sub    $0x1,%ecx
  800b8b:	74 1d                	je     800baa <strlcpy+0x36>
  800b8d:	0f b6 1a             	movzbl (%edx),%ebx
  800b90:	84 db                	test   %bl,%bl
  800b92:	74 16                	je     800baa <strlcpy+0x36>
			*dst++ = *src++;
  800b94:	88 18                	mov    %bl,(%eax)
  800b96:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b99:	83 e9 01             	sub    $0x1,%ecx
  800b9c:	74 0e                	je     800bac <strlcpy+0x38>
			*dst++ = *src++;
  800b9e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba1:	0f b6 1a             	movzbl (%edx),%ebx
  800ba4:	84 db                	test   %bl,%bl
  800ba6:	75 ec                	jne    800b94 <strlcpy+0x20>
  800ba8:	eb 02                	jmp    800bac <strlcpy+0x38>
  800baa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bac:	c6 00 00             	movb   $0x0,(%eax)
  800baf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bbe:	0f b6 01             	movzbl (%ecx),%eax
  800bc1:	84 c0                	test   %al,%al
  800bc3:	74 15                	je     800bda <strcmp+0x25>
  800bc5:	3a 02                	cmp    (%edx),%al
  800bc7:	75 11                	jne    800bda <strcmp+0x25>
		p++, q++;
  800bc9:	83 c1 01             	add    $0x1,%ecx
  800bcc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bcf:	0f b6 01             	movzbl (%ecx),%eax
  800bd2:	84 c0                	test   %al,%al
  800bd4:	74 04                	je     800bda <strcmp+0x25>
  800bd6:	3a 02                	cmp    (%edx),%al
  800bd8:	74 ef                	je     800bc9 <strcmp+0x14>
  800bda:	0f b6 c0             	movzbl %al,%eax
  800bdd:	0f b6 12             	movzbl (%edx),%edx
  800be0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	53                   	push   %ebx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	74 23                	je     800c18 <strncmp+0x34>
  800bf5:	0f b6 1a             	movzbl (%edx),%ebx
  800bf8:	84 db                	test   %bl,%bl
  800bfa:	74 25                	je     800c21 <strncmp+0x3d>
  800bfc:	3a 19                	cmp    (%ecx),%bl
  800bfe:	75 21                	jne    800c21 <strncmp+0x3d>
  800c00:	83 e8 01             	sub    $0x1,%eax
  800c03:	74 13                	je     800c18 <strncmp+0x34>
		n--, p++, q++;
  800c05:	83 c2 01             	add    $0x1,%edx
  800c08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c0b:	0f b6 1a             	movzbl (%edx),%ebx
  800c0e:	84 db                	test   %bl,%bl
  800c10:	74 0f                	je     800c21 <strncmp+0x3d>
  800c12:	3a 19                	cmp    (%ecx),%bl
  800c14:	74 ea                	je     800c00 <strncmp+0x1c>
  800c16:	eb 09                	jmp    800c21 <strncmp+0x3d>
  800c18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5d                   	pop    %ebp
  800c1f:	90                   	nop
  800c20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c21:	0f b6 02             	movzbl (%edx),%eax
  800c24:	0f b6 11             	movzbl (%ecx),%edx
  800c27:	29 d0                	sub    %edx,%eax
  800c29:	eb f2                	jmp    800c1d <strncmp+0x39>

00800c2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c35:	0f b6 10             	movzbl (%eax),%edx
  800c38:	84 d2                	test   %dl,%dl
  800c3a:	74 18                	je     800c54 <strchr+0x29>
		if (*s == c)
  800c3c:	38 ca                	cmp    %cl,%dl
  800c3e:	75 0a                	jne    800c4a <strchr+0x1f>
  800c40:	eb 17                	jmp    800c59 <strchr+0x2e>
  800c42:	38 ca                	cmp    %cl,%dl
  800c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c48:	74 0f                	je     800c59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	0f b6 10             	movzbl (%eax),%edx
  800c50:	84 d2                	test   %dl,%dl
  800c52:	75 ee                	jne    800c42 <strchr+0x17>
  800c54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c65:	0f b6 10             	movzbl (%eax),%edx
  800c68:	84 d2                	test   %dl,%dl
  800c6a:	74 18                	je     800c84 <strfind+0x29>
		if (*s == c)
  800c6c:	38 ca                	cmp    %cl,%dl
  800c6e:	75 0a                	jne    800c7a <strfind+0x1f>
  800c70:	eb 12                	jmp    800c84 <strfind+0x29>
  800c72:	38 ca                	cmp    %cl,%dl
  800c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c78:	74 0a                	je     800c84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	0f b6 10             	movzbl (%eax),%edx
  800c80:	84 d2                	test   %dl,%dl
  800c82:	75 ee                	jne    800c72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	89 1c 24             	mov    %ebx,(%esp)
  800c8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ca0:	85 c9                	test   %ecx,%ecx
  800ca2:	74 30                	je     800cd4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ca4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800caa:	75 25                	jne    800cd1 <memset+0x4b>
  800cac:	f6 c1 03             	test   $0x3,%cl
  800caf:	75 20                	jne    800cd1 <memset+0x4b>
		c &= 0xFF;
  800cb1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	c1 e3 08             	shl    $0x8,%ebx
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	c1 e6 18             	shl    $0x18,%esi
  800cbe:	89 d0                	mov    %edx,%eax
  800cc0:	c1 e0 10             	shl    $0x10,%eax
  800cc3:	09 f0                	or     %esi,%eax
  800cc5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800cc7:	09 d8                	or     %ebx,%eax
  800cc9:	c1 e9 02             	shr    $0x2,%ecx
  800ccc:	fc                   	cld    
  800ccd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ccf:	eb 03                	jmp    800cd4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cd1:	fc                   	cld    
  800cd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cd4:	89 f8                	mov    %edi,%eax
  800cd6:	8b 1c 24             	mov    (%esp),%ebx
  800cd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cdd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce1:	89 ec                	mov    %ebp,%esp
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
  800ceb:	89 34 24             	mov    %esi,(%esp)
  800cee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cfb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800cfd:	39 c6                	cmp    %eax,%esi
  800cff:	73 35                	jae    800d36 <memmove+0x51>
  800d01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d04:	39 d0                	cmp    %edx,%eax
  800d06:	73 2e                	jae    800d36 <memmove+0x51>
		s += n;
		d += n;
  800d08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0a:	f6 c2 03             	test   $0x3,%dl
  800d0d:	75 1b                	jne    800d2a <memmove+0x45>
  800d0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d15:	75 13                	jne    800d2a <memmove+0x45>
  800d17:	f6 c1 03             	test   $0x3,%cl
  800d1a:	75 0e                	jne    800d2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d1c:	83 ef 04             	sub    $0x4,%edi
  800d1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d22:	c1 e9 02             	shr    $0x2,%ecx
  800d25:	fd                   	std    
  800d26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d28:	eb 09                	jmp    800d33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d2a:	83 ef 01             	sub    $0x1,%edi
  800d2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d30:	fd                   	std    
  800d31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d34:	eb 20                	jmp    800d56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d3c:	75 15                	jne    800d53 <memmove+0x6e>
  800d3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d44:	75 0d                	jne    800d53 <memmove+0x6e>
  800d46:	f6 c1 03             	test   $0x3,%cl
  800d49:	75 08                	jne    800d53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d4b:	c1 e9 02             	shr    $0x2,%ecx
  800d4e:	fc                   	cld    
  800d4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d51:	eb 03                	jmp    800d56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d53:	fc                   	cld    
  800d54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d56:	8b 34 24             	mov    (%esp),%esi
  800d59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d5d:	89 ec                	mov    %ebp,%esp
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d67:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	89 04 24             	mov    %eax,(%esp)
  800d7b:	e8 65 ff ff ff       	call   800ce5 <memmove>
}
  800d80:	c9                   	leave  
  800d81:	c3                   	ret    

00800d82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	8b 75 08             	mov    0x8(%ebp),%esi
  800d8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d91:	85 c9                	test   %ecx,%ecx
  800d93:	74 36                	je     800dcb <memcmp+0x49>
		if (*s1 != *s2)
  800d95:	0f b6 06             	movzbl (%esi),%eax
  800d98:	0f b6 1f             	movzbl (%edi),%ebx
  800d9b:	38 d8                	cmp    %bl,%al
  800d9d:	74 20                	je     800dbf <memcmp+0x3d>
  800d9f:	eb 14                	jmp    800db5 <memcmp+0x33>
  800da1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800da6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800dab:	83 c2 01             	add    $0x1,%edx
  800dae:	83 e9 01             	sub    $0x1,%ecx
  800db1:	38 d8                	cmp    %bl,%al
  800db3:	74 12                	je     800dc7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800db5:	0f b6 c0             	movzbl %al,%eax
  800db8:	0f b6 db             	movzbl %bl,%ebx
  800dbb:	29 d8                	sub    %ebx,%eax
  800dbd:	eb 11                	jmp    800dd0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbf:	83 e9 01             	sub    $0x1,%ecx
  800dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc7:	85 c9                	test   %ecx,%ecx
  800dc9:	75 d6                	jne    800da1 <memcmp+0x1f>
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ddb:	89 c2                	mov    %eax,%edx
  800ddd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800de0:	39 d0                	cmp    %edx,%eax
  800de2:	73 15                	jae    800df9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800de8:	38 08                	cmp    %cl,(%eax)
  800dea:	75 06                	jne    800df2 <memfind+0x1d>
  800dec:	eb 0b                	jmp    800df9 <memfind+0x24>
  800dee:	38 08                	cmp    %cl,(%eax)
  800df0:	74 07                	je     800df9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800df2:	83 c0 01             	add    $0x1,%eax
  800df5:	39 c2                	cmp    %eax,%edx
  800df7:	77 f5                	ja     800dee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0a:	0f b6 02             	movzbl (%edx),%eax
  800e0d:	3c 20                	cmp    $0x20,%al
  800e0f:	74 04                	je     800e15 <strtol+0x1a>
  800e11:	3c 09                	cmp    $0x9,%al
  800e13:	75 0e                	jne    800e23 <strtol+0x28>
		s++;
  800e15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e18:	0f b6 02             	movzbl (%edx),%eax
  800e1b:	3c 20                	cmp    $0x20,%al
  800e1d:	74 f6                	je     800e15 <strtol+0x1a>
  800e1f:	3c 09                	cmp    $0x9,%al
  800e21:	74 f2                	je     800e15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e23:	3c 2b                	cmp    $0x2b,%al
  800e25:	75 0c                	jne    800e33 <strtol+0x38>
		s++;
  800e27:	83 c2 01             	add    $0x1,%edx
  800e2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e31:	eb 15                	jmp    800e48 <strtol+0x4d>
	else if (*s == '-')
  800e33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e3a:	3c 2d                	cmp    $0x2d,%al
  800e3c:	75 0a                	jne    800e48 <strtol+0x4d>
		s++, neg = 1;
  800e3e:	83 c2 01             	add    $0x1,%edx
  800e41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e48:	85 db                	test   %ebx,%ebx
  800e4a:	0f 94 c0             	sete   %al
  800e4d:	74 05                	je     800e54 <strtol+0x59>
  800e4f:	83 fb 10             	cmp    $0x10,%ebx
  800e52:	75 18                	jne    800e6c <strtol+0x71>
  800e54:	80 3a 30             	cmpb   $0x30,(%edx)
  800e57:	75 13                	jne    800e6c <strtol+0x71>
  800e59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e5d:	8d 76 00             	lea    0x0(%esi),%esi
  800e60:	75 0a                	jne    800e6c <strtol+0x71>
		s += 2, base = 16;
  800e62:	83 c2 02             	add    $0x2,%edx
  800e65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e6a:	eb 15                	jmp    800e81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e6c:	84 c0                	test   %al,%al
  800e6e:	66 90                	xchg   %ax,%ax
  800e70:	74 0f                	je     800e81 <strtol+0x86>
  800e72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e77:	80 3a 30             	cmpb   $0x30,(%edx)
  800e7a:	75 05                	jne    800e81 <strtol+0x86>
		s++, base = 8;
  800e7c:	83 c2 01             	add    $0x1,%edx
  800e7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e88:	0f b6 0a             	movzbl (%edx),%ecx
  800e8b:	89 cf                	mov    %ecx,%edi
  800e8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e90:	80 fb 09             	cmp    $0x9,%bl
  800e93:	77 08                	ja     800e9d <strtol+0xa2>
			dig = *s - '0';
  800e95:	0f be c9             	movsbl %cl,%ecx
  800e98:	83 e9 30             	sub    $0x30,%ecx
  800e9b:	eb 1e                	jmp    800ebb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ea0:	80 fb 19             	cmp    $0x19,%bl
  800ea3:	77 08                	ja     800ead <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ea5:	0f be c9             	movsbl %cl,%ecx
  800ea8:	83 e9 57             	sub    $0x57,%ecx
  800eab:	eb 0e                	jmp    800ebb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ead:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800eb0:	80 fb 19             	cmp    $0x19,%bl
  800eb3:	77 15                	ja     800eca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800eb5:	0f be c9             	movsbl %cl,%ecx
  800eb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ebb:	39 f1                	cmp    %esi,%ecx
  800ebd:	7d 0b                	jge    800eca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ebf:	83 c2 01             	add    $0x1,%edx
  800ec2:	0f af c6             	imul   %esi,%eax
  800ec5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ec8:	eb be                	jmp    800e88 <strtol+0x8d>
  800eca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ecc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed0:	74 05                	je     800ed7 <strtol+0xdc>
		*endptr = (char *) s;
  800ed2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ed5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ed7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800edb:	74 04                	je     800ee1 <strtol+0xe6>
  800edd:	89 c8                	mov    %ecx,%eax
  800edf:	f7 d8                	neg    %eax
}
  800ee1:	83 c4 04             	add    $0x4,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	00 00                	add    %al,(%eax)
	...

00800eec <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
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
  800ef9:	ba 00 00 00 00       	mov    $0x0,%edx
  800efe:	b8 01 00 00 00       	mov    $0x1,%eax
  800f03:	89 d1                	mov    %edx,%ecx
  800f05:	89 d3                	mov    %edx,%ebx
  800f07:	89 d7                	mov    %edx,%edi
  800f09:	51                   	push   %ecx
  800f0a:	52                   	push   %edx
  800f0b:	53                   	push   %ebx
  800f0c:	54                   	push   %esp
  800f0d:	55                   	push   %ebp
  800f0e:	56                   	push   %esi
  800f0f:	57                   	push   %edi
  800f10:	54                   	push   %esp
  800f11:	5d                   	pop    %ebp
  800f12:	8d 35 1a 0f 80 00    	lea    0x800f1a,%esi
  800f18:	0f 34                	sysenter 
  800f1a:	5f                   	pop    %edi
  800f1b:	5e                   	pop    %esi
  800f1c:	5d                   	pop    %ebp
  800f1d:	5c                   	pop    %esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5a                   	pop    %edx
  800f20:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f21:	8b 1c 24             	mov    (%esp),%ebx
  800f24:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f28:	89 ec                	mov    %ebp,%esp
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 08             	sub    $0x8,%esp
  800f32:	89 1c 24             	mov    %ebx,(%esp)
  800f35:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	89 c7                	mov    %eax,%edi
  800f48:	51                   	push   %ecx
  800f49:	52                   	push   %edx
  800f4a:	53                   	push   %ebx
  800f4b:	54                   	push   %esp
  800f4c:	55                   	push   %ebp
  800f4d:	56                   	push   %esi
  800f4e:	57                   	push   %edi
  800f4f:	54                   	push   %esp
  800f50:	5d                   	pop    %ebp
  800f51:	8d 35 59 0f 80 00    	lea    0x800f59,%esi
  800f57:	0f 34                	sysenter 
  800f59:	5f                   	pop    %edi
  800f5a:	5e                   	pop    %esi
  800f5b:	5d                   	pop    %ebp
  800f5c:	5c                   	pop    %esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5a                   	pop    %edx
  800f5f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f60:	8b 1c 24             	mov    (%esp),%ebx
  800f63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f67:	89 ec                	mov    %ebp,%esp
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	89 1c 24             	mov    %ebx,(%esp)
  800f74:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f78:	b8 10 00 00 00       	mov    $0x10,%eax
  800f7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
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
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800fa1:	8b 1c 24             	mov    (%esp),%ebx
  800fa4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fa8:	89 ec                	mov    %ebp,%esp
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 28             	sub    $0x28,%esp
  800fb2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fb5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc8:	89 df                	mov    %ebx,%edi
  800fca:	51                   	push   %ecx
  800fcb:	52                   	push   %edx
  800fcc:	53                   	push   %ebx
  800fcd:	54                   	push   %esp
  800fce:	55                   	push   %ebp
  800fcf:	56                   	push   %esi
  800fd0:	57                   	push   %edi
  800fd1:	54                   	push   %esp
  800fd2:	5d                   	pop    %ebp
  800fd3:	8d 35 db 0f 80 00    	lea    0x800fdb,%esi
  800fd9:	0f 34                	sysenter 
  800fdb:	5f                   	pop    %edi
  800fdc:	5e                   	pop    %esi
  800fdd:	5d                   	pop    %ebp
  800fde:	5c                   	pop    %esp
  800fdf:	5b                   	pop    %ebx
  800fe0:	5a                   	pop    %edx
  800fe1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	7e 28                	jle    80100e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fea:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801001:	00 
  801002:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  801009:	e8 26 11 00 00       	call   802134 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80100e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801011:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801014:	89 ec                	mov    %ebp,%esp
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	89 1c 24             	mov    %ebx,(%esp)
  801021:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801025:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102a:	b8 11 00 00 00       	mov    $0x11,%eax
  80102f:	8b 55 08             	mov    0x8(%ebp),%edx
  801032:	89 cb                	mov    %ecx,%ebx
  801034:	89 cf                	mov    %ecx,%edi
  801036:	51                   	push   %ecx
  801037:	52                   	push   %edx
  801038:	53                   	push   %ebx
  801039:	54                   	push   %esp
  80103a:	55                   	push   %ebp
  80103b:	56                   	push   %esi
  80103c:	57                   	push   %edi
  80103d:	54                   	push   %esp
  80103e:	5d                   	pop    %ebp
  80103f:	8d 35 47 10 80 00    	lea    0x801047,%esi
  801045:	0f 34                	sysenter 
  801047:	5f                   	pop    %edi
  801048:	5e                   	pop    %esi
  801049:	5d                   	pop    %ebp
  80104a:	5c                   	pop    %esp
  80104b:	5b                   	pop    %ebx
  80104c:	5a                   	pop    %edx
  80104d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80104e:	8b 1c 24             	mov    (%esp),%ebx
  801051:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801055:	89 ec                	mov    %ebp,%esp
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	83 ec 28             	sub    $0x28,%esp
  80105f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801062:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801065:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80106f:	8b 55 08             	mov    0x8(%ebp),%edx
  801072:	89 cb                	mov    %ecx,%ebx
  801074:	89 cf                	mov    %ecx,%edi
  801076:	51                   	push   %ecx
  801077:	52                   	push   %edx
  801078:	53                   	push   %ebx
  801079:	54                   	push   %esp
  80107a:	55                   	push   %ebp
  80107b:	56                   	push   %esi
  80107c:	57                   	push   %edi
  80107d:	54                   	push   %esp
  80107e:	5d                   	pop    %ebp
  80107f:	8d 35 87 10 80 00    	lea    0x801087,%esi
  801085:	0f 34                	sysenter 
  801087:	5f                   	pop    %edi
  801088:	5e                   	pop    %esi
  801089:	5d                   	pop    %ebp
  80108a:	5c                   	pop    %esp
  80108b:	5b                   	pop    %ebx
  80108c:	5a                   	pop    %edx
  80108d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80108e:	85 c0                	test   %eax,%eax
  801090:	7e 28                	jle    8010ba <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801092:	89 44 24 10          	mov    %eax,0x10(%esp)
  801096:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80109d:	00 
  80109e:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010ad:	00 
  8010ae:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  8010b5:	e8 7a 10 00 00       	call   802134 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010ba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c0:	89 ec                	mov    %ebp,%esp
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	89 1c 24             	mov    %ebx,(%esp)
  8010cd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010d1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010df:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e2:	51                   	push   %ecx
  8010e3:	52                   	push   %edx
  8010e4:	53                   	push   %ebx
  8010e5:	54                   	push   %esp
  8010e6:	55                   	push   %ebp
  8010e7:	56                   	push   %esi
  8010e8:	57                   	push   %edi
  8010e9:	54                   	push   %esp
  8010ea:	5d                   	pop    %ebp
  8010eb:	8d 35 f3 10 80 00    	lea    0x8010f3,%esi
  8010f1:	0f 34                	sysenter 
  8010f3:	5f                   	pop    %edi
  8010f4:	5e                   	pop    %esi
  8010f5:	5d                   	pop    %ebp
  8010f6:	5c                   	pop    %esp
  8010f7:	5b                   	pop    %ebx
  8010f8:	5a                   	pop    %edx
  8010f9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010fa:	8b 1c 24             	mov    (%esp),%ebx
  8010fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801101:	89 ec                	mov    %ebp,%esp
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 28             	sub    $0x28,%esp
  80110b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80110e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801111:	bb 00 00 00 00       	mov    $0x0,%ebx
  801116:	b8 0b 00 00 00       	mov    $0xb,%eax
  80111b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111e:	8b 55 08             	mov    0x8(%ebp),%edx
  801121:	89 df                	mov    %ebx,%edi
  801123:	51                   	push   %ecx
  801124:	52                   	push   %edx
  801125:	53                   	push   %ebx
  801126:	54                   	push   %esp
  801127:	55                   	push   %ebp
  801128:	56                   	push   %esi
  801129:	57                   	push   %edi
  80112a:	54                   	push   %esp
  80112b:	5d                   	pop    %ebp
  80112c:	8d 35 34 11 80 00    	lea    0x801134,%esi
  801132:	0f 34                	sysenter 
  801134:	5f                   	pop    %edi
  801135:	5e                   	pop    %esi
  801136:	5d                   	pop    %ebp
  801137:	5c                   	pop    %esp
  801138:	5b                   	pop    %ebx
  801139:	5a                   	pop    %edx
  80113a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80113b:	85 c0                	test   %eax,%eax
  80113d:	7e 28                	jle    801167 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801143:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80114a:	00 
  80114b:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  801152:	00 
  801153:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80115a:	00 
  80115b:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  801162:	e8 cd 0f 00 00       	call   802134 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801167:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80116a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80116d:	89 ec                	mov    %ebp,%esp
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 28             	sub    $0x28,%esp
  801177:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80117a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80117d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801182:	b8 0a 00 00 00       	mov    $0xa,%eax
  801187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118a:	8b 55 08             	mov    0x8(%ebp),%edx
  80118d:	89 df                	mov    %ebx,%edi
  80118f:	51                   	push   %ecx
  801190:	52                   	push   %edx
  801191:	53                   	push   %ebx
  801192:	54                   	push   %esp
  801193:	55                   	push   %ebp
  801194:	56                   	push   %esi
  801195:	57                   	push   %edi
  801196:	54                   	push   %esp
  801197:	5d                   	pop    %ebp
  801198:	8d 35 a0 11 80 00    	lea    0x8011a0,%esi
  80119e:	0f 34                	sysenter 
  8011a0:	5f                   	pop    %edi
  8011a1:	5e                   	pop    %esi
  8011a2:	5d                   	pop    %ebp
  8011a3:	5c                   	pop    %esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5a                   	pop    %edx
  8011a6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	7e 28                	jle    8011d3 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011af:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011b6:	00 
  8011b7:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  8011be:	00 
  8011bf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011c6:	00 
  8011c7:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  8011ce:	e8 61 0f 00 00       	call   802134 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011d3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011d6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d9:	89 ec                	mov    %ebp,%esp
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	83 ec 28             	sub    $0x28,%esp
  8011e3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011e6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8011f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f9:	89 df                	mov    %ebx,%edi
  8011fb:	51                   	push   %ecx
  8011fc:	52                   	push   %edx
  8011fd:	53                   	push   %ebx
  8011fe:	54                   	push   %esp
  8011ff:	55                   	push   %ebp
  801200:	56                   	push   %esi
  801201:	57                   	push   %edi
  801202:	54                   	push   %esp
  801203:	5d                   	pop    %ebp
  801204:	8d 35 0c 12 80 00    	lea    0x80120c,%esi
  80120a:	0f 34                	sysenter 
  80120c:	5f                   	pop    %edi
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	5c                   	pop    %esp
  801210:	5b                   	pop    %ebx
  801211:	5a                   	pop    %edx
  801212:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801213:	85 c0                	test   %eax,%eax
  801215:	7e 28                	jle    80123f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801217:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801222:	00 
  801223:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  80122a:	00 
  80122b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801232:	00 
  801233:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  80123a:	e8 f5 0e 00 00       	call   802134 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80123f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801242:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801245:	89 ec                	mov    %ebp,%esp
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 28             	sub    $0x28,%esp
  80124f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801252:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125a:	b8 07 00 00 00       	mov    $0x7,%eax
  80125f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801262:	8b 55 08             	mov    0x8(%ebp),%edx
  801265:	89 df                	mov    %ebx,%edi
  801267:	51                   	push   %ecx
  801268:	52                   	push   %edx
  801269:	53                   	push   %ebx
  80126a:	54                   	push   %esp
  80126b:	55                   	push   %ebp
  80126c:	56                   	push   %esi
  80126d:	57                   	push   %edi
  80126e:	54                   	push   %esp
  80126f:	5d                   	pop    %ebp
  801270:	8d 35 78 12 80 00    	lea    0x801278,%esi
  801276:	0f 34                	sysenter 
  801278:	5f                   	pop    %edi
  801279:	5e                   	pop    %esi
  80127a:	5d                   	pop    %ebp
  80127b:	5c                   	pop    %esp
  80127c:	5b                   	pop    %ebx
  80127d:	5a                   	pop    %edx
  80127e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80127f:	85 c0                	test   %eax,%eax
  801281:	7e 28                	jle    8012ab <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801283:	89 44 24 10          	mov    %eax,0x10(%esp)
  801287:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80128e:	00 
  80128f:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  801296:	00 
  801297:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80129e:	00 
  80129f:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  8012a6:	e8 89 0e 00 00       	call   802134 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012ab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012b1:	89 ec                	mov    %ebp,%esp
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 28             	sub    $0x28,%esp
  8012bb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012be:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012c1:	8b 7d 18             	mov    0x18(%ebp),%edi
  8012c4:	0b 7d 14             	or     0x14(%ebp),%edi
  8012c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8012cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d5:	51                   	push   %ecx
  8012d6:	52                   	push   %edx
  8012d7:	53                   	push   %ebx
  8012d8:	54                   	push   %esp
  8012d9:	55                   	push   %ebp
  8012da:	56                   	push   %esi
  8012db:	57                   	push   %edi
  8012dc:	54                   	push   %esp
  8012dd:	5d                   	pop    %ebp
  8012de:	8d 35 e6 12 80 00    	lea    0x8012e6,%esi
  8012e4:	0f 34                	sysenter 
  8012e6:	5f                   	pop    %edi
  8012e7:	5e                   	pop    %esi
  8012e8:	5d                   	pop    %ebp
  8012e9:	5c                   	pop    %esp
  8012ea:	5b                   	pop    %ebx
  8012eb:	5a                   	pop    %edx
  8012ec:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	7e 28                	jle    801319 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012fc:	00 
  8012fd:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  801304:	00 
  801305:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80130c:	00 
  80130d:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  801314:	e8 1b 0e 00 00       	call   802134 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801319:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80131c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80131f:	89 ec                	mov    %ebp,%esp
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 28             	sub    $0x28,%esp
  801329:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80132c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80132f:	bf 00 00 00 00       	mov    $0x0,%edi
  801334:	b8 05 00 00 00       	mov    $0x5,%eax
  801339:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133f:	8b 55 08             	mov    0x8(%ebp),%edx
  801342:	51                   	push   %ecx
  801343:	52                   	push   %edx
  801344:	53                   	push   %ebx
  801345:	54                   	push   %esp
  801346:	55                   	push   %ebp
  801347:	56                   	push   %esi
  801348:	57                   	push   %edi
  801349:	54                   	push   %esp
  80134a:	5d                   	pop    %ebp
  80134b:	8d 35 53 13 80 00    	lea    0x801353,%esi
  801351:	0f 34                	sysenter 
  801353:	5f                   	pop    %edi
  801354:	5e                   	pop    %esi
  801355:	5d                   	pop    %ebp
  801356:	5c                   	pop    %esp
  801357:	5b                   	pop    %ebx
  801358:	5a                   	pop    %edx
  801359:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80135a:	85 c0                	test   %eax,%eax
  80135c:	7e 28                	jle    801386 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801362:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801369:	00 
  80136a:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  801371:	00 
  801372:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801379:	00 
  80137a:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  801381:	e8 ae 0d 00 00       	call   802134 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801386:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801389:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80138c:	89 ec                	mov    %ebp,%esp
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	89 1c 24             	mov    %ebx,(%esp)
  801399:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80139d:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013a7:	89 d1                	mov    %edx,%ecx
  8013a9:	89 d3                	mov    %edx,%ebx
  8013ab:	89 d7                	mov    %edx,%edi
  8013ad:	51                   	push   %ecx
  8013ae:	52                   	push   %edx
  8013af:	53                   	push   %ebx
  8013b0:	54                   	push   %esp
  8013b1:	55                   	push   %ebp
  8013b2:	56                   	push   %esi
  8013b3:	57                   	push   %edi
  8013b4:	54                   	push   %esp
  8013b5:	5d                   	pop    %ebp
  8013b6:	8d 35 be 13 80 00    	lea    0x8013be,%esi
  8013bc:	0f 34                	sysenter 
  8013be:	5f                   	pop    %edi
  8013bf:	5e                   	pop    %esi
  8013c0:	5d                   	pop    %ebp
  8013c1:	5c                   	pop    %esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5a                   	pop    %edx
  8013c4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8013c5:	8b 1c 24             	mov    (%esp),%ebx
  8013c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013cc:	89 ec                	mov    %ebp,%esp
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	89 1c 24             	mov    %ebx,(%esp)
  8013d9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e2:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ed:	89 df                	mov    %ebx,%edi
  8013ef:	51                   	push   %ecx
  8013f0:	52                   	push   %edx
  8013f1:	53                   	push   %ebx
  8013f2:	54                   	push   %esp
  8013f3:	55                   	push   %ebp
  8013f4:	56                   	push   %esi
  8013f5:	57                   	push   %edi
  8013f6:	54                   	push   %esp
  8013f7:	5d                   	pop    %ebp
  8013f8:	8d 35 00 14 80 00    	lea    0x801400,%esi
  8013fe:	0f 34                	sysenter 
  801400:	5f                   	pop    %edi
  801401:	5e                   	pop    %esi
  801402:	5d                   	pop    %ebp
  801403:	5c                   	pop    %esp
  801404:	5b                   	pop    %ebx
  801405:	5a                   	pop    %edx
  801406:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801407:	8b 1c 24             	mov    (%esp),%ebx
  80140a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80140e:	89 ec                	mov    %ebp,%esp
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	89 1c 24             	mov    %ebx,(%esp)
  80141b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80141f:	ba 00 00 00 00       	mov    $0x0,%edx
  801424:	b8 02 00 00 00       	mov    $0x2,%eax
  801429:	89 d1                	mov    %edx,%ecx
  80142b:	89 d3                	mov    %edx,%ebx
  80142d:	89 d7                	mov    %edx,%edi
  80142f:	51                   	push   %ecx
  801430:	52                   	push   %edx
  801431:	53                   	push   %ebx
  801432:	54                   	push   %esp
  801433:	55                   	push   %ebp
  801434:	56                   	push   %esi
  801435:	57                   	push   %edi
  801436:	54                   	push   %esp
  801437:	5d                   	pop    %ebp
  801438:	8d 35 40 14 80 00    	lea    0x801440,%esi
  80143e:	0f 34                	sysenter 
  801440:	5f                   	pop    %edi
  801441:	5e                   	pop    %esi
  801442:	5d                   	pop    %ebp
  801443:	5c                   	pop    %esp
  801444:	5b                   	pop    %ebx
  801445:	5a                   	pop    %edx
  801446:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801447:	8b 1c 24             	mov    (%esp),%ebx
  80144a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80144e:	89 ec                	mov    %ebp,%esp
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 28             	sub    $0x28,%esp
  801458:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80145b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80145e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801463:	b8 03 00 00 00       	mov    $0x3,%eax
  801468:	8b 55 08             	mov    0x8(%ebp),%edx
  80146b:	89 cb                	mov    %ecx,%ebx
  80146d:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801487:	85 c0                	test   %eax,%eax
  801489:	7e 28                	jle    8014b3 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80148b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80148f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801496:	00 
  801497:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  80149e:	00 
  80149f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014a6:	00 
  8014a7:	c7 04 24 7d 29 80 00 	movl   $0x80297d,(%esp)
  8014ae:	e8 81 0c 00 00       	call   802134 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014b9:	89 ec                	mov    %ebp,%esp
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    
  8014bd:	00 00                	add    %al,(%eax)
	...

008014c0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014c6:	c7 44 24 08 8b 29 80 	movl   $0x80298b,0x8(%esp)
  8014cd:	00 
  8014ce:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  8014d5:	00 
  8014d6:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  8014dd:	e8 52 0c 00 00       	call   802134 <_panic>

008014e2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	57                   	push   %edi
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  8014eb:	c7 04 24 37 17 80 00 	movl   $0x801737,(%esp)
  8014f2:	e8 95 0c 00 00       	call   80218c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014f7:	ba 08 00 00 00       	mov    $0x8,%edx
  8014fc:	89 d0                	mov    %edx,%eax
  8014fe:	cd 30                	int    $0x30
  801500:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801503:	85 c0                	test   %eax,%eax
  801505:	79 20                	jns    801527 <fork+0x45>
		panic("sys_exofork: %e", envid);
  801507:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150b:	c7 44 24 08 ac 29 80 	movl   $0x8029ac,0x8(%esp)
  801512:	00 
  801513:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80151a:	00 
  80151b:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  801522:	e8 0d 0c 00 00       	call   802134 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801527:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80152c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801531:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80153a:	75 20                	jne    80155c <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80153c:	e8 d1 fe ff ff       	call   801412 <sys_getenvid>
  801541:	25 ff 03 00 00       	and    $0x3ff,%eax
  801546:	89 c2                	mov    %eax,%edx
  801548:	c1 e2 07             	shl    $0x7,%edx
  80154b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801552:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801557:	e9 d0 01 00 00       	jmp    80172c <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80155c:	89 d8                	mov    %ebx,%eax
  80155e:	c1 e8 16             	shr    $0x16,%eax
  801561:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801564:	a8 01                	test   $0x1,%al
  801566:	0f 84 0d 01 00 00    	je     801679 <fork+0x197>
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	c1 e8 0c             	shr    $0xc,%eax
  801571:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801574:	f6 c2 01             	test   $0x1,%dl
  801577:	0f 84 fc 00 00 00    	je     801679 <fork+0x197>
  80157d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801580:	f6 c2 04             	test   $0x4,%dl
  801583:	0f 84 f0 00 00 00    	je     801679 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  801589:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  80158c:	89 c2                	mov    %eax,%edx
  80158e:	c1 ea 0c             	shr    $0xc,%edx
  801591:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801594:	f6 c2 01             	test   $0x1,%dl
  801597:	0f 84 dc 00 00 00    	je     801679 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  80159d:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8015a3:	0f 84 8d 00 00 00    	je     801636 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8015a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015ac:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8015b3:	00 
  8015b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ca:	e8 e6 fc ff ff       	call   8012b5 <sys_page_map>
               if(r<0)
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	79 1c                	jns    8015ef <fork+0x10d>
                 panic("map failed");
  8015d3:	c7 44 24 08 bc 29 80 	movl   $0x8029bc,0x8(%esp)
  8015da:	00 
  8015db:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8015e2:	00 
  8015e3:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  8015ea:	e8 45 0b 00 00       	call   802134 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  8015ef:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8015f6:	00 
  8015f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801605:	00 
  801606:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801611:	e8 9f fc ff ff       	call   8012b5 <sys_page_map>
               if(r<0)
  801616:	85 c0                	test   %eax,%eax
  801618:	79 5f                	jns    801679 <fork+0x197>
                 panic("map failed");
  80161a:	c7 44 24 08 bc 29 80 	movl   $0x8029bc,0x8(%esp)
  801621:	00 
  801622:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801629:	00 
  80162a:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  801631:	e8 fe 0a 00 00       	call   802134 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801636:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80163d:	00 
  80163e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801642:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801645:	89 54 24 08          	mov    %edx,0x8(%esp)
  801649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801654:	e8 5c fc ff ff       	call   8012b5 <sys_page_map>
               if(r<0)
  801659:	85 c0                	test   %eax,%eax
  80165b:	79 1c                	jns    801679 <fork+0x197>
                 panic("map failed");
  80165d:	c7 44 24 08 bc 29 80 	movl   $0x8029bc,0x8(%esp)
  801664:	00 
  801665:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80166c:	00 
  80166d:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  801674:	e8 bb 0a 00 00       	call   802134 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801679:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80167f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801685:	0f 85 d1 fe ff ff    	jne    80155c <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80168b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801692:	00 
  801693:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80169a:	ee 
  80169b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80169e:	89 04 24             	mov    %eax,(%esp)
  8016a1:	e8 7d fc ff ff       	call   801323 <sys_page_alloc>
        if(r < 0)
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	79 1c                	jns    8016c6 <fork+0x1e4>
            panic("alloc failed");
  8016aa:	c7 44 24 08 c7 29 80 	movl   $0x8029c7,0x8(%esp)
  8016b1:	00 
  8016b2:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8016b9:	00 
  8016ba:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  8016c1:	e8 6e 0a 00 00       	call   802134 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8016c6:	c7 44 24 04 d8 21 80 	movl   $0x8021d8,0x4(%esp)
  8016cd:	00 
  8016ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d1:	89 14 24             	mov    %edx,(%esp)
  8016d4:	e8 2c fa ff ff       	call   801105 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	79 1c                	jns    8016f9 <fork+0x217>
            panic("set pgfault upcall failed");
  8016dd:	c7 44 24 08 d4 29 80 	movl   $0x8029d4,0x8(%esp)
  8016e4:	00 
  8016e5:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8016ec:	00 
  8016ed:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  8016f4:	e8 3b 0a 00 00       	call   802134 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  8016f9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801700:	00 
  801701:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801704:	89 04 24             	mov    %eax,(%esp)
  801707:	e8 d1 fa ff ff       	call   8011dd <sys_env_set_status>
        if(r < 0)
  80170c:	85 c0                	test   %eax,%eax
  80170e:	79 1c                	jns    80172c <fork+0x24a>
            panic("set status failed");
  801710:	c7 44 24 08 ee 29 80 	movl   $0x8029ee,0x8(%esp)
  801717:	00 
  801718:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80171f:	00 
  801720:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  801727:	e8 08 0a 00 00       	call   802134 <_panic>
        return envid;
	//panic("fork not implemented");
}
  80172c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172f:	83 c4 3c             	add    $0x3c,%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 24             	sub    $0x24,%esp
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801741:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801743:	89 da                	mov    %ebx,%edx
  801745:	c1 ea 0c             	shr    $0xc,%edx
  801748:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80174f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801753:	74 08                	je     80175d <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801755:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80175b:	75 1c                	jne    801779 <pgfault+0x42>
           panic("pgfault error");
  80175d:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  801764:	00 
  801765:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80176c:	00 
  80176d:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  801774:	e8 bb 09 00 00       	call   802134 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801779:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801780:	00 
  801781:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801788:	00 
  801789:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801790:	e8 8e fb ff ff       	call   801323 <sys_page_alloc>
  801795:	85 c0                	test   %eax,%eax
  801797:	79 20                	jns    8017b9 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  801799:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80179d:	c7 44 24 08 0e 2a 80 	movl   $0x802a0e,0x8(%esp)
  8017a4:	00 
  8017a5:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8017ac:	00 
  8017ad:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  8017b4:	e8 7b 09 00 00       	call   802134 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  8017b9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8017bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8017c6:	00 
  8017c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017cb:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8017d2:	e8 0e f5 ff ff       	call   800ce5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  8017d7:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8017de:	00 
  8017df:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ea:	00 
  8017eb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8017f2:	00 
  8017f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fa:	e8 b6 fa ff ff       	call   8012b5 <sys_page_map>
  8017ff:	85 c0                	test   %eax,%eax
  801801:	79 20                	jns    801823 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801807:	c7 44 24 08 21 2a 80 	movl   $0x802a21,0x8(%esp)
  80180e:	00 
  80180f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801816:	00 
  801817:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  80181e:	e8 11 09 00 00       	call   802134 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801823:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80182a:	00 
  80182b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801832:	e8 12 fa ff ff       	call   801249 <sys_page_unmap>
  801837:	85 c0                	test   %eax,%eax
  801839:	79 20                	jns    80185b <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80183b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80183f:	c7 44 24 08 32 2a 80 	movl   $0x802a32,0x8(%esp)
  801846:	00 
  801847:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80184e:	00 
  80184f:	c7 04 24 a1 29 80 00 	movl   $0x8029a1,(%esp)
  801856:	e8 d9 08 00 00       	call   802134 <_panic>
	//panic("pgfault not implemented");
}
  80185b:	83 c4 24             	add    $0x24,%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5d                   	pop    %ebp
  801860:	c3                   	ret    
	...

00801870 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	05 00 00 00 30       	add    $0x30000000,%eax
  80187b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	89 04 24             	mov    %eax,(%esp)
  80188c:	e8 df ff ff ff       	call   801870 <fd2num>
  801891:	05 20 00 0d 00       	add    $0xd0020,%eax
  801896:	c1 e0 0c             	shl    $0xc,%eax
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	57                   	push   %edi
  80189f:	56                   	push   %esi
  8018a0:	53                   	push   %ebx
  8018a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8018a4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8018a9:	a8 01                	test   $0x1,%al
  8018ab:	74 36                	je     8018e3 <fd_alloc+0x48>
  8018ad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8018b2:	a8 01                	test   $0x1,%al
  8018b4:	74 2d                	je     8018e3 <fd_alloc+0x48>
  8018b6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8018bb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8018c0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	89 c2                	mov    %eax,%edx
  8018c9:	c1 ea 16             	shr    $0x16,%edx
  8018cc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8018cf:	f6 c2 01             	test   $0x1,%dl
  8018d2:	74 14                	je     8018e8 <fd_alloc+0x4d>
  8018d4:	89 c2                	mov    %eax,%edx
  8018d6:	c1 ea 0c             	shr    $0xc,%edx
  8018d9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8018dc:	f6 c2 01             	test   $0x1,%dl
  8018df:	75 10                	jne    8018f1 <fd_alloc+0x56>
  8018e1:	eb 05                	jmp    8018e8 <fd_alloc+0x4d>
  8018e3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8018e8:	89 1f                	mov    %ebx,(%edi)
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8018ef:	eb 17                	jmp    801908 <fd_alloc+0x6d>
  8018f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8018f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8018fb:	75 c8                	jne    8018c5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8018fd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801903:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801908:	5b                   	pop    %ebx
  801909:	5e                   	pop    %esi
  80190a:	5f                   	pop    %edi
  80190b:	5d                   	pop    %ebp
  80190c:	c3                   	ret    

0080190d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801910:	8b 45 08             	mov    0x8(%ebp),%eax
  801913:	83 f8 1f             	cmp    $0x1f,%eax
  801916:	77 36                	ja     80194e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801918:	05 00 00 0d 00       	add    $0xd0000,%eax
  80191d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801920:	89 c2                	mov    %eax,%edx
  801922:	c1 ea 16             	shr    $0x16,%edx
  801925:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80192c:	f6 c2 01             	test   $0x1,%dl
  80192f:	74 1d                	je     80194e <fd_lookup+0x41>
  801931:	89 c2                	mov    %eax,%edx
  801933:	c1 ea 0c             	shr    $0xc,%edx
  801936:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80193d:	f6 c2 01             	test   $0x1,%dl
  801940:	74 0c                	je     80194e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801942:	8b 55 0c             	mov    0xc(%ebp),%edx
  801945:	89 02                	mov    %eax,(%edx)
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80194c:	eb 05                	jmp    801953 <fd_lookup+0x46>
  80194e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80195b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80195e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	89 04 24             	mov    %eax,(%esp)
  801968:	e8 a0 ff ff ff       	call   80190d <fd_lookup>
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 0e                	js     80197f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801971:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801974:	8b 55 0c             	mov    0xc(%ebp),%edx
  801977:	89 50 04             	mov    %edx,0x4(%eax)
  80197a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	56                   	push   %esi
  801985:	53                   	push   %ebx
  801986:	83 ec 10             	sub    $0x10,%esp
  801989:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80198f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801994:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801999:	be c4 2a 80 00       	mov    $0x802ac4,%esi
		if (devtab[i]->dev_id == dev_id) {
  80199e:	39 08                	cmp    %ecx,(%eax)
  8019a0:	75 10                	jne    8019b2 <dev_lookup+0x31>
  8019a2:	eb 04                	jmp    8019a8 <dev_lookup+0x27>
  8019a4:	39 08                	cmp    %ecx,(%eax)
  8019a6:	75 0a                	jne    8019b2 <dev_lookup+0x31>
			*dev = devtab[i];
  8019a8:	89 03                	mov    %eax,(%ebx)
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8019af:	90                   	nop
  8019b0:	eb 31                	jmp    8019e3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8019b2:	83 c2 01             	add    $0x1,%edx
  8019b5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	75 e8                	jne    8019a4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8019c1:	8b 40 48             	mov    0x48(%eax),%eax
  8019c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cc:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  8019d3:	e8 f5 e7 ff ff       	call   8001cd <cprintf>
	*dev = 0;
  8019d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	5b                   	pop    %ebx
  8019e7:	5e                   	pop    %esi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	53                   	push   %ebx
  8019ee:	83 ec 24             	sub    $0x24,%esp
  8019f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	e8 07 ff ff ff       	call   80190d <fd_lookup>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 53                	js     801a5d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a14:	8b 00                	mov    (%eax),%eax
  801a16:	89 04 24             	mov    %eax,(%esp)
  801a19:	e8 63 ff ff ff       	call   801981 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 3b                	js     801a5d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801a22:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a2a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801a2e:	74 2d                	je     801a5d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a30:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a33:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a3a:	00 00 00 
	stat->st_isdir = 0;
  801a3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a44:	00 00 00 
	stat->st_dev = dev;
  801a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a57:	89 14 24             	mov    %edx,(%esp)
  801a5a:	ff 50 14             	call   *0x14(%eax)
}
  801a5d:	83 c4 24             	add    $0x24,%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	53                   	push   %ebx
  801a67:	83 ec 24             	sub    $0x24,%esp
  801a6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a74:	89 1c 24             	mov    %ebx,(%esp)
  801a77:	e8 91 fe ff ff       	call   80190d <fd_lookup>
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	78 5f                	js     801adf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8a:	8b 00                	mov    (%eax),%eax
  801a8c:	89 04 24             	mov    %eax,(%esp)
  801a8f:	e8 ed fe ff ff       	call   801981 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a94:	85 c0                	test   %eax,%eax
  801a96:	78 47                	js     801adf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a9b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801a9f:	75 23                	jne    801ac4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801aa1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801aa6:	8b 40 48             	mov    0x48(%eax),%eax
  801aa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801aad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab1:	c7 04 24 68 2a 80 00 	movl   $0x802a68,(%esp)
  801ab8:	e8 10 e7 ff ff       	call   8001cd <cprintf>
  801abd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801ac2:	eb 1b                	jmp    801adf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac7:	8b 48 18             	mov    0x18(%eax),%ecx
  801aca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801acf:	85 c9                	test   %ecx,%ecx
  801ad1:	74 0c                	je     801adf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ada:	89 14 24             	mov    %edx,(%esp)
  801add:	ff d1                	call   *%ecx
}
  801adf:	83 c4 24             	add    $0x24,%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 24             	sub    $0x24,%esp
  801aec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af6:	89 1c 24             	mov    %ebx,(%esp)
  801af9:	e8 0f fe ff ff       	call   80190d <fd_lookup>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 66                	js     801b68 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b0c:	8b 00                	mov    (%eax),%eax
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	e8 6b fe ff ff       	call   801981 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 4e                	js     801b68 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b1d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801b21:	75 23                	jne    801b46 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b23:	a1 04 40 80 00       	mov    0x804004,%eax
  801b28:	8b 40 48             	mov    0x48(%eax),%eax
  801b2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b33:	c7 04 24 89 2a 80 00 	movl   $0x802a89,(%esp)
  801b3a:	e8 8e e6 ff ff       	call   8001cd <cprintf>
  801b3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801b44:	eb 22                	jmp    801b68 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b49:	8b 48 0c             	mov    0xc(%eax),%ecx
  801b4c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b51:	85 c9                	test   %ecx,%ecx
  801b53:	74 13                	je     801b68 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b55:	8b 45 10             	mov    0x10(%ebp),%eax
  801b58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b63:	89 14 24             	mov    %edx,(%esp)
  801b66:	ff d1                	call   *%ecx
}
  801b68:	83 c4 24             	add    $0x24,%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	83 ec 24             	sub    $0x24,%esp
  801b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7f:	89 1c 24             	mov    %ebx,(%esp)
  801b82:	e8 86 fd ff ff       	call   80190d <fd_lookup>
  801b87:	85 c0                	test   %eax,%eax
  801b89:	78 6b                	js     801bf6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b95:	8b 00                	mov    (%eax),%eax
  801b97:	89 04 24             	mov    %eax,(%esp)
  801b9a:	e8 e2 fd ff ff       	call   801981 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 53                	js     801bf6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ba3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ba6:	8b 42 08             	mov    0x8(%edx),%eax
  801ba9:	83 e0 03             	and    $0x3,%eax
  801bac:	83 f8 01             	cmp    $0x1,%eax
  801baf:	75 23                	jne    801bd4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801bb1:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb6:	8b 40 48             	mov    0x48(%eax),%eax
  801bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc1:	c7 04 24 a6 2a 80 00 	movl   $0x802aa6,(%esp)
  801bc8:	e8 00 e6 ff ff       	call   8001cd <cprintf>
  801bcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801bd2:	eb 22                	jmp    801bf6 <read+0x88>
	}
	if (!dev->dev_read)
  801bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd7:	8b 48 08             	mov    0x8(%eax),%ecx
  801bda:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bdf:	85 c9                	test   %ecx,%ecx
  801be1:	74 13                	je     801bf6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801be3:	8b 45 10             	mov    0x10(%ebp),%eax
  801be6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf1:	89 14 24             	mov    %edx,(%esp)
  801bf4:	ff d1                	call   *%ecx
}
  801bf6:	83 c4 24             	add    $0x24,%esp
  801bf9:	5b                   	pop    %ebx
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	83 ec 1c             	sub    $0x1c,%esp
  801c05:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c08:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1a:	85 f6                	test   %esi,%esi
  801c1c:	74 29                	je     801c47 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c1e:	89 f0                	mov    %esi,%eax
  801c20:	29 d0                	sub    %edx,%eax
  801c22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c26:	03 55 0c             	add    0xc(%ebp),%edx
  801c29:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c2d:	89 3c 24             	mov    %edi,(%esp)
  801c30:	e8 39 ff ff ff       	call   801b6e <read>
		if (m < 0)
  801c35:	85 c0                	test   %eax,%eax
  801c37:	78 0e                	js     801c47 <readn+0x4b>
			return m;
		if (m == 0)
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	74 08                	je     801c45 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c3d:	01 c3                	add    %eax,%ebx
  801c3f:	89 da                	mov    %ebx,%edx
  801c41:	39 f3                	cmp    %esi,%ebx
  801c43:	72 d9                	jb     801c1e <readn+0x22>
  801c45:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801c47:	83 c4 1c             	add    $0x1c,%esp
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 20             	sub    $0x20,%esp
  801c57:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c5a:	89 34 24             	mov    %esi,(%esp)
  801c5d:	e8 0e fc ff ff       	call   801870 <fd2num>
  801c62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c65:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c69:	89 04 24             	mov    %eax,(%esp)
  801c6c:	e8 9c fc ff ff       	call   80190d <fd_lookup>
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	85 c0                	test   %eax,%eax
  801c75:	78 05                	js     801c7c <fd_close+0x2d>
  801c77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c7a:	74 0c                	je     801c88 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801c7c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801c80:	19 c0                	sbb    %eax,%eax
  801c82:	f7 d0                	not    %eax
  801c84:	21 c3                	and    %eax,%ebx
  801c86:	eb 3d                	jmp    801cc5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801c88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8f:	8b 06                	mov    (%esi),%eax
  801c91:	89 04 24             	mov    %eax,(%esp)
  801c94:	e8 e8 fc ff ff       	call   801981 <dev_lookup>
  801c99:	89 c3                	mov    %eax,%ebx
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 16                	js     801cb5 <fd_close+0x66>
		if (dev->dev_close)
  801c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca2:	8b 40 10             	mov    0x10(%eax),%eax
  801ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801caa:	85 c0                	test   %eax,%eax
  801cac:	74 07                	je     801cb5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801cae:	89 34 24             	mov    %esi,(%esp)
  801cb1:	ff d0                	call   *%eax
  801cb3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc0:	e8 84 f5 ff ff       	call   801249 <sys_page_unmap>
	return r;
}
  801cc5:	89 d8                	mov    %ebx,%eax
  801cc7:	83 c4 20             	add    $0x20,%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 27 fc ff ff       	call   80190d <fd_lookup>
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 13                	js     801cfd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801cea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801cf1:	00 
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	89 04 24             	mov    %eax,(%esp)
  801cf8:	e8 52 ff ff ff       	call   801c4f <fd_close>
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	83 ec 18             	sub    $0x18,%esp
  801d05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d08:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d12:	00 
  801d13:	8b 45 08             	mov    0x8(%ebp),%eax
  801d16:	89 04 24             	mov    %eax,(%esp)
  801d19:	e8 79 03 00 00       	call   802097 <open>
  801d1e:	89 c3                	mov    %eax,%ebx
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 1b                	js     801d3f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2b:	89 1c 24             	mov    %ebx,(%esp)
  801d2e:	e8 b7 fc ff ff       	call   8019ea <fstat>
  801d33:	89 c6                	mov    %eax,%esi
	close(fd);
  801d35:	89 1c 24             	mov    %ebx,(%esp)
  801d38:	e8 91 ff ff ff       	call   801cce <close>
  801d3d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801d3f:	89 d8                	mov    %ebx,%eax
  801d41:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d44:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d47:	89 ec                	mov    %ebp,%esp
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 14             	sub    $0x14,%esp
  801d52:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801d57:	89 1c 24             	mov    %ebx,(%esp)
  801d5a:	e8 6f ff ff ff       	call   801cce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d5f:	83 c3 01             	add    $0x1,%ebx
  801d62:	83 fb 20             	cmp    $0x20,%ebx
  801d65:	75 f0                	jne    801d57 <close_all+0xc>
		close(i);
}
  801d67:	83 c4 14             	add    $0x14,%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	83 ec 58             	sub    $0x58,%esp
  801d73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801d76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d79:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d7c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d86:	8b 45 08             	mov    0x8(%ebp),%eax
  801d89:	89 04 24             	mov    %eax,(%esp)
  801d8c:	e8 7c fb ff ff       	call   80190d <fd_lookup>
  801d91:	89 c3                	mov    %eax,%ebx
  801d93:	85 c0                	test   %eax,%eax
  801d95:	0f 88 e0 00 00 00    	js     801e7b <dup+0x10e>
		return r;
	close(newfdnum);
  801d9b:	89 3c 24             	mov    %edi,(%esp)
  801d9e:	e8 2b ff ff ff       	call   801cce <close>

	newfd = INDEX2FD(newfdnum);
  801da3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801da9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801dac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801daf:	89 04 24             	mov    %eax,(%esp)
  801db2:	e8 c9 fa ff ff       	call   801880 <fd2data>
  801db7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801db9:	89 34 24             	mov    %esi,(%esp)
  801dbc:	e8 bf fa ff ff       	call   801880 <fd2data>
  801dc1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801dc4:	89 da                	mov    %ebx,%edx
  801dc6:	89 d8                	mov    %ebx,%eax
  801dc8:	c1 e8 16             	shr    $0x16,%eax
  801dcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801dd2:	a8 01                	test   $0x1,%al
  801dd4:	74 43                	je     801e19 <dup+0xac>
  801dd6:	c1 ea 0c             	shr    $0xc,%edx
  801dd9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801de0:	a8 01                	test   $0x1,%al
  801de2:	74 35                	je     801e19 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801de4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801deb:	25 07 0e 00 00       	and    $0xe07,%eax
  801df0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801df4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801df7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dfb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e02:	00 
  801e03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0e:	e8 a2 f4 ff ff       	call   8012b5 <sys_page_map>
  801e13:	89 c3                	mov    %eax,%ebx
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 3f                	js     801e58 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e1c:	89 c2                	mov    %eax,%edx
  801e1e:	c1 ea 0c             	shr    $0xc,%edx
  801e21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e28:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801e2e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e32:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e3d:	00 
  801e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e49:	e8 67 f4 ff ff       	call   8012b5 <sys_page_map>
  801e4e:	89 c3                	mov    %eax,%ebx
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 04                	js     801e58 <dup+0xeb>
  801e54:	89 fb                	mov    %edi,%ebx
  801e56:	eb 23                	jmp    801e7b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e58:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e63:	e8 e1 f3 ff ff       	call   801249 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e76:	e8 ce f3 ff ff       	call   801249 <sys_page_unmap>
	return r;
}
  801e7b:	89 d8                	mov    %ebx,%eax
  801e7d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e80:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801e83:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801e86:	89 ec                	mov    %ebp,%esp
  801e88:	5d                   	pop    %ebp
  801e89:	c3                   	ret    
	...

00801e8c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 18             	sub    $0x18,%esp
  801e92:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e95:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801e9c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ea3:	75 11                	jne    801eb6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ea5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801eac:	e8 4f 03 00 00       	call   802200 <ipc_find_env>
  801eb1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801eb6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ebd:	00 
  801ebe:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ec5:	00 
  801ec6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eca:	a1 00 40 80 00       	mov    0x804000,%eax
  801ecf:	89 04 24             	mov    %eax,(%esp)
  801ed2:	e8 74 03 00 00       	call   80224b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ed7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ede:	00 
  801edf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eea:	e8 da 03 00 00       	call   8022c9 <ipc_recv>
}
  801eef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ef2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ef5:	89 ec                	mov    %ebp,%esp
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801eff:	8b 45 08             	mov    0x8(%ebp),%eax
  801f02:	8b 40 0c             	mov    0xc(%eax),%eax
  801f05:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801f0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f12:	ba 00 00 00 00       	mov    $0x0,%edx
  801f17:	b8 02 00 00 00       	mov    $0x2,%eax
  801f1c:	e8 6b ff ff ff       	call   801e8c <fsipc>
}
  801f21:	c9                   	leave  
  801f22:	c3                   	ret    

00801f23 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f29:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801f2f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801f34:	ba 00 00 00 00       	mov    $0x0,%edx
  801f39:	b8 06 00 00 00       	mov    $0x6,%eax
  801f3e:	e8 49 ff ff ff       	call   801e8c <fsipc>
}
  801f43:	c9                   	leave  
  801f44:	c3                   	ret    

00801f45 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f50:	b8 08 00 00 00       	mov    $0x8,%eax
  801f55:	e8 32 ff ff ff       	call   801e8c <fsipc>
}
  801f5a:	c9                   	leave  
  801f5b:	c3                   	ret    

00801f5c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	53                   	push   %ebx
  801f60:	83 ec 14             	sub    $0x14,%esp
  801f63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f66:	8b 45 08             	mov    0x8(%ebp),%eax
  801f69:	8b 40 0c             	mov    0xc(%eax),%eax
  801f6c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f71:	ba 00 00 00 00       	mov    $0x0,%edx
  801f76:	b8 05 00 00 00       	mov    $0x5,%eax
  801f7b:	e8 0c ff ff ff       	call   801e8c <fsipc>
  801f80:	85 c0                	test   %eax,%eax
  801f82:	78 2b                	js     801faf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801f84:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f8b:	00 
  801f8c:	89 1c 24             	mov    %ebx,(%esp)
  801f8f:	e8 66 eb ff ff       	call   800afa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801f94:	a1 80 50 80 00       	mov    0x805080,%eax
  801f99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801f9f:	a1 84 50 80 00       	mov    0x805084,%eax
  801fa4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801faa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801faf:	83 c4 14             	add    $0x14,%esp
  801fb2:	5b                   	pop    %ebx
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 18             	sub    $0x18,%esp
  801fbb:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801fc3:	76 05                	jbe    801fca <devfile_write+0x15>
  801fc5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801fca:	8b 55 08             	mov    0x8(%ebp),%edx
  801fcd:	8b 52 0c             	mov    0xc(%edx),%edx
  801fd0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801fd6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801fdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801fed:	e8 f3 ec ff ff       	call   800ce5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801ff2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff7:	b8 04 00 00 00       	mov    $0x4,%eax
  801ffc:	e8 8b fe ff ff       	call   801e8c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802001:	c9                   	leave  
  802002:	c3                   	ret    

00802003 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	53                   	push   %ebx
  802007:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80200a:	8b 45 08             	mov    0x8(%ebp),%eax
  80200d:	8b 40 0c             	mov    0xc(%eax),%eax
  802010:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  802015:	8b 45 10             	mov    0x10(%ebp),%eax
  802018:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  80201d:	ba 00 00 00 00       	mov    $0x0,%edx
  802022:	b8 03 00 00 00       	mov    $0x3,%eax
  802027:	e8 60 fe ff ff       	call   801e8c <fsipc>
  80202c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 17                	js     802049 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802032:	89 44 24 08          	mov    %eax,0x8(%esp)
  802036:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80203d:	00 
  80203e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802041:	89 04 24             	mov    %eax,(%esp)
  802044:	e8 9c ec ff ff       	call   800ce5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802049:	89 d8                	mov    %ebx,%eax
  80204b:	83 c4 14             	add    $0x14,%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    

00802051 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	53                   	push   %ebx
  802055:	83 ec 14             	sub    $0x14,%esp
  802058:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80205b:	89 1c 24             	mov    %ebx,(%esp)
  80205e:	e8 4d ea ff ff       	call   800ab0 <strlen>
  802063:	89 c2                	mov    %eax,%edx
  802065:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80206a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802070:	7f 1f                	jg     802091 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802072:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802076:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80207d:	e8 78 ea ff ff       	call   800afa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802082:	ba 00 00 00 00       	mov    $0x0,%edx
  802087:	b8 07 00 00 00       	mov    $0x7,%eax
  80208c:	e8 fb fd ff ff       	call   801e8c <fsipc>
}
  802091:	83 c4 14             	add    $0x14,%esp
  802094:	5b                   	pop    %ebx
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	83 ec 28             	sub    $0x28,%esp
  80209d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8020a0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8020a3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  8020a6:	89 34 24             	mov    %esi,(%esp)
  8020a9:	e8 02 ea ff ff       	call   800ab0 <strlen>
  8020ae:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8020b3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020b8:	7f 6d                	jg     802127 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8020ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020bd:	89 04 24             	mov    %eax,(%esp)
  8020c0:	e8 d6 f7 ff ff       	call   80189b <fd_alloc>
  8020c5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	78 5c                	js     802127 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8020cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ce:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8020d3:	89 34 24             	mov    %esi,(%esp)
  8020d6:	e8 d5 e9 ff ff       	call   800ab0 <strlen>
  8020db:	83 c0 01             	add    $0x1,%eax
  8020de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020e6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8020ed:	e8 f3 eb ff ff       	call   800ce5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8020f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fa:	e8 8d fd ff ff       	call   801e8c <fsipc>
  8020ff:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802101:	85 c0                	test   %eax,%eax
  802103:	79 15                	jns    80211a <open+0x83>
             fd_close(fd,0);
  802105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80210c:	00 
  80210d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802110:	89 04 24             	mov    %eax,(%esp)
  802113:	e8 37 fb ff ff       	call   801c4f <fd_close>
             return r;
  802118:	eb 0d                	jmp    802127 <open+0x90>
        }
        return fd2num(fd);
  80211a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211d:	89 04 24             	mov    %eax,(%esp)
  802120:	e8 4b f7 ff ff       	call   801870 <fd2num>
  802125:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802127:	89 d8                	mov    %ebx,%eax
  802129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80212c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80212f:	89 ec                	mov    %ebp,%esp
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    
	...

00802134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	56                   	push   %esi
  802138:	53                   	push   %ebx
  802139:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80213c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80213f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802145:	e8 c8 f2 ff ff       	call   801412 <sys_getenvid>
  80214a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80214d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802151:	8b 55 08             	mov    0x8(%ebp),%edx
  802154:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802158:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80215c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802160:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  802167:	e8 61 e0 ff ff       	call   8001cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80216c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802170:	8b 45 10             	mov    0x10(%ebp),%eax
  802173:	89 04 24             	mov    %eax,(%esp)
  802176:	e8 f1 df ff ff       	call   80016c <vcprintf>
	cprintf("\n");
  80217b:	c7 04 24 d4 25 80 00 	movl   $0x8025d4,(%esp)
  802182:	e8 46 e0 ff ff       	call   8001cd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802187:	cc                   	int3   
  802188:	eb fd                	jmp    802187 <_panic+0x53>
	...

0080218c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802192:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802199:	75 30                	jne    8021cb <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80219b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021a2:	00 
  8021a3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021aa:	ee 
  8021ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b2:	e8 6c f1 ff ff       	call   801323 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8021b7:	c7 44 24 04 d8 21 80 	movl   $0x8021d8,0x4(%esp)
  8021be:	00 
  8021bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c6:	e8 3a ef ff ff       	call   801105 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ce:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    
  8021d5:	00 00                	add    %al,(%eax)
	...

008021d8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021d9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021e0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8021e3:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8021e7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8021eb:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8021ee:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8021f0:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8021f4:	83 c4 08             	add    $0x8,%esp
        popal
  8021f7:	61                   	popa   
        addl $0x4,%esp
  8021f8:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8021fb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8021fc:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8021fd:	c3                   	ret    
	...

00802200 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802206:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80220c:	b8 01 00 00 00       	mov    $0x1,%eax
  802211:	39 ca                	cmp    %ecx,%edx
  802213:	75 04                	jne    802219 <ipc_find_env+0x19>
  802215:	b0 00                	mov    $0x0,%al
  802217:	eb 12                	jmp    80222b <ipc_find_env+0x2b>
  802219:	89 c2                	mov    %eax,%edx
  80221b:	c1 e2 07             	shl    $0x7,%edx
  80221e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802225:	8b 12                	mov    (%edx),%edx
  802227:	39 ca                	cmp    %ecx,%edx
  802229:	75 10                	jne    80223b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80222b:	89 c2                	mov    %eax,%edx
  80222d:	c1 e2 07             	shl    $0x7,%edx
  802230:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802237:	8b 00                	mov    (%eax),%eax
  802239:	eb 0e                	jmp    802249 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80223b:	83 c0 01             	add    $0x1,%eax
  80223e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802243:	75 d4                	jne    802219 <ipc_find_env+0x19>
  802245:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    

0080224b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	57                   	push   %edi
  80224f:	56                   	push   %esi
  802250:	53                   	push   %ebx
  802251:	83 ec 1c             	sub    $0x1c,%esp
  802254:	8b 75 08             	mov    0x8(%ebp),%esi
  802257:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80225a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80225d:	85 db                	test   %ebx,%ebx
  80225f:	74 19                	je     80227a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802261:	8b 45 14             	mov    0x14(%ebp),%eax
  802264:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802268:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80226c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802270:	89 34 24             	mov    %esi,(%esp)
  802273:	e8 4c ee ff ff       	call   8010c4 <sys_ipc_try_send>
  802278:	eb 1b                	jmp    802295 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80227a:	8b 45 14             	mov    0x14(%ebp),%eax
  80227d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802281:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802288:	ee 
  802289:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80228d:	89 34 24             	mov    %esi,(%esp)
  802290:	e8 2f ee ff ff       	call   8010c4 <sys_ipc_try_send>
           if(ret == 0)
  802295:	85 c0                	test   %eax,%eax
  802297:	74 28                	je     8022c1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802299:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80229c:	74 1c                	je     8022ba <ipc_send+0x6f>
              panic("ipc send error");
  80229e:	c7 44 24 08 f0 2a 80 	movl   $0x802af0,0x8(%esp)
  8022a5:	00 
  8022a6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8022ad:	00 
  8022ae:	c7 04 24 ff 2a 80 00 	movl   $0x802aff,(%esp)
  8022b5:	e8 7a fe ff ff       	call   802134 <_panic>
           sys_yield();
  8022ba:	e8 d1 f0 ff ff       	call   801390 <sys_yield>
        }
  8022bf:	eb 9c                	jmp    80225d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    

008022c9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	56                   	push   %esi
  8022cd:	53                   	push   %ebx
  8022ce:	83 ec 10             	sub    $0x10,%esp
  8022d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8022d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8022da:	85 c0                	test   %eax,%eax
  8022dc:	75 0e                	jne    8022ec <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8022de:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8022e5:	e8 6f ed ff ff       	call   801059 <sys_ipc_recv>
  8022ea:	eb 08                	jmp    8022f4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8022ec:	89 04 24             	mov    %eax,(%esp)
  8022ef:	e8 65 ed ff ff       	call   801059 <sys_ipc_recv>
        if(ret == 0){
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	75 26                	jne    80231e <ipc_recv+0x55>
           if(from_env_store)
  8022f8:	85 f6                	test   %esi,%esi
  8022fa:	74 0a                	je     802306 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  8022fc:	a1 04 40 80 00       	mov    0x804004,%eax
  802301:	8b 40 78             	mov    0x78(%eax),%eax
  802304:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802306:	85 db                	test   %ebx,%ebx
  802308:	74 0a                	je     802314 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80230a:	a1 04 40 80 00       	mov    0x804004,%eax
  80230f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802312:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802314:	a1 04 40 80 00       	mov    0x804004,%eax
  802319:	8b 40 74             	mov    0x74(%eax),%eax
  80231c:	eb 14                	jmp    802332 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80231e:	85 f6                	test   %esi,%esi
  802320:	74 06                	je     802328 <ipc_recv+0x5f>
              *from_env_store = 0;
  802322:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802328:	85 db                	test   %ebx,%ebx
  80232a:	74 06                	je     802332 <ipc_recv+0x69>
              *perm_store = 0;
  80232c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	5b                   	pop    %ebx
  802336:	5e                   	pop    %esi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	00 00                	add    %al,(%eax)
  80233b:	00 00                	add    %al,(%eax)
  80233d:	00 00                	add    %al,(%eax)
	...

00802340 <__udivdi3>:
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	57                   	push   %edi
  802344:	56                   	push   %esi
  802345:	83 ec 10             	sub    $0x10,%esp
  802348:	8b 45 14             	mov    0x14(%ebp),%eax
  80234b:	8b 55 08             	mov    0x8(%ebp),%edx
  80234e:	8b 75 10             	mov    0x10(%ebp),%esi
  802351:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802354:	85 c0                	test   %eax,%eax
  802356:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802359:	75 35                	jne    802390 <__udivdi3+0x50>
  80235b:	39 fe                	cmp    %edi,%esi
  80235d:	77 61                	ja     8023c0 <__udivdi3+0x80>
  80235f:	85 f6                	test   %esi,%esi
  802361:	75 0b                	jne    80236e <__udivdi3+0x2e>
  802363:	b8 01 00 00 00       	mov    $0x1,%eax
  802368:	31 d2                	xor    %edx,%edx
  80236a:	f7 f6                	div    %esi
  80236c:	89 c6                	mov    %eax,%esi
  80236e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802371:	31 d2                	xor    %edx,%edx
  802373:	89 f8                	mov    %edi,%eax
  802375:	f7 f6                	div    %esi
  802377:	89 c7                	mov    %eax,%edi
  802379:	89 c8                	mov    %ecx,%eax
  80237b:	f7 f6                	div    %esi
  80237d:	89 c1                	mov    %eax,%ecx
  80237f:	89 fa                	mov    %edi,%edx
  802381:	89 c8                	mov    %ecx,%eax
  802383:	83 c4 10             	add    $0x10,%esp
  802386:	5e                   	pop    %esi
  802387:	5f                   	pop    %edi
  802388:	5d                   	pop    %ebp
  802389:	c3                   	ret    
  80238a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802390:	39 f8                	cmp    %edi,%eax
  802392:	77 1c                	ja     8023b0 <__udivdi3+0x70>
  802394:	0f bd d0             	bsr    %eax,%edx
  802397:	83 f2 1f             	xor    $0x1f,%edx
  80239a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80239d:	75 39                	jne    8023d8 <__udivdi3+0x98>
  80239f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8023a2:	0f 86 a0 00 00 00    	jbe    802448 <__udivdi3+0x108>
  8023a8:	39 f8                	cmp    %edi,%eax
  8023aa:	0f 82 98 00 00 00    	jb     802448 <__udivdi3+0x108>
  8023b0:	31 ff                	xor    %edi,%edi
  8023b2:	31 c9                	xor    %ecx,%ecx
  8023b4:	89 c8                	mov    %ecx,%eax
  8023b6:	89 fa                	mov    %edi,%edx
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	5e                   	pop    %esi
  8023bc:	5f                   	pop    %edi
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    
  8023bf:	90                   	nop
  8023c0:	89 d1                	mov    %edx,%ecx
  8023c2:	89 fa                	mov    %edi,%edx
  8023c4:	89 c8                	mov    %ecx,%eax
  8023c6:	31 ff                	xor    %edi,%edi
  8023c8:	f7 f6                	div    %esi
  8023ca:	89 c1                	mov    %eax,%ecx
  8023cc:	89 fa                	mov    %edi,%edx
  8023ce:	89 c8                	mov    %ecx,%eax
  8023d0:	83 c4 10             	add    $0x10,%esp
  8023d3:	5e                   	pop    %esi
  8023d4:	5f                   	pop    %edi
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    
  8023d7:	90                   	nop
  8023d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8023dc:	89 f2                	mov    %esi,%edx
  8023de:	d3 e0                	shl    %cl,%eax
  8023e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8023e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8023e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8023eb:	89 c1                	mov    %eax,%ecx
  8023ed:	d3 ea                	shr    %cl,%edx
  8023ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8023f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8023f6:	d3 e6                	shl    %cl,%esi
  8023f8:	89 c1                	mov    %eax,%ecx
  8023fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8023fd:	89 fe                	mov    %edi,%esi
  8023ff:	d3 ee                	shr    %cl,%esi
  802401:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802405:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802408:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80240b:	d3 e7                	shl    %cl,%edi
  80240d:	89 c1                	mov    %eax,%ecx
  80240f:	d3 ea                	shr    %cl,%edx
  802411:	09 d7                	or     %edx,%edi
  802413:	89 f2                	mov    %esi,%edx
  802415:	89 f8                	mov    %edi,%eax
  802417:	f7 75 ec             	divl   -0x14(%ebp)
  80241a:	89 d6                	mov    %edx,%esi
  80241c:	89 c7                	mov    %eax,%edi
  80241e:	f7 65 e8             	mull   -0x18(%ebp)
  802421:	39 d6                	cmp    %edx,%esi
  802423:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802426:	72 30                	jb     802458 <__udivdi3+0x118>
  802428:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80242b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80242f:	d3 e2                	shl    %cl,%edx
  802431:	39 c2                	cmp    %eax,%edx
  802433:	73 05                	jae    80243a <__udivdi3+0xfa>
  802435:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802438:	74 1e                	je     802458 <__udivdi3+0x118>
  80243a:	89 f9                	mov    %edi,%ecx
  80243c:	31 ff                	xor    %edi,%edi
  80243e:	e9 71 ff ff ff       	jmp    8023b4 <__udivdi3+0x74>
  802443:	90                   	nop
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	31 ff                	xor    %edi,%edi
  80244a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80244f:	e9 60 ff ff ff       	jmp    8023b4 <__udivdi3+0x74>
  802454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802458:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80245b:	31 ff                	xor    %edi,%edi
  80245d:	89 c8                	mov    %ecx,%eax
  80245f:	89 fa                	mov    %edi,%edx
  802461:	83 c4 10             	add    $0x10,%esp
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
	...

00802470 <__umoddi3>:
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	57                   	push   %edi
  802474:	56                   	push   %esi
  802475:	83 ec 20             	sub    $0x20,%esp
  802478:	8b 55 14             	mov    0x14(%ebp),%edx
  80247b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80247e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802481:	8b 75 0c             	mov    0xc(%ebp),%esi
  802484:	85 d2                	test   %edx,%edx
  802486:	89 c8                	mov    %ecx,%eax
  802488:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80248b:	75 13                	jne    8024a0 <__umoddi3+0x30>
  80248d:	39 f7                	cmp    %esi,%edi
  80248f:	76 3f                	jbe    8024d0 <__umoddi3+0x60>
  802491:	89 f2                	mov    %esi,%edx
  802493:	f7 f7                	div    %edi
  802495:	89 d0                	mov    %edx,%eax
  802497:	31 d2                	xor    %edx,%edx
  802499:	83 c4 20             	add    $0x20,%esp
  80249c:	5e                   	pop    %esi
  80249d:	5f                   	pop    %edi
  80249e:	5d                   	pop    %ebp
  80249f:	c3                   	ret    
  8024a0:	39 f2                	cmp    %esi,%edx
  8024a2:	77 4c                	ja     8024f0 <__umoddi3+0x80>
  8024a4:	0f bd ca             	bsr    %edx,%ecx
  8024a7:	83 f1 1f             	xor    $0x1f,%ecx
  8024aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8024ad:	75 51                	jne    802500 <__umoddi3+0x90>
  8024af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8024b2:	0f 87 e0 00 00 00    	ja     802598 <__umoddi3+0x128>
  8024b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bb:	29 f8                	sub    %edi,%eax
  8024bd:	19 d6                	sbb    %edx,%esi
  8024bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8024c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c5:	89 f2                	mov    %esi,%edx
  8024c7:	83 c4 20             	add    $0x20,%esp
  8024ca:	5e                   	pop    %esi
  8024cb:	5f                   	pop    %edi
  8024cc:	5d                   	pop    %ebp
  8024cd:	c3                   	ret    
  8024ce:	66 90                	xchg   %ax,%ax
  8024d0:	85 ff                	test   %edi,%edi
  8024d2:	75 0b                	jne    8024df <__umoddi3+0x6f>
  8024d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d9:	31 d2                	xor    %edx,%edx
  8024db:	f7 f7                	div    %edi
  8024dd:	89 c7                	mov    %eax,%edi
  8024df:	89 f0                	mov    %esi,%eax
  8024e1:	31 d2                	xor    %edx,%edx
  8024e3:	f7 f7                	div    %edi
  8024e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e8:	f7 f7                	div    %edi
  8024ea:	eb a9                	jmp    802495 <__umoddi3+0x25>
  8024ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	89 c8                	mov    %ecx,%eax
  8024f2:	89 f2                	mov    %esi,%edx
  8024f4:	83 c4 20             	add    $0x20,%esp
  8024f7:	5e                   	pop    %esi
  8024f8:	5f                   	pop    %edi
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    
  8024fb:	90                   	nop
  8024fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802500:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802504:	d3 e2                	shl    %cl,%edx
  802506:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802509:	ba 20 00 00 00       	mov    $0x20,%edx
  80250e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802511:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802514:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802518:	89 fa                	mov    %edi,%edx
  80251a:	d3 ea                	shr    %cl,%edx
  80251c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802520:	0b 55 f4             	or     -0xc(%ebp),%edx
  802523:	d3 e7                	shl    %cl,%edi
  802525:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802529:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80252c:	89 f2                	mov    %esi,%edx
  80252e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802531:	89 c7                	mov    %eax,%edi
  802533:	d3 ea                	shr    %cl,%edx
  802535:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802539:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80253c:	89 c2                	mov    %eax,%edx
  80253e:	d3 e6                	shl    %cl,%esi
  802540:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802544:	d3 ea                	shr    %cl,%edx
  802546:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80254a:	09 d6                	or     %edx,%esi
  80254c:	89 f0                	mov    %esi,%eax
  80254e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802551:	d3 e7                	shl    %cl,%edi
  802553:	89 f2                	mov    %esi,%edx
  802555:	f7 75 f4             	divl   -0xc(%ebp)
  802558:	89 d6                	mov    %edx,%esi
  80255a:	f7 65 e8             	mull   -0x18(%ebp)
  80255d:	39 d6                	cmp    %edx,%esi
  80255f:	72 2b                	jb     80258c <__umoddi3+0x11c>
  802561:	39 c7                	cmp    %eax,%edi
  802563:	72 23                	jb     802588 <__umoddi3+0x118>
  802565:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802569:	29 c7                	sub    %eax,%edi
  80256b:	19 d6                	sbb    %edx,%esi
  80256d:	89 f0                	mov    %esi,%eax
  80256f:	89 f2                	mov    %esi,%edx
  802571:	d3 ef                	shr    %cl,%edi
  802573:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802577:	d3 e0                	shl    %cl,%eax
  802579:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80257d:	09 f8                	or     %edi,%eax
  80257f:	d3 ea                	shr    %cl,%edx
  802581:	83 c4 20             	add    $0x20,%esp
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    
  802588:	39 d6                	cmp    %edx,%esi
  80258a:	75 d9                	jne    802565 <__umoddi3+0xf5>
  80258c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80258f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802592:	eb d1                	jmp    802565 <__umoddi3+0xf5>
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	39 f2                	cmp    %esi,%edx
  80259a:	0f 82 18 ff ff ff    	jb     8024b8 <__umoddi3+0x48>
  8025a0:	e9 1d ff ff ff       	jmp    8024c2 <__umoddi3+0x52>
