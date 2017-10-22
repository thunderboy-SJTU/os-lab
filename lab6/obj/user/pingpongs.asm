
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
  80003d:	e8 d2 15 00 00       	call   801614 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 0c 50 80 00    	mov    0x80500c,%ebx
  80004f:	e8 13 15 00 00       	call   801567 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  800063:	e8 b5 01 00 00       	call   80021d <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 f7 14 00 00       	call   801567 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 7a 2c 80 00 	movl   $0x802c7a,(%esp)
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
  8000a2:	e8 64 19 00 00       	call   801a0b <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 c7 19 00 00       	call   801a89 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 0c 50 80 00    	mov    0x80500c,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 8b 14 00 00       	call   801567 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  8000fa:	e8 1e 01 00 00       	call   80021d <cprintf>
		if (val == 10)
  8000ff:	a1 08 50 80 00       	mov    0x805008,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 08 50 80 00       	mov    %eax,0x805008
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 d7 18 00 00       	call   801a0b <ipc_send>
		if (val == 10)
  800134:	83 3d 08 50 80 00 0a 	cmpl   $0xa,0x805008
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
  80015e:	e8 04 14 00 00       	call   801567 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	89 c2                	mov    %eax,%edx
  80016a:	c1 e2 07             	shl    $0x7,%edx
  80016d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800174:	a3 0c 50 80 00       	mov    %eax,0x80500c
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x38>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 40 80 00       	mov    %eax,0x804000

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
  8001a6:	e8 30 1e 00 00       	call   801fdb <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 f0 13 00 00       	call   8015a7 <sys_env_destroy>
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
  8002ef:	e8 ec 26 00 00       	call   8029e0 <__udivdi3>
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
  800357:	e8 b4 27 00 00       	call   802b10 <__umoddi3>
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	0f be 80 c0 2c 80 00 	movsbl 0x802cc0(%eax),%eax
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
  80044a:	ff 24 95 a0 2e 80 00 	jmp    *0x802ea0(,%edx,4)
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
  800507:	8b 14 85 00 30 80 00 	mov    0x803000(,%eax,4),%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	75 26                	jne    800538 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800512:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800516:	c7 44 24 08 d1 2c 80 	movl   $0x802cd1,0x8(%esp)
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
  80053c:	c7 44 24 08 f2 31 80 	movl   $0x8031f2,0x8(%esp)
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
  80057a:	be da 2c 80 00       	mov    $0x802cda,%esi
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
  800824:	e8 b7 21 00 00       	call   8029e0 <__udivdi3>
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
  800870:	e8 9b 22 00 00       	call   802b10 <__umoddi3>
  800875:	89 74 24 04          	mov    %esi,0x4(%esp)
  800879:	0f be 80 c0 2c 80 00 	movsbl 0x802cc0(%eax),%eax
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
  800925:	c7 44 24 0c f4 2d 80 	movl   $0x802df4,0xc(%esp)
  80092c:	00 
  80092d:	c7 44 24 08 f2 31 80 	movl   $0x8031f2,0x8(%esp)
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
  80095b:	c7 44 24 0c 2c 2e 80 	movl   $0x802e2c,0xc(%esp)
  800962:	00 
  800963:	c7 44 24 08 f2 31 80 	movl   $0x8031f2,0x8(%esp)
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
  8009ef:	e8 1c 21 00 00       	call   802b10 <__umoddi3>
  8009f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f8:	0f be 80 c0 2c 80 00 	movsbl 0x802cc0(%eax),%eax
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
  800a31:	e8 da 20 00 00       	call   802b10 <__umoddi3>
  800a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3a:	0f be 80 c0 2c 80 00 	movsbl 0x802cc0(%eax),%eax
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

00800fbb <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  800fc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcd:	b8 13 00 00 00       	mov    $0x13,%eax
  800fd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd5:	89 cb                	mov    %ecx,%ebx
  800fd7:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800ff1:	8b 1c 24             	mov    (%esp),%ebx
  800ff4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff8:	89 ec                	mov    %ebp,%esp
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	89 1c 24             	mov    %ebx,(%esp)
  801005:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100e:	b8 12 00 00 00       	mov    $0x12,%eax
  801013:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	89 df                	mov    %ebx,%edi
  80101b:	51                   	push   %ecx
  80101c:	52                   	push   %edx
  80101d:	53                   	push   %ebx
  80101e:	54                   	push   %esp
  80101f:	55                   	push   %ebp
  801020:	56                   	push   %esi
  801021:	57                   	push   %edi
  801022:	54                   	push   %esp
  801023:	5d                   	pop    %ebp
  801024:	8d 35 2c 10 80 00    	lea    0x80102c,%esi
  80102a:	0f 34                	sysenter 
  80102c:	5f                   	pop    %edi
  80102d:	5e                   	pop    %esi
  80102e:	5d                   	pop    %ebp
  80102f:	5c                   	pop    %esp
  801030:	5b                   	pop    %ebx
  801031:	5a                   	pop    %edx
  801032:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801033:	8b 1c 24             	mov    (%esp),%ebx
  801036:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80103a:	89 ec                	mov    %ebp,%esp
  80103c:	5d                   	pop    %ebp
  80103d:	c3                   	ret    

0080103e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	89 1c 24             	mov    %ebx,(%esp)
  801047:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80104b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801050:	b8 11 00 00 00       	mov    $0x11,%eax
  801055:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801058:	8b 55 08             	mov    0x8(%ebp),%edx
  80105b:	89 df                	mov    %ebx,%edi
  80105d:	51                   	push   %ecx
  80105e:	52                   	push   %edx
  80105f:	53                   	push   %ebx
  801060:	54                   	push   %esp
  801061:	55                   	push   %ebp
  801062:	56                   	push   %esi
  801063:	57                   	push   %edi
  801064:	54                   	push   %esp
  801065:	5d                   	pop    %ebp
  801066:	8d 35 6e 10 80 00    	lea    0x80106e,%esi
  80106c:	0f 34                	sysenter 
  80106e:	5f                   	pop    %edi
  80106f:	5e                   	pop    %esi
  801070:	5d                   	pop    %ebp
  801071:	5c                   	pop    %esp
  801072:	5b                   	pop    %ebx
  801073:	5a                   	pop    %edx
  801074:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801075:	8b 1c 24             	mov    (%esp),%ebx
  801078:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80107c:	89 ec                	mov    %ebp,%esp
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	89 1c 24             	mov    %ebx,(%esp)
  801089:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108d:	b8 10 00 00 00       	mov    $0x10,%eax
  801092:	8b 7d 14             	mov    0x14(%ebp),%edi
  801095:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801098:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109b:	8b 55 08             	mov    0x8(%ebp),%edx
  80109e:	51                   	push   %ecx
  80109f:	52                   	push   %edx
  8010a0:	53                   	push   %ebx
  8010a1:	54                   	push   %esp
  8010a2:	55                   	push   %ebp
  8010a3:	56                   	push   %esi
  8010a4:	57                   	push   %edi
  8010a5:	54                   	push   %esp
  8010a6:	5d                   	pop    %ebp
  8010a7:	8d 35 af 10 80 00    	lea    0x8010af,%esi
  8010ad:	0f 34                	sysenter 
  8010af:	5f                   	pop    %edi
  8010b0:	5e                   	pop    %esi
  8010b1:	5d                   	pop    %ebp
  8010b2:	5c                   	pop    %esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5a                   	pop    %edx
  8010b5:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  8010b6:	8b 1c 24             	mov    (%esp),%ebx
  8010b9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010bd:	89 ec                	mov    %ebp,%esp
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	83 ec 28             	sub    $0x28,%esp
  8010c7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010ca:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010da:	8b 55 08             	mov    0x8(%ebp),%edx
  8010dd:	89 df                	mov    %ebx,%edi
  8010df:	51                   	push   %ecx
  8010e0:	52                   	push   %edx
  8010e1:	53                   	push   %ebx
  8010e2:	54                   	push   %esp
  8010e3:	55                   	push   %ebp
  8010e4:	56                   	push   %esi
  8010e5:	57                   	push   %edi
  8010e6:	54                   	push   %esp
  8010e7:	5d                   	pop    %ebp
  8010e8:	8d 35 f0 10 80 00    	lea    0x8010f0,%esi
  8010ee:	0f 34                	sysenter 
  8010f0:	5f                   	pop    %edi
  8010f1:	5e                   	pop    %esi
  8010f2:	5d                   	pop    %ebp
  8010f3:	5c                   	pop    %esp
  8010f4:	5b                   	pop    %ebx
  8010f5:	5a                   	pop    %edx
  8010f6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	7e 28                	jle    801123 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ff:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801106:	00 
  801107:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  80110e:	00 
  80110f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801116:	00 
  801117:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  80111e:	e8 b1 17 00 00       	call   8028d4 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801123:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801126:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801129:	89 ec                	mov    %ebp,%esp
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	89 1c 24             	mov    %ebx,(%esp)
  801136:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113a:	ba 00 00 00 00       	mov    $0x0,%edx
  80113f:	b8 15 00 00 00       	mov    $0x15,%eax
  801144:	89 d1                	mov    %edx,%ecx
  801146:	89 d3                	mov    %edx,%ebx
  801148:	89 d7                	mov    %edx,%edi
  80114a:	51                   	push   %ecx
  80114b:	52                   	push   %edx
  80114c:	53                   	push   %ebx
  80114d:	54                   	push   %esp
  80114e:	55                   	push   %ebp
  80114f:	56                   	push   %esi
  801150:	57                   	push   %edi
  801151:	54                   	push   %esp
  801152:	5d                   	pop    %ebp
  801153:	8d 35 5b 11 80 00    	lea    0x80115b,%esi
  801159:	0f 34                	sysenter 
  80115b:	5f                   	pop    %edi
  80115c:	5e                   	pop    %esi
  80115d:	5d                   	pop    %ebp
  80115e:	5c                   	pop    %esp
  80115f:	5b                   	pop    %ebx
  801160:	5a                   	pop    %edx
  801161:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801162:	8b 1c 24             	mov    (%esp),%ebx
  801165:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801169:	89 ec                	mov    %ebp,%esp
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	89 1c 24             	mov    %ebx,(%esp)
  801176:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80117a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117f:	b8 14 00 00 00       	mov    $0x14,%eax
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	89 cb                	mov    %ecx,%ebx
  801189:	89 cf                	mov    %ecx,%edi
  80118b:	51                   	push   %ecx
  80118c:	52                   	push   %edx
  80118d:	53                   	push   %ebx
  80118e:	54                   	push   %esp
  80118f:	55                   	push   %ebp
  801190:	56                   	push   %esi
  801191:	57                   	push   %edi
  801192:	54                   	push   %esp
  801193:	5d                   	pop    %ebp
  801194:	8d 35 9c 11 80 00    	lea    0x80119c,%esi
  80119a:	0f 34                	sysenter 
  80119c:	5f                   	pop    %edi
  80119d:	5e                   	pop    %esi
  80119e:	5d                   	pop    %ebp
  80119f:	5c                   	pop    %esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5a                   	pop    %edx
  8011a2:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011a3:	8b 1c 24             	mov    (%esp),%ebx
  8011a6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011aa:	89 ec                	mov    %ebp,%esp
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 28             	sub    $0x28,%esp
  8011b4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011b7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011bf:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c7:	89 cb                	mov    %ecx,%ebx
  8011c9:	89 cf                	mov    %ecx,%edi
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
  8011e5:	7e 28                	jle    80120f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011eb:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801202:	00 
  801203:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  80120a:	e8 c5 16 00 00       	call   8028d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80120f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801212:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801215:	89 ec                	mov    %ebp,%esp
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	89 1c 24             	mov    %ebx,(%esp)
  801222:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801226:	b8 0d 00 00 00       	mov    $0xd,%eax
  80122b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80122e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801234:	8b 55 08             	mov    0x8(%ebp),%edx
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

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80124f:	8b 1c 24             	mov    (%esp),%ebx
  801252:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801256:	89 ec                	mov    %ebp,%esp
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	83 ec 28             	sub    $0x28,%esp
  801260:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801263:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801273:	8b 55 08             	mov    0x8(%ebp),%edx
  801276:	89 df                	mov    %ebx,%edi
  801278:	51                   	push   %ecx
  801279:	52                   	push   %edx
  80127a:	53                   	push   %ebx
  80127b:	54                   	push   %esp
  80127c:	55                   	push   %ebp
  80127d:	56                   	push   %esi
  80127e:	57                   	push   %edi
  80127f:	54                   	push   %esp
  801280:	5d                   	pop    %ebp
  801281:	8d 35 89 12 80 00    	lea    0x801289,%esi
  801287:	0f 34                	sysenter 
  801289:	5f                   	pop    %edi
  80128a:	5e                   	pop    %esi
  80128b:	5d                   	pop    %ebp
  80128c:	5c                   	pop    %esp
  80128d:	5b                   	pop    %ebx
  80128e:	5a                   	pop    %edx
  80128f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801290:	85 c0                	test   %eax,%eax
  801292:	7e 28                	jle    8012bc <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801294:	89 44 24 10          	mov    %eax,0x10(%esp)
  801298:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80129f:	00 
  8012a0:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  8012a7:	00 
  8012a8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012af:	00 
  8012b0:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  8012b7:	e8 18 16 00 00       	call   8028d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012bc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012bf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012c2:	89 ec                	mov    %ebp,%esp
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	83 ec 28             	sub    $0x28,%esp
  8012cc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012cf:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012df:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e2:	89 df                	mov    %ebx,%edi
  8012e4:	51                   	push   %ecx
  8012e5:	52                   	push   %edx
  8012e6:	53                   	push   %ebx
  8012e7:	54                   	push   %esp
  8012e8:	55                   	push   %ebp
  8012e9:	56                   	push   %esi
  8012ea:	57                   	push   %edi
  8012eb:	54                   	push   %esp
  8012ec:	5d                   	pop    %ebp
  8012ed:	8d 35 f5 12 80 00    	lea    0x8012f5,%esi
  8012f3:	0f 34                	sysenter 
  8012f5:	5f                   	pop    %edi
  8012f6:	5e                   	pop    %esi
  8012f7:	5d                   	pop    %ebp
  8012f8:	5c                   	pop    %esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5a                   	pop    %edx
  8012fb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	7e 28                	jle    801328 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801300:	89 44 24 10          	mov    %eax,0x10(%esp)
  801304:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80130b:	00 
  80130c:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  801313:	00 
  801314:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80131b:	00 
  80131c:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  801323:	e8 ac 15 00 00       	call   8028d4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801328:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80132b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80132e:	89 ec                	mov    %ebp,%esp
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 28             	sub    $0x28,%esp
  801338:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80133b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80133e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801343:	b8 09 00 00 00       	mov    $0x9,%eax
  801348:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134b:	8b 55 08             	mov    0x8(%ebp),%edx
  80134e:	89 df                	mov    %ebx,%edi
  801350:	51                   	push   %ecx
  801351:	52                   	push   %edx
  801352:	53                   	push   %ebx
  801353:	54                   	push   %esp
  801354:	55                   	push   %ebp
  801355:	56                   	push   %esi
  801356:	57                   	push   %edi
  801357:	54                   	push   %esp
  801358:	5d                   	pop    %ebp
  801359:	8d 35 61 13 80 00    	lea    0x801361,%esi
  80135f:	0f 34                	sysenter 
  801361:	5f                   	pop    %edi
  801362:	5e                   	pop    %esi
  801363:	5d                   	pop    %ebp
  801364:	5c                   	pop    %esp
  801365:	5b                   	pop    %ebx
  801366:	5a                   	pop    %edx
  801367:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801368:	85 c0                	test   %eax,%eax
  80136a:	7e 28                	jle    801394 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801370:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801377:	00 
  801378:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  80137f:	00 
  801380:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801387:	00 
  801388:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  80138f:	e8 40 15 00 00       	call   8028d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801394:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801397:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139a:	89 ec                	mov    %ebp,%esp
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 28             	sub    $0x28,%esp
  8013a4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013a7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013af:	b8 07 00 00 00       	mov    $0x7,%eax
  8013b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ba:	89 df                	mov    %ebx,%edi
  8013bc:	51                   	push   %ecx
  8013bd:	52                   	push   %edx
  8013be:	53                   	push   %ebx
  8013bf:	54                   	push   %esp
  8013c0:	55                   	push   %ebp
  8013c1:	56                   	push   %esi
  8013c2:	57                   	push   %edi
  8013c3:	54                   	push   %esp
  8013c4:	5d                   	pop    %ebp
  8013c5:	8d 35 cd 13 80 00    	lea    0x8013cd,%esi
  8013cb:	0f 34                	sysenter 
  8013cd:	5f                   	pop    %edi
  8013ce:	5e                   	pop    %esi
  8013cf:	5d                   	pop    %ebp
  8013d0:	5c                   	pop    %esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5a                   	pop    %edx
  8013d3:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	7e 28                	jle    801400 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013dc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013e3:	00 
  8013e4:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  8013eb:	00 
  8013ec:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013f3:	00 
  8013f4:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  8013fb:	e8 d4 14 00 00       	call   8028d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801400:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801403:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801406:	89 ec                	mov    %ebp,%esp
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 28             	sub    $0x28,%esp
  801410:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801413:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801416:	8b 7d 18             	mov    0x18(%ebp),%edi
  801419:	0b 7d 14             	or     0x14(%ebp),%edi
  80141c:	b8 06 00 00 00       	mov    $0x6,%eax
  801421:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801427:	8b 55 08             	mov    0x8(%ebp),%edx
  80142a:	51                   	push   %ecx
  80142b:	52                   	push   %edx
  80142c:	53                   	push   %ebx
  80142d:	54                   	push   %esp
  80142e:	55                   	push   %ebp
  80142f:	56                   	push   %esi
  801430:	57                   	push   %edi
  801431:	54                   	push   %esp
  801432:	5d                   	pop    %ebp
  801433:	8d 35 3b 14 80 00    	lea    0x80143b,%esi
  801439:	0f 34                	sysenter 
  80143b:	5f                   	pop    %edi
  80143c:	5e                   	pop    %esi
  80143d:	5d                   	pop    %ebp
  80143e:	5c                   	pop    %esp
  80143f:	5b                   	pop    %ebx
  801440:	5a                   	pop    %edx
  801441:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801442:	85 c0                	test   %eax,%eax
  801444:	7e 28                	jle    80146e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801446:	89 44 24 10          	mov    %eax,0x10(%esp)
  80144a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801451:	00 
  801452:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  801459:	00 
  80145a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801461:	00 
  801462:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  801469:	e8 66 14 00 00       	call   8028d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80146e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801471:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801474:	89 ec                	mov    %ebp,%esp
  801476:	5d                   	pop    %ebp
  801477:	c3                   	ret    

00801478 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 28             	sub    $0x28,%esp
  80147e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801481:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801484:	bf 00 00 00 00       	mov    $0x0,%edi
  801489:	b8 05 00 00 00       	mov    $0x5,%eax
  80148e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801491:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801494:	8b 55 08             	mov    0x8(%ebp),%edx
  801497:	51                   	push   %ecx
  801498:	52                   	push   %edx
  801499:	53                   	push   %ebx
  80149a:	54                   	push   %esp
  80149b:	55                   	push   %ebp
  80149c:	56                   	push   %esi
  80149d:	57                   	push   %edi
  80149e:	54                   	push   %esp
  80149f:	5d                   	pop    %ebp
  8014a0:	8d 35 a8 14 80 00    	lea    0x8014a8,%esi
  8014a6:	0f 34                	sysenter 
  8014a8:	5f                   	pop    %edi
  8014a9:	5e                   	pop    %esi
  8014aa:	5d                   	pop    %ebp
  8014ab:	5c                   	pop    %esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5a                   	pop    %edx
  8014ae:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	7e 28                	jle    8014db <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8014be:	00 
  8014bf:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  8014c6:	00 
  8014c7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014ce:	00 
  8014cf:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  8014d6:	e8 f9 13 00 00       	call   8028d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8014db:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014e1:	89 ec                	mov    %ebp,%esp
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014fc:	89 d1                	mov    %edx,%ecx
  8014fe:	89 d3                	mov    %edx,%ebx
  801500:	89 d7                	mov    %edx,%edi
  801502:	51                   	push   %ecx
  801503:	52                   	push   %edx
  801504:	53                   	push   %ebx
  801505:	54                   	push   %esp
  801506:	55                   	push   %ebp
  801507:	56                   	push   %esi
  801508:	57                   	push   %edi
  801509:	54                   	push   %esp
  80150a:	5d                   	pop    %ebp
  80150b:	8d 35 13 15 80 00    	lea    0x801513,%esi
  801511:	0f 34                	sysenter 
  801513:	5f                   	pop    %edi
  801514:	5e                   	pop    %esi
  801515:	5d                   	pop    %ebp
  801516:	5c                   	pop    %esp
  801517:	5b                   	pop    %ebx
  801518:	5a                   	pop    %edx
  801519:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80151a:	8b 1c 24             	mov    (%esp),%ebx
  80151d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801521:	89 ec                	mov    %ebp,%esp
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	89 1c 24             	mov    %ebx,(%esp)
  80152e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801532:	bb 00 00 00 00       	mov    $0x0,%ebx
  801537:	b8 04 00 00 00       	mov    $0x4,%eax
  80153c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80153f:	8b 55 08             	mov    0x8(%ebp),%edx
  801542:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80155c:	8b 1c 24             	mov    (%esp),%ebx
  80155f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801563:	89 ec                	mov    %ebp,%esp
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	89 1c 24             	mov    %ebx,(%esp)
  801570:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
  801579:	b8 02 00 00 00       	mov    $0x2,%eax
  80157e:	89 d1                	mov    %edx,%ecx
  801580:	89 d3                	mov    %edx,%ebx
  801582:	89 d7                	mov    %edx,%edi
  801584:	51                   	push   %ecx
  801585:	52                   	push   %edx
  801586:	53                   	push   %ebx
  801587:	54                   	push   %esp
  801588:	55                   	push   %ebp
  801589:	56                   	push   %esi
  80158a:	57                   	push   %edi
  80158b:	54                   	push   %esp
  80158c:	5d                   	pop    %ebp
  80158d:	8d 35 95 15 80 00    	lea    0x801595,%esi
  801593:	0f 34                	sysenter 
  801595:	5f                   	pop    %edi
  801596:	5e                   	pop    %esi
  801597:	5d                   	pop    %ebp
  801598:	5c                   	pop    %esp
  801599:	5b                   	pop    %ebx
  80159a:	5a                   	pop    %edx
  80159b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80159c:	8b 1c 24             	mov    (%esp),%ebx
  80159f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015a3:	89 ec                	mov    %ebp,%esp
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    

008015a7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 28             	sub    $0x28,%esp
  8015ad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015b0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015b8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c0:	89 cb                	mov    %ecx,%ebx
  8015c2:	89 cf                	mov    %ecx,%edi
  8015c4:	51                   	push   %ecx
  8015c5:	52                   	push   %edx
  8015c6:	53                   	push   %ebx
  8015c7:	54                   	push   %esp
  8015c8:	55                   	push   %ebp
  8015c9:	56                   	push   %esi
  8015ca:	57                   	push   %edi
  8015cb:	54                   	push   %esp
  8015cc:	5d                   	pop    %ebp
  8015cd:	8d 35 d5 15 80 00    	lea    0x8015d5,%esi
  8015d3:	0f 34                	sysenter 
  8015d5:	5f                   	pop    %edi
  8015d6:	5e                   	pop    %esi
  8015d7:	5d                   	pop    %ebp
  8015d8:	5c                   	pop    %esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5a                   	pop    %edx
  8015db:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	7e 28                	jle    801608 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e4:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8015eb:	00 
  8015ec:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  8015f3:	00 
  8015f4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015fb:	00 
  8015fc:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  801603:	e8 cc 12 00 00       	call   8028d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801608:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80160b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80160e:	89 ec                	mov    %ebp,%esp
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    
	...

00801614 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80161a:	c7 44 24 08 6b 30 80 	movl   $0x80306b,0x8(%esp)
  801621:	00 
  801622:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801629:	00 
  80162a:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801631:	e8 9e 12 00 00       	call   8028d4 <_panic>

00801636 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	57                   	push   %edi
  80163a:	56                   	push   %esi
  80163b:	53                   	push   %ebx
  80163c:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80163f:	c7 04 24 8b 18 80 00 	movl   $0x80188b,(%esp)
  801646:	e8 e1 12 00 00       	call   80292c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80164b:	ba 08 00 00 00       	mov    $0x8,%edx
  801650:	89 d0                	mov    %edx,%eax
  801652:	cd 30                	int    $0x30
  801654:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801657:	85 c0                	test   %eax,%eax
  801659:	79 20                	jns    80167b <fork+0x45>
		panic("sys_exofork: %e", envid);
  80165b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80165f:	c7 44 24 08 8c 30 80 	movl   $0x80308c,0x8(%esp)
  801666:	00 
  801667:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80166e:	00 
  80166f:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801676:	e8 59 12 00 00       	call   8028d4 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  80167b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801680:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801685:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  80168a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80168e:	75 20                	jne    8016b0 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801690:	e8 d2 fe ff ff       	call   801567 <sys_getenvid>
  801695:	25 ff 03 00 00       	and    $0x3ff,%eax
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	c1 e2 07             	shl    $0x7,%edx
  80169f:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8016a6:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  8016ab:	e9 d0 01 00 00       	jmp    801880 <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8016b0:	89 d8                	mov    %ebx,%eax
  8016b2:	c1 e8 16             	shr    $0x16,%eax
  8016b5:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8016b8:	a8 01                	test   $0x1,%al
  8016ba:	0f 84 0d 01 00 00    	je     8017cd <fork+0x197>
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	c1 e8 0c             	shr    $0xc,%eax
  8016c5:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8016c8:	f6 c2 01             	test   $0x1,%dl
  8016cb:	0f 84 fc 00 00 00    	je     8017cd <fork+0x197>
  8016d1:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8016d4:	f6 c2 04             	test   $0x4,%dl
  8016d7:	0f 84 f0 00 00 00    	je     8017cd <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  8016dd:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	c1 ea 0c             	shr    $0xc,%edx
  8016e5:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  8016e8:	f6 c2 01             	test   $0x1,%dl
  8016eb:	0f 84 dc 00 00 00    	je     8017cd <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8016f1:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8016f7:	0f 84 8d 00 00 00    	je     80178a <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8016fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801700:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801707:	00 
  801708:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80170c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801713:	89 44 24 04          	mov    %eax,0x4(%esp)
  801717:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171e:	e8 e7 fc ff ff       	call   80140a <sys_page_map>
               if(r<0)
  801723:	85 c0                	test   %eax,%eax
  801725:	79 1c                	jns    801743 <fork+0x10d>
                 panic("map failed");
  801727:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  80172e:	00 
  80172f:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801736:	00 
  801737:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  80173e:	e8 91 11 00 00       	call   8028d4 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  801743:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80174a:	00 
  80174b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80174e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801752:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801759:	00 
  80175a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801765:	e8 a0 fc ff ff       	call   80140a <sys_page_map>
               if(r<0)
  80176a:	85 c0                	test   %eax,%eax
  80176c:	79 5f                	jns    8017cd <fork+0x197>
                 panic("map failed");
  80176e:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  801775:	00 
  801776:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80177d:	00 
  80177e:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801785:	e8 4a 11 00 00       	call   8028d4 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  80178a:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801791:	00 
  801792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801796:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801799:	89 54 24 08          	mov    %edx,0x8(%esp)
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a8:	e8 5d fc ff ff       	call   80140a <sys_page_map>
               if(r<0)
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	79 1c                	jns    8017cd <fork+0x197>
                 panic("map failed");
  8017b1:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  8017b8:	00 
  8017b9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8017c0:	00 
  8017c1:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  8017c8:	e8 07 11 00 00       	call   8028d4 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8017cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8017d3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8017d9:	0f 85 d1 fe ff ff    	jne    8016b0 <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8017df:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017e6:	00 
  8017e7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017ee:	ee 
  8017ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017f2:	89 04 24             	mov    %eax,(%esp)
  8017f5:	e8 7e fc ff ff       	call   801478 <sys_page_alloc>
        if(r < 0)
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	79 1c                	jns    80181a <fork+0x1e4>
            panic("alloc failed");
  8017fe:	c7 44 24 08 a7 30 80 	movl   $0x8030a7,0x8(%esp)
  801805:	00 
  801806:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80180d:	00 
  80180e:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801815:	e8 ba 10 00 00       	call   8028d4 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80181a:	c7 44 24 04 78 29 80 	movl   $0x802978,0x4(%esp)
  801821:	00 
  801822:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801825:	89 14 24             	mov    %edx,(%esp)
  801828:	e8 2d fa ff ff       	call   80125a <sys_env_set_pgfault_upcall>
        if(r < 0)
  80182d:	85 c0                	test   %eax,%eax
  80182f:	79 1c                	jns    80184d <fork+0x217>
            panic("set pgfault upcall failed");
  801831:	c7 44 24 08 b4 30 80 	movl   $0x8030b4,0x8(%esp)
  801838:	00 
  801839:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801840:	00 
  801841:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801848:	e8 87 10 00 00       	call   8028d4 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  80184d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801854:	00 
  801855:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801858:	89 04 24             	mov    %eax,(%esp)
  80185b:	e8 d2 fa ff ff       	call   801332 <sys_env_set_status>
        if(r < 0)
  801860:	85 c0                	test   %eax,%eax
  801862:	79 1c                	jns    801880 <fork+0x24a>
            panic("set status failed");
  801864:	c7 44 24 08 ce 30 80 	movl   $0x8030ce,0x8(%esp)
  80186b:	00 
  80186c:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801873:	00 
  801874:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  80187b:	e8 54 10 00 00       	call   8028d4 <_panic>
        return envid;
	//panic("fork not implemented");
}
  801880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801883:	83 c4 3c             	add    $0x3c,%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5f                   	pop    %edi
  801889:	5d                   	pop    %ebp
  80188a:	c3                   	ret    

0080188b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	53                   	push   %ebx
  80188f:	83 ec 24             	sub    $0x24,%esp
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801895:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801897:	89 da                	mov    %ebx,%edx
  801899:	c1 ea 0c             	shr    $0xc,%edx
  80189c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8018a3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8018a7:	74 08                	je     8018b1 <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  8018a9:	f7 c2 05 08 00 00    	test   $0x805,%edx
  8018af:	75 1c                	jne    8018cd <pgfault+0x42>
           panic("pgfault error");
  8018b1:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  8018b8:	00 
  8018b9:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8018c0:	00 
  8018c1:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  8018c8:	e8 07 10 00 00       	call   8028d4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018cd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018d4:	00 
  8018d5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018dc:	00 
  8018dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e4:	e8 8f fb ff ff       	call   801478 <sys_page_alloc>
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	79 20                	jns    80190d <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  8018ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018f1:	c7 44 24 08 ee 30 80 	movl   $0x8030ee,0x8(%esp)
  8018f8:	00 
  8018f9:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801900:	00 
  801901:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801908:	e8 c7 0f 00 00       	call   8028d4 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  80190d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801913:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80191a:	00 
  80191b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80191f:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801926:	e8 0a f4 ff ff       	call   800d35 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  80192b:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801932:	00 
  801933:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801937:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80193e:	00 
  80193f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801946:	00 
  801947:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194e:	e8 b7 fa ff ff       	call   80140a <sys_page_map>
  801953:	85 c0                	test   %eax,%eax
  801955:	79 20                	jns    801977 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801957:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80195b:	c7 44 24 08 01 31 80 	movl   $0x803101,0x8(%esp)
  801962:	00 
  801963:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80196a:	00 
  80196b:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801972:	e8 5d 0f 00 00       	call   8028d4 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801977:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80197e:	00 
  80197f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801986:	e8 13 fa ff ff       	call   80139e <sys_page_unmap>
  80198b:	85 c0                	test   %eax,%eax
  80198d:	79 20                	jns    8019af <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80198f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801993:	c7 44 24 08 12 31 80 	movl   $0x803112,0x8(%esp)
  80199a:	00 
  80199b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8019a2:	00 
  8019a3:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  8019aa:	e8 25 0f 00 00       	call   8028d4 <_panic>
	//panic("pgfault not implemented");
}
  8019af:	83 c4 24             	add    $0x24,%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5d                   	pop    %ebp
  8019b4:	c3                   	ret    
	...

008019c0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8019c6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8019cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d1:	39 ca                	cmp    %ecx,%edx
  8019d3:	75 04                	jne    8019d9 <ipc_find_env+0x19>
  8019d5:	b0 00                	mov    $0x0,%al
  8019d7:	eb 12                	jmp    8019eb <ipc_find_env+0x2b>
  8019d9:	89 c2                	mov    %eax,%edx
  8019db:	c1 e2 07             	shl    $0x7,%edx
  8019de:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8019e5:	8b 12                	mov    (%edx),%edx
  8019e7:	39 ca                	cmp    %ecx,%edx
  8019e9:	75 10                	jne    8019fb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8019eb:	89 c2                	mov    %eax,%edx
  8019ed:	c1 e2 07             	shl    $0x7,%edx
  8019f0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8019f7:	8b 00                	mov    (%eax),%eax
  8019f9:	eb 0e                	jmp    801a09 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019fb:	83 c0 01             	add    $0x1,%eax
  8019fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a03:	75 d4                	jne    8019d9 <ipc_find_env+0x19>
  801a05:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	57                   	push   %edi
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	83 ec 1c             	sub    $0x1c,%esp
  801a14:	8b 75 08             	mov    0x8(%ebp),%esi
  801a17:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801a1d:	85 db                	test   %ebx,%ebx
  801a1f:	74 19                	je     801a3a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801a21:	8b 45 14             	mov    0x14(%ebp),%eax
  801a24:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a28:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a2c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a30:	89 34 24             	mov    %esi,(%esp)
  801a33:	e8 e1 f7 ff ff       	call   801219 <sys_ipc_try_send>
  801a38:	eb 1b                	jmp    801a55 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801a3a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a41:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801a48:	ee 
  801a49:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a4d:	89 34 24             	mov    %esi,(%esp)
  801a50:	e8 c4 f7 ff ff       	call   801219 <sys_ipc_try_send>
           if(ret == 0)
  801a55:	85 c0                	test   %eax,%eax
  801a57:	74 28                	je     801a81 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801a59:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a5c:	74 1c                	je     801a7a <ipc_send+0x6f>
              panic("ipc send error");
  801a5e:	c7 44 24 08 25 31 80 	movl   $0x803125,0x8(%esp)
  801a65:	00 
  801a66:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801a6d:	00 
  801a6e:	c7 04 24 34 31 80 00 	movl   $0x803134,(%esp)
  801a75:	e8 5a 0e 00 00       	call   8028d4 <_panic>
           sys_yield();
  801a7a:	e8 66 fa ff ff       	call   8014e5 <sys_yield>
        }
  801a7f:	eb 9c                	jmp    801a1d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801a81:	83 c4 1c             	add    $0x1c,%esp
  801a84:	5b                   	pop    %ebx
  801a85:	5e                   	pop    %esi
  801a86:	5f                   	pop    %edi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 10             	sub    $0x10,%esp
  801a91:	8b 75 08             	mov    0x8(%ebp),%esi
  801a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	75 0e                	jne    801aac <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801a9e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801aa5:	e8 04 f7 ff ff       	call   8011ae <sys_ipc_recv>
  801aaa:	eb 08                	jmp    801ab4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801aac:	89 04 24             	mov    %eax,(%esp)
  801aaf:	e8 fa f6 ff ff       	call   8011ae <sys_ipc_recv>
        if(ret == 0){
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	75 26                	jne    801ade <ipc_recv+0x55>
           if(from_env_store)
  801ab8:	85 f6                	test   %esi,%esi
  801aba:	74 0a                	je     801ac6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801abc:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801ac1:	8b 40 78             	mov    0x78(%eax),%eax
  801ac4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801ac6:	85 db                	test   %ebx,%ebx
  801ac8:	74 0a                	je     801ad4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801aca:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801acf:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ad2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801ad4:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801ad9:	8b 40 74             	mov    0x74(%eax),%eax
  801adc:	eb 14                	jmp    801af2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801ade:	85 f6                	test   %esi,%esi
  801ae0:	74 06                	je     801ae8 <ipc_recv+0x5f>
              *from_env_store = 0;
  801ae2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801ae8:	85 db                	test   %ebx,%ebx
  801aea:	74 06                	je     801af2 <ipc_recv+0x69>
              *perm_store = 0;
  801aec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    
  801af9:	00 00                	add    %al,(%eax)
  801afb:	00 00                	add    %al,(%eax)
  801afd:	00 00                	add    %al,(%eax)
	...

00801b00 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	05 00 00 00 30       	add    $0x30000000,%eax
  801b0b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	89 04 24             	mov    %eax,(%esp)
  801b1c:	e8 df ff ff ff       	call   801b00 <fd2num>
  801b21:	05 20 00 0d 00       	add    $0xd0020,%eax
  801b26:	c1 e0 0c             	shl    $0xc,%eax
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	57                   	push   %edi
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
  801b31:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801b34:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801b39:	a8 01                	test   $0x1,%al
  801b3b:	74 36                	je     801b73 <fd_alloc+0x48>
  801b3d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801b42:	a8 01                	test   $0x1,%al
  801b44:	74 2d                	je     801b73 <fd_alloc+0x48>
  801b46:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801b4b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801b50:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801b55:	89 c3                	mov    %eax,%ebx
  801b57:	89 c2                	mov    %eax,%edx
  801b59:	c1 ea 16             	shr    $0x16,%edx
  801b5c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801b5f:	f6 c2 01             	test   $0x1,%dl
  801b62:	74 14                	je     801b78 <fd_alloc+0x4d>
  801b64:	89 c2                	mov    %eax,%edx
  801b66:	c1 ea 0c             	shr    $0xc,%edx
  801b69:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801b6c:	f6 c2 01             	test   $0x1,%dl
  801b6f:	75 10                	jne    801b81 <fd_alloc+0x56>
  801b71:	eb 05                	jmp    801b78 <fd_alloc+0x4d>
  801b73:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801b78:	89 1f                	mov    %ebx,(%edi)
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801b7f:	eb 17                	jmp    801b98 <fd_alloc+0x6d>
  801b81:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801b86:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801b8b:	75 c8                	jne    801b55 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801b8d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b93:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5f                   	pop    %edi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	83 f8 1f             	cmp    $0x1f,%eax
  801ba6:	77 36                	ja     801bde <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ba8:	05 00 00 0d 00       	add    $0xd0000,%eax
  801bad:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801bb0:	89 c2                	mov    %eax,%edx
  801bb2:	c1 ea 16             	shr    $0x16,%edx
  801bb5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bbc:	f6 c2 01             	test   $0x1,%dl
  801bbf:	74 1d                	je     801bde <fd_lookup+0x41>
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	c1 ea 0c             	shr    $0xc,%edx
  801bc6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bcd:	f6 c2 01             	test   $0x1,%dl
  801bd0:	74 0c                	je     801bde <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd5:	89 02                	mov    %eax,(%edx)
  801bd7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801bdc:	eb 05                	jmp    801be3 <fd_lookup+0x46>
  801bde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801beb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf5:	89 04 24             	mov    %eax,(%esp)
  801bf8:	e8 a0 ff ff ff       	call   801b9d <fd_lookup>
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 0e                	js     801c0f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c07:	89 50 04             	mov    %edx,0x4(%eax)
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	56                   	push   %esi
  801c15:	53                   	push   %ebx
  801c16:	83 ec 10             	sub    $0x10,%esp
  801c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801c1f:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801c24:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c29:	be bc 31 80 00       	mov    $0x8031bc,%esi
		if (devtab[i]->dev_id == dev_id) {
  801c2e:	39 08                	cmp    %ecx,(%eax)
  801c30:	75 10                	jne    801c42 <dev_lookup+0x31>
  801c32:	eb 04                	jmp    801c38 <dev_lookup+0x27>
  801c34:	39 08                	cmp    %ecx,(%eax)
  801c36:	75 0a                	jne    801c42 <dev_lookup+0x31>
			*dev = devtab[i];
  801c38:	89 03                	mov    %eax,(%ebx)
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801c3f:	90                   	nop
  801c40:	eb 31                	jmp    801c73 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c42:	83 c2 01             	add    $0x1,%edx
  801c45:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	75 e8                	jne    801c34 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801c4c:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801c51:	8b 40 48             	mov    0x48(%eax),%eax
  801c54:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5c:	c7 04 24 40 31 80 00 	movl   $0x803140,(%esp)
  801c63:	e8 b5 e5 ff ff       	call   80021d <cprintf>
	*dev = 0;
  801c68:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 24             	sub    $0x24,%esp
  801c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8e:	89 04 24             	mov    %eax,(%esp)
  801c91:	e8 07 ff ff ff       	call   801b9d <fd_lookup>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	78 53                	js     801ced <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca4:	8b 00                	mov    (%eax),%eax
  801ca6:	89 04 24             	mov    %eax,(%esp)
  801ca9:	e8 63 ff ff ff       	call   801c11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	78 3b                	js     801ced <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801cb2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801cb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cba:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801cbe:	74 2d                	je     801ced <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801cc0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801cc3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801cca:	00 00 00 
	stat->st_isdir = 0;
  801ccd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cd4:	00 00 00 
	stat->st_dev = dev;
  801cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cda:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ce0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ce7:	89 14 24             	mov    %edx,(%esp)
  801cea:	ff 50 14             	call   *0x14(%eax)
}
  801ced:	83 c4 24             	add    $0x24,%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    

00801cf3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	53                   	push   %ebx
  801cf7:	83 ec 24             	sub    $0x24,%esp
  801cfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d04:	89 1c 24             	mov    %ebx,(%esp)
  801d07:	e8 91 fe ff ff       	call   801b9d <fd_lookup>
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 5f                	js     801d6f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1a:	8b 00                	mov    (%eax),%eax
  801d1c:	89 04 24             	mov    %eax,(%esp)
  801d1f:	e8 ed fe ff ff       	call   801c11 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d24:	85 c0                	test   %eax,%eax
  801d26:	78 47                	js     801d6f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d2b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801d2f:	75 23                	jne    801d54 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801d31:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801d36:	8b 40 48             	mov    0x48(%eax),%eax
  801d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d41:	c7 04 24 60 31 80 00 	movl   $0x803160,(%esp)
  801d48:	e8 d0 e4 ff ff       	call   80021d <cprintf>
  801d4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801d52:	eb 1b                	jmp    801d6f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d57:	8b 48 18             	mov    0x18(%eax),%ecx
  801d5a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d5f:	85 c9                	test   %ecx,%ecx
  801d61:	74 0c                	je     801d6f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801d63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6a:	89 14 24             	mov    %edx,(%esp)
  801d6d:	ff d1                	call   *%ecx
}
  801d6f:	83 c4 24             	add    $0x24,%esp
  801d72:	5b                   	pop    %ebx
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	53                   	push   %ebx
  801d79:	83 ec 24             	sub    $0x24,%esp
  801d7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d86:	89 1c 24             	mov    %ebx,(%esp)
  801d89:	e8 0f fe ff ff       	call   801b9d <fd_lookup>
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 66                	js     801df8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d9c:	8b 00                	mov    (%eax),%eax
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	e8 6b fe ff ff       	call   801c11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801da6:	85 c0                	test   %eax,%eax
  801da8:	78 4e                	js     801df8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801daa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dad:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801db1:	75 23                	jne    801dd6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801db3:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801db8:	8b 40 48             	mov    0x48(%eax),%eax
  801dbb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc3:	c7 04 24 81 31 80 00 	movl   $0x803181,(%esp)
  801dca:	e8 4e e4 ff ff       	call   80021d <cprintf>
  801dcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801dd4:	eb 22                	jmp    801df8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd9:	8b 48 0c             	mov    0xc(%eax),%ecx
  801ddc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801de1:	85 c9                	test   %ecx,%ecx
  801de3:	74 13                	je     801df8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801de5:	8b 45 10             	mov    0x10(%ebp),%eax
  801de8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801def:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df3:	89 14 24             	mov    %edx,(%esp)
  801df6:	ff d1                	call   *%ecx
}
  801df8:	83 c4 24             	add    $0x24,%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	53                   	push   %ebx
  801e02:	83 ec 24             	sub    $0x24,%esp
  801e05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0f:	89 1c 24             	mov    %ebx,(%esp)
  801e12:	e8 86 fd ff ff       	call   801b9d <fd_lookup>
  801e17:	85 c0                	test   %eax,%eax
  801e19:	78 6b                	js     801e86 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e25:	8b 00                	mov    (%eax),%eax
  801e27:	89 04 24             	mov    %eax,(%esp)
  801e2a:	e8 e2 fd ff ff       	call   801c11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 53                	js     801e86 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e33:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e36:	8b 42 08             	mov    0x8(%edx),%eax
  801e39:	83 e0 03             	and    $0x3,%eax
  801e3c:	83 f8 01             	cmp    $0x1,%eax
  801e3f:	75 23                	jne    801e64 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801e41:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801e46:	8b 40 48             	mov    0x48(%eax),%eax
  801e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e51:	c7 04 24 9e 31 80 00 	movl   $0x80319e,(%esp)
  801e58:	e8 c0 e3 ff ff       	call   80021d <cprintf>
  801e5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801e62:	eb 22                	jmp    801e86 <read+0x88>
	}
	if (!dev->dev_read)
  801e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e67:	8b 48 08             	mov    0x8(%eax),%ecx
  801e6a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e6f:	85 c9                	test   %ecx,%ecx
  801e71:	74 13                	je     801e86 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801e73:	8b 45 10             	mov    0x10(%ebp),%eax
  801e76:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e81:	89 14 24             	mov    %edx,(%esp)
  801e84:	ff d1                	call   *%ecx
}
  801e86:	83 c4 24             	add    $0x24,%esp
  801e89:	5b                   	pop    %ebx
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	57                   	push   %edi
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	83 ec 1c             	sub    $0x1c,%esp
  801e95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e98:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eaa:	85 f6                	test   %esi,%esi
  801eac:	74 29                	je     801ed7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801eae:	89 f0                	mov    %esi,%eax
  801eb0:	29 d0                	sub    %edx,%eax
  801eb2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb6:	03 55 0c             	add    0xc(%ebp),%edx
  801eb9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ebd:	89 3c 24             	mov    %edi,(%esp)
  801ec0:	e8 39 ff ff ff       	call   801dfe <read>
		if (m < 0)
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	78 0e                	js     801ed7 <readn+0x4b>
			return m;
		if (m == 0)
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	74 08                	je     801ed5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ecd:	01 c3                	add    %eax,%ebx
  801ecf:	89 da                	mov    %ebx,%edx
  801ed1:	39 f3                	cmp    %esi,%ebx
  801ed3:	72 d9                	jb     801eae <readn+0x22>
  801ed5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801ed7:	83 c4 1c             	add    $0x1c,%esp
  801eda:	5b                   	pop    %ebx
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 20             	sub    $0x20,%esp
  801ee7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801eea:	89 34 24             	mov    %esi,(%esp)
  801eed:	e8 0e fc ff ff       	call   801b00 <fd2num>
  801ef2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ef5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ef9:	89 04 24             	mov    %eax,(%esp)
  801efc:	e8 9c fc ff ff       	call   801b9d <fd_lookup>
  801f01:	89 c3                	mov    %eax,%ebx
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 05                	js     801f0c <fd_close+0x2d>
  801f07:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801f0a:	74 0c                	je     801f18 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801f0c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801f10:	19 c0                	sbb    %eax,%eax
  801f12:	f7 d0                	not    %eax
  801f14:	21 c3                	and    %eax,%ebx
  801f16:	eb 3d                	jmp    801f55 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1f:	8b 06                	mov    (%esi),%eax
  801f21:	89 04 24             	mov    %eax,(%esp)
  801f24:	e8 e8 fc ff ff       	call   801c11 <dev_lookup>
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 16                	js     801f45 <fd_close+0x66>
		if (dev->dev_close)
  801f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f32:	8b 40 10             	mov    0x10(%eax),%eax
  801f35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	74 07                	je     801f45 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801f3e:	89 34 24             	mov    %esi,(%esp)
  801f41:	ff d0                	call   *%eax
  801f43:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801f45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f50:	e8 49 f4 ff ff       	call   80139e <sys_page_unmap>
	return r;
}
  801f55:	89 d8                	mov    %ebx,%eax
  801f57:	83 c4 20             	add    $0x20,%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6e:	89 04 24             	mov    %eax,(%esp)
  801f71:	e8 27 fc ff ff       	call   801b9d <fd_lookup>
  801f76:	85 c0                	test   %eax,%eax
  801f78:	78 13                	js     801f8d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801f7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f81:	00 
  801f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 52 ff ff ff       	call   801edf <fd_close>
}
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    

00801f8f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	83 ec 18             	sub    $0x18,%esp
  801f95:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f98:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801f9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fa2:	00 
  801fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa6:	89 04 24             	mov    %eax,(%esp)
  801fa9:	e8 79 03 00 00       	call   802327 <open>
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 1b                	js     801fcf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbb:	89 1c 24             	mov    %ebx,(%esp)
  801fbe:	e8 b7 fc ff ff       	call   801c7a <fstat>
  801fc3:	89 c6                	mov    %eax,%esi
	close(fd);
  801fc5:	89 1c 24             	mov    %ebx,(%esp)
  801fc8:	e8 91 ff ff ff       	call   801f5e <close>
  801fcd:	89 f3                	mov    %esi,%ebx
	return r;
}
  801fcf:	89 d8                	mov    %ebx,%eax
  801fd1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fd4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fd7:	89 ec                	mov    %ebp,%esp
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	53                   	push   %ebx
  801fdf:	83 ec 14             	sub    $0x14,%esp
  801fe2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801fe7:	89 1c 24             	mov    %ebx,(%esp)
  801fea:	e8 6f ff ff ff       	call   801f5e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801fef:	83 c3 01             	add    $0x1,%ebx
  801ff2:	83 fb 20             	cmp    $0x20,%ebx
  801ff5:	75 f0                	jne    801fe7 <close_all+0xc>
		close(i);
}
  801ff7:	83 c4 14             	add    $0x14,%esp
  801ffa:	5b                   	pop    %ebx
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    

00801ffd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 58             	sub    $0x58,%esp
  802003:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802006:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802009:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80200c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80200f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802012:	89 44 24 04          	mov    %eax,0x4(%esp)
  802016:	8b 45 08             	mov    0x8(%ebp),%eax
  802019:	89 04 24             	mov    %eax,(%esp)
  80201c:	e8 7c fb ff ff       	call   801b9d <fd_lookup>
  802021:	89 c3                	mov    %eax,%ebx
  802023:	85 c0                	test   %eax,%eax
  802025:	0f 88 e0 00 00 00    	js     80210b <dup+0x10e>
		return r;
	close(newfdnum);
  80202b:	89 3c 24             	mov    %edi,(%esp)
  80202e:	e8 2b ff ff ff       	call   801f5e <close>

	newfd = INDEX2FD(newfdnum);
  802033:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802039:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80203c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80203f:	89 04 24             	mov    %eax,(%esp)
  802042:	e8 c9 fa ff ff       	call   801b10 <fd2data>
  802047:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802049:	89 34 24             	mov    %esi,(%esp)
  80204c:	e8 bf fa ff ff       	call   801b10 <fd2data>
  802051:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  802054:	89 da                	mov    %ebx,%edx
  802056:	89 d8                	mov    %ebx,%eax
  802058:	c1 e8 16             	shr    $0x16,%eax
  80205b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802062:	a8 01                	test   $0x1,%al
  802064:	74 43                	je     8020a9 <dup+0xac>
  802066:	c1 ea 0c             	shr    $0xc,%edx
  802069:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802070:	a8 01                	test   $0x1,%al
  802072:	74 35                	je     8020a9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802074:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80207b:	25 07 0e 00 00       	and    $0xe07,%eax
  802080:	89 44 24 10          	mov    %eax,0x10(%esp)
  802084:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802087:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80208b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802092:	00 
  802093:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802097:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209e:	e8 67 f3 ff ff       	call   80140a <sys_page_map>
  8020a3:	89 c3                	mov    %eax,%ebx
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	78 3f                	js     8020e8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ac:	89 c2                	mov    %eax,%edx
  8020ae:	c1 ea 0c             	shr    $0xc,%edx
  8020b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8020b8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8020be:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8020c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020cd:	00 
  8020ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d9:	e8 2c f3 ff ff       	call   80140a <sys_page_map>
  8020de:	89 c3                	mov    %eax,%ebx
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 04                	js     8020e8 <dup+0xeb>
  8020e4:	89 fb                	mov    %edi,%ebx
  8020e6:	eb 23                	jmp    80210b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8020e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f3:	e8 a6 f2 ff ff       	call   80139e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8020f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8020fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802106:	e8 93 f2 ff ff       	call   80139e <sys_page_unmap>
	return r;
}
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802110:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802113:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802116:	89 ec                	mov    %ebp,%esp
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    
	...

0080211c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 18             	sub    $0x18,%esp
  802122:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802125:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802128:	89 c3                	mov    %eax,%ebx
  80212a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80212c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  802133:	75 11                	jne    802146 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802135:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80213c:	e8 7f f8 ff ff       	call   8019c0 <ipc_find_env>
  802141:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802146:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80214d:	00 
  80214e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802155:	00 
  802156:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80215a:	a1 00 50 80 00       	mov    0x805000,%eax
  80215f:	89 04 24             	mov    %eax,(%esp)
  802162:	e8 a4 f8 ff ff       	call   801a0b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802167:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80216e:	00 
  80216f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802173:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217a:	e8 0a f9 ff ff       	call   801a89 <ipc_recv>
}
  80217f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802182:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802185:	89 ec                	mov    %ebp,%esp
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    

00802189 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80218f:	8b 45 08             	mov    0x8(%ebp),%eax
  802192:	8b 40 0c             	mov    0xc(%eax),%eax
  802195:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80219a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80219d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8021ac:	e8 6b ff ff ff       	call   80211c <fsipc>
}
  8021b1:	c9                   	leave  
  8021b2:	c3                   	ret    

008021b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8021bf:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8021c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8021c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8021ce:	e8 49 ff ff ff       	call   80211c <fsipc>
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    

008021d5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8021db:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8021e5:	e8 32 ff ff ff       	call   80211c <fsipc>
}
  8021ea:	c9                   	leave  
  8021eb:	c3                   	ret    

008021ec <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	53                   	push   %ebx
  8021f0:	83 ec 14             	sub    $0x14,%esp
  8021f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8021fc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802201:	ba 00 00 00 00       	mov    $0x0,%edx
  802206:	b8 05 00 00 00       	mov    $0x5,%eax
  80220b:	e8 0c ff ff ff       	call   80211c <fsipc>
  802210:	85 c0                	test   %eax,%eax
  802212:	78 2b                	js     80223f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802214:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80221b:	00 
  80221c:	89 1c 24             	mov    %ebx,(%esp)
  80221f:	e8 26 e9 ff ff       	call   800b4a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802224:	a1 80 60 80 00       	mov    0x806080,%eax
  802229:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80222f:	a1 84 60 80 00       	mov    0x806084,%eax
  802234:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80223a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80223f:	83 c4 14             	add    $0x14,%esp
  802242:	5b                   	pop    %ebx
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    

00802245 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 18             	sub    $0x18,%esp
  80224b:	8b 45 10             	mov    0x10(%ebp),%eax
  80224e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802253:	76 05                	jbe    80225a <devfile_write+0x15>
  802255:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  80225a:	8b 55 08             	mov    0x8(%ebp),%edx
  80225d:	8b 52 0c             	mov    0xc(%edx),%edx
  802260:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  802266:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  80226b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80226f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802272:	89 44 24 04          	mov    %eax,0x4(%esp)
  802276:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80227d:	e8 b3 ea ff ff       	call   800d35 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  802282:	ba 00 00 00 00       	mov    $0x0,%edx
  802287:	b8 04 00 00 00       	mov    $0x4,%eax
  80228c:	e8 8b fe ff ff       	call   80211c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802291:	c9                   	leave  
  802292:	c3                   	ret    

00802293 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	53                   	push   %ebx
  802297:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80229a:	8b 45 08             	mov    0x8(%ebp),%eax
  80229d:	8b 40 0c             	mov    0xc(%eax),%eax
  8022a0:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  8022a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8022a8:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  8022ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022b7:	e8 60 fe ff ff       	call   80211c <fsipc>
  8022bc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	78 17                	js     8022d9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  8022c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022c6:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8022cd:	00 
  8022ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d1:	89 04 24             	mov    %eax,(%esp)
  8022d4:	e8 5c ea ff ff       	call   800d35 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  8022d9:	89 d8                	mov    %ebx,%eax
  8022db:	83 c4 14             	add    $0x14,%esp
  8022de:	5b                   	pop    %ebx
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    

008022e1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8022e1:	55                   	push   %ebp
  8022e2:	89 e5                	mov    %esp,%ebp
  8022e4:	53                   	push   %ebx
  8022e5:	83 ec 14             	sub    $0x14,%esp
  8022e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8022eb:	89 1c 24             	mov    %ebx,(%esp)
  8022ee:	e8 0d e8 ff ff       	call   800b00 <strlen>
  8022f3:	89 c2                	mov    %eax,%edx
  8022f5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8022fa:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802300:	7f 1f                	jg     802321 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802302:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802306:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80230d:	e8 38 e8 ff ff       	call   800b4a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802312:	ba 00 00 00 00       	mov    $0x0,%edx
  802317:	b8 07 00 00 00       	mov    $0x7,%eax
  80231c:	e8 fb fd ff ff       	call   80211c <fsipc>
}
  802321:	83 c4 14             	add    $0x14,%esp
  802324:	5b                   	pop    %ebx
  802325:	5d                   	pop    %ebp
  802326:	c3                   	ret    

00802327 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802327:	55                   	push   %ebp
  802328:	89 e5                	mov    %esp,%ebp
  80232a:	83 ec 28             	sub    $0x28,%esp
  80232d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802330:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802333:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802336:	89 34 24             	mov    %esi,(%esp)
  802339:	e8 c2 e7 ff ff       	call   800b00 <strlen>
  80233e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802343:	3d 00 04 00 00       	cmp    $0x400,%eax
  802348:	7f 6d                	jg     8023b7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80234a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80234d:	89 04 24             	mov    %eax,(%esp)
  802350:	e8 d6 f7 ff ff       	call   801b2b <fd_alloc>
  802355:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  802357:	85 c0                	test   %eax,%eax
  802359:	78 5c                	js     8023b7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80235b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80235e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  802363:	89 34 24             	mov    %esi,(%esp)
  802366:	e8 95 e7 ff ff       	call   800b00 <strlen>
  80236b:	83 c0 01             	add    $0x1,%eax
  80236e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802372:	89 74 24 04          	mov    %esi,0x4(%esp)
  802376:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80237d:	e8 b3 e9 ff ff       	call   800d35 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  802382:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802385:	b8 01 00 00 00       	mov    $0x1,%eax
  80238a:	e8 8d fd ff ff       	call   80211c <fsipc>
  80238f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802391:	85 c0                	test   %eax,%eax
  802393:	79 15                	jns    8023aa <open+0x83>
             fd_close(fd,0);
  802395:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80239c:	00 
  80239d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a0:	89 04 24             	mov    %eax,(%esp)
  8023a3:	e8 37 fb ff ff       	call   801edf <fd_close>
             return r;
  8023a8:	eb 0d                	jmp    8023b7 <open+0x90>
        }
        return fd2num(fd);
  8023aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ad:	89 04 24             	mov    %eax,(%esp)
  8023b0:	e8 4b f7 ff ff       	call   801b00 <fd2num>
  8023b5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8023b7:	89 d8                	mov    %ebx,%eax
  8023b9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8023bc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8023bf:	89 ec                	mov    %ebp,%esp
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    
	...

008023d0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8023d6:	c7 44 24 04 c8 31 80 	movl   $0x8031c8,0x4(%esp)
  8023dd:	00 
  8023de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e1:	89 04 24             	mov    %eax,(%esp)
  8023e4:	e8 61 e7 ff ff       	call   800b4a <strcpy>
	return 0;
}
  8023e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ee:	c9                   	leave  
  8023ef:	c3                   	ret    

008023f0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8023f0:	55                   	push   %ebp
  8023f1:	89 e5                	mov    %esp,%ebp
  8023f3:	53                   	push   %ebx
  8023f4:	83 ec 14             	sub    $0x14,%esp
  8023f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8023fa:	89 1c 24             	mov    %ebx,(%esp)
  8023fd:	e8 9e 05 00 00       	call   8029a0 <pageref>
  802402:	89 c2                	mov    %eax,%edx
  802404:	b8 00 00 00 00       	mov    $0x0,%eax
  802409:	83 fa 01             	cmp    $0x1,%edx
  80240c:	75 0b                	jne    802419 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80240e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802411:	89 04 24             	mov    %eax,(%esp)
  802414:	e8 b9 02 00 00       	call   8026d2 <nsipc_close>
	else
		return 0;
}
  802419:	83 c4 14             	add    $0x14,%esp
  80241c:	5b                   	pop    %ebx
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    

0080241f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80241f:	55                   	push   %ebp
  802420:	89 e5                	mov    %esp,%ebp
  802422:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802425:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80242c:	00 
  80242d:	8b 45 10             	mov    0x10(%ebp),%eax
  802430:	89 44 24 08          	mov    %eax,0x8(%esp)
  802434:	8b 45 0c             	mov    0xc(%ebp),%eax
  802437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80243b:	8b 45 08             	mov    0x8(%ebp),%eax
  80243e:	8b 40 0c             	mov    0xc(%eax),%eax
  802441:	89 04 24             	mov    %eax,(%esp)
  802444:	e8 c5 02 00 00       	call   80270e <nsipc_send>
}
  802449:	c9                   	leave  
  80244a:	c3                   	ret    

0080244b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
  80244e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802451:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802458:	00 
  802459:	8b 45 10             	mov    0x10(%ebp),%eax
  80245c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802460:	8b 45 0c             	mov    0xc(%ebp),%eax
  802463:	89 44 24 04          	mov    %eax,0x4(%esp)
  802467:	8b 45 08             	mov    0x8(%ebp),%eax
  80246a:	8b 40 0c             	mov    0xc(%eax),%eax
  80246d:	89 04 24             	mov    %eax,(%esp)
  802470:	e8 0c 03 00 00       	call   802781 <nsipc_recv>
}
  802475:	c9                   	leave  
  802476:	c3                   	ret    

00802477 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
  80247a:	56                   	push   %esi
  80247b:	53                   	push   %ebx
  80247c:	83 ec 20             	sub    $0x20,%esp
  80247f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802484:	89 04 24             	mov    %eax,(%esp)
  802487:	e8 9f f6 ff ff       	call   801b2b <fd_alloc>
  80248c:	89 c3                	mov    %eax,%ebx
  80248e:	85 c0                	test   %eax,%eax
  802490:	78 21                	js     8024b3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802492:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802499:	00 
  80249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80249d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a8:	e8 cb ef ff ff       	call   801478 <sys_page_alloc>
  8024ad:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8024af:	85 c0                	test   %eax,%eax
  8024b1:	79 0a                	jns    8024bd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  8024b3:	89 34 24             	mov    %esi,(%esp)
  8024b6:	e8 17 02 00 00       	call   8026d2 <nsipc_close>
		return r;
  8024bb:	eb 28                	jmp    8024e5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8024bd:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8024c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8024c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8024d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8024d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024db:	89 04 24             	mov    %eax,(%esp)
  8024de:	e8 1d f6 ff ff       	call   801b00 <fd2num>
  8024e3:	89 c3                	mov    %eax,%ebx
}
  8024e5:	89 d8                	mov    %ebx,%eax
  8024e7:	83 c4 20             	add    $0x20,%esp
  8024ea:	5b                   	pop    %ebx
  8024eb:	5e                   	pop    %esi
  8024ec:	5d                   	pop    %ebp
  8024ed:	c3                   	ret    

008024ee <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
  8024f1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8024f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8024f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802502:	8b 45 08             	mov    0x8(%ebp),%eax
  802505:	89 04 24             	mov    %eax,(%esp)
  802508:	e8 79 01 00 00       	call   802686 <nsipc_socket>
  80250d:	85 c0                	test   %eax,%eax
  80250f:	78 05                	js     802516 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802511:	e8 61 ff ff ff       	call   802477 <alloc_sockfd>
}
  802516:	c9                   	leave  
  802517:	c3                   	ret    

00802518 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802518:	55                   	push   %ebp
  802519:	89 e5                	mov    %esp,%ebp
  80251b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80251e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802521:	89 54 24 04          	mov    %edx,0x4(%esp)
  802525:	89 04 24             	mov    %eax,(%esp)
  802528:	e8 70 f6 ff ff       	call   801b9d <fd_lookup>
  80252d:	85 c0                	test   %eax,%eax
  80252f:	78 15                	js     802546 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802531:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802534:	8b 0a                	mov    (%edx),%ecx
  802536:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80253b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802541:	75 03                	jne    802546 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802543:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802546:	c9                   	leave  
  802547:	c3                   	ret    

00802548 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802548:	55                   	push   %ebp
  802549:	89 e5                	mov    %esp,%ebp
  80254b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80254e:	8b 45 08             	mov    0x8(%ebp),%eax
  802551:	e8 c2 ff ff ff       	call   802518 <fd2sockid>
  802556:	85 c0                	test   %eax,%eax
  802558:	78 0f                	js     802569 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80255a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80255d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802561:	89 04 24             	mov    %eax,(%esp)
  802564:	e8 47 01 00 00       	call   8026b0 <nsipc_listen>
}
  802569:	c9                   	leave  
  80256a:	c3                   	ret    

0080256b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80256b:	55                   	push   %ebp
  80256c:	89 e5                	mov    %esp,%ebp
  80256e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802571:	8b 45 08             	mov    0x8(%ebp),%eax
  802574:	e8 9f ff ff ff       	call   802518 <fd2sockid>
  802579:	85 c0                	test   %eax,%eax
  80257b:	78 16                	js     802593 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80257d:	8b 55 10             	mov    0x10(%ebp),%edx
  802580:	89 54 24 08          	mov    %edx,0x8(%esp)
  802584:	8b 55 0c             	mov    0xc(%ebp),%edx
  802587:	89 54 24 04          	mov    %edx,0x4(%esp)
  80258b:	89 04 24             	mov    %eax,(%esp)
  80258e:	e8 6e 02 00 00       	call   802801 <nsipc_connect>
}
  802593:	c9                   	leave  
  802594:	c3                   	ret    

00802595 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802595:	55                   	push   %ebp
  802596:	89 e5                	mov    %esp,%ebp
  802598:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80259b:	8b 45 08             	mov    0x8(%ebp),%eax
  80259e:	e8 75 ff ff ff       	call   802518 <fd2sockid>
  8025a3:	85 c0                	test   %eax,%eax
  8025a5:	78 0f                	js     8025b6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8025a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025ae:	89 04 24             	mov    %eax,(%esp)
  8025b1:	e8 36 01 00 00       	call   8026ec <nsipc_shutdown>
}
  8025b6:	c9                   	leave  
  8025b7:	c3                   	ret    

008025b8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025be:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c1:	e8 52 ff ff ff       	call   802518 <fd2sockid>
  8025c6:	85 c0                	test   %eax,%eax
  8025c8:	78 16                	js     8025e0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8025ca:	8b 55 10             	mov    0x10(%ebp),%edx
  8025cd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025d8:	89 04 24             	mov    %eax,(%esp)
  8025db:	e8 60 02 00 00       	call   802840 <nsipc_bind>
}
  8025e0:	c9                   	leave  
  8025e1:	c3                   	ret    

008025e2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8025eb:	e8 28 ff ff ff       	call   802518 <fd2sockid>
  8025f0:	85 c0                	test   %eax,%eax
  8025f2:	78 1f                	js     802613 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8025f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8025f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  802602:	89 04 24             	mov    %eax,(%esp)
  802605:	e8 75 02 00 00       	call   80287f <nsipc_accept>
  80260a:	85 c0                	test   %eax,%eax
  80260c:	78 05                	js     802613 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80260e:	e8 64 fe ff ff       	call   802477 <alloc_sockfd>
}
  802613:	c9                   	leave  
  802614:	c3                   	ret    
	...

00802620 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	53                   	push   %ebx
  802624:	83 ec 14             	sub    $0x14,%esp
  802627:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802629:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802630:	75 11                	jne    802643 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802632:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802639:	e8 82 f3 ff ff       	call   8019c0 <ipc_find_env>
  80263e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802643:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80264a:	00 
  80264b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802652:	00 
  802653:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802657:	a1 04 50 80 00       	mov    0x805004,%eax
  80265c:	89 04 24             	mov    %eax,(%esp)
  80265f:	e8 a7 f3 ff ff       	call   801a0b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802664:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80266b:	00 
  80266c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802673:	00 
  802674:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80267b:	e8 09 f4 ff ff       	call   801a89 <ipc_recv>
}
  802680:	83 c4 14             	add    $0x14,%esp
  802683:	5b                   	pop    %ebx
  802684:	5d                   	pop    %ebp
  802685:	c3                   	ret    

00802686 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802686:	55                   	push   %ebp
  802687:	89 e5                	mov    %esp,%ebp
  802689:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80268c:	8b 45 08             	mov    0x8(%ebp),%eax
  80268f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802694:	8b 45 0c             	mov    0xc(%ebp),%eax
  802697:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80269c:	8b 45 10             	mov    0x10(%ebp),%eax
  80269f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8026a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8026a9:	e8 72 ff ff ff       	call   802620 <nsipc>
}
  8026ae:	c9                   	leave  
  8026af:	c3                   	ret    

008026b0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8026b0:	55                   	push   %ebp
  8026b1:	89 e5                	mov    %esp,%ebp
  8026b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8026b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8026be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026c1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8026c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8026cb:	e8 50 ff ff ff       	call   802620 <nsipc>
}
  8026d0:	c9                   	leave  
  8026d1:	c3                   	ret    

008026d2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8026d2:	55                   	push   %ebp
  8026d3:	89 e5                	mov    %esp,%ebp
  8026d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8026d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8026db:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8026e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8026e5:	e8 36 ff ff ff       	call   802620 <nsipc>
}
  8026ea:	c9                   	leave  
  8026eb:	c3                   	ret    

008026ec <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8026ec:	55                   	push   %ebp
  8026ed:	89 e5                	mov    %esp,%ebp
  8026ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8026f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8026fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026fd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802702:	b8 03 00 00 00       	mov    $0x3,%eax
  802707:	e8 14 ff ff ff       	call   802620 <nsipc>
}
  80270c:	c9                   	leave  
  80270d:	c3                   	ret    

0080270e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80270e:	55                   	push   %ebp
  80270f:	89 e5                	mov    %esp,%ebp
  802711:	53                   	push   %ebx
  802712:	83 ec 14             	sub    $0x14,%esp
  802715:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802718:	8b 45 08             	mov    0x8(%ebp),%eax
  80271b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802720:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802726:	7e 24                	jle    80274c <nsipc_send+0x3e>
  802728:	c7 44 24 0c d4 31 80 	movl   $0x8031d4,0xc(%esp)
  80272f:	00 
  802730:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  802737:	00 
  802738:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80273f:	00 
  802740:	c7 04 24 f5 31 80 00 	movl   $0x8031f5,(%esp)
  802747:	e8 88 01 00 00       	call   8028d4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80274c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802750:	8b 45 0c             	mov    0xc(%ebp),%eax
  802753:	89 44 24 04          	mov    %eax,0x4(%esp)
  802757:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80275e:	e8 d2 e5 ff ff       	call   800d35 <memmove>
	nsipcbuf.send.req_size = size;
  802763:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802769:	8b 45 14             	mov    0x14(%ebp),%eax
  80276c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802771:	b8 08 00 00 00       	mov    $0x8,%eax
  802776:	e8 a5 fe ff ff       	call   802620 <nsipc>
}
  80277b:	83 c4 14             	add    $0x14,%esp
  80277e:	5b                   	pop    %ebx
  80277f:	5d                   	pop    %ebp
  802780:	c3                   	ret    

00802781 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802781:	55                   	push   %ebp
  802782:	89 e5                	mov    %esp,%ebp
  802784:	56                   	push   %esi
  802785:	53                   	push   %ebx
  802786:	83 ec 10             	sub    $0x10,%esp
  802789:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80278c:	8b 45 08             	mov    0x8(%ebp),%eax
  80278f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802794:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80279a:	8b 45 14             	mov    0x14(%ebp),%eax
  80279d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8027a2:	b8 07 00 00 00       	mov    $0x7,%eax
  8027a7:	e8 74 fe ff ff       	call   802620 <nsipc>
  8027ac:	89 c3                	mov    %eax,%ebx
  8027ae:	85 c0                	test   %eax,%eax
  8027b0:	78 46                	js     8027f8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8027b2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8027b7:	7f 04                	jg     8027bd <nsipc_recv+0x3c>
  8027b9:	39 c6                	cmp    %eax,%esi
  8027bb:	7d 24                	jge    8027e1 <nsipc_recv+0x60>
  8027bd:	c7 44 24 0c 01 32 80 	movl   $0x803201,0xc(%esp)
  8027c4:	00 
  8027c5:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  8027cc:	00 
  8027cd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8027d4:	00 
  8027d5:	c7 04 24 f5 31 80 00 	movl   $0x8031f5,(%esp)
  8027dc:	e8 f3 00 00 00       	call   8028d4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8027e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027e5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8027ec:	00 
  8027ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027f0:	89 04 24             	mov    %eax,(%esp)
  8027f3:	e8 3d e5 ff ff       	call   800d35 <memmove>
	}

	return r;
}
  8027f8:	89 d8                	mov    %ebx,%eax
  8027fa:	83 c4 10             	add    $0x10,%esp
  8027fd:	5b                   	pop    %ebx
  8027fe:	5e                   	pop    %esi
  8027ff:	5d                   	pop    %ebp
  802800:	c3                   	ret    

00802801 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802801:	55                   	push   %ebp
  802802:	89 e5                	mov    %esp,%ebp
  802804:	53                   	push   %ebx
  802805:	83 ec 14             	sub    $0x14,%esp
  802808:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80280b:	8b 45 08             	mov    0x8(%ebp),%eax
  80280e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802813:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802817:	8b 45 0c             	mov    0xc(%ebp),%eax
  80281a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80281e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802825:	e8 0b e5 ff ff       	call   800d35 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80282a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802830:	b8 05 00 00 00       	mov    $0x5,%eax
  802835:	e8 e6 fd ff ff       	call   802620 <nsipc>
}
  80283a:	83 c4 14             	add    $0x14,%esp
  80283d:	5b                   	pop    %ebx
  80283e:	5d                   	pop    %ebp
  80283f:	c3                   	ret    

00802840 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802840:	55                   	push   %ebp
  802841:	89 e5                	mov    %esp,%ebp
  802843:	53                   	push   %ebx
  802844:	83 ec 14             	sub    $0x14,%esp
  802847:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80284a:	8b 45 08             	mov    0x8(%ebp),%eax
  80284d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802852:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802856:	8b 45 0c             	mov    0xc(%ebp),%eax
  802859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80285d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802864:	e8 cc e4 ff ff       	call   800d35 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802869:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80286f:	b8 02 00 00 00       	mov    $0x2,%eax
  802874:	e8 a7 fd ff ff       	call   802620 <nsipc>
}
  802879:	83 c4 14             	add    $0x14,%esp
  80287c:	5b                   	pop    %ebx
  80287d:	5d                   	pop    %ebp
  80287e:	c3                   	ret    

0080287f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80287f:	55                   	push   %ebp
  802880:	89 e5                	mov    %esp,%ebp
  802882:	83 ec 18             	sub    $0x18,%esp
  802885:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802888:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80288b:	8b 45 08             	mov    0x8(%ebp),%eax
  80288e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802893:	b8 01 00 00 00       	mov    $0x1,%eax
  802898:	e8 83 fd ff ff       	call   802620 <nsipc>
  80289d:	89 c3                	mov    %eax,%ebx
  80289f:	85 c0                	test   %eax,%eax
  8028a1:	78 25                	js     8028c8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8028a3:	be 10 70 80 00       	mov    $0x807010,%esi
  8028a8:	8b 06                	mov    (%esi),%eax
  8028aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028ae:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8028b5:	00 
  8028b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028b9:	89 04 24             	mov    %eax,(%esp)
  8028bc:	e8 74 e4 ff ff       	call   800d35 <memmove>
		*addrlen = ret->ret_addrlen;
  8028c1:	8b 16                	mov    (%esi),%edx
  8028c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8028c6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8028c8:	89 d8                	mov    %ebx,%eax
  8028ca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8028cd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8028d0:	89 ec                	mov    %ebp,%esp
  8028d2:	5d                   	pop    %ebp
  8028d3:	c3                   	ret    

008028d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8028d4:	55                   	push   %ebp
  8028d5:	89 e5                	mov    %esp,%ebp
  8028d7:	56                   	push   %esi
  8028d8:	53                   	push   %ebx
  8028d9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8028dc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8028df:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8028e5:	e8 7d ec ff ff       	call   801567 <sys_getenvid>
  8028ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8028f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8028f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8028f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802900:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  802907:	e8 11 d9 ff ff       	call   80021d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80290c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802910:	8b 45 10             	mov    0x10(%ebp),%eax
  802913:	89 04 24             	mov    %eax,(%esp)
  802916:	e8 a1 d8 ff ff       	call   8001bc <vcprintf>
	cprintf("\n");
  80291b:	c7 04 24 b8 31 80 00 	movl   $0x8031b8,(%esp)
  802922:	e8 f6 d8 ff ff       	call   80021d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802927:	cc                   	int3   
  802928:	eb fd                	jmp    802927 <_panic+0x53>
	...

0080292c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80292c:	55                   	push   %ebp
  80292d:	89 e5                	mov    %esp,%ebp
  80292f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802932:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802939:	75 30                	jne    80296b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80293b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802942:	00 
  802943:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80294a:	ee 
  80294b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802952:	e8 21 eb ff ff       	call   801478 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802957:	c7 44 24 04 78 29 80 	movl   $0x802978,0x4(%esp)
  80295e:	00 
  80295f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802966:	e8 ef e8 ff ff       	call   80125a <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80296b:	8b 45 08             	mov    0x8(%ebp),%eax
  80296e:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802973:	c9                   	leave  
  802974:	c3                   	ret    
  802975:	00 00                	add    %al,(%eax)
	...

00802978 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802978:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802979:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80297e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802980:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  802983:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  802987:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  80298b:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  80298e:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802990:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  802994:	83 c4 08             	add    $0x8,%esp
        popal
  802997:	61                   	popa   
        addl $0x4,%esp
  802998:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  80299b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  80299c:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80299d:	c3                   	ret    
	...

008029a0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029a0:	55                   	push   %ebp
  8029a1:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8029a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8029a6:	89 c2                	mov    %eax,%edx
  8029a8:	c1 ea 16             	shr    $0x16,%edx
  8029ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029b2:	f6 c2 01             	test   $0x1,%dl
  8029b5:	74 20                	je     8029d7 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8029b7:	c1 e8 0c             	shr    $0xc,%eax
  8029ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8029c1:	a8 01                	test   $0x1,%al
  8029c3:	74 12                	je     8029d7 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029c5:	c1 e8 0c             	shr    $0xc,%eax
  8029c8:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8029cd:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8029d2:	0f b7 c0             	movzwl %ax,%eax
  8029d5:	eb 05                	jmp    8029dc <pageref+0x3c>
  8029d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029dc:	5d                   	pop    %ebp
  8029dd:	c3                   	ret    
	...

008029e0 <__udivdi3>:
  8029e0:	55                   	push   %ebp
  8029e1:	89 e5                	mov    %esp,%ebp
  8029e3:	57                   	push   %edi
  8029e4:	56                   	push   %esi
  8029e5:	83 ec 10             	sub    $0x10,%esp
  8029e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8029eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8029ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8029f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029f4:	85 c0                	test   %eax,%eax
  8029f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8029f9:	75 35                	jne    802a30 <__udivdi3+0x50>
  8029fb:	39 fe                	cmp    %edi,%esi
  8029fd:	77 61                	ja     802a60 <__udivdi3+0x80>
  8029ff:	85 f6                	test   %esi,%esi
  802a01:	75 0b                	jne    802a0e <__udivdi3+0x2e>
  802a03:	b8 01 00 00 00       	mov    $0x1,%eax
  802a08:	31 d2                	xor    %edx,%edx
  802a0a:	f7 f6                	div    %esi
  802a0c:	89 c6                	mov    %eax,%esi
  802a0e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802a11:	31 d2                	xor    %edx,%edx
  802a13:	89 f8                	mov    %edi,%eax
  802a15:	f7 f6                	div    %esi
  802a17:	89 c7                	mov    %eax,%edi
  802a19:	89 c8                	mov    %ecx,%eax
  802a1b:	f7 f6                	div    %esi
  802a1d:	89 c1                	mov    %eax,%ecx
  802a1f:	89 fa                	mov    %edi,%edx
  802a21:	89 c8                	mov    %ecx,%eax
  802a23:	83 c4 10             	add    $0x10,%esp
  802a26:	5e                   	pop    %esi
  802a27:	5f                   	pop    %edi
  802a28:	5d                   	pop    %ebp
  802a29:	c3                   	ret    
  802a2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a30:	39 f8                	cmp    %edi,%eax
  802a32:	77 1c                	ja     802a50 <__udivdi3+0x70>
  802a34:	0f bd d0             	bsr    %eax,%edx
  802a37:	83 f2 1f             	xor    $0x1f,%edx
  802a3a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802a3d:	75 39                	jne    802a78 <__udivdi3+0x98>
  802a3f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802a42:	0f 86 a0 00 00 00    	jbe    802ae8 <__udivdi3+0x108>
  802a48:	39 f8                	cmp    %edi,%eax
  802a4a:	0f 82 98 00 00 00    	jb     802ae8 <__udivdi3+0x108>
  802a50:	31 ff                	xor    %edi,%edi
  802a52:	31 c9                	xor    %ecx,%ecx
  802a54:	89 c8                	mov    %ecx,%eax
  802a56:	89 fa                	mov    %edi,%edx
  802a58:	83 c4 10             	add    $0x10,%esp
  802a5b:	5e                   	pop    %esi
  802a5c:	5f                   	pop    %edi
  802a5d:	5d                   	pop    %ebp
  802a5e:	c3                   	ret    
  802a5f:	90                   	nop
  802a60:	89 d1                	mov    %edx,%ecx
  802a62:	89 fa                	mov    %edi,%edx
  802a64:	89 c8                	mov    %ecx,%eax
  802a66:	31 ff                	xor    %edi,%edi
  802a68:	f7 f6                	div    %esi
  802a6a:	89 c1                	mov    %eax,%ecx
  802a6c:	89 fa                	mov    %edi,%edx
  802a6e:	89 c8                	mov    %ecx,%eax
  802a70:	83 c4 10             	add    $0x10,%esp
  802a73:	5e                   	pop    %esi
  802a74:	5f                   	pop    %edi
  802a75:	5d                   	pop    %ebp
  802a76:	c3                   	ret    
  802a77:	90                   	nop
  802a78:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a7c:	89 f2                	mov    %esi,%edx
  802a7e:	d3 e0                	shl    %cl,%eax
  802a80:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a83:	b8 20 00 00 00       	mov    $0x20,%eax
  802a88:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802a8b:	89 c1                	mov    %eax,%ecx
  802a8d:	d3 ea                	shr    %cl,%edx
  802a8f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a93:	0b 55 ec             	or     -0x14(%ebp),%edx
  802a96:	d3 e6                	shl    %cl,%esi
  802a98:	89 c1                	mov    %eax,%ecx
  802a9a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802a9d:	89 fe                	mov    %edi,%esi
  802a9f:	d3 ee                	shr    %cl,%esi
  802aa1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802aa5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802aa8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802aab:	d3 e7                	shl    %cl,%edi
  802aad:	89 c1                	mov    %eax,%ecx
  802aaf:	d3 ea                	shr    %cl,%edx
  802ab1:	09 d7                	or     %edx,%edi
  802ab3:	89 f2                	mov    %esi,%edx
  802ab5:	89 f8                	mov    %edi,%eax
  802ab7:	f7 75 ec             	divl   -0x14(%ebp)
  802aba:	89 d6                	mov    %edx,%esi
  802abc:	89 c7                	mov    %eax,%edi
  802abe:	f7 65 e8             	mull   -0x18(%ebp)
  802ac1:	39 d6                	cmp    %edx,%esi
  802ac3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802ac6:	72 30                	jb     802af8 <__udivdi3+0x118>
  802ac8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802acb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802acf:	d3 e2                	shl    %cl,%edx
  802ad1:	39 c2                	cmp    %eax,%edx
  802ad3:	73 05                	jae    802ada <__udivdi3+0xfa>
  802ad5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802ad8:	74 1e                	je     802af8 <__udivdi3+0x118>
  802ada:	89 f9                	mov    %edi,%ecx
  802adc:	31 ff                	xor    %edi,%edi
  802ade:	e9 71 ff ff ff       	jmp    802a54 <__udivdi3+0x74>
  802ae3:	90                   	nop
  802ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ae8:	31 ff                	xor    %edi,%edi
  802aea:	b9 01 00 00 00       	mov    $0x1,%ecx
  802aef:	e9 60 ff ff ff       	jmp    802a54 <__udivdi3+0x74>
  802af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802af8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802afb:	31 ff                	xor    %edi,%edi
  802afd:	89 c8                	mov    %ecx,%eax
  802aff:	89 fa                	mov    %edi,%edx
  802b01:	83 c4 10             	add    $0x10,%esp
  802b04:	5e                   	pop    %esi
  802b05:	5f                   	pop    %edi
  802b06:	5d                   	pop    %ebp
  802b07:	c3                   	ret    
	...

00802b10 <__umoddi3>:
  802b10:	55                   	push   %ebp
  802b11:	89 e5                	mov    %esp,%ebp
  802b13:	57                   	push   %edi
  802b14:	56                   	push   %esi
  802b15:	83 ec 20             	sub    $0x20,%esp
  802b18:	8b 55 14             	mov    0x14(%ebp),%edx
  802b1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b1e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b24:	85 d2                	test   %edx,%edx
  802b26:	89 c8                	mov    %ecx,%eax
  802b28:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802b2b:	75 13                	jne    802b40 <__umoddi3+0x30>
  802b2d:	39 f7                	cmp    %esi,%edi
  802b2f:	76 3f                	jbe    802b70 <__umoddi3+0x60>
  802b31:	89 f2                	mov    %esi,%edx
  802b33:	f7 f7                	div    %edi
  802b35:	89 d0                	mov    %edx,%eax
  802b37:	31 d2                	xor    %edx,%edx
  802b39:	83 c4 20             	add    $0x20,%esp
  802b3c:	5e                   	pop    %esi
  802b3d:	5f                   	pop    %edi
  802b3e:	5d                   	pop    %ebp
  802b3f:	c3                   	ret    
  802b40:	39 f2                	cmp    %esi,%edx
  802b42:	77 4c                	ja     802b90 <__umoddi3+0x80>
  802b44:	0f bd ca             	bsr    %edx,%ecx
  802b47:	83 f1 1f             	xor    $0x1f,%ecx
  802b4a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802b4d:	75 51                	jne    802ba0 <__umoddi3+0x90>
  802b4f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802b52:	0f 87 e0 00 00 00    	ja     802c38 <__umoddi3+0x128>
  802b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b5b:	29 f8                	sub    %edi,%eax
  802b5d:	19 d6                	sbb    %edx,%esi
  802b5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b65:	89 f2                	mov    %esi,%edx
  802b67:	83 c4 20             	add    $0x20,%esp
  802b6a:	5e                   	pop    %esi
  802b6b:	5f                   	pop    %edi
  802b6c:	5d                   	pop    %ebp
  802b6d:	c3                   	ret    
  802b6e:	66 90                	xchg   %ax,%ax
  802b70:	85 ff                	test   %edi,%edi
  802b72:	75 0b                	jne    802b7f <__umoddi3+0x6f>
  802b74:	b8 01 00 00 00       	mov    $0x1,%eax
  802b79:	31 d2                	xor    %edx,%edx
  802b7b:	f7 f7                	div    %edi
  802b7d:	89 c7                	mov    %eax,%edi
  802b7f:	89 f0                	mov    %esi,%eax
  802b81:	31 d2                	xor    %edx,%edx
  802b83:	f7 f7                	div    %edi
  802b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b88:	f7 f7                	div    %edi
  802b8a:	eb a9                	jmp    802b35 <__umoddi3+0x25>
  802b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b90:	89 c8                	mov    %ecx,%eax
  802b92:	89 f2                	mov    %esi,%edx
  802b94:	83 c4 20             	add    $0x20,%esp
  802b97:	5e                   	pop    %esi
  802b98:	5f                   	pop    %edi
  802b99:	5d                   	pop    %ebp
  802b9a:	c3                   	ret    
  802b9b:	90                   	nop
  802b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ba0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802ba4:	d3 e2                	shl    %cl,%edx
  802ba6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802ba9:	ba 20 00 00 00       	mov    $0x20,%edx
  802bae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802bb1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802bb4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bb8:	89 fa                	mov    %edi,%edx
  802bba:	d3 ea                	shr    %cl,%edx
  802bbc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bc0:	0b 55 f4             	or     -0xc(%ebp),%edx
  802bc3:	d3 e7                	shl    %cl,%edi
  802bc5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bc9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802bcc:	89 f2                	mov    %esi,%edx
  802bce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802bd1:	89 c7                	mov    %eax,%edi
  802bd3:	d3 ea                	shr    %cl,%edx
  802bd5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bd9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802bdc:	89 c2                	mov    %eax,%edx
  802bde:	d3 e6                	shl    %cl,%esi
  802be0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802be4:	d3 ea                	shr    %cl,%edx
  802be6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bea:	09 d6                	or     %edx,%esi
  802bec:	89 f0                	mov    %esi,%eax
  802bee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802bf1:	d3 e7                	shl    %cl,%edi
  802bf3:	89 f2                	mov    %esi,%edx
  802bf5:	f7 75 f4             	divl   -0xc(%ebp)
  802bf8:	89 d6                	mov    %edx,%esi
  802bfa:	f7 65 e8             	mull   -0x18(%ebp)
  802bfd:	39 d6                	cmp    %edx,%esi
  802bff:	72 2b                	jb     802c2c <__umoddi3+0x11c>
  802c01:	39 c7                	cmp    %eax,%edi
  802c03:	72 23                	jb     802c28 <__umoddi3+0x118>
  802c05:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802c09:	29 c7                	sub    %eax,%edi
  802c0b:	19 d6                	sbb    %edx,%esi
  802c0d:	89 f0                	mov    %esi,%eax
  802c0f:	89 f2                	mov    %esi,%edx
  802c11:	d3 ef                	shr    %cl,%edi
  802c13:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802c17:	d3 e0                	shl    %cl,%eax
  802c19:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802c1d:	09 f8                	or     %edi,%eax
  802c1f:	d3 ea                	shr    %cl,%edx
  802c21:	83 c4 20             	add    $0x20,%esp
  802c24:	5e                   	pop    %esi
  802c25:	5f                   	pop    %edi
  802c26:	5d                   	pop    %ebp
  802c27:	c3                   	ret    
  802c28:	39 d6                	cmp    %edx,%esi
  802c2a:	75 d9                	jne    802c05 <__umoddi3+0xf5>
  802c2c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802c2f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802c32:	eb d1                	jmp    802c05 <__umoddi3+0xf5>
  802c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c38:	39 f2                	cmp    %esi,%edx
  802c3a:	0f 82 18 ff ff ff    	jb     802b58 <__umoddi3+0x48>
  802c40:	e9 1d ff ff ff       	jmp    802b62 <__umoddi3+0x52>
