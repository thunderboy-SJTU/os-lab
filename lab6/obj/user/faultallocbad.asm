
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
  800041:	e8 be 15 00 00       	call   801604 <set_pgfault_handler>
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
  80006c:	c7 04 24 60 28 80 00 	movl   $0x802860,(%esp)
  800073:	e8 95 01 00 00       	call   80020d <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800078:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80007f:	00 
  800080:	89 d8                	mov    %ebx,%eax
  800082:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800092:	e8 d1 13 00 00       	call   801468 <sys_page_alloc>
  800097:	85 c0                	test   %eax,%eax
  800099:	79 24                	jns    8000bf <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a3:	c7 44 24 08 80 28 80 	movl   $0x802880,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 6a 28 80 00 	movl   $0x80286a,(%esp)
  8000ba:	e8 95 00 00 00       	call   800154 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000c3:	c7 44 24 08 ac 28 80 	movl   $0x8028ac,0x8(%esp)
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
  8000f6:	e8 5c 14 00 00       	call   801557 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	89 c2                	mov    %eax,%edx
  800102:	c1 e2 07             	shl    $0x7,%edx
  800105:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80010c:	a3 08 40 80 00       	mov    %eax,0x804008
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
  80013e:	e8 18 1a 00 00       	call   801b5b <close_all>
	sys_env_destroy(0);
  800143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014a:	e8 48 14 00 00       	call   801597 <sys_env_destroy>
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
  800165:	e8 ed 13 00 00       	call   801557 <sys_getenvid>
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 d8 28 80 00 	movl   $0x8028d8,(%esp)
  800187:	e8 81 00 00 00       	call   80020d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 11 00 00 00       	call   8001ac <vcprintf>
	cprintf("\n");
  80019b:	c7 04 24 27 2d 80 00 	movl   $0x802d27,(%esp)
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
  8002df:	e8 fc 22 00 00       	call   8025e0 <__udivdi3>
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
  800347:	e8 c4 23 00 00       	call   802710 <__umoddi3>
  80034c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800350:	0f be 80 fb 28 80 00 	movsbl 0x8028fb(%eax),%eax
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
  80043a:	ff 24 95 e0 2a 80 00 	jmp    *0x802ae0(,%edx,4)
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
  8004f7:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  8004fe:	85 d2                	test   %edx,%edx
  800500:	75 26                	jne    800528 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800502:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800506:	c7 44 24 08 0c 29 80 	movl   $0x80290c,0x8(%esp)
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
  80052c:	c7 44 24 08 62 2d 80 	movl   $0x802d62,0x8(%esp)
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
  80056a:	be 15 29 80 00       	mov    $0x802915,%esi
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
  800814:	e8 c7 1d 00 00       	call   8025e0 <__udivdi3>
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
  800860:	e8 ab 1e 00 00       	call   802710 <__umoddi3>
  800865:	89 74 24 04          	mov    %esi,0x4(%esp)
  800869:	0f be 80 fb 28 80 00 	movsbl 0x8028fb(%eax),%eax
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
  800915:	c7 44 24 0c 30 2a 80 	movl   $0x802a30,0xc(%esp)
  80091c:	00 
  80091d:	c7 44 24 08 62 2d 80 	movl   $0x802d62,0x8(%esp)
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
  80094b:	c7 44 24 0c 68 2a 80 	movl   $0x802a68,0xc(%esp)
  800952:	00 
  800953:	c7 44 24 08 62 2d 80 	movl   $0x802d62,0x8(%esp)
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
  8009df:	e8 2c 1d 00 00       	call   802710 <__umoddi3>
  8009e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e8:	0f be 80 fb 28 80 00 	movsbl 0x8028fb(%eax),%eax
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
  800a21:	e8 ea 1c 00 00       	call   802710 <__umoddi3>
  800a26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2a:	0f be 80 fb 28 80 00 	movsbl 0x8028fb(%eax),%eax
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

00800fab <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  800fb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbd:	b8 13 00 00 00       	mov    $0x13,%eax
  800fc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc5:	89 cb                	mov    %ecx,%ebx
  800fc7:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800fe1:	8b 1c 24             	mov    (%esp),%ebx
  800fe4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe8:	89 ec                	mov    %ebp,%esp
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 08             	sub    $0x8,%esp
  800ff2:	89 1c 24             	mov    %ebx,(%esp)
  800ff5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffe:	b8 12 00 00 00       	mov    $0x12,%eax
  801003:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801006:	8b 55 08             	mov    0x8(%ebp),%edx
  801009:	89 df                	mov    %ebx,%edi
  80100b:	51                   	push   %ecx
  80100c:	52                   	push   %edx
  80100d:	53                   	push   %ebx
  80100e:	54                   	push   %esp
  80100f:	55                   	push   %ebp
  801010:	56                   	push   %esi
  801011:	57                   	push   %edi
  801012:	54                   	push   %esp
  801013:	5d                   	pop    %ebp
  801014:	8d 35 1c 10 80 00    	lea    0x80101c,%esi
  80101a:	0f 34                	sysenter 
  80101c:	5f                   	pop    %edi
  80101d:	5e                   	pop    %esi
  80101e:	5d                   	pop    %ebp
  80101f:	5c                   	pop    %esp
  801020:	5b                   	pop    %ebx
  801021:	5a                   	pop    %edx
  801022:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801023:	8b 1c 24             	mov    (%esp),%ebx
  801026:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80102a:	89 ec                	mov    %ebp,%esp
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	89 1c 24             	mov    %ebx,(%esp)
  801037:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80103b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801040:	b8 11 00 00 00       	mov    $0x11,%eax
  801045:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801048:	8b 55 08             	mov    0x8(%ebp),%edx
  80104b:	89 df                	mov    %ebx,%edi
  80104d:	51                   	push   %ecx
  80104e:	52                   	push   %edx
  80104f:	53                   	push   %ebx
  801050:	54                   	push   %esp
  801051:	55                   	push   %ebp
  801052:	56                   	push   %esi
  801053:	57                   	push   %edi
  801054:	54                   	push   %esp
  801055:	5d                   	pop    %ebp
  801056:	8d 35 5e 10 80 00    	lea    0x80105e,%esi
  80105c:	0f 34                	sysenter 
  80105e:	5f                   	pop    %edi
  80105f:	5e                   	pop    %esi
  801060:	5d                   	pop    %ebp
  801061:	5c                   	pop    %esp
  801062:	5b                   	pop    %ebx
  801063:	5a                   	pop    %edx
  801064:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801065:	8b 1c 24             	mov    (%esp),%ebx
  801068:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80106c:	89 ec                	mov    %ebp,%esp
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 08             	sub    $0x8,%esp
  801076:	89 1c 24             	mov    %ebx,(%esp)
  801079:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80107d:	b8 10 00 00 00       	mov    $0x10,%eax
  801082:	8b 7d 14             	mov    0x14(%ebp),%edi
  801085:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	51                   	push   %ecx
  80108f:	52                   	push   %edx
  801090:	53                   	push   %ebx
  801091:	54                   	push   %esp
  801092:	55                   	push   %ebp
  801093:	56                   	push   %esi
  801094:	57                   	push   %edi
  801095:	54                   	push   %esp
  801096:	5d                   	pop    %ebp
  801097:	8d 35 9f 10 80 00    	lea    0x80109f,%esi
  80109d:	0f 34                	sysenter 
  80109f:	5f                   	pop    %edi
  8010a0:	5e                   	pop    %esi
  8010a1:	5d                   	pop    %ebp
  8010a2:	5c                   	pop    %esp
  8010a3:	5b                   	pop    %ebx
  8010a4:	5a                   	pop    %edx
  8010a5:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  8010a6:	8b 1c 24             	mov    (%esp),%ebx
  8010a9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010ad:	89 ec                	mov    %ebp,%esp
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	83 ec 28             	sub    $0x28,%esp
  8010b7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010ba:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cd:	89 df                	mov    %ebx,%edi
  8010cf:	51                   	push   %ecx
  8010d0:	52                   	push   %edx
  8010d1:	53                   	push   %ebx
  8010d2:	54                   	push   %esp
  8010d3:	55                   	push   %ebp
  8010d4:	56                   	push   %esi
  8010d5:	57                   	push   %edi
  8010d6:	54                   	push   %esp
  8010d7:	5d                   	pop    %ebp
  8010d8:	8d 35 e0 10 80 00    	lea    0x8010e0,%esi
  8010de:	0f 34                	sysenter 
  8010e0:	5f                   	pop    %edi
  8010e1:	5e                   	pop    %esi
  8010e2:	5d                   	pop    %ebp
  8010e3:	5c                   	pop    %esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5a                   	pop    %edx
  8010e6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	7e 28                	jle    801113 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ef:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8010f6:	00 
  8010f7:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  8010fe:	00 
  8010ff:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801106:	00 
  801107:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  80110e:	e8 41 f0 ff ff       	call   800154 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801113:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801116:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801119:	89 ec                	mov    %ebp,%esp
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 08             	sub    $0x8,%esp
  801123:	89 1c 24             	mov    %ebx,(%esp)
  801126:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80112a:	ba 00 00 00 00       	mov    $0x0,%edx
  80112f:	b8 15 00 00 00       	mov    $0x15,%eax
  801134:	89 d1                	mov    %edx,%ecx
  801136:	89 d3                	mov    %edx,%ebx
  801138:	89 d7                	mov    %edx,%edi
  80113a:	51                   	push   %ecx
  80113b:	52                   	push   %edx
  80113c:	53                   	push   %ebx
  80113d:	54                   	push   %esp
  80113e:	55                   	push   %ebp
  80113f:	56                   	push   %esi
  801140:	57                   	push   %edi
  801141:	54                   	push   %esp
  801142:	5d                   	pop    %ebp
  801143:	8d 35 4b 11 80 00    	lea    0x80114b,%esi
  801149:	0f 34                	sysenter 
  80114b:	5f                   	pop    %edi
  80114c:	5e                   	pop    %esi
  80114d:	5d                   	pop    %ebp
  80114e:	5c                   	pop    %esp
  80114f:	5b                   	pop    %ebx
  801150:	5a                   	pop    %edx
  801151:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801152:	8b 1c 24             	mov    (%esp),%ebx
  801155:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801159:	89 ec                	mov    %ebp,%esp
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	83 ec 08             	sub    $0x8,%esp
  801163:	89 1c 24             	mov    %ebx,(%esp)
  801166:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80116a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80116f:	b8 14 00 00 00       	mov    $0x14,%eax
  801174:	8b 55 08             	mov    0x8(%ebp),%edx
  801177:	89 cb                	mov    %ecx,%ebx
  801179:	89 cf                	mov    %ecx,%edi
  80117b:	51                   	push   %ecx
  80117c:	52                   	push   %edx
  80117d:	53                   	push   %ebx
  80117e:	54                   	push   %esp
  80117f:	55                   	push   %ebp
  801180:	56                   	push   %esi
  801181:	57                   	push   %edi
  801182:	54                   	push   %esp
  801183:	5d                   	pop    %ebp
  801184:	8d 35 8c 11 80 00    	lea    0x80118c,%esi
  80118a:	0f 34                	sysenter 
  80118c:	5f                   	pop    %edi
  80118d:	5e                   	pop    %esi
  80118e:	5d                   	pop    %ebp
  80118f:	5c                   	pop    %esp
  801190:	5b                   	pop    %ebx
  801191:	5a                   	pop    %edx
  801192:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801193:	8b 1c 24             	mov    (%esp),%ebx
  801196:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80119a:	89 ec                	mov    %ebp,%esp
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	83 ec 28             	sub    $0x28,%esp
  8011a4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011a7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011af:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b7:	89 cb                	mov    %ecx,%ebx
  8011b9:	89 cf                	mov    %ecx,%edi
  8011bb:	51                   	push   %ecx
  8011bc:	52                   	push   %edx
  8011bd:	53                   	push   %ebx
  8011be:	54                   	push   %esp
  8011bf:	55                   	push   %ebp
  8011c0:	56                   	push   %esi
  8011c1:	57                   	push   %edi
  8011c2:	54                   	push   %esp
  8011c3:	5d                   	pop    %ebp
  8011c4:	8d 35 cc 11 80 00    	lea    0x8011cc,%esi
  8011ca:	0f 34                	sysenter 
  8011cc:	5f                   	pop    %edi
  8011cd:	5e                   	pop    %esi
  8011ce:	5d                   	pop    %ebp
  8011cf:	5c                   	pop    %esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5a                   	pop    %edx
  8011d2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	7e 28                	jle    8011ff <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011db:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011f2:	00 
  8011f3:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  8011fa:	e8 55 ef ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801202:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801205:	89 ec                	mov    %ebp,%esp
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	89 1c 24             	mov    %ebx,(%esp)
  801212:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801216:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80121e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801224:	8b 55 08             	mov    0x8(%ebp),%edx
  801227:	51                   	push   %ecx
  801228:	52                   	push   %edx
  801229:	53                   	push   %ebx
  80122a:	54                   	push   %esp
  80122b:	55                   	push   %ebp
  80122c:	56                   	push   %esi
  80122d:	57                   	push   %edi
  80122e:	54                   	push   %esp
  80122f:	5d                   	pop    %ebp
  801230:	8d 35 38 12 80 00    	lea    0x801238,%esi
  801236:	0f 34                	sysenter 
  801238:	5f                   	pop    %edi
  801239:	5e                   	pop    %esi
  80123a:	5d                   	pop    %ebp
  80123b:	5c                   	pop    %esp
  80123c:	5b                   	pop    %ebx
  80123d:	5a                   	pop    %edx
  80123e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80123f:	8b 1c 24             	mov    (%esp),%ebx
  801242:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801246:	89 ec                	mov    %ebp,%esp
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 28             	sub    $0x28,%esp
  801250:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801253:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801263:	8b 55 08             	mov    0x8(%ebp),%edx
  801266:	89 df                	mov    %ebx,%edi
  801268:	51                   	push   %ecx
  801269:	52                   	push   %edx
  80126a:	53                   	push   %ebx
  80126b:	54                   	push   %esp
  80126c:	55                   	push   %ebp
  80126d:	56                   	push   %esi
  80126e:	57                   	push   %edi
  80126f:	54                   	push   %esp
  801270:	5d                   	pop    %ebp
  801271:	8d 35 79 12 80 00    	lea    0x801279,%esi
  801277:	0f 34                	sysenter 
  801279:	5f                   	pop    %edi
  80127a:	5e                   	pop    %esi
  80127b:	5d                   	pop    %ebp
  80127c:	5c                   	pop    %esp
  80127d:	5b                   	pop    %ebx
  80127e:	5a                   	pop    %edx
  80127f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801280:	85 c0                	test   %eax,%eax
  801282:	7e 28                	jle    8012ac <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801284:	89 44 24 10          	mov    %eax,0x10(%esp)
  801288:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80128f:	00 
  801290:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  801297:	00 
  801298:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80129f:	00 
  8012a0:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  8012a7:	e8 a8 ee ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012ac:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012af:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012b2:	89 ec                	mov    %ebp,%esp
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	83 ec 28             	sub    $0x28,%esp
  8012bc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012bf:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d2:	89 df                	mov    %ebx,%edi
  8012d4:	51                   	push   %ecx
  8012d5:	52                   	push   %edx
  8012d6:	53                   	push   %ebx
  8012d7:	54                   	push   %esp
  8012d8:	55                   	push   %ebp
  8012d9:	56                   	push   %esi
  8012da:	57                   	push   %edi
  8012db:	54                   	push   %esp
  8012dc:	5d                   	pop    %ebp
  8012dd:	8d 35 e5 12 80 00    	lea    0x8012e5,%esi
  8012e3:	0f 34                	sysenter 
  8012e5:	5f                   	pop    %edi
  8012e6:	5e                   	pop    %esi
  8012e7:	5d                   	pop    %ebp
  8012e8:	5c                   	pop    %esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5a                   	pop    %edx
  8012eb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	7e 28                	jle    801318 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  801303:	00 
  801304:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80130b:	00 
  80130c:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  801313:	e8 3c ee ff ff       	call   800154 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801318:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80131b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80131e:	89 ec                	mov    %ebp,%esp
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	83 ec 28             	sub    $0x28,%esp
  801328:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80132b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80132e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801333:	b8 09 00 00 00       	mov    $0x9,%eax
  801338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133b:	8b 55 08             	mov    0x8(%ebp),%edx
  80133e:	89 df                	mov    %ebx,%edi
  801340:	51                   	push   %ecx
  801341:	52                   	push   %edx
  801342:	53                   	push   %ebx
  801343:	54                   	push   %esp
  801344:	55                   	push   %ebp
  801345:	56                   	push   %esi
  801346:	57                   	push   %edi
  801347:	54                   	push   %esp
  801348:	5d                   	pop    %ebp
  801349:	8d 35 51 13 80 00    	lea    0x801351,%esi
  80134f:	0f 34                	sysenter 
  801351:	5f                   	pop    %edi
  801352:	5e                   	pop    %esi
  801353:	5d                   	pop    %ebp
  801354:	5c                   	pop    %esp
  801355:	5b                   	pop    %ebx
  801356:	5a                   	pop    %edx
  801357:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801358:	85 c0                	test   %eax,%eax
  80135a:	7e 28                	jle    801384 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801360:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801367:	00 
  801368:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  80136f:	00 
  801370:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801377:	00 
  801378:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  80137f:	e8 d0 ed ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801384:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801387:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80138a:	89 ec                	mov    %ebp,%esp
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	83 ec 28             	sub    $0x28,%esp
  801394:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801397:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80139a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80139f:	b8 07 00 00 00       	mov    $0x7,%eax
  8013a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013aa:	89 df                	mov    %ebx,%edi
  8013ac:	51                   	push   %ecx
  8013ad:	52                   	push   %edx
  8013ae:	53                   	push   %ebx
  8013af:	54                   	push   %esp
  8013b0:	55                   	push   %ebp
  8013b1:	56                   	push   %esi
  8013b2:	57                   	push   %edi
  8013b3:	54                   	push   %esp
  8013b4:	5d                   	pop    %ebp
  8013b5:	8d 35 bd 13 80 00    	lea    0x8013bd,%esi
  8013bb:	0f 34                	sysenter 
  8013bd:	5f                   	pop    %edi
  8013be:	5e                   	pop    %esi
  8013bf:	5d                   	pop    %ebp
  8013c0:	5c                   	pop    %esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5a                   	pop    %edx
  8013c3:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	7e 28                	jle    8013f0 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013cc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013d3:	00 
  8013d4:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  8013db:	00 
  8013dc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013e3:	00 
  8013e4:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  8013eb:	e8 64 ed ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013f0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013f3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013f6:	89 ec                	mov    %ebp,%esp
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    

008013fa <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 28             	sub    $0x28,%esp
  801400:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801403:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801406:	8b 7d 18             	mov    0x18(%ebp),%edi
  801409:	0b 7d 14             	or     0x14(%ebp),%edi
  80140c:	b8 06 00 00 00       	mov    $0x6,%eax
  801411:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801414:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801417:	8b 55 08             	mov    0x8(%ebp),%edx
  80141a:	51                   	push   %ecx
  80141b:	52                   	push   %edx
  80141c:	53                   	push   %ebx
  80141d:	54                   	push   %esp
  80141e:	55                   	push   %ebp
  80141f:	56                   	push   %esi
  801420:	57                   	push   %edi
  801421:	54                   	push   %esp
  801422:	5d                   	pop    %ebp
  801423:	8d 35 2b 14 80 00    	lea    0x80142b,%esi
  801429:	0f 34                	sysenter 
  80142b:	5f                   	pop    %edi
  80142c:	5e                   	pop    %esi
  80142d:	5d                   	pop    %ebp
  80142e:	5c                   	pop    %esp
  80142f:	5b                   	pop    %ebx
  801430:	5a                   	pop    %edx
  801431:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801432:	85 c0                	test   %eax,%eax
  801434:	7e 28                	jle    80145e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801436:	89 44 24 10          	mov    %eax,0x10(%esp)
  80143a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801441:	00 
  801442:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  801449:	00 
  80144a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801451:	00 
  801452:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  801459:	e8 f6 ec ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80145e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801461:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801464:	89 ec                	mov    %ebp,%esp
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 28             	sub    $0x28,%esp
  80146e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801471:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801474:	bf 00 00 00 00       	mov    $0x0,%edi
  801479:	b8 05 00 00 00       	mov    $0x5,%eax
  80147e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801481:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801484:	8b 55 08             	mov    0x8(%ebp),%edx
  801487:	51                   	push   %ecx
  801488:	52                   	push   %edx
  801489:	53                   	push   %ebx
  80148a:	54                   	push   %esp
  80148b:	55                   	push   %ebp
  80148c:	56                   	push   %esi
  80148d:	57                   	push   %edi
  80148e:	54                   	push   %esp
  80148f:	5d                   	pop    %ebp
  801490:	8d 35 98 14 80 00    	lea    0x801498,%esi
  801496:	0f 34                	sysenter 
  801498:	5f                   	pop    %edi
  801499:	5e                   	pop    %esi
  80149a:	5d                   	pop    %ebp
  80149b:	5c                   	pop    %esp
  80149c:	5b                   	pop    %ebx
  80149d:	5a                   	pop    %edx
  80149e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	7e 28                	jle    8014cb <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8014ae:	00 
  8014af:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  8014b6:	00 
  8014b7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014be:	00 
  8014bf:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  8014c6:	e8 89 ec ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8014cb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014d1:	89 ec                	mov    %ebp,%esp
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    

008014d5 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	89 1c 24             	mov    %ebx,(%esp)
  8014de:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014ec:	89 d1                	mov    %edx,%ecx
  8014ee:	89 d3                	mov    %edx,%ebx
  8014f0:	89 d7                	mov    %edx,%edi
  8014f2:	51                   	push   %ecx
  8014f3:	52                   	push   %edx
  8014f4:	53                   	push   %ebx
  8014f5:	54                   	push   %esp
  8014f6:	55                   	push   %ebp
  8014f7:	56                   	push   %esi
  8014f8:	57                   	push   %edi
  8014f9:	54                   	push   %esp
  8014fa:	5d                   	pop    %ebp
  8014fb:	8d 35 03 15 80 00    	lea    0x801503,%esi
  801501:	0f 34                	sysenter 
  801503:	5f                   	pop    %edi
  801504:	5e                   	pop    %esi
  801505:	5d                   	pop    %ebp
  801506:	5c                   	pop    %esp
  801507:	5b                   	pop    %ebx
  801508:	5a                   	pop    %edx
  801509:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80150a:	8b 1c 24             	mov    (%esp),%ebx
  80150d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801511:	89 ec                	mov    %ebp,%esp
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	89 1c 24             	mov    %ebx,(%esp)
  80151e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801522:	bb 00 00 00 00       	mov    $0x0,%ebx
  801527:	b8 04 00 00 00       	mov    $0x4,%eax
  80152c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80152f:	8b 55 08             	mov    0x8(%ebp),%edx
  801532:	89 df                	mov    %ebx,%edi
  801534:	51                   	push   %ecx
  801535:	52                   	push   %edx
  801536:	53                   	push   %ebx
  801537:	54                   	push   %esp
  801538:	55                   	push   %ebp
  801539:	56                   	push   %esi
  80153a:	57                   	push   %edi
  80153b:	54                   	push   %esp
  80153c:	5d                   	pop    %ebp
  80153d:	8d 35 45 15 80 00    	lea    0x801545,%esi
  801543:	0f 34                	sysenter 
  801545:	5f                   	pop    %edi
  801546:	5e                   	pop    %esi
  801547:	5d                   	pop    %ebp
  801548:	5c                   	pop    %esp
  801549:	5b                   	pop    %ebx
  80154a:	5a                   	pop    %edx
  80154b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80154c:	8b 1c 24             	mov    (%esp),%ebx
  80154f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801553:	89 ec                	mov    %ebp,%esp
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	89 1c 24             	mov    %ebx,(%esp)
  801560:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
  801569:	b8 02 00 00 00       	mov    $0x2,%eax
  80156e:	89 d1                	mov    %edx,%ecx
  801570:	89 d3                	mov    %edx,%ebx
  801572:	89 d7                	mov    %edx,%edi
  801574:	51                   	push   %ecx
  801575:	52                   	push   %edx
  801576:	53                   	push   %ebx
  801577:	54                   	push   %esp
  801578:	55                   	push   %ebp
  801579:	56                   	push   %esi
  80157a:	57                   	push   %edi
  80157b:	54                   	push   %esp
  80157c:	5d                   	pop    %ebp
  80157d:	8d 35 85 15 80 00    	lea    0x801585,%esi
  801583:	0f 34                	sysenter 
  801585:	5f                   	pop    %edi
  801586:	5e                   	pop    %esi
  801587:	5d                   	pop    %ebp
  801588:	5c                   	pop    %esp
  801589:	5b                   	pop    %ebx
  80158a:	5a                   	pop    %edx
  80158b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80158c:	8b 1c 24             	mov    (%esp),%ebx
  80158f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801593:	89 ec                	mov    %ebp,%esp
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 28             	sub    $0x28,%esp
  80159d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015a0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b0:	89 cb                	mov    %ecx,%ebx
  8015b2:	89 cf                	mov    %ecx,%edi
  8015b4:	51                   	push   %ecx
  8015b5:	52                   	push   %edx
  8015b6:	53                   	push   %ebx
  8015b7:	54                   	push   %esp
  8015b8:	55                   	push   %ebp
  8015b9:	56                   	push   %esi
  8015ba:	57                   	push   %edi
  8015bb:	54                   	push   %esp
  8015bc:	5d                   	pop    %ebp
  8015bd:	8d 35 c5 15 80 00    	lea    0x8015c5,%esi
  8015c3:	0f 34                	sysenter 
  8015c5:	5f                   	pop    %edi
  8015c6:	5e                   	pop    %esi
  8015c7:	5d                   	pop    %ebp
  8015c8:	5c                   	pop    %esp
  8015c9:	5b                   	pop    %ebx
  8015ca:	5a                   	pop    %edx
  8015cb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	7e 28                	jle    8015f8 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d4:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8015db:	00 
  8015dc:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  8015e3:	00 
  8015e4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015eb:	00 
  8015ec:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  8015f3:	e8 5c eb ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015f8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015fb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015fe:	89 ec                	mov    %ebp,%esp
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    
	...

00801604 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80160a:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  801611:	75 30                	jne    801643 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801613:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80161a:	00 
  80161b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801622:	ee 
  801623:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80162a:	e8 39 fe ff ff       	call   801468 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80162f:	c7 44 24 04 50 16 80 	movl   $0x801650,0x4(%esp)
  801636:	00 
  801637:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163e:	e8 07 fc ff ff       	call   80124a <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    
  80164d:	00 00                	add    %al,(%eax)
	...

00801650 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801650:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801651:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  801656:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801658:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  80165b:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  80165f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  801663:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  801666:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  801668:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  80166c:	83 c4 08             	add    $0x8,%esp
        popal
  80166f:	61                   	popa   
        addl $0x4,%esp
  801670:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  801673:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801674:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801675:	c3                   	ret    
	...

00801680 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	05 00 00 00 30       	add    $0x30000000,%eax
  80168b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	89 04 24             	mov    %eax,(%esp)
  80169c:	e8 df ff ff ff       	call   801680 <fd2num>
  8016a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8016b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016b9:	a8 01                	test   $0x1,%al
  8016bb:	74 36                	je     8016f3 <fd_alloc+0x48>
  8016bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016c2:	a8 01                	test   $0x1,%al
  8016c4:	74 2d                	je     8016f3 <fd_alloc+0x48>
  8016c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8016cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016d5:	89 c3                	mov    %eax,%ebx
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	c1 ea 16             	shr    $0x16,%edx
  8016dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016df:	f6 c2 01             	test   $0x1,%dl
  8016e2:	74 14                	je     8016f8 <fd_alloc+0x4d>
  8016e4:	89 c2                	mov    %eax,%edx
  8016e6:	c1 ea 0c             	shr    $0xc,%edx
  8016e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016ec:	f6 c2 01             	test   $0x1,%dl
  8016ef:	75 10                	jne    801701 <fd_alloc+0x56>
  8016f1:	eb 05                	jmp    8016f8 <fd_alloc+0x4d>
  8016f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8016f8:	89 1f                	mov    %ebx,(%edi)
  8016fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016ff:	eb 17                	jmp    801718 <fd_alloc+0x6d>
  801701:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801706:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80170b:	75 c8                	jne    8016d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80170d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801713:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5f                   	pop    %edi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	83 f8 1f             	cmp    $0x1f,%eax
  801726:	77 36                	ja     80175e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801728:	05 00 00 0d 00       	add    $0xd0000,%eax
  80172d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801730:	89 c2                	mov    %eax,%edx
  801732:	c1 ea 16             	shr    $0x16,%edx
  801735:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80173c:	f6 c2 01             	test   $0x1,%dl
  80173f:	74 1d                	je     80175e <fd_lookup+0x41>
  801741:	89 c2                	mov    %eax,%edx
  801743:	c1 ea 0c             	shr    $0xc,%edx
  801746:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80174d:	f6 c2 01             	test   $0x1,%dl
  801750:	74 0c                	je     80175e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801752:	8b 55 0c             	mov    0xc(%ebp),%edx
  801755:	89 02                	mov    %eax,(%edx)
  801757:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80175c:	eb 05                	jmp    801763 <fd_lookup+0x46>
  80175e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80176b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80176e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	89 04 24             	mov    %eax,(%esp)
  801778:	e8 a0 ff ff ff       	call   80171d <fd_lookup>
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 0e                	js     80178f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801781:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801784:	8b 55 0c             	mov    0xc(%ebp),%edx
  801787:	89 50 04             	mov    %edx,0x4(%eax)
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80178f:	c9                   	leave  
  801790:	c3                   	ret    

00801791 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 10             	sub    $0x10,%esp
  801799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80179f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017a9:	be 2c 2d 80 00       	mov    $0x802d2c,%esi
		if (devtab[i]->dev_id == dev_id) {
  8017ae:	39 08                	cmp    %ecx,(%eax)
  8017b0:	75 10                	jne    8017c2 <dev_lookup+0x31>
  8017b2:	eb 04                	jmp    8017b8 <dev_lookup+0x27>
  8017b4:	39 08                	cmp    %ecx,(%eax)
  8017b6:	75 0a                	jne    8017c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8017b8:	89 03                	mov    %eax,(%ebx)
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017bf:	90                   	nop
  8017c0:	eb 31                	jmp    8017f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017c2:	83 c2 01             	add    $0x1,%edx
  8017c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	75 e8                	jne    8017b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8017d1:	8b 40 48             	mov    0x48(%eax),%eax
  8017d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dc:	c7 04 24 ac 2c 80 00 	movl   $0x802cac,(%esp)
  8017e3:	e8 25 ea ff ff       	call   80020d <cprintf>
	*dev = 0;
  8017e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	5b                   	pop    %ebx
  8017f7:	5e                   	pop    %esi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 24             	sub    $0x24,%esp
  801801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 07 ff ff ff       	call   80171d <fd_lookup>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 53                	js     80186d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801824:	8b 00                	mov    (%eax),%eax
  801826:	89 04 24             	mov    %eax,(%esp)
  801829:	e8 63 ff ff ff       	call   801791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 3b                	js     80186d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801832:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801837:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80183e:	74 2d                	je     80186d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801840:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801843:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80184a:	00 00 00 
	stat->st_isdir = 0;
  80184d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801854:	00 00 00 
	stat->st_dev = dev;
  801857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801860:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801864:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801867:	89 14 24             	mov    %edx,(%esp)
  80186a:	ff 50 14             	call   *0x14(%eax)
}
  80186d:	83 c4 24             	add    $0x24,%esp
  801870:	5b                   	pop    %ebx
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 24             	sub    $0x24,%esp
  80187a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801880:	89 44 24 04          	mov    %eax,0x4(%esp)
  801884:	89 1c 24             	mov    %ebx,(%esp)
  801887:	e8 91 fe ff ff       	call   80171d <fd_lookup>
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 5f                	js     8018ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801893:	89 44 24 04          	mov    %eax,0x4(%esp)
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	8b 00                	mov    (%eax),%eax
  80189c:	89 04 24             	mov    %eax,(%esp)
  80189f:	e8 ed fe ff ff       	call   801791 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 47                	js     8018ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018ab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018af:	75 23                	jne    8018d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018b1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018b6:	8b 40 48             	mov    0x48(%eax),%eax
  8018b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c1:	c7 04 24 cc 2c 80 00 	movl   $0x802ccc,(%esp)
  8018c8:	e8 40 e9 ff ff       	call   80020d <cprintf>
  8018cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d2:	eb 1b                	jmp    8018ef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d7:	8b 48 18             	mov    0x18(%eax),%ecx
  8018da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018df:	85 c9                	test   %ecx,%ecx
  8018e1:	74 0c                	je     8018ef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	89 14 24             	mov    %edx,(%esp)
  8018ed:	ff d1                	call   *%ecx
}
  8018ef:	83 c4 24             	add    $0x24,%esp
  8018f2:	5b                   	pop    %ebx
  8018f3:	5d                   	pop    %ebp
  8018f4:	c3                   	ret    

008018f5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 24             	sub    $0x24,%esp
  8018fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801902:	89 44 24 04          	mov    %eax,0x4(%esp)
  801906:	89 1c 24             	mov    %ebx,(%esp)
  801909:	e8 0f fe ff ff       	call   80171d <fd_lookup>
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 66                	js     801978 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801912:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801915:	89 44 24 04          	mov    %eax,0x4(%esp)
  801919:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191c:	8b 00                	mov    (%eax),%eax
  80191e:	89 04 24             	mov    %eax,(%esp)
  801921:	e8 6b fe ff ff       	call   801791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801926:	85 c0                	test   %eax,%eax
  801928:	78 4e                	js     801978 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80192a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80192d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801931:	75 23                	jne    801956 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801933:	a1 08 40 80 00       	mov    0x804008,%eax
  801938:	8b 40 48             	mov    0x48(%eax),%eax
  80193b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80193f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801943:	c7 04 24 f0 2c 80 00 	movl   $0x802cf0,(%esp)
  80194a:	e8 be e8 ff ff       	call   80020d <cprintf>
  80194f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801954:	eb 22                	jmp    801978 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801959:	8b 48 0c             	mov    0xc(%eax),%ecx
  80195c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801961:	85 c9                	test   %ecx,%ecx
  801963:	74 13                	je     801978 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801965:	8b 45 10             	mov    0x10(%ebp),%eax
  801968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801973:	89 14 24             	mov    %edx,(%esp)
  801976:	ff d1                	call   *%ecx
}
  801978:	83 c4 24             	add    $0x24,%esp
  80197b:	5b                   	pop    %ebx
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	53                   	push   %ebx
  801982:	83 ec 24             	sub    $0x24,%esp
  801985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	89 1c 24             	mov    %ebx,(%esp)
  801992:	e8 86 fd ff ff       	call   80171d <fd_lookup>
  801997:	85 c0                	test   %eax,%eax
  801999:	78 6b                	js     801a06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a5:	8b 00                	mov    (%eax),%eax
  8019a7:	89 04 24             	mov    %eax,(%esp)
  8019aa:	e8 e2 fd ff ff       	call   801791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	78 53                	js     801a06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019b6:	8b 42 08             	mov    0x8(%edx),%eax
  8019b9:	83 e0 03             	and    $0x3,%eax
  8019bc:	83 f8 01             	cmp    $0x1,%eax
  8019bf:	75 23                	jne    8019e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8019c6:	8b 40 48             	mov    0x48(%eax),%eax
  8019c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d1:	c7 04 24 0d 2d 80 00 	movl   $0x802d0d,(%esp)
  8019d8:	e8 30 e8 ff ff       	call   80020d <cprintf>
  8019dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019e2:	eb 22                	jmp    801a06 <read+0x88>
	}
	if (!dev->dev_read)
  8019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e7:	8b 48 08             	mov    0x8(%eax),%ecx
  8019ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019ef:	85 c9                	test   %ecx,%ecx
  8019f1:	74 13                	je     801a06 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a01:	89 14 24             	mov    %edx,(%esp)
  801a04:	ff d1                	call   *%ecx
}
  801a06:	83 c4 24             	add    $0x24,%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	57                   	push   %edi
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	83 ec 1c             	sub    $0x1c,%esp
  801a15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a18:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a25:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2a:	85 f6                	test   %esi,%esi
  801a2c:	74 29                	je     801a57 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a2e:	89 f0                	mov    %esi,%eax
  801a30:	29 d0                	sub    %edx,%eax
  801a32:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a36:	03 55 0c             	add    0xc(%ebp),%edx
  801a39:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a3d:	89 3c 24             	mov    %edi,(%esp)
  801a40:	e8 39 ff ff ff       	call   80197e <read>
		if (m < 0)
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 0e                	js     801a57 <readn+0x4b>
			return m;
		if (m == 0)
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	74 08                	je     801a55 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a4d:	01 c3                	add    %eax,%ebx
  801a4f:	89 da                	mov    %ebx,%edx
  801a51:	39 f3                	cmp    %esi,%ebx
  801a53:	72 d9                	jb     801a2e <readn+0x22>
  801a55:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a57:	83 c4 1c             	add    $0x1c,%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 20             	sub    $0x20,%esp
  801a67:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a6a:	89 34 24             	mov    %esi,(%esp)
  801a6d:	e8 0e fc ff ff       	call   801680 <fd2num>
  801a72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a75:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a79:	89 04 24             	mov    %eax,(%esp)
  801a7c:	e8 9c fc ff ff       	call   80171d <fd_lookup>
  801a81:	89 c3                	mov    %eax,%ebx
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 05                	js     801a8c <fd_close+0x2d>
  801a87:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a8a:	74 0c                	je     801a98 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a8c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801a90:	19 c0                	sbb    %eax,%eax
  801a92:	f7 d0                	not    %eax
  801a94:	21 c3                	and    %eax,%ebx
  801a96:	eb 3d                	jmp    801ad5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9f:	8b 06                	mov    (%esi),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 e8 fc ff ff       	call   801791 <dev_lookup>
  801aa9:	89 c3                	mov    %eax,%ebx
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 16                	js     801ac5 <fd_close+0x66>
		if (dev->dev_close)
  801aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab2:	8b 40 10             	mov    0x10(%eax),%eax
  801ab5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aba:	85 c0                	test   %eax,%eax
  801abc:	74 07                	je     801ac5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801abe:	89 34 24             	mov    %esi,(%esp)
  801ac1:	ff d0                	call   *%eax
  801ac3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ac5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad0:	e8 b9 f8 ff ff       	call   80138e <sys_page_unmap>
	return r;
}
  801ad5:	89 d8                	mov    %ebx,%eax
  801ad7:	83 c4 20             	add    $0x20,%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	89 04 24             	mov    %eax,(%esp)
  801af1:	e8 27 fc ff ff       	call   80171d <fd_lookup>
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 13                	js     801b0d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801afa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b01:	00 
  801b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b05:	89 04 24             	mov    %eax,(%esp)
  801b08:	e8 52 ff ff ff       	call   801a5f <fd_close>
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 18             	sub    $0x18,%esp
  801b15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b22:	00 
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	89 04 24             	mov    %eax,(%esp)
  801b29:	e8 79 03 00 00       	call   801ea7 <open>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 1b                	js     801b4f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3b:	89 1c 24             	mov    %ebx,(%esp)
  801b3e:	e8 b7 fc ff ff       	call   8017fa <fstat>
  801b43:	89 c6                	mov    %eax,%esi
	close(fd);
  801b45:	89 1c 24             	mov    %ebx,(%esp)
  801b48:	e8 91 ff ff ff       	call   801ade <close>
  801b4d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b4f:	89 d8                	mov    %ebx,%eax
  801b51:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b54:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b57:	89 ec                	mov    %ebp,%esp
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	53                   	push   %ebx
  801b5f:	83 ec 14             	sub    $0x14,%esp
  801b62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b67:	89 1c 24             	mov    %ebx,(%esp)
  801b6a:	e8 6f ff ff ff       	call   801ade <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b6f:	83 c3 01             	add    $0x1,%ebx
  801b72:	83 fb 20             	cmp    $0x20,%ebx
  801b75:	75 f0                	jne    801b67 <close_all+0xc>
		close(i);
}
  801b77:	83 c4 14             	add    $0x14,%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	83 ec 58             	sub    $0x58,%esp
  801b83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	89 04 24             	mov    %eax,(%esp)
  801b9c:	e8 7c fb ff ff       	call   80171d <fd_lookup>
  801ba1:	89 c3                	mov    %eax,%ebx
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 e0 00 00 00    	js     801c8b <dup+0x10e>
		return r;
	close(newfdnum);
  801bab:	89 3c 24             	mov    %edi,(%esp)
  801bae:	e8 2b ff ff ff       	call   801ade <close>

	newfd = INDEX2FD(newfdnum);
  801bb3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801bb9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bbf:	89 04 24             	mov    %eax,(%esp)
  801bc2:	e8 c9 fa ff ff       	call   801690 <fd2data>
  801bc7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bc9:	89 34 24             	mov    %esi,(%esp)
  801bcc:	e8 bf fa ff ff       	call   801690 <fd2data>
  801bd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801bd4:	89 da                	mov    %ebx,%edx
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	c1 e8 16             	shr    $0x16,%eax
  801bdb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801be2:	a8 01                	test   $0x1,%al
  801be4:	74 43                	je     801c29 <dup+0xac>
  801be6:	c1 ea 0c             	shr    $0xc,%edx
  801be9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bf0:	a8 01                	test   $0x1,%al
  801bf2:	74 35                	je     801c29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bf4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bfb:	25 07 0e 00 00       	and    $0xe07,%eax
  801c00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c12:	00 
  801c13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1e:	e8 d7 f7 ff ff       	call   8013fa <sys_page_map>
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	85 c0                	test   %eax,%eax
  801c27:	78 3f                	js     801c68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2c:	89 c2                	mov    %eax,%edx
  801c2e:	c1 ea 0c             	shr    $0xc,%edx
  801c31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c4d:	00 
  801c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c59:	e8 9c f7 ff ff       	call   8013fa <sys_page_map>
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 04                	js     801c68 <dup+0xeb>
  801c64:	89 fb                	mov    %edi,%ebx
  801c66:	eb 23                	jmp    801c8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c73:	e8 16 f7 ff ff       	call   80138e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c86:	e8 03 f7 ff ff       	call   80138e <sys_page_unmap>
	return r;
}
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c96:	89 ec                	mov    %ebp,%esp
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    
	...

00801c9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 18             	sub    $0x18,%esp
  801ca2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ca5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ca8:	89 c3                	mov    %eax,%ebx
  801caa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801cb3:	75 11                	jne    801cc6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801cbc:	e8 9f 07 00 00       	call   802460 <ipc_find_env>
  801cc1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ccd:	00 
  801cce:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cd5:	00 
  801cd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cda:	a1 00 40 80 00       	mov    0x804000,%eax
  801cdf:	89 04 24             	mov    %eax,(%esp)
  801ce2:	e8 c4 07 00 00       	call   8024ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ce7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cee:	00 
  801cef:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cf3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cfa:	e8 2a 08 00 00       	call   802529 <ipc_recv>
}
  801cff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d05:	89 ec                	mov    %ebp,%esp
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d12:	8b 40 0c             	mov    0xc(%eax),%eax
  801d15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d22:	ba 00 00 00 00       	mov    $0x0,%edx
  801d27:	b8 02 00 00 00       	mov    $0x2,%eax
  801d2c:	e8 6b ff ff ff       	call   801c9c <fsipc>
}
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d3f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d44:	ba 00 00 00 00       	mov    $0x0,%edx
  801d49:	b8 06 00 00 00       	mov    $0x6,%eax
  801d4e:	e8 49 ff ff ff       	call   801c9c <fsipc>
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d60:	b8 08 00 00 00       	mov    $0x8,%eax
  801d65:	e8 32 ff ff ff       	call   801c9c <fsipc>
}
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	53                   	push   %ebx
  801d70:	83 ec 14             	sub    $0x14,%esp
  801d73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	8b 40 0c             	mov    0xc(%eax),%eax
  801d7c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d81:	ba 00 00 00 00       	mov    $0x0,%edx
  801d86:	b8 05 00 00 00       	mov    $0x5,%eax
  801d8b:	e8 0c ff ff ff       	call   801c9c <fsipc>
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 2b                	js     801dbf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d94:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d9b:	00 
  801d9c:	89 1c 24             	mov    %ebx,(%esp)
  801d9f:	e8 96 ed ff ff       	call   800b3a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801da4:	a1 80 50 80 00       	mov    0x805080,%eax
  801da9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801daf:	a1 84 50 80 00       	mov    0x805084,%eax
  801db4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801dba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801dbf:	83 c4 14             	add    $0x14,%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 18             	sub    $0x18,%esp
  801dcb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801dd3:	76 05                	jbe    801dda <devfile_write+0x15>
  801dd5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dda:	8b 55 08             	mov    0x8(%ebp),%edx
  801ddd:	8b 52 0c             	mov    0xc(%edx),%edx
  801de0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801de6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801deb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801def:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801dfd:	e8 23 ef ff ff       	call   800d25 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801e02:	ba 00 00 00 00       	mov    $0x0,%edx
  801e07:	b8 04 00 00 00       	mov    $0x4,%eax
  801e0c:	e8 8b fe ff ff       	call   801c9c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	53                   	push   %ebx
  801e17:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e20:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801e25:	8b 45 10             	mov    0x10(%ebp),%eax
  801e28:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801e2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e32:	b8 03 00 00 00       	mov    $0x3,%eax
  801e37:	e8 60 fe ff ff       	call   801c9c <fsipc>
  801e3c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 17                	js     801e59 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801e42:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e46:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e4d:	00 
  801e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e51:	89 04 24             	mov    %eax,(%esp)
  801e54:	e8 cc ee ff ff       	call   800d25 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801e59:	89 d8                	mov    %ebx,%eax
  801e5b:	83 c4 14             	add    $0x14,%esp
  801e5e:	5b                   	pop    %ebx
  801e5f:	5d                   	pop    %ebp
  801e60:	c3                   	ret    

00801e61 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	53                   	push   %ebx
  801e65:	83 ec 14             	sub    $0x14,%esp
  801e68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e6b:	89 1c 24             	mov    %ebx,(%esp)
  801e6e:	e8 7d ec ff ff       	call   800af0 <strlen>
  801e73:	89 c2                	mov    %eax,%edx
  801e75:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e7a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e80:	7f 1f                	jg     801ea1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e86:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e8d:	e8 a8 ec ff ff       	call   800b3a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e92:	ba 00 00 00 00       	mov    $0x0,%edx
  801e97:	b8 07 00 00 00       	mov    $0x7,%eax
  801e9c:	e8 fb fd ff ff       	call   801c9c <fsipc>
}
  801ea1:	83 c4 14             	add    $0x14,%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 28             	sub    $0x28,%esp
  801ead:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801eb0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801eb3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801eb6:	89 34 24             	mov    %esi,(%esp)
  801eb9:	e8 32 ec ff ff       	call   800af0 <strlen>
  801ebe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ec3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ec8:	7f 6d                	jg     801f37 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecd:	89 04 24             	mov    %eax,(%esp)
  801ed0:	e8 d6 f7 ff ff       	call   8016ab <fd_alloc>
  801ed5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 5c                	js     801f37 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ede:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801ee3:	89 34 24             	mov    %esi,(%esp)
  801ee6:	e8 05 ec ff ff       	call   800af0 <strlen>
  801eeb:	83 c0 01             	add    $0x1,%eax
  801eee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801efd:	e8 23 ee ff ff       	call   800d25 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801f02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f05:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0a:	e8 8d fd ff ff       	call   801c9c <fsipc>
  801f0f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801f11:	85 c0                	test   %eax,%eax
  801f13:	79 15                	jns    801f2a <open+0x83>
             fd_close(fd,0);
  801f15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f1c:	00 
  801f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f20:	89 04 24             	mov    %eax,(%esp)
  801f23:	e8 37 fb ff ff       	call   801a5f <fd_close>
             return r;
  801f28:	eb 0d                	jmp    801f37 <open+0x90>
        }
        return fd2num(fd);
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	89 04 24             	mov    %eax,(%esp)
  801f30:	e8 4b f7 ff ff       	call   801680 <fd2num>
  801f35:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801f37:	89 d8                	mov    %ebx,%eax
  801f39:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f3c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f3f:	89 ec                	mov    %ebp,%esp
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    
	...

00801f50 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f56:	c7 44 24 04 38 2d 80 	movl   $0x802d38,0x4(%esp)
  801f5d:	00 
  801f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f61:	89 04 24             	mov    %eax,(%esp)
  801f64:	e8 d1 eb ff ff       	call   800b3a <strcpy>
	return 0;
}
  801f69:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    

00801f70 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	53                   	push   %ebx
  801f74:	83 ec 14             	sub    $0x14,%esp
  801f77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f7a:	89 1c 24             	mov    %ebx,(%esp)
  801f7d:	e8 1a 06 00 00       	call   80259c <pageref>
  801f82:	89 c2                	mov    %eax,%edx
  801f84:	b8 00 00 00 00       	mov    $0x0,%eax
  801f89:	83 fa 01             	cmp    $0x1,%edx
  801f8c:	75 0b                	jne    801f99 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801f8e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 b9 02 00 00       	call   802252 <nsipc_close>
	else
		return 0;
}
  801f99:	83 c4 14             	add    $0x14,%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801fa5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801fac:	00 
  801fad:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	8b 40 0c             	mov    0xc(%eax),%eax
  801fc1:	89 04 24             	mov    %eax,(%esp)
  801fc4:	e8 c5 02 00 00       	call   80228e <nsipc_send>
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801fd1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801fd8:	00 
  801fd9:	8b 45 10             	mov    0x10(%ebp),%eax
  801fdc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fea:	8b 40 0c             	mov    0xc(%eax),%eax
  801fed:	89 04 24             	mov    %eax,(%esp)
  801ff0:	e8 0c 03 00 00       	call   802301 <nsipc_recv>
}
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    

00801ff7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	56                   	push   %esi
  801ffb:	53                   	push   %ebx
  801ffc:	83 ec 20             	sub    $0x20,%esp
  801fff:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802004:	89 04 24             	mov    %eax,(%esp)
  802007:	e8 9f f6 ff ff       	call   8016ab <fd_alloc>
  80200c:	89 c3                	mov    %eax,%ebx
  80200e:	85 c0                	test   %eax,%eax
  802010:	78 21                	js     802033 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802012:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802019:	00 
  80201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802021:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802028:	e8 3b f4 ff ff       	call   801468 <sys_page_alloc>
  80202d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80202f:	85 c0                	test   %eax,%eax
  802031:	79 0a                	jns    80203d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802033:	89 34 24             	mov    %esi,(%esp)
  802036:	e8 17 02 00 00       	call   802252 <nsipc_close>
		return r;
  80203b:	eb 28                	jmp    802065 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80203d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802043:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802046:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802048:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802055:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	89 04 24             	mov    %eax,(%esp)
  80205e:	e8 1d f6 ff ff       	call   801680 <fd2num>
  802063:	89 c3                	mov    %eax,%ebx
}
  802065:	89 d8                	mov    %ebx,%eax
  802067:	83 c4 20             	add    $0x20,%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    

0080206e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802074:	8b 45 10             	mov    0x10(%ebp),%eax
  802077:	89 44 24 08          	mov    %eax,0x8(%esp)
  80207b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802082:	8b 45 08             	mov    0x8(%ebp),%eax
  802085:	89 04 24             	mov    %eax,(%esp)
  802088:	e8 79 01 00 00       	call   802206 <nsipc_socket>
  80208d:	85 c0                	test   %eax,%eax
  80208f:	78 05                	js     802096 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802091:	e8 61 ff ff ff       	call   801ff7 <alloc_sockfd>
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80209e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8020a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 70 f6 ff ff       	call   80171d <fd_lookup>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	78 15                	js     8020c6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8020b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020b4:	8b 0a                	mov    (%edx),%ecx
  8020b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020bb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  8020c1:	75 03                	jne    8020c6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8020c3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8020c6:	c9                   	leave  
  8020c7:	c3                   	ret    

008020c8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d1:	e8 c2 ff ff ff       	call   802098 <fd2sockid>
  8020d6:	85 c0                	test   %eax,%eax
  8020d8:	78 0f                	js     8020e9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e1:	89 04 24             	mov    %eax,(%esp)
  8020e4:	e8 47 01 00 00       	call   802230 <nsipc_listen>
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f4:	e8 9f ff ff ff       	call   802098 <fd2sockid>
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	78 16                	js     802113 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8020fd:	8b 55 10             	mov    0x10(%ebp),%edx
  802100:	89 54 24 08          	mov    %edx,0x8(%esp)
  802104:	8b 55 0c             	mov    0xc(%ebp),%edx
  802107:	89 54 24 04          	mov    %edx,0x4(%esp)
  80210b:	89 04 24             	mov    %eax,(%esp)
  80210e:	e8 6e 02 00 00       	call   802381 <nsipc_connect>
}
  802113:	c9                   	leave  
  802114:	c3                   	ret    

00802115 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80211b:	8b 45 08             	mov    0x8(%ebp),%eax
  80211e:	e8 75 ff ff ff       	call   802098 <fd2sockid>
  802123:	85 c0                	test   %eax,%eax
  802125:	78 0f                	js     802136 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802127:	8b 55 0c             	mov    0xc(%ebp),%edx
  80212a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80212e:	89 04 24             	mov    %eax,(%esp)
  802131:	e8 36 01 00 00       	call   80226c <nsipc_shutdown>
}
  802136:	c9                   	leave  
  802137:	c3                   	ret    

00802138 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80213e:	8b 45 08             	mov    0x8(%ebp),%eax
  802141:	e8 52 ff ff ff       	call   802098 <fd2sockid>
  802146:	85 c0                	test   %eax,%eax
  802148:	78 16                	js     802160 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80214a:	8b 55 10             	mov    0x10(%ebp),%edx
  80214d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802151:	8b 55 0c             	mov    0xc(%ebp),%edx
  802154:	89 54 24 04          	mov    %edx,0x4(%esp)
  802158:	89 04 24             	mov    %eax,(%esp)
  80215b:	e8 60 02 00 00       	call   8023c0 <nsipc_bind>
}
  802160:	c9                   	leave  
  802161:	c3                   	ret    

00802162 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802168:	8b 45 08             	mov    0x8(%ebp),%eax
  80216b:	e8 28 ff ff ff       	call   802098 <fd2sockid>
  802170:	85 c0                	test   %eax,%eax
  802172:	78 1f                	js     802193 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802174:	8b 55 10             	mov    0x10(%ebp),%edx
  802177:	89 54 24 08          	mov    %edx,0x8(%esp)
  80217b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80217e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802182:	89 04 24             	mov    %eax,(%esp)
  802185:	e8 75 02 00 00       	call   8023ff <nsipc_accept>
  80218a:	85 c0                	test   %eax,%eax
  80218c:	78 05                	js     802193 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80218e:	e8 64 fe ff ff       	call   801ff7 <alloc_sockfd>
}
  802193:	c9                   	leave  
  802194:	c3                   	ret    
	...

008021a0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 14             	sub    $0x14,%esp
  8021a7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8021a9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8021b0:	75 11                	jne    8021c3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021b2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8021b9:	e8 a2 02 00 00       	call   802460 <ipc_find_env>
  8021be:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8021c3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8021ca:	00 
  8021cb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8021d2:	00 
  8021d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8021dc:	89 04 24             	mov    %eax,(%esp)
  8021df:	e8 c7 02 00 00       	call   8024ab <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021eb:	00 
  8021ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021f3:	00 
  8021f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021fb:	e8 29 03 00 00       	call   802529 <ipc_recv>
}
  802200:	83 c4 14             	add    $0x14,%esp
  802203:	5b                   	pop    %ebx
  802204:	5d                   	pop    %ebp
  802205:	c3                   	ret    

00802206 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80220c:	8b 45 08             	mov    0x8(%ebp),%eax
  80220f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802214:	8b 45 0c             	mov    0xc(%ebp),%eax
  802217:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80221c:	8b 45 10             	mov    0x10(%ebp),%eax
  80221f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802224:	b8 09 00 00 00       	mov    $0x9,%eax
  802229:	e8 72 ff ff ff       	call   8021a0 <nsipc>
}
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    

00802230 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802236:	8b 45 08             	mov    0x8(%ebp),%eax
  802239:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80223e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802241:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802246:	b8 06 00 00 00       	mov    $0x6,%eax
  80224b:	e8 50 ff ff ff       	call   8021a0 <nsipc>
}
  802250:	c9                   	leave  
  802251:	c3                   	ret    

00802252 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
  80225b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802260:	b8 04 00 00 00       	mov    $0x4,%eax
  802265:	e8 36 ff ff ff       	call   8021a0 <nsipc>
}
  80226a:	c9                   	leave  
  80226b:	c3                   	ret    

0080226c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802272:	8b 45 08             	mov    0x8(%ebp),%eax
  802275:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80227a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802282:	b8 03 00 00 00       	mov    $0x3,%eax
  802287:	e8 14 ff ff ff       	call   8021a0 <nsipc>
}
  80228c:	c9                   	leave  
  80228d:	c3                   	ret    

0080228e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80228e:	55                   	push   %ebp
  80228f:	89 e5                	mov    %esp,%ebp
  802291:	53                   	push   %ebx
  802292:	83 ec 14             	sub    $0x14,%esp
  802295:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802298:	8b 45 08             	mov    0x8(%ebp),%eax
  80229b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8022a0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022a6:	7e 24                	jle    8022cc <nsipc_send+0x3e>
  8022a8:	c7 44 24 0c 44 2d 80 	movl   $0x802d44,0xc(%esp)
  8022af:	00 
  8022b0:	c7 44 24 08 50 2d 80 	movl   $0x802d50,0x8(%esp)
  8022b7:	00 
  8022b8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8022bf:	00 
  8022c0:	c7 04 24 65 2d 80 00 	movl   $0x802d65,(%esp)
  8022c7:	e8 88 de ff ff       	call   800154 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8022de:	e8 42 ea ff ff       	call   800d25 <memmove>
	nsipcbuf.send.req_size = size;
  8022e3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8022e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8022ec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8022f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8022f6:	e8 a5 fe ff ff       	call   8021a0 <nsipc>
}
  8022fb:	83 c4 14             	add    $0x14,%esp
  8022fe:	5b                   	pop    %ebx
  8022ff:	5d                   	pop    %ebp
  802300:	c3                   	ret    

00802301 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	56                   	push   %esi
  802305:	53                   	push   %ebx
  802306:	83 ec 10             	sub    $0x10,%esp
  802309:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80230c:	8b 45 08             	mov    0x8(%ebp),%eax
  80230f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802314:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80231a:	8b 45 14             	mov    0x14(%ebp),%eax
  80231d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802322:	b8 07 00 00 00       	mov    $0x7,%eax
  802327:	e8 74 fe ff ff       	call   8021a0 <nsipc>
  80232c:	89 c3                	mov    %eax,%ebx
  80232e:	85 c0                	test   %eax,%eax
  802330:	78 46                	js     802378 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802332:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802337:	7f 04                	jg     80233d <nsipc_recv+0x3c>
  802339:	39 c6                	cmp    %eax,%esi
  80233b:	7d 24                	jge    802361 <nsipc_recv+0x60>
  80233d:	c7 44 24 0c 71 2d 80 	movl   $0x802d71,0xc(%esp)
  802344:	00 
  802345:	c7 44 24 08 50 2d 80 	movl   $0x802d50,0x8(%esp)
  80234c:	00 
  80234d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802354:	00 
  802355:	c7 04 24 65 2d 80 00 	movl   $0x802d65,(%esp)
  80235c:	e8 f3 dd ff ff       	call   800154 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802361:	89 44 24 08          	mov    %eax,0x8(%esp)
  802365:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80236c:	00 
  80236d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802370:	89 04 24             	mov    %eax,(%esp)
  802373:	e8 ad e9 ff ff       	call   800d25 <memmove>
	}

	return r;
}
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    

00802381 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
  802384:	53                   	push   %ebx
  802385:	83 ec 14             	sub    $0x14,%esp
  802388:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80238b:	8b 45 08             	mov    0x8(%ebp),%eax
  80238e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802393:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80239a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80239e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8023a5:	e8 7b e9 ff ff       	call   800d25 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8023aa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8023b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8023b5:	e8 e6 fd ff ff       	call   8021a0 <nsipc>
}
  8023ba:	83 c4 14             	add    $0x14,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5d                   	pop    %ebp
  8023bf:	c3                   	ret    

008023c0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 14             	sub    $0x14,%esp
  8023c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8023ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8023cd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8023d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023dd:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8023e4:	e8 3c e9 ff ff       	call   800d25 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8023e9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8023ef:	b8 02 00 00 00       	mov    $0x2,%eax
  8023f4:	e8 a7 fd ff ff       	call   8021a0 <nsipc>
}
  8023f9:	83 c4 14             	add    $0x14,%esp
  8023fc:	5b                   	pop    %ebx
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	83 ec 18             	sub    $0x18,%esp
  802405:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802408:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80240b:	8b 45 08             	mov    0x8(%ebp),%eax
  80240e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802413:	b8 01 00 00 00       	mov    $0x1,%eax
  802418:	e8 83 fd ff ff       	call   8021a0 <nsipc>
  80241d:	89 c3                	mov    %eax,%ebx
  80241f:	85 c0                	test   %eax,%eax
  802421:	78 25                	js     802448 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802423:	be 10 60 80 00       	mov    $0x806010,%esi
  802428:	8b 06                	mov    (%esi),%eax
  80242a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80242e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802435:	00 
  802436:	8b 45 0c             	mov    0xc(%ebp),%eax
  802439:	89 04 24             	mov    %eax,(%esp)
  80243c:	e8 e4 e8 ff ff       	call   800d25 <memmove>
		*addrlen = ret->ret_addrlen;
  802441:	8b 16                	mov    (%esi),%edx
  802443:	8b 45 10             	mov    0x10(%ebp),%eax
  802446:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802448:	89 d8                	mov    %ebx,%eax
  80244a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80244d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802450:	89 ec                	mov    %ebp,%esp
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    
	...

00802460 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802466:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80246c:	b8 01 00 00 00       	mov    $0x1,%eax
  802471:	39 ca                	cmp    %ecx,%edx
  802473:	75 04                	jne    802479 <ipc_find_env+0x19>
  802475:	b0 00                	mov    $0x0,%al
  802477:	eb 12                	jmp    80248b <ipc_find_env+0x2b>
  802479:	89 c2                	mov    %eax,%edx
  80247b:	c1 e2 07             	shl    $0x7,%edx
  80247e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802485:	8b 12                	mov    (%edx),%edx
  802487:	39 ca                	cmp    %ecx,%edx
  802489:	75 10                	jne    80249b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80248b:	89 c2                	mov    %eax,%edx
  80248d:	c1 e2 07             	shl    $0x7,%edx
  802490:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802497:	8b 00                	mov    (%eax),%eax
  802499:	eb 0e                	jmp    8024a9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80249b:	83 c0 01             	add    $0x1,%eax
  80249e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024a3:	75 d4                	jne    802479 <ipc_find_env+0x19>
  8024a5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    

008024ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	57                   	push   %edi
  8024af:	56                   	push   %esi
  8024b0:	53                   	push   %ebx
  8024b1:	83 ec 1c             	sub    $0x1c,%esp
  8024b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8024bd:	85 db                	test   %ebx,%ebx
  8024bf:	74 19                	je     8024da <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8024c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8024c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024d0:	89 34 24             	mov    %esi,(%esp)
  8024d3:	e8 31 ed ff ff       	call   801209 <sys_ipc_try_send>
  8024d8:	eb 1b                	jmp    8024f5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8024da:	8b 45 14             	mov    0x14(%ebp),%eax
  8024dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024e1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8024e8:	ee 
  8024e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024ed:	89 34 24             	mov    %esi,(%esp)
  8024f0:	e8 14 ed ff ff       	call   801209 <sys_ipc_try_send>
           if(ret == 0)
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	74 28                	je     802521 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8024f9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024fc:	74 1c                	je     80251a <ipc_send+0x6f>
              panic("ipc send error");
  8024fe:	c7 44 24 08 86 2d 80 	movl   $0x802d86,0x8(%esp)
  802505:	00 
  802506:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80250d:	00 
  80250e:	c7 04 24 95 2d 80 00 	movl   $0x802d95,(%esp)
  802515:	e8 3a dc ff ff       	call   800154 <_panic>
           sys_yield();
  80251a:	e8 b6 ef ff ff       	call   8014d5 <sys_yield>
        }
  80251f:	eb 9c                	jmp    8024bd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    

00802529 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802529:	55                   	push   %ebp
  80252a:	89 e5                	mov    %esp,%ebp
  80252c:	56                   	push   %esi
  80252d:	53                   	push   %ebx
  80252e:	83 ec 10             	sub    $0x10,%esp
  802531:	8b 75 08             	mov    0x8(%ebp),%esi
  802534:	8b 45 0c             	mov    0xc(%ebp),%eax
  802537:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80253a:	85 c0                	test   %eax,%eax
  80253c:	75 0e                	jne    80254c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80253e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802545:	e8 54 ec ff ff       	call   80119e <sys_ipc_recv>
  80254a:	eb 08                	jmp    802554 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80254c:	89 04 24             	mov    %eax,(%esp)
  80254f:	e8 4a ec ff ff       	call   80119e <sys_ipc_recv>
        if(ret == 0){
  802554:	85 c0                	test   %eax,%eax
  802556:	75 26                	jne    80257e <ipc_recv+0x55>
           if(from_env_store)
  802558:	85 f6                	test   %esi,%esi
  80255a:	74 0a                	je     802566 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80255c:	a1 08 40 80 00       	mov    0x804008,%eax
  802561:	8b 40 78             	mov    0x78(%eax),%eax
  802564:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802566:	85 db                	test   %ebx,%ebx
  802568:	74 0a                	je     802574 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80256a:	a1 08 40 80 00       	mov    0x804008,%eax
  80256f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802572:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802574:	a1 08 40 80 00       	mov    0x804008,%eax
  802579:	8b 40 74             	mov    0x74(%eax),%eax
  80257c:	eb 14                	jmp    802592 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80257e:	85 f6                	test   %esi,%esi
  802580:	74 06                	je     802588 <ipc_recv+0x5f>
              *from_env_store = 0;
  802582:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802588:	85 db                	test   %ebx,%ebx
  80258a:	74 06                	je     802592 <ipc_recv+0x69>
              *perm_store = 0;
  80258c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802592:	83 c4 10             	add    $0x10,%esp
  802595:	5b                   	pop    %ebx
  802596:	5e                   	pop    %esi
  802597:	5d                   	pop    %ebp
  802598:	c3                   	ret    
  802599:	00 00                	add    %al,(%eax)
	...

0080259c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80259c:	55                   	push   %ebp
  80259d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80259f:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a2:	89 c2                	mov    %eax,%edx
  8025a4:	c1 ea 16             	shr    $0x16,%edx
  8025a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025ae:	f6 c2 01             	test   $0x1,%dl
  8025b1:	74 20                	je     8025d3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025b3:	c1 e8 0c             	shr    $0xc,%eax
  8025b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025bd:	a8 01                	test   $0x1,%al
  8025bf:	74 12                	je     8025d3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025c1:	c1 e8 0c             	shr    $0xc,%eax
  8025c4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025c9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025ce:	0f b7 c0             	movzwl %ax,%eax
  8025d1:	eb 05                	jmp    8025d8 <pageref+0x3c>
  8025d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    
  8025da:	00 00                	add    %al,(%eax)
  8025dc:	00 00                	add    %al,(%eax)
	...

008025e0 <__udivdi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	89 e5                	mov    %esp,%ebp
  8025e3:	57                   	push   %edi
  8025e4:	56                   	push   %esi
  8025e5:	83 ec 10             	sub    $0x10,%esp
  8025e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8025eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8025f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025f4:	85 c0                	test   %eax,%eax
  8025f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8025f9:	75 35                	jne    802630 <__udivdi3+0x50>
  8025fb:	39 fe                	cmp    %edi,%esi
  8025fd:	77 61                	ja     802660 <__udivdi3+0x80>
  8025ff:	85 f6                	test   %esi,%esi
  802601:	75 0b                	jne    80260e <__udivdi3+0x2e>
  802603:	b8 01 00 00 00       	mov    $0x1,%eax
  802608:	31 d2                	xor    %edx,%edx
  80260a:	f7 f6                	div    %esi
  80260c:	89 c6                	mov    %eax,%esi
  80260e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802611:	31 d2                	xor    %edx,%edx
  802613:	89 f8                	mov    %edi,%eax
  802615:	f7 f6                	div    %esi
  802617:	89 c7                	mov    %eax,%edi
  802619:	89 c8                	mov    %ecx,%eax
  80261b:	f7 f6                	div    %esi
  80261d:	89 c1                	mov    %eax,%ecx
  80261f:	89 fa                	mov    %edi,%edx
  802621:	89 c8                	mov    %ecx,%eax
  802623:	83 c4 10             	add    $0x10,%esp
  802626:	5e                   	pop    %esi
  802627:	5f                   	pop    %edi
  802628:	5d                   	pop    %ebp
  802629:	c3                   	ret    
  80262a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802630:	39 f8                	cmp    %edi,%eax
  802632:	77 1c                	ja     802650 <__udivdi3+0x70>
  802634:	0f bd d0             	bsr    %eax,%edx
  802637:	83 f2 1f             	xor    $0x1f,%edx
  80263a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80263d:	75 39                	jne    802678 <__udivdi3+0x98>
  80263f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802642:	0f 86 a0 00 00 00    	jbe    8026e8 <__udivdi3+0x108>
  802648:	39 f8                	cmp    %edi,%eax
  80264a:	0f 82 98 00 00 00    	jb     8026e8 <__udivdi3+0x108>
  802650:	31 ff                	xor    %edi,%edi
  802652:	31 c9                	xor    %ecx,%ecx
  802654:	89 c8                	mov    %ecx,%eax
  802656:	89 fa                	mov    %edi,%edx
  802658:	83 c4 10             	add    $0x10,%esp
  80265b:	5e                   	pop    %esi
  80265c:	5f                   	pop    %edi
  80265d:	5d                   	pop    %ebp
  80265e:	c3                   	ret    
  80265f:	90                   	nop
  802660:	89 d1                	mov    %edx,%ecx
  802662:	89 fa                	mov    %edi,%edx
  802664:	89 c8                	mov    %ecx,%eax
  802666:	31 ff                	xor    %edi,%edi
  802668:	f7 f6                	div    %esi
  80266a:	89 c1                	mov    %eax,%ecx
  80266c:	89 fa                	mov    %edi,%edx
  80266e:	89 c8                	mov    %ecx,%eax
  802670:	83 c4 10             	add    $0x10,%esp
  802673:	5e                   	pop    %esi
  802674:	5f                   	pop    %edi
  802675:	5d                   	pop    %ebp
  802676:	c3                   	ret    
  802677:	90                   	nop
  802678:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80267c:	89 f2                	mov    %esi,%edx
  80267e:	d3 e0                	shl    %cl,%eax
  802680:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802683:	b8 20 00 00 00       	mov    $0x20,%eax
  802688:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80268b:	89 c1                	mov    %eax,%ecx
  80268d:	d3 ea                	shr    %cl,%edx
  80268f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802693:	0b 55 ec             	or     -0x14(%ebp),%edx
  802696:	d3 e6                	shl    %cl,%esi
  802698:	89 c1                	mov    %eax,%ecx
  80269a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80269d:	89 fe                	mov    %edi,%esi
  80269f:	d3 ee                	shr    %cl,%esi
  8026a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026ab:	d3 e7                	shl    %cl,%edi
  8026ad:	89 c1                	mov    %eax,%ecx
  8026af:	d3 ea                	shr    %cl,%edx
  8026b1:	09 d7                	or     %edx,%edi
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	89 f8                	mov    %edi,%eax
  8026b7:	f7 75 ec             	divl   -0x14(%ebp)
  8026ba:	89 d6                	mov    %edx,%esi
  8026bc:	89 c7                	mov    %eax,%edi
  8026be:	f7 65 e8             	mull   -0x18(%ebp)
  8026c1:	39 d6                	cmp    %edx,%esi
  8026c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026c6:	72 30                	jb     8026f8 <__udivdi3+0x118>
  8026c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026cf:	d3 e2                	shl    %cl,%edx
  8026d1:	39 c2                	cmp    %eax,%edx
  8026d3:	73 05                	jae    8026da <__udivdi3+0xfa>
  8026d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8026d8:	74 1e                	je     8026f8 <__udivdi3+0x118>
  8026da:	89 f9                	mov    %edi,%ecx
  8026dc:	31 ff                	xor    %edi,%edi
  8026de:	e9 71 ff ff ff       	jmp    802654 <__udivdi3+0x74>
  8026e3:	90                   	nop
  8026e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026e8:	31 ff                	xor    %edi,%edi
  8026ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8026ef:	e9 60 ff ff ff       	jmp    802654 <__udivdi3+0x74>
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8026fb:	31 ff                	xor    %edi,%edi
  8026fd:	89 c8                	mov    %ecx,%eax
  8026ff:	89 fa                	mov    %edi,%edx
  802701:	83 c4 10             	add    $0x10,%esp
  802704:	5e                   	pop    %esi
  802705:	5f                   	pop    %edi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    
	...

00802710 <__umoddi3>:
  802710:	55                   	push   %ebp
  802711:	89 e5                	mov    %esp,%ebp
  802713:	57                   	push   %edi
  802714:	56                   	push   %esi
  802715:	83 ec 20             	sub    $0x20,%esp
  802718:	8b 55 14             	mov    0x14(%ebp),%edx
  80271b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80271e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802721:	8b 75 0c             	mov    0xc(%ebp),%esi
  802724:	85 d2                	test   %edx,%edx
  802726:	89 c8                	mov    %ecx,%eax
  802728:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80272b:	75 13                	jne    802740 <__umoddi3+0x30>
  80272d:	39 f7                	cmp    %esi,%edi
  80272f:	76 3f                	jbe    802770 <__umoddi3+0x60>
  802731:	89 f2                	mov    %esi,%edx
  802733:	f7 f7                	div    %edi
  802735:	89 d0                	mov    %edx,%eax
  802737:	31 d2                	xor    %edx,%edx
  802739:	83 c4 20             	add    $0x20,%esp
  80273c:	5e                   	pop    %esi
  80273d:	5f                   	pop    %edi
  80273e:	5d                   	pop    %ebp
  80273f:	c3                   	ret    
  802740:	39 f2                	cmp    %esi,%edx
  802742:	77 4c                	ja     802790 <__umoddi3+0x80>
  802744:	0f bd ca             	bsr    %edx,%ecx
  802747:	83 f1 1f             	xor    $0x1f,%ecx
  80274a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80274d:	75 51                	jne    8027a0 <__umoddi3+0x90>
  80274f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802752:	0f 87 e0 00 00 00    	ja     802838 <__umoddi3+0x128>
  802758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80275b:	29 f8                	sub    %edi,%eax
  80275d:	19 d6                	sbb    %edx,%esi
  80275f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802765:	89 f2                	mov    %esi,%edx
  802767:	83 c4 20             	add    $0x20,%esp
  80276a:	5e                   	pop    %esi
  80276b:	5f                   	pop    %edi
  80276c:	5d                   	pop    %ebp
  80276d:	c3                   	ret    
  80276e:	66 90                	xchg   %ax,%ax
  802770:	85 ff                	test   %edi,%edi
  802772:	75 0b                	jne    80277f <__umoddi3+0x6f>
  802774:	b8 01 00 00 00       	mov    $0x1,%eax
  802779:	31 d2                	xor    %edx,%edx
  80277b:	f7 f7                	div    %edi
  80277d:	89 c7                	mov    %eax,%edi
  80277f:	89 f0                	mov    %esi,%eax
  802781:	31 d2                	xor    %edx,%edx
  802783:	f7 f7                	div    %edi
  802785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802788:	f7 f7                	div    %edi
  80278a:	eb a9                	jmp    802735 <__umoddi3+0x25>
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	89 c8                	mov    %ecx,%eax
  802792:	89 f2                	mov    %esi,%edx
  802794:	83 c4 20             	add    $0x20,%esp
  802797:	5e                   	pop    %esi
  802798:	5f                   	pop    %edi
  802799:	5d                   	pop    %ebp
  80279a:	c3                   	ret    
  80279b:	90                   	nop
  80279c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027a4:	d3 e2                	shl    %cl,%edx
  8027a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8027ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8027b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027b8:	89 fa                	mov    %edi,%edx
  8027ba:	d3 ea                	shr    %cl,%edx
  8027bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8027c3:	d3 e7                	shl    %cl,%edi
  8027c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027cc:	89 f2                	mov    %esi,%edx
  8027ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8027d1:	89 c7                	mov    %eax,%edi
  8027d3:	d3 ea                	shr    %cl,%edx
  8027d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8027dc:	89 c2                	mov    %eax,%edx
  8027de:	d3 e6                	shl    %cl,%esi
  8027e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027e4:	d3 ea                	shr    %cl,%edx
  8027e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027ea:	09 d6                	or     %edx,%esi
  8027ec:	89 f0                	mov    %esi,%eax
  8027ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8027f1:	d3 e7                	shl    %cl,%edi
  8027f3:	89 f2                	mov    %esi,%edx
  8027f5:	f7 75 f4             	divl   -0xc(%ebp)
  8027f8:	89 d6                	mov    %edx,%esi
  8027fa:	f7 65 e8             	mull   -0x18(%ebp)
  8027fd:	39 d6                	cmp    %edx,%esi
  8027ff:	72 2b                	jb     80282c <__umoddi3+0x11c>
  802801:	39 c7                	cmp    %eax,%edi
  802803:	72 23                	jb     802828 <__umoddi3+0x118>
  802805:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802809:	29 c7                	sub    %eax,%edi
  80280b:	19 d6                	sbb    %edx,%esi
  80280d:	89 f0                	mov    %esi,%eax
  80280f:	89 f2                	mov    %esi,%edx
  802811:	d3 ef                	shr    %cl,%edi
  802813:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802817:	d3 e0                	shl    %cl,%eax
  802819:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80281d:	09 f8                	or     %edi,%eax
  80281f:	d3 ea                	shr    %cl,%edx
  802821:	83 c4 20             	add    $0x20,%esp
  802824:	5e                   	pop    %esi
  802825:	5f                   	pop    %edi
  802826:	5d                   	pop    %ebp
  802827:	c3                   	ret    
  802828:	39 d6                	cmp    %edx,%esi
  80282a:	75 d9                	jne    802805 <__umoddi3+0xf5>
  80282c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80282f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802832:	eb d1                	jmp    802805 <__umoddi3+0xf5>
  802834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802838:	39 f2                	cmp    %esi,%edx
  80283a:	0f 82 18 ff ff ff    	jb     802758 <__umoddi3+0x48>
  802840:	e9 1d ff ff ff       	jmp    802762 <__umoddi3+0x52>
