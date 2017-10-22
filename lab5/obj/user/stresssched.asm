
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 55 14 00 00       	call   8014a2 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800054:	e8 19 15 00 00       	call   801572 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 1f                	jmp    800086 <umain+0x46>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 1a                	je     800086 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	89 f0                	mov    %esi,%eax
  800074:	c1 e0 07             	shl    $0x7,%eax
  800077:	8d 84 b0 54 00 c0 ee 	lea    -0x113fffac(%eax,%esi,4),%eax
  80007e:	8b 00                	mov    (%eax),%eax
  800080:	85 c0                	test   %eax,%eax
  800082:	75 11                	jne    800095 <umain+0x55>
  800084:	eb 23                	jmp    8000a9 <umain+0x69>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800086:	e8 95 13 00 00       	call   801420 <sys_yield>
		return;
  80008b:	90                   	nop
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e9 96 00 00 00       	jmp    80012b <umain+0xeb>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800095:	89 f0                	mov    %esi,%eax
  800097:	c1 e0 07             	shl    $0x7,%eax
  80009a:	8d 94 b0 54 00 c0 ee 	lea    -0x113fffac(%eax,%esi,4),%edx
		asm volatile("pause");
  8000a1:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a3:	8b 02                	mov    (%edx),%eax
  8000a5:	85 c0                	test   %eax,%eax
  8000a7:	75 f8                	jne    8000a1 <umain+0x61>
  8000a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000ae:	be 00 00 00 00       	mov    $0x0,%esi
  8000b3:	e8 68 13 00 00       	call   801420 <sys_yield>
  8000b8:	89 f0                	mov    %esi,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000ba:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000c0:	83 c2 01             	add    $0x1,%edx
  8000c3:	89 15 04 40 80 00    	mov    %edx,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000c9:	83 c0 01             	add    $0x1,%eax
  8000cc:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000d1:	75 e7                	jne    8000ba <umain+0x7a>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000d3:	83 c3 01             	add    $0x1,%ebx
  8000d6:	83 fb 0a             	cmp    $0xa,%ebx
  8000d9:	75 d8                	jne    8000b3 <umain+0x73>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000db:	a1 04 40 80 00       	mov    0x804004,%eax
  8000e0:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000e5:	74 25                	je     80010c <umain+0xcc>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f0:	c7 44 24 08 00 26 80 	movl   $0x802600,0x8(%esp)
  8000f7:	00 
  8000f8:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000ff:	00 
  800100:	c7 04 24 28 26 80 00 	movl   $0x802628,(%esp)
  800107:	e8 98 00 00 00       	call   8001a4 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  80010c:	a1 08 40 80 00       	mov    0x804008,%eax
  800111:	8b 50 5c             	mov    0x5c(%eax),%edx
  800114:	8b 40 48             	mov    0x48(%eax),%eax
  800117:	89 54 24 08          	mov    %edx,0x8(%esp)
  80011b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011f:	c7 04 24 3b 26 80 00 	movl   $0x80263b,(%esp)
  800126:	e8 32 01 00 00       	call   80025d <cprintf>

}
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    
	...

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
  80013a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80013d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800140:	8b 75 08             	mov    0x8(%ebp),%esi
  800143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800146:	e8 57 13 00 00       	call   8014a2 <sys_getenvid>
  80014b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800150:	89 c2                	mov    %eax,%edx
  800152:	c1 e2 07             	shl    $0x7,%edx
  800155:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80015c:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800161:	85 f6                	test   %esi,%esi
  800163:	7e 07                	jle    80016c <libmain+0x38>
		binaryname = argv[0];
  800165:	8b 03                	mov    (%ebx),%eax
  800167:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800170:	89 34 24             	mov    %esi,(%esp)
  800173:	e8 c8 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800178:	e8 0b 00 00 00       	call   800188 <exit>
}
  80017d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800180:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800183:	89 ec                	mov    %ebp,%esp
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    
	...

00800188 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80018e:	e8 48 1c 00 00       	call   801ddb <close_all>
	sys_env_destroy(0);
  800193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019a:	e8 43 13 00 00       	call   8014e2 <sys_env_destroy>
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    
  8001a1:	00 00                	add    %al,(%eax)
	...

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001ac:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001af:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001b5:	e8 e8 12 00 00       	call   8014a2 <sys_getenvid>
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 64 26 80 00 	movl   $0x802664,(%esp)
  8001d7:	e8 81 00 00 00       	call   80025d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 11 00 00 00       	call   8001fc <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 57 26 80 00 	movl   $0x802657,(%esp)
  8001f2:	e8 66 00 00 00       	call   80025d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f7:	cc                   	int3   
  8001f8:	eb fd                	jmp    8001f7 <_panic+0x53>
	...

008001fc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800205:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020c:	00 00 00 
	b.cnt = 0;
  80020f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800216:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800219:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800220:	8b 45 08             	mov    0x8(%ebp),%eax
  800223:	89 44 24 08          	mov    %eax,0x8(%esp)
  800227:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800231:	c7 04 24 77 02 80 00 	movl   $0x800277,(%esp)
  800238:	e8 cf 01 00 00       	call   80040c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024d:	89 04 24             	mov    %eax,(%esp)
  800250:	e8 67 0d 00 00       	call   800fbc <sys_cputs>

	return b.cnt;
}
  800255:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    

0080025d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800263:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800266:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	89 04 24             	mov    %eax,(%esp)
  800270:	e8 87 ff ff ff       	call   8001fc <vcprintf>
	va_end(ap);

	return cnt;
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	53                   	push   %ebx
  80027b:	83 ec 14             	sub    $0x14,%esp
  80027e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800281:	8b 03                	mov    (%ebx),%eax
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  800286:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80028a:	83 c0 01             	add    $0x1,%eax
  80028d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80028f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800294:	75 19                	jne    8002af <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800296:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80029d:	00 
  80029e:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a1:	89 04 24             	mov    %eax,(%esp)
  8002a4:	e8 13 0d 00 00       	call   800fbc <sys_cputs>
		b->idx = 0;
  8002a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b3:	83 c4 14             	add    $0x14,%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    
  8002b9:	00 00                	add    %al,(%eax)
  8002bb:	00 00                	add    %al,(%eax)
  8002bd:	00 00                	add    %al,(%eax)
	...

008002c0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 4c             	sub    $0x4c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d6                	mov    %edx,%esi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002da:	8b 45 10             	mov    0x10(%ebp),%eax
  8002dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8002e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002eb:	39 d1                	cmp    %edx,%ecx
  8002ed:	72 07                	jb     8002f6 <printnum_v2+0x36>
  8002ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002f2:	39 d0                	cmp    %edx,%eax
  8002f4:	77 5f                	ja     800355 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8002f6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002fa:	83 eb 01             	sub    $0x1,%ebx
  8002fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800301:	89 44 24 08          	mov    %eax,0x8(%esp)
  800305:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800309:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80030d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800310:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800313:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800316:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80031a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800321:	00 
  800322:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80032b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032f:	e8 4c 20 00 00       	call   802380 <__udivdi3>
  800334:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800337:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80033a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800342:	89 04 24             	mov    %eax,(%esp)
  800345:	89 54 24 04          	mov    %edx,0x4(%esp)
  800349:	89 f2                	mov    %esi,%edx
  80034b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034e:	e8 6d ff ff ff       	call   8002c0 <printnum_v2>
  800353:	eb 1e                	jmp    800373 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800355:	83 ff 2d             	cmp    $0x2d,%edi
  800358:	74 19                	je     800373 <printnum_v2+0xb3>
		while (--width > 0)
  80035a:	83 eb 01             	sub    $0x1,%ebx
  80035d:	85 db                	test   %ebx,%ebx
  80035f:	90                   	nop
  800360:	7e 11                	jle    800373 <printnum_v2+0xb3>
			putch(padc, putdat);
  800362:	89 74 24 04          	mov    %esi,0x4(%esp)
  800366:	89 3c 24             	mov    %edi,(%esp)
  800369:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80036c:	83 eb 01             	sub    $0x1,%ebx
  80036f:	85 db                	test   %ebx,%ebx
  800371:	7f ef                	jg     800362 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800373:	89 74 24 04          	mov    %esi,0x4(%esp)
  800377:	8b 74 24 04          	mov    0x4(%esp),%esi
  80037b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800382:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800389:	00 
  80038a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80038d:	89 14 24             	mov    %edx,(%esp)
  800390:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800393:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800397:	e8 14 21 00 00       	call   8024b0 <__umoddi3>
  80039c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a0:	0f be 80 87 26 80 00 	movsbl 0x802687(%eax),%eax
  8003a7:	89 04 24             	mov    %eax,(%esp)
  8003aa:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ad:	83 c4 4c             	add    $0x4c,%esp
  8003b0:	5b                   	pop    %ebx
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b8:	83 fa 01             	cmp    $0x1,%edx
  8003bb:	7e 0e                	jle    8003cb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bd:	8b 10                	mov    (%eax),%edx
  8003bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 02                	mov    (%edx),%eax
  8003c6:	8b 52 04             	mov    0x4(%edx),%edx
  8003c9:	eb 22                	jmp    8003ed <getuint+0x38>
	else if (lflag)
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	74 10                	je     8003df <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d4:	89 08                	mov    %ecx,(%eax)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dd:	eb 0e                	jmp    8003ed <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fe:	73 0a                	jae    80040a <sprintputch+0x1b>
		*b->buf++ = ch;
  800400:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800403:	88 0a                	mov    %cl,(%edx)
  800405:	83 c2 01             	add    $0x1,%edx
  800408:	89 10                	mov    %edx,(%eax)
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	83 ec 6c             	sub    $0x6c,%esp
  800415:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800418:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80041f:	eb 1a                	jmp    80043b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800421:	85 c0                	test   %eax,%eax
  800423:	0f 84 66 06 00 00    	je     800a8f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800429:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	ff 55 08             	call   *0x8(%ebp)
  800436:	eb 03                	jmp    80043b <vprintfmt+0x2f>
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043b:	0f b6 07             	movzbl (%edi),%eax
  80043e:	83 c7 01             	add    $0x1,%edi
  800441:	83 f8 25             	cmp    $0x25,%eax
  800444:	75 db                	jne    800421 <vprintfmt+0x15>
  800446:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80044a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800456:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80045b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800462:	be 00 00 00 00       	mov    $0x0,%esi
  800467:	eb 06                	jmp    80046f <vprintfmt+0x63>
  800469:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80046d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	0f b6 17             	movzbl (%edi),%edx
  800472:	0f b6 c2             	movzbl %dl,%eax
  800475:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800478:	8d 47 01             	lea    0x1(%edi),%eax
  80047b:	83 ea 23             	sub    $0x23,%edx
  80047e:	80 fa 55             	cmp    $0x55,%dl
  800481:	0f 87 60 05 00 00    	ja     8009e7 <vprintfmt+0x5db>
  800487:	0f b6 d2             	movzbl %dl,%edx
  80048a:	ff 24 95 60 28 80 00 	jmp    *0x802860(,%edx,4)
  800491:	b9 01 00 00 00       	mov    $0x1,%ecx
  800496:	eb d5                	jmp    80046d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800498:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80049b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80049e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004a1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004a4:	83 ff 09             	cmp    $0x9,%edi
  8004a7:	76 08                	jbe    8004b1 <vprintfmt+0xa5>
  8004a9:	eb 40                	jmp    8004eb <vprintfmt+0xdf>
  8004ab:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8004af:	eb bc                	jmp    80046d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004b4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8004b7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8004bb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004be:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004c1:	83 ff 09             	cmp    $0x9,%edi
  8004c4:	76 eb                	jbe    8004b1 <vprintfmt+0xa5>
  8004c6:	eb 23                	jmp    8004eb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004cb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004ce:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004d1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8004d3:	eb 16                	jmp    8004eb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8004d5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d8:	c1 fa 1f             	sar    $0x1f,%edx
  8004db:	f7 d2                	not    %edx
  8004dd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8004e0:	eb 8b                	jmp    80046d <vprintfmt+0x61>
  8004e2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004e9:	eb 82                	jmp    80046d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8004eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ef:	0f 89 78 ff ff ff    	jns    80046d <vprintfmt+0x61>
  8004f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004f8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8004fb:	e9 6d ff ff ff       	jmp    80046d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800500:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800503:	e9 65 ff ff ff       	jmp    80046d <vprintfmt+0x61>
  800508:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 04             	lea    0x4(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 55 0c             	mov    0xc(%ebp),%edx
  800517:	89 54 24 04          	mov    %edx,0x4(%esp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	89 04 24             	mov    %eax,(%esp)
  800520:	ff 55 08             	call   *0x8(%ebp)
  800523:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800526:	e9 10 ff ff ff       	jmp    80043b <vprintfmt+0x2f>
  80052b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 c2                	mov    %eax,%edx
  80053b:	c1 fa 1f             	sar    $0x1f,%edx
  80053e:	31 d0                	xor    %edx,%eax
  800540:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800542:	83 f8 0f             	cmp    $0xf,%eax
  800545:	7f 0b                	jg     800552 <vprintfmt+0x146>
  800547:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  80054e:	85 d2                	test   %edx,%edx
  800550:	75 26                	jne    800578 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800552:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800556:	c7 44 24 08 98 26 80 	movl   $0x802698,0x8(%esp)
  80055d:	00 
  80055e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800561:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800565:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800568:	89 1c 24             	mov    %ebx,(%esp)
  80056b:	e8 a7 05 00 00       	call   800b17 <printfmt>
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800573:	e9 c3 fe ff ff       	jmp    80043b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800578:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057c:	c7 44 24 08 a1 26 80 	movl   $0x8026a1,0x8(%esp)
  800583:	00 
  800584:	8b 45 0c             	mov    0xc(%ebp),%eax
  800587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058b:	8b 55 08             	mov    0x8(%ebp),%edx
  80058e:	89 14 24             	mov    %edx,(%esp)
  800591:	e8 81 05 00 00       	call   800b17 <printfmt>
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800599:	e9 9d fe ff ff       	jmp    80043b <vprintfmt+0x2f>
  80059e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a1:	89 c7                	mov    %eax,%edi
  8005a3:	89 d9                	mov    %ebx,%ecx
  8005a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 50 04             	lea    0x4(%eax),%edx
  8005b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b4:	8b 30                	mov    (%eax),%esi
  8005b6:	85 f6                	test   %esi,%esi
  8005b8:	75 05                	jne    8005bf <vprintfmt+0x1b3>
  8005ba:	be a4 26 80 00       	mov    $0x8026a4,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8005bf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005c3:	7e 06                	jle    8005cb <vprintfmt+0x1bf>
  8005c5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8005c9:	75 10                	jne    8005db <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cb:	0f be 06             	movsbl (%esi),%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	0f 85 a2 00 00 00    	jne    800678 <vprintfmt+0x26c>
  8005d6:	e9 92 00 00 00       	jmp    80066d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005df:	89 34 24             	mov    %esi,(%esp)
  8005e2:	e8 74 05 00 00       	call   800b5b <strnlen>
  8005e7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005ea:	29 c2                	sub    %eax,%edx
  8005ec:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005ef:	85 d2                	test   %edx,%edx
  8005f1:	7e d8                	jle    8005cb <vprintfmt+0x1bf>
					putch(padc, putdat);
  8005f3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8005f7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005fa:	89 d3                	mov    %edx,%ebx
  8005fc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ff:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800602:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800605:	89 ce                	mov    %ecx,%esi
  800607:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060b:	89 34 24             	mov    %esi,(%esp)
  80060e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800611:	83 eb 01             	sub    $0x1,%ebx
  800614:	85 db                	test   %ebx,%ebx
  800616:	7f ef                	jg     800607 <vprintfmt+0x1fb>
  800618:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80061b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80061e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800621:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800628:	eb a1                	jmp    8005cb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80062e:	74 1b                	je     80064b <vprintfmt+0x23f>
  800630:	8d 50 e0             	lea    -0x20(%eax),%edx
  800633:	83 fa 5e             	cmp    $0x5e,%edx
  800636:	76 13                	jbe    80064b <vprintfmt+0x23f>
					putch('?', putdat);
  800638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800646:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800649:	eb 0d                	jmp    800658 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80064b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800652:	89 04 24             	mov    %eax,(%esp)
  800655:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800658:	83 ef 01             	sub    $0x1,%edi
  80065b:	0f be 06             	movsbl (%esi),%eax
  80065e:	85 c0                	test   %eax,%eax
  800660:	74 05                	je     800667 <vprintfmt+0x25b>
  800662:	83 c6 01             	add    $0x1,%esi
  800665:	eb 1a                	jmp    800681 <vprintfmt+0x275>
  800667:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80066a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800671:	7f 1f                	jg     800692 <vprintfmt+0x286>
  800673:	e9 c0 fd ff ff       	jmp    800438 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800678:	83 c6 01             	add    $0x1,%esi
  80067b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80067e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800681:	85 db                	test   %ebx,%ebx
  800683:	78 a5                	js     80062a <vprintfmt+0x21e>
  800685:	83 eb 01             	sub    $0x1,%ebx
  800688:	79 a0                	jns    80062a <vprintfmt+0x21e>
  80068a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80068d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800690:	eb db                	jmp    80066d <vprintfmt+0x261>
  800692:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800695:	8b 75 0c             	mov    0xc(%ebp),%esi
  800698:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80069b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ab:	83 eb 01             	sub    $0x1,%ebx
  8006ae:	85 db                	test   %ebx,%ebx
  8006b0:	7f ec                	jg     80069e <vprintfmt+0x292>
  8006b2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006b5:	e9 81 fd ff ff       	jmp    80043b <vprintfmt+0x2f>
  8006ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006bd:	83 fe 01             	cmp    $0x1,%esi
  8006c0:	7e 10                	jle    8006d2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 08             	lea    0x8(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cb:	8b 18                	mov    (%eax),%ebx
  8006cd:	8b 70 04             	mov    0x4(%eax),%esi
  8006d0:	eb 26                	jmp    8006f8 <vprintfmt+0x2ec>
	else if (lflag)
  8006d2:	85 f6                	test   %esi,%esi
  8006d4:	74 12                	je     8006e8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006df:	8b 18                	mov    (%eax),%ebx
  8006e1:	89 de                	mov    %ebx,%esi
  8006e3:	c1 fe 1f             	sar    $0x1f,%esi
  8006e6:	eb 10                	jmp    8006f8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 18                	mov    (%eax),%ebx
  8006f3:	89 de                	mov    %ebx,%esi
  8006f5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8006f8:	83 f9 01             	cmp    $0x1,%ecx
  8006fb:	75 1e                	jne    80071b <vprintfmt+0x30f>
                               if((long long)num > 0){
  8006fd:	85 f6                	test   %esi,%esi
  8006ff:	78 1a                	js     80071b <vprintfmt+0x30f>
  800701:	85 f6                	test   %esi,%esi
  800703:	7f 05                	jg     80070a <vprintfmt+0x2fe>
  800705:	83 fb 00             	cmp    $0x0,%ebx
  800708:	76 11                	jbe    80071b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80070a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800711:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800718:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80071b:	85 f6                	test   %esi,%esi
  80071d:	78 13                	js     800732 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800722:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800728:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072d:	e9 da 00 00 00       	jmp    80080c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800732:	8b 45 0c             	mov    0xc(%ebp),%eax
  800735:	89 44 24 04          	mov    %eax,0x4(%esp)
  800739:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800743:	89 da                	mov    %ebx,%edx
  800745:	89 f1                	mov    %esi,%ecx
  800747:	f7 da                	neg    %edx
  800749:	83 d1 00             	adc    $0x0,%ecx
  80074c:	f7 d9                	neg    %ecx
  80074e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800751:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800754:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800757:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075c:	e9 ab 00 00 00       	jmp    80080c <vprintfmt+0x400>
  800761:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800764:	89 f2                	mov    %esi,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 47 fc ff ff       	call   8003b5 <getuint>
  80076e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800771:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800777:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80077c:	e9 8b 00 00 00       	jmp    80080c <vprintfmt+0x400>
  800781:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800787:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800792:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800795:	89 f2                	mov    %esi,%edx
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
  80079a:	e8 16 fc ff ff       	call   8003b5 <getuint>
  80079f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007a2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8007ad:	eb 5d                	jmp    80080c <vprintfmt+0x400>
  8007af:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007c0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ce:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 50 04             	lea    0x4(%eax),%edx
  8007d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007da:	8b 10                	mov    (%eax),%edx
  8007dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007e4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ea:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ef:	eb 1b                	jmp    80080c <vprintfmt+0x400>
  8007f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f4:	89 f2                	mov    %esi,%edx
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	e8 b7 fb ff ff       	call   8003b5 <getuint>
  8007fe:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800801:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800804:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800807:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800810:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800813:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800816:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80081a:	77 09                	ja     800825 <vprintfmt+0x419>
  80081c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80081f:	0f 82 ac 00 00 00    	jb     8008d1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800825:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800828:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80082c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80082f:	83 ea 01             	sub    $0x1,%edx
  800832:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800836:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80083e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800842:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800845:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800848:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80084b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80084f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800856:	00 
  800857:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80085a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80085d:	89 0c 24             	mov    %ecx,(%esp)
  800860:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800864:	e8 17 1b 00 00       	call   802380 <__udivdi3>
  800869:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80086c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80086f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800873:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800877:	89 04 24             	mov    %eax,(%esp)
  80087a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	e8 37 fa ff ff       	call   8002c0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80088c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800890:	8b 74 24 04          	mov    0x4(%esp),%esi
  800894:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800897:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008a2:	00 
  8008a3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8008a6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8008a9:	89 14 24             	mov    %edx,(%esp)
  8008ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b0:	e8 fb 1b 00 00       	call   8024b0 <__umoddi3>
  8008b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b9:	0f be 80 87 26 80 00 	movsbl 0x802687(%eax),%eax
  8008c0:	89 04 24             	mov    %eax,(%esp)
  8008c3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8008c6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008ca:	74 54                	je     800920 <vprintfmt+0x514>
  8008cc:	e9 67 fb ff ff       	jmp    800438 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8008d1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008d5:	8d 76 00             	lea    0x0(%esi),%esi
  8008d8:	0f 84 2a 01 00 00    	je     800a08 <vprintfmt+0x5fc>
		while (--width > 0)
  8008de:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008e1:	83 ef 01             	sub    $0x1,%edi
  8008e4:	85 ff                	test   %edi,%edi
  8008e6:	0f 8e 5e 01 00 00    	jle    800a4a <vprintfmt+0x63e>
  8008ec:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008ef:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008f2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8008f5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8008f8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008fb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8008fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800902:	89 1c 24             	mov    %ebx,(%esp)
  800905:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800908:	83 ef 01             	sub    $0x1,%edi
  80090b:	85 ff                	test   %edi,%edi
  80090d:	7f ef                	jg     8008fe <vprintfmt+0x4f2>
  80090f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800912:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800915:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800918:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80091b:	e9 2a 01 00 00       	jmp    800a4a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800920:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800923:	83 eb 01             	sub    $0x1,%ebx
  800926:	85 db                	test   %ebx,%ebx
  800928:	0f 8e 0a fb ff ff    	jle    800438 <vprintfmt+0x2c>
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800934:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800937:	89 74 24 04          	mov    %esi,0x4(%esp)
  80093b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800942:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800944:	83 eb 01             	sub    $0x1,%ebx
  800947:	85 db                	test   %ebx,%ebx
  800949:	7f ec                	jg     800937 <vprintfmt+0x52b>
  80094b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80094e:	e9 e8 fa ff ff       	jmp    80043b <vprintfmt+0x2f>
  800953:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800956:	8b 45 14             	mov    0x14(%ebp),%eax
  800959:	8d 50 04             	lea    0x4(%eax),%edx
  80095c:	89 55 14             	mov    %edx,0x14(%ebp)
  80095f:	8b 00                	mov    (%eax),%eax
  800961:	85 c0                	test   %eax,%eax
  800963:	75 2a                	jne    80098f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800965:	c7 44 24 0c c0 27 80 	movl   $0x8027c0,0xc(%esp)
  80096c:	00 
  80096d:	c7 44 24 08 a1 26 80 	movl   $0x8026a1,0x8(%esp)
  800974:	00 
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
  800978:	89 54 24 04          	mov    %edx,0x4(%esp)
  80097c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097f:	89 0c 24             	mov    %ecx,(%esp)
  800982:	e8 90 01 00 00       	call   800b17 <printfmt>
  800987:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80098a:	e9 ac fa ff ff       	jmp    80043b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80098f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800992:	8b 13                	mov    (%ebx),%edx
  800994:	83 fa 7f             	cmp    $0x7f,%edx
  800997:	7e 29                	jle    8009c2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800999:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80099b:	c7 44 24 0c f8 27 80 	movl   $0x8027f8,0xc(%esp)
  8009a2:	00 
  8009a3:	c7 44 24 08 a1 26 80 	movl   $0x8026a1,0x8(%esp)
  8009aa:	00 
  8009ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	89 04 24             	mov    %eax,(%esp)
  8009b5:	e8 5d 01 00 00       	call   800b17 <printfmt>
  8009ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009bd:	e9 79 fa ff ff       	jmp    80043b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8009c2:	88 10                	mov    %dl,(%eax)
  8009c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009c7:	e9 6f fa ff ff       	jmp    80043b <vprintfmt+0x2f>
  8009cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009d9:	89 14 24             	mov    %edx,(%esp)
  8009dc:	ff 55 08             	call   *0x8(%ebp)
  8009df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8009e2:	e9 54 fa ff ff       	jmp    80043b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009f5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8009fb:	80 38 25             	cmpb   $0x25,(%eax)
  8009fe:	0f 84 37 fa ff ff    	je     80043b <vprintfmt+0x2f>
  800a04:	89 c7                	mov    %eax,%edi
  800a06:	eb f0                	jmp    8009f8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a13:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a16:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a21:	00 
  800a22:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a25:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a28:	89 04 24             	mov    %eax,(%esp)
  800a2b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a2f:	e8 7c 1a 00 00       	call   8024b0 <__umoddi3>
  800a34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a38:	0f be 80 87 26 80 00 	movsbl 0x802687(%eax),%eax
  800a3f:	89 04 24             	mov    %eax,(%esp)
  800a42:	ff 55 08             	call   *0x8(%ebp)
  800a45:	e9 d6 fe ff ff       	jmp    800920 <vprintfmt+0x514>
  800a4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a51:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a55:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a5c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a63:	00 
  800a64:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a67:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a6a:	89 04 24             	mov    %eax,(%esp)
  800a6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a71:	e8 3a 1a 00 00       	call   8024b0 <__umoddi3>
  800a76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a7a:	0f be 80 87 26 80 00 	movsbl 0x802687(%eax),%eax
  800a81:	89 04 24             	mov    %eax,(%esp)
  800a84:	ff 55 08             	call   *0x8(%ebp)
  800a87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a8a:	e9 ac f9 ff ff       	jmp    80043b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a8f:	83 c4 6c             	add    $0x6c,%esp
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	83 ec 28             	sub    $0x28,%esp
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	74 04                	je     800aab <vsnprintf+0x14>
  800aa7:	85 d2                	test   %edx,%edx
  800aa9:	7f 07                	jg     800ab2 <vsnprintf+0x1b>
  800aab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ab0:	eb 3b                	jmp    800aed <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ab2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800abc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aca:	8b 45 10             	mov    0x10(%ebp),%eax
  800acd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad8:	c7 04 24 ef 03 80 00 	movl   $0x8003ef,(%esp)
  800adf:	e8 28 f9 ff ff       	call   80040c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ae4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ae7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
  800aff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	89 04 24             	mov    %eax,(%esp)
  800b10:	e8 82 ff ff ff       	call   800a97 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b15:	c9                   	leave  
  800b16:	c3                   	ret    

00800b17 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b1d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b24:	8b 45 10             	mov    0x10(%ebp),%eax
  800b27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	89 04 24             	mov    %eax,(%esp)
  800b38:	e8 cf f8 ff ff       	call   80040c <vprintfmt>
	va_end(ap);
}
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    
	...

00800b40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b4e:	74 09                	je     800b59 <strlen+0x19>
		n++;
  800b50:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b57:	75 f7                	jne    800b50 <strlen+0x10>
		n++;
	return n;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	53                   	push   %ebx
  800b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b65:	85 c9                	test   %ecx,%ecx
  800b67:	74 19                	je     800b82 <strnlen+0x27>
  800b69:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b6c:	74 14                	je     800b82 <strnlen+0x27>
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b73:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b76:	39 c8                	cmp    %ecx,%eax
  800b78:	74 0d                	je     800b87 <strnlen+0x2c>
  800b7a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b7e:	75 f3                	jne    800b73 <strnlen+0x18>
  800b80:	eb 05                	jmp    800b87 <strnlen+0x2c>
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b87:	5b                   	pop    %ebx
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	53                   	push   %ebx
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b99:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b9d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ba0:	83 c2 01             	add    $0x1,%edx
  800ba3:	84 c9                	test   %cl,%cl
  800ba5:	75 f2                	jne    800b99 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strcat>:

char *
strcat(char *dst, const char *src)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	83 ec 08             	sub    $0x8,%esp
  800bb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb4:	89 1c 24             	mov    %ebx,(%esp)
  800bb7:	e8 84 ff ff ff       	call   800b40 <strlen>
	strcpy(dst + len, src);
  800bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bc6:	89 04 24             	mov    %eax,(%esp)
  800bc9:	e8 bc ff ff ff       	call   800b8a <strcpy>
	return dst;
}
  800bce:	89 d8                	mov    %ebx,%eax
  800bd0:	83 c4 08             	add    $0x8,%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be4:	85 f6                	test   %esi,%esi
  800be6:	74 18                	je     800c00 <strncpy+0x2a>
  800be8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bed:	0f b6 1a             	movzbl (%edx),%ebx
  800bf0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bf3:	80 3a 01             	cmpb   $0x1,(%edx)
  800bf6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf9:	83 c1 01             	add    $0x1,%ecx
  800bfc:	39 ce                	cmp    %ecx,%esi
  800bfe:	77 ed                	ja     800bed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	8b 75 08             	mov    0x8(%ebp),%esi
  800c0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c12:	89 f0                	mov    %esi,%eax
  800c14:	85 c9                	test   %ecx,%ecx
  800c16:	74 27                	je     800c3f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c18:	83 e9 01             	sub    $0x1,%ecx
  800c1b:	74 1d                	je     800c3a <strlcpy+0x36>
  800c1d:	0f b6 1a             	movzbl (%edx),%ebx
  800c20:	84 db                	test   %bl,%bl
  800c22:	74 16                	je     800c3a <strlcpy+0x36>
			*dst++ = *src++;
  800c24:	88 18                	mov    %bl,(%eax)
  800c26:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c29:	83 e9 01             	sub    $0x1,%ecx
  800c2c:	74 0e                	je     800c3c <strlcpy+0x38>
			*dst++ = *src++;
  800c2e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c31:	0f b6 1a             	movzbl (%edx),%ebx
  800c34:	84 db                	test   %bl,%bl
  800c36:	75 ec                	jne    800c24 <strlcpy+0x20>
  800c38:	eb 02                	jmp    800c3c <strlcpy+0x38>
  800c3a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c3c:	c6 00 00             	movb   $0x0,(%eax)
  800c3f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c4e:	0f b6 01             	movzbl (%ecx),%eax
  800c51:	84 c0                	test   %al,%al
  800c53:	74 15                	je     800c6a <strcmp+0x25>
  800c55:	3a 02                	cmp    (%edx),%al
  800c57:	75 11                	jne    800c6a <strcmp+0x25>
		p++, q++;
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c5f:	0f b6 01             	movzbl (%ecx),%eax
  800c62:	84 c0                	test   %al,%al
  800c64:	74 04                	je     800c6a <strcmp+0x25>
  800c66:	3a 02                	cmp    (%edx),%al
  800c68:	74 ef                	je     800c59 <strcmp+0x14>
  800c6a:	0f b6 c0             	movzbl %al,%eax
  800c6d:	0f b6 12             	movzbl (%edx),%edx
  800c70:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	53                   	push   %ebx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	74 23                	je     800ca8 <strncmp+0x34>
  800c85:	0f b6 1a             	movzbl (%edx),%ebx
  800c88:	84 db                	test   %bl,%bl
  800c8a:	74 25                	je     800cb1 <strncmp+0x3d>
  800c8c:	3a 19                	cmp    (%ecx),%bl
  800c8e:	75 21                	jne    800cb1 <strncmp+0x3d>
  800c90:	83 e8 01             	sub    $0x1,%eax
  800c93:	74 13                	je     800ca8 <strncmp+0x34>
		n--, p++, q++;
  800c95:	83 c2 01             	add    $0x1,%edx
  800c98:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c9b:	0f b6 1a             	movzbl (%edx),%ebx
  800c9e:	84 db                	test   %bl,%bl
  800ca0:	74 0f                	je     800cb1 <strncmp+0x3d>
  800ca2:	3a 19                	cmp    (%ecx),%bl
  800ca4:	74 ea                	je     800c90 <strncmp+0x1c>
  800ca6:	eb 09                	jmp    800cb1 <strncmp+0x3d>
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cad:	5b                   	pop    %ebx
  800cae:	5d                   	pop    %ebp
  800caf:	90                   	nop
  800cb0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb1:	0f b6 02             	movzbl (%edx),%eax
  800cb4:	0f b6 11             	movzbl (%ecx),%edx
  800cb7:	29 d0                	sub    %edx,%eax
  800cb9:	eb f2                	jmp    800cad <strncmp+0x39>

00800cbb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc5:	0f b6 10             	movzbl (%eax),%edx
  800cc8:	84 d2                	test   %dl,%dl
  800cca:	74 18                	je     800ce4 <strchr+0x29>
		if (*s == c)
  800ccc:	38 ca                	cmp    %cl,%dl
  800cce:	75 0a                	jne    800cda <strchr+0x1f>
  800cd0:	eb 17                	jmp    800ce9 <strchr+0x2e>
  800cd2:	38 ca                	cmp    %cl,%dl
  800cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd8:	74 0f                	je     800ce9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cda:	83 c0 01             	add    $0x1,%eax
  800cdd:	0f b6 10             	movzbl (%eax),%edx
  800ce0:	84 d2                	test   %dl,%dl
  800ce2:	75 ee                	jne    800cd2 <strchr+0x17>
  800ce4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf5:	0f b6 10             	movzbl (%eax),%edx
  800cf8:	84 d2                	test   %dl,%dl
  800cfa:	74 18                	je     800d14 <strfind+0x29>
		if (*s == c)
  800cfc:	38 ca                	cmp    %cl,%dl
  800cfe:	75 0a                	jne    800d0a <strfind+0x1f>
  800d00:	eb 12                	jmp    800d14 <strfind+0x29>
  800d02:	38 ca                	cmp    %cl,%dl
  800d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d08:	74 0a                	je     800d14 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	0f b6 10             	movzbl (%eax),%edx
  800d10:	84 d2                	test   %dl,%dl
  800d12:	75 ee                	jne    800d02 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	89 1c 24             	mov    %ebx,(%esp)
  800d1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d30:	85 c9                	test   %ecx,%ecx
  800d32:	74 30                	je     800d64 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d3a:	75 25                	jne    800d61 <memset+0x4b>
  800d3c:	f6 c1 03             	test   $0x3,%cl
  800d3f:	75 20                	jne    800d61 <memset+0x4b>
		c &= 0xFF;
  800d41:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d44:	89 d3                	mov    %edx,%ebx
  800d46:	c1 e3 08             	shl    $0x8,%ebx
  800d49:	89 d6                	mov    %edx,%esi
  800d4b:	c1 e6 18             	shl    $0x18,%esi
  800d4e:	89 d0                	mov    %edx,%eax
  800d50:	c1 e0 10             	shl    $0x10,%eax
  800d53:	09 f0                	or     %esi,%eax
  800d55:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d57:	09 d8                	or     %ebx,%eax
  800d59:	c1 e9 02             	shr    $0x2,%ecx
  800d5c:	fc                   	cld    
  800d5d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d5f:	eb 03                	jmp    800d64 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d61:	fc                   	cld    
  800d62:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d64:	89 f8                	mov    %edi,%eax
  800d66:	8b 1c 24             	mov    (%esp),%ebx
  800d69:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d6d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d71:	89 ec                	mov    %ebp,%esp
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 08             	sub    $0x8,%esp
  800d7b:	89 34 24             	mov    %esi,(%esp)
  800d7e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d88:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d8b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d8d:	39 c6                	cmp    %eax,%esi
  800d8f:	73 35                	jae    800dc6 <memmove+0x51>
  800d91:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d94:	39 d0                	cmp    %edx,%eax
  800d96:	73 2e                	jae    800dc6 <memmove+0x51>
		s += n;
		d += n;
  800d98:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d9a:	f6 c2 03             	test   $0x3,%dl
  800d9d:	75 1b                	jne    800dba <memmove+0x45>
  800d9f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da5:	75 13                	jne    800dba <memmove+0x45>
  800da7:	f6 c1 03             	test   $0x3,%cl
  800daa:	75 0e                	jne    800dba <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800dac:	83 ef 04             	sub    $0x4,%edi
  800daf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800db2:	c1 e9 02             	shr    $0x2,%ecx
  800db5:	fd                   	std    
  800db6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800db8:	eb 09                	jmp    800dc3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dba:	83 ef 01             	sub    $0x1,%edi
  800dbd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800dc0:	fd                   	std    
  800dc1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dc3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dc4:	eb 20                	jmp    800de6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dcc:	75 15                	jne    800de3 <memmove+0x6e>
  800dce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dd4:	75 0d                	jne    800de3 <memmove+0x6e>
  800dd6:	f6 c1 03             	test   $0x3,%cl
  800dd9:	75 08                	jne    800de3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800ddb:	c1 e9 02             	shr    $0x2,%ecx
  800dde:	fc                   	cld    
  800ddf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de1:	eb 03                	jmp    800de6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800de3:	fc                   	cld    
  800de4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800de6:	8b 34 24             	mov    (%esp),%esi
  800de9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ded:	89 ec                	mov    %ebp,%esp
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800df7:	8b 45 10             	mov    0x10(%ebp),%eax
  800dfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	89 04 24             	mov    %eax,(%esp)
  800e0b:	e8 65 ff ff ff       	call   800d75 <memmove>
}
  800e10:	c9                   	leave  
  800e11:	c3                   	ret    

00800e12 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	8b 75 08             	mov    0x8(%ebp),%esi
  800e1b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e21:	85 c9                	test   %ecx,%ecx
  800e23:	74 36                	je     800e5b <memcmp+0x49>
		if (*s1 != *s2)
  800e25:	0f b6 06             	movzbl (%esi),%eax
  800e28:	0f b6 1f             	movzbl (%edi),%ebx
  800e2b:	38 d8                	cmp    %bl,%al
  800e2d:	74 20                	je     800e4f <memcmp+0x3d>
  800e2f:	eb 14                	jmp    800e45 <memcmp+0x33>
  800e31:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e36:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e3b:	83 c2 01             	add    $0x1,%edx
  800e3e:	83 e9 01             	sub    $0x1,%ecx
  800e41:	38 d8                	cmp    %bl,%al
  800e43:	74 12                	je     800e57 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e45:	0f b6 c0             	movzbl %al,%eax
  800e48:	0f b6 db             	movzbl %bl,%ebx
  800e4b:	29 d8                	sub    %ebx,%eax
  800e4d:	eb 11                	jmp    800e60 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e4f:	83 e9 01             	sub    $0x1,%ecx
  800e52:	ba 00 00 00 00       	mov    $0x0,%edx
  800e57:	85 c9                	test   %ecx,%ecx
  800e59:	75 d6                	jne    800e31 <memcmp+0x1f>
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e6b:	89 c2                	mov    %eax,%edx
  800e6d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e70:	39 d0                	cmp    %edx,%eax
  800e72:	73 15                	jae    800e89 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e74:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e78:	38 08                	cmp    %cl,(%eax)
  800e7a:	75 06                	jne    800e82 <memfind+0x1d>
  800e7c:	eb 0b                	jmp    800e89 <memfind+0x24>
  800e7e:	38 08                	cmp    %cl,(%eax)
  800e80:	74 07                	je     800e89 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e82:	83 c0 01             	add    $0x1,%eax
  800e85:	39 c2                	cmp    %eax,%edx
  800e87:	77 f5                	ja     800e7e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e9a:	0f b6 02             	movzbl (%edx),%eax
  800e9d:	3c 20                	cmp    $0x20,%al
  800e9f:	74 04                	je     800ea5 <strtol+0x1a>
  800ea1:	3c 09                	cmp    $0x9,%al
  800ea3:	75 0e                	jne    800eb3 <strtol+0x28>
		s++;
  800ea5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea8:	0f b6 02             	movzbl (%edx),%eax
  800eab:	3c 20                	cmp    $0x20,%al
  800ead:	74 f6                	je     800ea5 <strtol+0x1a>
  800eaf:	3c 09                	cmp    $0x9,%al
  800eb1:	74 f2                	je     800ea5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eb3:	3c 2b                	cmp    $0x2b,%al
  800eb5:	75 0c                	jne    800ec3 <strtol+0x38>
		s++;
  800eb7:	83 c2 01             	add    $0x1,%edx
  800eba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ec1:	eb 15                	jmp    800ed8 <strtol+0x4d>
	else if (*s == '-')
  800ec3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eca:	3c 2d                	cmp    $0x2d,%al
  800ecc:	75 0a                	jne    800ed8 <strtol+0x4d>
		s++, neg = 1;
  800ece:	83 c2 01             	add    $0x1,%edx
  800ed1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed8:	85 db                	test   %ebx,%ebx
  800eda:	0f 94 c0             	sete   %al
  800edd:	74 05                	je     800ee4 <strtol+0x59>
  800edf:	83 fb 10             	cmp    $0x10,%ebx
  800ee2:	75 18                	jne    800efc <strtol+0x71>
  800ee4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ee7:	75 13                	jne    800efc <strtol+0x71>
  800ee9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eed:	8d 76 00             	lea    0x0(%esi),%esi
  800ef0:	75 0a                	jne    800efc <strtol+0x71>
		s += 2, base = 16;
  800ef2:	83 c2 02             	add    $0x2,%edx
  800ef5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800efa:	eb 15                	jmp    800f11 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800efc:	84 c0                	test   %al,%al
  800efe:	66 90                	xchg   %ax,%ax
  800f00:	74 0f                	je     800f11 <strtol+0x86>
  800f02:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f07:	80 3a 30             	cmpb   $0x30,(%edx)
  800f0a:	75 05                	jne    800f11 <strtol+0x86>
		s++, base = 8;
  800f0c:	83 c2 01             	add    $0x1,%edx
  800f0f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
  800f16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f18:	0f b6 0a             	movzbl (%edx),%ecx
  800f1b:	89 cf                	mov    %ecx,%edi
  800f1d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f20:	80 fb 09             	cmp    $0x9,%bl
  800f23:	77 08                	ja     800f2d <strtol+0xa2>
			dig = *s - '0';
  800f25:	0f be c9             	movsbl %cl,%ecx
  800f28:	83 e9 30             	sub    $0x30,%ecx
  800f2b:	eb 1e                	jmp    800f4b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f2d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f30:	80 fb 19             	cmp    $0x19,%bl
  800f33:	77 08                	ja     800f3d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f35:	0f be c9             	movsbl %cl,%ecx
  800f38:	83 e9 57             	sub    $0x57,%ecx
  800f3b:	eb 0e                	jmp    800f4b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f3d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f40:	80 fb 19             	cmp    $0x19,%bl
  800f43:	77 15                	ja     800f5a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f45:	0f be c9             	movsbl %cl,%ecx
  800f48:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f4b:	39 f1                	cmp    %esi,%ecx
  800f4d:	7d 0b                	jge    800f5a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f4f:	83 c2 01             	add    $0x1,%edx
  800f52:	0f af c6             	imul   %esi,%eax
  800f55:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f58:	eb be                	jmp    800f18 <strtol+0x8d>
  800f5a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f60:	74 05                	je     800f67 <strtol+0xdc>
		*endptr = (char *) s;
  800f62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f65:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f6b:	74 04                	je     800f71 <strtol+0xe6>
  800f6d:	89 c8                	mov    %ecx,%eax
  800f6f:	f7 d8                	neg    %eax
}
  800f71:	83 c4 04             	add    $0x4,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	00 00                	add    %al,(%eax)
	...

00800f7c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
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
  800f89:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f93:	89 d1                	mov    %edx,%ecx
  800f95:	89 d3                	mov    %edx,%ebx
  800f97:	89 d7                	mov    %edx,%edi
  800f99:	51                   	push   %ecx
  800f9a:	52                   	push   %edx
  800f9b:	53                   	push   %ebx
  800f9c:	54                   	push   %esp
  800f9d:	55                   	push   %ebp
  800f9e:	56                   	push   %esi
  800f9f:	57                   	push   %edi
  800fa0:	54                   	push   %esp
  800fa1:	5d                   	pop    %ebp
  800fa2:	8d 35 aa 0f 80 00    	lea    0x800faa,%esi
  800fa8:	0f 34                	sysenter 
  800faa:	5f                   	pop    %edi
  800fab:	5e                   	pop    %esi
  800fac:	5d                   	pop    %ebp
  800fad:	5c                   	pop    %esp
  800fae:	5b                   	pop    %ebx
  800faf:	5a                   	pop    %edx
  800fb0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fb1:	8b 1c 24             	mov    (%esp),%ebx
  800fb4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb8:	89 ec                	mov    %ebp,%esp
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 08             	sub    $0x8,%esp
  800fc2:	89 1c 24             	mov    %ebx,(%esp)
  800fc5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd4:	89 c3                	mov    %eax,%ebx
  800fd6:	89 c7                	mov    %eax,%edi
  800fd8:	51                   	push   %ecx
  800fd9:	52                   	push   %edx
  800fda:	53                   	push   %ebx
  800fdb:	54                   	push   %esp
  800fdc:	55                   	push   %ebp
  800fdd:	56                   	push   %esi
  800fde:	57                   	push   %edi
  800fdf:	54                   	push   %esp
  800fe0:	5d                   	pop    %ebp
  800fe1:	8d 35 e9 0f 80 00    	lea    0x800fe9,%esi
  800fe7:	0f 34                	sysenter 
  800fe9:	5f                   	pop    %edi
  800fea:	5e                   	pop    %esi
  800feb:	5d                   	pop    %ebp
  800fec:	5c                   	pop    %esp
  800fed:	5b                   	pop    %ebx
  800fee:	5a                   	pop    %edx
  800fef:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ff0:	8b 1c 24             	mov    (%esp),%ebx
  800ff3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff7:	89 ec                	mov    %ebp,%esp
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	89 1c 24             	mov    %ebx,(%esp)
  801004:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801008:	b8 10 00 00 00       	mov    $0x10,%eax
  80100d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801010:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801013:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	51                   	push   %ecx
  80101a:	52                   	push   %edx
  80101b:	53                   	push   %ebx
  80101c:	54                   	push   %esp
  80101d:	55                   	push   %ebp
  80101e:	56                   	push   %esi
  80101f:	57                   	push   %edi
  801020:	54                   	push   %esp
  801021:	5d                   	pop    %ebp
  801022:	8d 35 2a 10 80 00    	lea    0x80102a,%esi
  801028:	0f 34                	sysenter 
  80102a:	5f                   	pop    %edi
  80102b:	5e                   	pop    %esi
  80102c:	5d                   	pop    %ebp
  80102d:	5c                   	pop    %esp
  80102e:	5b                   	pop    %ebx
  80102f:	5a                   	pop    %edx
  801030:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801031:	8b 1c 24             	mov    (%esp),%ebx
  801034:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801038:	89 ec                	mov    %ebp,%esp
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 28             	sub    $0x28,%esp
  801042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801045:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801048:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801052:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801055:	8b 55 08             	mov    0x8(%ebp),%edx
  801058:	89 df                	mov    %ebx,%edi
  80105a:	51                   	push   %ecx
  80105b:	52                   	push   %edx
  80105c:	53                   	push   %ebx
  80105d:	54                   	push   %esp
  80105e:	55                   	push   %ebp
  80105f:	56                   	push   %esi
  801060:	57                   	push   %edi
  801061:	54                   	push   %esp
  801062:	5d                   	pop    %ebp
  801063:	8d 35 6b 10 80 00    	lea    0x80106b,%esi
  801069:	0f 34                	sysenter 
  80106b:	5f                   	pop    %edi
  80106c:	5e                   	pop    %esi
  80106d:	5d                   	pop    %ebp
  80106e:	5c                   	pop    %esp
  80106f:	5b                   	pop    %ebx
  801070:	5a                   	pop    %edx
  801071:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 28                	jle    80109e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801076:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801081:	00 
  801082:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  801089:	00 
  80108a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801091:	00 
  801092:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  801099:	e8 06 f1 ff ff       	call   8001a4 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80109e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010a4:	89 ec                	mov    %ebp,%esp
  8010a6:	5d                   	pop    %ebp
  8010a7:	c3                   	ret    

008010a8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	89 1c 24             	mov    %ebx,(%esp)
  8010b1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ba:	b8 11 00 00 00       	mov    $0x11,%eax
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010de:	8b 1c 24             	mov    (%esp),%ebx
  8010e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010e5:	89 ec                	mov    %ebp,%esp
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	83 ec 28             	sub    $0x28,%esp
  8010ef:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010f2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fa:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	89 cb                	mov    %ecx,%ebx
  801104:	89 cf                	mov    %ecx,%edi
  801106:	51                   	push   %ecx
  801107:	52                   	push   %edx
  801108:	53                   	push   %ebx
  801109:	54                   	push   %esp
  80110a:	55                   	push   %ebp
  80110b:	56                   	push   %esi
  80110c:	57                   	push   %edi
  80110d:	54                   	push   %esp
  80110e:	5d                   	pop    %ebp
  80110f:	8d 35 17 11 80 00    	lea    0x801117,%esi
  801115:	0f 34                	sysenter 
  801117:	5f                   	pop    %edi
  801118:	5e                   	pop    %esi
  801119:	5d                   	pop    %ebp
  80111a:	5c                   	pop    %esp
  80111b:	5b                   	pop    %ebx
  80111c:	5a                   	pop    %edx
  80111d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80111e:	85 c0                	test   %eax,%eax
  801120:	7e 28                	jle    80114a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801122:	89 44 24 10          	mov    %eax,0x10(%esp)
  801126:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80112d:	00 
  80112e:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  801135:	00 
  801136:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80113d:	00 
  80113e:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  801145:	e8 5a f0 ff ff       	call   8001a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80114a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80114d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801150:	89 ec                	mov    %ebp,%esp
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	83 ec 08             	sub    $0x8,%esp
  80115a:	89 1c 24             	mov    %ebx,(%esp)
  80115d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801161:	b8 0d 00 00 00       	mov    $0xd,%eax
  801166:	8b 7d 14             	mov    0x14(%ebp),%edi
  801169:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80116c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116f:	8b 55 08             	mov    0x8(%ebp),%edx
  801172:	51                   	push   %ecx
  801173:	52                   	push   %edx
  801174:	53                   	push   %ebx
  801175:	54                   	push   %esp
  801176:	55                   	push   %ebp
  801177:	56                   	push   %esi
  801178:	57                   	push   %edi
  801179:	54                   	push   %esp
  80117a:	5d                   	pop    %ebp
  80117b:	8d 35 83 11 80 00    	lea    0x801183,%esi
  801181:	0f 34                	sysenter 
  801183:	5f                   	pop    %edi
  801184:	5e                   	pop    %esi
  801185:	5d                   	pop    %ebp
  801186:	5c                   	pop    %esp
  801187:	5b                   	pop    %ebx
  801188:	5a                   	pop    %edx
  801189:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80118a:	8b 1c 24             	mov    (%esp),%ebx
  80118d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801191:	89 ec                	mov    %ebp,%esp
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    

00801195 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	83 ec 28             	sub    $0x28,%esp
  80119b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80119e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	89 df                	mov    %ebx,%edi
  8011b3:	51                   	push   %ecx
  8011b4:	52                   	push   %edx
  8011b5:	53                   	push   %ebx
  8011b6:	54                   	push   %esp
  8011b7:	55                   	push   %ebp
  8011b8:	56                   	push   %esi
  8011b9:	57                   	push   %edi
  8011ba:	54                   	push   %esp
  8011bb:	5d                   	pop    %ebp
  8011bc:	8d 35 c4 11 80 00    	lea    0x8011c4,%esi
  8011c2:	0f 34                	sysenter 
  8011c4:	5f                   	pop    %edi
  8011c5:	5e                   	pop    %esi
  8011c6:	5d                   	pop    %ebp
  8011c7:	5c                   	pop    %esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5a                   	pop    %edx
  8011ca:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	7e 28                	jle    8011f7 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8011da:	00 
  8011db:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011ea:	00 
  8011eb:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  8011f2:	e8 ad ef ff ff       	call   8001a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011f7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011fd:	89 ec                	mov    %ebp,%esp
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 28             	sub    $0x28,%esp
  801207:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80120a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80120d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801212:	b8 0a 00 00 00       	mov    $0xa,%eax
  801217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121a:	8b 55 08             	mov    0x8(%ebp),%edx
  80121d:	89 df                	mov    %ebx,%edi
  80121f:	51                   	push   %ecx
  801220:	52                   	push   %edx
  801221:	53                   	push   %ebx
  801222:	54                   	push   %esp
  801223:	55                   	push   %ebp
  801224:	56                   	push   %esi
  801225:	57                   	push   %edi
  801226:	54                   	push   %esp
  801227:	5d                   	pop    %ebp
  801228:	8d 35 30 12 80 00    	lea    0x801230,%esi
  80122e:	0f 34                	sysenter 
  801230:	5f                   	pop    %edi
  801231:	5e                   	pop    %esi
  801232:	5d                   	pop    %ebp
  801233:	5c                   	pop    %esp
  801234:	5b                   	pop    %ebx
  801235:	5a                   	pop    %edx
  801236:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801237:	85 c0                	test   %eax,%eax
  801239:	7e 28                	jle    801263 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80123b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80123f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801246:	00 
  801247:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  80124e:	00 
  80124f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801256:	00 
  801257:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  80125e:	e8 41 ef ff ff       	call   8001a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801263:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801266:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801269:	89 ec                	mov    %ebp,%esp
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 28             	sub    $0x28,%esp
  801273:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801276:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801279:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127e:	b8 09 00 00 00       	mov    $0x9,%eax
  801283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801286:	8b 55 08             	mov    0x8(%ebp),%edx
  801289:	89 df                	mov    %ebx,%edi
  80128b:	51                   	push   %ecx
  80128c:	52                   	push   %edx
  80128d:	53                   	push   %ebx
  80128e:	54                   	push   %esp
  80128f:	55                   	push   %ebp
  801290:	56                   	push   %esi
  801291:	57                   	push   %edi
  801292:	54                   	push   %esp
  801293:	5d                   	pop    %ebp
  801294:	8d 35 9c 12 80 00    	lea    0x80129c,%esi
  80129a:	0f 34                	sysenter 
  80129c:	5f                   	pop    %edi
  80129d:	5e                   	pop    %esi
  80129e:	5d                   	pop    %ebp
  80129f:	5c                   	pop    %esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5a                   	pop    %edx
  8012a2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	7e 28                	jle    8012cf <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ab:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012b2:	00 
  8012b3:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  8012ba:	00 
  8012bb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012c2:	00 
  8012c3:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  8012ca:	e8 d5 ee ff ff       	call   8001a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012d5:	89 ec                	mov    %ebp,%esp
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 28             	sub    $0x28,%esp
  8012df:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012e2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ea:	b8 07 00 00 00       	mov    $0x7,%eax
  8012ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f5:	89 df                	mov    %ebx,%edi
  8012f7:	51                   	push   %ecx
  8012f8:	52                   	push   %edx
  8012f9:	53                   	push   %ebx
  8012fa:	54                   	push   %esp
  8012fb:	55                   	push   %ebp
  8012fc:	56                   	push   %esi
  8012fd:	57                   	push   %edi
  8012fe:	54                   	push   %esp
  8012ff:	5d                   	pop    %ebp
  801300:	8d 35 08 13 80 00    	lea    0x801308,%esi
  801306:	0f 34                	sysenter 
  801308:	5f                   	pop    %edi
  801309:	5e                   	pop    %esi
  80130a:	5d                   	pop    %ebp
  80130b:	5c                   	pop    %esp
  80130c:	5b                   	pop    %ebx
  80130d:	5a                   	pop    %edx
  80130e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80130f:	85 c0                	test   %eax,%eax
  801311:	7e 28                	jle    80133b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801313:	89 44 24 10          	mov    %eax,0x10(%esp)
  801317:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80131e:	00 
  80131f:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  801326:	00 
  801327:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80132e:	00 
  80132f:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  801336:	e8 69 ee ff ff       	call   8001a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80133b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80133e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801341:	89 ec                	mov    %ebp,%esp
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 28             	sub    $0x28,%esp
  80134b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80134e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801351:	8b 7d 18             	mov    0x18(%ebp),%edi
  801354:	0b 7d 14             	or     0x14(%ebp),%edi
  801357:	b8 06 00 00 00       	mov    $0x6,%eax
  80135c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80135f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801362:	8b 55 08             	mov    0x8(%ebp),%edx
  801365:	51                   	push   %ecx
  801366:	52                   	push   %edx
  801367:	53                   	push   %ebx
  801368:	54                   	push   %esp
  801369:	55                   	push   %ebp
  80136a:	56                   	push   %esi
  80136b:	57                   	push   %edi
  80136c:	54                   	push   %esp
  80136d:	5d                   	pop    %ebp
  80136e:	8d 35 76 13 80 00    	lea    0x801376,%esi
  801374:	0f 34                	sysenter 
  801376:	5f                   	pop    %edi
  801377:	5e                   	pop    %esi
  801378:	5d                   	pop    %ebp
  801379:	5c                   	pop    %esp
  80137a:	5b                   	pop    %ebx
  80137b:	5a                   	pop    %edx
  80137c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80137d:	85 c0                	test   %eax,%eax
  80137f:	7e 28                	jle    8013a9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801381:	89 44 24 10          	mov    %eax,0x10(%esp)
  801385:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80138c:	00 
  80138d:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  801394:	00 
  801395:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80139c:	00 
  80139d:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  8013a4:	e8 fb ed ff ff       	call   8001a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8013a9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013af:	89 ec                	mov    %ebp,%esp
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	83 ec 28             	sub    $0x28,%esp
  8013b9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013bc:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8013c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013cf:	8b 55 08             	mov    0x8(%ebp),%edx
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	7e 28                	jle    801416 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013f9:	00 
  8013fa:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  801401:	00 
  801402:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801409:	00 
  80140a:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  801411:	e8 8e ed ff ff       	call   8001a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801416:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801419:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80141c:	89 ec                	mov    %ebp,%esp
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
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
  80142d:	ba 00 00 00 00       	mov    $0x0,%edx
  801432:	b8 0c 00 00 00       	mov    $0xc,%eax
  801437:	89 d1                	mov    %edx,%ecx
  801439:	89 d3                	mov    %edx,%ebx
  80143b:	89 d7                	mov    %edx,%edi
  80143d:	51                   	push   %ecx
  80143e:	52                   	push   %edx
  80143f:	53                   	push   %ebx
  801440:	54                   	push   %esp
  801441:	55                   	push   %ebp
  801442:	56                   	push   %esi
  801443:	57                   	push   %edi
  801444:	54                   	push   %esp
  801445:	5d                   	pop    %ebp
  801446:	8d 35 4e 14 80 00    	lea    0x80144e,%esi
  80144c:	0f 34                	sysenter 
  80144e:	5f                   	pop    %edi
  80144f:	5e                   	pop    %esi
  801450:	5d                   	pop    %ebp
  801451:	5c                   	pop    %esp
  801452:	5b                   	pop    %ebx
  801453:	5a                   	pop    %edx
  801454:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801455:	8b 1c 24             	mov    (%esp),%ebx
  801458:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80145c:	89 ec                	mov    %ebp,%esp
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	89 1c 24             	mov    %ebx,(%esp)
  801469:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80146d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801472:	b8 04 00 00 00       	mov    $0x4,%eax
  801477:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147a:	8b 55 08             	mov    0x8(%ebp),%edx
  80147d:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801497:	8b 1c 24             	mov    (%esp),%ebx
  80149a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80149e:	89 ec                	mov    %ebp,%esp
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	89 1c 24             	mov    %ebx,(%esp)
  8014ab:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014af:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b9:	89 d1                	mov    %edx,%ecx
  8014bb:	89 d3                	mov    %edx,%ebx
  8014bd:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014d7:	8b 1c 24             	mov    (%esp),%ebx
  8014da:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014de:	89 ec                	mov    %ebp,%esp
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	83 ec 28             	sub    $0x28,%esp
  8014e8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014eb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fb:	89 cb                	mov    %ecx,%ebx
  8014fd:	89 cf                	mov    %ecx,%edi
  8014ff:	51                   	push   %ecx
  801500:	52                   	push   %edx
  801501:	53                   	push   %ebx
  801502:	54                   	push   %esp
  801503:	55                   	push   %ebp
  801504:	56                   	push   %esi
  801505:	57                   	push   %edi
  801506:	54                   	push   %esp
  801507:	5d                   	pop    %ebp
  801508:	8d 35 10 15 80 00    	lea    0x801510,%esi
  80150e:	0f 34                	sysenter 
  801510:	5f                   	pop    %edi
  801511:	5e                   	pop    %esi
  801512:	5d                   	pop    %ebp
  801513:	5c                   	pop    %esp
  801514:	5b                   	pop    %ebx
  801515:	5a                   	pop    %edx
  801516:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801517:	85 c0                	test   %eax,%eax
  801519:	7e 28                	jle    801543 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80151b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80151f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801526:	00 
  801527:	c7 44 24 08 00 2a 80 	movl   $0x802a00,0x8(%esp)
  80152e:	00 
  80152f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801536:	00 
  801537:	c7 04 24 1d 2a 80 00 	movl   $0x802a1d,(%esp)
  80153e:	e8 61 ec ff ff       	call   8001a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801543:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801546:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801549:	89 ec                	mov    %ebp,%esp
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    
  80154d:	00 00                	add    %al,(%eax)
	...

00801550 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801556:	c7 44 24 08 2b 2a 80 	movl   $0x802a2b,0x8(%esp)
  80155d:	00 
  80155e:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801565:	00 
  801566:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  80156d:	e8 32 ec ff ff       	call   8001a4 <_panic>

00801572 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	57                   	push   %edi
  801576:	56                   	push   %esi
  801577:	53                   	push   %ebx
  801578:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80157b:	c7 04 24 c7 17 80 00 	movl   $0x8017c7,(%esp)
  801582:	e8 3d 0c 00 00       	call   8021c4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801587:	ba 08 00 00 00       	mov    $0x8,%edx
  80158c:	89 d0                	mov    %edx,%eax
  80158e:	cd 30                	int    $0x30
  801590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801593:	85 c0                	test   %eax,%eax
  801595:	79 20                	jns    8015b7 <fork+0x45>
		panic("sys_exofork: %e", envid);
  801597:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80159b:	c7 44 24 08 4c 2a 80 	movl   $0x802a4c,0x8(%esp)
  8015a2:	00 
  8015a3:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8015aa:	00 
  8015ab:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  8015b2:	e8 ed eb ff ff       	call   8001a4 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8015b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8015bc:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8015c1:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8015c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8015ca:	75 20                	jne    8015ec <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8015cc:	e8 d1 fe ff ff       	call   8014a2 <sys_getenvid>
  8015d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015d6:	89 c2                	mov    %eax,%edx
  8015d8:	c1 e2 07             	shl    $0x7,%edx
  8015db:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8015e2:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8015e7:	e9 d0 01 00 00       	jmp    8017bc <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8015ec:	89 d8                	mov    %ebx,%eax
  8015ee:	c1 e8 16             	shr    $0x16,%eax
  8015f1:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8015f4:	a8 01                	test   $0x1,%al
  8015f6:	0f 84 0d 01 00 00    	je     801709 <fork+0x197>
  8015fc:	89 d8                	mov    %ebx,%eax
  8015fe:	c1 e8 0c             	shr    $0xc,%eax
  801601:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801604:	f6 c2 01             	test   $0x1,%dl
  801607:	0f 84 fc 00 00 00    	je     801709 <fork+0x197>
  80160d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801610:	f6 c2 04             	test   $0x4,%dl
  801613:	0f 84 f0 00 00 00    	je     801709 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  801619:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	c1 ea 0c             	shr    $0xc,%edx
  801621:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801624:	f6 c2 01             	test   $0x1,%dl
  801627:	0f 84 dc 00 00 00    	je     801709 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  80162d:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801633:	0f 84 8d 00 00 00    	je     8016c6 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  801639:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80163c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801643:	00 
  801644:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801648:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80164b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80164f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801653:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165a:	e8 e6 fc ff ff       	call   801345 <sys_page_map>
               if(r<0)
  80165f:	85 c0                	test   %eax,%eax
  801661:	79 1c                	jns    80167f <fork+0x10d>
                 panic("map failed");
  801663:	c7 44 24 08 5c 2a 80 	movl   $0x802a5c,0x8(%esp)
  80166a:	00 
  80166b:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801672:	00 
  801673:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  80167a:	e8 25 eb ff ff       	call   8001a4 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  80167f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801686:	00 
  801687:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80168a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80168e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801695:	00 
  801696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a1:	e8 9f fc ff ff       	call   801345 <sys_page_map>
               if(r<0)
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	79 5f                	jns    801709 <fork+0x197>
                 panic("map failed");
  8016aa:	c7 44 24 08 5c 2a 80 	movl   $0x802a5c,0x8(%esp)
  8016b1:	00 
  8016b2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8016b9:	00 
  8016ba:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  8016c1:	e8 de ea ff ff       	call   8001a4 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  8016c6:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8016cd:	00 
  8016ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e4:	e8 5c fc ff ff       	call   801345 <sys_page_map>
               if(r<0)
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	79 1c                	jns    801709 <fork+0x197>
                 panic("map failed");
  8016ed:	c7 44 24 08 5c 2a 80 	movl   $0x802a5c,0x8(%esp)
  8016f4:	00 
  8016f5:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8016fc:	00 
  8016fd:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  801704:	e8 9b ea ff ff       	call   8001a4 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801709:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80170f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801715:	0f 85 d1 fe ff ff    	jne    8015ec <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80171b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801722:	00 
  801723:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80172a:	ee 
  80172b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172e:	89 04 24             	mov    %eax,(%esp)
  801731:	e8 7d fc ff ff       	call   8013b3 <sys_page_alloc>
        if(r < 0)
  801736:	85 c0                	test   %eax,%eax
  801738:	79 1c                	jns    801756 <fork+0x1e4>
            panic("alloc failed");
  80173a:	c7 44 24 08 67 2a 80 	movl   $0x802a67,0x8(%esp)
  801741:	00 
  801742:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801749:	00 
  80174a:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  801751:	e8 4e ea ff ff       	call   8001a4 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801756:	c7 44 24 04 10 22 80 	movl   $0x802210,0x4(%esp)
  80175d:	00 
  80175e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801761:	89 14 24             	mov    %edx,(%esp)
  801764:	e8 2c fa ff ff       	call   801195 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801769:	85 c0                	test   %eax,%eax
  80176b:	79 1c                	jns    801789 <fork+0x217>
            panic("set pgfault upcall failed");
  80176d:	c7 44 24 08 74 2a 80 	movl   $0x802a74,0x8(%esp)
  801774:	00 
  801775:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80177c:	00 
  80177d:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  801784:	e8 1b ea ff ff       	call   8001a4 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801789:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801790:	00 
  801791:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801794:	89 04 24             	mov    %eax,(%esp)
  801797:	e8 d1 fa ff ff       	call   80126d <sys_env_set_status>
        if(r < 0)
  80179c:	85 c0                	test   %eax,%eax
  80179e:	79 1c                	jns    8017bc <fork+0x24a>
            panic("set status failed");
  8017a0:	c7 44 24 08 8e 2a 80 	movl   $0x802a8e,0x8(%esp)
  8017a7:	00 
  8017a8:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8017af:	00 
  8017b0:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  8017b7:	e8 e8 e9 ff ff       	call   8001a4 <_panic>
        return envid;
	//panic("fork not implemented");
}
  8017bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017bf:	83 c4 3c             	add    $0x3c,%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5f                   	pop    %edi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 24             	sub    $0x24,%esp
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017d1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  8017d3:	89 da                	mov    %ebx,%edx
  8017d5:	c1 ea 0c             	shr    $0xc,%edx
  8017d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8017df:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017e3:	74 08                	je     8017ed <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  8017e5:	f7 c2 05 08 00 00    	test   $0x805,%edx
  8017eb:	75 1c                	jne    801809 <pgfault+0x42>
           panic("pgfault error");
  8017ed:	c7 44 24 08 a0 2a 80 	movl   $0x802aa0,0x8(%esp)
  8017f4:	00 
  8017f5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8017fc:	00 
  8017fd:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  801804:	e8 9b e9 ff ff       	call   8001a4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801809:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801810:	00 
  801811:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801818:	00 
  801819:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801820:	e8 8e fb ff ff       	call   8013b3 <sys_page_alloc>
  801825:	85 c0                	test   %eax,%eax
  801827:	79 20                	jns    801849 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  801829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80182d:	c7 44 24 08 ae 2a 80 	movl   $0x802aae,0x8(%esp)
  801834:	00 
  801835:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80183c:	00 
  80183d:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  801844:	e8 5b e9 ff ff       	call   8001a4 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  801849:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80184f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801856:	00 
  801857:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80185b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801862:	e8 0e f5 ff ff       	call   800d75 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801867:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80186e:	00 
  80186f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801873:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80187a:	00 
  80187b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801882:	00 
  801883:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80188a:	e8 b6 fa ff ff       	call   801345 <sys_page_map>
  80188f:	85 c0                	test   %eax,%eax
  801891:	79 20                	jns    8018b3 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801893:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801897:	c7 44 24 08 c1 2a 80 	movl   $0x802ac1,0x8(%esp)
  80189e:	00 
  80189f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8018a6:	00 
  8018a7:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  8018ae:	e8 f1 e8 ff ff       	call   8001a4 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8018b3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018ba:	00 
  8018bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c2:	e8 12 fa ff ff       	call   8012d9 <sys_page_unmap>
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	79 20                	jns    8018eb <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  8018cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018cf:	c7 44 24 08 d2 2a 80 	movl   $0x802ad2,0x8(%esp)
  8018d6:	00 
  8018d7:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8018de:	00 
  8018df:	c7 04 24 41 2a 80 00 	movl   $0x802a41,(%esp)
  8018e6:	e8 b9 e8 ff ff       	call   8001a4 <_panic>
	//panic("pgfault not implemented");
}
  8018eb:	83 c4 24             	add    $0x24,%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5d                   	pop    %ebp
  8018f0:	c3                   	ret    
	...

00801900 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	8b 45 08             	mov    0x8(%ebp),%eax
  801906:	05 00 00 00 30       	add    $0x30000000,%eax
  80190b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	89 04 24             	mov    %eax,(%esp)
  80191c:	e8 df ff ff ff       	call   801900 <fd2num>
  801921:	05 20 00 0d 00       	add    $0xd0020,%eax
  801926:	c1 e0 0c             	shl    $0xc,%eax
}
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	57                   	push   %edi
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801934:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801939:	a8 01                	test   $0x1,%al
  80193b:	74 36                	je     801973 <fd_alloc+0x48>
  80193d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801942:	a8 01                	test   $0x1,%al
  801944:	74 2d                	je     801973 <fd_alloc+0x48>
  801946:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80194b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801950:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801955:	89 c3                	mov    %eax,%ebx
  801957:	89 c2                	mov    %eax,%edx
  801959:	c1 ea 16             	shr    $0x16,%edx
  80195c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80195f:	f6 c2 01             	test   $0x1,%dl
  801962:	74 14                	je     801978 <fd_alloc+0x4d>
  801964:	89 c2                	mov    %eax,%edx
  801966:	c1 ea 0c             	shr    $0xc,%edx
  801969:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80196c:	f6 c2 01             	test   $0x1,%dl
  80196f:	75 10                	jne    801981 <fd_alloc+0x56>
  801971:	eb 05                	jmp    801978 <fd_alloc+0x4d>
  801973:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801978:	89 1f                	mov    %ebx,(%edi)
  80197a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80197f:	eb 17                	jmp    801998 <fd_alloc+0x6d>
  801981:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801986:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80198b:	75 c8                	jne    801955 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80198d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801993:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801998:	5b                   	pop    %ebx
  801999:	5e                   	pop    %esi
  80199a:	5f                   	pop    %edi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	83 f8 1f             	cmp    $0x1f,%eax
  8019a6:	77 36                	ja     8019de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019a8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8019ad:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8019b0:	89 c2                	mov    %eax,%edx
  8019b2:	c1 ea 16             	shr    $0x16,%edx
  8019b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019bc:	f6 c2 01             	test   $0x1,%dl
  8019bf:	74 1d                	je     8019de <fd_lookup+0x41>
  8019c1:	89 c2                	mov    %eax,%edx
  8019c3:	c1 ea 0c             	shr    $0xc,%edx
  8019c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019cd:	f6 c2 01             	test   $0x1,%dl
  8019d0:	74 0c                	je     8019de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8019d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d5:	89 02                	mov    %eax,(%edx)
  8019d7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8019dc:	eb 05                	jmp    8019e3 <fd_lookup+0x46>
  8019de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019eb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f5:	89 04 24             	mov    %eax,(%esp)
  8019f8:	e8 a0 ff ff ff       	call   80199d <fd_lookup>
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 0e                	js     801a0f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a07:	89 50 04             	mov    %edx,0x4(%eax)
  801a0a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 10             	sub    $0x10,%esp
  801a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801a1f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a29:	be 68 2b 80 00       	mov    $0x802b68,%esi
		if (devtab[i]->dev_id == dev_id) {
  801a2e:	39 08                	cmp    %ecx,(%eax)
  801a30:	75 10                	jne    801a42 <dev_lookup+0x31>
  801a32:	eb 04                	jmp    801a38 <dev_lookup+0x27>
  801a34:	39 08                	cmp    %ecx,(%eax)
  801a36:	75 0a                	jne    801a42 <dev_lookup+0x31>
			*dev = devtab[i];
  801a38:	89 03                	mov    %eax,(%ebx)
  801a3a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801a3f:	90                   	nop
  801a40:	eb 31                	jmp    801a73 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a42:	83 c2 01             	add    $0x1,%edx
  801a45:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	75 e8                	jne    801a34 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a4c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a51:	8b 40 48             	mov    0x48(%eax),%eax
  801a54:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5c:	c7 04 24 e8 2a 80 00 	movl   $0x802ae8,(%esp)
  801a63:	e8 f5 e7 ff ff       	call   80025d <cprintf>
	*dev = 0;
  801a68:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    

00801a7a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	53                   	push   %ebx
  801a7e:	83 ec 24             	sub    $0x24,%esp
  801a81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	89 04 24             	mov    %eax,(%esp)
  801a91:	e8 07 ff ff ff       	call   80199d <fd_lookup>
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 53                	js     801aed <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa4:	8b 00                	mov    (%eax),%eax
  801aa6:	89 04 24             	mov    %eax,(%esp)
  801aa9:	e8 63 ff ff ff       	call   801a11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 3b                	js     801aed <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801ab2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ab7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aba:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801abe:	74 2d                	je     801aed <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ac0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ac3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801aca:	00 00 00 
	stat->st_isdir = 0;
  801acd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad4:	00 00 00 
	stat->st_dev = dev;
  801ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ada:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ae0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ae7:	89 14 24             	mov    %edx,(%esp)
  801aea:	ff 50 14             	call   *0x14(%eax)
}
  801aed:	83 c4 24             	add    $0x24,%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	53                   	push   %ebx
  801af7:	83 ec 24             	sub    $0x24,%esp
  801afa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801afd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b04:	89 1c 24             	mov    %ebx,(%esp)
  801b07:	e8 91 fe ff ff       	call   80199d <fd_lookup>
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 5f                	js     801b6f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1a:	8b 00                	mov    (%eax),%eax
  801b1c:	89 04 24             	mov    %eax,(%esp)
  801b1f:	e8 ed fe ff ff       	call   801a11 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 47                	js     801b6f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b2b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801b2f:	75 23                	jne    801b54 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b31:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b36:	8b 40 48             	mov    0x48(%eax),%eax
  801b39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b41:	c7 04 24 08 2b 80 00 	movl   $0x802b08,(%esp)
  801b48:	e8 10 e7 ff ff       	call   80025d <cprintf>
  801b4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b52:	eb 1b                	jmp    801b6f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b57:	8b 48 18             	mov    0x18(%eax),%ecx
  801b5a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b5f:	85 c9                	test   %ecx,%ecx
  801b61:	74 0c                	je     801b6f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6a:	89 14 24             	mov    %edx,(%esp)
  801b6d:	ff d1                	call   *%ecx
}
  801b6f:	83 c4 24             	add    $0x24,%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	53                   	push   %ebx
  801b79:	83 ec 24             	sub    $0x24,%esp
  801b7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b86:	89 1c 24             	mov    %ebx,(%esp)
  801b89:	e8 0f fe ff ff       	call   80199d <fd_lookup>
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 66                	js     801bf8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9c:	8b 00                	mov    (%eax),%eax
  801b9e:	89 04 24             	mov    %eax,(%esp)
  801ba1:	e8 6b fe ff ff       	call   801a11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 4e                	js     801bf8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801baa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bad:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801bb1:	75 23                	jne    801bd6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801bb3:	a1 08 40 80 00       	mov    0x804008,%eax
  801bb8:	8b 40 48             	mov    0x48(%eax),%eax
  801bbb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc3:	c7 04 24 2c 2b 80 00 	movl   $0x802b2c,(%esp)
  801bca:	e8 8e e6 ff ff       	call   80025d <cprintf>
  801bcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801bd4:	eb 22                	jmp    801bf8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd9:	8b 48 0c             	mov    0xc(%eax),%ecx
  801bdc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801be1:	85 c9                	test   %ecx,%ecx
  801be3:	74 13                	je     801bf8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801be5:	8b 45 10             	mov    0x10(%ebp),%eax
  801be8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf3:	89 14 24             	mov    %edx,(%esp)
  801bf6:	ff d1                	call   *%ecx
}
  801bf8:	83 c4 24             	add    $0x24,%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	53                   	push   %ebx
  801c02:	83 ec 24             	sub    $0x24,%esp
  801c05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0f:	89 1c 24             	mov    %ebx,(%esp)
  801c12:	e8 86 fd ff ff       	call   80199d <fd_lookup>
  801c17:	85 c0                	test   %eax,%eax
  801c19:	78 6b                	js     801c86 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c25:	8b 00                	mov    (%eax),%eax
  801c27:	89 04 24             	mov    %eax,(%esp)
  801c2a:	e8 e2 fd ff ff       	call   801a11 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 53                	js     801c86 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c33:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c36:	8b 42 08             	mov    0x8(%edx),%eax
  801c39:	83 e0 03             	and    $0x3,%eax
  801c3c:	83 f8 01             	cmp    $0x1,%eax
  801c3f:	75 23                	jne    801c64 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c41:	a1 08 40 80 00       	mov    0x804008,%eax
  801c46:	8b 40 48             	mov    0x48(%eax),%eax
  801c49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c51:	c7 04 24 49 2b 80 00 	movl   $0x802b49,(%esp)
  801c58:	e8 00 e6 ff ff       	call   80025d <cprintf>
  801c5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801c62:	eb 22                	jmp    801c86 <read+0x88>
	}
	if (!dev->dev_read)
  801c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c67:	8b 48 08             	mov    0x8(%eax),%ecx
  801c6a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c6f:	85 c9                	test   %ecx,%ecx
  801c71:	74 13                	je     801c86 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c73:	8b 45 10             	mov    0x10(%ebp),%eax
  801c76:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c81:	89 14 24             	mov    %edx,(%esp)
  801c84:	ff d1                	call   *%ecx
}
  801c86:	83 c4 24             	add    $0x24,%esp
  801c89:	5b                   	pop    %ebx
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    

00801c8c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	57                   	push   %edi
  801c90:	56                   	push   %esi
  801c91:	53                   	push   %ebx
  801c92:	83 ec 1c             	sub    $0x1c,%esp
  801c95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c98:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  801caa:	85 f6                	test   %esi,%esi
  801cac:	74 29                	je     801cd7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801cae:	89 f0                	mov    %esi,%eax
  801cb0:	29 d0                	sub    %edx,%eax
  801cb2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb6:	03 55 0c             	add    0xc(%ebp),%edx
  801cb9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cbd:	89 3c 24             	mov    %edi,(%esp)
  801cc0:	e8 39 ff ff ff       	call   801bfe <read>
		if (m < 0)
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 0e                	js     801cd7 <readn+0x4b>
			return m;
		if (m == 0)
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	74 08                	je     801cd5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ccd:	01 c3                	add    %eax,%ebx
  801ccf:	89 da                	mov    %ebx,%edx
  801cd1:	39 f3                	cmp    %esi,%ebx
  801cd3:	72 d9                	jb     801cae <readn+0x22>
  801cd5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801cd7:	83 c4 1c             	add    $0x1c,%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5f                   	pop    %edi
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 20             	sub    $0x20,%esp
  801ce7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cea:	89 34 24             	mov    %esi,(%esp)
  801ced:	e8 0e fc ff ff       	call   801900 <fd2num>
  801cf2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cf5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cf9:	89 04 24             	mov    %eax,(%esp)
  801cfc:	e8 9c fc ff ff       	call   80199d <fd_lookup>
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 05                	js     801d0c <fd_close+0x2d>
  801d07:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d0a:	74 0c                	je     801d18 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801d0c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801d10:	19 c0                	sbb    %eax,%eax
  801d12:	f7 d0                	not    %eax
  801d14:	21 c3                	and    %eax,%ebx
  801d16:	eb 3d                	jmp    801d55 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1f:	8b 06                	mov    (%esi),%eax
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 e8 fc ff ff       	call   801a11 <dev_lookup>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	78 16                	js     801d45 <fd_close+0x66>
		if (dev->dev_close)
  801d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d32:	8b 40 10             	mov    0x10(%eax),%eax
  801d35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	74 07                	je     801d45 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801d3e:	89 34 24             	mov    %esi,(%esp)
  801d41:	ff d0                	call   *%eax
  801d43:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d50:	e8 84 f5 ff ff       	call   8012d9 <sys_page_unmap>
	return r;
}
  801d55:	89 d8                	mov    %ebx,%eax
  801d57:	83 c4 20             	add    $0x20,%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 27 fc ff ff       	call   80199d <fd_lookup>
  801d76:	85 c0                	test   %eax,%eax
  801d78:	78 13                	js     801d8d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801d7a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d81:	00 
  801d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d85:	89 04 24             	mov    %eax,(%esp)
  801d88:	e8 52 ff ff ff       	call   801cdf <fd_close>
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	83 ec 18             	sub    $0x18,%esp
  801d95:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d98:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801da2:	00 
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	89 04 24             	mov    %eax,(%esp)
  801da9:	e8 79 03 00 00       	call   802127 <open>
  801dae:	89 c3                	mov    %eax,%ebx
  801db0:	85 c0                	test   %eax,%eax
  801db2:	78 1b                	js     801dcf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801db4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dbb:	89 1c 24             	mov    %ebx,(%esp)
  801dbe:	e8 b7 fc ff ff       	call   801a7a <fstat>
  801dc3:	89 c6                	mov    %eax,%esi
	close(fd);
  801dc5:	89 1c 24             	mov    %ebx,(%esp)
  801dc8:	e8 91 ff ff ff       	call   801d5e <close>
  801dcd:	89 f3                	mov    %esi,%ebx
	return r;
}
  801dcf:	89 d8                	mov    %ebx,%eax
  801dd1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801dd4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801dd7:	89 ec                	mov    %ebp,%esp
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	53                   	push   %ebx
  801ddf:	83 ec 14             	sub    $0x14,%esp
  801de2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801de7:	89 1c 24             	mov    %ebx,(%esp)
  801dea:	e8 6f ff ff ff       	call   801d5e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801def:	83 c3 01             	add    $0x1,%ebx
  801df2:	83 fb 20             	cmp    $0x20,%ebx
  801df5:	75 f0                	jne    801de7 <close_all+0xc>
		close(i);
}
  801df7:	83 c4 14             	add    $0x14,%esp
  801dfa:	5b                   	pop    %ebx
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	83 ec 58             	sub    $0x58,%esp
  801e03:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801e06:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801e09:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801e0c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	89 04 24             	mov    %eax,(%esp)
  801e1c:	e8 7c fb ff ff       	call   80199d <fd_lookup>
  801e21:	89 c3                	mov    %eax,%ebx
  801e23:	85 c0                	test   %eax,%eax
  801e25:	0f 88 e0 00 00 00    	js     801f0b <dup+0x10e>
		return r;
	close(newfdnum);
  801e2b:	89 3c 24             	mov    %edi,(%esp)
  801e2e:	e8 2b ff ff ff       	call   801d5e <close>

	newfd = INDEX2FD(newfdnum);
  801e33:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801e39:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e3f:	89 04 24             	mov    %eax,(%esp)
  801e42:	e8 c9 fa ff ff       	call   801910 <fd2data>
  801e47:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e49:	89 34 24             	mov    %esi,(%esp)
  801e4c:	e8 bf fa ff ff       	call   801910 <fd2data>
  801e51:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801e54:	89 da                	mov    %ebx,%edx
  801e56:	89 d8                	mov    %ebx,%eax
  801e58:	c1 e8 16             	shr    $0x16,%eax
  801e5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e62:	a8 01                	test   $0x1,%al
  801e64:	74 43                	je     801ea9 <dup+0xac>
  801e66:	c1 ea 0c             	shr    $0xc,%edx
  801e69:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e70:	a8 01                	test   $0x1,%al
  801e72:	74 35                	je     801ea9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e74:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e7b:	25 07 0e 00 00       	and    $0xe07,%eax
  801e80:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e84:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e92:	00 
  801e93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e9e:	e8 a2 f4 ff ff       	call   801345 <sys_page_map>
  801ea3:	89 c3                	mov    %eax,%ebx
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	78 3f                	js     801ee8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eac:	89 c2                	mov    %eax,%edx
  801eae:	c1 ea 0c             	shr    $0xc,%edx
  801eb1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801eb8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ebe:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ec2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ec6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ecd:	00 
  801ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed9:	e8 67 f4 ff ff       	call   801345 <sys_page_map>
  801ede:	89 c3                	mov    %eax,%ebx
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 04                	js     801ee8 <dup+0xeb>
  801ee4:	89 fb                	mov    %edi,%ebx
  801ee6:	eb 23                	jmp    801f0b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ee8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef3:	e8 e1 f3 ff ff       	call   8012d9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ef8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801efb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f06:	e8 ce f3 ff ff       	call   8012d9 <sys_page_unmap>
	return r;
}
  801f0b:	89 d8                	mov    %ebx,%eax
  801f0d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801f10:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801f13:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801f16:	89 ec                	mov    %ebp,%esp
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    
	...

00801f1c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 18             	sub    $0x18,%esp
  801f22:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f25:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f28:	89 c3                	mov    %eax,%ebx
  801f2a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801f2c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801f33:	75 11                	jne    801f46 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f35:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f3c:	e8 ff 02 00 00       	call   802240 <ipc_find_env>
  801f41:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f46:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f4d:	00 
  801f4e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801f55:	00 
  801f56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f5a:	a1 00 40 80 00       	mov    0x804000,%eax
  801f5f:	89 04 24             	mov    %eax,(%esp)
  801f62:	e8 24 03 00 00       	call   80228b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f6e:	00 
  801f6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f7a:	e8 8a 03 00 00       	call   802309 <ipc_recv>
}
  801f7f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f82:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f85:	89 ec                	mov    %ebp,%esp
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    

00801f89 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f92:	8b 40 0c             	mov    0xc(%eax),%eax
  801f95:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801fa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa7:	b8 02 00 00 00       	mov    $0x2,%eax
  801fac:	e8 6b ff ff ff       	call   801f1c <fsipc>
}
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    

00801fb3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbc:	8b 40 0c             	mov    0xc(%eax),%eax
  801fbf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc9:	b8 06 00 00 00       	mov    $0x6,%eax
  801fce:	e8 49 ff ff ff       	call   801f1c <fsipc>
}
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801fe0:	b8 08 00 00 00       	mov    $0x8,%eax
  801fe5:	e8 32 ff ff ff       	call   801f1c <fsipc>
}
  801fea:	c9                   	leave  
  801feb:	c3                   	ret    

00801fec <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	53                   	push   %ebx
  801ff0:	83 ec 14             	sub    $0x14,%esp
  801ff3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff9:	8b 40 0c             	mov    0xc(%eax),%eax
  801ffc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802001:	ba 00 00 00 00       	mov    $0x0,%edx
  802006:	b8 05 00 00 00       	mov    $0x5,%eax
  80200b:	e8 0c ff ff ff       	call   801f1c <fsipc>
  802010:	85 c0                	test   %eax,%eax
  802012:	78 2b                	js     80203f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802014:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80201b:	00 
  80201c:	89 1c 24             	mov    %ebx,(%esp)
  80201f:	e8 66 eb ff ff       	call   800b8a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802024:	a1 80 50 80 00       	mov    0x805080,%eax
  802029:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80202f:	a1 84 50 80 00       	mov    0x805084,%eax
  802034:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80203a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80203f:	83 c4 14             	add    $0x14,%esp
  802042:	5b                   	pop    %ebx
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 18             	sub    $0x18,%esp
  80204b:	8b 45 10             	mov    0x10(%ebp),%eax
  80204e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802053:	76 05                	jbe    80205a <devfile_write+0x15>
  802055:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  80205a:	8b 55 08             	mov    0x8(%ebp),%edx
  80205d:	8b 52 0c             	mov    0xc(%edx),%edx
  802060:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  802066:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  80206b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80206f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802072:	89 44 24 04          	mov    %eax,0x4(%esp)
  802076:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80207d:	e8 f3 ec ff ff       	call   800d75 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  802082:	ba 00 00 00 00       	mov    $0x0,%edx
  802087:	b8 04 00 00 00       	mov    $0x4,%eax
  80208c:	e8 8b fe ff ff       	call   801f1c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802091:	c9                   	leave  
  802092:	c3                   	ret    

00802093 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	53                   	push   %ebx
  802097:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80209a:	8b 45 08             	mov    0x8(%ebp),%eax
  80209d:	8b 40 0c             	mov    0xc(%eax),%eax
  8020a0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  8020a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8020a8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  8020ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8020b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8020b7:	e8 60 fe ff ff       	call   801f1c <fsipc>
  8020bc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8020be:	85 c0                	test   %eax,%eax
  8020c0:	78 17                	js     8020d9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  8020c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8020cd:	00 
  8020ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d1:	89 04 24             	mov    %eax,(%esp)
  8020d4:	e8 9c ec ff ff       	call   800d75 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  8020d9:	89 d8                	mov    %ebx,%eax
  8020db:	83 c4 14             	add    $0x14,%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5d                   	pop    %ebp
  8020e0:	c3                   	ret    

008020e1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8020e1:	55                   	push   %ebp
  8020e2:	89 e5                	mov    %esp,%ebp
  8020e4:	53                   	push   %ebx
  8020e5:	83 ec 14             	sub    $0x14,%esp
  8020e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8020eb:	89 1c 24             	mov    %ebx,(%esp)
  8020ee:	e8 4d ea ff ff       	call   800b40 <strlen>
  8020f3:	89 c2                	mov    %eax,%edx
  8020f5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8020fa:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802100:	7f 1f                	jg     802121 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802102:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802106:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80210d:	e8 78 ea ff ff       	call   800b8a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802112:	ba 00 00 00 00       	mov    $0x0,%edx
  802117:	b8 07 00 00 00       	mov    $0x7,%eax
  80211c:	e8 fb fd ff ff       	call   801f1c <fsipc>
}
  802121:	83 c4 14             	add    $0x14,%esp
  802124:	5b                   	pop    %ebx
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    

00802127 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	83 ec 28             	sub    $0x28,%esp
  80212d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802130:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802133:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802136:	89 34 24             	mov    %esi,(%esp)
  802139:	e8 02 ea ff ff       	call   800b40 <strlen>
  80213e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802143:	3d 00 04 00 00       	cmp    $0x400,%eax
  802148:	7f 6d                	jg     8021b7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80214a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80214d:	89 04 24             	mov    %eax,(%esp)
  802150:	e8 d6 f7 ff ff       	call   80192b <fd_alloc>
  802155:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  802157:	85 c0                	test   %eax,%eax
  802159:	78 5c                	js     8021b7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80215b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  802163:	89 34 24             	mov    %esi,(%esp)
  802166:	e8 d5 e9 ff ff       	call   800b40 <strlen>
  80216b:	83 c0 01             	add    $0x1,%eax
  80216e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802172:	89 74 24 04          	mov    %esi,0x4(%esp)
  802176:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80217d:	e8 f3 eb ff ff       	call   800d75 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  802182:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802185:	b8 01 00 00 00       	mov    $0x1,%eax
  80218a:	e8 8d fd ff ff       	call   801f1c <fsipc>
  80218f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802191:	85 c0                	test   %eax,%eax
  802193:	79 15                	jns    8021aa <open+0x83>
             fd_close(fd,0);
  802195:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80219c:	00 
  80219d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a0:	89 04 24             	mov    %eax,(%esp)
  8021a3:	e8 37 fb ff ff       	call   801cdf <fd_close>
             return r;
  8021a8:	eb 0d                	jmp    8021b7 <open+0x90>
        }
        return fd2num(fd);
  8021aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ad:	89 04 24             	mov    %eax,(%esp)
  8021b0:	e8 4b f7 ff ff       	call   801900 <fd2num>
  8021b5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8021b7:	89 d8                	mov    %ebx,%eax
  8021b9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8021bc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021bf:	89 ec                	mov    %ebp,%esp
  8021c1:	5d                   	pop    %ebp
  8021c2:	c3                   	ret    
	...

008021c4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021ca:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021d1:	75 30                	jne    802203 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8021d3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021da:	00 
  8021db:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021e2:	ee 
  8021e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ea:	e8 c4 f1 ff ff       	call   8013b3 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8021ef:	c7 44 24 04 10 22 80 	movl   $0x802210,0x4(%esp)
  8021f6:	00 
  8021f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021fe:	e8 92 ef ff ff       	call   801195 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
  802206:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80220b:	c9                   	leave  
  80220c:	c3                   	ret    
  80220d:	00 00                	add    %al,(%eax)
	...

00802210 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802210:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802211:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802216:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802218:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  80221b:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  80221f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  802223:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  802226:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802228:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  80222c:	83 c4 08             	add    $0x8,%esp
        popal
  80222f:	61                   	popa   
        addl $0x4,%esp
  802230:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  802233:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802234:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802235:	c3                   	ret    
	...

00802240 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802246:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80224c:	b8 01 00 00 00       	mov    $0x1,%eax
  802251:	39 ca                	cmp    %ecx,%edx
  802253:	75 04                	jne    802259 <ipc_find_env+0x19>
  802255:	b0 00                	mov    $0x0,%al
  802257:	eb 12                	jmp    80226b <ipc_find_env+0x2b>
  802259:	89 c2                	mov    %eax,%edx
  80225b:	c1 e2 07             	shl    $0x7,%edx
  80225e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802265:	8b 12                	mov    (%edx),%edx
  802267:	39 ca                	cmp    %ecx,%edx
  802269:	75 10                	jne    80227b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80226b:	89 c2                	mov    %eax,%edx
  80226d:	c1 e2 07             	shl    $0x7,%edx
  802270:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802277:	8b 00                	mov    (%eax),%eax
  802279:	eb 0e                	jmp    802289 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80227b:	83 c0 01             	add    $0x1,%eax
  80227e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802283:	75 d4                	jne    802259 <ipc_find_env+0x19>
  802285:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802289:	5d                   	pop    %ebp
  80228a:	c3                   	ret    

0080228b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	57                   	push   %edi
  80228f:	56                   	push   %esi
  802290:	53                   	push   %ebx
  802291:	83 ec 1c             	sub    $0x1c,%esp
  802294:	8b 75 08             	mov    0x8(%ebp),%esi
  802297:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80229a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80229d:	85 db                	test   %ebx,%ebx
  80229f:	74 19                	je     8022ba <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8022a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8022a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022b0:	89 34 24             	mov    %esi,(%esp)
  8022b3:	e8 9c ee ff ff       	call   801154 <sys_ipc_try_send>
  8022b8:	eb 1b                	jmp    8022d5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8022ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8022bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022c1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8022c8:	ee 
  8022c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022cd:	89 34 24             	mov    %esi,(%esp)
  8022d0:	e8 7f ee ff ff       	call   801154 <sys_ipc_try_send>
           if(ret == 0)
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	74 28                	je     802301 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8022d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022dc:	74 1c                	je     8022fa <ipc_send+0x6f>
              panic("ipc send error");
  8022de:	c7 44 24 08 70 2b 80 	movl   $0x802b70,0x8(%esp)
  8022e5:	00 
  8022e6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8022ed:	00 
  8022ee:	c7 04 24 7f 2b 80 00 	movl   $0x802b7f,(%esp)
  8022f5:	e8 aa de ff ff       	call   8001a4 <_panic>
           sys_yield();
  8022fa:	e8 21 f1 ff ff       	call   801420 <sys_yield>
        }
  8022ff:	eb 9c                	jmp    80229d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    

00802309 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	56                   	push   %esi
  80230d:	53                   	push   %ebx
  80230e:	83 ec 10             	sub    $0x10,%esp
  802311:	8b 75 08             	mov    0x8(%ebp),%esi
  802314:	8b 45 0c             	mov    0xc(%ebp),%eax
  802317:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80231a:	85 c0                	test   %eax,%eax
  80231c:	75 0e                	jne    80232c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80231e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802325:	e8 bf ed ff ff       	call   8010e9 <sys_ipc_recv>
  80232a:	eb 08                	jmp    802334 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80232c:	89 04 24             	mov    %eax,(%esp)
  80232f:	e8 b5 ed ff ff       	call   8010e9 <sys_ipc_recv>
        if(ret == 0){
  802334:	85 c0                	test   %eax,%eax
  802336:	75 26                	jne    80235e <ipc_recv+0x55>
           if(from_env_store)
  802338:	85 f6                	test   %esi,%esi
  80233a:	74 0a                	je     802346 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80233c:	a1 08 40 80 00       	mov    0x804008,%eax
  802341:	8b 40 78             	mov    0x78(%eax),%eax
  802344:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802346:	85 db                	test   %ebx,%ebx
  802348:	74 0a                	je     802354 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80234a:	a1 08 40 80 00       	mov    0x804008,%eax
  80234f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802352:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802354:	a1 08 40 80 00       	mov    0x804008,%eax
  802359:	8b 40 74             	mov    0x74(%eax),%eax
  80235c:	eb 14                	jmp    802372 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80235e:	85 f6                	test   %esi,%esi
  802360:	74 06                	je     802368 <ipc_recv+0x5f>
              *from_env_store = 0;
  802362:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802368:	85 db                	test   %ebx,%ebx
  80236a:	74 06                	je     802372 <ipc_recv+0x69>
              *perm_store = 0;
  80236c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802372:	83 c4 10             	add    $0x10,%esp
  802375:	5b                   	pop    %ebx
  802376:	5e                   	pop    %esi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	00 00                	add    %al,(%eax)
  80237b:	00 00                	add    %al,(%eax)
  80237d:	00 00                	add    %al,(%eax)
	...

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	57                   	push   %edi
  802384:	56                   	push   %esi
  802385:	83 ec 10             	sub    $0x10,%esp
  802388:	8b 45 14             	mov    0x14(%ebp),%eax
  80238b:	8b 55 08             	mov    0x8(%ebp),%edx
  80238e:	8b 75 10             	mov    0x10(%ebp),%esi
  802391:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802394:	85 c0                	test   %eax,%eax
  802396:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802399:	75 35                	jne    8023d0 <__udivdi3+0x50>
  80239b:	39 fe                	cmp    %edi,%esi
  80239d:	77 61                	ja     802400 <__udivdi3+0x80>
  80239f:	85 f6                	test   %esi,%esi
  8023a1:	75 0b                	jne    8023ae <__udivdi3+0x2e>
  8023a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	f7 f6                	div    %esi
  8023ac:	89 c6                	mov    %eax,%esi
  8023ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8023b1:	31 d2                	xor    %edx,%edx
  8023b3:	89 f8                	mov    %edi,%eax
  8023b5:	f7 f6                	div    %esi
  8023b7:	89 c7                	mov    %eax,%edi
  8023b9:	89 c8                	mov    %ecx,%eax
  8023bb:	f7 f6                	div    %esi
  8023bd:	89 c1                	mov    %eax,%ecx
  8023bf:	89 fa                	mov    %edi,%edx
  8023c1:	89 c8                	mov    %ecx,%eax
  8023c3:	83 c4 10             	add    $0x10,%esp
  8023c6:	5e                   	pop    %esi
  8023c7:	5f                   	pop    %edi
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    
  8023ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d0:	39 f8                	cmp    %edi,%eax
  8023d2:	77 1c                	ja     8023f0 <__udivdi3+0x70>
  8023d4:	0f bd d0             	bsr    %eax,%edx
  8023d7:	83 f2 1f             	xor    $0x1f,%edx
  8023da:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8023dd:	75 39                	jne    802418 <__udivdi3+0x98>
  8023df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8023e2:	0f 86 a0 00 00 00    	jbe    802488 <__udivdi3+0x108>
  8023e8:	39 f8                	cmp    %edi,%eax
  8023ea:	0f 82 98 00 00 00    	jb     802488 <__udivdi3+0x108>
  8023f0:	31 ff                	xor    %edi,%edi
  8023f2:	31 c9                	xor    %ecx,%ecx
  8023f4:	89 c8                	mov    %ecx,%eax
  8023f6:	89 fa                	mov    %edi,%edx
  8023f8:	83 c4 10             	add    $0x10,%esp
  8023fb:	5e                   	pop    %esi
  8023fc:	5f                   	pop    %edi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    
  8023ff:	90                   	nop
  802400:	89 d1                	mov    %edx,%ecx
  802402:	89 fa                	mov    %edi,%edx
  802404:	89 c8                	mov    %ecx,%eax
  802406:	31 ff                	xor    %edi,%edi
  802408:	f7 f6                	div    %esi
  80240a:	89 c1                	mov    %eax,%ecx
  80240c:	89 fa                	mov    %edi,%edx
  80240e:	89 c8                	mov    %ecx,%eax
  802410:	83 c4 10             	add    $0x10,%esp
  802413:	5e                   	pop    %esi
  802414:	5f                   	pop    %edi
  802415:	5d                   	pop    %ebp
  802416:	c3                   	ret    
  802417:	90                   	nop
  802418:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80241c:	89 f2                	mov    %esi,%edx
  80241e:	d3 e0                	shl    %cl,%eax
  802420:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802423:	b8 20 00 00 00       	mov    $0x20,%eax
  802428:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80242b:	89 c1                	mov    %eax,%ecx
  80242d:	d3 ea                	shr    %cl,%edx
  80242f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802433:	0b 55 ec             	or     -0x14(%ebp),%edx
  802436:	d3 e6                	shl    %cl,%esi
  802438:	89 c1                	mov    %eax,%ecx
  80243a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80243d:	89 fe                	mov    %edi,%esi
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802445:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802448:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80244b:	d3 e7                	shl    %cl,%edi
  80244d:	89 c1                	mov    %eax,%ecx
  80244f:	d3 ea                	shr    %cl,%edx
  802451:	09 d7                	or     %edx,%edi
  802453:	89 f2                	mov    %esi,%edx
  802455:	89 f8                	mov    %edi,%eax
  802457:	f7 75 ec             	divl   -0x14(%ebp)
  80245a:	89 d6                	mov    %edx,%esi
  80245c:	89 c7                	mov    %eax,%edi
  80245e:	f7 65 e8             	mull   -0x18(%ebp)
  802461:	39 d6                	cmp    %edx,%esi
  802463:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802466:	72 30                	jb     802498 <__udivdi3+0x118>
  802468:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80246b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80246f:	d3 e2                	shl    %cl,%edx
  802471:	39 c2                	cmp    %eax,%edx
  802473:	73 05                	jae    80247a <__udivdi3+0xfa>
  802475:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802478:	74 1e                	je     802498 <__udivdi3+0x118>
  80247a:	89 f9                	mov    %edi,%ecx
  80247c:	31 ff                	xor    %edi,%edi
  80247e:	e9 71 ff ff ff       	jmp    8023f4 <__udivdi3+0x74>
  802483:	90                   	nop
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	31 ff                	xor    %edi,%edi
  80248a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80248f:	e9 60 ff ff ff       	jmp    8023f4 <__udivdi3+0x74>
  802494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802498:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80249b:	31 ff                	xor    %edi,%edi
  80249d:	89 c8                	mov    %ecx,%eax
  80249f:	89 fa                	mov    %edi,%edx
  8024a1:	83 c4 10             	add    $0x10,%esp
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
	...

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
  8024b3:	57                   	push   %edi
  8024b4:	56                   	push   %esi
  8024b5:	83 ec 20             	sub    $0x20,%esp
  8024b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8024bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8024c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024c4:	85 d2                	test   %edx,%edx
  8024c6:	89 c8                	mov    %ecx,%eax
  8024c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8024cb:	75 13                	jne    8024e0 <__umoddi3+0x30>
  8024cd:	39 f7                	cmp    %esi,%edi
  8024cf:	76 3f                	jbe    802510 <__umoddi3+0x60>
  8024d1:	89 f2                	mov    %esi,%edx
  8024d3:	f7 f7                	div    %edi
  8024d5:	89 d0                	mov    %edx,%eax
  8024d7:	31 d2                	xor    %edx,%edx
  8024d9:	83 c4 20             	add    $0x20,%esp
  8024dc:	5e                   	pop    %esi
  8024dd:	5f                   	pop    %edi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    
  8024e0:	39 f2                	cmp    %esi,%edx
  8024e2:	77 4c                	ja     802530 <__umoddi3+0x80>
  8024e4:	0f bd ca             	bsr    %edx,%ecx
  8024e7:	83 f1 1f             	xor    $0x1f,%ecx
  8024ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8024ed:	75 51                	jne    802540 <__umoddi3+0x90>
  8024ef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8024f2:	0f 87 e0 00 00 00    	ja     8025d8 <__umoddi3+0x128>
  8024f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024fb:	29 f8                	sub    %edi,%eax
  8024fd:	19 d6                	sbb    %edx,%esi
  8024ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802502:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802505:	89 f2                	mov    %esi,%edx
  802507:	83 c4 20             	add    $0x20,%esp
  80250a:	5e                   	pop    %esi
  80250b:	5f                   	pop    %edi
  80250c:	5d                   	pop    %ebp
  80250d:	c3                   	ret    
  80250e:	66 90                	xchg   %ax,%ax
  802510:	85 ff                	test   %edi,%edi
  802512:	75 0b                	jne    80251f <__umoddi3+0x6f>
  802514:	b8 01 00 00 00       	mov    $0x1,%eax
  802519:	31 d2                	xor    %edx,%edx
  80251b:	f7 f7                	div    %edi
  80251d:	89 c7                	mov    %eax,%edi
  80251f:	89 f0                	mov    %esi,%eax
  802521:	31 d2                	xor    %edx,%edx
  802523:	f7 f7                	div    %edi
  802525:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802528:	f7 f7                	div    %edi
  80252a:	eb a9                	jmp    8024d5 <__umoddi3+0x25>
  80252c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 f2                	mov    %esi,%edx
  802534:	83 c4 20             	add    $0x20,%esp
  802537:	5e                   	pop    %esi
  802538:	5f                   	pop    %edi
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    
  80253b:	90                   	nop
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802544:	d3 e2                	shl    %cl,%edx
  802546:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802549:	ba 20 00 00 00       	mov    $0x20,%edx
  80254e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802551:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802554:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802558:	89 fa                	mov    %edi,%edx
  80255a:	d3 ea                	shr    %cl,%edx
  80255c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802560:	0b 55 f4             	or     -0xc(%ebp),%edx
  802563:	d3 e7                	shl    %cl,%edi
  802565:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802569:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80256c:	89 f2                	mov    %esi,%edx
  80256e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802571:	89 c7                	mov    %eax,%edi
  802573:	d3 ea                	shr    %cl,%edx
  802575:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802579:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80257c:	89 c2                	mov    %eax,%edx
  80257e:	d3 e6                	shl    %cl,%esi
  802580:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802584:	d3 ea                	shr    %cl,%edx
  802586:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80258a:	09 d6                	or     %edx,%esi
  80258c:	89 f0                	mov    %esi,%eax
  80258e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802591:	d3 e7                	shl    %cl,%edi
  802593:	89 f2                	mov    %esi,%edx
  802595:	f7 75 f4             	divl   -0xc(%ebp)
  802598:	89 d6                	mov    %edx,%esi
  80259a:	f7 65 e8             	mull   -0x18(%ebp)
  80259d:	39 d6                	cmp    %edx,%esi
  80259f:	72 2b                	jb     8025cc <__umoddi3+0x11c>
  8025a1:	39 c7                	cmp    %eax,%edi
  8025a3:	72 23                	jb     8025c8 <__umoddi3+0x118>
  8025a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8025a9:	29 c7                	sub    %eax,%edi
  8025ab:	19 d6                	sbb    %edx,%esi
  8025ad:	89 f0                	mov    %esi,%eax
  8025af:	89 f2                	mov    %esi,%edx
  8025b1:	d3 ef                	shr    %cl,%edi
  8025b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8025b7:	d3 e0                	shl    %cl,%eax
  8025b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8025bd:	09 f8                	or     %edi,%eax
  8025bf:	d3 ea                	shr    %cl,%edx
  8025c1:	83 c4 20             	add    $0x20,%esp
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    
  8025c8:	39 d6                	cmp    %edx,%esi
  8025ca:	75 d9                	jne    8025a5 <__umoddi3+0xf5>
  8025cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8025cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8025d2:	eb d1                	jmp    8025a5 <__umoddi3+0xf5>
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	39 f2                	cmp    %esi,%edx
  8025da:	0f 82 18 ff ff ff    	jb     8024f8 <__umoddi3+0x48>
  8025e0:	e9 1d ff ff ff       	jmp    802502 <__umoddi3+0x52>
