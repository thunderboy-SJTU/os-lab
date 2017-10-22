
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 4f 01 00 00       	call   800180 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
	for (i = 0; i < n; i++)
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	85 db                	test   %ebx,%ebx
  80004b:	7e 10                	jle    80005d <sum+0x29>
		tot ^= i * s[i];
  80004d:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  800051:	0f af ca             	imul   %edx,%ecx
  800054:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800056:	83 c2 01             	add    $0x1,%edx
  800059:	39 da                	cmp    %ebx,%edx
  80005b:	75 f0                	jne    80004d <sum+0x19>
		tot ^= i * s[i];
	return tot;
}
  80005d:	5b                   	pop    %ebx
  80005e:	5e                   	pop    %esi
  80005f:	5d                   	pop    %ebp
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  80006d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  800070:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800077:	e8 d5 01 00 00       	call   800251 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  80007c:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  800083:	00 
  800084:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <sum>
  800090:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800095:	74 1a                	je     8000b1 <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800097:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009e:	00 
  80009f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a3:	c7 04 24 e0 28 80 00 	movl   $0x8028e0,(%esp)
  8000aa:	e8 a2 01 00 00       	call   800251 <cprintf>
  8000af:	eb 0c                	jmp    8000bd <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b1:	c7 04 24 8f 28 80 00 	movl   $0x80288f,(%esp)
  8000b8:	e8 94 01 00 00       	call   800251 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bd:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000cc:	e8 63 ff ff ff       	call   800034 <sum>
  8000d1:	85 c0                	test   %eax,%eax
  8000d3:	74 12                	je     8000e7 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d9:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8000e0:	e8 6c 01 00 00       	call   800251 <cprintf>
  8000e5:	eb 0c                	jmp    8000f3 <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	c7 04 24 a6 28 80 00 	movl   $0x8028a6,(%esp)
  8000ee:	e8 5e 01 00 00       	call   800251 <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f3:	c7 44 24 04 bc 28 80 	movl   $0x8028bc,0x4(%esp)
  8000fa:	00 
  8000fb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800101:	89 04 24             	mov    %eax,(%esp)
  800104:	e8 91 0a 00 00       	call   800b9a <strcat>
	for (i = 0; i < argc; i++) {
  800109:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80010d:	7e 42                	jle    800151 <umain+0xf0>
  80010f:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800114:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  80011a:	c7 44 24 04 c8 28 80 	movl   $0x8028c8,0x4(%esp)
  800121:	00 
  800122:	89 34 24             	mov    %esi,(%esp)
  800125:	e8 70 0a 00 00       	call   800b9a <strcat>
		strcat(args, argv[i]);
  80012a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800131:	89 34 24             	mov    %esi,(%esp)
  800134:	e8 61 0a 00 00       	call   800b9a <strcat>
		strcat(args, "'");
  800139:	c7 44 24 04 c9 28 80 	movl   $0x8028c9,0x4(%esp)
  800140:	00 
  800141:	89 34 24             	mov    %esi,(%esp)
  800144:	e8 51 0a 00 00       	call   800b9a <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800149:	83 c3 01             	add    $0x1,%ebx
  80014c:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  80014f:	7f c9                	jg     80011a <umain+0xb9>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	c7 04 24 cb 28 80 00 	movl   $0x8028cb,(%esp)
  800162:	e8 ea 00 00 00       	call   800251 <cprintf>

	cprintf("init: exiting\n");
  800167:	c7 04 24 cf 28 80 00 	movl   $0x8028cf,(%esp)
  80016e:	e8 de 00 00 00       	call   800251 <cprintf>
}
  800173:	81 c4 1c 01 00 00    	add    $0x11c,%esp
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    
	...

00800180 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 18             	sub    $0x18,%esp
  800186:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800189:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80018c:	8b 75 08             	mov    0x8(%ebp),%esi
  80018f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800192:	e8 00 14 00 00       	call   801597 <sys_getenvid>
  800197:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019c:	89 c2                	mov    %eax,%edx
  80019e:	c1 e2 07             	shl    $0x7,%edx
  8001a1:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8001a8:	a3 90 67 80 00       	mov    %eax,0x806790
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ad:	85 f6                	test   %esi,%esi
  8001af:	7e 07                	jle    8001b8 <libmain+0x38>
		binaryname = argv[0];
  8001b1:	8b 03                	mov    (%ebx),%eax
  8001b3:	a3 70 47 80 00       	mov    %eax,0x804770

	// call user main routine
	umain(argc, argv);
  8001b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001bc:	89 34 24             	mov    %esi,(%esp)
  8001bf:	e8 9d fe ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8001c4:	e8 0b 00 00 00       	call   8001d4 <exit>
}
  8001c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001cc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001cf:	89 ec                	mov    %ebp,%esp
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    
	...

008001d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001da:	e8 4c 19 00 00       	call   801b2b <close_all>
	sys_env_destroy(0);
  8001df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001e6:	e8 ec 13 00 00       	call   8015d7 <sys_env_destroy>
}
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    
  8001ed:	00 00                	add    %al,(%eax)
	...

008001f0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800200:	00 00 00 
	b.cnt = 0;
  800203:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800210:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800221:	89 44 24 04          	mov    %eax,0x4(%esp)
  800225:	c7 04 24 6b 02 80 00 	movl   $0x80026b,(%esp)
  80022c:	e8 cb 01 00 00       	call   8003fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800231:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	e8 63 0d 00 00       	call   800fac <sys_cputs>

	return b.cnt;
}
  800249:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800257:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 87 ff ff ff       	call   8001f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	53                   	push   %ebx
  80026f:	83 ec 14             	sub    $0x14,%esp
  800272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800275:	8b 03                	mov    (%ebx),%eax
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80027e:	83 c0 01             	add    $0x1,%eax
  800281:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800283:	3d ff 00 00 00       	cmp    $0xff,%eax
  800288:	75 19                	jne    8002a3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80028a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800291:	00 
  800292:	8d 43 08             	lea    0x8(%ebx),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	e8 0f 0d 00 00       	call   800fac <sys_cputs>
		b->idx = 0;
  80029d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    
  8002ad:	00 00                	add    %al,(%eax)
	...

008002b0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8002d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002db:	39 d1                	cmp    %edx,%ecx
  8002dd:	72 07                	jb     8002e6 <printnum_v2+0x36>
  8002df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e2:	39 d0                	cmp    %edx,%eax
  8002e4:	77 5f                	ja     800345 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8002e6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002ea:	83 eb 01             	sub    $0x1,%ebx
  8002ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002f9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800300:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800303:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800306:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80030a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800311:	00 
  800312:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80031b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031f:	e8 dc 22 00 00       	call   802600 <__udivdi3>
  800324:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800327:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80032a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80032e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	89 54 24 04          	mov    %edx,0x4(%esp)
  800339:	89 f2                	mov    %esi,%edx
  80033b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033e:	e8 6d ff ff ff       	call   8002b0 <printnum_v2>
  800343:	eb 1e                	jmp    800363 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800345:	83 ff 2d             	cmp    $0x2d,%edi
  800348:	74 19                	je     800363 <printnum_v2+0xb3>
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	90                   	nop
  800350:	7e 11                	jle    800363 <printnum_v2+0xb3>
			putch(padc, putdat);
  800352:	89 74 24 04          	mov    %esi,0x4(%esp)
  800356:	89 3c 24             	mov    %edi,(%esp)
  800359:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80035c:	83 eb 01             	sub    $0x1,%ebx
  80035f:	85 db                	test   %ebx,%ebx
  800361:	7f ef                	jg     800352 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800363:	89 74 24 04          	mov    %esi,0x4(%esp)
  800367:	8b 74 24 04          	mov    0x4(%esp),%esi
  80036b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800372:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800379:	00 
  80037a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80037d:	89 14 24             	mov    %edx,(%esp)
  800380:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800383:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800387:	e8 a4 23 00 00       	call   802730 <__umoddi3>
  80038c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800390:	0f be 80 55 29 80 00 	movsbl 0x802955(%eax),%eax
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039d:	83 c4 4c             	add    $0x4c,%esp
  8003a0:	5b                   	pop    %ebx
  8003a1:	5e                   	pop    %esi
  8003a2:	5f                   	pop    %edi
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a8:	83 fa 01             	cmp    $0x1,%edx
  8003ab:	7e 0e                	jle    8003bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b2:	89 08                	mov    %ecx,(%eax)
  8003b4:	8b 02                	mov    (%edx),%eax
  8003b6:	8b 52 04             	mov    0x4(%edx),%edx
  8003b9:	eb 22                	jmp    8003dd <getuint+0x38>
	else if (lflag)
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	74 10                	je     8003cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	eb 0e                	jmp    8003dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d4:	89 08                	mov    %ecx,(%eax)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ee:	73 0a                	jae    8003fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f3:	88 0a                	mov    %cl,(%edx)
  8003f5:	83 c2 01             	add    $0x1,%edx
  8003f8:	89 10                	mov    %edx,(%eax)
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	56                   	push   %esi
  800401:	53                   	push   %ebx
  800402:	83 ec 6c             	sub    $0x6c,%esp
  800405:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800408:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80040f:	eb 1a                	jmp    80042b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800411:	85 c0                	test   %eax,%eax
  800413:	0f 84 66 06 00 00    	je     800a7f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	ff 55 08             	call   *0x8(%ebp)
  800426:	eb 03                	jmp    80042b <vprintfmt+0x2f>
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042b:	0f b6 07             	movzbl (%edi),%eax
  80042e:	83 c7 01             	add    $0x1,%edi
  800431:	83 f8 25             	cmp    $0x25,%eax
  800434:	75 db                	jne    800411 <vprintfmt+0x15>
  800436:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80043a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800446:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80044b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800452:	be 00 00 00 00       	mov    $0x0,%esi
  800457:	eb 06                	jmp    80045f <vprintfmt+0x63>
  800459:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80045d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	0f b6 17             	movzbl (%edi),%edx
  800462:	0f b6 c2             	movzbl %dl,%eax
  800465:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800468:	8d 47 01             	lea    0x1(%edi),%eax
  80046b:	83 ea 23             	sub    $0x23,%edx
  80046e:	80 fa 55             	cmp    $0x55,%dl
  800471:	0f 87 60 05 00 00    	ja     8009d7 <vprintfmt+0x5db>
  800477:	0f b6 d2             	movzbl %dl,%edx
  80047a:	ff 24 95 40 2b 80 00 	jmp    *0x802b40(,%edx,4)
  800481:	b9 01 00 00 00       	mov    $0x1,%ecx
  800486:	eb d5                	jmp    80045d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800488:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80048b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80048e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800491:	8d 7a d0             	lea    -0x30(%edx),%edi
  800494:	83 ff 09             	cmp    $0x9,%edi
  800497:	76 08                	jbe    8004a1 <vprintfmt+0xa5>
  800499:	eb 40                	jmp    8004db <vprintfmt+0xdf>
  80049b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80049f:	eb bc                	jmp    80045d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004a4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8004a7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8004ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ae:	8d 7a d0             	lea    -0x30(%edx),%edi
  8004b1:	83 ff 09             	cmp    $0x9,%edi
  8004b4:	76 eb                	jbe    8004a1 <vprintfmt+0xa5>
  8004b6:	eb 23                	jmp    8004db <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004bb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004be:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004c1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8004c3:	eb 16                	jmp    8004db <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8004c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004c8:	c1 fa 1f             	sar    $0x1f,%edx
  8004cb:	f7 d2                	not    %edx
  8004cd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8004d0:	eb 8b                	jmp    80045d <vprintfmt+0x61>
  8004d2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004d9:	eb 82                	jmp    80045d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8004db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004df:	0f 89 78 ff ff ff    	jns    80045d <vprintfmt+0x61>
  8004e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004e8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8004eb:	e9 6d ff ff ff       	jmp    80045d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8004f3:	e9 65 ff ff ff       	jmp    80045d <vprintfmt+0x61>
  8004f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 55 0c             	mov    0xc(%ebp),%edx
  800507:	89 54 24 04          	mov    %edx,0x4(%esp)
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	ff 55 08             	call   *0x8(%ebp)
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800516:	e9 10 ff ff ff       	jmp    80042b <vprintfmt+0x2f>
  80051b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 c2                	mov    %eax,%edx
  80052b:	c1 fa 1f             	sar    $0x1f,%edx
  80052e:	31 d0                	xor    %edx,%eax
  800530:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800532:	83 f8 0f             	cmp    $0xf,%eax
  800535:	7f 0b                	jg     800542 <vprintfmt+0x146>
  800537:	8b 14 85 a0 2c 80 00 	mov    0x802ca0(,%eax,4),%edx
  80053e:	85 d2                	test   %edx,%edx
  800540:	75 26                	jne    800568 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800542:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800546:	c7 44 24 08 66 29 80 	movl   $0x802966,0x8(%esp)
  80054d:	00 
  80054e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800551:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800555:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800558:	89 1c 24             	mov    %ebx,(%esp)
  80055b:	e8 a7 05 00 00       	call   800b07 <printfmt>
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800563:	e9 c3 fe ff ff       	jmp    80042b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800568:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80056c:	c7 44 24 08 be 2d 80 	movl   $0x802dbe,0x8(%esp)
  800573:	00 
  800574:	8b 45 0c             	mov    0xc(%ebp),%eax
  800577:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057b:	8b 55 08             	mov    0x8(%ebp),%edx
  80057e:	89 14 24             	mov    %edx,(%esp)
  800581:	e8 81 05 00 00       	call   800b07 <printfmt>
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800589:	e9 9d fe ff ff       	jmp    80042b <vprintfmt+0x2f>
  80058e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800591:	89 c7                	mov    %eax,%edi
  800593:	89 d9                	mov    %ebx,%ecx
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 50 04             	lea    0x4(%eax),%edx
  8005a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a4:	8b 30                	mov    (%eax),%esi
  8005a6:	85 f6                	test   %esi,%esi
  8005a8:	75 05                	jne    8005af <vprintfmt+0x1b3>
  8005aa:	be 6f 29 80 00       	mov    $0x80296f,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8005af:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005b3:	7e 06                	jle    8005bb <vprintfmt+0x1bf>
  8005b5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8005b9:	75 10                	jne    8005cb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bb:	0f be 06             	movsbl (%esi),%eax
  8005be:	85 c0                	test   %eax,%eax
  8005c0:	0f 85 a2 00 00 00    	jne    800668 <vprintfmt+0x26c>
  8005c6:	e9 92 00 00 00       	jmp    80065d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005cf:	89 34 24             	mov    %esi,(%esp)
  8005d2:	e8 74 05 00 00       	call   800b4b <strnlen>
  8005d7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005da:	29 c2                	sub    %eax,%edx
  8005dc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005df:	85 d2                	test   %edx,%edx
  8005e1:	7e d8                	jle    8005bb <vprintfmt+0x1bf>
					putch(padc, putdat);
  8005e3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8005e7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005ea:	89 d3                	mov    %edx,%ebx
  8005ec:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ef:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8005f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005f5:	89 ce                	mov    %ecx,%esi
  8005f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fb:	89 34 24             	mov    %esi,(%esp)
  8005fe:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	83 eb 01             	sub    $0x1,%ebx
  800604:	85 db                	test   %ebx,%ebx
  800606:	7f ef                	jg     8005f7 <vprintfmt+0x1fb>
  800608:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80060b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800611:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800618:	eb a1                	jmp    8005bb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x23f>
  800620:	8d 50 e0             	lea    -0x20(%eax),%edx
  800623:	83 fa 5e             	cmp    $0x5e,%edx
  800626:	76 13                	jbe    80063b <vprintfmt+0x23f>
					putch('?', putdat);
  800628:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800636:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80063b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 ef 01             	sub    $0x1,%edi
  80064b:	0f be 06             	movsbl (%esi),%eax
  80064e:	85 c0                	test   %eax,%eax
  800650:	74 05                	je     800657 <vprintfmt+0x25b>
  800652:	83 c6 01             	add    $0x1,%esi
  800655:	eb 1a                	jmp    800671 <vprintfmt+0x275>
  800657:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80065a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800661:	7f 1f                	jg     800682 <vprintfmt+0x286>
  800663:	e9 c0 fd ff ff       	jmp    800428 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800668:	83 c6 01             	add    $0x1,%esi
  80066b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80066e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800671:	85 db                	test   %ebx,%ebx
  800673:	78 a5                	js     80061a <vprintfmt+0x21e>
  800675:	83 eb 01             	sub    $0x1,%ebx
  800678:	79 a0                	jns    80061a <vprintfmt+0x21e>
  80067a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80067d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800680:	eb db                	jmp    80065d <vprintfmt+0x261>
  800682:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800685:	8b 75 0c             	mov    0xc(%ebp),%esi
  800688:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80068b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800692:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800699:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069b:	83 eb 01             	sub    $0x1,%ebx
  80069e:	85 db                	test   %ebx,%ebx
  8006a0:	7f ec                	jg     80068e <vprintfmt+0x292>
  8006a2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006a5:	e9 81 fd ff ff       	jmp    80042b <vprintfmt+0x2f>
  8006aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ad:	83 fe 01             	cmp    $0x1,%esi
  8006b0:	7e 10                	jle    8006c2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 08             	lea    0x8(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 18                	mov    (%eax),%ebx
  8006bd:	8b 70 04             	mov    0x4(%eax),%esi
  8006c0:	eb 26                	jmp    8006e8 <vprintfmt+0x2ec>
	else if (lflag)
  8006c2:	85 f6                	test   %esi,%esi
  8006c4:	74 12                	je     8006d8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 18                	mov    (%eax),%ebx
  8006d1:	89 de                	mov    %ebx,%esi
  8006d3:	c1 fe 1f             	sar    $0x1f,%esi
  8006d6:	eb 10                	jmp    8006e8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 18                	mov    (%eax),%ebx
  8006e3:	89 de                	mov    %ebx,%esi
  8006e5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	75 1e                	jne    80070b <vprintfmt+0x30f>
                               if((long long)num > 0){
  8006ed:	85 f6                	test   %esi,%esi
  8006ef:	78 1a                	js     80070b <vprintfmt+0x30f>
  8006f1:	85 f6                	test   %esi,%esi
  8006f3:	7f 05                	jg     8006fa <vprintfmt+0x2fe>
  8006f5:	83 fb 00             	cmp    $0x0,%ebx
  8006f8:	76 11                	jbe    80070b <vprintfmt+0x30f>
                                   putch('+',putdat);
  8006fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006fd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800701:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800708:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80070b:	85 f6                	test   %esi,%esi
  80070d:	78 13                	js     800722 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800712:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800718:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071d:	e9 da 00 00 00       	jmp    8007fc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800733:	89 da                	mov    %ebx,%edx
  800735:	89 f1                	mov    %esi,%ecx
  800737:	f7 da                	neg    %edx
  800739:	83 d1 00             	adc    $0x0,%ecx
  80073c:	f7 d9                	neg    %ecx
  80073e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800741:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800747:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074c:	e9 ab 00 00 00       	jmp    8007fc <vprintfmt+0x400>
  800751:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800754:	89 f2                	mov    %esi,%edx
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 47 fc ff ff       	call   8003a5 <getuint>
  80075e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800761:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800764:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800767:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80076c:	e9 8b 00 00 00       	jmp    8007fc <vprintfmt+0x400>
  800771:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800777:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800782:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800785:	89 f2                	mov    %esi,%edx
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
  80078a:	e8 16 fc ff ff       	call   8003a5 <getuint>
  80078f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800792:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800795:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800798:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80079d:	eb 5d                	jmp    8007fc <vprintfmt+0x400>
  80079f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007be:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 50 04             	lea    0x4(%eax),%edx
  8007c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ca:	8b 10                	mov    (%eax),%edx
  8007cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8007d4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007da:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007df:	eb 1b                	jmp    8007fc <vprintfmt+0x400>
  8007e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 b7 fb ff ff       	call   8003a5 <getuint>
  8007ee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8007f1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8007f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800800:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800803:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800806:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80080a:	77 09                	ja     800815 <vprintfmt+0x419>
  80080c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80080f:	0f 82 ac 00 00 00    	jb     8008c1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800815:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800818:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80081c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80081f:	83 ea 01             	sub    $0x1,%edx
  800822:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800826:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80082e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800832:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800835:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800838:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80083b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80083f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800846:	00 
  800847:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80084a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80084d:	89 0c 24             	mov    %ecx,(%esp)
  800850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800854:	e8 a7 1d 00 00       	call   802600 <__udivdi3>
  800859:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80085c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80085f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800863:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	e8 37 fa ff ff       	call   8002b0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80087c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800880:	8b 74 24 04          	mov    0x4(%esp),%esi
  800884:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800887:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800892:	00 
  800893:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800896:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800899:	89 14 24             	mov    %edx,(%esp)
  80089c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a0:	e8 8b 1e 00 00       	call   802730 <__umoddi3>
  8008a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a9:	0f be 80 55 29 80 00 	movsbl 0x802955(%eax),%eax
  8008b0:	89 04 24             	mov    %eax,(%esp)
  8008b3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8008b6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008ba:	74 54                	je     800910 <vprintfmt+0x514>
  8008bc:	e9 67 fb ff ff       	jmp    800428 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8008c1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8008c5:	8d 76 00             	lea    0x0(%esi),%esi
  8008c8:	0f 84 2a 01 00 00    	je     8009f8 <vprintfmt+0x5fc>
		while (--width > 0)
  8008ce:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008d1:	83 ef 01             	sub    $0x1,%edi
  8008d4:	85 ff                	test   %edi,%edi
  8008d6:	0f 8e 5e 01 00 00    	jle    800a3a <vprintfmt+0x63e>
  8008dc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8008df:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8008e2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8008e5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8008e8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008eb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8008ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8008f8:	83 ef 01             	sub    $0x1,%edi
  8008fb:	85 ff                	test   %edi,%edi
  8008fd:	7f ef                	jg     8008ee <vprintfmt+0x4f2>
  8008ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800902:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800905:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800908:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80090b:	e9 2a 01 00 00       	jmp    800a3a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800910:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800913:	83 eb 01             	sub    $0x1,%ebx
  800916:	85 db                	test   %ebx,%ebx
  800918:	0f 8e 0a fb ff ff    	jle    800428 <vprintfmt+0x2c>
  80091e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800921:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800924:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800927:	89 74 24 04          	mov    %esi,0x4(%esp)
  80092b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800932:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800934:	83 eb 01             	sub    $0x1,%ebx
  800937:	85 db                	test   %ebx,%ebx
  800939:	7f ec                	jg     800927 <vprintfmt+0x52b>
  80093b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80093e:	e9 e8 fa ff ff       	jmp    80042b <vprintfmt+0x2f>
  800943:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8d 50 04             	lea    0x4(%eax),%edx
  80094c:	89 55 14             	mov    %edx,0x14(%ebp)
  80094f:	8b 00                	mov    (%eax),%eax
  800951:	85 c0                	test   %eax,%eax
  800953:	75 2a                	jne    80097f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800955:	c7 44 24 0c 88 2a 80 	movl   $0x802a88,0xc(%esp)
  80095c:	00 
  80095d:	c7 44 24 08 be 2d 80 	movl   $0x802dbe,0x8(%esp)
  800964:	00 
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
  800968:	89 54 24 04          	mov    %edx,0x4(%esp)
  80096c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096f:	89 0c 24             	mov    %ecx,(%esp)
  800972:	e8 90 01 00 00       	call   800b07 <printfmt>
  800977:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80097a:	e9 ac fa ff ff       	jmp    80042b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80097f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800982:	8b 13                	mov    (%ebx),%edx
  800984:	83 fa 7f             	cmp    $0x7f,%edx
  800987:	7e 29                	jle    8009b2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800989:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80098b:	c7 44 24 0c c0 2a 80 	movl   $0x802ac0,0xc(%esp)
  800992:	00 
  800993:	c7 44 24 08 be 2d 80 	movl   $0x802dbe,0x8(%esp)
  80099a:	00 
  80099b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	89 04 24             	mov    %eax,(%esp)
  8009a5:	e8 5d 01 00 00       	call   800b07 <printfmt>
  8009aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ad:	e9 79 fa ff ff       	jmp    80042b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8009b2:	88 10                	mov    %dl,(%eax)
  8009b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009b7:	e9 6f fa ff ff       	jmp    80042b <vprintfmt+0x2f>
  8009bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009c9:	89 14 24             	mov    %edx,(%esp)
  8009cc:	ff 55 08             	call   *0x8(%ebp)
  8009cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8009d2:	e9 54 fa ff ff       	jmp    80042b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8009eb:	80 38 25             	cmpb   $0x25,(%eax)
  8009ee:	0f 84 37 fa ff ff    	je     80042b <vprintfmt+0x2f>
  8009f4:	89 c7                	mov    %eax,%edi
  8009f6:	eb f0                	jmp    8009e8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a03:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800a06:	89 54 24 08          	mov    %edx,0x8(%esp)
  800a0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a11:	00 
  800a12:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a15:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a1f:	e8 0c 1d 00 00       	call   802730 <__umoddi3>
  800a24:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a28:	0f be 80 55 29 80 00 	movsbl 0x802955(%eax),%eax
  800a2f:	89 04 24             	mov    %eax,(%esp)
  800a32:	ff 55 08             	call   *0x8(%ebp)
  800a35:	e9 d6 fe ff ff       	jmp    800910 <vprintfmt+0x514>
  800a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a41:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a45:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800a4c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a53:	00 
  800a54:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800a57:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800a5a:	89 04 24             	mov    %eax,(%esp)
  800a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a61:	e8 ca 1c 00 00       	call   802730 <__umoddi3>
  800a66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6a:	0f be 80 55 29 80 00 	movsbl 0x802955(%eax),%eax
  800a71:	89 04 24             	mov    %eax,(%esp)
  800a74:	ff 55 08             	call   *0x8(%ebp)
  800a77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7a:	e9 ac f9 ff ff       	jmp    80042b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a7f:	83 c4 6c             	add    $0x6c,%esp
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	83 ec 28             	sub    $0x28,%esp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a93:	85 c0                	test   %eax,%eax
  800a95:	74 04                	je     800a9b <vsnprintf+0x14>
  800a97:	85 d2                	test   %edx,%edx
  800a99:	7f 07                	jg     800aa2 <vsnprintf+0x1b>
  800a9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aa0:	eb 3b                	jmp    800add <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aa5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ab3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aba:	8b 45 10             	mov    0x10(%ebp),%eax
  800abd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac8:	c7 04 24 df 03 80 00 	movl   $0x8003df,(%esp)
  800acf:	e8 28 f9 ff ff       	call   8003fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800add:	c9                   	leave  
  800ade:	c3                   	ret    

00800adf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800ae5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800ae8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
  800aef:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	89 04 24             	mov    %eax,(%esp)
  800b00:	e8 82 ff ff ff       	call   800a87 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b0d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b14:	8b 45 10             	mov    0x10(%ebp),%eax
  800b17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	89 04 24             	mov    %eax,(%esp)
  800b28:	e8 cf f8 ff ff       	call   8003fc <vprintfmt>
	va_end(ap);
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    
	...

00800b30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b3e:	74 09                	je     800b49 <strlen+0x19>
		n++;
  800b40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b47:	75 f7                	jne    800b40 <strlen+0x10>
		n++;
	return n;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	53                   	push   %ebx
  800b4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b55:	85 c9                	test   %ecx,%ecx
  800b57:	74 19                	je     800b72 <strnlen+0x27>
  800b59:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b5c:	74 14                	je     800b72 <strnlen+0x27>
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b63:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b66:	39 c8                	cmp    %ecx,%eax
  800b68:	74 0d                	je     800b77 <strnlen+0x2c>
  800b6a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b6e:	75 f3                	jne    800b63 <strnlen+0x18>
  800b70:	eb 05                	jmp    800b77 <strnlen+0x2c>
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b77:	5b                   	pop    %ebx
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b8d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	84 c9                	test   %cl,%cl
  800b95:	75 f2                	jne    800b89 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b97:	5b                   	pop    %ebx
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 08             	sub    $0x8,%esp
  800ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ba4:	89 1c 24             	mov    %ebx,(%esp)
  800ba7:	e8 84 ff ff ff       	call   800b30 <strlen>
	strcpy(dst + len, src);
  800bac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800baf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bb3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bb6:	89 04 24             	mov    %eax,(%esp)
  800bb9:	e8 bc ff ff ff       	call   800b7a <strcpy>
	return dst;
}
  800bbe:	89 d8                	mov    %ebx,%eax
  800bc0:	83 c4 08             	add    $0x8,%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd4:	85 f6                	test   %esi,%esi
  800bd6:	74 18                	je     800bf0 <strncpy+0x2a>
  800bd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800bdd:	0f b6 1a             	movzbl (%edx),%ebx
  800be0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be3:	80 3a 01             	cmpb   $0x1,(%edx)
  800be6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be9:	83 c1 01             	add    $0x1,%ecx
  800bec:	39 ce                	cmp    %ecx,%esi
  800bee:	77 ed                	ja     800bdd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c02:	89 f0                	mov    %esi,%eax
  800c04:	85 c9                	test   %ecx,%ecx
  800c06:	74 27                	je     800c2f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c08:	83 e9 01             	sub    $0x1,%ecx
  800c0b:	74 1d                	je     800c2a <strlcpy+0x36>
  800c0d:	0f b6 1a             	movzbl (%edx),%ebx
  800c10:	84 db                	test   %bl,%bl
  800c12:	74 16                	je     800c2a <strlcpy+0x36>
			*dst++ = *src++;
  800c14:	88 18                	mov    %bl,(%eax)
  800c16:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c19:	83 e9 01             	sub    $0x1,%ecx
  800c1c:	74 0e                	je     800c2c <strlcpy+0x38>
			*dst++ = *src++;
  800c1e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c21:	0f b6 1a             	movzbl (%edx),%ebx
  800c24:	84 db                	test   %bl,%bl
  800c26:	75 ec                	jne    800c14 <strlcpy+0x20>
  800c28:	eb 02                	jmp    800c2c <strlcpy+0x38>
  800c2a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c2c:	c6 00 00             	movb   $0x0,(%eax)
  800c2f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c3e:	0f b6 01             	movzbl (%ecx),%eax
  800c41:	84 c0                	test   %al,%al
  800c43:	74 15                	je     800c5a <strcmp+0x25>
  800c45:	3a 02                	cmp    (%edx),%al
  800c47:	75 11                	jne    800c5a <strcmp+0x25>
		p++, q++;
  800c49:	83 c1 01             	add    $0x1,%ecx
  800c4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c4f:	0f b6 01             	movzbl (%ecx),%eax
  800c52:	84 c0                	test   %al,%al
  800c54:	74 04                	je     800c5a <strcmp+0x25>
  800c56:	3a 02                	cmp    (%edx),%al
  800c58:	74 ef                	je     800c49 <strcmp+0x14>
  800c5a:	0f b6 c0             	movzbl %al,%eax
  800c5d:	0f b6 12             	movzbl (%edx),%edx
  800c60:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	53                   	push   %ebx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	74 23                	je     800c98 <strncmp+0x34>
  800c75:	0f b6 1a             	movzbl (%edx),%ebx
  800c78:	84 db                	test   %bl,%bl
  800c7a:	74 25                	je     800ca1 <strncmp+0x3d>
  800c7c:	3a 19                	cmp    (%ecx),%bl
  800c7e:	75 21                	jne    800ca1 <strncmp+0x3d>
  800c80:	83 e8 01             	sub    $0x1,%eax
  800c83:	74 13                	je     800c98 <strncmp+0x34>
		n--, p++, q++;
  800c85:	83 c2 01             	add    $0x1,%edx
  800c88:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c8b:	0f b6 1a             	movzbl (%edx),%ebx
  800c8e:	84 db                	test   %bl,%bl
  800c90:	74 0f                	je     800ca1 <strncmp+0x3d>
  800c92:	3a 19                	cmp    (%ecx),%bl
  800c94:	74 ea                	je     800c80 <strncmp+0x1c>
  800c96:	eb 09                	jmp    800ca1 <strncmp+0x3d>
  800c98:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5d                   	pop    %ebp
  800c9f:	90                   	nop
  800ca0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca1:	0f b6 02             	movzbl (%edx),%eax
  800ca4:	0f b6 11             	movzbl (%ecx),%edx
  800ca7:	29 d0                	sub    %edx,%eax
  800ca9:	eb f2                	jmp    800c9d <strncmp+0x39>

00800cab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb5:	0f b6 10             	movzbl (%eax),%edx
  800cb8:	84 d2                	test   %dl,%dl
  800cba:	74 18                	je     800cd4 <strchr+0x29>
		if (*s == c)
  800cbc:	38 ca                	cmp    %cl,%dl
  800cbe:	75 0a                	jne    800cca <strchr+0x1f>
  800cc0:	eb 17                	jmp    800cd9 <strchr+0x2e>
  800cc2:	38 ca                	cmp    %cl,%dl
  800cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc8:	74 0f                	je     800cd9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cca:	83 c0 01             	add    $0x1,%eax
  800ccd:	0f b6 10             	movzbl (%eax),%edx
  800cd0:	84 d2                	test   %dl,%dl
  800cd2:	75 ee                	jne    800cc2 <strchr+0x17>
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce5:	0f b6 10             	movzbl (%eax),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	74 18                	je     800d04 <strfind+0x29>
		if (*s == c)
  800cec:	38 ca                	cmp    %cl,%dl
  800cee:	75 0a                	jne    800cfa <strfind+0x1f>
  800cf0:	eb 12                	jmp    800d04 <strfind+0x29>
  800cf2:	38 ca                	cmp    %cl,%dl
  800cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf8:	74 0a                	je     800d04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	0f b6 10             	movzbl (%eax),%edx
  800d00:	84 d2                	test   %dl,%dl
  800d02:	75 ee                	jne    800cf2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	89 1c 24             	mov    %ebx,(%esp)
  800d0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d20:	85 c9                	test   %ecx,%ecx
  800d22:	74 30                	je     800d54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d2a:	75 25                	jne    800d51 <memset+0x4b>
  800d2c:	f6 c1 03             	test   $0x3,%cl
  800d2f:	75 20                	jne    800d51 <memset+0x4b>
		c &= 0xFF;
  800d31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	c1 e3 08             	shl    $0x8,%ebx
  800d39:	89 d6                	mov    %edx,%esi
  800d3b:	c1 e6 18             	shl    $0x18,%esi
  800d3e:	89 d0                	mov    %edx,%eax
  800d40:	c1 e0 10             	shl    $0x10,%eax
  800d43:	09 f0                	or     %esi,%eax
  800d45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d47:	09 d8                	or     %ebx,%eax
  800d49:	c1 e9 02             	shr    $0x2,%ecx
  800d4c:	fc                   	cld    
  800d4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d4f:	eb 03                	jmp    800d54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d51:	fc                   	cld    
  800d52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d54:	89 f8                	mov    %edi,%eax
  800d56:	8b 1c 24             	mov    (%esp),%ebx
  800d59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d61:	89 ec                	mov    %ebp,%esp
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
  800d6b:	89 34 24             	mov    %esi,(%esp)
  800d6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d7d:	39 c6                	cmp    %eax,%esi
  800d7f:	73 35                	jae    800db6 <memmove+0x51>
  800d81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d84:	39 d0                	cmp    %edx,%eax
  800d86:	73 2e                	jae    800db6 <memmove+0x51>
		s += n;
		d += n;
  800d88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d8a:	f6 c2 03             	test   $0x3,%dl
  800d8d:	75 1b                	jne    800daa <memmove+0x45>
  800d8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d95:	75 13                	jne    800daa <memmove+0x45>
  800d97:	f6 c1 03             	test   $0x3,%cl
  800d9a:	75 0e                	jne    800daa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d9c:	83 ef 04             	sub    $0x4,%edi
  800d9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800da2:	c1 e9 02             	shr    $0x2,%ecx
  800da5:	fd                   	std    
  800da6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da8:	eb 09                	jmp    800db3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800daa:	83 ef 01             	sub    $0x1,%edi
  800dad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800db0:	fd                   	std    
  800db1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800db3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800db4:	eb 20                	jmp    800dd6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800db6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dbc:	75 15                	jne    800dd3 <memmove+0x6e>
  800dbe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc4:	75 0d                	jne    800dd3 <memmove+0x6e>
  800dc6:	f6 c1 03             	test   $0x3,%cl
  800dc9:	75 08                	jne    800dd3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800dcb:	c1 e9 02             	shr    $0x2,%ecx
  800dce:	fc                   	cld    
  800dcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd1:	eb 03                	jmp    800dd6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dd3:	fc                   	cld    
  800dd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dd6:	8b 34 24             	mov    (%esp),%esi
  800dd9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ddd:	89 ec                	mov    %ebp,%esp
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800de7:	8b 45 10             	mov    0x10(%ebp),%eax
  800dea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	89 04 24             	mov    %eax,(%esp)
  800dfb:	e8 65 ff ff ff       	call   800d65 <memmove>
}
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	8b 75 08             	mov    0x8(%ebp),%esi
  800e0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e11:	85 c9                	test   %ecx,%ecx
  800e13:	74 36                	je     800e4b <memcmp+0x49>
		if (*s1 != *s2)
  800e15:	0f b6 06             	movzbl (%esi),%eax
  800e18:	0f b6 1f             	movzbl (%edi),%ebx
  800e1b:	38 d8                	cmp    %bl,%al
  800e1d:	74 20                	je     800e3f <memcmp+0x3d>
  800e1f:	eb 14                	jmp    800e35 <memcmp+0x33>
  800e21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e2b:	83 c2 01             	add    $0x1,%edx
  800e2e:	83 e9 01             	sub    $0x1,%ecx
  800e31:	38 d8                	cmp    %bl,%al
  800e33:	74 12                	je     800e47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e35:	0f b6 c0             	movzbl %al,%eax
  800e38:	0f b6 db             	movzbl %bl,%ebx
  800e3b:	29 d8                	sub    %ebx,%eax
  800e3d:	eb 11                	jmp    800e50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e3f:	83 e9 01             	sub    $0x1,%ecx
  800e42:	ba 00 00 00 00       	mov    $0x0,%edx
  800e47:	85 c9                	test   %ecx,%ecx
  800e49:	75 d6                	jne    800e21 <memcmp+0x1f>
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e5b:	89 c2                	mov    %eax,%edx
  800e5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e60:	39 d0                	cmp    %edx,%eax
  800e62:	73 15                	jae    800e79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e68:	38 08                	cmp    %cl,(%eax)
  800e6a:	75 06                	jne    800e72 <memfind+0x1d>
  800e6c:	eb 0b                	jmp    800e79 <memfind+0x24>
  800e6e:	38 08                	cmp    %cl,(%eax)
  800e70:	74 07                	je     800e79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e72:	83 c0 01             	add    $0x1,%eax
  800e75:	39 c2                	cmp    %eax,%edx
  800e77:	77 f5                	ja     800e6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e8a:	0f b6 02             	movzbl (%edx),%eax
  800e8d:	3c 20                	cmp    $0x20,%al
  800e8f:	74 04                	je     800e95 <strtol+0x1a>
  800e91:	3c 09                	cmp    $0x9,%al
  800e93:	75 0e                	jne    800ea3 <strtol+0x28>
		s++;
  800e95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e98:	0f b6 02             	movzbl (%edx),%eax
  800e9b:	3c 20                	cmp    $0x20,%al
  800e9d:	74 f6                	je     800e95 <strtol+0x1a>
  800e9f:	3c 09                	cmp    $0x9,%al
  800ea1:	74 f2                	je     800e95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ea3:	3c 2b                	cmp    $0x2b,%al
  800ea5:	75 0c                	jne    800eb3 <strtol+0x38>
		s++;
  800ea7:	83 c2 01             	add    $0x1,%edx
  800eaa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eb1:	eb 15                	jmp    800ec8 <strtol+0x4d>
	else if (*s == '-')
  800eb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800eba:	3c 2d                	cmp    $0x2d,%al
  800ebc:	75 0a                	jne    800ec8 <strtol+0x4d>
		s++, neg = 1;
  800ebe:	83 c2 01             	add    $0x1,%edx
  800ec1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ec8:	85 db                	test   %ebx,%ebx
  800eca:	0f 94 c0             	sete   %al
  800ecd:	74 05                	je     800ed4 <strtol+0x59>
  800ecf:	83 fb 10             	cmp    $0x10,%ebx
  800ed2:	75 18                	jne    800eec <strtol+0x71>
  800ed4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ed7:	75 13                	jne    800eec <strtol+0x71>
  800ed9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800edd:	8d 76 00             	lea    0x0(%esi),%esi
  800ee0:	75 0a                	jne    800eec <strtol+0x71>
		s += 2, base = 16;
  800ee2:	83 c2 02             	add    $0x2,%edx
  800ee5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eea:	eb 15                	jmp    800f01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eec:	84 c0                	test   %al,%al
  800eee:	66 90                	xchg   %ax,%ax
  800ef0:	74 0f                	je     800f01 <strtol+0x86>
  800ef2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ef7:	80 3a 30             	cmpb   $0x30,(%edx)
  800efa:	75 05                	jne    800f01 <strtol+0x86>
		s++, base = 8;
  800efc:	83 c2 01             	add    $0x1,%edx
  800eff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f08:	0f b6 0a             	movzbl (%edx),%ecx
  800f0b:	89 cf                	mov    %ecx,%edi
  800f0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f10:	80 fb 09             	cmp    $0x9,%bl
  800f13:	77 08                	ja     800f1d <strtol+0xa2>
			dig = *s - '0';
  800f15:	0f be c9             	movsbl %cl,%ecx
  800f18:	83 e9 30             	sub    $0x30,%ecx
  800f1b:	eb 1e                	jmp    800f3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f20:	80 fb 19             	cmp    $0x19,%bl
  800f23:	77 08                	ja     800f2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f25:	0f be c9             	movsbl %cl,%ecx
  800f28:	83 e9 57             	sub    $0x57,%ecx
  800f2b:	eb 0e                	jmp    800f3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f30:	80 fb 19             	cmp    $0x19,%bl
  800f33:	77 15                	ja     800f4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f35:	0f be c9             	movsbl %cl,%ecx
  800f38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f3b:	39 f1                	cmp    %esi,%ecx
  800f3d:	7d 0b                	jge    800f4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f3f:	83 c2 01             	add    $0x1,%edx
  800f42:	0f af c6             	imul   %esi,%eax
  800f45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f48:	eb be                	jmp    800f08 <strtol+0x8d>
  800f4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f50:	74 05                	je     800f57 <strtol+0xdc>
		*endptr = (char *) s;
  800f52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f5b:	74 04                	je     800f61 <strtol+0xe6>
  800f5d:	89 c8                	mov    %ecx,%eax
  800f5f:	f7 d8                	neg    %eax
}
  800f61:	83 c4 04             	add    $0x4,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	00 00                	add    %al,(%eax)
	...

00800f6c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
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
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f83:	89 d1                	mov    %edx,%ecx
  800f85:	89 d3                	mov    %edx,%ebx
  800f87:	89 d7                	mov    %edx,%edi
  800f89:	51                   	push   %ecx
  800f8a:	52                   	push   %edx
  800f8b:	53                   	push   %ebx
  800f8c:	54                   	push   %esp
  800f8d:	55                   	push   %ebp
  800f8e:	56                   	push   %esi
  800f8f:	57                   	push   %edi
  800f90:	54                   	push   %esp
  800f91:	5d                   	pop    %ebp
  800f92:	8d 35 9a 0f 80 00    	lea    0x800f9a,%esi
  800f98:	0f 34                	sysenter 
  800f9a:	5f                   	pop    %edi
  800f9b:	5e                   	pop    %esi
  800f9c:	5d                   	pop    %ebp
  800f9d:	5c                   	pop    %esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5a                   	pop    %edx
  800fa0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fa1:	8b 1c 24             	mov    (%esp),%ebx
  800fa4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fa8:	89 ec                	mov    %ebp,%esp
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	89 1c 24             	mov    %ebx,(%esp)
  800fb5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	89 c3                	mov    %eax,%ebx
  800fc6:	89 c7                	mov    %eax,%edi
  800fc8:	51                   	push   %ecx
  800fc9:	52                   	push   %edx
  800fca:	53                   	push   %ebx
  800fcb:	54                   	push   %esp
  800fcc:	55                   	push   %ebp
  800fcd:	56                   	push   %esi
  800fce:	57                   	push   %edi
  800fcf:	54                   	push   %esp
  800fd0:	5d                   	pop    %ebp
  800fd1:	8d 35 d9 0f 80 00    	lea    0x800fd9,%esi
  800fd7:	0f 34                	sysenter 
  800fd9:	5f                   	pop    %edi
  800fda:	5e                   	pop    %esi
  800fdb:	5d                   	pop    %ebp
  800fdc:	5c                   	pop    %esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5a                   	pop    %edx
  800fdf:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fe0:	8b 1c 24             	mov    (%esp),%ebx
  800fe3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe7:	89 ec                	mov    %ebp,%esp
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    

00800feb <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	89 1c 24             	mov    %ebx,(%esp)
  800ff4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffd:	b8 13 00 00 00       	mov    $0x13,%eax
  801002:	8b 55 08             	mov    0x8(%ebp),%edx
  801005:	89 cb                	mov    %ecx,%ebx
  801007:	89 cf                	mov    %ecx,%edi
  801009:	51                   	push   %ecx
  80100a:	52                   	push   %edx
  80100b:	53                   	push   %ebx
  80100c:	54                   	push   %esp
  80100d:	55                   	push   %ebp
  80100e:	56                   	push   %esi
  80100f:	57                   	push   %edi
  801010:	54                   	push   %esp
  801011:	5d                   	pop    %ebp
  801012:	8d 35 1a 10 80 00    	lea    0x80101a,%esi
  801018:	0f 34                	sysenter 
  80101a:	5f                   	pop    %edi
  80101b:	5e                   	pop    %esi
  80101c:	5d                   	pop    %ebp
  80101d:	5c                   	pop    %esp
  80101e:	5b                   	pop    %ebx
  80101f:	5a                   	pop    %edx
  801020:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801021:	8b 1c 24             	mov    (%esp),%ebx
  801024:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801028:	89 ec                	mov    %ebp,%esp
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	89 1c 24             	mov    %ebx,(%esp)
  801035:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801039:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103e:	b8 12 00 00 00       	mov    $0x12,%eax
  801043:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801046:	8b 55 08             	mov    0x8(%ebp),%edx
  801049:	89 df                	mov    %ebx,%edi
  80104b:	51                   	push   %ecx
  80104c:	52                   	push   %edx
  80104d:	53                   	push   %ebx
  80104e:	54                   	push   %esp
  80104f:	55                   	push   %ebp
  801050:	56                   	push   %esi
  801051:	57                   	push   %edi
  801052:	54                   	push   %esp
  801053:	5d                   	pop    %ebp
  801054:	8d 35 5c 10 80 00    	lea    0x80105c,%esi
  80105a:	0f 34                	sysenter 
  80105c:	5f                   	pop    %edi
  80105d:	5e                   	pop    %esi
  80105e:	5d                   	pop    %ebp
  80105f:	5c                   	pop    %esp
  801060:	5b                   	pop    %ebx
  801061:	5a                   	pop    %edx
  801062:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801063:	8b 1c 24             	mov    (%esp),%ebx
  801066:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80106a:	89 ec                	mov    %ebp,%esp
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	83 ec 08             	sub    $0x8,%esp
  801074:	89 1c 24             	mov    %ebx,(%esp)
  801077:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80107b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801080:	b8 11 00 00 00       	mov    $0x11,%eax
  801085:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801088:	8b 55 08             	mov    0x8(%ebp),%edx
  80108b:	89 df                	mov    %ebx,%edi
  80108d:	51                   	push   %ecx
  80108e:	52                   	push   %edx
  80108f:	53                   	push   %ebx
  801090:	54                   	push   %esp
  801091:	55                   	push   %ebp
  801092:	56                   	push   %esi
  801093:	57                   	push   %edi
  801094:	54                   	push   %esp
  801095:	5d                   	pop    %ebp
  801096:	8d 35 9e 10 80 00    	lea    0x80109e,%esi
  80109c:	0f 34                	sysenter 
  80109e:	5f                   	pop    %edi
  80109f:	5e                   	pop    %esi
  8010a0:	5d                   	pop    %ebp
  8010a1:	5c                   	pop    %esp
  8010a2:	5b                   	pop    %ebx
  8010a3:	5a                   	pop    %edx
  8010a4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8010a5:	8b 1c 24             	mov    (%esp),%ebx
  8010a8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010ac:	89 ec                	mov    %ebp,%esp
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 08             	sub    $0x8,%esp
  8010b6:	89 1c 24             	mov    %ebx,(%esp)
  8010b9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010bd:	b8 10 00 00 00       	mov    $0x10,%eax
  8010c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ce:	51                   	push   %ecx
  8010cf:	52                   	push   %edx
  8010d0:	53                   	push   %ebx
  8010d1:	54                   	push   %esp
  8010d2:	55                   	push   %ebp
  8010d3:	56                   	push   %esi
  8010d4:	57                   	push   %edi
  8010d5:	54                   	push   %esp
  8010d6:	5d                   	pop    %ebp
  8010d7:	8d 35 df 10 80 00    	lea    0x8010df,%esi
  8010dd:	0f 34                	sysenter 
  8010df:	5f                   	pop    %edi
  8010e0:	5e                   	pop    %esi
  8010e1:	5d                   	pop    %ebp
  8010e2:	5c                   	pop    %esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5a                   	pop    %edx
  8010e5:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  8010e6:	8b 1c 24             	mov    (%esp),%ebx
  8010e9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010ed:	89 ec                	mov    %ebp,%esp
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	83 ec 28             	sub    $0x28,%esp
  8010f7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010fa:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801102:	b8 0f 00 00 00       	mov    $0xf,%eax
  801107:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110a:	8b 55 08             	mov    0x8(%ebp),%edx
  80110d:	89 df                	mov    %ebx,%edi
  80110f:	51                   	push   %ecx
  801110:	52                   	push   %edx
  801111:	53                   	push   %ebx
  801112:	54                   	push   %esp
  801113:	55                   	push   %ebp
  801114:	56                   	push   %esi
  801115:	57                   	push   %edi
  801116:	54                   	push   %esp
  801117:	5d                   	pop    %ebp
  801118:	8d 35 20 11 80 00    	lea    0x801120,%esi
  80111e:	0f 34                	sysenter 
  801120:	5f                   	pop    %edi
  801121:	5e                   	pop    %esi
  801122:	5d                   	pop    %ebp
  801123:	5c                   	pop    %esp
  801124:	5b                   	pop    %ebx
  801125:	5a                   	pop    %edx
  801126:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801127:	85 c0                	test   %eax,%eax
  801129:	7e 28                	jle    801153 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801136:	00 
  801137:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  80113e:	00 
  80113f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801146:	00 
  801147:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  80114e:	e8 d1 12 00 00       	call   802424 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801153:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801156:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801159:	89 ec                	mov    %ebp,%esp
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
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
  80116a:	ba 00 00 00 00       	mov    $0x0,%edx
  80116f:	b8 15 00 00 00       	mov    $0x15,%eax
  801174:	89 d1                	mov    %edx,%ecx
  801176:	89 d3                	mov    %edx,%ebx
  801178:	89 d7                	mov    %edx,%edi
  80117a:	51                   	push   %ecx
  80117b:	52                   	push   %edx
  80117c:	53                   	push   %ebx
  80117d:	54                   	push   %esp
  80117e:	55                   	push   %ebp
  80117f:	56                   	push   %esi
  801180:	57                   	push   %edi
  801181:	54                   	push   %esp
  801182:	5d                   	pop    %ebp
  801183:	8d 35 8b 11 80 00    	lea    0x80118b,%esi
  801189:	0f 34                	sysenter 
  80118b:	5f                   	pop    %edi
  80118c:	5e                   	pop    %esi
  80118d:	5d                   	pop    %ebp
  80118e:	5c                   	pop    %esp
  80118f:	5b                   	pop    %ebx
  801190:	5a                   	pop    %edx
  801191:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801192:	8b 1c 24             	mov    (%esp),%ebx
  801195:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801199:	89 ec                	mov    %ebp,%esp
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	89 1c 24             	mov    %ebx,(%esp)
  8011a6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011af:	b8 14 00 00 00       	mov    $0x14,%eax
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011d3:	8b 1c 24             	mov    (%esp),%ebx
  8011d6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011da:	89 ec                	mov    %ebp,%esp
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	83 ec 28             	sub    $0x28,%esp
  8011e4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011e7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ef:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f7:	89 cb                	mov    %ecx,%ebx
  8011f9:	89 cf                	mov    %ecx,%edi
  8011fb:	51                   	push   %ecx
  8011fc:	52                   	push   %edx
  8011fd:	53                   	push   %ebx
  8011fe:	54                   	push   %esp
  8011ff:	55                   	push   %ebp
  801200:	56                   	push   %esi
  801201:	57                   	push   %edi
  801202:	54                   	push   %esp
  801203:	5d                   	pop    %ebp
  801204:	8d 35 0c 12 80 00    	lea    0x80120c,%esi
  80120a:	0f 34                	sysenter 
  80120c:	5f                   	pop    %edi
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	5c                   	pop    %esp
  801210:	5b                   	pop    %ebx
  801211:	5a                   	pop    %edx
  801212:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801213:	85 c0                	test   %eax,%eax
  801215:	7e 28                	jle    80123f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801217:	89 44 24 10          	mov    %eax,0x10(%esp)
  80121b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801222:	00 
  801223:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  80122a:	00 
  80122b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801232:	00 
  801233:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  80123a:	e8 e5 11 00 00       	call   802424 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80123f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801242:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801245:	89 ec                	mov    %ebp,%esp
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	89 1c 24             	mov    %ebx,(%esp)
  801252:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801256:	b8 0d 00 00 00       	mov    $0xd,%eax
  80125b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80125e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801264:	8b 55 08             	mov    0x8(%ebp),%edx
  801267:	51                   	push   %ecx
  801268:	52                   	push   %edx
  801269:	53                   	push   %ebx
  80126a:	54                   	push   %esp
  80126b:	55                   	push   %ebp
  80126c:	56                   	push   %esi
  80126d:	57                   	push   %edi
  80126e:	54                   	push   %esp
  80126f:	5d                   	pop    %ebp
  801270:	8d 35 78 12 80 00    	lea    0x801278,%esi
  801276:	0f 34                	sysenter 
  801278:	5f                   	pop    %edi
  801279:	5e                   	pop    %esi
  80127a:	5d                   	pop    %ebp
  80127b:	5c                   	pop    %esp
  80127c:	5b                   	pop    %ebx
  80127d:	5a                   	pop    %edx
  80127e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80127f:	8b 1c 24             	mov    (%esp),%ebx
  801282:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801286:	89 ec                	mov    %ebp,%esp
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 28             	sub    $0x28,%esp
  801290:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801293:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801296:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129b:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a6:	89 df                	mov    %ebx,%edi
  8012a8:	51                   	push   %ecx
  8012a9:	52                   	push   %edx
  8012aa:	53                   	push   %ebx
  8012ab:	54                   	push   %esp
  8012ac:	55                   	push   %ebp
  8012ad:	56                   	push   %esi
  8012ae:	57                   	push   %edi
  8012af:	54                   	push   %esp
  8012b0:	5d                   	pop    %ebp
  8012b1:	8d 35 b9 12 80 00    	lea    0x8012b9,%esi
  8012b7:	0f 34                	sysenter 
  8012b9:	5f                   	pop    %edi
  8012ba:	5e                   	pop    %esi
  8012bb:	5d                   	pop    %ebp
  8012bc:	5c                   	pop    %esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5a                   	pop    %edx
  8012bf:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	7e 28                	jle    8012ec <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8012cf:	00 
  8012d0:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  8012d7:	00 
  8012d8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012df:	00 
  8012e0:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  8012e7:	e8 38 11 00 00       	call   802424 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012ec:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012f2:	89 ec                	mov    %ebp,%esp
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	83 ec 28             	sub    $0x28,%esp
  8012fc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012ff:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801302:	bb 00 00 00 00       	mov    $0x0,%ebx
  801307:	b8 0a 00 00 00       	mov    $0xa,%eax
  80130c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130f:	8b 55 08             	mov    0x8(%ebp),%edx
  801312:	89 df                	mov    %ebx,%edi
  801314:	51                   	push   %ecx
  801315:	52                   	push   %edx
  801316:	53                   	push   %ebx
  801317:	54                   	push   %esp
  801318:	55                   	push   %ebp
  801319:	56                   	push   %esi
  80131a:	57                   	push   %edi
  80131b:	54                   	push   %esp
  80131c:	5d                   	pop    %ebp
  80131d:	8d 35 25 13 80 00    	lea    0x801325,%esi
  801323:	0f 34                	sysenter 
  801325:	5f                   	pop    %edi
  801326:	5e                   	pop    %esi
  801327:	5d                   	pop    %ebp
  801328:	5c                   	pop    %esp
  801329:	5b                   	pop    %ebx
  80132a:	5a                   	pop    %edx
  80132b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80132c:	85 c0                	test   %eax,%eax
  80132e:	7e 28                	jle    801358 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801330:	89 44 24 10          	mov    %eax,0x10(%esp)
  801334:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80133b:	00 
  80133c:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  801343:	00 
  801344:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80134b:	00 
  80134c:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  801353:	e8 cc 10 00 00       	call   802424 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801358:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80135b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80135e:	89 ec                	mov    %ebp,%esp
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 28             	sub    $0x28,%esp
  801368:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80136b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80136e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801373:	b8 09 00 00 00       	mov    $0x9,%eax
  801378:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137b:	8b 55 08             	mov    0x8(%ebp),%edx
  80137e:	89 df                	mov    %ebx,%edi
  801380:	51                   	push   %ecx
  801381:	52                   	push   %edx
  801382:	53                   	push   %ebx
  801383:	54                   	push   %esp
  801384:	55                   	push   %ebp
  801385:	56                   	push   %esi
  801386:	57                   	push   %edi
  801387:	54                   	push   %esp
  801388:	5d                   	pop    %ebp
  801389:	8d 35 91 13 80 00    	lea    0x801391,%esi
  80138f:	0f 34                	sysenter 
  801391:	5f                   	pop    %edi
  801392:	5e                   	pop    %esi
  801393:	5d                   	pop    %ebp
  801394:	5c                   	pop    %esp
  801395:	5b                   	pop    %ebx
  801396:	5a                   	pop    %edx
  801397:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801398:	85 c0                	test   %eax,%eax
  80139a:	7e 28                	jle    8013c4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80139c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013a7:	00 
  8013a8:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  8013af:	00 
  8013b0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013b7:	00 
  8013b8:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  8013bf:	e8 60 10 00 00       	call   802424 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013c4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013c7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ca:	89 ec                	mov    %ebp,%esp
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	83 ec 28             	sub    $0x28,%esp
  8013d4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013d7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013df:	b8 07 00 00 00       	mov    $0x7,%eax
  8013e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ea:	89 df                	mov    %ebx,%edi
  8013ec:	51                   	push   %ecx
  8013ed:	52                   	push   %edx
  8013ee:	53                   	push   %ebx
  8013ef:	54                   	push   %esp
  8013f0:	55                   	push   %ebp
  8013f1:	56                   	push   %esi
  8013f2:	57                   	push   %edi
  8013f3:	54                   	push   %esp
  8013f4:	5d                   	pop    %ebp
  8013f5:	8d 35 fd 13 80 00    	lea    0x8013fd,%esi
  8013fb:	0f 34                	sysenter 
  8013fd:	5f                   	pop    %edi
  8013fe:	5e                   	pop    %esi
  8013ff:	5d                   	pop    %ebp
  801400:	5c                   	pop    %esp
  801401:	5b                   	pop    %ebx
  801402:	5a                   	pop    %edx
  801403:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801404:	85 c0                	test   %eax,%eax
  801406:	7e 28                	jle    801430 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801408:	89 44 24 10          	mov    %eax,0x10(%esp)
  80140c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801413:	00 
  801414:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  80141b:	00 
  80141c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801423:	00 
  801424:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  80142b:	e8 f4 0f 00 00       	call   802424 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801430:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801433:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801436:	89 ec                	mov    %ebp,%esp
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	83 ec 28             	sub    $0x28,%esp
  801440:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801443:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801446:	8b 7d 18             	mov    0x18(%ebp),%edi
  801449:	0b 7d 14             	or     0x14(%ebp),%edi
  80144c:	b8 06 00 00 00       	mov    $0x6,%eax
  801451:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801454:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801457:	8b 55 08             	mov    0x8(%ebp),%edx
  80145a:	51                   	push   %ecx
  80145b:	52                   	push   %edx
  80145c:	53                   	push   %ebx
  80145d:	54                   	push   %esp
  80145e:	55                   	push   %ebp
  80145f:	56                   	push   %esi
  801460:	57                   	push   %edi
  801461:	54                   	push   %esp
  801462:	5d                   	pop    %ebp
  801463:	8d 35 6b 14 80 00    	lea    0x80146b,%esi
  801469:	0f 34                	sysenter 
  80146b:	5f                   	pop    %edi
  80146c:	5e                   	pop    %esi
  80146d:	5d                   	pop    %ebp
  80146e:	5c                   	pop    %esp
  80146f:	5b                   	pop    %ebx
  801470:	5a                   	pop    %edx
  801471:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801472:	85 c0                	test   %eax,%eax
  801474:	7e 28                	jle    80149e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801476:	89 44 24 10          	mov    %eax,0x10(%esp)
  80147a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801481:	00 
  801482:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  801489:	00 
  80148a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801491:	00 
  801492:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  801499:	e8 86 0f 00 00       	call   802424 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80149e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014a4:	89 ec                	mov    %ebp,%esp
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 28             	sub    $0x28,%esp
  8014ae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014b1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8014b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c7:	51                   	push   %ecx
  8014c8:	52                   	push   %edx
  8014c9:	53                   	push   %ebx
  8014ca:	54                   	push   %esp
  8014cb:	55                   	push   %ebp
  8014cc:	56                   	push   %esi
  8014cd:	57                   	push   %edi
  8014ce:	54                   	push   %esp
  8014cf:	5d                   	pop    %ebp
  8014d0:	8d 35 d8 14 80 00    	lea    0x8014d8,%esi
  8014d6:	0f 34                	sysenter 
  8014d8:	5f                   	pop    %edi
  8014d9:	5e                   	pop    %esi
  8014da:	5d                   	pop    %ebp
  8014db:	5c                   	pop    %esp
  8014dc:	5b                   	pop    %ebx
  8014dd:	5a                   	pop    %edx
  8014de:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	7e 28                	jle    80150b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014e7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8014ee:	00 
  8014ef:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  8014f6:	00 
  8014f7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014fe:	00 
  8014ff:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  801506:	e8 19 0f 00 00       	call   802424 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80150b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80150e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801511:	89 ec                	mov    %ebp,%esp
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
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
  801522:	ba 00 00 00 00       	mov    $0x0,%edx
  801527:	b8 0c 00 00 00       	mov    $0xc,%eax
  80152c:	89 d1                	mov    %edx,%ecx
  80152e:	89 d3                	mov    %edx,%ebx
  801530:	89 d7                	mov    %edx,%edi
  801532:	51                   	push   %ecx
  801533:	52                   	push   %edx
  801534:	53                   	push   %ebx
  801535:	54                   	push   %esp
  801536:	55                   	push   %ebp
  801537:	56                   	push   %esi
  801538:	57                   	push   %edi
  801539:	54                   	push   %esp
  80153a:	5d                   	pop    %ebp
  80153b:	8d 35 43 15 80 00    	lea    0x801543,%esi
  801541:	0f 34                	sysenter 
  801543:	5f                   	pop    %edi
  801544:	5e                   	pop    %esi
  801545:	5d                   	pop    %ebp
  801546:	5c                   	pop    %esp
  801547:	5b                   	pop    %ebx
  801548:	5a                   	pop    %edx
  801549:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80154a:	8b 1c 24             	mov    (%esp),%ebx
  80154d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801551:	89 ec                	mov    %ebp,%esp
  801553:	5d                   	pop    %ebp
  801554:	c3                   	ret    

00801555 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	89 1c 24             	mov    %ebx,(%esp)
  80155e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801562:	bb 00 00 00 00       	mov    $0x0,%ebx
  801567:	b8 04 00 00 00       	mov    $0x4,%eax
  80156c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80156f:	8b 55 08             	mov    0x8(%ebp),%edx
  801572:	89 df                	mov    %ebx,%edi
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

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80158c:	8b 1c 24             	mov    (%esp),%ebx
  80158f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801593:	89 ec                	mov    %ebp,%esp
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	89 1c 24             	mov    %ebx,(%esp)
  8015a0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8015ae:	89 d1                	mov    %edx,%ecx
  8015b0:	89 d3                	mov    %edx,%ebx
  8015b2:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015cc:	8b 1c 24             	mov    (%esp),%ebx
  8015cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015d3:	89 ec                	mov    %ebp,%esp
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 28             	sub    $0x28,%esp
  8015dd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015e0:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f0:	89 cb                	mov    %ecx,%ebx
  8015f2:	89 cf                	mov    %ecx,%edi
  8015f4:	51                   	push   %ecx
  8015f5:	52                   	push   %edx
  8015f6:	53                   	push   %ebx
  8015f7:	54                   	push   %esp
  8015f8:	55                   	push   %ebp
  8015f9:	56                   	push   %esi
  8015fa:	57                   	push   %edi
  8015fb:	54                   	push   %esp
  8015fc:	5d                   	pop    %ebp
  8015fd:	8d 35 05 16 80 00    	lea    0x801605,%esi
  801603:	0f 34                	sysenter 
  801605:	5f                   	pop    %edi
  801606:	5e                   	pop    %esi
  801607:	5d                   	pop    %ebp
  801608:	5c                   	pop    %esp
  801609:	5b                   	pop    %ebx
  80160a:	5a                   	pop    %edx
  80160b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80160c:	85 c0                	test   %eax,%eax
  80160e:	7e 28                	jle    801638 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801610:	89 44 24 10          	mov    %eax,0x10(%esp)
  801614:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80161b:	00 
  80161c:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  801623:	00 
  801624:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80162b:	00 
  80162c:	c7 04 24 fd 2c 80 00 	movl   $0x802cfd,(%esp)
  801633:	e8 ec 0d 00 00       	call   802424 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801638:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80163b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80163e:	89 ec                	mov    %ebp,%esp
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    
	...

00801650 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	05 00 00 00 30       	add    $0x30000000,%eax
  80165b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	89 04 24             	mov    %eax,(%esp)
  80166c:	e8 df ff ff ff       	call   801650 <fd2num>
  801671:	05 20 00 0d 00       	add    $0xd0020,%eax
  801676:	c1 e0 0c             	shl    $0xc,%eax
}
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	57                   	push   %edi
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801684:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801689:	a8 01                	test   $0x1,%al
  80168b:	74 36                	je     8016c3 <fd_alloc+0x48>
  80168d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801692:	a8 01                	test   $0x1,%al
  801694:	74 2d                	je     8016c3 <fd_alloc+0x48>
  801696:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80169b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016a0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016a5:	89 c3                	mov    %eax,%ebx
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	c1 ea 16             	shr    $0x16,%edx
  8016ac:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016af:	f6 c2 01             	test   $0x1,%dl
  8016b2:	74 14                	je     8016c8 <fd_alloc+0x4d>
  8016b4:	89 c2                	mov    %eax,%edx
  8016b6:	c1 ea 0c             	shr    $0xc,%edx
  8016b9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016bc:	f6 c2 01             	test   $0x1,%dl
  8016bf:	75 10                	jne    8016d1 <fd_alloc+0x56>
  8016c1:	eb 05                	jmp    8016c8 <fd_alloc+0x4d>
  8016c3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8016c8:	89 1f                	mov    %ebx,(%edi)
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016cf:	eb 17                	jmp    8016e8 <fd_alloc+0x6d>
  8016d1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016d6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016db:	75 c8                	jne    8016a5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016dd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8016e3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8016e8:	5b                   	pop    %ebx
  8016e9:	5e                   	pop    %esi
  8016ea:	5f                   	pop    %edi
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f3:	83 f8 1f             	cmp    $0x1f,%eax
  8016f6:	77 36                	ja     80172e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016f8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8016fd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801700:	89 c2                	mov    %eax,%edx
  801702:	c1 ea 16             	shr    $0x16,%edx
  801705:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80170c:	f6 c2 01             	test   $0x1,%dl
  80170f:	74 1d                	je     80172e <fd_lookup+0x41>
  801711:	89 c2                	mov    %eax,%edx
  801713:	c1 ea 0c             	shr    $0xc,%edx
  801716:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80171d:	f6 c2 01             	test   $0x1,%dl
  801720:	74 0c                	je     80172e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801722:	8b 55 0c             	mov    0xc(%ebp),%edx
  801725:	89 02                	mov    %eax,(%edx)
  801727:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80172c:	eb 05                	jmp    801733 <fd_lookup+0x46>
  80172e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80173b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80173e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 a0 ff ff ff       	call   8016ed <fd_lookup>
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 0e                	js     80175f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801751:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801754:	8b 55 0c             	mov    0xc(%ebp),%edx
  801757:	89 50 04             	mov    %edx,0x4(%eax)
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	83 ec 10             	sub    $0x10,%esp
  801769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80176f:	b8 74 47 80 00       	mov    $0x804774,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801774:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801779:	be 88 2d 80 00       	mov    $0x802d88,%esi
		if (devtab[i]->dev_id == dev_id) {
  80177e:	39 08                	cmp    %ecx,(%eax)
  801780:	75 10                	jne    801792 <dev_lookup+0x31>
  801782:	eb 04                	jmp    801788 <dev_lookup+0x27>
  801784:	39 08                	cmp    %ecx,(%eax)
  801786:	75 0a                	jne    801792 <dev_lookup+0x31>
			*dev = devtab[i];
  801788:	89 03                	mov    %eax,(%ebx)
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80178f:	90                   	nop
  801790:	eb 31                	jmp    8017c3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801792:	83 c2 01             	add    $0x1,%edx
  801795:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801798:	85 c0                	test   %eax,%eax
  80179a:	75 e8                	jne    801784 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80179c:	a1 90 67 80 00       	mov    0x806790,%eax
  8017a1:	8b 40 48             	mov    0x48(%eax),%eax
  8017a4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ac:	c7 04 24 0c 2d 80 00 	movl   $0x802d0c,(%esp)
  8017b3:	e8 99 ea ff ff       	call   800251 <cprintf>
	*dev = 0;
  8017b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	5b                   	pop    %ebx
  8017c7:	5e                   	pop    %esi
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	53                   	push   %ebx
  8017ce:	83 ec 24             	sub    $0x24,%esp
  8017d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	89 04 24             	mov    %eax,(%esp)
  8017e1:	e8 07 ff ff ff       	call   8016ed <fd_lookup>
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 53                	js     80183d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f4:	8b 00                	mov    (%eax),%eax
  8017f6:	89 04 24             	mov    %eax,(%esp)
  8017f9:	e8 63 ff ff ff       	call   801761 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 3b                	js     80183d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801802:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801807:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80180e:	74 2d                	je     80183d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801810:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801813:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80181a:	00 00 00 
	stat->st_isdir = 0;
  80181d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801824:	00 00 00 
	stat->st_dev = dev;
  801827:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801834:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801837:	89 14 24             	mov    %edx,(%esp)
  80183a:	ff 50 14             	call   *0x14(%eax)
}
  80183d:	83 c4 24             	add    $0x24,%esp
  801840:	5b                   	pop    %ebx
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 24             	sub    $0x24,%esp
  80184a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801850:	89 44 24 04          	mov    %eax,0x4(%esp)
  801854:	89 1c 24             	mov    %ebx,(%esp)
  801857:	e8 91 fe ff ff       	call   8016ed <fd_lookup>
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 5f                	js     8018bf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801863:	89 44 24 04          	mov    %eax,0x4(%esp)
  801867:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186a:	8b 00                	mov    (%eax),%eax
  80186c:	89 04 24             	mov    %eax,(%esp)
  80186f:	e8 ed fe ff ff       	call   801761 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801874:	85 c0                	test   %eax,%eax
  801876:	78 47                	js     8018bf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801878:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80187b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80187f:	75 23                	jne    8018a4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801881:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801886:	8b 40 48             	mov    0x48(%eax),%eax
  801889:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	c7 04 24 2c 2d 80 00 	movl   $0x802d2c,(%esp)
  801898:	e8 b4 e9 ff ff       	call   800251 <cprintf>
  80189d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018a2:	eb 1b                	jmp    8018bf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a7:	8b 48 18             	mov    0x18(%eax),%ecx
  8018aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018af:	85 c9                	test   %ecx,%ecx
  8018b1:	74 0c                	je     8018bf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ba:	89 14 24             	mov    %edx,(%esp)
  8018bd:	ff d1                	call   *%ecx
}
  8018bf:	83 c4 24             	add    $0x24,%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    

008018c5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 24             	sub    $0x24,%esp
  8018cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d6:	89 1c 24             	mov    %ebx,(%esp)
  8018d9:	e8 0f fe ff ff       	call   8016ed <fd_lookup>
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 66                	js     801948 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ec:	8b 00                	mov    (%eax),%eax
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	e8 6b fe ff ff       	call   801761 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 4e                	js     801948 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018fd:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801901:	75 23                	jne    801926 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801903:	a1 90 67 80 00       	mov    0x806790,%eax
  801908:	8b 40 48             	mov    0x48(%eax),%eax
  80190b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80190f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801913:	c7 04 24 4d 2d 80 00 	movl   $0x802d4d,(%esp)
  80191a:	e8 32 e9 ff ff       	call   800251 <cprintf>
  80191f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801924:	eb 22                	jmp    801948 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801929:	8b 48 0c             	mov    0xc(%eax),%ecx
  80192c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801931:	85 c9                	test   %ecx,%ecx
  801933:	74 13                	je     801948 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801935:	8b 45 10             	mov    0x10(%ebp),%eax
  801938:	89 44 24 08          	mov    %eax,0x8(%esp)
  80193c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801943:	89 14 24             	mov    %edx,(%esp)
  801946:	ff d1                	call   *%ecx
}
  801948:	83 c4 24             	add    $0x24,%esp
  80194b:	5b                   	pop    %ebx
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 24             	sub    $0x24,%esp
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801958:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195f:	89 1c 24             	mov    %ebx,(%esp)
  801962:	e8 86 fd ff ff       	call   8016ed <fd_lookup>
  801967:	85 c0                	test   %eax,%eax
  801969:	78 6b                	js     8019d6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801972:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801975:	8b 00                	mov    (%eax),%eax
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 e2 fd ff ff       	call   801761 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 53                	js     8019d6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801983:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801986:	8b 42 08             	mov    0x8(%edx),%eax
  801989:	83 e0 03             	and    $0x3,%eax
  80198c:	83 f8 01             	cmp    $0x1,%eax
  80198f:	75 23                	jne    8019b4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801991:	a1 90 67 80 00       	mov    0x806790,%eax
  801996:	8b 40 48             	mov    0x48(%eax),%eax
  801999:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	c7 04 24 6a 2d 80 00 	movl   $0x802d6a,(%esp)
  8019a8:	e8 a4 e8 ff ff       	call   800251 <cprintf>
  8019ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019b2:	eb 22                	jmp    8019d6 <read+0x88>
	}
	if (!dev->dev_read)
  8019b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b7:	8b 48 08             	mov    0x8(%eax),%ecx
  8019ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019bf:	85 c9                	test   %ecx,%ecx
  8019c1:	74 13                	je     8019d6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d1:	89 14 24             	mov    %edx,(%esp)
  8019d4:	ff d1                	call   *%ecx
}
  8019d6:	83 c4 24             	add    $0x24,%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	57                   	push   %edi
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 1c             	sub    $0x1c,%esp
  8019e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	85 f6                	test   %esi,%esi
  8019fc:	74 29                	je     801a27 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019fe:	89 f0                	mov    %esi,%eax
  801a00:	29 d0                	sub    %edx,%eax
  801a02:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a06:	03 55 0c             	add    0xc(%ebp),%edx
  801a09:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a0d:	89 3c 24             	mov    %edi,(%esp)
  801a10:	e8 39 ff ff ff       	call   80194e <read>
		if (m < 0)
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 0e                	js     801a27 <readn+0x4b>
			return m;
		if (m == 0)
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	74 08                	je     801a25 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a1d:	01 c3                	add    %eax,%ebx
  801a1f:	89 da                	mov    %ebx,%edx
  801a21:	39 f3                	cmp    %esi,%ebx
  801a23:	72 d9                	jb     8019fe <readn+0x22>
  801a25:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a27:	83 c4 1c             	add    $0x1c,%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5f                   	pop    %edi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	83 ec 20             	sub    $0x20,%esp
  801a37:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a3a:	89 34 24             	mov    %esi,(%esp)
  801a3d:	e8 0e fc ff ff       	call   801650 <fd2num>
  801a42:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a45:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a49:	89 04 24             	mov    %eax,(%esp)
  801a4c:	e8 9c fc ff ff       	call   8016ed <fd_lookup>
  801a51:	89 c3                	mov    %eax,%ebx
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 05                	js     801a5c <fd_close+0x2d>
  801a57:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a5a:	74 0c                	je     801a68 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a5c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801a60:	19 c0                	sbb    %eax,%eax
  801a62:	f7 d0                	not    %eax
  801a64:	21 c3                	and    %eax,%ebx
  801a66:	eb 3d                	jmp    801aa5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6f:	8b 06                	mov    (%esi),%eax
  801a71:	89 04 24             	mov    %eax,(%esp)
  801a74:	e8 e8 fc ff ff       	call   801761 <dev_lookup>
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 16                	js     801a95 <fd_close+0x66>
		if (dev->dev_close)
  801a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a82:	8b 40 10             	mov    0x10(%eax),%eax
  801a85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	74 07                	je     801a95 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801a8e:	89 34 24             	mov    %esi,(%esp)
  801a91:	ff d0                	call   *%eax
  801a93:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a95:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa0:	e8 29 f9 ff ff       	call   8013ce <sys_page_unmap>
	return r;
}
  801aa5:	89 d8                	mov    %ebx,%eax
  801aa7:	83 c4 20             	add    $0x20,%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	89 04 24             	mov    %eax,(%esp)
  801ac1:	e8 27 fc ff ff       	call   8016ed <fd_lookup>
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 13                	js     801add <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801aca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ad1:	00 
  801ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad5:	89 04 24             	mov    %eax,(%esp)
  801ad8:	e8 52 ff ff ff       	call   801a2f <fd_close>
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 18             	sub    $0x18,%esp
  801ae5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ae8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801aeb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801af2:	00 
  801af3:	8b 45 08             	mov    0x8(%ebp),%eax
  801af6:	89 04 24             	mov    %eax,(%esp)
  801af9:	e8 79 03 00 00       	call   801e77 <open>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 1b                	js     801b1f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0b:	89 1c 24             	mov    %ebx,(%esp)
  801b0e:	e8 b7 fc ff ff       	call   8017ca <fstat>
  801b13:	89 c6                	mov    %eax,%esi
	close(fd);
  801b15:	89 1c 24             	mov    %ebx,(%esp)
  801b18:	e8 91 ff ff ff       	call   801aae <close>
  801b1d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b1f:	89 d8                	mov    %ebx,%eax
  801b21:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b24:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b27:	89 ec                	mov    %ebp,%esp
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	53                   	push   %ebx
  801b2f:	83 ec 14             	sub    $0x14,%esp
  801b32:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b37:	89 1c 24             	mov    %ebx,(%esp)
  801b3a:	e8 6f ff ff ff       	call   801aae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b3f:	83 c3 01             	add    $0x1,%ebx
  801b42:	83 fb 20             	cmp    $0x20,%ebx
  801b45:	75 f0                	jne    801b37 <close_all+0xc>
		close(i);
}
  801b47:	83 c4 14             	add    $0x14,%esp
  801b4a:	5b                   	pop    %ebx
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 58             	sub    $0x58,%esp
  801b53:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b56:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b59:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b5c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b5f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b66:	8b 45 08             	mov    0x8(%ebp),%eax
  801b69:	89 04 24             	mov    %eax,(%esp)
  801b6c:	e8 7c fb ff ff       	call   8016ed <fd_lookup>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	85 c0                	test   %eax,%eax
  801b75:	0f 88 e0 00 00 00    	js     801c5b <dup+0x10e>
		return r;
	close(newfdnum);
  801b7b:	89 3c 24             	mov    %edi,(%esp)
  801b7e:	e8 2b ff ff ff       	call   801aae <close>

	newfd = INDEX2FD(newfdnum);
  801b83:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b89:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8f:	89 04 24             	mov    %eax,(%esp)
  801b92:	e8 c9 fa ff ff       	call   801660 <fd2data>
  801b97:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b99:	89 34 24             	mov    %esi,(%esp)
  801b9c:	e8 bf fa ff ff       	call   801660 <fd2data>
  801ba1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801ba4:	89 da                	mov    %ebx,%edx
  801ba6:	89 d8                	mov    %ebx,%eax
  801ba8:	c1 e8 16             	shr    $0x16,%eax
  801bab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bb2:	a8 01                	test   $0x1,%al
  801bb4:	74 43                	je     801bf9 <dup+0xac>
  801bb6:	c1 ea 0c             	shr    $0xc,%edx
  801bb9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bc0:	a8 01                	test   $0x1,%al
  801bc2:	74 35                	je     801bf9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bc4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bcb:	25 07 0e 00 00       	and    $0xe07,%eax
  801bd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801bd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801bd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801be2:	00 
  801be3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bee:	e8 47 f8 ff ff       	call   80143a <sys_page_map>
  801bf3:	89 c3                	mov    %eax,%ebx
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	78 3f                	js     801c38 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801bf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bfc:	89 c2                	mov    %eax,%edx
  801bfe:	c1 ea 0c             	shr    $0xc,%edx
  801c01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c08:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c0e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c12:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c1d:	00 
  801c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c29:	e8 0c f8 ff ff       	call   80143a <sys_page_map>
  801c2e:	89 c3                	mov    %eax,%ebx
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 04                	js     801c38 <dup+0xeb>
  801c34:	89 fb                	mov    %edi,%ebx
  801c36:	eb 23                	jmp    801c5b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c43:	e8 86 f7 ff ff       	call   8013ce <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c56:	e8 73 f7 ff ff       	call   8013ce <sys_page_unmap>
	return r;
}
  801c5b:	89 d8                	mov    %ebx,%eax
  801c5d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c60:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c63:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c66:	89 ec                	mov    %ebp,%esp
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    
	...

00801c6c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 18             	sub    $0x18,%esp
  801c72:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c75:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c78:	89 c3                	mov    %eax,%ebx
  801c7a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c7c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801c83:	75 11                	jne    801c96 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c8c:	e8 ef 07 00 00       	call   802480 <ipc_find_env>
  801c91:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c9d:	00 
  801c9e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801ca5:	00 
  801ca6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801caa:	a1 00 50 80 00       	mov    0x805000,%eax
  801caf:	89 04 24             	mov    %eax,(%esp)
  801cb2:	e8 14 08 00 00       	call   8024cb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cbe:	00 
  801cbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cca:	e8 7a 08 00 00       	call   802549 <ipc_recv>
}
  801ccf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cd2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cd5:	89 ec                	mov    %ebp,%esp
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    

00801cd9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce5:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ced:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf7:	b8 02 00 00 00       	mov    $0x2,%eax
  801cfc:	e8 6b ff ff ff       	call   801c6c <fsipc>
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d0f:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801d14:	ba 00 00 00 00       	mov    $0x0,%edx
  801d19:	b8 06 00 00 00       	mov    $0x6,%eax
  801d1e:	e8 49 ff ff ff       	call   801c6c <fsipc>
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d30:	b8 08 00 00 00       	mov    $0x8,%eax
  801d35:	e8 32 ff ff ff       	call   801c6c <fsipc>
}
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	53                   	push   %ebx
  801d40:	83 ec 14             	sub    $0x14,%esp
  801d43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	8b 40 0c             	mov    0xc(%eax),%eax
  801d4c:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d51:	ba 00 00 00 00       	mov    $0x0,%edx
  801d56:	b8 05 00 00 00       	mov    $0x5,%eax
  801d5b:	e8 0c ff ff ff       	call   801c6c <fsipc>
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 2b                	js     801d8f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d64:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801d6b:	00 
  801d6c:	89 1c 24             	mov    %ebx,(%esp)
  801d6f:	e8 06 ee ff ff       	call   800b7a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d74:	a1 80 70 80 00       	mov    0x807080,%eax
  801d79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d7f:	a1 84 70 80 00       	mov    0x807084,%eax
  801d84:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d8a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d8f:	83 c4 14             	add    $0x14,%esp
  801d92:	5b                   	pop    %ebx
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 18             	sub    $0x18,%esp
  801d9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d9e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801da3:	76 05                	jbe    801daa <devfile_write+0x15>
  801da5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801daa:	8b 55 08             	mov    0x8(%ebp),%edx
  801dad:	8b 52 0c             	mov    0xc(%edx),%edx
  801db0:	89 15 00 70 80 00    	mov    %edx,0x807000
        fsipcbuf.write.req_n = n;
  801db6:	a3 04 70 80 00       	mov    %eax,0x807004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801dbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc6:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801dcd:	e8 93 ef ff ff       	call   800d65 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd7:	b8 04 00 00 00       	mov    $0x4,%eax
  801ddc:	e8 8b fe ff ff       	call   801c6c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	53                   	push   %ebx
  801de7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ded:	8b 40 0c             	mov    0xc(%eax),%eax
  801df0:	a3 00 70 80 00       	mov    %eax,0x807000
        fsipcbuf.read.req_n = n;
  801df5:	8b 45 10             	mov    0x10(%ebp),%eax
  801df8:	a3 04 70 80 00       	mov    %eax,0x807004
        r = fsipc(FSREQ_READ,NULL);
  801dfd:	ba 00 00 00 00       	mov    $0x0,%edx
  801e02:	b8 03 00 00 00       	mov    $0x3,%eax
  801e07:	e8 60 fe ff ff       	call   801c6c <fsipc>
  801e0c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	78 17                	js     801e29 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801e12:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e16:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801e1d:	00 
  801e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e21:	89 04 24             	mov    %eax,(%esp)
  801e24:	e8 3c ef ff ff       	call   800d65 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801e29:	89 d8                	mov    %ebx,%eax
  801e2b:	83 c4 14             	add    $0x14,%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    

00801e31 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	53                   	push   %ebx
  801e35:	83 ec 14             	sub    $0x14,%esp
  801e38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e3b:	89 1c 24             	mov    %ebx,(%esp)
  801e3e:	e8 ed ec ff ff       	call   800b30 <strlen>
  801e43:	89 c2                	mov    %eax,%edx
  801e45:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e4a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e50:	7f 1f                	jg     801e71 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e56:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801e5d:	e8 18 ed ff ff       	call   800b7a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e62:	ba 00 00 00 00       	mov    $0x0,%edx
  801e67:	b8 07 00 00 00       	mov    $0x7,%eax
  801e6c:	e8 fb fd ff ff       	call   801c6c <fsipc>
}
  801e71:	83 c4 14             	add    $0x14,%esp
  801e74:	5b                   	pop    %ebx
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    

00801e77 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	83 ec 28             	sub    $0x28,%esp
  801e7d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e80:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e83:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801e86:	89 34 24             	mov    %esi,(%esp)
  801e89:	e8 a2 ec ff ff       	call   800b30 <strlen>
  801e8e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801e93:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e98:	7f 6d                	jg     801f07 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801e9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9d:	89 04 24             	mov    %eax,(%esp)
  801ea0:	e8 d6 f7 ff ff       	call   80167b <fd_alloc>
  801ea5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 5c                	js     801f07 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801eab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eae:	a3 00 74 80 00       	mov    %eax,0x807400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801eb3:	89 34 24             	mov    %esi,(%esp)
  801eb6:	e8 75 ec ff ff       	call   800b30 <strlen>
  801ebb:	83 c0 01             	add    $0x1,%eax
  801ebe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec6:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801ecd:	e8 93 ee ff ff       	call   800d65 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801ed2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed5:	b8 01 00 00 00       	mov    $0x1,%eax
  801eda:	e8 8d fd ff ff       	call   801c6c <fsipc>
  801edf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	79 15                	jns    801efa <open+0x83>
             fd_close(fd,0);
  801ee5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801eec:	00 
  801eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef0:	89 04 24             	mov    %eax,(%esp)
  801ef3:	e8 37 fb ff ff       	call   801a2f <fd_close>
             return r;
  801ef8:	eb 0d                	jmp    801f07 <open+0x90>
        }
        return fd2num(fd);
  801efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efd:	89 04 24             	mov    %eax,(%esp)
  801f00:	e8 4b f7 ff ff       	call   801650 <fd2num>
  801f05:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801f07:	89 d8                	mov    %ebx,%eax
  801f09:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f0c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f0f:	89 ec                	mov    %ebp,%esp
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    
	...

00801f20 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f26:	c7 44 24 04 94 2d 80 	movl   $0x802d94,0x4(%esp)
  801f2d:	00 
  801f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f31:	89 04 24             	mov    %eax,(%esp)
  801f34:	e8 41 ec ff ff       	call   800b7a <strcpy>
	return 0;
}
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3e:	c9                   	leave  
  801f3f:	c3                   	ret    

00801f40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	53                   	push   %ebx
  801f44:	83 ec 14             	sub    $0x14,%esp
  801f47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f4a:	89 1c 24             	mov    %ebx,(%esp)
  801f4d:	e8 6a 06 00 00       	call   8025bc <pageref>
  801f52:	89 c2                	mov    %eax,%edx
  801f54:	b8 00 00 00 00       	mov    $0x0,%eax
  801f59:	83 fa 01             	cmp    $0x1,%edx
  801f5c:	75 0b                	jne    801f69 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801f5e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f61:	89 04 24             	mov    %eax,(%esp)
  801f64:	e8 b9 02 00 00       	call   802222 <nsipc_close>
	else
		return 0;
}
  801f69:	83 c4 14             	add    $0x14,%esp
  801f6c:	5b                   	pop    %ebx
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    

00801f6f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f7c:	00 
  801f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 c5 02 00 00       	call   80225e <nsipc_send>
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801fa1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801fa8:	00 
  801fa9:	8b 45 10             	mov    0x10(%ebp),%eax
  801fac:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fba:	8b 40 0c             	mov    0xc(%eax),%eax
  801fbd:	89 04 24             	mov    %eax,(%esp)
  801fc0:	e8 0c 03 00 00       	call   8022d1 <nsipc_recv>
}
  801fc5:	c9                   	leave  
  801fc6:	c3                   	ret    

00801fc7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	56                   	push   %esi
  801fcb:	53                   	push   %ebx
  801fcc:	83 ec 20             	sub    $0x20,%esp
  801fcf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd4:	89 04 24             	mov    %eax,(%esp)
  801fd7:	e8 9f f6 ff ff       	call   80167b <fd_alloc>
  801fdc:	89 c3                	mov    %eax,%ebx
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	78 21                	js     802003 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fe2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fe9:	00 
  801fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff8:	e8 ab f4 ff ff       	call   8014a8 <sys_page_alloc>
  801ffd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fff:	85 c0                	test   %eax,%eax
  802001:	79 0a                	jns    80200d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802003:	89 34 24             	mov    %esi,(%esp)
  802006:	e8 17 02 00 00       	call   802222 <nsipc_close>
		return r;
  80200b:	eb 28                	jmp    802035 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80200d:	8b 15 90 47 80 00    	mov    0x804790,%edx
  802013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802016:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802025:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202b:	89 04 24             	mov    %eax,(%esp)
  80202e:	e8 1d f6 ff ff       	call   801650 <fd2num>
  802033:	89 c3                	mov    %eax,%ebx
}
  802035:	89 d8                	mov    %ebx,%eax
  802037:	83 c4 20             	add    $0x20,%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802044:	8b 45 10             	mov    0x10(%ebp),%eax
  802047:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802052:	8b 45 08             	mov    0x8(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 79 01 00 00       	call   8021d6 <nsipc_socket>
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 05                	js     802066 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802061:	e8 61 ff ff ff       	call   801fc7 <alloc_sockfd>
}
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80206e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802071:	89 54 24 04          	mov    %edx,0x4(%esp)
  802075:	89 04 24             	mov    %eax,(%esp)
  802078:	e8 70 f6 ff ff       	call   8016ed <fd_lookup>
  80207d:	85 c0                	test   %eax,%eax
  80207f:	78 15                	js     802096 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802081:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802084:	8b 0a                	mov    (%edx),%ecx
  802086:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80208b:	3b 0d 90 47 80 00    	cmp    0x804790,%ecx
  802091:	75 03                	jne    802096 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802093:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80209e:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a1:	e8 c2 ff ff ff       	call   802068 <fd2sockid>
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 0f                	js     8020b9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 47 01 00 00       	call   802200 <nsipc_listen>
}
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c4:	e8 9f ff ff ff       	call   802068 <fd2sockid>
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 16                	js     8020e3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8020cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8020d0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020db:	89 04 24             	mov    %eax,(%esp)
  8020de:	e8 6e 02 00 00       	call   802351 <nsipc_connect>
}
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    

008020e5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ee:	e8 75 ff ff ff       	call   802068 <fd2sockid>
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	78 0f                	js     802106 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020fe:	89 04 24             	mov    %eax,(%esp)
  802101:	e8 36 01 00 00       	call   80223c <nsipc_shutdown>
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
  802111:	e8 52 ff ff ff       	call   802068 <fd2sockid>
  802116:	85 c0                	test   %eax,%eax
  802118:	78 16                	js     802130 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80211a:	8b 55 10             	mov    0x10(%ebp),%edx
  80211d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802121:	8b 55 0c             	mov    0xc(%ebp),%edx
  802124:	89 54 24 04          	mov    %edx,0x4(%esp)
  802128:	89 04 24             	mov    %eax,(%esp)
  80212b:	e8 60 02 00 00       	call   802390 <nsipc_bind>
}
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802138:	8b 45 08             	mov    0x8(%ebp),%eax
  80213b:	e8 28 ff ff ff       	call   802068 <fd2sockid>
  802140:	85 c0                	test   %eax,%eax
  802142:	78 1f                	js     802163 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802144:	8b 55 10             	mov    0x10(%ebp),%edx
  802147:	89 54 24 08          	mov    %edx,0x8(%esp)
  80214b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80214e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802152:	89 04 24             	mov    %eax,(%esp)
  802155:	e8 75 02 00 00       	call   8023cf <nsipc_accept>
  80215a:	85 c0                	test   %eax,%eax
  80215c:	78 05                	js     802163 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80215e:	e8 64 fe ff ff       	call   801fc7 <alloc_sockfd>
}
  802163:	c9                   	leave  
  802164:	c3                   	ret    
	...

00802170 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	53                   	push   %ebx
  802174:	83 ec 14             	sub    $0x14,%esp
  802177:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802179:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802180:	75 11                	jne    802193 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802182:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802189:	e8 f2 02 00 00       	call   802480 <ipc_find_env>
  80218e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802193:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80219a:	00 
  80219b:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  8021a2:	00 
  8021a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021a7:	a1 04 50 80 00       	mov    0x805004,%eax
  8021ac:	89 04 24             	mov    %eax,(%esp)
  8021af:	e8 17 03 00 00       	call   8024cb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021bb:	00 
  8021bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021c3:	00 
  8021c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021cb:	e8 79 03 00 00       	call   802549 <ipc_recv>
}
  8021d0:	83 c4 14             	add    $0x14,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021df:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  8021e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e7:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  8021ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ef:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  8021f4:	b8 09 00 00 00       	mov    $0x9,%eax
  8021f9:	e8 72 ff ff ff       	call   802170 <nsipc>
}
  8021fe:	c9                   	leave  
  8021ff:	c3                   	ret    

00802200 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802206:	8b 45 08             	mov    0x8(%ebp),%eax
  802209:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  80220e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802211:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  802216:	b8 06 00 00 00       	mov    $0x6,%eax
  80221b:	e8 50 ff ff ff       	call   802170 <nsipc>
}
  802220:	c9                   	leave  
  802221:	c3                   	ret    

00802222 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802228:	8b 45 08             	mov    0x8(%ebp),%eax
  80222b:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  802230:	b8 04 00 00 00       	mov    $0x4,%eax
  802235:	e8 36 ff ff ff       	call   802170 <nsipc>
}
  80223a:	c9                   	leave  
  80223b:	c3                   	ret    

0080223c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802242:	8b 45 08             	mov    0x8(%ebp),%eax
  802245:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  80224a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224d:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  802252:	b8 03 00 00 00       	mov    $0x3,%eax
  802257:	e8 14 ff ff ff       	call   802170 <nsipc>
}
  80225c:	c9                   	leave  
  80225d:	c3                   	ret    

0080225e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
  802261:	53                   	push   %ebx
  802262:	83 ec 14             	sub    $0x14,%esp
  802265:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802268:	8b 45 08             	mov    0x8(%ebp),%eax
  80226b:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  802270:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802276:	7e 24                	jle    80229c <nsipc_send+0x3e>
  802278:	c7 44 24 0c a0 2d 80 	movl   $0x802da0,0xc(%esp)
  80227f:	00 
  802280:	c7 44 24 08 ac 2d 80 	movl   $0x802dac,0x8(%esp)
  802287:	00 
  802288:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80228f:	00 
  802290:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  802297:	e8 88 01 00 00       	call   802424 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80229c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a7:	c7 04 24 0c 80 80 00 	movl   $0x80800c,(%esp)
  8022ae:	e8 b2 ea ff ff       	call   800d65 <memmove>
	nsipcbuf.send.req_size = size;
  8022b3:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  8022b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8022bc:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  8022c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8022c6:	e8 a5 fe ff ff       	call   802170 <nsipc>
}
  8022cb:	83 c4 14             	add    $0x14,%esp
  8022ce:	5b                   	pop    %ebx
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    

008022d1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	56                   	push   %esi
  8022d5:	53                   	push   %ebx
  8022d6:	83 ec 10             	sub    $0x10,%esp
  8022d9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022df:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  8022e4:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  8022ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8022ed:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022f2:	b8 07 00 00 00       	mov    $0x7,%eax
  8022f7:	e8 74 fe ff ff       	call   802170 <nsipc>
  8022fc:	89 c3                	mov    %eax,%ebx
  8022fe:	85 c0                	test   %eax,%eax
  802300:	78 46                	js     802348 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802302:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802307:	7f 04                	jg     80230d <nsipc_recv+0x3c>
  802309:	39 c6                	cmp    %eax,%esi
  80230b:	7d 24                	jge    802331 <nsipc_recv+0x60>
  80230d:	c7 44 24 0c cd 2d 80 	movl   $0x802dcd,0xc(%esp)
  802314:	00 
  802315:	c7 44 24 08 ac 2d 80 	movl   $0x802dac,0x8(%esp)
  80231c:	00 
  80231d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802324:	00 
  802325:	c7 04 24 c1 2d 80 00 	movl   $0x802dc1,(%esp)
  80232c:	e8 f3 00 00 00       	call   802424 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802331:	89 44 24 08          	mov    %eax,0x8(%esp)
  802335:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  80233c:	00 
  80233d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802340:	89 04 24             	mov    %eax,(%esp)
  802343:	e8 1d ea ff ff       	call   800d65 <memmove>
	}

	return r;
}
  802348:	89 d8                	mov    %ebx,%eax
  80234a:	83 c4 10             	add    $0x10,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5d                   	pop    %ebp
  802350:	c3                   	ret    

00802351 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802351:	55                   	push   %ebp
  802352:	89 e5                	mov    %esp,%ebp
  802354:	53                   	push   %ebx
  802355:	83 ec 14             	sub    $0x14,%esp
  802358:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80235b:	8b 45 08             	mov    0x8(%ebp),%eax
  80235e:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802363:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802367:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236e:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  802375:	e8 eb e9 ff ff       	call   800d65 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80237a:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  802380:	b8 05 00 00 00       	mov    $0x5,%eax
  802385:	e8 e6 fd ff ff       	call   802170 <nsipc>
}
  80238a:	83 c4 14             	add    $0x14,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    

00802390 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	53                   	push   %ebx
  802394:	83 ec 14             	sub    $0x14,%esp
  802397:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80239a:	8b 45 08             	mov    0x8(%ebp),%eax
  80239d:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8023a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ad:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  8023b4:	e8 ac e9 ff ff       	call   800d65 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8023b9:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  8023bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8023c4:	e8 a7 fd ff ff       	call   802170 <nsipc>
}
  8023c9:	83 c4 14             	add    $0x14,%esp
  8023cc:	5b                   	pop    %ebx
  8023cd:	5d                   	pop    %ebp
  8023ce:	c3                   	ret    

008023cf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8023cf:	55                   	push   %ebp
  8023d0:	89 e5                	mov    %esp,%ebp
  8023d2:	83 ec 18             	sub    $0x18,%esp
  8023d5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8023d8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8023db:	8b 45 08             	mov    0x8(%ebp),%eax
  8023de:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8023e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e8:	e8 83 fd ff ff       	call   802170 <nsipc>
  8023ed:	89 c3                	mov    %eax,%ebx
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	78 25                	js     802418 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8023f3:	be 10 80 80 00       	mov    $0x808010,%esi
  8023f8:	8b 06                	mov    (%esi),%eax
  8023fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023fe:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  802405:	00 
  802406:	8b 45 0c             	mov    0xc(%ebp),%eax
  802409:	89 04 24             	mov    %eax,(%esp)
  80240c:	e8 54 e9 ff ff       	call   800d65 <memmove>
		*addrlen = ret->ret_addrlen;
  802411:	8b 16                	mov    (%esi),%edx
  802413:	8b 45 10             	mov    0x10(%ebp),%eax
  802416:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80241d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802420:	89 ec                	mov    %ebp,%esp
  802422:	5d                   	pop    %ebp
  802423:	c3                   	ret    

00802424 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802424:	55                   	push   %ebp
  802425:	89 e5                	mov    %esp,%ebp
  802427:	56                   	push   %esi
  802428:	53                   	push   %ebx
  802429:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80242c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80242f:	8b 1d 70 47 80 00    	mov    0x804770,%ebx
  802435:	e8 5d f1 ff ff       	call   801597 <sys_getenvid>
  80243a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80243d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802441:	8b 55 08             	mov    0x8(%ebp),%edx
  802444:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802448:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80244c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802450:	c7 04 24 e4 2d 80 00 	movl   $0x802de4,(%esp)
  802457:	e8 f5 dd ff ff       	call   800251 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80245c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802460:	8b 45 10             	mov    0x10(%ebp),%eax
  802463:	89 04 24             	mov    %eax,(%esp)
  802466:	e8 85 dd ff ff       	call   8001f0 <vcprintf>
	cprintf("\n");
  80246b:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  802472:	e8 da dd ff ff       	call   800251 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802477:	cc                   	int3   
  802478:	eb fd                	jmp    802477 <_panic+0x53>
  80247a:	00 00                	add    %al,(%eax)
  80247c:	00 00                	add    %al,(%eax)
	...

00802480 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802486:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80248c:	b8 01 00 00 00       	mov    $0x1,%eax
  802491:	39 ca                	cmp    %ecx,%edx
  802493:	75 04                	jne    802499 <ipc_find_env+0x19>
  802495:	b0 00                	mov    $0x0,%al
  802497:	eb 12                	jmp    8024ab <ipc_find_env+0x2b>
  802499:	89 c2                	mov    %eax,%edx
  80249b:	c1 e2 07             	shl    $0x7,%edx
  80249e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8024a5:	8b 12                	mov    (%edx),%edx
  8024a7:	39 ca                	cmp    %ecx,%edx
  8024a9:	75 10                	jne    8024bb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8024ab:	89 c2                	mov    %eax,%edx
  8024ad:	c1 e2 07             	shl    $0x7,%edx
  8024b0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8024b7:	8b 00                	mov    (%eax),%eax
  8024b9:	eb 0e                	jmp    8024c9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024bb:	83 c0 01             	add    $0x1,%eax
  8024be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024c3:	75 d4                	jne    802499 <ipc_find_env+0x19>
  8024c5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8024c9:	5d                   	pop    %ebp
  8024ca:	c3                   	ret    

008024cb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024cb:	55                   	push   %ebp
  8024cc:	89 e5                	mov    %esp,%ebp
  8024ce:	57                   	push   %edi
  8024cf:	56                   	push   %esi
  8024d0:	53                   	push   %ebx
  8024d1:	83 ec 1c             	sub    $0x1c,%esp
  8024d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8024d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8024dd:	85 db                	test   %ebx,%ebx
  8024df:	74 19                	je     8024fa <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8024e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8024e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024f0:	89 34 24             	mov    %esi,(%esp)
  8024f3:	e8 51 ed ff ff       	call   801249 <sys_ipc_try_send>
  8024f8:	eb 1b                	jmp    802515 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8024fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8024fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802501:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802508:	ee 
  802509:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80250d:	89 34 24             	mov    %esi,(%esp)
  802510:	e8 34 ed ff ff       	call   801249 <sys_ipc_try_send>
           if(ret == 0)
  802515:	85 c0                	test   %eax,%eax
  802517:	74 28                	je     802541 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802519:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80251c:	74 1c                	je     80253a <ipc_send+0x6f>
              panic("ipc send error");
  80251e:	c7 44 24 08 08 2e 80 	movl   $0x802e08,0x8(%esp)
  802525:	00 
  802526:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80252d:	00 
  80252e:	c7 04 24 17 2e 80 00 	movl   $0x802e17,(%esp)
  802535:	e8 ea fe ff ff       	call   802424 <_panic>
           sys_yield();
  80253a:	e8 d6 ef ff ff       	call   801515 <sys_yield>
        }
  80253f:	eb 9c                	jmp    8024dd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802541:	83 c4 1c             	add    $0x1c,%esp
  802544:	5b                   	pop    %ebx
  802545:	5e                   	pop    %esi
  802546:	5f                   	pop    %edi
  802547:	5d                   	pop    %ebp
  802548:	c3                   	ret    

00802549 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802549:	55                   	push   %ebp
  80254a:	89 e5                	mov    %esp,%ebp
  80254c:	56                   	push   %esi
  80254d:	53                   	push   %ebx
  80254e:	83 ec 10             	sub    $0x10,%esp
  802551:	8b 75 08             	mov    0x8(%ebp),%esi
  802554:	8b 45 0c             	mov    0xc(%ebp),%eax
  802557:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80255a:	85 c0                	test   %eax,%eax
  80255c:	75 0e                	jne    80256c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80255e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802565:	e8 74 ec ff ff       	call   8011de <sys_ipc_recv>
  80256a:	eb 08                	jmp    802574 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80256c:	89 04 24             	mov    %eax,(%esp)
  80256f:	e8 6a ec ff ff       	call   8011de <sys_ipc_recv>
        if(ret == 0){
  802574:	85 c0                	test   %eax,%eax
  802576:	75 26                	jne    80259e <ipc_recv+0x55>
           if(from_env_store)
  802578:	85 f6                	test   %esi,%esi
  80257a:	74 0a                	je     802586 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80257c:	a1 90 67 80 00       	mov    0x806790,%eax
  802581:	8b 40 78             	mov    0x78(%eax),%eax
  802584:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802586:	85 db                	test   %ebx,%ebx
  802588:	74 0a                	je     802594 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80258a:	a1 90 67 80 00       	mov    0x806790,%eax
  80258f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802592:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802594:	a1 90 67 80 00       	mov    0x806790,%eax
  802599:	8b 40 74             	mov    0x74(%eax),%eax
  80259c:	eb 14                	jmp    8025b2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80259e:	85 f6                	test   %esi,%esi
  8025a0:	74 06                	je     8025a8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8025a2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8025a8:	85 db                	test   %ebx,%ebx
  8025aa:	74 06                	je     8025b2 <ipc_recv+0x69>
              *perm_store = 0;
  8025ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8025b2:	83 c4 10             	add    $0x10,%esp
  8025b5:	5b                   	pop    %ebx
  8025b6:	5e                   	pop    %esi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    
  8025b9:	00 00                	add    %al,(%eax)
	...

008025bc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025bc:	55                   	push   %ebp
  8025bd:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8025bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c2:	89 c2                	mov    %eax,%edx
  8025c4:	c1 ea 16             	shr    $0x16,%edx
  8025c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025ce:	f6 c2 01             	test   $0x1,%dl
  8025d1:	74 20                	je     8025f3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025d3:	c1 e8 0c             	shr    $0xc,%eax
  8025d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025dd:	a8 01                	test   $0x1,%al
  8025df:	74 12                	je     8025f3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025e1:	c1 e8 0c             	shr    $0xc,%eax
  8025e4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025e9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025ee:	0f b7 c0             	movzwl %ax,%eax
  8025f1:	eb 05                	jmp    8025f8 <pageref+0x3c>
  8025f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025f8:	5d                   	pop    %ebp
  8025f9:	c3                   	ret    
  8025fa:	00 00                	add    %al,(%eax)
  8025fc:	00 00                	add    %al,(%eax)
	...

00802600 <__udivdi3>:
  802600:	55                   	push   %ebp
  802601:	89 e5                	mov    %esp,%ebp
  802603:	57                   	push   %edi
  802604:	56                   	push   %esi
  802605:	83 ec 10             	sub    $0x10,%esp
  802608:	8b 45 14             	mov    0x14(%ebp),%eax
  80260b:	8b 55 08             	mov    0x8(%ebp),%edx
  80260e:	8b 75 10             	mov    0x10(%ebp),%esi
  802611:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802614:	85 c0                	test   %eax,%eax
  802616:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802619:	75 35                	jne    802650 <__udivdi3+0x50>
  80261b:	39 fe                	cmp    %edi,%esi
  80261d:	77 61                	ja     802680 <__udivdi3+0x80>
  80261f:	85 f6                	test   %esi,%esi
  802621:	75 0b                	jne    80262e <__udivdi3+0x2e>
  802623:	b8 01 00 00 00       	mov    $0x1,%eax
  802628:	31 d2                	xor    %edx,%edx
  80262a:	f7 f6                	div    %esi
  80262c:	89 c6                	mov    %eax,%esi
  80262e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802631:	31 d2                	xor    %edx,%edx
  802633:	89 f8                	mov    %edi,%eax
  802635:	f7 f6                	div    %esi
  802637:	89 c7                	mov    %eax,%edi
  802639:	89 c8                	mov    %ecx,%eax
  80263b:	f7 f6                	div    %esi
  80263d:	89 c1                	mov    %eax,%ecx
  80263f:	89 fa                	mov    %edi,%edx
  802641:	89 c8                	mov    %ecx,%eax
  802643:	83 c4 10             	add    $0x10,%esp
  802646:	5e                   	pop    %esi
  802647:	5f                   	pop    %edi
  802648:	5d                   	pop    %ebp
  802649:	c3                   	ret    
  80264a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802650:	39 f8                	cmp    %edi,%eax
  802652:	77 1c                	ja     802670 <__udivdi3+0x70>
  802654:	0f bd d0             	bsr    %eax,%edx
  802657:	83 f2 1f             	xor    $0x1f,%edx
  80265a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80265d:	75 39                	jne    802698 <__udivdi3+0x98>
  80265f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802662:	0f 86 a0 00 00 00    	jbe    802708 <__udivdi3+0x108>
  802668:	39 f8                	cmp    %edi,%eax
  80266a:	0f 82 98 00 00 00    	jb     802708 <__udivdi3+0x108>
  802670:	31 ff                	xor    %edi,%edi
  802672:	31 c9                	xor    %ecx,%ecx
  802674:	89 c8                	mov    %ecx,%eax
  802676:	89 fa                	mov    %edi,%edx
  802678:	83 c4 10             	add    $0x10,%esp
  80267b:	5e                   	pop    %esi
  80267c:	5f                   	pop    %edi
  80267d:	5d                   	pop    %ebp
  80267e:	c3                   	ret    
  80267f:	90                   	nop
  802680:	89 d1                	mov    %edx,%ecx
  802682:	89 fa                	mov    %edi,%edx
  802684:	89 c8                	mov    %ecx,%eax
  802686:	31 ff                	xor    %edi,%edi
  802688:	f7 f6                	div    %esi
  80268a:	89 c1                	mov    %eax,%ecx
  80268c:	89 fa                	mov    %edi,%edx
  80268e:	89 c8                	mov    %ecx,%eax
  802690:	83 c4 10             	add    $0x10,%esp
  802693:	5e                   	pop    %esi
  802694:	5f                   	pop    %edi
  802695:	5d                   	pop    %ebp
  802696:	c3                   	ret    
  802697:	90                   	nop
  802698:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80269c:	89 f2                	mov    %esi,%edx
  80269e:	d3 e0                	shl    %cl,%eax
  8026a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8026a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8026ab:	89 c1                	mov    %eax,%ecx
  8026ad:	d3 ea                	shr    %cl,%edx
  8026af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8026b6:	d3 e6                	shl    %cl,%esi
  8026b8:	89 c1                	mov    %eax,%ecx
  8026ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8026bd:	89 fe                	mov    %edi,%esi
  8026bf:	d3 ee                	shr    %cl,%esi
  8026c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026cb:	d3 e7                	shl    %cl,%edi
  8026cd:	89 c1                	mov    %eax,%ecx
  8026cf:	d3 ea                	shr    %cl,%edx
  8026d1:	09 d7                	or     %edx,%edi
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	89 f8                	mov    %edi,%eax
  8026d7:	f7 75 ec             	divl   -0x14(%ebp)
  8026da:	89 d6                	mov    %edx,%esi
  8026dc:	89 c7                	mov    %eax,%edi
  8026de:	f7 65 e8             	mull   -0x18(%ebp)
  8026e1:	39 d6                	cmp    %edx,%esi
  8026e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026e6:	72 30                	jb     802718 <__udivdi3+0x118>
  8026e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026ef:	d3 e2                	shl    %cl,%edx
  8026f1:	39 c2                	cmp    %eax,%edx
  8026f3:	73 05                	jae    8026fa <__udivdi3+0xfa>
  8026f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8026f8:	74 1e                	je     802718 <__udivdi3+0x118>
  8026fa:	89 f9                	mov    %edi,%ecx
  8026fc:	31 ff                	xor    %edi,%edi
  8026fe:	e9 71 ff ff ff       	jmp    802674 <__udivdi3+0x74>
  802703:	90                   	nop
  802704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802708:	31 ff                	xor    %edi,%edi
  80270a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80270f:	e9 60 ff ff ff       	jmp    802674 <__udivdi3+0x74>
  802714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802718:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80271b:	31 ff                	xor    %edi,%edi
  80271d:	89 c8                	mov    %ecx,%eax
  80271f:	89 fa                	mov    %edi,%edx
  802721:	83 c4 10             	add    $0x10,%esp
  802724:	5e                   	pop    %esi
  802725:	5f                   	pop    %edi
  802726:	5d                   	pop    %ebp
  802727:	c3                   	ret    
	...

00802730 <__umoddi3>:
  802730:	55                   	push   %ebp
  802731:	89 e5                	mov    %esp,%ebp
  802733:	57                   	push   %edi
  802734:	56                   	push   %esi
  802735:	83 ec 20             	sub    $0x20,%esp
  802738:	8b 55 14             	mov    0x14(%ebp),%edx
  80273b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80273e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802741:	8b 75 0c             	mov    0xc(%ebp),%esi
  802744:	85 d2                	test   %edx,%edx
  802746:	89 c8                	mov    %ecx,%eax
  802748:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80274b:	75 13                	jne    802760 <__umoddi3+0x30>
  80274d:	39 f7                	cmp    %esi,%edi
  80274f:	76 3f                	jbe    802790 <__umoddi3+0x60>
  802751:	89 f2                	mov    %esi,%edx
  802753:	f7 f7                	div    %edi
  802755:	89 d0                	mov    %edx,%eax
  802757:	31 d2                	xor    %edx,%edx
  802759:	83 c4 20             	add    $0x20,%esp
  80275c:	5e                   	pop    %esi
  80275d:	5f                   	pop    %edi
  80275e:	5d                   	pop    %ebp
  80275f:	c3                   	ret    
  802760:	39 f2                	cmp    %esi,%edx
  802762:	77 4c                	ja     8027b0 <__umoddi3+0x80>
  802764:	0f bd ca             	bsr    %edx,%ecx
  802767:	83 f1 1f             	xor    $0x1f,%ecx
  80276a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80276d:	75 51                	jne    8027c0 <__umoddi3+0x90>
  80276f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802772:	0f 87 e0 00 00 00    	ja     802858 <__umoddi3+0x128>
  802778:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80277b:	29 f8                	sub    %edi,%eax
  80277d:	19 d6                	sbb    %edx,%esi
  80277f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802785:	89 f2                	mov    %esi,%edx
  802787:	83 c4 20             	add    $0x20,%esp
  80278a:	5e                   	pop    %esi
  80278b:	5f                   	pop    %edi
  80278c:	5d                   	pop    %ebp
  80278d:	c3                   	ret    
  80278e:	66 90                	xchg   %ax,%ax
  802790:	85 ff                	test   %edi,%edi
  802792:	75 0b                	jne    80279f <__umoddi3+0x6f>
  802794:	b8 01 00 00 00       	mov    $0x1,%eax
  802799:	31 d2                	xor    %edx,%edx
  80279b:	f7 f7                	div    %edi
  80279d:	89 c7                	mov    %eax,%edi
  80279f:	89 f0                	mov    %esi,%eax
  8027a1:	31 d2                	xor    %edx,%edx
  8027a3:	f7 f7                	div    %edi
  8027a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027a8:	f7 f7                	div    %edi
  8027aa:	eb a9                	jmp    802755 <__umoddi3+0x25>
  8027ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b0:	89 c8                	mov    %ecx,%eax
  8027b2:	89 f2                	mov    %esi,%edx
  8027b4:	83 c4 20             	add    $0x20,%esp
  8027b7:	5e                   	pop    %esi
  8027b8:	5f                   	pop    %edi
  8027b9:	5d                   	pop    %ebp
  8027ba:	c3                   	ret    
  8027bb:	90                   	nop
  8027bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027c4:	d3 e2                	shl    %cl,%edx
  8027c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8027ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8027d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027d8:	89 fa                	mov    %edi,%edx
  8027da:	d3 ea                	shr    %cl,%edx
  8027dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8027e3:	d3 e7                	shl    %cl,%edi
  8027e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027ec:	89 f2                	mov    %esi,%edx
  8027ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8027f1:	89 c7                	mov    %eax,%edi
  8027f3:	d3 ea                	shr    %cl,%edx
  8027f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8027fc:	89 c2                	mov    %eax,%edx
  8027fe:	d3 e6                	shl    %cl,%esi
  802800:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802804:	d3 ea                	shr    %cl,%edx
  802806:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80280a:	09 d6                	or     %edx,%esi
  80280c:	89 f0                	mov    %esi,%eax
  80280e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802811:	d3 e7                	shl    %cl,%edi
  802813:	89 f2                	mov    %esi,%edx
  802815:	f7 75 f4             	divl   -0xc(%ebp)
  802818:	89 d6                	mov    %edx,%esi
  80281a:	f7 65 e8             	mull   -0x18(%ebp)
  80281d:	39 d6                	cmp    %edx,%esi
  80281f:	72 2b                	jb     80284c <__umoddi3+0x11c>
  802821:	39 c7                	cmp    %eax,%edi
  802823:	72 23                	jb     802848 <__umoddi3+0x118>
  802825:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802829:	29 c7                	sub    %eax,%edi
  80282b:	19 d6                	sbb    %edx,%esi
  80282d:	89 f0                	mov    %esi,%eax
  80282f:	89 f2                	mov    %esi,%edx
  802831:	d3 ef                	shr    %cl,%edi
  802833:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802837:	d3 e0                	shl    %cl,%eax
  802839:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80283d:	09 f8                	or     %edi,%eax
  80283f:	d3 ea                	shr    %cl,%edx
  802841:	83 c4 20             	add    $0x20,%esp
  802844:	5e                   	pop    %esi
  802845:	5f                   	pop    %edi
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    
  802848:	39 d6                	cmp    %edx,%esi
  80284a:	75 d9                	jne    802825 <__umoddi3+0xf5>
  80284c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80284f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802852:	eb d1                	jmp    802825 <__umoddi3+0xf5>
  802854:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802858:	39 f2                	cmp    %esi,%edx
  80285a:	0f 82 18 ff ff ff    	jb     802778 <__umoddi3+0x48>
  802860:	e9 1d ff ff ff       	jmp    802782 <__umoddi3+0x52>
