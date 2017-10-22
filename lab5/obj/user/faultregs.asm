
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 73 05 00 00       	call   8005a4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800054:	89 54 24 08          	mov    %edx,0x8(%esp)
  800058:	c7 44 24 04 f1 26 80 	movl   $0x8026f1,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 c0 26 80 00 	movl   $0x8026c0,(%esp)
  800067:	e8 61 06 00 00       	call   8006cd <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	89 44 24 08          	mov    %eax,0x8(%esp)
  800078:	c7 44 24 04 d0 26 80 	movl   $0x8026d0,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  800087:	e8 41 06 00 00       	call   8006cd <cprintf>
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	3b 06                	cmp    (%esi),%eax
  800090:	75 13                	jne    8000a5 <check_regs+0x65>
  800092:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  800099:	e8 2f 06 00 00       	call   8006cd <cprintf>
  80009e:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a3:	eb 11                	jmp    8000b6 <check_regs+0x76>
  8000a5:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  8000ac:	e8 1c 06 00 00       	call   8006cd <cprintf>
  8000b1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000b6:	8b 46 04             	mov    0x4(%esi),%eax
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c4:	c7 44 24 04 f2 26 80 	movl   $0x8026f2,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  8000d3:	e8 f5 05 00 00       	call   8006cd <cprintf>
  8000d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000db:	3b 46 04             	cmp    0x4(%esi),%eax
  8000de:	75 0e                	jne    8000ee <check_regs+0xae>
  8000e0:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  8000e7:	e8 e1 05 00 00       	call   8006cd <cprintf>
  8000ec:	eb 11                	jmp    8000ff <check_regs+0xbf>
  8000ee:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  8000f5:	e8 d3 05 00 00       	call   8006cd <cprintf>
  8000fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000ff:	8b 46 08             	mov    0x8(%esi),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 43 08             	mov    0x8(%ebx),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	c7 44 24 04 f6 26 80 	movl   $0x8026f6,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  80011c:	e8 ac 05 00 00       	call   8006cd <cprintf>
  800121:	8b 43 08             	mov    0x8(%ebx),%eax
  800124:	3b 46 08             	cmp    0x8(%esi),%eax
  800127:	75 0e                	jne    800137 <check_regs+0xf7>
  800129:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  800130:	e8 98 05 00 00       	call   8006cd <cprintf>
  800135:	eb 11                	jmp    800148 <check_regs+0x108>
  800137:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  80013e:	e8 8a 05 00 00       	call   8006cd <cprintf>
  800143:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800148:	8b 46 10             	mov    0x10(%esi),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 43 10             	mov    0x10(%ebx),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 fa 26 80 	movl   $0x8026fa,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  800165:	e8 63 05 00 00       	call   8006cd <cprintf>
  80016a:	8b 43 10             	mov    0x10(%ebx),%eax
  80016d:	3b 46 10             	cmp    0x10(%esi),%eax
  800170:	75 0e                	jne    800180 <check_regs+0x140>
  800172:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  800179:	e8 4f 05 00 00       	call   8006cd <cprintf>
  80017e:	eb 11                	jmp    800191 <check_regs+0x151>
  800180:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  800187:	e8 41 05 00 00       	call   8006cd <cprintf>
  80018c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800191:	8b 46 14             	mov    0x14(%esi),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 43 14             	mov    0x14(%ebx),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	c7 44 24 04 fe 26 80 	movl   $0x8026fe,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  8001ae:	e8 1a 05 00 00       	call   8006cd <cprintf>
  8001b3:	8b 43 14             	mov    0x14(%ebx),%eax
  8001b6:	3b 46 14             	cmp    0x14(%esi),%eax
  8001b9:	75 0e                	jne    8001c9 <check_regs+0x189>
  8001bb:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  8001c2:	e8 06 05 00 00       	call   8006cd <cprintf>
  8001c7:	eb 11                	jmp    8001da <check_regs+0x19a>
  8001c9:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  8001d0:	e8 f8 04 00 00       	call   8006cd <cprintf>
  8001d5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001da:	8b 46 18             	mov    0x18(%esi),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 43 18             	mov    0x18(%ebx),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	c7 44 24 04 02 27 80 	movl   $0x802702,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  8001f7:	e8 d1 04 00 00       	call   8006cd <cprintf>
  8001fc:	8b 43 18             	mov    0x18(%ebx),%eax
  8001ff:	3b 46 18             	cmp    0x18(%esi),%eax
  800202:	75 0e                	jne    800212 <check_regs+0x1d2>
  800204:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  80020b:	e8 bd 04 00 00       	call   8006cd <cprintf>
  800210:	eb 11                	jmp    800223 <check_regs+0x1e3>
  800212:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  800219:	e8 af 04 00 00       	call   8006cd <cprintf>
  80021e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800223:	8b 46 1c             	mov    0x1c(%esi),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	c7 44 24 04 06 27 80 	movl   $0x802706,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  800240:	e8 88 04 00 00       	call   8006cd <cprintf>
  800245:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800248:	3b 46 1c             	cmp    0x1c(%esi),%eax
  80024b:	75 0e                	jne    80025b <check_regs+0x21b>
  80024d:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  800254:	e8 74 04 00 00       	call   8006cd <cprintf>
  800259:	eb 11                	jmp    80026c <check_regs+0x22c>
  80025b:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  800262:	e8 66 04 00 00       	call   8006cd <cprintf>
  800267:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80026c:	8b 46 20             	mov    0x20(%esi),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 43 20             	mov    0x20(%ebx),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 0a 27 80 	movl   $0x80270a,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  800289:	e8 3f 04 00 00       	call   8006cd <cprintf>
  80028e:	8b 43 20             	mov    0x20(%ebx),%eax
  800291:	3b 46 20             	cmp    0x20(%esi),%eax
  800294:	75 0e                	jne    8002a4 <check_regs+0x264>
  800296:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  80029d:	e8 2b 04 00 00       	call   8006cd <cprintf>
  8002a2:	eb 11                	jmp    8002b5 <check_regs+0x275>
  8002a4:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  8002ab:	e8 1d 04 00 00       	call   8006cd <cprintf>
  8002b0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002b5:	8b 46 24             	mov    0x24(%esi),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 43 24             	mov    0x24(%ebx),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 0e 27 80 	movl   $0x80270e,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  8002d2:	e8 f6 03 00 00       	call   8006cd <cprintf>
  8002d7:	8b 43 24             	mov    0x24(%ebx),%eax
  8002da:	3b 46 24             	cmp    0x24(%esi),%eax
  8002dd:	75 0e                	jne    8002ed <check_regs+0x2ad>
  8002df:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  8002e6:	e8 e2 03 00 00       	call   8006cd <cprintf>
  8002eb:	eb 11                	jmp    8002fe <check_regs+0x2be>
  8002ed:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  8002f4:	e8 d4 03 00 00       	call   8006cd <cprintf>
  8002f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002fe:	8b 46 28             	mov    0x28(%esi),%eax
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 43 28             	mov    0x28(%ebx),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	c7 44 24 04 15 27 80 	movl   $0x802715,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  80031b:	e8 ad 03 00 00       	call   8006cd <cprintf>
  800320:	8b 43 28             	mov    0x28(%ebx),%eax
  800323:	3b 46 28             	cmp    0x28(%esi),%eax
  800326:	75 25                	jne    80034d <check_regs+0x30d>
  800328:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  80032f:	e8 99 03 00 00       	call   8006cd <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	c7 04 24 19 27 80 00 	movl   $0x802719,(%esp)
  800342:	e8 86 03 00 00       	call   8006cd <cprintf>
	if (!mismatch)
  800347:	85 ff                	test   %edi,%edi
  800349:	74 23                	je     80036e <check_regs+0x32e>
  80034b:	eb 2f                	jmp    80037c <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  80034d:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  800354:	e8 74 03 00 00       	call   8006cd <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 19 27 80 00 	movl   $0x802719,(%esp)
  800367:	e8 61 03 00 00       	call   8006cd <cprintf>
  80036c:	eb 0e                	jmp    80037c <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  80036e:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  800375:	e8 53 03 00 00       	call   8006cd <cprintf>
  80037a:	eb 0c                	jmp    800388 <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80037c:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  800383:	e8 45 03 00 00       	call   8006cd <cprintf>
}
  800388:	83 c4 1c             	add    $0x1c,%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5f                   	pop    %edi
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <umain>:
		panic("sys_page_alloc: %e", r);
}

void
umain(int argc, char **argv)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800396:	c7 04 24 a1 04 80 00 	movl   $0x8004a1,(%esp)
  80039d:	e8 1e 16 00 00       	call   8019c0 <set_pgfault_handler>

	__asm __volatile(
  8003a2:	50                   	push   %eax
  8003a3:	9c                   	pushf  
  8003a4:	58                   	pop    %eax
  8003a5:	0d d5 08 00 00       	or     $0x8d5,%eax
  8003aa:	50                   	push   %eax
  8003ab:	9d                   	popf   
  8003ac:	a3 24 40 80 00       	mov    %eax,0x804024
  8003b1:	8d 05 ec 03 80 00    	lea    0x8003ec,%eax
  8003b7:	a3 20 40 80 00       	mov    %eax,0x804020
  8003bc:	58                   	pop    %eax
  8003bd:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8003c3:	89 35 04 40 80 00    	mov    %esi,0x804004
  8003c9:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8003cf:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8003d5:	89 15 14 40 80 00    	mov    %edx,0x804014
  8003db:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8003e1:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8003e6:	89 25 28 40 80 00    	mov    %esp,0x804028
  8003ec:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8003f3:	00 00 00 
  8003f6:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8003fc:	89 35 84 40 80 00    	mov    %esi,0x804084
  800402:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  800408:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  80040e:	89 15 94 40 80 00    	mov    %edx,0x804094
  800414:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  80041a:	a3 9c 40 80 00       	mov    %eax,0x80409c
  80041f:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  800425:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  80042b:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800431:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  800437:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  80043d:	8b 15 14 40 80 00    	mov    0x804014,%edx
  800443:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  800449:	a1 1c 40 80 00       	mov    0x80401c,%eax
  80044e:	8b 25 28 40 80 00    	mov    0x804028,%esp
  800454:	50                   	push   %eax
  800455:	9c                   	pushf  
  800456:	58                   	pop    %eax
  800457:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80045c:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80045d:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800464:	74 0c                	je     800472 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800466:	c7 04 24 80 27 80 00 	movl   $0x802780,(%esp)
  80046d:	e8 5b 02 00 00       	call   8006cd <cprintf>
	after.eip = before.eip;
  800472:	a1 20 40 80 00       	mov    0x804020,%eax
  800477:	a3 a0 40 80 00       	mov    %eax,0x8040a0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80047c:	c7 44 24 04 2e 27 80 	movl   $0x80272e,0x4(%esp)
  800483:	00 
  800484:	c7 04 24 3f 27 80 00 	movl   $0x80273f,(%esp)
  80048b:	b9 80 40 80 00       	mov    $0x804080,%ecx
  800490:	ba 27 27 80 00       	mov    $0x802727,%edx
  800495:	b8 00 40 80 00       	mov    $0x804000,%eax
  80049a:	e8 a1 fb ff ff       	call   800040 <check_regs>
}
  80049f:	c9                   	leave  
  8004a0:	c3                   	ret    

008004a1 <pgfault>:
		cprintf("MISMATCH\n");
}

static void
pgfault(struct UTrapframe *utf)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
  8004a4:	83 ec 28             	sub    $0x28,%esp
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8004b2:	74 27                	je     8004db <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004b4:	8b 40 28             	mov    0x28(%eax),%eax
  8004b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bf:	c7 44 24 08 a0 27 80 	movl   $0x8027a0,0x8(%esp)
  8004c6:	00 
  8004c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 45 27 80 00 	movl   $0x802745,(%esp)
  8004d6:	e8 39 01 00 00       	call   800614 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8004db:	8b 50 08             	mov    0x8(%eax),%edx
  8004de:	89 15 40 40 80 00    	mov    %edx,0x804040
  8004e4:	8b 50 0c             	mov    0xc(%eax),%edx
  8004e7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8004ed:	8b 50 10             	mov    0x10(%eax),%edx
  8004f0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8004f6:	8b 50 14             	mov    0x14(%eax),%edx
  8004f9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8004ff:	8b 50 18             	mov    0x18(%eax),%edx
  800502:	89 15 50 40 80 00    	mov    %edx,0x804050
  800508:	8b 50 1c             	mov    0x1c(%eax),%edx
  80050b:	89 15 54 40 80 00    	mov    %edx,0x804054
  800511:	8b 50 20             	mov    0x20(%eax),%edx
  800514:	89 15 58 40 80 00    	mov    %edx,0x804058
  80051a:	8b 50 24             	mov    0x24(%eax),%edx
  80051d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800523:	8b 50 28             	mov    0x28(%eax),%edx
  800526:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80052c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80052f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800535:	8b 40 30             	mov    0x30(%eax),%eax
  800538:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80053d:	c7 44 24 04 56 27 80 	movl   $0x802756,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 64 27 80 00 	movl   $0x802764,(%esp)
  80054c:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800551:	ba 27 27 80 00       	mov    $0x802727,%edx
  800556:	b8 00 40 80 00       	mov    $0x804000,%eax
  80055b:	e8 e0 fa ff ff       	call   800040 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800560:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800577:	e8 a7 12 00 00       	call   801823 <sys_page_alloc>
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 20                	jns    8005a0 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800584:	c7 44 24 08 6b 27 80 	movl   $0x80276b,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 45 27 80 00 	movl   $0x802745,(%esp)
  80059b:	e8 74 00 00 00       	call   800614 <_panic>
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    
	...

008005a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	83 ec 18             	sub    $0x18,%esp
  8005aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8005b6:	e8 57 13 00 00       	call   801912 <sys_getenvid>
  8005bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005c0:	89 c2                	mov    %eax,%edx
  8005c2:	c1 e2 07             	shl    $0x7,%edx
  8005c5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8005cc:	a3 b0 40 80 00       	mov    %eax,0x8040b0
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005d1:	85 f6                	test   %esi,%esi
  8005d3:	7e 07                	jle    8005dc <libmain+0x38>
		binaryname = argv[0];
  8005d5:	8b 03                	mov    (%ebx),%eax
  8005d7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	89 34 24             	mov    %esi,(%esp)
  8005e3:	e8 a8 fd ff ff       	call   800390 <umain>

	// exit gracefully
	exit();
  8005e8:	e8 0b 00 00 00       	call   8005f8 <exit>
}
  8005ed:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005f0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005f3:	89 ec                	mov    %ebp,%esp
  8005f5:	5d                   	pop    %ebp
  8005f6:	c3                   	ret    
	...

008005f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005fe:	e8 18 19 00 00       	call   801f1b <close_all>
	sys_env_destroy(0);
  800603:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80060a:	e8 43 13 00 00       	call   801952 <sys_env_destroy>
}
  80060f:	c9                   	leave  
  800610:	c3                   	ret    
  800611:	00 00                	add    %al,(%eax)
	...

00800614 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	56                   	push   %esi
  800618:	53                   	push   %ebx
  800619:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80061c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80061f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800625:	e8 e8 12 00 00       	call   801912 <sys_getenvid>
  80062a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800631:	8b 55 08             	mov    0x8(%ebp),%edx
  800634:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800638:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800647:	e8 81 00 00 00       	call   8006cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80064c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800650:	8b 45 10             	mov    0x10(%ebp),%eax
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	e8 11 00 00 00       	call   80066c <vcprintf>
	cprintf("\n");
  80065b:	c7 04 24 f0 26 80 00 	movl   $0x8026f0,(%esp)
  800662:	e8 66 00 00 00       	call   8006cd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800667:	cc                   	int3   
  800668:	eb fd                	jmp    800667 <_panic+0x53>
	...

0080066c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800675:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80067c:	00 00 00 
	b.cnt = 0;
  80067f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800686:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800689:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	89 44 24 08          	mov    %eax,0x8(%esp)
  800697:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	c7 04 24 e7 06 80 00 	movl   $0x8006e7,(%esp)
  8006a8:	e8 cf 01 00 00       	call   80087c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ad:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006bd:	89 04 24             	mov    %eax,(%esp)
  8006c0:	e8 67 0d 00 00       	call   80142c <sys_cputs>

	return b.cnt;
}
  8006c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8006d3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	89 04 24             	mov    %eax,(%esp)
  8006e0:	e8 87 ff ff ff       	call   80066c <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	53                   	push   %ebx
  8006eb:	83 ec 14             	sub    $0x14,%esp
  8006ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006f1:	8b 03                	mov    (%ebx),%eax
  8006f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006fa:	83 c0 01             	add    $0x1,%eax
  8006fd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800704:	75 19                	jne    80071f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800706:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80070d:	00 
  80070e:	8d 43 08             	lea    0x8(%ebx),%eax
  800711:	89 04 24             	mov    %eax,(%esp)
  800714:	e8 13 0d 00 00       	call   80142c <sys_cputs>
		b->idx = 0;
  800719:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80071f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800723:	83 c4 14             	add    $0x14,%esp
  800726:	5b                   	pop    %ebx
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    
  800729:	00 00                	add    %al,(%eax)
  80072b:	00 00                	add    %al,(%eax)
  80072d:	00 00                	add    %al,(%eax)
	...

00800730 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	57                   	push   %edi
  800734:	56                   	push   %esi
  800735:	53                   	push   %ebx
  800736:	83 ec 4c             	sub    $0x4c,%esp
  800739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073c:	89 d6                	mov    %edx,%esi
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
  800747:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80074a:	8b 45 10             	mov    0x10(%ebp),%eax
  80074d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800750:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800753:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	39 d1                	cmp    %edx,%ecx
  80075d:	72 07                	jb     800766 <printnum_v2+0x36>
  80075f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800762:	39 d0                	cmp    %edx,%eax
  800764:	77 5f                	ja     8007c5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800766:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80076a:	83 eb 01             	sub    $0x1,%ebx
  80076d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800771:	89 44 24 08          	mov    %eax,0x8(%esp)
  800775:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800779:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80077d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800780:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800783:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800786:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80078a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800791:	00 
  800792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800795:	89 04 24             	mov    %eax,(%esp)
  800798:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80079b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079f:	e8 ac 1c 00 00       	call   802450 <__udivdi3>
  8007a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007b2:	89 04 24             	mov    %eax,(%esp)
  8007b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b9:	89 f2                	mov    %esi,%edx
  8007bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007be:	e8 6d ff ff ff       	call   800730 <printnum_v2>
  8007c3:	eb 1e                	jmp    8007e3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007c5:	83 ff 2d             	cmp    $0x2d,%edi
  8007c8:	74 19                	je     8007e3 <printnum_v2+0xb3>
		while (--width > 0)
  8007ca:	83 eb 01             	sub    $0x1,%ebx
  8007cd:	85 db                	test   %ebx,%ebx
  8007cf:	90                   	nop
  8007d0:	7e 11                	jle    8007e3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8007d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d6:	89 3c 24             	mov    %edi,(%esp)
  8007d9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007dc:	83 eb 01             	sub    $0x1,%ebx
  8007df:	85 db                	test   %ebx,%ebx
  8007e1:	7f ef                	jg     8007d2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007f9:	00 
  8007fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fd:	89 14 24             	mov    %edx,(%esp)
  800800:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800803:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800807:	e8 74 1d 00 00       	call   802580 <__umoddi3>
  80080c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800810:	0f be 80 ff 27 80 00 	movsbl 0x8027ff(%eax),%eax
  800817:	89 04 24             	mov    %eax,(%esp)
  80081a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80081d:	83 c4 4c             	add    $0x4c,%esp
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5f                   	pop    %edi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800828:	83 fa 01             	cmp    $0x1,%edx
  80082b:	7e 0e                	jle    80083b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800832:	89 08                	mov    %ecx,(%eax)
  800834:	8b 02                	mov    (%edx),%eax
  800836:	8b 52 04             	mov    0x4(%edx),%edx
  800839:	eb 22                	jmp    80085d <getuint+0x38>
	else if (lflag)
  80083b:	85 d2                	test   %edx,%edx
  80083d:	74 10                	je     80084f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083f:	8b 10                	mov    (%eax),%edx
  800841:	8d 4a 04             	lea    0x4(%edx),%ecx
  800844:	89 08                	mov    %ecx,(%eax)
  800846:	8b 02                	mov    (%edx),%eax
  800848:	ba 00 00 00 00       	mov    $0x0,%edx
  80084d:	eb 0e                	jmp    80085d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	8d 4a 04             	lea    0x4(%edx),%ecx
  800854:	89 08                	mov    %ecx,(%eax)
  800856:	8b 02                	mov    (%edx),%eax
  800858:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800865:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800869:	8b 10                	mov    (%eax),%edx
  80086b:	3b 50 04             	cmp    0x4(%eax),%edx
  80086e:	73 0a                	jae    80087a <sprintputch+0x1b>
		*b->buf++ = ch;
  800870:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800873:	88 0a                	mov    %cl,(%edx)
  800875:	83 c2 01             	add    $0x1,%edx
  800878:	89 10                	mov    %edx,(%eax)
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
  800882:	83 ec 6c             	sub    $0x6c,%esp
  800885:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800888:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80088f:	eb 1a                	jmp    8008ab <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800891:	85 c0                	test   %eax,%eax
  800893:	0f 84 66 06 00 00    	je     800eff <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	ff 55 08             	call   *0x8(%ebp)
  8008a6:	eb 03                	jmp    8008ab <vprintfmt+0x2f>
  8008a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ab:	0f b6 07             	movzbl (%edi),%eax
  8008ae:	83 c7 01             	add    $0x1,%edi
  8008b1:	83 f8 25             	cmp    $0x25,%eax
  8008b4:	75 db                	jne    800891 <vprintfmt+0x15>
  8008b6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8008ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008bf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8008c6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8008cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008d2:	be 00 00 00 00       	mov    $0x0,%esi
  8008d7:	eb 06                	jmp    8008df <vprintfmt+0x63>
  8008d9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8008dd:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008df:	0f b6 17             	movzbl (%edi),%edx
  8008e2:	0f b6 c2             	movzbl %dl,%eax
  8008e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e8:	8d 47 01             	lea    0x1(%edi),%eax
  8008eb:	83 ea 23             	sub    $0x23,%edx
  8008ee:	80 fa 55             	cmp    $0x55,%dl
  8008f1:	0f 87 60 05 00 00    	ja     800e57 <vprintfmt+0x5db>
  8008f7:	0f b6 d2             	movzbl %dl,%edx
  8008fa:	ff 24 95 e0 29 80 00 	jmp    *0x8029e0(,%edx,4)
  800901:	b9 01 00 00 00       	mov    $0x1,%ecx
  800906:	eb d5                	jmp    8008dd <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800908:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80090b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80090e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800911:	8d 7a d0             	lea    -0x30(%edx),%edi
  800914:	83 ff 09             	cmp    $0x9,%edi
  800917:	76 08                	jbe    800921 <vprintfmt+0xa5>
  800919:	eb 40                	jmp    80095b <vprintfmt+0xdf>
  80091b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80091f:	eb bc                	jmp    8008dd <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800921:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800924:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800927:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80092b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80092e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800931:	83 ff 09             	cmp    $0x9,%edi
  800934:	76 eb                	jbe    800921 <vprintfmt+0xa5>
  800936:	eb 23                	jmp    80095b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800938:	8b 55 14             	mov    0x14(%ebp),%edx
  80093b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80093e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800941:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800943:	eb 16                	jmp    80095b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800945:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800948:	c1 fa 1f             	sar    $0x1f,%edx
  80094b:	f7 d2                	not    %edx
  80094d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800950:	eb 8b                	jmp    8008dd <vprintfmt+0x61>
  800952:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800959:	eb 82                	jmp    8008dd <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80095b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80095f:	0f 89 78 ff ff ff    	jns    8008dd <vprintfmt+0x61>
  800965:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800968:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80096b:	e9 6d ff ff ff       	jmp    8008dd <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800970:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800973:	e9 65 ff ff ff       	jmp    8008dd <vprintfmt+0x61>
  800978:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80097b:	8b 45 14             	mov    0x14(%ebp),%eax
  80097e:	8d 50 04             	lea    0x4(%eax),%edx
  800981:	89 55 14             	mov    %edx,0x14(%ebp)
  800984:	8b 55 0c             	mov    0xc(%ebp),%edx
  800987:	89 54 24 04          	mov    %edx,0x4(%esp)
  80098b:	8b 00                	mov    (%eax),%eax
  80098d:	89 04 24             	mov    %eax,(%esp)
  800990:	ff 55 08             	call   *0x8(%ebp)
  800993:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800996:	e9 10 ff ff ff       	jmp    8008ab <vprintfmt+0x2f>
  80099b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a7:	8b 00                	mov    (%eax),%eax
  8009a9:	89 c2                	mov    %eax,%edx
  8009ab:	c1 fa 1f             	sar    $0x1f,%edx
  8009ae:	31 d0                	xor    %edx,%eax
  8009b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009b2:	83 f8 0f             	cmp    $0xf,%eax
  8009b5:	7f 0b                	jg     8009c2 <vprintfmt+0x146>
  8009b7:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  8009be:	85 d2                	test   %edx,%edx
  8009c0:	75 26                	jne    8009e8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8009c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c6:	c7 44 24 08 10 28 80 	movl   $0x802810,0x8(%esp)
  8009cd:	00 
  8009ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d8:	89 1c 24             	mov    %ebx,(%esp)
  8009db:	e8 a7 05 00 00       	call   800f87 <printfmt>
  8009e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009e3:	e9 c3 fe ff ff       	jmp    8008ab <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ec:	c7 44 24 08 19 28 80 	movl   $0x802819,0x8(%esp)
  8009f3:	00 
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fe:	89 14 24             	mov    %edx,(%esp)
  800a01:	e8 81 05 00 00       	call   800f87 <printfmt>
  800a06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a09:	e9 9d fe ff ff       	jmp    8008ab <vprintfmt+0x2f>
  800a0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a11:	89 c7                	mov    %eax,%edi
  800a13:	89 d9                	mov    %ebx,%ecx
  800a15:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a18:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1e:	8d 50 04             	lea    0x4(%eax),%edx
  800a21:	89 55 14             	mov    %edx,0x14(%ebp)
  800a24:	8b 30                	mov    (%eax),%esi
  800a26:	85 f6                	test   %esi,%esi
  800a28:	75 05                	jne    800a2f <vprintfmt+0x1b3>
  800a2a:	be 1c 28 80 00       	mov    $0x80281c,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  800a2f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800a33:	7e 06                	jle    800a3b <vprintfmt+0x1bf>
  800a35:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800a39:	75 10                	jne    800a4b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3b:	0f be 06             	movsbl (%esi),%eax
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	0f 85 a2 00 00 00    	jne    800ae8 <vprintfmt+0x26c>
  800a46:	e9 92 00 00 00       	jmp    800add <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a4b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a4f:	89 34 24             	mov    %esi,(%esp)
  800a52:	e8 74 05 00 00       	call   800fcb <strnlen>
  800a57:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800a5a:	29 c2                	sub    %eax,%edx
  800a5c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800a5f:	85 d2                	test   %edx,%edx
  800a61:	7e d8                	jle    800a3b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800a63:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800a67:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800a6a:	89 d3                	mov    %edx,%ebx
  800a6c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a6f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800a72:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a75:	89 ce                	mov    %ecx,%esi
  800a77:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a7b:	89 34 24             	mov    %esi,(%esp)
  800a7e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a81:	83 eb 01             	sub    $0x1,%ebx
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	7f ef                	jg     800a77 <vprintfmt+0x1fb>
  800a88:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800a8b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a8e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800a91:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a98:	eb a1                	jmp    800a3b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a9a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a9e:	74 1b                	je     800abb <vprintfmt+0x23f>
  800aa0:	8d 50 e0             	lea    -0x20(%eax),%edx
  800aa3:	83 fa 5e             	cmp    $0x5e,%edx
  800aa6:	76 13                	jbe    800abb <vprintfmt+0x23f>
					putch('?', putdat);
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aaf:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ab6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ab9:	eb 0d                	jmp    800ac8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800abb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac2:	89 04 24             	mov    %eax,(%esp)
  800ac5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ac8:	83 ef 01             	sub    $0x1,%edi
  800acb:	0f be 06             	movsbl (%esi),%eax
  800ace:	85 c0                	test   %eax,%eax
  800ad0:	74 05                	je     800ad7 <vprintfmt+0x25b>
  800ad2:	83 c6 01             	add    $0x1,%esi
  800ad5:	eb 1a                	jmp    800af1 <vprintfmt+0x275>
  800ad7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800ada:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800add:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ae1:	7f 1f                	jg     800b02 <vprintfmt+0x286>
  800ae3:	e9 c0 fd ff ff       	jmp    8008a8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ae8:	83 c6 01             	add    $0x1,%esi
  800aeb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800aee:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	78 a5                	js     800a9a <vprintfmt+0x21e>
  800af5:	83 eb 01             	sub    $0x1,%ebx
  800af8:	79 a0                	jns    800a9a <vprintfmt+0x21e>
  800afa:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800afd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b00:	eb db                	jmp    800add <vprintfmt+0x261>
  800b02:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800b0b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b12:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b19:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b1b:	83 eb 01             	sub    $0x1,%ebx
  800b1e:	85 db                	test   %ebx,%ebx
  800b20:	7f ec                	jg     800b0e <vprintfmt+0x292>
  800b22:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800b25:	e9 81 fd ff ff       	jmp    8008ab <vprintfmt+0x2f>
  800b2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b2d:	83 fe 01             	cmp    $0x1,%esi
  800b30:	7e 10                	jle    800b42 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800b32:	8b 45 14             	mov    0x14(%ebp),%eax
  800b35:	8d 50 08             	lea    0x8(%eax),%edx
  800b38:	89 55 14             	mov    %edx,0x14(%ebp)
  800b3b:	8b 18                	mov    (%eax),%ebx
  800b3d:	8b 70 04             	mov    0x4(%eax),%esi
  800b40:	eb 26                	jmp    800b68 <vprintfmt+0x2ec>
	else if (lflag)
  800b42:	85 f6                	test   %esi,%esi
  800b44:	74 12                	je     800b58 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800b46:	8b 45 14             	mov    0x14(%ebp),%eax
  800b49:	8d 50 04             	lea    0x4(%eax),%edx
  800b4c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4f:	8b 18                	mov    (%eax),%ebx
  800b51:	89 de                	mov    %ebx,%esi
  800b53:	c1 fe 1f             	sar    $0x1f,%esi
  800b56:	eb 10                	jmp    800b68 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800b58:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5b:	8d 50 04             	lea    0x4(%eax),%edx
  800b5e:	89 55 14             	mov    %edx,0x14(%ebp)
  800b61:	8b 18                	mov    (%eax),%ebx
  800b63:	89 de                	mov    %ebx,%esi
  800b65:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800b68:	83 f9 01             	cmp    $0x1,%ecx
  800b6b:	75 1e                	jne    800b8b <vprintfmt+0x30f>
                               if((long long)num > 0){
  800b6d:	85 f6                	test   %esi,%esi
  800b6f:	78 1a                	js     800b8b <vprintfmt+0x30f>
  800b71:	85 f6                	test   %esi,%esi
  800b73:	7f 05                	jg     800b7a <vprintfmt+0x2fe>
  800b75:	83 fb 00             	cmp    $0x0,%ebx
  800b78:	76 11                	jbe    800b8b <vprintfmt+0x30f>
                                   putch('+',putdat);
  800b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b81:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800b88:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  800b8b:	85 f6                	test   %esi,%esi
  800b8d:	78 13                	js     800ba2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b8f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800b92:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800b95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b98:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9d:	e9 da 00 00 00       	jmp    800c7c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bb0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800bb3:	89 da                	mov    %ebx,%edx
  800bb5:	89 f1                	mov    %esi,%ecx
  800bb7:	f7 da                	neg    %edx
  800bb9:	83 d1 00             	adc    $0x0,%ecx
  800bbc:	f7 d9                	neg    %ecx
  800bbe:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800bc1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800bc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bc7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bcc:	e9 ab 00 00 00       	jmp    800c7c <vprintfmt+0x400>
  800bd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bd4:	89 f2                	mov    %esi,%edx
  800bd6:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd9:	e8 47 fc ff ff       	call   800825 <getuint>
  800bde:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800be1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800be4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800be7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800bec:	e9 8b 00 00 00       	jmp    800c7c <vprintfmt+0x400>
  800bf1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bfb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c02:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800c05:	89 f2                	mov    %esi,%edx
  800c07:	8d 45 14             	lea    0x14(%ebp),%eax
  800c0a:	e8 16 fc ff ff       	call   800825 <getuint>
  800c0f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800c12:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800c15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c18:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  800c1d:	eb 5d                	jmp    800c7c <vprintfmt+0x400>
  800c1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800c22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c29:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c30:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800c33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c37:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c3e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800c41:	8b 45 14             	mov    0x14(%ebp),%eax
  800c44:	8d 50 04             	lea    0x4(%eax),%edx
  800c47:	89 55 14             	mov    %edx,0x14(%ebp)
  800c4a:	8b 10                	mov    (%eax),%edx
  800c4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c51:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800c54:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800c57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c5a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c5f:	eb 1b                	jmp    800c7c <vprintfmt+0x400>
  800c61:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c64:	89 f2                	mov    %esi,%edx
  800c66:	8d 45 14             	lea    0x14(%ebp),%eax
  800c69:	e8 b7 fb ff ff       	call   800825 <getuint>
  800c6e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800c71:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800c74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c77:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c7c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800c80:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800c83:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800c86:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800c8a:	77 09                	ja     800c95 <vprintfmt+0x419>
  800c8c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800c8f:	0f 82 ac 00 00 00    	jb     800d41 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800c95:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800c98:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800c9c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800c9f:	83 ea 01             	sub    $0x1,%edx
  800ca2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ca6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800caa:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cae:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800cb2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800cb5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800cb8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800cbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cbf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800cc6:	00 
  800cc7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800cca:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800ccd:	89 0c 24             	mov    %ecx,(%esp)
  800cd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd4:	e8 77 17 00 00       	call   802450 <__udivdi3>
  800cd9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800cdc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800cdf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ce3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ce7:	89 04 24             	mov    %eax,(%esp)
  800cea:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	e8 37 fa ff ff       	call   800730 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800cf9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cfc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d00:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d04:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800d07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d0b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d12:	00 
  800d13:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800d16:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800d19:	89 14 24             	mov    %edx,(%esp)
  800d1c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d20:	e8 5b 18 00 00       	call   802580 <__umoddi3>
  800d25:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d29:	0f be 80 ff 27 80 00 	movsbl 0x8027ff(%eax),%eax
  800d30:	89 04 24             	mov    %eax,(%esp)
  800d33:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800d36:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800d3a:	74 54                	je     800d90 <vprintfmt+0x514>
  800d3c:	e9 67 fb ff ff       	jmp    8008a8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800d41:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
  800d48:	0f 84 2a 01 00 00    	je     800e78 <vprintfmt+0x5fc>
		while (--width > 0)
  800d4e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d51:	83 ef 01             	sub    $0x1,%edi
  800d54:	85 ff                	test   %edi,%edi
  800d56:	0f 8e 5e 01 00 00    	jle    800eba <vprintfmt+0x63e>
  800d5c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800d5f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800d62:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d65:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800d68:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800d6b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800d6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d72:	89 1c 24             	mov    %ebx,(%esp)
  800d75:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800d78:	83 ef 01             	sub    $0x1,%edi
  800d7b:	85 ff                	test   %edi,%edi
  800d7d:	7f ef                	jg     800d6e <vprintfmt+0x4f2>
  800d7f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d82:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d85:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800d88:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800d8b:	e9 2a 01 00 00       	jmp    800eba <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800d90:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800d93:	83 eb 01             	sub    $0x1,%ebx
  800d96:	85 db                	test   %ebx,%ebx
  800d98:	0f 8e 0a fb ff ff    	jle    8008a8 <vprintfmt+0x2c>
  800d9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800da4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800da7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800db2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800db4:	83 eb 01             	sub    $0x1,%ebx
  800db7:	85 db                	test   %ebx,%ebx
  800db9:	7f ec                	jg     800da7 <vprintfmt+0x52b>
  800dbb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800dbe:	e9 e8 fa ff ff       	jmp    8008ab <vprintfmt+0x2f>
  800dc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800dc6:	8b 45 14             	mov    0x14(%ebp),%eax
  800dc9:	8d 50 04             	lea    0x4(%eax),%edx
  800dcc:	89 55 14             	mov    %edx,0x14(%ebp)
  800dcf:	8b 00                	mov    (%eax),%eax
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	75 2a                	jne    800dff <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800dd5:	c7 44 24 0c 38 29 80 	movl   $0x802938,0xc(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 08 19 28 80 	movl   $0x802819,0x8(%esp)
  800de4:	00 
  800de5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800def:	89 0c 24             	mov    %ecx,(%esp)
  800df2:	e8 90 01 00 00       	call   800f87 <printfmt>
  800df7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800dfa:	e9 ac fa ff ff       	jmp    8008ab <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800dff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e02:	8b 13                	mov    (%ebx),%edx
  800e04:	83 fa 7f             	cmp    $0x7f,%edx
  800e07:	7e 29                	jle    800e32 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800e09:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800e0b:	c7 44 24 0c 70 29 80 	movl   $0x802970,0xc(%esp)
  800e12:	00 
  800e13:	c7 44 24 08 19 28 80 	movl   $0x802819,0x8(%esp)
  800e1a:	00 
  800e1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	89 04 24             	mov    %eax,(%esp)
  800e25:	e8 5d 01 00 00       	call   800f87 <printfmt>
  800e2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e2d:	e9 79 fa ff ff       	jmp    8008ab <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800e32:	88 10                	mov    %dl,(%eax)
  800e34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e37:	e9 6f fa ff ff       	jmp    8008ab <vprintfmt+0x2f>
  800e3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e49:	89 14 24             	mov    %edx,(%esp)
  800e4c:	ff 55 08             	call   *0x8(%ebp)
  800e4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800e52:	e9 54 fa ff ff       	jmp    8008ab <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e5e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e65:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e68:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e6b:	80 38 25             	cmpb   $0x25,(%eax)
  800e6e:	0f 84 37 fa ff ff    	je     8008ab <vprintfmt+0x2f>
  800e74:	89 c7                	mov    %eax,%edi
  800e76:	eb f0                	jmp    800e68 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e83:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e86:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e91:	00 
  800e92:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800e95:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800e98:	89 04 24             	mov    %eax,(%esp)
  800e9b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e9f:	e8 dc 16 00 00       	call   802580 <__umoddi3>
  800ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea8:	0f be 80 ff 27 80 00 	movsbl 0x8027ff(%eax),%eax
  800eaf:	89 04 24             	mov    %eax,(%esp)
  800eb2:	ff 55 08             	call   *0x8(%ebp)
  800eb5:	e9 d6 fe ff ff       	jmp    800d90 <vprintfmt+0x514>
  800eba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ec1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ec5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ec8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ecc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed3:	00 
  800ed4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800ed7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800eda:	89 04 24             	mov    %eax,(%esp)
  800edd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee1:	e8 9a 16 00 00       	call   802580 <__umoddi3>
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	0f be 80 ff 27 80 00 	movsbl 0x8027ff(%eax),%eax
  800ef1:	89 04 24             	mov    %eax,(%esp)
  800ef4:	ff 55 08             	call   *0x8(%ebp)
  800ef7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800efa:	e9 ac f9 ff ff       	jmp    8008ab <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800eff:	83 c4 6c             	add    $0x6c,%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 28             	sub    $0x28,%esp
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	74 04                	je     800f1b <vsnprintf+0x14>
  800f17:	85 d2                	test   %edx,%edx
  800f19:	7f 07                	jg     800f22 <vsnprintf+0x1b>
  800f1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f20:	eb 3b                	jmp    800f5d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f25:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f33:	8b 45 14             	mov    0x14(%ebp),%eax
  800f36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f41:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f48:	c7 04 24 5f 08 80 00 	movl   $0x80085f,(%esp)
  800f4f:	e8 28 f9 ff ff       	call   80087c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f57:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800f65:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800f68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7d:	89 04 24             	mov    %eax,(%esp)
  800f80:	e8 82 ff ff ff       	call   800f07 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800f8d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800f90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f94:	8b 45 10             	mov    0x10(%ebp),%eax
  800f97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa5:	89 04 24             	mov    %eax,(%esp)
  800fa8:	e8 cf f8 ff ff       	call   80087c <vprintfmt>
	va_end(ap);
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    
	...

00800fb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbb:	80 3a 00             	cmpb   $0x0,(%edx)
  800fbe:	74 09                	je     800fc9 <strlen+0x19>
		n++;
  800fc0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fc7:	75 f7                	jne    800fc0 <strlen+0x10>
		n++;
	return n;
}
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	53                   	push   %ebx
  800fcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fd5:	85 c9                	test   %ecx,%ecx
  800fd7:	74 19                	je     800ff2 <strnlen+0x27>
  800fd9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800fdc:	74 14                	je     800ff2 <strnlen+0x27>
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800fe3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fe6:	39 c8                	cmp    %ecx,%eax
  800fe8:	74 0d                	je     800ff7 <strnlen+0x2c>
  800fea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800fee:	75 f3                	jne    800fe3 <strnlen+0x18>
  800ff0:	eb 05                	jmp    800ff7 <strnlen+0x2c>
  800ff2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ff7:	5b                   	pop    %ebx
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	53                   	push   %ebx
  800ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  801001:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801004:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801009:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80100d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801010:	83 c2 01             	add    $0x1,%edx
  801013:	84 c9                	test   %cl,%cl
  801015:	75 f2                	jne    801009 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801017:	5b                   	pop    %ebx
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	53                   	push   %ebx
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801024:	89 1c 24             	mov    %ebx,(%esp)
  801027:	e8 84 ff ff ff       	call   800fb0 <strlen>
	strcpy(dst + len, src);
  80102c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80102f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801033:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801036:	89 04 24             	mov    %eax,(%esp)
  801039:	e8 bc ff ff ff       	call   800ffa <strcpy>
	return dst;
}
  80103e:	89 d8                	mov    %ebx,%eax
  801040:	83 c4 08             	add    $0x8,%esp
  801043:	5b                   	pop    %ebx
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	56                   	push   %esi
  80104a:	53                   	push   %ebx
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801051:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801054:	85 f6                	test   %esi,%esi
  801056:	74 18                	je     801070 <strncpy+0x2a>
  801058:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80105d:	0f b6 1a             	movzbl (%edx),%ebx
  801060:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801063:	80 3a 01             	cmpb   $0x1,(%edx)
  801066:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801069:	83 c1 01             	add    $0x1,%ecx
  80106c:	39 ce                	cmp    %ecx,%esi
  80106e:	77 ed                	ja     80105d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	8b 75 08             	mov    0x8(%ebp),%esi
  80107c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801082:	89 f0                	mov    %esi,%eax
  801084:	85 c9                	test   %ecx,%ecx
  801086:	74 27                	je     8010af <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801088:	83 e9 01             	sub    $0x1,%ecx
  80108b:	74 1d                	je     8010aa <strlcpy+0x36>
  80108d:	0f b6 1a             	movzbl (%edx),%ebx
  801090:	84 db                	test   %bl,%bl
  801092:	74 16                	je     8010aa <strlcpy+0x36>
			*dst++ = *src++;
  801094:	88 18                	mov    %bl,(%eax)
  801096:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801099:	83 e9 01             	sub    $0x1,%ecx
  80109c:	74 0e                	je     8010ac <strlcpy+0x38>
			*dst++ = *src++;
  80109e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8010a1:	0f b6 1a             	movzbl (%edx),%ebx
  8010a4:	84 db                	test   %bl,%bl
  8010a6:	75 ec                	jne    801094 <strlcpy+0x20>
  8010a8:	eb 02                	jmp    8010ac <strlcpy+0x38>
  8010aa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8010ac:	c6 00 00             	movb   $0x0,(%eax)
  8010af:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8010be:	0f b6 01             	movzbl (%ecx),%eax
  8010c1:	84 c0                	test   %al,%al
  8010c3:	74 15                	je     8010da <strcmp+0x25>
  8010c5:	3a 02                	cmp    (%edx),%al
  8010c7:	75 11                	jne    8010da <strcmp+0x25>
		p++, q++;
  8010c9:	83 c1 01             	add    $0x1,%ecx
  8010cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8010cf:	0f b6 01             	movzbl (%ecx),%eax
  8010d2:	84 c0                	test   %al,%al
  8010d4:	74 04                	je     8010da <strcmp+0x25>
  8010d6:	3a 02                	cmp    (%edx),%al
  8010d8:	74 ef                	je     8010c9 <strcmp+0x14>
  8010da:	0f b6 c0             	movzbl %al,%eax
  8010dd:	0f b6 12             	movzbl (%edx),%edx
  8010e0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	53                   	push   %ebx
  8010e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	74 23                	je     801118 <strncmp+0x34>
  8010f5:	0f b6 1a             	movzbl (%edx),%ebx
  8010f8:	84 db                	test   %bl,%bl
  8010fa:	74 25                	je     801121 <strncmp+0x3d>
  8010fc:	3a 19                	cmp    (%ecx),%bl
  8010fe:	75 21                	jne    801121 <strncmp+0x3d>
  801100:	83 e8 01             	sub    $0x1,%eax
  801103:	74 13                	je     801118 <strncmp+0x34>
		n--, p++, q++;
  801105:	83 c2 01             	add    $0x1,%edx
  801108:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80110b:	0f b6 1a             	movzbl (%edx),%ebx
  80110e:	84 db                	test   %bl,%bl
  801110:	74 0f                	je     801121 <strncmp+0x3d>
  801112:	3a 19                	cmp    (%ecx),%bl
  801114:	74 ea                	je     801100 <strncmp+0x1c>
  801116:	eb 09                	jmp    801121 <strncmp+0x3d>
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80111d:	5b                   	pop    %ebx
  80111e:	5d                   	pop    %ebp
  80111f:	90                   	nop
  801120:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801121:	0f b6 02             	movzbl (%edx),%eax
  801124:	0f b6 11             	movzbl (%ecx),%edx
  801127:	29 d0                	sub    %edx,%eax
  801129:	eb f2                	jmp    80111d <strncmp+0x39>

0080112b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801135:	0f b6 10             	movzbl (%eax),%edx
  801138:	84 d2                	test   %dl,%dl
  80113a:	74 18                	je     801154 <strchr+0x29>
		if (*s == c)
  80113c:	38 ca                	cmp    %cl,%dl
  80113e:	75 0a                	jne    80114a <strchr+0x1f>
  801140:	eb 17                	jmp    801159 <strchr+0x2e>
  801142:	38 ca                	cmp    %cl,%dl
  801144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801148:	74 0f                	je     801159 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80114a:	83 c0 01             	add    $0x1,%eax
  80114d:	0f b6 10             	movzbl (%eax),%edx
  801150:	84 d2                	test   %dl,%dl
  801152:	75 ee                	jne    801142 <strchr+0x17>
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	8b 45 08             	mov    0x8(%ebp),%eax
  801161:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801165:	0f b6 10             	movzbl (%eax),%edx
  801168:	84 d2                	test   %dl,%dl
  80116a:	74 18                	je     801184 <strfind+0x29>
		if (*s == c)
  80116c:	38 ca                	cmp    %cl,%dl
  80116e:	75 0a                	jne    80117a <strfind+0x1f>
  801170:	eb 12                	jmp    801184 <strfind+0x29>
  801172:	38 ca                	cmp    %cl,%dl
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	74 0a                	je     801184 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80117a:	83 c0 01             	add    $0x1,%eax
  80117d:	0f b6 10             	movzbl (%eax),%edx
  801180:	84 d2                	test   %dl,%dl
  801182:	75 ee                	jne    801172 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	83 ec 0c             	sub    $0xc,%esp
  80118c:	89 1c 24             	mov    %ebx,(%esp)
  80118f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801193:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801197:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8011a0:	85 c9                	test   %ecx,%ecx
  8011a2:	74 30                	je     8011d4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011aa:	75 25                	jne    8011d1 <memset+0x4b>
  8011ac:	f6 c1 03             	test   $0x3,%cl
  8011af:	75 20                	jne    8011d1 <memset+0x4b>
		c &= 0xFF;
  8011b1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8011b4:	89 d3                	mov    %edx,%ebx
  8011b6:	c1 e3 08             	shl    $0x8,%ebx
  8011b9:	89 d6                	mov    %edx,%esi
  8011bb:	c1 e6 18             	shl    $0x18,%esi
  8011be:	89 d0                	mov    %edx,%eax
  8011c0:	c1 e0 10             	shl    $0x10,%eax
  8011c3:	09 f0                	or     %esi,%eax
  8011c5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8011c7:	09 d8                	or     %ebx,%eax
  8011c9:	c1 e9 02             	shr    $0x2,%ecx
  8011cc:	fc                   	cld    
  8011cd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011cf:	eb 03                	jmp    8011d4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011d1:	fc                   	cld    
  8011d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011d4:	89 f8                	mov    %edi,%eax
  8011d6:	8b 1c 24             	mov    (%esp),%ebx
  8011d9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011dd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011e1:	89 ec                	mov    %ebp,%esp
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	89 34 24             	mov    %esi,(%esp)
  8011ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8011f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8011fb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8011fd:	39 c6                	cmp    %eax,%esi
  8011ff:	73 35                	jae    801236 <memmove+0x51>
  801201:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801204:	39 d0                	cmp    %edx,%eax
  801206:	73 2e                	jae    801236 <memmove+0x51>
		s += n;
		d += n;
  801208:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80120a:	f6 c2 03             	test   $0x3,%dl
  80120d:	75 1b                	jne    80122a <memmove+0x45>
  80120f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801215:	75 13                	jne    80122a <memmove+0x45>
  801217:	f6 c1 03             	test   $0x3,%cl
  80121a:	75 0e                	jne    80122a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80121c:	83 ef 04             	sub    $0x4,%edi
  80121f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801222:	c1 e9 02             	shr    $0x2,%ecx
  801225:	fd                   	std    
  801226:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801228:	eb 09                	jmp    801233 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80122a:	83 ef 01             	sub    $0x1,%edi
  80122d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801230:	fd                   	std    
  801231:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801233:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801234:	eb 20                	jmp    801256 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801236:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80123c:	75 15                	jne    801253 <memmove+0x6e>
  80123e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801244:	75 0d                	jne    801253 <memmove+0x6e>
  801246:	f6 c1 03             	test   $0x3,%cl
  801249:	75 08                	jne    801253 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80124b:	c1 e9 02             	shr    $0x2,%ecx
  80124e:	fc                   	cld    
  80124f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801251:	eb 03                	jmp    801256 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801253:	fc                   	cld    
  801254:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801256:	8b 34 24             	mov    (%esp),%esi
  801259:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80125d:	89 ec                	mov    %ebp,%esp
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801267:	8b 45 10             	mov    0x10(%ebp),%eax
  80126a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80126e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801271:	89 44 24 04          	mov    %eax,0x4(%esp)
  801275:	8b 45 08             	mov    0x8(%ebp),%eax
  801278:	89 04 24             	mov    %eax,(%esp)
  80127b:	e8 65 ff ff ff       	call   8011e5 <memmove>
}
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	57                   	push   %edi
  801286:	56                   	push   %esi
  801287:	53                   	push   %ebx
  801288:	8b 75 08             	mov    0x8(%ebp),%esi
  80128b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80128e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801291:	85 c9                	test   %ecx,%ecx
  801293:	74 36                	je     8012cb <memcmp+0x49>
		if (*s1 != *s2)
  801295:	0f b6 06             	movzbl (%esi),%eax
  801298:	0f b6 1f             	movzbl (%edi),%ebx
  80129b:	38 d8                	cmp    %bl,%al
  80129d:	74 20                	je     8012bf <memcmp+0x3d>
  80129f:	eb 14                	jmp    8012b5 <memcmp+0x33>
  8012a1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8012a6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8012ab:	83 c2 01             	add    $0x1,%edx
  8012ae:	83 e9 01             	sub    $0x1,%ecx
  8012b1:	38 d8                	cmp    %bl,%al
  8012b3:	74 12                	je     8012c7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8012b5:	0f b6 c0             	movzbl %al,%eax
  8012b8:	0f b6 db             	movzbl %bl,%ebx
  8012bb:	29 d8                	sub    %ebx,%eax
  8012bd:	eb 11                	jmp    8012d0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012bf:	83 e9 01             	sub    $0x1,%ecx
  8012c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c7:	85 c9                	test   %ecx,%ecx
  8012c9:	75 d6                	jne    8012a1 <memcmp+0x1f>
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012e0:	39 d0                	cmp    %edx,%eax
  8012e2:	73 15                	jae    8012f9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8012e8:	38 08                	cmp    %cl,(%eax)
  8012ea:	75 06                	jne    8012f2 <memfind+0x1d>
  8012ec:	eb 0b                	jmp    8012f9 <memfind+0x24>
  8012ee:	38 08                	cmp    %cl,(%eax)
  8012f0:	74 07                	je     8012f9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8012f2:	83 c0 01             	add    $0x1,%eax
  8012f5:	39 c2                	cmp    %eax,%edx
  8012f7:	77 f5                	ja     8012ee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8012f9:	5d                   	pop    %ebp
  8012fa:	c3                   	ret    

008012fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	57                   	push   %edi
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
  801301:	83 ec 04             	sub    $0x4,%esp
  801304:	8b 55 08             	mov    0x8(%ebp),%edx
  801307:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80130a:	0f b6 02             	movzbl (%edx),%eax
  80130d:	3c 20                	cmp    $0x20,%al
  80130f:	74 04                	je     801315 <strtol+0x1a>
  801311:	3c 09                	cmp    $0x9,%al
  801313:	75 0e                	jne    801323 <strtol+0x28>
		s++;
  801315:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801318:	0f b6 02             	movzbl (%edx),%eax
  80131b:	3c 20                	cmp    $0x20,%al
  80131d:	74 f6                	je     801315 <strtol+0x1a>
  80131f:	3c 09                	cmp    $0x9,%al
  801321:	74 f2                	je     801315 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801323:	3c 2b                	cmp    $0x2b,%al
  801325:	75 0c                	jne    801333 <strtol+0x38>
		s++;
  801327:	83 c2 01             	add    $0x1,%edx
  80132a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801331:	eb 15                	jmp    801348 <strtol+0x4d>
	else if (*s == '-')
  801333:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80133a:	3c 2d                	cmp    $0x2d,%al
  80133c:	75 0a                	jne    801348 <strtol+0x4d>
		s++, neg = 1;
  80133e:	83 c2 01             	add    $0x1,%edx
  801341:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801348:	85 db                	test   %ebx,%ebx
  80134a:	0f 94 c0             	sete   %al
  80134d:	74 05                	je     801354 <strtol+0x59>
  80134f:	83 fb 10             	cmp    $0x10,%ebx
  801352:	75 18                	jne    80136c <strtol+0x71>
  801354:	80 3a 30             	cmpb   $0x30,(%edx)
  801357:	75 13                	jne    80136c <strtol+0x71>
  801359:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80135d:	8d 76 00             	lea    0x0(%esi),%esi
  801360:	75 0a                	jne    80136c <strtol+0x71>
		s += 2, base = 16;
  801362:	83 c2 02             	add    $0x2,%edx
  801365:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80136a:	eb 15                	jmp    801381 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80136c:	84 c0                	test   %al,%al
  80136e:	66 90                	xchg   %ax,%ax
  801370:	74 0f                	je     801381 <strtol+0x86>
  801372:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801377:	80 3a 30             	cmpb   $0x30,(%edx)
  80137a:	75 05                	jne    801381 <strtol+0x86>
		s++, base = 8;
  80137c:	83 c2 01             	add    $0x1,%edx
  80137f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801381:	b8 00 00 00 00       	mov    $0x0,%eax
  801386:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801388:	0f b6 0a             	movzbl (%edx),%ecx
  80138b:	89 cf                	mov    %ecx,%edi
  80138d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801390:	80 fb 09             	cmp    $0x9,%bl
  801393:	77 08                	ja     80139d <strtol+0xa2>
			dig = *s - '0';
  801395:	0f be c9             	movsbl %cl,%ecx
  801398:	83 e9 30             	sub    $0x30,%ecx
  80139b:	eb 1e                	jmp    8013bb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80139d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8013a0:	80 fb 19             	cmp    $0x19,%bl
  8013a3:	77 08                	ja     8013ad <strtol+0xb2>
			dig = *s - 'a' + 10;
  8013a5:	0f be c9             	movsbl %cl,%ecx
  8013a8:	83 e9 57             	sub    $0x57,%ecx
  8013ab:	eb 0e                	jmp    8013bb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8013ad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8013b0:	80 fb 19             	cmp    $0x19,%bl
  8013b3:	77 15                	ja     8013ca <strtol+0xcf>
			dig = *s - 'A' + 10;
  8013b5:	0f be c9             	movsbl %cl,%ecx
  8013b8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8013bb:	39 f1                	cmp    %esi,%ecx
  8013bd:	7d 0b                	jge    8013ca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8013bf:	83 c2 01             	add    $0x1,%edx
  8013c2:	0f af c6             	imul   %esi,%eax
  8013c5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8013c8:	eb be                	jmp    801388 <strtol+0x8d>
  8013ca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8013cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013d0:	74 05                	je     8013d7 <strtol+0xdc>
		*endptr = (char *) s;
  8013d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013d5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8013d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013db:	74 04                	je     8013e1 <strtol+0xe6>
  8013dd:	89 c8                	mov    %ecx,%eax
  8013df:	f7 d8                	neg    %eax
}
  8013e1:	83 c4 04             	add    $0x4,%esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5e                   	pop    %esi
  8013e6:	5f                   	pop    %edi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    
  8013e9:	00 00                	add    %al,(%eax)
	...

008013ec <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	89 1c 24             	mov    %ebx,(%esp)
  8013f5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fe:	b8 01 00 00 00       	mov    $0x1,%eax
  801403:	89 d1                	mov    %edx,%ecx
  801405:	89 d3                	mov    %edx,%ebx
  801407:	89 d7                	mov    %edx,%edi
  801409:	51                   	push   %ecx
  80140a:	52                   	push   %edx
  80140b:	53                   	push   %ebx
  80140c:	54                   	push   %esp
  80140d:	55                   	push   %ebp
  80140e:	56                   	push   %esi
  80140f:	57                   	push   %edi
  801410:	54                   	push   %esp
  801411:	5d                   	pop    %ebp
  801412:	8d 35 1a 14 80 00    	lea    0x80141a,%esi
  801418:	0f 34                	sysenter 
  80141a:	5f                   	pop    %edi
  80141b:	5e                   	pop    %esi
  80141c:	5d                   	pop    %ebp
  80141d:	5c                   	pop    %esp
  80141e:	5b                   	pop    %ebx
  80141f:	5a                   	pop    %edx
  801420:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801421:	8b 1c 24             	mov    (%esp),%ebx
  801424:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801428:	89 ec                	mov    %ebp,%esp
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	89 1c 24             	mov    %ebx,(%esp)
  801435:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801439:	b8 00 00 00 00       	mov    $0x0,%eax
  80143e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801441:	8b 55 08             	mov    0x8(%ebp),%edx
  801444:	89 c3                	mov    %eax,%ebx
  801446:	89 c7                	mov    %eax,%edi
  801448:	51                   	push   %ecx
  801449:	52                   	push   %edx
  80144a:	53                   	push   %ebx
  80144b:	54                   	push   %esp
  80144c:	55                   	push   %ebp
  80144d:	56                   	push   %esi
  80144e:	57                   	push   %edi
  80144f:	54                   	push   %esp
  801450:	5d                   	pop    %ebp
  801451:	8d 35 59 14 80 00    	lea    0x801459,%esi
  801457:	0f 34                	sysenter 
  801459:	5f                   	pop    %edi
  80145a:	5e                   	pop    %esi
  80145b:	5d                   	pop    %ebp
  80145c:	5c                   	pop    %esp
  80145d:	5b                   	pop    %ebx
  80145e:	5a                   	pop    %edx
  80145f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801460:	8b 1c 24             	mov    (%esp),%ebx
  801463:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801467:	89 ec                	mov    %ebp,%esp
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    

0080146b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	89 1c 24             	mov    %ebx,(%esp)
  801474:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801478:	b8 10 00 00 00       	mov    $0x10,%eax
  80147d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801480:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801483:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801486:	8b 55 08             	mov    0x8(%ebp),%edx
  801489:	51                   	push   %ecx
  80148a:	52                   	push   %edx
  80148b:	53                   	push   %ebx
  80148c:	54                   	push   %esp
  80148d:	55                   	push   %ebp
  80148e:	56                   	push   %esi
  80148f:	57                   	push   %edi
  801490:	54                   	push   %esp
  801491:	5d                   	pop    %ebp
  801492:	8d 35 9a 14 80 00    	lea    0x80149a,%esi
  801498:	0f 34                	sysenter 
  80149a:	5f                   	pop    %edi
  80149b:	5e                   	pop    %esi
  80149c:	5d                   	pop    %ebp
  80149d:	5c                   	pop    %esp
  80149e:	5b                   	pop    %ebx
  80149f:	5a                   	pop    %edx
  8014a0:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  8014a1:	8b 1c 24             	mov    (%esp),%ebx
  8014a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014a8:	89 ec                	mov    %ebp,%esp
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    

008014ac <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 28             	sub    $0x28,%esp
  8014b2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014b5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014bd:	b8 0f 00 00 00       	mov    $0xf,%eax
  8014c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c8:	89 df                	mov    %ebx,%edi
  8014ca:	51                   	push   %ecx
  8014cb:	52                   	push   %edx
  8014cc:	53                   	push   %ebx
  8014cd:	54                   	push   %esp
  8014ce:	55                   	push   %ebp
  8014cf:	56                   	push   %esi
  8014d0:	57                   	push   %edi
  8014d1:	54                   	push   %esp
  8014d2:	5d                   	pop    %ebp
  8014d3:	8d 35 db 14 80 00    	lea    0x8014db,%esi
  8014d9:	0f 34                	sysenter 
  8014db:	5f                   	pop    %edi
  8014dc:	5e                   	pop    %esi
  8014dd:	5d                   	pop    %ebp
  8014de:	5c                   	pop    %esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5a                   	pop    %edx
  8014e1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	7e 28                	jle    80150e <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ea:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8014f1:	00 
  8014f2:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801501:	00 
  801502:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801509:	e8 06 f1 ff ff       	call   800614 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80150e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801511:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801514:	89 ec                	mov    %ebp,%esp
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	89 1c 24             	mov    %ebx,(%esp)
  801521:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801525:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152a:	b8 11 00 00 00       	mov    $0x11,%eax
  80152f:	8b 55 08             	mov    0x8(%ebp),%edx
  801532:	89 cb                	mov    %ecx,%ebx
  801534:	89 cf                	mov    %ecx,%edi
  801536:	51                   	push   %ecx
  801537:	52                   	push   %edx
  801538:	53                   	push   %ebx
  801539:	54                   	push   %esp
  80153a:	55                   	push   %ebp
  80153b:	56                   	push   %esi
  80153c:	57                   	push   %edi
  80153d:	54                   	push   %esp
  80153e:	5d                   	pop    %ebp
  80153f:	8d 35 47 15 80 00    	lea    0x801547,%esi
  801545:	0f 34                	sysenter 
  801547:	5f                   	pop    %edi
  801548:	5e                   	pop    %esi
  801549:	5d                   	pop    %ebp
  80154a:	5c                   	pop    %esp
  80154b:	5b                   	pop    %ebx
  80154c:	5a                   	pop    %edx
  80154d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80154e:	8b 1c 24             	mov    (%esp),%ebx
  801551:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801555:	89 ec                	mov    %ebp,%esp
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	83 ec 28             	sub    $0x28,%esp
  80155f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801562:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80156f:	8b 55 08             	mov    0x8(%ebp),%edx
  801572:	89 cb                	mov    %ecx,%ebx
  801574:	89 cf                	mov    %ecx,%edi
  801576:	51                   	push   %ecx
  801577:	52                   	push   %edx
  801578:	53                   	push   %ebx
  801579:	54                   	push   %esp
  80157a:	55                   	push   %ebp
  80157b:	56                   	push   %esi
  80157c:	57                   	push   %edi
  80157d:	54                   	push   %esp
  80157e:	5d                   	pop    %ebp
  80157f:	8d 35 87 15 80 00    	lea    0x801587,%esi
  801585:	0f 34                	sysenter 
  801587:	5f                   	pop    %edi
  801588:	5e                   	pop    %esi
  801589:	5d                   	pop    %ebp
  80158a:	5c                   	pop    %esp
  80158b:	5b                   	pop    %ebx
  80158c:	5a                   	pop    %edx
  80158d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80158e:	85 c0                	test   %eax,%eax
  801590:	7e 28                	jle    8015ba <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801592:	89 44 24 10          	mov    %eax,0x10(%esp)
  801596:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80159d:	00 
  80159e:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  8015a5:	00 
  8015a6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015ad:	00 
  8015ae:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  8015b5:	e8 5a f0 ff ff       	call   800614 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8015ba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015c0:	89 ec                	mov    %ebp,%esp
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    

008015c4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	89 1c 24             	mov    %ebx,(%esp)
  8015cd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015d1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8015d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015df:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e2:	51                   	push   %ecx
  8015e3:	52                   	push   %edx
  8015e4:	53                   	push   %ebx
  8015e5:	54                   	push   %esp
  8015e6:	55                   	push   %ebp
  8015e7:	56                   	push   %esi
  8015e8:	57                   	push   %edi
  8015e9:	54                   	push   %esp
  8015ea:	5d                   	pop    %ebp
  8015eb:	8d 35 f3 15 80 00    	lea    0x8015f3,%esi
  8015f1:	0f 34                	sysenter 
  8015f3:	5f                   	pop    %edi
  8015f4:	5e                   	pop    %esi
  8015f5:	5d                   	pop    %ebp
  8015f6:	5c                   	pop    %esp
  8015f7:	5b                   	pop    %ebx
  8015f8:	5a                   	pop    %edx
  8015f9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8015fa:	8b 1c 24             	mov    (%esp),%ebx
  8015fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801601:	89 ec                	mov    %ebp,%esp
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 28             	sub    $0x28,%esp
  80160b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80160e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801611:	bb 00 00 00 00       	mov    $0x0,%ebx
  801616:	b8 0b 00 00 00       	mov    $0xb,%eax
  80161b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80161e:	8b 55 08             	mov    0x8(%ebp),%edx
  801621:	89 df                	mov    %ebx,%edi
  801623:	51                   	push   %ecx
  801624:	52                   	push   %edx
  801625:	53                   	push   %ebx
  801626:	54                   	push   %esp
  801627:	55                   	push   %ebp
  801628:	56                   	push   %esi
  801629:	57                   	push   %edi
  80162a:	54                   	push   %esp
  80162b:	5d                   	pop    %ebp
  80162c:	8d 35 34 16 80 00    	lea    0x801634,%esi
  801632:	0f 34                	sysenter 
  801634:	5f                   	pop    %edi
  801635:	5e                   	pop    %esi
  801636:	5d                   	pop    %ebp
  801637:	5c                   	pop    %esp
  801638:	5b                   	pop    %ebx
  801639:	5a                   	pop    %edx
  80163a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80163b:	85 c0                	test   %eax,%eax
  80163d:	7e 28                	jle    801667 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80163f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801643:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80164a:	00 
  80164b:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801652:	00 
  801653:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80165a:	00 
  80165b:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801662:	e8 ad ef ff ff       	call   800614 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801667:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80166a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80166d:	89 ec                	mov    %ebp,%esp
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 28             	sub    $0x28,%esp
  801677:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80167a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80167d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801682:	b8 0a 00 00 00       	mov    $0xa,%eax
  801687:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168a:	8b 55 08             	mov    0x8(%ebp),%edx
  80168d:	89 df                	mov    %ebx,%edi
  80168f:	51                   	push   %ecx
  801690:	52                   	push   %edx
  801691:	53                   	push   %ebx
  801692:	54                   	push   %esp
  801693:	55                   	push   %ebp
  801694:	56                   	push   %esi
  801695:	57                   	push   %edi
  801696:	54                   	push   %esp
  801697:	5d                   	pop    %ebp
  801698:	8d 35 a0 16 80 00    	lea    0x8016a0,%esi
  80169e:	0f 34                	sysenter 
  8016a0:	5f                   	pop    %edi
  8016a1:	5e                   	pop    %esi
  8016a2:	5d                   	pop    %ebp
  8016a3:	5c                   	pop    %esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5a                   	pop    %edx
  8016a6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	7e 28                	jle    8016d3 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016af:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8016b6:	00 
  8016b7:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  8016be:	00 
  8016bf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8016c6:	00 
  8016c7:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  8016ce:	e8 41 ef ff ff       	call   800614 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016d3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016d6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016d9:	89 ec                	mov    %ebp,%esp
  8016db:	5d                   	pop    %ebp
  8016dc:	c3                   	ret    

008016dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	83 ec 28             	sub    $0x28,%esp
  8016e3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016e6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8016e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8016f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f9:	89 df                	mov    %ebx,%edi
  8016fb:	51                   	push   %ecx
  8016fc:	52                   	push   %edx
  8016fd:	53                   	push   %ebx
  8016fe:	54                   	push   %esp
  8016ff:	55                   	push   %ebp
  801700:	56                   	push   %esi
  801701:	57                   	push   %edi
  801702:	54                   	push   %esp
  801703:	5d                   	pop    %ebp
  801704:	8d 35 0c 17 80 00    	lea    0x80170c,%esi
  80170a:	0f 34                	sysenter 
  80170c:	5f                   	pop    %edi
  80170d:	5e                   	pop    %esi
  80170e:	5d                   	pop    %ebp
  80170f:	5c                   	pop    %esp
  801710:	5b                   	pop    %ebx
  801711:	5a                   	pop    %edx
  801712:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801713:	85 c0                	test   %eax,%eax
  801715:	7e 28                	jle    80173f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801717:	89 44 24 10          	mov    %eax,0x10(%esp)
  80171b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801722:	00 
  801723:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80172a:	00 
  80172b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801732:	00 
  801733:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80173a:	e8 d5 ee ff ff       	call   800614 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80173f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801742:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801745:	89 ec                	mov    %ebp,%esp
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 28             	sub    $0x28,%esp
  80174f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801752:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801755:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175a:	b8 07 00 00 00       	mov    $0x7,%eax
  80175f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801762:	8b 55 08             	mov    0x8(%ebp),%edx
  801765:	89 df                	mov    %ebx,%edi
  801767:	51                   	push   %ecx
  801768:	52                   	push   %edx
  801769:	53                   	push   %ebx
  80176a:	54                   	push   %esp
  80176b:	55                   	push   %ebp
  80176c:	56                   	push   %esi
  80176d:	57                   	push   %edi
  80176e:	54                   	push   %esp
  80176f:	5d                   	pop    %ebp
  801770:	8d 35 78 17 80 00    	lea    0x801778,%esi
  801776:	0f 34                	sysenter 
  801778:	5f                   	pop    %edi
  801779:	5e                   	pop    %esi
  80177a:	5d                   	pop    %ebp
  80177b:	5c                   	pop    %esp
  80177c:	5b                   	pop    %ebx
  80177d:	5a                   	pop    %edx
  80177e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80177f:	85 c0                	test   %eax,%eax
  801781:	7e 28                	jle    8017ab <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801783:	89 44 24 10          	mov    %eax,0x10(%esp)
  801787:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80178e:	00 
  80178f:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801796:	00 
  801797:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80179e:	00 
  80179f:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  8017a6:	e8 69 ee ff ff       	call   800614 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8017ab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017b1:	89 ec                	mov    %ebp,%esp
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 28             	sub    $0x28,%esp
  8017bb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017be:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8017c1:	8b 7d 18             	mov    0x18(%ebp),%edi
  8017c4:	0b 7d 14             	or     0x14(%ebp),%edi
  8017c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d5:	51                   	push   %ecx
  8017d6:	52                   	push   %edx
  8017d7:	53                   	push   %ebx
  8017d8:	54                   	push   %esp
  8017d9:	55                   	push   %ebp
  8017da:	56                   	push   %esi
  8017db:	57                   	push   %edi
  8017dc:	54                   	push   %esp
  8017dd:	5d                   	pop    %ebp
  8017de:	8d 35 e6 17 80 00    	lea    0x8017e6,%esi
  8017e4:	0f 34                	sysenter 
  8017e6:	5f                   	pop    %edi
  8017e7:	5e                   	pop    %esi
  8017e8:	5d                   	pop    %ebp
  8017e9:	5c                   	pop    %esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5a                   	pop    %edx
  8017ec:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	7e 28                	jle    801819 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017f5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8017fc:	00 
  8017fd:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801804:	00 
  801805:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80180c:	00 
  80180d:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801814:	e8 fb ed ff ff       	call   800614 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  801819:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80181c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80181f:	89 ec                	mov    %ebp,%esp
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 28             	sub    $0x28,%esp
  801829:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80182c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80182f:	bf 00 00 00 00       	mov    $0x0,%edi
  801834:	b8 05 00 00 00       	mov    $0x5,%eax
  801839:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80183c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183f:	8b 55 08             	mov    0x8(%ebp),%edx
  801842:	51                   	push   %ecx
  801843:	52                   	push   %edx
  801844:	53                   	push   %ebx
  801845:	54                   	push   %esp
  801846:	55                   	push   %ebp
  801847:	56                   	push   %esi
  801848:	57                   	push   %edi
  801849:	54                   	push   %esp
  80184a:	5d                   	pop    %ebp
  80184b:	8d 35 53 18 80 00    	lea    0x801853,%esi
  801851:	0f 34                	sysenter 
  801853:	5f                   	pop    %edi
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	5c                   	pop    %esp
  801857:	5b                   	pop    %ebx
  801858:	5a                   	pop    %edx
  801859:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80185a:	85 c0                	test   %eax,%eax
  80185c:	7e 28                	jle    801886 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80185e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801862:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801869:	00 
  80186a:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  801871:	00 
  801872:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801879:	00 
  80187a:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  801881:	e8 8e ed ff ff       	call   800614 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801886:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801889:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80188c:	89 ec                	mov    %ebp,%esp
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	89 1c 24             	mov    %ebx,(%esp)
  801899:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8018a7:	89 d1                	mov    %edx,%ecx
  8018a9:	89 d3                	mov    %edx,%ebx
  8018ab:	89 d7                	mov    %edx,%edi
  8018ad:	51                   	push   %ecx
  8018ae:	52                   	push   %edx
  8018af:	53                   	push   %ebx
  8018b0:	54                   	push   %esp
  8018b1:	55                   	push   %ebp
  8018b2:	56                   	push   %esi
  8018b3:	57                   	push   %edi
  8018b4:	54                   	push   %esp
  8018b5:	5d                   	pop    %ebp
  8018b6:	8d 35 be 18 80 00    	lea    0x8018be,%esi
  8018bc:	0f 34                	sysenter 
  8018be:	5f                   	pop    %edi
  8018bf:	5e                   	pop    %esi
  8018c0:	5d                   	pop    %ebp
  8018c1:	5c                   	pop    %esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5a                   	pop    %edx
  8018c4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8018c5:	8b 1c 24             	mov    (%esp),%ebx
  8018c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018cc:	89 ec                	mov    %ebp,%esp
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	89 1c 24             	mov    %ebx,(%esp)
  8018d9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8018dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e2:	b8 04 00 00 00       	mov    $0x4,%eax
  8018e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ed:	89 df                	mov    %ebx,%edi
  8018ef:	51                   	push   %ecx
  8018f0:	52                   	push   %edx
  8018f1:	53                   	push   %ebx
  8018f2:	54                   	push   %esp
  8018f3:	55                   	push   %ebp
  8018f4:	56                   	push   %esi
  8018f5:	57                   	push   %edi
  8018f6:	54                   	push   %esp
  8018f7:	5d                   	pop    %ebp
  8018f8:	8d 35 00 19 80 00    	lea    0x801900,%esi
  8018fe:	0f 34                	sysenter 
  801900:	5f                   	pop    %edi
  801901:	5e                   	pop    %esi
  801902:	5d                   	pop    %ebp
  801903:	5c                   	pop    %esp
  801904:	5b                   	pop    %ebx
  801905:	5a                   	pop    %edx
  801906:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801907:	8b 1c 24             	mov    (%esp),%ebx
  80190a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80190e:	89 ec                	mov    %ebp,%esp
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	83 ec 08             	sub    $0x8,%esp
  801918:	89 1c 24             	mov    %ebx,(%esp)
  80191b:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80191f:	ba 00 00 00 00       	mov    $0x0,%edx
  801924:	b8 02 00 00 00       	mov    $0x2,%eax
  801929:	89 d1                	mov    %edx,%ecx
  80192b:	89 d3                	mov    %edx,%ebx
  80192d:	89 d7                	mov    %edx,%edi
  80192f:	51                   	push   %ecx
  801930:	52                   	push   %edx
  801931:	53                   	push   %ebx
  801932:	54                   	push   %esp
  801933:	55                   	push   %ebp
  801934:	56                   	push   %esi
  801935:	57                   	push   %edi
  801936:	54                   	push   %esp
  801937:	5d                   	pop    %ebp
  801938:	8d 35 40 19 80 00    	lea    0x801940,%esi
  80193e:	0f 34                	sysenter 
  801940:	5f                   	pop    %edi
  801941:	5e                   	pop    %esi
  801942:	5d                   	pop    %ebp
  801943:	5c                   	pop    %esp
  801944:	5b                   	pop    %ebx
  801945:	5a                   	pop    %edx
  801946:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801947:	8b 1c 24             	mov    (%esp),%ebx
  80194a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80194e:	89 ec                	mov    %ebp,%esp
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 28             	sub    $0x28,%esp
  801958:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80195b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80195e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801963:	b8 03 00 00 00       	mov    $0x3,%eax
  801968:	8b 55 08             	mov    0x8(%ebp),%edx
  80196b:	89 cb                	mov    %ecx,%ebx
  80196d:	89 cf                	mov    %ecx,%edi
  80196f:	51                   	push   %ecx
  801970:	52                   	push   %edx
  801971:	53                   	push   %ebx
  801972:	54                   	push   %esp
  801973:	55                   	push   %ebp
  801974:	56                   	push   %esi
  801975:	57                   	push   %edi
  801976:	54                   	push   %esp
  801977:	5d                   	pop    %ebp
  801978:	8d 35 80 19 80 00    	lea    0x801980,%esi
  80197e:	0f 34                	sysenter 
  801980:	5f                   	pop    %edi
  801981:	5e                   	pop    %esi
  801982:	5d                   	pop    %ebp
  801983:	5c                   	pop    %esp
  801984:	5b                   	pop    %ebx
  801985:	5a                   	pop    %edx
  801986:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801987:	85 c0                	test   %eax,%eax
  801989:	7e 28                	jle    8019b3 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80198b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80198f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801996:	00 
  801997:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80199e:	00 
  80199f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8019a6:	00 
  8019a7:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  8019ae:	e8 61 ec ff ff       	call   800614 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8019b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019b9:	89 ec                	mov    %ebp,%esp
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    
  8019bd:	00 00                	add    %al,(%eax)
	...

008019c0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8019c6:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8019cd:	75 30                	jne    8019ff <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  8019cf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019d6:	00 
  8019d7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8019de:	ee 
  8019df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e6:	e8 38 fe ff ff       	call   801823 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8019eb:	c7 44 24 04 0c 1a 80 	movl   $0x801a0c,0x4(%esp)
  8019f2:	00 
  8019f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fa:	e8 06 fc ff ff       	call   801605 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8019ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801a02:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    
  801a09:	00 00                	add    %al,(%eax)
	...

00801a0c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801a0c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801a0d:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801a12:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801a14:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  801a17:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  801a1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  801a1f:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  801a22:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  801a24:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  801a28:	83 c4 08             	add    $0x8,%esp
        popal
  801a2b:	61                   	popa   
        addl $0x4,%esp
  801a2c:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  801a2f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801a30:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801a31:	c3                   	ret    
	...

00801a40 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	8b 45 08             	mov    0x8(%ebp),%eax
  801a46:	05 00 00 00 30       	add    $0x30000000,%eax
  801a4b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	89 04 24             	mov    %eax,(%esp)
  801a5c:	e8 df ff ff ff       	call   801a40 <fd2num>
  801a61:	05 20 00 0d 00       	add    $0xd0020,%eax
  801a66:	c1 e0 0c             	shl    $0xc,%eax
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	57                   	push   %edi
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801a74:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801a79:	a8 01                	test   $0x1,%al
  801a7b:	74 36                	je     801ab3 <fd_alloc+0x48>
  801a7d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801a82:	a8 01                	test   $0x1,%al
  801a84:	74 2d                	je     801ab3 <fd_alloc+0x48>
  801a86:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801a8b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801a90:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801a95:	89 c3                	mov    %eax,%ebx
  801a97:	89 c2                	mov    %eax,%edx
  801a99:	c1 ea 16             	shr    $0x16,%edx
  801a9c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801a9f:	f6 c2 01             	test   $0x1,%dl
  801aa2:	74 14                	je     801ab8 <fd_alloc+0x4d>
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	c1 ea 0c             	shr    $0xc,%edx
  801aa9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801aac:	f6 c2 01             	test   $0x1,%dl
  801aaf:	75 10                	jne    801ac1 <fd_alloc+0x56>
  801ab1:	eb 05                	jmp    801ab8 <fd_alloc+0x4d>
  801ab3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801ab8:	89 1f                	mov    %ebx,(%edi)
  801aba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801abf:	eb 17                	jmp    801ad8 <fd_alloc+0x6d>
  801ac1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801ac6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801acb:	75 c8                	jne    801a95 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801acd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801ad3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5f                   	pop    %edi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	83 f8 1f             	cmp    $0x1f,%eax
  801ae6:	77 36                	ja     801b1e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ae8:	05 00 00 0d 00       	add    $0xd0000,%eax
  801aed:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801af0:	89 c2                	mov    %eax,%edx
  801af2:	c1 ea 16             	shr    $0x16,%edx
  801af5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801afc:	f6 c2 01             	test   $0x1,%dl
  801aff:	74 1d                	je     801b1e <fd_lookup+0x41>
  801b01:	89 c2                	mov    %eax,%edx
  801b03:	c1 ea 0c             	shr    $0xc,%edx
  801b06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b0d:	f6 c2 01             	test   $0x1,%dl
  801b10:	74 0c                	je     801b1e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b15:	89 02                	mov    %eax,(%edx)
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801b1c:	eb 05                	jmp    801b23 <fd_lookup+0x46>
  801b1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b2b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b32:	8b 45 08             	mov    0x8(%ebp),%eax
  801b35:	89 04 24             	mov    %eax,(%esp)
  801b38:	e8 a0 ff ff ff       	call   801add <fd_lookup>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 0e                	js     801b4f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b47:	89 50 04             	mov    %edx,0x4(%eax)
  801b4a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 10             	sub    $0x10,%esp
  801b59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801b5f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801b64:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b69:	be 2c 2c 80 00       	mov    $0x802c2c,%esi
		if (devtab[i]->dev_id == dev_id) {
  801b6e:	39 08                	cmp    %ecx,(%eax)
  801b70:	75 10                	jne    801b82 <dev_lookup+0x31>
  801b72:	eb 04                	jmp    801b78 <dev_lookup+0x27>
  801b74:	39 08                	cmp    %ecx,(%eax)
  801b76:	75 0a                	jne    801b82 <dev_lookup+0x31>
			*dev = devtab[i];
  801b78:	89 03                	mov    %eax,(%ebx)
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801b7f:	90                   	nop
  801b80:	eb 31                	jmp    801bb3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b82:	83 c2 01             	add    $0x1,%edx
  801b85:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	75 e8                	jne    801b74 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801b8c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801b91:	8b 40 48             	mov    0x48(%eax),%eax
  801b94:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9c:	c7 04 24 ac 2b 80 00 	movl   $0x802bac,(%esp)
  801ba3:	e8 25 eb ff ff       	call   8006cd <cprintf>
	*dev = 0;
  801ba8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 24             	sub    $0x24,%esp
  801bc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bce:	89 04 24             	mov    %eax,(%esp)
  801bd1:	e8 07 ff ff ff       	call   801add <fd_lookup>
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	78 53                	js     801c2d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be4:	8b 00                	mov    (%eax),%eax
  801be6:	89 04 24             	mov    %eax,(%esp)
  801be9:	e8 63 ff ff ff       	call   801b51 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 3b                	js     801c2d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801bf2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bfa:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801bfe:	74 2d                	je     801c2d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c00:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c03:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c0a:	00 00 00 
	stat->st_isdir = 0;
  801c0d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c14:	00 00 00 
	stat->st_dev = dev;
  801c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c27:	89 14 24             	mov    %edx,(%esp)
  801c2a:	ff 50 14             	call   *0x14(%eax)
}
  801c2d:	83 c4 24             	add    $0x24,%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	83 ec 24             	sub    $0x24,%esp
  801c3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c44:	89 1c 24             	mov    %ebx,(%esp)
  801c47:	e8 91 fe ff ff       	call   801add <fd_lookup>
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	78 5f                	js     801caf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5a:	8b 00                	mov    (%eax),%eax
  801c5c:	89 04 24             	mov    %eax,(%esp)
  801c5f:	e8 ed fe ff ff       	call   801b51 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c64:	85 c0                	test   %eax,%eax
  801c66:	78 47                	js     801caf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c6b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801c6f:	75 23                	jne    801c94 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c71:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c76:	8b 40 48             	mov    0x48(%eax),%eax
  801c79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c81:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  801c88:	e8 40 ea ff ff       	call   8006cd <cprintf>
  801c8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c92:	eb 1b                	jmp    801caf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c97:	8b 48 18             	mov    0x18(%eax),%ecx
  801c9a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c9f:	85 c9                	test   %ecx,%ecx
  801ca1:	74 0c                	je     801caf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801caa:	89 14 24             	mov    %edx,(%esp)
  801cad:	ff d1                	call   *%ecx
}
  801caf:	83 c4 24             	add    $0x24,%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	53                   	push   %ebx
  801cb9:	83 ec 24             	sub    $0x24,%esp
  801cbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc6:	89 1c 24             	mov    %ebx,(%esp)
  801cc9:	e8 0f fe ff ff       	call   801add <fd_lookup>
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 66                	js     801d38 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdc:	8b 00                	mov    (%eax),%eax
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 6b fe ff ff       	call   801b51 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 4e                	js     801d38 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ced:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801cf1:	75 23                	jne    801d16 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801cf3:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801cf8:	8b 40 48             	mov    0x48(%eax),%eax
  801cfb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d03:	c7 04 24 f0 2b 80 00 	movl   $0x802bf0,(%esp)
  801d0a:	e8 be e9 ff ff       	call   8006cd <cprintf>
  801d0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801d14:	eb 22                	jmp    801d38 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d19:	8b 48 0c             	mov    0xc(%eax),%ecx
  801d1c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d21:	85 c9                	test   %ecx,%ecx
  801d23:	74 13                	je     801d38 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d25:	8b 45 10             	mov    0x10(%ebp),%eax
  801d28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d33:	89 14 24             	mov    %edx,(%esp)
  801d36:	ff d1                	call   *%ecx
}
  801d38:	83 c4 24             	add    $0x24,%esp
  801d3b:	5b                   	pop    %ebx
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	53                   	push   %ebx
  801d42:	83 ec 24             	sub    $0x24,%esp
  801d45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4f:	89 1c 24             	mov    %ebx,(%esp)
  801d52:	e8 86 fd ff ff       	call   801add <fd_lookup>
  801d57:	85 c0                	test   %eax,%eax
  801d59:	78 6b                	js     801dc6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d65:	8b 00                	mov    (%eax),%eax
  801d67:	89 04 24             	mov    %eax,(%esp)
  801d6a:	e8 e2 fd ff ff       	call   801b51 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	78 53                	js     801dc6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801d73:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d76:	8b 42 08             	mov    0x8(%edx),%eax
  801d79:	83 e0 03             	and    $0x3,%eax
  801d7c:	83 f8 01             	cmp    $0x1,%eax
  801d7f:	75 23                	jne    801da4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801d81:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801d86:	8b 40 48             	mov    0x48(%eax),%eax
  801d89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d91:	c7 04 24 0d 2c 80 00 	movl   $0x802c0d,(%esp)
  801d98:	e8 30 e9 ff ff       	call   8006cd <cprintf>
  801d9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801da2:	eb 22                	jmp    801dc6 <read+0x88>
	}
	if (!dev->dev_read)
  801da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da7:	8b 48 08             	mov    0x8(%eax),%ecx
  801daa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801daf:	85 c9                	test   %ecx,%ecx
  801db1:	74 13                	je     801dc6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801db3:	8b 45 10             	mov    0x10(%ebp),%eax
  801db6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc1:	89 14 24             	mov    %edx,(%esp)
  801dc4:	ff d1                	call   *%ecx
}
  801dc6:	83 c4 24             	add    $0x24,%esp
  801dc9:	5b                   	pop    %ebx
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    

00801dcc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	57                   	push   %edi
  801dd0:	56                   	push   %esi
  801dd1:	53                   	push   %ebx
  801dd2:	83 ec 1c             	sub    $0x1c,%esp
  801dd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dd8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ddb:	ba 00 00 00 00       	mov    $0x0,%edx
  801de0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dea:	85 f6                	test   %esi,%esi
  801dec:	74 29                	je     801e17 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	29 d0                	sub    %edx,%eax
  801df2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df6:	03 55 0c             	add    0xc(%ebp),%edx
  801df9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dfd:	89 3c 24             	mov    %edi,(%esp)
  801e00:	e8 39 ff ff ff       	call   801d3e <read>
		if (m < 0)
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 0e                	js     801e17 <readn+0x4b>
			return m;
		if (m == 0)
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	74 08                	je     801e15 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e0d:	01 c3                	add    %eax,%ebx
  801e0f:	89 da                	mov    %ebx,%edx
  801e11:	39 f3                	cmp    %esi,%ebx
  801e13:	72 d9                	jb     801dee <readn+0x22>
  801e15:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801e17:	83 c4 1c             	add    $0x1c,%esp
  801e1a:	5b                   	pop    %ebx
  801e1b:	5e                   	pop    %esi
  801e1c:	5f                   	pop    %edi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	56                   	push   %esi
  801e23:	53                   	push   %ebx
  801e24:	83 ec 20             	sub    $0x20,%esp
  801e27:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801e2a:	89 34 24             	mov    %esi,(%esp)
  801e2d:	e8 0e fc ff ff       	call   801a40 <fd2num>
  801e32:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e35:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e39:	89 04 24             	mov    %eax,(%esp)
  801e3c:	e8 9c fc ff ff       	call   801add <fd_lookup>
  801e41:	89 c3                	mov    %eax,%ebx
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 05                	js     801e4c <fd_close+0x2d>
  801e47:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801e4a:	74 0c                	je     801e58 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801e4c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801e50:	19 c0                	sbb    %eax,%eax
  801e52:	f7 d0                	not    %eax
  801e54:	21 c3                	and    %eax,%ebx
  801e56:	eb 3d                	jmp    801e95 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e58:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5f:	8b 06                	mov    (%esi),%eax
  801e61:	89 04 24             	mov    %eax,(%esp)
  801e64:	e8 e8 fc ff ff       	call   801b51 <dev_lookup>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 16                	js     801e85 <fd_close+0x66>
		if (dev->dev_close)
  801e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e72:	8b 40 10             	mov    0x10(%eax),%eax
  801e75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	74 07                	je     801e85 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801e7e:	89 34 24             	mov    %esi,(%esp)
  801e81:	ff d0                	call   *%eax
  801e83:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801e85:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e90:	e8 b4 f8 ff ff       	call   801749 <sys_page_unmap>
	return r;
}
  801e95:	89 d8                	mov    %ebx,%eax
  801e97:	83 c4 20             	add    $0x20,%esp
  801e9a:	5b                   	pop    %ebx
  801e9b:	5e                   	pop    %esi
  801e9c:	5d                   	pop    %ebp
  801e9d:	c3                   	ret    

00801e9e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	89 04 24             	mov    %eax,(%esp)
  801eb1:	e8 27 fc ff ff       	call   801add <fd_lookup>
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 13                	js     801ecd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801eba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ec1:	00 
  801ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec5:	89 04 24             	mov    %eax,(%esp)
  801ec8:	e8 52 ff ff ff       	call   801e1f <fd_close>
}
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	83 ec 18             	sub    $0x18,%esp
  801ed5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ed8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801edb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ee2:	00 
  801ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 79 03 00 00       	call   802267 <open>
  801eee:	89 c3                	mov    %eax,%ebx
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 1b                	js     801f0f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efb:	89 1c 24             	mov    %ebx,(%esp)
  801efe:	e8 b7 fc ff ff       	call   801bba <fstat>
  801f03:	89 c6                	mov    %eax,%esi
	close(fd);
  801f05:	89 1c 24             	mov    %ebx,(%esp)
  801f08:	e8 91 ff ff ff       	call   801e9e <close>
  801f0d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801f0f:	89 d8                	mov    %ebx,%eax
  801f11:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f14:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f17:	89 ec                	mov    %ebp,%esp
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    

00801f1b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	53                   	push   %ebx
  801f1f:	83 ec 14             	sub    $0x14,%esp
  801f22:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801f27:	89 1c 24             	mov    %ebx,(%esp)
  801f2a:	e8 6f ff ff ff       	call   801e9e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801f2f:	83 c3 01             	add    $0x1,%ebx
  801f32:	83 fb 20             	cmp    $0x20,%ebx
  801f35:	75 f0                	jne    801f27 <close_all+0xc>
		close(i);
}
  801f37:	83 c4 14             	add    $0x14,%esp
  801f3a:	5b                   	pop    %ebx
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    

00801f3d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	83 ec 58             	sub    $0x58,%esp
  801f43:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f46:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f49:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f4c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801f4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f56:	8b 45 08             	mov    0x8(%ebp),%eax
  801f59:	89 04 24             	mov    %eax,(%esp)
  801f5c:	e8 7c fb ff ff       	call   801add <fd_lookup>
  801f61:	89 c3                	mov    %eax,%ebx
  801f63:	85 c0                	test   %eax,%eax
  801f65:	0f 88 e0 00 00 00    	js     80204b <dup+0x10e>
		return r;
	close(newfdnum);
  801f6b:	89 3c 24             	mov    %edi,(%esp)
  801f6e:	e8 2b ff ff ff       	call   801e9e <close>

	newfd = INDEX2FD(newfdnum);
  801f73:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801f79:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801f7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f7f:	89 04 24             	mov    %eax,(%esp)
  801f82:	e8 c9 fa ff ff       	call   801a50 <fd2data>
  801f87:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801f89:	89 34 24             	mov    %esi,(%esp)
  801f8c:	e8 bf fa ff ff       	call   801a50 <fd2data>
  801f91:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801f94:	89 da                	mov    %ebx,%edx
  801f96:	89 d8                	mov    %ebx,%eax
  801f98:	c1 e8 16             	shr    $0x16,%eax
  801f9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fa2:	a8 01                	test   $0x1,%al
  801fa4:	74 43                	je     801fe9 <dup+0xac>
  801fa6:	c1 ea 0c             	shr    $0xc,%edx
  801fa9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801fb0:	a8 01                	test   $0x1,%al
  801fb2:	74 35                	je     801fe9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801fb4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801fbb:	25 07 0e 00 00       	and    $0xe07,%eax
  801fc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801fc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fd2:	00 
  801fd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fde:	e8 d2 f7 ff ff       	call   8017b5 <sys_page_map>
  801fe3:	89 c3                	mov    %eax,%ebx
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	78 3f                	js     802028 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fec:	89 c2                	mov    %eax,%edx
  801fee:	c1 ea 0c             	shr    $0xc,%edx
  801ff1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ff8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ffe:	89 54 24 10          	mov    %edx,0x10(%esp)
  802002:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802006:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80200d:	00 
  80200e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802019:	e8 97 f7 ff ff       	call   8017b5 <sys_page_map>
  80201e:	89 c3                	mov    %eax,%ebx
  802020:	85 c0                	test   %eax,%eax
  802022:	78 04                	js     802028 <dup+0xeb>
  802024:	89 fb                	mov    %edi,%ebx
  802026:	eb 23                	jmp    80204b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802028:	89 74 24 04          	mov    %esi,0x4(%esp)
  80202c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802033:	e8 11 f7 ff ff       	call   801749 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802038:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80203b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802046:	e8 fe f6 ff ff       	call   801749 <sys_page_unmap>
	return r;
}
  80204b:	89 d8                	mov    %ebx,%eax
  80204d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802050:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802053:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802056:	89 ec                	mov    %ebp,%esp
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    
	...

0080205c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	83 ec 18             	sub    $0x18,%esp
  802062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802068:	89 c3                	mov    %eax,%ebx
  80206a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80206c:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  802073:	75 11                	jne    802086 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802075:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80207c:	e8 8f 02 00 00       	call   802310 <ipc_find_env>
  802081:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802086:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80208d:	00 
  80208e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  802095:	00 
  802096:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80209a:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  80209f:	89 04 24             	mov    %eax,(%esp)
  8020a2:	e8 b4 02 00 00       	call   80235b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8020a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020ae:	00 
  8020af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ba:	e8 1a 03 00 00       	call   8023d9 <ipc_recv>
}
  8020bf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8020c2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8020c5:	89 ec                	mov    %ebp,%esp
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    

008020c9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8020cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8020d5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8020da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020dd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8020e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e7:	b8 02 00 00 00       	mov    $0x2,%eax
  8020ec:	e8 6b ff ff ff       	call   80205c <fsipc>
}
  8020f1:	c9                   	leave  
  8020f2:	c3                   	ret    

008020f3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8020f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8020ff:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  802104:	ba 00 00 00 00       	mov    $0x0,%edx
  802109:	b8 06 00 00 00       	mov    $0x6,%eax
  80210e:	e8 49 ff ff ff       	call   80205c <fsipc>
}
  802113:	c9                   	leave  
  802114:	c3                   	ret    

00802115 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80211b:	ba 00 00 00 00       	mov    $0x0,%edx
  802120:	b8 08 00 00 00       	mov    $0x8,%eax
  802125:	e8 32 ff ff ff       	call   80205c <fsipc>
}
  80212a:	c9                   	leave  
  80212b:	c3                   	ret    

0080212c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	53                   	push   %ebx
  802130:	83 ec 14             	sub    $0x14,%esp
  802133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802136:	8b 45 08             	mov    0x8(%ebp),%eax
  802139:	8b 40 0c             	mov    0xc(%eax),%eax
  80213c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802141:	ba 00 00 00 00       	mov    $0x0,%edx
  802146:	b8 05 00 00 00       	mov    $0x5,%eax
  80214b:	e8 0c ff ff ff       	call   80205c <fsipc>
  802150:	85 c0                	test   %eax,%eax
  802152:	78 2b                	js     80217f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802154:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80215b:	00 
  80215c:	89 1c 24             	mov    %ebx,(%esp)
  80215f:	e8 96 ee ff ff       	call   800ffa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802164:	a1 80 50 80 00       	mov    0x805080,%eax
  802169:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80216f:	a1 84 50 80 00       	mov    0x805084,%eax
  802174:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80217a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80217f:	83 c4 14             	add    $0x14,%esp
  802182:	5b                   	pop    %ebx
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    

00802185 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802185:	55                   	push   %ebp
  802186:	89 e5                	mov    %esp,%ebp
  802188:	83 ec 18             	sub    $0x18,%esp
  80218b:	8b 45 10             	mov    0x10(%ebp),%eax
  80218e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802193:	76 05                	jbe    80219a <devfile_write+0x15>
  802195:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  80219a:	8b 55 08             	mov    0x8(%ebp),%edx
  80219d:	8b 52 0c             	mov    0xc(%edx),%edx
  8021a0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  8021a6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  8021ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8021bd:	e8 23 f0 ff ff       	call   8011e5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  8021c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8021cc:	e8 8b fe ff ff       	call   80205c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    

008021d3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	53                   	push   %ebx
  8021d7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  8021da:	8b 45 08             	mov    0x8(%ebp),%eax
  8021dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8021e0:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  8021e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8021e8:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  8021ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8021f7:	e8 60 fe ff ff       	call   80205c <fsipc>
  8021fc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8021fe:	85 c0                	test   %eax,%eax
  802200:	78 17                	js     802219 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802202:	89 44 24 08          	mov    %eax,0x8(%esp)
  802206:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80220d:	00 
  80220e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802211:	89 04 24             	mov    %eax,(%esp)
  802214:	e8 cc ef ff ff       	call   8011e5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802219:	89 d8                	mov    %ebx,%eax
  80221b:	83 c4 14             	add    $0x14,%esp
  80221e:	5b                   	pop    %ebx
  80221f:	5d                   	pop    %ebp
  802220:	c3                   	ret    

00802221 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802221:	55                   	push   %ebp
  802222:	89 e5                	mov    %esp,%ebp
  802224:	53                   	push   %ebx
  802225:	83 ec 14             	sub    $0x14,%esp
  802228:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80222b:	89 1c 24             	mov    %ebx,(%esp)
  80222e:	e8 7d ed ff ff       	call   800fb0 <strlen>
  802233:	89 c2                	mov    %eax,%edx
  802235:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80223a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802240:	7f 1f                	jg     802261 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802242:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802246:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80224d:	e8 a8 ed ff ff       	call   800ffa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802252:	ba 00 00 00 00       	mov    $0x0,%edx
  802257:	b8 07 00 00 00       	mov    $0x7,%eax
  80225c:	e8 fb fd ff ff       	call   80205c <fsipc>
}
  802261:	83 c4 14             	add    $0x14,%esp
  802264:	5b                   	pop    %ebx
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    

00802267 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	83 ec 28             	sub    $0x28,%esp
  80226d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802270:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802273:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802276:	89 34 24             	mov    %esi,(%esp)
  802279:	e8 32 ed ff ff       	call   800fb0 <strlen>
  80227e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802283:	3d 00 04 00 00       	cmp    $0x400,%eax
  802288:	7f 6d                	jg     8022f7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80228a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228d:	89 04 24             	mov    %eax,(%esp)
  802290:	e8 d6 f7 ff ff       	call   801a6b <fd_alloc>
  802295:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  802297:	85 c0                	test   %eax,%eax
  802299:	78 5c                	js     8022f7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80229b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8022a3:	89 34 24             	mov    %esi,(%esp)
  8022a6:	e8 05 ed ff ff       	call   800fb0 <strlen>
  8022ab:	83 c0 01             	add    $0x1,%eax
  8022ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8022bd:	e8 23 ef ff ff       	call   8011e5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8022c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ca:	e8 8d fd ff ff       	call   80205c <fsipc>
  8022cf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  8022d1:	85 c0                	test   %eax,%eax
  8022d3:	79 15                	jns    8022ea <open+0x83>
             fd_close(fd,0);
  8022d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022dc:	00 
  8022dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e0:	89 04 24             	mov    %eax,(%esp)
  8022e3:	e8 37 fb ff ff       	call   801e1f <fd_close>
             return r;
  8022e8:	eb 0d                	jmp    8022f7 <open+0x90>
        }
        return fd2num(fd);
  8022ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ed:	89 04 24             	mov    %eax,(%esp)
  8022f0:	e8 4b f7 ff ff       	call   801a40 <fd2num>
  8022f5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8022f7:	89 d8                	mov    %ebx,%eax
  8022f9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8022fc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8022ff:	89 ec                	mov    %ebp,%esp
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    
	...

00802310 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802316:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80231c:	b8 01 00 00 00       	mov    $0x1,%eax
  802321:	39 ca                	cmp    %ecx,%edx
  802323:	75 04                	jne    802329 <ipc_find_env+0x19>
  802325:	b0 00                	mov    $0x0,%al
  802327:	eb 12                	jmp    80233b <ipc_find_env+0x2b>
  802329:	89 c2                	mov    %eax,%edx
  80232b:	c1 e2 07             	shl    $0x7,%edx
  80232e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802335:	8b 12                	mov    (%edx),%edx
  802337:	39 ca                	cmp    %ecx,%edx
  802339:	75 10                	jne    80234b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80233b:	89 c2                	mov    %eax,%edx
  80233d:	c1 e2 07             	shl    $0x7,%edx
  802340:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802347:	8b 00                	mov    (%eax),%eax
  802349:	eb 0e                	jmp    802359 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80234b:	83 c0 01             	add    $0x1,%eax
  80234e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802353:	75 d4                	jne    802329 <ipc_find_env+0x19>
  802355:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802359:	5d                   	pop    %ebp
  80235a:	c3                   	ret    

0080235b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80235b:	55                   	push   %ebp
  80235c:	89 e5                	mov    %esp,%ebp
  80235e:	57                   	push   %edi
  80235f:	56                   	push   %esi
  802360:	53                   	push   %ebx
  802361:	83 ec 1c             	sub    $0x1c,%esp
  802364:	8b 75 08             	mov    0x8(%ebp),%esi
  802367:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80236a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80236d:	85 db                	test   %ebx,%ebx
  80236f:	74 19                	je     80238a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802371:	8b 45 14             	mov    0x14(%ebp),%eax
  802374:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802378:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80237c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802380:	89 34 24             	mov    %esi,(%esp)
  802383:	e8 3c f2 ff ff       	call   8015c4 <sys_ipc_try_send>
  802388:	eb 1b                	jmp    8023a5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80238a:	8b 45 14             	mov    0x14(%ebp),%eax
  80238d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802391:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802398:	ee 
  802399:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80239d:	89 34 24             	mov    %esi,(%esp)
  8023a0:	e8 1f f2 ff ff       	call   8015c4 <sys_ipc_try_send>
           if(ret == 0)
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	74 28                	je     8023d1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8023a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023ac:	74 1c                	je     8023ca <ipc_send+0x6f>
              panic("ipc send error");
  8023ae:	c7 44 24 08 34 2c 80 	movl   $0x802c34,0x8(%esp)
  8023b5:	00 
  8023b6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8023bd:	00 
  8023be:	c7 04 24 43 2c 80 00 	movl   $0x802c43,(%esp)
  8023c5:	e8 4a e2 ff ff       	call   800614 <_panic>
           sys_yield();
  8023ca:	e8 c1 f4 ff ff       	call   801890 <sys_yield>
        }
  8023cf:	eb 9c                	jmp    80236d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8023d1:	83 c4 1c             	add    $0x1c,%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5e                   	pop    %esi
  8023d6:	5f                   	pop    %edi
  8023d7:	5d                   	pop    %ebp
  8023d8:	c3                   	ret    

008023d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023d9:	55                   	push   %ebp
  8023da:	89 e5                	mov    %esp,%ebp
  8023dc:	56                   	push   %esi
  8023dd:	53                   	push   %ebx
  8023de:	83 ec 10             	sub    $0x10,%esp
  8023e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8023e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8023ea:	85 c0                	test   %eax,%eax
  8023ec:	75 0e                	jne    8023fc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8023ee:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8023f5:	e8 5f f1 ff ff       	call   801559 <sys_ipc_recv>
  8023fa:	eb 08                	jmp    802404 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8023fc:	89 04 24             	mov    %eax,(%esp)
  8023ff:	e8 55 f1 ff ff       	call   801559 <sys_ipc_recv>
        if(ret == 0){
  802404:	85 c0                	test   %eax,%eax
  802406:	75 26                	jne    80242e <ipc_recv+0x55>
           if(from_env_store)
  802408:	85 f6                	test   %esi,%esi
  80240a:	74 0a                	je     802416 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80240c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802411:	8b 40 78             	mov    0x78(%eax),%eax
  802414:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802416:	85 db                	test   %ebx,%ebx
  802418:	74 0a                	je     802424 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80241a:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80241f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802422:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802424:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802429:	8b 40 74             	mov    0x74(%eax),%eax
  80242c:	eb 14                	jmp    802442 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80242e:	85 f6                	test   %esi,%esi
  802430:	74 06                	je     802438 <ipc_recv+0x5f>
              *from_env_store = 0;
  802432:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802438:	85 db                	test   %ebx,%ebx
  80243a:	74 06                	je     802442 <ipc_recv+0x69>
              *perm_store = 0;
  80243c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802442:	83 c4 10             	add    $0x10,%esp
  802445:	5b                   	pop    %ebx
  802446:	5e                   	pop    %esi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
  802449:	00 00                	add    %al,(%eax)
  80244b:	00 00                	add    %al,(%eax)
  80244d:	00 00                	add    %al,(%eax)
	...

00802450 <__udivdi3>:
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	57                   	push   %edi
  802454:	56                   	push   %esi
  802455:	83 ec 10             	sub    $0x10,%esp
  802458:	8b 45 14             	mov    0x14(%ebp),%eax
  80245b:	8b 55 08             	mov    0x8(%ebp),%edx
  80245e:	8b 75 10             	mov    0x10(%ebp),%esi
  802461:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802464:	85 c0                	test   %eax,%eax
  802466:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802469:	75 35                	jne    8024a0 <__udivdi3+0x50>
  80246b:	39 fe                	cmp    %edi,%esi
  80246d:	77 61                	ja     8024d0 <__udivdi3+0x80>
  80246f:	85 f6                	test   %esi,%esi
  802471:	75 0b                	jne    80247e <__udivdi3+0x2e>
  802473:	b8 01 00 00 00       	mov    $0x1,%eax
  802478:	31 d2                	xor    %edx,%edx
  80247a:	f7 f6                	div    %esi
  80247c:	89 c6                	mov    %eax,%esi
  80247e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802481:	31 d2                	xor    %edx,%edx
  802483:	89 f8                	mov    %edi,%eax
  802485:	f7 f6                	div    %esi
  802487:	89 c7                	mov    %eax,%edi
  802489:	89 c8                	mov    %ecx,%eax
  80248b:	f7 f6                	div    %esi
  80248d:	89 c1                	mov    %eax,%ecx
  80248f:	89 fa                	mov    %edi,%edx
  802491:	89 c8                	mov    %ecx,%eax
  802493:	83 c4 10             	add    $0x10,%esp
  802496:	5e                   	pop    %esi
  802497:	5f                   	pop    %edi
  802498:	5d                   	pop    %ebp
  802499:	c3                   	ret    
  80249a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a0:	39 f8                	cmp    %edi,%eax
  8024a2:	77 1c                	ja     8024c0 <__udivdi3+0x70>
  8024a4:	0f bd d0             	bsr    %eax,%edx
  8024a7:	83 f2 1f             	xor    $0x1f,%edx
  8024aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8024ad:	75 39                	jne    8024e8 <__udivdi3+0x98>
  8024af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8024b2:	0f 86 a0 00 00 00    	jbe    802558 <__udivdi3+0x108>
  8024b8:	39 f8                	cmp    %edi,%eax
  8024ba:	0f 82 98 00 00 00    	jb     802558 <__udivdi3+0x108>
  8024c0:	31 ff                	xor    %edi,%edi
  8024c2:	31 c9                	xor    %ecx,%ecx
  8024c4:	89 c8                	mov    %ecx,%eax
  8024c6:	89 fa                	mov    %edi,%edx
  8024c8:	83 c4 10             	add    $0x10,%esp
  8024cb:	5e                   	pop    %esi
  8024cc:	5f                   	pop    %edi
  8024cd:	5d                   	pop    %ebp
  8024ce:	c3                   	ret    
  8024cf:	90                   	nop
  8024d0:	89 d1                	mov    %edx,%ecx
  8024d2:	89 fa                	mov    %edi,%edx
  8024d4:	89 c8                	mov    %ecx,%eax
  8024d6:	31 ff                	xor    %edi,%edi
  8024d8:	f7 f6                	div    %esi
  8024da:	89 c1                	mov    %eax,%ecx
  8024dc:	89 fa                	mov    %edi,%edx
  8024de:	89 c8                	mov    %ecx,%eax
  8024e0:	83 c4 10             	add    $0x10,%esp
  8024e3:	5e                   	pop    %esi
  8024e4:	5f                   	pop    %edi
  8024e5:	5d                   	pop    %ebp
  8024e6:	c3                   	ret    
  8024e7:	90                   	nop
  8024e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8024ec:	89 f2                	mov    %esi,%edx
  8024ee:	d3 e0                	shl    %cl,%eax
  8024f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8024f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8024f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8024fb:	89 c1                	mov    %eax,%ecx
  8024fd:	d3 ea                	shr    %cl,%edx
  8024ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802503:	0b 55 ec             	or     -0x14(%ebp),%edx
  802506:	d3 e6                	shl    %cl,%esi
  802508:	89 c1                	mov    %eax,%ecx
  80250a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80250d:	89 fe                	mov    %edi,%esi
  80250f:	d3 ee                	shr    %cl,%esi
  802511:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802515:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802518:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80251b:	d3 e7                	shl    %cl,%edi
  80251d:	89 c1                	mov    %eax,%ecx
  80251f:	d3 ea                	shr    %cl,%edx
  802521:	09 d7                	or     %edx,%edi
  802523:	89 f2                	mov    %esi,%edx
  802525:	89 f8                	mov    %edi,%eax
  802527:	f7 75 ec             	divl   -0x14(%ebp)
  80252a:	89 d6                	mov    %edx,%esi
  80252c:	89 c7                	mov    %eax,%edi
  80252e:	f7 65 e8             	mull   -0x18(%ebp)
  802531:	39 d6                	cmp    %edx,%esi
  802533:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802536:	72 30                	jb     802568 <__udivdi3+0x118>
  802538:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80253b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80253f:	d3 e2                	shl    %cl,%edx
  802541:	39 c2                	cmp    %eax,%edx
  802543:	73 05                	jae    80254a <__udivdi3+0xfa>
  802545:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802548:	74 1e                	je     802568 <__udivdi3+0x118>
  80254a:	89 f9                	mov    %edi,%ecx
  80254c:	31 ff                	xor    %edi,%edi
  80254e:	e9 71 ff ff ff       	jmp    8024c4 <__udivdi3+0x74>
  802553:	90                   	nop
  802554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802558:	31 ff                	xor    %edi,%edi
  80255a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80255f:	e9 60 ff ff ff       	jmp    8024c4 <__udivdi3+0x74>
  802564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802568:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80256b:	31 ff                	xor    %edi,%edi
  80256d:	89 c8                	mov    %ecx,%eax
  80256f:	89 fa                	mov    %edi,%edx
  802571:	83 c4 10             	add    $0x10,%esp
  802574:	5e                   	pop    %esi
  802575:	5f                   	pop    %edi
  802576:	5d                   	pop    %ebp
  802577:	c3                   	ret    
	...

00802580 <__umoddi3>:
  802580:	55                   	push   %ebp
  802581:	89 e5                	mov    %esp,%ebp
  802583:	57                   	push   %edi
  802584:	56                   	push   %esi
  802585:	83 ec 20             	sub    $0x20,%esp
  802588:	8b 55 14             	mov    0x14(%ebp),%edx
  80258b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80258e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802591:	8b 75 0c             	mov    0xc(%ebp),%esi
  802594:	85 d2                	test   %edx,%edx
  802596:	89 c8                	mov    %ecx,%eax
  802598:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80259b:	75 13                	jne    8025b0 <__umoddi3+0x30>
  80259d:	39 f7                	cmp    %esi,%edi
  80259f:	76 3f                	jbe    8025e0 <__umoddi3+0x60>
  8025a1:	89 f2                	mov    %esi,%edx
  8025a3:	f7 f7                	div    %edi
  8025a5:	89 d0                	mov    %edx,%eax
  8025a7:	31 d2                	xor    %edx,%edx
  8025a9:	83 c4 20             	add    $0x20,%esp
  8025ac:	5e                   	pop    %esi
  8025ad:	5f                   	pop    %edi
  8025ae:	5d                   	pop    %ebp
  8025af:	c3                   	ret    
  8025b0:	39 f2                	cmp    %esi,%edx
  8025b2:	77 4c                	ja     802600 <__umoddi3+0x80>
  8025b4:	0f bd ca             	bsr    %edx,%ecx
  8025b7:	83 f1 1f             	xor    $0x1f,%ecx
  8025ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8025bd:	75 51                	jne    802610 <__umoddi3+0x90>
  8025bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8025c2:	0f 87 e0 00 00 00    	ja     8026a8 <__umoddi3+0x128>
  8025c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025cb:	29 f8                	sub    %edi,%eax
  8025cd:	19 d6                	sbb    %edx,%esi
  8025cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8025d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d5:	89 f2                	mov    %esi,%edx
  8025d7:	83 c4 20             	add    $0x20,%esp
  8025da:	5e                   	pop    %esi
  8025db:	5f                   	pop    %edi
  8025dc:	5d                   	pop    %ebp
  8025dd:	c3                   	ret    
  8025de:	66 90                	xchg   %ax,%ax
  8025e0:	85 ff                	test   %edi,%edi
  8025e2:	75 0b                	jne    8025ef <__umoddi3+0x6f>
  8025e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e9:	31 d2                	xor    %edx,%edx
  8025eb:	f7 f7                	div    %edi
  8025ed:	89 c7                	mov    %eax,%edi
  8025ef:	89 f0                	mov    %esi,%eax
  8025f1:	31 d2                	xor    %edx,%edx
  8025f3:	f7 f7                	div    %edi
  8025f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f8:	f7 f7                	div    %edi
  8025fa:	eb a9                	jmp    8025a5 <__umoddi3+0x25>
  8025fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	83 c4 20             	add    $0x20,%esp
  802607:	5e                   	pop    %esi
  802608:	5f                   	pop    %edi
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    
  80260b:	90                   	nop
  80260c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802610:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802614:	d3 e2                	shl    %cl,%edx
  802616:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802619:	ba 20 00 00 00       	mov    $0x20,%edx
  80261e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802621:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802624:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802628:	89 fa                	mov    %edi,%edx
  80262a:	d3 ea                	shr    %cl,%edx
  80262c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802630:	0b 55 f4             	or     -0xc(%ebp),%edx
  802633:	d3 e7                	shl    %cl,%edi
  802635:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802639:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80263c:	89 f2                	mov    %esi,%edx
  80263e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802641:	89 c7                	mov    %eax,%edi
  802643:	d3 ea                	shr    %cl,%edx
  802645:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802649:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80264c:	89 c2                	mov    %eax,%edx
  80264e:	d3 e6                	shl    %cl,%esi
  802650:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802654:	d3 ea                	shr    %cl,%edx
  802656:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80265a:	09 d6                	or     %edx,%esi
  80265c:	89 f0                	mov    %esi,%eax
  80265e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802661:	d3 e7                	shl    %cl,%edi
  802663:	89 f2                	mov    %esi,%edx
  802665:	f7 75 f4             	divl   -0xc(%ebp)
  802668:	89 d6                	mov    %edx,%esi
  80266a:	f7 65 e8             	mull   -0x18(%ebp)
  80266d:	39 d6                	cmp    %edx,%esi
  80266f:	72 2b                	jb     80269c <__umoddi3+0x11c>
  802671:	39 c7                	cmp    %eax,%edi
  802673:	72 23                	jb     802698 <__umoddi3+0x118>
  802675:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802679:	29 c7                	sub    %eax,%edi
  80267b:	19 d6                	sbb    %edx,%esi
  80267d:	89 f0                	mov    %esi,%eax
  80267f:	89 f2                	mov    %esi,%edx
  802681:	d3 ef                	shr    %cl,%edi
  802683:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802687:	d3 e0                	shl    %cl,%eax
  802689:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80268d:	09 f8                	or     %edi,%eax
  80268f:	d3 ea                	shr    %cl,%edx
  802691:	83 c4 20             	add    $0x20,%esp
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	39 d6                	cmp    %edx,%esi
  80269a:	75 d9                	jne    802675 <__umoddi3+0xf5>
  80269c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80269f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8026a2:	eb d1                	jmp    802675 <__umoddi3+0xf5>
  8026a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a8:	39 f2                	cmp    %esi,%edx
  8026aa:	0f 82 18 ff ff ff    	jb     8025c8 <__umoddi3+0x48>
  8026b0:	e9 1d ff ff ff       	jmp    8025d2 <__umoddi3+0x52>
