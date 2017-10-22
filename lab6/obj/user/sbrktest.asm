
obj/user/sbrktest.debug:     file format elf32-i386


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
  800044:	e8 94 10 00 00       	call   8010dd <sys_sbrk>
  800049:	89 c6                	mov    %eax,%esi
	end = sys_sbrk(ALLOCATE_SIZE);
  80004b:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  800052:	e8 86 10 00 00       	call   8010dd <sys_sbrk>

	if (end - start < ALLOCATE_SIZE) {
  800057:	29 f0                	sub    %esi,%eax
  800059:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  80005e:	77 0c                	ja     80006c <umain+0x38>
		cprintf("sbrk not correctly implemented\n");
  800060:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  800067:	e8 21 01 00 00       	call   80018d <cprintf>
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
  8000a5:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  8000ac:	e8 dc 00 00 00       	call   80018d <cprintf>
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
  8000ce:	e8 04 14 00 00       	call   8014d7 <sys_getenvid>
  8000d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d8:	89 c2                	mov    %eax,%edx
  8000da:	c1 e2 07             	shl    $0x7,%edx
  8000dd:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000e4:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x38>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800116:	e8 50 19 00 00       	call   801a6b <close_all>
	sys_env_destroy(0);
  80011b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800122:	e8 f0 13 00 00       	call   801517 <sys_env_destroy>
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    
  800129:	00 00                	add    %al,(%eax)
	...

0080012c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800135:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013c:	00 00 00 
	b.cnt = 0;
  80013f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800146:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800149:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800150:	8b 45 08             	mov    0x8(%ebp),%eax
  800153:	89 44 24 08          	mov    %eax,0x8(%esp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	c7 04 24 a7 01 80 00 	movl   $0x8001a7,(%esp)
  800168:	e8 cf 01 00 00       	call   80033c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800173:	89 44 24 04          	mov    %eax,0x4(%esp)
  800177:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017d:	89 04 24             	mov    %eax,(%esp)
  800180:	e8 67 0d 00 00       	call   800eec <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 87 ff ff ff       	call   80012c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 14             	sub    $0x14,%esp
  8001ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b1:	8b 03                	mov    (%ebx),%eax
  8001b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ba:	83 c0 01             	add    $0x1,%eax
  8001bd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c4:	75 19                	jne    8001df <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cd:	00 
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 13 0d 00 00       	call   800eec <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e3:	83 c4 14             	add    $0x14,%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
  8001e9:	00 00                	add    %al,(%eax)
  8001eb:	00 00                	add    %al,(%eax)
  8001ed:	00 00                	add    %al,(%eax)
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
  80025f:	e8 dc 22 00 00       	call   802540 <__udivdi3>
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
  8002c7:	e8 a4 23 00 00       	call   802670 <__umoddi3>
  8002cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d0:	0f be 80 f9 27 80 00 	movsbl 0x8027f9(%eax),%eax
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
  8003ba:	ff 24 95 e0 29 80 00 	jmp    *0x8029e0(,%edx,4)
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
  800472:	83 f8 0f             	cmp    $0xf,%eax
  800475:	7f 0b                	jg     800482 <vprintfmt+0x146>
  800477:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  80047e:	85 d2                	test   %edx,%edx
  800480:	75 26                	jne    8004a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800482:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800486:	c7 44 24 08 0a 28 80 	movl   $0x80280a,0x8(%esp)
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
  8004ac:	c7 44 24 08 5e 2c 80 	movl   $0x802c5e,0x8(%esp)
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
  8004ea:	be 13 28 80 00       	mov    $0x802813,%esi
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
  800794:	e8 a7 1d 00 00       	call   802540 <__udivdi3>
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
  8007e0:	e8 8b 1e 00 00       	call   802670 <__umoddi3>
  8007e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e9:	0f be 80 f9 27 80 00 	movsbl 0x8027f9(%eax),%eax
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
  800895:	c7 44 24 0c 2c 29 80 	movl   $0x80292c,0xc(%esp)
  80089c:	00 
  80089d:	c7 44 24 08 5e 2c 80 	movl   $0x802c5e,0x8(%esp)
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
  8008cb:	c7 44 24 0c 64 29 80 	movl   $0x802964,0xc(%esp)
  8008d2:	00 
  8008d3:	c7 44 24 08 5e 2c 80 	movl   $0x802c5e,0x8(%esp)
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
  80095f:	e8 0c 1d 00 00       	call   802670 <__umoddi3>
  800964:	89 74 24 04          	mov    %esi,0x4(%esp)
  800968:	0f be 80 f9 27 80 00 	movsbl 0x8027f9(%eax),%eax
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
  8009a1:	e8 ca 1c 00 00       	call   802670 <__umoddi3>
  8009a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009aa:	0f be 80 f9 27 80 00 	movsbl 0x8027f9(%eax),%eax
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

00800f2b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	89 1c 24             	mov    %ebx,(%esp)
  800f34:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3d:	b8 13 00 00 00       	mov    $0x13,%eax
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	89 cb                	mov    %ecx,%ebx
  800f47:	89 cf                	mov    %ecx,%edi
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
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800f61:	8b 1c 24             	mov    (%esp),%ebx
  800f64:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
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
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7e:	b8 12 00 00 00       	mov    $0x12,%eax
  800f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
  800f89:	89 df                	mov    %ebx,%edi
  800f8b:	51                   	push   %ecx
  800f8c:	52                   	push   %edx
  800f8d:	53                   	push   %ebx
  800f8e:	54                   	push   %esp
  800f8f:	55                   	push   %ebp
  800f90:	56                   	push   %esi
  800f91:	57                   	push   %edi
  800f92:	54                   	push   %esp
  800f93:	5d                   	pop    %ebp
  800f94:	8d 35 9c 0f 80 00    	lea    0x800f9c,%esi
  800f9a:	0f 34                	sysenter 
  800f9c:	5f                   	pop    %edi
  800f9d:	5e                   	pop    %esi
  800f9e:	5d                   	pop    %ebp
  800f9f:	5c                   	pop    %esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5a                   	pop    %edx
  800fa2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800fa3:	8b 1c 24             	mov    (%esp),%ebx
  800fa6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800faa:	89 ec                	mov    %ebp,%esp
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	89 1c 24             	mov    %ebx,(%esp)
  800fb7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc0:	b8 11 00 00 00       	mov    $0x11,%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	89 df                	mov    %ebx,%edi
  800fcd:	51                   	push   %ecx
  800fce:	52                   	push   %edx
  800fcf:	53                   	push   %ebx
  800fd0:	54                   	push   %esp
  800fd1:	55                   	push   %ebp
  800fd2:	56                   	push   %esi
  800fd3:	57                   	push   %edi
  800fd4:	54                   	push   %esp
  800fd5:	5d                   	pop    %ebp
  800fd6:	8d 35 de 0f 80 00    	lea    0x800fde,%esi
  800fdc:	0f 34                	sysenter 
  800fde:	5f                   	pop    %edi
  800fdf:	5e                   	pop    %esi
  800fe0:	5d                   	pop    %ebp
  800fe1:	5c                   	pop    %esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5a                   	pop    %edx
  800fe4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800fe5:	8b 1c 24             	mov    (%esp),%ebx
  800fe8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fec:	89 ec                	mov    %ebp,%esp
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	89 1c 24             	mov    %ebx,(%esp)
  800ff9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ffd:	b8 10 00 00 00       	mov    $0x10,%eax
  801002:	8b 7d 14             	mov    0x14(%ebp),%edi
  801005:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801008:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100b:	8b 55 08             	mov    0x8(%ebp),%edx
  80100e:	51                   	push   %ecx
  80100f:	52                   	push   %edx
  801010:	53                   	push   %ebx
  801011:	54                   	push   %esp
  801012:	55                   	push   %ebp
  801013:	56                   	push   %esi
  801014:	57                   	push   %edi
  801015:	54                   	push   %esp
  801016:	5d                   	pop    %ebp
  801017:	8d 35 1f 10 80 00    	lea    0x80101f,%esi
  80101d:	0f 34                	sysenter 
  80101f:	5f                   	pop    %edi
  801020:	5e                   	pop    %esi
  801021:	5d                   	pop    %ebp
  801022:	5c                   	pop    %esp
  801023:	5b                   	pop    %ebx
  801024:	5a                   	pop    %edx
  801025:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801026:	8b 1c 24             	mov    (%esp),%ebx
  801029:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80102d:	89 ec                	mov    %ebp,%esp
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 28             	sub    $0x28,%esp
  801037:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80103a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80103d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801042:	b8 0f 00 00 00       	mov    $0xf,%eax
  801047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104a:	8b 55 08             	mov    0x8(%ebp),%edx
  80104d:	89 df                	mov    %ebx,%edi
  80104f:	51                   	push   %ecx
  801050:	52                   	push   %edx
  801051:	53                   	push   %ebx
  801052:	54                   	push   %esp
  801053:	55                   	push   %ebp
  801054:	56                   	push   %esi
  801055:	57                   	push   %edi
  801056:	54                   	push   %esp
  801057:	5d                   	pop    %ebp
  801058:	8d 35 60 10 80 00    	lea    0x801060,%esi
  80105e:	0f 34                	sysenter 
  801060:	5f                   	pop    %edi
  801061:	5e                   	pop    %esi
  801062:	5d                   	pop    %ebp
  801063:	5c                   	pop    %esp
  801064:	5b                   	pop    %ebx
  801065:	5a                   	pop    %edx
  801066:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801067:	85 c0                	test   %eax,%eax
  801069:	7e 28                	jle    801093 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801076:	00 
  801077:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80107e:	00 
  80107f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801086:	00 
  801087:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80108e:	e8 d1 12 00 00       	call   802364 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801093:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801096:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801099:	89 ec                	mov    %ebp,%esp
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	89 1c 24             	mov    %ebx,(%esp)
  8010a6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010af:	b8 15 00 00 00       	mov    $0x15,%eax
  8010b4:	89 d1                	mov    %edx,%ecx
  8010b6:	89 d3                	mov    %edx,%ebx
  8010b8:	89 d7                	mov    %edx,%edi
  8010ba:	51                   	push   %ecx
  8010bb:	52                   	push   %edx
  8010bc:	53                   	push   %ebx
  8010bd:	54                   	push   %esp
  8010be:	55                   	push   %ebp
  8010bf:	56                   	push   %esi
  8010c0:	57                   	push   %edi
  8010c1:	54                   	push   %esp
  8010c2:	5d                   	pop    %ebp
  8010c3:	8d 35 cb 10 80 00    	lea    0x8010cb,%esi
  8010c9:	0f 34                	sysenter 
  8010cb:	5f                   	pop    %edi
  8010cc:	5e                   	pop    %esi
  8010cd:	5d                   	pop    %ebp
  8010ce:	5c                   	pop    %esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5a                   	pop    %edx
  8010d1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010d2:	8b 1c 24             	mov    (%esp),%ebx
  8010d5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d9:	89 ec                	mov    %ebp,%esp
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
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
  8010ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ef:	b8 14 00 00 00       	mov    $0x14,%eax
  8010f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f7:	89 cb                	mov    %ecx,%ebx
  8010f9:	89 cf                	mov    %ecx,%edi
  8010fb:	51                   	push   %ecx
  8010fc:	52                   	push   %edx
  8010fd:	53                   	push   %ebx
  8010fe:	54                   	push   %esp
  8010ff:	55                   	push   %ebp
  801100:	56                   	push   %esi
  801101:	57                   	push   %edi
  801102:	54                   	push   %esp
  801103:	5d                   	pop    %ebp
  801104:	8d 35 0c 11 80 00    	lea    0x80110c,%esi
  80110a:	0f 34                	sysenter 
  80110c:	5f                   	pop    %edi
  80110d:	5e                   	pop    %esi
  80110e:	5d                   	pop    %ebp
  80110f:	5c                   	pop    %esp
  801110:	5b                   	pop    %ebx
  801111:	5a                   	pop    %edx
  801112:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801113:	8b 1c 24             	mov    (%esp),%ebx
  801116:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80111a:	89 ec                	mov    %ebp,%esp
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 28             	sub    $0x28,%esp
  801124:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801127:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80112a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112f:	b8 0e 00 00 00       	mov    $0xe,%eax
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 28                	jle    80117f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801162:	00 
  801163:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80117a:	e8 e5 11 00 00       	call   802364 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80117f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801182:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801185:	89 ec                	mov    %ebp,%esp
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	89 1c 24             	mov    %ebx,(%esp)
  801192:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801196:	b8 0d 00 00 00       	mov    $0xd,%eax
  80119b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80119e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a7:	51                   	push   %ecx
  8011a8:	52                   	push   %edx
  8011a9:	53                   	push   %ebx
  8011aa:	54                   	push   %esp
  8011ab:	55                   	push   %ebp
  8011ac:	56                   	push   %esi
  8011ad:	57                   	push   %edi
  8011ae:	54                   	push   %esp
  8011af:	5d                   	pop    %ebp
  8011b0:	8d 35 b8 11 80 00    	lea    0x8011b8,%esi
  8011b6:	0f 34                	sysenter 
  8011b8:	5f                   	pop    %edi
  8011b9:	5e                   	pop    %esi
  8011ba:	5d                   	pop    %ebp
  8011bb:	5c                   	pop    %esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5a                   	pop    %edx
  8011be:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011bf:	8b 1c 24             	mov    (%esp),%ebx
  8011c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011c6:	89 ec                	mov    %ebp,%esp
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	83 ec 28             	sub    $0x28,%esp
  8011d0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011d3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011db:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e6:	89 df                	mov    %ebx,%edi
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
  801202:	7e 28                	jle    80122c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801204:	89 44 24 10          	mov    %eax,0x10(%esp)
  801208:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80120f:	00 
  801210:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801217:	00 
  801218:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80121f:	00 
  801220:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801227:	e8 38 11 00 00       	call   802364 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80122c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80122f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801232:	89 ec                	mov    %ebp,%esp
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
  801247:	b8 0a 00 00 00       	mov    $0xa,%eax
  80124c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124f:	8b 55 08             	mov    0x8(%ebp),%edx
  801252:	89 df                	mov    %ebx,%edi
  801254:	51                   	push   %ecx
  801255:	52                   	push   %edx
  801256:	53                   	push   %ebx
  801257:	54                   	push   %esp
  801258:	55                   	push   %ebp
  801259:	56                   	push   %esi
  80125a:	57                   	push   %edi
  80125b:	54                   	push   %esp
  80125c:	5d                   	pop    %ebp
  80125d:	8d 35 65 12 80 00    	lea    0x801265,%esi
  801263:	0f 34                	sysenter 
  801265:	5f                   	pop    %edi
  801266:	5e                   	pop    %esi
  801267:	5d                   	pop    %ebp
  801268:	5c                   	pop    %esp
  801269:	5b                   	pop    %ebx
  80126a:	5a                   	pop    %edx
  80126b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80126c:	85 c0                	test   %eax,%eax
  80126e:	7e 28                	jle    801298 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801270:	89 44 24 10          	mov    %eax,0x10(%esp)
  801274:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80127b:	00 
  80127c:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80128b:	00 
  80128c:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801293:	e8 cc 10 00 00       	call   802364 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801298:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80129b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80129e:	89 ec                	mov    %ebp,%esp
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	83 ec 28             	sub    $0x28,%esp
  8012a8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012ab:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8012b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012be:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	7e 28                	jle    801304 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012e0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012e7:	00 
  8012e8:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  8012ef:	00 
  8012f0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012f7:	00 
  8012f8:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  8012ff:	e8 60 10 00 00       	call   802364 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801304:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801307:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80130a:	89 ec                	mov    %ebp,%esp
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 28             	sub    $0x28,%esp
  801314:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801317:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80131a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80131f:	b8 07 00 00 00       	mov    $0x7,%eax
  801324:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801327:	8b 55 08             	mov    0x8(%ebp),%edx
  80132a:	89 df                	mov    %ebx,%edi
  80132c:	51                   	push   %ecx
  80132d:	52                   	push   %edx
  80132e:	53                   	push   %ebx
  80132f:	54                   	push   %esp
  801330:	55                   	push   %ebp
  801331:	56                   	push   %esi
  801332:	57                   	push   %edi
  801333:	54                   	push   %esp
  801334:	5d                   	pop    %ebp
  801335:	8d 35 3d 13 80 00    	lea    0x80133d,%esi
  80133b:	0f 34                	sysenter 
  80133d:	5f                   	pop    %edi
  80133e:	5e                   	pop    %esi
  80133f:	5d                   	pop    %ebp
  801340:	5c                   	pop    %esp
  801341:	5b                   	pop    %ebx
  801342:	5a                   	pop    %edx
  801343:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801344:	85 c0                	test   %eax,%eax
  801346:	7e 28                	jle    801370 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801348:	89 44 24 10          	mov    %eax,0x10(%esp)
  80134c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801353:	00 
  801354:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80135b:	00 
  80135c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801363:	00 
  801364:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80136b:	e8 f4 0f 00 00       	call   802364 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801370:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801373:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801376:	89 ec                	mov    %ebp,%esp
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 28             	sub    $0x28,%esp
  801380:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801383:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801386:	8b 7d 18             	mov    0x18(%ebp),%edi
  801389:	0b 7d 14             	or     0x14(%ebp),%edi
  80138c:	b8 06 00 00 00       	mov    $0x6,%eax
  801391:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801394:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801397:	8b 55 08             	mov    0x8(%ebp),%edx
  80139a:	51                   	push   %ecx
  80139b:	52                   	push   %edx
  80139c:	53                   	push   %ebx
  80139d:	54                   	push   %esp
  80139e:	55                   	push   %ebp
  80139f:	56                   	push   %esi
  8013a0:	57                   	push   %edi
  8013a1:	54                   	push   %esp
  8013a2:	5d                   	pop    %ebp
  8013a3:	8d 35 ab 13 80 00    	lea    0x8013ab,%esi
  8013a9:	0f 34                	sysenter 
  8013ab:	5f                   	pop    %edi
  8013ac:	5e                   	pop    %esi
  8013ad:	5d                   	pop    %ebp
  8013ae:	5c                   	pop    %esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5a                   	pop    %edx
  8013b1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	7e 28                	jle    8013de <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8013c1:	00 
  8013c2:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  8013c9:	00 
  8013ca:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013d1:	00 
  8013d2:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  8013d9:	e8 86 0f 00 00       	call   802364 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8013de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013e4:	89 ec                	mov    %ebp,%esp
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	83 ec 28             	sub    $0x28,%esp
  8013ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013f1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801401:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801404:	8b 55 08             	mov    0x8(%ebp),%edx
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
  801421:	7e 28                	jle    80144b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801423:	89 44 24 10          	mov    %eax,0x10(%esp)
  801427:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80142e:	00 
  80142f:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801436:	00 
  801437:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80143e:	00 
  80143f:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801446:	e8 19 0f 00 00       	call   802364 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80144b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80144e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801451:	89 ec                	mov    %ebp,%esp
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	89 1c 24             	mov    %ebx,(%esp)
  80145e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801462:	ba 00 00 00 00       	mov    $0x0,%edx
  801467:	b8 0c 00 00 00       	mov    $0xc,%eax
  80146c:	89 d1                	mov    %edx,%ecx
  80146e:	89 d3                	mov    %edx,%ebx
  801470:	89 d7                	mov    %edx,%edi
  801472:	51                   	push   %ecx
  801473:	52                   	push   %edx
  801474:	53                   	push   %ebx
  801475:	54                   	push   %esp
  801476:	55                   	push   %ebp
  801477:	56                   	push   %esi
  801478:	57                   	push   %edi
  801479:	54                   	push   %esp
  80147a:	5d                   	pop    %ebp
  80147b:	8d 35 83 14 80 00    	lea    0x801483,%esi
  801481:	0f 34                	sysenter 
  801483:	5f                   	pop    %edi
  801484:	5e                   	pop    %esi
  801485:	5d                   	pop    %ebp
  801486:	5c                   	pop    %esp
  801487:	5b                   	pop    %ebx
  801488:	5a                   	pop    %edx
  801489:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80148a:	8b 1c 24             	mov    (%esp),%ebx
  80148d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801491:	89 ec                	mov    %ebp,%esp
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
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
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014af:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b2:	89 df                	mov    %ebx,%edi
  8014b4:	51                   	push   %ecx
  8014b5:	52                   	push   %edx
  8014b6:	53                   	push   %ebx
  8014b7:	54                   	push   %esp
  8014b8:	55                   	push   %ebp
  8014b9:	56                   	push   %esi
  8014ba:	57                   	push   %edi
  8014bb:	54                   	push   %esp
  8014bc:	5d                   	pop    %ebp
  8014bd:	8d 35 c5 14 80 00    	lea    0x8014c5,%esi
  8014c3:	0f 34                	sysenter 
  8014c5:	5f                   	pop    %edi
  8014c6:	5e                   	pop    %esi
  8014c7:	5d                   	pop    %ebp
  8014c8:	5c                   	pop    %esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5a                   	pop    %edx
  8014cb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8014cc:	8b 1c 24             	mov    (%esp),%ebx
  8014cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014d3:	89 ec                	mov    %ebp,%esp
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	89 1c 24             	mov    %ebx,(%esp)
  8014e0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014ee:	89 d1                	mov    %edx,%ecx
  8014f0:	89 d3                	mov    %edx,%ebx
  8014f2:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80150c:	8b 1c 24             	mov    (%esp),%ebx
  80150f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801513:	89 ec                	mov    %ebp,%esp
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	83 ec 28             	sub    $0x28,%esp
  80151d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801520:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801523:	b9 00 00 00 00       	mov    $0x0,%ecx
  801528:	b8 03 00 00 00       	mov    $0x3,%eax
  80152d:	8b 55 08             	mov    0x8(%ebp),%edx
  801530:	89 cb                	mov    %ecx,%ebx
  801532:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80154c:	85 c0                	test   %eax,%eax
  80154e:	7e 28                	jle    801578 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801550:	89 44 24 10          	mov    %eax,0x10(%esp)
  801554:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80155b:	00 
  80155c:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801563:	00 
  801564:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80156b:	00 
  80156c:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801573:	e8 ec 0d 00 00       	call   802364 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801578:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80157b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80157e:	89 ec                	mov    %ebp,%esp
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    
	...

00801590 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	8b 45 08             	mov    0x8(%ebp),%eax
  801596:	05 00 00 00 30       	add    $0x30000000,%eax
  80159b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    

008015a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8015a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a9:	89 04 24             	mov    %eax,(%esp)
  8015ac:	e8 df ff ff ff       	call   801590 <fd2num>
  8015b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8015b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	57                   	push   %edi
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8015c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8015c9:	a8 01                	test   $0x1,%al
  8015cb:	74 36                	je     801603 <fd_alloc+0x48>
  8015cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8015d2:	a8 01                	test   $0x1,%al
  8015d4:	74 2d                	je     801603 <fd_alloc+0x48>
  8015d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8015db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8015e5:	89 c3                	mov    %eax,%ebx
  8015e7:	89 c2                	mov    %eax,%edx
  8015e9:	c1 ea 16             	shr    $0x16,%edx
  8015ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8015ef:	f6 c2 01             	test   $0x1,%dl
  8015f2:	74 14                	je     801608 <fd_alloc+0x4d>
  8015f4:	89 c2                	mov    %eax,%edx
  8015f6:	c1 ea 0c             	shr    $0xc,%edx
  8015f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8015fc:	f6 c2 01             	test   $0x1,%dl
  8015ff:	75 10                	jne    801611 <fd_alloc+0x56>
  801601:	eb 05                	jmp    801608 <fd_alloc+0x4d>
  801603:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801608:	89 1f                	mov    %ebx,(%edi)
  80160a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80160f:	eb 17                	jmp    801628 <fd_alloc+0x6d>
  801611:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801616:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80161b:	75 c8                	jne    8015e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80161d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801623:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	5f                   	pop    %edi
  80162b:	5d                   	pop    %ebp
  80162c:	c3                   	ret    

0080162d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801630:	8b 45 08             	mov    0x8(%ebp),%eax
  801633:	83 f8 1f             	cmp    $0x1f,%eax
  801636:	77 36                	ja     80166e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801638:	05 00 00 0d 00       	add    $0xd0000,%eax
  80163d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801640:	89 c2                	mov    %eax,%edx
  801642:	c1 ea 16             	shr    $0x16,%edx
  801645:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80164c:	f6 c2 01             	test   $0x1,%dl
  80164f:	74 1d                	je     80166e <fd_lookup+0x41>
  801651:	89 c2                	mov    %eax,%edx
  801653:	c1 ea 0c             	shr    $0xc,%edx
  801656:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80165d:	f6 c2 01             	test   $0x1,%dl
  801660:	74 0c                	je     80166e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801662:	8b 55 0c             	mov    0xc(%ebp),%edx
  801665:	89 02                	mov    %eax,(%edx)
  801667:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80166c:	eb 05                	jmp    801673 <fd_lookup+0x46>
  80166e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80167e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801682:	8b 45 08             	mov    0x8(%ebp),%eax
  801685:	89 04 24             	mov    %eax,(%esp)
  801688:	e8 a0 ff ff ff       	call   80162d <fd_lookup>
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 0e                	js     80169f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801691:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801694:	8b 55 0c             	mov    0xc(%ebp),%edx
  801697:	89 50 04             	mov    %edx,0x4(%eax)
  80169a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 10             	sub    $0x10,%esp
  8016a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8016af:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016b9:	be 28 2c 80 00       	mov    $0x802c28,%esi
		if (devtab[i]->dev_id == dev_id) {
  8016be:	39 08                	cmp    %ecx,(%eax)
  8016c0:	75 10                	jne    8016d2 <dev_lookup+0x31>
  8016c2:	eb 04                	jmp    8016c8 <dev_lookup+0x27>
  8016c4:	39 08                	cmp    %ecx,(%eax)
  8016c6:	75 0a                	jne    8016d2 <dev_lookup+0x31>
			*dev = devtab[i];
  8016c8:	89 03                	mov    %eax,(%ebx)
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016cf:	90                   	nop
  8016d0:	eb 31                	jmp    801703 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016d2:	83 c2 01             	add    $0x1,%edx
  8016d5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	75 e8                	jne    8016c4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8016e1:	8b 40 48             	mov    0x48(%eax),%eax
  8016e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ec:	c7 04 24 ac 2b 80 00 	movl   $0x802bac,(%esp)
  8016f3:	e8 95 ea ff ff       	call   80018d <cprintf>
	*dev = 0;
  8016f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	53                   	push   %ebx
  80170e:	83 ec 24             	sub    $0x24,%esp
  801711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171b:	8b 45 08             	mov    0x8(%ebp),%eax
  80171e:	89 04 24             	mov    %eax,(%esp)
  801721:	e8 07 ff ff ff       	call   80162d <fd_lookup>
  801726:	85 c0                	test   %eax,%eax
  801728:	78 53                	js     80177d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801734:	8b 00                	mov    (%eax),%eax
  801736:	89 04 24             	mov    %eax,(%esp)
  801739:	e8 63 ff ff ff       	call   8016a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 3b                	js     80177d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801742:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801747:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80174e:	74 2d                	je     80177d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801750:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801753:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80175a:	00 00 00 
	stat->st_isdir = 0;
  80175d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801764:	00 00 00 
	stat->st_dev = dev;
  801767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801770:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801774:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801777:	89 14 24             	mov    %edx,(%esp)
  80177a:	ff 50 14             	call   *0x14(%eax)
}
  80177d:	83 c4 24             	add    $0x24,%esp
  801780:	5b                   	pop    %ebx
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	53                   	push   %ebx
  801787:	83 ec 24             	sub    $0x24,%esp
  80178a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801790:	89 44 24 04          	mov    %eax,0x4(%esp)
  801794:	89 1c 24             	mov    %ebx,(%esp)
  801797:	e8 91 fe ff ff       	call   80162d <fd_lookup>
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 5f                	js     8017ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017aa:	8b 00                	mov    (%eax),%eax
  8017ac:	89 04 24             	mov    %eax,(%esp)
  8017af:	e8 ed fe ff ff       	call   8016a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 47                	js     8017ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017bb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017bf:	75 23                	jne    8017e4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c6:	8b 40 48             	mov    0x48(%eax),%eax
  8017c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  8017d8:	e8 b0 e9 ff ff       	call   80018d <cprintf>
  8017dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017e2:	eb 1b                	jmp    8017ff <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e7:	8b 48 18             	mov    0x18(%eax),%ecx
  8017ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ef:	85 c9                	test   %ecx,%ecx
  8017f1:	74 0c                	je     8017ff <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fa:	89 14 24             	mov    %edx,(%esp)
  8017fd:	ff d1                	call   *%ecx
}
  8017ff:	83 c4 24             	add    $0x24,%esp
  801802:	5b                   	pop    %ebx
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	53                   	push   %ebx
  801809:	83 ec 24             	sub    $0x24,%esp
  80180c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801812:	89 44 24 04          	mov    %eax,0x4(%esp)
  801816:	89 1c 24             	mov    %ebx,(%esp)
  801819:	e8 0f fe ff ff       	call   80162d <fd_lookup>
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 66                	js     801888 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801825:	89 44 24 04          	mov    %eax,0x4(%esp)
  801829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182c:	8b 00                	mov    (%eax),%eax
  80182e:	89 04 24             	mov    %eax,(%esp)
  801831:	e8 6b fe ff ff       	call   8016a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801836:	85 c0                	test   %eax,%eax
  801838:	78 4e                	js     801888 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80183a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80183d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801841:	75 23                	jne    801866 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801843:	a1 08 40 80 00       	mov    0x804008,%eax
  801848:	8b 40 48             	mov    0x48(%eax),%eax
  80184b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80184f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801853:	c7 04 24 ed 2b 80 00 	movl   $0x802bed,(%esp)
  80185a:	e8 2e e9 ff ff       	call   80018d <cprintf>
  80185f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801864:	eb 22                	jmp    801888 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801869:	8b 48 0c             	mov    0xc(%eax),%ecx
  80186c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801871:	85 c9                	test   %ecx,%ecx
  801873:	74 13                	je     801888 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801875:	8b 45 10             	mov    0x10(%ebp),%eax
  801878:	89 44 24 08          	mov    %eax,0x8(%esp)
  80187c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801883:	89 14 24             	mov    %edx,(%esp)
  801886:	ff d1                	call   *%ecx
}
  801888:	83 c4 24             	add    $0x24,%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5d                   	pop    %ebp
  80188d:	c3                   	ret    

0080188e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	53                   	push   %ebx
  801892:	83 ec 24             	sub    $0x24,%esp
  801895:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801898:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189f:	89 1c 24             	mov    %ebx,(%esp)
  8018a2:	e8 86 fd ff ff       	call   80162d <fd_lookup>
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 6b                	js     801916 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b5:	8b 00                	mov    (%eax),%eax
  8018b7:	89 04 24             	mov    %eax,(%esp)
  8018ba:	e8 e2 fd ff ff       	call   8016a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 53                	js     801916 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018c6:	8b 42 08             	mov    0x8(%edx),%eax
  8018c9:	83 e0 03             	and    $0x3,%eax
  8018cc:	83 f8 01             	cmp    $0x1,%eax
  8018cf:	75 23                	jne    8018f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018d1:	a1 08 40 80 00       	mov    0x804008,%eax
  8018d6:	8b 40 48             	mov    0x48(%eax),%eax
  8018d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e1:	c7 04 24 0a 2c 80 00 	movl   $0x802c0a,(%esp)
  8018e8:	e8 a0 e8 ff ff       	call   80018d <cprintf>
  8018ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018f2:	eb 22                	jmp    801916 <read+0x88>
	}
	if (!dev->dev_read)
  8018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f7:	8b 48 08             	mov    0x8(%eax),%ecx
  8018fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018ff:	85 c9                	test   %ecx,%ecx
  801901:	74 13                	je     801916 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801903:	8b 45 10             	mov    0x10(%ebp),%eax
  801906:	89 44 24 08          	mov    %eax,0x8(%esp)
  80190a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801911:	89 14 24             	mov    %edx,(%esp)
  801914:	ff d1                	call   *%ecx
}
  801916:	83 c4 24             	add    $0x24,%esp
  801919:	5b                   	pop    %ebx
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	57                   	push   %edi
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	83 ec 1c             	sub    $0x1c,%esp
  801925:	8b 7d 08             	mov    0x8(%ebp),%edi
  801928:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80192b:	ba 00 00 00 00       	mov    $0x0,%edx
  801930:	bb 00 00 00 00       	mov    $0x0,%ebx
  801935:	b8 00 00 00 00       	mov    $0x0,%eax
  80193a:	85 f6                	test   %esi,%esi
  80193c:	74 29                	je     801967 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80193e:	89 f0                	mov    %esi,%eax
  801940:	29 d0                	sub    %edx,%eax
  801942:	89 44 24 08          	mov    %eax,0x8(%esp)
  801946:	03 55 0c             	add    0xc(%ebp),%edx
  801949:	89 54 24 04          	mov    %edx,0x4(%esp)
  80194d:	89 3c 24             	mov    %edi,(%esp)
  801950:	e8 39 ff ff ff       	call   80188e <read>
		if (m < 0)
  801955:	85 c0                	test   %eax,%eax
  801957:	78 0e                	js     801967 <readn+0x4b>
			return m;
		if (m == 0)
  801959:	85 c0                	test   %eax,%eax
  80195b:	74 08                	je     801965 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80195d:	01 c3                	add    %eax,%ebx
  80195f:	89 da                	mov    %ebx,%edx
  801961:	39 f3                	cmp    %esi,%ebx
  801963:	72 d9                	jb     80193e <readn+0x22>
  801965:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801967:	83 c4 1c             	add    $0x1c,%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	5f                   	pop    %edi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	83 ec 20             	sub    $0x20,%esp
  801977:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80197a:	89 34 24             	mov    %esi,(%esp)
  80197d:	e8 0e fc ff ff       	call   801590 <fd2num>
  801982:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801985:	89 54 24 04          	mov    %edx,0x4(%esp)
  801989:	89 04 24             	mov    %eax,(%esp)
  80198c:	e8 9c fc ff ff       	call   80162d <fd_lookup>
  801991:	89 c3                	mov    %eax,%ebx
  801993:	85 c0                	test   %eax,%eax
  801995:	78 05                	js     80199c <fd_close+0x2d>
  801997:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80199a:	74 0c                	je     8019a8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80199c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8019a0:	19 c0                	sbb    %eax,%eax
  8019a2:	f7 d0                	not    %eax
  8019a4:	21 c3                	and    %eax,%ebx
  8019a6:	eb 3d                	jmp    8019e5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8019a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019af:	8b 06                	mov    (%esi),%eax
  8019b1:	89 04 24             	mov    %eax,(%esp)
  8019b4:	e8 e8 fc ff ff       	call   8016a1 <dev_lookup>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 16                	js     8019d5 <fd_close+0x66>
		if (dev->dev_close)
  8019bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c2:	8b 40 10             	mov    0x10(%eax),%eax
  8019c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	74 07                	je     8019d5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8019ce:	89 34 24             	mov    %esi,(%esp)
  8019d1:	ff d0                	call   *%eax
  8019d3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e0:	e8 29 f9 ff ff       	call   80130e <sys_page_unmap>
	return r;
}
  8019e5:	89 d8                	mov    %ebx,%eax
  8019e7:	83 c4 20             	add    $0x20,%esp
  8019ea:	5b                   	pop    %ebx
  8019eb:	5e                   	pop    %esi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	e8 27 fc ff ff       	call   80162d <fd_lookup>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 13                	js     801a1d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801a0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a11:	00 
  801a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a15:	89 04 24             	mov    %eax,(%esp)
  801a18:	e8 52 ff ff ff       	call   80196f <fd_close>
}
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 18             	sub    $0x18,%esp
  801a25:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a28:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a32:	00 
  801a33:	8b 45 08             	mov    0x8(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 79 03 00 00       	call   801db7 <open>
  801a3e:	89 c3                	mov    %eax,%ebx
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 1b                	js     801a5f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	89 1c 24             	mov    %ebx,(%esp)
  801a4e:	e8 b7 fc ff ff       	call   80170a <fstat>
  801a53:	89 c6                	mov    %eax,%esi
	close(fd);
  801a55:	89 1c 24             	mov    %ebx,(%esp)
  801a58:	e8 91 ff ff ff       	call   8019ee <close>
  801a5d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a64:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a67:	89 ec                	mov    %ebp,%esp
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 14             	sub    $0x14,%esp
  801a72:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a77:	89 1c 24             	mov    %ebx,(%esp)
  801a7a:	e8 6f ff ff ff       	call   8019ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a7f:	83 c3 01             	add    $0x1,%ebx
  801a82:	83 fb 20             	cmp    $0x20,%ebx
  801a85:	75 f0                	jne    801a77 <close_all+0xc>
		close(i);
}
  801a87:	83 c4 14             	add    $0x14,%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5d                   	pop    %ebp
  801a8c:	c3                   	ret    

00801a8d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 58             	sub    $0x58,%esp
  801a93:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a96:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a99:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	89 04 24             	mov    %eax,(%esp)
  801aac:	e8 7c fb ff ff       	call   80162d <fd_lookup>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	0f 88 e0 00 00 00    	js     801b9b <dup+0x10e>
		return r;
	close(newfdnum);
  801abb:	89 3c 24             	mov    %edi,(%esp)
  801abe:	e8 2b ff ff ff       	call   8019ee <close>

	newfd = INDEX2FD(newfdnum);
  801ac3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801ac9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801acc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801acf:	89 04 24             	mov    %eax,(%esp)
  801ad2:	e8 c9 fa ff ff       	call   8015a0 <fd2data>
  801ad7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ad9:	89 34 24             	mov    %esi,(%esp)
  801adc:	e8 bf fa ff ff       	call   8015a0 <fd2data>
  801ae1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801ae4:	89 da                	mov    %ebx,%edx
  801ae6:	89 d8                	mov    %ebx,%eax
  801ae8:	c1 e8 16             	shr    $0x16,%eax
  801aeb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801af2:	a8 01                	test   $0x1,%al
  801af4:	74 43                	je     801b39 <dup+0xac>
  801af6:	c1 ea 0c             	shr    $0xc,%edx
  801af9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b00:	a8 01                	test   $0x1,%al
  801b02:	74 35                	je     801b39 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b04:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b0b:	25 07 0e 00 00       	and    $0xe07,%eax
  801b10:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b22:	00 
  801b23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2e:	e8 47 f8 ff ff       	call   80137a <sys_page_map>
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 3f                	js     801b78 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b3c:	89 c2                	mov    %eax,%edx
  801b3e:	c1 ea 0c             	shr    $0xc,%edx
  801b41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b48:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b4e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b52:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b5d:	00 
  801b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b69:	e8 0c f8 ff ff       	call   80137a <sys_page_map>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 04                	js     801b78 <dup+0xeb>
  801b74:	89 fb                	mov    %edi,%ebx
  801b76:	eb 23                	jmp    801b9b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b78:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b83:	e8 86 f7 ff ff       	call   80130e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b96:	e8 73 f7 ff ff       	call   80130e <sys_page_unmap>
	return r;
}
  801b9b:	89 d8                	mov    %ebx,%eax
  801b9d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ba0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ba3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ba6:	89 ec                	mov    %ebp,%esp
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    
	...

00801bac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 18             	sub    $0x18,%esp
  801bb2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801bb5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801bb8:	89 c3                	mov    %eax,%ebx
  801bba:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801bbc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801bc3:	75 11                	jne    801bd6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bc5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801bcc:	e8 ef 07 00 00       	call   8023c0 <ipc_find_env>
  801bd1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bd6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bdd:	00 
  801bde:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801be5:	00 
  801be6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bea:	a1 00 40 80 00       	mov    0x804000,%eax
  801bef:	89 04 24             	mov    %eax,(%esp)
  801bf2:	e8 14 08 00 00       	call   80240b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801bf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bfe:	00 
  801bff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0a:	e8 7a 08 00 00       	call   802489 <ipc_recv>
}
  801c0f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c12:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c15:	89 ec                	mov    %ebp,%esp
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c22:	8b 40 0c             	mov    0xc(%eax),%eax
  801c25:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c32:	ba 00 00 00 00       	mov    $0x0,%edx
  801c37:	b8 02 00 00 00       	mov    $0x2,%eax
  801c3c:	e8 6b ff ff ff       	call   801bac <fsipc>
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c4f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c54:	ba 00 00 00 00       	mov    $0x0,%edx
  801c59:	b8 06 00 00 00       	mov    $0x6,%eax
  801c5e:	e8 49 ff ff ff       	call   801bac <fsipc>
}
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    

00801c65 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c70:	b8 08 00 00 00       	mov    $0x8,%eax
  801c75:	e8 32 ff ff ff       	call   801bac <fsipc>
}
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	53                   	push   %ebx
  801c80:	83 ec 14             	sub    $0x14,%esp
  801c83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	8b 40 0c             	mov    0xc(%eax),%eax
  801c8c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c91:	ba 00 00 00 00       	mov    $0x0,%edx
  801c96:	b8 05 00 00 00       	mov    $0x5,%eax
  801c9b:	e8 0c ff ff ff       	call   801bac <fsipc>
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	78 2b                	js     801ccf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ca4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cab:	00 
  801cac:	89 1c 24             	mov    %ebx,(%esp)
  801caf:	e8 06 ee ff ff       	call   800aba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cb4:	a1 80 50 80 00       	mov    0x805080,%eax
  801cb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cbf:	a1 84 50 80 00       	mov    0x805084,%eax
  801cc4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801ccf:	83 c4 14             	add    $0x14,%esp
  801cd2:	5b                   	pop    %ebx
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 18             	sub    $0x18,%esp
  801cdb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cde:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ce3:	76 05                	jbe    801cea <devfile_write+0x15>
  801ce5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cea:	8b 55 08             	mov    0x8(%ebp),%edx
  801ced:	8b 52 0c             	mov    0xc(%edx),%edx
  801cf0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801cf6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d06:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801d0d:	e8 93 ef ff ff       	call   800ca5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801d12:	ba 00 00 00 00       	mov    $0x0,%edx
  801d17:	b8 04 00 00 00       	mov    $0x4,%eax
  801d1c:	e8 8b fe ff ff       	call   801bac <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	53                   	push   %ebx
  801d27:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d30:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801d35:	8b 45 10             	mov    0x10(%ebp),%eax
  801d38:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801d3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d42:	b8 03 00 00 00       	mov    $0x3,%eax
  801d47:	e8 60 fe ff ff       	call   801bac <fsipc>
  801d4c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	78 17                	js     801d69 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801d52:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d56:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d5d:	00 
  801d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d61:	89 04 24             	mov    %eax,(%esp)
  801d64:	e8 3c ef ff ff       	call   800ca5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	83 c4 14             	add    $0x14,%esp
  801d6e:	5b                   	pop    %ebx
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	53                   	push   %ebx
  801d75:	83 ec 14             	sub    $0x14,%esp
  801d78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d7b:	89 1c 24             	mov    %ebx,(%esp)
  801d7e:	e8 ed ec ff ff       	call   800a70 <strlen>
  801d83:	89 c2                	mov    %eax,%edx
  801d85:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d8a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d90:	7f 1f                	jg     801db1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d96:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d9d:	e8 18 ed ff ff       	call   800aba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801da2:	ba 00 00 00 00       	mov    $0x0,%edx
  801da7:	b8 07 00 00 00       	mov    $0x7,%eax
  801dac:	e8 fb fd ff ff       	call   801bac <fsipc>
}
  801db1:	83 c4 14             	add    $0x14,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 28             	sub    $0x28,%esp
  801dbd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dc0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801dc3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801dc6:	89 34 24             	mov    %esi,(%esp)
  801dc9:	e8 a2 ec ff ff       	call   800a70 <strlen>
  801dce:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801dd3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dd8:	7f 6d                	jg     801e47 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801dda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddd:	89 04 24             	mov    %eax,(%esp)
  801de0:	e8 d6 f7 ff ff       	call   8015bb <fd_alloc>
  801de5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801de7:	85 c0                	test   %eax,%eax
  801de9:	78 5c                	js     801e47 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801deb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dee:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801df3:	89 34 24             	mov    %esi,(%esp)
  801df6:	e8 75 ec ff ff       	call   800a70 <strlen>
  801dfb:	83 c0 01             	add    $0x1,%eax
  801dfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e02:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e06:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e0d:	e8 93 ee ff ff       	call   800ca5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801e12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e15:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1a:	e8 8d fd ff ff       	call   801bac <fsipc>
  801e1f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801e21:	85 c0                	test   %eax,%eax
  801e23:	79 15                	jns    801e3a <open+0x83>
             fd_close(fd,0);
  801e25:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e2c:	00 
  801e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e30:	89 04 24             	mov    %eax,(%esp)
  801e33:	e8 37 fb ff ff       	call   80196f <fd_close>
             return r;
  801e38:	eb 0d                	jmp    801e47 <open+0x90>
        }
        return fd2num(fd);
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	89 04 24             	mov    %eax,(%esp)
  801e40:	e8 4b f7 ff ff       	call   801590 <fd2num>
  801e45:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801e47:	89 d8                	mov    %ebx,%eax
  801e49:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e4c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e4f:	89 ec                	mov    %ebp,%esp
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    
	...

00801e60 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e66:	c7 44 24 04 34 2c 80 	movl   $0x802c34,0x4(%esp)
  801e6d:	00 
  801e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	e8 41 ec ff ff       	call   800aba <strcpy>
	return 0;
}
  801e79:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	53                   	push   %ebx
  801e84:	83 ec 14             	sub    $0x14,%esp
  801e87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e8a:	89 1c 24             	mov    %ebx,(%esp)
  801e8d:	e8 6a 06 00 00       	call   8024fc <pageref>
  801e92:	89 c2                	mov    %eax,%edx
  801e94:	b8 00 00 00 00       	mov    $0x0,%eax
  801e99:	83 fa 01             	cmp    $0x1,%edx
  801e9c:	75 0b                	jne    801ea9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801e9e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ea1:	89 04 24             	mov    %eax,(%esp)
  801ea4:	e8 b9 02 00 00       	call   802162 <nsipc_close>
	else
		return 0;
}
  801ea9:	83 c4 14             	add    $0x14,%esp
  801eac:	5b                   	pop    %ebx
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801eb5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ebc:	00 
  801ebd:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ece:	8b 40 0c             	mov    0xc(%eax),%eax
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 c5 02 00 00       	call   80219e <nsipc_send>
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ee1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ee8:	00 
  801ee9:	8b 45 10             	mov    0x10(%ebp),%eax
  801eec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  801efa:	8b 40 0c             	mov    0xc(%eax),%eax
  801efd:	89 04 24             	mov    %eax,(%esp)
  801f00:	e8 0c 03 00 00       	call   802211 <nsipc_recv>
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	56                   	push   %esi
  801f0b:	53                   	push   %ebx
  801f0c:	83 ec 20             	sub    $0x20,%esp
  801f0f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f14:	89 04 24             	mov    %eax,(%esp)
  801f17:	e8 9f f6 ff ff       	call   8015bb <fd_alloc>
  801f1c:	89 c3                	mov    %eax,%ebx
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 21                	js     801f43 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f29:	00 
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f38:	e8 ab f4 ff ff       	call   8013e8 <sys_page_alloc>
  801f3d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	79 0a                	jns    801f4d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801f43:	89 34 24             	mov    %esi,(%esp)
  801f46:	e8 17 02 00 00       	call   802162 <nsipc_close>
		return r;
  801f4b:	eb 28                	jmp    801f75 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f56:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f65:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6b:	89 04 24             	mov    %eax,(%esp)
  801f6e:	e8 1d f6 ff ff       	call   801590 <fd2num>
  801f73:	89 c3                	mov    %eax,%ebx
}
  801f75:	89 d8                	mov    %ebx,%eax
  801f77:	83 c4 20             	add    $0x20,%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f84:	8b 45 10             	mov    0x10(%ebp),%eax
  801f87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 79 01 00 00       	call   802116 <nsipc_socket>
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 05                	js     801fa6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801fa1:	e8 61 ff ff ff       	call   801f07 <alloc_sockfd>
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801fae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801fb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fb5:	89 04 24             	mov    %eax,(%esp)
  801fb8:	e8 70 f6 ff ff       	call   80162d <fd_lookup>
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 15                	js     801fd6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801fc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fc4:	8b 0a                	mov    (%edx),%ecx
  801fc6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801fcb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801fd1:	75 03                	jne    801fd6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801fd3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fde:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe1:	e8 c2 ff ff ff       	call   801fa8 <fd2sockid>
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	78 0f                	js     801ff9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801fea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fed:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ff1:	89 04 24             	mov    %eax,(%esp)
  801ff4:	e8 47 01 00 00       	call   802140 <nsipc_listen>
}
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	e8 9f ff ff ff       	call   801fa8 <fd2sockid>
  802009:	85 c0                	test   %eax,%eax
  80200b:	78 16                	js     802023 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80200d:	8b 55 10             	mov    0x10(%ebp),%edx
  802010:	89 54 24 08          	mov    %edx,0x8(%esp)
  802014:	8b 55 0c             	mov    0xc(%ebp),%edx
  802017:	89 54 24 04          	mov    %edx,0x4(%esp)
  80201b:	89 04 24             	mov    %eax,(%esp)
  80201e:	e8 6e 02 00 00       	call   802291 <nsipc_connect>
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80202b:	8b 45 08             	mov    0x8(%ebp),%eax
  80202e:	e8 75 ff ff ff       	call   801fa8 <fd2sockid>
  802033:	85 c0                	test   %eax,%eax
  802035:	78 0f                	js     802046 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802037:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80203e:	89 04 24             	mov    %eax,(%esp)
  802041:	e8 36 01 00 00       	call   80217c <nsipc_shutdown>
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    

00802048 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	e8 52 ff ff ff       	call   801fa8 <fd2sockid>
  802056:	85 c0                	test   %eax,%eax
  802058:	78 16                	js     802070 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80205a:	8b 55 10             	mov    0x10(%ebp),%edx
  80205d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802061:	8b 55 0c             	mov    0xc(%ebp),%edx
  802064:	89 54 24 04          	mov    %edx,0x4(%esp)
  802068:	89 04 24             	mov    %eax,(%esp)
  80206b:	e8 60 02 00 00       	call   8022d0 <nsipc_bind>
}
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802078:	8b 45 08             	mov    0x8(%ebp),%eax
  80207b:	e8 28 ff ff ff       	call   801fa8 <fd2sockid>
  802080:	85 c0                	test   %eax,%eax
  802082:	78 1f                	js     8020a3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802084:	8b 55 10             	mov    0x10(%ebp),%edx
  802087:	89 54 24 08          	mov    %edx,0x8(%esp)
  80208b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80208e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802092:	89 04 24             	mov    %eax,(%esp)
  802095:	e8 75 02 00 00       	call   80230f <nsipc_accept>
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 05                	js     8020a3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80209e:	e8 64 fe ff ff       	call   801f07 <alloc_sockfd>
}
  8020a3:	c9                   	leave  
  8020a4:	c3                   	ret    
	...

008020b0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 14             	sub    $0x14,%esp
  8020b7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020b9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8020c0:	75 11                	jne    8020d3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020c2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8020c9:	e8 f2 02 00 00       	call   8023c0 <ipc_find_env>
  8020ce:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020d3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020da:	00 
  8020db:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8020e2:	00 
  8020e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ec:	89 04 24             	mov    %eax,(%esp)
  8020ef:	e8 17 03 00 00       	call   80240b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020fb:	00 
  8020fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802103:	00 
  802104:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210b:	e8 79 03 00 00       	call   802489 <ipc_recv>
}
  802110:	83 c4 14             	add    $0x14,%esp
  802113:	5b                   	pop    %ebx
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80211c:	8b 45 08             	mov    0x8(%ebp),%eax
  80211f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802124:	8b 45 0c             	mov    0xc(%ebp),%eax
  802127:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80212c:	8b 45 10             	mov    0x10(%ebp),%eax
  80212f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802134:	b8 09 00 00 00       	mov    $0x9,%eax
  802139:	e8 72 ff ff ff       	call   8020b0 <nsipc>
}
  80213e:	c9                   	leave  
  80213f:	c3                   	ret    

00802140 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802146:	8b 45 08             	mov    0x8(%ebp),%eax
  802149:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80214e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802151:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802156:	b8 06 00 00 00       	mov    $0x6,%eax
  80215b:	e8 50 ff ff ff       	call   8020b0 <nsipc>
}
  802160:	c9                   	leave  
  802161:	c3                   	ret    

00802162 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802168:	8b 45 08             	mov    0x8(%ebp),%eax
  80216b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802170:	b8 04 00 00 00       	mov    $0x4,%eax
  802175:	e8 36 ff ff ff       	call   8020b0 <nsipc>
}
  80217a:	c9                   	leave  
  80217b:	c3                   	ret    

0080217c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802182:	8b 45 08             	mov    0x8(%ebp),%eax
  802185:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80218a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802192:	b8 03 00 00 00       	mov    $0x3,%eax
  802197:	e8 14 ff ff ff       	call   8020b0 <nsipc>
}
  80219c:	c9                   	leave  
  80219d:	c3                   	ret    

0080219e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	53                   	push   %ebx
  8021a2:	83 ec 14             	sub    $0x14,%esp
  8021a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ab:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8021b0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021b6:	7e 24                	jle    8021dc <nsipc_send+0x3e>
  8021b8:	c7 44 24 0c 40 2c 80 	movl   $0x802c40,0xc(%esp)
  8021bf:	00 
  8021c0:	c7 44 24 08 4c 2c 80 	movl   $0x802c4c,0x8(%esp)
  8021c7:	00 
  8021c8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8021cf:	00 
  8021d0:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8021d7:	e8 88 01 00 00       	call   802364 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8021ee:	e8 b2 ea ff ff       	call   800ca5 <memmove>
	nsipcbuf.send.req_size = size;
  8021f3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8021fc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802201:	b8 08 00 00 00       	mov    $0x8,%eax
  802206:	e8 a5 fe ff ff       	call   8020b0 <nsipc>
}
  80220b:	83 c4 14             	add    $0x14,%esp
  80220e:	5b                   	pop    %ebx
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    

00802211 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	56                   	push   %esi
  802215:	53                   	push   %ebx
  802216:	83 ec 10             	sub    $0x10,%esp
  802219:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80221c:	8b 45 08             	mov    0x8(%ebp),%eax
  80221f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802224:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80222a:	8b 45 14             	mov    0x14(%ebp),%eax
  80222d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802232:	b8 07 00 00 00       	mov    $0x7,%eax
  802237:	e8 74 fe ff ff       	call   8020b0 <nsipc>
  80223c:	89 c3                	mov    %eax,%ebx
  80223e:	85 c0                	test   %eax,%eax
  802240:	78 46                	js     802288 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802242:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802247:	7f 04                	jg     80224d <nsipc_recv+0x3c>
  802249:	39 c6                	cmp    %eax,%esi
  80224b:	7d 24                	jge    802271 <nsipc_recv+0x60>
  80224d:	c7 44 24 0c 6d 2c 80 	movl   $0x802c6d,0xc(%esp)
  802254:	00 
  802255:	c7 44 24 08 4c 2c 80 	movl   $0x802c4c,0x8(%esp)
  80225c:	00 
  80225d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802264:	00 
  802265:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80226c:	e8 f3 00 00 00       	call   802364 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802271:	89 44 24 08          	mov    %eax,0x8(%esp)
  802275:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80227c:	00 
  80227d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802280:	89 04 24             	mov    %eax,(%esp)
  802283:	e8 1d ea ff ff       	call   800ca5 <memmove>
	}

	return r;
}
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	83 c4 10             	add    $0x10,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5d                   	pop    %ebp
  802290:	c3                   	ret    

00802291 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	53                   	push   %ebx
  802295:	83 ec 14             	sub    $0x14,%esp
  802298:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80229b:	8b 45 08             	mov    0x8(%ebp),%eax
  80229e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8022a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ae:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8022b5:	e8 eb e9 ff ff       	call   800ca5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8022ba:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8022c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8022c5:	e8 e6 fd ff ff       	call   8020b0 <nsipc>
}
  8022ca:	83 c4 14             	add    $0x14,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5d                   	pop    %ebp
  8022cf:	c3                   	ret    

008022d0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 14             	sub    $0x14,%esp
  8022d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8022da:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8022e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ed:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8022f4:	e8 ac e9 ff ff       	call   800ca5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8022f9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8022ff:	b8 02 00 00 00       	mov    $0x2,%eax
  802304:	e8 a7 fd ff ff       	call   8020b0 <nsipc>
}
  802309:	83 c4 14             	add    $0x14,%esp
  80230c:	5b                   	pop    %ebx
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    

0080230f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80230f:	55                   	push   %ebp
  802310:	89 e5                	mov    %esp,%ebp
  802312:	83 ec 18             	sub    $0x18,%esp
  802315:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802318:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80231b:	8b 45 08             	mov    0x8(%ebp),%eax
  80231e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802323:	b8 01 00 00 00       	mov    $0x1,%eax
  802328:	e8 83 fd ff ff       	call   8020b0 <nsipc>
  80232d:	89 c3                	mov    %eax,%ebx
  80232f:	85 c0                	test   %eax,%eax
  802331:	78 25                	js     802358 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802333:	be 10 60 80 00       	mov    $0x806010,%esi
  802338:	8b 06                	mov    (%esi),%eax
  80233a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80233e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802345:	00 
  802346:	8b 45 0c             	mov    0xc(%ebp),%eax
  802349:	89 04 24             	mov    %eax,(%esp)
  80234c:	e8 54 e9 ff ff       	call   800ca5 <memmove>
		*addrlen = ret->ret_addrlen;
  802351:	8b 16                	mov    (%esi),%edx
  802353:	8b 45 10             	mov    0x10(%ebp),%eax
  802356:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80235d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802360:	89 ec                	mov    %ebp,%esp
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    

00802364 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	56                   	push   %esi
  802368:	53                   	push   %ebx
  802369:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80236c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80236f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802375:	e8 5d f1 ff ff       	call   8014d7 <sys_getenvid>
  80237a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80237d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802381:	8b 55 08             	mov    0x8(%ebp),%edx
  802384:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802388:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80238c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802390:	c7 04 24 84 2c 80 00 	movl   $0x802c84,(%esp)
  802397:	e8 f1 dd ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80239c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8023a3:	89 04 24             	mov    %eax,(%esp)
  8023a6:	e8 81 dd ff ff       	call   80012c <vcprintf>
	cprintf("\n");
  8023ab:	c7 04 24 ed 27 80 00 	movl   $0x8027ed,(%esp)
  8023b2:	e8 d6 dd ff ff       	call   80018d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023b7:	cc                   	int3   
  8023b8:	eb fd                	jmp    8023b7 <_panic+0x53>
  8023ba:	00 00                	add    %al,(%eax)
  8023bc:	00 00                	add    %al,(%eax)
	...

008023c0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8023c6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8023cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d1:	39 ca                	cmp    %ecx,%edx
  8023d3:	75 04                	jne    8023d9 <ipc_find_env+0x19>
  8023d5:	b0 00                	mov    $0x0,%al
  8023d7:	eb 12                	jmp    8023eb <ipc_find_env+0x2b>
  8023d9:	89 c2                	mov    %eax,%edx
  8023db:	c1 e2 07             	shl    $0x7,%edx
  8023de:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8023e5:	8b 12                	mov    (%edx),%edx
  8023e7:	39 ca                	cmp    %ecx,%edx
  8023e9:	75 10                	jne    8023fb <ipc_find_env+0x3b>
			return envs[i].env_id;
  8023eb:	89 c2                	mov    %eax,%edx
  8023ed:	c1 e2 07             	shl    $0x7,%edx
  8023f0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8023f7:	8b 00                	mov    (%eax),%eax
  8023f9:	eb 0e                	jmp    802409 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023fb:	83 c0 01             	add    $0x1,%eax
  8023fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802403:	75 d4                	jne    8023d9 <ipc_find_env+0x19>
  802405:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    

0080240b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	57                   	push   %edi
  80240f:	56                   	push   %esi
  802410:	53                   	push   %ebx
  802411:	83 ec 1c             	sub    $0x1c,%esp
  802414:	8b 75 08             	mov    0x8(%ebp),%esi
  802417:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80241a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80241d:	85 db                	test   %ebx,%ebx
  80241f:	74 19                	je     80243a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802421:	8b 45 14             	mov    0x14(%ebp),%eax
  802424:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802428:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80242c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802430:	89 34 24             	mov    %esi,(%esp)
  802433:	e8 51 ed ff ff       	call   801189 <sys_ipc_try_send>
  802438:	eb 1b                	jmp    802455 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80243a:	8b 45 14             	mov    0x14(%ebp),%eax
  80243d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802441:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802448:	ee 
  802449:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80244d:	89 34 24             	mov    %esi,(%esp)
  802450:	e8 34 ed ff ff       	call   801189 <sys_ipc_try_send>
           if(ret == 0)
  802455:	85 c0                	test   %eax,%eax
  802457:	74 28                	je     802481 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802459:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80245c:	74 1c                	je     80247a <ipc_send+0x6f>
              panic("ipc send error");
  80245e:	c7 44 24 08 a8 2c 80 	movl   $0x802ca8,0x8(%esp)
  802465:	00 
  802466:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80246d:	00 
  80246e:	c7 04 24 b7 2c 80 00 	movl   $0x802cb7,(%esp)
  802475:	e8 ea fe ff ff       	call   802364 <_panic>
           sys_yield();
  80247a:	e8 d6 ef ff ff       	call   801455 <sys_yield>
        }
  80247f:	eb 9c                	jmp    80241d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802481:	83 c4 1c             	add    $0x1c,%esp
  802484:	5b                   	pop    %ebx
  802485:	5e                   	pop    %esi
  802486:	5f                   	pop    %edi
  802487:	5d                   	pop    %ebp
  802488:	c3                   	ret    

00802489 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802489:	55                   	push   %ebp
  80248a:	89 e5                	mov    %esp,%ebp
  80248c:	56                   	push   %esi
  80248d:	53                   	push   %ebx
  80248e:	83 ec 10             	sub    $0x10,%esp
  802491:	8b 75 08             	mov    0x8(%ebp),%esi
  802494:	8b 45 0c             	mov    0xc(%ebp),%eax
  802497:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80249a:	85 c0                	test   %eax,%eax
  80249c:	75 0e                	jne    8024ac <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80249e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8024a5:	e8 74 ec ff ff       	call   80111e <sys_ipc_recv>
  8024aa:	eb 08                	jmp    8024b4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8024ac:	89 04 24             	mov    %eax,(%esp)
  8024af:	e8 6a ec ff ff       	call   80111e <sys_ipc_recv>
        if(ret == 0){
  8024b4:	85 c0                	test   %eax,%eax
  8024b6:	75 26                	jne    8024de <ipc_recv+0x55>
           if(from_env_store)
  8024b8:	85 f6                	test   %esi,%esi
  8024ba:	74 0a                	je     8024c6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  8024bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8024c1:	8b 40 78             	mov    0x78(%eax),%eax
  8024c4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  8024c6:	85 db                	test   %ebx,%ebx
  8024c8:	74 0a                	je     8024d4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  8024ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8024cf:	8b 40 7c             	mov    0x7c(%eax),%eax
  8024d2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8024d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8024d9:	8b 40 74             	mov    0x74(%eax),%eax
  8024dc:	eb 14                	jmp    8024f2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8024de:	85 f6                	test   %esi,%esi
  8024e0:	74 06                	je     8024e8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8024e2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8024e8:	85 db                	test   %ebx,%ebx
  8024ea:	74 06                	je     8024f2 <ipc_recv+0x69>
              *perm_store = 0;
  8024ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8024f2:	83 c4 10             	add    $0x10,%esp
  8024f5:	5b                   	pop    %ebx
  8024f6:	5e                   	pop    %esi
  8024f7:	5d                   	pop    %ebp
  8024f8:	c3                   	ret    
  8024f9:	00 00                	add    %al,(%eax)
	...

008024fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024fc:	55                   	push   %ebp
  8024fd:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8024ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802502:	89 c2                	mov    %eax,%edx
  802504:	c1 ea 16             	shr    $0x16,%edx
  802507:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80250e:	f6 c2 01             	test   $0x1,%dl
  802511:	74 20                	je     802533 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802513:	c1 e8 0c             	shr    $0xc,%eax
  802516:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80251d:	a8 01                	test   $0x1,%al
  80251f:	74 12                	je     802533 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802521:	c1 e8 0c             	shr    $0xc,%eax
  802524:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802529:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80252e:	0f b7 c0             	movzwl %ax,%eax
  802531:	eb 05                	jmp    802538 <pageref+0x3c>
  802533:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802538:	5d                   	pop    %ebp
  802539:	c3                   	ret    
  80253a:	00 00                	add    %al,(%eax)
  80253c:	00 00                	add    %al,(%eax)
	...

00802540 <__udivdi3>:
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	57                   	push   %edi
  802544:	56                   	push   %esi
  802545:	83 ec 10             	sub    $0x10,%esp
  802548:	8b 45 14             	mov    0x14(%ebp),%eax
  80254b:	8b 55 08             	mov    0x8(%ebp),%edx
  80254e:	8b 75 10             	mov    0x10(%ebp),%esi
  802551:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802554:	85 c0                	test   %eax,%eax
  802556:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802559:	75 35                	jne    802590 <__udivdi3+0x50>
  80255b:	39 fe                	cmp    %edi,%esi
  80255d:	77 61                	ja     8025c0 <__udivdi3+0x80>
  80255f:	85 f6                	test   %esi,%esi
  802561:	75 0b                	jne    80256e <__udivdi3+0x2e>
  802563:	b8 01 00 00 00       	mov    $0x1,%eax
  802568:	31 d2                	xor    %edx,%edx
  80256a:	f7 f6                	div    %esi
  80256c:	89 c6                	mov    %eax,%esi
  80256e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802571:	31 d2                	xor    %edx,%edx
  802573:	89 f8                	mov    %edi,%eax
  802575:	f7 f6                	div    %esi
  802577:	89 c7                	mov    %eax,%edi
  802579:	89 c8                	mov    %ecx,%eax
  80257b:	f7 f6                	div    %esi
  80257d:	89 c1                	mov    %eax,%ecx
  80257f:	89 fa                	mov    %edi,%edx
  802581:	89 c8                	mov    %ecx,%eax
  802583:	83 c4 10             	add    $0x10,%esp
  802586:	5e                   	pop    %esi
  802587:	5f                   	pop    %edi
  802588:	5d                   	pop    %ebp
  802589:	c3                   	ret    
  80258a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802590:	39 f8                	cmp    %edi,%eax
  802592:	77 1c                	ja     8025b0 <__udivdi3+0x70>
  802594:	0f bd d0             	bsr    %eax,%edx
  802597:	83 f2 1f             	xor    $0x1f,%edx
  80259a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80259d:	75 39                	jne    8025d8 <__udivdi3+0x98>
  80259f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8025a2:	0f 86 a0 00 00 00    	jbe    802648 <__udivdi3+0x108>
  8025a8:	39 f8                	cmp    %edi,%eax
  8025aa:	0f 82 98 00 00 00    	jb     802648 <__udivdi3+0x108>
  8025b0:	31 ff                	xor    %edi,%edi
  8025b2:	31 c9                	xor    %ecx,%ecx
  8025b4:	89 c8                	mov    %ecx,%eax
  8025b6:	89 fa                	mov    %edi,%edx
  8025b8:	83 c4 10             	add    $0x10,%esp
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    
  8025bf:	90                   	nop
  8025c0:	89 d1                	mov    %edx,%ecx
  8025c2:	89 fa                	mov    %edi,%edx
  8025c4:	89 c8                	mov    %ecx,%eax
  8025c6:	31 ff                	xor    %edi,%edi
  8025c8:	f7 f6                	div    %esi
  8025ca:	89 c1                	mov    %eax,%ecx
  8025cc:	89 fa                	mov    %edi,%edx
  8025ce:	89 c8                	mov    %ecx,%eax
  8025d0:	83 c4 10             	add    $0x10,%esp
  8025d3:	5e                   	pop    %esi
  8025d4:	5f                   	pop    %edi
  8025d5:	5d                   	pop    %ebp
  8025d6:	c3                   	ret    
  8025d7:	90                   	nop
  8025d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025dc:	89 f2                	mov    %esi,%edx
  8025de:	d3 e0                	shl    %cl,%eax
  8025e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8025e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8025e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8025eb:	89 c1                	mov    %eax,%ecx
  8025ed:	d3 ea                	shr    %cl,%edx
  8025ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8025f6:	d3 e6                	shl    %cl,%esi
  8025f8:	89 c1                	mov    %eax,%ecx
  8025fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8025fd:	89 fe                	mov    %edi,%esi
  8025ff:	d3 ee                	shr    %cl,%esi
  802601:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802605:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802608:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80260b:	d3 e7                	shl    %cl,%edi
  80260d:	89 c1                	mov    %eax,%ecx
  80260f:	d3 ea                	shr    %cl,%edx
  802611:	09 d7                	or     %edx,%edi
  802613:	89 f2                	mov    %esi,%edx
  802615:	89 f8                	mov    %edi,%eax
  802617:	f7 75 ec             	divl   -0x14(%ebp)
  80261a:	89 d6                	mov    %edx,%esi
  80261c:	89 c7                	mov    %eax,%edi
  80261e:	f7 65 e8             	mull   -0x18(%ebp)
  802621:	39 d6                	cmp    %edx,%esi
  802623:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802626:	72 30                	jb     802658 <__udivdi3+0x118>
  802628:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80262b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80262f:	d3 e2                	shl    %cl,%edx
  802631:	39 c2                	cmp    %eax,%edx
  802633:	73 05                	jae    80263a <__udivdi3+0xfa>
  802635:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802638:	74 1e                	je     802658 <__udivdi3+0x118>
  80263a:	89 f9                	mov    %edi,%ecx
  80263c:	31 ff                	xor    %edi,%edi
  80263e:	e9 71 ff ff ff       	jmp    8025b4 <__udivdi3+0x74>
  802643:	90                   	nop
  802644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802648:	31 ff                	xor    %edi,%edi
  80264a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80264f:	e9 60 ff ff ff       	jmp    8025b4 <__udivdi3+0x74>
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80265b:	31 ff                	xor    %edi,%edi
  80265d:	89 c8                	mov    %ecx,%eax
  80265f:	89 fa                	mov    %edi,%edx
  802661:	83 c4 10             	add    $0x10,%esp
  802664:	5e                   	pop    %esi
  802665:	5f                   	pop    %edi
  802666:	5d                   	pop    %ebp
  802667:	c3                   	ret    
	...

00802670 <__umoddi3>:
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
  802673:	57                   	push   %edi
  802674:	56                   	push   %esi
  802675:	83 ec 20             	sub    $0x20,%esp
  802678:	8b 55 14             	mov    0x14(%ebp),%edx
  80267b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80267e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802681:	8b 75 0c             	mov    0xc(%ebp),%esi
  802684:	85 d2                	test   %edx,%edx
  802686:	89 c8                	mov    %ecx,%eax
  802688:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80268b:	75 13                	jne    8026a0 <__umoddi3+0x30>
  80268d:	39 f7                	cmp    %esi,%edi
  80268f:	76 3f                	jbe    8026d0 <__umoddi3+0x60>
  802691:	89 f2                	mov    %esi,%edx
  802693:	f7 f7                	div    %edi
  802695:	89 d0                	mov    %edx,%eax
  802697:	31 d2                	xor    %edx,%edx
  802699:	83 c4 20             	add    $0x20,%esp
  80269c:	5e                   	pop    %esi
  80269d:	5f                   	pop    %edi
  80269e:	5d                   	pop    %ebp
  80269f:	c3                   	ret    
  8026a0:	39 f2                	cmp    %esi,%edx
  8026a2:	77 4c                	ja     8026f0 <__umoddi3+0x80>
  8026a4:	0f bd ca             	bsr    %edx,%ecx
  8026a7:	83 f1 1f             	xor    $0x1f,%ecx
  8026aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8026ad:	75 51                	jne    802700 <__umoddi3+0x90>
  8026af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8026b2:	0f 87 e0 00 00 00    	ja     802798 <__umoddi3+0x128>
  8026b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026bb:	29 f8                	sub    %edi,%eax
  8026bd:	19 d6                	sbb    %edx,%esi
  8026bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8026c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026c5:	89 f2                	mov    %esi,%edx
  8026c7:	83 c4 20             	add    $0x20,%esp
  8026ca:	5e                   	pop    %esi
  8026cb:	5f                   	pop    %edi
  8026cc:	5d                   	pop    %ebp
  8026cd:	c3                   	ret    
  8026ce:	66 90                	xchg   %ax,%ax
  8026d0:	85 ff                	test   %edi,%edi
  8026d2:	75 0b                	jne    8026df <__umoddi3+0x6f>
  8026d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8026d9:	31 d2                	xor    %edx,%edx
  8026db:	f7 f7                	div    %edi
  8026dd:	89 c7                	mov    %eax,%edi
  8026df:	89 f0                	mov    %esi,%eax
  8026e1:	31 d2                	xor    %edx,%edx
  8026e3:	f7 f7                	div    %edi
  8026e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e8:	f7 f7                	div    %edi
  8026ea:	eb a9                	jmp    802695 <__umoddi3+0x25>
  8026ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	89 c8                	mov    %ecx,%eax
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	83 c4 20             	add    $0x20,%esp
  8026f7:	5e                   	pop    %esi
  8026f8:	5f                   	pop    %edi
  8026f9:	5d                   	pop    %ebp
  8026fa:	c3                   	ret    
  8026fb:	90                   	nop
  8026fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802700:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802704:	d3 e2                	shl    %cl,%edx
  802706:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802709:	ba 20 00 00 00       	mov    $0x20,%edx
  80270e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802711:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802714:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802718:	89 fa                	mov    %edi,%edx
  80271a:	d3 ea                	shr    %cl,%edx
  80271c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802720:	0b 55 f4             	or     -0xc(%ebp),%edx
  802723:	d3 e7                	shl    %cl,%edi
  802725:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802729:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80272c:	89 f2                	mov    %esi,%edx
  80272e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802731:	89 c7                	mov    %eax,%edi
  802733:	d3 ea                	shr    %cl,%edx
  802735:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802739:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80273c:	89 c2                	mov    %eax,%edx
  80273e:	d3 e6                	shl    %cl,%esi
  802740:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802744:	d3 ea                	shr    %cl,%edx
  802746:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80274a:	09 d6                	or     %edx,%esi
  80274c:	89 f0                	mov    %esi,%eax
  80274e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802751:	d3 e7                	shl    %cl,%edi
  802753:	89 f2                	mov    %esi,%edx
  802755:	f7 75 f4             	divl   -0xc(%ebp)
  802758:	89 d6                	mov    %edx,%esi
  80275a:	f7 65 e8             	mull   -0x18(%ebp)
  80275d:	39 d6                	cmp    %edx,%esi
  80275f:	72 2b                	jb     80278c <__umoddi3+0x11c>
  802761:	39 c7                	cmp    %eax,%edi
  802763:	72 23                	jb     802788 <__umoddi3+0x118>
  802765:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802769:	29 c7                	sub    %eax,%edi
  80276b:	19 d6                	sbb    %edx,%esi
  80276d:	89 f0                	mov    %esi,%eax
  80276f:	89 f2                	mov    %esi,%edx
  802771:	d3 ef                	shr    %cl,%edi
  802773:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802777:	d3 e0                	shl    %cl,%eax
  802779:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80277d:	09 f8                	or     %edi,%eax
  80277f:	d3 ea                	shr    %cl,%edx
  802781:	83 c4 20             	add    $0x20,%esp
  802784:	5e                   	pop    %esi
  802785:	5f                   	pop    %edi
  802786:	5d                   	pop    %ebp
  802787:	c3                   	ret    
  802788:	39 d6                	cmp    %edx,%esi
  80278a:	75 d9                	jne    802765 <__umoddi3+0xf5>
  80278c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80278f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802792:	eb d1                	jmp    802765 <__umoddi3+0xf5>
  802794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802798:	39 f2                	cmp    %esi,%edx
  80279a:	0f 82 18 ff ff ff    	jb     8026b8 <__umoddi3+0x48>
  8027a0:	e9 1d ff ff ff       	jmp    8026c2 <__umoddi3+0x52>
