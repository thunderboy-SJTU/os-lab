
obj/user/dumbfork.debug:     file format elf32-i386


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
  800051:	e8 7d 14 00 00       	call   8014d3 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 00 23 80 	movl   $0x802300,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  800075:	e8 46 02 00 00       	call   8002c0 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 c7 13 00 00       	call   801465 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 23 23 80 	movl   $0x802323,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  8000bd:	e8 fe 01 00 00       	call   8002c0 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 bb 0d 00 00       	call   800e95 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 0b 13 00 00       	call   8013f9 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 34 23 80 	movl   $0x802334,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  80010d:	e8 ae 01 00 00       	call   8002c0 <_panic>
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
  800133:	c7 44 24 08 47 23 80 	movl   $0x802347,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  80014a:	e8 71 01 00 00       	call   8002c0 <_panic>
	if (envid == 0) {
  80014f:	85 c0                	test   %eax,%eax
  800151:	75 1d                	jne    800170 <dumbfork+0x57>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800153:	e8 6a 14 00 00       	call   8015c2 <sys_getenvid>
  800158:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015d:	89 c2                	mov    %eax,%edx
  80015f:	c1 e2 07             	shl    $0x7,%edx
  800162:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800169:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80016e:	eb 7e                	jmp    8001ee <dumbfork+0xd5>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800170:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800177:	b8 00 60 80 00       	mov    $0x806000,%eax
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
  80019f:	3d 00 60 80 00       	cmp    $0x806000,%eax
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
  8001c5:	e8 c3 11 00 00       	call   80138d <sys_env_set_status>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <dumbfork+0xd5>
		panic("sys_env_set_status: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 57 23 80 	movl   $0x802357,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  8001e9:	e8 d2 00 00 00       	call   8002c0 <_panic>

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
  80020b:	bf 74 23 80 00       	mov    $0x802374,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800210:	eb 27                	jmp    800239 <umain+0x43>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800212:	89 f8                	mov    %edi,%eax
  800214:	85 f6                	test   %esi,%esi
  800216:	75 05                	jne    80021d <umain+0x27>
  800218:	b8 6e 23 80 00       	mov    $0x80236e,%eax
  80021d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800221:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800225:	c7 04 24 7b 23 80 00 	movl   $0x80237b,(%esp)
  80022c:	e8 48 01 00 00       	call   800379 <cprintf>
		sys_yield();
  800231:	e8 0a 13 00 00       	call   801540 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800236:	83 c3 01             	add    $0x1,%ebx
  800239:	83 fe 01             	cmp    $0x1,%esi
  80023c:	19 c0                	sbb    %eax,%eax
  80023e:	83 e0 0a             	and    $0xa,%eax
  800241:	83 c0 0a             	add    $0xa,%eax
  800244:	39 c3                	cmp    %eax,%ebx
  800246:	7c ca                	jl     800212 <umain+0x1c>
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
  800262:	e8 5b 13 00 00       	call   8015c2 <sys_getenvid>
  800267:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026c:	89 c2                	mov    %eax,%edx
  80026e:	c1 e2 07             	shl    $0x7,%edx
  800271:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800278:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80027d:	85 f6                	test   %esi,%esi
  80027f:	7e 07                	jle    800288 <libmain+0x38>
		binaryname = argv[0];
  800281:	8b 03                	mov    (%ebx),%eax
  800283:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8002aa:	e8 9c 18 00 00       	call   801b4b <close_all>
	sys_env_destroy(0);
  8002af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b6:	e8 47 13 00 00       	call   801602 <sys_env_destroy>
}
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    
  8002bd:	00 00                	add    %al,(%eax)
	...

008002c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8002c8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002d1:	e8 ec 12 00 00       	call   8015c2 <sys_getenvid>
  8002d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ec:	c7 04 24 98 23 80 00 	movl   $0x802398,(%esp)
  8002f3:	e8 81 00 00 00       	call   800379 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	e8 11 00 00 00       	call   800318 <vcprintf>
	cprintf("\n");
  800307:	c7 04 24 8b 23 80 00 	movl   $0x80238b,(%esp)
  80030e:	e8 66 00 00 00       	call   800379 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800313:	cc                   	int3   
  800314:	eb fd                	jmp    800313 <_panic+0x53>
	...

00800318 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800321:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800328:	00 00 00 
	b.cnt = 0;
  80032b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800332:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800335:	8b 45 0c             	mov    0xc(%ebp),%eax
  800338:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034d:	c7 04 24 93 03 80 00 	movl   $0x800393,(%esp)
  800354:	e8 d3 01 00 00       	call   80052c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800359:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80035f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800363:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800369:	89 04 24             	mov    %eax,(%esp)
  80036c:	e8 6b 0d 00 00       	call   8010dc <sys_cputs>

	return b.cnt;
}
  800371:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800377:	c9                   	leave  
  800378:	c3                   	ret    

00800379 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80037f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800382:	89 44 24 04          	mov    %eax,0x4(%esp)
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
  800389:	89 04 24             	mov    %eax,(%esp)
  80038c:	e8 87 ff ff ff       	call   800318 <vcprintf>
	va_end(ap);

	return cnt;
}
  800391:	c9                   	leave  
  800392:	c3                   	ret    

00800393 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	53                   	push   %ebx
  800397:	83 ec 14             	sub    $0x14,%esp
  80039a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039d:	8b 03                	mov    (%ebx),%eax
  80039f:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003a6:	83 c0 01             	add    $0x1,%eax
  8003a9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b0:	75 19                	jne    8003cb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003b2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003b9:	00 
  8003ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8003bd:	89 04 24             	mov    %eax,(%esp)
  8003c0:	e8 17 0d 00 00       	call   8010dc <sys_cputs>
		b->idx = 0;
  8003c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003cf:	83 c4 14             	add    $0x14,%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    
	...

008003e0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 4c             	sub    $0x4c,%esp
  8003e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ec:	89 d6                	mov    %edx,%esi
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800400:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800403:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800406:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040b:	39 d1                	cmp    %edx,%ecx
  80040d:	72 07                	jb     800416 <printnum_v2+0x36>
  80040f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800412:	39 d0                	cmp    %edx,%eax
  800414:	77 5f                	ja     800475 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800416:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80041a:	83 eb 01             	sub    $0x1,%ebx
  80041d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800421:	89 44 24 08          	mov    %eax,0x8(%esp)
  800425:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800429:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80042d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800430:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800433:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800436:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80043a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800441:	00 
  800442:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800445:	89 04 24             	mov    %eax,(%esp)
  800448:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80044b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80044f:	e8 2c 1c 00 00       	call   802080 <__udivdi3>
  800454:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800457:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80045a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80045e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800462:	89 04 24             	mov    %eax,(%esp)
  800465:	89 54 24 04          	mov    %edx,0x4(%esp)
  800469:	89 f2                	mov    %esi,%edx
  80046b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046e:	e8 6d ff ff ff       	call   8003e0 <printnum_v2>
  800473:	eb 1e                	jmp    800493 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800475:	83 ff 2d             	cmp    $0x2d,%edi
  800478:	74 19                	je     800493 <printnum_v2+0xb3>
		while (--width > 0)
  80047a:	83 eb 01             	sub    $0x1,%ebx
  80047d:	85 db                	test   %ebx,%ebx
  80047f:	90                   	nop
  800480:	7e 11                	jle    800493 <printnum_v2+0xb3>
			putch(padc, putdat);
  800482:	89 74 24 04          	mov    %esi,0x4(%esp)
  800486:	89 3c 24             	mov    %edi,(%esp)
  800489:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80048c:	83 eb 01             	sub    $0x1,%ebx
  80048f:	85 db                	test   %ebx,%ebx
  800491:	7f ef                	jg     800482 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800493:	89 74 24 04          	mov    %esi,0x4(%esp)
  800497:	8b 74 24 04          	mov    0x4(%esp),%esi
  80049b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80049e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004a9:	00 
  8004aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ad:	89 14 24             	mov    %edx,(%esp)
  8004b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b7:	e8 f4 1c 00 00       	call   8021b0 <__umoddi3>
  8004bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c0:	0f be 80 bb 23 80 00 	movsbl 0x8023bb(%eax),%eax
  8004c7:	89 04 24             	mov    %eax,(%esp)
  8004ca:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004cd:	83 c4 4c             	add    $0x4c,%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5f                   	pop    %edi
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d8:	83 fa 01             	cmp    $0x1,%edx
  8004db:	7e 0e                	jle    8004eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e2:	89 08                	mov    %ecx,(%eax)
  8004e4:	8b 02                	mov    (%edx),%eax
  8004e6:	8b 52 04             	mov    0x4(%edx),%edx
  8004e9:	eb 22                	jmp    80050d <getuint+0x38>
	else if (lflag)
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	74 10                	je     8004ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 02                	mov    (%edx),%eax
  8004f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fd:	eb 0e                	jmp    80050d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ff:	8b 10                	mov    (%eax),%edx
  800501:	8d 4a 04             	lea    0x4(%edx),%ecx
  800504:	89 08                	mov    %ecx,(%eax)
  800506:	8b 02                	mov    (%edx),%eax
  800508:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    

0080050f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800515:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800519:	8b 10                	mov    (%eax),%edx
  80051b:	3b 50 04             	cmp    0x4(%eax),%edx
  80051e:	73 0a                	jae    80052a <sprintputch+0x1b>
		*b->buf++ = ch;
  800520:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800523:	88 0a                	mov    %cl,(%edx)
  800525:	83 c2 01             	add    $0x1,%edx
  800528:	89 10                	mov    %edx,(%eax)
}
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	57                   	push   %edi
  800530:	56                   	push   %esi
  800531:	53                   	push   %ebx
  800532:	83 ec 6c             	sub    $0x6c,%esp
  800535:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800538:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80053f:	eb 1a                	jmp    80055b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800541:	85 c0                	test   %eax,%eax
  800543:	0f 84 66 06 00 00    	je     800baf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800549:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	eb 03                	jmp    80055b <vprintfmt+0x2f>
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055b:	0f b6 07             	movzbl (%edi),%eax
  80055e:	83 c7 01             	add    $0x1,%edi
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 db                	jne    800541 <vprintfmt+0x15>
  800566:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80056a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800576:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80057b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800582:	be 00 00 00 00       	mov    $0x0,%esi
  800587:	eb 06                	jmp    80058f <vprintfmt+0x63>
  800589:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80058d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	0f b6 17             	movzbl (%edi),%edx
  800592:	0f b6 c2             	movzbl %dl,%eax
  800595:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800598:	8d 47 01             	lea    0x1(%edi),%eax
  80059b:	83 ea 23             	sub    $0x23,%edx
  80059e:	80 fa 55             	cmp    $0x55,%dl
  8005a1:	0f 87 60 05 00 00    	ja     800b07 <vprintfmt+0x5db>
  8005a7:	0f b6 d2             	movzbl %dl,%edx
  8005aa:	ff 24 95 a0 25 80 00 	jmp    *0x8025a0(,%edx,4)
  8005b1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8005b6:	eb d5                	jmp    80058d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005bb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8005be:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005c1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8005c4:	83 ff 09             	cmp    $0x9,%edi
  8005c7:	76 08                	jbe    8005d1 <vprintfmt+0xa5>
  8005c9:	eb 40                	jmp    80060b <vprintfmt+0xdf>
  8005cb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8005cf:	eb bc                	jmp    80058d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005d4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8005d7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8005db:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005de:	8d 7a d0             	lea    -0x30(%edx),%edi
  8005e1:	83 ff 09             	cmp    $0x9,%edi
  8005e4:	76 eb                	jbe    8005d1 <vprintfmt+0xa5>
  8005e6:	eb 23                	jmp    80060b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8005eb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8005ee:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8005f1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8005f3:	eb 16                	jmp    80060b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8005f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f8:	c1 fa 1f             	sar    $0x1f,%edx
  8005fb:	f7 d2                	not    %edx
  8005fd:	21 55 d8             	and    %edx,-0x28(%ebp)
  800600:	eb 8b                	jmp    80058d <vprintfmt+0x61>
  800602:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800609:	eb 82                	jmp    80058d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80060b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060f:	0f 89 78 ff ff ff    	jns    80058d <vprintfmt+0x61>
  800615:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800618:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80061b:	e9 6d ff ff ff       	jmp    80058d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800620:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800623:	e9 65 ff ff ff       	jmp    80058d <vprintfmt+0x61>
  800628:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 55 0c             	mov    0xc(%ebp),%edx
  800637:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 04 24             	mov    %eax,(%esp)
  800640:	ff 55 08             	call   *0x8(%ebp)
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800646:	e9 10 ff ff ff       	jmp    80055b <vprintfmt+0x2f>
  80064b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 00                	mov    (%eax),%eax
  800659:	89 c2                	mov    %eax,%edx
  80065b:	c1 fa 1f             	sar    $0x1f,%edx
  80065e:	31 d0                	xor    %edx,%eax
  800660:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800662:	83 f8 0f             	cmp    $0xf,%eax
  800665:	7f 0b                	jg     800672 <vprintfmt+0x146>
  800667:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  80066e:	85 d2                	test   %edx,%edx
  800670:	75 26                	jne    800698 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800672:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800676:	c7 44 24 08 cc 23 80 	movl   $0x8023cc,0x8(%esp)
  80067d:	00 
  80067e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800681:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800685:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800688:	89 1c 24             	mov    %ebx,(%esp)
  80068b:	e8 a7 05 00 00       	call   800c37 <printfmt>
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800693:	e9 c3 fe ff ff       	jmp    80055b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800698:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069c:	c7 44 24 08 d5 23 80 	movl   $0x8023d5,0x8(%esp)
  8006a3:	00 
  8006a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ae:	89 14 24             	mov    %edx,(%esp)
  8006b1:	e8 81 05 00 00       	call   800c37 <printfmt>
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	e9 9d fe ff ff       	jmp    80055b <vprintfmt+0x2f>
  8006be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c1:	89 c7                	mov    %eax,%edi
  8006c3:	89 d9                	mov    %ebx,%ecx
  8006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 30                	mov    (%eax),%esi
  8006d6:	85 f6                	test   %esi,%esi
  8006d8:	75 05                	jne    8006df <vprintfmt+0x1b3>
  8006da:	be d8 23 80 00       	mov    $0x8023d8,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8006df:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8006e3:	7e 06                	jle    8006eb <vprintfmt+0x1bf>
  8006e5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8006e9:	75 10                	jne    8006fb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006eb:	0f be 06             	movsbl (%esi),%eax
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	0f 85 a2 00 00 00    	jne    800798 <vprintfmt+0x26c>
  8006f6:	e9 92 00 00 00       	jmp    80078d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ff:	89 34 24             	mov    %esi,(%esp)
  800702:	e8 74 05 00 00       	call   800c7b <strnlen>
  800707:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80070a:	29 c2                	sub    %eax,%edx
  80070c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80070f:	85 d2                	test   %edx,%edx
  800711:	7e d8                	jle    8006eb <vprintfmt+0x1bf>
					putch(padc, putdat);
  800713:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800717:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80071a:	89 d3                	mov    %edx,%ebx
  80071c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80071f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800722:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800725:	89 ce                	mov    %ecx,%esi
  800727:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80072b:	89 34 24             	mov    %esi,(%esp)
  80072e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800731:	83 eb 01             	sub    $0x1,%ebx
  800734:	85 db                	test   %ebx,%ebx
  800736:	7f ef                	jg     800727 <vprintfmt+0x1fb>
  800738:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80073b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80073e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800741:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800748:	eb a1                	jmp    8006eb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80074a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80074e:	74 1b                	je     80076b <vprintfmt+0x23f>
  800750:	8d 50 e0             	lea    -0x20(%eax),%edx
  800753:	83 fa 5e             	cmp    $0x5e,%edx
  800756:	76 13                	jbe    80076b <vprintfmt+0x23f>
					putch('?', putdat);
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800766:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800769:	eb 0d                	jmp    800778 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800772:	89 04 24             	mov    %eax,(%esp)
  800775:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800778:	83 ef 01             	sub    $0x1,%edi
  80077b:	0f be 06             	movsbl (%esi),%eax
  80077e:	85 c0                	test   %eax,%eax
  800780:	74 05                	je     800787 <vprintfmt+0x25b>
  800782:	83 c6 01             	add    $0x1,%esi
  800785:	eb 1a                	jmp    8007a1 <vprintfmt+0x275>
  800787:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80078a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800791:	7f 1f                	jg     8007b2 <vprintfmt+0x286>
  800793:	e9 c0 fd ff ff       	jmp    800558 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800798:	83 c6 01             	add    $0x1,%esi
  80079b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80079e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007a1:	85 db                	test   %ebx,%ebx
  8007a3:	78 a5                	js     80074a <vprintfmt+0x21e>
  8007a5:	83 eb 01             	sub    $0x1,%ebx
  8007a8:	79 a0                	jns    80074a <vprintfmt+0x21e>
  8007aa:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8007ad:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007b0:	eb db                	jmp    80078d <vprintfmt+0x261>
  8007b2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007b8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8007bb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cb:	83 eb 01             	sub    $0x1,%ebx
  8007ce:	85 db                	test   %ebx,%ebx
  8007d0:	7f ec                	jg     8007be <vprintfmt+0x292>
  8007d2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007d5:	e9 81 fd ff ff       	jmp    80055b <vprintfmt+0x2f>
  8007da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007dd:	83 fe 01             	cmp    $0x1,%esi
  8007e0:	7e 10                	jle    8007f2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 08             	lea    0x8(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007eb:	8b 18                	mov    (%eax),%ebx
  8007ed:	8b 70 04             	mov    0x4(%eax),%esi
  8007f0:	eb 26                	jmp    800818 <vprintfmt+0x2ec>
	else if (lflag)
  8007f2:	85 f6                	test   %esi,%esi
  8007f4:	74 12                	je     800808 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 04             	lea    0x4(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	8b 18                	mov    (%eax),%ebx
  800801:	89 de                	mov    %ebx,%esi
  800803:	c1 fe 1f             	sar    $0x1f,%esi
  800806:	eb 10                	jmp    800818 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8d 50 04             	lea    0x4(%eax),%edx
  80080e:	89 55 14             	mov    %edx,0x14(%ebp)
  800811:	8b 18                	mov    (%eax),%ebx
  800813:	89 de                	mov    %ebx,%esi
  800815:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800818:	83 f9 01             	cmp    $0x1,%ecx
  80081b:	75 1e                	jne    80083b <vprintfmt+0x30f>
                               if((long long)num > 0){
  80081d:	85 f6                	test   %esi,%esi
  80081f:	78 1a                	js     80083b <vprintfmt+0x30f>
  800821:	85 f6                	test   %esi,%esi
  800823:	7f 05                	jg     80082a <vprintfmt+0x2fe>
  800825:	83 fb 00             	cmp    $0x0,%ebx
  800828:	76 11                	jbe    80083b <vprintfmt+0x30f>
                                   putch('+',putdat);
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800831:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800838:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80083b:	85 f6                	test   %esi,%esi
  80083d:	78 13                	js     800852 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80083f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800842:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800845:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800848:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084d:	e9 da 00 00 00       	jmp    80092c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800852:	8b 45 0c             	mov    0xc(%ebp),%eax
  800855:	89 44 24 04          	mov    %eax,0x4(%esp)
  800859:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800860:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800863:	89 da                	mov    %ebx,%edx
  800865:	89 f1                	mov    %esi,%ecx
  800867:	f7 da                	neg    %edx
  800869:	83 d1 00             	adc    $0x0,%ecx
  80086c:	f7 d9                	neg    %ecx
  80086e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800871:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800874:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800877:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087c:	e9 ab 00 00 00       	jmp    80092c <vprintfmt+0x400>
  800881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800884:	89 f2                	mov    %esi,%edx
  800886:	8d 45 14             	lea    0x14(%ebp),%eax
  800889:	e8 47 fc ff ff       	call   8004d5 <getuint>
  80088e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800891:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800897:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80089c:	e9 8b 00 00 00       	jmp    80092c <vprintfmt+0x400>
  8008a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8008a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008ab:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008b2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  8008b5:	89 f2                	mov    %esi,%edx
  8008b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ba:	e8 16 fc ff ff       	call   8004d5 <getuint>
  8008bf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8008c2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8008c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  8008cd:	eb 5d                	jmp    80092c <vprintfmt+0x400>
  8008cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8008d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008ee:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8008f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f4:	8d 50 04             	lea    0x4(%eax),%edx
  8008f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fa:	8b 10                	mov    (%eax),%edx
  8008fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800901:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800904:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800907:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80090a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80090f:	eb 1b                	jmp    80092c <vprintfmt+0x400>
  800911:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800914:	89 f2                	mov    %esi,%edx
  800916:	8d 45 14             	lea    0x14(%ebp),%eax
  800919:	e8 b7 fb ff ff       	call   8004d5 <getuint>
  80091e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800921:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800924:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800927:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80092c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800930:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800933:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800936:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80093a:	77 09                	ja     800945 <vprintfmt+0x419>
  80093c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80093f:	0f 82 ac 00 00 00    	jb     8009f1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800945:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800948:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80094c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80094f:	83 ea 01             	sub    $0x1,%edx
  800952:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800956:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80095e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800962:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800965:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800968:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80096b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80096f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800976:	00 
  800977:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80097a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80097d:	89 0c 24             	mov    %ecx,(%esp)
  800980:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800984:	e8 f7 16 00 00       	call   802080 <__udivdi3>
  800989:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80098c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80098f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800993:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800997:	89 04 24             	mov    %eax,(%esp)
  80099a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	e8 37 fa ff ff       	call   8003e0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b0:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009b4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009c2:	00 
  8009c3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8009c6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  8009c9:	89 14 24             	mov    %edx,(%esp)
  8009cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009d0:	e8 db 17 00 00       	call   8021b0 <__umoddi3>
  8009d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009d9:	0f be 80 bb 23 80 00 	movsbl 0x8023bb(%eax),%eax
  8009e0:	89 04 24             	mov    %eax,(%esp)
  8009e3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8009e6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8009ea:	74 54                	je     800a40 <vprintfmt+0x514>
  8009ec:	e9 67 fb ff ff       	jmp    800558 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8009f1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8009f5:	8d 76 00             	lea    0x0(%esi),%esi
  8009f8:	0f 84 2a 01 00 00    	je     800b28 <vprintfmt+0x5fc>
		while (--width > 0)
  8009fe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a01:	83 ef 01             	sub    $0x1,%edi
  800a04:	85 ff                	test   %edi,%edi
  800a06:	0f 8e 5e 01 00 00    	jle    800b6a <vprintfmt+0x63e>
  800a0c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800a0f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800a12:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800a15:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800a18:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a1b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800a1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a22:	89 1c 24             	mov    %ebx,(%esp)
  800a25:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800a28:	83 ef 01             	sub    $0x1,%edi
  800a2b:	85 ff                	test   %edi,%edi
  800a2d:	7f ef                	jg     800a1e <vprintfmt+0x4f2>
  800a2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a32:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a35:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800a38:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800a3b:	e9 2a 01 00 00       	jmp    800b6a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800a40:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800a43:	83 eb 01             	sub    $0x1,%ebx
  800a46:	85 db                	test   %ebx,%ebx
  800a48:	0f 8e 0a fb ff ff    	jle    800558 <vprintfmt+0x2c>
  800a4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a51:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800a54:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800a57:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a5b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a62:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800a64:	83 eb 01             	sub    $0x1,%ebx
  800a67:	85 db                	test   %ebx,%ebx
  800a69:	7f ec                	jg     800a57 <vprintfmt+0x52b>
  800a6b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a6e:	e9 e8 fa ff ff       	jmp    80055b <vprintfmt+0x2f>
  800a73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800a76:	8b 45 14             	mov    0x14(%ebp),%eax
  800a79:	8d 50 04             	lea    0x4(%eax),%edx
  800a7c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a7f:	8b 00                	mov    (%eax),%eax
  800a81:	85 c0                	test   %eax,%eax
  800a83:	75 2a                	jne    800aaf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800a85:	c7 44 24 0c f4 24 80 	movl   $0x8024f4,0xc(%esp)
  800a8c:	00 
  800a8d:	c7 44 24 08 d5 23 80 	movl   $0x8023d5,0x8(%esp)
  800a94:	00 
  800a95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a98:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9f:	89 0c 24             	mov    %ecx,(%esp)
  800aa2:	e8 90 01 00 00       	call   800c37 <printfmt>
  800aa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aaa:	e9 ac fa ff ff       	jmp    80055b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab2:	8b 13                	mov    (%ebx),%edx
  800ab4:	83 fa 7f             	cmp    $0x7f,%edx
  800ab7:	7e 29                	jle    800ae2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800ab9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800abb:	c7 44 24 0c 2c 25 80 	movl   $0x80252c,0xc(%esp)
  800ac2:	00 
  800ac3:	c7 44 24 08 d5 23 80 	movl   $0x8023d5,0x8(%esp)
  800aca:	00 
  800acb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	89 04 24             	mov    %eax,(%esp)
  800ad5:	e8 5d 01 00 00       	call   800c37 <printfmt>
  800ada:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800add:	e9 79 fa ff ff       	jmp    80055b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800ae2:	88 10                	mov    %dl,(%eax)
  800ae4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ae7:	e9 6f fa ff ff       	jmp    80055b <vprintfmt+0x2f>
  800aec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800af9:	89 14 24             	mov    %edx,(%esp)
  800afc:	ff 55 08             	call   *0x8(%ebp)
  800aff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800b02:	e9 54 fa ff ff       	jmp    80055b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b0e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b15:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b18:	8d 47 ff             	lea    -0x1(%edi),%eax
  800b1b:	80 38 25             	cmpb   $0x25,(%eax)
  800b1e:	0f 84 37 fa ff ff    	je     80055b <vprintfmt+0x2f>
  800b24:	89 c7                	mov    %eax,%edi
  800b26:	eb f0                	jmp    800b18 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b33:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b36:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b41:	00 
  800b42:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800b45:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800b48:	89 04 24             	mov    %eax,(%esp)
  800b4b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b4f:	e8 5c 16 00 00       	call   8021b0 <__umoddi3>
  800b54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b58:	0f be 80 bb 23 80 00 	movsbl 0x8023bb(%eax),%eax
  800b5f:	89 04 24             	mov    %eax,(%esp)
  800b62:	ff 55 08             	call   *0x8(%ebp)
  800b65:	e9 d6 fe ff ff       	jmp    800a40 <vprintfmt+0x514>
  800b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b71:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b75:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b7c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b83:	00 
  800b84:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800b87:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800b8a:	89 04 24             	mov    %eax,(%esp)
  800b8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b91:	e8 1a 16 00 00       	call   8021b0 <__umoddi3>
  800b96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b9a:	0f be 80 bb 23 80 00 	movsbl 0x8023bb(%eax),%eax
  800ba1:	89 04 24             	mov    %eax,(%esp)
  800ba4:	ff 55 08             	call   *0x8(%ebp)
  800ba7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800baa:	e9 ac f9 ff ff       	jmp    80055b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800baf:	83 c4 6c             	add    $0x6c,%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 28             	sub    $0x28,%esp
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	74 04                	je     800bcb <vsnprintf+0x14>
  800bc7:	85 d2                	test   %edx,%edx
  800bc9:	7f 07                	jg     800bd2 <vsnprintf+0x1b>
  800bcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bd0:	eb 3b                	jmp    800c0d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bd5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800be3:	8b 45 14             	mov    0x14(%ebp),%eax
  800be6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bea:	8b 45 10             	mov    0x10(%ebp),%eax
  800bed:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf8:	c7 04 24 0f 05 80 00 	movl   $0x80050f,(%esp)
  800bff:	e8 28 f9 ff ff       	call   80052c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800c15:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800c18:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	89 04 24             	mov    %eax,(%esp)
  800c30:	e8 82 ff ff ff       	call   800bb7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800c3d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800c40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c44:	8b 45 10             	mov    0x10(%ebp),%eax
  800c47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	89 04 24             	mov    %eax,(%esp)
  800c58:	e8 cf f8 ff ff       	call   80052c <vprintfmt>
	va_end(ap);
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    
	...

00800c60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c6e:	74 09                	je     800c79 <strlen+0x19>
		n++;
  800c70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c77:	75 f7                	jne    800c70 <strlen+0x10>
		n++;
	return n;
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c85:	85 c9                	test   %ecx,%ecx
  800c87:	74 19                	je     800ca2 <strnlen+0x27>
  800c89:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c8c:	74 14                	je     800ca2 <strnlen+0x27>
  800c8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800c93:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c96:	39 c8                	cmp    %ecx,%eax
  800c98:	74 0d                	je     800ca7 <strnlen+0x2c>
  800c9a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800c9e:	75 f3                	jne    800c93 <strnlen+0x18>
  800ca0:	eb 05                	jmp    800ca7 <strnlen+0x2c>
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	53                   	push   %ebx
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cb4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cbd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800cc0:	83 c2 01             	add    $0x1,%edx
  800cc3:	84 c9                	test   %cl,%cl
  800cc5:	75 f2                	jne    800cb9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 08             	sub    $0x8,%esp
  800cd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cd4:	89 1c 24             	mov    %ebx,(%esp)
  800cd7:	e8 84 ff ff ff       	call   800c60 <strlen>
	strcpy(dst + len, src);
  800cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cdf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ce3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800ce6:	89 04 24             	mov    %eax,(%esp)
  800ce9:	e8 bc ff ff ff       	call   800caa <strcpy>
	return dst;
}
  800cee:	89 d8                	mov    %ebx,%eax
  800cf0:	83 c4 08             	add    $0x8,%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d04:	85 f6                	test   %esi,%esi
  800d06:	74 18                	je     800d20 <strncpy+0x2a>
  800d08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d0d:	0f b6 1a             	movzbl (%edx),%ebx
  800d10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d13:	80 3a 01             	cmpb   $0x1,(%edx)
  800d16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d19:	83 c1 01             	add    $0x1,%ecx
  800d1c:	39 ce                	cmp    %ecx,%esi
  800d1e:	77 ed                	ja     800d0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	8b 75 08             	mov    0x8(%ebp),%esi
  800d2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d32:	89 f0                	mov    %esi,%eax
  800d34:	85 c9                	test   %ecx,%ecx
  800d36:	74 27                	je     800d5f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800d38:	83 e9 01             	sub    $0x1,%ecx
  800d3b:	74 1d                	je     800d5a <strlcpy+0x36>
  800d3d:	0f b6 1a             	movzbl (%edx),%ebx
  800d40:	84 db                	test   %bl,%bl
  800d42:	74 16                	je     800d5a <strlcpy+0x36>
			*dst++ = *src++;
  800d44:	88 18                	mov    %bl,(%eax)
  800d46:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d49:	83 e9 01             	sub    $0x1,%ecx
  800d4c:	74 0e                	je     800d5c <strlcpy+0x38>
			*dst++ = *src++;
  800d4e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d51:	0f b6 1a             	movzbl (%edx),%ebx
  800d54:	84 db                	test   %bl,%bl
  800d56:	75 ec                	jne    800d44 <strlcpy+0x20>
  800d58:	eb 02                	jmp    800d5c <strlcpy+0x38>
  800d5a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d5c:	c6 00 00             	movb   $0x0,(%eax)
  800d5f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d6e:	0f b6 01             	movzbl (%ecx),%eax
  800d71:	84 c0                	test   %al,%al
  800d73:	74 15                	je     800d8a <strcmp+0x25>
  800d75:	3a 02                	cmp    (%edx),%al
  800d77:	75 11                	jne    800d8a <strcmp+0x25>
		p++, q++;
  800d79:	83 c1 01             	add    $0x1,%ecx
  800d7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d7f:	0f b6 01             	movzbl (%ecx),%eax
  800d82:	84 c0                	test   %al,%al
  800d84:	74 04                	je     800d8a <strcmp+0x25>
  800d86:	3a 02                	cmp    (%edx),%al
  800d88:	74 ef                	je     800d79 <strcmp+0x14>
  800d8a:	0f b6 c0             	movzbl %al,%eax
  800d8d:	0f b6 12             	movzbl (%edx),%edx
  800d90:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	53                   	push   %ebx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	74 23                	je     800dc8 <strncmp+0x34>
  800da5:	0f b6 1a             	movzbl (%edx),%ebx
  800da8:	84 db                	test   %bl,%bl
  800daa:	74 25                	je     800dd1 <strncmp+0x3d>
  800dac:	3a 19                	cmp    (%ecx),%bl
  800dae:	75 21                	jne    800dd1 <strncmp+0x3d>
  800db0:	83 e8 01             	sub    $0x1,%eax
  800db3:	74 13                	je     800dc8 <strncmp+0x34>
		n--, p++, q++;
  800db5:	83 c2 01             	add    $0x1,%edx
  800db8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dbb:	0f b6 1a             	movzbl (%edx),%ebx
  800dbe:	84 db                	test   %bl,%bl
  800dc0:	74 0f                	je     800dd1 <strncmp+0x3d>
  800dc2:	3a 19                	cmp    (%ecx),%bl
  800dc4:	74 ea                	je     800db0 <strncmp+0x1c>
  800dc6:	eb 09                	jmp    800dd1 <strncmp+0x3d>
  800dc8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dcd:	5b                   	pop    %ebx
  800dce:	5d                   	pop    %ebp
  800dcf:	90                   	nop
  800dd0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dd1:	0f b6 02             	movzbl (%edx),%eax
  800dd4:	0f b6 11             	movzbl (%ecx),%edx
  800dd7:	29 d0                	sub    %edx,%eax
  800dd9:	eb f2                	jmp    800dcd <strncmp+0x39>

00800ddb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
  800de1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de5:	0f b6 10             	movzbl (%eax),%edx
  800de8:	84 d2                	test   %dl,%dl
  800dea:	74 18                	je     800e04 <strchr+0x29>
		if (*s == c)
  800dec:	38 ca                	cmp    %cl,%dl
  800dee:	75 0a                	jne    800dfa <strchr+0x1f>
  800df0:	eb 17                	jmp    800e09 <strchr+0x2e>
  800df2:	38 ca                	cmp    %cl,%dl
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	74 0f                	je     800e09 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfa:	83 c0 01             	add    $0x1,%eax
  800dfd:	0f b6 10             	movzbl (%eax),%edx
  800e00:	84 d2                	test   %dl,%dl
  800e02:	75 ee                	jne    800df2 <strchr+0x17>
  800e04:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e15:	0f b6 10             	movzbl (%eax),%edx
  800e18:	84 d2                	test   %dl,%dl
  800e1a:	74 18                	je     800e34 <strfind+0x29>
		if (*s == c)
  800e1c:	38 ca                	cmp    %cl,%dl
  800e1e:	75 0a                	jne    800e2a <strfind+0x1f>
  800e20:	eb 12                	jmp    800e34 <strfind+0x29>
  800e22:	38 ca                	cmp    %cl,%dl
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	74 0a                	je     800e34 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e2a:	83 c0 01             	add    $0x1,%eax
  800e2d:	0f b6 10             	movzbl (%eax),%edx
  800e30:	84 d2                	test   %dl,%dl
  800e32:	75 ee                	jne    800e22 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	83 ec 0c             	sub    $0xc,%esp
  800e3c:	89 1c 24             	mov    %ebx,(%esp)
  800e3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e47:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e50:	85 c9                	test   %ecx,%ecx
  800e52:	74 30                	je     800e84 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e5a:	75 25                	jne    800e81 <memset+0x4b>
  800e5c:	f6 c1 03             	test   $0x3,%cl
  800e5f:	75 20                	jne    800e81 <memset+0x4b>
		c &= 0xFF;
  800e61:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e64:	89 d3                	mov    %edx,%ebx
  800e66:	c1 e3 08             	shl    $0x8,%ebx
  800e69:	89 d6                	mov    %edx,%esi
  800e6b:	c1 e6 18             	shl    $0x18,%esi
  800e6e:	89 d0                	mov    %edx,%eax
  800e70:	c1 e0 10             	shl    $0x10,%eax
  800e73:	09 f0                	or     %esi,%eax
  800e75:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800e77:	09 d8                	or     %ebx,%eax
  800e79:	c1 e9 02             	shr    $0x2,%ecx
  800e7c:	fc                   	cld    
  800e7d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e7f:	eb 03                	jmp    800e84 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e81:	fc                   	cld    
  800e82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e84:	89 f8                	mov    %edi,%eax
  800e86:	8b 1c 24             	mov    (%esp),%ebx
  800e89:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e91:	89 ec                	mov    %ebp,%esp
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	89 34 24             	mov    %esi,(%esp)
  800e9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ea8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800eab:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ead:	39 c6                	cmp    %eax,%esi
  800eaf:	73 35                	jae    800ee6 <memmove+0x51>
  800eb1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eb4:	39 d0                	cmp    %edx,%eax
  800eb6:	73 2e                	jae    800ee6 <memmove+0x51>
		s += n;
		d += n;
  800eb8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eba:	f6 c2 03             	test   $0x3,%dl
  800ebd:	75 1b                	jne    800eda <memmove+0x45>
  800ebf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ec5:	75 13                	jne    800eda <memmove+0x45>
  800ec7:	f6 c1 03             	test   $0x3,%cl
  800eca:	75 0e                	jne    800eda <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ecc:	83 ef 04             	sub    $0x4,%edi
  800ecf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ed2:	c1 e9 02             	shr    $0x2,%ecx
  800ed5:	fd                   	std    
  800ed6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed8:	eb 09                	jmp    800ee3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eda:	83 ef 01             	sub    $0x1,%edi
  800edd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ee0:	fd                   	std    
  800ee1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ee3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ee4:	eb 20                	jmp    800f06 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eec:	75 15                	jne    800f03 <memmove+0x6e>
  800eee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ef4:	75 0d                	jne    800f03 <memmove+0x6e>
  800ef6:	f6 c1 03             	test   $0x3,%cl
  800ef9:	75 08                	jne    800f03 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800efb:	c1 e9 02             	shr    $0x2,%ecx
  800efe:	fc                   	cld    
  800eff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f01:	eb 03                	jmp    800f06 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f03:	fc                   	cld    
  800f04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f06:	8b 34 24             	mov    (%esp),%esi
  800f09:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f0d:	89 ec                	mov    %ebp,%esp
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f17:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
  800f28:	89 04 24             	mov    %eax,(%esp)
  800f2b:	e8 65 ff ff ff       	call   800e95 <memmove>
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f41:	85 c9                	test   %ecx,%ecx
  800f43:	74 36                	je     800f7b <memcmp+0x49>
		if (*s1 != *s2)
  800f45:	0f b6 06             	movzbl (%esi),%eax
  800f48:	0f b6 1f             	movzbl (%edi),%ebx
  800f4b:	38 d8                	cmp    %bl,%al
  800f4d:	74 20                	je     800f6f <memcmp+0x3d>
  800f4f:	eb 14                	jmp    800f65 <memcmp+0x33>
  800f51:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800f56:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800f5b:	83 c2 01             	add    $0x1,%edx
  800f5e:	83 e9 01             	sub    $0x1,%ecx
  800f61:	38 d8                	cmp    %bl,%al
  800f63:	74 12                	je     800f77 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800f65:	0f b6 c0             	movzbl %al,%eax
  800f68:	0f b6 db             	movzbl %bl,%ebx
  800f6b:	29 d8                	sub    %ebx,%eax
  800f6d:	eb 11                	jmp    800f80 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f6f:	83 e9 01             	sub    $0x1,%ecx
  800f72:	ba 00 00 00 00       	mov    $0x0,%edx
  800f77:	85 c9                	test   %ecx,%ecx
  800f79:	75 d6                	jne    800f51 <memcmp+0x1f>
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f8b:	89 c2                	mov    %eax,%edx
  800f8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f90:	39 d0                	cmp    %edx,%eax
  800f92:	73 15                	jae    800fa9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f98:	38 08                	cmp    %cl,(%eax)
  800f9a:	75 06                	jne    800fa2 <memfind+0x1d>
  800f9c:	eb 0b                	jmp    800fa9 <memfind+0x24>
  800f9e:	38 08                	cmp    %cl,(%eax)
  800fa0:	74 07                	je     800fa9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fa2:	83 c0 01             	add    $0x1,%eax
  800fa5:	39 c2                	cmp    %eax,%edx
  800fa7:	77 f5                	ja     800f9e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 04             	sub    $0x4,%esp
  800fb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fba:	0f b6 02             	movzbl (%edx),%eax
  800fbd:	3c 20                	cmp    $0x20,%al
  800fbf:	74 04                	je     800fc5 <strtol+0x1a>
  800fc1:	3c 09                	cmp    $0x9,%al
  800fc3:	75 0e                	jne    800fd3 <strtol+0x28>
		s++;
  800fc5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fc8:	0f b6 02             	movzbl (%edx),%eax
  800fcb:	3c 20                	cmp    $0x20,%al
  800fcd:	74 f6                	je     800fc5 <strtol+0x1a>
  800fcf:	3c 09                	cmp    $0x9,%al
  800fd1:	74 f2                	je     800fc5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fd3:	3c 2b                	cmp    $0x2b,%al
  800fd5:	75 0c                	jne    800fe3 <strtol+0x38>
		s++;
  800fd7:	83 c2 01             	add    $0x1,%edx
  800fda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800fe1:	eb 15                	jmp    800ff8 <strtol+0x4d>
	else if (*s == '-')
  800fe3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800fea:	3c 2d                	cmp    $0x2d,%al
  800fec:	75 0a                	jne    800ff8 <strtol+0x4d>
		s++, neg = 1;
  800fee:	83 c2 01             	add    $0x1,%edx
  800ff1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ff8:	85 db                	test   %ebx,%ebx
  800ffa:	0f 94 c0             	sete   %al
  800ffd:	74 05                	je     801004 <strtol+0x59>
  800fff:	83 fb 10             	cmp    $0x10,%ebx
  801002:	75 18                	jne    80101c <strtol+0x71>
  801004:	80 3a 30             	cmpb   $0x30,(%edx)
  801007:	75 13                	jne    80101c <strtol+0x71>
  801009:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	75 0a                	jne    80101c <strtol+0x71>
		s += 2, base = 16;
  801012:	83 c2 02             	add    $0x2,%edx
  801015:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80101a:	eb 15                	jmp    801031 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80101c:	84 c0                	test   %al,%al
  80101e:	66 90                	xchg   %ax,%ax
  801020:	74 0f                	je     801031 <strtol+0x86>
  801022:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801027:	80 3a 30             	cmpb   $0x30,(%edx)
  80102a:	75 05                	jne    801031 <strtol+0x86>
		s++, base = 8;
  80102c:	83 c2 01             	add    $0x1,%edx
  80102f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801031:	b8 00 00 00 00       	mov    $0x0,%eax
  801036:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801038:	0f b6 0a             	movzbl (%edx),%ecx
  80103b:	89 cf                	mov    %ecx,%edi
  80103d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801040:	80 fb 09             	cmp    $0x9,%bl
  801043:	77 08                	ja     80104d <strtol+0xa2>
			dig = *s - '0';
  801045:	0f be c9             	movsbl %cl,%ecx
  801048:	83 e9 30             	sub    $0x30,%ecx
  80104b:	eb 1e                	jmp    80106b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80104d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801050:	80 fb 19             	cmp    $0x19,%bl
  801053:	77 08                	ja     80105d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801055:	0f be c9             	movsbl %cl,%ecx
  801058:	83 e9 57             	sub    $0x57,%ecx
  80105b:	eb 0e                	jmp    80106b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80105d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801060:	80 fb 19             	cmp    $0x19,%bl
  801063:	77 15                	ja     80107a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801065:	0f be c9             	movsbl %cl,%ecx
  801068:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80106b:	39 f1                	cmp    %esi,%ecx
  80106d:	7d 0b                	jge    80107a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80106f:	83 c2 01             	add    $0x1,%edx
  801072:	0f af c6             	imul   %esi,%eax
  801075:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801078:	eb be                	jmp    801038 <strtol+0x8d>
  80107a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80107c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801080:	74 05                	je     801087 <strtol+0xdc>
		*endptr = (char *) s;
  801082:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801085:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801087:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80108b:	74 04                	je     801091 <strtol+0xe6>
  80108d:	89 c8                	mov    %ecx,%eax
  80108f:	f7 d8                	neg    %eax
}
  801091:	83 c4 04             	add    $0x4,%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    
  801099:	00 00                	add    %al,(%eax)
	...

0080109c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	89 1c 24             	mov    %ebx,(%esp)
  8010a5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b3:	89 d1                	mov    %edx,%ecx
  8010b5:	89 d3                	mov    %edx,%ebx
  8010b7:	89 d7                	mov    %edx,%edi
  8010b9:	51                   	push   %ecx
  8010ba:	52                   	push   %edx
  8010bb:	53                   	push   %ebx
  8010bc:	54                   	push   %esp
  8010bd:	55                   	push   %ebp
  8010be:	56                   	push   %esi
  8010bf:	57                   	push   %edi
  8010c0:	54                   	push   %esp
  8010c1:	5d                   	pop    %ebp
  8010c2:	8d 35 ca 10 80 00    	lea    0x8010ca,%esi
  8010c8:	0f 34                	sysenter 
  8010ca:	5f                   	pop    %edi
  8010cb:	5e                   	pop    %esi
  8010cc:	5d                   	pop    %ebp
  8010cd:	5c                   	pop    %esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5a                   	pop    %edx
  8010d0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010d1:	8b 1c 24             	mov    (%esp),%ebx
  8010d4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d8:	89 ec                	mov    %ebp,%esp
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	89 1c 24             	mov    %ebx,(%esp)
  8010e5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f4:	89 c3                	mov    %eax,%ebx
  8010f6:	89 c7                	mov    %eax,%edi
  8010f8:	51                   	push   %ecx
  8010f9:	52                   	push   %edx
  8010fa:	53                   	push   %ebx
  8010fb:	54                   	push   %esp
  8010fc:	55                   	push   %ebp
  8010fd:	56                   	push   %esi
  8010fe:	57                   	push   %edi
  8010ff:	54                   	push   %esp
  801100:	5d                   	pop    %ebp
  801101:	8d 35 09 11 80 00    	lea    0x801109,%esi
  801107:	0f 34                	sysenter 
  801109:	5f                   	pop    %edi
  80110a:	5e                   	pop    %esi
  80110b:	5d                   	pop    %ebp
  80110c:	5c                   	pop    %esp
  80110d:	5b                   	pop    %ebx
  80110e:	5a                   	pop    %edx
  80110f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801110:	8b 1c 24             	mov    (%esp),%ebx
  801113:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801117:	89 ec                	mov    %ebp,%esp
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	89 1c 24             	mov    %ebx,(%esp)
  801124:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801128:	b8 10 00 00 00       	mov    $0x10,%eax
  80112d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801130:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801133:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801136:	8b 55 08             	mov    0x8(%ebp),%edx
  801139:	51                   	push   %ecx
  80113a:	52                   	push   %edx
  80113b:	53                   	push   %ebx
  80113c:	54                   	push   %esp
  80113d:	55                   	push   %ebp
  80113e:	56                   	push   %esi
  80113f:	57                   	push   %edi
  801140:	54                   	push   %esp
  801141:	5d                   	pop    %ebp
  801142:	8d 35 4a 11 80 00    	lea    0x80114a,%esi
  801148:	0f 34                	sysenter 
  80114a:	5f                   	pop    %edi
  80114b:	5e                   	pop    %esi
  80114c:	5d                   	pop    %ebp
  80114d:	5c                   	pop    %esp
  80114e:	5b                   	pop    %ebx
  80114f:	5a                   	pop    %edx
  801150:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801151:	8b 1c 24             	mov    (%esp),%ebx
  801154:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801158:	89 ec                	mov    %ebp,%esp
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
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
  80116d:	b8 0f 00 00 00       	mov    $0xf,%eax
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
  801194:	7e 28                	jle    8011be <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801196:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119a:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011b1:	00 
  8011b2:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  8011b9:	e8 02 f1 ff ff       	call   8002c0 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8011be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8011c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011c4:	89 ec                	mov    %ebp,%esp
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	89 1c 24             	mov    %ebx,(%esp)
  8011d1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011da:	b8 11 00 00 00       	mov    $0x11,%eax
  8011df:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e2:	89 cb                	mov    %ecx,%ebx
  8011e4:	89 cf                	mov    %ecx,%edi
  8011e6:	51                   	push   %ecx
  8011e7:	52                   	push   %edx
  8011e8:	53                   	push   %ebx
  8011e9:	54                   	push   %esp
  8011ea:	55                   	push   %ebp
  8011eb:	56                   	push   %esi
  8011ec:	57                   	push   %edi
  8011ed:	54                   	push   %esp
  8011ee:	5d                   	pop    %ebp
  8011ef:	8d 35 f7 11 80 00    	lea    0x8011f7,%esi
  8011f5:	0f 34                	sysenter 
  8011f7:	5f                   	pop    %edi
  8011f8:	5e                   	pop    %esi
  8011f9:	5d                   	pop    %ebp
  8011fa:	5c                   	pop    %esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5a                   	pop    %edx
  8011fd:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011fe:	8b 1c 24             	mov    (%esp),%ebx
  801201:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801205:	89 ec                	mov    %ebp,%esp
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
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
  801215:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80121f:	8b 55 08             	mov    0x8(%ebp),%edx
  801222:	89 cb                	mov    %ecx,%ebx
  801224:	89 cf                	mov    %ecx,%edi
  801226:	51                   	push   %ecx
  801227:	52                   	push   %edx
  801228:	53                   	push   %ebx
  801229:	54                   	push   %esp
  80122a:	55                   	push   %ebp
  80122b:	56                   	push   %esi
  80122c:	57                   	push   %edi
  80122d:	54                   	push   %esp
  80122e:	5d                   	pop    %ebp
  80122f:	8d 35 37 12 80 00    	lea    0x801237,%esi
  801235:	0f 34                	sysenter 
  801237:	5f                   	pop    %edi
  801238:	5e                   	pop    %esi
  801239:	5d                   	pop    %ebp
  80123a:	5c                   	pop    %esp
  80123b:	5b                   	pop    %ebx
  80123c:	5a                   	pop    %edx
  80123d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80123e:	85 c0                	test   %eax,%eax
  801240:	7e 28                	jle    80126a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801242:	89 44 24 10          	mov    %eax,0x10(%esp)
  801246:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80124d:	00 
  80124e:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  801255:	00 
  801256:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80125d:	00 
  80125e:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  801265:	e8 56 f0 ff ff       	call   8002c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80126a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80126d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801270:	89 ec                	mov    %ebp,%esp
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	89 1c 24             	mov    %ebx,(%esp)
  80127d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801281:	b8 0d 00 00 00       	mov    $0xd,%eax
  801286:	8b 7d 14             	mov    0x14(%ebp),%edi
  801289:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128f:	8b 55 08             	mov    0x8(%ebp),%edx
  801292:	51                   	push   %ecx
  801293:	52                   	push   %edx
  801294:	53                   	push   %ebx
  801295:	54                   	push   %esp
  801296:	55                   	push   %ebp
  801297:	56                   	push   %esi
  801298:	57                   	push   %edi
  801299:	54                   	push   %esp
  80129a:	5d                   	pop    %ebp
  80129b:	8d 35 a3 12 80 00    	lea    0x8012a3,%esi
  8012a1:	0f 34                	sysenter 
  8012a3:	5f                   	pop    %edi
  8012a4:	5e                   	pop    %esi
  8012a5:	5d                   	pop    %ebp
  8012a6:	5c                   	pop    %esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5a                   	pop    %edx
  8012a9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012aa:	8b 1c 24             	mov    (%esp),%ebx
  8012ad:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012b1:	89 ec                	mov    %ebp,%esp
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 28             	sub    $0x28,%esp
  8012bb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012be:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d1:	89 df                	mov    %ebx,%edi
  8012d3:	51                   	push   %ecx
  8012d4:	52                   	push   %edx
  8012d5:	53                   	push   %ebx
  8012d6:	54                   	push   %esp
  8012d7:	55                   	push   %ebp
  8012d8:	56                   	push   %esi
  8012d9:	57                   	push   %edi
  8012da:	54                   	push   %esp
  8012db:	5d                   	pop    %ebp
  8012dc:	8d 35 e4 12 80 00    	lea    0x8012e4,%esi
  8012e2:	0f 34                	sysenter 
  8012e4:	5f                   	pop    %edi
  8012e5:	5e                   	pop    %esi
  8012e6:	5d                   	pop    %ebp
  8012e7:	5c                   	pop    %esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5a                   	pop    %edx
  8012ea:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	7e 28                	jle    801317 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f3:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8012fa:	00 
  8012fb:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  801302:	00 
  801303:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80130a:	00 
  80130b:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  801312:	e8 a9 ef ff ff       	call   8002c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801317:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80131a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80131d:	89 ec                	mov    %ebp,%esp
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    

00801321 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	83 ec 28             	sub    $0x28,%esp
  801327:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80132a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80132d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801332:	b8 0a 00 00 00       	mov    $0xa,%eax
  801337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133a:	8b 55 08             	mov    0x8(%ebp),%edx
  80133d:	89 df                	mov    %ebx,%edi
  80133f:	51                   	push   %ecx
  801340:	52                   	push   %edx
  801341:	53                   	push   %ebx
  801342:	54                   	push   %esp
  801343:	55                   	push   %ebp
  801344:	56                   	push   %esi
  801345:	57                   	push   %edi
  801346:	54                   	push   %esp
  801347:	5d                   	pop    %ebp
  801348:	8d 35 50 13 80 00    	lea    0x801350,%esi
  80134e:	0f 34                	sysenter 
  801350:	5f                   	pop    %edi
  801351:	5e                   	pop    %esi
  801352:	5d                   	pop    %ebp
  801353:	5c                   	pop    %esp
  801354:	5b                   	pop    %ebx
  801355:	5a                   	pop    %edx
  801356:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801357:	85 c0                	test   %eax,%eax
  801359:	7e 28                	jle    801383 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801366:	00 
  801367:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  80137e:	e8 3d ef ff ff       	call   8002c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801383:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801386:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801389:	89 ec                	mov    %ebp,%esp
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	83 ec 28             	sub    $0x28,%esp
  801393:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801396:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801399:	bb 00 00 00 00       	mov    $0x0,%ebx
  80139e:	b8 09 00 00 00       	mov    $0x9,%eax
  8013a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a9:	89 df                	mov    %ebx,%edi
  8013ab:	51                   	push   %ecx
  8013ac:	52                   	push   %edx
  8013ad:	53                   	push   %ebx
  8013ae:	54                   	push   %esp
  8013af:	55                   	push   %ebp
  8013b0:	56                   	push   %esi
  8013b1:	57                   	push   %edi
  8013b2:	54                   	push   %esp
  8013b3:	5d                   	pop    %ebp
  8013b4:	8d 35 bc 13 80 00    	lea    0x8013bc,%esi
  8013ba:	0f 34                	sysenter 
  8013bc:	5f                   	pop    %edi
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	5c                   	pop    %esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5a                   	pop    %edx
  8013c2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	7e 28                	jle    8013ef <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013cb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013d2:	00 
  8013d3:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  8013da:	00 
  8013db:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013e2:	00 
  8013e3:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  8013ea:	e8 d1 ee ff ff       	call   8002c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8013f2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013f5:	89 ec                	mov    %ebp,%esp
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	83 ec 28             	sub    $0x28,%esp
  8013ff:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801402:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140a:	b8 07 00 00 00       	mov    $0x7,%eax
  80140f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801412:	8b 55 08             	mov    0x8(%ebp),%edx
  801415:	89 df                	mov    %ebx,%edi
  801417:	51                   	push   %ecx
  801418:	52                   	push   %edx
  801419:	53                   	push   %ebx
  80141a:	54                   	push   %esp
  80141b:	55                   	push   %ebp
  80141c:	56                   	push   %esi
  80141d:	57                   	push   %edi
  80141e:	54                   	push   %esp
  80141f:	5d                   	pop    %ebp
  801420:	8d 35 28 14 80 00    	lea    0x801428,%esi
  801426:	0f 34                	sysenter 
  801428:	5f                   	pop    %edi
  801429:	5e                   	pop    %esi
  80142a:	5d                   	pop    %ebp
  80142b:	5c                   	pop    %esp
  80142c:	5b                   	pop    %ebx
  80142d:	5a                   	pop    %edx
  80142e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80142f:	85 c0                	test   %eax,%eax
  801431:	7e 28                	jle    80145b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801433:	89 44 24 10          	mov    %eax,0x10(%esp)
  801437:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80143e:	00 
  80143f:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  801446:	00 
  801447:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80144e:	00 
  80144f:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  801456:	e8 65 ee ff ff       	call   8002c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80145b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80145e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801461:	89 ec                	mov    %ebp,%esp
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 28             	sub    $0x28,%esp
  80146b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80146e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801471:	8b 7d 18             	mov    0x18(%ebp),%edi
  801474:	0b 7d 14             	or     0x14(%ebp),%edi
  801477:	b8 06 00 00 00       	mov    $0x6,%eax
  80147c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80147f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801482:	8b 55 08             	mov    0x8(%ebp),%edx
  801485:	51                   	push   %ecx
  801486:	52                   	push   %edx
  801487:	53                   	push   %ebx
  801488:	54                   	push   %esp
  801489:	55                   	push   %ebp
  80148a:	56                   	push   %esi
  80148b:	57                   	push   %edi
  80148c:	54                   	push   %esp
  80148d:	5d                   	pop    %ebp
  80148e:	8d 35 96 14 80 00    	lea    0x801496,%esi
  801494:	0f 34                	sysenter 
  801496:	5f                   	pop    %edi
  801497:	5e                   	pop    %esi
  801498:	5d                   	pop    %ebp
  801499:	5c                   	pop    %esp
  80149a:	5b                   	pop    %ebx
  80149b:	5a                   	pop    %edx
  80149c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80149d:	85 c0                	test   %eax,%eax
  80149f:	7e 28                	jle    8014c9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8014ac:	00 
  8014ad:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  8014b4:	00 
  8014b5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014bc:	00 
  8014bd:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  8014c4:	e8 f7 ed ff ff       	call   8002c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8014c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014cf:	89 ec                	mov    %ebp,%esp
  8014d1:	5d                   	pop    %ebp
  8014d2:	c3                   	ret    

008014d3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	83 ec 28             	sub    $0x28,%esp
  8014d9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014dc:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014df:	bf 00 00 00 00       	mov    $0x0,%edi
  8014e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8014e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f2:	51                   	push   %ecx
  8014f3:	52                   	push   %edx
  8014f4:	53                   	push   %ebx
  8014f5:	54                   	push   %esp
  8014f6:	55                   	push   %ebp
  8014f7:	56                   	push   %esi
  8014f8:	57                   	push   %edi
  8014f9:	54                   	push   %esp
  8014fa:	5d                   	pop    %ebp
  8014fb:	8d 35 03 15 80 00    	lea    0x801503,%esi
  801501:	0f 34                	sysenter 
  801503:	5f                   	pop    %edi
  801504:	5e                   	pop    %esi
  801505:	5d                   	pop    %ebp
  801506:	5c                   	pop    %esp
  801507:	5b                   	pop    %ebx
  801508:	5a                   	pop    %edx
  801509:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	7e 28                	jle    801536 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80150e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801512:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801519:	00 
  80151a:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  801521:	00 
  801522:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801529:	00 
  80152a:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  801531:	e8 8a ed ff ff       	call   8002c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801536:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801539:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80153c:	89 ec                	mov    %ebp,%esp
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	89 1c 24             	mov    %ebx,(%esp)
  801549:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80154d:	ba 00 00 00 00       	mov    $0x0,%edx
  801552:	b8 0c 00 00 00       	mov    $0xc,%eax
  801557:	89 d1                	mov    %edx,%ecx
  801559:	89 d3                	mov    %edx,%ebx
  80155b:	89 d7                	mov    %edx,%edi
  80155d:	51                   	push   %ecx
  80155e:	52                   	push   %edx
  80155f:	53                   	push   %ebx
  801560:	54                   	push   %esp
  801561:	55                   	push   %ebp
  801562:	56                   	push   %esi
  801563:	57                   	push   %edi
  801564:	54                   	push   %esp
  801565:	5d                   	pop    %ebp
  801566:	8d 35 6e 15 80 00    	lea    0x80156e,%esi
  80156c:	0f 34                	sysenter 
  80156e:	5f                   	pop    %edi
  80156f:	5e                   	pop    %esi
  801570:	5d                   	pop    %ebp
  801571:	5c                   	pop    %esp
  801572:	5b                   	pop    %ebx
  801573:	5a                   	pop    %edx
  801574:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801575:	8b 1c 24             	mov    (%esp),%ebx
  801578:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80157c:	89 ec                	mov    %ebp,%esp
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    

00801580 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	89 1c 24             	mov    %ebx,(%esp)
  801589:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80158d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801592:	b8 04 00 00 00       	mov    $0x4,%eax
  801597:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80159a:	8b 55 08             	mov    0x8(%ebp),%edx
  80159d:	89 df                	mov    %ebx,%edi
  80159f:	51                   	push   %ecx
  8015a0:	52                   	push   %edx
  8015a1:	53                   	push   %ebx
  8015a2:	54                   	push   %esp
  8015a3:	55                   	push   %ebp
  8015a4:	56                   	push   %esi
  8015a5:	57                   	push   %edi
  8015a6:	54                   	push   %esp
  8015a7:	5d                   	pop    %ebp
  8015a8:	8d 35 b0 15 80 00    	lea    0x8015b0,%esi
  8015ae:	0f 34                	sysenter 
  8015b0:	5f                   	pop    %edi
  8015b1:	5e                   	pop    %esi
  8015b2:	5d                   	pop    %ebp
  8015b3:	5c                   	pop    %esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5a                   	pop    %edx
  8015b6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8015b7:	8b 1c 24             	mov    (%esp),%ebx
  8015ba:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015be:	89 ec                	mov    %ebp,%esp
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    

008015c2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	89 1c 24             	mov    %ebx,(%esp)
  8015cb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8015d9:	89 d1                	mov    %edx,%ecx
  8015db:	89 d3                	mov    %edx,%ebx
  8015dd:	89 d7                	mov    %edx,%edi
  8015df:	51                   	push   %ecx
  8015e0:	52                   	push   %edx
  8015e1:	53                   	push   %ebx
  8015e2:	54                   	push   %esp
  8015e3:	55                   	push   %ebp
  8015e4:	56                   	push   %esi
  8015e5:	57                   	push   %edi
  8015e6:	54                   	push   %esp
  8015e7:	5d                   	pop    %ebp
  8015e8:	8d 35 f0 15 80 00    	lea    0x8015f0,%esi
  8015ee:	0f 34                	sysenter 
  8015f0:	5f                   	pop    %edi
  8015f1:	5e                   	pop    %esi
  8015f2:	5d                   	pop    %ebp
  8015f3:	5c                   	pop    %esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5a                   	pop    %edx
  8015f6:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8015f7:	8b 1c 24             	mov    (%esp),%ebx
  8015fa:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015fe:	89 ec                	mov    %ebp,%esp
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 28             	sub    $0x28,%esp
  801608:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80160b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80160e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801613:	b8 03 00 00 00       	mov    $0x3,%eax
  801618:	8b 55 08             	mov    0x8(%ebp),%edx
  80161b:	89 cb                	mov    %ecx,%ebx
  80161d:	89 cf                	mov    %ecx,%edi
  80161f:	51                   	push   %ecx
  801620:	52                   	push   %edx
  801621:	53                   	push   %ebx
  801622:	54                   	push   %esp
  801623:	55                   	push   %ebp
  801624:	56                   	push   %esi
  801625:	57                   	push   %edi
  801626:	54                   	push   %esp
  801627:	5d                   	pop    %ebp
  801628:	8d 35 30 16 80 00    	lea    0x801630,%esi
  80162e:	0f 34                	sysenter 
  801630:	5f                   	pop    %edi
  801631:	5e                   	pop    %esi
  801632:	5d                   	pop    %ebp
  801633:	5c                   	pop    %esp
  801634:	5b                   	pop    %ebx
  801635:	5a                   	pop    %edx
  801636:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801637:	85 c0                	test   %eax,%eax
  801639:	7e 28                	jle    801663 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80163b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80163f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801646:	00 
  801647:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  80164e:	00 
  80164f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801656:	00 
  801657:	c7 04 24 5d 27 80 00 	movl   $0x80275d,(%esp)
  80165e:	e8 5d ec ff ff       	call   8002c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801663:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801666:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801669:	89 ec                	mov    %ebp,%esp
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    
  80166d:	00 00                	add    %al,(%eax)
	...

00801670 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	05 00 00 00 30       	add    $0x30000000,%eax
  80167b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	89 04 24             	mov    %eax,(%esp)
  80168c:	e8 df ff ff ff       	call   801670 <fd2num>
  801691:	05 20 00 0d 00       	add    $0xd0020,%eax
  801696:	c1 e0 0c             	shl    $0xc,%eax
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	57                   	push   %edi
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8016a4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016a9:	a8 01                	test   $0x1,%al
  8016ab:	74 36                	je     8016e3 <fd_alloc+0x48>
  8016ad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016b2:	a8 01                	test   $0x1,%al
  8016b4:	74 2d                	je     8016e3 <fd_alloc+0x48>
  8016b6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8016bb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016c0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016c5:	89 c3                	mov    %eax,%ebx
  8016c7:	89 c2                	mov    %eax,%edx
  8016c9:	c1 ea 16             	shr    $0x16,%edx
  8016cc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016cf:	f6 c2 01             	test   $0x1,%dl
  8016d2:	74 14                	je     8016e8 <fd_alloc+0x4d>
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	c1 ea 0c             	shr    $0xc,%edx
  8016d9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016dc:	f6 c2 01             	test   $0x1,%dl
  8016df:	75 10                	jne    8016f1 <fd_alloc+0x56>
  8016e1:	eb 05                	jmp    8016e8 <fd_alloc+0x4d>
  8016e3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8016e8:	89 1f                	mov    %ebx,(%edi)
  8016ea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016ef:	eb 17                	jmp    801708 <fd_alloc+0x6d>
  8016f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016fb:	75 c8                	jne    8016c5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016fd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801703:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5f                   	pop    %edi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801710:	8b 45 08             	mov    0x8(%ebp),%eax
  801713:	83 f8 1f             	cmp    $0x1f,%eax
  801716:	77 36                	ja     80174e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801718:	05 00 00 0d 00       	add    $0xd0000,%eax
  80171d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801720:	89 c2                	mov    %eax,%edx
  801722:	c1 ea 16             	shr    $0x16,%edx
  801725:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80172c:	f6 c2 01             	test   $0x1,%dl
  80172f:	74 1d                	je     80174e <fd_lookup+0x41>
  801731:	89 c2                	mov    %eax,%edx
  801733:	c1 ea 0c             	shr    $0xc,%edx
  801736:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80173d:	f6 c2 01             	test   $0x1,%dl
  801740:	74 0c                	je     80174e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801742:	8b 55 0c             	mov    0xc(%ebp),%edx
  801745:	89 02                	mov    %eax,(%edx)
  801747:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80174c:	eb 05                	jmp    801753 <fd_lookup+0x46>
  80174e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80175e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	89 04 24             	mov    %eax,(%esp)
  801768:	e8 a0 ff ff ff       	call   80170d <fd_lookup>
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 0e                	js     80177f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801771:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801774:	8b 55 0c             	mov    0xc(%ebp),%edx
  801777:	89 50 04             	mov    %edx,0x4(%eax)
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 10             	sub    $0x10,%esp
  801789:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80178f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801794:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801799:	be ec 27 80 00       	mov    $0x8027ec,%esi
		if (devtab[i]->dev_id == dev_id) {
  80179e:	39 08                	cmp    %ecx,(%eax)
  8017a0:	75 10                	jne    8017b2 <dev_lookup+0x31>
  8017a2:	eb 04                	jmp    8017a8 <dev_lookup+0x27>
  8017a4:	39 08                	cmp    %ecx,(%eax)
  8017a6:	75 0a                	jne    8017b2 <dev_lookup+0x31>
			*dev = devtab[i];
  8017a8:	89 03                	mov    %eax,(%ebx)
  8017aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017af:	90                   	nop
  8017b0:	eb 31                	jmp    8017e3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017b2:	83 c2 01             	add    $0x1,%edx
  8017b5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	75 e8                	jne    8017a4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c1:	8b 40 48             	mov    0x48(%eax),%eax
  8017c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cc:	c7 04 24 6c 27 80 00 	movl   $0x80276c,(%esp)
  8017d3:	e8 a1 eb ff ff       	call   800379 <cprintf>
	*dev = 0;
  8017d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5e                   	pop    %esi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 24             	sub    $0x24,%esp
  8017f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fe:	89 04 24             	mov    %eax,(%esp)
  801801:	e8 07 ff ff ff       	call   80170d <fd_lookup>
  801806:	85 c0                	test   %eax,%eax
  801808:	78 53                	js     80185d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801814:	8b 00                	mov    (%eax),%eax
  801816:	89 04 24             	mov    %eax,(%esp)
  801819:	e8 63 ff ff ff       	call   801781 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 3b                	js     80185d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801822:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801827:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80182e:	74 2d                	je     80185d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801830:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801833:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80183a:	00 00 00 
	stat->st_isdir = 0;
  80183d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801844:	00 00 00 
	stat->st_dev = dev;
  801847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801854:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801857:	89 14 24             	mov    %edx,(%esp)
  80185a:	ff 50 14             	call   *0x14(%eax)
}
  80185d:	83 c4 24             	add    $0x24,%esp
  801860:	5b                   	pop    %ebx
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 24             	sub    $0x24,%esp
  80186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801870:	89 44 24 04          	mov    %eax,0x4(%esp)
  801874:	89 1c 24             	mov    %ebx,(%esp)
  801877:	e8 91 fe ff ff       	call   80170d <fd_lookup>
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 5f                	js     8018df <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801883:	89 44 24 04          	mov    %eax,0x4(%esp)
  801887:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188a:	8b 00                	mov    (%eax),%eax
  80188c:	89 04 24             	mov    %eax,(%esp)
  80188f:	e8 ed fe ff ff       	call   801781 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801894:	85 c0                	test   %eax,%eax
  801896:	78 47                	js     8018df <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801898:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80189b:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  80189f:	75 23                	jne    8018c4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018a6:	8b 40 48             	mov    0x48(%eax),%eax
  8018a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  8018b8:	e8 bc ea ff ff       	call   800379 <cprintf>
  8018bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018c2:	eb 1b                	jmp    8018df <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c7:	8b 48 18             	mov    0x18(%eax),%ecx
  8018ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018cf:	85 c9                	test   %ecx,%ecx
  8018d1:	74 0c                	je     8018df <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018da:	89 14 24             	mov    %edx,(%esp)
  8018dd:	ff d1                	call   *%ecx
}
  8018df:	83 c4 24             	add    $0x24,%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 24             	sub    $0x24,%esp
  8018ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f6:	89 1c 24             	mov    %ebx,(%esp)
  8018f9:	e8 0f fe ff ff       	call   80170d <fd_lookup>
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 66                	js     801968 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801902:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801905:	89 44 24 04          	mov    %eax,0x4(%esp)
  801909:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190c:	8b 00                	mov    (%eax),%eax
  80190e:	89 04 24             	mov    %eax,(%esp)
  801911:	e8 6b fe ff ff       	call   801781 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801916:	85 c0                	test   %eax,%eax
  801918:	78 4e                	js     801968 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80191a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80191d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801921:	75 23                	jne    801946 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801923:	a1 04 40 80 00       	mov    0x804004,%eax
  801928:	8b 40 48             	mov    0x48(%eax),%eax
  80192b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801933:	c7 04 24 b0 27 80 00 	movl   $0x8027b0,(%esp)
  80193a:	e8 3a ea ff ff       	call   800379 <cprintf>
  80193f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801944:	eb 22                	jmp    801968 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801946:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801949:	8b 48 0c             	mov    0xc(%eax),%ecx
  80194c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801951:	85 c9                	test   %ecx,%ecx
  801953:	74 13                	je     801968 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801955:	8b 45 10             	mov    0x10(%ebp),%eax
  801958:	89 44 24 08          	mov    %eax,0x8(%esp)
  80195c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801963:	89 14 24             	mov    %edx,(%esp)
  801966:	ff d1                	call   *%ecx
}
  801968:	83 c4 24             	add    $0x24,%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	53                   	push   %ebx
  801972:	83 ec 24             	sub    $0x24,%esp
  801975:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801978:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80197b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197f:	89 1c 24             	mov    %ebx,(%esp)
  801982:	e8 86 fd ff ff       	call   80170d <fd_lookup>
  801987:	85 c0                	test   %eax,%eax
  801989:	78 6b                	js     8019f6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80198b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801992:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801995:	8b 00                	mov    (%eax),%eax
  801997:	89 04 24             	mov    %eax,(%esp)
  80199a:	e8 e2 fd ff ff       	call   801781 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 53                	js     8019f6 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019a6:	8b 42 08             	mov    0x8(%edx),%eax
  8019a9:	83 e0 03             	and    $0x3,%eax
  8019ac:	83 f8 01             	cmp    $0x1,%eax
  8019af:	75 23                	jne    8019d4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8019b6:	8b 40 48             	mov    0x48(%eax),%eax
  8019b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c1:	c7 04 24 cd 27 80 00 	movl   $0x8027cd,(%esp)
  8019c8:	e8 ac e9 ff ff       	call   800379 <cprintf>
  8019cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019d2:	eb 22                	jmp    8019f6 <read+0x88>
	}
	if (!dev->dev_read)
  8019d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d7:	8b 48 08             	mov    0x8(%eax),%ecx
  8019da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019df:	85 c9                	test   %ecx,%ecx
  8019e1:	74 13                	je     8019f6 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f1:	89 14 24             	mov    %edx,(%esp)
  8019f4:	ff d1                	call   *%ecx
}
  8019f6:	83 c4 24             	add    $0x24,%esp
  8019f9:	5b                   	pop    %ebx
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	57                   	push   %edi
  801a00:	56                   	push   %esi
  801a01:	53                   	push   %ebx
  801a02:	83 ec 1c             	sub    $0x1c,%esp
  801a05:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a08:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a10:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a15:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1a:	85 f6                	test   %esi,%esi
  801a1c:	74 29                	je     801a47 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a1e:	89 f0                	mov    %esi,%eax
  801a20:	29 d0                	sub    %edx,%eax
  801a22:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a26:	03 55 0c             	add    0xc(%ebp),%edx
  801a29:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a2d:	89 3c 24             	mov    %edi,(%esp)
  801a30:	e8 39 ff ff ff       	call   80196e <read>
		if (m < 0)
  801a35:	85 c0                	test   %eax,%eax
  801a37:	78 0e                	js     801a47 <readn+0x4b>
			return m;
		if (m == 0)
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	74 08                	je     801a45 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a3d:	01 c3                	add    %eax,%ebx
  801a3f:	89 da                	mov    %ebx,%edx
  801a41:	39 f3                	cmp    %esi,%ebx
  801a43:	72 d9                	jb     801a1e <readn+0x22>
  801a45:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a47:	83 c4 1c             	add    $0x1c,%esp
  801a4a:	5b                   	pop    %ebx
  801a4b:	5e                   	pop    %esi
  801a4c:	5f                   	pop    %edi
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	56                   	push   %esi
  801a53:	53                   	push   %ebx
  801a54:	83 ec 20             	sub    $0x20,%esp
  801a57:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a5a:	89 34 24             	mov    %esi,(%esp)
  801a5d:	e8 0e fc ff ff       	call   801670 <fd2num>
  801a62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a65:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a69:	89 04 24             	mov    %eax,(%esp)
  801a6c:	e8 9c fc ff ff       	call   80170d <fd_lookup>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 05                	js     801a7c <fd_close+0x2d>
  801a77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a7a:	74 0c                	je     801a88 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a7c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801a80:	19 c0                	sbb    %eax,%eax
  801a82:	f7 d0                	not    %eax
  801a84:	21 c3                	and    %eax,%ebx
  801a86:	eb 3d                	jmp    801ac5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8f:	8b 06                	mov    (%esi),%eax
  801a91:	89 04 24             	mov    %eax,(%esp)
  801a94:	e8 e8 fc ff ff       	call   801781 <dev_lookup>
  801a99:	89 c3                	mov    %eax,%ebx
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	78 16                	js     801ab5 <fd_close+0x66>
		if (dev->dev_close)
  801a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa2:	8b 40 10             	mov    0x10(%eax),%eax
  801aa5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	74 07                	je     801ab5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801aae:	89 34 24             	mov    %esi,(%esp)
  801ab1:	ff d0                	call   *%eax
  801ab3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ab5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ab9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac0:	e8 34 f9 ff ff       	call   8013f9 <sys_page_unmap>
	return r;
}
  801ac5:	89 d8                	mov    %ebx,%eax
  801ac7:	83 c4 20             	add    $0x20,%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ade:	89 04 24             	mov    %eax,(%esp)
  801ae1:	e8 27 fc ff ff       	call   80170d <fd_lookup>
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	78 13                	js     801afd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801aea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801af1:	00 
  801af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af5:	89 04 24             	mov    %eax,(%esp)
  801af8:	e8 52 ff ff ff       	call   801a4f <fd_close>
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 18             	sub    $0x18,%esp
  801b05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b08:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b12:	00 
  801b13:	8b 45 08             	mov    0x8(%ebp),%eax
  801b16:	89 04 24             	mov    %eax,(%esp)
  801b19:	e8 79 03 00 00       	call   801e97 <open>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 1b                	js     801b3f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2b:	89 1c 24             	mov    %ebx,(%esp)
  801b2e:	e8 b7 fc ff ff       	call   8017ea <fstat>
  801b33:	89 c6                	mov    %eax,%esi
	close(fd);
  801b35:	89 1c 24             	mov    %ebx,(%esp)
  801b38:	e8 91 ff ff ff       	call   801ace <close>
  801b3d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b3f:	89 d8                	mov    %ebx,%eax
  801b41:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b44:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b47:	89 ec                	mov    %ebp,%esp
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 14             	sub    $0x14,%esp
  801b52:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b57:	89 1c 24             	mov    %ebx,(%esp)
  801b5a:	e8 6f ff ff ff       	call   801ace <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b5f:	83 c3 01             	add    $0x1,%ebx
  801b62:	83 fb 20             	cmp    $0x20,%ebx
  801b65:	75 f0                	jne    801b57 <close_all+0xc>
		close(i);
}
  801b67:	83 c4 14             	add    $0x14,%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	83 ec 58             	sub    $0x58,%esp
  801b73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b79:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b7c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	89 04 24             	mov    %eax,(%esp)
  801b8c:	e8 7c fb ff ff       	call   80170d <fd_lookup>
  801b91:	89 c3                	mov    %eax,%ebx
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 88 e0 00 00 00    	js     801c7b <dup+0x10e>
		return r;
	close(newfdnum);
  801b9b:	89 3c 24             	mov    %edi,(%esp)
  801b9e:	e8 2b ff ff ff       	call   801ace <close>

	newfd = INDEX2FD(newfdnum);
  801ba3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801ba9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801baf:	89 04 24             	mov    %eax,(%esp)
  801bb2:	e8 c9 fa ff ff       	call   801680 <fd2data>
  801bb7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bb9:	89 34 24             	mov    %esi,(%esp)
  801bbc:	e8 bf fa ff ff       	call   801680 <fd2data>
  801bc1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801bc4:	89 da                	mov    %ebx,%edx
  801bc6:	89 d8                	mov    %ebx,%eax
  801bc8:	c1 e8 16             	shr    $0x16,%eax
  801bcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bd2:	a8 01                	test   $0x1,%al
  801bd4:	74 43                	je     801c19 <dup+0xac>
  801bd6:	c1 ea 0c             	shr    $0xc,%edx
  801bd9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801be0:	a8 01                	test   $0x1,%al
  801be2:	74 35                	je     801c19 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801be4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801beb:	25 07 0e 00 00       	and    $0xe07,%eax
  801bf0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801bf4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801bf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c02:	00 
  801c03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0e:	e8 52 f8 ff ff       	call   801465 <sys_page_map>
  801c13:	89 c3                	mov    %eax,%ebx
  801c15:	85 c0                	test   %eax,%eax
  801c17:	78 3f                	js     801c58 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c1c:	89 c2                	mov    %eax,%edx
  801c1e:	c1 ea 0c             	shr    $0xc,%edx
  801c21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c28:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c2e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c32:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c3d:	00 
  801c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c49:	e8 17 f8 ff ff       	call   801465 <sys_page_map>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 04                	js     801c58 <dup+0xeb>
  801c54:	89 fb                	mov    %edi,%ebx
  801c56:	eb 23                	jmp    801c7b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c58:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c63:	e8 91 f7 ff ff       	call   8013f9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c76:	e8 7e f7 ff ff       	call   8013f9 <sys_page_unmap>
	return r;
}
  801c7b:	89 d8                	mov    %ebx,%eax
  801c7d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c80:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c83:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c86:	89 ec                	mov    %ebp,%esp
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    
	...

00801c8c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	83 ec 18             	sub    $0x18,%esp
  801c92:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c95:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c98:	89 c3                	mov    %eax,%ebx
  801c9a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c9c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ca3:	75 11                	jne    801cb6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ca5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801cac:	e8 8f 02 00 00       	call   801f40 <ipc_find_env>
  801cb1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cb6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cbd:	00 
  801cbe:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cc5:	00 
  801cc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cca:	a1 00 40 80 00       	mov    0x804000,%eax
  801ccf:	89 04 24             	mov    %eax,(%esp)
  801cd2:	e8 b4 02 00 00       	call   801f8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cd7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cde:	00 
  801cdf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ce3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cea:	e8 1a 03 00 00       	call   802009 <ipc_recv>
}
  801cef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cf2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cf5:	89 ec                	mov    %ebp,%esp
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	8b 40 0c             	mov    0xc(%eax),%eax
  801d05:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d12:	ba 00 00 00 00       	mov    $0x0,%edx
  801d17:	b8 02 00 00 00       	mov    $0x2,%eax
  801d1c:	e8 6b ff ff ff       	call   801c8c <fsipc>
}
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801d2f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d34:	ba 00 00 00 00       	mov    $0x0,%edx
  801d39:	b8 06 00 00 00       	mov    $0x6,%eax
  801d3e:	e8 49 ff ff ff       	call   801c8c <fsipc>
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d50:	b8 08 00 00 00       	mov    $0x8,%eax
  801d55:	e8 32 ff ff ff       	call   801c8c <fsipc>
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	53                   	push   %ebx
  801d60:	83 ec 14             	sub    $0x14,%esp
  801d63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
  801d69:	8b 40 0c             	mov    0xc(%eax),%eax
  801d6c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d71:	ba 00 00 00 00       	mov    $0x0,%edx
  801d76:	b8 05 00 00 00       	mov    $0x5,%eax
  801d7b:	e8 0c ff ff ff       	call   801c8c <fsipc>
  801d80:	85 c0                	test   %eax,%eax
  801d82:	78 2b                	js     801daf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d84:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d8b:	00 
  801d8c:	89 1c 24             	mov    %ebx,(%esp)
  801d8f:	e8 16 ef ff ff       	call   800caa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d94:	a1 80 50 80 00       	mov    0x805080,%eax
  801d99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d9f:	a1 84 50 80 00       	mov    0x805084,%eax
  801da4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801daf:	83 c4 14             	add    $0x14,%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 18             	sub    $0x18,%esp
  801dbb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dbe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801dc3:	76 05                	jbe    801dca <devfile_write+0x15>
  801dc5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dca:	8b 55 08             	mov    0x8(%ebp),%edx
  801dcd:	8b 52 0c             	mov    0xc(%edx),%edx
  801dd0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801dd6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801ded:	e8 a3 f0 ff ff       	call   800e95 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801df2:	ba 00 00 00 00       	mov    $0x0,%edx
  801df7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dfc:	e8 8b fe ff ff       	call   801c8c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	53                   	push   %ebx
  801e07:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e10:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801e15:	8b 45 10             	mov    0x10(%ebp),%eax
  801e18:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801e1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e22:	b8 03 00 00 00       	mov    $0x3,%eax
  801e27:	e8 60 fe ff ff       	call   801c8c <fsipc>
  801e2c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 17                	js     801e49 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801e32:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e36:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e3d:	00 
  801e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e41:	89 04 24             	mov    %eax,(%esp)
  801e44:	e8 4c f0 ff ff       	call   800e95 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801e49:	89 d8                	mov    %ebx,%eax
  801e4b:	83 c4 14             	add    $0x14,%esp
  801e4e:	5b                   	pop    %ebx
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	53                   	push   %ebx
  801e55:	83 ec 14             	sub    $0x14,%esp
  801e58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e5b:	89 1c 24             	mov    %ebx,(%esp)
  801e5e:	e8 fd ed ff ff       	call   800c60 <strlen>
  801e63:	89 c2                	mov    %eax,%edx
  801e65:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e6a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e70:	7f 1f                	jg     801e91 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e76:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e7d:	e8 28 ee ff ff       	call   800caa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e82:	ba 00 00 00 00       	mov    $0x0,%edx
  801e87:	b8 07 00 00 00       	mov    $0x7,%eax
  801e8c:	e8 fb fd ff ff       	call   801c8c <fsipc>
}
  801e91:	83 c4 14             	add    $0x14,%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	83 ec 28             	sub    $0x28,%esp
  801e9d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ea0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ea3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801ea6:	89 34 24             	mov    %esi,(%esp)
  801ea9:	e8 b2 ed ff ff       	call   800c60 <strlen>
  801eae:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801eb3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eb8:	7f 6d                	jg     801f27 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801eba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebd:	89 04 24             	mov    %eax,(%esp)
  801ec0:	e8 d6 f7 ff ff       	call   80169b <fd_alloc>
  801ec5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 5c                	js     801f27 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ece:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801ed3:	89 34 24             	mov    %esi,(%esp)
  801ed6:	e8 85 ed ff ff       	call   800c60 <strlen>
  801edb:	83 c0 01             	add    $0x1,%eax
  801ede:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ee2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801eed:	e8 a3 ef ff ff       	call   800e95 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801ef2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ef5:	b8 01 00 00 00       	mov    $0x1,%eax
  801efa:	e8 8d fd ff ff       	call   801c8c <fsipc>
  801eff:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801f01:	85 c0                	test   %eax,%eax
  801f03:	79 15                	jns    801f1a <open+0x83>
             fd_close(fd,0);
  801f05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f0c:	00 
  801f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f10:	89 04 24             	mov    %eax,(%esp)
  801f13:	e8 37 fb ff ff       	call   801a4f <fd_close>
             return r;
  801f18:	eb 0d                	jmp    801f27 <open+0x90>
        }
        return fd2num(fd);
  801f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1d:	89 04 24             	mov    %eax,(%esp)
  801f20:	e8 4b f7 ff ff       	call   801670 <fd2num>
  801f25:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801f27:	89 d8                	mov    %ebx,%eax
  801f29:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f2c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f2f:	89 ec                	mov    %ebp,%esp
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    
	...

00801f40 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f46:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801f4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f51:	39 ca                	cmp    %ecx,%edx
  801f53:	75 04                	jne    801f59 <ipc_find_env+0x19>
  801f55:	b0 00                	mov    $0x0,%al
  801f57:	eb 12                	jmp    801f6b <ipc_find_env+0x2b>
  801f59:	89 c2                	mov    %eax,%edx
  801f5b:	c1 e2 07             	shl    $0x7,%edx
  801f5e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801f65:	8b 12                	mov    (%edx),%edx
  801f67:	39 ca                	cmp    %ecx,%edx
  801f69:	75 10                	jne    801f7b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801f6b:	89 c2                	mov    %eax,%edx
  801f6d:	c1 e2 07             	shl    $0x7,%edx
  801f70:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801f77:	8b 00                	mov    (%eax),%eax
  801f79:	eb 0e                	jmp    801f89 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7b:	83 c0 01             	add    $0x1,%eax
  801f7e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f83:	75 d4                	jne    801f59 <ipc_find_env+0x19>
  801f85:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	57                   	push   %edi
  801f8f:	56                   	push   %esi
  801f90:	53                   	push   %ebx
  801f91:	83 ec 1c             	sub    $0x1c,%esp
  801f94:	8b 75 08             	mov    0x8(%ebp),%esi
  801f97:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801f9d:	85 db                	test   %ebx,%ebx
  801f9f:	74 19                	je     801fba <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801fa1:	8b 45 14             	mov    0x14(%ebp),%eax
  801fa4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fa8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fb0:	89 34 24             	mov    %esi,(%esp)
  801fb3:	e8 bc f2 ff ff       	call   801274 <sys_ipc_try_send>
  801fb8:	eb 1b                	jmp    801fd5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801fba:	8b 45 14             	mov    0x14(%ebp),%eax
  801fbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fc1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801fc8:	ee 
  801fc9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fcd:	89 34 24             	mov    %esi,(%esp)
  801fd0:	e8 9f f2 ff ff       	call   801274 <sys_ipc_try_send>
           if(ret == 0)
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	74 28                	je     802001 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801fd9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fdc:	74 1c                	je     801ffa <ipc_send+0x6f>
              panic("ipc send error");
  801fde:	c7 44 24 08 f4 27 80 	movl   $0x8027f4,0x8(%esp)
  801fe5:	00 
  801fe6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801fed:	00 
  801fee:	c7 04 24 03 28 80 00 	movl   $0x802803,(%esp)
  801ff5:	e8 c6 e2 ff ff       	call   8002c0 <_panic>
           sys_yield();
  801ffa:	e8 41 f5 ff ff       	call   801540 <sys_yield>
        }
  801fff:	eb 9c                	jmp    801f9d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802001:	83 c4 1c             	add    $0x1c,%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	56                   	push   %esi
  80200d:	53                   	push   %ebx
  80200e:	83 ec 10             	sub    $0x10,%esp
  802011:	8b 75 08             	mov    0x8(%ebp),%esi
  802014:	8b 45 0c             	mov    0xc(%ebp),%eax
  802017:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80201a:	85 c0                	test   %eax,%eax
  80201c:	75 0e                	jne    80202c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80201e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802025:	e8 df f1 ff ff       	call   801209 <sys_ipc_recv>
  80202a:	eb 08                	jmp    802034 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 d5 f1 ff ff       	call   801209 <sys_ipc_recv>
        if(ret == 0){
  802034:	85 c0                	test   %eax,%eax
  802036:	75 26                	jne    80205e <ipc_recv+0x55>
           if(from_env_store)
  802038:	85 f6                	test   %esi,%esi
  80203a:	74 0a                	je     802046 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80203c:	a1 04 40 80 00       	mov    0x804004,%eax
  802041:	8b 40 78             	mov    0x78(%eax),%eax
  802044:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802046:	85 db                	test   %ebx,%ebx
  802048:	74 0a                	je     802054 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80204a:	a1 04 40 80 00       	mov    0x804004,%eax
  80204f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802052:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802054:	a1 04 40 80 00       	mov    0x804004,%eax
  802059:	8b 40 74             	mov    0x74(%eax),%eax
  80205c:	eb 14                	jmp    802072 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80205e:	85 f6                	test   %esi,%esi
  802060:	74 06                	je     802068 <ipc_recv+0x5f>
              *from_env_store = 0;
  802062:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802068:	85 db                	test   %ebx,%ebx
  80206a:	74 06                	je     802072 <ipc_recv+0x69>
              *perm_store = 0;
  80206c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	5b                   	pop    %ebx
  802076:	5e                   	pop    %esi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	00 00                	add    %al,(%eax)
  80207b:	00 00                	add    %al,(%eax)
  80207d:	00 00                	add    %al,(%eax)
	...

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	57                   	push   %edi
  802084:	56                   	push   %esi
  802085:	83 ec 10             	sub    $0x10,%esp
  802088:	8b 45 14             	mov    0x14(%ebp),%eax
  80208b:	8b 55 08             	mov    0x8(%ebp),%edx
  80208e:	8b 75 10             	mov    0x10(%ebp),%esi
  802091:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802094:	85 c0                	test   %eax,%eax
  802096:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802099:	75 35                	jne    8020d0 <__udivdi3+0x50>
  80209b:	39 fe                	cmp    %edi,%esi
  80209d:	77 61                	ja     802100 <__udivdi3+0x80>
  80209f:	85 f6                	test   %esi,%esi
  8020a1:	75 0b                	jne    8020ae <__udivdi3+0x2e>
  8020a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	f7 f6                	div    %esi
  8020ac:	89 c6                	mov    %eax,%esi
  8020ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8020b1:	31 d2                	xor    %edx,%edx
  8020b3:	89 f8                	mov    %edi,%eax
  8020b5:	f7 f6                	div    %esi
  8020b7:	89 c7                	mov    %eax,%edi
  8020b9:	89 c8                	mov    %ecx,%eax
  8020bb:	f7 f6                	div    %esi
  8020bd:	89 c1                	mov    %eax,%ecx
  8020bf:	89 fa                	mov    %edi,%edx
  8020c1:	89 c8                	mov    %ecx,%eax
  8020c3:	83 c4 10             	add    $0x10,%esp
  8020c6:	5e                   	pop    %esi
  8020c7:	5f                   	pop    %edi
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    
  8020ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d0:	39 f8                	cmp    %edi,%eax
  8020d2:	77 1c                	ja     8020f0 <__udivdi3+0x70>
  8020d4:	0f bd d0             	bsr    %eax,%edx
  8020d7:	83 f2 1f             	xor    $0x1f,%edx
  8020da:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020dd:	75 39                	jne    802118 <__udivdi3+0x98>
  8020df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020e2:	0f 86 a0 00 00 00    	jbe    802188 <__udivdi3+0x108>
  8020e8:	39 f8                	cmp    %edi,%eax
  8020ea:	0f 82 98 00 00 00    	jb     802188 <__udivdi3+0x108>
  8020f0:	31 ff                	xor    %edi,%edi
  8020f2:	31 c9                	xor    %ecx,%ecx
  8020f4:	89 c8                	mov    %ecx,%eax
  8020f6:	89 fa                	mov    %edi,%edx
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    
  8020ff:	90                   	nop
  802100:	89 d1                	mov    %edx,%ecx
  802102:	89 fa                	mov    %edi,%edx
  802104:	89 c8                	mov    %ecx,%eax
  802106:	31 ff                	xor    %edi,%edi
  802108:	f7 f6                	div    %esi
  80210a:	89 c1                	mov    %eax,%ecx
  80210c:	89 fa                	mov    %edi,%edx
  80210e:	89 c8                	mov    %ecx,%eax
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	5e                   	pop    %esi
  802114:	5f                   	pop    %edi
  802115:	5d                   	pop    %ebp
  802116:	c3                   	ret    
  802117:	90                   	nop
  802118:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80211c:	89 f2                	mov    %esi,%edx
  80211e:	d3 e0                	shl    %cl,%eax
  802120:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802123:	b8 20 00 00 00       	mov    $0x20,%eax
  802128:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80212b:	89 c1                	mov    %eax,%ecx
  80212d:	d3 ea                	shr    %cl,%edx
  80212f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802133:	0b 55 ec             	or     -0x14(%ebp),%edx
  802136:	d3 e6                	shl    %cl,%esi
  802138:	89 c1                	mov    %eax,%ecx
  80213a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80213d:	89 fe                	mov    %edi,%esi
  80213f:	d3 ee                	shr    %cl,%esi
  802141:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802145:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80214b:	d3 e7                	shl    %cl,%edi
  80214d:	89 c1                	mov    %eax,%ecx
  80214f:	d3 ea                	shr    %cl,%edx
  802151:	09 d7                	or     %edx,%edi
  802153:	89 f2                	mov    %esi,%edx
  802155:	89 f8                	mov    %edi,%eax
  802157:	f7 75 ec             	divl   -0x14(%ebp)
  80215a:	89 d6                	mov    %edx,%esi
  80215c:	89 c7                	mov    %eax,%edi
  80215e:	f7 65 e8             	mull   -0x18(%ebp)
  802161:	39 d6                	cmp    %edx,%esi
  802163:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802166:	72 30                	jb     802198 <__udivdi3+0x118>
  802168:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80216b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	39 c2                	cmp    %eax,%edx
  802173:	73 05                	jae    80217a <__udivdi3+0xfa>
  802175:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802178:	74 1e                	je     802198 <__udivdi3+0x118>
  80217a:	89 f9                	mov    %edi,%ecx
  80217c:	31 ff                	xor    %edi,%edi
  80217e:	e9 71 ff ff ff       	jmp    8020f4 <__udivdi3+0x74>
  802183:	90                   	nop
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80218f:	e9 60 ff ff ff       	jmp    8020f4 <__udivdi3+0x74>
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80219b:	31 ff                	xor    %edi,%edi
  80219d:	89 c8                	mov    %ecx,%eax
  80219f:	89 fa                	mov    %edi,%edx
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
	...

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	57                   	push   %edi
  8021b4:	56                   	push   %esi
  8021b5:	83 ec 20             	sub    $0x20,%esp
  8021b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8021bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8021c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021c4:	85 d2                	test   %edx,%edx
  8021c6:	89 c8                	mov    %ecx,%eax
  8021c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021cb:	75 13                	jne    8021e0 <__umoddi3+0x30>
  8021cd:	39 f7                	cmp    %esi,%edi
  8021cf:	76 3f                	jbe    802210 <__umoddi3+0x60>
  8021d1:	89 f2                	mov    %esi,%edx
  8021d3:	f7 f7                	div    %edi
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	31 d2                	xor    %edx,%edx
  8021d9:	83 c4 20             	add    $0x20,%esp
  8021dc:	5e                   	pop    %esi
  8021dd:	5f                   	pop    %edi
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    
  8021e0:	39 f2                	cmp    %esi,%edx
  8021e2:	77 4c                	ja     802230 <__umoddi3+0x80>
  8021e4:	0f bd ca             	bsr    %edx,%ecx
  8021e7:	83 f1 1f             	xor    $0x1f,%ecx
  8021ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021ed:	75 51                	jne    802240 <__umoddi3+0x90>
  8021ef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021f2:	0f 87 e0 00 00 00    	ja     8022d8 <__umoddi3+0x128>
  8021f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fb:	29 f8                	sub    %edi,%eax
  8021fd:	19 d6                	sbb    %edx,%esi
  8021ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802202:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802205:	89 f2                	mov    %esi,%edx
  802207:	83 c4 20             	add    $0x20,%esp
  80220a:	5e                   	pop    %esi
  80220b:	5f                   	pop    %edi
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    
  80220e:	66 90                	xchg   %ax,%ax
  802210:	85 ff                	test   %edi,%edi
  802212:	75 0b                	jne    80221f <__umoddi3+0x6f>
  802214:	b8 01 00 00 00       	mov    $0x1,%eax
  802219:	31 d2                	xor    %edx,%edx
  80221b:	f7 f7                	div    %edi
  80221d:	89 c7                	mov    %eax,%edi
  80221f:	89 f0                	mov    %esi,%eax
  802221:	31 d2                	xor    %edx,%edx
  802223:	f7 f7                	div    %edi
  802225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802228:	f7 f7                	div    %edi
  80222a:	eb a9                	jmp    8021d5 <__umoddi3+0x25>
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 20             	add    $0x20,%esp
  802237:	5e                   	pop    %esi
  802238:	5f                   	pop    %edi
  802239:	5d                   	pop    %ebp
  80223a:	c3                   	ret    
  80223b:	90                   	nop
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802244:	d3 e2                	shl    %cl,%edx
  802246:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802249:	ba 20 00 00 00       	mov    $0x20,%edx
  80224e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802251:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802254:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802258:	89 fa                	mov    %edi,%edx
  80225a:	d3 ea                	shr    %cl,%edx
  80225c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802260:	0b 55 f4             	or     -0xc(%ebp),%edx
  802263:	d3 e7                	shl    %cl,%edi
  802265:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802269:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80226c:	89 f2                	mov    %esi,%edx
  80226e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802271:	89 c7                	mov    %eax,%edi
  802273:	d3 ea                	shr    %cl,%edx
  802275:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802279:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80227c:	89 c2                	mov    %eax,%edx
  80227e:	d3 e6                	shl    %cl,%esi
  802280:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802284:	d3 ea                	shr    %cl,%edx
  802286:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80228a:	09 d6                	or     %edx,%esi
  80228c:	89 f0                	mov    %esi,%eax
  80228e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802291:	d3 e7                	shl    %cl,%edi
  802293:	89 f2                	mov    %esi,%edx
  802295:	f7 75 f4             	divl   -0xc(%ebp)
  802298:	89 d6                	mov    %edx,%esi
  80229a:	f7 65 e8             	mull   -0x18(%ebp)
  80229d:	39 d6                	cmp    %edx,%esi
  80229f:	72 2b                	jb     8022cc <__umoddi3+0x11c>
  8022a1:	39 c7                	cmp    %eax,%edi
  8022a3:	72 23                	jb     8022c8 <__umoddi3+0x118>
  8022a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022a9:	29 c7                	sub    %eax,%edi
  8022ab:	19 d6                	sbb    %edx,%esi
  8022ad:	89 f0                	mov    %esi,%eax
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	d3 ef                	shr    %cl,%edi
  8022b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022bd:	09 f8                	or     %edi,%eax
  8022bf:	d3 ea                	shr    %cl,%edx
  8022c1:	83 c4 20             	add    $0x20,%esp
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	39 d6                	cmp    %edx,%esi
  8022ca:	75 d9                	jne    8022a5 <__umoddi3+0xf5>
  8022cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8022cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022d2:	eb d1                	jmp    8022a5 <__umoddi3+0xf5>
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	0f 82 18 ff ff ff    	jb     8021f8 <__umoddi3+0x48>
  8022e0:	e9 1d ff ff ff       	jmp    802202 <__umoddi3+0x52>
