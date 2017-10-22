
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
  800048:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  80004f:	e8 43 1f 00 00       	call   801f97 <open>
  800054:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 49 29 80 	movl   $0x802949,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 5b 29 80 00 	movl   $0x80295b,(%esp)
  800079:	e8 36 02 00 00       	call   8002b4 <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 6c 29 80 00 	movl   $0x80296c,(%esp)
  80008d:	e8 05 1f 00 00       	call   801f97 <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 72 29 80 	movl   $0x802972,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 5b 29 80 00 	movl   $0x80295b,(%esp)
  8000b3:	e8 fc 01 00 00       	call   8002b4 <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 81 29 80 00 	movl   $0x802981,(%esp)
  8000cd:	e8 9b 02 00 00       	call   80036d <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd e4 fd ff ff    	cmp    %edi,-0x21c(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 ec 29 80 	movl   $0x8029ec,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 5b 29 80 00 	movl   $0x80295b,(%esp)
  8000f1:	e8 be 01 00 00       	call   8002b4 <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 99 29 80 00 	movl   $0x802999,(%esp)
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
  800125:	e8 44 19 00 00       	call   801a6e <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
		sys_cputs(buf, n);
	cprintf("===\n");
  80012e:	c7 04 24 a2 29 80 00 	movl   $0x8029a2,(%esp)
  800135:	e8 33 02 00 00       	call   80036d <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 0b 17 00 00       	call   801855 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 09 18 00 00       	call   801963 <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 a7 29 80 	movl   $0x8029a7,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 5b 29 80 00 	movl   $0x80295b,(%esp)
  800179:	e8 36 01 00 00       	call   8002b4 <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 ba 29 80 00 	movl   $0x8029ba,(%esp)
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
  8001a9:	e8 37 18 00 00       	call   8019e5 <write>
  8001ae:	39 c3                	cmp    %eax,%ebx
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 c8 29 80 	movl   $0x8029c8,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 5b 29 80 00 	movl   $0x80295b,(%esp)
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
  8001e7:	e8 82 18 00 00       	call   801a6e <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
		sys_cputs(buf, n);
		if ((r = write(wfd, buf, n)) != n)
			panic("write /motd: %e", r);
	}
	cprintf("===\n");
  8001f2:	c7 04 24 a2 29 80 00 	movl   $0x8029a2,(%esp)
  8001f9:	e8 6f 01 00 00       	call   80036d <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 d8 29 80 	movl   $0x8029d8,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 5b 29 80 00 	movl   $0x80295b,(%esp)
  80021d:	e8 92 00 00 00       	call   8002b4 <_panic>

	close(rfd);
  800222:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 9e 19 00 00       	call   801bce <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 96 19 00 00       	call   801bce <close>
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
  800256:	e8 5c 14 00 00       	call   8016b7 <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	89 c2                	mov    %eax,%edx
  800262:	c1 e2 07             	shl    $0x7,%edx
  800265:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80026c:	a3 08 40 80 00       	mov    %eax,0x804008
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
  80029e:	e8 a8 19 00 00       	call   801c4b <close_all>
	sys_env_destroy(0);
  8002a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002aa:	e8 48 14 00 00       	call   8016f7 <sys_env_destroy>
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
  8002c5:	e8 ed 13 00 00       	call   8016b7 <sys_getenvid>
  8002ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e0:	c7 04 24 28 2a 80 00 	movl   $0x802a28,(%esp)
  8002e7:	e8 81 00 00 00       	call   80036d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 11 00 00 00       	call   80030c <vcprintf>
	cprintf("\n");
  8002fb:	c7 04 24 a5 29 80 00 	movl   $0x8029a5,(%esp)
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
  80043f:	e8 8c 22 00 00       	call   8026d0 <__udivdi3>
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
  8004a7:	e8 54 23 00 00       	call   802800 <__umoddi3>
  8004ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b0:	0f be 80 4b 2a 80 00 	movsbl 0x802a4b(%eax),%eax
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
  80059a:	ff 24 95 20 2c 80 00 	jmp    *0x802c20(,%edx,4)
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
  800657:	8b 14 85 80 2d 80 00 	mov    0x802d80(,%eax,4),%edx
  80065e:	85 d2                	test   %edx,%edx
  800660:	75 26                	jne    800688 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800662:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800666:	c7 44 24 08 5c 2a 80 	movl   $0x802a5c,0x8(%esp)
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
  80068c:	c7 44 24 08 a2 2e 80 	movl   $0x802ea2,0x8(%esp)
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
  8006ca:	be 65 2a 80 00       	mov    $0x802a65,%esi
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
  800974:	e8 57 1d 00 00       	call   8026d0 <__udivdi3>
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
  8009c0:	e8 3b 1e 00 00       	call   802800 <__umoddi3>
  8009c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c9:	0f be 80 4b 2a 80 00 	movsbl 0x802a4b(%eax),%eax
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
  800a75:	c7 44 24 0c 80 2b 80 	movl   $0x802b80,0xc(%esp)
  800a7c:	00 
  800a7d:	c7 44 24 08 a2 2e 80 	movl   $0x802ea2,0x8(%esp)
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
  800aab:	c7 44 24 0c b8 2b 80 	movl   $0x802bb8,0xc(%esp)
  800ab2:	00 
  800ab3:	c7 44 24 08 a2 2e 80 	movl   $0x802ea2,0x8(%esp)
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
  800b3f:	e8 bc 1c 00 00       	call   802800 <__umoddi3>
  800b44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b48:	0f be 80 4b 2a 80 00 	movsbl 0x802a4b(%eax),%eax
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
  800b81:	e8 7a 1c 00 00       	call   802800 <__umoddi3>
  800b86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b8a:	0f be 80 4b 2a 80 00 	movsbl 0x802a4b(%eax),%eax
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

0080110b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  801118:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111d:	b8 13 00 00 00       	mov    $0x13,%eax
  801122:	8b 55 08             	mov    0x8(%ebp),%edx
  801125:	89 cb                	mov    %ecx,%ebx
  801127:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801141:	8b 1c 24             	mov    (%esp),%ebx
  801144:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801148:	89 ec                	mov    %ebp,%esp
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	89 1c 24             	mov    %ebx,(%esp)
  801155:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801159:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115e:	b8 12 00 00 00       	mov    $0x12,%eax
  801163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801166:	8b 55 08             	mov    0x8(%ebp),%edx
  801169:	89 df                	mov    %ebx,%edi
  80116b:	51                   	push   %ecx
  80116c:	52                   	push   %edx
  80116d:	53                   	push   %ebx
  80116e:	54                   	push   %esp
  80116f:	55                   	push   %ebp
  801170:	56                   	push   %esi
  801171:	57                   	push   %edi
  801172:	54                   	push   %esp
  801173:	5d                   	pop    %ebp
  801174:	8d 35 7c 11 80 00    	lea    0x80117c,%esi
  80117a:	0f 34                	sysenter 
  80117c:	5f                   	pop    %edi
  80117d:	5e                   	pop    %esi
  80117e:	5d                   	pop    %ebp
  80117f:	5c                   	pop    %esp
  801180:	5b                   	pop    %ebx
  801181:	5a                   	pop    %edx
  801182:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801183:	8b 1c 24             	mov    (%esp),%ebx
  801186:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80118a:	89 ec                	mov    %ebp,%esp
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	89 1c 24             	mov    %ebx,(%esp)
  801197:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80119b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a0:	b8 11 00 00 00       	mov    $0x11,%eax
  8011a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ab:	89 df                	mov    %ebx,%edi
  8011ad:	51                   	push   %ecx
  8011ae:	52                   	push   %edx
  8011af:	53                   	push   %ebx
  8011b0:	54                   	push   %esp
  8011b1:	55                   	push   %ebp
  8011b2:	56                   	push   %esi
  8011b3:	57                   	push   %edi
  8011b4:	54                   	push   %esp
  8011b5:	5d                   	pop    %ebp
  8011b6:	8d 35 be 11 80 00    	lea    0x8011be,%esi
  8011bc:	0f 34                	sysenter 
  8011be:	5f                   	pop    %edi
  8011bf:	5e                   	pop    %esi
  8011c0:	5d                   	pop    %ebp
  8011c1:	5c                   	pop    %esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5a                   	pop    %edx
  8011c4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8011c5:	8b 1c 24             	mov    (%esp),%ebx
  8011c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011cc:	89 ec                	mov    %ebp,%esp
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	89 1c 24             	mov    %ebx,(%esp)
  8011d9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8011e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011eb:	8b 55 08             	mov    0x8(%ebp),%edx
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
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801206:	8b 1c 24             	mov    (%esp),%ebx
  801209:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80120d:	89 ec                	mov    %ebp,%esp
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	83 ec 28             	sub    $0x28,%esp
  801217:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80121a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80121d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801222:	b8 0f 00 00 00       	mov    $0xf,%eax
  801227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122a:	8b 55 08             	mov    0x8(%ebp),%edx
  80122d:	89 df                	mov    %ebx,%edi
  80122f:	51                   	push   %ecx
  801230:	52                   	push   %edx
  801231:	53                   	push   %ebx
  801232:	54                   	push   %esp
  801233:	55                   	push   %ebp
  801234:	56                   	push   %esi
  801235:	57                   	push   %edi
  801236:	54                   	push   %esp
  801237:	5d                   	pop    %ebp
  801238:	8d 35 40 12 80 00    	lea    0x801240,%esi
  80123e:	0f 34                	sysenter 
  801240:	5f                   	pop    %edi
  801241:	5e                   	pop    %esi
  801242:	5d                   	pop    %ebp
  801243:	5c                   	pop    %esp
  801244:	5b                   	pop    %ebx
  801245:	5a                   	pop    %edx
  801246:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801247:	85 c0                	test   %eax,%eax
  801249:	7e 28                	jle    801273 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80124f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801256:	00 
  801257:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  80125e:	00 
  80125f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801266:	00 
  801267:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  80126e:	e8 41 f0 ff ff       	call   8002b4 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801273:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801276:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801279:	89 ec                	mov    %ebp,%esp
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	89 1c 24             	mov    %ebx,(%esp)
  801286:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80128a:	ba 00 00 00 00       	mov    $0x0,%edx
  80128f:	b8 15 00 00 00       	mov    $0x15,%eax
  801294:	89 d1                	mov    %edx,%ecx
  801296:	89 d3                	mov    %edx,%ebx
  801298:	89 d7                	mov    %edx,%edi
  80129a:	51                   	push   %ecx
  80129b:	52                   	push   %edx
  80129c:	53                   	push   %ebx
  80129d:	54                   	push   %esp
  80129e:	55                   	push   %ebp
  80129f:	56                   	push   %esi
  8012a0:	57                   	push   %edi
  8012a1:	54                   	push   %esp
  8012a2:	5d                   	pop    %ebp
  8012a3:	8d 35 ab 12 80 00    	lea    0x8012ab,%esi
  8012a9:	0f 34                	sysenter 
  8012ab:	5f                   	pop    %edi
  8012ac:	5e                   	pop    %esi
  8012ad:	5d                   	pop    %ebp
  8012ae:	5c                   	pop    %esp
  8012af:	5b                   	pop    %ebx
  8012b0:	5a                   	pop    %edx
  8012b1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012b2:	8b 1c 24             	mov    (%esp),%ebx
  8012b5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012b9:	89 ec                	mov    %ebp,%esp
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	89 1c 24             	mov    %ebx,(%esp)
  8012c6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012cf:	b8 14 00 00 00       	mov    $0x14,%eax
  8012d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d7:	89 cb                	mov    %ecx,%ebx
  8012d9:	89 cf                	mov    %ecx,%edi
  8012db:	51                   	push   %ecx
  8012dc:	52                   	push   %edx
  8012dd:	53                   	push   %ebx
  8012de:	54                   	push   %esp
  8012df:	55                   	push   %ebp
  8012e0:	56                   	push   %esi
  8012e1:	57                   	push   %edi
  8012e2:	54                   	push   %esp
  8012e3:	5d                   	pop    %ebp
  8012e4:	8d 35 ec 12 80 00    	lea    0x8012ec,%esi
  8012ea:	0f 34                	sysenter 
  8012ec:	5f                   	pop    %edi
  8012ed:	5e                   	pop    %esi
  8012ee:	5d                   	pop    %ebp
  8012ef:	5c                   	pop    %esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5a                   	pop    %edx
  8012f2:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8012f3:	8b 1c 24             	mov    (%esp),%ebx
  8012f6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012fa:	89 ec                	mov    %ebp,%esp
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	83 ec 28             	sub    $0x28,%esp
  801304:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801307:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80130a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80130f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801314:	8b 55 08             	mov    0x8(%ebp),%edx
  801317:	89 cb                	mov    %ecx,%ebx
  801319:	89 cf                	mov    %ecx,%edi
  80131b:	51                   	push   %ecx
  80131c:	52                   	push   %edx
  80131d:	53                   	push   %ebx
  80131e:	54                   	push   %esp
  80131f:	55                   	push   %ebp
  801320:	56                   	push   %esi
  801321:	57                   	push   %edi
  801322:	54                   	push   %esp
  801323:	5d                   	pop    %ebp
  801324:	8d 35 2c 13 80 00    	lea    0x80132c,%esi
  80132a:	0f 34                	sysenter 
  80132c:	5f                   	pop    %edi
  80132d:	5e                   	pop    %esi
  80132e:	5d                   	pop    %ebp
  80132f:	5c                   	pop    %esp
  801330:	5b                   	pop    %ebx
  801331:	5a                   	pop    %edx
  801332:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801333:	85 c0                	test   %eax,%eax
  801335:	7e 28                	jle    80135f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801337:	89 44 24 10          	mov    %eax,0x10(%esp)
  80133b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801342:	00 
  801343:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  80134a:	00 
  80134b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801352:	00 
  801353:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  80135a:	e8 55 ef ff ff       	call   8002b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80135f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801362:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801365:	89 ec                	mov    %ebp,%esp
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    

00801369 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	89 1c 24             	mov    %ebx,(%esp)
  801372:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801376:	b8 0d 00 00 00       	mov    $0xd,%eax
  80137b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80137e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801384:	8b 55 08             	mov    0x8(%ebp),%edx
  801387:	51                   	push   %ecx
  801388:	52                   	push   %edx
  801389:	53                   	push   %ebx
  80138a:	54                   	push   %esp
  80138b:	55                   	push   %ebp
  80138c:	56                   	push   %esi
  80138d:	57                   	push   %edi
  80138e:	54                   	push   %esp
  80138f:	5d                   	pop    %ebp
  801390:	8d 35 98 13 80 00    	lea    0x801398,%esi
  801396:	0f 34                	sysenter 
  801398:	5f                   	pop    %edi
  801399:	5e                   	pop    %esi
  80139a:	5d                   	pop    %ebp
  80139b:	5c                   	pop    %esp
  80139c:	5b                   	pop    %ebx
  80139d:	5a                   	pop    %edx
  80139e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80139f:	8b 1c 24             	mov    (%esp),%ebx
  8013a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013a6:	89 ec                	mov    %ebp,%esp
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 28             	sub    $0x28,%esp
  8013b0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013b3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013bb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8013c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c6:	89 df                	mov    %ebx,%edi
  8013c8:	51                   	push   %ecx
  8013c9:	52                   	push   %edx
  8013ca:	53                   	push   %ebx
  8013cb:	54                   	push   %esp
  8013cc:	55                   	push   %ebp
  8013cd:	56                   	push   %esi
  8013ce:	57                   	push   %edi
  8013cf:	54                   	push   %esp
  8013d0:	5d                   	pop    %ebp
  8013d1:	8d 35 d9 13 80 00    	lea    0x8013d9,%esi
  8013d7:	0f 34                	sysenter 
  8013d9:	5f                   	pop    %edi
  8013da:	5e                   	pop    %esi
  8013db:	5d                   	pop    %ebp
  8013dc:	5c                   	pop    %esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5a                   	pop    %edx
  8013df:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	7e 28                	jle    80140c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8013ef:	00 
  8013f0:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  8013f7:	00 
  8013f8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013ff:	00 
  801400:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  801407:	e8 a8 ee ff ff       	call   8002b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80140c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80140f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801412:	89 ec                	mov    %ebp,%esp
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    

00801416 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 28             	sub    $0x28,%esp
  80141c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80141f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801422:	bb 00 00 00 00       	mov    $0x0,%ebx
  801427:	b8 0a 00 00 00       	mov    $0xa,%eax
  80142c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142f:	8b 55 08             	mov    0x8(%ebp),%edx
  801432:	89 df                	mov    %ebx,%edi
  801434:	51                   	push   %ecx
  801435:	52                   	push   %edx
  801436:	53                   	push   %ebx
  801437:	54                   	push   %esp
  801438:	55                   	push   %ebp
  801439:	56                   	push   %esi
  80143a:	57                   	push   %edi
  80143b:	54                   	push   %esp
  80143c:	5d                   	pop    %ebp
  80143d:	8d 35 45 14 80 00    	lea    0x801445,%esi
  801443:	0f 34                	sysenter 
  801445:	5f                   	pop    %edi
  801446:	5e                   	pop    %esi
  801447:	5d                   	pop    %ebp
  801448:	5c                   	pop    %esp
  801449:	5b                   	pop    %ebx
  80144a:	5a                   	pop    %edx
  80144b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80144c:	85 c0                	test   %eax,%eax
  80144e:	7e 28                	jle    801478 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801450:	89 44 24 10          	mov    %eax,0x10(%esp)
  801454:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80145b:	00 
  80145c:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  801463:	00 
  801464:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80146b:	00 
  80146c:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  801473:	e8 3c ee ff ff       	call   8002b4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801478:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80147b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80147e:	89 ec                	mov    %ebp,%esp
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 28             	sub    $0x28,%esp
  801488:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80148b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80148e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801493:	b8 09 00 00 00       	mov    $0x9,%eax
  801498:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149b:	8b 55 08             	mov    0x8(%ebp),%edx
  80149e:	89 df                	mov    %ebx,%edi
  8014a0:	51                   	push   %ecx
  8014a1:	52                   	push   %edx
  8014a2:	53                   	push   %ebx
  8014a3:	54                   	push   %esp
  8014a4:	55                   	push   %ebp
  8014a5:	56                   	push   %esi
  8014a6:	57                   	push   %edi
  8014a7:	54                   	push   %esp
  8014a8:	5d                   	pop    %ebp
  8014a9:	8d 35 b1 14 80 00    	lea    0x8014b1,%esi
  8014af:	0f 34                	sysenter 
  8014b1:	5f                   	pop    %edi
  8014b2:	5e                   	pop    %esi
  8014b3:	5d                   	pop    %ebp
  8014b4:	5c                   	pop    %esp
  8014b5:	5b                   	pop    %ebx
  8014b6:	5a                   	pop    %edx
  8014b7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	7e 28                	jle    8014e4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014c0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8014c7:	00 
  8014c8:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  8014cf:	00 
  8014d0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014d7:	00 
  8014d8:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  8014df:	e8 d0 ed ff ff       	call   8002b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8014e4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014e7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014ea:	89 ec                	mov    %ebp,%esp
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 28             	sub    $0x28,%esp
  8014f4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014f7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ff:	b8 07 00 00 00       	mov    $0x7,%eax
  801504:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801507:	8b 55 08             	mov    0x8(%ebp),%edx
  80150a:	89 df                	mov    %ebx,%edi
  80150c:	51                   	push   %ecx
  80150d:	52                   	push   %edx
  80150e:	53                   	push   %ebx
  80150f:	54                   	push   %esp
  801510:	55                   	push   %ebp
  801511:	56                   	push   %esi
  801512:	57                   	push   %edi
  801513:	54                   	push   %esp
  801514:	5d                   	pop    %ebp
  801515:	8d 35 1d 15 80 00    	lea    0x80151d,%esi
  80151b:	0f 34                	sysenter 
  80151d:	5f                   	pop    %edi
  80151e:	5e                   	pop    %esi
  80151f:	5d                   	pop    %ebp
  801520:	5c                   	pop    %esp
  801521:	5b                   	pop    %ebx
  801522:	5a                   	pop    %edx
  801523:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801524:	85 c0                	test   %eax,%eax
  801526:	7e 28                	jle    801550 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801528:	89 44 24 10          	mov    %eax,0x10(%esp)
  80152c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801533:	00 
  801534:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  80153b:	00 
  80153c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801543:	00 
  801544:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  80154b:	e8 64 ed ff ff       	call   8002b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801550:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801553:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801556:	89 ec                	mov    %ebp,%esp
  801558:	5d                   	pop    %ebp
  801559:	c3                   	ret    

0080155a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	83 ec 28             	sub    $0x28,%esp
  801560:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801563:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801566:	8b 7d 18             	mov    0x18(%ebp),%edi
  801569:	0b 7d 14             	or     0x14(%ebp),%edi
  80156c:	b8 06 00 00 00       	mov    $0x6,%eax
  801571:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801574:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801577:	8b 55 08             	mov    0x8(%ebp),%edx
  80157a:	51                   	push   %ecx
  80157b:	52                   	push   %edx
  80157c:	53                   	push   %ebx
  80157d:	54                   	push   %esp
  80157e:	55                   	push   %ebp
  80157f:	56                   	push   %esi
  801580:	57                   	push   %edi
  801581:	54                   	push   %esp
  801582:	5d                   	pop    %ebp
  801583:	8d 35 8b 15 80 00    	lea    0x80158b,%esi
  801589:	0f 34                	sysenter 
  80158b:	5f                   	pop    %edi
  80158c:	5e                   	pop    %esi
  80158d:	5d                   	pop    %ebp
  80158e:	5c                   	pop    %esp
  80158f:	5b                   	pop    %ebx
  801590:	5a                   	pop    %edx
  801591:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801592:	85 c0                	test   %eax,%eax
  801594:	7e 28                	jle    8015be <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801596:	89 44 24 10          	mov    %eax,0x10(%esp)
  80159a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8015a1:	00 
  8015a2:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  8015a9:	00 
  8015aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015b1:	00 
  8015b2:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  8015b9:	e8 f6 ec ff ff       	call   8002b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8015be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015c4:	89 ec                	mov    %ebp,%esp
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	83 ec 28             	sub    $0x28,%esp
  8015ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015d1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8015d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8015de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e7:	51                   	push   %ecx
  8015e8:	52                   	push   %edx
  8015e9:	53                   	push   %ebx
  8015ea:	54                   	push   %esp
  8015eb:	55                   	push   %ebp
  8015ec:	56                   	push   %esi
  8015ed:	57                   	push   %edi
  8015ee:	54                   	push   %esp
  8015ef:	5d                   	pop    %ebp
  8015f0:	8d 35 f8 15 80 00    	lea    0x8015f8,%esi
  8015f6:	0f 34                	sysenter 
  8015f8:	5f                   	pop    %edi
  8015f9:	5e                   	pop    %esi
  8015fa:	5d                   	pop    %ebp
  8015fb:	5c                   	pop    %esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5a                   	pop    %edx
  8015fe:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8015ff:	85 c0                	test   %eax,%eax
  801601:	7e 28                	jle    80162b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801603:	89 44 24 10          	mov    %eax,0x10(%esp)
  801607:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80160e:	00 
  80160f:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  801616:	00 
  801617:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80161e:	00 
  80161f:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  801626:	e8 89 ec ff ff       	call   8002b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80162b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80162e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801631:	89 ec                	mov    %ebp,%esp
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	89 1c 24             	mov    %ebx,(%esp)
  80163e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 0c 00 00 00       	mov    $0xc,%eax
  80164c:	89 d1                	mov    %edx,%ecx
  80164e:	89 d3                	mov    %edx,%ebx
  801650:	89 d7                	mov    %edx,%edi
  801652:	51                   	push   %ecx
  801653:	52                   	push   %edx
  801654:	53                   	push   %ebx
  801655:	54                   	push   %esp
  801656:	55                   	push   %ebp
  801657:	56                   	push   %esi
  801658:	57                   	push   %edi
  801659:	54                   	push   %esp
  80165a:	5d                   	pop    %ebp
  80165b:	8d 35 63 16 80 00    	lea    0x801663,%esi
  801661:	0f 34                	sysenter 
  801663:	5f                   	pop    %edi
  801664:	5e                   	pop    %esi
  801665:	5d                   	pop    %ebp
  801666:	5c                   	pop    %esp
  801667:	5b                   	pop    %ebx
  801668:	5a                   	pop    %edx
  801669:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80166a:	8b 1c 24             	mov    (%esp),%ebx
  80166d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801671:	89 ec                	mov    %ebp,%esp
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	89 1c 24             	mov    %ebx,(%esp)
  80167e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801682:	bb 00 00 00 00       	mov    $0x0,%ebx
  801687:	b8 04 00 00 00       	mov    $0x4,%eax
  80168c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168f:	8b 55 08             	mov    0x8(%ebp),%edx
  801692:	89 df                	mov    %ebx,%edi
  801694:	51                   	push   %ecx
  801695:	52                   	push   %edx
  801696:	53                   	push   %ebx
  801697:	54                   	push   %esp
  801698:	55                   	push   %ebp
  801699:	56                   	push   %esi
  80169a:	57                   	push   %edi
  80169b:	54                   	push   %esp
  80169c:	5d                   	pop    %ebp
  80169d:	8d 35 a5 16 80 00    	lea    0x8016a5,%esi
  8016a3:	0f 34                	sysenter 
  8016a5:	5f                   	pop    %edi
  8016a6:	5e                   	pop    %esi
  8016a7:	5d                   	pop    %ebp
  8016a8:	5c                   	pop    %esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5a                   	pop    %edx
  8016ab:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8016ac:	8b 1c 24             	mov    (%esp),%ebx
  8016af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016b3:	89 ec                	mov    %ebp,%esp
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	83 ec 08             	sub    $0x8,%esp
  8016bd:	89 1c 24             	mov    %ebx,(%esp)
  8016c0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8016c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c9:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ce:	89 d1                	mov    %edx,%ecx
  8016d0:	89 d3                	mov    %edx,%ebx
  8016d2:	89 d7                	mov    %edx,%edi
  8016d4:	51                   	push   %ecx
  8016d5:	52                   	push   %edx
  8016d6:	53                   	push   %ebx
  8016d7:	54                   	push   %esp
  8016d8:	55                   	push   %ebp
  8016d9:	56                   	push   %esi
  8016da:	57                   	push   %edi
  8016db:	54                   	push   %esp
  8016dc:	5d                   	pop    %ebp
  8016dd:	8d 35 e5 16 80 00    	lea    0x8016e5,%esi
  8016e3:	0f 34                	sysenter 
  8016e5:	5f                   	pop    %edi
  8016e6:	5e                   	pop    %esi
  8016e7:	5d                   	pop    %ebp
  8016e8:	5c                   	pop    %esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5a                   	pop    %edx
  8016eb:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8016ec:	8b 1c 24             	mov    (%esp),%ebx
  8016ef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016f3:	89 ec                	mov    %ebp,%esp
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 28             	sub    $0x28,%esp
  8016fd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801700:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801703:	b9 00 00 00 00       	mov    $0x0,%ecx
  801708:	b8 03 00 00 00       	mov    $0x3,%eax
  80170d:	8b 55 08             	mov    0x8(%ebp),%edx
  801710:	89 cb                	mov    %ecx,%ebx
  801712:	89 cf                	mov    %ecx,%edi
  801714:	51                   	push   %ecx
  801715:	52                   	push   %edx
  801716:	53                   	push   %ebx
  801717:	54                   	push   %esp
  801718:	55                   	push   %ebp
  801719:	56                   	push   %esi
  80171a:	57                   	push   %edi
  80171b:	54                   	push   %esp
  80171c:	5d                   	pop    %ebp
  80171d:	8d 35 25 17 80 00    	lea    0x801725,%esi
  801723:	0f 34                	sysenter 
  801725:	5f                   	pop    %edi
  801726:	5e                   	pop    %esi
  801727:	5d                   	pop    %ebp
  801728:	5c                   	pop    %esp
  801729:	5b                   	pop    %ebx
  80172a:	5a                   	pop    %edx
  80172b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80172c:	85 c0                	test   %eax,%eax
  80172e:	7e 28                	jle    801758 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801730:	89 44 24 10          	mov    %eax,0x10(%esp)
  801734:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80173b:	00 
  80173c:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  801743:	00 
  801744:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80174b:	00 
  80174c:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  801753:	e8 5c eb ff ff       	call   8002b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801758:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80175b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80175e:	89 ec                	mov    %ebp,%esp
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    
	...

00801770 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	05 00 00 00 30       	add    $0x30000000,%eax
  80177b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	89 04 24             	mov    %eax,(%esp)
  80178c:	e8 df ff ff ff       	call   801770 <fd2num>
  801791:	05 20 00 0d 00       	add    $0xd0020,%eax
  801796:	c1 e0 0c             	shl    $0xc,%eax
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	57                   	push   %edi
  80179f:	56                   	push   %esi
  8017a0:	53                   	push   %ebx
  8017a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8017a4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8017a9:	a8 01                	test   $0x1,%al
  8017ab:	74 36                	je     8017e3 <fd_alloc+0x48>
  8017ad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8017b2:	a8 01                	test   $0x1,%al
  8017b4:	74 2d                	je     8017e3 <fd_alloc+0x48>
  8017b6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8017bb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8017c0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	89 c2                	mov    %eax,%edx
  8017c9:	c1 ea 16             	shr    $0x16,%edx
  8017cc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8017cf:	f6 c2 01             	test   $0x1,%dl
  8017d2:	74 14                	je     8017e8 <fd_alloc+0x4d>
  8017d4:	89 c2                	mov    %eax,%edx
  8017d6:	c1 ea 0c             	shr    $0xc,%edx
  8017d9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8017dc:	f6 c2 01             	test   $0x1,%dl
  8017df:	75 10                	jne    8017f1 <fd_alloc+0x56>
  8017e1:	eb 05                	jmp    8017e8 <fd_alloc+0x4d>
  8017e3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8017e8:	89 1f                	mov    %ebx,(%edi)
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017ef:	eb 17                	jmp    801808 <fd_alloc+0x6d>
  8017f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017fb:	75 c8                	jne    8017c5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017fd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801803:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5f                   	pop    %edi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	83 f8 1f             	cmp    $0x1f,%eax
  801816:	77 36                	ja     80184e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801818:	05 00 00 0d 00       	add    $0xd0000,%eax
  80181d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801820:	89 c2                	mov    %eax,%edx
  801822:	c1 ea 16             	shr    $0x16,%edx
  801825:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80182c:	f6 c2 01             	test   $0x1,%dl
  80182f:	74 1d                	je     80184e <fd_lookup+0x41>
  801831:	89 c2                	mov    %eax,%edx
  801833:	c1 ea 0c             	shr    $0xc,%edx
  801836:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80183d:	f6 c2 01             	test   $0x1,%dl
  801840:	74 0c                	je     80184e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801842:	8b 55 0c             	mov    0xc(%ebp),%edx
  801845:	89 02                	mov    %eax,(%edx)
  801847:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80184c:	eb 05                	jmp    801853 <fd_lookup+0x46>
  80184e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80185e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	89 04 24             	mov    %eax,(%esp)
  801868:	e8 a0 ff ff ff       	call   80180d <fd_lookup>
  80186d:	85 c0                	test   %eax,%eax
  80186f:	78 0e                	js     80187f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801871:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801874:	8b 55 0c             	mov    0xc(%ebp),%edx
  801877:	89 50 04             	mov    %edx,0x4(%eax)
  80187a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	83 ec 10             	sub    $0x10,%esp
  801889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80188c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80188f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801894:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801899:	be 6c 2e 80 00       	mov    $0x802e6c,%esi
		if (devtab[i]->dev_id == dev_id) {
  80189e:	39 08                	cmp    %ecx,(%eax)
  8018a0:	75 10                	jne    8018b2 <dev_lookup+0x31>
  8018a2:	eb 04                	jmp    8018a8 <dev_lookup+0x27>
  8018a4:	39 08                	cmp    %ecx,(%eax)
  8018a6:	75 0a                	jne    8018b2 <dev_lookup+0x31>
			*dev = devtab[i];
  8018a8:	89 03                	mov    %eax,(%ebx)
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8018af:	90                   	nop
  8018b0:	eb 31                	jmp    8018e3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018b2:	83 c2 01             	add    $0x1,%edx
  8018b5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	75 e8                	jne    8018a4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8018bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8018c1:	8b 40 48             	mov    0x48(%eax),%eax
  8018c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cc:	c7 04 24 ec 2d 80 00 	movl   $0x802dec,(%esp)
  8018d3:	e8 95 ea ff ff       	call   80036d <cprintf>
	*dev = 0;
  8018d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 24             	sub    $0x24,%esp
  8018f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	e8 07 ff ff ff       	call   80180d <fd_lookup>
  801906:	85 c0                	test   %eax,%eax
  801908:	78 53                	js     80195d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801911:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801914:	8b 00                	mov    (%eax),%eax
  801916:	89 04 24             	mov    %eax,(%esp)
  801919:	e8 63 ff ff ff       	call   801881 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 3b                	js     80195d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801922:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801927:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80192e:	74 2d                	je     80195d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801930:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801933:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80193a:	00 00 00 
	stat->st_isdir = 0;
  80193d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801944:	00 00 00 
	stat->st_dev = dev;
  801947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801954:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801957:	89 14 24             	mov    %edx,(%esp)
  80195a:	ff 50 14             	call   *0x14(%eax)
}
  80195d:	83 c4 24             	add    $0x24,%esp
  801960:	5b                   	pop    %ebx
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	53                   	push   %ebx
  801967:	83 ec 24             	sub    $0x24,%esp
  80196a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801970:	89 44 24 04          	mov    %eax,0x4(%esp)
  801974:	89 1c 24             	mov    %ebx,(%esp)
  801977:	e8 91 fe ff ff       	call   80180d <fd_lookup>
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 5f                	js     8019df <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801980:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801983:	89 44 24 04          	mov    %eax,0x4(%esp)
  801987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198a:	8b 00                	mov    (%eax),%eax
  80198c:	89 04 24             	mov    %eax,(%esp)
  80198f:	e8 ed fe ff ff       	call   801881 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801994:	85 c0                	test   %eax,%eax
  801996:	78 47                	js     8019df <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801998:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80199b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80199f:	75 23                	jne    8019c4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019a1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019a6:	8b 40 48             	mov    0x48(%eax),%eax
  8019a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b1:	c7 04 24 0c 2e 80 00 	movl   $0x802e0c,(%esp)
  8019b8:	e8 b0 e9 ff ff       	call   80036d <cprintf>
  8019bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019c2:	eb 1b                	jmp    8019df <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8019c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c7:	8b 48 18             	mov    0x18(%eax),%ecx
  8019ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019cf:	85 c9                	test   %ecx,%ecx
  8019d1:	74 0c                	je     8019df <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019da:	89 14 24             	mov    %edx,(%esp)
  8019dd:	ff d1                	call   *%ecx
}
  8019df:	83 c4 24             	add    $0x24,%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	53                   	push   %ebx
  8019e9:	83 ec 24             	sub    $0x24,%esp
  8019ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f6:	89 1c 24             	mov    %ebx,(%esp)
  8019f9:	e8 0f fe ff ff       	call   80180d <fd_lookup>
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 66                	js     801a68 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0c:	8b 00                	mov    (%eax),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 6b fe ff ff       	call   801881 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 4e                	js     801a68 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a1d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801a21:	75 23                	jne    801a46 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a23:	a1 08 40 80 00       	mov    0x804008,%eax
  801a28:	8b 40 48             	mov    0x48(%eax),%eax
  801a2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a33:	c7 04 24 30 2e 80 00 	movl   $0x802e30,(%esp)
  801a3a:	e8 2e e9 ff ff       	call   80036d <cprintf>
  801a3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a44:	eb 22                	jmp    801a68 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a49:	8b 48 0c             	mov    0xc(%eax),%ecx
  801a4c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a51:	85 c9                	test   %ecx,%ecx
  801a53:	74 13                	je     801a68 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a55:	8b 45 10             	mov    0x10(%ebp),%eax
  801a58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a63:	89 14 24             	mov    %edx,(%esp)
  801a66:	ff d1                	call   *%ecx
}
  801a68:	83 c4 24             	add    $0x24,%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	53                   	push   %ebx
  801a72:	83 ec 24             	sub    $0x24,%esp
  801a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7f:	89 1c 24             	mov    %ebx,(%esp)
  801a82:	e8 86 fd ff ff       	call   80180d <fd_lookup>
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 6b                	js     801af6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a95:	8b 00                	mov    (%eax),%eax
  801a97:	89 04 24             	mov    %eax,(%esp)
  801a9a:	e8 e2 fd ff ff       	call   801881 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 53                	js     801af6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801aa3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801aa6:	8b 42 08             	mov    0x8(%edx),%eax
  801aa9:	83 e0 03             	and    $0x3,%eax
  801aac:	83 f8 01             	cmp    $0x1,%eax
  801aaf:	75 23                	jne    801ad4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ab1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ab6:	8b 40 48             	mov    0x48(%eax),%eax
  801ab9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac1:	c7 04 24 4d 2e 80 00 	movl   $0x802e4d,(%esp)
  801ac8:	e8 a0 e8 ff ff       	call   80036d <cprintf>
  801acd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801ad2:	eb 22                	jmp    801af6 <read+0x88>
	}
	if (!dev->dev_read)
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	8b 48 08             	mov    0x8(%eax),%ecx
  801ada:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801adf:	85 c9                	test   %ecx,%ecx
  801ae1:	74 13                	je     801af6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ae3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af1:	89 14 24             	mov    %edx,(%esp)
  801af4:	ff d1                	call   *%ecx
}
  801af6:	83 c4 24             	add    $0x24,%esp
  801af9:	5b                   	pop    %ebx
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	57                   	push   %edi
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 1c             	sub    $0x1c,%esp
  801b05:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b08:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b10:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1a:	85 f6                	test   %esi,%esi
  801b1c:	74 29                	je     801b47 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b1e:	89 f0                	mov    %esi,%eax
  801b20:	29 d0                	sub    %edx,%eax
  801b22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b26:	03 55 0c             	add    0xc(%ebp),%edx
  801b29:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b2d:	89 3c 24             	mov    %edi,(%esp)
  801b30:	e8 39 ff ff ff       	call   801a6e <read>
		if (m < 0)
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 0e                	js     801b47 <readn+0x4b>
			return m;
		if (m == 0)
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	74 08                	je     801b45 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b3d:	01 c3                	add    %eax,%ebx
  801b3f:	89 da                	mov    %ebx,%edx
  801b41:	39 f3                	cmp    %esi,%ebx
  801b43:	72 d9                	jb     801b1e <readn+0x22>
  801b45:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b47:	83 c4 1c             	add    $0x1c,%esp
  801b4a:	5b                   	pop    %ebx
  801b4b:	5e                   	pop    %esi
  801b4c:	5f                   	pop    %edi
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 20             	sub    $0x20,%esp
  801b57:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b5a:	89 34 24             	mov    %esi,(%esp)
  801b5d:	e8 0e fc ff ff       	call   801770 <fd2num>
  801b62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b65:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b69:	89 04 24             	mov    %eax,(%esp)
  801b6c:	e8 9c fc ff ff       	call   80180d <fd_lookup>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 05                	js     801b7c <fd_close+0x2d>
  801b77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b7a:	74 0c                	je     801b88 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801b7c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801b80:	19 c0                	sbb    %eax,%eax
  801b82:	f7 d0                	not    %eax
  801b84:	21 c3                	and    %eax,%ebx
  801b86:	eb 3d                	jmp    801bc5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8f:	8b 06                	mov    (%esi),%eax
  801b91:	89 04 24             	mov    %eax,(%esp)
  801b94:	e8 e8 fc ff ff       	call   801881 <dev_lookup>
  801b99:	89 c3                	mov    %eax,%ebx
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 16                	js     801bb5 <fd_close+0x66>
		if (dev->dev_close)
  801b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba2:	8b 40 10             	mov    0x10(%eax),%eax
  801ba5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801baa:	85 c0                	test   %eax,%eax
  801bac:	74 07                	je     801bb5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801bae:	89 34 24             	mov    %esi,(%esp)
  801bb1:	ff d0                	call   *%eax
  801bb3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801bb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc0:	e8 29 f9 ff ff       	call   8014ee <sys_page_unmap>
	return r;
}
  801bc5:	89 d8                	mov    %ebx,%eax
  801bc7:	83 c4 20             	add    $0x20,%esp
  801bca:	5b                   	pop    %ebx
  801bcb:	5e                   	pop    %esi
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	89 04 24             	mov    %eax,(%esp)
  801be1:	e8 27 fc ff ff       	call   80180d <fd_lookup>
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 13                	js     801bfd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801bea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bf1:	00 
  801bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf5:	89 04 24             	mov    %eax,(%esp)
  801bf8:	e8 52 ff ff ff       	call   801b4f <fd_close>
}
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	83 ec 18             	sub    $0x18,%esp
  801c05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c08:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c12:	00 
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	89 04 24             	mov    %eax,(%esp)
  801c19:	e8 79 03 00 00       	call   801f97 <open>
  801c1e:	89 c3                	mov    %eax,%ebx
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 1b                	js     801c3f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2b:	89 1c 24             	mov    %ebx,(%esp)
  801c2e:	e8 b7 fc ff ff       	call   8018ea <fstat>
  801c33:	89 c6                	mov    %eax,%esi
	close(fd);
  801c35:	89 1c 24             	mov    %ebx,(%esp)
  801c38:	e8 91 ff ff ff       	call   801bce <close>
  801c3d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801c3f:	89 d8                	mov    %ebx,%eax
  801c41:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c44:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c47:	89 ec                	mov    %ebp,%esp
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 14             	sub    $0x14,%esp
  801c52:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801c57:	89 1c 24             	mov    %ebx,(%esp)
  801c5a:	e8 6f ff ff ff       	call   801bce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c5f:	83 c3 01             	add    $0x1,%ebx
  801c62:	83 fb 20             	cmp    $0x20,%ebx
  801c65:	75 f0                	jne    801c57 <close_all+0xc>
		close(i);
}
  801c67:	83 c4 14             	add    $0x14,%esp
  801c6a:	5b                   	pop    %ebx
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 58             	sub    $0x58,%esp
  801c73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c79:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c7c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	89 04 24             	mov    %eax,(%esp)
  801c8c:	e8 7c fb ff ff       	call   80180d <fd_lookup>
  801c91:	89 c3                	mov    %eax,%ebx
  801c93:	85 c0                	test   %eax,%eax
  801c95:	0f 88 e0 00 00 00    	js     801d7b <dup+0x10e>
		return r;
	close(newfdnum);
  801c9b:	89 3c 24             	mov    %edi,(%esp)
  801c9e:	e8 2b ff ff ff       	call   801bce <close>

	newfd = INDEX2FD(newfdnum);
  801ca3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801ca9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801cac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801caf:	89 04 24             	mov    %eax,(%esp)
  801cb2:	e8 c9 fa ff ff       	call   801780 <fd2data>
  801cb7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801cb9:	89 34 24             	mov    %esi,(%esp)
  801cbc:	e8 bf fa ff ff       	call   801780 <fd2data>
  801cc1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801cc4:	89 da                	mov    %ebx,%edx
  801cc6:	89 d8                	mov    %ebx,%eax
  801cc8:	c1 e8 16             	shr    $0x16,%eax
  801ccb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cd2:	a8 01                	test   $0x1,%al
  801cd4:	74 43                	je     801d19 <dup+0xac>
  801cd6:	c1 ea 0c             	shr    $0xc,%edx
  801cd9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ce0:	a8 01                	test   $0x1,%al
  801ce2:	74 35                	je     801d19 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ce4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ceb:	25 07 0e 00 00       	and    $0xe07,%eax
  801cf0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cf4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801cf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cfb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d02:	00 
  801d03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0e:	e8 47 f8 ff ff       	call   80155a <sys_page_map>
  801d13:	89 c3                	mov    %eax,%ebx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 3f                	js     801d58 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d1c:	89 c2                	mov    %eax,%edx
  801d1e:	c1 ea 0c             	shr    $0xc,%edx
  801d21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d28:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d2e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d32:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d3d:	00 
  801d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d49:	e8 0c f8 ff ff       	call   80155a <sys_page_map>
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	85 c0                	test   %eax,%eax
  801d52:	78 04                	js     801d58 <dup+0xeb>
  801d54:	89 fb                	mov    %edi,%ebx
  801d56:	eb 23                	jmp    801d7b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d58:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d63:	e8 86 f7 ff ff       	call   8014ee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d76:	e8 73 f7 ff ff       	call   8014ee <sys_page_unmap>
	return r;
}
  801d7b:	89 d8                	mov    %ebx,%eax
  801d7d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d80:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d83:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d86:	89 ec                	mov    %ebp,%esp
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    
	...

00801d8c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 18             	sub    $0x18,%esp
  801d92:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d95:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d98:	89 c3                	mov    %eax,%ebx
  801d9a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d9c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801da3:	75 11                	jne    801db6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801da5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801dac:	e8 9f 07 00 00       	call   802550 <ipc_find_env>
  801db1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801db6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801dbd:	00 
  801dbe:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801dc5:	00 
  801dc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dca:	a1 00 40 80 00       	mov    0x804000,%eax
  801dcf:	89 04 24             	mov    %eax,(%esp)
  801dd2:	e8 c4 07 00 00       	call   80259b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801dd7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dde:	00 
  801ddf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dea:	e8 2a 08 00 00       	call   802619 <ipc_recv>
}
  801def:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801df2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801df5:	89 ec                	mov    %ebp,%esp
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    

00801df9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801dff:	8b 45 08             	mov    0x8(%ebp),%eax
  801e02:	8b 40 0c             	mov    0xc(%eax),%eax
  801e05:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e12:	ba 00 00 00 00       	mov    $0x0,%edx
  801e17:	b8 02 00 00 00       	mov    $0x2,%eax
  801e1c:	e8 6b ff ff ff       	call   801d8c <fsipc>
}
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e29:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801e2f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801e34:	ba 00 00 00 00       	mov    $0x0,%edx
  801e39:	b8 06 00 00 00       	mov    $0x6,%eax
  801e3e:	e8 49 ff ff ff       	call   801d8c <fsipc>
}
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e50:	b8 08 00 00 00       	mov    $0x8,%eax
  801e55:	e8 32 ff ff ff       	call   801d8c <fsipc>
}
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	53                   	push   %ebx
  801e60:	83 ec 14             	sub    $0x14,%esp
  801e63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e66:	8b 45 08             	mov    0x8(%ebp),%eax
  801e69:	8b 40 0c             	mov    0xc(%eax),%eax
  801e6c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e71:	ba 00 00 00 00       	mov    $0x0,%edx
  801e76:	b8 05 00 00 00       	mov    $0x5,%eax
  801e7b:	e8 0c ff ff ff       	call   801d8c <fsipc>
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 2b                	js     801eaf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e84:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e8b:	00 
  801e8c:	89 1c 24             	mov    %ebx,(%esp)
  801e8f:	e8 06 ee ff ff       	call   800c9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e94:	a1 80 50 80 00       	mov    0x805080,%eax
  801e99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e9f:	a1 84 50 80 00       	mov    0x805084,%eax
  801ea4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801eaa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801eaf:	83 c4 14             	add    $0x14,%esp
  801eb2:	5b                   	pop    %ebx
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    

00801eb5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	83 ec 18             	sub    $0x18,%esp
  801ebb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ec3:	76 05                	jbe    801eca <devfile_write+0x15>
  801ec5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801eca:	8b 55 08             	mov    0x8(%ebp),%edx
  801ecd:	8b 52 0c             	mov    0xc(%edx),%edx
  801ed0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801ed6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801edb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801eed:	e8 93 ef ff ff       	call   800e85 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801ef2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef7:	b8 04 00 00 00       	mov    $0x4,%eax
  801efc:	e8 8b fe ff ff       	call   801d8c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801f01:	c9                   	leave  
  801f02:	c3                   	ret    

00801f03 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	53                   	push   %ebx
  801f07:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801f10:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801f15:	8b 45 10             	mov    0x10(%ebp),%eax
  801f18:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801f1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f22:	b8 03 00 00 00       	mov    $0x3,%eax
  801f27:	e8 60 fe ff ff       	call   801d8c <fsipc>
  801f2c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 17                	js     801f49 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801f32:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f36:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f3d:	00 
  801f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 3c ef ff ff       	call   800e85 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801f49:	89 d8                	mov    %ebx,%eax
  801f4b:	83 c4 14             	add    $0x14,%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5d                   	pop    %ebp
  801f50:	c3                   	ret    

00801f51 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	53                   	push   %ebx
  801f55:	83 ec 14             	sub    $0x14,%esp
  801f58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801f5b:	89 1c 24             	mov    %ebx,(%esp)
  801f5e:	e8 ed ec ff ff       	call   800c50 <strlen>
  801f63:	89 c2                	mov    %eax,%edx
  801f65:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801f6a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801f70:	7f 1f                	jg     801f91 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f76:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f7d:	e8 18 ed ff ff       	call   800c9a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801f82:	ba 00 00 00 00       	mov    $0x0,%edx
  801f87:	b8 07 00 00 00       	mov    $0x7,%eax
  801f8c:	e8 fb fd ff ff       	call   801d8c <fsipc>
}
  801f91:	83 c4 14             	add    $0x14,%esp
  801f94:	5b                   	pop    %ebx
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    

00801f97 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 28             	sub    $0x28,%esp
  801f9d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fa0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801fa3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801fa6:	89 34 24             	mov    %esi,(%esp)
  801fa9:	e8 a2 ec ff ff       	call   800c50 <strlen>
  801fae:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801fb3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fb8:	7f 6d                	jg     802027 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbd:	89 04 24             	mov    %eax,(%esp)
  801fc0:	e8 d6 f7 ff ff       	call   80179b <fd_alloc>
  801fc5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 5c                	js     802027 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fce:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801fd3:	89 34 24             	mov    %esi,(%esp)
  801fd6:	e8 75 ec ff ff       	call   800c50 <strlen>
  801fdb:	83 c0 01             	add    $0x1,%eax
  801fde:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801fed:	e8 93 ee ff ff       	call   800e85 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801ff2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ff5:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffa:	e8 8d fd ff ff       	call   801d8c <fsipc>
  801fff:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802001:	85 c0                	test   %eax,%eax
  802003:	79 15                	jns    80201a <open+0x83>
             fd_close(fd,0);
  802005:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80200c:	00 
  80200d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802010:	89 04 24             	mov    %eax,(%esp)
  802013:	e8 37 fb ff ff       	call   801b4f <fd_close>
             return r;
  802018:	eb 0d                	jmp    802027 <open+0x90>
        }
        return fd2num(fd);
  80201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201d:	89 04 24             	mov    %eax,(%esp)
  802020:	e8 4b f7 ff ff       	call   801770 <fd2num>
  802025:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802027:	89 d8                	mov    %ebx,%eax
  802029:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80202c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80202f:	89 ec                	mov    %ebp,%esp
  802031:	5d                   	pop    %ebp
  802032:	c3                   	ret    
	...

00802040 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802046:	c7 44 24 04 78 2e 80 	movl   $0x802e78,0x4(%esp)
  80204d:	00 
  80204e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802051:	89 04 24             	mov    %eax,(%esp)
  802054:	e8 41 ec ff ff       	call   800c9a <strcpy>
	return 0;
}
  802059:	b8 00 00 00 00       	mov    $0x0,%eax
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	53                   	push   %ebx
  802064:	83 ec 14             	sub    $0x14,%esp
  802067:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80206a:	89 1c 24             	mov    %ebx,(%esp)
  80206d:	e8 1a 06 00 00       	call   80268c <pageref>
  802072:	89 c2                	mov    %eax,%edx
  802074:	b8 00 00 00 00       	mov    $0x0,%eax
  802079:	83 fa 01             	cmp    $0x1,%edx
  80207c:	75 0b                	jne    802089 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80207e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802081:	89 04 24             	mov    %eax,(%esp)
  802084:	e8 b9 02 00 00       	call   802342 <nsipc_close>
	else
		return 0;
}
  802089:	83 c4 14             	add    $0x14,%esp
  80208c:	5b                   	pop    %ebx
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802095:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80209c:	00 
  80209d:	8b 45 10             	mov    0x10(%ebp),%eax
  8020a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 c5 02 00 00       	call   80237e <nsipc_send>
}
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8020c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020c8:	00 
  8020c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020da:	8b 40 0c             	mov    0xc(%eax),%eax
  8020dd:	89 04 24             	mov    %eax,(%esp)
  8020e0:	e8 0c 03 00 00       	call   8023f1 <nsipc_recv>
}
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	56                   	push   %esi
  8020eb:	53                   	push   %ebx
  8020ec:	83 ec 20             	sub    $0x20,%esp
  8020ef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f4:	89 04 24             	mov    %eax,(%esp)
  8020f7:	e8 9f f6 ff ff       	call   80179b <fd_alloc>
  8020fc:	89 c3                	mov    %eax,%ebx
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 21                	js     802123 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802102:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802109:	00 
  80210a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802111:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802118:	e8 ab f4 ff ff       	call   8015c8 <sys_page_alloc>
  80211d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80211f:	85 c0                	test   %eax,%eax
  802121:	79 0a                	jns    80212d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802123:	89 34 24             	mov    %esi,(%esp)
  802126:	e8 17 02 00 00       	call   802342 <nsipc_close>
		return r;
  80212b:	eb 28                	jmp    802155 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80212d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802133:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802136:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802145:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214b:	89 04 24             	mov    %eax,(%esp)
  80214e:	e8 1d f6 ff ff       	call   801770 <fd2num>
  802153:	89 c3                	mov    %eax,%ebx
}
  802155:	89 d8                	mov    %ebx,%eax
  802157:	83 c4 20             	add    $0x20,%esp
  80215a:	5b                   	pop    %ebx
  80215b:	5e                   	pop    %esi
  80215c:	5d                   	pop    %ebp
  80215d:	c3                   	ret    

0080215e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80215e:	55                   	push   %ebp
  80215f:	89 e5                	mov    %esp,%ebp
  802161:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802164:	8b 45 10             	mov    0x10(%ebp),%eax
  802167:	89 44 24 08          	mov    %eax,0x8(%esp)
  80216b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80216e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802172:	8b 45 08             	mov    0x8(%ebp),%eax
  802175:	89 04 24             	mov    %eax,(%esp)
  802178:	e8 79 01 00 00       	call   8022f6 <nsipc_socket>
  80217d:	85 c0                	test   %eax,%eax
  80217f:	78 05                	js     802186 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802181:	e8 61 ff ff ff       	call   8020e7 <alloc_sockfd>
}
  802186:	c9                   	leave  
  802187:	c3                   	ret    

00802188 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80218e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802191:	89 54 24 04          	mov    %edx,0x4(%esp)
  802195:	89 04 24             	mov    %eax,(%esp)
  802198:	e8 70 f6 ff ff       	call   80180d <fd_lookup>
  80219d:	85 c0                	test   %eax,%eax
  80219f:	78 15                	js     8021b6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8021a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a4:	8b 0a                	mov    (%edx),%ecx
  8021a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8021ab:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  8021b1:	75 03                	jne    8021b6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8021b3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8021b6:	c9                   	leave  
  8021b7:	c3                   	ret    

008021b8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021be:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c1:	e8 c2 ff ff ff       	call   802188 <fd2sockid>
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	78 0f                	js     8021d9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8021ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 47 01 00 00       	call   802320 <nsipc_listen>
}
  8021d9:	c9                   	leave  
  8021da:	c3                   	ret    

008021db <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e4:	e8 9f ff ff ff       	call   802188 <fd2sockid>
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	78 16                	js     802203 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8021ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8021f0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021fb:	89 04 24             	mov    %eax,(%esp)
  8021fe:	e8 6e 02 00 00       	call   802471 <nsipc_connect>
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	e8 75 ff ff ff       	call   802188 <fd2sockid>
  802213:	85 c0                	test   %eax,%eax
  802215:	78 0f                	js     802226 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80221e:	89 04 24             	mov    %eax,(%esp)
  802221:	e8 36 01 00 00       	call   80235c <nsipc_shutdown>
}
  802226:	c9                   	leave  
  802227:	c3                   	ret    

00802228 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80222e:	8b 45 08             	mov    0x8(%ebp),%eax
  802231:	e8 52 ff ff ff       	call   802188 <fd2sockid>
  802236:	85 c0                	test   %eax,%eax
  802238:	78 16                	js     802250 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80223a:	8b 55 10             	mov    0x10(%ebp),%edx
  80223d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802241:	8b 55 0c             	mov    0xc(%ebp),%edx
  802244:	89 54 24 04          	mov    %edx,0x4(%esp)
  802248:	89 04 24             	mov    %eax,(%esp)
  80224b:	e8 60 02 00 00       	call   8024b0 <nsipc_bind>
}
  802250:	c9                   	leave  
  802251:	c3                   	ret    

00802252 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
  80225b:	e8 28 ff ff ff       	call   802188 <fd2sockid>
  802260:	85 c0                	test   %eax,%eax
  802262:	78 1f                	js     802283 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802264:	8b 55 10             	mov    0x10(%ebp),%edx
  802267:	89 54 24 08          	mov    %edx,0x8(%esp)
  80226b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80226e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802272:	89 04 24             	mov    %eax,(%esp)
  802275:	e8 75 02 00 00       	call   8024ef <nsipc_accept>
  80227a:	85 c0                	test   %eax,%eax
  80227c:	78 05                	js     802283 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80227e:	e8 64 fe ff ff       	call   8020e7 <alloc_sockfd>
}
  802283:	c9                   	leave  
  802284:	c3                   	ret    
	...

00802290 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	53                   	push   %ebx
  802294:	83 ec 14             	sub    $0x14,%esp
  802297:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802299:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8022a0:	75 11                	jne    8022b3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8022a2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8022a9:	e8 a2 02 00 00       	call   802550 <ipc_find_env>
  8022ae:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8022b3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8022ba:	00 
  8022bb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8022c2:	00 
  8022c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8022cc:	89 04 24             	mov    %eax,(%esp)
  8022cf:	e8 c7 02 00 00       	call   80259b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8022d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022db:	00 
  8022dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022e3:	00 
  8022e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022eb:	e8 29 03 00 00       	call   802619 <ipc_recv>
}
  8022f0:	83 c4 14             	add    $0x14,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5d                   	pop    %ebp
  8022f5:	c3                   	ret    

008022f6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802304:	8b 45 0c             	mov    0xc(%ebp),%eax
  802307:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80230c:	8b 45 10             	mov    0x10(%ebp),%eax
  80230f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802314:	b8 09 00 00 00       	mov    $0x9,%eax
  802319:	e8 72 ff ff ff       	call   802290 <nsipc>
}
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    

00802320 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802326:	8b 45 08             	mov    0x8(%ebp),%eax
  802329:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80232e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802331:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802336:	b8 06 00 00 00       	mov    $0x6,%eax
  80233b:	e8 50 ff ff ff       	call   802290 <nsipc>
}
  802340:	c9                   	leave  
  802341:	c3                   	ret    

00802342 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802348:	8b 45 08             	mov    0x8(%ebp),%eax
  80234b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802350:	b8 04 00 00 00       	mov    $0x4,%eax
  802355:	e8 36 ff ff ff       	call   802290 <nsipc>
}
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802362:	8b 45 08             	mov    0x8(%ebp),%eax
  802365:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80236a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802372:	b8 03 00 00 00       	mov    $0x3,%eax
  802377:	e8 14 ff ff ff       	call   802290 <nsipc>
}
  80237c:	c9                   	leave  
  80237d:	c3                   	ret    

0080237e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	53                   	push   %ebx
  802382:	83 ec 14             	sub    $0x14,%esp
  802385:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802388:	8b 45 08             	mov    0x8(%ebp),%eax
  80238b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802390:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802396:	7e 24                	jle    8023bc <nsipc_send+0x3e>
  802398:	c7 44 24 0c 84 2e 80 	movl   $0x802e84,0xc(%esp)
  80239f:	00 
  8023a0:	c7 44 24 08 90 2e 80 	movl   $0x802e90,0x8(%esp)
  8023a7:	00 
  8023a8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8023af:	00 
  8023b0:	c7 04 24 a5 2e 80 00 	movl   $0x802ea5,(%esp)
  8023b7:	e8 f8 de ff ff       	call   8002b4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8023ce:	e8 b2 ea ff ff       	call   800e85 <memmove>
	nsipcbuf.send.req_size = size;
  8023d3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8023d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8023dc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8023e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8023e6:	e8 a5 fe ff ff       	call   802290 <nsipc>
}
  8023eb:	83 c4 14             	add    $0x14,%esp
  8023ee:	5b                   	pop    %ebx
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    

008023f1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	56                   	push   %esi
  8023f5:	53                   	push   %ebx
  8023f6:	83 ec 10             	sub    $0x10,%esp
  8023f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802404:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80240a:	8b 45 14             	mov    0x14(%ebp),%eax
  80240d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802412:	b8 07 00 00 00       	mov    $0x7,%eax
  802417:	e8 74 fe ff ff       	call   802290 <nsipc>
  80241c:	89 c3                	mov    %eax,%ebx
  80241e:	85 c0                	test   %eax,%eax
  802420:	78 46                	js     802468 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802422:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802427:	7f 04                	jg     80242d <nsipc_recv+0x3c>
  802429:	39 c6                	cmp    %eax,%esi
  80242b:	7d 24                	jge    802451 <nsipc_recv+0x60>
  80242d:	c7 44 24 0c b1 2e 80 	movl   $0x802eb1,0xc(%esp)
  802434:	00 
  802435:	c7 44 24 08 90 2e 80 	movl   $0x802e90,0x8(%esp)
  80243c:	00 
  80243d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802444:	00 
  802445:	c7 04 24 a5 2e 80 00 	movl   $0x802ea5,(%esp)
  80244c:	e8 63 de ff ff       	call   8002b4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802451:	89 44 24 08          	mov    %eax,0x8(%esp)
  802455:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80245c:	00 
  80245d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802460:	89 04 24             	mov    %eax,(%esp)
  802463:	e8 1d ea ff ff       	call   800e85 <memmove>
	}

	return r;
}
  802468:	89 d8                	mov    %ebx,%eax
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5d                   	pop    %ebp
  802470:	c3                   	ret    

00802471 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802471:	55                   	push   %ebp
  802472:	89 e5                	mov    %esp,%ebp
  802474:	53                   	push   %ebx
  802475:	83 ec 14             	sub    $0x14,%esp
  802478:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80247b:	8b 45 08             	mov    0x8(%ebp),%eax
  80247e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802483:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802487:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80248e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802495:	e8 eb e9 ff ff       	call   800e85 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80249a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8024a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8024a5:	e8 e6 fd ff ff       	call   802290 <nsipc>
}
  8024aa:	83 c4 14             	add    $0x14,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5d                   	pop    %ebp
  8024af:	c3                   	ret    

008024b0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 14             	sub    $0x14,%esp
  8024b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024cd:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8024d4:	e8 ac e9 ff ff       	call   800e85 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024d9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8024df:	b8 02 00 00 00       	mov    $0x2,%eax
  8024e4:	e8 a7 fd ff ff       	call   802290 <nsipc>
}
  8024e9:	83 c4 14             	add    $0x14,%esp
  8024ec:	5b                   	pop    %ebx
  8024ed:	5d                   	pop    %ebp
  8024ee:	c3                   	ret    

008024ef <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024ef:	55                   	push   %ebp
  8024f0:	89 e5                	mov    %esp,%ebp
  8024f2:	83 ec 18             	sub    $0x18,%esp
  8024f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8024f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8024fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fe:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802503:	b8 01 00 00 00       	mov    $0x1,%eax
  802508:	e8 83 fd ff ff       	call   802290 <nsipc>
  80250d:	89 c3                	mov    %eax,%ebx
  80250f:	85 c0                	test   %eax,%eax
  802511:	78 25                	js     802538 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802513:	be 10 60 80 00       	mov    $0x806010,%esi
  802518:	8b 06                	mov    (%esi),%eax
  80251a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80251e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802525:	00 
  802526:	8b 45 0c             	mov    0xc(%ebp),%eax
  802529:	89 04 24             	mov    %eax,(%esp)
  80252c:	e8 54 e9 ff ff       	call   800e85 <memmove>
		*addrlen = ret->ret_addrlen;
  802531:	8b 16                	mov    (%esi),%edx
  802533:	8b 45 10             	mov    0x10(%ebp),%eax
  802536:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80253d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802540:	89 ec                	mov    %ebp,%esp
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    
	...

00802550 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802556:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80255c:	b8 01 00 00 00       	mov    $0x1,%eax
  802561:	39 ca                	cmp    %ecx,%edx
  802563:	75 04                	jne    802569 <ipc_find_env+0x19>
  802565:	b0 00                	mov    $0x0,%al
  802567:	eb 12                	jmp    80257b <ipc_find_env+0x2b>
  802569:	89 c2                	mov    %eax,%edx
  80256b:	c1 e2 07             	shl    $0x7,%edx
  80256e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802575:	8b 12                	mov    (%edx),%edx
  802577:	39 ca                	cmp    %ecx,%edx
  802579:	75 10                	jne    80258b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80257b:	89 c2                	mov    %eax,%edx
  80257d:	c1 e2 07             	shl    $0x7,%edx
  802580:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802587:	8b 00                	mov    (%eax),%eax
  802589:	eb 0e                	jmp    802599 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80258b:	83 c0 01             	add    $0x1,%eax
  80258e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802593:	75 d4                	jne    802569 <ipc_find_env+0x19>
  802595:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    

0080259b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	57                   	push   %edi
  80259f:	56                   	push   %esi
  8025a0:	53                   	push   %ebx
  8025a1:	83 ec 1c             	sub    $0x1c,%esp
  8025a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8025a7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8025ad:	85 db                	test   %ebx,%ebx
  8025af:	74 19                	je     8025ca <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8025b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8025b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025c0:	89 34 24             	mov    %esi,(%esp)
  8025c3:	e8 a1 ed ff ff       	call   801369 <sys_ipc_try_send>
  8025c8:	eb 1b                	jmp    8025e5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8025ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8025cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025d1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8025d8:	ee 
  8025d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025dd:	89 34 24             	mov    %esi,(%esp)
  8025e0:	e8 84 ed ff ff       	call   801369 <sys_ipc_try_send>
           if(ret == 0)
  8025e5:	85 c0                	test   %eax,%eax
  8025e7:	74 28                	je     802611 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8025e9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025ec:	74 1c                	je     80260a <ipc_send+0x6f>
              panic("ipc send error");
  8025ee:	c7 44 24 08 c6 2e 80 	movl   $0x802ec6,0x8(%esp)
  8025f5:	00 
  8025f6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8025fd:	00 
  8025fe:	c7 04 24 d5 2e 80 00 	movl   $0x802ed5,(%esp)
  802605:	e8 aa dc ff ff       	call   8002b4 <_panic>
           sys_yield();
  80260a:	e8 26 f0 ff ff       	call   801635 <sys_yield>
        }
  80260f:	eb 9c                	jmp    8025ad <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802611:	83 c4 1c             	add    $0x1c,%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    

00802619 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802619:	55                   	push   %ebp
  80261a:	89 e5                	mov    %esp,%ebp
  80261c:	56                   	push   %esi
  80261d:	53                   	push   %ebx
  80261e:	83 ec 10             	sub    $0x10,%esp
  802621:	8b 75 08             	mov    0x8(%ebp),%esi
  802624:	8b 45 0c             	mov    0xc(%ebp),%eax
  802627:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80262a:	85 c0                	test   %eax,%eax
  80262c:	75 0e                	jne    80263c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80262e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802635:	e8 c4 ec ff ff       	call   8012fe <sys_ipc_recv>
  80263a:	eb 08                	jmp    802644 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80263c:	89 04 24             	mov    %eax,(%esp)
  80263f:	e8 ba ec ff ff       	call   8012fe <sys_ipc_recv>
        if(ret == 0){
  802644:	85 c0                	test   %eax,%eax
  802646:	75 26                	jne    80266e <ipc_recv+0x55>
           if(from_env_store)
  802648:	85 f6                	test   %esi,%esi
  80264a:	74 0a                	je     802656 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80264c:	a1 08 40 80 00       	mov    0x804008,%eax
  802651:	8b 40 78             	mov    0x78(%eax),%eax
  802654:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802656:	85 db                	test   %ebx,%ebx
  802658:	74 0a                	je     802664 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80265a:	a1 08 40 80 00       	mov    0x804008,%eax
  80265f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802662:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802664:	a1 08 40 80 00       	mov    0x804008,%eax
  802669:	8b 40 74             	mov    0x74(%eax),%eax
  80266c:	eb 14                	jmp    802682 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80266e:	85 f6                	test   %esi,%esi
  802670:	74 06                	je     802678 <ipc_recv+0x5f>
              *from_env_store = 0;
  802672:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802678:	85 db                	test   %ebx,%ebx
  80267a:	74 06                	je     802682 <ipc_recv+0x69>
              *perm_store = 0;
  80267c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802682:	83 c4 10             	add    $0x10,%esp
  802685:	5b                   	pop    %ebx
  802686:	5e                   	pop    %esi
  802687:	5d                   	pop    %ebp
  802688:	c3                   	ret    
  802689:	00 00                	add    %al,(%eax)
	...

0080268c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80268c:	55                   	push   %ebp
  80268d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80268f:	8b 45 08             	mov    0x8(%ebp),%eax
  802692:	89 c2                	mov    %eax,%edx
  802694:	c1 ea 16             	shr    $0x16,%edx
  802697:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80269e:	f6 c2 01             	test   $0x1,%dl
  8026a1:	74 20                	je     8026c3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8026a3:	c1 e8 0c             	shr    $0xc,%eax
  8026a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026ad:	a8 01                	test   $0x1,%al
  8026af:	74 12                	je     8026c3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026b1:	c1 e8 0c             	shr    $0xc,%eax
  8026b4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8026b9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8026be:	0f b7 c0             	movzwl %ax,%eax
  8026c1:	eb 05                	jmp    8026c8 <pageref+0x3c>
  8026c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026c8:	5d                   	pop    %ebp
  8026c9:	c3                   	ret    
  8026ca:	00 00                	add    %al,(%eax)
  8026cc:	00 00                	add    %al,(%eax)
	...

008026d0 <__udivdi3>:
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	57                   	push   %edi
  8026d4:	56                   	push   %esi
  8026d5:	83 ec 10             	sub    $0x10,%esp
  8026d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8026db:	8b 55 08             	mov    0x8(%ebp),%edx
  8026de:	8b 75 10             	mov    0x10(%ebp),%esi
  8026e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026e4:	85 c0                	test   %eax,%eax
  8026e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8026e9:	75 35                	jne    802720 <__udivdi3+0x50>
  8026eb:	39 fe                	cmp    %edi,%esi
  8026ed:	77 61                	ja     802750 <__udivdi3+0x80>
  8026ef:	85 f6                	test   %esi,%esi
  8026f1:	75 0b                	jne    8026fe <__udivdi3+0x2e>
  8026f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8026f8:	31 d2                	xor    %edx,%edx
  8026fa:	f7 f6                	div    %esi
  8026fc:	89 c6                	mov    %eax,%esi
  8026fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802701:	31 d2                	xor    %edx,%edx
  802703:	89 f8                	mov    %edi,%eax
  802705:	f7 f6                	div    %esi
  802707:	89 c7                	mov    %eax,%edi
  802709:	89 c8                	mov    %ecx,%eax
  80270b:	f7 f6                	div    %esi
  80270d:	89 c1                	mov    %eax,%ecx
  80270f:	89 fa                	mov    %edi,%edx
  802711:	89 c8                	mov    %ecx,%eax
  802713:	83 c4 10             	add    $0x10,%esp
  802716:	5e                   	pop    %esi
  802717:	5f                   	pop    %edi
  802718:	5d                   	pop    %ebp
  802719:	c3                   	ret    
  80271a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802720:	39 f8                	cmp    %edi,%eax
  802722:	77 1c                	ja     802740 <__udivdi3+0x70>
  802724:	0f bd d0             	bsr    %eax,%edx
  802727:	83 f2 1f             	xor    $0x1f,%edx
  80272a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80272d:	75 39                	jne    802768 <__udivdi3+0x98>
  80272f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802732:	0f 86 a0 00 00 00    	jbe    8027d8 <__udivdi3+0x108>
  802738:	39 f8                	cmp    %edi,%eax
  80273a:	0f 82 98 00 00 00    	jb     8027d8 <__udivdi3+0x108>
  802740:	31 ff                	xor    %edi,%edi
  802742:	31 c9                	xor    %ecx,%ecx
  802744:	89 c8                	mov    %ecx,%eax
  802746:	89 fa                	mov    %edi,%edx
  802748:	83 c4 10             	add    $0x10,%esp
  80274b:	5e                   	pop    %esi
  80274c:	5f                   	pop    %edi
  80274d:	5d                   	pop    %ebp
  80274e:	c3                   	ret    
  80274f:	90                   	nop
  802750:	89 d1                	mov    %edx,%ecx
  802752:	89 fa                	mov    %edi,%edx
  802754:	89 c8                	mov    %ecx,%eax
  802756:	31 ff                	xor    %edi,%edi
  802758:	f7 f6                	div    %esi
  80275a:	89 c1                	mov    %eax,%ecx
  80275c:	89 fa                	mov    %edi,%edx
  80275e:	89 c8                	mov    %ecx,%eax
  802760:	83 c4 10             	add    $0x10,%esp
  802763:	5e                   	pop    %esi
  802764:	5f                   	pop    %edi
  802765:	5d                   	pop    %ebp
  802766:	c3                   	ret    
  802767:	90                   	nop
  802768:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80276c:	89 f2                	mov    %esi,%edx
  80276e:	d3 e0                	shl    %cl,%eax
  802770:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802773:	b8 20 00 00 00       	mov    $0x20,%eax
  802778:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80277b:	89 c1                	mov    %eax,%ecx
  80277d:	d3 ea                	shr    %cl,%edx
  80277f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802783:	0b 55 ec             	or     -0x14(%ebp),%edx
  802786:	d3 e6                	shl    %cl,%esi
  802788:	89 c1                	mov    %eax,%ecx
  80278a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80278d:	89 fe                	mov    %edi,%esi
  80278f:	d3 ee                	shr    %cl,%esi
  802791:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802795:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802798:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80279b:	d3 e7                	shl    %cl,%edi
  80279d:	89 c1                	mov    %eax,%ecx
  80279f:	d3 ea                	shr    %cl,%edx
  8027a1:	09 d7                	or     %edx,%edi
  8027a3:	89 f2                	mov    %esi,%edx
  8027a5:	89 f8                	mov    %edi,%eax
  8027a7:	f7 75 ec             	divl   -0x14(%ebp)
  8027aa:	89 d6                	mov    %edx,%esi
  8027ac:	89 c7                	mov    %eax,%edi
  8027ae:	f7 65 e8             	mull   -0x18(%ebp)
  8027b1:	39 d6                	cmp    %edx,%esi
  8027b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027b6:	72 30                	jb     8027e8 <__udivdi3+0x118>
  8027b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8027bf:	d3 e2                	shl    %cl,%edx
  8027c1:	39 c2                	cmp    %eax,%edx
  8027c3:	73 05                	jae    8027ca <__udivdi3+0xfa>
  8027c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8027c8:	74 1e                	je     8027e8 <__udivdi3+0x118>
  8027ca:	89 f9                	mov    %edi,%ecx
  8027cc:	31 ff                	xor    %edi,%edi
  8027ce:	e9 71 ff ff ff       	jmp    802744 <__udivdi3+0x74>
  8027d3:	90                   	nop
  8027d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d8:	31 ff                	xor    %edi,%edi
  8027da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8027df:	e9 60 ff ff ff       	jmp    802744 <__udivdi3+0x74>
  8027e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8027eb:	31 ff                	xor    %edi,%edi
  8027ed:	89 c8                	mov    %ecx,%eax
  8027ef:	89 fa                	mov    %edi,%edx
  8027f1:	83 c4 10             	add    $0x10,%esp
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
	...

00802800 <__umoddi3>:
  802800:	55                   	push   %ebp
  802801:	89 e5                	mov    %esp,%ebp
  802803:	57                   	push   %edi
  802804:	56                   	push   %esi
  802805:	83 ec 20             	sub    $0x20,%esp
  802808:	8b 55 14             	mov    0x14(%ebp),%edx
  80280b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80280e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802811:	8b 75 0c             	mov    0xc(%ebp),%esi
  802814:	85 d2                	test   %edx,%edx
  802816:	89 c8                	mov    %ecx,%eax
  802818:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80281b:	75 13                	jne    802830 <__umoddi3+0x30>
  80281d:	39 f7                	cmp    %esi,%edi
  80281f:	76 3f                	jbe    802860 <__umoddi3+0x60>
  802821:	89 f2                	mov    %esi,%edx
  802823:	f7 f7                	div    %edi
  802825:	89 d0                	mov    %edx,%eax
  802827:	31 d2                	xor    %edx,%edx
  802829:	83 c4 20             	add    $0x20,%esp
  80282c:	5e                   	pop    %esi
  80282d:	5f                   	pop    %edi
  80282e:	5d                   	pop    %ebp
  80282f:	c3                   	ret    
  802830:	39 f2                	cmp    %esi,%edx
  802832:	77 4c                	ja     802880 <__umoddi3+0x80>
  802834:	0f bd ca             	bsr    %edx,%ecx
  802837:	83 f1 1f             	xor    $0x1f,%ecx
  80283a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80283d:	75 51                	jne    802890 <__umoddi3+0x90>
  80283f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802842:	0f 87 e0 00 00 00    	ja     802928 <__umoddi3+0x128>
  802848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80284b:	29 f8                	sub    %edi,%eax
  80284d:	19 d6                	sbb    %edx,%esi
  80284f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802852:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802855:	89 f2                	mov    %esi,%edx
  802857:	83 c4 20             	add    $0x20,%esp
  80285a:	5e                   	pop    %esi
  80285b:	5f                   	pop    %edi
  80285c:	5d                   	pop    %ebp
  80285d:	c3                   	ret    
  80285e:	66 90                	xchg   %ax,%ax
  802860:	85 ff                	test   %edi,%edi
  802862:	75 0b                	jne    80286f <__umoddi3+0x6f>
  802864:	b8 01 00 00 00       	mov    $0x1,%eax
  802869:	31 d2                	xor    %edx,%edx
  80286b:	f7 f7                	div    %edi
  80286d:	89 c7                	mov    %eax,%edi
  80286f:	89 f0                	mov    %esi,%eax
  802871:	31 d2                	xor    %edx,%edx
  802873:	f7 f7                	div    %edi
  802875:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802878:	f7 f7                	div    %edi
  80287a:	eb a9                	jmp    802825 <__umoddi3+0x25>
  80287c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802880:	89 c8                	mov    %ecx,%eax
  802882:	89 f2                	mov    %esi,%edx
  802884:	83 c4 20             	add    $0x20,%esp
  802887:	5e                   	pop    %esi
  802888:	5f                   	pop    %edi
  802889:	5d                   	pop    %ebp
  80288a:	c3                   	ret    
  80288b:	90                   	nop
  80288c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802890:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802894:	d3 e2                	shl    %cl,%edx
  802896:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802899:	ba 20 00 00 00       	mov    $0x20,%edx
  80289e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8028a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8028a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8028a8:	89 fa                	mov    %edi,%edx
  8028aa:	d3 ea                	shr    %cl,%edx
  8028ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8028b3:	d3 e7                	shl    %cl,%edi
  8028b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8028b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8028bc:	89 f2                	mov    %esi,%edx
  8028be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8028c1:	89 c7                	mov    %eax,%edi
  8028c3:	d3 ea                	shr    %cl,%edx
  8028c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8028cc:	89 c2                	mov    %eax,%edx
  8028ce:	d3 e6                	shl    %cl,%esi
  8028d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8028d4:	d3 ea                	shr    %cl,%edx
  8028d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028da:	09 d6                	or     %edx,%esi
  8028dc:	89 f0                	mov    %esi,%eax
  8028de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8028e1:	d3 e7                	shl    %cl,%edi
  8028e3:	89 f2                	mov    %esi,%edx
  8028e5:	f7 75 f4             	divl   -0xc(%ebp)
  8028e8:	89 d6                	mov    %edx,%esi
  8028ea:	f7 65 e8             	mull   -0x18(%ebp)
  8028ed:	39 d6                	cmp    %edx,%esi
  8028ef:	72 2b                	jb     80291c <__umoddi3+0x11c>
  8028f1:	39 c7                	cmp    %eax,%edi
  8028f3:	72 23                	jb     802918 <__umoddi3+0x118>
  8028f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028f9:	29 c7                	sub    %eax,%edi
  8028fb:	19 d6                	sbb    %edx,%esi
  8028fd:	89 f0                	mov    %esi,%eax
  8028ff:	89 f2                	mov    %esi,%edx
  802901:	d3 ef                	shr    %cl,%edi
  802903:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802907:	d3 e0                	shl    %cl,%eax
  802909:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80290d:	09 f8                	or     %edi,%eax
  80290f:	d3 ea                	shr    %cl,%edx
  802911:	83 c4 20             	add    $0x20,%esp
  802914:	5e                   	pop    %esi
  802915:	5f                   	pop    %edi
  802916:	5d                   	pop    %ebp
  802917:	c3                   	ret    
  802918:	39 d6                	cmp    %edx,%esi
  80291a:	75 d9                	jne    8028f5 <__umoddi3+0xf5>
  80291c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80291f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802922:	eb d1                	jmp    8028f5 <__umoddi3+0xf5>
  802924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802928:	39 f2                	cmp    %esi,%edx
  80292a:	0f 82 18 ff ff ff    	jb     802848 <__umoddi3+0x48>
  802930:	e9 1d ff ff ff       	jmp    802852 <__umoddi3+0x52>
