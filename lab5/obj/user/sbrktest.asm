
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
  800044:	e8 8f 0f 00 00       	call   800fd8 <sys_sbrk>
  800049:	89 c6                	mov    %eax,%esi
	end = sys_sbrk(ALLOCATE_SIZE);
  80004b:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  800052:	e8 81 0f 00 00       	call   800fd8 <sys_sbrk>

	if (end - start < ALLOCATE_SIZE) {
  800057:	29 f0                	sub    %esi,%eax
  800059:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  80005e:	77 0c                	ja     80006c <umain+0x38>
		cprintf("sbrk not correctly implemented\n");
  800060:	c7 04 24 60 21 80 00 	movl   $0x802160,(%esp)
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
  8000a5:	c7 04 24 80 21 80 00 	movl   $0x802180,(%esp)
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
  8000ce:	e8 ff 12 00 00       	call   8013d2 <sys_getenvid>
  8000d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d8:	89 c2                	mov    %eax,%edx
  8000da:	c1 e2 07             	shl    $0x7,%edx
  8000dd:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000e4:	a3 04 40 80 00       	mov    %eax,0x804004
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
  800116:	e8 40 18 00 00       	call   80195b <close_all>
	sys_env_destroy(0);
  80011b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800122:	e8 eb 12 00 00       	call   801412 <sys_env_destroy>
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
  80025f:	e8 7c 1c 00 00       	call   801ee0 <__udivdi3>
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
  8002c7:	e8 44 1d 00 00       	call   802010 <__umoddi3>
  8002cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d0:	0f be 80 99 21 80 00 	movsbl 0x802199(%eax),%eax
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
  8003ba:	ff 24 95 80 23 80 00 	jmp    *0x802380(,%edx,4)
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
  800477:	8b 14 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%edx
  80047e:	85 d2                	test   %edx,%edx
  800480:	75 26                	jne    8004a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800482:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800486:	c7 44 24 08 aa 21 80 	movl   $0x8021aa,0x8(%esp)
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
  8004ac:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
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
  8004ea:	be b6 21 80 00       	mov    $0x8021b6,%esi
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
  800794:	e8 47 17 00 00       	call   801ee0 <__udivdi3>
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
  8007e0:	e8 2b 18 00 00       	call   802010 <__umoddi3>
  8007e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e9:	0f be 80 99 21 80 00 	movsbl 0x802199(%eax),%eax
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
  800895:	c7 44 24 0c d0 22 80 	movl   $0x8022d0,0xc(%esp)
  80089c:	00 
  80089d:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
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
  8008cb:	c7 44 24 0c 08 23 80 	movl   $0x802308,0xc(%esp)
  8008d2:	00 
  8008d3:	c7 44 24 08 b3 21 80 	movl   $0x8021b3,0x8(%esp)
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
  80095f:	e8 ac 16 00 00       	call   802010 <__umoddi3>
  800964:	89 74 24 04          	mov    %esi,0x4(%esp)
  800968:	0f be 80 99 21 80 00 	movsbl 0x802199(%eax),%eax
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
  8009a1:	e8 6a 16 00 00       	call   802010 <__umoddi3>
  8009a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009aa:	0f be 80 99 21 80 00 	movsbl 0x802199(%eax),%eax
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

00800f2b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
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
  800f38:	b8 10 00 00 00       	mov    $0x10,%eax
  800f3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
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
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800f61:	8b 1c 24             	mov    (%esp),%ebx
  800f64:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f68:	89 ec                	mov    %ebp,%esp
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 28             	sub    $0x28,%esp
  800f72:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f75:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	89 df                	mov    %ebx,%edi
  800f8a:	51                   	push   %ecx
  800f8b:	52                   	push   %edx
  800f8c:	53                   	push   %ebx
  800f8d:	54                   	push   %esp
  800f8e:	55                   	push   %ebp
  800f8f:	56                   	push   %esi
  800f90:	57                   	push   %edi
  800f91:	54                   	push   %esp
  800f92:	5d                   	pop    %ebp
  800f93:	8d 35 9b 0f 80 00    	lea    0x800f9b,%esi
  800f99:	0f 34                	sysenter 
  800f9b:	5f                   	pop    %edi
  800f9c:	5e                   	pop    %esi
  800f9d:	5d                   	pop    %ebp
  800f9e:	5c                   	pop    %esp
  800f9f:	5b                   	pop    %ebx
  800fa0:	5a                   	pop    %edx
  800fa1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	7e 28                	jle    800fce <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800faa:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  800fb9:	00 
  800fba:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fc1:	00 
  800fc2:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  800fc9:	e8 76 0d 00 00       	call   801d44 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800fce:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fd1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd4:	89 ec                	mov    %ebp,%esp
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	89 1c 24             	mov    %ebx,(%esp)
  800fe1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fea:	b8 11 00 00 00       	mov    $0x11,%eax
  800fef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff2:	89 cb                	mov    %ecx,%ebx
  800ff4:	89 cf                	mov    %ecx,%edi
  800ff6:	51                   	push   %ecx
  800ff7:	52                   	push   %edx
  800ff8:	53                   	push   %ebx
  800ff9:	54                   	push   %esp
  800ffa:	55                   	push   %ebp
  800ffb:	56                   	push   %esi
  800ffc:	57                   	push   %edi
  800ffd:	54                   	push   %esp
  800ffe:	5d                   	pop    %ebp
  800fff:	8d 35 07 10 80 00    	lea    0x801007,%esi
  801005:	0f 34                	sysenter 
  801007:	5f                   	pop    %edi
  801008:	5e                   	pop    %esi
  801009:	5d                   	pop    %ebp
  80100a:	5c                   	pop    %esp
  80100b:	5b                   	pop    %ebx
  80100c:	5a                   	pop    %edx
  80100d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80100e:	8b 1c 24             	mov    (%esp),%ebx
  801011:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801015:	89 ec                	mov    %ebp,%esp
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	83 ec 28             	sub    $0x28,%esp
  80101f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801022:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801025:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80102f:	8b 55 08             	mov    0x8(%ebp),%edx
  801032:	89 cb                	mov    %ecx,%ebx
  801034:	89 cf                	mov    %ecx,%edi
  801036:	51                   	push   %ecx
  801037:	52                   	push   %edx
  801038:	53                   	push   %ebx
  801039:	54                   	push   %esp
  80103a:	55                   	push   %ebp
  80103b:	56                   	push   %esi
  80103c:	57                   	push   %edi
  80103d:	54                   	push   %esp
  80103e:	5d                   	pop    %ebp
  80103f:	8d 35 47 10 80 00    	lea    0x801047,%esi
  801045:	0f 34                	sysenter 
  801047:	5f                   	pop    %edi
  801048:	5e                   	pop    %esi
  801049:	5d                   	pop    %ebp
  80104a:	5c                   	pop    %esp
  80104b:	5b                   	pop    %ebx
  80104c:	5a                   	pop    %edx
  80104d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	7e 28                	jle    80107a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801052:	89 44 24 10          	mov    %eax,0x10(%esp)
  801056:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80105d:	00 
  80105e:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  801065:	00 
  801066:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80106d:	00 
  80106e:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  801075:	e8 ca 0c 00 00       	call   801d44 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80107a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80107d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801080:	89 ec                	mov    %ebp,%esp
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	89 1c 24             	mov    %ebx,(%esp)
  80108d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801091:	b8 0d 00 00 00       	mov    $0xd,%eax
  801096:	8b 7d 14             	mov    0x14(%ebp),%edi
  801099:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	8b 55 08             	mov    0x8(%ebp),%edx
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

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010ba:	8b 1c 24             	mov    (%esp),%ebx
  8010bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010c1:	89 ec                	mov    %ebp,%esp
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 28             	sub    $0x28,%esp
  8010cb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010ce:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010de:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e1:	89 df                	mov    %ebx,%edi
  8010e3:	51                   	push   %ecx
  8010e4:	52                   	push   %edx
  8010e5:	53                   	push   %ebx
  8010e6:	54                   	push   %esp
  8010e7:	55                   	push   %ebp
  8010e8:	56                   	push   %esi
  8010e9:	57                   	push   %edi
  8010ea:	54                   	push   %esp
  8010eb:	5d                   	pop    %ebp
  8010ec:	8d 35 f4 10 80 00    	lea    0x8010f4,%esi
  8010f2:	0f 34                	sysenter 
  8010f4:	5f                   	pop    %edi
  8010f5:	5e                   	pop    %esi
  8010f6:	5d                   	pop    %ebp
  8010f7:	5c                   	pop    %esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5a                   	pop    %edx
  8010fa:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	7e 28                	jle    801127 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801103:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80110a:	00 
  80110b:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  801112:	00 
  801113:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80111a:	00 
  80111b:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  801122:	e8 1d 0c 00 00       	call   801d44 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801127:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80112a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80112d:	89 ec                	mov    %ebp,%esp
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 28             	sub    $0x28,%esp
  801137:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80113a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	b8 0a 00 00 00       	mov    $0xa,%eax
  801147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114a:	8b 55 08             	mov    0x8(%ebp),%edx
  80114d:	89 df                	mov    %ebx,%edi
  80114f:	51                   	push   %ecx
  801150:	52                   	push   %edx
  801151:	53                   	push   %ebx
  801152:	54                   	push   %esp
  801153:	55                   	push   %ebp
  801154:	56                   	push   %esi
  801155:	57                   	push   %edi
  801156:	54                   	push   %esp
  801157:	5d                   	pop    %ebp
  801158:	8d 35 60 11 80 00    	lea    0x801160,%esi
  80115e:	0f 34                	sysenter 
  801160:	5f                   	pop    %edi
  801161:	5e                   	pop    %esi
  801162:	5d                   	pop    %ebp
  801163:	5c                   	pop    %esp
  801164:	5b                   	pop    %ebx
  801165:	5a                   	pop    %edx
  801166:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801167:	85 c0                	test   %eax,%eax
  801169:	7e 28                	jle    801193 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801176:	00 
  801177:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  80117e:	00 
  80117f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  80118e:	e8 b1 0b 00 00       	call   801d44 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801193:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801196:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801199:	89 ec                	mov    %ebp,%esp
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 28             	sub    $0x28,%esp
  8011a3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011a6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8011b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b9:	89 df                	mov    %ebx,%edi
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
  8011d5:	7e 28                	jle    8011ff <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011db:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011f2:	00 
  8011f3:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  8011fa:	e8 45 0b 00 00       	call   801d44 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801202:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801205:	89 ec                	mov    %ebp,%esp
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	83 ec 28             	sub    $0x28,%esp
  80120f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801212:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121a:	b8 07 00 00 00       	mov    $0x7,%eax
  80121f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801222:	8b 55 08             	mov    0x8(%ebp),%edx
  801225:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80123f:	85 c0                	test   %eax,%eax
  801241:	7e 28                	jle    80126b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801243:	89 44 24 10          	mov    %eax,0x10(%esp)
  801247:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80124e:	00 
  80124f:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  801256:	00 
  801257:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80125e:	00 
  80125f:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  801266:	e8 d9 0a 00 00       	call   801d44 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80126b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80126e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801271:	89 ec                	mov    %ebp,%esp
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	83 ec 28             	sub    $0x28,%esp
  80127b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80127e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801281:	8b 7d 18             	mov    0x18(%ebp),%edi
  801284:	0b 7d 14             	or     0x14(%ebp),%edi
  801287:	b8 06 00 00 00       	mov    $0x6,%eax
  80128c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	8b 55 08             	mov    0x8(%ebp),%edx
  801295:	51                   	push   %ecx
  801296:	52                   	push   %edx
  801297:	53                   	push   %ebx
  801298:	54                   	push   %esp
  801299:	55                   	push   %ebp
  80129a:	56                   	push   %esi
  80129b:	57                   	push   %edi
  80129c:	54                   	push   %esp
  80129d:	5d                   	pop    %ebp
  80129e:	8d 35 a6 12 80 00    	lea    0x8012a6,%esi
  8012a4:	0f 34                	sysenter 
  8012a6:	5f                   	pop    %edi
  8012a7:	5e                   	pop    %esi
  8012a8:	5d                   	pop    %ebp
  8012a9:	5c                   	pop    %esp
  8012aa:	5b                   	pop    %ebx
  8012ab:	5a                   	pop    %edx
  8012ac:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	7e 28                	jle    8012d9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  8012c4:	00 
  8012c5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012cc:	00 
  8012cd:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  8012d4:	e8 6b 0a 00 00       	call   801d44 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8012d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012df:	89 ec                	mov    %ebp,%esp
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 28             	sub    $0x28,%esp
  8012e9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012ec:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8012f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8012f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ff:	8b 55 08             	mov    0x8(%ebp),%edx
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80131a:	85 c0                	test   %eax,%eax
  80131c:	7e 28                	jle    801346 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801322:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801329:	00 
  80132a:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  801331:	00 
  801332:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801339:	00 
  80133a:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  801341:	e8 fe 09 00 00       	call   801d44 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801346:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801349:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80134c:	89 ec                	mov    %ebp,%esp
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	89 1c 24             	mov    %ebx,(%esp)
  801359:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80135d:	ba 00 00 00 00       	mov    $0x0,%edx
  801362:	b8 0c 00 00 00       	mov    $0xc,%eax
  801367:	89 d1                	mov    %edx,%ecx
  801369:	89 d3                	mov    %edx,%ebx
  80136b:	89 d7                	mov    %edx,%edi
  80136d:	51                   	push   %ecx
  80136e:	52                   	push   %edx
  80136f:	53                   	push   %ebx
  801370:	54                   	push   %esp
  801371:	55                   	push   %ebp
  801372:	56                   	push   %esi
  801373:	57                   	push   %edi
  801374:	54                   	push   %esp
  801375:	5d                   	pop    %ebp
  801376:	8d 35 7e 13 80 00    	lea    0x80137e,%esi
  80137c:	0f 34                	sysenter 
  80137e:	5f                   	pop    %edi
  80137f:	5e                   	pop    %esi
  801380:	5d                   	pop    %ebp
  801381:	5c                   	pop    %esp
  801382:	5b                   	pop    %ebx
  801383:	5a                   	pop    %edx
  801384:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801385:	8b 1c 24             	mov    (%esp),%ebx
  801388:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80138c:	89 ec                	mov    %ebp,%esp
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	89 1c 24             	mov    %ebx,(%esp)
  801399:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80139d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8013a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ad:	89 df                	mov    %ebx,%edi
  8013af:	51                   	push   %ecx
  8013b0:	52                   	push   %edx
  8013b1:	53                   	push   %ebx
  8013b2:	54                   	push   %esp
  8013b3:	55                   	push   %ebp
  8013b4:	56                   	push   %esi
  8013b5:	57                   	push   %edi
  8013b6:	54                   	push   %esp
  8013b7:	5d                   	pop    %ebp
  8013b8:	8d 35 c0 13 80 00    	lea    0x8013c0,%esi
  8013be:	0f 34                	sysenter 
  8013c0:	5f                   	pop    %edi
  8013c1:	5e                   	pop    %esi
  8013c2:	5d                   	pop    %ebp
  8013c3:	5c                   	pop    %esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5a                   	pop    %edx
  8013c6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8013c7:	8b 1c 24             	mov    (%esp),%ebx
  8013ca:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ce:	89 ec                	mov    %ebp,%esp
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	89 1c 24             	mov    %ebx,(%esp)
  8013db:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013df:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8013e9:	89 d1                	mov    %edx,%ecx
  8013eb:	89 d3                	mov    %edx,%ebx
  8013ed:	89 d7                	mov    %edx,%edi
  8013ef:	51                   	push   %ecx
  8013f0:	52                   	push   %edx
  8013f1:	53                   	push   %ebx
  8013f2:	54                   	push   %esp
  8013f3:	55                   	push   %ebp
  8013f4:	56                   	push   %esi
  8013f5:	57                   	push   %edi
  8013f6:	54                   	push   %esp
  8013f7:	5d                   	pop    %ebp
  8013f8:	8d 35 00 14 80 00    	lea    0x801400,%esi
  8013fe:	0f 34                	sysenter 
  801400:	5f                   	pop    %edi
  801401:	5e                   	pop    %esi
  801402:	5d                   	pop    %ebp
  801403:	5c                   	pop    %esp
  801404:	5b                   	pop    %ebx
  801405:	5a                   	pop    %edx
  801406:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801407:	8b 1c 24             	mov    (%esp),%ebx
  80140a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80140e:	89 ec                	mov    %ebp,%esp
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 28             	sub    $0x28,%esp
  801418:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80141b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80141e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801423:	b8 03 00 00 00       	mov    $0x3,%eax
  801428:	8b 55 08             	mov    0x8(%ebp),%edx
  80142b:	89 cb                	mov    %ecx,%ebx
  80142d:	89 cf                	mov    %ecx,%edi
  80142f:	51                   	push   %ecx
  801430:	52                   	push   %edx
  801431:	53                   	push   %ebx
  801432:	54                   	push   %esp
  801433:	55                   	push   %ebp
  801434:	56                   	push   %esi
  801435:	57                   	push   %edi
  801436:	54                   	push   %esp
  801437:	5d                   	pop    %ebp
  801438:	8d 35 40 14 80 00    	lea    0x801440,%esi
  80143e:	0f 34                	sysenter 
  801440:	5f                   	pop    %edi
  801441:	5e                   	pop    %esi
  801442:	5d                   	pop    %ebp
  801443:	5c                   	pop    %esp
  801444:	5b                   	pop    %ebx
  801445:	5a                   	pop    %edx
  801446:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801447:	85 c0                	test   %eax,%eax
  801449:	7e 28                	jle    801473 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80144b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80144f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801456:	00 
  801457:	c7 44 24 08 20 25 80 	movl   $0x802520,0x8(%esp)
  80145e:	00 
  80145f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801466:	00 
  801467:	c7 04 24 3d 25 80 00 	movl   $0x80253d,(%esp)
  80146e:	e8 d1 08 00 00       	call   801d44 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801473:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801476:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801479:	89 ec                	mov    %ebp,%esp
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    
  80147d:	00 00                	add    %al,(%eax)
	...

00801480 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	05 00 00 00 30       	add    $0x30000000,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801496:	8b 45 08             	mov    0x8(%ebp),%eax
  801499:	89 04 24             	mov    %eax,(%esp)
  80149c:	e8 df ff ff ff       	call   801480 <fd2num>
  8014a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	57                   	push   %edi
  8014af:	56                   	push   %esi
  8014b0:	53                   	push   %ebx
  8014b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8014b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014b9:	a8 01                	test   $0x1,%al
  8014bb:	74 36                	je     8014f3 <fd_alloc+0x48>
  8014bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014c2:	a8 01                	test   $0x1,%al
  8014c4:	74 2d                	je     8014f3 <fd_alloc+0x48>
  8014c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8014cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8014d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8014d5:	89 c3                	mov    %eax,%ebx
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	c1 ea 16             	shr    $0x16,%edx
  8014dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8014df:	f6 c2 01             	test   $0x1,%dl
  8014e2:	74 14                	je     8014f8 <fd_alloc+0x4d>
  8014e4:	89 c2                	mov    %eax,%edx
  8014e6:	c1 ea 0c             	shr    $0xc,%edx
  8014e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8014ec:	f6 c2 01             	test   $0x1,%dl
  8014ef:	75 10                	jne    801501 <fd_alloc+0x56>
  8014f1:	eb 05                	jmp    8014f8 <fd_alloc+0x4d>
  8014f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8014f8:	89 1f                	mov    %ebx,(%edi)
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8014ff:	eb 17                	jmp    801518 <fd_alloc+0x6d>
  801501:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801506:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80150b:	75 c8                	jne    8014d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80150d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801513:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801518:	5b                   	pop    %ebx
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
  801523:	83 f8 1f             	cmp    $0x1f,%eax
  801526:	77 36                	ja     80155e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801528:	05 00 00 0d 00       	add    $0xd0000,%eax
  80152d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801530:	89 c2                	mov    %eax,%edx
  801532:	c1 ea 16             	shr    $0x16,%edx
  801535:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80153c:	f6 c2 01             	test   $0x1,%dl
  80153f:	74 1d                	je     80155e <fd_lookup+0x41>
  801541:	89 c2                	mov    %eax,%edx
  801543:	c1 ea 0c             	shr    $0xc,%edx
  801546:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154d:	f6 c2 01             	test   $0x1,%dl
  801550:	74 0c                	je     80155e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801552:	8b 55 0c             	mov    0xc(%ebp),%edx
  801555:	89 02                	mov    %eax,(%edx)
  801557:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80155c:	eb 05                	jmp    801563 <fd_lookup+0x46>
  80155e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80156e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801572:	8b 45 08             	mov    0x8(%ebp),%eax
  801575:	89 04 24             	mov    %eax,(%esp)
  801578:	e8 a0 ff ff ff       	call   80151d <fd_lookup>
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 0e                	js     80158f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801581:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801584:	8b 55 0c             	mov    0xc(%ebp),%edx
  801587:	89 50 04             	mov    %edx,0x4(%eax)
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 10             	sub    $0x10,%esp
  801599:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80159c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80159f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8015a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015a9:	be c8 25 80 00       	mov    $0x8025c8,%esi
		if (devtab[i]->dev_id == dev_id) {
  8015ae:	39 08                	cmp    %ecx,(%eax)
  8015b0:	75 10                	jne    8015c2 <dev_lookup+0x31>
  8015b2:	eb 04                	jmp    8015b8 <dev_lookup+0x27>
  8015b4:	39 08                	cmp    %ecx,(%eax)
  8015b6:	75 0a                	jne    8015c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8015b8:	89 03                	mov    %eax,(%ebx)
  8015ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015bf:	90                   	nop
  8015c0:	eb 31                	jmp    8015f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015c2:	83 c2 01             	add    $0x1,%edx
  8015c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	75 e8                	jne    8015b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d1:	8b 40 48             	mov    0x48(%eax),%eax
  8015d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015dc:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  8015e3:	e8 a5 eb ff ff       	call   80018d <cprintf>
	*dev = 0;
  8015e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	5b                   	pop    %ebx
  8015f7:	5e                   	pop    %esi
  8015f8:	5d                   	pop    %ebp
  8015f9:	c3                   	ret    

008015fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 24             	sub    $0x24,%esp
  801601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801604:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160b:	8b 45 08             	mov    0x8(%ebp),%eax
  80160e:	89 04 24             	mov    %eax,(%esp)
  801611:	e8 07 ff ff ff       	call   80151d <fd_lookup>
  801616:	85 c0                	test   %eax,%eax
  801618:	78 53                	js     80166d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801624:	8b 00                	mov    (%eax),%eax
  801626:	89 04 24             	mov    %eax,(%esp)
  801629:	e8 63 ff ff ff       	call   801591 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 3b                	js     80166d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801632:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801637:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80163e:	74 2d                	je     80166d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801640:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801643:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80164a:	00 00 00 
	stat->st_isdir = 0;
  80164d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801654:	00 00 00 
	stat->st_dev = dev;
  801657:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801664:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801667:	89 14 24             	mov    %edx,(%esp)
  80166a:	ff 50 14             	call   *0x14(%eax)
}
  80166d:	83 c4 24             	add    $0x24,%esp
  801670:	5b                   	pop    %ebx
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	53                   	push   %ebx
  801677:	83 ec 24             	sub    $0x24,%esp
  80167a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801680:	89 44 24 04          	mov    %eax,0x4(%esp)
  801684:	89 1c 24             	mov    %ebx,(%esp)
  801687:	e8 91 fe ff ff       	call   80151d <fd_lookup>
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 5f                	js     8016ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801693:	89 44 24 04          	mov    %eax,0x4(%esp)
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	8b 00                	mov    (%eax),%eax
  80169c:	89 04 24             	mov    %eax,(%esp)
  80169f:	e8 ed fe ff ff       	call   801591 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 47                	js     8016ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8016af:	75 23                	jne    8016d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016b1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016b6:	8b 40 48             	mov    0x48(%eax),%eax
  8016b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c1:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  8016c8:	e8 c0 ea ff ff       	call   80018d <cprintf>
  8016cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d2:	eb 1b                	jmp    8016ef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8016d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d7:	8b 48 18             	mov    0x18(%eax),%ecx
  8016da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016df:	85 c9                	test   %ecx,%ecx
  8016e1:	74 0c                	je     8016ef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ea:	89 14 24             	mov    %edx,(%esp)
  8016ed:	ff d1                	call   *%ecx
}
  8016ef:	83 c4 24             	add    $0x24,%esp
  8016f2:	5b                   	pop    %ebx
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	53                   	push   %ebx
  8016f9:	83 ec 24             	sub    $0x24,%esp
  8016fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801702:	89 44 24 04          	mov    %eax,0x4(%esp)
  801706:	89 1c 24             	mov    %ebx,(%esp)
  801709:	e8 0f fe ff ff       	call   80151d <fd_lookup>
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 66                	js     801778 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801712:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801715:	89 44 24 04          	mov    %eax,0x4(%esp)
  801719:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171c:	8b 00                	mov    (%eax),%eax
  80171e:	89 04 24             	mov    %eax,(%esp)
  801721:	e8 6b fe ff ff       	call   801591 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801726:	85 c0                	test   %eax,%eax
  801728:	78 4e                	js     801778 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80172a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80172d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801731:	75 23                	jne    801756 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801733:	a1 04 40 80 00       	mov    0x804004,%eax
  801738:	8b 40 48             	mov    0x48(%eax),%eax
  80173b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80173f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801743:	c7 04 24 8d 25 80 00 	movl   $0x80258d,(%esp)
  80174a:	e8 3e ea ff ff       	call   80018d <cprintf>
  80174f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801754:	eb 22                	jmp    801778 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801759:	8b 48 0c             	mov    0xc(%eax),%ecx
  80175c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801761:	85 c9                	test   %ecx,%ecx
  801763:	74 13                	je     801778 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801765:	8b 45 10             	mov    0x10(%ebp),%eax
  801768:	89 44 24 08          	mov    %eax,0x8(%esp)
  80176c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801773:	89 14 24             	mov    %edx,(%esp)
  801776:	ff d1                	call   *%ecx
}
  801778:	83 c4 24             	add    $0x24,%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    

0080177e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	53                   	push   %ebx
  801782:	83 ec 24             	sub    $0x24,%esp
  801785:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801788:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178f:	89 1c 24             	mov    %ebx,(%esp)
  801792:	e8 86 fd ff ff       	call   80151d <fd_lookup>
  801797:	85 c0                	test   %eax,%eax
  801799:	78 6b                	js     801806 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a5:	8b 00                	mov    (%eax),%eax
  8017a7:	89 04 24             	mov    %eax,(%esp)
  8017aa:	e8 e2 fd ff ff       	call   801591 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 53                	js     801806 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017b6:	8b 42 08             	mov    0x8(%edx),%eax
  8017b9:	83 e0 03             	and    $0x3,%eax
  8017bc:	83 f8 01             	cmp    $0x1,%eax
  8017bf:	75 23                	jne    8017e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c6:	8b 40 48             	mov    0x48(%eax),%eax
  8017c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d1:	c7 04 24 aa 25 80 00 	movl   $0x8025aa,(%esp)
  8017d8:	e8 b0 e9 ff ff       	call   80018d <cprintf>
  8017dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8017e2:	eb 22                	jmp    801806 <read+0x88>
	}
	if (!dev->dev_read)
  8017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e7:	8b 48 08             	mov    0x8(%eax),%ecx
  8017ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ef:	85 c9                	test   %ecx,%ecx
  8017f1:	74 13                	je     801806 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	89 14 24             	mov    %edx,(%esp)
  801804:	ff d1                	call   *%ecx
}
  801806:	83 c4 24             	add    $0x24,%esp
  801809:	5b                   	pop    %ebx
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	57                   	push   %edi
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	83 ec 1c             	sub    $0x1c,%esp
  801815:	8b 7d 08             	mov    0x8(%ebp),%edi
  801818:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80181b:	ba 00 00 00 00       	mov    $0x0,%edx
  801820:	bb 00 00 00 00       	mov    $0x0,%ebx
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
  80182a:	85 f6                	test   %esi,%esi
  80182c:	74 29                	je     801857 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80182e:	89 f0                	mov    %esi,%eax
  801830:	29 d0                	sub    %edx,%eax
  801832:	89 44 24 08          	mov    %eax,0x8(%esp)
  801836:	03 55 0c             	add    0xc(%ebp),%edx
  801839:	89 54 24 04          	mov    %edx,0x4(%esp)
  80183d:	89 3c 24             	mov    %edi,(%esp)
  801840:	e8 39 ff ff ff       	call   80177e <read>
		if (m < 0)
  801845:	85 c0                	test   %eax,%eax
  801847:	78 0e                	js     801857 <readn+0x4b>
			return m;
		if (m == 0)
  801849:	85 c0                	test   %eax,%eax
  80184b:	74 08                	je     801855 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80184d:	01 c3                	add    %eax,%ebx
  80184f:	89 da                	mov    %ebx,%edx
  801851:	39 f3                	cmp    %esi,%ebx
  801853:	72 d9                	jb     80182e <readn+0x22>
  801855:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801857:	83 c4 1c             	add    $0x1c,%esp
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5f                   	pop    %edi
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	83 ec 20             	sub    $0x20,%esp
  801867:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80186a:	89 34 24             	mov    %esi,(%esp)
  80186d:	e8 0e fc ff ff       	call   801480 <fd2num>
  801872:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801875:	89 54 24 04          	mov    %edx,0x4(%esp)
  801879:	89 04 24             	mov    %eax,(%esp)
  80187c:	e8 9c fc ff ff       	call   80151d <fd_lookup>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	85 c0                	test   %eax,%eax
  801885:	78 05                	js     80188c <fd_close+0x2d>
  801887:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80188a:	74 0c                	je     801898 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80188c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801890:	19 c0                	sbb    %eax,%eax
  801892:	f7 d0                	not    %eax
  801894:	21 c3                	and    %eax,%ebx
  801896:	eb 3d                	jmp    8018d5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801898:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189f:	8b 06                	mov    (%esi),%eax
  8018a1:	89 04 24             	mov    %eax,(%esp)
  8018a4:	e8 e8 fc ff ff       	call   801591 <dev_lookup>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 16                	js     8018c5 <fd_close+0x66>
		if (dev->dev_close)
  8018af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b2:	8b 40 10             	mov    0x10(%eax),%eax
  8018b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	74 07                	je     8018c5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  8018be:	89 34 24             	mov    %esi,(%esp)
  8018c1:	ff d0                	call   *%eax
  8018c3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d0:	e8 34 f9 ff ff       	call   801209 <sys_page_unmap>
	return r;
}
  8018d5:	89 d8                	mov    %ebx,%eax
  8018d7:	83 c4 20             	add    $0x20,%esp
  8018da:	5b                   	pop    %ebx
  8018db:	5e                   	pop    %esi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	e8 27 fc ff ff       	call   80151d <fd_lookup>
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 13                	js     80190d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8018fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801901:	00 
  801902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801905:	89 04 24             	mov    %eax,(%esp)
  801908:	e8 52 ff ff ff       	call   80185f <fd_close>
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 18             	sub    $0x18,%esp
  801915:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801918:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80191b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801922:	00 
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	89 04 24             	mov    %eax,(%esp)
  801929:	e8 79 03 00 00       	call   801ca7 <open>
  80192e:	89 c3                	mov    %eax,%ebx
  801930:	85 c0                	test   %eax,%eax
  801932:	78 1b                	js     80194f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801934:	8b 45 0c             	mov    0xc(%ebp),%eax
  801937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193b:	89 1c 24             	mov    %ebx,(%esp)
  80193e:	e8 b7 fc ff ff       	call   8015fa <fstat>
  801943:	89 c6                	mov    %eax,%esi
	close(fd);
  801945:	89 1c 24             	mov    %ebx,(%esp)
  801948:	e8 91 ff ff ff       	call   8018de <close>
  80194d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80194f:	89 d8                	mov    %ebx,%eax
  801951:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801954:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801957:	89 ec                	mov    %ebp,%esp
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	53                   	push   %ebx
  80195f:	83 ec 14             	sub    $0x14,%esp
  801962:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801967:	89 1c 24             	mov    %ebx,(%esp)
  80196a:	e8 6f ff ff ff       	call   8018de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80196f:	83 c3 01             	add    $0x1,%ebx
  801972:	83 fb 20             	cmp    $0x20,%ebx
  801975:	75 f0                	jne    801967 <close_all+0xc>
		close(i);
}
  801977:	83 c4 14             	add    $0x14,%esp
  80197a:	5b                   	pop    %ebx
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	83 ec 58             	sub    $0x58,%esp
  801983:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801986:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801989:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80198c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80198f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801992:	89 44 24 04          	mov    %eax,0x4(%esp)
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
  801999:	89 04 24             	mov    %eax,(%esp)
  80199c:	e8 7c fb ff ff       	call   80151d <fd_lookup>
  8019a1:	89 c3                	mov    %eax,%ebx
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	0f 88 e0 00 00 00    	js     801a8b <dup+0x10e>
		return r;
	close(newfdnum);
  8019ab:	89 3c 24             	mov    %edi,(%esp)
  8019ae:	e8 2b ff ff ff       	call   8018de <close>

	newfd = INDEX2FD(newfdnum);
  8019b3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8019b9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8019bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019bf:	89 04 24             	mov    %eax,(%esp)
  8019c2:	e8 c9 fa ff ff       	call   801490 <fd2data>
  8019c7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8019c9:	89 34 24             	mov    %esi,(%esp)
  8019cc:	e8 bf fa ff ff       	call   801490 <fd2data>
  8019d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8019d4:	89 da                	mov    %ebx,%edx
  8019d6:	89 d8                	mov    %ebx,%eax
  8019d8:	c1 e8 16             	shr    $0x16,%eax
  8019db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019e2:	a8 01                	test   $0x1,%al
  8019e4:	74 43                	je     801a29 <dup+0xac>
  8019e6:	c1 ea 0c             	shr    $0xc,%edx
  8019e9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019f0:	a8 01                	test   $0x1,%al
  8019f2:	74 35                	je     801a29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019f4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801a00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a12:	00 
  801a13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a1e:	e8 52 f8 ff ff       	call   801275 <sys_page_map>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 3f                	js     801a68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a2c:	89 c2                	mov    %eax,%edx
  801a2e:	c1 ea 0c             	shr    $0xc,%edx
  801a31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a4d:	00 
  801a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a59:	e8 17 f8 ff ff       	call   801275 <sys_page_map>
  801a5e:	89 c3                	mov    %eax,%ebx
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 04                	js     801a68 <dup+0xeb>
  801a64:	89 fb                	mov    %edi,%ebx
  801a66:	eb 23                	jmp    801a8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a73:	e8 91 f7 ff ff       	call   801209 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a86:	e8 7e f7 ff ff       	call   801209 <sys_page_unmap>
	return r;
}
  801a8b:	89 d8                	mov    %ebx,%eax
  801a8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a96:	89 ec                	mov    %ebp,%esp
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    
	...

00801a9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 18             	sub    $0x18,%esp
  801aa2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801aa5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801aa8:	89 c3                	mov    %eax,%ebx
  801aaa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801aac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ab3:	75 11                	jne    801ac6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ab5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801abc:	e8 df 02 00 00       	call   801da0 <ipc_find_env>
  801ac1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ac6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801acd:	00 
  801ace:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ad5:	00 
  801ad6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ada:	a1 00 40 80 00       	mov    0x804000,%eax
  801adf:	89 04 24             	mov    %eax,(%esp)
  801ae2:	e8 04 03 00 00       	call   801deb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ae7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aee:	00 
  801aef:	89 74 24 04          	mov    %esi,0x4(%esp)
  801af3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afa:	e8 6a 03 00 00       	call   801e69 <ipc_recv>
}
  801aff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b05:	89 ec                	mov    %ebp,%esp
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	8b 40 0c             	mov    0xc(%eax),%eax
  801b15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b22:	ba 00 00 00 00       	mov    $0x0,%edx
  801b27:	b8 02 00 00 00       	mov    $0x2,%eax
  801b2c:	e8 6b ff ff ff       	call   801a9c <fsipc>
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b44:	ba 00 00 00 00       	mov    $0x0,%edx
  801b49:	b8 06 00 00 00       	mov    $0x6,%eax
  801b4e:	e8 49 ff ff ff       	call   801a9c <fsipc>
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b60:	b8 08 00 00 00       	mov    $0x8,%eax
  801b65:	e8 32 ff ff ff       	call   801a9c <fsipc>
}
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	53                   	push   %ebx
  801b70:	83 ec 14             	sub    $0x14,%esp
  801b73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b76:	8b 45 08             	mov    0x8(%ebp),%eax
  801b79:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b81:	ba 00 00 00 00       	mov    $0x0,%edx
  801b86:	b8 05 00 00 00       	mov    $0x5,%eax
  801b8b:	e8 0c ff ff ff       	call   801a9c <fsipc>
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 2b                	js     801bbf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b94:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b9b:	00 
  801b9c:	89 1c 24             	mov    %ebx,(%esp)
  801b9f:	e8 16 ef ff ff       	call   800aba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ba4:	a1 80 50 80 00       	mov    0x805080,%eax
  801ba9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801baf:	a1 84 50 80 00       	mov    0x805084,%eax
  801bb4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801bba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801bbf:	83 c4 14             	add    $0x14,%esp
  801bc2:	5b                   	pop    %ebx
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    

00801bc5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	83 ec 18             	sub    $0x18,%esp
  801bcb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bd3:	76 05                	jbe    801bda <devfile_write+0x15>
  801bd5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bda:	8b 55 08             	mov    0x8(%ebp),%edx
  801bdd:	8b 52 0c             	mov    0xc(%edx),%edx
  801be0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801be6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801beb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801bfd:	e8 a3 f0 ff ff       	call   800ca5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801c02:	ba 00 00 00 00       	mov    $0x0,%edx
  801c07:	b8 04 00 00 00       	mov    $0x4,%eax
  801c0c:	e8 8b fe ff ff       	call   801a9c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	53                   	push   %ebx
  801c17:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c20:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801c25:	8b 45 10             	mov    0x10(%ebp),%eax
  801c28:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c32:	b8 03 00 00 00       	mov    $0x3,%eax
  801c37:	e8 60 fe ff ff       	call   801a9c <fsipc>
  801c3c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 17                	js     801c59 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801c42:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c46:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c4d:	00 
  801c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c51:	89 04 24             	mov    %eax,(%esp)
  801c54:	e8 4c f0 ff ff       	call   800ca5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801c59:	89 d8                	mov    %ebx,%eax
  801c5b:	83 c4 14             	add    $0x14,%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	53                   	push   %ebx
  801c65:	83 ec 14             	sub    $0x14,%esp
  801c68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c6b:	89 1c 24             	mov    %ebx,(%esp)
  801c6e:	e8 fd ed ff ff       	call   800a70 <strlen>
  801c73:	89 c2                	mov    %eax,%edx
  801c75:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801c7a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801c80:	7f 1f                	jg     801ca1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801c82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c86:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c8d:	e8 28 ee ff ff       	call   800aba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801c92:	ba 00 00 00 00       	mov    $0x0,%edx
  801c97:	b8 07 00 00 00       	mov    $0x7,%eax
  801c9c:	e8 fb fd ff ff       	call   801a9c <fsipc>
}
  801ca1:	83 c4 14             	add    $0x14,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 28             	sub    $0x28,%esp
  801cad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cb0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cb3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801cb6:	89 34 24             	mov    %esi,(%esp)
  801cb9:	e8 b2 ed ff ff       	call   800a70 <strlen>
  801cbe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801cc3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cc8:	7f 6d                	jg     801d37 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801cca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccd:	89 04 24             	mov    %eax,(%esp)
  801cd0:	e8 d6 f7 ff ff       	call   8014ab <fd_alloc>
  801cd5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	78 5c                	js     801d37 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cde:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801ce3:	89 34 24             	mov    %esi,(%esp)
  801ce6:	e8 85 ed ff ff       	call   800a70 <strlen>
  801ceb:	83 c0 01             	add    $0x1,%eax
  801cee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cf6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cfd:	e8 a3 ef ff ff       	call   800ca5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801d02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d05:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0a:	e8 8d fd ff ff       	call   801a9c <fsipc>
  801d0f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801d11:	85 c0                	test   %eax,%eax
  801d13:	79 15                	jns    801d2a <open+0x83>
             fd_close(fd,0);
  801d15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d1c:	00 
  801d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d20:	89 04 24             	mov    %eax,(%esp)
  801d23:	e8 37 fb ff ff       	call   80185f <fd_close>
             return r;
  801d28:	eb 0d                	jmp    801d37 <open+0x90>
        }
        return fd2num(fd);
  801d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2d:	89 04 24             	mov    %eax,(%esp)
  801d30:	e8 4b f7 ff ff       	call   801480 <fd2num>
  801d35:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801d37:	89 d8                	mov    %ebx,%eax
  801d39:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d3c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d3f:	89 ec                	mov    %ebp,%esp
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    
	...

00801d44 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	56                   	push   %esi
  801d48:	53                   	push   %ebx
  801d49:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801d4c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d4f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d55:	e8 78 f6 ff ff       	call   8013d2 <sys_getenvid>
  801d5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d61:	8b 55 08             	mov    0x8(%ebp),%edx
  801d64:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d70:	c7 04 24 d0 25 80 00 	movl   $0x8025d0,(%esp)
  801d77:	e8 11 e4 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d80:	8b 45 10             	mov    0x10(%ebp),%eax
  801d83:	89 04 24             	mov    %eax,(%esp)
  801d86:	e8 a1 e3 ff ff       	call   80012c <vcprintf>
	cprintf("\n");
  801d8b:	c7 04 24 8d 21 80 00 	movl   $0x80218d,(%esp)
  801d92:	e8 f6 e3 ff ff       	call   80018d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d97:	cc                   	int3   
  801d98:	eb fd                	jmp    801d97 <_panic+0x53>
  801d9a:	00 00                	add    %al,(%eax)
  801d9c:	00 00                	add    %al,(%eax)
	...

00801da0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801da6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801dac:	b8 01 00 00 00       	mov    $0x1,%eax
  801db1:	39 ca                	cmp    %ecx,%edx
  801db3:	75 04                	jne    801db9 <ipc_find_env+0x19>
  801db5:	b0 00                	mov    $0x0,%al
  801db7:	eb 12                	jmp    801dcb <ipc_find_env+0x2b>
  801db9:	89 c2                	mov    %eax,%edx
  801dbb:	c1 e2 07             	shl    $0x7,%edx
  801dbe:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801dc5:	8b 12                	mov    (%edx),%edx
  801dc7:	39 ca                	cmp    %ecx,%edx
  801dc9:	75 10                	jne    801ddb <ipc_find_env+0x3b>
			return envs[i].env_id;
  801dcb:	89 c2                	mov    %eax,%edx
  801dcd:	c1 e2 07             	shl    $0x7,%edx
  801dd0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801dd7:	8b 00                	mov    (%eax),%eax
  801dd9:	eb 0e                	jmp    801de9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ddb:	83 c0 01             	add    $0x1,%eax
  801dde:	3d 00 04 00 00       	cmp    $0x400,%eax
  801de3:	75 d4                	jne    801db9 <ipc_find_env+0x19>
  801de5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	57                   	push   %edi
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	83 ec 1c             	sub    $0x1c,%esp
  801df4:	8b 75 08             	mov    0x8(%ebp),%esi
  801df7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801dfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801dfd:	85 db                	test   %ebx,%ebx
  801dff:	74 19                	je     801e1a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801e01:	8b 45 14             	mov    0x14(%ebp),%eax
  801e04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e10:	89 34 24             	mov    %esi,(%esp)
  801e13:	e8 6c f2 ff ff       	call   801084 <sys_ipc_try_send>
  801e18:	eb 1b                	jmp    801e35 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801e1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e21:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801e28:	ee 
  801e29:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e2d:	89 34 24             	mov    %esi,(%esp)
  801e30:	e8 4f f2 ff ff       	call   801084 <sys_ipc_try_send>
           if(ret == 0)
  801e35:	85 c0                	test   %eax,%eax
  801e37:	74 28                	je     801e61 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801e39:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e3c:	74 1c                	je     801e5a <ipc_send+0x6f>
              panic("ipc send error");
  801e3e:	c7 44 24 08 f4 25 80 	movl   $0x8025f4,0x8(%esp)
  801e45:	00 
  801e46:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801e4d:	00 
  801e4e:	c7 04 24 03 26 80 00 	movl   $0x802603,(%esp)
  801e55:	e8 ea fe ff ff       	call   801d44 <_panic>
           sys_yield();
  801e5a:	e8 f1 f4 ff ff       	call   801350 <sys_yield>
        }
  801e5f:	eb 9c                	jmp    801dfd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801e61:	83 c4 1c             	add    $0x1c,%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5e                   	pop    %esi
  801e66:	5f                   	pop    %edi
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    

00801e69 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
  801e6e:	83 ec 10             	sub    $0x10,%esp
  801e71:	8b 75 08             	mov    0x8(%ebp),%esi
  801e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	75 0e                	jne    801e8c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e7e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e85:	e8 8f f1 ff ff       	call   801019 <sys_ipc_recv>
  801e8a:	eb 08                	jmp    801e94 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e8c:	89 04 24             	mov    %eax,(%esp)
  801e8f:	e8 85 f1 ff ff       	call   801019 <sys_ipc_recv>
        if(ret == 0){
  801e94:	85 c0                	test   %eax,%eax
  801e96:	75 26                	jne    801ebe <ipc_recv+0x55>
           if(from_env_store)
  801e98:	85 f6                	test   %esi,%esi
  801e9a:	74 0a                	je     801ea6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e9c:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea1:	8b 40 78             	mov    0x78(%eax),%eax
  801ea4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801ea6:	85 db                	test   %ebx,%ebx
  801ea8:	74 0a                	je     801eb4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801eaa:	a1 04 40 80 00       	mov    0x804004,%eax
  801eaf:	8b 40 7c             	mov    0x7c(%eax),%eax
  801eb2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801eb4:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb9:	8b 40 74             	mov    0x74(%eax),%eax
  801ebc:	eb 14                	jmp    801ed2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801ebe:	85 f6                	test   %esi,%esi
  801ec0:	74 06                	je     801ec8 <ipc_recv+0x5f>
              *from_env_store = 0;
  801ec2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801ec8:	85 db                	test   %ebx,%ebx
  801eca:	74 06                	je     801ed2 <ipc_recv+0x69>
              *perm_store = 0;
  801ecc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    
  801ed9:	00 00                	add    %al,(%eax)
  801edb:	00 00                	add    %al,(%eax)
  801edd:	00 00                	add    %al,(%eax)
	...

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	57                   	push   %edi
  801ee4:	56                   	push   %esi
  801ee5:	83 ec 10             	sub    $0x10,%esp
  801ee8:	8b 45 14             	mov    0x14(%ebp),%eax
  801eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  801eee:	8b 75 10             	mov    0x10(%ebp),%esi
  801ef1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801ef9:	75 35                	jne    801f30 <__udivdi3+0x50>
  801efb:	39 fe                	cmp    %edi,%esi
  801efd:	77 61                	ja     801f60 <__udivdi3+0x80>
  801eff:	85 f6                	test   %esi,%esi
  801f01:	75 0b                	jne    801f0e <__udivdi3+0x2e>
  801f03:	b8 01 00 00 00       	mov    $0x1,%eax
  801f08:	31 d2                	xor    %edx,%edx
  801f0a:	f7 f6                	div    %esi
  801f0c:	89 c6                	mov    %eax,%esi
  801f0e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801f11:	31 d2                	xor    %edx,%edx
  801f13:	89 f8                	mov    %edi,%eax
  801f15:	f7 f6                	div    %esi
  801f17:	89 c7                	mov    %eax,%edi
  801f19:	89 c8                	mov    %ecx,%eax
  801f1b:	f7 f6                	div    %esi
  801f1d:	89 c1                	mov    %eax,%ecx
  801f1f:	89 fa                	mov    %edi,%edx
  801f21:	89 c8                	mov    %ecx,%eax
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	5e                   	pop    %esi
  801f27:	5f                   	pop    %edi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    
  801f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f30:	39 f8                	cmp    %edi,%eax
  801f32:	77 1c                	ja     801f50 <__udivdi3+0x70>
  801f34:	0f bd d0             	bsr    %eax,%edx
  801f37:	83 f2 1f             	xor    $0x1f,%edx
  801f3a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f3d:	75 39                	jne    801f78 <__udivdi3+0x98>
  801f3f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f42:	0f 86 a0 00 00 00    	jbe    801fe8 <__udivdi3+0x108>
  801f48:	39 f8                	cmp    %edi,%eax
  801f4a:	0f 82 98 00 00 00    	jb     801fe8 <__udivdi3+0x108>
  801f50:	31 ff                	xor    %edi,%edi
  801f52:	31 c9                	xor    %ecx,%ecx
  801f54:	89 c8                	mov    %ecx,%eax
  801f56:	89 fa                	mov    %edi,%edx
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	5e                   	pop    %esi
  801f5c:	5f                   	pop    %edi
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    
  801f5f:	90                   	nop
  801f60:	89 d1                	mov    %edx,%ecx
  801f62:	89 fa                	mov    %edi,%edx
  801f64:	89 c8                	mov    %ecx,%eax
  801f66:	31 ff                	xor    %edi,%edi
  801f68:	f7 f6                	div    %esi
  801f6a:	89 c1                	mov    %eax,%ecx
  801f6c:	89 fa                	mov    %edi,%edx
  801f6e:	89 c8                	mov    %ecx,%eax
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	5e                   	pop    %esi
  801f74:	5f                   	pop    %edi
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    
  801f77:	90                   	nop
  801f78:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f7c:	89 f2                	mov    %esi,%edx
  801f7e:	d3 e0                	shl    %cl,%eax
  801f80:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f83:	b8 20 00 00 00       	mov    $0x20,%eax
  801f88:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f8b:	89 c1                	mov    %eax,%ecx
  801f8d:	d3 ea                	shr    %cl,%edx
  801f8f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f93:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f96:	d3 e6                	shl    %cl,%esi
  801f98:	89 c1                	mov    %eax,%ecx
  801f9a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f9d:	89 fe                	mov    %edi,%esi
  801f9f:	d3 ee                	shr    %cl,%esi
  801fa1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fa5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fa8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fab:	d3 e7                	shl    %cl,%edi
  801fad:	89 c1                	mov    %eax,%ecx
  801faf:	d3 ea                	shr    %cl,%edx
  801fb1:	09 d7                	or     %edx,%edi
  801fb3:	89 f2                	mov    %esi,%edx
  801fb5:	89 f8                	mov    %edi,%eax
  801fb7:	f7 75 ec             	divl   -0x14(%ebp)
  801fba:	89 d6                	mov    %edx,%esi
  801fbc:	89 c7                	mov    %eax,%edi
  801fbe:	f7 65 e8             	mull   -0x18(%ebp)
  801fc1:	39 d6                	cmp    %edx,%esi
  801fc3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fc6:	72 30                	jb     801ff8 <__udivdi3+0x118>
  801fc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fcb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fcf:	d3 e2                	shl    %cl,%edx
  801fd1:	39 c2                	cmp    %eax,%edx
  801fd3:	73 05                	jae    801fda <__udivdi3+0xfa>
  801fd5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801fd8:	74 1e                	je     801ff8 <__udivdi3+0x118>
  801fda:	89 f9                	mov    %edi,%ecx
  801fdc:	31 ff                	xor    %edi,%edi
  801fde:	e9 71 ff ff ff       	jmp    801f54 <__udivdi3+0x74>
  801fe3:	90                   	nop
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	31 ff                	xor    %edi,%edi
  801fea:	b9 01 00 00 00       	mov    $0x1,%ecx
  801fef:	e9 60 ff ff ff       	jmp    801f54 <__udivdi3+0x74>
  801ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801ffb:	31 ff                	xor    %edi,%edi
  801ffd:	89 c8                	mov    %ecx,%eax
  801fff:	89 fa                	mov    %edi,%edx
  802001:	83 c4 10             	add    $0x10,%esp
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
	...

00802010 <__umoddi3>:
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	57                   	push   %edi
  802014:	56                   	push   %esi
  802015:	83 ec 20             	sub    $0x20,%esp
  802018:	8b 55 14             	mov    0x14(%ebp),%edx
  80201b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80201e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802021:	8b 75 0c             	mov    0xc(%ebp),%esi
  802024:	85 d2                	test   %edx,%edx
  802026:	89 c8                	mov    %ecx,%eax
  802028:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80202b:	75 13                	jne    802040 <__umoddi3+0x30>
  80202d:	39 f7                	cmp    %esi,%edi
  80202f:	76 3f                	jbe    802070 <__umoddi3+0x60>
  802031:	89 f2                	mov    %esi,%edx
  802033:	f7 f7                	div    %edi
  802035:	89 d0                	mov    %edx,%eax
  802037:	31 d2                	xor    %edx,%edx
  802039:	83 c4 20             	add    $0x20,%esp
  80203c:	5e                   	pop    %esi
  80203d:	5f                   	pop    %edi
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    
  802040:	39 f2                	cmp    %esi,%edx
  802042:	77 4c                	ja     802090 <__umoddi3+0x80>
  802044:	0f bd ca             	bsr    %edx,%ecx
  802047:	83 f1 1f             	xor    $0x1f,%ecx
  80204a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80204d:	75 51                	jne    8020a0 <__umoddi3+0x90>
  80204f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802052:	0f 87 e0 00 00 00    	ja     802138 <__umoddi3+0x128>
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	29 f8                	sub    %edi,%eax
  80205d:	19 d6                	sbb    %edx,%esi
  80205f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802062:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802065:	89 f2                	mov    %esi,%edx
  802067:	83 c4 20             	add    $0x20,%esp
  80206a:	5e                   	pop    %esi
  80206b:	5f                   	pop    %edi
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    
  80206e:	66 90                	xchg   %ax,%ax
  802070:	85 ff                	test   %edi,%edi
  802072:	75 0b                	jne    80207f <__umoddi3+0x6f>
  802074:	b8 01 00 00 00       	mov    $0x1,%eax
  802079:	31 d2                	xor    %edx,%edx
  80207b:	f7 f7                	div    %edi
  80207d:	89 c7                	mov    %eax,%edi
  80207f:	89 f0                	mov    %esi,%eax
  802081:	31 d2                	xor    %edx,%edx
  802083:	f7 f7                	div    %edi
  802085:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802088:	f7 f7                	div    %edi
  80208a:	eb a9                	jmp    802035 <__umoddi3+0x25>
  80208c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	83 c4 20             	add    $0x20,%esp
  802097:	5e                   	pop    %esi
  802098:	5f                   	pop    %edi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    
  80209b:	90                   	nop
  80209c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020a4:	d3 e2                	shl    %cl,%edx
  8020a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8020ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8020b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	d3 ea                	shr    %cl,%edx
  8020bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8020c3:	d3 e7                	shl    %cl,%edi
  8020c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020cc:	89 f2                	mov    %esi,%edx
  8020ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8020d1:	89 c7                	mov    %eax,%edi
  8020d3:	d3 ea                	shr    %cl,%edx
  8020d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020dc:	89 c2                	mov    %eax,%edx
  8020de:	d3 e6                	shl    %cl,%esi
  8020e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020e4:	d3 ea                	shr    %cl,%edx
  8020e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020ea:	09 d6                	or     %edx,%esi
  8020ec:	89 f0                	mov    %esi,%eax
  8020ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8020f1:	d3 e7                	shl    %cl,%edi
  8020f3:	89 f2                	mov    %esi,%edx
  8020f5:	f7 75 f4             	divl   -0xc(%ebp)
  8020f8:	89 d6                	mov    %edx,%esi
  8020fa:	f7 65 e8             	mull   -0x18(%ebp)
  8020fd:	39 d6                	cmp    %edx,%esi
  8020ff:	72 2b                	jb     80212c <__umoddi3+0x11c>
  802101:	39 c7                	cmp    %eax,%edi
  802103:	72 23                	jb     802128 <__umoddi3+0x118>
  802105:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802109:	29 c7                	sub    %eax,%edi
  80210b:	19 d6                	sbb    %edx,%esi
  80210d:	89 f0                	mov    %esi,%eax
  80210f:	89 f2                	mov    %esi,%edx
  802111:	d3 ef                	shr    %cl,%edi
  802113:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802117:	d3 e0                	shl    %cl,%eax
  802119:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80211d:	09 f8                	or     %edi,%eax
  80211f:	d3 ea                	shr    %cl,%edx
  802121:	83 c4 20             	add    $0x20,%esp
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	39 d6                	cmp    %edx,%esi
  80212a:	75 d9                	jne    802105 <__umoddi3+0xf5>
  80212c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80212f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802132:	eb d1                	jmp    802105 <__umoddi3+0xf5>
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	0f 82 18 ff ff ff    	jb     802058 <__umoddi3+0x48>
  802140:	e9 1d ff ff ff       	jmp    802062 <__umoddi3+0x52>
