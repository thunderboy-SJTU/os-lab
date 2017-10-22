
obj/user/writemotd.debug:     file format elf32-i386


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
  80002c:	e8 13 02 00 00       	call   800244 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 2c 02 00 00    	sub    $0x22c,%esp
	int rfd, wfd;
	char buf[512];
	int n, r;

	if ((rfd = open("/newmotd", O_RDONLY)) < 0)
  800040:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800047:	00 
  800048:	c7 04 24 e0 22 80 00 	movl   $0x8022e0,(%esp)
  80004f:	e8 33 1e 00 00       	call   801e87 <open>
  800054:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 e9 22 80 	movl   $0x8022e9,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  800079:	e8 36 02 00 00       	call   8002b4 <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  80008d:	e8 f5 1d 00 00       	call   801e87 <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 12 23 80 	movl   $0x802312,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  8000b3:	e8 fc 01 00 00       	call   8002b4 <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 21 23 80 00 	movl   $0x802321,(%esp)
  8000cd:	e8 9b 02 00 00       	call   80036d <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd e4 fd ff ff    	cmp    %edi,-0x21c(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 8c 23 80 	movl   $0x80238c,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  8000f1:	e8 be 01 00 00       	call   8002b4 <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 39 23 80 00 	movl   $0x802339,(%esp)
  8000fd:	e8 6b 02 00 00       	call   80036d <cprintf>
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800102:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800108:	eb 0c                	jmp    800116 <umain+0xe2>
		sys_cputs(buf, n);
  80010a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010e:	89 1c 24             	mov    %ebx,(%esp)
  800111:	e8 b6 0f 00 00       	call   8010cc <sys_cputs>
	cprintf("file descriptors %d %d\n", rfd, wfd);
	if (rfd == wfd)
		panic("open /newmotd and /motd give same file descriptor");

	cprintf("OLD MOTD\n===\n");
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800116:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  80011d:	00 
  80011e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800122:	89 3c 24             	mov    %edi,(%esp)
  800125:	e8 34 18 00 00       	call   80195e <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
		sys_cputs(buf, n);
	cprintf("===\n");
  80012e:	c7 04 24 42 23 80 00 	movl   $0x802342,(%esp)
  800135:	e8 33 02 00 00       	call   80036d <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 fb 15 00 00       	call   801745 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 f9 16 00 00       	call   801853 <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 47 23 80 	movl   $0x802347,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  800179:	e8 36 01 00 00       	call   8002b4 <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 5a 23 80 00 	movl   $0x80235a,(%esp)
  800185:	e8 e3 01 00 00       	call   80036d <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  80018a:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  800190:	eb 40                	jmp    8001d2 <umain+0x19e>
		sys_cputs(buf, n);
  800192:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 2e 0f 00 00       	call   8010cc <sys_cputs>
		if ((r = write(wfd, buf, n)) != n)
  80019e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a6:	89 3c 24             	mov    %edi,(%esp)
  8001a9:	e8 27 17 00 00       	call   8018d5 <write>
  8001ae:	39 c3                	cmp    %eax,%ebx
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 68 23 80 	movl   $0x802368,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  8001cd:	e8 e2 00 00 00       	call   8002b4 <_panic>

	if ((r = ftruncate(wfd, 0)) < 0)
		panic("truncate /motd: %e", r);

	cprintf("NEW MOTD\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  8001d2:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  8001d9:	00 
  8001da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001de:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 72 17 00 00       	call   80195e <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
		sys_cputs(buf, n);
		if ((r = write(wfd, buf, n)) != n)
			panic("write /motd: %e", r);
	}
	cprintf("===\n");
  8001f2:	c7 04 24 42 23 80 00 	movl   $0x802342,(%esp)
  8001f9:	e8 6f 01 00 00       	call   80036d <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 78 23 80 	movl   $0x802378,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  80021d:	e8 92 00 00 00       	call   8002b4 <_panic>

	close(rfd);
  800222:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 8e 18 00 00       	call   801abe <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 86 18 00 00       	call   801abe <close>
}
  800238:	81 c4 2c 02 00 00    	add    $0x22c,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5f                   	pop    %edi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    
	...

00800244 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
  80024a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80024d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800256:	e8 57 13 00 00       	call   8015b2 <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	89 c2                	mov    %eax,%edx
  800262:	c1 e2 07             	shl    $0x7,%edx
  800265:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80026c:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800271:	85 f6                	test   %esi,%esi
  800273:	7e 07                	jle    80027c <libmain+0x38>
		binaryname = argv[0];
  800275:	8b 03                	mov    (%ebx),%eax
  800277:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80027c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800280:	89 34 24             	mov    %esi,(%esp)
  800283:	e8 ac fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800288:	e8 0b 00 00 00       	call   800298 <exit>
}
  80028d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800290:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800293:	89 ec                	mov    %ebp,%esp
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    
	...

00800298 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80029e:	e8 98 18 00 00       	call   801b3b <close_all>
	sys_env_destroy(0);
  8002a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002aa:	e8 43 13 00 00       	call   8015f2 <sys_env_destroy>
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    
  8002b1:	00 00                	add    %al,(%eax)
	...

008002b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8002bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002bf:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002c5:	e8 e8 12 00 00       	call   8015b2 <sys_getenvid>
  8002ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e0:	c7 04 24 c8 23 80 00 	movl   $0x8023c8,(%esp)
  8002e7:	e8 81 00 00 00       	call   80036d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 11 00 00 00       	call   80030c <vcprintf>
	cprintf("\n");
  8002fb:	c7 04 24 45 23 80 00 	movl   $0x802345,(%esp)
  800302:	e8 66 00 00 00       	call   80036d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800307:	cc                   	int3   
  800308:	eb fd                	jmp    800307 <_panic+0x53>
	...

0080030c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800315:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80031c:	00 00 00 
	b.cnt = 0;
  80031f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800326:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	89 44 24 08          	mov    %eax,0x8(%esp)
  800337:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	c7 04 24 87 03 80 00 	movl   $0x800387,(%esp)
  800348:	e8 cf 01 00 00       	call   80051c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80034d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800353:	89 44 24 04          	mov    %eax,0x4(%esp)
  800357:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80035d:	89 04 24             	mov    %eax,(%esp)
  800360:	e8 67 0d 00 00       	call   8010cc <sys_cputs>

	return b.cnt;
}
  800365:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800373:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037a:	8b 45 08             	mov    0x8(%ebp),%eax
  80037d:	89 04 24             	mov    %eax,(%esp)
  800380:	e8 87 ff ff ff       	call   80030c <vcprintf>
	va_end(ap);

	return cnt;
}
  800385:	c9                   	leave  
  800386:	c3                   	ret    

00800387 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	53                   	push   %ebx
  80038b:	83 ec 14             	sub    $0x14,%esp
  80038e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800391:	8b 03                	mov    (%ebx),%eax
  800393:	8b 55 08             	mov    0x8(%ebp),%edx
  800396:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80039a:	83 c0 01             	add    $0x1,%eax
  80039d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a4:	75 19                	jne    8003bf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003a6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ad:	00 
  8003ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b1:	89 04 24             	mov    %eax,(%esp)
  8003b4:	e8 13 0d 00 00       	call   8010cc <sys_cputs>
		b->idx = 0;
  8003b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c3:	83 c4 14             	add    $0x14,%esp
  8003c6:	5b                   	pop    %ebx
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    
  8003c9:	00 00                	add    %al,(%eax)
  8003cb:	00 00                	add    %al,(%eax)
  8003cd:	00 00                	add    %al,(%eax)
	...

008003d0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 4c             	sub    $0x4c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d6                	mov    %edx,%esi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8003f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	39 d1                	cmp    %edx,%ecx
  8003fd:	72 07                	jb     800406 <printnum_v2+0x36>
  8003ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800402:	39 d0                	cmp    %edx,%eax
  800404:	77 5f                	ja     800465 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800406:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80040a:	83 eb 01             	sub    $0x1,%ebx
  80040d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800411:	89 44 24 08          	mov    %eax,0x8(%esp)
  800415:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800419:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80041d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800420:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800423:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800426:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80042a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800431:	00 
  800432:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800435:	89 04 24             	mov    %eax,(%esp)
  800438:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80043f:	e8 2c 1c 00 00       	call   802070 <__udivdi3>
  800444:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800447:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80044a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80044e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800452:	89 04 24             	mov    %eax,(%esp)
  800455:	89 54 24 04          	mov    %edx,0x4(%esp)
  800459:	89 f2                	mov    %esi,%edx
  80045b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045e:	e8 6d ff ff ff       	call   8003d0 <printnum_v2>
  800463:	eb 1e                	jmp    800483 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800465:	83 ff 2d             	cmp    $0x2d,%edi
  800468:	74 19                	je     800483 <printnum_v2+0xb3>
		while (--width > 0)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	85 db                	test   %ebx,%ebx
  80046f:	90                   	nop
  800470:	7e 11                	jle    800483 <printnum_v2+0xb3>
			putch(padc, putdat);
  800472:	89 74 24 04          	mov    %esi,0x4(%esp)
  800476:	89 3c 24             	mov    %edi,(%esp)
  800479:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80047c:	83 eb 01             	sub    $0x1,%ebx
  80047f:	85 db                	test   %ebx,%ebx
  800481:	7f ef                	jg     800472 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800483:	89 74 24 04          	mov    %esi,0x4(%esp)
  800487:	8b 74 24 04          	mov    0x4(%esp),%esi
  80048b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800492:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800499:	00 
  80049a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80049d:	89 14 24             	mov    %edx,(%esp)
  8004a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a7:	e8 f4 1c 00 00       	call   8021a0 <__umoddi3>
  8004ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b0:	0f be 80 eb 23 80 00 	movsbl 0x8023eb(%eax),%eax
  8004b7:	89 04 24             	mov    %eax,(%esp)
  8004ba:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004bd:	83 c4 4c             	add    $0x4c,%esp
  8004c0:	5b                   	pop    %ebx
  8004c1:	5e                   	pop    %esi
  8004c2:	5f                   	pop    %edi
  8004c3:	5d                   	pop    %ebp
  8004c4:	c3                   	ret    

008004c5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c8:	83 fa 01             	cmp    $0x1,%edx
  8004cb:	7e 0e                	jle    8004db <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004cd:	8b 10                	mov    (%eax),%edx
  8004cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d2:	89 08                	mov    %ecx,(%eax)
  8004d4:	8b 02                	mov    (%edx),%eax
  8004d6:	8b 52 04             	mov    0x4(%edx),%edx
  8004d9:	eb 22                	jmp    8004fd <getuint+0x38>
	else if (lflag)
  8004db:	85 d2                	test   %edx,%edx
  8004dd:	74 10                	je     8004ef <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004df:	8b 10                	mov    (%eax),%edx
  8004e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e4:	89 08                	mov    %ecx,(%eax)
  8004e6:	8b 02                	mov    (%edx),%eax
  8004e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ed:	eb 0e                	jmp    8004fd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 02                	mov    (%edx),%eax
  8004f8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800505:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800509:	8b 10                	mov    (%eax),%edx
  80050b:	3b 50 04             	cmp    0x4(%eax),%edx
  80050e:	73 0a                	jae    80051a <sprintputch+0x1b>
		*b->buf++ = ch;
  800510:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800513:	88 0a                	mov    %cl,(%edx)
  800515:	83 c2 01             	add    $0x1,%edx
  800518:	89 10                	mov    %edx,(%eax)
}
  80051a:	5d                   	pop    %ebp
  80051b:	c3                   	ret    

0080051c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	57                   	push   %edi
  800520:	56                   	push   %esi
  800521:	53                   	push   %ebx
  800522:	83 ec 6c             	sub    $0x6c,%esp
  800525:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800528:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80052f:	eb 1a                	jmp    80054b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800531:	85 c0                	test   %eax,%eax
  800533:	0f 84 66 06 00 00    	je     800b9f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800539:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	ff 55 08             	call   *0x8(%ebp)
  800546:	eb 03                	jmp    80054b <vprintfmt+0x2f>
  800548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054b:	0f b6 07             	movzbl (%edi),%eax
  80054e:	83 c7 01             	add    $0x1,%edi
  800551:	83 f8 25             	cmp    $0x25,%eax
  800554:	75 db                	jne    800531 <vprintfmt+0x15>
  800556:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80055a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800566:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80056b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800572:	be 00 00 00 00       	mov    $0x0,%esi
  800577:	eb 06                	jmp    80057f <vprintfmt+0x63>
  800579:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80057d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	0f b6 17             	movzbl (%edi),%edx
  800582:	0f b6 c2             	movzbl %dl,%eax
  800585:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800588:	8d 47 01             	lea    0x1(%edi),%eax
  80058b:	83 ea 23             	sub    $0x23,%edx
  80058e:	80 fa 55             	cmp    $0x55,%dl
  800591:	0f 87 60 05 00 00    	ja     800af7 <vprintfmt+0x5db>
  800597:	0f b6 d2             	movzbl %dl,%edx
  80059a:	ff 24 95 c0 25 80 00 	jmp    *0x8025c0(,%edx,4)
  8005a1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8005a6:	eb d5                	jmp    80057d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ab:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8005ae:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005b1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8005b4:	83 ff 09             	cmp    $0x9,%edi
  8005b7:	76 08                	jbe    8005c1 <vprintfmt+0xa5>
  8005b9:	eb 40                	jmp    8005fb <vprintfmt+0xdf>
  8005bb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8005bf:	eb bc                	jmp    80057d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005c4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8005c7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8005cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005ce:	8d 7a d0             	lea    -0x30(%edx),%edi
  8005d1:	83 ff 09             	cmp    $0x9,%edi
  8005d4:	76 eb                	jbe    8005c1 <vprintfmt+0xa5>
  8005d6:	eb 23                	jmp    8005fb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8005db:	8d 5a 04             	lea    0x4(%edx),%ebx
  8005de:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8005e1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8005e3:	eb 16                	jmp    8005fb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8005e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e8:	c1 fa 1f             	sar    $0x1f,%edx
  8005eb:	f7 d2                	not    %edx
  8005ed:	21 55 d8             	and    %edx,-0x28(%ebp)
  8005f0:	eb 8b                	jmp    80057d <vprintfmt+0x61>
  8005f2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8005f9:	eb 82                	jmp    80057d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8005fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ff:	0f 89 78 ff ff ff    	jns    80057d <vprintfmt+0x61>
  800605:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800608:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80060b:	e9 6d ff ff ff       	jmp    80057d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800610:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800613:	e9 65 ff ff ff       	jmp    80057d <vprintfmt+0x61>
  800618:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 55 0c             	mov    0xc(%ebp),%edx
  800627:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	ff 55 08             	call   *0x8(%ebp)
  800633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800636:	e9 10 ff ff ff       	jmp    80054b <vprintfmt+0x2f>
  80063b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 c2                	mov    %eax,%edx
  80064b:	c1 fa 1f             	sar    $0x1f,%edx
  80064e:	31 d0                	xor    %edx,%eax
  800650:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800652:	83 f8 0f             	cmp    $0xf,%eax
  800655:	7f 0b                	jg     800662 <vprintfmt+0x146>
  800657:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  80065e:	85 d2                	test   %edx,%edx
  800660:	75 26                	jne    800688 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800662:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800666:	c7 44 24 08 fc 23 80 	movl   $0x8023fc,0x8(%esp)
  80066d:	00 
  80066e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800671:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800675:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800678:	89 1c 24             	mov    %ebx,(%esp)
  80067b:	e8 a7 05 00 00       	call   800c27 <printfmt>
  800680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800683:	e9 c3 fe ff ff       	jmp    80054b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800688:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068c:	c7 44 24 08 05 24 80 	movl   $0x802405,0x8(%esp)
  800693:	00 
  800694:	8b 45 0c             	mov    0xc(%ebp),%eax
  800697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069b:	8b 55 08             	mov    0x8(%ebp),%edx
  80069e:	89 14 24             	mov    %edx,(%esp)
  8006a1:	e8 81 05 00 00       	call   800c27 <printfmt>
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a9:	e9 9d fe ff ff       	jmp    80054b <vprintfmt+0x2f>
  8006ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b1:	89 c7                	mov    %eax,%edi
  8006b3:	89 d9                	mov    %ebx,%ecx
  8006b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 30                	mov    (%eax),%esi
  8006c6:	85 f6                	test   %esi,%esi
  8006c8:	75 05                	jne    8006cf <vprintfmt+0x1b3>
  8006ca:	be 08 24 80 00       	mov    $0x802408,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8006cf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8006d3:	7e 06                	jle    8006db <vprintfmt+0x1bf>
  8006d5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8006d9:	75 10                	jne    8006eb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006db:	0f be 06             	movsbl (%esi),%eax
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	0f 85 a2 00 00 00    	jne    800788 <vprintfmt+0x26c>
  8006e6:	e9 92 00 00 00       	jmp    80077d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ef:	89 34 24             	mov    %esi,(%esp)
  8006f2:	e8 74 05 00 00       	call   800c6b <strnlen>
  8006f7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8006fa:	29 c2                	sub    %eax,%edx
  8006fc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006ff:	85 d2                	test   %edx,%edx
  800701:	7e d8                	jle    8006db <vprintfmt+0x1bf>
					putch(padc, putdat);
  800703:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800707:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80070a:	89 d3                	mov    %edx,%ebx
  80070c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80070f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800712:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800715:	89 ce                	mov    %ecx,%esi
  800717:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071b:	89 34 24             	mov    %esi,(%esp)
  80071e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800721:	83 eb 01             	sub    $0x1,%ebx
  800724:	85 db                	test   %ebx,%ebx
  800726:	7f ef                	jg     800717 <vprintfmt+0x1fb>
  800728:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80072b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80072e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800731:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800738:	eb a1                	jmp    8006db <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80073a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80073e:	74 1b                	je     80075b <vprintfmt+0x23f>
  800740:	8d 50 e0             	lea    -0x20(%eax),%edx
  800743:	83 fa 5e             	cmp    $0x5e,%edx
  800746:	76 13                	jbe    80075b <vprintfmt+0x23f>
					putch('?', putdat);
  800748:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800756:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800759:	eb 0d                	jmp    800768 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800762:	89 04 24             	mov    %eax,(%esp)
  800765:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800768:	83 ef 01             	sub    $0x1,%edi
  80076b:	0f be 06             	movsbl (%esi),%eax
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 05                	je     800777 <vprintfmt+0x25b>
  800772:	83 c6 01             	add    $0x1,%esi
  800775:	eb 1a                	jmp    800791 <vprintfmt+0x275>
  800777:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80077a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800781:	7f 1f                	jg     8007a2 <vprintfmt+0x286>
  800783:	e9 c0 fd ff ff       	jmp    800548 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800788:	83 c6 01             	add    $0x1,%esi
  80078b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80078e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800791:	85 db                	test   %ebx,%ebx
  800793:	78 a5                	js     80073a <vprintfmt+0x21e>
  800795:	83 eb 01             	sub    $0x1,%ebx
  800798:	79 a0                	jns    80073a <vprintfmt+0x21e>
  80079a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80079d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007a0:	eb db                	jmp    80077d <vprintfmt+0x261>
  8007a2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007a8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8007ab:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007b9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bb:	83 eb 01             	sub    $0x1,%ebx
  8007be:	85 db                	test   %ebx,%ebx
  8007c0:	7f ec                	jg     8007ae <vprintfmt+0x292>
  8007c2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007c5:	e9 81 fd ff ff       	jmp    80054b <vprintfmt+0x2f>
  8007ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007cd:	83 fe 01             	cmp    $0x1,%esi
  8007d0:	7e 10                	jle    8007e2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 08             	lea    0x8(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007db:	8b 18                	mov    (%eax),%ebx
  8007dd:	8b 70 04             	mov    0x4(%eax),%esi
  8007e0:	eb 26                	jmp    800808 <vprintfmt+0x2ec>
	else if (lflag)
  8007e2:	85 f6                	test   %esi,%esi
  8007e4:	74 12                	je     8007f8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ef:	8b 18                	mov    (%eax),%ebx
  8007f1:	89 de                	mov    %ebx,%esi
  8007f3:	c1 fe 1f             	sar    $0x1f,%esi
  8007f6:	eb 10                	jmp    800808 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 04             	lea    0x4(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800801:	8b 18                	mov    (%eax),%ebx
  800803:	89 de                	mov    %ebx,%esi
  800805:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800808:	83 f9 01             	cmp    $0x1,%ecx
  80080b:	75 1e                	jne    80082b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80080d:	85 f6                	test   %esi,%esi
  80080f:	78 1a                	js     80082b <vprintfmt+0x30f>
  800811:	85 f6                	test   %esi,%esi
  800813:	7f 05                	jg     80081a <vprintfmt+0x2fe>
  800815:	83 fb 00             	cmp    $0x0,%ebx
  800818:	76 11                	jbe    80082b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800821:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800828:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80082b:	85 f6                	test   %esi,%esi
  80082d:	78 13                	js     800842 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80082f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800832:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800835:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800838:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083d:	e9 da 00 00 00       	jmp    80091c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800842:	8b 45 0c             	mov    0xc(%ebp),%eax
  800845:	89 44 24 04          	mov    %eax,0x4(%esp)
  800849:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800850:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800853:	89 da                	mov    %ebx,%edx
  800855:	89 f1                	mov    %esi,%ecx
  800857:	f7 da                	neg    %edx
  800859:	83 d1 00             	adc    $0x0,%ecx
  80085c:	f7 d9                	neg    %ecx
  80085e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800861:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800864:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800867:	b8 0a 00 00 00       	mov    $0xa,%eax
  80086c:	e9 ab 00 00 00       	jmp    80091c <vprintfmt+0x400>
  800871:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800874:	89 f2                	mov    %esi,%edx
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
  800879:	e8 47 fc ff ff       	call   8004c5 <getuint>
  80087e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800881:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800884:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800887:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80088c:	e9 8b 00 00 00       	jmp    80091c <vprintfmt+0x400>
  800891:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80089b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008a2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8008a5:	89 f2                	mov    %esi,%edx
  8008a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008aa:	e8 16 fc ff ff       	call   8004c5 <getuint>
  8008af:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8008b2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8008b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8008bd:	eb 5d                	jmp    80091c <vprintfmt+0x400>
  8008bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8008c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008de:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8008e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e4:	8d 50 04             	lea    0x4(%eax),%edx
  8008e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ea:	8b 10                	mov    (%eax),%edx
  8008ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8008f4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8008f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008fa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008ff:	eb 1b                	jmp    80091c <vprintfmt+0x400>
  800901:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800904:	89 f2                	mov    %esi,%edx
  800906:	8d 45 14             	lea    0x14(%ebp),%eax
  800909:	e8 b7 fb ff ff       	call   8004c5 <getuint>
  80090e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800911:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800914:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800917:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80091c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800920:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800923:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800926:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80092a:	77 09                	ja     800935 <vprintfmt+0x419>
  80092c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80092f:	0f 82 ac 00 00 00    	jb     8009e1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800935:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800938:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80093c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80093f:	83 ea 01             	sub    $0x1,%edx
  800942:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800946:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80094e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800952:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800955:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800958:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80095b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80095f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800966:	00 
  800967:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80096a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80096d:	89 0c 24             	mov    %ecx,(%esp)
  800970:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800974:	e8 f7 16 00 00       	call   802070 <__udivdi3>
  800979:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80097c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80097f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800983:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800987:	89 04 24             	mov    %eax,(%esp)
  80098a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	e8 37 fa ff ff       	call   8003d0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800999:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80099c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009b2:	00 
  8009b3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8009b6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8009b9:	89 14 24             	mov    %edx,(%esp)
  8009bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009c0:	e8 db 17 00 00       	call   8021a0 <__umoddi3>
  8009c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c9:	0f be 80 eb 23 80 00 	movsbl 0x8023eb(%eax),%eax
  8009d0:	89 04 24             	mov    %eax,(%esp)
  8009d3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8009d6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8009da:	74 54                	je     800a30 <vprintfmt+0x514>
  8009dc:	e9 67 fb ff ff       	jmp    800548 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8009e1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8009e5:	8d 76 00             	lea    0x0(%esi),%esi
  8009e8:	0f 84 2a 01 00 00    	je     800b18 <vprintfmt+0x5fc>
		while (--width > 0)
  8009ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8009f1:	83 ef 01             	sub    $0x1,%edi
  8009f4:	85 ff                	test   %edi,%edi
  8009f6:	0f 8e 5e 01 00 00    	jle    800b5a <vprintfmt+0x63e>
  8009fc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8009ff:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800a02:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800a05:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800a08:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800a0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a12:	89 1c 24             	mov    %ebx,(%esp)
  800a15:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800a18:	83 ef 01             	sub    $0x1,%edi
  800a1b:	85 ff                	test   %edi,%edi
  800a1d:	7f ef                	jg     800a0e <vprintfmt+0x4f2>
  800a1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a22:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a25:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800a28:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800a2b:	e9 2a 01 00 00       	jmp    800b5a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800a30:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800a33:	83 eb 01             	sub    $0x1,%ebx
  800a36:	85 db                	test   %ebx,%ebx
  800a38:	0f 8e 0a fb ff ff    	jle    800548 <vprintfmt+0x2c>
  800a3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a41:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a44:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800a47:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a52:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800a54:	83 eb 01             	sub    $0x1,%ebx
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	7f ec                	jg     800a47 <vprintfmt+0x52b>
  800a5b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a5e:	e9 e8 fa ff ff       	jmp    80054b <vprintfmt+0x2f>
  800a63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800a66:	8b 45 14             	mov    0x14(%ebp),%eax
  800a69:	8d 50 04             	lea    0x4(%eax),%edx
  800a6c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a6f:	8b 00                	mov    (%eax),%eax
  800a71:	85 c0                	test   %eax,%eax
  800a73:	75 2a                	jne    800a9f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800a75:	c7 44 24 0c 24 25 80 	movl   $0x802524,0xc(%esp)
  800a7c:	00 
  800a7d:	c7 44 24 08 05 24 80 	movl   $0x802405,0x8(%esp)
  800a84:	00 
  800a85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a88:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8f:	89 0c 24             	mov    %ecx,(%esp)
  800a92:	e8 90 01 00 00       	call   800c27 <printfmt>
  800a97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a9a:	e9 ac fa ff ff       	jmp    80054b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800a9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa2:	8b 13                	mov    (%ebx),%edx
  800aa4:	83 fa 7f             	cmp    $0x7f,%edx
  800aa7:	7e 29                	jle    800ad2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800aa9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800aab:	c7 44 24 0c 5c 25 80 	movl   $0x80255c,0xc(%esp)
  800ab2:	00 
  800ab3:	c7 44 24 08 05 24 80 	movl   $0x802405,0x8(%esp)
  800aba:	00 
  800abb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	89 04 24             	mov    %eax,(%esp)
  800ac5:	e8 5d 01 00 00       	call   800c27 <printfmt>
  800aca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800acd:	e9 79 fa ff ff       	jmp    80054b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800ad2:	88 10                	mov    %dl,(%eax)
  800ad4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ad7:	e9 6f fa ff ff       	jmp    80054b <vprintfmt+0x2f>
  800adc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800adf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ae9:	89 14 24             	mov    %edx,(%esp)
  800aec:	ff 55 08             	call   *0x8(%ebp)
  800aef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800af2:	e9 54 fa ff ff       	jmp    80054b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800af7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800afa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800afe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b05:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b08:	8d 47 ff             	lea    -0x1(%edi),%eax
  800b0b:	80 38 25             	cmpb   $0x25,(%eax)
  800b0e:	0f 84 37 fa ff ff    	je     80054b <vprintfmt+0x2f>
  800b14:	89 c7                	mov    %eax,%edi
  800b16:	eb f0                	jmp    800b08 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b23:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b26:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b2a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b31:	00 
  800b32:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800b35:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800b38:	89 04 24             	mov    %eax,(%esp)
  800b3b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b3f:	e8 5c 16 00 00       	call   8021a0 <__umoddi3>
  800b44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b48:	0f be 80 eb 23 80 00 	movsbl 0x8023eb(%eax),%eax
  800b4f:	89 04 24             	mov    %eax,(%esp)
  800b52:	ff 55 08             	call   *0x8(%ebp)
  800b55:	e9 d6 fe ff ff       	jmp    800a30 <vprintfmt+0x514>
  800b5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b61:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b65:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b6c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b73:	00 
  800b74:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800b77:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800b7a:	89 04 24             	mov    %eax,(%esp)
  800b7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b81:	e8 1a 16 00 00       	call   8021a0 <__umoddi3>
  800b86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b8a:	0f be 80 eb 23 80 00 	movsbl 0x8023eb(%eax),%eax
  800b91:	89 04 24             	mov    %eax,(%esp)
  800b94:	ff 55 08             	call   *0x8(%ebp)
  800b97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b9a:	e9 ac f9 ff ff       	jmp    80054b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b9f:	83 c4 6c             	add    $0x6c,%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 28             	sub    $0x28,%esp
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	74 04                	je     800bbb <vsnprintf+0x14>
  800bb7:	85 d2                	test   %edx,%edx
  800bb9:	7f 07                	jg     800bc2 <vsnprintf+0x1b>
  800bbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bc0:	eb 3b                	jmp    800bfd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bc5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bcc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bda:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be8:	c7 04 24 ff 04 80 00 	movl   $0x8004ff,(%esp)
  800bef:	e8 28 f9 ff ff       	call   80051c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800c05:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800c08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	89 04 24             	mov    %eax,(%esp)
  800c20:	e8 82 ff ff ff       	call   800ba7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800c2d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c34:	8b 45 10             	mov    0x10(%ebp),%eax
  800c37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	89 04 24             	mov    %eax,(%esp)
  800c48:	e8 cf f8 ff ff       	call   80051c <vprintfmt>
	va_end(ap);
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    
	...

00800c50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c56:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c5e:	74 09                	je     800c69 <strlen+0x19>
		n++;
  800c60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c67:	75 f7                	jne    800c60 <strlen+0x10>
		n++;
	return n;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	53                   	push   %ebx
  800c6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c75:	85 c9                	test   %ecx,%ecx
  800c77:	74 19                	je     800c92 <strnlen+0x27>
  800c79:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c7c:	74 14                	je     800c92 <strnlen+0x27>
  800c7e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800c83:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c86:	39 c8                	cmp    %ecx,%eax
  800c88:	74 0d                	je     800c97 <strnlen+0x2c>
  800c8a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800c8e:	75 f3                	jne    800c83 <strnlen+0x18>
  800c90:	eb 05                	jmp    800c97 <strnlen+0x2c>
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c97:	5b                   	pop    %ebx
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	53                   	push   %ebx
  800c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ca9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800cb0:	83 c2 01             	add    $0x1,%edx
  800cb3:	84 c9                	test   %cl,%cl
  800cb5:	75 f2                	jne    800ca9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 08             	sub    $0x8,%esp
  800cc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cc4:	89 1c 24             	mov    %ebx,(%esp)
  800cc7:	e8 84 ff ff ff       	call   800c50 <strlen>
	strcpy(dst + len, src);
  800ccc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cd3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800cd6:	89 04 24             	mov    %eax,(%esp)
  800cd9:	e8 bc ff ff ff       	call   800c9a <strcpy>
	return dst;
}
  800cde:	89 d8                	mov    %ebx,%eax
  800ce0:	83 c4 08             	add    $0x8,%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf4:	85 f6                	test   %esi,%esi
  800cf6:	74 18                	je     800d10 <strncpy+0x2a>
  800cf8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800cfd:	0f b6 1a             	movzbl (%edx),%ebx
  800d00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d03:	80 3a 01             	cmpb   $0x1,(%edx)
  800d06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d09:	83 c1 01             	add    $0x1,%ecx
  800d0c:	39 ce                	cmp    %ecx,%esi
  800d0e:	77 ed                	ja     800cfd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d22:	89 f0                	mov    %esi,%eax
  800d24:	85 c9                	test   %ecx,%ecx
  800d26:	74 27                	je     800d4f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800d28:	83 e9 01             	sub    $0x1,%ecx
  800d2b:	74 1d                	je     800d4a <strlcpy+0x36>
  800d2d:	0f b6 1a             	movzbl (%edx),%ebx
  800d30:	84 db                	test   %bl,%bl
  800d32:	74 16                	je     800d4a <strlcpy+0x36>
			*dst++ = *src++;
  800d34:	88 18                	mov    %bl,(%eax)
  800d36:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d39:	83 e9 01             	sub    $0x1,%ecx
  800d3c:	74 0e                	je     800d4c <strlcpy+0x38>
			*dst++ = *src++;
  800d3e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d41:	0f b6 1a             	movzbl (%edx),%ebx
  800d44:	84 db                	test   %bl,%bl
  800d46:	75 ec                	jne    800d34 <strlcpy+0x20>
  800d48:	eb 02                	jmp    800d4c <strlcpy+0x38>
  800d4a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d4c:	c6 00 00             	movb   $0x0,(%eax)
  800d4f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d5e:	0f b6 01             	movzbl (%ecx),%eax
  800d61:	84 c0                	test   %al,%al
  800d63:	74 15                	je     800d7a <strcmp+0x25>
  800d65:	3a 02                	cmp    (%edx),%al
  800d67:	75 11                	jne    800d7a <strcmp+0x25>
		p++, q++;
  800d69:	83 c1 01             	add    $0x1,%ecx
  800d6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d6f:	0f b6 01             	movzbl (%ecx),%eax
  800d72:	84 c0                	test   %al,%al
  800d74:	74 04                	je     800d7a <strcmp+0x25>
  800d76:	3a 02                	cmp    (%edx),%al
  800d78:	74 ef                	je     800d69 <strcmp+0x14>
  800d7a:	0f b6 c0             	movzbl %al,%eax
  800d7d:	0f b6 12             	movzbl (%edx),%edx
  800d80:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	53                   	push   %ebx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	74 23                	je     800db8 <strncmp+0x34>
  800d95:	0f b6 1a             	movzbl (%edx),%ebx
  800d98:	84 db                	test   %bl,%bl
  800d9a:	74 25                	je     800dc1 <strncmp+0x3d>
  800d9c:	3a 19                	cmp    (%ecx),%bl
  800d9e:	75 21                	jne    800dc1 <strncmp+0x3d>
  800da0:	83 e8 01             	sub    $0x1,%eax
  800da3:	74 13                	je     800db8 <strncmp+0x34>
		n--, p++, q++;
  800da5:	83 c2 01             	add    $0x1,%edx
  800da8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dab:	0f b6 1a             	movzbl (%edx),%ebx
  800dae:	84 db                	test   %bl,%bl
  800db0:	74 0f                	je     800dc1 <strncmp+0x3d>
  800db2:	3a 19                	cmp    (%ecx),%bl
  800db4:	74 ea                	je     800da0 <strncmp+0x1c>
  800db6:	eb 09                	jmp    800dc1 <strncmp+0x3d>
  800db8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5d                   	pop    %ebp
  800dbf:	90                   	nop
  800dc0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc1:	0f b6 02             	movzbl (%edx),%eax
  800dc4:	0f b6 11             	movzbl (%ecx),%edx
  800dc7:	29 d0                	sub    %edx,%eax
  800dc9:	eb f2                	jmp    800dbd <strncmp+0x39>

00800dcb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dd5:	0f b6 10             	movzbl (%eax),%edx
  800dd8:	84 d2                	test   %dl,%dl
  800dda:	74 18                	je     800df4 <strchr+0x29>
		if (*s == c)
  800ddc:	38 ca                	cmp    %cl,%dl
  800dde:	75 0a                	jne    800dea <strchr+0x1f>
  800de0:	eb 17                	jmp    800df9 <strchr+0x2e>
  800de2:	38 ca                	cmp    %cl,%dl
  800de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de8:	74 0f                	je     800df9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dea:	83 c0 01             	add    $0x1,%eax
  800ded:	0f b6 10             	movzbl (%eax),%edx
  800df0:	84 d2                	test   %dl,%dl
  800df2:	75 ee                	jne    800de2 <strchr+0x17>
  800df4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e05:	0f b6 10             	movzbl (%eax),%edx
  800e08:	84 d2                	test   %dl,%dl
  800e0a:	74 18                	je     800e24 <strfind+0x29>
		if (*s == c)
  800e0c:	38 ca                	cmp    %cl,%dl
  800e0e:	75 0a                	jne    800e1a <strfind+0x1f>
  800e10:	eb 12                	jmp    800e24 <strfind+0x29>
  800e12:	38 ca                	cmp    %cl,%dl
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	74 0a                	je     800e24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e1a:	83 c0 01             	add    $0x1,%eax
  800e1d:	0f b6 10             	movzbl (%eax),%edx
  800e20:	84 d2                	test   %dl,%dl
  800e22:	75 ee                	jne    800e12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	89 1c 24             	mov    %ebx,(%esp)
  800e2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e40:	85 c9                	test   %ecx,%ecx
  800e42:	74 30                	je     800e74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e4a:	75 25                	jne    800e71 <memset+0x4b>
  800e4c:	f6 c1 03             	test   $0x3,%cl
  800e4f:	75 20                	jne    800e71 <memset+0x4b>
		c &= 0xFF;
  800e51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e54:	89 d3                	mov    %edx,%ebx
  800e56:	c1 e3 08             	shl    $0x8,%ebx
  800e59:	89 d6                	mov    %edx,%esi
  800e5b:	c1 e6 18             	shl    $0x18,%esi
  800e5e:	89 d0                	mov    %edx,%eax
  800e60:	c1 e0 10             	shl    $0x10,%eax
  800e63:	09 f0                	or     %esi,%eax
  800e65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800e67:	09 d8                	or     %ebx,%eax
  800e69:	c1 e9 02             	shr    $0x2,%ecx
  800e6c:	fc                   	cld    
  800e6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e6f:	eb 03                	jmp    800e74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e71:	fc                   	cld    
  800e72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e74:	89 f8                	mov    %edi,%eax
  800e76:	8b 1c 24             	mov    (%esp),%ebx
  800e79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e81:	89 ec                	mov    %ebp,%esp
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	89 34 24             	mov    %esi,(%esp)
  800e8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800e98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800e9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800e9d:	39 c6                	cmp    %eax,%esi
  800e9f:	73 35                	jae    800ed6 <memmove+0x51>
  800ea1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ea4:	39 d0                	cmp    %edx,%eax
  800ea6:	73 2e                	jae    800ed6 <memmove+0x51>
		s += n;
		d += n;
  800ea8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eaa:	f6 c2 03             	test   $0x3,%dl
  800ead:	75 1b                	jne    800eca <memmove+0x45>
  800eaf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eb5:	75 13                	jne    800eca <memmove+0x45>
  800eb7:	f6 c1 03             	test   $0x3,%cl
  800eba:	75 0e                	jne    800eca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ebc:	83 ef 04             	sub    $0x4,%edi
  800ebf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ec2:	c1 e9 02             	shr    $0x2,%ecx
  800ec5:	fd                   	std    
  800ec6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ec8:	eb 09                	jmp    800ed3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eca:	83 ef 01             	sub    $0x1,%edi
  800ecd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ed0:	fd                   	std    
  800ed1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ed3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ed4:	eb 20                	jmp    800ef6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800edc:	75 15                	jne    800ef3 <memmove+0x6e>
  800ede:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ee4:	75 0d                	jne    800ef3 <memmove+0x6e>
  800ee6:	f6 c1 03             	test   $0x3,%cl
  800ee9:	75 08                	jne    800ef3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800eeb:	c1 e9 02             	shr    $0x2,%ecx
  800eee:	fc                   	cld    
  800eef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ef1:	eb 03                	jmp    800ef6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ef3:	fc                   	cld    
  800ef4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ef6:	8b 34 24             	mov    (%esp),%esi
  800ef9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800efd:	89 ec                	mov    %ebp,%esp
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f07:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f15:	8b 45 08             	mov    0x8(%ebp),%eax
  800f18:	89 04 24             	mov    %eax,(%esp)
  800f1b:	e8 65 ff ff ff       	call   800e85 <memmove>
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f31:	85 c9                	test   %ecx,%ecx
  800f33:	74 36                	je     800f6b <memcmp+0x49>
		if (*s1 != *s2)
  800f35:	0f b6 06             	movzbl (%esi),%eax
  800f38:	0f b6 1f             	movzbl (%edi),%ebx
  800f3b:	38 d8                	cmp    %bl,%al
  800f3d:	74 20                	je     800f5f <memcmp+0x3d>
  800f3f:	eb 14                	jmp    800f55 <memcmp+0x33>
  800f41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800f46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800f4b:	83 c2 01             	add    $0x1,%edx
  800f4e:	83 e9 01             	sub    $0x1,%ecx
  800f51:	38 d8                	cmp    %bl,%al
  800f53:	74 12                	je     800f67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800f55:	0f b6 c0             	movzbl %al,%eax
  800f58:	0f b6 db             	movzbl %bl,%ebx
  800f5b:	29 d8                	sub    %ebx,%eax
  800f5d:	eb 11                	jmp    800f70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f5f:	83 e9 01             	sub    $0x1,%ecx
  800f62:	ba 00 00 00 00       	mov    $0x0,%edx
  800f67:	85 c9                	test   %ecx,%ecx
  800f69:	75 d6                	jne    800f41 <memcmp+0x1f>
  800f6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f7b:	89 c2                	mov    %eax,%edx
  800f7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f80:	39 d0                	cmp    %edx,%eax
  800f82:	73 15                	jae    800f99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f88:	38 08                	cmp    %cl,(%eax)
  800f8a:	75 06                	jne    800f92 <memfind+0x1d>
  800f8c:	eb 0b                	jmp    800f99 <memfind+0x24>
  800f8e:	38 08                	cmp    %cl,(%eax)
  800f90:	74 07                	je     800f99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f92:	83 c0 01             	add    $0x1,%eax
  800f95:	39 c2                	cmp    %eax,%edx
  800f97:	77 f5                	ja     800f8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800faa:	0f b6 02             	movzbl (%edx),%eax
  800fad:	3c 20                	cmp    $0x20,%al
  800faf:	74 04                	je     800fb5 <strtol+0x1a>
  800fb1:	3c 09                	cmp    $0x9,%al
  800fb3:	75 0e                	jne    800fc3 <strtol+0x28>
		s++;
  800fb5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb8:	0f b6 02             	movzbl (%edx),%eax
  800fbb:	3c 20                	cmp    $0x20,%al
  800fbd:	74 f6                	je     800fb5 <strtol+0x1a>
  800fbf:	3c 09                	cmp    $0x9,%al
  800fc1:	74 f2                	je     800fb5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fc3:	3c 2b                	cmp    $0x2b,%al
  800fc5:	75 0c                	jne    800fd3 <strtol+0x38>
		s++;
  800fc7:	83 c2 01             	add    $0x1,%edx
  800fca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800fd1:	eb 15                	jmp    800fe8 <strtol+0x4d>
	else if (*s == '-')
  800fd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800fda:	3c 2d                	cmp    $0x2d,%al
  800fdc:	75 0a                	jne    800fe8 <strtol+0x4d>
		s++, neg = 1;
  800fde:	83 c2 01             	add    $0x1,%edx
  800fe1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fe8:	85 db                	test   %ebx,%ebx
  800fea:	0f 94 c0             	sete   %al
  800fed:	74 05                	je     800ff4 <strtol+0x59>
  800fef:	83 fb 10             	cmp    $0x10,%ebx
  800ff2:	75 18                	jne    80100c <strtol+0x71>
  800ff4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ff7:	75 13                	jne    80100c <strtol+0x71>
  800ff9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	75 0a                	jne    80100c <strtol+0x71>
		s += 2, base = 16;
  801002:	83 c2 02             	add    $0x2,%edx
  801005:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80100a:	eb 15                	jmp    801021 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80100c:	84 c0                	test   %al,%al
  80100e:	66 90                	xchg   %ax,%ax
  801010:	74 0f                	je     801021 <strtol+0x86>
  801012:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801017:	80 3a 30             	cmpb   $0x30,(%edx)
  80101a:	75 05                	jne    801021 <strtol+0x86>
		s++, base = 8;
  80101c:	83 c2 01             	add    $0x1,%edx
  80101f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
  801026:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801028:	0f b6 0a             	movzbl (%edx),%ecx
  80102b:	89 cf                	mov    %ecx,%edi
  80102d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801030:	80 fb 09             	cmp    $0x9,%bl
  801033:	77 08                	ja     80103d <strtol+0xa2>
			dig = *s - '0';
  801035:	0f be c9             	movsbl %cl,%ecx
  801038:	83 e9 30             	sub    $0x30,%ecx
  80103b:	eb 1e                	jmp    80105b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80103d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801040:	80 fb 19             	cmp    $0x19,%bl
  801043:	77 08                	ja     80104d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801045:	0f be c9             	movsbl %cl,%ecx
  801048:	83 e9 57             	sub    $0x57,%ecx
  80104b:	eb 0e                	jmp    80105b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80104d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801050:	80 fb 19             	cmp    $0x19,%bl
  801053:	77 15                	ja     80106a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801055:	0f be c9             	movsbl %cl,%ecx
  801058:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80105b:	39 f1                	cmp    %esi,%ecx
  80105d:	7d 0b                	jge    80106a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80105f:	83 c2 01             	add    $0x1,%edx
  801062:	0f af c6             	imul   %esi,%eax
  801065:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801068:	eb be                	jmp    801028 <strtol+0x8d>
  80106a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80106c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801070:	74 05                	je     801077 <strtol+0xdc>
		*endptr = (char *) s;
  801072:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801075:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801077:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80107b:	74 04                	je     801081 <strtol+0xe6>
  80107d:	89 c8                	mov    %ecx,%eax
  80107f:	f7 d8                	neg    %eax
}
  801081:	83 c4 04             	add    $0x4,%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    
  801089:	00 00                	add    %al,(%eax)
	...

0080108c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 08             	sub    $0x8,%esp
  801092:	89 1c 24             	mov    %ebx,(%esp)
  801095:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801099:	ba 00 00 00 00       	mov    $0x0,%edx
  80109e:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	89 d3                	mov    %edx,%ebx
  8010a7:	89 d7                	mov    %edx,%edi
  8010a9:	51                   	push   %ecx
  8010aa:	52                   	push   %edx
  8010ab:	53                   	push   %ebx
  8010ac:	54                   	push   %esp
  8010ad:	55                   	push   %ebp
  8010ae:	56                   	push   %esi
  8010af:	57                   	push   %edi
  8010b0:	54                   	push   %esp
  8010b1:	5d                   	pop    %ebp
  8010b2:	8d 35 ba 10 80 00    	lea    0x8010ba,%esi
  8010b8:	0f 34                	sysenter 
  8010ba:	5f                   	pop    %edi
  8010bb:	5e                   	pop    %esi
  8010bc:	5d                   	pop    %ebp
  8010bd:	5c                   	pop    %esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5a                   	pop    %edx
  8010c0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010c1:	8b 1c 24             	mov    (%esp),%ebx
  8010c4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010c8:	89 ec                	mov    %ebp,%esp
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 08             	sub    $0x8,%esp
  8010d2:	89 1c 24             	mov    %ebx,(%esp)
  8010d5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e4:	89 c3                	mov    %eax,%ebx
  8010e6:	89 c7                	mov    %eax,%edi
  8010e8:	51                   	push   %ecx
  8010e9:	52                   	push   %edx
  8010ea:	53                   	push   %ebx
  8010eb:	54                   	push   %esp
  8010ec:	55                   	push   %ebp
  8010ed:	56                   	push   %esi
  8010ee:	57                   	push   %edi
  8010ef:	54                   	push   %esp
  8010f0:	5d                   	pop    %ebp
  8010f1:	8d 35 f9 10 80 00    	lea    0x8010f9,%esi
  8010f7:	0f 34                	sysenter 
  8010f9:	5f                   	pop    %edi
  8010fa:	5e                   	pop    %esi
  8010fb:	5d                   	pop    %ebp
  8010fc:	5c                   	pop    %esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5a                   	pop    %edx
  8010ff:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801100:	8b 1c 24             	mov    (%esp),%ebx
  801103:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801107:	89 ec                	mov    %ebp,%esp
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 08             	sub    $0x8,%esp
  801111:	89 1c 24             	mov    %ebx,(%esp)
  801114:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801118:	b8 10 00 00 00       	mov    $0x10,%eax
  80111d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801120:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801123:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801126:	8b 55 08             	mov    0x8(%ebp),%edx
  801129:	51                   	push   %ecx
  80112a:	52                   	push   %edx
  80112b:	53                   	push   %ebx
  80112c:	54                   	push   %esp
  80112d:	55                   	push   %ebp
  80112e:	56                   	push   %esi
  80112f:	57                   	push   %edi
  801130:	54                   	push   %esp
  801131:	5d                   	pop    %ebp
  801132:	8d 35 3a 11 80 00    	lea    0x80113a,%esi
  801138:	0f 34                	sysenter 
  80113a:	5f                   	pop    %edi
  80113b:	5e                   	pop    %esi
  80113c:	5d                   	pop    %ebp
  80113d:	5c                   	pop    %esp
  80113e:	5b                   	pop    %ebx
  80113f:	5a                   	pop    %edx
  801140:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801141:	8b 1c 24             	mov    (%esp),%ebx
  801144:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801148:	89 ec                	mov    %ebp,%esp
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	83 ec 28             	sub    $0x28,%esp
  801152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801155:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801158:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115d:	b8 0f 00 00 00       	mov    $0xf,%eax
  801162:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801165:	8b 55 08             	mov    0x8(%ebp),%edx
  801168:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801182:	85 c0                	test   %eax,%eax
  801184:	7e 28                	jle    8011ae <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801186:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801191:	00 
  801192:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  801199:	00 
  80119a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011a1:	00 
  8011a2:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  8011a9:	e8 06 f1 ff ff       	call   8002b4 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8011ae:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011b4:	89 ec                	mov    %ebp,%esp
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	89 1c 24             	mov    %ebx,(%esp)
  8011c1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ca:	b8 11 00 00 00       	mov    $0x11,%eax
  8011cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d2:	89 cb                	mov    %ecx,%ebx
  8011d4:	89 cf                	mov    %ecx,%edi
  8011d6:	51                   	push   %ecx
  8011d7:	52                   	push   %edx
  8011d8:	53                   	push   %ebx
  8011d9:	54                   	push   %esp
  8011da:	55                   	push   %ebp
  8011db:	56                   	push   %esi
  8011dc:	57                   	push   %edi
  8011dd:	54                   	push   %esp
  8011de:	5d                   	pop    %ebp
  8011df:	8d 35 e7 11 80 00    	lea    0x8011e7,%esi
  8011e5:	0f 34                	sysenter 
  8011e7:	5f                   	pop    %edi
  8011e8:	5e                   	pop    %esi
  8011e9:	5d                   	pop    %ebp
  8011ea:	5c                   	pop    %esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5a                   	pop    %edx
  8011ed:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011ee:	8b 1c 24             	mov    (%esp),%ebx
  8011f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011f5:	89 ec                	mov    %ebp,%esp
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 28             	sub    $0x28,%esp
  8011ff:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801202:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801205:	b9 00 00 00 00       	mov    $0x0,%ecx
  80120a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80120f:	8b 55 08             	mov    0x8(%ebp),%edx
  801212:	89 cb                	mov    %ecx,%ebx
  801214:	89 cf                	mov    %ecx,%edi
  801216:	51                   	push   %ecx
  801217:	52                   	push   %edx
  801218:	53                   	push   %ebx
  801219:	54                   	push   %esp
  80121a:	55                   	push   %ebp
  80121b:	56                   	push   %esi
  80121c:	57                   	push   %edi
  80121d:	54                   	push   %esp
  80121e:	5d                   	pop    %ebp
  80121f:	8d 35 27 12 80 00    	lea    0x801227,%esi
  801225:	0f 34                	sysenter 
  801227:	5f                   	pop    %edi
  801228:	5e                   	pop    %esi
  801229:	5d                   	pop    %ebp
  80122a:	5c                   	pop    %esp
  80122b:	5b                   	pop    %ebx
  80122c:	5a                   	pop    %edx
  80122d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80122e:	85 c0                	test   %eax,%eax
  801230:	7e 28                	jle    80125a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801232:	89 44 24 10          	mov    %eax,0x10(%esp)
  801236:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80123d:	00 
  80123e:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  801245:	00 
  801246:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80124d:	00 
  80124e:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  801255:	e8 5a f0 ff ff       	call   8002b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80125a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80125d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801260:	89 ec                	mov    %ebp,%esp
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	89 1c 24             	mov    %ebx,(%esp)
  80126d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801271:	b8 0d 00 00 00       	mov    $0xd,%eax
  801276:	8b 7d 14             	mov    0x14(%ebp),%edi
  801279:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80127c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127f:	8b 55 08             	mov    0x8(%ebp),%edx
  801282:	51                   	push   %ecx
  801283:	52                   	push   %edx
  801284:	53                   	push   %ebx
  801285:	54                   	push   %esp
  801286:	55                   	push   %ebp
  801287:	56                   	push   %esi
  801288:	57                   	push   %edi
  801289:	54                   	push   %esp
  80128a:	5d                   	pop    %ebp
  80128b:	8d 35 93 12 80 00    	lea    0x801293,%esi
  801291:	0f 34                	sysenter 
  801293:	5f                   	pop    %edi
  801294:	5e                   	pop    %esi
  801295:	5d                   	pop    %ebp
  801296:	5c                   	pop    %esp
  801297:	5b                   	pop    %ebx
  801298:	5a                   	pop    %edx
  801299:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80129a:	8b 1c 24             	mov    (%esp),%ebx
  80129d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012a1:	89 ec                	mov    %ebp,%esp
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	83 ec 28             	sub    $0x28,%esp
  8012ab:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012ae:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012be:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c1:	89 df                	mov    %ebx,%edi
  8012c3:	51                   	push   %ecx
  8012c4:	52                   	push   %edx
  8012c5:	53                   	push   %ebx
  8012c6:	54                   	push   %esp
  8012c7:	55                   	push   %ebp
  8012c8:	56                   	push   %esi
  8012c9:	57                   	push   %edi
  8012ca:	54                   	push   %esp
  8012cb:	5d                   	pop    %ebp
  8012cc:	8d 35 d4 12 80 00    	lea    0x8012d4,%esi
  8012d2:	0f 34                	sysenter 
  8012d4:	5f                   	pop    %edi
  8012d5:	5e                   	pop    %esi
  8012d6:	5d                   	pop    %ebp
  8012d7:	5c                   	pop    %esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5a                   	pop    %edx
  8012da:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	7e 28                	jle    801307 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012e3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8012ea:	00 
  8012eb:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  8012f2:	00 
  8012f3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012fa:	00 
  8012fb:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  801302:	e8 ad ef ff ff       	call   8002b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801307:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80130a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80130d:	89 ec                	mov    %ebp,%esp
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	83 ec 28             	sub    $0x28,%esp
  801317:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80131a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80131d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801322:	b8 0a 00 00 00       	mov    $0xa,%eax
  801327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132a:	8b 55 08             	mov    0x8(%ebp),%edx
  80132d:	89 df                	mov    %ebx,%edi
  80132f:	51                   	push   %ecx
  801330:	52                   	push   %edx
  801331:	53                   	push   %ebx
  801332:	54                   	push   %esp
  801333:	55                   	push   %ebp
  801334:	56                   	push   %esi
  801335:	57                   	push   %edi
  801336:	54                   	push   %esp
  801337:	5d                   	pop    %ebp
  801338:	8d 35 40 13 80 00    	lea    0x801340,%esi
  80133e:	0f 34                	sysenter 
  801340:	5f                   	pop    %edi
  801341:	5e                   	pop    %esi
  801342:	5d                   	pop    %ebp
  801343:	5c                   	pop    %esp
  801344:	5b                   	pop    %ebx
  801345:	5a                   	pop    %edx
  801346:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801347:	85 c0                	test   %eax,%eax
  801349:	7e 28                	jle    801373 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80134b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80134f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801356:	00 
  801357:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  80135e:	00 
  80135f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801366:	00 
  801367:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  80136e:	e8 41 ef ff ff       	call   8002b4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801373:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801376:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801379:	89 ec                	mov    %ebp,%esp
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 28             	sub    $0x28,%esp
  801383:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801386:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801389:	bb 00 00 00 00       	mov    $0x0,%ebx
  80138e:	b8 09 00 00 00       	mov    $0x9,%eax
  801393:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801396:	8b 55 08             	mov    0x8(%ebp),%edx
  801399:	89 df                	mov    %ebx,%edi
  80139b:	51                   	push   %ecx
  80139c:	52                   	push   %edx
  80139d:	53                   	push   %ebx
  80139e:	54                   	push   %esp
  80139f:	55                   	push   %ebp
  8013a0:	56                   	push   %esi
  8013a1:	57                   	push   %edi
  8013a2:	54                   	push   %esp
  8013a3:	5d                   	pop    %ebp
  8013a4:	8d 35 ac 13 80 00    	lea    0x8013ac,%esi
  8013aa:	0f 34                	sysenter 
  8013ac:	5f                   	pop    %edi
  8013ad:	5e                   	pop    %esi
  8013ae:	5d                   	pop    %ebp
  8013af:	5c                   	pop    %esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5a                   	pop    %edx
  8013b2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	7e 28                	jle    8013df <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013bb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013c2:	00 
  8013c3:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  8013ca:	00 
  8013cb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013d2:	00 
  8013d3:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  8013da:	e8 d5 ee ff ff       	call   8002b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013e2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013e5:	89 ec                	mov    %ebp,%esp
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 28             	sub    $0x28,%esp
  8013ef:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013f2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fa:	b8 07 00 00 00       	mov    $0x7,%eax
  8013ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801402:	8b 55 08             	mov    0x8(%ebp),%edx
  801405:	89 df                	mov    %ebx,%edi
  801407:	51                   	push   %ecx
  801408:	52                   	push   %edx
  801409:	53                   	push   %ebx
  80140a:	54                   	push   %esp
  80140b:	55                   	push   %ebp
  80140c:	56                   	push   %esi
  80140d:	57                   	push   %edi
  80140e:	54                   	push   %esp
  80140f:	5d                   	pop    %ebp
  801410:	8d 35 18 14 80 00    	lea    0x801418,%esi
  801416:	0f 34                	sysenter 
  801418:	5f                   	pop    %edi
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	5c                   	pop    %esp
  80141c:	5b                   	pop    %ebx
  80141d:	5a                   	pop    %edx
  80141e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80141f:	85 c0                	test   %eax,%eax
  801421:	7e 28                	jle    80144b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801423:	89 44 24 10          	mov    %eax,0x10(%esp)
  801427:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80142e:	00 
  80142f:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  801436:	00 
  801437:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80143e:	00 
  80143f:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  801446:	e8 69 ee ff ff       	call   8002b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80144b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80144e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801451:	89 ec                	mov    %ebp,%esp
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 28             	sub    $0x28,%esp
  80145b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80145e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801461:	8b 7d 18             	mov    0x18(%ebp),%edi
  801464:	0b 7d 14             	or     0x14(%ebp),%edi
  801467:	b8 06 00 00 00       	mov    $0x6,%eax
  80146c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80146f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801472:	8b 55 08             	mov    0x8(%ebp),%edx
  801475:	51                   	push   %ecx
  801476:	52                   	push   %edx
  801477:	53                   	push   %ebx
  801478:	54                   	push   %esp
  801479:	55                   	push   %ebp
  80147a:	56                   	push   %esi
  80147b:	57                   	push   %edi
  80147c:	54                   	push   %esp
  80147d:	5d                   	pop    %ebp
  80147e:	8d 35 86 14 80 00    	lea    0x801486,%esi
  801484:	0f 34                	sysenter 
  801486:	5f                   	pop    %edi
  801487:	5e                   	pop    %esi
  801488:	5d                   	pop    %ebp
  801489:	5c                   	pop    %esp
  80148a:	5b                   	pop    %ebx
  80148b:	5a                   	pop    %edx
  80148c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80148d:	85 c0                	test   %eax,%eax
  80148f:	7e 28                	jle    8014b9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801491:	89 44 24 10          	mov    %eax,0x10(%esp)
  801495:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80149c:	00 
  80149d:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  8014a4:	00 
  8014a5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014ac:	00 
  8014ad:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  8014b4:	e8 fb ed ff ff       	call   8002b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8014b9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014bf:	89 ec                	mov    %ebp,%esp
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	83 ec 28             	sub    $0x28,%esp
  8014c9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014cc:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8014d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014df:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e2:	51                   	push   %ecx
  8014e3:	52                   	push   %edx
  8014e4:	53                   	push   %ebx
  8014e5:	54                   	push   %esp
  8014e6:	55                   	push   %ebp
  8014e7:	56                   	push   %esi
  8014e8:	57                   	push   %edi
  8014e9:	54                   	push   %esp
  8014ea:	5d                   	pop    %ebp
  8014eb:	8d 35 f3 14 80 00    	lea    0x8014f3,%esi
  8014f1:	0f 34                	sysenter 
  8014f3:	5f                   	pop    %edi
  8014f4:	5e                   	pop    %esi
  8014f5:	5d                   	pop    %ebp
  8014f6:	5c                   	pop    %esp
  8014f7:	5b                   	pop    %ebx
  8014f8:	5a                   	pop    %edx
  8014f9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	7e 28                	jle    801526 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801502:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801509:	00 
  80150a:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  801511:	00 
  801512:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801519:	00 
  80151a:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  801521:	e8 8e ed ff ff       	call   8002b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801526:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801529:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80152c:	89 ec                	mov    %ebp,%esp
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	89 1c 24             	mov    %ebx,(%esp)
  801539:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80153d:	ba 00 00 00 00       	mov    $0x0,%edx
  801542:	b8 0c 00 00 00       	mov    $0xc,%eax
  801547:	89 d1                	mov    %edx,%ecx
  801549:	89 d3                	mov    %edx,%ebx
  80154b:	89 d7                	mov    %edx,%edi
  80154d:	51                   	push   %ecx
  80154e:	52                   	push   %edx
  80154f:	53                   	push   %ebx
  801550:	54                   	push   %esp
  801551:	55                   	push   %ebp
  801552:	56                   	push   %esi
  801553:	57                   	push   %edi
  801554:	54                   	push   %esp
  801555:	5d                   	pop    %ebp
  801556:	8d 35 5e 15 80 00    	lea    0x80155e,%esi
  80155c:	0f 34                	sysenter 
  80155e:	5f                   	pop    %edi
  80155f:	5e                   	pop    %esi
  801560:	5d                   	pop    %ebp
  801561:	5c                   	pop    %esp
  801562:	5b                   	pop    %ebx
  801563:	5a                   	pop    %edx
  801564:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801565:	8b 1c 24             	mov    (%esp),%ebx
  801568:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80156c:	89 ec                	mov    %ebp,%esp
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	89 1c 24             	mov    %ebx,(%esp)
  801579:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80157d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801582:	b8 04 00 00 00       	mov    $0x4,%eax
  801587:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80158a:	8b 55 08             	mov    0x8(%ebp),%edx
  80158d:	89 df                	mov    %ebx,%edi
  80158f:	51                   	push   %ecx
  801590:	52                   	push   %edx
  801591:	53                   	push   %ebx
  801592:	54                   	push   %esp
  801593:	55                   	push   %ebp
  801594:	56                   	push   %esi
  801595:	57                   	push   %edi
  801596:	54                   	push   %esp
  801597:	5d                   	pop    %ebp
  801598:	8d 35 a0 15 80 00    	lea    0x8015a0,%esi
  80159e:	0f 34                	sysenter 
  8015a0:	5f                   	pop    %edi
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	5c                   	pop    %esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5a                   	pop    %edx
  8015a6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8015a7:	8b 1c 24             	mov    (%esp),%ebx
  8015aa:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015ae:	89 ec                	mov    %ebp,%esp
  8015b0:	5d                   	pop    %ebp
  8015b1:	c3                   	ret    

008015b2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	89 1c 24             	mov    %ebx,(%esp)
  8015bb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8015c9:	89 d1                	mov    %edx,%ecx
  8015cb:	89 d3                	mov    %edx,%ebx
  8015cd:	89 d7                	mov    %edx,%edi
  8015cf:	51                   	push   %ecx
  8015d0:	52                   	push   %edx
  8015d1:	53                   	push   %ebx
  8015d2:	54                   	push   %esp
  8015d3:	55                   	push   %ebp
  8015d4:	56                   	push   %esi
  8015d5:	57                   	push   %edi
  8015d6:	54                   	push   %esp
  8015d7:	5d                   	pop    %ebp
  8015d8:	8d 35 e0 15 80 00    	lea    0x8015e0,%esi
  8015de:	0f 34                	sysenter 
  8015e0:	5f                   	pop    %edi
  8015e1:	5e                   	pop    %esi
  8015e2:	5d                   	pop    %ebp
  8015e3:	5c                   	pop    %esp
  8015e4:	5b                   	pop    %ebx
  8015e5:	5a                   	pop    %edx
  8015e6:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015e7:	8b 1c 24             	mov    (%esp),%ebx
  8015ea:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015ee:	89 ec                	mov    %ebp,%esp
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	83 ec 28             	sub    $0x28,%esp
  8015f8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015fb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801603:	b8 03 00 00 00       	mov    $0x3,%eax
  801608:	8b 55 08             	mov    0x8(%ebp),%edx
  80160b:	89 cb                	mov    %ecx,%ebx
  80160d:	89 cf                	mov    %ecx,%edi
  80160f:	51                   	push   %ecx
  801610:	52                   	push   %edx
  801611:	53                   	push   %ebx
  801612:	54                   	push   %esp
  801613:	55                   	push   %ebp
  801614:	56                   	push   %esi
  801615:	57                   	push   %edi
  801616:	54                   	push   %esp
  801617:	5d                   	pop    %ebp
  801618:	8d 35 20 16 80 00    	lea    0x801620,%esi
  80161e:	0f 34                	sysenter 
  801620:	5f                   	pop    %edi
  801621:	5e                   	pop    %esi
  801622:	5d                   	pop    %ebp
  801623:	5c                   	pop    %esp
  801624:	5b                   	pop    %ebx
  801625:	5a                   	pop    %edx
  801626:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801627:	85 c0                	test   %eax,%eax
  801629:	7e 28                	jle    801653 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80162b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80162f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801636:	00 
  801637:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  80163e:	00 
  80163f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801646:	00 
  801647:	c7 04 24 7d 27 80 00 	movl   $0x80277d,(%esp)
  80164e:	e8 61 ec ff ff       	call   8002b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801653:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801656:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801659:	89 ec                	mov    %ebp,%esp
  80165b:	5d                   	pop    %ebp
  80165c:	c3                   	ret    
  80165d:	00 00                	add    %al,(%eax)
	...

00801660 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	8b 45 08             	mov    0x8(%ebp),%eax
  801666:	05 00 00 00 30       	add    $0x30000000,%eax
  80166b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	89 04 24             	mov    %eax,(%esp)
  80167c:	e8 df ff ff ff       	call   801660 <fd2num>
  801681:	05 20 00 0d 00       	add    $0xd0020,%eax
  801686:	c1 e0 0c             	shl    $0xc,%eax
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	57                   	push   %edi
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801694:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801699:	a8 01                	test   $0x1,%al
  80169b:	74 36                	je     8016d3 <fd_alloc+0x48>
  80169d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016a2:	a8 01                	test   $0x1,%al
  8016a4:	74 2d                	je     8016d3 <fd_alloc+0x48>
  8016a6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8016ab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016b0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016b5:	89 c3                	mov    %eax,%ebx
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	c1 ea 16             	shr    $0x16,%edx
  8016bc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016bf:	f6 c2 01             	test   $0x1,%dl
  8016c2:	74 14                	je     8016d8 <fd_alloc+0x4d>
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	c1 ea 0c             	shr    $0xc,%edx
  8016c9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016cc:	f6 c2 01             	test   $0x1,%dl
  8016cf:	75 10                	jne    8016e1 <fd_alloc+0x56>
  8016d1:	eb 05                	jmp    8016d8 <fd_alloc+0x4d>
  8016d3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8016d8:	89 1f                	mov    %ebx,(%edi)
  8016da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016df:	eb 17                	jmp    8016f8 <fd_alloc+0x6d>
  8016e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016eb:	75 c8                	jne    8016b5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016ed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8016f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5f                   	pop    %edi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	83 f8 1f             	cmp    $0x1f,%eax
  801706:	77 36                	ja     80173e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801708:	05 00 00 0d 00       	add    $0xd0000,%eax
  80170d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801710:	89 c2                	mov    %eax,%edx
  801712:	c1 ea 16             	shr    $0x16,%edx
  801715:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80171c:	f6 c2 01             	test   $0x1,%dl
  80171f:	74 1d                	je     80173e <fd_lookup+0x41>
  801721:	89 c2                	mov    %eax,%edx
  801723:	c1 ea 0c             	shr    $0xc,%edx
  801726:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80172d:	f6 c2 01             	test   $0x1,%dl
  801730:	74 0c                	je     80173e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801732:	8b 55 0c             	mov    0xc(%ebp),%edx
  801735:	89 02                	mov    %eax,(%edx)
  801737:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80173c:	eb 05                	jmp    801743 <fd_lookup+0x46>
  80173e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80174b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80174e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	89 04 24             	mov    %eax,(%esp)
  801758:	e8 a0 ff ff ff       	call   8016fd <fd_lookup>
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 0e                	js     80176f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801761:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801764:	8b 55 0c             	mov    0xc(%ebp),%edx
  801767:	89 50 04             	mov    %edx,0x4(%eax)
  80176a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	56                   	push   %esi
  801775:	53                   	push   %ebx
  801776:	83 ec 10             	sub    $0x10,%esp
  801779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80177f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801784:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801789:	be 0c 28 80 00       	mov    $0x80280c,%esi
		if (devtab[i]->dev_id == dev_id) {
  80178e:	39 08                	cmp    %ecx,(%eax)
  801790:	75 10                	jne    8017a2 <dev_lookup+0x31>
  801792:	eb 04                	jmp    801798 <dev_lookup+0x27>
  801794:	39 08                	cmp    %ecx,(%eax)
  801796:	75 0a                	jne    8017a2 <dev_lookup+0x31>
			*dev = devtab[i];
  801798:	89 03                	mov    %eax,(%ebx)
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80179f:	90                   	nop
  8017a0:	eb 31                	jmp    8017d3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017a2:	83 c2 01             	add    $0x1,%edx
  8017a5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	75 e8                	jne    801794 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8017b1:	8b 40 48             	mov    0x48(%eax),%eax
  8017b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bc:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  8017c3:	e8 a5 eb ff ff       	call   80036d <cprintf>
	*dev = 0;
  8017c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5e                   	pop    %esi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	53                   	push   %ebx
  8017de:	83 ec 24             	sub    $0x24,%esp
  8017e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	89 04 24             	mov    %eax,(%esp)
  8017f1:	e8 07 ff ff ff       	call   8016fd <fd_lookup>
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 53                	js     80184d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801804:	8b 00                	mov    (%eax),%eax
  801806:	89 04 24             	mov    %eax,(%esp)
  801809:	e8 63 ff ff ff       	call   801771 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 3b                	js     80184d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801812:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801817:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80181a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80181e:	74 2d                	je     80184d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801820:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801823:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80182a:	00 00 00 
	stat->st_isdir = 0;
  80182d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801834:	00 00 00 
	stat->st_dev = dev;
  801837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801844:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801847:	89 14 24             	mov    %edx,(%esp)
  80184a:	ff 50 14             	call   *0x14(%eax)
}
  80184d:	83 c4 24             	add    $0x24,%esp
  801850:	5b                   	pop    %ebx
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	53                   	push   %ebx
  801857:	83 ec 24             	sub    $0x24,%esp
  80185a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801860:	89 44 24 04          	mov    %eax,0x4(%esp)
  801864:	89 1c 24             	mov    %ebx,(%esp)
  801867:	e8 91 fe ff ff       	call   8016fd <fd_lookup>
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 5f                	js     8018cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801870:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801873:	89 44 24 04          	mov    %eax,0x4(%esp)
  801877:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187a:	8b 00                	mov    (%eax),%eax
  80187c:	89 04 24             	mov    %eax,(%esp)
  80187f:	e8 ed fe ff ff       	call   801771 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801884:	85 c0                	test   %eax,%eax
  801886:	78 47                	js     8018cf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801888:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80188b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80188f:	75 23                	jne    8018b4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801891:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801896:	8b 40 48             	mov    0x48(%eax),%eax
  801899:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a1:	c7 04 24 ac 27 80 00 	movl   $0x8027ac,(%esp)
  8018a8:	e8 c0 ea ff ff       	call   80036d <cprintf>
  8018ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018b2:	eb 1b                	jmp    8018cf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b7:	8b 48 18             	mov    0x18(%eax),%ecx
  8018ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018bf:	85 c9                	test   %ecx,%ecx
  8018c1:	74 0c                	je     8018cf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ca:	89 14 24             	mov    %edx,(%esp)
  8018cd:	ff d1                	call   *%ecx
}
  8018cf:	83 c4 24             	add    $0x24,%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 24             	sub    $0x24,%esp
  8018dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	89 1c 24             	mov    %ebx,(%esp)
  8018e9:	e8 0f fe ff ff       	call   8016fd <fd_lookup>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 66                	js     801958 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fc:	8b 00                	mov    (%eax),%eax
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	e8 6b fe ff ff       	call   801771 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801906:	85 c0                	test   %eax,%eax
  801908:	78 4e                	js     801958 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80190d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801911:	75 23                	jne    801936 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801913:	a1 04 40 80 00       	mov    0x804004,%eax
  801918:	8b 40 48             	mov    0x48(%eax),%eax
  80191b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801923:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  80192a:	e8 3e ea ff ff       	call   80036d <cprintf>
  80192f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801934:	eb 22                	jmp    801958 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801936:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801939:	8b 48 0c             	mov    0xc(%eax),%ecx
  80193c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801941:	85 c9                	test   %ecx,%ecx
  801943:	74 13                	je     801958 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801945:	8b 45 10             	mov    0x10(%ebp),%eax
  801948:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801953:	89 14 24             	mov    %edx,(%esp)
  801956:	ff d1                	call   *%ecx
}
  801958:	83 c4 24             	add    $0x24,%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	83 ec 24             	sub    $0x24,%esp
  801965:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801968:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196f:	89 1c 24             	mov    %ebx,(%esp)
  801972:	e8 86 fd ff ff       	call   8016fd <fd_lookup>
  801977:	85 c0                	test   %eax,%eax
  801979:	78 6b                	js     8019e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801985:	8b 00                	mov    (%eax),%eax
  801987:	89 04 24             	mov    %eax,(%esp)
  80198a:	e8 e2 fd ff ff       	call   801771 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 53                	js     8019e6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801993:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801996:	8b 42 08             	mov    0x8(%edx),%eax
  801999:	83 e0 03             	and    $0x3,%eax
  80199c:	83 f8 01             	cmp    $0x1,%eax
  80199f:	75 23                	jne    8019c4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8019a6:	8b 40 48             	mov    0x48(%eax),%eax
  8019a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b1:	c7 04 24 ed 27 80 00 	movl   $0x8027ed,(%esp)
  8019b8:	e8 b0 e9 ff ff       	call   80036d <cprintf>
  8019bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019c2:	eb 22                	jmp    8019e6 <read+0x88>
	}
	if (!dev->dev_read)
  8019c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c7:	8b 48 08             	mov    0x8(%eax),%ecx
  8019ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019cf:	85 c9                	test   %ecx,%ecx
  8019d1:	74 13                	je     8019e6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e1:	89 14 24             	mov    %edx,(%esp)
  8019e4:	ff d1                	call   *%ecx
}
  8019e6:	83 c4 24             	add    $0x24,%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5d                   	pop    %ebp
  8019eb:	c3                   	ret    

008019ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	57                   	push   %edi
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 1c             	sub    $0x1c,%esp
  8019f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a05:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0a:	85 f6                	test   %esi,%esi
  801a0c:	74 29                	je     801a37 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a0e:	89 f0                	mov    %esi,%eax
  801a10:	29 d0                	sub    %edx,%eax
  801a12:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a16:	03 55 0c             	add    0xc(%ebp),%edx
  801a19:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a1d:	89 3c 24             	mov    %edi,(%esp)
  801a20:	e8 39 ff ff ff       	call   80195e <read>
		if (m < 0)
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 0e                	js     801a37 <readn+0x4b>
			return m;
		if (m == 0)
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	74 08                	je     801a35 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a2d:	01 c3                	add    %eax,%ebx
  801a2f:	89 da                	mov    %ebx,%edx
  801a31:	39 f3                	cmp    %esi,%ebx
  801a33:	72 d9                	jb     801a0e <readn+0x22>
  801a35:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a37:	83 c4 1c             	add    $0x1c,%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5f                   	pop    %edi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	83 ec 20             	sub    $0x20,%esp
  801a47:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a4a:	89 34 24             	mov    %esi,(%esp)
  801a4d:	e8 0e fc ff ff       	call   801660 <fd2num>
  801a52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a55:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a59:	89 04 24             	mov    %eax,(%esp)
  801a5c:	e8 9c fc ff ff       	call   8016fd <fd_lookup>
  801a61:	89 c3                	mov    %eax,%ebx
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 05                	js     801a6c <fd_close+0x2d>
  801a67:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a6a:	74 0c                	je     801a78 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a6c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801a70:	19 c0                	sbb    %eax,%eax
  801a72:	f7 d0                	not    %eax
  801a74:	21 c3                	and    %eax,%ebx
  801a76:	eb 3d                	jmp    801ab5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7f:	8b 06                	mov    (%esi),%eax
  801a81:	89 04 24             	mov    %eax,(%esp)
  801a84:	e8 e8 fc ff ff       	call   801771 <dev_lookup>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 16                	js     801aa5 <fd_close+0x66>
		if (dev->dev_close)
  801a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a92:	8b 40 10             	mov    0x10(%eax),%eax
  801a95:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	74 07                	je     801aa5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801a9e:	89 34 24             	mov    %esi,(%esp)
  801aa1:	ff d0                	call   *%eax
  801aa3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801aa5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ab0:	e8 34 f9 ff ff       	call   8013e9 <sys_page_unmap>
	return r;
}
  801ab5:	89 d8                	mov    %ebx,%eax
  801ab7:	83 c4 20             	add    $0x20,%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ac4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ace:	89 04 24             	mov    %eax,(%esp)
  801ad1:	e8 27 fc ff ff       	call   8016fd <fd_lookup>
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 13                	js     801aed <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801ada:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ae1:	00 
  801ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae5:	89 04 24             	mov    %eax,(%esp)
  801ae8:	e8 52 ff ff ff       	call   801a3f <fd_close>
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 18             	sub    $0x18,%esp
  801af5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801af8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801afb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b02:	00 
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	89 04 24             	mov    %eax,(%esp)
  801b09:	e8 79 03 00 00       	call   801e87 <open>
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 1b                	js     801b2f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1b:	89 1c 24             	mov    %ebx,(%esp)
  801b1e:	e8 b7 fc ff ff       	call   8017da <fstat>
  801b23:	89 c6                	mov    %eax,%esi
	close(fd);
  801b25:	89 1c 24             	mov    %ebx,(%esp)
  801b28:	e8 91 ff ff ff       	call   801abe <close>
  801b2d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b2f:	89 d8                	mov    %ebx,%eax
  801b31:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b34:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b37:	89 ec                	mov    %ebp,%esp
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 14             	sub    $0x14,%esp
  801b42:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b47:	89 1c 24             	mov    %ebx,(%esp)
  801b4a:	e8 6f ff ff ff       	call   801abe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b4f:	83 c3 01             	add    $0x1,%ebx
  801b52:	83 fb 20             	cmp    $0x20,%ebx
  801b55:	75 f0                	jne    801b47 <close_all+0xc>
		close(i);
}
  801b57:	83 c4 14             	add    $0x14,%esp
  801b5a:	5b                   	pop    %ebx
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	83 ec 58             	sub    $0x58,%esp
  801b63:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b66:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b69:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b6c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b6f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b76:	8b 45 08             	mov    0x8(%ebp),%eax
  801b79:	89 04 24             	mov    %eax,(%esp)
  801b7c:	e8 7c fb ff ff       	call   8016fd <fd_lookup>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	85 c0                	test   %eax,%eax
  801b85:	0f 88 e0 00 00 00    	js     801c6b <dup+0x10e>
		return r;
	close(newfdnum);
  801b8b:	89 3c 24             	mov    %edi,(%esp)
  801b8e:	e8 2b ff ff ff       	call   801abe <close>

	newfd = INDEX2FD(newfdnum);
  801b93:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b99:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b9f:	89 04 24             	mov    %eax,(%esp)
  801ba2:	e8 c9 fa ff ff       	call   801670 <fd2data>
  801ba7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ba9:	89 34 24             	mov    %esi,(%esp)
  801bac:	e8 bf fa ff ff       	call   801670 <fd2data>
  801bb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801bb4:	89 da                	mov    %ebx,%edx
  801bb6:	89 d8                	mov    %ebx,%eax
  801bb8:	c1 e8 16             	shr    $0x16,%eax
  801bbb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bc2:	a8 01                	test   $0x1,%al
  801bc4:	74 43                	je     801c09 <dup+0xac>
  801bc6:	c1 ea 0c             	shr    $0xc,%edx
  801bc9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bd0:	a8 01                	test   $0x1,%al
  801bd2:	74 35                	je     801c09 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bd4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bdb:	25 07 0e 00 00       	and    $0xe07,%eax
  801be0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801be4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801be7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801beb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bf2:	00 
  801bf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bf7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfe:	e8 52 f8 ff ff       	call   801455 <sys_page_map>
  801c03:	89 c3                	mov    %eax,%ebx
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 3f                	js     801c48 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0c:	89 c2                	mov    %eax,%edx
  801c0e:	c1 ea 0c             	shr    $0xc,%edx
  801c11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c18:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c1e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c22:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c2d:	00 
  801c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c39:	e8 17 f8 ff ff       	call   801455 <sys_page_map>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 04                	js     801c48 <dup+0xeb>
  801c44:	89 fb                	mov    %edi,%ebx
  801c46:	eb 23                	jmp    801c6b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c48:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c53:	e8 91 f7 ff ff       	call   8013e9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c66:	e8 7e f7 ff ff       	call   8013e9 <sys_page_unmap>
	return r;
}
  801c6b:	89 d8                	mov    %ebx,%eax
  801c6d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c70:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c73:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c76:	89 ec                	mov    %ebp,%esp
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    
	...

00801c7c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 18             	sub    $0x18,%esp
  801c82:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c85:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c8c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c93:	75 11                	jne    801ca6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c95:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c9c:	e8 8f 02 00 00       	call   801f30 <ipc_find_env>
  801ca1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ca6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cad:	00 
  801cae:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cb5:	00 
  801cb6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cba:	a1 00 40 80 00       	mov    0x804000,%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 b4 02 00 00       	call   801f7b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cce:	00 
  801ccf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cda:	e8 1a 03 00 00       	call   801ff9 <ipc_recv>
}
  801cdf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ce2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ce5:	89 ec                	mov    %ebp,%esp
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    

00801ce9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	8b 40 0c             	mov    0xc(%eax),%eax
  801cf5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
  801d07:	b8 02 00 00 00       	mov    $0x2,%eax
  801d0c:	e8 6b ff ff ff       	call   801c7c <fsipc>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d1f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d24:	ba 00 00 00 00       	mov    $0x0,%edx
  801d29:	b8 06 00 00 00       	mov    $0x6,%eax
  801d2e:	e8 49 ff ff ff       	call   801c7c <fsipc>
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d40:	b8 08 00 00 00       	mov    $0x8,%eax
  801d45:	e8 32 ff ff ff       	call   801c7c <fsipc>
}
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	53                   	push   %ebx
  801d50:	83 ec 14             	sub    $0x14,%esp
  801d53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	8b 40 0c             	mov    0xc(%eax),%eax
  801d5c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d61:	ba 00 00 00 00       	mov    $0x0,%edx
  801d66:	b8 05 00 00 00       	mov    $0x5,%eax
  801d6b:	e8 0c ff ff ff       	call   801c7c <fsipc>
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 2b                	js     801d9f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d74:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d7b:	00 
  801d7c:	89 1c 24             	mov    %ebx,(%esp)
  801d7f:	e8 16 ef ff ff       	call   800c9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d84:	a1 80 50 80 00       	mov    0x805080,%eax
  801d89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d8f:	a1 84 50 80 00       	mov    0x805084,%eax
  801d94:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d9a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d9f:	83 c4 14             	add    $0x14,%esp
  801da2:	5b                   	pop    %ebx
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 18             	sub    $0x18,%esp
  801dab:	8b 45 10             	mov    0x10(%ebp),%eax
  801dae:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801db3:	76 05                	jbe    801dba <devfile_write+0x15>
  801db5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dba:	8b 55 08             	mov    0x8(%ebp),%edx
  801dbd:	8b 52 0c             	mov    0xc(%edx),%edx
  801dc0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801dc6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801ddd:	e8 a3 f0 ff ff       	call   800e85 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801de2:	ba 00 00 00 00       	mov    $0x0,%edx
  801de7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dec:	e8 8b fe ff ff       	call   801c7c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	53                   	push   %ebx
  801df7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	8b 40 0c             	mov    0xc(%eax),%eax
  801e00:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801e05:	8b 45 10             	mov    0x10(%ebp),%eax
  801e08:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801e0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e12:	b8 03 00 00 00       	mov    $0x3,%eax
  801e17:	e8 60 fe ff ff       	call   801c7c <fsipc>
  801e1c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	78 17                	js     801e39 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801e22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e26:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e2d:	00 
  801e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e31:	89 04 24             	mov    %eax,(%esp)
  801e34:	e8 4c f0 ff ff       	call   800e85 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801e39:	89 d8                	mov    %ebx,%eax
  801e3b:	83 c4 14             	add    $0x14,%esp
  801e3e:	5b                   	pop    %ebx
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	53                   	push   %ebx
  801e45:	83 ec 14             	sub    $0x14,%esp
  801e48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e4b:	89 1c 24             	mov    %ebx,(%esp)
  801e4e:	e8 fd ed ff ff       	call   800c50 <strlen>
  801e53:	89 c2                	mov    %eax,%edx
  801e55:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e5a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e60:	7f 1f                	jg     801e81 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e66:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e6d:	e8 28 ee ff ff       	call   800c9a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e72:	ba 00 00 00 00       	mov    $0x0,%edx
  801e77:	b8 07 00 00 00       	mov    $0x7,%eax
  801e7c:	e8 fb fd ff ff       	call   801c7c <fsipc>
}
  801e81:	83 c4 14             	add    $0x14,%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 28             	sub    $0x28,%esp
  801e8d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e90:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e93:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801e96:	89 34 24             	mov    %esi,(%esp)
  801e99:	e8 b2 ed ff ff       	call   800c50 <strlen>
  801e9e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ea3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ea8:	7f 6d                	jg     801f17 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801eaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ead:	89 04 24             	mov    %eax,(%esp)
  801eb0:	e8 d6 f7 ff ff       	call   80168b <fd_alloc>
  801eb5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 5c                	js     801f17 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebe:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801ec3:	89 34 24             	mov    %esi,(%esp)
  801ec6:	e8 85 ed ff ff       	call   800c50 <strlen>
  801ecb:	83 c0 01             	add    $0x1,%eax
  801ece:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ed2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801edd:	e8 a3 ef ff ff       	call   800e85 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801ee2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ee5:	b8 01 00 00 00       	mov    $0x1,%eax
  801eea:	e8 8d fd ff ff       	call   801c7c <fsipc>
  801eef:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	79 15                	jns    801f0a <open+0x83>
             fd_close(fd,0);
  801ef5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801efc:	00 
  801efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f00:	89 04 24             	mov    %eax,(%esp)
  801f03:	e8 37 fb ff ff       	call   801a3f <fd_close>
             return r;
  801f08:	eb 0d                	jmp    801f17 <open+0x90>
        }
        return fd2num(fd);
  801f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0d:	89 04 24             	mov    %eax,(%esp)
  801f10:	e8 4b f7 ff ff       	call   801660 <fd2num>
  801f15:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801f17:	89 d8                	mov    %ebx,%eax
  801f19:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f1c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f1f:	89 ec                	mov    %ebp,%esp
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    
	...

00801f30 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f36:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f41:	39 ca                	cmp    %ecx,%edx
  801f43:	75 04                	jne    801f49 <ipc_find_env+0x19>
  801f45:	b0 00                	mov    $0x0,%al
  801f47:	eb 12                	jmp    801f5b <ipc_find_env+0x2b>
  801f49:	89 c2                	mov    %eax,%edx
  801f4b:	c1 e2 07             	shl    $0x7,%edx
  801f4e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801f55:	8b 12                	mov    (%edx),%edx
  801f57:	39 ca                	cmp    %ecx,%edx
  801f59:	75 10                	jne    801f6b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801f5b:	89 c2                	mov    %eax,%edx
  801f5d:	c1 e2 07             	shl    $0x7,%edx
  801f60:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801f67:	8b 00                	mov    (%eax),%eax
  801f69:	eb 0e                	jmp    801f79 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6b:	83 c0 01             	add    $0x1,%eax
  801f6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f73:	75 d4                	jne    801f49 <ipc_find_env+0x19>
  801f75:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	57                   	push   %edi
  801f7f:	56                   	push   %esi
  801f80:	53                   	push   %ebx
  801f81:	83 ec 1c             	sub    $0x1c,%esp
  801f84:	8b 75 08             	mov    0x8(%ebp),%esi
  801f87:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801f8d:	85 db                	test   %ebx,%ebx
  801f8f:	74 19                	je     801faa <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801f91:	8b 45 14             	mov    0x14(%ebp),%eax
  801f94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fa0:	89 34 24             	mov    %esi,(%esp)
  801fa3:	e8 bc f2 ff ff       	call   801264 <sys_ipc_try_send>
  801fa8:	eb 1b                	jmp    801fc5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801faa:	8b 45 14             	mov    0x14(%ebp),%eax
  801fad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801fb8:	ee 
  801fb9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fbd:	89 34 24             	mov    %esi,(%esp)
  801fc0:	e8 9f f2 ff ff       	call   801264 <sys_ipc_try_send>
           if(ret == 0)
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	74 28                	je     801ff1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801fc9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fcc:	74 1c                	je     801fea <ipc_send+0x6f>
              panic("ipc send error");
  801fce:	c7 44 24 08 14 28 80 	movl   $0x802814,0x8(%esp)
  801fd5:	00 
  801fd6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801fdd:	00 
  801fde:	c7 04 24 23 28 80 00 	movl   $0x802823,(%esp)
  801fe5:	e8 ca e2 ff ff       	call   8002b4 <_panic>
           sys_yield();
  801fea:	e8 41 f5 ff ff       	call   801530 <sys_yield>
        }
  801fef:	eb 9c                	jmp    801f8d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801ff1:	83 c4 1c             	add    $0x1c,%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	56                   	push   %esi
  801ffd:	53                   	push   %ebx
  801ffe:	83 ec 10             	sub    $0x10,%esp
  802001:	8b 75 08             	mov    0x8(%ebp),%esi
  802004:	8b 45 0c             	mov    0xc(%ebp),%eax
  802007:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80200a:	85 c0                	test   %eax,%eax
  80200c:	75 0e                	jne    80201c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80200e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802015:	e8 df f1 ff ff       	call   8011f9 <sys_ipc_recv>
  80201a:	eb 08                	jmp    802024 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80201c:	89 04 24             	mov    %eax,(%esp)
  80201f:	e8 d5 f1 ff ff       	call   8011f9 <sys_ipc_recv>
        if(ret == 0){
  802024:	85 c0                	test   %eax,%eax
  802026:	75 26                	jne    80204e <ipc_recv+0x55>
           if(from_env_store)
  802028:	85 f6                	test   %esi,%esi
  80202a:	74 0a                	je     802036 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80202c:	a1 04 40 80 00       	mov    0x804004,%eax
  802031:	8b 40 78             	mov    0x78(%eax),%eax
  802034:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802036:	85 db                	test   %ebx,%ebx
  802038:	74 0a                	je     802044 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80203a:	a1 04 40 80 00       	mov    0x804004,%eax
  80203f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802042:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802044:	a1 04 40 80 00       	mov    0x804004,%eax
  802049:	8b 40 74             	mov    0x74(%eax),%eax
  80204c:	eb 14                	jmp    802062 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80204e:	85 f6                	test   %esi,%esi
  802050:	74 06                	je     802058 <ipc_recv+0x5f>
              *from_env_store = 0;
  802052:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802058:	85 db                	test   %ebx,%ebx
  80205a:	74 06                	je     802062 <ipc_recv+0x69>
              *perm_store = 0;
  80205c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	5b                   	pop    %ebx
  802066:	5e                   	pop    %esi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    
  802069:	00 00                	add    %al,(%eax)
  80206b:	00 00                	add    %al,(%eax)
  80206d:	00 00                	add    %al,(%eax)
	...

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	57                   	push   %edi
  802074:	56                   	push   %esi
  802075:	83 ec 10             	sub    $0x10,%esp
  802078:	8b 45 14             	mov    0x14(%ebp),%eax
  80207b:	8b 55 08             	mov    0x8(%ebp),%edx
  80207e:	8b 75 10             	mov    0x10(%ebp),%esi
  802081:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802084:	85 c0                	test   %eax,%eax
  802086:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802089:	75 35                	jne    8020c0 <__udivdi3+0x50>
  80208b:	39 fe                	cmp    %edi,%esi
  80208d:	77 61                	ja     8020f0 <__udivdi3+0x80>
  80208f:	85 f6                	test   %esi,%esi
  802091:	75 0b                	jne    80209e <__udivdi3+0x2e>
  802093:	b8 01 00 00 00       	mov    $0x1,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	f7 f6                	div    %esi
  80209c:	89 c6                	mov    %eax,%esi
  80209e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8020a1:	31 d2                	xor    %edx,%edx
  8020a3:	89 f8                	mov    %edi,%eax
  8020a5:	f7 f6                	div    %esi
  8020a7:	89 c7                	mov    %eax,%edi
  8020a9:	89 c8                	mov    %ecx,%eax
  8020ab:	f7 f6                	div    %esi
  8020ad:	89 c1                	mov    %eax,%ecx
  8020af:	89 fa                	mov    %edi,%edx
  8020b1:	89 c8                	mov    %ecx,%eax
  8020b3:	83 c4 10             	add    $0x10,%esp
  8020b6:	5e                   	pop    %esi
  8020b7:	5f                   	pop    %edi
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    
  8020ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c0:	39 f8                	cmp    %edi,%eax
  8020c2:	77 1c                	ja     8020e0 <__udivdi3+0x70>
  8020c4:	0f bd d0             	bsr    %eax,%edx
  8020c7:	83 f2 1f             	xor    $0x1f,%edx
  8020ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020cd:	75 39                	jne    802108 <__udivdi3+0x98>
  8020cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020d2:	0f 86 a0 00 00 00    	jbe    802178 <__udivdi3+0x108>
  8020d8:	39 f8                	cmp    %edi,%eax
  8020da:	0f 82 98 00 00 00    	jb     802178 <__udivdi3+0x108>
  8020e0:	31 ff                	xor    %edi,%edi
  8020e2:	31 c9                	xor    %ecx,%ecx
  8020e4:	89 c8                	mov    %ecx,%eax
  8020e6:	89 fa                	mov    %edi,%edx
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	5e                   	pop    %esi
  8020ec:	5f                   	pop    %edi
  8020ed:	5d                   	pop    %ebp
  8020ee:	c3                   	ret    
  8020ef:	90                   	nop
  8020f0:	89 d1                	mov    %edx,%ecx
  8020f2:	89 fa                	mov    %edi,%edx
  8020f4:	89 c8                	mov    %ecx,%eax
  8020f6:	31 ff                	xor    %edi,%edi
  8020f8:	f7 f6                	div    %esi
  8020fa:	89 c1                	mov    %eax,%ecx
  8020fc:	89 fa                	mov    %edi,%edx
  8020fe:	89 c8                	mov    %ecx,%eax
  802100:	83 c4 10             	add    $0x10,%esp
  802103:	5e                   	pop    %esi
  802104:	5f                   	pop    %edi
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    
  802107:	90                   	nop
  802108:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80210c:	89 f2                	mov    %esi,%edx
  80210e:	d3 e0                	shl    %cl,%eax
  802110:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802113:	b8 20 00 00 00       	mov    $0x20,%eax
  802118:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80211b:	89 c1                	mov    %eax,%ecx
  80211d:	d3 ea                	shr    %cl,%edx
  80211f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802123:	0b 55 ec             	or     -0x14(%ebp),%edx
  802126:	d3 e6                	shl    %cl,%esi
  802128:	89 c1                	mov    %eax,%ecx
  80212a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80212d:	89 fe                	mov    %edi,%esi
  80212f:	d3 ee                	shr    %cl,%esi
  802131:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802135:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802138:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80213b:	d3 e7                	shl    %cl,%edi
  80213d:	89 c1                	mov    %eax,%ecx
  80213f:	d3 ea                	shr    %cl,%edx
  802141:	09 d7                	or     %edx,%edi
  802143:	89 f2                	mov    %esi,%edx
  802145:	89 f8                	mov    %edi,%eax
  802147:	f7 75 ec             	divl   -0x14(%ebp)
  80214a:	89 d6                	mov    %edx,%esi
  80214c:	89 c7                	mov    %eax,%edi
  80214e:	f7 65 e8             	mull   -0x18(%ebp)
  802151:	39 d6                	cmp    %edx,%esi
  802153:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802156:	72 30                	jb     802188 <__udivdi3+0x118>
  802158:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80215b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	39 c2                	cmp    %eax,%edx
  802163:	73 05                	jae    80216a <__udivdi3+0xfa>
  802165:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802168:	74 1e                	je     802188 <__udivdi3+0x118>
  80216a:	89 f9                	mov    %edi,%ecx
  80216c:	31 ff                	xor    %edi,%edi
  80216e:	e9 71 ff ff ff       	jmp    8020e4 <__udivdi3+0x74>
  802173:	90                   	nop
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80217f:	e9 60 ff ff ff       	jmp    8020e4 <__udivdi3+0x74>
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80218b:	31 ff                	xor    %edi,%edi
  80218d:	89 c8                	mov    %ecx,%eax
  80218f:	89 fa                	mov    %edi,%edx
  802191:	83 c4 10             	add    $0x10,%esp
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
	...

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	57                   	push   %edi
  8021a4:	56                   	push   %esi
  8021a5:	83 ec 20             	sub    $0x20,%esp
  8021a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8021ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8021b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b4:	85 d2                	test   %edx,%edx
  8021b6:	89 c8                	mov    %ecx,%eax
  8021b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021bb:	75 13                	jne    8021d0 <__umoddi3+0x30>
  8021bd:	39 f7                	cmp    %esi,%edi
  8021bf:	76 3f                	jbe    802200 <__umoddi3+0x60>
  8021c1:	89 f2                	mov    %esi,%edx
  8021c3:	f7 f7                	div    %edi
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	31 d2                	xor    %edx,%edx
  8021c9:	83 c4 20             	add    $0x20,%esp
  8021cc:	5e                   	pop    %esi
  8021cd:	5f                   	pop    %edi
  8021ce:	5d                   	pop    %ebp
  8021cf:	c3                   	ret    
  8021d0:	39 f2                	cmp    %esi,%edx
  8021d2:	77 4c                	ja     802220 <__umoddi3+0x80>
  8021d4:	0f bd ca             	bsr    %edx,%ecx
  8021d7:	83 f1 1f             	xor    $0x1f,%ecx
  8021da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021dd:	75 51                	jne    802230 <__umoddi3+0x90>
  8021df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021e2:	0f 87 e0 00 00 00    	ja     8022c8 <__umoddi3+0x128>
  8021e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021eb:	29 f8                	sub    %edi,%eax
  8021ed:	19 d6                	sbb    %edx,%esi
  8021ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f5:	89 f2                	mov    %esi,%edx
  8021f7:	83 c4 20             	add    $0x20,%esp
  8021fa:	5e                   	pop    %esi
  8021fb:	5f                   	pop    %edi
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    
  8021fe:	66 90                	xchg   %ax,%ax
  802200:	85 ff                	test   %edi,%edi
  802202:	75 0b                	jne    80220f <__umoddi3+0x6f>
  802204:	b8 01 00 00 00       	mov    $0x1,%eax
  802209:	31 d2                	xor    %edx,%edx
  80220b:	f7 f7                	div    %edi
  80220d:	89 c7                	mov    %eax,%edi
  80220f:	89 f0                	mov    %esi,%eax
  802211:	31 d2                	xor    %edx,%edx
  802213:	f7 f7                	div    %edi
  802215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802218:	f7 f7                	div    %edi
  80221a:	eb a9                	jmp    8021c5 <__umoddi3+0x25>
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 20             	add    $0x20,%esp
  802227:	5e                   	pop    %esi
  802228:	5f                   	pop    %edi
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    
  80222b:	90                   	nop
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802234:	d3 e2                	shl    %cl,%edx
  802236:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802239:	ba 20 00 00 00       	mov    $0x20,%edx
  80223e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802241:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802244:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802248:	89 fa                	mov    %edi,%edx
  80224a:	d3 ea                	shr    %cl,%edx
  80224c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802250:	0b 55 f4             	or     -0xc(%ebp),%edx
  802253:	d3 e7                	shl    %cl,%edi
  802255:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802259:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80225c:	89 f2                	mov    %esi,%edx
  80225e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802261:	89 c7                	mov    %eax,%edi
  802263:	d3 ea                	shr    %cl,%edx
  802265:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802269:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80226c:	89 c2                	mov    %eax,%edx
  80226e:	d3 e6                	shl    %cl,%esi
  802270:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802274:	d3 ea                	shr    %cl,%edx
  802276:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80227a:	09 d6                	or     %edx,%esi
  80227c:	89 f0                	mov    %esi,%eax
  80227e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802281:	d3 e7                	shl    %cl,%edi
  802283:	89 f2                	mov    %esi,%edx
  802285:	f7 75 f4             	divl   -0xc(%ebp)
  802288:	89 d6                	mov    %edx,%esi
  80228a:	f7 65 e8             	mull   -0x18(%ebp)
  80228d:	39 d6                	cmp    %edx,%esi
  80228f:	72 2b                	jb     8022bc <__umoddi3+0x11c>
  802291:	39 c7                	cmp    %eax,%edi
  802293:	72 23                	jb     8022b8 <__umoddi3+0x118>
  802295:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802299:	29 c7                	sub    %eax,%edi
  80229b:	19 d6                	sbb    %edx,%esi
  80229d:	89 f0                	mov    %esi,%eax
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	d3 ef                	shr    %cl,%edi
  8022a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022a7:	d3 e0                	shl    %cl,%eax
  8022a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022ad:	09 f8                	or     %edi,%eax
  8022af:	d3 ea                	shr    %cl,%edx
  8022b1:	83 c4 20             	add    $0x20,%esp
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	39 d6                	cmp    %edx,%esi
  8022ba:	75 d9                	jne    802295 <__umoddi3+0xf5>
  8022bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8022bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022c2:	eb d1                	jmp    802295 <__umoddi3+0xf5>
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	39 f2                	cmp    %esi,%edx
  8022ca:	0f 82 18 ff ff ff    	jb     8021e8 <__umoddi3+0x48>
  8022d0:	e9 1d ff ff ff       	jmp    8021f2 <__umoddi3+0x52>
