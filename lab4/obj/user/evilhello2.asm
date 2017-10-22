
obj/user/evilhello2:     file format elf32-i386


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
  80002c:	e8 13 01 00 00       	call   800144 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <evil>:
struct Segdesc savedGate;
struct Gatedesc* gate;

// Call this function with ring0 privilege
void evil()
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800037:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800043:	b8 49 00 00 00       	mov    $0x49,%eax
  800048:	ee                   	out    %al,(%dx)
  800049:	b8 4e 00 00 00       	mov    $0x4e,%eax
  80004e:	ee                   	out    %al,(%dx)
  80004f:	b8 20 00 00 00       	mov    $0x20,%eax
  800054:	ee                   	out    %al,(%dx)
  800055:	b8 52 00 00 00       	mov    $0x52,%eax
  80005a:	ee                   	out    %al,(%dx)
  80005b:	b8 49 00 00 00       	mov    $0x49,%eax
  800060:	ee                   	out    %al,(%dx)
  800061:	b8 4e 00 00 00       	mov    $0x4e,%eax
  800066:	ee                   	out    %al,(%dx)
  800067:	b8 47 00 00 00       	mov    $0x47,%eax
  80006c:	ee                   	out    %al,(%dx)
  80006d:	b8 30 00 00 00       	mov    $0x30,%eax
  800072:	ee                   	out    %al,(%dx)
  800073:	b8 21 00 00 00       	mov    $0x21,%eax
  800078:	ee                   	out    %al,(%dx)
  800079:	ee                   	out    %al,(%dx)
  80007a:	ee                   	out    %al,(%dx)
  80007b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800080:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <wrapper>:
sgdt(struct Pseudodesc* gdtd)
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
}

void wrapper(){
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
    evil();
  800086:	e8 a9 ff ff ff       	call   800034 <evil>
    *((struct Segdesc*)gate) = savedGate;
  80008b:	8b 15 20 20 80 00    	mov    0x802020,%edx
  800091:	8b 0d 24 20 80 00    	mov    0x802024,%ecx
  800097:	a1 28 20 80 00       	mov    0x802028,%eax
  80009c:	89 10                	mov    %edx,(%eax)
  80009e:	89 48 04             	mov    %ecx,0x4(%eax)
    asm volatile("popl %ebp");
  8000a1:	5d                   	pop    %ebp
    asm volatile("lret\n\t");
  8000a2:	cb                   	lret   
}
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    

008000a5 <ring0_call>:

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	83 ec 28             	sub    $0x28,%esp
}

static void
sgdt(struct Pseudodesc* gdtd)
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
  8000ab:	0f 01 45 f2          	sgdtl  -0xe(%ebp)
    //        file if necessary.

    // Lab3 : Your Code Here
    struct Pseudodesc gdtd;
    sgdt(&gdtd);
    sys_map_kernel_page((void*)gdtd.pd_base,(void*)va);
  8000af:	c7 44 24 04 40 20 80 	movl   $0x802040,0x4(%esp)
  8000b6:	00 
  8000b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 21 05 00 00       	call   8005e3 <sys_map_kernel_page>
    gdt = (struct Segdesc*)(((PGNUM(va) << PTXSHIFT)) + (PGOFF(gdtd.pd_base)));
  8000c2:	ba 40 20 80 00       	mov    $0x802040,%edx
  8000c7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  8000cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000d0:	25 ff 0f 00 00       	and    $0xfff,%eax
  8000d5:	8d 04 02             	lea    (%edx,%eax,1),%eax
  8000d8:	a3 2c 20 80 00       	mov    %eax,0x80202c
    savedGate = *(gdt + (GD_UT >> 3));
  8000dd:	8b 50 18             	mov    0x18(%eax),%edx
  8000e0:	8b 48 1c             	mov    0x1c(%eax),%ecx
  8000e3:	89 15 20 20 80 00    	mov    %edx,0x802020
  8000e9:	89 0d 24 20 80 00    	mov    %ecx,0x802024
    gate = (struct Gatedesc*)(gdt + (GD_UT >> 3));
  8000ef:	83 c0 18             	add    $0x18,%eax
  8000f2:	a3 28 20 80 00       	mov    %eax,0x802028
    SETCALLGATE(*gate,GD_KT,wrapper,3);
  8000f7:	b9 83 00 80 00       	mov    $0x800083,%ecx
  8000fc:	66 89 08             	mov    %cx,(%eax)
  8000ff:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  800105:	c6 40 04 00          	movb   $0x0,0x4(%eax)
  800109:	0f b6 50 05          	movzbl 0x5(%eax),%edx
  80010d:	83 e2 e0             	and    $0xffffffe0,%edx
  800110:	83 ca 0c             	or     $0xc,%edx
  800113:	83 ca e0             	or     $0xffffffe0,%edx
  800116:	88 50 05             	mov    %dl,0x5(%eax)
  800119:	c1 e9 10             	shr    $0x10,%ecx
  80011c:	66 89 48 06          	mov    %cx,0x6(%eax)
    asm volatile("lcall $0x18,$0\n\t");    
  800120:	9a 00 00 00 00 18 00 	lcall  $0x18,$0x0
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <umain>:

void
umain(int argc, char **argv)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 18             	sub    $0x18,%esp
        // call the evil function in ring0
	ring0_call(&evil);
  80012f:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800136:	e8 6a ff ff ff       	call   8000a5 <ring0_call>

	// call the evil function in ring3
	evil();
  80013b:	e8 f4 fe ff ff       	call   800034 <evil>
}
  800140:	c9                   	leave  
  800141:	c3                   	ret    
	...

00800144 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 18             	sub    $0x18,%esp
  80014a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80014d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800156:	e8 ca 04 00 00       	call   800625 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	89 c2                	mov    %eax,%edx
  800162:	c1 e2 07             	shl    $0x7,%edx
  800165:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80016c:	a3 40 30 80 00       	mov    %eax,0x803040
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800171:	85 f6                	test   %esi,%esi
  800173:	7e 07                	jle    80017c <libmain+0x38>
		binaryname = argv[0];
  800175:	8b 03                	mov    (%ebx),%eax
  800177:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80017c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800180:	89 34 24             	mov    %esi,(%esp)
  800183:	e8 a1 ff ff ff       	call   800129 <umain>

	// exit gracefully
	exit();
  800188:	e8 0b 00 00 00       	call   800198 <exit>
}
  80018d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800190:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800193:	89 ec                	mov    %ebp,%esp
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    
	...

00800198 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80019e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a5:	e8 bb 04 00 00       	call   800665 <sys_env_destroy>
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 08             	sub    $0x8,%esp
  8001b2:	89 1c 24             	mov    %ebx,(%esp)
  8001b5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001be:	b8 01 00 00 00       	mov    $0x1,%eax
  8001c3:	89 d1                	mov    %edx,%ecx
  8001c5:	89 d3                	mov    %edx,%ebx
  8001c7:	89 d7                	mov    %edx,%edi
  8001c9:	51                   	push   %ecx
  8001ca:	52                   	push   %edx
  8001cb:	53                   	push   %ebx
  8001cc:	54                   	push   %esp
  8001cd:	55                   	push   %ebp
  8001ce:	56                   	push   %esi
  8001cf:	57                   	push   %edi
  8001d0:	54                   	push   %esp
  8001d1:	5d                   	pop    %ebp
  8001d2:	8d 35 da 01 80 00    	lea    0x8001da,%esi
  8001d8:	0f 34                	sysenter 
  8001da:	5f                   	pop    %edi
  8001db:	5e                   	pop    %esi
  8001dc:	5d                   	pop    %ebp
  8001dd:	5c                   	pop    %esp
  8001de:	5b                   	pop    %ebx
  8001df:	5a                   	pop    %edx
  8001e0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8001e1:	8b 1c 24             	mov    (%esp),%ebx
  8001e4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001e8:	89 ec                	mov    %ebp,%esp
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	89 1c 24             	mov    %ebx,(%esp)
  8001f5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 c3                	mov    %eax,%ebx
  800206:	89 c7                	mov    %eax,%edi
  800208:	51                   	push   %ecx
  800209:	52                   	push   %edx
  80020a:	53                   	push   %ebx
  80020b:	54                   	push   %esp
  80020c:	55                   	push   %ebp
  80020d:	56                   	push   %esi
  80020e:	57                   	push   %edi
  80020f:	54                   	push   %esp
  800210:	5d                   	pop    %ebp
  800211:	8d 35 19 02 80 00    	lea    0x800219,%esi
  800217:	0f 34                	sysenter 
  800219:	5f                   	pop    %edi
  80021a:	5e                   	pop    %esi
  80021b:	5d                   	pop    %ebp
  80021c:	5c                   	pop    %esp
  80021d:	5b                   	pop    %ebx
  80021e:	5a                   	pop    %edx
  80021f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800220:	8b 1c 24             	mov    (%esp),%ebx
  800223:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800227:	89 ec                	mov    %ebp,%esp
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 28             	sub    $0x28,%esp
  800231:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800234:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800237:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	89 df                	mov    %ebx,%edi
  800249:	51                   	push   %ecx
  80024a:	52                   	push   %edx
  80024b:	53                   	push   %ebx
  80024c:	54                   	push   %esp
  80024d:	55                   	push   %ebp
  80024e:	56                   	push   %esi
  80024f:	57                   	push   %edi
  800250:	54                   	push   %esp
  800251:	5d                   	pop    %ebp
  800252:	8d 35 5a 02 80 00    	lea    0x80025a,%esi
  800258:	0f 34                	sysenter 
  80025a:	5f                   	pop    %edi
  80025b:	5e                   	pop    %esi
  80025c:	5d                   	pop    %ebp
  80025d:	5c                   	pop    %esp
  80025e:	5b                   	pop    %ebx
  80025f:	5a                   	pop    %edx
  800260:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800261:	85 c0                	test   %eax,%eax
  800263:	7e 28                	jle    80028d <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800265:	89 44 24 10          	mov    %eax,0x10(%esp)
  800269:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800270:	00 
  800271:	c7 44 24 08 4a 17 80 	movl   $0x80174a,0x8(%esp)
  800278:	00 
  800279:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 67 17 80 00 	movl   $0x801767,(%esp)
  800288:	e8 43 04 00 00       	call   8006d0 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80028d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800290:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800293:	89 ec                	mov    %ebp,%esp
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	89 1c 24             	mov    %ebx,(%esp)
  8002a0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	89 cb                	mov    %ecx,%ebx
  8002b3:	89 cf                	mov    %ecx,%edi
  8002b5:	51                   	push   %ecx
  8002b6:	52                   	push   %edx
  8002b7:	53                   	push   %ebx
  8002b8:	54                   	push   %esp
  8002b9:	55                   	push   %ebp
  8002ba:	56                   	push   %esi
  8002bb:	57                   	push   %edi
  8002bc:	54                   	push   %esp
  8002bd:	5d                   	pop    %ebp
  8002be:	8d 35 c6 02 80 00    	lea    0x8002c6,%esi
  8002c4:	0f 34                	sysenter 
  8002c6:	5f                   	pop    %edi
  8002c7:	5e                   	pop    %esi
  8002c8:	5d                   	pop    %ebp
  8002c9:	5c                   	pop    %esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5a                   	pop    %edx
  8002cc:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8002cd:	8b 1c 24             	mov    (%esp),%ebx
  8002d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002d4:	89 ec                	mov    %ebp,%esp
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	83 ec 28             	sub    $0x28,%esp
  8002de:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002e1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f1:	89 cb                	mov    %ecx,%ebx
  8002f3:	89 cf                	mov    %ecx,%edi
  8002f5:	51                   	push   %ecx
  8002f6:	52                   	push   %edx
  8002f7:	53                   	push   %ebx
  8002f8:	54                   	push   %esp
  8002f9:	55                   	push   %ebp
  8002fa:	56                   	push   %esi
  8002fb:	57                   	push   %edi
  8002fc:	54                   	push   %esp
  8002fd:	5d                   	pop    %ebp
  8002fe:	8d 35 06 03 80 00    	lea    0x800306,%esi
  800304:	0f 34                	sysenter 
  800306:	5f                   	pop    %edi
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	5c                   	pop    %esp
  80030a:	5b                   	pop    %ebx
  80030b:	5a                   	pop    %edx
  80030c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80030d:	85 c0                	test   %eax,%eax
  80030f:	7e 28                	jle    800339 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800311:	89 44 24 10          	mov    %eax,0x10(%esp)
  800315:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80031c:	00 
  80031d:	c7 44 24 08 4a 17 80 	movl   $0x80174a,0x8(%esp)
  800324:	00 
  800325:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80032c:	00 
  80032d:	c7 04 24 67 17 80 00 	movl   $0x801767,(%esp)
  800334:	e8 97 03 00 00       	call   8006d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800339:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80033c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80033f:	89 ec                	mov    %ebp,%esp
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	83 ec 08             	sub    $0x8,%esp
  800349:	89 1c 24             	mov    %ebx,(%esp)
  80034c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800350:	b8 0c 00 00 00       	mov    $0xc,%eax
  800355:	8b 7d 14             	mov    0x14(%ebp),%edi
  800358:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80035e:	8b 55 08             	mov    0x8(%ebp),%edx
  800361:	51                   	push   %ecx
  800362:	52                   	push   %edx
  800363:	53                   	push   %ebx
  800364:	54                   	push   %esp
  800365:	55                   	push   %ebp
  800366:	56                   	push   %esi
  800367:	57                   	push   %edi
  800368:	54                   	push   %esp
  800369:	5d                   	pop    %ebp
  80036a:	8d 35 72 03 80 00    	lea    0x800372,%esi
  800370:	0f 34                	sysenter 
  800372:	5f                   	pop    %edi
  800373:	5e                   	pop    %esi
  800374:	5d                   	pop    %ebp
  800375:	5c                   	pop    %esp
  800376:	5b                   	pop    %ebx
  800377:	5a                   	pop    %edx
  800378:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800379:	8b 1c 24             	mov    (%esp),%ebx
  80037c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800380:	89 ec                	mov    %ebp,%esp
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 28             	sub    $0x28,%esp
  80038a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80038d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800390:	bb 00 00 00 00       	mov    $0x0,%ebx
  800395:	b8 0a 00 00 00       	mov    $0xa,%eax
  80039a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	89 df                	mov    %ebx,%edi
  8003a2:	51                   	push   %ecx
  8003a3:	52                   	push   %edx
  8003a4:	53                   	push   %ebx
  8003a5:	54                   	push   %esp
  8003a6:	55                   	push   %ebp
  8003a7:	56                   	push   %esi
  8003a8:	57                   	push   %edi
  8003a9:	54                   	push   %esp
  8003aa:	5d                   	pop    %ebp
  8003ab:	8d 35 b3 03 80 00    	lea    0x8003b3,%esi
  8003b1:	0f 34                	sysenter 
  8003b3:	5f                   	pop    %edi
  8003b4:	5e                   	pop    %esi
  8003b5:	5d                   	pop    %ebp
  8003b6:	5c                   	pop    %esp
  8003b7:	5b                   	pop    %ebx
  8003b8:	5a                   	pop    %edx
  8003b9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8003ba:	85 c0                	test   %eax,%eax
  8003bc:	7e 28                	jle    8003e6 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c2:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8003c9:	00 
  8003ca:	c7 44 24 08 4a 17 80 	movl   $0x80174a,0x8(%esp)
  8003d1:	00 
  8003d2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8003d9:	00 
  8003da:	c7 04 24 67 17 80 00 	movl   $0x801767,(%esp)
  8003e1:	e8 ea 02 00 00       	call   8006d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003ec:	89 ec                	mov    %ebp,%esp
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	83 ec 28             	sub    $0x28,%esp
  8003f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003f9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800401:	b8 09 00 00 00       	mov    $0x9,%eax
  800406:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800409:	8b 55 08             	mov    0x8(%ebp),%edx
  80040c:	89 df                	mov    %ebx,%edi
  80040e:	51                   	push   %ecx
  80040f:	52                   	push   %edx
  800410:	53                   	push   %ebx
  800411:	54                   	push   %esp
  800412:	55                   	push   %ebp
  800413:	56                   	push   %esi
  800414:	57                   	push   %edi
  800415:	54                   	push   %esp
  800416:	5d                   	pop    %ebp
  800417:	8d 35 1f 04 80 00    	lea    0x80041f,%esi
  80041d:	0f 34                	sysenter 
  80041f:	5f                   	pop    %edi
  800420:	5e                   	pop    %esi
  800421:	5d                   	pop    %ebp
  800422:	5c                   	pop    %esp
  800423:	5b                   	pop    %ebx
  800424:	5a                   	pop    %edx
  800425:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800426:	85 c0                	test   %eax,%eax
  800428:	7e 28                	jle    800452 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80042a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80042e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800435:	00 
  800436:	c7 44 24 08 4a 17 80 	movl   $0x80174a,0x8(%esp)
  80043d:	00 
  80043e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800445:	00 
  800446:	c7 04 24 67 17 80 00 	movl   $0x801767,(%esp)
  80044d:	e8 7e 02 00 00       	call   8006d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800452:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800455:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800458:	89 ec                	mov    %ebp,%esp
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    

0080045c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	83 ec 28             	sub    $0x28,%esp
  800462:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800465:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800468:	bb 00 00 00 00       	mov    $0x0,%ebx
  80046d:	b8 07 00 00 00       	mov    $0x7,%eax
  800472:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800475:	8b 55 08             	mov    0x8(%ebp),%edx
  800478:	89 df                	mov    %ebx,%edi
  80047a:	51                   	push   %ecx
  80047b:	52                   	push   %edx
  80047c:	53                   	push   %ebx
  80047d:	54                   	push   %esp
  80047e:	55                   	push   %ebp
  80047f:	56                   	push   %esi
  800480:	57                   	push   %edi
  800481:	54                   	push   %esp
  800482:	5d                   	pop    %ebp
  800483:	8d 35 8b 04 80 00    	lea    0x80048b,%esi
  800489:	0f 34                	sysenter 
  80048b:	5f                   	pop    %edi
  80048c:	5e                   	pop    %esi
  80048d:	5d                   	pop    %ebp
  80048e:	5c                   	pop    %esp
  80048f:	5b                   	pop    %ebx
  800490:	5a                   	pop    %edx
  800491:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800492:	85 c0                	test   %eax,%eax
  800494:	7e 28                	jle    8004be <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800496:	89 44 24 10          	mov    %eax,0x10(%esp)
  80049a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8004a1:	00 
  8004a2:	c7 44 24 08 4a 17 80 	movl   $0x80174a,0x8(%esp)
  8004a9:	00 
  8004aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004b1:	00 
  8004b2:	c7 04 24 67 17 80 00 	movl   $0x801767,(%esp)
  8004b9:	e8 12 02 00 00       	call   8006d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8004be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004c4:	89 ec                	mov    %ebp,%esp
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 28             	sub    $0x28,%esp
  8004ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004d1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004d4:	8b 7d 18             	mov    0x18(%ebp),%edi
  8004d7:	0b 7d 14             	or     0x14(%ebp),%edi
  8004da:	b8 06 00 00 00       	mov    $0x6,%eax
  8004df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e8:	51                   	push   %ecx
  8004e9:	52                   	push   %edx
  8004ea:	53                   	push   %ebx
  8004eb:	54                   	push   %esp
  8004ec:	55                   	push   %ebp
  8004ed:	56                   	push   %esi
  8004ee:	57                   	push   %edi
  8004ef:	54                   	push   %esp
  8004f0:	5d                   	pop    %ebp
  8004f1:	8d 35 f9 04 80 00    	lea    0x8004f9,%esi
  8004f7:	0f 34                	sysenter 
  8004f9:	5f                   	pop    %edi
  8004fa:	5e                   	pop    %esi
  8004fb:	5d                   	pop    %ebp
  8004fc:	5c                   	pop    %esp
  8004fd:	5b                   	pop    %ebx
  8004fe:	5a                   	pop    %edx
  8004ff:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800500:	85 c0                	test   %eax,%eax
  800502:	7e 28                	jle    80052c <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  800504:	89 44 24 10          	mov    %eax,0x10(%esp)
  800508:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80050f:	00 
  800510:	c7 44 24 08 4a 17 80 	movl   $0x80174a,0x8(%esp)
  800517:	00 
  800518:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80051f:	00 
  800520:	c7 04 24 67 17 80 00 	movl   $0x801767,(%esp)
  800527:	e8 a4 01 00 00       	call   8006d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80052c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80052f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800532:	89 ec                	mov    %ebp,%esp
  800534:	5d                   	pop    %ebp
  800535:	c3                   	ret    

00800536 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	83 ec 28             	sub    $0x28,%esp
  80053c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80053f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800542:	bf 00 00 00 00       	mov    $0x0,%edi
  800547:	b8 05 00 00 00       	mov    $0x5,%eax
  80054c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80054f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800552:	8b 55 08             	mov    0x8(%ebp),%edx
  800555:	51                   	push   %ecx
  800556:	52                   	push   %edx
  800557:	53                   	push   %ebx
  800558:	54                   	push   %esp
  800559:	55                   	push   %ebp
  80055a:	56                   	push   %esi
  80055b:	57                   	push   %edi
  80055c:	54                   	push   %esp
  80055d:	5d                   	pop    %ebp
  80055e:	8d 35 66 05 80 00    	lea    0x800566,%esi
  800564:	0f 34                	sysenter 
  800566:	5f                   	pop    %edi
  800567:	5e                   	pop    %esi
  800568:	5d                   	pop    %ebp
  800569:	5c                   	pop    %esp
  80056a:	5b                   	pop    %ebx
  80056b:	5a                   	pop    %edx
  80056c:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80056d:	85 c0                	test   %eax,%eax
  80056f:	7e 28                	jle    800599 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800571:	89 44 24 10          	mov    %eax,0x10(%esp)
  800575:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80057c:	00 
  80057d:	c7 44 24 08 4a 17 80 	movl   $0x80174a,0x8(%esp)
  800584:	00 
  800585:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80058c:	00 
  80058d:	c7 04 24 67 17 80 00 	movl   $0x801767,(%esp)
  800594:	e8 37 01 00 00       	call   8006d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800599:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80059c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80059f:	89 ec                	mov    %ebp,%esp
  8005a1:	5d                   	pop    %ebp
  8005a2:	c3                   	ret    

008005a3 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	89 1c 24             	mov    %ebx,(%esp)
  8005ac:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8005ba:	89 d1                	mov    %edx,%ecx
  8005bc:	89 d3                	mov    %edx,%ebx
  8005be:	89 d7                	mov    %edx,%edi
  8005c0:	51                   	push   %ecx
  8005c1:	52                   	push   %edx
  8005c2:	53                   	push   %ebx
  8005c3:	54                   	push   %esp
  8005c4:	55                   	push   %ebp
  8005c5:	56                   	push   %esi
  8005c6:	57                   	push   %edi
  8005c7:	54                   	push   %esp
  8005c8:	5d                   	pop    %ebp
  8005c9:	8d 35 d1 05 80 00    	lea    0x8005d1,%esi
  8005cf:	0f 34                	sysenter 
  8005d1:	5f                   	pop    %edi
  8005d2:	5e                   	pop    %esi
  8005d3:	5d                   	pop    %ebp
  8005d4:	5c                   	pop    %esp
  8005d5:	5b                   	pop    %ebx
  8005d6:	5a                   	pop    %edx
  8005d7:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8005d8:	8b 1c 24             	mov    (%esp),%ebx
  8005db:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005df:	89 ec                	mov    %ebp,%esp
  8005e1:	5d                   	pop    %ebp
  8005e2:	c3                   	ret    

008005e3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8005e3:	55                   	push   %ebp
  8005e4:	89 e5                	mov    %esp,%ebp
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	89 1c 24             	mov    %ebx,(%esp)
  8005ec:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f5:	b8 04 00 00 00       	mov    $0x4,%eax
  8005fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800600:	89 df                	mov    %ebx,%edi
  800602:	51                   	push   %ecx
  800603:	52                   	push   %edx
  800604:	53                   	push   %ebx
  800605:	54                   	push   %esp
  800606:	55                   	push   %ebp
  800607:	56                   	push   %esi
  800608:	57                   	push   %edi
  800609:	54                   	push   %esp
  80060a:	5d                   	pop    %ebp
  80060b:	8d 35 13 06 80 00    	lea    0x800613,%esi
  800611:	0f 34                	sysenter 
  800613:	5f                   	pop    %edi
  800614:	5e                   	pop    %esi
  800615:	5d                   	pop    %ebp
  800616:	5c                   	pop    %esp
  800617:	5b                   	pop    %ebx
  800618:	5a                   	pop    %edx
  800619:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80061a:	8b 1c 24             	mov    (%esp),%ebx
  80061d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800621:	89 ec                	mov    %ebp,%esp
  800623:	5d                   	pop    %ebp
  800624:	c3                   	ret    

00800625 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	89 1c 24             	mov    %ebx,(%esp)
  80062e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800632:	ba 00 00 00 00       	mov    $0x0,%edx
  800637:	b8 02 00 00 00       	mov    $0x2,%eax
  80063c:	89 d1                	mov    %edx,%ecx
  80063e:	89 d3                	mov    %edx,%ebx
  800640:	89 d7                	mov    %edx,%edi
  800642:	51                   	push   %ecx
  800643:	52                   	push   %edx
  800644:	53                   	push   %ebx
  800645:	54                   	push   %esp
  800646:	55                   	push   %ebp
  800647:	56                   	push   %esi
  800648:	57                   	push   %edi
  800649:	54                   	push   %esp
  80064a:	5d                   	pop    %ebp
  80064b:	8d 35 53 06 80 00    	lea    0x800653,%esi
  800651:	0f 34                	sysenter 
  800653:	5f                   	pop    %edi
  800654:	5e                   	pop    %esi
  800655:	5d                   	pop    %ebp
  800656:	5c                   	pop    %esp
  800657:	5b                   	pop    %ebx
  800658:	5a                   	pop    %edx
  800659:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80065a:	8b 1c 24             	mov    (%esp),%ebx
  80065d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800661:	89 ec                	mov    %ebp,%esp
  800663:	5d                   	pop    %ebp
  800664:	c3                   	ret    

00800665 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	83 ec 28             	sub    $0x28,%esp
  80066b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80066e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	b8 03 00 00 00       	mov    $0x3,%eax
  80067b:	8b 55 08             	mov    0x8(%ebp),%edx
  80067e:	89 cb                	mov    %ecx,%ebx
  800680:	89 cf                	mov    %ecx,%edi
  800682:	51                   	push   %ecx
  800683:	52                   	push   %edx
  800684:	53                   	push   %ebx
  800685:	54                   	push   %esp
  800686:	55                   	push   %ebp
  800687:	56                   	push   %esi
  800688:	57                   	push   %edi
  800689:	54                   	push   %esp
  80068a:	5d                   	pop    %ebp
  80068b:	8d 35 93 06 80 00    	lea    0x800693,%esi
  800691:	0f 34                	sysenter 
  800693:	5f                   	pop    %edi
  800694:	5e                   	pop    %esi
  800695:	5d                   	pop    %ebp
  800696:	5c                   	pop    %esp
  800697:	5b                   	pop    %ebx
  800698:	5a                   	pop    %edx
  800699:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80069a:	85 c0                	test   %eax,%eax
  80069c:	7e 28                	jle    8006c6 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80069e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006a2:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8006a9:	00 
  8006aa:	c7 44 24 08 4a 17 80 	movl   $0x80174a,0x8(%esp)
  8006b1:	00 
  8006b2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8006b9:	00 
  8006ba:	c7 04 24 67 17 80 00 	movl   $0x801767,(%esp)
  8006c1:	e8 0a 00 00 00       	call   8006d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8006c6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8006c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006cc:	89 ec                	mov    %ebp,%esp
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	56                   	push   %esi
  8006d4:	53                   	push   %ebx
  8006d5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8006d8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8006db:	a1 44 30 80 00       	mov    0x803044,%eax
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 10                	je     8006f4 <_panic+0x24>
		cprintf("%s: ", argv0);
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	c7 04 24 75 17 80 00 	movl   $0x801775,(%esp)
  8006ef:	e8 ad 00 00 00       	call   8007a1 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006f4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8006fa:	e8 26 ff ff ff       	call   800625 <sys_getenvid>
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800702:	89 54 24 10          	mov    %edx,0x10(%esp)
  800706:	8b 55 08             	mov    0x8(%ebp),%edx
  800709:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800711:	89 44 24 04          	mov    %eax,0x4(%esp)
  800715:	c7 04 24 7c 17 80 00 	movl   $0x80177c,(%esp)
  80071c:	e8 80 00 00 00       	call   8007a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800721:	89 74 24 04          	mov    %esi,0x4(%esp)
  800725:	8b 45 10             	mov    0x10(%ebp),%eax
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	e8 10 00 00 00       	call   800740 <vcprintf>
	cprintf("\n");
  800730:	c7 04 24 7a 17 80 00 	movl   $0x80177a,(%esp)
  800737:	e8 65 00 00 00       	call   8007a1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80073c:	cc                   	int3   
  80073d:	eb fd                	jmp    80073c <_panic+0x6c>
	...

00800740 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800749:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800750:	00 00 00 
	b.cnt = 0;
  800753:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80075a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800771:	89 44 24 04          	mov    %eax,0x4(%esp)
  800775:	c7 04 24 bb 07 80 00 	movl   $0x8007bb,(%esp)
  80077c:	e8 cb 01 00 00       	call   80094c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800781:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800791:	89 04 24             	mov    %eax,(%esp)
  800794:	e8 53 fa ff ff       	call   8001ec <sys_cputs>

	return b.cnt;
}
  800799:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8007a7:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8007aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	89 04 24             	mov    %eax,(%esp)
  8007b4:	e8 87 ff ff ff       	call   800740 <vcprintf>
	va_end(ap);

	return cnt;
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 14             	sub    $0x14,%esp
  8007c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007c5:	8b 03                	mov    (%ebx),%eax
  8007c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ca:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8007ce:	83 c0 01             	add    $0x1,%eax
  8007d1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8007d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007d8:	75 19                	jne    8007f3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8007da:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8007e1:	00 
  8007e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8007e5:	89 04 24             	mov    %eax,(%esp)
  8007e8:	e8 ff f9 ff ff       	call   8001ec <sys_cputs>
		b->idx = 0;
  8007ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8007f3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8007f7:	83 c4 14             	add    $0x14,%esp
  8007fa:	5b                   	pop    %ebx
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    
  8007fd:	00 00                	add    %al,(%eax)
	...

00800800 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	57                   	push   %edi
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
  800806:	83 ec 4c             	sub    $0x4c,%esp
  800809:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80080c:	89 d6                	mov    %edx,%esi
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
  800817:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80081a:	8b 45 10             	mov    0x10(%ebp),%eax
  80081d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800820:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800823:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800826:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082b:	39 d1                	cmp    %edx,%ecx
  80082d:	72 07                	jb     800836 <printnum_v2+0x36>
  80082f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800832:	39 d0                	cmp    %edx,%eax
  800834:	77 5f                	ja     800895 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800836:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80083a:	83 eb 01             	sub    $0x1,%ebx
  80083d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800841:	89 44 24 08          	mov    %eax,0x8(%esp)
  800845:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800849:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80084d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800850:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800853:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800856:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80085a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800861:	00 
  800862:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800865:	89 04 24             	mov    %eax,(%esp)
  800868:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80086b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80086f:	e8 4c 0c 00 00       	call   8014c0 <__udivdi3>
  800874:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800877:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80087a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80087e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	89 54 24 04          	mov    %edx,0x4(%esp)
  800889:	89 f2                	mov    %esi,%edx
  80088b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80088e:	e8 6d ff ff ff       	call   800800 <printnum_v2>
  800893:	eb 1e                	jmp    8008b3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800895:	83 ff 2d             	cmp    $0x2d,%edi
  800898:	74 19                	je     8008b3 <printnum_v2+0xb3>
		while (--width > 0)
  80089a:	83 eb 01             	sub    $0x1,%ebx
  80089d:	85 db                	test   %ebx,%ebx
  80089f:	90                   	nop
  8008a0:	7e 11                	jle    8008b3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8008a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a6:	89 3c 24             	mov    %edi,(%esp)
  8008a9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8008ac:	83 eb 01             	sub    $0x1,%ebx
  8008af:	85 db                	test   %ebx,%ebx
  8008b1:	7f ef                	jg     8008a2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8008bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8008c9:	00 
  8008ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008cd:	89 14 24             	mov    %edx,(%esp)
  8008d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008d7:	e8 14 0d 00 00       	call   8015f0 <__umoddi3>
  8008dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e0:	0f be 80 9f 17 80 00 	movsbl 0x80179f(%eax),%eax
  8008e7:	89 04 24             	mov    %eax,(%esp)
  8008ea:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8008ed:	83 c4 4c             	add    $0x4c,%esp
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5f                   	pop    %edi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8008f8:	83 fa 01             	cmp    $0x1,%edx
  8008fb:	7e 0e                	jle    80090b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8008fd:	8b 10                	mov    (%eax),%edx
  8008ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800902:	89 08                	mov    %ecx,(%eax)
  800904:	8b 02                	mov    (%edx),%eax
  800906:	8b 52 04             	mov    0x4(%edx),%edx
  800909:	eb 22                	jmp    80092d <getuint+0x38>
	else if (lflag)
  80090b:	85 d2                	test   %edx,%edx
  80090d:	74 10                	je     80091f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80090f:	8b 10                	mov    (%eax),%edx
  800911:	8d 4a 04             	lea    0x4(%edx),%ecx
  800914:	89 08                	mov    %ecx,(%eax)
  800916:	8b 02                	mov    (%edx),%eax
  800918:	ba 00 00 00 00       	mov    $0x0,%edx
  80091d:	eb 0e                	jmp    80092d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80091f:	8b 10                	mov    (%eax),%edx
  800921:	8d 4a 04             	lea    0x4(%edx),%ecx
  800924:	89 08                	mov    %ecx,(%eax)
  800926:	8b 02                	mov    (%edx),%eax
  800928:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800935:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800939:	8b 10                	mov    (%eax),%edx
  80093b:	3b 50 04             	cmp    0x4(%eax),%edx
  80093e:	73 0a                	jae    80094a <sprintputch+0x1b>
		*b->buf++ = ch;
  800940:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800943:	88 0a                	mov    %cl,(%edx)
  800945:	83 c2 01             	add    $0x1,%edx
  800948:	89 10                	mov    %edx,(%eax)
}
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	83 ec 6c             	sub    $0x6c,%esp
  800955:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800958:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80095f:	eb 1a                	jmp    80097b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800961:	85 c0                	test   %eax,%eax
  800963:	0f 84 66 06 00 00    	je     800fcf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800970:	89 04 24             	mov    %eax,(%esp)
  800973:	ff 55 08             	call   *0x8(%ebp)
  800976:	eb 03                	jmp    80097b <vprintfmt+0x2f>
  800978:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80097b:	0f b6 07             	movzbl (%edi),%eax
  80097e:	83 c7 01             	add    $0x1,%edi
  800981:	83 f8 25             	cmp    $0x25,%eax
  800984:	75 db                	jne    800961 <vprintfmt+0x15>
  800986:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80098a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800996:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80099b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8009a2:	be 00 00 00 00       	mov    $0x0,%esi
  8009a7:	eb 06                	jmp    8009af <vprintfmt+0x63>
  8009a9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8009ad:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009af:	0f b6 17             	movzbl (%edi),%edx
  8009b2:	0f b6 c2             	movzbl %dl,%eax
  8009b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009b8:	8d 47 01             	lea    0x1(%edi),%eax
  8009bb:	83 ea 23             	sub    $0x23,%edx
  8009be:	80 fa 55             	cmp    $0x55,%dl
  8009c1:	0f 87 60 05 00 00    	ja     800f27 <vprintfmt+0x5db>
  8009c7:	0f b6 d2             	movzbl %dl,%edx
  8009ca:	ff 24 95 e0 18 80 00 	jmp    *0x8018e0(,%edx,4)
  8009d1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8009d6:	eb d5                	jmp    8009ad <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8009d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009db:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8009de:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8009e1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8009e4:	83 ff 09             	cmp    $0x9,%edi
  8009e7:	76 08                	jbe    8009f1 <vprintfmt+0xa5>
  8009e9:	eb 40                	jmp    800a2b <vprintfmt+0xdf>
  8009eb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8009ef:	eb bc                	jmp    8009ad <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009f1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8009f4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8009f7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8009fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8009fe:	8d 7a d0             	lea    -0x30(%edx),%edi
  800a01:	83 ff 09             	cmp    $0x9,%edi
  800a04:	76 eb                	jbe    8009f1 <vprintfmt+0xa5>
  800a06:	eb 23                	jmp    800a2b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a08:	8b 55 14             	mov    0x14(%ebp),%edx
  800a0b:	8d 5a 04             	lea    0x4(%edx),%ebx
  800a0e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800a11:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800a13:	eb 16                	jmp    800a2b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800a15:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a18:	c1 fa 1f             	sar    $0x1f,%edx
  800a1b:	f7 d2                	not    %edx
  800a1d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800a20:	eb 8b                	jmp    8009ad <vprintfmt+0x61>
  800a22:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800a29:	eb 82                	jmp    8009ad <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  800a2b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a2f:	0f 89 78 ff ff ff    	jns    8009ad <vprintfmt+0x61>
  800a35:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800a38:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  800a3b:	e9 6d ff ff ff       	jmp    8009ad <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a40:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800a43:	e9 65 ff ff ff       	jmp    8009ad <vprintfmt+0x61>
  800a48:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4e:	8d 50 04             	lea    0x4(%eax),%edx
  800a51:	89 55 14             	mov    %edx,0x14(%ebp)
  800a54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a57:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a5b:	8b 00                	mov    (%eax),%eax
  800a5d:	89 04 24             	mov    %eax,(%esp)
  800a60:	ff 55 08             	call   *0x8(%ebp)
  800a63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800a66:	e9 10 ff ff ff       	jmp    80097b <vprintfmt+0x2f>
  800a6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a71:	8d 50 04             	lea    0x4(%eax),%edx
  800a74:	89 55 14             	mov    %edx,0x14(%ebp)
  800a77:	8b 00                	mov    (%eax),%eax
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	c1 fa 1f             	sar    $0x1f,%edx
  800a7e:	31 d0                	xor    %edx,%eax
  800a80:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a82:	83 f8 08             	cmp    $0x8,%eax
  800a85:	7f 0b                	jg     800a92 <vprintfmt+0x146>
  800a87:	8b 14 85 40 1a 80 00 	mov    0x801a40(,%eax,4),%edx
  800a8e:	85 d2                	test   %edx,%edx
  800a90:	75 26                	jne    800ab8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800a92:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a96:	c7 44 24 08 b0 17 80 	movl   $0x8017b0,0x8(%esp)
  800a9d:	00 
  800a9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800aa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa8:	89 1c 24             	mov    %ebx,(%esp)
  800aab:	e8 a7 05 00 00       	call   801057 <printfmt>
  800ab0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ab3:	e9 c3 fe ff ff       	jmp    80097b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800ab8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800abc:	c7 44 24 08 b9 17 80 	movl   $0x8017b9,0x8(%esp)
  800ac3:	00 
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	89 14 24             	mov    %edx,(%esp)
  800ad1:	e8 81 05 00 00       	call   801057 <printfmt>
  800ad6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ad9:	e9 9d fe ff ff       	jmp    80097b <vprintfmt+0x2f>
  800ade:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ae1:	89 c7                	mov    %eax,%edi
  800ae3:	89 d9                	mov    %ebx,%ecx
  800ae5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ae8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800aeb:	8b 45 14             	mov    0x14(%ebp),%eax
  800aee:	8d 50 04             	lea    0x4(%eax),%edx
  800af1:	89 55 14             	mov    %edx,0x14(%ebp)
  800af4:	8b 30                	mov    (%eax),%esi
  800af6:	85 f6                	test   %esi,%esi
  800af8:	75 05                	jne    800aff <vprintfmt+0x1b3>
  800afa:	be bc 17 80 00       	mov    $0x8017bc,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  800aff:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800b03:	7e 06                	jle    800b0b <vprintfmt+0x1bf>
  800b05:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800b09:	75 10                	jne    800b1b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b0b:	0f be 06             	movsbl (%esi),%eax
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	0f 85 a2 00 00 00    	jne    800bb8 <vprintfmt+0x26c>
  800b16:	e9 92 00 00 00       	jmp    800bad <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b1b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b1f:	89 34 24             	mov    %esi,(%esp)
  800b22:	e8 74 05 00 00       	call   80109b <strnlen>
  800b27:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800b2a:	29 c2                	sub    %eax,%edx
  800b2c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800b2f:	85 d2                	test   %edx,%edx
  800b31:	7e d8                	jle    800b0b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800b33:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800b37:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800b3a:	89 d3                	mov    %edx,%ebx
  800b3c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800b3f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800b42:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b45:	89 ce                	mov    %ecx,%esi
  800b47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b4b:	89 34 24             	mov    %esi,(%esp)
  800b4e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b51:	83 eb 01             	sub    $0x1,%ebx
  800b54:	85 db                	test   %ebx,%ebx
  800b56:	7f ef                	jg     800b47 <vprintfmt+0x1fb>
  800b58:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800b5b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800b5e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800b61:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800b68:	eb a1                	jmp    800b0b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b6a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800b6e:	74 1b                	je     800b8b <vprintfmt+0x23f>
  800b70:	8d 50 e0             	lea    -0x20(%eax),%edx
  800b73:	83 fa 5e             	cmp    $0x5e,%edx
  800b76:	76 13                	jbe    800b8b <vprintfmt+0x23f>
					putch('?', putdat);
  800b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b86:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b89:	eb 0d                	jmp    800b98 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800b8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b92:	89 04 24             	mov    %eax,(%esp)
  800b95:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b98:	83 ef 01             	sub    $0x1,%edi
  800b9b:	0f be 06             	movsbl (%esi),%eax
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	74 05                	je     800ba7 <vprintfmt+0x25b>
  800ba2:	83 c6 01             	add    $0x1,%esi
  800ba5:	eb 1a                	jmp    800bc1 <vprintfmt+0x275>
  800ba7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800baa:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800bb1:	7f 1f                	jg     800bd2 <vprintfmt+0x286>
  800bb3:	e9 c0 fd ff ff       	jmp    800978 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bb8:	83 c6 01             	add    $0x1,%esi
  800bbb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800bbe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800bc1:	85 db                	test   %ebx,%ebx
  800bc3:	78 a5                	js     800b6a <vprintfmt+0x21e>
  800bc5:	83 eb 01             	sub    $0x1,%ebx
  800bc8:	79 a0                	jns    800b6a <vprintfmt+0x21e>
  800bca:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800bcd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800bd0:	eb db                	jmp    800bad <vprintfmt+0x261>
  800bd2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800bdb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bde:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800be9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800beb:	83 eb 01             	sub    $0x1,%ebx
  800bee:	85 db                	test   %ebx,%ebx
  800bf0:	7f ec                	jg     800bde <vprintfmt+0x292>
  800bf2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800bf5:	e9 81 fd ff ff       	jmp    80097b <vprintfmt+0x2f>
  800bfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bfd:	83 fe 01             	cmp    $0x1,%esi
  800c00:	7e 10                	jle    800c12 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800c02:	8b 45 14             	mov    0x14(%ebp),%eax
  800c05:	8d 50 08             	lea    0x8(%eax),%edx
  800c08:	89 55 14             	mov    %edx,0x14(%ebp)
  800c0b:	8b 18                	mov    (%eax),%ebx
  800c0d:	8b 70 04             	mov    0x4(%eax),%esi
  800c10:	eb 26                	jmp    800c38 <vprintfmt+0x2ec>
	else if (lflag)
  800c12:	85 f6                	test   %esi,%esi
  800c14:	74 12                	je     800c28 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800c16:	8b 45 14             	mov    0x14(%ebp),%eax
  800c19:	8d 50 04             	lea    0x4(%eax),%edx
  800c1c:	89 55 14             	mov    %edx,0x14(%ebp)
  800c1f:	8b 18                	mov    (%eax),%ebx
  800c21:	89 de                	mov    %ebx,%esi
  800c23:	c1 fe 1f             	sar    $0x1f,%esi
  800c26:	eb 10                	jmp    800c38 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800c28:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2b:	8d 50 04             	lea    0x4(%eax),%edx
  800c2e:	89 55 14             	mov    %edx,0x14(%ebp)
  800c31:	8b 18                	mov    (%eax),%ebx
  800c33:	89 de                	mov    %ebx,%esi
  800c35:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800c38:	83 f9 01             	cmp    $0x1,%ecx
  800c3b:	75 1e                	jne    800c5b <vprintfmt+0x30f>
                               if((long long)num > 0){
  800c3d:	85 f6                	test   %esi,%esi
  800c3f:	78 1a                	js     800c5b <vprintfmt+0x30f>
  800c41:	85 f6                	test   %esi,%esi
  800c43:	7f 05                	jg     800c4a <vprintfmt+0x2fe>
  800c45:	83 fb 00             	cmp    $0x0,%ebx
  800c48:	76 11                	jbe    800c5b <vprintfmt+0x30f>
                                   putch('+',putdat);
  800c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c51:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800c58:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  800c5b:	85 f6                	test   %esi,%esi
  800c5d:	78 13                	js     800c72 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c5f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800c62:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800c65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c68:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6d:	e9 da 00 00 00       	jmp    800d4c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c79:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c80:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c83:	89 da                	mov    %ebx,%edx
  800c85:	89 f1                	mov    %esi,%ecx
  800c87:	f7 da                	neg    %edx
  800c89:	83 d1 00             	adc    $0x0,%ecx
  800c8c:	f7 d9                	neg    %ecx
  800c8e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800c91:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800c94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9c:	e9 ab 00 00 00       	jmp    800d4c <vprintfmt+0x400>
  800ca1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ca4:	89 f2                	mov    %esi,%edx
  800ca6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca9:	e8 47 fc ff ff       	call   8008f5 <getuint>
  800cae:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800cb1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800cb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800cbc:	e9 8b 00 00 00       	jmp    800d4c <vprintfmt+0x400>
  800cc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ccb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cd2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800cd5:	89 f2                	mov    %esi,%edx
  800cd7:	8d 45 14             	lea    0x14(%ebp),%eax
  800cda:	e8 16 fc ff ff       	call   8008f5 <getuint>
  800cdf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800ce2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800ce5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ce8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  800ced:	eb 5d                	jmp    800d4c <vprintfmt+0x400>
  800cef:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800cf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cf5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cf9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d00:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800d03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d07:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d0e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800d11:	8b 45 14             	mov    0x14(%ebp),%eax
  800d14:	8d 50 04             	lea    0x4(%eax),%edx
  800d17:	89 55 14             	mov    %edx,0x14(%ebp)
  800d1a:	8b 10                	mov    (%eax),%edx
  800d1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d21:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800d24:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800d27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d2a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800d2f:	eb 1b                	jmp    800d4c <vprintfmt+0x400>
  800d31:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d34:	89 f2                	mov    %esi,%edx
  800d36:	8d 45 14             	lea    0x14(%ebp),%eax
  800d39:	e8 b7 fb ff ff       	call   8008f5 <getuint>
  800d3e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800d41:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800d44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d47:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d4c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800d50:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800d53:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d56:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800d5a:	77 09                	ja     800d65 <vprintfmt+0x419>
  800d5c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800d5f:	0f 82 ac 00 00 00    	jb     800e11 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800d65:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800d68:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800d6c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d6f:	83 ea 01             	sub    $0x1,%edx
  800d72:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d76:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7a:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d7e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d82:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800d85:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800d88:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800d8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d8f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d96:	00 
  800d97:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800d9a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800d9d:	89 0c 24             	mov    %ecx,(%esp)
  800da0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da4:	e8 17 07 00 00       	call   8014c0 <__udivdi3>
  800da9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800dac:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800daf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800db3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800db7:	89 04 24             	mov    %eax,(%esp)
  800dba:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	e8 37 fa ff ff       	call   800800 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800dc9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dcc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dd0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800dd7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ddb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800de2:	00 
  800de3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800de6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800de9:	89 14 24             	mov    %edx,(%esp)
  800dec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800df0:	e8 fb 07 00 00       	call   8015f0 <__umoddi3>
  800df5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800df9:	0f be 80 9f 17 80 00 	movsbl 0x80179f(%eax),%eax
  800e00:	89 04 24             	mov    %eax,(%esp)
  800e03:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800e06:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800e0a:	74 54                	je     800e60 <vprintfmt+0x514>
  800e0c:	e9 67 fb ff ff       	jmp    800978 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800e11:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
  800e18:	0f 84 2a 01 00 00    	je     800f48 <vprintfmt+0x5fc>
		while (--width > 0)
  800e1e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800e21:	83 ef 01             	sub    $0x1,%edi
  800e24:	85 ff                	test   %edi,%edi
  800e26:	0f 8e 5e 01 00 00    	jle    800f8a <vprintfmt+0x63e>
  800e2c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800e2f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800e32:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800e35:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800e38:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800e3b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800e3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e42:	89 1c 24             	mov    %ebx,(%esp)
  800e45:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800e48:	83 ef 01             	sub    $0x1,%edi
  800e4b:	85 ff                	test   %edi,%edi
  800e4d:	7f ef                	jg     800e3e <vprintfmt+0x4f2>
  800e4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800e52:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800e55:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800e58:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800e5b:	e9 2a 01 00 00       	jmp    800f8a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800e60:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800e63:	83 eb 01             	sub    $0x1,%ebx
  800e66:	85 db                	test   %ebx,%ebx
  800e68:	0f 8e 0a fb ff ff    	jle    800978 <vprintfmt+0x2c>
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800e74:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800e77:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e82:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800e84:	83 eb 01             	sub    $0x1,%ebx
  800e87:	85 db                	test   %ebx,%ebx
  800e89:	7f ec                	jg     800e77 <vprintfmt+0x52b>
  800e8b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800e8e:	e9 e8 fa ff ff       	jmp    80097b <vprintfmt+0x2f>
  800e93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800e96:	8b 45 14             	mov    0x14(%ebp),%eax
  800e99:	8d 50 04             	lea    0x4(%eax),%edx
  800e9c:	89 55 14             	mov    %edx,0x14(%ebp)
  800e9f:	8b 00                	mov    (%eax),%eax
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	75 2a                	jne    800ecf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800ea5:	c7 44 24 0c 58 18 80 	movl   $0x801858,0xc(%esp)
  800eac:	00 
  800ead:	c7 44 24 08 b9 17 80 	movl   $0x8017b9,0x8(%esp)
  800eb4:	00 
  800eb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ebc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebf:	89 0c 24             	mov    %ecx,(%esp)
  800ec2:	e8 90 01 00 00       	call   801057 <printfmt>
  800ec7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800eca:	e9 ac fa ff ff       	jmp    80097b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800ecf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ed2:	8b 13                	mov    (%ebx),%edx
  800ed4:	83 fa 7f             	cmp    $0x7f,%edx
  800ed7:	7e 29                	jle    800f02 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800ed9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800edb:	c7 44 24 0c 90 18 80 	movl   $0x801890,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 b9 17 80 	movl   $0x8017b9,0x8(%esp)
  800eea:	00 
  800eeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef2:	89 04 24             	mov    %eax,(%esp)
  800ef5:	e8 5d 01 00 00       	call   801057 <printfmt>
  800efa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800efd:	e9 79 fa ff ff       	jmp    80097b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800f02:	88 10                	mov    %dl,(%eax)
  800f04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f07:	e9 6f fa ff ff       	jmp    80097b <vprintfmt+0x2f>
  800f0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f15:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f19:	89 14 24             	mov    %edx,(%esp)
  800f1c:	ff 55 08             	call   *0x8(%ebp)
  800f1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800f22:	e9 54 fa ff ff       	jmp    80097b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f2e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800f35:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f38:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f3b:	80 38 25             	cmpb   $0x25,(%eax)
  800f3e:	0f 84 37 fa ff ff    	je     80097b <vprintfmt+0x2f>
  800f44:	89 c7                	mov    %eax,%edi
  800f46:	eb f0                	jmp    800f38 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f53:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800f56:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f5a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f61:	00 
  800f62:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800f65:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800f68:	89 04 24             	mov    %eax,(%esp)
  800f6b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f6f:	e8 7c 06 00 00       	call   8015f0 <__umoddi3>
  800f74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f78:	0f be 80 9f 17 80 00 	movsbl 0x80179f(%eax),%eax
  800f7f:	89 04 24             	mov    %eax,(%esp)
  800f82:	ff 55 08             	call   *0x8(%ebp)
  800f85:	e9 d6 fe ff ff       	jmp    800e60 <vprintfmt+0x514>
  800f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f91:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f95:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fa3:	00 
  800fa4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800fa7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800faa:	89 04 24             	mov    %eax,(%esp)
  800fad:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fb1:	e8 3a 06 00 00       	call   8015f0 <__umoddi3>
  800fb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fba:	0f be 80 9f 17 80 00 	movsbl 0x80179f(%eax),%eax
  800fc1:	89 04 24             	mov    %eax,(%esp)
  800fc4:	ff 55 08             	call   *0x8(%ebp)
  800fc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fca:	e9 ac f9 ff ff       	jmp    80097b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800fcf:	83 c4 6c             	add    $0x6c,%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 28             	sub    $0x28,%esp
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	74 04                	je     800feb <vsnprintf+0x14>
  800fe7:	85 d2                	test   %edx,%edx
  800fe9:	7f 07                	jg     800ff2 <vsnprintf+0x1b>
  800feb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff0:	eb 3b                	jmp    80102d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ff2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ff5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ff9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ffc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801003:	8b 45 14             	mov    0x14(%ebp),%eax
  801006:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80100a:	8b 45 10             	mov    0x10(%ebp),%eax
  80100d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801011:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801014:	89 44 24 04          	mov    %eax,0x4(%esp)
  801018:	c7 04 24 2f 09 80 00 	movl   $0x80092f,(%esp)
  80101f:	e8 28 f9 ff ff       	call   80094c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801024:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801027:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801035:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801038:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80103c:	8b 45 10             	mov    0x10(%ebp),%eax
  80103f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801043:	8b 45 0c             	mov    0xc(%ebp),%eax
  801046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104a:	8b 45 08             	mov    0x8(%ebp),%eax
  80104d:	89 04 24             	mov    %eax,(%esp)
  801050:	e8 82 ff ff ff       	call   800fd7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80105d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801060:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801064:	8b 45 10             	mov    0x10(%ebp),%eax
  801067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801072:	8b 45 08             	mov    0x8(%ebp),%eax
  801075:	89 04 24             	mov    %eax,(%esp)
  801078:	e8 cf f8 ff ff       	call   80094c <vprintfmt>
	va_end(ap);
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    
	...

00801080 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
  80108b:	80 3a 00             	cmpb   $0x0,(%edx)
  80108e:	74 09                	je     801099 <strlen+0x19>
		n++;
  801090:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801093:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801097:	75 f7                	jne    801090 <strlen+0x10>
		n++;
	return n;
}
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	53                   	push   %ebx
  80109f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8010a5:	85 c9                	test   %ecx,%ecx
  8010a7:	74 19                	je     8010c2 <strnlen+0x27>
  8010a9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8010ac:	74 14                	je     8010c2 <strnlen+0x27>
  8010ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8010b3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8010b6:	39 c8                	cmp    %ecx,%eax
  8010b8:	74 0d                	je     8010c7 <strnlen+0x2c>
  8010ba:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8010be:	75 f3                	jne    8010b3 <strnlen+0x18>
  8010c0:	eb 05                	jmp    8010c7 <strnlen+0x2c>
  8010c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8010c7:	5b                   	pop    %ebx
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	53                   	push   %ebx
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010d4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8010d9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8010dd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8010e0:	83 c2 01             	add    $0x1,%edx
  8010e3:	84 c9                	test   %cl,%cl
  8010e5:	75 f2                	jne    8010d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8010e7:	5b                   	pop    %ebx
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8010f4:	89 1c 24             	mov    %ebx,(%esp)
  8010f7:	e8 84 ff ff ff       	call   801080 <strlen>
	strcpy(dst + len, src);
  8010fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ff:	89 54 24 04          	mov    %edx,0x4(%esp)
  801103:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801106:	89 04 24             	mov    %eax,(%esp)
  801109:	e8 bc ff ff ff       	call   8010ca <strcpy>
	return dst;
}
  80110e:	89 d8                	mov    %ebx,%eax
  801110:	83 c4 08             	add    $0x8,%esp
  801113:	5b                   	pop    %ebx
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801121:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801124:	85 f6                	test   %esi,%esi
  801126:	74 18                	je     801140 <strncpy+0x2a>
  801128:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80112d:	0f b6 1a             	movzbl (%edx),%ebx
  801130:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801133:	80 3a 01             	cmpb   $0x1,(%edx)
  801136:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801139:	83 c1 01             	add    $0x1,%ecx
  80113c:	39 ce                	cmp    %ecx,%esi
  80113e:	77 ed                	ja     80112d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	8b 75 08             	mov    0x8(%ebp),%esi
  80114c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801152:	89 f0                	mov    %esi,%eax
  801154:	85 c9                	test   %ecx,%ecx
  801156:	74 27                	je     80117f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801158:	83 e9 01             	sub    $0x1,%ecx
  80115b:	74 1d                	je     80117a <strlcpy+0x36>
  80115d:	0f b6 1a             	movzbl (%edx),%ebx
  801160:	84 db                	test   %bl,%bl
  801162:	74 16                	je     80117a <strlcpy+0x36>
			*dst++ = *src++;
  801164:	88 18                	mov    %bl,(%eax)
  801166:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801169:	83 e9 01             	sub    $0x1,%ecx
  80116c:	74 0e                	je     80117c <strlcpy+0x38>
			*dst++ = *src++;
  80116e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801171:	0f b6 1a             	movzbl (%edx),%ebx
  801174:	84 db                	test   %bl,%bl
  801176:	75 ec                	jne    801164 <strlcpy+0x20>
  801178:	eb 02                	jmp    80117c <strlcpy+0x38>
  80117a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80117c:	c6 00 00             	movb   $0x0,(%eax)
  80117f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80118e:	0f b6 01             	movzbl (%ecx),%eax
  801191:	84 c0                	test   %al,%al
  801193:	74 15                	je     8011aa <strcmp+0x25>
  801195:	3a 02                	cmp    (%edx),%al
  801197:	75 11                	jne    8011aa <strcmp+0x25>
		p++, q++;
  801199:	83 c1 01             	add    $0x1,%ecx
  80119c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80119f:	0f b6 01             	movzbl (%ecx),%eax
  8011a2:	84 c0                	test   %al,%al
  8011a4:	74 04                	je     8011aa <strcmp+0x25>
  8011a6:	3a 02                	cmp    (%edx),%al
  8011a8:	74 ef                	je     801199 <strcmp+0x14>
  8011aa:	0f b6 c0             	movzbl %al,%eax
  8011ad:	0f b6 12             	movzbl (%edx),%edx
  8011b0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	53                   	push   %ebx
  8011b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011be:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	74 23                	je     8011e8 <strncmp+0x34>
  8011c5:	0f b6 1a             	movzbl (%edx),%ebx
  8011c8:	84 db                	test   %bl,%bl
  8011ca:	74 25                	je     8011f1 <strncmp+0x3d>
  8011cc:	3a 19                	cmp    (%ecx),%bl
  8011ce:	75 21                	jne    8011f1 <strncmp+0x3d>
  8011d0:	83 e8 01             	sub    $0x1,%eax
  8011d3:	74 13                	je     8011e8 <strncmp+0x34>
		n--, p++, q++;
  8011d5:	83 c2 01             	add    $0x1,%edx
  8011d8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8011db:	0f b6 1a             	movzbl (%edx),%ebx
  8011de:	84 db                	test   %bl,%bl
  8011e0:	74 0f                	je     8011f1 <strncmp+0x3d>
  8011e2:	3a 19                	cmp    (%ecx),%bl
  8011e4:	74 ea                	je     8011d0 <strncmp+0x1c>
  8011e6:	eb 09                	jmp    8011f1 <strncmp+0x3d>
  8011e8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8011ed:	5b                   	pop    %ebx
  8011ee:	5d                   	pop    %ebp
  8011ef:	90                   	nop
  8011f0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8011f1:	0f b6 02             	movzbl (%edx),%eax
  8011f4:	0f b6 11             	movzbl (%ecx),%edx
  8011f7:	29 d0                	sub    %edx,%eax
  8011f9:	eb f2                	jmp    8011ed <strncmp+0x39>

008011fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801201:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801205:	0f b6 10             	movzbl (%eax),%edx
  801208:	84 d2                	test   %dl,%dl
  80120a:	74 18                	je     801224 <strchr+0x29>
		if (*s == c)
  80120c:	38 ca                	cmp    %cl,%dl
  80120e:	75 0a                	jne    80121a <strchr+0x1f>
  801210:	eb 17                	jmp    801229 <strchr+0x2e>
  801212:	38 ca                	cmp    %cl,%dl
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	74 0f                	je     801229 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80121a:	83 c0 01             	add    $0x1,%eax
  80121d:	0f b6 10             	movzbl (%eax),%edx
  801220:	84 d2                	test   %dl,%dl
  801222:	75 ee                	jne    801212 <strchr+0x17>
  801224:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	8b 45 08             	mov    0x8(%ebp),%eax
  801231:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801235:	0f b6 10             	movzbl (%eax),%edx
  801238:	84 d2                	test   %dl,%dl
  80123a:	74 18                	je     801254 <strfind+0x29>
		if (*s == c)
  80123c:	38 ca                	cmp    %cl,%dl
  80123e:	75 0a                	jne    80124a <strfind+0x1f>
  801240:	eb 12                	jmp    801254 <strfind+0x29>
  801242:	38 ca                	cmp    %cl,%dl
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	74 0a                	je     801254 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80124a:	83 c0 01             	add    $0x1,%eax
  80124d:	0f b6 10             	movzbl (%eax),%edx
  801250:	84 d2                	test   %dl,%dl
  801252:	75 ee                	jne    801242 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	83 ec 0c             	sub    $0xc,%esp
  80125c:	89 1c 24             	mov    %ebx,(%esp)
  80125f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801263:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801267:	8b 7d 08             	mov    0x8(%ebp),%edi
  80126a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801270:	85 c9                	test   %ecx,%ecx
  801272:	74 30                	je     8012a4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801274:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80127a:	75 25                	jne    8012a1 <memset+0x4b>
  80127c:	f6 c1 03             	test   $0x3,%cl
  80127f:	75 20                	jne    8012a1 <memset+0x4b>
		c &= 0xFF;
  801281:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801284:	89 d3                	mov    %edx,%ebx
  801286:	c1 e3 08             	shl    $0x8,%ebx
  801289:	89 d6                	mov    %edx,%esi
  80128b:	c1 e6 18             	shl    $0x18,%esi
  80128e:	89 d0                	mov    %edx,%eax
  801290:	c1 e0 10             	shl    $0x10,%eax
  801293:	09 f0                	or     %esi,%eax
  801295:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801297:	09 d8                	or     %ebx,%eax
  801299:	c1 e9 02             	shr    $0x2,%ecx
  80129c:	fc                   	cld    
  80129d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80129f:	eb 03                	jmp    8012a4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012a1:	fc                   	cld    
  8012a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012a4:	89 f8                	mov    %edi,%eax
  8012a6:	8b 1c 24             	mov    (%esp),%ebx
  8012a9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012ad:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012b1:	89 ec                	mov    %ebp,%esp
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	89 34 24             	mov    %esi,(%esp)
  8012be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8012c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8012cb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8012cd:	39 c6                	cmp    %eax,%esi
  8012cf:	73 35                	jae    801306 <memmove+0x51>
  8012d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8012d4:	39 d0                	cmp    %edx,%eax
  8012d6:	73 2e                	jae    801306 <memmove+0x51>
		s += n;
		d += n;
  8012d8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012da:	f6 c2 03             	test   $0x3,%dl
  8012dd:	75 1b                	jne    8012fa <memmove+0x45>
  8012df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012e5:	75 13                	jne    8012fa <memmove+0x45>
  8012e7:	f6 c1 03             	test   $0x3,%cl
  8012ea:	75 0e                	jne    8012fa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8012ec:	83 ef 04             	sub    $0x4,%edi
  8012ef:	8d 72 fc             	lea    -0x4(%edx),%esi
  8012f2:	c1 e9 02             	shr    $0x2,%ecx
  8012f5:	fd                   	std    
  8012f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012f8:	eb 09                	jmp    801303 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8012fa:	83 ef 01             	sub    $0x1,%edi
  8012fd:	8d 72 ff             	lea    -0x1(%edx),%esi
  801300:	fd                   	std    
  801301:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801303:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801304:	eb 20                	jmp    801326 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801306:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80130c:	75 15                	jne    801323 <memmove+0x6e>
  80130e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801314:	75 0d                	jne    801323 <memmove+0x6e>
  801316:	f6 c1 03             	test   $0x3,%cl
  801319:	75 08                	jne    801323 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80131b:	c1 e9 02             	shr    $0x2,%ecx
  80131e:	fc                   	cld    
  80131f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801321:	eb 03                	jmp    801326 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801323:	fc                   	cld    
  801324:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801326:	8b 34 24             	mov    (%esp),%esi
  801329:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80132d:	89 ec                	mov    %ebp,%esp
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801337:	8b 45 10             	mov    0x10(%ebp),%eax
  80133a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801341:	89 44 24 04          	mov    %eax,0x4(%esp)
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	e8 65 ff ff ff       	call   8012b5 <memmove>
}
  801350:	c9                   	leave  
  801351:	c3                   	ret    

00801352 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	57                   	push   %edi
  801356:	56                   	push   %esi
  801357:	53                   	push   %ebx
  801358:	8b 75 08             	mov    0x8(%ebp),%esi
  80135b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80135e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801361:	85 c9                	test   %ecx,%ecx
  801363:	74 36                	je     80139b <memcmp+0x49>
		if (*s1 != *s2)
  801365:	0f b6 06             	movzbl (%esi),%eax
  801368:	0f b6 1f             	movzbl (%edi),%ebx
  80136b:	38 d8                	cmp    %bl,%al
  80136d:	74 20                	je     80138f <memcmp+0x3d>
  80136f:	eb 14                	jmp    801385 <memcmp+0x33>
  801371:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801376:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80137b:	83 c2 01             	add    $0x1,%edx
  80137e:	83 e9 01             	sub    $0x1,%ecx
  801381:	38 d8                	cmp    %bl,%al
  801383:	74 12                	je     801397 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801385:	0f b6 c0             	movzbl %al,%eax
  801388:	0f b6 db             	movzbl %bl,%ebx
  80138b:	29 d8                	sub    %ebx,%eax
  80138d:	eb 11                	jmp    8013a0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80138f:	83 e9 01             	sub    $0x1,%ecx
  801392:	ba 00 00 00 00       	mov    $0x0,%edx
  801397:	85 c9                	test   %ecx,%ecx
  801399:	75 d6                	jne    801371 <memcmp+0x1f>
  80139b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8013b0:	39 d0                	cmp    %edx,%eax
  8013b2:	73 15                	jae    8013c9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8013b8:	38 08                	cmp    %cl,(%eax)
  8013ba:	75 06                	jne    8013c2 <memfind+0x1d>
  8013bc:	eb 0b                	jmp    8013c9 <memfind+0x24>
  8013be:	38 08                	cmp    %cl,(%eax)
  8013c0:	74 07                	je     8013c9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013c2:	83 c0 01             	add    $0x1,%eax
  8013c5:	39 c2                	cmp    %eax,%edx
  8013c7:	77 f5                	ja     8013be <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	57                   	push   %edi
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 04             	sub    $0x4,%esp
  8013d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013da:	0f b6 02             	movzbl (%edx),%eax
  8013dd:	3c 20                	cmp    $0x20,%al
  8013df:	74 04                	je     8013e5 <strtol+0x1a>
  8013e1:	3c 09                	cmp    $0x9,%al
  8013e3:	75 0e                	jne    8013f3 <strtol+0x28>
		s++;
  8013e5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013e8:	0f b6 02             	movzbl (%edx),%eax
  8013eb:	3c 20                	cmp    $0x20,%al
  8013ed:	74 f6                	je     8013e5 <strtol+0x1a>
  8013ef:	3c 09                	cmp    $0x9,%al
  8013f1:	74 f2                	je     8013e5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013f3:	3c 2b                	cmp    $0x2b,%al
  8013f5:	75 0c                	jne    801403 <strtol+0x38>
		s++;
  8013f7:	83 c2 01             	add    $0x1,%edx
  8013fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801401:	eb 15                	jmp    801418 <strtol+0x4d>
	else if (*s == '-')
  801403:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80140a:	3c 2d                	cmp    $0x2d,%al
  80140c:	75 0a                	jne    801418 <strtol+0x4d>
		s++, neg = 1;
  80140e:	83 c2 01             	add    $0x1,%edx
  801411:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801418:	85 db                	test   %ebx,%ebx
  80141a:	0f 94 c0             	sete   %al
  80141d:	74 05                	je     801424 <strtol+0x59>
  80141f:	83 fb 10             	cmp    $0x10,%ebx
  801422:	75 18                	jne    80143c <strtol+0x71>
  801424:	80 3a 30             	cmpb   $0x30,(%edx)
  801427:	75 13                	jne    80143c <strtol+0x71>
  801429:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80142d:	8d 76 00             	lea    0x0(%esi),%esi
  801430:	75 0a                	jne    80143c <strtol+0x71>
		s += 2, base = 16;
  801432:	83 c2 02             	add    $0x2,%edx
  801435:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80143a:	eb 15                	jmp    801451 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80143c:	84 c0                	test   %al,%al
  80143e:	66 90                	xchg   %ax,%ax
  801440:	74 0f                	je     801451 <strtol+0x86>
  801442:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801447:	80 3a 30             	cmpb   $0x30,(%edx)
  80144a:	75 05                	jne    801451 <strtol+0x86>
		s++, base = 8;
  80144c:	83 c2 01             	add    $0x1,%edx
  80144f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801451:	b8 00 00 00 00       	mov    $0x0,%eax
  801456:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801458:	0f b6 0a             	movzbl (%edx),%ecx
  80145b:	89 cf                	mov    %ecx,%edi
  80145d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801460:	80 fb 09             	cmp    $0x9,%bl
  801463:	77 08                	ja     80146d <strtol+0xa2>
			dig = *s - '0';
  801465:	0f be c9             	movsbl %cl,%ecx
  801468:	83 e9 30             	sub    $0x30,%ecx
  80146b:	eb 1e                	jmp    80148b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80146d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801470:	80 fb 19             	cmp    $0x19,%bl
  801473:	77 08                	ja     80147d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801475:	0f be c9             	movsbl %cl,%ecx
  801478:	83 e9 57             	sub    $0x57,%ecx
  80147b:	eb 0e                	jmp    80148b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80147d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801480:	80 fb 19             	cmp    $0x19,%bl
  801483:	77 15                	ja     80149a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801485:	0f be c9             	movsbl %cl,%ecx
  801488:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80148b:	39 f1                	cmp    %esi,%ecx
  80148d:	7d 0b                	jge    80149a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80148f:	83 c2 01             	add    $0x1,%edx
  801492:	0f af c6             	imul   %esi,%eax
  801495:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801498:	eb be                	jmp    801458 <strtol+0x8d>
  80149a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80149c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014a0:	74 05                	je     8014a7 <strtol+0xdc>
		*endptr = (char *) s;
  8014a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8014a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014ab:	74 04                	je     8014b1 <strtol+0xe6>
  8014ad:	89 c8                	mov    %ecx,%eax
  8014af:	f7 d8                	neg    %eax
}
  8014b1:	83 c4 04             	add    $0x4,%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5f                   	pop    %edi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    
  8014b9:	00 00                	add    %al,(%eax)
  8014bb:	00 00                	add    %al,(%eax)
  8014bd:	00 00                	add    %al,(%eax)
	...

008014c0 <__udivdi3>:
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	57                   	push   %edi
  8014c4:	56                   	push   %esi
  8014c5:	83 ec 10             	sub    $0x10,%esp
  8014c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8014d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8014d9:	75 35                	jne    801510 <__udivdi3+0x50>
  8014db:	39 fe                	cmp    %edi,%esi
  8014dd:	77 61                	ja     801540 <__udivdi3+0x80>
  8014df:	85 f6                	test   %esi,%esi
  8014e1:	75 0b                	jne    8014ee <__udivdi3+0x2e>
  8014e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e8:	31 d2                	xor    %edx,%edx
  8014ea:	f7 f6                	div    %esi
  8014ec:	89 c6                	mov    %eax,%esi
  8014ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8014f1:	31 d2                	xor    %edx,%edx
  8014f3:	89 f8                	mov    %edi,%eax
  8014f5:	f7 f6                	div    %esi
  8014f7:	89 c7                	mov    %eax,%edi
  8014f9:	89 c8                	mov    %ecx,%eax
  8014fb:	f7 f6                	div    %esi
  8014fd:	89 c1                	mov    %eax,%ecx
  8014ff:	89 fa                	mov    %edi,%edx
  801501:	89 c8                	mov    %ecx,%eax
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	5e                   	pop    %esi
  801507:	5f                   	pop    %edi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    
  80150a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801510:	39 f8                	cmp    %edi,%eax
  801512:	77 1c                	ja     801530 <__udivdi3+0x70>
  801514:	0f bd d0             	bsr    %eax,%edx
  801517:	83 f2 1f             	xor    $0x1f,%edx
  80151a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80151d:	75 39                	jne    801558 <__udivdi3+0x98>
  80151f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801522:	0f 86 a0 00 00 00    	jbe    8015c8 <__udivdi3+0x108>
  801528:	39 f8                	cmp    %edi,%eax
  80152a:	0f 82 98 00 00 00    	jb     8015c8 <__udivdi3+0x108>
  801530:	31 ff                	xor    %edi,%edi
  801532:	31 c9                	xor    %ecx,%ecx
  801534:	89 c8                	mov    %ecx,%eax
  801536:	89 fa                	mov    %edi,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	5e                   	pop    %esi
  80153c:	5f                   	pop    %edi
  80153d:	5d                   	pop    %ebp
  80153e:	c3                   	ret    
  80153f:	90                   	nop
  801540:	89 d1                	mov    %edx,%ecx
  801542:	89 fa                	mov    %edi,%edx
  801544:	89 c8                	mov    %ecx,%eax
  801546:	31 ff                	xor    %edi,%edi
  801548:	f7 f6                	div    %esi
  80154a:	89 c1                	mov    %eax,%ecx
  80154c:	89 fa                	mov    %edi,%edx
  80154e:	89 c8                	mov    %ecx,%eax
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    
  801557:	90                   	nop
  801558:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80155c:	89 f2                	mov    %esi,%edx
  80155e:	d3 e0                	shl    %cl,%eax
  801560:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801563:	b8 20 00 00 00       	mov    $0x20,%eax
  801568:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80156b:	89 c1                	mov    %eax,%ecx
  80156d:	d3 ea                	shr    %cl,%edx
  80156f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801573:	0b 55 ec             	or     -0x14(%ebp),%edx
  801576:	d3 e6                	shl    %cl,%esi
  801578:	89 c1                	mov    %eax,%ecx
  80157a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80157d:	89 fe                	mov    %edi,%esi
  80157f:	d3 ee                	shr    %cl,%esi
  801581:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801585:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801588:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80158b:	d3 e7                	shl    %cl,%edi
  80158d:	89 c1                	mov    %eax,%ecx
  80158f:	d3 ea                	shr    %cl,%edx
  801591:	09 d7                	or     %edx,%edi
  801593:	89 f2                	mov    %esi,%edx
  801595:	89 f8                	mov    %edi,%eax
  801597:	f7 75 ec             	divl   -0x14(%ebp)
  80159a:	89 d6                	mov    %edx,%esi
  80159c:	89 c7                	mov    %eax,%edi
  80159e:	f7 65 e8             	mull   -0x18(%ebp)
  8015a1:	39 d6                	cmp    %edx,%esi
  8015a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015a6:	72 30                	jb     8015d8 <__udivdi3+0x118>
  8015a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015af:	d3 e2                	shl    %cl,%edx
  8015b1:	39 c2                	cmp    %eax,%edx
  8015b3:	73 05                	jae    8015ba <__udivdi3+0xfa>
  8015b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8015b8:	74 1e                	je     8015d8 <__udivdi3+0x118>
  8015ba:	89 f9                	mov    %edi,%ecx
  8015bc:	31 ff                	xor    %edi,%edi
  8015be:	e9 71 ff ff ff       	jmp    801534 <__udivdi3+0x74>
  8015c3:	90                   	nop
  8015c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015c8:	31 ff                	xor    %edi,%edi
  8015ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8015cf:	e9 60 ff ff ff       	jmp    801534 <__udivdi3+0x74>
  8015d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8015db:	31 ff                	xor    %edi,%edi
  8015dd:	89 c8                	mov    %ecx,%eax
  8015df:	89 fa                	mov    %edi,%edx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	5e                   	pop    %esi
  8015e5:	5f                   	pop    %edi
  8015e6:	5d                   	pop    %ebp
  8015e7:	c3                   	ret    
	...

008015f0 <__umoddi3>:
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	57                   	push   %edi
  8015f4:	56                   	push   %esi
  8015f5:	83 ec 20             	sub    $0x20,%esp
  8015f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8015fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801601:	8b 75 0c             	mov    0xc(%ebp),%esi
  801604:	85 d2                	test   %edx,%edx
  801606:	89 c8                	mov    %ecx,%eax
  801608:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80160b:	75 13                	jne    801620 <__umoddi3+0x30>
  80160d:	39 f7                	cmp    %esi,%edi
  80160f:	76 3f                	jbe    801650 <__umoddi3+0x60>
  801611:	89 f2                	mov    %esi,%edx
  801613:	f7 f7                	div    %edi
  801615:	89 d0                	mov    %edx,%eax
  801617:	31 d2                	xor    %edx,%edx
  801619:	83 c4 20             	add    $0x20,%esp
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    
  801620:	39 f2                	cmp    %esi,%edx
  801622:	77 4c                	ja     801670 <__umoddi3+0x80>
  801624:	0f bd ca             	bsr    %edx,%ecx
  801627:	83 f1 1f             	xor    $0x1f,%ecx
  80162a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162d:	75 51                	jne    801680 <__umoddi3+0x90>
  80162f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801632:	0f 87 e0 00 00 00    	ja     801718 <__umoddi3+0x128>
  801638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163b:	29 f8                	sub    %edi,%eax
  80163d:	19 d6                	sbb    %edx,%esi
  80163f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801645:	89 f2                	mov    %esi,%edx
  801647:	83 c4 20             	add    $0x20,%esp
  80164a:	5e                   	pop    %esi
  80164b:	5f                   	pop    %edi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    
  80164e:	66 90                	xchg   %ax,%ax
  801650:	85 ff                	test   %edi,%edi
  801652:	75 0b                	jne    80165f <__umoddi3+0x6f>
  801654:	b8 01 00 00 00       	mov    $0x1,%eax
  801659:	31 d2                	xor    %edx,%edx
  80165b:	f7 f7                	div    %edi
  80165d:	89 c7                	mov    %eax,%edi
  80165f:	89 f0                	mov    %esi,%eax
  801661:	31 d2                	xor    %edx,%edx
  801663:	f7 f7                	div    %edi
  801665:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801668:	f7 f7                	div    %edi
  80166a:	eb a9                	jmp    801615 <__umoddi3+0x25>
  80166c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801670:	89 c8                	mov    %ecx,%eax
  801672:	89 f2                	mov    %esi,%edx
  801674:	83 c4 20             	add    $0x20,%esp
  801677:	5e                   	pop    %esi
  801678:	5f                   	pop    %edi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    
  80167b:	90                   	nop
  80167c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801680:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801684:	d3 e2                	shl    %cl,%edx
  801686:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801689:	ba 20 00 00 00       	mov    $0x20,%edx
  80168e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801691:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801694:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801698:	89 fa                	mov    %edi,%edx
  80169a:	d3 ea                	shr    %cl,%edx
  80169c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8016a3:	d3 e7                	shl    %cl,%edi
  8016a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016ac:	89 f2                	mov    %esi,%edx
  8016ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8016b1:	89 c7                	mov    %eax,%edi
  8016b3:	d3 ea                	shr    %cl,%edx
  8016b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8016bc:	89 c2                	mov    %eax,%edx
  8016be:	d3 e6                	shl    %cl,%esi
  8016c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016c4:	d3 ea                	shr    %cl,%edx
  8016c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016ca:	09 d6                	or     %edx,%esi
  8016cc:	89 f0                	mov    %esi,%eax
  8016ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8016d1:	d3 e7                	shl    %cl,%edi
  8016d3:	89 f2                	mov    %esi,%edx
  8016d5:	f7 75 f4             	divl   -0xc(%ebp)
  8016d8:	89 d6                	mov    %edx,%esi
  8016da:	f7 65 e8             	mull   -0x18(%ebp)
  8016dd:	39 d6                	cmp    %edx,%esi
  8016df:	72 2b                	jb     80170c <__umoddi3+0x11c>
  8016e1:	39 c7                	cmp    %eax,%edi
  8016e3:	72 23                	jb     801708 <__umoddi3+0x118>
  8016e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016e9:	29 c7                	sub    %eax,%edi
  8016eb:	19 d6                	sbb    %edx,%esi
  8016ed:	89 f0                	mov    %esi,%eax
  8016ef:	89 f2                	mov    %esi,%edx
  8016f1:	d3 ef                	shr    %cl,%edi
  8016f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016f7:	d3 e0                	shl    %cl,%eax
  8016f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016fd:	09 f8                	or     %edi,%eax
  8016ff:	d3 ea                	shr    %cl,%edx
  801701:	83 c4 20             	add    $0x20,%esp
  801704:	5e                   	pop    %esi
  801705:	5f                   	pop    %edi
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    
  801708:	39 d6                	cmp    %edx,%esi
  80170a:	75 d9                	jne    8016e5 <__umoddi3+0xf5>
  80170c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80170f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801712:	eb d1                	jmp    8016e5 <__umoddi3+0xf5>
  801714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801718:	39 f2                	cmp    %esi,%edx
  80171a:	0f 82 18 ff ff ff    	jb     801638 <__umoddi3+0x48>
  801720:	e9 1d ff ff ff       	jmp    801642 <__umoddi3+0x52>
