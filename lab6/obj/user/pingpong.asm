
obj/user/pingpong.debug:     file format elf32-i386


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
  80003d:	e8 a4 15 00 00       	call   8015e6 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 c7 14 00 00       	call   801517 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 00 2c 80 00 	movl   $0x802c00,(%esp)
  80005f:	e8 65 01 00 00       	call   8001c9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 34 19 00 00       	call   8019bb <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 97 19 00 00       	call   801a39 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 6b 14 00 00       	call   801517 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  8000bf:	e8 05 01 00 00       	call   8001c9 <cprintf>
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
  8000e6:	e8 d0 18 00 00       	call   8019bb <ipc_send>
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
  80010a:	e8 08 14 00 00       	call   801517 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	89 c2                	mov    %eax,%edx
  800116:	c1 e2 07             	shl    $0x7,%edx
  800119:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800120:	a3 08 50 80 00       	mov    %eax,0x805008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x38>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 40 80 00       	mov    %eax,0x804000

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
	close_all();
  800152:	e8 34 1e 00 00       	call   801f8b <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 f4 13 00 00       	call   801557 <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800171:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800178:	00 00 00 
	b.cnt = 0;
  80017b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800182:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800185:	8b 45 0c             	mov    0xc(%ebp),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	c7 04 24 e3 01 80 00 	movl   $0x8001e3,(%esp)
  8001a4:	e8 d3 01 00 00       	call   80037c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b9:	89 04 24             	mov    %eax,(%esp)
  8001bc:	e8 6b 0d 00 00       	call   800f2c <sys_cputs>

	return b.cnt;
}
  8001c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001cf:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	e8 87 ff ff ff       	call   800168 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 14             	sub    $0x14,%esp
  8001ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ed:	8b 03                	mov    (%ebx),%eax
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001f6:	83 c0 01             	add    $0x1,%eax
  8001f9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800200:	75 19                	jne    80021b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800202:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800209:	00 
  80020a:	8d 43 08             	lea    0x8(%ebx),%eax
  80020d:	89 04 24             	mov    %eax,(%esp)
  800210:	e8 17 0d 00 00       	call   800f2c <sys_cputs>
		b->idx = 0;
  800215:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80021b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021f:	83 c4 14             	add    $0x14,%esp
  800222:	5b                   	pop    %ebx
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    
	...

00800230 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 4c             	sub    $0x4c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80024a:	8b 45 10             	mov    0x10(%ebp),%eax
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800250:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800253:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800256:	b9 00 00 00 00       	mov    $0x0,%ecx
  80025b:	39 d1                	cmp    %edx,%ecx
  80025d:	72 07                	jb     800266 <printnum_v2+0x36>
  80025f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800262:	39 d0                	cmp    %edx,%eax
  800264:	77 5f                	ja     8002c5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800266:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80026a:	83 eb 01             	sub    $0x1,%ebx
  80026d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800271:	89 44 24 08          	mov    %eax,0x8(%esp)
  800275:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800279:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80027d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800280:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800283:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800286:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800291:	00 
  800292:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80029b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029f:	e8 ec 26 00 00       	call   802990 <__udivdi3>
  8002a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b9:	89 f2                	mov    %esi,%edx
  8002bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002be:	e8 6d ff ff ff       	call   800230 <printnum_v2>
  8002c3:	eb 1e                	jmp    8002e3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8002c5:	83 ff 2d             	cmp    $0x2d,%edi
  8002c8:	74 19                	je     8002e3 <printnum_v2+0xb3>
		while (--width > 0)
  8002ca:	83 eb 01             	sub    $0x1,%ebx
  8002cd:	85 db                	test   %ebx,%ebx
  8002cf:	90                   	nop
  8002d0:	7e 11                	jle    8002e3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8002d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d6:	89 3c 24             	mov    %edi,(%esp)
  8002d9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8002dc:	83 eb 01             	sub    $0x1,%ebx
  8002df:	85 db                	test   %ebx,%ebx
  8002e1:	7f ef                	jg     8002d2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f9:	00 
  8002fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002fd:	89 14 24             	mov    %edx,(%esp)
  800300:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800303:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800307:	e8 b4 27 00 00       	call   802ac0 <__umoddi3>
  80030c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800310:	0f be 80 33 2c 80 00 	movsbl 0x802c33(%eax),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80031d:	83 c4 4c             	add    $0x4c,%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800328:	83 fa 01             	cmp    $0x1,%edx
  80032b:	7e 0e                	jle    80033b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800332:	89 08                	mov    %ecx,(%eax)
  800334:	8b 02                	mov    (%edx),%eax
  800336:	8b 52 04             	mov    0x4(%edx),%edx
  800339:	eb 22                	jmp    80035d <getuint+0x38>
	else if (lflag)
  80033b:	85 d2                	test   %edx,%edx
  80033d:	74 10                	je     80034f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	8d 4a 04             	lea    0x4(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 02                	mov    (%edx),%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
  80034d:	eb 0e                	jmp    80035d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 04             	lea    0x4(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800365:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	3b 50 04             	cmp    0x4(%eax),%edx
  80036e:	73 0a                	jae    80037a <sprintputch+0x1b>
		*b->buf++ = ch;
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	88 0a                	mov    %cl,(%edx)
  800375:	83 c2 01             	add    $0x1,%edx
  800378:	89 10                	mov    %edx,(%eax)
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
  800382:	83 ec 6c             	sub    $0x6c,%esp
  800385:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800388:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80038f:	eb 1a                	jmp    8003ab <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800391:	85 c0                	test   %eax,%eax
  800393:	0f 84 66 06 00 00    	je     8009ff <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800399:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	ff 55 08             	call   *0x8(%ebp)
  8003a6:	eb 03                	jmp    8003ab <vprintfmt+0x2f>
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	83 c7 01             	add    $0x1,%edi
  8003b1:	83 f8 25             	cmp    $0x25,%eax
  8003b4:	75 db                	jne    800391 <vprintfmt+0x15>
  8003b6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8003ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003c6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8003cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d2:	be 00 00 00 00       	mov    $0x0,%esi
  8003d7:	eb 06                	jmp    8003df <vprintfmt+0x63>
  8003d9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8003dd:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	0f b6 17             	movzbl (%edi),%edx
  8003e2:	0f b6 c2             	movzbl %dl,%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	8d 47 01             	lea    0x1(%edi),%eax
  8003eb:	83 ea 23             	sub    $0x23,%edx
  8003ee:	80 fa 55             	cmp    $0x55,%dl
  8003f1:	0f 87 60 05 00 00    	ja     800957 <vprintfmt+0x5db>
  8003f7:	0f b6 d2             	movzbl %dl,%edx
  8003fa:	ff 24 95 20 2e 80 00 	jmp    *0x802e20(,%edx,4)
  800401:	b9 01 00 00 00       	mov    $0x1,%ecx
  800406:	eb d5                	jmp    8003dd <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800408:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80040b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80040e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800411:	8d 7a d0             	lea    -0x30(%edx),%edi
  800414:	83 ff 09             	cmp    $0x9,%edi
  800417:	76 08                	jbe    800421 <vprintfmt+0xa5>
  800419:	eb 40                	jmp    80045b <vprintfmt+0xdf>
  80041b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80041f:	eb bc                	jmp    8003dd <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800421:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800424:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800427:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80042b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80042e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800431:	83 ff 09             	cmp    $0x9,%edi
  800434:	76 eb                	jbe    800421 <vprintfmt+0xa5>
  800436:	eb 23                	jmp    80045b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800438:	8b 55 14             	mov    0x14(%ebp),%edx
  80043b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80043e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800441:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800443:	eb 16                	jmp    80045b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800445:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800448:	c1 fa 1f             	sar    $0x1f,%edx
  80044b:	f7 d2                	not    %edx
  80044d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800450:	eb 8b                	jmp    8003dd <vprintfmt+0x61>
  800452:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800459:	eb 82                	jmp    8003dd <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80045b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045f:	0f 89 78 ff ff ff    	jns    8003dd <vprintfmt+0x61>
  800465:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800468:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80046b:	e9 6d ff ff ff       	jmp    8003dd <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800470:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800473:	e9 65 ff ff ff       	jmp    8003dd <vprintfmt+0x61>
  800478:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 55 0c             	mov    0xc(%ebp),%edx
  800487:	89 54 24 04          	mov    %edx,0x4(%esp)
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	89 04 24             	mov    %eax,(%esp)
  800490:	ff 55 08             	call   *0x8(%ebp)
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800496:	e9 10 ff ff ff       	jmp    8003ab <vprintfmt+0x2f>
  80049b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	89 c2                	mov    %eax,%edx
  8004ab:	c1 fa 1f             	sar    $0x1f,%edx
  8004ae:	31 d0                	xor    %edx,%eax
  8004b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b2:	83 f8 0f             	cmp    $0xf,%eax
  8004b5:	7f 0b                	jg     8004c2 <vprintfmt+0x146>
  8004b7:	8b 14 85 80 2f 80 00 	mov    0x802f80(,%eax,4),%edx
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	75 26                	jne    8004e8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c6:	c7 44 24 08 44 2c 80 	movl   $0x802c44,0x8(%esp)
  8004cd:	00 
  8004ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004d8:	89 1c 24             	mov    %ebx,(%esp)
  8004db:	e8 a7 05 00 00       	call   800a87 <printfmt>
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	e9 c3 fe ff ff       	jmp    8003ab <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ec:	c7 44 24 08 72 31 80 	movl   $0x803172,0x8(%esp)
  8004f3:	00 
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fe:	89 14 24             	mov    %edx,(%esp)
  800501:	e8 81 05 00 00       	call   800a87 <printfmt>
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	e9 9d fe ff ff       	jmp    8003ab <vprintfmt+0x2f>
  80050e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800511:	89 c7                	mov    %eax,%edi
  800513:	89 d9                	mov    %ebx,%ecx
  800515:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800518:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 30                	mov    (%eax),%esi
  800526:	85 f6                	test   %esi,%esi
  800528:	75 05                	jne    80052f <vprintfmt+0x1b3>
  80052a:	be 4d 2c 80 00       	mov    $0x802c4d,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80052f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800533:	7e 06                	jle    80053b <vprintfmt+0x1bf>
  800535:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800539:	75 10                	jne    80054b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053b:	0f be 06             	movsbl (%esi),%eax
  80053e:	85 c0                	test   %eax,%eax
  800540:	0f 85 a2 00 00 00    	jne    8005e8 <vprintfmt+0x26c>
  800546:	e9 92 00 00 00       	jmp    8005dd <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054f:	89 34 24             	mov    %esi,(%esp)
  800552:	e8 74 05 00 00       	call   800acb <strnlen>
  800557:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80055a:	29 c2                	sub    %eax,%edx
  80055c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80055f:	85 d2                	test   %edx,%edx
  800561:	7e d8                	jle    80053b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800563:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800567:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80056a:	89 d3                	mov    %edx,%ebx
  80056c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80056f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800572:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800575:	89 ce                	mov    %ecx,%esi
  800577:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057b:	89 34 24             	mov    %esi,(%esp)
  80057e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	83 eb 01             	sub    $0x1,%ebx
  800584:	85 db                	test   %ebx,%ebx
  800586:	7f ef                	jg     800577 <vprintfmt+0x1fb>
  800588:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80058b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80058e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800591:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800598:	eb a1                	jmp    80053b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80059e:	74 1b                	je     8005bb <vprintfmt+0x23f>
  8005a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a3:	83 fa 5e             	cmp    $0x5e,%edx
  8005a6:	76 13                	jbe    8005bb <vprintfmt+0x23f>
					putch('?', putdat);
  8005a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	eb 0d                	jmp    8005c8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c2:	89 04 24             	mov    %eax,(%esp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c8:	83 ef 01             	sub    $0x1,%edi
  8005cb:	0f be 06             	movsbl (%esi),%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	74 05                	je     8005d7 <vprintfmt+0x25b>
  8005d2:	83 c6 01             	add    $0x1,%esi
  8005d5:	eb 1a                	jmp    8005f1 <vprintfmt+0x275>
  8005d7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005da:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	7f 1f                	jg     800602 <vprintfmt+0x286>
  8005e3:	e9 c0 fd ff ff       	jmp    8003a8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e8:	83 c6 01             	add    $0x1,%esi
  8005eb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005f1:	85 db                	test   %ebx,%ebx
  8005f3:	78 a5                	js     80059a <vprintfmt+0x21e>
  8005f5:	83 eb 01             	sub    $0x1,%ebx
  8005f8:	79 a0                	jns    80059a <vprintfmt+0x21e>
  8005fa:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005fd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800600:	eb db                	jmp    8005dd <vprintfmt+0x261>
  800602:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800605:	8b 75 0c             	mov    0xc(%ebp),%esi
  800608:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80060b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800612:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800619:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061b:	83 eb 01             	sub    $0x1,%ebx
  80061e:	85 db                	test   %ebx,%ebx
  800620:	7f ec                	jg     80060e <vprintfmt+0x292>
  800622:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800625:	e9 81 fd ff ff       	jmp    8003ab <vprintfmt+0x2f>
  80062a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062d:	83 fe 01             	cmp    $0x1,%esi
  800630:	7e 10                	jle    800642 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 08             	lea    0x8(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 18                	mov    (%eax),%ebx
  80063d:	8b 70 04             	mov    0x4(%eax),%esi
  800640:	eb 26                	jmp    800668 <vprintfmt+0x2ec>
	else if (lflag)
  800642:	85 f6                	test   %esi,%esi
  800644:	74 12                	je     800658 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 18                	mov    (%eax),%ebx
  800651:	89 de                	mov    %ebx,%esi
  800653:	c1 fe 1f             	sar    $0x1f,%esi
  800656:	eb 10                	jmp    800668 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 04             	lea    0x4(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)
  800661:	8b 18                	mov    (%eax),%ebx
  800663:	89 de                	mov    %ebx,%esi
  800665:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800668:	83 f9 01             	cmp    $0x1,%ecx
  80066b:	75 1e                	jne    80068b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80066d:	85 f6                	test   %esi,%esi
  80066f:	78 1a                	js     80068b <vprintfmt+0x30f>
  800671:	85 f6                	test   %esi,%esi
  800673:	7f 05                	jg     80067a <vprintfmt+0x2fe>
  800675:	83 fb 00             	cmp    $0x0,%ebx
  800678:	76 11                	jbe    80068b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80067a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80067d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800681:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800688:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80068b:	85 f6                	test   %esi,%esi
  80068d:	78 13                	js     8006a2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800692:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069d:	e9 da 00 00 00       	jmp    80077c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8006a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b3:	89 da                	mov    %ebx,%edx
  8006b5:	89 f1                	mov    %esi,%ecx
  8006b7:	f7 da                	neg    %edx
  8006b9:	83 d1 00             	adc    $0x0,%ecx
  8006bc:	f7 d9                	neg    %ecx
  8006be:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006c1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cc:	e9 ab 00 00 00       	jmp    80077c <vprintfmt+0x400>
  8006d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d4:	89 f2                	mov    %esi,%edx
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 47 fc ff ff       	call   800325 <getuint>
  8006de:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006e1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006ec:	e9 8b 00 00 00       	jmp    80077c <vprintfmt+0x400>
  8006f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006fb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800702:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800705:	89 f2                	mov    %esi,%edx
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	e8 16 fc ff ff       	call   800325 <getuint>
  80070f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800712:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800718:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80071d:	eb 5d                	jmp    80077c <vprintfmt+0x400>
  80071f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800725:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800729:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800730:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 50 04             	lea    0x4(%eax),%edx
  800747:	89 55 14             	mov    %edx,0x14(%ebp)
  80074a:	8b 10                	mov    (%eax),%edx
  80074c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800751:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800754:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80075f:	eb 1b                	jmp    80077c <vprintfmt+0x400>
  800761:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800764:	89 f2                	mov    %esi,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 b7 fb ff ff       	call   800325 <getuint>
  80076e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800771:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800777:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800780:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800783:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800786:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80078a:	77 09                	ja     800795 <vprintfmt+0x419>
  80078c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80078f:	0f 82 ac 00 00 00    	jb     800841 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800795:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800798:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80079c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079f:	83 ea 01             	sub    $0x1,%edx
  8007a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007aa:	8b 44 24 08          	mov    0x8(%esp),%eax
  8007ae:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8007b2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8007b5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8007b8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007c6:	00 
  8007c7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007ca:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007cd:	89 0c 24             	mov    %ecx,(%esp)
  8007d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d4:	e8 b7 21 00 00       	call   802990 <__udivdi3>
  8007d9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8007dc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8007df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	e8 37 fa ff ff       	call   800230 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	8b 74 24 04          	mov    0x4(%esp),%esi
  800804:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800807:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800812:	00 
  800813:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800816:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800819:	89 14 24             	mov    %edx,(%esp)
  80081c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800820:	e8 9b 22 00 00       	call   802ac0 <__umoddi3>
  800825:	89 74 24 04          	mov    %esi,0x4(%esp)
  800829:	0f be 80 33 2c 80 00 	movsbl 0x802c33(%eax),%eax
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800836:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80083a:	74 54                	je     800890 <vprintfmt+0x514>
  80083c:	e9 67 fb ff ff       	jmp    8003a8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800841:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800845:	8d 76 00             	lea    0x0(%esi),%esi
  800848:	0f 84 2a 01 00 00    	je     800978 <vprintfmt+0x5fc>
		while (--width > 0)
  80084e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800851:	83 ef 01             	sub    $0x1,%edi
  800854:	85 ff                	test   %edi,%edi
  800856:	0f 8e 5e 01 00 00    	jle    8009ba <vprintfmt+0x63e>
  80085c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80085f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800862:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800865:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800868:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80086b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80086e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800872:	89 1c 24             	mov    %ebx,(%esp)
  800875:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800878:	83 ef 01             	sub    $0x1,%edi
  80087b:	85 ff                	test   %edi,%edi
  80087d:	7f ef                	jg     80086e <vprintfmt+0x4f2>
  80087f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800882:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800885:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800888:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80088b:	e9 2a 01 00 00       	jmp    8009ba <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800890:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800893:	83 eb 01             	sub    $0x1,%ebx
  800896:	85 db                	test   %ebx,%ebx
  800898:	0f 8e 0a fb ff ff    	jle    8003a8 <vprintfmt+0x2c>
  80089e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8008a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008b2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008b4:	83 eb 01             	sub    $0x1,%ebx
  8008b7:	85 db                	test   %ebx,%ebx
  8008b9:	7f ec                	jg     8008a7 <vprintfmt+0x52b>
  8008bb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008be:	e9 e8 fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
  8008c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	8d 50 04             	lea    0x4(%eax),%edx
  8008cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cf:	8b 00                	mov    (%eax),%eax
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	75 2a                	jne    8008ff <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8008d5:	c7 44 24 0c 68 2d 80 	movl   $0x802d68,0xc(%esp)
  8008dc:	00 
  8008dd:	c7 44 24 08 72 31 80 	movl   $0x803172,0x8(%esp)
  8008e4:	00 
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ef:	89 0c 24             	mov    %ecx,(%esp)
  8008f2:	e8 90 01 00 00       	call   800a87 <printfmt>
  8008f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008fa:	e9 ac fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8008ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800902:	8b 13                	mov    (%ebx),%edx
  800904:	83 fa 7f             	cmp    $0x7f,%edx
  800907:	7e 29                	jle    800932 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800909:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80090b:	c7 44 24 0c a0 2d 80 	movl   $0x802da0,0xc(%esp)
  800912:	00 
  800913:	c7 44 24 08 72 31 80 	movl   $0x803172,0x8(%esp)
  80091a:	00 
  80091b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	e8 5d 01 00 00       	call   800a87 <printfmt>
  80092a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092d:	e9 79 fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800932:	88 10                	mov    %dl,(%eax)
  800934:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800937:	e9 6f fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
  80093c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80093f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800945:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800949:	89 14 24             	mov    %edx,(%esp)
  80094c:	ff 55 08             	call   *0x8(%ebp)
  80094f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800952:	e9 54 fa ff ff       	jmp    8003ab <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800957:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800965:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800968:	8d 47 ff             	lea    -0x1(%edi),%eax
  80096b:	80 38 25             	cmpb   $0x25,(%eax)
  80096e:	0f 84 37 fa ff ff    	je     8003ab <vprintfmt+0x2f>
  800974:	89 c7                	mov    %eax,%edi
  800976:	eb f0                	jmp    800968 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800983:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800986:	89 54 24 08          	mov    %edx,0x8(%esp)
  80098a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800991:	00 
  800992:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800995:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800998:	89 04 24             	mov    %eax,(%esp)
  80099b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099f:	e8 1c 21 00 00       	call   802ac0 <__umoddi3>
  8009a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a8:	0f be 80 33 2c 80 00 	movsbl 0x802c33(%eax),%eax
  8009af:	89 04 24             	mov    %eax,(%esp)
  8009b2:	ff 55 08             	call   *0x8(%ebp)
  8009b5:	e9 d6 fe ff ff       	jmp    800890 <vprintfmt+0x514>
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009c1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009c5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009d3:	00 
  8009d4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009d7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009da:	89 04 24             	mov    %eax,(%esp)
  8009dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e1:	e8 da 20 00 00       	call   802ac0 <__umoddi3>
  8009e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ea:	0f be 80 33 2c 80 00 	movsbl 0x802c33(%eax),%eax
  8009f1:	89 04 24             	mov    %eax,(%esp)
  8009f4:	ff 55 08             	call   *0x8(%ebp)
  8009f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009fa:	e9 ac f9 ff ff       	jmp    8003ab <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009ff:	83 c4 6c             	add    $0x6c,%esp
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	83 ec 28             	sub    $0x28,%esp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a13:	85 c0                	test   %eax,%eax
  800a15:	74 04                	je     800a1b <vsnprintf+0x14>
  800a17:	85 d2                	test   %edx,%edx
  800a19:	7f 07                	jg     800a22 <vsnprintf+0x1b>
  800a1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a20:	eb 3b                	jmp    800a5d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a25:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a33:	8b 45 14             	mov    0x14(%ebp),%eax
  800a36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a41:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a48:	c7 04 24 5f 03 80 00 	movl   $0x80035f,(%esp)
  800a4f:	e8 28 f9 ff ff       	call   80037c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a57:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a65:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	89 04 24             	mov    %eax,(%esp)
  800a80:	e8 82 ff ff ff       	call   800a07 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a8d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a94:	8b 45 10             	mov    0x10(%ebp),%eax
  800a97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	89 04 24             	mov    %eax,(%esp)
  800aa8:	e8 cf f8 ff ff       	call   80037c <vprintfmt>
	va_end(ap);
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    
	...

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	80 3a 00             	cmpb   $0x0,(%edx)
  800abe:	74 09                	je     800ac9 <strlen+0x19>
		n++;
  800ac0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac7:	75 f7                	jne    800ac0 <strlen+0x10>
		n++;
	return n;
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad5:	85 c9                	test   %ecx,%ecx
  800ad7:	74 19                	je     800af2 <strnlen+0x27>
  800ad9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800adc:	74 14                	je     800af2 <strnlen+0x27>
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ae3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae6:	39 c8                	cmp    %ecx,%eax
  800ae8:	74 0d                	je     800af7 <strnlen+0x2c>
  800aea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800aee:	75 f3                	jne    800ae3 <strnlen+0x18>
  800af0:	eb 05                	jmp    800af7 <strnlen+0x2c>
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800af7:	5b                   	pop    %ebx
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b10:	83 c2 01             	add    $0x1,%edx
  800b13:	84 c9                	test   %cl,%cl
  800b15:	75 f2                	jne    800b09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b17:	5b                   	pop    %ebx
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 08             	sub    $0x8,%esp
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b24:	89 1c 24             	mov    %ebx,(%esp)
  800b27:	e8 84 ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b33:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	e8 bc ff ff ff       	call   800afa <strcpy>
	return dst;
}
  800b3e:	89 d8                	mov    %ebx,%eax
  800b40:	83 c4 08             	add    $0x8,%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b54:	85 f6                	test   %esi,%esi
  800b56:	74 18                	je     800b70 <strncpy+0x2a>
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b5d:	0f b6 1a             	movzbl (%edx),%ebx
  800b60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b63:	80 3a 01             	cmpb   $0x1,(%edx)
  800b66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	39 ce                	cmp    %ecx,%esi
  800b6e:	77 ed                	ja     800b5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b82:	89 f0                	mov    %esi,%eax
  800b84:	85 c9                	test   %ecx,%ecx
  800b86:	74 27                	je     800baf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b88:	83 e9 01             	sub    $0x1,%ecx
  800b8b:	74 1d                	je     800baa <strlcpy+0x36>
  800b8d:	0f b6 1a             	movzbl (%edx),%ebx
  800b90:	84 db                	test   %bl,%bl
  800b92:	74 16                	je     800baa <strlcpy+0x36>
			*dst++ = *src++;
  800b94:	88 18                	mov    %bl,(%eax)
  800b96:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b99:	83 e9 01             	sub    $0x1,%ecx
  800b9c:	74 0e                	je     800bac <strlcpy+0x38>
			*dst++ = *src++;
  800b9e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba1:	0f b6 1a             	movzbl (%edx),%ebx
  800ba4:	84 db                	test   %bl,%bl
  800ba6:	75 ec                	jne    800b94 <strlcpy+0x20>
  800ba8:	eb 02                	jmp    800bac <strlcpy+0x38>
  800baa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bac:	c6 00 00             	movb   $0x0,(%eax)
  800baf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bbe:	0f b6 01             	movzbl (%ecx),%eax
  800bc1:	84 c0                	test   %al,%al
  800bc3:	74 15                	je     800bda <strcmp+0x25>
  800bc5:	3a 02                	cmp    (%edx),%al
  800bc7:	75 11                	jne    800bda <strcmp+0x25>
		p++, q++;
  800bc9:	83 c1 01             	add    $0x1,%ecx
  800bcc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bcf:	0f b6 01             	movzbl (%ecx),%eax
  800bd2:	84 c0                	test   %al,%al
  800bd4:	74 04                	je     800bda <strcmp+0x25>
  800bd6:	3a 02                	cmp    (%edx),%al
  800bd8:	74 ef                	je     800bc9 <strcmp+0x14>
  800bda:	0f b6 c0             	movzbl %al,%eax
  800bdd:	0f b6 12             	movzbl (%edx),%edx
  800be0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	53                   	push   %ebx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	74 23                	je     800c18 <strncmp+0x34>
  800bf5:	0f b6 1a             	movzbl (%edx),%ebx
  800bf8:	84 db                	test   %bl,%bl
  800bfa:	74 25                	je     800c21 <strncmp+0x3d>
  800bfc:	3a 19                	cmp    (%ecx),%bl
  800bfe:	75 21                	jne    800c21 <strncmp+0x3d>
  800c00:	83 e8 01             	sub    $0x1,%eax
  800c03:	74 13                	je     800c18 <strncmp+0x34>
		n--, p++, q++;
  800c05:	83 c2 01             	add    $0x1,%edx
  800c08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c0b:	0f b6 1a             	movzbl (%edx),%ebx
  800c0e:	84 db                	test   %bl,%bl
  800c10:	74 0f                	je     800c21 <strncmp+0x3d>
  800c12:	3a 19                	cmp    (%ecx),%bl
  800c14:	74 ea                	je     800c00 <strncmp+0x1c>
  800c16:	eb 09                	jmp    800c21 <strncmp+0x3d>
  800c18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5d                   	pop    %ebp
  800c1f:	90                   	nop
  800c20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c21:	0f b6 02             	movzbl (%edx),%eax
  800c24:	0f b6 11             	movzbl (%ecx),%edx
  800c27:	29 d0                	sub    %edx,%eax
  800c29:	eb f2                	jmp    800c1d <strncmp+0x39>

00800c2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c35:	0f b6 10             	movzbl (%eax),%edx
  800c38:	84 d2                	test   %dl,%dl
  800c3a:	74 18                	je     800c54 <strchr+0x29>
		if (*s == c)
  800c3c:	38 ca                	cmp    %cl,%dl
  800c3e:	75 0a                	jne    800c4a <strchr+0x1f>
  800c40:	eb 17                	jmp    800c59 <strchr+0x2e>
  800c42:	38 ca                	cmp    %cl,%dl
  800c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c48:	74 0f                	je     800c59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	0f b6 10             	movzbl (%eax),%edx
  800c50:	84 d2                	test   %dl,%dl
  800c52:	75 ee                	jne    800c42 <strchr+0x17>
  800c54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c65:	0f b6 10             	movzbl (%eax),%edx
  800c68:	84 d2                	test   %dl,%dl
  800c6a:	74 18                	je     800c84 <strfind+0x29>
		if (*s == c)
  800c6c:	38 ca                	cmp    %cl,%dl
  800c6e:	75 0a                	jne    800c7a <strfind+0x1f>
  800c70:	eb 12                	jmp    800c84 <strfind+0x29>
  800c72:	38 ca                	cmp    %cl,%dl
  800c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c78:	74 0a                	je     800c84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	0f b6 10             	movzbl (%eax),%edx
  800c80:	84 d2                	test   %dl,%dl
  800c82:	75 ee                	jne    800c72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	89 1c 24             	mov    %ebx,(%esp)
  800c8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ca0:	85 c9                	test   %ecx,%ecx
  800ca2:	74 30                	je     800cd4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ca4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800caa:	75 25                	jne    800cd1 <memset+0x4b>
  800cac:	f6 c1 03             	test   $0x3,%cl
  800caf:	75 20                	jne    800cd1 <memset+0x4b>
		c &= 0xFF;
  800cb1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	c1 e3 08             	shl    $0x8,%ebx
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	c1 e6 18             	shl    $0x18,%esi
  800cbe:	89 d0                	mov    %edx,%eax
  800cc0:	c1 e0 10             	shl    $0x10,%eax
  800cc3:	09 f0                	or     %esi,%eax
  800cc5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800cc7:	09 d8                	or     %ebx,%eax
  800cc9:	c1 e9 02             	shr    $0x2,%ecx
  800ccc:	fc                   	cld    
  800ccd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ccf:	eb 03                	jmp    800cd4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cd1:	fc                   	cld    
  800cd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cd4:	89 f8                	mov    %edi,%eax
  800cd6:	8b 1c 24             	mov    (%esp),%ebx
  800cd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cdd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce1:	89 ec                	mov    %ebp,%esp
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
  800ceb:	89 34 24             	mov    %esi,(%esp)
  800cee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cfb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800cfd:	39 c6                	cmp    %eax,%esi
  800cff:	73 35                	jae    800d36 <memmove+0x51>
  800d01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d04:	39 d0                	cmp    %edx,%eax
  800d06:	73 2e                	jae    800d36 <memmove+0x51>
		s += n;
		d += n;
  800d08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0a:	f6 c2 03             	test   $0x3,%dl
  800d0d:	75 1b                	jne    800d2a <memmove+0x45>
  800d0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d15:	75 13                	jne    800d2a <memmove+0x45>
  800d17:	f6 c1 03             	test   $0x3,%cl
  800d1a:	75 0e                	jne    800d2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d1c:	83 ef 04             	sub    $0x4,%edi
  800d1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d22:	c1 e9 02             	shr    $0x2,%ecx
  800d25:	fd                   	std    
  800d26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d28:	eb 09                	jmp    800d33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d2a:	83 ef 01             	sub    $0x1,%edi
  800d2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d30:	fd                   	std    
  800d31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d34:	eb 20                	jmp    800d56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d3c:	75 15                	jne    800d53 <memmove+0x6e>
  800d3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d44:	75 0d                	jne    800d53 <memmove+0x6e>
  800d46:	f6 c1 03             	test   $0x3,%cl
  800d49:	75 08                	jne    800d53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d4b:	c1 e9 02             	shr    $0x2,%ecx
  800d4e:	fc                   	cld    
  800d4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d51:	eb 03                	jmp    800d56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d53:	fc                   	cld    
  800d54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d56:	8b 34 24             	mov    (%esp),%esi
  800d59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d5d:	89 ec                	mov    %ebp,%esp
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d67:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	89 04 24             	mov    %eax,(%esp)
  800d7b:	e8 65 ff ff ff       	call   800ce5 <memmove>
}
  800d80:	c9                   	leave  
  800d81:	c3                   	ret    

00800d82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	8b 75 08             	mov    0x8(%ebp),%esi
  800d8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d91:	85 c9                	test   %ecx,%ecx
  800d93:	74 36                	je     800dcb <memcmp+0x49>
		if (*s1 != *s2)
  800d95:	0f b6 06             	movzbl (%esi),%eax
  800d98:	0f b6 1f             	movzbl (%edi),%ebx
  800d9b:	38 d8                	cmp    %bl,%al
  800d9d:	74 20                	je     800dbf <memcmp+0x3d>
  800d9f:	eb 14                	jmp    800db5 <memcmp+0x33>
  800da1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800da6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800dab:	83 c2 01             	add    $0x1,%edx
  800dae:	83 e9 01             	sub    $0x1,%ecx
  800db1:	38 d8                	cmp    %bl,%al
  800db3:	74 12                	je     800dc7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800db5:	0f b6 c0             	movzbl %al,%eax
  800db8:	0f b6 db             	movzbl %bl,%ebx
  800dbb:	29 d8                	sub    %ebx,%eax
  800dbd:	eb 11                	jmp    800dd0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbf:	83 e9 01             	sub    $0x1,%ecx
  800dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc7:	85 c9                	test   %ecx,%ecx
  800dc9:	75 d6                	jne    800da1 <memcmp+0x1f>
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ddb:	89 c2                	mov    %eax,%edx
  800ddd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800de0:	39 d0                	cmp    %edx,%eax
  800de2:	73 15                	jae    800df9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800de8:	38 08                	cmp    %cl,(%eax)
  800dea:	75 06                	jne    800df2 <memfind+0x1d>
  800dec:	eb 0b                	jmp    800df9 <memfind+0x24>
  800dee:	38 08                	cmp    %cl,(%eax)
  800df0:	74 07                	je     800df9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800df2:	83 c0 01             	add    $0x1,%eax
  800df5:	39 c2                	cmp    %eax,%edx
  800df7:	77 f5                	ja     800dee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0a:	0f b6 02             	movzbl (%edx),%eax
  800e0d:	3c 20                	cmp    $0x20,%al
  800e0f:	74 04                	je     800e15 <strtol+0x1a>
  800e11:	3c 09                	cmp    $0x9,%al
  800e13:	75 0e                	jne    800e23 <strtol+0x28>
		s++;
  800e15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e18:	0f b6 02             	movzbl (%edx),%eax
  800e1b:	3c 20                	cmp    $0x20,%al
  800e1d:	74 f6                	je     800e15 <strtol+0x1a>
  800e1f:	3c 09                	cmp    $0x9,%al
  800e21:	74 f2                	je     800e15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e23:	3c 2b                	cmp    $0x2b,%al
  800e25:	75 0c                	jne    800e33 <strtol+0x38>
		s++;
  800e27:	83 c2 01             	add    $0x1,%edx
  800e2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e31:	eb 15                	jmp    800e48 <strtol+0x4d>
	else if (*s == '-')
  800e33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e3a:	3c 2d                	cmp    $0x2d,%al
  800e3c:	75 0a                	jne    800e48 <strtol+0x4d>
		s++, neg = 1;
  800e3e:	83 c2 01             	add    $0x1,%edx
  800e41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e48:	85 db                	test   %ebx,%ebx
  800e4a:	0f 94 c0             	sete   %al
  800e4d:	74 05                	je     800e54 <strtol+0x59>
  800e4f:	83 fb 10             	cmp    $0x10,%ebx
  800e52:	75 18                	jne    800e6c <strtol+0x71>
  800e54:	80 3a 30             	cmpb   $0x30,(%edx)
  800e57:	75 13                	jne    800e6c <strtol+0x71>
  800e59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e5d:	8d 76 00             	lea    0x0(%esi),%esi
  800e60:	75 0a                	jne    800e6c <strtol+0x71>
		s += 2, base = 16;
  800e62:	83 c2 02             	add    $0x2,%edx
  800e65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e6a:	eb 15                	jmp    800e81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e6c:	84 c0                	test   %al,%al
  800e6e:	66 90                	xchg   %ax,%ax
  800e70:	74 0f                	je     800e81 <strtol+0x86>
  800e72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e77:	80 3a 30             	cmpb   $0x30,(%edx)
  800e7a:	75 05                	jne    800e81 <strtol+0x86>
		s++, base = 8;
  800e7c:	83 c2 01             	add    $0x1,%edx
  800e7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e88:	0f b6 0a             	movzbl (%edx),%ecx
  800e8b:	89 cf                	mov    %ecx,%edi
  800e8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e90:	80 fb 09             	cmp    $0x9,%bl
  800e93:	77 08                	ja     800e9d <strtol+0xa2>
			dig = *s - '0';
  800e95:	0f be c9             	movsbl %cl,%ecx
  800e98:	83 e9 30             	sub    $0x30,%ecx
  800e9b:	eb 1e                	jmp    800ebb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ea0:	80 fb 19             	cmp    $0x19,%bl
  800ea3:	77 08                	ja     800ead <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ea5:	0f be c9             	movsbl %cl,%ecx
  800ea8:	83 e9 57             	sub    $0x57,%ecx
  800eab:	eb 0e                	jmp    800ebb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ead:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800eb0:	80 fb 19             	cmp    $0x19,%bl
  800eb3:	77 15                	ja     800eca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800eb5:	0f be c9             	movsbl %cl,%ecx
  800eb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ebb:	39 f1                	cmp    %esi,%ecx
  800ebd:	7d 0b                	jge    800eca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ebf:	83 c2 01             	add    $0x1,%edx
  800ec2:	0f af c6             	imul   %esi,%eax
  800ec5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ec8:	eb be                	jmp    800e88 <strtol+0x8d>
  800eca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ecc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed0:	74 05                	je     800ed7 <strtol+0xdc>
		*endptr = (char *) s;
  800ed2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ed5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ed7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800edb:	74 04                	je     800ee1 <strtol+0xe6>
  800edd:	89 c8                	mov    %ecx,%eax
  800edf:	f7 d8                	neg    %eax
}
  800ee1:	83 c4 04             	add    $0x4,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	00 00                	add    %al,(%eax)
	...

00800eec <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	89 1c 24             	mov    %ebx,(%esp)
  800ef5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ef9:	ba 00 00 00 00       	mov    $0x0,%edx
  800efe:	b8 01 00 00 00       	mov    $0x1,%eax
  800f03:	89 d1                	mov    %edx,%ecx
  800f05:	89 d3                	mov    %edx,%ebx
  800f07:	89 d7                	mov    %edx,%edi
  800f09:	51                   	push   %ecx
  800f0a:	52                   	push   %edx
  800f0b:	53                   	push   %ebx
  800f0c:	54                   	push   %esp
  800f0d:	55                   	push   %ebp
  800f0e:	56                   	push   %esi
  800f0f:	57                   	push   %edi
  800f10:	54                   	push   %esp
  800f11:	5d                   	pop    %ebp
  800f12:	8d 35 1a 0f 80 00    	lea    0x800f1a,%esi
  800f18:	0f 34                	sysenter 
  800f1a:	5f                   	pop    %edi
  800f1b:	5e                   	pop    %esi
  800f1c:	5d                   	pop    %ebp
  800f1d:	5c                   	pop    %esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5a                   	pop    %edx
  800f20:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f21:	8b 1c 24             	mov    (%esp),%ebx
  800f24:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f28:	89 ec                	mov    %ebp,%esp
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	89 c7                	mov    %eax,%edi
  800f48:	51                   	push   %ecx
  800f49:	52                   	push   %edx
  800f4a:	53                   	push   %ebx
  800f4b:	54                   	push   %esp
  800f4c:	55                   	push   %ebp
  800f4d:	56                   	push   %esi
  800f4e:	57                   	push   %edi
  800f4f:	54                   	push   %esp
  800f50:	5d                   	pop    %ebp
  800f51:	8d 35 59 0f 80 00    	lea    0x800f59,%esi
  800f57:	0f 34                	sysenter 
  800f59:	5f                   	pop    %edi
  800f5a:	5e                   	pop    %esi
  800f5b:	5d                   	pop    %ebp
  800f5c:	5c                   	pop    %esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5a                   	pop    %edx
  800f5f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f60:	8b 1c 24             	mov    (%esp),%ebx
  800f63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f67:	89 ec                	mov    %ebp,%esp
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	89 1c 24             	mov    %ebx,(%esp)
  800f74:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7d:	b8 13 00 00 00       	mov    $0x13,%eax
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
  800f85:	89 cb                	mov    %ecx,%ebx
  800f87:	89 cf                	mov    %ecx,%edi
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
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800fa1:	8b 1c 24             	mov    (%esp),%ebx
  800fa4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fa8:	89 ec                	mov    %ebp,%esp
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
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
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbe:	b8 12 00 00 00       	mov    $0x12,%eax
  800fc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc9:	89 df                	mov    %ebx,%edi
  800fcb:	51                   	push   %ecx
  800fcc:	52                   	push   %edx
  800fcd:	53                   	push   %ebx
  800fce:	54                   	push   %esp
  800fcf:	55                   	push   %ebp
  800fd0:	56                   	push   %esi
  800fd1:	57                   	push   %edi
  800fd2:	54                   	push   %esp
  800fd3:	5d                   	pop    %ebp
  800fd4:	8d 35 dc 0f 80 00    	lea    0x800fdc,%esi
  800fda:	0f 34                	sysenter 
  800fdc:	5f                   	pop    %edi
  800fdd:	5e                   	pop    %esi
  800fde:	5d                   	pop    %ebp
  800fdf:	5c                   	pop    %esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5a                   	pop    %edx
  800fe2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800fe3:	8b 1c 24             	mov    (%esp),%ebx
  800fe6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fea:	89 ec                	mov    %ebp,%esp
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	83 ec 08             	sub    $0x8,%esp
  800ff4:	89 1c 24             	mov    %ebx,(%esp)
  800ff7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ffb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801000:	b8 11 00 00 00       	mov    $0x11,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	89 df                	mov    %ebx,%edi
  80100d:	51                   	push   %ecx
  80100e:	52                   	push   %edx
  80100f:	53                   	push   %ebx
  801010:	54                   	push   %esp
  801011:	55                   	push   %ebp
  801012:	56                   	push   %esi
  801013:	57                   	push   %edi
  801014:	54                   	push   %esp
  801015:	5d                   	pop    %ebp
  801016:	8d 35 1e 10 80 00    	lea    0x80101e,%esi
  80101c:	0f 34                	sysenter 
  80101e:	5f                   	pop    %edi
  80101f:	5e                   	pop    %esi
  801020:	5d                   	pop    %ebp
  801021:	5c                   	pop    %esp
  801022:	5b                   	pop    %ebx
  801023:	5a                   	pop    %edx
  801024:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801025:	8b 1c 24             	mov    (%esp),%ebx
  801028:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80102c:	89 ec                	mov    %ebp,%esp
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	89 1c 24             	mov    %ebx,(%esp)
  801039:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80103d:	b8 10 00 00 00       	mov    $0x10,%eax
  801042:	8b 7d 14             	mov    0x14(%ebp),%edi
  801045:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801048:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	51                   	push   %ecx
  80104f:	52                   	push   %edx
  801050:	53                   	push   %ebx
  801051:	54                   	push   %esp
  801052:	55                   	push   %ebp
  801053:	56                   	push   %esi
  801054:	57                   	push   %edi
  801055:	54                   	push   %esp
  801056:	5d                   	pop    %ebp
  801057:	8d 35 5f 10 80 00    	lea    0x80105f,%esi
  80105d:	0f 34                	sysenter 
  80105f:	5f                   	pop    %edi
  801060:	5e                   	pop    %esi
  801061:	5d                   	pop    %ebp
  801062:	5c                   	pop    %esp
  801063:	5b                   	pop    %ebx
  801064:	5a                   	pop    %edx
  801065:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801066:	8b 1c 24             	mov    (%esp),%ebx
  801069:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80106d:	89 ec                	mov    %ebp,%esp
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 28             	sub    $0x28,%esp
  801077:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80107a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80107d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801082:	b8 0f 00 00 00       	mov    $0xf,%eax
  801087:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108a:	8b 55 08             	mov    0x8(%ebp),%edx
  80108d:	89 df                	mov    %ebx,%edi
  80108f:	51                   	push   %ecx
  801090:	52                   	push   %edx
  801091:	53                   	push   %ebx
  801092:	54                   	push   %esp
  801093:	55                   	push   %ebp
  801094:	56                   	push   %esi
  801095:	57                   	push   %edi
  801096:	54                   	push   %esp
  801097:	5d                   	pop    %ebp
  801098:	8d 35 a0 10 80 00    	lea    0x8010a0,%esi
  80109e:	0f 34                	sysenter 
  8010a0:	5f                   	pop    %edi
  8010a1:	5e                   	pop    %esi
  8010a2:	5d                   	pop    %ebp
  8010a3:	5c                   	pop    %esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5a                   	pop    %edx
  8010a6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	7e 28                	jle    8010d3 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010af:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8010b6:	00 
  8010b7:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  8010be:	00 
  8010bf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010c6:	00 
  8010c7:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  8010ce:	e8 b1 17 00 00       	call   802884 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8010d3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010d6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d9:	89 ec                	mov    %ebp,%esp
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	89 1c 24             	mov    %ebx,(%esp)
  8010e6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ef:	b8 15 00 00 00       	mov    $0x15,%eax
  8010f4:	89 d1                	mov    %edx,%ecx
  8010f6:	89 d3                	mov    %edx,%ebx
  8010f8:	89 d7                	mov    %edx,%edi
  8010fa:	51                   	push   %ecx
  8010fb:	52                   	push   %edx
  8010fc:	53                   	push   %ebx
  8010fd:	54                   	push   %esp
  8010fe:	55                   	push   %ebp
  8010ff:	56                   	push   %esi
  801100:	57                   	push   %edi
  801101:	54                   	push   %esp
  801102:	5d                   	pop    %ebp
  801103:	8d 35 0b 11 80 00    	lea    0x80110b,%esi
  801109:	0f 34                	sysenter 
  80110b:	5f                   	pop    %edi
  80110c:	5e                   	pop    %esi
  80110d:	5d                   	pop    %ebp
  80110e:	5c                   	pop    %esp
  80110f:	5b                   	pop    %ebx
  801110:	5a                   	pop    %edx
  801111:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801112:	8b 1c 24             	mov    (%esp),%ebx
  801115:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801119:	89 ec                	mov    %ebp,%esp
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
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
  80112a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112f:	b8 14 00 00 00       	mov    $0x14,%eax
  801134:	8b 55 08             	mov    0x8(%ebp),%edx
  801137:	89 cb                	mov    %ecx,%ebx
  801139:	89 cf                	mov    %ecx,%edi
  80113b:	51                   	push   %ecx
  80113c:	52                   	push   %edx
  80113d:	53                   	push   %ebx
  80113e:	54                   	push   %esp
  80113f:	55                   	push   %ebp
  801140:	56                   	push   %esi
  801141:	57                   	push   %edi
  801142:	54                   	push   %esp
  801143:	5d                   	pop    %ebp
  801144:	8d 35 4c 11 80 00    	lea    0x80114c,%esi
  80114a:	0f 34                	sysenter 
  80114c:	5f                   	pop    %edi
  80114d:	5e                   	pop    %esi
  80114e:	5d                   	pop    %ebp
  80114f:	5c                   	pop    %esp
  801150:	5b                   	pop    %ebx
  801151:	5a                   	pop    %edx
  801152:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801153:	8b 1c 24             	mov    (%esp),%ebx
  801156:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80115a:	89 ec                	mov    %ebp,%esp
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	83 ec 28             	sub    $0x28,%esp
  801164:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801167:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80116a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80116f:	b8 0e 00 00 00       	mov    $0xe,%eax
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801193:	85 c0                	test   %eax,%eax
  801195:	7e 28                	jle    8011bf <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801197:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011b2:	00 
  8011b3:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  8011ba:	e8 c5 16 00 00       	call   802884 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011bf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011c5:	89 ec                	mov    %ebp,%esp
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    

008011c9 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	89 1c 24             	mov    %ebx,(%esp)
  8011d2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011d6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e7:	51                   	push   %ecx
  8011e8:	52                   	push   %edx
  8011e9:	53                   	push   %ebx
  8011ea:	54                   	push   %esp
  8011eb:	55                   	push   %ebp
  8011ec:	56                   	push   %esi
  8011ed:	57                   	push   %edi
  8011ee:	54                   	push   %esp
  8011ef:	5d                   	pop    %ebp
  8011f0:	8d 35 f8 11 80 00    	lea    0x8011f8,%esi
  8011f6:	0f 34                	sysenter 
  8011f8:	5f                   	pop    %edi
  8011f9:	5e                   	pop    %esi
  8011fa:	5d                   	pop    %ebp
  8011fb:	5c                   	pop    %esp
  8011fc:	5b                   	pop    %ebx
  8011fd:	5a                   	pop    %edx
  8011fe:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011ff:	8b 1c 24             	mov    (%esp),%ebx
  801202:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801206:	89 ec                	mov    %ebp,%esp
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	83 ec 28             	sub    $0x28,%esp
  801210:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801213:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801223:	8b 55 08             	mov    0x8(%ebp),%edx
  801226:	89 df                	mov    %ebx,%edi
  801228:	51                   	push   %ecx
  801229:	52                   	push   %edx
  80122a:	53                   	push   %ebx
  80122b:	54                   	push   %esp
  80122c:	55                   	push   %ebp
  80122d:	56                   	push   %esi
  80122e:	57                   	push   %edi
  80122f:	54                   	push   %esp
  801230:	5d                   	pop    %ebp
  801231:	8d 35 39 12 80 00    	lea    0x801239,%esi
  801237:	0f 34                	sysenter 
  801239:	5f                   	pop    %edi
  80123a:	5e                   	pop    %esi
  80123b:	5d                   	pop    %ebp
  80123c:	5c                   	pop    %esp
  80123d:	5b                   	pop    %ebx
  80123e:	5a                   	pop    %edx
  80123f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801240:	85 c0                	test   %eax,%eax
  801242:	7e 28                	jle    80126c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801244:	89 44 24 10          	mov    %eax,0x10(%esp)
  801248:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80124f:	00 
  801250:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  801257:	00 
  801258:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80125f:	00 
  801260:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  801267:	e8 18 16 00 00       	call   802884 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80126c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80126f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801272:	89 ec                	mov    %ebp,%esp
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	83 ec 28             	sub    $0x28,%esp
  80127c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80127f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801282:	bb 00 00 00 00       	mov    $0x0,%ebx
  801287:	b8 0a 00 00 00       	mov    $0xa,%eax
  80128c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128f:	8b 55 08             	mov    0x8(%ebp),%edx
  801292:	89 df                	mov    %ebx,%edi
  801294:	51                   	push   %ecx
  801295:	52                   	push   %edx
  801296:	53                   	push   %ebx
  801297:	54                   	push   %esp
  801298:	55                   	push   %ebp
  801299:	56                   	push   %esi
  80129a:	57                   	push   %edi
  80129b:	54                   	push   %esp
  80129c:	5d                   	pop    %ebp
  80129d:	8d 35 a5 12 80 00    	lea    0x8012a5,%esi
  8012a3:	0f 34                	sysenter 
  8012a5:	5f                   	pop    %edi
  8012a6:	5e                   	pop    %esi
  8012a7:	5d                   	pop    %ebp
  8012a8:	5c                   	pop    %esp
  8012a9:	5b                   	pop    %ebx
  8012aa:	5a                   	pop    %edx
  8012ab:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	7e 28                	jle    8012d8 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012bb:	00 
  8012bc:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  8012c3:	00 
  8012c4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012cb:	00 
  8012cc:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  8012d3:	e8 ac 15 00 00       	call   802884 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012d8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012de:	89 ec                	mov    %ebp,%esp
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 28             	sub    $0x28,%esp
  8012e8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012eb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f3:	b8 09 00 00 00       	mov    $0x9,%eax
  8012f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fe:	89 df                	mov    %ebx,%edi
  801300:	51                   	push   %ecx
  801301:	52                   	push   %edx
  801302:	53                   	push   %ebx
  801303:	54                   	push   %esp
  801304:	55                   	push   %ebp
  801305:	56                   	push   %esi
  801306:	57                   	push   %edi
  801307:	54                   	push   %esp
  801308:	5d                   	pop    %ebp
  801309:	8d 35 11 13 80 00    	lea    0x801311,%esi
  80130f:	0f 34                	sysenter 
  801311:	5f                   	pop    %edi
  801312:	5e                   	pop    %esi
  801313:	5d                   	pop    %ebp
  801314:	5c                   	pop    %esp
  801315:	5b                   	pop    %ebx
  801316:	5a                   	pop    %edx
  801317:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801318:	85 c0                	test   %eax,%eax
  80131a:	7e 28                	jle    801344 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801320:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801327:	00 
  801328:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  80132f:	00 
  801330:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801337:	00 
  801338:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  80133f:	e8 40 15 00 00       	call   802884 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801344:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801347:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80134a:	89 ec                	mov    %ebp,%esp
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 28             	sub    $0x28,%esp
  801354:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801357:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80135a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135f:	b8 07 00 00 00       	mov    $0x7,%eax
  801364:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801367:	8b 55 08             	mov    0x8(%ebp),%edx
  80136a:	89 df                	mov    %ebx,%edi
  80136c:	51                   	push   %ecx
  80136d:	52                   	push   %edx
  80136e:	53                   	push   %ebx
  80136f:	54                   	push   %esp
  801370:	55                   	push   %ebp
  801371:	56                   	push   %esi
  801372:	57                   	push   %edi
  801373:	54                   	push   %esp
  801374:	5d                   	pop    %ebp
  801375:	8d 35 7d 13 80 00    	lea    0x80137d,%esi
  80137b:	0f 34                	sysenter 
  80137d:	5f                   	pop    %edi
  80137e:	5e                   	pop    %esi
  80137f:	5d                   	pop    %ebp
  801380:	5c                   	pop    %esp
  801381:	5b                   	pop    %ebx
  801382:	5a                   	pop    %edx
  801383:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801384:	85 c0                	test   %eax,%eax
  801386:	7e 28                	jle    8013b0 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801388:	89 44 24 10          	mov    %eax,0x10(%esp)
  80138c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801393:	00 
  801394:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  80139b:	00 
  80139c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013a3:	00 
  8013a4:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  8013ab:	e8 d4 14 00 00       	call   802884 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013b0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013b3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013b6:	89 ec                	mov    %ebp,%esp
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 28             	sub    $0x28,%esp
  8013c0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013c3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013c6:	8b 7d 18             	mov    0x18(%ebp),%edi
  8013c9:	0b 7d 14             	or     0x14(%ebp),%edi
  8013cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8013d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013da:	51                   	push   %ecx
  8013db:	52                   	push   %edx
  8013dc:	53                   	push   %ebx
  8013dd:	54                   	push   %esp
  8013de:	55                   	push   %ebp
  8013df:	56                   	push   %esi
  8013e0:	57                   	push   %edi
  8013e1:	54                   	push   %esp
  8013e2:	5d                   	pop    %ebp
  8013e3:	8d 35 eb 13 80 00    	lea    0x8013eb,%esi
  8013e9:	0f 34                	sysenter 
  8013eb:	5f                   	pop    %edi
  8013ec:	5e                   	pop    %esi
  8013ed:	5d                   	pop    %ebp
  8013ee:	5c                   	pop    %esp
  8013ef:	5b                   	pop    %ebx
  8013f0:	5a                   	pop    %edx
  8013f1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	7e 28                	jle    80141e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013fa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801401:	00 
  801402:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  801409:	00 
  80140a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801411:	00 
  801412:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  801419:	e8 66 14 00 00       	call   802884 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80141e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801421:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801424:	89 ec                	mov    %ebp,%esp
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 28             	sub    $0x28,%esp
  80142e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801431:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801434:	bf 00 00 00 00       	mov    $0x0,%edi
  801439:	b8 05 00 00 00       	mov    $0x5,%eax
  80143e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801441:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801444:	8b 55 08             	mov    0x8(%ebp),%edx
  801447:	51                   	push   %ecx
  801448:	52                   	push   %edx
  801449:	53                   	push   %ebx
  80144a:	54                   	push   %esp
  80144b:	55                   	push   %ebp
  80144c:	56                   	push   %esi
  80144d:	57                   	push   %edi
  80144e:	54                   	push   %esp
  80144f:	5d                   	pop    %ebp
  801450:	8d 35 58 14 80 00    	lea    0x801458,%esi
  801456:	0f 34                	sysenter 
  801458:	5f                   	pop    %edi
  801459:	5e                   	pop    %esi
  80145a:	5d                   	pop    %ebp
  80145b:	5c                   	pop    %esp
  80145c:	5b                   	pop    %ebx
  80145d:	5a                   	pop    %edx
  80145e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80145f:	85 c0                	test   %eax,%eax
  801461:	7e 28                	jle    80148b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801463:	89 44 24 10          	mov    %eax,0x10(%esp)
  801467:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80146e:	00 
  80146f:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  801476:	00 
  801477:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80147e:	00 
  80147f:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  801486:	e8 f9 13 00 00       	call   802884 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80148b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80148e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801491:	89 ec                	mov    %ebp,%esp
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	89 1c 24             	mov    %ebx,(%esp)
  80149e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014ac:	89 d1                	mov    %edx,%ecx
  8014ae:	89 d3                	mov    %edx,%ebx
  8014b0:	89 d7                	mov    %edx,%edi
  8014b2:	51                   	push   %ecx
  8014b3:	52                   	push   %edx
  8014b4:	53                   	push   %ebx
  8014b5:	54                   	push   %esp
  8014b6:	55                   	push   %ebp
  8014b7:	56                   	push   %esi
  8014b8:	57                   	push   %edi
  8014b9:	54                   	push   %esp
  8014ba:	5d                   	pop    %ebp
  8014bb:	8d 35 c3 14 80 00    	lea    0x8014c3,%esi
  8014c1:	0f 34                	sysenter 
  8014c3:	5f                   	pop    %edi
  8014c4:	5e                   	pop    %esi
  8014c5:	5d                   	pop    %ebp
  8014c6:	5c                   	pop    %esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5a                   	pop    %edx
  8014c9:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8014ca:	8b 1c 24             	mov    (%esp),%ebx
  8014cd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014d1:	89 ec                	mov    %ebp,%esp
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    

008014d5 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
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
  8014e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f2:	89 df                	mov    %ebx,%edi
  8014f4:	51                   	push   %ecx
  8014f5:	52                   	push   %edx
  8014f6:	53                   	push   %ebx
  8014f7:	54                   	push   %esp
  8014f8:	55                   	push   %ebp
  8014f9:	56                   	push   %esi
  8014fa:	57                   	push   %edi
  8014fb:	54                   	push   %esp
  8014fc:	5d                   	pop    %ebp
  8014fd:	8d 35 05 15 80 00    	lea    0x801505,%esi
  801503:	0f 34                	sysenter 
  801505:	5f                   	pop    %edi
  801506:	5e                   	pop    %esi
  801507:	5d                   	pop    %ebp
  801508:	5c                   	pop    %esp
  801509:	5b                   	pop    %ebx
  80150a:	5a                   	pop    %edx
  80150b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80150c:	8b 1c 24             	mov    (%esp),%ebx
  80150f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801513:	89 ec                	mov    %ebp,%esp
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	89 1c 24             	mov    %ebx,(%esp)
  801520:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	b8 02 00 00 00       	mov    $0x2,%eax
  80152e:	89 d1                	mov    %edx,%ecx
  801530:	89 d3                	mov    %edx,%ebx
  801532:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80154c:	8b 1c 24             	mov    (%esp),%ebx
  80154f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801553:	89 ec                	mov    %ebp,%esp
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	83 ec 28             	sub    $0x28,%esp
  80155d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801560:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801563:	b9 00 00 00 00       	mov    $0x0,%ecx
  801568:	b8 03 00 00 00       	mov    $0x3,%eax
  80156d:	8b 55 08             	mov    0x8(%ebp),%edx
  801570:	89 cb                	mov    %ecx,%ebx
  801572:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80158c:	85 c0                	test   %eax,%eax
  80158e:	7e 28                	jle    8015b8 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801590:	89 44 24 10          	mov    %eax,0x10(%esp)
  801594:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80159b:	00 
  80159c:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  8015a3:	00 
  8015a4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015ab:	00 
  8015ac:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  8015b3:	e8 cc 12 00 00       	call   802884 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015b8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015be:	89 ec                	mov    %ebp,%esp
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    
	...

008015c4 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8015ca:	c7 44 24 08 eb 2f 80 	movl   $0x802feb,0x8(%esp)
  8015d1:	00 
  8015d2:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  8015d9:	00 
  8015da:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  8015e1:	e8 9e 12 00 00       	call   802884 <_panic>

008015e6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	57                   	push   %edi
  8015ea:	56                   	push   %esi
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  8015ef:	c7 04 24 3b 18 80 00 	movl   $0x80183b,(%esp)
  8015f6:	e8 e1 12 00 00       	call   8028dc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015fb:	ba 08 00 00 00       	mov    $0x8,%edx
  801600:	89 d0                	mov    %edx,%eax
  801602:	cd 30                	int    $0x30
  801604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801607:	85 c0                	test   %eax,%eax
  801609:	79 20                	jns    80162b <fork+0x45>
		panic("sys_exofork: %e", envid);
  80160b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80160f:	c7 44 24 08 0c 30 80 	movl   $0x80300c,0x8(%esp)
  801616:	00 
  801617:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80161e:	00 
  80161f:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  801626:	e8 59 12 00 00       	call   802884 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  80162b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801630:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801635:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  80163a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80163e:	75 20                	jne    801660 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801640:	e8 d2 fe ff ff       	call   801517 <sys_getenvid>
  801645:	25 ff 03 00 00       	and    $0x3ff,%eax
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	c1 e2 07             	shl    $0x7,%edx
  80164f:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801656:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80165b:	e9 d0 01 00 00       	jmp    801830 <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801660:	89 d8                	mov    %ebx,%eax
  801662:	c1 e8 16             	shr    $0x16,%eax
  801665:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801668:	a8 01                	test   $0x1,%al
  80166a:	0f 84 0d 01 00 00    	je     80177d <fork+0x197>
  801670:	89 d8                	mov    %ebx,%eax
  801672:	c1 e8 0c             	shr    $0xc,%eax
  801675:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801678:	f6 c2 01             	test   $0x1,%dl
  80167b:	0f 84 fc 00 00 00    	je     80177d <fork+0x197>
  801681:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801684:	f6 c2 04             	test   $0x4,%dl
  801687:	0f 84 f0 00 00 00    	je     80177d <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  80168d:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  801690:	89 c2                	mov    %eax,%edx
  801692:	c1 ea 0c             	shr    $0xc,%edx
  801695:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  801698:	f6 c2 01             	test   $0x1,%dl
  80169b:	0f 84 dc 00 00 00    	je     80177d <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8016a1:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8016a7:	0f 84 8d 00 00 00    	je     80173a <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8016ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016b0:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8016b7:	00 
  8016b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016bf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ce:	e8 e7 fc ff ff       	call   8013ba <sys_page_map>
               if(r<0)
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	79 1c                	jns    8016f3 <fork+0x10d>
                 panic("map failed");
  8016d7:	c7 44 24 08 1c 30 80 	movl   $0x80301c,0x8(%esp)
  8016de:	00 
  8016df:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8016e6:	00 
  8016e7:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  8016ee:	e8 91 11 00 00       	call   802884 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  8016f3:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8016fa:	00 
  8016fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801702:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801709:	00 
  80170a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801715:	e8 a0 fc ff ff       	call   8013ba <sys_page_map>
               if(r<0)
  80171a:	85 c0                	test   %eax,%eax
  80171c:	79 5f                	jns    80177d <fork+0x197>
                 panic("map failed");
  80171e:	c7 44 24 08 1c 30 80 	movl   $0x80301c,0x8(%esp)
  801725:	00 
  801726:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80172d:	00 
  80172e:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  801735:	e8 4a 11 00 00       	call   802884 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  80173a:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801741:	00 
  801742:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801746:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801749:	89 54 24 08          	mov    %edx,0x8(%esp)
  80174d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801751:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801758:	e8 5d fc ff ff       	call   8013ba <sys_page_map>
               if(r<0)
  80175d:	85 c0                	test   %eax,%eax
  80175f:	79 1c                	jns    80177d <fork+0x197>
                 panic("map failed");
  801761:	c7 44 24 08 1c 30 80 	movl   $0x80301c,0x8(%esp)
  801768:	00 
  801769:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801770:	00 
  801771:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  801778:	e8 07 11 00 00       	call   802884 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80177d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801783:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801789:	0f 85 d1 fe ff ff    	jne    801660 <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80178f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801796:	00 
  801797:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80179e:	ee 
  80179f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	e8 7e fc ff ff       	call   801428 <sys_page_alloc>
        if(r < 0)
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	79 1c                	jns    8017ca <fork+0x1e4>
            panic("alloc failed");
  8017ae:	c7 44 24 08 27 30 80 	movl   $0x803027,0x8(%esp)
  8017b5:	00 
  8017b6:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8017bd:	00 
  8017be:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  8017c5:	e8 ba 10 00 00       	call   802884 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8017ca:	c7 44 24 04 28 29 80 	movl   $0x802928,0x4(%esp)
  8017d1:	00 
  8017d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d5:	89 14 24             	mov    %edx,(%esp)
  8017d8:	e8 2d fa ff ff       	call   80120a <sys_env_set_pgfault_upcall>
        if(r < 0)
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	79 1c                	jns    8017fd <fork+0x217>
            panic("set pgfault upcall failed");
  8017e1:	c7 44 24 08 34 30 80 	movl   $0x803034,0x8(%esp)
  8017e8:	00 
  8017e9:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8017f0:	00 
  8017f1:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  8017f8:	e8 87 10 00 00       	call   802884 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  8017fd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801804:	00 
  801805:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	e8 d2 fa ff ff       	call   8012e2 <sys_env_set_status>
        if(r < 0)
  801810:	85 c0                	test   %eax,%eax
  801812:	79 1c                	jns    801830 <fork+0x24a>
            panic("set status failed");
  801814:	c7 44 24 08 4e 30 80 	movl   $0x80304e,0x8(%esp)
  80181b:	00 
  80181c:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801823:	00 
  801824:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  80182b:	e8 54 10 00 00       	call   802884 <_panic>
        return envid;
	//panic("fork not implemented");
}
  801830:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801833:	83 c4 3c             	add    $0x3c,%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5f                   	pop    %edi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    

0080183b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	53                   	push   %ebx
  80183f:	83 ec 24             	sub    $0x24,%esp
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801845:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801847:	89 da                	mov    %ebx,%edx
  801849:	c1 ea 0c             	shr    $0xc,%edx
  80184c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  801853:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801857:	74 08                	je     801861 <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801859:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80185f:	75 1c                	jne    80187d <pgfault+0x42>
           panic("pgfault error");
  801861:	c7 44 24 08 60 30 80 	movl   $0x803060,0x8(%esp)
  801868:	00 
  801869:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801870:	00 
  801871:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  801878:	e8 07 10 00 00       	call   802884 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80187d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801884:	00 
  801885:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80188c:	00 
  80188d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801894:	e8 8f fb ff ff       	call   801428 <sys_page_alloc>
  801899:	85 c0                	test   %eax,%eax
  80189b:	79 20                	jns    8018bd <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  80189d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a1:	c7 44 24 08 6e 30 80 	movl   $0x80306e,0x8(%esp)
  8018a8:	00 
  8018a9:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8018b0:	00 
  8018b1:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  8018b8:	e8 c7 0f 00 00       	call   802884 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  8018bd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8018c3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018ca:	00 
  8018cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018cf:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8018d6:	e8 0a f4 ff ff       	call   800ce5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  8018db:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018e2:	00 
  8018e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8018e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018ee:	00 
  8018ef:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018f6:	00 
  8018f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fe:	e8 b7 fa ff ff       	call   8013ba <sys_page_map>
  801903:	85 c0                	test   %eax,%eax
  801905:	79 20                	jns    801927 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801907:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80190b:	c7 44 24 08 81 30 80 	movl   $0x803081,0x8(%esp)
  801912:	00 
  801913:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80191a:	00 
  80191b:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  801922:	e8 5d 0f 00 00       	call   802884 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801927:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80192e:	00 
  80192f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801936:	e8 13 fa ff ff       	call   80134e <sys_page_unmap>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	79 20                	jns    80195f <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80193f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801943:	c7 44 24 08 92 30 80 	movl   $0x803092,0x8(%esp)
  80194a:	00 
  80194b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801952:	00 
  801953:	c7 04 24 01 30 80 00 	movl   $0x803001,(%esp)
  80195a:	e8 25 0f 00 00       	call   802884 <_panic>
	//panic("pgfault not implemented");
}
  80195f:	83 c4 24             	add    $0x24,%esp
  801962:	5b                   	pop    %ebx
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    
	...

00801970 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801976:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80197c:	b8 01 00 00 00       	mov    $0x1,%eax
  801981:	39 ca                	cmp    %ecx,%edx
  801983:	75 04                	jne    801989 <ipc_find_env+0x19>
  801985:	b0 00                	mov    $0x0,%al
  801987:	eb 12                	jmp    80199b <ipc_find_env+0x2b>
  801989:	89 c2                	mov    %eax,%edx
  80198b:	c1 e2 07             	shl    $0x7,%edx
  80198e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801995:	8b 12                	mov    (%edx),%edx
  801997:	39 ca                	cmp    %ecx,%edx
  801999:	75 10                	jne    8019ab <ipc_find_env+0x3b>
			return envs[i].env_id;
  80199b:	89 c2                	mov    %eax,%edx
  80199d:	c1 e2 07             	shl    $0x7,%edx
  8019a0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8019a7:	8b 00                	mov    (%eax),%eax
  8019a9:	eb 0e                	jmp    8019b9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019ab:	83 c0 01             	add    $0x1,%eax
  8019ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019b3:	75 d4                	jne    801989 <ipc_find_env+0x19>
  8019b5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	57                   	push   %edi
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 1c             	sub    $0x1c,%esp
  8019c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8019cd:	85 db                	test   %ebx,%ebx
  8019cf:	74 19                	je     8019ea <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8019d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019e0:	89 34 24             	mov    %esi,(%esp)
  8019e3:	e8 e1 f7 ff ff       	call   8011c9 <sys_ipc_try_send>
  8019e8:	eb 1b                	jmp    801a05 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8019ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8019f8:	ee 
  8019f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019fd:	89 34 24             	mov    %esi,(%esp)
  801a00:	e8 c4 f7 ff ff       	call   8011c9 <sys_ipc_try_send>
           if(ret == 0)
  801a05:	85 c0                	test   %eax,%eax
  801a07:	74 28                	je     801a31 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801a09:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a0c:	74 1c                	je     801a2a <ipc_send+0x6f>
              panic("ipc send error");
  801a0e:	c7 44 24 08 a5 30 80 	movl   $0x8030a5,0x8(%esp)
  801a15:	00 
  801a16:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801a1d:	00 
  801a1e:	c7 04 24 b4 30 80 00 	movl   $0x8030b4,(%esp)
  801a25:	e8 5a 0e 00 00       	call   802884 <_panic>
           sys_yield();
  801a2a:	e8 66 fa ff ff       	call   801495 <sys_yield>
        }
  801a2f:	eb 9c                	jmp    8019cd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801a31:	83 c4 1c             	add    $0x1c,%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5f                   	pop    %edi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	83 ec 10             	sub    $0x10,%esp
  801a41:	8b 75 08             	mov    0x8(%ebp),%esi
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	75 0e                	jne    801a5c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801a4e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801a55:	e8 04 f7 ff ff       	call   80115e <sys_ipc_recv>
  801a5a:	eb 08                	jmp    801a64 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	e8 fa f6 ff ff       	call   80115e <sys_ipc_recv>
        if(ret == 0){
  801a64:	85 c0                	test   %eax,%eax
  801a66:	75 26                	jne    801a8e <ipc_recv+0x55>
           if(from_env_store)
  801a68:	85 f6                	test   %esi,%esi
  801a6a:	74 0a                	je     801a76 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801a6c:	a1 08 50 80 00       	mov    0x805008,%eax
  801a71:	8b 40 78             	mov    0x78(%eax),%eax
  801a74:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801a76:	85 db                	test   %ebx,%ebx
  801a78:	74 0a                	je     801a84 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801a7a:	a1 08 50 80 00       	mov    0x805008,%eax
  801a7f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801a82:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801a84:	a1 08 50 80 00       	mov    0x805008,%eax
  801a89:	8b 40 74             	mov    0x74(%eax),%eax
  801a8c:	eb 14                	jmp    801aa2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801a8e:	85 f6                	test   %esi,%esi
  801a90:	74 06                	je     801a98 <ipc_recv+0x5f>
              *from_env_store = 0;
  801a92:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801a98:	85 db                	test   %ebx,%ebx
  801a9a:	74 06                	je     801aa2 <ipc_recv+0x69>
              *perm_store = 0;
  801a9c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    
  801aa9:	00 00                	add    %al,(%eax)
  801aab:	00 00                	add    %al,(%eax)
  801aad:	00 00                	add    %al,(%eax)
	...

00801ab0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	05 00 00 00 30       	add    $0x30000000,%eax
  801abb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    

00801ac0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac9:	89 04 24             	mov    %eax,(%esp)
  801acc:	e8 df ff ff ff       	call   801ab0 <fd2num>
  801ad1:	05 20 00 0d 00       	add    $0xd0020,%eax
  801ad6:	c1 e0 0c             	shl    $0xc,%eax
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	57                   	push   %edi
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801ae4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801ae9:	a8 01                	test   $0x1,%al
  801aeb:	74 36                	je     801b23 <fd_alloc+0x48>
  801aed:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801af2:	a8 01                	test   $0x1,%al
  801af4:	74 2d                	je     801b23 <fd_alloc+0x48>
  801af6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801afb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801b00:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	89 c2                	mov    %eax,%edx
  801b09:	c1 ea 16             	shr    $0x16,%edx
  801b0c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801b0f:	f6 c2 01             	test   $0x1,%dl
  801b12:	74 14                	je     801b28 <fd_alloc+0x4d>
  801b14:	89 c2                	mov    %eax,%edx
  801b16:	c1 ea 0c             	shr    $0xc,%edx
  801b19:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801b1c:	f6 c2 01             	test   $0x1,%dl
  801b1f:	75 10                	jne    801b31 <fd_alloc+0x56>
  801b21:	eb 05                	jmp    801b28 <fd_alloc+0x4d>
  801b23:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801b28:	89 1f                	mov    %ebx,(%edi)
  801b2a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801b2f:	eb 17                	jmp    801b48 <fd_alloc+0x6d>
  801b31:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801b36:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801b3b:	75 c8                	jne    801b05 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801b3d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b43:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5f                   	pop    %edi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	83 f8 1f             	cmp    $0x1f,%eax
  801b56:	77 36                	ja     801b8e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801b58:	05 00 00 0d 00       	add    $0xd0000,%eax
  801b5d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	c1 ea 16             	shr    $0x16,%edx
  801b65:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b6c:	f6 c2 01             	test   $0x1,%dl
  801b6f:	74 1d                	je     801b8e <fd_lookup+0x41>
  801b71:	89 c2                	mov    %eax,%edx
  801b73:	c1 ea 0c             	shr    $0xc,%edx
  801b76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b7d:	f6 c2 01             	test   $0x1,%dl
  801b80:	74 0c                	je     801b8e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801b82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b85:	89 02                	mov    %eax,(%edx)
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801b8c:	eb 05                	jmp    801b93 <fd_lookup+0x46>
  801b8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b9b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba5:	89 04 24             	mov    %eax,(%esp)
  801ba8:	e8 a0 ff ff ff       	call   801b4d <fd_lookup>
  801bad:	85 c0                	test   %eax,%eax
  801baf:	78 0e                	js     801bbf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801bb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb7:	89 50 04             	mov    %edx,0x4(%eax)
  801bba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801bbf:	c9                   	leave  
  801bc0:	c3                   	ret    

00801bc1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	83 ec 10             	sub    $0x10,%esp
  801bc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801bcf:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801bd4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801bd9:	be 3c 31 80 00       	mov    $0x80313c,%esi
		if (devtab[i]->dev_id == dev_id) {
  801bde:	39 08                	cmp    %ecx,(%eax)
  801be0:	75 10                	jne    801bf2 <dev_lookup+0x31>
  801be2:	eb 04                	jmp    801be8 <dev_lookup+0x27>
  801be4:	39 08                	cmp    %ecx,(%eax)
  801be6:	75 0a                	jne    801bf2 <dev_lookup+0x31>
			*dev = devtab[i];
  801be8:	89 03                	mov    %eax,(%ebx)
  801bea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801bef:	90                   	nop
  801bf0:	eb 31                	jmp    801c23 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801bf2:	83 c2 01             	add    $0x1,%edx
  801bf5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	75 e8                	jne    801be4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801bfc:	a1 08 50 80 00       	mov    0x805008,%eax
  801c01:	8b 40 48             	mov    0x48(%eax),%eax
  801c04:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0c:	c7 04 24 c0 30 80 00 	movl   $0x8030c0,(%esp)
  801c13:	e8 b1 e5 ff ff       	call   8001c9 <cprintf>
	*dev = 0;
  801c18:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	53                   	push   %ebx
  801c2e:	83 ec 24             	sub    $0x24,%esp
  801c31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 07 ff ff ff       	call   801b4d <fd_lookup>
  801c46:	85 c0                	test   %eax,%eax
  801c48:	78 53                	js     801c9d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c54:	8b 00                	mov    (%eax),%eax
  801c56:	89 04 24             	mov    %eax,(%esp)
  801c59:	e8 63 ff ff ff       	call   801bc1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	78 3b                	js     801c9d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801c62:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801c6e:	74 2d                	je     801c9d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c70:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c73:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c7a:	00 00 00 
	stat->st_isdir = 0;
  801c7d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c84:	00 00 00 
	stat->st_dev = dev;
  801c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c94:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c97:	89 14 24             	mov    %edx,(%esp)
  801c9a:	ff 50 14             	call   *0x14(%eax)
}
  801c9d:	83 c4 24             	add    $0x24,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 24             	sub    $0x24,%esp
  801caa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb4:	89 1c 24             	mov    %ebx,(%esp)
  801cb7:	e8 91 fe ff ff       	call   801b4d <fd_lookup>
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	78 5f                	js     801d1f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cca:	8b 00                	mov    (%eax),%eax
  801ccc:	89 04 24             	mov    %eax,(%esp)
  801ccf:	e8 ed fe ff ff       	call   801bc1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	78 47                	js     801d1f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cdb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801cdf:	75 23                	jne    801d04 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ce1:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801ce6:	8b 40 48             	mov    0x48(%eax),%eax
  801ce9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf1:	c7 04 24 e0 30 80 00 	movl   $0x8030e0,(%esp)
  801cf8:	e8 cc e4 ff ff       	call   8001c9 <cprintf>
  801cfd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801d02:	eb 1b                	jmp    801d1f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d07:	8b 48 18             	mov    0x18(%eax),%ecx
  801d0a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d0f:	85 c9                	test   %ecx,%ecx
  801d11:	74 0c                	je     801d1f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801d13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1a:	89 14 24             	mov    %edx,(%esp)
  801d1d:	ff d1                	call   *%ecx
}
  801d1f:	83 c4 24             	add    $0x24,%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	53                   	push   %ebx
  801d29:	83 ec 24             	sub    $0x24,%esp
  801d2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d36:	89 1c 24             	mov    %ebx,(%esp)
  801d39:	e8 0f fe ff ff       	call   801b4d <fd_lookup>
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 66                	js     801da8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4c:	8b 00                	mov    (%eax),%eax
  801d4e:	89 04 24             	mov    %eax,(%esp)
  801d51:	e8 6b fe ff ff       	call   801bc1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 4e                	js     801da8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d5a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d5d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801d61:	75 23                	jne    801d86 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d63:	a1 08 50 80 00       	mov    0x805008,%eax
  801d68:	8b 40 48             	mov    0x48(%eax),%eax
  801d6b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d73:	c7 04 24 01 31 80 00 	movl   $0x803101,(%esp)
  801d7a:	e8 4a e4 ff ff       	call   8001c9 <cprintf>
  801d7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801d84:	eb 22                	jmp    801da8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d89:	8b 48 0c             	mov    0xc(%eax),%ecx
  801d8c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d91:	85 c9                	test   %ecx,%ecx
  801d93:	74 13                	je     801da8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d95:	8b 45 10             	mov    0x10(%ebp),%eax
  801d98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da3:	89 14 24             	mov    %edx,(%esp)
  801da6:	ff d1                	call   *%ecx
}
  801da8:	83 c4 24             	add    $0x24,%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	53                   	push   %ebx
  801db2:	83 ec 24             	sub    $0x24,%esp
  801db5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801db8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dbf:	89 1c 24             	mov    %ebx,(%esp)
  801dc2:	e8 86 fd ff ff       	call   801b4d <fd_lookup>
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 6b                	js     801e36 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd5:	8b 00                	mov    (%eax),%eax
  801dd7:	89 04 24             	mov    %eax,(%esp)
  801dda:	e8 e2 fd ff ff       	call   801bc1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	78 53                	js     801e36 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801de3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801de6:	8b 42 08             	mov    0x8(%edx),%eax
  801de9:	83 e0 03             	and    $0x3,%eax
  801dec:	83 f8 01             	cmp    $0x1,%eax
  801def:	75 23                	jne    801e14 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801df1:	a1 08 50 80 00       	mov    0x805008,%eax
  801df6:	8b 40 48             	mov    0x48(%eax),%eax
  801df9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e01:	c7 04 24 1e 31 80 00 	movl   $0x80311e,(%esp)
  801e08:	e8 bc e3 ff ff       	call   8001c9 <cprintf>
  801e0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801e12:	eb 22                	jmp    801e36 <read+0x88>
	}
	if (!dev->dev_read)
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	8b 48 08             	mov    0x8(%eax),%ecx
  801e1a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e1f:	85 c9                	test   %ecx,%ecx
  801e21:	74 13                	je     801e36 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801e23:	8b 45 10             	mov    0x10(%ebp),%eax
  801e26:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e31:	89 14 24             	mov    %edx,(%esp)
  801e34:	ff d1                	call   *%ecx
}
  801e36:	83 c4 24             	add    $0x24,%esp
  801e39:	5b                   	pop    %ebx
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	57                   	push   %edi
  801e40:	56                   	push   %esi
  801e41:	53                   	push   %ebx
  801e42:	83 ec 1c             	sub    $0x1c,%esp
  801e45:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e48:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e55:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5a:	85 f6                	test   %esi,%esi
  801e5c:	74 29                	je     801e87 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801e5e:	89 f0                	mov    %esi,%eax
  801e60:	29 d0                	sub    %edx,%eax
  801e62:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e66:	03 55 0c             	add    0xc(%ebp),%edx
  801e69:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e6d:	89 3c 24             	mov    %edi,(%esp)
  801e70:	e8 39 ff ff ff       	call   801dae <read>
		if (m < 0)
  801e75:	85 c0                	test   %eax,%eax
  801e77:	78 0e                	js     801e87 <readn+0x4b>
			return m;
		if (m == 0)
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	74 08                	je     801e85 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e7d:	01 c3                	add    %eax,%ebx
  801e7f:	89 da                	mov    %ebx,%edx
  801e81:	39 f3                	cmp    %esi,%ebx
  801e83:	72 d9                	jb     801e5e <readn+0x22>
  801e85:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801e87:	83 c4 1c             	add    $0x1c,%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	56                   	push   %esi
  801e93:	53                   	push   %ebx
  801e94:	83 ec 20             	sub    $0x20,%esp
  801e97:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801e9a:	89 34 24             	mov    %esi,(%esp)
  801e9d:	e8 0e fc ff ff       	call   801ab0 <fd2num>
  801ea2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ea5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ea9:	89 04 24             	mov    %eax,(%esp)
  801eac:	e8 9c fc ff ff       	call   801b4d <fd_lookup>
  801eb1:	89 c3                	mov    %eax,%ebx
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	78 05                	js     801ebc <fd_close+0x2d>
  801eb7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801eba:	74 0c                	je     801ec8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801ebc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801ec0:	19 c0                	sbb    %eax,%eax
  801ec2:	f7 d0                	not    %eax
  801ec4:	21 c3                	and    %eax,%ebx
  801ec6:	eb 3d                	jmp    801f05 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ec8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecf:	8b 06                	mov    (%esi),%eax
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 e8 fc ff ff       	call   801bc1 <dev_lookup>
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 16                	js     801ef5 <fd_close+0x66>
		if (dev->dev_close)
  801edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee2:	8b 40 10             	mov    0x10(%eax),%eax
  801ee5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eea:	85 c0                	test   %eax,%eax
  801eec:	74 07                	je     801ef5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801eee:	89 34 24             	mov    %esi,(%esp)
  801ef1:	ff d0                	call   *%eax
  801ef3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ef5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f00:	e8 49 f4 ff ff       	call   80134e <sys_page_unmap>
	return r;
}
  801f05:	89 d8                	mov    %ebx,%eax
  801f07:	83 c4 20             	add    $0x20,%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	89 04 24             	mov    %eax,(%esp)
  801f21:	e8 27 fc ff ff       	call   801b4d <fd_lookup>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 13                	js     801f3d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801f2a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f31:	00 
  801f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f35:	89 04 24             	mov    %eax,(%esp)
  801f38:	e8 52 ff ff ff       	call   801e8f <fd_close>
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 18             	sub    $0x18,%esp
  801f45:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f48:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801f4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f52:	00 
  801f53:	8b 45 08             	mov    0x8(%ebp),%eax
  801f56:	89 04 24             	mov    %eax,(%esp)
  801f59:	e8 79 03 00 00       	call   8022d7 <open>
  801f5e:	89 c3                	mov    %eax,%ebx
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 1b                	js     801f7f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6b:	89 1c 24             	mov    %ebx,(%esp)
  801f6e:	e8 b7 fc ff ff       	call   801c2a <fstat>
  801f73:	89 c6                	mov    %eax,%esi
	close(fd);
  801f75:	89 1c 24             	mov    %ebx,(%esp)
  801f78:	e8 91 ff ff ff       	call   801f0e <close>
  801f7d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801f7f:	89 d8                	mov    %ebx,%eax
  801f81:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f84:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f87:	89 ec                	mov    %ebp,%esp
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 14             	sub    $0x14,%esp
  801f92:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801f97:	89 1c 24             	mov    %ebx,(%esp)
  801f9a:	e8 6f ff ff ff       	call   801f0e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801f9f:	83 c3 01             	add    $0x1,%ebx
  801fa2:	83 fb 20             	cmp    $0x20,%ebx
  801fa5:	75 f0                	jne    801f97 <close_all+0xc>
		close(i);
}
  801fa7:	83 c4 14             	add    $0x14,%esp
  801faa:	5b                   	pop    %ebx
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    

00801fad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 58             	sub    $0x58,%esp
  801fb3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fb6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801fb9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801fbc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801fbf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc9:	89 04 24             	mov    %eax,(%esp)
  801fcc:	e8 7c fb ff ff       	call   801b4d <fd_lookup>
  801fd1:	89 c3                	mov    %eax,%ebx
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	0f 88 e0 00 00 00    	js     8020bb <dup+0x10e>
		return r;
	close(newfdnum);
  801fdb:	89 3c 24             	mov    %edi,(%esp)
  801fde:	e8 2b ff ff ff       	call   801f0e <close>

	newfd = INDEX2FD(newfdnum);
  801fe3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801fe9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801fec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fef:	89 04 24             	mov    %eax,(%esp)
  801ff2:	e8 c9 fa ff ff       	call   801ac0 <fd2data>
  801ff7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ff9:	89 34 24             	mov    %esi,(%esp)
  801ffc:	e8 bf fa ff ff       	call   801ac0 <fd2data>
  802001:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  802004:	89 da                	mov    %ebx,%edx
  802006:	89 d8                	mov    %ebx,%eax
  802008:	c1 e8 16             	shr    $0x16,%eax
  80200b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802012:	a8 01                	test   $0x1,%al
  802014:	74 43                	je     802059 <dup+0xac>
  802016:	c1 ea 0c             	shr    $0xc,%edx
  802019:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802020:	a8 01                	test   $0x1,%al
  802022:	74 35                	je     802059 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802024:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80202b:	25 07 0e 00 00       	and    $0xe07,%eax
  802030:	89 44 24 10          	mov    %eax,0x10(%esp)
  802034:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802037:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802042:	00 
  802043:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802047:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204e:	e8 67 f3 ff ff       	call   8013ba <sys_page_map>
  802053:	89 c3                	mov    %eax,%ebx
  802055:	85 c0                	test   %eax,%eax
  802057:	78 3f                	js     802098 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80205c:	89 c2                	mov    %eax,%edx
  80205e:	c1 ea 0c             	shr    $0xc,%edx
  802061:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802068:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80206e:	89 54 24 10          	mov    %edx,0x10(%esp)
  802072:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802076:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80207d:	00 
  80207e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802082:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802089:	e8 2c f3 ff ff       	call   8013ba <sys_page_map>
  80208e:	89 c3                	mov    %eax,%ebx
  802090:	85 c0                	test   %eax,%eax
  802092:	78 04                	js     802098 <dup+0xeb>
  802094:	89 fb                	mov    %edi,%ebx
  802096:	eb 23                	jmp    8020bb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802098:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a3:	e8 a6 f2 ff ff       	call   80134e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8020a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8020ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b6:	e8 93 f2 ff ff       	call   80134e <sys_page_unmap>
	return r;
}
  8020bb:	89 d8                	mov    %ebx,%eax
  8020bd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8020c0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8020c3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8020c6:	89 ec                	mov    %ebp,%esp
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    
	...

008020cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	83 ec 18             	sub    $0x18,%esp
  8020d2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8020d5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8020d8:	89 c3                	mov    %eax,%ebx
  8020da:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8020dc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8020e3:	75 11                	jne    8020f6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8020e5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8020ec:	e8 7f f8 ff ff       	call   801970 <ipc_find_env>
  8020f1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8020f6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020fd:	00 
  8020fe:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802105:	00 
  802106:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80210a:	a1 00 50 80 00       	mov    0x805000,%eax
  80210f:	89 04 24             	mov    %eax,(%esp)
  802112:	e8 a4 f8 ff ff       	call   8019bb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80211e:	00 
  80211f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802123:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80212a:	e8 0a f9 ff ff       	call   801a39 <ipc_recv>
}
  80212f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802132:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802135:	89 ec                	mov    %ebp,%esp
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    

00802139 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80213f:	8b 45 08             	mov    0x8(%ebp),%eax
  802142:	8b 40 0c             	mov    0xc(%eax),%eax
  802145:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80214a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802152:	ba 00 00 00 00       	mov    $0x0,%edx
  802157:	b8 02 00 00 00       	mov    $0x2,%eax
  80215c:	e8 6b ff ff ff       	call   8020cc <fsipc>
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    

00802163 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802169:	8b 45 08             	mov    0x8(%ebp),%eax
  80216c:	8b 40 0c             	mov    0xc(%eax),%eax
  80216f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802174:	ba 00 00 00 00       	mov    $0x0,%edx
  802179:	b8 06 00 00 00       	mov    $0x6,%eax
  80217e:	e8 49 ff ff ff       	call   8020cc <fsipc>
}
  802183:	c9                   	leave  
  802184:	c3                   	ret    

00802185 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802185:	55                   	push   %ebp
  802186:	89 e5                	mov    %esp,%ebp
  802188:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80218b:	ba 00 00 00 00       	mov    $0x0,%edx
  802190:	b8 08 00 00 00       	mov    $0x8,%eax
  802195:	e8 32 ff ff ff       	call   8020cc <fsipc>
}
  80219a:	c9                   	leave  
  80219b:	c3                   	ret    

0080219c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	53                   	push   %ebx
  8021a0:	83 ec 14             	sub    $0x14,%esp
  8021a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8021ac:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8021b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8021bb:	e8 0c ff ff ff       	call   8020cc <fsipc>
  8021c0:	85 c0                	test   %eax,%eax
  8021c2:	78 2b                	js     8021ef <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8021c4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8021cb:	00 
  8021cc:	89 1c 24             	mov    %ebx,(%esp)
  8021cf:	e8 26 e9 ff ff       	call   800afa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8021d4:	a1 80 60 80 00       	mov    0x806080,%eax
  8021d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8021df:	a1 84 60 80 00       	mov    0x806084,%eax
  8021e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8021ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8021ef:	83 c4 14             	add    $0x14,%esp
  8021f2:	5b                   	pop    %ebx
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 18             	sub    $0x18,%esp
  8021fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8021fe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802203:	76 05                	jbe    80220a <devfile_write+0x15>
  802205:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  80220a:	8b 55 08             	mov    0x8(%ebp),%edx
  80220d:	8b 52 0c             	mov    0xc(%edx),%edx
  802210:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  802216:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  80221b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80221f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802222:	89 44 24 04          	mov    %eax,0x4(%esp)
  802226:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80222d:	e8 b3 ea ff ff       	call   800ce5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  802232:	ba 00 00 00 00       	mov    $0x0,%edx
  802237:	b8 04 00 00 00       	mov    $0x4,%eax
  80223c:	e8 8b fe ff ff       	call   8020cc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802241:	c9                   	leave  
  802242:	c3                   	ret    

00802243 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802243:	55                   	push   %ebp
  802244:	89 e5                	mov    %esp,%ebp
  802246:	53                   	push   %ebx
  802247:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80224a:	8b 45 08             	mov    0x8(%ebp),%eax
  80224d:	8b 40 0c             	mov    0xc(%eax),%eax
  802250:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  802255:	8b 45 10             	mov    0x10(%ebp),%eax
  802258:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  80225d:	ba 00 00 00 00       	mov    $0x0,%edx
  802262:	b8 03 00 00 00       	mov    $0x3,%eax
  802267:	e8 60 fe ff ff       	call   8020cc <fsipc>
  80226c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80226e:	85 c0                	test   %eax,%eax
  802270:	78 17                	js     802289 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802272:	89 44 24 08          	mov    %eax,0x8(%esp)
  802276:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80227d:	00 
  80227e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802281:	89 04 24             	mov    %eax,(%esp)
  802284:	e8 5c ea ff ff       	call   800ce5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802289:	89 d8                	mov    %ebx,%eax
  80228b:	83 c4 14             	add    $0x14,%esp
  80228e:	5b                   	pop    %ebx
  80228f:	5d                   	pop    %ebp
  802290:	c3                   	ret    

00802291 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	53                   	push   %ebx
  802295:	83 ec 14             	sub    $0x14,%esp
  802298:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80229b:	89 1c 24             	mov    %ebx,(%esp)
  80229e:	e8 0d e8 ff ff       	call   800ab0 <strlen>
  8022a3:	89 c2                	mov    %eax,%edx
  8022a5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8022aa:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8022b0:	7f 1f                	jg     8022d1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8022b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022b6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8022bd:	e8 38 e8 ff ff       	call   800afa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8022c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c7:	b8 07 00 00 00       	mov    $0x7,%eax
  8022cc:	e8 fb fd ff ff       	call   8020cc <fsipc>
}
  8022d1:	83 c4 14             	add    $0x14,%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5d                   	pop    %ebp
  8022d6:	c3                   	ret    

008022d7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	83 ec 28             	sub    $0x28,%esp
  8022dd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8022e0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8022e3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  8022e6:	89 34 24             	mov    %esi,(%esp)
  8022e9:	e8 c2 e7 ff ff       	call   800ab0 <strlen>
  8022ee:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8022f3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022f8:	7f 6d                	jg     802367 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8022fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fd:	89 04 24             	mov    %eax,(%esp)
  802300:	e8 d6 f7 ff ff       	call   801adb <fd_alloc>
  802305:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  802307:	85 c0                	test   %eax,%eax
  802309:	78 5c                	js     802367 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80230b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  802313:	89 34 24             	mov    %esi,(%esp)
  802316:	e8 95 e7 ff ff       	call   800ab0 <strlen>
  80231b:	83 c0 01             	add    $0x1,%eax
  80231e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802322:	89 74 24 04          	mov    %esi,0x4(%esp)
  802326:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80232d:	e8 b3 e9 ff ff       	call   800ce5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  802332:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802335:	b8 01 00 00 00       	mov    $0x1,%eax
  80233a:	e8 8d fd ff ff       	call   8020cc <fsipc>
  80233f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802341:	85 c0                	test   %eax,%eax
  802343:	79 15                	jns    80235a <open+0x83>
             fd_close(fd,0);
  802345:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80234c:	00 
  80234d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802350:	89 04 24             	mov    %eax,(%esp)
  802353:	e8 37 fb ff ff       	call   801e8f <fd_close>
             return r;
  802358:	eb 0d                	jmp    802367 <open+0x90>
        }
        return fd2num(fd);
  80235a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235d:	89 04 24             	mov    %eax,(%esp)
  802360:	e8 4b f7 ff ff       	call   801ab0 <fd2num>
  802365:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802367:	89 d8                	mov    %ebx,%eax
  802369:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80236c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80236f:	89 ec                	mov    %ebp,%esp
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    
	...

00802380 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802386:	c7 44 24 04 48 31 80 	movl   $0x803148,0x4(%esp)
  80238d:	00 
  80238e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802391:	89 04 24             	mov    %eax,(%esp)
  802394:	e8 61 e7 ff ff       	call   800afa <strcpy>
	return 0;
}
  802399:	b8 00 00 00 00       	mov    $0x0,%eax
  80239e:	c9                   	leave  
  80239f:	c3                   	ret    

008023a0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 14             	sub    $0x14,%esp
  8023a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8023aa:	89 1c 24             	mov    %ebx,(%esp)
  8023ad:	e8 9e 05 00 00       	call   802950 <pageref>
  8023b2:	89 c2                	mov    %eax,%edx
  8023b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b9:	83 fa 01             	cmp    $0x1,%edx
  8023bc:	75 0b                	jne    8023c9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8023be:	8b 43 0c             	mov    0xc(%ebx),%eax
  8023c1:	89 04 24             	mov    %eax,(%esp)
  8023c4:	e8 b9 02 00 00       	call   802682 <nsipc_close>
	else
		return 0;
}
  8023c9:	83 c4 14             	add    $0x14,%esp
  8023cc:	5b                   	pop    %ebx
  8023cd:	5d                   	pop    %ebp
  8023ce:	c3                   	ret    

008023cf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8023cf:	55                   	push   %ebp
  8023d0:	89 e5                	mov    %esp,%ebp
  8023d2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8023d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8023dc:	00 
  8023dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8023e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8023f1:	89 04 24             	mov    %eax,(%esp)
  8023f4:	e8 c5 02 00 00       	call   8026be <nsipc_send>
}
  8023f9:	c9                   	leave  
  8023fa:	c3                   	ret    

008023fb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8023fb:	55                   	push   %ebp
  8023fc:	89 e5                	mov    %esp,%ebp
  8023fe:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802401:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802408:	00 
  802409:	8b 45 10             	mov    0x10(%ebp),%eax
  80240c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802410:	8b 45 0c             	mov    0xc(%ebp),%eax
  802413:	89 44 24 04          	mov    %eax,0x4(%esp)
  802417:	8b 45 08             	mov    0x8(%ebp),%eax
  80241a:	8b 40 0c             	mov    0xc(%eax),%eax
  80241d:	89 04 24             	mov    %eax,(%esp)
  802420:	e8 0c 03 00 00       	call   802731 <nsipc_recv>
}
  802425:	c9                   	leave  
  802426:	c3                   	ret    

00802427 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	56                   	push   %esi
  80242b:	53                   	push   %ebx
  80242c:	83 ec 20             	sub    $0x20,%esp
  80242f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802434:	89 04 24             	mov    %eax,(%esp)
  802437:	e8 9f f6 ff ff       	call   801adb <fd_alloc>
  80243c:	89 c3                	mov    %eax,%ebx
  80243e:	85 c0                	test   %eax,%eax
  802440:	78 21                	js     802463 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802442:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802449:	00 
  80244a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80244d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802451:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802458:	e8 cb ef ff ff       	call   801428 <sys_page_alloc>
  80245d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80245f:	85 c0                	test   %eax,%eax
  802461:	79 0a                	jns    80246d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802463:	89 34 24             	mov    %esi,(%esp)
  802466:	e8 17 02 00 00       	call   802682 <nsipc_close>
		return r;
  80246b:	eb 28                	jmp    802495 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80246d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802473:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802476:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802482:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802485:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248b:	89 04 24             	mov    %eax,(%esp)
  80248e:	e8 1d f6 ff ff       	call   801ab0 <fd2num>
  802493:	89 c3                	mov    %eax,%ebx
}
  802495:	89 d8                	mov    %ebx,%eax
  802497:	83 c4 20             	add    $0x20,%esp
  80249a:	5b                   	pop    %ebx
  80249b:	5e                   	pop    %esi
  80249c:	5d                   	pop    %ebp
  80249d:	c3                   	ret    

0080249e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80249e:	55                   	push   %ebp
  80249f:	89 e5                	mov    %esp,%ebp
  8024a1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8024a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8024a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b5:	89 04 24             	mov    %eax,(%esp)
  8024b8:	e8 79 01 00 00       	call   802636 <nsipc_socket>
  8024bd:	85 c0                	test   %eax,%eax
  8024bf:	78 05                	js     8024c6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8024c1:	e8 61 ff ff ff       	call   802427 <alloc_sockfd>
}
  8024c6:	c9                   	leave  
  8024c7:	c3                   	ret    

008024c8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
  8024cb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8024ce:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8024d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024d5:	89 04 24             	mov    %eax,(%esp)
  8024d8:	e8 70 f6 ff ff       	call   801b4d <fd_lookup>
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	78 15                	js     8024f6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8024e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024e4:	8b 0a                	mov    (%edx),%ecx
  8024e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8024eb:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8024f1:	75 03                	jne    8024f6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8024f3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8024f6:	c9                   	leave  
  8024f7:	c3                   	ret    

008024f8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8024f8:	55                   	push   %ebp
  8024f9:	89 e5                	mov    %esp,%ebp
  8024fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802501:	e8 c2 ff ff ff       	call   8024c8 <fd2sockid>
  802506:	85 c0                	test   %eax,%eax
  802508:	78 0f                	js     802519 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80250a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80250d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802511:	89 04 24             	mov    %eax,(%esp)
  802514:	e8 47 01 00 00       	call   802660 <nsipc_listen>
}
  802519:	c9                   	leave  
  80251a:	c3                   	ret    

0080251b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80251b:	55                   	push   %ebp
  80251c:	89 e5                	mov    %esp,%ebp
  80251e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802521:	8b 45 08             	mov    0x8(%ebp),%eax
  802524:	e8 9f ff ff ff       	call   8024c8 <fd2sockid>
  802529:	85 c0                	test   %eax,%eax
  80252b:	78 16                	js     802543 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80252d:	8b 55 10             	mov    0x10(%ebp),%edx
  802530:	89 54 24 08          	mov    %edx,0x8(%esp)
  802534:	8b 55 0c             	mov    0xc(%ebp),%edx
  802537:	89 54 24 04          	mov    %edx,0x4(%esp)
  80253b:	89 04 24             	mov    %eax,(%esp)
  80253e:	e8 6e 02 00 00       	call   8027b1 <nsipc_connect>
}
  802543:	c9                   	leave  
  802544:	c3                   	ret    

00802545 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802545:	55                   	push   %ebp
  802546:	89 e5                	mov    %esp,%ebp
  802548:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80254b:	8b 45 08             	mov    0x8(%ebp),%eax
  80254e:	e8 75 ff ff ff       	call   8024c8 <fd2sockid>
  802553:	85 c0                	test   %eax,%eax
  802555:	78 0f                	js     802566 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802557:	8b 55 0c             	mov    0xc(%ebp),%edx
  80255a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80255e:	89 04 24             	mov    %eax,(%esp)
  802561:	e8 36 01 00 00       	call   80269c <nsipc_shutdown>
}
  802566:	c9                   	leave  
  802567:	c3                   	ret    

00802568 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802568:	55                   	push   %ebp
  802569:	89 e5                	mov    %esp,%ebp
  80256b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80256e:	8b 45 08             	mov    0x8(%ebp),%eax
  802571:	e8 52 ff ff ff       	call   8024c8 <fd2sockid>
  802576:	85 c0                	test   %eax,%eax
  802578:	78 16                	js     802590 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80257a:	8b 55 10             	mov    0x10(%ebp),%edx
  80257d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802581:	8b 55 0c             	mov    0xc(%ebp),%edx
  802584:	89 54 24 04          	mov    %edx,0x4(%esp)
  802588:	89 04 24             	mov    %eax,(%esp)
  80258b:	e8 60 02 00 00       	call   8027f0 <nsipc_bind>
}
  802590:	c9                   	leave  
  802591:	c3                   	ret    

00802592 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802592:	55                   	push   %ebp
  802593:	89 e5                	mov    %esp,%ebp
  802595:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802598:	8b 45 08             	mov    0x8(%ebp),%eax
  80259b:	e8 28 ff ff ff       	call   8024c8 <fd2sockid>
  8025a0:	85 c0                	test   %eax,%eax
  8025a2:	78 1f                	js     8025c3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8025a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8025a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025b2:	89 04 24             	mov    %eax,(%esp)
  8025b5:	e8 75 02 00 00       	call   80282f <nsipc_accept>
  8025ba:	85 c0                	test   %eax,%eax
  8025bc:	78 05                	js     8025c3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8025be:	e8 64 fe ff ff       	call   802427 <alloc_sockfd>
}
  8025c3:	c9                   	leave  
  8025c4:	c3                   	ret    
	...

008025d0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8025d0:	55                   	push   %ebp
  8025d1:	89 e5                	mov    %esp,%ebp
  8025d3:	53                   	push   %ebx
  8025d4:	83 ec 14             	sub    $0x14,%esp
  8025d7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8025d9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8025e0:	75 11                	jne    8025f3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8025e2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8025e9:	e8 82 f3 ff ff       	call   801970 <ipc_find_env>
  8025ee:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8025f3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8025fa:	00 
  8025fb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802602:	00 
  802603:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802607:	a1 04 50 80 00       	mov    0x805004,%eax
  80260c:	89 04 24             	mov    %eax,(%esp)
  80260f:	e8 a7 f3 ff ff       	call   8019bb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802614:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80261b:	00 
  80261c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802623:	00 
  802624:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80262b:	e8 09 f4 ff ff       	call   801a39 <ipc_recv>
}
  802630:	83 c4 14             	add    $0x14,%esp
  802633:	5b                   	pop    %ebx
  802634:	5d                   	pop    %ebp
  802635:	c3                   	ret    

00802636 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80263c:	8b 45 08             	mov    0x8(%ebp),%eax
  80263f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802644:	8b 45 0c             	mov    0xc(%ebp),%eax
  802647:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80264c:	8b 45 10             	mov    0x10(%ebp),%eax
  80264f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802654:	b8 09 00 00 00       	mov    $0x9,%eax
  802659:	e8 72 ff ff ff       	call   8025d0 <nsipc>
}
  80265e:	c9                   	leave  
  80265f:	c3                   	ret    

00802660 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802660:	55                   	push   %ebp
  802661:	89 e5                	mov    %esp,%ebp
  802663:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802666:	8b 45 08             	mov    0x8(%ebp),%eax
  802669:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80266e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802671:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802676:	b8 06 00 00 00       	mov    $0x6,%eax
  80267b:	e8 50 ff ff ff       	call   8025d0 <nsipc>
}
  802680:	c9                   	leave  
  802681:	c3                   	ret    

00802682 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802682:	55                   	push   %ebp
  802683:	89 e5                	mov    %esp,%ebp
  802685:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802688:	8b 45 08             	mov    0x8(%ebp),%eax
  80268b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802690:	b8 04 00 00 00       	mov    $0x4,%eax
  802695:	e8 36 ff ff ff       	call   8025d0 <nsipc>
}
  80269a:	c9                   	leave  
  80269b:	c3                   	ret    

0080269c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80269c:	55                   	push   %ebp
  80269d:	89 e5                	mov    %esp,%ebp
  80269f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8026a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8026aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ad:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8026b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8026b7:	e8 14 ff ff ff       	call   8025d0 <nsipc>
}
  8026bc:	c9                   	leave  
  8026bd:	c3                   	ret    

008026be <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8026be:	55                   	push   %ebp
  8026bf:	89 e5                	mov    %esp,%ebp
  8026c1:	53                   	push   %ebx
  8026c2:	83 ec 14             	sub    $0x14,%esp
  8026c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8026c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8026d0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8026d6:	7e 24                	jle    8026fc <nsipc_send+0x3e>
  8026d8:	c7 44 24 0c 54 31 80 	movl   $0x803154,0xc(%esp)
  8026df:	00 
  8026e0:	c7 44 24 08 60 31 80 	movl   $0x803160,0x8(%esp)
  8026e7:	00 
  8026e8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8026ef:	00 
  8026f0:	c7 04 24 75 31 80 00 	movl   $0x803175,(%esp)
  8026f7:	e8 88 01 00 00       	call   802884 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8026fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802700:	8b 45 0c             	mov    0xc(%ebp),%eax
  802703:	89 44 24 04          	mov    %eax,0x4(%esp)
  802707:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80270e:	e8 d2 e5 ff ff       	call   800ce5 <memmove>
	nsipcbuf.send.req_size = size;
  802713:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802719:	8b 45 14             	mov    0x14(%ebp),%eax
  80271c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802721:	b8 08 00 00 00       	mov    $0x8,%eax
  802726:	e8 a5 fe ff ff       	call   8025d0 <nsipc>
}
  80272b:	83 c4 14             	add    $0x14,%esp
  80272e:	5b                   	pop    %ebx
  80272f:	5d                   	pop    %ebp
  802730:	c3                   	ret    

00802731 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802731:	55                   	push   %ebp
  802732:	89 e5                	mov    %esp,%ebp
  802734:	56                   	push   %esi
  802735:	53                   	push   %ebx
  802736:	83 ec 10             	sub    $0x10,%esp
  802739:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80273c:	8b 45 08             	mov    0x8(%ebp),%eax
  80273f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802744:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80274a:	8b 45 14             	mov    0x14(%ebp),%eax
  80274d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802752:	b8 07 00 00 00       	mov    $0x7,%eax
  802757:	e8 74 fe ff ff       	call   8025d0 <nsipc>
  80275c:	89 c3                	mov    %eax,%ebx
  80275e:	85 c0                	test   %eax,%eax
  802760:	78 46                	js     8027a8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802762:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802767:	7f 04                	jg     80276d <nsipc_recv+0x3c>
  802769:	39 c6                	cmp    %eax,%esi
  80276b:	7d 24                	jge    802791 <nsipc_recv+0x60>
  80276d:	c7 44 24 0c 81 31 80 	movl   $0x803181,0xc(%esp)
  802774:	00 
  802775:	c7 44 24 08 60 31 80 	movl   $0x803160,0x8(%esp)
  80277c:	00 
  80277d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802784:	00 
  802785:	c7 04 24 75 31 80 00 	movl   $0x803175,(%esp)
  80278c:	e8 f3 00 00 00       	call   802884 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802791:	89 44 24 08          	mov    %eax,0x8(%esp)
  802795:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80279c:	00 
  80279d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027a0:	89 04 24             	mov    %eax,(%esp)
  8027a3:	e8 3d e5 ff ff       	call   800ce5 <memmove>
	}

	return r;
}
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	83 c4 10             	add    $0x10,%esp
  8027ad:	5b                   	pop    %ebx
  8027ae:	5e                   	pop    %esi
  8027af:	5d                   	pop    %ebp
  8027b0:	c3                   	ret    

008027b1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8027b1:	55                   	push   %ebp
  8027b2:	89 e5                	mov    %esp,%ebp
  8027b4:	53                   	push   %ebx
  8027b5:	83 ec 14             	sub    $0x14,%esp
  8027b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8027bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8027be:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8027c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ce:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8027d5:	e8 0b e5 ff ff       	call   800ce5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8027da:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8027e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8027e5:	e8 e6 fd ff ff       	call   8025d0 <nsipc>
}
  8027ea:	83 c4 14             	add    $0x14,%esp
  8027ed:	5b                   	pop    %ebx
  8027ee:	5d                   	pop    %ebp
  8027ef:	c3                   	ret    

008027f0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8027f0:	55                   	push   %ebp
  8027f1:	89 e5                	mov    %esp,%ebp
  8027f3:	53                   	push   %ebx
  8027f4:	83 ec 14             	sub    $0x14,%esp
  8027f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8027fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802802:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802806:	8b 45 0c             	mov    0xc(%ebp),%eax
  802809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80280d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802814:	e8 cc e4 ff ff       	call   800ce5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802819:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80281f:	b8 02 00 00 00       	mov    $0x2,%eax
  802824:	e8 a7 fd ff ff       	call   8025d0 <nsipc>
}
  802829:	83 c4 14             	add    $0x14,%esp
  80282c:	5b                   	pop    %ebx
  80282d:	5d                   	pop    %ebp
  80282e:	c3                   	ret    

0080282f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80282f:	55                   	push   %ebp
  802830:	89 e5                	mov    %esp,%ebp
  802832:	83 ec 18             	sub    $0x18,%esp
  802835:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802838:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80283b:	8b 45 08             	mov    0x8(%ebp),%eax
  80283e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802843:	b8 01 00 00 00       	mov    $0x1,%eax
  802848:	e8 83 fd ff ff       	call   8025d0 <nsipc>
  80284d:	89 c3                	mov    %eax,%ebx
  80284f:	85 c0                	test   %eax,%eax
  802851:	78 25                	js     802878 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802853:	be 10 70 80 00       	mov    $0x807010,%esi
  802858:	8b 06                	mov    (%esi),%eax
  80285a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80285e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802865:	00 
  802866:	8b 45 0c             	mov    0xc(%ebp),%eax
  802869:	89 04 24             	mov    %eax,(%esp)
  80286c:	e8 74 e4 ff ff       	call   800ce5 <memmove>
		*addrlen = ret->ret_addrlen;
  802871:	8b 16                	mov    (%esi),%edx
  802873:	8b 45 10             	mov    0x10(%ebp),%eax
  802876:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802878:	89 d8                	mov    %ebx,%eax
  80287a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80287d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802880:	89 ec                	mov    %ebp,%esp
  802882:	5d                   	pop    %ebp
  802883:	c3                   	ret    

00802884 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802884:	55                   	push   %ebp
  802885:	89 e5                	mov    %esp,%ebp
  802887:	56                   	push   %esi
  802888:	53                   	push   %ebx
  802889:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80288c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80288f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  802895:	e8 7d ec ff ff       	call   801517 <sys_getenvid>
  80289a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80289d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8028a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8028a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8028a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028b0:	c7 04 24 98 31 80 00 	movl   $0x803198,(%esp)
  8028b7:	e8 0d d9 ff ff       	call   8001c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8028bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8028c3:	89 04 24             	mov    %eax,(%esp)
  8028c6:	e8 9d d8 ff ff       	call   800168 <vcprintf>
	cprintf("\n");
  8028cb:	c7 04 24 38 31 80 00 	movl   $0x803138,(%esp)
  8028d2:	e8 f2 d8 ff ff       	call   8001c9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8028d7:	cc                   	int3   
  8028d8:	eb fd                	jmp    8028d7 <_panic+0x53>
	...

008028dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028dc:	55                   	push   %ebp
  8028dd:	89 e5                	mov    %esp,%ebp
  8028df:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028e2:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8028e9:	75 30                	jne    80291b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8028eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8028f2:	00 
  8028f3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8028fa:	ee 
  8028fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802902:	e8 21 eb ff ff       	call   801428 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802907:	c7 44 24 04 28 29 80 	movl   $0x802928,0x4(%esp)
  80290e:	00 
  80290f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802916:	e8 ef e8 ff ff       	call   80120a <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80291b:	8b 45 08             	mov    0x8(%ebp),%eax
  80291e:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802923:	c9                   	leave  
  802924:	c3                   	ret    
  802925:	00 00                	add    %al,(%eax)
	...

00802928 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802928:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802929:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80292e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802930:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  802933:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  802937:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  80293b:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  80293e:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802940:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  802944:	83 c4 08             	add    $0x8,%esp
        popal
  802947:	61                   	popa   
        addl $0x4,%esp
  802948:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  80294b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  80294c:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80294d:	c3                   	ret    
	...

00802950 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802950:	55                   	push   %ebp
  802951:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802953:	8b 45 08             	mov    0x8(%ebp),%eax
  802956:	89 c2                	mov    %eax,%edx
  802958:	c1 ea 16             	shr    $0x16,%edx
  80295b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802962:	f6 c2 01             	test   $0x1,%dl
  802965:	74 20                	je     802987 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802967:	c1 e8 0c             	shr    $0xc,%eax
  80296a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802971:	a8 01                	test   $0x1,%al
  802973:	74 12                	je     802987 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802975:	c1 e8 0c             	shr    $0xc,%eax
  802978:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  80297d:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802982:	0f b7 c0             	movzwl %ax,%eax
  802985:	eb 05                	jmp    80298c <pageref+0x3c>
  802987:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80298c:	5d                   	pop    %ebp
  80298d:	c3                   	ret    
	...

00802990 <__udivdi3>:
  802990:	55                   	push   %ebp
  802991:	89 e5                	mov    %esp,%ebp
  802993:	57                   	push   %edi
  802994:	56                   	push   %esi
  802995:	83 ec 10             	sub    $0x10,%esp
  802998:	8b 45 14             	mov    0x14(%ebp),%eax
  80299b:	8b 55 08             	mov    0x8(%ebp),%edx
  80299e:	8b 75 10             	mov    0x10(%ebp),%esi
  8029a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029a4:	85 c0                	test   %eax,%eax
  8029a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8029a9:	75 35                	jne    8029e0 <__udivdi3+0x50>
  8029ab:	39 fe                	cmp    %edi,%esi
  8029ad:	77 61                	ja     802a10 <__udivdi3+0x80>
  8029af:	85 f6                	test   %esi,%esi
  8029b1:	75 0b                	jne    8029be <__udivdi3+0x2e>
  8029b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8029b8:	31 d2                	xor    %edx,%edx
  8029ba:	f7 f6                	div    %esi
  8029bc:	89 c6                	mov    %eax,%esi
  8029be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8029c1:	31 d2                	xor    %edx,%edx
  8029c3:	89 f8                	mov    %edi,%eax
  8029c5:	f7 f6                	div    %esi
  8029c7:	89 c7                	mov    %eax,%edi
  8029c9:	89 c8                	mov    %ecx,%eax
  8029cb:	f7 f6                	div    %esi
  8029cd:	89 c1                	mov    %eax,%ecx
  8029cf:	89 fa                	mov    %edi,%edx
  8029d1:	89 c8                	mov    %ecx,%eax
  8029d3:	83 c4 10             	add    $0x10,%esp
  8029d6:	5e                   	pop    %esi
  8029d7:	5f                   	pop    %edi
  8029d8:	5d                   	pop    %ebp
  8029d9:	c3                   	ret    
  8029da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029e0:	39 f8                	cmp    %edi,%eax
  8029e2:	77 1c                	ja     802a00 <__udivdi3+0x70>
  8029e4:	0f bd d0             	bsr    %eax,%edx
  8029e7:	83 f2 1f             	xor    $0x1f,%edx
  8029ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8029ed:	75 39                	jne    802a28 <__udivdi3+0x98>
  8029ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8029f2:	0f 86 a0 00 00 00    	jbe    802a98 <__udivdi3+0x108>
  8029f8:	39 f8                	cmp    %edi,%eax
  8029fa:	0f 82 98 00 00 00    	jb     802a98 <__udivdi3+0x108>
  802a00:	31 ff                	xor    %edi,%edi
  802a02:	31 c9                	xor    %ecx,%ecx
  802a04:	89 c8                	mov    %ecx,%eax
  802a06:	89 fa                	mov    %edi,%edx
  802a08:	83 c4 10             	add    $0x10,%esp
  802a0b:	5e                   	pop    %esi
  802a0c:	5f                   	pop    %edi
  802a0d:	5d                   	pop    %ebp
  802a0e:	c3                   	ret    
  802a0f:	90                   	nop
  802a10:	89 d1                	mov    %edx,%ecx
  802a12:	89 fa                	mov    %edi,%edx
  802a14:	89 c8                	mov    %ecx,%eax
  802a16:	31 ff                	xor    %edi,%edi
  802a18:	f7 f6                	div    %esi
  802a1a:	89 c1                	mov    %eax,%ecx
  802a1c:	89 fa                	mov    %edi,%edx
  802a1e:	89 c8                	mov    %ecx,%eax
  802a20:	83 c4 10             	add    $0x10,%esp
  802a23:	5e                   	pop    %esi
  802a24:	5f                   	pop    %edi
  802a25:	5d                   	pop    %ebp
  802a26:	c3                   	ret    
  802a27:	90                   	nop
  802a28:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a2c:	89 f2                	mov    %esi,%edx
  802a2e:	d3 e0                	shl    %cl,%eax
  802a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a33:	b8 20 00 00 00       	mov    $0x20,%eax
  802a38:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802a3b:	89 c1                	mov    %eax,%ecx
  802a3d:	d3 ea                	shr    %cl,%edx
  802a3f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a43:	0b 55 ec             	or     -0x14(%ebp),%edx
  802a46:	d3 e6                	shl    %cl,%esi
  802a48:	89 c1                	mov    %eax,%ecx
  802a4a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802a4d:	89 fe                	mov    %edi,%esi
  802a4f:	d3 ee                	shr    %cl,%esi
  802a51:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a55:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a5b:	d3 e7                	shl    %cl,%edi
  802a5d:	89 c1                	mov    %eax,%ecx
  802a5f:	d3 ea                	shr    %cl,%edx
  802a61:	09 d7                	or     %edx,%edi
  802a63:	89 f2                	mov    %esi,%edx
  802a65:	89 f8                	mov    %edi,%eax
  802a67:	f7 75 ec             	divl   -0x14(%ebp)
  802a6a:	89 d6                	mov    %edx,%esi
  802a6c:	89 c7                	mov    %eax,%edi
  802a6e:	f7 65 e8             	mull   -0x18(%ebp)
  802a71:	39 d6                	cmp    %edx,%esi
  802a73:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a76:	72 30                	jb     802aa8 <__udivdi3+0x118>
  802a78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a7b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a7f:	d3 e2                	shl    %cl,%edx
  802a81:	39 c2                	cmp    %eax,%edx
  802a83:	73 05                	jae    802a8a <__udivdi3+0xfa>
  802a85:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802a88:	74 1e                	je     802aa8 <__udivdi3+0x118>
  802a8a:	89 f9                	mov    %edi,%ecx
  802a8c:	31 ff                	xor    %edi,%edi
  802a8e:	e9 71 ff ff ff       	jmp    802a04 <__udivdi3+0x74>
  802a93:	90                   	nop
  802a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a98:	31 ff                	xor    %edi,%edi
  802a9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  802a9f:	e9 60 ff ff ff       	jmp    802a04 <__udivdi3+0x74>
  802aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802aa8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802aab:	31 ff                	xor    %edi,%edi
  802aad:	89 c8                	mov    %ecx,%eax
  802aaf:	89 fa                	mov    %edi,%edx
  802ab1:	83 c4 10             	add    $0x10,%esp
  802ab4:	5e                   	pop    %esi
  802ab5:	5f                   	pop    %edi
  802ab6:	5d                   	pop    %ebp
  802ab7:	c3                   	ret    
	...

00802ac0 <__umoddi3>:
  802ac0:	55                   	push   %ebp
  802ac1:	89 e5                	mov    %esp,%ebp
  802ac3:	57                   	push   %edi
  802ac4:	56                   	push   %esi
  802ac5:	83 ec 20             	sub    $0x20,%esp
  802ac8:	8b 55 14             	mov    0x14(%ebp),%edx
  802acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ace:	8b 7d 10             	mov    0x10(%ebp),%edi
  802ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ad4:	85 d2                	test   %edx,%edx
  802ad6:	89 c8                	mov    %ecx,%eax
  802ad8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802adb:	75 13                	jne    802af0 <__umoddi3+0x30>
  802add:	39 f7                	cmp    %esi,%edi
  802adf:	76 3f                	jbe    802b20 <__umoddi3+0x60>
  802ae1:	89 f2                	mov    %esi,%edx
  802ae3:	f7 f7                	div    %edi
  802ae5:	89 d0                	mov    %edx,%eax
  802ae7:	31 d2                	xor    %edx,%edx
  802ae9:	83 c4 20             	add    $0x20,%esp
  802aec:	5e                   	pop    %esi
  802aed:	5f                   	pop    %edi
  802aee:	5d                   	pop    %ebp
  802aef:	c3                   	ret    
  802af0:	39 f2                	cmp    %esi,%edx
  802af2:	77 4c                	ja     802b40 <__umoddi3+0x80>
  802af4:	0f bd ca             	bsr    %edx,%ecx
  802af7:	83 f1 1f             	xor    $0x1f,%ecx
  802afa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802afd:	75 51                	jne    802b50 <__umoddi3+0x90>
  802aff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802b02:	0f 87 e0 00 00 00    	ja     802be8 <__umoddi3+0x128>
  802b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b0b:	29 f8                	sub    %edi,%eax
  802b0d:	19 d6                	sbb    %edx,%esi
  802b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b15:	89 f2                	mov    %esi,%edx
  802b17:	83 c4 20             	add    $0x20,%esp
  802b1a:	5e                   	pop    %esi
  802b1b:	5f                   	pop    %edi
  802b1c:	5d                   	pop    %ebp
  802b1d:	c3                   	ret    
  802b1e:	66 90                	xchg   %ax,%ax
  802b20:	85 ff                	test   %edi,%edi
  802b22:	75 0b                	jne    802b2f <__umoddi3+0x6f>
  802b24:	b8 01 00 00 00       	mov    $0x1,%eax
  802b29:	31 d2                	xor    %edx,%edx
  802b2b:	f7 f7                	div    %edi
  802b2d:	89 c7                	mov    %eax,%edi
  802b2f:	89 f0                	mov    %esi,%eax
  802b31:	31 d2                	xor    %edx,%edx
  802b33:	f7 f7                	div    %edi
  802b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b38:	f7 f7                	div    %edi
  802b3a:	eb a9                	jmp    802ae5 <__umoddi3+0x25>
  802b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b40:	89 c8                	mov    %ecx,%eax
  802b42:	89 f2                	mov    %esi,%edx
  802b44:	83 c4 20             	add    $0x20,%esp
  802b47:	5e                   	pop    %esi
  802b48:	5f                   	pop    %edi
  802b49:	5d                   	pop    %ebp
  802b4a:	c3                   	ret    
  802b4b:	90                   	nop
  802b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b50:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b54:	d3 e2                	shl    %cl,%edx
  802b56:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b59:	ba 20 00 00 00       	mov    $0x20,%edx
  802b5e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802b61:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802b64:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b68:	89 fa                	mov    %edi,%edx
  802b6a:	d3 ea                	shr    %cl,%edx
  802b6c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b70:	0b 55 f4             	or     -0xc(%ebp),%edx
  802b73:	d3 e7                	shl    %cl,%edi
  802b75:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b79:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b7c:	89 f2                	mov    %esi,%edx
  802b7e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802b81:	89 c7                	mov    %eax,%edi
  802b83:	d3 ea                	shr    %cl,%edx
  802b85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b89:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802b8c:	89 c2                	mov    %eax,%edx
  802b8e:	d3 e6                	shl    %cl,%esi
  802b90:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b94:	d3 ea                	shr    %cl,%edx
  802b96:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b9a:	09 d6                	or     %edx,%esi
  802b9c:	89 f0                	mov    %esi,%eax
  802b9e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802ba1:	d3 e7                	shl    %cl,%edi
  802ba3:	89 f2                	mov    %esi,%edx
  802ba5:	f7 75 f4             	divl   -0xc(%ebp)
  802ba8:	89 d6                	mov    %edx,%esi
  802baa:	f7 65 e8             	mull   -0x18(%ebp)
  802bad:	39 d6                	cmp    %edx,%esi
  802baf:	72 2b                	jb     802bdc <__umoddi3+0x11c>
  802bb1:	39 c7                	cmp    %eax,%edi
  802bb3:	72 23                	jb     802bd8 <__umoddi3+0x118>
  802bb5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bb9:	29 c7                	sub    %eax,%edi
  802bbb:	19 d6                	sbb    %edx,%esi
  802bbd:	89 f0                	mov    %esi,%eax
  802bbf:	89 f2                	mov    %esi,%edx
  802bc1:	d3 ef                	shr    %cl,%edi
  802bc3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bc7:	d3 e0                	shl    %cl,%eax
  802bc9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bcd:	09 f8                	or     %edi,%eax
  802bcf:	d3 ea                	shr    %cl,%edx
  802bd1:	83 c4 20             	add    $0x20,%esp
  802bd4:	5e                   	pop    %esi
  802bd5:	5f                   	pop    %edi
  802bd6:	5d                   	pop    %ebp
  802bd7:	c3                   	ret    
  802bd8:	39 d6                	cmp    %edx,%esi
  802bda:	75 d9                	jne    802bb5 <__umoddi3+0xf5>
  802bdc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802bdf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802be2:	eb d1                	jmp    802bb5 <__umoddi3+0xf5>
  802be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802be8:	39 f2                	cmp    %esi,%edx
  802bea:	0f 82 18 ff ff ff    	jb     802b08 <__umoddi3+0x48>
  802bf0:	e9 1d ff ff ff       	jmp    802b12 <__umoddi3+0x52>
