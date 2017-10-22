
obj/user/pingpong:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 e0 13 00 00       	call   801422 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 05 13 00 00       	call   801355 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 40 1c 80 00 	movl   $0x801c40,(%esp)
  80005f:	e8 5d 01 00 00       	call   8001c1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 74 17 00 00       	call   8017fb <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 d7 17 00 00       	call   801879 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 a9 12 00 00       	call   801355 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 56 1c 80 00 	movl   $0x801c56,(%esp)
  8000bf:	e8 fd 00 00 00       	call   8001c1 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 10 17 00 00       	call   8017fb <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

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
  80010a:	e8 46 12 00 00       	call   801355 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	89 c2                	mov    %eax,%edx
  800116:	c1 e2 07             	shl    $0x7,%edx
  800119:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800120:	a3 04 30 80 00       	mov    %eax,0x803004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x38>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800159:	e8 37 12 00 00       	call   801395 <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	c7 04 24 db 01 80 00 	movl   $0x8001db,(%esp)
  80019c:	e8 cb 01 00 00       	call   80036c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 63 0d 00 00       	call   800f1c <sys_cputs>

	return b.cnt;
}
  8001b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001c7:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 87 ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	53                   	push   %ebx
  8001df:	83 ec 14             	sub    $0x14,%esp
  8001e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e5:	8b 03                	mov    (%ebx),%eax
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ee:	83 c0 01             	add    $0x1,%eax
  8001f1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f8:	75 19                	jne    800213 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800201:	00 
  800202:	8d 43 08             	lea    0x8(%ebx),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 0f 0d 00 00       	call   800f1c <sys_cputs>
		b->idx = 0;
  80020d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	83 c4 14             	add    $0x14,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 4c             	sub    $0x4c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800240:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800243:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800246:	b9 00 00 00 00       	mov    $0x0,%ecx
  80024b:	39 d1                	cmp    %edx,%ecx
  80024d:	72 07                	jb     800256 <printnum_v2+0x36>
  80024f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800252:	39 d0                	cmp    %edx,%eax
  800254:	77 5f                	ja     8002b5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800256:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80025a:	83 eb 01             	sub    $0x1,%ebx
  80025d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800261:	89 44 24 08          	mov    %eax,0x8(%esp)
  800265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800269:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80026d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800270:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800273:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800276:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800281:	00 
  800282:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80028b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028f:	e8 3c 17 00 00       	call   8019d0 <__udivdi3>
  800294:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800297:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80029a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80029e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a2:	89 04 24             	mov    %eax,(%esp)
  8002a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a9:	89 f2                	mov    %esi,%edx
  8002ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ae:	e8 6d ff ff ff       	call   800220 <printnum_v2>
  8002b3:	eb 1e                	jmp    8002d3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8002b5:	83 ff 2d             	cmp    $0x2d,%edi
  8002b8:	74 19                	je     8002d3 <printnum_v2+0xb3>
		while (--width > 0)
  8002ba:	83 eb 01             	sub    $0x1,%ebx
  8002bd:	85 db                	test   %ebx,%ebx
  8002bf:	90                   	nop
  8002c0:	7e 11                	jle    8002d3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8002c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c6:	89 3c 24             	mov    %edi,(%esp)
  8002c9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8002cc:	83 eb 01             	sub    $0x1,%ebx
  8002cf:	85 db                	test   %ebx,%ebx
  8002d1:	7f ef                	jg     8002c2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e9:	00 
  8002ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002ed:	89 14 24             	mov    %edx,(%esp)
  8002f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002f7:	e8 04 18 00 00       	call   801b00 <__umoddi3>
  8002fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800300:	0f be 80 73 1c 80 00 	movsbl 0x801c73(%eax),%eax
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80030d:	83 c4 4c             	add    $0x4c,%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800318:	83 fa 01             	cmp    $0x1,%edx
  80031b:	7e 0e                	jle    80032b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	8b 52 04             	mov    0x4(%edx),%edx
  800329:	eb 22                	jmp    80034d <getuint+0x38>
	else if (lflag)
  80032b:	85 d2                	test   %edx,%edx
  80032d:	74 10                	je     80033f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	8d 4a 04             	lea    0x4(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 02                	mov    (%edx),%eax
  800338:	ba 00 00 00 00       	mov    $0x0,%edx
  80033d:	eb 0e                	jmp    80034d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	8d 4a 04             	lea    0x4(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 02                	mov    (%edx),%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800363:	88 0a                	mov    %cl,(%edx)
  800365:	83 c2 01             	add    $0x1,%edx
  800368:	89 10                	mov    %edx,(%eax)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
  800372:	83 ec 6c             	sub    $0x6c,%esp
  800375:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800378:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80037f:	eb 1a                	jmp    80039b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800381:	85 c0                	test   %eax,%eax
  800383:	0f 84 66 06 00 00    	je     8009ef <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800389:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800390:	89 04 24             	mov    %eax,(%esp)
  800393:	ff 55 08             	call   *0x8(%ebp)
  800396:	eb 03                	jmp    80039b <vprintfmt+0x2f>
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039b:	0f b6 07             	movzbl (%edi),%eax
  80039e:	83 c7 01             	add    $0x1,%edi
  8003a1:	83 f8 25             	cmp    $0x25,%eax
  8003a4:	75 db                	jne    800381 <vprintfmt+0x15>
  8003a6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8003aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003af:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003b6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8003bb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c2:	be 00 00 00 00       	mov    $0x0,%esi
  8003c7:	eb 06                	jmp    8003cf <vprintfmt+0x63>
  8003c9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8003cd:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	0f b6 17             	movzbl (%edi),%edx
  8003d2:	0f b6 c2             	movzbl %dl,%eax
  8003d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d8:	8d 47 01             	lea    0x1(%edi),%eax
  8003db:	83 ea 23             	sub    $0x23,%edx
  8003de:	80 fa 55             	cmp    $0x55,%dl
  8003e1:	0f 87 60 05 00 00    	ja     800947 <vprintfmt+0x5db>
  8003e7:	0f b6 d2             	movzbl %dl,%edx
  8003ea:	ff 24 95 c0 1d 80 00 	jmp    *0x801dc0(,%edx,4)
  8003f1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8003f6:	eb d5                	jmp    8003cd <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003fb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8003fe:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800401:	8d 7a d0             	lea    -0x30(%edx),%edi
  800404:	83 ff 09             	cmp    $0x9,%edi
  800407:	76 08                	jbe    800411 <vprintfmt+0xa5>
  800409:	eb 40                	jmp    80044b <vprintfmt+0xdf>
  80040b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80040f:	eb bc                	jmp    8003cd <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800414:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800417:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80041b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80041e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800421:	83 ff 09             	cmp    $0x9,%edi
  800424:	76 eb                	jbe    800411 <vprintfmt+0xa5>
  800426:	eb 23                	jmp    80044b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800428:	8b 55 14             	mov    0x14(%ebp),%edx
  80042b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80042e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800431:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800433:	eb 16                	jmp    80044b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800435:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800438:	c1 fa 1f             	sar    $0x1f,%edx
  80043b:	f7 d2                	not    %edx
  80043d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800440:	eb 8b                	jmp    8003cd <vprintfmt+0x61>
  800442:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800449:	eb 82                	jmp    8003cd <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80044b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044f:	0f 89 78 ff ff ff    	jns    8003cd <vprintfmt+0x61>
  800455:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800458:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80045b:	e9 6d ff ff ff       	jmp    8003cd <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800460:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800463:	e9 65 ff ff ff       	jmp    8003cd <vprintfmt+0x61>
  800468:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	8b 55 0c             	mov    0xc(%ebp),%edx
  800477:	89 54 24 04          	mov    %edx,0x4(%esp)
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	89 04 24             	mov    %eax,(%esp)
  800480:	ff 55 08             	call   *0x8(%ebp)
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800486:	e9 10 ff ff ff       	jmp    80039b <vprintfmt+0x2f>
  80048b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 50 04             	lea    0x4(%eax),%edx
  800494:	89 55 14             	mov    %edx,0x14(%ebp)
  800497:	8b 00                	mov    (%eax),%eax
  800499:	89 c2                	mov    %eax,%edx
  80049b:	c1 fa 1f             	sar    $0x1f,%edx
  80049e:	31 d0                	xor    %edx,%eax
  8004a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a2:	83 f8 08             	cmp    $0x8,%eax
  8004a5:	7f 0b                	jg     8004b2 <vprintfmt+0x146>
  8004a7:	8b 14 85 20 1f 80 00 	mov    0x801f20(,%eax,4),%edx
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	75 26                	jne    8004d8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b6:	c7 44 24 08 84 1c 80 	movl   $0x801c84,0x8(%esp)
  8004bd:	00 
  8004be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004c8:	89 1c 24             	mov    %ebx,(%esp)
  8004cb:	e8 a7 05 00 00       	call   800a77 <printfmt>
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d3:	e9 c3 fe ff ff       	jmp    80039b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004dc:	c7 44 24 08 8d 1c 80 	movl   $0x801c8d,0x8(%esp)
  8004e3:	00 
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ee:	89 14 24             	mov    %edx,(%esp)
  8004f1:	e8 81 05 00 00       	call   800a77 <printfmt>
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f9:	e9 9d fe ff ff       	jmp    80039b <vprintfmt+0x2f>
  8004fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800501:	89 c7                	mov    %eax,%edi
  800503:	89 d9                	mov    %ebx,%ecx
  800505:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800508:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 04             	lea    0x4(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 30                	mov    (%eax),%esi
  800516:	85 f6                	test   %esi,%esi
  800518:	75 05                	jne    80051f <vprintfmt+0x1b3>
  80051a:	be 90 1c 80 00       	mov    $0x801c90,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80051f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800523:	7e 06                	jle    80052b <vprintfmt+0x1bf>
  800525:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800529:	75 10                	jne    80053b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052b:	0f be 06             	movsbl (%esi),%eax
  80052e:	85 c0                	test   %eax,%eax
  800530:	0f 85 a2 00 00 00    	jne    8005d8 <vprintfmt+0x26c>
  800536:	e9 92 00 00 00       	jmp    8005cd <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053f:	89 34 24             	mov    %esi,(%esp)
  800542:	e8 74 05 00 00       	call   800abb <strnlen>
  800547:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80054a:	29 c2                	sub    %eax,%edx
  80054c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80054f:	85 d2                	test   %edx,%edx
  800551:	7e d8                	jle    80052b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800553:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800557:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80055a:	89 d3                	mov    %edx,%ebx
  80055c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80055f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800562:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800565:	89 ce                	mov    %ecx,%esi
  800567:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056b:	89 34 24             	mov    %esi,(%esp)
  80056e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800571:	83 eb 01             	sub    $0x1,%ebx
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f ef                	jg     800567 <vprintfmt+0x1fb>
  800578:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80057b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80057e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800581:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800588:	eb a1                	jmp    80052b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80058e:	74 1b                	je     8005ab <vprintfmt+0x23f>
  800590:	8d 50 e0             	lea    -0x20(%eax),%edx
  800593:	83 fa 5e             	cmp    $0x5e,%edx
  800596:	76 13                	jbe    8005ab <vprintfmt+0x23f>
					putch('?', putdat);
  800598:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a9:	eb 0d                	jmp    8005b8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b2:	89 04 24             	mov    %eax,(%esp)
  8005b5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b8:	83 ef 01             	sub    $0x1,%edi
  8005bb:	0f be 06             	movsbl (%esi),%eax
  8005be:	85 c0                	test   %eax,%eax
  8005c0:	74 05                	je     8005c7 <vprintfmt+0x25b>
  8005c2:	83 c6 01             	add    $0x1,%esi
  8005c5:	eb 1a                	jmp    8005e1 <vprintfmt+0x275>
  8005c7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005ca:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d1:	7f 1f                	jg     8005f2 <vprintfmt+0x286>
  8005d3:	e9 c0 fd ff ff       	jmp    800398 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d8:	83 c6 01             	add    $0x1,%esi
  8005db:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005de:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005e1:	85 db                	test   %ebx,%ebx
  8005e3:	78 a5                	js     80058a <vprintfmt+0x21e>
  8005e5:	83 eb 01             	sub    $0x1,%ebx
  8005e8:	79 a0                	jns    80058a <vprintfmt+0x21e>
  8005ea:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005ed:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f0:	eb db                	jmp    8005cd <vprintfmt+0x261>
  8005f2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005f8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005fb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800602:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800609:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	83 eb 01             	sub    $0x1,%ebx
  80060e:	85 db                	test   %ebx,%ebx
  800610:	7f ec                	jg     8005fe <vprintfmt+0x292>
  800612:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800615:	e9 81 fd ff ff       	jmp    80039b <vprintfmt+0x2f>
  80061a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061d:	83 fe 01             	cmp    $0x1,%esi
  800620:	7e 10                	jle    800632 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 08             	lea    0x8(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 18                	mov    (%eax),%ebx
  80062d:	8b 70 04             	mov    0x4(%eax),%esi
  800630:	eb 26                	jmp    800658 <vprintfmt+0x2ec>
	else if (lflag)
  800632:	85 f6                	test   %esi,%esi
  800634:	74 12                	je     800648 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 50 04             	lea    0x4(%eax),%edx
  80063c:	89 55 14             	mov    %edx,0x14(%ebp)
  80063f:	8b 18                	mov    (%eax),%ebx
  800641:	89 de                	mov    %ebx,%esi
  800643:	c1 fe 1f             	sar    $0x1f,%esi
  800646:	eb 10                	jmp    800658 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 04             	lea    0x4(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	8b 18                	mov    (%eax),%ebx
  800653:	89 de                	mov    %ebx,%esi
  800655:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800658:	83 f9 01             	cmp    $0x1,%ecx
  80065b:	75 1e                	jne    80067b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80065d:	85 f6                	test   %esi,%esi
  80065f:	78 1a                	js     80067b <vprintfmt+0x30f>
  800661:	85 f6                	test   %esi,%esi
  800663:	7f 05                	jg     80066a <vprintfmt+0x2fe>
  800665:	83 fb 00             	cmp    $0x0,%ebx
  800668:	76 11                	jbe    80067b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80066a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80066d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800671:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800678:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80067b:	85 f6                	test   %esi,%esi
  80067d:	78 13                	js     800692 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800682:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800688:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068d:	e9 da 00 00 00       	jmp    80076c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800692:	8b 45 0c             	mov    0xc(%ebp),%eax
  800695:	89 44 24 04          	mov    %eax,0x4(%esp)
  800699:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006a3:	89 da                	mov    %ebx,%edx
  8006a5:	89 f1                	mov    %esi,%ecx
  8006a7:	f7 da                	neg    %edx
  8006a9:	83 d1 00             	adc    $0x0,%ecx
  8006ac:	f7 d9                	neg    %ecx
  8006ae:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006b1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bc:	e9 ab 00 00 00       	jmp    80076c <vprintfmt+0x400>
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c4:	89 f2                	mov    %esi,%edx
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 47 fc ff ff       	call   800315 <getuint>
  8006ce:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006d1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006dc:	e9 8b 00 00 00       	jmp    80076c <vprintfmt+0x400>
  8006e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006eb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8006f5:	89 f2                	mov    %esi,%edx
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	e8 16 fc ff ff       	call   800315 <getuint>
  8006ff:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800702:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800708:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80070d:	eb 5d                	jmp    80076c <vprintfmt+0x400>
  80070f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800715:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800719:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800720:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800723:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800727:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 10                	mov    (%eax),%edx
  80073c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800741:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800744:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80074f:	eb 1b                	jmp    80076c <vprintfmt+0x400>
  800751:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800754:	89 f2                	mov    %esi,%edx
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 b7 fb ff ff       	call   800315 <getuint>
  80075e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800761:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800764:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800767:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80076c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800770:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800773:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800776:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80077a:	77 09                	ja     800785 <vprintfmt+0x419>
  80077c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80077f:	0f 82 ac 00 00 00    	jb     800831 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800785:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800788:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80078c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80078f:	83 ea 01             	sub    $0x1,%edx
  800792:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800796:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80079e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8007a2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8007a5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8007a8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007b6:	00 
  8007b7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007ba:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007bd:	89 0c 24             	mov    %ecx,(%esp)
  8007c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c4:	e8 07 12 00 00       	call   8019d0 <__udivdi3>
  8007c9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8007cc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8007cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	e8 37 fa ff ff       	call   800220 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007f4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800802:	00 
  800803:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800806:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800809:	89 14 24             	mov    %edx,(%esp)
  80080c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800810:	e8 eb 12 00 00       	call   801b00 <__umoddi3>
  800815:	89 74 24 04          	mov    %esi,0x4(%esp)
  800819:	0f be 80 73 1c 80 00 	movsbl 0x801c73(%eax),%eax
  800820:	89 04 24             	mov    %eax,(%esp)
  800823:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800826:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80082a:	74 54                	je     800880 <vprintfmt+0x514>
  80082c:	e9 67 fb ff ff       	jmp    800398 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800831:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800835:	8d 76 00             	lea    0x0(%esi),%esi
  800838:	0f 84 2a 01 00 00    	je     800968 <vprintfmt+0x5fc>
		while (--width > 0)
  80083e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800841:	83 ef 01             	sub    $0x1,%edi
  800844:	85 ff                	test   %edi,%edi
  800846:	0f 8e 5e 01 00 00    	jle    8009aa <vprintfmt+0x63e>
  80084c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80084f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800852:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800855:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800858:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80085b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80085e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800862:	89 1c 24             	mov    %ebx,(%esp)
  800865:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800868:	83 ef 01             	sub    $0x1,%edi
  80086b:	85 ff                	test   %edi,%edi
  80086d:	7f ef                	jg     80085e <vprintfmt+0x4f2>
  80086f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800872:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800875:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800878:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80087b:	e9 2a 01 00 00       	jmp    8009aa <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800880:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800883:	83 eb 01             	sub    $0x1,%ebx
  800886:	85 db                	test   %ebx,%ebx
  800888:	0f 8e 0a fb ff ff    	jle    800398 <vprintfmt+0x2c>
  80088e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800891:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800894:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800897:	89 74 24 04          	mov    %esi,0x4(%esp)
  80089b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008a2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008a4:	83 eb 01             	sub    $0x1,%ebx
  8008a7:	85 db                	test   %ebx,%ebx
  8008a9:	7f ec                	jg     800897 <vprintfmt+0x52b>
  8008ab:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008ae:	e9 e8 fa ff ff       	jmp    80039b <vprintfmt+0x2f>
  8008b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8d 50 04             	lea    0x4(%eax),%edx
  8008bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bf:	8b 00                	mov    (%eax),%eax
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	75 2a                	jne    8008ef <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8008c5:	c7 44 24 0c 2c 1d 80 	movl   $0x801d2c,0xc(%esp)
  8008cc:	00 
  8008cd:	c7 44 24 08 8d 1c 80 	movl   $0x801c8d,0x8(%esp)
  8008d4:	00 
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008df:	89 0c 24             	mov    %ecx,(%esp)
  8008e2:	e8 90 01 00 00       	call   800a77 <printfmt>
  8008e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ea:	e9 ac fa ff ff       	jmp    80039b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8008ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f2:	8b 13                	mov    (%ebx),%edx
  8008f4:	83 fa 7f             	cmp    $0x7f,%edx
  8008f7:	7e 29                	jle    800922 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8008f9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8008fb:	c7 44 24 0c 64 1d 80 	movl   $0x801d64,0xc(%esp)
  800902:	00 
  800903:	c7 44 24 08 8d 1c 80 	movl   $0x801c8d,0x8(%esp)
  80090a:	00 
  80090b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	e8 5d 01 00 00       	call   800a77 <printfmt>
  80091a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091d:	e9 79 fa ff ff       	jmp    80039b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800922:	88 10                	mov    %dl,(%eax)
  800924:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800927:	e9 6f fa ff ff       	jmp    80039b <vprintfmt+0x2f>
  80092c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80092f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800935:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800939:	89 14 24             	mov    %edx,(%esp)
  80093c:	ff 55 08             	call   *0x8(%ebp)
  80093f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800942:	e9 54 fa ff ff       	jmp    80039b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800947:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800955:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800958:	8d 47 ff             	lea    -0x1(%edi),%eax
  80095b:	80 38 25             	cmpb   $0x25,(%eax)
  80095e:	0f 84 37 fa ff ff    	je     80039b <vprintfmt+0x2f>
  800964:	89 c7                	mov    %eax,%edi
  800966:	eb f0                	jmp    800958 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800973:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800976:	89 54 24 08          	mov    %edx,0x8(%esp)
  80097a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800981:	00 
  800982:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800985:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800988:	89 04 24             	mov    %eax,(%esp)
  80098b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80098f:	e8 6c 11 00 00       	call   801b00 <__umoddi3>
  800994:	89 74 24 04          	mov    %esi,0x4(%esp)
  800998:	0f be 80 73 1c 80 00 	movsbl 0x801c73(%eax),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	ff 55 08             	call   *0x8(%ebp)
  8009a5:	e9 d6 fe ff ff       	jmp    800880 <vprintfmt+0x514>
  8009aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009c3:	00 
  8009c4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009c7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009ca:	89 04 24             	mov    %eax,(%esp)
  8009cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d1:	e8 2a 11 00 00       	call   801b00 <__umoddi3>
  8009d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009da:	0f be 80 73 1c 80 00 	movsbl 0x801c73(%eax),%eax
  8009e1:	89 04 24             	mov    %eax,(%esp)
  8009e4:	ff 55 08             	call   *0x8(%ebp)
  8009e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ea:	e9 ac f9 ff ff       	jmp    80039b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009ef:	83 c4 6c             	add    $0x6c,%esp
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 28             	sub    $0x28,%esp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a03:	85 c0                	test   %eax,%eax
  800a05:	74 04                	je     800a0b <vsnprintf+0x14>
  800a07:	85 d2                	test   %edx,%edx
  800a09:	7f 07                	jg     800a12 <vsnprintf+0x1b>
  800a0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a10:	eb 3b                	jmp    800a4d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a15:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a31:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a38:	c7 04 24 4f 03 80 00 	movl   $0x80034f,(%esp)
  800a3f:	e8 28 f9 ff ff       	call   80036c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a47:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a55:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	89 04 24             	mov    %eax,(%esp)
  800a70:	e8 82 ff ff ff       	call   8009f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a7d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a84:	8b 45 10             	mov    0x10(%ebp),%eax
  800a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	89 04 24             	mov    %eax,(%esp)
  800a98:	e8 cf f8 ff ff       	call   80036c <vprintfmt>
	va_end(ap);
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    
	...

00800aa0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	80 3a 00             	cmpb   $0x0,(%edx)
  800aae:	74 09                	je     800ab9 <strlen+0x19>
		n++;
  800ab0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ab7:	75 f7                	jne    800ab0 <strlen+0x10>
		n++;
	return n;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ac2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ac5:	85 c9                	test   %ecx,%ecx
  800ac7:	74 19                	je     800ae2 <strnlen+0x27>
  800ac9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800acc:	74 14                	je     800ae2 <strnlen+0x27>
  800ace:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ad3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad6:	39 c8                	cmp    %ecx,%eax
  800ad8:	74 0d                	je     800ae7 <strnlen+0x2c>
  800ada:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800ade:	75 f3                	jne    800ad3 <strnlen+0x18>
  800ae0:	eb 05                	jmp    800ae7 <strnlen+0x2c>
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	53                   	push   %ebx
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800af9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800afd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b00:	83 c2 01             	add    $0x1,%edx
  800b03:	84 c9                	test   %cl,%cl
  800b05:	75 f2                	jne    800af9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b07:	5b                   	pop    %ebx
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 08             	sub    $0x8,%esp
  800b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b14:	89 1c 24             	mov    %ebx,(%esp)
  800b17:	e8 84 ff ff ff       	call   800aa0 <strlen>
	strcpy(dst + len, src);
  800b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b23:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b26:	89 04 24             	mov    %eax,(%esp)
  800b29:	e8 bc ff ff ff       	call   800aea <strcpy>
	return dst;
}
  800b2e:	89 d8                	mov    %ebx,%eax
  800b30:	83 c4 08             	add    $0x8,%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b44:	85 f6                	test   %esi,%esi
  800b46:	74 18                	je     800b60 <strncpy+0x2a>
  800b48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b4d:	0f b6 1a             	movzbl (%edx),%ebx
  800b50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b53:	80 3a 01             	cmpb   $0x1,(%edx)
  800b56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b59:	83 c1 01             	add    $0x1,%ecx
  800b5c:	39 ce                	cmp    %ecx,%esi
  800b5e:	77 ed                	ja     800b4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b72:	89 f0                	mov    %esi,%eax
  800b74:	85 c9                	test   %ecx,%ecx
  800b76:	74 27                	je     800b9f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b78:	83 e9 01             	sub    $0x1,%ecx
  800b7b:	74 1d                	je     800b9a <strlcpy+0x36>
  800b7d:	0f b6 1a             	movzbl (%edx),%ebx
  800b80:	84 db                	test   %bl,%bl
  800b82:	74 16                	je     800b9a <strlcpy+0x36>
			*dst++ = *src++;
  800b84:	88 18                	mov    %bl,(%eax)
  800b86:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b89:	83 e9 01             	sub    $0x1,%ecx
  800b8c:	74 0e                	je     800b9c <strlcpy+0x38>
			*dst++ = *src++;
  800b8e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b91:	0f b6 1a             	movzbl (%edx),%ebx
  800b94:	84 db                	test   %bl,%bl
  800b96:	75 ec                	jne    800b84 <strlcpy+0x20>
  800b98:	eb 02                	jmp    800b9c <strlcpy+0x38>
  800b9a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b9c:	c6 00 00             	movb   $0x0,(%eax)
  800b9f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bae:	0f b6 01             	movzbl (%ecx),%eax
  800bb1:	84 c0                	test   %al,%al
  800bb3:	74 15                	je     800bca <strcmp+0x25>
  800bb5:	3a 02                	cmp    (%edx),%al
  800bb7:	75 11                	jne    800bca <strcmp+0x25>
		p++, q++;
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bbf:	0f b6 01             	movzbl (%ecx),%eax
  800bc2:	84 c0                	test   %al,%al
  800bc4:	74 04                	je     800bca <strcmp+0x25>
  800bc6:	3a 02                	cmp    (%edx),%al
  800bc8:	74 ef                	je     800bb9 <strcmp+0x14>
  800bca:	0f b6 c0             	movzbl %al,%eax
  800bcd:	0f b6 12             	movzbl (%edx),%edx
  800bd0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	53                   	push   %ebx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	74 23                	je     800c08 <strncmp+0x34>
  800be5:	0f b6 1a             	movzbl (%edx),%ebx
  800be8:	84 db                	test   %bl,%bl
  800bea:	74 25                	je     800c11 <strncmp+0x3d>
  800bec:	3a 19                	cmp    (%ecx),%bl
  800bee:	75 21                	jne    800c11 <strncmp+0x3d>
  800bf0:	83 e8 01             	sub    $0x1,%eax
  800bf3:	74 13                	je     800c08 <strncmp+0x34>
		n--, p++, q++;
  800bf5:	83 c2 01             	add    $0x1,%edx
  800bf8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bfb:	0f b6 1a             	movzbl (%edx),%ebx
  800bfe:	84 db                	test   %bl,%bl
  800c00:	74 0f                	je     800c11 <strncmp+0x3d>
  800c02:	3a 19                	cmp    (%ecx),%bl
  800c04:	74 ea                	je     800bf0 <strncmp+0x1c>
  800c06:	eb 09                	jmp    800c11 <strncmp+0x3d>
  800c08:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5d                   	pop    %ebp
  800c0f:	90                   	nop
  800c10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c11:	0f b6 02             	movzbl (%edx),%eax
  800c14:	0f b6 11             	movzbl (%ecx),%edx
  800c17:	29 d0                	sub    %edx,%eax
  800c19:	eb f2                	jmp    800c0d <strncmp+0x39>

00800c1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c25:	0f b6 10             	movzbl (%eax),%edx
  800c28:	84 d2                	test   %dl,%dl
  800c2a:	74 18                	je     800c44 <strchr+0x29>
		if (*s == c)
  800c2c:	38 ca                	cmp    %cl,%dl
  800c2e:	75 0a                	jne    800c3a <strchr+0x1f>
  800c30:	eb 17                	jmp    800c49 <strchr+0x2e>
  800c32:	38 ca                	cmp    %cl,%dl
  800c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c38:	74 0f                	je     800c49 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c3a:	83 c0 01             	add    $0x1,%eax
  800c3d:	0f b6 10             	movzbl (%eax),%edx
  800c40:	84 d2                	test   %dl,%dl
  800c42:	75 ee                	jne    800c32 <strchr+0x17>
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c55:	0f b6 10             	movzbl (%eax),%edx
  800c58:	84 d2                	test   %dl,%dl
  800c5a:	74 18                	je     800c74 <strfind+0x29>
		if (*s == c)
  800c5c:	38 ca                	cmp    %cl,%dl
  800c5e:	75 0a                	jne    800c6a <strfind+0x1f>
  800c60:	eb 12                	jmp    800c74 <strfind+0x29>
  800c62:	38 ca                	cmp    %cl,%dl
  800c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c68:	74 0a                	je     800c74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c6a:	83 c0 01             	add    $0x1,%eax
  800c6d:	0f b6 10             	movzbl (%eax),%edx
  800c70:	84 d2                	test   %dl,%dl
  800c72:	75 ee                	jne    800c62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	89 1c 24             	mov    %ebx,(%esp)
  800c7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c90:	85 c9                	test   %ecx,%ecx
  800c92:	74 30                	je     800cc4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9a:	75 25                	jne    800cc1 <memset+0x4b>
  800c9c:	f6 c1 03             	test   $0x3,%cl
  800c9f:	75 20                	jne    800cc1 <memset+0x4b>
		c &= 0xFF;
  800ca1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca4:	89 d3                	mov    %edx,%ebx
  800ca6:	c1 e3 08             	shl    $0x8,%ebx
  800ca9:	89 d6                	mov    %edx,%esi
  800cab:	c1 e6 18             	shl    $0x18,%esi
  800cae:	89 d0                	mov    %edx,%eax
  800cb0:	c1 e0 10             	shl    $0x10,%eax
  800cb3:	09 f0                	or     %esi,%eax
  800cb5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800cb7:	09 d8                	or     %ebx,%eax
  800cb9:	c1 e9 02             	shr    $0x2,%ecx
  800cbc:	fc                   	cld    
  800cbd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cbf:	eb 03                	jmp    800cc4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc1:	fc                   	cld    
  800cc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cc4:	89 f8                	mov    %edi,%eax
  800cc6:	8b 1c 24             	mov    (%esp),%ebx
  800cc9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ccd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cd1:	89 ec                	mov    %ebp,%esp
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 08             	sub    $0x8,%esp
  800cdb:	89 34 24             	mov    %esi,(%esp)
  800cde:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ce8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ceb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ced:	39 c6                	cmp    %eax,%esi
  800cef:	73 35                	jae    800d26 <memmove+0x51>
  800cf1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cf4:	39 d0                	cmp    %edx,%eax
  800cf6:	73 2e                	jae    800d26 <memmove+0x51>
		s += n;
		d += n;
  800cf8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cfa:	f6 c2 03             	test   $0x3,%dl
  800cfd:	75 1b                	jne    800d1a <memmove+0x45>
  800cff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d05:	75 13                	jne    800d1a <memmove+0x45>
  800d07:	f6 c1 03             	test   $0x3,%cl
  800d0a:	75 0e                	jne    800d1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d0c:	83 ef 04             	sub    $0x4,%edi
  800d0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d12:	c1 e9 02             	shr    $0x2,%ecx
  800d15:	fd                   	std    
  800d16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d18:	eb 09                	jmp    800d23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d1a:	83 ef 01             	sub    $0x1,%edi
  800d1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d20:	fd                   	std    
  800d21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d23:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d24:	eb 20                	jmp    800d46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d2c:	75 15                	jne    800d43 <memmove+0x6e>
  800d2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d34:	75 0d                	jne    800d43 <memmove+0x6e>
  800d36:	f6 c1 03             	test   $0x3,%cl
  800d39:	75 08                	jne    800d43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d3b:	c1 e9 02             	shr    $0x2,%ecx
  800d3e:	fc                   	cld    
  800d3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d41:	eb 03                	jmp    800d46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d43:	fc                   	cld    
  800d44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d46:	8b 34 24             	mov    (%esp),%esi
  800d49:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d4d:	89 ec                	mov    %ebp,%esp
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d57:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	89 04 24             	mov    %eax,(%esp)
  800d6b:	e8 65 ff ff ff       	call   800cd5 <memmove>
}
  800d70:	c9                   	leave  
  800d71:	c3                   	ret    

00800d72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d81:	85 c9                	test   %ecx,%ecx
  800d83:	74 36                	je     800dbb <memcmp+0x49>
		if (*s1 != *s2)
  800d85:	0f b6 06             	movzbl (%esi),%eax
  800d88:	0f b6 1f             	movzbl (%edi),%ebx
  800d8b:	38 d8                	cmp    %bl,%al
  800d8d:	74 20                	je     800daf <memcmp+0x3d>
  800d8f:	eb 14                	jmp    800da5 <memcmp+0x33>
  800d91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d9b:	83 c2 01             	add    $0x1,%edx
  800d9e:	83 e9 01             	sub    $0x1,%ecx
  800da1:	38 d8                	cmp    %bl,%al
  800da3:	74 12                	je     800db7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800da5:	0f b6 c0             	movzbl %al,%eax
  800da8:	0f b6 db             	movzbl %bl,%ebx
  800dab:	29 d8                	sub    %ebx,%eax
  800dad:	eb 11                	jmp    800dc0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800daf:	83 e9 01             	sub    $0x1,%ecx
  800db2:	ba 00 00 00 00       	mov    $0x0,%edx
  800db7:	85 c9                	test   %ecx,%ecx
  800db9:	75 d6                	jne    800d91 <memcmp+0x1f>
  800dbb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dcb:	89 c2                	mov    %eax,%edx
  800dcd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dd0:	39 d0                	cmp    %edx,%eax
  800dd2:	73 15                	jae    800de9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dd4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800dd8:	38 08                	cmp    %cl,(%eax)
  800dda:	75 06                	jne    800de2 <memfind+0x1d>
  800ddc:	eb 0b                	jmp    800de9 <memfind+0x24>
  800dde:	38 08                	cmp    %cl,(%eax)
  800de0:	74 07                	je     800de9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800de2:	83 c0 01             	add    $0x1,%eax
  800de5:	39 c2                	cmp    %eax,%edx
  800de7:	77 f5                	ja     800dde <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 04             	sub    $0x4,%esp
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dfa:	0f b6 02             	movzbl (%edx),%eax
  800dfd:	3c 20                	cmp    $0x20,%al
  800dff:	74 04                	je     800e05 <strtol+0x1a>
  800e01:	3c 09                	cmp    $0x9,%al
  800e03:	75 0e                	jne    800e13 <strtol+0x28>
		s++;
  800e05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e08:	0f b6 02             	movzbl (%edx),%eax
  800e0b:	3c 20                	cmp    $0x20,%al
  800e0d:	74 f6                	je     800e05 <strtol+0x1a>
  800e0f:	3c 09                	cmp    $0x9,%al
  800e11:	74 f2                	je     800e05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e13:	3c 2b                	cmp    $0x2b,%al
  800e15:	75 0c                	jne    800e23 <strtol+0x38>
		s++;
  800e17:	83 c2 01             	add    $0x1,%edx
  800e1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e21:	eb 15                	jmp    800e38 <strtol+0x4d>
	else if (*s == '-')
  800e23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e2a:	3c 2d                	cmp    $0x2d,%al
  800e2c:	75 0a                	jne    800e38 <strtol+0x4d>
		s++, neg = 1;
  800e2e:	83 c2 01             	add    $0x1,%edx
  800e31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e38:	85 db                	test   %ebx,%ebx
  800e3a:	0f 94 c0             	sete   %al
  800e3d:	74 05                	je     800e44 <strtol+0x59>
  800e3f:	83 fb 10             	cmp    $0x10,%ebx
  800e42:	75 18                	jne    800e5c <strtol+0x71>
  800e44:	80 3a 30             	cmpb   $0x30,(%edx)
  800e47:	75 13                	jne    800e5c <strtol+0x71>
  800e49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e4d:	8d 76 00             	lea    0x0(%esi),%esi
  800e50:	75 0a                	jne    800e5c <strtol+0x71>
		s += 2, base = 16;
  800e52:	83 c2 02             	add    $0x2,%edx
  800e55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e5a:	eb 15                	jmp    800e71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e5c:	84 c0                	test   %al,%al
  800e5e:	66 90                	xchg   %ax,%ax
  800e60:	74 0f                	je     800e71 <strtol+0x86>
  800e62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e67:	80 3a 30             	cmpb   $0x30,(%edx)
  800e6a:	75 05                	jne    800e71 <strtol+0x86>
		s++, base = 8;
  800e6c:	83 c2 01             	add    $0x1,%edx
  800e6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e78:	0f b6 0a             	movzbl (%edx),%ecx
  800e7b:	89 cf                	mov    %ecx,%edi
  800e7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e80:	80 fb 09             	cmp    $0x9,%bl
  800e83:	77 08                	ja     800e8d <strtol+0xa2>
			dig = *s - '0';
  800e85:	0f be c9             	movsbl %cl,%ecx
  800e88:	83 e9 30             	sub    $0x30,%ecx
  800e8b:	eb 1e                	jmp    800eab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e90:	80 fb 19             	cmp    $0x19,%bl
  800e93:	77 08                	ja     800e9d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e95:	0f be c9             	movsbl %cl,%ecx
  800e98:	83 e9 57             	sub    $0x57,%ecx
  800e9b:	eb 0e                	jmp    800eab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ea0:	80 fb 19             	cmp    $0x19,%bl
  800ea3:	77 15                	ja     800eba <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ea5:	0f be c9             	movsbl %cl,%ecx
  800ea8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800eab:	39 f1                	cmp    %esi,%ecx
  800ead:	7d 0b                	jge    800eba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800eaf:	83 c2 01             	add    $0x1,%edx
  800eb2:	0f af c6             	imul   %esi,%eax
  800eb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800eb8:	eb be                	jmp    800e78 <strtol+0x8d>
  800eba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ebc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec0:	74 05                	je     800ec7 <strtol+0xdc>
		*endptr = (char *) s;
  800ec2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ec5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ec7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ecb:	74 04                	je     800ed1 <strtol+0xe6>
  800ecd:	89 c8                	mov    %ecx,%eax
  800ecf:	f7 d8                	neg    %eax
}
  800ed1:	83 c4 04             	add    $0x4,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	00 00                	add    %al,(%eax)
	...

00800edc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 08             	sub    $0x8,%esp
  800ee2:	89 1c 24             	mov    %ebx,(%esp)
  800ee5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ee9:	ba 00 00 00 00       	mov    $0x0,%edx
  800eee:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef3:	89 d1                	mov    %edx,%ecx
  800ef5:	89 d3                	mov    %edx,%ebx
  800ef7:	89 d7                	mov    %edx,%edi
  800ef9:	51                   	push   %ecx
  800efa:	52                   	push   %edx
  800efb:	53                   	push   %ebx
  800efc:	54                   	push   %esp
  800efd:	55                   	push   %ebp
  800efe:	56                   	push   %esi
  800eff:	57                   	push   %edi
  800f00:	54                   	push   %esp
  800f01:	5d                   	pop    %ebp
  800f02:	8d 35 0a 0f 80 00    	lea    0x800f0a,%esi
  800f08:	0f 34                	sysenter 
  800f0a:	5f                   	pop    %edi
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	5c                   	pop    %esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5a                   	pop    %edx
  800f10:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f11:	8b 1c 24             	mov    (%esp),%ebx
  800f14:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f18:	89 ec                	mov    %ebp,%esp
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	89 1c 24             	mov    %ebx,(%esp)
  800f25:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f31:	8b 55 08             	mov    0x8(%ebp),%edx
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	89 c7                	mov    %eax,%edi
  800f38:	51                   	push   %ecx
  800f39:	52                   	push   %edx
  800f3a:	53                   	push   %ebx
  800f3b:	54                   	push   %esp
  800f3c:	55                   	push   %ebp
  800f3d:	56                   	push   %esi
  800f3e:	57                   	push   %edi
  800f3f:	54                   	push   %esp
  800f40:	5d                   	pop    %ebp
  800f41:	8d 35 49 0f 80 00    	lea    0x800f49,%esi
  800f47:	0f 34                	sysenter 
  800f49:	5f                   	pop    %edi
  800f4a:	5e                   	pop    %esi
  800f4b:	5d                   	pop    %ebp
  800f4c:	5c                   	pop    %esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5a                   	pop    %edx
  800f4f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f50:	8b 1c 24             	mov    (%esp),%ebx
  800f53:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f57:	89 ec                	mov    %ebp,%esp
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 28             	sub    $0x28,%esp
  800f61:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f64:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f74:	8b 55 08             	mov    0x8(%ebp),%edx
  800f77:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 28                	jle    800fbd <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f99:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fb0:	00 
  800fb1:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  800fb8:	e8 2f 09 00 00       	call   8018ec <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800fbd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc3:	89 ec                	mov    %ebp,%esp
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 08             	sub    $0x8,%esp
  800fcd:	89 1c 24             	mov    %ebx,(%esp)
  800fd0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fde:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe1:	89 cb                	mov    %ecx,%ebx
  800fe3:	89 cf                	mov    %ecx,%edi
  800fe5:	51                   	push   %ecx
  800fe6:	52                   	push   %edx
  800fe7:	53                   	push   %ebx
  800fe8:	54                   	push   %esp
  800fe9:	55                   	push   %ebp
  800fea:	56                   	push   %esi
  800feb:	57                   	push   %edi
  800fec:	54                   	push   %esp
  800fed:	5d                   	pop    %ebp
  800fee:	8d 35 f6 0f 80 00    	lea    0x800ff6,%esi
  800ff4:	0f 34                	sysenter 
  800ff6:	5f                   	pop    %edi
  800ff7:	5e                   	pop    %esi
  800ff8:	5d                   	pop    %ebp
  800ff9:	5c                   	pop    %esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5a                   	pop    %edx
  800ffc:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ffd:	8b 1c 24             	mov    (%esp),%ebx
  801000:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801004:	89 ec                	mov    %ebp,%esp
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 28             	sub    $0x28,%esp
  80100e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801011:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801014:	b9 00 00 00 00       	mov    $0x0,%ecx
  801019:	b8 0d 00 00 00       	mov    $0xd,%eax
  80101e:	8b 55 08             	mov    0x8(%ebp),%edx
  801021:	89 cb                	mov    %ecx,%ebx
  801023:	89 cf                	mov    %ecx,%edi
  801025:	51                   	push   %ecx
  801026:	52                   	push   %edx
  801027:	53                   	push   %ebx
  801028:	54                   	push   %esp
  801029:	55                   	push   %ebp
  80102a:	56                   	push   %esi
  80102b:	57                   	push   %edi
  80102c:	54                   	push   %esp
  80102d:	5d                   	pop    %ebp
  80102e:	8d 35 36 10 80 00    	lea    0x801036,%esi
  801034:	0f 34                	sysenter 
  801036:	5f                   	pop    %edi
  801037:	5e                   	pop    %esi
  801038:	5d                   	pop    %ebp
  801039:	5c                   	pop    %esp
  80103a:	5b                   	pop    %ebx
  80103b:	5a                   	pop    %edx
  80103c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80103d:	85 c0                	test   %eax,%eax
  80103f:	7e 28                	jle    801069 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801041:	89 44 24 10          	mov    %eax,0x10(%esp)
  801045:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80104c:	00 
  80104d:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  801064:	e8 83 08 00 00       	call   8018ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801069:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80106c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80106f:	89 ec                	mov    %ebp,%esp
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 08             	sub    $0x8,%esp
  801079:	89 1c 24             	mov    %ebx,(%esp)
  80107c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801080:	b8 0c 00 00 00       	mov    $0xc,%eax
  801085:	8b 7d 14             	mov    0x14(%ebp),%edi
  801088:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80108b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108e:	8b 55 08             	mov    0x8(%ebp),%edx
  801091:	51                   	push   %ecx
  801092:	52                   	push   %edx
  801093:	53                   	push   %ebx
  801094:	54                   	push   %esp
  801095:	55                   	push   %ebp
  801096:	56                   	push   %esi
  801097:	57                   	push   %edi
  801098:	54                   	push   %esp
  801099:	5d                   	pop    %ebp
  80109a:	8d 35 a2 10 80 00    	lea    0x8010a2,%esi
  8010a0:	0f 34                	sysenter 
  8010a2:	5f                   	pop    %edi
  8010a3:	5e                   	pop    %esi
  8010a4:	5d                   	pop    %ebp
  8010a5:	5c                   	pop    %esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5a                   	pop    %edx
  8010a8:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010a9:	8b 1c 24             	mov    (%esp),%ebx
  8010ac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b0:	89 ec                	mov    %ebp,%esp
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 28             	sub    $0x28,%esp
  8010ba:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010bd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d0:	89 df                	mov    %ebx,%edi
  8010d2:	51                   	push   %ecx
  8010d3:	52                   	push   %edx
  8010d4:	53                   	push   %ebx
  8010d5:	54                   	push   %esp
  8010d6:	55                   	push   %ebp
  8010d7:	56                   	push   %esi
  8010d8:	57                   	push   %edi
  8010d9:	54                   	push   %esp
  8010da:	5d                   	pop    %ebp
  8010db:	8d 35 e3 10 80 00    	lea    0x8010e3,%esi
  8010e1:	0f 34                	sysenter 
  8010e3:	5f                   	pop    %edi
  8010e4:	5e                   	pop    %esi
  8010e5:	5d                   	pop    %ebp
  8010e6:	5c                   	pop    %esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5a                   	pop    %edx
  8010e9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	7e 28                	jle    801116 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f2:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010f9:	00 
  8010fa:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  801101:	00 
  801102:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801109:	00 
  80110a:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  801111:	e8 d6 07 00 00       	call   8018ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801116:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801119:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80111c:	89 ec                	mov    %ebp,%esp
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 28             	sub    $0x28,%esp
  801126:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801129:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80112c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801131:	b8 09 00 00 00       	mov    $0x9,%eax
  801136:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801139:	8b 55 08             	mov    0x8(%ebp),%edx
  80113c:	89 df                	mov    %ebx,%edi
  80113e:	51                   	push   %ecx
  80113f:	52                   	push   %edx
  801140:	53                   	push   %ebx
  801141:	54                   	push   %esp
  801142:	55                   	push   %ebp
  801143:	56                   	push   %esi
  801144:	57                   	push   %edi
  801145:	54                   	push   %esp
  801146:	5d                   	pop    %ebp
  801147:	8d 35 4f 11 80 00    	lea    0x80114f,%esi
  80114d:	0f 34                	sysenter 
  80114f:	5f                   	pop    %edi
  801150:	5e                   	pop    %esi
  801151:	5d                   	pop    %ebp
  801152:	5c                   	pop    %esp
  801153:	5b                   	pop    %ebx
  801154:	5a                   	pop    %edx
  801155:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801156:	85 c0                	test   %eax,%eax
  801158:	7e 28                	jle    801182 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801165:	00 
  801166:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  80117d:	e8 6a 07 00 00       	call   8018ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801182:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801185:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801188:	89 ec                	mov    %ebp,%esp
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	83 ec 28             	sub    $0x28,%esp
  801192:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801195:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801198:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119d:	b8 07 00 00 00       	mov    $0x7,%eax
  8011a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a8:	89 df                	mov    %ebx,%edi
  8011aa:	51                   	push   %ecx
  8011ab:	52                   	push   %edx
  8011ac:	53                   	push   %ebx
  8011ad:	54                   	push   %esp
  8011ae:	55                   	push   %ebp
  8011af:	56                   	push   %esi
  8011b0:	57                   	push   %edi
  8011b1:	54                   	push   %esp
  8011b2:	5d                   	pop    %ebp
  8011b3:	8d 35 bb 11 80 00    	lea    0x8011bb,%esi
  8011b9:	0f 34                	sysenter 
  8011bb:	5f                   	pop    %edi
  8011bc:	5e                   	pop    %esi
  8011bd:	5d                   	pop    %ebp
  8011be:	5c                   	pop    %esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5a                   	pop    %edx
  8011c1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	7e 28                	jle    8011ee <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  8011d9:	00 
  8011da:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011e1:	00 
  8011e2:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  8011e9:	e8 fe 06 00 00       	call   8018ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011ee:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011f4:	89 ec                	mov    %ebp,%esp
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 28             	sub    $0x28,%esp
  8011fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801201:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801204:	8b 7d 18             	mov    0x18(%ebp),%edi
  801207:	0b 7d 14             	or     0x14(%ebp),%edi
  80120a:	b8 06 00 00 00       	mov    $0x6,%eax
  80120f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801215:	8b 55 08             	mov    0x8(%ebp),%edx
  801218:	51                   	push   %ecx
  801219:	52                   	push   %edx
  80121a:	53                   	push   %ebx
  80121b:	54                   	push   %esp
  80121c:	55                   	push   %ebp
  80121d:	56                   	push   %esi
  80121e:	57                   	push   %edi
  80121f:	54                   	push   %esp
  801220:	5d                   	pop    %ebp
  801221:	8d 35 29 12 80 00    	lea    0x801229,%esi
  801227:	0f 34                	sysenter 
  801229:	5f                   	pop    %edi
  80122a:	5e                   	pop    %esi
  80122b:	5d                   	pop    %ebp
  80122c:	5c                   	pop    %esp
  80122d:	5b                   	pop    %ebx
  80122e:	5a                   	pop    %edx
  80122f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801230:	85 c0                	test   %eax,%eax
  801232:	7e 28                	jle    80125c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801234:	89 44 24 10          	mov    %eax,0x10(%esp)
  801238:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80123f:	00 
  801240:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  801247:	00 
  801248:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80124f:	00 
  801250:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  801257:	e8 90 06 00 00       	call   8018ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80125c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80125f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801262:	89 ec                	mov    %ebp,%esp
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	83 ec 28             	sub    $0x28,%esp
  80126c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80126f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801272:	bf 00 00 00 00       	mov    $0x0,%edi
  801277:	b8 05 00 00 00       	mov    $0x5,%eax
  80127c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80127f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801282:	8b 55 08             	mov    0x8(%ebp),%edx
  801285:	51                   	push   %ecx
  801286:	52                   	push   %edx
  801287:	53                   	push   %ebx
  801288:	54                   	push   %esp
  801289:	55                   	push   %ebp
  80128a:	56                   	push   %esi
  80128b:	57                   	push   %edi
  80128c:	54                   	push   %esp
  80128d:	5d                   	pop    %ebp
  80128e:	8d 35 96 12 80 00    	lea    0x801296,%esi
  801294:	0f 34                	sysenter 
  801296:	5f                   	pop    %edi
  801297:	5e                   	pop    %esi
  801298:	5d                   	pop    %ebp
  801299:	5c                   	pop    %esp
  80129a:	5b                   	pop    %ebx
  80129b:	5a                   	pop    %edx
  80129c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80129d:	85 c0                	test   %eax,%eax
  80129f:	7e 28                	jle    8012c9 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a5:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  8012b4:	00 
  8012b5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012bc:	00 
  8012bd:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  8012c4:	e8 23 06 00 00       	call   8018ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012cf:	89 ec                	mov    %ebp,%esp
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	89 1c 24             	mov    %ebx,(%esp)
  8012dc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012ea:	89 d1                	mov    %edx,%ecx
  8012ec:	89 d3                	mov    %edx,%ebx
  8012ee:	89 d7                	mov    %edx,%edi
  8012f0:	51                   	push   %ecx
  8012f1:	52                   	push   %edx
  8012f2:	53                   	push   %ebx
  8012f3:	54                   	push   %esp
  8012f4:	55                   	push   %ebp
  8012f5:	56                   	push   %esi
  8012f6:	57                   	push   %edi
  8012f7:	54                   	push   %esp
  8012f8:	5d                   	pop    %ebp
  8012f9:	8d 35 01 13 80 00    	lea    0x801301,%esi
  8012ff:	0f 34                	sysenter 
  801301:	5f                   	pop    %edi
  801302:	5e                   	pop    %esi
  801303:	5d                   	pop    %ebp
  801304:	5c                   	pop    %esp
  801305:	5b                   	pop    %ebx
  801306:	5a                   	pop    %edx
  801307:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801308:	8b 1c 24             	mov    (%esp),%ebx
  80130b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80130f:	89 ec                	mov    %ebp,%esp
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    

00801313 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	89 1c 24             	mov    %ebx,(%esp)
  80131c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801320:	bb 00 00 00 00       	mov    $0x0,%ebx
  801325:	b8 04 00 00 00       	mov    $0x4,%eax
  80132a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132d:	8b 55 08             	mov    0x8(%ebp),%edx
  801330:	89 df                	mov    %ebx,%edi
  801332:	51                   	push   %ecx
  801333:	52                   	push   %edx
  801334:	53                   	push   %ebx
  801335:	54                   	push   %esp
  801336:	55                   	push   %ebp
  801337:	56                   	push   %esi
  801338:	57                   	push   %edi
  801339:	54                   	push   %esp
  80133a:	5d                   	pop    %ebp
  80133b:	8d 35 43 13 80 00    	lea    0x801343,%esi
  801341:	0f 34                	sysenter 
  801343:	5f                   	pop    %edi
  801344:	5e                   	pop    %esi
  801345:	5d                   	pop    %ebp
  801346:	5c                   	pop    %esp
  801347:	5b                   	pop    %ebx
  801348:	5a                   	pop    %edx
  801349:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80134a:	8b 1c 24             	mov    (%esp),%ebx
  80134d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801351:	89 ec                	mov    %ebp,%esp
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 08             	sub    $0x8,%esp
  80135b:	89 1c 24             	mov    %ebx,(%esp)
  80135e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801362:	ba 00 00 00 00       	mov    $0x0,%edx
  801367:	b8 02 00 00 00       	mov    $0x2,%eax
  80136c:	89 d1                	mov    %edx,%ecx
  80136e:	89 d3                	mov    %edx,%ebx
  801370:	89 d7                	mov    %edx,%edi
  801372:	51                   	push   %ecx
  801373:	52                   	push   %edx
  801374:	53                   	push   %ebx
  801375:	54                   	push   %esp
  801376:	55                   	push   %ebp
  801377:	56                   	push   %esi
  801378:	57                   	push   %edi
  801379:	54                   	push   %esp
  80137a:	5d                   	pop    %ebp
  80137b:	8d 35 83 13 80 00    	lea    0x801383,%esi
  801381:	0f 34                	sysenter 
  801383:	5f                   	pop    %edi
  801384:	5e                   	pop    %esi
  801385:	5d                   	pop    %ebp
  801386:	5c                   	pop    %esp
  801387:	5b                   	pop    %ebx
  801388:	5a                   	pop    %edx
  801389:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80138a:	8b 1c 24             	mov    (%esp),%ebx
  80138d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801391:	89 ec                	mov    %ebp,%esp
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 28             	sub    $0x28,%esp
  80139b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80139e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013a6:	b8 03 00 00 00       	mov    $0x3,%eax
  8013ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ae:	89 cb                	mov    %ecx,%ebx
  8013b0:	89 cf                	mov    %ecx,%edi
  8013b2:	51                   	push   %ecx
  8013b3:	52                   	push   %edx
  8013b4:	53                   	push   %ebx
  8013b5:	54                   	push   %esp
  8013b6:	55                   	push   %ebp
  8013b7:	56                   	push   %esi
  8013b8:	57                   	push   %edi
  8013b9:	54                   	push   %esp
  8013ba:	5d                   	pop    %ebp
  8013bb:	8d 35 c3 13 80 00    	lea    0x8013c3,%esi
  8013c1:	0f 34                	sysenter 
  8013c3:	5f                   	pop    %edi
  8013c4:	5e                   	pop    %esi
  8013c5:	5d                   	pop    %ebp
  8013c6:	5c                   	pop    %esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5a                   	pop    %edx
  8013c9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	7e 28                	jle    8013f6 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8013d9:	00 
  8013da:	c7 44 24 08 44 1f 80 	movl   $0x801f44,0x8(%esp)
  8013e1:	00 
  8013e2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013e9:	00 
  8013ea:	c7 04 24 61 1f 80 00 	movl   $0x801f61,(%esp)
  8013f1:	e8 f6 04 00 00       	call   8018ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8013f6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013f9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013fc:	89 ec                	mov    %ebp,%esp
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801406:	c7 44 24 08 6f 1f 80 	movl   $0x801f6f,0x8(%esp)
  80140d:	00 
  80140e:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801415:	00 
  801416:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  80141d:	e8 ca 04 00 00       	call   8018ec <_panic>

00801422 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	57                   	push   %edi
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
  801428:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80142b:	c7 04 24 77 16 80 00 	movl   $0x801677,(%esp)
  801432:	e8 25 05 00 00       	call   80195c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801437:	ba 08 00 00 00       	mov    $0x8,%edx
  80143c:	89 d0                	mov    %edx,%eax
  80143e:	cd 30                	int    $0x30
  801440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801443:	85 c0                	test   %eax,%eax
  801445:	79 20                	jns    801467 <fork+0x45>
		panic("sys_exofork: %e", envid);
  801447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144b:	c7 44 24 08 90 1f 80 	movl   $0x801f90,0x8(%esp)
  801452:	00 
  801453:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80145a:	00 
  80145b:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  801462:	e8 85 04 00 00       	call   8018ec <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801467:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80146c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801471:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801476:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80147a:	75 20                	jne    80149c <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80147c:	e8 d4 fe ff ff       	call   801355 <sys_getenvid>
  801481:	25 ff 03 00 00       	and    $0x3ff,%eax
  801486:	89 c2                	mov    %eax,%edx
  801488:	c1 e2 07             	shl    $0x7,%edx
  80148b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801492:	a3 04 30 80 00       	mov    %eax,0x803004
		return 0;
  801497:	e9 d0 01 00 00       	jmp    80166c <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80149c:	89 d8                	mov    %ebx,%eax
  80149e:	c1 e8 16             	shr    $0x16,%eax
  8014a1:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8014a4:	a8 01                	test   $0x1,%al
  8014a6:	0f 84 0d 01 00 00    	je     8015b9 <fork+0x197>
  8014ac:	89 d8                	mov    %ebx,%eax
  8014ae:	c1 e8 0c             	shr    $0xc,%eax
  8014b1:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8014b4:	f6 c2 01             	test   $0x1,%dl
  8014b7:	0f 84 fc 00 00 00    	je     8015b9 <fork+0x197>
  8014bd:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8014c0:	f6 c2 04             	test   $0x4,%dl
  8014c3:	0f 84 f0 00 00 00    	je     8015b9 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  8014c9:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	c1 ea 0c             	shr    $0xc,%edx
  8014d1:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  8014d4:	f6 c2 01             	test   $0x1,%dl
  8014d7:	0f 84 dc 00 00 00    	je     8015b9 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8014dd:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8014e3:	0f 84 8d 00 00 00    	je     801576 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8014e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014ec:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8014f3:	00 
  8014f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801503:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80150a:	e8 e9 fc ff ff       	call   8011f8 <sys_page_map>
               if(r<0)
  80150f:	85 c0                	test   %eax,%eax
  801511:	79 1c                	jns    80152f <fork+0x10d>
                 panic("map failed");
  801513:	c7 44 24 08 a0 1f 80 	movl   $0x801fa0,0x8(%esp)
  80151a:	00 
  80151b:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801522:	00 
  801523:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  80152a:	e8 bd 03 00 00       	call   8018ec <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  80152f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801536:	00 
  801537:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80153a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80153e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801545:	00 
  801546:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801551:	e8 a2 fc ff ff       	call   8011f8 <sys_page_map>
               if(r<0)
  801556:	85 c0                	test   %eax,%eax
  801558:	79 5f                	jns    8015b9 <fork+0x197>
                 panic("map failed");
  80155a:	c7 44 24 08 a0 1f 80 	movl   $0x801fa0,0x8(%esp)
  801561:	00 
  801562:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801569:	00 
  80156a:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  801571:	e8 76 03 00 00       	call   8018ec <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801576:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80157d:	00 
  80157e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801582:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801585:	89 54 24 08          	mov    %edx,0x8(%esp)
  801589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801594:	e8 5f fc ff ff       	call   8011f8 <sys_page_map>
               if(r<0)
  801599:	85 c0                	test   %eax,%eax
  80159b:	79 1c                	jns    8015b9 <fork+0x197>
                 panic("map failed");
  80159d:	c7 44 24 08 a0 1f 80 	movl   $0x801fa0,0x8(%esp)
  8015a4:	00 
  8015a5:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8015ac:	00 
  8015ad:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  8015b4:	e8 33 03 00 00       	call   8018ec <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8015b9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015bf:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8015c5:	0f 85 d1 fe ff ff    	jne    80149c <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8015cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015d2:	00 
  8015d3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015da:	ee 
  8015db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015de:	89 04 24             	mov    %eax,(%esp)
  8015e1:	e8 80 fc ff ff       	call   801266 <sys_page_alloc>
        if(r < 0)
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	79 1c                	jns    801606 <fork+0x1e4>
            panic("alloc failed");
  8015ea:	c7 44 24 08 ab 1f 80 	movl   $0x801fab,0x8(%esp)
  8015f1:	00 
  8015f2:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8015f9:	00 
  8015fa:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  801601:	e8 e6 02 00 00       	call   8018ec <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801606:	c7 44 24 04 a8 19 80 	movl   $0x8019a8,0x4(%esp)
  80160d:	00 
  80160e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801611:	89 14 24             	mov    %edx,(%esp)
  801614:	e8 9b fa ff ff       	call   8010b4 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801619:	85 c0                	test   %eax,%eax
  80161b:	79 1c                	jns    801639 <fork+0x217>
            panic("set pgfault upcall failed");
  80161d:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  801624:	00 
  801625:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80162c:	00 
  80162d:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  801634:	e8 b3 02 00 00       	call   8018ec <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801639:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801640:	00 
  801641:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801644:	89 04 24             	mov    %eax,(%esp)
  801647:	e8 d4 fa ff ff       	call   801120 <sys_env_set_status>
        if(r < 0)
  80164c:	85 c0                	test   %eax,%eax
  80164e:	79 1c                	jns    80166c <fork+0x24a>
            panic("set status failed");
  801650:	c7 44 24 08 d2 1f 80 	movl   $0x801fd2,0x8(%esp)
  801657:	00 
  801658:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80165f:	00 
  801660:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  801667:	e8 80 02 00 00       	call   8018ec <_panic>
        return envid;
	//panic("fork not implemented");
}
  80166c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80166f:	83 c4 3c             	add    $0x3c,%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5f                   	pop    %edi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 24             	sub    $0x24,%esp
  80167e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801681:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801683:	89 da                	mov    %ebx,%edx
  801685:	c1 ea 0c             	shr    $0xc,%edx
  801688:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80168f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801693:	74 08                	je     80169d <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801695:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80169b:	75 1c                	jne    8016b9 <pgfault+0x42>
           panic("pgfault error");
  80169d:	c7 44 24 08 e4 1f 80 	movl   $0x801fe4,0x8(%esp)
  8016a4:	00 
  8016a5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8016ac:	00 
  8016ad:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  8016b4:	e8 33 02 00 00       	call   8018ec <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016b9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016c0:	00 
  8016c1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8016c8:	00 
  8016c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d0:	e8 91 fb ff ff       	call   801266 <sys_page_alloc>
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	79 20                	jns    8016f9 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  8016d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016dd:	c7 44 24 08 f2 1f 80 	movl   $0x801ff2,0x8(%esp)
  8016e4:	00 
  8016e5:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8016ec:	00 
  8016ed:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  8016f4:	e8 f3 01 00 00       	call   8018ec <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  8016f9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8016ff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801706:	00 
  801707:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80170b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801712:	e8 be f5 ff ff       	call   800cd5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801717:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80171e:	00 
  80171f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801723:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80172a:	00 
  80172b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801732:	00 
  801733:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173a:	e8 b9 fa ff ff       	call   8011f8 <sys_page_map>
  80173f:	85 c0                	test   %eax,%eax
  801741:	79 20                	jns    801763 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801743:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801747:	c7 44 24 08 05 20 80 	movl   $0x802005,0x8(%esp)
  80174e:	00 
  80174f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801756:	00 
  801757:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  80175e:	e8 89 01 00 00       	call   8018ec <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801763:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80176a:	00 
  80176b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801772:	e8 15 fa ff ff       	call   80118c <sys_page_unmap>
  801777:	85 c0                	test   %eax,%eax
  801779:	79 20                	jns    80179b <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80177b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80177f:	c7 44 24 08 16 20 80 	movl   $0x802016,0x8(%esp)
  801786:	00 
  801787:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80178e:	00 
  80178f:	c7 04 24 85 1f 80 00 	movl   $0x801f85,(%esp)
  801796:	e8 51 01 00 00       	call   8018ec <_panic>
	//panic("pgfault not implemented");
}
  80179b:	83 c4 24             	add    $0x24,%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    
	...

008017b0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8017b6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8017bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c1:	39 ca                	cmp    %ecx,%edx
  8017c3:	75 04                	jne    8017c9 <ipc_find_env+0x19>
  8017c5:	b0 00                	mov    $0x0,%al
  8017c7:	eb 12                	jmp    8017db <ipc_find_env+0x2b>
  8017c9:	89 c2                	mov    %eax,%edx
  8017cb:	c1 e2 07             	shl    $0x7,%edx
  8017ce:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8017d5:	8b 12                	mov    (%edx),%edx
  8017d7:	39 ca                	cmp    %ecx,%edx
  8017d9:	75 10                	jne    8017eb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8017db:	89 c2                	mov    %eax,%edx
  8017dd:	c1 e2 07             	shl    $0x7,%edx
  8017e0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8017e7:	8b 00                	mov    (%eax),%eax
  8017e9:	eb 0e                	jmp    8017f9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8017eb:	83 c0 01             	add    $0x1,%eax
  8017ee:	3d 00 04 00 00       	cmp    $0x400,%eax
  8017f3:	75 d4                	jne    8017c9 <ipc_find_env+0x19>
  8017f5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	57                   	push   %edi
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	83 ec 1c             	sub    $0x1c,%esp
  801804:	8b 75 08             	mov    0x8(%ebp),%esi
  801807:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80180a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80180d:	85 db                	test   %ebx,%ebx
  80180f:	74 19                	je     80182a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801811:	8b 45 14             	mov    0x14(%ebp),%eax
  801814:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801818:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801820:	89 34 24             	mov    %esi,(%esp)
  801823:	e8 4b f8 ff ff       	call   801073 <sys_ipc_try_send>
  801828:	eb 1b                	jmp    801845 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80182a:	8b 45 14             	mov    0x14(%ebp),%eax
  80182d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801831:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801838:	ee 
  801839:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80183d:	89 34 24             	mov    %esi,(%esp)
  801840:	e8 2e f8 ff ff       	call   801073 <sys_ipc_try_send>
           if(ret == 0)
  801845:	85 c0                	test   %eax,%eax
  801847:	74 28                	je     801871 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801849:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80184c:	74 1c                	je     80186a <ipc_send+0x6f>
              panic("ipc send error");
  80184e:	c7 44 24 08 29 20 80 	movl   $0x802029,0x8(%esp)
  801855:	00 
  801856:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80185d:	00 
  80185e:	c7 04 24 38 20 80 00 	movl   $0x802038,(%esp)
  801865:	e8 82 00 00 00       	call   8018ec <_panic>
           sys_yield();
  80186a:	e8 64 fa ff ff       	call   8012d3 <sys_yield>
        }
  80186f:	eb 9c                	jmp    80180d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801871:	83 c4 1c             	add    $0x1c,%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5f                   	pop    %edi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	83 ec 10             	sub    $0x10,%esp
  801881:	8b 75 08             	mov    0x8(%ebp),%esi
  801884:	8b 45 0c             	mov    0xc(%ebp),%eax
  801887:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80188a:	85 c0                	test   %eax,%eax
  80188c:	75 0e                	jne    80189c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80188e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801895:	e8 6e f7 ff ff       	call   801008 <sys_ipc_recv>
  80189a:	eb 08                	jmp    8018a4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80189c:	89 04 24             	mov    %eax,(%esp)
  80189f:	e8 64 f7 ff ff       	call   801008 <sys_ipc_recv>
        if(ret == 0){
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	75 26                	jne    8018ce <ipc_recv+0x55>
           if(from_env_store)
  8018a8:	85 f6                	test   %esi,%esi
  8018aa:	74 0a                	je     8018b6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  8018ac:	a1 04 30 80 00       	mov    0x803004,%eax
  8018b1:	8b 40 78             	mov    0x78(%eax),%eax
  8018b4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  8018b6:	85 db                	test   %ebx,%ebx
  8018b8:	74 0a                	je     8018c4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  8018ba:	a1 04 30 80 00       	mov    0x803004,%eax
  8018bf:	8b 40 7c             	mov    0x7c(%eax),%eax
  8018c2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8018c4:	a1 04 30 80 00       	mov    0x803004,%eax
  8018c9:	8b 40 74             	mov    0x74(%eax),%eax
  8018cc:	eb 14                	jmp    8018e2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8018ce:	85 f6                	test   %esi,%esi
  8018d0:	74 06                	je     8018d8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8018d2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8018d8:	85 db                	test   %ebx,%ebx
  8018da:	74 06                	je     8018e2 <ipc_recv+0x69>
              *perm_store = 0;
  8018dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	5d                   	pop    %ebp
  8018e8:	c3                   	ret    
  8018e9:	00 00                	add    %al,(%eax)
	...

008018ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8018f4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8018f7:	a1 08 30 80 00       	mov    0x803008,%eax
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	74 10                	je     801910 <_panic+0x24>
		cprintf("%s: ", argv0);
  801900:	89 44 24 04          	mov    %eax,0x4(%esp)
  801904:	c7 04 24 42 20 80 00 	movl   $0x802042,(%esp)
  80190b:	e8 b1 e8 ff ff       	call   8001c1 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801910:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801916:	e8 3a fa ff ff       	call   801355 <sys_getenvid>
  80191b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801922:	8b 55 08             	mov    0x8(%ebp),%edx
  801925:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801929:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801931:	c7 04 24 48 20 80 00 	movl   $0x802048,(%esp)
  801938:	e8 84 e8 ff ff       	call   8001c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80193d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801941:	8b 45 10             	mov    0x10(%ebp),%eax
  801944:	89 04 24             	mov    %eax,(%esp)
  801947:	e8 14 e8 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  80194c:	c7 04 24 67 1c 80 00 	movl   $0x801c67,(%esp)
  801953:	e8 69 e8 ff ff       	call   8001c1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801958:	cc                   	int3   
  801959:	eb fd                	jmp    801958 <_panic+0x6c>
	...

0080195c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801962:	83 3d 0c 30 80 00 00 	cmpl   $0x0,0x80300c
  801969:	75 30                	jne    80199b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80196b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801972:	00 
  801973:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80197a:	ee 
  80197b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801982:	e8 df f8 ff ff       	call   801266 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  801987:	c7 44 24 04 a8 19 80 	movl   $0x8019a8,0x4(%esp)
  80198e:	00 
  80198f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801996:	e8 19 f7 ff ff       	call   8010b4 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    
  8019a5:	00 00                	add    %al,(%eax)
	...

008019a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8019a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8019a9:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  8019ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8019b0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8019b3:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8019b7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8019bb:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8019be:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8019c0:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8019c4:	83 c4 08             	add    $0x8,%esp
        popal
  8019c7:	61                   	popa   
        addl $0x4,%esp
  8019c8:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8019cb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8019cc:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8019cd:	c3                   	ret    
	...

008019d0 <__udivdi3>:
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	57                   	push   %edi
  8019d4:	56                   	push   %esi
  8019d5:	83 ec 10             	sub    $0x10,%esp
  8019d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019db:	8b 55 08             	mov    0x8(%ebp),%edx
  8019de:	8b 75 10             	mov    0x10(%ebp),%esi
  8019e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8019e9:	75 35                	jne    801a20 <__udivdi3+0x50>
  8019eb:	39 fe                	cmp    %edi,%esi
  8019ed:	77 61                	ja     801a50 <__udivdi3+0x80>
  8019ef:	85 f6                	test   %esi,%esi
  8019f1:	75 0b                	jne    8019fe <__udivdi3+0x2e>
  8019f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f8:	31 d2                	xor    %edx,%edx
  8019fa:	f7 f6                	div    %esi
  8019fc:	89 c6                	mov    %eax,%esi
  8019fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801a01:	31 d2                	xor    %edx,%edx
  801a03:	89 f8                	mov    %edi,%eax
  801a05:	f7 f6                	div    %esi
  801a07:	89 c7                	mov    %eax,%edi
  801a09:	89 c8                	mov    %ecx,%eax
  801a0b:	f7 f6                	div    %esi
  801a0d:	89 c1                	mov    %eax,%ecx
  801a0f:	89 fa                	mov    %edi,%edx
  801a11:	89 c8                	mov    %ecx,%eax
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	5e                   	pop    %esi
  801a17:	5f                   	pop    %edi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    
  801a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a20:	39 f8                	cmp    %edi,%eax
  801a22:	77 1c                	ja     801a40 <__udivdi3+0x70>
  801a24:	0f bd d0             	bsr    %eax,%edx
  801a27:	83 f2 1f             	xor    $0x1f,%edx
  801a2a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801a2d:	75 39                	jne    801a68 <__udivdi3+0x98>
  801a2f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801a32:	0f 86 a0 00 00 00    	jbe    801ad8 <__udivdi3+0x108>
  801a38:	39 f8                	cmp    %edi,%eax
  801a3a:	0f 82 98 00 00 00    	jb     801ad8 <__udivdi3+0x108>
  801a40:	31 ff                	xor    %edi,%edi
  801a42:	31 c9                	xor    %ecx,%ecx
  801a44:	89 c8                	mov    %ecx,%eax
  801a46:	89 fa                	mov    %edi,%edx
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	5e                   	pop    %esi
  801a4c:	5f                   	pop    %edi
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    
  801a4f:	90                   	nop
  801a50:	89 d1                	mov    %edx,%ecx
  801a52:	89 fa                	mov    %edi,%edx
  801a54:	89 c8                	mov    %ecx,%eax
  801a56:	31 ff                	xor    %edi,%edi
  801a58:	f7 f6                	div    %esi
  801a5a:	89 c1                	mov    %eax,%ecx
  801a5c:	89 fa                	mov    %edi,%edx
  801a5e:	89 c8                	mov    %ecx,%eax
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	5e                   	pop    %esi
  801a64:	5f                   	pop    %edi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    
  801a67:	90                   	nop
  801a68:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a6c:	89 f2                	mov    %esi,%edx
  801a6e:	d3 e0                	shl    %cl,%eax
  801a70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a73:	b8 20 00 00 00       	mov    $0x20,%eax
  801a78:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801a7b:	89 c1                	mov    %eax,%ecx
  801a7d:	d3 ea                	shr    %cl,%edx
  801a7f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a83:	0b 55 ec             	or     -0x14(%ebp),%edx
  801a86:	d3 e6                	shl    %cl,%esi
  801a88:	89 c1                	mov    %eax,%ecx
  801a8a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801a8d:	89 fe                	mov    %edi,%esi
  801a8f:	d3 ee                	shr    %cl,%esi
  801a91:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a95:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a9b:	d3 e7                	shl    %cl,%edi
  801a9d:	89 c1                	mov    %eax,%ecx
  801a9f:	d3 ea                	shr    %cl,%edx
  801aa1:	09 d7                	or     %edx,%edi
  801aa3:	89 f2                	mov    %esi,%edx
  801aa5:	89 f8                	mov    %edi,%eax
  801aa7:	f7 75 ec             	divl   -0x14(%ebp)
  801aaa:	89 d6                	mov    %edx,%esi
  801aac:	89 c7                	mov    %eax,%edi
  801aae:	f7 65 e8             	mull   -0x18(%ebp)
  801ab1:	39 d6                	cmp    %edx,%esi
  801ab3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801ab6:	72 30                	jb     801ae8 <__udivdi3+0x118>
  801ab8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801abb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801abf:	d3 e2                	shl    %cl,%edx
  801ac1:	39 c2                	cmp    %eax,%edx
  801ac3:	73 05                	jae    801aca <__udivdi3+0xfa>
  801ac5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801ac8:	74 1e                	je     801ae8 <__udivdi3+0x118>
  801aca:	89 f9                	mov    %edi,%ecx
  801acc:	31 ff                	xor    %edi,%edi
  801ace:	e9 71 ff ff ff       	jmp    801a44 <__udivdi3+0x74>
  801ad3:	90                   	nop
  801ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ad8:	31 ff                	xor    %edi,%edi
  801ada:	b9 01 00 00 00       	mov    $0x1,%ecx
  801adf:	e9 60 ff ff ff       	jmp    801a44 <__udivdi3+0x74>
  801ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ae8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801aeb:	31 ff                	xor    %edi,%edi
  801aed:	89 c8                	mov    %ecx,%eax
  801aef:	89 fa                	mov    %edi,%edx
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	5e                   	pop    %esi
  801af5:	5f                   	pop    %edi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    
	...

00801b00 <__umoddi3>:
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	57                   	push   %edi
  801b04:	56                   	push   %esi
  801b05:	83 ec 20             	sub    $0x20,%esp
  801b08:	8b 55 14             	mov    0x14(%ebp),%edx
  801b0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b0e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b11:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b14:	85 d2                	test   %edx,%edx
  801b16:	89 c8                	mov    %ecx,%eax
  801b18:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b1b:	75 13                	jne    801b30 <__umoddi3+0x30>
  801b1d:	39 f7                	cmp    %esi,%edi
  801b1f:	76 3f                	jbe    801b60 <__umoddi3+0x60>
  801b21:	89 f2                	mov    %esi,%edx
  801b23:	f7 f7                	div    %edi
  801b25:	89 d0                	mov    %edx,%eax
  801b27:	31 d2                	xor    %edx,%edx
  801b29:	83 c4 20             	add    $0x20,%esp
  801b2c:	5e                   	pop    %esi
  801b2d:	5f                   	pop    %edi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    
  801b30:	39 f2                	cmp    %esi,%edx
  801b32:	77 4c                	ja     801b80 <__umoddi3+0x80>
  801b34:	0f bd ca             	bsr    %edx,%ecx
  801b37:	83 f1 1f             	xor    $0x1f,%ecx
  801b3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b3d:	75 51                	jne    801b90 <__umoddi3+0x90>
  801b3f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801b42:	0f 87 e0 00 00 00    	ja     801c28 <__umoddi3+0x128>
  801b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4b:	29 f8                	sub    %edi,%eax
  801b4d:	19 d6                	sbb    %edx,%esi
  801b4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b55:	89 f2                	mov    %esi,%edx
  801b57:	83 c4 20             	add    $0x20,%esp
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    
  801b5e:	66 90                	xchg   %ax,%ax
  801b60:	85 ff                	test   %edi,%edi
  801b62:	75 0b                	jne    801b6f <__umoddi3+0x6f>
  801b64:	b8 01 00 00 00       	mov    $0x1,%eax
  801b69:	31 d2                	xor    %edx,%edx
  801b6b:	f7 f7                	div    %edi
  801b6d:	89 c7                	mov    %eax,%edi
  801b6f:	89 f0                	mov    %esi,%eax
  801b71:	31 d2                	xor    %edx,%edx
  801b73:	f7 f7                	div    %edi
  801b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b78:	f7 f7                	div    %edi
  801b7a:	eb a9                	jmp    801b25 <__umoddi3+0x25>
  801b7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b80:	89 c8                	mov    %ecx,%eax
  801b82:	89 f2                	mov    %esi,%edx
  801b84:	83 c4 20             	add    $0x20,%esp
  801b87:	5e                   	pop    %esi
  801b88:	5f                   	pop    %edi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    
  801b8b:	90                   	nop
  801b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b90:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b94:	d3 e2                	shl    %cl,%edx
  801b96:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b99:	ba 20 00 00 00       	mov    $0x20,%edx
  801b9e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801ba1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801ba4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ba8:	89 fa                	mov    %edi,%edx
  801baa:	d3 ea                	shr    %cl,%edx
  801bac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bb0:	0b 55 f4             	or     -0xc(%ebp),%edx
  801bb3:	d3 e7                	shl    %cl,%edi
  801bb5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801bb9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801bbc:	89 f2                	mov    %esi,%edx
  801bbe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801bc1:	89 c7                	mov    %eax,%edi
  801bc3:	d3 ea                	shr    %cl,%edx
  801bc5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bc9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801bcc:	89 c2                	mov    %eax,%edx
  801bce:	d3 e6                	shl    %cl,%esi
  801bd0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801bd4:	d3 ea                	shr    %cl,%edx
  801bd6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bda:	09 d6                	or     %edx,%esi
  801bdc:	89 f0                	mov    %esi,%eax
  801bde:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801be1:	d3 e7                	shl    %cl,%edi
  801be3:	89 f2                	mov    %esi,%edx
  801be5:	f7 75 f4             	divl   -0xc(%ebp)
  801be8:	89 d6                	mov    %edx,%esi
  801bea:	f7 65 e8             	mull   -0x18(%ebp)
  801bed:	39 d6                	cmp    %edx,%esi
  801bef:	72 2b                	jb     801c1c <__umoddi3+0x11c>
  801bf1:	39 c7                	cmp    %eax,%edi
  801bf3:	72 23                	jb     801c18 <__umoddi3+0x118>
  801bf5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bf9:	29 c7                	sub    %eax,%edi
  801bfb:	19 d6                	sbb    %edx,%esi
  801bfd:	89 f0                	mov    %esi,%eax
  801bff:	89 f2                	mov    %esi,%edx
  801c01:	d3 ef                	shr    %cl,%edi
  801c03:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c07:	d3 e0                	shl    %cl,%eax
  801c09:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c0d:	09 f8                	or     %edi,%eax
  801c0f:	d3 ea                	shr    %cl,%edx
  801c11:	83 c4 20             	add    $0x20,%esp
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	39 d6                	cmp    %edx,%esi
  801c1a:	75 d9                	jne    801bf5 <__umoddi3+0xf5>
  801c1c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801c1f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801c22:	eb d1                	jmp    801bf5 <__umoddi3+0xf5>
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	39 f2                	cmp    %esi,%edx
  801c2a:	0f 82 18 ff ff ff    	jb     801b48 <__umoddi3+0x48>
  801c30:	e9 1d ff ff ff       	jmp    801b52 <__umoddi3+0x52>
