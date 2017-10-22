
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  80003a:	c7 04 24 70 00 80 00 	movl   $0x800070,(%esp)
  800041:	e8 2a 14 00 00       	call   801470 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  800046:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80004d:	de 
  80004e:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  800055:	e8 d7 01 00 00       	call   800231 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  80005a:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  800061:	ca 
  800062:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  800069:	e8 c3 01 00 00       	call   800231 <cprintf>
}
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	53                   	push   %ebx
  800074:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800077:	8b 45 08             	mov    0x8(%ebp),%eax
  80007a:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	c7 04 24 64 17 80 00 	movl   $0x801764,(%esp)
  800087:	e8 a5 01 00 00       	call   800231 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80008c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800093:	00 
  800094:	89 d8                	mov    %ebx,%eax
  800096:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 2b 12 00 00       	call   8012d6 <sys_page_alloc>
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 24                	jns    8000d3 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  8000af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b7:	c7 44 24 08 80 17 80 	movl   $0x801780,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 6e 17 80 00 	movl   $0x80176e,(%esp)
  8000ce:	e8 8d 00 00 00       	call   800160 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d7:	c7 44 24 08 ac 17 80 	movl   $0x8017ac,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000e6:	00 
  8000e7:	89 1c 24             	mov    %ebx,(%esp)
  8000ea:	e8 d0 09 00 00       	call   800abf <snprintf>
}
  8000ef:	83 c4 24             	add    $0x24,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80010a:	e8 b6 12 00 00       	call   8013c5 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	89 c2                	mov    %eax,%edx
  800116:	c1 e2 07             	shl    $0x7,%edx
  800119:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800120:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x38>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 f8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0b 00 00 00       	call   80014c <exit>
}
  800141:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800144:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 a7 12 00 00       	call   801405 <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800168:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80016b:	a1 08 20 80 00       	mov    0x802008,%eax
  800170:	85 c0                	test   %eax,%eax
  800172:	74 10                	je     800184 <_panic+0x24>
		cprintf("%s: ", argv0);
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	c7 04 24 d7 17 80 00 	movl   $0x8017d7,(%esp)
  80017f:	e8 ad 00 00 00       	call   800231 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800184:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80018a:	e8 36 12 00 00       	call   8013c5 <sys_getenvid>
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	89 54 24 10          	mov    %edx,0x10(%esp)
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80019d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	c7 04 24 dc 17 80 00 	movl   $0x8017dc,(%esp)
  8001ac:	e8 80 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 10 00 00 00       	call   8001d0 <vcprintf>
	cprintf("\n");
  8001c0:	c7 04 24 62 17 80 00 	movl   $0x801762,(%esp)
  8001c7:	e8 65 00 00 00       	call   800231 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cc:	cc                   	int3   
  8001cd:	eb fd                	jmp    8001cc <_panic+0x6c>
	...

008001d0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e0:	00 00 00 
	b.cnt = 0;
  8001e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	89 44 24 04          	mov    %eax,0x4(%esp)
  800205:	c7 04 24 4b 02 80 00 	movl   $0x80024b,(%esp)
  80020c:	e8 cb 01 00 00       	call   8003dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800211:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	e8 63 0d 00 00       	call   800f8c <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80023a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	e8 87 ff ff ff       	call   8001d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	53                   	push   %ebx
  80024f:	83 ec 14             	sub    $0x14,%esp
  800252:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800255:	8b 03                	mov    (%ebx),%eax
  800257:	8b 55 08             	mov    0x8(%ebp),%edx
  80025a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80025e:	83 c0 01             	add    $0x1,%eax
  800261:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800263:	3d ff 00 00 00       	cmp    $0xff,%eax
  800268:	75 19                	jne    800283 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80026a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800271:	00 
  800272:	8d 43 08             	lea    0x8(%ebx),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	e8 0f 0d 00 00       	call   800f8c <sys_cputs>
		b->idx = 0;
  80027d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800283:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800287:	83 c4 14             	add    $0x14,%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    
  80028d:	00 00                	add    %al,(%eax)
	...

00800290 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 4c             	sub    $0x4c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d6                	mov    %edx,%esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8002b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002bb:	39 d1                	cmp    %edx,%ecx
  8002bd:	72 07                	jb     8002c6 <printnum_v2+0x36>
  8002bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002c2:	39 d0                	cmp    %edx,%eax
  8002c4:	77 5f                	ja     800325 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8002c6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002ca:	83 eb 01             	sub    $0x1,%ebx
  8002cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002d9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002dd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002e0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002e3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f1:	00 
  8002f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ff:	e8 ec 11 00 00       	call   8014f0 <__udivdi3>
  800304:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800307:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80030a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	89 54 24 04          	mov    %edx,0x4(%esp)
  800319:	89 f2                	mov    %esi,%edx
  80031b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031e:	e8 6d ff ff ff       	call   800290 <printnum_v2>
  800323:	eb 1e                	jmp    800343 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800325:	83 ff 2d             	cmp    $0x2d,%edi
  800328:	74 19                	je     800343 <printnum_v2+0xb3>
		while (--width > 0)
  80032a:	83 eb 01             	sub    $0x1,%ebx
  80032d:	85 db                	test   %ebx,%ebx
  80032f:	90                   	nop
  800330:	7e 11                	jle    800343 <printnum_v2+0xb3>
			putch(padc, putdat);
  800332:	89 74 24 04          	mov    %esi,0x4(%esp)
  800336:	89 3c 24             	mov    %edi,(%esp)
  800339:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80033c:	83 eb 01             	sub    $0x1,%ebx
  80033f:	85 db                	test   %ebx,%ebx
  800341:	7f ef                	jg     800332 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800343:	89 74 24 04          	mov    %esi,0x4(%esp)
  800347:	8b 74 24 04          	mov    0x4(%esp),%esi
  80034b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800352:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800359:	00 
  80035a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80035d:	89 14 24             	mov    %edx,(%esp)
  800360:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800363:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800367:	e8 b4 12 00 00       	call   801620 <__umoddi3>
  80036c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800370:	0f be 80 ff 17 80 00 	movsbl 0x8017ff(%eax),%eax
  800377:	89 04 24             	mov    %eax,(%esp)
  80037a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80037d:	83 c4 4c             	add    $0x4c,%esp
  800380:	5b                   	pop    %ebx
  800381:	5e                   	pop    %esi
  800382:	5f                   	pop    %edi
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800388:	83 fa 01             	cmp    $0x1,%edx
  80038b:	7e 0e                	jle    80039b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	8b 52 04             	mov    0x4(%edx),%edx
  800399:	eb 22                	jmp    8003bd <getuint+0x38>
	else if (lflag)
  80039b:	85 d2                	test   %edx,%edx
  80039d:	74 10                	je     8003af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 0e                	jmp    8003bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ce:	73 0a                	jae    8003da <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d3:	88 0a                	mov    %cl,(%edx)
  8003d5:	83 c2 01             	add    $0x1,%edx
  8003d8:	89 10                	mov    %edx,(%eax)
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	57                   	push   %edi
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	83 ec 6c             	sub    $0x6c,%esp
  8003e5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003e8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003ef:	eb 1a                	jmp    80040b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	0f 84 66 06 00 00    	je     800a5f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	ff 55 08             	call   *0x8(%ebp)
  800406:	eb 03                	jmp    80040b <vprintfmt+0x2f>
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040b:	0f b6 07             	movzbl (%edi),%eax
  80040e:	83 c7 01             	add    $0x1,%edi
  800411:	83 f8 25             	cmp    $0x25,%eax
  800414:	75 db                	jne    8003f1 <vprintfmt+0x15>
  800416:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800426:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80042b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800432:	be 00 00 00 00       	mov    $0x0,%esi
  800437:	eb 06                	jmp    80043f <vprintfmt+0x63>
  800439:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80043d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	0f b6 17             	movzbl (%edi),%edx
  800442:	0f b6 c2             	movzbl %dl,%eax
  800445:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800448:	8d 47 01             	lea    0x1(%edi),%eax
  80044b:	83 ea 23             	sub    $0x23,%edx
  80044e:	80 fa 55             	cmp    $0x55,%dl
  800451:	0f 87 60 05 00 00    	ja     8009b7 <vprintfmt+0x5db>
  800457:	0f b6 d2             	movzbl %dl,%edx
  80045a:	ff 24 95 40 19 80 00 	jmp    *0x801940(,%edx,4)
  800461:	b9 01 00 00 00       	mov    $0x1,%ecx
  800466:	eb d5                	jmp    80043d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800468:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80046b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80046e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800471:	8d 7a d0             	lea    -0x30(%edx),%edi
  800474:	83 ff 09             	cmp    $0x9,%edi
  800477:	76 08                	jbe    800481 <vprintfmt+0xa5>
  800479:	eb 40                	jmp    8004bb <vprintfmt+0xdf>
  80047b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80047f:	eb bc                	jmp    80043d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800481:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800484:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800487:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80048b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80048e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800491:	83 ff 09             	cmp    $0x9,%edi
  800494:	76 eb                	jbe    800481 <vprintfmt+0xa5>
  800496:	eb 23                	jmp    8004bb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800498:	8b 55 14             	mov    0x14(%ebp),%edx
  80049b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80049e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004a1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8004a3:	eb 16                	jmp    8004bb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8004a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004a8:	c1 fa 1f             	sar    $0x1f,%edx
  8004ab:	f7 d2                	not    %edx
  8004ad:	21 55 d8             	and    %edx,-0x28(%ebp)
  8004b0:	eb 8b                	jmp    80043d <vprintfmt+0x61>
  8004b2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004b9:	eb 82                	jmp    80043d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8004bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bf:	0f 89 78 ff ff ff    	jns    80043d <vprintfmt+0x61>
  8004c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004c8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8004cb:	e9 6d ff ff ff       	jmp    80043d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8004d3:	e9 65 ff ff ff       	jmp    80043d <vprintfmt+0x61>
  8004d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	89 04 24             	mov    %eax,(%esp)
  8004f0:	ff 55 08             	call   *0x8(%ebp)
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8004f6:	e9 10 ff ff ff       	jmp    80040b <vprintfmt+0x2f>
  8004fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	8b 00                	mov    (%eax),%eax
  800509:	89 c2                	mov    %eax,%edx
  80050b:	c1 fa 1f             	sar    $0x1f,%edx
  80050e:	31 d0                	xor    %edx,%eax
  800510:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800512:	83 f8 08             	cmp    $0x8,%eax
  800515:	7f 0b                	jg     800522 <vprintfmt+0x146>
  800517:	8b 14 85 a0 1a 80 00 	mov    0x801aa0(,%eax,4),%edx
  80051e:	85 d2                	test   %edx,%edx
  800520:	75 26                	jne    800548 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800522:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800526:	c7 44 24 08 10 18 80 	movl   $0x801810,0x8(%esp)
  80052d:	00 
  80052e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800531:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800535:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800538:	89 1c 24             	mov    %ebx,(%esp)
  80053b:	e8 a7 05 00 00       	call   800ae7 <printfmt>
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800543:	e9 c3 fe ff ff       	jmp    80040b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800548:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054c:	c7 44 24 08 19 18 80 	movl   $0x801819,0x8(%esp)
  800553:	00 
  800554:	8b 45 0c             	mov    0xc(%ebp),%eax
  800557:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055b:	8b 55 08             	mov    0x8(%ebp),%edx
  80055e:	89 14 24             	mov    %edx,(%esp)
  800561:	e8 81 05 00 00       	call   800ae7 <printfmt>
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800569:	e9 9d fe ff ff       	jmp    80040b <vprintfmt+0x2f>
  80056e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800571:	89 c7                	mov    %eax,%edi
  800573:	89 d9                	mov    %ebx,%ecx
  800575:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800578:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 30                	mov    (%eax),%esi
  800586:	85 f6                	test   %esi,%esi
  800588:	75 05                	jne    80058f <vprintfmt+0x1b3>
  80058a:	be 1c 18 80 00       	mov    $0x80181c,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80058f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800593:	7e 06                	jle    80059b <vprintfmt+0x1bf>
  800595:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800599:	75 10                	jne    8005ab <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059b:	0f be 06             	movsbl (%esi),%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	0f 85 a2 00 00 00    	jne    800648 <vprintfmt+0x26c>
  8005a6:	e9 92 00 00 00       	jmp    80063d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005af:	89 34 24             	mov    %esi,(%esp)
  8005b2:	e8 74 05 00 00       	call   800b2b <strnlen>
  8005b7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005ba:	29 c2                	sub    %eax,%edx
  8005bc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	7e d8                	jle    80059b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8005c3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8005c7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005ca:	89 d3                	mov    %edx,%ebx
  8005cc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005cf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8005d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005d5:	89 ce                	mov    %ecx,%esi
  8005d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005db:	89 34 24             	mov    %esi,(%esp)
  8005de:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 eb 01             	sub    $0x1,%ebx
  8005e4:	85 db                	test   %ebx,%ebx
  8005e6:	7f ef                	jg     8005d7 <vprintfmt+0x1fb>
  8005e8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ee:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8005f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005f8:	eb a1                	jmp    80059b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005fe:	74 1b                	je     80061b <vprintfmt+0x23f>
  800600:	8d 50 e0             	lea    -0x20(%eax),%edx
  800603:	83 fa 5e             	cmp    $0x5e,%edx
  800606:	76 13                	jbe    80061b <vprintfmt+0x23f>
					putch('?', putdat);
  800608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	eb 0d                	jmp    800628 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80061b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80061e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800628:	83 ef 01             	sub    $0x1,%edi
  80062b:	0f be 06             	movsbl (%esi),%eax
  80062e:	85 c0                	test   %eax,%eax
  800630:	74 05                	je     800637 <vprintfmt+0x25b>
  800632:	83 c6 01             	add    $0x1,%esi
  800635:	eb 1a                	jmp    800651 <vprintfmt+0x275>
  800637:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80063a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800641:	7f 1f                	jg     800662 <vprintfmt+0x286>
  800643:	e9 c0 fd ff ff       	jmp    800408 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 c6 01             	add    $0x1,%esi
  80064b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80064e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800651:	85 db                	test   %ebx,%ebx
  800653:	78 a5                	js     8005fa <vprintfmt+0x21e>
  800655:	83 eb 01             	sub    $0x1,%ebx
  800658:	79 a0                	jns    8005fa <vprintfmt+0x21e>
  80065a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80065d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800660:	eb db                	jmp    80063d <vprintfmt+0x261>
  800662:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800665:	8b 75 0c             	mov    0xc(%ebp),%esi
  800668:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80066b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800672:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800679:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067b:	83 eb 01             	sub    $0x1,%ebx
  80067e:	85 db                	test   %ebx,%ebx
  800680:	7f ec                	jg     80066e <vprintfmt+0x292>
  800682:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800685:	e9 81 fd ff ff       	jmp    80040b <vprintfmt+0x2f>
  80068a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068d:	83 fe 01             	cmp    $0x1,%esi
  800690:	7e 10                	jle    8006a2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 08             	lea    0x8(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 18                	mov    (%eax),%ebx
  80069d:	8b 70 04             	mov    0x4(%eax),%esi
  8006a0:	eb 26                	jmp    8006c8 <vprintfmt+0x2ec>
	else if (lflag)
  8006a2:	85 f6                	test   %esi,%esi
  8006a4:	74 12                	je     8006b8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 18                	mov    (%eax),%ebx
  8006b1:	89 de                	mov    %ebx,%esi
  8006b3:	c1 fe 1f             	sar    $0x1f,%esi
  8006b6:	eb 10                	jmp    8006c8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 18                	mov    (%eax),%ebx
  8006c3:	89 de                	mov    %ebx,%esi
  8006c5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8006c8:	83 f9 01             	cmp    $0x1,%ecx
  8006cb:	75 1e                	jne    8006eb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8006cd:	85 f6                	test   %esi,%esi
  8006cf:	78 1a                	js     8006eb <vprintfmt+0x30f>
  8006d1:	85 f6                	test   %esi,%esi
  8006d3:	7f 05                	jg     8006da <vprintfmt+0x2fe>
  8006d5:	83 fb 00             	cmp    $0x0,%ebx
  8006d8:	76 11                	jbe    8006eb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8006da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006e1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8006e8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8006eb:	85 f6                	test   %esi,%esi
  8006ed:	78 13                	js     800702 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ef:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8006f2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fd:	e9 da 00 00 00       	jmp    8007dc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800702:	8b 45 0c             	mov    0xc(%ebp),%eax
  800705:	89 44 24 04          	mov    %eax,0x4(%esp)
  800709:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800710:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800713:	89 da                	mov    %ebx,%edx
  800715:	89 f1                	mov    %esi,%ecx
  800717:	f7 da                	neg    %edx
  800719:	83 d1 00             	adc    $0x0,%ecx
  80071c:	f7 d9                	neg    %ecx
  80071e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800721:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072c:	e9 ab 00 00 00       	jmp    8007dc <vprintfmt+0x400>
  800731:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800734:	89 f2                	mov    %esi,%edx
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
  800739:	e8 47 fc ff ff       	call   800385 <getuint>
  80073e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800741:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800747:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80074c:	e9 8b 00 00 00       	jmp    8007dc <vprintfmt+0x400>
  800751:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800754:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800757:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80075b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800762:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800765:	89 f2                	mov    %esi,%edx
  800767:	8d 45 14             	lea    0x14(%ebp),%eax
  80076a:	e8 16 fc ff ff       	call   800385 <getuint>
  80076f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800772:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800778:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80077d:	eb 5d                	jmp    8007dc <vprintfmt+0x400>
  80077f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800785:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800789:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800790:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800793:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800797:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8d 50 04             	lea    0x4(%eax),%edx
  8007a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007aa:	8b 10                	mov    (%eax),%edx
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007b4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007bf:	eb 1b                	jmp    8007dc <vprintfmt+0x400>
  8007c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c4:	89 f2                	mov    %esi,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 b7 fb ff ff       	call   800385 <getuint>
  8007ce:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007d1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007dc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8007e0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007e6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8007ea:	77 09                	ja     8007f5 <vprintfmt+0x419>
  8007ec:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8007ef:	0f 82 ac 00 00 00    	jb     8008a1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8007f5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007f8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8007fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ff:	83 ea 01             	sub    $0x1,%edx
  800802:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800806:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80080e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800812:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800815:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800818:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80081b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80081f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800826:	00 
  800827:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80082a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80082d:	89 0c 24             	mov    %ecx,(%esp)
  800830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800834:	e8 b7 0c 00 00       	call   8014f0 <__udivdi3>
  800839:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80083c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80083f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800843:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	e8 37 fa ff ff       	call   800290 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800859:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80085c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800860:	8b 74 24 04          	mov    0x4(%esp),%esi
  800864:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800867:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800872:	00 
  800873:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800876:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800879:	89 14 24             	mov    %edx,(%esp)
  80087c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800880:	e8 9b 0d 00 00       	call   801620 <__umoddi3>
  800885:	89 74 24 04          	mov    %esi,0x4(%esp)
  800889:	0f be 80 ff 17 80 00 	movsbl 0x8017ff(%eax),%eax
  800890:	89 04 24             	mov    %eax,(%esp)
  800893:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800896:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80089a:	74 54                	je     8008f0 <vprintfmt+0x514>
  80089c:	e9 67 fb ff ff       	jmp    800408 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8008a1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008a5:	8d 76 00             	lea    0x0(%esi),%esi
  8008a8:	0f 84 2a 01 00 00    	je     8009d8 <vprintfmt+0x5fc>
		while (--width > 0)
  8008ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008b1:	83 ef 01             	sub    $0x1,%edi
  8008b4:	85 ff                	test   %edi,%edi
  8008b6:	0f 8e 5e 01 00 00    	jle    800a1a <vprintfmt+0x63e>
  8008bc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008bf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008c2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8008c5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8008c8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008cb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8008ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d2:	89 1c 24             	mov    %ebx,(%esp)
  8008d5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8008d8:	83 ef 01             	sub    $0x1,%edi
  8008db:	85 ff                	test   %edi,%edi
  8008dd:	7f ef                	jg     8008ce <vprintfmt+0x4f2>
  8008df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008e5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8008e8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8008eb:	e9 2a 01 00 00       	jmp    800a1a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008f0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8008f3:	83 eb 01             	sub    $0x1,%ebx
  8008f6:	85 db                	test   %ebx,%ebx
  8008f8:	0f 8e 0a fb ff ff    	jle    800408 <vprintfmt+0x2c>
  8008fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800901:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800907:	89 74 24 04          	mov    %esi,0x4(%esp)
  80090b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800912:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	85 db                	test   %ebx,%ebx
  800919:	7f ec                	jg     800907 <vprintfmt+0x52b>
  80091b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80091e:	e9 e8 fa ff ff       	jmp    80040b <vprintfmt+0x2f>
  800923:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800926:	8b 45 14             	mov    0x14(%ebp),%eax
  800929:	8d 50 04             	lea    0x4(%eax),%edx
  80092c:	89 55 14             	mov    %edx,0x14(%ebp)
  80092f:	8b 00                	mov    (%eax),%eax
  800931:	85 c0                	test   %eax,%eax
  800933:	75 2a                	jne    80095f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800935:	c7 44 24 0c b8 18 80 	movl   $0x8018b8,0xc(%esp)
  80093c:	00 
  80093d:	c7 44 24 08 19 18 80 	movl   $0x801819,0x8(%esp)
  800944:	00 
  800945:	8b 55 0c             	mov    0xc(%ebp),%edx
  800948:	89 54 24 04          	mov    %edx,0x4(%esp)
  80094c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094f:	89 0c 24             	mov    %ecx,(%esp)
  800952:	e8 90 01 00 00       	call   800ae7 <printfmt>
  800957:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80095a:	e9 ac fa ff ff       	jmp    80040b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80095f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800962:	8b 13                	mov    (%ebx),%edx
  800964:	83 fa 7f             	cmp    $0x7f,%edx
  800967:	7e 29                	jle    800992 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800969:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80096b:	c7 44 24 0c f0 18 80 	movl   $0x8018f0,0xc(%esp)
  800972:	00 
  800973:	c7 44 24 08 19 18 80 	movl   $0x801819,0x8(%esp)
  80097a:	00 
  80097b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	89 04 24             	mov    %eax,(%esp)
  800985:	e8 5d 01 00 00       	call   800ae7 <printfmt>
  80098a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80098d:	e9 79 fa ff ff       	jmp    80040b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800992:	88 10                	mov    %dl,(%eax)
  800994:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800997:	e9 6f fa ff ff       	jmp    80040b <vprintfmt+0x2f>
  80099c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80099f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009a9:	89 14 24             	mov    %edx,(%esp)
  8009ac:	ff 55 08             	call   *0x8(%ebp)
  8009af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8009b2:	e9 54 fa ff ff       	jmp    80040b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8009cb:	80 38 25             	cmpb   $0x25,(%eax)
  8009ce:	0f 84 37 fa ff ff    	je     80040b <vprintfmt+0x2f>
  8009d4:	89 c7                	mov    %eax,%edi
  8009d6:	eb f0                	jmp    8009c8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009df:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009e3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009e6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009f1:	00 
  8009f2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009f5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009f8:	89 04 24             	mov    %eax,(%esp)
  8009fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009ff:	e8 1c 0c 00 00       	call   801620 <__umoddi3>
  800a04:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a08:	0f be 80 ff 17 80 00 	movsbl 0x8017ff(%eax),%eax
  800a0f:	89 04 24             	mov    %eax,(%esp)
  800a12:	ff 55 08             	call   *0x8(%ebp)
  800a15:	e9 d6 fe ff ff       	jmp    8008f0 <vprintfmt+0x514>
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a21:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a25:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a2c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a33:	00 
  800a34:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a37:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a3a:	89 04 24             	mov    %eax,(%esp)
  800a3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a41:	e8 da 0b 00 00       	call   801620 <__umoddi3>
  800a46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4a:	0f be 80 ff 17 80 00 	movsbl 0x8017ff(%eax),%eax
  800a51:	89 04 24             	mov    %eax,(%esp)
  800a54:	ff 55 08             	call   *0x8(%ebp)
  800a57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5a:	e9 ac f9 ff ff       	jmp    80040b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a5f:	83 c4 6c             	add    $0x6c,%esp
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	83 ec 28             	sub    $0x28,%esp
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a73:	85 c0                	test   %eax,%eax
  800a75:	74 04                	je     800a7b <vsnprintf+0x14>
  800a77:	85 d2                	test   %edx,%edx
  800a79:	7f 07                	jg     800a82 <vsnprintf+0x1b>
  800a7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a80:	eb 3b                	jmp    800abd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a85:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a89:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a93:	8b 45 14             	mov    0x14(%ebp),%eax
  800a96:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a9a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa8:	c7 04 24 bf 03 80 00 	movl   $0x8003bf,(%esp)
  800aaf:	e8 28 f9 ff ff       	call   8003dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ab7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800ac5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800ac8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800acc:	8b 45 10             	mov    0x10(%ebp),%eax
  800acf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	89 04 24             	mov    %eax,(%esp)
  800ae0:	e8 82 ff ff ff       	call   800a67 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800aed:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800af0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af4:	8b 45 10             	mov    0x10(%ebp),%eax
  800af7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	89 04 24             	mov    %eax,(%esp)
  800b08:	e8 cf f8 ff ff       	call   8003dc <vprintfmt>
	va_end(ap);
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    
	...

00800b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b1e:	74 09                	je     800b29 <strlen+0x19>
		n++;
  800b20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b27:	75 f7                	jne    800b20 <strlen+0x10>
		n++;
	return n;
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	53                   	push   %ebx
  800b2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b35:	85 c9                	test   %ecx,%ecx
  800b37:	74 19                	je     800b52 <strnlen+0x27>
  800b39:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b3c:	74 14                	je     800b52 <strnlen+0x27>
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b43:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b46:	39 c8                	cmp    %ecx,%eax
  800b48:	74 0d                	je     800b57 <strnlen+0x2c>
  800b4a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b4e:	75 f3                	jne    800b43 <strnlen+0x18>
  800b50:	eb 05                	jmp    800b57 <strnlen+0x2c>
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b57:	5b                   	pop    %ebx
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b69:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b6d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b70:	83 c2 01             	add    $0x1,%edx
  800b73:	84 c9                	test   %cl,%cl
  800b75:	75 f2                	jne    800b69 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b77:	5b                   	pop    %ebx
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 08             	sub    $0x8,%esp
  800b81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b84:	89 1c 24             	mov    %ebx,(%esp)
  800b87:	e8 84 ff ff ff       	call   800b10 <strlen>
	strcpy(dst + len, src);
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b93:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b96:	89 04 24             	mov    %eax,(%esp)
  800b99:	e8 bc ff ff ff       	call   800b5a <strcpy>
	return dst;
}
  800b9e:	89 d8                	mov    %ebx,%eax
  800ba0:	83 c4 08             	add    $0x8,%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	8b 45 08             	mov    0x8(%ebp),%eax
  800bae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb4:	85 f6                	test   %esi,%esi
  800bb6:	74 18                	je     800bd0 <strncpy+0x2a>
  800bb8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bbd:	0f b6 1a             	movzbl (%edx),%ebx
  800bc0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bc3:	80 3a 01             	cmpb   $0x1,(%edx)
  800bc6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc9:	83 c1 01             	add    $0x1,%ecx
  800bcc:	39 ce                	cmp    %ecx,%esi
  800bce:	77 ed                	ja     800bbd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800be2:	89 f0                	mov    %esi,%eax
  800be4:	85 c9                	test   %ecx,%ecx
  800be6:	74 27                	je     800c0f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800be8:	83 e9 01             	sub    $0x1,%ecx
  800beb:	74 1d                	je     800c0a <strlcpy+0x36>
  800bed:	0f b6 1a             	movzbl (%edx),%ebx
  800bf0:	84 db                	test   %bl,%bl
  800bf2:	74 16                	je     800c0a <strlcpy+0x36>
			*dst++ = *src++;
  800bf4:	88 18                	mov    %bl,(%eax)
  800bf6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bf9:	83 e9 01             	sub    $0x1,%ecx
  800bfc:	74 0e                	je     800c0c <strlcpy+0x38>
			*dst++ = *src++;
  800bfe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c01:	0f b6 1a             	movzbl (%edx),%ebx
  800c04:	84 db                	test   %bl,%bl
  800c06:	75 ec                	jne    800bf4 <strlcpy+0x20>
  800c08:	eb 02                	jmp    800c0c <strlcpy+0x38>
  800c0a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c0c:	c6 00 00             	movb   $0x0,(%eax)
  800c0f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c1e:	0f b6 01             	movzbl (%ecx),%eax
  800c21:	84 c0                	test   %al,%al
  800c23:	74 15                	je     800c3a <strcmp+0x25>
  800c25:	3a 02                	cmp    (%edx),%al
  800c27:	75 11                	jne    800c3a <strcmp+0x25>
		p++, q++;
  800c29:	83 c1 01             	add    $0x1,%ecx
  800c2c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c2f:	0f b6 01             	movzbl (%ecx),%eax
  800c32:	84 c0                	test   %al,%al
  800c34:	74 04                	je     800c3a <strcmp+0x25>
  800c36:	3a 02                	cmp    (%edx),%al
  800c38:	74 ef                	je     800c29 <strcmp+0x14>
  800c3a:	0f b6 c0             	movzbl %al,%eax
  800c3d:	0f b6 12             	movzbl (%edx),%edx
  800c40:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	53                   	push   %ebx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	74 23                	je     800c78 <strncmp+0x34>
  800c55:	0f b6 1a             	movzbl (%edx),%ebx
  800c58:	84 db                	test   %bl,%bl
  800c5a:	74 25                	je     800c81 <strncmp+0x3d>
  800c5c:	3a 19                	cmp    (%ecx),%bl
  800c5e:	75 21                	jne    800c81 <strncmp+0x3d>
  800c60:	83 e8 01             	sub    $0x1,%eax
  800c63:	74 13                	je     800c78 <strncmp+0x34>
		n--, p++, q++;
  800c65:	83 c2 01             	add    $0x1,%edx
  800c68:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c6b:	0f b6 1a             	movzbl (%edx),%ebx
  800c6e:	84 db                	test   %bl,%bl
  800c70:	74 0f                	je     800c81 <strncmp+0x3d>
  800c72:	3a 19                	cmp    (%ecx),%bl
  800c74:	74 ea                	je     800c60 <strncmp+0x1c>
  800c76:	eb 09                	jmp    800c81 <strncmp+0x3d>
  800c78:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5d                   	pop    %ebp
  800c7f:	90                   	nop
  800c80:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c81:	0f b6 02             	movzbl (%edx),%eax
  800c84:	0f b6 11             	movzbl (%ecx),%edx
  800c87:	29 d0                	sub    %edx,%eax
  800c89:	eb f2                	jmp    800c7d <strncmp+0x39>

00800c8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c95:	0f b6 10             	movzbl (%eax),%edx
  800c98:	84 d2                	test   %dl,%dl
  800c9a:	74 18                	je     800cb4 <strchr+0x29>
		if (*s == c)
  800c9c:	38 ca                	cmp    %cl,%dl
  800c9e:	75 0a                	jne    800caa <strchr+0x1f>
  800ca0:	eb 17                	jmp    800cb9 <strchr+0x2e>
  800ca2:	38 ca                	cmp    %cl,%dl
  800ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca8:	74 0f                	je     800cb9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800caa:	83 c0 01             	add    $0x1,%eax
  800cad:	0f b6 10             	movzbl (%eax),%edx
  800cb0:	84 d2                	test   %dl,%dl
  800cb2:	75 ee                	jne    800ca2 <strchr+0x17>
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc5:	0f b6 10             	movzbl (%eax),%edx
  800cc8:	84 d2                	test   %dl,%dl
  800cca:	74 18                	je     800ce4 <strfind+0x29>
		if (*s == c)
  800ccc:	38 ca                	cmp    %cl,%dl
  800cce:	75 0a                	jne    800cda <strfind+0x1f>
  800cd0:	eb 12                	jmp    800ce4 <strfind+0x29>
  800cd2:	38 ca                	cmp    %cl,%dl
  800cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd8:	74 0a                	je     800ce4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cda:	83 c0 01             	add    $0x1,%eax
  800cdd:	0f b6 10             	movzbl (%eax),%edx
  800ce0:	84 d2                	test   %dl,%dl
  800ce2:	75 ee                	jne    800cd2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	89 1c 24             	mov    %ebx,(%esp)
  800cef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d00:	85 c9                	test   %ecx,%ecx
  800d02:	74 30                	je     800d34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d0a:	75 25                	jne    800d31 <memset+0x4b>
  800d0c:	f6 c1 03             	test   $0x3,%cl
  800d0f:	75 20                	jne    800d31 <memset+0x4b>
		c &= 0xFF;
  800d11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d14:	89 d3                	mov    %edx,%ebx
  800d16:	c1 e3 08             	shl    $0x8,%ebx
  800d19:	89 d6                	mov    %edx,%esi
  800d1b:	c1 e6 18             	shl    $0x18,%esi
  800d1e:	89 d0                	mov    %edx,%eax
  800d20:	c1 e0 10             	shl    $0x10,%eax
  800d23:	09 f0                	or     %esi,%eax
  800d25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d27:	09 d8                	or     %ebx,%eax
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	fc                   	cld    
  800d2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d2f:	eb 03                	jmp    800d34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d31:	fc                   	cld    
  800d32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d34:	89 f8                	mov    %edi,%eax
  800d36:	8b 1c 24             	mov    (%esp),%ebx
  800d39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d41:	89 ec                	mov    %ebp,%esp
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
  800d4b:	89 34 24             	mov    %esi,(%esp)
  800d4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d5d:	39 c6                	cmp    %eax,%esi
  800d5f:	73 35                	jae    800d96 <memmove+0x51>
  800d61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d64:	39 d0                	cmp    %edx,%eax
  800d66:	73 2e                	jae    800d96 <memmove+0x51>
		s += n;
		d += n;
  800d68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6a:	f6 c2 03             	test   $0x3,%dl
  800d6d:	75 1b                	jne    800d8a <memmove+0x45>
  800d6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d75:	75 13                	jne    800d8a <memmove+0x45>
  800d77:	f6 c1 03             	test   $0x3,%cl
  800d7a:	75 0e                	jne    800d8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d7c:	83 ef 04             	sub    $0x4,%edi
  800d7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d82:	c1 e9 02             	shr    $0x2,%ecx
  800d85:	fd                   	std    
  800d86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d88:	eb 09                	jmp    800d93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d8a:	83 ef 01             	sub    $0x1,%edi
  800d8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d90:	fd                   	std    
  800d91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d93:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d94:	eb 20                	jmp    800db6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d9c:	75 15                	jne    800db3 <memmove+0x6e>
  800d9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da4:	75 0d                	jne    800db3 <memmove+0x6e>
  800da6:	f6 c1 03             	test   $0x3,%cl
  800da9:	75 08                	jne    800db3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800dab:	c1 e9 02             	shr    $0x2,%ecx
  800dae:	fc                   	cld    
  800daf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800db1:	eb 03                	jmp    800db6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800db3:	fc                   	cld    
  800db4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800db6:	8b 34 24             	mov    (%esp),%esi
  800db9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dbd:	89 ec                	mov    %ebp,%esp
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800dca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	89 04 24             	mov    %eax,(%esp)
  800ddb:	e8 65 ff ff ff       	call   800d45 <memmove>
}
  800de0:	c9                   	leave  
  800de1:	c3                   	ret    

00800de2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	8b 75 08             	mov    0x8(%ebp),%esi
  800deb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df1:	85 c9                	test   %ecx,%ecx
  800df3:	74 36                	je     800e2b <memcmp+0x49>
		if (*s1 != *s2)
  800df5:	0f b6 06             	movzbl (%esi),%eax
  800df8:	0f b6 1f             	movzbl (%edi),%ebx
  800dfb:	38 d8                	cmp    %bl,%al
  800dfd:	74 20                	je     800e1f <memcmp+0x3d>
  800dff:	eb 14                	jmp    800e15 <memcmp+0x33>
  800e01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e0b:	83 c2 01             	add    $0x1,%edx
  800e0e:	83 e9 01             	sub    $0x1,%ecx
  800e11:	38 d8                	cmp    %bl,%al
  800e13:	74 12                	je     800e27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e15:	0f b6 c0             	movzbl %al,%eax
  800e18:	0f b6 db             	movzbl %bl,%ebx
  800e1b:	29 d8                	sub    %ebx,%eax
  800e1d:	eb 11                	jmp    800e30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e1f:	83 e9 01             	sub    $0x1,%ecx
  800e22:	ba 00 00 00 00       	mov    $0x0,%edx
  800e27:	85 c9                	test   %ecx,%ecx
  800e29:	75 d6                	jne    800e01 <memcmp+0x1f>
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e3b:	89 c2                	mov    %eax,%edx
  800e3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e40:	39 d0                	cmp    %edx,%eax
  800e42:	73 15                	jae    800e59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e48:	38 08                	cmp    %cl,(%eax)
  800e4a:	75 06                	jne    800e52 <memfind+0x1d>
  800e4c:	eb 0b                	jmp    800e59 <memfind+0x24>
  800e4e:	38 08                	cmp    %cl,(%eax)
  800e50:	74 07                	je     800e59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e52:	83 c0 01             	add    $0x1,%eax
  800e55:	39 c2                	cmp    %eax,%edx
  800e57:	77 f5                	ja     800e4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e6a:	0f b6 02             	movzbl (%edx),%eax
  800e6d:	3c 20                	cmp    $0x20,%al
  800e6f:	74 04                	je     800e75 <strtol+0x1a>
  800e71:	3c 09                	cmp    $0x9,%al
  800e73:	75 0e                	jne    800e83 <strtol+0x28>
		s++;
  800e75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e78:	0f b6 02             	movzbl (%edx),%eax
  800e7b:	3c 20                	cmp    $0x20,%al
  800e7d:	74 f6                	je     800e75 <strtol+0x1a>
  800e7f:	3c 09                	cmp    $0x9,%al
  800e81:	74 f2                	je     800e75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e83:	3c 2b                	cmp    $0x2b,%al
  800e85:	75 0c                	jne    800e93 <strtol+0x38>
		s++;
  800e87:	83 c2 01             	add    $0x1,%edx
  800e8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e91:	eb 15                	jmp    800ea8 <strtol+0x4d>
	else if (*s == '-')
  800e93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e9a:	3c 2d                	cmp    $0x2d,%al
  800e9c:	75 0a                	jne    800ea8 <strtol+0x4d>
		s++, neg = 1;
  800e9e:	83 c2 01             	add    $0x1,%edx
  800ea1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ea8:	85 db                	test   %ebx,%ebx
  800eaa:	0f 94 c0             	sete   %al
  800ead:	74 05                	je     800eb4 <strtol+0x59>
  800eaf:	83 fb 10             	cmp    $0x10,%ebx
  800eb2:	75 18                	jne    800ecc <strtol+0x71>
  800eb4:	80 3a 30             	cmpb   $0x30,(%edx)
  800eb7:	75 13                	jne    800ecc <strtol+0x71>
  800eb9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ebd:	8d 76 00             	lea    0x0(%esi),%esi
  800ec0:	75 0a                	jne    800ecc <strtol+0x71>
		s += 2, base = 16;
  800ec2:	83 c2 02             	add    $0x2,%edx
  800ec5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eca:	eb 15                	jmp    800ee1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ecc:	84 c0                	test   %al,%al
  800ece:	66 90                	xchg   %ax,%ax
  800ed0:	74 0f                	je     800ee1 <strtol+0x86>
  800ed2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ed7:	80 3a 30             	cmpb   $0x30,(%edx)
  800eda:	75 05                	jne    800ee1 <strtol+0x86>
		s++, base = 8;
  800edc:	83 c2 01             	add    $0x1,%edx
  800edf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ee8:	0f b6 0a             	movzbl (%edx),%ecx
  800eeb:	89 cf                	mov    %ecx,%edi
  800eed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ef0:	80 fb 09             	cmp    $0x9,%bl
  800ef3:	77 08                	ja     800efd <strtol+0xa2>
			dig = *s - '0';
  800ef5:	0f be c9             	movsbl %cl,%ecx
  800ef8:	83 e9 30             	sub    $0x30,%ecx
  800efb:	eb 1e                	jmp    800f1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800efd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f00:	80 fb 19             	cmp    $0x19,%bl
  800f03:	77 08                	ja     800f0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f05:	0f be c9             	movsbl %cl,%ecx
  800f08:	83 e9 57             	sub    $0x57,%ecx
  800f0b:	eb 0e                	jmp    800f1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f10:	80 fb 19             	cmp    $0x19,%bl
  800f13:	77 15                	ja     800f2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f15:	0f be c9             	movsbl %cl,%ecx
  800f18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f1b:	39 f1                	cmp    %esi,%ecx
  800f1d:	7d 0b                	jge    800f2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f1f:	83 c2 01             	add    $0x1,%edx
  800f22:	0f af c6             	imul   %esi,%eax
  800f25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f28:	eb be                	jmp    800ee8 <strtol+0x8d>
  800f2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f30:	74 05                	je     800f37 <strtol+0xdc>
		*endptr = (char *) s;
  800f32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f3b:	74 04                	je     800f41 <strtol+0xe6>
  800f3d:	89 c8                	mov    %ecx,%eax
  800f3f:	f7 d8                	neg    %eax
}
  800f41:	83 c4 04             	add    $0x4,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	00 00                	add    %al,(%eax)
	...

00800f4c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 08             	sub    $0x8,%esp
  800f52:	89 1c 24             	mov    %ebx,(%esp)
  800f55:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f59:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	89 d1                	mov    %edx,%ecx
  800f65:	89 d3                	mov    %edx,%ebx
  800f67:	89 d7                	mov    %edx,%edi
  800f69:	51                   	push   %ecx
  800f6a:	52                   	push   %edx
  800f6b:	53                   	push   %ebx
  800f6c:	54                   	push   %esp
  800f6d:	55                   	push   %ebp
  800f6e:	56                   	push   %esi
  800f6f:	57                   	push   %edi
  800f70:	54                   	push   %esp
  800f71:	5d                   	pop    %ebp
  800f72:	8d 35 7a 0f 80 00    	lea    0x800f7a,%esi
  800f78:	0f 34                	sysenter 
  800f7a:	5f                   	pop    %edi
  800f7b:	5e                   	pop    %esi
  800f7c:	5d                   	pop    %ebp
  800f7d:	5c                   	pop    %esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5a                   	pop    %edx
  800f80:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f81:	8b 1c 24             	mov    (%esp),%ebx
  800f84:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f88:	89 ec                	mov    %ebp,%esp
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800f99:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	89 c3                	mov    %eax,%ebx
  800fa6:	89 c7                	mov    %eax,%edi
  800fa8:	51                   	push   %ecx
  800fa9:	52                   	push   %edx
  800faa:	53                   	push   %ebx
  800fab:	54                   	push   %esp
  800fac:	55                   	push   %ebp
  800fad:	56                   	push   %esi
  800fae:	57                   	push   %edi
  800faf:	54                   	push   %esp
  800fb0:	5d                   	pop    %ebp
  800fb1:	8d 35 b9 0f 80 00    	lea    0x800fb9,%esi
  800fb7:	0f 34                	sysenter 
  800fb9:	5f                   	pop    %edi
  800fba:	5e                   	pop    %esi
  800fbb:	5d                   	pop    %ebp
  800fbc:	5c                   	pop    %esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5a                   	pop    %edx
  800fbf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fc0:	8b 1c 24             	mov    (%esp),%ebx
  800fc3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fc7:	89 ec                	mov    %ebp,%esp
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	83 ec 28             	sub    $0x28,%esp
  800fd1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fd4:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	51                   	push   %ecx
  800fea:	52                   	push   %edx
  800feb:	53                   	push   %ebx
  800fec:	54                   	push   %esp
  800fed:	55                   	push   %ebp
  800fee:	56                   	push   %esi
  800fef:	57                   	push   %edi
  800ff0:	54                   	push   %esp
  800ff1:	5d                   	pop    %ebp
  800ff2:	8d 35 fa 0f 80 00    	lea    0x800ffa,%esi
  800ff8:	0f 34                	sysenter 
  800ffa:	5f                   	pop    %edi
  800ffb:	5e                   	pop    %esi
  800ffc:	5d                   	pop    %ebp
  800ffd:	5c                   	pop    %esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5a                   	pop    %edx
  801000:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	7e 28                	jle    80102d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801005:	89 44 24 10          	mov    %eax,0x10(%esp)
  801009:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801010:	00 
  801011:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  801028:	e8 33 f1 ff ff       	call   800160 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80102d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801030:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801033:	89 ec                	mov    %ebp,%esp
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 08             	sub    $0x8,%esp
  80103d:	89 1c 24             	mov    %ebx,(%esp)
  801040:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801044:	b9 00 00 00 00       	mov    $0x0,%ecx
  801049:	b8 0f 00 00 00       	mov    $0xf,%eax
  80104e:	8b 55 08             	mov    0x8(%ebp),%edx
  801051:	89 cb                	mov    %ecx,%ebx
  801053:	89 cf                	mov    %ecx,%edi
  801055:	51                   	push   %ecx
  801056:	52                   	push   %edx
  801057:	53                   	push   %ebx
  801058:	54                   	push   %esp
  801059:	55                   	push   %ebp
  80105a:	56                   	push   %esi
  80105b:	57                   	push   %edi
  80105c:	54                   	push   %esp
  80105d:	5d                   	pop    %ebp
  80105e:	8d 35 66 10 80 00    	lea    0x801066,%esi
  801064:	0f 34                	sysenter 
  801066:	5f                   	pop    %edi
  801067:	5e                   	pop    %esi
  801068:	5d                   	pop    %ebp
  801069:	5c                   	pop    %esp
  80106a:	5b                   	pop    %ebx
  80106b:	5a                   	pop    %edx
  80106c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80106d:	8b 1c 24             	mov    (%esp),%ebx
  801070:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801074:	89 ec                	mov    %ebp,%esp
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 28             	sub    $0x28,%esp
  80107e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801081:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801084:	b9 00 00 00 00       	mov    $0x0,%ecx
  801089:	b8 0d 00 00 00       	mov    $0xd,%eax
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	7e 28                	jle    8010d9 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010bc:	00 
  8010bd:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  8010c4:	00 
  8010c5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010cc:	00 
  8010cd:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  8010d4:	e8 87 f0 ff ff       	call   800160 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010df:	89 ec                	mov    %ebp,%esp
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	83 ec 08             	sub    $0x8,%esp
  8010e9:	89 1c 24             	mov    %ebx,(%esp)
  8010ec:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010f5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801101:	51                   	push   %ecx
  801102:	52                   	push   %edx
  801103:	53                   	push   %ebx
  801104:	54                   	push   %esp
  801105:	55                   	push   %ebp
  801106:	56                   	push   %esi
  801107:	57                   	push   %edi
  801108:	54                   	push   %esp
  801109:	5d                   	pop    %ebp
  80110a:	8d 35 12 11 80 00    	lea    0x801112,%esi
  801110:	0f 34                	sysenter 
  801112:	5f                   	pop    %edi
  801113:	5e                   	pop    %esi
  801114:	5d                   	pop    %ebp
  801115:	5c                   	pop    %esp
  801116:	5b                   	pop    %ebx
  801117:	5a                   	pop    %edx
  801118:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801119:	8b 1c 24             	mov    (%esp),%ebx
  80111c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801120:	89 ec                	mov    %ebp,%esp
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 28             	sub    $0x28,%esp
  80112a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80112d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801130:	bb 00 00 00 00       	mov    $0x0,%ebx
  801135:	b8 0a 00 00 00       	mov    $0xa,%eax
  80113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx
  801140:	89 df                	mov    %ebx,%edi
  801142:	51                   	push   %ecx
  801143:	52                   	push   %edx
  801144:	53                   	push   %ebx
  801145:	54                   	push   %esp
  801146:	55                   	push   %ebp
  801147:	56                   	push   %esi
  801148:	57                   	push   %edi
  801149:	54                   	push   %esp
  80114a:	5d                   	pop    %ebp
  80114b:	8d 35 53 11 80 00    	lea    0x801153,%esi
  801151:	0f 34                	sysenter 
  801153:	5f                   	pop    %edi
  801154:	5e                   	pop    %esi
  801155:	5d                   	pop    %ebp
  801156:	5c                   	pop    %esp
  801157:	5b                   	pop    %ebx
  801158:	5a                   	pop    %edx
  801159:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80115a:	85 c0                	test   %eax,%eax
  80115c:	7e 28                	jle    801186 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801162:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801169:	00 
  80116a:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  801171:	00 
  801172:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801179:	00 
  80117a:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  801181:	e8 da ef ff ff       	call   800160 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801186:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801189:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80118c:	89 ec                	mov    %ebp,%esp
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 28             	sub    $0x28,%esp
  801196:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801199:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80119c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8011a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	89 df                	mov    %ebx,%edi
  8011ae:	51                   	push   %ecx
  8011af:	52                   	push   %edx
  8011b0:	53                   	push   %ebx
  8011b1:	54                   	push   %esp
  8011b2:	55                   	push   %ebp
  8011b3:	56                   	push   %esi
  8011b4:	57                   	push   %edi
  8011b5:	54                   	push   %esp
  8011b6:	5d                   	pop    %ebp
  8011b7:	8d 35 bf 11 80 00    	lea    0x8011bf,%esi
  8011bd:	0f 34                	sysenter 
  8011bf:	5f                   	pop    %edi
  8011c0:	5e                   	pop    %esi
  8011c1:	5d                   	pop    %ebp
  8011c2:	5c                   	pop    %esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5a                   	pop    %edx
  8011c5:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	7e 28                	jle    8011f2 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ce:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011d5:	00 
  8011d6:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  8011dd:	00 
  8011de:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011e5:	00 
  8011e6:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  8011ed:	e8 6e ef ff ff       	call   800160 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011f2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011f8:	89 ec                	mov    %ebp,%esp
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 28             	sub    $0x28,%esp
  801202:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801205:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120d:	b8 07 00 00 00       	mov    $0x7,%eax
  801212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801215:	8b 55 08             	mov    0x8(%ebp),%edx
  801218:	89 df                	mov    %ebx,%edi
  80121a:	51                   	push   %ecx
  80121b:	52                   	push   %edx
  80121c:	53                   	push   %ebx
  80121d:	54                   	push   %esp
  80121e:	55                   	push   %ebp
  80121f:	56                   	push   %esi
  801220:	57                   	push   %edi
  801221:	54                   	push   %esp
  801222:	5d                   	pop    %ebp
  801223:	8d 35 2b 12 80 00    	lea    0x80122b,%esi
  801229:	0f 34                	sysenter 
  80122b:	5f                   	pop    %edi
  80122c:	5e                   	pop    %esi
  80122d:	5d                   	pop    %ebp
  80122e:	5c                   	pop    %esp
  80122f:	5b                   	pop    %ebx
  801230:	5a                   	pop    %edx
  801231:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801232:	85 c0                	test   %eax,%eax
  801234:	7e 28                	jle    80125e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801236:	89 44 24 10          	mov    %eax,0x10(%esp)
  80123a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801241:	00 
  801242:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  801249:	00 
  80124a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801251:	00 
  801252:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  801259:	e8 02 ef ff ff       	call   800160 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80125e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801261:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801264:	89 ec                	mov    %ebp,%esp
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 28             	sub    $0x28,%esp
  80126e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801271:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801274:	8b 7d 18             	mov    0x18(%ebp),%edi
  801277:	0b 7d 14             	or     0x14(%ebp),%edi
  80127a:	b8 06 00 00 00       	mov    $0x6,%eax
  80127f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801285:	8b 55 08             	mov    0x8(%ebp),%edx
  801288:	51                   	push   %ecx
  801289:	52                   	push   %edx
  80128a:	53                   	push   %ebx
  80128b:	54                   	push   %esp
  80128c:	55                   	push   %ebp
  80128d:	56                   	push   %esi
  80128e:	57                   	push   %edi
  80128f:	54                   	push   %esp
  801290:	5d                   	pop    %ebp
  801291:	8d 35 99 12 80 00    	lea    0x801299,%esi
  801297:	0f 34                	sysenter 
  801299:	5f                   	pop    %edi
  80129a:	5e                   	pop    %esi
  80129b:	5d                   	pop    %ebp
  80129c:	5c                   	pop    %esp
  80129d:	5b                   	pop    %ebx
  80129e:	5a                   	pop    %edx
  80129f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	7e 28                	jle    8012cc <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012af:	00 
  8012b0:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  8012b7:	00 
  8012b8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012bf:	00 
  8012c0:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  8012c7:	e8 94 ee ff ff       	call   800160 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8012cc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012cf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012d2:	89 ec                	mov    %ebp,%esp
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 28             	sub    $0x28,%esp
  8012dc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012df:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8012e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8012ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f5:	51                   	push   %ecx
  8012f6:	52                   	push   %edx
  8012f7:	53                   	push   %ebx
  8012f8:	54                   	push   %esp
  8012f9:	55                   	push   %ebp
  8012fa:	56                   	push   %esi
  8012fb:	57                   	push   %edi
  8012fc:	54                   	push   %esp
  8012fd:	5d                   	pop    %ebp
  8012fe:	8d 35 06 13 80 00    	lea    0x801306,%esi
  801304:	0f 34                	sysenter 
  801306:	5f                   	pop    %edi
  801307:	5e                   	pop    %esi
  801308:	5d                   	pop    %ebp
  801309:	5c                   	pop    %esp
  80130a:	5b                   	pop    %ebx
  80130b:	5a                   	pop    %edx
  80130c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80130d:	85 c0                	test   %eax,%eax
  80130f:	7e 28                	jle    801339 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801311:	89 44 24 10          	mov    %eax,0x10(%esp)
  801315:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80131c:	00 
  80131d:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  801324:	00 
  801325:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80132c:	00 
  80132d:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  801334:	e8 27 ee ff ff       	call   800160 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801339:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80133c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80133f:	89 ec                	mov    %ebp,%esp
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	89 1c 24             	mov    %ebx,(%esp)
  80134c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801350:	ba 00 00 00 00       	mov    $0x0,%edx
  801355:	b8 0b 00 00 00       	mov    $0xb,%eax
  80135a:	89 d1                	mov    %edx,%ecx
  80135c:	89 d3                	mov    %edx,%ebx
  80135e:	89 d7                	mov    %edx,%edi
  801360:	51                   	push   %ecx
  801361:	52                   	push   %edx
  801362:	53                   	push   %ebx
  801363:	54                   	push   %esp
  801364:	55                   	push   %ebp
  801365:	56                   	push   %esi
  801366:	57                   	push   %edi
  801367:	54                   	push   %esp
  801368:	5d                   	pop    %ebp
  801369:	8d 35 71 13 80 00    	lea    0x801371,%esi
  80136f:	0f 34                	sysenter 
  801371:	5f                   	pop    %edi
  801372:	5e                   	pop    %esi
  801373:	5d                   	pop    %ebp
  801374:	5c                   	pop    %esp
  801375:	5b                   	pop    %ebx
  801376:	5a                   	pop    %edx
  801377:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801378:	8b 1c 24             	mov    (%esp),%ebx
  80137b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80137f:	89 ec                	mov    %ebp,%esp
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
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
  801390:	bb 00 00 00 00       	mov    $0x0,%ebx
  801395:	b8 04 00 00 00       	mov    $0x4,%eax
  80139a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139d:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a0:	89 df                	mov    %ebx,%edi
  8013a2:	51                   	push   %ecx
  8013a3:	52                   	push   %edx
  8013a4:	53                   	push   %ebx
  8013a5:	54                   	push   %esp
  8013a6:	55                   	push   %ebp
  8013a7:	56                   	push   %esi
  8013a8:	57                   	push   %edi
  8013a9:	54                   	push   %esp
  8013aa:	5d                   	pop    %ebp
  8013ab:	8d 35 b3 13 80 00    	lea    0x8013b3,%esi
  8013b1:	0f 34                	sysenter 
  8013b3:	5f                   	pop    %edi
  8013b4:	5e                   	pop    %esi
  8013b5:	5d                   	pop    %ebp
  8013b6:	5c                   	pop    %esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5a                   	pop    %edx
  8013b9:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8013ba:	8b 1c 24             	mov    (%esp),%ebx
  8013bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013c1:	89 ec                	mov    %ebp,%esp
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	89 1c 24             	mov    %ebx,(%esp)
  8013ce:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d7:	b8 02 00 00 00       	mov    $0x2,%eax
  8013dc:	89 d1                	mov    %edx,%ecx
  8013de:	89 d3                	mov    %edx,%ebx
  8013e0:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013fa:	8b 1c 24             	mov    (%esp),%ebx
  8013fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801401:	89 ec                	mov    %ebp,%esp
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	83 ec 28             	sub    $0x28,%esp
  80140b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80140e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801411:	b9 00 00 00 00       	mov    $0x0,%ecx
  801416:	b8 03 00 00 00       	mov    $0x3,%eax
  80141b:	8b 55 08             	mov    0x8(%ebp),%edx
  80141e:	89 cb                	mov    %ecx,%ebx
  801420:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80143a:	85 c0                	test   %eax,%eax
  80143c:	7e 28                	jle    801466 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80143e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801442:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801449:	00 
  80144a:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  801451:	00 
  801452:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801459:	00 
  80145a:	c7 04 24 e1 1a 80 00 	movl   $0x801ae1,(%esp)
  801461:	e8 fa ec ff ff       	call   800160 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801466:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801469:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80146c:	89 ec                	mov    %ebp,%esp
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801476:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80147d:	75 30                	jne    8014af <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80147f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801486:	00 
  801487:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80148e:	ee 
  80148f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801496:	e8 3b fe ff ff       	call   8012d6 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80149b:	c7 44 24 04 bc 14 80 	movl   $0x8014bc,0x4(%esp)
  8014a2:	00 
  8014a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014aa:	e8 75 fc ff ff       	call   801124 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014af:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b2:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    
  8014b9:	00 00                	add    %al,(%eax)
	...

008014bc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014bc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014bd:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8014c2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014c4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8014c7:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8014cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8014cf:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8014d2:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8014d4:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8014d8:	83 c4 08             	add    $0x8,%esp
        popal
  8014db:	61                   	popa   
        addl $0x4,%esp
  8014dc:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8014df:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8014e0:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8014e1:	c3                   	ret    
	...

008014f0 <__udivdi3>:
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	57                   	push   %edi
  8014f4:	56                   	push   %esi
  8014f5:	83 ec 10             	sub    $0x10,%esp
  8014f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fe:	8b 75 10             	mov    0x10(%ebp),%esi
  801501:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801504:	85 c0                	test   %eax,%eax
  801506:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801509:	75 35                	jne    801540 <__udivdi3+0x50>
  80150b:	39 fe                	cmp    %edi,%esi
  80150d:	77 61                	ja     801570 <__udivdi3+0x80>
  80150f:	85 f6                	test   %esi,%esi
  801511:	75 0b                	jne    80151e <__udivdi3+0x2e>
  801513:	b8 01 00 00 00       	mov    $0x1,%eax
  801518:	31 d2                	xor    %edx,%edx
  80151a:	f7 f6                	div    %esi
  80151c:	89 c6                	mov    %eax,%esi
  80151e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801521:	31 d2                	xor    %edx,%edx
  801523:	89 f8                	mov    %edi,%eax
  801525:	f7 f6                	div    %esi
  801527:	89 c7                	mov    %eax,%edi
  801529:	89 c8                	mov    %ecx,%eax
  80152b:	f7 f6                	div    %esi
  80152d:	89 c1                	mov    %eax,%ecx
  80152f:	89 fa                	mov    %edi,%edx
  801531:	89 c8                	mov    %ecx,%eax
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	5e                   	pop    %esi
  801537:	5f                   	pop    %edi
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    
  80153a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801540:	39 f8                	cmp    %edi,%eax
  801542:	77 1c                	ja     801560 <__udivdi3+0x70>
  801544:	0f bd d0             	bsr    %eax,%edx
  801547:	83 f2 1f             	xor    $0x1f,%edx
  80154a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80154d:	75 39                	jne    801588 <__udivdi3+0x98>
  80154f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801552:	0f 86 a0 00 00 00    	jbe    8015f8 <__udivdi3+0x108>
  801558:	39 f8                	cmp    %edi,%eax
  80155a:	0f 82 98 00 00 00    	jb     8015f8 <__udivdi3+0x108>
  801560:	31 ff                	xor    %edi,%edi
  801562:	31 c9                	xor    %ecx,%ecx
  801564:	89 c8                	mov    %ecx,%eax
  801566:	89 fa                	mov    %edi,%edx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	5e                   	pop    %esi
  80156c:	5f                   	pop    %edi
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    
  80156f:	90                   	nop
  801570:	89 d1                	mov    %edx,%ecx
  801572:	89 fa                	mov    %edi,%edx
  801574:	89 c8                	mov    %ecx,%eax
  801576:	31 ff                	xor    %edi,%edi
  801578:	f7 f6                	div    %esi
  80157a:	89 c1                	mov    %eax,%ecx
  80157c:	89 fa                	mov    %edi,%edx
  80157e:	89 c8                	mov    %ecx,%eax
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	5e                   	pop    %esi
  801584:	5f                   	pop    %edi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    
  801587:	90                   	nop
  801588:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80158c:	89 f2                	mov    %esi,%edx
  80158e:	d3 e0                	shl    %cl,%eax
  801590:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801593:	b8 20 00 00 00       	mov    $0x20,%eax
  801598:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80159b:	89 c1                	mov    %eax,%ecx
  80159d:	d3 ea                	shr    %cl,%edx
  80159f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8015a6:	d3 e6                	shl    %cl,%esi
  8015a8:	89 c1                	mov    %eax,%ecx
  8015aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8015ad:	89 fe                	mov    %edi,%esi
  8015af:	d3 ee                	shr    %cl,%esi
  8015b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015bb:	d3 e7                	shl    %cl,%edi
  8015bd:	89 c1                	mov    %eax,%ecx
  8015bf:	d3 ea                	shr    %cl,%edx
  8015c1:	09 d7                	or     %edx,%edi
  8015c3:	89 f2                	mov    %esi,%edx
  8015c5:	89 f8                	mov    %edi,%eax
  8015c7:	f7 75 ec             	divl   -0x14(%ebp)
  8015ca:	89 d6                	mov    %edx,%esi
  8015cc:	89 c7                	mov    %eax,%edi
  8015ce:	f7 65 e8             	mull   -0x18(%ebp)
  8015d1:	39 d6                	cmp    %edx,%esi
  8015d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015d6:	72 30                	jb     801608 <__udivdi3+0x118>
  8015d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015df:	d3 e2                	shl    %cl,%edx
  8015e1:	39 c2                	cmp    %eax,%edx
  8015e3:	73 05                	jae    8015ea <__udivdi3+0xfa>
  8015e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8015e8:	74 1e                	je     801608 <__udivdi3+0x118>
  8015ea:	89 f9                	mov    %edi,%ecx
  8015ec:	31 ff                	xor    %edi,%edi
  8015ee:	e9 71 ff ff ff       	jmp    801564 <__udivdi3+0x74>
  8015f3:	90                   	nop
  8015f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015f8:	31 ff                	xor    %edi,%edi
  8015fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8015ff:	e9 60 ff ff ff       	jmp    801564 <__udivdi3+0x74>
  801604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801608:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80160b:	31 ff                	xor    %edi,%edi
  80160d:	89 c8                	mov    %ecx,%eax
  80160f:	89 fa                	mov    %edi,%edx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	5e                   	pop    %esi
  801615:	5f                   	pop    %edi
  801616:	5d                   	pop    %ebp
  801617:	c3                   	ret    
	...

00801620 <__umoddi3>:
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	56                   	push   %esi
  801625:	83 ec 20             	sub    $0x20,%esp
  801628:	8b 55 14             	mov    0x14(%ebp),%edx
  80162b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801631:	8b 75 0c             	mov    0xc(%ebp),%esi
  801634:	85 d2                	test   %edx,%edx
  801636:	89 c8                	mov    %ecx,%eax
  801638:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80163b:	75 13                	jne    801650 <__umoddi3+0x30>
  80163d:	39 f7                	cmp    %esi,%edi
  80163f:	76 3f                	jbe    801680 <__umoddi3+0x60>
  801641:	89 f2                	mov    %esi,%edx
  801643:	f7 f7                	div    %edi
  801645:	89 d0                	mov    %edx,%eax
  801647:	31 d2                	xor    %edx,%edx
  801649:	83 c4 20             	add    $0x20,%esp
  80164c:	5e                   	pop    %esi
  80164d:	5f                   	pop    %edi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    
  801650:	39 f2                	cmp    %esi,%edx
  801652:	77 4c                	ja     8016a0 <__umoddi3+0x80>
  801654:	0f bd ca             	bsr    %edx,%ecx
  801657:	83 f1 1f             	xor    $0x1f,%ecx
  80165a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80165d:	75 51                	jne    8016b0 <__umoddi3+0x90>
  80165f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801662:	0f 87 e0 00 00 00    	ja     801748 <__umoddi3+0x128>
  801668:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166b:	29 f8                	sub    %edi,%eax
  80166d:	19 d6                	sbb    %edx,%esi
  80166f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801675:	89 f2                	mov    %esi,%edx
  801677:	83 c4 20             	add    $0x20,%esp
  80167a:	5e                   	pop    %esi
  80167b:	5f                   	pop    %edi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    
  80167e:	66 90                	xchg   %ax,%ax
  801680:	85 ff                	test   %edi,%edi
  801682:	75 0b                	jne    80168f <__umoddi3+0x6f>
  801684:	b8 01 00 00 00       	mov    $0x1,%eax
  801689:	31 d2                	xor    %edx,%edx
  80168b:	f7 f7                	div    %edi
  80168d:	89 c7                	mov    %eax,%edi
  80168f:	89 f0                	mov    %esi,%eax
  801691:	31 d2                	xor    %edx,%edx
  801693:	f7 f7                	div    %edi
  801695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801698:	f7 f7                	div    %edi
  80169a:	eb a9                	jmp    801645 <__umoddi3+0x25>
  80169c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016a0:	89 c8                	mov    %ecx,%eax
  8016a2:	89 f2                	mov    %esi,%edx
  8016a4:	83 c4 20             	add    $0x20,%esp
  8016a7:	5e                   	pop    %esi
  8016a8:	5f                   	pop    %edi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    
  8016ab:	90                   	nop
  8016ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016b4:	d3 e2                	shl    %cl,%edx
  8016b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8016be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8016c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8016c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016c8:	89 fa                	mov    %edi,%edx
  8016ca:	d3 ea                	shr    %cl,%edx
  8016cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8016d3:	d3 e7                	shl    %cl,%edi
  8016d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016dc:	89 f2                	mov    %esi,%edx
  8016de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8016e1:	89 c7                	mov    %eax,%edi
  8016e3:	d3 ea                	shr    %cl,%edx
  8016e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	d3 e6                	shl    %cl,%esi
  8016f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016f4:	d3 ea                	shr    %cl,%edx
  8016f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016fa:	09 d6                	or     %edx,%esi
  8016fc:	89 f0                	mov    %esi,%eax
  8016fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801701:	d3 e7                	shl    %cl,%edi
  801703:	89 f2                	mov    %esi,%edx
  801705:	f7 75 f4             	divl   -0xc(%ebp)
  801708:	89 d6                	mov    %edx,%esi
  80170a:	f7 65 e8             	mull   -0x18(%ebp)
  80170d:	39 d6                	cmp    %edx,%esi
  80170f:	72 2b                	jb     80173c <__umoddi3+0x11c>
  801711:	39 c7                	cmp    %eax,%edi
  801713:	72 23                	jb     801738 <__umoddi3+0x118>
  801715:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801719:	29 c7                	sub    %eax,%edi
  80171b:	19 d6                	sbb    %edx,%esi
  80171d:	89 f0                	mov    %esi,%eax
  80171f:	89 f2                	mov    %esi,%edx
  801721:	d3 ef                	shr    %cl,%edi
  801723:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801727:	d3 e0                	shl    %cl,%eax
  801729:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80172d:	09 f8                	or     %edi,%eax
  80172f:	d3 ea                	shr    %cl,%edx
  801731:	83 c4 20             	add    $0x20,%esp
  801734:	5e                   	pop    %esi
  801735:	5f                   	pop    %edi
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    
  801738:	39 d6                	cmp    %edx,%esi
  80173a:	75 d9                	jne    801715 <__umoddi3+0xf5>
  80173c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80173f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801742:	eb d1                	jmp    801715 <__umoddi3+0xf5>
  801744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801748:	39 f2                	cmp    %esi,%edx
  80174a:	0f 82 18 ff ff ff    	jb     801668 <__umoddi3+0x48>
  801750:	e9 1d ff ff ff       	jmp    801672 <__umoddi3+0x52>
