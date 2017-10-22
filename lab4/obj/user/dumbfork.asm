
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 1f 02 00 00       	call   800250 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 e0 13 00 00       	call   801436 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 40 18 80 	movl   $0x801840,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 53 18 80 00 	movl   $0x801853,(%esp)
  800075:	e8 3e 02 00 00       	call   8002b8 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 2a 13 00 00       	call   8013c8 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 63 18 80 	movl   $0x801863,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 53 18 80 00 	movl   $0x801853,(%esp)
  8000bd:	e8 f6 01 00 00       	call   8002b8 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 cb 0d 00 00       	call   800ea5 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 6e 12 00 00       	call   80135c <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 53 18 80 00 	movl   $0x801853,(%esp)
  80010d:	e8 a6 01 00 00       	call   8002b8 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	53                   	push   %ebx
  80011d:	83 ec 24             	sub    $0x24,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800120:	bb 08 00 00 00       	mov    $0x8,%ebx
  800125:	89 d8                	mov    %ebx,%eax
  800127:	cd 30                	int    $0x30
  800129:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	79 20                	jns    80014f <dumbfork+0x36>
		panic("sys_exofork: %e", envid);
  80012f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800133:	c7 44 24 08 87 18 80 	movl   $0x801887,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 53 18 80 00 	movl   $0x801853,(%esp)
  80014a:	e8 69 01 00 00       	call   8002b8 <_panic>
	if (envid == 0) {
  80014f:	85 c0                	test   %eax,%eax
  800151:	75 1d                	jne    800170 <dumbfork+0x57>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800153:	e8 cd 13 00 00       	call   801525 <sys_getenvid>
  800158:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015d:	89 c2                	mov    %eax,%edx
  80015f:	c1 e2 07             	shl    $0x7,%edx
  800162:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800169:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80016e:	eb 7e                	jmp    8001ee <dumbfork+0xd5>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800170:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800177:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80017c:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800181:	76 23                	jbe    8001a6 <dumbfork+0x8d>
  800183:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	89 1c 24             	mov    %ebx,(%esp)
  80018f:	e8 a0 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800197:	05 00 10 00 00       	add    $0x1000,%eax
  80019c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019f:	3d 0c 20 80 00       	cmp    $0x80200c,%eax
  8001a4:	72 e2                	jb     800188 <dumbfork+0x6f>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b2:	89 1c 24             	mov    %ebx,(%esp)
  8001b5:	e8 7a fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001ba:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c1:	00 
  8001c2:	89 1c 24             	mov    %ebx,(%esp)
  8001c5:	e8 26 11 00 00       	call   8012f0 <sys_env_set_status>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <dumbfork+0xd5>
		panic("sys_env_set_status: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 97 18 80 	movl   $0x801897,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 53 18 80 00 	movl   $0x801853,(%esp)
  8001e9:	e8 ca 00 00 00       	call   8002b8 <_panic>

	return envid;
}
  8001ee:	89 d8                	mov    %ebx,%eax
  8001f0:	83 c4 24             	add    $0x24,%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	57                   	push   %edi
  8001fa:	56                   	push   %esi
  8001fb:	53                   	push   %ebx
  8001fc:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001ff:	e8 15 ff ff ff       	call   800119 <dumbfork>
  800204:	89 c6                	mov    %eax,%esi
  800206:	bb 00 00 00 00       	mov    $0x0,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020b:	bf b4 18 80 00       	mov    $0x8018b4,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800210:	eb 27                	jmp    800239 <umain+0x43>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800212:	89 f8                	mov    %edi,%eax
  800214:	85 f6                	test   %esi,%esi
  800216:	75 05                	jne    80021d <umain+0x27>
  800218:	b8 ae 18 80 00       	mov    $0x8018ae,%eax
  80021d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800221:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800225:	c7 04 24 bb 18 80 00 	movl   $0x8018bb,(%esp)
  80022c:	e8 58 01 00 00       	call   800389 <cprintf>
		sys_yield();
  800231:	e8 6d 12 00 00       	call   8014a3 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800236:	83 c3 01             	add    $0x1,%ebx
  800239:	83 fe 01             	cmp    $0x1,%esi
  80023c:	19 c0                	sbb    %eax,%eax
  80023e:	83 e0 0a             	and    $0xa,%eax
  800241:	83 c0 0a             	add    $0xa,%eax
  800244:	39 d8                	cmp    %ebx,%eax
  800246:	7f ca                	jg     800212 <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800248:	83 c4 1c             	add    $0x1c,%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
  800256:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800259:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80025c:	8b 75 08             	mov    0x8(%ebp),%esi
  80025f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800262:	e8 be 12 00 00       	call   801525 <sys_getenvid>
  800267:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026c:	89 c2                	mov    %eax,%edx
  80026e:	c1 e2 07             	shl    $0x7,%edx
  800271:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800278:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80027d:	85 f6                	test   %esi,%esi
  80027f:	7e 07                	jle    800288 <libmain+0x38>
		binaryname = argv[0];
  800281:	8b 03                	mov    (%ebx),%eax
  800283:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800288:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80028c:	89 34 24             	mov    %esi,(%esp)
  80028f:	e8 62 ff ff ff       	call   8001f6 <umain>

	// exit gracefully
	exit();
  800294:	e8 0b 00 00 00       	call   8002a4 <exit>
}
  800299:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80029c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80029f:	89 ec                	mov    %ebp,%esp
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    
	...

008002a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b1:	e8 af 12 00 00       	call   801565 <sys_env_destroy>
}
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8002c0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8002c3:	a1 08 20 80 00       	mov    0x802008,%eax
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	74 10                	je     8002dc <_panic+0x24>
		cprintf("%s: ", argv0);
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	c7 04 24 d7 18 80 00 	movl   $0x8018d7,(%esp)
  8002d7:	e8 ad 00 00 00       	call   800389 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002dc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002e2:	e8 3e 12 00 00       	call   801525 <sys_getenvid>
  8002e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ea:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fd:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800304:	e8 80 00 00 00       	call   800389 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800309:	89 74 24 04          	mov    %esi,0x4(%esp)
  80030d:	8b 45 10             	mov    0x10(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 10 00 00 00       	call   800328 <vcprintf>
	cprintf("\n");
  800318:	c7 04 24 cb 18 80 00 	movl   $0x8018cb,(%esp)
  80031f:	e8 65 00 00 00       	call   800389 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800324:	cc                   	int3   
  800325:	eb fd                	jmp    800324 <_panic+0x6c>
	...

00800328 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800331:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800338:	00 00 00 
	b.cnt = 0;
  80033b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800342:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
  800348:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800353:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	c7 04 24 a3 03 80 00 	movl   $0x8003a3,(%esp)
  800364:	e8 d3 01 00 00       	call   80053c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800369:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80036f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800373:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	e8 6b 0d 00 00       	call   8010ec <sys_cputs>

	return b.cnt;
}
  800381:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80038f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800392:	89 44 24 04          	mov    %eax,0x4(%esp)
  800396:	8b 45 08             	mov    0x8(%ebp),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	e8 87 ff ff ff       	call   800328 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	53                   	push   %ebx
  8003a7:	83 ec 14             	sub    $0x14,%esp
  8003aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ad:	8b 03                	mov    (%ebx),%eax
  8003af:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003b6:	83 c0 01             	add    $0x1,%eax
  8003b9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003c0:	75 19                	jne    8003db <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003c2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003c9:	00 
  8003ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8003cd:	89 04 24             	mov    %eax,(%esp)
  8003d0:	e8 17 0d 00 00       	call   8010ec <sys_cputs>
		b->idx = 0;
  8003d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003df:	83 c4 14             	add    $0x14,%esp
  8003e2:	5b                   	pop    %ebx
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    
	...

008003f0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 4c             	sub    $0x4c,%esp
  8003f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fc:	89 d6                	mov    %edx,%esi
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	8b 55 0c             	mov    0xc(%ebp),%edx
  800407:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80040a:	8b 45 10             	mov    0x10(%ebp),%eax
  80040d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800410:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800413:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800416:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041b:	39 d1                	cmp    %edx,%ecx
  80041d:	72 07                	jb     800426 <printnum_v2+0x36>
  80041f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800422:	39 d0                	cmp    %edx,%eax
  800424:	77 5f                	ja     800485 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800426:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80042a:	83 eb 01             	sub    $0x1,%ebx
  80042d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800431:	89 44 24 08          	mov    %eax,0x8(%esp)
  800435:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800439:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80043d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800440:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800443:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800446:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80044a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800451:	00 
  800452:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800455:	89 04 24             	mov    %eax,(%esp)
  800458:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80045b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045f:	e8 6c 11 00 00       	call   8015d0 <__udivdi3>
  800464:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800467:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80046a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80046e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800472:	89 04 24             	mov    %eax,(%esp)
  800475:	89 54 24 04          	mov    %edx,0x4(%esp)
  800479:	89 f2                	mov    %esi,%edx
  80047b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80047e:	e8 6d ff ff ff       	call   8003f0 <printnum_v2>
  800483:	eb 1e                	jmp    8004a3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800485:	83 ff 2d             	cmp    $0x2d,%edi
  800488:	74 19                	je     8004a3 <printnum_v2+0xb3>
		while (--width > 0)
  80048a:	83 eb 01             	sub    $0x1,%ebx
  80048d:	85 db                	test   %ebx,%ebx
  80048f:	90                   	nop
  800490:	7e 11                	jle    8004a3 <printnum_v2+0xb3>
			putch(padc, putdat);
  800492:	89 74 24 04          	mov    %esi,0x4(%esp)
  800496:	89 3c 24             	mov    %edi,(%esp)
  800499:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80049c:	83 eb 01             	sub    $0x1,%ebx
  80049f:	85 db                	test   %ebx,%ebx
  8004a1:	7f ef                	jg     800492 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8004ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004b9:	00 
  8004ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004bd:	89 14 24             	mov    %edx,(%esp)
  8004c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c7:	e8 34 12 00 00       	call   801700 <__umoddi3>
  8004cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d0:	0f be 80 ff 18 80 00 	movsbl 0x8018ff(%eax),%eax
  8004d7:	89 04 24             	mov    %eax,(%esp)
  8004da:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004dd:	83 c4 4c             	add    $0x4c,%esp
  8004e0:	5b                   	pop    %ebx
  8004e1:	5e                   	pop    %esi
  8004e2:	5f                   	pop    %edi
  8004e3:	5d                   	pop    %ebp
  8004e4:	c3                   	ret    

008004e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e8:	83 fa 01             	cmp    $0x1,%edx
  8004eb:	7e 0e                	jle    8004fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f2:	89 08                	mov    %ecx,(%eax)
  8004f4:	8b 02                	mov    (%edx),%eax
  8004f6:	8b 52 04             	mov    0x4(%edx),%edx
  8004f9:	eb 22                	jmp    80051d <getuint+0x38>
	else if (lflag)
  8004fb:	85 d2                	test   %edx,%edx
  8004fd:	74 10                	je     80050f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ff:	8b 10                	mov    (%eax),%edx
  800501:	8d 4a 04             	lea    0x4(%edx),%ecx
  800504:	89 08                	mov    %ecx,(%eax)
  800506:	8b 02                	mov    (%edx),%eax
  800508:	ba 00 00 00 00       	mov    $0x0,%edx
  80050d:	eb 0e                	jmp    80051d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80050f:	8b 10                	mov    (%eax),%edx
  800511:	8d 4a 04             	lea    0x4(%edx),%ecx
  800514:	89 08                	mov    %ecx,(%eax)
  800516:	8b 02                	mov    (%edx),%eax
  800518:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    

0080051f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800525:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800529:	8b 10                	mov    (%eax),%edx
  80052b:	3b 50 04             	cmp    0x4(%eax),%edx
  80052e:	73 0a                	jae    80053a <sprintputch+0x1b>
		*b->buf++ = ch;
  800530:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800533:	88 0a                	mov    %cl,(%edx)
  800535:	83 c2 01             	add    $0x1,%edx
  800538:	89 10                	mov    %edx,(%eax)
}
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
  800542:	83 ec 6c             	sub    $0x6c,%esp
  800545:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800548:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80054f:	eb 1a                	jmp    80056b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 84 66 06 00 00    	je     800bbf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800559:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	eb 03                	jmp    80056b <vprintfmt+0x2f>
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056b:	0f b6 07             	movzbl (%edi),%eax
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	83 f8 25             	cmp    $0x25,%eax
  800574:	75 db                	jne    800551 <vprintfmt+0x15>
  800576:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80057a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800586:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80058b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800592:	be 00 00 00 00       	mov    $0x0,%esi
  800597:	eb 06                	jmp    80059f <vprintfmt+0x63>
  800599:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80059d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	0f b6 17             	movzbl (%edi),%edx
  8005a2:	0f b6 c2             	movzbl %dl,%eax
  8005a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a8:	8d 47 01             	lea    0x1(%edi),%eax
  8005ab:	83 ea 23             	sub    $0x23,%edx
  8005ae:	80 fa 55             	cmp    $0x55,%dl
  8005b1:	0f 87 60 05 00 00    	ja     800b17 <vprintfmt+0x5db>
  8005b7:	0f b6 d2             	movzbl %dl,%edx
  8005ba:	ff 24 95 40 1a 80 00 	jmp    *0x801a40(,%edx,4)
  8005c1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8005c6:	eb d5                	jmp    80059d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005cb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8005ce:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005d1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8005d4:	83 ff 09             	cmp    $0x9,%edi
  8005d7:	76 08                	jbe    8005e1 <vprintfmt+0xa5>
  8005d9:	eb 40                	jmp    80061b <vprintfmt+0xdf>
  8005db:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8005df:	eb bc                	jmp    80059d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005e4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8005e7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8005eb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005ee:	8d 7a d0             	lea    -0x30(%edx),%edi
  8005f1:	83 ff 09             	cmp    $0x9,%edi
  8005f4:	76 eb                	jbe    8005e1 <vprintfmt+0xa5>
  8005f6:	eb 23                	jmp    80061b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8005fb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8005fe:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800601:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800603:	eb 16                	jmp    80061b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800605:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800608:	c1 fa 1f             	sar    $0x1f,%edx
  80060b:	f7 d2                	not    %edx
  80060d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800610:	eb 8b                	jmp    80059d <vprintfmt+0x61>
  800612:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800619:	eb 82                	jmp    80059d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80061b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061f:	0f 89 78 ff ff ff    	jns    80059d <vprintfmt+0x61>
  800625:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800628:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80062b:	e9 6d ff ff ff       	jmp    80059d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800630:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800633:	e9 65 ff ff ff       	jmp    80059d <vprintfmt+0x61>
  800638:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 50 04             	lea    0x4(%eax),%edx
  800641:	89 55 14             	mov    %edx,0x14(%ebp)
  800644:	8b 55 0c             	mov    0xc(%ebp),%edx
  800647:	89 54 24 04          	mov    %edx,0x4(%esp)
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	ff 55 08             	call   *0x8(%ebp)
  800653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800656:	e9 10 ff ff ff       	jmp    80056b <vprintfmt+0x2f>
  80065b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 c2                	mov    %eax,%edx
  80066b:	c1 fa 1f             	sar    $0x1f,%edx
  80066e:	31 d0                	xor    %edx,%eax
  800670:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800672:	83 f8 08             	cmp    $0x8,%eax
  800675:	7f 0b                	jg     800682 <vprintfmt+0x146>
  800677:	8b 14 85 a0 1b 80 00 	mov    0x801ba0(,%eax,4),%edx
  80067e:	85 d2                	test   %edx,%edx
  800680:	75 26                	jne    8006a8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800682:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800686:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  80068d:	00 
  80068e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800691:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800695:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800698:	89 1c 24             	mov    %ebx,(%esp)
  80069b:	e8 a7 05 00 00       	call   800c47 <printfmt>
  8006a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a3:	e9 c3 fe ff ff       	jmp    80056b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8006a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ac:	c7 44 24 08 19 19 80 	movl   $0x801919,0x8(%esp)
  8006b3:	00 
  8006b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8006be:	89 14 24             	mov    %edx,(%esp)
  8006c1:	e8 81 05 00 00       	call   800c47 <printfmt>
  8006c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c9:	e9 9d fe ff ff       	jmp    80056b <vprintfmt+0x2f>
  8006ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d1:	89 c7                	mov    %eax,%edi
  8006d3:	89 d9                	mov    %ebx,%ecx
  8006d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8d 50 04             	lea    0x4(%eax),%edx
  8006e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e4:	8b 30                	mov    (%eax),%esi
  8006e6:	85 f6                	test   %esi,%esi
  8006e8:	75 05                	jne    8006ef <vprintfmt+0x1b3>
  8006ea:	be 1c 19 80 00       	mov    $0x80191c,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8006ef:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8006f3:	7e 06                	jle    8006fb <vprintfmt+0x1bf>
  8006f5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8006f9:	75 10                	jne    80070b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fb:	0f be 06             	movsbl (%esi),%eax
  8006fe:	85 c0                	test   %eax,%eax
  800700:	0f 85 a2 00 00 00    	jne    8007a8 <vprintfmt+0x26c>
  800706:	e9 92 00 00 00       	jmp    80079d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80070f:	89 34 24             	mov    %esi,(%esp)
  800712:	e8 74 05 00 00       	call   800c8b <strnlen>
  800717:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80071a:	29 c2                	sub    %eax,%edx
  80071c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80071f:	85 d2                	test   %edx,%edx
  800721:	7e d8                	jle    8006fb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800723:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800727:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80072a:	89 d3                	mov    %edx,%ebx
  80072c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80072f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800732:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800735:	89 ce                	mov    %ecx,%esi
  800737:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80073b:	89 34 24             	mov    %esi,(%esp)
  80073e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800741:	83 eb 01             	sub    $0x1,%ebx
  800744:	85 db                	test   %ebx,%ebx
  800746:	7f ef                	jg     800737 <vprintfmt+0x1fb>
  800748:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80074b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80074e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800751:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800758:	eb a1                	jmp    8006fb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80075a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80075e:	74 1b                	je     80077b <vprintfmt+0x23f>
  800760:	8d 50 e0             	lea    -0x20(%eax),%edx
  800763:	83 fa 5e             	cmp    $0x5e,%edx
  800766:	76 13                	jbe    80077b <vprintfmt+0x23f>
					putch('?', putdat);
  800768:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800776:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800779:	eb 0d                	jmp    800788 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800782:	89 04 24             	mov    %eax,(%esp)
  800785:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800788:	83 ef 01             	sub    $0x1,%edi
  80078b:	0f be 06             	movsbl (%esi),%eax
  80078e:	85 c0                	test   %eax,%eax
  800790:	74 05                	je     800797 <vprintfmt+0x25b>
  800792:	83 c6 01             	add    $0x1,%esi
  800795:	eb 1a                	jmp    8007b1 <vprintfmt+0x275>
  800797:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80079a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007a1:	7f 1f                	jg     8007c2 <vprintfmt+0x286>
  8007a3:	e9 c0 fd ff ff       	jmp    800568 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a8:	83 c6 01             	add    $0x1,%esi
  8007ab:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007b1:	85 db                	test   %ebx,%ebx
  8007b3:	78 a5                	js     80075a <vprintfmt+0x21e>
  8007b5:	83 eb 01             	sub    $0x1,%ebx
  8007b8:	79 a0                	jns    80075a <vprintfmt+0x21e>
  8007ba:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8007bd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007c0:	eb db                	jmp    80079d <vprintfmt+0x261>
  8007c2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007c8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8007cb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007db:	83 eb 01             	sub    $0x1,%ebx
  8007de:	85 db                	test   %ebx,%ebx
  8007e0:	7f ec                	jg     8007ce <vprintfmt+0x292>
  8007e2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007e5:	e9 81 fd ff ff       	jmp    80056b <vprintfmt+0x2f>
  8007ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ed:	83 fe 01             	cmp    $0x1,%esi
  8007f0:	7e 10                	jle    800802 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 08             	lea    0x8(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	8b 18                	mov    (%eax),%ebx
  8007fd:	8b 70 04             	mov    0x4(%eax),%esi
  800800:	eb 26                	jmp    800828 <vprintfmt+0x2ec>
	else if (lflag)
  800802:	85 f6                	test   %esi,%esi
  800804:	74 12                	je     800818 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 18                	mov    (%eax),%ebx
  800811:	89 de                	mov    %ebx,%esi
  800813:	c1 fe 1f             	sar    $0x1f,%esi
  800816:	eb 10                	jmp    800828 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8d 50 04             	lea    0x4(%eax),%edx
  80081e:	89 55 14             	mov    %edx,0x14(%ebp)
  800821:	8b 18                	mov    (%eax),%ebx
  800823:	89 de                	mov    %ebx,%esi
  800825:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800828:	83 f9 01             	cmp    $0x1,%ecx
  80082b:	75 1e                	jne    80084b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80082d:	85 f6                	test   %esi,%esi
  80082f:	78 1a                	js     80084b <vprintfmt+0x30f>
  800831:	85 f6                	test   %esi,%esi
  800833:	7f 05                	jg     80083a <vprintfmt+0x2fe>
  800835:	83 fb 00             	cmp    $0x0,%ebx
  800838:	76 11                	jbe    80084b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800841:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800848:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80084b:	85 f6                	test   %esi,%esi
  80084d:	78 13                	js     800862 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80084f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800852:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800858:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085d:	e9 da 00 00 00       	jmp    80093c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800862:	8b 45 0c             	mov    0xc(%ebp),%eax
  800865:	89 44 24 04          	mov    %eax,0x4(%esp)
  800869:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800870:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800873:	89 da                	mov    %ebx,%edx
  800875:	89 f1                	mov    %esi,%ecx
  800877:	f7 da                	neg    %edx
  800879:	83 d1 00             	adc    $0x0,%ecx
  80087c:	f7 d9                	neg    %ecx
  80087e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800881:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800884:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800887:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088c:	e9 ab 00 00 00       	jmp    80093c <vprintfmt+0x400>
  800891:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800894:	89 f2                	mov    %esi,%edx
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
  800899:	e8 47 fc ff ff       	call   8004e5 <getuint>
  80089e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8008a1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8008ac:	e9 8b 00 00 00       	jmp    80093c <vprintfmt+0x400>
  8008b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8008b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008bb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008c2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8008c5:	89 f2                	mov    %esi,%edx
  8008c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ca:	e8 16 fc ff ff       	call   8004e5 <getuint>
  8008cf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8008d2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8008d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8008dd:	eb 5d                	jmp    80093c <vprintfmt+0x400>
  8008df:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8008e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008fe:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800901:	8b 45 14             	mov    0x14(%ebp),%eax
  800904:	8d 50 04             	lea    0x4(%eax),%edx
  800907:	89 55 14             	mov    %edx,0x14(%ebp)
  80090a:	8b 10                	mov    (%eax),%edx
  80090c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800911:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800914:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800917:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80091f:	eb 1b                	jmp    80093c <vprintfmt+0x400>
  800921:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800924:	89 f2                	mov    %esi,%edx
  800926:	8d 45 14             	lea    0x14(%ebp),%eax
  800929:	e8 b7 fb ff ff       	call   8004e5 <getuint>
  80092e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800931:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800934:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800937:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80093c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800940:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800943:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800946:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80094a:	77 09                	ja     800955 <vprintfmt+0x419>
  80094c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80094f:	0f 82 ac 00 00 00    	jb     800a01 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800955:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800958:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80095c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80095f:	83 ea 01             	sub    $0x1,%edx
  800962:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800966:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80096e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800972:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800975:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800978:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80097b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80097f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800986:	00 
  800987:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80098a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80098d:	89 0c 24             	mov    %ecx,(%esp)
  800990:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800994:	e8 37 0c 00 00       	call   8015d0 <__udivdi3>
  800999:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80099c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80099f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8009a7:	89 04 24             	mov    %eax,(%esp)
  8009aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	e8 37 fa ff ff       	call   8003f0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009d2:	00 
  8009d3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8009d6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8009d9:	89 14 24             	mov    %edx,(%esp)
  8009dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e0:	e8 1b 0d 00 00       	call   801700 <__umoddi3>
  8009e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e9:	0f be 80 ff 18 80 00 	movsbl 0x8018ff(%eax),%eax
  8009f0:	89 04 24             	mov    %eax,(%esp)
  8009f3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8009f6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8009fa:	74 54                	je     800a50 <vprintfmt+0x514>
  8009fc:	e9 67 fb ff ff       	jmp    800568 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800a01:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800a05:	8d 76 00             	lea    0x0(%esi),%esi
  800a08:	0f 84 2a 01 00 00    	je     800b38 <vprintfmt+0x5fc>
		while (--width > 0)
  800a0e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a11:	83 ef 01             	sub    $0x1,%edi
  800a14:	85 ff                	test   %edi,%edi
  800a16:	0f 8e 5e 01 00 00    	jle    800b7a <vprintfmt+0x63e>
  800a1c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800a1f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800a22:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800a25:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800a28:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a2b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800a2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a32:	89 1c 24             	mov    %ebx,(%esp)
  800a35:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800a38:	83 ef 01             	sub    $0x1,%edi
  800a3b:	85 ff                	test   %edi,%edi
  800a3d:	7f ef                	jg     800a2e <vprintfmt+0x4f2>
  800a3f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a42:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a45:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800a48:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800a4b:	e9 2a 01 00 00       	jmp    800b7a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800a50:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800a53:	83 eb 01             	sub    $0x1,%ebx
  800a56:	85 db                	test   %ebx,%ebx
  800a58:	0f 8e 0a fb ff ff    	jle    800568 <vprintfmt+0x2c>
  800a5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a61:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a64:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800a67:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a72:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800a74:	83 eb 01             	sub    $0x1,%ebx
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	7f ec                	jg     800a67 <vprintfmt+0x52b>
  800a7b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a7e:	e9 e8 fa ff ff       	jmp    80056b <vprintfmt+0x2f>
  800a83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800a86:	8b 45 14             	mov    0x14(%ebp),%eax
  800a89:	8d 50 04             	lea    0x4(%eax),%edx
  800a8c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8f:	8b 00                	mov    (%eax),%eax
  800a91:	85 c0                	test   %eax,%eax
  800a93:	75 2a                	jne    800abf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800a95:	c7 44 24 0c b8 19 80 	movl   $0x8019b8,0xc(%esp)
  800a9c:	00 
  800a9d:	c7 44 24 08 19 19 80 	movl   $0x801919,0x8(%esp)
  800aa4:	00 
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaf:	89 0c 24             	mov    %ecx,(%esp)
  800ab2:	e8 90 01 00 00       	call   800c47 <printfmt>
  800ab7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aba:	e9 ac fa ff ff       	jmp    80056b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac2:	8b 13                	mov    (%ebx),%edx
  800ac4:	83 fa 7f             	cmp    $0x7f,%edx
  800ac7:	7e 29                	jle    800af2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800ac9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800acb:	c7 44 24 0c f0 19 80 	movl   $0x8019f0,0xc(%esp)
  800ad2:	00 
  800ad3:	c7 44 24 08 19 19 80 	movl   $0x801919,0x8(%esp)
  800ada:	00 
  800adb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	89 04 24             	mov    %eax,(%esp)
  800ae5:	e8 5d 01 00 00       	call   800c47 <printfmt>
  800aea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aed:	e9 79 fa ff ff       	jmp    80056b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800af2:	88 10                	mov    %dl,(%eax)
  800af4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800af7:	e9 6f fa ff ff       	jmp    80056b <vprintfmt+0x2f>
  800afc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b05:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b09:	89 14 24             	mov    %edx,(%esp)
  800b0c:	ff 55 08             	call   *0x8(%ebp)
  800b0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800b12:	e9 54 fa ff ff       	jmp    80056b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b25:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b28:	8d 47 ff             	lea    -0x1(%edi),%eax
  800b2b:	80 38 25             	cmpb   $0x25,(%eax)
  800b2e:	0f 84 37 fa ff ff    	je     80056b <vprintfmt+0x2f>
  800b34:	89 c7                	mov    %eax,%edi
  800b36:	eb f0                	jmp    800b28 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b43:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b46:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b4a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b51:	00 
  800b52:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800b55:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b5f:	e8 9c 0b 00 00       	call   801700 <__umoddi3>
  800b64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b68:	0f be 80 ff 18 80 00 	movsbl 0x8018ff(%eax),%eax
  800b6f:	89 04 24             	mov    %eax,(%esp)
  800b72:	ff 55 08             	call   *0x8(%ebp)
  800b75:	e9 d6 fe ff ff       	jmp    800a50 <vprintfmt+0x514>
  800b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b81:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b85:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b93:	00 
  800b94:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800b97:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800b9a:	89 04 24             	mov    %eax,(%esp)
  800b9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ba1:	e8 5a 0b 00 00       	call   801700 <__umoddi3>
  800ba6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800baa:	0f be 80 ff 18 80 00 	movsbl 0x8018ff(%eax),%eax
  800bb1:	89 04 24             	mov    %eax,(%esp)
  800bb4:	ff 55 08             	call   *0x8(%ebp)
  800bb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bba:	e9 ac f9 ff ff       	jmp    80056b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800bbf:	83 c4 6c             	add    $0x6c,%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 28             	sub    $0x28,%esp
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	74 04                	je     800bdb <vsnprintf+0x14>
  800bd7:	85 d2                	test   %edx,%edx
  800bd9:	7f 07                	jg     800be2 <vsnprintf+0x1b>
  800bdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800be0:	eb 3b                	jmp    800c1d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800be2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bf3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c01:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c08:	c7 04 24 1f 05 80 00 	movl   $0x80051f,(%esp)
  800c0f:	e8 28 f9 ff ff       	call   80053c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800c25:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800c28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	89 04 24             	mov    %eax,(%esp)
  800c40:	e8 82 ff ff ff       	call   800bc7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800c4d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800c50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c54:	8b 45 10             	mov    0x10(%ebp),%eax
  800c57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	89 04 24             	mov    %eax,(%esp)
  800c68:	e8 cf f8 ff ff       	call   80053c <vprintfmt>
	va_end(ap);
}
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    
	...

00800c70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c76:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c7e:	74 09                	je     800c89 <strlen+0x19>
		n++;
  800c80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c87:	75 f7                	jne    800c80 <strlen+0x10>
		n++;
	return n;
}
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	53                   	push   %ebx
  800c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c95:	85 c9                	test   %ecx,%ecx
  800c97:	74 19                	je     800cb2 <strnlen+0x27>
  800c99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c9c:	74 14                	je     800cb2 <strnlen+0x27>
  800c9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ca3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca6:	39 c8                	cmp    %ecx,%eax
  800ca8:	74 0d                	je     800cb7 <strnlen+0x2c>
  800caa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800cae:	75 f3                	jne    800ca3 <strnlen+0x18>
  800cb0:	eb 05                	jmp    800cb7 <strnlen+0x2c>
  800cb2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	53                   	push   %ebx
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800ccd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800cd0:	83 c2 01             	add    $0x1,%edx
  800cd3:	84 c9                	test   %cl,%cl
  800cd5:	75 f2                	jne    800cc9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 08             	sub    $0x8,%esp
  800ce1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ce4:	89 1c 24             	mov    %ebx,(%esp)
  800ce7:	e8 84 ff ff ff       	call   800c70 <strlen>
	strcpy(dst + len, src);
  800cec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cef:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cf3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800cf6:	89 04 24             	mov    %eax,(%esp)
  800cf9:	e8 bc ff ff ff       	call   800cba <strcpy>
	return dst;
}
  800cfe:	89 d8                	mov    %ebx,%eax
  800d00:	83 c4 08             	add    $0x8,%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d14:	85 f6                	test   %esi,%esi
  800d16:	74 18                	je     800d30 <strncpy+0x2a>
  800d18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d1d:	0f b6 1a             	movzbl (%edx),%ebx
  800d20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d23:	80 3a 01             	cmpb   $0x1,(%edx)
  800d26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d29:	83 c1 01             	add    $0x1,%ecx
  800d2c:	39 ce                	cmp    %ecx,%esi
  800d2e:	77 ed                	ja     800d1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	8b 75 08             	mov    0x8(%ebp),%esi
  800d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d42:	89 f0                	mov    %esi,%eax
  800d44:	85 c9                	test   %ecx,%ecx
  800d46:	74 27                	je     800d6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800d48:	83 e9 01             	sub    $0x1,%ecx
  800d4b:	74 1d                	je     800d6a <strlcpy+0x36>
  800d4d:	0f b6 1a             	movzbl (%edx),%ebx
  800d50:	84 db                	test   %bl,%bl
  800d52:	74 16                	je     800d6a <strlcpy+0x36>
			*dst++ = *src++;
  800d54:	88 18                	mov    %bl,(%eax)
  800d56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d59:	83 e9 01             	sub    $0x1,%ecx
  800d5c:	74 0e                	je     800d6c <strlcpy+0x38>
			*dst++ = *src++;
  800d5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d61:	0f b6 1a             	movzbl (%edx),%ebx
  800d64:	84 db                	test   %bl,%bl
  800d66:	75 ec                	jne    800d54 <strlcpy+0x20>
  800d68:	eb 02                	jmp    800d6c <strlcpy+0x38>
  800d6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d6c:	c6 00 00             	movb   $0x0,(%eax)
  800d6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d7e:	0f b6 01             	movzbl (%ecx),%eax
  800d81:	84 c0                	test   %al,%al
  800d83:	74 15                	je     800d9a <strcmp+0x25>
  800d85:	3a 02                	cmp    (%edx),%al
  800d87:	75 11                	jne    800d9a <strcmp+0x25>
		p++, q++;
  800d89:	83 c1 01             	add    $0x1,%ecx
  800d8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d8f:	0f b6 01             	movzbl (%ecx),%eax
  800d92:	84 c0                	test   %al,%al
  800d94:	74 04                	je     800d9a <strcmp+0x25>
  800d96:	3a 02                	cmp    (%edx),%al
  800d98:	74 ef                	je     800d89 <strcmp+0x14>
  800d9a:	0f b6 c0             	movzbl %al,%eax
  800d9d:	0f b6 12             	movzbl (%edx),%edx
  800da0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	53                   	push   %ebx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	74 23                	je     800dd8 <strncmp+0x34>
  800db5:	0f b6 1a             	movzbl (%edx),%ebx
  800db8:	84 db                	test   %bl,%bl
  800dba:	74 25                	je     800de1 <strncmp+0x3d>
  800dbc:	3a 19                	cmp    (%ecx),%bl
  800dbe:	75 21                	jne    800de1 <strncmp+0x3d>
  800dc0:	83 e8 01             	sub    $0x1,%eax
  800dc3:	74 13                	je     800dd8 <strncmp+0x34>
		n--, p++, q++;
  800dc5:	83 c2 01             	add    $0x1,%edx
  800dc8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcb:	0f b6 1a             	movzbl (%edx),%ebx
  800dce:	84 db                	test   %bl,%bl
  800dd0:	74 0f                	je     800de1 <strncmp+0x3d>
  800dd2:	3a 19                	cmp    (%ecx),%bl
  800dd4:	74 ea                	je     800dc0 <strncmp+0x1c>
  800dd6:	eb 09                	jmp    800de1 <strncmp+0x3d>
  800dd8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5d                   	pop    %ebp
  800ddf:	90                   	nop
  800de0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800de1:	0f b6 02             	movzbl (%edx),%eax
  800de4:	0f b6 11             	movzbl (%ecx),%edx
  800de7:	29 d0                	sub    %edx,%eax
  800de9:	eb f2                	jmp    800ddd <strncmp+0x39>

00800deb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df5:	0f b6 10             	movzbl (%eax),%edx
  800df8:	84 d2                	test   %dl,%dl
  800dfa:	74 18                	je     800e14 <strchr+0x29>
		if (*s == c)
  800dfc:	38 ca                	cmp    %cl,%dl
  800dfe:	75 0a                	jne    800e0a <strchr+0x1f>
  800e00:	eb 17                	jmp    800e19 <strchr+0x2e>
  800e02:	38 ca                	cmp    %cl,%dl
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	74 0f                	je     800e19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e0a:	83 c0 01             	add    $0x1,%eax
  800e0d:	0f b6 10             	movzbl (%eax),%edx
  800e10:	84 d2                	test   %dl,%dl
  800e12:	75 ee                	jne    800e02 <strchr+0x17>
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e25:	0f b6 10             	movzbl (%eax),%edx
  800e28:	84 d2                	test   %dl,%dl
  800e2a:	74 18                	je     800e44 <strfind+0x29>
		if (*s == c)
  800e2c:	38 ca                	cmp    %cl,%dl
  800e2e:	75 0a                	jne    800e3a <strfind+0x1f>
  800e30:	eb 12                	jmp    800e44 <strfind+0x29>
  800e32:	38 ca                	cmp    %cl,%dl
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	74 0a                	je     800e44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e3a:	83 c0 01             	add    $0x1,%eax
  800e3d:	0f b6 10             	movzbl (%eax),%edx
  800e40:	84 d2                	test   %dl,%dl
  800e42:	75 ee                	jne    800e32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	89 1c 24             	mov    %ebx,(%esp)
  800e4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e60:	85 c9                	test   %ecx,%ecx
  800e62:	74 30                	je     800e94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e6a:	75 25                	jne    800e91 <memset+0x4b>
  800e6c:	f6 c1 03             	test   $0x3,%cl
  800e6f:	75 20                	jne    800e91 <memset+0x4b>
		c &= 0xFF;
  800e71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e74:	89 d3                	mov    %edx,%ebx
  800e76:	c1 e3 08             	shl    $0x8,%ebx
  800e79:	89 d6                	mov    %edx,%esi
  800e7b:	c1 e6 18             	shl    $0x18,%esi
  800e7e:	89 d0                	mov    %edx,%eax
  800e80:	c1 e0 10             	shl    $0x10,%eax
  800e83:	09 f0                	or     %esi,%eax
  800e85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800e87:	09 d8                	or     %ebx,%eax
  800e89:	c1 e9 02             	shr    $0x2,%ecx
  800e8c:	fc                   	cld    
  800e8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e8f:	eb 03                	jmp    800e94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e91:	fc                   	cld    
  800e92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e94:	89 f8                	mov    %edi,%eax
  800e96:	8b 1c 24             	mov    (%esp),%ebx
  800e99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ea1:	89 ec                	mov    %ebp,%esp
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	89 34 24             	mov    %esi,(%esp)
  800eae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800eb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ebb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ebd:	39 c6                	cmp    %eax,%esi
  800ebf:	73 35                	jae    800ef6 <memmove+0x51>
  800ec1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ec4:	39 d0                	cmp    %edx,%eax
  800ec6:	73 2e                	jae    800ef6 <memmove+0x51>
		s += n;
		d += n;
  800ec8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eca:	f6 c2 03             	test   $0x3,%dl
  800ecd:	75 1b                	jne    800eea <memmove+0x45>
  800ecf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ed5:	75 13                	jne    800eea <memmove+0x45>
  800ed7:	f6 c1 03             	test   $0x3,%cl
  800eda:	75 0e                	jne    800eea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800edc:	83 ef 04             	sub    $0x4,%edi
  800edf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ee2:	c1 e9 02             	shr    $0x2,%ecx
  800ee5:	fd                   	std    
  800ee6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee8:	eb 09                	jmp    800ef3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eea:	83 ef 01             	sub    $0x1,%edi
  800eed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ef0:	fd                   	std    
  800ef1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ef4:	eb 20                	jmp    800f16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ef6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800efc:	75 15                	jne    800f13 <memmove+0x6e>
  800efe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f04:	75 0d                	jne    800f13 <memmove+0x6e>
  800f06:	f6 c1 03             	test   $0x3,%cl
  800f09:	75 08                	jne    800f13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800f0b:	c1 e9 02             	shr    $0x2,%ecx
  800f0e:	fc                   	cld    
  800f0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f11:	eb 03                	jmp    800f16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f13:	fc                   	cld    
  800f14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f16:	8b 34 24             	mov    (%esp),%esi
  800f19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f1d:	89 ec                	mov    %ebp,%esp
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f27:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	89 04 24             	mov    %eax,(%esp)
  800f3b:	e8 65 ff ff ff       	call   800ea5 <memmove>
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f51:	85 c9                	test   %ecx,%ecx
  800f53:	74 36                	je     800f8b <memcmp+0x49>
		if (*s1 != *s2)
  800f55:	0f b6 06             	movzbl (%esi),%eax
  800f58:	0f b6 1f             	movzbl (%edi),%ebx
  800f5b:	38 d8                	cmp    %bl,%al
  800f5d:	74 20                	je     800f7f <memcmp+0x3d>
  800f5f:	eb 14                	jmp    800f75 <memcmp+0x33>
  800f61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800f66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800f6b:	83 c2 01             	add    $0x1,%edx
  800f6e:	83 e9 01             	sub    $0x1,%ecx
  800f71:	38 d8                	cmp    %bl,%al
  800f73:	74 12                	je     800f87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800f75:	0f b6 c0             	movzbl %al,%eax
  800f78:	0f b6 db             	movzbl %bl,%ebx
  800f7b:	29 d8                	sub    %ebx,%eax
  800f7d:	eb 11                	jmp    800f90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f7f:	83 e9 01             	sub    $0x1,%ecx
  800f82:	ba 00 00 00 00       	mov    $0x0,%edx
  800f87:	85 c9                	test   %ecx,%ecx
  800f89:	75 d6                	jne    800f61 <memcmp+0x1f>
  800f8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f9b:	89 c2                	mov    %eax,%edx
  800f9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fa0:	39 d0                	cmp    %edx,%eax
  800fa2:	73 15                	jae    800fb9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fa4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800fa8:	38 08                	cmp    %cl,(%eax)
  800faa:	75 06                	jne    800fb2 <memfind+0x1d>
  800fac:	eb 0b                	jmp    800fb9 <memfind+0x24>
  800fae:	38 08                	cmp    %cl,(%eax)
  800fb0:	74 07                	je     800fb9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fb2:	83 c0 01             	add    $0x1,%eax
  800fb5:	39 c2                	cmp    %eax,%edx
  800fb7:	77 f5                	ja     800fae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	57                   	push   %edi
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 04             	sub    $0x4,%esp
  800fc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fca:	0f b6 02             	movzbl (%edx),%eax
  800fcd:	3c 20                	cmp    $0x20,%al
  800fcf:	74 04                	je     800fd5 <strtol+0x1a>
  800fd1:	3c 09                	cmp    $0x9,%al
  800fd3:	75 0e                	jne    800fe3 <strtol+0x28>
		s++;
  800fd5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fd8:	0f b6 02             	movzbl (%edx),%eax
  800fdb:	3c 20                	cmp    $0x20,%al
  800fdd:	74 f6                	je     800fd5 <strtol+0x1a>
  800fdf:	3c 09                	cmp    $0x9,%al
  800fe1:	74 f2                	je     800fd5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fe3:	3c 2b                	cmp    $0x2b,%al
  800fe5:	75 0c                	jne    800ff3 <strtol+0x38>
		s++;
  800fe7:	83 c2 01             	add    $0x1,%edx
  800fea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ff1:	eb 15                	jmp    801008 <strtol+0x4d>
	else if (*s == '-')
  800ff3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ffa:	3c 2d                	cmp    $0x2d,%al
  800ffc:	75 0a                	jne    801008 <strtol+0x4d>
		s++, neg = 1;
  800ffe:	83 c2 01             	add    $0x1,%edx
  801001:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801008:	85 db                	test   %ebx,%ebx
  80100a:	0f 94 c0             	sete   %al
  80100d:	74 05                	je     801014 <strtol+0x59>
  80100f:	83 fb 10             	cmp    $0x10,%ebx
  801012:	75 18                	jne    80102c <strtol+0x71>
  801014:	80 3a 30             	cmpb   $0x30,(%edx)
  801017:	75 13                	jne    80102c <strtol+0x71>
  801019:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	75 0a                	jne    80102c <strtol+0x71>
		s += 2, base = 16;
  801022:	83 c2 02             	add    $0x2,%edx
  801025:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80102a:	eb 15                	jmp    801041 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80102c:	84 c0                	test   %al,%al
  80102e:	66 90                	xchg   %ax,%ax
  801030:	74 0f                	je     801041 <strtol+0x86>
  801032:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801037:	80 3a 30             	cmpb   $0x30,(%edx)
  80103a:	75 05                	jne    801041 <strtol+0x86>
		s++, base = 8;
  80103c:	83 c2 01             	add    $0x1,%edx
  80103f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801041:	b8 00 00 00 00       	mov    $0x0,%eax
  801046:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801048:	0f b6 0a             	movzbl (%edx),%ecx
  80104b:	89 cf                	mov    %ecx,%edi
  80104d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801050:	80 fb 09             	cmp    $0x9,%bl
  801053:	77 08                	ja     80105d <strtol+0xa2>
			dig = *s - '0';
  801055:	0f be c9             	movsbl %cl,%ecx
  801058:	83 e9 30             	sub    $0x30,%ecx
  80105b:	eb 1e                	jmp    80107b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80105d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801060:	80 fb 19             	cmp    $0x19,%bl
  801063:	77 08                	ja     80106d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801065:	0f be c9             	movsbl %cl,%ecx
  801068:	83 e9 57             	sub    $0x57,%ecx
  80106b:	eb 0e                	jmp    80107b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80106d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801070:	80 fb 19             	cmp    $0x19,%bl
  801073:	77 15                	ja     80108a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801075:	0f be c9             	movsbl %cl,%ecx
  801078:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80107b:	39 f1                	cmp    %esi,%ecx
  80107d:	7d 0b                	jge    80108a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80107f:	83 c2 01             	add    $0x1,%edx
  801082:	0f af c6             	imul   %esi,%eax
  801085:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801088:	eb be                	jmp    801048 <strtol+0x8d>
  80108a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80108c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801090:	74 05                	je     801097 <strtol+0xdc>
		*endptr = (char *) s;
  801092:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801095:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801097:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80109b:	74 04                	je     8010a1 <strtol+0xe6>
  80109d:	89 c8                	mov    %ecx,%eax
  80109f:	f7 d8                	neg    %eax
}
  8010a1:	83 c4 04             	add    $0x4,%esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5e                   	pop    %esi
  8010a6:	5f                   	pop    %edi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    
  8010a9:	00 00                	add    %al,(%eax)
	...

008010ac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 08             	sub    $0x8,%esp
  8010b2:	89 1c 24             	mov    %ebx,(%esp)
  8010b5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010be:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c3:	89 d1                	mov    %edx,%ecx
  8010c5:	89 d3                	mov    %edx,%ebx
  8010c7:	89 d7                	mov    %edx,%edi
  8010c9:	51                   	push   %ecx
  8010ca:	52                   	push   %edx
  8010cb:	53                   	push   %ebx
  8010cc:	54                   	push   %esp
  8010cd:	55                   	push   %ebp
  8010ce:	56                   	push   %esi
  8010cf:	57                   	push   %edi
  8010d0:	54                   	push   %esp
  8010d1:	5d                   	pop    %ebp
  8010d2:	8d 35 da 10 80 00    	lea    0x8010da,%esi
  8010d8:	0f 34                	sysenter 
  8010da:	5f                   	pop    %edi
  8010db:	5e                   	pop    %esi
  8010dc:	5d                   	pop    %ebp
  8010dd:	5c                   	pop    %esp
  8010de:	5b                   	pop    %ebx
  8010df:	5a                   	pop    %edx
  8010e0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010e1:	8b 1c 24             	mov    (%esp),%ebx
  8010e4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010e8:	89 ec                	mov    %ebp,%esp
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	89 1c 24             	mov    %ebx,(%esp)
  8010f5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801101:	8b 55 08             	mov    0x8(%ebp),%edx
  801104:	89 c3                	mov    %eax,%ebx
  801106:	89 c7                	mov    %eax,%edi
  801108:	51                   	push   %ecx
  801109:	52                   	push   %edx
  80110a:	53                   	push   %ebx
  80110b:	54                   	push   %esp
  80110c:	55                   	push   %ebp
  80110d:	56                   	push   %esi
  80110e:	57                   	push   %edi
  80110f:	54                   	push   %esp
  801110:	5d                   	pop    %ebp
  801111:	8d 35 19 11 80 00    	lea    0x801119,%esi
  801117:	0f 34                	sysenter 
  801119:	5f                   	pop    %edi
  80111a:	5e                   	pop    %esi
  80111b:	5d                   	pop    %ebp
  80111c:	5c                   	pop    %esp
  80111d:	5b                   	pop    %ebx
  80111e:	5a                   	pop    %edx
  80111f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801120:	8b 1c 24             	mov    (%esp),%ebx
  801123:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801127:	89 ec                	mov    %ebp,%esp
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	83 ec 28             	sub    $0x28,%esp
  801131:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801134:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801137:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	89 df                	mov    %ebx,%edi
  801149:	51                   	push   %ecx
  80114a:	52                   	push   %edx
  80114b:	53                   	push   %ebx
  80114c:	54                   	push   %esp
  80114d:	55                   	push   %ebp
  80114e:	56                   	push   %esi
  80114f:	57                   	push   %edi
  801150:	54                   	push   %esp
  801151:	5d                   	pop    %ebp
  801152:	8d 35 5a 11 80 00    	lea    0x80115a,%esi
  801158:	0f 34                	sysenter 
  80115a:	5f                   	pop    %edi
  80115b:	5e                   	pop    %esi
  80115c:	5d                   	pop    %ebp
  80115d:	5c                   	pop    %esp
  80115e:	5b                   	pop    %ebx
  80115f:	5a                   	pop    %edx
  801160:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801161:	85 c0                	test   %eax,%eax
  801163:	7e 28                	jle    80118d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801165:	89 44 24 10          	mov    %eax,0x10(%esp)
  801169:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801170:	00 
  801171:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  801178:	00 
  801179:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801180:	00 
  801181:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  801188:	e8 2b f1 ff ff       	call   8002b8 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80118d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801190:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801193:	89 ec                	mov    %ebp,%esp
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	83 ec 08             	sub    $0x8,%esp
  80119d:	89 1c 24             	mov    %ebx,(%esp)
  8011a0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	89 cb                	mov    %ecx,%ebx
  8011b3:	89 cf                	mov    %ecx,%edi
  8011b5:	51                   	push   %ecx
  8011b6:	52                   	push   %edx
  8011b7:	53                   	push   %ebx
  8011b8:	54                   	push   %esp
  8011b9:	55                   	push   %ebp
  8011ba:	56                   	push   %esi
  8011bb:	57                   	push   %edi
  8011bc:	54                   	push   %esp
  8011bd:	5d                   	pop    %ebp
  8011be:	8d 35 c6 11 80 00    	lea    0x8011c6,%esi
  8011c4:	0f 34                	sysenter 
  8011c6:	5f                   	pop    %edi
  8011c7:	5e                   	pop    %esi
  8011c8:	5d                   	pop    %ebp
  8011c9:	5c                   	pop    %esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5a                   	pop    %edx
  8011cc:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011cd:	8b 1c 24             	mov    (%esp),%ebx
  8011d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011d4:	89 ec                	mov    %ebp,%esp
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 28             	sub    $0x28,%esp
  8011de:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8011e1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f1:	89 cb                	mov    %ecx,%ebx
  8011f3:	89 cf                	mov    %ecx,%edi
  8011f5:	51                   	push   %ecx
  8011f6:	52                   	push   %edx
  8011f7:	53                   	push   %ebx
  8011f8:	54                   	push   %esp
  8011f9:	55                   	push   %ebp
  8011fa:	56                   	push   %esi
  8011fb:	57                   	push   %edi
  8011fc:	54                   	push   %esp
  8011fd:	5d                   	pop    %ebp
  8011fe:	8d 35 06 12 80 00    	lea    0x801206,%esi
  801204:	0f 34                	sysenter 
  801206:	5f                   	pop    %edi
  801207:	5e                   	pop    %esi
  801208:	5d                   	pop    %ebp
  801209:	5c                   	pop    %esp
  80120a:	5b                   	pop    %ebx
  80120b:	5a                   	pop    %edx
  80120c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80120d:	85 c0                	test   %eax,%eax
  80120f:	7e 28                	jle    801239 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801211:	89 44 24 10          	mov    %eax,0x10(%esp)
  801215:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80121c:	00 
  80121d:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  801224:	00 
  801225:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80122c:	00 
  80122d:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  801234:	e8 7f f0 ff ff       	call   8002b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801239:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80123c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80123f:	89 ec                	mov    %ebp,%esp
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	89 1c 24             	mov    %ebx,(%esp)
  80124c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801250:	b8 0c 00 00 00       	mov    $0xc,%eax
  801255:	8b 7d 14             	mov    0x14(%ebp),%edi
  801258:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125e:	8b 55 08             	mov    0x8(%ebp),%edx
  801261:	51                   	push   %ecx
  801262:	52                   	push   %edx
  801263:	53                   	push   %ebx
  801264:	54                   	push   %esp
  801265:	55                   	push   %ebp
  801266:	56                   	push   %esi
  801267:	57                   	push   %edi
  801268:	54                   	push   %esp
  801269:	5d                   	pop    %ebp
  80126a:	8d 35 72 12 80 00    	lea    0x801272,%esi
  801270:	0f 34                	sysenter 
  801272:	5f                   	pop    %edi
  801273:	5e                   	pop    %esi
  801274:	5d                   	pop    %ebp
  801275:	5c                   	pop    %esp
  801276:	5b                   	pop    %ebx
  801277:	5a                   	pop    %edx
  801278:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801279:	8b 1c 24             	mov    (%esp),%ebx
  80127c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801280:	89 ec                	mov    %ebp,%esp
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	83 ec 28             	sub    $0x28,%esp
  80128a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80128d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801290:	bb 00 00 00 00       	mov    $0x0,%ebx
  801295:	b8 0a 00 00 00       	mov    $0xa,%eax
  80129a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129d:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a0:	89 df                	mov    %ebx,%edi
  8012a2:	51                   	push   %ecx
  8012a3:	52                   	push   %edx
  8012a4:	53                   	push   %ebx
  8012a5:	54                   	push   %esp
  8012a6:	55                   	push   %ebp
  8012a7:	56                   	push   %esi
  8012a8:	57                   	push   %edi
  8012a9:	54                   	push   %esp
  8012aa:	5d                   	pop    %ebp
  8012ab:	8d 35 b3 12 80 00    	lea    0x8012b3,%esi
  8012b1:	0f 34                	sysenter 
  8012b3:	5f                   	pop    %edi
  8012b4:	5e                   	pop    %esi
  8012b5:	5d                   	pop    %ebp
  8012b6:	5c                   	pop    %esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5a                   	pop    %edx
  8012b9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	7e 28                	jle    8012e6 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c2:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012c9:	00 
  8012ca:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  8012d1:	00 
  8012d2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012d9:	00 
  8012da:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  8012e1:	e8 d2 ef ff ff       	call   8002b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ec:	89 ec                	mov    %ebp,%esp
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 28             	sub    $0x28,%esp
  8012f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012f9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801301:	b8 09 00 00 00       	mov    $0x9,%eax
  801306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801309:	8b 55 08             	mov    0x8(%ebp),%edx
  80130c:	89 df                	mov    %ebx,%edi
  80130e:	51                   	push   %ecx
  80130f:	52                   	push   %edx
  801310:	53                   	push   %ebx
  801311:	54                   	push   %esp
  801312:	55                   	push   %ebp
  801313:	56                   	push   %esi
  801314:	57                   	push   %edi
  801315:	54                   	push   %esp
  801316:	5d                   	pop    %ebp
  801317:	8d 35 1f 13 80 00    	lea    0x80131f,%esi
  80131d:	0f 34                	sysenter 
  80131f:	5f                   	pop    %edi
  801320:	5e                   	pop    %esi
  801321:	5d                   	pop    %ebp
  801322:	5c                   	pop    %esp
  801323:	5b                   	pop    %ebx
  801324:	5a                   	pop    %edx
  801325:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801326:	85 c0                	test   %eax,%eax
  801328:	7e 28                	jle    801352 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80132a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80132e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801335:	00 
  801336:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  80133d:	00 
  80133e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801345:	00 
  801346:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  80134d:	e8 66 ef ff ff       	call   8002b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801352:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801355:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801358:	89 ec                	mov    %ebp,%esp
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 28             	sub    $0x28,%esp
  801362:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801365:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801368:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136d:	b8 07 00 00 00       	mov    $0x7,%eax
  801372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801375:	8b 55 08             	mov    0x8(%ebp),%edx
  801378:	89 df                	mov    %ebx,%edi
  80137a:	51                   	push   %ecx
  80137b:	52                   	push   %edx
  80137c:	53                   	push   %ebx
  80137d:	54                   	push   %esp
  80137e:	55                   	push   %ebp
  80137f:	56                   	push   %esi
  801380:	57                   	push   %edi
  801381:	54                   	push   %esp
  801382:	5d                   	pop    %ebp
  801383:	8d 35 8b 13 80 00    	lea    0x80138b,%esi
  801389:	0f 34                	sysenter 
  80138b:	5f                   	pop    %edi
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	5c                   	pop    %esp
  80138f:	5b                   	pop    %ebx
  801390:	5a                   	pop    %edx
  801391:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801392:	85 c0                	test   %eax,%eax
  801394:	7e 28                	jle    8013be <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801396:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013a1:	00 
  8013a2:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  8013a9:	00 
  8013aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013b1:	00 
  8013b2:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  8013b9:	e8 fa ee ff ff       	call   8002b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013c4:	89 ec                	mov    %ebp,%esp
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 28             	sub    $0x28,%esp
  8013ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013d1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013d4:	8b 7d 18             	mov    0x18(%ebp),%edi
  8013d7:	0b 7d 14             	or     0x14(%ebp),%edi
  8013da:	b8 06 00 00 00       	mov    $0x6,%eax
  8013df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e8:	51                   	push   %ecx
  8013e9:	52                   	push   %edx
  8013ea:	53                   	push   %ebx
  8013eb:	54                   	push   %esp
  8013ec:	55                   	push   %ebp
  8013ed:	56                   	push   %esi
  8013ee:	57                   	push   %edi
  8013ef:	54                   	push   %esp
  8013f0:	5d                   	pop    %ebp
  8013f1:	8d 35 f9 13 80 00    	lea    0x8013f9,%esi
  8013f7:	0f 34                	sysenter 
  8013f9:	5f                   	pop    %edi
  8013fa:	5e                   	pop    %esi
  8013fb:	5d                   	pop    %ebp
  8013fc:	5c                   	pop    %esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5a                   	pop    %edx
  8013ff:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801400:	85 c0                	test   %eax,%eax
  801402:	7e 28                	jle    80142c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  801404:	89 44 24 10          	mov    %eax,0x10(%esp)
  801408:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80140f:	00 
  801410:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  801417:	00 
  801418:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80141f:	00 
  801420:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  801427:	e8 8c ee ff ff       	call   8002b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80142c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80142f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801432:	89 ec                	mov    %ebp,%esp
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 28             	sub    $0x28,%esp
  80143c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80143f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801442:	bf 00 00 00 00       	mov    $0x0,%edi
  801447:	b8 05 00 00 00       	mov    $0x5,%eax
  80144c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80144f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801452:	8b 55 08             	mov    0x8(%ebp),%edx
  801455:	51                   	push   %ecx
  801456:	52                   	push   %edx
  801457:	53                   	push   %ebx
  801458:	54                   	push   %esp
  801459:	55                   	push   %ebp
  80145a:	56                   	push   %esi
  80145b:	57                   	push   %edi
  80145c:	54                   	push   %esp
  80145d:	5d                   	pop    %ebp
  80145e:	8d 35 66 14 80 00    	lea    0x801466,%esi
  801464:	0f 34                	sysenter 
  801466:	5f                   	pop    %edi
  801467:	5e                   	pop    %esi
  801468:	5d                   	pop    %ebp
  801469:	5c                   	pop    %esp
  80146a:	5b                   	pop    %ebx
  80146b:	5a                   	pop    %edx
  80146c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80146d:	85 c0                	test   %eax,%eax
  80146f:	7e 28                	jle    801499 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801471:	89 44 24 10          	mov    %eax,0x10(%esp)
  801475:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80147c:	00 
  80147d:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  801484:	00 
  801485:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80148c:	00 
  80148d:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  801494:	e8 1f ee ff ff       	call   8002b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801499:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80149c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80149f:	89 ec                	mov    %ebp,%esp
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	89 1c 24             	mov    %ebx,(%esp)
  8014ac:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014ba:	89 d1                	mov    %edx,%ecx
  8014bc:	89 d3                	mov    %edx,%ebx
  8014be:	89 d7                	mov    %edx,%edi
  8014c0:	51                   	push   %ecx
  8014c1:	52                   	push   %edx
  8014c2:	53                   	push   %ebx
  8014c3:	54                   	push   %esp
  8014c4:	55                   	push   %ebp
  8014c5:	56                   	push   %esi
  8014c6:	57                   	push   %edi
  8014c7:	54                   	push   %esp
  8014c8:	5d                   	pop    %ebp
  8014c9:	8d 35 d1 14 80 00    	lea    0x8014d1,%esi
  8014cf:	0f 34                	sysenter 
  8014d1:	5f                   	pop    %edi
  8014d2:	5e                   	pop    %esi
  8014d3:	5d                   	pop    %ebp
  8014d4:	5c                   	pop    %esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5a                   	pop    %edx
  8014d7:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8014d8:	8b 1c 24             	mov    (%esp),%ebx
  8014db:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014df:	89 ec                	mov    %ebp,%esp
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	89 1c 24             	mov    %ebx,(%esp)
  8014ec:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f5:	b8 04 00 00 00       	mov    $0x4,%eax
  8014fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801500:	89 df                	mov    %ebx,%edi
  801502:	51                   	push   %ecx
  801503:	52                   	push   %edx
  801504:	53                   	push   %ebx
  801505:	54                   	push   %esp
  801506:	55                   	push   %ebp
  801507:	56                   	push   %esi
  801508:	57                   	push   %edi
  801509:	54                   	push   %esp
  80150a:	5d                   	pop    %ebp
  80150b:	8d 35 13 15 80 00    	lea    0x801513,%esi
  801511:	0f 34                	sysenter 
  801513:	5f                   	pop    %edi
  801514:	5e                   	pop    %esi
  801515:	5d                   	pop    %ebp
  801516:	5c                   	pop    %esp
  801517:	5b                   	pop    %ebx
  801518:	5a                   	pop    %edx
  801519:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80151a:	8b 1c 24             	mov    (%esp),%ebx
  80151d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801521:	89 ec                	mov    %ebp,%esp
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	89 1c 24             	mov    %ebx,(%esp)
  80152e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801532:	ba 00 00 00 00       	mov    $0x0,%edx
  801537:	b8 02 00 00 00       	mov    $0x2,%eax
  80153c:	89 d1                	mov    %edx,%ecx
  80153e:	89 d3                	mov    %edx,%ebx
  801540:	89 d7                	mov    %edx,%edi
  801542:	51                   	push   %ecx
  801543:	52                   	push   %edx
  801544:	53                   	push   %ebx
  801545:	54                   	push   %esp
  801546:	55                   	push   %ebp
  801547:	56                   	push   %esi
  801548:	57                   	push   %edi
  801549:	54                   	push   %esp
  80154a:	5d                   	pop    %ebp
  80154b:	8d 35 53 15 80 00    	lea    0x801553,%esi
  801551:	0f 34                	sysenter 
  801553:	5f                   	pop    %edi
  801554:	5e                   	pop    %esi
  801555:	5d                   	pop    %ebp
  801556:	5c                   	pop    %esp
  801557:	5b                   	pop    %ebx
  801558:	5a                   	pop    %edx
  801559:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80155a:	8b 1c 24             	mov    (%esp),%ebx
  80155d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801561:	89 ec                	mov    %ebp,%esp
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 28             	sub    $0x28,%esp
  80156b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80156e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801571:	b9 00 00 00 00       	mov    $0x0,%ecx
  801576:	b8 03 00 00 00       	mov    $0x3,%eax
  80157b:	8b 55 08             	mov    0x8(%ebp),%edx
  80157e:	89 cb                	mov    %ecx,%ebx
  801580:	89 cf                	mov    %ecx,%edi
  801582:	51                   	push   %ecx
  801583:	52                   	push   %edx
  801584:	53                   	push   %ebx
  801585:	54                   	push   %esp
  801586:	55                   	push   %ebp
  801587:	56                   	push   %esi
  801588:	57                   	push   %edi
  801589:	54                   	push   %esp
  80158a:	5d                   	pop    %ebp
  80158b:	8d 35 93 15 80 00    	lea    0x801593,%esi
  801591:	0f 34                	sysenter 
  801593:	5f                   	pop    %edi
  801594:	5e                   	pop    %esi
  801595:	5d                   	pop    %ebp
  801596:	5c                   	pop    %esp
  801597:	5b                   	pop    %ebx
  801598:	5a                   	pop    %edx
  801599:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80159a:	85 c0                	test   %eax,%eax
  80159c:	7e 28                	jle    8015c6 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80159e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8015a9:	00 
  8015aa:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  8015b1:	00 
  8015b2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015b9:	00 
  8015ba:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  8015c1:	e8 f2 ec ff ff       	call   8002b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015c6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015cc:	89 ec                	mov    %ebp,%esp
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <__udivdi3>:
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	57                   	push   %edi
  8015d4:	56                   	push   %esi
  8015d5:	83 ec 10             	sub    $0x10,%esp
  8015d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015db:	8b 55 08             	mov    0x8(%ebp),%edx
  8015de:	8b 75 10             	mov    0x10(%ebp),%esi
  8015e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8015e9:	75 35                	jne    801620 <__udivdi3+0x50>
  8015eb:	39 fe                	cmp    %edi,%esi
  8015ed:	77 61                	ja     801650 <__udivdi3+0x80>
  8015ef:	85 f6                	test   %esi,%esi
  8015f1:	75 0b                	jne    8015fe <__udivdi3+0x2e>
  8015f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f8:	31 d2                	xor    %edx,%edx
  8015fa:	f7 f6                	div    %esi
  8015fc:	89 c6                	mov    %eax,%esi
  8015fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801601:	31 d2                	xor    %edx,%edx
  801603:	89 f8                	mov    %edi,%eax
  801605:	f7 f6                	div    %esi
  801607:	89 c7                	mov    %eax,%edi
  801609:	89 c8                	mov    %ecx,%eax
  80160b:	f7 f6                	div    %esi
  80160d:	89 c1                	mov    %eax,%ecx
  80160f:	89 fa                	mov    %edi,%edx
  801611:	89 c8                	mov    %ecx,%eax
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    
  80161a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801620:	39 f8                	cmp    %edi,%eax
  801622:	77 1c                	ja     801640 <__udivdi3+0x70>
  801624:	0f bd d0             	bsr    %eax,%edx
  801627:	83 f2 1f             	xor    $0x1f,%edx
  80162a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80162d:	75 39                	jne    801668 <__udivdi3+0x98>
  80162f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801632:	0f 86 a0 00 00 00    	jbe    8016d8 <__udivdi3+0x108>
  801638:	39 f8                	cmp    %edi,%eax
  80163a:	0f 82 98 00 00 00    	jb     8016d8 <__udivdi3+0x108>
  801640:	31 ff                	xor    %edi,%edi
  801642:	31 c9                	xor    %ecx,%ecx
  801644:	89 c8                	mov    %ecx,%eax
  801646:	89 fa                	mov    %edi,%edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	5e                   	pop    %esi
  80164c:	5f                   	pop    %edi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    
  80164f:	90                   	nop
  801650:	89 d1                	mov    %edx,%ecx
  801652:	89 fa                	mov    %edi,%edx
  801654:	89 c8                	mov    %ecx,%eax
  801656:	31 ff                	xor    %edi,%edi
  801658:	f7 f6                	div    %esi
  80165a:	89 c1                	mov    %eax,%ecx
  80165c:	89 fa                	mov    %edi,%edx
  80165e:	89 c8                	mov    %ecx,%eax
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	5e                   	pop    %esi
  801664:	5f                   	pop    %edi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    
  801667:	90                   	nop
  801668:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80166c:	89 f2                	mov    %esi,%edx
  80166e:	d3 e0                	shl    %cl,%eax
  801670:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801673:	b8 20 00 00 00       	mov    $0x20,%eax
  801678:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80167b:	89 c1                	mov    %eax,%ecx
  80167d:	d3 ea                	shr    %cl,%edx
  80167f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801683:	0b 55 ec             	or     -0x14(%ebp),%edx
  801686:	d3 e6                	shl    %cl,%esi
  801688:	89 c1                	mov    %eax,%ecx
  80168a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80168d:	89 fe                	mov    %edi,%esi
  80168f:	d3 ee                	shr    %cl,%esi
  801691:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801695:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801698:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80169b:	d3 e7                	shl    %cl,%edi
  80169d:	89 c1                	mov    %eax,%ecx
  80169f:	d3 ea                	shr    %cl,%edx
  8016a1:	09 d7                	or     %edx,%edi
  8016a3:	89 f2                	mov    %esi,%edx
  8016a5:	89 f8                	mov    %edi,%eax
  8016a7:	f7 75 ec             	divl   -0x14(%ebp)
  8016aa:	89 d6                	mov    %edx,%esi
  8016ac:	89 c7                	mov    %eax,%edi
  8016ae:	f7 65 e8             	mull   -0x18(%ebp)
  8016b1:	39 d6                	cmp    %edx,%esi
  8016b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8016b6:	72 30                	jb     8016e8 <__udivdi3+0x118>
  8016b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8016bf:	d3 e2                	shl    %cl,%edx
  8016c1:	39 c2                	cmp    %eax,%edx
  8016c3:	73 05                	jae    8016ca <__udivdi3+0xfa>
  8016c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8016c8:	74 1e                	je     8016e8 <__udivdi3+0x118>
  8016ca:	89 f9                	mov    %edi,%ecx
  8016cc:	31 ff                	xor    %edi,%edi
  8016ce:	e9 71 ff ff ff       	jmp    801644 <__udivdi3+0x74>
  8016d3:	90                   	nop
  8016d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016d8:	31 ff                	xor    %edi,%edi
  8016da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8016df:	e9 60 ff ff ff       	jmp    801644 <__udivdi3+0x74>
  8016e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8016eb:	31 ff                	xor    %edi,%edi
  8016ed:	89 c8                	mov    %ecx,%eax
  8016ef:	89 fa                	mov    %edi,%edx
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	5e                   	pop    %esi
  8016f5:	5f                   	pop    %edi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    
	...

00801700 <__umoddi3>:
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	83 ec 20             	sub    $0x20,%esp
  801708:	8b 55 14             	mov    0x14(%ebp),%edx
  80170b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801711:	8b 75 0c             	mov    0xc(%ebp),%esi
  801714:	85 d2                	test   %edx,%edx
  801716:	89 c8                	mov    %ecx,%eax
  801718:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80171b:	75 13                	jne    801730 <__umoddi3+0x30>
  80171d:	39 f7                	cmp    %esi,%edi
  80171f:	76 3f                	jbe    801760 <__umoddi3+0x60>
  801721:	89 f2                	mov    %esi,%edx
  801723:	f7 f7                	div    %edi
  801725:	89 d0                	mov    %edx,%eax
  801727:	31 d2                	xor    %edx,%edx
  801729:	83 c4 20             	add    $0x20,%esp
  80172c:	5e                   	pop    %esi
  80172d:	5f                   	pop    %edi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    
  801730:	39 f2                	cmp    %esi,%edx
  801732:	77 4c                	ja     801780 <__umoddi3+0x80>
  801734:	0f bd ca             	bsr    %edx,%ecx
  801737:	83 f1 1f             	xor    $0x1f,%ecx
  80173a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80173d:	75 51                	jne    801790 <__umoddi3+0x90>
  80173f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801742:	0f 87 e0 00 00 00    	ja     801828 <__umoddi3+0x128>
  801748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174b:	29 f8                	sub    %edi,%eax
  80174d:	19 d6                	sbb    %edx,%esi
  80174f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801755:	89 f2                	mov    %esi,%edx
  801757:	83 c4 20             	add    $0x20,%esp
  80175a:	5e                   	pop    %esi
  80175b:	5f                   	pop    %edi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    
  80175e:	66 90                	xchg   %ax,%ax
  801760:	85 ff                	test   %edi,%edi
  801762:	75 0b                	jne    80176f <__umoddi3+0x6f>
  801764:	b8 01 00 00 00       	mov    $0x1,%eax
  801769:	31 d2                	xor    %edx,%edx
  80176b:	f7 f7                	div    %edi
  80176d:	89 c7                	mov    %eax,%edi
  80176f:	89 f0                	mov    %esi,%eax
  801771:	31 d2                	xor    %edx,%edx
  801773:	f7 f7                	div    %edi
  801775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801778:	f7 f7                	div    %edi
  80177a:	eb a9                	jmp    801725 <__umoddi3+0x25>
  80177c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801780:	89 c8                	mov    %ecx,%eax
  801782:	89 f2                	mov    %esi,%edx
  801784:	83 c4 20             	add    $0x20,%esp
  801787:	5e                   	pop    %esi
  801788:	5f                   	pop    %edi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    
  80178b:	90                   	nop
  80178c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801790:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801794:	d3 e2                	shl    %cl,%edx
  801796:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801799:	ba 20 00 00 00       	mov    $0x20,%edx
  80179e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8017a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8017a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8017a8:	89 fa                	mov    %edi,%edx
  8017aa:	d3 ea                	shr    %cl,%edx
  8017ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8017b3:	d3 e7                	shl    %cl,%edi
  8017b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8017b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8017bc:	89 f2                	mov    %esi,%edx
  8017be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8017c1:	89 c7                	mov    %eax,%edi
  8017c3:	d3 ea                	shr    %cl,%edx
  8017c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8017cc:	89 c2                	mov    %eax,%edx
  8017ce:	d3 e6                	shl    %cl,%esi
  8017d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8017d4:	d3 ea                	shr    %cl,%edx
  8017d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017da:	09 d6                	or     %edx,%esi
  8017dc:	89 f0                	mov    %esi,%eax
  8017de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8017e1:	d3 e7                	shl    %cl,%edi
  8017e3:	89 f2                	mov    %esi,%edx
  8017e5:	f7 75 f4             	divl   -0xc(%ebp)
  8017e8:	89 d6                	mov    %edx,%esi
  8017ea:	f7 65 e8             	mull   -0x18(%ebp)
  8017ed:	39 d6                	cmp    %edx,%esi
  8017ef:	72 2b                	jb     80181c <__umoddi3+0x11c>
  8017f1:	39 c7                	cmp    %eax,%edi
  8017f3:	72 23                	jb     801818 <__umoddi3+0x118>
  8017f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017f9:	29 c7                	sub    %eax,%edi
  8017fb:	19 d6                	sbb    %edx,%esi
  8017fd:	89 f0                	mov    %esi,%eax
  8017ff:	89 f2                	mov    %esi,%edx
  801801:	d3 ef                	shr    %cl,%edi
  801803:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801807:	d3 e0                	shl    %cl,%eax
  801809:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80180d:	09 f8                	or     %edi,%eax
  80180f:	d3 ea                	shr    %cl,%edx
  801811:	83 c4 20             	add    $0x20,%esp
  801814:	5e                   	pop    %esi
  801815:	5f                   	pop    %edi
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    
  801818:	39 d6                	cmp    %edx,%esi
  80181a:	75 d9                	jne    8017f5 <__umoddi3+0xf5>
  80181c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80181f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801822:	eb d1                	jmp    8017f5 <__umoddi3+0xf5>
  801824:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801828:	39 f2                	cmp    %esi,%edx
  80182a:	0f 82 18 ff ff ff    	jb     801748 <__umoddi3+0x48>
  801830:	e9 1d ff ff ff       	jmp    801752 <__umoddi3+0x52>
