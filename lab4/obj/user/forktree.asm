
obj/user/forktree:     file format elf32-i386


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
  800061:	c7 44 24 08 20 1b 80 	movl   $0x801b20,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  800070:	00 
  800071:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800074:	89 04 24             	mov    %eax,(%esp)
  800077:	e8 e3 09 00 00       	call   800a5f <snprintf>
	if (fork() == 0) {
  80007c:	e8 b1 13 00 00       	call   801432 <fork>
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
  8000a9:	e8 b7 12 00 00       	call   801365 <sys_getenvid>
  8000ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b6:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8000bd:	e8 03 01 00 00       	call   8001c5 <cprintf>

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
  8000ee:	c7 04 24 35 1b 80 00 	movl   $0x801b35,(%esp)
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
  80010e:	e8 52 12 00 00       	call   801365 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	89 c2                	mov    %eax,%edx
  80011a:	c1 e2 07             	shl    $0x7,%edx
  80011d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800124:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800129:	85 f6                	test   %esi,%esi
  80012b:	7e 07                	jle    800134 <libmain+0x38>
		binaryname = argv[0];
  80012d:	8b 03                	mov    (%ebx),%eax
  80012f:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  800156:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015d:	e8 43 12 00 00       	call   8013a5 <sys_env_destroy>
}
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	8b 45 0c             	mov    0xc(%ebp),%eax
  800184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 df 01 80 00 	movl   $0x8001df,(%esp)
  8001a0:	e8 d7 01 00 00       	call   80037c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 6f 0d 00 00       	call   800f2c <sys_cputs>

	return b.cnt;
}
  8001bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 87 ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 14             	sub    $0x14,%esp
  8001e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e9:	8b 03                	mov    (%ebx),%eax
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001f2:	83 c0 01             	add    $0x1,%eax
  8001f5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fc:	75 19                	jne    800217 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fe:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800205:	00 
  800206:	8d 43 08             	lea    0x8(%ebx),%eax
  800209:	89 04 24             	mov    %eax,(%esp)
  80020c:	e8 1b 0d 00 00       	call   800f2c <sys_cputs>
		b->idx = 0;
  800211:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800217:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021b:	83 c4 14             	add    $0x14,%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    
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
  80029f:	e8 fc 15 00 00       	call   8018a0 <__udivdi3>
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
  800307:	e8 c4 16 00 00       	call   8019d0 <__umoddi3>
  80030c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800310:	0f be 80 40 1b 80 00 	movsbl 0x801b40(%eax),%eax
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
  8003fa:	ff 24 95 80 1c 80 00 	jmp    *0x801c80(,%edx,4)
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
  8004b2:	83 f8 08             	cmp    $0x8,%eax
  8004b5:	7f 0b                	jg     8004c2 <vprintfmt+0x146>
  8004b7:	8b 14 85 e0 1d 80 00 	mov    0x801de0(,%eax,4),%edx
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	75 26                	jne    8004e8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c6:	c7 44 24 08 51 1b 80 	movl   $0x801b51,0x8(%esp)
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
  8004ec:	c7 44 24 08 5a 1b 80 	movl   $0x801b5a,0x8(%esp)
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
  80052a:	be 5d 1b 80 00       	mov    $0x801b5d,%esi
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
  8007d4:	e8 c7 10 00 00       	call   8018a0 <__udivdi3>
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
  800820:	e8 ab 11 00 00       	call   8019d0 <__umoddi3>
  800825:	89 74 24 04          	mov    %esi,0x4(%esp)
  800829:	0f be 80 40 1b 80 00 	movsbl 0x801b40(%eax),%eax
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
  8008d5:	c7 44 24 0c f8 1b 80 	movl   $0x801bf8,0xc(%esp)
  8008dc:	00 
  8008dd:	c7 44 24 08 5a 1b 80 	movl   $0x801b5a,0x8(%esp)
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
  80090b:	c7 44 24 0c 30 1c 80 	movl   $0x801c30,0xc(%esp)
  800912:	00 
  800913:	c7 44 24 08 5a 1b 80 	movl   $0x801b5a,0x8(%esp)
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
  80099f:	e8 2c 10 00 00       	call   8019d0 <__umoddi3>
  8009a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a8:	0f be 80 40 1b 80 00 	movsbl 0x801b40(%eax),%eax
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
  8009e1:	e8 ea 0f 00 00       	call   8019d0 <__umoddi3>
  8009e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ea:	0f be 80 40 1b 80 00 	movsbl 0x801b40(%eax),%eax
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

00800f6b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 28             	sub    $0x28,%esp
  800f71:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f74:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f84:	8b 55 08             	mov    0x8(%ebp),%edx
  800f87:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	7e 28                	jle    800fcd <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa9:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 08 04 1e 80 	movl   $0x801e04,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  800fc8:	e8 e7 07 00 00       	call   8017b4 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800fcd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fd0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd3:	89 ec                	mov    %ebp,%esp
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	89 1c 24             	mov    %ebx,(%esp)
  800fe0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	89 cb                	mov    %ecx,%ebx
  800ff3:	89 cf                	mov    %ecx,%edi
  800ff5:	51                   	push   %ecx
  800ff6:	52                   	push   %edx
  800ff7:	53                   	push   %ebx
  800ff8:	54                   	push   %esp
  800ff9:	55                   	push   %ebp
  800ffa:	56                   	push   %esi
  800ffb:	57                   	push   %edi
  800ffc:	54                   	push   %esp
  800ffd:	5d                   	pop    %ebp
  800ffe:	8d 35 06 10 80 00    	lea    0x801006,%esi
  801004:	0f 34                	sysenter 
  801006:	5f                   	pop    %edi
  801007:	5e                   	pop    %esi
  801008:	5d                   	pop    %ebp
  801009:	5c                   	pop    %esp
  80100a:	5b                   	pop    %ebx
  80100b:	5a                   	pop    %edx
  80100c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80100d:	8b 1c 24             	mov    (%esp),%ebx
  801010:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801014:	89 ec                	mov    %ebp,%esp
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 28             	sub    $0x28,%esp
  80101e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801021:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801024:	b9 00 00 00 00       	mov    $0x0,%ecx
  801029:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102e:	8b 55 08             	mov    0x8(%ebp),%edx
  801031:	89 cb                	mov    %ecx,%ebx
  801033:	89 cf                	mov    %ecx,%edi
  801035:	51                   	push   %ecx
  801036:	52                   	push   %edx
  801037:	53                   	push   %ebx
  801038:	54                   	push   %esp
  801039:	55                   	push   %ebp
  80103a:	56                   	push   %esi
  80103b:	57                   	push   %edi
  80103c:	54                   	push   %esp
  80103d:	5d                   	pop    %ebp
  80103e:	8d 35 46 10 80 00    	lea    0x801046,%esi
  801044:	0f 34                	sysenter 
  801046:	5f                   	pop    %edi
  801047:	5e                   	pop    %esi
  801048:	5d                   	pop    %ebp
  801049:	5c                   	pop    %esp
  80104a:	5b                   	pop    %ebx
  80104b:	5a                   	pop    %edx
  80104c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	7e 28                	jle    801079 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801051:	89 44 24 10          	mov    %eax,0x10(%esp)
  801055:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80105c:	00 
  80105d:	c7 44 24 08 04 1e 80 	movl   $0x801e04,0x8(%esp)
  801064:	00 
  801065:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80106c:	00 
  80106d:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  801074:	e8 3b 07 00 00       	call   8017b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801079:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80107c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107f:	89 ec                	mov    %ebp,%esp
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 08             	sub    $0x8,%esp
  801089:	89 1c 24             	mov    %ebx,(%esp)
  80108c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801090:	b8 0c 00 00 00       	mov    $0xc,%eax
  801095:	8b 7d 14             	mov    0x14(%ebp),%edi
  801098:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80109b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109e:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a1:	51                   	push   %ecx
  8010a2:	52                   	push   %edx
  8010a3:	53                   	push   %ebx
  8010a4:	54                   	push   %esp
  8010a5:	55                   	push   %ebp
  8010a6:	56                   	push   %esi
  8010a7:	57                   	push   %edi
  8010a8:	54                   	push   %esp
  8010a9:	5d                   	pop    %ebp
  8010aa:	8d 35 b2 10 80 00    	lea    0x8010b2,%esi
  8010b0:	0f 34                	sysenter 
  8010b2:	5f                   	pop    %edi
  8010b3:	5e                   	pop    %esi
  8010b4:	5d                   	pop    %ebp
  8010b5:	5c                   	pop    %esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5a                   	pop    %edx
  8010b8:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010b9:	8b 1c 24             	mov    (%esp),%ebx
  8010bc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010c0:	89 ec                	mov    %ebp,%esp
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 28             	sub    $0x28,%esp
  8010ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010cd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e0:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	7e 28                	jle    801126 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801102:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801109:	00 
  80110a:	c7 44 24 08 04 1e 80 	movl   $0x801e04,0x8(%esp)
  801111:	00 
  801112:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801119:	00 
  80111a:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  801121:	e8 8e 06 00 00       	call   8017b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801126:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801129:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80112c:	89 ec                	mov    %ebp,%esp
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	83 ec 28             	sub    $0x28,%esp
  801136:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801139:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801141:	b8 09 00 00 00       	mov    $0x9,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	89 df                	mov    %ebx,%edi
  80114e:	51                   	push   %ecx
  80114f:	52                   	push   %edx
  801150:	53                   	push   %ebx
  801151:	54                   	push   %esp
  801152:	55                   	push   %ebp
  801153:	56                   	push   %esi
  801154:	57                   	push   %edi
  801155:	54                   	push   %esp
  801156:	5d                   	pop    %ebp
  801157:	8d 35 5f 11 80 00    	lea    0x80115f,%esi
  80115d:	0f 34                	sysenter 
  80115f:	5f                   	pop    %edi
  801160:	5e                   	pop    %esi
  801161:	5d                   	pop    %ebp
  801162:	5c                   	pop    %esp
  801163:	5b                   	pop    %ebx
  801164:	5a                   	pop    %edx
  801165:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801166:	85 c0                	test   %eax,%eax
  801168:	7e 28                	jle    801192 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801175:	00 
  801176:	c7 44 24 08 04 1e 80 	movl   $0x801e04,0x8(%esp)
  80117d:	00 
  80117e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801185:	00 
  801186:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  80118d:	e8 22 06 00 00       	call   8017b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801192:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801195:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801198:	89 ec                	mov    %ebp,%esp
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 28             	sub    $0x28,%esp
  8011a2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011a5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ad:	b8 07 00 00 00       	mov    $0x7,%eax
  8011b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b8:	89 df                	mov    %ebx,%edi
  8011ba:	51                   	push   %ecx
  8011bb:	52                   	push   %edx
  8011bc:	53                   	push   %ebx
  8011bd:	54                   	push   %esp
  8011be:	55                   	push   %ebp
  8011bf:	56                   	push   %esi
  8011c0:	57                   	push   %edi
  8011c1:	54                   	push   %esp
  8011c2:	5d                   	pop    %ebp
  8011c3:	8d 35 cb 11 80 00    	lea    0x8011cb,%esi
  8011c9:	0f 34                	sysenter 
  8011cb:	5f                   	pop    %edi
  8011cc:	5e                   	pop    %esi
  8011cd:	5d                   	pop    %ebp
  8011ce:	5c                   	pop    %esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5a                   	pop    %edx
  8011d1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	7e 28                	jle    8011fe <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011da:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8011e1:	00 
  8011e2:	c7 44 24 08 04 1e 80 	movl   $0x801e04,0x8(%esp)
  8011e9:	00 
  8011ea:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011f1:	00 
  8011f2:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  8011f9:	e8 b6 05 00 00       	call   8017b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011fe:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801201:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801204:	89 ec                	mov    %ebp,%esp
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 28             	sub    $0x28,%esp
  80120e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801211:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801214:	8b 7d 18             	mov    0x18(%ebp),%edi
  801217:	0b 7d 14             	or     0x14(%ebp),%edi
  80121a:	b8 06 00 00 00       	mov    $0x6,%eax
  80121f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801222:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801225:	8b 55 08             	mov    0x8(%ebp),%edx
  801228:	51                   	push   %ecx
  801229:	52                   	push   %edx
  80122a:	53                   	push   %ebx
  80122b:	54                   	push   %esp
  80122c:	55                   	push   %ebp
  80122d:	56                   	push   %esi
  80122e:	57                   	push   %edi
  80122f:	54                   	push   %esp
  801230:	5d                   	pop    %ebp
  801231:	8d 35 39 12 80 00    	lea    0x801239,%esi
  801237:	0f 34                	sysenter 
  801239:	5f                   	pop    %edi
  80123a:	5e                   	pop    %esi
  80123b:	5d                   	pop    %ebp
  80123c:	5c                   	pop    %esp
  80123d:	5b                   	pop    %ebx
  80123e:	5a                   	pop    %edx
  80123f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801240:	85 c0                	test   %eax,%eax
  801242:	7e 28                	jle    80126c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801244:	89 44 24 10          	mov    %eax,0x10(%esp)
  801248:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80124f:	00 
  801250:	c7 44 24 08 04 1e 80 	movl   $0x801e04,0x8(%esp)
  801257:	00 
  801258:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80125f:	00 
  801260:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  801267:	e8 48 05 00 00       	call   8017b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80126c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80126f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801272:	89 ec                	mov    %ebp,%esp
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	83 ec 28             	sub    $0x28,%esp
  80127c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80127f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801282:	bf 00 00 00 00       	mov    $0x0,%edi
  801287:	b8 05 00 00 00       	mov    $0x5,%eax
  80128c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	8b 55 08             	mov    0x8(%ebp),%edx
  801295:	51                   	push   %ecx
  801296:	52                   	push   %edx
  801297:	53                   	push   %ebx
  801298:	54                   	push   %esp
  801299:	55                   	push   %ebp
  80129a:	56                   	push   %esi
  80129b:	57                   	push   %edi
  80129c:	54                   	push   %esp
  80129d:	5d                   	pop    %ebp
  80129e:	8d 35 a6 12 80 00    	lea    0x8012a6,%esi
  8012a4:	0f 34                	sysenter 
  8012a6:	5f                   	pop    %edi
  8012a7:	5e                   	pop    %esi
  8012a8:	5d                   	pop    %ebp
  8012a9:	5c                   	pop    %esp
  8012aa:	5b                   	pop    %ebx
  8012ab:	5a                   	pop    %edx
  8012ac:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	7e 28                	jle    8012d9 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b5:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 08 04 1e 80 	movl   $0x801e04,0x8(%esp)
  8012c4:	00 
  8012c5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012cc:	00 
  8012cd:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  8012d4:	e8 db 04 00 00       	call   8017b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012df:	89 ec                	mov    %ebp,%esp
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	89 1c 24             	mov    %ebx,(%esp)
  8012ec:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012fa:	89 d1                	mov    %edx,%ecx
  8012fc:	89 d3                	mov    %edx,%ebx
  8012fe:	89 d7                	mov    %edx,%edi
  801300:	51                   	push   %ecx
  801301:	52                   	push   %edx
  801302:	53                   	push   %ebx
  801303:	54                   	push   %esp
  801304:	55                   	push   %ebp
  801305:	56                   	push   %esi
  801306:	57                   	push   %edi
  801307:	54                   	push   %esp
  801308:	5d                   	pop    %ebp
  801309:	8d 35 11 13 80 00    	lea    0x801311,%esi
  80130f:	0f 34                	sysenter 
  801311:	5f                   	pop    %edi
  801312:	5e                   	pop    %esi
  801313:	5d                   	pop    %ebp
  801314:	5c                   	pop    %esp
  801315:	5b                   	pop    %ebx
  801316:	5a                   	pop    %edx
  801317:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801318:	8b 1c 24             	mov    (%esp),%ebx
  80131b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80131f:	89 ec                	mov    %ebp,%esp
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	89 1c 24             	mov    %ebx,(%esp)
  80132c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801330:	bb 00 00 00 00       	mov    $0x0,%ebx
  801335:	b8 04 00 00 00       	mov    $0x4,%eax
  80133a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133d:	8b 55 08             	mov    0x8(%ebp),%edx
  801340:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80135a:	8b 1c 24             	mov    (%esp),%ebx
  80135d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801361:	89 ec                	mov    %ebp,%esp
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	89 1c 24             	mov    %ebx,(%esp)
  80136e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
  801377:	b8 02 00 00 00       	mov    $0x2,%eax
  80137c:	89 d1                	mov    %edx,%ecx
  80137e:	89 d3                	mov    %edx,%ebx
  801380:	89 d7                	mov    %edx,%edi
  801382:	51                   	push   %ecx
  801383:	52                   	push   %edx
  801384:	53                   	push   %ebx
  801385:	54                   	push   %esp
  801386:	55                   	push   %ebp
  801387:	56                   	push   %esi
  801388:	57                   	push   %edi
  801389:	54                   	push   %esp
  80138a:	5d                   	pop    %ebp
  80138b:	8d 35 93 13 80 00    	lea    0x801393,%esi
  801391:	0f 34                	sysenter 
  801393:	5f                   	pop    %edi
  801394:	5e                   	pop    %esi
  801395:	5d                   	pop    %ebp
  801396:	5c                   	pop    %esp
  801397:	5b                   	pop    %ebx
  801398:	5a                   	pop    %edx
  801399:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80139a:	8b 1c 24             	mov    (%esp),%ebx
  80139d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013a1:	89 ec                	mov    %ebp,%esp
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	83 ec 28             	sub    $0x28,%esp
  8013ab:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013ae:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8013bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013be:	89 cb                	mov    %ecx,%ebx
  8013c0:	89 cf                	mov    %ecx,%edi
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
  8013dc:	7e 28                	jle    801406 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8013e9:	00 
  8013ea:	c7 44 24 08 04 1e 80 	movl   $0x801e04,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 21 1e 80 00 	movl   $0x801e21,(%esp)
  801401:	e8 ae 03 00 00       	call   8017b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801406:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801409:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80140c:	89 ec                	mov    %ebp,%esp
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801416:	c7 44 24 08 2f 1e 80 	movl   $0x801e2f,0x8(%esp)
  80141d:	00 
  80141e:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801425:	00 
  801426:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  80142d:	e8 82 03 00 00       	call   8017b4 <_panic>

00801432 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	57                   	push   %edi
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
  801438:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80143b:	c7 04 24 87 16 80 00 	movl   $0x801687,(%esp)
  801442:	e8 dd 03 00 00       	call   801824 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801447:	ba 08 00 00 00       	mov    $0x8,%edx
  80144c:	89 d0                	mov    %edx,%eax
  80144e:	cd 30                	int    $0x30
  801450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801453:	85 c0                	test   %eax,%eax
  801455:	79 20                	jns    801477 <fork+0x45>
		panic("sys_exofork: %e", envid);
  801457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145b:	c7 44 24 08 50 1e 80 	movl   $0x801e50,0x8(%esp)
  801462:	00 
  801463:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80146a:	00 
  80146b:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  801472:	e8 3d 03 00 00       	call   8017b4 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801477:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80147c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801481:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801486:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80148a:	75 20                	jne    8014ac <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80148c:	e8 d4 fe ff ff       	call   801365 <sys_getenvid>
  801491:	25 ff 03 00 00       	and    $0x3ff,%eax
  801496:	89 c2                	mov    %eax,%edx
  801498:	c1 e2 07             	shl    $0x7,%edx
  80149b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8014a2:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  8014a7:	e9 d0 01 00 00       	jmp    80167c <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8014ac:	89 d8                	mov    %ebx,%eax
  8014ae:	c1 e8 16             	shr    $0x16,%eax
  8014b1:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8014b4:	a8 01                	test   $0x1,%al
  8014b6:	0f 84 0d 01 00 00    	je     8015c9 <fork+0x197>
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	c1 e8 0c             	shr    $0xc,%eax
  8014c1:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8014c4:	f6 c2 01             	test   $0x1,%dl
  8014c7:	0f 84 fc 00 00 00    	je     8015c9 <fork+0x197>
  8014cd:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8014d0:	f6 c2 04             	test   $0x4,%dl
  8014d3:	0f 84 f0 00 00 00    	je     8015c9 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  8014d9:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	c1 ea 0c             	shr    $0xc,%edx
  8014e1:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  8014e4:	f6 c2 01             	test   $0x1,%dl
  8014e7:	0f 84 dc 00 00 00    	je     8015c9 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8014ed:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8014f3:	0f 84 8d 00 00 00    	je     801586 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8014f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014fc:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801503:	00 
  801504:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801508:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80150b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80150f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801513:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151a:	e8 e9 fc ff ff       	call   801208 <sys_page_map>
               if(r<0)
  80151f:	85 c0                	test   %eax,%eax
  801521:	79 1c                	jns    80153f <fork+0x10d>
                 panic("map failed");
  801523:	c7 44 24 08 60 1e 80 	movl   $0x801e60,0x8(%esp)
  80152a:	00 
  80152b:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801532:	00 
  801533:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  80153a:	e8 75 02 00 00       	call   8017b4 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  80153f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801546:	00 
  801547:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80154a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80154e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801555:	00 
  801556:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801561:	e8 a2 fc ff ff       	call   801208 <sys_page_map>
               if(r<0)
  801566:	85 c0                	test   %eax,%eax
  801568:	79 5f                	jns    8015c9 <fork+0x197>
                 panic("map failed");
  80156a:	c7 44 24 08 60 1e 80 	movl   $0x801e60,0x8(%esp)
  801571:	00 
  801572:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801579:	00 
  80157a:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  801581:	e8 2e 02 00 00       	call   8017b4 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801586:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80158d:	00 
  80158e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801592:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801595:	89 54 24 08          	mov    %edx,0x8(%esp)
  801599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a4:	e8 5f fc ff ff       	call   801208 <sys_page_map>
               if(r<0)
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	79 1c                	jns    8015c9 <fork+0x197>
                 panic("map failed");
  8015ad:	c7 44 24 08 60 1e 80 	movl   $0x801e60,0x8(%esp)
  8015b4:	00 
  8015b5:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8015bc:	00 
  8015bd:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  8015c4:	e8 eb 01 00 00       	call   8017b4 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8015c9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015cf:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8015d5:	0f 85 d1 fe ff ff    	jne    8014ac <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8015db:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015e2:	00 
  8015e3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015ea:	ee 
  8015eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015ee:	89 04 24             	mov    %eax,(%esp)
  8015f1:	e8 80 fc ff ff       	call   801276 <sys_page_alloc>
        if(r < 0)
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	79 1c                	jns    801616 <fork+0x1e4>
            panic("alloc failed");
  8015fa:	c7 44 24 08 6b 1e 80 	movl   $0x801e6b,0x8(%esp)
  801601:	00 
  801602:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801609:	00 
  80160a:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  801611:	e8 9e 01 00 00       	call   8017b4 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801616:	c7 44 24 04 70 18 80 	movl   $0x801870,0x4(%esp)
  80161d:	00 
  80161e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801621:	89 14 24             	mov    %edx,(%esp)
  801624:	e8 9b fa ff ff       	call   8010c4 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801629:	85 c0                	test   %eax,%eax
  80162b:	79 1c                	jns    801649 <fork+0x217>
            panic("set pgfault upcall failed");
  80162d:	c7 44 24 08 78 1e 80 	movl   $0x801e78,0x8(%esp)
  801634:	00 
  801635:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80163c:	00 
  80163d:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  801644:	e8 6b 01 00 00       	call   8017b4 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801649:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801650:	00 
  801651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801654:	89 04 24             	mov    %eax,(%esp)
  801657:	e8 d4 fa ff ff       	call   801130 <sys_env_set_status>
        if(r < 0)
  80165c:	85 c0                	test   %eax,%eax
  80165e:	79 1c                	jns    80167c <fork+0x24a>
            panic("set status failed");
  801660:	c7 44 24 08 92 1e 80 	movl   $0x801e92,0x8(%esp)
  801667:	00 
  801668:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80166f:	00 
  801670:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  801677:	e8 38 01 00 00       	call   8017b4 <_panic>
        return envid;
	//panic("fork not implemented");
}
  80167c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167f:	83 c4 3c             	add    $0x3c,%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	83 ec 24             	sub    $0x24,%esp
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801691:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801693:	89 da                	mov    %ebx,%edx
  801695:	c1 ea 0c             	shr    $0xc,%edx
  801698:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80169f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8016a3:	74 08                	je     8016ad <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  8016a5:	f7 c2 05 08 00 00    	test   $0x805,%edx
  8016ab:	75 1c                	jne    8016c9 <pgfault+0x42>
           panic("pgfault error");
  8016ad:	c7 44 24 08 a4 1e 80 	movl   $0x801ea4,0x8(%esp)
  8016b4:	00 
  8016b5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8016bc:	00 
  8016bd:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  8016c4:	e8 eb 00 00 00       	call   8017b4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016c9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016d0:	00 
  8016d1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8016d8:	00 
  8016d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e0:	e8 91 fb ff ff       	call   801276 <sys_page_alloc>
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	79 20                	jns    801709 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  8016e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016ed:	c7 44 24 08 b2 1e 80 	movl   $0x801eb2,0x8(%esp)
  8016f4:	00 
  8016f5:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8016fc:	00 
  8016fd:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  801704:	e8 ab 00 00 00       	call   8017b4 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  801709:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80170f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801716:	00 
  801717:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80171b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801722:	e8 be f5 ff ff       	call   800ce5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801727:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80172e:	00 
  80172f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801733:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80173a:	00 
  80173b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801742:	00 
  801743:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80174a:	e8 b9 fa ff ff       	call   801208 <sys_page_map>
  80174f:	85 c0                	test   %eax,%eax
  801751:	79 20                	jns    801773 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801753:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801757:	c7 44 24 08 c5 1e 80 	movl   $0x801ec5,0x8(%esp)
  80175e:	00 
  80175f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801766:	00 
  801767:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  80176e:	e8 41 00 00 00       	call   8017b4 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801773:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80177a:	00 
  80177b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801782:	e8 15 fa ff ff       	call   80119c <sys_page_unmap>
  801787:	85 c0                	test   %eax,%eax
  801789:	79 20                	jns    8017ab <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80178b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80178f:	c7 44 24 08 d6 1e 80 	movl   $0x801ed6,0x8(%esp)
  801796:	00 
  801797:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80179e:	00 
  80179f:	c7 04 24 45 1e 80 00 	movl   $0x801e45,(%esp)
  8017a6:	e8 09 00 00 00       	call   8017b4 <_panic>
	//panic("pgfault not implemented");
}
  8017ab:	83 c4 24             	add    $0x24,%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    
  8017b1:	00 00                	add    %al,(%eax)
	...

008017b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8017bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8017bf:	a1 08 20 80 00       	mov    0x802008,%eax
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	74 10                	je     8017d8 <_panic+0x24>
		cprintf("%s: ", argv0);
  8017c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cc:	c7 04 24 e9 1e 80 00 	movl   $0x801ee9,(%esp)
  8017d3:	e8 ed e9 ff ff       	call   8001c5 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8017d8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8017de:	e8 82 fb ff ff       	call   801365 <sys_getenvid>
  8017e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f9:	c7 04 24 f0 1e 80 00 	movl   $0x801ef0,(%esp)
  801800:	e8 c0 e9 ff ff       	call   8001c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801805:	89 74 24 04          	mov    %esi,0x4(%esp)
  801809:	8b 45 10             	mov    0x10(%ebp),%eax
  80180c:	89 04 24             	mov    %eax,(%esp)
  80180f:	e8 50 e9 ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  801814:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  80181b:	e8 a5 e9 ff ff       	call   8001c5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801820:	cc                   	int3   
  801821:	eb fd                	jmp    801820 <_panic+0x6c>
	...

00801824 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80182a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801831:	75 30                	jne    801863 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801833:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80183a:	00 
  80183b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801842:	ee 
  801843:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80184a:	e8 27 fa ff ff       	call   801276 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80184f:	c7 44 24 04 70 18 80 	movl   $0x801870,0x4(%esp)
  801856:	00 
  801857:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80185e:	e8 61 f8 ff ff       	call   8010c4 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    
  80186d:	00 00                	add    %al,(%eax)
	...

00801870 <_pgfault_upcall>:
  801870:	54                   	push   %esp
  801871:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801876:	ff d0                	call   *%eax
  801878:	83 c4 04             	add    $0x4,%esp
  80187b:	8b 44 24 28          	mov    0x28(%esp),%eax
  80187f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801883:	83 e9 04             	sub    $0x4,%ecx
  801886:	89 01                	mov    %eax,(%ecx)
  801888:	89 4c 24 30          	mov    %ecx,0x30(%esp)
  80188c:	83 c4 08             	add    $0x8,%esp
  80188f:	61                   	popa   
  801890:	83 c4 04             	add    $0x4,%esp
  801893:	9d                   	popf   
  801894:	5c                   	pop    %esp
  801895:	c3                   	ret    
	...

008018a0 <__udivdi3>:
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	57                   	push   %edi
  8018a4:	56                   	push   %esi
  8018a5:	83 ec 10             	sub    $0x10,%esp
  8018a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8018b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8018b9:	75 35                	jne    8018f0 <__udivdi3+0x50>
  8018bb:	39 fe                	cmp    %edi,%esi
  8018bd:	77 61                	ja     801920 <__udivdi3+0x80>
  8018bf:	85 f6                	test   %esi,%esi
  8018c1:	75 0b                	jne    8018ce <__udivdi3+0x2e>
  8018c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c8:	31 d2                	xor    %edx,%edx
  8018ca:	f7 f6                	div    %esi
  8018cc:	89 c6                	mov    %eax,%esi
  8018ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8018d1:	31 d2                	xor    %edx,%edx
  8018d3:	89 f8                	mov    %edi,%eax
  8018d5:	f7 f6                	div    %esi
  8018d7:	89 c7                	mov    %eax,%edi
  8018d9:	89 c8                	mov    %ecx,%eax
  8018db:	f7 f6                	div    %esi
  8018dd:	89 c1                	mov    %eax,%ecx
  8018df:	89 fa                	mov    %edi,%edx
  8018e1:	89 c8                	mov    %ecx,%eax
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	5e                   	pop    %esi
  8018e7:	5f                   	pop    %edi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    
  8018ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8018f0:	39 f8                	cmp    %edi,%eax
  8018f2:	77 1c                	ja     801910 <__udivdi3+0x70>
  8018f4:	0f bd d0             	bsr    %eax,%edx
  8018f7:	83 f2 1f             	xor    $0x1f,%edx
  8018fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8018fd:	75 39                	jne    801938 <__udivdi3+0x98>
  8018ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801902:	0f 86 a0 00 00 00    	jbe    8019a8 <__udivdi3+0x108>
  801908:	39 f8                	cmp    %edi,%eax
  80190a:	0f 82 98 00 00 00    	jb     8019a8 <__udivdi3+0x108>
  801910:	31 ff                	xor    %edi,%edi
  801912:	31 c9                	xor    %ecx,%ecx
  801914:	89 c8                	mov    %ecx,%eax
  801916:	89 fa                	mov    %edi,%edx
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	5e                   	pop    %esi
  80191c:	5f                   	pop    %edi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    
  80191f:	90                   	nop
  801920:	89 d1                	mov    %edx,%ecx
  801922:	89 fa                	mov    %edi,%edx
  801924:	89 c8                	mov    %ecx,%eax
  801926:	31 ff                	xor    %edi,%edi
  801928:	f7 f6                	div    %esi
  80192a:	89 c1                	mov    %eax,%ecx
  80192c:	89 fa                	mov    %edi,%edx
  80192e:	89 c8                	mov    %ecx,%eax
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	5e                   	pop    %esi
  801934:	5f                   	pop    %edi
  801935:	5d                   	pop    %ebp
  801936:	c3                   	ret    
  801937:	90                   	nop
  801938:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80193c:	89 f2                	mov    %esi,%edx
  80193e:	d3 e0                	shl    %cl,%eax
  801940:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801943:	b8 20 00 00 00       	mov    $0x20,%eax
  801948:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80194b:	89 c1                	mov    %eax,%ecx
  80194d:	d3 ea                	shr    %cl,%edx
  80194f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801953:	0b 55 ec             	or     -0x14(%ebp),%edx
  801956:	d3 e6                	shl    %cl,%esi
  801958:	89 c1                	mov    %eax,%ecx
  80195a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80195d:	89 fe                	mov    %edi,%esi
  80195f:	d3 ee                	shr    %cl,%esi
  801961:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801965:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801968:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80196b:	d3 e7                	shl    %cl,%edi
  80196d:	89 c1                	mov    %eax,%ecx
  80196f:	d3 ea                	shr    %cl,%edx
  801971:	09 d7                	or     %edx,%edi
  801973:	89 f2                	mov    %esi,%edx
  801975:	89 f8                	mov    %edi,%eax
  801977:	f7 75 ec             	divl   -0x14(%ebp)
  80197a:	89 d6                	mov    %edx,%esi
  80197c:	89 c7                	mov    %eax,%edi
  80197e:	f7 65 e8             	mull   -0x18(%ebp)
  801981:	39 d6                	cmp    %edx,%esi
  801983:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801986:	72 30                	jb     8019b8 <__udivdi3+0x118>
  801988:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80198b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80198f:	d3 e2                	shl    %cl,%edx
  801991:	39 c2                	cmp    %eax,%edx
  801993:	73 05                	jae    80199a <__udivdi3+0xfa>
  801995:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801998:	74 1e                	je     8019b8 <__udivdi3+0x118>
  80199a:	89 f9                	mov    %edi,%ecx
  80199c:	31 ff                	xor    %edi,%edi
  80199e:	e9 71 ff ff ff       	jmp    801914 <__udivdi3+0x74>
  8019a3:	90                   	nop
  8019a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019a8:	31 ff                	xor    %edi,%edi
  8019aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8019af:	e9 60 ff ff ff       	jmp    801914 <__udivdi3+0x74>
  8019b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8019bb:	31 ff                	xor    %edi,%edi
  8019bd:	89 c8                	mov    %ecx,%eax
  8019bf:	89 fa                	mov    %edi,%edx
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	5e                   	pop    %esi
  8019c5:	5f                   	pop    %edi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    
	...

008019d0 <__umoddi3>:
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	57                   	push   %edi
  8019d4:	56                   	push   %esi
  8019d5:	83 ec 20             	sub    $0x20,%esp
  8019d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8019db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8019e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e4:	85 d2                	test   %edx,%edx
  8019e6:	89 c8                	mov    %ecx,%eax
  8019e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8019eb:	75 13                	jne    801a00 <__umoddi3+0x30>
  8019ed:	39 f7                	cmp    %esi,%edi
  8019ef:	76 3f                	jbe    801a30 <__umoddi3+0x60>
  8019f1:	89 f2                	mov    %esi,%edx
  8019f3:	f7 f7                	div    %edi
  8019f5:	89 d0                	mov    %edx,%eax
  8019f7:	31 d2                	xor    %edx,%edx
  8019f9:	83 c4 20             	add    $0x20,%esp
  8019fc:	5e                   	pop    %esi
  8019fd:	5f                   	pop    %edi
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    
  801a00:	39 f2                	cmp    %esi,%edx
  801a02:	77 4c                	ja     801a50 <__umoddi3+0x80>
  801a04:	0f bd ca             	bsr    %edx,%ecx
  801a07:	83 f1 1f             	xor    $0x1f,%ecx
  801a0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a0d:	75 51                	jne    801a60 <__umoddi3+0x90>
  801a0f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801a12:	0f 87 e0 00 00 00    	ja     801af8 <__umoddi3+0x128>
  801a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1b:	29 f8                	sub    %edi,%eax
  801a1d:	19 d6                	sbb    %edx,%esi
  801a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	89 f2                	mov    %esi,%edx
  801a27:	83 c4 20             	add    $0x20,%esp
  801a2a:	5e                   	pop    %esi
  801a2b:	5f                   	pop    %edi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    
  801a2e:	66 90                	xchg   %ax,%ax
  801a30:	85 ff                	test   %edi,%edi
  801a32:	75 0b                	jne    801a3f <__umoddi3+0x6f>
  801a34:	b8 01 00 00 00       	mov    $0x1,%eax
  801a39:	31 d2                	xor    %edx,%edx
  801a3b:	f7 f7                	div    %edi
  801a3d:	89 c7                	mov    %eax,%edi
  801a3f:	89 f0                	mov    %esi,%eax
  801a41:	31 d2                	xor    %edx,%edx
  801a43:	f7 f7                	div    %edi
  801a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a48:	f7 f7                	div    %edi
  801a4a:	eb a9                	jmp    8019f5 <__umoddi3+0x25>
  801a4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a50:	89 c8                	mov    %ecx,%eax
  801a52:	89 f2                	mov    %esi,%edx
  801a54:	83 c4 20             	add    $0x20,%esp
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    
  801a5b:	90                   	nop
  801a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801a64:	d3 e2                	shl    %cl,%edx
  801a66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801a69:	ba 20 00 00 00       	mov    $0x20,%edx
  801a6e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801a71:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a74:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801a78:	89 fa                	mov    %edi,%edx
  801a7a:	d3 ea                	shr    %cl,%edx
  801a7c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801a80:	0b 55 f4             	or     -0xc(%ebp),%edx
  801a83:	d3 e7                	shl    %cl,%edi
  801a85:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801a89:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801a8c:	89 f2                	mov    %esi,%edx
  801a8e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801a91:	89 c7                	mov    %eax,%edi
  801a93:	d3 ea                	shr    %cl,%edx
  801a95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801a99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801a9c:	89 c2                	mov    %eax,%edx
  801a9e:	d3 e6                	shl    %cl,%esi
  801aa0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801aa4:	d3 ea                	shr    %cl,%edx
  801aa6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801aaa:	09 d6                	or     %edx,%esi
  801aac:	89 f0                	mov    %esi,%eax
  801aae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801ab1:	d3 e7                	shl    %cl,%edi
  801ab3:	89 f2                	mov    %esi,%edx
  801ab5:	f7 75 f4             	divl   -0xc(%ebp)
  801ab8:	89 d6                	mov    %edx,%esi
  801aba:	f7 65 e8             	mull   -0x18(%ebp)
  801abd:	39 d6                	cmp    %edx,%esi
  801abf:	72 2b                	jb     801aec <__umoddi3+0x11c>
  801ac1:	39 c7                	cmp    %eax,%edi
  801ac3:	72 23                	jb     801ae8 <__umoddi3+0x118>
  801ac5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ac9:	29 c7                	sub    %eax,%edi
  801acb:	19 d6                	sbb    %edx,%esi
  801acd:	89 f0                	mov    %esi,%eax
  801acf:	89 f2                	mov    %esi,%edx
  801ad1:	d3 ef                	shr    %cl,%edi
  801ad3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ad7:	d3 e0                	shl    %cl,%eax
  801ad9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801add:	09 f8                	or     %edi,%eax
  801adf:	d3 ea                	shr    %cl,%edx
  801ae1:	83 c4 20             	add    $0x20,%esp
  801ae4:	5e                   	pop    %esi
  801ae5:	5f                   	pop    %edi
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    
  801ae8:	39 d6                	cmp    %edx,%esi
  801aea:	75 d9                	jne    801ac5 <__umoddi3+0xf5>
  801aec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801aef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801af2:	eb d1                	jmp    801ac5 <__umoddi3+0xf5>
  801af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af8:	39 f2                	cmp    %esi,%edx
  801afa:	0f 82 18 ff ff ff    	jb     801a18 <__umoddi3+0x48>
  801b00:	e9 1d ff ff ff       	jmp    801a22 <__umoddi3+0x52>
