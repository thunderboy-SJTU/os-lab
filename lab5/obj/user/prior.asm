
obj/user/prior.debug:     file format elf32-i386


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
  800048:	e8 a5 14 00 00       	call   8014f2 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 29                	je     80007a <umain+0x3a>
        sys_env_set_prior(pid,PRIOR_HIGH);
  800051:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  800058:	00 
  800059:	89 04 24             	mov    %eax,(%esp)
  80005c:	e8 5b 0f 00 00       	call   800fbc <sys_env_set_prior>
        if((pid = fork())!= 0)
  800061:	e8 8c 14 00 00       	call   8014f2 <fork>
  800066:	85 c0                	test   %eax,%eax
  800068:	74 10                	je     80007a <umain+0x3a>
           sys_env_set_prior(pid,PRIOR_LOW);
  80006a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800071:	00 
  800072:	89 04 24             	mov    %eax,(%esp)
  800075:	e8 42 0f 00 00       	call   800fbc <sys_env_set_prior>
    }
    sys_yield();
  80007a:	e8 21 13 00 00       	call   8013a0 <sys_yield>
    env = (struct Env*)envs + ENVX(sys_getenvid());
  80007f:	e8 9e 13 00 00       	call   801422 <sys_getenvid>
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
  80009f:	e8 7e 13 00 00       	call   801422 <sys_getenvid>
  8000a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ac:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  8000b3:	e8 29 01 00 00       	call   8001e1 <cprintf>
  8000b8:	eb 3f                	jmp    8000f9 <umain+0xb9>
       if(env->env_prior == PRIOR_MIDD)
  8000ba:	83 fe 02             	cmp    $0x2,%esi
  8000bd:	75 1c                	jne    8000db <umain+0x9b>
          cprintf("[%08x] MIDD PRIOR %d iteration\n",sys_getenvid(),i);
  8000bf:	90                   	nop
  8000c0:	e8 5d 13 00 00       	call   801422 <sys_getenvid>
  8000c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000cd:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  8000d4:	e8 08 01 00 00       	call   8001e1 <cprintf>
  8000d9:	eb 1e                	jmp    8000f9 <umain+0xb9>
       if(env->env_prior == PRIOR_LOW)
  8000db:	83 fe 01             	cmp    $0x1,%esi
  8000de:	75 19                	jne    8000f9 <umain+0xb9>
          cprintf("[%08x] LOW PRIOR %d iteration\n",sys_getenvid(),i);
  8000e0:	e8 3d 13 00 00       	call   801422 <sys_getenvid>
  8000e5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ed:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  8000f4:	e8 e8 00 00 00       	call   8001e1 <cprintf>
       sys_yield();
  8000f9:	e8 a2 12 00 00       	call   8013a0 <sys_yield>
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
  800122:	e8 fb 12 00 00       	call   801422 <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	89 c2                	mov    %eax,%edx
  80012e:	c1 e2 07             	shl    $0x7,%edx
  800131:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800138:	a3 04 40 80 00       	mov    %eax,0x804004
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
	close_all();
  80016a:	e8 ec 1b 00 00       	call   801d5b <close_all>
	sys_env_destroy(0);
  80016f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800176:	e8 e7 12 00 00       	call   801462 <sys_env_destroy>
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    
  80017d:	00 00                	add    %al,(%eax)
	...

00800180 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800189:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800190:	00 00 00 
	b.cnt = 0;
  800193:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	c7 04 24 fb 01 80 00 	movl   $0x8001fb,(%esp)
  8001bc:	e8 cb 01 00 00       	call   80038c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 63 0d 00 00       	call   800f3c <sys_cputs>

	return b.cnt;
}
  8001d9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001e7:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 87 ff ff ff       	call   800180 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	53                   	push   %ebx
  8001ff:	83 ec 14             	sub    $0x14,%esp
  800202:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800205:	8b 03                	mov    (%ebx),%eax
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80020e:	83 c0 01             	add    $0x1,%eax
  800211:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800213:	3d ff 00 00 00       	cmp    $0xff,%eax
  800218:	75 19                	jne    800233 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80021a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800221:	00 
  800222:	8d 43 08             	lea    0x8(%ebx),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	e8 0f 0d 00 00       	call   800f3c <sys_cputs>
		b->idx = 0;
  80022d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800233:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5d                   	pop    %ebp
  80023c:	c3                   	ret    
  80023d:	00 00                	add    %al,(%eax)
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
  8002af:	e8 9c 20 00 00       	call   802350 <__udivdi3>
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
  800317:	e8 64 21 00 00       	call   802480 <__umoddi3>
  80031c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800320:	0f be 80 29 26 80 00 	movsbl 0x802629(%eax),%eax
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
  80040a:	ff 24 95 00 28 80 00 	jmp    *0x802800(,%edx,4)
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
  8004c2:	83 f8 0f             	cmp    $0xf,%eax
  8004c5:	7f 0b                	jg     8004d2 <vprintfmt+0x146>
  8004c7:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	75 26                	jne    8004f8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	c7 44 24 08 3a 26 80 	movl   $0x80263a,0x8(%esp)
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
  8004fc:	c7 44 24 08 43 26 80 	movl   $0x802643,0x8(%esp)
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
  80053a:	be 46 26 80 00       	mov    $0x802646,%esi
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
  8007e4:	e8 67 1b 00 00       	call   802350 <__udivdi3>
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
  800830:	e8 4b 1c 00 00       	call   802480 <__umoddi3>
  800835:	89 74 24 04          	mov    %esi,0x4(%esp)
  800839:	0f be 80 29 26 80 00 	movsbl 0x802629(%eax),%eax
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
  8008e5:	c7 44 24 0c 60 27 80 	movl   $0x802760,0xc(%esp)
  8008ec:	00 
  8008ed:	c7 44 24 08 43 26 80 	movl   $0x802643,0x8(%esp)
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
  80091b:	c7 44 24 0c 98 27 80 	movl   $0x802798,0xc(%esp)
  800922:	00 
  800923:	c7 44 24 08 43 26 80 	movl   $0x802643,0x8(%esp)
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
  8009af:	e8 cc 1a 00 00       	call   802480 <__umoddi3>
  8009b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b8:	0f be 80 29 26 80 00 	movsbl 0x802629(%eax),%eax
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
  8009f1:	e8 8a 1a 00 00       	call   802480 <__umoddi3>
  8009f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fa:	0f be 80 29 26 80 00 	movsbl 0x802629(%eax),%eax
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

00800f7b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 08             	sub    $0x8,%esp
  800f81:	89 1c 24             	mov    %ebx,(%esp)
  800f84:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f88:	b8 10 00 00 00       	mov    $0x10,%eax
  800f8d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f96:	8b 55 08             	mov    0x8(%ebp),%edx
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
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800fb1:	8b 1c 24             	mov    (%esp),%ebx
  800fb4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb8:	89 ec                	mov    %ebp,%esp
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 28             	sub    $0x28,%esp
  800fc2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fc5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd8:	89 df                	mov    %ebx,%edi
  800fda:	51                   	push   %ecx
  800fdb:	52                   	push   %edx
  800fdc:	53                   	push   %ebx
  800fdd:	54                   	push   %esp
  800fde:	55                   	push   %ebp
  800fdf:	56                   	push   %esi
  800fe0:	57                   	push   %edi
  800fe1:	54                   	push   %esp
  800fe2:	5d                   	pop    %ebp
  800fe3:	8d 35 eb 0f 80 00    	lea    0x800feb,%esi
  800fe9:	0f 34                	sysenter 
  800feb:	5f                   	pop    %edi
  800fec:	5e                   	pop    %esi
  800fed:	5d                   	pop    %ebp
  800fee:	5c                   	pop    %esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5a                   	pop    %edx
  800ff1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	7e 28                	jle    80101e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffa:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  801019:	e8 26 11 00 00       	call   802144 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80101e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801021:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801024:	89 ec                	mov    %ebp,%esp
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 08             	sub    $0x8,%esp
  80102e:	89 1c 24             	mov    %ebx,(%esp)
  801031:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801035:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103a:	b8 11 00 00 00       	mov    $0x11,%eax
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	89 cb                	mov    %ecx,%ebx
  801044:	89 cf                	mov    %ecx,%edi
  801046:	51                   	push   %ecx
  801047:	52                   	push   %edx
  801048:	53                   	push   %ebx
  801049:	54                   	push   %esp
  80104a:	55                   	push   %ebp
  80104b:	56                   	push   %esi
  80104c:	57                   	push   %edi
  80104d:	54                   	push   %esp
  80104e:	5d                   	pop    %ebp
  80104f:	8d 35 57 10 80 00    	lea    0x801057,%esi
  801055:	0f 34                	sysenter 
  801057:	5f                   	pop    %edi
  801058:	5e                   	pop    %esi
  801059:	5d                   	pop    %ebp
  80105a:	5c                   	pop    %esp
  80105b:	5b                   	pop    %ebx
  80105c:	5a                   	pop    %edx
  80105d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80105e:	8b 1c 24             	mov    (%esp),%ebx
  801061:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801065:	89 ec                	mov    %ebp,%esp
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 28             	sub    $0x28,%esp
  80106f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801072:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801075:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80107f:	8b 55 08             	mov    0x8(%ebp),%edx
  801082:	89 cb                	mov    %ecx,%ebx
  801084:	89 cf                	mov    %ecx,%edi
  801086:	51                   	push   %ecx
  801087:	52                   	push   %edx
  801088:	53                   	push   %ebx
  801089:	54                   	push   %esp
  80108a:	55                   	push   %ebp
  80108b:	56                   	push   %esi
  80108c:	57                   	push   %edi
  80108d:	54                   	push   %esp
  80108e:	5d                   	pop    %ebp
  80108f:	8d 35 97 10 80 00    	lea    0x801097,%esi
  801095:	0f 34                	sysenter 
  801097:	5f                   	pop    %edi
  801098:	5e                   	pop    %esi
  801099:	5d                   	pop    %ebp
  80109a:	5c                   	pop    %esp
  80109b:	5b                   	pop    %ebx
  80109c:	5a                   	pop    %edx
  80109d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	7e 28                	jle    8010ca <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a6:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8010ad:	00 
  8010ae:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010bd:	00 
  8010be:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  8010c5:	e8 7a 10 00 00       	call   802144 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010ca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d0:	89 ec                	mov    %ebp,%esp
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	89 1c 24             	mov    %ebx,(%esp)
  8010dd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ef:	8b 55 08             	mov    0x8(%ebp),%edx
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

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80110a:	8b 1c 24             	mov    (%esp),%ebx
  80110d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801111:	89 ec                	mov    %ebp,%esp
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 28             	sub    $0x28,%esp
  80111b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80111e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801121:	bb 00 00 00 00       	mov    $0x0,%ebx
  801126:	b8 0b 00 00 00       	mov    $0xb,%eax
  80112b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112e:	8b 55 08             	mov    0x8(%ebp),%edx
  801131:	89 df                	mov    %ebx,%edi
  801133:	51                   	push   %ecx
  801134:	52                   	push   %edx
  801135:	53                   	push   %ebx
  801136:	54                   	push   %esp
  801137:	55                   	push   %ebp
  801138:	56                   	push   %esi
  801139:	57                   	push   %edi
  80113a:	54                   	push   %esp
  80113b:	5d                   	pop    %ebp
  80113c:	8d 35 44 11 80 00    	lea    0x801144,%esi
  801142:	0f 34                	sysenter 
  801144:	5f                   	pop    %edi
  801145:	5e                   	pop    %esi
  801146:	5d                   	pop    %ebp
  801147:	5c                   	pop    %esp
  801148:	5b                   	pop    %ebx
  801149:	5a                   	pop    %edx
  80114a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	7e 28                	jle    801177 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801153:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80115a:	00 
  80115b:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  801162:	00 
  801163:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80116a:	00 
  80116b:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  801172:	e8 cd 0f 00 00       	call   802144 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801177:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80117a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80117d:	89 ec                	mov    %ebp,%esp
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	83 ec 28             	sub    $0x28,%esp
  801187:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80118a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	b8 0a 00 00 00       	mov    $0xa,%eax
  801197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119a:	8b 55 08             	mov    0x8(%ebp),%edx
  80119d:	89 df                	mov    %ebx,%edi
  80119f:	51                   	push   %ecx
  8011a0:	52                   	push   %edx
  8011a1:	53                   	push   %ebx
  8011a2:	54                   	push   %esp
  8011a3:	55                   	push   %ebp
  8011a4:	56                   	push   %esi
  8011a5:	57                   	push   %edi
  8011a6:	54                   	push   %esp
  8011a7:	5d                   	pop    %ebp
  8011a8:	8d 35 b0 11 80 00    	lea    0x8011b0,%esi
  8011ae:	0f 34                	sysenter 
  8011b0:	5f                   	pop    %edi
  8011b1:	5e                   	pop    %esi
  8011b2:	5d                   	pop    %ebp
  8011b3:	5c                   	pop    %esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5a                   	pop    %edx
  8011b6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	7e 28                	jle    8011e3 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011bf:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011c6:	00 
  8011c7:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  8011ce:	00 
  8011cf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011d6:	00 
  8011d7:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  8011de:	e8 61 0f 00 00       	call   802144 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e9:	89 ec                	mov    %ebp,%esp
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	83 ec 28             	sub    $0x28,%esp
  8011f3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011f6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801206:	8b 55 08             	mov    0x8(%ebp),%edx
  801209:	89 df                	mov    %ebx,%edi
  80120b:	51                   	push   %ecx
  80120c:	52                   	push   %edx
  80120d:	53                   	push   %ebx
  80120e:	54                   	push   %esp
  80120f:	55                   	push   %ebp
  801210:	56                   	push   %esi
  801211:	57                   	push   %edi
  801212:	54                   	push   %esp
  801213:	5d                   	pop    %ebp
  801214:	8d 35 1c 12 80 00    	lea    0x80121c,%esi
  80121a:	0f 34                	sysenter 
  80121c:	5f                   	pop    %edi
  80121d:	5e                   	pop    %esi
  80121e:	5d                   	pop    %ebp
  80121f:	5c                   	pop    %esp
  801220:	5b                   	pop    %ebx
  801221:	5a                   	pop    %edx
  801222:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801223:	85 c0                	test   %eax,%eax
  801225:	7e 28                	jle    80124f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801227:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801232:	00 
  801233:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  80123a:	00 
  80123b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801242:	00 
  801243:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  80124a:	e8 f5 0e 00 00       	call   802144 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80124f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801252:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801255:	89 ec                	mov    %ebp,%esp
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 28             	sub    $0x28,%esp
  80125f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801262:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126a:	b8 07 00 00 00       	mov    $0x7,%eax
  80126f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801272:	8b 55 08             	mov    0x8(%ebp),%edx
  801275:	89 df                	mov    %ebx,%edi
  801277:	51                   	push   %ecx
  801278:	52                   	push   %edx
  801279:	53                   	push   %ebx
  80127a:	54                   	push   %esp
  80127b:	55                   	push   %ebp
  80127c:	56                   	push   %esi
  80127d:	57                   	push   %edi
  80127e:	54                   	push   %esp
  80127f:	5d                   	pop    %ebp
  801280:	8d 35 88 12 80 00    	lea    0x801288,%esi
  801286:	0f 34                	sysenter 
  801288:	5f                   	pop    %edi
  801289:	5e                   	pop    %esi
  80128a:	5d                   	pop    %ebp
  80128b:	5c                   	pop    %esp
  80128c:	5b                   	pop    %ebx
  80128d:	5a                   	pop    %edx
  80128e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80128f:	85 c0                	test   %eax,%eax
  801291:	7e 28                	jle    8012bb <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801293:	89 44 24 10          	mov    %eax,0x10(%esp)
  801297:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80129e:	00 
  80129f:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  8012a6:	00 
  8012a7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012ae:	00 
  8012af:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  8012b6:	e8 89 0e 00 00       	call   802144 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012bb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012be:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012c1:	89 ec                	mov    %ebp,%esp
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	83 ec 28             	sub    $0x28,%esp
  8012cb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012ce:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012d1:	8b 7d 18             	mov    0x18(%ebp),%edi
  8012d4:	0b 7d 14             	or     0x14(%ebp),%edi
  8012d7:	b8 06 00 00 00       	mov    $0x6,%eax
  8012dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e5:	51                   	push   %ecx
  8012e6:	52                   	push   %edx
  8012e7:	53                   	push   %ebx
  8012e8:	54                   	push   %esp
  8012e9:	55                   	push   %ebp
  8012ea:	56                   	push   %esi
  8012eb:	57                   	push   %edi
  8012ec:	54                   	push   %esp
  8012ed:	5d                   	pop    %ebp
  8012ee:	8d 35 f6 12 80 00    	lea    0x8012f6,%esi
  8012f4:	0f 34                	sysenter 
  8012f6:	5f                   	pop    %edi
  8012f7:	5e                   	pop    %esi
  8012f8:	5d                   	pop    %ebp
  8012f9:	5c                   	pop    %esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5a                   	pop    %edx
  8012fc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	7e 28                	jle    801329 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801301:	89 44 24 10          	mov    %eax,0x10(%esp)
  801305:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80130c:	00 
  80130d:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  801314:	00 
  801315:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80131c:	00 
  80131d:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  801324:	e8 1b 0e 00 00       	call   802144 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801329:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80132c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80132f:	89 ec                	mov    %ebp,%esp
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	83 ec 28             	sub    $0x28,%esp
  801339:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80133c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80133f:	bf 00 00 00 00       	mov    $0x0,%edi
  801344:	b8 05 00 00 00       	mov    $0x5,%eax
  801349:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134f:	8b 55 08             	mov    0x8(%ebp),%edx
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80136a:	85 c0                	test   %eax,%eax
  80136c:	7e 28                	jle    801396 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801372:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801379:	00 
  80137a:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  801381:	00 
  801382:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801389:	00 
  80138a:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  801391:	e8 ae 0d 00 00       	call   802144 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801396:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801399:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139c:	89 ec                	mov    %ebp,%esp
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    

008013a0 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	89 1c 24             	mov    %ebx,(%esp)
  8013a9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013b7:	89 d1                	mov    %edx,%ecx
  8013b9:	89 d3                	mov    %edx,%ebx
  8013bb:	89 d7                	mov    %edx,%edi
  8013bd:	51                   	push   %ecx
  8013be:	52                   	push   %edx
  8013bf:	53                   	push   %ebx
  8013c0:	54                   	push   %esp
  8013c1:	55                   	push   %ebp
  8013c2:	56                   	push   %esi
  8013c3:	57                   	push   %edi
  8013c4:	54                   	push   %esp
  8013c5:	5d                   	pop    %ebp
  8013c6:	8d 35 ce 13 80 00    	lea    0x8013ce,%esi
  8013cc:	0f 34                	sysenter 
  8013ce:	5f                   	pop    %edi
  8013cf:	5e                   	pop    %esi
  8013d0:	5d                   	pop    %ebp
  8013d1:	5c                   	pop    %esp
  8013d2:	5b                   	pop    %ebx
  8013d3:	5a                   	pop    %edx
  8013d4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8013d5:	8b 1c 24             	mov    (%esp),%ebx
  8013d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013dc:	89 ec                	mov    %ebp,%esp
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	89 1c 24             	mov    %ebx,(%esp)
  8013e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8013f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fd:	89 df                	mov    %ebx,%edi
  8013ff:	51                   	push   %ecx
  801400:	52                   	push   %edx
  801401:	53                   	push   %ebx
  801402:	54                   	push   %esp
  801403:	55                   	push   %ebp
  801404:	56                   	push   %esi
  801405:	57                   	push   %edi
  801406:	54                   	push   %esp
  801407:	5d                   	pop    %ebp
  801408:	8d 35 10 14 80 00    	lea    0x801410,%esi
  80140e:	0f 34                	sysenter 
  801410:	5f                   	pop    %edi
  801411:	5e                   	pop    %esi
  801412:	5d                   	pop    %ebp
  801413:	5c                   	pop    %esp
  801414:	5b                   	pop    %ebx
  801415:	5a                   	pop    %edx
  801416:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801417:	8b 1c 24             	mov    (%esp),%ebx
  80141a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80141e:	89 ec                	mov    %ebp,%esp
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	89 1c 24             	mov    %ebx,(%esp)
  80142b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	b8 02 00 00 00       	mov    $0x2,%eax
  801439:	89 d1                	mov    %edx,%ecx
  80143b:	89 d3                	mov    %edx,%ebx
  80143d:	89 d7                	mov    %edx,%edi
  80143f:	51                   	push   %ecx
  801440:	52                   	push   %edx
  801441:	53                   	push   %ebx
  801442:	54                   	push   %esp
  801443:	55                   	push   %ebp
  801444:	56                   	push   %esi
  801445:	57                   	push   %edi
  801446:	54                   	push   %esp
  801447:	5d                   	pop    %ebp
  801448:	8d 35 50 14 80 00    	lea    0x801450,%esi
  80144e:	0f 34                	sysenter 
  801450:	5f                   	pop    %edi
  801451:	5e                   	pop    %esi
  801452:	5d                   	pop    %ebp
  801453:	5c                   	pop    %esp
  801454:	5b                   	pop    %ebx
  801455:	5a                   	pop    %edx
  801456:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801457:	8b 1c 24             	mov    (%esp),%ebx
  80145a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80145e:	89 ec                	mov    %ebp,%esp
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 28             	sub    $0x28,%esp
  801468:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80146b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80146e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801473:	b8 03 00 00 00       	mov    $0x3,%eax
  801478:	8b 55 08             	mov    0x8(%ebp),%edx
  80147b:	89 cb                	mov    %ecx,%ebx
  80147d:	89 cf                	mov    %ecx,%edi
  80147f:	51                   	push   %ecx
  801480:	52                   	push   %edx
  801481:	53                   	push   %ebx
  801482:	54                   	push   %esp
  801483:	55                   	push   %ebp
  801484:	56                   	push   %esi
  801485:	57                   	push   %edi
  801486:	54                   	push   %esp
  801487:	5d                   	pop    %ebp
  801488:	8d 35 90 14 80 00    	lea    0x801490,%esi
  80148e:	0f 34                	sysenter 
  801490:	5f                   	pop    %edi
  801491:	5e                   	pop    %esi
  801492:	5d                   	pop    %ebp
  801493:	5c                   	pop    %esp
  801494:	5b                   	pop    %ebx
  801495:	5a                   	pop    %edx
  801496:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801497:	85 c0                	test   %eax,%eax
  801499:	7e 28                	jle    8014c3 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80149b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80149f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014a6:	00 
  8014a7:	c7 44 24 08 a0 29 80 	movl   $0x8029a0,0x8(%esp)
  8014ae:	00 
  8014af:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014b6:	00 
  8014b7:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  8014be:	e8 81 0c 00 00       	call   802144 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014c3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014c6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014c9:	89 ec                	mov    %ebp,%esp
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    
  8014cd:	00 00                	add    %al,(%eax)
	...

008014d0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014d6:	c7 44 24 08 cb 29 80 	movl   $0x8029cb,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  8014ed:	e8 52 0c 00 00       	call   802144 <_panic>

008014f2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	57                   	push   %edi
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  8014fb:	c7 04 24 47 17 80 00 	movl   $0x801747,(%esp)
  801502:	e8 95 0c 00 00       	call   80219c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801507:	ba 08 00 00 00       	mov    $0x8,%edx
  80150c:	89 d0                	mov    %edx,%eax
  80150e:	cd 30                	int    $0x30
  801510:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801513:	85 c0                	test   %eax,%eax
  801515:	79 20                	jns    801537 <fork+0x45>
		panic("sys_exofork: %e", envid);
  801517:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80151b:	c7 44 24 08 ec 29 80 	movl   $0x8029ec,0x8(%esp)
  801522:	00 
  801523:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80152a:	00 
  80152b:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  801532:	e8 0d 0c 00 00       	call   802144 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801537:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80153c:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801541:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  801546:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80154a:	75 20                	jne    80156c <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80154c:	e8 d1 fe ff ff       	call   801422 <sys_getenvid>
  801551:	25 ff 03 00 00       	and    $0x3ff,%eax
  801556:	89 c2                	mov    %eax,%edx
  801558:	c1 e2 07             	shl    $0x7,%edx
  80155b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801562:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801567:	e9 d0 01 00 00       	jmp    80173c <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	c1 e8 16             	shr    $0x16,%eax
  801571:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801574:	a8 01                	test   $0x1,%al
  801576:	0f 84 0d 01 00 00    	je     801689 <fork+0x197>
  80157c:	89 d8                	mov    %ebx,%eax
  80157e:	c1 e8 0c             	shr    $0xc,%eax
  801581:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801584:	f6 c2 01             	test   $0x1,%dl
  801587:	0f 84 fc 00 00 00    	je     801689 <fork+0x197>
  80158d:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801590:	f6 c2 04             	test   $0x4,%dl
  801593:	0f 84 f0 00 00 00    	je     801689 <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  801599:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	c1 ea 0c             	shr    $0xc,%edx
  8015a1:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  8015a4:	f6 c2 01             	test   $0x1,%dl
  8015a7:	0f 84 dc 00 00 00    	je     801689 <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8015ad:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8015b3:	0f 84 8d 00 00 00    	je     801646 <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8015b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015bc:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8015c3:	00 
  8015c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015da:	e8 e6 fc ff ff       	call   8012c5 <sys_page_map>
               if(r<0)
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	79 1c                	jns    8015ff <fork+0x10d>
                 panic("map failed");
  8015e3:	c7 44 24 08 fc 29 80 	movl   $0x8029fc,0x8(%esp)
  8015ea:	00 
  8015eb:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8015f2:	00 
  8015f3:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  8015fa:	e8 45 0b 00 00       	call   802144 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  8015ff:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801606:	00 
  801607:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80160a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80160e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801615:	00 
  801616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801621:	e8 9f fc ff ff       	call   8012c5 <sys_page_map>
               if(r<0)
  801626:	85 c0                	test   %eax,%eax
  801628:	79 5f                	jns    801689 <fork+0x197>
                 panic("map failed");
  80162a:	c7 44 24 08 fc 29 80 	movl   $0x8029fc,0x8(%esp)
  801631:	00 
  801632:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801639:	00 
  80163a:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  801641:	e8 fe 0a 00 00       	call   802144 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  801646:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80164d:	00 
  80164e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801652:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801655:	89 54 24 08          	mov    %edx,0x8(%esp)
  801659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801664:	e8 5c fc ff ff       	call   8012c5 <sys_page_map>
               if(r<0)
  801669:	85 c0                	test   %eax,%eax
  80166b:	79 1c                	jns    801689 <fork+0x197>
                 panic("map failed");
  80166d:	c7 44 24 08 fc 29 80 	movl   $0x8029fc,0x8(%esp)
  801674:	00 
  801675:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80167c:	00 
  80167d:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  801684:	e8 bb 0a 00 00       	call   802144 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801689:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80168f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801695:	0f 85 d1 fe ff ff    	jne    80156c <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80169b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016a2:	00 
  8016a3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016aa:	ee 
  8016ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ae:	89 04 24             	mov    %eax,(%esp)
  8016b1:	e8 7d fc ff ff       	call   801333 <sys_page_alloc>
        if(r < 0)
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	79 1c                	jns    8016d6 <fork+0x1e4>
            panic("alloc failed");
  8016ba:	c7 44 24 08 07 2a 80 	movl   $0x802a07,0x8(%esp)
  8016c1:	00 
  8016c2:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8016c9:	00 
  8016ca:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  8016d1:	e8 6e 0a 00 00       	call   802144 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8016d6:	c7 44 24 04 e8 21 80 	movl   $0x8021e8,0x4(%esp)
  8016dd:	00 
  8016de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016e1:	89 14 24             	mov    %edx,(%esp)
  8016e4:	e8 2c fa ff ff       	call   801115 <sys_env_set_pgfault_upcall>
        if(r < 0)
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	79 1c                	jns    801709 <fork+0x217>
            panic("set pgfault upcall failed");
  8016ed:	c7 44 24 08 14 2a 80 	movl   $0x802a14,0x8(%esp)
  8016f4:	00 
  8016f5:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8016fc:	00 
  8016fd:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  801704:	e8 3b 0a 00 00       	call   802144 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  801709:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801710:	00 
  801711:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801714:	89 04 24             	mov    %eax,(%esp)
  801717:	e8 d1 fa ff ff       	call   8011ed <sys_env_set_status>
        if(r < 0)
  80171c:	85 c0                	test   %eax,%eax
  80171e:	79 1c                	jns    80173c <fork+0x24a>
            panic("set status failed");
  801720:	c7 44 24 08 2e 2a 80 	movl   $0x802a2e,0x8(%esp)
  801727:	00 
  801728:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80172f:	00 
  801730:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  801737:	e8 08 0a 00 00       	call   802144 <_panic>
        return envid;
	//panic("fork not implemented");
}
  80173c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173f:	83 c4 3c             	add    $0x3c,%esp
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5f                   	pop    %edi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	53                   	push   %ebx
  80174b:	83 ec 24             	sub    $0x24,%esp
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801751:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801753:	89 da                	mov    %ebx,%edx
  801755:	c1 ea 0c             	shr    $0xc,%edx
  801758:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  80175f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801763:	74 08                	je     80176d <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801765:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80176b:	75 1c                	jne    801789 <pgfault+0x42>
           panic("pgfault error");
  80176d:	c7 44 24 08 40 2a 80 	movl   $0x802a40,0x8(%esp)
  801774:	00 
  801775:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80177c:	00 
  80177d:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  801784:	e8 bb 09 00 00       	call   802144 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801789:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801790:	00 
  801791:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801798:	00 
  801799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a0:	e8 8e fb ff ff       	call   801333 <sys_page_alloc>
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	79 20                	jns    8017c9 <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  8017a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ad:	c7 44 24 08 4e 2a 80 	movl   $0x802a4e,0x8(%esp)
  8017b4:	00 
  8017b5:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8017bc:	00 
  8017bd:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  8017c4:	e8 7b 09 00 00       	call   802144 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  8017c9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8017cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8017d6:	00 
  8017d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017db:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8017e2:	e8 0e f5 ff ff       	call   800cf5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  8017e7:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8017ee:	00 
  8017ef:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017fa:	00 
  8017fb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801802:	00 
  801803:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80180a:	e8 b6 fa ff ff       	call   8012c5 <sys_page_map>
  80180f:	85 c0                	test   %eax,%eax
  801811:	79 20                	jns    801833 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801817:	c7 44 24 08 61 2a 80 	movl   $0x802a61,0x8(%esp)
  80181e:	00 
  80181f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801826:	00 
  801827:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  80182e:	e8 11 09 00 00       	call   802144 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801833:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80183a:	00 
  80183b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801842:	e8 12 fa ff ff       	call   801259 <sys_page_unmap>
  801847:	85 c0                	test   %eax,%eax
  801849:	79 20                	jns    80186b <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80184b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184f:	c7 44 24 08 72 2a 80 	movl   $0x802a72,0x8(%esp)
  801856:	00 
  801857:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80185e:	00 
  80185f:	c7 04 24 e1 29 80 00 	movl   $0x8029e1,(%esp)
  801866:	e8 d9 08 00 00       	call   802144 <_panic>
	//panic("pgfault not implemented");
}
  80186b:	83 c4 24             	add    $0x24,%esp
  80186e:	5b                   	pop    %ebx
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    
	...

00801880 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	05 00 00 00 30       	add    $0x30000000,%eax
  80188b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801896:	8b 45 08             	mov    0x8(%ebp),%eax
  801899:	89 04 24             	mov    %eax,(%esp)
  80189c:	e8 df ff ff ff       	call   801880 <fd2num>
  8018a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8018a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	57                   	push   %edi
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8018b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8018b9:	a8 01                	test   $0x1,%al
  8018bb:	74 36                	je     8018f3 <fd_alloc+0x48>
  8018bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8018c2:	a8 01                	test   $0x1,%al
  8018c4:	74 2d                	je     8018f3 <fd_alloc+0x48>
  8018c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8018cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8018d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	89 c2                	mov    %eax,%edx
  8018d9:	c1 ea 16             	shr    $0x16,%edx
  8018dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8018df:	f6 c2 01             	test   $0x1,%dl
  8018e2:	74 14                	je     8018f8 <fd_alloc+0x4d>
  8018e4:	89 c2                	mov    %eax,%edx
  8018e6:	c1 ea 0c             	shr    $0xc,%edx
  8018e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8018ec:	f6 c2 01             	test   $0x1,%dl
  8018ef:	75 10                	jne    801901 <fd_alloc+0x56>
  8018f1:	eb 05                	jmp    8018f8 <fd_alloc+0x4d>
  8018f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8018f8:	89 1f                	mov    %ebx,(%edi)
  8018fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8018ff:	eb 17                	jmp    801918 <fd_alloc+0x6d>
  801901:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801906:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80190b:	75 c8                	jne    8018d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80190d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801913:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5f                   	pop    %edi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	83 f8 1f             	cmp    $0x1f,%eax
  801926:	77 36                	ja     80195e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801928:	05 00 00 0d 00       	add    $0xd0000,%eax
  80192d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801930:	89 c2                	mov    %eax,%edx
  801932:	c1 ea 16             	shr    $0x16,%edx
  801935:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80193c:	f6 c2 01             	test   $0x1,%dl
  80193f:	74 1d                	je     80195e <fd_lookup+0x41>
  801941:	89 c2                	mov    %eax,%edx
  801943:	c1 ea 0c             	shr    $0xc,%edx
  801946:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80194d:	f6 c2 01             	test   $0x1,%dl
  801950:	74 0c                	je     80195e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801952:	8b 55 0c             	mov    0xc(%ebp),%edx
  801955:	89 02                	mov    %eax,(%edx)
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80195c:	eb 05                	jmp    801963 <fd_lookup+0x46>
  80195e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    

00801965 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80196b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80196e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	89 04 24             	mov    %eax,(%esp)
  801978:	e8 a0 ff ff ff       	call   80191d <fd_lookup>
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 0e                	js     80198f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801981:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801984:	8b 55 0c             	mov    0xc(%ebp),%edx
  801987:	89 50 04             	mov    %edx,0x4(%eax)
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	56                   	push   %esi
  801995:	53                   	push   %ebx
  801996:	83 ec 10             	sub    $0x10,%esp
  801999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80199f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8019a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8019a9:	be 04 2b 80 00       	mov    $0x802b04,%esi
		if (devtab[i]->dev_id == dev_id) {
  8019ae:	39 08                	cmp    %ecx,(%eax)
  8019b0:	75 10                	jne    8019c2 <dev_lookup+0x31>
  8019b2:	eb 04                	jmp    8019b8 <dev_lookup+0x27>
  8019b4:	39 08                	cmp    %ecx,(%eax)
  8019b6:	75 0a                	jne    8019c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8019b8:	89 03                	mov    %eax,(%ebx)
  8019ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8019bf:	90                   	nop
  8019c0:	eb 31                	jmp    8019f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8019c2:	83 c2 01             	add    $0x1,%edx
  8019c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	75 e8                	jne    8019b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8019d1:	8b 40 48             	mov    0x48(%eax),%eax
  8019d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019dc:	c7 04 24 88 2a 80 00 	movl   $0x802a88,(%esp)
  8019e3:	e8 f9 e7 ff ff       	call   8001e1 <cprintf>
	*dev = 0;
  8019e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5e                   	pop    %esi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	53                   	push   %ebx
  8019fe:	83 ec 24             	sub    $0x24,%esp
  801a01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 07 ff ff ff       	call   80191d <fd_lookup>
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 53                	js     801a6d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a24:	8b 00                	mov    (%eax),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 63 ff ff ff       	call   801991 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 3b                	js     801a6d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801a32:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801a3e:	74 2d                	je     801a6d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a40:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a43:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a4a:	00 00 00 
	stat->st_isdir = 0;
  801a4d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a54:	00 00 00 
	stat->st_dev = dev;
  801a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a64:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a67:	89 14 24             	mov    %edx,(%esp)
  801a6a:	ff 50 14             	call   *0x14(%eax)
}
  801a6d:	83 c4 24             	add    $0x24,%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    

00801a73 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	53                   	push   %ebx
  801a77:	83 ec 24             	sub    $0x24,%esp
  801a7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a84:	89 1c 24             	mov    %ebx,(%esp)
  801a87:	e8 91 fe ff ff       	call   80191d <fd_lookup>
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	78 5f                	js     801aef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a9a:	8b 00                	mov    (%eax),%eax
  801a9c:	89 04 24             	mov    %eax,(%esp)
  801a9f:	e8 ed fe ff ff       	call   801991 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	78 47                	js     801aef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aa8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801aab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801aaf:	75 23                	jne    801ad4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ab1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801ab6:	8b 40 48             	mov    0x48(%eax),%eax
  801ab9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac1:	c7 04 24 a8 2a 80 00 	movl   $0x802aa8,(%esp)
  801ac8:	e8 14 e7 ff ff       	call   8001e1 <cprintf>
  801acd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801ad2:	eb 1b                	jmp    801aef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	8b 48 18             	mov    0x18(%eax),%ecx
  801ada:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801adf:	85 c9                	test   %ecx,%ecx
  801ae1:	74 0c                	je     801aef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aea:	89 14 24             	mov    %edx,(%esp)
  801aed:	ff d1                	call   *%ecx
}
  801aef:	83 c4 24             	add    $0x24,%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	53                   	push   %ebx
  801af9:	83 ec 24             	sub    $0x24,%esp
  801afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b06:	89 1c 24             	mov    %ebx,(%esp)
  801b09:	e8 0f fe ff ff       	call   80191d <fd_lookup>
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 66                	js     801b78 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1c:	8b 00                	mov    (%eax),%eax
  801b1e:	89 04 24             	mov    %eax,(%esp)
  801b21:	e8 6b fe ff ff       	call   801991 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 4e                	js     801b78 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b2d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801b31:	75 23                	jne    801b56 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b33:	a1 04 40 80 00       	mov    0x804004,%eax
  801b38:	8b 40 48             	mov    0x48(%eax),%eax
  801b3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b43:	c7 04 24 c9 2a 80 00 	movl   $0x802ac9,(%esp)
  801b4a:	e8 92 e6 ff ff       	call   8001e1 <cprintf>
  801b4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801b54:	eb 22                	jmp    801b78 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b59:	8b 48 0c             	mov    0xc(%eax),%ecx
  801b5c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b61:	85 c9                	test   %ecx,%ecx
  801b63:	74 13                	je     801b78 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b65:	8b 45 10             	mov    0x10(%ebp),%eax
  801b68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b73:	89 14 24             	mov    %edx,(%esp)
  801b76:	ff d1                	call   *%ecx
}
  801b78:	83 c4 24             	add    $0x24,%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	53                   	push   %ebx
  801b82:	83 ec 24             	sub    $0x24,%esp
  801b85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8f:	89 1c 24             	mov    %ebx,(%esp)
  801b92:	e8 86 fd ff ff       	call   80191d <fd_lookup>
  801b97:	85 c0                	test   %eax,%eax
  801b99:	78 6b                	js     801c06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba5:	8b 00                	mov    (%eax),%eax
  801ba7:	89 04 24             	mov    %eax,(%esp)
  801baa:	e8 e2 fd ff ff       	call   801991 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	78 53                	js     801c06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801bb3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bb6:	8b 42 08             	mov    0x8(%edx),%eax
  801bb9:	83 e0 03             	and    $0x3,%eax
  801bbc:	83 f8 01             	cmp    $0x1,%eax
  801bbf:	75 23                	jne    801be4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801bc1:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc6:	8b 40 48             	mov    0x48(%eax),%eax
  801bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd1:	c7 04 24 e6 2a 80 00 	movl   $0x802ae6,(%esp)
  801bd8:	e8 04 e6 ff ff       	call   8001e1 <cprintf>
  801bdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801be2:	eb 22                	jmp    801c06 <read+0x88>
	}
	if (!dev->dev_read)
  801be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be7:	8b 48 08             	mov    0x8(%eax),%ecx
  801bea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bef:	85 c9                	test   %ecx,%ecx
  801bf1:	74 13                	je     801c06 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801bf3:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c01:	89 14 24             	mov    %edx,(%esp)
  801c04:	ff d1                	call   *%ecx
}
  801c06:	83 c4 24             	add    $0x24,%esp
  801c09:	5b                   	pop    %ebx
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	57                   	push   %edi
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	83 ec 1c             	sub    $0x1c,%esp
  801c15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c18:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c25:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2a:	85 f6                	test   %esi,%esi
  801c2c:	74 29                	je     801c57 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c2e:	89 f0                	mov    %esi,%eax
  801c30:	29 d0                	sub    %edx,%eax
  801c32:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c36:	03 55 0c             	add    0xc(%ebp),%edx
  801c39:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c3d:	89 3c 24             	mov    %edi,(%esp)
  801c40:	e8 39 ff ff ff       	call   801b7e <read>
		if (m < 0)
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 0e                	js     801c57 <readn+0x4b>
			return m;
		if (m == 0)
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	74 08                	je     801c55 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c4d:	01 c3                	add    %eax,%ebx
  801c4f:	89 da                	mov    %ebx,%edx
  801c51:	39 f3                	cmp    %esi,%ebx
  801c53:	72 d9                	jb     801c2e <readn+0x22>
  801c55:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801c57:	83 c4 1c             	add    $0x1c,%esp
  801c5a:	5b                   	pop    %ebx
  801c5b:	5e                   	pop    %esi
  801c5c:	5f                   	pop    %edi
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 20             	sub    $0x20,%esp
  801c67:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c6a:	89 34 24             	mov    %esi,(%esp)
  801c6d:	e8 0e fc ff ff       	call   801880 <fd2num>
  801c72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c75:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c79:	89 04 24             	mov    %eax,(%esp)
  801c7c:	e8 9c fc ff ff       	call   80191d <fd_lookup>
  801c81:	89 c3                	mov    %eax,%ebx
  801c83:	85 c0                	test   %eax,%eax
  801c85:	78 05                	js     801c8c <fd_close+0x2d>
  801c87:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c8a:	74 0c                	je     801c98 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801c8c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801c90:	19 c0                	sbb    %eax,%eax
  801c92:	f7 d0                	not    %eax
  801c94:	21 c3                	and    %eax,%ebx
  801c96:	eb 3d                	jmp    801cd5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801c98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9f:	8b 06                	mov    (%esi),%eax
  801ca1:	89 04 24             	mov    %eax,(%esp)
  801ca4:	e8 e8 fc ff ff       	call   801991 <dev_lookup>
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	85 c0                	test   %eax,%eax
  801cad:	78 16                	js     801cc5 <fd_close+0x66>
		if (dev->dev_close)
  801caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb2:	8b 40 10             	mov    0x10(%eax),%eax
  801cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	74 07                	je     801cc5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801cbe:	89 34 24             	mov    %esi,(%esp)
  801cc1:	ff d0                	call   *%eax
  801cc3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801cc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd0:	e8 84 f5 ff ff       	call   801259 <sys_page_unmap>
	return r;
}
  801cd5:	89 d8                	mov    %ebx,%eax
  801cd7:	83 c4 20             	add    $0x20,%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	89 04 24             	mov    %eax,(%esp)
  801cf1:	e8 27 fc ff ff       	call   80191d <fd_lookup>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 13                	js     801d0d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801cfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d01:	00 
  801d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d05:	89 04 24             	mov    %eax,(%esp)
  801d08:	e8 52 ff ff ff       	call   801c5f <fd_close>
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 18             	sub    $0x18,%esp
  801d15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d22:	00 
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	89 04 24             	mov    %eax,(%esp)
  801d29:	e8 79 03 00 00       	call   8020a7 <open>
  801d2e:	89 c3                	mov    %eax,%ebx
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 1b                	js     801d4f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3b:	89 1c 24             	mov    %ebx,(%esp)
  801d3e:	e8 b7 fc ff ff       	call   8019fa <fstat>
  801d43:	89 c6                	mov    %eax,%esi
	close(fd);
  801d45:	89 1c 24             	mov    %ebx,(%esp)
  801d48:	e8 91 ff ff ff       	call   801cde <close>
  801d4d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801d4f:	89 d8                	mov    %ebx,%eax
  801d51:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d54:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d57:	89 ec                	mov    %ebp,%esp
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	53                   	push   %ebx
  801d5f:	83 ec 14             	sub    $0x14,%esp
  801d62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801d67:	89 1c 24             	mov    %ebx,(%esp)
  801d6a:	e8 6f ff ff ff       	call   801cde <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d6f:	83 c3 01             	add    $0x1,%ebx
  801d72:	83 fb 20             	cmp    $0x20,%ebx
  801d75:	75 f0                	jne    801d67 <close_all+0xc>
		close(i);
}
  801d77:	83 c4 14             	add    $0x14,%esp
  801d7a:	5b                   	pop    %ebx
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 58             	sub    $0x58,%esp
  801d83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801d86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	89 04 24             	mov    %eax,(%esp)
  801d9c:	e8 7c fb ff ff       	call   80191d <fd_lookup>
  801da1:	89 c3                	mov    %eax,%ebx
  801da3:	85 c0                	test   %eax,%eax
  801da5:	0f 88 e0 00 00 00    	js     801e8b <dup+0x10e>
		return r;
	close(newfdnum);
  801dab:	89 3c 24             	mov    %edi,(%esp)
  801dae:	e8 2b ff ff ff       	call   801cde <close>

	newfd = INDEX2FD(newfdnum);
  801db3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801db9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801dbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dbf:	89 04 24             	mov    %eax,(%esp)
  801dc2:	e8 c9 fa ff ff       	call   801890 <fd2data>
  801dc7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801dc9:	89 34 24             	mov    %esi,(%esp)
  801dcc:	e8 bf fa ff ff       	call   801890 <fd2data>
  801dd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801dd4:	89 da                	mov    %ebx,%edx
  801dd6:	89 d8                	mov    %ebx,%eax
  801dd8:	c1 e8 16             	shr    $0x16,%eax
  801ddb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801de2:	a8 01                	test   $0x1,%al
  801de4:	74 43                	je     801e29 <dup+0xac>
  801de6:	c1 ea 0c             	shr    $0xc,%edx
  801de9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801df0:	a8 01                	test   $0x1,%al
  801df2:	74 35                	je     801e29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801df4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801dfb:	25 07 0e 00 00       	and    $0xe07,%eax
  801e00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e12:	00 
  801e13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1e:	e8 a2 f4 ff ff       	call   8012c5 <sys_page_map>
  801e23:	89 c3                	mov    %eax,%ebx
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 3f                	js     801e68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e2c:	89 c2                	mov    %eax,%edx
  801e2e:	c1 ea 0c             	shr    $0xc,%edx
  801e31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801e3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e4d:	00 
  801e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e59:	e8 67 f4 ff ff       	call   8012c5 <sys_page_map>
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 04                	js     801e68 <dup+0xeb>
  801e64:	89 fb                	mov    %edi,%ebx
  801e66:	eb 23                	jmp    801e8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e73:	e8 e1 f3 ff ff       	call   801259 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e86:	e8 ce f3 ff ff       	call   801259 <sys_page_unmap>
	return r;
}
  801e8b:	89 d8                	mov    %ebx,%eax
  801e8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801e93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801e96:	89 ec                	mov    %ebp,%esp
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    
	...

00801e9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 18             	sub    $0x18,%esp
  801ea2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ea5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ea8:	89 c3                	mov    %eax,%ebx
  801eaa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801eac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801eb3:	75 11                	jne    801ec6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801eb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ebc:	e8 4f 03 00 00       	call   802210 <ipc_find_env>
  801ec1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ec6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ecd:	00 
  801ece:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ed5:	00 
  801ed6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eda:	a1 00 40 80 00       	mov    0x804000,%eax
  801edf:	89 04 24             	mov    %eax,(%esp)
  801ee2:	e8 74 03 00 00       	call   80225b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ee7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eee:	00 
  801eef:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efa:	e8 da 03 00 00       	call   8022d9 <ipc_recv>
}
  801eff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f05:	89 ec                	mov    %ebp,%esp
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f12:	8b 40 0c             	mov    0xc(%eax),%eax
  801f15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f22:	ba 00 00 00 00       	mov    $0x0,%edx
  801f27:	b8 02 00 00 00       	mov    $0x2,%eax
  801f2c:	e8 6b ff ff ff       	call   801e9c <fsipc>
}
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801f3f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801f44:	ba 00 00 00 00       	mov    $0x0,%edx
  801f49:	b8 06 00 00 00       	mov    $0x6,%eax
  801f4e:	e8 49 ff ff ff       	call   801e9c <fsipc>
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f60:	b8 08 00 00 00       	mov    $0x8,%eax
  801f65:	e8 32 ff ff ff       	call   801e9c <fsipc>
}
  801f6a:	c9                   	leave  
  801f6b:	c3                   	ret    

00801f6c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	53                   	push   %ebx
  801f70:	83 ec 14             	sub    $0x14,%esp
  801f73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f76:	8b 45 08             	mov    0x8(%ebp),%eax
  801f79:	8b 40 0c             	mov    0xc(%eax),%eax
  801f7c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f81:	ba 00 00 00 00       	mov    $0x0,%edx
  801f86:	b8 05 00 00 00       	mov    $0x5,%eax
  801f8b:	e8 0c ff ff ff       	call   801e9c <fsipc>
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 2b                	js     801fbf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801f94:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f9b:	00 
  801f9c:	89 1c 24             	mov    %ebx,(%esp)
  801f9f:	e8 66 eb ff ff       	call   800b0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801fa4:	a1 80 50 80 00       	mov    0x805080,%eax
  801fa9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801faf:	a1 84 50 80 00       	mov    0x805084,%eax
  801fb4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801fba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801fbf:	83 c4 14             	add    $0x14,%esp
  801fc2:	5b                   	pop    %ebx
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    

00801fc5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 18             	sub    $0x18,%esp
  801fcb:	8b 45 10             	mov    0x10(%ebp),%eax
  801fce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801fd3:	76 05                	jbe    801fda <devfile_write+0x15>
  801fd5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801fda:	8b 55 08             	mov    0x8(%ebp),%edx
  801fdd:	8b 52 0c             	mov    0xc(%edx),%edx
  801fe0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801fe6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801feb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801ffd:	e8 f3 ec ff ff       	call   800cf5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  802002:	ba 00 00 00 00       	mov    $0x0,%edx
  802007:	b8 04 00 00 00       	mov    $0x4,%eax
  80200c:	e8 8b fe ff ff       	call   801e9c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802011:	c9                   	leave  
  802012:	c3                   	ret    

00802013 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	53                   	push   %ebx
  802017:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80201a:	8b 45 08             	mov    0x8(%ebp),%eax
  80201d:	8b 40 0c             	mov    0xc(%eax),%eax
  802020:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  802025:	8b 45 10             	mov    0x10(%ebp),%eax
  802028:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  80202d:	ba 00 00 00 00       	mov    $0x0,%edx
  802032:	b8 03 00 00 00       	mov    $0x3,%eax
  802037:	e8 60 fe ff ff       	call   801e9c <fsipc>
  80203c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80203e:	85 c0                	test   %eax,%eax
  802040:	78 17                	js     802059 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802042:	89 44 24 08          	mov    %eax,0x8(%esp)
  802046:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80204d:	00 
  80204e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802051:	89 04 24             	mov    %eax,(%esp)
  802054:	e8 9c ec ff ff       	call   800cf5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802059:	89 d8                	mov    %ebx,%eax
  80205b:	83 c4 14             	add    $0x14,%esp
  80205e:	5b                   	pop    %ebx
  80205f:	5d                   	pop    %ebp
  802060:	c3                   	ret    

00802061 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	53                   	push   %ebx
  802065:	83 ec 14             	sub    $0x14,%esp
  802068:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80206b:	89 1c 24             	mov    %ebx,(%esp)
  80206e:	e8 4d ea ff ff       	call   800ac0 <strlen>
  802073:	89 c2                	mov    %eax,%edx
  802075:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80207a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802080:	7f 1f                	jg     8020a1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802086:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80208d:	e8 78 ea ff ff       	call   800b0a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802092:	ba 00 00 00 00       	mov    $0x0,%edx
  802097:	b8 07 00 00 00       	mov    $0x7,%eax
  80209c:	e8 fb fd ff ff       	call   801e9c <fsipc>
}
  8020a1:	83 c4 14             	add    $0x14,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    

008020a7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	83 ec 28             	sub    $0x28,%esp
  8020ad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8020b0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8020b3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  8020b6:	89 34 24             	mov    %esi,(%esp)
  8020b9:	e8 02 ea ff ff       	call   800ac0 <strlen>
  8020be:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8020c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c8:	7f 6d                	jg     802137 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8020ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cd:	89 04 24             	mov    %eax,(%esp)
  8020d0:	e8 d6 f7 ff ff       	call   8018ab <fd_alloc>
  8020d5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 5c                	js     802137 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8020db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020de:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8020e3:	89 34 24             	mov    %esi,(%esp)
  8020e6:	e8 d5 e9 ff ff       	call   800ac0 <strlen>
  8020eb:	83 c0 01             	add    $0x1,%eax
  8020ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020f6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8020fd:	e8 f3 eb ff ff       	call   800cf5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  802102:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802105:	b8 01 00 00 00       	mov    $0x1,%eax
  80210a:	e8 8d fd ff ff       	call   801e9c <fsipc>
  80210f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802111:	85 c0                	test   %eax,%eax
  802113:	79 15                	jns    80212a <open+0x83>
             fd_close(fd,0);
  802115:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80211c:	00 
  80211d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802120:	89 04 24             	mov    %eax,(%esp)
  802123:	e8 37 fb ff ff       	call   801c5f <fd_close>
             return r;
  802128:	eb 0d                	jmp    802137 <open+0x90>
        }
        return fd2num(fd);
  80212a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212d:	89 04 24             	mov    %eax,(%esp)
  802130:	e8 4b f7 ff ff       	call   801880 <fd2num>
  802135:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802137:	89 d8                	mov    %ebx,%eax
  802139:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80213c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80213f:	89 ec                	mov    %ebp,%esp
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    
	...

00802144 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	56                   	push   %esi
  802148:	53                   	push   %ebx
  802149:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80214c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80214f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802155:	e8 c8 f2 ff ff       	call   801422 <sys_getenvid>
  80215a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80215d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802161:	8b 55 08             	mov    0x8(%ebp),%edx
  802164:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802168:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80216c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802170:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  802177:	e8 65 e0 ff ff       	call   8001e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80217c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802180:	8b 45 10             	mov    0x10(%ebp),%eax
  802183:	89 04 24             	mov    %eax,(%esp)
  802186:	e8 f5 df ff ff       	call   800180 <vcprintf>
	cprintf("\n");
  80218b:	c7 04 24 00 2b 80 00 	movl   $0x802b00,(%esp)
  802192:	e8 4a e0 ff ff       	call   8001e1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802197:	cc                   	int3   
  802198:	eb fd                	jmp    802197 <_panic+0x53>
	...

0080219c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021a2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021a9:	75 30                	jne    8021db <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8021ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021b2:	00 
  8021b3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021ba:	ee 
  8021bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c2:	e8 6c f1 ff ff       	call   801333 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8021c7:	c7 44 24 04 e8 21 80 	movl   $0x8021e8,0x4(%esp)
  8021ce:	00 
  8021cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d6:	e8 3a ef ff ff       	call   801115 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021db:	8b 45 08             	mov    0x8(%ebp),%eax
  8021de:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021e3:	c9                   	leave  
  8021e4:	c3                   	ret    
  8021e5:	00 00                	add    %al,(%eax)
	...

008021e8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021e8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021e9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021ee:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021f0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8021f3:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8021f7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8021fb:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8021fe:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802200:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  802204:	83 c4 08             	add    $0x8,%esp
        popal
  802207:	61                   	popa   
        addl $0x4,%esp
  802208:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  80220b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  80220c:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80220d:	c3                   	ret    
	...

00802210 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802216:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80221c:	b8 01 00 00 00       	mov    $0x1,%eax
  802221:	39 ca                	cmp    %ecx,%edx
  802223:	75 04                	jne    802229 <ipc_find_env+0x19>
  802225:	b0 00                	mov    $0x0,%al
  802227:	eb 12                	jmp    80223b <ipc_find_env+0x2b>
  802229:	89 c2                	mov    %eax,%edx
  80222b:	c1 e2 07             	shl    $0x7,%edx
  80222e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802235:	8b 12                	mov    (%edx),%edx
  802237:	39 ca                	cmp    %ecx,%edx
  802239:	75 10                	jne    80224b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80223b:	89 c2                	mov    %eax,%edx
  80223d:	c1 e2 07             	shl    $0x7,%edx
  802240:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802247:	8b 00                	mov    (%eax),%eax
  802249:	eb 0e                	jmp    802259 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80224b:	83 c0 01             	add    $0x1,%eax
  80224e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802253:	75 d4                	jne    802229 <ipc_find_env+0x19>
  802255:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	57                   	push   %edi
  80225f:	56                   	push   %esi
  802260:	53                   	push   %ebx
  802261:	83 ec 1c             	sub    $0x1c,%esp
  802264:	8b 75 08             	mov    0x8(%ebp),%esi
  802267:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80226a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80226d:	85 db                	test   %ebx,%ebx
  80226f:	74 19                	je     80228a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802271:	8b 45 14             	mov    0x14(%ebp),%eax
  802274:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802278:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80227c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802280:	89 34 24             	mov    %esi,(%esp)
  802283:	e8 4c ee ff ff       	call   8010d4 <sys_ipc_try_send>
  802288:	eb 1b                	jmp    8022a5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80228a:	8b 45 14             	mov    0x14(%ebp),%eax
  80228d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802291:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802298:	ee 
  802299:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80229d:	89 34 24             	mov    %esi,(%esp)
  8022a0:	e8 2f ee ff ff       	call   8010d4 <sys_ipc_try_send>
           if(ret == 0)
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	74 28                	je     8022d1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8022a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ac:	74 1c                	je     8022ca <ipc_send+0x6f>
              panic("ipc send error");
  8022ae:	c7 44 24 08 30 2b 80 	movl   $0x802b30,0x8(%esp)
  8022b5:	00 
  8022b6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8022bd:	00 
  8022be:	c7 04 24 3f 2b 80 00 	movl   $0x802b3f,(%esp)
  8022c5:	e8 7a fe ff ff       	call   802144 <_panic>
           sys_yield();
  8022ca:	e8 d1 f0 ff ff       	call   8013a0 <sys_yield>
        }
  8022cf:	eb 9c                	jmp    80226d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8022d1:	83 c4 1c             	add    $0x1c,%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	56                   	push   %esi
  8022dd:	53                   	push   %ebx
  8022de:	83 ec 10             	sub    $0x10,%esp
  8022e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8022e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	75 0e                	jne    8022fc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8022ee:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8022f5:	e8 6f ed ff ff       	call   801069 <sys_ipc_recv>
  8022fa:	eb 08                	jmp    802304 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8022fc:	89 04 24             	mov    %eax,(%esp)
  8022ff:	e8 65 ed ff ff       	call   801069 <sys_ipc_recv>
        if(ret == 0){
  802304:	85 c0                	test   %eax,%eax
  802306:	75 26                	jne    80232e <ipc_recv+0x55>
           if(from_env_store)
  802308:	85 f6                	test   %esi,%esi
  80230a:	74 0a                	je     802316 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80230c:	a1 04 40 80 00       	mov    0x804004,%eax
  802311:	8b 40 78             	mov    0x78(%eax),%eax
  802314:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802316:	85 db                	test   %ebx,%ebx
  802318:	74 0a                	je     802324 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80231a:	a1 04 40 80 00       	mov    0x804004,%eax
  80231f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802322:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802324:	a1 04 40 80 00       	mov    0x804004,%eax
  802329:	8b 40 74             	mov    0x74(%eax),%eax
  80232c:	eb 14                	jmp    802342 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80232e:	85 f6                	test   %esi,%esi
  802330:	74 06                	je     802338 <ipc_recv+0x5f>
              *from_env_store = 0;
  802332:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802338:	85 db                	test   %ebx,%ebx
  80233a:	74 06                	je     802342 <ipc_recv+0x69>
              *perm_store = 0;
  80233c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802342:	83 c4 10             	add    $0x10,%esp
  802345:	5b                   	pop    %ebx
  802346:	5e                   	pop    %esi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    
  802349:	00 00                	add    %al,(%eax)
  80234b:	00 00                	add    %al,(%eax)
  80234d:	00 00                	add    %al,(%eax)
	...

00802350 <__udivdi3>:
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
  802353:	57                   	push   %edi
  802354:	56                   	push   %esi
  802355:	83 ec 10             	sub    $0x10,%esp
  802358:	8b 45 14             	mov    0x14(%ebp),%eax
  80235b:	8b 55 08             	mov    0x8(%ebp),%edx
  80235e:	8b 75 10             	mov    0x10(%ebp),%esi
  802361:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802364:	85 c0                	test   %eax,%eax
  802366:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802369:	75 35                	jne    8023a0 <__udivdi3+0x50>
  80236b:	39 fe                	cmp    %edi,%esi
  80236d:	77 61                	ja     8023d0 <__udivdi3+0x80>
  80236f:	85 f6                	test   %esi,%esi
  802371:	75 0b                	jne    80237e <__udivdi3+0x2e>
  802373:	b8 01 00 00 00       	mov    $0x1,%eax
  802378:	31 d2                	xor    %edx,%edx
  80237a:	f7 f6                	div    %esi
  80237c:	89 c6                	mov    %eax,%esi
  80237e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802381:	31 d2                	xor    %edx,%edx
  802383:	89 f8                	mov    %edi,%eax
  802385:	f7 f6                	div    %esi
  802387:	89 c7                	mov    %eax,%edi
  802389:	89 c8                	mov    %ecx,%eax
  80238b:	f7 f6                	div    %esi
  80238d:	89 c1                	mov    %eax,%ecx
  80238f:	89 fa                	mov    %edi,%edx
  802391:	89 c8                	mov    %ecx,%eax
  802393:	83 c4 10             	add    $0x10,%esp
  802396:	5e                   	pop    %esi
  802397:	5f                   	pop    %edi
  802398:	5d                   	pop    %ebp
  802399:	c3                   	ret    
  80239a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023a0:	39 f8                	cmp    %edi,%eax
  8023a2:	77 1c                	ja     8023c0 <__udivdi3+0x70>
  8023a4:	0f bd d0             	bsr    %eax,%edx
  8023a7:	83 f2 1f             	xor    $0x1f,%edx
  8023aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8023ad:	75 39                	jne    8023e8 <__udivdi3+0x98>
  8023af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8023b2:	0f 86 a0 00 00 00    	jbe    802458 <__udivdi3+0x108>
  8023b8:	39 f8                	cmp    %edi,%eax
  8023ba:	0f 82 98 00 00 00    	jb     802458 <__udivdi3+0x108>
  8023c0:	31 ff                	xor    %edi,%edi
  8023c2:	31 c9                	xor    %ecx,%ecx
  8023c4:	89 c8                	mov    %ecx,%eax
  8023c6:	89 fa                	mov    %edi,%edx
  8023c8:	83 c4 10             	add    $0x10,%esp
  8023cb:	5e                   	pop    %esi
  8023cc:	5f                   	pop    %edi
  8023cd:	5d                   	pop    %ebp
  8023ce:	c3                   	ret    
  8023cf:	90                   	nop
  8023d0:	89 d1                	mov    %edx,%ecx
  8023d2:	89 fa                	mov    %edi,%edx
  8023d4:	89 c8                	mov    %ecx,%eax
  8023d6:	31 ff                	xor    %edi,%edi
  8023d8:	f7 f6                	div    %esi
  8023da:	89 c1                	mov    %eax,%ecx
  8023dc:	89 fa                	mov    %edi,%edx
  8023de:	89 c8                	mov    %ecx,%eax
  8023e0:	83 c4 10             	add    $0x10,%esp
  8023e3:	5e                   	pop    %esi
  8023e4:	5f                   	pop    %edi
  8023e5:	5d                   	pop    %ebp
  8023e6:	c3                   	ret    
  8023e7:	90                   	nop
  8023e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8023ec:	89 f2                	mov    %esi,%edx
  8023ee:	d3 e0                	shl    %cl,%eax
  8023f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8023f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8023f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8023fb:	89 c1                	mov    %eax,%ecx
  8023fd:	d3 ea                	shr    %cl,%edx
  8023ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802403:	0b 55 ec             	or     -0x14(%ebp),%edx
  802406:	d3 e6                	shl    %cl,%esi
  802408:	89 c1                	mov    %eax,%ecx
  80240a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80240d:	89 fe                	mov    %edi,%esi
  80240f:	d3 ee                	shr    %cl,%esi
  802411:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802415:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802418:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80241b:	d3 e7                	shl    %cl,%edi
  80241d:	89 c1                	mov    %eax,%ecx
  80241f:	d3 ea                	shr    %cl,%edx
  802421:	09 d7                	or     %edx,%edi
  802423:	89 f2                	mov    %esi,%edx
  802425:	89 f8                	mov    %edi,%eax
  802427:	f7 75 ec             	divl   -0x14(%ebp)
  80242a:	89 d6                	mov    %edx,%esi
  80242c:	89 c7                	mov    %eax,%edi
  80242e:	f7 65 e8             	mull   -0x18(%ebp)
  802431:	39 d6                	cmp    %edx,%esi
  802433:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802436:	72 30                	jb     802468 <__udivdi3+0x118>
  802438:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80243b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80243f:	d3 e2                	shl    %cl,%edx
  802441:	39 c2                	cmp    %eax,%edx
  802443:	73 05                	jae    80244a <__udivdi3+0xfa>
  802445:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802448:	74 1e                	je     802468 <__udivdi3+0x118>
  80244a:	89 f9                	mov    %edi,%ecx
  80244c:	31 ff                	xor    %edi,%edi
  80244e:	e9 71 ff ff ff       	jmp    8023c4 <__udivdi3+0x74>
  802453:	90                   	nop
  802454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802458:	31 ff                	xor    %edi,%edi
  80245a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80245f:	e9 60 ff ff ff       	jmp    8023c4 <__udivdi3+0x74>
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80246b:	31 ff                	xor    %edi,%edi
  80246d:	89 c8                	mov    %ecx,%eax
  80246f:	89 fa                	mov    %edi,%edx
  802471:	83 c4 10             	add    $0x10,%esp
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
	...

00802480 <__umoddi3>:
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	57                   	push   %edi
  802484:	56                   	push   %esi
  802485:	83 ec 20             	sub    $0x20,%esp
  802488:	8b 55 14             	mov    0x14(%ebp),%edx
  80248b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80248e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802491:	8b 75 0c             	mov    0xc(%ebp),%esi
  802494:	85 d2                	test   %edx,%edx
  802496:	89 c8                	mov    %ecx,%eax
  802498:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80249b:	75 13                	jne    8024b0 <__umoddi3+0x30>
  80249d:	39 f7                	cmp    %esi,%edi
  80249f:	76 3f                	jbe    8024e0 <__umoddi3+0x60>
  8024a1:	89 f2                	mov    %esi,%edx
  8024a3:	f7 f7                	div    %edi
  8024a5:	89 d0                	mov    %edx,%eax
  8024a7:	31 d2                	xor    %edx,%edx
  8024a9:	83 c4 20             	add    $0x20,%esp
  8024ac:	5e                   	pop    %esi
  8024ad:	5f                   	pop    %edi
  8024ae:	5d                   	pop    %ebp
  8024af:	c3                   	ret    
  8024b0:	39 f2                	cmp    %esi,%edx
  8024b2:	77 4c                	ja     802500 <__umoddi3+0x80>
  8024b4:	0f bd ca             	bsr    %edx,%ecx
  8024b7:	83 f1 1f             	xor    $0x1f,%ecx
  8024ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8024bd:	75 51                	jne    802510 <__umoddi3+0x90>
  8024bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8024c2:	0f 87 e0 00 00 00    	ja     8025a8 <__umoddi3+0x128>
  8024c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cb:	29 f8                	sub    %edi,%eax
  8024cd:	19 d6                	sbb    %edx,%esi
  8024cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8024d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d5:	89 f2                	mov    %esi,%edx
  8024d7:	83 c4 20             	add    $0x20,%esp
  8024da:	5e                   	pop    %esi
  8024db:	5f                   	pop    %edi
  8024dc:	5d                   	pop    %ebp
  8024dd:	c3                   	ret    
  8024de:	66 90                	xchg   %ax,%ax
  8024e0:	85 ff                	test   %edi,%edi
  8024e2:	75 0b                	jne    8024ef <__umoddi3+0x6f>
  8024e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e9:	31 d2                	xor    %edx,%edx
  8024eb:	f7 f7                	div    %edi
  8024ed:	89 c7                	mov    %eax,%edi
  8024ef:	89 f0                	mov    %esi,%eax
  8024f1:	31 d2                	xor    %edx,%edx
  8024f3:	f7 f7                	div    %edi
  8024f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f8:	f7 f7                	div    %edi
  8024fa:	eb a9                	jmp    8024a5 <__umoddi3+0x25>
  8024fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 f2                	mov    %esi,%edx
  802504:	83 c4 20             	add    $0x20,%esp
  802507:	5e                   	pop    %esi
  802508:	5f                   	pop    %edi
  802509:	5d                   	pop    %ebp
  80250a:	c3                   	ret    
  80250b:	90                   	nop
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802514:	d3 e2                	shl    %cl,%edx
  802516:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802519:	ba 20 00 00 00       	mov    $0x20,%edx
  80251e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802521:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802524:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802528:	89 fa                	mov    %edi,%edx
  80252a:	d3 ea                	shr    %cl,%edx
  80252c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802530:	0b 55 f4             	or     -0xc(%ebp),%edx
  802533:	d3 e7                	shl    %cl,%edi
  802535:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802539:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80253c:	89 f2                	mov    %esi,%edx
  80253e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802541:	89 c7                	mov    %eax,%edi
  802543:	d3 ea                	shr    %cl,%edx
  802545:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802549:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80254c:	89 c2                	mov    %eax,%edx
  80254e:	d3 e6                	shl    %cl,%esi
  802550:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802554:	d3 ea                	shr    %cl,%edx
  802556:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80255a:	09 d6                	or     %edx,%esi
  80255c:	89 f0                	mov    %esi,%eax
  80255e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802561:	d3 e7                	shl    %cl,%edi
  802563:	89 f2                	mov    %esi,%edx
  802565:	f7 75 f4             	divl   -0xc(%ebp)
  802568:	89 d6                	mov    %edx,%esi
  80256a:	f7 65 e8             	mull   -0x18(%ebp)
  80256d:	39 d6                	cmp    %edx,%esi
  80256f:	72 2b                	jb     80259c <__umoddi3+0x11c>
  802571:	39 c7                	cmp    %eax,%edi
  802573:	72 23                	jb     802598 <__umoddi3+0x118>
  802575:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802579:	29 c7                	sub    %eax,%edi
  80257b:	19 d6                	sbb    %edx,%esi
  80257d:	89 f0                	mov    %esi,%eax
  80257f:	89 f2                	mov    %esi,%edx
  802581:	d3 ef                	shr    %cl,%edi
  802583:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802587:	d3 e0                	shl    %cl,%eax
  802589:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80258d:	09 f8                	or     %edi,%eax
  80258f:	d3 ea                	shr    %cl,%edx
  802591:	83 c4 20             	add    $0x20,%esp
  802594:	5e                   	pop    %esi
  802595:	5f                   	pop    %edi
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    
  802598:	39 d6                	cmp    %edx,%esi
  80259a:	75 d9                	jne    802575 <__umoddi3+0xf5>
  80259c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80259f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8025a2:	eb d1                	jmp    802575 <__umoddi3+0xf5>
  8025a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	39 f2                	cmp    %esi,%edx
  8025aa:	0f 82 18 ff ff ff    	jb     8024c8 <__umoddi3+0x48>
  8025b0:	e9 1d ff ff ff       	jmp    8024d2 <__umoddi3+0x52>
