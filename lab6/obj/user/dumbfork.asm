
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
  800051:	e8 82 15 00 00       	call   8015d8 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 60 29 80 	movl   $0x802960,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 73 29 80 00 	movl   $0x802973,(%esp)
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
  800099:	e8 cc 14 00 00       	call   80156a <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 83 29 80 	movl   $0x802983,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 73 29 80 00 	movl   $0x802973,(%esp)
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
  8000e9:	e8 10 14 00 00       	call   8014fe <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 94 29 80 	movl   $0x802994,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 73 29 80 00 	movl   $0x802973,(%esp)
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
  800133:	c7 44 24 08 a7 29 80 	movl   $0x8029a7,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 73 29 80 00 	movl   $0x802973,(%esp)
  80014a:	e8 71 01 00 00       	call   8002c0 <_panic>
	if (envid == 0) {
  80014f:	85 c0                	test   %eax,%eax
  800151:	75 1d                	jne    800170 <dumbfork+0x57>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800153:	e8 6f 15 00 00       	call   8016c7 <sys_getenvid>
  800158:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015d:	89 c2                	mov    %eax,%edx
  80015f:	c1 e2 07             	shl    $0x7,%edx
  800162:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800169:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80016e:	eb 7e                	jmp    8001ee <dumbfork+0xd5>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800170:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800177:	b8 00 70 80 00       	mov    $0x807000,%eax
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
  80019f:	3d 00 70 80 00       	cmp    $0x807000,%eax
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
  8001c5:	e8 c8 12 00 00       	call   801492 <sys_env_set_status>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <dumbfork+0xd5>
		panic("sys_env_set_status: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 b7 29 80 	movl   $0x8029b7,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 73 29 80 00 	movl   $0x802973,(%esp)
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
  80020b:	bf d4 29 80 00       	mov    $0x8029d4,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800210:	eb 27                	jmp    800239 <umain+0x43>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800212:	89 f8                	mov    %edi,%eax
  800214:	85 f6                	test   %esi,%esi
  800216:	75 05                	jne    80021d <umain+0x27>
  800218:	b8 ce 29 80 00       	mov    $0x8029ce,%eax
  80021d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800221:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800225:	c7 04 24 db 29 80 00 	movl   $0x8029db,(%esp)
  80022c:	e8 48 01 00 00       	call   800379 <cprintf>
		sys_yield();
  800231:	e8 0f 14 00 00       	call   801645 <sys_yield>

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
  800262:	e8 60 14 00 00       	call   8016c7 <sys_getenvid>
  800267:	25 ff 03 00 00       	and    $0x3ff,%eax
  80026c:	89 c2                	mov    %eax,%edx
  80026e:	c1 e2 07             	shl    $0x7,%edx
  800271:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800278:	a3 08 40 80 00       	mov    %eax,0x804008
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
  8002aa:	e8 ac 19 00 00       	call   801c5b <close_all>
	sys_env_destroy(0);
  8002af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b6:	e8 4c 14 00 00       	call   801707 <sys_env_destroy>
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
  8002d1:	e8 f1 13 00 00       	call   8016c7 <sys_getenvid>
  8002d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ec:	c7 04 24 f8 29 80 00 	movl   $0x8029f8,(%esp)
  8002f3:	e8 81 00 00 00       	call   800379 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	e8 11 00 00 00       	call   800318 <vcprintf>
	cprintf("\n");
  800307:	c7 04 24 eb 29 80 00 	movl   $0x8029eb,(%esp)
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
  80044f:	e8 8c 22 00 00       	call   8026e0 <__udivdi3>
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
  8004b7:	e8 54 23 00 00       	call   802810 <__umoddi3>
  8004bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c0:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
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
  8005aa:	ff 24 95 00 2c 80 00 	jmp    *0x802c00(,%edx,4)
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
  800667:	8b 14 85 60 2d 80 00 	mov    0x802d60(,%eax,4),%edx
  80066e:	85 d2                	test   %edx,%edx
  800670:	75 26                	jne    800698 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800672:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800676:	c7 44 24 08 2c 2a 80 	movl   $0x802a2c,0x8(%esp)
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
  80069c:	c7 44 24 08 82 2e 80 	movl   $0x802e82,0x8(%esp)
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
  8006da:	be 35 2a 80 00       	mov    $0x802a35,%esi
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
  800984:	e8 57 1d 00 00       	call   8026e0 <__udivdi3>
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
  8009d0:	e8 3b 1e 00 00       	call   802810 <__umoddi3>
  8009d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009d9:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
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
  800a85:	c7 44 24 0c 50 2b 80 	movl   $0x802b50,0xc(%esp)
  800a8c:	00 
  800a8d:	c7 44 24 08 82 2e 80 	movl   $0x802e82,0x8(%esp)
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
  800abb:	c7 44 24 0c 88 2b 80 	movl   $0x802b88,0xc(%esp)
  800ac2:	00 
  800ac3:	c7 44 24 08 82 2e 80 	movl   $0x802e82,0x8(%esp)
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
  800b4f:	e8 bc 1c 00 00       	call   802810 <__umoddi3>
  800b54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b58:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
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
  800b91:	e8 7a 1c 00 00       	call   802810 <__umoddi3>
  800b96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b9a:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
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

0080111b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  801128:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112d:	b8 13 00 00 00       	mov    $0x13,%eax
  801132:	8b 55 08             	mov    0x8(%ebp),%edx
  801135:	89 cb                	mov    %ecx,%ebx
  801137:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  801151:	8b 1c 24             	mov    (%esp),%ebx
  801154:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801158:	89 ec                	mov    %ebp,%esp
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	89 1c 24             	mov    %ebx,(%esp)
  801165:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801169:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116e:	b8 12 00 00 00       	mov    $0x12,%eax
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801176:	8b 55 08             	mov    0x8(%ebp),%edx
  801179:	89 df                	mov    %ebx,%edi
  80117b:	51                   	push   %ecx
  80117c:	52                   	push   %edx
  80117d:	53                   	push   %ebx
  80117e:	54                   	push   %esp
  80117f:	55                   	push   %ebp
  801180:	56                   	push   %esi
  801181:	57                   	push   %edi
  801182:	54                   	push   %esp
  801183:	5d                   	pop    %ebp
  801184:	8d 35 8c 11 80 00    	lea    0x80118c,%esi
  80118a:	0f 34                	sysenter 
  80118c:	5f                   	pop    %edi
  80118d:	5e                   	pop    %esi
  80118e:	5d                   	pop    %ebp
  80118f:	5c                   	pop    %esp
  801190:	5b                   	pop    %ebx
  801191:	5a                   	pop    %edx
  801192:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  801193:	8b 1c 24             	mov    (%esp),%ebx
  801196:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80119a:	89 ec                	mov    %ebp,%esp
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	89 1c 24             	mov    %ebx,(%esp)
  8011a7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b0:	b8 11 00 00 00       	mov    $0x11,%eax
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bb:	89 df                	mov    %ebx,%edi
  8011bd:	51                   	push   %ecx
  8011be:	52                   	push   %edx
  8011bf:	53                   	push   %ebx
  8011c0:	54                   	push   %esp
  8011c1:	55                   	push   %ebp
  8011c2:	56                   	push   %esi
  8011c3:	57                   	push   %edi
  8011c4:	54                   	push   %esp
  8011c5:	5d                   	pop    %ebp
  8011c6:	8d 35 ce 11 80 00    	lea    0x8011ce,%esi
  8011cc:	0f 34                	sysenter 
  8011ce:	5f                   	pop    %edi
  8011cf:	5e                   	pop    %esi
  8011d0:	5d                   	pop    %ebp
  8011d1:	5c                   	pop    %esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5a                   	pop    %edx
  8011d4:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8011d5:	8b 1c 24             	mov    (%esp),%ebx
  8011d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011dc:	89 ec                	mov    %ebp,%esp
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	89 1c 24             	mov    %ebx,(%esp)
  8011e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011ed:	b8 10 00 00 00       	mov    $0x10,%eax
  8011f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fe:	51                   	push   %ecx
  8011ff:	52                   	push   %edx
  801200:	53                   	push   %ebx
  801201:	54                   	push   %esp
  801202:	55                   	push   %ebp
  801203:	56                   	push   %esi
  801204:	57                   	push   %edi
  801205:	54                   	push   %esp
  801206:	5d                   	pop    %ebp
  801207:	8d 35 0f 12 80 00    	lea    0x80120f,%esi
  80120d:	0f 34                	sysenter 
  80120f:	5f                   	pop    %edi
  801210:	5e                   	pop    %esi
  801211:	5d                   	pop    %ebp
  801212:	5c                   	pop    %esp
  801213:	5b                   	pop    %ebx
  801214:	5a                   	pop    %edx
  801215:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  801216:	8b 1c 24             	mov    (%esp),%ebx
  801219:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80121d:	89 ec                	mov    %ebp,%esp
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 28             	sub    $0x28,%esp
  801227:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80122a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801232:	b8 0f 00 00 00       	mov    $0xf,%eax
  801237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123a:	8b 55 08             	mov    0x8(%ebp),%edx
  80123d:	89 df                	mov    %ebx,%edi
  80123f:	51                   	push   %ecx
  801240:	52                   	push   %edx
  801241:	53                   	push   %ebx
  801242:	54                   	push   %esp
  801243:	55                   	push   %ebp
  801244:	56                   	push   %esi
  801245:	57                   	push   %edi
  801246:	54                   	push   %esp
  801247:	5d                   	pop    %ebp
  801248:	8d 35 50 12 80 00    	lea    0x801250,%esi
  80124e:	0f 34                	sysenter 
  801250:	5f                   	pop    %edi
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	5c                   	pop    %esp
  801254:	5b                   	pop    %ebx
  801255:	5a                   	pop    %edx
  801256:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801257:	85 c0                	test   %eax,%eax
  801259:	7e 28                	jle    801283 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80125f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  801266:	00 
  801267:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  80126e:	00 
  80126f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801276:	00 
  801277:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  80127e:	e8 3d f0 ff ff       	call   8002c0 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  801283:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801286:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801289:	89 ec                	mov    %ebp,%esp
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	89 1c 24             	mov    %ebx,(%esp)
  801296:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80129a:	ba 00 00 00 00       	mov    $0x0,%edx
  80129f:	b8 15 00 00 00       	mov    $0x15,%eax
  8012a4:	89 d1                	mov    %edx,%ecx
  8012a6:	89 d3                	mov    %edx,%ebx
  8012a8:	89 d7                	mov    %edx,%edi
  8012aa:	51                   	push   %ecx
  8012ab:	52                   	push   %edx
  8012ac:	53                   	push   %ebx
  8012ad:	54                   	push   %esp
  8012ae:	55                   	push   %ebp
  8012af:	56                   	push   %esi
  8012b0:	57                   	push   %edi
  8012b1:	54                   	push   %esp
  8012b2:	5d                   	pop    %ebp
  8012b3:	8d 35 bb 12 80 00    	lea    0x8012bb,%esi
  8012b9:	0f 34                	sysenter 
  8012bb:	5f                   	pop    %edi
  8012bc:	5e                   	pop    %esi
  8012bd:	5d                   	pop    %ebp
  8012be:	5c                   	pop    %esp
  8012bf:	5b                   	pop    %ebx
  8012c0:	5a                   	pop    %edx
  8012c1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012c2:	8b 1c 24             	mov    (%esp),%ebx
  8012c5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012c9:	89 ec                	mov    %ebp,%esp
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	89 1c 24             	mov    %ebx,(%esp)
  8012d6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012df:	b8 14 00 00 00       	mov    $0x14,%eax
  8012e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e7:	89 cb                	mov    %ecx,%ebx
  8012e9:	89 cf                	mov    %ecx,%edi
  8012eb:	51                   	push   %ecx
  8012ec:	52                   	push   %edx
  8012ed:	53                   	push   %ebx
  8012ee:	54                   	push   %esp
  8012ef:	55                   	push   %ebp
  8012f0:	56                   	push   %esi
  8012f1:	57                   	push   %edi
  8012f2:	54                   	push   %esp
  8012f3:	5d                   	pop    %ebp
  8012f4:	8d 35 fc 12 80 00    	lea    0x8012fc,%esi
  8012fa:	0f 34                	sysenter 
  8012fc:	5f                   	pop    %edi
  8012fd:	5e                   	pop    %esi
  8012fe:	5d                   	pop    %ebp
  8012ff:	5c                   	pop    %esp
  801300:	5b                   	pop    %ebx
  801301:	5a                   	pop    %edx
  801302:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801303:	8b 1c 24             	mov    (%esp),%ebx
  801306:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80130a:	89 ec                	mov    %ebp,%esp
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
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
  80131a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80131f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801324:	8b 55 08             	mov    0x8(%ebp),%edx
  801327:	89 cb                	mov    %ecx,%ebx
  801329:	89 cf                	mov    %ecx,%edi
  80132b:	51                   	push   %ecx
  80132c:	52                   	push   %edx
  80132d:	53                   	push   %ebx
  80132e:	54                   	push   %esp
  80132f:	55                   	push   %ebp
  801330:	56                   	push   %esi
  801331:	57                   	push   %edi
  801332:	54                   	push   %esp
  801333:	5d                   	pop    %ebp
  801334:	8d 35 3c 13 80 00    	lea    0x80133c,%esi
  80133a:	0f 34                	sysenter 
  80133c:	5f                   	pop    %edi
  80133d:	5e                   	pop    %esi
  80133e:	5d                   	pop    %ebp
  80133f:	5c                   	pop    %esp
  801340:	5b                   	pop    %ebx
  801341:	5a                   	pop    %edx
  801342:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801343:	85 c0                	test   %eax,%eax
  801345:	7e 28                	jle    80136f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801347:	89 44 24 10          	mov    %eax,0x10(%esp)
  80134b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  801352:	00 
  801353:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  80135a:	00 
  80135b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801362:	00 
  801363:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  80136a:	e8 51 ef ff ff       	call   8002c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80136f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801372:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801375:	89 ec                	mov    %ebp,%esp
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	89 1c 24             	mov    %ebx,(%esp)
  801382:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801386:	b8 0d 00 00 00       	mov    $0xd,%eax
  80138b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80138e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801391:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801394:	8b 55 08             	mov    0x8(%ebp),%edx
  801397:	51                   	push   %ecx
  801398:	52                   	push   %edx
  801399:	53                   	push   %ebx
  80139a:	54                   	push   %esp
  80139b:	55                   	push   %ebp
  80139c:	56                   	push   %esi
  80139d:	57                   	push   %edi
  80139e:	54                   	push   %esp
  80139f:	5d                   	pop    %ebp
  8013a0:	8d 35 a8 13 80 00    	lea    0x8013a8,%esi
  8013a6:	0f 34                	sysenter 
  8013a8:	5f                   	pop    %edi
  8013a9:	5e                   	pop    %esi
  8013aa:	5d                   	pop    %ebp
  8013ab:	5c                   	pop    %esp
  8013ac:	5b                   	pop    %ebx
  8013ad:	5a                   	pop    %edx
  8013ae:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013af:	8b 1c 24             	mov    (%esp),%ebx
  8013b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b6:	89 ec                	mov    %ebp,%esp
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 28             	sub    $0x28,%esp
  8013c0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013c3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8013d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d6:	89 df                	mov    %ebx,%edi
  8013d8:	51                   	push   %ecx
  8013d9:	52                   	push   %edx
  8013da:	53                   	push   %ebx
  8013db:	54                   	push   %esp
  8013dc:	55                   	push   %ebp
  8013dd:	56                   	push   %esi
  8013de:	57                   	push   %edi
  8013df:	54                   	push   %esp
  8013e0:	5d                   	pop    %ebp
  8013e1:	8d 35 e9 13 80 00    	lea    0x8013e9,%esi
  8013e7:	0f 34                	sysenter 
  8013e9:	5f                   	pop    %edi
  8013ea:	5e                   	pop    %esi
  8013eb:	5d                   	pop    %ebp
  8013ec:	5c                   	pop    %esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5a                   	pop    %edx
  8013ef:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	7e 28                	jle    80141c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f8:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  8013ff:	00 
  801400:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  801407:	00 
  801408:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80140f:	00 
  801410:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  801417:	e8 a4 ee ff ff       	call   8002c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80141c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80141f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801422:	89 ec                	mov    %ebp,%esp
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 28             	sub    $0x28,%esp
  80142c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80142f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801432:	bb 00 00 00 00       	mov    $0x0,%ebx
  801437:	b8 0a 00 00 00       	mov    $0xa,%eax
  80143c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143f:	8b 55 08             	mov    0x8(%ebp),%edx
  801442:	89 df                	mov    %ebx,%edi
  801444:	51                   	push   %ecx
  801445:	52                   	push   %edx
  801446:	53                   	push   %ebx
  801447:	54                   	push   %esp
  801448:	55                   	push   %ebp
  801449:	56                   	push   %esi
  80144a:	57                   	push   %edi
  80144b:	54                   	push   %esp
  80144c:	5d                   	pop    %ebp
  80144d:	8d 35 55 14 80 00    	lea    0x801455,%esi
  801453:	0f 34                	sysenter 
  801455:	5f                   	pop    %edi
  801456:	5e                   	pop    %esi
  801457:	5d                   	pop    %ebp
  801458:	5c                   	pop    %esp
  801459:	5b                   	pop    %ebx
  80145a:	5a                   	pop    %edx
  80145b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80145c:	85 c0                	test   %eax,%eax
  80145e:	7e 28                	jle    801488 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801460:	89 44 24 10          	mov    %eax,0x10(%esp)
  801464:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80146b:	00 
  80146c:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  801473:	00 
  801474:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80147b:	00 
  80147c:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  801483:	e8 38 ee ff ff       	call   8002c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801488:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80148b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80148e:	89 ec                	mov    %ebp,%esp
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 28             	sub    $0x28,%esp
  801498:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80149b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80149e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a3:	b8 09 00 00 00       	mov    $0x9,%eax
  8014a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ae:	89 df                	mov    %ebx,%edi
  8014b0:	51                   	push   %ecx
  8014b1:	52                   	push   %edx
  8014b2:	53                   	push   %ebx
  8014b3:	54                   	push   %esp
  8014b4:	55                   	push   %ebp
  8014b5:	56                   	push   %esi
  8014b6:	57                   	push   %edi
  8014b7:	54                   	push   %esp
  8014b8:	5d                   	pop    %ebp
  8014b9:	8d 35 c1 14 80 00    	lea    0x8014c1,%esi
  8014bf:	0f 34                	sysenter 
  8014c1:	5f                   	pop    %edi
  8014c2:	5e                   	pop    %esi
  8014c3:	5d                   	pop    %ebp
  8014c4:	5c                   	pop    %esp
  8014c5:	5b                   	pop    %ebx
  8014c6:	5a                   	pop    %edx
  8014c7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	7e 28                	jle    8014f4 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014d0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8014d7:	00 
  8014d8:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  8014df:	00 
  8014e0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014e7:	00 
  8014e8:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  8014ef:	e8 cc ed ff ff       	call   8002c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8014f4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014f7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014fa:	89 ec                	mov    %ebp,%esp
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 28             	sub    $0x28,%esp
  801504:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801507:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80150a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150f:	b8 07 00 00 00       	mov    $0x7,%eax
  801514:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801517:	8b 55 08             	mov    0x8(%ebp),%edx
  80151a:	89 df                	mov    %ebx,%edi
  80151c:	51                   	push   %ecx
  80151d:	52                   	push   %edx
  80151e:	53                   	push   %ebx
  80151f:	54                   	push   %esp
  801520:	55                   	push   %ebp
  801521:	56                   	push   %esi
  801522:	57                   	push   %edi
  801523:	54                   	push   %esp
  801524:	5d                   	pop    %ebp
  801525:	8d 35 2d 15 80 00    	lea    0x80152d,%esi
  80152b:	0f 34                	sysenter 
  80152d:	5f                   	pop    %edi
  80152e:	5e                   	pop    %esi
  80152f:	5d                   	pop    %ebp
  801530:	5c                   	pop    %esp
  801531:	5b                   	pop    %ebx
  801532:	5a                   	pop    %edx
  801533:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  801534:	85 c0                	test   %eax,%eax
  801536:	7e 28                	jle    801560 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  801538:	89 44 24 10          	mov    %eax,0x10(%esp)
  80153c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801543:	00 
  801544:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  80154b:	00 
  80154c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801553:	00 
  801554:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  80155b:	e8 60 ed ff ff       	call   8002c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801560:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801563:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801566:	89 ec                	mov    %ebp,%esp
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 28             	sub    $0x28,%esp
  801570:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801573:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801576:	8b 7d 18             	mov    0x18(%ebp),%edi
  801579:	0b 7d 14             	or     0x14(%ebp),%edi
  80157c:	b8 06 00 00 00       	mov    $0x6,%eax
  801581:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801587:	8b 55 08             	mov    0x8(%ebp),%edx
  80158a:	51                   	push   %ecx
  80158b:	52                   	push   %edx
  80158c:	53                   	push   %ebx
  80158d:	54                   	push   %esp
  80158e:	55                   	push   %ebp
  80158f:	56                   	push   %esi
  801590:	57                   	push   %edi
  801591:	54                   	push   %esp
  801592:	5d                   	pop    %ebp
  801593:	8d 35 9b 15 80 00    	lea    0x80159b,%esi
  801599:	0f 34                	sysenter 
  80159b:	5f                   	pop    %edi
  80159c:	5e                   	pop    %esi
  80159d:	5d                   	pop    %ebp
  80159e:	5c                   	pop    %esp
  80159f:	5b                   	pop    %ebx
  8015a0:	5a                   	pop    %edx
  8015a1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	7e 28                	jle    8015ce <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015aa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8015b1:	00 
  8015b2:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  8015b9:	00 
  8015ba:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8015c1:	00 
  8015c2:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  8015c9:	e8 f2 ec ff ff       	call   8002c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8015ce:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015d4:	89 ec                	mov    %ebp,%esp
  8015d6:	5d                   	pop    %ebp
  8015d7:	c3                   	ret    

008015d8 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	83 ec 28             	sub    $0x28,%esp
  8015de:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015e1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8015e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f7:	51                   	push   %ecx
  8015f8:	52                   	push   %edx
  8015f9:	53                   	push   %ebx
  8015fa:	54                   	push   %esp
  8015fb:	55                   	push   %ebp
  8015fc:	56                   	push   %esi
  8015fd:	57                   	push   %edi
  8015fe:	54                   	push   %esp
  8015ff:	5d                   	pop    %ebp
  801600:	8d 35 08 16 80 00    	lea    0x801608,%esi
  801606:	0f 34                	sysenter 
  801608:	5f                   	pop    %edi
  801609:	5e                   	pop    %esi
  80160a:	5d                   	pop    %ebp
  80160b:	5c                   	pop    %esp
  80160c:	5b                   	pop    %ebx
  80160d:	5a                   	pop    %edx
  80160e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80160f:	85 c0                	test   %eax,%eax
  801611:	7e 28                	jle    80163b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  801613:	89 44 24 10          	mov    %eax,0x10(%esp)
  801617:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80161e:	00 
  80161f:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  801626:	00 
  801627:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80162e:	00 
  80162f:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  801636:	e8 85 ec ff ff       	call   8002c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80163b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80163e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801641:	89 ec                	mov    %ebp,%esp
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	89 1c 24             	mov    %ebx,(%esp)
  80164e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801652:	ba 00 00 00 00       	mov    $0x0,%edx
  801657:	b8 0c 00 00 00       	mov    $0xc,%eax
  80165c:	89 d1                	mov    %edx,%ecx
  80165e:	89 d3                	mov    %edx,%ebx
  801660:	89 d7                	mov    %edx,%edi
  801662:	51                   	push   %ecx
  801663:	52                   	push   %edx
  801664:	53                   	push   %ebx
  801665:	54                   	push   %esp
  801666:	55                   	push   %ebp
  801667:	56                   	push   %esi
  801668:	57                   	push   %edi
  801669:	54                   	push   %esp
  80166a:	5d                   	pop    %ebp
  80166b:	8d 35 73 16 80 00    	lea    0x801673,%esi
  801671:	0f 34                	sysenter 
  801673:	5f                   	pop    %edi
  801674:	5e                   	pop    %esi
  801675:	5d                   	pop    %ebp
  801676:	5c                   	pop    %esp
  801677:	5b                   	pop    %ebx
  801678:	5a                   	pop    %edx
  801679:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80167a:	8b 1c 24             	mov    (%esp),%ebx
  80167d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801681:	89 ec                	mov    %ebp,%esp
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	89 1c 24             	mov    %ebx,(%esp)
  80168e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801692:	bb 00 00 00 00       	mov    $0x0,%ebx
  801697:	b8 04 00 00 00       	mov    $0x4,%eax
  80169c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80169f:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a2:	89 df                	mov    %ebx,%edi
  8016a4:	51                   	push   %ecx
  8016a5:	52                   	push   %edx
  8016a6:	53                   	push   %ebx
  8016a7:	54                   	push   %esp
  8016a8:	55                   	push   %ebp
  8016a9:	56                   	push   %esi
  8016aa:	57                   	push   %edi
  8016ab:	54                   	push   %esp
  8016ac:	5d                   	pop    %ebp
  8016ad:	8d 35 b5 16 80 00    	lea    0x8016b5,%esi
  8016b3:	0f 34                	sysenter 
  8016b5:	5f                   	pop    %edi
  8016b6:	5e                   	pop    %esi
  8016b7:	5d                   	pop    %ebp
  8016b8:	5c                   	pop    %esp
  8016b9:	5b                   	pop    %ebx
  8016ba:	5a                   	pop    %edx
  8016bb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8016bc:	8b 1c 24             	mov    (%esp),%ebx
  8016bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016c3:	89 ec                	mov    %ebp,%esp
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	89 1c 24             	mov    %ebx,(%esp)
  8016d0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8016d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8016de:	89 d1                	mov    %edx,%ecx
  8016e0:	89 d3                	mov    %edx,%ebx
  8016e2:	89 d7                	mov    %edx,%edi
  8016e4:	51                   	push   %ecx
  8016e5:	52                   	push   %edx
  8016e6:	53                   	push   %ebx
  8016e7:	54                   	push   %esp
  8016e8:	55                   	push   %ebp
  8016e9:	56                   	push   %esi
  8016ea:	57                   	push   %edi
  8016eb:	54                   	push   %esp
  8016ec:	5d                   	pop    %ebp
  8016ed:	8d 35 f5 16 80 00    	lea    0x8016f5,%esi
  8016f3:	0f 34                	sysenter 
  8016f5:	5f                   	pop    %edi
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	5c                   	pop    %esp
  8016f9:	5b                   	pop    %ebx
  8016fa:	5a                   	pop    %edx
  8016fb:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8016fc:	8b 1c 24             	mov    (%esp),%ebx
  8016ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801703:	89 ec                	mov    %ebp,%esp
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	83 ec 28             	sub    $0x28,%esp
  80170d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801710:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801713:	b9 00 00 00 00       	mov    $0x0,%ecx
  801718:	b8 03 00 00 00       	mov    $0x3,%eax
  80171d:	8b 55 08             	mov    0x8(%ebp),%edx
  801720:	89 cb                	mov    %ecx,%ebx
  801722:	89 cf                	mov    %ecx,%edi
  801724:	51                   	push   %ecx
  801725:	52                   	push   %edx
  801726:	53                   	push   %ebx
  801727:	54                   	push   %esp
  801728:	55                   	push   %ebp
  801729:	56                   	push   %esi
  80172a:	57                   	push   %edi
  80172b:	54                   	push   %esp
  80172c:	5d                   	pop    %ebp
  80172d:	8d 35 35 17 80 00    	lea    0x801735,%esi
  801733:	0f 34                	sysenter 
  801735:	5f                   	pop    %edi
  801736:	5e                   	pop    %esi
  801737:	5d                   	pop    %ebp
  801738:	5c                   	pop    %esp
  801739:	5b                   	pop    %ebx
  80173a:	5a                   	pop    %edx
  80173b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80173c:	85 c0                	test   %eax,%eax
  80173e:	7e 28                	jle    801768 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  801740:	89 44 24 10          	mov    %eax,0x10(%esp)
  801744:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80174b:	00 
  80174c:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  801753:	00 
  801754:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80175b:	00 
  80175c:	c7 04 24 bd 2d 80 00 	movl   $0x802dbd,(%esp)
  801763:	e8 58 eb ff ff       	call   8002c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801768:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80176b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80176e:	89 ec                	mov    %ebp,%esp
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    
	...

00801780 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	05 00 00 00 30       	add    $0x30000000,%eax
  80178b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
  801799:	89 04 24             	mov    %eax,(%esp)
  80179c:	e8 df ff ff ff       	call   801780 <fd2num>
  8017a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8017a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	57                   	push   %edi
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8017b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8017b9:	a8 01                	test   $0x1,%al
  8017bb:	74 36                	je     8017f3 <fd_alloc+0x48>
  8017bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8017c2:	a8 01                	test   $0x1,%al
  8017c4:	74 2d                	je     8017f3 <fd_alloc+0x48>
  8017c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8017cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8017d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	c1 ea 16             	shr    $0x16,%edx
  8017dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8017df:	f6 c2 01             	test   $0x1,%dl
  8017e2:	74 14                	je     8017f8 <fd_alloc+0x4d>
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	c1 ea 0c             	shr    $0xc,%edx
  8017e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8017ec:	f6 c2 01             	test   $0x1,%dl
  8017ef:	75 10                	jne    801801 <fd_alloc+0x56>
  8017f1:	eb 05                	jmp    8017f8 <fd_alloc+0x4d>
  8017f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8017f8:	89 1f                	mov    %ebx,(%edi)
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017ff:	eb 17                	jmp    801818 <fd_alloc+0x6d>
  801801:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801806:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80180b:	75 c8                	jne    8017d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80180d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801813:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5f                   	pop    %edi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	83 f8 1f             	cmp    $0x1f,%eax
  801826:	77 36                	ja     80185e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801828:	05 00 00 0d 00       	add    $0xd0000,%eax
  80182d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801830:	89 c2                	mov    %eax,%edx
  801832:	c1 ea 16             	shr    $0x16,%edx
  801835:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80183c:	f6 c2 01             	test   $0x1,%dl
  80183f:	74 1d                	je     80185e <fd_lookup+0x41>
  801841:	89 c2                	mov    %eax,%edx
  801843:	c1 ea 0c             	shr    $0xc,%edx
  801846:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80184d:	f6 c2 01             	test   $0x1,%dl
  801850:	74 0c                	je     80185e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801852:	8b 55 0c             	mov    0xc(%ebp),%edx
  801855:	89 02                	mov    %eax,(%edx)
  801857:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80185c:	eb 05                	jmp    801863 <fd_lookup+0x46>
  80185e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80186e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801872:	8b 45 08             	mov    0x8(%ebp),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 a0 ff ff ff       	call   80181d <fd_lookup>
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 0e                	js     80188f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801881:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801884:	8b 55 0c             	mov    0xc(%ebp),%edx
  801887:	89 50 04             	mov    %edx,0x4(%eax)
  80188a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	83 ec 10             	sub    $0x10,%esp
  801899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80189f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8018a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018a9:	be 4c 2e 80 00       	mov    $0x802e4c,%esi
		if (devtab[i]->dev_id == dev_id) {
  8018ae:	39 08                	cmp    %ecx,(%eax)
  8018b0:	75 10                	jne    8018c2 <dev_lookup+0x31>
  8018b2:	eb 04                	jmp    8018b8 <dev_lookup+0x27>
  8018b4:	39 08                	cmp    %ecx,(%eax)
  8018b6:	75 0a                	jne    8018c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8018b8:	89 03                	mov    %eax,(%ebx)
  8018ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8018bf:	90                   	nop
  8018c0:	eb 31                	jmp    8018f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018c2:	83 c2 01             	add    $0x1,%edx
  8018c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	75 e8                	jne    8018b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8018cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8018d1:	8b 40 48             	mov    0x48(%eax),%eax
  8018d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018dc:	c7 04 24 cc 2d 80 00 	movl   $0x802dcc,(%esp)
  8018e3:	e8 91 ea ff ff       	call   800379 <cprintf>
	*dev = 0;
  8018e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	5b                   	pop    %ebx
  8018f7:	5e                   	pop    %esi
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    

008018fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 24             	sub    $0x24,%esp
  801901:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801904:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	89 04 24             	mov    %eax,(%esp)
  801911:	e8 07 ff ff ff       	call   80181d <fd_lookup>
  801916:	85 c0                	test   %eax,%eax
  801918:	78 53                	js     80196d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801924:	8b 00                	mov    (%eax),%eax
  801926:	89 04 24             	mov    %eax,(%esp)
  801929:	e8 63 ff ff ff       	call   801891 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 3b                	js     80196d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801932:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801937:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80193e:	74 2d                	je     80196d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801940:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801943:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80194a:	00 00 00 
	stat->st_isdir = 0;
  80194d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801954:	00 00 00 
	stat->st_dev = dev;
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801960:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801964:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801967:	89 14 24             	mov    %edx,(%esp)
  80196a:	ff 50 14             	call   *0x14(%eax)
}
  80196d:	83 c4 24             	add    $0x24,%esp
  801970:	5b                   	pop    %ebx
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	53                   	push   %ebx
  801977:	83 ec 24             	sub    $0x24,%esp
  80197a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801980:	89 44 24 04          	mov    %eax,0x4(%esp)
  801984:	89 1c 24             	mov    %ebx,(%esp)
  801987:	e8 91 fe ff ff       	call   80181d <fd_lookup>
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 5f                	js     8019ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801990:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801993:	89 44 24 04          	mov    %eax,0x4(%esp)
  801997:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199a:	8b 00                	mov    (%eax),%eax
  80199c:	89 04 24             	mov    %eax,(%esp)
  80199f:	e8 ed fe ff ff       	call   801891 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 47                	js     8019ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019ab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8019af:	75 23                	jne    8019d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019b1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019b6:	8b 40 48             	mov    0x48(%eax),%eax
  8019b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c1:	c7 04 24 ec 2d 80 00 	movl   $0x802dec,(%esp)
  8019c8:	e8 ac e9 ff ff       	call   800379 <cprintf>
  8019cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019d2:	eb 1b                	jmp    8019ef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8019d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d7:	8b 48 18             	mov    0x18(%eax),%ecx
  8019da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019df:	85 c9                	test   %ecx,%ecx
  8019e1:	74 0c                	je     8019ef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ea:	89 14 24             	mov    %edx,(%esp)
  8019ed:	ff d1                	call   *%ecx
}
  8019ef:	83 c4 24             	add    $0x24,%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	53                   	push   %ebx
  8019f9:	83 ec 24             	sub    $0x24,%esp
  8019fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a06:	89 1c 24             	mov    %ebx,(%esp)
  801a09:	e8 0f fe ff ff       	call   80181d <fd_lookup>
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 66                	js     801a78 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1c:	8b 00                	mov    (%eax),%eax
  801a1e:	89 04 24             	mov    %eax,(%esp)
  801a21:	e8 6b fe ff ff       	call   801891 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 4e                	js     801a78 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a2d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801a31:	75 23                	jne    801a56 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a33:	a1 08 40 80 00       	mov    0x804008,%eax
  801a38:	8b 40 48             	mov    0x48(%eax),%eax
  801a3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a43:	c7 04 24 10 2e 80 00 	movl   $0x802e10,(%esp)
  801a4a:	e8 2a e9 ff ff       	call   800379 <cprintf>
  801a4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a54:	eb 22                	jmp    801a78 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a59:	8b 48 0c             	mov    0xc(%eax),%ecx
  801a5c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a61:	85 c9                	test   %ecx,%ecx
  801a63:	74 13                	je     801a78 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a65:	8b 45 10             	mov    0x10(%ebp),%eax
  801a68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a73:	89 14 24             	mov    %edx,(%esp)
  801a76:	ff d1                	call   *%ecx
}
  801a78:	83 c4 24             	add    $0x24,%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	53                   	push   %ebx
  801a82:	83 ec 24             	sub    $0x24,%esp
  801a85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8f:	89 1c 24             	mov    %ebx,(%esp)
  801a92:	e8 86 fd ff ff       	call   80181d <fd_lookup>
  801a97:	85 c0                	test   %eax,%eax
  801a99:	78 6b                	js     801b06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa5:	8b 00                	mov    (%eax),%eax
  801aa7:	89 04 24             	mov    %eax,(%esp)
  801aaa:	e8 e2 fd ff ff       	call   801891 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 53                	js     801b06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ab3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ab6:	8b 42 08             	mov    0x8(%edx),%eax
  801ab9:	83 e0 03             	and    $0x3,%eax
  801abc:	83 f8 01             	cmp    $0x1,%eax
  801abf:	75 23                	jne    801ae4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ac1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ac6:	8b 40 48             	mov    0x48(%eax),%eax
  801ac9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad1:	c7 04 24 2d 2e 80 00 	movl   $0x802e2d,(%esp)
  801ad8:	e8 9c e8 ff ff       	call   800379 <cprintf>
  801add:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801ae2:	eb 22                	jmp    801b06 <read+0x88>
	}
	if (!dev->dev_read)
  801ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae7:	8b 48 08             	mov    0x8(%eax),%ecx
  801aea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801aef:	85 c9                	test   %ecx,%ecx
  801af1:	74 13                	je     801b06 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801af3:	8b 45 10             	mov    0x10(%ebp),%eax
  801af6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b01:	89 14 24             	mov    %edx,(%esp)
  801b04:	ff d1                	call   *%ecx
}
  801b06:	83 c4 24             	add    $0x24,%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	57                   	push   %edi
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	83 ec 1c             	sub    $0x1c,%esp
  801b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b18:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2a:	85 f6                	test   %esi,%esi
  801b2c:	74 29                	je     801b57 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b2e:	89 f0                	mov    %esi,%eax
  801b30:	29 d0                	sub    %edx,%eax
  801b32:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b36:	03 55 0c             	add    0xc(%ebp),%edx
  801b39:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b3d:	89 3c 24             	mov    %edi,(%esp)
  801b40:	e8 39 ff ff ff       	call   801a7e <read>
		if (m < 0)
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 0e                	js     801b57 <readn+0x4b>
			return m;
		if (m == 0)
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	74 08                	je     801b55 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b4d:	01 c3                	add    %eax,%ebx
  801b4f:	89 da                	mov    %ebx,%edx
  801b51:	39 f3                	cmp    %esi,%ebx
  801b53:	72 d9                	jb     801b2e <readn+0x22>
  801b55:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b57:	83 c4 1c             	add    $0x1c,%esp
  801b5a:	5b                   	pop    %ebx
  801b5b:	5e                   	pop    %esi
  801b5c:	5f                   	pop    %edi
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 20             	sub    $0x20,%esp
  801b67:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b6a:	89 34 24             	mov    %esi,(%esp)
  801b6d:	e8 0e fc ff ff       	call   801780 <fd2num>
  801b72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b75:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b79:	89 04 24             	mov    %eax,(%esp)
  801b7c:	e8 9c fc ff ff       	call   80181d <fd_lookup>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 05                	js     801b8c <fd_close+0x2d>
  801b87:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b8a:	74 0c                	je     801b98 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801b8c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  801b90:	19 c0                	sbb    %eax,%eax
  801b92:	f7 d0                	not    %eax
  801b94:	21 c3                	and    %eax,%ebx
  801b96:	eb 3d                	jmp    801bd5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9f:	8b 06                	mov    (%esi),%eax
  801ba1:	89 04 24             	mov    %eax,(%esp)
  801ba4:	e8 e8 fc ff ff       	call   801891 <dev_lookup>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 16                	js     801bc5 <fd_close+0x66>
		if (dev->dev_close)
  801baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb2:	8b 40 10             	mov    0x10(%eax),%eax
  801bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	74 07                	je     801bc5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  801bbe:	89 34 24             	mov    %esi,(%esp)
  801bc1:	ff d0                	call   *%eax
  801bc3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801bc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd0:	e8 29 f9 ff ff       	call   8014fe <sys_page_unmap>
	return r;
}
  801bd5:	89 d8                	mov    %ebx,%eax
  801bd7:	83 c4 20             	add    $0x20,%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 27 fc ff ff       	call   80181d <fd_lookup>
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 13                	js     801c0d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801bfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c01:	00 
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 52 ff ff ff       	call   801b5f <fd_close>
}
  801c0d:	c9                   	leave  
  801c0e:	c3                   	ret    

00801c0f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 18             	sub    $0x18,%esp
  801c15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c22:	00 
  801c23:	8b 45 08             	mov    0x8(%ebp),%eax
  801c26:	89 04 24             	mov    %eax,(%esp)
  801c29:	e8 79 03 00 00       	call   801fa7 <open>
  801c2e:	89 c3                	mov    %eax,%ebx
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 1b                	js     801c4f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3b:	89 1c 24             	mov    %ebx,(%esp)
  801c3e:	e8 b7 fc ff ff       	call   8018fa <fstat>
  801c43:	89 c6                	mov    %eax,%esi
	close(fd);
  801c45:	89 1c 24             	mov    %ebx,(%esp)
  801c48:	e8 91 ff ff ff       	call   801bde <close>
  801c4d:	89 f3                	mov    %esi,%ebx
	return r;
}
  801c4f:	89 d8                	mov    %ebx,%eax
  801c51:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c54:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c57:	89 ec                	mov    %ebp,%esp
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	83 ec 14             	sub    $0x14,%esp
  801c62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801c67:	89 1c 24             	mov    %ebx,(%esp)
  801c6a:	e8 6f ff ff ff       	call   801bde <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c6f:	83 c3 01             	add    $0x1,%ebx
  801c72:	83 fb 20             	cmp    $0x20,%ebx
  801c75:	75 f0                	jne    801c67 <close_all+0xc>
		close(i);
}
  801c77:	83 c4 14             	add    $0x14,%esp
  801c7a:	5b                   	pop    %ebx
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    

00801c7d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	83 ec 58             	sub    $0x58,%esp
  801c83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c96:	8b 45 08             	mov    0x8(%ebp),%eax
  801c99:	89 04 24             	mov    %eax,(%esp)
  801c9c:	e8 7c fb ff ff       	call   80181d <fd_lookup>
  801ca1:	89 c3                	mov    %eax,%ebx
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	0f 88 e0 00 00 00    	js     801d8b <dup+0x10e>
		return r;
	close(newfdnum);
  801cab:	89 3c 24             	mov    %edi,(%esp)
  801cae:	e8 2b ff ff ff       	call   801bde <close>

	newfd = INDEX2FD(newfdnum);
  801cb3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801cb9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801cbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 c9 fa ff ff       	call   801790 <fd2data>
  801cc7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801cc9:	89 34 24             	mov    %esi,(%esp)
  801ccc:	e8 bf fa ff ff       	call   801790 <fd2data>
  801cd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801cd4:	89 da                	mov    %ebx,%edx
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	c1 e8 16             	shr    $0x16,%eax
  801cdb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ce2:	a8 01                	test   $0x1,%al
  801ce4:	74 43                	je     801d29 <dup+0xac>
  801ce6:	c1 ea 0c             	shr    $0xc,%edx
  801ce9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cf0:	a8 01                	test   $0x1,%al
  801cf2:	74 35                	je     801d29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801cf4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cfb:	25 07 0e 00 00       	and    $0xe07,%eax
  801d00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d12:	00 
  801d13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d1e:	e8 47 f8 ff ff       	call   80156a <sys_page_map>
  801d23:	89 c3                	mov    %eax,%ebx
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 3f                	js     801d68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d2c:	89 c2                	mov    %eax,%edx
  801d2e:	c1 ea 0c             	shr    $0xc,%edx
  801d31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d4d:	00 
  801d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d59:	e8 0c f8 ff ff       	call   80156a <sys_page_map>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 04                	js     801d68 <dup+0xeb>
  801d64:	89 fb                	mov    %edi,%ebx
  801d66:	eb 23                	jmp    801d8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d73:	e8 86 f7 ff ff       	call   8014fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d86:	e8 73 f7 ff ff       	call   8014fe <sys_page_unmap>
	return r;
}
  801d8b:	89 d8                	mov    %ebx,%eax
  801d8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d96:	89 ec                	mov    %ebp,%esp
  801d98:	5d                   	pop    %ebp
  801d99:	c3                   	ret    
	...

00801d9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 18             	sub    $0x18,%esp
  801da2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801da5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801da8:	89 c3                	mov    %eax,%ebx
  801daa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801dac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801db3:	75 11                	jne    801dc6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801db5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801dbc:	e8 9f 07 00 00       	call   802560 <ipc_find_env>
  801dc1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801dc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801dcd:	00 
  801dce:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801dd5:	00 
  801dd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dda:	a1 00 40 80 00       	mov    0x804000,%eax
  801ddf:	89 04 24             	mov    %eax,(%esp)
  801de2:	e8 c4 07 00 00       	call   8025ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801de7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dee:	00 
  801def:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dfa:	e8 2a 08 00 00       	call   802629 <ipc_recv>
}
  801dff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e05:	89 ec                	mov    %ebp,%esp
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e12:	8b 40 0c             	mov    0xc(%eax),%eax
  801e15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e22:	ba 00 00 00 00       	mov    $0x0,%edx
  801e27:	b8 02 00 00 00       	mov    $0x2,%eax
  801e2c:	e8 6b ff ff ff       	call   801d9c <fsipc>
}
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e39:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801e3f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801e44:	ba 00 00 00 00       	mov    $0x0,%edx
  801e49:	b8 06 00 00 00       	mov    $0x6,%eax
  801e4e:	e8 49 ff ff ff       	call   801d9c <fsipc>
}
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e60:	b8 08 00 00 00       	mov    $0x8,%eax
  801e65:	e8 32 ff ff ff       	call   801d9c <fsipc>
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	53                   	push   %ebx
  801e70:	83 ec 14             	sub    $0x14,%esp
  801e73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e76:	8b 45 08             	mov    0x8(%ebp),%eax
  801e79:	8b 40 0c             	mov    0xc(%eax),%eax
  801e7c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e81:	ba 00 00 00 00       	mov    $0x0,%edx
  801e86:	b8 05 00 00 00       	mov    $0x5,%eax
  801e8b:	e8 0c ff ff ff       	call   801d9c <fsipc>
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 2b                	js     801ebf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e94:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e9b:	00 
  801e9c:	89 1c 24             	mov    %ebx,(%esp)
  801e9f:	e8 06 ee ff ff       	call   800caa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ea4:	a1 80 50 80 00       	mov    0x805080,%eax
  801ea9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801eaf:	a1 84 50 80 00       	mov    0x805084,%eax
  801eb4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801eba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801ebf:	83 c4 14             	add    $0x14,%esp
  801ec2:	5b                   	pop    %ebx
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    

00801ec5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	83 ec 18             	sub    $0x18,%esp
  801ecb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ece:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ed3:	76 05                	jbe    801eda <devfile_write+0x15>
  801ed5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  801eda:	8b 55 08             	mov    0x8(%ebp),%edx
  801edd:	8b 52 0c             	mov    0xc(%edx),%edx
  801ee0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  801ee6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  801eeb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801efd:	e8 93 ef ff ff       	call   800e95 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801f02:	ba 00 00 00 00       	mov    $0x0,%edx
  801f07:	b8 04 00 00 00       	mov    $0x4,%eax
  801f0c:	e8 8b fe ff ff       	call   801d9c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	53                   	push   %ebx
  801f17:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  801f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801f20:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  801f25:	8b 45 10             	mov    0x10(%ebp),%eax
  801f28:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  801f2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f32:	b8 03 00 00 00       	mov    $0x3,%eax
  801f37:	e8 60 fe ff ff       	call   801d9c <fsipc>
  801f3c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	78 17                	js     801f59 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801f42:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f46:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801f4d:	00 
  801f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 3c ef ff ff       	call   800e95 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801f59:	89 d8                	mov    %ebx,%eax
  801f5b:	83 c4 14             	add    $0x14,%esp
  801f5e:	5b                   	pop    %ebx
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	53                   	push   %ebx
  801f65:	83 ec 14             	sub    $0x14,%esp
  801f68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801f6b:	89 1c 24             	mov    %ebx,(%esp)
  801f6e:	e8 ed ec ff ff       	call   800c60 <strlen>
  801f73:	89 c2                	mov    %eax,%edx
  801f75:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801f7a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801f80:	7f 1f                	jg     801fa1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f86:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f8d:	e8 18 ed ff ff       	call   800caa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801f92:	ba 00 00 00 00       	mov    $0x0,%edx
  801f97:	b8 07 00 00 00       	mov    $0x7,%eax
  801f9c:	e8 fb fd ff ff       	call   801d9c <fsipc>
}
  801fa1:	83 c4 14             	add    $0x14,%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    

00801fa7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	83 ec 28             	sub    $0x28,%esp
  801fad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fb0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801fb3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801fb6:	89 34 24             	mov    %esi,(%esp)
  801fb9:	e8 a2 ec ff ff       	call   800c60 <strlen>
  801fbe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801fc3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fc8:	7f 6d                	jg     802037 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  801fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcd:	89 04 24             	mov    %eax,(%esp)
  801fd0:	e8 d6 f7 ff ff       	call   8017ab <fd_alloc>
  801fd5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	78 5c                	js     802037 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  801fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fde:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801fe3:	89 34 24             	mov    %esi,(%esp)
  801fe6:	e8 75 ec ff ff       	call   800c60 <strlen>
  801feb:	83 c0 01             	add    $0x1,%eax
  801fee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ff2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ff6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ffd:	e8 93 ee ff ff       	call   800e95 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  802002:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802005:	b8 01 00 00 00       	mov    $0x1,%eax
  80200a:	e8 8d fd ff ff       	call   801d9c <fsipc>
  80200f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  802011:	85 c0                	test   %eax,%eax
  802013:	79 15                	jns    80202a <open+0x83>
             fd_close(fd,0);
  802015:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80201c:	00 
  80201d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802020:	89 04 24             	mov    %eax,(%esp)
  802023:	e8 37 fb ff ff       	call   801b5f <fd_close>
             return r;
  802028:	eb 0d                	jmp    802037 <open+0x90>
        }
        return fd2num(fd);
  80202a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202d:	89 04 24             	mov    %eax,(%esp)
  802030:	e8 4b f7 ff ff       	call   801780 <fd2num>
  802035:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  802037:	89 d8                	mov    %ebx,%eax
  802039:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80203c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80203f:	89 ec                	mov    %ebp,%esp
  802041:	5d                   	pop    %ebp
  802042:	c3                   	ret    
	...

00802050 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802056:	c7 44 24 04 58 2e 80 	movl   $0x802e58,0x4(%esp)
  80205d:	00 
  80205e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802061:	89 04 24             	mov    %eax,(%esp)
  802064:	e8 41 ec ff ff       	call   800caa <strcpy>
	return 0;
}
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	53                   	push   %ebx
  802074:	83 ec 14             	sub    $0x14,%esp
  802077:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80207a:	89 1c 24             	mov    %ebx,(%esp)
  80207d:	e8 1a 06 00 00       	call   80269c <pageref>
  802082:	89 c2                	mov    %eax,%edx
  802084:	b8 00 00 00 00       	mov    $0x0,%eax
  802089:	83 fa 01             	cmp    $0x1,%edx
  80208c:	75 0b                	jne    802099 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80208e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802091:	89 04 24             	mov    %eax,(%esp)
  802094:	e8 b9 02 00 00       	call   802352 <nsipc_close>
	else
		return 0;
}
  802099:	83 c4 14             	add    $0x14,%esp
  80209c:	5b                   	pop    %ebx
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    

0080209f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8020a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020ac:	00 
  8020ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020be:	8b 40 0c             	mov    0xc(%eax),%eax
  8020c1:	89 04 24             	mov    %eax,(%esp)
  8020c4:	e8 c5 02 00 00       	call   80238e <nsipc_send>
}
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    

008020cb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8020d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020d8:	00 
  8020d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8020ed:	89 04 24             	mov    %eax,(%esp)
  8020f0:	e8 0c 03 00 00       	call   802401 <nsipc_recv>
}
  8020f5:	c9                   	leave  
  8020f6:	c3                   	ret    

008020f7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8020f7:	55                   	push   %ebp
  8020f8:	89 e5                	mov    %esp,%ebp
  8020fa:	56                   	push   %esi
  8020fb:	53                   	push   %ebx
  8020fc:	83 ec 20             	sub    $0x20,%esp
  8020ff:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802104:	89 04 24             	mov    %eax,(%esp)
  802107:	e8 9f f6 ff ff       	call   8017ab <fd_alloc>
  80210c:	89 c3                	mov    %eax,%ebx
  80210e:	85 c0                	test   %eax,%eax
  802110:	78 21                	js     802133 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802112:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802119:	00 
  80211a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802121:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802128:	e8 ab f4 ff ff       	call   8015d8 <sys_page_alloc>
  80212d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80212f:	85 c0                	test   %eax,%eax
  802131:	79 0a                	jns    80213d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802133:	89 34 24             	mov    %esi,(%esp)
  802136:	e8 17 02 00 00       	call   802352 <nsipc_close>
		return r;
  80213b:	eb 28                	jmp    802165 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80213d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802146:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802152:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802155:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215b:	89 04 24             	mov    %eax,(%esp)
  80215e:	e8 1d f6 ff ff       	call   801780 <fd2num>
  802163:	89 c3                	mov    %eax,%ebx
}
  802165:	89 d8                	mov    %ebx,%eax
  802167:	83 c4 20             	add    $0x20,%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802174:	8b 45 10             	mov    0x10(%ebp),%eax
  802177:	89 44 24 08          	mov    %eax,0x8(%esp)
  80217b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802182:	8b 45 08             	mov    0x8(%ebp),%eax
  802185:	89 04 24             	mov    %eax,(%esp)
  802188:	e8 79 01 00 00       	call   802306 <nsipc_socket>
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 05                	js     802196 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802191:	e8 61 ff ff ff       	call   8020f7 <alloc_sockfd>
}
  802196:	c9                   	leave  
  802197:	c3                   	ret    

00802198 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80219e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8021a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a5:	89 04 24             	mov    %eax,(%esp)
  8021a8:	e8 70 f6 ff ff       	call   80181d <fd_lookup>
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	78 15                	js     8021c6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8021b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021b4:	8b 0a                	mov    (%edx),%ecx
  8021b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8021bb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  8021c1:	75 03                	jne    8021c6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8021c3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    

008021c8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d1:	e8 c2 ff ff ff       	call   802198 <fd2sockid>
  8021d6:	85 c0                	test   %eax,%eax
  8021d8:	78 0f                	js     8021e9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8021da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e1:	89 04 24             	mov    %eax,(%esp)
  8021e4:	e8 47 01 00 00       	call   802330 <nsipc_listen>
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    

008021eb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f4:	e8 9f ff ff ff       	call   802198 <fd2sockid>
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	78 16                	js     802213 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8021fd:	8b 55 10             	mov    0x10(%ebp),%edx
  802200:	89 54 24 08          	mov    %edx,0x8(%esp)
  802204:	8b 55 0c             	mov    0xc(%ebp),%edx
  802207:	89 54 24 04          	mov    %edx,0x4(%esp)
  80220b:	89 04 24             	mov    %eax,(%esp)
  80220e:	e8 6e 02 00 00       	call   802481 <nsipc_connect>
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	e8 75 ff ff ff       	call   802198 <fd2sockid>
  802223:	85 c0                	test   %eax,%eax
  802225:	78 0f                	js     802236 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80222a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80222e:	89 04 24             	mov    %eax,(%esp)
  802231:	e8 36 01 00 00       	call   80236c <nsipc_shutdown>
}
  802236:	c9                   	leave  
  802237:	c3                   	ret    

00802238 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802238:	55                   	push   %ebp
  802239:	89 e5                	mov    %esp,%ebp
  80223b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80223e:	8b 45 08             	mov    0x8(%ebp),%eax
  802241:	e8 52 ff ff ff       	call   802198 <fd2sockid>
  802246:	85 c0                	test   %eax,%eax
  802248:	78 16                	js     802260 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80224a:	8b 55 10             	mov    0x10(%ebp),%edx
  80224d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802251:	8b 55 0c             	mov    0xc(%ebp),%edx
  802254:	89 54 24 04          	mov    %edx,0x4(%esp)
  802258:	89 04 24             	mov    %eax,(%esp)
  80225b:	e8 60 02 00 00       	call   8024c0 <nsipc_bind>
}
  802260:	c9                   	leave  
  802261:	c3                   	ret    

00802262 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802268:	8b 45 08             	mov    0x8(%ebp),%eax
  80226b:	e8 28 ff ff ff       	call   802198 <fd2sockid>
  802270:	85 c0                	test   %eax,%eax
  802272:	78 1f                	js     802293 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802274:	8b 55 10             	mov    0x10(%ebp),%edx
  802277:	89 54 24 08          	mov    %edx,0x8(%esp)
  80227b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802282:	89 04 24             	mov    %eax,(%esp)
  802285:	e8 75 02 00 00       	call   8024ff <nsipc_accept>
  80228a:	85 c0                	test   %eax,%eax
  80228c:	78 05                	js     802293 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80228e:	e8 64 fe ff ff       	call   8020f7 <alloc_sockfd>
}
  802293:	c9                   	leave  
  802294:	c3                   	ret    
	...

008022a0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 14             	sub    $0x14,%esp
  8022a7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8022a9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8022b0:	75 11                	jne    8022c3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8022b2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8022b9:	e8 a2 02 00 00       	call   802560 <ipc_find_env>
  8022be:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8022c3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8022ca:	00 
  8022cb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8022d2:	00 
  8022d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8022dc:	89 04 24             	mov    %eax,(%esp)
  8022df:	e8 c7 02 00 00       	call   8025ab <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8022e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022eb:	00 
  8022ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022f3:	00 
  8022f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fb:	e8 29 03 00 00       	call   802629 <ipc_recv>
}
  802300:	83 c4 14             	add    $0x14,%esp
  802303:	5b                   	pop    %ebx
  802304:	5d                   	pop    %ebp
  802305:	c3                   	ret    

00802306 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80230c:	8b 45 08             	mov    0x8(%ebp),%eax
  80230f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802314:	8b 45 0c             	mov    0xc(%ebp),%eax
  802317:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80231c:	8b 45 10             	mov    0x10(%ebp),%eax
  80231f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802324:	b8 09 00 00 00       	mov    $0x9,%eax
  802329:	e8 72 ff ff ff       	call   8022a0 <nsipc>
}
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802336:	8b 45 08             	mov    0x8(%ebp),%eax
  802339:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80233e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802341:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802346:	b8 06 00 00 00       	mov    $0x6,%eax
  80234b:	e8 50 ff ff ff       	call   8022a0 <nsipc>
}
  802350:	c9                   	leave  
  802351:	c3                   	ret    

00802352 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802352:	55                   	push   %ebp
  802353:	89 e5                	mov    %esp,%ebp
  802355:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802358:	8b 45 08             	mov    0x8(%ebp),%eax
  80235b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802360:	b8 04 00 00 00       	mov    $0x4,%eax
  802365:	e8 36 ff ff ff       	call   8022a0 <nsipc>
}
  80236a:	c9                   	leave  
  80236b:	c3                   	ret    

0080236c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802372:	8b 45 08             	mov    0x8(%ebp),%eax
  802375:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80237a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802382:	b8 03 00 00 00       	mov    $0x3,%eax
  802387:	e8 14 ff ff ff       	call   8022a0 <nsipc>
}
  80238c:	c9                   	leave  
  80238d:	c3                   	ret    

0080238e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
  802391:	53                   	push   %ebx
  802392:	83 ec 14             	sub    $0x14,%esp
  802395:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802398:	8b 45 08             	mov    0x8(%ebp),%eax
  80239b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8023a0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8023a6:	7e 24                	jle    8023cc <nsipc_send+0x3e>
  8023a8:	c7 44 24 0c 64 2e 80 	movl   $0x802e64,0xc(%esp)
  8023af:	00 
  8023b0:	c7 44 24 08 70 2e 80 	movl   $0x802e70,0x8(%esp)
  8023b7:	00 
  8023b8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8023bf:	00 
  8023c0:	c7 04 24 85 2e 80 00 	movl   $0x802e85,(%esp)
  8023c7:	e8 f4 de ff ff       	call   8002c0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8023de:	e8 b2 ea ff ff       	call   800e95 <memmove>
	nsipcbuf.send.req_size = size;
  8023e3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8023e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8023ec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8023f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8023f6:	e8 a5 fe ff ff       	call   8022a0 <nsipc>
}
  8023fb:	83 c4 14             	add    $0x14,%esp
  8023fe:	5b                   	pop    %ebx
  8023ff:	5d                   	pop    %ebp
  802400:	c3                   	ret    

00802401 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802401:	55                   	push   %ebp
  802402:	89 e5                	mov    %esp,%ebp
  802404:	56                   	push   %esi
  802405:	53                   	push   %ebx
  802406:	83 ec 10             	sub    $0x10,%esp
  802409:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80240c:	8b 45 08             	mov    0x8(%ebp),%eax
  80240f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802414:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80241a:	8b 45 14             	mov    0x14(%ebp),%eax
  80241d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802422:	b8 07 00 00 00       	mov    $0x7,%eax
  802427:	e8 74 fe ff ff       	call   8022a0 <nsipc>
  80242c:	89 c3                	mov    %eax,%ebx
  80242e:	85 c0                	test   %eax,%eax
  802430:	78 46                	js     802478 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802432:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802437:	7f 04                	jg     80243d <nsipc_recv+0x3c>
  802439:	39 c6                	cmp    %eax,%esi
  80243b:	7d 24                	jge    802461 <nsipc_recv+0x60>
  80243d:	c7 44 24 0c 91 2e 80 	movl   $0x802e91,0xc(%esp)
  802444:	00 
  802445:	c7 44 24 08 70 2e 80 	movl   $0x802e70,0x8(%esp)
  80244c:	00 
  80244d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802454:	00 
  802455:	c7 04 24 85 2e 80 00 	movl   $0x802e85,(%esp)
  80245c:	e8 5f de ff ff       	call   8002c0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802461:	89 44 24 08          	mov    %eax,0x8(%esp)
  802465:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80246c:	00 
  80246d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802470:	89 04 24             	mov    %eax,(%esp)
  802473:	e8 1d ea ff ff       	call   800e95 <memmove>
	}

	return r;
}
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	83 c4 10             	add    $0x10,%esp
  80247d:	5b                   	pop    %ebx
  80247e:	5e                   	pop    %esi
  80247f:	5d                   	pop    %ebp
  802480:	c3                   	ret    

00802481 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	53                   	push   %ebx
  802485:	83 ec 14             	sub    $0x14,%esp
  802488:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80248b:	8b 45 08             	mov    0x8(%ebp),%eax
  80248e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802493:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802497:	8b 45 0c             	mov    0xc(%ebp),%eax
  80249a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8024a5:	e8 eb e9 ff ff       	call   800e95 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8024aa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8024b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8024b5:	e8 e6 fd ff ff       	call   8022a0 <nsipc>
}
  8024ba:	83 c4 14             	add    $0x14,%esp
  8024bd:	5b                   	pop    %ebx
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 14             	sub    $0x14,%esp
  8024c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024dd:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8024e4:	e8 ac e9 ff ff       	call   800e95 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024e9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8024ef:	b8 02 00 00 00       	mov    $0x2,%eax
  8024f4:	e8 a7 fd ff ff       	call   8022a0 <nsipc>
}
  8024f9:	83 c4 14             	add    $0x14,%esp
  8024fc:	5b                   	pop    %ebx
  8024fd:	5d                   	pop    %ebp
  8024fe:	c3                   	ret    

008024ff <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024ff:	55                   	push   %ebp
  802500:	89 e5                	mov    %esp,%ebp
  802502:	83 ec 18             	sub    $0x18,%esp
  802505:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802508:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80250b:	8b 45 08             	mov    0x8(%ebp),%eax
  80250e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802513:	b8 01 00 00 00       	mov    $0x1,%eax
  802518:	e8 83 fd ff ff       	call   8022a0 <nsipc>
  80251d:	89 c3                	mov    %eax,%ebx
  80251f:	85 c0                	test   %eax,%eax
  802521:	78 25                	js     802548 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802523:	be 10 60 80 00       	mov    $0x806010,%esi
  802528:	8b 06                	mov    (%esi),%eax
  80252a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80252e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802535:	00 
  802536:	8b 45 0c             	mov    0xc(%ebp),%eax
  802539:	89 04 24             	mov    %eax,(%esp)
  80253c:	e8 54 e9 ff ff       	call   800e95 <memmove>
		*addrlen = ret->ret_addrlen;
  802541:	8b 16                	mov    (%esi),%edx
  802543:	8b 45 10             	mov    0x10(%ebp),%eax
  802546:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802548:	89 d8                	mov    %ebx,%eax
  80254a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80254d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802550:	89 ec                	mov    %ebp,%esp
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
	...

00802560 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
  802563:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802566:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80256c:	b8 01 00 00 00       	mov    $0x1,%eax
  802571:	39 ca                	cmp    %ecx,%edx
  802573:	75 04                	jne    802579 <ipc_find_env+0x19>
  802575:	b0 00                	mov    $0x0,%al
  802577:	eb 12                	jmp    80258b <ipc_find_env+0x2b>
  802579:	89 c2                	mov    %eax,%edx
  80257b:	c1 e2 07             	shl    $0x7,%edx
  80257e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802585:	8b 12                	mov    (%edx),%edx
  802587:	39 ca                	cmp    %ecx,%edx
  802589:	75 10                	jne    80259b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80258b:	89 c2                	mov    %eax,%edx
  80258d:	c1 e2 07             	shl    $0x7,%edx
  802590:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802597:	8b 00                	mov    (%eax),%eax
  802599:	eb 0e                	jmp    8025a9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80259b:	83 c0 01             	add    $0x1,%eax
  80259e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025a3:	75 d4                	jne    802579 <ipc_find_env+0x19>
  8025a5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8025a9:	5d                   	pop    %ebp
  8025aa:	c3                   	ret    

008025ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025ab:	55                   	push   %ebp
  8025ac:	89 e5                	mov    %esp,%ebp
  8025ae:	57                   	push   %edi
  8025af:	56                   	push   %esi
  8025b0:	53                   	push   %ebx
  8025b1:	83 ec 1c             	sub    $0x1c,%esp
  8025b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8025b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8025bd:	85 db                	test   %ebx,%ebx
  8025bf:	74 19                	je     8025da <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8025c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8025c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025d0:	89 34 24             	mov    %esi,(%esp)
  8025d3:	e8 a1 ed ff ff       	call   801379 <sys_ipc_try_send>
  8025d8:	eb 1b                	jmp    8025f5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8025da:	8b 45 14             	mov    0x14(%ebp),%eax
  8025dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025e1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8025e8:	ee 
  8025e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025ed:	89 34 24             	mov    %esi,(%esp)
  8025f0:	e8 84 ed ff ff       	call   801379 <sys_ipc_try_send>
           if(ret == 0)
  8025f5:	85 c0                	test   %eax,%eax
  8025f7:	74 28                	je     802621 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8025f9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025fc:	74 1c                	je     80261a <ipc_send+0x6f>
              panic("ipc send error");
  8025fe:	c7 44 24 08 a6 2e 80 	movl   $0x802ea6,0x8(%esp)
  802605:	00 
  802606:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80260d:	00 
  80260e:	c7 04 24 b5 2e 80 00 	movl   $0x802eb5,(%esp)
  802615:	e8 a6 dc ff ff       	call   8002c0 <_panic>
           sys_yield();
  80261a:	e8 26 f0 ff ff       	call   801645 <sys_yield>
        }
  80261f:	eb 9c                	jmp    8025bd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802621:	83 c4 1c             	add    $0x1c,%esp
  802624:	5b                   	pop    %ebx
  802625:	5e                   	pop    %esi
  802626:	5f                   	pop    %edi
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    

00802629 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802629:	55                   	push   %ebp
  80262a:	89 e5                	mov    %esp,%ebp
  80262c:	56                   	push   %esi
  80262d:	53                   	push   %ebx
  80262e:	83 ec 10             	sub    $0x10,%esp
  802631:	8b 75 08             	mov    0x8(%ebp),%esi
  802634:	8b 45 0c             	mov    0xc(%ebp),%eax
  802637:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80263a:	85 c0                	test   %eax,%eax
  80263c:	75 0e                	jne    80264c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80263e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802645:	e8 c4 ec ff ff       	call   80130e <sys_ipc_recv>
  80264a:	eb 08                	jmp    802654 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80264c:	89 04 24             	mov    %eax,(%esp)
  80264f:	e8 ba ec ff ff       	call   80130e <sys_ipc_recv>
        if(ret == 0){
  802654:	85 c0                	test   %eax,%eax
  802656:	75 26                	jne    80267e <ipc_recv+0x55>
           if(from_env_store)
  802658:	85 f6                	test   %esi,%esi
  80265a:	74 0a                	je     802666 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80265c:	a1 08 40 80 00       	mov    0x804008,%eax
  802661:	8b 40 78             	mov    0x78(%eax),%eax
  802664:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802666:	85 db                	test   %ebx,%ebx
  802668:	74 0a                	je     802674 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80266a:	a1 08 40 80 00       	mov    0x804008,%eax
  80266f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802672:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802674:	a1 08 40 80 00       	mov    0x804008,%eax
  802679:	8b 40 74             	mov    0x74(%eax),%eax
  80267c:	eb 14                	jmp    802692 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80267e:	85 f6                	test   %esi,%esi
  802680:	74 06                	je     802688 <ipc_recv+0x5f>
              *from_env_store = 0;
  802682:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802688:	85 db                	test   %ebx,%ebx
  80268a:	74 06                	je     802692 <ipc_recv+0x69>
              *perm_store = 0;
  80268c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802692:	83 c4 10             	add    $0x10,%esp
  802695:	5b                   	pop    %ebx
  802696:	5e                   	pop    %esi
  802697:	5d                   	pop    %ebp
  802698:	c3                   	ret    
  802699:	00 00                	add    %al,(%eax)
	...

0080269c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80269c:	55                   	push   %ebp
  80269d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80269f:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a2:	89 c2                	mov    %eax,%edx
  8026a4:	c1 ea 16             	shr    $0x16,%edx
  8026a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026ae:	f6 c2 01             	test   $0x1,%dl
  8026b1:	74 20                	je     8026d3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8026b3:	c1 e8 0c             	shr    $0xc,%eax
  8026b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026bd:	a8 01                	test   $0x1,%al
  8026bf:	74 12                	je     8026d3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026c1:	c1 e8 0c             	shr    $0xc,%eax
  8026c4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8026c9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8026ce:	0f b7 c0             	movzwl %ax,%eax
  8026d1:	eb 05                	jmp    8026d8 <pageref+0x3c>
  8026d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026d8:	5d                   	pop    %ebp
  8026d9:	c3                   	ret    
  8026da:	00 00                	add    %al,(%eax)
  8026dc:	00 00                	add    %al,(%eax)
	...

008026e0 <__udivdi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	89 e5                	mov    %esp,%ebp
  8026e3:	57                   	push   %edi
  8026e4:	56                   	push   %esi
  8026e5:	83 ec 10             	sub    $0x10,%esp
  8026e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8026eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8026f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026f4:	85 c0                	test   %eax,%eax
  8026f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8026f9:	75 35                	jne    802730 <__udivdi3+0x50>
  8026fb:	39 fe                	cmp    %edi,%esi
  8026fd:	77 61                	ja     802760 <__udivdi3+0x80>
  8026ff:	85 f6                	test   %esi,%esi
  802701:	75 0b                	jne    80270e <__udivdi3+0x2e>
  802703:	b8 01 00 00 00       	mov    $0x1,%eax
  802708:	31 d2                	xor    %edx,%edx
  80270a:	f7 f6                	div    %esi
  80270c:	89 c6                	mov    %eax,%esi
  80270e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802711:	31 d2                	xor    %edx,%edx
  802713:	89 f8                	mov    %edi,%eax
  802715:	f7 f6                	div    %esi
  802717:	89 c7                	mov    %eax,%edi
  802719:	89 c8                	mov    %ecx,%eax
  80271b:	f7 f6                	div    %esi
  80271d:	89 c1                	mov    %eax,%ecx
  80271f:	89 fa                	mov    %edi,%edx
  802721:	89 c8                	mov    %ecx,%eax
  802723:	83 c4 10             	add    $0x10,%esp
  802726:	5e                   	pop    %esi
  802727:	5f                   	pop    %edi
  802728:	5d                   	pop    %ebp
  802729:	c3                   	ret    
  80272a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802730:	39 f8                	cmp    %edi,%eax
  802732:	77 1c                	ja     802750 <__udivdi3+0x70>
  802734:	0f bd d0             	bsr    %eax,%edx
  802737:	83 f2 1f             	xor    $0x1f,%edx
  80273a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80273d:	75 39                	jne    802778 <__udivdi3+0x98>
  80273f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802742:	0f 86 a0 00 00 00    	jbe    8027e8 <__udivdi3+0x108>
  802748:	39 f8                	cmp    %edi,%eax
  80274a:	0f 82 98 00 00 00    	jb     8027e8 <__udivdi3+0x108>
  802750:	31 ff                	xor    %edi,%edi
  802752:	31 c9                	xor    %ecx,%ecx
  802754:	89 c8                	mov    %ecx,%eax
  802756:	89 fa                	mov    %edi,%edx
  802758:	83 c4 10             	add    $0x10,%esp
  80275b:	5e                   	pop    %esi
  80275c:	5f                   	pop    %edi
  80275d:	5d                   	pop    %ebp
  80275e:	c3                   	ret    
  80275f:	90                   	nop
  802760:	89 d1                	mov    %edx,%ecx
  802762:	89 fa                	mov    %edi,%edx
  802764:	89 c8                	mov    %ecx,%eax
  802766:	31 ff                	xor    %edi,%edi
  802768:	f7 f6                	div    %esi
  80276a:	89 c1                	mov    %eax,%ecx
  80276c:	89 fa                	mov    %edi,%edx
  80276e:	89 c8                	mov    %ecx,%eax
  802770:	83 c4 10             	add    $0x10,%esp
  802773:	5e                   	pop    %esi
  802774:	5f                   	pop    %edi
  802775:	5d                   	pop    %ebp
  802776:	c3                   	ret    
  802777:	90                   	nop
  802778:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80277c:	89 f2                	mov    %esi,%edx
  80277e:	d3 e0                	shl    %cl,%eax
  802780:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802783:	b8 20 00 00 00       	mov    $0x20,%eax
  802788:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80278b:	89 c1                	mov    %eax,%ecx
  80278d:	d3 ea                	shr    %cl,%edx
  80278f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802793:	0b 55 ec             	or     -0x14(%ebp),%edx
  802796:	d3 e6                	shl    %cl,%esi
  802798:	89 c1                	mov    %eax,%ecx
  80279a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80279d:	89 fe                	mov    %edi,%esi
  80279f:	d3 ee                	shr    %cl,%esi
  8027a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8027a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027ab:	d3 e7                	shl    %cl,%edi
  8027ad:	89 c1                	mov    %eax,%ecx
  8027af:	d3 ea                	shr    %cl,%edx
  8027b1:	09 d7                	or     %edx,%edi
  8027b3:	89 f2                	mov    %esi,%edx
  8027b5:	89 f8                	mov    %edi,%eax
  8027b7:	f7 75 ec             	divl   -0x14(%ebp)
  8027ba:	89 d6                	mov    %edx,%esi
  8027bc:	89 c7                	mov    %eax,%edi
  8027be:	f7 65 e8             	mull   -0x18(%ebp)
  8027c1:	39 d6                	cmp    %edx,%esi
  8027c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027c6:	72 30                	jb     8027f8 <__udivdi3+0x118>
  8027c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8027cf:	d3 e2                	shl    %cl,%edx
  8027d1:	39 c2                	cmp    %eax,%edx
  8027d3:	73 05                	jae    8027da <__udivdi3+0xfa>
  8027d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8027d8:	74 1e                	je     8027f8 <__udivdi3+0x118>
  8027da:	89 f9                	mov    %edi,%ecx
  8027dc:	31 ff                	xor    %edi,%edi
  8027de:	e9 71 ff ff ff       	jmp    802754 <__udivdi3+0x74>
  8027e3:	90                   	nop
  8027e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e8:	31 ff                	xor    %edi,%edi
  8027ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8027ef:	e9 60 ff ff ff       	jmp    802754 <__udivdi3+0x74>
  8027f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8027fb:	31 ff                	xor    %edi,%edi
  8027fd:	89 c8                	mov    %ecx,%eax
  8027ff:	89 fa                	mov    %edi,%edx
  802801:	83 c4 10             	add    $0x10,%esp
  802804:	5e                   	pop    %esi
  802805:	5f                   	pop    %edi
  802806:	5d                   	pop    %ebp
  802807:	c3                   	ret    
	...

00802810 <__umoddi3>:
  802810:	55                   	push   %ebp
  802811:	89 e5                	mov    %esp,%ebp
  802813:	57                   	push   %edi
  802814:	56                   	push   %esi
  802815:	83 ec 20             	sub    $0x20,%esp
  802818:	8b 55 14             	mov    0x14(%ebp),%edx
  80281b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80281e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802821:	8b 75 0c             	mov    0xc(%ebp),%esi
  802824:	85 d2                	test   %edx,%edx
  802826:	89 c8                	mov    %ecx,%eax
  802828:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80282b:	75 13                	jne    802840 <__umoddi3+0x30>
  80282d:	39 f7                	cmp    %esi,%edi
  80282f:	76 3f                	jbe    802870 <__umoddi3+0x60>
  802831:	89 f2                	mov    %esi,%edx
  802833:	f7 f7                	div    %edi
  802835:	89 d0                	mov    %edx,%eax
  802837:	31 d2                	xor    %edx,%edx
  802839:	83 c4 20             	add    $0x20,%esp
  80283c:	5e                   	pop    %esi
  80283d:	5f                   	pop    %edi
  80283e:	5d                   	pop    %ebp
  80283f:	c3                   	ret    
  802840:	39 f2                	cmp    %esi,%edx
  802842:	77 4c                	ja     802890 <__umoddi3+0x80>
  802844:	0f bd ca             	bsr    %edx,%ecx
  802847:	83 f1 1f             	xor    $0x1f,%ecx
  80284a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80284d:	75 51                	jne    8028a0 <__umoddi3+0x90>
  80284f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802852:	0f 87 e0 00 00 00    	ja     802938 <__umoddi3+0x128>
  802858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80285b:	29 f8                	sub    %edi,%eax
  80285d:	19 d6                	sbb    %edx,%esi
  80285f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802865:	89 f2                	mov    %esi,%edx
  802867:	83 c4 20             	add    $0x20,%esp
  80286a:	5e                   	pop    %esi
  80286b:	5f                   	pop    %edi
  80286c:	5d                   	pop    %ebp
  80286d:	c3                   	ret    
  80286e:	66 90                	xchg   %ax,%ax
  802870:	85 ff                	test   %edi,%edi
  802872:	75 0b                	jne    80287f <__umoddi3+0x6f>
  802874:	b8 01 00 00 00       	mov    $0x1,%eax
  802879:	31 d2                	xor    %edx,%edx
  80287b:	f7 f7                	div    %edi
  80287d:	89 c7                	mov    %eax,%edi
  80287f:	89 f0                	mov    %esi,%eax
  802881:	31 d2                	xor    %edx,%edx
  802883:	f7 f7                	div    %edi
  802885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802888:	f7 f7                	div    %edi
  80288a:	eb a9                	jmp    802835 <__umoddi3+0x25>
  80288c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 c8                	mov    %ecx,%eax
  802892:	89 f2                	mov    %esi,%edx
  802894:	83 c4 20             	add    $0x20,%esp
  802897:	5e                   	pop    %esi
  802898:	5f                   	pop    %edi
  802899:	5d                   	pop    %ebp
  80289a:	c3                   	ret    
  80289b:	90                   	nop
  80289c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028a4:	d3 e2                	shl    %cl,%edx
  8028a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8028a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8028ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8028b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8028b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8028b8:	89 fa                	mov    %edi,%edx
  8028ba:	d3 ea                	shr    %cl,%edx
  8028bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8028c3:	d3 e7                	shl    %cl,%edi
  8028c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8028c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8028cc:	89 f2                	mov    %esi,%edx
  8028ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8028d1:	89 c7                	mov    %eax,%edi
  8028d3:	d3 ea                	shr    %cl,%edx
  8028d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8028dc:	89 c2                	mov    %eax,%edx
  8028de:	d3 e6                	shl    %cl,%esi
  8028e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8028e4:	d3 ea                	shr    %cl,%edx
  8028e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028ea:	09 d6                	or     %edx,%esi
  8028ec:	89 f0                	mov    %esi,%eax
  8028ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8028f1:	d3 e7                	shl    %cl,%edi
  8028f3:	89 f2                	mov    %esi,%edx
  8028f5:	f7 75 f4             	divl   -0xc(%ebp)
  8028f8:	89 d6                	mov    %edx,%esi
  8028fa:	f7 65 e8             	mull   -0x18(%ebp)
  8028fd:	39 d6                	cmp    %edx,%esi
  8028ff:	72 2b                	jb     80292c <__umoddi3+0x11c>
  802901:	39 c7                	cmp    %eax,%edi
  802903:	72 23                	jb     802928 <__umoddi3+0x118>
  802905:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802909:	29 c7                	sub    %eax,%edi
  80290b:	19 d6                	sbb    %edx,%esi
  80290d:	89 f0                	mov    %esi,%eax
  80290f:	89 f2                	mov    %esi,%edx
  802911:	d3 ef                	shr    %cl,%edi
  802913:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802917:	d3 e0                	shl    %cl,%eax
  802919:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80291d:	09 f8                	or     %edi,%eax
  80291f:	d3 ea                	shr    %cl,%edx
  802921:	83 c4 20             	add    $0x20,%esp
  802924:	5e                   	pop    %esi
  802925:	5f                   	pop    %edi
  802926:	5d                   	pop    %ebp
  802927:	c3                   	ret    
  802928:	39 d6                	cmp    %edx,%esi
  80292a:	75 d9                	jne    802905 <__umoddi3+0xf5>
  80292c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80292f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802932:	eb d1                	jmp    802905 <__umoddi3+0xf5>
  802934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802938:	39 f2                	cmp    %esi,%edx
  80293a:	0f 82 18 ff ff ff    	jb     802858 <__umoddi3+0x48>
  802940:	e9 1d ff ff ff       	jmp    802862 <__umoddi3+0x52>
