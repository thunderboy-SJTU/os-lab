
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
  800048:	e8 a9 15 00 00       	call   8015f6 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 29                	je     80007a <umain+0x3a>
        sys_env_set_prior(pid,PRIOR_HIGH);
  800051:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  800058:	00 
  800059:	89 04 24             	mov    %eax,(%esp)
  80005c:	e8 20 10 00 00       	call   801081 <sys_env_set_prior>
        if((pid = fork())!= 0)
  800061:	e8 90 15 00 00       	call   8015f6 <fork>
  800066:	85 c0                	test   %eax,%eax
  800068:	74 10                	je     80007a <umain+0x3a>
           sys_env_set_prior(pid,PRIOR_LOW);
  80006a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800071:	00 
  800072:	89 04 24             	mov    %eax,(%esp)
  800075:	e8 07 10 00 00       	call   801081 <sys_env_set_prior>
    }
    sys_yield();
  80007a:	e8 26 14 00 00       	call   8014a5 <sys_yield>
    env = (struct Env*)envs + ENVX(sys_getenvid());
  80007f:	e8 a3 14 00 00       	call   801527 <sys_getenvid>
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
  80009f:	e8 83 14 00 00       	call   801527 <sys_getenvid>
  8000a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ac:	c7 04 24 20 2c 80 00 	movl   $0x802c20,(%esp)
  8000b3:	e8 29 01 00 00       	call   8001e1 <cprintf>
  8000b8:	eb 3f                	jmp    8000f9 <umain+0xb9>
       if(env->env_prior == PRIOR_MIDD)
  8000ba:	83 fe 02             	cmp    $0x2,%esi
  8000bd:	75 1c                	jne    8000db <umain+0x9b>
          cprintf("[%08x] MIDD PRIOR %d iteration\n",sys_getenvid(),i);
  8000bf:	90                   	nop
  8000c0:	e8 62 14 00 00       	call   801527 <sys_getenvid>
  8000c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000cd:	c7 04 24 40 2c 80 00 	movl   $0x802c40,(%esp)
  8000d4:	e8 08 01 00 00       	call   8001e1 <cprintf>
  8000d9:	eb 1e                	jmp    8000f9 <umain+0xb9>
       if(env->env_prior == PRIOR_LOW)
  8000db:	83 fe 01             	cmp    $0x1,%esi
  8000de:	75 19                	jne    8000f9 <umain+0xb9>
          cprintf("[%08x] LOW PRIOR %d iteration\n",sys_getenvid(),i);
  8000e0:	e8 42 14 00 00       	call   801527 <sys_getenvid>
  8000e5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ed:	c7 04 24 60 2c 80 00 	movl   $0x802c60,(%esp)
  8000f4:	e8 e8 00 00 00       	call   8001e1 <cprintf>
       sys_yield();
  8000f9:	e8 a7 13 00 00       	call   8014a5 <sys_yield>
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
  800122:	e8 00 14 00 00       	call   801527 <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	89 c2                	mov    %eax,%edx
  80012e:	c1 e2 07             	shl    $0x7,%edx
  800131:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800138:	a3 08 50 80 00       	mov    %eax,0x805008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013d:	85 f6                	test   %esi,%esi
  80013f:	7e 07                	jle    800148 <libmain+0x38>
		binaryname = argv[0];
  800141:	8b 03                	mov    (%ebx),%eax
  800143:	a3 00 40 80 00       	mov    %eax,0x804000

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
  80016a:	e8 ec 1c 00 00       	call   801e5b <close_all>
	sys_env_destroy(0);
  80016f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800176:	e8 ec 13 00 00       	call   801567 <sys_env_destroy>
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
  8002af:	e8 ec 26 00 00       	call   8029a0 <__udivdi3>
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
  800317:	e8 b4 27 00 00       	call   802ad0 <__umoddi3>
  80031c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800320:	0f be 80 89 2c 80 00 	movsbl 0x802c89(%eax),%eax
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
  80040a:	ff 24 95 60 2e 80 00 	jmp    *0x802e60(,%edx,4)
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
  8004c7:	8b 14 85 c0 2f 80 00 	mov    0x802fc0(,%eax,4),%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	75 26                	jne    8004f8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	c7 44 24 08 9a 2c 80 	movl   $0x802c9a,0x8(%esp)
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
  8004fc:	c7 44 24 08 9a 31 80 	movl   $0x80319a,0x8(%esp)
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
  80053a:	be a3 2c 80 00       	mov    $0x802ca3,%esi
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
  8007e4:	e8 b7 21 00 00       	call   8029a0 <__udivdi3>
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
  800830:	e8 9b 22 00 00       	call   802ad0 <__umoddi3>
  800835:	89 74 24 04          	mov    %esi,0x4(%esp)
  800839:	0f be 80 89 2c 80 00 	movsbl 0x802c89(%eax),%eax
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
  8008e5:	c7 44 24 0c bc 2d 80 	movl   $0x802dbc,0xc(%esp)
  8008ec:	00 
  8008ed:	c7 44 24 08 9a 31 80 	movl   $0x80319a,0x8(%esp)
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
  80091b:	c7 44 24 0c f4 2d 80 	movl   $0x802df4,0xc(%esp)
  800922:	00 
  800923:	c7 44 24 08 9a 31 80 	movl   $0x80319a,0x8(%esp)
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
  8009af:	e8 1c 21 00 00       	call   802ad0 <__umoddi3>
  8009b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b8:	0f be 80 89 2c 80 00 	movsbl 0x802c89(%eax),%eax
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
  8009f1:	e8 da 20 00 00       	call   802ad0 <__umoddi3>
  8009f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fa:	0f be 80 89 2c 80 00 	movsbl 0x802c89(%eax),%eax
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

00800f7b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  800f88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8d:	b8 13 00 00 00       	mov    $0x13,%eax
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	89 cb                	mov    %ecx,%ebx
  800f97:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800fb1:	8b 1c 24             	mov    (%esp),%ebx
  800fb4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb8:	89 ec                	mov    %ebp,%esp
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 08             	sub    $0x8,%esp
  800fc2:	89 1c 24             	mov    %ebx,(%esp)
  800fc5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fce:	b8 12 00 00 00       	mov    $0x12,%eax
  800fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd9:	89 df                	mov    %ebx,%edi
  800fdb:	51                   	push   %ecx
  800fdc:	52                   	push   %edx
  800fdd:	53                   	push   %ebx
  800fde:	54                   	push   %esp
  800fdf:	55                   	push   %ebp
  800fe0:	56                   	push   %esi
  800fe1:	57                   	push   %edi
  800fe2:	54                   	push   %esp
  800fe3:	5d                   	pop    %ebp
  800fe4:	8d 35 ec 0f 80 00    	lea    0x800fec,%esi
  800fea:	0f 34                	sysenter 
  800fec:	5f                   	pop    %edi
  800fed:	5e                   	pop    %esi
  800fee:	5d                   	pop    %ebp
  800fef:	5c                   	pop    %esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5a                   	pop    %edx
  800ff2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800ff3:	8b 1c 24             	mov    (%esp),%ebx
  800ff6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ffa:	89 ec                	mov    %ebp,%esp
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    

00800ffe <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 08             	sub    $0x8,%esp
  801004:	89 1c 24             	mov    %ebx,(%esp)
  801007:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80100b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801010:	b8 11 00 00 00       	mov    $0x11,%eax
  801015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801018:	8b 55 08             	mov    0x8(%ebp),%edx
  80101b:	89 df                	mov    %ebx,%edi
  80101d:	51                   	push   %ecx
  80101e:	52                   	push   %edx
  80101f:	53                   	push   %ebx
  801020:	54                   	push   %esp
  801021:	55                   	push   %ebp
  801022:	56                   	push   %esi
  801023:	57                   	push   %edi
  801024:	54                   	push   %esp
  801025:	5d                   	pop    %ebp
  801026:	8d 35 2e 10 80 00    	lea    0x80102e,%esi
  80102c:	0f 34                	sysenter 
  80102e:	5f                   	pop    %edi
  80102f:	5e                   	pop    %esi
  801030:	5d                   	pop    %ebp
  801031:	5c                   	pop    %esp
  801032:	5b                   	pop    %ebx
  801033:	5a                   	pop    %edx
  801034:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801035:	8b 1c 24             	mov    (%esp),%ebx
  801038:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80103c:	89 ec                	mov    %ebp,%esp
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	89 1c 24             	mov    %ebx,(%esp)
  801049:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80104d:	b8 10 00 00 00       	mov    $0x10,%eax
  801052:	8b 7d 14             	mov    0x14(%ebp),%edi
  801055:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105b:	8b 55 08             	mov    0x8(%ebp),%edx
  80105e:	51                   	push   %ecx
  80105f:	52                   	push   %edx
  801060:	53                   	push   %ebx
  801061:	54                   	push   %esp
  801062:	55                   	push   %ebp
  801063:	56                   	push   %esi
  801064:	57                   	push   %edi
  801065:	54                   	push   %esp
  801066:	5d                   	pop    %ebp
  801067:	8d 35 6f 10 80 00    	lea    0x80106f,%esi
  80106d:	0f 34                	sysenter 
  80106f:	5f                   	pop    %edi
  801070:	5e                   	pop    %esi
  801071:	5d                   	pop    %ebp
  801072:	5c                   	pop    %esp
  801073:	5b                   	pop    %ebx
  801074:	5a                   	pop    %edx
  801075:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801076:	8b 1c 24             	mov    (%esp),%ebx
  801079:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80107d:	89 ec                	mov    %ebp,%esp
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	83 ec 28             	sub    $0x28,%esp
  801087:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80108a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801092:	b8 0f 00 00 00       	mov    $0xf,%eax
  801097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109a:	8b 55 08             	mov    0x8(%ebp),%edx
  80109d:	89 df                	mov    %ebx,%edi
  80109f:	51                   	push   %ecx
  8010a0:	52                   	push   %edx
  8010a1:	53                   	push   %ebx
  8010a2:	54                   	push   %esp
  8010a3:	55                   	push   %ebp
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	54                   	push   %esp
  8010a7:	5d                   	pop    %ebp
  8010a8:	8d 35 b0 10 80 00    	lea    0x8010b0,%esi
  8010ae:	0f 34                	sysenter 
  8010b0:	5f                   	pop    %edi
  8010b1:	5e                   	pop    %esi
  8010b2:	5d                   	pop    %ebp
  8010b3:	5c                   	pop    %esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5a                   	pop    %edx
  8010b6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	7e 28                	jle    8010e3 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010bf:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8010ce:	00 
  8010cf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010d6:	00 
  8010d7:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8010de:	e8 71 16 00 00       	call   802754 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8010e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e9:	89 ec                	mov    %ebp,%esp
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 08             	sub    $0x8,%esp
  8010f3:	89 1c 24             	mov    %ebx,(%esp)
  8010f6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ff:	b8 15 00 00 00       	mov    $0x15,%eax
  801104:	89 d1                	mov    %edx,%ecx
  801106:	89 d3                	mov    %edx,%ebx
  801108:	89 d7                	mov    %edx,%edi
  80110a:	51                   	push   %ecx
  80110b:	52                   	push   %edx
  80110c:	53                   	push   %ebx
  80110d:	54                   	push   %esp
  80110e:	55                   	push   %ebp
  80110f:	56                   	push   %esi
  801110:	57                   	push   %edi
  801111:	54                   	push   %esp
  801112:	5d                   	pop    %ebp
  801113:	8d 35 1b 11 80 00    	lea    0x80111b,%esi
  801119:	0f 34                	sysenter 
  80111b:	5f                   	pop    %edi
  80111c:	5e                   	pop    %esi
  80111d:	5d                   	pop    %ebp
  80111e:	5c                   	pop    %esp
  80111f:	5b                   	pop    %ebx
  801120:	5a                   	pop    %edx
  801121:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801122:	8b 1c 24             	mov    (%esp),%ebx
  801125:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801129:	89 ec                	mov    %ebp,%esp
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	89 1c 24             	mov    %ebx,(%esp)
  801136:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80113f:	b8 14 00 00 00       	mov    $0x14,%eax
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	89 cb                	mov    %ecx,%ebx
  801149:	89 cf                	mov    %ecx,%edi
  80114b:	51                   	push   %ecx
  80114c:	52                   	push   %edx
  80114d:	53                   	push   %ebx
  80114e:	54                   	push   %esp
  80114f:	55                   	push   %ebp
  801150:	56                   	push   %esi
  801151:	57                   	push   %edi
  801152:	54                   	push   %esp
  801153:	5d                   	pop    %ebp
  801154:	8d 35 5c 11 80 00    	lea    0x80115c,%esi
  80115a:	0f 34                	sysenter 
  80115c:	5f                   	pop    %edi
  80115d:	5e                   	pop    %esi
  80115e:	5d                   	pop    %ebp
  80115f:	5c                   	pop    %esp
  801160:	5b                   	pop    %ebx
  801161:	5a                   	pop    %edx
  801162:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801163:	8b 1c 24             	mov    (%esp),%ebx
  801166:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80116a:	89 ec                	mov    %ebp,%esp
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 28             	sub    $0x28,%esp
  801174:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801177:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80117a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	89 cb                	mov    %ecx,%ebx
  801189:	89 cf                	mov    %ecx,%edi
  80118b:	51                   	push   %ecx
  80118c:	52                   	push   %edx
  80118d:	53                   	push   %ebx
  80118e:	54                   	push   %esp
  80118f:	55                   	push   %ebp
  801190:	56                   	push   %esi
  801191:	57                   	push   %edi
  801192:	54                   	push   %esp
  801193:	5d                   	pop    %ebp
  801194:	8d 35 9c 11 80 00    	lea    0x80119c,%esi
  80119a:	0f 34                	sysenter 
  80119c:	5f                   	pop    %edi
  80119d:	5e                   	pop    %esi
  80119e:	5d                   	pop    %ebp
  80119f:	5c                   	pop    %esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5a                   	pop    %edx
  8011a2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	7e 28                	jle    8011cf <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ab:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8011ca:	e8 85 15 00 00       	call   802754 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d5:	89 ec                	mov    %ebp,%esp
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	89 1c 24             	mov    %ebx,(%esp)
  8011e2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f7:	51                   	push   %ecx
  8011f8:	52                   	push   %edx
  8011f9:	53                   	push   %ebx
  8011fa:	54                   	push   %esp
  8011fb:	55                   	push   %ebp
  8011fc:	56                   	push   %esi
  8011fd:	57                   	push   %edi
  8011fe:	54                   	push   %esp
  8011ff:	5d                   	pop    %ebp
  801200:	8d 35 08 12 80 00    	lea    0x801208,%esi
  801206:	0f 34                	sysenter 
  801208:	5f                   	pop    %edi
  801209:	5e                   	pop    %esi
  80120a:	5d                   	pop    %ebp
  80120b:	5c                   	pop    %esp
  80120c:	5b                   	pop    %ebx
  80120d:	5a                   	pop    %edx
  80120e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80120f:	8b 1c 24             	mov    (%esp),%ebx
  801212:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801216:	89 ec                	mov    %ebp,%esp
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 28             	sub    $0x28,%esp
  801220:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801223:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801233:	8b 55 08             	mov    0x8(%ebp),%edx
  801236:	89 df                	mov    %ebx,%edi
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
  801252:	7e 28                	jle    80127c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801254:	89 44 24 10          	mov    %eax,0x10(%esp)
  801258:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80125f:	00 
  801260:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  801277:	e8 d8 14 00 00       	call   802754 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80127c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80127f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801282:	89 ec                	mov    %ebp,%esp
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  801292:	bb 00 00 00 00       	mov    $0x0,%ebx
  801297:	b8 0a 00 00 00       	mov    $0xa,%eax
  80129c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129f:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a2:	89 df                	mov    %ebx,%edi
  8012a4:	51                   	push   %ecx
  8012a5:	52                   	push   %edx
  8012a6:	53                   	push   %ebx
  8012a7:	54                   	push   %esp
  8012a8:	55                   	push   %ebp
  8012a9:	56                   	push   %esi
  8012aa:	57                   	push   %edi
  8012ab:	54                   	push   %esp
  8012ac:	5d                   	pop    %ebp
  8012ad:	8d 35 b5 12 80 00    	lea    0x8012b5,%esi
  8012b3:	0f 34                	sysenter 
  8012b5:	5f                   	pop    %edi
  8012b6:	5e                   	pop    %esi
  8012b7:	5d                   	pop    %ebp
  8012b8:	5c                   	pop    %esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5a                   	pop    %edx
  8012bb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	7e 28                	jle    8012e8 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8012d3:	00 
  8012d4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012db:	00 
  8012dc:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8012e3:	e8 6c 14 00 00       	call   802754 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012e8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012eb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ee:	89 ec                	mov    %ebp,%esp
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 28             	sub    $0x28,%esp
  8012f8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012fb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801303:	b8 09 00 00 00       	mov    $0x9,%eax
  801308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130b:	8b 55 08             	mov    0x8(%ebp),%edx
  80130e:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801328:	85 c0                	test   %eax,%eax
  80132a:	7e 28                	jle    801354 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80132c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801330:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801337:	00 
  801338:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  80133f:	00 
  801340:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801347:	00 
  801348:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  80134f:	e8 00 14 00 00       	call   802754 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801354:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801357:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80135a:	89 ec                	mov    %ebp,%esp
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 28             	sub    $0x28,%esp
  801364:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801367:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80136a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136f:	b8 07 00 00 00       	mov    $0x7,%eax
  801374:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801377:	8b 55 08             	mov    0x8(%ebp),%edx
  80137a:	89 df                	mov    %ebx,%edi
  80137c:	51                   	push   %ecx
  80137d:	52                   	push   %edx
  80137e:	53                   	push   %ebx
  80137f:	54                   	push   %esp
  801380:	55                   	push   %ebp
  801381:	56                   	push   %esi
  801382:	57                   	push   %edi
  801383:	54                   	push   %esp
  801384:	5d                   	pop    %ebp
  801385:	8d 35 8d 13 80 00    	lea    0x80138d,%esi
  80138b:	0f 34                	sysenter 
  80138d:	5f                   	pop    %edi
  80138e:	5e                   	pop    %esi
  80138f:	5d                   	pop    %ebp
  801390:	5c                   	pop    %esp
  801391:	5b                   	pop    %ebx
  801392:	5a                   	pop    %edx
  801393:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801394:	85 c0                	test   %eax,%eax
  801396:	7e 28                	jle    8013c0 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801398:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013a3:	00 
  8013a4:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8013ab:	00 
  8013ac:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013b3:	00 
  8013b4:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8013bb:	e8 94 13 00 00       	call   802754 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013c0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013c3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013c6:	89 ec                	mov    %ebp,%esp
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 28             	sub    $0x28,%esp
  8013d0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013d3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013d6:	8b 7d 18             	mov    0x18(%ebp),%edi
  8013d9:	0b 7d 14             	or     0x14(%ebp),%edi
  8013dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ea:	51                   	push   %ecx
  8013eb:	52                   	push   %edx
  8013ec:	53                   	push   %ebx
  8013ed:	54                   	push   %esp
  8013ee:	55                   	push   %ebp
  8013ef:	56                   	push   %esi
  8013f0:	57                   	push   %edi
  8013f1:	54                   	push   %esp
  8013f2:	5d                   	pop    %ebp
  8013f3:	8d 35 fb 13 80 00    	lea    0x8013fb,%esi
  8013f9:	0f 34                	sysenter 
  8013fb:	5f                   	pop    %edi
  8013fc:	5e                   	pop    %esi
  8013fd:	5d                   	pop    %ebp
  8013fe:	5c                   	pop    %esp
  8013ff:	5b                   	pop    %ebx
  801400:	5a                   	pop    %edx
  801401:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801402:	85 c0                	test   %eax,%eax
  801404:	7e 28                	jle    80142e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801406:	89 44 24 10          	mov    %eax,0x10(%esp)
  80140a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801411:	00 
  801412:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801419:	00 
  80141a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801421:	00 
  801422:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  801429:	e8 26 13 00 00       	call   802754 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80142e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801431:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801434:	89 ec                	mov    %ebp,%esp
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 28             	sub    $0x28,%esp
  80143e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801441:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801444:	bf 00 00 00 00       	mov    $0x0,%edi
  801449:	b8 05 00 00 00       	mov    $0x5,%eax
  80144e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801454:	8b 55 08             	mov    0x8(%ebp),%edx
  801457:	51                   	push   %ecx
  801458:	52                   	push   %edx
  801459:	53                   	push   %ebx
  80145a:	54                   	push   %esp
  80145b:	55                   	push   %ebp
  80145c:	56                   	push   %esi
  80145d:	57                   	push   %edi
  80145e:	54                   	push   %esp
  80145f:	5d                   	pop    %ebp
  801460:	8d 35 68 14 80 00    	lea    0x801468,%esi
  801466:	0f 34                	sysenter 
  801468:	5f                   	pop    %edi
  801469:	5e                   	pop    %esi
  80146a:	5d                   	pop    %ebp
  80146b:	5c                   	pop    %esp
  80146c:	5b                   	pop    %ebx
  80146d:	5a                   	pop    %edx
  80146e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80146f:	85 c0                	test   %eax,%eax
  801471:	7e 28                	jle    80149b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801473:	89 44 24 10          	mov    %eax,0x10(%esp)
  801477:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80147e:	00 
  80147f:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  801486:	00 
  801487:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80148e:	00 
  80148f:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  801496:	e8 b9 12 00 00       	call   802754 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80149b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80149e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014a1:	89 ec                	mov    %ebp,%esp
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	89 1c 24             	mov    %ebx,(%esp)
  8014ae:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014bc:	89 d1                	mov    %edx,%ecx
  8014be:	89 d3                	mov    %edx,%ebx
  8014c0:	89 d7                	mov    %edx,%edi
  8014c2:	51                   	push   %ecx
  8014c3:	52                   	push   %edx
  8014c4:	53                   	push   %ebx
  8014c5:	54                   	push   %esp
  8014c6:	55                   	push   %ebp
  8014c7:	56                   	push   %esi
  8014c8:	57                   	push   %edi
  8014c9:	54                   	push   %esp
  8014ca:	5d                   	pop    %ebp
  8014cb:	8d 35 d3 14 80 00    	lea    0x8014d3,%esi
  8014d1:	0f 34                	sysenter 
  8014d3:	5f                   	pop    %edi
  8014d4:	5e                   	pop    %esi
  8014d5:	5d                   	pop    %ebp
  8014d6:	5c                   	pop    %esp
  8014d7:	5b                   	pop    %ebx
  8014d8:	5a                   	pop    %edx
  8014d9:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8014da:	8b 1c 24             	mov    (%esp),%ebx
  8014dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014e1:	89 ec                	mov    %ebp,%esp
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801502:	89 df                	mov    %ebx,%edi
  801504:	51                   	push   %ecx
  801505:	52                   	push   %edx
  801506:	53                   	push   %ebx
  801507:	54                   	push   %esp
  801508:	55                   	push   %ebp
  801509:	56                   	push   %esi
  80150a:	57                   	push   %edi
  80150b:	54                   	push   %esp
  80150c:	5d                   	pop    %ebp
  80150d:	8d 35 15 15 80 00    	lea    0x801515,%esi
  801513:	0f 34                	sysenter 
  801515:	5f                   	pop    %edi
  801516:	5e                   	pop    %esi
  801517:	5d                   	pop    %ebp
  801518:	5c                   	pop    %esp
  801519:	5b                   	pop    %ebx
  80151a:	5a                   	pop    %edx
  80151b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80151c:	8b 1c 24             	mov    (%esp),%ebx
  80151f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801523:	89 ec                	mov    %ebp,%esp
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	89 1c 24             	mov    %ebx,(%esp)
  801530:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801534:	ba 00 00 00 00       	mov    $0x0,%edx
  801539:	b8 02 00 00 00       	mov    $0x2,%eax
  80153e:	89 d1                	mov    %edx,%ecx
  801540:	89 d3                	mov    %edx,%ebx
  801542:	89 d7                	mov    %edx,%edi
  801544:	51                   	push   %ecx
  801545:	52                   	push   %edx
  801546:	53                   	push   %ebx
  801547:	54                   	push   %esp
  801548:	55                   	push   %ebp
  801549:	56                   	push   %esi
  80154a:	57                   	push   %edi
  80154b:	54                   	push   %esp
  80154c:	5d                   	pop    %ebp
  80154d:	8d 35 55 15 80 00    	lea    0x801555,%esi
  801553:	0f 34                	sysenter 
  801555:	5f                   	pop    %edi
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	5c                   	pop    %esp
  801559:	5b                   	pop    %ebx
  80155a:	5a                   	pop    %edx
  80155b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80155c:	8b 1c 24             	mov    (%esp),%ebx
  80155f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801563:	89 ec                	mov    %ebp,%esp
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	83 ec 28             	sub    $0x28,%esp
  80156d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801570:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801573:	b9 00 00 00 00       	mov    $0x0,%ecx
  801578:	b8 03 00 00 00       	mov    $0x3,%eax
  80157d:	8b 55 08             	mov    0x8(%ebp),%edx
  801580:	89 cb                	mov    %ecx,%ebx
  801582:	89 cf                	mov    %ecx,%edi
  801584:	51                   	push   %ecx
  801585:	52                   	push   %edx
  801586:	53                   	push   %ebx
  801587:	54                   	push   %esp
  801588:	55                   	push   %ebp
  801589:	56                   	push   %esi
  80158a:	57                   	push   %edi
  80158b:	54                   	push   %esp
  80158c:	5d                   	pop    %ebp
  80158d:	8d 35 95 15 80 00    	lea    0x801595,%esi
  801593:	0f 34                	sysenter 
  801595:	5f                   	pop    %edi
  801596:	5e                   	pop    %esi
  801597:	5d                   	pop    %ebp
  801598:	5c                   	pop    %esp
  801599:	5b                   	pop    %ebx
  80159a:	5a                   	pop    %edx
  80159b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80159c:	85 c0                	test   %eax,%eax
  80159e:	7e 28                	jle    8015c8 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a4:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8015ab:	00 
  8015ac:	c7 44 24 08 00 30 80 	movl   $0x803000,0x8(%esp)
  8015b3:	00 
  8015b4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015bb:	00 
  8015bc:	c7 04 24 1d 30 80 00 	movl   $0x80301d,(%esp)
  8015c3:	e8 8c 11 00 00       	call   802754 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015c8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015ce:	89 ec                	mov    %ebp,%esp
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    
	...

008015d4 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8015da:	c7 44 24 08 2b 30 80 	movl   $0x80302b,0x8(%esp)
  8015e1:	00 
  8015e2:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  8015e9:	00 
  8015ea:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  8015f1:	e8 5e 11 00 00       	call   802754 <_panic>

008015f6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	57                   	push   %edi
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
        set_pgfault_handler(pgfault);
  8015ff:	c7 04 24 4b 18 80 00 	movl   $0x80184b,(%esp)
  801606:	e8 a1 11 00 00       	call   8027ac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80160b:	ba 08 00 00 00       	mov    $0x8,%edx
  801610:	89 d0                	mov    %edx,%eax
  801612:	cd 30                	int    $0x30
  801614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t envid = sys_exofork();
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
  801617:	85 c0                	test   %eax,%eax
  801619:	79 20                	jns    80163b <fork+0x45>
		panic("sys_exofork: %e", envid);
  80161b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80161f:	c7 44 24 08 4c 30 80 	movl   $0x80304c,0x8(%esp)
  801626:	00 
  801627:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80162e:	00 
  80162f:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  801636:	e8 19 11 00 00       	call   802754 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  80163b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801640:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801645:	bf 00 00 40 ef       	mov    $0xef400000,%edi
        uint32_t addr;
        extern void _pgfault_upcall();
        int r = 0;
        if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  80164a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80164e:	75 20                	jne    801670 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801650:	e8 d2 fe ff ff       	call   801527 <sys_getenvid>
  801655:	25 ff 03 00 00       	and    $0x3ff,%eax
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	c1 e2 07             	shl    $0x7,%edx
  80165f:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801666:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80166b:	e9 d0 01 00 00       	jmp    801840 <fork+0x24a>
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
  801670:	89 d8                	mov    %ebx,%eax
  801672:	c1 e8 16             	shr    $0x16,%eax
  801675:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801678:	a8 01                	test   $0x1,%al
  80167a:	0f 84 0d 01 00 00    	je     80178d <fork+0x197>
  801680:	89 d8                	mov    %ebx,%eax
  801682:	c1 e8 0c             	shr    $0xc,%eax
  801685:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801688:	f6 c2 01             	test   $0x1,%dl
  80168b:	0f 84 fc 00 00 00    	je     80178d <fork+0x197>
  801691:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801694:	f6 c2 04             	test   $0x4,%dl
  801697:	0f 84 f0 00 00 00    	je     80178d <fork+0x197>
duppage(envid_t envid, unsigned pn)
{
	int r;
        
	// LAB 4: Your code here.
        uint32_t addr = pn*PGSIZE;
  80169d:	c1 e0 0c             	shl    $0xc,%eax
        pte_t pte = vpt[PGNUM(addr)];
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	c1 ea 0c             	shr    $0xc,%edx
  8016a5:	8b 14 97             	mov    (%edi,%edx,4),%edx
        if(pte & PTE_P){
  8016a8:	f6 c2 01             	test   $0x1,%dl
  8016ab:	0f 84 dc 00 00 00    	je     80178d <fork+0x197>
          if((pte & PTE_W)|| (pte & PTE_COW)){
  8016b1:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8016b7:	0f 84 8d 00 00 00    	je     80174a <fork+0x154>
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U|PTE_COW);
  8016bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016c0:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8016c7:	00 
  8016c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016cf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016de:	e8 e7 fc ff ff       	call   8013ca <sys_page_map>
               if(r<0)
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	79 1c                	jns    801703 <fork+0x10d>
                 panic("map failed");
  8016e7:	c7 44 24 08 5c 30 80 	movl   $0x80305c,0x8(%esp)
  8016ee:	00 
  8016ef:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8016f6:	00 
  8016f7:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  8016fe:	e8 51 10 00 00       	call   802754 <_panic>
               r = sys_page_map(0,(void*)addr,0,(void*)addr,PTE_P|PTE_U|PTE_COW);    //mark itself COW as well
  801703:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80170a:	00 
  80170b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80170e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801712:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801719:	00 
  80171a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801725:	e8 a0 fc ff ff       	call   8013ca <sys_page_map>
               if(r<0)
  80172a:	85 c0                	test   %eax,%eax
  80172c:	79 5f                	jns    80178d <fork+0x197>
                 panic("map failed");
  80172e:	c7 44 24 08 5c 30 80 	movl   $0x80305c,0x8(%esp)
  801735:	00 
  801736:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80173d:	00 
  80173e:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  801745:	e8 0a 10 00 00       	call   802754 <_panic>
          }
          else{
               r = sys_page_map(0,(void*)addr,envid,(void*)addr,PTE_P|PTE_U);
  80174a:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801751:	00 
  801752:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801756:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801759:	89 54 24 08          	mov    %edx,0x8(%esp)
  80175d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801761:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801768:	e8 5d fc ff ff       	call   8013ca <sys_page_map>
               if(r<0)
  80176d:	85 c0                	test   %eax,%eax
  80176f:	79 1c                	jns    80178d <fork+0x197>
                 panic("map failed");
  801771:	c7 44 24 08 5c 30 80 	movl   $0x80305c,0x8(%esp)
  801778:	00 
  801779:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801780:	00 
  801781:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  801788:	e8 c7 0f 00 00       	call   802754 <_panic>
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
        for(addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80178d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801793:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801799:	0f 85 d1 fe ff ff    	jne    801670 <fork+0x7a>
           if((vpd[PDX(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_P) && (vpt[PGNUM(addr)] & PTE_U))
              duppage(envid,PGNUM(addr));
        }
        r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80179f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017a6:	00 
  8017a7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017ae:	ee 
  8017af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b2:	89 04 24             	mov    %eax,(%esp)
  8017b5:	e8 7e fc ff ff       	call   801438 <sys_page_alloc>
        if(r < 0)
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	79 1c                	jns    8017da <fork+0x1e4>
            panic("alloc failed");
  8017be:	c7 44 24 08 67 30 80 	movl   $0x803067,0x8(%esp)
  8017c5:	00 
  8017c6:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8017cd:	00 
  8017ce:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  8017d5:	e8 7a 0f 00 00       	call   802754 <_panic>
        r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8017da:	c7 44 24 04 f8 27 80 	movl   $0x8027f8,0x4(%esp)
  8017e1:	00 
  8017e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e5:	89 14 24             	mov    %edx,(%esp)
  8017e8:	e8 2d fa ff ff       	call   80121a <sys_env_set_pgfault_upcall>
        if(r < 0)
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	79 1c                	jns    80180d <fork+0x217>
            panic("set pgfault upcall failed");
  8017f1:	c7 44 24 08 74 30 80 	movl   $0x803074,0x8(%esp)
  8017f8:	00 
  8017f9:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801800:	00 
  801801:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  801808:	e8 47 0f 00 00       	call   802754 <_panic>
        r = sys_env_set_status(envid, ENV_RUNNABLE);
  80180d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801814:	00 
  801815:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	e8 d2 fa ff ff       	call   8012f2 <sys_env_set_status>
        if(r < 0)
  801820:	85 c0                	test   %eax,%eax
  801822:	79 1c                	jns    801840 <fork+0x24a>
            panic("set status failed");
  801824:	c7 44 24 08 8e 30 80 	movl   $0x80308e,0x8(%esp)
  80182b:	00 
  80182c:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801833:	00 
  801834:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  80183b:	e8 14 0f 00 00       	call   802754 <_panic>
        return envid;
	//panic("fork not implemented");
}
  801840:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801843:	83 c4 3c             	add    $0x3c,%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	5f                   	pop    %edi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 24             	sub    $0x24,%esp
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801855:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
  801857:	89 da                	mov    %ebx,%edx
  801859:	c1 ea 0c             	shr    $0xc,%edx
  80185c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
  801863:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801867:	74 08                	je     801871 <pgfault+0x26>
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        pte_t pte = vpt[PGNUM(addr)];
        if((!(err & FEC_WR)) ||(!(pte & (PTE_P | PTE_U |PTE_COW))))
  801869:	f7 c2 05 08 00 00    	test   $0x805,%edx
  80186f:	75 1c                	jne    80188d <pgfault+0x42>
           panic("pgfault error");
  801871:	c7 44 24 08 a0 30 80 	movl   $0x8030a0,0x8(%esp)
  801878:	00 
  801879:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801880:	00 
  801881:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  801888:	e8 c7 0e 00 00       	call   802754 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
        if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80188d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801894:	00 
  801895:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80189c:	00 
  80189d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a4:	e8 8f fb ff ff       	call   801438 <sys_page_alloc>
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	79 20                	jns    8018cd <pgfault+0x82>
		panic("sys_page_alloc: %e", r);
  8018ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018b1:	c7 44 24 08 ae 30 80 	movl   $0x8030ae,0x8(%esp)
  8018b8:	00 
  8018b9:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8018c0:	00 
  8018c1:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  8018c8:	e8 87 0e 00 00       	call   802754 <_panic>
        memmove(PFTEMP, (void*)((PGNUM(addr))<< PTXSHIFT), PGSIZE);
  8018cd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8018d3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018da:	00 
  8018db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018df:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8018e6:	e8 0a f4 ff ff       	call   800cf5 <memmove>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)((PGNUM(addr))<< PTXSHIFT), PTE_P|PTE_U|PTE_W)) < 0)
  8018eb:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018f2:	00 
  8018f3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8018f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018fe:	00 
  8018ff:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801906:	00 
  801907:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190e:	e8 b7 fa ff ff       	call   8013ca <sys_page_map>
  801913:	85 c0                	test   %eax,%eax
  801915:	79 20                	jns    801937 <pgfault+0xec>
		panic("sys_page_map: %e", r);	
  801917:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80191b:	c7 44 24 08 c1 30 80 	movl   $0x8030c1,0x8(%esp)
  801922:	00 
  801923:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80192a:	00 
  80192b:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  801932:	e8 1d 0e 00 00       	call   802754 <_panic>
        if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801937:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80193e:	00 
  80193f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801946:	e8 13 fa ff ff       	call   80135e <sys_page_unmap>
  80194b:	85 c0                	test   %eax,%eax
  80194d:	79 20                	jns    80196f <pgfault+0x124>
		panic("sys_page_unmap: %e", r);
  80194f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801953:	c7 44 24 08 d2 30 80 	movl   $0x8030d2,0x8(%esp)
  80195a:	00 
  80195b:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801962:	00 
  801963:	c7 04 24 41 30 80 00 	movl   $0x803041,(%esp)
  80196a:	e8 e5 0d 00 00       	call   802754 <_panic>
	//panic("pgfault not implemented");
}
  80196f:	83 c4 24             	add    $0x24,%esp
  801972:	5b                   	pop    %ebx
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    
	...

00801980 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	05 00 00 00 30       	add    $0x30000000,%eax
  80198b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
  801999:	89 04 24             	mov    %eax,(%esp)
  80199c:	e8 df ff ff ff       	call   801980 <fd2num>
  8019a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8019a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	57                   	push   %edi
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8019b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8019b9:	a8 01                	test   $0x1,%al
  8019bb:	74 36                	je     8019f3 <fd_alloc+0x48>
  8019bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8019c2:	a8 01                	test   $0x1,%al
  8019c4:	74 2d                	je     8019f3 <fd_alloc+0x48>
  8019c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8019cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8019d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8019d5:	89 c3                	mov    %eax,%ebx
  8019d7:	89 c2                	mov    %eax,%edx
  8019d9:	c1 ea 16             	shr    $0x16,%edx
  8019dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8019df:	f6 c2 01             	test   $0x1,%dl
  8019e2:	74 14                	je     8019f8 <fd_alloc+0x4d>
  8019e4:	89 c2                	mov    %eax,%edx
  8019e6:	c1 ea 0c             	shr    $0xc,%edx
  8019e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8019ec:	f6 c2 01             	test   $0x1,%dl
  8019ef:	75 10                	jne    801a01 <fd_alloc+0x56>
  8019f1:	eb 05                	jmp    8019f8 <fd_alloc+0x4d>
  8019f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8019f8:	89 1f                	mov    %ebx,(%edi)
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8019ff:	eb 17                	jmp    801a18 <fd_alloc+0x6d>
  801a01:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801a06:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801a0b:	75 c8                	jne    8019d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801a0d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a13:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5f                   	pop    %edi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801a20:	8b 45 08             	mov    0x8(%ebp),%eax
  801a23:	83 f8 1f             	cmp    $0x1f,%eax
  801a26:	77 36                	ja     801a5e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801a28:	05 00 00 0d 00       	add    $0xd0000,%eax
  801a2d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801a30:	89 c2                	mov    %eax,%edx
  801a32:	c1 ea 16             	shr    $0x16,%edx
  801a35:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a3c:	f6 c2 01             	test   $0x1,%dl
  801a3f:	74 1d                	je     801a5e <fd_lookup+0x41>
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	c1 ea 0c             	shr    $0xc,%edx
  801a46:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a4d:	f6 c2 01             	test   $0x1,%dl
  801a50:	74 0c                	je     801a5e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a52:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a55:	89 02                	mov    %eax,(%edx)
  801a57:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801a5c:	eb 05                	jmp    801a63 <fd_lookup+0x46>
  801a5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a6b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a72:	8b 45 08             	mov    0x8(%ebp),%eax
  801a75:	89 04 24             	mov    %eax,(%esp)
  801a78:	e8 a0 ff ff ff       	call   801a1d <fd_lookup>
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 0e                	js     801a8f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a81:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a87:	89 50 04             	mov    %edx,0x4(%eax)
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 10             	sub    $0x10,%esp
  801a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801a9f:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801aa4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801aa9:	be 64 31 80 00       	mov    $0x803164,%esi
		if (devtab[i]->dev_id == dev_id) {
  801aae:	39 08                	cmp    %ecx,(%eax)
  801ab0:	75 10                	jne    801ac2 <dev_lookup+0x31>
  801ab2:	eb 04                	jmp    801ab8 <dev_lookup+0x27>
  801ab4:	39 08                	cmp    %ecx,(%eax)
  801ab6:	75 0a                	jne    801ac2 <dev_lookup+0x31>
			*dev = devtab[i];
  801ab8:	89 03                	mov    %eax,(%ebx)
  801aba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801abf:	90                   	nop
  801ac0:	eb 31                	jmp    801af3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ac2:	83 c2 01             	add    $0x1,%edx
  801ac5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	75 e8                	jne    801ab4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801acc:	a1 08 50 80 00       	mov    0x805008,%eax
  801ad1:	8b 40 48             	mov    0x48(%eax),%eax
  801ad4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adc:	c7 04 24 e8 30 80 00 	movl   $0x8030e8,(%esp)
  801ae3:	e8 f9 e6 ff ff       	call   8001e1 <cprintf>
	*dev = 0;
  801ae8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	53                   	push   %ebx
  801afe:	83 ec 24             	sub    $0x24,%esp
  801b01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	89 04 24             	mov    %eax,(%esp)
  801b11:	e8 07 ff ff ff       	call   801a1d <fd_lookup>
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 53                	js     801b6d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b24:	8b 00                	mov    (%eax),%eax
  801b26:	89 04 24             	mov    %eax,(%esp)
  801b29:	e8 63 ff ff ff       	call   801a91 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	78 3b                	js     801b6d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801b32:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b3a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801b3e:	74 2d                	je     801b6d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b40:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b43:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b4a:	00 00 00 
	stat->st_isdir = 0;
  801b4d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b54:	00 00 00 
	stat->st_dev = dev;
  801b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b64:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b67:	89 14 24             	mov    %edx,(%esp)
  801b6a:	ff 50 14             	call   *0x14(%eax)
}
  801b6d:	83 c4 24             	add    $0x24,%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	53                   	push   %ebx
  801b77:	83 ec 24             	sub    $0x24,%esp
  801b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b7d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b84:	89 1c 24             	mov    %ebx,(%esp)
  801b87:	e8 91 fe ff ff       	call   801a1d <fd_lookup>
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 5f                	js     801bef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9a:	8b 00                	mov    (%eax),%eax
  801b9c:	89 04 24             	mov    %eax,(%esp)
  801b9f:	e8 ed fe ff ff       	call   801a91 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 47                	js     801bef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ba8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801baf:	75 23                	jne    801bd4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801bb1:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801bb6:	8b 40 48             	mov    0x48(%eax),%eax
  801bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc1:	c7 04 24 08 31 80 00 	movl   $0x803108,(%esp)
  801bc8:	e8 14 e6 ff ff       	call   8001e1 <cprintf>
  801bcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801bd2:	eb 1b                	jmp    801bef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd7:	8b 48 18             	mov    0x18(%eax),%ecx
  801bda:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bdf:	85 c9                	test   %ecx,%ecx
  801be1:	74 0c                	je     801bef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bea:	89 14 24             	mov    %edx,(%esp)
  801bed:	ff d1                	call   *%ecx
}
  801bef:	83 c4 24             	add    $0x24,%esp
  801bf2:	5b                   	pop    %ebx
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 24             	sub    $0x24,%esp
  801bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c06:	89 1c 24             	mov    %ebx,(%esp)
  801c09:	e8 0f fe ff ff       	call   801a1d <fd_lookup>
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 66                	js     801c78 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1c:	8b 00                	mov    (%eax),%eax
  801c1e:	89 04 24             	mov    %eax,(%esp)
  801c21:	e8 6b fe ff ff       	call   801a91 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 4e                	js     801c78 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c2d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801c31:	75 23                	jne    801c56 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801c33:	a1 08 50 80 00       	mov    0x805008,%eax
  801c38:	8b 40 48             	mov    0x48(%eax),%eax
  801c3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c43:	c7 04 24 29 31 80 00 	movl   $0x803129,(%esp)
  801c4a:	e8 92 e5 ff ff       	call   8001e1 <cprintf>
  801c4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801c54:	eb 22                	jmp    801c78 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c59:	8b 48 0c             	mov    0xc(%eax),%ecx
  801c5c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c61:	85 c9                	test   %ecx,%ecx
  801c63:	74 13                	je     801c78 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c65:	8b 45 10             	mov    0x10(%ebp),%eax
  801c68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c73:	89 14 24             	mov    %edx,(%esp)
  801c76:	ff d1                	call   *%ecx
}
  801c78:	83 c4 24             	add    $0x24,%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	53                   	push   %ebx
  801c82:	83 ec 24             	sub    $0x24,%esp
  801c85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8f:	89 1c 24             	mov    %ebx,(%esp)
  801c92:	e8 86 fd ff ff       	call   801a1d <fd_lookup>
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 6b                	js     801d06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca5:	8b 00                	mov    (%eax),%eax
  801ca7:	89 04 24             	mov    %eax,(%esp)
  801caa:	e8 e2 fd ff ff       	call   801a91 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	78 53                	js     801d06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801cb3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cb6:	8b 42 08             	mov    0x8(%edx),%eax
  801cb9:	83 e0 03             	and    $0x3,%eax
  801cbc:	83 f8 01             	cmp    $0x1,%eax
  801cbf:	75 23                	jne    801ce4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801cc1:	a1 08 50 80 00       	mov    0x805008,%eax
  801cc6:	8b 40 48             	mov    0x48(%eax),%eax
  801cc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd1:	c7 04 24 46 31 80 00 	movl   $0x803146,(%esp)
  801cd8:	e8 04 e5 ff ff       	call   8001e1 <cprintf>
  801cdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801ce2:	eb 22                	jmp    801d06 <read+0x88>
	}
	if (!dev->dev_read)
  801ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce7:	8b 48 08             	mov    0x8(%eax),%ecx
  801cea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801cef:	85 c9                	test   %ecx,%ecx
  801cf1:	74 13                	je     801d06 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801cf3:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d01:	89 14 24             	mov    %edx,(%esp)
  801d04:	ff d1                	call   *%ecx
}
  801d06:	83 c4 24             	add    $0x24,%esp
  801d09:	5b                   	pop    %ebx
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	83 ec 1c             	sub    $0x1c,%esp
  801d15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d18:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2a:	85 f6                	test   %esi,%esi
  801d2c:	74 29                	je     801d57 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801d2e:	89 f0                	mov    %esi,%eax
  801d30:	29 d0                	sub    %edx,%eax
  801d32:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d36:	03 55 0c             	add    0xc(%ebp),%edx
  801d39:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d3d:	89 3c 24             	mov    %edi,(%esp)
  801d40:	e8 39 ff ff ff       	call   801c7e <read>
		if (m < 0)
  801d45:	85 c0                	test   %eax,%eax
  801d47:	78 0e                	js     801d57 <readn+0x4b>
			return m;
		if (m == 0)
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	74 08                	je     801d55 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d4d:	01 c3                	add    %eax,%ebx
  801d4f:	89 da                	mov    %ebx,%edx
  801d51:	39 f3                	cmp    %esi,%ebx
  801d53:	72 d9                	jb     801d2e <readn+0x22>
  801d55:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801d57:	83 c4 1c             	add    $0x1c,%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 20             	sub    $0x20,%esp
  801d67:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d6a:	89 34 24             	mov    %esi,(%esp)
  801d6d:	e8 0e fc ff ff       	call   801980 <fd2num>
  801d72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d75:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d79:	89 04 24             	mov    %eax,(%esp)
  801d7c:	e8 9c fc ff ff       	call   801a1d <fd_lookup>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	85 c0                	test   %eax,%eax
  801d85:	78 05                	js     801d8c <fd_close+0x2d>
  801d87:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d8a:	74 0c                	je     801d98 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801d8c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801d90:	19 c0                	sbb    %eax,%eax
  801d92:	f7 d0                	not    %eax
  801d94:	21 c3                	and    %eax,%ebx
  801d96:	eb 3d                	jmp    801dd5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9f:	8b 06                	mov    (%esi),%eax
  801da1:	89 04 24             	mov    %eax,(%esp)
  801da4:	e8 e8 fc ff ff       	call   801a91 <dev_lookup>
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 16                	js     801dc5 <fd_close+0x66>
		if (dev->dev_close)
  801daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db2:	8b 40 10             	mov    0x10(%eax),%eax
  801db5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	74 07                	je     801dc5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801dbe:	89 34 24             	mov    %esi,(%esp)
  801dc1:	ff d0                	call   *%eax
  801dc3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801dc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd0:	e8 89 f5 ff ff       	call   80135e <sys_page_unmap>
	return r;
}
  801dd5:	89 d8                	mov    %ebx,%eax
  801dd7:	83 c4 20             	add    $0x20,%esp
  801dda:	5b                   	pop    %ebx
  801ddb:	5e                   	pop    %esi
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    

00801dde <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801deb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dee:	89 04 24             	mov    %eax,(%esp)
  801df1:	e8 27 fc ff ff       	call   801a1d <fd_lookup>
  801df6:	85 c0                	test   %eax,%eax
  801df8:	78 13                	js     801e0d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801dfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e01:	00 
  801e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e05:	89 04 24             	mov    %eax,(%esp)
  801e08:	e8 52 ff ff ff       	call   801d5f <fd_close>
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 18             	sub    $0x18,%esp
  801e15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801e1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e22:	00 
  801e23:	8b 45 08             	mov    0x8(%ebp),%eax
  801e26:	89 04 24             	mov    %eax,(%esp)
  801e29:	e8 79 03 00 00       	call   8021a7 <open>
  801e2e:	89 c3                	mov    %eax,%ebx
  801e30:	85 c0                	test   %eax,%eax
  801e32:	78 1b                	js     801e4f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801e34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3b:	89 1c 24             	mov    %ebx,(%esp)
  801e3e:	e8 b7 fc ff ff       	call   801afa <fstat>
  801e43:	89 c6                	mov    %eax,%esi
	close(fd);
  801e45:	89 1c 24             	mov    %ebx,(%esp)
  801e48:	e8 91 ff ff ff       	call   801dde <close>
  801e4d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801e4f:	89 d8                	mov    %ebx,%eax
  801e51:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e54:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e57:	89 ec                	mov    %ebp,%esp
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    

00801e5b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	53                   	push   %ebx
  801e5f:	83 ec 14             	sub    $0x14,%esp
  801e62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801e67:	89 1c 24             	mov    %ebx,(%esp)
  801e6a:	e8 6f ff ff ff       	call   801dde <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e6f:	83 c3 01             	add    $0x1,%ebx
  801e72:	83 fb 20             	cmp    $0x20,%ebx
  801e75:	75 f0                	jne    801e67 <close_all+0xc>
		close(i);
}
  801e77:	83 c4 14             	add    $0x14,%esp
  801e7a:	5b                   	pop    %ebx
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 58             	sub    $0x58,%esp
  801e83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801e86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801e89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801e8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e96:	8b 45 08             	mov    0x8(%ebp),%eax
  801e99:	89 04 24             	mov    %eax,(%esp)
  801e9c:	e8 7c fb ff ff       	call   801a1d <fd_lookup>
  801ea1:	89 c3                	mov    %eax,%ebx
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	0f 88 e0 00 00 00    	js     801f8b <dup+0x10e>
		return r;
	close(newfdnum);
  801eab:	89 3c 24             	mov    %edi,(%esp)
  801eae:	e8 2b ff ff ff       	call   801dde <close>

	newfd = INDEX2FD(newfdnum);
  801eb3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801eb9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ebf:	89 04 24             	mov    %eax,(%esp)
  801ec2:	e8 c9 fa ff ff       	call   801990 <fd2data>
  801ec7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ec9:	89 34 24             	mov    %esi,(%esp)
  801ecc:	e8 bf fa ff ff       	call   801990 <fd2data>
  801ed1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801ed4:	89 da                	mov    %ebx,%edx
  801ed6:	89 d8                	mov    %ebx,%eax
  801ed8:	c1 e8 16             	shr    $0x16,%eax
  801edb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ee2:	a8 01                	test   $0x1,%al
  801ee4:	74 43                	je     801f29 <dup+0xac>
  801ee6:	c1 ea 0c             	shr    $0xc,%edx
  801ee9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ef0:	a8 01                	test   $0x1,%al
  801ef2:	74 35                	je     801f29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ef4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801efb:	25 07 0e 00 00       	and    $0xe07,%eax
  801f00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f12:	00 
  801f13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f1e:	e8 a7 f4 ff ff       	call   8013ca <sys_page_map>
  801f23:	89 c3                	mov    %eax,%ebx
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 3f                	js     801f68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2c:	89 c2                	mov    %eax,%edx
  801f2e:	c1 ea 0c             	shr    $0xc,%edx
  801f31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801f38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801f3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f4d:	00 
  801f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f59:	e8 6c f4 ff ff       	call   8013ca <sys_page_map>
  801f5e:	89 c3                	mov    %eax,%ebx
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 04                	js     801f68 <dup+0xeb>
  801f64:	89 fb                	mov    %edi,%ebx
  801f66:	eb 23                	jmp    801f8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f73:	e8 e6 f3 ff ff       	call   80135e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f86:	e8 d3 f3 ff ff       	call   80135e <sys_page_unmap>
	return r;
}
  801f8b:	89 d8                	mov    %ebx,%eax
  801f8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801f90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801f93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801f96:	89 ec                	mov    %ebp,%esp
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    
	...

00801f9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	83 ec 18             	sub    $0x18,%esp
  801fa2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fa5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801fa8:	89 c3                	mov    %eax,%ebx
  801faa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801fac:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801fb3:	75 11                	jne    801fc6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801fb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801fbc:	e8 5f 08 00 00       	call   802820 <ipc_find_env>
  801fc1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801fc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801fcd:	00 
  801fce:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801fd5:	00 
  801fd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fda:	a1 00 50 80 00       	mov    0x805000,%eax
  801fdf:	89 04 24             	mov    %eax,(%esp)
  801fe2:	e8 84 08 00 00       	call   80286b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801fe7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fee:	00 
  801fef:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ff3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ffa:	e8 ea 08 00 00       	call   8028e9 <ipc_recv>
}
  801fff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802002:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802005:	89 ec                	mov    %ebp,%esp
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80200f:	8b 45 08             	mov    0x8(%ebp),%eax
  802012:	8b 40 0c             	mov    0xc(%eax),%eax
  802015:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80201a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802022:	ba 00 00 00 00       	mov    $0x0,%edx
  802027:	b8 02 00 00 00       	mov    $0x2,%eax
  80202c:	e8 6b ff ff ff       	call   801f9c <fsipc>
}
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802039:	8b 45 08             	mov    0x8(%ebp),%eax
  80203c:	8b 40 0c             	mov    0xc(%eax),%eax
  80203f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802044:	ba 00 00 00 00       	mov    $0x0,%edx
  802049:	b8 06 00 00 00       	mov    $0x6,%eax
  80204e:	e8 49 ff ff ff       	call   801f9c <fsipc>
}
  802053:	c9                   	leave  
  802054:	c3                   	ret    

00802055 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80205b:	ba 00 00 00 00       	mov    $0x0,%edx
  802060:	b8 08 00 00 00       	mov    $0x8,%eax
  802065:	e8 32 ff ff ff       	call   801f9c <fsipc>
}
  80206a:	c9                   	leave  
  80206b:	c3                   	ret    

0080206c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	53                   	push   %ebx
  802070:	83 ec 14             	sub    $0x14,%esp
  802073:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802076:	8b 45 08             	mov    0x8(%ebp),%eax
  802079:	8b 40 0c             	mov    0xc(%eax),%eax
  80207c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802081:	ba 00 00 00 00       	mov    $0x0,%edx
  802086:	b8 05 00 00 00       	mov    $0x5,%eax
  80208b:	e8 0c ff ff ff       	call   801f9c <fsipc>
  802090:	85 c0                	test   %eax,%eax
  802092:	78 2b                	js     8020bf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802094:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80209b:	00 
  80209c:	89 1c 24             	mov    %ebx,(%esp)
  80209f:	e8 66 ea ff ff       	call   800b0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8020a4:	a1 80 60 80 00       	mov    0x806080,%eax
  8020a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8020af:	a1 84 60 80 00       	mov    0x806084,%eax
  8020b4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8020ba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8020bf:	83 c4 14             	add    $0x14,%esp
  8020c2:	5b                   	pop    %ebx
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    

008020c5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 18             	sub    $0x18,%esp
  8020cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8020d3:	76 05                	jbe    8020da <devfile_write+0x15>
  8020d5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  8020da:	8b 55 08             	mov    0x8(%ebp),%edx
  8020dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8020e0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  8020e6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  8020eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8020fd:	e8 f3 eb ff ff       	call   800cf5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  802102:	ba 00 00 00 00       	mov    $0x0,%edx
  802107:	b8 04 00 00 00       	mov    $0x4,%eax
  80210c:	e8 8b fe ff ff       	call   801f9c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  802111:	c9                   	leave  
  802112:	c3                   	ret    

00802113 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802113:	55                   	push   %ebp
  802114:	89 e5                	mov    %esp,%ebp
  802116:	53                   	push   %ebx
  802117:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80211a:	8b 45 08             	mov    0x8(%ebp),%eax
  80211d:	8b 40 0c             	mov    0xc(%eax),%eax
  802120:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  802125:	8b 45 10             	mov    0x10(%ebp),%eax
  802128:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  80212d:	ba 00 00 00 00       	mov    $0x0,%edx
  802132:	b8 03 00 00 00       	mov    $0x3,%eax
  802137:	e8 60 fe ff ff       	call   801f9c <fsipc>
  80213c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80213e:	85 c0                	test   %eax,%eax
  802140:	78 17                	js     802159 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802142:	89 44 24 08          	mov    %eax,0x8(%esp)
  802146:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80214d:	00 
  80214e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802151:	89 04 24             	mov    %eax,(%esp)
  802154:	e8 9c eb ff ff       	call   800cf5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802159:	89 d8                	mov    %ebx,%eax
  80215b:	83 c4 14             	add    $0x14,%esp
  80215e:	5b                   	pop    %ebx
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    

00802161 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	53                   	push   %ebx
  802165:	83 ec 14             	sub    $0x14,%esp
  802168:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80216b:	89 1c 24             	mov    %ebx,(%esp)
  80216e:	e8 4d e9 ff ff       	call   800ac0 <strlen>
  802173:	89 c2                	mov    %eax,%edx
  802175:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80217a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802180:	7f 1f                	jg     8021a1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802182:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802186:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80218d:	e8 78 e9 ff ff       	call   800b0a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802192:	ba 00 00 00 00       	mov    $0x0,%edx
  802197:	b8 07 00 00 00       	mov    $0x7,%eax
  80219c:	e8 fb fd ff ff       	call   801f9c <fsipc>
}
  8021a1:	83 c4 14             	add    $0x14,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	83 ec 28             	sub    $0x28,%esp
  8021ad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8021b0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8021b3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  8021b6:	89 34 24             	mov    %esi,(%esp)
  8021b9:	e8 02 e9 ff ff       	call   800ac0 <strlen>
  8021be:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8021c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021c8:	7f 6d                	jg     802237 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8021ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021cd:	89 04 24             	mov    %eax,(%esp)
  8021d0:	e8 d6 f7 ff ff       	call   8019ab <fd_alloc>
  8021d5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8021d7:	85 c0                	test   %eax,%eax
  8021d9:	78 5c                	js     802237 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8021db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021de:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8021e3:	89 34 24             	mov    %esi,(%esp)
  8021e6:	e8 d5 e8 ff ff       	call   800ac0 <strlen>
  8021eb:	83 c0 01             	add    $0x1,%eax
  8021ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8021fd:	e8 f3 ea ff ff       	call   800cf5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  802202:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802205:	b8 01 00 00 00       	mov    $0x1,%eax
  80220a:	e8 8d fd ff ff       	call   801f9c <fsipc>
  80220f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802211:	85 c0                	test   %eax,%eax
  802213:	79 15                	jns    80222a <open+0x83>
             fd_close(fd,0);
  802215:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80221c:	00 
  80221d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802220:	89 04 24             	mov    %eax,(%esp)
  802223:	e8 37 fb ff ff       	call   801d5f <fd_close>
             return r;
  802228:	eb 0d                	jmp    802237 <open+0x90>
        }
        return fd2num(fd);
  80222a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222d:	89 04 24             	mov    %eax,(%esp)
  802230:	e8 4b f7 ff ff       	call   801980 <fd2num>
  802235:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802237:	89 d8                	mov    %ebx,%eax
  802239:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80223c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80223f:	89 ec                	mov    %ebp,%esp
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    
	...

00802250 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802250:	55                   	push   %ebp
  802251:	89 e5                	mov    %esp,%ebp
  802253:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802256:	c7 44 24 04 70 31 80 	movl   $0x803170,0x4(%esp)
  80225d:	00 
  80225e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802261:	89 04 24             	mov    %eax,(%esp)
  802264:	e8 a1 e8 ff ff       	call   800b0a <strcpy>
	return 0;
}
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	53                   	push   %ebx
  802274:	83 ec 14             	sub    $0x14,%esp
  802277:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80227a:	89 1c 24             	mov    %ebx,(%esp)
  80227d:	e8 da 06 00 00       	call   80295c <pageref>
  802282:	89 c2                	mov    %eax,%edx
  802284:	b8 00 00 00 00       	mov    $0x0,%eax
  802289:	83 fa 01             	cmp    $0x1,%edx
  80228c:	75 0b                	jne    802299 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80228e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802291:	89 04 24             	mov    %eax,(%esp)
  802294:	e8 b9 02 00 00       	call   802552 <nsipc_close>
	else
		return 0;
}
  802299:	83 c4 14             	add    $0x14,%esp
  80229c:	5b                   	pop    %ebx
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    

0080229f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8022a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8022ac:	00 
  8022ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022be:	8b 40 0c             	mov    0xc(%eax),%eax
  8022c1:	89 04 24             	mov    %eax,(%esp)
  8022c4:	e8 c5 02 00 00       	call   80258e <nsipc_send>
}
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    

008022cb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8022d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8022d8:	00 
  8022d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8022dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ed:	89 04 24             	mov    %eax,(%esp)
  8022f0:	e8 0c 03 00 00       	call   802601 <nsipc_recv>
}
  8022f5:	c9                   	leave  
  8022f6:	c3                   	ret    

008022f7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8022f7:	55                   	push   %ebp
  8022f8:	89 e5                	mov    %esp,%ebp
  8022fa:	56                   	push   %esi
  8022fb:	53                   	push   %ebx
  8022fc:	83 ec 20             	sub    $0x20,%esp
  8022ff:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802304:	89 04 24             	mov    %eax,(%esp)
  802307:	e8 9f f6 ff ff       	call   8019ab <fd_alloc>
  80230c:	89 c3                	mov    %eax,%ebx
  80230e:	85 c0                	test   %eax,%eax
  802310:	78 21                	js     802333 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802312:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802319:	00 
  80231a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802321:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802328:	e8 0b f1 ff ff       	call   801438 <sys_page_alloc>
  80232d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80232f:	85 c0                	test   %eax,%eax
  802331:	79 0a                	jns    80233d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802333:	89 34 24             	mov    %esi,(%esp)
  802336:	e8 17 02 00 00       	call   802552 <nsipc_close>
		return r;
  80233b:	eb 28                	jmp    802365 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80233d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802343:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802346:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802348:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802355:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235b:	89 04 24             	mov    %eax,(%esp)
  80235e:	e8 1d f6 ff ff       	call   801980 <fd2num>
  802363:	89 c3                	mov    %eax,%ebx
}
  802365:	89 d8                	mov    %ebx,%eax
  802367:	83 c4 20             	add    $0x20,%esp
  80236a:	5b                   	pop    %ebx
  80236b:	5e                   	pop    %esi
  80236c:	5d                   	pop    %ebp
  80236d:	c3                   	ret    

0080236e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802374:	8b 45 10             	mov    0x10(%ebp),%eax
  802377:	89 44 24 08          	mov    %eax,0x8(%esp)
  80237b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802382:	8b 45 08             	mov    0x8(%ebp),%eax
  802385:	89 04 24             	mov    %eax,(%esp)
  802388:	e8 79 01 00 00       	call   802506 <nsipc_socket>
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 05                	js     802396 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802391:	e8 61 ff ff ff       	call   8022f7 <alloc_sockfd>
}
  802396:	c9                   	leave  
  802397:	c3                   	ret    

00802398 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
  80239b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80239e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8023a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a5:	89 04 24             	mov    %eax,(%esp)
  8023a8:	e8 70 f6 ff ff       	call   801a1d <fd_lookup>
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	78 15                	js     8023c6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8023b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023b4:	8b 0a                	mov    (%edx),%ecx
  8023b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8023bb:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8023c1:	75 03                	jne    8023c6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8023c3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8023c6:	c9                   	leave  
  8023c7:	c3                   	ret    

008023c8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d1:	e8 c2 ff ff ff       	call   802398 <fd2sockid>
  8023d6:	85 c0                	test   %eax,%eax
  8023d8:	78 0f                	js     8023e9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8023da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e1:	89 04 24             	mov    %eax,(%esp)
  8023e4:	e8 47 01 00 00       	call   802530 <nsipc_listen>
}
  8023e9:	c9                   	leave  
  8023ea:	c3                   	ret    

008023eb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f4:	e8 9f ff ff ff       	call   802398 <fd2sockid>
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	78 16                	js     802413 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8023fd:	8b 55 10             	mov    0x10(%ebp),%edx
  802400:	89 54 24 08          	mov    %edx,0x8(%esp)
  802404:	8b 55 0c             	mov    0xc(%ebp),%edx
  802407:	89 54 24 04          	mov    %edx,0x4(%esp)
  80240b:	89 04 24             	mov    %eax,(%esp)
  80240e:	e8 6e 02 00 00       	call   802681 <nsipc_connect>
}
  802413:	c9                   	leave  
  802414:	c3                   	ret    

00802415 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80241b:	8b 45 08             	mov    0x8(%ebp),%eax
  80241e:	e8 75 ff ff ff       	call   802398 <fd2sockid>
  802423:	85 c0                	test   %eax,%eax
  802425:	78 0f                	js     802436 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802427:	8b 55 0c             	mov    0xc(%ebp),%edx
  80242a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80242e:	89 04 24             	mov    %eax,(%esp)
  802431:	e8 36 01 00 00       	call   80256c <nsipc_shutdown>
}
  802436:	c9                   	leave  
  802437:	c3                   	ret    

00802438 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80243e:	8b 45 08             	mov    0x8(%ebp),%eax
  802441:	e8 52 ff ff ff       	call   802398 <fd2sockid>
  802446:	85 c0                	test   %eax,%eax
  802448:	78 16                	js     802460 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80244a:	8b 55 10             	mov    0x10(%ebp),%edx
  80244d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802451:	8b 55 0c             	mov    0xc(%ebp),%edx
  802454:	89 54 24 04          	mov    %edx,0x4(%esp)
  802458:	89 04 24             	mov    %eax,(%esp)
  80245b:	e8 60 02 00 00       	call   8026c0 <nsipc_bind>
}
  802460:	c9                   	leave  
  802461:	c3                   	ret    

00802462 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802462:	55                   	push   %ebp
  802463:	89 e5                	mov    %esp,%ebp
  802465:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802468:	8b 45 08             	mov    0x8(%ebp),%eax
  80246b:	e8 28 ff ff ff       	call   802398 <fd2sockid>
  802470:	85 c0                	test   %eax,%eax
  802472:	78 1f                	js     802493 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802474:	8b 55 10             	mov    0x10(%ebp),%edx
  802477:	89 54 24 08          	mov    %edx,0x8(%esp)
  80247b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80247e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802482:	89 04 24             	mov    %eax,(%esp)
  802485:	e8 75 02 00 00       	call   8026ff <nsipc_accept>
  80248a:	85 c0                	test   %eax,%eax
  80248c:	78 05                	js     802493 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80248e:	e8 64 fe ff ff       	call   8022f7 <alloc_sockfd>
}
  802493:	c9                   	leave  
  802494:	c3                   	ret    
	...

008024a0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 14             	sub    $0x14,%esp
  8024a7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8024a9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8024b0:	75 11                	jne    8024c3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8024b2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8024b9:	e8 62 03 00 00       	call   802820 <ipc_find_env>
  8024be:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8024c3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8024ca:	00 
  8024cb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8024d2:	00 
  8024d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024d7:	a1 04 50 80 00       	mov    0x805004,%eax
  8024dc:	89 04 24             	mov    %eax,(%esp)
  8024df:	e8 87 03 00 00       	call   80286b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8024e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024eb:	00 
  8024ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8024f3:	00 
  8024f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024fb:	e8 e9 03 00 00       	call   8028e9 <ipc_recv>
}
  802500:	83 c4 14             	add    $0x14,%esp
  802503:	5b                   	pop    %ebx
  802504:	5d                   	pop    %ebp
  802505:	c3                   	ret    

00802506 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802506:	55                   	push   %ebp
  802507:	89 e5                	mov    %esp,%ebp
  802509:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80250c:	8b 45 08             	mov    0x8(%ebp),%eax
  80250f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802514:	8b 45 0c             	mov    0xc(%ebp),%eax
  802517:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80251c:	8b 45 10             	mov    0x10(%ebp),%eax
  80251f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802524:	b8 09 00 00 00       	mov    $0x9,%eax
  802529:	e8 72 ff ff ff       	call   8024a0 <nsipc>
}
  80252e:	c9                   	leave  
  80252f:	c3                   	ret    

00802530 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802530:	55                   	push   %ebp
  802531:	89 e5                	mov    %esp,%ebp
  802533:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802536:	8b 45 08             	mov    0x8(%ebp),%eax
  802539:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80253e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802541:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802546:	b8 06 00 00 00       	mov    $0x6,%eax
  80254b:	e8 50 ff ff ff       	call   8024a0 <nsipc>
}
  802550:	c9                   	leave  
  802551:	c3                   	ret    

00802552 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802552:	55                   	push   %ebp
  802553:	89 e5                	mov    %esp,%ebp
  802555:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802558:	8b 45 08             	mov    0x8(%ebp),%eax
  80255b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802560:	b8 04 00 00 00       	mov    $0x4,%eax
  802565:	e8 36 ff ff ff       	call   8024a0 <nsipc>
}
  80256a:	c9                   	leave  
  80256b:	c3                   	ret    

0080256c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80256c:	55                   	push   %ebp
  80256d:	89 e5                	mov    %esp,%ebp
  80256f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802572:	8b 45 08             	mov    0x8(%ebp),%eax
  802575:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80257a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80257d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802582:	b8 03 00 00 00       	mov    $0x3,%eax
  802587:	e8 14 ff ff ff       	call   8024a0 <nsipc>
}
  80258c:	c9                   	leave  
  80258d:	c3                   	ret    

0080258e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80258e:	55                   	push   %ebp
  80258f:	89 e5                	mov    %esp,%ebp
  802591:	53                   	push   %ebx
  802592:	83 ec 14             	sub    $0x14,%esp
  802595:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802598:	8b 45 08             	mov    0x8(%ebp),%eax
  80259b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8025a0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8025a6:	7e 24                	jle    8025cc <nsipc_send+0x3e>
  8025a8:	c7 44 24 0c 7c 31 80 	movl   $0x80317c,0xc(%esp)
  8025af:	00 
  8025b0:	c7 44 24 08 88 31 80 	movl   $0x803188,0x8(%esp)
  8025b7:	00 
  8025b8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8025bf:	00 
  8025c0:	c7 04 24 9d 31 80 00 	movl   $0x80319d,(%esp)
  8025c7:	e8 88 01 00 00       	call   802754 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8025cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8025de:	e8 12 e7 ff ff       	call   800cf5 <memmove>
	nsipcbuf.send.req_size = size;
  8025e3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8025e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8025ec:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8025f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8025f6:	e8 a5 fe ff ff       	call   8024a0 <nsipc>
}
  8025fb:	83 c4 14             	add    $0x14,%esp
  8025fe:	5b                   	pop    %ebx
  8025ff:	5d                   	pop    %ebp
  802600:	c3                   	ret    

00802601 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802601:	55                   	push   %ebp
  802602:	89 e5                	mov    %esp,%ebp
  802604:	56                   	push   %esi
  802605:	53                   	push   %ebx
  802606:	83 ec 10             	sub    $0x10,%esp
  802609:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80260c:	8b 45 08             	mov    0x8(%ebp),%eax
  80260f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802614:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80261a:	8b 45 14             	mov    0x14(%ebp),%eax
  80261d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802622:	b8 07 00 00 00       	mov    $0x7,%eax
  802627:	e8 74 fe ff ff       	call   8024a0 <nsipc>
  80262c:	89 c3                	mov    %eax,%ebx
  80262e:	85 c0                	test   %eax,%eax
  802630:	78 46                	js     802678 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802632:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802637:	7f 04                	jg     80263d <nsipc_recv+0x3c>
  802639:	39 c6                	cmp    %eax,%esi
  80263b:	7d 24                	jge    802661 <nsipc_recv+0x60>
  80263d:	c7 44 24 0c a9 31 80 	movl   $0x8031a9,0xc(%esp)
  802644:	00 
  802645:	c7 44 24 08 88 31 80 	movl   $0x803188,0x8(%esp)
  80264c:	00 
  80264d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802654:	00 
  802655:	c7 04 24 9d 31 80 00 	movl   $0x80319d,(%esp)
  80265c:	e8 f3 00 00 00       	call   802754 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802661:	89 44 24 08          	mov    %eax,0x8(%esp)
  802665:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80266c:	00 
  80266d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802670:	89 04 24             	mov    %eax,(%esp)
  802673:	e8 7d e6 ff ff       	call   800cf5 <memmove>
	}

	return r;
}
  802678:	89 d8                	mov    %ebx,%eax
  80267a:	83 c4 10             	add    $0x10,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5d                   	pop    %ebp
  802680:	c3                   	ret    

00802681 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802681:	55                   	push   %ebp
  802682:	89 e5                	mov    %esp,%ebp
  802684:	53                   	push   %ebx
  802685:	83 ec 14             	sub    $0x14,%esp
  802688:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80268b:	8b 45 08             	mov    0x8(%ebp),%eax
  80268e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802693:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802697:	8b 45 0c             	mov    0xc(%ebp),%eax
  80269a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80269e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8026a5:	e8 4b e6 ff ff       	call   800cf5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8026aa:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8026b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8026b5:	e8 e6 fd ff ff       	call   8024a0 <nsipc>
}
  8026ba:	83 c4 14             	add    $0x14,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5d                   	pop    %ebp
  8026bf:	c3                   	ret    

008026c0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8026c0:	55                   	push   %ebp
  8026c1:	89 e5                	mov    %esp,%ebp
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 14             	sub    $0x14,%esp
  8026c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8026ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8026d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026dd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8026e4:	e8 0c e6 ff ff       	call   800cf5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8026e9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8026ef:	b8 02 00 00 00       	mov    $0x2,%eax
  8026f4:	e8 a7 fd ff ff       	call   8024a0 <nsipc>
}
  8026f9:	83 c4 14             	add    $0x14,%esp
  8026fc:	5b                   	pop    %ebx
  8026fd:	5d                   	pop    %ebp
  8026fe:	c3                   	ret    

008026ff <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8026ff:	55                   	push   %ebp
  802700:	89 e5                	mov    %esp,%ebp
  802702:	83 ec 18             	sub    $0x18,%esp
  802705:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802708:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80270b:	8b 45 08             	mov    0x8(%ebp),%eax
  80270e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802713:	b8 01 00 00 00       	mov    $0x1,%eax
  802718:	e8 83 fd ff ff       	call   8024a0 <nsipc>
  80271d:	89 c3                	mov    %eax,%ebx
  80271f:	85 c0                	test   %eax,%eax
  802721:	78 25                	js     802748 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802723:	be 10 70 80 00       	mov    $0x807010,%esi
  802728:	8b 06                	mov    (%esi),%eax
  80272a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80272e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802735:	00 
  802736:	8b 45 0c             	mov    0xc(%ebp),%eax
  802739:	89 04 24             	mov    %eax,(%esp)
  80273c:	e8 b4 e5 ff ff       	call   800cf5 <memmove>
		*addrlen = ret->ret_addrlen;
  802741:	8b 16                	mov    (%esi),%edx
  802743:	8b 45 10             	mov    0x10(%ebp),%eax
  802746:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80274d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802750:	89 ec                	mov    %ebp,%esp
  802752:	5d                   	pop    %ebp
  802753:	c3                   	ret    

00802754 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802754:	55                   	push   %ebp
  802755:	89 e5                	mov    %esp,%ebp
  802757:	56                   	push   %esi
  802758:	53                   	push   %ebx
  802759:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80275c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80275f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  802765:	e8 bd ed ff ff       	call   801527 <sys_getenvid>
  80276a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80276d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802771:	8b 55 08             	mov    0x8(%ebp),%edx
  802774:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802778:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80277c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802780:	c7 04 24 c0 31 80 00 	movl   $0x8031c0,(%esp)
  802787:	e8 55 da ff ff       	call   8001e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80278c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802790:	8b 45 10             	mov    0x10(%ebp),%eax
  802793:	89 04 24             	mov    %eax,(%esp)
  802796:	e8 e5 d9 ff ff       	call   800180 <vcprintf>
	cprintf("\n");
  80279b:	c7 04 24 60 31 80 00 	movl   $0x803160,(%esp)
  8027a2:	e8 3a da ff ff       	call   8001e1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8027a7:	cc                   	int3   
  8027a8:	eb fd                	jmp    8027a7 <_panic+0x53>
	...

008027ac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
  8027af:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8027b2:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8027b9:	75 30                	jne    8027eb <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8027bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8027c2:	00 
  8027c3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8027ca:	ee 
  8027cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027d2:	e8 61 ec ff ff       	call   801438 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8027d7:	c7 44 24 04 f8 27 80 	movl   $0x8027f8,0x4(%esp)
  8027de:	00 
  8027df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027e6:	e8 2f ea ff ff       	call   80121a <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ee:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8027f3:	c9                   	leave  
  8027f4:	c3                   	ret    
  8027f5:	00 00                	add    %al,(%eax)
	...

008027f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027f9:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8027fe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802800:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  802803:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  802807:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  80280b:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  80280e:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  802810:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  802814:	83 c4 08             	add    $0x8,%esp
        popal
  802817:	61                   	popa   
        addl $0x4,%esp
  802818:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  80281b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  80281c:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80281d:	c3                   	ret    
	...

00802820 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802820:	55                   	push   %ebp
  802821:	89 e5                	mov    %esp,%ebp
  802823:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802826:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80282c:	b8 01 00 00 00       	mov    $0x1,%eax
  802831:	39 ca                	cmp    %ecx,%edx
  802833:	75 04                	jne    802839 <ipc_find_env+0x19>
  802835:	b0 00                	mov    $0x0,%al
  802837:	eb 12                	jmp    80284b <ipc_find_env+0x2b>
  802839:	89 c2                	mov    %eax,%edx
  80283b:	c1 e2 07             	shl    $0x7,%edx
  80283e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802845:	8b 12                	mov    (%edx),%edx
  802847:	39 ca                	cmp    %ecx,%edx
  802849:	75 10                	jne    80285b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80284b:	89 c2                	mov    %eax,%edx
  80284d:	c1 e2 07             	shl    $0x7,%edx
  802850:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802857:	8b 00                	mov    (%eax),%eax
  802859:	eb 0e                	jmp    802869 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80285b:	83 c0 01             	add    $0x1,%eax
  80285e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802863:	75 d4                	jne    802839 <ipc_find_env+0x19>
  802865:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802869:	5d                   	pop    %ebp
  80286a:	c3                   	ret    

0080286b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80286b:	55                   	push   %ebp
  80286c:	89 e5                	mov    %esp,%ebp
  80286e:	57                   	push   %edi
  80286f:	56                   	push   %esi
  802870:	53                   	push   %ebx
  802871:	83 ec 1c             	sub    $0x1c,%esp
  802874:	8b 75 08             	mov    0x8(%ebp),%esi
  802877:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80287a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80287d:	85 db                	test   %ebx,%ebx
  80287f:	74 19                	je     80289a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802881:	8b 45 14             	mov    0x14(%ebp),%eax
  802884:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802888:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80288c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802890:	89 34 24             	mov    %esi,(%esp)
  802893:	e8 41 e9 ff ff       	call   8011d9 <sys_ipc_try_send>
  802898:	eb 1b                	jmp    8028b5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80289a:	8b 45 14             	mov    0x14(%ebp),%eax
  80289d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028a1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8028a8:	ee 
  8028a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028ad:	89 34 24             	mov    %esi,(%esp)
  8028b0:	e8 24 e9 ff ff       	call   8011d9 <sys_ipc_try_send>
           if(ret == 0)
  8028b5:	85 c0                	test   %eax,%eax
  8028b7:	74 28                	je     8028e1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8028b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028bc:	74 1c                	je     8028da <ipc_send+0x6f>
              panic("ipc send error");
  8028be:	c7 44 24 08 e4 31 80 	movl   $0x8031e4,0x8(%esp)
  8028c5:	00 
  8028c6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8028cd:	00 
  8028ce:	c7 04 24 f3 31 80 00 	movl   $0x8031f3,(%esp)
  8028d5:	e8 7a fe ff ff       	call   802754 <_panic>
           sys_yield();
  8028da:	e8 c6 eb ff ff       	call   8014a5 <sys_yield>
        }
  8028df:	eb 9c                	jmp    80287d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8028e1:	83 c4 1c             	add    $0x1c,%esp
  8028e4:	5b                   	pop    %ebx
  8028e5:	5e                   	pop    %esi
  8028e6:	5f                   	pop    %edi
  8028e7:	5d                   	pop    %ebp
  8028e8:	c3                   	ret    

008028e9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028e9:	55                   	push   %ebp
  8028ea:	89 e5                	mov    %esp,%ebp
  8028ec:	56                   	push   %esi
  8028ed:	53                   	push   %ebx
  8028ee:	83 ec 10             	sub    $0x10,%esp
  8028f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8028f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8028fa:	85 c0                	test   %eax,%eax
  8028fc:	75 0e                	jne    80290c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8028fe:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802905:	e8 64 e8 ff ff       	call   80116e <sys_ipc_recv>
  80290a:	eb 08                	jmp    802914 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80290c:	89 04 24             	mov    %eax,(%esp)
  80290f:	e8 5a e8 ff ff       	call   80116e <sys_ipc_recv>
        if(ret == 0){
  802914:	85 c0                	test   %eax,%eax
  802916:	75 26                	jne    80293e <ipc_recv+0x55>
           if(from_env_store)
  802918:	85 f6                	test   %esi,%esi
  80291a:	74 0a                	je     802926 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80291c:	a1 08 50 80 00       	mov    0x805008,%eax
  802921:	8b 40 78             	mov    0x78(%eax),%eax
  802924:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802926:	85 db                	test   %ebx,%ebx
  802928:	74 0a                	je     802934 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80292a:	a1 08 50 80 00       	mov    0x805008,%eax
  80292f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802932:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802934:	a1 08 50 80 00       	mov    0x805008,%eax
  802939:	8b 40 74             	mov    0x74(%eax),%eax
  80293c:	eb 14                	jmp    802952 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80293e:	85 f6                	test   %esi,%esi
  802940:	74 06                	je     802948 <ipc_recv+0x5f>
              *from_env_store = 0;
  802942:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802948:	85 db                	test   %ebx,%ebx
  80294a:	74 06                	je     802952 <ipc_recv+0x69>
              *perm_store = 0;
  80294c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802952:	83 c4 10             	add    $0x10,%esp
  802955:	5b                   	pop    %ebx
  802956:	5e                   	pop    %esi
  802957:	5d                   	pop    %ebp
  802958:	c3                   	ret    
  802959:	00 00                	add    %al,(%eax)
	...

0080295c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80295c:	55                   	push   %ebp
  80295d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80295f:	8b 45 08             	mov    0x8(%ebp),%eax
  802962:	89 c2                	mov    %eax,%edx
  802964:	c1 ea 16             	shr    $0x16,%edx
  802967:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80296e:	f6 c2 01             	test   $0x1,%dl
  802971:	74 20                	je     802993 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802973:	c1 e8 0c             	shr    $0xc,%eax
  802976:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80297d:	a8 01                	test   $0x1,%al
  80297f:	74 12                	je     802993 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802981:	c1 e8 0c             	shr    $0xc,%eax
  802984:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802989:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80298e:	0f b7 c0             	movzwl %ax,%eax
  802991:	eb 05                	jmp    802998 <pageref+0x3c>
  802993:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802998:	5d                   	pop    %ebp
  802999:	c3                   	ret    
  80299a:	00 00                	add    %al,(%eax)
  80299c:	00 00                	add    %al,(%eax)
	...

008029a0 <__udivdi3>:
  8029a0:	55                   	push   %ebp
  8029a1:	89 e5                	mov    %esp,%ebp
  8029a3:	57                   	push   %edi
  8029a4:	56                   	push   %esi
  8029a5:	83 ec 10             	sub    $0x10,%esp
  8029a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8029ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8029ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8029b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029b4:	85 c0                	test   %eax,%eax
  8029b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8029b9:	75 35                	jne    8029f0 <__udivdi3+0x50>
  8029bb:	39 fe                	cmp    %edi,%esi
  8029bd:	77 61                	ja     802a20 <__udivdi3+0x80>
  8029bf:	85 f6                	test   %esi,%esi
  8029c1:	75 0b                	jne    8029ce <__udivdi3+0x2e>
  8029c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8029c8:	31 d2                	xor    %edx,%edx
  8029ca:	f7 f6                	div    %esi
  8029cc:	89 c6                	mov    %eax,%esi
  8029ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8029d1:	31 d2                	xor    %edx,%edx
  8029d3:	89 f8                	mov    %edi,%eax
  8029d5:	f7 f6                	div    %esi
  8029d7:	89 c7                	mov    %eax,%edi
  8029d9:	89 c8                	mov    %ecx,%eax
  8029db:	f7 f6                	div    %esi
  8029dd:	89 c1                	mov    %eax,%ecx
  8029df:	89 fa                	mov    %edi,%edx
  8029e1:	89 c8                	mov    %ecx,%eax
  8029e3:	83 c4 10             	add    $0x10,%esp
  8029e6:	5e                   	pop    %esi
  8029e7:	5f                   	pop    %edi
  8029e8:	5d                   	pop    %ebp
  8029e9:	c3                   	ret    
  8029ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029f0:	39 f8                	cmp    %edi,%eax
  8029f2:	77 1c                	ja     802a10 <__udivdi3+0x70>
  8029f4:	0f bd d0             	bsr    %eax,%edx
  8029f7:	83 f2 1f             	xor    $0x1f,%edx
  8029fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8029fd:	75 39                	jne    802a38 <__udivdi3+0x98>
  8029ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802a02:	0f 86 a0 00 00 00    	jbe    802aa8 <__udivdi3+0x108>
  802a08:	39 f8                	cmp    %edi,%eax
  802a0a:	0f 82 98 00 00 00    	jb     802aa8 <__udivdi3+0x108>
  802a10:	31 ff                	xor    %edi,%edi
  802a12:	31 c9                	xor    %ecx,%ecx
  802a14:	89 c8                	mov    %ecx,%eax
  802a16:	89 fa                	mov    %edi,%edx
  802a18:	83 c4 10             	add    $0x10,%esp
  802a1b:	5e                   	pop    %esi
  802a1c:	5f                   	pop    %edi
  802a1d:	5d                   	pop    %ebp
  802a1e:	c3                   	ret    
  802a1f:	90                   	nop
  802a20:	89 d1                	mov    %edx,%ecx
  802a22:	89 fa                	mov    %edi,%edx
  802a24:	89 c8                	mov    %ecx,%eax
  802a26:	31 ff                	xor    %edi,%edi
  802a28:	f7 f6                	div    %esi
  802a2a:	89 c1                	mov    %eax,%ecx
  802a2c:	89 fa                	mov    %edi,%edx
  802a2e:	89 c8                	mov    %ecx,%eax
  802a30:	83 c4 10             	add    $0x10,%esp
  802a33:	5e                   	pop    %esi
  802a34:	5f                   	pop    %edi
  802a35:	5d                   	pop    %ebp
  802a36:	c3                   	ret    
  802a37:	90                   	nop
  802a38:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a3c:	89 f2                	mov    %esi,%edx
  802a3e:	d3 e0                	shl    %cl,%eax
  802a40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a43:	b8 20 00 00 00       	mov    $0x20,%eax
  802a48:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802a4b:	89 c1                	mov    %eax,%ecx
  802a4d:	d3 ea                	shr    %cl,%edx
  802a4f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a53:	0b 55 ec             	or     -0x14(%ebp),%edx
  802a56:	d3 e6                	shl    %cl,%esi
  802a58:	89 c1                	mov    %eax,%ecx
  802a5a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802a5d:	89 fe                	mov    %edi,%esi
  802a5f:	d3 ee                	shr    %cl,%esi
  802a61:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a65:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a6b:	d3 e7                	shl    %cl,%edi
  802a6d:	89 c1                	mov    %eax,%ecx
  802a6f:	d3 ea                	shr    %cl,%edx
  802a71:	09 d7                	or     %edx,%edi
  802a73:	89 f2                	mov    %esi,%edx
  802a75:	89 f8                	mov    %edi,%eax
  802a77:	f7 75 ec             	divl   -0x14(%ebp)
  802a7a:	89 d6                	mov    %edx,%esi
  802a7c:	89 c7                	mov    %eax,%edi
  802a7e:	f7 65 e8             	mull   -0x18(%ebp)
  802a81:	39 d6                	cmp    %edx,%esi
  802a83:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802a86:	72 30                	jb     802ab8 <__udivdi3+0x118>
  802a88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a8b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802a8f:	d3 e2                	shl    %cl,%edx
  802a91:	39 c2                	cmp    %eax,%edx
  802a93:	73 05                	jae    802a9a <__udivdi3+0xfa>
  802a95:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802a98:	74 1e                	je     802ab8 <__udivdi3+0x118>
  802a9a:	89 f9                	mov    %edi,%ecx
  802a9c:	31 ff                	xor    %edi,%edi
  802a9e:	e9 71 ff ff ff       	jmp    802a14 <__udivdi3+0x74>
  802aa3:	90                   	nop
  802aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802aa8:	31 ff                	xor    %edi,%edi
  802aaa:	b9 01 00 00 00       	mov    $0x1,%ecx
  802aaf:	e9 60 ff ff ff       	jmp    802a14 <__udivdi3+0x74>
  802ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ab8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802abb:	31 ff                	xor    %edi,%edi
  802abd:	89 c8                	mov    %ecx,%eax
  802abf:	89 fa                	mov    %edi,%edx
  802ac1:	83 c4 10             	add    $0x10,%esp
  802ac4:	5e                   	pop    %esi
  802ac5:	5f                   	pop    %edi
  802ac6:	5d                   	pop    %ebp
  802ac7:	c3                   	ret    
	...

00802ad0 <__umoddi3>:
  802ad0:	55                   	push   %ebp
  802ad1:	89 e5                	mov    %esp,%ebp
  802ad3:	57                   	push   %edi
  802ad4:	56                   	push   %esi
  802ad5:	83 ec 20             	sub    $0x20,%esp
  802ad8:	8b 55 14             	mov    0x14(%ebp),%edx
  802adb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ade:	8b 7d 10             	mov    0x10(%ebp),%edi
  802ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ae4:	85 d2                	test   %edx,%edx
  802ae6:	89 c8                	mov    %ecx,%eax
  802ae8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802aeb:	75 13                	jne    802b00 <__umoddi3+0x30>
  802aed:	39 f7                	cmp    %esi,%edi
  802aef:	76 3f                	jbe    802b30 <__umoddi3+0x60>
  802af1:	89 f2                	mov    %esi,%edx
  802af3:	f7 f7                	div    %edi
  802af5:	89 d0                	mov    %edx,%eax
  802af7:	31 d2                	xor    %edx,%edx
  802af9:	83 c4 20             	add    $0x20,%esp
  802afc:	5e                   	pop    %esi
  802afd:	5f                   	pop    %edi
  802afe:	5d                   	pop    %ebp
  802aff:	c3                   	ret    
  802b00:	39 f2                	cmp    %esi,%edx
  802b02:	77 4c                	ja     802b50 <__umoddi3+0x80>
  802b04:	0f bd ca             	bsr    %edx,%ecx
  802b07:	83 f1 1f             	xor    $0x1f,%ecx
  802b0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802b0d:	75 51                	jne    802b60 <__umoddi3+0x90>
  802b0f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802b12:	0f 87 e0 00 00 00    	ja     802bf8 <__umoddi3+0x128>
  802b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b1b:	29 f8                	sub    %edi,%eax
  802b1d:	19 d6                	sbb    %edx,%esi
  802b1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b25:	89 f2                	mov    %esi,%edx
  802b27:	83 c4 20             	add    $0x20,%esp
  802b2a:	5e                   	pop    %esi
  802b2b:	5f                   	pop    %edi
  802b2c:	5d                   	pop    %ebp
  802b2d:	c3                   	ret    
  802b2e:	66 90                	xchg   %ax,%ax
  802b30:	85 ff                	test   %edi,%edi
  802b32:	75 0b                	jne    802b3f <__umoddi3+0x6f>
  802b34:	b8 01 00 00 00       	mov    $0x1,%eax
  802b39:	31 d2                	xor    %edx,%edx
  802b3b:	f7 f7                	div    %edi
  802b3d:	89 c7                	mov    %eax,%edi
  802b3f:	89 f0                	mov    %esi,%eax
  802b41:	31 d2                	xor    %edx,%edx
  802b43:	f7 f7                	div    %edi
  802b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b48:	f7 f7                	div    %edi
  802b4a:	eb a9                	jmp    802af5 <__umoddi3+0x25>
  802b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b50:	89 c8                	mov    %ecx,%eax
  802b52:	89 f2                	mov    %esi,%edx
  802b54:	83 c4 20             	add    $0x20,%esp
  802b57:	5e                   	pop    %esi
  802b58:	5f                   	pop    %edi
  802b59:	5d                   	pop    %ebp
  802b5a:	c3                   	ret    
  802b5b:	90                   	nop
  802b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b64:	d3 e2                	shl    %cl,%edx
  802b66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b69:	ba 20 00 00 00       	mov    $0x20,%edx
  802b6e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802b71:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802b74:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b78:	89 fa                	mov    %edi,%edx
  802b7a:	d3 ea                	shr    %cl,%edx
  802b7c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b80:	0b 55 f4             	or     -0xc(%ebp),%edx
  802b83:	d3 e7                	shl    %cl,%edi
  802b85:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b89:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802b8c:	89 f2                	mov    %esi,%edx
  802b8e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802b91:	89 c7                	mov    %eax,%edi
  802b93:	d3 ea                	shr    %cl,%edx
  802b95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802b9c:	89 c2                	mov    %eax,%edx
  802b9e:	d3 e6                	shl    %cl,%esi
  802ba0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802ba4:	d3 ea                	shr    %cl,%edx
  802ba6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802baa:	09 d6                	or     %edx,%esi
  802bac:	89 f0                	mov    %esi,%eax
  802bae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802bb1:	d3 e7                	shl    %cl,%edi
  802bb3:	89 f2                	mov    %esi,%edx
  802bb5:	f7 75 f4             	divl   -0xc(%ebp)
  802bb8:	89 d6                	mov    %edx,%esi
  802bba:	f7 65 e8             	mull   -0x18(%ebp)
  802bbd:	39 d6                	cmp    %edx,%esi
  802bbf:	72 2b                	jb     802bec <__umoddi3+0x11c>
  802bc1:	39 c7                	cmp    %eax,%edi
  802bc3:	72 23                	jb     802be8 <__umoddi3+0x118>
  802bc5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bc9:	29 c7                	sub    %eax,%edi
  802bcb:	19 d6                	sbb    %edx,%esi
  802bcd:	89 f0                	mov    %esi,%eax
  802bcf:	89 f2                	mov    %esi,%edx
  802bd1:	d3 ef                	shr    %cl,%edi
  802bd3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802bd7:	d3 e0                	shl    %cl,%eax
  802bd9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802bdd:	09 f8                	or     %edi,%eax
  802bdf:	d3 ea                	shr    %cl,%edx
  802be1:	83 c4 20             	add    $0x20,%esp
  802be4:	5e                   	pop    %esi
  802be5:	5f                   	pop    %edi
  802be6:	5d                   	pop    %ebp
  802be7:	c3                   	ret    
  802be8:	39 d6                	cmp    %edx,%esi
  802bea:	75 d9                	jne    802bc5 <__umoddi3+0xf5>
  802bec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802bef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802bf2:	eb d1                	jmp    802bc5 <__umoddi3+0xf5>
  802bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bf8:	39 f2                	cmp    %esi,%edx
  802bfa:	0f 82 18 ff ff ff    	jb     802b18 <__umoddi3+0x48>
  802c00:	e9 1d ff ff ff       	jmp    802b22 <__umoddi3+0x52>
