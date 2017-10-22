
obj/user/faultregs:     file format elf32-i386


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
  800058:	c7 44 24 04 51 1c 80 	movl   $0x801c51,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 20 1c 80 00 	movl   $0x801c20,(%esp)
  800067:	e8 71 06 00 00       	call   8006dd <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	89 44 24 08          	mov    %eax,0x8(%esp)
  800078:	c7 44 24 04 30 1c 80 	movl   $0x801c30,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  800087:	e8 51 06 00 00       	call   8006dd <cprintf>
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	3b 06                	cmp    (%esi),%eax
  800090:	75 13                	jne    8000a5 <check_regs+0x65>
  800092:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  800099:	e8 3f 06 00 00       	call   8006dd <cprintf>
  80009e:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a3:	eb 11                	jmp    8000b6 <check_regs+0x76>
  8000a5:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  8000ac:	e8 2c 06 00 00       	call   8006dd <cprintf>
  8000b1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000b6:	8b 46 04             	mov    0x4(%esi),%eax
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c4:	c7 44 24 04 52 1c 80 	movl   $0x801c52,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  8000d3:	e8 05 06 00 00       	call   8006dd <cprintf>
  8000d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000db:	3b 46 04             	cmp    0x4(%esi),%eax
  8000de:	75 0e                	jne    8000ee <check_regs+0xae>
  8000e0:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  8000e7:	e8 f1 05 00 00       	call   8006dd <cprintf>
  8000ec:	eb 11                	jmp    8000ff <check_regs+0xbf>
  8000ee:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  8000f5:	e8 e3 05 00 00       	call   8006dd <cprintf>
  8000fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000ff:	8b 46 08             	mov    0x8(%esi),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 43 08             	mov    0x8(%ebx),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	c7 44 24 04 56 1c 80 	movl   $0x801c56,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  80011c:	e8 bc 05 00 00       	call   8006dd <cprintf>
  800121:	8b 43 08             	mov    0x8(%ebx),%eax
  800124:	3b 46 08             	cmp    0x8(%esi),%eax
  800127:	75 0e                	jne    800137 <check_regs+0xf7>
  800129:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  800130:	e8 a8 05 00 00       	call   8006dd <cprintf>
  800135:	eb 11                	jmp    800148 <check_regs+0x108>
  800137:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  80013e:	e8 9a 05 00 00       	call   8006dd <cprintf>
  800143:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800148:	8b 46 10             	mov    0x10(%esi),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 43 10             	mov    0x10(%ebx),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 5a 1c 80 	movl   $0x801c5a,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  800165:	e8 73 05 00 00       	call   8006dd <cprintf>
  80016a:	8b 43 10             	mov    0x10(%ebx),%eax
  80016d:	3b 46 10             	cmp    0x10(%esi),%eax
  800170:	75 0e                	jne    800180 <check_regs+0x140>
  800172:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  800179:	e8 5f 05 00 00       	call   8006dd <cprintf>
  80017e:	eb 11                	jmp    800191 <check_regs+0x151>
  800180:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  800187:	e8 51 05 00 00       	call   8006dd <cprintf>
  80018c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800191:	8b 46 14             	mov    0x14(%esi),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 43 14             	mov    0x14(%ebx),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	c7 44 24 04 5e 1c 80 	movl   $0x801c5e,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  8001ae:	e8 2a 05 00 00       	call   8006dd <cprintf>
  8001b3:	8b 43 14             	mov    0x14(%ebx),%eax
  8001b6:	3b 46 14             	cmp    0x14(%esi),%eax
  8001b9:	75 0e                	jne    8001c9 <check_regs+0x189>
  8001bb:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  8001c2:	e8 16 05 00 00       	call   8006dd <cprintf>
  8001c7:	eb 11                	jmp    8001da <check_regs+0x19a>
  8001c9:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  8001d0:	e8 08 05 00 00       	call   8006dd <cprintf>
  8001d5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001da:	8b 46 18             	mov    0x18(%esi),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 43 18             	mov    0x18(%ebx),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	c7 44 24 04 62 1c 80 	movl   $0x801c62,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  8001f7:	e8 e1 04 00 00       	call   8006dd <cprintf>
  8001fc:	8b 43 18             	mov    0x18(%ebx),%eax
  8001ff:	3b 46 18             	cmp    0x18(%esi),%eax
  800202:	75 0e                	jne    800212 <check_regs+0x1d2>
  800204:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  80020b:	e8 cd 04 00 00       	call   8006dd <cprintf>
  800210:	eb 11                	jmp    800223 <check_regs+0x1e3>
  800212:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  800219:	e8 bf 04 00 00       	call   8006dd <cprintf>
  80021e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800223:	8b 46 1c             	mov    0x1c(%esi),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	c7 44 24 04 66 1c 80 	movl   $0x801c66,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  800240:	e8 98 04 00 00       	call   8006dd <cprintf>
  800245:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800248:	3b 46 1c             	cmp    0x1c(%esi),%eax
  80024b:	75 0e                	jne    80025b <check_regs+0x21b>
  80024d:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  800254:	e8 84 04 00 00       	call   8006dd <cprintf>
  800259:	eb 11                	jmp    80026c <check_regs+0x22c>
  80025b:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  800262:	e8 76 04 00 00       	call   8006dd <cprintf>
  800267:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80026c:	8b 46 20             	mov    0x20(%esi),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 43 20             	mov    0x20(%ebx),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 6a 1c 80 	movl   $0x801c6a,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  800289:	e8 4f 04 00 00       	call   8006dd <cprintf>
  80028e:	8b 43 20             	mov    0x20(%ebx),%eax
  800291:	3b 46 20             	cmp    0x20(%esi),%eax
  800294:	75 0e                	jne    8002a4 <check_regs+0x264>
  800296:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  80029d:	e8 3b 04 00 00       	call   8006dd <cprintf>
  8002a2:	eb 11                	jmp    8002b5 <check_regs+0x275>
  8002a4:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  8002ab:	e8 2d 04 00 00       	call   8006dd <cprintf>
  8002b0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002b5:	8b 46 24             	mov    0x24(%esi),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 43 24             	mov    0x24(%ebx),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 6e 1c 80 	movl   $0x801c6e,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  8002d2:	e8 06 04 00 00       	call   8006dd <cprintf>
  8002d7:	8b 43 24             	mov    0x24(%ebx),%eax
  8002da:	3b 46 24             	cmp    0x24(%esi),%eax
  8002dd:	75 0e                	jne    8002ed <check_regs+0x2ad>
  8002df:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  8002e6:	e8 f2 03 00 00       	call   8006dd <cprintf>
  8002eb:	eb 11                	jmp    8002fe <check_regs+0x2be>
  8002ed:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  8002f4:	e8 e4 03 00 00       	call   8006dd <cprintf>
  8002f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002fe:	8b 46 28             	mov    0x28(%esi),%eax
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 43 28             	mov    0x28(%ebx),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	c7 44 24 04 75 1c 80 	movl   $0x801c75,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 34 1c 80 00 	movl   $0x801c34,(%esp)
  80031b:	e8 bd 03 00 00       	call   8006dd <cprintf>
  800320:	8b 43 28             	mov    0x28(%ebx),%eax
  800323:	3b 46 28             	cmp    0x28(%esi),%eax
  800326:	75 25                	jne    80034d <check_regs+0x30d>
  800328:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  80032f:	e8 a9 03 00 00       	call   8006dd <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	c7 04 24 79 1c 80 00 	movl   $0x801c79,(%esp)
  800342:	e8 96 03 00 00       	call   8006dd <cprintf>
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
  80034d:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  800354:	e8 84 03 00 00       	call   8006dd <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 79 1c 80 00 	movl   $0x801c79,(%esp)
  800367:	e8 71 03 00 00       	call   8006dd <cprintf>
  80036c:	eb 0e                	jmp    80037c <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  80036e:	c7 04 24 44 1c 80 00 	movl   $0x801c44,(%esp)
  800375:	e8 63 03 00 00       	call   8006dd <cprintf>
  80037a:	eb 0c                	jmp    800388 <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80037c:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  800383:	e8 55 03 00 00       	call   8006dd <cprintf>
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
  80039d:	e8 7e 15 00 00       	call   801920 <set_pgfault_handler>

	__asm __volatile(
  8003a2:	50                   	push   %eax
  8003a3:	9c                   	pushf  
  8003a4:	58                   	pop    %eax
  8003a5:	0d d5 08 00 00       	or     $0x8d5,%eax
  8003aa:	50                   	push   %eax
  8003ab:	9d                   	popf   
  8003ac:	a3 44 30 80 00       	mov    %eax,0x803044
  8003b1:	8d 05 ec 03 80 00    	lea    0x8003ec,%eax
  8003b7:	a3 40 30 80 00       	mov    %eax,0x803040
  8003bc:	58                   	pop    %eax
  8003bd:	89 3d 20 30 80 00    	mov    %edi,0x803020
  8003c3:	89 35 24 30 80 00    	mov    %esi,0x803024
  8003c9:	89 2d 28 30 80 00    	mov    %ebp,0x803028
  8003cf:	89 1d 30 30 80 00    	mov    %ebx,0x803030
  8003d5:	89 15 34 30 80 00    	mov    %edx,0x803034
  8003db:	89 0d 38 30 80 00    	mov    %ecx,0x803038
  8003e1:	a3 3c 30 80 00       	mov    %eax,0x80303c
  8003e6:	89 25 48 30 80 00    	mov    %esp,0x803048
  8003ec:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8003f3:	00 00 00 
  8003f6:	89 3d a0 30 80 00    	mov    %edi,0x8030a0
  8003fc:	89 35 a4 30 80 00    	mov    %esi,0x8030a4
  800402:	89 2d a8 30 80 00    	mov    %ebp,0x8030a8
  800408:	89 1d b0 30 80 00    	mov    %ebx,0x8030b0
  80040e:	89 15 b4 30 80 00    	mov    %edx,0x8030b4
  800414:	89 0d b8 30 80 00    	mov    %ecx,0x8030b8
  80041a:	a3 bc 30 80 00       	mov    %eax,0x8030bc
  80041f:	89 25 c8 30 80 00    	mov    %esp,0x8030c8
  800425:	8b 3d 20 30 80 00    	mov    0x803020,%edi
  80042b:	8b 35 24 30 80 00    	mov    0x803024,%esi
  800431:	8b 2d 28 30 80 00    	mov    0x803028,%ebp
  800437:	8b 1d 30 30 80 00    	mov    0x803030,%ebx
  80043d:	8b 15 34 30 80 00    	mov    0x803034,%edx
  800443:	8b 0d 38 30 80 00    	mov    0x803038,%ecx
  800449:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80044e:	8b 25 48 30 80 00    	mov    0x803048,%esp
  800454:	50                   	push   %eax
  800455:	9c                   	pushf  
  800456:	58                   	pop    %eax
  800457:	a3 c4 30 80 00       	mov    %eax,0x8030c4
  80045c:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80045d:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800464:	74 0c                	je     800472 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800466:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  80046d:	e8 6b 02 00 00       	call   8006dd <cprintf>
	after.eip = before.eip;
  800472:	a1 40 30 80 00       	mov    0x803040,%eax
  800477:	a3 c0 30 80 00       	mov    %eax,0x8030c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80047c:	c7 44 24 04 8e 1c 80 	movl   $0x801c8e,0x4(%esp)
  800483:	00 
  800484:	c7 04 24 9f 1c 80 00 	movl   $0x801c9f,(%esp)
  80048b:	b9 a0 30 80 00       	mov    $0x8030a0,%ecx
  800490:	ba 87 1c 80 00       	mov    $0x801c87,%edx
  800495:	b8 20 30 80 00       	mov    $0x803020,%eax
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
  8004bf:	c7 44 24 08 00 1d 80 	movl   $0x801d00,0x8(%esp)
  8004c6:	00 
  8004c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 a5 1c 80 00 	movl   $0x801ca5,(%esp)
  8004d6:	e8 31 01 00 00       	call   80060c <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8004db:	8b 50 08             	mov    0x8(%eax),%edx
  8004de:	89 15 60 30 80 00    	mov    %edx,0x803060
  8004e4:	8b 50 0c             	mov    0xc(%eax),%edx
  8004e7:	89 15 64 30 80 00    	mov    %edx,0x803064
  8004ed:	8b 50 10             	mov    0x10(%eax),%edx
  8004f0:	89 15 68 30 80 00    	mov    %edx,0x803068
  8004f6:	8b 50 14             	mov    0x14(%eax),%edx
  8004f9:	89 15 6c 30 80 00    	mov    %edx,0x80306c
  8004ff:	8b 50 18             	mov    0x18(%eax),%edx
  800502:	89 15 70 30 80 00    	mov    %edx,0x803070
  800508:	8b 50 1c             	mov    0x1c(%eax),%edx
  80050b:	89 15 74 30 80 00    	mov    %edx,0x803074
  800511:	8b 50 20             	mov    0x20(%eax),%edx
  800514:	89 15 78 30 80 00    	mov    %edx,0x803078
  80051a:	8b 50 24             	mov    0x24(%eax),%edx
  80051d:	89 15 7c 30 80 00    	mov    %edx,0x80307c
	during.eip = utf->utf_eip;
  800523:	8b 50 28             	mov    0x28(%eax),%edx
  800526:	89 15 80 30 80 00    	mov    %edx,0x803080
	during.eflags = utf->utf_eflags;
  80052c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80052f:	89 15 84 30 80 00    	mov    %edx,0x803084
	during.esp = utf->utf_esp;
  800535:	8b 40 30             	mov    0x30(%eax),%eax
  800538:	a3 88 30 80 00       	mov    %eax,0x803088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80053d:	c7 44 24 04 b6 1c 80 	movl   $0x801cb6,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 c4 1c 80 00 	movl   $0x801cc4,(%esp)
  80054c:	b9 60 30 80 00       	mov    $0x803060,%ecx
  800551:	ba 87 1c 80 00       	mov    $0x801c87,%edx
  800556:	b8 20 30 80 00       	mov    $0x803020,%eax
  80055b:	e8 e0 fa ff ff       	call   800040 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800560:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800577:	e8 0a 12 00 00       	call   801786 <sys_page_alloc>
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 20                	jns    8005a0 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800584:	c7 44 24 08 cb 1c 80 	movl   $0x801ccb,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 a5 1c 80 00 	movl   $0x801ca5,(%esp)
  80059b:	e8 6c 00 00 00       	call   80060c <_panic>
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
  8005b6:	e8 ba 12 00 00       	call   801875 <sys_getenvid>
  8005bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005c0:	89 c2                	mov    %eax,%edx
  8005c2:	c1 e2 07             	shl    $0x7,%edx
  8005c5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8005cc:	a3 cc 30 80 00       	mov    %eax,0x8030cc
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
	sys_env_destroy(0);
  8005fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800605:	e8 ab 12 00 00       	call   8018b5 <sys_env_destroy>
}
  80060a:	c9                   	leave  
  80060b:	c3                   	ret    

0080060c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80060c:	55                   	push   %ebp
  80060d:	89 e5                	mov    %esp,%ebp
  80060f:	56                   	push   %esi
  800610:	53                   	push   %ebx
  800611:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800614:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800617:	a1 d0 30 80 00       	mov    0x8030d0,%eax
  80061c:	85 c0                	test   %eax,%eax
  80061e:	74 10                	je     800630 <_panic+0x24>
		cprintf("%s: ", argv0);
  800620:	89 44 24 04          	mov    %eax,0x4(%esp)
  800624:	c7 04 24 3b 1d 80 00 	movl   $0x801d3b,(%esp)
  80062b:	e8 ad 00 00 00       	call   8006dd <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800630:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800636:	e8 3a 12 00 00       	call   801875 <sys_getenvid>
  80063b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800642:	8b 55 08             	mov    0x8(%ebp),%edx
  800645:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800649:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80064d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800651:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  800658:	e8 80 00 00 00       	call   8006dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80065d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800661:	8b 45 10             	mov    0x10(%ebp),%eax
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	e8 10 00 00 00       	call   80067c <vcprintf>
	cprintf("\n");
  80066c:	c7 04 24 50 1c 80 00 	movl   $0x801c50,(%esp)
  800673:	e8 65 00 00 00       	call   8006dd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800678:	cc                   	int3   
  800679:	eb fd                	jmp    800678 <_panic+0x6c>
	...

0080067c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800685:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068c:	00 00 00 
	b.cnt = 0;
  80068f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800696:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b1:	c7 04 24 f7 06 80 00 	movl   $0x8006f7,(%esp)
  8006b8:	e8 cf 01 00 00       	call   80088c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006bd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	e8 67 0d 00 00       	call   80143c <sys_cputs>

	return b.cnt;
}
  8006d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8006e3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	89 04 24             	mov    %eax,(%esp)
  8006f0:	e8 87 ff ff ff       	call   80067c <vcprintf>
	va_end(ap);

	return cnt;
}
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	53                   	push   %ebx
  8006fb:	83 ec 14             	sub    $0x14,%esp
  8006fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800701:	8b 03                	mov    (%ebx),%eax
  800703:	8b 55 08             	mov    0x8(%ebp),%edx
  800706:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80070a:	83 c0 01             	add    $0x1,%eax
  80070d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80070f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800714:	75 19                	jne    80072f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800716:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80071d:	00 
  80071e:	8d 43 08             	lea    0x8(%ebx),%eax
  800721:	89 04 24             	mov    %eax,(%esp)
  800724:	e8 13 0d 00 00       	call   80143c <sys_cputs>
		b->idx = 0;
  800729:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80072f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800733:	83 c4 14             	add    $0x14,%esp
  800736:	5b                   	pop    %ebx
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    
  800739:	00 00                	add    %al,(%eax)
  80073b:	00 00                	add    %al,(%eax)
  80073d:	00 00                	add    %al,(%eax)
	...

00800740 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	57                   	push   %edi
  800744:	56                   	push   %esi
  800745:	53                   	push   %ebx
  800746:	83 ec 4c             	sub    $0x4c,%esp
  800749:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074c:	89 d6                	mov    %edx,%esi
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
  800757:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80075a:	8b 45 10             	mov    0x10(%ebp),%eax
  80075d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800760:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800763:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800766:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076b:	39 d1                	cmp    %edx,%ecx
  80076d:	72 07                	jb     800776 <printnum_v2+0x36>
  80076f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800772:	39 d0                	cmp    %edx,%eax
  800774:	77 5f                	ja     8007d5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800776:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80077a:	83 eb 01             	sub    $0x1,%ebx
  80077d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800789:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80078d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800790:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800793:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800796:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80079a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007a1:	00 
  8007a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a5:	89 04 24             	mov    %eax,(%esp)
  8007a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007af:	e8 ec 11 00 00       	call   8019a0 <__udivdi3>
  8007b4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007c2:	89 04 24             	mov    %eax,(%esp)
  8007c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c9:	89 f2                	mov    %esi,%edx
  8007cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ce:	e8 6d ff ff ff       	call   800740 <printnum_v2>
  8007d3:	eb 1e                	jmp    8007f3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007d5:	83 ff 2d             	cmp    $0x2d,%edi
  8007d8:	74 19                	je     8007f3 <printnum_v2+0xb3>
		while (--width > 0)
  8007da:	83 eb 01             	sub    $0x1,%ebx
  8007dd:	85 db                	test   %ebx,%ebx
  8007df:	90                   	nop
  8007e0:	7e 11                	jle    8007f3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8007e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e6:	89 3c 24             	mov    %edi,(%esp)
  8007e9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007ec:	83 eb 01             	sub    $0x1,%ebx
  8007ef:	85 db                	test   %ebx,%ebx
  8007f1:	7f ef                	jg     8007e2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800802:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800809:	00 
  80080a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80080d:	89 14 24             	mov    %edx,(%esp)
  800810:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800813:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800817:	e8 b4 12 00 00       	call   801ad0 <__umoddi3>
  80081c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800820:	0f be 80 63 1d 80 00 	movsbl 0x801d63(%eax),%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80082d:	83 c4 4c             	add    $0x4c,%esp
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5f                   	pop    %edi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800838:	83 fa 01             	cmp    $0x1,%edx
  80083b:	7e 0e                	jle    80084b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800842:	89 08                	mov    %ecx,(%eax)
  800844:	8b 02                	mov    (%edx),%eax
  800846:	8b 52 04             	mov    0x4(%edx),%edx
  800849:	eb 22                	jmp    80086d <getuint+0x38>
	else if (lflag)
  80084b:	85 d2                	test   %edx,%edx
  80084d:	74 10                	je     80085f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	8d 4a 04             	lea    0x4(%edx),%ecx
  800854:	89 08                	mov    %ecx,(%eax)
  800856:	8b 02                	mov    (%edx),%eax
  800858:	ba 00 00 00 00       	mov    $0x0,%edx
  80085d:	eb 0e                	jmp    80086d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80085f:	8b 10                	mov    (%eax),%edx
  800861:	8d 4a 04             	lea    0x4(%edx),%ecx
  800864:	89 08                	mov    %ecx,(%eax)
  800866:	8b 02                	mov    (%edx),%eax
  800868:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800875:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800879:	8b 10                	mov    (%eax),%edx
  80087b:	3b 50 04             	cmp    0x4(%eax),%edx
  80087e:	73 0a                	jae    80088a <sprintputch+0x1b>
		*b->buf++ = ch;
  800880:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800883:	88 0a                	mov    %cl,(%edx)
  800885:	83 c2 01             	add    $0x1,%edx
  800888:	89 10                	mov    %edx,(%eax)
}
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	53                   	push   %ebx
  800892:	83 ec 6c             	sub    $0x6c,%esp
  800895:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800898:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80089f:	eb 1a                	jmp    8008bb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	0f 84 66 06 00 00    	je     800f0f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b0:	89 04 24             	mov    %eax,(%esp)
  8008b3:	ff 55 08             	call   *0x8(%ebp)
  8008b6:	eb 03                	jmp    8008bb <vprintfmt+0x2f>
  8008b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008bb:	0f b6 07             	movzbl (%edi),%eax
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	83 f8 25             	cmp    $0x25,%eax
  8008c4:	75 db                	jne    8008a1 <vprintfmt+0x15>
  8008c6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8008ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008cf:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8008d6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8008db:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008e2:	be 00 00 00 00       	mov    $0x0,%esi
  8008e7:	eb 06                	jmp    8008ef <vprintfmt+0x63>
  8008e9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8008ed:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ef:	0f b6 17             	movzbl (%edi),%edx
  8008f2:	0f b6 c2             	movzbl %dl,%eax
  8008f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f8:	8d 47 01             	lea    0x1(%edi),%eax
  8008fb:	83 ea 23             	sub    $0x23,%edx
  8008fe:	80 fa 55             	cmp    $0x55,%dl
  800901:	0f 87 60 05 00 00    	ja     800e67 <vprintfmt+0x5db>
  800907:	0f b6 d2             	movzbl %dl,%edx
  80090a:	ff 24 95 a0 1e 80 00 	jmp    *0x801ea0(,%edx,4)
  800911:	b9 01 00 00 00       	mov    $0x1,%ecx
  800916:	eb d5                	jmp    8008ed <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800918:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80091b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80091e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800921:	8d 7a d0             	lea    -0x30(%edx),%edi
  800924:	83 ff 09             	cmp    $0x9,%edi
  800927:	76 08                	jbe    800931 <vprintfmt+0xa5>
  800929:	eb 40                	jmp    80096b <vprintfmt+0xdf>
  80092b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80092f:	eb bc                	jmp    8008ed <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800931:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800934:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800937:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80093b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80093e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800941:	83 ff 09             	cmp    $0x9,%edi
  800944:	76 eb                	jbe    800931 <vprintfmt+0xa5>
  800946:	eb 23                	jmp    80096b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800948:	8b 55 14             	mov    0x14(%ebp),%edx
  80094b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80094e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800951:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800953:	eb 16                	jmp    80096b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800955:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800958:	c1 fa 1f             	sar    $0x1f,%edx
  80095b:	f7 d2                	not    %edx
  80095d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800960:	eb 8b                	jmp    8008ed <vprintfmt+0x61>
  800962:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800969:	eb 82                	jmp    8008ed <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80096b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80096f:	0f 89 78 ff ff ff    	jns    8008ed <vprintfmt+0x61>
  800975:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800978:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80097b:	e9 6d ff ff ff       	jmp    8008ed <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800980:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800983:	e9 65 ff ff ff       	jmp    8008ed <vprintfmt+0x61>
  800988:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80098b:	8b 45 14             	mov    0x14(%ebp),%eax
  80098e:	8d 50 04             	lea    0x4(%eax),%edx
  800991:	89 55 14             	mov    %edx,0x14(%ebp)
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099b:	8b 00                	mov    (%eax),%eax
  80099d:	89 04 24             	mov    %eax,(%esp)
  8009a0:	ff 55 08             	call   *0x8(%ebp)
  8009a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8009a6:	e9 10 ff ff ff       	jmp    8008bb <vprintfmt+0x2f>
  8009ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b1:	8d 50 04             	lea    0x4(%eax),%edx
  8009b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b7:	8b 00                	mov    (%eax),%eax
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	c1 fa 1f             	sar    $0x1f,%edx
  8009be:	31 d0                	xor    %edx,%eax
  8009c0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009c2:	83 f8 08             	cmp    $0x8,%eax
  8009c5:	7f 0b                	jg     8009d2 <vprintfmt+0x146>
  8009c7:	8b 14 85 00 20 80 00 	mov    0x802000(,%eax,4),%edx
  8009ce:	85 d2                	test   %edx,%edx
  8009d0:	75 26                	jne    8009f8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8009d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d6:	c7 44 24 08 74 1d 80 	movl   $0x801d74,0x8(%esp)
  8009dd:	00 
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e8:	89 1c 24             	mov    %ebx,(%esp)
  8009eb:	e8 a7 05 00 00       	call   800f97 <printfmt>
  8009f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009f3:	e9 c3 fe ff ff       	jmp    8008bb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009fc:	c7 44 24 08 7d 1d 80 	movl   $0x801d7d,0x8(%esp)
  800a03:	00 
  800a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0e:	89 14 24             	mov    %edx,(%esp)
  800a11:	e8 81 05 00 00       	call   800f97 <printfmt>
  800a16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a19:	e9 9d fe ff ff       	jmp    8008bb <vprintfmt+0x2f>
  800a1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a21:	89 c7                	mov    %eax,%edi
  800a23:	89 d9                	mov    %ebx,%ecx
  800a25:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a28:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2e:	8d 50 04             	lea    0x4(%eax),%edx
  800a31:	89 55 14             	mov    %edx,0x14(%ebp)
  800a34:	8b 30                	mov    (%eax),%esi
  800a36:	85 f6                	test   %esi,%esi
  800a38:	75 05                	jne    800a3f <vprintfmt+0x1b3>
  800a3a:	be 80 1d 80 00       	mov    $0x801d80,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  800a3f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800a43:	7e 06                	jle    800a4b <vprintfmt+0x1bf>
  800a45:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800a49:	75 10                	jne    800a5b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4b:	0f be 06             	movsbl (%esi),%eax
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	0f 85 a2 00 00 00    	jne    800af8 <vprintfmt+0x26c>
  800a56:	e9 92 00 00 00       	jmp    800aed <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a5b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a5f:	89 34 24             	mov    %esi,(%esp)
  800a62:	e8 74 05 00 00       	call   800fdb <strnlen>
  800a67:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800a6a:	29 c2                	sub    %eax,%edx
  800a6c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800a6f:	85 d2                	test   %edx,%edx
  800a71:	7e d8                	jle    800a4b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800a73:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800a77:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800a7a:	89 d3                	mov    %edx,%ebx
  800a7c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a7f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800a82:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a85:	89 ce                	mov    %ecx,%esi
  800a87:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a8b:	89 34 24             	mov    %esi,(%esp)
  800a8e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a91:	83 eb 01             	sub    $0x1,%ebx
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	7f ef                	jg     800a87 <vprintfmt+0x1fb>
  800a98:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800a9b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a9e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800aa1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800aa8:	eb a1                	jmp    800a4b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aaa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800aae:	74 1b                	je     800acb <vprintfmt+0x23f>
  800ab0:	8d 50 e0             	lea    -0x20(%eax),%edx
  800ab3:	83 fa 5e             	cmp    $0x5e,%edx
  800ab6:	76 13                	jbe    800acb <vprintfmt+0x23f>
					putch('?', putdat);
  800ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abf:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800ac6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ac9:	eb 0d                	jmp    800ad8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800acb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ace:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ad2:	89 04 24             	mov    %eax,(%esp)
  800ad5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ad8:	83 ef 01             	sub    $0x1,%edi
  800adb:	0f be 06             	movsbl (%esi),%eax
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	74 05                	je     800ae7 <vprintfmt+0x25b>
  800ae2:	83 c6 01             	add    $0x1,%esi
  800ae5:	eb 1a                	jmp    800b01 <vprintfmt+0x275>
  800ae7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800aea:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800af1:	7f 1f                	jg     800b12 <vprintfmt+0x286>
  800af3:	e9 c0 fd ff ff       	jmp    8008b8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800af8:	83 c6 01             	add    $0x1,%esi
  800afb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800afe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800b01:	85 db                	test   %ebx,%ebx
  800b03:	78 a5                	js     800aaa <vprintfmt+0x21e>
  800b05:	83 eb 01             	sub    $0x1,%ebx
  800b08:	79 a0                	jns    800aaa <vprintfmt+0x21e>
  800b0a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800b0d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b10:	eb db                	jmp    800aed <vprintfmt+0x261>
  800b12:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800b15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b18:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800b1b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b22:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b29:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b2b:	83 eb 01             	sub    $0x1,%ebx
  800b2e:	85 db                	test   %ebx,%ebx
  800b30:	7f ec                	jg     800b1e <vprintfmt+0x292>
  800b32:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800b35:	e9 81 fd ff ff       	jmp    8008bb <vprintfmt+0x2f>
  800b3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b3d:	83 fe 01             	cmp    $0x1,%esi
  800b40:	7e 10                	jle    800b52 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800b42:	8b 45 14             	mov    0x14(%ebp),%eax
  800b45:	8d 50 08             	lea    0x8(%eax),%edx
  800b48:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4b:	8b 18                	mov    (%eax),%ebx
  800b4d:	8b 70 04             	mov    0x4(%eax),%esi
  800b50:	eb 26                	jmp    800b78 <vprintfmt+0x2ec>
	else if (lflag)
  800b52:	85 f6                	test   %esi,%esi
  800b54:	74 12                	je     800b68 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800b56:	8b 45 14             	mov    0x14(%ebp),%eax
  800b59:	8d 50 04             	lea    0x4(%eax),%edx
  800b5c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5f:	8b 18                	mov    (%eax),%ebx
  800b61:	89 de                	mov    %ebx,%esi
  800b63:	c1 fe 1f             	sar    $0x1f,%esi
  800b66:	eb 10                	jmp    800b78 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800b68:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6b:	8d 50 04             	lea    0x4(%eax),%edx
  800b6e:	89 55 14             	mov    %edx,0x14(%ebp)
  800b71:	8b 18                	mov    (%eax),%ebx
  800b73:	89 de                	mov    %ebx,%esi
  800b75:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800b78:	83 f9 01             	cmp    $0x1,%ecx
  800b7b:	75 1e                	jne    800b9b <vprintfmt+0x30f>
                               if((long long)num > 0){
  800b7d:	85 f6                	test   %esi,%esi
  800b7f:	78 1a                	js     800b9b <vprintfmt+0x30f>
  800b81:	85 f6                	test   %esi,%esi
  800b83:	7f 05                	jg     800b8a <vprintfmt+0x2fe>
  800b85:	83 fb 00             	cmp    $0x0,%ebx
  800b88:	76 11                	jbe    800b9b <vprintfmt+0x30f>
                                   putch('+',putdat);
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b91:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800b98:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  800b9b:	85 f6                	test   %esi,%esi
  800b9d:	78 13                	js     800bb2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b9f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800ba2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800ba5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ba8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bad:	e9 da 00 00 00       	jmp    800c8c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bc0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800bc3:	89 da                	mov    %ebx,%edx
  800bc5:	89 f1                	mov    %esi,%ecx
  800bc7:	f7 da                	neg    %edx
  800bc9:	83 d1 00             	adc    $0x0,%ecx
  800bcc:	f7 d9                	neg    %ecx
  800bce:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800bd1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800bd4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bdc:	e9 ab 00 00 00       	jmp    800c8c <vprintfmt+0x400>
  800be1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800be4:	89 f2                	mov    %esi,%edx
  800be6:	8d 45 14             	lea    0x14(%ebp),%eax
  800be9:	e8 47 fc ff ff       	call   800835 <getuint>
  800bee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800bf1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800bf4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bf7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800bfc:	e9 8b 00 00 00       	jmp    800c8c <vprintfmt+0x400>
  800c01:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c0b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c12:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800c15:	89 f2                	mov    %esi,%edx
  800c17:	8d 45 14             	lea    0x14(%ebp),%eax
  800c1a:	e8 16 fc ff ff       	call   800835 <getuint>
  800c1f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800c22:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800c25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c28:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  800c2d:	eb 5d                	jmp    800c8c <vprintfmt+0x400>
  800c2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800c32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c35:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c39:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c40:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800c43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c47:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c4e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800c51:	8b 45 14             	mov    0x14(%ebp),%eax
  800c54:	8d 50 04             	lea    0x4(%eax),%edx
  800c57:	89 55 14             	mov    %edx,0x14(%ebp)
  800c5a:	8b 10                	mov    (%eax),%edx
  800c5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c61:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800c64:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800c67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c6a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c6f:	eb 1b                	jmp    800c8c <vprintfmt+0x400>
  800c71:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c74:	89 f2                	mov    %esi,%edx
  800c76:	8d 45 14             	lea    0x14(%ebp),%eax
  800c79:	e8 b7 fb ff ff       	call   800835 <getuint>
  800c7e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800c81:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800c84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c87:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c8c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800c90:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800c93:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800c96:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800c9a:	77 09                	ja     800ca5 <vprintfmt+0x419>
  800c9c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800c9f:	0f 82 ac 00 00 00    	jb     800d51 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800ca5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800ca8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800cac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800caf:	83 ea 01             	sub    $0x1,%edx
  800cb2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cb6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cba:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cbe:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800cc2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800cc5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800cc8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ccb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ccf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800cd6:	00 
  800cd7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800cda:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800cdd:	89 0c 24             	mov    %ecx,(%esp)
  800ce0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce4:	e8 b7 0c 00 00       	call   8019a0 <__udivdi3>
  800ce9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800cec:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800cef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cf7:	89 04 24             	mov    %eax,(%esp)
  800cfa:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	e8 37 fa ff ff       	call   800740 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800d09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d10:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d14:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800d17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d1b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d22:	00 
  800d23:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800d26:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800d29:	89 14 24             	mov    %edx,(%esp)
  800d2c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d30:	e8 9b 0d 00 00       	call   801ad0 <__umoddi3>
  800d35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d39:	0f be 80 63 1d 80 00 	movsbl 0x801d63(%eax),%eax
  800d40:	89 04 24             	mov    %eax,(%esp)
  800d43:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800d46:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800d4a:	74 54                	je     800da0 <vprintfmt+0x514>
  800d4c:	e9 67 fb ff ff       	jmp    8008b8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800d51:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800d55:	8d 76 00             	lea    0x0(%esi),%esi
  800d58:	0f 84 2a 01 00 00    	je     800e88 <vprintfmt+0x5fc>
		while (--width > 0)
  800d5e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d61:	83 ef 01             	sub    $0x1,%edi
  800d64:	85 ff                	test   %edi,%edi
  800d66:	0f 8e 5e 01 00 00    	jle    800eca <vprintfmt+0x63e>
  800d6c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800d6f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800d72:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d75:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800d78:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800d7b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800d7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d82:	89 1c 24             	mov    %ebx,(%esp)
  800d85:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800d88:	83 ef 01             	sub    $0x1,%edi
  800d8b:	85 ff                	test   %edi,%edi
  800d8d:	7f ef                	jg     800d7e <vprintfmt+0x4f2>
  800d8f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d92:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d95:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800d98:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800d9b:	e9 2a 01 00 00       	jmp    800eca <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800da0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800da3:	83 eb 01             	sub    $0x1,%ebx
  800da6:	85 db                	test   %ebx,%ebx
  800da8:	0f 8e 0a fb ff ff    	jle    8008b8 <vprintfmt+0x2c>
  800dae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800db4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800db7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dbb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800dc2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800dc4:	83 eb 01             	sub    $0x1,%ebx
  800dc7:	85 db                	test   %ebx,%ebx
  800dc9:	7f ec                	jg     800db7 <vprintfmt+0x52b>
  800dcb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800dce:	e9 e8 fa ff ff       	jmp    8008bb <vprintfmt+0x2f>
  800dd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800dd6:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd9:	8d 50 04             	lea    0x4(%eax),%edx
  800ddc:	89 55 14             	mov    %edx,0x14(%ebp)
  800ddf:	8b 00                	mov    (%eax),%eax
  800de1:	85 c0                	test   %eax,%eax
  800de3:	75 2a                	jne    800e0f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800de5:	c7 44 24 0c 1c 1e 80 	movl   $0x801e1c,0xc(%esp)
  800dec:	00 
  800ded:	c7 44 24 08 7d 1d 80 	movl   $0x801d7d,0x8(%esp)
  800df4:	00 
  800df5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dff:	89 0c 24             	mov    %ecx,(%esp)
  800e02:	e8 90 01 00 00       	call   800f97 <printfmt>
  800e07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e0a:	e9 ac fa ff ff       	jmp    8008bb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800e0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e12:	8b 13                	mov    (%ebx),%edx
  800e14:	83 fa 7f             	cmp    $0x7f,%edx
  800e17:	7e 29                	jle    800e42 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800e19:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800e1b:	c7 44 24 0c 54 1e 80 	movl   $0x801e54,0xc(%esp)
  800e22:	00 
  800e23:	c7 44 24 08 7d 1d 80 	movl   $0x801d7d,0x8(%esp)
  800e2a:	00 
  800e2b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	89 04 24             	mov    %eax,(%esp)
  800e35:	e8 5d 01 00 00       	call   800f97 <printfmt>
  800e3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e3d:	e9 79 fa ff ff       	jmp    8008bb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800e42:	88 10                	mov    %dl,(%eax)
  800e44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e47:	e9 6f fa ff ff       	jmp    8008bb <vprintfmt+0x2f>
  800e4c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e59:	89 14 24             	mov    %edx,(%esp)
  800e5c:	ff 55 08             	call   *0x8(%ebp)
  800e5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800e62:	e9 54 fa ff ff       	jmp    8008bb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e6e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e75:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e78:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e7b:	80 38 25             	cmpb   $0x25,(%eax)
  800e7e:	0f 84 37 fa ff ff    	je     8008bb <vprintfmt+0x2f>
  800e84:	89 c7                	mov    %eax,%edi
  800e86:	eb f0                	jmp    800e78 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e93:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e96:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e9a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea1:	00 
  800ea2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800ea5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800ea8:	89 04 24             	mov    %eax,(%esp)
  800eab:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eaf:	e8 1c 0c 00 00       	call   801ad0 <__umoddi3>
  800eb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eb8:	0f be 80 63 1d 80 00 	movsbl 0x801d63(%eax),%eax
  800ebf:	89 04 24             	mov    %eax,(%esp)
  800ec2:	ff 55 08             	call   *0x8(%ebp)
  800ec5:	e9 d6 fe ff ff       	jmp    800da0 <vprintfmt+0x514>
  800eca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ecd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ed5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ed8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800edc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee3:	00 
  800ee4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800ee7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800eea:	89 04 24             	mov    %eax,(%esp)
  800eed:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef1:	e8 da 0b 00 00       	call   801ad0 <__umoddi3>
  800ef6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efa:	0f be 80 63 1d 80 00 	movsbl 0x801d63(%eax),%eax
  800f01:	89 04 24             	mov    %eax,(%esp)
  800f04:	ff 55 08             	call   *0x8(%ebp)
  800f07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f0a:	e9 ac f9 ff ff       	jmp    8008bb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800f0f:	83 c4 6c             	add    $0x6c,%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 28             	sub    $0x28,%esp
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800f23:	85 c0                	test   %eax,%eax
  800f25:	74 04                	je     800f2b <vsnprintf+0x14>
  800f27:	85 d2                	test   %edx,%edx
  800f29:	7f 07                	jg     800f32 <vsnprintf+0x1b>
  800f2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f30:	eb 3b                	jmp    800f6d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f35:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800f39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f43:	8b 45 14             	mov    0x14(%ebp),%eax
  800f46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f51:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f58:	c7 04 24 6f 08 80 00 	movl   $0x80086f,(%esp)
  800f5f:	e8 28 f9 ff ff       	call   80088c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f67:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800f75:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800f78:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	89 04 24             	mov    %eax,(%esp)
  800f90:	e8 82 ff ff ff       	call   800f17 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f95:	c9                   	leave  
  800f96:	c3                   	ret    

00800f97 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800f9d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800fa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fa4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	89 04 24             	mov    %eax,(%esp)
  800fb8:	e8 cf f8 ff ff       	call   80088c <vprintfmt>
	va_end(ap);
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    
	...

00800fc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	80 3a 00             	cmpb   $0x0,(%edx)
  800fce:	74 09                	je     800fd9 <strlen+0x19>
		n++;
  800fd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fd7:	75 f7                	jne    800fd0 <strlen+0x10>
		n++;
	return n;
}
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	53                   	push   %ebx
  800fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fe5:	85 c9                	test   %ecx,%ecx
  800fe7:	74 19                	je     801002 <strnlen+0x27>
  800fe9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800fec:	74 14                	je     801002 <strnlen+0x27>
  800fee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ff3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ff6:	39 c8                	cmp    %ecx,%eax
  800ff8:	74 0d                	je     801007 <strnlen+0x2c>
  800ffa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800ffe:	75 f3                	jne    800ff3 <strnlen+0x18>
  801000:	eb 05                	jmp    801007 <strnlen+0x2c>
  801002:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801007:	5b                   	pop    %ebx
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	53                   	push   %ebx
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
  801011:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801014:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801019:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80101d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801020:	83 c2 01             	add    $0x1,%edx
  801023:	84 c9                	test   %cl,%cl
  801025:	75 f2                	jne    801019 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801027:	5b                   	pop    %ebx
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	53                   	push   %ebx
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801034:	89 1c 24             	mov    %ebx,(%esp)
  801037:	e8 84 ff ff ff       	call   800fc0 <strlen>
	strcpy(dst + len, src);
  80103c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801043:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801046:	89 04 24             	mov    %eax,(%esp)
  801049:	e8 bc ff ff ff       	call   80100a <strcpy>
	return dst;
}
  80104e:	89 d8                	mov    %ebx,%eax
  801050:	83 c4 08             	add    $0x8,%esp
  801053:	5b                   	pop    %ebx
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	8b 45 08             	mov    0x8(%ebp),%eax
  80105e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801061:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801064:	85 f6                	test   %esi,%esi
  801066:	74 18                	je     801080 <strncpy+0x2a>
  801068:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80106d:	0f b6 1a             	movzbl (%edx),%ebx
  801070:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801073:	80 3a 01             	cmpb   $0x1,(%edx)
  801076:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801079:	83 c1 01             	add    $0x1,%ecx
  80107c:	39 ce                	cmp    %ecx,%esi
  80107e:	77 ed                	ja     80106d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	8b 75 08             	mov    0x8(%ebp),%esi
  80108c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801092:	89 f0                	mov    %esi,%eax
  801094:	85 c9                	test   %ecx,%ecx
  801096:	74 27                	je     8010bf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801098:	83 e9 01             	sub    $0x1,%ecx
  80109b:	74 1d                	je     8010ba <strlcpy+0x36>
  80109d:	0f b6 1a             	movzbl (%edx),%ebx
  8010a0:	84 db                	test   %bl,%bl
  8010a2:	74 16                	je     8010ba <strlcpy+0x36>
			*dst++ = *src++;
  8010a4:	88 18                	mov    %bl,(%eax)
  8010a6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8010a9:	83 e9 01             	sub    $0x1,%ecx
  8010ac:	74 0e                	je     8010bc <strlcpy+0x38>
			*dst++ = *src++;
  8010ae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8010b1:	0f b6 1a             	movzbl (%edx),%ebx
  8010b4:	84 db                	test   %bl,%bl
  8010b6:	75 ec                	jne    8010a4 <strlcpy+0x20>
  8010b8:	eb 02                	jmp    8010bc <strlcpy+0x38>
  8010ba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8010bc:	c6 00 00             	movb   $0x0,(%eax)
  8010bf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8010ce:	0f b6 01             	movzbl (%ecx),%eax
  8010d1:	84 c0                	test   %al,%al
  8010d3:	74 15                	je     8010ea <strcmp+0x25>
  8010d5:	3a 02                	cmp    (%edx),%al
  8010d7:	75 11                	jne    8010ea <strcmp+0x25>
		p++, q++;
  8010d9:	83 c1 01             	add    $0x1,%ecx
  8010dc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8010df:	0f b6 01             	movzbl (%ecx),%eax
  8010e2:	84 c0                	test   %al,%al
  8010e4:	74 04                	je     8010ea <strcmp+0x25>
  8010e6:	3a 02                	cmp    (%edx),%al
  8010e8:	74 ef                	je     8010d9 <strcmp+0x14>
  8010ea:	0f b6 c0             	movzbl %al,%eax
  8010ed:	0f b6 12             	movzbl (%edx),%edx
  8010f0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	53                   	push   %ebx
  8010f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801101:	85 c0                	test   %eax,%eax
  801103:	74 23                	je     801128 <strncmp+0x34>
  801105:	0f b6 1a             	movzbl (%edx),%ebx
  801108:	84 db                	test   %bl,%bl
  80110a:	74 25                	je     801131 <strncmp+0x3d>
  80110c:	3a 19                	cmp    (%ecx),%bl
  80110e:	75 21                	jne    801131 <strncmp+0x3d>
  801110:	83 e8 01             	sub    $0x1,%eax
  801113:	74 13                	je     801128 <strncmp+0x34>
		n--, p++, q++;
  801115:	83 c2 01             	add    $0x1,%edx
  801118:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80111b:	0f b6 1a             	movzbl (%edx),%ebx
  80111e:	84 db                	test   %bl,%bl
  801120:	74 0f                	je     801131 <strncmp+0x3d>
  801122:	3a 19                	cmp    (%ecx),%bl
  801124:	74 ea                	je     801110 <strncmp+0x1c>
  801126:	eb 09                	jmp    801131 <strncmp+0x3d>
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80112d:	5b                   	pop    %ebx
  80112e:	5d                   	pop    %ebp
  80112f:	90                   	nop
  801130:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801131:	0f b6 02             	movzbl (%edx),%eax
  801134:	0f b6 11             	movzbl (%ecx),%edx
  801137:	29 d0                	sub    %edx,%eax
  801139:	eb f2                	jmp    80112d <strncmp+0x39>

0080113b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801145:	0f b6 10             	movzbl (%eax),%edx
  801148:	84 d2                	test   %dl,%dl
  80114a:	74 18                	je     801164 <strchr+0x29>
		if (*s == c)
  80114c:	38 ca                	cmp    %cl,%dl
  80114e:	75 0a                	jne    80115a <strchr+0x1f>
  801150:	eb 17                	jmp    801169 <strchr+0x2e>
  801152:	38 ca                	cmp    %cl,%dl
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	74 0f                	je     801169 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80115a:	83 c0 01             	add    $0x1,%eax
  80115d:	0f b6 10             	movzbl (%eax),%edx
  801160:	84 d2                	test   %dl,%dl
  801162:	75 ee                	jne    801152 <strchr+0x17>
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	8b 45 08             	mov    0x8(%ebp),%eax
  801171:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801175:	0f b6 10             	movzbl (%eax),%edx
  801178:	84 d2                	test   %dl,%dl
  80117a:	74 18                	je     801194 <strfind+0x29>
		if (*s == c)
  80117c:	38 ca                	cmp    %cl,%dl
  80117e:	75 0a                	jne    80118a <strfind+0x1f>
  801180:	eb 12                	jmp    801194 <strfind+0x29>
  801182:	38 ca                	cmp    %cl,%dl
  801184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801188:	74 0a                	je     801194 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80118a:	83 c0 01             	add    $0x1,%eax
  80118d:	0f b6 10             	movzbl (%eax),%edx
  801190:	84 d2                	test   %dl,%dl
  801192:	75 ee                	jne    801182 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	89 1c 24             	mov    %ebx,(%esp)
  80119f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8011b0:	85 c9                	test   %ecx,%ecx
  8011b2:	74 30                	je     8011e4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011ba:	75 25                	jne    8011e1 <memset+0x4b>
  8011bc:	f6 c1 03             	test   $0x3,%cl
  8011bf:	75 20                	jne    8011e1 <memset+0x4b>
		c &= 0xFF;
  8011c1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8011c4:	89 d3                	mov    %edx,%ebx
  8011c6:	c1 e3 08             	shl    $0x8,%ebx
  8011c9:	89 d6                	mov    %edx,%esi
  8011cb:	c1 e6 18             	shl    $0x18,%esi
  8011ce:	89 d0                	mov    %edx,%eax
  8011d0:	c1 e0 10             	shl    $0x10,%eax
  8011d3:	09 f0                	or     %esi,%eax
  8011d5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8011d7:	09 d8                	or     %ebx,%eax
  8011d9:	c1 e9 02             	shr    $0x2,%ecx
  8011dc:	fc                   	cld    
  8011dd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011df:	eb 03                	jmp    8011e4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011e1:	fc                   	cld    
  8011e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011e4:	89 f8                	mov    %edi,%eax
  8011e6:	8b 1c 24             	mov    (%esp),%ebx
  8011e9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011ed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011f1:	89 ec                	mov    %ebp,%esp
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	89 34 24             	mov    %esi,(%esp)
  8011fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801202:	8b 45 08             	mov    0x8(%ebp),%eax
  801205:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801208:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80120b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80120d:	39 c6                	cmp    %eax,%esi
  80120f:	73 35                	jae    801246 <memmove+0x51>
  801211:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801214:	39 d0                	cmp    %edx,%eax
  801216:	73 2e                	jae    801246 <memmove+0x51>
		s += n;
		d += n;
  801218:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80121a:	f6 c2 03             	test   $0x3,%dl
  80121d:	75 1b                	jne    80123a <memmove+0x45>
  80121f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801225:	75 13                	jne    80123a <memmove+0x45>
  801227:	f6 c1 03             	test   $0x3,%cl
  80122a:	75 0e                	jne    80123a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80122c:	83 ef 04             	sub    $0x4,%edi
  80122f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801232:	c1 e9 02             	shr    $0x2,%ecx
  801235:	fd                   	std    
  801236:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801238:	eb 09                	jmp    801243 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80123a:	83 ef 01             	sub    $0x1,%edi
  80123d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801240:	fd                   	std    
  801241:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801243:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801244:	eb 20                	jmp    801266 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801246:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80124c:	75 15                	jne    801263 <memmove+0x6e>
  80124e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801254:	75 0d                	jne    801263 <memmove+0x6e>
  801256:	f6 c1 03             	test   $0x3,%cl
  801259:	75 08                	jne    801263 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80125b:	c1 e9 02             	shr    $0x2,%ecx
  80125e:	fc                   	cld    
  80125f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801261:	eb 03                	jmp    801266 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801263:	fc                   	cld    
  801264:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801266:	8b 34 24             	mov    (%esp),%esi
  801269:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80126d:	89 ec                	mov    %ebp,%esp
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801277:	8b 45 10             	mov    0x10(%ebp),%eax
  80127a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801281:	89 44 24 04          	mov    %eax,0x4(%esp)
  801285:	8b 45 08             	mov    0x8(%ebp),%eax
  801288:	89 04 24             	mov    %eax,(%esp)
  80128b:	e8 65 ff ff ff       	call   8011f5 <memmove>
}
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	8b 75 08             	mov    0x8(%ebp),%esi
  80129b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80129e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012a1:	85 c9                	test   %ecx,%ecx
  8012a3:	74 36                	je     8012db <memcmp+0x49>
		if (*s1 != *s2)
  8012a5:	0f b6 06             	movzbl (%esi),%eax
  8012a8:	0f b6 1f             	movzbl (%edi),%ebx
  8012ab:	38 d8                	cmp    %bl,%al
  8012ad:	74 20                	je     8012cf <memcmp+0x3d>
  8012af:	eb 14                	jmp    8012c5 <memcmp+0x33>
  8012b1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8012b6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8012bb:	83 c2 01             	add    $0x1,%edx
  8012be:	83 e9 01             	sub    $0x1,%ecx
  8012c1:	38 d8                	cmp    %bl,%al
  8012c3:	74 12                	je     8012d7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8012c5:	0f b6 c0             	movzbl %al,%eax
  8012c8:	0f b6 db             	movzbl %bl,%ebx
  8012cb:	29 d8                	sub    %ebx,%eax
  8012cd:	eb 11                	jmp    8012e0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012cf:	83 e9 01             	sub    $0x1,%ecx
  8012d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d7:	85 c9                	test   %ecx,%ecx
  8012d9:	75 d6                	jne    8012b1 <memcmp+0x1f>
  8012db:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8012e0:	5b                   	pop    %ebx
  8012e1:	5e                   	pop    %esi
  8012e2:	5f                   	pop    %edi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012f0:	39 d0                	cmp    %edx,%eax
  8012f2:	73 15                	jae    801309 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8012f8:	38 08                	cmp    %cl,(%eax)
  8012fa:	75 06                	jne    801302 <memfind+0x1d>
  8012fc:	eb 0b                	jmp    801309 <memfind+0x24>
  8012fe:	38 08                	cmp    %cl,(%eax)
  801300:	74 07                	je     801309 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801302:	83 c0 01             	add    $0x1,%eax
  801305:	39 c2                	cmp    %eax,%edx
  801307:	77 f5                	ja     8012fe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	57                   	push   %edi
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
  801311:	83 ec 04             	sub    $0x4,%esp
  801314:	8b 55 08             	mov    0x8(%ebp),%edx
  801317:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80131a:	0f b6 02             	movzbl (%edx),%eax
  80131d:	3c 20                	cmp    $0x20,%al
  80131f:	74 04                	je     801325 <strtol+0x1a>
  801321:	3c 09                	cmp    $0x9,%al
  801323:	75 0e                	jne    801333 <strtol+0x28>
		s++;
  801325:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801328:	0f b6 02             	movzbl (%edx),%eax
  80132b:	3c 20                	cmp    $0x20,%al
  80132d:	74 f6                	je     801325 <strtol+0x1a>
  80132f:	3c 09                	cmp    $0x9,%al
  801331:	74 f2                	je     801325 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801333:	3c 2b                	cmp    $0x2b,%al
  801335:	75 0c                	jne    801343 <strtol+0x38>
		s++;
  801337:	83 c2 01             	add    $0x1,%edx
  80133a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801341:	eb 15                	jmp    801358 <strtol+0x4d>
	else if (*s == '-')
  801343:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80134a:	3c 2d                	cmp    $0x2d,%al
  80134c:	75 0a                	jne    801358 <strtol+0x4d>
		s++, neg = 1;
  80134e:	83 c2 01             	add    $0x1,%edx
  801351:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801358:	85 db                	test   %ebx,%ebx
  80135a:	0f 94 c0             	sete   %al
  80135d:	74 05                	je     801364 <strtol+0x59>
  80135f:	83 fb 10             	cmp    $0x10,%ebx
  801362:	75 18                	jne    80137c <strtol+0x71>
  801364:	80 3a 30             	cmpb   $0x30,(%edx)
  801367:	75 13                	jne    80137c <strtol+0x71>
  801369:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80136d:	8d 76 00             	lea    0x0(%esi),%esi
  801370:	75 0a                	jne    80137c <strtol+0x71>
		s += 2, base = 16;
  801372:	83 c2 02             	add    $0x2,%edx
  801375:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80137a:	eb 15                	jmp    801391 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80137c:	84 c0                	test   %al,%al
  80137e:	66 90                	xchg   %ax,%ax
  801380:	74 0f                	je     801391 <strtol+0x86>
  801382:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801387:	80 3a 30             	cmpb   $0x30,(%edx)
  80138a:	75 05                	jne    801391 <strtol+0x86>
		s++, base = 8;
  80138c:	83 c2 01             	add    $0x1,%edx
  80138f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801391:	b8 00 00 00 00       	mov    $0x0,%eax
  801396:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801398:	0f b6 0a             	movzbl (%edx),%ecx
  80139b:	89 cf                	mov    %ecx,%edi
  80139d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8013a0:	80 fb 09             	cmp    $0x9,%bl
  8013a3:	77 08                	ja     8013ad <strtol+0xa2>
			dig = *s - '0';
  8013a5:	0f be c9             	movsbl %cl,%ecx
  8013a8:	83 e9 30             	sub    $0x30,%ecx
  8013ab:	eb 1e                	jmp    8013cb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8013ad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8013b0:	80 fb 19             	cmp    $0x19,%bl
  8013b3:	77 08                	ja     8013bd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8013b5:	0f be c9             	movsbl %cl,%ecx
  8013b8:	83 e9 57             	sub    $0x57,%ecx
  8013bb:	eb 0e                	jmp    8013cb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8013bd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8013c0:	80 fb 19             	cmp    $0x19,%bl
  8013c3:	77 15                	ja     8013da <strtol+0xcf>
			dig = *s - 'A' + 10;
  8013c5:	0f be c9             	movsbl %cl,%ecx
  8013c8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8013cb:	39 f1                	cmp    %esi,%ecx
  8013cd:	7d 0b                	jge    8013da <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8013cf:	83 c2 01             	add    $0x1,%edx
  8013d2:	0f af c6             	imul   %esi,%eax
  8013d5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8013d8:	eb be                	jmp    801398 <strtol+0x8d>
  8013da:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8013dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013e0:	74 05                	je     8013e7 <strtol+0xdc>
		*endptr = (char *) s;
  8013e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013e5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8013e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013eb:	74 04                	je     8013f1 <strtol+0xe6>
  8013ed:	89 c8                	mov    %ecx,%eax
  8013ef:	f7 d8                	neg    %eax
}
  8013f1:	83 c4 04             	add    $0x4,%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5e                   	pop    %esi
  8013f6:	5f                   	pop    %edi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    
  8013f9:	00 00                	add    %al,(%eax)
	...

008013fc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	89 1c 24             	mov    %ebx,(%esp)
  801405:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801409:	ba 00 00 00 00       	mov    $0x0,%edx
  80140e:	b8 01 00 00 00       	mov    $0x1,%eax
  801413:	89 d1                	mov    %edx,%ecx
  801415:	89 d3                	mov    %edx,%ebx
  801417:	89 d7                	mov    %edx,%edi
  801419:	51                   	push   %ecx
  80141a:	52                   	push   %edx
  80141b:	53                   	push   %ebx
  80141c:	54                   	push   %esp
  80141d:	55                   	push   %ebp
  80141e:	56                   	push   %esi
  80141f:	57                   	push   %edi
  801420:	54                   	push   %esp
  801421:	5d                   	pop    %ebp
  801422:	8d 35 2a 14 80 00    	lea    0x80142a,%esi
  801428:	0f 34                	sysenter 
  80142a:	5f                   	pop    %edi
  80142b:	5e                   	pop    %esi
  80142c:	5d                   	pop    %ebp
  80142d:	5c                   	pop    %esp
  80142e:	5b                   	pop    %ebx
  80142f:	5a                   	pop    %edx
  801430:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801431:	8b 1c 24             	mov    (%esp),%ebx
  801434:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801438:	89 ec                	mov    %ebp,%esp
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	89 1c 24             	mov    %ebx,(%esp)
  801445:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801449:	b8 00 00 00 00       	mov    $0x0,%eax
  80144e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801451:	8b 55 08             	mov    0x8(%ebp),%edx
  801454:	89 c3                	mov    %eax,%ebx
  801456:	89 c7                	mov    %eax,%edi
  801458:	51                   	push   %ecx
  801459:	52                   	push   %edx
  80145a:	53                   	push   %ebx
  80145b:	54                   	push   %esp
  80145c:	55                   	push   %ebp
  80145d:	56                   	push   %esi
  80145e:	57                   	push   %edi
  80145f:	54                   	push   %esp
  801460:	5d                   	pop    %ebp
  801461:	8d 35 69 14 80 00    	lea    0x801469,%esi
  801467:	0f 34                	sysenter 
  801469:	5f                   	pop    %edi
  80146a:	5e                   	pop    %esi
  80146b:	5d                   	pop    %ebp
  80146c:	5c                   	pop    %esp
  80146d:	5b                   	pop    %ebx
  80146e:	5a                   	pop    %edx
  80146f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801470:	8b 1c 24             	mov    (%esp),%ebx
  801473:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801477:	89 ec                	mov    %ebp,%esp
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 28             	sub    $0x28,%esp
  801481:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801484:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801487:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801491:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801494:	8b 55 08             	mov    0x8(%ebp),%edx
  801497:	89 df                	mov    %ebx,%edi
  801499:	51                   	push   %ecx
  80149a:	52                   	push   %edx
  80149b:	53                   	push   %ebx
  80149c:	54                   	push   %esp
  80149d:	55                   	push   %ebp
  80149e:	56                   	push   %esi
  80149f:	57                   	push   %edi
  8014a0:	54                   	push   %esp
  8014a1:	5d                   	pop    %ebp
  8014a2:	8d 35 aa 14 80 00    	lea    0x8014aa,%esi
  8014a8:	0f 34                	sysenter 
  8014aa:	5f                   	pop    %edi
  8014ab:	5e                   	pop    %esi
  8014ac:	5d                   	pop    %ebp
  8014ad:	5c                   	pop    %esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5a                   	pop    %edx
  8014b0:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	7e 28                	jle    8014dd <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b9:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 08 24 20 80 	movl   $0x802024,0x8(%esp)
  8014c8:	00 
  8014c9:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014d0:	00 
  8014d1:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  8014d8:	e8 2f f1 ff ff       	call   80060c <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8014dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014e3:	89 ec                	mov    %ebp,%esp
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    

008014e7 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	89 1c 24             	mov    %ebx,(%esp)
  8014f0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8014fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801501:	89 cb                	mov    %ecx,%ebx
  801503:	89 cf                	mov    %ecx,%edi
  801505:	51                   	push   %ecx
  801506:	52                   	push   %edx
  801507:	53                   	push   %ebx
  801508:	54                   	push   %esp
  801509:	55                   	push   %ebp
  80150a:	56                   	push   %esi
  80150b:	57                   	push   %edi
  80150c:	54                   	push   %esp
  80150d:	5d                   	pop    %ebp
  80150e:	8d 35 16 15 80 00    	lea    0x801516,%esi
  801514:	0f 34                	sysenter 
  801516:	5f                   	pop    %edi
  801517:	5e                   	pop    %esi
  801518:	5d                   	pop    %ebp
  801519:	5c                   	pop    %esp
  80151a:	5b                   	pop    %ebx
  80151b:	5a                   	pop    %edx
  80151c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80151d:	8b 1c 24             	mov    (%esp),%ebx
  801520:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801524:	89 ec                	mov    %ebp,%esp
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    

00801528 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	83 ec 28             	sub    $0x28,%esp
  80152e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801531:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801534:	b9 00 00 00 00       	mov    $0x0,%ecx
  801539:	b8 0d 00 00 00       	mov    $0xd,%eax
  80153e:	8b 55 08             	mov    0x8(%ebp),%edx
  801541:	89 cb                	mov    %ecx,%ebx
  801543:	89 cf                	mov    %ecx,%edi
  801545:	51                   	push   %ecx
  801546:	52                   	push   %edx
  801547:	53                   	push   %ebx
  801548:	54                   	push   %esp
  801549:	55                   	push   %ebp
  80154a:	56                   	push   %esi
  80154b:	57                   	push   %edi
  80154c:	54                   	push   %esp
  80154d:	5d                   	pop    %ebp
  80154e:	8d 35 56 15 80 00    	lea    0x801556,%esi
  801554:	0f 34                	sysenter 
  801556:	5f                   	pop    %edi
  801557:	5e                   	pop    %esi
  801558:	5d                   	pop    %ebp
  801559:	5c                   	pop    %esp
  80155a:	5b                   	pop    %ebx
  80155b:	5a                   	pop    %edx
  80155c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80155d:	85 c0                	test   %eax,%eax
  80155f:	7e 28                	jle    801589 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801561:	89 44 24 10          	mov    %eax,0x10(%esp)
  801565:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80156c:	00 
  80156d:	c7 44 24 08 24 20 80 	movl   $0x802024,0x8(%esp)
  801574:	00 
  801575:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80157c:	00 
  80157d:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  801584:	e8 83 f0 ff ff       	call   80060c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801589:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80158c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80158f:	89 ec                	mov    %ebp,%esp
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	89 1c 24             	mov    %ebx,(%esp)
  80159c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015a0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8015a5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b1:	51                   	push   %ecx
  8015b2:	52                   	push   %edx
  8015b3:	53                   	push   %ebx
  8015b4:	54                   	push   %esp
  8015b5:	55                   	push   %ebp
  8015b6:	56                   	push   %esi
  8015b7:	57                   	push   %edi
  8015b8:	54                   	push   %esp
  8015b9:	5d                   	pop    %ebp
  8015ba:	8d 35 c2 15 80 00    	lea    0x8015c2,%esi
  8015c0:	0f 34                	sysenter 
  8015c2:	5f                   	pop    %edi
  8015c3:	5e                   	pop    %esi
  8015c4:	5d                   	pop    %ebp
  8015c5:	5c                   	pop    %esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5a                   	pop    %edx
  8015c8:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8015c9:	8b 1c 24             	mov    (%esp),%ebx
  8015cc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015d0:	89 ec                	mov    %ebp,%esp
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    

008015d4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 28             	sub    $0x28,%esp
  8015da:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015dd:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f0:	89 df                	mov    %ebx,%edi
  8015f2:	51                   	push   %ecx
  8015f3:	52                   	push   %edx
  8015f4:	53                   	push   %ebx
  8015f5:	54                   	push   %esp
  8015f6:	55                   	push   %ebp
  8015f7:	56                   	push   %esi
  8015f8:	57                   	push   %edi
  8015f9:	54                   	push   %esp
  8015fa:	5d                   	pop    %ebp
  8015fb:	8d 35 03 16 80 00    	lea    0x801603,%esi
  801601:	0f 34                	sysenter 
  801603:	5f                   	pop    %edi
  801604:	5e                   	pop    %esi
  801605:	5d                   	pop    %ebp
  801606:	5c                   	pop    %esp
  801607:	5b                   	pop    %ebx
  801608:	5a                   	pop    %edx
  801609:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80160a:	85 c0                	test   %eax,%eax
  80160c:	7e 28                	jle    801636 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80160e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801612:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801619:	00 
  80161a:	c7 44 24 08 24 20 80 	movl   $0x802024,0x8(%esp)
  801621:	00 
  801622:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801629:	00 
  80162a:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  801631:	e8 d6 ef ff ff       	call   80060c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801636:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801639:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80163c:	89 ec                	mov    %ebp,%esp
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	83 ec 28             	sub    $0x28,%esp
  801646:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801649:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80164c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801651:	b8 09 00 00 00       	mov    $0x9,%eax
  801656:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801659:	8b 55 08             	mov    0x8(%ebp),%edx
  80165c:	89 df                	mov    %ebx,%edi
  80165e:	51                   	push   %ecx
  80165f:	52                   	push   %edx
  801660:	53                   	push   %ebx
  801661:	54                   	push   %esp
  801662:	55                   	push   %ebp
  801663:	56                   	push   %esi
  801664:	57                   	push   %edi
  801665:	54                   	push   %esp
  801666:	5d                   	pop    %ebp
  801667:	8d 35 6f 16 80 00    	lea    0x80166f,%esi
  80166d:	0f 34                	sysenter 
  80166f:	5f                   	pop    %edi
  801670:	5e                   	pop    %esi
  801671:	5d                   	pop    %ebp
  801672:	5c                   	pop    %esp
  801673:	5b                   	pop    %ebx
  801674:	5a                   	pop    %edx
  801675:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801676:	85 c0                	test   %eax,%eax
  801678:	7e 28                	jle    8016a2 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80167a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80167e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801685:	00 
  801686:	c7 44 24 08 24 20 80 	movl   $0x802024,0x8(%esp)
  80168d:	00 
  80168e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801695:	00 
  801696:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  80169d:	e8 6a ef ff ff       	call   80060c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016a2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016a8:	89 ec                	mov    %ebp,%esp
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 28             	sub    $0x28,%esp
  8016b2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016b5:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8016b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016bd:	b8 07 00 00 00       	mov    $0x7,%eax
  8016c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c8:	89 df                	mov    %ebx,%edi
  8016ca:	51                   	push   %ecx
  8016cb:	52                   	push   %edx
  8016cc:	53                   	push   %ebx
  8016cd:	54                   	push   %esp
  8016ce:	55                   	push   %ebp
  8016cf:	56                   	push   %esi
  8016d0:	57                   	push   %edi
  8016d1:	54                   	push   %esp
  8016d2:	5d                   	pop    %ebp
  8016d3:	8d 35 db 16 80 00    	lea    0x8016db,%esi
  8016d9:	0f 34                	sysenter 
  8016db:	5f                   	pop    %edi
  8016dc:	5e                   	pop    %esi
  8016dd:	5d                   	pop    %ebp
  8016de:	5c                   	pop    %esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5a                   	pop    %edx
  8016e1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	7e 28                	jle    80170e <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016f1:	00 
  8016f2:	c7 44 24 08 24 20 80 	movl   $0x802024,0x8(%esp)
  8016f9:	00 
  8016fa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801701:	00 
  801702:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  801709:	e8 fe ee ff ff       	call   80060c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80170e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801711:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801714:	89 ec                	mov    %ebp,%esp
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 28             	sub    $0x28,%esp
  80171e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801721:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801724:	8b 7d 18             	mov    0x18(%ebp),%edi
  801727:	0b 7d 14             	or     0x14(%ebp),%edi
  80172a:	b8 06 00 00 00       	mov    $0x6,%eax
  80172f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801732:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801735:	8b 55 08             	mov    0x8(%ebp),%edx
  801738:	51                   	push   %ecx
  801739:	52                   	push   %edx
  80173a:	53                   	push   %ebx
  80173b:	54                   	push   %esp
  80173c:	55                   	push   %ebp
  80173d:	56                   	push   %esi
  80173e:	57                   	push   %edi
  80173f:	54                   	push   %esp
  801740:	5d                   	pop    %ebp
  801741:	8d 35 49 17 80 00    	lea    0x801749,%esi
  801747:	0f 34                	sysenter 
  801749:	5f                   	pop    %edi
  80174a:	5e                   	pop    %esi
  80174b:	5d                   	pop    %ebp
  80174c:	5c                   	pop    %esp
  80174d:	5b                   	pop    %ebx
  80174e:	5a                   	pop    %edx
  80174f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801750:	85 c0                	test   %eax,%eax
  801752:	7e 28                	jle    80177c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801754:	89 44 24 10          	mov    %eax,0x10(%esp)
  801758:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80175f:	00 
  801760:	c7 44 24 08 24 20 80 	movl   $0x802024,0x8(%esp)
  801767:	00 
  801768:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80176f:	00 
  801770:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  801777:	e8 90 ee ff ff       	call   80060c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80177c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80177f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801782:	89 ec                	mov    %ebp,%esp
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	83 ec 28             	sub    $0x28,%esp
  80178c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80178f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801792:	bf 00 00 00 00       	mov    $0x0,%edi
  801797:	b8 05 00 00 00       	mov    $0x5,%eax
  80179c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80179f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a5:	51                   	push   %ecx
  8017a6:	52                   	push   %edx
  8017a7:	53                   	push   %ebx
  8017a8:	54                   	push   %esp
  8017a9:	55                   	push   %ebp
  8017aa:	56                   	push   %esi
  8017ab:	57                   	push   %edi
  8017ac:	54                   	push   %esp
  8017ad:	5d                   	pop    %ebp
  8017ae:	8d 35 b6 17 80 00    	lea    0x8017b6,%esi
  8017b4:	0f 34                	sysenter 
  8017b6:	5f                   	pop    %edi
  8017b7:	5e                   	pop    %esi
  8017b8:	5d                   	pop    %ebp
  8017b9:	5c                   	pop    %esp
  8017ba:	5b                   	pop    %ebx
  8017bb:	5a                   	pop    %edx
  8017bc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	7e 28                	jle    8017e9 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017c5:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8017cc:	00 
  8017cd:	c7 44 24 08 24 20 80 	movl   $0x802024,0x8(%esp)
  8017d4:	00 
  8017d5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8017dc:	00 
  8017dd:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  8017e4:	e8 23 ee ff ff       	call   80060c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8017e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017ef:	89 ec                	mov    %ebp,%esp
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	89 1c 24             	mov    %ebx,(%esp)
  8017fc:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801800:	ba 00 00 00 00       	mov    $0x0,%edx
  801805:	b8 0b 00 00 00       	mov    $0xb,%eax
  80180a:	89 d1                	mov    %edx,%ecx
  80180c:	89 d3                	mov    %edx,%ebx
  80180e:	89 d7                	mov    %edx,%edi
  801810:	51                   	push   %ecx
  801811:	52                   	push   %edx
  801812:	53                   	push   %ebx
  801813:	54                   	push   %esp
  801814:	55                   	push   %ebp
  801815:	56                   	push   %esi
  801816:	57                   	push   %edi
  801817:	54                   	push   %esp
  801818:	5d                   	pop    %ebp
  801819:	8d 35 21 18 80 00    	lea    0x801821,%esi
  80181f:	0f 34                	sysenter 
  801821:	5f                   	pop    %edi
  801822:	5e                   	pop    %esi
  801823:	5d                   	pop    %ebp
  801824:	5c                   	pop    %esp
  801825:	5b                   	pop    %ebx
  801826:	5a                   	pop    %edx
  801827:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801828:	8b 1c 24             	mov    (%esp),%ebx
  80182b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80182f:	89 ec                	mov    %ebp,%esp
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	89 1c 24             	mov    %ebx,(%esp)
  80183c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801840:	bb 00 00 00 00       	mov    $0x0,%ebx
  801845:	b8 04 00 00 00       	mov    $0x4,%eax
  80184a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184d:	8b 55 08             	mov    0x8(%ebp),%edx
  801850:	89 df                	mov    %ebx,%edi
  801852:	51                   	push   %ecx
  801853:	52                   	push   %edx
  801854:	53                   	push   %ebx
  801855:	54                   	push   %esp
  801856:	55                   	push   %ebp
  801857:	56                   	push   %esi
  801858:	57                   	push   %edi
  801859:	54                   	push   %esp
  80185a:	5d                   	pop    %ebp
  80185b:	8d 35 63 18 80 00    	lea    0x801863,%esi
  801861:	0f 34                	sysenter 
  801863:	5f                   	pop    %edi
  801864:	5e                   	pop    %esi
  801865:	5d                   	pop    %ebp
  801866:	5c                   	pop    %esp
  801867:	5b                   	pop    %ebx
  801868:	5a                   	pop    %edx
  801869:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80186a:	8b 1c 24             	mov    (%esp),%ebx
  80186d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801871:	89 ec                	mov    %ebp,%esp
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	89 1c 24             	mov    %ebx,(%esp)
  80187e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801882:	ba 00 00 00 00       	mov    $0x0,%edx
  801887:	b8 02 00 00 00       	mov    $0x2,%eax
  80188c:	89 d1                	mov    %edx,%ecx
  80188e:	89 d3                	mov    %edx,%ebx
  801890:	89 d7                	mov    %edx,%edi
  801892:	51                   	push   %ecx
  801893:	52                   	push   %edx
  801894:	53                   	push   %ebx
  801895:	54                   	push   %esp
  801896:	55                   	push   %ebp
  801897:	56                   	push   %esi
  801898:	57                   	push   %edi
  801899:	54                   	push   %esp
  80189a:	5d                   	pop    %ebp
  80189b:	8d 35 a3 18 80 00    	lea    0x8018a3,%esi
  8018a1:	0f 34                	sysenter 
  8018a3:	5f                   	pop    %edi
  8018a4:	5e                   	pop    %esi
  8018a5:	5d                   	pop    %ebp
  8018a6:	5c                   	pop    %esp
  8018a7:	5b                   	pop    %ebx
  8018a8:	5a                   	pop    %edx
  8018a9:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8018aa:	8b 1c 24             	mov    (%esp),%ebx
  8018ad:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018b1:	89 ec                	mov    %ebp,%esp
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 28             	sub    $0x28,%esp
  8018bb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018be:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8018c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8018cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ce:	89 cb                	mov    %ecx,%ebx
  8018d0:	89 cf                	mov    %ecx,%edi
  8018d2:	51                   	push   %ecx
  8018d3:	52                   	push   %edx
  8018d4:	53                   	push   %ebx
  8018d5:	54                   	push   %esp
  8018d6:	55                   	push   %ebp
  8018d7:	56                   	push   %esi
  8018d8:	57                   	push   %edi
  8018d9:	54                   	push   %esp
  8018da:	5d                   	pop    %ebp
  8018db:	8d 35 e3 18 80 00    	lea    0x8018e3,%esi
  8018e1:	0f 34                	sysenter 
  8018e3:	5f                   	pop    %edi
  8018e4:	5e                   	pop    %esi
  8018e5:	5d                   	pop    %ebp
  8018e6:	5c                   	pop    %esp
  8018e7:	5b                   	pop    %ebx
  8018e8:	5a                   	pop    %edx
  8018e9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	7e 28                	jle    801916 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018f2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8018f9:	00 
  8018fa:	c7 44 24 08 24 20 80 	movl   $0x802024,0x8(%esp)
  801901:	00 
  801902:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801909:	00 
  80190a:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  801911:	e8 f6 ec ff ff       	call   80060c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801916:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801919:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80191c:	89 ec                	mov    %ebp,%esp
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801926:	83 3d d4 30 80 00 00 	cmpl   $0x0,0x8030d4
  80192d:	75 30                	jne    80195f <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80192f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801936:	00 
  801937:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80193e:	ee 
  80193f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801946:	e8 3b fe ff ff       	call   801786 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  80194b:	c7 44 24 04 6c 19 80 	movl   $0x80196c,0x4(%esp)
  801952:	00 
  801953:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195a:	e8 75 fc ff ff       	call   8015d4 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80195f:	8b 45 08             	mov    0x8(%ebp),%eax
  801962:	a3 d4 30 80 00       	mov    %eax,0x8030d4
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    
  801969:	00 00                	add    %al,(%eax)
	...

0080196c <_pgfault_upcall>:
  80196c:	54                   	push   %esp
  80196d:	a1 d4 30 80 00       	mov    0x8030d4,%eax
  801972:	ff d0                	call   *%eax
  801974:	83 c4 04             	add    $0x4,%esp
  801977:	8b 44 24 28          	mov    0x28(%esp),%eax
  80197b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80197f:	83 e9 04             	sub    $0x4,%ecx
  801982:	89 01                	mov    %eax,(%ecx)
  801984:	89 4c 24 30          	mov    %ecx,0x30(%esp)
  801988:	83 c4 08             	add    $0x8,%esp
  80198b:	61                   	popa   
  80198c:	83 c4 04             	add    $0x4,%esp
  80198f:	9d                   	popf   
  801990:	5c                   	pop    %esp
  801991:	c3                   	ret    
	...

008019a0 <__udivdi3>:
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	57                   	push   %edi
  8019a4:	56                   	push   %esi
  8019a5:	83 ec 10             	sub    $0x10,%esp
  8019a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8019ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8019b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8019b9:	75 35                	jne    8019f0 <__udivdi3+0x50>
  8019bb:	39 fe                	cmp    %edi,%esi
  8019bd:	77 61                	ja     801a20 <__udivdi3+0x80>
  8019bf:	85 f6                	test   %esi,%esi
  8019c1:	75 0b                	jne    8019ce <__udivdi3+0x2e>
  8019c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c8:	31 d2                	xor    %edx,%edx
  8019ca:	f7 f6                	div    %esi
  8019cc:	89 c6                	mov    %eax,%esi
  8019ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8019d1:	31 d2                	xor    %edx,%edx
  8019d3:	89 f8                	mov    %edi,%eax
  8019d5:	f7 f6                	div    %esi
  8019d7:	89 c7                	mov    %eax,%edi
  8019d9:	89 c8                	mov    %ecx,%eax
  8019db:	f7 f6                	div    %esi
  8019dd:	89 c1                	mov    %eax,%ecx
  8019df:	89 fa                	mov    %edi,%edx
  8019e1:	89 c8                	mov    %ecx,%eax
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	5e                   	pop    %esi
  8019e7:	5f                   	pop    %edi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    
  8019ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8019f0:	39 f8                	cmp    %edi,%eax
  8019f2:	77 1c                	ja     801a10 <__udivdi3+0x70>
  8019f4:	0f bd d0             	bsr    %eax,%edx
  8019f7:	83 f2 1f             	xor    $0x1f,%edx
  8019fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8019fd:	75 39                	jne    801a38 <__udivdi3+0x98>
  8019ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801a02:	0f 86 a0 00 00 00    	jbe    801aa8 <__udivdi3+0x108>
  801a08:	39 f8                	cmp    %edi,%eax
  801a0a:	0f 82 98 00 00 00    	jb     801aa8 <__udivdi3+0x108>
  801a10:	31 ff                	xor    %edi,%edi
  801a12:	31 c9                	xor    %ecx,%ecx
  801a14:	89 c8                	mov    %ecx,%eax
  801a16:	89 fa                	mov    %edi,%edx
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	5e                   	pop    %esi
  801a1c:	5f                   	pop    %edi
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    
  801a1f:	90                   	nop
  801a20:	89 d1                	mov    %edx,%ecx
  801a22:	89 fa                	mov    %edi,%edx
  801a24:	89 c8                	mov    %ecx,%eax
  801a26:	31 ff                	xor    %edi,%edi
  801a28:	f7 f6                	div    %esi
  801a2a:	89 c1                	mov    %eax,%ecx
  801a2c:	89 fa                	mov    %edi,%edx
  801a2e:	89 c8                	mov    %ecx,%eax
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	5e                   	pop    %esi
  801a34:	5f                   	pop    %edi
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    
  801a37:	90                   	nop
  801a38:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a3c:	89 f2                	mov    %esi,%edx
  801a3e:	d3 e0                	shl    %cl,%eax
  801a40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a43:	b8 20 00 00 00       	mov    $0x20,%eax
  801a48:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801a4b:	89 c1                	mov    %eax,%ecx
  801a4d:	d3 ea                	shr    %cl,%edx
  801a4f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a53:	0b 55 ec             	or     -0x14(%ebp),%edx
  801a56:	d3 e6                	shl    %cl,%esi
  801a58:	89 c1                	mov    %eax,%ecx
  801a5a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801a5d:	89 fe                	mov    %edi,%esi
  801a5f:	d3 ee                	shr    %cl,%esi
  801a61:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a65:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a6b:	d3 e7                	shl    %cl,%edi
  801a6d:	89 c1                	mov    %eax,%ecx
  801a6f:	d3 ea                	shr    %cl,%edx
  801a71:	09 d7                	or     %edx,%edi
  801a73:	89 f2                	mov    %esi,%edx
  801a75:	89 f8                	mov    %edi,%eax
  801a77:	f7 75 ec             	divl   -0x14(%ebp)
  801a7a:	89 d6                	mov    %edx,%esi
  801a7c:	89 c7                	mov    %eax,%edi
  801a7e:	f7 65 e8             	mull   -0x18(%ebp)
  801a81:	39 d6                	cmp    %edx,%esi
  801a83:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801a86:	72 30                	jb     801ab8 <__udivdi3+0x118>
  801a88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a8b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801a8f:	d3 e2                	shl    %cl,%edx
  801a91:	39 c2                	cmp    %eax,%edx
  801a93:	73 05                	jae    801a9a <__udivdi3+0xfa>
  801a95:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801a98:	74 1e                	je     801ab8 <__udivdi3+0x118>
  801a9a:	89 f9                	mov    %edi,%ecx
  801a9c:	31 ff                	xor    %edi,%edi
  801a9e:	e9 71 ff ff ff       	jmp    801a14 <__udivdi3+0x74>
  801aa3:	90                   	nop
  801aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801aa8:	31 ff                	xor    %edi,%edi
  801aaa:	b9 01 00 00 00       	mov    $0x1,%ecx
  801aaf:	e9 60 ff ff ff       	jmp    801a14 <__udivdi3+0x74>
  801ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ab8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801abb:	31 ff                	xor    %edi,%edi
  801abd:	89 c8                	mov    %ecx,%eax
  801abf:	89 fa                	mov    %edi,%edx
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	5e                   	pop    %esi
  801ac5:	5f                   	pop    %edi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    
	...

00801ad0 <__umoddi3>:
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	83 ec 20             	sub    $0x20,%esp
  801ad8:	8b 55 14             	mov    0x14(%ebp),%edx
  801adb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ade:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae4:	85 d2                	test   %edx,%edx
  801ae6:	89 c8                	mov    %ecx,%eax
  801ae8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801aeb:	75 13                	jne    801b00 <__umoddi3+0x30>
  801aed:	39 f7                	cmp    %esi,%edi
  801aef:	76 3f                	jbe    801b30 <__umoddi3+0x60>
  801af1:	89 f2                	mov    %esi,%edx
  801af3:	f7 f7                	div    %edi
  801af5:	89 d0                	mov    %edx,%eax
  801af7:	31 d2                	xor    %edx,%edx
  801af9:	83 c4 20             	add    $0x20,%esp
  801afc:	5e                   	pop    %esi
  801afd:	5f                   	pop    %edi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    
  801b00:	39 f2                	cmp    %esi,%edx
  801b02:	77 4c                	ja     801b50 <__umoddi3+0x80>
  801b04:	0f bd ca             	bsr    %edx,%ecx
  801b07:	83 f1 1f             	xor    $0x1f,%ecx
  801b0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b0d:	75 51                	jne    801b60 <__umoddi3+0x90>
  801b0f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801b12:	0f 87 e0 00 00 00    	ja     801bf8 <__umoddi3+0x128>
  801b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1b:	29 f8                	sub    %edi,%eax
  801b1d:	19 d6                	sbb    %edx,%esi
  801b1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b25:	89 f2                	mov    %esi,%edx
  801b27:	83 c4 20             	add    $0x20,%esp
  801b2a:	5e                   	pop    %esi
  801b2b:	5f                   	pop    %edi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    
  801b2e:	66 90                	xchg   %ax,%ax
  801b30:	85 ff                	test   %edi,%edi
  801b32:	75 0b                	jne    801b3f <__umoddi3+0x6f>
  801b34:	b8 01 00 00 00       	mov    $0x1,%eax
  801b39:	31 d2                	xor    %edx,%edx
  801b3b:	f7 f7                	div    %edi
  801b3d:	89 c7                	mov    %eax,%edi
  801b3f:	89 f0                	mov    %esi,%eax
  801b41:	31 d2                	xor    %edx,%edx
  801b43:	f7 f7                	div    %edi
  801b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b48:	f7 f7                	div    %edi
  801b4a:	eb a9                	jmp    801af5 <__umoddi3+0x25>
  801b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b50:	89 c8                	mov    %ecx,%eax
  801b52:	89 f2                	mov    %esi,%edx
  801b54:	83 c4 20             	add    $0x20,%esp
  801b57:	5e                   	pop    %esi
  801b58:	5f                   	pop    %edi
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    
  801b5b:	90                   	nop
  801b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b64:	d3 e2                	shl    %cl,%edx
  801b66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b69:	ba 20 00 00 00       	mov    $0x20,%edx
  801b6e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801b71:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b74:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b78:	89 fa                	mov    %edi,%edx
  801b7a:	d3 ea                	shr    %cl,%edx
  801b7c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b80:	0b 55 f4             	or     -0xc(%ebp),%edx
  801b83:	d3 e7                	shl    %cl,%edi
  801b85:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801b89:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b8c:	89 f2                	mov    %esi,%edx
  801b8e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801b91:	89 c7                	mov    %eax,%edi
  801b93:	d3 ea                	shr    %cl,%edx
  801b95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801b99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b9c:	89 c2                	mov    %eax,%edx
  801b9e:	d3 e6                	shl    %cl,%esi
  801ba0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ba4:	d3 ea                	shr    %cl,%edx
  801ba6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801baa:	09 d6                	or     %edx,%esi
  801bac:	89 f0                	mov    %esi,%eax
  801bae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801bb1:	d3 e7                	shl    %cl,%edi
  801bb3:	89 f2                	mov    %esi,%edx
  801bb5:	f7 75 f4             	divl   -0xc(%ebp)
  801bb8:	89 d6                	mov    %edx,%esi
  801bba:	f7 65 e8             	mull   -0x18(%ebp)
  801bbd:	39 d6                	cmp    %edx,%esi
  801bbf:	72 2b                	jb     801bec <__umoddi3+0x11c>
  801bc1:	39 c7                	cmp    %eax,%edi
  801bc3:	72 23                	jb     801be8 <__umoddi3+0x118>
  801bc5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bc9:	29 c7                	sub    %eax,%edi
  801bcb:	19 d6                	sbb    %edx,%esi
  801bcd:	89 f0                	mov    %esi,%eax
  801bcf:	89 f2                	mov    %esi,%edx
  801bd1:	d3 ef                	shr    %cl,%edi
  801bd3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801bd7:	d3 e0                	shl    %cl,%eax
  801bd9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801bdd:	09 f8                	or     %edi,%eax
  801bdf:	d3 ea                	shr    %cl,%edx
  801be1:	83 c4 20             	add    $0x20,%esp
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	39 d6                	cmp    %edx,%esi
  801bea:	75 d9                	jne    801bc5 <__umoddi3+0xf5>
  801bec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801bef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801bf2:	eb d1                	jmp    801bc5 <__umoddi3+0xf5>
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	39 f2                	cmp    %esi,%edx
  801bfa:	0f 82 18 ff ff ff    	jb     801b18 <__umoddi3+0x48>
  801c00:	e9 1d ff ff ff       	jmp    801b22 <__umoddi3+0x52>
