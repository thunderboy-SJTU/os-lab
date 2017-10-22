
obj/user/sbrktest:     file format elf32-i386


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
  80002c:	e8 8b 00 00 00       	call   8000bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define ALLOCATE_SIZE 4096
#define STRING_SIZE	  64

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
	int i;
	uint32_t start, end;
	char *s;

	start = sys_sbrk(0);
  80003d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800044:	e8 4e 0f 00 00       	call   800f97 <sys_sbrk>
  800049:	89 c6                	mov    %eax,%esi
	end = sys_sbrk(ALLOCATE_SIZE);
  80004b:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  800052:	e8 40 0f 00 00       	call   800f97 <sys_sbrk>

	if (end - start < ALLOCATE_SIZE) {
  800057:	29 f0                	sub    %esi,%eax
  800059:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  80005e:	77 0c                	ja     80006c <umain+0x38>
		cprintf("sbrk not correctly implemented\n");
  800060:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  800067:	e8 19 01 00 00       	call   800185 <cprintf>
	}

	s = (char *) start;
  80006c:	89 f7                	mov    %esi,%edi
  80006e:	b9 00 00 00 00       	mov    $0x0,%ecx
	for ( i = 0; i < STRING_SIZE; i++) {
		s[i] = 'A' + (i % 26);
  800073:	bb 4f ec c4 4e       	mov    $0x4ec4ec4f,%ebx
  800078:	89 c8                	mov    %ecx,%eax
  80007a:	f7 eb                	imul   %ebx
  80007c:	c1 fa 03             	sar    $0x3,%edx
  80007f:	89 c8                	mov    %ecx,%eax
  800081:	c1 f8 1f             	sar    $0x1f,%eax
  800084:	29 c2                	sub    %eax,%edx
  800086:	6b c2 1a             	imul   $0x1a,%edx,%eax
  800089:	89 ca                	mov    %ecx,%edx
  80008b:	29 c2                	sub    %eax,%edx
  80008d:	89 d0                	mov    %edx,%eax
  80008f:	83 c0 41             	add    $0x41,%eax
  800092:	88 04 31             	mov    %al,(%ecx,%esi,1)
	if (end - start < ALLOCATE_SIZE) {
		cprintf("sbrk not correctly implemented\n");
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  800095:	83 c1 01             	add    $0x1,%ecx
  800098:	83 f9 40             	cmp    $0x40,%ecx
  80009b:	75 db                	jne    800078 <umain+0x44>
		s[i] = 'A' + (i % 26);
	}
	s[STRING_SIZE] = '\0';
  80009d:	c6 47 40 00          	movb   $0x0,0x40(%edi)

	cprintf("SBRK_TEST(%s)\n", s);
  8000a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000a5:	c7 04 24 e0 16 80 00 	movl   $0x8016e0,(%esp)
  8000ac:	e8 d4 00 00 00       	call   800185 <cprintf>
}
  8000b1:	83 c4 1c             	add    $0x1c,%esp
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    
  8000b9:	00 00                	add    %al,(%eax)
	...

008000bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 18             	sub    $0x18,%esp
  8000c2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ce:	e8 52 12 00 00       	call   801325 <sys_getenvid>
  8000d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d8:	89 c2                	mov    %eax,%edx
  8000da:	c1 e2 07             	shl    $0x7,%edx
  8000dd:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000e4:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x38>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f8:	89 34 24             	mov    %esi,(%esp)
  8000fb:	e8 34 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800100:	e8 0b 00 00 00       	call   800110 <exit>
}
  800105:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800108:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
	...

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800116:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011d:	e8 43 12 00 00       	call   801365 <sys_env_destroy>
}
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	8b 45 0c             	mov    0xc(%ebp),%eax
  800144:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800148:	8b 45 08             	mov    0x8(%ebp),%eax
  80014b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800155:	89 44 24 04          	mov    %eax,0x4(%esp)
  800159:	c7 04 24 9f 01 80 00 	movl   $0x80019f,(%esp)
  800160:	e8 d7 01 00 00       	call   80033c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800165:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800175:	89 04 24             	mov    %eax,(%esp)
  800178:	e8 6f 0d 00 00       	call   800eec <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80018b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 04 24             	mov    %eax,(%esp)
  800198:	e8 87 ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 14             	sub    $0x14,%esp
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a9:	8b 03                	mov    (%ebx),%eax
  8001ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ae:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b2:	83 c0 01             	add    $0x1,%eax
  8001b5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bc:	75 19                	jne    8001d7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001be:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c5:	00 
  8001c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 1b 0d 00 00       	call   800eec <sys_cputs>
		b->idx = 0;
  8001d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	83 c4 14             	add    $0x14,%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    
	...

008001f0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	8b 55 0c             	mov    0xc(%ebp),%edx
  800207:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800213:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800216:	b9 00 00 00 00       	mov    $0x0,%ecx
  80021b:	39 d1                	cmp    %edx,%ecx
  80021d:	72 07                	jb     800226 <printnum_v2+0x36>
  80021f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800222:	39 d0                	cmp    %edx,%eax
  800224:	77 5f                	ja     800285 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800226:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80022a:	83 eb 01             	sub    $0x1,%ebx
  80022d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800239:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80023d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800240:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800243:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800246:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800251:	00 
  800252:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80025b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025f:	e8 dc 11 00 00       	call   801440 <__udivdi3>
  800264:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800267:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80026a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80026e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	89 54 24 04          	mov    %edx,0x4(%esp)
  800279:	89 f2                	mov    %esi,%edx
  80027b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027e:	e8 6d ff ff ff       	call   8001f0 <printnum_v2>
  800283:	eb 1e                	jmp    8002a3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800285:	83 ff 2d             	cmp    $0x2d,%edi
  800288:	74 19                	je     8002a3 <printnum_v2+0xb3>
		while (--width > 0)
  80028a:	83 eb 01             	sub    $0x1,%ebx
  80028d:	85 db                	test   %ebx,%ebx
  80028f:	90                   	nop
  800290:	7e 11                	jle    8002a3 <printnum_v2+0xb3>
			putch(padc, putdat);
  800292:	89 74 24 04          	mov    %esi,0x4(%esp)
  800296:	89 3c 24             	mov    %edi,(%esp)
  800299:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80029c:	83 eb 01             	sub    $0x1,%ebx
  80029f:	85 db                	test   %ebx,%ebx
  8002a1:	7f ef                	jg     800292 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b9:	00 
  8002ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002bd:	89 14 24             	mov    %edx,(%esp)
  8002c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002c7:	e8 a4 12 00 00       	call   801570 <__umoddi3>
  8002cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d0:	0f be 80 f9 16 80 00 	movsbl 0x8016f9(%eax),%eax
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002dd:	83 c4 4c             	add    $0x4c,%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5e                   	pop    %esi
  8002e2:	5f                   	pop    %edi
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e8:	83 fa 01             	cmp    $0x1,%edx
  8002eb:	7e 0e                	jle    8002fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	8b 52 04             	mov    0x4(%edx),%edx
  8002f9:	eb 22                	jmp    80031d <getuint+0x38>
	else if (lflag)
  8002fb:	85 d2                	test   %edx,%edx
  8002fd:	74 10                	je     80030f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
  80030d:	eb 0e                	jmp    80031d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800325:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	3b 50 04             	cmp    0x4(%eax),%edx
  80032e:	73 0a                	jae    80033a <sprintputch+0x1b>
		*b->buf++ = ch;
  800330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800333:	88 0a                	mov    %cl,(%edx)
  800335:	83 c2 01             	add    $0x1,%edx
  800338:	89 10                	mov    %edx,(%eax)
}
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 6c             	sub    $0x6c,%esp
  800345:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800348:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80034f:	eb 1a                	jmp    80036b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800351:	85 c0                	test   %eax,%eax
  800353:	0f 84 66 06 00 00    	je     8009bf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	ff 55 08             	call   *0x8(%ebp)
  800366:	eb 03                	jmp    80036b <vprintfmt+0x2f>
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036b:	0f b6 07             	movzbl (%edi),%eax
  80036e:	83 c7 01             	add    $0x1,%edi
  800371:	83 f8 25             	cmp    $0x25,%eax
  800374:	75 db                	jne    800351 <vprintfmt+0x15>
  800376:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80037a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800386:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80038b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800392:	be 00 00 00 00       	mov    $0x0,%esi
  800397:	eb 06                	jmp    80039f <vprintfmt+0x63>
  800399:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80039d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	0f b6 17             	movzbl (%edi),%edx
  8003a2:	0f b6 c2             	movzbl %dl,%eax
  8003a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a8:	8d 47 01             	lea    0x1(%edi),%eax
  8003ab:	83 ea 23             	sub    $0x23,%edx
  8003ae:	80 fa 55             	cmp    $0x55,%dl
  8003b1:	0f 87 60 05 00 00    	ja     800917 <vprintfmt+0x5db>
  8003b7:	0f b6 d2             	movzbl %dl,%edx
  8003ba:	ff 24 95 40 18 80 00 	jmp    *0x801840(,%edx,4)
  8003c1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8003c6:	eb d5                	jmp    80039d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003cb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8003ce:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003d1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003d4:	83 ff 09             	cmp    $0x9,%edi
  8003d7:	76 08                	jbe    8003e1 <vprintfmt+0xa5>
  8003d9:	eb 40                	jmp    80041b <vprintfmt+0xdf>
  8003db:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8003df:	eb bc                	jmp    80039d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003e4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8003e7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8003eb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ee:	8d 7a d0             	lea    -0x30(%edx),%edi
  8003f1:	83 ff 09             	cmp    $0x9,%edi
  8003f4:	76 eb                	jbe    8003e1 <vprintfmt+0xa5>
  8003f6:	eb 23                	jmp    80041b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003fb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003fe:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800401:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800403:	eb 16                	jmp    80041b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800405:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800408:	c1 fa 1f             	sar    $0x1f,%edx
  80040b:	f7 d2                	not    %edx
  80040d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800410:	eb 8b                	jmp    80039d <vprintfmt+0x61>
  800412:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800419:	eb 82                	jmp    80039d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80041b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041f:	0f 89 78 ff ff ff    	jns    80039d <vprintfmt+0x61>
  800425:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800428:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80042b:	e9 6d ff ff ff       	jmp    80039d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800430:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800433:	e9 65 ff ff ff       	jmp    80039d <vprintfmt+0x61>
  800438:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 55 14             	mov    %edx,0x14(%ebp)
  800444:	8b 55 0c             	mov    0xc(%ebp),%edx
  800447:	89 54 24 04          	mov    %edx,0x4(%esp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 04 24             	mov    %eax,(%esp)
  800450:	ff 55 08             	call   *0x8(%ebp)
  800453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800456:	e9 10 ff ff ff       	jmp    80036b <vprintfmt+0x2f>
  80045b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	89 c2                	mov    %eax,%edx
  80046b:	c1 fa 1f             	sar    $0x1f,%edx
  80046e:	31 d0                	xor    %edx,%eax
  800470:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800472:	83 f8 08             	cmp    $0x8,%eax
  800475:	7f 0b                	jg     800482 <vprintfmt+0x146>
  800477:	8b 14 85 a0 19 80 00 	mov    0x8019a0(,%eax,4),%edx
  80047e:	85 d2                	test   %edx,%edx
  800480:	75 26                	jne    8004a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800482:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800486:	c7 44 24 08 0a 17 80 	movl   $0x80170a,0x8(%esp)
  80048d:	00 
  80048e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800491:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800495:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800498:	89 1c 24             	mov    %ebx,(%esp)
  80049b:	e8 a7 05 00 00       	call   800a47 <printfmt>
  8004a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a3:	e9 c3 fe ff ff       	jmp    80036b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ac:	c7 44 24 08 13 17 80 	movl   $0x801713,0x8(%esp)
  8004b3:	00 
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004be:	89 14 24             	mov    %edx,(%esp)
  8004c1:	e8 81 05 00 00       	call   800a47 <printfmt>
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c9:	e9 9d fe ff ff       	jmp    80036b <vprintfmt+0x2f>
  8004ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 d9                	mov    %ebx,%ecx
  8004d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004d8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 30                	mov    (%eax),%esi
  8004e6:	85 f6                	test   %esi,%esi
  8004e8:	75 05                	jne    8004ef <vprintfmt+0x1b3>
  8004ea:	be 16 17 80 00       	mov    $0x801716,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8004ef:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004f3:	7e 06                	jle    8004fb <vprintfmt+0x1bf>
  8004f5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8004f9:	75 10                	jne    80050b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fb:	0f be 06             	movsbl (%esi),%eax
  8004fe:	85 c0                	test   %eax,%eax
  800500:	0f 85 a2 00 00 00    	jne    8005a8 <vprintfmt+0x26c>
  800506:	e9 92 00 00 00       	jmp    80059d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80050f:	89 34 24             	mov    %esi,(%esp)
  800512:	e8 74 05 00 00       	call   800a8b <strnlen>
  800517:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80051a:	29 c2                	sub    %eax,%edx
  80051c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80051f:	85 d2                	test   %edx,%edx
  800521:	7e d8                	jle    8004fb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800523:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800527:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80052a:	89 d3                	mov    %edx,%ebx
  80052c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80052f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800532:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800535:	89 ce                	mov    %ecx,%esi
  800537:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053b:	89 34 24             	mov    %esi,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	83 eb 01             	sub    $0x1,%ebx
  800544:	85 db                	test   %ebx,%ebx
  800546:	7f ef                	jg     800537 <vprintfmt+0x1fb>
  800548:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80054b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80054e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800551:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800558:	eb a1                	jmp    8004fb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x23f>
  800560:	8d 50 e0             	lea    -0x20(%eax),%edx
  800563:	83 fa 5e             	cmp    $0x5e,%edx
  800566:	76 13                	jbe    80057b <vprintfmt+0x23f>
					putch('?', putdat);
  800568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800576:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80057b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80057e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 ef 01             	sub    $0x1,%edi
  80058b:	0f be 06             	movsbl (%esi),%eax
  80058e:	85 c0                	test   %eax,%eax
  800590:	74 05                	je     800597 <vprintfmt+0x25b>
  800592:	83 c6 01             	add    $0x1,%esi
  800595:	eb 1a                	jmp    8005b1 <vprintfmt+0x275>
  800597:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80059a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a1:	7f 1f                	jg     8005c2 <vprintfmt+0x286>
  8005a3:	e9 c0 fd ff ff       	jmp    800368 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a8:	83 c6 01             	add    $0x1,%esi
  8005ab:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005b1:	85 db                	test   %ebx,%ebx
  8005b3:	78 a5                	js     80055a <vprintfmt+0x21e>
  8005b5:	83 eb 01             	sub    $0x1,%ebx
  8005b8:	79 a0                	jns    80055a <vprintfmt+0x21e>
  8005ba:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005bd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005c0:	eb db                	jmp    80059d <vprintfmt+0x261>
  8005c2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005cb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005db:	83 eb 01             	sub    $0x1,%ebx
  8005de:	85 db                	test   %ebx,%ebx
  8005e0:	7f ec                	jg     8005ce <vprintfmt+0x292>
  8005e2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005e5:	e9 81 fd ff ff       	jmp    80036b <vprintfmt+0x2f>
  8005ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ed:	83 fe 01             	cmp    $0x1,%esi
  8005f0:	7e 10                	jle    800602 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 08             	lea    0x8(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 18                	mov    (%eax),%ebx
  8005fd:	8b 70 04             	mov    0x4(%eax),%esi
  800600:	eb 26                	jmp    800628 <vprintfmt+0x2ec>
	else if (lflag)
  800602:	85 f6                	test   %esi,%esi
  800604:	74 12                	je     800618 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 18                	mov    (%eax),%ebx
  800611:	89 de                	mov    %ebx,%esi
  800613:	c1 fe 1f             	sar    $0x1f,%esi
  800616:	eb 10                	jmp    800628 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 18                	mov    (%eax),%ebx
  800623:	89 de                	mov    %ebx,%esi
  800625:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	75 1e                	jne    80064b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80062d:	85 f6                	test   %esi,%esi
  80062f:	78 1a                	js     80064b <vprintfmt+0x30f>
  800631:	85 f6                	test   %esi,%esi
  800633:	7f 05                	jg     80063a <vprintfmt+0x2fe>
  800635:	83 fb 00             	cmp    $0x0,%ebx
  800638:	76 11                	jbe    80064b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80063a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80063d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800641:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80064b:	85 f6                	test   %esi,%esi
  80064d:	78 13                	js     800662 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800652:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800655:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800658:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065d:	e9 da 00 00 00       	jmp    80073c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800662:	8b 45 0c             	mov    0xc(%ebp),%eax
  800665:	89 44 24 04          	mov    %eax,0x4(%esp)
  800669:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800670:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800673:	89 da                	mov    %ebx,%edx
  800675:	89 f1                	mov    %esi,%ecx
  800677:	f7 da                	neg    %edx
  800679:	83 d1 00             	adc    $0x0,%ecx
  80067c:	f7 d9                	neg    %ecx
  80067e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800681:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800687:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068c:	e9 ab 00 00 00       	jmp    80073c <vprintfmt+0x400>
  800691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800694:	89 f2                	mov    %esi,%edx
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 47 fc ff ff       	call   8002e5 <getuint>
  80069e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006a1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006ac:	e9 8b 00 00 00       	jmp    80073c <vprintfmt+0x400>
  8006b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006bb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8006c5:	89 f2                	mov    %esi,%edx
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ca:	e8 16 fc ff ff       	call   8002e5 <getuint>
  8006cf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006d2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8006dd:	eb 5d                	jmp    80073c <vprintfmt+0x400>
  8006df:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006fe:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800711:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800714:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071f:	eb 1b                	jmp    80073c <vprintfmt+0x400>
  800721:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800724:	89 f2                	mov    %esi,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 b7 fb ff ff       	call   8002e5 <getuint>
  80072e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800731:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800740:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800743:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800746:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80074a:	77 09                	ja     800755 <vprintfmt+0x419>
  80074c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80074f:	0f 82 ac 00 00 00    	jb     800801 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800755:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800758:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80075c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075f:	83 ea 01             	sub    $0x1,%edx
  800762:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800766:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80076e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800772:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800775:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800778:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80077b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80077f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800786:	00 
  800787:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80078a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80078d:	89 0c 24             	mov    %ecx,(%esp)
  800790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800794:	e8 a7 0c 00 00       	call   801440 <__udivdi3>
  800799:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80079c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80079f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b4:	e8 37 fa ff ff       	call   8001f0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007d2:	00 
  8007d3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8007d6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8007d9:	89 14 24             	mov    %edx,(%esp)
  8007dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e0:	e8 8b 0d 00 00       	call   801570 <__umoddi3>
  8007e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e9:	0f be 80 f9 16 80 00 	movsbl 0x8016f9(%eax),%eax
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8007f6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8007fa:	74 54                	je     800850 <vprintfmt+0x514>
  8007fc:	e9 67 fb ff ff       	jmp    800368 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800801:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800805:	8d 76 00             	lea    0x0(%esi),%esi
  800808:	0f 84 2a 01 00 00    	je     800938 <vprintfmt+0x5fc>
		while (--width > 0)
  80080e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800811:	83 ef 01             	sub    $0x1,%edi
  800814:	85 ff                	test   %edi,%edi
  800816:	0f 8e 5e 01 00 00    	jle    80097a <vprintfmt+0x63e>
  80081c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80081f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800822:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800825:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800828:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80082b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80082e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800832:	89 1c 24             	mov    %ebx,(%esp)
  800835:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800838:	83 ef 01             	sub    $0x1,%edi
  80083b:	85 ff                	test   %edi,%edi
  80083d:	7f ef                	jg     80082e <vprintfmt+0x4f2>
  80083f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800842:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800845:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800848:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80084b:	e9 2a 01 00 00       	jmp    80097a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800850:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800853:	83 eb 01             	sub    $0x1,%ebx
  800856:	85 db                	test   %ebx,%ebx
  800858:	0f 8e 0a fb ff ff    	jle    800368 <vprintfmt+0x2c>
  80085e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800861:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800864:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800867:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800872:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800874:	83 eb 01             	sub    $0x1,%ebx
  800877:	85 db                	test   %ebx,%ebx
  800879:	7f ec                	jg     800867 <vprintfmt+0x52b>
  80087b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80087e:	e9 e8 fa ff ff       	jmp    80036b <vprintfmt+0x2f>
  800883:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800886:	8b 45 14             	mov    0x14(%ebp),%eax
  800889:	8d 50 04             	lea    0x4(%eax),%edx
  80088c:	89 55 14             	mov    %edx,0x14(%ebp)
  80088f:	8b 00                	mov    (%eax),%eax
  800891:	85 c0                	test   %eax,%eax
  800893:	75 2a                	jne    8008bf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800895:	c7 44 24 0c b0 17 80 	movl   $0x8017b0,0xc(%esp)
  80089c:	00 
  80089d:	c7 44 24 08 13 17 80 	movl   $0x801713,0x8(%esp)
  8008a4:	00 
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008af:	89 0c 24             	mov    %ecx,(%esp)
  8008b2:	e8 90 01 00 00       	call   800a47 <printfmt>
  8008b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ba:	e9 ac fa ff ff       	jmp    80036b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  8008bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c2:	8b 13                	mov    (%ebx),%edx
  8008c4:	83 fa 7f             	cmp    $0x7f,%edx
  8008c7:	7e 29                	jle    8008f2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  8008c9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  8008cb:	c7 44 24 0c e8 17 80 	movl   $0x8017e8,0xc(%esp)
  8008d2:	00 
  8008d3:	c7 44 24 08 13 17 80 	movl   $0x801713,0x8(%esp)
  8008da:	00 
  8008db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	89 04 24             	mov    %eax,(%esp)
  8008e5:	e8 5d 01 00 00       	call   800a47 <printfmt>
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ed:	e9 79 fa ff ff       	jmp    80036b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8008f2:	88 10                	mov    %dl,(%eax)
  8008f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f7:	e9 6f fa ff ff       	jmp    80036b <vprintfmt+0x2f>
  8008fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800905:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800909:	89 14 24             	mov    %edx,(%esp)
  80090c:	ff 55 08             	call   *0x8(%ebp)
  80090f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800912:	e9 54 fa ff ff       	jmp    80036b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800917:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80091a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800925:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800928:	8d 47 ff             	lea    -0x1(%edi),%eax
  80092b:	80 38 25             	cmpb   $0x25,(%eax)
  80092e:	0f 84 37 fa ff ff    	je     80036b <vprintfmt+0x2f>
  800934:	89 c7                	mov    %eax,%edi
  800936:	eb f0                	jmp    800928 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800943:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800946:	89 54 24 08          	mov    %edx,0x8(%esp)
  80094a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800951:	00 
  800952:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800955:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800958:	89 04 24             	mov    %eax,(%esp)
  80095b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095f:	e8 0c 0c 00 00       	call   801570 <__umoddi3>
  800964:	89 74 24 04          	mov    %esi,0x4(%esp)
  800968:	0f be 80 f9 16 80 00 	movsbl 0x8016f9(%eax),%eax
  80096f:	89 04 24             	mov    %eax,(%esp)
  800972:	ff 55 08             	call   *0x8(%ebp)
  800975:	e9 d6 fe ff ff       	jmp    800850 <vprintfmt+0x514>
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800981:	8b 74 24 04          	mov    0x4(%esp),%esi
  800985:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800988:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80098c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800993:	00 
  800994:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800997:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80099a:	89 04 24             	mov    %eax,(%esp)
  80099d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a1:	e8 ca 0b 00 00       	call   801570 <__umoddi3>
  8009a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009aa:	0f be 80 f9 16 80 00 	movsbl 0x8016f9(%eax),%eax
  8009b1:	89 04 24             	mov    %eax,(%esp)
  8009b4:	ff 55 08             	call   *0x8(%ebp)
  8009b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009ba:	e9 ac f9 ff ff       	jmp    80036b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009bf:	83 c4 6c             	add    $0x6c,%esp
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	83 ec 28             	sub    $0x28,%esp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	74 04                	je     8009db <vsnprintf+0x14>
  8009d7:	85 d2                	test   %edx,%edx
  8009d9:	7f 07                	jg     8009e2 <vsnprintf+0x1b>
  8009db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e0:	eb 3b                	jmp    800a1d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8009e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a01:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	c7 04 24 1f 03 80 00 	movl   $0x80031f,(%esp)
  800a0f:	e8 28 f9 ff ff       	call   80033c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a25:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 82 ff ff ff       	call   8009c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a4d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a54:	8b 45 10             	mov    0x10(%ebp),%eax
  800a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	89 04 24             	mov    %eax,(%esp)
  800a68:	e8 cf f8 ff ff       	call   80033c <vprintfmt>
	va_end(ap);
}
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    
	...

00800a70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a7e:	74 09                	je     800a89 <strlen+0x19>
		n++;
  800a80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a87:	75 f7                	jne    800a80 <strlen+0x10>
		n++;
	return n;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a95:	85 c9                	test   %ecx,%ecx
  800a97:	74 19                	je     800ab2 <strnlen+0x27>
  800a99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a9c:	74 14                	je     800ab2 <strnlen+0x27>
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800aa3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa6:	39 c8                	cmp    %ecx,%eax
  800aa8:	74 0d                	je     800ab7 <strnlen+0x2c>
  800aaa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800aae:	75 f3                	jne    800aa3 <strnlen+0x18>
  800ab0:	eb 05                	jmp    800ab7 <strnlen+0x2c>
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	53                   	push   %ebx
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ac9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800acd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ad0:	83 c2 01             	add    $0x1,%edx
  800ad3:	84 c9                	test   %cl,%cl
  800ad5:	75 f2                	jne    800ac9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	83 ec 08             	sub    $0x8,%esp
  800ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ae4:	89 1c 24             	mov    %ebx,(%esp)
  800ae7:	e8 84 ff ff ff       	call   800a70 <strlen>
	strcpy(dst + len, src);
  800aec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aef:	89 54 24 04          	mov    %edx,0x4(%esp)
  800af3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800af6:	89 04 24             	mov    %eax,(%esp)
  800af9:	e8 bc ff ff ff       	call   800aba <strcpy>
	return dst;
}
  800afe:	89 d8                	mov    %ebx,%eax
  800b00:	83 c4 08             	add    $0x8,%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b14:	85 f6                	test   %esi,%esi
  800b16:	74 18                	je     800b30 <strncpy+0x2a>
  800b18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b1d:	0f b6 1a             	movzbl (%edx),%ebx
  800b20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b23:	80 3a 01             	cmpb   $0x1,(%edx)
  800b26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	39 ce                	cmp    %ecx,%esi
  800b2e:	77 ed                	ja     800b1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b42:	89 f0                	mov    %esi,%eax
  800b44:	85 c9                	test   %ecx,%ecx
  800b46:	74 27                	je     800b6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b48:	83 e9 01             	sub    $0x1,%ecx
  800b4b:	74 1d                	je     800b6a <strlcpy+0x36>
  800b4d:	0f b6 1a             	movzbl (%edx),%ebx
  800b50:	84 db                	test   %bl,%bl
  800b52:	74 16                	je     800b6a <strlcpy+0x36>
			*dst++ = *src++;
  800b54:	88 18                	mov    %bl,(%eax)
  800b56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b59:	83 e9 01             	sub    $0x1,%ecx
  800b5c:	74 0e                	je     800b6c <strlcpy+0x38>
			*dst++ = *src++;
  800b5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b61:	0f b6 1a             	movzbl (%edx),%ebx
  800b64:	84 db                	test   %bl,%bl
  800b66:	75 ec                	jne    800b54 <strlcpy+0x20>
  800b68:	eb 02                	jmp    800b6c <strlcpy+0x38>
  800b6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b6c:	c6 00 00             	movb   $0x0,(%eax)
  800b6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b7e:	0f b6 01             	movzbl (%ecx),%eax
  800b81:	84 c0                	test   %al,%al
  800b83:	74 15                	je     800b9a <strcmp+0x25>
  800b85:	3a 02                	cmp    (%edx),%al
  800b87:	75 11                	jne    800b9a <strcmp+0x25>
		p++, q++;
  800b89:	83 c1 01             	add    $0x1,%ecx
  800b8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b8f:	0f b6 01             	movzbl (%ecx),%eax
  800b92:	84 c0                	test   %al,%al
  800b94:	74 04                	je     800b9a <strcmp+0x25>
  800b96:	3a 02                	cmp    (%edx),%al
  800b98:	74 ef                	je     800b89 <strcmp+0x14>
  800b9a:	0f b6 c0             	movzbl %al,%eax
  800b9d:	0f b6 12             	movzbl (%edx),%edx
  800ba0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	53                   	push   %ebx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	74 23                	je     800bd8 <strncmp+0x34>
  800bb5:	0f b6 1a             	movzbl (%edx),%ebx
  800bb8:	84 db                	test   %bl,%bl
  800bba:	74 25                	je     800be1 <strncmp+0x3d>
  800bbc:	3a 19                	cmp    (%ecx),%bl
  800bbe:	75 21                	jne    800be1 <strncmp+0x3d>
  800bc0:	83 e8 01             	sub    $0x1,%eax
  800bc3:	74 13                	je     800bd8 <strncmp+0x34>
		n--, p++, q++;
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bcb:	0f b6 1a             	movzbl (%edx),%ebx
  800bce:	84 db                	test   %bl,%bl
  800bd0:	74 0f                	je     800be1 <strncmp+0x3d>
  800bd2:	3a 19                	cmp    (%ecx),%bl
  800bd4:	74 ea                	je     800bc0 <strncmp+0x1c>
  800bd6:	eb 09                	jmp    800be1 <strncmp+0x3d>
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5d                   	pop    %ebp
  800bdf:	90                   	nop
  800be0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800be1:	0f b6 02             	movzbl (%edx),%eax
  800be4:	0f b6 11             	movzbl (%ecx),%edx
  800be7:	29 d0                	sub    %edx,%eax
  800be9:	eb f2                	jmp    800bdd <strncmp+0x39>

00800beb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bf5:	0f b6 10             	movzbl (%eax),%edx
  800bf8:	84 d2                	test   %dl,%dl
  800bfa:	74 18                	je     800c14 <strchr+0x29>
		if (*s == c)
  800bfc:	38 ca                	cmp    %cl,%dl
  800bfe:	75 0a                	jne    800c0a <strchr+0x1f>
  800c00:	eb 17                	jmp    800c19 <strchr+0x2e>
  800c02:	38 ca                	cmp    %cl,%dl
  800c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c08:	74 0f                	je     800c19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	0f b6 10             	movzbl (%eax),%edx
  800c10:	84 d2                	test   %dl,%dl
  800c12:	75 ee                	jne    800c02 <strchr+0x17>
  800c14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c25:	0f b6 10             	movzbl (%eax),%edx
  800c28:	84 d2                	test   %dl,%dl
  800c2a:	74 18                	je     800c44 <strfind+0x29>
		if (*s == c)
  800c2c:	38 ca                	cmp    %cl,%dl
  800c2e:	75 0a                	jne    800c3a <strfind+0x1f>
  800c30:	eb 12                	jmp    800c44 <strfind+0x29>
  800c32:	38 ca                	cmp    %cl,%dl
  800c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c38:	74 0a                	je     800c44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c3a:	83 c0 01             	add    $0x1,%eax
  800c3d:	0f b6 10             	movzbl (%eax),%edx
  800c40:	84 d2                	test   %dl,%dl
  800c42:	75 ee                	jne    800c32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	89 1c 24             	mov    %ebx,(%esp)
  800c4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c60:	85 c9                	test   %ecx,%ecx
  800c62:	74 30                	je     800c94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c6a:	75 25                	jne    800c91 <memset+0x4b>
  800c6c:	f6 c1 03             	test   $0x3,%cl
  800c6f:	75 20                	jne    800c91 <memset+0x4b>
		c &= 0xFF;
  800c71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c74:	89 d3                	mov    %edx,%ebx
  800c76:	c1 e3 08             	shl    $0x8,%ebx
  800c79:	89 d6                	mov    %edx,%esi
  800c7b:	c1 e6 18             	shl    $0x18,%esi
  800c7e:	89 d0                	mov    %edx,%eax
  800c80:	c1 e0 10             	shl    $0x10,%eax
  800c83:	09 f0                	or     %esi,%eax
  800c85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c87:	09 d8                	or     %ebx,%eax
  800c89:	c1 e9 02             	shr    $0x2,%ecx
  800c8c:	fc                   	cld    
  800c8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c8f:	eb 03                	jmp    800c94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c91:	fc                   	cld    
  800c92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c94:	89 f8                	mov    %edi,%eax
  800c96:	8b 1c 24             	mov    (%esp),%ebx
  800c99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ca1:	89 ec                	mov    %ebp,%esp
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	83 ec 08             	sub    $0x8,%esp
  800cab:	89 34 24             	mov    %esi,(%esp)
  800cae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800cbd:	39 c6                	cmp    %eax,%esi
  800cbf:	73 35                	jae    800cf6 <memmove+0x51>
  800cc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc4:	39 d0                	cmp    %edx,%eax
  800cc6:	73 2e                	jae    800cf6 <memmove+0x51>
		s += n;
		d += n;
  800cc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cca:	f6 c2 03             	test   $0x3,%dl
  800ccd:	75 1b                	jne    800cea <memmove+0x45>
  800ccf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cd5:	75 13                	jne    800cea <memmove+0x45>
  800cd7:	f6 c1 03             	test   $0x3,%cl
  800cda:	75 0e                	jne    800cea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800cdc:	83 ef 04             	sub    $0x4,%edi
  800cdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ce2:	c1 e9 02             	shr    $0x2,%ecx
  800ce5:	fd                   	std    
  800ce6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce8:	eb 09                	jmp    800cf3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cea:	83 ef 01             	sub    $0x1,%edi
  800ced:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cf0:	fd                   	std    
  800cf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cf3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cf4:	eb 20                	jmp    800d16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfc:	75 15                	jne    800d13 <memmove+0x6e>
  800cfe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d04:	75 0d                	jne    800d13 <memmove+0x6e>
  800d06:	f6 c1 03             	test   $0x3,%cl
  800d09:	75 08                	jne    800d13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d0b:	c1 e9 02             	shr    $0x2,%ecx
  800d0e:	fc                   	cld    
  800d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d11:	eb 03                	jmp    800d16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d13:	fc                   	cld    
  800d14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d16:	8b 34 24             	mov    (%esp),%esi
  800d19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d1d:	89 ec                	mov    %ebp,%esp
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d27:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
  800d38:	89 04 24             	mov    %eax,(%esp)
  800d3b:	e8 65 ff ff ff       	call   800ca5 <memmove>
}
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	8b 75 08             	mov    0x8(%ebp),%esi
  800d4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d51:	85 c9                	test   %ecx,%ecx
  800d53:	74 36                	je     800d8b <memcmp+0x49>
		if (*s1 != *s2)
  800d55:	0f b6 06             	movzbl (%esi),%eax
  800d58:	0f b6 1f             	movzbl (%edi),%ebx
  800d5b:	38 d8                	cmp    %bl,%al
  800d5d:	74 20                	je     800d7f <memcmp+0x3d>
  800d5f:	eb 14                	jmp    800d75 <memcmp+0x33>
  800d61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d6b:	83 c2 01             	add    $0x1,%edx
  800d6e:	83 e9 01             	sub    $0x1,%ecx
  800d71:	38 d8                	cmp    %bl,%al
  800d73:	74 12                	je     800d87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d75:	0f b6 c0             	movzbl %al,%eax
  800d78:	0f b6 db             	movzbl %bl,%ebx
  800d7b:	29 d8                	sub    %ebx,%eax
  800d7d:	eb 11                	jmp    800d90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7f:	83 e9 01             	sub    $0x1,%ecx
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	85 c9                	test   %ecx,%ecx
  800d89:	75 d6                	jne    800d61 <memcmp+0x1f>
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d9b:	89 c2                	mov    %eax,%edx
  800d9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800da0:	39 d0                	cmp    %edx,%eax
  800da2:	73 15                	jae    800db9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800da4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800da8:	38 08                	cmp    %cl,(%eax)
  800daa:	75 06                	jne    800db2 <memfind+0x1d>
  800dac:	eb 0b                	jmp    800db9 <memfind+0x24>
  800dae:	38 08                	cmp    %cl,(%eax)
  800db0:	74 07                	je     800db9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800db2:	83 c0 01             	add    $0x1,%eax
  800db5:	39 c2                	cmp    %eax,%edx
  800db7:	77 f5                	ja     800dae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 04             	sub    $0x4,%esp
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dca:	0f b6 02             	movzbl (%edx),%eax
  800dcd:	3c 20                	cmp    $0x20,%al
  800dcf:	74 04                	je     800dd5 <strtol+0x1a>
  800dd1:	3c 09                	cmp    $0x9,%al
  800dd3:	75 0e                	jne    800de3 <strtol+0x28>
		s++;
  800dd5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd8:	0f b6 02             	movzbl (%edx),%eax
  800ddb:	3c 20                	cmp    $0x20,%al
  800ddd:	74 f6                	je     800dd5 <strtol+0x1a>
  800ddf:	3c 09                	cmp    $0x9,%al
  800de1:	74 f2                	je     800dd5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800de3:	3c 2b                	cmp    $0x2b,%al
  800de5:	75 0c                	jne    800df3 <strtol+0x38>
		s++;
  800de7:	83 c2 01             	add    $0x1,%edx
  800dea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800df1:	eb 15                	jmp    800e08 <strtol+0x4d>
	else if (*s == '-')
  800df3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dfa:	3c 2d                	cmp    $0x2d,%al
  800dfc:	75 0a                	jne    800e08 <strtol+0x4d>
		s++, neg = 1;
  800dfe:	83 c2 01             	add    $0x1,%edx
  800e01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e08:	85 db                	test   %ebx,%ebx
  800e0a:	0f 94 c0             	sete   %al
  800e0d:	74 05                	je     800e14 <strtol+0x59>
  800e0f:	83 fb 10             	cmp    $0x10,%ebx
  800e12:	75 18                	jne    800e2c <strtol+0x71>
  800e14:	80 3a 30             	cmpb   $0x30,(%edx)
  800e17:	75 13                	jne    800e2c <strtol+0x71>
  800e19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e1d:	8d 76 00             	lea    0x0(%esi),%esi
  800e20:	75 0a                	jne    800e2c <strtol+0x71>
		s += 2, base = 16;
  800e22:	83 c2 02             	add    $0x2,%edx
  800e25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e2a:	eb 15                	jmp    800e41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e2c:	84 c0                	test   %al,%al
  800e2e:	66 90                	xchg   %ax,%ax
  800e30:	74 0f                	je     800e41 <strtol+0x86>
  800e32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e37:	80 3a 30             	cmpb   $0x30,(%edx)
  800e3a:	75 05                	jne    800e41 <strtol+0x86>
		s++, base = 8;
  800e3c:	83 c2 01             	add    $0x1,%edx
  800e3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e48:	0f b6 0a             	movzbl (%edx),%ecx
  800e4b:	89 cf                	mov    %ecx,%edi
  800e4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e50:	80 fb 09             	cmp    $0x9,%bl
  800e53:	77 08                	ja     800e5d <strtol+0xa2>
			dig = *s - '0';
  800e55:	0f be c9             	movsbl %cl,%ecx
  800e58:	83 e9 30             	sub    $0x30,%ecx
  800e5b:	eb 1e                	jmp    800e7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e60:	80 fb 19             	cmp    $0x19,%bl
  800e63:	77 08                	ja     800e6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e65:	0f be c9             	movsbl %cl,%ecx
  800e68:	83 e9 57             	sub    $0x57,%ecx
  800e6b:	eb 0e                	jmp    800e7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e70:	80 fb 19             	cmp    $0x19,%bl
  800e73:	77 15                	ja     800e8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e75:	0f be c9             	movsbl %cl,%ecx
  800e78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e7b:	39 f1                	cmp    %esi,%ecx
  800e7d:	7d 0b                	jge    800e8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e7f:	83 c2 01             	add    $0x1,%edx
  800e82:	0f af c6             	imul   %esi,%eax
  800e85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e88:	eb be                	jmp    800e48 <strtol+0x8d>
  800e8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e90:	74 05                	je     800e97 <strtol+0xdc>
		*endptr = (char *) s;
  800e92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e9b:	74 04                	je     800ea1 <strtol+0xe6>
  800e9d:	89 c8                	mov    %ecx,%eax
  800e9f:	f7 d8                	neg    %eax
}
  800ea1:	83 c4 04             	add    $0x4,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	00 00                	add    %al,(%eax)
	...

00800eac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	89 1c 24             	mov    %ebx,(%esp)
  800eb5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebe:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec3:	89 d1                	mov    %edx,%ecx
  800ec5:	89 d3                	mov    %edx,%ebx
  800ec7:	89 d7                	mov    %edx,%edi
  800ec9:	51                   	push   %ecx
  800eca:	52                   	push   %edx
  800ecb:	53                   	push   %ebx
  800ecc:	54                   	push   %esp
  800ecd:	55                   	push   %ebp
  800ece:	56                   	push   %esi
  800ecf:	57                   	push   %edi
  800ed0:	54                   	push   %esp
  800ed1:	5d                   	pop    %ebp
  800ed2:	8d 35 da 0e 80 00    	lea    0x800eda,%esi
  800ed8:	0f 34                	sysenter 
  800eda:	5f                   	pop    %edi
  800edb:	5e                   	pop    %esi
  800edc:	5d                   	pop    %ebp
  800edd:	5c                   	pop    %esp
  800ede:	5b                   	pop    %ebx
  800edf:	5a                   	pop    %edx
  800ee0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ee1:	8b 1c 24             	mov    (%esp),%ebx
  800ee4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ee8:	89 ec                	mov    %ebp,%esp
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	89 c3                	mov    %eax,%ebx
  800f06:	89 c7                	mov    %eax,%edi
  800f08:	51                   	push   %ecx
  800f09:	52                   	push   %edx
  800f0a:	53                   	push   %ebx
  800f0b:	54                   	push   %esp
  800f0c:	55                   	push   %ebp
  800f0d:	56                   	push   %esi
  800f0e:	57                   	push   %edi
  800f0f:	54                   	push   %esp
  800f10:	5d                   	pop    %ebp
  800f11:	8d 35 19 0f 80 00    	lea    0x800f19,%esi
  800f17:	0f 34                	sysenter 
  800f19:	5f                   	pop    %edi
  800f1a:	5e                   	pop    %esi
  800f1b:	5d                   	pop    %ebp
  800f1c:	5c                   	pop    %esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5a                   	pop    %edx
  800f1f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f20:	8b 1c 24             	mov    (%esp),%ebx
  800f23:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f27:	89 ec                	mov    %ebp,%esp
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 28             	sub    $0x28,%esp
  800f31:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f34:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f44:	8b 55 08             	mov    0x8(%ebp),%edx
  800f47:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	7e 28                	jle    800f8d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f69:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800f70:	00 
  800f71:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800f78:	00 
  800f79:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f80:	00 
  800f81:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  800f88:	e8 43 04 00 00       	call   8013d0 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800f8d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f90:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f93:	89 ec                	mov    %ebp,%esp
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	89 1c 24             	mov    %ebx,(%esp)
  800fa0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fae:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb1:	89 cb                	mov    %ecx,%ebx
  800fb3:	89 cf                	mov    %ecx,%edi
  800fb5:	51                   	push   %ecx
  800fb6:	52                   	push   %edx
  800fb7:	53                   	push   %ebx
  800fb8:	54                   	push   %esp
  800fb9:	55                   	push   %ebp
  800fba:	56                   	push   %esi
  800fbb:	57                   	push   %edi
  800fbc:	54                   	push   %esp
  800fbd:	5d                   	pop    %ebp
  800fbe:	8d 35 c6 0f 80 00    	lea    0x800fc6,%esi
  800fc4:	0f 34                	sysenter 
  800fc6:	5f                   	pop    %edi
  800fc7:	5e                   	pop    %esi
  800fc8:	5d                   	pop    %ebp
  800fc9:	5c                   	pop    %esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5a                   	pop    %edx
  800fcc:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800fcd:	8b 1c 24             	mov    (%esp),%ebx
  800fd0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fd4:	89 ec                	mov    %ebp,%esp
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 28             	sub    $0x28,%esp
  800fde:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fe1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	89 cb                	mov    %ecx,%ebx
  800ff3:	89 cf                	mov    %ecx,%edi
  800ff5:	51                   	push   %ecx
  800ff6:	52                   	push   %edx
  800ff7:	53                   	push   %ebx
  800ff8:	54                   	push   %esp
  800ff9:	55                   	push   %ebp
  800ffa:	56                   	push   %esi
  800ffb:	57                   	push   %edi
  800ffc:	54                   	push   %esp
  800ffd:	5d                   	pop    %ebp
  800ffe:	8d 35 06 10 80 00    	lea    0x801006,%esi
  801004:	0f 34                	sysenter 
  801006:	5f                   	pop    %edi
  801007:	5e                   	pop    %esi
  801008:	5d                   	pop    %ebp
  801009:	5c                   	pop    %esp
  80100a:	5b                   	pop    %ebx
  80100b:	5a                   	pop    %edx
  80100c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	7e 28                	jle    801039 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801011:	89 44 24 10          	mov    %eax,0x10(%esp)
  801015:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80101c:	00 
  80101d:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  801024:	00 
  801025:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80102c:	00 
  80102d:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  801034:	e8 97 03 00 00       	call   8013d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801039:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80103c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80103f:	89 ec                	mov    %ebp,%esp
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	83 ec 08             	sub    $0x8,%esp
  801049:	89 1c 24             	mov    %ebx,(%esp)
  80104c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801050:	b8 0c 00 00 00       	mov    $0xc,%eax
  801055:	8b 7d 14             	mov    0x14(%ebp),%edi
  801058:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80105b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105e:	8b 55 08             	mov    0x8(%ebp),%edx
  801061:	51                   	push   %ecx
  801062:	52                   	push   %edx
  801063:	53                   	push   %ebx
  801064:	54                   	push   %esp
  801065:	55                   	push   %ebp
  801066:	56                   	push   %esi
  801067:	57                   	push   %edi
  801068:	54                   	push   %esp
  801069:	5d                   	pop    %ebp
  80106a:	8d 35 72 10 80 00    	lea    0x801072,%esi
  801070:	0f 34                	sysenter 
  801072:	5f                   	pop    %edi
  801073:	5e                   	pop    %esi
  801074:	5d                   	pop    %ebp
  801075:	5c                   	pop    %esp
  801076:	5b                   	pop    %ebx
  801077:	5a                   	pop    %edx
  801078:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801079:	8b 1c 24             	mov    (%esp),%ebx
  80107c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801080:	89 ec                	mov    %ebp,%esp
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 28             	sub    $0x28,%esp
  80108a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80108d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801090:	bb 00 00 00 00       	mov    $0x0,%ebx
  801095:	b8 0a 00 00 00       	mov    $0xa,%eax
  80109a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109d:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a0:	89 df                	mov    %ebx,%edi
  8010a2:	51                   	push   %ecx
  8010a3:	52                   	push   %edx
  8010a4:	53                   	push   %ebx
  8010a5:	54                   	push   %esp
  8010a6:	55                   	push   %ebp
  8010a7:	56                   	push   %esi
  8010a8:	57                   	push   %edi
  8010a9:	54                   	push   %esp
  8010aa:	5d                   	pop    %ebp
  8010ab:	8d 35 b3 10 80 00    	lea    0x8010b3,%esi
  8010b1:	0f 34                	sysenter 
  8010b3:	5f                   	pop    %edi
  8010b4:	5e                   	pop    %esi
  8010b5:	5d                   	pop    %ebp
  8010b6:	5c                   	pop    %esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5a                   	pop    %edx
  8010b9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	7e 28                	jle    8010e6 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c2:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010c9:	00 
  8010ca:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  8010d1:	00 
  8010d2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010d9:	00 
  8010da:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  8010e1:	e8 ea 02 00 00       	call   8013d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ec:	89 ec                	mov    %ebp,%esp
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	83 ec 28             	sub    $0x28,%esp
  8010f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010f9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801101:	b8 09 00 00 00       	mov    $0x9,%eax
  801106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801109:	8b 55 08             	mov    0x8(%ebp),%edx
  80110c:	89 df                	mov    %ebx,%edi
  80110e:	51                   	push   %ecx
  80110f:	52                   	push   %edx
  801110:	53                   	push   %ebx
  801111:	54                   	push   %esp
  801112:	55                   	push   %ebp
  801113:	56                   	push   %esi
  801114:	57                   	push   %edi
  801115:	54                   	push   %esp
  801116:	5d                   	pop    %ebp
  801117:	8d 35 1f 11 80 00    	lea    0x80111f,%esi
  80111d:	0f 34                	sysenter 
  80111f:	5f                   	pop    %edi
  801120:	5e                   	pop    %esi
  801121:	5d                   	pop    %ebp
  801122:	5c                   	pop    %esp
  801123:	5b                   	pop    %ebx
  801124:	5a                   	pop    %edx
  801125:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801126:	85 c0                	test   %eax,%eax
  801128:	7e 28                	jle    801152 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801135:	00 
  801136:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  80113d:	00 
  80113e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801145:	00 
  801146:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  80114d:	e8 7e 02 00 00       	call   8013d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801152:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801155:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801158:	89 ec                	mov    %ebp,%esp
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 28             	sub    $0x28,%esp
  801162:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801165:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801168:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116d:	b8 07 00 00 00       	mov    $0x7,%eax
  801172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801175:	8b 55 08             	mov    0x8(%ebp),%edx
  801178:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801192:	85 c0                	test   %eax,%eax
  801194:	7e 28                	jle    8011be <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801196:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011b1:	00 
  8011b2:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  8011b9:	e8 12 02 00 00       	call   8013d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011c4:	89 ec                	mov    %ebp,%esp
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 28             	sub    $0x28,%esp
  8011ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011d1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011d4:	8b 7d 18             	mov    0x18(%ebp),%edi
  8011d7:	0b 7d 14             	or     0x14(%ebp),%edi
  8011da:	b8 06 00 00 00       	mov    $0x6,%eax
  8011df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e8:	51                   	push   %ecx
  8011e9:	52                   	push   %edx
  8011ea:	53                   	push   %ebx
  8011eb:	54                   	push   %esp
  8011ec:	55                   	push   %ebp
  8011ed:	56                   	push   %esi
  8011ee:	57                   	push   %edi
  8011ef:	54                   	push   %esp
  8011f0:	5d                   	pop    %ebp
  8011f1:	8d 35 f9 11 80 00    	lea    0x8011f9,%esi
  8011f7:	0f 34                	sysenter 
  8011f9:	5f                   	pop    %edi
  8011fa:	5e                   	pop    %esi
  8011fb:	5d                   	pop    %ebp
  8011fc:	5c                   	pop    %esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5a                   	pop    %edx
  8011ff:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801200:	85 c0                	test   %eax,%eax
  801202:	7e 28                	jle    80122c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801204:	89 44 24 10          	mov    %eax,0x10(%esp)
  801208:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80120f:	00 
  801210:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  801217:	00 
  801218:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80121f:	00 
  801220:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  801227:	e8 a4 01 00 00       	call   8013d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80122c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80122f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801232:	89 ec                	mov    %ebp,%esp
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	83 ec 28             	sub    $0x28,%esp
  80123c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80123f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801242:	bf 00 00 00 00       	mov    $0x0,%edi
  801247:	b8 05 00 00 00       	mov    $0x5,%eax
  80124c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801252:	8b 55 08             	mov    0x8(%ebp),%edx
  801255:	51                   	push   %ecx
  801256:	52                   	push   %edx
  801257:	53                   	push   %ebx
  801258:	54                   	push   %esp
  801259:	55                   	push   %ebp
  80125a:	56                   	push   %esi
  80125b:	57                   	push   %edi
  80125c:	54                   	push   %esp
  80125d:	5d                   	pop    %ebp
  80125e:	8d 35 66 12 80 00    	lea    0x801266,%esi
  801264:	0f 34                	sysenter 
  801266:	5f                   	pop    %edi
  801267:	5e                   	pop    %esi
  801268:	5d                   	pop    %ebp
  801269:	5c                   	pop    %esp
  80126a:	5b                   	pop    %ebx
  80126b:	5a                   	pop    %edx
  80126c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80126d:	85 c0                	test   %eax,%eax
  80126f:	7e 28                	jle    801299 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801271:	89 44 24 10          	mov    %eax,0x10(%esp)
  801275:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80127c:	00 
  80127d:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  801284:	00 
  801285:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80128c:	00 
  80128d:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  801294:	e8 37 01 00 00       	call   8013d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801299:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80129c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80129f:	89 ec                	mov    %ebp,%esp
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	89 1c 24             	mov    %ebx,(%esp)
  8012ac:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012ba:	89 d1                	mov    %edx,%ecx
  8012bc:	89 d3                	mov    %edx,%ebx
  8012be:	89 d7                	mov    %edx,%edi
  8012c0:	51                   	push   %ecx
  8012c1:	52                   	push   %edx
  8012c2:	53                   	push   %ebx
  8012c3:	54                   	push   %esp
  8012c4:	55                   	push   %ebp
  8012c5:	56                   	push   %esi
  8012c6:	57                   	push   %edi
  8012c7:	54                   	push   %esp
  8012c8:	5d                   	pop    %ebp
  8012c9:	8d 35 d1 12 80 00    	lea    0x8012d1,%esi
  8012cf:	0f 34                	sysenter 
  8012d1:	5f                   	pop    %edi
  8012d2:	5e                   	pop    %esi
  8012d3:	5d                   	pop    %ebp
  8012d4:	5c                   	pop    %esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5a                   	pop    %edx
  8012d7:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012d8:	8b 1c 24             	mov    (%esp),%ebx
  8012db:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012df:	89 ec                	mov    %ebp,%esp
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	89 1c 24             	mov    %ebx,(%esp)
  8012ec:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f5:	b8 04 00 00 00       	mov    $0x4,%eax
  8012fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801300:	89 df                	mov    %ebx,%edi
  801302:	51                   	push   %ecx
  801303:	52                   	push   %edx
  801304:	53                   	push   %ebx
  801305:	54                   	push   %esp
  801306:	55                   	push   %ebp
  801307:	56                   	push   %esi
  801308:	57                   	push   %edi
  801309:	54                   	push   %esp
  80130a:	5d                   	pop    %ebp
  80130b:	8d 35 13 13 80 00    	lea    0x801313,%esi
  801311:	0f 34                	sysenter 
  801313:	5f                   	pop    %edi
  801314:	5e                   	pop    %esi
  801315:	5d                   	pop    %ebp
  801316:	5c                   	pop    %esp
  801317:	5b                   	pop    %ebx
  801318:	5a                   	pop    %edx
  801319:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80131a:	8b 1c 24             	mov    (%esp),%ebx
  80131d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801321:	89 ec                	mov    %ebp,%esp
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	89 1c 24             	mov    %ebx,(%esp)
  80132e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801332:	ba 00 00 00 00       	mov    $0x0,%edx
  801337:	b8 02 00 00 00       	mov    $0x2,%eax
  80133c:	89 d1                	mov    %edx,%ecx
  80133e:	89 d3                	mov    %edx,%ebx
  801340:	89 d7                	mov    %edx,%edi
  801342:	51                   	push   %ecx
  801343:	52                   	push   %edx
  801344:	53                   	push   %ebx
  801345:	54                   	push   %esp
  801346:	55                   	push   %ebp
  801347:	56                   	push   %esi
  801348:	57                   	push   %edi
  801349:	54                   	push   %esp
  80134a:	5d                   	pop    %ebp
  80134b:	8d 35 53 13 80 00    	lea    0x801353,%esi
  801351:	0f 34                	sysenter 
  801353:	5f                   	pop    %edi
  801354:	5e                   	pop    %esi
  801355:	5d                   	pop    %ebp
  801356:	5c                   	pop    %esp
  801357:	5b                   	pop    %ebx
  801358:	5a                   	pop    %edx
  801359:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80135a:	8b 1c 24             	mov    (%esp),%ebx
  80135d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801361:	89 ec                	mov    %ebp,%esp
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    

00801365 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	83 ec 28             	sub    $0x28,%esp
  80136b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80136e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801371:	b9 00 00 00 00       	mov    $0x0,%ecx
  801376:	b8 03 00 00 00       	mov    $0x3,%eax
  80137b:	8b 55 08             	mov    0x8(%ebp),%edx
  80137e:	89 cb                	mov    %ecx,%ebx
  801380:	89 cf                	mov    %ecx,%edi
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
  80139c:	7e 28                	jle    8013c6 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80139e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8013a9:	00 
  8013aa:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  8013b1:	00 
  8013b2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013b9:	00 
  8013ba:	c7 04 24 e1 19 80 00 	movl   $0x8019e1,(%esp)
  8013c1:	e8 0a 00 00 00       	call   8013d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8013c6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013cc:	89 ec                	mov    %ebp,%esp
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	56                   	push   %esi
  8013d4:	53                   	push   %ebx
  8013d5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8013d8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8013db:	a1 08 20 80 00       	mov    0x802008,%eax
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	74 10                	je     8013f4 <_panic+0x24>
		cprintf("%s: ", argv0);
  8013e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e8:	c7 04 24 ef 19 80 00 	movl   $0x8019ef,(%esp)
  8013ef:	e8 91 ed ff ff       	call   800185 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013f4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013fa:	e8 26 ff ff ff       	call   801325 <sys_getenvid>
  8013ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801402:	89 54 24 10          	mov    %edx,0x10(%esp)
  801406:	8b 55 08             	mov    0x8(%ebp),%edx
  801409:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80140d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801411:	89 44 24 04          	mov    %eax,0x4(%esp)
  801415:	c7 04 24 f4 19 80 00 	movl   $0x8019f4,(%esp)
  80141c:	e8 64 ed ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801421:	89 74 24 04          	mov    %esi,0x4(%esp)
  801425:	8b 45 10             	mov    0x10(%ebp),%eax
  801428:	89 04 24             	mov    %eax,(%esp)
  80142b:	e8 f4 ec ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  801430:	c7 04 24 ed 16 80 00 	movl   $0x8016ed,(%esp)
  801437:	e8 49 ed ff ff       	call   800185 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80143c:	cc                   	int3   
  80143d:	eb fd                	jmp    80143c <_panic+0x6c>
	...

00801440 <__udivdi3>:
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	83 ec 10             	sub    $0x10,%esp
  801448:	8b 45 14             	mov    0x14(%ebp),%eax
  80144b:	8b 55 08             	mov    0x8(%ebp),%edx
  80144e:	8b 75 10             	mov    0x10(%ebp),%esi
  801451:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801454:	85 c0                	test   %eax,%eax
  801456:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801459:	75 35                	jne    801490 <__udivdi3+0x50>
  80145b:	39 fe                	cmp    %edi,%esi
  80145d:	77 61                	ja     8014c0 <__udivdi3+0x80>
  80145f:	85 f6                	test   %esi,%esi
  801461:	75 0b                	jne    80146e <__udivdi3+0x2e>
  801463:	b8 01 00 00 00       	mov    $0x1,%eax
  801468:	31 d2                	xor    %edx,%edx
  80146a:	f7 f6                	div    %esi
  80146c:	89 c6                	mov    %eax,%esi
  80146e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801471:	31 d2                	xor    %edx,%edx
  801473:	89 f8                	mov    %edi,%eax
  801475:	f7 f6                	div    %esi
  801477:	89 c7                	mov    %eax,%edi
  801479:	89 c8                	mov    %ecx,%eax
  80147b:	f7 f6                	div    %esi
  80147d:	89 c1                	mov    %eax,%ecx
  80147f:	89 fa                	mov    %edi,%edx
  801481:	89 c8                	mov    %ecx,%eax
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	5e                   	pop    %esi
  801487:	5f                   	pop    %edi
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    
  80148a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801490:	39 f8                	cmp    %edi,%eax
  801492:	77 1c                	ja     8014b0 <__udivdi3+0x70>
  801494:	0f bd d0             	bsr    %eax,%edx
  801497:	83 f2 1f             	xor    $0x1f,%edx
  80149a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80149d:	75 39                	jne    8014d8 <__udivdi3+0x98>
  80149f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8014a2:	0f 86 a0 00 00 00    	jbe    801548 <__udivdi3+0x108>
  8014a8:	39 f8                	cmp    %edi,%eax
  8014aa:	0f 82 98 00 00 00    	jb     801548 <__udivdi3+0x108>
  8014b0:	31 ff                	xor    %edi,%edi
  8014b2:	31 c9                	xor    %ecx,%ecx
  8014b4:	89 c8                	mov    %ecx,%eax
  8014b6:	89 fa                	mov    %edi,%edx
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    
  8014bf:	90                   	nop
  8014c0:	89 d1                	mov    %edx,%ecx
  8014c2:	89 fa                	mov    %edi,%edx
  8014c4:	89 c8                	mov    %ecx,%eax
  8014c6:	31 ff                	xor    %edi,%edi
  8014c8:	f7 f6                	div    %esi
  8014ca:	89 c1                	mov    %eax,%ecx
  8014cc:	89 fa                	mov    %edi,%edx
  8014ce:	89 c8                	mov    %ecx,%eax
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	5e                   	pop    %esi
  8014d4:	5f                   	pop    %edi
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    
  8014d7:	90                   	nop
  8014d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014dc:	89 f2                	mov    %esi,%edx
  8014de:	d3 e0                	shl    %cl,%eax
  8014e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8014e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8014e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8014eb:	89 c1                	mov    %eax,%ecx
  8014ed:	d3 ea                	shr    %cl,%edx
  8014ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8014f6:	d3 e6                	shl    %cl,%esi
  8014f8:	89 c1                	mov    %eax,%ecx
  8014fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8014fd:	89 fe                	mov    %edi,%esi
  8014ff:	d3 ee                	shr    %cl,%esi
  801501:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801505:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801508:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80150b:	d3 e7                	shl    %cl,%edi
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	d3 ea                	shr    %cl,%edx
  801511:	09 d7                	or     %edx,%edi
  801513:	89 f2                	mov    %esi,%edx
  801515:	89 f8                	mov    %edi,%eax
  801517:	f7 75 ec             	divl   -0x14(%ebp)
  80151a:	89 d6                	mov    %edx,%esi
  80151c:	89 c7                	mov    %eax,%edi
  80151e:	f7 65 e8             	mull   -0x18(%ebp)
  801521:	39 d6                	cmp    %edx,%esi
  801523:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801526:	72 30                	jb     801558 <__udivdi3+0x118>
  801528:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80152f:	d3 e2                	shl    %cl,%edx
  801531:	39 c2                	cmp    %eax,%edx
  801533:	73 05                	jae    80153a <__udivdi3+0xfa>
  801535:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801538:	74 1e                	je     801558 <__udivdi3+0x118>
  80153a:	89 f9                	mov    %edi,%ecx
  80153c:	31 ff                	xor    %edi,%edi
  80153e:	e9 71 ff ff ff       	jmp    8014b4 <__udivdi3+0x74>
  801543:	90                   	nop
  801544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801548:	31 ff                	xor    %edi,%edi
  80154a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80154f:	e9 60 ff ff ff       	jmp    8014b4 <__udivdi3+0x74>
  801554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801558:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80155b:	31 ff                	xor    %edi,%edi
  80155d:	89 c8                	mov    %ecx,%eax
  80155f:	89 fa                	mov    %edi,%edx
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    
	...

00801570 <__umoddi3>:
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	57                   	push   %edi
  801574:	56                   	push   %esi
  801575:	83 ec 20             	sub    $0x20,%esp
  801578:	8b 55 14             	mov    0x14(%ebp),%edx
  80157b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80157e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801581:	8b 75 0c             	mov    0xc(%ebp),%esi
  801584:	85 d2                	test   %edx,%edx
  801586:	89 c8                	mov    %ecx,%eax
  801588:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80158b:	75 13                	jne    8015a0 <__umoddi3+0x30>
  80158d:	39 f7                	cmp    %esi,%edi
  80158f:	76 3f                	jbe    8015d0 <__umoddi3+0x60>
  801591:	89 f2                	mov    %esi,%edx
  801593:	f7 f7                	div    %edi
  801595:	89 d0                	mov    %edx,%eax
  801597:	31 d2                	xor    %edx,%edx
  801599:	83 c4 20             	add    $0x20,%esp
  80159c:	5e                   	pop    %esi
  80159d:	5f                   	pop    %edi
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    
  8015a0:	39 f2                	cmp    %esi,%edx
  8015a2:	77 4c                	ja     8015f0 <__umoddi3+0x80>
  8015a4:	0f bd ca             	bsr    %edx,%ecx
  8015a7:	83 f1 1f             	xor    $0x1f,%ecx
  8015aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015ad:	75 51                	jne    801600 <__umoddi3+0x90>
  8015af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8015b2:	0f 87 e0 00 00 00    	ja     801698 <__umoddi3+0x128>
  8015b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bb:	29 f8                	sub    %edi,%eax
  8015bd:	19 d6                	sbb    %edx,%esi
  8015bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c5:	89 f2                	mov    %esi,%edx
  8015c7:	83 c4 20             	add    $0x20,%esp
  8015ca:	5e                   	pop    %esi
  8015cb:	5f                   	pop    %edi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    
  8015ce:	66 90                	xchg   %ax,%ax
  8015d0:	85 ff                	test   %edi,%edi
  8015d2:	75 0b                	jne    8015df <__umoddi3+0x6f>
  8015d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d9:	31 d2                	xor    %edx,%edx
  8015db:	f7 f7                	div    %edi
  8015dd:	89 c7                	mov    %eax,%edi
  8015df:	89 f0                	mov    %esi,%eax
  8015e1:	31 d2                	xor    %edx,%edx
  8015e3:	f7 f7                	div    %edi
  8015e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e8:	f7 f7                	div    %edi
  8015ea:	eb a9                	jmp    801595 <__umoddi3+0x25>
  8015ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015f0:	89 c8                	mov    %ecx,%eax
  8015f2:	89 f2                	mov    %esi,%edx
  8015f4:	83 c4 20             	add    $0x20,%esp
  8015f7:	5e                   	pop    %esi
  8015f8:	5f                   	pop    %edi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    
  8015fb:	90                   	nop
  8015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801600:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801604:	d3 e2                	shl    %cl,%edx
  801606:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801609:	ba 20 00 00 00       	mov    $0x20,%edx
  80160e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801611:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801614:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801618:	89 fa                	mov    %edi,%edx
  80161a:	d3 ea                	shr    %cl,%edx
  80161c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801620:	0b 55 f4             	or     -0xc(%ebp),%edx
  801623:	d3 e7                	shl    %cl,%edi
  801625:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801629:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80162c:	89 f2                	mov    %esi,%edx
  80162e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801631:	89 c7                	mov    %eax,%edi
  801633:	d3 ea                	shr    %cl,%edx
  801635:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801639:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	d3 e6                	shl    %cl,%esi
  801640:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801644:	d3 ea                	shr    %cl,%edx
  801646:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80164a:	09 d6                	or     %edx,%esi
  80164c:	89 f0                	mov    %esi,%eax
  80164e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801651:	d3 e7                	shl    %cl,%edi
  801653:	89 f2                	mov    %esi,%edx
  801655:	f7 75 f4             	divl   -0xc(%ebp)
  801658:	89 d6                	mov    %edx,%esi
  80165a:	f7 65 e8             	mull   -0x18(%ebp)
  80165d:	39 d6                	cmp    %edx,%esi
  80165f:	72 2b                	jb     80168c <__umoddi3+0x11c>
  801661:	39 c7                	cmp    %eax,%edi
  801663:	72 23                	jb     801688 <__umoddi3+0x118>
  801665:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801669:	29 c7                	sub    %eax,%edi
  80166b:	19 d6                	sbb    %edx,%esi
  80166d:	89 f0                	mov    %esi,%eax
  80166f:	89 f2                	mov    %esi,%edx
  801671:	d3 ef                	shr    %cl,%edi
  801673:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801677:	d3 e0                	shl    %cl,%eax
  801679:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80167d:	09 f8                	or     %edi,%eax
  80167f:	d3 ea                	shr    %cl,%edx
  801681:	83 c4 20             	add    $0x20,%esp
  801684:	5e                   	pop    %esi
  801685:	5f                   	pop    %edi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    
  801688:	39 d6                	cmp    %edx,%esi
  80168a:	75 d9                	jne    801665 <__umoddi3+0xf5>
  80168c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80168f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801692:	eb d1                	jmp    801665 <__umoddi3+0xf5>
  801694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801698:	39 f2                	cmp    %esi,%edx
  80169a:	0f 82 18 ff ff ff    	jb     8015b8 <__umoddi3+0x48>
  8016a0:	e9 1d ff ff ff       	jmp    8015c2 <__umoddi3+0x52>
