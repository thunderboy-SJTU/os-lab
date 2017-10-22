
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
  800058:	c7 44 24 04 51 2d 80 	movl   $0x802d51,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
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
  800078:	c7 44 24 04 30 2d 80 	movl   $0x802d30,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  800087:	e8 41 06 00 00       	call   8006cd <cprintf>
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	3b 06                	cmp    (%esi),%eax
  800090:	75 13                	jne    8000a5 <check_regs+0x65>
  800092:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  800099:	e8 2f 06 00 00       	call   8006cd <cprintf>
  80009e:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a3:	eb 11                	jmp    8000b6 <check_regs+0x76>
  8000a5:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  8000ac:	e8 1c 06 00 00       	call   8006cd <cprintf>
  8000b1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000b6:	8b 46 04             	mov    0x4(%esi),%eax
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c4:	c7 44 24 04 52 2d 80 	movl   $0x802d52,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  8000d3:	e8 f5 05 00 00       	call   8006cd <cprintf>
  8000d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000db:	3b 46 04             	cmp    0x4(%esi),%eax
  8000de:	75 0e                	jne    8000ee <check_regs+0xae>
  8000e0:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  8000e7:	e8 e1 05 00 00       	call   8006cd <cprintf>
  8000ec:	eb 11                	jmp    8000ff <check_regs+0xbf>
  8000ee:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  8000f5:	e8 d3 05 00 00       	call   8006cd <cprintf>
  8000fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000ff:	8b 46 08             	mov    0x8(%esi),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 43 08             	mov    0x8(%ebx),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	c7 44 24 04 56 2d 80 	movl   $0x802d56,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  80011c:	e8 ac 05 00 00       	call   8006cd <cprintf>
  800121:	8b 43 08             	mov    0x8(%ebx),%eax
  800124:	3b 46 08             	cmp    0x8(%esi),%eax
  800127:	75 0e                	jne    800137 <check_regs+0xf7>
  800129:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  800130:	e8 98 05 00 00       	call   8006cd <cprintf>
  800135:	eb 11                	jmp    800148 <check_regs+0x108>
  800137:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  80013e:	e8 8a 05 00 00       	call   8006cd <cprintf>
  800143:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800148:	8b 46 10             	mov    0x10(%esi),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 43 10             	mov    0x10(%ebx),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 5a 2d 80 	movl   $0x802d5a,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  800165:	e8 63 05 00 00       	call   8006cd <cprintf>
  80016a:	8b 43 10             	mov    0x10(%ebx),%eax
  80016d:	3b 46 10             	cmp    0x10(%esi),%eax
  800170:	75 0e                	jne    800180 <check_regs+0x140>
  800172:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  800179:	e8 4f 05 00 00       	call   8006cd <cprintf>
  80017e:	eb 11                	jmp    800191 <check_regs+0x151>
  800180:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  800187:	e8 41 05 00 00       	call   8006cd <cprintf>
  80018c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800191:	8b 46 14             	mov    0x14(%esi),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 43 14             	mov    0x14(%ebx),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	c7 44 24 04 5e 2d 80 	movl   $0x802d5e,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  8001ae:	e8 1a 05 00 00       	call   8006cd <cprintf>
  8001b3:	8b 43 14             	mov    0x14(%ebx),%eax
  8001b6:	3b 46 14             	cmp    0x14(%esi),%eax
  8001b9:	75 0e                	jne    8001c9 <check_regs+0x189>
  8001bb:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  8001c2:	e8 06 05 00 00       	call   8006cd <cprintf>
  8001c7:	eb 11                	jmp    8001da <check_regs+0x19a>
  8001c9:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  8001d0:	e8 f8 04 00 00       	call   8006cd <cprintf>
  8001d5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001da:	8b 46 18             	mov    0x18(%esi),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 43 18             	mov    0x18(%ebx),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	c7 44 24 04 62 2d 80 	movl   $0x802d62,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  8001f7:	e8 d1 04 00 00       	call   8006cd <cprintf>
  8001fc:	8b 43 18             	mov    0x18(%ebx),%eax
  8001ff:	3b 46 18             	cmp    0x18(%esi),%eax
  800202:	75 0e                	jne    800212 <check_regs+0x1d2>
  800204:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  80020b:	e8 bd 04 00 00       	call   8006cd <cprintf>
  800210:	eb 11                	jmp    800223 <check_regs+0x1e3>
  800212:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  800219:	e8 af 04 00 00       	call   8006cd <cprintf>
  80021e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800223:	8b 46 1c             	mov    0x1c(%esi),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	c7 44 24 04 66 2d 80 	movl   $0x802d66,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  800240:	e8 88 04 00 00       	call   8006cd <cprintf>
  800245:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800248:	3b 46 1c             	cmp    0x1c(%esi),%eax
  80024b:	75 0e                	jne    80025b <check_regs+0x21b>
  80024d:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  800254:	e8 74 04 00 00       	call   8006cd <cprintf>
  800259:	eb 11                	jmp    80026c <check_regs+0x22c>
  80025b:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  800262:	e8 66 04 00 00       	call   8006cd <cprintf>
  800267:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80026c:	8b 46 20             	mov    0x20(%esi),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 43 20             	mov    0x20(%ebx),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 6a 2d 80 	movl   $0x802d6a,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  800289:	e8 3f 04 00 00       	call   8006cd <cprintf>
  80028e:	8b 43 20             	mov    0x20(%ebx),%eax
  800291:	3b 46 20             	cmp    0x20(%esi),%eax
  800294:	75 0e                	jne    8002a4 <check_regs+0x264>
  800296:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  80029d:	e8 2b 04 00 00       	call   8006cd <cprintf>
  8002a2:	eb 11                	jmp    8002b5 <check_regs+0x275>
  8002a4:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  8002ab:	e8 1d 04 00 00       	call   8006cd <cprintf>
  8002b0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002b5:	8b 46 24             	mov    0x24(%esi),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 43 24             	mov    0x24(%ebx),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 6e 2d 80 	movl   $0x802d6e,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  8002d2:	e8 f6 03 00 00       	call   8006cd <cprintf>
  8002d7:	8b 43 24             	mov    0x24(%ebx),%eax
  8002da:	3b 46 24             	cmp    0x24(%esi),%eax
  8002dd:	75 0e                	jne    8002ed <check_regs+0x2ad>
  8002df:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  8002e6:	e8 e2 03 00 00       	call   8006cd <cprintf>
  8002eb:	eb 11                	jmp    8002fe <check_regs+0x2be>
  8002ed:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  8002f4:	e8 d4 03 00 00       	call   8006cd <cprintf>
  8002f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002fe:	8b 46 28             	mov    0x28(%esi),%eax
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 43 28             	mov    0x28(%ebx),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	c7 44 24 04 75 2d 80 	movl   $0x802d75,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 34 2d 80 00 	movl   $0x802d34,(%esp)
  80031b:	e8 ad 03 00 00       	call   8006cd <cprintf>
  800320:	8b 43 28             	mov    0x28(%ebx),%eax
  800323:	3b 46 28             	cmp    0x28(%esi),%eax
  800326:	75 25                	jne    80034d <check_regs+0x30d>
  800328:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  80032f:	e8 99 03 00 00       	call   8006cd <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	c7 04 24 79 2d 80 00 	movl   $0x802d79,(%esp)
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
  80034d:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
  800354:	e8 74 03 00 00       	call   8006cd <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 79 2d 80 00 	movl   $0x802d79,(%esp)
  800367:	e8 61 03 00 00       	call   8006cd <cprintf>
  80036c:	eb 0e                	jmp    80037c <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  80036e:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  800375:	e8 53 03 00 00       	call   8006cd <cprintf>
  80037a:	eb 0c                	jmp    800388 <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80037c:	c7 04 24 48 2d 80 00 	movl   $0x802d48,(%esp)
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
  80039d:	e8 22 17 00 00       	call   801ac4 <set_pgfault_handler>

	__asm __volatile(
  8003a2:	50                   	push   %eax
  8003a3:	9c                   	pushf  
  8003a4:	58                   	pop    %eax
  8003a5:	0d d5 08 00 00       	or     $0x8d5,%eax
  8003aa:	50                   	push   %eax
  8003ab:	9d                   	popf   
  8003ac:	a3 24 50 80 00       	mov    %eax,0x805024
  8003b1:	8d 05 ec 03 80 00    	lea    0x8003ec,%eax
  8003b7:	a3 20 50 80 00       	mov    %eax,0x805020
  8003bc:	58                   	pop    %eax
  8003bd:	89 3d 00 50 80 00    	mov    %edi,0x805000
  8003c3:	89 35 04 50 80 00    	mov    %esi,0x805004
  8003c9:	89 2d 08 50 80 00    	mov    %ebp,0x805008
  8003cf:	89 1d 10 50 80 00    	mov    %ebx,0x805010
  8003d5:	89 15 14 50 80 00    	mov    %edx,0x805014
  8003db:	89 0d 18 50 80 00    	mov    %ecx,0x805018
  8003e1:	a3 1c 50 80 00       	mov    %eax,0x80501c
  8003e6:	89 25 28 50 80 00    	mov    %esp,0x805028
  8003ec:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8003f3:	00 00 00 
  8003f6:	89 3d 80 50 80 00    	mov    %edi,0x805080
  8003fc:	89 35 84 50 80 00    	mov    %esi,0x805084
  800402:	89 2d 88 50 80 00    	mov    %ebp,0x805088
  800408:	89 1d 90 50 80 00    	mov    %ebx,0x805090
  80040e:	89 15 94 50 80 00    	mov    %edx,0x805094
  800414:	89 0d 98 50 80 00    	mov    %ecx,0x805098
  80041a:	a3 9c 50 80 00       	mov    %eax,0x80509c
  80041f:	89 25 a8 50 80 00    	mov    %esp,0x8050a8
  800425:	8b 3d 00 50 80 00    	mov    0x805000,%edi
  80042b:	8b 35 04 50 80 00    	mov    0x805004,%esi
  800431:	8b 2d 08 50 80 00    	mov    0x805008,%ebp
  800437:	8b 1d 10 50 80 00    	mov    0x805010,%ebx
  80043d:	8b 15 14 50 80 00    	mov    0x805014,%edx
  800443:	8b 0d 18 50 80 00    	mov    0x805018,%ecx
  800449:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80044e:	8b 25 28 50 80 00    	mov    0x805028,%esp
  800454:	50                   	push   %eax
  800455:	9c                   	pushf  
  800456:	58                   	pop    %eax
  800457:	a3 a4 50 80 00       	mov    %eax,0x8050a4
  80045c:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80045d:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800464:	74 0c                	je     800472 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800466:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  80046d:	e8 5b 02 00 00       	call   8006cd <cprintf>
	after.eip = before.eip;
  800472:	a1 20 50 80 00       	mov    0x805020,%eax
  800477:	a3 a0 50 80 00       	mov    %eax,0x8050a0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80047c:	c7 44 24 04 8e 2d 80 	movl   $0x802d8e,0x4(%esp)
  800483:	00 
  800484:	c7 04 24 9f 2d 80 00 	movl   $0x802d9f,(%esp)
  80048b:	b9 80 50 80 00       	mov    $0x805080,%ecx
  800490:	ba 87 2d 80 00       	mov    $0x802d87,%edx
  800495:	b8 00 50 80 00       	mov    $0x805000,%eax
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
  8004bf:	c7 44 24 08 00 2e 80 	movl   $0x802e00,0x8(%esp)
  8004c6:	00 
  8004c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 a5 2d 80 00 	movl   $0x802da5,(%esp)
  8004d6:	e8 39 01 00 00       	call   800614 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8004db:	8b 50 08             	mov    0x8(%eax),%edx
  8004de:	89 15 40 50 80 00    	mov    %edx,0x805040
  8004e4:	8b 50 0c             	mov    0xc(%eax),%edx
  8004e7:	89 15 44 50 80 00    	mov    %edx,0x805044
  8004ed:	8b 50 10             	mov    0x10(%eax),%edx
  8004f0:	89 15 48 50 80 00    	mov    %edx,0x805048
  8004f6:	8b 50 14             	mov    0x14(%eax),%edx
  8004f9:	89 15 4c 50 80 00    	mov    %edx,0x80504c
  8004ff:	8b 50 18             	mov    0x18(%eax),%edx
  800502:	89 15 50 50 80 00    	mov    %edx,0x805050
  800508:	8b 50 1c             	mov    0x1c(%eax),%edx
  80050b:	89 15 54 50 80 00    	mov    %edx,0x805054
  800511:	8b 50 20             	mov    0x20(%eax),%edx
  800514:	89 15 58 50 80 00    	mov    %edx,0x805058
  80051a:	8b 50 24             	mov    0x24(%eax),%edx
  80051d:	89 15 5c 50 80 00    	mov    %edx,0x80505c
	during.eip = utf->utf_eip;
  800523:	8b 50 28             	mov    0x28(%eax),%edx
  800526:	89 15 60 50 80 00    	mov    %edx,0x805060
	during.eflags = utf->utf_eflags;
  80052c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80052f:	89 15 64 50 80 00    	mov    %edx,0x805064
	during.esp = utf->utf_esp;
  800535:	8b 40 30             	mov    0x30(%eax),%eax
  800538:	a3 68 50 80 00       	mov    %eax,0x805068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80053d:	c7 44 24 04 b6 2d 80 	movl   $0x802db6,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  80054c:	b9 40 50 80 00       	mov    $0x805040,%ecx
  800551:	ba 87 2d 80 00       	mov    $0x802d87,%edx
  800556:	b8 00 50 80 00       	mov    $0x805000,%eax
  80055b:	e8 e0 fa ff ff       	call   800040 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800560:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800577:	e8 ac 13 00 00       	call   801928 <sys_page_alloc>
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 20                	jns    8005a0 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800584:	c7 44 24 08 cb 2d 80 	movl   $0x802dcb,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 a5 2d 80 00 	movl   $0x802da5,(%esp)
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
  8005b6:	e8 5c 14 00 00       	call   801a17 <sys_getenvid>
  8005bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005c0:	89 c2                	mov    %eax,%edx
  8005c2:	c1 e2 07             	shl    $0x7,%edx
  8005c5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8005cc:	a3 b4 50 80 00       	mov    %eax,0x8050b4
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005d1:	85 f6                	test   %esi,%esi
  8005d3:	7e 07                	jle    8005dc <libmain+0x38>
		binaryname = argv[0];
  8005d5:	8b 03                	mov    (%ebx),%eax
  8005d7:	a3 00 40 80 00       	mov    %eax,0x804000

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
  8005fe:	e8 18 1a 00 00       	call   80201b <close_all>
	sys_env_destroy(0);
  800603:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80060a:	e8 48 14 00 00       	call   801a57 <sys_env_destroy>
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
  80061f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800625:	e8 ed 13 00 00       	call   801a17 <sys_getenvid>
  80062a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800631:	8b 55 08             	mov    0x8(%ebp),%edx
  800634:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800638:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	c7 04 24 3c 2e 80 00 	movl   $0x802e3c,(%esp)
  800647:	e8 81 00 00 00       	call   8006cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80064c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800650:	8b 45 10             	mov    0x10(%ebp),%eax
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	e8 11 00 00 00       	call   80066c <vcprintf>
	cprintf("\n");
  80065b:	c7 04 24 50 2d 80 00 	movl   $0x802d50,(%esp)
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
  80079f:	e8 fc 22 00 00       	call   802aa0 <__udivdi3>
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
  800807:	e8 c4 23 00 00       	call   802bd0 <__umoddi3>
  80080c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800810:	0f be 80 5f 2e 80 00 	movsbl 0x802e5f(%eax),%eax
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
  8008fa:	ff 24 95 40 30 80 00 	jmp    *0x803040(,%edx,4)
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
  8009b7:	8b 14 85 a0 31 80 00 	mov    0x8031a0(,%eax,4),%edx
  8009be:	85 d2                	test   %edx,%edx
  8009c0:	75 26                	jne    8009e8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8009c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c6:	c7 44 24 08 70 2e 80 	movl   $0x802e70,0x8(%esp)
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
  8009ec:	c7 44 24 08 c2 32 80 	movl   $0x8032c2,0x8(%esp)
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
  800a2a:	be 79 2e 80 00       	mov    $0x802e79,%esi
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
  800cd4:	e8 c7 1d 00 00       	call   802aa0 <__udivdi3>
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
  800d20:	e8 ab 1e 00 00       	call   802bd0 <__umoddi3>
  800d25:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d29:	0f be 80 5f 2e 80 00 	movsbl 0x802e5f(%eax),%eax
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
  800dd5:	c7 44 24 0c 94 2f 80 	movl   $0x802f94,0xc(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 08 c2 32 80 	movl   $0x8032c2,0x8(%esp)
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
  800e0b:	c7 44 24 0c cc 2f 80 	movl   $0x802fcc,0xc(%esp)
  800e12:	00 
  800e13:	c7 44 24 08 c2 32 80 	movl   $0x8032c2,0x8(%esp)
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
  800e9f:	e8 2c 1d 00 00       	call   802bd0 <__umoddi3>
  800ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea8:	0f be 80 5f 2e 80 00 	movsbl 0x802e5f(%eax),%eax
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
  800ee1:	e8 ea 1c 00 00       	call   802bd0 <__umoddi3>
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	0f be 80 5f 2e 80 00 	movsbl 0x802e5f(%eax),%eax
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

0080146b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  801478:	b9 00 00 00 00       	mov    $0x0,%ecx
  80147d:	b8 13 00 00 00       	mov    $0x13,%eax
  801482:	8b 55 08             	mov    0x8(%ebp),%edx
  801485:	89 cb                	mov    %ecx,%ebx
  801487:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  8014a1:	8b 1c 24             	mov    (%esp),%ebx
  8014a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014a8:	89 ec                	mov    %ebp,%esp
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    

008014ac <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	89 1c 24             	mov    %ebx,(%esp)
  8014b5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014be:	b8 12 00 00 00       	mov    $0x12,%eax
  8014c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c9:	89 df                	mov    %ebx,%edi
  8014cb:	51                   	push   %ecx
  8014cc:	52                   	push   %edx
  8014cd:	53                   	push   %ebx
  8014ce:	54                   	push   %esp
  8014cf:	55                   	push   %ebp
  8014d0:	56                   	push   %esi
  8014d1:	57                   	push   %edi
  8014d2:	54                   	push   %esp
  8014d3:	5d                   	pop    %ebp
  8014d4:	8d 35 dc 14 80 00    	lea    0x8014dc,%esi
  8014da:	0f 34                	sysenter 
  8014dc:	5f                   	pop    %edi
  8014dd:	5e                   	pop    %esi
  8014de:	5d                   	pop    %ebp
  8014df:	5c                   	pop    %esp
  8014e0:	5b                   	pop    %ebx
  8014e1:	5a                   	pop    %edx
  8014e2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8014e3:	8b 1c 24             	mov    (%esp),%ebx
  8014e6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014ea:	89 ec                	mov    %ebp,%esp
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 08             	sub    $0x8,%esp
  8014f4:	89 1c 24             	mov    %ebx,(%esp)
  8014f7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801500:	b8 11 00 00 00       	mov    $0x11,%eax
  801505:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801508:	8b 55 08             	mov    0x8(%ebp),%edx
  80150b:	89 df                	mov    %ebx,%edi
  80150d:	51                   	push   %ecx
  80150e:	52                   	push   %edx
  80150f:	53                   	push   %ebx
  801510:	54                   	push   %esp
  801511:	55                   	push   %ebp
  801512:	56                   	push   %esi
  801513:	57                   	push   %edi
  801514:	54                   	push   %esp
  801515:	5d                   	pop    %ebp
  801516:	8d 35 1e 15 80 00    	lea    0x80151e,%esi
  80151c:	0f 34                	sysenter 
  80151e:	5f                   	pop    %edi
  80151f:	5e                   	pop    %esi
  801520:	5d                   	pop    %ebp
  801521:	5c                   	pop    %esp
  801522:	5b                   	pop    %ebx
  801523:	5a                   	pop    %edx
  801524:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801525:	8b 1c 24             	mov    (%esp),%ebx
  801528:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80152c:	89 ec                	mov    %ebp,%esp
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	89 1c 24             	mov    %ebx,(%esp)
  801539:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80153d:	b8 10 00 00 00       	mov    $0x10,%eax
  801542:	8b 7d 14             	mov    0x14(%ebp),%edi
  801545:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801548:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154b:	8b 55 08             	mov    0x8(%ebp),%edx
  80154e:	51                   	push   %ecx
  80154f:	52                   	push   %edx
  801550:	53                   	push   %ebx
  801551:	54                   	push   %esp
  801552:	55                   	push   %ebp
  801553:	56                   	push   %esi
  801554:	57                   	push   %edi
  801555:	54                   	push   %esp
  801556:	5d                   	pop    %ebp
  801557:	8d 35 5f 15 80 00    	lea    0x80155f,%esi
  80155d:	0f 34                	sysenter 
  80155f:	5f                   	pop    %edi
  801560:	5e                   	pop    %esi
  801561:	5d                   	pop    %ebp
  801562:	5c                   	pop    %esp
  801563:	5b                   	pop    %ebx
  801564:	5a                   	pop    %edx
  801565:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801566:	8b 1c 24             	mov    (%esp),%ebx
  801569:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80156d:	89 ec                	mov    %ebp,%esp
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 28             	sub    $0x28,%esp
  801577:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80157a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80157d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801582:	b8 0f 00 00 00       	mov    $0xf,%eax
  801587:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80158a:	8b 55 08             	mov    0x8(%ebp),%edx
  80158d:	89 df                	mov    %ebx,%edi
  80158f:	51                   	push   %ecx
  801590:	52                   	push   %edx
  801591:	53                   	push   %ebx
  801592:	54                   	push   %esp
  801593:	55                   	push   %ebp
  801594:	56                   	push   %esi
  801595:	57                   	push   %edi
  801596:	54                   	push   %esp
  801597:	5d                   	pop    %ebp
  801598:	8d 35 a0 15 80 00    	lea    0x8015a0,%esi
  80159e:	0f 34                	sysenter 
  8015a0:	5f                   	pop    %edi
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	5c                   	pop    %esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5a                   	pop    %edx
  8015a6:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	7e 28                	jle    8015d3 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015af:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8015b6:	00 
  8015b7:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  8015be:	00 
  8015bf:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015c6:	00 
  8015c7:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  8015ce:	e8 41 f0 ff ff       	call   800614 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8015d3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015d6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015d9:	89 ec                	mov    %ebp,%esp
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	89 1c 24             	mov    %ebx,(%esp)
  8015e6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ef:	b8 15 00 00 00       	mov    $0x15,%eax
  8015f4:	89 d1                	mov    %edx,%ecx
  8015f6:	89 d3                	mov    %edx,%ebx
  8015f8:	89 d7                	mov    %edx,%edi
  8015fa:	51                   	push   %ecx
  8015fb:	52                   	push   %edx
  8015fc:	53                   	push   %ebx
  8015fd:	54                   	push   %esp
  8015fe:	55                   	push   %ebp
  8015ff:	56                   	push   %esi
  801600:	57                   	push   %edi
  801601:	54                   	push   %esp
  801602:	5d                   	pop    %ebp
  801603:	8d 35 0b 16 80 00    	lea    0x80160b,%esi
  801609:	0f 34                	sysenter 
  80160b:	5f                   	pop    %edi
  80160c:	5e                   	pop    %esi
  80160d:	5d                   	pop    %ebp
  80160e:	5c                   	pop    %esp
  80160f:	5b                   	pop    %ebx
  801610:	5a                   	pop    %edx
  801611:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801612:	8b 1c 24             	mov    (%esp),%ebx
  801615:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801619:	89 ec                	mov    %ebp,%esp
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	89 1c 24             	mov    %ebx,(%esp)
  801626:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80162a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80162f:	b8 14 00 00 00       	mov    $0x14,%eax
  801634:	8b 55 08             	mov    0x8(%ebp),%edx
  801637:	89 cb                	mov    %ecx,%ebx
  801639:	89 cf                	mov    %ecx,%edi
  80163b:	51                   	push   %ecx
  80163c:	52                   	push   %edx
  80163d:	53                   	push   %ebx
  80163e:	54                   	push   %esp
  80163f:	55                   	push   %ebp
  801640:	56                   	push   %esi
  801641:	57                   	push   %edi
  801642:	54                   	push   %esp
  801643:	5d                   	pop    %ebp
  801644:	8d 35 4c 16 80 00    	lea    0x80164c,%esi
  80164a:	0f 34                	sysenter 
  80164c:	5f                   	pop    %edi
  80164d:	5e                   	pop    %esi
  80164e:	5d                   	pop    %ebp
  80164f:	5c                   	pop    %esp
  801650:	5b                   	pop    %ebx
  801651:	5a                   	pop    %edx
  801652:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801653:	8b 1c 24             	mov    (%esp),%ebx
  801656:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80165a:	89 ec                	mov    %ebp,%esp
  80165c:	5d                   	pop    %ebp
  80165d:	c3                   	ret    

0080165e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	83 ec 28             	sub    $0x28,%esp
  801664:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801667:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80166a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80166f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801674:	8b 55 08             	mov    0x8(%ebp),%edx
  801677:	89 cb                	mov    %ecx,%ebx
  801679:	89 cf                	mov    %ecx,%edi
  80167b:	51                   	push   %ecx
  80167c:	52                   	push   %edx
  80167d:	53                   	push   %ebx
  80167e:	54                   	push   %esp
  80167f:	55                   	push   %ebp
  801680:	56                   	push   %esi
  801681:	57                   	push   %edi
  801682:	54                   	push   %esp
  801683:	5d                   	pop    %ebp
  801684:	8d 35 8c 16 80 00    	lea    0x80168c,%esi
  80168a:	0f 34                	sysenter 
  80168c:	5f                   	pop    %edi
  80168d:	5e                   	pop    %esi
  80168e:	5d                   	pop    %ebp
  80168f:	5c                   	pop    %esp
  801690:	5b                   	pop    %ebx
  801691:	5a                   	pop    %edx
  801692:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801693:	85 c0                	test   %eax,%eax
  801695:	7e 28                	jle    8016bf <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801697:	89 44 24 10          	mov    %eax,0x10(%esp)
  80169b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8016a2:	00 
  8016a3:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  8016aa:	00 
  8016ab:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8016b2:	00 
  8016b3:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  8016ba:	e8 55 ef ff ff       	call   800614 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8016bf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016c2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016c5:	89 ec                	mov    %ebp,%esp
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	89 1c 24             	mov    %ebx,(%esp)
  8016d2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8016d6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8016db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e7:	51                   	push   %ecx
  8016e8:	52                   	push   %edx
  8016e9:	53                   	push   %ebx
  8016ea:	54                   	push   %esp
  8016eb:	55                   	push   %ebp
  8016ec:	56                   	push   %esi
  8016ed:	57                   	push   %edi
  8016ee:	54                   	push   %esp
  8016ef:	5d                   	pop    %ebp
  8016f0:	8d 35 f8 16 80 00    	lea    0x8016f8,%esi
  8016f6:	0f 34                	sysenter 
  8016f8:	5f                   	pop    %edi
  8016f9:	5e                   	pop    %esi
  8016fa:	5d                   	pop    %ebp
  8016fb:	5c                   	pop    %esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5a                   	pop    %edx
  8016fe:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8016ff:	8b 1c 24             	mov    (%esp),%ebx
  801702:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801706:	89 ec                	mov    %ebp,%esp
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	83 ec 28             	sub    $0x28,%esp
  801710:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801713:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801716:	bb 00 00 00 00       	mov    $0x0,%ebx
  80171b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801723:	8b 55 08             	mov    0x8(%ebp),%edx
  801726:	89 df                	mov    %ebx,%edi
  801728:	51                   	push   %ecx
  801729:	52                   	push   %edx
  80172a:	53                   	push   %ebx
  80172b:	54                   	push   %esp
  80172c:	55                   	push   %ebp
  80172d:	56                   	push   %esi
  80172e:	57                   	push   %edi
  80172f:	54                   	push   %esp
  801730:	5d                   	pop    %ebp
  801731:	8d 35 39 17 80 00    	lea    0x801739,%esi
  801737:	0f 34                	sysenter 
  801739:	5f                   	pop    %edi
  80173a:	5e                   	pop    %esi
  80173b:	5d                   	pop    %ebp
  80173c:	5c                   	pop    %esp
  80173d:	5b                   	pop    %ebx
  80173e:	5a                   	pop    %edx
  80173f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801740:	85 c0                	test   %eax,%eax
  801742:	7e 28                	jle    80176c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801744:	89 44 24 10          	mov    %eax,0x10(%esp)
  801748:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80174f:	00 
  801750:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  801757:	00 
  801758:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80175f:	00 
  801760:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  801767:	e8 a8 ee ff ff       	call   800614 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80176c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80176f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801772:	89 ec                	mov    %ebp,%esp
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    

00801776 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	83 ec 28             	sub    $0x28,%esp
  80177c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80177f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801782:	bb 00 00 00 00       	mov    $0x0,%ebx
  801787:	b8 0a 00 00 00       	mov    $0xa,%eax
  80178c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178f:	8b 55 08             	mov    0x8(%ebp),%edx
  801792:	89 df                	mov    %ebx,%edi
  801794:	51                   	push   %ecx
  801795:	52                   	push   %edx
  801796:	53                   	push   %ebx
  801797:	54                   	push   %esp
  801798:	55                   	push   %ebp
  801799:	56                   	push   %esi
  80179a:	57                   	push   %edi
  80179b:	54                   	push   %esp
  80179c:	5d                   	pop    %ebp
  80179d:	8d 35 a5 17 80 00    	lea    0x8017a5,%esi
  8017a3:	0f 34                	sysenter 
  8017a5:	5f                   	pop    %edi
  8017a6:	5e                   	pop    %esi
  8017a7:	5d                   	pop    %ebp
  8017a8:	5c                   	pop    %esp
  8017a9:	5b                   	pop    %ebx
  8017aa:	5a                   	pop    %edx
  8017ab:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	7e 28                	jle    8017d8 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017b4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8017bb:	00 
  8017bc:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  8017c3:	00 
  8017c4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8017cb:	00 
  8017cc:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  8017d3:	e8 3c ee ff ff       	call   800614 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8017d8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017de:	89 ec                	mov    %ebp,%esp
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 28             	sub    $0x28,%esp
  8017e8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017eb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8017ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f3:	b8 09 00 00 00       	mov    $0x9,%eax
  8017f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8017fe:	89 df                	mov    %ebx,%edi
  801800:	51                   	push   %ecx
  801801:	52                   	push   %edx
  801802:	53                   	push   %ebx
  801803:	54                   	push   %esp
  801804:	55                   	push   %ebp
  801805:	56                   	push   %esi
  801806:	57                   	push   %edi
  801807:	54                   	push   %esp
  801808:	5d                   	pop    %ebp
  801809:	8d 35 11 18 80 00    	lea    0x801811,%esi
  80180f:	0f 34                	sysenter 
  801811:	5f                   	pop    %edi
  801812:	5e                   	pop    %esi
  801813:	5d                   	pop    %ebp
  801814:	5c                   	pop    %esp
  801815:	5b                   	pop    %ebx
  801816:	5a                   	pop    %edx
  801817:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801818:	85 c0                	test   %eax,%eax
  80181a:	7e 28                	jle    801844 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80181c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801820:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801827:	00 
  801828:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  80182f:	00 
  801830:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801837:	00 
  801838:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  80183f:	e8 d0 ed ff ff       	call   800614 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801844:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801847:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80184a:	89 ec                	mov    %ebp,%esp
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 28             	sub    $0x28,%esp
  801854:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801857:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80185a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80185f:	b8 07 00 00 00       	mov    $0x7,%eax
  801864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801867:	8b 55 08             	mov    0x8(%ebp),%edx
  80186a:	89 df                	mov    %ebx,%edi
  80186c:	51                   	push   %ecx
  80186d:	52                   	push   %edx
  80186e:	53                   	push   %ebx
  80186f:	54                   	push   %esp
  801870:	55                   	push   %ebp
  801871:	56                   	push   %esi
  801872:	57                   	push   %edi
  801873:	54                   	push   %esp
  801874:	5d                   	pop    %ebp
  801875:	8d 35 7d 18 80 00    	lea    0x80187d,%esi
  80187b:	0f 34                	sysenter 
  80187d:	5f                   	pop    %edi
  80187e:	5e                   	pop    %esi
  80187f:	5d                   	pop    %ebp
  801880:	5c                   	pop    %esp
  801881:	5b                   	pop    %ebx
  801882:	5a                   	pop    %edx
  801883:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801884:	85 c0                	test   %eax,%eax
  801886:	7e 28                	jle    8018b0 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801888:	89 44 24 10          	mov    %eax,0x10(%esp)
  80188c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801893:	00 
  801894:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  80189b:	00 
  80189c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8018a3:	00 
  8018a4:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  8018ab:	e8 64 ed ff ff       	call   800614 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8018b0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018b3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018b6:	89 ec                	mov    %ebp,%esp
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 28             	sub    $0x28,%esp
  8018c0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018c3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8018c6:	8b 7d 18             	mov    0x18(%ebp),%edi
  8018c9:	0b 7d 14             	or     0x14(%ebp),%edi
  8018cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8018da:	51                   	push   %ecx
  8018db:	52                   	push   %edx
  8018dc:	53                   	push   %ebx
  8018dd:	54                   	push   %esp
  8018de:	55                   	push   %ebp
  8018df:	56                   	push   %esi
  8018e0:	57                   	push   %edi
  8018e1:	54                   	push   %esp
  8018e2:	5d                   	pop    %ebp
  8018e3:	8d 35 eb 18 80 00    	lea    0x8018eb,%esi
  8018e9:	0f 34                	sysenter 
  8018eb:	5f                   	pop    %edi
  8018ec:	5e                   	pop    %esi
  8018ed:	5d                   	pop    %ebp
  8018ee:	5c                   	pop    %esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5a                   	pop    %edx
  8018f1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	7e 28                	jle    80191e <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018fa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801901:	00 
  801902:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  801909:	00 
  80190a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801911:	00 
  801912:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  801919:	e8 f6 ec ff ff       	call   800614 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80191e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801921:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801924:	89 ec                	mov    %ebp,%esp
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	83 ec 28             	sub    $0x28,%esp
  80192e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801931:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801934:	bf 00 00 00 00       	mov    $0x0,%edi
  801939:	b8 05 00 00 00       	mov    $0x5,%eax
  80193e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801941:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801944:	8b 55 08             	mov    0x8(%ebp),%edx
  801947:	51                   	push   %ecx
  801948:	52                   	push   %edx
  801949:	53                   	push   %ebx
  80194a:	54                   	push   %esp
  80194b:	55                   	push   %ebp
  80194c:	56                   	push   %esi
  80194d:	57                   	push   %edi
  80194e:	54                   	push   %esp
  80194f:	5d                   	pop    %ebp
  801950:	8d 35 58 19 80 00    	lea    0x801958,%esi
  801956:	0f 34                	sysenter 
  801958:	5f                   	pop    %edi
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	5c                   	pop    %esp
  80195c:	5b                   	pop    %ebx
  80195d:	5a                   	pop    %edx
  80195e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80195f:	85 c0                	test   %eax,%eax
  801961:	7e 28                	jle    80198b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801963:	89 44 24 10          	mov    %eax,0x10(%esp)
  801967:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80196e:	00 
  80196f:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  801976:	00 
  801977:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80197e:	00 
  80197f:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  801986:	e8 89 ec ff ff       	call   800614 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80198b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80198e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801991:	89 ec                	mov    %ebp,%esp
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 08             	sub    $0x8,%esp
  80199b:	89 1c 24             	mov    %ebx,(%esp)
  80199e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8019a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8019ac:	89 d1                	mov    %edx,%ecx
  8019ae:	89 d3                	mov    %edx,%ebx
  8019b0:	89 d7                	mov    %edx,%edi
  8019b2:	51                   	push   %ecx
  8019b3:	52                   	push   %edx
  8019b4:	53                   	push   %ebx
  8019b5:	54                   	push   %esp
  8019b6:	55                   	push   %ebp
  8019b7:	56                   	push   %esi
  8019b8:	57                   	push   %edi
  8019b9:	54                   	push   %esp
  8019ba:	5d                   	pop    %ebp
  8019bb:	8d 35 c3 19 80 00    	lea    0x8019c3,%esi
  8019c1:	0f 34                	sysenter 
  8019c3:	5f                   	pop    %edi
  8019c4:	5e                   	pop    %esi
  8019c5:	5d                   	pop    %ebp
  8019c6:	5c                   	pop    %esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5a                   	pop    %edx
  8019c9:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8019ca:	8b 1c 24             	mov    (%esp),%ebx
  8019cd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8019d1:	89 ec                	mov    %ebp,%esp
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	89 1c 24             	mov    %ebx,(%esp)
  8019de:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8019e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8019f2:	89 df                	mov    %ebx,%edi
  8019f4:	51                   	push   %ecx
  8019f5:	52                   	push   %edx
  8019f6:	53                   	push   %ebx
  8019f7:	54                   	push   %esp
  8019f8:	55                   	push   %ebp
  8019f9:	56                   	push   %esi
  8019fa:	57                   	push   %edi
  8019fb:	54                   	push   %esp
  8019fc:	5d                   	pop    %ebp
  8019fd:	8d 35 05 1a 80 00    	lea    0x801a05,%esi
  801a03:	0f 34                	sysenter 
  801a05:	5f                   	pop    %edi
  801a06:	5e                   	pop    %esi
  801a07:	5d                   	pop    %ebp
  801a08:	5c                   	pop    %esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5a                   	pop    %edx
  801a0b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801a0c:	8b 1c 24             	mov    (%esp),%ebx
  801a0f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a13:	89 ec                	mov    %ebp,%esp
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	89 1c 24             	mov    %ebx,(%esp)
  801a20:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx
  801a29:	b8 02 00 00 00       	mov    $0x2,%eax
  801a2e:	89 d1                	mov    %edx,%ecx
  801a30:	89 d3                	mov    %edx,%ebx
  801a32:	89 d7                	mov    %edx,%edi
  801a34:	51                   	push   %ecx
  801a35:	52                   	push   %edx
  801a36:	53                   	push   %ebx
  801a37:	54                   	push   %esp
  801a38:	55                   	push   %ebp
  801a39:	56                   	push   %esi
  801a3a:	57                   	push   %edi
  801a3b:	54                   	push   %esp
  801a3c:	5d                   	pop    %ebp
  801a3d:	8d 35 45 1a 80 00    	lea    0x801a45,%esi
  801a43:	0f 34                	sysenter 
  801a45:	5f                   	pop    %edi
  801a46:	5e                   	pop    %esi
  801a47:	5d                   	pop    %ebp
  801a48:	5c                   	pop    %esp
  801a49:	5b                   	pop    %ebx
  801a4a:	5a                   	pop    %edx
  801a4b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801a4c:	8b 1c 24             	mov    (%esp),%ebx
  801a4f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a53:	89 ec                	mov    %ebp,%esp
  801a55:	5d                   	pop    %ebp
  801a56:	c3                   	ret    

00801a57 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 28             	sub    $0x28,%esp
  801a5d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a60:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801a63:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a68:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  801a70:	89 cb                	mov    %ecx,%ebx
  801a72:	89 cf                	mov    %ecx,%edi
  801a74:	51                   	push   %ecx
  801a75:	52                   	push   %edx
  801a76:	53                   	push   %ebx
  801a77:	54                   	push   %esp
  801a78:	55                   	push   %ebp
  801a79:	56                   	push   %esi
  801a7a:	57                   	push   %edi
  801a7b:	54                   	push   %esp
  801a7c:	5d                   	pop    %ebp
  801a7d:	8d 35 85 1a 80 00    	lea    0x801a85,%esi
  801a83:	0f 34                	sysenter 
  801a85:	5f                   	pop    %edi
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	5c                   	pop    %esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5a                   	pop    %edx
  801a8b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	7e 28                	jle    801ab8 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801a90:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a94:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801a9b:	00 
  801a9c:	c7 44 24 08 e0 31 80 	movl   $0x8031e0,0x8(%esp)
  801aa3:	00 
  801aa4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801aab:	00 
  801aac:	c7 04 24 fd 31 80 00 	movl   $0x8031fd,(%esp)
  801ab3:	e8 5c eb ff ff       	call   800614 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801ab8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801abb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801abe:	89 ec                	mov    %ebp,%esp
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    
	...

00801ac4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801aca:	83 3d b8 50 80 00 00 	cmpl   $0x0,0x8050b8
  801ad1:	75 30                	jne    801b03 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801ad3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ada:	00 
  801adb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801ae2:	ee 
  801ae3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aea:	e8 39 fe ff ff       	call   801928 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  801aef:	c7 44 24 04 10 1b 80 	movl   $0x801b10,0x4(%esp)
  801af6:	00 
  801af7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afe:	e8 07 fc ff ff       	call   80170a <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	a3 b8 50 80 00       	mov    %eax,0x8050b8
}
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    
  801b0d:	00 00                	add    %al,(%eax)
	...

00801b10 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801b10:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801b11:	a1 b8 50 80 00       	mov    0x8050b8,%eax
	call *%eax
  801b16:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801b18:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  801b1b:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  801b1f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  801b23:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  801b26:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  801b28:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  801b2c:	83 c4 08             	add    $0x8,%esp
        popal
  801b2f:	61                   	popa   
        addl $0x4,%esp
  801b30:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  801b33:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801b34:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801b35:	c3                   	ret    
	...

00801b40 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
  801b46:	05 00 00 00 30       	add    $0x30000000,%eax
  801b4b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	89 04 24             	mov    %eax,(%esp)
  801b5c:	e8 df ff ff ff       	call   801b40 <fd2num>
  801b61:	05 20 00 0d 00       	add    $0xd0020,%eax
  801b66:	c1 e0 0c             	shl    $0xc,%eax
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	57                   	push   %edi
  801b6f:	56                   	push   %esi
  801b70:	53                   	push   %ebx
  801b71:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801b74:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801b79:	a8 01                	test   $0x1,%al
  801b7b:	74 36                	je     801bb3 <fd_alloc+0x48>
  801b7d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801b82:	a8 01                	test   $0x1,%al
  801b84:	74 2d                	je     801bb3 <fd_alloc+0x48>
  801b86:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801b8b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801b90:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801b95:	89 c3                	mov    %eax,%ebx
  801b97:	89 c2                	mov    %eax,%edx
  801b99:	c1 ea 16             	shr    $0x16,%edx
  801b9c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801b9f:	f6 c2 01             	test   $0x1,%dl
  801ba2:	74 14                	je     801bb8 <fd_alloc+0x4d>
  801ba4:	89 c2                	mov    %eax,%edx
  801ba6:	c1 ea 0c             	shr    $0xc,%edx
  801ba9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801bac:	f6 c2 01             	test   $0x1,%dl
  801baf:	75 10                	jne    801bc1 <fd_alloc+0x56>
  801bb1:	eb 05                	jmp    801bb8 <fd_alloc+0x4d>
  801bb3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801bb8:	89 1f                	mov    %ebx,(%edi)
  801bba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801bbf:	eb 17                	jmp    801bd8 <fd_alloc+0x6d>
  801bc1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801bc6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801bcb:	75 c8                	jne    801b95 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801bcd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801bd3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801bd8:	5b                   	pop    %ebx
  801bd9:	5e                   	pop    %esi
  801bda:	5f                   	pop    %edi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801be0:	8b 45 08             	mov    0x8(%ebp),%eax
  801be3:	83 f8 1f             	cmp    $0x1f,%eax
  801be6:	77 36                	ja     801c1e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801be8:	05 00 00 0d 00       	add    $0xd0000,%eax
  801bed:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801bf0:	89 c2                	mov    %eax,%edx
  801bf2:	c1 ea 16             	shr    $0x16,%edx
  801bf5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bfc:	f6 c2 01             	test   $0x1,%dl
  801bff:	74 1d                	je     801c1e <fd_lookup+0x41>
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	c1 ea 0c             	shr    $0xc,%edx
  801c06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c0d:	f6 c2 01             	test   $0x1,%dl
  801c10:	74 0c                	je     801c1e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c15:	89 02                	mov    %eax,(%edx)
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801c1c:	eb 05                	jmp    801c23 <fd_lookup+0x46>
  801c1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c2b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 a0 ff ff ff       	call   801bdd <fd_lookup>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 0e                	js     801c4f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c41:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c47:	89 50 04             	mov    %edx,0x4(%eax)
  801c4a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c4f:	c9                   	leave  
  801c50:	c3                   	ret    

00801c51 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	56                   	push   %esi
  801c55:	53                   	push   %ebx
  801c56:	83 ec 10             	sub    $0x10,%esp
  801c59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  801c5f:	b8 04 40 80 00       	mov    $0x804004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801c64:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c69:	be 8c 32 80 00       	mov    $0x80328c,%esi
		if (devtab[i]->dev_id == dev_id) {
  801c6e:	39 08                	cmp    %ecx,(%eax)
  801c70:	75 10                	jne    801c82 <dev_lookup+0x31>
  801c72:	eb 04                	jmp    801c78 <dev_lookup+0x27>
  801c74:	39 08                	cmp    %ecx,(%eax)
  801c76:	75 0a                	jne    801c82 <dev_lookup+0x31>
			*dev = devtab[i];
  801c78:	89 03                	mov    %eax,(%ebx)
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801c7f:	90                   	nop
  801c80:	eb 31                	jmp    801cb3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c82:	83 c2 01             	add    $0x1,%edx
  801c85:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	75 e8                	jne    801c74 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801c8c:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  801c91:	8b 40 48             	mov    0x48(%eax),%eax
  801c94:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9c:	c7 04 24 0c 32 80 00 	movl   $0x80320c,(%esp)
  801ca3:	e8 25 ea ff ff       	call   8006cd <cprintf>
	*dev = 0;
  801ca8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    

00801cba <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 24             	sub    $0x24,%esp
  801cc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	89 04 24             	mov    %eax,(%esp)
  801cd1:	e8 07 ff ff ff       	call   801bdd <fd_lookup>
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 53                	js     801d2d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce4:	8b 00                	mov    (%eax),%eax
  801ce6:	89 04 24             	mov    %eax,(%esp)
  801ce9:	e8 63 ff ff ff       	call   801c51 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 3b                	js     801d2d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801cf2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801cf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cfa:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801cfe:	74 2d                	je     801d2d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d00:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d03:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d0a:	00 00 00 
	stat->st_isdir = 0;
  801d0d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d14:	00 00 00 
	stat->st_dev = dev;
  801d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d27:	89 14 24             	mov    %edx,(%esp)
  801d2a:	ff 50 14             	call   *0x14(%eax)
}
  801d2d:	83 c4 24             	add    $0x24,%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	83 ec 24             	sub    $0x24,%esp
  801d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d44:	89 1c 24             	mov    %ebx,(%esp)
  801d47:	e8 91 fe ff ff       	call   801bdd <fd_lookup>
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 5f                	js     801daf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5a:	8b 00                	mov    (%eax),%eax
  801d5c:	89 04 24             	mov    %eax,(%esp)
  801d5f:	e8 ed fe ff ff       	call   801c51 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d64:	85 c0                	test   %eax,%eax
  801d66:	78 47                	js     801daf <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d6b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801d6f:	75 23                	jne    801d94 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801d71:	a1 b4 50 80 00       	mov    0x8050b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801d76:	8b 40 48             	mov    0x48(%eax),%eax
  801d79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d81:	c7 04 24 2c 32 80 00 	movl   $0x80322c,(%esp)
  801d88:	e8 40 e9 ff ff       	call   8006cd <cprintf>
  801d8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801d92:	eb 1b                	jmp    801daf <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d97:	8b 48 18             	mov    0x18(%eax),%ecx
  801d9a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d9f:	85 c9                	test   %ecx,%ecx
  801da1:	74 0c                	je     801daf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801da3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801daa:	89 14 24             	mov    %edx,(%esp)
  801dad:	ff d1                	call   *%ecx
}
  801daf:	83 c4 24             	add    $0x24,%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	53                   	push   %ebx
  801db9:	83 ec 24             	sub    $0x24,%esp
  801dbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801dbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc6:	89 1c 24             	mov    %ebx,(%esp)
  801dc9:	e8 0f fe ff ff       	call   801bdd <fd_lookup>
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 66                	js     801e38 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ddc:	8b 00                	mov    (%eax),%eax
  801dde:	89 04 24             	mov    %eax,(%esp)
  801de1:	e8 6b fe ff ff       	call   801c51 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801de6:	85 c0                	test   %eax,%eax
  801de8:	78 4e                	js     801e38 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801dea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ded:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801df1:	75 23                	jne    801e16 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801df3:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  801df8:	8b 40 48             	mov    0x48(%eax),%eax
  801dfb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e03:	c7 04 24 50 32 80 00 	movl   $0x803250,(%esp)
  801e0a:	e8 be e8 ff ff       	call   8006cd <cprintf>
  801e0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801e14:	eb 22                	jmp    801e38 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e19:	8b 48 0c             	mov    0xc(%eax),%ecx
  801e1c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e21:	85 c9                	test   %ecx,%ecx
  801e23:	74 13                	je     801e38 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801e25:	8b 45 10             	mov    0x10(%ebp),%eax
  801e28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e33:	89 14 24             	mov    %edx,(%esp)
  801e36:	ff d1                	call   *%ecx
}
  801e38:	83 c4 24             	add    $0x24,%esp
  801e3b:	5b                   	pop    %ebx
  801e3c:	5d                   	pop    %ebp
  801e3d:	c3                   	ret    

00801e3e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 24             	sub    $0x24,%esp
  801e45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4f:	89 1c 24             	mov    %ebx,(%esp)
  801e52:	e8 86 fd ff ff       	call   801bdd <fd_lookup>
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 6b                	js     801ec6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e65:	8b 00                	mov    (%eax),%eax
  801e67:	89 04 24             	mov    %eax,(%esp)
  801e6a:	e8 e2 fd ff ff       	call   801c51 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	78 53                	js     801ec6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e73:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e76:	8b 42 08             	mov    0x8(%edx),%eax
  801e79:	83 e0 03             	and    $0x3,%eax
  801e7c:	83 f8 01             	cmp    $0x1,%eax
  801e7f:	75 23                	jne    801ea4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801e81:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  801e86:	8b 40 48             	mov    0x48(%eax),%eax
  801e89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e91:	c7 04 24 6d 32 80 00 	movl   $0x80326d,(%esp)
  801e98:	e8 30 e8 ff ff       	call   8006cd <cprintf>
  801e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801ea2:	eb 22                	jmp    801ec6 <read+0x88>
	}
	if (!dev->dev_read)
  801ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea7:	8b 48 08             	mov    0x8(%eax),%ecx
  801eaa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801eaf:	85 c9                	test   %ecx,%ecx
  801eb1:	74 13                	je     801ec6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801eb3:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec1:	89 14 24             	mov    %edx,(%esp)
  801ec4:	ff d1                	call   *%ecx
}
  801ec6:	83 c4 24             	add    $0x24,%esp
  801ec9:	5b                   	pop    %ebx
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    

00801ecc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	57                   	push   %edi
  801ed0:	56                   	push   %esi
  801ed1:	53                   	push   %ebx
  801ed2:	83 ec 1c             	sub    $0x1c,%esp
  801ed5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801edb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eea:	85 f6                	test   %esi,%esi
  801eec:	74 29                	je     801f17 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801eee:	89 f0                	mov    %esi,%eax
  801ef0:	29 d0                	sub    %edx,%eax
  801ef2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef6:	03 55 0c             	add    0xc(%ebp),%edx
  801ef9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801efd:	89 3c 24             	mov    %edi,(%esp)
  801f00:	e8 39 ff ff ff       	call   801e3e <read>
		if (m < 0)
  801f05:	85 c0                	test   %eax,%eax
  801f07:	78 0e                	js     801f17 <readn+0x4b>
			return m;
		if (m == 0)
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	74 08                	je     801f15 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f0d:	01 c3                	add    %eax,%ebx
  801f0f:	89 da                	mov    %ebx,%edx
  801f11:	39 f3                	cmp    %esi,%ebx
  801f13:	72 d9                	jb     801eee <readn+0x22>
  801f15:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f17:	83 c4 1c             	add    $0x1c,%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5f                   	pop    %edi
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 20             	sub    $0x20,%esp
  801f27:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f2a:	89 34 24             	mov    %esi,(%esp)
  801f2d:	e8 0e fc ff ff       	call   801b40 <fd2num>
  801f32:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f35:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f39:	89 04 24             	mov    %eax,(%esp)
  801f3c:	e8 9c fc ff ff       	call   801bdd <fd_lookup>
  801f41:	89 c3                	mov    %eax,%ebx
  801f43:	85 c0                	test   %eax,%eax
  801f45:	78 05                	js     801f4c <fd_close+0x2d>
  801f47:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801f4a:	74 0c                	je     801f58 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801f4c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801f50:	19 c0                	sbb    %eax,%eax
  801f52:	f7 d0                	not    %eax
  801f54:	21 c3                	and    %eax,%ebx
  801f56:	eb 3d                	jmp    801f95 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f58:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5f:	8b 06                	mov    (%esi),%eax
  801f61:	89 04 24             	mov    %eax,(%esp)
  801f64:	e8 e8 fc ff ff       	call   801c51 <dev_lookup>
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	78 16                	js     801f85 <fd_close+0x66>
		if (dev->dev_close)
  801f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f72:	8b 40 10             	mov    0x10(%eax),%eax
  801f75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	74 07                	je     801f85 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801f7e:	89 34 24             	mov    %esi,(%esp)
  801f81:	ff d0                	call   *%eax
  801f83:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801f85:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f90:	e8 b9 f8 ff ff       	call   80184e <sys_page_unmap>
	return r;
}
  801f95:	89 d8                	mov    %ebx,%eax
  801f97:	83 c4 20             	add    $0x20,%esp
  801f9a:	5b                   	pop    %ebx
  801f9b:	5e                   	pop    %esi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 27 fc ff ff       	call   801bdd <fd_lookup>
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	78 13                	js     801fcd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801fba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fc1:	00 
  801fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc5:	89 04 24             	mov    %eax,(%esp)
  801fc8:	e8 52 ff ff ff       	call   801f1f <fd_close>
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 18             	sub    $0x18,%esp
  801fd5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fd8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801fdb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fe2:	00 
  801fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe6:	89 04 24             	mov    %eax,(%esp)
  801fe9:	e8 79 03 00 00       	call   802367 <open>
  801fee:	89 c3                	mov    %eax,%ebx
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	78 1b                	js     80200f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffb:	89 1c 24             	mov    %ebx,(%esp)
  801ffe:	e8 b7 fc ff ff       	call   801cba <fstat>
  802003:	89 c6                	mov    %eax,%esi
	close(fd);
  802005:	89 1c 24             	mov    %ebx,(%esp)
  802008:	e8 91 ff ff ff       	call   801f9e <close>
  80200d:	89 f3                	mov    %esi,%ebx
	return r;
}
  80200f:	89 d8                	mov    %ebx,%eax
  802011:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802014:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802017:	89 ec                	mov    %ebp,%esp
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	53                   	push   %ebx
  80201f:	83 ec 14             	sub    $0x14,%esp
  802022:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  802027:	89 1c 24             	mov    %ebx,(%esp)
  80202a:	e8 6f ff ff ff       	call   801f9e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80202f:	83 c3 01             	add    $0x1,%ebx
  802032:	83 fb 20             	cmp    $0x20,%ebx
  802035:	75 f0                	jne    802027 <close_all+0xc>
		close(i);
}
  802037:	83 c4 14             	add    $0x14,%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    

0080203d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	83 ec 58             	sub    $0x58,%esp
  802043:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802046:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802049:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80204c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80204f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802052:	89 44 24 04          	mov    %eax,0x4(%esp)
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
  802059:	89 04 24             	mov    %eax,(%esp)
  80205c:	e8 7c fb ff ff       	call   801bdd <fd_lookup>
  802061:	89 c3                	mov    %eax,%ebx
  802063:	85 c0                	test   %eax,%eax
  802065:	0f 88 e0 00 00 00    	js     80214b <dup+0x10e>
		return r;
	close(newfdnum);
  80206b:	89 3c 24             	mov    %edi,(%esp)
  80206e:	e8 2b ff ff ff       	call   801f9e <close>

	newfd = INDEX2FD(newfdnum);
  802073:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802079:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80207c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80207f:	89 04 24             	mov    %eax,(%esp)
  802082:	e8 c9 fa ff ff       	call   801b50 <fd2data>
  802087:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802089:	89 34 24             	mov    %esi,(%esp)
  80208c:	e8 bf fa ff ff       	call   801b50 <fd2data>
  802091:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  802094:	89 da                	mov    %ebx,%edx
  802096:	89 d8                	mov    %ebx,%eax
  802098:	c1 e8 16             	shr    $0x16,%eax
  80209b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020a2:	a8 01                	test   $0x1,%al
  8020a4:	74 43                	je     8020e9 <dup+0xac>
  8020a6:	c1 ea 0c             	shr    $0xc,%edx
  8020a9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8020b0:	a8 01                	test   $0x1,%al
  8020b2:	74 35                	je     8020e9 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8020b4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8020bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8020c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8020c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020d2:	00 
  8020d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020de:	e8 d7 f7 ff ff       	call   8018ba <sys_page_map>
  8020e3:	89 c3                	mov    %eax,%ebx
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	78 3f                	js     802128 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ec:	89 c2                	mov    %eax,%edx
  8020ee:	c1 ea 0c             	shr    $0xc,%edx
  8020f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8020f8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8020fe:	89 54 24 10          	mov    %edx,0x10(%esp)
  802102:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802106:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80210d:	00 
  80210e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802119:	e8 9c f7 ff ff       	call   8018ba <sys_page_map>
  80211e:	89 c3                	mov    %eax,%ebx
  802120:	85 c0                	test   %eax,%eax
  802122:	78 04                	js     802128 <dup+0xeb>
  802124:	89 fb                	mov    %edi,%ebx
  802126:	eb 23                	jmp    80214b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802128:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802133:	e8 16 f7 ff ff       	call   80184e <sys_page_unmap>
	sys_page_unmap(0, nva);
  802138:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80213b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802146:	e8 03 f7 ff ff       	call   80184e <sys_page_unmap>
	return r;
}
  80214b:	89 d8                	mov    %ebx,%eax
  80214d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802150:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802153:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802156:	89 ec                	mov    %ebp,%esp
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
	...

0080215c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	83 ec 18             	sub    $0x18,%esp
  802162:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802165:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802168:	89 c3                	mov    %eax,%ebx
  80216a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80216c:	83 3d ac 50 80 00 00 	cmpl   $0x0,0x8050ac
  802173:	75 11                	jne    802186 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802175:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80217c:	e8 9f 07 00 00       	call   802920 <ipc_find_env>
  802181:	a3 ac 50 80 00       	mov    %eax,0x8050ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802186:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80218d:	00 
  80218e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802195:	00 
  802196:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80219a:	a1 ac 50 80 00       	mov    0x8050ac,%eax
  80219f:	89 04 24             	mov    %eax,(%esp)
  8021a2:	e8 c4 07 00 00       	call   80296b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021ae:	00 
  8021af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ba:	e8 2a 08 00 00       	call   8029e9 <ipc_recv>
}
  8021bf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8021c2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021c5:	89 ec                	mov    %ebp,%esp
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    

008021c9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8021d5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021dd:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e7:	b8 02 00 00 00       	mov    $0x2,%eax
  8021ec:	e8 6b ff ff ff       	call   80215c <fsipc>
}
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8021ff:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802204:	ba 00 00 00 00       	mov    $0x0,%edx
  802209:	b8 06 00 00 00       	mov    $0x6,%eax
  80220e:	e8 49 ff ff ff       	call   80215c <fsipc>
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80221b:	ba 00 00 00 00       	mov    $0x0,%edx
  802220:	b8 08 00 00 00       	mov    $0x8,%eax
  802225:	e8 32 ff ff ff       	call   80215c <fsipc>
}
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	53                   	push   %ebx
  802230:	83 ec 14             	sub    $0x14,%esp
  802233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802236:	8b 45 08             	mov    0x8(%ebp),%eax
  802239:	8b 40 0c             	mov    0xc(%eax),%eax
  80223c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802241:	ba 00 00 00 00       	mov    $0x0,%edx
  802246:	b8 05 00 00 00       	mov    $0x5,%eax
  80224b:	e8 0c ff ff ff       	call   80215c <fsipc>
  802250:	85 c0                	test   %eax,%eax
  802252:	78 2b                	js     80227f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802254:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80225b:	00 
  80225c:	89 1c 24             	mov    %ebx,(%esp)
  80225f:	e8 96 ed ff ff       	call   800ffa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802264:	a1 80 60 80 00       	mov    0x806080,%eax
  802269:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80226f:	a1 84 60 80 00       	mov    0x806084,%eax
  802274:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80227a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80227f:	83 c4 14             	add    $0x14,%esp
  802282:	5b                   	pop    %ebx
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    

00802285 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 18             	sub    $0x18,%esp
  80228b:	8b 45 10             	mov    0x10(%ebp),%eax
  80228e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802293:	76 05                	jbe    80229a <devfile_write+0x15>
  802295:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  80229a:	8b 55 08             	mov    0x8(%ebp),%edx
  80229d:	8b 52 0c             	mov    0xc(%edx),%edx
  8022a0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  8022a6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  8022ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8022bd:	e8 23 ef ff ff       	call   8011e5 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  8022c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8022cc:	e8 8b fe ff ff       	call   80215c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  8022d1:	c9                   	leave  
  8022d2:	c3                   	ret    

008022d3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	53                   	push   %ebx
  8022d7:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022da:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8022e0:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  8022e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e8:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  8022ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022f7:	e8 60 fe ff ff       	call   80215c <fsipc>
  8022fc:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8022fe:	85 c0                	test   %eax,%eax
  802300:	78 17                	js     802319 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  802302:	89 44 24 08          	mov    %eax,0x8(%esp)
  802306:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80230d:	00 
  80230e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802311:	89 04 24             	mov    %eax,(%esp)
  802314:	e8 cc ee ff ff       	call   8011e5 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  802319:	89 d8                	mov    %ebx,%eax
  80231b:	83 c4 14             	add    $0x14,%esp
  80231e:	5b                   	pop    %ebx
  80231f:	5d                   	pop    %ebp
  802320:	c3                   	ret    

00802321 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	53                   	push   %ebx
  802325:	83 ec 14             	sub    $0x14,%esp
  802328:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80232b:	89 1c 24             	mov    %ebx,(%esp)
  80232e:	e8 7d ec ff ff       	call   800fb0 <strlen>
  802333:	89 c2                	mov    %eax,%edx
  802335:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80233a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  802340:	7f 1f                	jg     802361 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  802342:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802346:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80234d:	e8 a8 ec ff ff       	call   800ffa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  802352:	ba 00 00 00 00       	mov    $0x0,%edx
  802357:	b8 07 00 00 00       	mov    $0x7,%eax
  80235c:	e8 fb fd ff ff       	call   80215c <fsipc>
}
  802361:	83 c4 14             	add    $0x14,%esp
  802364:	5b                   	pop    %ebx
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    

00802367 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802367:	55                   	push   %ebp
  802368:	89 e5                	mov    %esp,%ebp
  80236a:	83 ec 28             	sub    $0x28,%esp
  80236d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802370:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802373:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  802376:	89 34 24             	mov    %esi,(%esp)
  802379:	e8 32 ec ff ff       	call   800fb0 <strlen>
  80237e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802383:	3d 00 04 00 00       	cmp    $0x400,%eax
  802388:	7f 6d                	jg     8023f7 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80238a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238d:	89 04 24             	mov    %eax,(%esp)
  802390:	e8 d6 f7 ff ff       	call   801b6b <fd_alloc>
  802395:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  802397:	85 c0                	test   %eax,%eax
  802399:	78 5c                	js     8023f7 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80239b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80239e:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8023a3:	89 34 24             	mov    %esi,(%esp)
  8023a6:	e8 05 ec ff ff       	call   800fb0 <strlen>
  8023ab:	83 c0 01             	add    $0x1,%eax
  8023ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023b6:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8023bd:	e8 23 ee ff ff       	call   8011e5 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  8023c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ca:	e8 8d fd ff ff       	call   80215c <fsipc>
  8023cf:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  8023d1:	85 c0                	test   %eax,%eax
  8023d3:	79 15                	jns    8023ea <open+0x83>
             fd_close(fd,0);
  8023d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8023dc:	00 
  8023dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e0:	89 04 24             	mov    %eax,(%esp)
  8023e3:	e8 37 fb ff ff       	call   801f1f <fd_close>
             return r;
  8023e8:	eb 0d                	jmp    8023f7 <open+0x90>
        }
        return fd2num(fd);
  8023ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ed:	89 04 24             	mov    %eax,(%esp)
  8023f0:	e8 4b f7 ff ff       	call   801b40 <fd2num>
  8023f5:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  8023f7:	89 d8                	mov    %ebx,%eax
  8023f9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8023fc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8023ff:	89 ec                	mov    %ebp,%esp
  802401:	5d                   	pop    %ebp
  802402:	c3                   	ret    
	...

00802410 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802410:	55                   	push   %ebp
  802411:	89 e5                	mov    %esp,%ebp
  802413:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802416:	c7 44 24 04 98 32 80 	movl   $0x803298,0x4(%esp)
  80241d:	00 
  80241e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802421:	89 04 24             	mov    %eax,(%esp)
  802424:	e8 d1 eb ff ff       	call   800ffa <strcpy>
	return 0;
}
  802429:	b8 00 00 00 00       	mov    $0x0,%eax
  80242e:	c9                   	leave  
  80242f:	c3                   	ret    

00802430 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	53                   	push   %ebx
  802434:	83 ec 14             	sub    $0x14,%esp
  802437:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80243a:	89 1c 24             	mov    %ebx,(%esp)
  80243d:	e8 1a 06 00 00       	call   802a5c <pageref>
  802442:	89 c2                	mov    %eax,%edx
  802444:	b8 00 00 00 00       	mov    $0x0,%eax
  802449:	83 fa 01             	cmp    $0x1,%edx
  80244c:	75 0b                	jne    802459 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80244e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802451:	89 04 24             	mov    %eax,(%esp)
  802454:	e8 b9 02 00 00       	call   802712 <nsipc_close>
	else
		return 0;
}
  802459:	83 c4 14             	add    $0x14,%esp
  80245c:	5b                   	pop    %ebx
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    

0080245f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802465:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80246c:	00 
  80246d:	8b 45 10             	mov    0x10(%ebp),%eax
  802470:	89 44 24 08          	mov    %eax,0x8(%esp)
  802474:	8b 45 0c             	mov    0xc(%ebp),%eax
  802477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80247b:	8b 45 08             	mov    0x8(%ebp),%eax
  80247e:	8b 40 0c             	mov    0xc(%eax),%eax
  802481:	89 04 24             	mov    %eax,(%esp)
  802484:	e8 c5 02 00 00       	call   80274e <nsipc_send>
}
  802489:	c9                   	leave  
  80248a:	c3                   	ret    

0080248b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80248b:	55                   	push   %ebp
  80248c:	89 e5                	mov    %esp,%ebp
  80248e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802491:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802498:	00 
  802499:	8b 45 10             	mov    0x10(%ebp),%eax
  80249c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8024ad:	89 04 24             	mov    %eax,(%esp)
  8024b0:	e8 0c 03 00 00       	call   8027c1 <nsipc_recv>
}
  8024b5:	c9                   	leave  
  8024b6:	c3                   	ret    

008024b7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8024b7:	55                   	push   %ebp
  8024b8:	89 e5                	mov    %esp,%ebp
  8024ba:	56                   	push   %esi
  8024bb:	53                   	push   %ebx
  8024bc:	83 ec 20             	sub    $0x20,%esp
  8024bf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8024c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c4:	89 04 24             	mov    %eax,(%esp)
  8024c7:	e8 9f f6 ff ff       	call   801b6b <fd_alloc>
  8024cc:	89 c3                	mov    %eax,%ebx
  8024ce:	85 c0                	test   %eax,%eax
  8024d0:	78 21                	js     8024f3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8024d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024d9:	00 
  8024da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e8:	e8 3b f4 ff ff       	call   801928 <sys_page_alloc>
  8024ed:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8024ef:	85 c0                	test   %eax,%eax
  8024f1:	79 0a                	jns    8024fd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  8024f3:	89 34 24             	mov    %esi,(%esp)
  8024f6:	e8 17 02 00 00       	call   802712 <nsipc_close>
		return r;
  8024fb:	eb 28                	jmp    802525 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8024fd:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802506:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802515:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80251b:	89 04 24             	mov    %eax,(%esp)
  80251e:	e8 1d f6 ff ff       	call   801b40 <fd2num>
  802523:	89 c3                	mov    %eax,%ebx
}
  802525:	89 d8                	mov    %ebx,%eax
  802527:	83 c4 20             	add    $0x20,%esp
  80252a:	5b                   	pop    %ebx
  80252b:	5e                   	pop    %esi
  80252c:	5d                   	pop    %ebp
  80252d:	c3                   	ret    

0080252e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80252e:	55                   	push   %ebp
  80252f:	89 e5                	mov    %esp,%ebp
  802531:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802534:	8b 45 10             	mov    0x10(%ebp),%eax
  802537:	89 44 24 08          	mov    %eax,0x8(%esp)
  80253b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802542:	8b 45 08             	mov    0x8(%ebp),%eax
  802545:	89 04 24             	mov    %eax,(%esp)
  802548:	e8 79 01 00 00       	call   8026c6 <nsipc_socket>
  80254d:	85 c0                	test   %eax,%eax
  80254f:	78 05                	js     802556 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802551:	e8 61 ff ff ff       	call   8024b7 <alloc_sockfd>
}
  802556:	c9                   	leave  
  802557:	c3                   	ret    

00802558 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802558:	55                   	push   %ebp
  802559:	89 e5                	mov    %esp,%ebp
  80255b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80255e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802561:	89 54 24 04          	mov    %edx,0x4(%esp)
  802565:	89 04 24             	mov    %eax,(%esp)
  802568:	e8 70 f6 ff ff       	call   801bdd <fd_lookup>
  80256d:	85 c0                	test   %eax,%eax
  80256f:	78 15                	js     802586 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802571:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802574:	8b 0a                	mov    (%edx),%ecx
  802576:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80257b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802581:	75 03                	jne    802586 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802583:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802586:	c9                   	leave  
  802587:	c3                   	ret    

00802588 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80258e:	8b 45 08             	mov    0x8(%ebp),%eax
  802591:	e8 c2 ff ff ff       	call   802558 <fd2sockid>
  802596:	85 c0                	test   %eax,%eax
  802598:	78 0f                	js     8025a9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80259a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80259d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025a1:	89 04 24             	mov    %eax,(%esp)
  8025a4:	e8 47 01 00 00       	call   8026f0 <nsipc_listen>
}
  8025a9:	c9                   	leave  
  8025aa:	c3                   	ret    

008025ab <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025ab:	55                   	push   %ebp
  8025ac:	89 e5                	mov    %esp,%ebp
  8025ae:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b4:	e8 9f ff ff ff       	call   802558 <fd2sockid>
  8025b9:	85 c0                	test   %eax,%eax
  8025bb:	78 16                	js     8025d3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8025bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8025c0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8025c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025cb:	89 04 24             	mov    %eax,(%esp)
  8025ce:	e8 6e 02 00 00       	call   802841 <nsipc_connect>
}
  8025d3:	c9                   	leave  
  8025d4:	c3                   	ret    

008025d5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8025d5:	55                   	push   %ebp
  8025d6:	89 e5                	mov    %esp,%ebp
  8025d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025db:	8b 45 08             	mov    0x8(%ebp),%eax
  8025de:	e8 75 ff ff ff       	call   802558 <fd2sockid>
  8025e3:	85 c0                	test   %eax,%eax
  8025e5:	78 0f                	js     8025f6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8025e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025ee:	89 04 24             	mov    %eax,(%esp)
  8025f1:	e8 36 01 00 00       	call   80272c <nsipc_shutdown>
}
  8025f6:	c9                   	leave  
  8025f7:	c3                   	ret    

008025f8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8025f8:	55                   	push   %ebp
  8025f9:	89 e5                	mov    %esp,%ebp
  8025fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802601:	e8 52 ff ff ff       	call   802558 <fd2sockid>
  802606:	85 c0                	test   %eax,%eax
  802608:	78 16                	js     802620 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80260a:	8b 55 10             	mov    0x10(%ebp),%edx
  80260d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802611:	8b 55 0c             	mov    0xc(%ebp),%edx
  802614:	89 54 24 04          	mov    %edx,0x4(%esp)
  802618:	89 04 24             	mov    %eax,(%esp)
  80261b:	e8 60 02 00 00       	call   802880 <nsipc_bind>
}
  802620:	c9                   	leave  
  802621:	c3                   	ret    

00802622 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802622:	55                   	push   %ebp
  802623:	89 e5                	mov    %esp,%ebp
  802625:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802628:	8b 45 08             	mov    0x8(%ebp),%eax
  80262b:	e8 28 ff ff ff       	call   802558 <fd2sockid>
  802630:	85 c0                	test   %eax,%eax
  802632:	78 1f                	js     802653 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802634:	8b 55 10             	mov    0x10(%ebp),%edx
  802637:	89 54 24 08          	mov    %edx,0x8(%esp)
  80263b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80263e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802642:	89 04 24             	mov    %eax,(%esp)
  802645:	e8 75 02 00 00       	call   8028bf <nsipc_accept>
  80264a:	85 c0                	test   %eax,%eax
  80264c:	78 05                	js     802653 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80264e:	e8 64 fe ff ff       	call   8024b7 <alloc_sockfd>
}
  802653:	c9                   	leave  
  802654:	c3                   	ret    
	...

00802660 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802660:	55                   	push   %ebp
  802661:	89 e5                	mov    %esp,%ebp
  802663:	53                   	push   %ebx
  802664:	83 ec 14             	sub    $0x14,%esp
  802667:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802669:	83 3d b0 50 80 00 00 	cmpl   $0x0,0x8050b0
  802670:	75 11                	jne    802683 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802672:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802679:	e8 a2 02 00 00       	call   802920 <ipc_find_env>
  80267e:	a3 b0 50 80 00       	mov    %eax,0x8050b0
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802683:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80268a:	00 
  80268b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802692:	00 
  802693:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802697:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  80269c:	89 04 24             	mov    %eax,(%esp)
  80269f:	e8 c7 02 00 00       	call   80296b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8026a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8026ab:	00 
  8026ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8026b3:	00 
  8026b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026bb:	e8 29 03 00 00       	call   8029e9 <ipc_recv>
}
  8026c0:	83 c4 14             	add    $0x14,%esp
  8026c3:	5b                   	pop    %ebx
  8026c4:	5d                   	pop    %ebp
  8026c5:	c3                   	ret    

008026c6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8026c6:	55                   	push   %ebp
  8026c7:	89 e5                	mov    %esp,%ebp
  8026c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8026cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8026d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026d7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8026dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8026df:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8026e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8026e9:	e8 72 ff ff ff       	call   802660 <nsipc>
}
  8026ee:	c9                   	leave  
  8026ef:	c3                   	ret    

008026f0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8026f0:	55                   	push   %ebp
  8026f1:	89 e5                	mov    %esp,%ebp
  8026f3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8026f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8026fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802701:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802706:	b8 06 00 00 00       	mov    $0x6,%eax
  80270b:	e8 50 ff ff ff       	call   802660 <nsipc>
}
  802710:	c9                   	leave  
  802711:	c3                   	ret    

00802712 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802712:	55                   	push   %ebp
  802713:	89 e5                	mov    %esp,%ebp
  802715:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802718:	8b 45 08             	mov    0x8(%ebp),%eax
  80271b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802720:	b8 04 00 00 00       	mov    $0x4,%eax
  802725:	e8 36 ff ff ff       	call   802660 <nsipc>
}
  80272a:	c9                   	leave  
  80272b:	c3                   	ret    

0080272c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80272c:	55                   	push   %ebp
  80272d:	89 e5                	mov    %esp,%ebp
  80272f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802732:	8b 45 08             	mov    0x8(%ebp),%eax
  802735:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80273a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80273d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802742:	b8 03 00 00 00       	mov    $0x3,%eax
  802747:	e8 14 ff ff ff       	call   802660 <nsipc>
}
  80274c:	c9                   	leave  
  80274d:	c3                   	ret    

0080274e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80274e:	55                   	push   %ebp
  80274f:	89 e5                	mov    %esp,%ebp
  802751:	53                   	push   %ebx
  802752:	83 ec 14             	sub    $0x14,%esp
  802755:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802758:	8b 45 08             	mov    0x8(%ebp),%eax
  80275b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802760:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802766:	7e 24                	jle    80278c <nsipc_send+0x3e>
  802768:	c7 44 24 0c a4 32 80 	movl   $0x8032a4,0xc(%esp)
  80276f:	00 
  802770:	c7 44 24 08 b0 32 80 	movl   $0x8032b0,0x8(%esp)
  802777:	00 
  802778:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80277f:	00 
  802780:	c7 04 24 c5 32 80 00 	movl   $0x8032c5,(%esp)
  802787:	e8 88 de ff ff       	call   800614 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80278c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802790:	8b 45 0c             	mov    0xc(%ebp),%eax
  802793:	89 44 24 04          	mov    %eax,0x4(%esp)
  802797:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80279e:	e8 42 ea ff ff       	call   8011e5 <memmove>
	nsipcbuf.send.req_size = size;
  8027a3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8027a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8027ac:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8027b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8027b6:	e8 a5 fe ff ff       	call   802660 <nsipc>
}
  8027bb:	83 c4 14             	add    $0x14,%esp
  8027be:	5b                   	pop    %ebx
  8027bf:	5d                   	pop    %ebp
  8027c0:	c3                   	ret    

008027c1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8027c1:	55                   	push   %ebp
  8027c2:	89 e5                	mov    %esp,%ebp
  8027c4:	56                   	push   %esi
  8027c5:	53                   	push   %ebx
  8027c6:	83 ec 10             	sub    $0x10,%esp
  8027c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8027cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8027cf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8027d4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8027da:	8b 45 14             	mov    0x14(%ebp),%eax
  8027dd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8027e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8027e7:	e8 74 fe ff ff       	call   802660 <nsipc>
  8027ec:	89 c3                	mov    %eax,%ebx
  8027ee:	85 c0                	test   %eax,%eax
  8027f0:	78 46                	js     802838 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8027f2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8027f7:	7f 04                	jg     8027fd <nsipc_recv+0x3c>
  8027f9:	39 c6                	cmp    %eax,%esi
  8027fb:	7d 24                	jge    802821 <nsipc_recv+0x60>
  8027fd:	c7 44 24 0c d1 32 80 	movl   $0x8032d1,0xc(%esp)
  802804:	00 
  802805:	c7 44 24 08 b0 32 80 	movl   $0x8032b0,0x8(%esp)
  80280c:	00 
  80280d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802814:	00 
  802815:	c7 04 24 c5 32 80 00 	movl   $0x8032c5,(%esp)
  80281c:	e8 f3 dd ff ff       	call   800614 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802821:	89 44 24 08          	mov    %eax,0x8(%esp)
  802825:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80282c:	00 
  80282d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802830:	89 04 24             	mov    %eax,(%esp)
  802833:	e8 ad e9 ff ff       	call   8011e5 <memmove>
	}

	return r;
}
  802838:	89 d8                	mov    %ebx,%eax
  80283a:	83 c4 10             	add    $0x10,%esp
  80283d:	5b                   	pop    %ebx
  80283e:	5e                   	pop    %esi
  80283f:	5d                   	pop    %ebp
  802840:	c3                   	ret    

00802841 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802841:	55                   	push   %ebp
  802842:	89 e5                	mov    %esp,%ebp
  802844:	53                   	push   %ebx
  802845:	83 ec 14             	sub    $0x14,%esp
  802848:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80284b:	8b 45 08             	mov    0x8(%ebp),%eax
  80284e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802853:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80285a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80285e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802865:	e8 7b e9 ff ff       	call   8011e5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80286a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802870:	b8 05 00 00 00       	mov    $0x5,%eax
  802875:	e8 e6 fd ff ff       	call   802660 <nsipc>
}
  80287a:	83 c4 14             	add    $0x14,%esp
  80287d:	5b                   	pop    %ebx
  80287e:	5d                   	pop    %ebp
  80287f:	c3                   	ret    

00802880 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802880:	55                   	push   %ebp
  802881:	89 e5                	mov    %esp,%ebp
  802883:	53                   	push   %ebx
  802884:	83 ec 14             	sub    $0x14,%esp
  802887:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80288a:	8b 45 08             	mov    0x8(%ebp),%eax
  80288d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802892:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802896:	8b 45 0c             	mov    0xc(%ebp),%eax
  802899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80289d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8028a4:	e8 3c e9 ff ff       	call   8011e5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8028a9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8028af:	b8 02 00 00 00       	mov    $0x2,%eax
  8028b4:	e8 a7 fd ff ff       	call   802660 <nsipc>
}
  8028b9:	83 c4 14             	add    $0x14,%esp
  8028bc:	5b                   	pop    %ebx
  8028bd:	5d                   	pop    %ebp
  8028be:	c3                   	ret    

008028bf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8028bf:	55                   	push   %ebp
  8028c0:	89 e5                	mov    %esp,%ebp
  8028c2:	83 ec 18             	sub    $0x18,%esp
  8028c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8028c8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8028cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8028ce:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8028d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8028d8:	e8 83 fd ff ff       	call   802660 <nsipc>
  8028dd:	89 c3                	mov    %eax,%ebx
  8028df:	85 c0                	test   %eax,%eax
  8028e1:	78 25                	js     802908 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8028e3:	be 10 70 80 00       	mov    $0x807010,%esi
  8028e8:	8b 06                	mov    (%esi),%eax
  8028ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028ee:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8028f5:	00 
  8028f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028f9:	89 04 24             	mov    %eax,(%esp)
  8028fc:	e8 e4 e8 ff ff       	call   8011e5 <memmove>
		*addrlen = ret->ret_addrlen;
  802901:	8b 16                	mov    (%esi),%edx
  802903:	8b 45 10             	mov    0x10(%ebp),%eax
  802906:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802908:	89 d8                	mov    %ebx,%eax
  80290a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80290d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802910:	89 ec                	mov    %ebp,%esp
  802912:	5d                   	pop    %ebp
  802913:	c3                   	ret    
	...

00802920 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802920:	55                   	push   %ebp
  802921:	89 e5                	mov    %esp,%ebp
  802923:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802926:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80292c:	b8 01 00 00 00       	mov    $0x1,%eax
  802931:	39 ca                	cmp    %ecx,%edx
  802933:	75 04                	jne    802939 <ipc_find_env+0x19>
  802935:	b0 00                	mov    $0x0,%al
  802937:	eb 12                	jmp    80294b <ipc_find_env+0x2b>
  802939:	89 c2                	mov    %eax,%edx
  80293b:	c1 e2 07             	shl    $0x7,%edx
  80293e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802945:	8b 12                	mov    (%edx),%edx
  802947:	39 ca                	cmp    %ecx,%edx
  802949:	75 10                	jne    80295b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80294b:	89 c2                	mov    %eax,%edx
  80294d:	c1 e2 07             	shl    $0x7,%edx
  802950:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802957:	8b 00                	mov    (%eax),%eax
  802959:	eb 0e                	jmp    802969 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80295b:	83 c0 01             	add    $0x1,%eax
  80295e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802963:	75 d4                	jne    802939 <ipc_find_env+0x19>
  802965:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802969:	5d                   	pop    %ebp
  80296a:	c3                   	ret    

0080296b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80296b:	55                   	push   %ebp
  80296c:	89 e5                	mov    %esp,%ebp
  80296e:	57                   	push   %edi
  80296f:	56                   	push   %esi
  802970:	53                   	push   %ebx
  802971:	83 ec 1c             	sub    $0x1c,%esp
  802974:	8b 75 08             	mov    0x8(%ebp),%esi
  802977:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80297a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80297d:	85 db                	test   %ebx,%ebx
  80297f:	74 19                	je     80299a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802981:	8b 45 14             	mov    0x14(%ebp),%eax
  802984:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802988:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80298c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802990:	89 34 24             	mov    %esi,(%esp)
  802993:	e8 31 ed ff ff       	call   8016c9 <sys_ipc_try_send>
  802998:	eb 1b                	jmp    8029b5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80299a:	8b 45 14             	mov    0x14(%ebp),%eax
  80299d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029a1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8029a8:	ee 
  8029a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8029ad:	89 34 24             	mov    %esi,(%esp)
  8029b0:	e8 14 ed ff ff       	call   8016c9 <sys_ipc_try_send>
           if(ret == 0)
  8029b5:	85 c0                	test   %eax,%eax
  8029b7:	74 28                	je     8029e1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8029b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029bc:	74 1c                	je     8029da <ipc_send+0x6f>
              panic("ipc send error");
  8029be:	c7 44 24 08 e6 32 80 	movl   $0x8032e6,0x8(%esp)
  8029c5:	00 
  8029c6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8029cd:	00 
  8029ce:	c7 04 24 f5 32 80 00 	movl   $0x8032f5,(%esp)
  8029d5:	e8 3a dc ff ff       	call   800614 <_panic>
           sys_yield();
  8029da:	e8 b6 ef ff ff       	call   801995 <sys_yield>
        }
  8029df:	eb 9c                	jmp    80297d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8029e1:	83 c4 1c             	add    $0x1c,%esp
  8029e4:	5b                   	pop    %ebx
  8029e5:	5e                   	pop    %esi
  8029e6:	5f                   	pop    %edi
  8029e7:	5d                   	pop    %ebp
  8029e8:	c3                   	ret    

008029e9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8029e9:	55                   	push   %ebp
  8029ea:	89 e5                	mov    %esp,%ebp
  8029ec:	56                   	push   %esi
  8029ed:	53                   	push   %ebx
  8029ee:	83 ec 10             	sub    $0x10,%esp
  8029f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8029f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8029fa:	85 c0                	test   %eax,%eax
  8029fc:	75 0e                	jne    802a0c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8029fe:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802a05:	e8 54 ec ff ff       	call   80165e <sys_ipc_recv>
  802a0a:	eb 08                	jmp    802a14 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  802a0c:	89 04 24             	mov    %eax,(%esp)
  802a0f:	e8 4a ec ff ff       	call   80165e <sys_ipc_recv>
        if(ret == 0){
  802a14:	85 c0                	test   %eax,%eax
  802a16:	75 26                	jne    802a3e <ipc_recv+0x55>
           if(from_env_store)
  802a18:	85 f6                	test   %esi,%esi
  802a1a:	74 0a                	je     802a26 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  802a1c:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  802a21:	8b 40 78             	mov    0x78(%eax),%eax
  802a24:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802a26:	85 db                	test   %ebx,%ebx
  802a28:	74 0a                	je     802a34 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  802a2a:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  802a2f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802a32:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802a34:	a1 b4 50 80 00       	mov    0x8050b4,%eax
  802a39:	8b 40 74             	mov    0x74(%eax),%eax
  802a3c:	eb 14                	jmp    802a52 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  802a3e:	85 f6                	test   %esi,%esi
  802a40:	74 06                	je     802a48 <ipc_recv+0x5f>
              *from_env_store = 0;
  802a42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802a48:	85 db                	test   %ebx,%ebx
  802a4a:	74 06                	je     802a52 <ipc_recv+0x69>
              *perm_store = 0;
  802a4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802a52:	83 c4 10             	add    $0x10,%esp
  802a55:	5b                   	pop    %ebx
  802a56:	5e                   	pop    %esi
  802a57:	5d                   	pop    %ebp
  802a58:	c3                   	ret    
  802a59:	00 00                	add    %al,(%eax)
	...

00802a5c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a5c:	55                   	push   %ebp
  802a5d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  802a62:	89 c2                	mov    %eax,%edx
  802a64:	c1 ea 16             	shr    $0x16,%edx
  802a67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a6e:	f6 c2 01             	test   $0x1,%dl
  802a71:	74 20                	je     802a93 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802a73:	c1 e8 0c             	shr    $0xc,%eax
  802a76:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802a7d:	a8 01                	test   $0x1,%al
  802a7f:	74 12                	je     802a93 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a81:	c1 e8 0c             	shr    $0xc,%eax
  802a84:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802a89:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802a8e:	0f b7 c0             	movzwl %ax,%eax
  802a91:	eb 05                	jmp    802a98 <pageref+0x3c>
  802a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a98:	5d                   	pop    %ebp
  802a99:	c3                   	ret    
  802a9a:	00 00                	add    %al,(%eax)
  802a9c:	00 00                	add    %al,(%eax)
	...

00802aa0 <__udivdi3>:
  802aa0:	55                   	push   %ebp
  802aa1:	89 e5                	mov    %esp,%ebp
  802aa3:	57                   	push   %edi
  802aa4:	56                   	push   %esi
  802aa5:	83 ec 10             	sub    $0x10,%esp
  802aa8:	8b 45 14             	mov    0x14(%ebp),%eax
  802aab:	8b 55 08             	mov    0x8(%ebp),%edx
  802aae:	8b 75 10             	mov    0x10(%ebp),%esi
  802ab1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802ab4:	85 c0                	test   %eax,%eax
  802ab6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802ab9:	75 35                	jne    802af0 <__udivdi3+0x50>
  802abb:	39 fe                	cmp    %edi,%esi
  802abd:	77 61                	ja     802b20 <__udivdi3+0x80>
  802abf:	85 f6                	test   %esi,%esi
  802ac1:	75 0b                	jne    802ace <__udivdi3+0x2e>
  802ac3:	b8 01 00 00 00       	mov    $0x1,%eax
  802ac8:	31 d2                	xor    %edx,%edx
  802aca:	f7 f6                	div    %esi
  802acc:	89 c6                	mov    %eax,%esi
  802ace:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802ad1:	31 d2                	xor    %edx,%edx
  802ad3:	89 f8                	mov    %edi,%eax
  802ad5:	f7 f6                	div    %esi
  802ad7:	89 c7                	mov    %eax,%edi
  802ad9:	89 c8                	mov    %ecx,%eax
  802adb:	f7 f6                	div    %esi
  802add:	89 c1                	mov    %eax,%ecx
  802adf:	89 fa                	mov    %edi,%edx
  802ae1:	89 c8                	mov    %ecx,%eax
  802ae3:	83 c4 10             	add    $0x10,%esp
  802ae6:	5e                   	pop    %esi
  802ae7:	5f                   	pop    %edi
  802ae8:	5d                   	pop    %ebp
  802ae9:	c3                   	ret    
  802aea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802af0:	39 f8                	cmp    %edi,%eax
  802af2:	77 1c                	ja     802b10 <__udivdi3+0x70>
  802af4:	0f bd d0             	bsr    %eax,%edx
  802af7:	83 f2 1f             	xor    $0x1f,%edx
  802afa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802afd:	75 39                	jne    802b38 <__udivdi3+0x98>
  802aff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802b02:	0f 86 a0 00 00 00    	jbe    802ba8 <__udivdi3+0x108>
  802b08:	39 f8                	cmp    %edi,%eax
  802b0a:	0f 82 98 00 00 00    	jb     802ba8 <__udivdi3+0x108>
  802b10:	31 ff                	xor    %edi,%edi
  802b12:	31 c9                	xor    %ecx,%ecx
  802b14:	89 c8                	mov    %ecx,%eax
  802b16:	89 fa                	mov    %edi,%edx
  802b18:	83 c4 10             	add    $0x10,%esp
  802b1b:	5e                   	pop    %esi
  802b1c:	5f                   	pop    %edi
  802b1d:	5d                   	pop    %ebp
  802b1e:	c3                   	ret    
  802b1f:	90                   	nop
  802b20:	89 d1                	mov    %edx,%ecx
  802b22:	89 fa                	mov    %edi,%edx
  802b24:	89 c8                	mov    %ecx,%eax
  802b26:	31 ff                	xor    %edi,%edi
  802b28:	f7 f6                	div    %esi
  802b2a:	89 c1                	mov    %eax,%ecx
  802b2c:	89 fa                	mov    %edi,%edx
  802b2e:	89 c8                	mov    %ecx,%eax
  802b30:	83 c4 10             	add    $0x10,%esp
  802b33:	5e                   	pop    %esi
  802b34:	5f                   	pop    %edi
  802b35:	5d                   	pop    %ebp
  802b36:	c3                   	ret    
  802b37:	90                   	nop
  802b38:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802b3c:	89 f2                	mov    %esi,%edx
  802b3e:	d3 e0                	shl    %cl,%eax
  802b40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802b43:	b8 20 00 00 00       	mov    $0x20,%eax
  802b48:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802b4b:	89 c1                	mov    %eax,%ecx
  802b4d:	d3 ea                	shr    %cl,%edx
  802b4f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802b53:	0b 55 ec             	or     -0x14(%ebp),%edx
  802b56:	d3 e6                	shl    %cl,%esi
  802b58:	89 c1                	mov    %eax,%ecx
  802b5a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802b5d:	89 fe                	mov    %edi,%esi
  802b5f:	d3 ee                	shr    %cl,%esi
  802b61:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802b65:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802b68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b6b:	d3 e7                	shl    %cl,%edi
  802b6d:	89 c1                	mov    %eax,%ecx
  802b6f:	d3 ea                	shr    %cl,%edx
  802b71:	09 d7                	or     %edx,%edi
  802b73:	89 f2                	mov    %esi,%edx
  802b75:	89 f8                	mov    %edi,%eax
  802b77:	f7 75 ec             	divl   -0x14(%ebp)
  802b7a:	89 d6                	mov    %edx,%esi
  802b7c:	89 c7                	mov    %eax,%edi
  802b7e:	f7 65 e8             	mull   -0x18(%ebp)
  802b81:	39 d6                	cmp    %edx,%esi
  802b83:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802b86:	72 30                	jb     802bb8 <__udivdi3+0x118>
  802b88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b8b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802b8f:	d3 e2                	shl    %cl,%edx
  802b91:	39 c2                	cmp    %eax,%edx
  802b93:	73 05                	jae    802b9a <__udivdi3+0xfa>
  802b95:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802b98:	74 1e                	je     802bb8 <__udivdi3+0x118>
  802b9a:	89 f9                	mov    %edi,%ecx
  802b9c:	31 ff                	xor    %edi,%edi
  802b9e:	e9 71 ff ff ff       	jmp    802b14 <__udivdi3+0x74>
  802ba3:	90                   	nop
  802ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ba8:	31 ff                	xor    %edi,%edi
  802baa:	b9 01 00 00 00       	mov    $0x1,%ecx
  802baf:	e9 60 ff ff ff       	jmp    802b14 <__udivdi3+0x74>
  802bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bb8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802bbb:	31 ff                	xor    %edi,%edi
  802bbd:	89 c8                	mov    %ecx,%eax
  802bbf:	89 fa                	mov    %edi,%edx
  802bc1:	83 c4 10             	add    $0x10,%esp
  802bc4:	5e                   	pop    %esi
  802bc5:	5f                   	pop    %edi
  802bc6:	5d                   	pop    %ebp
  802bc7:	c3                   	ret    
	...

00802bd0 <__umoddi3>:
  802bd0:	55                   	push   %ebp
  802bd1:	89 e5                	mov    %esp,%ebp
  802bd3:	57                   	push   %edi
  802bd4:	56                   	push   %esi
  802bd5:	83 ec 20             	sub    $0x20,%esp
  802bd8:	8b 55 14             	mov    0x14(%ebp),%edx
  802bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802bde:	8b 7d 10             	mov    0x10(%ebp),%edi
  802be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802be4:	85 d2                	test   %edx,%edx
  802be6:	89 c8                	mov    %ecx,%eax
  802be8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802beb:	75 13                	jne    802c00 <__umoddi3+0x30>
  802bed:	39 f7                	cmp    %esi,%edi
  802bef:	76 3f                	jbe    802c30 <__umoddi3+0x60>
  802bf1:	89 f2                	mov    %esi,%edx
  802bf3:	f7 f7                	div    %edi
  802bf5:	89 d0                	mov    %edx,%eax
  802bf7:	31 d2                	xor    %edx,%edx
  802bf9:	83 c4 20             	add    $0x20,%esp
  802bfc:	5e                   	pop    %esi
  802bfd:	5f                   	pop    %edi
  802bfe:	5d                   	pop    %ebp
  802bff:	c3                   	ret    
  802c00:	39 f2                	cmp    %esi,%edx
  802c02:	77 4c                	ja     802c50 <__umoddi3+0x80>
  802c04:	0f bd ca             	bsr    %edx,%ecx
  802c07:	83 f1 1f             	xor    $0x1f,%ecx
  802c0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802c0d:	75 51                	jne    802c60 <__umoddi3+0x90>
  802c0f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802c12:	0f 87 e0 00 00 00    	ja     802cf8 <__umoddi3+0x128>
  802c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c1b:	29 f8                	sub    %edi,%eax
  802c1d:	19 d6                	sbb    %edx,%esi
  802c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c25:	89 f2                	mov    %esi,%edx
  802c27:	83 c4 20             	add    $0x20,%esp
  802c2a:	5e                   	pop    %esi
  802c2b:	5f                   	pop    %edi
  802c2c:	5d                   	pop    %ebp
  802c2d:	c3                   	ret    
  802c2e:	66 90                	xchg   %ax,%ax
  802c30:	85 ff                	test   %edi,%edi
  802c32:	75 0b                	jne    802c3f <__umoddi3+0x6f>
  802c34:	b8 01 00 00 00       	mov    $0x1,%eax
  802c39:	31 d2                	xor    %edx,%edx
  802c3b:	f7 f7                	div    %edi
  802c3d:	89 c7                	mov    %eax,%edi
  802c3f:	89 f0                	mov    %esi,%eax
  802c41:	31 d2                	xor    %edx,%edx
  802c43:	f7 f7                	div    %edi
  802c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c48:	f7 f7                	div    %edi
  802c4a:	eb a9                	jmp    802bf5 <__umoddi3+0x25>
  802c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c50:	89 c8                	mov    %ecx,%eax
  802c52:	89 f2                	mov    %esi,%edx
  802c54:	83 c4 20             	add    $0x20,%esp
  802c57:	5e                   	pop    %esi
  802c58:	5f                   	pop    %edi
  802c59:	5d                   	pop    %ebp
  802c5a:	c3                   	ret    
  802c5b:	90                   	nop
  802c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802c64:	d3 e2                	shl    %cl,%edx
  802c66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802c69:	ba 20 00 00 00       	mov    $0x20,%edx
  802c6e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802c71:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802c74:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802c78:	89 fa                	mov    %edi,%edx
  802c7a:	d3 ea                	shr    %cl,%edx
  802c7c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802c80:	0b 55 f4             	or     -0xc(%ebp),%edx
  802c83:	d3 e7                	shl    %cl,%edi
  802c85:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802c89:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802c8c:	89 f2                	mov    %esi,%edx
  802c8e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802c91:	89 c7                	mov    %eax,%edi
  802c93:	d3 ea                	shr    %cl,%edx
  802c95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802c99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802c9c:	89 c2                	mov    %eax,%edx
  802c9e:	d3 e6                	shl    %cl,%esi
  802ca0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802ca4:	d3 ea                	shr    %cl,%edx
  802ca6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802caa:	09 d6                	or     %edx,%esi
  802cac:	89 f0                	mov    %esi,%eax
  802cae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802cb1:	d3 e7                	shl    %cl,%edi
  802cb3:	89 f2                	mov    %esi,%edx
  802cb5:	f7 75 f4             	divl   -0xc(%ebp)
  802cb8:	89 d6                	mov    %edx,%esi
  802cba:	f7 65 e8             	mull   -0x18(%ebp)
  802cbd:	39 d6                	cmp    %edx,%esi
  802cbf:	72 2b                	jb     802cec <__umoddi3+0x11c>
  802cc1:	39 c7                	cmp    %eax,%edi
  802cc3:	72 23                	jb     802ce8 <__umoddi3+0x118>
  802cc5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802cc9:	29 c7                	sub    %eax,%edi
  802ccb:	19 d6                	sbb    %edx,%esi
  802ccd:	89 f0                	mov    %esi,%eax
  802ccf:	89 f2                	mov    %esi,%edx
  802cd1:	d3 ef                	shr    %cl,%edi
  802cd3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802cd7:	d3 e0                	shl    %cl,%eax
  802cd9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802cdd:	09 f8                	or     %edi,%eax
  802cdf:	d3 ea                	shr    %cl,%edx
  802ce1:	83 c4 20             	add    $0x20,%esp
  802ce4:	5e                   	pop    %esi
  802ce5:	5f                   	pop    %edi
  802ce6:	5d                   	pop    %ebp
  802ce7:	c3                   	ret    
  802ce8:	39 d6                	cmp    %edx,%esi
  802cea:	75 d9                	jne    802cc5 <__umoddi3+0xf5>
  802cec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802cef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802cf2:	eb d1                	jmp    802cc5 <__umoddi3+0xf5>
  802cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802cf8:	39 f2                	cmp    %esi,%edx
  802cfa:	0f 82 18 ff ff ff    	jb     802c18 <__umoddi3+0x48>
  802d00:	e9 1d ff ff ff       	jmp    802c22 <__umoddi3+0x52>
