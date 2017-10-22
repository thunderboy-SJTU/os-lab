
obj/user/pingpongs:     file format elf32-i386


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
  80003d:	e8 1e 14 00 00       	call   801460 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  80004f:	e8 61 13 00 00       	call   8013b5 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  800063:	e8 ad 01 00 00       	call   800215 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 45 13 00 00       	call   8013b5 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 ba 1c 80 00 	movl   $0x801cba,(%esp)
  80007f:	e8 91 01 00 00       	call   800215 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 b4 17 00 00       	call   80185b <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 17 18 00 00       	call   8018d9 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 30 80 00    	mov    0x803004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 d9 12 00 00       	call   8013b5 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 d0 1c 80 00 	movl   $0x801cd0,(%esp)
  8000fa:	e8 16 01 00 00       	call   800215 <cprintf>
		if (val == 10)
  8000ff:	a1 04 30 80 00       	mov    0x803004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 30 80 00       	mov    %eax,0x803004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 27 17 00 00       	call   80185b <ipc_send>
		if (val == 10)
  800134:	83 3d 04 30 80 00 0a 	cmpl   $0xa,0x803004
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
  80015e:	e8 52 12 00 00       	call   8013b5 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	89 c2                	mov    %eax,%edx
  80016a:	c1 e2 07             	shl    $0x7,%edx
  80016d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800174:	a3 08 30 80 00       	mov    %eax,0x803008
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
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 43 12 00 00       	call   8013f5 <sys_env_destroy>
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	c7 04 24 2f 02 80 00 	movl   $0x80022f,(%esp)
  8001f0:	e8 d7 01 00 00       	call   8003cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 6f 0d 00 00       	call   800f7c <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	8b 45 08             	mov    0x8(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	e8 87 ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	53                   	push   %ebx
  800233:	83 ec 14             	sub    $0x14,%esp
  800236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800239:	8b 03                	mov    (%ebx),%eax
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800242:	83 c0 01             	add    $0x1,%eax
  800245:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800247:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024c:	75 19                	jne    800267 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80024e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800255:	00 
  800256:	8d 43 08             	lea    0x8(%ebx),%eax
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	e8 1b 0d 00 00       	call   800f7c <sys_cputs>
		b->idx = 0;
  800261:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800267:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80026b:	83 c4 14             	add    $0x14,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    
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
  8002ef:	e8 3c 17 00 00       	call   801a30 <__udivdi3>
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
  800357:	e8 04 18 00 00       	call   801b60 <__umoddi3>
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	0f be 80 00 1d 80 00 	movsbl 0x801d00(%eax),%eax
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
  80044a:	ff 24 95 40 1e 80 00 	jmp    *0x801e40(,%edx,4)
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
  800502:	83 f8 08             	cmp    $0x8,%eax
  800505:	7f 0b                	jg     800512 <vprintfmt+0x146>
  800507:	8b 14 85 a0 1f 80 00 	mov    0x801fa0(,%eax,4),%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	75 26                	jne    800538 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800512:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800516:	c7 44 24 08 11 1d 80 	movl   $0x801d11,0x8(%esp)
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
  80053c:	c7 44 24 08 1a 1d 80 	movl   $0x801d1a,0x8(%esp)
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
  80057a:	be 1d 1d 80 00       	mov    $0x801d1d,%esi
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
  800824:	e8 07 12 00 00       	call   801a30 <__udivdi3>
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
  800870:	e8 eb 12 00 00       	call   801b60 <__umoddi3>
  800875:	89 74 24 04          	mov    %esi,0x4(%esp)
  800879:	0f be 80 00 1d 80 00 	movsbl 0x801d00(%eax),%eax
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
  800925:	c7 44 24 0c b8 1d 80 	movl   $0x801db8,0xc(%esp)
  80092c:	00 
  80092d:	c7 44 24 08 1a 1d 80 	movl   $0x801d1a,0x8(%esp)
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
  80095b:	c7 44 24 0c f0 1d 80 	movl   $0x801df0,0xc(%esp)
  800962:	00 
  800963:	c7 44 24 08 1a 1d 80 	movl   $0x801d1a,0x8(%esp)
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
  8009ef:	e8 6c 11 00 00       	call   801b60 <__umoddi3>
  8009f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f8:	0f be 80 00 1d 80 00 	movsbl 0x801d00(%eax),%eax
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
  800a31:	e8 2a 11 00 00       	call   801b60 <__umoddi3>
  800a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3a:	0f be 80 00 1d 80 00 	movsbl 0x801d00(%eax),%eax
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

00800fbb <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 28             	sub    $0x28,%esp
  800fc1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fc4:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd7:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	7e 28                	jle    80101d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff9:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801000:	00 
  801001:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801008:	00 
  801009:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801010:	00 
  801011:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801018:	e8 2f 09 00 00       	call   80194c <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80101d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801020:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801023:	89 ec                	mov    %ebp,%esp
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	89 1c 24             	mov    %ebx,(%esp)
  801030:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801034:	b9 00 00 00 00       	mov    $0x0,%ecx
  801039:	b8 0f 00 00 00       	mov    $0xf,%eax
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
  801041:	89 cb                	mov    %ecx,%ebx
  801043:	89 cf                	mov    %ecx,%edi
  801045:	51                   	push   %ecx
  801046:	52                   	push   %edx
  801047:	53                   	push   %ebx
  801048:	54                   	push   %esp
  801049:	55                   	push   %ebp
  80104a:	56                   	push   %esi
  80104b:	57                   	push   %edi
  80104c:	54                   	push   %esp
  80104d:	5d                   	pop    %ebp
  80104e:	8d 35 56 10 80 00    	lea    0x801056,%esi
  801054:	0f 34                	sysenter 
  801056:	5f                   	pop    %edi
  801057:	5e                   	pop    %esi
  801058:	5d                   	pop    %ebp
  801059:	5c                   	pop    %esp
  80105a:	5b                   	pop    %ebx
  80105b:	5a                   	pop    %edx
  80105c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80105d:	8b 1c 24             	mov    (%esp),%ebx
  801060:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801064:	89 ec                	mov    %ebp,%esp
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 28             	sub    $0x28,%esp
  80106e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801071:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801074:	b9 00 00 00 00       	mov    $0x0,%ecx
  801079:	b8 0d 00 00 00       	mov    $0xd,%eax
  80107e:	8b 55 08             	mov    0x8(%ebp),%edx
  801081:	89 cb                	mov    %ecx,%ebx
  801083:	89 cf                	mov    %ecx,%edi
  801085:	51                   	push   %ecx
  801086:	52                   	push   %edx
  801087:	53                   	push   %ebx
  801088:	54                   	push   %esp
  801089:	55                   	push   %ebp
  80108a:	56                   	push   %esi
  80108b:	57                   	push   %edi
  80108c:	54                   	push   %esp
  80108d:	5d                   	pop    %ebp
  80108e:	8d 35 96 10 80 00    	lea    0x801096,%esi
  801094:	0f 34                	sysenter 
  801096:	5f                   	pop    %edi
  801097:	5e                   	pop    %esi
  801098:	5d                   	pop    %ebp
  801099:	5c                   	pop    %esp
  80109a:	5b                   	pop    %ebx
  80109b:	5a                   	pop    %edx
  80109c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80109d:	85 c0                	test   %eax,%eax
  80109f:	7e 28                	jle    8010c9 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  8010b4:	00 
  8010b5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010bc:	00 
  8010bd:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  8010c4:	e8 83 08 00 00       	call   80194c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cf:	89 ec                	mov    %ebp,%esp
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	89 1c 24             	mov    %ebx,(%esp)
  8010dc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f1:	51                   	push   %ecx
  8010f2:	52                   	push   %edx
  8010f3:	53                   	push   %ebx
  8010f4:	54                   	push   %esp
  8010f5:	55                   	push   %ebp
  8010f6:	56                   	push   %esi
  8010f7:	57                   	push   %edi
  8010f8:	54                   	push   %esp
  8010f9:	5d                   	pop    %ebp
  8010fa:	8d 35 02 11 80 00    	lea    0x801102,%esi
  801100:	0f 34                	sysenter 
  801102:	5f                   	pop    %edi
  801103:	5e                   	pop    %esi
  801104:	5d                   	pop    %ebp
  801105:	5c                   	pop    %esp
  801106:	5b                   	pop    %ebx
  801107:	5a                   	pop    %edx
  801108:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801109:	8b 1c 24             	mov    (%esp),%ebx
  80110c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801110:	89 ec                	mov    %ebp,%esp
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 28             	sub    $0x28,%esp
  80111a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80111d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801120:	bb 00 00 00 00       	mov    $0x0,%ebx
  801125:	b8 0a 00 00 00       	mov    $0xa,%eax
  80112a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112d:	8b 55 08             	mov    0x8(%ebp),%edx
  801130:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	7e 28                	jle    801176 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801152:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801159:	00 
  80115a:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801161:	00 
  801162:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801169:	00 
  80116a:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801171:	e8 d6 07 00 00       	call   80194c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801176:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801179:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80117c:	89 ec                	mov    %ebp,%esp
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 28             	sub    $0x28,%esp
  801186:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801189:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80118c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801191:	b8 09 00 00 00       	mov    $0x9,%eax
  801196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801199:	8b 55 08             	mov    0x8(%ebp),%edx
  80119c:	89 df                	mov    %ebx,%edi
  80119e:	51                   	push   %ecx
  80119f:	52                   	push   %edx
  8011a0:	53                   	push   %ebx
  8011a1:	54                   	push   %esp
  8011a2:	55                   	push   %ebp
  8011a3:	56                   	push   %esi
  8011a4:	57                   	push   %edi
  8011a5:	54                   	push   %esp
  8011a6:	5d                   	pop    %ebp
  8011a7:	8d 35 af 11 80 00    	lea    0x8011af,%esi
  8011ad:	0f 34                	sysenter 
  8011af:	5f                   	pop    %edi
  8011b0:	5e                   	pop    %esi
  8011b1:	5d                   	pop    %ebp
  8011b2:	5c                   	pop    %esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5a                   	pop    %edx
  8011b5:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	7e 28                	jle    8011e2 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011be:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011c5:	00 
  8011c6:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  8011cd:	00 
  8011ce:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011d5:	00 
  8011d6:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  8011dd:	e8 6a 07 00 00       	call   80194c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011e2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e8:	89 ec                	mov    %ebp,%esp
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 28             	sub    $0x28,%esp
  8011f2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011f5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fd:	b8 07 00 00 00       	mov    $0x7,%eax
  801202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801205:	8b 55 08             	mov    0x8(%ebp),%edx
  801208:	89 df                	mov    %ebx,%edi
  80120a:	51                   	push   %ecx
  80120b:	52                   	push   %edx
  80120c:	53                   	push   %ebx
  80120d:	54                   	push   %esp
  80120e:	55                   	push   %ebp
  80120f:	56                   	push   %esi
  801210:	57                   	push   %edi
  801211:	54                   	push   %esp
  801212:	5d                   	pop    %ebp
  801213:	8d 35 1b 12 80 00    	lea    0x80121b,%esi
  801219:	0f 34                	sysenter 
  80121b:	5f                   	pop    %edi
  80121c:	5e                   	pop    %esi
  80121d:	5d                   	pop    %ebp
  80121e:	5c                   	pop    %esp
  80121f:	5b                   	pop    %ebx
  801220:	5a                   	pop    %edx
  801221:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801222:	85 c0                	test   %eax,%eax
  801224:	7e 28                	jle    80124e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801226:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801231:	00 
  801232:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801239:	00 
  80123a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801241:	00 
  801242:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801249:	e8 fe 06 00 00       	call   80194c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80124e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801251:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801254:	89 ec                	mov    %ebp,%esp
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 28             	sub    $0x28,%esp
  80125e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801261:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801264:	8b 7d 18             	mov    0x18(%ebp),%edi
  801267:	0b 7d 14             	or     0x14(%ebp),%edi
  80126a:	b8 06 00 00 00       	mov    $0x6,%eax
  80126f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801275:	8b 55 08             	mov    0x8(%ebp),%edx
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
  801292:	7e 28                	jle    8012bc <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801294:	89 44 24 10          	mov    %eax,0x10(%esp)
  801298:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80129f:	00 
  8012a0:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  8012a7:	00 
  8012a8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012af:	00 
  8012b0:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  8012b7:	e8 90 06 00 00       	call   80194c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8012bc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012bf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012c2:	89 ec                	mov    %ebp,%esp
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  8012d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8012d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8012dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e5:	51                   	push   %ecx
  8012e6:	52                   	push   %edx
  8012e7:	53                   	push   %ebx
  8012e8:	54                   	push   %esp
  8012e9:	55                   	push   %ebp
  8012ea:	56                   	push   %esi
  8012eb:	57                   	push   %edi
  8012ec:	54                   	push   %esp
  8012ed:	5d                   	pop    %ebp
  8012ee:	8d 35 f6 12 80 00    	lea    0x8012f6,%esi
  8012f4:	0f 34                	sysenter 
  8012f6:	5f                   	pop    %edi
  8012f7:	5e                   	pop    %esi
  8012f8:	5d                   	pop    %ebp
  8012f9:	5c                   	pop    %esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5a                   	pop    %edx
  8012fc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	7e 28                	jle    801329 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801301:	89 44 24 10          	mov    %eax,0x10(%esp)
  801305:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80130c:	00 
  80130d:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801314:	00 
  801315:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80131c:	00 
  80131d:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801324:	e8 23 06 00 00       	call   80194c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801329:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80132c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80132f:	89 ec                	mov    %ebp,%esp
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	89 1c 24             	mov    %ebx,(%esp)
  80133c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801340:	ba 00 00 00 00       	mov    $0x0,%edx
  801345:	b8 0b 00 00 00       	mov    $0xb,%eax
  80134a:	89 d1                	mov    %edx,%ecx
  80134c:	89 d3                	mov    %edx,%ebx
  80134e:	89 d7                	mov    %edx,%edi
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

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801368:	8b 1c 24             	mov    (%esp),%ebx
  80136b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80136f:	89 ec                	mov    %ebp,%esp
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	89 1c 24             	mov    %ebx,(%esp)
  80137c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801380:	bb 00 00 00 00       	mov    $0x0,%ebx
  801385:	b8 04 00 00 00       	mov    $0x4,%eax
  80138a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138d:	8b 55 08             	mov    0x8(%ebp),%edx
  801390:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8013aa:	8b 1c 24             	mov    (%esp),%ebx
  8013ad:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b1:	89 ec                	mov    %ebp,%esp
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	89 1c 24             	mov    %ebx,(%esp)
  8013be:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8013cc:	89 d1                	mov    %edx,%ecx
  8013ce:	89 d3                	mov    %edx,%ebx
  8013d0:	89 d7                	mov    %edx,%edi
  8013d2:	51                   	push   %ecx
  8013d3:	52                   	push   %edx
  8013d4:	53                   	push   %ebx
  8013d5:	54                   	push   %esp
  8013d6:	55                   	push   %ebp
  8013d7:	56                   	push   %esi
  8013d8:	57                   	push   %edi
  8013d9:	54                   	push   %esp
  8013da:	5d                   	pop    %ebp
  8013db:	8d 35 e3 13 80 00    	lea    0x8013e3,%esi
  8013e1:	0f 34                	sysenter 
  8013e3:	5f                   	pop    %edi
  8013e4:	5e                   	pop    %esi
  8013e5:	5d                   	pop    %ebp
  8013e6:	5c                   	pop    %esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5a                   	pop    %edx
  8013e9:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013ea:	8b 1c 24             	mov    (%esp),%ebx
  8013ed:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013f1:	89 ec                	mov    %ebp,%esp
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 28             	sub    $0x28,%esp
  8013fb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013fe:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801401:	b9 00 00 00 00       	mov    $0x0,%ecx
  801406:	b8 03 00 00 00       	mov    $0x3,%eax
  80140b:	8b 55 08             	mov    0x8(%ebp),%edx
  80140e:	89 cb                	mov    %ecx,%ebx
  801410:	89 cf                	mov    %ecx,%edi
  801412:	51                   	push   %ecx
  801413:	52                   	push   %edx
  801414:	53                   	push   %ebx
  801415:	54                   	push   %esp
  801416:	55                   	push   %ebp
  801417:	56                   	push   %esi
  801418:	57                   	push   %edi
  801419:	54                   	push   %esp
  80141a:	5d                   	pop    %ebp
  80141b:	8d 35 23 14 80 00    	lea    0x801423,%esi
  801421:	0f 34                	sysenter 
  801423:	5f                   	pop    %edi
  801424:	5e                   	pop    %esi
  801425:	5d                   	pop    %ebp
  801426:	5c                   	pop    %esp
  801427:	5b                   	pop    %ebx
  801428:	5a                   	pop    %edx
  801429:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80142a:	85 c0                	test   %eax,%eax
  80142c:	7e 28                	jle    801456 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80142e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801432:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801439:	00 
  80143a:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  801441:	00 
  801442:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801449:	00 
  80144a:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  801451:	e8 f6 04 00 00       	call   80194c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801456:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801459:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80145c:	89 ec                	mov    %ebp,%esp
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801466:	c7 44 24 08 ef 1f 80 	movl   $0x801fef,0x8(%esp)
  80146d:	00 
  80146e:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801475:	00 
  801476:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80147d:	e8 ca 04 00 00       	call   80194c <_panic>

00801482 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	57                   	push   %edi
  801486:	56                   	push   %esi
  801487:	53                   	push   %ebx
  801488:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80148b:	c7 04 24 d7 16 80 00 	movl   $0x8016d7,(%esp)
  801492:	e8 25 05 00 00       	call   8019bc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801497:	ba 08 00 00 00       	mov    $0x8,%edx
  80149c:	89 d0                	mov    %edx,%eax
  80149e:	cd 30                	int    $0x30
  8014a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	79 20                	jns    8014c7 <fork+0x45>
		panic("sys_exofork: %e", envid);
  8014a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ab:	c7 44 24 08 10 20 80 	movl   $0x802010,0x8(%esp)
  8014b2:	00 
  8014b3:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8014ba:	00 
  8014bb:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8014c2:	e8 85 04 00 00       	call   80194c <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8014c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8014cc:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8014d1:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8014d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014da:	75 20                	jne    8014fc <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8014dc:	e8 d4 fe ff ff       	call   8013b5 <sys_getenvid>
  8014e1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014e6:	89 c2                	mov    %eax,%edx
  8014e8:	c1 e2 07             	shl    $0x7,%edx
  8014eb:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8014f2:	a3 08 30 80 00       	mov    %eax,0x803008
		return 0;
  8014f7:	e9 d0 01 00 00       	jmp    8016cc <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	c1 e8 16             	shr    $0x16,%eax
  801501:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801504:	a8 01                	test   $0x1,%al
  801506:	0f 84 0d 01 00 00    	je     801619 <fork+0x197>
  80150c:	89 d8                	mov    %ebx,%eax
  80150e:	c1 e8 0c             	shr    $0xc,%eax
  801511:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801514:	f6 c2 01             	test   $0x1,%dl
  801517:	0f 84 fc 00 00 00    	je     801619 <fork+0x197>
  80151d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801520:	f6 c2 04             	test   $0x4,%dl
  801523:	0f 84 f0 00 00 00    	je     801619 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  801529:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	c1 ea 0c             	shr    $0xc,%edx
  801531:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801534:	f6 c2 01             	test   $0x1,%dl
  801537:	0f 84 dc 00 00 00    	je     801619 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  80153d:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801543:	0f 84 8d 00 00 00    	je     8015d6 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  801549:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80154c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801553:	00 
  801554:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801558:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80155b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80155f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801563:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156a:	e8 e9 fc ff ff       	call   801258 <sys_page_map>
               if(r<0)
  80156f:	85 c0                	test   %eax,%eax
  801571:	79 1c                	jns    80158f <fork+0x10d>
                 panic("map failed");
  801573:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  80157a:	00 
  80157b:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801582:	00 
  801583:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  80158a:	e8 bd 03 00 00       	call   80194c <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  80158f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801596:	00 
  801597:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80159a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80159e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a5:	00 
  8015a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b1:	e8 a2 fc ff ff       	call   801258 <sys_page_map>
               if(r<0)
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	79 5f                	jns    801619 <fork+0x197>
                 panic("map failed");
  8015ba:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  8015c1:	00 
  8015c2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8015c9:	00 
  8015ca:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8015d1:	e8 76 03 00 00       	call   80194c <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  8015d6:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8015dd:	00 
  8015de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f4:	e8 5f fc ff ff       	call   801258 <sys_page_map>
               if(r<0)
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	79 1c                	jns    801619 <fork+0x197>
                 panic("map failed");
  8015fd:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  801604:	00 
  801605:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80160c:	00 
  80160d:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801614:	e8 33 03 00 00       	call   80194c <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801619:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80161f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801625:	0f 85 d1 fe ff ff    	jne    8014fc <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80162b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801632:	00 
  801633:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80163a:	ee 
  80163b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163e:	89 04 24             	mov    %eax,(%esp)
  801641:	e8 80 fc ff ff       	call   8012c6 <sys_page_alloc>
        if(r < 0)
  801646:	85 c0                	test   %eax,%eax
  801648:	79 1c                	jns    801666 <fork+0x1e4>
            panic("alloc failed");
  80164a:	c7 44 24 08 2b 20 80 	movl   $0x80202b,0x8(%esp)
  801651:	00 
  801652:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801659:	00 
  80165a:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801661:	e8 e6 02 00 00       	call   80194c <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801666:	c7 44 24 04 08 1a 80 	movl   $0x801a08,0x4(%esp)
  80166d:	00 
  80166e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801671:	89 14 24             	mov    %edx,(%esp)
  801674:	e8 9b fa ff ff       	call   801114 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801679:	85 c0                	test   %eax,%eax
  80167b:	79 1c                	jns    801699 <fork+0x217>
            panic("set pgfault upcall failed");
  80167d:	c7 44 24 08 38 20 80 	movl   $0x802038,0x8(%esp)
  801684:	00 
  801685:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80168c:	00 
  80168d:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801694:	e8 b3 02 00 00       	call   80194c <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801699:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016a0:	00 
  8016a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a4:	89 04 24             	mov    %eax,(%esp)
  8016a7:	e8 d4 fa ff ff       	call   801180 <sys_env_set_status>
        if(r < 0)
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	79 1c                	jns    8016cc <fork+0x24a>
            panic("set status failed");
  8016b0:	c7 44 24 08 52 20 80 	movl   $0x802052,0x8(%esp)
  8016b7:	00 
  8016b8:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8016bf:	00 
  8016c0:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8016c7:	e8 80 02 00 00       	call   80194c <_panic>
        return envid;
	//panic("fork not implemented");
}
  8016cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016cf:	83 c4 3c             	add    $0x3c,%esp
  8016d2:	5b                   	pop    %ebx
  8016d3:	5e                   	pop    %esi
  8016d4:	5f                   	pop    %edi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	83 ec 24             	sub    $0x24,%esp
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8016e1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  8016e3:	89 da                	mov    %ebx,%edx
  8016e5:	c1 ea 0c             	shr    $0xc,%edx
  8016e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8016ef:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8016f3:	74 08                	je     8016fd <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  8016f5:	f7 c2 05 08 00 00    	test   $0x805,%edx
  8016fb:	75 1c                	jne    801719 <pgfault+0x42>
           panic("pgfault error");
  8016fd:	c7 44 24 08 64 20 80 	movl   $0x802064,0x8(%esp)
  801704:	00 
  801705:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80170c:	00 
  80170d:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801714:	e8 33 02 00 00       	call   80194c <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801719:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801720:	00 
  801721:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801728:	00 
  801729:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801730:	e8 91 fb ff ff       	call   8012c6 <sys_page_alloc>
  801735:	85 c0                	test   %eax,%eax
  801737:	79 20                	jns    801759 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  801739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80173d:	c7 44 24 08 72 20 80 	movl   $0x802072,0x8(%esp)
  801744:	00 
  801745:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80174c:	00 
  80174d:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  801754:	e8 f3 01 00 00       	call   80194c <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  801759:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80175f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801766:	00 
  801767:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80176b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801772:	e8 be f5 ff ff       	call   800d35 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801777:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80177e:	00 
  80177f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801783:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178a:	00 
  80178b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801792:	00 
  801793:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179a:	e8 b9 fa ff ff       	call   801258 <sys_page_map>
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	79 20                	jns    8017c3 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  8017a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a7:	c7 44 24 08 85 20 80 	movl   $0x802085,0x8(%esp)
  8017ae:	00 
  8017af:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8017b6:	00 
  8017b7:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8017be:	e8 89 01 00 00       	call   80194c <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8017c3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8017ca:	00 
  8017cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d2:	e8 15 fa ff ff       	call   8011ec <sys_page_unmap>
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	79 20                	jns    8017fb <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  8017db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017df:	c7 44 24 08 96 20 80 	movl   $0x802096,0x8(%esp)
  8017e6:	00 
  8017e7:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8017ee:	00 
  8017ef:	c7 04 24 05 20 80 00 	movl   $0x802005,(%esp)
  8017f6:	e8 51 01 00 00       	call   80194c <_panic>
	//panic("pgfault not implemented");
}
  8017fb:	83 c4 24             	add    $0x24,%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    
	...

00801810 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801816:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80181c:	b8 01 00 00 00       	mov    $0x1,%eax
  801821:	39 ca                	cmp    %ecx,%edx
  801823:	75 04                	jne    801829 <ipc_find_env+0x19>
  801825:	b0 00                	mov    $0x0,%al
  801827:	eb 12                	jmp    80183b <ipc_find_env+0x2b>
  801829:	89 c2                	mov    %eax,%edx
  80182b:	c1 e2 07             	shl    $0x7,%edx
  80182e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801835:	8b 12                	mov    (%edx),%edx
  801837:	39 ca                	cmp    %ecx,%edx
  801839:	75 10                	jne    80184b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80183b:	89 c2                	mov    %eax,%edx
  80183d:	c1 e2 07             	shl    $0x7,%edx
  801840:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801847:	8b 00                	mov    (%eax),%eax
  801849:	eb 0e                	jmp    801859 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80184b:	83 c0 01             	add    $0x1,%eax
  80184e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801853:	75 d4                	jne    801829 <ipc_find_env+0x19>
  801855:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	57                   	push   %edi
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	83 ec 1c             	sub    $0x1c,%esp
  801864:	8b 75 08             	mov    0x8(%ebp),%esi
  801867:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80186a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80186d:	85 db                	test   %ebx,%ebx
  80186f:	74 19                	je     80188a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801871:	8b 45 14             	mov    0x14(%ebp),%eax
  801874:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801878:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80187c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801880:	89 34 24             	mov    %esi,(%esp)
  801883:	e8 4b f8 ff ff       	call   8010d3 <sys_ipc_try_send>
  801888:	eb 1b                	jmp    8018a5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80188a:	8b 45 14             	mov    0x14(%ebp),%eax
  80188d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801891:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801898:	ee 
  801899:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80189d:	89 34 24             	mov    %esi,(%esp)
  8018a0:	e8 2e f8 ff ff       	call   8010d3 <sys_ipc_try_send>
           if(ret == 0)
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	74 28                	je     8018d1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8018a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018ac:	74 1c                	je     8018ca <ipc_send+0x6f>
              panic("ipc send error");
  8018ae:	c7 44 24 08 a9 20 80 	movl   $0x8020a9,0x8(%esp)
  8018b5:	00 
  8018b6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8018bd:	00 
  8018be:	c7 04 24 b8 20 80 00 	movl   $0x8020b8,(%esp)
  8018c5:	e8 82 00 00 00       	call   80194c <_panic>
           sys_yield();
  8018ca:	e8 64 fa ff ff       	call   801333 <sys_yield>
        }
  8018cf:	eb 9c                	jmp    80186d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8018d1:	83 c4 1c             	add    $0x1c,%esp
  8018d4:	5b                   	pop    %ebx
  8018d5:	5e                   	pop    %esi
  8018d6:	5f                   	pop    %edi
  8018d7:	5d                   	pop    %ebp
  8018d8:	c3                   	ret    

008018d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
  8018de:	83 ec 10             	sub    $0x10,%esp
  8018e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8018e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	75 0e                	jne    8018fc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8018ee:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8018f5:	e8 6e f7 ff ff       	call   801068 <sys_ipc_recv>
  8018fa:	eb 08                	jmp    801904 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	e8 64 f7 ff ff       	call   801068 <sys_ipc_recv>
        if(ret == 0){
  801904:	85 c0                	test   %eax,%eax
  801906:	75 26                	jne    80192e <ipc_recv+0x55>
           if(from_env_store)
  801908:	85 f6                	test   %esi,%esi
  80190a:	74 0a                	je     801916 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80190c:	a1 08 30 80 00       	mov    0x803008,%eax
  801911:	8b 40 78             	mov    0x78(%eax),%eax
  801914:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801916:	85 db                	test   %ebx,%ebx
  801918:	74 0a                	je     801924 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80191a:	a1 08 30 80 00       	mov    0x803008,%eax
  80191f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801922:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801924:	a1 08 30 80 00       	mov    0x803008,%eax
  801929:	8b 40 74             	mov    0x74(%eax),%eax
  80192c:	eb 14                	jmp    801942 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80192e:	85 f6                	test   %esi,%esi
  801930:	74 06                	je     801938 <ipc_recv+0x5f>
              *from_env_store = 0;
  801932:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801938:	85 db                	test   %ebx,%ebx
  80193a:	74 06                	je     801942 <ipc_recv+0x69>
              *perm_store = 0;
  80193c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	5b                   	pop    %ebx
  801946:	5e                   	pop    %esi
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    
  801949:	00 00                	add    %al,(%eax)
	...

0080194c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801954:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  801957:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80195c:	85 c0                	test   %eax,%eax
  80195e:	74 10                	je     801970 <_panic+0x24>
		cprintf("%s: ", argv0);
  801960:	89 44 24 04          	mov    %eax,0x4(%esp)
  801964:	c7 04 24 c2 20 80 00 	movl   $0x8020c2,(%esp)
  80196b:	e8 a5 e8 ff ff       	call   800215 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801970:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801976:	e8 3a fa ff ff       	call   8013b5 <sys_getenvid>
  80197b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80197e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801982:	8b 55 08             	mov    0x8(%ebp),%edx
  801985:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801989:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80198d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801991:	c7 04 24 c8 20 80 00 	movl   $0x8020c8,(%esp)
  801998:	e8 78 e8 ff ff       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80199d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8019a4:	89 04 24             	mov    %eax,(%esp)
  8019a7:	e8 08 e8 ff ff       	call   8001b4 <vcprintf>
	cprintf("\n");
  8019ac:	c7 04 24 b8 1c 80 00 	movl   $0x801cb8,(%esp)
  8019b3:	e8 5d e8 ff ff       	call   800215 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019b8:	cc                   	int3   
  8019b9:	eb fd                	jmp    8019b8 <_panic+0x6c>
	...

008019bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8019c2:	83 3d 10 30 80 00 00 	cmpl   $0x0,0x803010
  8019c9:	75 30                	jne    8019fb <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8019cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019d2:	00 
  8019d3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8019da:	ee 
  8019db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e2:	e8 df f8 ff ff       	call   8012c6 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8019e7:	c7 44 24 04 08 1a 80 	movl   $0x801a08,0x4(%esp)
  8019ee:	00 
  8019ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f6:	e8 19 f7 ff ff       	call   801114 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	a3 10 30 80 00       	mov    %eax,0x803010
}
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    
  801a05:	00 00                	add    %al,(%eax)
	...

00801a08 <_pgfault_upcall>:
  801a08:	54                   	push   %esp
  801a09:	a1 10 30 80 00       	mov    0x803010,%eax
  801a0e:	ff d0                	call   *%eax
  801a10:	83 c4 04             	add    $0x4,%esp
  801a13:	8b 44 24 28          	mov    0x28(%esp),%eax
  801a17:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801a1b:	83 e9 04             	sub    $0x4,%ecx
  801a1e:	89 01                	mov    %eax,(%ecx)
  801a20:	89 4c 24 30          	mov    %ecx,0x30(%esp)
  801a24:	83 c4 08             	add    $0x8,%esp
  801a27:	61                   	popa   
  801a28:	83 c4 04             	add    $0x4,%esp
  801a2b:	9d                   	popf   
  801a2c:	5c                   	pop    %esp
  801a2d:	c3                   	ret    
	...

00801a30 <__udivdi3>:
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	83 ec 10             	sub    $0x10,%esp
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a3e:	8b 75 10             	mov    0x10(%ebp),%esi
  801a41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a44:	85 c0                	test   %eax,%eax
  801a46:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801a49:	75 35                	jne    801a80 <__udivdi3+0x50>
  801a4b:	39 fe                	cmp    %edi,%esi
  801a4d:	77 61                	ja     801ab0 <__udivdi3+0x80>
  801a4f:	85 f6                	test   %esi,%esi
  801a51:	75 0b                	jne    801a5e <__udivdi3+0x2e>
  801a53:	b8 01 00 00 00       	mov    $0x1,%eax
  801a58:	31 d2                	xor    %edx,%edx
  801a5a:	f7 f6                	div    %esi
  801a5c:	89 c6                	mov    %eax,%esi
  801a5e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801a61:	31 d2                	xor    %edx,%edx
  801a63:	89 f8                	mov    %edi,%eax
  801a65:	f7 f6                	div    %esi
  801a67:	89 c7                	mov    %eax,%edi
  801a69:	89 c8                	mov    %ecx,%eax
  801a6b:	f7 f6                	div    %esi
  801a6d:	89 c1                	mov    %eax,%ecx
  801a6f:	89 fa                	mov    %edi,%edx
  801a71:	89 c8                	mov    %ecx,%eax
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	5e                   	pop    %esi
  801a77:	5f                   	pop    %edi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    
  801a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a80:	39 f8                	cmp    %edi,%eax
  801a82:	77 1c                	ja     801aa0 <__udivdi3+0x70>
  801a84:	0f bd d0             	bsr    %eax,%edx
  801a87:	83 f2 1f             	xor    $0x1f,%edx
  801a8a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801a8d:	75 39                	jne    801ac8 <__udivdi3+0x98>
  801a8f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801a92:	0f 86 a0 00 00 00    	jbe    801b38 <__udivdi3+0x108>
  801a98:	39 f8                	cmp    %edi,%eax
  801a9a:	0f 82 98 00 00 00    	jb     801b38 <__udivdi3+0x108>
  801aa0:	31 ff                	xor    %edi,%edi
  801aa2:	31 c9                	xor    %ecx,%ecx
  801aa4:	89 c8                	mov    %ecx,%eax
  801aa6:	89 fa                	mov    %edi,%edx
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	5e                   	pop    %esi
  801aac:	5f                   	pop    %edi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    
  801aaf:	90                   	nop
  801ab0:	89 d1                	mov    %edx,%ecx
  801ab2:	89 fa                	mov    %edi,%edx
  801ab4:	89 c8                	mov    %ecx,%eax
  801ab6:	31 ff                	xor    %edi,%edi
  801ab8:	f7 f6                	div    %esi
  801aba:	89 c1                	mov    %eax,%ecx
  801abc:	89 fa                	mov    %edi,%edx
  801abe:	89 c8                	mov    %ecx,%eax
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	5e                   	pop    %esi
  801ac4:	5f                   	pop    %edi
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    
  801ac7:	90                   	nop
  801ac8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801acc:	89 f2                	mov    %esi,%edx
  801ace:	d3 e0                	shl    %cl,%eax
  801ad0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ad3:	b8 20 00 00 00       	mov    $0x20,%eax
  801ad8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801adb:	89 c1                	mov    %eax,%ecx
  801add:	d3 ea                	shr    %cl,%edx
  801adf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801ae3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801ae6:	d3 e6                	shl    %cl,%esi
  801ae8:	89 c1                	mov    %eax,%ecx
  801aea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801aed:	89 fe                	mov    %edi,%esi
  801aef:	d3 ee                	shr    %cl,%esi
  801af1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801af5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801af8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801afb:	d3 e7                	shl    %cl,%edi
  801afd:	89 c1                	mov    %eax,%ecx
  801aff:	d3 ea                	shr    %cl,%edx
  801b01:	09 d7                	or     %edx,%edi
  801b03:	89 f2                	mov    %esi,%edx
  801b05:	89 f8                	mov    %edi,%eax
  801b07:	f7 75 ec             	divl   -0x14(%ebp)
  801b0a:	89 d6                	mov    %edx,%esi
  801b0c:	89 c7                	mov    %eax,%edi
  801b0e:	f7 65 e8             	mull   -0x18(%ebp)
  801b11:	39 d6                	cmp    %edx,%esi
  801b13:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b16:	72 30                	jb     801b48 <__udivdi3+0x118>
  801b18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b1b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b1f:	d3 e2                	shl    %cl,%edx
  801b21:	39 c2                	cmp    %eax,%edx
  801b23:	73 05                	jae    801b2a <__udivdi3+0xfa>
  801b25:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801b28:	74 1e                	je     801b48 <__udivdi3+0x118>
  801b2a:	89 f9                	mov    %edi,%ecx
  801b2c:	31 ff                	xor    %edi,%edi
  801b2e:	e9 71 ff ff ff       	jmp    801aa4 <__udivdi3+0x74>
  801b33:	90                   	nop
  801b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b38:	31 ff                	xor    %edi,%edi
  801b3a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801b3f:	e9 60 ff ff ff       	jmp    801aa4 <__udivdi3+0x74>
  801b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b48:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801b4b:	31 ff                	xor    %edi,%edi
  801b4d:	89 c8                	mov    %ecx,%eax
  801b4f:	89 fa                	mov    %edi,%edx
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
	...

00801b60 <__umoddi3>:
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	83 ec 20             	sub    $0x20,%esp
  801b68:	8b 55 14             	mov    0x14(%ebp),%edx
  801b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b71:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b74:	85 d2                	test   %edx,%edx
  801b76:	89 c8                	mov    %ecx,%eax
  801b78:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b7b:	75 13                	jne    801b90 <__umoddi3+0x30>
  801b7d:	39 f7                	cmp    %esi,%edi
  801b7f:	76 3f                	jbe    801bc0 <__umoddi3+0x60>
  801b81:	89 f2                	mov    %esi,%edx
  801b83:	f7 f7                	div    %edi
  801b85:	89 d0                	mov    %edx,%eax
  801b87:	31 d2                	xor    %edx,%edx
  801b89:	83 c4 20             	add    $0x20,%esp
  801b8c:	5e                   	pop    %esi
  801b8d:	5f                   	pop    %edi
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    
  801b90:	39 f2                	cmp    %esi,%edx
  801b92:	77 4c                	ja     801be0 <__umoddi3+0x80>
  801b94:	0f bd ca             	bsr    %edx,%ecx
  801b97:	83 f1 1f             	xor    $0x1f,%ecx
  801b9a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b9d:	75 51                	jne    801bf0 <__umoddi3+0x90>
  801b9f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801ba2:	0f 87 e0 00 00 00    	ja     801c88 <__umoddi3+0x128>
  801ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bab:	29 f8                	sub    %edi,%eax
  801bad:	19 d6                	sbb    %edx,%esi
  801baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb5:	89 f2                	mov    %esi,%edx
  801bb7:	83 c4 20             	add    $0x20,%esp
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    
  801bbe:	66 90                	xchg   %ax,%ax
  801bc0:	85 ff                	test   %edi,%edi
  801bc2:	75 0b                	jne    801bcf <__umoddi3+0x6f>
  801bc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc9:	31 d2                	xor    %edx,%edx
  801bcb:	f7 f7                	div    %edi
  801bcd:	89 c7                	mov    %eax,%edi
  801bcf:	89 f0                	mov    %esi,%eax
  801bd1:	31 d2                	xor    %edx,%edx
  801bd3:	f7 f7                	div    %edi
  801bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd8:	f7 f7                	div    %edi
  801bda:	eb a9                	jmp    801b85 <__umoddi3+0x25>
  801bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 c8                	mov    %ecx,%eax
  801be2:	89 f2                	mov    %esi,%edx
  801be4:	83 c4 20             	add    $0x20,%esp
  801be7:	5e                   	pop    %esi
  801be8:	5f                   	pop    %edi
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    
  801beb:	90                   	nop
  801bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bf4:	d3 e2                	shl    %cl,%edx
  801bf6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801bf9:	ba 20 00 00 00       	mov    $0x20,%edx
  801bfe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c01:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c04:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	d3 ea                	shr    %cl,%edx
  801c0c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c10:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c13:	d3 e7                	shl    %cl,%edi
  801c15:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c19:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801c21:	89 c7                	mov    %eax,%edi
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c29:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c2c:	89 c2                	mov    %eax,%edx
  801c2e:	d3 e6                	shl    %cl,%esi
  801c30:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c34:	d3 ea                	shr    %cl,%edx
  801c36:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c3a:	09 d6                	or     %edx,%esi
  801c3c:	89 f0                	mov    %esi,%eax
  801c3e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801c41:	d3 e7                	shl    %cl,%edi
  801c43:	89 f2                	mov    %esi,%edx
  801c45:	f7 75 f4             	divl   -0xc(%ebp)
  801c48:	89 d6                	mov    %edx,%esi
  801c4a:	f7 65 e8             	mull   -0x18(%ebp)
  801c4d:	39 d6                	cmp    %edx,%esi
  801c4f:	72 2b                	jb     801c7c <__umoddi3+0x11c>
  801c51:	39 c7                	cmp    %eax,%edi
  801c53:	72 23                	jb     801c78 <__umoddi3+0x118>
  801c55:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c59:	29 c7                	sub    %eax,%edi
  801c5b:	19 d6                	sbb    %edx,%esi
  801c5d:	89 f0                	mov    %esi,%eax
  801c5f:	89 f2                	mov    %esi,%edx
  801c61:	d3 ef                	shr    %cl,%edi
  801c63:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c67:	d3 e0                	shl    %cl,%eax
  801c69:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c6d:	09 f8                	or     %edi,%eax
  801c6f:	d3 ea                	shr    %cl,%edx
  801c71:	83 c4 20             	add    $0x20,%esp
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	39 d6                	cmp    %edx,%esi
  801c7a:	75 d9                	jne    801c55 <__umoddi3+0xf5>
  801c7c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801c7f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801c82:	eb d1                	jmp    801c55 <__umoddi3+0xf5>
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	0f 82 18 ff ff ff    	jb     801ba8 <__umoddi3+0x48>
  801c90:	e9 1d ff ff ff       	jmp    801bb2 <__umoddi3+0x52>
