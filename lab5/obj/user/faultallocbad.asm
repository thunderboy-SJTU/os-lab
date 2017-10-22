
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80003a:	c7 04 24 5c 00 80 00 	movl   $0x80005c,(%esp)
  800041:	e8 ba 14 00 00       	call   801500 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  800046:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80004d:	00 
  80004e:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  800055:	e8 12 0f 00 00       	call   800f6c <sys_cputs>
}
  80005a:	c9                   	leave  
  80005b:	c3                   	ret    

0080005c <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	53                   	push   %ebx
  800060:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800063:	8b 45 08             	mov    0x8(%ebp),%eax
  800066:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800068:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80006c:	c7 04 24 00 22 80 00 	movl   $0x802200,(%esp)
  800073:	e8 95 01 00 00       	call   80020d <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800078:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80007f:	00 
  800080:	89 d8                	mov    %ebx,%eax
  800082:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800092:	e8 cc 12 00 00       	call   801363 <sys_page_alloc>
  800097:	85 c0                	test   %eax,%eax
  800099:	79 24                	jns    8000bf <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a3:	c7 44 24 08 20 22 80 	movl   $0x802220,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 0a 22 80 00 	movl   $0x80220a,(%esp)
  8000ba:	e8 95 00 00 00       	call   800154 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000c3:	c7 44 24 08 4c 22 80 	movl   $0x80224c,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000d2:	00 
  8000d3:	89 1c 24             	mov    %ebx,(%esp)
  8000d6:	e8 c4 09 00 00       	call   800a9f <snprintf>
}
  8000db:	83 c4 24             	add    $0x24,%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000f6:	e8 57 13 00 00       	call   801452 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	89 c2                	mov    %eax,%edx
  800102:	c1 e2 07             	shl    $0x7,%edx
  800105:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80010c:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800111:	85 f6                	test   %esi,%esi
  800113:	7e 07                	jle    80011c <libmain+0x38>
		binaryname = argv[0];
  800115:	8b 03                	mov    (%ebx),%eax
  800117:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800120:	89 34 24             	mov    %esi,(%esp)
  800123:	e8 0c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800128:	e8 0b 00 00 00       	call   800138 <exit>
}
  80012d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800130:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800133:	89 ec                	mov    %ebp,%esp
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    
	...

00800138 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80013e:	e8 18 19 00 00       	call   801a5b <close_all>
	sys_env_destroy(0);
  800143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014a:	e8 43 13 00 00       	call   801492 <sys_env_destroy>
}
  80014f:	c9                   	leave  
  800150:	c3                   	ret    
  800151:	00 00                	add    %al,(%eax)
	...

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80015c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800165:	e8 e8 12 00 00       	call   801452 <sys_getenvid>
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 78 22 80 00 	movl   $0x802278,(%esp)
  800187:	e8 81 00 00 00       	call   80020d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 11 00 00 00       	call   8001ac <vcprintf>
	cprintf("\n");
  80019b:	c7 04 24 c7 26 80 00 	movl   $0x8026c7,(%esp)
  8001a2:	e8 66 00 00 00       	call   80020d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x53>
	...

008001ac <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bc:	00 00 00 
	b.cnt = 0;
  8001bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	c7 04 24 27 02 80 00 	movl   $0x800227,(%esp)
  8001e8:	e8 cf 01 00 00       	call   8003bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fd:	89 04 24             	mov    %eax,(%esp)
  800200:	e8 67 0d 00 00       	call   800f6c <sys_cputs>

	return b.cnt;
}
  800205:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800213:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	89 04 24             	mov    %eax,(%esp)
  800220:	e8 87 ff ff ff       	call   8001ac <vcprintf>
	va_end(ap);

	return cnt;
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	53                   	push   %ebx
  80022b:	83 ec 14             	sub    $0x14,%esp
  80022e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800231:	8b 03                	mov    (%ebx),%eax
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80023a:	83 c0 01             	add    $0x1,%eax
  80023d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80023f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800244:	75 19                	jne    80025f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800246:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80024d:	00 
  80024e:	8d 43 08             	lea    0x8(%ebx),%eax
  800251:	89 04 24             	mov    %eax,(%esp)
  800254:	e8 13 0d 00 00       	call   800f6c <sys_cputs>
		b->idx = 0;
  800259:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80025f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800263:	83 c4 14             	add    $0x14,%esp
  800266:	5b                   	pop    %ebx
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    
  800269:	00 00                	add    %al,(%eax)
  80026b:	00 00                	add    %al,(%eax)
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 4c             	sub    $0x4c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d6                	mov    %edx,%esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800284:	8b 55 0c             	mov    0xc(%ebp),%edx
  800287:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
  80028d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800290:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800293:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800296:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029b:	39 d1                	cmp    %edx,%ecx
  80029d:	72 07                	jb     8002a6 <printnum_v2+0x36>
  80029f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a2:	39 d0                	cmp    %edx,%eax
  8002a4:	77 5f                	ja     800305 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8002a6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002b9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002bd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002c0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002c3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d1:	00 
  8002d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002df:	e8 ac 1c 00 00       	call   801f90 <__udivdi3>
  8002e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fe:	e8 6d ff ff ff       	call   800270 <printnum_v2>
  800303:	eb 1e                	jmp    800323 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800305:	83 ff 2d             	cmp    $0x2d,%edi
  800308:	74 19                	je     800323 <printnum_v2+0xb3>
		while (--width > 0)
  80030a:	83 eb 01             	sub    $0x1,%ebx
  80030d:	85 db                	test   %ebx,%ebx
  80030f:	90                   	nop
  800310:	7e 11                	jle    800323 <printnum_v2+0xb3>
			putch(padc, putdat);
  800312:	89 74 24 04          	mov    %esi,0x4(%esp)
  800316:	89 3c 24             	mov    %edi,(%esp)
  800319:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80031c:	83 eb 01             	sub    $0x1,%ebx
  80031f:	85 db                	test   %ebx,%ebx
  800321:	7f ef                	jg     800312 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800323:	89 74 24 04          	mov    %esi,0x4(%esp)
  800327:	8b 74 24 04          	mov    0x4(%esp),%esi
  80032b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800332:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800339:	00 
  80033a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80033d:	89 14 24             	mov    %edx,(%esp)
  800340:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800343:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800347:	e8 74 1d 00 00       	call   8020c0 <__umoddi3>
  80034c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800350:	0f be 80 9b 22 80 00 	movsbl 0x80229b(%eax),%eax
  800357:	89 04 24             	mov    %eax,(%esp)
  80035a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80035d:	83 c4 4c             	add    $0x4c,%esp
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800368:	83 fa 01             	cmp    $0x1,%edx
  80036b:	7e 0e                	jle    80037b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800372:	89 08                	mov    %ecx,(%eax)
  800374:	8b 02                	mov    (%edx),%eax
  800376:	8b 52 04             	mov    0x4(%edx),%edx
  800379:	eb 22                	jmp    80039d <getuint+0x38>
	else if (lflag)
  80037b:	85 d2                	test   %edx,%edx
  80037d:	74 10                	je     80038f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	8d 4a 04             	lea    0x4(%edx),%ecx
  800384:	89 08                	mov    %ecx,(%eax)
  800386:	8b 02                	mov    (%edx),%eax
  800388:	ba 00 00 00 00       	mov    $0x0,%edx
  80038d:	eb 0e                	jmp    80039d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	8d 4a 04             	lea    0x4(%edx),%ecx
  800394:	89 08                	mov    %ecx,(%eax)
  800396:	8b 02                	mov    (%edx),%eax
  800398:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ae:	73 0a                	jae    8003ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b3:	88 0a                	mov    %cl,(%edx)
  8003b5:	83 c2 01             	add    $0x1,%edx
  8003b8:	89 10                	mov    %edx,(%eax)
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	57                   	push   %edi
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 6c             	sub    $0x6c,%esp
  8003c5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003c8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003cf:	eb 1a                	jmp    8003eb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	0f 84 66 06 00 00    	je     800a3f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8003d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e0:	89 04 24             	mov    %eax,(%esp)
  8003e3:	ff 55 08             	call   *0x8(%ebp)
  8003e6:	eb 03                	jmp    8003eb <vprintfmt+0x2f>
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003eb:	0f b6 07             	movzbl (%edi),%eax
  8003ee:	83 c7 01             	add    $0x1,%edi
  8003f1:	83 f8 25             	cmp    $0x25,%eax
  8003f4:	75 db                	jne    8003d1 <vprintfmt+0x15>
  8003f6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8003fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ff:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800406:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80040b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800412:	be 00 00 00 00       	mov    $0x0,%esi
  800417:	eb 06                	jmp    80041f <vprintfmt+0x63>
  800419:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80041d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	0f b6 17             	movzbl (%edi),%edx
  800422:	0f b6 c2             	movzbl %dl,%eax
  800425:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800428:	8d 47 01             	lea    0x1(%edi),%eax
  80042b:	83 ea 23             	sub    $0x23,%edx
  80042e:	80 fa 55             	cmp    $0x55,%dl
  800431:	0f 87 60 05 00 00    	ja     800997 <vprintfmt+0x5db>
  800437:	0f b6 d2             	movzbl %dl,%edx
  80043a:	ff 24 95 80 24 80 00 	jmp    *0x802480(,%edx,4)
  800441:	b9 01 00 00 00       	mov    $0x1,%ecx
  800446:	eb d5                	jmp    80041d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800448:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80044b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80044e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800451:	8d 7a d0             	lea    -0x30(%edx),%edi
  800454:	83 ff 09             	cmp    $0x9,%edi
  800457:	76 08                	jbe    800461 <vprintfmt+0xa5>
  800459:	eb 40                	jmp    80049b <vprintfmt+0xdf>
  80045b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80045f:	eb bc                	jmp    80041d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800461:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800464:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800467:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80046b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80046e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800471:	83 ff 09             	cmp    $0x9,%edi
  800474:	76 eb                	jbe    800461 <vprintfmt+0xa5>
  800476:	eb 23                	jmp    80049b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800478:	8b 55 14             	mov    0x14(%ebp),%edx
  80047b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80047e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800481:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800483:	eb 16                	jmp    80049b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800485:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800488:	c1 fa 1f             	sar    $0x1f,%edx
  80048b:	f7 d2                	not    %edx
  80048d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800490:	eb 8b                	jmp    80041d <vprintfmt+0x61>
  800492:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800499:	eb 82                	jmp    80041d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80049b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049f:	0f 89 78 ff ff ff    	jns    80041d <vprintfmt+0x61>
  8004a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004a8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8004ab:	e9 6d ff ff ff       	jmp    80041d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8004b3:	e9 65 ff ff ff       	jmp    80041d <vprintfmt+0x61>
  8004b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 50 04             	lea    0x4(%eax),%edx
  8004c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	89 04 24             	mov    %eax,(%esp)
  8004d0:	ff 55 08             	call   *0x8(%ebp)
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8004d6:	e9 10 ff ff ff       	jmp    8003eb <vprintfmt+0x2f>
  8004db:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8d 50 04             	lea    0x4(%eax),%edx
  8004e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e7:	8b 00                	mov    (%eax),%eax
  8004e9:	89 c2                	mov    %eax,%edx
  8004eb:	c1 fa 1f             	sar    $0x1f,%edx
  8004ee:	31 d0                	xor    %edx,%eax
  8004f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f2:	83 f8 0f             	cmp    $0xf,%eax
  8004f5:	7f 0b                	jg     800502 <vprintfmt+0x146>
  8004f7:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  8004fe:	85 d2                	test   %edx,%edx
  800500:	75 26                	jne    800528 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800502:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800506:	c7 44 24 08 ac 22 80 	movl   $0x8022ac,0x8(%esp)
  80050d:	00 
  80050e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800511:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800515:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800518:	89 1c 24             	mov    %ebx,(%esp)
  80051b:	e8 a7 05 00 00       	call   800ac7 <printfmt>
  800520:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800523:	e9 c3 fe ff ff       	jmp    8003eb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800528:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80052c:	c7 44 24 08 b5 22 80 	movl   $0x8022b5,0x8(%esp)
  800533:	00 
  800534:	8b 45 0c             	mov    0xc(%ebp),%eax
  800537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053b:	8b 55 08             	mov    0x8(%ebp),%edx
  80053e:	89 14 24             	mov    %edx,(%esp)
  800541:	e8 81 05 00 00       	call   800ac7 <printfmt>
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800549:	e9 9d fe ff ff       	jmp    8003eb <vprintfmt+0x2f>
  80054e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800551:	89 c7                	mov    %eax,%edi
  800553:	89 d9                	mov    %ebx,%ecx
  800555:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800558:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 50 04             	lea    0x4(%eax),%edx
  800561:	89 55 14             	mov    %edx,0x14(%ebp)
  800564:	8b 30                	mov    (%eax),%esi
  800566:	85 f6                	test   %esi,%esi
  800568:	75 05                	jne    80056f <vprintfmt+0x1b3>
  80056a:	be b8 22 80 00       	mov    $0x8022b8,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80056f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800573:	7e 06                	jle    80057b <vprintfmt+0x1bf>
  800575:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800579:	75 10                	jne    80058b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057b:	0f be 06             	movsbl (%esi),%eax
  80057e:	85 c0                	test   %eax,%eax
  800580:	0f 85 a2 00 00 00    	jne    800628 <vprintfmt+0x26c>
  800586:	e9 92 00 00 00       	jmp    80061d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80058f:	89 34 24             	mov    %esi,(%esp)
  800592:	e8 74 05 00 00       	call   800b0b <strnlen>
  800597:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80059a:	29 c2                	sub    %eax,%edx
  80059c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	7e d8                	jle    80057b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8005a3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8005a7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005aa:	89 d3                	mov    %edx,%ebx
  8005ac:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005af:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8005b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b5:	89 ce                	mov    %ecx,%esi
  8005b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bb:	89 34 24             	mov    %esi,(%esp)
  8005be:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 eb 01             	sub    $0x1,%ebx
  8005c4:	85 db                	test   %ebx,%ebx
  8005c6:	7f ef                	jg     8005b7 <vprintfmt+0x1fb>
  8005c8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ce:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8005d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005d8:	eb a1                	jmp    80057b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005da:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005de:	74 1b                	je     8005fb <vprintfmt+0x23f>
  8005e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005e3:	83 fa 5e             	cmp    $0x5e,%edx
  8005e6:	76 13                	jbe    8005fb <vprintfmt+0x23f>
					putch('?', putdat);
  8005e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ef:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f9:	eb 0d                	jmp    800608 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	83 ef 01             	sub    $0x1,%edi
  80060b:	0f be 06             	movsbl (%esi),%eax
  80060e:	85 c0                	test   %eax,%eax
  800610:	74 05                	je     800617 <vprintfmt+0x25b>
  800612:	83 c6 01             	add    $0x1,%esi
  800615:	eb 1a                	jmp    800631 <vprintfmt+0x275>
  800617:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80061a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800621:	7f 1f                	jg     800642 <vprintfmt+0x286>
  800623:	e9 c0 fd ff ff       	jmp    8003e8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800628:	83 c6 01             	add    $0x1,%esi
  80062b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80062e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800631:	85 db                	test   %ebx,%ebx
  800633:	78 a5                	js     8005da <vprintfmt+0x21e>
  800635:	83 eb 01             	sub    $0x1,%ebx
  800638:	79 a0                	jns    8005da <vprintfmt+0x21e>
  80063a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80063d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800640:	eb db                	jmp    80061d <vprintfmt+0x261>
  800642:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800645:	8b 75 0c             	mov    0xc(%ebp),%esi
  800648:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80064b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800652:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800659:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065b:	83 eb 01             	sub    $0x1,%ebx
  80065e:	85 db                	test   %ebx,%ebx
  800660:	7f ec                	jg     80064e <vprintfmt+0x292>
  800662:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800665:	e9 81 fd ff ff       	jmp    8003eb <vprintfmt+0x2f>
  80066a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066d:	83 fe 01             	cmp    $0x1,%esi
  800670:	7e 10                	jle    800682 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 08             	lea    0x8(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
  80067b:	8b 18                	mov    (%eax),%ebx
  80067d:	8b 70 04             	mov    0x4(%eax),%esi
  800680:	eb 26                	jmp    8006a8 <vprintfmt+0x2ec>
	else if (lflag)
  800682:	85 f6                	test   %esi,%esi
  800684:	74 12                	je     800698 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 18                	mov    (%eax),%ebx
  800691:	89 de                	mov    %ebx,%esi
  800693:	c1 fe 1f             	sar    $0x1f,%esi
  800696:	eb 10                	jmp    8006a8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 18                	mov    (%eax),%ebx
  8006a3:	89 de                	mov    %ebx,%esi
  8006a5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8006a8:	83 f9 01             	cmp    $0x1,%ecx
  8006ab:	75 1e                	jne    8006cb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8006ad:	85 f6                	test   %esi,%esi
  8006af:	78 1a                	js     8006cb <vprintfmt+0x30f>
  8006b1:	85 f6                	test   %esi,%esi
  8006b3:	7f 05                	jg     8006ba <vprintfmt+0x2fe>
  8006b5:	83 fb 00             	cmp    $0x0,%ebx
  8006b8:	76 11                	jbe    8006cb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8006ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006bd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006c1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8006c8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8006cb:	85 f6                	test   %esi,%esi
  8006cd:	78 13                	js     8006e2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cf:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8006d2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8006d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dd:	e9 da 00 00 00       	jmp    8007bc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f3:	89 da                	mov    %ebx,%edx
  8006f5:	89 f1                	mov    %esi,%ecx
  8006f7:	f7 da                	neg    %edx
  8006f9:	83 d1 00             	adc    $0x0,%ecx
  8006fc:	f7 d9                	neg    %ecx
  8006fe:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800701:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800707:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070c:	e9 ab 00 00 00       	jmp    8007bc <vprintfmt+0x400>
  800711:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800714:	89 f2                	mov    %esi,%edx
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
  800719:	e8 47 fc ff ff       	call   800365 <getuint>
  80071e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800721:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80072c:	e9 8b 00 00 00       	jmp    8007bc <vprintfmt+0x400>
  800731:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800737:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80073b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800742:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800745:	89 f2                	mov    %esi,%edx
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 16 fc ff ff       	call   800365 <getuint>
  80074f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800752:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800758:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80075d:	eb 5d                	jmp    8007bc <vprintfmt+0x400>
  80075f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800762:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800765:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800769:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800770:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800773:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800777:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)
  80078a:	8b 10                	mov    (%eax),%edx
  80078c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800791:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800794:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800797:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80079f:	eb 1b                	jmp    8007bc <vprintfmt+0x400>
  8007a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a4:	89 f2                	mov    %esi,%edx
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	e8 b7 fb ff ff       	call   800365 <getuint>
  8007ae:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007b1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8007c0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007c6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8007ca:	77 09                	ja     8007d5 <vprintfmt+0x419>
  8007cc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8007cf:	0f 82 ac 00 00 00    	jb     800881 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8007d5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007d8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8007dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007df:	83 ea 01             	sub    $0x1,%edx
  8007e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	8b 44 24 08          	mov    0x8(%esp),%eax
  8007ee:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8007f2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8007f5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8007f8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800806:	00 
  800807:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80080a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80080d:	89 0c 24             	mov    %ecx,(%esp)
  800810:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800814:	e8 77 17 00 00       	call   801f90 <__udivdi3>
  800819:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80081c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80081f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800823:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	e8 37 fa ff ff       	call   800270 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800839:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800840:	8b 74 24 04          	mov    0x4(%esp),%esi
  800844:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800847:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800852:	00 
  800853:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800856:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800859:	89 14 24             	mov    %edx,(%esp)
  80085c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800860:	e8 5b 18 00 00       	call   8020c0 <__umoddi3>
  800865:	89 74 24 04          	mov    %esi,0x4(%esp)
  800869:	0f be 80 9b 22 80 00 	movsbl 0x80229b(%eax),%eax
  800870:	89 04 24             	mov    %eax,(%esp)
  800873:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800876:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80087a:	74 54                	je     8008d0 <vprintfmt+0x514>
  80087c:	e9 67 fb ff ff       	jmp    8003e8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800881:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800885:	8d 76 00             	lea    0x0(%esi),%esi
  800888:	0f 84 2a 01 00 00    	je     8009b8 <vprintfmt+0x5fc>
		while (--width > 0)
  80088e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800891:	83 ef 01             	sub    $0x1,%edi
  800894:	85 ff                	test   %edi,%edi
  800896:	0f 8e 5e 01 00 00    	jle    8009fa <vprintfmt+0x63e>
  80089c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80089f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008a2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8008a5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8008a8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8008ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b2:	89 1c 24             	mov    %ebx,(%esp)
  8008b5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8008b8:	83 ef 01             	sub    $0x1,%edi
  8008bb:	85 ff                	test   %edi,%edi
  8008bd:	7f ef                	jg     8008ae <vprintfmt+0x4f2>
  8008bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008c5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8008c8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8008cb:	e9 2a 01 00 00       	jmp    8009fa <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008d0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8008d3:	83 eb 01             	sub    $0x1,%ebx
  8008d6:	85 db                	test   %ebx,%ebx
  8008d8:	0f 8e 0a fb ff ff    	jle    8003e8 <vprintfmt+0x2c>
  8008de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008e4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8008e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008eb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008f2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008f4:	83 eb 01             	sub    $0x1,%ebx
  8008f7:	85 db                	test   %ebx,%ebx
  8008f9:	7f ec                	jg     8008e7 <vprintfmt+0x52b>
  8008fb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008fe:	e9 e8 fa ff ff       	jmp    8003eb <vprintfmt+0x2f>
  800903:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8d 50 04             	lea    0x4(%eax),%edx
  80090c:	89 55 14             	mov    %edx,0x14(%ebp)
  80090f:	8b 00                	mov    (%eax),%eax
  800911:	85 c0                	test   %eax,%eax
  800913:	75 2a                	jne    80093f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800915:	c7 44 24 0c d4 23 80 	movl   $0x8023d4,0xc(%esp)
  80091c:	00 
  80091d:	c7 44 24 08 b5 22 80 	movl   $0x8022b5,0x8(%esp)
  800924:	00 
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
  800928:	89 54 24 04          	mov    %edx,0x4(%esp)
  80092c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092f:	89 0c 24             	mov    %ecx,(%esp)
  800932:	e8 90 01 00 00       	call   800ac7 <printfmt>
  800937:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80093a:	e9 ac fa ff ff       	jmp    8003eb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80093f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800942:	8b 13                	mov    (%ebx),%edx
  800944:	83 fa 7f             	cmp    $0x7f,%edx
  800947:	7e 29                	jle    800972 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800949:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80094b:	c7 44 24 0c 0c 24 80 	movl   $0x80240c,0xc(%esp)
  800952:	00 
  800953:	c7 44 24 08 b5 22 80 	movl   $0x8022b5,0x8(%esp)
  80095a:	00 
  80095b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	89 04 24             	mov    %eax,(%esp)
  800965:	e8 5d 01 00 00       	call   800ac7 <printfmt>
  80096a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096d:	e9 79 fa ff ff       	jmp    8003eb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800972:	88 10                	mov    %dl,(%eax)
  800974:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800977:	e9 6f fa ff ff       	jmp    8003eb <vprintfmt+0x2f>
  80097c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80097f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800985:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800989:	89 14 24             	mov    %edx,(%esp)
  80098c:	ff 55 08             	call   *0x8(%ebp)
  80098f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800992:	e9 54 fa ff ff       	jmp    8003eb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80099a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8009ab:	80 38 25             	cmpb   $0x25,(%eax)
  8009ae:	0f 84 37 fa ff ff    	je     8003eb <vprintfmt+0x2f>
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	eb f0                	jmp    8009a8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009c3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009d1:	00 
  8009d2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009d5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009d8:	89 04 24             	mov    %eax,(%esp)
  8009db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009df:	e8 dc 16 00 00       	call   8020c0 <__umoddi3>
  8009e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e8:	0f be 80 9b 22 80 00 	movsbl 0x80229b(%eax),%eax
  8009ef:	89 04 24             	mov    %eax,(%esp)
  8009f2:	ff 55 08             	call   *0x8(%ebp)
  8009f5:	e9 d6 fe ff ff       	jmp    8008d0 <vprintfmt+0x514>
  8009fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a01:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a05:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a0c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a13:	00 
  800a14:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a17:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a1a:	89 04 24             	mov    %eax,(%esp)
  800a1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a21:	e8 9a 16 00 00       	call   8020c0 <__umoddi3>
  800a26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2a:	0f be 80 9b 22 80 00 	movsbl 0x80229b(%eax),%eax
  800a31:	89 04 24             	mov    %eax,(%esp)
  800a34:	ff 55 08             	call   *0x8(%ebp)
  800a37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a3a:	e9 ac f9 ff ff       	jmp    8003eb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a3f:	83 c4 6c             	add    $0x6c,%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	83 ec 28             	sub    $0x28,%esp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a53:	85 c0                	test   %eax,%eax
  800a55:	74 04                	je     800a5b <vsnprintf+0x14>
  800a57:	85 d2                	test   %edx,%edx
  800a59:	7f 07                	jg     800a62 <vsnprintf+0x1b>
  800a5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a60:	eb 3b                	jmp    800a9d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a65:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a73:	8b 45 14             	mov    0x14(%ebp),%eax
  800a76:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a81:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a88:	c7 04 24 9f 03 80 00 	movl   $0x80039f,(%esp)
  800a8f:	e8 28 f9 ff ff       	call   8003bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a97:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800aa5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800aa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aac:	8b 45 10             	mov    0x10(%ebp),%eax
  800aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	89 04 24             	mov    %eax,(%esp)
  800ac0:	e8 82 ff ff ff       	call   800a47 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800acd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800ad0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	89 04 24             	mov    %eax,(%esp)
  800ae8:	e8 cf f8 ff ff       	call   8003bc <vprintfmt>
	va_end(ap);
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    
	...

00800af0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	80 3a 00             	cmpb   $0x0,(%edx)
  800afe:	74 09                	je     800b09 <strlen+0x19>
		n++;
  800b00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b07:	75 f7                	jne    800b00 <strlen+0x10>
		n++;
	return n;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b15:	85 c9                	test   %ecx,%ecx
  800b17:	74 19                	je     800b32 <strnlen+0x27>
  800b19:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b1c:	74 14                	je     800b32 <strnlen+0x27>
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b23:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b26:	39 c8                	cmp    %ecx,%eax
  800b28:	74 0d                	je     800b37 <strnlen+0x2c>
  800b2a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b2e:	75 f3                	jne    800b23 <strnlen+0x18>
  800b30:	eb 05                	jmp    800b37 <strnlen+0x2c>
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b37:	5b                   	pop    %ebx
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	53                   	push   %ebx
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	84 c9                	test   %cl,%cl
  800b55:	75 f2                	jne    800b49 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b57:	5b                   	pop    %ebx
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 08             	sub    $0x8,%esp
  800b61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b64:	89 1c 24             	mov    %ebx,(%esp)
  800b67:	e8 84 ff ff ff       	call   800af0 <strlen>
	strcpy(dst + len, src);
  800b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b73:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b76:	89 04 24             	mov    %eax,(%esp)
  800b79:	e8 bc ff ff ff       	call   800b3a <strcpy>
	return dst;
}
  800b7e:	89 d8                	mov    %ebx,%eax
  800b80:	83 c4 08             	add    $0x8,%esp
  800b83:	5b                   	pop    %ebx
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b91:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	85 f6                	test   %esi,%esi
  800b96:	74 18                	je     800bb0 <strncpy+0x2a>
  800b98:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ba0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ba6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba9:	83 c1 01             	add    $0x1,%ecx
  800bac:	39 ce                	cmp    %ecx,%esi
  800bae:	77 ed                	ja     800b9d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc2:	89 f0                	mov    %esi,%eax
  800bc4:	85 c9                	test   %ecx,%ecx
  800bc6:	74 27                	je     800bef <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800bc8:	83 e9 01             	sub    $0x1,%ecx
  800bcb:	74 1d                	je     800bea <strlcpy+0x36>
  800bcd:	0f b6 1a             	movzbl (%edx),%ebx
  800bd0:	84 db                	test   %bl,%bl
  800bd2:	74 16                	je     800bea <strlcpy+0x36>
			*dst++ = *src++;
  800bd4:	88 18                	mov    %bl,(%eax)
  800bd6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd9:	83 e9 01             	sub    $0x1,%ecx
  800bdc:	74 0e                	je     800bec <strlcpy+0x38>
			*dst++ = *src++;
  800bde:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800be1:	0f b6 1a             	movzbl (%edx),%ebx
  800be4:	84 db                	test   %bl,%bl
  800be6:	75 ec                	jne    800bd4 <strlcpy+0x20>
  800be8:	eb 02                	jmp    800bec <strlcpy+0x38>
  800bea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bec:	c6 00 00             	movb   $0x0,(%eax)
  800bef:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bfe:	0f b6 01             	movzbl (%ecx),%eax
  800c01:	84 c0                	test   %al,%al
  800c03:	74 15                	je     800c1a <strcmp+0x25>
  800c05:	3a 02                	cmp    (%edx),%al
  800c07:	75 11                	jne    800c1a <strcmp+0x25>
		p++, q++;
  800c09:	83 c1 01             	add    $0x1,%ecx
  800c0c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c0f:	0f b6 01             	movzbl (%ecx),%eax
  800c12:	84 c0                	test   %al,%al
  800c14:	74 04                	je     800c1a <strcmp+0x25>
  800c16:	3a 02                	cmp    (%edx),%al
  800c18:	74 ef                	je     800c09 <strcmp+0x14>
  800c1a:	0f b6 c0             	movzbl %al,%eax
  800c1d:	0f b6 12             	movzbl (%edx),%edx
  800c20:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	53                   	push   %ebx
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	74 23                	je     800c58 <strncmp+0x34>
  800c35:	0f b6 1a             	movzbl (%edx),%ebx
  800c38:	84 db                	test   %bl,%bl
  800c3a:	74 25                	je     800c61 <strncmp+0x3d>
  800c3c:	3a 19                	cmp    (%ecx),%bl
  800c3e:	75 21                	jne    800c61 <strncmp+0x3d>
  800c40:	83 e8 01             	sub    $0x1,%eax
  800c43:	74 13                	je     800c58 <strncmp+0x34>
		n--, p++, q++;
  800c45:	83 c2 01             	add    $0x1,%edx
  800c48:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c4b:	0f b6 1a             	movzbl (%edx),%ebx
  800c4e:	84 db                	test   %bl,%bl
  800c50:	74 0f                	je     800c61 <strncmp+0x3d>
  800c52:	3a 19                	cmp    (%ecx),%bl
  800c54:	74 ea                	je     800c40 <strncmp+0x1c>
  800c56:	eb 09                	jmp    800c61 <strncmp+0x3d>
  800c58:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5d                   	pop    %ebp
  800c5f:	90                   	nop
  800c60:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c61:	0f b6 02             	movzbl (%edx),%eax
  800c64:	0f b6 11             	movzbl (%ecx),%edx
  800c67:	29 d0                	sub    %edx,%eax
  800c69:	eb f2                	jmp    800c5d <strncmp+0x39>

00800c6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	0f b6 10             	movzbl (%eax),%edx
  800c78:	84 d2                	test   %dl,%dl
  800c7a:	74 18                	je     800c94 <strchr+0x29>
		if (*s == c)
  800c7c:	38 ca                	cmp    %cl,%dl
  800c7e:	75 0a                	jne    800c8a <strchr+0x1f>
  800c80:	eb 17                	jmp    800c99 <strchr+0x2e>
  800c82:	38 ca                	cmp    %cl,%dl
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	74 0f                	je     800c99 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c8a:	83 c0 01             	add    $0x1,%eax
  800c8d:	0f b6 10             	movzbl (%eax),%edx
  800c90:	84 d2                	test   %dl,%dl
  800c92:	75 ee                	jne    800c82 <strchr+0x17>
  800c94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca5:	0f b6 10             	movzbl (%eax),%edx
  800ca8:	84 d2                	test   %dl,%dl
  800caa:	74 18                	je     800cc4 <strfind+0x29>
		if (*s == c)
  800cac:	38 ca                	cmp    %cl,%dl
  800cae:	75 0a                	jne    800cba <strfind+0x1f>
  800cb0:	eb 12                	jmp    800cc4 <strfind+0x29>
  800cb2:	38 ca                	cmp    %cl,%dl
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	74 0a                	je     800cc4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	0f b6 10             	movzbl (%eax),%edx
  800cc0:	84 d2                	test   %dl,%dl
  800cc2:	75 ee                	jne    800cb2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	89 1c 24             	mov    %ebx,(%esp)
  800ccf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ce0:	85 c9                	test   %ecx,%ecx
  800ce2:	74 30                	je     800d14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ce4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cea:	75 25                	jne    800d11 <memset+0x4b>
  800cec:	f6 c1 03             	test   $0x3,%cl
  800cef:	75 20                	jne    800d11 <memset+0x4b>
		c &= 0xFF;
  800cf1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cf4:	89 d3                	mov    %edx,%ebx
  800cf6:	c1 e3 08             	shl    $0x8,%ebx
  800cf9:	89 d6                	mov    %edx,%esi
  800cfb:	c1 e6 18             	shl    $0x18,%esi
  800cfe:	89 d0                	mov    %edx,%eax
  800d00:	c1 e0 10             	shl    $0x10,%eax
  800d03:	09 f0                	or     %esi,%eax
  800d05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d07:	09 d8                	or     %ebx,%eax
  800d09:	c1 e9 02             	shr    $0x2,%ecx
  800d0c:	fc                   	cld    
  800d0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d0f:	eb 03                	jmp    800d14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d11:	fc                   	cld    
  800d12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d14:	89 f8                	mov    %edi,%eax
  800d16:	8b 1c 24             	mov    (%esp),%ebx
  800d19:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d21:	89 ec                	mov    %ebp,%esp
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	83 ec 08             	sub    $0x8,%esp
  800d2b:	89 34 24             	mov    %esi,(%esp)
  800d2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d3d:	39 c6                	cmp    %eax,%esi
  800d3f:	73 35                	jae    800d76 <memmove+0x51>
  800d41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d44:	39 d0                	cmp    %edx,%eax
  800d46:	73 2e                	jae    800d76 <memmove+0x51>
		s += n;
		d += n;
  800d48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d4a:	f6 c2 03             	test   $0x3,%dl
  800d4d:	75 1b                	jne    800d6a <memmove+0x45>
  800d4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d55:	75 13                	jne    800d6a <memmove+0x45>
  800d57:	f6 c1 03             	test   $0x3,%cl
  800d5a:	75 0e                	jne    800d6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d5c:	83 ef 04             	sub    $0x4,%edi
  800d5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d62:	c1 e9 02             	shr    $0x2,%ecx
  800d65:	fd                   	std    
  800d66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d68:	eb 09                	jmp    800d73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d6a:	83 ef 01             	sub    $0x1,%edi
  800d6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d70:	fd                   	std    
  800d71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d74:	eb 20                	jmp    800d96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d7c:	75 15                	jne    800d93 <memmove+0x6e>
  800d7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d84:	75 0d                	jne    800d93 <memmove+0x6e>
  800d86:	f6 c1 03             	test   $0x3,%cl
  800d89:	75 08                	jne    800d93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d8b:	c1 e9 02             	shr    $0x2,%ecx
  800d8e:	fc                   	cld    
  800d8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d91:	eb 03                	jmp    800d96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d93:	fc                   	cld    
  800d94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d96:	8b 34 24             	mov    (%esp),%esi
  800d99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d9d:	89 ec                	mov    %ebp,%esp
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800da7:	8b 45 10             	mov    0x10(%ebp),%eax
  800daa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	89 04 24             	mov    %eax,(%esp)
  800dbb:	e8 65 ff ff ff       	call   800d25 <memmove>
}
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    

00800dc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800dcb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd1:	85 c9                	test   %ecx,%ecx
  800dd3:	74 36                	je     800e0b <memcmp+0x49>
		if (*s1 != *s2)
  800dd5:	0f b6 06             	movzbl (%esi),%eax
  800dd8:	0f b6 1f             	movzbl (%edi),%ebx
  800ddb:	38 d8                	cmp    %bl,%al
  800ddd:	74 20                	je     800dff <memcmp+0x3d>
  800ddf:	eb 14                	jmp    800df5 <memcmp+0x33>
  800de1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800de6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800deb:	83 c2 01             	add    $0x1,%edx
  800dee:	83 e9 01             	sub    $0x1,%ecx
  800df1:	38 d8                	cmp    %bl,%al
  800df3:	74 12                	je     800e07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800df5:	0f b6 c0             	movzbl %al,%eax
  800df8:	0f b6 db             	movzbl %bl,%ebx
  800dfb:	29 d8                	sub    %ebx,%eax
  800dfd:	eb 11                	jmp    800e10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dff:	83 e9 01             	sub    $0x1,%ecx
  800e02:	ba 00 00 00 00       	mov    $0x0,%edx
  800e07:	85 c9                	test   %ecx,%ecx
  800e09:	75 d6                	jne    800de1 <memcmp+0x1f>
  800e0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e1b:	89 c2                	mov    %eax,%edx
  800e1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e20:	39 d0                	cmp    %edx,%eax
  800e22:	73 15                	jae    800e39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e28:	38 08                	cmp    %cl,(%eax)
  800e2a:	75 06                	jne    800e32 <memfind+0x1d>
  800e2c:	eb 0b                	jmp    800e39 <memfind+0x24>
  800e2e:	38 08                	cmp    %cl,(%eax)
  800e30:	74 07                	je     800e39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e32:	83 c0 01             	add    $0x1,%eax
  800e35:	39 c2                	cmp    %eax,%edx
  800e37:	77 f5                	ja     800e2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	83 ec 04             	sub    $0x4,%esp
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e4a:	0f b6 02             	movzbl (%edx),%eax
  800e4d:	3c 20                	cmp    $0x20,%al
  800e4f:	74 04                	je     800e55 <strtol+0x1a>
  800e51:	3c 09                	cmp    $0x9,%al
  800e53:	75 0e                	jne    800e63 <strtol+0x28>
		s++;
  800e55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e58:	0f b6 02             	movzbl (%edx),%eax
  800e5b:	3c 20                	cmp    $0x20,%al
  800e5d:	74 f6                	je     800e55 <strtol+0x1a>
  800e5f:	3c 09                	cmp    $0x9,%al
  800e61:	74 f2                	je     800e55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e63:	3c 2b                	cmp    $0x2b,%al
  800e65:	75 0c                	jne    800e73 <strtol+0x38>
		s++;
  800e67:	83 c2 01             	add    $0x1,%edx
  800e6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e71:	eb 15                	jmp    800e88 <strtol+0x4d>
	else if (*s == '-')
  800e73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e7a:	3c 2d                	cmp    $0x2d,%al
  800e7c:	75 0a                	jne    800e88 <strtol+0x4d>
		s++, neg = 1;
  800e7e:	83 c2 01             	add    $0x1,%edx
  800e81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e88:	85 db                	test   %ebx,%ebx
  800e8a:	0f 94 c0             	sete   %al
  800e8d:	74 05                	je     800e94 <strtol+0x59>
  800e8f:	83 fb 10             	cmp    $0x10,%ebx
  800e92:	75 18                	jne    800eac <strtol+0x71>
  800e94:	80 3a 30             	cmpb   $0x30,(%edx)
  800e97:	75 13                	jne    800eac <strtol+0x71>
  800e99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ea0:	75 0a                	jne    800eac <strtol+0x71>
		s += 2, base = 16;
  800ea2:	83 c2 02             	add    $0x2,%edx
  800ea5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eaa:	eb 15                	jmp    800ec1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eac:	84 c0                	test   %al,%al
  800eae:	66 90                	xchg   %ax,%ax
  800eb0:	74 0f                	je     800ec1 <strtol+0x86>
  800eb2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800eb7:	80 3a 30             	cmpb   $0x30,(%edx)
  800eba:	75 05                	jne    800ec1 <strtol+0x86>
		s++, base = 8;
  800ebc:	83 c2 01             	add    $0x1,%edx
  800ebf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ec8:	0f b6 0a             	movzbl (%edx),%ecx
  800ecb:	89 cf                	mov    %ecx,%edi
  800ecd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ed0:	80 fb 09             	cmp    $0x9,%bl
  800ed3:	77 08                	ja     800edd <strtol+0xa2>
			dig = *s - '0';
  800ed5:	0f be c9             	movsbl %cl,%ecx
  800ed8:	83 e9 30             	sub    $0x30,%ecx
  800edb:	eb 1e                	jmp    800efb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800edd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ee0:	80 fb 19             	cmp    $0x19,%bl
  800ee3:	77 08                	ja     800eed <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ee5:	0f be c9             	movsbl %cl,%ecx
  800ee8:	83 e9 57             	sub    $0x57,%ecx
  800eeb:	eb 0e                	jmp    800efb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800eed:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ef0:	80 fb 19             	cmp    $0x19,%bl
  800ef3:	77 15                	ja     800f0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ef5:	0f be c9             	movsbl %cl,%ecx
  800ef8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800efb:	39 f1                	cmp    %esi,%ecx
  800efd:	7d 0b                	jge    800f0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800eff:	83 c2 01             	add    $0x1,%edx
  800f02:	0f af c6             	imul   %esi,%eax
  800f05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f08:	eb be                	jmp    800ec8 <strtol+0x8d>
  800f0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f10:	74 05                	je     800f17 <strtol+0xdc>
		*endptr = (char *) s;
  800f12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f1b:	74 04                	je     800f21 <strtol+0xe6>
  800f1d:	89 c8                	mov    %ecx,%eax
  800f1f:	f7 d8                	neg    %eax
}
  800f21:	83 c4 04             	add    $0x4,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	00 00                	add    %al,(%eax)
	...

00800f2c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
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
  800f39:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f43:	89 d1                	mov    %edx,%ecx
  800f45:	89 d3                	mov    %edx,%ebx
  800f47:	89 d7                	mov    %edx,%edi
  800f49:	51                   	push   %ecx
  800f4a:	52                   	push   %edx
  800f4b:	53                   	push   %ebx
  800f4c:	54                   	push   %esp
  800f4d:	55                   	push   %ebp
  800f4e:	56                   	push   %esi
  800f4f:	57                   	push   %edi
  800f50:	54                   	push   %esp
  800f51:	5d                   	pop    %ebp
  800f52:	8d 35 5a 0f 80 00    	lea    0x800f5a,%esi
  800f58:	0f 34                	sysenter 
  800f5a:	5f                   	pop    %edi
  800f5b:	5e                   	pop    %esi
  800f5c:	5d                   	pop    %ebp
  800f5d:	5c                   	pop    %esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5a                   	pop    %edx
  800f60:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f61:	8b 1c 24             	mov    (%esp),%ebx
  800f64:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 08             	sub    $0x8,%esp
  800f72:	89 1c 24             	mov    %ebx,(%esp)
  800f75:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	89 c3                	mov    %eax,%ebx
  800f86:	89 c7                	mov    %eax,%edi
  800f88:	51                   	push   %ecx
  800f89:	52                   	push   %edx
  800f8a:	53                   	push   %ebx
  800f8b:	54                   	push   %esp
  800f8c:	55                   	push   %ebp
  800f8d:	56                   	push   %esi
  800f8e:	57                   	push   %edi
  800f8f:	54                   	push   %esp
  800f90:	5d                   	pop    %ebp
  800f91:	8d 35 99 0f 80 00    	lea    0x800f99,%esi
  800f97:	0f 34                	sysenter 
  800f99:	5f                   	pop    %edi
  800f9a:	5e                   	pop    %esi
  800f9b:	5d                   	pop    %ebp
  800f9c:	5c                   	pop    %esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5a                   	pop    %edx
  800f9f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fa0:	8b 1c 24             	mov    (%esp),%ebx
  800fa3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fa7:	89 ec                	mov    %ebp,%esp
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 08             	sub    $0x8,%esp
  800fb1:	89 1c 24             	mov    %ebx,(%esp)
  800fb4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb8:	b8 10 00 00 00       	mov    $0x10,%eax
  800fbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc9:	51                   	push   %ecx
  800fca:	52                   	push   %edx
  800fcb:	53                   	push   %ebx
  800fcc:	54                   	push   %esp
  800fcd:	55                   	push   %ebp
  800fce:	56                   	push   %esi
  800fcf:	57                   	push   %edi
  800fd0:	54                   	push   %esp
  800fd1:	5d                   	pop    %ebp
  800fd2:	8d 35 da 0f 80 00    	lea    0x800fda,%esi
  800fd8:	0f 34                	sysenter 
  800fda:	5f                   	pop    %edi
  800fdb:	5e                   	pop    %esi
  800fdc:	5d                   	pop    %ebp
  800fdd:	5c                   	pop    %esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5a                   	pop    %edx
  800fe0:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800fe1:	8b 1c 24             	mov    (%esp),%ebx
  800fe4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe8:	89 ec                	mov    %ebp,%esp
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 28             	sub    $0x28,%esp
  800ff2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ff5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffd:	b8 0f 00 00 00       	mov    $0xf,%eax
  801002:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801005:	8b 55 08             	mov    0x8(%ebp),%edx
  801008:	89 df                	mov    %ebx,%edi
  80100a:	51                   	push   %ecx
  80100b:	52                   	push   %edx
  80100c:	53                   	push   %ebx
  80100d:	54                   	push   %esp
  80100e:	55                   	push   %ebp
  80100f:	56                   	push   %esi
  801010:	57                   	push   %edi
  801011:	54                   	push   %esp
  801012:	5d                   	pop    %ebp
  801013:	8d 35 1b 10 80 00    	lea    0x80101b,%esi
  801019:	0f 34                	sysenter 
  80101b:	5f                   	pop    %edi
  80101c:	5e                   	pop    %esi
  80101d:	5d                   	pop    %ebp
  80101e:	5c                   	pop    %esp
  80101f:	5b                   	pop    %ebx
  801020:	5a                   	pop    %edx
  801021:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801022:	85 c0                	test   %eax,%eax
  801024:	7e 28                	jle    80104e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801026:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801031:	00 
  801032:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  801049:	e8 06 f1 ff ff       	call   800154 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80104e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801051:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801054:	89 ec                	mov    %ebp,%esp
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 08             	sub    $0x8,%esp
  80105e:	89 1c 24             	mov    %ebx,(%esp)
  801061:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801065:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106a:	b8 11 00 00 00       	mov    $0x11,%eax
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80108e:	8b 1c 24             	mov    (%esp),%ebx
  801091:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801095:	89 ec                	mov    %ebp,%esp
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	83 ec 28             	sub    $0x28,%esp
  80109f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010a2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010aa:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010af:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b2:	89 cb                	mov    %ecx,%ebx
  8010b4:	89 cf                	mov    %ecx,%edi
  8010b6:	51                   	push   %ecx
  8010b7:	52                   	push   %edx
  8010b8:	53                   	push   %ebx
  8010b9:	54                   	push   %esp
  8010ba:	55                   	push   %ebp
  8010bb:	56                   	push   %esi
  8010bc:	57                   	push   %edi
  8010bd:	54                   	push   %esp
  8010be:	5d                   	pop    %ebp
  8010bf:	8d 35 c7 10 80 00    	lea    0x8010c7,%esi
  8010c5:	0f 34                	sysenter 
  8010c7:	5f                   	pop    %edi
  8010c8:	5e                   	pop    %esi
  8010c9:	5d                   	pop    %ebp
  8010ca:	5c                   	pop    %esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5a                   	pop    %edx
  8010cd:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	7e 28                	jle    8010fa <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d6:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8010dd:	00 
  8010de:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8010e5:	00 
  8010e6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010ed:	00 
  8010ee:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  8010f5:	e8 5a f0 ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010fa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801100:	89 ec                	mov    %ebp,%esp
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	89 1c 24             	mov    %ebx,(%esp)
  80110d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801111:	b8 0d 00 00 00       	mov    $0xd,%eax
  801116:	8b 7d 14             	mov    0x14(%ebp),%edi
  801119:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80111c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111f:	8b 55 08             	mov    0x8(%ebp),%edx
  801122:	51                   	push   %ecx
  801123:	52                   	push   %edx
  801124:	53                   	push   %ebx
  801125:	54                   	push   %esp
  801126:	55                   	push   %ebp
  801127:	56                   	push   %esi
  801128:	57                   	push   %edi
  801129:	54                   	push   %esp
  80112a:	5d                   	pop    %ebp
  80112b:	8d 35 33 11 80 00    	lea    0x801133,%esi
  801131:	0f 34                	sysenter 
  801133:	5f                   	pop    %edi
  801134:	5e                   	pop    %esi
  801135:	5d                   	pop    %ebp
  801136:	5c                   	pop    %esp
  801137:	5b                   	pop    %ebx
  801138:	5a                   	pop    %edx
  801139:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80113a:	8b 1c 24             	mov    (%esp),%ebx
  80113d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801141:	89 ec                	mov    %ebp,%esp
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 28             	sub    $0x28,%esp
  80114b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80114e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801151:	bb 00 00 00 00       	mov    $0x0,%ebx
  801156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80115b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115e:	8b 55 08             	mov    0x8(%ebp),%edx
  801161:	89 df                	mov    %ebx,%edi
  801163:	51                   	push   %ecx
  801164:	52                   	push   %edx
  801165:	53                   	push   %ebx
  801166:	54                   	push   %esp
  801167:	55                   	push   %ebp
  801168:	56                   	push   %esi
  801169:	57                   	push   %edi
  80116a:	54                   	push   %esp
  80116b:	5d                   	pop    %ebp
  80116c:	8d 35 74 11 80 00    	lea    0x801174,%esi
  801172:	0f 34                	sysenter 
  801174:	5f                   	pop    %edi
  801175:	5e                   	pop    %esi
  801176:	5d                   	pop    %ebp
  801177:	5c                   	pop    %esp
  801178:	5b                   	pop    %ebx
  801179:	5a                   	pop    %edx
  80117a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80117b:	85 c0                	test   %eax,%eax
  80117d:	7e 28                	jle    8011a7 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801183:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80118a:	00 
  80118b:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  801192:	00 
  801193:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80119a:	00 
  80119b:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  8011a2:	e8 ad ef ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011a7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ad:	89 ec                	mov    %ebp,%esp
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 28             	sub    $0x28,%esp
  8011b7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011ba:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cd:	89 df                	mov    %ebx,%edi
  8011cf:	51                   	push   %ecx
  8011d0:	52                   	push   %edx
  8011d1:	53                   	push   %ebx
  8011d2:	54                   	push   %esp
  8011d3:	55                   	push   %ebp
  8011d4:	56                   	push   %esi
  8011d5:	57                   	push   %edi
  8011d6:	54                   	push   %esp
  8011d7:	5d                   	pop    %ebp
  8011d8:	8d 35 e0 11 80 00    	lea    0x8011e0,%esi
  8011de:	0f 34                	sysenter 
  8011e0:	5f                   	pop    %edi
  8011e1:	5e                   	pop    %esi
  8011e2:	5d                   	pop    %ebp
  8011e3:	5c                   	pop    %esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5a                   	pop    %edx
  8011e6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	7e 28                	jle    801213 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ef:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8011fe:	00 
  8011ff:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801206:	00 
  801207:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  80120e:	e8 41 ef ff ff       	call   800154 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801213:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801216:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801219:	89 ec                	mov    %ebp,%esp
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	83 ec 28             	sub    $0x28,%esp
  801223:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801226:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122e:	b8 09 00 00 00       	mov    $0x9,%eax
  801233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801236:	8b 55 08             	mov    0x8(%ebp),%edx
  801239:	89 df                	mov    %ebx,%edi
  80123b:	51                   	push   %ecx
  80123c:	52                   	push   %edx
  80123d:	53                   	push   %ebx
  80123e:	54                   	push   %esp
  80123f:	55                   	push   %ebp
  801240:	56                   	push   %esi
  801241:	57                   	push   %edi
  801242:	54                   	push   %esp
  801243:	5d                   	pop    %ebp
  801244:	8d 35 4c 12 80 00    	lea    0x80124c,%esi
  80124a:	0f 34                	sysenter 
  80124c:	5f                   	pop    %edi
  80124d:	5e                   	pop    %esi
  80124e:	5d                   	pop    %ebp
  80124f:	5c                   	pop    %esp
  801250:	5b                   	pop    %ebx
  801251:	5a                   	pop    %edx
  801252:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	7e 28                	jle    80127f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801257:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801262:	00 
  801263:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  80126a:	00 
  80126b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801272:	00 
  801273:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  80127a:	e8 d5 ee ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80127f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801282:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801285:	89 ec                	mov    %ebp,%esp
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 28             	sub    $0x28,%esp
  80128f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801292:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801295:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129a:	b8 07 00 00 00       	mov    $0x7,%eax
  80129f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a5:	89 df                	mov    %ebx,%edi
  8012a7:	51                   	push   %ecx
  8012a8:	52                   	push   %edx
  8012a9:	53                   	push   %ebx
  8012aa:	54                   	push   %esp
  8012ab:	55                   	push   %ebp
  8012ac:	56                   	push   %esi
  8012ad:	57                   	push   %edi
  8012ae:	54                   	push   %esp
  8012af:	5d                   	pop    %ebp
  8012b0:	8d 35 b8 12 80 00    	lea    0x8012b8,%esi
  8012b6:	0f 34                	sysenter 
  8012b8:	5f                   	pop    %edi
  8012b9:	5e                   	pop    %esi
  8012ba:	5d                   	pop    %ebp
  8012bb:	5c                   	pop    %esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5a                   	pop    %edx
  8012be:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	7e 28                	jle    8012eb <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8012ce:	00 
  8012cf:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8012d6:	00 
  8012d7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012de:	00 
  8012df:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  8012e6:	e8 69 ee ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012eb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012f1:	89 ec                	mov    %ebp,%esp
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	83 ec 28             	sub    $0x28,%esp
  8012fb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012fe:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801301:	8b 7d 18             	mov    0x18(%ebp),%edi
  801304:	0b 7d 14             	or     0x14(%ebp),%edi
  801307:	b8 06 00 00 00       	mov    $0x6,%eax
  80130c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80130f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801312:	8b 55 08             	mov    0x8(%ebp),%edx
  801315:	51                   	push   %ecx
  801316:	52                   	push   %edx
  801317:	53                   	push   %ebx
  801318:	54                   	push   %esp
  801319:	55                   	push   %ebp
  80131a:	56                   	push   %esi
  80131b:	57                   	push   %edi
  80131c:	54                   	push   %esp
  80131d:	5d                   	pop    %ebp
  80131e:	8d 35 26 13 80 00    	lea    0x801326,%esi
  801324:	0f 34                	sysenter 
  801326:	5f                   	pop    %edi
  801327:	5e                   	pop    %esi
  801328:	5d                   	pop    %ebp
  801329:	5c                   	pop    %esp
  80132a:	5b                   	pop    %ebx
  80132b:	5a                   	pop    %edx
  80132c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80132d:	85 c0                	test   %eax,%eax
  80132f:	7e 28                	jle    801359 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801331:	89 44 24 10          	mov    %eax,0x10(%esp)
  801335:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80133c:	00 
  80133d:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  801344:	00 
  801345:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80134c:	00 
  80134d:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  801354:	e8 fb ed ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801359:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80135c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80135f:	89 ec                	mov    %ebp,%esp
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	83 ec 28             	sub    $0x28,%esp
  801369:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80136c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80136f:	bf 00 00 00 00       	mov    $0x0,%edi
  801374:	b8 05 00 00 00       	mov    $0x5,%eax
  801379:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137f:	8b 55 08             	mov    0x8(%ebp),%edx
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80139a:	85 c0                	test   %eax,%eax
  80139c:	7e 28                	jle    8013c6 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80139e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013a9:	00 
  8013aa:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8013b1:	00 
  8013b2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013b9:	00 
  8013ba:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  8013c1:	e8 8e ed ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8013c6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013cc:	89 ec                	mov    %ebp,%esp
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
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
  8013dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013e7:	89 d1                	mov    %edx,%ecx
  8013e9:	89 d3                	mov    %edx,%ebx
  8013eb:	89 d7                	mov    %edx,%edi
  8013ed:	51                   	push   %ecx
  8013ee:	52                   	push   %edx
  8013ef:	53                   	push   %ebx
  8013f0:	54                   	push   %esp
  8013f1:	55                   	push   %ebp
  8013f2:	56                   	push   %esi
  8013f3:	57                   	push   %edi
  8013f4:	54                   	push   %esp
  8013f5:	5d                   	pop    %ebp
  8013f6:	8d 35 fe 13 80 00    	lea    0x8013fe,%esi
  8013fc:	0f 34                	sysenter 
  8013fe:	5f                   	pop    %edi
  8013ff:	5e                   	pop    %esi
  801400:	5d                   	pop    %ebp
  801401:	5c                   	pop    %esp
  801402:	5b                   	pop    %ebx
  801403:	5a                   	pop    %edx
  801404:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801405:	8b 1c 24             	mov    (%esp),%ebx
  801408:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80140c:	89 ec                	mov    %ebp,%esp
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	89 1c 24             	mov    %ebx,(%esp)
  801419:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80141d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801422:	b8 04 00 00 00       	mov    $0x4,%eax
  801427:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142a:	8b 55 08             	mov    0x8(%ebp),%edx
  80142d:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801447:	8b 1c 24             	mov    (%esp),%ebx
  80144a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80144e:	89 ec                	mov    %ebp,%esp
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	89 1c 24             	mov    %ebx,(%esp)
  80145b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80145f:	ba 00 00 00 00       	mov    $0x0,%edx
  801464:	b8 02 00 00 00       	mov    $0x2,%eax
  801469:	89 d1                	mov    %edx,%ecx
  80146b:	89 d3                	mov    %edx,%ebx
  80146d:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801487:	8b 1c 24             	mov    (%esp),%ebx
  80148a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80148e:	89 ec                	mov    %ebp,%esp
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 28             	sub    $0x28,%esp
  801498:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80149b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80149e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8014a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ab:	89 cb                	mov    %ecx,%ebx
  8014ad:	89 cf                	mov    %ecx,%edi
  8014af:	51                   	push   %ecx
  8014b0:	52                   	push   %edx
  8014b1:	53                   	push   %ebx
  8014b2:	54                   	push   %esp
  8014b3:	55                   	push   %ebp
  8014b4:	56                   	push   %esi
  8014b5:	57                   	push   %edi
  8014b6:	54                   	push   %esp
  8014b7:	5d                   	pop    %ebp
  8014b8:	8d 35 c0 14 80 00    	lea    0x8014c0,%esi
  8014be:	0f 34                	sysenter 
  8014c0:	5f                   	pop    %edi
  8014c1:	5e                   	pop    %esi
  8014c2:	5d                   	pop    %ebp
  8014c3:	5c                   	pop    %esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5a                   	pop    %edx
  8014c6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	7e 28                	jle    8014f3 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014cf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014d6:	00 
  8014d7:	c7 44 24 08 20 26 80 	movl   $0x802620,0x8(%esp)
  8014de:	00 
  8014df:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014e6:	00 
  8014e7:	c7 04 24 3d 26 80 00 	movl   $0x80263d,(%esp)
  8014ee:	e8 61 ec ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014f3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014f6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014f9:	89 ec                	mov    %ebp,%esp
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    
  8014fd:	00 00                	add    %al,(%eax)
	...

00801500 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801506:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  80150d:	75 30                	jne    80153f <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80150f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801516:	00 
  801517:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80151e:	ee 
  80151f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801526:	e8 38 fe ff ff       	call   801363 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80152b:	c7 44 24 04 4c 15 80 	movl   $0x80154c,0x4(%esp)
  801532:	00 
  801533:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153a:	e8 06 fc ff ff       	call   801145 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80153f:	8b 45 08             	mov    0x8(%ebp),%eax
  801542:	a3 08 40 80 00       	mov    %eax,0x804008
}
  801547:	c9                   	leave  
  801548:	c3                   	ret    
  801549:	00 00                	add    %al,(%eax)
	...

0080154c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80154c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80154d:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801552:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801554:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  801557:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  80155b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  80155f:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  801562:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  801564:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  801568:	83 c4 08             	add    $0x8,%esp
        popal
  80156b:	61                   	popa   
        addl $0x4,%esp
  80156c:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  80156f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801570:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801571:	c3                   	ret    
	...

00801580 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	8b 45 08             	mov    0x8(%ebp),%eax
  801586:	05 00 00 00 30       	add    $0x30000000,%eax
  80158b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801596:	8b 45 08             	mov    0x8(%ebp),%eax
  801599:	89 04 24             	mov    %eax,(%esp)
  80159c:	e8 df ff ff ff       	call   801580 <fd2num>
  8015a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8015a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	57                   	push   %edi
  8015af:	56                   	push   %esi
  8015b0:	53                   	push   %ebx
  8015b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8015b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8015b9:	a8 01                	test   $0x1,%al
  8015bb:	74 36                	je     8015f3 <fd_alloc+0x48>
  8015bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8015c2:	a8 01                	test   $0x1,%al
  8015c4:	74 2d                	je     8015f3 <fd_alloc+0x48>
  8015c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8015cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	c1 ea 16             	shr    $0x16,%edx
  8015dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8015df:	f6 c2 01             	test   $0x1,%dl
  8015e2:	74 14                	je     8015f8 <fd_alloc+0x4d>
  8015e4:	89 c2                	mov    %eax,%edx
  8015e6:	c1 ea 0c             	shr    $0xc,%edx
  8015e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8015ec:	f6 c2 01             	test   $0x1,%dl
  8015ef:	75 10                	jne    801601 <fd_alloc+0x56>
  8015f1:	eb 05                	jmp    8015f8 <fd_alloc+0x4d>
  8015f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8015f8:	89 1f                	mov    %ebx,(%edi)
  8015fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015ff:	eb 17                	jmp    801618 <fd_alloc+0x6d>
  801601:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801606:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80160b:	75 c8                	jne    8015d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80160d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801613:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5f                   	pop    %edi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	83 f8 1f             	cmp    $0x1f,%eax
  801626:	77 36                	ja     80165e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801628:	05 00 00 0d 00       	add    $0xd0000,%eax
  80162d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801630:	89 c2                	mov    %eax,%edx
  801632:	c1 ea 16             	shr    $0x16,%edx
  801635:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80163c:	f6 c2 01             	test   $0x1,%dl
  80163f:	74 1d                	je     80165e <fd_lookup+0x41>
  801641:	89 c2                	mov    %eax,%edx
  801643:	c1 ea 0c             	shr    $0xc,%edx
  801646:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80164d:	f6 c2 01             	test   $0x1,%dl
  801650:	74 0c                	je     80165e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801652:	8b 55 0c             	mov    0xc(%ebp),%edx
  801655:	89 02                	mov    %eax,(%edx)
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80165c:	eb 05                	jmp    801663 <fd_lookup+0x46>
  80165e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80166e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801672:	8b 45 08             	mov    0x8(%ebp),%eax
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	e8 a0 ff ff ff       	call   80161d <fd_lookup>
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 0e                	js     80168f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801681:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801684:	8b 55 0c             	mov    0xc(%ebp),%edx
  801687:	89 50 04             	mov    %edx,0x4(%eax)
  80168a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 10             	sub    $0x10,%esp
  801699:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80169f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016a9:	be cc 26 80 00       	mov    $0x8026cc,%esi
		if (devtab[i]->dev_id == dev_id) {
  8016ae:	39 08                	cmp    %ecx,(%eax)
  8016b0:	75 10                	jne    8016c2 <dev_lookup+0x31>
  8016b2:	eb 04                	jmp    8016b8 <dev_lookup+0x27>
  8016b4:	39 08                	cmp    %ecx,(%eax)
  8016b6:	75 0a                	jne    8016c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8016b8:	89 03                	mov    %eax,(%ebx)
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016bf:	90                   	nop
  8016c0:	eb 31                	jmp    8016f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016c2:	83 c2 01             	add    $0x1,%edx
  8016c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	75 e8                	jne    8016b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d1:	8b 40 48             	mov    0x48(%eax),%eax
  8016d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dc:	c7 04 24 4c 26 80 00 	movl   $0x80264c,(%esp)
  8016e3:	e8 25 eb ff ff       	call   80020d <cprintf>
	*dev = 0;
  8016e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	5b                   	pop    %ebx
  8016f7:	5e                   	pop    %esi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 24             	sub    $0x24,%esp
  801701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	e8 07 ff ff ff       	call   80161d <fd_lookup>
  801716:	85 c0                	test   %eax,%eax
  801718:	78 53                	js     80176d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801724:	8b 00                	mov    (%eax),%eax
  801726:	89 04 24             	mov    %eax,(%esp)
  801729:	e8 63 ff ff ff       	call   801691 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 3b                	js     80176d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801732:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801737:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80173e:	74 2d                	je     80176d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801740:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801743:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174a:	00 00 00 
	stat->st_isdir = 0;
  80174d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801754:	00 00 00 
	stat->st_dev = dev;
  801757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801764:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801767:	89 14 24             	mov    %edx,(%esp)
  80176a:	ff 50 14             	call   *0x14(%eax)
}
  80176d:	83 c4 24             	add    $0x24,%esp
  801770:	5b                   	pop    %ebx
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 24             	sub    $0x24,%esp
  80177a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801780:	89 44 24 04          	mov    %eax,0x4(%esp)
  801784:	89 1c 24             	mov    %ebx,(%esp)
  801787:	e8 91 fe ff ff       	call   80161d <fd_lookup>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 5f                	js     8017ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801793:	89 44 24 04          	mov    %eax,0x4(%esp)
  801797:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179a:	8b 00                	mov    (%eax),%eax
  80179c:	89 04 24             	mov    %eax,(%esp)
  80179f:	e8 ed fe ff ff       	call   801691 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 47                	js     8017ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017ab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017af:	75 23                	jne    8017d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017b1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b6:	8b 40 48             	mov    0x48(%eax),%eax
  8017b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c1:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  8017c8:	e8 40 ea ff ff       	call   80020d <cprintf>
  8017cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d2:	eb 1b                	jmp    8017ef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8017d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d7:	8b 48 18             	mov    0x18(%eax),%ecx
  8017da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017df:	85 c9                	test   %ecx,%ecx
  8017e1:	74 0c                	je     8017ef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ea:	89 14 24             	mov    %edx,(%esp)
  8017ed:	ff d1                	call   *%ecx
}
  8017ef:	83 c4 24             	add    $0x24,%esp
  8017f2:	5b                   	pop    %ebx
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 24             	sub    $0x24,%esp
  8017fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801802:	89 44 24 04          	mov    %eax,0x4(%esp)
  801806:	89 1c 24             	mov    %ebx,(%esp)
  801809:	e8 0f fe ff ff       	call   80161d <fd_lookup>
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 66                	js     801878 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801815:	89 44 24 04          	mov    %eax,0x4(%esp)
  801819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181c:	8b 00                	mov    (%eax),%eax
  80181e:	89 04 24             	mov    %eax,(%esp)
  801821:	e8 6b fe ff ff       	call   801691 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801826:	85 c0                	test   %eax,%eax
  801828:	78 4e                	js     801878 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80182a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80182d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801831:	75 23                	jne    801856 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801833:	a1 04 40 80 00       	mov    0x804004,%eax
  801838:	8b 40 48             	mov    0x48(%eax),%eax
  80183b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80183f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801843:	c7 04 24 90 26 80 00 	movl   $0x802690,(%esp)
  80184a:	e8 be e9 ff ff       	call   80020d <cprintf>
  80184f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801854:	eb 22                	jmp    801878 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801856:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801859:	8b 48 0c             	mov    0xc(%eax),%ecx
  80185c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801861:	85 c9                	test   %ecx,%ecx
  801863:	74 13                	je     801878 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801865:	8b 45 10             	mov    0x10(%ebp),%eax
  801868:	89 44 24 08          	mov    %eax,0x8(%esp)
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801873:	89 14 24             	mov    %edx,(%esp)
  801876:	ff d1                	call   *%ecx
}
  801878:	83 c4 24             	add    $0x24,%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 24             	sub    $0x24,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188f:	89 1c 24             	mov    %ebx,(%esp)
  801892:	e8 86 fd ff ff       	call   80161d <fd_lookup>
  801897:	85 c0                	test   %eax,%eax
  801899:	78 6b                	js     801906 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a5:	8b 00                	mov    (%eax),%eax
  8018a7:	89 04 24             	mov    %eax,(%esp)
  8018aa:	e8 e2 fd ff ff       	call   801691 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 53                	js     801906 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018b6:	8b 42 08             	mov    0x8(%edx),%eax
  8018b9:	83 e0 03             	and    $0x3,%eax
  8018bc:	83 f8 01             	cmp    $0x1,%eax
  8018bf:	75 23                	jne    8018e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c6:	8b 40 48             	mov    0x48(%eax),%eax
  8018c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d1:	c7 04 24 ad 26 80 00 	movl   $0x8026ad,(%esp)
  8018d8:	e8 30 e9 ff ff       	call   80020d <cprintf>
  8018dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018e2:	eb 22                	jmp    801906 <read+0x88>
	}
	if (!dev->dev_read)
  8018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e7:	8b 48 08             	mov    0x8(%eax),%ecx
  8018ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018ef:	85 c9                	test   %ecx,%ecx
  8018f1:	74 13                	je     801906 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801901:	89 14 24             	mov    %edx,(%esp)
  801904:	ff d1                	call   *%ecx
}
  801906:	83 c4 24             	add    $0x24,%esp
  801909:	5b                   	pop    %ebx
  80190a:	5d                   	pop    %ebp
  80190b:	c3                   	ret    

0080190c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	57                   	push   %edi
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	83 ec 1c             	sub    $0x1c,%esp
  801915:	8b 7d 08             	mov    0x8(%ebp),%edi
  801918:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80191b:	ba 00 00 00 00       	mov    $0x0,%edx
  801920:	bb 00 00 00 00       	mov    $0x0,%ebx
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
  80192a:	85 f6                	test   %esi,%esi
  80192c:	74 29                	je     801957 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80192e:	89 f0                	mov    %esi,%eax
  801930:	29 d0                	sub    %edx,%eax
  801932:	89 44 24 08          	mov    %eax,0x8(%esp)
  801936:	03 55 0c             	add    0xc(%ebp),%edx
  801939:	89 54 24 04          	mov    %edx,0x4(%esp)
  80193d:	89 3c 24             	mov    %edi,(%esp)
  801940:	e8 39 ff ff ff       	call   80187e <read>
		if (m < 0)
  801945:	85 c0                	test   %eax,%eax
  801947:	78 0e                	js     801957 <readn+0x4b>
			return m;
		if (m == 0)
  801949:	85 c0                	test   %eax,%eax
  80194b:	74 08                	je     801955 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80194d:	01 c3                	add    %eax,%ebx
  80194f:	89 da                	mov    %ebx,%edx
  801951:	39 f3                	cmp    %esi,%ebx
  801953:	72 d9                	jb     80192e <readn+0x22>
  801955:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801957:	83 c4 1c             	add    $0x1c,%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5f                   	pop    %edi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    

0080195f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	83 ec 20             	sub    $0x20,%esp
  801967:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80196a:	89 34 24             	mov    %esi,(%esp)
  80196d:	e8 0e fc ff ff       	call   801580 <fd2num>
  801972:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801975:	89 54 24 04          	mov    %edx,0x4(%esp)
  801979:	89 04 24             	mov    %eax,(%esp)
  80197c:	e8 9c fc ff ff       	call   80161d <fd_lookup>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	85 c0                	test   %eax,%eax
  801985:	78 05                	js     80198c <fd_close+0x2d>
  801987:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80198a:	74 0c                	je     801998 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80198c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801990:	19 c0                	sbb    %eax,%eax
  801992:	f7 d0                	not    %eax
  801994:	21 c3                	and    %eax,%ebx
  801996:	eb 3d                	jmp    8019d5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801998:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199f:	8b 06                	mov    (%esi),%eax
  8019a1:	89 04 24             	mov    %eax,(%esp)
  8019a4:	e8 e8 fc ff ff       	call   801691 <dev_lookup>
  8019a9:	89 c3                	mov    %eax,%ebx
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 16                	js     8019c5 <fd_close+0x66>
		if (dev->dev_close)
  8019af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b2:	8b 40 10             	mov    0x10(%eax),%eax
  8019b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	74 07                	je     8019c5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8019be:	89 34 24             	mov    %esi,(%esp)
  8019c1:	ff d0                	call   *%eax
  8019c3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d0:	e8 b4 f8 ff ff       	call   801289 <sys_page_unmap>
	return r;
}
  8019d5:	89 d8                	mov    %ebx,%eax
  8019d7:	83 c4 20             	add    $0x20,%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	e8 27 fc ff ff       	call   80161d <fd_lookup>
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 13                	js     801a0d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a01:	00 
  801a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a05:	89 04 24             	mov    %eax,(%esp)
  801a08:	e8 52 ff ff ff       	call   80195f <fd_close>
}
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 18             	sub    $0x18,%esp
  801a15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a22:	00 
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 79 03 00 00       	call   801da7 <open>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 1b                	js     801a4f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3b:	89 1c 24             	mov    %ebx,(%esp)
  801a3e:	e8 b7 fc ff ff       	call   8016fa <fstat>
  801a43:	89 c6                	mov    %eax,%esi
	close(fd);
  801a45:	89 1c 24             	mov    %ebx,(%esp)
  801a48:	e8 91 ff ff ff       	call   8019de <close>
  801a4d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a4f:	89 d8                	mov    %ebx,%eax
  801a51:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a54:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a57:	89 ec                	mov    %ebp,%esp
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 14             	sub    $0x14,%esp
  801a62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a67:	89 1c 24             	mov    %ebx,(%esp)
  801a6a:	e8 6f ff ff ff       	call   8019de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a6f:	83 c3 01             	add    $0x1,%ebx
  801a72:	83 fb 20             	cmp    $0x20,%ebx
  801a75:	75 f0                	jne    801a67 <close_all+0xc>
		close(i);
}
  801a77:	83 c4 14             	add    $0x14,%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5d                   	pop    %ebp
  801a7c:	c3                   	ret    

00801a7d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 58             	sub    $0x58,%esp
  801a83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	89 04 24             	mov    %eax,(%esp)
  801a9c:	e8 7c fb ff ff       	call   80161d <fd_lookup>
  801aa1:	89 c3                	mov    %eax,%ebx
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	0f 88 e0 00 00 00    	js     801b8b <dup+0x10e>
		return r;
	close(newfdnum);
  801aab:	89 3c 24             	mov    %edi,(%esp)
  801aae:	e8 2b ff ff ff       	call   8019de <close>

	newfd = INDEX2FD(newfdnum);
  801ab3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801ab9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801abc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801abf:	89 04 24             	mov    %eax,(%esp)
  801ac2:	e8 c9 fa ff ff       	call   801590 <fd2data>
  801ac7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ac9:	89 34 24             	mov    %esi,(%esp)
  801acc:	e8 bf fa ff ff       	call   801590 <fd2data>
  801ad1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	89 d8                	mov    %ebx,%eax
  801ad8:	c1 e8 16             	shr    $0x16,%eax
  801adb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ae2:	a8 01                	test   $0x1,%al
  801ae4:	74 43                	je     801b29 <dup+0xac>
  801ae6:	c1 ea 0c             	shr    $0xc,%edx
  801ae9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801af0:	a8 01                	test   $0x1,%al
  801af2:	74 35                	je     801b29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801af4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801afb:	25 07 0e 00 00       	and    $0xe07,%eax
  801b00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b12:	00 
  801b13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1e:	e8 d2 f7 ff ff       	call   8012f5 <sys_page_map>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 3f                	js     801b68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2c:	89 c2                	mov    %eax,%edx
  801b2e:	c1 ea 0c             	shr    $0xc,%edx
  801b31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b4d:	00 
  801b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b59:	e8 97 f7 ff ff       	call   8012f5 <sys_page_map>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 04                	js     801b68 <dup+0xeb>
  801b64:	89 fb                	mov    %edi,%ebx
  801b66:	eb 23                	jmp    801b8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b73:	e8 11 f7 ff ff       	call   801289 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b86:	e8 fe f6 ff ff       	call   801289 <sys_page_unmap>
	return r;
}
  801b8b:	89 d8                	mov    %ebx,%eax
  801b8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b96:	89 ec                	mov    %ebp,%esp
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    
	...

00801b9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 18             	sub    $0x18,%esp
  801ba2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ba5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801bac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801bb3:	75 11                	jne    801bc6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801bbc:	e8 8f 02 00 00       	call   801e50 <ipc_find_env>
  801bc1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bcd:	00 
  801bce:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801bd5:	00 
  801bd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bda:	a1 00 40 80 00       	mov    0x804000,%eax
  801bdf:	89 04 24             	mov    %eax,(%esp)
  801be2:	e8 b4 02 00 00       	call   801e9b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801be7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bee:	00 
  801bef:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bf3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfa:	e8 1a 03 00 00       	call   801f19 <ipc_recv>
}
  801bff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c05:	89 ec                	mov    %ebp,%esp
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	8b 40 0c             	mov    0xc(%eax),%eax
  801c15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c22:	ba 00 00 00 00       	mov    $0x0,%edx
  801c27:	b8 02 00 00 00       	mov    $0x2,%eax
  801c2c:	e8 6b ff ff ff       	call   801b9c <fsipc>
}
  801c31:	c9                   	leave  
  801c32:	c3                   	ret    

00801c33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c39:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c44:	ba 00 00 00 00       	mov    $0x0,%edx
  801c49:	b8 06 00 00 00       	mov    $0x6,%eax
  801c4e:	e8 49 ff ff ff       	call   801b9c <fsipc>
}
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    

00801c55 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c60:	b8 08 00 00 00       	mov    $0x8,%eax
  801c65:	e8 32 ff ff ff       	call   801b9c <fsipc>
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	53                   	push   %ebx
  801c70:	83 ec 14             	sub    $0x14,%esp
  801c73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c76:	8b 45 08             	mov    0x8(%ebp),%eax
  801c79:	8b 40 0c             	mov    0xc(%eax),%eax
  801c7c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c81:	ba 00 00 00 00       	mov    $0x0,%edx
  801c86:	b8 05 00 00 00       	mov    $0x5,%eax
  801c8b:	e8 0c ff ff ff       	call   801b9c <fsipc>
  801c90:	85 c0                	test   %eax,%eax
  801c92:	78 2b                	js     801cbf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c94:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c9b:	00 
  801c9c:	89 1c 24             	mov    %ebx,(%esp)
  801c9f:	e8 96 ee ff ff       	call   800b3a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ca4:	a1 80 50 80 00       	mov    0x805080,%eax
  801ca9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801caf:	a1 84 50 80 00       	mov    0x805084,%eax
  801cb4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801cbf:	83 c4 14             	add    $0x14,%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 18             	sub    $0x18,%esp
  801ccb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801cd3:	76 05                	jbe    801cda <devfile_write+0x15>
  801cd5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cda:	8b 55 08             	mov    0x8(%ebp),%edx
  801cdd:	8b 52 0c             	mov    0xc(%edx),%edx
  801ce0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801ce6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801cfd:	e8 23 f0 ff ff       	call   800d25 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
  801d07:	b8 04 00 00 00       	mov    $0x4,%eax
  801d0c:	e8 8b fe ff ff       	call   801b9c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d20:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801d25:	8b 45 10             	mov    0x10(%ebp),%eax
  801d28:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801d2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d32:	b8 03 00 00 00       	mov    $0x3,%eax
  801d37:	e8 60 fe ff ff       	call   801b9c <fsipc>
  801d3c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 17                	js     801d59 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801d42:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d46:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d4d:	00 
  801d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d51:	89 04 24             	mov    %eax,(%esp)
  801d54:	e8 cc ef ff ff       	call   800d25 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801d59:	89 d8                	mov    %ebx,%eax
  801d5b:	83 c4 14             	add    $0x14,%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	53                   	push   %ebx
  801d65:	83 ec 14             	sub    $0x14,%esp
  801d68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d6b:	89 1c 24             	mov    %ebx,(%esp)
  801d6e:	e8 7d ed ff ff       	call   800af0 <strlen>
  801d73:	89 c2                	mov    %eax,%edx
  801d75:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d7a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d80:	7f 1f                	jg     801da1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d86:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d8d:	e8 a8 ed ff ff       	call   800b3a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d92:	ba 00 00 00 00       	mov    $0x0,%edx
  801d97:	b8 07 00 00 00       	mov    $0x7,%eax
  801d9c:	e8 fb fd ff ff       	call   801b9c <fsipc>
}
  801da1:	83 c4 14             	add    $0x14,%esp
  801da4:	5b                   	pop    %ebx
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 28             	sub    $0x28,%esp
  801dad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801db0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801db3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801db6:	89 34 24             	mov    %esi,(%esp)
  801db9:	e8 32 ed ff ff       	call   800af0 <strlen>
  801dbe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801dc3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dc8:	7f 6d                	jg     801e37 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801dca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcd:	89 04 24             	mov    %eax,(%esp)
  801dd0:	e8 d6 f7 ff ff       	call   8015ab <fd_alloc>
  801dd5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 5c                	js     801e37 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dde:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801de3:	89 34 24             	mov    %esi,(%esp)
  801de6:	e8 05 ed ff ff       	call   800af0 <strlen>
  801deb:	83 c0 01             	add    $0x1,%eax
  801dee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801dfd:	e8 23 ef ff ff       	call   800d25 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801e02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e05:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0a:	e8 8d fd ff ff       	call   801b9c <fsipc>
  801e0f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801e11:	85 c0                	test   %eax,%eax
  801e13:	79 15                	jns    801e2a <open+0x83>
             fd_close(fd,0);
  801e15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e1c:	00 
  801e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e20:	89 04 24             	mov    %eax,(%esp)
  801e23:	e8 37 fb ff ff       	call   80195f <fd_close>
             return r;
  801e28:	eb 0d                	jmp    801e37 <open+0x90>
        }
        return fd2num(fd);
  801e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2d:	89 04 24             	mov    %eax,(%esp)
  801e30:	e8 4b f7 ff ff       	call   801580 <fd2num>
  801e35:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801e37:	89 d8                	mov    %ebx,%eax
  801e39:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e3c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e3f:	89 ec                	mov    %ebp,%esp
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    
	...

00801e50 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e56:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801e5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e61:	39 ca                	cmp    %ecx,%edx
  801e63:	75 04                	jne    801e69 <ipc_find_env+0x19>
  801e65:	b0 00                	mov    $0x0,%al
  801e67:	eb 12                	jmp    801e7b <ipc_find_env+0x2b>
  801e69:	89 c2                	mov    %eax,%edx
  801e6b:	c1 e2 07             	shl    $0x7,%edx
  801e6e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801e75:	8b 12                	mov    (%edx),%edx
  801e77:	39 ca                	cmp    %ecx,%edx
  801e79:	75 10                	jne    801e8b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801e7b:	89 c2                	mov    %eax,%edx
  801e7d:	c1 e2 07             	shl    $0x7,%edx
  801e80:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801e87:	8b 00                	mov    (%eax),%eax
  801e89:	eb 0e                	jmp    801e99 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e8b:	83 c0 01             	add    $0x1,%eax
  801e8e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e93:	75 d4                	jne    801e69 <ipc_find_env+0x19>
  801e95:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	57                   	push   %edi
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 1c             	sub    $0x1c,%esp
  801ea4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801eaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801ead:	85 db                	test   %ebx,%ebx
  801eaf:	74 19                	je     801eca <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801eb1:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ebc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ec0:	89 34 24             	mov    %esi,(%esp)
  801ec3:	e8 3c f2 ff ff       	call   801104 <sys_ipc_try_send>
  801ec8:	eb 1b                	jmp    801ee5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801eca:	8b 45 14             	mov    0x14(%ebp),%eax
  801ecd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ed1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801ed8:	ee 
  801ed9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801edd:	89 34 24             	mov    %esi,(%esp)
  801ee0:	e8 1f f2 ff ff       	call   801104 <sys_ipc_try_send>
           if(ret == 0)
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	74 28                	je     801f11 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801ee9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eec:	74 1c                	je     801f0a <ipc_send+0x6f>
              panic("ipc send error");
  801eee:	c7 44 24 08 d4 26 80 	movl   $0x8026d4,0x8(%esp)
  801ef5:	00 
  801ef6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801efd:	00 
  801efe:	c7 04 24 e3 26 80 00 	movl   $0x8026e3,(%esp)
  801f05:	e8 4a e2 ff ff       	call   800154 <_panic>
           sys_yield();
  801f0a:	e8 c1 f4 ff ff       	call   8013d0 <sys_yield>
        }
  801f0f:	eb 9c                	jmp    801ead <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801f11:	83 c4 1c             	add    $0x1c,%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5f                   	pop    %edi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	56                   	push   %esi
  801f1d:	53                   	push   %ebx
  801f1e:	83 ec 10             	sub    $0x10,%esp
  801f21:	8b 75 08             	mov    0x8(%ebp),%esi
  801f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	75 0e                	jne    801f3c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801f2e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801f35:	e8 5f f1 ff ff       	call   801099 <sys_ipc_recv>
  801f3a:	eb 08                	jmp    801f44 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801f3c:	89 04 24             	mov    %eax,(%esp)
  801f3f:	e8 55 f1 ff ff       	call   801099 <sys_ipc_recv>
        if(ret == 0){
  801f44:	85 c0                	test   %eax,%eax
  801f46:	75 26                	jne    801f6e <ipc_recv+0x55>
           if(from_env_store)
  801f48:	85 f6                	test   %esi,%esi
  801f4a:	74 0a                	je     801f56 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801f4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801f51:	8b 40 78             	mov    0x78(%eax),%eax
  801f54:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801f56:	85 db                	test   %ebx,%ebx
  801f58:	74 0a                	je     801f64 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801f5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f5f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f62:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801f64:	a1 04 40 80 00       	mov    0x804004,%eax
  801f69:	8b 40 74             	mov    0x74(%eax),%eax
  801f6c:	eb 14                	jmp    801f82 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801f6e:	85 f6                	test   %esi,%esi
  801f70:	74 06                	je     801f78 <ipc_recv+0x5f>
              *from_env_store = 0;
  801f72:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801f78:	85 db                	test   %ebx,%ebx
  801f7a:	74 06                	je     801f82 <ipc_recv+0x69>
              *perm_store = 0;
  801f7c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    
  801f89:	00 00                	add    %al,(%eax)
  801f8b:	00 00                	add    %al,(%eax)
  801f8d:	00 00                	add    %al,(%eax)
	...

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	57                   	push   %edi
  801f94:	56                   	push   %esi
  801f95:	83 ec 10             	sub    $0x10,%esp
  801f98:	8b 45 14             	mov    0x14(%ebp),%eax
  801f9b:	8b 55 08             	mov    0x8(%ebp),%edx
  801f9e:	8b 75 10             	mov    0x10(%ebp),%esi
  801fa1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801fa9:	75 35                	jne    801fe0 <__udivdi3+0x50>
  801fab:	39 fe                	cmp    %edi,%esi
  801fad:	77 61                	ja     802010 <__udivdi3+0x80>
  801faf:	85 f6                	test   %esi,%esi
  801fb1:	75 0b                	jne    801fbe <__udivdi3+0x2e>
  801fb3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb8:	31 d2                	xor    %edx,%edx
  801fba:	f7 f6                	div    %esi
  801fbc:	89 c6                	mov    %eax,%esi
  801fbe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801fc1:	31 d2                	xor    %edx,%edx
  801fc3:	89 f8                	mov    %edi,%eax
  801fc5:	f7 f6                	div    %esi
  801fc7:	89 c7                	mov    %eax,%edi
  801fc9:	89 c8                	mov    %ecx,%eax
  801fcb:	f7 f6                	div    %esi
  801fcd:	89 c1                	mov    %eax,%ecx
  801fcf:	89 fa                	mov    %edi,%edx
  801fd1:	89 c8                	mov    %ecx,%eax
  801fd3:	83 c4 10             	add    $0x10,%esp
  801fd6:	5e                   	pop    %esi
  801fd7:	5f                   	pop    %edi
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    
  801fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fe0:	39 f8                	cmp    %edi,%eax
  801fe2:	77 1c                	ja     802000 <__udivdi3+0x70>
  801fe4:	0f bd d0             	bsr    %eax,%edx
  801fe7:	83 f2 1f             	xor    $0x1f,%edx
  801fea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801fed:	75 39                	jne    802028 <__udivdi3+0x98>
  801fef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ff2:	0f 86 a0 00 00 00    	jbe    802098 <__udivdi3+0x108>
  801ff8:	39 f8                	cmp    %edi,%eax
  801ffa:	0f 82 98 00 00 00    	jb     802098 <__udivdi3+0x108>
  802000:	31 ff                	xor    %edi,%edi
  802002:	31 c9                	xor    %ecx,%ecx
  802004:	89 c8                	mov    %ecx,%eax
  802006:	89 fa                	mov    %edi,%edx
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    
  80200f:	90                   	nop
  802010:	89 d1                	mov    %edx,%ecx
  802012:	89 fa                	mov    %edi,%edx
  802014:	89 c8                	mov    %ecx,%eax
  802016:	31 ff                	xor    %edi,%edi
  802018:	f7 f6                	div    %esi
  80201a:	89 c1                	mov    %eax,%ecx
  80201c:	89 fa                	mov    %edi,%edx
  80201e:	89 c8                	mov    %ecx,%eax
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	5e                   	pop    %esi
  802024:	5f                   	pop    %edi
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    
  802027:	90                   	nop
  802028:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80202c:	89 f2                	mov    %esi,%edx
  80202e:	d3 e0                	shl    %cl,%eax
  802030:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802033:	b8 20 00 00 00       	mov    $0x20,%eax
  802038:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80203b:	89 c1                	mov    %eax,%ecx
  80203d:	d3 ea                	shr    %cl,%edx
  80203f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802043:	0b 55 ec             	or     -0x14(%ebp),%edx
  802046:	d3 e6                	shl    %cl,%esi
  802048:	89 c1                	mov    %eax,%ecx
  80204a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80204d:	89 fe                	mov    %edi,%esi
  80204f:	d3 ee                	shr    %cl,%esi
  802051:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802055:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802058:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80205b:	d3 e7                	shl    %cl,%edi
  80205d:	89 c1                	mov    %eax,%ecx
  80205f:	d3 ea                	shr    %cl,%edx
  802061:	09 d7                	or     %edx,%edi
  802063:	89 f2                	mov    %esi,%edx
  802065:	89 f8                	mov    %edi,%eax
  802067:	f7 75 ec             	divl   -0x14(%ebp)
  80206a:	89 d6                	mov    %edx,%esi
  80206c:	89 c7                	mov    %eax,%edi
  80206e:	f7 65 e8             	mull   -0x18(%ebp)
  802071:	39 d6                	cmp    %edx,%esi
  802073:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802076:	72 30                	jb     8020a8 <__udivdi3+0x118>
  802078:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80207b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80207f:	d3 e2                	shl    %cl,%edx
  802081:	39 c2                	cmp    %eax,%edx
  802083:	73 05                	jae    80208a <__udivdi3+0xfa>
  802085:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802088:	74 1e                	je     8020a8 <__udivdi3+0x118>
  80208a:	89 f9                	mov    %edi,%ecx
  80208c:	31 ff                	xor    %edi,%edi
  80208e:	e9 71 ff ff ff       	jmp    802004 <__udivdi3+0x74>
  802093:	90                   	nop
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80209f:	e9 60 ff ff ff       	jmp    802004 <__udivdi3+0x74>
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8020ab:	31 ff                	xor    %edi,%edi
  8020ad:	89 c8                	mov    %ecx,%eax
  8020af:	89 fa                	mov    %edi,%edx
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
	...

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	57                   	push   %edi
  8020c4:	56                   	push   %esi
  8020c5:	83 ec 20             	sub    $0x20,%esp
  8020c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8020cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8020d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020d4:	85 d2                	test   %edx,%edx
  8020d6:	89 c8                	mov    %ecx,%eax
  8020d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020db:	75 13                	jne    8020f0 <__umoddi3+0x30>
  8020dd:	39 f7                	cmp    %esi,%edi
  8020df:	76 3f                	jbe    802120 <__umoddi3+0x60>
  8020e1:	89 f2                	mov    %esi,%edx
  8020e3:	f7 f7                	div    %edi
  8020e5:	89 d0                	mov    %edx,%eax
  8020e7:	31 d2                	xor    %edx,%edx
  8020e9:	83 c4 20             	add    $0x20,%esp
  8020ec:	5e                   	pop    %esi
  8020ed:	5f                   	pop    %edi
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    
  8020f0:	39 f2                	cmp    %esi,%edx
  8020f2:	77 4c                	ja     802140 <__umoddi3+0x80>
  8020f4:	0f bd ca             	bsr    %edx,%ecx
  8020f7:	83 f1 1f             	xor    $0x1f,%ecx
  8020fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020fd:	75 51                	jne    802150 <__umoddi3+0x90>
  8020ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802102:	0f 87 e0 00 00 00    	ja     8021e8 <__umoddi3+0x128>
  802108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210b:	29 f8                	sub    %edi,%eax
  80210d:	19 d6                	sbb    %edx,%esi
  80210f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802115:	89 f2                	mov    %esi,%edx
  802117:	83 c4 20             	add    $0x20,%esp
  80211a:	5e                   	pop    %esi
  80211b:	5f                   	pop    %edi
  80211c:	5d                   	pop    %ebp
  80211d:	c3                   	ret    
  80211e:	66 90                	xchg   %ax,%ax
  802120:	85 ff                	test   %edi,%edi
  802122:	75 0b                	jne    80212f <__umoddi3+0x6f>
  802124:	b8 01 00 00 00       	mov    $0x1,%eax
  802129:	31 d2                	xor    %edx,%edx
  80212b:	f7 f7                	div    %edi
  80212d:	89 c7                	mov    %eax,%edi
  80212f:	89 f0                	mov    %esi,%eax
  802131:	31 d2                	xor    %edx,%edx
  802133:	f7 f7                	div    %edi
  802135:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802138:	f7 f7                	div    %edi
  80213a:	eb a9                	jmp    8020e5 <__umoddi3+0x25>
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 20             	add    $0x20,%esp
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    
  80214b:	90                   	nop
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802154:	d3 e2                	shl    %cl,%edx
  802156:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802159:	ba 20 00 00 00       	mov    $0x20,%edx
  80215e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802161:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802164:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802168:	89 fa                	mov    %edi,%edx
  80216a:	d3 ea                	shr    %cl,%edx
  80216c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802170:	0b 55 f4             	or     -0xc(%ebp),%edx
  802173:	d3 e7                	shl    %cl,%edi
  802175:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802179:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80217c:	89 f2                	mov    %esi,%edx
  80217e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802181:	89 c7                	mov    %eax,%edi
  802183:	d3 ea                	shr    %cl,%edx
  802185:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802189:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80218c:	89 c2                	mov    %eax,%edx
  80218e:	d3 e6                	shl    %cl,%esi
  802190:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802194:	d3 ea                	shr    %cl,%edx
  802196:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80219a:	09 d6                	or     %edx,%esi
  80219c:	89 f0                	mov    %esi,%eax
  80219e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8021a1:	d3 e7                	shl    %cl,%edi
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	f7 75 f4             	divl   -0xc(%ebp)
  8021a8:	89 d6                	mov    %edx,%esi
  8021aa:	f7 65 e8             	mull   -0x18(%ebp)
  8021ad:	39 d6                	cmp    %edx,%esi
  8021af:	72 2b                	jb     8021dc <__umoddi3+0x11c>
  8021b1:	39 c7                	cmp    %eax,%edi
  8021b3:	72 23                	jb     8021d8 <__umoddi3+0x118>
  8021b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021b9:	29 c7                	sub    %eax,%edi
  8021bb:	19 d6                	sbb    %edx,%esi
  8021bd:	89 f0                	mov    %esi,%eax
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	d3 ef                	shr    %cl,%edi
  8021c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021cd:	09 f8                	or     %edi,%eax
  8021cf:	d3 ea                	shr    %cl,%edx
  8021d1:	83 c4 20             	add    $0x20,%esp
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	39 d6                	cmp    %edx,%esi
  8021da:	75 d9                	jne    8021b5 <__umoddi3+0xf5>
  8021dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8021df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8021e2:	eb d1                	jmp    8021b5 <__umoddi3+0xf5>
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	0f 82 18 ff ff ff    	jb     802108 <__umoddi3+0x48>
  8021f0:	e9 1d ff ff ff       	jmp    802112 <__umoddi3+0x52>
