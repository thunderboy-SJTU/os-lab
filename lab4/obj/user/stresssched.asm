
obj/user/stresssched:     file format elf32-i386


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
  800048:	e8 b8 13 00 00       	call   801405 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800054:	e8 79 14 00 00       	call   8014d2 <fork>
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
  800086:	e8 f8 12 00 00       	call   801383 <sys_yield>
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
  8000b3:	e8 cb 12 00 00       	call   801383 <sys_yield>
  8000b8:	89 f0                	mov    %esi,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000ba:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000c0:	83 c2 01             	add    $0x1,%edx
  8000c3:	89 15 04 20 80 00    	mov    %edx,0x802004
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
  8000db:	a1 04 20 80 00       	mov    0x802004,%eax
  8000e0:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000e5:	74 25                	je     80010c <umain+0xcc>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000e7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f0:	c7 44 24 08 40 1b 80 	movl   $0x801b40,0x8(%esp)
  8000f7:	00 
  8000f8:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000ff:	00 
  800100:	c7 04 24 68 1b 80 00 	movl   $0x801b68,(%esp)
  800107:	e8 90 00 00 00       	call   80019c <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  80010c:	a1 08 20 80 00       	mov    0x802008,%eax
  800111:	8b 50 5c             	mov    0x5c(%eax),%edx
  800114:	8b 40 48             	mov    0x48(%eax),%eax
  800117:	89 54 24 08          	mov    %edx,0x8(%esp)
  80011b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011f:	c7 04 24 7b 1b 80 00 	movl   $0x801b7b,(%esp)
  800126:	e8 42 01 00 00       	call   80026d <cprintf>

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
  800146:	e8 ba 12 00 00       	call   801405 <sys_getenvid>
  80014b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800150:	89 c2                	mov    %eax,%edx
  800152:	c1 e2 07             	shl    $0x7,%edx
  800155:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80015c:	a3 08 20 80 00       	mov    %eax,0x802008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800161:	85 f6                	test   %esi,%esi
  800163:	7e 07                	jle    80016c <libmain+0x38>
		binaryname = argv[0];
  800165:	8b 03                	mov    (%ebx),%eax
  800167:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  80018e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800195:	e8 ab 12 00 00       	call   801445 <sys_env_destroy>
}
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001a4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8001a7:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	74 10                	je     8001c0 <_panic+0x24>
		cprintf("%s: ", argv0);
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  8001bb:	e8 ad 00 00 00       	call   80026d <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c0:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c6:	e8 3a 12 00 00       	call   801405 <sys_getenvid>
  8001cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ce:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	c7 04 24 a8 1b 80 00 	movl   $0x801ba8,(%esp)
  8001e8:	e8 80 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 10 00 00 00       	call   80020c <vcprintf>
	cprintf("\n");
  8001fc:	c7 04 24 97 1b 80 00 	movl   $0x801b97,(%esp)
  800203:	e8 65 00 00 00       	call   80026d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800208:	cc                   	int3   
  800209:	eb fd                	jmp    800208 <_panic+0x6c>
	...

0080020c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800215:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021c:	00 00 00 
	b.cnt = 0;
  80021f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800226:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800229:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	89 44 24 08          	mov    %eax,0x8(%esp)
  800237:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	c7 04 24 87 02 80 00 	movl   $0x800287,(%esp)
  800248:	e8 cf 01 00 00       	call   80041c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	e8 67 0d 00 00       	call   800fcc <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800276:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	e8 87 ff ff ff       	call   80020c <vcprintf>
	va_end(ap);

	return cnt;
}
  800285:	c9                   	leave  
  800286:	c3                   	ret    

00800287 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	53                   	push   %ebx
  80028b:	83 ec 14             	sub    $0x14,%esp
  80028e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800291:	8b 03                	mov    (%ebx),%eax
  800293:	8b 55 08             	mov    0x8(%ebp),%edx
  800296:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029a:	83 c0 01             	add    $0x1,%eax
  80029d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a4:	75 19                	jne    8002bf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002a6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002ad:	00 
  8002ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 13 0d 00 00       	call   800fcc <sys_cputs>
		b->idx = 0;
  8002b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c3:	83 c4 14             	add    $0x14,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    
  8002c9:	00 00                	add    %al,(%eax)
  8002cb:	00 00                	add    %al,(%eax)
  8002cd:	00 00                	add    %al,(%eax)
	...

008002d0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 4c             	sub    $0x4c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d6                	mov    %edx,%esi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8002f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fb:	39 d1                	cmp    %edx,%ecx
  8002fd:	72 07                	jb     800306 <printnum_v2+0x36>
  8002ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800302:	39 d0                	cmp    %edx,%eax
  800304:	77 5f                	ja     800365 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800306:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80030a:	83 eb 01             	sub    $0x1,%ebx
  80030d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800311:	89 44 24 08          	mov    %eax,0x8(%esp)
  800315:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800319:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80031d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800320:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800323:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800326:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800331:	00 
  800332:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80033b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033f:	e8 8c 15 00 00       	call   8018d0 <__udivdi3>
  800344:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800347:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80034a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	89 54 24 04          	mov    %edx,0x4(%esp)
  800359:	89 f2                	mov    %esi,%edx
  80035b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035e:	e8 6d ff ff ff       	call   8002d0 <printnum_v2>
  800363:	eb 1e                	jmp    800383 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800365:	83 ff 2d             	cmp    $0x2d,%edi
  800368:	74 19                	je     800383 <printnum_v2+0xb3>
		while (--width > 0)
  80036a:	83 eb 01             	sub    $0x1,%ebx
  80036d:	85 db                	test   %ebx,%ebx
  80036f:	90                   	nop
  800370:	7e 11                	jle    800383 <printnum_v2+0xb3>
			putch(padc, putdat);
  800372:	89 74 24 04          	mov    %esi,0x4(%esp)
  800376:	89 3c 24             	mov    %edi,(%esp)
  800379:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80037c:	83 eb 01             	sub    $0x1,%ebx
  80037f:	85 db                	test   %ebx,%ebx
  800381:	7f ef                	jg     800372 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800383:	89 74 24 04          	mov    %esi,0x4(%esp)
  800387:	8b 74 24 04          	mov    0x4(%esp),%esi
  80038b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800392:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800399:	00 
  80039a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80039d:	89 14 24             	mov    %edx,(%esp)
  8003a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003a7:	e8 54 16 00 00       	call   801a00 <__umoddi3>
  8003ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b0:	0f be 80 cb 1b 80 00 	movsbl 0x801bcb(%eax),%eax
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003bd:	83 c4 4c             	add    $0x4c,%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c8:	83 fa 01             	cmp    $0x1,%edx
  8003cb:	7e 0e                	jle    8003db <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d2:	89 08                	mov    %ecx,(%eax)
  8003d4:	8b 02                	mov    (%edx),%eax
  8003d6:	8b 52 04             	mov    0x4(%edx),%edx
  8003d9:	eb 22                	jmp    8003fd <getuint+0x38>
	else if (lflag)
  8003db:	85 d2                	test   %edx,%edx
  8003dd:	74 10                	je     8003ef <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ed:	eb 0e                	jmp    8003fd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ef:	8b 10                	mov    (%eax),%edx
  8003f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 02                	mov    (%edx),%eax
  8003f8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800405:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800409:	8b 10                	mov    (%eax),%edx
  80040b:	3b 50 04             	cmp    0x4(%eax),%edx
  80040e:	73 0a                	jae    80041a <sprintputch+0x1b>
		*b->buf++ = ch;
  800410:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800413:	88 0a                	mov    %cl,(%edx)
  800415:	83 c2 01             	add    $0x1,%edx
  800418:	89 10                	mov    %edx,(%eax)
}
  80041a:	5d                   	pop    %ebp
  80041b:	c3                   	ret    

0080041c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	57                   	push   %edi
  800420:	56                   	push   %esi
  800421:	53                   	push   %ebx
  800422:	83 ec 6c             	sub    $0x6c,%esp
  800425:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800428:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80042f:	eb 1a                	jmp    80044b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800431:	85 c0                	test   %eax,%eax
  800433:	0f 84 66 06 00 00    	je     800a9f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800439:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	ff 55 08             	call   *0x8(%ebp)
  800446:	eb 03                	jmp    80044b <vprintfmt+0x2f>
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044b:	0f b6 07             	movzbl (%edi),%eax
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	83 f8 25             	cmp    $0x25,%eax
  800454:	75 db                	jne    800431 <vprintfmt+0x15>
  800456:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80045a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800466:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80046b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800472:	be 00 00 00 00       	mov    $0x0,%esi
  800477:	eb 06                	jmp    80047f <vprintfmt+0x63>
  800479:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80047d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	0f b6 17             	movzbl (%edi),%edx
  800482:	0f b6 c2             	movzbl %dl,%eax
  800485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800488:	8d 47 01             	lea    0x1(%edi),%eax
  80048b:	83 ea 23             	sub    $0x23,%edx
  80048e:	80 fa 55             	cmp    $0x55,%dl
  800491:	0f 87 60 05 00 00    	ja     8009f7 <vprintfmt+0x5db>
  800497:	0f b6 d2             	movzbl %dl,%edx
  80049a:	ff 24 95 00 1d 80 00 	jmp    *0x801d00(,%edx,4)
  8004a1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8004a6:	eb d5                	jmp    80047d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004ab:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8004ae:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004b1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004b4:	83 ff 09             	cmp    $0x9,%edi
  8004b7:	76 08                	jbe    8004c1 <vprintfmt+0xa5>
  8004b9:	eb 40                	jmp    8004fb <vprintfmt+0xdf>
  8004bb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8004bf:	eb bc                	jmp    80047d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004c4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8004c7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8004cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ce:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004d1:	83 ff 09             	cmp    $0x9,%edi
  8004d4:	76 eb                	jbe    8004c1 <vprintfmt+0xa5>
  8004d6:	eb 23                	jmp    8004fb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004db:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004de:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004e1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8004e3:	eb 16                	jmp    8004fb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8004e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e8:	c1 fa 1f             	sar    $0x1f,%edx
  8004eb:	f7 d2                	not    %edx
  8004ed:	21 55 d8             	and    %edx,-0x28(%ebp)
  8004f0:	eb 8b                	jmp    80047d <vprintfmt+0x61>
  8004f2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004f9:	eb 82                	jmp    80047d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8004fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ff:	0f 89 78 ff ff ff    	jns    80047d <vprintfmt+0x61>
  800505:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800508:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80050b:	e9 6d ff ff ff       	jmp    80047d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800510:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800513:	e9 65 ff ff ff       	jmp    80047d <vprintfmt+0x61>
  800518:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 55 0c             	mov    0xc(%ebp),%edx
  800527:	89 54 24 04          	mov    %edx,0x4(%esp)
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800536:	e9 10 ff ff ff       	jmp    80044b <vprintfmt+0x2f>
  80053b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 c2                	mov    %eax,%edx
  80054b:	c1 fa 1f             	sar    $0x1f,%edx
  80054e:	31 d0                	xor    %edx,%eax
  800550:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800552:	83 f8 08             	cmp    $0x8,%eax
  800555:	7f 0b                	jg     800562 <vprintfmt+0x146>
  800557:	8b 14 85 60 1e 80 00 	mov    0x801e60(,%eax,4),%edx
  80055e:	85 d2                	test   %edx,%edx
  800560:	75 26                	jne    800588 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800562:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800566:	c7 44 24 08 dc 1b 80 	movl   $0x801bdc,0x8(%esp)
  80056d:	00 
  80056e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800571:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800575:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800578:	89 1c 24             	mov    %ebx,(%esp)
  80057b:	e8 a7 05 00 00       	call   800b27 <printfmt>
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800583:	e9 c3 fe ff ff       	jmp    80044b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800588:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058c:	c7 44 24 08 e5 1b 80 	movl   $0x801be5,0x8(%esp)
  800593:	00 
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059b:	8b 55 08             	mov    0x8(%ebp),%edx
  80059e:	89 14 24             	mov    %edx,(%esp)
  8005a1:	e8 81 05 00 00       	call   800b27 <printfmt>
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 9d fe ff ff       	jmp    80044b <vprintfmt+0x2f>
  8005ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b1:	89 c7                	mov    %eax,%edi
  8005b3:	89 d9                	mov    %ebx,%ecx
  8005b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 30                	mov    (%eax),%esi
  8005c6:	85 f6                	test   %esi,%esi
  8005c8:	75 05                	jne    8005cf <vprintfmt+0x1b3>
  8005ca:	be e8 1b 80 00       	mov    $0x801be8,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8005cf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005d3:	7e 06                	jle    8005db <vprintfmt+0x1bf>
  8005d5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8005d9:	75 10                	jne    8005eb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005db:	0f be 06             	movsbl (%esi),%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	0f 85 a2 00 00 00    	jne    800688 <vprintfmt+0x26c>
  8005e6:	e9 92 00 00 00       	jmp    80067d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ef:	89 34 24             	mov    %esi,(%esp)
  8005f2:	e8 74 05 00 00       	call   800b6b <strnlen>
  8005f7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005fa:	29 c2                	sub    %eax,%edx
  8005fc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005ff:	85 d2                	test   %edx,%edx
  800601:	7e d8                	jle    8005db <vprintfmt+0x1bf>
					putch(padc, putdat);
  800603:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800607:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80060a:	89 d3                	mov    %edx,%ebx
  80060c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80060f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800612:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800615:	89 ce                	mov    %ecx,%esi
  800617:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061b:	89 34 24             	mov    %esi,(%esp)
  80061e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800621:	83 eb 01             	sub    $0x1,%ebx
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f ef                	jg     800617 <vprintfmt+0x1fb>
  800628:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80062b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800631:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800638:	eb a1                	jmp    8005db <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80063e:	74 1b                	je     80065b <vprintfmt+0x23f>
  800640:	8d 50 e0             	lea    -0x20(%eax),%edx
  800643:	83 fa 5e             	cmp    $0x5e,%edx
  800646:	76 13                	jbe    80065b <vprintfmt+0x23f>
					putch('?', putdat);
  800648:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800656:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800659:	eb 0d                	jmp    800668 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80065b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800662:	89 04 24             	mov    %eax,(%esp)
  800665:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800668:	83 ef 01             	sub    $0x1,%edi
  80066b:	0f be 06             	movsbl (%esi),%eax
  80066e:	85 c0                	test   %eax,%eax
  800670:	74 05                	je     800677 <vprintfmt+0x25b>
  800672:	83 c6 01             	add    $0x1,%esi
  800675:	eb 1a                	jmp    800691 <vprintfmt+0x275>
  800677:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80067a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800681:	7f 1f                	jg     8006a2 <vprintfmt+0x286>
  800683:	e9 c0 fd ff ff       	jmp    800448 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800688:	83 c6 01             	add    $0x1,%esi
  80068b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80068e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800691:	85 db                	test   %ebx,%ebx
  800693:	78 a5                	js     80063a <vprintfmt+0x21e>
  800695:	83 eb 01             	sub    $0x1,%ebx
  800698:	79 a0                	jns    80063a <vprintfmt+0x21e>
  80069a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80069d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006a0:	eb db                	jmp    80067d <vprintfmt+0x261>
  8006a2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006a8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8006ab:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bb:	83 eb 01             	sub    $0x1,%ebx
  8006be:	85 db                	test   %ebx,%ebx
  8006c0:	7f ec                	jg     8006ae <vprintfmt+0x292>
  8006c2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006c5:	e9 81 fd ff ff       	jmp    80044b <vprintfmt+0x2f>
  8006ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cd:	83 fe 01             	cmp    $0x1,%esi
  8006d0:	7e 10                	jle    8006e2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 08             	lea    0x8(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006db:	8b 18                	mov    (%eax),%ebx
  8006dd:	8b 70 04             	mov    0x4(%eax),%esi
  8006e0:	eb 26                	jmp    800708 <vprintfmt+0x2ec>
	else if (lflag)
  8006e2:	85 f6                	test   %esi,%esi
  8006e4:	74 12                	je     8006f8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ef:	8b 18                	mov    (%eax),%ebx
  8006f1:	89 de                	mov    %ebx,%esi
  8006f3:	c1 fe 1f             	sar    $0x1f,%esi
  8006f6:	eb 10                	jmp    800708 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 18                	mov    (%eax),%ebx
  800703:	89 de                	mov    %ebx,%esi
  800705:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800708:	83 f9 01             	cmp    $0x1,%ecx
  80070b:	75 1e                	jne    80072b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80070d:	85 f6                	test   %esi,%esi
  80070f:	78 1a                	js     80072b <vprintfmt+0x30f>
  800711:	85 f6                	test   %esi,%esi
  800713:	7f 05                	jg     80071a <vprintfmt+0x2fe>
  800715:	83 fb 00             	cmp    $0x0,%ebx
  800718:	76 11                	jbe    80072b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80071a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800721:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800728:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80072b:	85 f6                	test   %esi,%esi
  80072d:	78 13                	js     800742 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800732:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800735:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800738:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073d:	e9 da 00 00 00       	jmp    80081c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800742:	8b 45 0c             	mov    0xc(%ebp),%eax
  800745:	89 44 24 04          	mov    %eax,0x4(%esp)
  800749:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800750:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800753:	89 da                	mov    %ebx,%edx
  800755:	89 f1                	mov    %esi,%ecx
  800757:	f7 da                	neg    %edx
  800759:	83 d1 00             	adc    $0x0,%ecx
  80075c:	f7 d9                	neg    %ecx
  80075e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800761:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800764:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800767:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076c:	e9 ab 00 00 00       	jmp    80081c <vprintfmt+0x400>
  800771:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800774:	89 f2                	mov    %esi,%edx
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 47 fc ff ff       	call   8003c5 <getuint>
  80077e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800781:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80078c:	e9 8b 00 00 00       	jmp    80081c <vprintfmt+0x400>
  800791:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800797:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80079b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8007a5:	89 f2                	mov    %esi,%edx
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007aa:	e8 16 fc ff ff       	call   8003c5 <getuint>
  8007af:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007b2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8007bd:	eb 5d                	jmp    80081c <vprintfmt+0x400>
  8007bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007d0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007de:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 50 04             	lea    0x4(%eax),%edx
  8007e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ea:	8b 10                	mov    (%eax),%edx
  8007ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007f4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007fa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ff:	eb 1b                	jmp    80081c <vprintfmt+0x400>
  800801:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800804:	89 f2                	mov    %esi,%edx
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
  800809:	e8 b7 fb ff ff       	call   8003c5 <getuint>
  80080e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800811:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800814:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800817:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800820:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800823:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800826:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80082a:	77 09                	ja     800835 <vprintfmt+0x419>
  80082c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80082f:	0f 82 ac 00 00 00    	jb     8008e1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800835:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800838:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80083c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80083f:	83 ea 01             	sub    $0x1,%edx
  800842:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800846:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80084e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800852:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800855:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800858:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80085b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80085f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800866:	00 
  800867:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80086a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80086d:	89 0c 24             	mov    %ecx,(%esp)
  800870:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800874:	e8 57 10 00 00       	call   8018d0 <__udivdi3>
  800879:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80087c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80087f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800883:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800887:	89 04 24             	mov    %eax,(%esp)
  80088a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	e8 37 fa ff ff       	call   8002d0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80089c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008b2:	00 
  8008b3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8008b6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8008b9:	89 14 24             	mov    %edx,(%esp)
  8008bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008c0:	e8 3b 11 00 00       	call   801a00 <__umoddi3>
  8008c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c9:	0f be 80 cb 1b 80 00 	movsbl 0x801bcb(%eax),%eax
  8008d0:	89 04 24             	mov    %eax,(%esp)
  8008d3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8008d6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008da:	74 54                	je     800930 <vprintfmt+0x514>
  8008dc:	e9 67 fb ff ff       	jmp    800448 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8008e1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008e5:	8d 76 00             	lea    0x0(%esi),%esi
  8008e8:	0f 84 2a 01 00 00    	je     800a18 <vprintfmt+0x5fc>
		while (--width > 0)
  8008ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008f1:	83 ef 01             	sub    $0x1,%edi
  8008f4:	85 ff                	test   %edi,%edi
  8008f6:	0f 8e 5e 01 00 00    	jle    800a5a <vprintfmt+0x63e>
  8008fc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008ff:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800902:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800905:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800908:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80090b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80090e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800912:	89 1c 24             	mov    %ebx,(%esp)
  800915:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800918:	83 ef 01             	sub    $0x1,%edi
  80091b:	85 ff                	test   %edi,%edi
  80091d:	7f ef                	jg     80090e <vprintfmt+0x4f2>
  80091f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800922:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800925:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800928:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80092b:	e9 2a 01 00 00       	jmp    800a5a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800930:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800933:	83 eb 01             	sub    $0x1,%ebx
  800936:	85 db                	test   %ebx,%ebx
  800938:	0f 8e 0a fb ff ff    	jle    800448 <vprintfmt+0x2c>
  80093e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800941:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800944:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800947:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800952:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800954:	83 eb 01             	sub    $0x1,%ebx
  800957:	85 db                	test   %ebx,%ebx
  800959:	7f ec                	jg     800947 <vprintfmt+0x52b>
  80095b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80095e:	e9 e8 fa ff ff       	jmp    80044b <vprintfmt+0x2f>
  800963:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8d 50 04             	lea    0x4(%eax),%edx
  80096c:	89 55 14             	mov    %edx,0x14(%ebp)
  80096f:	8b 00                	mov    (%eax),%eax
  800971:	85 c0                	test   %eax,%eax
  800973:	75 2a                	jne    80099f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800975:	c7 44 24 0c 84 1c 80 	movl   $0x801c84,0xc(%esp)
  80097c:	00 
  80097d:	c7 44 24 08 e5 1b 80 	movl   $0x801be5,0x8(%esp)
  800984:	00 
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
  800988:	89 54 24 04          	mov    %edx,0x4(%esp)
  80098c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098f:	89 0c 24             	mov    %ecx,(%esp)
  800992:	e8 90 01 00 00       	call   800b27 <printfmt>
  800997:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80099a:	e9 ac fa ff ff       	jmp    80044b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80099f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a2:	8b 13                	mov    (%ebx),%edx
  8009a4:	83 fa 7f             	cmp    $0x7f,%edx
  8009a7:	7e 29                	jle    8009d2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8009a9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8009ab:	c7 44 24 0c bc 1c 80 	movl   $0x801cbc,0xc(%esp)
  8009b2:	00 
  8009b3:	c7 44 24 08 e5 1b 80 	movl   $0x801be5,0x8(%esp)
  8009ba:	00 
  8009bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	89 04 24             	mov    %eax,(%esp)
  8009c5:	e8 5d 01 00 00       	call   800b27 <printfmt>
  8009ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009cd:	e9 79 fa ff ff       	jmp    80044b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8009d2:	88 10                	mov    %dl,(%eax)
  8009d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009d7:	e9 6f fa ff ff       	jmp    80044b <vprintfmt+0x2f>
  8009dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e9:	89 14 24             	mov    %edx,(%esp)
  8009ec:	ff 55 08             	call   *0x8(%ebp)
  8009ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8009f2:	e9 54 fa ff ff       	jmp    80044b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a05:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a08:	8d 47 ff             	lea    -0x1(%edi),%eax
  800a0b:	80 38 25             	cmpb   $0x25,(%eax)
  800a0e:	0f 84 37 fa ff ff    	je     80044b <vprintfmt+0x2f>
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	eb f0                	jmp    800a08 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a23:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a26:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a2a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a31:	00 
  800a32:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a35:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a38:	89 04 24             	mov    %eax,(%esp)
  800a3b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a3f:	e8 bc 0f 00 00       	call   801a00 <__umoddi3>
  800a44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a48:	0f be 80 cb 1b 80 00 	movsbl 0x801bcb(%eax),%eax
  800a4f:	89 04 24             	mov    %eax,(%esp)
  800a52:	ff 55 08             	call   *0x8(%ebp)
  800a55:	e9 d6 fe ff ff       	jmp    800930 <vprintfmt+0x514>
  800a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a61:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a65:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a6c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a73:	00 
  800a74:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a77:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a7a:	89 04 24             	mov    %eax,(%esp)
  800a7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a81:	e8 7a 0f 00 00       	call   801a00 <__umoddi3>
  800a86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a8a:	0f be 80 cb 1b 80 00 	movsbl 0x801bcb(%eax),%eax
  800a91:	89 04 24             	mov    %eax,(%esp)
  800a94:	ff 55 08             	call   *0x8(%ebp)
  800a97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a9a:	e9 ac f9 ff ff       	jmp    80044b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a9f:	83 c4 6c             	add    $0x6c,%esp
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	83 ec 28             	sub    $0x28,%esp
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	74 04                	je     800abb <vsnprintf+0x14>
  800ab7:	85 d2                	test   %edx,%edx
  800ab9:	7f 07                	jg     800ac2 <vsnprintf+0x1b>
  800abb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac0:	eb 3b                	jmp    800afd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ac2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ac5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800acc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ad3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ada:	8b 45 10             	mov    0x10(%ebp),%eax
  800add:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae8:	c7 04 24 ff 03 80 00 	movl   $0x8003ff,(%esp)
  800aef:	e8 28 f9 ff ff       	call   80041c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b05:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1d:	89 04 24             	mov    %eax,(%esp)
  800b20:	e8 82 ff ff ff       	call   800aa7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b25:	c9                   	leave  
  800b26:	c3                   	ret    

00800b27 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b2d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b34:	8b 45 10             	mov    0x10(%ebp),%eax
  800b37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
  800b45:	89 04 24             	mov    %eax,(%esp)
  800b48:	e8 cf f8 ff ff       	call   80041c <vprintfmt>
	va_end(ap);
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    
	...

00800b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b5e:	74 09                	je     800b69 <strlen+0x19>
		n++;
  800b60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b67:	75 f7                	jne    800b60 <strlen+0x10>
		n++;
	return n;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	53                   	push   %ebx
  800b6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b75:	85 c9                	test   %ecx,%ecx
  800b77:	74 19                	je     800b92 <strnlen+0x27>
  800b79:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b7c:	74 14                	je     800b92 <strnlen+0x27>
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b83:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b86:	39 c8                	cmp    %ecx,%eax
  800b88:	74 0d                	je     800b97 <strnlen+0x2c>
  800b8a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b8e:	75 f3                	jne    800b83 <strnlen+0x18>
  800b90:	eb 05                	jmp    800b97 <strnlen+0x2c>
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b97:	5b                   	pop    %ebx
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	53                   	push   %ebx
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ba9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bb0:	83 c2 01             	add    $0x1,%edx
  800bb3:	84 c9                	test   %cl,%cl
  800bb5:	75 f2                	jne    800ba9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 08             	sub    $0x8,%esp
  800bc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bc4:	89 1c 24             	mov    %ebx,(%esp)
  800bc7:	e8 84 ff ff ff       	call   800b50 <strlen>
	strcpy(dst + len, src);
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bd3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bd6:	89 04 24             	mov    %eax,(%esp)
  800bd9:	e8 bc ff ff ff       	call   800b9a <strcpy>
	return dst;
}
  800bde:	89 d8                	mov    %ebx,%eax
  800be0:	83 c4 08             	add    $0x8,%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf4:	85 f6                	test   %esi,%esi
  800bf6:	74 18                	je     800c10 <strncpy+0x2a>
  800bf8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bfd:	0f b6 1a             	movzbl (%edx),%ebx
  800c00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c03:	80 3a 01             	cmpb   $0x1,(%edx)
  800c06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c09:	83 c1 01             	add    $0x1,%ecx
  800c0c:	39 ce                	cmp    %ecx,%esi
  800c0e:	77 ed                	ja     800bfd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 75 08             	mov    0x8(%ebp),%esi
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c22:	89 f0                	mov    %esi,%eax
  800c24:	85 c9                	test   %ecx,%ecx
  800c26:	74 27                	je     800c4f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c28:	83 e9 01             	sub    $0x1,%ecx
  800c2b:	74 1d                	je     800c4a <strlcpy+0x36>
  800c2d:	0f b6 1a             	movzbl (%edx),%ebx
  800c30:	84 db                	test   %bl,%bl
  800c32:	74 16                	je     800c4a <strlcpy+0x36>
			*dst++ = *src++;
  800c34:	88 18                	mov    %bl,(%eax)
  800c36:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c39:	83 e9 01             	sub    $0x1,%ecx
  800c3c:	74 0e                	je     800c4c <strlcpy+0x38>
			*dst++ = *src++;
  800c3e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c41:	0f b6 1a             	movzbl (%edx),%ebx
  800c44:	84 db                	test   %bl,%bl
  800c46:	75 ec                	jne    800c34 <strlcpy+0x20>
  800c48:	eb 02                	jmp    800c4c <strlcpy+0x38>
  800c4a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c4c:	c6 00 00             	movb   $0x0,(%eax)
  800c4f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c5e:	0f b6 01             	movzbl (%ecx),%eax
  800c61:	84 c0                	test   %al,%al
  800c63:	74 15                	je     800c7a <strcmp+0x25>
  800c65:	3a 02                	cmp    (%edx),%al
  800c67:	75 11                	jne    800c7a <strcmp+0x25>
		p++, q++;
  800c69:	83 c1 01             	add    $0x1,%ecx
  800c6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c6f:	0f b6 01             	movzbl (%ecx),%eax
  800c72:	84 c0                	test   %al,%al
  800c74:	74 04                	je     800c7a <strcmp+0x25>
  800c76:	3a 02                	cmp    (%edx),%al
  800c78:	74 ef                	je     800c69 <strcmp+0x14>
  800c7a:	0f b6 c0             	movzbl %al,%eax
  800c7d:	0f b6 12             	movzbl (%edx),%edx
  800c80:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	53                   	push   %ebx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	74 23                	je     800cb8 <strncmp+0x34>
  800c95:	0f b6 1a             	movzbl (%edx),%ebx
  800c98:	84 db                	test   %bl,%bl
  800c9a:	74 25                	je     800cc1 <strncmp+0x3d>
  800c9c:	3a 19                	cmp    (%ecx),%bl
  800c9e:	75 21                	jne    800cc1 <strncmp+0x3d>
  800ca0:	83 e8 01             	sub    $0x1,%eax
  800ca3:	74 13                	je     800cb8 <strncmp+0x34>
		n--, p++, q++;
  800ca5:	83 c2 01             	add    $0x1,%edx
  800ca8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cab:	0f b6 1a             	movzbl (%edx),%ebx
  800cae:	84 db                	test   %bl,%bl
  800cb0:	74 0f                	je     800cc1 <strncmp+0x3d>
  800cb2:	3a 19                	cmp    (%ecx),%bl
  800cb4:	74 ea                	je     800ca0 <strncmp+0x1c>
  800cb6:	eb 09                	jmp    800cc1 <strncmp+0x3d>
  800cb8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5d                   	pop    %ebp
  800cbf:	90                   	nop
  800cc0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cc1:	0f b6 02             	movzbl (%edx),%eax
  800cc4:	0f b6 11             	movzbl (%ecx),%edx
  800cc7:	29 d0                	sub    %edx,%eax
  800cc9:	eb f2                	jmp    800cbd <strncmp+0x39>

00800ccb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd5:	0f b6 10             	movzbl (%eax),%edx
  800cd8:	84 d2                	test   %dl,%dl
  800cda:	74 18                	je     800cf4 <strchr+0x29>
		if (*s == c)
  800cdc:	38 ca                	cmp    %cl,%dl
  800cde:	75 0a                	jne    800cea <strchr+0x1f>
  800ce0:	eb 17                	jmp    800cf9 <strchr+0x2e>
  800ce2:	38 ca                	cmp    %cl,%dl
  800ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce8:	74 0f                	je     800cf9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cea:	83 c0 01             	add    $0x1,%eax
  800ced:	0f b6 10             	movzbl (%eax),%edx
  800cf0:	84 d2                	test   %dl,%dl
  800cf2:	75 ee                	jne    800ce2 <strchr+0x17>
  800cf4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d05:	0f b6 10             	movzbl (%eax),%edx
  800d08:	84 d2                	test   %dl,%dl
  800d0a:	74 18                	je     800d24 <strfind+0x29>
		if (*s == c)
  800d0c:	38 ca                	cmp    %cl,%dl
  800d0e:	75 0a                	jne    800d1a <strfind+0x1f>
  800d10:	eb 12                	jmp    800d24 <strfind+0x29>
  800d12:	38 ca                	cmp    %cl,%dl
  800d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d18:	74 0a                	je     800d24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d1a:	83 c0 01             	add    $0x1,%eax
  800d1d:	0f b6 10             	movzbl (%eax),%edx
  800d20:	84 d2                	test   %dl,%dl
  800d22:	75 ee                	jne    800d12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	89 1c 24             	mov    %ebx,(%esp)
  800d2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d40:	85 c9                	test   %ecx,%ecx
  800d42:	74 30                	je     800d74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d4a:	75 25                	jne    800d71 <memset+0x4b>
  800d4c:	f6 c1 03             	test   $0x3,%cl
  800d4f:	75 20                	jne    800d71 <memset+0x4b>
		c &= 0xFF;
  800d51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d54:	89 d3                	mov    %edx,%ebx
  800d56:	c1 e3 08             	shl    $0x8,%ebx
  800d59:	89 d6                	mov    %edx,%esi
  800d5b:	c1 e6 18             	shl    $0x18,%esi
  800d5e:	89 d0                	mov    %edx,%eax
  800d60:	c1 e0 10             	shl    $0x10,%eax
  800d63:	09 f0                	or     %esi,%eax
  800d65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d67:	09 d8                	or     %ebx,%eax
  800d69:	c1 e9 02             	shr    $0x2,%ecx
  800d6c:	fc                   	cld    
  800d6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d6f:	eb 03                	jmp    800d74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d71:	fc                   	cld    
  800d72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d74:	89 f8                	mov    %edi,%eax
  800d76:	8b 1c 24             	mov    (%esp),%ebx
  800d79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d81:	89 ec                	mov    %ebp,%esp
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	83 ec 08             	sub    $0x8,%esp
  800d8b:	89 34 24             	mov    %esi,(%esp)
  800d8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d9d:	39 c6                	cmp    %eax,%esi
  800d9f:	73 35                	jae    800dd6 <memmove+0x51>
  800da1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800da4:	39 d0                	cmp    %edx,%eax
  800da6:	73 2e                	jae    800dd6 <memmove+0x51>
		s += n;
		d += n;
  800da8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800daa:	f6 c2 03             	test   $0x3,%dl
  800dad:	75 1b                	jne    800dca <memmove+0x45>
  800daf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800db5:	75 13                	jne    800dca <memmove+0x45>
  800db7:	f6 c1 03             	test   $0x3,%cl
  800dba:	75 0e                	jne    800dca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800dbc:	83 ef 04             	sub    $0x4,%edi
  800dbf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dc2:	c1 e9 02             	shr    $0x2,%ecx
  800dc5:	fd                   	std    
  800dc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc8:	eb 09                	jmp    800dd3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dca:	83 ef 01             	sub    $0x1,%edi
  800dcd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800dd0:	fd                   	std    
  800dd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dd3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dd4:	eb 20                	jmp    800df6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ddc:	75 15                	jne    800df3 <memmove+0x6e>
  800dde:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800de4:	75 0d                	jne    800df3 <memmove+0x6e>
  800de6:	f6 c1 03             	test   $0x3,%cl
  800de9:	75 08                	jne    800df3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800deb:	c1 e9 02             	shr    $0x2,%ecx
  800dee:	fc                   	cld    
  800def:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df1:	eb 03                	jmp    800df6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800df3:	fc                   	cld    
  800df4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800df6:	8b 34 24             	mov    (%esp),%esi
  800df9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dfd:	89 ec                	mov    %ebp,%esp
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e07:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	89 04 24             	mov    %eax,(%esp)
  800e1b:	e8 65 ff ff ff       	call   800d85 <memmove>
}
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    

00800e22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e31:	85 c9                	test   %ecx,%ecx
  800e33:	74 36                	je     800e6b <memcmp+0x49>
		if (*s1 != *s2)
  800e35:	0f b6 06             	movzbl (%esi),%eax
  800e38:	0f b6 1f             	movzbl (%edi),%ebx
  800e3b:	38 d8                	cmp    %bl,%al
  800e3d:	74 20                	je     800e5f <memcmp+0x3d>
  800e3f:	eb 14                	jmp    800e55 <memcmp+0x33>
  800e41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e4b:	83 c2 01             	add    $0x1,%edx
  800e4e:	83 e9 01             	sub    $0x1,%ecx
  800e51:	38 d8                	cmp    %bl,%al
  800e53:	74 12                	je     800e67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e55:	0f b6 c0             	movzbl %al,%eax
  800e58:	0f b6 db             	movzbl %bl,%ebx
  800e5b:	29 d8                	sub    %ebx,%eax
  800e5d:	eb 11                	jmp    800e70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e5f:	83 e9 01             	sub    $0x1,%ecx
  800e62:	ba 00 00 00 00       	mov    $0x0,%edx
  800e67:	85 c9                	test   %ecx,%ecx
  800e69:	75 d6                	jne    800e41 <memcmp+0x1f>
  800e6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e80:	39 d0                	cmp    %edx,%eax
  800e82:	73 15                	jae    800e99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e88:	38 08                	cmp    %cl,(%eax)
  800e8a:	75 06                	jne    800e92 <memfind+0x1d>
  800e8c:	eb 0b                	jmp    800e99 <memfind+0x24>
  800e8e:	38 08                	cmp    %cl,(%eax)
  800e90:	74 07                	je     800e99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e92:	83 c0 01             	add    $0x1,%eax
  800e95:	39 c2                	cmp    %eax,%edx
  800e97:	77 f5                	ja     800e8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eaa:	0f b6 02             	movzbl (%edx),%eax
  800ead:	3c 20                	cmp    $0x20,%al
  800eaf:	74 04                	je     800eb5 <strtol+0x1a>
  800eb1:	3c 09                	cmp    $0x9,%al
  800eb3:	75 0e                	jne    800ec3 <strtol+0x28>
		s++;
  800eb5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eb8:	0f b6 02             	movzbl (%edx),%eax
  800ebb:	3c 20                	cmp    $0x20,%al
  800ebd:	74 f6                	je     800eb5 <strtol+0x1a>
  800ebf:	3c 09                	cmp    $0x9,%al
  800ec1:	74 f2                	je     800eb5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ec3:	3c 2b                	cmp    $0x2b,%al
  800ec5:	75 0c                	jne    800ed3 <strtol+0x38>
		s++;
  800ec7:	83 c2 01             	add    $0x1,%edx
  800eca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ed1:	eb 15                	jmp    800ee8 <strtol+0x4d>
	else if (*s == '-')
  800ed3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eda:	3c 2d                	cmp    $0x2d,%al
  800edc:	75 0a                	jne    800ee8 <strtol+0x4d>
		s++, neg = 1;
  800ede:	83 c2 01             	add    $0x1,%edx
  800ee1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ee8:	85 db                	test   %ebx,%ebx
  800eea:	0f 94 c0             	sete   %al
  800eed:	74 05                	je     800ef4 <strtol+0x59>
  800eef:	83 fb 10             	cmp    $0x10,%ebx
  800ef2:	75 18                	jne    800f0c <strtol+0x71>
  800ef4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ef7:	75 13                	jne    800f0c <strtol+0x71>
  800ef9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800efd:	8d 76 00             	lea    0x0(%esi),%esi
  800f00:	75 0a                	jne    800f0c <strtol+0x71>
		s += 2, base = 16;
  800f02:	83 c2 02             	add    $0x2,%edx
  800f05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0a:	eb 15                	jmp    800f21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f0c:	84 c0                	test   %al,%al
  800f0e:	66 90                	xchg   %ax,%ax
  800f10:	74 0f                	je     800f21 <strtol+0x86>
  800f12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f17:	80 3a 30             	cmpb   $0x30,(%edx)
  800f1a:	75 05                	jne    800f21 <strtol+0x86>
		s++, base = 8;
  800f1c:	83 c2 01             	add    $0x1,%edx
  800f1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
  800f26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f28:	0f b6 0a             	movzbl (%edx),%ecx
  800f2b:	89 cf                	mov    %ecx,%edi
  800f2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f30:	80 fb 09             	cmp    $0x9,%bl
  800f33:	77 08                	ja     800f3d <strtol+0xa2>
			dig = *s - '0';
  800f35:	0f be c9             	movsbl %cl,%ecx
  800f38:	83 e9 30             	sub    $0x30,%ecx
  800f3b:	eb 1e                	jmp    800f5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f40:	80 fb 19             	cmp    $0x19,%bl
  800f43:	77 08                	ja     800f4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f45:	0f be c9             	movsbl %cl,%ecx
  800f48:	83 e9 57             	sub    $0x57,%ecx
  800f4b:	eb 0e                	jmp    800f5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f50:	80 fb 19             	cmp    $0x19,%bl
  800f53:	77 15                	ja     800f6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f55:	0f be c9             	movsbl %cl,%ecx
  800f58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f5b:	39 f1                	cmp    %esi,%ecx
  800f5d:	7d 0b                	jge    800f6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f5f:	83 c2 01             	add    $0x1,%edx
  800f62:	0f af c6             	imul   %esi,%eax
  800f65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f68:	eb be                	jmp    800f28 <strtol+0x8d>
  800f6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f70:	74 05                	je     800f77 <strtol+0xdc>
		*endptr = (char *) s;
  800f72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f7b:	74 04                	je     800f81 <strtol+0xe6>
  800f7d:	89 c8                	mov    %ecx,%eax
  800f7f:	f7 d8                	neg    %eax
}
  800f81:	83 c4 04             	add    $0x4,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    
  800f89:	00 00                	add    %al,(%eax)
	...

00800f8c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	89 1c 24             	mov    %ebx,(%esp)
  800f95:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f99:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa3:	89 d1                	mov    %edx,%ecx
  800fa5:	89 d3                	mov    %edx,%ebx
  800fa7:	89 d7                	mov    %edx,%edi
  800fa9:	51                   	push   %ecx
  800faa:	52                   	push   %edx
  800fab:	53                   	push   %ebx
  800fac:	54                   	push   %esp
  800fad:	55                   	push   %ebp
  800fae:	56                   	push   %esi
  800faf:	57                   	push   %edi
  800fb0:	54                   	push   %esp
  800fb1:	5d                   	pop    %ebp
  800fb2:	8d 35 ba 0f 80 00    	lea    0x800fba,%esi
  800fb8:	0f 34                	sysenter 
  800fba:	5f                   	pop    %edi
  800fbb:	5e                   	pop    %esi
  800fbc:	5d                   	pop    %ebp
  800fbd:	5c                   	pop    %esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5a                   	pop    %edx
  800fc0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fc1:	8b 1c 24             	mov    (%esp),%ebx
  800fc4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fc8:	89 ec                	mov    %ebp,%esp
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 08             	sub    $0x8,%esp
  800fd2:	89 1c 24             	mov    %ebx,(%esp)
  800fd5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	89 c3                	mov    %eax,%ebx
  800fe6:	89 c7                	mov    %eax,%edi
  800fe8:	51                   	push   %ecx
  800fe9:	52                   	push   %edx
  800fea:	53                   	push   %ebx
  800feb:	54                   	push   %esp
  800fec:	55                   	push   %ebp
  800fed:	56                   	push   %esi
  800fee:	57                   	push   %edi
  800fef:	54                   	push   %esp
  800ff0:	5d                   	pop    %ebp
  800ff1:	8d 35 f9 0f 80 00    	lea    0x800ff9,%esi
  800ff7:	0f 34                	sysenter 
  800ff9:	5f                   	pop    %edi
  800ffa:	5e                   	pop    %esi
  800ffb:	5d                   	pop    %ebp
  800ffc:	5c                   	pop    %esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5a                   	pop    %edx
  800fff:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801000:	8b 1c 24             	mov    (%esp),%ebx
  801003:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801007:	89 ec                	mov    %ebp,%esp
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	83 ec 28             	sub    $0x28,%esp
  801011:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801014:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801017:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	89 df                	mov    %ebx,%edi
  801029:	51                   	push   %ecx
  80102a:	52                   	push   %edx
  80102b:	53                   	push   %ebx
  80102c:	54                   	push   %esp
  80102d:	55                   	push   %ebp
  80102e:	56                   	push   %esi
  80102f:	57                   	push   %edi
  801030:	54                   	push   %esp
  801031:	5d                   	pop    %ebp
  801032:	8d 35 3a 10 80 00    	lea    0x80103a,%esi
  801038:	0f 34                	sysenter 
  80103a:	5f                   	pop    %edi
  80103b:	5e                   	pop    %esi
  80103c:	5d                   	pop    %ebp
  80103d:	5c                   	pop    %esp
  80103e:	5b                   	pop    %ebx
  80103f:	5a                   	pop    %edx
  801040:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801041:	85 c0                	test   %eax,%eax
  801043:	7e 28                	jle    80106d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801045:	89 44 24 10          	mov    %eax,0x10(%esp)
  801049:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801050:	00 
  801051:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  801058:	00 
  801059:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801060:	00 
  801061:	c7 04 24 a1 1e 80 00 	movl   $0x801ea1,(%esp)
  801068:	e8 2f f1 ff ff       	call   80019c <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80106d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801070:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801073:	89 ec                	mov    %ebp,%esp
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	89 1c 24             	mov    %ebx,(%esp)
  801080:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801084:	b9 00 00 00 00       	mov    $0x0,%ecx
  801089:	b8 0f 00 00 00       	mov    $0xf,%eax
  80108e:	8b 55 08             	mov    0x8(%ebp),%edx
  801091:	89 cb                	mov    %ecx,%ebx
  801093:	89 cf                	mov    %ecx,%edi
  801095:	51                   	push   %ecx
  801096:	52                   	push   %edx
  801097:	53                   	push   %ebx
  801098:	54                   	push   %esp
  801099:	55                   	push   %ebp
  80109a:	56                   	push   %esi
  80109b:	57                   	push   %edi
  80109c:	54                   	push   %esp
  80109d:	5d                   	pop    %ebp
  80109e:	8d 35 a6 10 80 00    	lea    0x8010a6,%esi
  8010a4:	0f 34                	sysenter 
  8010a6:	5f                   	pop    %edi
  8010a7:	5e                   	pop    %esi
  8010a8:	5d                   	pop    %ebp
  8010a9:	5c                   	pop    %esp
  8010aa:	5b                   	pop    %ebx
  8010ab:	5a                   	pop    %edx
  8010ac:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010ad:	8b 1c 24             	mov    (%esp),%ebx
  8010b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b4:	89 ec                	mov    %ebp,%esp
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	83 ec 28             	sub    $0x28,%esp
  8010be:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010c1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d1:	89 cb                	mov    %ecx,%ebx
  8010d3:	89 cf                	mov    %ecx,%edi
  8010d5:	51                   	push   %ecx
  8010d6:	52                   	push   %edx
  8010d7:	53                   	push   %ebx
  8010d8:	54                   	push   %esp
  8010d9:	55                   	push   %ebp
  8010da:	56                   	push   %esi
  8010db:	57                   	push   %edi
  8010dc:	54                   	push   %esp
  8010dd:	5d                   	pop    %ebp
  8010de:	8d 35 e6 10 80 00    	lea    0x8010e6,%esi
  8010e4:	0f 34                	sysenter 
  8010e6:	5f                   	pop    %edi
  8010e7:	5e                   	pop    %esi
  8010e8:	5d                   	pop    %ebp
  8010e9:	5c                   	pop    %esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5a                   	pop    %edx
  8010ec:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	7e 28                	jle    801119 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010fc:	00 
  8010fd:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  801104:	00 
  801105:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80110c:	00 
  80110d:	c7 04 24 a1 1e 80 00 	movl   $0x801ea1,(%esp)
  801114:	e8 83 f0 ff ff       	call   80019c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801119:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80111c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80111f:	89 ec                	mov    %ebp,%esp
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	89 1c 24             	mov    %ebx,(%esp)
  80112c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801130:	b8 0c 00 00 00       	mov    $0xc,%eax
  801135:	8b 7d 14             	mov    0x14(%ebp),%edi
  801138:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80113b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113e:	8b 55 08             	mov    0x8(%ebp),%edx
  801141:	51                   	push   %ecx
  801142:	52                   	push   %edx
  801143:	53                   	push   %ebx
  801144:	54                   	push   %esp
  801145:	55                   	push   %ebp
  801146:	56                   	push   %esi
  801147:	57                   	push   %edi
  801148:	54                   	push   %esp
  801149:	5d                   	pop    %ebp
  80114a:	8d 35 52 11 80 00    	lea    0x801152,%esi
  801150:	0f 34                	sysenter 
  801152:	5f                   	pop    %edi
  801153:	5e                   	pop    %esi
  801154:	5d                   	pop    %ebp
  801155:	5c                   	pop    %esp
  801156:	5b                   	pop    %ebx
  801157:	5a                   	pop    %edx
  801158:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801159:	8b 1c 24             	mov    (%esp),%ebx
  80115c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801160:	89 ec                	mov    %ebp,%esp
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 28             	sub    $0x28,%esp
  80116a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80116d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801170:	bb 00 00 00 00       	mov    $0x0,%ebx
  801175:	b8 0a 00 00 00       	mov    $0xa,%eax
  80117a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
  801180:	89 df                	mov    %ebx,%edi
  801182:	51                   	push   %ecx
  801183:	52                   	push   %edx
  801184:	53                   	push   %ebx
  801185:	54                   	push   %esp
  801186:	55                   	push   %ebp
  801187:	56                   	push   %esi
  801188:	57                   	push   %edi
  801189:	54                   	push   %esp
  80118a:	5d                   	pop    %ebp
  80118b:	8d 35 93 11 80 00    	lea    0x801193,%esi
  801191:	0f 34                	sysenter 
  801193:	5f                   	pop    %edi
  801194:	5e                   	pop    %esi
  801195:	5d                   	pop    %ebp
  801196:	5c                   	pop    %esp
  801197:	5b                   	pop    %ebx
  801198:	5a                   	pop    %edx
  801199:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80119a:	85 c0                	test   %eax,%eax
  80119c:	7e 28                	jle    8011c6 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a2:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  8011b1:	00 
  8011b2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011b9:	00 
  8011ba:	c7 04 24 a1 1e 80 00 	movl   $0x801ea1,(%esp)
  8011c1:	e8 d6 ef ff ff       	call   80019c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011c6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011cc:	89 ec                	mov    %ebp,%esp
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 28             	sub    $0x28,%esp
  8011d6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011d9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e1:	b8 09 00 00 00       	mov    $0x9,%eax
  8011e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ec:	89 df                	mov    %ebx,%edi
  8011ee:	51                   	push   %ecx
  8011ef:	52                   	push   %edx
  8011f0:	53                   	push   %ebx
  8011f1:	54                   	push   %esp
  8011f2:	55                   	push   %ebp
  8011f3:	56                   	push   %esi
  8011f4:	57                   	push   %edi
  8011f5:	54                   	push   %esp
  8011f6:	5d                   	pop    %ebp
  8011f7:	8d 35 ff 11 80 00    	lea    0x8011ff,%esi
  8011fd:	0f 34                	sysenter 
  8011ff:	5f                   	pop    %edi
  801200:	5e                   	pop    %esi
  801201:	5d                   	pop    %ebp
  801202:	5c                   	pop    %esp
  801203:	5b                   	pop    %ebx
  801204:	5a                   	pop    %edx
  801205:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801206:	85 c0                	test   %eax,%eax
  801208:	7e 28                	jle    801232 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801215:	00 
  801216:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801225:	00 
  801226:	c7 04 24 a1 1e 80 00 	movl   $0x801ea1,(%esp)
  80122d:	e8 6a ef ff ff       	call   80019c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801232:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801235:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801238:	89 ec                	mov    %ebp,%esp
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 28             	sub    $0x28,%esp
  801242:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801245:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801248:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124d:	b8 07 00 00 00       	mov    $0x7,%eax
  801252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801255:	8b 55 08             	mov    0x8(%ebp),%edx
  801258:	89 df                	mov    %ebx,%edi
  80125a:	51                   	push   %ecx
  80125b:	52                   	push   %edx
  80125c:	53                   	push   %ebx
  80125d:	54                   	push   %esp
  80125e:	55                   	push   %ebp
  80125f:	56                   	push   %esi
  801260:	57                   	push   %edi
  801261:	54                   	push   %esp
  801262:	5d                   	pop    %ebp
  801263:	8d 35 6b 12 80 00    	lea    0x80126b,%esi
  801269:	0f 34                	sysenter 
  80126b:	5f                   	pop    %edi
  80126c:	5e                   	pop    %esi
  80126d:	5d                   	pop    %ebp
  80126e:	5c                   	pop    %esp
  80126f:	5b                   	pop    %ebx
  801270:	5a                   	pop    %edx
  801271:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801272:	85 c0                	test   %eax,%eax
  801274:	7e 28                	jle    80129e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801276:	89 44 24 10          	mov    %eax,0x10(%esp)
  80127a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801281:	00 
  801282:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  801289:	00 
  80128a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801291:	00 
  801292:	c7 04 24 a1 1e 80 00 	movl   $0x801ea1,(%esp)
  801299:	e8 fe ee ff ff       	call   80019c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80129e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012a4:	89 ec                	mov    %ebp,%esp
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 28             	sub    $0x28,%esp
  8012ae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012b1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012b4:	8b 7d 18             	mov    0x18(%ebp),%edi
  8012b7:	0b 7d 14             	or     0x14(%ebp),%edi
  8012ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8012bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c8:	51                   	push   %ecx
  8012c9:	52                   	push   %edx
  8012ca:	53                   	push   %ebx
  8012cb:	54                   	push   %esp
  8012cc:	55                   	push   %ebp
  8012cd:	56                   	push   %esi
  8012ce:	57                   	push   %edi
  8012cf:	54                   	push   %esp
  8012d0:	5d                   	pop    %ebp
  8012d1:	8d 35 d9 12 80 00    	lea    0x8012d9,%esi
  8012d7:	0f 34                	sysenter 
  8012d9:	5f                   	pop    %edi
  8012da:	5e                   	pop    %esi
  8012db:	5d                   	pop    %ebp
  8012dc:	5c                   	pop    %esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5a                   	pop    %edx
  8012df:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	7e 28                	jle    80130c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012e8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012ef:	00 
  8012f0:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012ff:	00 
  801300:	c7 04 24 a1 1e 80 00 	movl   $0x801ea1,(%esp)
  801307:	e8 90 ee ff ff       	call   80019c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80130c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80130f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801312:	89 ec                	mov    %ebp,%esp
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	83 ec 28             	sub    $0x28,%esp
  80131c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80131f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801322:	bf 00 00 00 00       	mov    $0x0,%edi
  801327:	b8 05 00 00 00       	mov    $0x5,%eax
  80132c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80132f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801332:	8b 55 08             	mov    0x8(%ebp),%edx
  801335:	51                   	push   %ecx
  801336:	52                   	push   %edx
  801337:	53                   	push   %ebx
  801338:	54                   	push   %esp
  801339:	55                   	push   %ebp
  80133a:	56                   	push   %esi
  80133b:	57                   	push   %edi
  80133c:	54                   	push   %esp
  80133d:	5d                   	pop    %ebp
  80133e:	8d 35 46 13 80 00    	lea    0x801346,%esi
  801344:	0f 34                	sysenter 
  801346:	5f                   	pop    %edi
  801347:	5e                   	pop    %esi
  801348:	5d                   	pop    %ebp
  801349:	5c                   	pop    %esp
  80134a:	5b                   	pop    %ebx
  80134b:	5a                   	pop    %edx
  80134c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80134d:	85 c0                	test   %eax,%eax
  80134f:	7e 28                	jle    801379 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801351:	89 44 24 10          	mov    %eax,0x10(%esp)
  801355:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80135c:	00 
  80135d:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  801364:	00 
  801365:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80136c:	00 
  80136d:	c7 04 24 a1 1e 80 00 	movl   $0x801ea1,(%esp)
  801374:	e8 23 ee ff ff       	call   80019c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801379:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80137c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80137f:	89 ec                	mov    %ebp,%esp
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	89 1c 24             	mov    %ebx,(%esp)
  80138c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801390:	ba 00 00 00 00       	mov    $0x0,%edx
  801395:	b8 0b 00 00 00       	mov    $0xb,%eax
  80139a:	89 d1                	mov    %edx,%ecx
  80139c:	89 d3                	mov    %edx,%ebx
  80139e:	89 d7                	mov    %edx,%edi
  8013a0:	51                   	push   %ecx
  8013a1:	52                   	push   %edx
  8013a2:	53                   	push   %ebx
  8013a3:	54                   	push   %esp
  8013a4:	55                   	push   %ebp
  8013a5:	56                   	push   %esi
  8013a6:	57                   	push   %edi
  8013a7:	54                   	push   %esp
  8013a8:	5d                   	pop    %ebp
  8013a9:	8d 35 b1 13 80 00    	lea    0x8013b1,%esi
  8013af:	0f 34                	sysenter 
  8013b1:	5f                   	pop    %edi
  8013b2:	5e                   	pop    %esi
  8013b3:	5d                   	pop    %ebp
  8013b4:	5c                   	pop    %esp
  8013b5:	5b                   	pop    %ebx
  8013b6:	5a                   	pop    %edx
  8013b7:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8013b8:	8b 1c 24             	mov    (%esp),%ebx
  8013bb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013bf:	89 ec                	mov    %ebp,%esp
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    

008013c3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	89 1c 24             	mov    %ebx,(%esp)
  8013cc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d5:	b8 04 00 00 00       	mov    $0x4,%eax
  8013da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e0:	89 df                	mov    %ebx,%edi
  8013e2:	51                   	push   %ecx
  8013e3:	52                   	push   %edx
  8013e4:	53                   	push   %ebx
  8013e5:	54                   	push   %esp
  8013e6:	55                   	push   %ebp
  8013e7:	56                   	push   %esi
  8013e8:	57                   	push   %edi
  8013e9:	54                   	push   %esp
  8013ea:	5d                   	pop    %ebp
  8013eb:	8d 35 f3 13 80 00    	lea    0x8013f3,%esi
  8013f1:	0f 34                	sysenter 
  8013f3:	5f                   	pop    %edi
  8013f4:	5e                   	pop    %esi
  8013f5:	5d                   	pop    %ebp
  8013f6:	5c                   	pop    %esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5a                   	pop    %edx
  8013f9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8013fa:	8b 1c 24             	mov    (%esp),%ebx
  8013fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801401:	89 ec                	mov    %ebp,%esp
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	89 1c 24             	mov    %ebx,(%esp)
  80140e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801412:	ba 00 00 00 00       	mov    $0x0,%edx
  801417:	b8 02 00 00 00       	mov    $0x2,%eax
  80141c:	89 d1                	mov    %edx,%ecx
  80141e:	89 d3                	mov    %edx,%ebx
  801420:	89 d7                	mov    %edx,%edi
  801422:	51                   	push   %ecx
  801423:	52                   	push   %edx
  801424:	53                   	push   %ebx
  801425:	54                   	push   %esp
  801426:	55                   	push   %ebp
  801427:	56                   	push   %esi
  801428:	57                   	push   %edi
  801429:	54                   	push   %esp
  80142a:	5d                   	pop    %ebp
  80142b:	8d 35 33 14 80 00    	lea    0x801433,%esi
  801431:	0f 34                	sysenter 
  801433:	5f                   	pop    %edi
  801434:	5e                   	pop    %esi
  801435:	5d                   	pop    %ebp
  801436:	5c                   	pop    %esp
  801437:	5b                   	pop    %ebx
  801438:	5a                   	pop    %edx
  801439:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80143a:	8b 1c 24             	mov    (%esp),%ebx
  80143d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801441:	89 ec                	mov    %ebp,%esp
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    

00801445 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	83 ec 28             	sub    $0x28,%esp
  80144b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80144e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801451:	b9 00 00 00 00       	mov    $0x0,%ecx
  801456:	b8 03 00 00 00       	mov    $0x3,%eax
  80145b:	8b 55 08             	mov    0x8(%ebp),%edx
  80145e:	89 cb                	mov    %ecx,%ebx
  801460:	89 cf                	mov    %ecx,%edi
  801462:	51                   	push   %ecx
  801463:	52                   	push   %edx
  801464:	53                   	push   %ebx
  801465:	54                   	push   %esp
  801466:	55                   	push   %ebp
  801467:	56                   	push   %esi
  801468:	57                   	push   %edi
  801469:	54                   	push   %esp
  80146a:	5d                   	pop    %ebp
  80146b:	8d 35 73 14 80 00    	lea    0x801473,%esi
  801471:	0f 34                	sysenter 
  801473:	5f                   	pop    %edi
  801474:	5e                   	pop    %esi
  801475:	5d                   	pop    %ebp
  801476:	5c                   	pop    %esp
  801477:	5b                   	pop    %ebx
  801478:	5a                   	pop    %edx
  801479:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80147a:	85 c0                	test   %eax,%eax
  80147c:	7e 28                	jle    8014a6 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80147e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801482:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801489:	00 
  80148a:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  801491:	00 
  801492:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801499:	00 
  80149a:	c7 04 24 a1 1e 80 00 	movl   $0x801ea1,(%esp)
  8014a1:	e8 f6 ec ff ff       	call   80019c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014a6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014a9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014ac:	89 ec                	mov    %ebp,%esp
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014b6:	c7 44 24 08 af 1e 80 	movl   $0x801eaf,0x8(%esp)
  8014bd:	00 
  8014be:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  8014c5:	00 
  8014c6:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  8014cd:	e8 ca ec ff ff       	call   80019c <_panic>

008014d2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	57                   	push   %edi
  8014d6:	56                   	push   %esi
  8014d7:	53                   	push   %ebx
  8014d8:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  8014db:	c7 04 24 27 17 80 00 	movl   $0x801727,(%esp)
  8014e2:	e8 6d 03 00 00       	call   801854 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014e7:	ba 08 00 00 00       	mov    $0x8,%edx
  8014ec:	89 d0                	mov    %edx,%eax
  8014ee:	cd 30                	int    $0x30
  8014f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	79 20                	jns    801517 <fork+0x45>
		panic("sys_exofork: %e", envid);
  8014f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014fb:	c7 44 24 08 d0 1e 80 	movl   $0x801ed0,0x8(%esp)
  801502:	00 
  801503:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80150a:	00 
  80150b:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  801512:	e8 85 ec ff ff       	call   80019c <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801517:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80151c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801521:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801526:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80152a:	75 20                	jne    80154c <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80152c:	e8 d4 fe ff ff       	call   801405 <sys_getenvid>
  801531:	25 ff 03 00 00       	and    $0x3ff,%eax
  801536:	89 c2                	mov    %eax,%edx
  801538:	c1 e2 07             	shl    $0x7,%edx
  80153b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801542:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  801547:	e9 d0 01 00 00       	jmp    80171c <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80154c:	89 d8                	mov    %ebx,%eax
  80154e:	c1 e8 16             	shr    $0x16,%eax
  801551:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801554:	a8 01                	test   $0x1,%al
  801556:	0f 84 0d 01 00 00    	je     801669 <fork+0x197>
  80155c:	89 d8                	mov    %ebx,%eax
  80155e:	c1 e8 0c             	shr    $0xc,%eax
  801561:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801564:	f6 c2 01             	test   $0x1,%dl
  801567:	0f 84 fc 00 00 00    	je     801669 <fork+0x197>
  80156d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801570:	f6 c2 04             	test   $0x4,%dl
  801573:	0f 84 f0 00 00 00    	je     801669 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  801579:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	c1 ea 0c             	shr    $0xc,%edx
  801581:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801584:	f6 c2 01             	test   $0x1,%dl
  801587:	0f 84 dc 00 00 00    	je     801669 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  80158d:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801593:	0f 84 8d 00 00 00    	je     801626 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  801599:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80159c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8015a3:	00 
  8015a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ba:	e8 e9 fc ff ff       	call   8012a8 <sys_page_map>
               if(r<0)
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	79 1c                	jns    8015df <fork+0x10d>
                 panic("map failed");
  8015c3:	c7 44 24 08 e0 1e 80 	movl   $0x801ee0,0x8(%esp)
  8015ca:	00 
  8015cb:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8015d2:	00 
  8015d3:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  8015da:	e8 bd eb ff ff       	call   80019c <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  8015df:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8015e6:	00 
  8015e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f5:	00 
  8015f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801601:	e8 a2 fc ff ff       	call   8012a8 <sys_page_map>
               if(r<0)
  801606:	85 c0                	test   %eax,%eax
  801608:	79 5f                	jns    801669 <fork+0x197>
                 panic("map failed");
  80160a:	c7 44 24 08 e0 1e 80 	movl   $0x801ee0,0x8(%esp)
  801611:	00 
  801612:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801619:	00 
  80161a:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  801621:	e8 76 eb ff ff       	call   80019c <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801626:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80162d:	00 
  80162e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801632:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801635:	89 54 24 08          	mov    %edx,0x8(%esp)
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801644:	e8 5f fc ff ff       	call   8012a8 <sys_page_map>
               if(r<0)
  801649:	85 c0                	test   %eax,%eax
  80164b:	79 1c                	jns    801669 <fork+0x197>
                 panic("map failed");
  80164d:	c7 44 24 08 e0 1e 80 	movl   $0x801ee0,0x8(%esp)
  801654:	00 
  801655:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80165c:	00 
  80165d:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  801664:	e8 33 eb ff ff       	call   80019c <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801669:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80166f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801675:	0f 85 d1 fe ff ff    	jne    80154c <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80167b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801682:	00 
  801683:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80168a:	ee 
  80168b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80168e:	89 04 24             	mov    %eax,(%esp)
  801691:	e8 80 fc ff ff       	call   801316 <sys_page_alloc>
        if(r < 0)
  801696:	85 c0                	test   %eax,%eax
  801698:	79 1c                	jns    8016b6 <fork+0x1e4>
            panic("alloc failed");
  80169a:	c7 44 24 08 eb 1e 80 	movl   $0x801eeb,0x8(%esp)
  8016a1:	00 
  8016a2:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8016a9:	00 
  8016aa:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  8016b1:	e8 e6 ea ff ff       	call   80019c <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8016b6:	c7 44 24 04 a0 18 80 	movl   $0x8018a0,0x4(%esp)
  8016bd:	00 
  8016be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016c1:	89 14 24             	mov    %edx,(%esp)
  8016c4:	e8 9b fa ff ff       	call   801164 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	79 1c                	jns    8016e9 <fork+0x217>
            panic("set pgfault upcall failed");
  8016cd:	c7 44 24 08 f8 1e 80 	movl   $0x801ef8,0x8(%esp)
  8016d4:	00 
  8016d5:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8016dc:	00 
  8016dd:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  8016e4:	e8 b3 ea ff ff       	call   80019c <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  8016e9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016f0:	00 
  8016f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f4:	89 04 24             	mov    %eax,(%esp)
  8016f7:	e8 d4 fa ff ff       	call   8011d0 <sys_env_set_status>
        if(r < 0)
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	79 1c                	jns    80171c <fork+0x24a>
            panic("set status failed");
  801700:	c7 44 24 08 12 1f 80 	movl   $0x801f12,0x8(%esp)
  801707:	00 
  801708:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80170f:	00 
  801710:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  801717:	e8 80 ea ff ff       	call   80019c <_panic>
        return envid;
	//panic("fork not implemented");
}
  80171c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171f:	83 c4 3c             	add    $0x3c,%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5f                   	pop    %edi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	53                   	push   %ebx
  80172b:	83 ec 24             	sub    $0x24,%esp
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801731:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801733:	89 da                	mov    %ebx,%edx
  801735:	c1 ea 0c             	shr    $0xc,%edx
  801738:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80173f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801743:	74 08                	je     80174d <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801745:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80174b:	75 1c                	jne    801769 <pgfault+0x42>
           panic("pgfault error");
  80174d:	c7 44 24 08 24 1f 80 	movl   $0x801f24,0x8(%esp)
  801754:	00 
  801755:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80175c:	00 
  80175d:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  801764:	e8 33 ea ff ff       	call   80019c <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801769:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801770:	00 
  801771:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801778:	00 
  801779:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801780:	e8 91 fb ff ff       	call   801316 <sys_page_alloc>
  801785:	85 c0                	test   %eax,%eax
  801787:	79 20                	jns    8017a9 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  801789:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80178d:	c7 44 24 08 32 1f 80 	movl   $0x801f32,0x8(%esp)
  801794:	00 
  801795:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80179c:	00 
  80179d:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  8017a4:	e8 f3 e9 ff ff       	call   80019c <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  8017a9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8017af:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8017b6:	00 
  8017b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017bb:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8017c2:	e8 be f5 ff ff       	call   800d85 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  8017c7:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8017ce:	00 
  8017cf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017da:	00 
  8017db:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8017e2:	00 
  8017e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ea:	e8 b9 fa ff ff       	call   8012a8 <sys_page_map>
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	79 20                	jns    801813 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  8017f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f7:	c7 44 24 08 45 1f 80 	movl   $0x801f45,0x8(%esp)
  8017fe:	00 
  8017ff:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801806:	00 
  801807:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  80180e:	e8 89 e9 ff ff       	call   80019c <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801813:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80181a:	00 
  80181b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801822:	e8 15 fa ff ff       	call   80123c <sys_page_unmap>
  801827:	85 c0                	test   %eax,%eax
  801829:	79 20                	jns    80184b <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80182b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80182f:	c7 44 24 08 56 1f 80 	movl   $0x801f56,0x8(%esp)
  801836:	00 
  801837:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80183e:	00 
  80183f:	c7 04 24 c5 1e 80 00 	movl   $0x801ec5,(%esp)
  801846:	e8 51 e9 ff ff       	call   80019c <_panic>
	//panic("pgfault not implemented");
}
  80184b:	83 c4 24             	add    $0x24,%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    
  801851:	00 00                	add    %al,(%eax)
	...

00801854 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80185a:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801861:	75 30                	jne    801893 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801863:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80186a:	00 
  80186b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801872:	ee 
  801873:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187a:	e8 97 fa ff ff       	call   801316 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80187f:	c7 44 24 04 a0 18 80 	movl   $0x8018a0,0x4(%esp)
  801886:	00 
  801887:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80188e:	e8 d1 f8 ff ff       	call   801164 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
  801896:	a3 10 20 80 00       	mov    %eax,0x802010
}
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    
  80189d:	00 00                	add    %al,(%eax)
	...

008018a0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8018a0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8018a1:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8018a6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8018a8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8018ab:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8018af:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8018b3:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8018b6:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8018b8:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8018bc:	83 c4 08             	add    $0x8,%esp
        popal
  8018bf:	61                   	popa   
        addl $0x4,%esp
  8018c0:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8018c3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8018c4:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8018c5:	c3                   	ret    
	...

008018d0 <__udivdi3>:
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	57                   	push   %edi
  8018d4:	56                   	push   %esi
  8018d5:	83 ec 10             	sub    $0x10,%esp
  8018d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018db:	8b 55 08             	mov    0x8(%ebp),%edx
  8018de:	8b 75 10             	mov    0x10(%ebp),%esi
  8018e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8018e9:	75 35                	jne    801920 <__udivdi3+0x50>
  8018eb:	39 fe                	cmp    %edi,%esi
  8018ed:	77 61                	ja     801950 <__udivdi3+0x80>
  8018ef:	85 f6                	test   %esi,%esi
  8018f1:	75 0b                	jne    8018fe <__udivdi3+0x2e>
  8018f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f8:	31 d2                	xor    %edx,%edx
  8018fa:	f7 f6                	div    %esi
  8018fc:	89 c6                	mov    %eax,%esi
  8018fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801901:	31 d2                	xor    %edx,%edx
  801903:	89 f8                	mov    %edi,%eax
  801905:	f7 f6                	div    %esi
  801907:	89 c7                	mov    %eax,%edi
  801909:	89 c8                	mov    %ecx,%eax
  80190b:	f7 f6                	div    %esi
  80190d:	89 c1                	mov    %eax,%ecx
  80190f:	89 fa                	mov    %edi,%edx
  801911:	89 c8                	mov    %ecx,%eax
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	5e                   	pop    %esi
  801917:	5f                   	pop    %edi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    
  80191a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801920:	39 f8                	cmp    %edi,%eax
  801922:	77 1c                	ja     801940 <__udivdi3+0x70>
  801924:	0f bd d0             	bsr    %eax,%edx
  801927:	83 f2 1f             	xor    $0x1f,%edx
  80192a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80192d:	75 39                	jne    801968 <__udivdi3+0x98>
  80192f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801932:	0f 86 a0 00 00 00    	jbe    8019d8 <__udivdi3+0x108>
  801938:	39 f8                	cmp    %edi,%eax
  80193a:	0f 82 98 00 00 00    	jb     8019d8 <__udivdi3+0x108>
  801940:	31 ff                	xor    %edi,%edi
  801942:	31 c9                	xor    %ecx,%ecx
  801944:	89 c8                	mov    %ecx,%eax
  801946:	89 fa                	mov    %edi,%edx
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	5e                   	pop    %esi
  80194c:	5f                   	pop    %edi
  80194d:	5d                   	pop    %ebp
  80194e:	c3                   	ret    
  80194f:	90                   	nop
  801950:	89 d1                	mov    %edx,%ecx
  801952:	89 fa                	mov    %edi,%edx
  801954:	89 c8                	mov    %ecx,%eax
  801956:	31 ff                	xor    %edi,%edi
  801958:	f7 f6                	div    %esi
  80195a:	89 c1                	mov    %eax,%ecx
  80195c:	89 fa                	mov    %edi,%edx
  80195e:	89 c8                	mov    %ecx,%eax
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	5e                   	pop    %esi
  801964:	5f                   	pop    %edi
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    
  801967:	90                   	nop
  801968:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80196c:	89 f2                	mov    %esi,%edx
  80196e:	d3 e0                	shl    %cl,%eax
  801970:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801973:	b8 20 00 00 00       	mov    $0x20,%eax
  801978:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80197b:	89 c1                	mov    %eax,%ecx
  80197d:	d3 ea                	shr    %cl,%edx
  80197f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801983:	0b 55 ec             	or     -0x14(%ebp),%edx
  801986:	d3 e6                	shl    %cl,%esi
  801988:	89 c1                	mov    %eax,%ecx
  80198a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80198d:	89 fe                	mov    %edi,%esi
  80198f:	d3 ee                	shr    %cl,%esi
  801991:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801995:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801998:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80199b:	d3 e7                	shl    %cl,%edi
  80199d:	89 c1                	mov    %eax,%ecx
  80199f:	d3 ea                	shr    %cl,%edx
  8019a1:	09 d7                	or     %edx,%edi
  8019a3:	89 f2                	mov    %esi,%edx
  8019a5:	89 f8                	mov    %edi,%eax
  8019a7:	f7 75 ec             	divl   -0x14(%ebp)
  8019aa:	89 d6                	mov    %edx,%esi
  8019ac:	89 c7                	mov    %eax,%edi
  8019ae:	f7 65 e8             	mull   -0x18(%ebp)
  8019b1:	39 d6                	cmp    %edx,%esi
  8019b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8019b6:	72 30                	jb     8019e8 <__udivdi3+0x118>
  8019b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8019bf:	d3 e2                	shl    %cl,%edx
  8019c1:	39 c2                	cmp    %eax,%edx
  8019c3:	73 05                	jae    8019ca <__udivdi3+0xfa>
  8019c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8019c8:	74 1e                	je     8019e8 <__udivdi3+0x118>
  8019ca:	89 f9                	mov    %edi,%ecx
  8019cc:	31 ff                	xor    %edi,%edi
  8019ce:	e9 71 ff ff ff       	jmp    801944 <__udivdi3+0x74>
  8019d3:	90                   	nop
  8019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019d8:	31 ff                	xor    %edi,%edi
  8019da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8019df:	e9 60 ff ff ff       	jmp    801944 <__udivdi3+0x74>
  8019e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8019eb:	31 ff                	xor    %edi,%edi
  8019ed:	89 c8                	mov    %ecx,%eax
  8019ef:	89 fa                	mov    %edi,%edx
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	5e                   	pop    %esi
  8019f5:	5f                   	pop    %edi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    
	...

00801a00 <__umoddi3>:
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	57                   	push   %edi
  801a04:	56                   	push   %esi
  801a05:	83 ec 20             	sub    $0x20,%esp
  801a08:	8b 55 14             	mov    0x14(%ebp),%edx
  801a0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a0e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a14:	85 d2                	test   %edx,%edx
  801a16:	89 c8                	mov    %ecx,%eax
  801a18:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801a1b:	75 13                	jne    801a30 <__umoddi3+0x30>
  801a1d:	39 f7                	cmp    %esi,%edi
  801a1f:	76 3f                	jbe    801a60 <__umoddi3+0x60>
  801a21:	89 f2                	mov    %esi,%edx
  801a23:	f7 f7                	div    %edi
  801a25:	89 d0                	mov    %edx,%eax
  801a27:	31 d2                	xor    %edx,%edx
  801a29:	83 c4 20             	add    $0x20,%esp
  801a2c:	5e                   	pop    %esi
  801a2d:	5f                   	pop    %edi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    
  801a30:	39 f2                	cmp    %esi,%edx
  801a32:	77 4c                	ja     801a80 <__umoddi3+0x80>
  801a34:	0f bd ca             	bsr    %edx,%ecx
  801a37:	83 f1 1f             	xor    $0x1f,%ecx
  801a3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a3d:	75 51                	jne    801a90 <__umoddi3+0x90>
  801a3f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801a42:	0f 87 e0 00 00 00    	ja     801b28 <__umoddi3+0x128>
  801a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4b:	29 f8                	sub    %edi,%eax
  801a4d:	19 d6                	sbb    %edx,%esi
  801a4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a55:	89 f2                	mov    %esi,%edx
  801a57:	83 c4 20             	add    $0x20,%esp
  801a5a:	5e                   	pop    %esi
  801a5b:	5f                   	pop    %edi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    
  801a5e:	66 90                	xchg   %ax,%ax
  801a60:	85 ff                	test   %edi,%edi
  801a62:	75 0b                	jne    801a6f <__umoddi3+0x6f>
  801a64:	b8 01 00 00 00       	mov    $0x1,%eax
  801a69:	31 d2                	xor    %edx,%edx
  801a6b:	f7 f7                	div    %edi
  801a6d:	89 c7                	mov    %eax,%edi
  801a6f:	89 f0                	mov    %esi,%eax
  801a71:	31 d2                	xor    %edx,%edx
  801a73:	f7 f7                	div    %edi
  801a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a78:	f7 f7                	div    %edi
  801a7a:	eb a9                	jmp    801a25 <__umoddi3+0x25>
  801a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a80:	89 c8                	mov    %ecx,%eax
  801a82:	89 f2                	mov    %esi,%edx
  801a84:	83 c4 20             	add    $0x20,%esp
  801a87:	5e                   	pop    %esi
  801a88:	5f                   	pop    %edi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    
  801a8b:	90                   	nop
  801a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a90:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801a94:	d3 e2                	shl    %cl,%edx
  801a96:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801a99:	ba 20 00 00 00       	mov    $0x20,%edx
  801a9e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801aa1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801aa4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801aa8:	89 fa                	mov    %edi,%edx
  801aaa:	d3 ea                	shr    %cl,%edx
  801aac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ab0:	0b 55 f4             	or     -0xc(%ebp),%edx
  801ab3:	d3 e7                	shl    %cl,%edi
  801ab5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ab9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801abc:	89 f2                	mov    %esi,%edx
  801abe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801ac1:	89 c7                	mov    %eax,%edi
  801ac3:	d3 ea                	shr    %cl,%edx
  801ac5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ac9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801acc:	89 c2                	mov    %eax,%edx
  801ace:	d3 e6                	shl    %cl,%esi
  801ad0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ad4:	d3 ea                	shr    %cl,%edx
  801ad6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ada:	09 d6                	or     %edx,%esi
  801adc:	89 f0                	mov    %esi,%eax
  801ade:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801ae1:	d3 e7                	shl    %cl,%edi
  801ae3:	89 f2                	mov    %esi,%edx
  801ae5:	f7 75 f4             	divl   -0xc(%ebp)
  801ae8:	89 d6                	mov    %edx,%esi
  801aea:	f7 65 e8             	mull   -0x18(%ebp)
  801aed:	39 d6                	cmp    %edx,%esi
  801aef:	72 2b                	jb     801b1c <__umoddi3+0x11c>
  801af1:	39 c7                	cmp    %eax,%edi
  801af3:	72 23                	jb     801b18 <__umoddi3+0x118>
  801af5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801af9:	29 c7                	sub    %eax,%edi
  801afb:	19 d6                	sbb    %edx,%esi
  801afd:	89 f0                	mov    %esi,%eax
  801aff:	89 f2                	mov    %esi,%edx
  801b01:	d3 ef                	shr    %cl,%edi
  801b03:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b07:	d3 e0                	shl    %cl,%eax
  801b09:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b0d:	09 f8                	or     %edi,%eax
  801b0f:	d3 ea                	shr    %cl,%edx
  801b11:	83 c4 20             	add    $0x20,%esp
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    
  801b18:	39 d6                	cmp    %edx,%esi
  801b1a:	75 d9                	jne    801af5 <__umoddi3+0xf5>
  801b1c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801b1f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801b22:	eb d1                	jmp    801af5 <__umoddi3+0xf5>
  801b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b28:	39 f2                	cmp    %esi,%edx
  801b2a:	0f 82 18 ff ff ff    	jb     801a48 <__umoddi3+0x48>
  801b30:	e9 1d ff ff ff       	jmp    801a52 <__umoddi3+0x52>
