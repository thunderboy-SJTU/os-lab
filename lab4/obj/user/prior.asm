
obj/user/prior:     file format elf32-i386


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

00800040 <umain>:
#include<inc/lib.h>
#include<inc/env.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
    int pid;
    int i;
    struct Env* env;
    if((pid = fork()) != 0){
  800048:	e8 f5 13 00 00       	call   801442 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 29                	je     80007a <umain+0x3a>
        sys_env_set_prior(pid,PRIOR_HIGH);
  800051:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  800058:	00 
  800059:	89 04 24             	mov    %eax,(%esp)
  80005c:	e8 1a 0f 00 00       	call   800f7b <sys_env_set_prior>
        if((pid = fork())!= 0)
  800061:	e8 dc 13 00 00       	call   801442 <fork>
  800066:	85 c0                	test   %eax,%eax
  800068:	74 10                	je     80007a <umain+0x3a>
           sys_env_set_prior(pid,PRIOR_LOW);
  80006a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800071:	00 
  800072:	89 04 24             	mov    %eax,(%esp)
  800075:	e8 01 0f 00 00       	call   800f7b <sys_env_set_prior>
    }
    sys_yield();
  80007a:	e8 74 12 00 00       	call   8012f3 <sys_yield>
    env = (struct Env*)envs + ENVX(sys_getenvid());
  80007f:	e8 f1 12 00 00       	call   801375 <sys_getenvid>
    for(i = 0; i < 3;i++){
       if(env->env_prior == PRIOR_HIGH)
  800084:	25 ff 03 00 00       	and    $0x3ff,%eax
  800089:	89 c2                	mov    %eax,%edx
  80008b:	c1 e2 07             	shl    $0x7,%edx
  80008e:	8b b4 82 80 00 c0 ee 	mov    -0x113fff80(%edx,%eax,4),%esi
  800095:	bb 00 00 00 00       	mov    $0x0,%ebx
  80009a:	83 fe 03             	cmp    $0x3,%esi
  80009d:	75 1b                	jne    8000ba <umain+0x7a>
          cprintf("[%08x] HIGH PRIOR %d iteration\n",sys_getenvid(),i);
  80009f:	e8 d1 12 00 00       	call   801375 <sys_getenvid>
  8000a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ac:	c7 04 24 20 1b 80 00 	movl   $0x801b20,(%esp)
  8000b3:	e8 21 01 00 00       	call   8001d9 <cprintf>
  8000b8:	eb 3f                	jmp    8000f9 <umain+0xb9>
       if(env->env_prior == PRIOR_MIDD)
  8000ba:	83 fe 02             	cmp    $0x2,%esi
  8000bd:	75 1c                	jne    8000db <umain+0x9b>
          cprintf("[%08x] MIDD PRIOR %d iteration\n",sys_getenvid(),i);
  8000bf:	90                   	nop
  8000c0:	e8 b0 12 00 00       	call   801375 <sys_getenvid>
  8000c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000cd:	c7 04 24 40 1b 80 00 	movl   $0x801b40,(%esp)
  8000d4:	e8 00 01 00 00       	call   8001d9 <cprintf>
  8000d9:	eb 1e                	jmp    8000f9 <umain+0xb9>
       if(env->env_prior == PRIOR_LOW)
  8000db:	83 fe 01             	cmp    $0x1,%esi
  8000de:	75 19                	jne    8000f9 <umain+0xb9>
          cprintf("[%08x] LOW PRIOR %d iteration\n",sys_getenvid(),i);
  8000e0:	e8 90 12 00 00       	call   801375 <sys_getenvid>
  8000e5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ed:	c7 04 24 60 1b 80 00 	movl   $0x801b60,(%esp)
  8000f4:	e8 e0 00 00 00       	call   8001d9 <cprintf>
       sys_yield();
  8000f9:	e8 f5 11 00 00       	call   8012f3 <sys_yield>
        if((pid = fork())!= 0)
           sys_env_set_prior(pid,PRIOR_LOW);
    }
    sys_yield();
    env = (struct Env*)envs + ENVX(sys_getenvid());
    for(i = 0; i < 3;i++){
  8000fe:	83 c3 01             	add    $0x1,%ebx
  800101:	83 fb 03             	cmp    $0x3,%ebx
  800104:	75 94                	jne    80009a <umain+0x5a>
          cprintf("[%08x] MIDD PRIOR %d iteration\n",sys_getenvid(),i);
       if(env->env_prior == PRIOR_LOW)
          cprintf("[%08x] LOW PRIOR %d iteration\n",sys_getenvid(),i);
       sys_yield();
    }
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    
  80010d:	00 00                	add    %al,(%eax)
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
  800122:	e8 4e 12 00 00       	call   801375 <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	89 c2                	mov    %eax,%edx
  80012e:	c1 e2 07             	shl    $0x7,%edx
  800131:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800138:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013d:	85 f6                	test   %esi,%esi
  80013f:	7e 07                	jle    800148 <libmain+0x38>
		binaryname = argv[0];
  800141:	8b 03                	mov    (%ebx),%eax
  800143:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800148:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80014c:	89 34 24             	mov    %esi,(%esp)
  80014f:	e8 ec fe ff ff       	call   800040 <umain>

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
	sys_env_destroy(0);
  80016a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800171:	e8 3f 12 00 00       	call   8013b5 <sys_env_destroy>
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800181:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800188:	00 00 00 
	b.cnt = 0;
  80018b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800192:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800195:	8b 45 0c             	mov    0xc(%ebp),%eax
  800198:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019c:	8b 45 08             	mov    0x8(%ebp),%eax
  80019f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	c7 04 24 f3 01 80 00 	movl   $0x8001f3,(%esp)
  8001b4:	e8 d3 01 00 00       	call   80038c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 6b 0d 00 00       	call   800f3c <sys_cputs>

	return b.cnt;
}
  8001d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d7:	c9                   	leave  
  8001d8:	c3                   	ret    

008001d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001df:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e9:	89 04 24             	mov    %eax,(%esp)
  8001ec:	e8 87 ff ff ff       	call   800178 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 14             	sub    $0x14,%esp
  8001fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fd:	8b 03                	mov    (%ebx),%eax
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800206:	83 c0 01             	add    $0x1,%eax
  800209:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80020b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800210:	75 19                	jne    80022b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800212:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800219:	00 
  80021a:	8d 43 08             	lea    0x8(%ebx),%eax
  80021d:	89 04 24             	mov    %eax,(%esp)
  800220:	e8 17 0d 00 00       	call   800f3c <sys_cputs>
		b->idx = 0;
  800225:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80022b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022f:	83 c4 14             	add    $0x14,%esp
  800232:	5b                   	pop    %ebx
  800233:	5d                   	pop    %ebp
  800234:	c3                   	ret    
	...

00800240 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 4c             	sub    $0x4c,%esp
  800249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80024c:	89 d6                	mov    %edx,%esi
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800254:	8b 55 0c             	mov    0xc(%ebp),%edx
  800257:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80025a:	8b 45 10             	mov    0x10(%ebp),%eax
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800260:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800263:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800266:	b9 00 00 00 00       	mov    $0x0,%ecx
  80026b:	39 d1                	cmp    %edx,%ecx
  80026d:	72 07                	jb     800276 <printnum_v2+0x36>
  80026f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800272:	39 d0                	cmp    %edx,%eax
  800274:	77 5f                	ja     8002d5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800276:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800281:	89 44 24 08          	mov    %eax,0x8(%esp)
  800285:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800289:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80028d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800290:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800293:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800296:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80029a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002a1:	00 
  8002a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002af:	e8 fc 15 00 00       	call   8018b0 <__udivdi3>
  8002b4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c9:	89 f2                	mov    %esi,%edx
  8002cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ce:	e8 6d ff ff ff       	call   800240 <printnum_v2>
  8002d3:	eb 1e                	jmp    8002f3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8002d5:	83 ff 2d             	cmp    $0x2d,%edi
  8002d8:	74 19                	je     8002f3 <printnum_v2+0xb3>
		while (--width > 0)
  8002da:	83 eb 01             	sub    $0x1,%ebx
  8002dd:	85 db                	test   %ebx,%ebx
  8002df:	90                   	nop
  8002e0:	7e 11                	jle    8002f3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8002e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e6:	89 3c 24             	mov    %edi,(%esp)
  8002e9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8002ec:	83 eb 01             	sub    $0x1,%ebx
  8002ef:	85 db                	test   %ebx,%ebx
  8002f1:	7f ef                	jg     8002e2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800302:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800309:	00 
  80030a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80030d:	89 14 24             	mov    %edx,(%esp)
  800310:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800313:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800317:	e8 c4 16 00 00       	call   8019e0 <__umoddi3>
  80031c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800320:	0f be 80 89 1b 80 00 	movsbl 0x801b89(%eax),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032d:	83 c4 4c             	add    $0x4c,%esp
  800330:	5b                   	pop    %ebx
  800331:	5e                   	pop    %esi
  800332:	5f                   	pop    %edi
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800338:	83 fa 01             	cmp    $0x1,%edx
  80033b:	7e 0e                	jle    80034b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 02                	mov    (%edx),%eax
  800346:	8b 52 04             	mov    0x4(%edx),%edx
  800349:	eb 22                	jmp    80036d <getuint+0x38>
	else if (lflag)
  80034b:	85 d2                	test   %edx,%edx
  80034d:	74 10                	je     80035f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 04             	lea    0x4(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	ba 00 00 00 00       	mov    $0x0,%edx
  80035d:	eb 0e                	jmp    80036d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	8d 4a 04             	lea    0x4(%edx),%ecx
  800364:	89 08                	mov    %ecx,(%eax)
  800366:	8b 02                	mov    (%edx),%eax
  800368:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800375:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 0a                	jae    80038a <sprintputch+0x1b>
		*b->buf++ = ch;
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 0a                	mov    %cl,(%edx)
  800385:	83 c2 01             	add    $0x1,%edx
  800388:	89 10                	mov    %edx,(%eax)
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 6c             	sub    $0x6c,%esp
  800395:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800398:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80039f:	eb 1a                	jmp    8003bb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	0f 84 66 06 00 00    	je     800a0f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8003a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	ff 55 08             	call   *0x8(%ebp)
  8003b6:	eb 03                	jmp    8003bb <vprintfmt+0x2f>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bb:	0f b6 07             	movzbl (%edi),%eax
  8003be:	83 c7 01             	add    $0x1,%edi
  8003c1:	83 f8 25             	cmp    $0x25,%eax
  8003c4:	75 db                	jne    8003a1 <vprintfmt+0x15>
  8003c6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8003ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003d6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8003db:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e2:	be 00 00 00 00       	mov    $0x0,%esi
  8003e7:	eb 06                	jmp    8003ef <vprintfmt+0x63>
  8003e9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8003ed:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	0f b6 17             	movzbl (%edi),%edx
  8003f2:	0f b6 c2             	movzbl %dl,%eax
  8003f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f8:	8d 47 01             	lea    0x1(%edi),%eax
  8003fb:	83 ea 23             	sub    $0x23,%edx
  8003fe:	80 fa 55             	cmp    $0x55,%dl
  800401:	0f 87 60 05 00 00    	ja     800967 <vprintfmt+0x5db>
  800407:	0f b6 d2             	movzbl %dl,%edx
  80040a:	ff 24 95 c0 1c 80 00 	jmp    *0x801cc0(,%edx,4)
  800411:	b9 01 00 00 00       	mov    $0x1,%ecx
  800416:	eb d5                	jmp    8003ed <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800418:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80041b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80041e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800421:	8d 7a d0             	lea    -0x30(%edx),%edi
  800424:	83 ff 09             	cmp    $0x9,%edi
  800427:	76 08                	jbe    800431 <vprintfmt+0xa5>
  800429:	eb 40                	jmp    80046b <vprintfmt+0xdf>
  80042b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80042f:	eb bc                	jmp    8003ed <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800431:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800434:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800437:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80043b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80043e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800441:	83 ff 09             	cmp    $0x9,%edi
  800444:	76 eb                	jbe    800431 <vprintfmt+0xa5>
  800446:	eb 23                	jmp    80046b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 55 14             	mov    0x14(%ebp),%edx
  80044b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80044e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800451:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800453:	eb 16                	jmp    80046b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800455:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800458:	c1 fa 1f             	sar    $0x1f,%edx
  80045b:	f7 d2                	not    %edx
  80045d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800460:	eb 8b                	jmp    8003ed <vprintfmt+0x61>
  800462:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800469:	eb 82                	jmp    8003ed <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80046b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046f:	0f 89 78 ff ff ff    	jns    8003ed <vprintfmt+0x61>
  800475:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800478:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80047b:	e9 6d ff ff ff       	jmp    8003ed <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800480:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800483:	e9 65 ff ff ff       	jmp    8003ed <vprintfmt+0x61>
  800488:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 55 0c             	mov    0xc(%ebp),%edx
  800497:	89 54 24 04          	mov    %edx,0x4(%esp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	89 04 24             	mov    %eax,(%esp)
  8004a0:	ff 55 08             	call   *0x8(%ebp)
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8004a6:	e9 10 ff ff ff       	jmp    8003bb <vprintfmt+0x2f>
  8004ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	89 c2                	mov    %eax,%edx
  8004bb:	c1 fa 1f             	sar    $0x1f,%edx
  8004be:	31 d0                	xor    %edx,%eax
  8004c0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c2:	83 f8 08             	cmp    $0x8,%eax
  8004c5:	7f 0b                	jg     8004d2 <vprintfmt+0x146>
  8004c7:	8b 14 85 20 1e 80 00 	mov    0x801e20(,%eax,4),%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	75 26                	jne    8004f8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	c7 44 24 08 9a 1b 80 	movl   $0x801b9a,0x8(%esp)
  8004dd:	00 
  8004de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004e8:	89 1c 24             	mov    %ebx,(%esp)
  8004eb:	e8 a7 05 00 00       	call   800a97 <printfmt>
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	e9 c3 fe ff ff       	jmp    8003bb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fc:	c7 44 24 08 a3 1b 80 	movl   $0x801ba3,0x8(%esp)
  800503:	00 
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	8b 55 08             	mov    0x8(%ebp),%edx
  80050e:	89 14 24             	mov    %edx,(%esp)
  800511:	e8 81 05 00 00       	call   800a97 <printfmt>
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800519:	e9 9d fe ff ff       	jmp    8003bb <vprintfmt+0x2f>
  80051e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800521:	89 c7                	mov    %eax,%edi
  800523:	89 d9                	mov    %ebx,%ecx
  800525:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800528:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 30                	mov    (%eax),%esi
  800536:	85 f6                	test   %esi,%esi
  800538:	75 05                	jne    80053f <vprintfmt+0x1b3>
  80053a:	be a6 1b 80 00       	mov    $0x801ba6,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80053f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800543:	7e 06                	jle    80054b <vprintfmt+0x1bf>
  800545:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800549:	75 10                	jne    80055b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054b:	0f be 06             	movsbl (%esi),%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	0f 85 a2 00 00 00    	jne    8005f8 <vprintfmt+0x26c>
  800556:	e9 92 00 00 00       	jmp    8005ed <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 74 05 00 00       	call   800adb <strnlen>
  800567:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80056f:	85 d2                	test   %edx,%edx
  800571:	7e d8                	jle    80054b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800573:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800577:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80057a:	89 d3                	mov    %edx,%ebx
  80057c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80057f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800582:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800585:	89 ce                	mov    %ecx,%esi
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	89 34 24             	mov    %esi,(%esp)
  80058e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 eb 01             	sub    $0x1,%ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f ef                	jg     800587 <vprintfmt+0x1fb>
  800598:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80059b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80059e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8005a1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005a8:	eb a1                	jmp    80054b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005ae:	74 1b                	je     8005cb <vprintfmt+0x23f>
  8005b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b3:	83 fa 5e             	cmp    $0x5e,%edx
  8005b6:	76 13                	jbe    8005cb <vprintfmt+0x23f>
					putch('?', putdat);
  8005b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c9:	eb 0d                	jmp    8005d8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d8:	83 ef 01             	sub    $0x1,%edi
  8005db:	0f be 06             	movsbl (%esi),%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	74 05                	je     8005e7 <vprintfmt+0x25b>
  8005e2:	83 c6 01             	add    $0x1,%esi
  8005e5:	eb 1a                	jmp    800601 <vprintfmt+0x275>
  8005e7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005ea:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f1:	7f 1f                	jg     800612 <vprintfmt+0x286>
  8005f3:	e9 c0 fd ff ff       	jmp    8003b8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f8:	83 c6 01             	add    $0x1,%esi
  8005fb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005fe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800601:	85 db                	test   %ebx,%ebx
  800603:	78 a5                	js     8005aa <vprintfmt+0x21e>
  800605:	83 eb 01             	sub    $0x1,%ebx
  800608:	79 a0                	jns    8005aa <vprintfmt+0x21e>
  80060a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80060d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800610:	eb db                	jmp    8005ed <vprintfmt+0x261>
  800612:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800615:	8b 75 0c             	mov    0xc(%ebp),%esi
  800618:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80061b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800622:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800629:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 eb 01             	sub    $0x1,%ebx
  80062e:	85 db                	test   %ebx,%ebx
  800630:	7f ec                	jg     80061e <vprintfmt+0x292>
  800632:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800635:	e9 81 fd ff ff       	jmp    8003bb <vprintfmt+0x2f>
  80063a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063d:	83 fe 01             	cmp    $0x1,%esi
  800640:	7e 10                	jle    800652 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 08             	lea    0x8(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 18                	mov    (%eax),%ebx
  80064d:	8b 70 04             	mov    0x4(%eax),%esi
  800650:	eb 26                	jmp    800678 <vprintfmt+0x2ec>
	else if (lflag)
  800652:	85 f6                	test   %esi,%esi
  800654:	74 12                	je     800668 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 18                	mov    (%eax),%ebx
  800661:	89 de                	mov    %ebx,%esi
  800663:	c1 fe 1f             	sar    $0x1f,%esi
  800666:	eb 10                	jmp    800678 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 18                	mov    (%eax),%ebx
  800673:	89 de                	mov    %ebx,%esi
  800675:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800678:	83 f9 01             	cmp    $0x1,%ecx
  80067b:	75 1e                	jne    80069b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80067d:	85 f6                	test   %esi,%esi
  80067f:	78 1a                	js     80069b <vprintfmt+0x30f>
  800681:	85 f6                	test   %esi,%esi
  800683:	7f 05                	jg     80068a <vprintfmt+0x2fe>
  800685:	83 fb 00             	cmp    $0x0,%ebx
  800688:	76 11                	jbe    80069b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80068a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80068d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800691:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80069b:	85 f6                	test   %esi,%esi
  80069d:	78 13                	js     8006b2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8006a2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ad:	e9 da 00 00 00       	jmp    80078c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c3:	89 da                	mov    %ebx,%edx
  8006c5:	89 f1                	mov    %esi,%ecx
  8006c7:	f7 da                	neg    %edx
  8006c9:	83 d1 00             	adc    $0x0,%ecx
  8006cc:	f7 d9                	neg    %ecx
  8006ce:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8006d1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dc:	e9 ab 00 00 00       	jmp    80078c <vprintfmt+0x400>
  8006e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e4:	89 f2                	mov    %esi,%edx
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e9:	e8 47 fc ff ff       	call   800335 <getuint>
  8006ee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8006f1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006fc:	e9 8b 00 00 00       	jmp    80078c <vprintfmt+0x400>
  800701:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800704:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800707:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80070b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800712:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800715:	89 f2                	mov    %esi,%edx
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
  80071a:	e8 16 fc ff ff       	call   800335 <getuint>
  80071f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800722:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800728:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80072d:	eb 5d                	jmp    80078c <vprintfmt+0x400>
  80072f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800735:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800739:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800743:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800747:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 50 04             	lea    0x4(%eax),%edx
  800757:	89 55 14             	mov    %edx,0x14(%ebp)
  80075a:	8b 10                	mov    (%eax),%edx
  80075c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800761:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800764:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800767:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80076a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80076f:	eb 1b                	jmp    80078c <vprintfmt+0x400>
  800771:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800774:	89 f2                	mov    %esi,%edx
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 b7 fb ff ff       	call   800335 <getuint>
  80077e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800781:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800787:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800790:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800793:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800796:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80079a:	77 09                	ja     8007a5 <vprintfmt+0x419>
  80079c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80079f:	0f 82 ac 00 00 00    	jb     800851 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007a8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8007ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007af:	83 ea 01             	sub    $0x1,%edx
  8007b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ba:	8b 44 24 08          	mov    0x8(%esp),%eax
  8007be:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8007c2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8007c5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8007c8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007d6:	00 
  8007d7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8007da:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8007dd:	89 0c 24             	mov    %ecx,(%esp)
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	e8 c7 10 00 00       	call   8018b0 <__udivdi3>
  8007e9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8007ec:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8007ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007f3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007f7:	89 04 24             	mov    %eax,(%esp)
  8007fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	e8 37 fa ff ff       	call   800240 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800810:	8b 74 24 04          	mov    0x4(%esp),%esi
  800814:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800817:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800822:	00 
  800823:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800826:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800829:	89 14 24             	mov    %edx,(%esp)
  80082c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800830:	e8 ab 11 00 00       	call   8019e0 <__umoddi3>
  800835:	89 74 24 04          	mov    %esi,0x4(%esp)
  800839:	0f be 80 89 1b 80 00 	movsbl 0x801b89(%eax),%eax
  800840:	89 04 24             	mov    %eax,(%esp)
  800843:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800846:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80084a:	74 54                	je     8008a0 <vprintfmt+0x514>
  80084c:	e9 67 fb ff ff       	jmp    8003b8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800851:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800855:	8d 76 00             	lea    0x0(%esi),%esi
  800858:	0f 84 2a 01 00 00    	je     800988 <vprintfmt+0x5fc>
		while (--width > 0)
  80085e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800861:	83 ef 01             	sub    $0x1,%edi
  800864:	85 ff                	test   %edi,%edi
  800866:	0f 8e 5e 01 00 00    	jle    8009ca <vprintfmt+0x63e>
  80086c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80086f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800872:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800875:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800878:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80087b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80087e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800882:	89 1c 24             	mov    %ebx,(%esp)
  800885:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800888:	83 ef 01             	sub    $0x1,%edi
  80088b:	85 ff                	test   %edi,%edi
  80088d:	7f ef                	jg     80087e <vprintfmt+0x4f2>
  80088f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800892:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800895:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800898:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80089b:	e9 2a 01 00 00       	jmp    8009ca <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008a0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8008a3:	83 eb 01             	sub    $0x1,%ebx
  8008a6:	85 db                	test   %ebx,%ebx
  8008a8:	0f 8e 0a fb ff ff    	jle    8003b8 <vprintfmt+0x2c>
  8008ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8008b4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8008b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008c2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8008c4:	83 eb 01             	sub    $0x1,%ebx
  8008c7:	85 db                	test   %ebx,%ebx
  8008c9:	7f ec                	jg     8008b7 <vprintfmt+0x52b>
  8008cb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008ce:	e9 e8 fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
  8008d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8d 50 04             	lea    0x4(%eax),%edx
  8008dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008df:	8b 00                	mov    (%eax),%eax
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	75 2a                	jne    80090f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  8008e5:	c7 44 24 0c 40 1c 80 	movl   $0x801c40,0xc(%esp)
  8008ec:	00 
  8008ed:	c7 44 24 08 a3 1b 80 	movl   $0x801ba3,0x8(%esp)
  8008f4:	00 
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ff:	89 0c 24             	mov    %ecx,(%esp)
  800902:	e8 90 01 00 00       	call   800a97 <printfmt>
  800907:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80090a:	e9 ac fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80090f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800912:	8b 13                	mov    (%ebx),%edx
  800914:	83 fa 7f             	cmp    $0x7f,%edx
  800917:	7e 29                	jle    800942 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800919:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80091b:	c7 44 24 0c 78 1c 80 	movl   $0x801c78,0xc(%esp)
  800922:	00 
  800923:	c7 44 24 08 a3 1b 80 	movl   $0x801ba3,0x8(%esp)
  80092a:	00 
  80092b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	89 04 24             	mov    %eax,(%esp)
  800935:	e8 5d 01 00 00       	call   800a97 <printfmt>
  80093a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80093d:	e9 79 fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800942:	88 10                	mov    %dl,(%eax)
  800944:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800947:	e9 6f fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
  80094c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80094f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800955:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800959:	89 14 24             	mov    %edx,(%esp)
  80095c:	ff 55 08             	call   *0x8(%ebp)
  80095f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800962:	e9 54 fa ff ff       	jmp    8003bb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800975:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800978:	8d 47 ff             	lea    -0x1(%edi),%eax
  80097b:	80 38 25             	cmpb   $0x25,(%eax)
  80097e:	0f 84 37 fa ff ff    	je     8003bb <vprintfmt+0x2f>
  800984:	89 c7                	mov    %eax,%edi
  800986:	eb f0                	jmp    800978 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800993:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800996:	89 54 24 08          	mov    %edx,0x8(%esp)
  80099a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009a1:	00 
  8009a2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009a5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009a8:	89 04 24             	mov    %eax,(%esp)
  8009ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009af:	e8 2c 10 00 00       	call   8019e0 <__umoddi3>
  8009b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b8:	0f be 80 89 1b 80 00 	movsbl 0x801b89(%eax),%eax
  8009bf:	89 04 24             	mov    %eax,(%esp)
  8009c2:	ff 55 08             	call   *0x8(%ebp)
  8009c5:	e9 d6 fe ff ff       	jmp    8008a0 <vprintfmt+0x514>
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009d5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009dc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009e3:	00 
  8009e4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8009e7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8009ea:	89 04 24             	mov    %eax,(%esp)
  8009ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f1:	e8 ea 0f 00 00       	call   8019e0 <__umoddi3>
  8009f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fa:	0f be 80 89 1b 80 00 	movsbl 0x801b89(%eax),%eax
  800a01:	89 04 24             	mov    %eax,(%esp)
  800a04:	ff 55 08             	call   *0x8(%ebp)
  800a07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a0a:	e9 ac f9 ff ff       	jmp    8003bb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a0f:	83 c4 6c             	add    $0x6c,%esp
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 28             	sub    $0x28,%esp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a23:	85 c0                	test   %eax,%eax
  800a25:	74 04                	je     800a2b <vsnprintf+0x14>
  800a27:	85 d2                	test   %edx,%edx
  800a29:	7f 07                	jg     800a32 <vsnprintf+0x1b>
  800a2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a30:	eb 3b                	jmp    800a6d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a35:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a43:	8b 45 14             	mov    0x14(%ebp),%eax
  800a46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a51:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a58:	c7 04 24 6f 03 80 00 	movl   $0x80036f,(%esp)
  800a5f:	e8 28 f9 ff ff       	call   80038c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a67:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a75:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a78:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 82 ff ff ff       	call   800a17 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a9d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800aa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa4:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	89 04 24             	mov    %eax,(%esp)
  800ab8:	e8 cf f8 ff ff       	call   80038c <vprintfmt>
	va_end(ap);
}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    
	...

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	80 3a 00             	cmpb   $0x0,(%edx)
  800ace:	74 09                	je     800ad9 <strlen+0x19>
		n++;
  800ad0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad7:	75 f7                	jne    800ad0 <strlen+0x10>
		n++;
	return n;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae5:	85 c9                	test   %ecx,%ecx
  800ae7:	74 19                	je     800b02 <strnlen+0x27>
  800ae9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aec:	74 14                	je     800b02 <strnlen+0x27>
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800af3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	74 0d                	je     800b07 <strnlen+0x2c>
  800afa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800afe:	75 f3                	jne    800af3 <strnlen+0x18>
  800b00:	eb 05                	jmp    800b07 <strnlen+0x2c>
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b07:	5b                   	pop    %ebx
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b20:	83 c2 01             	add    $0x1,%edx
  800b23:	84 c9                	test   %cl,%cl
  800b25:	75 f2                	jne    800b19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b27:	5b                   	pop    %ebx
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b34:	89 1c 24             	mov    %ebx,(%esp)
  800b37:	e8 84 ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	e8 bc ff ff ff       	call   800b0a <strcpy>
	return dst;
}
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b64:	85 f6                	test   %esi,%esi
  800b66:	74 18                	je     800b80 <strncpy+0x2a>
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b6d:	0f b6 1a             	movzbl (%edx),%ebx
  800b70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b73:	80 3a 01             	cmpb   $0x1,(%edx)
  800b76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	39 ce                	cmp    %ecx,%esi
  800b7e:	77 ed                	ja     800b6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b92:	89 f0                	mov    %esi,%eax
  800b94:	85 c9                	test   %ecx,%ecx
  800b96:	74 27                	je     800bbf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b98:	83 e9 01             	sub    $0x1,%ecx
  800b9b:	74 1d                	je     800bba <strlcpy+0x36>
  800b9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ba0:	84 db                	test   %bl,%bl
  800ba2:	74 16                	je     800bba <strlcpy+0x36>
			*dst++ = *src++;
  800ba4:	88 18                	mov    %bl,(%eax)
  800ba6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba9:	83 e9 01             	sub    $0x1,%ecx
  800bac:	74 0e                	je     800bbc <strlcpy+0x38>
			*dst++ = *src++;
  800bae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb1:	0f b6 1a             	movzbl (%edx),%ebx
  800bb4:	84 db                	test   %bl,%bl
  800bb6:	75 ec                	jne    800ba4 <strlcpy+0x20>
  800bb8:	eb 02                	jmp    800bbc <strlcpy+0x38>
  800bba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bbc:	c6 00 00             	movb   $0x0,(%eax)
  800bbf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bce:	0f b6 01             	movzbl (%ecx),%eax
  800bd1:	84 c0                	test   %al,%al
  800bd3:	74 15                	je     800bea <strcmp+0x25>
  800bd5:	3a 02                	cmp    (%edx),%al
  800bd7:	75 11                	jne    800bea <strcmp+0x25>
		p++, q++;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bdf:	0f b6 01             	movzbl (%ecx),%eax
  800be2:	84 c0                	test   %al,%al
  800be4:	74 04                	je     800bea <strcmp+0x25>
  800be6:	3a 02                	cmp    (%edx),%al
  800be8:	74 ef                	je     800bd9 <strcmp+0x14>
  800bea:	0f b6 c0             	movzbl %al,%eax
  800bed:	0f b6 12             	movzbl (%edx),%edx
  800bf0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	74 23                	je     800c28 <strncmp+0x34>
  800c05:	0f b6 1a             	movzbl (%edx),%ebx
  800c08:	84 db                	test   %bl,%bl
  800c0a:	74 25                	je     800c31 <strncmp+0x3d>
  800c0c:	3a 19                	cmp    (%ecx),%bl
  800c0e:	75 21                	jne    800c31 <strncmp+0x3d>
  800c10:	83 e8 01             	sub    $0x1,%eax
  800c13:	74 13                	je     800c28 <strncmp+0x34>
		n--, p++, q++;
  800c15:	83 c2 01             	add    $0x1,%edx
  800c18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c1b:	0f b6 1a             	movzbl (%edx),%ebx
  800c1e:	84 db                	test   %bl,%bl
  800c20:	74 0f                	je     800c31 <strncmp+0x3d>
  800c22:	3a 19                	cmp    (%ecx),%bl
  800c24:	74 ea                	je     800c10 <strncmp+0x1c>
  800c26:	eb 09                	jmp    800c31 <strncmp+0x3d>
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5d                   	pop    %ebp
  800c2f:	90                   	nop
  800c30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c31:	0f b6 02             	movzbl (%edx),%eax
  800c34:	0f b6 11             	movzbl (%ecx),%edx
  800c37:	29 d0                	sub    %edx,%eax
  800c39:	eb f2                	jmp    800c2d <strncmp+0x39>

00800c3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c45:	0f b6 10             	movzbl (%eax),%edx
  800c48:	84 d2                	test   %dl,%dl
  800c4a:	74 18                	je     800c64 <strchr+0x29>
		if (*s == c)
  800c4c:	38 ca                	cmp    %cl,%dl
  800c4e:	75 0a                	jne    800c5a <strchr+0x1f>
  800c50:	eb 17                	jmp    800c69 <strchr+0x2e>
  800c52:	38 ca                	cmp    %cl,%dl
  800c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c58:	74 0f                	je     800c69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 ee                	jne    800c52 <strchr+0x17>
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	0f b6 10             	movzbl (%eax),%edx
  800c78:	84 d2                	test   %dl,%dl
  800c7a:	74 18                	je     800c94 <strfind+0x29>
		if (*s == c)
  800c7c:	38 ca                	cmp    %cl,%dl
  800c7e:	75 0a                	jne    800c8a <strfind+0x1f>
  800c80:	eb 12                	jmp    800c94 <strfind+0x29>
  800c82:	38 ca                	cmp    %cl,%dl
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	74 0a                	je     800c94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c8a:	83 c0 01             	add    $0x1,%eax
  800c8d:	0f b6 10             	movzbl (%eax),%edx
  800c90:	84 d2                	test   %dl,%dl
  800c92:	75 ee                	jne    800c82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	89 1c 24             	mov    %ebx,(%esp)
  800c9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb0:	85 c9                	test   %ecx,%ecx
  800cb2:	74 30                	je     800ce4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cba:	75 25                	jne    800ce1 <memset+0x4b>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 20                	jne    800ce1 <memset+0x4b>
		c &= 0xFF;
  800cc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	c1 e3 08             	shl    $0x8,%ebx
  800cc9:	89 d6                	mov    %edx,%esi
  800ccb:	c1 e6 18             	shl    $0x18,%esi
  800cce:	89 d0                	mov    %edx,%eax
  800cd0:	c1 e0 10             	shl    $0x10,%eax
  800cd3:	09 f0                	or     %esi,%eax
  800cd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800cd7:	09 d8                	or     %ebx,%eax
  800cd9:	c1 e9 02             	shr    $0x2,%ecx
  800cdc:	fc                   	cld    
  800cdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cdf:	eb 03                	jmp    800ce4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce1:	fc                   	cld    
  800ce2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	8b 1c 24             	mov    (%esp),%ebx
  800ce9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ced:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf1:	89 ec                	mov    %ebp,%esp
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	83 ec 08             	sub    $0x8,%esp
  800cfb:	89 34 24             	mov    %esi,(%esp)
  800cfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d0d:	39 c6                	cmp    %eax,%esi
  800d0f:	73 35                	jae    800d46 <memmove+0x51>
  800d11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d14:	39 d0                	cmp    %edx,%eax
  800d16:	73 2e                	jae    800d46 <memmove+0x51>
		s += n;
		d += n;
  800d18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1a:	f6 c2 03             	test   $0x3,%dl
  800d1d:	75 1b                	jne    800d3a <memmove+0x45>
  800d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d25:	75 13                	jne    800d3a <memmove+0x45>
  800d27:	f6 c1 03             	test   $0x3,%cl
  800d2a:	75 0e                	jne    800d3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d2c:	83 ef 04             	sub    $0x4,%edi
  800d2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d32:	c1 e9 02             	shr    $0x2,%ecx
  800d35:	fd                   	std    
  800d36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d38:	eb 09                	jmp    800d43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d3a:	83 ef 01             	sub    $0x1,%edi
  800d3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d40:	fd                   	std    
  800d41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d44:	eb 20                	jmp    800d66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d4c:	75 15                	jne    800d63 <memmove+0x6e>
  800d4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d54:	75 0d                	jne    800d63 <memmove+0x6e>
  800d56:	f6 c1 03             	test   $0x3,%cl
  800d59:	75 08                	jne    800d63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d5b:	c1 e9 02             	shr    $0x2,%ecx
  800d5e:	fc                   	cld    
  800d5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d61:	eb 03                	jmp    800d66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d63:	fc                   	cld    
  800d64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d66:	8b 34 24             	mov    (%esp),%esi
  800d69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d6d:	89 ec                	mov    %ebp,%esp
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d77:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	89 04 24             	mov    %eax,(%esp)
  800d8b:	e8 65 ff ff ff       	call   800cf5 <memmove>
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da1:	85 c9                	test   %ecx,%ecx
  800da3:	74 36                	je     800ddb <memcmp+0x49>
		if (*s1 != *s2)
  800da5:	0f b6 06             	movzbl (%esi),%eax
  800da8:	0f b6 1f             	movzbl (%edi),%ebx
  800dab:	38 d8                	cmp    %bl,%al
  800dad:	74 20                	je     800dcf <memcmp+0x3d>
  800daf:	eb 14                	jmp    800dc5 <memcmp+0x33>
  800db1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800db6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	83 e9 01             	sub    $0x1,%ecx
  800dc1:	38 d8                	cmp    %bl,%al
  800dc3:	74 12                	je     800dd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800dc5:	0f b6 c0             	movzbl %al,%eax
  800dc8:	0f b6 db             	movzbl %bl,%ebx
  800dcb:	29 d8                	sub    %ebx,%eax
  800dcd:	eb 11                	jmp    800de0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dcf:	83 e9 01             	sub    $0x1,%ecx
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	85 c9                	test   %ecx,%ecx
  800dd9:	75 d6                	jne    800db1 <memcmp+0x1f>
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df0:	39 d0                	cmp    %edx,%eax
  800df2:	73 15                	jae    800e09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800df8:	38 08                	cmp    %cl,(%eax)
  800dfa:	75 06                	jne    800e02 <memfind+0x1d>
  800dfc:	eb 0b                	jmp    800e09 <memfind+0x24>
  800dfe:	38 08                	cmp    %cl,(%eax)
  800e00:	74 07                	je     800e09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e02:	83 c0 01             	add    $0x1,%eax
  800e05:	39 c2                	cmp    %eax,%edx
  800e07:	77 f5                	ja     800dfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1a:	0f b6 02             	movzbl (%edx),%eax
  800e1d:	3c 20                	cmp    $0x20,%al
  800e1f:	74 04                	je     800e25 <strtol+0x1a>
  800e21:	3c 09                	cmp    $0x9,%al
  800e23:	75 0e                	jne    800e33 <strtol+0x28>
		s++;
  800e25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e28:	0f b6 02             	movzbl (%edx),%eax
  800e2b:	3c 20                	cmp    $0x20,%al
  800e2d:	74 f6                	je     800e25 <strtol+0x1a>
  800e2f:	3c 09                	cmp    $0x9,%al
  800e31:	74 f2                	je     800e25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e33:	3c 2b                	cmp    $0x2b,%al
  800e35:	75 0c                	jne    800e43 <strtol+0x38>
		s++;
  800e37:	83 c2 01             	add    $0x1,%edx
  800e3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e41:	eb 15                	jmp    800e58 <strtol+0x4d>
	else if (*s == '-')
  800e43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e4a:	3c 2d                	cmp    $0x2d,%al
  800e4c:	75 0a                	jne    800e58 <strtol+0x4d>
		s++, neg = 1;
  800e4e:	83 c2 01             	add    $0x1,%edx
  800e51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e58:	85 db                	test   %ebx,%ebx
  800e5a:	0f 94 c0             	sete   %al
  800e5d:	74 05                	je     800e64 <strtol+0x59>
  800e5f:	83 fb 10             	cmp    $0x10,%ebx
  800e62:	75 18                	jne    800e7c <strtol+0x71>
  800e64:	80 3a 30             	cmpb   $0x30,(%edx)
  800e67:	75 13                	jne    800e7c <strtol+0x71>
  800e69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e6d:	8d 76 00             	lea    0x0(%esi),%esi
  800e70:	75 0a                	jne    800e7c <strtol+0x71>
		s += 2, base = 16;
  800e72:	83 c2 02             	add    $0x2,%edx
  800e75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e7a:	eb 15                	jmp    800e91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7c:	84 c0                	test   %al,%al
  800e7e:	66 90                	xchg   %ax,%ax
  800e80:	74 0f                	je     800e91 <strtol+0x86>
  800e82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e87:	80 3a 30             	cmpb   $0x30,(%edx)
  800e8a:	75 05                	jne    800e91 <strtol+0x86>
		s++, base = 8;
  800e8c:	83 c2 01             	add    $0x1,%edx
  800e8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e98:	0f b6 0a             	movzbl (%edx),%ecx
  800e9b:	89 cf                	mov    %ecx,%edi
  800e9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ea0:	80 fb 09             	cmp    $0x9,%bl
  800ea3:	77 08                	ja     800ead <strtol+0xa2>
			dig = *s - '0';
  800ea5:	0f be c9             	movsbl %cl,%ecx
  800ea8:	83 e9 30             	sub    $0x30,%ecx
  800eab:	eb 1e                	jmp    800ecb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ead:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800eb0:	80 fb 19             	cmp    $0x19,%bl
  800eb3:	77 08                	ja     800ebd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800eb5:	0f be c9             	movsbl %cl,%ecx
  800eb8:	83 e9 57             	sub    $0x57,%ecx
  800ebb:	eb 0e                	jmp    800ecb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ebd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ec0:	80 fb 19             	cmp    $0x19,%bl
  800ec3:	77 15                	ja     800eda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ec5:	0f be c9             	movsbl %cl,%ecx
  800ec8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ecb:	39 f1                	cmp    %esi,%ecx
  800ecd:	7d 0b                	jge    800eda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ecf:	83 c2 01             	add    $0x1,%edx
  800ed2:	0f af c6             	imul   %esi,%eax
  800ed5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ed8:	eb be                	jmp    800e98 <strtol+0x8d>
  800eda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800edc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee0:	74 05                	je     800ee7 <strtol+0xdc>
		*endptr = (char *) s;
  800ee2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ee7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800eeb:	74 04                	je     800ef1 <strtol+0xe6>
  800eed:	89 c8                	mov    %ecx,%eax
  800eef:	f7 d8                	neg    %eax
}
  800ef1:	83 c4 04             	add    $0x4,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	00 00                	add    %al,(%eax)
	...

00800efc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	89 1c 24             	mov    %ebx,(%esp)
  800f05:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f09:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f13:	89 d1                	mov    %edx,%ecx
  800f15:	89 d3                	mov    %edx,%ebx
  800f17:	89 d7                	mov    %edx,%edi
  800f19:	51                   	push   %ecx
  800f1a:	52                   	push   %edx
  800f1b:	53                   	push   %ebx
  800f1c:	54                   	push   %esp
  800f1d:	55                   	push   %ebp
  800f1e:	56                   	push   %esi
  800f1f:	57                   	push   %edi
  800f20:	54                   	push   %esp
  800f21:	5d                   	pop    %ebp
  800f22:	8d 35 2a 0f 80 00    	lea    0x800f2a,%esi
  800f28:	0f 34                	sysenter 
  800f2a:	5f                   	pop    %edi
  800f2b:	5e                   	pop    %esi
  800f2c:	5d                   	pop    %ebp
  800f2d:	5c                   	pop    %esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5a                   	pop    %edx
  800f30:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f31:	8b 1c 24             	mov    (%esp),%ebx
  800f34:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 08             	sub    $0x8,%esp
  800f42:	89 1c 24             	mov    %ebx,(%esp)
  800f45:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f51:	8b 55 08             	mov    0x8(%ebp),%edx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	89 c7                	mov    %eax,%edi
  800f58:	51                   	push   %ecx
  800f59:	52                   	push   %edx
  800f5a:	53                   	push   %ebx
  800f5b:	54                   	push   %esp
  800f5c:	55                   	push   %ebp
  800f5d:	56                   	push   %esi
  800f5e:	57                   	push   %edi
  800f5f:	54                   	push   %esp
  800f60:	5d                   	pop    %ebp
  800f61:	8d 35 69 0f 80 00    	lea    0x800f69,%esi
  800f67:	0f 34                	sysenter 
  800f69:	5f                   	pop    %edi
  800f6a:	5e                   	pop    %esi
  800f6b:	5d                   	pop    %ebp
  800f6c:	5c                   	pop    %esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5a                   	pop    %edx
  800f6f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f70:	8b 1c 24             	mov    (%esp),%ebx
  800f73:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f77:	89 ec                	mov    %ebp,%esp
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 28             	sub    $0x28,%esp
  800f81:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f84:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f94:	8b 55 08             	mov    0x8(%ebp),%edx
  800f97:	89 df                	mov    %ebx,%edi
  800f99:	51                   	push   %ecx
  800f9a:	52                   	push   %edx
  800f9b:	53                   	push   %ebx
  800f9c:	54                   	push   %esp
  800f9d:	55                   	push   %ebp
  800f9e:	56                   	push   %esi
  800f9f:	57                   	push   %edi
  800fa0:	54                   	push   %esp
  800fa1:	5d                   	pop    %ebp
  800fa2:	8d 35 aa 0f 80 00    	lea    0x800faa,%esi
  800fa8:	0f 34                	sysenter 
  800faa:	5f                   	pop    %edi
  800fab:	5e                   	pop    %esi
  800fac:	5d                   	pop    %ebp
  800fad:	5c                   	pop    %esp
  800fae:	5b                   	pop    %ebx
  800faf:	5a                   	pop    %edx
  800fb0:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	7e 28                	jle    800fdd <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb9:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  800fc8:	00 
  800fc9:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fd0:	00 
  800fd1:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  800fd8:	e8 e7 07 00 00       	call   8017c4 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800fdd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800fe0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe3:	89 ec                	mov    %ebp,%esp
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	89 1c 24             	mov    %ebx,(%esp)
  800ff0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	89 cb                	mov    %ecx,%ebx
  801003:	89 cf                	mov    %ecx,%edi
  801005:	51                   	push   %ecx
  801006:	52                   	push   %edx
  801007:	53                   	push   %ebx
  801008:	54                   	push   %esp
  801009:	55                   	push   %ebp
  80100a:	56                   	push   %esi
  80100b:	57                   	push   %edi
  80100c:	54                   	push   %esp
  80100d:	5d                   	pop    %ebp
  80100e:	8d 35 16 10 80 00    	lea    0x801016,%esi
  801014:	0f 34                	sysenter 
  801016:	5f                   	pop    %edi
  801017:	5e                   	pop    %esi
  801018:	5d                   	pop    %ebp
  801019:	5c                   	pop    %esp
  80101a:	5b                   	pop    %ebx
  80101b:	5a                   	pop    %edx
  80101c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80101d:	8b 1c 24             	mov    (%esp),%ebx
  801020:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801024:	89 ec                	mov    %ebp,%esp
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 28             	sub    $0x28,%esp
  80102e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801031:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801034:	b9 00 00 00 00       	mov    $0x0,%ecx
  801039:	b8 0d 00 00 00       	mov    $0xd,%eax
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
  801041:	89 cb                	mov    %ecx,%ebx
  801043:	89 cf                	mov    %ecx,%edi
  801045:	51                   	push   %ecx
  801046:	52                   	push   %edx
  801047:	53                   	push   %ebx
  801048:	54                   	push   %esp
  801049:	55                   	push   %ebp
  80104a:	56                   	push   %esi
  80104b:	57                   	push   %edi
  80104c:	54                   	push   %esp
  80104d:	5d                   	pop    %ebp
  80104e:	8d 35 56 10 80 00    	lea    0x801056,%esi
  801054:	0f 34                	sysenter 
  801056:	5f                   	pop    %edi
  801057:	5e                   	pop    %esi
  801058:	5d                   	pop    %ebp
  801059:	5c                   	pop    %esp
  80105a:	5b                   	pop    %ebx
  80105b:	5a                   	pop    %edx
  80105c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80105d:	85 c0                	test   %eax,%eax
  80105f:	7e 28                	jle    801089 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801061:	89 44 24 10          	mov    %eax,0x10(%esp)
  801065:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80106c:	00 
  80106d:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  801074:	00 
  801075:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80107c:	00 
  80107d:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  801084:	e8 3b 07 00 00       	call   8017c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80108c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80108f:	89 ec                	mov    %ebp,%esp
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	89 1c 24             	mov    %ebx,(%esp)
  80109c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010a5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b1:	51                   	push   %ecx
  8010b2:	52                   	push   %edx
  8010b3:	53                   	push   %ebx
  8010b4:	54                   	push   %esp
  8010b5:	55                   	push   %ebp
  8010b6:	56                   	push   %esi
  8010b7:	57                   	push   %edi
  8010b8:	54                   	push   %esp
  8010b9:	5d                   	pop    %ebp
  8010ba:	8d 35 c2 10 80 00    	lea    0x8010c2,%esi
  8010c0:	0f 34                	sysenter 
  8010c2:	5f                   	pop    %edi
  8010c3:	5e                   	pop    %esi
  8010c4:	5d                   	pop    %ebp
  8010c5:	5c                   	pop    %esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5a                   	pop    %edx
  8010c8:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010c9:	8b 1c 24             	mov    (%esp),%ebx
  8010cc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d0:	89 ec                	mov    %ebp,%esp
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 28             	sub    $0x28,%esp
  8010da:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010dd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	89 df                	mov    %ebx,%edi
  8010f2:	51                   	push   %ecx
  8010f3:	52                   	push   %edx
  8010f4:	53                   	push   %ebx
  8010f5:	54                   	push   %esp
  8010f6:	55                   	push   %ebp
  8010f7:	56                   	push   %esi
  8010f8:	57                   	push   %edi
  8010f9:	54                   	push   %esp
  8010fa:	5d                   	pop    %ebp
  8010fb:	8d 35 03 11 80 00    	lea    0x801103,%esi
  801101:	0f 34                	sysenter 
  801103:	5f                   	pop    %edi
  801104:	5e                   	pop    %esi
  801105:	5d                   	pop    %ebp
  801106:	5c                   	pop    %esp
  801107:	5b                   	pop    %ebx
  801108:	5a                   	pop    %edx
  801109:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80110a:	85 c0                	test   %eax,%eax
  80110c:	7e 28                	jle    801136 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801112:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801119:	00 
  80111a:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  801121:	00 
  801122:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801129:	00 
  80112a:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  801131:	e8 8e 06 00 00       	call   8017c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801136:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801139:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80113c:	89 ec                	mov    %ebp,%esp
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 28             	sub    $0x28,%esp
  801146:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801149:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801151:	b8 09 00 00 00       	mov    $0x9,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	89 df                	mov    %ebx,%edi
  80115e:	51                   	push   %ecx
  80115f:	52                   	push   %edx
  801160:	53                   	push   %ebx
  801161:	54                   	push   %esp
  801162:	55                   	push   %ebp
  801163:	56                   	push   %esi
  801164:	57                   	push   %edi
  801165:	54                   	push   %esp
  801166:	5d                   	pop    %ebp
  801167:	8d 35 6f 11 80 00    	lea    0x80116f,%esi
  80116d:	0f 34                	sysenter 
  80116f:	5f                   	pop    %edi
  801170:	5e                   	pop    %esi
  801171:	5d                   	pop    %ebp
  801172:	5c                   	pop    %esp
  801173:	5b                   	pop    %ebx
  801174:	5a                   	pop    %edx
  801175:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801176:	85 c0                	test   %eax,%eax
  801178:	7e 28                	jle    8011a2 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801185:	00 
  801186:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  80118d:	00 
  80118e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801195:	00 
  801196:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  80119d:	e8 22 06 00 00       	call   8017c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011a2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011a8:	89 ec                	mov    %ebp,%esp
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 28             	sub    $0x28,%esp
  8011b2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011b5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bd:	b8 07 00 00 00       	mov    $0x7,%eax
  8011c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c8:	89 df                	mov    %ebx,%edi
  8011ca:	51                   	push   %ecx
  8011cb:	52                   	push   %edx
  8011cc:	53                   	push   %ebx
  8011cd:	54                   	push   %esp
  8011ce:	55                   	push   %ebp
  8011cf:	56                   	push   %esi
  8011d0:	57                   	push   %edi
  8011d1:	54                   	push   %esp
  8011d2:	5d                   	pop    %ebp
  8011d3:	8d 35 db 11 80 00    	lea    0x8011db,%esi
  8011d9:	0f 34                	sysenter 
  8011db:	5f                   	pop    %edi
  8011dc:	5e                   	pop    %esi
  8011dd:	5d                   	pop    %ebp
  8011de:	5c                   	pop    %esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5a                   	pop    %edx
  8011e1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	7e 28                	jle    80120e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8011f1:	00 
  8011f2:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  8011f9:	00 
  8011fa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801201:	00 
  801202:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  801209:	e8 b6 05 00 00       	call   8017c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80120e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801211:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801214:	89 ec                	mov    %ebp,%esp
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 28             	sub    $0x28,%esp
  80121e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801221:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801224:	8b 7d 18             	mov    0x18(%ebp),%edi
  801227:	0b 7d 14             	or     0x14(%ebp),%edi
  80122a:	b8 06 00 00 00       	mov    $0x6,%eax
  80122f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801235:	8b 55 08             	mov    0x8(%ebp),%edx
  801238:	51                   	push   %ecx
  801239:	52                   	push   %edx
  80123a:	53                   	push   %ebx
  80123b:	54                   	push   %esp
  80123c:	55                   	push   %ebp
  80123d:	56                   	push   %esi
  80123e:	57                   	push   %edi
  80123f:	54                   	push   %esp
  801240:	5d                   	pop    %ebp
  801241:	8d 35 49 12 80 00    	lea    0x801249,%esi
  801247:	0f 34                	sysenter 
  801249:	5f                   	pop    %edi
  80124a:	5e                   	pop    %esi
  80124b:	5d                   	pop    %ebp
  80124c:	5c                   	pop    %esp
  80124d:	5b                   	pop    %ebx
  80124e:	5a                   	pop    %edx
  80124f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801250:	85 c0                	test   %eax,%eax
  801252:	7e 28                	jle    80127c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801254:	89 44 24 10          	mov    %eax,0x10(%esp)
  801258:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80125f:	00 
  801260:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  801277:	e8 48 05 00 00       	call   8017c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80127c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80127f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801282:	89 ec                	mov    %ebp,%esp
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	83 ec 28             	sub    $0x28,%esp
  80128c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80128f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801292:	bf 00 00 00 00       	mov    $0x0,%edi
  801297:	b8 05 00 00 00       	mov    $0x5,%eax
  80129c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80129f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a5:	51                   	push   %ecx
  8012a6:	52                   	push   %edx
  8012a7:	53                   	push   %ebx
  8012a8:	54                   	push   %esp
  8012a9:	55                   	push   %ebp
  8012aa:	56                   	push   %esi
  8012ab:	57                   	push   %edi
  8012ac:	54                   	push   %esp
  8012ad:	5d                   	pop    %ebp
  8012ae:	8d 35 b6 12 80 00    	lea    0x8012b6,%esi
  8012b4:	0f 34                	sysenter 
  8012b6:	5f                   	pop    %edi
  8012b7:	5e                   	pop    %esi
  8012b8:	5d                   	pop    %ebp
  8012b9:	5c                   	pop    %esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5a                   	pop    %edx
  8012bc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	7e 28                	jle    8012e9 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c5:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012cc:	00 
  8012cd:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  8012d4:	00 
  8012d5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012dc:	00 
  8012dd:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  8012e4:	e8 db 04 00 00       	call   8017c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ef:	89 ec                	mov    %ebp,%esp
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	89 1c 24             	mov    %ebx,(%esp)
  8012fc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801300:	ba 00 00 00 00       	mov    $0x0,%edx
  801305:	b8 0b 00 00 00       	mov    $0xb,%eax
  80130a:	89 d1                	mov    %edx,%ecx
  80130c:	89 d3                	mov    %edx,%ebx
  80130e:	89 d7                	mov    %edx,%edi
  801310:	51                   	push   %ecx
  801311:	52                   	push   %edx
  801312:	53                   	push   %ebx
  801313:	54                   	push   %esp
  801314:	55                   	push   %ebp
  801315:	56                   	push   %esi
  801316:	57                   	push   %edi
  801317:	54                   	push   %esp
  801318:	5d                   	pop    %ebp
  801319:	8d 35 21 13 80 00    	lea    0x801321,%esi
  80131f:	0f 34                	sysenter 
  801321:	5f                   	pop    %edi
  801322:	5e                   	pop    %esi
  801323:	5d                   	pop    %ebp
  801324:	5c                   	pop    %esp
  801325:	5b                   	pop    %ebx
  801326:	5a                   	pop    %edx
  801327:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801328:	8b 1c 24             	mov    (%esp),%ebx
  80132b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80132f:	89 ec                	mov    %ebp,%esp
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	89 1c 24             	mov    %ebx,(%esp)
  80133c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801340:	bb 00 00 00 00       	mov    $0x0,%ebx
  801345:	b8 04 00 00 00       	mov    $0x4,%eax
  80134a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134d:	8b 55 08             	mov    0x8(%ebp),%edx
  801350:	89 df                	mov    %ebx,%edi
  801352:	51                   	push   %ecx
  801353:	52                   	push   %edx
  801354:	53                   	push   %ebx
  801355:	54                   	push   %esp
  801356:	55                   	push   %ebp
  801357:	56                   	push   %esi
  801358:	57                   	push   %edi
  801359:	54                   	push   %esp
  80135a:	5d                   	pop    %ebp
  80135b:	8d 35 63 13 80 00    	lea    0x801363,%esi
  801361:	0f 34                	sysenter 
  801363:	5f                   	pop    %edi
  801364:	5e                   	pop    %esi
  801365:	5d                   	pop    %ebp
  801366:	5c                   	pop    %esp
  801367:	5b                   	pop    %ebx
  801368:	5a                   	pop    %edx
  801369:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80136a:	8b 1c 24             	mov    (%esp),%ebx
  80136d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801371:	89 ec                	mov    %ebp,%esp
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	89 1c 24             	mov    %ebx,(%esp)
  80137e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801382:	ba 00 00 00 00       	mov    $0x0,%edx
  801387:	b8 02 00 00 00       	mov    $0x2,%eax
  80138c:	89 d1                	mov    %edx,%ecx
  80138e:	89 d3                	mov    %edx,%ebx
  801390:	89 d7                	mov    %edx,%edi
  801392:	51                   	push   %ecx
  801393:	52                   	push   %edx
  801394:	53                   	push   %ebx
  801395:	54                   	push   %esp
  801396:	55                   	push   %ebp
  801397:	56                   	push   %esi
  801398:	57                   	push   %edi
  801399:	54                   	push   %esp
  80139a:	5d                   	pop    %ebp
  80139b:	8d 35 a3 13 80 00    	lea    0x8013a3,%esi
  8013a1:	0f 34                	sysenter 
  8013a3:	5f                   	pop    %edi
  8013a4:	5e                   	pop    %esi
  8013a5:	5d                   	pop    %ebp
  8013a6:	5c                   	pop    %esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5a                   	pop    %edx
  8013a9:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013aa:	8b 1c 24             	mov    (%esp),%ebx
  8013ad:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b1:	89 ec                	mov    %ebp,%esp
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	83 ec 28             	sub    $0x28,%esp
  8013bb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013be:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8013cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ce:	89 cb                	mov    %ecx,%ebx
  8013d0:	89 cf                	mov    %ecx,%edi
  8013d2:	51                   	push   %ecx
  8013d3:	52                   	push   %edx
  8013d4:	53                   	push   %ebx
  8013d5:	54                   	push   %esp
  8013d6:	55                   	push   %ebp
  8013d7:	56                   	push   %esi
  8013d8:	57                   	push   %edi
  8013d9:	54                   	push   %esp
  8013da:	5d                   	pop    %ebp
  8013db:	8d 35 e3 13 80 00    	lea    0x8013e3,%esi
  8013e1:	0f 34                	sysenter 
  8013e3:	5f                   	pop    %edi
  8013e4:	5e                   	pop    %esi
  8013e5:	5d                   	pop    %ebp
  8013e6:	5c                   	pop    %esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5a                   	pop    %edx
  8013e9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	7e 28                	jle    801416 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8013f9:	00 
  8013fa:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  801401:	00 
  801402:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801409:	00 
  80140a:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  801411:	e8 ae 03 00 00       	call   8017c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801416:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801419:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80141c:	89 ec                	mov    %ebp,%esp
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801426:	c7 44 24 08 6f 1e 80 	movl   $0x801e6f,0x8(%esp)
  80142d:	00 
  80142e:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  801435:	00 
  801436:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  80143d:	e8 82 03 00 00       	call   8017c4 <_panic>

00801442 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	57                   	push   %edi
  801446:	56                   	push   %esi
  801447:	53                   	push   %ebx
  801448:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  80144b:	c7 04 24 97 16 80 00 	movl   $0x801697,(%esp)
  801452:	e8 dd 03 00 00       	call   801834 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801457:	ba 08 00 00 00       	mov    $0x8,%edx
  80145c:	89 d0                	mov    %edx,%eax
  80145e:	cd 30                	int    $0x30
  801460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801463:	85 c0                	test   %eax,%eax
  801465:	79 20                	jns    801487 <fork+0x45>
		panic("sys_exofork: %e", envid);
  801467:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146b:	c7 44 24 08 90 1e 80 	movl   $0x801e90,0x8(%esp)
  801472:	00 
  801473:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80147a:	00 
  80147b:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  801482:	e8 3d 03 00 00       	call   8017c4 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801487:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80148c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801491:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801496:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80149a:	75 20                	jne    8014bc <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80149c:	e8 d4 fe ff ff       	call   801375 <sys_getenvid>
  8014a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	c1 e2 07             	shl    $0x7,%edx
  8014ab:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8014b2:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  8014b7:	e9 d0 01 00 00       	jmp    80168c <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	c1 e8 16             	shr    $0x16,%eax
  8014c1:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8014c4:	a8 01                	test   $0x1,%al
  8014c6:	0f 84 0d 01 00 00    	je     8015d9 <fork+0x197>
  8014cc:	89 d8                	mov    %ebx,%eax
  8014ce:	c1 e8 0c             	shr    $0xc,%eax
  8014d1:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8014d4:	f6 c2 01             	test   $0x1,%dl
  8014d7:	0f 84 fc 00 00 00    	je     8015d9 <fork+0x197>
  8014dd:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8014e0:	f6 c2 04             	test   $0x4,%dl
  8014e3:	0f 84 f0 00 00 00    	je     8015d9 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  8014e9:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  8014ec:	89 c2                	mov    %eax,%edx
  8014ee:	c1 ea 0c             	shr    $0xc,%edx
  8014f1:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  8014f4:	f6 c2 01             	test   $0x1,%dl
  8014f7:	0f 84 dc 00 00 00    	je     8015d9 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8014fd:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801503:	0f 84 8d 00 00 00    	je     801596 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  801509:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80150c:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801513:	00 
  801514:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801518:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80151b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80151f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801523:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80152a:	e8 e9 fc ff ff       	call   801218 <sys_page_map>
               if(r<0)
  80152f:	85 c0                	test   %eax,%eax
  801531:	79 1c                	jns    80154f <fork+0x10d>
                 panic("map failed");
  801533:	c7 44 24 08 a0 1e 80 	movl   $0x801ea0,0x8(%esp)
  80153a:	00 
  80153b:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801542:	00 
  801543:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  80154a:	e8 75 02 00 00       	call   8017c4 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  80154f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801556:	00 
  801557:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80155a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80155e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801565:	00 
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801571:	e8 a2 fc ff ff       	call   801218 <sys_page_map>
               if(r<0)
  801576:	85 c0                	test   %eax,%eax
  801578:	79 5f                	jns    8015d9 <fork+0x197>
                 panic("map failed");
  80157a:	c7 44 24 08 a0 1e 80 	movl   $0x801ea0,0x8(%esp)
  801581:	00 
  801582:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801589:	00 
  80158a:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  801591:	e8 2e 02 00 00       	call   8017c4 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801596:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80159d:	00 
  80159e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b4:	e8 5f fc ff ff       	call   801218 <sys_page_map>
               if(r<0)
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	79 1c                	jns    8015d9 <fork+0x197>
                 panic("map failed");
  8015bd:	c7 44 24 08 a0 1e 80 	movl   $0x801ea0,0x8(%esp)
  8015c4:	00 
  8015c5:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8015cc:	00 
  8015cd:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  8015d4:	e8 eb 01 00 00       	call   8017c4 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8015d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015df:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8015e5:	0f 85 d1 fe ff ff    	jne    8014bc <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8015eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015f2:	00 
  8015f3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015fa:	ee 
  8015fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fe:	89 04 24             	mov    %eax,(%esp)
  801601:	e8 80 fc ff ff       	call   801286 <sys_page_alloc>
        if(r < 0)
  801606:	85 c0                	test   %eax,%eax
  801608:	79 1c                	jns    801626 <fork+0x1e4>
            panic("alloc failed");
  80160a:	c7 44 24 08 ab 1e 80 	movl   $0x801eab,0x8(%esp)
  801611:	00 
  801612:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801619:	00 
  80161a:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  801621:	e8 9e 01 00 00       	call   8017c4 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801626:	c7 44 24 04 80 18 80 	movl   $0x801880,0x4(%esp)
  80162d:	00 
  80162e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801631:	89 14 24             	mov    %edx,(%esp)
  801634:	e8 9b fa ff ff       	call   8010d4 <sys_env_set_pgfault_upcall>
        if(r < 0)
  801639:	85 c0                	test   %eax,%eax
  80163b:	79 1c                	jns    801659 <fork+0x217>
            panic("set pgfault upcall failed");
  80163d:	c7 44 24 08 b8 1e 80 	movl   $0x801eb8,0x8(%esp)
  801644:	00 
  801645:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80164c:	00 
  80164d:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  801654:	e8 6b 01 00 00       	call   8017c4 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801659:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801660:	00 
  801661:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801664:	89 04 24             	mov    %eax,(%esp)
  801667:	e8 d4 fa ff ff       	call   801140 <sys_env_set_status>
        if(r < 0)
  80166c:	85 c0                	test   %eax,%eax
  80166e:	79 1c                	jns    80168c <fork+0x24a>
            panic("set status failed");
  801670:	c7 44 24 08 d2 1e 80 	movl   $0x801ed2,0x8(%esp)
  801677:	00 
  801678:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80167f:	00 
  801680:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  801687:	e8 38 01 00 00       	call   8017c4 <_panic>
        return envid;
	//panic("fork not implemented");
}
  80168c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80168f:	83 c4 3c             	add    $0x3c,%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5f                   	pop    %edi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 24             	sub    $0x24,%esp
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8016a1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  8016a3:	89 da                	mov    %ebx,%edx
  8016a5:	c1 ea 0c             	shr    $0xc,%edx
  8016a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  8016af:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8016b3:	74 08                	je     8016bd <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  8016b5:	f7 c2 05 08 00 00    	test   $0x805,%edx
  8016bb:	75 1c                	jne    8016d9 <pgfault+0x42>
           panic("pgfault error");
  8016bd:	c7 44 24 08 e4 1e 80 	movl   $0x801ee4,0x8(%esp)
  8016c4:	00 
  8016c5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8016cc:	00 
  8016cd:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  8016d4:	e8 eb 00 00 00       	call   8017c4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016d9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016e0:	00 
  8016e1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8016e8:	00 
  8016e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f0:	e8 91 fb ff ff       	call   801286 <sys_page_alloc>
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	79 20                	jns    801719 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  8016f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016fd:	c7 44 24 08 f2 1e 80 	movl   $0x801ef2,0x8(%esp)
  801704:	00 
  801705:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80170c:	00 
  80170d:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  801714:	e8 ab 00 00 00       	call   8017c4 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  801719:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80171f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801726:	00 
  801727:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80172b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801732:	e8 be f5 ff ff       	call   800cf5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  801737:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80173e:	00 
  80173f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801743:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80174a:	00 
  80174b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801752:	00 
  801753:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80175a:	e8 b9 fa ff ff       	call   801218 <sys_page_map>
  80175f:	85 c0                	test   %eax,%eax
  801761:	79 20                	jns    801783 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801763:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801767:	c7 44 24 08 05 1f 80 	movl   $0x801f05,0x8(%esp)
  80176e:	00 
  80176f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801776:	00 
  801777:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  80177e:	e8 41 00 00 00       	call   8017c4 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801783:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80178a:	00 
  80178b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801792:	e8 15 fa ff ff       	call   8011ac <sys_page_unmap>
  801797:	85 c0                	test   %eax,%eax
  801799:	79 20                	jns    8017bb <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80179b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80179f:	c7 44 24 08 16 1f 80 	movl   $0x801f16,0x8(%esp)
  8017a6:	00 
  8017a7:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8017ae:	00 
  8017af:	c7 04 24 85 1e 80 00 	movl   $0x801e85,(%esp)
  8017b6:	e8 09 00 00 00       	call   8017c4 <_panic>
	//panic("pgfault not implemented");
}
  8017bb:	83 c4 24             	add    $0x24,%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5d                   	pop    %ebp
  8017c0:	c3                   	ret    
  8017c1:	00 00                	add    %al,(%eax)
	...

008017c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	56                   	push   %esi
  8017c8:	53                   	push   %ebx
  8017c9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8017cc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8017cf:	a1 08 20 80 00       	mov    0x802008,%eax
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	74 10                	je     8017e8 <_panic+0x24>
		cprintf("%s: ", argv0);
  8017d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dc:	c7 04 24 29 1f 80 00 	movl   $0x801f29,(%esp)
  8017e3:	e8 f1 e9 ff ff       	call   8001d9 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8017e8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8017ee:	e8 82 fb ff ff       	call   801375 <sys_getenvid>
  8017f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8017fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801801:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801805:	89 44 24 04          	mov    %eax,0x4(%esp)
  801809:	c7 04 24 30 1f 80 00 	movl   $0x801f30,(%esp)
  801810:	e8 c4 e9 ff ff       	call   8001d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801815:	89 74 24 04          	mov    %esi,0x4(%esp)
  801819:	8b 45 10             	mov    0x10(%ebp),%eax
  80181c:	89 04 24             	mov    %eax,(%esp)
  80181f:	e8 54 e9 ff ff       	call   800178 <vcprintf>
	cprintf("\n");
  801824:	c7 04 24 2e 1f 80 00 	movl   $0x801f2e,(%esp)
  80182b:	e8 a9 e9 ff ff       	call   8001d9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801830:	cc                   	int3   
  801831:	eb fd                	jmp    801830 <_panic+0x6c>
	...

00801834 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80183a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801841:	75 30                	jne    801873 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801843:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80184a:	00 
  80184b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801852:	ee 
  801853:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80185a:	e8 27 fa ff ff       	call   801286 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80185f:	c7 44 24 04 80 18 80 	movl   $0x801880,0x4(%esp)
  801866:	00 
  801867:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186e:	e8 61 f8 ff ff       	call   8010d4 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    
  80187d:	00 00                	add    %al,(%eax)
	...

00801880 <_pgfault_upcall>:
  801880:	54                   	push   %esp
  801881:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801886:	ff d0                	call   *%eax
  801888:	83 c4 04             	add    $0x4,%esp
  80188b:	8b 44 24 28          	mov    0x28(%esp),%eax
  80188f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801893:	83 e9 04             	sub    $0x4,%ecx
  801896:	89 01                	mov    %eax,(%ecx)
  801898:	89 4c 24 30          	mov    %ecx,0x30(%esp)
  80189c:	83 c4 08             	add    $0x8,%esp
  80189f:	61                   	popa   
  8018a0:	83 c4 04             	add    $0x4,%esp
  8018a3:	9d                   	popf   
  8018a4:	5c                   	pop    %esp
  8018a5:	c3                   	ret    
	...

008018b0 <__udivdi3>:
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	83 ec 10             	sub    $0x10,%esp
  8018b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8018be:	8b 75 10             	mov    0x10(%ebp),%esi
  8018c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8018c9:	75 35                	jne    801900 <__udivdi3+0x50>
  8018cb:	39 fe                	cmp    %edi,%esi
  8018cd:	77 61                	ja     801930 <__udivdi3+0x80>
  8018cf:	85 f6                	test   %esi,%esi
  8018d1:	75 0b                	jne    8018de <__udivdi3+0x2e>
  8018d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d8:	31 d2                	xor    %edx,%edx
  8018da:	f7 f6                	div    %esi
  8018dc:	89 c6                	mov    %eax,%esi
  8018de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8018e1:	31 d2                	xor    %edx,%edx
  8018e3:	89 f8                	mov    %edi,%eax
  8018e5:	f7 f6                	div    %esi
  8018e7:	89 c7                	mov    %eax,%edi
  8018e9:	89 c8                	mov    %ecx,%eax
  8018eb:	f7 f6                	div    %esi
  8018ed:	89 c1                	mov    %eax,%ecx
  8018ef:	89 fa                	mov    %edi,%edx
  8018f1:	89 c8                	mov    %ecx,%eax
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	5e                   	pop    %esi
  8018f7:	5f                   	pop    %edi
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    
  8018fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801900:	39 f8                	cmp    %edi,%eax
  801902:	77 1c                	ja     801920 <__udivdi3+0x70>
  801904:	0f bd d0             	bsr    %eax,%edx
  801907:	83 f2 1f             	xor    $0x1f,%edx
  80190a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80190d:	75 39                	jne    801948 <__udivdi3+0x98>
  80190f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801912:	0f 86 a0 00 00 00    	jbe    8019b8 <__udivdi3+0x108>
  801918:	39 f8                	cmp    %edi,%eax
  80191a:	0f 82 98 00 00 00    	jb     8019b8 <__udivdi3+0x108>
  801920:	31 ff                	xor    %edi,%edi
  801922:	31 c9                	xor    %ecx,%ecx
  801924:	89 c8                	mov    %ecx,%eax
  801926:	89 fa                	mov    %edi,%edx
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	5e                   	pop    %esi
  80192c:	5f                   	pop    %edi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    
  80192f:	90                   	nop
  801930:	89 d1                	mov    %edx,%ecx
  801932:	89 fa                	mov    %edi,%edx
  801934:	89 c8                	mov    %ecx,%eax
  801936:	31 ff                	xor    %edi,%edi
  801938:	f7 f6                	div    %esi
  80193a:	89 c1                	mov    %eax,%ecx
  80193c:	89 fa                	mov    %edi,%edx
  80193e:	89 c8                	mov    %ecx,%eax
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	5e                   	pop    %esi
  801944:	5f                   	pop    %edi
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    
  801947:	90                   	nop
  801948:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80194c:	89 f2                	mov    %esi,%edx
  80194e:	d3 e0                	shl    %cl,%eax
  801950:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801953:	b8 20 00 00 00       	mov    $0x20,%eax
  801958:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80195b:	89 c1                	mov    %eax,%ecx
  80195d:	d3 ea                	shr    %cl,%edx
  80195f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801963:	0b 55 ec             	or     -0x14(%ebp),%edx
  801966:	d3 e6                	shl    %cl,%esi
  801968:	89 c1                	mov    %eax,%ecx
  80196a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80196d:	89 fe                	mov    %edi,%esi
  80196f:	d3 ee                	shr    %cl,%esi
  801971:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801975:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801978:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80197b:	d3 e7                	shl    %cl,%edi
  80197d:	89 c1                	mov    %eax,%ecx
  80197f:	d3 ea                	shr    %cl,%edx
  801981:	09 d7                	or     %edx,%edi
  801983:	89 f2                	mov    %esi,%edx
  801985:	89 f8                	mov    %edi,%eax
  801987:	f7 75 ec             	divl   -0x14(%ebp)
  80198a:	89 d6                	mov    %edx,%esi
  80198c:	89 c7                	mov    %eax,%edi
  80198e:	f7 65 e8             	mull   -0x18(%ebp)
  801991:	39 d6                	cmp    %edx,%esi
  801993:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801996:	72 30                	jb     8019c8 <__udivdi3+0x118>
  801998:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80199b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80199f:	d3 e2                	shl    %cl,%edx
  8019a1:	39 c2                	cmp    %eax,%edx
  8019a3:	73 05                	jae    8019aa <__udivdi3+0xfa>
  8019a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8019a8:	74 1e                	je     8019c8 <__udivdi3+0x118>
  8019aa:	89 f9                	mov    %edi,%ecx
  8019ac:	31 ff                	xor    %edi,%edi
  8019ae:	e9 71 ff ff ff       	jmp    801924 <__udivdi3+0x74>
  8019b3:	90                   	nop
  8019b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019b8:	31 ff                	xor    %edi,%edi
  8019ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  8019bf:	e9 60 ff ff ff       	jmp    801924 <__udivdi3+0x74>
  8019c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8019cb:	31 ff                	xor    %edi,%edi
  8019cd:	89 c8                	mov    %ecx,%eax
  8019cf:	89 fa                	mov    %edi,%edx
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	5e                   	pop    %esi
  8019d5:	5f                   	pop    %edi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    
	...

008019e0 <__umoddi3>:
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	57                   	push   %edi
  8019e4:	56                   	push   %esi
  8019e5:	83 ec 20             	sub    $0x20,%esp
  8019e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8019eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8019f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f4:	85 d2                	test   %edx,%edx
  8019f6:	89 c8                	mov    %ecx,%eax
  8019f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8019fb:	75 13                	jne    801a10 <__umoddi3+0x30>
  8019fd:	39 f7                	cmp    %esi,%edi
  8019ff:	76 3f                	jbe    801a40 <__umoddi3+0x60>
  801a01:	89 f2                	mov    %esi,%edx
  801a03:	f7 f7                	div    %edi
  801a05:	89 d0                	mov    %edx,%eax
  801a07:	31 d2                	xor    %edx,%edx
  801a09:	83 c4 20             	add    $0x20,%esp
  801a0c:	5e                   	pop    %esi
  801a0d:	5f                   	pop    %edi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    
  801a10:	39 f2                	cmp    %esi,%edx
  801a12:	77 4c                	ja     801a60 <__umoddi3+0x80>
  801a14:	0f bd ca             	bsr    %edx,%ecx
  801a17:	83 f1 1f             	xor    $0x1f,%ecx
  801a1a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a1d:	75 51                	jne    801a70 <__umoddi3+0x90>
  801a1f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801a22:	0f 87 e0 00 00 00    	ja     801b08 <__umoddi3+0x128>
  801a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2b:	29 f8                	sub    %edi,%eax
  801a2d:	19 d6                	sbb    %edx,%esi
  801a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a35:	89 f2                	mov    %esi,%edx
  801a37:	83 c4 20             	add    $0x20,%esp
  801a3a:	5e                   	pop    %esi
  801a3b:	5f                   	pop    %edi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    
  801a3e:	66 90                	xchg   %ax,%ax
  801a40:	85 ff                	test   %edi,%edi
  801a42:	75 0b                	jne    801a4f <__umoddi3+0x6f>
  801a44:	b8 01 00 00 00       	mov    $0x1,%eax
  801a49:	31 d2                	xor    %edx,%edx
  801a4b:	f7 f7                	div    %edi
  801a4d:	89 c7                	mov    %eax,%edi
  801a4f:	89 f0                	mov    %esi,%eax
  801a51:	31 d2                	xor    %edx,%edx
  801a53:	f7 f7                	div    %edi
  801a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a58:	f7 f7                	div    %edi
  801a5a:	eb a9                	jmp    801a05 <__umoddi3+0x25>
  801a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a60:	89 c8                	mov    %ecx,%eax
  801a62:	89 f2                	mov    %esi,%edx
  801a64:	83 c4 20             	add    $0x20,%esp
  801a67:	5e                   	pop    %esi
  801a68:	5f                   	pop    %edi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    
  801a6b:	90                   	nop
  801a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801a74:	d3 e2                	shl    %cl,%edx
  801a76:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801a79:	ba 20 00 00 00       	mov    $0x20,%edx
  801a7e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801a81:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a84:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801a88:	89 fa                	mov    %edi,%edx
  801a8a:	d3 ea                	shr    %cl,%edx
  801a8c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801a90:	0b 55 f4             	or     -0xc(%ebp),%edx
  801a93:	d3 e7                	shl    %cl,%edi
  801a95:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801a99:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801a9c:	89 f2                	mov    %esi,%edx
  801a9e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801aa1:	89 c7                	mov    %eax,%edi
  801aa3:	d3 ea                	shr    %cl,%edx
  801aa5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801aa9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801aac:	89 c2                	mov    %eax,%edx
  801aae:	d3 e6                	shl    %cl,%esi
  801ab0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ab4:	d3 ea                	shr    %cl,%edx
  801ab6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801aba:	09 d6                	or     %edx,%esi
  801abc:	89 f0                	mov    %esi,%eax
  801abe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801ac1:	d3 e7                	shl    %cl,%edi
  801ac3:	89 f2                	mov    %esi,%edx
  801ac5:	f7 75 f4             	divl   -0xc(%ebp)
  801ac8:	89 d6                	mov    %edx,%esi
  801aca:	f7 65 e8             	mull   -0x18(%ebp)
  801acd:	39 d6                	cmp    %edx,%esi
  801acf:	72 2b                	jb     801afc <__umoddi3+0x11c>
  801ad1:	39 c7                	cmp    %eax,%edi
  801ad3:	72 23                	jb     801af8 <__umoddi3+0x118>
  801ad5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ad9:	29 c7                	sub    %eax,%edi
  801adb:	19 d6                	sbb    %edx,%esi
  801add:	89 f0                	mov    %esi,%eax
  801adf:	89 f2                	mov    %esi,%edx
  801ae1:	d3 ef                	shr    %cl,%edi
  801ae3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ae7:	d3 e0                	shl    %cl,%eax
  801ae9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801aed:	09 f8                	or     %edi,%eax
  801aef:	d3 ea                	shr    %cl,%edx
  801af1:	83 c4 20             	add    $0x20,%esp
  801af4:	5e                   	pop    %esi
  801af5:	5f                   	pop    %edi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    
  801af8:	39 d6                	cmp    %edx,%esi
  801afa:	75 d9                	jne    801ad5 <__umoddi3+0xf5>
  801afc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801aff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801b02:	eb d1                	jmp    801ad5 <__umoddi3+0xf5>
  801b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b08:	39 f2                	cmp    %esi,%edx
  801b0a:	0f 82 18 ff ff ff    	jb     801a28 <__umoddi3+0x48>
  801b10:	e9 1d ff ff ff       	jmp    801a32 <__umoddi3+0x52>
