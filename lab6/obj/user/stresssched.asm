
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
  800048:	e8 5a 15 00 00       	call   8015a7 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800054:	e8 1d 16 00 00       	call   801676 <fork>
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
  800086:	e8 9a 14 00 00       	call   801525 <sys_yield>
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
  8000b3:	e8 6d 14 00 00       	call   801525 <sys_yield>
  8000b8:	89 f0                	mov    %esi,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000ba:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8000c0:	83 c2 01             	add    $0x1,%edx
  8000c3:	89 15 08 50 80 00    	mov    %edx,0x805008
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
  8000db:	a1 08 50 80 00       	mov    0x805008,%eax
  8000e0:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000e5:	74 25                	je     80010c <umain+0xcc>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000e7:	a1 08 50 80 00       	mov    0x805008,%eax
  8000ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f0:	c7 44 24 08 40 2c 80 	movl   $0x802c40,0x8(%esp)
  8000f7:	00 
  8000f8:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000ff:	00 
  800100:	c7 04 24 68 2c 80 00 	movl   $0x802c68,(%esp)
  800107:	e8 98 00 00 00       	call   8001a4 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  80010c:	a1 0c 50 80 00       	mov    0x80500c,%eax
  800111:	8b 50 5c             	mov    0x5c(%eax),%edx
  800114:	8b 40 48             	mov    0x48(%eax),%eax
  800117:	89 54 24 08          	mov    %edx,0x8(%esp)
  80011b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011f:	c7 04 24 7b 2c 80 00 	movl   $0x802c7b,(%esp)
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
  800146:	e8 5c 14 00 00       	call   8015a7 <sys_getenvid>
  80014b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800150:	89 c2                	mov    %eax,%edx
  800152:	c1 e2 07             	shl    $0x7,%edx
  800155:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80015c:	a3 0c 50 80 00       	mov    %eax,0x80500c
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800161:	85 f6                	test   %esi,%esi
  800163:	7e 07                	jle    80016c <libmain+0x38>
		binaryname = argv[0];
  800165:	8b 03                	mov    (%ebx),%eax
  800167:	a3 00 40 80 00       	mov    %eax,0x804000

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
  80018e:	e8 48 1d 00 00       	call   801edb <close_all>
	sys_env_destroy(0);
  800193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019a:	e8 48 14 00 00       	call   8015e7 <sys_env_destroy>
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
  8001af:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001b5:	e8 ed 13 00 00       	call   8015a7 <sys_getenvid>
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 a4 2c 80 00 	movl   $0x802ca4,(%esp)
  8001d7:	e8 81 00 00 00       	call   80025d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 11 00 00 00       	call   8001fc <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 97 2c 80 00 	movl   $0x802c97,(%esp)
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
  80032f:	e8 9c 26 00 00       	call   8029d0 <__udivdi3>
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
  800397:	e8 64 27 00 00       	call   802b00 <__umoddi3>
  80039c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a0:	0f be 80 c7 2c 80 00 	movsbl 0x802cc7(%eax),%eax
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
  80048a:	ff 24 95 a0 2e 80 00 	jmp    *0x802ea0(,%edx,4)
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
  800547:	8b 14 85 00 30 80 00 	mov    0x803000(,%eax,4),%edx
  80054e:	85 d2                	test   %edx,%edx
  800550:	75 26                	jne    800578 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800552:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800556:	c7 44 24 08 d8 2c 80 	movl   $0x802cd8,0x8(%esp)
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
  80057c:	c7 44 24 08 de 31 80 	movl   $0x8031de,0x8(%esp)
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
  8005ba:	be e1 2c 80 00       	mov    $0x802ce1,%esi
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
  800864:	e8 67 21 00 00       	call   8029d0 <__udivdi3>
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
  8008b0:	e8 4b 22 00 00       	call   802b00 <__umoddi3>
  8008b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b9:	0f be 80 c7 2c 80 00 	movsbl 0x802cc7(%eax),%eax
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
  800965:	c7 44 24 0c fc 2d 80 	movl   $0x802dfc,0xc(%esp)
  80096c:	00 
  80096d:	c7 44 24 08 de 31 80 	movl   $0x8031de,0x8(%esp)
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
  80099b:	c7 44 24 0c 34 2e 80 	movl   $0x802e34,0xc(%esp)
  8009a2:	00 
  8009a3:	c7 44 24 08 de 31 80 	movl   $0x8031de,0x8(%esp)
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
  800a2f:	e8 cc 20 00 00       	call   802b00 <__umoddi3>
  800a34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a38:	0f be 80 c7 2c 80 00 	movsbl 0x802cc7(%eax),%eax
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
  800a71:	e8 8a 20 00 00       	call   802b00 <__umoddi3>
  800a76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a7a:	0f be 80 c7 2c 80 00 	movsbl 0x802cc7(%eax),%eax
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

00800ffb <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  801008:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100d:	b8 13 00 00 00       	mov    $0x13,%eax
  801012:	8b 55 08             	mov    0x8(%ebp),%edx
  801015:	89 cb                	mov    %ecx,%ebx
  801017:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801031:	8b 1c 24             	mov    (%esp),%ebx
  801034:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801038:	89 ec                	mov    %ebp,%esp
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	89 1c 24             	mov    %ebx,(%esp)
  801045:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801049:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104e:	b8 12 00 00 00       	mov    $0x12,%eax
  801053:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801056:	8b 55 08             	mov    0x8(%ebp),%edx
  801059:	89 df                	mov    %ebx,%edi
  80105b:	51                   	push   %ecx
  80105c:	52                   	push   %edx
  80105d:	53                   	push   %ebx
  80105e:	54                   	push   %esp
  80105f:	55                   	push   %ebp
  801060:	56                   	push   %esi
  801061:	57                   	push   %edi
  801062:	54                   	push   %esp
  801063:	5d                   	pop    %ebp
  801064:	8d 35 6c 10 80 00    	lea    0x80106c,%esi
  80106a:	0f 34                	sysenter 
  80106c:	5f                   	pop    %edi
  80106d:	5e                   	pop    %esi
  80106e:	5d                   	pop    %ebp
  80106f:	5c                   	pop    %esp
  801070:	5b                   	pop    %ebx
  801071:	5a                   	pop    %edx
  801072:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801073:	8b 1c 24             	mov    (%esp),%ebx
  801076:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80107a:	89 ec                	mov    %ebp,%esp
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	89 1c 24             	mov    %ebx,(%esp)
  801087:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801090:	b8 11 00 00 00       	mov    $0x11,%eax
  801095:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801098:	8b 55 08             	mov    0x8(%ebp),%edx
  80109b:	89 df                	mov    %ebx,%edi
  80109d:	51                   	push   %ecx
  80109e:	52                   	push   %edx
  80109f:	53                   	push   %ebx
  8010a0:	54                   	push   %esp
  8010a1:	55                   	push   %ebp
  8010a2:	56                   	push   %esi
  8010a3:	57                   	push   %edi
  8010a4:	54                   	push   %esp
  8010a5:	5d                   	pop    %ebp
  8010a6:	8d 35 ae 10 80 00    	lea    0x8010ae,%esi
  8010ac:	0f 34                	sysenter 
  8010ae:	5f                   	pop    %edi
  8010af:	5e                   	pop    %esi
  8010b0:	5d                   	pop    %ebp
  8010b1:	5c                   	pop    %esp
  8010b2:	5b                   	pop    %ebx
  8010b3:	5a                   	pop    %edx
  8010b4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8010b5:	8b 1c 24             	mov    (%esp),%ebx
  8010b8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010bc:	89 ec                	mov    %ebp,%esp
  8010be:	5d                   	pop    %ebp
  8010bf:	c3                   	ret    

008010c0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 08             	sub    $0x8,%esp
  8010c6:	89 1c 24             	mov    %ebx,(%esp)
  8010c9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010cd:	b8 10 00 00 00       	mov    $0x10,%eax
  8010d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	51                   	push   %ecx
  8010df:	52                   	push   %edx
  8010e0:	53                   	push   %ebx
  8010e1:	54                   	push   %esp
  8010e2:	55                   	push   %ebp
  8010e3:	56                   	push   %esi
  8010e4:	57                   	push   %edi
  8010e5:	54                   	push   %esp
  8010e6:	5d                   	pop    %ebp
  8010e7:	8d 35 ef 10 80 00    	lea    0x8010ef,%esi
  8010ed:	0f 34                	sysenter 
  8010ef:	5f                   	pop    %edi
  8010f0:	5e                   	pop    %esi
  8010f1:	5d                   	pop    %ebp
  8010f2:	5c                   	pop    %esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5a                   	pop    %edx
  8010f5:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  8010f6:	8b 1c 24             	mov    (%esp),%ebx
  8010f9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010fd:	89 ec                	mov    %ebp,%esp
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 28             	sub    $0x28,%esp
  801107:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80110a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80110d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801112:	b8 0f 00 00 00       	mov    $0xf,%eax
  801117:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111a:	8b 55 08             	mov    0x8(%ebp),%edx
  80111d:	89 df                	mov    %ebx,%edi
  80111f:	51                   	push   %ecx
  801120:	52                   	push   %edx
  801121:	53                   	push   %ebx
  801122:	54                   	push   %esp
  801123:	55                   	push   %ebp
  801124:	56                   	push   %esi
  801125:	57                   	push   %edi
  801126:	54                   	push   %esp
  801127:	5d                   	pop    %ebp
  801128:	8d 35 30 11 80 00    	lea    0x801130,%esi
  80112e:	0f 34                	sysenter 
  801130:	5f                   	pop    %edi
  801131:	5e                   	pop    %esi
  801132:	5d                   	pop    %ebp
  801133:	5c                   	pop    %esp
  801134:	5b                   	pop    %ebx
  801135:	5a                   	pop    %edx
  801136:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801137:	85 c0                	test   %eax,%eax
  801139:	7e 28                	jle    801163 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801146:	00 
  801147:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  80114e:	00 
  80114f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801156:	00 
  801157:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  80115e:	e8 41 f0 ff ff       	call   8001a4 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801163:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801166:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801169:	89 ec                	mov    %ebp,%esp
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
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
  80117a:	ba 00 00 00 00       	mov    $0x0,%edx
  80117f:	b8 15 00 00 00       	mov    $0x15,%eax
  801184:	89 d1                	mov    %edx,%ecx
  801186:	89 d3                	mov    %edx,%ebx
  801188:	89 d7                	mov    %edx,%edi
  80118a:	51                   	push   %ecx
  80118b:	52                   	push   %edx
  80118c:	53                   	push   %ebx
  80118d:	54                   	push   %esp
  80118e:	55                   	push   %ebp
  80118f:	56                   	push   %esi
  801190:	57                   	push   %edi
  801191:	54                   	push   %esp
  801192:	5d                   	pop    %ebp
  801193:	8d 35 9b 11 80 00    	lea    0x80119b,%esi
  801199:	0f 34                	sysenter 
  80119b:	5f                   	pop    %edi
  80119c:	5e                   	pop    %esi
  80119d:	5d                   	pop    %ebp
  80119e:	5c                   	pop    %esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5a                   	pop    %edx
  8011a1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011a2:	8b 1c 24             	mov    (%esp),%ebx
  8011a5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011a9:	89 ec                	mov    %ebp,%esp
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	89 1c 24             	mov    %ebx,(%esp)
  8011b6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011bf:	b8 14 00 00 00       	mov    $0x14,%eax
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011e3:	8b 1c 24             	mov    (%esp),%ebx
  8011e6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011ea:	89 ec                	mov    %ebp,%esp
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	83 ec 28             	sub    $0x28,%esp
  8011f4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011f7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ff:	b8 0e 00 00 00       	mov    $0xe,%eax
  801204:	8b 55 08             	mov    0x8(%ebp),%edx
  801207:	89 cb                	mov    %ecx,%ebx
  801209:	89 cf                	mov    %ecx,%edi
  80120b:	51                   	push   %ecx
  80120c:	52                   	push   %edx
  80120d:	53                   	push   %ebx
  80120e:	54                   	push   %esp
  80120f:	55                   	push   %ebp
  801210:	56                   	push   %esi
  801211:	57                   	push   %edi
  801212:	54                   	push   %esp
  801213:	5d                   	pop    %ebp
  801214:	8d 35 1c 12 80 00    	lea    0x80121c,%esi
  80121a:	0f 34                	sysenter 
  80121c:	5f                   	pop    %edi
  80121d:	5e                   	pop    %esi
  80121e:	5d                   	pop    %ebp
  80121f:	5c                   	pop    %esp
  801220:	5b                   	pop    %ebx
  801221:	5a                   	pop    %edx
  801222:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801223:	85 c0                	test   %eax,%eax
  801225:	7e 28                	jle    80124f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801227:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801232:	00 
  801233:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  80123a:	00 
  80123b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801242:	00 
  801243:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  80124a:	e8 55 ef ff ff       	call   8001a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80124f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801252:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801255:	89 ec                	mov    %ebp,%esp
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	89 1c 24             	mov    %ebx,(%esp)
  801262:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801266:	b8 0d 00 00 00       	mov    $0xd,%eax
  80126b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80126e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801274:	8b 55 08             	mov    0x8(%ebp),%edx
  801277:	51                   	push   %ecx
  801278:	52                   	push   %edx
  801279:	53                   	push   %ebx
  80127a:	54                   	push   %esp
  80127b:	55                   	push   %ebp
  80127c:	56                   	push   %esi
  80127d:	57                   	push   %edi
  80127e:	54                   	push   %esp
  80127f:	5d                   	pop    %ebp
  801280:	8d 35 88 12 80 00    	lea    0x801288,%esi
  801286:	0f 34                	sysenter 
  801288:	5f                   	pop    %edi
  801289:	5e                   	pop    %esi
  80128a:	5d                   	pop    %ebp
  80128b:	5c                   	pop    %esp
  80128c:	5b                   	pop    %ebx
  80128d:	5a                   	pop    %edx
  80128e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80128f:	8b 1c 24             	mov    (%esp),%ebx
  801292:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801296:	89 ec                	mov    %ebp,%esp
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	83 ec 28             	sub    $0x28,%esp
  8012a0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012a3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ab:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b6:	89 df                	mov    %ebx,%edi
  8012b8:	51                   	push   %ecx
  8012b9:	52                   	push   %edx
  8012ba:	53                   	push   %ebx
  8012bb:	54                   	push   %esp
  8012bc:	55                   	push   %ebp
  8012bd:	56                   	push   %esi
  8012be:	57                   	push   %edi
  8012bf:	54                   	push   %esp
  8012c0:	5d                   	pop    %ebp
  8012c1:	8d 35 c9 12 80 00    	lea    0x8012c9,%esi
  8012c7:	0f 34                	sysenter 
  8012c9:	5f                   	pop    %edi
  8012ca:	5e                   	pop    %esi
  8012cb:	5d                   	pop    %ebp
  8012cc:	5c                   	pop    %esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5a                   	pop    %edx
  8012cf:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	7e 28                	jle    8012fc <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8012df:	00 
  8012e0:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  8012e7:	00 
  8012e8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012ef:	00 
  8012f0:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  8012f7:	e8 a8 ee ff ff       	call   8001a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012fc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ff:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801302:	89 ec                	mov    %ebp,%esp
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	83 ec 28             	sub    $0x28,%esp
  80130c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80130f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801312:	bb 00 00 00 00       	mov    $0x0,%ebx
  801317:	b8 0a 00 00 00       	mov    $0xa,%eax
  80131c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131f:	8b 55 08             	mov    0x8(%ebp),%edx
  801322:	89 df                	mov    %ebx,%edi
  801324:	51                   	push   %ecx
  801325:	52                   	push   %edx
  801326:	53                   	push   %ebx
  801327:	54                   	push   %esp
  801328:	55                   	push   %ebp
  801329:	56                   	push   %esi
  80132a:	57                   	push   %edi
  80132b:	54                   	push   %esp
  80132c:	5d                   	pop    %ebp
  80132d:	8d 35 35 13 80 00    	lea    0x801335,%esi
  801333:	0f 34                	sysenter 
  801335:	5f                   	pop    %edi
  801336:	5e                   	pop    %esi
  801337:	5d                   	pop    %ebp
  801338:	5c                   	pop    %esp
  801339:	5b                   	pop    %ebx
  80133a:	5a                   	pop    %edx
  80133b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80133c:	85 c0                	test   %eax,%eax
  80133e:	7e 28                	jle    801368 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801340:	89 44 24 10          	mov    %eax,0x10(%esp)
  801344:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80134b:	00 
  80134c:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  801353:	00 
  801354:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80135b:	00 
  80135c:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  801363:	e8 3c ee ff ff       	call   8001a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801368:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80136b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80136e:	89 ec                	mov    %ebp,%esp
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 28             	sub    $0x28,%esp
  801378:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80137b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80137e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801383:	b8 09 00 00 00       	mov    $0x9,%eax
  801388:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138b:	8b 55 08             	mov    0x8(%ebp),%edx
  80138e:	89 df                	mov    %ebx,%edi
  801390:	51                   	push   %ecx
  801391:	52                   	push   %edx
  801392:	53                   	push   %ebx
  801393:	54                   	push   %esp
  801394:	55                   	push   %ebp
  801395:	56                   	push   %esi
  801396:	57                   	push   %edi
  801397:	54                   	push   %esp
  801398:	5d                   	pop    %ebp
  801399:	8d 35 a1 13 80 00    	lea    0x8013a1,%esi
  80139f:	0f 34                	sysenter 
  8013a1:	5f                   	pop    %edi
  8013a2:	5e                   	pop    %esi
  8013a3:	5d                   	pop    %ebp
  8013a4:	5c                   	pop    %esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5a                   	pop    %edx
  8013a7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	7e 28                	jle    8013d4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013b7:	00 
  8013b8:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  8013bf:	00 
  8013c0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013c7:	00 
  8013c8:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  8013cf:	e8 d0 ed ff ff       	call   8001a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013d4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013d7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013da:	89 ec                	mov    %ebp,%esp
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 28             	sub    $0x28,%esp
  8013e4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013e7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ef:	b8 07 00 00 00       	mov    $0x7,%eax
  8013f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fa:	89 df                	mov    %ebx,%edi
  8013fc:	51                   	push   %ecx
  8013fd:	52                   	push   %edx
  8013fe:	53                   	push   %ebx
  8013ff:	54                   	push   %esp
  801400:	55                   	push   %ebp
  801401:	56                   	push   %esi
  801402:	57                   	push   %edi
  801403:	54                   	push   %esp
  801404:	5d                   	pop    %ebp
  801405:	8d 35 0d 14 80 00    	lea    0x80140d,%esi
  80140b:	0f 34                	sysenter 
  80140d:	5f                   	pop    %edi
  80140e:	5e                   	pop    %esi
  80140f:	5d                   	pop    %ebp
  801410:	5c                   	pop    %esp
  801411:	5b                   	pop    %ebx
  801412:	5a                   	pop    %edx
  801413:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801414:	85 c0                	test   %eax,%eax
  801416:	7e 28                	jle    801440 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801418:	89 44 24 10          	mov    %eax,0x10(%esp)
  80141c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801423:	00 
  801424:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  80142b:	00 
  80142c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801433:	00 
  801434:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  80143b:	e8 64 ed ff ff       	call   8001a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801440:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801443:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801446:	89 ec                	mov    %ebp,%esp
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    

0080144a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 28             	sub    $0x28,%esp
  801450:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801453:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801456:	8b 7d 18             	mov    0x18(%ebp),%edi
  801459:	0b 7d 14             	or     0x14(%ebp),%edi
  80145c:	b8 06 00 00 00       	mov    $0x6,%eax
  801461:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801464:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801467:	8b 55 08             	mov    0x8(%ebp),%edx
  80146a:	51                   	push   %ecx
  80146b:	52                   	push   %edx
  80146c:	53                   	push   %ebx
  80146d:	54                   	push   %esp
  80146e:	55                   	push   %ebp
  80146f:	56                   	push   %esi
  801470:	57                   	push   %edi
  801471:	54                   	push   %esp
  801472:	5d                   	pop    %ebp
  801473:	8d 35 7b 14 80 00    	lea    0x80147b,%esi
  801479:	0f 34                	sysenter 
  80147b:	5f                   	pop    %edi
  80147c:	5e                   	pop    %esi
  80147d:	5d                   	pop    %ebp
  80147e:	5c                   	pop    %esp
  80147f:	5b                   	pop    %ebx
  801480:	5a                   	pop    %edx
  801481:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801482:	85 c0                	test   %eax,%eax
  801484:	7e 28                	jle    8014ae <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801486:	89 44 24 10          	mov    %eax,0x10(%esp)
  80148a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801491:	00 
  801492:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  801499:	00 
  80149a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014a1:	00 
  8014a2:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  8014a9:	e8 f6 ec ff ff       	call   8001a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8014ae:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014b4:	89 ec                	mov    %ebp,%esp
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	83 ec 28             	sub    $0x28,%esp
  8014be:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014c1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014c4:	bf 00 00 00 00       	mov    $0x0,%edi
  8014c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d7:	51                   	push   %ecx
  8014d8:	52                   	push   %edx
  8014d9:	53                   	push   %ebx
  8014da:	54                   	push   %esp
  8014db:	55                   	push   %ebp
  8014dc:	56                   	push   %esi
  8014dd:	57                   	push   %edi
  8014de:	54                   	push   %esp
  8014df:	5d                   	pop    %ebp
  8014e0:	8d 35 e8 14 80 00    	lea    0x8014e8,%esi
  8014e6:	0f 34                	sysenter 
  8014e8:	5f                   	pop    %edi
  8014e9:	5e                   	pop    %esi
  8014ea:	5d                   	pop    %ebp
  8014eb:	5c                   	pop    %esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5a                   	pop    %edx
  8014ee:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	7e 28                	jle    80151b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014f7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8014fe:	00 
  8014ff:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  801506:	00 
  801507:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80150e:	00 
  80150f:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  801516:	e8 89 ec ff ff       	call   8001a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80151b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80151e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801521:	89 ec                	mov    %ebp,%esp
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
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
  801532:	ba 00 00 00 00       	mov    $0x0,%edx
  801537:	b8 0c 00 00 00       	mov    $0xc,%eax
  80153c:	89 d1                	mov    %edx,%ecx
  80153e:	89 d3                	mov    %edx,%ebx
  801540:	89 d7                	mov    %edx,%edi
  801542:	51                   	push   %ecx
  801543:	52                   	push   %edx
  801544:	53                   	push   %ebx
  801545:	54                   	push   %esp
  801546:	55                   	push   %ebp
  801547:	56                   	push   %esi
  801548:	57                   	push   %edi
  801549:	54                   	push   %esp
  80154a:	5d                   	pop    %ebp
  80154b:	8d 35 53 15 80 00    	lea    0x801553,%esi
  801551:	0f 34                	sysenter 
  801553:	5f                   	pop    %edi
  801554:	5e                   	pop    %esi
  801555:	5d                   	pop    %ebp
  801556:	5c                   	pop    %esp
  801557:	5b                   	pop    %ebx
  801558:	5a                   	pop    %edx
  801559:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80155a:	8b 1c 24             	mov    (%esp),%ebx
  80155d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801561:	89 ec                	mov    %ebp,%esp
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	89 1c 24             	mov    %ebx,(%esp)
  80156e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801572:	bb 00 00 00 00       	mov    $0x0,%ebx
  801577:	b8 04 00 00 00       	mov    $0x4,%eax
  80157c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157f:	8b 55 08             	mov    0x8(%ebp),%edx
  801582:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80159c:	8b 1c 24             	mov    (%esp),%ebx
  80159f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015a3:	89 ec                	mov    %ebp,%esp
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    

008015a7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	89 1c 24             	mov    %ebx,(%esp)
  8015b0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b9:	b8 02 00 00 00       	mov    $0x2,%eax
  8015be:	89 d1                	mov    %edx,%ecx
  8015c0:	89 d3                	mov    %edx,%ebx
  8015c2:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015dc:	8b 1c 24             	mov    (%esp),%ebx
  8015df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015e3:	89 ec                	mov    %ebp,%esp
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 28             	sub    $0x28,%esp
  8015ed:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015f0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801600:	89 cb                	mov    %ecx,%ebx
  801602:	89 cf                	mov    %ecx,%edi
  801604:	51                   	push   %ecx
  801605:	52                   	push   %edx
  801606:	53                   	push   %ebx
  801607:	54                   	push   %esp
  801608:	55                   	push   %ebp
  801609:	56                   	push   %esi
  80160a:	57                   	push   %edi
  80160b:	54                   	push   %esp
  80160c:	5d                   	pop    %ebp
  80160d:	8d 35 15 16 80 00    	lea    0x801615,%esi
  801613:	0f 34                	sysenter 
  801615:	5f                   	pop    %edi
  801616:	5e                   	pop    %esi
  801617:	5d                   	pop    %ebp
  801618:	5c                   	pop    %esp
  801619:	5b                   	pop    %ebx
  80161a:	5a                   	pop    %edx
  80161b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80161c:	85 c0                	test   %eax,%eax
  80161e:	7e 28                	jle    801648 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801620:	89 44 24 10          	mov    %eax,0x10(%esp)
  801624:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80162b:	00 
  80162c:	c7 44 24 08 40 30 80 	movl   $0x803040,0x8(%esp)
  801633:	00 
  801634:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80163b:	00 
  80163c:	c7 04 24 5d 30 80 00 	movl   $0x80305d,(%esp)
  801643:	e8 5c eb ff ff       	call   8001a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801648:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80164b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80164e:	89 ec                	mov    %ebp,%esp
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    
	...

00801654 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80165a:	c7 44 24 08 6b 30 80 	movl   $0x80306b,0x8(%esp)
  801661:	00 
  801662:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801669:	00 
  80166a:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801671:	e8 2e eb ff ff       	call   8001a4 <_panic>

00801676 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	57                   	push   %edi
  80167a:	56                   	push   %esi
  80167b:	53                   	push   %ebx
  80167c:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80167f:	c7 04 24 cb 18 80 00 	movl   $0x8018cb,(%esp)
  801686:	e8 49 11 00 00       	call   8027d4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80168b:	ba 08 00 00 00       	mov    $0x8,%edx
  801690:	89 d0                	mov    %edx,%eax
  801692:	cd 30                	int    $0x30
  801694:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801697:	85 c0                	test   %eax,%eax
  801699:	79 20                	jns    8016bb <fork+0x45>
		panic("sys_exofork: %e", envid);
  80169b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80169f:	c7 44 24 08 8c 30 80 	movl   $0x80308c,0x8(%esp)
  8016a6:	00 
  8016a7:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8016ae:	00 
  8016af:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  8016b6:	e8 e9 ea ff ff       	call   8001a4 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8016bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8016c0:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8016c5:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8016ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016ce:	75 20                	jne    8016f0 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8016d0:	e8 d2 fe ff ff       	call   8015a7 <sys_getenvid>
  8016d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	c1 e2 07             	shl    $0x7,%edx
  8016df:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8016e6:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  8016eb:	e9 d0 01 00 00       	jmp    8018c0 <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	c1 e8 16             	shr    $0x16,%eax
  8016f5:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8016f8:	a8 01                	test   $0x1,%al
  8016fa:	0f 84 0d 01 00 00    	je     80180d <fork+0x197>
  801700:	89 d8                	mov    %ebx,%eax
  801702:	c1 e8 0c             	shr    $0xc,%eax
  801705:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801708:	f6 c2 01             	test   $0x1,%dl
  80170b:	0f 84 fc 00 00 00    	je     80180d <fork+0x197>
  801711:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801714:	f6 c2 04             	test   $0x4,%dl
  801717:	0f 84 f0 00 00 00    	je     80180d <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  80171d:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  801720:	89 c2                	mov    %eax,%edx
  801722:	c1 ea 0c             	shr    $0xc,%edx
  801725:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801728:	f6 c2 01             	test   $0x1,%dl
  80172b:	0f 84 dc 00 00 00    	je     80180d <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  801731:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801737:	0f 84 8d 00 00 00    	je     8017ca <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  80173d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801740:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801747:	00 
  801748:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80174c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80174f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801753:	89 44 24 04          	mov    %eax,0x4(%esp)
  801757:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80175e:	e8 e7 fc ff ff       	call   80144a <sys_page_map>
               if(r<0)
  801763:	85 c0                	test   %eax,%eax
  801765:	79 1c                	jns    801783 <fork+0x10d>
                 panic("map failed");
  801767:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  80176e:	00 
  80176f:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801776:	00 
  801777:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  80177e:	e8 21 ea ff ff       	call   8001a4 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  801783:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80178a:	00 
  80178b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80178e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801792:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801799:	00 
  80179a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a5:	e8 a0 fc ff ff       	call   80144a <sys_page_map>
               if(r<0)
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	79 5f                	jns    80180d <fork+0x197>
                 panic("map failed");
  8017ae:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  8017b5:	00 
  8017b6:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8017bd:	00 
  8017be:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  8017c5:	e8 da e9 ff ff       	call   8001a4 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  8017ca:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8017d1:	00 
  8017d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e8:	e8 5d fc ff ff       	call   80144a <sys_page_map>
               if(r<0)
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	79 1c                	jns    80180d <fork+0x197>
                 panic("map failed");
  8017f1:	c7 44 24 08 9c 30 80 	movl   $0x80309c,0x8(%esp)
  8017f8:	00 
  8017f9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801800:	00 
  801801:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801808:	e8 97 e9 ff ff       	call   8001a4 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80180d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801813:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801819:	0f 85 d1 fe ff ff    	jne    8016f0 <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80181f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801826:	00 
  801827:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80182e:	ee 
  80182f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801832:	89 04 24             	mov    %eax,(%esp)
  801835:	e8 7e fc ff ff       	call   8014b8 <sys_page_alloc>
        if(r < 0)
  80183a:	85 c0                	test   %eax,%eax
  80183c:	79 1c                	jns    80185a <fork+0x1e4>
            panic("alloc failed");
  80183e:	c7 44 24 08 a7 30 80 	movl   $0x8030a7,0x8(%esp)
  801845:	00 
  801846:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80184d:	00 
  80184e:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801855:	e8 4a e9 ff ff       	call   8001a4 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80185a:	c7 44 24 04 20 28 80 	movl   $0x802820,0x4(%esp)
  801861:	00 
  801862:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801865:	89 14 24             	mov    %edx,(%esp)
  801868:	e8 2d fa ff ff       	call   80129a <sys_env_set_pgfault_upcall>
        if(r < 0)
  80186d:	85 c0                	test   %eax,%eax
  80186f:	79 1c                	jns    80188d <fork+0x217>
            panic("set pgfault upcall failed");
  801871:	c7 44 24 08 b4 30 80 	movl   $0x8030b4,0x8(%esp)
  801878:	00 
  801879:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801880:	00 
  801881:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801888:	e8 17 e9 ff ff       	call   8001a4 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  80188d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801894:	00 
  801895:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801898:	89 04 24             	mov    %eax,(%esp)
  80189b:	e8 d2 fa ff ff       	call   801372 <sys_env_set_status>
        if(r < 0)
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	79 1c                	jns    8018c0 <fork+0x24a>
            panic("set status failed");
  8018a4:	c7 44 24 08 ce 30 80 	movl   $0x8030ce,0x8(%esp)
  8018ab:	00 
  8018ac:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8018b3:	00 
  8018b4:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  8018bb:	e8 e4 e8 ff ff       	call   8001a4 <_panic>
        return envid;
	//panic("fork not implemented");
}
  8018c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018c3:	83 c4 3c             	add    $0x3c,%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5f                   	pop    %edi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	53                   	push   %ebx
  8018cf:	83 ec 24             	sub    $0x24,%esp
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8018d5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  8018d7:	89 da                	mov    %ebx,%edx
  8018d9:	c1 ea 0c             	shr    $0xc,%edx
  8018dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8018e3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8018e7:	74 08                	je     8018f1 <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  8018e9:	f7 c2 05 08 00 00    	test   $0x805,%edx
  8018ef:	75 1c                	jne    80190d <pgfault+0x42>
           panic("pgfault error");
  8018f1:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  8018f8:	00 
  8018f9:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801900:	00 
  801901:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801908:	e8 97 e8 ff ff       	call   8001a4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80190d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801914:	00 
  801915:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80191c:	00 
  80191d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801924:	e8 8f fb ff ff       	call   8014b8 <sys_page_alloc>
  801929:	85 c0                	test   %eax,%eax
  80192b:	79 20                	jns    80194d <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  80192d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801931:	c7 44 24 08 ee 30 80 	movl   $0x8030ee,0x8(%esp)
  801938:	00 
  801939:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801940:	00 
  801941:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  801948:	e8 57 e8 ff ff       	call   8001a4 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  80194d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801953:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80195a:	00 
  80195b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80195f:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801966:	e8 0a f4 ff ff       	call   800d75 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  80196b:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801972:	00 
  801973:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801977:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80197e:	00 
  80197f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801986:	00 
  801987:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80198e:	e8 b7 fa ff ff       	call   80144a <sys_page_map>
  801993:	85 c0                	test   %eax,%eax
  801995:	79 20                	jns    8019b7 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801997:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80199b:	c7 44 24 08 01 31 80 	movl   $0x803101,0x8(%esp)
  8019a2:	00 
  8019a3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8019aa:	00 
  8019ab:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  8019b2:	e8 ed e7 ff ff       	call   8001a4 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8019b7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8019be:	00 
  8019bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c6:	e8 13 fa ff ff       	call   8013de <sys_page_unmap>
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	79 20                	jns    8019ef <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  8019cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d3:	c7 44 24 08 12 31 80 	movl   $0x803112,0x8(%esp)
  8019da:	00 
  8019db:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8019e2:	00 
  8019e3:	c7 04 24 81 30 80 00 	movl   $0x803081,(%esp)
  8019ea:	e8 b5 e7 ff ff       	call   8001a4 <_panic>
	//panic("pgfault not implemented");
}
  8019ef:	83 c4 24             	add    $0x24,%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    
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
  801b1f:	b8 04 40 80 00       	mov    $0x804004,%eax
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
  801b29:	be a8 31 80 00       	mov    $0x8031a8,%esi
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
  801b4c:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801b51:	8b 40 48             	mov    0x48(%eax),%eax
  801b54:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	c7 04 24 28 31 80 00 	movl   $0x803128,(%esp)
  801b63:	e8 f5 e6 ff ff       	call   80025d <cprintf>
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
  801c31:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c36:	8b 40 48             	mov    0x48(%eax),%eax
  801c39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c41:	c7 04 24 48 31 80 00 	movl   $0x803148,(%esp)
  801c48:	e8 10 e6 ff ff       	call   80025d <cprintf>
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
  801cb3:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801cb8:	8b 40 48             	mov    0x48(%eax),%eax
  801cbb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc3:	c7 04 24 6c 31 80 00 	movl   $0x80316c,(%esp)
  801cca:	e8 8e e5 ff ff       	call   80025d <cprintf>
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
  801d41:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801d46:	8b 40 48             	mov    0x48(%eax),%eax
  801d49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d51:	c7 04 24 89 31 80 00 	movl   $0x803189,(%esp)
  801d58:	e8 00 e5 ff ff       	call   80025d <cprintf>
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
  801e50:	e8 89 f5 ff ff       	call   8013de <sys_page_unmap>
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
  801f9e:	e8 a7 f4 ff ff       	call   80144a <sys_page_map>
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
  801fd9:	e8 6c f4 ff ff       	call   80144a <sys_page_map>
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
  801ff3:	e8 e6 f3 ff ff       	call   8013de <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ff8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802006:	e8 d3 f3 ff ff       	call   8013de <sys_page_unmap>
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
  80202c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  802033:	75 11                	jne    802046 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802035:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80203c:	e8 0f 08 00 00       	call   802850 <ipc_find_env>
  802041:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802046:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80204d:	00 
  80204e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802055:	00 
  802056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80205a:	a1 00 50 80 00       	mov    0x805000,%eax
  80205f:	89 04 24             	mov    %eax,(%esp)
  802062:	e8 34 08 00 00       	call   80289b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802067:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80206e:	00 
  80206f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207a:	e8 9a 08 00 00       	call   802919 <ipc_recv>
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
  802095:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80209a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209d:	a3 04 60 80 00       	mov    %eax,0x806004
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
  8020bf:	a3 00 60 80 00       	mov    %eax,0x806000
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
  8020fc:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802101:	ba 00 00 00 00       	mov    $0x0,%edx
  802106:	b8 05 00 00 00       	mov    $0x5,%eax
  80210b:	e8 0c ff ff ff       	call   80201c <fsipc>
  802110:	85 c0                	test   %eax,%eax
  802112:	78 2b                	js     80213f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802114:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80211b:	00 
  80211c:	89 1c 24             	mov    %ebx,(%esp)
  80211f:	e8 66 ea ff ff       	call   800b8a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802124:	a1 80 60 80 00       	mov    0x806080,%eax
  802129:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80212f:	a1 84 60 80 00       	mov    0x806084,%eax
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
  802160:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  802166:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  80216b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80216f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802172:	89 44 24 04          	mov    %eax,0x4(%esp)
  802176:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80217d:	e8 f3 eb ff ff       	call   800d75 <memmove>
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
  8021a0:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  8021a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a8:	a3 04 60 80 00       	mov    %eax,0x806004
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
  8021c6:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8021cd:	00 
  8021ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 9c eb ff ff       	call   800d75 <memmove>
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
  8021ee:	e8 4d e9 ff ff       	call   800b40 <strlen>
  8021f3:	89 c2                	mov    %eax,%edx
  8021f5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8021fa:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802200:	7f 1f                	jg     802221 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802202:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802206:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80220d:	e8 78 e9 ff ff       	call   800b8a <strcpy>
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
  802239:	e8 02 e9 ff ff       	call   800b40 <strlen>
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
  80225e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  802263:	89 34 24             	mov    %esi,(%esp)
  802266:	e8 d5 e8 ff ff       	call   800b40 <strlen>
  80226b:	83 c0 01             	add    $0x1,%eax
  80226e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802272:	89 74 24 04          	mov    %esi,0x4(%esp)
  802276:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80227d:	e8 f3 ea ff ff       	call   800d75 <memmove>
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

008022d0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8022d6:	c7 44 24 04 b4 31 80 	movl   $0x8031b4,0x4(%esp)
  8022dd:	00 
  8022de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e1:	89 04 24             	mov    %eax,(%esp)
  8022e4:	e8 a1 e8 ff ff       	call   800b8a <strcpy>
	return 0;
}
  8022e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    

008022f0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 14             	sub    $0x14,%esp
  8022f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8022fa:	89 1c 24             	mov    %ebx,(%esp)
  8022fd:	e8 8a 06 00 00       	call   80298c <pageref>
  802302:	89 c2                	mov    %eax,%edx
  802304:	b8 00 00 00 00       	mov    $0x0,%eax
  802309:	83 fa 01             	cmp    $0x1,%edx
  80230c:	75 0b                	jne    802319 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80230e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802311:	89 04 24             	mov    %eax,(%esp)
  802314:	e8 b9 02 00 00       	call   8025d2 <nsipc_close>
	else
		return 0;
}
  802319:	83 c4 14             	add    $0x14,%esp
  80231c:	5b                   	pop    %ebx
  80231d:	5d                   	pop    %ebp
  80231e:	c3                   	ret    

0080231f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80231f:	55                   	push   %ebp
  802320:	89 e5                	mov    %esp,%ebp
  802322:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802325:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80232c:	00 
  80232d:	8b 45 10             	mov    0x10(%ebp),%eax
  802330:	89 44 24 08          	mov    %eax,0x8(%esp)
  802334:	8b 45 0c             	mov    0xc(%ebp),%eax
  802337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233b:	8b 45 08             	mov    0x8(%ebp),%eax
  80233e:	8b 40 0c             	mov    0xc(%eax),%eax
  802341:	89 04 24             	mov    %eax,(%esp)
  802344:	e8 c5 02 00 00       	call   80260e <nsipc_send>
}
  802349:	c9                   	leave  
  80234a:	c3                   	ret    

0080234b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802351:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802358:	00 
  802359:	8b 45 10             	mov    0x10(%ebp),%eax
  80235c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802360:	8b 45 0c             	mov    0xc(%ebp),%eax
  802363:	89 44 24 04          	mov    %eax,0x4(%esp)
  802367:	8b 45 08             	mov    0x8(%ebp),%eax
  80236a:	8b 40 0c             	mov    0xc(%eax),%eax
  80236d:	89 04 24             	mov    %eax,(%esp)
  802370:	e8 0c 03 00 00       	call   802681 <nsipc_recv>
}
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	56                   	push   %esi
  80237b:	53                   	push   %ebx
  80237c:	83 ec 20             	sub    $0x20,%esp
  80237f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802384:	89 04 24             	mov    %eax,(%esp)
  802387:	e8 9f f6 ff ff       	call   801a2b <fd_alloc>
  80238c:	89 c3                	mov    %eax,%ebx
  80238e:	85 c0                	test   %eax,%eax
  802390:	78 21                	js     8023b3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802392:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802399:	00 
  80239a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a8:	e8 0b f1 ff ff       	call   8014b8 <sys_page_alloc>
  8023ad:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	79 0a                	jns    8023bd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  8023b3:	89 34 24             	mov    %esi,(%esp)
  8023b6:	e8 17 02 00 00       	call   8025d2 <nsipc_close>
		return r;
  8023bb:	eb 28                	jmp    8023e5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8023bd:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8023c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8023c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8023d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8023d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023db:	89 04 24             	mov    %eax,(%esp)
  8023de:	e8 1d f6 ff ff       	call   801a00 <fd2num>
  8023e3:	89 c3                	mov    %eax,%ebx
}
  8023e5:	89 d8                	mov    %ebx,%eax
  8023e7:	83 c4 20             	add    $0x20,%esp
  8023ea:	5b                   	pop    %ebx
  8023eb:	5e                   	pop    %esi
  8023ec:	5d                   	pop    %ebp
  8023ed:	c3                   	ret    

008023ee <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8023f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802402:	8b 45 08             	mov    0x8(%ebp),%eax
  802405:	89 04 24             	mov    %eax,(%esp)
  802408:	e8 79 01 00 00       	call   802586 <nsipc_socket>
  80240d:	85 c0                	test   %eax,%eax
  80240f:	78 05                	js     802416 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802411:	e8 61 ff ff ff       	call   802377 <alloc_sockfd>
}
  802416:	c9                   	leave  
  802417:	c3                   	ret    

00802418 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80241e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802421:	89 54 24 04          	mov    %edx,0x4(%esp)
  802425:	89 04 24             	mov    %eax,(%esp)
  802428:	e8 70 f6 ff ff       	call   801a9d <fd_lookup>
  80242d:	85 c0                	test   %eax,%eax
  80242f:	78 15                	js     802446 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802431:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802434:	8b 0a                	mov    (%edx),%ecx
  802436:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80243b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802441:	75 03                	jne    802446 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802443:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802446:	c9                   	leave  
  802447:	c3                   	ret    

00802448 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802448:	55                   	push   %ebp
  802449:	89 e5                	mov    %esp,%ebp
  80244b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80244e:	8b 45 08             	mov    0x8(%ebp),%eax
  802451:	e8 c2 ff ff ff       	call   802418 <fd2sockid>
  802456:	85 c0                	test   %eax,%eax
  802458:	78 0f                	js     802469 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80245a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80245d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802461:	89 04 24             	mov    %eax,(%esp)
  802464:	e8 47 01 00 00       	call   8025b0 <nsipc_listen>
}
  802469:	c9                   	leave  
  80246a:	c3                   	ret    

0080246b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802471:	8b 45 08             	mov    0x8(%ebp),%eax
  802474:	e8 9f ff ff ff       	call   802418 <fd2sockid>
  802479:	85 c0                	test   %eax,%eax
  80247b:	78 16                	js     802493 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80247d:	8b 55 10             	mov    0x10(%ebp),%edx
  802480:	89 54 24 08          	mov    %edx,0x8(%esp)
  802484:	8b 55 0c             	mov    0xc(%ebp),%edx
  802487:	89 54 24 04          	mov    %edx,0x4(%esp)
  80248b:	89 04 24             	mov    %eax,(%esp)
  80248e:	e8 6e 02 00 00       	call   802701 <nsipc_connect>
}
  802493:	c9                   	leave  
  802494:	c3                   	ret    

00802495 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802495:	55                   	push   %ebp
  802496:	89 e5                	mov    %esp,%ebp
  802498:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80249b:	8b 45 08             	mov    0x8(%ebp),%eax
  80249e:	e8 75 ff ff ff       	call   802418 <fd2sockid>
  8024a3:	85 c0                	test   %eax,%eax
  8024a5:	78 0f                	js     8024b6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8024a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024ae:	89 04 24             	mov    %eax,(%esp)
  8024b1:	e8 36 01 00 00       	call   8025ec <nsipc_shutdown>
}
  8024b6:	c9                   	leave  
  8024b7:	c3                   	ret    

008024b8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024b8:	55                   	push   %ebp
  8024b9:	89 e5                	mov    %esp,%ebp
  8024bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024be:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c1:	e8 52 ff ff ff       	call   802418 <fd2sockid>
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	78 16                	js     8024e0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8024ca:	8b 55 10             	mov    0x10(%ebp),%edx
  8024cd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024d8:	89 04 24             	mov    %eax,(%esp)
  8024db:	e8 60 02 00 00       	call   802740 <nsipc_bind>
}
  8024e0:	c9                   	leave  
  8024e1:	c3                   	ret    

008024e2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024e2:	55                   	push   %ebp
  8024e3:	89 e5                	mov    %esp,%ebp
  8024e5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024eb:	e8 28 ff ff ff       	call   802418 <fd2sockid>
  8024f0:	85 c0                	test   %eax,%eax
  8024f2:	78 1f                	js     802513 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8024f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8024f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  802502:	89 04 24             	mov    %eax,(%esp)
  802505:	e8 75 02 00 00       	call   80277f <nsipc_accept>
  80250a:	85 c0                	test   %eax,%eax
  80250c:	78 05                	js     802513 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80250e:	e8 64 fe ff ff       	call   802377 <alloc_sockfd>
}
  802513:	c9                   	leave  
  802514:	c3                   	ret    
	...

00802520 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	53                   	push   %ebx
  802524:	83 ec 14             	sub    $0x14,%esp
  802527:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802529:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802530:	75 11                	jne    802543 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802532:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802539:	e8 12 03 00 00       	call   802850 <ipc_find_env>
  80253e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802543:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80254a:	00 
  80254b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802552:	00 
  802553:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802557:	a1 04 50 80 00       	mov    0x805004,%eax
  80255c:	89 04 24             	mov    %eax,(%esp)
  80255f:	e8 37 03 00 00       	call   80289b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802564:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80256b:	00 
  80256c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802573:	00 
  802574:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80257b:	e8 99 03 00 00       	call   802919 <ipc_recv>
}
  802580:	83 c4 14             	add    $0x14,%esp
  802583:	5b                   	pop    %ebx
  802584:	5d                   	pop    %ebp
  802585:	c3                   	ret    

00802586 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802586:	55                   	push   %ebp
  802587:	89 e5                	mov    %esp,%ebp
  802589:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80258c:	8b 45 08             	mov    0x8(%ebp),%eax
  80258f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802594:	8b 45 0c             	mov    0xc(%ebp),%eax
  802597:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80259c:	8b 45 10             	mov    0x10(%ebp),%eax
  80259f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8025a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8025a9:	e8 72 ff ff ff       	call   802520 <nsipc>
}
  8025ae:	c9                   	leave  
  8025af:	c3                   	ret    

008025b0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8025b0:	55                   	push   %ebp
  8025b1:	89 e5                	mov    %esp,%ebp
  8025b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8025b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8025be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8025c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8025cb:	e8 50 ff ff ff       	call   802520 <nsipc>
}
  8025d0:	c9                   	leave  
  8025d1:	c3                   	ret    

008025d2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8025d2:	55                   	push   %ebp
  8025d3:	89 e5                	mov    %esp,%ebp
  8025d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8025d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8025db:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8025e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8025e5:	e8 36 ff ff ff       	call   802520 <nsipc>
}
  8025ea:	c9                   	leave  
  8025eb:	c3                   	ret    

008025ec <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8025ec:	55                   	push   %ebp
  8025ed:	89 e5                	mov    %esp,%ebp
  8025ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8025f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025f5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8025fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025fd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802602:	b8 03 00 00 00       	mov    $0x3,%eax
  802607:	e8 14 ff ff ff       	call   802520 <nsipc>
}
  80260c:	c9                   	leave  
  80260d:	c3                   	ret    

0080260e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80260e:	55                   	push   %ebp
  80260f:	89 e5                	mov    %esp,%ebp
  802611:	53                   	push   %ebx
  802612:	83 ec 14             	sub    $0x14,%esp
  802615:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802618:	8b 45 08             	mov    0x8(%ebp),%eax
  80261b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802620:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802626:	7e 24                	jle    80264c <nsipc_send+0x3e>
  802628:	c7 44 24 0c c0 31 80 	movl   $0x8031c0,0xc(%esp)
  80262f:	00 
  802630:	c7 44 24 08 cc 31 80 	movl   $0x8031cc,0x8(%esp)
  802637:	00 
  802638:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80263f:	00 
  802640:	c7 04 24 e1 31 80 00 	movl   $0x8031e1,(%esp)
  802647:	e8 58 db ff ff       	call   8001a4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80264c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802650:	8b 45 0c             	mov    0xc(%ebp),%eax
  802653:	89 44 24 04          	mov    %eax,0x4(%esp)
  802657:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80265e:	e8 12 e7 ff ff       	call   800d75 <memmove>
	nsipcbuf.send.req_size = size;
  802663:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802669:	8b 45 14             	mov    0x14(%ebp),%eax
  80266c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802671:	b8 08 00 00 00       	mov    $0x8,%eax
  802676:	e8 a5 fe ff ff       	call   802520 <nsipc>
}
  80267b:	83 c4 14             	add    $0x14,%esp
  80267e:	5b                   	pop    %ebx
  80267f:	5d                   	pop    %ebp
  802680:	c3                   	ret    

00802681 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802681:	55                   	push   %ebp
  802682:	89 e5                	mov    %esp,%ebp
  802684:	56                   	push   %esi
  802685:	53                   	push   %ebx
  802686:	83 ec 10             	sub    $0x10,%esp
  802689:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80268c:	8b 45 08             	mov    0x8(%ebp),%eax
  80268f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802694:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80269a:	8b 45 14             	mov    0x14(%ebp),%eax
  80269d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8026a2:	b8 07 00 00 00       	mov    $0x7,%eax
  8026a7:	e8 74 fe ff ff       	call   802520 <nsipc>
  8026ac:	89 c3                	mov    %eax,%ebx
  8026ae:	85 c0                	test   %eax,%eax
  8026b0:	78 46                	js     8026f8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8026b2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8026b7:	7f 04                	jg     8026bd <nsipc_recv+0x3c>
  8026b9:	39 c6                	cmp    %eax,%esi
  8026bb:	7d 24                	jge    8026e1 <nsipc_recv+0x60>
  8026bd:	c7 44 24 0c ed 31 80 	movl   $0x8031ed,0xc(%esp)
  8026c4:	00 
  8026c5:	c7 44 24 08 cc 31 80 	movl   $0x8031cc,0x8(%esp)
  8026cc:	00 
  8026cd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8026d4:	00 
  8026d5:	c7 04 24 e1 31 80 00 	movl   $0x8031e1,(%esp)
  8026dc:	e8 c3 da ff ff       	call   8001a4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8026e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026e5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8026ec:	00 
  8026ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026f0:	89 04 24             	mov    %eax,(%esp)
  8026f3:	e8 7d e6 ff ff       	call   800d75 <memmove>
	}

	return r;
}
  8026f8:	89 d8                	mov    %ebx,%eax
  8026fa:	83 c4 10             	add    $0x10,%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5d                   	pop    %ebp
  802700:	c3                   	ret    

00802701 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802701:	55                   	push   %ebp
  802702:	89 e5                	mov    %esp,%ebp
  802704:	53                   	push   %ebx
  802705:	83 ec 14             	sub    $0x14,%esp
  802708:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80270b:	8b 45 08             	mov    0x8(%ebp),%eax
  80270e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802713:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802717:	8b 45 0c             	mov    0xc(%ebp),%eax
  80271a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80271e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802725:	e8 4b e6 ff ff       	call   800d75 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80272a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802730:	b8 05 00 00 00       	mov    $0x5,%eax
  802735:	e8 e6 fd ff ff       	call   802520 <nsipc>
}
  80273a:	83 c4 14             	add    $0x14,%esp
  80273d:	5b                   	pop    %ebx
  80273e:	5d                   	pop    %ebp
  80273f:	c3                   	ret    

00802740 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802740:	55                   	push   %ebp
  802741:	89 e5                	mov    %esp,%ebp
  802743:	53                   	push   %ebx
  802744:	83 ec 14             	sub    $0x14,%esp
  802747:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80274a:	8b 45 08             	mov    0x8(%ebp),%eax
  80274d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802752:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802756:	8b 45 0c             	mov    0xc(%ebp),%eax
  802759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80275d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802764:	e8 0c e6 ff ff       	call   800d75 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802769:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80276f:	b8 02 00 00 00       	mov    $0x2,%eax
  802774:	e8 a7 fd ff ff       	call   802520 <nsipc>
}
  802779:	83 c4 14             	add    $0x14,%esp
  80277c:	5b                   	pop    %ebx
  80277d:	5d                   	pop    %ebp
  80277e:	c3                   	ret    

0080277f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80277f:	55                   	push   %ebp
  802780:	89 e5                	mov    %esp,%ebp
  802782:	83 ec 18             	sub    $0x18,%esp
  802785:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802788:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80278b:	8b 45 08             	mov    0x8(%ebp),%eax
  80278e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802793:	b8 01 00 00 00       	mov    $0x1,%eax
  802798:	e8 83 fd ff ff       	call   802520 <nsipc>
  80279d:	89 c3                	mov    %eax,%ebx
  80279f:	85 c0                	test   %eax,%eax
  8027a1:	78 25                	js     8027c8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8027a3:	be 10 70 80 00       	mov    $0x807010,%esi
  8027a8:	8b 06                	mov    (%esi),%eax
  8027aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027ae:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8027b5:	00 
  8027b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b9:	89 04 24             	mov    %eax,(%esp)
  8027bc:	e8 b4 e5 ff ff       	call   800d75 <memmove>
		*addrlen = ret->ret_addrlen;
  8027c1:	8b 16                	mov    (%esi),%edx
  8027c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8027c6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8027c8:	89 d8                	mov    %ebx,%eax
  8027ca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8027cd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8027d0:	89 ec                	mov    %ebp,%esp
  8027d2:	5d                   	pop    %ebp
  8027d3:	c3                   	ret    

008027d4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027d4:	55                   	push   %ebp
  8027d5:	89 e5                	mov    %esp,%ebp
  8027d7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8027da:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8027e1:	75 30                	jne    802813 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8027e3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8027ea:	00 
  8027eb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8027f2:	ee 
  8027f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027fa:	e8 b9 ec ff ff       	call   8014b8 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8027ff:	c7 44 24 04 20 28 80 	movl   $0x802820,0x4(%esp)
  802806:	00 
  802807:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80280e:	e8 87 ea ff ff       	call   80129a <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802813:	8b 45 08             	mov    0x8(%ebp),%eax
  802816:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80281b:	c9                   	leave  
  80281c:	c3                   	ret    
  80281d:	00 00                	add    %al,(%eax)
	...

00802820 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802820:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802821:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802826:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802828:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  80282b:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  80282f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  802833:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  802836:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802838:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  80283c:	83 c4 08             	add    $0x8,%esp
        popal
  80283f:	61                   	popa   
        addl $0x4,%esp
  802840:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  802843:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802844:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802845:	c3                   	ret    
	...

00802850 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802850:	55                   	push   %ebp
  802851:	89 e5                	mov    %esp,%ebp
  802853:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802856:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80285c:	b8 01 00 00 00       	mov    $0x1,%eax
  802861:	39 ca                	cmp    %ecx,%edx
  802863:	75 04                	jne    802869 <ipc_find_env+0x19>
  802865:	b0 00                	mov    $0x0,%al
  802867:	eb 12                	jmp    80287b <ipc_find_env+0x2b>
  802869:	89 c2                	mov    %eax,%edx
  80286b:	c1 e2 07             	shl    $0x7,%edx
  80286e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802875:	8b 12                	mov    (%edx),%edx
  802877:	39 ca                	cmp    %ecx,%edx
  802879:	75 10                	jne    80288b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80287b:	89 c2                	mov    %eax,%edx
  80287d:	c1 e2 07             	shl    $0x7,%edx
  802880:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802887:	8b 00                	mov    (%eax),%eax
  802889:	eb 0e                	jmp    802899 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80288b:	83 c0 01             	add    $0x1,%eax
  80288e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802893:	75 d4                	jne    802869 <ipc_find_env+0x19>
  802895:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802899:	5d                   	pop    %ebp
  80289a:	c3                   	ret    

0080289b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80289b:	55                   	push   %ebp
  80289c:	89 e5                	mov    %esp,%ebp
  80289e:	57                   	push   %edi
  80289f:	56                   	push   %esi
  8028a0:	53                   	push   %ebx
  8028a1:	83 ec 1c             	sub    $0x1c,%esp
  8028a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8028a7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8028ad:	85 db                	test   %ebx,%ebx
  8028af:	74 19                	je     8028ca <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8028b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8028b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028c0:	89 34 24             	mov    %esi,(%esp)
  8028c3:	e8 91 e9 ff ff       	call   801259 <sys_ipc_try_send>
  8028c8:	eb 1b                	jmp    8028e5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8028ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8028cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028d1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8028d8:	ee 
  8028d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028dd:	89 34 24             	mov    %esi,(%esp)
  8028e0:	e8 74 e9 ff ff       	call   801259 <sys_ipc_try_send>
           if(ret == 0)
  8028e5:	85 c0                	test   %eax,%eax
  8028e7:	74 28                	je     802911 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8028e9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028ec:	74 1c                	je     80290a <ipc_send+0x6f>
              panic("ipc send error");
  8028ee:	c7 44 24 08 02 32 80 	movl   $0x803202,0x8(%esp)
  8028f5:	00 
  8028f6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8028fd:	00 
  8028fe:	c7 04 24 11 32 80 00 	movl   $0x803211,(%esp)
  802905:	e8 9a d8 ff ff       	call   8001a4 <_panic>
           sys_yield();
  80290a:	e8 16 ec ff ff       	call   801525 <sys_yield>
        }
  80290f:	eb 9c                	jmp    8028ad <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802911:	83 c4 1c             	add    $0x1c,%esp
  802914:	5b                   	pop    %ebx
  802915:	5e                   	pop    %esi
  802916:	5f                   	pop    %edi
  802917:	5d                   	pop    %ebp
  802918:	c3                   	ret    

00802919 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802919:	55                   	push   %ebp
  80291a:	89 e5                	mov    %esp,%ebp
  80291c:	56                   	push   %esi
  80291d:	53                   	push   %ebx
  80291e:	83 ec 10             	sub    $0x10,%esp
  802921:	8b 75 08             	mov    0x8(%ebp),%esi
  802924:	8b 45 0c             	mov    0xc(%ebp),%eax
  802927:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80292a:	85 c0                	test   %eax,%eax
  80292c:	75 0e                	jne    80293c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80292e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802935:	e8 b4 e8 ff ff       	call   8011ee <sys_ipc_recv>
  80293a:	eb 08                	jmp    802944 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80293c:	89 04 24             	mov    %eax,(%esp)
  80293f:	e8 aa e8 ff ff       	call   8011ee <sys_ipc_recv>
        if(ret == 0){
  802944:	85 c0                	test   %eax,%eax
  802946:	75 26                	jne    80296e <ipc_recv+0x55>
           if(from_env_store)
  802948:	85 f6                	test   %esi,%esi
  80294a:	74 0a                	je     802956 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80294c:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802951:	8b 40 78             	mov    0x78(%eax),%eax
  802954:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802956:	85 db                	test   %ebx,%ebx
  802958:	74 0a                	je     802964 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80295a:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80295f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802962:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802964:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802969:	8b 40 74             	mov    0x74(%eax),%eax
  80296c:	eb 14                	jmp    802982 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80296e:	85 f6                	test   %esi,%esi
  802970:	74 06                	je     802978 <ipc_recv+0x5f>
              *from_env_store = 0;
  802972:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802978:	85 db                	test   %ebx,%ebx
  80297a:	74 06                	je     802982 <ipc_recv+0x69>
              *perm_store = 0;
  80297c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802982:	83 c4 10             	add    $0x10,%esp
  802985:	5b                   	pop    %ebx
  802986:	5e                   	pop    %esi
  802987:	5d                   	pop    %ebp
  802988:	c3                   	ret    
  802989:	00 00                	add    %al,(%eax)
	...

0080298c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80298c:	55                   	push   %ebp
  80298d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80298f:	8b 45 08             	mov    0x8(%ebp),%eax
  802992:	89 c2                	mov    %eax,%edx
  802994:	c1 ea 16             	shr    $0x16,%edx
  802997:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80299e:	f6 c2 01             	test   $0x1,%dl
  8029a1:	74 20                	je     8029c3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8029a3:	c1 e8 0c             	shr    $0xc,%eax
  8029a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8029ad:	a8 01                	test   $0x1,%al
  8029af:	74 12                	je     8029c3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029b1:	c1 e8 0c             	shr    $0xc,%eax
  8029b4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8029b9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8029be:	0f b7 c0             	movzwl %ax,%eax
  8029c1:	eb 05                	jmp    8029c8 <pageref+0x3c>
  8029c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029c8:	5d                   	pop    %ebp
  8029c9:	c3                   	ret    
  8029ca:	00 00                	add    %al,(%eax)
  8029cc:	00 00                	add    %al,(%eax)
	...

008029d0 <__udivdi3>:
  8029d0:	55                   	push   %ebp
  8029d1:	89 e5                	mov    %esp,%ebp
  8029d3:	57                   	push   %edi
  8029d4:	56                   	push   %esi
  8029d5:	83 ec 10             	sub    $0x10,%esp
  8029d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8029db:	8b 55 08             	mov    0x8(%ebp),%edx
  8029de:	8b 75 10             	mov    0x10(%ebp),%esi
  8029e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029e4:	85 c0                	test   %eax,%eax
  8029e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8029e9:	75 35                	jne    802a20 <__udivdi3+0x50>
  8029eb:	39 fe                	cmp    %edi,%esi
  8029ed:	77 61                	ja     802a50 <__udivdi3+0x80>
  8029ef:	85 f6                	test   %esi,%esi
  8029f1:	75 0b                	jne    8029fe <__udivdi3+0x2e>
  8029f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8029f8:	31 d2                	xor    %edx,%edx
  8029fa:	f7 f6                	div    %esi
  8029fc:	89 c6                	mov    %eax,%esi
  8029fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802a01:	31 d2                	xor    %edx,%edx
  802a03:	89 f8                	mov    %edi,%eax
  802a05:	f7 f6                	div    %esi
  802a07:	89 c7                	mov    %eax,%edi
  802a09:	89 c8                	mov    %ecx,%eax
  802a0b:	f7 f6                	div    %esi
  802a0d:	89 c1                	mov    %eax,%ecx
  802a0f:	89 fa                	mov    %edi,%edx
  802a11:	89 c8                	mov    %ecx,%eax
  802a13:	83 c4 10             	add    $0x10,%esp
  802a16:	5e                   	pop    %esi
  802a17:	5f                   	pop    %edi
  802a18:	5d                   	pop    %ebp
  802a19:	c3                   	ret    
  802a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a20:	39 f8                	cmp    %edi,%eax
  802a22:	77 1c                	ja     802a40 <__udivdi3+0x70>
  802a24:	0f bd d0             	bsr    %eax,%edx
  802a27:	83 f2 1f             	xor    $0x1f,%edx
  802a2a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802a2d:	75 39                	jne    802a68 <__udivdi3+0x98>
  802a2f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802a32:	0f 86 a0 00 00 00    	jbe    802ad8 <__udivdi3+0x108>
  802a38:	39 f8                	cmp    %edi,%eax
  802a3a:	0f 82 98 00 00 00    	jb     802ad8 <__udivdi3+0x108>
  802a40:	31 ff                	xor    %edi,%edi
  802a42:	31 c9                	xor    %ecx,%ecx
  802a44:	89 c8                	mov    %ecx,%eax
  802a46:	89 fa                	mov    %edi,%edx
  802a48:	83 c4 10             	add    $0x10,%esp
  802a4b:	5e                   	pop    %esi
  802a4c:	5f                   	pop    %edi
  802a4d:	5d                   	pop    %ebp
  802a4e:	c3                   	ret    
  802a4f:	90                   	nop
  802a50:	89 d1                	mov    %edx,%ecx
  802a52:	89 fa                	mov    %edi,%edx
  802a54:	89 c8                	mov    %ecx,%eax
  802a56:	31 ff                	xor    %edi,%edi
  802a58:	f7 f6                	div    %esi
  802a5a:	89 c1                	mov    %eax,%ecx
  802a5c:	89 fa                	mov    %edi,%edx
  802a5e:	89 c8                	mov    %ecx,%eax
  802a60:	83 c4 10             	add    $0x10,%esp
  802a63:	5e                   	pop    %esi
  802a64:	5f                   	pop    %edi
  802a65:	5d                   	pop    %ebp
  802a66:	c3                   	ret    
  802a67:	90                   	nop
  802a68:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a6c:	89 f2                	mov    %esi,%edx
  802a6e:	d3 e0                	shl    %cl,%eax
  802a70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a73:	b8 20 00 00 00       	mov    $0x20,%eax
  802a78:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802a7b:	89 c1                	mov    %eax,%ecx
  802a7d:	d3 ea                	shr    %cl,%edx
  802a7f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a83:	0b 55 ec             	or     -0x14(%ebp),%edx
  802a86:	d3 e6                	shl    %cl,%esi
  802a88:	89 c1                	mov    %eax,%ecx
  802a8a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802a8d:	89 fe                	mov    %edi,%esi
  802a8f:	d3 ee                	shr    %cl,%esi
  802a91:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a95:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a9b:	d3 e7                	shl    %cl,%edi
  802a9d:	89 c1                	mov    %eax,%ecx
  802a9f:	d3 ea                	shr    %cl,%edx
  802aa1:	09 d7                	or     %edx,%edi
  802aa3:	89 f2                	mov    %esi,%edx
  802aa5:	89 f8                	mov    %edi,%eax
  802aa7:	f7 75 ec             	divl   -0x14(%ebp)
  802aaa:	89 d6                	mov    %edx,%esi
  802aac:	89 c7                	mov    %eax,%edi
  802aae:	f7 65 e8             	mull   -0x18(%ebp)
  802ab1:	39 d6                	cmp    %edx,%esi
  802ab3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802ab6:	72 30                	jb     802ae8 <__udivdi3+0x118>
  802ab8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802abb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802abf:	d3 e2                	shl    %cl,%edx
  802ac1:	39 c2                	cmp    %eax,%edx
  802ac3:	73 05                	jae    802aca <__udivdi3+0xfa>
  802ac5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802ac8:	74 1e                	je     802ae8 <__udivdi3+0x118>
  802aca:	89 f9                	mov    %edi,%ecx
  802acc:	31 ff                	xor    %edi,%edi
  802ace:	e9 71 ff ff ff       	jmp    802a44 <__udivdi3+0x74>
  802ad3:	90                   	nop
  802ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ad8:	31 ff                	xor    %edi,%edi
  802ada:	b9 01 00 00 00       	mov    $0x1,%ecx
  802adf:	e9 60 ff ff ff       	jmp    802a44 <__udivdi3+0x74>
  802ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ae8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802aeb:	31 ff                	xor    %edi,%edi
  802aed:	89 c8                	mov    %ecx,%eax
  802aef:	89 fa                	mov    %edi,%edx
  802af1:	83 c4 10             	add    $0x10,%esp
  802af4:	5e                   	pop    %esi
  802af5:	5f                   	pop    %edi
  802af6:	5d                   	pop    %ebp
  802af7:	c3                   	ret    
	...

00802b00 <__umoddi3>:
  802b00:	55                   	push   %ebp
  802b01:	89 e5                	mov    %esp,%ebp
  802b03:	57                   	push   %edi
  802b04:	56                   	push   %esi
  802b05:	83 ec 20             	sub    $0x20,%esp
  802b08:	8b 55 14             	mov    0x14(%ebp),%edx
  802b0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b0e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802b11:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b14:	85 d2                	test   %edx,%edx
  802b16:	89 c8                	mov    %ecx,%eax
  802b18:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802b1b:	75 13                	jne    802b30 <__umoddi3+0x30>
  802b1d:	39 f7                	cmp    %esi,%edi
  802b1f:	76 3f                	jbe    802b60 <__umoddi3+0x60>
  802b21:	89 f2                	mov    %esi,%edx
  802b23:	f7 f7                	div    %edi
  802b25:	89 d0                	mov    %edx,%eax
  802b27:	31 d2                	xor    %edx,%edx
  802b29:	83 c4 20             	add    $0x20,%esp
  802b2c:	5e                   	pop    %esi
  802b2d:	5f                   	pop    %edi
  802b2e:	5d                   	pop    %ebp
  802b2f:	c3                   	ret    
  802b30:	39 f2                	cmp    %esi,%edx
  802b32:	77 4c                	ja     802b80 <__umoddi3+0x80>
  802b34:	0f bd ca             	bsr    %edx,%ecx
  802b37:	83 f1 1f             	xor    $0x1f,%ecx
  802b3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802b3d:	75 51                	jne    802b90 <__umoddi3+0x90>
  802b3f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802b42:	0f 87 e0 00 00 00    	ja     802c28 <__umoddi3+0x128>
  802b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b4b:	29 f8                	sub    %edi,%eax
  802b4d:	19 d6                	sbb    %edx,%esi
  802b4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b55:	89 f2                	mov    %esi,%edx
  802b57:	83 c4 20             	add    $0x20,%esp
  802b5a:	5e                   	pop    %esi
  802b5b:	5f                   	pop    %edi
  802b5c:	5d                   	pop    %ebp
  802b5d:	c3                   	ret    
  802b5e:	66 90                	xchg   %ax,%ax
  802b60:	85 ff                	test   %edi,%edi
  802b62:	75 0b                	jne    802b6f <__umoddi3+0x6f>
  802b64:	b8 01 00 00 00       	mov    $0x1,%eax
  802b69:	31 d2                	xor    %edx,%edx
  802b6b:	f7 f7                	div    %edi
  802b6d:	89 c7                	mov    %eax,%edi
  802b6f:	89 f0                	mov    %esi,%eax
  802b71:	31 d2                	xor    %edx,%edx
  802b73:	f7 f7                	div    %edi
  802b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b78:	f7 f7                	div    %edi
  802b7a:	eb a9                	jmp    802b25 <__umoddi3+0x25>
  802b7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b80:	89 c8                	mov    %ecx,%eax
  802b82:	89 f2                	mov    %esi,%edx
  802b84:	83 c4 20             	add    $0x20,%esp
  802b87:	5e                   	pop    %esi
  802b88:	5f                   	pop    %edi
  802b89:	5d                   	pop    %ebp
  802b8a:	c3                   	ret    
  802b8b:	90                   	nop
  802b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b90:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b94:	d3 e2                	shl    %cl,%edx
  802b96:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b99:	ba 20 00 00 00       	mov    $0x20,%edx
  802b9e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802ba1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802ba4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802ba8:	89 fa                	mov    %edi,%edx
  802baa:	d3 ea                	shr    %cl,%edx
  802bac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bb0:	0b 55 f4             	or     -0xc(%ebp),%edx
  802bb3:	d3 e7                	shl    %cl,%edi
  802bb5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bb9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802bbc:	89 f2                	mov    %esi,%edx
  802bbe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802bc1:	89 c7                	mov    %eax,%edi
  802bc3:	d3 ea                	shr    %cl,%edx
  802bc5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bc9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802bcc:	89 c2                	mov    %eax,%edx
  802bce:	d3 e6                	shl    %cl,%esi
  802bd0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bd4:	d3 ea                	shr    %cl,%edx
  802bd6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bda:	09 d6                	or     %edx,%esi
  802bdc:	89 f0                	mov    %esi,%eax
  802bde:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802be1:	d3 e7                	shl    %cl,%edi
  802be3:	89 f2                	mov    %esi,%edx
  802be5:	f7 75 f4             	divl   -0xc(%ebp)
  802be8:	89 d6                	mov    %edx,%esi
  802bea:	f7 65 e8             	mull   -0x18(%ebp)
  802bed:	39 d6                	cmp    %edx,%esi
  802bef:	72 2b                	jb     802c1c <__umoddi3+0x11c>
  802bf1:	39 c7                	cmp    %eax,%edi
  802bf3:	72 23                	jb     802c18 <__umoddi3+0x118>
  802bf5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bf9:	29 c7                	sub    %eax,%edi
  802bfb:	19 d6                	sbb    %edx,%esi
  802bfd:	89 f0                	mov    %esi,%eax
  802bff:	89 f2                	mov    %esi,%edx
  802c01:	d3 ef                	shr    %cl,%edi
  802c03:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802c07:	d3 e0                	shl    %cl,%eax
  802c09:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802c0d:	09 f8                	or     %edi,%eax
  802c0f:	d3 ea                	shr    %cl,%edx
  802c11:	83 c4 20             	add    $0x20,%esp
  802c14:	5e                   	pop    %esi
  802c15:	5f                   	pop    %edi
  802c16:	5d                   	pop    %ebp
  802c17:	c3                   	ret    
  802c18:	39 d6                	cmp    %edx,%esi
  802c1a:	75 d9                	jne    802bf5 <__umoddi3+0xf5>
  802c1c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802c1f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802c22:	eb d1                	jmp    802bf5 <__umoddi3+0xf5>
  802c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c28:	39 f2                	cmp    %esi,%edx
  802c2a:	0f 82 18 ff ff ff    	jb     802b48 <__umoddi3+0x48>
  802c30:	e9 1d ff ff ff       	jmp    802b52 <__umoddi3+0x52>
