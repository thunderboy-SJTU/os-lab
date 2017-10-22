
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 ce 14 00 00       	call   801510 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 0e 14 00 00       	call   801462 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  800063:	e8 b5 01 00 00       	call   80021d <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 f2 13 00 00       	call   801462 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 1a 26 80 00 	movl   $0x80261a,(%esp)
  80007f:	e8 99 01 00 00       	call   80021d <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 64 18 00 00       	call   80190b <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 c7 18 00 00       	call   801989 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 86 13 00 00       	call   801462 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
  8000fa:	e8 1e 01 00 00       	call   80021d <cprintf>
		if (val == 10)
  8000ff:	a1 04 40 80 00       	mov    0x804004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 d7 17 00 00       	call   80190b <ipc_send>
		if (val == 10)
  800134:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80015e:	e8 ff 12 00 00       	call   801462 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	89 c2                	mov    %eax,%edx
  80016a:	c1 e2 07             	shl    $0x7,%edx
  80016d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800174:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x38>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	89 34 24             	mov    %esi,(%esp)
  80018b:	e8 a4 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a6:	e8 30 1d 00 00       	call   801edb <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 eb 12 00 00       	call   8014a2 <sys_env_destroy>
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
  8001b9:	00 00                	add    %al,(%eax)
	...

008001bc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cc:	00 00 00 
	b.cnt = 0;
  8001cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f1:	c7 04 24 37 02 80 00 	movl   $0x800237,(%esp)
  8001f8:	e8 cf 01 00 00       	call   8003cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800203:	89 44 24 04          	mov    %eax,0x4(%esp)
  800207:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020d:	89 04 24             	mov    %eax,(%esp)
  800210:	e8 67 0d 00 00       	call   800f7c <sys_cputs>

	return b.cnt;
}
  800215:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800223:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	89 04 24             	mov    %eax,(%esp)
  800230:	e8 87 ff ff ff       	call   8001bc <vcprintf>
	va_end(ap);

	return cnt;
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	53                   	push   %ebx
  80023b:	83 ec 14             	sub    $0x14,%esp
  80023e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800241:	8b 03                	mov    (%ebx),%eax
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80024a:	83 c0 01             	add    $0x1,%eax
  80024d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80024f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800254:	75 19                	jne    80026f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800256:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80025d:	00 
  80025e:	8d 43 08             	lea    0x8(%ebx),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 13 0d 00 00       	call   800f7c <sys_cputs>
		b->idx = 0;
  800269:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80026f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800273:	83 c4 14             	add    $0x14,%esp
  800276:	5b                   	pop    %ebx
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    
  800279:	00 00                	add    %al,(%eax)
  80027b:	00 00                	add    %al,(%eax)
  80027d:	00 00                	add    %al,(%eax)
	...

00800280 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8002a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ab:	39 d1                	cmp    %edx,%ecx
  8002ad:	72 07                	jb     8002b6 <printnum_v2+0x36>
  8002af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b2:	39 d0                	cmp    %edx,%eax
  8002b4:	77 5f                	ja     800315 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002ba:	83 eb 01             	sub    $0x1,%ebx
  8002bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002c9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002d0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e1:	00 
  8002e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ef:	e8 9c 20 00 00       	call   802390 <__udivdi3>
  8002f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	89 54 24 04          	mov    %edx,0x4(%esp)
  800309:	89 f2                	mov    %esi,%edx
  80030b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030e:	e8 6d ff ff ff       	call   800280 <printnum_v2>
  800313:	eb 1e                	jmp    800333 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800315:	83 ff 2d             	cmp    $0x2d,%edi
  800318:	74 19                	je     800333 <printnum_v2+0xb3>
		while (--width > 0)
  80031a:	83 eb 01             	sub    $0x1,%ebx
  80031d:	85 db                	test   %ebx,%ebx
  80031f:	90                   	nop
  800320:	7e 11                	jle    800333 <printnum_v2+0xb3>
			putch(padc, putdat);
  800322:	89 74 24 04          	mov    %esi,0x4(%esp)
  800326:	89 3c 24             	mov    %edi,(%esp)
  800329:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80032c:	83 eb 01             	sub    $0x1,%ebx
  80032f:	85 db                	test   %ebx,%ebx
  800331:	7f ef                	jg     800322 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800333:	89 74 24 04          	mov    %esi,0x4(%esp)
  800337:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800342:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800349:	00 
  80034a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80034d:	89 14 24             	mov    %edx,(%esp)
  800350:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800353:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800357:	e8 64 21 00 00       	call   8024c0 <__umoddi3>
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	0f be 80 60 26 80 00 	movsbl 0x802660(%eax),%eax
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80036d:	83 c4 4c             	add    $0x4c,%esp
  800370:	5b                   	pop    %ebx
  800371:	5e                   	pop    %esi
  800372:	5f                   	pop    %edi
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800378:	83 fa 01             	cmp    $0x1,%edx
  80037b:	7e 0e                	jle    80038b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	8b 52 04             	mov    0x4(%edx),%edx
  800389:	eb 22                	jmp    8003ad <getuint+0x38>
	else if (lflag)
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 10                	je     80039f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	8d 4a 04             	lea    0x4(%edx),%ecx
  800394:	89 08                	mov    %ecx,(%eax)
  800396:	8b 02                	mov    (%edx),%eax
  800398:	ba 00 00 00 00       	mov    $0x0,%edx
  80039d:	eb 0e                	jmp    8003ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b9:	8b 10                	mov    (%eax),%edx
  8003bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003be:	73 0a                	jae    8003ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c3:	88 0a                	mov    %cl,(%edx)
  8003c5:	83 c2 01             	add    $0x1,%edx
  8003c8:	89 10                	mov    %edx,(%eax)
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	57                   	push   %edi
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
  8003d2:	83 ec 6c             	sub    $0x6c,%esp
  8003d5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003d8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003df:	eb 1a                	jmp    8003fb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	0f 84 66 06 00 00    	je     800a4f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8003e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	ff 55 08             	call   *0x8(%ebp)
  8003f6:	eb 03                	jmp    8003fb <vprintfmt+0x2f>
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003fb:	0f b6 07             	movzbl (%edi),%eax
  8003fe:	83 c7 01             	add    $0x1,%edi
  800401:	83 f8 25             	cmp    $0x25,%eax
  800404:	75 db                	jne    8003e1 <vprintfmt+0x15>
  800406:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80040a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800416:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80041b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800422:	be 00 00 00 00       	mov    $0x0,%esi
  800427:	eb 06                	jmp    80042f <vprintfmt+0x63>
  800429:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80042d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	0f b6 17             	movzbl (%edi),%edx
  800432:	0f b6 c2             	movzbl %dl,%eax
  800435:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800438:	8d 47 01             	lea    0x1(%edi),%eax
  80043b:	83 ea 23             	sub    $0x23,%edx
  80043e:	80 fa 55             	cmp    $0x55,%dl
  800441:	0f 87 60 05 00 00    	ja     8009a7 <vprintfmt+0x5db>
  800447:	0f b6 d2             	movzbl %dl,%edx
  80044a:	ff 24 95 40 28 80 00 	jmp    *0x802840(,%edx,4)
  800451:	b9 01 00 00 00       	mov    $0x1,%ecx
  800456:	eb d5                	jmp    80042d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800458:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80045b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80045e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800461:	8d 7a d0             	lea    -0x30(%edx),%edi
  800464:	83 ff 09             	cmp    $0x9,%edi
  800467:	76 08                	jbe    800471 <vprintfmt+0xa5>
  800469:	eb 40                	jmp    8004ab <vprintfmt+0xdf>
  80046b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80046f:	eb bc                	jmp    80042d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800471:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800474:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800477:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80047b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80047e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800481:	83 ff 09             	cmp    $0x9,%edi
  800484:	76 eb                	jbe    800471 <vprintfmt+0xa5>
  800486:	eb 23                	jmp    8004ab <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800488:	8b 55 14             	mov    0x14(%ebp),%edx
  80048b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80048e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800491:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800493:	eb 16                	jmp    8004ab <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800495:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800498:	c1 fa 1f             	sar    $0x1f,%edx
  80049b:	f7 d2                	not    %edx
  80049d:	21 55 d8             	and    %edx,-0x28(%ebp)
  8004a0:	eb 8b                	jmp    80042d <vprintfmt+0x61>
  8004a2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004a9:	eb 82                	jmp    80042d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8004ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004af:	0f 89 78 ff ff ff    	jns    80042d <vprintfmt+0x61>
  8004b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004b8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8004bb:	e9 6d ff ff ff       	jmp    80042d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8004c3:	e9 65 ff ff ff       	jmp    80042d <vprintfmt+0x61>
  8004c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	89 04 24             	mov    %eax,(%esp)
  8004e0:	ff 55 08             	call   *0x8(%ebp)
  8004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8004e6:	e9 10 ff ff ff       	jmp    8003fb <vprintfmt+0x2f>
  8004eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	8b 00                	mov    (%eax),%eax
  8004f9:	89 c2                	mov    %eax,%edx
  8004fb:	c1 fa 1f             	sar    $0x1f,%edx
  8004fe:	31 d0                	xor    %edx,%eax
  800500:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800502:	83 f8 0f             	cmp    $0xf,%eax
  800505:	7f 0b                	jg     800512 <vprintfmt+0x146>
  800507:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	75 26                	jne    800538 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800512:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800516:	c7 44 24 08 71 26 80 	movl   $0x802671,0x8(%esp)
  80051d:	00 
  80051e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800521:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800525:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800528:	89 1c 24             	mov    %ebx,(%esp)
  80052b:	e8 a7 05 00 00       	call   800ad7 <printfmt>
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800533:	e9 c3 fe ff ff       	jmp    8003fb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800538:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053c:	c7 44 24 08 7a 26 80 	movl   $0x80267a,0x8(%esp)
  800543:	00 
  800544:	8b 45 0c             	mov    0xc(%ebp),%eax
  800547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054b:	8b 55 08             	mov    0x8(%ebp),%edx
  80054e:	89 14 24             	mov    %edx,(%esp)
  800551:	e8 81 05 00 00       	call   800ad7 <printfmt>
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800559:	e9 9d fe ff ff       	jmp    8003fb <vprintfmt+0x2f>
  80055e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800561:	89 c7                	mov    %eax,%edi
  800563:	89 d9                	mov    %ebx,%ecx
  800565:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800568:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 04             	lea    0x4(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 30                	mov    (%eax),%esi
  800576:	85 f6                	test   %esi,%esi
  800578:	75 05                	jne    80057f <vprintfmt+0x1b3>
  80057a:	be 7d 26 80 00       	mov    $0x80267d,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80057f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800583:	7e 06                	jle    80058b <vprintfmt+0x1bf>
  800585:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800589:	75 10                	jne    80059b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058b:	0f be 06             	movsbl (%esi),%eax
  80058e:	85 c0                	test   %eax,%eax
  800590:	0f 85 a2 00 00 00    	jne    800638 <vprintfmt+0x26c>
  800596:	e9 92 00 00 00       	jmp    80062d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80059f:	89 34 24             	mov    %esi,(%esp)
  8005a2:	e8 74 05 00 00       	call   800b1b <strnlen>
  8005a7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005aa:	29 c2                	sub    %eax,%edx
  8005ac:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	7e d8                	jle    80058b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8005b3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8005b7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005ba:	89 d3                	mov    %edx,%ebx
  8005bc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005bf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8005c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005c5:	89 ce                	mov    %ecx,%esi
  8005c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005cb:	89 34 24             	mov    %esi,(%esp)
  8005ce:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	83 eb 01             	sub    $0x1,%ebx
  8005d4:	85 db                	test   %ebx,%ebx
  8005d6:	7f ef                	jg     8005c7 <vprintfmt+0x1fb>
  8005d8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005de:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8005e1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005e8:	eb a1                	jmp    80058b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ea:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005ee:	74 1b                	je     80060b <vprintfmt+0x23f>
  8005f0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005f3:	83 fa 5e             	cmp    $0x5e,%edx
  8005f6:	76 13                	jbe    80060b <vprintfmt+0x23f>
					putch('?', putdat);
  8005f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ff:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800606:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800609:	eb 0d                	jmp    800618 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80060b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800612:	89 04 24             	mov    %eax,(%esp)
  800615:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800618:	83 ef 01             	sub    $0x1,%edi
  80061b:	0f be 06             	movsbl (%esi),%eax
  80061e:	85 c0                	test   %eax,%eax
  800620:	74 05                	je     800627 <vprintfmt+0x25b>
  800622:	83 c6 01             	add    $0x1,%esi
  800625:	eb 1a                	jmp    800641 <vprintfmt+0x275>
  800627:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80062a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800631:	7f 1f                	jg     800652 <vprintfmt+0x286>
  800633:	e9 c0 fd ff ff       	jmp    8003f8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800638:	83 c6 01             	add    $0x1,%esi
  80063b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80063e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800641:	85 db                	test   %ebx,%ebx
  800643:	78 a5                	js     8005ea <vprintfmt+0x21e>
  800645:	83 eb 01             	sub    $0x1,%ebx
  800648:	79 a0                	jns    8005ea <vprintfmt+0x21e>
  80064a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80064d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800650:	eb db                	jmp    80062d <vprintfmt+0x261>
  800652:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800655:	8b 75 0c             	mov    0xc(%ebp),%esi
  800658:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80065b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800662:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800669:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066b:	83 eb 01             	sub    $0x1,%ebx
  80066e:	85 db                	test   %ebx,%ebx
  800670:	7f ec                	jg     80065e <vprintfmt+0x292>
  800672:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800675:	e9 81 fd ff ff       	jmp    8003fb <vprintfmt+0x2f>
  80067a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067d:	83 fe 01             	cmp    $0x1,%esi
  800680:	7e 10                	jle    800692 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 08             	lea    0x8(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 18                	mov    (%eax),%ebx
  80068d:	8b 70 04             	mov    0x4(%eax),%esi
  800690:	eb 26                	jmp    8006b8 <vprintfmt+0x2ec>
	else if (lflag)
  800692:	85 f6                	test   %esi,%esi
  800694:	74 12                	je     8006a8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)
  80069f:	8b 18                	mov    (%eax),%ebx
  8006a1:	89 de                	mov    %ebx,%esi
  8006a3:	c1 fe 1f             	sar    $0x1f,%esi
  8006a6:	eb 10                	jmp    8006b8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 50 04             	lea    0x4(%eax),%edx
  8006ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b1:	8b 18                	mov    (%eax),%ebx
  8006b3:	89 de                	mov    %ebx,%esi
  8006b5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8006b8:	83 f9 01             	cmp    $0x1,%ecx
  8006bb:	75 1e                	jne    8006db <vprintfmt+0x30f>
                               if((long long)num > 0){
  8006bd:	85 f6                	test   %esi,%esi
  8006bf:	78 1a                	js     8006db <vprintfmt+0x30f>
  8006c1:	85 f6                	test   %esi,%esi
  8006c3:	7f 05                	jg     8006ca <vprintfmt+0x2fe>
  8006c5:	83 fb 00             	cmp    $0x0,%ebx
  8006c8:	76 11                	jbe    8006db <vprintfmt+0x30f>
                                   putch('+',putdat);
  8006ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006d1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8006d8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8006db:	85 f6                	test   %esi,%esi
  8006dd:	78 13                	js     8006f2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006df:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8006e2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8006e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ed:	e9 da 00 00 00       	jmp    8007cc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8006f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800700:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800703:	89 da                	mov    %ebx,%edx
  800705:	89 f1                	mov    %esi,%ecx
  800707:	f7 da                	neg    %edx
  800709:	83 d1 00             	adc    $0x0,%ecx
  80070c:	f7 d9                	neg    %ecx
  80070e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800711:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800717:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071c:	e9 ab 00 00 00       	jmp    8007cc <vprintfmt+0x400>
  800721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800724:	89 f2                	mov    %esi,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 47 fc ff ff       	call   800375 <getuint>
  80072e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800731:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800737:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80073c:	e9 8b 00 00 00       	jmp    8007cc <vprintfmt+0x400>
  800741:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800747:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80074b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800752:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800755:	89 f2                	mov    %esi,%edx
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	e8 16 fc ff ff       	call   800375 <getuint>
  80075f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800762:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800768:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80076d:	eb 5d                	jmp    8007cc <vprintfmt+0x400>
  80076f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800775:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800779:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800780:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800783:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800787:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80078e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	8b 10                	mov    (%eax),%edx
  80079c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007a4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007aa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007af:	eb 1b                	jmp    8007cc <vprintfmt+0x400>
  8007b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b4:	89 f2                	mov    %esi,%edx
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 b7 fb ff ff       	call   800375 <getuint>
  8007be:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007c1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007cc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8007d0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007d6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8007da:	77 09                	ja     8007e5 <vprintfmt+0x419>
  8007dc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8007df:	0f 82 ac 00 00 00    	jb     800891 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8007e5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007e8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8007ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ef:	83 ea 01             	sub    $0x1,%edx
  8007f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fa:	8b 44 24 08          	mov    0x8(%esp),%eax
  8007fe:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800802:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800805:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800808:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80080b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80080f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800816:	00 
  800817:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80081a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80081d:	89 0c 24             	mov    %ecx,(%esp)
  800820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800824:	e8 67 1b 00 00       	call   802390 <__udivdi3>
  800829:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80082c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80082f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800833:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800837:	89 04 24             	mov    %eax,(%esp)
  80083a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	e8 37 fa ff ff       	call   800280 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800850:	8b 74 24 04          	mov    0x4(%esp),%esi
  800854:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800857:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800862:	00 
  800863:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800866:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800869:	89 14 24             	mov    %edx,(%esp)
  80086c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800870:	e8 4b 1c 00 00       	call   8024c0 <__umoddi3>
  800875:	89 74 24 04          	mov    %esi,0x4(%esp)
  800879:	0f be 80 60 26 80 00 	movsbl 0x802660(%eax),%eax
  800880:	89 04 24             	mov    %eax,(%esp)
  800883:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800886:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80088a:	74 54                	je     8008e0 <vprintfmt+0x514>
  80088c:	e9 67 fb ff ff       	jmp    8003f8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800891:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800895:	8d 76 00             	lea    0x0(%esi),%esi
  800898:	0f 84 2a 01 00 00    	je     8009c8 <vprintfmt+0x5fc>
		while (--width > 0)
  80089e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008a1:	83 ef 01             	sub    $0x1,%edi
  8008a4:	85 ff                	test   %edi,%edi
  8008a6:	0f 8e 5e 01 00 00    	jle    800a0a <vprintfmt+0x63e>
  8008ac:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008af:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008b2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8008b5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8008b8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008bb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8008be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c2:	89 1c 24             	mov    %ebx,(%esp)
  8008c5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8008c8:	83 ef 01             	sub    $0x1,%edi
  8008cb:	85 ff                	test   %edi,%edi
  8008cd:	7f ef                	jg     8008be <vprintfmt+0x4f2>
  8008cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008d5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8008d8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8008db:	e9 2a 01 00 00       	jmp    800a0a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8008e3:	83 eb 01             	sub    $0x1,%ebx
  8008e6:	85 db                	test   %ebx,%ebx
  8008e8:	0f 8e 0a fb ff ff    	jle    8003f8 <vprintfmt+0x2c>
  8008ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008f4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8008f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008fb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800902:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800904:	83 eb 01             	sub    $0x1,%ebx
  800907:	85 db                	test   %ebx,%ebx
  800909:	7f ec                	jg     8008f7 <vprintfmt+0x52b>
  80090b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80090e:	e9 e8 fa ff ff       	jmp    8003fb <vprintfmt+0x2f>
  800913:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	8d 50 04             	lea    0x4(%eax),%edx
  80091c:	89 55 14             	mov    %edx,0x14(%ebp)
  80091f:	8b 00                	mov    (%eax),%eax
  800921:	85 c0                	test   %eax,%eax
  800923:	75 2a                	jne    80094f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800925:	c7 44 24 0c 98 27 80 	movl   $0x802798,0xc(%esp)
  80092c:	00 
  80092d:	c7 44 24 08 7a 26 80 	movl   $0x80267a,0x8(%esp)
  800934:	00 
  800935:	8b 55 0c             	mov    0xc(%ebp),%edx
  800938:	89 54 24 04          	mov    %edx,0x4(%esp)
  80093c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093f:	89 0c 24             	mov    %ecx,(%esp)
  800942:	e8 90 01 00 00       	call   800ad7 <printfmt>
  800947:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80094a:	e9 ac fa ff ff       	jmp    8003fb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	8b 13                	mov    (%ebx),%edx
  800954:	83 fa 7f             	cmp    $0x7f,%edx
  800957:	7e 29                	jle    800982 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800959:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80095b:	c7 44 24 0c d0 27 80 	movl   $0x8027d0,0xc(%esp)
  800962:	00 
  800963:	c7 44 24 08 7a 26 80 	movl   $0x80267a,0x8(%esp)
  80096a:	00 
  80096b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	89 04 24             	mov    %eax,(%esp)
  800975:	e8 5d 01 00 00       	call   800ad7 <printfmt>
  80097a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80097d:	e9 79 fa ff ff       	jmp    8003fb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800982:	88 10                	mov    %dl,(%eax)
  800984:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800987:	e9 6f fa ff ff       	jmp    8003fb <vprintfmt+0x2f>
  80098c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80098f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800992:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800995:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800999:	89 14 24             	mov    %edx,(%esp)
  80099c:	ff 55 08             	call   *0x8(%ebp)
  80099f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8009a2:	e9 54 fa ff ff       	jmp    8003fb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8009bb:	80 38 25             	cmpb   $0x25,(%eax)
  8009be:	0f 84 37 fa ff ff    	je     8003fb <vprintfmt+0x2f>
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	eb f0                	jmp    8009b8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009d3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009e1:	00 
  8009e2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009e5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009e8:	89 04 24             	mov    %eax,(%esp)
  8009eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009ef:	e8 cc 1a 00 00       	call   8024c0 <__umoddi3>
  8009f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f8:	0f be 80 60 26 80 00 	movsbl 0x802660(%eax),%eax
  8009ff:	89 04 24             	mov    %eax,(%esp)
  800a02:	ff 55 08             	call   *0x8(%ebp)
  800a05:	e9 d6 fe ff ff       	jmp    8008e0 <vprintfmt+0x514>
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a11:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a15:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a1c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a23:	00 
  800a24:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a27:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a2a:	89 04 24             	mov    %eax,(%esp)
  800a2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a31:	e8 8a 1a 00 00       	call   8024c0 <__umoddi3>
  800a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3a:	0f be 80 60 26 80 00 	movsbl 0x802660(%eax),%eax
  800a41:	89 04 24             	mov    %eax,(%esp)
  800a44:	ff 55 08             	call   *0x8(%ebp)
  800a47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a4a:	e9 ac f9 ff ff       	jmp    8003fb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a4f:	83 c4 6c             	add    $0x6c,%esp
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	83 ec 28             	sub    $0x28,%esp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a63:	85 c0                	test   %eax,%eax
  800a65:	74 04                	je     800a6b <vsnprintf+0x14>
  800a67:	85 d2                	test   %edx,%edx
  800a69:	7f 07                	jg     800a72 <vsnprintf+0x1b>
  800a6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a70:	eb 3b                	jmp    800aad <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a75:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a83:	8b 45 14             	mov    0x14(%ebp),%eax
  800a86:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a91:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a98:	c7 04 24 af 03 80 00 	movl   $0x8003af,(%esp)
  800a9f:	e8 28 f9 ff ff       	call   8003cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aa7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800ab5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800ab8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	89 04 24             	mov    %eax,(%esp)
  800ad0:	e8 82 ff ff ff       	call   800a57 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800add:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800ae0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	89 04 24             	mov    %eax,(%esp)
  800af8:	e8 cf f8 ff ff       	call   8003cc <vprintfmt>
	va_end(ap);
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    
	...

00800b00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b0e:	74 09                	je     800b19 <strlen+0x19>
		n++;
  800b10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b17:	75 f7                	jne    800b10 <strlen+0x10>
		n++;
	return n;
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	53                   	push   %ebx
  800b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b25:	85 c9                	test   %ecx,%ecx
  800b27:	74 19                	je     800b42 <strnlen+0x27>
  800b29:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b2c:	74 14                	je     800b42 <strnlen+0x27>
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b33:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b36:	39 c8                	cmp    %ecx,%eax
  800b38:	74 0d                	je     800b47 <strnlen+0x2c>
  800b3a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b3e:	75 f3                	jne    800b33 <strnlen+0x18>
  800b40:	eb 05                	jmp    800b47 <strnlen+0x2c>
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b47:	5b                   	pop    %ebx
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	53                   	push   %ebx
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b59:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b5d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b60:	83 c2 01             	add    $0x1,%edx
  800b63:	84 c9                	test   %cl,%cl
  800b65:	75 f2                	jne    800b59 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b67:	5b                   	pop    %ebx
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 08             	sub    $0x8,%esp
  800b71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b74:	89 1c 24             	mov    %ebx,(%esp)
  800b77:	e8 84 ff ff ff       	call   800b00 <strlen>
	strcpy(dst + len, src);
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b83:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b86:	89 04 24             	mov    %eax,(%esp)
  800b89:	e8 bc ff ff ff       	call   800b4a <strcpy>
	return dst;
}
  800b8e:	89 d8                	mov    %ebx,%eax
  800b90:	83 c4 08             	add    $0x8,%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba4:	85 f6                	test   %esi,%esi
  800ba6:	74 18                	je     800bc0 <strncpy+0x2a>
  800ba8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bad:	0f b6 1a             	movzbl (%edx),%ebx
  800bb0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bb3:	80 3a 01             	cmpb   $0x1,(%edx)
  800bb6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	39 ce                	cmp    %ecx,%esi
  800bbe:	77 ed                	ja     800bad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bd2:	89 f0                	mov    %esi,%eax
  800bd4:	85 c9                	test   %ecx,%ecx
  800bd6:	74 27                	je     800bff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800bd8:	83 e9 01             	sub    $0x1,%ecx
  800bdb:	74 1d                	je     800bfa <strlcpy+0x36>
  800bdd:	0f b6 1a             	movzbl (%edx),%ebx
  800be0:	84 db                	test   %bl,%bl
  800be2:	74 16                	je     800bfa <strlcpy+0x36>
			*dst++ = *src++;
  800be4:	88 18                	mov    %bl,(%eax)
  800be6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800be9:	83 e9 01             	sub    $0x1,%ecx
  800bec:	74 0e                	je     800bfc <strlcpy+0x38>
			*dst++ = *src++;
  800bee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bf1:	0f b6 1a             	movzbl (%edx),%ebx
  800bf4:	84 db                	test   %bl,%bl
  800bf6:	75 ec                	jne    800be4 <strlcpy+0x20>
  800bf8:	eb 02                	jmp    800bfc <strlcpy+0x38>
  800bfa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bfc:	c6 00 00             	movb   $0x0,(%eax)
  800bff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c0e:	0f b6 01             	movzbl (%ecx),%eax
  800c11:	84 c0                	test   %al,%al
  800c13:	74 15                	je     800c2a <strcmp+0x25>
  800c15:	3a 02                	cmp    (%edx),%al
  800c17:	75 11                	jne    800c2a <strcmp+0x25>
		p++, q++;
  800c19:	83 c1 01             	add    $0x1,%ecx
  800c1c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c1f:	0f b6 01             	movzbl (%ecx),%eax
  800c22:	84 c0                	test   %al,%al
  800c24:	74 04                	je     800c2a <strcmp+0x25>
  800c26:	3a 02                	cmp    (%edx),%al
  800c28:	74 ef                	je     800c19 <strcmp+0x14>
  800c2a:	0f b6 c0             	movzbl %al,%eax
  800c2d:	0f b6 12             	movzbl (%edx),%edx
  800c30:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	53                   	push   %ebx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	74 23                	je     800c68 <strncmp+0x34>
  800c45:	0f b6 1a             	movzbl (%edx),%ebx
  800c48:	84 db                	test   %bl,%bl
  800c4a:	74 25                	je     800c71 <strncmp+0x3d>
  800c4c:	3a 19                	cmp    (%ecx),%bl
  800c4e:	75 21                	jne    800c71 <strncmp+0x3d>
  800c50:	83 e8 01             	sub    $0x1,%eax
  800c53:	74 13                	je     800c68 <strncmp+0x34>
		n--, p++, q++;
  800c55:	83 c2 01             	add    $0x1,%edx
  800c58:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c5b:	0f b6 1a             	movzbl (%edx),%ebx
  800c5e:	84 db                	test   %bl,%bl
  800c60:	74 0f                	je     800c71 <strncmp+0x3d>
  800c62:	3a 19                	cmp    (%ecx),%bl
  800c64:	74 ea                	je     800c50 <strncmp+0x1c>
  800c66:	eb 09                	jmp    800c71 <strncmp+0x3d>
  800c68:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5d                   	pop    %ebp
  800c6f:	90                   	nop
  800c70:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c71:	0f b6 02             	movzbl (%edx),%eax
  800c74:	0f b6 11             	movzbl (%ecx),%edx
  800c77:	29 d0                	sub    %edx,%eax
  800c79:	eb f2                	jmp    800c6d <strncmp+0x39>

00800c7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c85:	0f b6 10             	movzbl (%eax),%edx
  800c88:	84 d2                	test   %dl,%dl
  800c8a:	74 18                	je     800ca4 <strchr+0x29>
		if (*s == c)
  800c8c:	38 ca                	cmp    %cl,%dl
  800c8e:	75 0a                	jne    800c9a <strchr+0x1f>
  800c90:	eb 17                	jmp    800ca9 <strchr+0x2e>
  800c92:	38 ca                	cmp    %cl,%dl
  800c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c98:	74 0f                	je     800ca9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c9a:	83 c0 01             	add    $0x1,%eax
  800c9d:	0f b6 10             	movzbl (%eax),%edx
  800ca0:	84 d2                	test   %dl,%dl
  800ca2:	75 ee                	jne    800c92 <strchr+0x17>
  800ca4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb5:	0f b6 10             	movzbl (%eax),%edx
  800cb8:	84 d2                	test   %dl,%dl
  800cba:	74 18                	je     800cd4 <strfind+0x29>
		if (*s == c)
  800cbc:	38 ca                	cmp    %cl,%dl
  800cbe:	75 0a                	jne    800cca <strfind+0x1f>
  800cc0:	eb 12                	jmp    800cd4 <strfind+0x29>
  800cc2:	38 ca                	cmp    %cl,%dl
  800cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc8:	74 0a                	je     800cd4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cca:	83 c0 01             	add    $0x1,%eax
  800ccd:	0f b6 10             	movzbl (%eax),%edx
  800cd0:	84 d2                	test   %dl,%dl
  800cd2:	75 ee                	jne    800cc2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	89 1c 24             	mov    %ebx,(%esp)
  800cdf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ce7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ced:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cf0:	85 c9                	test   %ecx,%ecx
  800cf2:	74 30                	je     800d24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cf4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cfa:	75 25                	jne    800d21 <memset+0x4b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 20                	jne    800d21 <memset+0x4b>
		c &= 0xFF;
  800d01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d04:	89 d3                	mov    %edx,%ebx
  800d06:	c1 e3 08             	shl    $0x8,%ebx
  800d09:	89 d6                	mov    %edx,%esi
  800d0b:	c1 e6 18             	shl    $0x18,%esi
  800d0e:	89 d0                	mov    %edx,%eax
  800d10:	c1 e0 10             	shl    $0x10,%eax
  800d13:	09 f0                	or     %esi,%eax
  800d15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d17:	09 d8                	or     %ebx,%eax
  800d19:	c1 e9 02             	shr    $0x2,%ecx
  800d1c:	fc                   	cld    
  800d1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d1f:	eb 03                	jmp    800d24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d21:	fc                   	cld    
  800d22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d24:	89 f8                	mov    %edi,%eax
  800d26:	8b 1c 24             	mov    (%esp),%ebx
  800d29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d31:	89 ec                	mov    %ebp,%esp
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	83 ec 08             	sub    $0x8,%esp
  800d3b:	89 34 24             	mov    %esi,(%esp)
  800d3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d4d:	39 c6                	cmp    %eax,%esi
  800d4f:	73 35                	jae    800d86 <memmove+0x51>
  800d51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d54:	39 d0                	cmp    %edx,%eax
  800d56:	73 2e                	jae    800d86 <memmove+0x51>
		s += n;
		d += n;
  800d58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d5a:	f6 c2 03             	test   $0x3,%dl
  800d5d:	75 1b                	jne    800d7a <memmove+0x45>
  800d5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d65:	75 13                	jne    800d7a <memmove+0x45>
  800d67:	f6 c1 03             	test   $0x3,%cl
  800d6a:	75 0e                	jne    800d7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d6c:	83 ef 04             	sub    $0x4,%edi
  800d6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d72:	c1 e9 02             	shr    $0x2,%ecx
  800d75:	fd                   	std    
  800d76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d78:	eb 09                	jmp    800d83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d7a:	83 ef 01             	sub    $0x1,%edi
  800d7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d80:	fd                   	std    
  800d81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d83:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d84:	eb 20                	jmp    800da6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d8c:	75 15                	jne    800da3 <memmove+0x6e>
  800d8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d94:	75 0d                	jne    800da3 <memmove+0x6e>
  800d96:	f6 c1 03             	test   $0x3,%cl
  800d99:	75 08                	jne    800da3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d9b:	c1 e9 02             	shr    $0x2,%ecx
  800d9e:	fc                   	cld    
  800d9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da1:	eb 03                	jmp    800da6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800da3:	fc                   	cld    
  800da4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800da6:	8b 34 24             	mov    (%esp),%esi
  800da9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dad:	89 ec                	mov    %ebp,%esp
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800db7:	8b 45 10             	mov    0x10(%ebp),%eax
  800dba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	89 04 24             	mov    %eax,(%esp)
  800dcb:	e8 65 ff ff ff       	call   800d35 <memmove>
}
  800dd0:	c9                   	leave  
  800dd1:	c3                   	ret    

00800dd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ddb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800de1:	85 c9                	test   %ecx,%ecx
  800de3:	74 36                	je     800e1b <memcmp+0x49>
		if (*s1 != *s2)
  800de5:	0f b6 06             	movzbl (%esi),%eax
  800de8:	0f b6 1f             	movzbl (%edi),%ebx
  800deb:	38 d8                	cmp    %bl,%al
  800ded:	74 20                	je     800e0f <memcmp+0x3d>
  800def:	eb 14                	jmp    800e05 <memcmp+0x33>
  800df1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800df6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800dfb:	83 c2 01             	add    $0x1,%edx
  800dfe:	83 e9 01             	sub    $0x1,%ecx
  800e01:	38 d8                	cmp    %bl,%al
  800e03:	74 12                	je     800e17 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e05:	0f b6 c0             	movzbl %al,%eax
  800e08:	0f b6 db             	movzbl %bl,%ebx
  800e0b:	29 d8                	sub    %ebx,%eax
  800e0d:	eb 11                	jmp    800e20 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e0f:	83 e9 01             	sub    $0x1,%ecx
  800e12:	ba 00 00 00 00       	mov    $0x0,%edx
  800e17:	85 c9                	test   %ecx,%ecx
  800e19:	75 d6                	jne    800df1 <memcmp+0x1f>
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e2b:	89 c2                	mov    %eax,%edx
  800e2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e30:	39 d0                	cmp    %edx,%eax
  800e32:	73 15                	jae    800e49 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e38:	38 08                	cmp    %cl,(%eax)
  800e3a:	75 06                	jne    800e42 <memfind+0x1d>
  800e3c:	eb 0b                	jmp    800e49 <memfind+0x24>
  800e3e:	38 08                	cmp    %cl,(%eax)
  800e40:	74 07                	je     800e49 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e42:	83 c0 01             	add    $0x1,%eax
  800e45:	39 c2                	cmp    %eax,%edx
  800e47:	77 f5                	ja     800e3e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	8b 55 08             	mov    0x8(%ebp),%edx
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e5a:	0f b6 02             	movzbl (%edx),%eax
  800e5d:	3c 20                	cmp    $0x20,%al
  800e5f:	74 04                	je     800e65 <strtol+0x1a>
  800e61:	3c 09                	cmp    $0x9,%al
  800e63:	75 0e                	jne    800e73 <strtol+0x28>
		s++;
  800e65:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e68:	0f b6 02             	movzbl (%edx),%eax
  800e6b:	3c 20                	cmp    $0x20,%al
  800e6d:	74 f6                	je     800e65 <strtol+0x1a>
  800e6f:	3c 09                	cmp    $0x9,%al
  800e71:	74 f2                	je     800e65 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e73:	3c 2b                	cmp    $0x2b,%al
  800e75:	75 0c                	jne    800e83 <strtol+0x38>
		s++;
  800e77:	83 c2 01             	add    $0x1,%edx
  800e7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e81:	eb 15                	jmp    800e98 <strtol+0x4d>
	else if (*s == '-')
  800e83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e8a:	3c 2d                	cmp    $0x2d,%al
  800e8c:	75 0a                	jne    800e98 <strtol+0x4d>
		s++, neg = 1;
  800e8e:	83 c2 01             	add    $0x1,%edx
  800e91:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e98:	85 db                	test   %ebx,%ebx
  800e9a:	0f 94 c0             	sete   %al
  800e9d:	74 05                	je     800ea4 <strtol+0x59>
  800e9f:	83 fb 10             	cmp    $0x10,%ebx
  800ea2:	75 18                	jne    800ebc <strtol+0x71>
  800ea4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ea7:	75 13                	jne    800ebc <strtol+0x71>
  800ea9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ead:	8d 76 00             	lea    0x0(%esi),%esi
  800eb0:	75 0a                	jne    800ebc <strtol+0x71>
		s += 2, base = 16;
  800eb2:	83 c2 02             	add    $0x2,%edx
  800eb5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eba:	eb 15                	jmp    800ed1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ebc:	84 c0                	test   %al,%al
  800ebe:	66 90                	xchg   %ax,%ax
  800ec0:	74 0f                	je     800ed1 <strtol+0x86>
  800ec2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ec7:	80 3a 30             	cmpb   $0x30,(%edx)
  800eca:	75 05                	jne    800ed1 <strtol+0x86>
		s++, base = 8;
  800ecc:	83 c2 01             	add    $0x1,%edx
  800ecf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ed8:	0f b6 0a             	movzbl (%edx),%ecx
  800edb:	89 cf                	mov    %ecx,%edi
  800edd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ee0:	80 fb 09             	cmp    $0x9,%bl
  800ee3:	77 08                	ja     800eed <strtol+0xa2>
			dig = *s - '0';
  800ee5:	0f be c9             	movsbl %cl,%ecx
  800ee8:	83 e9 30             	sub    $0x30,%ecx
  800eeb:	eb 1e                	jmp    800f0b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800eed:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ef0:	80 fb 19             	cmp    $0x19,%bl
  800ef3:	77 08                	ja     800efd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ef5:	0f be c9             	movsbl %cl,%ecx
  800ef8:	83 e9 57             	sub    $0x57,%ecx
  800efb:	eb 0e                	jmp    800f0b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800efd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f00:	80 fb 19             	cmp    $0x19,%bl
  800f03:	77 15                	ja     800f1a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f05:	0f be c9             	movsbl %cl,%ecx
  800f08:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f0b:	39 f1                	cmp    %esi,%ecx
  800f0d:	7d 0b                	jge    800f1a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f0f:	83 c2 01             	add    $0x1,%edx
  800f12:	0f af c6             	imul   %esi,%eax
  800f15:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f18:	eb be                	jmp    800ed8 <strtol+0x8d>
  800f1a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f20:	74 05                	je     800f27 <strtol+0xdc>
		*endptr = (char *) s;
  800f22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f25:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f2b:	74 04                	je     800f31 <strtol+0xe6>
  800f2d:	89 c8                	mov    %ecx,%eax
  800f2f:	f7 d8                	neg    %eax
}
  800f31:	83 c4 04             	add    $0x4,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    
  800f39:	00 00                	add    %al,(%eax)
	...

00800f3c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 08             	sub    $0x8,%esp
  800f42:	89 1c 24             	mov    %ebx,(%esp)
  800f45:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f49:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f53:	89 d1                	mov    %edx,%ecx
  800f55:	89 d3                	mov    %edx,%ebx
  800f57:	89 d7                	mov    %edx,%edi
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

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f71:	8b 1c 24             	mov    (%esp),%ebx
  800f74:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f78:	89 ec                	mov    %ebp,%esp
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
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
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f91:	8b 55 08             	mov    0x8(%ebp),%edx
  800f94:	89 c3                	mov    %eax,%ebx
  800f96:	89 c7                	mov    %eax,%edi
  800f98:	51                   	push   %ecx
  800f99:	52                   	push   %edx
  800f9a:	53                   	push   %ebx
  800f9b:	54                   	push   %esp
  800f9c:	55                   	push   %ebp
  800f9d:	56                   	push   %esi
  800f9e:	57                   	push   %edi
  800f9f:	54                   	push   %esp
  800fa0:	5d                   	pop    %ebp
  800fa1:	8d 35 a9 0f 80 00    	lea    0x800fa9,%esi
  800fa7:	0f 34                	sysenter 
  800fa9:	5f                   	pop    %edi
  800faa:	5e                   	pop    %esi
  800fab:	5d                   	pop    %ebp
  800fac:	5c                   	pop    %esp
  800fad:	5b                   	pop    %ebx
  800fae:	5a                   	pop    %edx
  800faf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb0:	8b 1c 24             	mov    (%esp),%ebx
  800fb3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb7:	89 ec                	mov    %ebp,%esp
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	89 1c 24             	mov    %ebx,(%esp)
  800fc4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc8:	b8 10 00 00 00       	mov    $0x10,%eax
  800fcd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd9:	51                   	push   %ecx
  800fda:	52                   	push   %edx
  800fdb:	53                   	push   %ebx
  800fdc:	54                   	push   %esp
  800fdd:	55                   	push   %ebp
  800fde:	56                   	push   %esi
  800fdf:	57                   	push   %edi
  800fe0:	54                   	push   %esp
  800fe1:	5d                   	pop    %ebp
  800fe2:	8d 35 ea 0f 80 00    	lea    0x800fea,%esi
  800fe8:	0f 34                	sysenter 
  800fea:	5f                   	pop    %edi
  800feb:	5e                   	pop    %esi
  800fec:	5d                   	pop    %ebp
  800fed:	5c                   	pop    %esp
  800fee:	5b                   	pop    %ebx
  800fef:	5a                   	pop    %edx
  800ff0:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800ff1:	8b 1c 24             	mov    (%esp),%ebx
  800ff4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff8:	89 ec                	mov    %ebp,%esp
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 28             	sub    $0x28,%esp
  801002:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801005:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801008:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801012:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801015:	8b 55 08             	mov    0x8(%ebp),%edx
  801018:	89 df                	mov    %ebx,%edi
  80101a:	51                   	push   %ecx
  80101b:	52                   	push   %edx
  80101c:	53                   	push   %ebx
  80101d:	54                   	push   %esp
  80101e:	55                   	push   %ebp
  80101f:	56                   	push   %esi
  801020:	57                   	push   %edi
  801021:	54                   	push   %esp
  801022:	5d                   	pop    %ebp
  801023:	8d 35 2b 10 80 00    	lea    0x80102b,%esi
  801029:	0f 34                	sysenter 
  80102b:	5f                   	pop    %edi
  80102c:	5e                   	pop    %esi
  80102d:	5d                   	pop    %ebp
  80102e:	5c                   	pop    %esp
  80102f:	5b                   	pop    %ebx
  801030:	5a                   	pop    %edx
  801031:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801032:	85 c0                	test   %eax,%eax
  801034:	7e 28                	jle    80105e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801036:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801041:	00 
  801042:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801049:	00 
  80104a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801051:	00 
  801052:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  801059:	e8 66 12 00 00       	call   8022c4 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80105e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801061:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801064:	89 ec                	mov    %ebp,%esp
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 08             	sub    $0x8,%esp
  80106e:	89 1c 24             	mov    %ebx,(%esp)
  801071:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801075:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107a:	b8 11 00 00 00       	mov    $0x11,%eax
  80107f:	8b 55 08             	mov    0x8(%ebp),%edx
  801082:	89 cb                	mov    %ecx,%ebx
  801084:	89 cf                	mov    %ecx,%edi
  801086:	51                   	push   %ecx
  801087:	52                   	push   %edx
  801088:	53                   	push   %ebx
  801089:	54                   	push   %esp
  80108a:	55                   	push   %ebp
  80108b:	56                   	push   %esi
  80108c:	57                   	push   %edi
  80108d:	54                   	push   %esp
  80108e:	5d                   	pop    %ebp
  80108f:	8d 35 97 10 80 00    	lea    0x801097,%esi
  801095:	0f 34                	sysenter 
  801097:	5f                   	pop    %edi
  801098:	5e                   	pop    %esi
  801099:	5d                   	pop    %ebp
  80109a:	5c                   	pop    %esp
  80109b:	5b                   	pop    %ebx
  80109c:	5a                   	pop    %edx
  80109d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80109e:	8b 1c 24             	mov    (%esp),%ebx
  8010a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010a5:	89 ec                	mov    %ebp,%esp
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	83 ec 28             	sub    $0x28,%esp
  8010af:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010b2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ba:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c2:	89 cb                	mov    %ecx,%ebx
  8010c4:	89 cf                	mov    %ecx,%edi
  8010c6:	51                   	push   %ecx
  8010c7:	52                   	push   %edx
  8010c8:	53                   	push   %ebx
  8010c9:	54                   	push   %esp
  8010ca:	55                   	push   %ebp
  8010cb:	56                   	push   %esi
  8010cc:	57                   	push   %edi
  8010cd:	54                   	push   %esp
  8010ce:	5d                   	pop    %ebp
  8010cf:	8d 35 d7 10 80 00    	lea    0x8010d7,%esi
  8010d5:	0f 34                	sysenter 
  8010d7:	5f                   	pop    %edi
  8010d8:	5e                   	pop    %esi
  8010d9:	5d                   	pop    %ebp
  8010da:	5c                   	pop    %esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5a                   	pop    %edx
  8010dd:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	7e 28                	jle    80110a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e6:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8010ed:	00 
  8010ee:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8010f5:	00 
  8010f6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010fd:	00 
  8010fe:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  801105:	e8 ba 11 00 00       	call   8022c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80110a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80110d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801110:	89 ec                	mov    %ebp,%esp
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 08             	sub    $0x8,%esp
  80111a:	89 1c 24             	mov    %ebx,(%esp)
  80111d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801121:	b8 0d 00 00 00       	mov    $0xd,%eax
  801126:	8b 7d 14             	mov    0x14(%ebp),%edi
  801129:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	8b 55 08             	mov    0x8(%ebp),%edx
  801132:	51                   	push   %ecx
  801133:	52                   	push   %edx
  801134:	53                   	push   %ebx
  801135:	54                   	push   %esp
  801136:	55                   	push   %ebp
  801137:	56                   	push   %esi
  801138:	57                   	push   %edi
  801139:	54                   	push   %esp
  80113a:	5d                   	pop    %ebp
  80113b:	8d 35 43 11 80 00    	lea    0x801143,%esi
  801141:	0f 34                	sysenter 
  801143:	5f                   	pop    %edi
  801144:	5e                   	pop    %esi
  801145:	5d                   	pop    %ebp
  801146:	5c                   	pop    %esp
  801147:	5b                   	pop    %ebx
  801148:	5a                   	pop    %edx
  801149:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80114a:	8b 1c 24             	mov    (%esp),%ebx
  80114d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801151:	89 ec                	mov    %ebp,%esp
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 28             	sub    $0x28,%esp
  80115b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80115e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801161:	bb 00 00 00 00       	mov    $0x0,%ebx
  801166:	b8 0b 00 00 00       	mov    $0xb,%eax
  80116b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116e:	8b 55 08             	mov    0x8(%ebp),%edx
  801171:	89 df                	mov    %ebx,%edi
  801173:	51                   	push   %ecx
  801174:	52                   	push   %edx
  801175:	53                   	push   %ebx
  801176:	54                   	push   %esp
  801177:	55                   	push   %ebp
  801178:	56                   	push   %esi
  801179:	57                   	push   %edi
  80117a:	54                   	push   %esp
  80117b:	5d                   	pop    %ebp
  80117c:	8d 35 84 11 80 00    	lea    0x801184,%esi
  801182:	0f 34                	sysenter 
  801184:	5f                   	pop    %edi
  801185:	5e                   	pop    %esi
  801186:	5d                   	pop    %ebp
  801187:	5c                   	pop    %esp
  801188:	5b                   	pop    %ebx
  801189:	5a                   	pop    %edx
  80118a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80118b:	85 c0                	test   %eax,%eax
  80118d:	7e 28                	jle    8011b7 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801193:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80119a:	00 
  80119b:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011aa:	00 
  8011ab:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  8011b2:	e8 0d 11 00 00       	call   8022c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011b7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011ba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011bd:	89 ec                	mov    %ebp,%esp
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 28             	sub    $0x28,%esp
  8011c7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011ca:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011da:	8b 55 08             	mov    0x8(%ebp),%edx
  8011dd:	89 df                	mov    %ebx,%edi
  8011df:	51                   	push   %ecx
  8011e0:	52                   	push   %edx
  8011e1:	53                   	push   %ebx
  8011e2:	54                   	push   %esp
  8011e3:	55                   	push   %ebp
  8011e4:	56                   	push   %esi
  8011e5:	57                   	push   %edi
  8011e6:	54                   	push   %esp
  8011e7:	5d                   	pop    %ebp
  8011e8:	8d 35 f0 11 80 00    	lea    0x8011f0,%esi
  8011ee:	0f 34                	sysenter 
  8011f0:	5f                   	pop    %edi
  8011f1:	5e                   	pop    %esi
  8011f2:	5d                   	pop    %ebp
  8011f3:	5c                   	pop    %esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5a                   	pop    %edx
  8011f6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	7e 28                	jle    801223 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ff:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801206:	00 
  801207:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  80120e:	00 
  80120f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801216:	00 
  801217:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  80121e:	e8 a1 10 00 00       	call   8022c4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801223:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801226:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801229:	89 ec                	mov    %ebp,%esp
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 28             	sub    $0x28,%esp
  801233:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801236:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123e:	b8 09 00 00 00       	mov    $0x9,%eax
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	8b 55 08             	mov    0x8(%ebp),%edx
  801249:	89 df                	mov    %ebx,%edi
  80124b:	51                   	push   %ecx
  80124c:	52                   	push   %edx
  80124d:	53                   	push   %ebx
  80124e:	54                   	push   %esp
  80124f:	55                   	push   %ebp
  801250:	56                   	push   %esi
  801251:	57                   	push   %edi
  801252:	54                   	push   %esp
  801253:	5d                   	pop    %ebp
  801254:	8d 35 5c 12 80 00    	lea    0x80125c,%esi
  80125a:	0f 34                	sysenter 
  80125c:	5f                   	pop    %edi
  80125d:	5e                   	pop    %esi
  80125e:	5d                   	pop    %ebp
  80125f:	5c                   	pop    %esp
  801260:	5b                   	pop    %ebx
  801261:	5a                   	pop    %edx
  801262:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801263:	85 c0                	test   %eax,%eax
  801265:	7e 28                	jle    80128f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801267:	89 44 24 10          	mov    %eax,0x10(%esp)
  80126b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801272:	00 
  801273:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  80127a:	00 
  80127b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801282:	00 
  801283:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  80128a:	e8 35 10 00 00       	call   8022c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80128f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801292:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801295:	89 ec                	mov    %ebp,%esp
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 28             	sub    $0x28,%esp
  80129f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012a2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012aa:	b8 07 00 00 00       	mov    $0x7,%eax
  8012af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b5:	89 df                	mov    %ebx,%edi
  8012b7:	51                   	push   %ecx
  8012b8:	52                   	push   %edx
  8012b9:	53                   	push   %ebx
  8012ba:	54                   	push   %esp
  8012bb:	55                   	push   %ebp
  8012bc:	56                   	push   %esi
  8012bd:	57                   	push   %edi
  8012be:	54                   	push   %esp
  8012bf:	5d                   	pop    %ebp
  8012c0:	8d 35 c8 12 80 00    	lea    0x8012c8,%esi
  8012c6:	0f 34                	sysenter 
  8012c8:	5f                   	pop    %edi
  8012c9:	5e                   	pop    %esi
  8012ca:	5d                   	pop    %ebp
  8012cb:	5c                   	pop    %esp
  8012cc:	5b                   	pop    %ebx
  8012cd:	5a                   	pop    %edx
  8012ce:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	7e 28                	jle    8012fb <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8012de:	00 
  8012df:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8012e6:	00 
  8012e7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012ee:	00 
  8012ef:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  8012f6:	e8 c9 0f 00 00       	call   8022c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012fb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801301:	89 ec                	mov    %ebp,%esp
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 28             	sub    $0x28,%esp
  80130b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80130e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801311:	8b 7d 18             	mov    0x18(%ebp),%edi
  801314:	0b 7d 14             	or     0x14(%ebp),%edi
  801317:	b8 06 00 00 00       	mov    $0x6,%eax
  80131c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80131f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801322:	8b 55 08             	mov    0x8(%ebp),%edx
  801325:	51                   	push   %ecx
  801326:	52                   	push   %edx
  801327:	53                   	push   %ebx
  801328:	54                   	push   %esp
  801329:	55                   	push   %ebp
  80132a:	56                   	push   %esi
  80132b:	57                   	push   %edi
  80132c:	54                   	push   %esp
  80132d:	5d                   	pop    %ebp
  80132e:	8d 35 36 13 80 00    	lea    0x801336,%esi
  801334:	0f 34                	sysenter 
  801336:	5f                   	pop    %edi
  801337:	5e                   	pop    %esi
  801338:	5d                   	pop    %ebp
  801339:	5c                   	pop    %esp
  80133a:	5b                   	pop    %ebx
  80133b:	5a                   	pop    %edx
  80133c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80133d:	85 c0                	test   %eax,%eax
  80133f:	7e 28                	jle    801369 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801341:	89 44 24 10          	mov    %eax,0x10(%esp)
  801345:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80134c:	00 
  80134d:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  801354:	00 
  801355:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80135c:	00 
  80135d:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  801364:	e8 5b 0f 00 00       	call   8022c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801369:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80136c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80136f:	89 ec                	mov    %ebp,%esp
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 28             	sub    $0x28,%esp
  801379:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80137c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80137f:	bf 00 00 00 00       	mov    $0x0,%edi
  801384:	b8 05 00 00 00       	mov    $0x5,%eax
  801389:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138f:	8b 55 08             	mov    0x8(%ebp),%edx
  801392:	51                   	push   %ecx
  801393:	52                   	push   %edx
  801394:	53                   	push   %ebx
  801395:	54                   	push   %esp
  801396:	55                   	push   %ebp
  801397:	56                   	push   %esi
  801398:	57                   	push   %edi
  801399:	54                   	push   %esp
  80139a:	5d                   	pop    %ebp
  80139b:	8d 35 a3 13 80 00    	lea    0x8013a3,%esi
  8013a1:	0f 34                	sysenter 
  8013a3:	5f                   	pop    %edi
  8013a4:	5e                   	pop    %esi
  8013a5:	5d                   	pop    %ebp
  8013a6:	5c                   	pop    %esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5a                   	pop    %edx
  8013a9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	7e 28                	jle    8013d6 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013b9:	00 
  8013ba:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8013c1:	00 
  8013c2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013c9:	00 
  8013ca:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  8013d1:	e8 ee 0e 00 00       	call   8022c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8013d6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013d9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013dc:	89 ec                	mov    %ebp,%esp
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	89 1c 24             	mov    %ebx,(%esp)
  8013e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013f7:	89 d1                	mov    %edx,%ecx
  8013f9:	89 d3                	mov    %edx,%ebx
  8013fb:	89 d7                	mov    %edx,%edi
  8013fd:	51                   	push   %ecx
  8013fe:	52                   	push   %edx
  8013ff:	53                   	push   %ebx
  801400:	54                   	push   %esp
  801401:	55                   	push   %ebp
  801402:	56                   	push   %esi
  801403:	57                   	push   %edi
  801404:	54                   	push   %esp
  801405:	5d                   	pop    %ebp
  801406:	8d 35 0e 14 80 00    	lea    0x80140e,%esi
  80140c:	0f 34                	sysenter 
  80140e:	5f                   	pop    %edi
  80140f:	5e                   	pop    %esi
  801410:	5d                   	pop    %ebp
  801411:	5c                   	pop    %esp
  801412:	5b                   	pop    %ebx
  801413:	5a                   	pop    %edx
  801414:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801415:	8b 1c 24             	mov    (%esp),%ebx
  801418:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80141c:	89 ec                	mov    %ebp,%esp
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	89 1c 24             	mov    %ebx,(%esp)
  801429:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80142d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801432:	b8 04 00 00 00       	mov    $0x4,%eax
  801437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143a:	8b 55 08             	mov    0x8(%ebp),%edx
  80143d:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801457:	8b 1c 24             	mov    (%esp),%ebx
  80145a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80145e:	89 ec                	mov    %ebp,%esp
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 08             	sub    $0x8,%esp
  801468:	89 1c 24             	mov    %ebx,(%esp)
  80146b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80146f:	ba 00 00 00 00       	mov    $0x0,%edx
  801474:	b8 02 00 00 00       	mov    $0x2,%eax
  801479:	89 d1                	mov    %edx,%ecx
  80147b:	89 d3                	mov    %edx,%ebx
  80147d:	89 d7                	mov    %edx,%edi
  80147f:	51                   	push   %ecx
  801480:	52                   	push   %edx
  801481:	53                   	push   %ebx
  801482:	54                   	push   %esp
  801483:	55                   	push   %ebp
  801484:	56                   	push   %esi
  801485:	57                   	push   %edi
  801486:	54                   	push   %esp
  801487:	5d                   	pop    %ebp
  801488:	8d 35 90 14 80 00    	lea    0x801490,%esi
  80148e:	0f 34                	sysenter 
  801490:	5f                   	pop    %edi
  801491:	5e                   	pop    %esi
  801492:	5d                   	pop    %ebp
  801493:	5c                   	pop    %esp
  801494:	5b                   	pop    %ebx
  801495:	5a                   	pop    %edx
  801496:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801497:	8b 1c 24             	mov    (%esp),%ebx
  80149a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80149e:	89 ec                	mov    %ebp,%esp
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 28             	sub    $0x28,%esp
  8014a8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014ab:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b3:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bb:	89 cb                	mov    %ecx,%ebx
  8014bd:	89 cf                	mov    %ecx,%edi
  8014bf:	51                   	push   %ecx
  8014c0:	52                   	push   %edx
  8014c1:	53                   	push   %ebx
  8014c2:	54                   	push   %esp
  8014c3:	55                   	push   %ebp
  8014c4:	56                   	push   %esi
  8014c5:	57                   	push   %edi
  8014c6:	54                   	push   %esp
  8014c7:	5d                   	pop    %ebp
  8014c8:	8d 35 d0 14 80 00    	lea    0x8014d0,%esi
  8014ce:	0f 34                	sysenter 
  8014d0:	5f                   	pop    %edi
  8014d1:	5e                   	pop    %esi
  8014d2:	5d                   	pop    %ebp
  8014d3:	5c                   	pop    %esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5a                   	pop    %edx
  8014d6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	7e 28                	jle    801503 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014df:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014e6:	00 
  8014e7:	c7 44 24 08 e0 29 80 	movl   $0x8029e0,0x8(%esp)
  8014ee:	00 
  8014ef:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014f6:	00 
  8014f7:	c7 04 24 fd 29 80 00 	movl   $0x8029fd,(%esp)
  8014fe:	e8 c1 0d 00 00       	call   8022c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801503:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801506:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801509:	89 ec                	mov    %ebp,%esp
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
  80150d:	00 00                	add    %al,(%eax)
	...

00801510 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801516:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  80151d:	00 
  80151e:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801525:	00 
  801526:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  80152d:	e8 92 0d 00 00       	call   8022c4 <_panic>

00801532 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	57                   	push   %edi
  801536:	56                   	push   %esi
  801537:	53                   	push   %ebx
  801538:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80153b:	c7 04 24 87 17 80 00 	movl   $0x801787,(%esp)
  801542:	e8 d5 0d 00 00       	call   80231c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801547:	ba 08 00 00 00       	mov    $0x8,%edx
  80154c:	89 d0                	mov    %edx,%eax
  80154e:	cd 30                	int    $0x30
  801550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801553:	85 c0                	test   %eax,%eax
  801555:	79 20                	jns    801577 <fork+0x45>
		panic("sys_exofork: %e", envid);
  801557:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80155b:	c7 44 24 08 2c 2a 80 	movl   $0x802a2c,0x8(%esp)
  801562:	00 
  801563:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80156a:	00 
  80156b:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801572:	e8 4d 0d 00 00       	call   8022c4 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801577:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80157c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801581:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801586:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80158a:	75 20                	jne    8015ac <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80158c:	e8 d1 fe ff ff       	call   801462 <sys_getenvid>
  801591:	25 ff 03 00 00       	and    $0x3ff,%eax
  801596:	89 c2                	mov    %eax,%edx
  801598:	c1 e2 07             	shl    $0x7,%edx
  80159b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8015a2:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8015a7:	e9 d0 01 00 00       	jmp    80177c <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8015ac:	89 d8                	mov    %ebx,%eax
  8015ae:	c1 e8 16             	shr    $0x16,%eax
  8015b1:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8015b4:	a8 01                	test   $0x1,%al
  8015b6:	0f 84 0d 01 00 00    	je     8016c9 <fork+0x197>
  8015bc:	89 d8                	mov    %ebx,%eax
  8015be:	c1 e8 0c             	shr    $0xc,%eax
  8015c1:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8015c4:	f6 c2 01             	test   $0x1,%dl
  8015c7:	0f 84 fc 00 00 00    	je     8016c9 <fork+0x197>
  8015cd:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8015d0:	f6 c2 04             	test   $0x4,%dl
  8015d3:	0f 84 f0 00 00 00    	je     8016c9 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  8015d9:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	c1 ea 0c             	shr    $0xc,%edx
  8015e1:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  8015e4:	f6 c2 01             	test   $0x1,%dl
  8015e7:	0f 84 dc 00 00 00    	je     8016c9 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8015ed:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8015f3:	0f 84 8d 00 00 00    	je     801686 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8015f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015fc:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801603:	00 
  801604:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801608:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80160b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80160f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801613:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80161a:	e8 e6 fc ff ff       	call   801305 <sys_page_map>
               if(r<0)
  80161f:	85 c0                	test   %eax,%eax
  801621:	79 1c                	jns    80163f <fork+0x10d>
                 panic("map failed");
  801623:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  80162a:	00 
  80162b:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801632:	00 
  801633:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  80163a:	e8 85 0c 00 00       	call   8022c4 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  80163f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801646:	00 
  801647:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80164a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80164e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801655:	00 
  801656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801661:	e8 9f fc ff ff       	call   801305 <sys_page_map>
               if(r<0)
  801666:	85 c0                	test   %eax,%eax
  801668:	79 5f                	jns    8016c9 <fork+0x197>
                 panic("map failed");
  80166a:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  801671:	00 
  801672:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801679:	00 
  80167a:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801681:	e8 3e 0c 00 00       	call   8022c4 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801686:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80168d:	00 
  80168e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801692:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801695:	89 54 24 08          	mov    %edx,0x8(%esp)
  801699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a4:	e8 5c fc ff ff       	call   801305 <sys_page_map>
               if(r<0)
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	79 1c                	jns    8016c9 <fork+0x197>
                 panic("map failed");
  8016ad:	c7 44 24 08 3c 2a 80 	movl   $0x802a3c,0x8(%esp)
  8016b4:	00 
  8016b5:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8016bc:	00 
  8016bd:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  8016c4:	e8 fb 0b 00 00       	call   8022c4 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8016c9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8016cf:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8016d5:	0f 85 d1 fe ff ff    	jne    8015ac <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8016db:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016e2:	00 
  8016e3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016ea:	ee 
  8016eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ee:	89 04 24             	mov    %eax,(%esp)
  8016f1:	e8 7d fc ff ff       	call   801373 <sys_page_alloc>
        if(r < 0)
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	79 1c                	jns    801716 <fork+0x1e4>
            panic("alloc failed");
  8016fa:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  801701:	00 
  801702:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801709:	00 
  80170a:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801711:	e8 ae 0b 00 00       	call   8022c4 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801716:	c7 44 24 04 68 23 80 	movl   $0x802368,0x4(%esp)
  80171d:	00 
  80171e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801721:	89 14 24             	mov    %edx,(%esp)
  801724:	e8 2c fa ff ff       	call   801155 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801729:	85 c0                	test   %eax,%eax
  80172b:	79 1c                	jns    801749 <fork+0x217>
            panic("set pgfault upcall failed");
  80172d:	c7 44 24 08 54 2a 80 	movl   $0x802a54,0x8(%esp)
  801734:	00 
  801735:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80173c:	00 
  80173d:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801744:	e8 7b 0b 00 00       	call   8022c4 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801749:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801750:	00 
  801751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 d1 fa ff ff       	call   80122d <sys_env_set_status>
        if(r < 0)
  80175c:	85 c0                	test   %eax,%eax
  80175e:	79 1c                	jns    80177c <fork+0x24a>
            panic("set status failed");
  801760:	c7 44 24 08 6e 2a 80 	movl   $0x802a6e,0x8(%esp)
  801767:	00 
  801768:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80176f:	00 
  801770:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801777:	e8 48 0b 00 00       	call   8022c4 <_panic>
        return envid;
	//panic("fork not implemented");
}
  80177c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80177f:	83 c4 3c             	add    $0x3c,%esp
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5f                   	pop    %edi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 24             	sub    $0x24,%esp
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801791:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801793:	89 da                	mov    %ebx,%edx
  801795:	c1 ea 0c             	shr    $0xc,%edx
  801798:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80179f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017a3:	74 08                	je     8017ad <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  8017a5:	f7 c2 05 08 00 00    	test   $0x805,%edx
  8017ab:	75 1c                	jne    8017c9 <pgfault+0x42>
           panic("pgfault error");
  8017ad:	c7 44 24 08 80 2a 80 	movl   $0x802a80,0x8(%esp)
  8017b4:	00 
  8017b5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8017bc:	00 
  8017bd:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  8017c4:	e8 fb 0a 00 00       	call   8022c4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017c9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017d0:	00 
  8017d1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8017d8:	00 
  8017d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e0:	e8 8e fb ff ff       	call   801373 <sys_page_alloc>
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	79 20                	jns    801809 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  8017e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ed:	c7 44 24 08 8e 2a 80 	movl   $0x802a8e,0x8(%esp)
  8017f4:	00 
  8017f5:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8017fc:	00 
  8017fd:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  801804:	e8 bb 0a 00 00       	call   8022c4 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  801809:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80180f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801816:	00 
  801817:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80181b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801822:	e8 0e f5 ff ff       	call   800d35 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801827:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80182e:	00 
  80182f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801833:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80183a:	00 
  80183b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801842:	00 
  801843:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80184a:	e8 b6 fa ff ff       	call   801305 <sys_page_map>
  80184f:	85 c0                	test   %eax,%eax
  801851:	79 20                	jns    801873 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801853:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801857:	c7 44 24 08 a1 2a 80 	movl   $0x802aa1,0x8(%esp)
  80185e:	00 
  80185f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801866:	00 
  801867:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  80186e:	e8 51 0a 00 00       	call   8022c4 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801873:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80187a:	00 
  80187b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801882:	e8 12 fa ff ff       	call   801299 <sys_page_unmap>
  801887:	85 c0                	test   %eax,%eax
  801889:	79 20                	jns    8018ab <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80188b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80188f:	c7 44 24 08 b2 2a 80 	movl   $0x802ab2,0x8(%esp)
  801896:	00 
  801897:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80189e:	00 
  80189f:	c7 04 24 21 2a 80 00 	movl   $0x802a21,(%esp)
  8018a6:	e8 19 0a 00 00       	call   8022c4 <_panic>
	//panic("pgfault not implemented");
}
  8018ab:	83 c4 24             	add    $0x24,%esp
  8018ae:	5b                   	pop    %ebx
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    
	...

008018c0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8018c6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8018cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d1:	39 ca                	cmp    %ecx,%edx
  8018d3:	75 04                	jne    8018d9 <ipc_find_env+0x19>
  8018d5:	b0 00                	mov    $0x0,%al
  8018d7:	eb 12                	jmp    8018eb <ipc_find_env+0x2b>
  8018d9:	89 c2                	mov    %eax,%edx
  8018db:	c1 e2 07             	shl    $0x7,%edx
  8018de:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8018e5:	8b 12                	mov    (%edx),%edx
  8018e7:	39 ca                	cmp    %ecx,%edx
  8018e9:	75 10                	jne    8018fb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8018eb:	89 c2                	mov    %eax,%edx
  8018ed:	c1 e2 07             	shl    $0x7,%edx
  8018f0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8018f7:	8b 00                	mov    (%eax),%eax
  8018f9:	eb 0e                	jmp    801909 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018fb:	83 c0 01             	add    $0x1,%eax
  8018fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801903:	75 d4                	jne    8018d9 <ipc_find_env+0x19>
  801905:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	57                   	push   %edi
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	83 ec 1c             	sub    $0x1c,%esp
  801914:	8b 75 08             	mov    0x8(%ebp),%esi
  801917:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80191a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80191d:	85 db                	test   %ebx,%ebx
  80191f:	74 19                	je     80193a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801921:	8b 45 14             	mov    0x14(%ebp),%eax
  801924:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801928:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801930:	89 34 24             	mov    %esi,(%esp)
  801933:	e8 dc f7 ff ff       	call   801114 <sys_ipc_try_send>
  801938:	eb 1b                	jmp    801955 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80193a:	8b 45 14             	mov    0x14(%ebp),%eax
  80193d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801941:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801948:	ee 
  801949:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80194d:	89 34 24             	mov    %esi,(%esp)
  801950:	e8 bf f7 ff ff       	call   801114 <sys_ipc_try_send>
           if(ret == 0)
  801955:	85 c0                	test   %eax,%eax
  801957:	74 28                	je     801981 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801959:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80195c:	74 1c                	je     80197a <ipc_send+0x6f>
              panic("ipc send error");
  80195e:	c7 44 24 08 c5 2a 80 	movl   $0x802ac5,0x8(%esp)
  801965:	00 
  801966:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80196d:	00 
  80196e:	c7 04 24 d4 2a 80 00 	movl   $0x802ad4,(%esp)
  801975:	e8 4a 09 00 00       	call   8022c4 <_panic>
           sys_yield();
  80197a:	e8 61 fa ff ff       	call   8013e0 <sys_yield>
        }
  80197f:	eb 9c                	jmp    80191d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801981:	83 c4 1c             	add    $0x1c,%esp
  801984:	5b                   	pop    %ebx
  801985:	5e                   	pop    %esi
  801986:	5f                   	pop    %edi
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	56                   	push   %esi
  80198d:	53                   	push   %ebx
  80198e:	83 ec 10             	sub    $0x10,%esp
  801991:	8b 75 08             	mov    0x8(%ebp),%esi
  801994:	8b 45 0c             	mov    0xc(%ebp),%eax
  801997:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80199a:	85 c0                	test   %eax,%eax
  80199c:	75 0e                	jne    8019ac <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80199e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8019a5:	e8 ff f6 ff ff       	call   8010a9 <sys_ipc_recv>
  8019aa:	eb 08                	jmp    8019b4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8019ac:	89 04 24             	mov    %eax,(%esp)
  8019af:	e8 f5 f6 ff ff       	call   8010a9 <sys_ipc_recv>
        if(ret == 0){
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	75 26                	jne    8019de <ipc_recv+0x55>
           if(from_env_store)
  8019b8:	85 f6                	test   %esi,%esi
  8019ba:	74 0a                	je     8019c6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  8019bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8019c1:	8b 40 78             	mov    0x78(%eax),%eax
  8019c4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  8019c6:	85 db                	test   %ebx,%ebx
  8019c8:	74 0a                	je     8019d4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  8019ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8019cf:	8b 40 7c             	mov    0x7c(%eax),%eax
  8019d2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8019d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8019d9:	8b 40 74             	mov    0x74(%eax),%eax
  8019dc:	eb 14                	jmp    8019f2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8019de:	85 f6                	test   %esi,%esi
  8019e0:	74 06                	je     8019e8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8019e2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8019e8:	85 db                	test   %ebx,%ebx
  8019ea:	74 06                	je     8019f2 <ipc_recv+0x69>
              *perm_store = 0;
  8019ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    
  8019f9:	00 00                	add    %al,(%eax)
  8019fb:	00 00                	add    %al,(%eax)
  8019fd:	00 00                	add    %al,(%eax)
	...

00801a00 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	05 00 00 00 30       	add    $0x30000000,%eax
  801a0b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	89 04 24             	mov    %eax,(%esp)
  801a1c:	e8 df ff ff ff       	call   801a00 <fd2num>
  801a21:	05 20 00 0d 00       	add    $0xd0020,%eax
  801a26:	c1 e0 0c             	shl    $0xc,%eax
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	57                   	push   %edi
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801a34:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801a39:	a8 01                	test   $0x1,%al
  801a3b:	74 36                	je     801a73 <fd_alloc+0x48>
  801a3d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801a42:	a8 01                	test   $0x1,%al
  801a44:	74 2d                	je     801a73 <fd_alloc+0x48>
  801a46:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801a4b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801a50:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801a55:	89 c3                	mov    %eax,%ebx
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	c1 ea 16             	shr    $0x16,%edx
  801a5c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801a5f:	f6 c2 01             	test   $0x1,%dl
  801a62:	74 14                	je     801a78 <fd_alloc+0x4d>
  801a64:	89 c2                	mov    %eax,%edx
  801a66:	c1 ea 0c             	shr    $0xc,%edx
  801a69:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801a6c:	f6 c2 01             	test   $0x1,%dl
  801a6f:	75 10                	jne    801a81 <fd_alloc+0x56>
  801a71:	eb 05                	jmp    801a78 <fd_alloc+0x4d>
  801a73:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801a78:	89 1f                	mov    %ebx,(%edi)
  801a7a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801a7f:	eb 17                	jmp    801a98 <fd_alloc+0x6d>
  801a81:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801a86:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801a8b:	75 c8                	jne    801a55 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801a8d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a93:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5f                   	pop    %edi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	83 f8 1f             	cmp    $0x1f,%eax
  801aa6:	77 36                	ja     801ade <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801aa8:	05 00 00 0d 00       	add    $0xd0000,%eax
  801aad:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801ab0:	89 c2                	mov    %eax,%edx
  801ab2:	c1 ea 16             	shr    $0x16,%edx
  801ab5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801abc:	f6 c2 01             	test   $0x1,%dl
  801abf:	74 1d                	je     801ade <fd_lookup+0x41>
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	c1 ea 0c             	shr    $0xc,%edx
  801ac6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801acd:	f6 c2 01             	test   $0x1,%dl
  801ad0:	74 0c                	je     801ade <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801ad2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad5:	89 02                	mov    %eax,(%edx)
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801adc:	eb 05                	jmp    801ae3 <fd_lookup+0x46>
  801ade:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aeb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801aee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af2:	8b 45 08             	mov    0x8(%ebp),%eax
  801af5:	89 04 24             	mov    %eax,(%esp)
  801af8:	e8 a0 ff ff ff       	call   801a9d <fd_lookup>
  801afd:	85 c0                	test   %eax,%eax
  801aff:	78 0e                	js     801b0f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b07:	89 50 04             	mov    %edx,0x4(%eax)
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	56                   	push   %esi
  801b15:	53                   	push   %ebx
  801b16:	83 ec 10             	sub    $0x10,%esp
  801b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801b1f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801b24:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b29:	be 5c 2b 80 00       	mov    $0x802b5c,%esi
		if (devtab[i]->dev_id == dev_id) {
  801b2e:	39 08                	cmp    %ecx,(%eax)
  801b30:	75 10                	jne    801b42 <dev_lookup+0x31>
  801b32:	eb 04                	jmp    801b38 <dev_lookup+0x27>
  801b34:	39 08                	cmp    %ecx,(%eax)
  801b36:	75 0a                	jne    801b42 <dev_lookup+0x31>
			*dev = devtab[i];
  801b38:	89 03                	mov    %eax,(%ebx)
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801b3f:	90                   	nop
  801b40:	eb 31                	jmp    801b73 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b42:	83 c2 01             	add    $0x1,%edx
  801b45:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	75 e8                	jne    801b34 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801b4c:	a1 08 40 80 00       	mov    0x804008,%eax
  801b51:	8b 40 48             	mov    0x48(%eax),%eax
  801b54:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  801b63:	e8 b5 e6 ff ff       	call   80021d <cprintf>
	*dev = 0;
  801b68:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 24             	sub    $0x24,%esp
  801b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	89 04 24             	mov    %eax,(%esp)
  801b91:	e8 07 ff ff ff       	call   801a9d <fd_lookup>
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 53                	js     801bed <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba4:	8b 00                	mov    (%eax),%eax
  801ba6:	89 04 24             	mov    %eax,(%esp)
  801ba9:	e8 63 ff ff ff       	call   801b11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 3b                	js     801bed <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801bb2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bba:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801bbe:	74 2d                	je     801bed <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801bc0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bc3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bca:	00 00 00 
	stat->st_isdir = 0;
  801bcd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bd4:	00 00 00 
	stat->st_dev = dev;
  801bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bda:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801be0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801be7:	89 14 24             	mov    %edx,(%esp)
  801bea:	ff 50 14             	call   *0x14(%eax)
}
  801bed:	83 c4 24             	add    $0x24,%esp
  801bf0:	5b                   	pop    %ebx
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 24             	sub    $0x24,%esp
  801bfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c04:	89 1c 24             	mov    %ebx,(%esp)
  801c07:	e8 91 fe ff ff       	call   801a9d <fd_lookup>
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	78 5f                	js     801c6f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1a:	8b 00                	mov    (%eax),%eax
  801c1c:	89 04 24             	mov    %eax,(%esp)
  801c1f:	e8 ed fe ff ff       	call   801b11 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 47                	js     801c6f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c2b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801c2f:	75 23                	jne    801c54 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c31:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c36:	8b 40 48             	mov    0x48(%eax),%eax
  801c39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c41:	c7 04 24 00 2b 80 00 	movl   $0x802b00,(%esp)
  801c48:	e8 d0 e5 ff ff       	call   80021d <cprintf>
  801c4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c52:	eb 1b                	jmp    801c6f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c57:	8b 48 18             	mov    0x18(%eax),%ecx
  801c5a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c5f:	85 c9                	test   %ecx,%ecx
  801c61:	74 0c                	je     801c6f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6a:	89 14 24             	mov    %edx,(%esp)
  801c6d:	ff d1                	call   *%ecx
}
  801c6f:	83 c4 24             	add    $0x24,%esp
  801c72:	5b                   	pop    %ebx
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 24             	sub    $0x24,%esp
  801c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c86:	89 1c 24             	mov    %ebx,(%esp)
  801c89:	e8 0f fe ff ff       	call   801a9d <fd_lookup>
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 66                	js     801cf8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9c:	8b 00                	mov    (%eax),%eax
  801c9e:	89 04 24             	mov    %eax,(%esp)
  801ca1:	e8 6b fe ff ff       	call   801b11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	78 4e                	js     801cf8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801caa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cad:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801cb1:	75 23                	jne    801cd6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801cb3:	a1 08 40 80 00       	mov    0x804008,%eax
  801cb8:	8b 40 48             	mov    0x48(%eax),%eax
  801cbb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc3:	c7 04 24 21 2b 80 00 	movl   $0x802b21,(%esp)
  801cca:	e8 4e e5 ff ff       	call   80021d <cprintf>
  801ccf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801cd4:	eb 22                	jmp    801cf8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd9:	8b 48 0c             	mov    0xc(%eax),%ecx
  801cdc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ce1:	85 c9                	test   %ecx,%ecx
  801ce3:	74 13                	je     801cf8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ce5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf3:	89 14 24             	mov    %edx,(%esp)
  801cf6:	ff d1                	call   *%ecx
}
  801cf8:	83 c4 24             	add    $0x24,%esp
  801cfb:	5b                   	pop    %ebx
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	53                   	push   %ebx
  801d02:	83 ec 24             	sub    $0x24,%esp
  801d05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0f:	89 1c 24             	mov    %ebx,(%esp)
  801d12:	e8 86 fd ff ff       	call   801a9d <fd_lookup>
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 6b                	js     801d86 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d25:	8b 00                	mov    (%eax),%eax
  801d27:	89 04 24             	mov    %eax,(%esp)
  801d2a:	e8 e2 fd ff ff       	call   801b11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 53                	js     801d86 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801d33:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d36:	8b 42 08             	mov    0x8(%edx),%eax
  801d39:	83 e0 03             	and    $0x3,%eax
  801d3c:	83 f8 01             	cmp    $0x1,%eax
  801d3f:	75 23                	jne    801d64 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801d41:	a1 08 40 80 00       	mov    0x804008,%eax
  801d46:	8b 40 48             	mov    0x48(%eax),%eax
  801d49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d51:	c7 04 24 3e 2b 80 00 	movl   $0x802b3e,(%esp)
  801d58:	e8 c0 e4 ff ff       	call   80021d <cprintf>
  801d5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801d62:	eb 22                	jmp    801d86 <read+0x88>
	}
	if (!dev->dev_read)
  801d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d67:	8b 48 08             	mov    0x8(%eax),%ecx
  801d6a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d6f:	85 c9                	test   %ecx,%ecx
  801d71:	74 13                	je     801d86 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801d73:	8b 45 10             	mov    0x10(%ebp),%eax
  801d76:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d81:	89 14 24             	mov    %edx,(%esp)
  801d84:	ff d1                	call   *%ecx
}
  801d86:	83 c4 24             	add    $0x24,%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	83 ec 1c             	sub    $0x1c,%esp
  801d95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d98:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
  801daa:	85 f6                	test   %esi,%esi
  801dac:	74 29                	je     801dd7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801dae:	89 f0                	mov    %esi,%eax
  801db0:	29 d0                	sub    %edx,%eax
  801db2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db6:	03 55 0c             	add    0xc(%ebp),%edx
  801db9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dbd:	89 3c 24             	mov    %edi,(%esp)
  801dc0:	e8 39 ff ff ff       	call   801cfe <read>
		if (m < 0)
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 0e                	js     801dd7 <readn+0x4b>
			return m;
		if (m == 0)
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	74 08                	je     801dd5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801dcd:	01 c3                	add    %eax,%ebx
  801dcf:	89 da                	mov    %ebx,%edx
  801dd1:	39 f3                	cmp    %esi,%ebx
  801dd3:	72 d9                	jb     801dae <readn+0x22>
  801dd5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801dd7:	83 c4 1c             	add    $0x1c,%esp
  801dda:	5b                   	pop    %ebx
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	56                   	push   %esi
  801de3:	53                   	push   %ebx
  801de4:	83 ec 20             	sub    $0x20,%esp
  801de7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801dea:	89 34 24             	mov    %esi,(%esp)
  801ded:	e8 0e fc ff ff       	call   801a00 <fd2num>
  801df2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801df5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df9:	89 04 24             	mov    %eax,(%esp)
  801dfc:	e8 9c fc ff ff       	call   801a9d <fd_lookup>
  801e01:	89 c3                	mov    %eax,%ebx
  801e03:	85 c0                	test   %eax,%eax
  801e05:	78 05                	js     801e0c <fd_close+0x2d>
  801e07:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801e0a:	74 0c                	je     801e18 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801e0c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801e10:	19 c0                	sbb    %eax,%eax
  801e12:	f7 d0                	not    %eax
  801e14:	21 c3                	and    %eax,%ebx
  801e16:	eb 3d                	jmp    801e55 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1f:	8b 06                	mov    (%esi),%eax
  801e21:	89 04 24             	mov    %eax,(%esp)
  801e24:	e8 e8 fc ff ff       	call   801b11 <dev_lookup>
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 16                	js     801e45 <fd_close+0x66>
		if (dev->dev_close)
  801e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e32:	8b 40 10             	mov    0x10(%eax),%eax
  801e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	74 07                	je     801e45 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801e3e:	89 34 24             	mov    %esi,(%esp)
  801e41:	ff d0                	call   *%eax
  801e43:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801e45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e50:	e8 44 f4 ff ff       	call   801299 <sys_page_unmap>
	return r;
}
  801e55:	89 d8                	mov    %ebx,%eax
  801e57:	83 c4 20             	add    $0x20,%esp
  801e5a:	5b                   	pop    %ebx
  801e5b:	5e                   	pop    %esi
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 27 fc ff ff       	call   801a9d <fd_lookup>
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 13                	js     801e8d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801e7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e81:	00 
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	89 04 24             	mov    %eax,(%esp)
  801e88:	e8 52 ff ff ff       	call   801ddf <fd_close>
}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 18             	sub    $0x18,%esp
  801e95:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e98:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801e9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ea2:	00 
  801ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea6:	89 04 24             	mov    %eax,(%esp)
  801ea9:	e8 79 03 00 00       	call   802227 <open>
  801eae:	89 c3                	mov    %eax,%ebx
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 1b                	js     801ecf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ebb:	89 1c 24             	mov    %ebx,(%esp)
  801ebe:	e8 b7 fc ff ff       	call   801b7a <fstat>
  801ec3:	89 c6                	mov    %eax,%esi
	close(fd);
  801ec5:	89 1c 24             	mov    %ebx,(%esp)
  801ec8:	e8 91 ff ff ff       	call   801e5e <close>
  801ecd:	89 f3                	mov    %esi,%ebx
	return r;
}
  801ecf:	89 d8                	mov    %ebx,%eax
  801ed1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ed4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ed7:	89 ec                	mov    %ebp,%esp
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    

00801edb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	53                   	push   %ebx
  801edf:	83 ec 14             	sub    $0x14,%esp
  801ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801ee7:	89 1c 24             	mov    %ebx,(%esp)
  801eea:	e8 6f ff ff ff       	call   801e5e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801eef:	83 c3 01             	add    $0x1,%ebx
  801ef2:	83 fb 20             	cmp    $0x20,%ebx
  801ef5:	75 f0                	jne    801ee7 <close_all+0xc>
		close(i);
}
  801ef7:	83 c4 14             	add    $0x14,%esp
  801efa:	5b                   	pop    %ebx
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 58             	sub    $0x58,%esp
  801f03:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f06:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f09:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f0c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801f0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f16:	8b 45 08             	mov    0x8(%ebp),%eax
  801f19:	89 04 24             	mov    %eax,(%esp)
  801f1c:	e8 7c fb ff ff       	call   801a9d <fd_lookup>
  801f21:	89 c3                	mov    %eax,%ebx
  801f23:	85 c0                	test   %eax,%eax
  801f25:	0f 88 e0 00 00 00    	js     80200b <dup+0x10e>
		return r;
	close(newfdnum);
  801f2b:	89 3c 24             	mov    %edi,(%esp)
  801f2e:	e8 2b ff ff ff       	call   801e5e <close>

	newfd = INDEX2FD(newfdnum);
  801f33:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801f39:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801f3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f3f:	89 04 24             	mov    %eax,(%esp)
  801f42:	e8 c9 fa ff ff       	call   801a10 <fd2data>
  801f47:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801f49:	89 34 24             	mov    %esi,(%esp)
  801f4c:	e8 bf fa ff ff       	call   801a10 <fd2data>
  801f51:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801f54:	89 da                	mov    %ebx,%edx
  801f56:	89 d8                	mov    %ebx,%eax
  801f58:	c1 e8 16             	shr    $0x16,%eax
  801f5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f62:	a8 01                	test   $0x1,%al
  801f64:	74 43                	je     801fa9 <dup+0xac>
  801f66:	c1 ea 0c             	shr    $0xc,%edx
  801f69:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801f70:	a8 01                	test   $0x1,%al
  801f72:	74 35                	je     801fa9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801f74:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801f7b:	25 07 0e 00 00       	and    $0xe07,%eax
  801f80:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f84:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f92:	00 
  801f93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9e:	e8 62 f3 ff ff       	call   801305 <sys_page_map>
  801fa3:	89 c3                	mov    %eax,%ebx
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	78 3f                	js     801fe8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fac:	89 c2                	mov    %eax,%edx
  801fae:	c1 ea 0c             	shr    $0xc,%edx
  801fb1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801fb8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801fbe:	89 54 24 10          	mov    %edx,0x10(%esp)
  801fc2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801fc6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fcd:	00 
  801fce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd9:	e8 27 f3 ff ff       	call   801305 <sys_page_map>
  801fde:	89 c3                	mov    %eax,%ebx
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	78 04                	js     801fe8 <dup+0xeb>
  801fe4:	89 fb                	mov    %edi,%ebx
  801fe6:	eb 23                	jmp    80200b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801fe8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff3:	e8 a1 f2 ff ff       	call   801299 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ff8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802006:	e8 8e f2 ff ff       	call   801299 <sys_page_unmap>
	return r;
}
  80200b:	89 d8                	mov    %ebx,%eax
  80200d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802010:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802013:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802016:	89 ec                	mov    %ebp,%esp
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    
	...

0080201c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 18             	sub    $0x18,%esp
  802022:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802025:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802028:	89 c3                	mov    %eax,%ebx
  80202a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80202c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  802033:	75 11                	jne    802046 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802035:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80203c:	e8 7f f8 ff ff       	call   8018c0 <ipc_find_env>
  802041:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802046:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80204d:	00 
  80204e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  802055:	00 
  802056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80205a:	a1 00 40 80 00       	mov    0x804000,%eax
  80205f:	89 04 24             	mov    %eax,(%esp)
  802062:	e8 a4 f8 ff ff       	call   80190b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802067:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80206e:	00 
  80206f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207a:	e8 0a f9 ff ff       	call   801989 <ipc_recv>
}
  80207f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802082:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802085:	89 ec                	mov    %ebp,%esp
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    

00802089 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80208f:	8b 45 08             	mov    0x8(%ebp),%eax
  802092:	8b 40 0c             	mov    0xc(%eax),%eax
  802095:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80209a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8020a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8020a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8020ac:	e8 6b ff ff ff       	call   80201c <fsipc>
}
  8020b1:	c9                   	leave  
  8020b2:	c3                   	ret    

008020b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8020b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8020bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8020c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8020c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8020ce:	e8 49 ff ff ff       	call   80201c <fsipc>
}
  8020d3:	c9                   	leave  
  8020d4:	c3                   	ret    

008020d5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8020db:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8020e5:	e8 32 ff ff ff       	call   80201c <fsipc>
}
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    

008020ec <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	53                   	push   %ebx
  8020f0:	83 ec 14             	sub    $0x14,%esp
  8020f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8020f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8020fc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802101:	ba 00 00 00 00       	mov    $0x0,%edx
  802106:	b8 05 00 00 00       	mov    $0x5,%eax
  80210b:	e8 0c ff ff ff       	call   80201c <fsipc>
  802110:	85 c0                	test   %eax,%eax
  802112:	78 2b                	js     80213f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802114:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80211b:	00 
  80211c:	89 1c 24             	mov    %ebx,(%esp)
  80211f:	e8 26 ea ff ff       	call   800b4a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802124:	a1 80 50 80 00       	mov    0x805080,%eax
  802129:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80212f:	a1 84 50 80 00       	mov    0x805084,%eax
  802134:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80213a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80213f:	83 c4 14             	add    $0x14,%esp
  802142:	5b                   	pop    %ebx
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 18             	sub    $0x18,%esp
  80214b:	8b 45 10             	mov    0x10(%ebp),%eax
  80214e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802153:	76 05                	jbe    80215a <devfile_write+0x15>
  802155:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  80215a:	8b 55 08             	mov    0x8(%ebp),%edx
  80215d:	8b 52 0c             	mov    0xc(%edx),%edx
  802160:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  802166:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  80216b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80216f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802172:	89 44 24 04          	mov    %eax,0x4(%esp)
  802176:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80217d:	e8 b3 eb ff ff       	call   800d35 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  802182:	ba 00 00 00 00       	mov    $0x0,%edx
  802187:	b8 04 00 00 00       	mov    $0x4,%eax
  80218c:	e8 8b fe ff ff       	call   80201c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802191:	c9                   	leave  
  802192:	c3                   	ret    

00802193 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	53                   	push   %ebx
  802197:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80219a:	8b 45 08             	mov    0x8(%ebp),%eax
  80219d:	8b 40 0c             	mov    0xc(%eax),%eax
  8021a0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  8021a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  8021ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8021b7:	e8 60 fe ff ff       	call   80201c <fsipc>
  8021bc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	78 17                	js     8021d9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  8021c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8021cd:	00 
  8021ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 5c eb ff ff       	call   800d35 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  8021d9:	89 d8                	mov    %ebx,%eax
  8021db:	83 c4 14             	add    $0x14,%esp
  8021de:	5b                   	pop    %ebx
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	53                   	push   %ebx
  8021e5:	83 ec 14             	sub    $0x14,%esp
  8021e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8021eb:	89 1c 24             	mov    %ebx,(%esp)
  8021ee:	e8 0d e9 ff ff       	call   800b00 <strlen>
  8021f3:	89 c2                	mov    %eax,%edx
  8021f5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8021fa:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802200:	7f 1f                	jg     802221 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802202:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802206:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80220d:	e8 38 e9 ff ff       	call   800b4a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802212:	ba 00 00 00 00       	mov    $0x0,%edx
  802217:	b8 07 00 00 00       	mov    $0x7,%eax
  80221c:	e8 fb fd ff ff       	call   80201c <fsipc>
}
  802221:	83 c4 14             	add    $0x14,%esp
  802224:	5b                   	pop    %ebx
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    

00802227 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802227:	55                   	push   %ebp
  802228:	89 e5                	mov    %esp,%ebp
  80222a:	83 ec 28             	sub    $0x28,%esp
  80222d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802230:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802233:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802236:	89 34 24             	mov    %esi,(%esp)
  802239:	e8 c2 e8 ff ff       	call   800b00 <strlen>
  80223e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802243:	3d 00 04 00 00       	cmp    $0x400,%eax
  802248:	7f 6d                	jg     8022b7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80224a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224d:	89 04 24             	mov    %eax,(%esp)
  802250:	e8 d6 f7 ff ff       	call   801a2b <fd_alloc>
  802255:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  802257:	85 c0                	test   %eax,%eax
  802259:	78 5c                	js     8022b7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80225b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  802263:	89 34 24             	mov    %esi,(%esp)
  802266:	e8 95 e8 ff ff       	call   800b00 <strlen>
  80226b:	83 c0 01             	add    $0x1,%eax
  80226e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802272:	89 74 24 04          	mov    %esi,0x4(%esp)
  802276:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80227d:	e8 b3 ea ff ff       	call   800d35 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  802282:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802285:	b8 01 00 00 00       	mov    $0x1,%eax
  80228a:	e8 8d fd ff ff       	call   80201c <fsipc>
  80228f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802291:	85 c0                	test   %eax,%eax
  802293:	79 15                	jns    8022aa <open+0x83>
             fd_close(fd,0);
  802295:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80229c:	00 
  80229d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a0:	89 04 24             	mov    %eax,(%esp)
  8022a3:	e8 37 fb ff ff       	call   801ddf <fd_close>
             return r;
  8022a8:	eb 0d                	jmp    8022b7 <open+0x90>
        }
        return fd2num(fd);
  8022aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ad:	89 04 24             	mov    %eax,(%esp)
  8022b0:	e8 4b f7 ff ff       	call   801a00 <fd2num>
  8022b5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8022b7:	89 d8                	mov    %ebx,%eax
  8022b9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8022bc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8022bf:	89 ec                	mov    %ebp,%esp
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    
	...

008022c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	56                   	push   %esi
  8022c8:	53                   	push   %ebx
  8022c9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8022cc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022cf:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8022d5:	e8 88 f1 ff ff       	call   801462 <sys_getenvid>
  8022da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8022e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8022e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f0:	c7 04 24 64 2b 80 00 	movl   $0x802b64,(%esp)
  8022f7:	e8 21 df ff ff       	call   80021d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  802300:	8b 45 10             	mov    0x10(%ebp),%eax
  802303:	89 04 24             	mov    %eax,(%esp)
  802306:	e8 b1 de ff ff       	call   8001bc <vcprintf>
	cprintf("\n");
  80230b:	c7 04 24 58 2b 80 00 	movl   $0x802b58,(%esp)
  802312:	e8 06 df ff ff       	call   80021d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802317:	cc                   	int3   
  802318:	eb fd                	jmp    802317 <_panic+0x53>
	...

0080231c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802322:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802329:	75 30                	jne    80235b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80232b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802332:	00 
  802333:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80233a:	ee 
  80233b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802342:	e8 2c f0 ff ff       	call   801373 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802347:	c7 44 24 04 68 23 80 	movl   $0x802368,0x4(%esp)
  80234e:	00 
  80234f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802356:	e8 fa ed ff ff       	call   801155 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80235b:	8b 45 08             	mov    0x8(%ebp),%eax
  80235e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802363:	c9                   	leave  
  802364:	c3                   	ret    
  802365:	00 00                	add    %al,(%eax)
	...

00802368 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802368:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802369:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80236e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802370:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  802373:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  802377:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  80237b:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  80237e:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802380:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  802384:	83 c4 08             	add    $0x8,%esp
        popal
  802387:	61                   	popa   
        addl $0x4,%esp
  802388:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  80238b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  80238c:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80238d:	c3                   	ret    
	...

00802390 <__udivdi3>:
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	57                   	push   %edi
  802394:	56                   	push   %esi
  802395:	83 ec 10             	sub    $0x10,%esp
  802398:	8b 45 14             	mov    0x14(%ebp),%eax
  80239b:	8b 55 08             	mov    0x8(%ebp),%edx
  80239e:	8b 75 10             	mov    0x10(%ebp),%esi
  8023a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8023a9:	75 35                	jne    8023e0 <__udivdi3+0x50>
  8023ab:	39 fe                	cmp    %edi,%esi
  8023ad:	77 61                	ja     802410 <__udivdi3+0x80>
  8023af:	85 f6                	test   %esi,%esi
  8023b1:	75 0b                	jne    8023be <__udivdi3+0x2e>
  8023b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b8:	31 d2                	xor    %edx,%edx
  8023ba:	f7 f6                	div    %esi
  8023bc:	89 c6                	mov    %eax,%esi
  8023be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8023c1:	31 d2                	xor    %edx,%edx
  8023c3:	89 f8                	mov    %edi,%eax
  8023c5:	f7 f6                	div    %esi
  8023c7:	89 c7                	mov    %eax,%edi
  8023c9:	89 c8                	mov    %ecx,%eax
  8023cb:	f7 f6                	div    %esi
  8023cd:	89 c1                	mov    %eax,%ecx
  8023cf:	89 fa                	mov    %edi,%edx
  8023d1:	89 c8                	mov    %ecx,%eax
  8023d3:	83 c4 10             	add    $0x10,%esp
  8023d6:	5e                   	pop    %esi
  8023d7:	5f                   	pop    %edi
  8023d8:	5d                   	pop    %ebp
  8023d9:	c3                   	ret    
  8023da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e0:	39 f8                	cmp    %edi,%eax
  8023e2:	77 1c                	ja     802400 <__udivdi3+0x70>
  8023e4:	0f bd d0             	bsr    %eax,%edx
  8023e7:	83 f2 1f             	xor    $0x1f,%edx
  8023ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8023ed:	75 39                	jne    802428 <__udivdi3+0x98>
  8023ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8023f2:	0f 86 a0 00 00 00    	jbe    802498 <__udivdi3+0x108>
  8023f8:	39 f8                	cmp    %edi,%eax
  8023fa:	0f 82 98 00 00 00    	jb     802498 <__udivdi3+0x108>
  802400:	31 ff                	xor    %edi,%edi
  802402:	31 c9                	xor    %ecx,%ecx
  802404:	89 c8                	mov    %ecx,%eax
  802406:	89 fa                	mov    %edi,%edx
  802408:	83 c4 10             	add    $0x10,%esp
  80240b:	5e                   	pop    %esi
  80240c:	5f                   	pop    %edi
  80240d:	5d                   	pop    %ebp
  80240e:	c3                   	ret    
  80240f:	90                   	nop
  802410:	89 d1                	mov    %edx,%ecx
  802412:	89 fa                	mov    %edi,%edx
  802414:	89 c8                	mov    %ecx,%eax
  802416:	31 ff                	xor    %edi,%edi
  802418:	f7 f6                	div    %esi
  80241a:	89 c1                	mov    %eax,%ecx
  80241c:	89 fa                	mov    %edi,%edx
  80241e:	89 c8                	mov    %ecx,%eax
  802420:	83 c4 10             	add    $0x10,%esp
  802423:	5e                   	pop    %esi
  802424:	5f                   	pop    %edi
  802425:	5d                   	pop    %ebp
  802426:	c3                   	ret    
  802427:	90                   	nop
  802428:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80242c:	89 f2                	mov    %esi,%edx
  80242e:	d3 e0                	shl    %cl,%eax
  802430:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802433:	b8 20 00 00 00       	mov    $0x20,%eax
  802438:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80243b:	89 c1                	mov    %eax,%ecx
  80243d:	d3 ea                	shr    %cl,%edx
  80243f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802443:	0b 55 ec             	or     -0x14(%ebp),%edx
  802446:	d3 e6                	shl    %cl,%esi
  802448:	89 c1                	mov    %eax,%ecx
  80244a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80244d:	89 fe                	mov    %edi,%esi
  80244f:	d3 ee                	shr    %cl,%esi
  802451:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802455:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802458:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80245b:	d3 e7                	shl    %cl,%edi
  80245d:	89 c1                	mov    %eax,%ecx
  80245f:	d3 ea                	shr    %cl,%edx
  802461:	09 d7                	or     %edx,%edi
  802463:	89 f2                	mov    %esi,%edx
  802465:	89 f8                	mov    %edi,%eax
  802467:	f7 75 ec             	divl   -0x14(%ebp)
  80246a:	89 d6                	mov    %edx,%esi
  80246c:	89 c7                	mov    %eax,%edi
  80246e:	f7 65 e8             	mull   -0x18(%ebp)
  802471:	39 d6                	cmp    %edx,%esi
  802473:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802476:	72 30                	jb     8024a8 <__udivdi3+0x118>
  802478:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80247b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80247f:	d3 e2                	shl    %cl,%edx
  802481:	39 c2                	cmp    %eax,%edx
  802483:	73 05                	jae    80248a <__udivdi3+0xfa>
  802485:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802488:	74 1e                	je     8024a8 <__udivdi3+0x118>
  80248a:	89 f9                	mov    %edi,%ecx
  80248c:	31 ff                	xor    %edi,%edi
  80248e:	e9 71 ff ff ff       	jmp    802404 <__udivdi3+0x74>
  802493:	90                   	nop
  802494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802498:	31 ff                	xor    %edi,%edi
  80249a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80249f:	e9 60 ff ff ff       	jmp    802404 <__udivdi3+0x74>
  8024a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8024ab:	31 ff                	xor    %edi,%edi
  8024ad:	89 c8                	mov    %ecx,%eax
  8024af:	89 fa                	mov    %edi,%edx
  8024b1:	83 c4 10             	add    $0x10,%esp
  8024b4:	5e                   	pop    %esi
  8024b5:	5f                   	pop    %edi
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    
	...

008024c0 <__umoddi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	57                   	push   %edi
  8024c4:	56                   	push   %esi
  8024c5:	83 ec 20             	sub    $0x20,%esp
  8024c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8024cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8024d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024d4:	85 d2                	test   %edx,%edx
  8024d6:	89 c8                	mov    %ecx,%eax
  8024d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8024db:	75 13                	jne    8024f0 <__umoddi3+0x30>
  8024dd:	39 f7                	cmp    %esi,%edi
  8024df:	76 3f                	jbe    802520 <__umoddi3+0x60>
  8024e1:	89 f2                	mov    %esi,%edx
  8024e3:	f7 f7                	div    %edi
  8024e5:	89 d0                	mov    %edx,%eax
  8024e7:	31 d2                	xor    %edx,%edx
  8024e9:	83 c4 20             	add    $0x20,%esp
  8024ec:	5e                   	pop    %esi
  8024ed:	5f                   	pop    %edi
  8024ee:	5d                   	pop    %ebp
  8024ef:	c3                   	ret    
  8024f0:	39 f2                	cmp    %esi,%edx
  8024f2:	77 4c                	ja     802540 <__umoddi3+0x80>
  8024f4:	0f bd ca             	bsr    %edx,%ecx
  8024f7:	83 f1 1f             	xor    $0x1f,%ecx
  8024fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8024fd:	75 51                	jne    802550 <__umoddi3+0x90>
  8024ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802502:	0f 87 e0 00 00 00    	ja     8025e8 <__umoddi3+0x128>
  802508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250b:	29 f8                	sub    %edi,%eax
  80250d:	19 d6                	sbb    %edx,%esi
  80250f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802515:	89 f2                	mov    %esi,%edx
  802517:	83 c4 20             	add    $0x20,%esp
  80251a:	5e                   	pop    %esi
  80251b:	5f                   	pop    %edi
  80251c:	5d                   	pop    %ebp
  80251d:	c3                   	ret    
  80251e:	66 90                	xchg   %ax,%ax
  802520:	85 ff                	test   %edi,%edi
  802522:	75 0b                	jne    80252f <__umoddi3+0x6f>
  802524:	b8 01 00 00 00       	mov    $0x1,%eax
  802529:	31 d2                	xor    %edx,%edx
  80252b:	f7 f7                	div    %edi
  80252d:	89 c7                	mov    %eax,%edi
  80252f:	89 f0                	mov    %esi,%eax
  802531:	31 d2                	xor    %edx,%edx
  802533:	f7 f7                	div    %edi
  802535:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802538:	f7 f7                	div    %edi
  80253a:	eb a9                	jmp    8024e5 <__umoddi3+0x25>
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 f2                	mov    %esi,%edx
  802544:	83 c4 20             	add    $0x20,%esp
  802547:	5e                   	pop    %esi
  802548:	5f                   	pop    %edi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    
  80254b:	90                   	nop
  80254c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802550:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802554:	d3 e2                	shl    %cl,%edx
  802556:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802559:	ba 20 00 00 00       	mov    $0x20,%edx
  80255e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802561:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802564:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802568:	89 fa                	mov    %edi,%edx
  80256a:	d3 ea                	shr    %cl,%edx
  80256c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802570:	0b 55 f4             	or     -0xc(%ebp),%edx
  802573:	d3 e7                	shl    %cl,%edi
  802575:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802579:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80257c:	89 f2                	mov    %esi,%edx
  80257e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802581:	89 c7                	mov    %eax,%edi
  802583:	d3 ea                	shr    %cl,%edx
  802585:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802589:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80258c:	89 c2                	mov    %eax,%edx
  80258e:	d3 e6                	shl    %cl,%esi
  802590:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802594:	d3 ea                	shr    %cl,%edx
  802596:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80259a:	09 d6                	or     %edx,%esi
  80259c:	89 f0                	mov    %esi,%eax
  80259e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8025a1:	d3 e7                	shl    %cl,%edi
  8025a3:	89 f2                	mov    %esi,%edx
  8025a5:	f7 75 f4             	divl   -0xc(%ebp)
  8025a8:	89 d6                	mov    %edx,%esi
  8025aa:	f7 65 e8             	mull   -0x18(%ebp)
  8025ad:	39 d6                	cmp    %edx,%esi
  8025af:	72 2b                	jb     8025dc <__umoddi3+0x11c>
  8025b1:	39 c7                	cmp    %eax,%edi
  8025b3:	72 23                	jb     8025d8 <__umoddi3+0x118>
  8025b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8025b9:	29 c7                	sub    %eax,%edi
  8025bb:	19 d6                	sbb    %edx,%esi
  8025bd:	89 f0                	mov    %esi,%eax
  8025bf:	89 f2                	mov    %esi,%edx
  8025c1:	d3 ef                	shr    %cl,%edi
  8025c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8025c7:	d3 e0                	shl    %cl,%eax
  8025c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8025cd:	09 f8                	or     %edi,%eax
  8025cf:	d3 ea                	shr    %cl,%edx
  8025d1:	83 c4 20             	add    $0x20,%esp
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    
  8025d8:	39 d6                	cmp    %edx,%esi
  8025da:	75 d9                	jne    8025b5 <__umoddi3+0xf5>
  8025dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8025df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8025e2:	eb d1                	jmp    8025b5 <__umoddi3+0xf5>
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	0f 82 18 ff ff ff    	jb     802508 <__umoddi3+0x48>
  8025f0:	e9 1d ff ff ff       	jmp    802512 <__umoddi3+0x52>
