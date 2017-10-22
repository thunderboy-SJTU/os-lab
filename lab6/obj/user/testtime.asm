
obj/user/testtime.debug:     file format elf32-i386


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
  80002c:	e8 df 00 00 00       	call   800110 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	unsigned now = sys_time_msec();
  800047:	e8 01 11 00 00       	call   80114d <sys_time_msec>
	unsigned end = now + sec * 1000;

	if ((int)now < 0 && (int)now > -MAXERROR)
  80004c:	85 c0                	test   %eax,%eax
  80004e:	79 25                	jns    800075 <sleep+0x35>
  800050:	83 f8 f1             	cmp    $0xfffffff1,%eax
  800053:	7c 20                	jl     800075 <sleep+0x35>
		panic("sys_time_msec: %e", (int)now);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 20 28 80 	movl   $0x802820,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 32 28 80 00 	movl   $0x802832,(%esp)
  800070:	e8 0b 01 00 00       	call   800180 <_panic>

void
sleep(int sec)
{
	unsigned now = sys_time_msec();
	unsigned end = now + sec * 1000;
  800075:	69 5d 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%ebx

	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
  80007c:	01 c3                	add    %eax,%ebx
  80007e:	73 21                	jae    8000a1 <sleep+0x61>
		panic("sleep: wrap");
  800080:	c7 44 24 08 42 28 80 	movl   $0x802842,0x8(%esp)
  800087:	00 
  800088:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80008f:	00 
  800090:	c7 04 24 32 28 80 00 	movl   $0x802832,(%esp)
  800097:	e8 e4 00 00 00       	call   800180 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  80009c:	e8 64 14 00 00       	call   801505 <sys_yield>
	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
		panic("sleep: wrap");

	while (sys_time_msec() < end)
  8000a1:	e8 a7 10 00 00       	call   80114d <sys_time_msec>
  8000a6:	39 c3                	cmp    %eax,%ebx
  8000a8:	77 f2                	ja     80009c <sleep+0x5c>
		sys_yield();
}
  8000aa:	83 c4 14             	add    $0x14,%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5d                   	pop    %ebp
  8000af:	90                   	nop
  8000b0:	c3                   	ret    

008000b1 <umain>:

void
umain(int argc, char **argv)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 14             	sub    $0x14,%esp
  8000b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  8000bd:	e8 43 14 00 00       	call   801505 <sys_yield>
umain(int argc, char **argv)
{
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
  8000c2:	83 c3 01             	add    $0x1,%ebx
  8000c5:	83 fb 32             	cmp    $0x32,%ebx
  8000c8:	75 f3                	jne    8000bd <umain+0xc>
		sys_yield();

	cprintf("starting count down: ");
  8000ca:	c7 04 24 4e 28 80 00 	movl   $0x80284e,(%esp)
  8000d1:	e8 63 01 00 00       	call   800239 <cprintf>
  8000d6:	b3 05                	mov    $0x5,%bl
	for (i = 5; i >= 0; i--) {
		cprintf("%d ", i);
  8000d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000dc:	c7 04 24 64 28 80 00 	movl   $0x802864,(%esp)
  8000e3:	e8 51 01 00 00       	call   800239 <cprintf>
		sleep(1);
  8000e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ef:	e8 4c ff ff ff       	call   800040 <sleep>
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();

	cprintf("starting count down: ");
	for (i = 5; i >= 0; i--) {
  8000f4:	83 eb 01             	sub    $0x1,%ebx
  8000f7:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000fa:	75 dc                	jne    8000d8 <umain+0x27>
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("\n");
  8000fc:	c7 04 24 c7 2c 80 00 	movl   $0x802cc7,(%esp)
  800103:	e8 31 01 00 00       	call   800239 <cprintf>
static __inline void wrmsr(unsigned msr, unsigned low, unsigned high) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800108:	cc                   	int3   
	breakpoint();
}
  800109:	83 c4 14             	add    $0x14,%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
	...

00800110 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 18             	sub    $0x18,%esp
  800116:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800119:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80011c:	8b 75 08             	mov    0x8(%ebp),%esi
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800122:	e8 60 14 00 00       	call   801587 <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	89 c2                	mov    %eax,%edx
  80012e:	c1 e2 07             	shl    $0x7,%edx
  800131:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800138:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013d:	85 f6                	test   %esi,%esi
  80013f:	7e 07                	jle    800148 <libmain+0x38>
		binaryname = argv[0];
  800141:	8b 03                	mov    (%ebx),%eax
  800143:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800148:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80014c:	89 34 24             	mov    %esi,(%esp)
  80014f:	e8 5d ff ff ff       	call   8000b1 <umain>

	// exit gracefully
	exit();
  800154:	e8 0b 00 00 00       	call   800164 <exit>
}
  800159:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80015c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80015f:	89 ec                	mov    %ebp,%esp
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    
	...

00800164 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80016a:	e8 ac 19 00 00       	call   801b1b <close_all>
	sys_env_destroy(0);
  80016f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800176:	e8 4c 14 00 00       	call   8015c7 <sys_env_destroy>
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    
  80017d:	00 00                	add    %al,(%eax)
	...

00800180 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800188:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800191:	e8 f1 13 00 00       	call   801587 <sys_getenvid>
  800196:	8b 55 0c             	mov    0xc(%ebp),%edx
  800199:	89 54 24 10          	mov    %edx,0x10(%esp)
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ac:	c7 04 24 74 28 80 00 	movl   $0x802874,(%esp)
  8001b3:	e8 81 00 00 00       	call   800239 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 11 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 c7 2c 80 00 	movl   $0x802cc7,(%esp)
  8001ce:	e8 66 00 00 00       	call   800239 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d3:	cc                   	int3   
  8001d4:	eb fd                	jmp    8001d3 <_panic+0x53>
	...

008001d8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	c7 04 24 53 02 80 00 	movl   $0x800253,(%esp)
  800214:	e8 d3 01 00 00       	call   8003ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800219:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 6b 0d 00 00       	call   800f9c <sys_cputs>

	return b.cnt;
}
  800231:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80023f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 87 ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	53                   	push   %ebx
  800257:	83 ec 14             	sub    $0x14,%esp
  80025a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025d:	8b 03                	mov    (%ebx),%eax
  80025f:	8b 55 08             	mov    0x8(%ebp),%edx
  800262:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800266:	83 c0 01             	add    $0x1,%eax
  800269:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80026b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800270:	75 19                	jne    80028b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800272:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800279:	00 
  80027a:	8d 43 08             	lea    0x8(%ebx),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	e8 17 0d 00 00       	call   800f9c <sys_cputs>
		b->idx = 0;
  800285:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80028b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80028f:	83 c4 14             	add    $0x14,%esp
  800292:	5b                   	pop    %ebx
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    
	...

008002a0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 4c             	sub    $0x4c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d6                	mov    %edx,%esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8002c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002cb:	39 d1                	cmp    %edx,%ecx
  8002cd:	72 07                	jb     8002d6 <printnum_v2+0x36>
  8002cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d2:	39 d0                	cmp    %edx,%eax
  8002d4:	77 5f                	ja     800335 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8002d6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002da:	83 eb 01             	sub    $0x1,%ebx
  8002dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002e9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002ed:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002f0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800301:	00 
  800302:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80030b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030f:	e8 8c 22 00 00       	call   8025a0 <__udivdi3>
  800314:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800317:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80031a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	89 54 24 04          	mov    %edx,0x4(%esp)
  800329:	89 f2                	mov    %esi,%edx
  80032b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032e:	e8 6d ff ff ff       	call   8002a0 <printnum_v2>
  800333:	eb 1e                	jmp    800353 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800335:	83 ff 2d             	cmp    $0x2d,%edi
  800338:	74 19                	je     800353 <printnum_v2+0xb3>
		while (--width > 0)
  80033a:	83 eb 01             	sub    $0x1,%ebx
  80033d:	85 db                	test   %ebx,%ebx
  80033f:	90                   	nop
  800340:	7e 11                	jle    800353 <printnum_v2+0xb3>
			putch(padc, putdat);
  800342:	89 74 24 04          	mov    %esi,0x4(%esp)
  800346:	89 3c 24             	mov    %edi,(%esp)
  800349:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80034c:	83 eb 01             	sub    $0x1,%ebx
  80034f:	85 db                	test   %ebx,%ebx
  800351:	7f ef                	jg     800342 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800353:	89 74 24 04          	mov    %esi,0x4(%esp)
  800357:	8b 74 24 04          	mov    0x4(%esp),%esi
  80035b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800362:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800369:	00 
  80036a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80036d:	89 14 24             	mov    %edx,(%esp)
  800370:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800373:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800377:	e8 54 23 00 00       	call   8026d0 <__umoddi3>
  80037c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800380:	0f be 80 97 28 80 00 	movsbl 0x802897(%eax),%eax
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80038d:	83 c4 4c             	add    $0x4c,%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800398:	83 fa 01             	cmp    $0x1,%edx
  80039b:	7e 0e                	jle    8003ab <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	8b 52 04             	mov    0x4(%edx),%edx
  8003a9:	eb 22                	jmp    8003cd <getuint+0x38>
	else if (lflag)
  8003ab:	85 d2                	test   %edx,%edx
  8003ad:	74 10                	je     8003bf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bd:	eb 0e                	jmp    8003cd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 0a                	jae    8003ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	88 0a                	mov    %cl,(%edx)
  8003e5:	83 c2 01             	add    $0x1,%edx
  8003e8:	89 10                	mov    %edx,(%eax)
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	83 ec 6c             	sub    $0x6c,%esp
  8003f5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003f8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003ff:	eb 1a                	jmp    80041b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800401:	85 c0                	test   %eax,%eax
  800403:	0f 84 66 06 00 00    	je     800a6f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800409:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	ff 55 08             	call   *0x8(%ebp)
  800416:	eb 03                	jmp    80041b <vprintfmt+0x2f>
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	0f b6 07             	movzbl (%edi),%eax
  80041e:	83 c7 01             	add    $0x1,%edi
  800421:	83 f8 25             	cmp    $0x25,%eax
  800424:	75 db                	jne    800401 <vprintfmt+0x15>
  800426:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80042a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800436:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80043b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800442:	be 00 00 00 00       	mov    $0x0,%esi
  800447:	eb 06                	jmp    80044f <vprintfmt+0x63>
  800449:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80044d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	0f b6 17             	movzbl (%edi),%edx
  800452:	0f b6 c2             	movzbl %dl,%eax
  800455:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800458:	8d 47 01             	lea    0x1(%edi),%eax
  80045b:	83 ea 23             	sub    $0x23,%edx
  80045e:	80 fa 55             	cmp    $0x55,%dl
  800461:	0f 87 60 05 00 00    	ja     8009c7 <vprintfmt+0x5db>
  800467:	0f b6 d2             	movzbl %dl,%edx
  80046a:	ff 24 95 80 2a 80 00 	jmp    *0x802a80(,%edx,4)
  800471:	b9 01 00 00 00       	mov    $0x1,%ecx
  800476:	eb d5                	jmp    80044d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800478:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80047b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80047e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800481:	8d 7a d0             	lea    -0x30(%edx),%edi
  800484:	83 ff 09             	cmp    $0x9,%edi
  800487:	76 08                	jbe    800491 <vprintfmt+0xa5>
  800489:	eb 40                	jmp    8004cb <vprintfmt+0xdf>
  80048b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80048f:	eb bc                	jmp    80044d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800491:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800494:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800497:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80049b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80049e:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004a1:	83 ff 09             	cmp    $0x9,%edi
  8004a4:	76 eb                	jbe    800491 <vprintfmt+0xa5>
  8004a6:	eb 23                	jmp    8004cb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ab:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004ae:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004b1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8004b3:	eb 16                	jmp    8004cb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8004b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004b8:	c1 fa 1f             	sar    $0x1f,%edx
  8004bb:	f7 d2                	not    %edx
  8004bd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8004c0:	eb 8b                	jmp    80044d <vprintfmt+0x61>
  8004c2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004c9:	eb 82                	jmp    80044d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8004cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cf:	0f 89 78 ff ff ff    	jns    80044d <vprintfmt+0x61>
  8004d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004d8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8004db:	e9 6d ff ff ff       	jmp    80044d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8004e3:	e9 65 ff ff ff       	jmp    80044d <vprintfmt+0x61>
  8004e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 50 04             	lea    0x4(%eax),%edx
  8004f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 04 24             	mov    %eax,(%esp)
  800500:	ff 55 08             	call   *0x8(%ebp)
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800506:	e9 10 ff ff ff       	jmp    80041b <vprintfmt+0x2f>
  80050b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 04             	lea    0x4(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 c2                	mov    %eax,%edx
  80051b:	c1 fa 1f             	sar    $0x1f,%edx
  80051e:	31 d0                	xor    %edx,%eax
  800520:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800522:	83 f8 0f             	cmp    $0xf,%eax
  800525:	7f 0b                	jg     800532 <vprintfmt+0x146>
  800527:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	75 26                	jne    800558 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800532:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800536:	c7 44 24 08 a8 28 80 	movl   $0x8028a8,0x8(%esp)
  80053d:	00 
  80053e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800541:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800545:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800548:	89 1c 24             	mov    %ebx,(%esp)
  80054b:	e8 a7 05 00 00       	call   800af7 <printfmt>
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800553:	e9 c3 fe ff ff       	jmp    80041b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800558:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055c:	c7 44 24 08 02 2d 80 	movl   $0x802d02,0x8(%esp)
  800563:	00 
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056b:	8b 55 08             	mov    0x8(%ebp),%edx
  80056e:	89 14 24             	mov    %edx,(%esp)
  800571:	e8 81 05 00 00       	call   800af7 <printfmt>
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800579:	e9 9d fe ff ff       	jmp    80041b <vprintfmt+0x2f>
  80057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800581:	89 c7                	mov    %eax,%edi
  800583:	89 d9                	mov    %ebx,%ecx
  800585:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800588:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 30                	mov    (%eax),%esi
  800596:	85 f6                	test   %esi,%esi
  800598:	75 05                	jne    80059f <vprintfmt+0x1b3>
  80059a:	be b1 28 80 00       	mov    $0x8028b1,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80059f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005a3:	7e 06                	jle    8005ab <vprintfmt+0x1bf>
  8005a5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8005a9:	75 10                	jne    8005bb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ab:	0f be 06             	movsbl (%esi),%eax
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	0f 85 a2 00 00 00    	jne    800658 <vprintfmt+0x26c>
  8005b6:	e9 92 00 00 00       	jmp    80064d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005bf:	89 34 24             	mov    %esi,(%esp)
  8005c2:	e8 74 05 00 00       	call   800b3b <strnlen>
  8005c7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005ca:	29 c2                	sub    %eax,%edx
  8005cc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	7e d8                	jle    8005ab <vprintfmt+0x1bf>
					putch(padc, putdat);
  8005d3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8005d7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005da:	89 d3                	mov    %edx,%ebx
  8005dc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005df:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8005e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005e5:	89 ce                	mov    %ecx,%esi
  8005e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005eb:	89 34 24             	mov    %esi,(%esp)
  8005ee:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 eb 01             	sub    $0x1,%ebx
  8005f4:	85 db                	test   %ebx,%ebx
  8005f6:	7f ef                	jg     8005e7 <vprintfmt+0x1fb>
  8005f8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005fb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005fe:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800601:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800608:	eb a1                	jmp    8005ab <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80060e:	74 1b                	je     80062b <vprintfmt+0x23f>
  800610:	8d 50 e0             	lea    -0x20(%eax),%edx
  800613:	83 fa 5e             	cmp    $0x5e,%edx
  800616:	76 13                	jbe    80062b <vprintfmt+0x23f>
					putch('?', putdat);
  800618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800626:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800629:	eb 0d                	jmp    800638 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80062b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800632:	89 04 24             	mov    %eax,(%esp)
  800635:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800638:	83 ef 01             	sub    $0x1,%edi
  80063b:	0f be 06             	movsbl (%esi),%eax
  80063e:	85 c0                	test   %eax,%eax
  800640:	74 05                	je     800647 <vprintfmt+0x25b>
  800642:	83 c6 01             	add    $0x1,%esi
  800645:	eb 1a                	jmp    800661 <vprintfmt+0x275>
  800647:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80064a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800651:	7f 1f                	jg     800672 <vprintfmt+0x286>
  800653:	e9 c0 fd ff ff       	jmp    800418 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800658:	83 c6 01             	add    $0x1,%esi
  80065b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80065e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800661:	85 db                	test   %ebx,%ebx
  800663:	78 a5                	js     80060a <vprintfmt+0x21e>
  800665:	83 eb 01             	sub    $0x1,%ebx
  800668:	79 a0                	jns    80060a <vprintfmt+0x21e>
  80066a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80066d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800670:	eb db                	jmp    80064d <vprintfmt+0x261>
  800672:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800675:	8b 75 0c             	mov    0xc(%ebp),%esi
  800678:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80067b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800682:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800689:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068b:	83 eb 01             	sub    $0x1,%ebx
  80068e:	85 db                	test   %ebx,%ebx
  800690:	7f ec                	jg     80067e <vprintfmt+0x292>
  800692:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800695:	e9 81 fd ff ff       	jmp    80041b <vprintfmt+0x2f>
  80069a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069d:	83 fe 01             	cmp    $0x1,%esi
  8006a0:	7e 10                	jle    8006b2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 08             	lea    0x8(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 18                	mov    (%eax),%ebx
  8006ad:	8b 70 04             	mov    0x4(%eax),%esi
  8006b0:	eb 26                	jmp    8006d8 <vprintfmt+0x2ec>
	else if (lflag)
  8006b2:	85 f6                	test   %esi,%esi
  8006b4:	74 12                	je     8006c8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 50 04             	lea    0x4(%eax),%edx
  8006bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bf:	8b 18                	mov    (%eax),%ebx
  8006c1:	89 de                	mov    %ebx,%esi
  8006c3:	c1 fe 1f             	sar    $0x1f,%esi
  8006c6:	eb 10                	jmp    8006d8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d1:	8b 18                	mov    (%eax),%ebx
  8006d3:	89 de                	mov    %ebx,%esi
  8006d5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8006d8:	83 f9 01             	cmp    $0x1,%ecx
  8006db:	75 1e                	jne    8006fb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8006dd:	85 f6                	test   %esi,%esi
  8006df:	78 1a                	js     8006fb <vprintfmt+0x30f>
  8006e1:	85 f6                	test   %esi,%esi
  8006e3:	7f 05                	jg     8006ea <vprintfmt+0x2fe>
  8006e5:	83 fb 00             	cmp    $0x0,%ebx
  8006e8:	76 11                	jbe    8006fb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8006ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006f1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8006f8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8006fb:	85 f6                	test   %esi,%esi
  8006fd:	78 13                	js     800712 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ff:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800702:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800708:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070d:	e9 da 00 00 00       	jmp    8007ec <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800712:	8b 45 0c             	mov    0xc(%ebp),%eax
  800715:	89 44 24 04          	mov    %eax,0x4(%esp)
  800719:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800720:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800723:	89 da                	mov    %ebx,%edx
  800725:	89 f1                	mov    %esi,%ecx
  800727:	f7 da                	neg    %edx
  800729:	83 d1 00             	adc    $0x0,%ecx
  80072c:	f7 d9                	neg    %ecx
  80072e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800731:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800737:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073c:	e9 ab 00 00 00       	jmp    8007ec <vprintfmt+0x400>
  800741:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	89 f2                	mov    %esi,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 47 fc ff ff       	call   800395 <getuint>
  80074e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800751:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800754:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800757:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80075c:	e9 8b 00 00 00       	jmp    8007ec <vprintfmt+0x400>
  800761:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800767:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80076b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800772:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800775:	89 f2                	mov    %esi,%edx
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
  80077a:	e8 16 fc ff ff       	call   800395 <getuint>
  80077f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800782:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800788:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80078d:	eb 5d                	jmp    8007ec <vprintfmt+0x400>
  80078f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800795:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800799:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ae:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8d 50 04             	lea    0x4(%eax),%edx
  8007b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ba:	8b 10                	mov    (%eax),%edx
  8007bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007c4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ca:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cf:	eb 1b                	jmp    8007ec <vprintfmt+0x400>
  8007d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d4:	89 f2                	mov    %esi,%edx
  8007d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d9:	e8 b7 fb ff ff       	call   800395 <getuint>
  8007de:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007e1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ec:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8007f0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8007f6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8007fa:	77 09                	ja     800805 <vprintfmt+0x419>
  8007fc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8007ff:	0f 82 ac 00 00 00    	jb     8008b1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800805:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800808:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80080c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80080f:	83 ea 01             	sub    $0x1,%edx
  800812:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800816:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80081e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800822:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800825:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800828:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80082b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80082f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800836:	00 
  800837:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80083a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80083d:	89 0c 24             	mov    %ecx,(%esp)
  800840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800844:	e8 57 1d 00 00       	call   8025a0 <__udivdi3>
  800849:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80084c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80084f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800853:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	e8 37 fa ff ff       	call   8002a0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800870:	8b 74 24 04          	mov    0x4(%esp),%esi
  800874:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800877:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800882:	00 
  800883:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800886:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800889:	89 14 24             	mov    %edx,(%esp)
  80088c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800890:	e8 3b 1e 00 00       	call   8026d0 <__umoddi3>
  800895:	89 74 24 04          	mov    %esi,0x4(%esp)
  800899:	0f be 80 97 28 80 00 	movsbl 0x802897(%eax),%eax
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8008a6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008aa:	74 54                	je     800900 <vprintfmt+0x514>
  8008ac:	e9 67 fb ff ff       	jmp    800418 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8008b1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008b5:	8d 76 00             	lea    0x0(%esi),%esi
  8008b8:	0f 84 2a 01 00 00    	je     8009e8 <vprintfmt+0x5fc>
		while (--width > 0)
  8008be:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008c1:	83 ef 01             	sub    $0x1,%edi
  8008c4:	85 ff                	test   %edi,%edi
  8008c6:	0f 8e 5e 01 00 00    	jle    800a2a <vprintfmt+0x63e>
  8008cc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008cf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008d2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8008d5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8008d8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008db:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8008de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8008e8:	83 ef 01             	sub    $0x1,%edi
  8008eb:	85 ff                	test   %edi,%edi
  8008ed:	7f ef                	jg     8008de <vprintfmt+0x4f2>
  8008ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008f5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8008f8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8008fb:	e9 2a 01 00 00       	jmp    800a2a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800900:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800903:	83 eb 01             	sub    $0x1,%ebx
  800906:	85 db                	test   %ebx,%ebx
  800908:	0f 8e 0a fb ff ff    	jle    800418 <vprintfmt+0x2c>
  80090e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800911:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800914:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800917:	89 74 24 04          	mov    %esi,0x4(%esp)
  80091b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800922:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800924:	83 eb 01             	sub    $0x1,%ebx
  800927:	85 db                	test   %ebx,%ebx
  800929:	7f ec                	jg     800917 <vprintfmt+0x52b>
  80092b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80092e:	e9 e8 fa ff ff       	jmp    80041b <vprintfmt+0x2f>
  800933:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800936:	8b 45 14             	mov    0x14(%ebp),%eax
  800939:	8d 50 04             	lea    0x4(%eax),%edx
  80093c:	89 55 14             	mov    %edx,0x14(%ebp)
  80093f:	8b 00                	mov    (%eax),%eax
  800941:	85 c0                	test   %eax,%eax
  800943:	75 2a                	jne    80096f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800945:	c7 44 24 0c cc 29 80 	movl   $0x8029cc,0xc(%esp)
  80094c:	00 
  80094d:	c7 44 24 08 02 2d 80 	movl   $0x802d02,0x8(%esp)
  800954:	00 
  800955:	8b 55 0c             	mov    0xc(%ebp),%edx
  800958:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	89 0c 24             	mov    %ecx,(%esp)
  800962:	e8 90 01 00 00       	call   800af7 <printfmt>
  800967:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096a:	e9 ac fa ff ff       	jmp    80041b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80096f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800972:	8b 13                	mov    (%ebx),%edx
  800974:	83 fa 7f             	cmp    $0x7f,%edx
  800977:	7e 29                	jle    8009a2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800979:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80097b:	c7 44 24 0c 04 2a 80 	movl   $0x802a04,0xc(%esp)
  800982:	00 
  800983:	c7 44 24 08 02 2d 80 	movl   $0x802d02,0x8(%esp)
  80098a:	00 
  80098b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	89 04 24             	mov    %eax,(%esp)
  800995:	e8 5d 01 00 00       	call   800af7 <printfmt>
  80099a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80099d:	e9 79 fa ff ff       	jmp    80041b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8009a2:	88 10                	mov    %dl,(%eax)
  8009a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a7:	e9 6f fa ff ff       	jmp    80041b <vprintfmt+0x2f>
  8009ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009b9:	89 14 24             	mov    %edx,(%esp)
  8009bc:	ff 55 08             	call   *0x8(%ebp)
  8009bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8009c2:	e9 54 fa ff ff       	jmp    80041b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009d5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8009db:	80 38 25             	cmpb   $0x25,(%eax)
  8009de:	0f 84 37 fa ff ff    	je     80041b <vprintfmt+0x2f>
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	eb f0                	jmp    8009d8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ef:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009f3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a01:	00 
  800a02:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a05:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a0f:	e8 bc 1c 00 00       	call   8026d0 <__umoddi3>
  800a14:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a18:	0f be 80 97 28 80 00 	movsbl 0x802897(%eax),%eax
  800a1f:	89 04 24             	mov    %eax,(%esp)
  800a22:	ff 55 08             	call   *0x8(%ebp)
  800a25:	e9 d6 fe ff ff       	jmp    800900 <vprintfmt+0x514>
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a31:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a35:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a3c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a43:	00 
  800a44:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a47:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a4a:	89 04 24             	mov    %eax,(%esp)
  800a4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a51:	e8 7a 1c 00 00       	call   8026d0 <__umoddi3>
  800a56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a5a:	0f be 80 97 28 80 00 	movsbl 0x802897(%eax),%eax
  800a61:	89 04 24             	mov    %eax,(%esp)
  800a64:	ff 55 08             	call   *0x8(%ebp)
  800a67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a6a:	e9 ac f9 ff ff       	jmp    80041b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a6f:	83 c4 6c             	add    $0x6c,%esp
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	83 ec 28             	sub    $0x28,%esp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a83:	85 c0                	test   %eax,%eax
  800a85:	74 04                	je     800a8b <vsnprintf+0x14>
  800a87:	85 d2                	test   %edx,%edx
  800a89:	7f 07                	jg     800a92 <vsnprintf+0x1b>
  800a8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a90:	eb 3b                	jmp    800acd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a95:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aaa:	8b 45 10             	mov    0x10(%ebp),%eax
  800aad:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab8:	c7 04 24 cf 03 80 00 	movl   $0x8003cf,(%esp)
  800abf:	e8 28 f9 ff ff       	call   8003ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ac4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ac7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800ad5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800ad8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800adc:	8b 45 10             	mov    0x10(%ebp),%eax
  800adf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	89 04 24             	mov    %eax,(%esp)
  800af0:	e8 82 ff ff ff       	call   800a77 <vsnprintf>
	va_end(ap);

	return rc;
}
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800afd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b04:	8b 45 10             	mov    0x10(%ebp),%eax
  800b07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	89 04 24             	mov    %eax,(%esp)
  800b18:	e8 cf f8 ff ff       	call   8003ec <vprintfmt>
	va_end(ap);
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    
	...

00800b20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b2e:	74 09                	je     800b39 <strlen+0x19>
		n++;
  800b30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b37:	75 f7                	jne    800b30 <strlen+0x10>
		n++;
	return n;
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	53                   	push   %ebx
  800b3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b45:	85 c9                	test   %ecx,%ecx
  800b47:	74 19                	je     800b62 <strnlen+0x27>
  800b49:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b4c:	74 14                	je     800b62 <strnlen+0x27>
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b53:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b56:	39 c8                	cmp    %ecx,%eax
  800b58:	74 0d                	je     800b67 <strnlen+0x2c>
  800b5a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b5e:	75 f3                	jne    800b53 <strnlen+0x18>
  800b60:	eb 05                	jmp    800b67 <strnlen+0x2c>
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b67:	5b                   	pop    %ebx
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	53                   	push   %ebx
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b7d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b80:	83 c2 01             	add    $0x1,%edx
  800b83:	84 c9                	test   %cl,%cl
  800b85:	75 f2                	jne    800b79 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b87:	5b                   	pop    %ebx
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 08             	sub    $0x8,%esp
  800b91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b94:	89 1c 24             	mov    %ebx,(%esp)
  800b97:	e8 84 ff ff ff       	call   800b20 <strlen>
	strcpy(dst + len, src);
  800b9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ba3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800ba6:	89 04 24             	mov    %eax,(%esp)
  800ba9:	e8 bc ff ff ff       	call   800b6a <strcpy>
	return dst;
}
  800bae:	89 d8                	mov    %ebx,%eax
  800bb0:	83 c4 08             	add    $0x8,%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc4:	85 f6                	test   %esi,%esi
  800bc6:	74 18                	je     800be0 <strncpy+0x2a>
  800bc8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bcd:	0f b6 1a             	movzbl (%edx),%ebx
  800bd0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bd3:	80 3a 01             	cmpb   $0x1,(%edx)
  800bd6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	39 ce                	cmp    %ecx,%esi
  800bde:	77 ed                	ja     800bcd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bf2:	89 f0                	mov    %esi,%eax
  800bf4:	85 c9                	test   %ecx,%ecx
  800bf6:	74 27                	je     800c1f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800bf8:	83 e9 01             	sub    $0x1,%ecx
  800bfb:	74 1d                	je     800c1a <strlcpy+0x36>
  800bfd:	0f b6 1a             	movzbl (%edx),%ebx
  800c00:	84 db                	test   %bl,%bl
  800c02:	74 16                	je     800c1a <strlcpy+0x36>
			*dst++ = *src++;
  800c04:	88 18                	mov    %bl,(%eax)
  800c06:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c09:	83 e9 01             	sub    $0x1,%ecx
  800c0c:	74 0e                	je     800c1c <strlcpy+0x38>
			*dst++ = *src++;
  800c0e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c11:	0f b6 1a             	movzbl (%edx),%ebx
  800c14:	84 db                	test   %bl,%bl
  800c16:	75 ec                	jne    800c04 <strlcpy+0x20>
  800c18:	eb 02                	jmp    800c1c <strlcpy+0x38>
  800c1a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c1c:	c6 00 00             	movb   $0x0,(%eax)
  800c1f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c2e:	0f b6 01             	movzbl (%ecx),%eax
  800c31:	84 c0                	test   %al,%al
  800c33:	74 15                	je     800c4a <strcmp+0x25>
  800c35:	3a 02                	cmp    (%edx),%al
  800c37:	75 11                	jne    800c4a <strcmp+0x25>
		p++, q++;
  800c39:	83 c1 01             	add    $0x1,%ecx
  800c3c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c3f:	0f b6 01             	movzbl (%ecx),%eax
  800c42:	84 c0                	test   %al,%al
  800c44:	74 04                	je     800c4a <strcmp+0x25>
  800c46:	3a 02                	cmp    (%edx),%al
  800c48:	74 ef                	je     800c39 <strcmp+0x14>
  800c4a:	0f b6 c0             	movzbl %al,%eax
  800c4d:	0f b6 12             	movzbl (%edx),%edx
  800c50:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	53                   	push   %ebx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	74 23                	je     800c88 <strncmp+0x34>
  800c65:	0f b6 1a             	movzbl (%edx),%ebx
  800c68:	84 db                	test   %bl,%bl
  800c6a:	74 25                	je     800c91 <strncmp+0x3d>
  800c6c:	3a 19                	cmp    (%ecx),%bl
  800c6e:	75 21                	jne    800c91 <strncmp+0x3d>
  800c70:	83 e8 01             	sub    $0x1,%eax
  800c73:	74 13                	je     800c88 <strncmp+0x34>
		n--, p++, q++;
  800c75:	83 c2 01             	add    $0x1,%edx
  800c78:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c7b:	0f b6 1a             	movzbl (%edx),%ebx
  800c7e:	84 db                	test   %bl,%bl
  800c80:	74 0f                	je     800c91 <strncmp+0x3d>
  800c82:	3a 19                	cmp    (%ecx),%bl
  800c84:	74 ea                	je     800c70 <strncmp+0x1c>
  800c86:	eb 09                	jmp    800c91 <strncmp+0x3d>
  800c88:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5d                   	pop    %ebp
  800c8f:	90                   	nop
  800c90:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c91:	0f b6 02             	movzbl (%edx),%eax
  800c94:	0f b6 11             	movzbl (%ecx),%edx
  800c97:	29 d0                	sub    %edx,%eax
  800c99:	eb f2                	jmp    800c8d <strncmp+0x39>

00800c9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca5:	0f b6 10             	movzbl (%eax),%edx
  800ca8:	84 d2                	test   %dl,%dl
  800caa:	74 18                	je     800cc4 <strchr+0x29>
		if (*s == c)
  800cac:	38 ca                	cmp    %cl,%dl
  800cae:	75 0a                	jne    800cba <strchr+0x1f>
  800cb0:	eb 17                	jmp    800cc9 <strchr+0x2e>
  800cb2:	38 ca                	cmp    %cl,%dl
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	74 0f                	je     800cc9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	0f b6 10             	movzbl (%eax),%edx
  800cc0:	84 d2                	test   %dl,%dl
  800cc2:	75 ee                	jne    800cb2 <strchr+0x17>
  800cc4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd5:	0f b6 10             	movzbl (%eax),%edx
  800cd8:	84 d2                	test   %dl,%dl
  800cda:	74 18                	je     800cf4 <strfind+0x29>
		if (*s == c)
  800cdc:	38 ca                	cmp    %cl,%dl
  800cde:	75 0a                	jne    800cea <strfind+0x1f>
  800ce0:	eb 12                	jmp    800cf4 <strfind+0x29>
  800ce2:	38 ca                	cmp    %cl,%dl
  800ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce8:	74 0a                	je     800cf4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cea:	83 c0 01             	add    $0x1,%eax
  800ced:	0f b6 10             	movzbl (%eax),%edx
  800cf0:	84 d2                	test   %dl,%dl
  800cf2:	75 ee                	jne    800ce2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	89 1c 24             	mov    %ebx,(%esp)
  800cff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d10:	85 c9                	test   %ecx,%ecx
  800d12:	74 30                	je     800d44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1a:	75 25                	jne    800d41 <memset+0x4b>
  800d1c:	f6 c1 03             	test   $0x3,%cl
  800d1f:	75 20                	jne    800d41 <memset+0x4b>
		c &= 0xFF;
  800d21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d24:	89 d3                	mov    %edx,%ebx
  800d26:	c1 e3 08             	shl    $0x8,%ebx
  800d29:	89 d6                	mov    %edx,%esi
  800d2b:	c1 e6 18             	shl    $0x18,%esi
  800d2e:	89 d0                	mov    %edx,%eax
  800d30:	c1 e0 10             	shl    $0x10,%eax
  800d33:	09 f0                	or     %esi,%eax
  800d35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d37:	09 d8                	or     %ebx,%eax
  800d39:	c1 e9 02             	shr    $0x2,%ecx
  800d3c:	fc                   	cld    
  800d3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d3f:	eb 03                	jmp    800d44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d41:	fc                   	cld    
  800d42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d44:	89 f8                	mov    %edi,%eax
  800d46:	8b 1c 24             	mov    (%esp),%ebx
  800d49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d51:	89 ec                	mov    %ebp,%esp
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 08             	sub    $0x8,%esp
  800d5b:	89 34 24             	mov    %esi,(%esp)
  800d5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d6d:	39 c6                	cmp    %eax,%esi
  800d6f:	73 35                	jae    800da6 <memmove+0x51>
  800d71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d74:	39 d0                	cmp    %edx,%eax
  800d76:	73 2e                	jae    800da6 <memmove+0x51>
		s += n;
		d += n;
  800d78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d7a:	f6 c2 03             	test   $0x3,%dl
  800d7d:	75 1b                	jne    800d9a <memmove+0x45>
  800d7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d85:	75 13                	jne    800d9a <memmove+0x45>
  800d87:	f6 c1 03             	test   $0x3,%cl
  800d8a:	75 0e                	jne    800d9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d8c:	83 ef 04             	sub    $0x4,%edi
  800d8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d92:	c1 e9 02             	shr    $0x2,%ecx
  800d95:	fd                   	std    
  800d96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d98:	eb 09                	jmp    800da3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d9a:	83 ef 01             	sub    $0x1,%edi
  800d9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800da0:	fd                   	std    
  800da1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800da3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800da4:	eb 20                	jmp    800dc6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dac:	75 15                	jne    800dc3 <memmove+0x6e>
  800dae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800db4:	75 0d                	jne    800dc3 <memmove+0x6e>
  800db6:	f6 c1 03             	test   $0x3,%cl
  800db9:	75 08                	jne    800dc3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800dbb:	c1 e9 02             	shr    $0x2,%ecx
  800dbe:	fc                   	cld    
  800dbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc1:	eb 03                	jmp    800dc6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dc3:	fc                   	cld    
  800dc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dc6:	8b 34 24             	mov    (%esp),%esi
  800dc9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dcd:	89 ec                	mov    %ebp,%esp
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800dda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	89 04 24             	mov    %eax,(%esp)
  800deb:	e8 65 ff ff ff       	call   800d55 <memmove>
}
  800df0:	c9                   	leave  
  800df1:	c3                   	ret    

00800df2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	8b 75 08             	mov    0x8(%ebp),%esi
  800dfb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e01:	85 c9                	test   %ecx,%ecx
  800e03:	74 36                	je     800e3b <memcmp+0x49>
		if (*s1 != *s2)
  800e05:	0f b6 06             	movzbl (%esi),%eax
  800e08:	0f b6 1f             	movzbl (%edi),%ebx
  800e0b:	38 d8                	cmp    %bl,%al
  800e0d:	74 20                	je     800e2f <memcmp+0x3d>
  800e0f:	eb 14                	jmp    800e25 <memcmp+0x33>
  800e11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e1b:	83 c2 01             	add    $0x1,%edx
  800e1e:	83 e9 01             	sub    $0x1,%ecx
  800e21:	38 d8                	cmp    %bl,%al
  800e23:	74 12                	je     800e37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e25:	0f b6 c0             	movzbl %al,%eax
  800e28:	0f b6 db             	movzbl %bl,%ebx
  800e2b:	29 d8                	sub    %ebx,%eax
  800e2d:	eb 11                	jmp    800e40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e2f:	83 e9 01             	sub    $0x1,%ecx
  800e32:	ba 00 00 00 00       	mov    $0x0,%edx
  800e37:	85 c9                	test   %ecx,%ecx
  800e39:	75 d6                	jne    800e11 <memcmp+0x1f>
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e4b:	89 c2                	mov    %eax,%edx
  800e4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e50:	39 d0                	cmp    %edx,%eax
  800e52:	73 15                	jae    800e69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e58:	38 08                	cmp    %cl,(%eax)
  800e5a:	75 06                	jne    800e62 <memfind+0x1d>
  800e5c:	eb 0b                	jmp    800e69 <memfind+0x24>
  800e5e:	38 08                	cmp    %cl,(%eax)
  800e60:	74 07                	je     800e69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e62:	83 c0 01             	add    $0x1,%eax
  800e65:	39 c2                	cmp    %eax,%edx
  800e67:	77 f5                	ja     800e5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 04             	sub    $0x4,%esp
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e7a:	0f b6 02             	movzbl (%edx),%eax
  800e7d:	3c 20                	cmp    $0x20,%al
  800e7f:	74 04                	je     800e85 <strtol+0x1a>
  800e81:	3c 09                	cmp    $0x9,%al
  800e83:	75 0e                	jne    800e93 <strtol+0x28>
		s++;
  800e85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e88:	0f b6 02             	movzbl (%edx),%eax
  800e8b:	3c 20                	cmp    $0x20,%al
  800e8d:	74 f6                	je     800e85 <strtol+0x1a>
  800e8f:	3c 09                	cmp    $0x9,%al
  800e91:	74 f2                	je     800e85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e93:	3c 2b                	cmp    $0x2b,%al
  800e95:	75 0c                	jne    800ea3 <strtol+0x38>
		s++;
  800e97:	83 c2 01             	add    $0x1,%edx
  800e9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ea1:	eb 15                	jmp    800eb8 <strtol+0x4d>
	else if (*s == '-')
  800ea3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eaa:	3c 2d                	cmp    $0x2d,%al
  800eac:	75 0a                	jne    800eb8 <strtol+0x4d>
		s++, neg = 1;
  800eae:	83 c2 01             	add    $0x1,%edx
  800eb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eb8:	85 db                	test   %ebx,%ebx
  800eba:	0f 94 c0             	sete   %al
  800ebd:	74 05                	je     800ec4 <strtol+0x59>
  800ebf:	83 fb 10             	cmp    $0x10,%ebx
  800ec2:	75 18                	jne    800edc <strtol+0x71>
  800ec4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ec7:	75 13                	jne    800edc <strtol+0x71>
  800ec9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ecd:	8d 76 00             	lea    0x0(%esi),%esi
  800ed0:	75 0a                	jne    800edc <strtol+0x71>
		s += 2, base = 16;
  800ed2:	83 c2 02             	add    $0x2,%edx
  800ed5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eda:	eb 15                	jmp    800ef1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800edc:	84 c0                	test   %al,%al
  800ede:	66 90                	xchg   %ax,%ax
  800ee0:	74 0f                	je     800ef1 <strtol+0x86>
  800ee2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ee7:	80 3a 30             	cmpb   $0x30,(%edx)
  800eea:	75 05                	jne    800ef1 <strtol+0x86>
		s++, base = 8;
  800eec:	83 c2 01             	add    $0x1,%edx
  800eef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ef8:	0f b6 0a             	movzbl (%edx),%ecx
  800efb:	89 cf                	mov    %ecx,%edi
  800efd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f00:	80 fb 09             	cmp    $0x9,%bl
  800f03:	77 08                	ja     800f0d <strtol+0xa2>
			dig = *s - '0';
  800f05:	0f be c9             	movsbl %cl,%ecx
  800f08:	83 e9 30             	sub    $0x30,%ecx
  800f0b:	eb 1e                	jmp    800f2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f10:	80 fb 19             	cmp    $0x19,%bl
  800f13:	77 08                	ja     800f1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f15:	0f be c9             	movsbl %cl,%ecx
  800f18:	83 e9 57             	sub    $0x57,%ecx
  800f1b:	eb 0e                	jmp    800f2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f20:	80 fb 19             	cmp    $0x19,%bl
  800f23:	77 15                	ja     800f3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f25:	0f be c9             	movsbl %cl,%ecx
  800f28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f2b:	39 f1                	cmp    %esi,%ecx
  800f2d:	7d 0b                	jge    800f3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f2f:	83 c2 01             	add    $0x1,%edx
  800f32:	0f af c6             	imul   %esi,%eax
  800f35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f38:	eb be                	jmp    800ef8 <strtol+0x8d>
  800f3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f40:	74 05                	je     800f47 <strtol+0xdc>
		*endptr = (char *) s;
  800f42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f4b:	74 04                	je     800f51 <strtol+0xe6>
  800f4d:	89 c8                	mov    %ecx,%eax
  800f4f:	f7 d8                	neg    %eax
}
  800f51:	83 c4 04             	add    $0x4,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
  800f59:	00 00                	add    %al,(%eax)
	...

00800f5c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 08             	sub    $0x8,%esp
  800f62:	89 1c 24             	mov    %ebx,(%esp)
  800f65:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f69:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f73:	89 d1                	mov    %edx,%ecx
  800f75:	89 d3                	mov    %edx,%ebx
  800f77:	89 d7                	mov    %edx,%edi
  800f79:	51                   	push   %ecx
  800f7a:	52                   	push   %edx
  800f7b:	53                   	push   %ebx
  800f7c:	54                   	push   %esp
  800f7d:	55                   	push   %ebp
  800f7e:	56                   	push   %esi
  800f7f:	57                   	push   %edi
  800f80:	54                   	push   %esp
  800f81:	5d                   	pop    %ebp
  800f82:	8d 35 8a 0f 80 00    	lea    0x800f8a,%esi
  800f88:	0f 34                	sysenter 
  800f8a:	5f                   	pop    %edi
  800f8b:	5e                   	pop    %esi
  800f8c:	5d                   	pop    %ebp
  800f8d:	5c                   	pop    %esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5a                   	pop    %edx
  800f90:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f91:	8b 1c 24             	mov    (%esp),%ebx
  800f94:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f98:	89 ec                	mov    %ebp,%esp
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	89 1c 24             	mov    %ebx,(%esp)
  800fa5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	89 c7                	mov    %eax,%edi
  800fb8:	51                   	push   %ecx
  800fb9:	52                   	push   %edx
  800fba:	53                   	push   %ebx
  800fbb:	54                   	push   %esp
  800fbc:	55                   	push   %ebp
  800fbd:	56                   	push   %esi
  800fbe:	57                   	push   %edi
  800fbf:	54                   	push   %esp
  800fc0:	5d                   	pop    %ebp
  800fc1:	8d 35 c9 0f 80 00    	lea    0x800fc9,%esi
  800fc7:	0f 34                	sysenter 
  800fc9:	5f                   	pop    %edi
  800fca:	5e                   	pop    %esi
  800fcb:	5d                   	pop    %ebp
  800fcc:	5c                   	pop    %esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5a                   	pop    %edx
  800fcf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fd0:	8b 1c 24             	mov    (%esp),%ebx
  800fd3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fd7:	89 ec                	mov    %ebp,%esp
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 08             	sub    $0x8,%esp
  800fe1:	89 1c 24             	mov    %ebx,(%esp)
  800fe4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fed:	b8 13 00 00 00       	mov    $0x13,%eax
  800ff2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff5:	89 cb                	mov    %ecx,%ebx
  800ff7:	89 cf                	mov    %ecx,%edi
  800ff9:	51                   	push   %ecx
  800ffa:	52                   	push   %edx
  800ffb:	53                   	push   %ebx
  800ffc:	54                   	push   %esp
  800ffd:	55                   	push   %ebp
  800ffe:	56                   	push   %esi
  800fff:	57                   	push   %edi
  801000:	54                   	push   %esp
  801001:	5d                   	pop    %ebp
  801002:	8d 35 0a 10 80 00    	lea    0x80100a,%esi
  801008:	0f 34                	sysenter 
  80100a:	5f                   	pop    %edi
  80100b:	5e                   	pop    %esi
  80100c:	5d                   	pop    %ebp
  80100d:	5c                   	pop    %esp
  80100e:	5b                   	pop    %ebx
  80100f:	5a                   	pop    %edx
  801010:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801011:	8b 1c 24             	mov    (%esp),%ebx
  801014:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801018:	89 ec                	mov    %ebp,%esp
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	89 1c 24             	mov    %ebx,(%esp)
  801025:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801029:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102e:	b8 12 00 00 00       	mov    $0x12,%eax
  801033:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801036:	8b 55 08             	mov    0x8(%ebp),%edx
  801039:	89 df                	mov    %ebx,%edi
  80103b:	51                   	push   %ecx
  80103c:	52                   	push   %edx
  80103d:	53                   	push   %ebx
  80103e:	54                   	push   %esp
  80103f:	55                   	push   %ebp
  801040:	56                   	push   %esi
  801041:	57                   	push   %edi
  801042:	54                   	push   %esp
  801043:	5d                   	pop    %ebp
  801044:	8d 35 4c 10 80 00    	lea    0x80104c,%esi
  80104a:	0f 34                	sysenter 
  80104c:	5f                   	pop    %edi
  80104d:	5e                   	pop    %esi
  80104e:	5d                   	pop    %ebp
  80104f:	5c                   	pop    %esp
  801050:	5b                   	pop    %ebx
  801051:	5a                   	pop    %edx
  801052:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801053:	8b 1c 24             	mov    (%esp),%ebx
  801056:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80105a:	89 ec                	mov    %ebp,%esp
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    

0080105e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	89 1c 24             	mov    %ebx,(%esp)
  801067:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80106b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801070:	b8 11 00 00 00       	mov    $0x11,%eax
  801075:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801078:	8b 55 08             	mov    0x8(%ebp),%edx
  80107b:	89 df                	mov    %ebx,%edi
  80107d:	51                   	push   %ecx
  80107e:	52                   	push   %edx
  80107f:	53                   	push   %ebx
  801080:	54                   	push   %esp
  801081:	55                   	push   %ebp
  801082:	56                   	push   %esi
  801083:	57                   	push   %edi
  801084:	54                   	push   %esp
  801085:	5d                   	pop    %ebp
  801086:	8d 35 8e 10 80 00    	lea    0x80108e,%esi
  80108c:	0f 34                	sysenter 
  80108e:	5f                   	pop    %edi
  80108f:	5e                   	pop    %esi
  801090:	5d                   	pop    %ebp
  801091:	5c                   	pop    %esp
  801092:	5b                   	pop    %ebx
  801093:	5a                   	pop    %edx
  801094:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801095:	8b 1c 24             	mov    (%esp),%ebx
  801098:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80109c:	89 ec                	mov    %ebp,%esp
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	89 1c 24             	mov    %ebx,(%esp)
  8010a9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ad:	b8 10 00 00 00       	mov    $0x10,%eax
  8010b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010be:	51                   	push   %ecx
  8010bf:	52                   	push   %edx
  8010c0:	53                   	push   %ebx
  8010c1:	54                   	push   %esp
  8010c2:	55                   	push   %ebp
  8010c3:	56                   	push   %esi
  8010c4:	57                   	push   %edi
  8010c5:	54                   	push   %esp
  8010c6:	5d                   	pop    %ebp
  8010c7:	8d 35 cf 10 80 00    	lea    0x8010cf,%esi
  8010cd:	0f 34                	sysenter 
  8010cf:	5f                   	pop    %edi
  8010d0:	5e                   	pop    %esi
  8010d1:	5d                   	pop    %ebp
  8010d2:	5c                   	pop    %esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5a                   	pop    %edx
  8010d5:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  8010d6:	8b 1c 24             	mov    (%esp),%ebx
  8010d9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010dd:	89 ec                	mov    %ebp,%esp
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	83 ec 28             	sub    $0x28,%esp
  8010e7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010ea:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fd:	89 df                	mov    %ebx,%edi
  8010ff:	51                   	push   %ecx
  801100:	52                   	push   %edx
  801101:	53                   	push   %ebx
  801102:	54                   	push   %esp
  801103:	55                   	push   %ebp
  801104:	56                   	push   %esi
  801105:	57                   	push   %edi
  801106:	54                   	push   %esp
  801107:	5d                   	pop    %ebp
  801108:	8d 35 10 11 80 00    	lea    0x801110,%esi
  80110e:	0f 34                	sysenter 
  801110:	5f                   	pop    %edi
  801111:	5e                   	pop    %esi
  801112:	5d                   	pop    %ebp
  801113:	5c                   	pop    %esp
  801114:	5b                   	pop    %ebx
  801115:	5a                   	pop    %edx
  801116:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801117:	85 c0                	test   %eax,%eax
  801119:	7e 28                	jle    801143 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801126:	00 
  801127:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  80112e:	00 
  80112f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  80113e:	e8 3d f0 ff ff       	call   800180 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801143:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801146:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801149:	89 ec                	mov    %ebp,%esp
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	83 ec 08             	sub    $0x8,%esp
  801153:	89 1c 24             	mov    %ebx,(%esp)
  801156:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80115a:	ba 00 00 00 00       	mov    $0x0,%edx
  80115f:	b8 15 00 00 00       	mov    $0x15,%eax
  801164:	89 d1                	mov    %edx,%ecx
  801166:	89 d3                	mov    %edx,%ebx
  801168:	89 d7                	mov    %edx,%edi
  80116a:	51                   	push   %ecx
  80116b:	52                   	push   %edx
  80116c:	53                   	push   %ebx
  80116d:	54                   	push   %esp
  80116e:	55                   	push   %ebp
  80116f:	56                   	push   %esi
  801170:	57                   	push   %edi
  801171:	54                   	push   %esp
  801172:	5d                   	pop    %ebp
  801173:	8d 35 7b 11 80 00    	lea    0x80117b,%esi
  801179:	0f 34                	sysenter 
  80117b:	5f                   	pop    %edi
  80117c:	5e                   	pop    %esi
  80117d:	5d                   	pop    %ebp
  80117e:	5c                   	pop    %esp
  80117f:	5b                   	pop    %ebx
  801180:	5a                   	pop    %edx
  801181:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801182:	8b 1c 24             	mov    (%esp),%ebx
  801185:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801189:	89 ec                	mov    %ebp,%esp
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	89 1c 24             	mov    %ebx,(%esp)
  801196:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80119a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80119f:	b8 14 00 00 00       	mov    $0x14,%eax
  8011a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a7:	89 cb                	mov    %ecx,%ebx
  8011a9:	89 cf                	mov    %ecx,%edi
  8011ab:	51                   	push   %ecx
  8011ac:	52                   	push   %edx
  8011ad:	53                   	push   %ebx
  8011ae:	54                   	push   %esp
  8011af:	55                   	push   %ebp
  8011b0:	56                   	push   %esi
  8011b1:	57                   	push   %edi
  8011b2:	54                   	push   %esp
  8011b3:	5d                   	pop    %ebp
  8011b4:	8d 35 bc 11 80 00    	lea    0x8011bc,%esi
  8011ba:	0f 34                	sysenter 
  8011bc:	5f                   	pop    %edi
  8011bd:	5e                   	pop    %esi
  8011be:	5d                   	pop    %ebp
  8011bf:	5c                   	pop    %esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5a                   	pop    %edx
  8011c2:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011c3:	8b 1c 24             	mov    (%esp),%ebx
  8011c6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011ca:	89 ec                	mov    %ebp,%esp
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	83 ec 28             	sub    $0x28,%esp
  8011d4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011d7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011df:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e7:	89 cb                	mov    %ecx,%ebx
  8011e9:	89 cf                	mov    %ecx,%edi
  8011eb:	51                   	push   %ecx
  8011ec:	52                   	push   %edx
  8011ed:	53                   	push   %ebx
  8011ee:	54                   	push   %esp
  8011ef:	55                   	push   %ebp
  8011f0:	56                   	push   %esi
  8011f1:	57                   	push   %edi
  8011f2:	54                   	push   %esp
  8011f3:	5d                   	pop    %ebp
  8011f4:	8d 35 fc 11 80 00    	lea    0x8011fc,%esi
  8011fa:	0f 34                	sysenter 
  8011fc:	5f                   	pop    %edi
  8011fd:	5e                   	pop    %esi
  8011fe:	5d                   	pop    %ebp
  8011ff:	5c                   	pop    %esp
  801200:	5b                   	pop    %ebx
  801201:	5a                   	pop    %edx
  801202:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801203:	85 c0                	test   %eax,%eax
  801205:	7e 28                	jle    80122f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801207:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801212:	00 
  801213:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  80122a:	e8 51 ef ff ff       	call   800180 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80122f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801232:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801235:	89 ec                	mov    %ebp,%esp
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	89 1c 24             	mov    %ebx,(%esp)
  801242:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801246:	b8 0d 00 00 00       	mov    $0xd,%eax
  80124b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80124e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801254:	8b 55 08             	mov    0x8(%ebp),%edx
  801257:	51                   	push   %ecx
  801258:	52                   	push   %edx
  801259:	53                   	push   %ebx
  80125a:	54                   	push   %esp
  80125b:	55                   	push   %ebp
  80125c:	56                   	push   %esi
  80125d:	57                   	push   %edi
  80125e:	54                   	push   %esp
  80125f:	5d                   	pop    %ebp
  801260:	8d 35 68 12 80 00    	lea    0x801268,%esi
  801266:	0f 34                	sysenter 
  801268:	5f                   	pop    %edi
  801269:	5e                   	pop    %esi
  80126a:	5d                   	pop    %ebp
  80126b:	5c                   	pop    %esp
  80126c:	5b                   	pop    %ebx
  80126d:	5a                   	pop    %edx
  80126e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80126f:	8b 1c 24             	mov    (%esp),%ebx
  801272:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801276:	89 ec                	mov    %ebp,%esp
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	83 ec 28             	sub    $0x28,%esp
  801280:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801283:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801290:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801293:	8b 55 08             	mov    0x8(%ebp),%edx
  801296:	89 df                	mov    %ebx,%edi
  801298:	51                   	push   %ecx
  801299:	52                   	push   %edx
  80129a:	53                   	push   %ebx
  80129b:	54                   	push   %esp
  80129c:	55                   	push   %ebp
  80129d:	56                   	push   %esi
  80129e:	57                   	push   %edi
  80129f:	54                   	push   %esp
  8012a0:	5d                   	pop    %ebp
  8012a1:	8d 35 a9 12 80 00    	lea    0x8012a9,%esi
  8012a7:	0f 34                	sysenter 
  8012a9:	5f                   	pop    %edi
  8012aa:	5e                   	pop    %esi
  8012ab:	5d                   	pop    %ebp
  8012ac:	5c                   	pop    %esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5a                   	pop    %edx
  8012af:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	7e 28                	jle    8012dc <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8012bf:	00 
  8012c0:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  8012c7:	00 
  8012c8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012cf:	00 
  8012d0:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  8012d7:	e8 a4 ee ff ff       	call   800180 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012dc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012df:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012e2:	89 ec                	mov    %ebp,%esp
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 28             	sub    $0x28,%esp
  8012ec:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012ef:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801302:	89 df                	mov    %ebx,%edi
  801304:	51                   	push   %ecx
  801305:	52                   	push   %edx
  801306:	53                   	push   %ebx
  801307:	54                   	push   %esp
  801308:	55                   	push   %ebp
  801309:	56                   	push   %esi
  80130a:	57                   	push   %edi
  80130b:	54                   	push   %esp
  80130c:	5d                   	pop    %ebp
  80130d:	8d 35 15 13 80 00    	lea    0x801315,%esi
  801313:	0f 34                	sysenter 
  801315:	5f                   	pop    %edi
  801316:	5e                   	pop    %esi
  801317:	5d                   	pop    %ebp
  801318:	5c                   	pop    %esp
  801319:	5b                   	pop    %ebx
  80131a:	5a                   	pop    %edx
  80131b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80131c:	85 c0                	test   %eax,%eax
  80131e:	7e 28                	jle    801348 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801320:	89 44 24 10          	mov    %eax,0x10(%esp)
  801324:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80132b:	00 
  80132c:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  801333:	00 
  801334:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80133b:	00 
  80133c:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  801343:	e8 38 ee ff ff       	call   800180 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801348:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80134b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80134e:	89 ec                	mov    %ebp,%esp
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 28             	sub    $0x28,%esp
  801358:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80135b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80135e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801363:	b8 09 00 00 00       	mov    $0x9,%eax
  801368:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136b:	8b 55 08             	mov    0x8(%ebp),%edx
  80136e:	89 df                	mov    %ebx,%edi
  801370:	51                   	push   %ecx
  801371:	52                   	push   %edx
  801372:	53                   	push   %ebx
  801373:	54                   	push   %esp
  801374:	55                   	push   %ebp
  801375:	56                   	push   %esi
  801376:	57                   	push   %edi
  801377:	54                   	push   %esp
  801378:	5d                   	pop    %ebp
  801379:	8d 35 81 13 80 00    	lea    0x801381,%esi
  80137f:	0f 34                	sysenter 
  801381:	5f                   	pop    %edi
  801382:	5e                   	pop    %esi
  801383:	5d                   	pop    %ebp
  801384:	5c                   	pop    %esp
  801385:	5b                   	pop    %ebx
  801386:	5a                   	pop    %edx
  801387:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801388:	85 c0                	test   %eax,%eax
  80138a:	7e 28                	jle    8013b4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80138c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801390:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801397:	00 
  801398:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  80139f:	00 
  8013a0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013a7:	00 
  8013a8:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  8013af:	e8 cc ed ff ff       	call   800180 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013b4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013b7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ba:	89 ec                	mov    %ebp,%esp
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	83 ec 28             	sub    $0x28,%esp
  8013c4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013c7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cf:	b8 07 00 00 00       	mov    $0x7,%eax
  8013d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013da:	89 df                	mov    %ebx,%edi
  8013dc:	51                   	push   %ecx
  8013dd:	52                   	push   %edx
  8013de:	53                   	push   %ebx
  8013df:	54                   	push   %esp
  8013e0:	55                   	push   %ebp
  8013e1:	56                   	push   %esi
  8013e2:	57                   	push   %edi
  8013e3:	54                   	push   %esp
  8013e4:	5d                   	pop    %ebp
  8013e5:	8d 35 ed 13 80 00    	lea    0x8013ed,%esi
  8013eb:	0f 34                	sysenter 
  8013ed:	5f                   	pop    %edi
  8013ee:	5e                   	pop    %esi
  8013ef:	5d                   	pop    %ebp
  8013f0:	5c                   	pop    %esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5a                   	pop    %edx
  8013f3:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	7e 28                	jle    801420 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013fc:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801403:	00 
  801404:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  80140b:	00 
  80140c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801413:	00 
  801414:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  80141b:	e8 60 ed ff ff       	call   800180 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801420:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801423:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801426:	89 ec                	mov    %ebp,%esp
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 28             	sub    $0x28,%esp
  801430:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801433:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801436:	8b 7d 18             	mov    0x18(%ebp),%edi
  801439:	0b 7d 14             	or     0x14(%ebp),%edi
  80143c:	b8 06 00 00 00       	mov    $0x6,%eax
  801441:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801444:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801447:	8b 55 08             	mov    0x8(%ebp),%edx
  80144a:	51                   	push   %ecx
  80144b:	52                   	push   %edx
  80144c:	53                   	push   %ebx
  80144d:	54                   	push   %esp
  80144e:	55                   	push   %ebp
  80144f:	56                   	push   %esi
  801450:	57                   	push   %edi
  801451:	54                   	push   %esp
  801452:	5d                   	pop    %ebp
  801453:	8d 35 5b 14 80 00    	lea    0x80145b,%esi
  801459:	0f 34                	sysenter 
  80145b:	5f                   	pop    %edi
  80145c:	5e                   	pop    %esi
  80145d:	5d                   	pop    %ebp
  80145e:	5c                   	pop    %esp
  80145f:	5b                   	pop    %ebx
  801460:	5a                   	pop    %edx
  801461:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801462:	85 c0                	test   %eax,%eax
  801464:	7e 28                	jle    80148e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801466:	89 44 24 10          	mov    %eax,0x10(%esp)
  80146a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801471:	00 
  801472:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  801479:	00 
  80147a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801481:	00 
  801482:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  801489:	e8 f2 ec ff ff       	call   800180 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80148e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801491:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801494:	89 ec                	mov    %ebp,%esp
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	83 ec 28             	sub    $0x28,%esp
  80149e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014a1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8014a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b7:	51                   	push   %ecx
  8014b8:	52                   	push   %edx
  8014b9:	53                   	push   %ebx
  8014ba:	54                   	push   %esp
  8014bb:	55                   	push   %ebp
  8014bc:	56                   	push   %esi
  8014bd:	57                   	push   %edi
  8014be:	54                   	push   %esp
  8014bf:	5d                   	pop    %ebp
  8014c0:	8d 35 c8 14 80 00    	lea    0x8014c8,%esi
  8014c6:	0f 34                	sysenter 
  8014c8:	5f                   	pop    %edi
  8014c9:	5e                   	pop    %esi
  8014ca:	5d                   	pop    %ebp
  8014cb:	5c                   	pop    %esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5a                   	pop    %edx
  8014ce:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	7e 28                	jle    8014fb <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014d7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8014de:	00 
  8014df:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  8014e6:	00 
  8014e7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014ee:	00 
  8014ef:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  8014f6:	e8 85 ec ff ff       	call   800180 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8014fb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801501:	89 ec                	mov    %ebp,%esp
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	89 1c 24             	mov    %ebx,(%esp)
  80150e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801512:	ba 00 00 00 00       	mov    $0x0,%edx
  801517:	b8 0c 00 00 00       	mov    $0xc,%eax
  80151c:	89 d1                	mov    %edx,%ecx
  80151e:	89 d3                	mov    %edx,%ebx
  801520:	89 d7                	mov    %edx,%edi
  801522:	51                   	push   %ecx
  801523:	52                   	push   %edx
  801524:	53                   	push   %ebx
  801525:	54                   	push   %esp
  801526:	55                   	push   %ebp
  801527:	56                   	push   %esi
  801528:	57                   	push   %edi
  801529:	54                   	push   %esp
  80152a:	5d                   	pop    %ebp
  80152b:	8d 35 33 15 80 00    	lea    0x801533,%esi
  801531:	0f 34                	sysenter 
  801533:	5f                   	pop    %edi
  801534:	5e                   	pop    %esi
  801535:	5d                   	pop    %ebp
  801536:	5c                   	pop    %esp
  801537:	5b                   	pop    %ebx
  801538:	5a                   	pop    %edx
  801539:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80153a:	8b 1c 24             	mov    (%esp),%ebx
  80153d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801541:	89 ec                	mov    %ebp,%esp
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	89 1c 24             	mov    %ebx,(%esp)
  80154e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801552:	bb 00 00 00 00       	mov    $0x0,%ebx
  801557:	b8 04 00 00 00       	mov    $0x4,%eax
  80155c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80155f:	8b 55 08             	mov    0x8(%ebp),%edx
  801562:	89 df                	mov    %ebx,%edi
  801564:	51                   	push   %ecx
  801565:	52                   	push   %edx
  801566:	53                   	push   %ebx
  801567:	54                   	push   %esp
  801568:	55                   	push   %ebp
  801569:	56                   	push   %esi
  80156a:	57                   	push   %edi
  80156b:	54                   	push   %esp
  80156c:	5d                   	pop    %ebp
  80156d:	8d 35 75 15 80 00    	lea    0x801575,%esi
  801573:	0f 34                	sysenter 
  801575:	5f                   	pop    %edi
  801576:	5e                   	pop    %esi
  801577:	5d                   	pop    %ebp
  801578:	5c                   	pop    %esp
  801579:	5b                   	pop    %ebx
  80157a:	5a                   	pop    %edx
  80157b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80157c:	8b 1c 24             	mov    (%esp),%ebx
  80157f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801583:	89 ec                	mov    %ebp,%esp
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	89 1c 24             	mov    %ebx,(%esp)
  801590:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
  801599:	b8 02 00 00 00       	mov    $0x2,%eax
  80159e:	89 d1                	mov    %edx,%ecx
  8015a0:	89 d3                	mov    %edx,%ebx
  8015a2:	89 d7                	mov    %edx,%edi
  8015a4:	51                   	push   %ecx
  8015a5:	52                   	push   %edx
  8015a6:	53                   	push   %ebx
  8015a7:	54                   	push   %esp
  8015a8:	55                   	push   %ebp
  8015a9:	56                   	push   %esi
  8015aa:	57                   	push   %edi
  8015ab:	54                   	push   %esp
  8015ac:	5d                   	pop    %ebp
  8015ad:	8d 35 b5 15 80 00    	lea    0x8015b5,%esi
  8015b3:	0f 34                	sysenter 
  8015b5:	5f                   	pop    %edi
  8015b6:	5e                   	pop    %esi
  8015b7:	5d                   	pop    %ebp
  8015b8:	5c                   	pop    %esp
  8015b9:	5b                   	pop    %ebx
  8015ba:	5a                   	pop    %edx
  8015bb:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015bc:	8b 1c 24             	mov    (%esp),%ebx
  8015bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015c3:	89 ec                	mov    %ebp,%esp
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 28             	sub    $0x28,%esp
  8015cd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015d0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e0:	89 cb                	mov    %ecx,%ebx
  8015e2:	89 cf                	mov    %ecx,%edi
  8015e4:	51                   	push   %ecx
  8015e5:	52                   	push   %edx
  8015e6:	53                   	push   %ebx
  8015e7:	54                   	push   %esp
  8015e8:	55                   	push   %ebp
  8015e9:	56                   	push   %esi
  8015ea:	57                   	push   %edi
  8015eb:	54                   	push   %esp
  8015ec:	5d                   	pop    %ebp
  8015ed:	8d 35 f5 15 80 00    	lea    0x8015f5,%esi
  8015f3:	0f 34                	sysenter 
  8015f5:	5f                   	pop    %edi
  8015f6:	5e                   	pop    %esi
  8015f7:	5d                   	pop    %ebp
  8015f8:	5c                   	pop    %esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5a                   	pop    %edx
  8015fb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	7e 28                	jle    801628 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801600:	89 44 24 10          	mov    %eax,0x10(%esp)
  801604:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80160b:	00 
  80160c:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  801613:	00 
  801614:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80161b:	00 
  80161c:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  801623:	e8 58 eb ff ff       	call   800180 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801628:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80162b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80162e:	89 ec                	mov    %ebp,%esp
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    
	...

00801640 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	05 00 00 00 30       	add    $0x30000000,%eax
  80164b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801656:	8b 45 08             	mov    0x8(%ebp),%eax
  801659:	89 04 24             	mov    %eax,(%esp)
  80165c:	e8 df ff ff ff       	call   801640 <fd2num>
  801661:	05 20 00 0d 00       	add    $0xd0020,%eax
  801666:	c1 e0 0c             	shl    $0xc,%eax
}
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	57                   	push   %edi
  80166f:	56                   	push   %esi
  801670:	53                   	push   %ebx
  801671:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801674:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801679:	a8 01                	test   $0x1,%al
  80167b:	74 36                	je     8016b3 <fd_alloc+0x48>
  80167d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801682:	a8 01                	test   $0x1,%al
  801684:	74 2d                	je     8016b3 <fd_alloc+0x48>
  801686:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80168b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801690:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801695:	89 c3                	mov    %eax,%ebx
  801697:	89 c2                	mov    %eax,%edx
  801699:	c1 ea 16             	shr    $0x16,%edx
  80169c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80169f:	f6 c2 01             	test   $0x1,%dl
  8016a2:	74 14                	je     8016b8 <fd_alloc+0x4d>
  8016a4:	89 c2                	mov    %eax,%edx
  8016a6:	c1 ea 0c             	shr    $0xc,%edx
  8016a9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016ac:	f6 c2 01             	test   $0x1,%dl
  8016af:	75 10                	jne    8016c1 <fd_alloc+0x56>
  8016b1:	eb 05                	jmp    8016b8 <fd_alloc+0x4d>
  8016b3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8016b8:	89 1f                	mov    %ebx,(%edi)
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016bf:	eb 17                	jmp    8016d8 <fd_alloc+0x6d>
  8016c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016cb:	75 c8                	jne    801695 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8016d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8016d8:	5b                   	pop    %ebx
  8016d9:	5e                   	pop    %esi
  8016da:	5f                   	pop    %edi
  8016db:	5d                   	pop    %ebp
  8016dc:	c3                   	ret    

008016dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	83 f8 1f             	cmp    $0x1f,%eax
  8016e6:	77 36                	ja     80171e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016e8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8016ed:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	c1 ea 16             	shr    $0x16,%edx
  8016f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016fc:	f6 c2 01             	test   $0x1,%dl
  8016ff:	74 1d                	je     80171e <fd_lookup+0x41>
  801701:	89 c2                	mov    %eax,%edx
  801703:	c1 ea 0c             	shr    $0xc,%edx
  801706:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80170d:	f6 c2 01             	test   $0x1,%dl
  801710:	74 0c                	je     80171e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801712:	8b 55 0c             	mov    0xc(%ebp),%edx
  801715:	89 02                	mov    %eax,(%edx)
  801717:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80171c:	eb 05                	jmp    801723 <fd_lookup+0x46>
  80171e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80172b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80172e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	89 04 24             	mov    %eax,(%esp)
  801738:	e8 a0 ff ff ff       	call   8016dd <fd_lookup>
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 0e                	js     80174f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801741:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801744:	8b 55 0c             	mov    0xc(%ebp),%edx
  801747:	89 50 04             	mov    %edx,0x4(%eax)
  80174a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	56                   	push   %esi
  801755:	53                   	push   %ebx
  801756:	83 ec 10             	sub    $0x10,%esp
  801759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80175f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801764:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801769:	be cc 2c 80 00       	mov    $0x802ccc,%esi
		if (devtab[i]->dev_id == dev_id) {
  80176e:	39 08                	cmp    %ecx,(%eax)
  801770:	75 10                	jne    801782 <dev_lookup+0x31>
  801772:	eb 04                	jmp    801778 <dev_lookup+0x27>
  801774:	39 08                	cmp    %ecx,(%eax)
  801776:	75 0a                	jne    801782 <dev_lookup+0x31>
			*dev = devtab[i];
  801778:	89 03                	mov    %eax,(%ebx)
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80177f:	90                   	nop
  801780:	eb 31                	jmp    8017b3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801782:	83 c2 01             	add    $0x1,%edx
  801785:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801788:	85 c0                	test   %eax,%eax
  80178a:	75 e8                	jne    801774 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80178c:	a1 08 40 80 00       	mov    0x804008,%eax
  801791:	8b 40 48             	mov    0x48(%eax),%eax
  801794:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179c:	c7 04 24 4c 2c 80 00 	movl   $0x802c4c,(%esp)
  8017a3:	e8 91 ea ff ff       	call   800239 <cprintf>
	*dev = 0;
  8017a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	5b                   	pop    %ebx
  8017b7:	5e                   	pop    %esi
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	53                   	push   %ebx
  8017be:	83 ec 24             	sub    $0x24,%esp
  8017c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	89 04 24             	mov    %eax,(%esp)
  8017d1:	e8 07 ff ff ff       	call   8016dd <fd_lookup>
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 53                	js     80182d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e4:	8b 00                	mov    (%eax),%eax
  8017e6:	89 04 24             	mov    %eax,(%esp)
  8017e9:	e8 63 ff ff ff       	call   801751 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 3b                	js     80182d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8017f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017fa:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8017fe:	74 2d                	je     80182d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801800:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801803:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80180a:	00 00 00 
	stat->st_isdir = 0;
  80180d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801814:	00 00 00 
	stat->st_dev = dev;
  801817:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801824:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801827:	89 14 24             	mov    %edx,(%esp)
  80182a:	ff 50 14             	call   *0x14(%eax)
}
  80182d:	83 c4 24             	add    $0x24,%esp
  801830:	5b                   	pop    %ebx
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	83 ec 24             	sub    $0x24,%esp
  80183a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801840:	89 44 24 04          	mov    %eax,0x4(%esp)
  801844:	89 1c 24             	mov    %ebx,(%esp)
  801847:	e8 91 fe ff ff       	call   8016dd <fd_lookup>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 5f                	js     8018af <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	89 44 24 04          	mov    %eax,0x4(%esp)
  801857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185a:	8b 00                	mov    (%eax),%eax
  80185c:	89 04 24             	mov    %eax,(%esp)
  80185f:	e8 ed fe ff ff       	call   801751 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801864:	85 c0                	test   %eax,%eax
  801866:	78 47                	js     8018af <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801868:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80186b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80186f:	75 23                	jne    801894 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801871:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801876:	8b 40 48             	mov    0x48(%eax),%eax
  801879:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80187d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801881:	c7 04 24 6c 2c 80 00 	movl   $0x802c6c,(%esp)
  801888:	e8 ac e9 ff ff       	call   800239 <cprintf>
  80188d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801892:	eb 1b                	jmp    8018af <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801897:	8b 48 18             	mov    0x18(%eax),%ecx
  80189a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80189f:	85 c9                	test   %ecx,%ecx
  8018a1:	74 0c                	je     8018af <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018aa:	89 14 24             	mov    %edx,(%esp)
  8018ad:	ff d1                	call   *%ecx
}
  8018af:	83 c4 24             	add    $0x24,%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 24             	sub    $0x24,%esp
  8018bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c6:	89 1c 24             	mov    %ebx,(%esp)
  8018c9:	e8 0f fe ff ff       	call   8016dd <fd_lookup>
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 66                	js     801938 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dc:	8b 00                	mov    (%eax),%eax
  8018de:	89 04 24             	mov    %eax,(%esp)
  8018e1:	e8 6b fe ff ff       	call   801751 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 4e                	js     801938 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018ed:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018f1:	75 23                	jne    801916 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8018f8:	8b 40 48             	mov    0x48(%eax),%eax
  8018fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801903:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  80190a:	e8 2a e9 ff ff       	call   800239 <cprintf>
  80190f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801914:	eb 22                	jmp    801938 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801919:	8b 48 0c             	mov    0xc(%eax),%ecx
  80191c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801921:	85 c9                	test   %ecx,%ecx
  801923:	74 13                	je     801938 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801925:	8b 45 10             	mov    0x10(%ebp),%eax
  801928:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801933:	89 14 24             	mov    %edx,(%esp)
  801936:	ff d1                	call   *%ecx
}
  801938:	83 c4 24             	add    $0x24,%esp
  80193b:	5b                   	pop    %ebx
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 24             	sub    $0x24,%esp
  801945:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801948:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80194b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194f:	89 1c 24             	mov    %ebx,(%esp)
  801952:	e8 86 fd ff ff       	call   8016dd <fd_lookup>
  801957:	85 c0                	test   %eax,%eax
  801959:	78 6b                	js     8019c6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801962:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801965:	8b 00                	mov    (%eax),%eax
  801967:	89 04 24             	mov    %eax,(%esp)
  80196a:	e8 e2 fd ff ff       	call   801751 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 53                	js     8019c6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801973:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801976:	8b 42 08             	mov    0x8(%edx),%eax
  801979:	83 e0 03             	and    $0x3,%eax
  80197c:	83 f8 01             	cmp    $0x1,%eax
  80197f:	75 23                	jne    8019a4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801981:	a1 08 40 80 00       	mov    0x804008,%eax
  801986:	8b 40 48             	mov    0x48(%eax),%eax
  801989:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80198d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801991:	c7 04 24 ad 2c 80 00 	movl   $0x802cad,(%esp)
  801998:	e8 9c e8 ff ff       	call   800239 <cprintf>
  80199d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019a2:	eb 22                	jmp    8019c6 <read+0x88>
	}
	if (!dev->dev_read)
  8019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a7:	8b 48 08             	mov    0x8(%eax),%ecx
  8019aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019af:	85 c9                	test   %ecx,%ecx
  8019b1:	74 13                	je     8019c6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c1:	89 14 24             	mov    %edx,(%esp)
  8019c4:	ff d1                	call   *%ecx
}
  8019c6:	83 c4 24             	add    $0x24,%esp
  8019c9:	5b                   	pop    %ebx
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	57                   	push   %edi
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 1c             	sub    $0x1c,%esp
  8019d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019db:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ea:	85 f6                	test   %esi,%esi
  8019ec:	74 29                	je     801a17 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019ee:	89 f0                	mov    %esi,%eax
  8019f0:	29 d0                	sub    %edx,%eax
  8019f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f6:	03 55 0c             	add    0xc(%ebp),%edx
  8019f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019fd:	89 3c 24             	mov    %edi,(%esp)
  801a00:	e8 39 ff ff ff       	call   80193e <read>
		if (m < 0)
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 0e                	js     801a17 <readn+0x4b>
			return m;
		if (m == 0)
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	74 08                	je     801a15 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a0d:	01 c3                	add    %eax,%ebx
  801a0f:	89 da                	mov    %ebx,%edx
  801a11:	39 f3                	cmp    %esi,%ebx
  801a13:	72 d9                	jb     8019ee <readn+0x22>
  801a15:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a17:	83 c4 1c             	add    $0x1c,%esp
  801a1a:	5b                   	pop    %ebx
  801a1b:	5e                   	pop    %esi
  801a1c:	5f                   	pop    %edi
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    

00801a1f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
  801a24:	83 ec 20             	sub    $0x20,%esp
  801a27:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a2a:	89 34 24             	mov    %esi,(%esp)
  801a2d:	e8 0e fc ff ff       	call   801640 <fd2num>
  801a32:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a35:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a39:	89 04 24             	mov    %eax,(%esp)
  801a3c:	e8 9c fc ff ff       	call   8016dd <fd_lookup>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 05                	js     801a4c <fd_close+0x2d>
  801a47:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a4a:	74 0c                	je     801a58 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a4c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801a50:	19 c0                	sbb    %eax,%eax
  801a52:	f7 d0                	not    %eax
  801a54:	21 c3                	and    %eax,%ebx
  801a56:	eb 3d                	jmp    801a95 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a58:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5f:	8b 06                	mov    (%esi),%eax
  801a61:	89 04 24             	mov    %eax,(%esp)
  801a64:	e8 e8 fc ff ff       	call   801751 <dev_lookup>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 16                	js     801a85 <fd_close+0x66>
		if (dev->dev_close)
  801a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a72:	8b 40 10             	mov    0x10(%eax),%eax
  801a75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	74 07                	je     801a85 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801a7e:	89 34 24             	mov    %esi,(%esp)
  801a81:	ff d0                	call   *%eax
  801a83:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a85:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a90:	e8 29 f9 ff ff       	call   8013be <sys_page_unmap>
	return r;
}
  801a95:	89 d8                	mov    %ebx,%eax
  801a97:	83 c4 20             	add    $0x20,%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5e                   	pop    %esi
  801a9c:	5d                   	pop    %ebp
  801a9d:	c3                   	ret    

00801a9e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	89 04 24             	mov    %eax,(%esp)
  801ab1:	e8 27 fc ff ff       	call   8016dd <fd_lookup>
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 13                	js     801acd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801aba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ac1:	00 
  801ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac5:	89 04 24             	mov    %eax,(%esp)
  801ac8:	e8 52 ff ff ff       	call   801a1f <fd_close>
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	83 ec 18             	sub    $0x18,%esp
  801ad5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ad8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801adb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ae2:	00 
  801ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae6:	89 04 24             	mov    %eax,(%esp)
  801ae9:	e8 79 03 00 00       	call   801e67 <open>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 1b                	js     801b0f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	89 1c 24             	mov    %ebx,(%esp)
  801afe:	e8 b7 fc ff ff       	call   8017ba <fstat>
  801b03:	89 c6                	mov    %eax,%esi
	close(fd);
  801b05:	89 1c 24             	mov    %ebx,(%esp)
  801b08:	e8 91 ff ff ff       	call   801a9e <close>
  801b0d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b0f:	89 d8                	mov    %ebx,%eax
  801b11:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b14:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b17:	89 ec                	mov    %ebp,%esp
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	53                   	push   %ebx
  801b1f:	83 ec 14             	sub    $0x14,%esp
  801b22:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b27:	89 1c 24             	mov    %ebx,(%esp)
  801b2a:	e8 6f ff ff ff       	call   801a9e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b2f:	83 c3 01             	add    $0x1,%ebx
  801b32:	83 fb 20             	cmp    $0x20,%ebx
  801b35:	75 f0                	jne    801b27 <close_all+0xc>
		close(i);
}
  801b37:	83 c4 14             	add    $0x14,%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 58             	sub    $0x58,%esp
  801b43:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b46:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b49:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b4c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	89 04 24             	mov    %eax,(%esp)
  801b5c:	e8 7c fb ff ff       	call   8016dd <fd_lookup>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	85 c0                	test   %eax,%eax
  801b65:	0f 88 e0 00 00 00    	js     801c4b <dup+0x10e>
		return r;
	close(newfdnum);
  801b6b:	89 3c 24             	mov    %edi,(%esp)
  801b6e:	e8 2b ff ff ff       	call   801a9e <close>

	newfd = INDEX2FD(newfdnum);
  801b73:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b79:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7f:	89 04 24             	mov    %eax,(%esp)
  801b82:	e8 c9 fa ff ff       	call   801650 <fd2data>
  801b87:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b89:	89 34 24             	mov    %esi,(%esp)
  801b8c:	e8 bf fa ff ff       	call   801650 <fd2data>
  801b91:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801b94:	89 da                	mov    %ebx,%edx
  801b96:	89 d8                	mov    %ebx,%eax
  801b98:	c1 e8 16             	shr    $0x16,%eax
  801b9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ba2:	a8 01                	test   $0x1,%al
  801ba4:	74 43                	je     801be9 <dup+0xac>
  801ba6:	c1 ea 0c             	shr    $0xc,%edx
  801ba9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bb0:	a8 01                	test   $0x1,%al
  801bb2:	74 35                	je     801be9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bb4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bbb:	25 07 0e 00 00       	and    $0xe07,%eax
  801bc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801bc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801bc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bd2:	00 
  801bd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bde:	e8 47 f8 ff ff       	call   80142a <sys_page_map>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 3f                	js     801c28 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801be9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bec:	89 c2                	mov    %eax,%edx
  801bee:	c1 ea 0c             	shr    $0xc,%edx
  801bf1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bf8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801bfe:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c02:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c06:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c0d:	00 
  801c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c19:	e8 0c f8 ff ff       	call   80142a <sys_page_map>
  801c1e:	89 c3                	mov    %eax,%ebx
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 04                	js     801c28 <dup+0xeb>
  801c24:	89 fb                	mov    %edi,%ebx
  801c26:	eb 23                	jmp    801c4b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c33:	e8 86 f7 ff ff       	call   8013be <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c46:	e8 73 f7 ff ff       	call   8013be <sys_page_unmap>
	return r;
}
  801c4b:	89 d8                	mov    %ebx,%eax
  801c4d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c50:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c53:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c56:	89 ec                	mov    %ebp,%esp
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    
	...

00801c5c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 18             	sub    $0x18,%esp
  801c62:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c65:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c68:	89 c3                	mov    %eax,%ebx
  801c6a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c6c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c73:	75 11                	jne    801c86 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c75:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c7c:	e8 9f 07 00 00       	call   802420 <ipc_find_env>
  801c81:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c86:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c8d:	00 
  801c8e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c95:	00 
  801c96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c9a:	a1 00 40 80 00       	mov    0x804000,%eax
  801c9f:	89 04 24             	mov    %eax,(%esp)
  801ca2:	e8 c4 07 00 00       	call   80246b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ca7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cae:	00 
  801caf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cba:	e8 2a 08 00 00       	call   8024e9 <ipc_recv>
}
  801cbf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cc2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cc5:	89 ec                	mov    %ebp,%esp
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd2:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce7:	b8 02 00 00 00       	mov    $0x2,%eax
  801cec:	e8 6b ff ff ff       	call   801c5c <fsipc>
}
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfc:	8b 40 0c             	mov    0xc(%eax),%eax
  801cff:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d04:	ba 00 00 00 00       	mov    $0x0,%edx
  801d09:	b8 06 00 00 00       	mov    $0x6,%eax
  801d0e:	e8 49 ff ff ff       	call   801c5c <fsipc>
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d20:	b8 08 00 00 00       	mov    $0x8,%eax
  801d25:	e8 32 ff ff ff       	call   801c5c <fsipc>
}
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 14             	sub    $0x14,%esp
  801d33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	8b 40 0c             	mov    0xc(%eax),%eax
  801d3c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d41:	ba 00 00 00 00       	mov    $0x0,%edx
  801d46:	b8 05 00 00 00       	mov    $0x5,%eax
  801d4b:	e8 0c ff ff ff       	call   801c5c <fsipc>
  801d50:	85 c0                	test   %eax,%eax
  801d52:	78 2b                	js     801d7f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d54:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d5b:	00 
  801d5c:	89 1c 24             	mov    %ebx,(%esp)
  801d5f:	e8 06 ee ff ff       	call   800b6a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d64:	a1 80 50 80 00       	mov    0x805080,%eax
  801d69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d6f:	a1 84 50 80 00       	mov    0x805084,%eax
  801d74:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d7a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d7f:	83 c4 14             	add    $0x14,%esp
  801d82:	5b                   	pop    %ebx
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	83 ec 18             	sub    $0x18,%esp
  801d8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d93:	76 05                	jbe    801d9a <devfile_write+0x15>
  801d95:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  801d9d:	8b 52 0c             	mov    0xc(%edx),%edx
  801da0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801da6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801dab:	89 44 24 08          	mov    %eax,0x8(%esp)
  801daf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801dbd:	e8 93 ef ff ff       	call   800d55 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dcc:	e8 8b fe ff ff       	call   801c5c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	53                   	push   %ebx
  801dd7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	8b 40 0c             	mov    0xc(%eax),%eax
  801de0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801de5:	8b 45 10             	mov    0x10(%ebp),%eax
  801de8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801ded:	ba 00 00 00 00       	mov    $0x0,%edx
  801df2:	b8 03 00 00 00       	mov    $0x3,%eax
  801df7:	e8 60 fe ff ff       	call   801c5c <fsipc>
  801dfc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 17                	js     801e19 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801e02:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e06:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e0d:	00 
  801e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e11:	89 04 24             	mov    %eax,(%esp)
  801e14:	e8 3c ef ff ff       	call   800d55 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801e19:	89 d8                	mov    %ebx,%eax
  801e1b:	83 c4 14             	add    $0x14,%esp
  801e1e:	5b                   	pop    %ebx
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	53                   	push   %ebx
  801e25:	83 ec 14             	sub    $0x14,%esp
  801e28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e2b:	89 1c 24             	mov    %ebx,(%esp)
  801e2e:	e8 ed ec ff ff       	call   800b20 <strlen>
  801e33:	89 c2                	mov    %eax,%edx
  801e35:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e3a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e40:	7f 1f                	jg     801e61 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e46:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e4d:	e8 18 ed ff ff       	call   800b6a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e52:	ba 00 00 00 00       	mov    $0x0,%edx
  801e57:	b8 07 00 00 00       	mov    $0x7,%eax
  801e5c:	e8 fb fd ff ff       	call   801c5c <fsipc>
}
  801e61:	83 c4 14             	add    $0x14,%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 28             	sub    $0x28,%esp
  801e6d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e70:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e73:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801e76:	89 34 24             	mov    %esi,(%esp)
  801e79:	e8 a2 ec ff ff       	call   800b20 <strlen>
  801e7e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801e83:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e88:	7f 6d                	jg     801ef7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801e8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8d:	89 04 24             	mov    %eax,(%esp)
  801e90:	e8 d6 f7 ff ff       	call   80166b <fd_alloc>
  801e95:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e97:	85 c0                	test   %eax,%eax
  801e99:	78 5c                	js     801ef7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801ea3:	89 34 24             	mov    %esi,(%esp)
  801ea6:	e8 75 ec ff ff       	call   800b20 <strlen>
  801eab:	83 c0 01             	add    $0x1,%eax
  801eae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ebd:	e8 93 ee ff ff       	call   800d55 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801ec2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ec5:	b8 01 00 00 00       	mov    $0x1,%eax
  801eca:	e8 8d fd ff ff       	call   801c5c <fsipc>
  801ecf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	79 15                	jns    801eea <open+0x83>
             fd_close(fd,0);
  801ed5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801edc:	00 
  801edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee0:	89 04 24             	mov    %eax,(%esp)
  801ee3:	e8 37 fb ff ff       	call   801a1f <fd_close>
             return r;
  801ee8:	eb 0d                	jmp    801ef7 <open+0x90>
        }
        return fd2num(fd);
  801eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eed:	89 04 24             	mov    %eax,(%esp)
  801ef0:	e8 4b f7 ff ff       	call   801640 <fd2num>
  801ef5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801ef7:	89 d8                	mov    %ebx,%eax
  801ef9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801efc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801eff:	89 ec                	mov    %ebp,%esp
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    
	...

00801f10 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f16:	c7 44 24 04 d8 2c 80 	movl   $0x802cd8,0x4(%esp)
  801f1d:	00 
  801f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f21:	89 04 24             	mov    %eax,(%esp)
  801f24:	e8 41 ec ff ff       	call   800b6a <strcpy>
	return 0;
}
  801f29:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	53                   	push   %ebx
  801f34:	83 ec 14             	sub    $0x14,%esp
  801f37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f3a:	89 1c 24             	mov    %ebx,(%esp)
  801f3d:	e8 1a 06 00 00       	call   80255c <pageref>
  801f42:	89 c2                	mov    %eax,%edx
  801f44:	b8 00 00 00 00       	mov    $0x0,%eax
  801f49:	83 fa 01             	cmp    $0x1,%edx
  801f4c:	75 0b                	jne    801f59 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801f4e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 b9 02 00 00       	call   802212 <nsipc_close>
	else
		return 0;
}
  801f59:	83 c4 14             	add    $0x14,%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f65:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f6c:	00 
  801f6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f81:	89 04 24             	mov    %eax,(%esp)
  801f84:	e8 c5 02 00 00       	call   80224e <nsipc_send>
}
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    

00801f8b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f91:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f98:	00 
  801f99:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801faa:	8b 40 0c             	mov    0xc(%eax),%eax
  801fad:	89 04 24             	mov    %eax,(%esp)
  801fb0:	e8 0c 03 00 00       	call   8022c1 <nsipc_recv>
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	56                   	push   %esi
  801fbb:	53                   	push   %ebx
  801fbc:	83 ec 20             	sub    $0x20,%esp
  801fbf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc4:	89 04 24             	mov    %eax,(%esp)
  801fc7:	e8 9f f6 ff ff       	call   80166b <fd_alloc>
  801fcc:	89 c3                	mov    %eax,%ebx
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	78 21                	js     801ff3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fd2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fd9:	00 
  801fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe8:	e8 ab f4 ff ff       	call   801498 <sys_page_alloc>
  801fed:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	79 0a                	jns    801ffd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801ff3:	89 34 24             	mov    %esi,(%esp)
  801ff6:	e8 17 02 00 00       	call   802212 <nsipc_close>
		return r;
  801ffb:	eb 28                	jmp    802025 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ffd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802003:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802006:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802015:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201b:	89 04 24             	mov    %eax,(%esp)
  80201e:	e8 1d f6 ff ff       	call   801640 <fd2num>
  802023:	89 c3                	mov    %eax,%ebx
}
  802025:	89 d8                	mov    %ebx,%eax
  802027:	83 c4 20             	add    $0x20,%esp
  80202a:	5b                   	pop    %ebx
  80202b:	5e                   	pop    %esi
  80202c:	5d                   	pop    %ebp
  80202d:	c3                   	ret    

0080202e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802034:	8b 45 10             	mov    0x10(%ebp),%eax
  802037:	89 44 24 08          	mov    %eax,0x8(%esp)
  80203b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802042:	8b 45 08             	mov    0x8(%ebp),%eax
  802045:	89 04 24             	mov    %eax,(%esp)
  802048:	e8 79 01 00 00       	call   8021c6 <nsipc_socket>
  80204d:	85 c0                	test   %eax,%eax
  80204f:	78 05                	js     802056 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802051:	e8 61 ff ff ff       	call   801fb7 <alloc_sockfd>
}
  802056:	c9                   	leave  
  802057:	c3                   	ret    

00802058 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80205e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802061:	89 54 24 04          	mov    %edx,0x4(%esp)
  802065:	89 04 24             	mov    %eax,(%esp)
  802068:	e8 70 f6 ff ff       	call   8016dd <fd_lookup>
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 15                	js     802086 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802071:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802074:	8b 0a                	mov    (%edx),%ecx
  802076:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80207b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  802081:	75 03                	jne    802086 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802083:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	e8 c2 ff ff ff       	call   802058 <fd2sockid>
  802096:	85 c0                	test   %eax,%eax
  802098:	78 0f                	js     8020a9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80209a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80209d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020a1:	89 04 24             	mov    %eax,(%esp)
  8020a4:	e8 47 01 00 00       	call   8021f0 <nsipc_listen>
}
  8020a9:	c9                   	leave  
  8020aa:	c3                   	ret    

008020ab <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b4:	e8 9f ff ff ff       	call   802058 <fd2sockid>
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	78 16                	js     8020d3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8020bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8020c0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020cb:	89 04 24             	mov    %eax,(%esp)
  8020ce:	e8 6e 02 00 00       	call   802341 <nsipc_connect>
}
  8020d3:	c9                   	leave  
  8020d4:	c3                   	ret    

008020d5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020db:	8b 45 08             	mov    0x8(%ebp),%eax
  8020de:	e8 75 ff ff ff       	call   802058 <fd2sockid>
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 0f                	js     8020f6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020ee:	89 04 24             	mov    %eax,(%esp)
  8020f1:	e8 36 01 00 00       	call   80222c <nsipc_shutdown>
}
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802101:	e8 52 ff ff ff       	call   802058 <fd2sockid>
  802106:	85 c0                	test   %eax,%eax
  802108:	78 16                	js     802120 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80210a:	8b 55 10             	mov    0x10(%ebp),%edx
  80210d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802111:	8b 55 0c             	mov    0xc(%ebp),%edx
  802114:	89 54 24 04          	mov    %edx,0x4(%esp)
  802118:	89 04 24             	mov    %eax,(%esp)
  80211b:	e8 60 02 00 00       	call   802380 <nsipc_bind>
}
  802120:	c9                   	leave  
  802121:	c3                   	ret    

00802122 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802128:	8b 45 08             	mov    0x8(%ebp),%eax
  80212b:	e8 28 ff ff ff       	call   802058 <fd2sockid>
  802130:	85 c0                	test   %eax,%eax
  802132:	78 1f                	js     802153 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802134:	8b 55 10             	mov    0x10(%ebp),%edx
  802137:	89 54 24 08          	mov    %edx,0x8(%esp)
  80213b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80213e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802142:	89 04 24             	mov    %eax,(%esp)
  802145:	e8 75 02 00 00       	call   8023bf <nsipc_accept>
  80214a:	85 c0                	test   %eax,%eax
  80214c:	78 05                	js     802153 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80214e:	e8 64 fe ff ff       	call   801fb7 <alloc_sockfd>
}
  802153:	c9                   	leave  
  802154:	c3                   	ret    
	...

00802160 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	53                   	push   %ebx
  802164:	83 ec 14             	sub    $0x14,%esp
  802167:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802169:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  802170:	75 11                	jne    802183 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802172:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802179:	e8 a2 02 00 00       	call   802420 <ipc_find_env>
  80217e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802183:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80218a:	00 
  80218b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802192:	00 
  802193:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802197:	a1 04 40 80 00       	mov    0x804004,%eax
  80219c:	89 04 24             	mov    %eax,(%esp)
  80219f:	e8 c7 02 00 00       	call   80246b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021ab:	00 
  8021ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021b3:	00 
  8021b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021bb:	e8 29 03 00 00       	call   8024e9 <ipc_recv>
}
  8021c0:	83 c4 14             	add    $0x14,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    

008021c6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8021d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8021dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8021df:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8021e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8021e9:	e8 72 ff ff ff       	call   802160 <nsipc>
}
  8021ee:	c9                   	leave  
  8021ef:	c3                   	ret    

008021f0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8021fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802201:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802206:	b8 06 00 00 00       	mov    $0x6,%eax
  80220b:	e8 50 ff ff ff       	call   802160 <nsipc>
}
  802210:	c9                   	leave  
  802211:	c3                   	ret    

00802212 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802212:	55                   	push   %ebp
  802213:	89 e5                	mov    %esp,%ebp
  802215:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802218:	8b 45 08             	mov    0x8(%ebp),%eax
  80221b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802220:	b8 04 00 00 00       	mov    $0x4,%eax
  802225:	e8 36 ff ff ff       	call   802160 <nsipc>
}
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802232:	8b 45 08             	mov    0x8(%ebp),%eax
  802235:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80223a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802242:	b8 03 00 00 00       	mov    $0x3,%eax
  802247:	e8 14 ff ff ff       	call   802160 <nsipc>
}
  80224c:	c9                   	leave  
  80224d:	c3                   	ret    

0080224e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	53                   	push   %ebx
  802252:	83 ec 14             	sub    $0x14,%esp
  802255:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
  80225b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802260:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802266:	7e 24                	jle    80228c <nsipc_send+0x3e>
  802268:	c7 44 24 0c e4 2c 80 	movl   $0x802ce4,0xc(%esp)
  80226f:	00 
  802270:	c7 44 24 08 f0 2c 80 	movl   $0x802cf0,0x8(%esp)
  802277:	00 
  802278:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80227f:	00 
  802280:	c7 04 24 05 2d 80 00 	movl   $0x802d05,(%esp)
  802287:	e8 f4 de ff ff       	call   800180 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80228c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802290:	8b 45 0c             	mov    0xc(%ebp),%eax
  802293:	89 44 24 04          	mov    %eax,0x4(%esp)
  802297:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80229e:	e8 b2 ea ff ff       	call   800d55 <memmove>
	nsipcbuf.send.req_size = size;
  8022a3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8022a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8022ac:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8022b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8022b6:	e8 a5 fe ff ff       	call   802160 <nsipc>
}
  8022bb:	83 c4 14             	add    $0x14,%esp
  8022be:	5b                   	pop    %ebx
  8022bf:	5d                   	pop    %ebp
  8022c0:	c3                   	ret    

008022c1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022c1:	55                   	push   %ebp
  8022c2:	89 e5                	mov    %esp,%ebp
  8022c4:	56                   	push   %esi
  8022c5:	53                   	push   %ebx
  8022c6:	83 ec 10             	sub    $0x10,%esp
  8022c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8022d4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8022da:	8b 45 14             	mov    0x14(%ebp),%eax
  8022dd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8022e7:	e8 74 fe ff ff       	call   802160 <nsipc>
  8022ec:	89 c3                	mov    %eax,%ebx
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	78 46                	js     802338 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8022f2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022f7:	7f 04                	jg     8022fd <nsipc_recv+0x3c>
  8022f9:	39 c6                	cmp    %eax,%esi
  8022fb:	7d 24                	jge    802321 <nsipc_recv+0x60>
  8022fd:	c7 44 24 0c 11 2d 80 	movl   $0x802d11,0xc(%esp)
  802304:	00 
  802305:	c7 44 24 08 f0 2c 80 	movl   $0x802cf0,0x8(%esp)
  80230c:	00 
  80230d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802314:	00 
  802315:	c7 04 24 05 2d 80 00 	movl   $0x802d05,(%esp)
  80231c:	e8 5f de ff ff       	call   800180 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802321:	89 44 24 08          	mov    %eax,0x8(%esp)
  802325:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80232c:	00 
  80232d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802330:	89 04 24             	mov    %eax,(%esp)
  802333:	e8 1d ea ff ff       	call   800d55 <memmove>
	}

	return r;
}
  802338:	89 d8                	mov    %ebx,%eax
  80233a:	83 c4 10             	add    $0x10,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	53                   	push   %ebx
  802345:	83 ec 14             	sub    $0x14,%esp
  802348:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80234b:	8b 45 08             	mov    0x8(%ebp),%eax
  80234e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802353:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802357:	8b 45 0c             	mov    0xc(%ebp),%eax
  80235a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802365:	e8 eb e9 ff ff       	call   800d55 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80236a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802370:	b8 05 00 00 00       	mov    $0x5,%eax
  802375:	e8 e6 fd ff ff       	call   802160 <nsipc>
}
  80237a:	83 c4 14             	add    $0x14,%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5d                   	pop    %ebp
  80237f:	c3                   	ret    

00802380 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	53                   	push   %ebx
  802384:	83 ec 14             	sub    $0x14,%esp
  802387:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80238a:	8b 45 08             	mov    0x8(%ebp),%eax
  80238d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802392:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802396:	8b 45 0c             	mov    0xc(%ebp),%eax
  802399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80239d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8023a4:	e8 ac e9 ff ff       	call   800d55 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8023a9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8023af:	b8 02 00 00 00       	mov    $0x2,%eax
  8023b4:	e8 a7 fd ff ff       	call   802160 <nsipc>
}
  8023b9:	83 c4 14             	add    $0x14,%esp
  8023bc:	5b                   	pop    %ebx
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    

008023bf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8023bf:	55                   	push   %ebp
  8023c0:	89 e5                	mov    %esp,%ebp
  8023c2:	83 ec 18             	sub    $0x18,%esp
  8023c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8023c8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8023cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ce:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8023d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d8:	e8 83 fd ff ff       	call   802160 <nsipc>
  8023dd:	89 c3                	mov    %eax,%ebx
  8023df:	85 c0                	test   %eax,%eax
  8023e1:	78 25                	js     802408 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8023e3:	be 10 60 80 00       	mov    $0x806010,%esi
  8023e8:	8b 06                	mov    (%esi),%eax
  8023ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023ee:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8023f5:	00 
  8023f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f9:	89 04 24             	mov    %eax,(%esp)
  8023fc:	e8 54 e9 ff ff       	call   800d55 <memmove>
		*addrlen = ret->ret_addrlen;
  802401:	8b 16                	mov    (%esi),%edx
  802403:	8b 45 10             	mov    0x10(%ebp),%eax
  802406:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802408:	89 d8                	mov    %ebx,%eax
  80240a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80240d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802410:	89 ec                	mov    %ebp,%esp
  802412:	5d                   	pop    %ebp
  802413:	c3                   	ret    
	...

00802420 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802426:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80242c:	b8 01 00 00 00       	mov    $0x1,%eax
  802431:	39 ca                	cmp    %ecx,%edx
  802433:	75 04                	jne    802439 <ipc_find_env+0x19>
  802435:	b0 00                	mov    $0x0,%al
  802437:	eb 12                	jmp    80244b <ipc_find_env+0x2b>
  802439:	89 c2                	mov    %eax,%edx
  80243b:	c1 e2 07             	shl    $0x7,%edx
  80243e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802445:	8b 12                	mov    (%edx),%edx
  802447:	39 ca                	cmp    %ecx,%edx
  802449:	75 10                	jne    80245b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80244b:	89 c2                	mov    %eax,%edx
  80244d:	c1 e2 07             	shl    $0x7,%edx
  802450:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802457:	8b 00                	mov    (%eax),%eax
  802459:	eb 0e                	jmp    802469 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80245b:	83 c0 01             	add    $0x1,%eax
  80245e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802463:	75 d4                	jne    802439 <ipc_find_env+0x19>
  802465:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    

0080246b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	57                   	push   %edi
  80246f:	56                   	push   %esi
  802470:	53                   	push   %ebx
  802471:	83 ec 1c             	sub    $0x1c,%esp
  802474:	8b 75 08             	mov    0x8(%ebp),%esi
  802477:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80247a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80247d:	85 db                	test   %ebx,%ebx
  80247f:	74 19                	je     80249a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802481:	8b 45 14             	mov    0x14(%ebp),%eax
  802484:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802488:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802490:	89 34 24             	mov    %esi,(%esp)
  802493:	e8 a1 ed ff ff       	call   801239 <sys_ipc_try_send>
  802498:	eb 1b                	jmp    8024b5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80249a:	8b 45 14             	mov    0x14(%ebp),%eax
  80249d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024a1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8024a8:	ee 
  8024a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024ad:	89 34 24             	mov    %esi,(%esp)
  8024b0:	e8 84 ed ff ff       	call   801239 <sys_ipc_try_send>
           if(ret == 0)
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	74 28                	je     8024e1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8024b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024bc:	74 1c                	je     8024da <ipc_send+0x6f>
              panic("ipc send error");
  8024be:	c7 44 24 08 26 2d 80 	movl   $0x802d26,0x8(%esp)
  8024c5:	00 
  8024c6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8024cd:	00 
  8024ce:	c7 04 24 35 2d 80 00 	movl   $0x802d35,(%esp)
  8024d5:	e8 a6 dc ff ff       	call   800180 <_panic>
           sys_yield();
  8024da:	e8 26 f0 ff ff       	call   801505 <sys_yield>
        }
  8024df:	eb 9c                	jmp    80247d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8024e1:	83 c4 1c             	add    $0x1c,%esp
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5f                   	pop    %edi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    

008024e9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	56                   	push   %esi
  8024ed:	53                   	push   %ebx
  8024ee:	83 ec 10             	sub    $0x10,%esp
  8024f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8024f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8024fa:	85 c0                	test   %eax,%eax
  8024fc:	75 0e                	jne    80250c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8024fe:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802505:	e8 c4 ec ff ff       	call   8011ce <sys_ipc_recv>
  80250a:	eb 08                	jmp    802514 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80250c:	89 04 24             	mov    %eax,(%esp)
  80250f:	e8 ba ec ff ff       	call   8011ce <sys_ipc_recv>
        if(ret == 0){
  802514:	85 c0                	test   %eax,%eax
  802516:	75 26                	jne    80253e <ipc_recv+0x55>
           if(from_env_store)
  802518:	85 f6                	test   %esi,%esi
  80251a:	74 0a                	je     802526 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80251c:	a1 08 40 80 00       	mov    0x804008,%eax
  802521:	8b 40 78             	mov    0x78(%eax),%eax
  802524:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802526:	85 db                	test   %ebx,%ebx
  802528:	74 0a                	je     802534 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80252a:	a1 08 40 80 00       	mov    0x804008,%eax
  80252f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802532:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802534:	a1 08 40 80 00       	mov    0x804008,%eax
  802539:	8b 40 74             	mov    0x74(%eax),%eax
  80253c:	eb 14                	jmp    802552 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80253e:	85 f6                	test   %esi,%esi
  802540:	74 06                	je     802548 <ipc_recv+0x5f>
              *from_env_store = 0;
  802542:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802548:	85 db                	test   %ebx,%ebx
  80254a:	74 06                	je     802552 <ipc_recv+0x69>
              *perm_store = 0;
  80254c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802552:	83 c4 10             	add    $0x10,%esp
  802555:	5b                   	pop    %ebx
  802556:	5e                   	pop    %esi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    
  802559:	00 00                	add    %al,(%eax)
	...

0080255c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80255c:	55                   	push   %ebp
  80255d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80255f:	8b 45 08             	mov    0x8(%ebp),%eax
  802562:	89 c2                	mov    %eax,%edx
  802564:	c1 ea 16             	shr    $0x16,%edx
  802567:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80256e:	f6 c2 01             	test   $0x1,%dl
  802571:	74 20                	je     802593 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802573:	c1 e8 0c             	shr    $0xc,%eax
  802576:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80257d:	a8 01                	test   $0x1,%al
  80257f:	74 12                	je     802593 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802581:	c1 e8 0c             	shr    $0xc,%eax
  802584:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802589:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80258e:	0f b7 c0             	movzwl %ax,%eax
  802591:	eb 05                	jmp    802598 <pageref+0x3c>
  802593:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802598:	5d                   	pop    %ebp
  802599:	c3                   	ret    
  80259a:	00 00                	add    %al,(%eax)
  80259c:	00 00                	add    %al,(%eax)
	...

008025a0 <__udivdi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	89 e5                	mov    %esp,%ebp
  8025a3:	57                   	push   %edi
  8025a4:	56                   	push   %esi
  8025a5:	83 ec 10             	sub    $0x10,%esp
  8025a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8025ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8025b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8025b9:	75 35                	jne    8025f0 <__udivdi3+0x50>
  8025bb:	39 fe                	cmp    %edi,%esi
  8025bd:	77 61                	ja     802620 <__udivdi3+0x80>
  8025bf:	85 f6                	test   %esi,%esi
  8025c1:	75 0b                	jne    8025ce <__udivdi3+0x2e>
  8025c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c8:	31 d2                	xor    %edx,%edx
  8025ca:	f7 f6                	div    %esi
  8025cc:	89 c6                	mov    %eax,%esi
  8025ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8025d1:	31 d2                	xor    %edx,%edx
  8025d3:	89 f8                	mov    %edi,%eax
  8025d5:	f7 f6                	div    %esi
  8025d7:	89 c7                	mov    %eax,%edi
  8025d9:	89 c8                	mov    %ecx,%eax
  8025db:	f7 f6                	div    %esi
  8025dd:	89 c1                	mov    %eax,%ecx
  8025df:	89 fa                	mov    %edi,%edx
  8025e1:	89 c8                	mov    %ecx,%eax
  8025e3:	83 c4 10             	add    $0x10,%esp
  8025e6:	5e                   	pop    %esi
  8025e7:	5f                   	pop    %edi
  8025e8:	5d                   	pop    %ebp
  8025e9:	c3                   	ret    
  8025ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f0:	39 f8                	cmp    %edi,%eax
  8025f2:	77 1c                	ja     802610 <__udivdi3+0x70>
  8025f4:	0f bd d0             	bsr    %eax,%edx
  8025f7:	83 f2 1f             	xor    $0x1f,%edx
  8025fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8025fd:	75 39                	jne    802638 <__udivdi3+0x98>
  8025ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802602:	0f 86 a0 00 00 00    	jbe    8026a8 <__udivdi3+0x108>
  802608:	39 f8                	cmp    %edi,%eax
  80260a:	0f 82 98 00 00 00    	jb     8026a8 <__udivdi3+0x108>
  802610:	31 ff                	xor    %edi,%edi
  802612:	31 c9                	xor    %ecx,%ecx
  802614:	89 c8                	mov    %ecx,%eax
  802616:	89 fa                	mov    %edi,%edx
  802618:	83 c4 10             	add    $0x10,%esp
  80261b:	5e                   	pop    %esi
  80261c:	5f                   	pop    %edi
  80261d:	5d                   	pop    %ebp
  80261e:	c3                   	ret    
  80261f:	90                   	nop
  802620:	89 d1                	mov    %edx,%ecx
  802622:	89 fa                	mov    %edi,%edx
  802624:	89 c8                	mov    %ecx,%eax
  802626:	31 ff                	xor    %edi,%edi
  802628:	f7 f6                	div    %esi
  80262a:	89 c1                	mov    %eax,%ecx
  80262c:	89 fa                	mov    %edi,%edx
  80262e:	89 c8                	mov    %ecx,%eax
  802630:	83 c4 10             	add    $0x10,%esp
  802633:	5e                   	pop    %esi
  802634:	5f                   	pop    %edi
  802635:	5d                   	pop    %ebp
  802636:	c3                   	ret    
  802637:	90                   	nop
  802638:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80263c:	89 f2                	mov    %esi,%edx
  80263e:	d3 e0                	shl    %cl,%eax
  802640:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802643:	b8 20 00 00 00       	mov    $0x20,%eax
  802648:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80264b:	89 c1                	mov    %eax,%ecx
  80264d:	d3 ea                	shr    %cl,%edx
  80264f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802653:	0b 55 ec             	or     -0x14(%ebp),%edx
  802656:	d3 e6                	shl    %cl,%esi
  802658:	89 c1                	mov    %eax,%ecx
  80265a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80265d:	89 fe                	mov    %edi,%esi
  80265f:	d3 ee                	shr    %cl,%esi
  802661:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802665:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80266b:	d3 e7                	shl    %cl,%edi
  80266d:	89 c1                	mov    %eax,%ecx
  80266f:	d3 ea                	shr    %cl,%edx
  802671:	09 d7                	or     %edx,%edi
  802673:	89 f2                	mov    %esi,%edx
  802675:	89 f8                	mov    %edi,%eax
  802677:	f7 75 ec             	divl   -0x14(%ebp)
  80267a:	89 d6                	mov    %edx,%esi
  80267c:	89 c7                	mov    %eax,%edi
  80267e:	f7 65 e8             	mull   -0x18(%ebp)
  802681:	39 d6                	cmp    %edx,%esi
  802683:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802686:	72 30                	jb     8026b8 <__udivdi3+0x118>
  802688:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80268b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80268f:	d3 e2                	shl    %cl,%edx
  802691:	39 c2                	cmp    %eax,%edx
  802693:	73 05                	jae    80269a <__udivdi3+0xfa>
  802695:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802698:	74 1e                	je     8026b8 <__udivdi3+0x118>
  80269a:	89 f9                	mov    %edi,%ecx
  80269c:	31 ff                	xor    %edi,%edi
  80269e:	e9 71 ff ff ff       	jmp    802614 <__udivdi3+0x74>
  8026a3:	90                   	nop
  8026a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a8:	31 ff                	xor    %edi,%edi
  8026aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8026af:	e9 60 ff ff ff       	jmp    802614 <__udivdi3+0x74>
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8026bb:	31 ff                	xor    %edi,%edi
  8026bd:	89 c8                	mov    %ecx,%eax
  8026bf:	89 fa                	mov    %edi,%edx
  8026c1:	83 c4 10             	add    $0x10,%esp
  8026c4:	5e                   	pop    %esi
  8026c5:	5f                   	pop    %edi
  8026c6:	5d                   	pop    %ebp
  8026c7:	c3                   	ret    
	...

008026d0 <__umoddi3>:
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	57                   	push   %edi
  8026d4:	56                   	push   %esi
  8026d5:	83 ec 20             	sub    $0x20,%esp
  8026d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8026db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8026e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e4:	85 d2                	test   %edx,%edx
  8026e6:	89 c8                	mov    %ecx,%eax
  8026e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8026eb:	75 13                	jne    802700 <__umoddi3+0x30>
  8026ed:	39 f7                	cmp    %esi,%edi
  8026ef:	76 3f                	jbe    802730 <__umoddi3+0x60>
  8026f1:	89 f2                	mov    %esi,%edx
  8026f3:	f7 f7                	div    %edi
  8026f5:	89 d0                	mov    %edx,%eax
  8026f7:	31 d2                	xor    %edx,%edx
  8026f9:	83 c4 20             	add    $0x20,%esp
  8026fc:	5e                   	pop    %esi
  8026fd:	5f                   	pop    %edi
  8026fe:	5d                   	pop    %ebp
  8026ff:	c3                   	ret    
  802700:	39 f2                	cmp    %esi,%edx
  802702:	77 4c                	ja     802750 <__umoddi3+0x80>
  802704:	0f bd ca             	bsr    %edx,%ecx
  802707:	83 f1 1f             	xor    $0x1f,%ecx
  80270a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80270d:	75 51                	jne    802760 <__umoddi3+0x90>
  80270f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802712:	0f 87 e0 00 00 00    	ja     8027f8 <__umoddi3+0x128>
  802718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80271b:	29 f8                	sub    %edi,%eax
  80271d:	19 d6                	sbb    %edx,%esi
  80271f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802725:	89 f2                	mov    %esi,%edx
  802727:	83 c4 20             	add    $0x20,%esp
  80272a:	5e                   	pop    %esi
  80272b:	5f                   	pop    %edi
  80272c:	5d                   	pop    %ebp
  80272d:	c3                   	ret    
  80272e:	66 90                	xchg   %ax,%ax
  802730:	85 ff                	test   %edi,%edi
  802732:	75 0b                	jne    80273f <__umoddi3+0x6f>
  802734:	b8 01 00 00 00       	mov    $0x1,%eax
  802739:	31 d2                	xor    %edx,%edx
  80273b:	f7 f7                	div    %edi
  80273d:	89 c7                	mov    %eax,%edi
  80273f:	89 f0                	mov    %esi,%eax
  802741:	31 d2                	xor    %edx,%edx
  802743:	f7 f7                	div    %edi
  802745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802748:	f7 f7                	div    %edi
  80274a:	eb a9                	jmp    8026f5 <__umoddi3+0x25>
  80274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802750:	89 c8                	mov    %ecx,%eax
  802752:	89 f2                	mov    %esi,%edx
  802754:	83 c4 20             	add    $0x20,%esp
  802757:	5e                   	pop    %esi
  802758:	5f                   	pop    %edi
  802759:	5d                   	pop    %ebp
  80275a:	c3                   	ret    
  80275b:	90                   	nop
  80275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802760:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802764:	d3 e2                	shl    %cl,%edx
  802766:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802769:	ba 20 00 00 00       	mov    $0x20,%edx
  80276e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802771:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802774:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802778:	89 fa                	mov    %edi,%edx
  80277a:	d3 ea                	shr    %cl,%edx
  80277c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802780:	0b 55 f4             	or     -0xc(%ebp),%edx
  802783:	d3 e7                	shl    %cl,%edi
  802785:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802789:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80278c:	89 f2                	mov    %esi,%edx
  80278e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802791:	89 c7                	mov    %eax,%edi
  802793:	d3 ea                	shr    %cl,%edx
  802795:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802799:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80279c:	89 c2                	mov    %eax,%edx
  80279e:	d3 e6                	shl    %cl,%esi
  8027a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027a4:	d3 ea                	shr    %cl,%edx
  8027a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027aa:	09 d6                	or     %edx,%esi
  8027ac:	89 f0                	mov    %esi,%eax
  8027ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8027b1:	d3 e7                	shl    %cl,%edi
  8027b3:	89 f2                	mov    %esi,%edx
  8027b5:	f7 75 f4             	divl   -0xc(%ebp)
  8027b8:	89 d6                	mov    %edx,%esi
  8027ba:	f7 65 e8             	mull   -0x18(%ebp)
  8027bd:	39 d6                	cmp    %edx,%esi
  8027bf:	72 2b                	jb     8027ec <__umoddi3+0x11c>
  8027c1:	39 c7                	cmp    %eax,%edi
  8027c3:	72 23                	jb     8027e8 <__umoddi3+0x118>
  8027c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027c9:	29 c7                	sub    %eax,%edi
  8027cb:	19 d6                	sbb    %edx,%esi
  8027cd:	89 f0                	mov    %esi,%eax
  8027cf:	89 f2                	mov    %esi,%edx
  8027d1:	d3 ef                	shr    %cl,%edi
  8027d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027d7:	d3 e0                	shl    %cl,%eax
  8027d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027dd:	09 f8                	or     %edi,%eax
  8027df:	d3 ea                	shr    %cl,%edx
  8027e1:	83 c4 20             	add    $0x20,%esp
  8027e4:	5e                   	pop    %esi
  8027e5:	5f                   	pop    %edi
  8027e6:	5d                   	pop    %ebp
  8027e7:	c3                   	ret    
  8027e8:	39 d6                	cmp    %edx,%esi
  8027ea:	75 d9                	jne    8027c5 <__umoddi3+0xf5>
  8027ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8027ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8027f2:	eb d1                	jmp    8027c5 <__umoddi3+0xf5>
  8027f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	39 f2                	cmp    %esi,%edx
  8027fa:	0f 82 18 ff ff ff    	jb     802718 <__umoddi3+0x48>
  802800:	e9 1d ff ff ff       	jmp    802722 <__umoddi3+0x52>
