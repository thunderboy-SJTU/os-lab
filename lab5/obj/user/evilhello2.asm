
obj/user/evilhello2.debug:     file format elf32-i386


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
  80008b:	8b 15 20 40 80 00    	mov    0x804020,%edx
  800091:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  800097:	a1 28 40 80 00       	mov    0x804028,%eax
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
  8000af:	c7 44 24 04 40 40 80 	movl   $0x804040,0x4(%esp)
  8000b6:	00 
  8000b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 d6 05 00 00       	call   800698 <sys_map_kernel_page>
    gdt = (struct Segdesc*)(((PGNUM(va) << PTXSHIFT)) + (PGOFF(gdtd.pd_base)));
  8000c2:	ba 40 40 80 00       	mov    $0x804040,%edx
  8000c7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  8000cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000d0:	25 ff 0f 00 00       	and    $0xfff,%eax
  8000d5:	8d 04 02             	lea    (%edx,%eax,1),%eax
  8000d8:	a3 2c 40 80 00       	mov    %eax,0x80402c
    savedGate = *(gdt + (GD_UT >> 3));
  8000dd:	8b 50 18             	mov    0x18(%eax),%edx
  8000e0:	8b 48 1c             	mov    0x1c(%eax),%ecx
  8000e3:	89 15 20 40 80 00    	mov    %edx,0x804020
  8000e9:	89 0d 24 40 80 00    	mov    %ecx,0x804024
    gate = (struct Gatedesc*)(gdt + (GD_UT >> 3));
  8000ef:	83 c0 18             	add    $0x18,%eax
  8000f2:	a3 28 40 80 00       	mov    %eax,0x804028
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
  800156:	e8 7f 05 00 00       	call   8006da <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	89 c2                	mov    %eax,%edx
  800162:	c1 e2 07             	shl    $0x7,%edx
  800165:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80016c:	a3 40 50 80 00       	mov    %eax,0x805040
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800171:	85 f6                	test   %esi,%esi
  800173:	7e 07                	jle    80017c <libmain+0x38>
		binaryname = argv[0];
  800175:	8b 03                	mov    (%ebx),%eax
  800177:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  80019e:	e8 c8 0a 00 00       	call   800c6b <close_all>
	sys_env_destroy(0);
  8001a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001aa:	e8 6b 05 00 00       	call   80071a <sys_env_destroy>
}
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    
  8001b1:	00 00                	add    %al,(%eax)
	...

008001b4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	89 1c 24             	mov    %ebx,(%esp)
  8001bd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8001cb:	89 d1                	mov    %edx,%ecx
  8001cd:	89 d3                	mov    %edx,%ebx
  8001cf:	89 d7                	mov    %edx,%edi
  8001d1:	51                   	push   %ecx
  8001d2:	52                   	push   %edx
  8001d3:	53                   	push   %ebx
  8001d4:	54                   	push   %esp
  8001d5:	55                   	push   %ebp
  8001d6:	56                   	push   %esi
  8001d7:	57                   	push   %edi
  8001d8:	54                   	push   %esp
  8001d9:	5d                   	pop    %ebp
  8001da:	8d 35 e2 01 80 00    	lea    0x8001e2,%esi
  8001e0:	0f 34                	sysenter 
  8001e2:	5f                   	pop    %edi
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	5c                   	pop    %esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5a                   	pop    %edx
  8001e8:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8001e9:	8b 1c 24             	mov    (%esp),%ebx
  8001ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001f0:	89 ec                	mov    %ebp,%esp
  8001f2:	5d                   	pop    %ebp
  8001f3:	c3                   	ret    

008001f4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 08             	sub    $0x8,%esp
  8001fa:	89 1c 24             	mov    %ebx,(%esp)
  8001fd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800201:	b8 00 00 00 00       	mov    $0x0,%eax
  800206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800209:	8b 55 08             	mov    0x8(%ebp),%edx
  80020c:	89 c3                	mov    %eax,%ebx
  80020e:	89 c7                	mov    %eax,%edi
  800210:	51                   	push   %ecx
  800211:	52                   	push   %edx
  800212:	53                   	push   %ebx
  800213:	54                   	push   %esp
  800214:	55                   	push   %ebp
  800215:	56                   	push   %esi
  800216:	57                   	push   %edi
  800217:	54                   	push   %esp
  800218:	5d                   	pop    %ebp
  800219:	8d 35 21 02 80 00    	lea    0x800221,%esi
  80021f:	0f 34                	sysenter 
  800221:	5f                   	pop    %edi
  800222:	5e                   	pop    %esi
  800223:	5d                   	pop    %ebp
  800224:	5c                   	pop    %esp
  800225:	5b                   	pop    %ebx
  800226:	5a                   	pop    %edx
  800227:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800228:	8b 1c 24             	mov    (%esp),%ebx
  80022b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80022f:	89 ec                	mov    %ebp,%esp
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	89 1c 24             	mov    %ebx,(%esp)
  80023c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800240:	b8 10 00 00 00       	mov    $0x10,%eax
  800245:	8b 7d 14             	mov    0x14(%ebp),%edi
  800248:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	51                   	push   %ecx
  800252:	52                   	push   %edx
  800253:	53                   	push   %ebx
  800254:	54                   	push   %esp
  800255:	55                   	push   %ebp
  800256:	56                   	push   %esi
  800257:	57                   	push   %edi
  800258:	54                   	push   %esp
  800259:	5d                   	pop    %ebp
  80025a:	8d 35 62 02 80 00    	lea    0x800262,%esi
  800260:	0f 34                	sysenter 
  800262:	5f                   	pop    %edi
  800263:	5e                   	pop    %esi
  800264:	5d                   	pop    %ebp
  800265:	5c                   	pop    %esp
  800266:	5b                   	pop    %ebx
  800267:	5a                   	pop    %edx
  800268:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800269:	8b 1c 24             	mov    (%esp),%ebx
  80026c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800270:	89 ec                	mov    %ebp,%esp
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 28             	sub    $0x28,%esp
  80027a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80027d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800280:	bb 00 00 00 00       	mov    $0x0,%ebx
  800285:	b8 0f 00 00 00       	mov    $0xf,%eax
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	8b 55 08             	mov    0x8(%ebp),%edx
  800290:	89 df                	mov    %ebx,%edi
  800292:	51                   	push   %ecx
  800293:	52                   	push   %edx
  800294:	53                   	push   %ebx
  800295:	54                   	push   %esp
  800296:	55                   	push   %ebp
  800297:	56                   	push   %esi
  800298:	57                   	push   %edi
  800299:	54                   	push   %esp
  80029a:	5d                   	pop    %ebp
  80029b:	8d 35 a3 02 80 00    	lea    0x8002a3,%esi
  8002a1:	0f 34                	sysenter 
  8002a3:	5f                   	pop    %edi
  8002a4:	5e                   	pop    %esi
  8002a5:	5d                   	pop    %ebp
  8002a6:	5c                   	pop    %esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5a                   	pop    %edx
  8002a9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 28                	jle    8002d6 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b2:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  8002d1:	e8 7e 0d 00 00       	call   801054 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8002d6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002d9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002dc:	89 ec                	mov    %ebp,%esp
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	89 1c 24             	mov    %ebx,(%esp)
  8002e9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f2:	b8 11 00 00 00       	mov    $0x11,%eax
  8002f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fa:	89 cb                	mov    %ecx,%ebx
  8002fc:	89 cf                	mov    %ecx,%edi
  8002fe:	51                   	push   %ecx
  8002ff:	52                   	push   %edx
  800300:	53                   	push   %ebx
  800301:	54                   	push   %esp
  800302:	55                   	push   %ebp
  800303:	56                   	push   %esi
  800304:	57                   	push   %edi
  800305:	54                   	push   %esp
  800306:	5d                   	pop    %ebp
  800307:	8d 35 0f 03 80 00    	lea    0x80030f,%esi
  80030d:	0f 34                	sysenter 
  80030f:	5f                   	pop    %edi
  800310:	5e                   	pop    %esi
  800311:	5d                   	pop    %ebp
  800312:	5c                   	pop    %esp
  800313:	5b                   	pop    %ebx
  800314:	5a                   	pop    %edx
  800315:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800316:	8b 1c 24             	mov    (%esp),%ebx
  800319:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031d:	89 ec                	mov    %ebp,%esp
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	83 ec 28             	sub    $0x28,%esp
  800327:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80032a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800332:	b8 0e 00 00 00       	mov    $0xe,%eax
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	89 cb                	mov    %ecx,%ebx
  80033c:	89 cf                	mov    %ecx,%edi
  80033e:	51                   	push   %ecx
  80033f:	52                   	push   %edx
  800340:	53                   	push   %ebx
  800341:	54                   	push   %esp
  800342:	55                   	push   %ebp
  800343:	56                   	push   %esi
  800344:	57                   	push   %edi
  800345:	54                   	push   %esp
  800346:	5d                   	pop    %ebp
  800347:	8d 35 4f 03 80 00    	lea    0x80034f,%esi
  80034d:	0f 34                	sysenter 
  80034f:	5f                   	pop    %edi
  800350:	5e                   	pop    %esi
  800351:	5d                   	pop    %ebp
  800352:	5c                   	pop    %esp
  800353:	5b                   	pop    %ebx
  800354:	5a                   	pop    %edx
  800355:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800356:	85 c0                	test   %eax,%eax
  800358:	7e 28                	jle    800382 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035e:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800365:	00 
  800366:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  80036d:	00 
  80036e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800375:	00 
  800376:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  80037d:	e8 d2 0c 00 00       	call   801054 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800382:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800385:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800388:	89 ec                	mov    %ebp,%esp
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	89 1c 24             	mov    %ebx,(%esp)
  800395:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800399:	b8 0d 00 00 00       	mov    $0xd,%eax
  80039e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	51                   	push   %ecx
  8003ab:	52                   	push   %edx
  8003ac:	53                   	push   %ebx
  8003ad:	54                   	push   %esp
  8003ae:	55                   	push   %ebp
  8003af:	56                   	push   %esi
  8003b0:	57                   	push   %edi
  8003b1:	54                   	push   %esp
  8003b2:	5d                   	pop    %ebp
  8003b3:	8d 35 bb 03 80 00    	lea    0x8003bb,%esi
  8003b9:	0f 34                	sysenter 
  8003bb:	5f                   	pop    %edi
  8003bc:	5e                   	pop    %esi
  8003bd:	5d                   	pop    %ebp
  8003be:	5c                   	pop    %esp
  8003bf:	5b                   	pop    %ebx
  8003c0:	5a                   	pop    %edx
  8003c1:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003c2:	8b 1c 24             	mov    (%esp),%ebx
  8003c5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003c9:	89 ec                	mov    %ebp,%esp
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	83 ec 28             	sub    $0x28,%esp
  8003d3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003d6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003de:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e9:	89 df                	mov    %ebx,%edi
  8003eb:	51                   	push   %ecx
  8003ec:	52                   	push   %edx
  8003ed:	53                   	push   %ebx
  8003ee:	54                   	push   %esp
  8003ef:	55                   	push   %ebp
  8003f0:	56                   	push   %esi
  8003f1:	57                   	push   %edi
  8003f2:	54                   	push   %esp
  8003f3:	5d                   	pop    %ebp
  8003f4:	8d 35 fc 03 80 00    	lea    0x8003fc,%esi
  8003fa:	0f 34                	sysenter 
  8003fc:	5f                   	pop    %edi
  8003fd:	5e                   	pop    %esi
  8003fe:	5d                   	pop    %ebp
  8003ff:	5c                   	pop    %esp
  800400:	5b                   	pop    %ebx
  800401:	5a                   	pop    %edx
  800402:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800403:	85 c0                	test   %eax,%eax
  800405:	7e 28                	jle    80042f <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800407:	89 44 24 10          	mov    %eax,0x10(%esp)
  80040b:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  800412:	00 
  800413:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  80041a:	00 
  80041b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800422:	00 
  800423:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  80042a:	e8 25 0c 00 00       	call   801054 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80042f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800432:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800435:	89 ec                	mov    %ebp,%esp
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    

00800439 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
  80043c:	83 ec 28             	sub    $0x28,%esp
  80043f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800442:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800445:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80044f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800452:	8b 55 08             	mov    0x8(%ebp),%edx
  800455:	89 df                	mov    %ebx,%edi
  800457:	51                   	push   %ecx
  800458:	52                   	push   %edx
  800459:	53                   	push   %ebx
  80045a:	54                   	push   %esp
  80045b:	55                   	push   %ebp
  80045c:	56                   	push   %esi
  80045d:	57                   	push   %edi
  80045e:	54                   	push   %esp
  80045f:	5d                   	pop    %ebp
  800460:	8d 35 68 04 80 00    	lea    0x800468,%esi
  800466:	0f 34                	sysenter 
  800468:	5f                   	pop    %edi
  800469:	5e                   	pop    %esi
  80046a:	5d                   	pop    %ebp
  80046b:	5c                   	pop    %esp
  80046c:	5b                   	pop    %ebx
  80046d:	5a                   	pop    %edx
  80046e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80046f:	85 c0                	test   %eax,%eax
  800471:	7e 28                	jle    80049b <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800473:	89 44 24 10          	mov    %eax,0x10(%esp)
  800477:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80047e:	00 
  80047f:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  800486:	00 
  800487:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80048e:	00 
  80048f:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  800496:	e8 b9 0b 00 00       	call   801054 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80049b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80049e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004a1:	89 ec                	mov    %ebp,%esp
  8004a3:	5d                   	pop    %ebp
  8004a4:	c3                   	ret    

008004a5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	83 ec 28             	sub    $0x28,%esp
  8004ab:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004ae:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004b6:	b8 09 00 00 00       	mov    $0x9,%eax
  8004bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004be:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c1:	89 df                	mov    %ebx,%edi
  8004c3:	51                   	push   %ecx
  8004c4:	52                   	push   %edx
  8004c5:	53                   	push   %ebx
  8004c6:	54                   	push   %esp
  8004c7:	55                   	push   %ebp
  8004c8:	56                   	push   %esi
  8004c9:	57                   	push   %edi
  8004ca:	54                   	push   %esp
  8004cb:	5d                   	pop    %ebp
  8004cc:	8d 35 d4 04 80 00    	lea    0x8004d4,%esi
  8004d2:	0f 34                	sysenter 
  8004d4:	5f                   	pop    %edi
  8004d5:	5e                   	pop    %esi
  8004d6:	5d                   	pop    %ebp
  8004d7:	5c                   	pop    %esp
  8004d8:	5b                   	pop    %ebx
  8004d9:	5a                   	pop    %edx
  8004da:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	7e 28                	jle    800507 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004e3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8004ea:	00 
  8004eb:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  8004f2:	00 
  8004f3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004fa:	00 
  8004fb:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  800502:	e8 4d 0b 00 00       	call   801054 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800507:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80050a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80050d:	89 ec                	mov    %ebp,%esp
  80050f:	5d                   	pop    %ebp
  800510:	c3                   	ret    

00800511 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	83 ec 28             	sub    $0x28,%esp
  800517:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80051a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800522:	b8 07 00 00 00       	mov    $0x7,%eax
  800527:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80052a:	8b 55 08             	mov    0x8(%ebp),%edx
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	51                   	push   %ecx
  800530:	52                   	push   %edx
  800531:	53                   	push   %ebx
  800532:	54                   	push   %esp
  800533:	55                   	push   %ebp
  800534:	56                   	push   %esi
  800535:	57                   	push   %edi
  800536:	54                   	push   %esp
  800537:	5d                   	pop    %ebp
  800538:	8d 35 40 05 80 00    	lea    0x800540,%esi
  80053e:	0f 34                	sysenter 
  800540:	5f                   	pop    %edi
  800541:	5e                   	pop    %esi
  800542:	5d                   	pop    %ebp
  800543:	5c                   	pop    %esp
  800544:	5b                   	pop    %ebx
  800545:	5a                   	pop    %edx
  800546:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800547:	85 c0                	test   %eax,%eax
  800549:	7e 28                	jle    800573 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80054b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80054f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800556:	00 
  800557:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  80055e:	00 
  80055f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800566:	00 
  800567:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  80056e:	e8 e1 0a 00 00       	call   801054 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800573:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800576:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800579:	89 ec                	mov    %ebp,%esp
  80057b:	5d                   	pop    %ebp
  80057c:	c3                   	ret    

0080057d <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80057d:	55                   	push   %ebp
  80057e:	89 e5                	mov    %esp,%ebp
  800580:	83 ec 28             	sub    $0x28,%esp
  800583:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800586:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800589:	8b 7d 18             	mov    0x18(%ebp),%edi
  80058c:	0b 7d 14             	or     0x14(%ebp),%edi
  80058f:	b8 06 00 00 00       	mov    $0x6,%eax
  800594:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800597:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80059a:	8b 55 08             	mov    0x8(%ebp),%edx
  80059d:	51                   	push   %ecx
  80059e:	52                   	push   %edx
  80059f:	53                   	push   %ebx
  8005a0:	54                   	push   %esp
  8005a1:	55                   	push   %ebp
  8005a2:	56                   	push   %esi
  8005a3:	57                   	push   %edi
  8005a4:	54                   	push   %esp
  8005a5:	5d                   	pop    %ebp
  8005a6:	8d 35 ae 05 80 00    	lea    0x8005ae,%esi
  8005ac:	0f 34                	sysenter 
  8005ae:	5f                   	pop    %edi
  8005af:	5e                   	pop    %esi
  8005b0:	5d                   	pop    %ebp
  8005b1:	5c                   	pop    %esp
  8005b2:	5b                   	pop    %ebx
  8005b3:	5a                   	pop    %edx
  8005b4:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8005b5:	85 c0                	test   %eax,%eax
  8005b7:	7e 28                	jle    8005e1 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005bd:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005c4:	00 
  8005c5:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  8005cc:	00 
  8005cd:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8005d4:	00 
  8005d5:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  8005dc:	e8 73 0a 00 00       	call   801054 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8005e1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005e7:	89 ec                	mov    %ebp,%esp
  8005e9:	5d                   	pop    %ebp
  8005ea:	c3                   	ret    

008005eb <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005eb:	55                   	push   %ebp
  8005ec:	89 e5                	mov    %esp,%ebp
  8005ee:	83 ec 28             	sub    $0x28,%esp
  8005f1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005f4:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8005fc:	b8 05 00 00 00       	mov    $0x5,%eax
  800601:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800604:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800607:	8b 55 08             	mov    0x8(%ebp),%edx
  80060a:	51                   	push   %ecx
  80060b:	52                   	push   %edx
  80060c:	53                   	push   %ebx
  80060d:	54                   	push   %esp
  80060e:	55                   	push   %ebp
  80060f:	56                   	push   %esi
  800610:	57                   	push   %edi
  800611:	54                   	push   %esp
  800612:	5d                   	pop    %ebp
  800613:	8d 35 1b 06 80 00    	lea    0x80061b,%esi
  800619:	0f 34                	sysenter 
  80061b:	5f                   	pop    %edi
  80061c:	5e                   	pop    %esi
  80061d:	5d                   	pop    %ebp
  80061e:	5c                   	pop    %esp
  80061f:	5b                   	pop    %ebx
  800620:	5a                   	pop    %edx
  800621:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800622:	85 c0                	test   %eax,%eax
  800624:	7e 28                	jle    80064e <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800626:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062a:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800631:	00 
  800632:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  800639:	00 
  80063a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800641:	00 
  800642:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  800649:	e8 06 0a 00 00       	call   801054 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80064e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800651:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800654:	89 ec                	mov    %ebp,%esp
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	89 1c 24             	mov    %ebx,(%esp)
  800661:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
  80066a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80066f:	89 d1                	mov    %edx,%ecx
  800671:	89 d3                	mov    %edx,%ebx
  800673:	89 d7                	mov    %edx,%edi
  800675:	51                   	push   %ecx
  800676:	52                   	push   %edx
  800677:	53                   	push   %ebx
  800678:	54                   	push   %esp
  800679:	55                   	push   %ebp
  80067a:	56                   	push   %esi
  80067b:	57                   	push   %edi
  80067c:	54                   	push   %esp
  80067d:	5d                   	pop    %ebp
  80067e:	8d 35 86 06 80 00    	lea    0x800686,%esi
  800684:	0f 34                	sysenter 
  800686:	5f                   	pop    %edi
  800687:	5e                   	pop    %esi
  800688:	5d                   	pop    %ebp
  800689:	5c                   	pop    %esp
  80068a:	5b                   	pop    %ebx
  80068b:	5a                   	pop    %edx
  80068c:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80068d:	8b 1c 24             	mov    (%esp),%ebx
  800690:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800694:	89 ec                	mov    %ebp,%esp
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	89 1c 24             	mov    %ebx,(%esp)
  8006a1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8006af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b5:	89 df                	mov    %ebx,%edi
  8006b7:	51                   	push   %ecx
  8006b8:	52                   	push   %edx
  8006b9:	53                   	push   %ebx
  8006ba:	54                   	push   %esp
  8006bb:	55                   	push   %ebp
  8006bc:	56                   	push   %esi
  8006bd:	57                   	push   %edi
  8006be:	54                   	push   %esp
  8006bf:	5d                   	pop    %ebp
  8006c0:	8d 35 c8 06 80 00    	lea    0x8006c8,%esi
  8006c6:	0f 34                	sysenter 
  8006c8:	5f                   	pop    %edi
  8006c9:	5e                   	pop    %esi
  8006ca:	5d                   	pop    %ebp
  8006cb:	5c                   	pop    %esp
  8006cc:	5b                   	pop    %ebx
  8006cd:	5a                   	pop    %edx
  8006ce:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8006cf:	8b 1c 24             	mov    (%esp),%ebx
  8006d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006d6:	89 ec                	mov    %ebp,%esp
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	89 1c 24             	mov    %ebx,(%esp)
  8006e3:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8006f1:	89 d1                	mov    %edx,%ecx
  8006f3:	89 d3                	mov    %edx,%ebx
  8006f5:	89 d7                	mov    %edx,%edi
  8006f7:	51                   	push   %ecx
  8006f8:	52                   	push   %edx
  8006f9:	53                   	push   %ebx
  8006fa:	54                   	push   %esp
  8006fb:	55                   	push   %ebp
  8006fc:	56                   	push   %esi
  8006fd:	57                   	push   %edi
  8006fe:	54                   	push   %esp
  8006ff:	5d                   	pop    %ebp
  800700:	8d 35 08 07 80 00    	lea    0x800708,%esi
  800706:	0f 34                	sysenter 
  800708:	5f                   	pop    %edi
  800709:	5e                   	pop    %esi
  80070a:	5d                   	pop    %ebp
  80070b:	5c                   	pop    %esp
  80070c:	5b                   	pop    %ebx
  80070d:	5a                   	pop    %edx
  80070e:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80070f:	8b 1c 24             	mov    (%esp),%ebx
  800712:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800716:	89 ec                	mov    %ebp,%esp
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 28             	sub    $0x28,%esp
  800720:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800723:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	b8 03 00 00 00       	mov    $0x3,%eax
  800730:	8b 55 08             	mov    0x8(%ebp),%edx
  800733:	89 cb                	mov    %ecx,%ebx
  800735:	89 cf                	mov    %ecx,%edi
  800737:	51                   	push   %ecx
  800738:	52                   	push   %edx
  800739:	53                   	push   %ebx
  80073a:	54                   	push   %esp
  80073b:	55                   	push   %ebp
  80073c:	56                   	push   %esi
  80073d:	57                   	push   %edi
  80073e:	54                   	push   %esp
  80073f:	5d                   	pop    %ebp
  800740:	8d 35 48 07 80 00    	lea    0x800748,%esi
  800746:	0f 34                	sysenter 
  800748:	5f                   	pop    %edi
  800749:	5e                   	pop    %esi
  80074a:	5d                   	pop    %ebp
  80074b:	5c                   	pop    %esp
  80074c:	5b                   	pop    %ebx
  80074d:	5a                   	pop    %edx
  80074e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80074f:	85 c0                	test   %eax,%eax
  800751:	7e 28                	jle    80077b <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800753:	89 44 24 10          	mov    %eax,0x10(%esp)
  800757:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80075e:	00 
  80075f:	c7 44 24 08 ea 21 80 	movl   $0x8021ea,0x8(%esp)
  800766:	00 
  800767:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80076e:	00 
  80076f:	c7 04 24 07 22 80 00 	movl   $0x802207,(%esp)
  800776:	e8 d9 08 00 00       	call   801054 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80077b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80077e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800781:	89 ec                	mov    %ebp,%esp
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    
	...

00800790 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	05 00 00 00 30       	add    $0x30000000,%eax
  80079b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	89 04 24             	mov    %eax,(%esp)
  8007ac:	e8 df ff ff ff       	call   800790 <fd2num>
  8007b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8007b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	57                   	push   %edi
  8007bf:	56                   	push   %esi
  8007c0:	53                   	push   %ebx
  8007c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8007c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8007c9:	a8 01                	test   $0x1,%al
  8007cb:	74 36                	je     800803 <fd_alloc+0x48>
  8007cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8007d2:	a8 01                	test   $0x1,%al
  8007d4:	74 2d                	je     800803 <fd_alloc+0x48>
  8007d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8007db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8007e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8007e5:	89 c3                	mov    %eax,%ebx
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	c1 ea 16             	shr    $0x16,%edx
  8007ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8007ef:	f6 c2 01             	test   $0x1,%dl
  8007f2:	74 14                	je     800808 <fd_alloc+0x4d>
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	c1 ea 0c             	shr    $0xc,%edx
  8007f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8007fc:	f6 c2 01             	test   $0x1,%dl
  8007ff:	75 10                	jne    800811 <fd_alloc+0x56>
  800801:	eb 05                	jmp    800808 <fd_alloc+0x4d>
  800803:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800808:	89 1f                	mov    %ebx,(%edi)
  80080a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80080f:	eb 17                	jmp    800828 <fd_alloc+0x6d>
  800811:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800816:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80081b:	75 c8                	jne    8007e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80081d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800823:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5f                   	pop    %edi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	83 f8 1f             	cmp    $0x1f,%eax
  800836:	77 36                	ja     80086e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800838:	05 00 00 0d 00       	add    $0xd0000,%eax
  80083d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800840:	89 c2                	mov    %eax,%edx
  800842:	c1 ea 16             	shr    $0x16,%edx
  800845:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80084c:	f6 c2 01             	test   $0x1,%dl
  80084f:	74 1d                	je     80086e <fd_lookup+0x41>
  800851:	89 c2                	mov    %eax,%edx
  800853:	c1 ea 0c             	shr    $0xc,%edx
  800856:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80085d:	f6 c2 01             	test   $0x1,%dl
  800860:	74 0c                	je     80086e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	89 02                	mov    %eax,(%edx)
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80086c:	eb 05                	jmp    800873 <fd_lookup+0x46>
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80087b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80087e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	89 04 24             	mov    %eax,(%esp)
  800888:	e8 a0 ff ff ff       	call   80082d <fd_lookup>
  80088d:	85 c0                	test   %eax,%eax
  80088f:	78 0e                	js     80089f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800891:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	89 50 04             	mov    %edx,0x4(%eax)
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    

008008a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	56                   	push   %esi
  8008a5:	53                   	push   %ebx
  8008a6:	83 ec 10             	sub    $0x10,%esp
  8008a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8008af:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8008b4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008b9:	be 94 22 80 00       	mov    $0x802294,%esi
		if (devtab[i]->dev_id == dev_id) {
  8008be:	39 08                	cmp    %ecx,(%eax)
  8008c0:	75 10                	jne    8008d2 <dev_lookup+0x31>
  8008c2:	eb 04                	jmp    8008c8 <dev_lookup+0x27>
  8008c4:	39 08                	cmp    %ecx,(%eax)
  8008c6:	75 0a                	jne    8008d2 <dev_lookup+0x31>
			*dev = devtab[i];
  8008c8:	89 03                	mov    %eax,(%ebx)
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8008cf:	90                   	nop
  8008d0:	eb 31                	jmp    800903 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008d2:	83 c2 01             	add    $0x1,%edx
  8008d5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	75 e8                	jne    8008c4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008dc:	a1 40 50 80 00       	mov    0x805040,%eax
  8008e1:	8b 40 48             	mov    0x48(%eax),%eax
  8008e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ec:	c7 04 24 18 22 80 00 	movl   $0x802218,(%esp)
  8008f3:	e8 15 08 00 00       	call   80110d <cprintf>
	*dev = 0;
  8008f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8008fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800903:	83 c4 10             	add    $0x10,%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	83 ec 24             	sub    $0x24,%esp
  800911:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800914:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	89 04 24             	mov    %eax,(%esp)
  800921:	e8 07 ff ff ff       	call   80082d <fd_lookup>
  800926:	85 c0                	test   %eax,%eax
  800928:	78 53                	js     80097d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80092a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80092d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800931:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800934:	8b 00                	mov    (%eax),%eax
  800936:	89 04 24             	mov    %eax,(%esp)
  800939:	e8 63 ff ff ff       	call   8008a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80093e:	85 c0                	test   %eax,%eax
  800940:	78 3b                	js     80097d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800942:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800947:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80094a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80094e:	74 2d                	je     80097d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800950:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800953:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80095a:	00 00 00 
	stat->st_isdir = 0;
  80095d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800964:	00 00 00 
	stat->st_dev = dev;
  800967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800970:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800974:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800977:	89 14 24             	mov    %edx,(%esp)
  80097a:	ff 50 14             	call   *0x14(%eax)
}
  80097d:	83 c4 24             	add    $0x24,%esp
  800980:	5b                   	pop    %ebx
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	83 ec 24             	sub    $0x24,%esp
  80098a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80098d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800990:	89 44 24 04          	mov    %eax,0x4(%esp)
  800994:	89 1c 24             	mov    %ebx,(%esp)
  800997:	e8 91 fe ff ff       	call   80082d <fd_lookup>
  80099c:	85 c0                	test   %eax,%eax
  80099e:	78 5f                	js     8009ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009aa:	8b 00                	mov    (%eax),%eax
  8009ac:	89 04 24             	mov    %eax,(%esp)
  8009af:	e8 ed fe ff ff       	call   8008a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009b4:	85 c0                	test   %eax,%eax
  8009b6:	78 47                	js     8009ff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009bb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8009bf:	75 23                	jne    8009e4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8009c1:	a1 40 50 80 00       	mov    0x805040,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8009c6:	8b 40 48             	mov    0x48(%eax),%eax
  8009c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d1:	c7 04 24 38 22 80 00 	movl   $0x802238,(%esp)
  8009d8:	e8 30 07 00 00       	call   80110d <cprintf>
  8009dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8009e2:	eb 1b                	jmp    8009ff <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8009e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e7:	8b 48 18             	mov    0x18(%eax),%ecx
  8009ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8009ef:	85 c9                	test   %ecx,%ecx
  8009f1:	74 0c                	je     8009ff <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fa:	89 14 24             	mov    %edx,(%esp)
  8009fd:	ff d1                	call   *%ecx
}
  8009ff:	83 c4 24             	add    $0x24,%esp
  800a02:	5b                   	pop    %ebx
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	53                   	push   %ebx
  800a09:	83 ec 24             	sub    $0x24,%esp
  800a0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a16:	89 1c 24             	mov    %ebx,(%esp)
  800a19:	e8 0f fe ff ff       	call   80082d <fd_lookup>
  800a1e:	85 c0                	test   %eax,%eax
  800a20:	78 66                	js     800a88 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	89 04 24             	mov    %eax,(%esp)
  800a31:	e8 6b fe ff ff       	call   8008a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a36:	85 c0                	test   %eax,%eax
  800a38:	78 4e                	js     800a88 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a3d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800a41:	75 23                	jne    800a66 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a43:	a1 40 50 80 00       	mov    0x805040,%eax
  800a48:	8b 40 48             	mov    0x48(%eax),%eax
  800a4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a53:	c7 04 24 59 22 80 00 	movl   $0x802259,(%esp)
  800a5a:	e8 ae 06 00 00       	call   80110d <cprintf>
  800a5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800a64:	eb 22                	jmp    800a88 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a69:	8b 48 0c             	mov    0xc(%eax),%ecx
  800a6c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	74 13                	je     800a88 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800a75:	8b 45 10             	mov    0x10(%ebp),%eax
  800a78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a83:	89 14 24             	mov    %edx,(%esp)
  800a86:	ff d1                	call   *%ecx
}
  800a88:	83 c4 24             	add    $0x24,%esp
  800a8b:	5b                   	pop    %ebx
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	53                   	push   %ebx
  800a92:	83 ec 24             	sub    $0x24,%esp
  800a95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9f:	89 1c 24             	mov    %ebx,(%esp)
  800aa2:	e8 86 fd ff ff       	call   80082d <fd_lookup>
  800aa7:	85 c0                	test   %eax,%eax
  800aa9:	78 6b                	js     800b16 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab5:	8b 00                	mov    (%eax),%eax
  800ab7:	89 04 24             	mov    %eax,(%esp)
  800aba:	e8 e2 fd ff ff       	call   8008a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	78 53                	js     800b16 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ac3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ac6:	8b 42 08             	mov    0x8(%edx),%eax
  800ac9:	83 e0 03             	and    $0x3,%eax
  800acc:	83 f8 01             	cmp    $0x1,%eax
  800acf:	75 23                	jne    800af4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ad1:	a1 40 50 80 00       	mov    0x805040,%eax
  800ad6:	8b 40 48             	mov    0x48(%eax),%eax
  800ad9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800add:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae1:	c7 04 24 76 22 80 00 	movl   $0x802276,(%esp)
  800ae8:	e8 20 06 00 00       	call   80110d <cprintf>
  800aed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800af2:	eb 22                	jmp    800b16 <read+0x88>
	}
	if (!dev->dev_read)
  800af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af7:	8b 48 08             	mov    0x8(%eax),%ecx
  800afa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800aff:	85 c9                	test   %ecx,%ecx
  800b01:	74 13                	je     800b16 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b03:	8b 45 10             	mov    0x10(%ebp),%eax
  800b06:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b11:	89 14 24             	mov    %edx,(%esp)
  800b14:	ff d1                	call   *%ecx
}
  800b16:	83 c4 24             	add    $0x24,%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 1c             	sub    $0x1c,%esp
  800b25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b28:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	85 f6                	test   %esi,%esi
  800b3c:	74 29                	je     800b67 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b3e:	89 f0                	mov    %esi,%eax
  800b40:	29 d0                	sub    %edx,%eax
  800b42:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b46:	03 55 0c             	add    0xc(%ebp),%edx
  800b49:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b4d:	89 3c 24             	mov    %edi,(%esp)
  800b50:	e8 39 ff ff ff       	call   800a8e <read>
		if (m < 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	78 0e                	js     800b67 <readn+0x4b>
			return m;
		if (m == 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	74 08                	je     800b65 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b5d:	01 c3                	add    %eax,%ebx
  800b5f:	89 da                	mov    %ebx,%edx
  800b61:	39 f3                	cmp    %esi,%ebx
  800b63:	72 d9                	jb     800b3e <readn+0x22>
  800b65:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b67:	83 c4 1c             	add    $0x1c,%esp
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 20             	sub    $0x20,%esp
  800b77:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800b7a:	89 34 24             	mov    %esi,(%esp)
  800b7d:	e8 0e fc ff ff       	call   800790 <fd2num>
  800b82:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800b85:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b89:	89 04 24             	mov    %eax,(%esp)
  800b8c:	e8 9c fc ff ff       	call   80082d <fd_lookup>
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	85 c0                	test   %eax,%eax
  800b95:	78 05                	js     800b9c <fd_close+0x2d>
  800b97:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800b9a:	74 0c                	je     800ba8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800b9c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800ba0:	19 c0                	sbb    %eax,%eax
  800ba2:	f7 d0                	not    %eax
  800ba4:	21 c3                	and    %eax,%ebx
  800ba6:	eb 3d                	jmp    800be5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ba8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800baf:	8b 06                	mov    (%esi),%eax
  800bb1:	89 04 24             	mov    %eax,(%esp)
  800bb4:	e8 e8 fc ff ff       	call   8008a1 <dev_lookup>
  800bb9:	89 c3                	mov    %eax,%ebx
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	78 16                	js     800bd5 <fd_close+0x66>
		if (dev->dev_close)
  800bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc2:	8b 40 10             	mov    0x10(%eax),%eax
  800bc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	74 07                	je     800bd5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800bce:	89 34 24             	mov    %esi,(%esp)
  800bd1:	ff d0                	call   *%eax
  800bd3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800bd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800be0:	e8 2c f9 ff ff       	call   800511 <sys_page_unmap>
	return r;
}
  800be5:	89 d8                	mov    %ebx,%eax
  800be7:	83 c4 20             	add    $0x20,%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfe:	89 04 24             	mov    %eax,(%esp)
  800c01:	e8 27 fc ff ff       	call   80082d <fd_lookup>
  800c06:	85 c0                	test   %eax,%eax
  800c08:	78 13                	js     800c1d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800c0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800c11:	00 
  800c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c15:	89 04 24             	mov    %eax,(%esp)
  800c18:	e8 52 ff ff ff       	call   800b6f <fd_close>
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 18             	sub    $0x18,%esp
  800c25:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800c28:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c32:	00 
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	89 04 24             	mov    %eax,(%esp)
  800c39:	e8 79 03 00 00       	call   800fb7 <open>
  800c3e:	89 c3                	mov    %eax,%ebx
  800c40:	85 c0                	test   %eax,%eax
  800c42:	78 1b                	js     800c5f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800c44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4b:	89 1c 24             	mov    %ebx,(%esp)
  800c4e:	e8 b7 fc ff ff       	call   80090a <fstat>
  800c53:	89 c6                	mov    %eax,%esi
	close(fd);
  800c55:	89 1c 24             	mov    %ebx,(%esp)
  800c58:	e8 91 ff ff ff       	call   800bee <close>
  800c5d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800c5f:	89 d8                	mov    %ebx,%eax
  800c61:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800c64:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800c67:	89 ec                	mov    %ebp,%esp
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 14             	sub    $0x14,%esp
  800c72:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800c77:	89 1c 24             	mov    %ebx,(%esp)
  800c7a:	e8 6f ff ff ff       	call   800bee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800c7f:	83 c3 01             	add    $0x1,%ebx
  800c82:	83 fb 20             	cmp    $0x20,%ebx
  800c85:	75 f0                	jne    800c77 <close_all+0xc>
		close(i);
}
  800c87:	83 c4 14             	add    $0x14,%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	83 ec 58             	sub    $0x58,%esp
  800c93:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c96:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c99:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800c9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	89 04 24             	mov    %eax,(%esp)
  800cac:	e8 7c fb ff ff       	call   80082d <fd_lookup>
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	0f 88 e0 00 00 00    	js     800d9b <dup+0x10e>
		return r;
	close(newfdnum);
  800cbb:	89 3c 24             	mov    %edi,(%esp)
  800cbe:	e8 2b ff ff ff       	call   800bee <close>

	newfd = INDEX2FD(newfdnum);
  800cc3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800cc9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ccf:	89 04 24             	mov    %eax,(%esp)
  800cd2:	e8 c9 fa ff ff       	call   8007a0 <fd2data>
  800cd7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800cd9:	89 34 24             	mov    %esi,(%esp)
  800cdc:	e8 bf fa ff ff       	call   8007a0 <fd2data>
  800ce1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800ce4:	89 da                	mov    %ebx,%edx
  800ce6:	89 d8                	mov    %ebx,%eax
  800ce8:	c1 e8 16             	shr    $0x16,%eax
  800ceb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800cf2:	a8 01                	test   $0x1,%al
  800cf4:	74 43                	je     800d39 <dup+0xac>
  800cf6:	c1 ea 0c             	shr    $0xc,%edx
  800cf9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d00:	a8 01                	test   $0x1,%al
  800d02:	74 35                	je     800d39 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800d04:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d0b:	25 07 0e 00 00       	and    $0xe07,%eax
  800d10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d22:	00 
  800d23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d2e:	e8 4a f8 ff ff       	call   80057d <sys_page_map>
  800d33:	89 c3                	mov    %eax,%ebx
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 3f                	js     800d78 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d3c:	89 c2                	mov    %eax,%edx
  800d3e:	c1 ea 0c             	shr    $0xc,%edx
  800d41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d48:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d4e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d52:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d5d:	00 
  800d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d69:	e8 0f f8 ff ff       	call   80057d <sys_page_map>
  800d6e:	89 c3                	mov    %eax,%ebx
  800d70:	85 c0                	test   %eax,%eax
  800d72:	78 04                	js     800d78 <dup+0xeb>
  800d74:	89 fb                	mov    %edi,%ebx
  800d76:	eb 23                	jmp    800d9b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800d78:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d83:	e8 89 f7 ff ff       	call   800511 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800d88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d96:	e8 76 f7 ff ff       	call   800511 <sys_page_unmap>
	return r;
}
  800d9b:	89 d8                	mov    %ebx,%eax
  800d9d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da6:	89 ec                	mov    %ebp,%esp
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    
	...

00800dac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 18             	sub    $0x18,%esp
  800db2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800db5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800dbc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800dc3:	75 11                	jne    800dd6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800dc5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800dcc:	e8 5f 10 00 00       	call   801e30 <ipc_find_env>
  800dd1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800dd6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ddd:	00 
  800dde:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800de5:	00 
  800de6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dea:	a1 00 40 80 00       	mov    0x804000,%eax
  800def:	89 04 24             	mov    %eax,(%esp)
  800df2:	e8 84 10 00 00       	call   801e7b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800df7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dfe:	00 
  800dff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e0a:	e8 ea 10 00 00       	call   801ef9 <ipc_recv>
}
  800e0f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e12:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800e15:	89 ec                	mov    %ebp,%esp
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	8b 40 0c             	mov    0xc(%eax),%eax
  800e25:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  800e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e32:	ba 00 00 00 00       	mov    $0x0,%edx
  800e37:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3c:	e8 6b ff ff ff       	call   800dac <fsipc>
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	8b 40 0c             	mov    0xc(%eax),%eax
  800e4f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  800e54:	ba 00 00 00 00       	mov    $0x0,%edx
  800e59:	b8 06 00 00 00       	mov    $0x6,%eax
  800e5e:	e8 49 ff ff ff       	call   800dac <fsipc>
}
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    

00800e65 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e70:	b8 08 00 00 00       	mov    $0x8,%eax
  800e75:	e8 32 ff ff ff       	call   800dac <fsipc>
}
  800e7a:	c9                   	leave  
  800e7b:	c3                   	ret    

00800e7c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 14             	sub    $0x14,%esp
  800e83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	8b 40 0c             	mov    0xc(%eax),%eax
  800e8c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e91:	ba 00 00 00 00       	mov    $0x0,%edx
  800e96:	b8 05 00 00 00       	mov    $0x5,%eax
  800e9b:	e8 0c ff ff ff       	call   800dac <fsipc>
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	78 2b                	js     800ecf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ea4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800eab:	00 
  800eac:	89 1c 24             	mov    %ebx,(%esp)
  800eaf:	e8 86 0b 00 00       	call   801a3a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800eb4:	a1 80 60 80 00       	mov    0x806080,%eax
  800eb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ebf:	a1 84 60 80 00       	mov    0x806084,%eax
  800ec4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800ecf:	83 c4 14             	add    $0x14,%esp
  800ed2:	5b                   	pop    %ebx
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 18             	sub    $0x18,%esp
  800edb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ede:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800ee3:	76 05                	jbe    800eea <devfile_write+0x15>
  800ee5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	8b 52 0c             	mov    0xc(%edx),%edx
  800ef0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  800ef6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800efb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f06:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  800f0d:	e8 13 0d 00 00       	call   801c25 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800f12:	ba 00 00 00 00       	mov    $0x0,%edx
  800f17:	b8 04 00 00 00       	mov    $0x4,%eax
  800f1c:	e8 8b fe ff ff       	call   800dac <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	53                   	push   %ebx
  800f27:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2d:	8b 40 0c             	mov    0xc(%eax),%eax
  800f30:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  800f35:	8b 45 10             	mov    0x10(%ebp),%eax
  800f38:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  800f3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f42:	b8 03 00 00 00       	mov    $0x3,%eax
  800f47:	e8 60 fe ff ff       	call   800dac <fsipc>
  800f4c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 17                	js     800f69 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800f52:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f56:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800f5d:	00 
  800f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f61:	89 04 24             	mov    %eax,(%esp)
  800f64:	e8 bc 0c 00 00       	call   801c25 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800f69:	89 d8                	mov    %ebx,%eax
  800f6b:	83 c4 14             	add    $0x14,%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	53                   	push   %ebx
  800f75:	83 ec 14             	sub    $0x14,%esp
  800f78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800f7b:	89 1c 24             	mov    %ebx,(%esp)
  800f7e:	e8 6d 0a 00 00       	call   8019f0 <strlen>
  800f83:	89 c2                	mov    %eax,%edx
  800f85:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800f8a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800f90:	7f 1f                	jg     800fb1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800f92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f96:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  800f9d:	e8 98 0a 00 00       	call   801a3a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800fa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fac:	e8 fb fd ff ff       	call   800dac <fsipc>
}
  800fb1:	83 c4 14             	add    $0x14,%esp
  800fb4:	5b                   	pop    %ebx
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 28             	sub    $0x28,%esp
  800fbd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fc0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800fc3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  800fc6:	89 34 24             	mov    %esi,(%esp)
  800fc9:	e8 22 0a 00 00       	call   8019f0 <strlen>
  800fce:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800fd3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800fd8:	7f 6d                	jg     801047 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  800fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	e8 d6 f7 ff ff       	call   8007bb <fd_alloc>
  800fe5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 5c                	js     801047 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  800feb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fee:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  800ff3:	89 34 24             	mov    %esi,(%esp)
  800ff6:	e8 f5 09 00 00       	call   8019f0 <strlen>
  800ffb:	83 c0 01             	add    $0x1,%eax
  800ffe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801002:	89 74 24 04          	mov    %esi,0x4(%esp)
  801006:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80100d:	e8 13 0c 00 00       	call   801c25 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801012:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801015:	b8 01 00 00 00       	mov    $0x1,%eax
  80101a:	e8 8d fd ff ff       	call   800dac <fsipc>
  80101f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801021:	85 c0                	test   %eax,%eax
  801023:	79 15                	jns    80103a <open+0x83>
             fd_close(fd,0);
  801025:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80102c:	00 
  80102d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801030:	89 04 24             	mov    %eax,(%esp)
  801033:	e8 37 fb ff ff       	call   800b6f <fd_close>
             return r;
  801038:	eb 0d                	jmp    801047 <open+0x90>
        }
        return fd2num(fd);
  80103a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103d:	89 04 24             	mov    %eax,(%esp)
  801040:	e8 4b f7 ff ff       	call   800790 <fd2num>
  801045:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801047:	89 d8                	mov    %ebx,%eax
  801049:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80104c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80104f:	89 ec                	mov    %ebp,%esp
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    
	...

00801054 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80105c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80105f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801065:	e8 70 f6 ff ff       	call   8006da <sys_getenvid>
  80106a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801071:	8b 55 08             	mov    0x8(%ebp),%edx
  801074:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801078:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80107c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801080:	c7 04 24 9c 22 80 00 	movl   $0x80229c,(%esp)
  801087:	e8 81 00 00 00       	call   80110d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80108c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801090:	8b 45 10             	mov    0x10(%ebp),%eax
  801093:	89 04 24             	mov    %eax,(%esp)
  801096:	e8 11 00 00 00       	call   8010ac <vcprintf>
	cprintf("\n");
  80109b:	c7 04 24 90 22 80 00 	movl   $0x802290,(%esp)
  8010a2:	e8 66 00 00 00       	call   80110d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010a7:	cc                   	int3   
  8010a8:	eb fd                	jmp    8010a7 <_panic+0x53>
	...

008010ac <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8010b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010bc:	00 00 00 
	b.cnt = 0;
  8010bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e1:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  8010e8:	e8 cf 01 00 00       	call   8012bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8010f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fd:	89 04 24             	mov    %eax,(%esp)
  801100:	e8 ef f0 ff ff       	call   8001f4 <sys_cputs>

	return b.cnt;
}
  801105:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801113:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801116:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
  80111d:	89 04 24             	mov    %eax,(%esp)
  801120:	e8 87 ff ff ff       	call   8010ac <vcprintf>
	va_end(ap);

	return cnt;
}
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	53                   	push   %ebx
  80112b:	83 ec 14             	sub    $0x14,%esp
  80112e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801131:	8b 03                	mov    (%ebx),%eax
  801133:	8b 55 08             	mov    0x8(%ebp),%edx
  801136:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80113a:	83 c0 01             	add    $0x1,%eax
  80113d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80113f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801144:	75 19                	jne    80115f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801146:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80114d:	00 
  80114e:	8d 43 08             	lea    0x8(%ebx),%eax
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 9b f0 ff ff       	call   8001f4 <sys_cputs>
		b->idx = 0;
  801159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80115f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801163:	83 c4 14             	add    $0x14,%esp
  801166:	5b                   	pop    %ebx
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    
  801169:	00 00                	add    %al,(%eax)
  80116b:	00 00                	add    %al,(%eax)
  80116d:	00 00                	add    %al,(%eax)
	...

00801170 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 4c             	sub    $0x4c,%esp
  801179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80117c:	89 d6                	mov    %edx,%esi
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801184:	8b 55 0c             	mov    0xc(%ebp),%edx
  801187:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80118a:	8b 45 10             	mov    0x10(%ebp),%eax
  80118d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801190:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  801193:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801196:	b9 00 00 00 00       	mov    $0x0,%ecx
  80119b:	39 d1                	cmp    %edx,%ecx
  80119d:	72 07                	jb     8011a6 <printnum_v2+0x36>
  80119f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8011a2:	39 d0                	cmp    %edx,%eax
  8011a4:	77 5f                	ja     801205 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8011a6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8011aa:	83 eb 01             	sub    $0x1,%ebx
  8011ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011b9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8011bd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8011c0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8011c3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8011c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011d1:	00 
  8011d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011d5:	89 04 24             	mov    %eax,(%esp)
  8011d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8011db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011df:	e8 8c 0d 00 00       	call   801f70 <__udivdi3>
  8011e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8011e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8011ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011f2:	89 04 24             	mov    %eax,(%esp)
  8011f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011f9:	89 f2                	mov    %esi,%edx
  8011fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fe:	e8 6d ff ff ff       	call   801170 <printnum_v2>
  801203:	eb 1e                	jmp    801223 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801205:	83 ff 2d             	cmp    $0x2d,%edi
  801208:	74 19                	je     801223 <printnum_v2+0xb3>
		while (--width > 0)
  80120a:	83 eb 01             	sub    $0x1,%ebx
  80120d:	85 db                	test   %ebx,%ebx
  80120f:	90                   	nop
  801210:	7e 11                	jle    801223 <printnum_v2+0xb3>
			putch(padc, putdat);
  801212:	89 74 24 04          	mov    %esi,0x4(%esp)
  801216:	89 3c 24             	mov    %edi,(%esp)
  801219:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80121c:	83 eb 01             	sub    $0x1,%ebx
  80121f:	85 db                	test   %ebx,%ebx
  801221:	7f ef                	jg     801212 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801223:	89 74 24 04          	mov    %esi,0x4(%esp)
  801227:	8b 74 24 04          	mov    0x4(%esp),%esi
  80122b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80122e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801232:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801239:	00 
  80123a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80123d:	89 14 24             	mov    %edx,(%esp)
  801240:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801243:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801247:	e8 54 0e 00 00       	call   8020a0 <__umoddi3>
  80124c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801250:	0f be 80 bf 22 80 00 	movsbl 0x8022bf(%eax),%eax
  801257:	89 04 24             	mov    %eax,(%esp)
  80125a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80125d:	83 c4 4c             	add    $0x4c,%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801268:	83 fa 01             	cmp    $0x1,%edx
  80126b:	7e 0e                	jle    80127b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80126d:	8b 10                	mov    (%eax),%edx
  80126f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801272:	89 08                	mov    %ecx,(%eax)
  801274:	8b 02                	mov    (%edx),%eax
  801276:	8b 52 04             	mov    0x4(%edx),%edx
  801279:	eb 22                	jmp    80129d <getuint+0x38>
	else if (lflag)
  80127b:	85 d2                	test   %edx,%edx
  80127d:	74 10                	je     80128f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80127f:	8b 10                	mov    (%eax),%edx
  801281:	8d 4a 04             	lea    0x4(%edx),%ecx
  801284:	89 08                	mov    %ecx,(%eax)
  801286:	8b 02                	mov    (%edx),%eax
  801288:	ba 00 00 00 00       	mov    $0x0,%edx
  80128d:	eb 0e                	jmp    80129d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80128f:	8b 10                	mov    (%eax),%edx
  801291:	8d 4a 04             	lea    0x4(%edx),%ecx
  801294:	89 08                	mov    %ecx,(%eax)
  801296:	8b 02                	mov    (%edx),%eax
  801298:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8012a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8012a9:	8b 10                	mov    (%eax),%edx
  8012ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8012ae:	73 0a                	jae    8012ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8012b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b3:	88 0a                	mov    %cl,(%edx)
  8012b5:	83 c2 01             	add    $0x1,%edx
  8012b8:	89 10                	mov    %edx,(%eax)
}
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	57                   	push   %edi
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 6c             	sub    $0x6c,%esp
  8012c5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8012c8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8012cf:	eb 1a                	jmp    8012eb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	0f 84 66 06 00 00    	je     80193f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8012d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012e0:	89 04 24             	mov    %eax,(%esp)
  8012e3:	ff 55 08             	call   *0x8(%ebp)
  8012e6:	eb 03                	jmp    8012eb <vprintfmt+0x2f>
  8012e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012eb:	0f b6 07             	movzbl (%edi),%eax
  8012ee:	83 c7 01             	add    $0x1,%edi
  8012f1:	83 f8 25             	cmp    $0x25,%eax
  8012f4:	75 db                	jne    8012d1 <vprintfmt+0x15>
  8012f6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8012fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012ff:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801306:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80130b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801312:	be 00 00 00 00       	mov    $0x0,%esi
  801317:	eb 06                	jmp    80131f <vprintfmt+0x63>
  801319:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80131d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131f:	0f b6 17             	movzbl (%edi),%edx
  801322:	0f b6 c2             	movzbl %dl,%eax
  801325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801328:	8d 47 01             	lea    0x1(%edi),%eax
  80132b:	83 ea 23             	sub    $0x23,%edx
  80132e:	80 fa 55             	cmp    $0x55,%dl
  801331:	0f 87 60 05 00 00    	ja     801897 <vprintfmt+0x5db>
  801337:	0f b6 d2             	movzbl %dl,%edx
  80133a:	ff 24 95 a0 24 80 00 	jmp    *0x8024a0(,%edx,4)
  801341:	b9 01 00 00 00       	mov    $0x1,%ecx
  801346:	eb d5                	jmp    80131d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801348:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80134b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80134e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801351:	8d 7a d0             	lea    -0x30(%edx),%edi
  801354:	83 ff 09             	cmp    $0x9,%edi
  801357:	76 08                	jbe    801361 <vprintfmt+0xa5>
  801359:	eb 40                	jmp    80139b <vprintfmt+0xdf>
  80135b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80135f:	eb bc                	jmp    80131d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801361:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801364:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  801367:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80136b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80136e:	8d 7a d0             	lea    -0x30(%edx),%edi
  801371:	83 ff 09             	cmp    $0x9,%edi
  801374:	76 eb                	jbe    801361 <vprintfmt+0xa5>
  801376:	eb 23                	jmp    80139b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801378:	8b 55 14             	mov    0x14(%ebp),%edx
  80137b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80137e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801381:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  801383:	eb 16                	jmp    80139b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  801385:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801388:	c1 fa 1f             	sar    $0x1f,%edx
  80138b:	f7 d2                	not    %edx
  80138d:	21 55 d8             	and    %edx,-0x28(%ebp)
  801390:	eb 8b                	jmp    80131d <vprintfmt+0x61>
  801392:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801399:	eb 82                	jmp    80131d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80139b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80139f:	0f 89 78 ff ff ff    	jns    80131d <vprintfmt+0x61>
  8013a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8013a8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8013ab:	e9 6d ff ff ff       	jmp    80131d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8013b0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8013b3:	e9 65 ff ff ff       	jmp    80131d <vprintfmt+0x61>
  8013b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013be:	8d 50 04             	lea    0x4(%eax),%edx
  8013c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013cb:	8b 00                	mov    (%eax),%eax
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	ff 55 08             	call   *0x8(%ebp)
  8013d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8013d6:	e9 10 ff ff ff       	jmp    8012eb <vprintfmt+0x2f>
  8013db:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013de:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e1:	8d 50 04             	lea    0x4(%eax),%edx
  8013e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e7:	8b 00                	mov    (%eax),%eax
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	c1 fa 1f             	sar    $0x1f,%edx
  8013ee:	31 d0                	xor    %edx,%eax
  8013f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013f2:	83 f8 0f             	cmp    $0xf,%eax
  8013f5:	7f 0b                	jg     801402 <vprintfmt+0x146>
  8013f7:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8013fe:	85 d2                	test   %edx,%edx
  801400:	75 26                	jne    801428 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801402:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801406:	c7 44 24 08 d0 22 80 	movl   $0x8022d0,0x8(%esp)
  80140d:	00 
  80140e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801411:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801415:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801418:	89 1c 24             	mov    %ebx,(%esp)
  80141b:	e8 a7 05 00 00       	call   8019c7 <printfmt>
  801420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801423:	e9 c3 fe ff ff       	jmp    8012eb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801428:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80142c:	c7 44 24 08 d9 22 80 	movl   $0x8022d9,0x8(%esp)
  801433:	00 
  801434:	8b 45 0c             	mov    0xc(%ebp),%eax
  801437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143b:	8b 55 08             	mov    0x8(%ebp),%edx
  80143e:	89 14 24             	mov    %edx,(%esp)
  801441:	e8 81 05 00 00       	call   8019c7 <printfmt>
  801446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801449:	e9 9d fe ff ff       	jmp    8012eb <vprintfmt+0x2f>
  80144e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801451:	89 c7                	mov    %eax,%edi
  801453:	89 d9                	mov    %ebx,%ecx
  801455:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801458:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80145b:	8b 45 14             	mov    0x14(%ebp),%eax
  80145e:	8d 50 04             	lea    0x4(%eax),%edx
  801461:	89 55 14             	mov    %edx,0x14(%ebp)
  801464:	8b 30                	mov    (%eax),%esi
  801466:	85 f6                	test   %esi,%esi
  801468:	75 05                	jne    80146f <vprintfmt+0x1b3>
  80146a:	be dc 22 80 00       	mov    $0x8022dc,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80146f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  801473:	7e 06                	jle    80147b <vprintfmt+0x1bf>
  801475:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  801479:	75 10                	jne    80148b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147b:	0f be 06             	movsbl (%esi),%eax
  80147e:	85 c0                	test   %eax,%eax
  801480:	0f 85 a2 00 00 00    	jne    801528 <vprintfmt+0x26c>
  801486:	e9 92 00 00 00       	jmp    80151d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80148b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80148f:	89 34 24             	mov    %esi,(%esp)
  801492:	e8 74 05 00 00       	call   801a0b <strnlen>
  801497:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80149a:	29 c2                	sub    %eax,%edx
  80149c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80149f:	85 d2                	test   %edx,%edx
  8014a1:	7e d8                	jle    80147b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8014a3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8014a7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8014aa:	89 d3                	mov    %edx,%ebx
  8014ac:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014af:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8014b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014b5:	89 ce                	mov    %ecx,%esi
  8014b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014bb:	89 34 24             	mov    %esi,(%esp)
  8014be:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8014c1:	83 eb 01             	sub    $0x1,%ebx
  8014c4:	85 db                	test   %ebx,%ebx
  8014c6:	7f ef                	jg     8014b7 <vprintfmt+0x1fb>
  8014c8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8014cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8014ce:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8014d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8014d8:	eb a1                	jmp    80147b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8014da:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8014de:	74 1b                	je     8014fb <vprintfmt+0x23f>
  8014e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8014e3:	83 fa 5e             	cmp    $0x5e,%edx
  8014e6:	76 13                	jbe    8014fb <vprintfmt+0x23f>
					putch('?', putdat);
  8014e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ef:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8014f6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8014f9:	eb 0d                	jmp    801508 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8014fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801502:	89 04 24             	mov    %eax,(%esp)
  801505:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801508:	83 ef 01             	sub    $0x1,%edi
  80150b:	0f be 06             	movsbl (%esi),%eax
  80150e:	85 c0                	test   %eax,%eax
  801510:	74 05                	je     801517 <vprintfmt+0x25b>
  801512:	83 c6 01             	add    $0x1,%esi
  801515:	eb 1a                	jmp    801531 <vprintfmt+0x275>
  801517:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80151a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80151d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801521:	7f 1f                	jg     801542 <vprintfmt+0x286>
  801523:	e9 c0 fd ff ff       	jmp    8012e8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801528:	83 c6 01             	add    $0x1,%esi
  80152b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80152e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801531:	85 db                	test   %ebx,%ebx
  801533:	78 a5                	js     8014da <vprintfmt+0x21e>
  801535:	83 eb 01             	sub    $0x1,%ebx
  801538:	79 a0                	jns    8014da <vprintfmt+0x21e>
  80153a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80153d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801540:	eb db                	jmp    80151d <vprintfmt+0x261>
  801542:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801545:	8b 75 0c             	mov    0xc(%ebp),%esi
  801548:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80154b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80154e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801552:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801559:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80155b:	83 eb 01             	sub    $0x1,%ebx
  80155e:	85 db                	test   %ebx,%ebx
  801560:	7f ec                	jg     80154e <vprintfmt+0x292>
  801562:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801565:	e9 81 fd ff ff       	jmp    8012eb <vprintfmt+0x2f>
  80156a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80156d:	83 fe 01             	cmp    $0x1,%esi
  801570:	7e 10                	jle    801582 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801572:	8b 45 14             	mov    0x14(%ebp),%eax
  801575:	8d 50 08             	lea    0x8(%eax),%edx
  801578:	89 55 14             	mov    %edx,0x14(%ebp)
  80157b:	8b 18                	mov    (%eax),%ebx
  80157d:	8b 70 04             	mov    0x4(%eax),%esi
  801580:	eb 26                	jmp    8015a8 <vprintfmt+0x2ec>
	else if (lflag)
  801582:	85 f6                	test   %esi,%esi
  801584:	74 12                	je     801598 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801586:	8b 45 14             	mov    0x14(%ebp),%eax
  801589:	8d 50 04             	lea    0x4(%eax),%edx
  80158c:	89 55 14             	mov    %edx,0x14(%ebp)
  80158f:	8b 18                	mov    (%eax),%ebx
  801591:	89 de                	mov    %ebx,%esi
  801593:	c1 fe 1f             	sar    $0x1f,%esi
  801596:	eb 10                	jmp    8015a8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801598:	8b 45 14             	mov    0x14(%ebp),%eax
  80159b:	8d 50 04             	lea    0x4(%eax),%edx
  80159e:	89 55 14             	mov    %edx,0x14(%ebp)
  8015a1:	8b 18                	mov    (%eax),%ebx
  8015a3:	89 de                	mov    %ebx,%esi
  8015a5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8015a8:	83 f9 01             	cmp    $0x1,%ecx
  8015ab:	75 1e                	jne    8015cb <vprintfmt+0x30f>
                               if((long long)num > 0){
  8015ad:	85 f6                	test   %esi,%esi
  8015af:	78 1a                	js     8015cb <vprintfmt+0x30f>
  8015b1:	85 f6                	test   %esi,%esi
  8015b3:	7f 05                	jg     8015ba <vprintfmt+0x2fe>
  8015b5:	83 fb 00             	cmp    $0x0,%ebx
  8015b8:	76 11                	jbe    8015cb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8015ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015bd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015c1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8015c8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8015cb:	85 f6                	test   %esi,%esi
  8015cd:	78 13                	js     8015e2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8015cf:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8015d2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8015d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015dd:	e9 da 00 00 00       	jmp    8016bc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8015e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8015f0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8015f3:	89 da                	mov    %ebx,%edx
  8015f5:	89 f1                	mov    %esi,%ecx
  8015f7:	f7 da                	neg    %edx
  8015f9:	83 d1 00             	adc    $0x0,%ecx
  8015fc:	f7 d9                	neg    %ecx
  8015fe:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801601:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80160c:	e9 ab 00 00 00       	jmp    8016bc <vprintfmt+0x400>
  801611:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801614:	89 f2                	mov    %esi,%edx
  801616:	8d 45 14             	lea    0x14(%ebp),%eax
  801619:	e8 47 fc ff ff       	call   801265 <getuint>
  80161e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801621:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801627:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80162c:	e9 8b 00 00 00       	jmp    8016bc <vprintfmt+0x400>
  801631:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801634:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801637:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80163b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801642:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801645:	89 f2                	mov    %esi,%edx
  801647:	8d 45 14             	lea    0x14(%ebp),%eax
  80164a:	e8 16 fc ff ff       	call   801265 <getuint>
  80164f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801652:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801655:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801658:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80165d:	eb 5d                	jmp    8016bc <vprintfmt+0x400>
  80165f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801662:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801665:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801669:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801670:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801673:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801677:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80167e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801681:	8b 45 14             	mov    0x14(%ebp),%eax
  801684:	8d 50 04             	lea    0x4(%eax),%edx
  801687:	89 55 14             	mov    %edx,0x14(%ebp)
  80168a:	8b 10                	mov    (%eax),%edx
  80168c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801691:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801694:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80169a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80169f:	eb 1b                	jmp    8016bc <vprintfmt+0x400>
  8016a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8016a4:	89 f2                	mov    %esi,%edx
  8016a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8016a9:	e8 b7 fb ff ff       	call   801265 <getuint>
  8016ae:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8016b1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8016b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016b7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8016bc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8016c0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8016c6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8016ca:	77 09                	ja     8016d5 <vprintfmt+0x419>
  8016cc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8016cf:	0f 82 ac 00 00 00    	jb     801781 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8016d5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016d8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8016dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016df:	83 ea 01             	sub    $0x1,%edx
  8016e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ea:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016ee:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8016f2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8016f5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8016f8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8016fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801706:	00 
  801707:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80170a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80170d:	89 0c 24             	mov    %ecx,(%esp)
  801710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801714:	e8 57 08 00 00       	call   801f70 <__udivdi3>
  801719:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80171c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80171f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801723:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801727:	89 04 24             	mov    %eax,(%esp)
  80172a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80172e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	e8 37 fa ff ff       	call   801170 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801739:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80173c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801740:	8b 74 24 04          	mov    0x4(%esp),%esi
  801744:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801747:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801752:	00 
  801753:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801756:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801759:	89 14 24             	mov    %edx,(%esp)
  80175c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801760:	e8 3b 09 00 00       	call   8020a0 <__umoddi3>
  801765:	89 74 24 04          	mov    %esi,0x4(%esp)
  801769:	0f be 80 bf 22 80 00 	movsbl 0x8022bf(%eax),%eax
  801770:	89 04 24             	mov    %eax,(%esp)
  801773:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801776:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80177a:	74 54                	je     8017d0 <vprintfmt+0x514>
  80177c:	e9 67 fb ff ff       	jmp    8012e8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801781:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801785:	8d 76 00             	lea    0x0(%esi),%esi
  801788:	0f 84 2a 01 00 00    	je     8018b8 <vprintfmt+0x5fc>
		while (--width > 0)
  80178e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801791:	83 ef 01             	sub    $0x1,%edi
  801794:	85 ff                	test   %edi,%edi
  801796:	0f 8e 5e 01 00 00    	jle    8018fa <vprintfmt+0x63e>
  80179c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80179f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8017a2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8017a5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8017a8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8017ab:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8017ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b2:	89 1c 24             	mov    %ebx,(%esp)
  8017b5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8017b8:	83 ef 01             	sub    $0x1,%edi
  8017bb:	85 ff                	test   %edi,%edi
  8017bd:	7f ef                	jg     8017ae <vprintfmt+0x4f2>
  8017bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8017c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8017c5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8017c8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8017cb:	e9 2a 01 00 00       	jmp    8018fa <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8017d0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8017d3:	83 eb 01             	sub    $0x1,%ebx
  8017d6:	85 db                	test   %ebx,%ebx
  8017d8:	0f 8e 0a fb ff ff    	jle    8012e8 <vprintfmt+0x2c>
  8017de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017e1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8017e4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8017e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017eb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8017f2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8017f4:	83 eb 01             	sub    $0x1,%ebx
  8017f7:	85 db                	test   %ebx,%ebx
  8017f9:	7f ec                	jg     8017e7 <vprintfmt+0x52b>
  8017fb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8017fe:	e9 e8 fa ff ff       	jmp    8012eb <vprintfmt+0x2f>
  801803:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801806:	8b 45 14             	mov    0x14(%ebp),%eax
  801809:	8d 50 04             	lea    0x4(%eax),%edx
  80180c:	89 55 14             	mov    %edx,0x14(%ebp)
  80180f:	8b 00                	mov    (%eax),%eax
  801811:	85 c0                	test   %eax,%eax
  801813:	75 2a                	jne    80183f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801815:	c7 44 24 0c f8 23 80 	movl   $0x8023f8,0xc(%esp)
  80181c:	00 
  80181d:	c7 44 24 08 d9 22 80 	movl   $0x8022d9,0x8(%esp)
  801824:	00 
  801825:	8b 55 0c             	mov    0xc(%ebp),%edx
  801828:	89 54 24 04          	mov    %edx,0x4(%esp)
  80182c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80182f:	89 0c 24             	mov    %ecx,(%esp)
  801832:	e8 90 01 00 00       	call   8019c7 <printfmt>
  801837:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80183a:	e9 ac fa ff ff       	jmp    8012eb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80183f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801842:	8b 13                	mov    (%ebx),%edx
  801844:	83 fa 7f             	cmp    $0x7f,%edx
  801847:	7e 29                	jle    801872 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801849:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80184b:	c7 44 24 0c 30 24 80 	movl   $0x802430,0xc(%esp)
  801852:	00 
  801853:	c7 44 24 08 d9 22 80 	movl   $0x8022d9,0x8(%esp)
  80185a:	00 
  80185b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	89 04 24             	mov    %eax,(%esp)
  801865:	e8 5d 01 00 00       	call   8019c7 <printfmt>
  80186a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186d:	e9 79 fa ff ff       	jmp    8012eb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801872:	88 10                	mov    %dl,(%eax)
  801874:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801877:	e9 6f fa ff ff       	jmp    8012eb <vprintfmt+0x2f>
  80187c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80187f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801885:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801889:	89 14 24             	mov    %edx,(%esp)
  80188c:	ff 55 08             	call   *0x8(%ebp)
  80188f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801892:	e9 54 fa ff ff       	jmp    8012eb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801897:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80189a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80189e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8018a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8018a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8018ab:	80 38 25             	cmpb   $0x25,(%eax)
  8018ae:	0f 84 37 fa ff ff    	je     8012eb <vprintfmt+0x2f>
  8018b4:	89 c7                	mov    %eax,%edi
  8018b6:	eb f0                	jmp    8018a8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8018b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8018c3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8018c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018d1:	00 
  8018d2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8018d5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8018d8:	89 04 24             	mov    %eax,(%esp)
  8018db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018df:	e8 bc 07 00 00       	call   8020a0 <__umoddi3>
  8018e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e8:	0f be 80 bf 22 80 00 	movsbl 0x8022bf(%eax),%eax
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	ff 55 08             	call   *0x8(%ebp)
  8018f5:	e9 d6 fe ff ff       	jmp    8017d0 <vprintfmt+0x514>
  8018fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801901:	8b 74 24 04          	mov    0x4(%esp),%esi
  801905:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801908:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80190c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801913:	00 
  801914:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801917:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80191a:	89 04 24             	mov    %eax,(%esp)
  80191d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801921:	e8 7a 07 00 00       	call   8020a0 <__umoddi3>
  801926:	89 74 24 04          	mov    %esi,0x4(%esp)
  80192a:	0f be 80 bf 22 80 00 	movsbl 0x8022bf(%eax),%eax
  801931:	89 04 24             	mov    %eax,(%esp)
  801934:	ff 55 08             	call   *0x8(%ebp)
  801937:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80193a:	e9 ac f9 ff ff       	jmp    8012eb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80193f:	83 c4 6c             	add    $0x6c,%esp
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5f                   	pop    %edi
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 28             	sub    $0x28,%esp
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801953:	85 c0                	test   %eax,%eax
  801955:	74 04                	je     80195b <vsnprintf+0x14>
  801957:	85 d2                	test   %edx,%edx
  801959:	7f 07                	jg     801962 <vsnprintf+0x1b>
  80195b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801960:	eb 3b                	jmp    80199d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801962:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801965:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801969:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80196c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801973:	8b 45 14             	mov    0x14(%ebp),%eax
  801976:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80197a:	8b 45 10             	mov    0x10(%ebp),%eax
  80197d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801981:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801984:	89 44 24 04          	mov    %eax,0x4(%esp)
  801988:	c7 04 24 9f 12 80 00 	movl   $0x80129f,(%esp)
  80198f:	e8 28 f9 ff ff       	call   8012bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801994:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801997:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80199a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8019a5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8019a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8019af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	89 04 24             	mov    %eax,(%esp)
  8019c0:	e8 82 ff ff ff       	call   801947 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8019cd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8019d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e5:	89 04 24             	mov    %eax,(%esp)
  8019e8:	e8 cf f8 ff ff       	call   8012bc <vprintfmt>
	va_end(ap);
}
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    
	...

008019f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8019fe:	74 09                	je     801a09 <strlen+0x19>
		n++;
  801a00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a07:	75 f7                	jne    801a00 <strlen+0x10>
		n++;
	return n;
}
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	53                   	push   %ebx
  801a0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a15:	85 c9                	test   %ecx,%ecx
  801a17:	74 19                	je     801a32 <strnlen+0x27>
  801a19:	80 3b 00             	cmpb   $0x0,(%ebx)
  801a1c:	74 14                	je     801a32 <strnlen+0x27>
  801a1e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801a23:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a26:	39 c8                	cmp    %ecx,%eax
  801a28:	74 0d                	je     801a37 <strnlen+0x2c>
  801a2a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801a2e:	75 f3                	jne    801a23 <strnlen+0x18>
  801a30:	eb 05                	jmp    801a37 <strnlen+0x2c>
  801a32:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801a37:	5b                   	pop    %ebx
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    

00801a3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	53                   	push   %ebx
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a44:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801a4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801a50:	83 c2 01             	add    $0x1,%edx
  801a53:	84 c9                	test   %cl,%cl
  801a55:	75 f2                	jne    801a49 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801a57:	5b                   	pop    %ebx
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a64:	89 1c 24             	mov    %ebx,(%esp)
  801a67:	e8 84 ff ff ff       	call   8019f0 <strlen>
	strcpy(dst + len, src);
  801a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a6f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a73:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801a76:	89 04 24             	mov    %eax,(%esp)
  801a79:	e8 bc ff ff ff       	call   801a3a <strcpy>
	return dst;
}
  801a7e:	89 d8                	mov    %ebx,%eax
  801a80:	83 c4 08             	add    $0x8,%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    

00801a86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	56                   	push   %esi
  801a8a:	53                   	push   %ebx
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a91:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a94:	85 f6                	test   %esi,%esi
  801a96:	74 18                	je     801ab0 <strncpy+0x2a>
  801a98:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801a9d:	0f b6 1a             	movzbl (%edx),%ebx
  801aa0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801aa3:	80 3a 01             	cmpb   $0x1,(%edx)
  801aa6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aa9:	83 c1 01             	add    $0x1,%ecx
  801aac:	39 ce                	cmp    %ecx,%esi
  801aae:	77 ed                	ja     801a9d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	56                   	push   %esi
  801ab8:	53                   	push   %ebx
  801ab9:	8b 75 08             	mov    0x8(%ebp),%esi
  801abc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ac2:	89 f0                	mov    %esi,%eax
  801ac4:	85 c9                	test   %ecx,%ecx
  801ac6:	74 27                	je     801aef <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801ac8:	83 e9 01             	sub    $0x1,%ecx
  801acb:	74 1d                	je     801aea <strlcpy+0x36>
  801acd:	0f b6 1a             	movzbl (%edx),%ebx
  801ad0:	84 db                	test   %bl,%bl
  801ad2:	74 16                	je     801aea <strlcpy+0x36>
			*dst++ = *src++;
  801ad4:	88 18                	mov    %bl,(%eax)
  801ad6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ad9:	83 e9 01             	sub    $0x1,%ecx
  801adc:	74 0e                	je     801aec <strlcpy+0x38>
			*dst++ = *src++;
  801ade:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ae1:	0f b6 1a             	movzbl (%edx),%ebx
  801ae4:	84 db                	test   %bl,%bl
  801ae6:	75 ec                	jne    801ad4 <strlcpy+0x20>
  801ae8:	eb 02                	jmp    801aec <strlcpy+0x38>
  801aea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801aec:	c6 00 00             	movb   $0x0,(%eax)
  801aef:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801afe:	0f b6 01             	movzbl (%ecx),%eax
  801b01:	84 c0                	test   %al,%al
  801b03:	74 15                	je     801b1a <strcmp+0x25>
  801b05:	3a 02                	cmp    (%edx),%al
  801b07:	75 11                	jne    801b1a <strcmp+0x25>
		p++, q++;
  801b09:	83 c1 01             	add    $0x1,%ecx
  801b0c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b0f:	0f b6 01             	movzbl (%ecx),%eax
  801b12:	84 c0                	test   %al,%al
  801b14:	74 04                	je     801b1a <strcmp+0x25>
  801b16:	3a 02                	cmp    (%edx),%al
  801b18:	74 ef                	je     801b09 <strcmp+0x14>
  801b1a:	0f b6 c0             	movzbl %al,%eax
  801b1d:	0f b6 12             	movzbl (%edx),%edx
  801b20:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	53                   	push   %ebx
  801b28:	8b 55 08             	mov    0x8(%ebp),%edx
  801b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801b31:	85 c0                	test   %eax,%eax
  801b33:	74 23                	je     801b58 <strncmp+0x34>
  801b35:	0f b6 1a             	movzbl (%edx),%ebx
  801b38:	84 db                	test   %bl,%bl
  801b3a:	74 25                	je     801b61 <strncmp+0x3d>
  801b3c:	3a 19                	cmp    (%ecx),%bl
  801b3e:	75 21                	jne    801b61 <strncmp+0x3d>
  801b40:	83 e8 01             	sub    $0x1,%eax
  801b43:	74 13                	je     801b58 <strncmp+0x34>
		n--, p++, q++;
  801b45:	83 c2 01             	add    $0x1,%edx
  801b48:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b4b:	0f b6 1a             	movzbl (%edx),%ebx
  801b4e:	84 db                	test   %bl,%bl
  801b50:	74 0f                	je     801b61 <strncmp+0x3d>
  801b52:	3a 19                	cmp    (%ecx),%bl
  801b54:	74 ea                	je     801b40 <strncmp+0x1c>
  801b56:	eb 09                	jmp    801b61 <strncmp+0x3d>
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b5d:	5b                   	pop    %ebx
  801b5e:	5d                   	pop    %ebp
  801b5f:	90                   	nop
  801b60:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b61:	0f b6 02             	movzbl (%edx),%eax
  801b64:	0f b6 11             	movzbl (%ecx),%edx
  801b67:	29 d0                	sub    %edx,%eax
  801b69:	eb f2                	jmp    801b5d <strncmp+0x39>

00801b6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b75:	0f b6 10             	movzbl (%eax),%edx
  801b78:	84 d2                	test   %dl,%dl
  801b7a:	74 18                	je     801b94 <strchr+0x29>
		if (*s == c)
  801b7c:	38 ca                	cmp    %cl,%dl
  801b7e:	75 0a                	jne    801b8a <strchr+0x1f>
  801b80:	eb 17                	jmp    801b99 <strchr+0x2e>
  801b82:	38 ca                	cmp    %cl,%dl
  801b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b88:	74 0f                	je     801b99 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b8a:	83 c0 01             	add    $0x1,%eax
  801b8d:	0f b6 10             	movzbl (%eax),%edx
  801b90:	84 d2                	test   %dl,%dl
  801b92:	75 ee                	jne    801b82 <strchr+0x17>
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ba5:	0f b6 10             	movzbl (%eax),%edx
  801ba8:	84 d2                	test   %dl,%dl
  801baa:	74 18                	je     801bc4 <strfind+0x29>
		if (*s == c)
  801bac:	38 ca                	cmp    %cl,%dl
  801bae:	75 0a                	jne    801bba <strfind+0x1f>
  801bb0:	eb 12                	jmp    801bc4 <strfind+0x29>
  801bb2:	38 ca                	cmp    %cl,%dl
  801bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bb8:	74 0a                	je     801bc4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801bba:	83 c0 01             	add    $0x1,%eax
  801bbd:	0f b6 10             	movzbl (%eax),%edx
  801bc0:	84 d2                	test   %dl,%dl
  801bc2:	75 ee                	jne    801bb2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    

00801bc6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	89 1c 24             	mov    %ebx,(%esp)
  801bcf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801bd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801be0:	85 c9                	test   %ecx,%ecx
  801be2:	74 30                	je     801c14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801be4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801bea:	75 25                	jne    801c11 <memset+0x4b>
  801bec:	f6 c1 03             	test   $0x3,%cl
  801bef:	75 20                	jne    801c11 <memset+0x4b>
		c &= 0xFF;
  801bf1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801bf4:	89 d3                	mov    %edx,%ebx
  801bf6:	c1 e3 08             	shl    $0x8,%ebx
  801bf9:	89 d6                	mov    %edx,%esi
  801bfb:	c1 e6 18             	shl    $0x18,%esi
  801bfe:	89 d0                	mov    %edx,%eax
  801c00:	c1 e0 10             	shl    $0x10,%eax
  801c03:	09 f0                	or     %esi,%eax
  801c05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801c07:	09 d8                	or     %ebx,%eax
  801c09:	c1 e9 02             	shr    $0x2,%ecx
  801c0c:	fc                   	cld    
  801c0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c0f:	eb 03                	jmp    801c14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c11:	fc                   	cld    
  801c12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c14:	89 f8                	mov    %edi,%eax
  801c16:	8b 1c 24             	mov    (%esp),%ebx
  801c19:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801c21:	89 ec                	mov    %ebp,%esp
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 08             	sub    $0x8,%esp
  801c2b:	89 34 24             	mov    %esi,(%esp)
  801c2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801c38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801c3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801c3d:	39 c6                	cmp    %eax,%esi
  801c3f:	73 35                	jae    801c76 <memmove+0x51>
  801c41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801c44:	39 d0                	cmp    %edx,%eax
  801c46:	73 2e                	jae    801c76 <memmove+0x51>
		s += n;
		d += n;
  801c48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c4a:	f6 c2 03             	test   $0x3,%dl
  801c4d:	75 1b                	jne    801c6a <memmove+0x45>
  801c4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c55:	75 13                	jne    801c6a <memmove+0x45>
  801c57:	f6 c1 03             	test   $0x3,%cl
  801c5a:	75 0e                	jne    801c6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801c5c:	83 ef 04             	sub    $0x4,%edi
  801c5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c62:	c1 e9 02             	shr    $0x2,%ecx
  801c65:	fd                   	std    
  801c66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c68:	eb 09                	jmp    801c73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c6a:	83 ef 01             	sub    $0x1,%edi
  801c6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c70:	fd                   	std    
  801c71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801c74:	eb 20                	jmp    801c96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c7c:	75 15                	jne    801c93 <memmove+0x6e>
  801c7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c84:	75 0d                	jne    801c93 <memmove+0x6e>
  801c86:	f6 c1 03             	test   $0x3,%cl
  801c89:	75 08                	jne    801c93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801c8b:	c1 e9 02             	shr    $0x2,%ecx
  801c8e:	fc                   	cld    
  801c8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c91:	eb 03                	jmp    801c96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c93:	fc                   	cld    
  801c94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c96:	8b 34 24             	mov    (%esp),%esi
  801c99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801c9d:	89 ec                	mov    %ebp,%esp
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801ca7:	8b 45 10             	mov    0x10(%ebp),%eax
  801caa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	89 04 24             	mov    %eax,(%esp)
  801cbb:	e8 65 ff ff ff       	call   801c25 <memmove>
}
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	57                   	push   %edi
  801cc6:	56                   	push   %esi
  801cc7:	53                   	push   %ebx
  801cc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801ccb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801cd1:	85 c9                	test   %ecx,%ecx
  801cd3:	74 36                	je     801d0b <memcmp+0x49>
		if (*s1 != *s2)
  801cd5:	0f b6 06             	movzbl (%esi),%eax
  801cd8:	0f b6 1f             	movzbl (%edi),%ebx
  801cdb:	38 d8                	cmp    %bl,%al
  801cdd:	74 20                	je     801cff <memcmp+0x3d>
  801cdf:	eb 14                	jmp    801cf5 <memcmp+0x33>
  801ce1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801ce6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801ceb:	83 c2 01             	add    $0x1,%edx
  801cee:	83 e9 01             	sub    $0x1,%ecx
  801cf1:	38 d8                	cmp    %bl,%al
  801cf3:	74 12                	je     801d07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801cf5:	0f b6 c0             	movzbl %al,%eax
  801cf8:	0f b6 db             	movzbl %bl,%ebx
  801cfb:	29 d8                	sub    %ebx,%eax
  801cfd:	eb 11                	jmp    801d10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801cff:	83 e9 01             	sub    $0x1,%ecx
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
  801d07:	85 c9                	test   %ecx,%ecx
  801d09:	75 d6                	jne    801ce1 <memcmp+0x1f>
  801d0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d1b:	89 c2                	mov    %eax,%edx
  801d1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801d20:	39 d0                	cmp    %edx,%eax
  801d22:	73 15                	jae    801d39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801d28:	38 08                	cmp    %cl,(%eax)
  801d2a:	75 06                	jne    801d32 <memfind+0x1d>
  801d2c:	eb 0b                	jmp    801d39 <memfind+0x24>
  801d2e:	38 08                	cmp    %cl,(%eax)
  801d30:	74 07                	je     801d39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d32:	83 c0 01             	add    $0x1,%eax
  801d35:	39 c2                	cmp    %eax,%edx
  801d37:	77 f5                	ja     801d2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    

00801d3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	57                   	push   %edi
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	83 ec 04             	sub    $0x4,%esp
  801d44:	8b 55 08             	mov    0x8(%ebp),%edx
  801d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d4a:	0f b6 02             	movzbl (%edx),%eax
  801d4d:	3c 20                	cmp    $0x20,%al
  801d4f:	74 04                	je     801d55 <strtol+0x1a>
  801d51:	3c 09                	cmp    $0x9,%al
  801d53:	75 0e                	jne    801d63 <strtol+0x28>
		s++;
  801d55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801d58:	0f b6 02             	movzbl (%edx),%eax
  801d5b:	3c 20                	cmp    $0x20,%al
  801d5d:	74 f6                	je     801d55 <strtol+0x1a>
  801d5f:	3c 09                	cmp    $0x9,%al
  801d61:	74 f2                	je     801d55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d63:	3c 2b                	cmp    $0x2b,%al
  801d65:	75 0c                	jne    801d73 <strtol+0x38>
		s++;
  801d67:	83 c2 01             	add    $0x1,%edx
  801d6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801d71:	eb 15                	jmp    801d88 <strtol+0x4d>
	else if (*s == '-')
  801d73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801d7a:	3c 2d                	cmp    $0x2d,%al
  801d7c:	75 0a                	jne    801d88 <strtol+0x4d>
		s++, neg = 1;
  801d7e:	83 c2 01             	add    $0x1,%edx
  801d81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801d88:	85 db                	test   %ebx,%ebx
  801d8a:	0f 94 c0             	sete   %al
  801d8d:	74 05                	je     801d94 <strtol+0x59>
  801d8f:	83 fb 10             	cmp    $0x10,%ebx
  801d92:	75 18                	jne    801dac <strtol+0x71>
  801d94:	80 3a 30             	cmpb   $0x30,(%edx)
  801d97:	75 13                	jne    801dac <strtol+0x71>
  801d99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi
  801da0:	75 0a                	jne    801dac <strtol+0x71>
		s += 2, base = 16;
  801da2:	83 c2 02             	add    $0x2,%edx
  801da5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801daa:	eb 15                	jmp    801dc1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801dac:	84 c0                	test   %al,%al
  801dae:	66 90                	xchg   %ax,%ax
  801db0:	74 0f                	je     801dc1 <strtol+0x86>
  801db2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801db7:	80 3a 30             	cmpb   $0x30,(%edx)
  801dba:	75 05                	jne    801dc1 <strtol+0x86>
		s++, base = 8;
  801dbc:	83 c2 01             	add    $0x1,%edx
  801dbf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801dc8:	0f b6 0a             	movzbl (%edx),%ecx
  801dcb:	89 cf                	mov    %ecx,%edi
  801dcd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801dd0:	80 fb 09             	cmp    $0x9,%bl
  801dd3:	77 08                	ja     801ddd <strtol+0xa2>
			dig = *s - '0';
  801dd5:	0f be c9             	movsbl %cl,%ecx
  801dd8:	83 e9 30             	sub    $0x30,%ecx
  801ddb:	eb 1e                	jmp    801dfb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801ddd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801de0:	80 fb 19             	cmp    $0x19,%bl
  801de3:	77 08                	ja     801ded <strtol+0xb2>
			dig = *s - 'a' + 10;
  801de5:	0f be c9             	movsbl %cl,%ecx
  801de8:	83 e9 57             	sub    $0x57,%ecx
  801deb:	eb 0e                	jmp    801dfb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801ded:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801df0:	80 fb 19             	cmp    $0x19,%bl
  801df3:	77 15                	ja     801e0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801df5:	0f be c9             	movsbl %cl,%ecx
  801df8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801dfb:	39 f1                	cmp    %esi,%ecx
  801dfd:	7d 0b                	jge    801e0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801dff:	83 c2 01             	add    $0x1,%edx
  801e02:	0f af c6             	imul   %esi,%eax
  801e05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801e08:	eb be                	jmp    801dc8 <strtol+0x8d>
  801e0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801e0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e10:	74 05                	je     801e17 <strtol+0xdc>
		*endptr = (char *) s;
  801e12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801e17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801e1b:	74 04                	je     801e21 <strtol+0xe6>
  801e1d:	89 c8                	mov    %ecx,%eax
  801e1f:	f7 d8                	neg    %eax
}
  801e21:	83 c4 04             	add    $0x4,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    
  801e29:	00 00                	add    %al,(%eax)
  801e2b:	00 00                	add    %al,(%eax)
  801e2d:	00 00                	add    %al,(%eax)
	...

00801e30 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e36:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801e3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e41:	39 ca                	cmp    %ecx,%edx
  801e43:	75 04                	jne    801e49 <ipc_find_env+0x19>
  801e45:	b0 00                	mov    $0x0,%al
  801e47:	eb 12                	jmp    801e5b <ipc_find_env+0x2b>
  801e49:	89 c2                	mov    %eax,%edx
  801e4b:	c1 e2 07             	shl    $0x7,%edx
  801e4e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801e55:	8b 12                	mov    (%edx),%edx
  801e57:	39 ca                	cmp    %ecx,%edx
  801e59:	75 10                	jne    801e6b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801e5b:	89 c2                	mov    %eax,%edx
  801e5d:	c1 e2 07             	shl    $0x7,%edx
  801e60:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801e67:	8b 00                	mov    (%eax),%eax
  801e69:	eb 0e                	jmp    801e79 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e6b:	83 c0 01             	add    $0x1,%eax
  801e6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e73:	75 d4                	jne    801e49 <ipc_find_env+0x19>
  801e75:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    

00801e7b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	57                   	push   %edi
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
  801e81:	83 ec 1c             	sub    $0x1c,%esp
  801e84:	8b 75 08             	mov    0x8(%ebp),%esi
  801e87:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801e8d:	85 db                	test   %ebx,%ebx
  801e8f:	74 19                	je     801eaa <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801e91:	8b 45 14             	mov    0x14(%ebp),%eax
  801e94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ea0:	89 34 24             	mov    %esi,(%esp)
  801ea3:	e8 e4 e4 ff ff       	call   80038c <sys_ipc_try_send>
  801ea8:	eb 1b                	jmp    801ec5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801eaa:	8b 45 14             	mov    0x14(%ebp),%eax
  801ead:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801eb8:	ee 
  801eb9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ebd:	89 34 24             	mov    %esi,(%esp)
  801ec0:	e8 c7 e4 ff ff       	call   80038c <sys_ipc_try_send>
           if(ret == 0)
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	74 28                	je     801ef1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801ec9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ecc:	74 1c                	je     801eea <ipc_send+0x6f>
              panic("ipc send error");
  801ece:	c7 44 24 08 40 26 80 	movl   $0x802640,0x8(%esp)
  801ed5:	00 
  801ed6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801edd:	00 
  801ede:	c7 04 24 4f 26 80 00 	movl   $0x80264f,(%esp)
  801ee5:	e8 6a f1 ff ff       	call   801054 <_panic>
           sys_yield();
  801eea:	e8 69 e7 ff ff       	call   800658 <sys_yield>
        }
  801eef:	eb 9c                	jmp    801e8d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801ef1:	83 c4 1c             	add    $0x1c,%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5f                   	pop    %edi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	83 ec 10             	sub    $0x10,%esp
  801f01:	8b 75 08             	mov    0x8(%ebp),%esi
  801f04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	75 0e                	jne    801f1c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801f0e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801f15:	e8 07 e4 ff ff       	call   800321 <sys_ipc_recv>
  801f1a:	eb 08                	jmp    801f24 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801f1c:	89 04 24             	mov    %eax,(%esp)
  801f1f:	e8 fd e3 ff ff       	call   800321 <sys_ipc_recv>
        if(ret == 0){
  801f24:	85 c0                	test   %eax,%eax
  801f26:	75 26                	jne    801f4e <ipc_recv+0x55>
           if(from_env_store)
  801f28:	85 f6                	test   %esi,%esi
  801f2a:	74 0a                	je     801f36 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801f2c:	a1 40 50 80 00       	mov    0x805040,%eax
  801f31:	8b 40 78             	mov    0x78(%eax),%eax
  801f34:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801f36:	85 db                	test   %ebx,%ebx
  801f38:	74 0a                	je     801f44 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801f3a:	a1 40 50 80 00       	mov    0x805040,%eax
  801f3f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f42:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801f44:	a1 40 50 80 00       	mov    0x805040,%eax
  801f49:	8b 40 74             	mov    0x74(%eax),%eax
  801f4c:	eb 14                	jmp    801f62 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801f4e:	85 f6                	test   %esi,%esi
  801f50:	74 06                	je     801f58 <ipc_recv+0x5f>
              *from_env_store = 0;
  801f52:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801f58:	85 db                	test   %ebx,%ebx
  801f5a:	74 06                	je     801f62 <ipc_recv+0x69>
              *perm_store = 0;
  801f5c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    
  801f69:	00 00                	add    %al,(%eax)
  801f6b:	00 00                	add    %al,(%eax)
  801f6d:	00 00                	add    %al,(%eax)
	...

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	57                   	push   %edi
  801f74:	56                   	push   %esi
  801f75:	83 ec 10             	sub    $0x10,%esp
  801f78:	8b 45 14             	mov    0x14(%ebp),%eax
  801f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  801f7e:	8b 75 10             	mov    0x10(%ebp),%esi
  801f81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f84:	85 c0                	test   %eax,%eax
  801f86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801f89:	75 35                	jne    801fc0 <__udivdi3+0x50>
  801f8b:	39 fe                	cmp    %edi,%esi
  801f8d:	77 61                	ja     801ff0 <__udivdi3+0x80>
  801f8f:	85 f6                	test   %esi,%esi
  801f91:	75 0b                	jne    801f9e <__udivdi3+0x2e>
  801f93:	b8 01 00 00 00       	mov    $0x1,%eax
  801f98:	31 d2                	xor    %edx,%edx
  801f9a:	f7 f6                	div    %esi
  801f9c:	89 c6                	mov    %eax,%esi
  801f9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801fa1:	31 d2                	xor    %edx,%edx
  801fa3:	89 f8                	mov    %edi,%eax
  801fa5:	f7 f6                	div    %esi
  801fa7:	89 c7                	mov    %eax,%edi
  801fa9:	89 c8                	mov    %ecx,%eax
  801fab:	f7 f6                	div    %esi
  801fad:	89 c1                	mov    %eax,%ecx
  801faf:	89 fa                	mov    %edi,%edx
  801fb1:	89 c8                	mov    %ecx,%eax
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	5e                   	pop    %esi
  801fb7:	5f                   	pop    %edi
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    
  801fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fc0:	39 f8                	cmp    %edi,%eax
  801fc2:	77 1c                	ja     801fe0 <__udivdi3+0x70>
  801fc4:	0f bd d0             	bsr    %eax,%edx
  801fc7:	83 f2 1f             	xor    $0x1f,%edx
  801fca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801fcd:	75 39                	jne    802008 <__udivdi3+0x98>
  801fcf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801fd2:	0f 86 a0 00 00 00    	jbe    802078 <__udivdi3+0x108>
  801fd8:	39 f8                	cmp    %edi,%eax
  801fda:	0f 82 98 00 00 00    	jb     802078 <__udivdi3+0x108>
  801fe0:	31 ff                	xor    %edi,%edi
  801fe2:	31 c9                	xor    %ecx,%ecx
  801fe4:	89 c8                	mov    %ecx,%eax
  801fe6:	89 fa                	mov    %edi,%edx
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	5e                   	pop    %esi
  801fec:	5f                   	pop    %edi
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    
  801fef:	90                   	nop
  801ff0:	89 d1                	mov    %edx,%ecx
  801ff2:	89 fa                	mov    %edi,%edx
  801ff4:	89 c8                	mov    %ecx,%eax
  801ff6:	31 ff                	xor    %edi,%edi
  801ff8:	f7 f6                	div    %esi
  801ffa:	89 c1                	mov    %eax,%ecx
  801ffc:	89 fa                	mov    %edi,%edx
  801ffe:	89 c8                	mov    %ecx,%eax
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	5e                   	pop    %esi
  802004:	5f                   	pop    %edi
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    
  802007:	90                   	nop
  802008:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80200c:	89 f2                	mov    %esi,%edx
  80200e:	d3 e0                	shl    %cl,%eax
  802010:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802013:	b8 20 00 00 00       	mov    $0x20,%eax
  802018:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80201b:	89 c1                	mov    %eax,%ecx
  80201d:	d3 ea                	shr    %cl,%edx
  80201f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802023:	0b 55 ec             	or     -0x14(%ebp),%edx
  802026:	d3 e6                	shl    %cl,%esi
  802028:	89 c1                	mov    %eax,%ecx
  80202a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80202d:	89 fe                	mov    %edi,%esi
  80202f:	d3 ee                	shr    %cl,%esi
  802031:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802035:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802038:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80203b:	d3 e7                	shl    %cl,%edi
  80203d:	89 c1                	mov    %eax,%ecx
  80203f:	d3 ea                	shr    %cl,%edx
  802041:	09 d7                	or     %edx,%edi
  802043:	89 f2                	mov    %esi,%edx
  802045:	89 f8                	mov    %edi,%eax
  802047:	f7 75 ec             	divl   -0x14(%ebp)
  80204a:	89 d6                	mov    %edx,%esi
  80204c:	89 c7                	mov    %eax,%edi
  80204e:	f7 65 e8             	mull   -0x18(%ebp)
  802051:	39 d6                	cmp    %edx,%esi
  802053:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802056:	72 30                	jb     802088 <__udivdi3+0x118>
  802058:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80205b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80205f:	d3 e2                	shl    %cl,%edx
  802061:	39 c2                	cmp    %eax,%edx
  802063:	73 05                	jae    80206a <__udivdi3+0xfa>
  802065:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802068:	74 1e                	je     802088 <__udivdi3+0x118>
  80206a:	89 f9                	mov    %edi,%ecx
  80206c:	31 ff                	xor    %edi,%edi
  80206e:	e9 71 ff ff ff       	jmp    801fe4 <__udivdi3+0x74>
  802073:	90                   	nop
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	31 ff                	xor    %edi,%edi
  80207a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80207f:	e9 60 ff ff ff       	jmp    801fe4 <__udivdi3+0x74>
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80208b:	31 ff                	xor    %edi,%edi
  80208d:	89 c8                	mov    %ecx,%eax
  80208f:	89 fa                	mov    %edi,%edx
  802091:	83 c4 10             	add    $0x10,%esp
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
	...

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	57                   	push   %edi
  8020a4:	56                   	push   %esi
  8020a5:	83 ec 20             	sub    $0x20,%esp
  8020a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8020ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8020b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b4:	85 d2                	test   %edx,%edx
  8020b6:	89 c8                	mov    %ecx,%eax
  8020b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020bb:	75 13                	jne    8020d0 <__umoddi3+0x30>
  8020bd:	39 f7                	cmp    %esi,%edi
  8020bf:	76 3f                	jbe    802100 <__umoddi3+0x60>
  8020c1:	89 f2                	mov    %esi,%edx
  8020c3:	f7 f7                	div    %edi
  8020c5:	89 d0                	mov    %edx,%eax
  8020c7:	31 d2                	xor    %edx,%edx
  8020c9:	83 c4 20             	add    $0x20,%esp
  8020cc:	5e                   	pop    %esi
  8020cd:	5f                   	pop    %edi
  8020ce:	5d                   	pop    %ebp
  8020cf:	c3                   	ret    
  8020d0:	39 f2                	cmp    %esi,%edx
  8020d2:	77 4c                	ja     802120 <__umoddi3+0x80>
  8020d4:	0f bd ca             	bsr    %edx,%ecx
  8020d7:	83 f1 1f             	xor    $0x1f,%ecx
  8020da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020dd:	75 51                	jne    802130 <__umoddi3+0x90>
  8020df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8020e2:	0f 87 e0 00 00 00    	ja     8021c8 <__umoddi3+0x128>
  8020e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020eb:	29 f8                	sub    %edi,%eax
  8020ed:	19 d6                	sbb    %edx,%esi
  8020ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8020f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f5:	89 f2                	mov    %esi,%edx
  8020f7:	83 c4 20             	add    $0x20,%esp
  8020fa:	5e                   	pop    %esi
  8020fb:	5f                   	pop    %edi
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    
  8020fe:	66 90                	xchg   %ax,%ax
  802100:	85 ff                	test   %edi,%edi
  802102:	75 0b                	jne    80210f <__umoddi3+0x6f>
  802104:	b8 01 00 00 00       	mov    $0x1,%eax
  802109:	31 d2                	xor    %edx,%edx
  80210b:	f7 f7                	div    %edi
  80210d:	89 c7                	mov    %eax,%edi
  80210f:	89 f0                	mov    %esi,%eax
  802111:	31 d2                	xor    %edx,%edx
  802113:	f7 f7                	div    %edi
  802115:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802118:	f7 f7                	div    %edi
  80211a:	eb a9                	jmp    8020c5 <__umoddi3+0x25>
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	83 c4 20             	add    $0x20,%esp
  802127:	5e                   	pop    %esi
  802128:	5f                   	pop    %edi
  802129:	5d                   	pop    %ebp
  80212a:	c3                   	ret    
  80212b:	90                   	nop
  80212c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802130:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802134:	d3 e2                	shl    %cl,%edx
  802136:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802139:	ba 20 00 00 00       	mov    $0x20,%edx
  80213e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802141:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802144:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802148:	89 fa                	mov    %edi,%edx
  80214a:	d3 ea                	shr    %cl,%edx
  80214c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802150:	0b 55 f4             	or     -0xc(%ebp),%edx
  802153:	d3 e7                	shl    %cl,%edi
  802155:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802159:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80215c:	89 f2                	mov    %esi,%edx
  80215e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802161:	89 c7                	mov    %eax,%edi
  802163:	d3 ea                	shr    %cl,%edx
  802165:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802169:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80216c:	89 c2                	mov    %eax,%edx
  80216e:	d3 e6                	shl    %cl,%esi
  802170:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802174:	d3 ea                	shr    %cl,%edx
  802176:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80217a:	09 d6                	or     %edx,%esi
  80217c:	89 f0                	mov    %esi,%eax
  80217e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802181:	d3 e7                	shl    %cl,%edi
  802183:	89 f2                	mov    %esi,%edx
  802185:	f7 75 f4             	divl   -0xc(%ebp)
  802188:	89 d6                	mov    %edx,%esi
  80218a:	f7 65 e8             	mull   -0x18(%ebp)
  80218d:	39 d6                	cmp    %edx,%esi
  80218f:	72 2b                	jb     8021bc <__umoddi3+0x11c>
  802191:	39 c7                	cmp    %eax,%edi
  802193:	72 23                	jb     8021b8 <__umoddi3+0x118>
  802195:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802199:	29 c7                	sub    %eax,%edi
  80219b:	19 d6                	sbb    %edx,%esi
  80219d:	89 f0                	mov    %esi,%eax
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	d3 ef                	shr    %cl,%edi
  8021a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8021a7:	d3 e0                	shl    %cl,%eax
  8021a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021ad:	09 f8                	or     %edi,%eax
  8021af:	d3 ea                	shr    %cl,%edx
  8021b1:	83 c4 20             	add    $0x20,%esp
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	39 d6                	cmp    %edx,%esi
  8021ba:	75 d9                	jne    802195 <__umoddi3+0xf5>
  8021bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8021bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8021c2:	eb d1                	jmp    802195 <__umoddi3+0xf5>
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	0f 82 18 ff ff ff    	jb     8020e8 <__umoddi3+0x48>
  8021d0:	e9 1d ff ff ff       	jmp    8020f2 <__umoddi3+0x52>
