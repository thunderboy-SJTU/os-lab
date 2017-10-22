
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
  8000bd:	e8 db 06 00 00       	call   80079d <sys_map_kernel_page>
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
  800156:	e8 84 06 00 00       	call   8007df <sys_getenvid>
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
  80019e:	e8 c8 0b 00 00       	call   800d6b <close_all>
	sys_env_destroy(0);
  8001a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001aa:	e8 70 06 00 00       	call   80081f <sys_env_destroy>
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

00800233 <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
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
  800240:	b9 00 00 00 00       	mov    $0x0,%ecx
  800245:	b8 13 00 00 00       	mov    $0x13,%eax
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	89 cb                	mov    %ecx,%ebx
  80024f:	89 cf                	mov    %ecx,%edi
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
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800269:	8b 1c 24             	mov    (%esp),%ebx
  80026c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800270:	89 ec                	mov    %ebp,%esp
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	89 1c 24             	mov    %ebx,(%esp)
  80027d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800281:	bb 00 00 00 00       	mov    $0x0,%ebx
  800286:	b8 12 00 00 00       	mov    $0x12,%eax
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	8b 55 08             	mov    0x8(%ebp),%edx
  800291:	89 df                	mov    %ebx,%edi
  800293:	51                   	push   %ecx
  800294:	52                   	push   %edx
  800295:	53                   	push   %ebx
  800296:	54                   	push   %esp
  800297:	55                   	push   %ebp
  800298:	56                   	push   %esi
  800299:	57                   	push   %edi
  80029a:	54                   	push   %esp
  80029b:	5d                   	pop    %ebp
  80029c:	8d 35 a4 02 80 00    	lea    0x8002a4,%esi
  8002a2:	0f 34                	sysenter 
  8002a4:	5f                   	pop    %edi
  8002a5:	5e                   	pop    %esi
  8002a6:	5d                   	pop    %ebp
  8002a7:	5c                   	pop    %esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5a                   	pop    %edx
  8002aa:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8002ab:	8b 1c 24             	mov    (%esp),%ebx
  8002ae:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b2:	89 ec                	mov    %ebp,%esp
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	89 1c 24             	mov    %ebx,(%esp)
  8002bf:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c8:	b8 11 00 00 00       	mov    $0x11,%eax
  8002cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d3:	89 df                	mov    %ebx,%edi
  8002d5:	51                   	push   %ecx
  8002d6:	52                   	push   %edx
  8002d7:	53                   	push   %ebx
  8002d8:	54                   	push   %esp
  8002d9:	55                   	push   %ebp
  8002da:	56                   	push   %esi
  8002db:	57                   	push   %edi
  8002dc:	54                   	push   %esp
  8002dd:	5d                   	pop    %ebp
  8002de:	8d 35 e6 02 80 00    	lea    0x8002e6,%esi
  8002e4:	0f 34                	sysenter 
  8002e6:	5f                   	pop    %edi
  8002e7:	5e                   	pop    %esi
  8002e8:	5d                   	pop    %ebp
  8002e9:	5c                   	pop    %esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5a                   	pop    %edx
  8002ec:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8002ed:	8b 1c 24             	mov    (%esp),%ebx
  8002f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f4:	89 ec                	mov    %ebp,%esp
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	89 1c 24             	mov    %ebx,(%esp)
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800305:	b8 10 00 00 00       	mov    $0x10,%eax
  80030a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	51                   	push   %ecx
  800317:	52                   	push   %edx
  800318:	53                   	push   %ebx
  800319:	54                   	push   %esp
  80031a:	55                   	push   %ebp
  80031b:	56                   	push   %esi
  80031c:	57                   	push   %edi
  80031d:	54                   	push   %esp
  80031e:	5d                   	pop    %ebp
  80031f:	8d 35 27 03 80 00    	lea    0x800327,%esi
  800325:	0f 34                	sysenter 
  800327:	5f                   	pop    %edi
  800328:	5e                   	pop    %esi
  800329:	5d                   	pop    %ebp
  80032a:	5c                   	pop    %esp
  80032b:	5b                   	pop    %ebx
  80032c:	5a                   	pop    %edx
  80032d:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  80032e:	8b 1c 24             	mov    (%esp),%ebx
  800331:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800335:	89 ec                	mov    %ebp,%esp
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 28             	sub    $0x28,%esp
  80033f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800342:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800345:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80034f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800352:	8b 55 08             	mov    0x8(%ebp),%edx
  800355:	89 df                	mov    %ebx,%edi
  800357:	51                   	push   %ecx
  800358:	52                   	push   %edx
  800359:	53                   	push   %ebx
  80035a:	54                   	push   %esp
  80035b:	55                   	push   %ebp
  80035c:	56                   	push   %esi
  80035d:	57                   	push   %edi
  80035e:	54                   	push   %esp
  80035f:	5d                   	pop    %ebp
  800360:	8d 35 68 03 80 00    	lea    0x800368,%esi
  800366:	0f 34                	sysenter 
  800368:	5f                   	pop    %edi
  800369:	5e                   	pop    %esi
  80036a:	5d                   	pop    %ebp
  80036b:	5c                   	pop    %esp
  80036c:	5b                   	pop    %ebx
  80036d:	5a                   	pop    %edx
  80036e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80036f:	85 c0                	test   %eax,%eax
  800371:	7e 28                	jle    80039b <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800373:	89 44 24 10          	mov    %eax,0x10(%esp)
  800377:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80037e:	00 
  80037f:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  800386:	00 
  800387:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80038e:	00 
  80038f:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  800396:	e8 c9 12 00 00       	call   801664 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80039b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80039e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a1:	89 ec                	mov    %ebp,%esp
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	89 1c 24             	mov    %ebx,(%esp)
  8003ae:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b7:	b8 15 00 00 00       	mov    $0x15,%eax
  8003bc:	89 d1                	mov    %edx,%ecx
  8003be:	89 d3                	mov    %edx,%ebx
  8003c0:	89 d7                	mov    %edx,%edi
  8003c2:	51                   	push   %ecx
  8003c3:	52                   	push   %edx
  8003c4:	53                   	push   %ebx
  8003c5:	54                   	push   %esp
  8003c6:	55                   	push   %ebp
  8003c7:	56                   	push   %esi
  8003c8:	57                   	push   %edi
  8003c9:	54                   	push   %esp
  8003ca:	5d                   	pop    %ebp
  8003cb:	8d 35 d3 03 80 00    	lea    0x8003d3,%esi
  8003d1:	0f 34                	sysenter 
  8003d3:	5f                   	pop    %edi
  8003d4:	5e                   	pop    %esi
  8003d5:	5d                   	pop    %ebp
  8003d6:	5c                   	pop    %esp
  8003d7:	5b                   	pop    %ebx
  8003d8:	5a                   	pop    %edx
  8003d9:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003da:	8b 1c 24             	mov    (%esp),%ebx
  8003dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003e1:	89 ec                	mov    %ebp,%esp
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	89 1c 24             	mov    %ebx,(%esp)
  8003ee:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	b8 14 00 00 00       	mov    $0x14,%eax
  8003fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ff:	89 cb                	mov    %ecx,%ebx
  800401:	89 cf                	mov    %ecx,%edi
  800403:	51                   	push   %ecx
  800404:	52                   	push   %edx
  800405:	53                   	push   %ebx
  800406:	54                   	push   %esp
  800407:	55                   	push   %ebp
  800408:	56                   	push   %esi
  800409:	57                   	push   %edi
  80040a:	54                   	push   %esp
  80040b:	5d                   	pop    %ebp
  80040c:	8d 35 14 04 80 00    	lea    0x800414,%esi
  800412:	0f 34                	sysenter 
  800414:	5f                   	pop    %edi
  800415:	5e                   	pop    %esi
  800416:	5d                   	pop    %ebp
  800417:	5c                   	pop    %esp
  800418:	5b                   	pop    %ebx
  800419:	5a                   	pop    %edx
  80041a:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80041b:	8b 1c 24             	mov    (%esp),%ebx
  80041e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800422:	89 ec                	mov    %ebp,%esp
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 28             	sub    $0x28,%esp
  80042c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80042f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800432:	b9 00 00 00 00       	mov    $0x0,%ecx
  800437:	b8 0e 00 00 00       	mov    $0xe,%eax
  80043c:	8b 55 08             	mov    0x8(%ebp),%edx
  80043f:	89 cb                	mov    %ecx,%ebx
  800441:	89 cf                	mov    %ecx,%edi
  800443:	51                   	push   %ecx
  800444:	52                   	push   %edx
  800445:	53                   	push   %ebx
  800446:	54                   	push   %esp
  800447:	55                   	push   %ebp
  800448:	56                   	push   %esi
  800449:	57                   	push   %edi
  80044a:	54                   	push   %esp
  80044b:	5d                   	pop    %ebp
  80044c:	8d 35 54 04 80 00    	lea    0x800454,%esi
  800452:	0f 34                	sysenter 
  800454:	5f                   	pop    %edi
  800455:	5e                   	pop    %esi
  800456:	5d                   	pop    %ebp
  800457:	5c                   	pop    %esp
  800458:	5b                   	pop    %ebx
  800459:	5a                   	pop    %edx
  80045a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80045b:	85 c0                	test   %eax,%eax
  80045d:	7e 28                	jle    800487 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80045f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800463:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80046a:	00 
  80046b:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  800472:	00 
  800473:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80047a:	00 
  80047b:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  800482:	e8 dd 11 00 00       	call   801664 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800487:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80048a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80048d:	89 ec                	mov    %ebp,%esp
  80048f:	5d                   	pop    %ebp
  800490:	c3                   	ret    

00800491 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	89 1c 24             	mov    %ebx,(%esp)
  80049a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80049e:	b8 0d 00 00 00       	mov    $0xd,%eax
  8004a3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8004a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8004af:	51                   	push   %ecx
  8004b0:	52                   	push   %edx
  8004b1:	53                   	push   %ebx
  8004b2:	54                   	push   %esp
  8004b3:	55                   	push   %ebp
  8004b4:	56                   	push   %esi
  8004b5:	57                   	push   %edi
  8004b6:	54                   	push   %esp
  8004b7:	5d                   	pop    %ebp
  8004b8:	8d 35 c0 04 80 00    	lea    0x8004c0,%esi
  8004be:	0f 34                	sysenter 
  8004c0:	5f                   	pop    %edi
  8004c1:	5e                   	pop    %esi
  8004c2:	5d                   	pop    %ebp
  8004c3:	5c                   	pop    %esp
  8004c4:	5b                   	pop    %ebx
  8004c5:	5a                   	pop    %edx
  8004c6:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8004c7:	8b 1c 24             	mov    (%esp),%ebx
  8004ca:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004ce:	89 ec                	mov    %ebp,%esp
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 28             	sub    $0x28,%esp
  8004d8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004db:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004e3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8004e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ee:	89 df                	mov    %ebx,%edi
  8004f0:	51                   	push   %ecx
  8004f1:	52                   	push   %edx
  8004f2:	53                   	push   %ebx
  8004f3:	54                   	push   %esp
  8004f4:	55                   	push   %ebp
  8004f5:	56                   	push   %esi
  8004f6:	57                   	push   %edi
  8004f7:	54                   	push   %esp
  8004f8:	5d                   	pop    %ebp
  8004f9:	8d 35 01 05 80 00    	lea    0x800501,%esi
  8004ff:	0f 34                	sysenter 
  800501:	5f                   	pop    %edi
  800502:	5e                   	pop    %esi
  800503:	5d                   	pop    %ebp
  800504:	5c                   	pop    %esp
  800505:	5b                   	pop    %ebx
  800506:	5a                   	pop    %edx
  800507:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800508:	85 c0                	test   %eax,%eax
  80050a:	7e 28                	jle    800534 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80050c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800510:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  800517:	00 
  800518:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  80051f:	00 
  800520:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800527:	00 
  800528:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  80052f:	e8 30 11 00 00       	call   801664 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800534:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800537:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80053a:	89 ec                	mov    %ebp,%esp
  80053c:	5d                   	pop    %ebp
  80053d:	c3                   	ret    

0080053e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	83 ec 28             	sub    $0x28,%esp
  800544:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800547:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80054a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80054f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800554:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800557:	8b 55 08             	mov    0x8(%ebp),%edx
  80055a:	89 df                	mov    %ebx,%edi
  80055c:	51                   	push   %ecx
  80055d:	52                   	push   %edx
  80055e:	53                   	push   %ebx
  80055f:	54                   	push   %esp
  800560:	55                   	push   %ebp
  800561:	56                   	push   %esi
  800562:	57                   	push   %edi
  800563:	54                   	push   %esp
  800564:	5d                   	pop    %ebp
  800565:	8d 35 6d 05 80 00    	lea    0x80056d,%esi
  80056b:	0f 34                	sysenter 
  80056d:	5f                   	pop    %edi
  80056e:	5e                   	pop    %esi
  80056f:	5d                   	pop    %ebp
  800570:	5c                   	pop    %esp
  800571:	5b                   	pop    %ebx
  800572:	5a                   	pop    %edx
  800573:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800574:	85 c0                	test   %eax,%eax
  800576:	7e 28                	jle    8005a0 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800578:	89 44 24 10          	mov    %eax,0x10(%esp)
  80057c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800583:	00 
  800584:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  80059b:	e8 c4 10 00 00       	call   801664 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8005a0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005a3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005a6:	89 ec                	mov    %ebp,%esp
  8005a8:	5d                   	pop    %ebp
  8005a9:	c3                   	ret    

008005aa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
  8005ad:	83 ec 28             	sub    $0x28,%esp
  8005b0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005b3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005bb:	b8 09 00 00 00       	mov    $0x9,%eax
  8005c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c6:	89 df                	mov    %ebx,%edi
  8005c8:	51                   	push   %ecx
  8005c9:	52                   	push   %edx
  8005ca:	53                   	push   %ebx
  8005cb:	54                   	push   %esp
  8005cc:	55                   	push   %ebp
  8005cd:	56                   	push   %esi
  8005ce:	57                   	push   %edi
  8005cf:	54                   	push   %esp
  8005d0:	5d                   	pop    %ebp
  8005d1:	8d 35 d9 05 80 00    	lea    0x8005d9,%esi
  8005d7:	0f 34                	sysenter 
  8005d9:	5f                   	pop    %edi
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	5c                   	pop    %esp
  8005dd:	5b                   	pop    %ebx
  8005de:	5a                   	pop    %edx
  8005df:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	7e 28                	jle    80060c <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005e8:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8005ef:	00 
  8005f0:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  8005f7:	00 
  8005f8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8005ff:	00 
  800600:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  800607:	e8 58 10 00 00       	call   801664 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80060c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80060f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800612:	89 ec                	mov    %ebp,%esp
  800614:	5d                   	pop    %ebp
  800615:	c3                   	ret    

00800616 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800616:	55                   	push   %ebp
  800617:	89 e5                	mov    %esp,%ebp
  800619:	83 ec 28             	sub    $0x28,%esp
  80061c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80061f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800622:	bb 00 00 00 00       	mov    $0x0,%ebx
  800627:	b8 07 00 00 00       	mov    $0x7,%eax
  80062c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80062f:	8b 55 08             	mov    0x8(%ebp),%edx
  800632:	89 df                	mov    %ebx,%edi
  800634:	51                   	push   %ecx
  800635:	52                   	push   %edx
  800636:	53                   	push   %ebx
  800637:	54                   	push   %esp
  800638:	55                   	push   %ebp
  800639:	56                   	push   %esi
  80063a:	57                   	push   %edi
  80063b:	54                   	push   %esp
  80063c:	5d                   	pop    %ebp
  80063d:	8d 35 45 06 80 00    	lea    0x800645,%esi
  800643:	0f 34                	sysenter 
  800645:	5f                   	pop    %edi
  800646:	5e                   	pop    %esi
  800647:	5d                   	pop    %ebp
  800648:	5c                   	pop    %esp
  800649:	5b                   	pop    %ebx
  80064a:	5a                   	pop    %edx
  80064b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80064c:	85 c0                	test   %eax,%eax
  80064e:	7e 28                	jle    800678 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800650:	89 44 24 10          	mov    %eax,0x10(%esp)
  800654:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80065b:	00 
  80065c:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  800663:	00 
  800664:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80066b:	00 
  80066c:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  800673:	e8 ec 0f 00 00       	call   801664 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800678:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80067b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80067e:	89 ec                	mov    %ebp,%esp
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 28             	sub    $0x28,%esp
  800688:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80068b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80068e:	8b 7d 18             	mov    0x18(%ebp),%edi
  800691:	0b 7d 14             	or     0x14(%ebp),%edi
  800694:	b8 06 00 00 00       	mov    $0x6,%eax
  800699:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80069c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069f:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a2:	51                   	push   %ecx
  8006a3:	52                   	push   %edx
  8006a4:	53                   	push   %ebx
  8006a5:	54                   	push   %esp
  8006a6:	55                   	push   %ebp
  8006a7:	56                   	push   %esi
  8006a8:	57                   	push   %edi
  8006a9:	54                   	push   %esp
  8006aa:	5d                   	pop    %ebp
  8006ab:	8d 35 b3 06 80 00    	lea    0x8006b3,%esi
  8006b1:	0f 34                	sysenter 
  8006b3:	5f                   	pop    %edi
  8006b4:	5e                   	pop    %esi
  8006b5:	5d                   	pop    %ebp
  8006b6:	5c                   	pop    %esp
  8006b7:	5b                   	pop    %ebx
  8006b8:	5a                   	pop    %edx
  8006b9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8006ba:	85 c0                	test   %eax,%eax
  8006bc:	7e 28                	jle    8006e6 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006c2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8006c9:	00 
  8006ca:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  8006d1:	00 
  8006d2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8006d9:	00 
  8006da:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  8006e1:	e8 7e 0f 00 00       	call   801664 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8006e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8006e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006ec:	89 ec                	mov    %ebp,%esp
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	83 ec 28             	sub    $0x28,%esp
  8006f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8006f9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006fc:	bf 00 00 00 00       	mov    $0x0,%edi
  800701:	b8 05 00 00 00       	mov    $0x5,%eax
  800706:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070c:	8b 55 08             	mov    0x8(%ebp),%edx
  80070f:	51                   	push   %ecx
  800710:	52                   	push   %edx
  800711:	53                   	push   %ebx
  800712:	54                   	push   %esp
  800713:	55                   	push   %ebp
  800714:	56                   	push   %esi
  800715:	57                   	push   %edi
  800716:	54                   	push   %esp
  800717:	5d                   	pop    %ebp
  800718:	8d 35 20 07 80 00    	lea    0x800720,%esi
  80071e:	0f 34                	sysenter 
  800720:	5f                   	pop    %edi
  800721:	5e                   	pop    %esi
  800722:	5d                   	pop    %ebp
  800723:	5c                   	pop    %esp
  800724:	5b                   	pop    %ebx
  800725:	5a                   	pop    %edx
  800726:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800727:	85 c0                	test   %eax,%eax
  800729:	7e 28                	jle    800753 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80072b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80072f:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800736:	00 
  800737:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  80073e:	00 
  80073f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800746:	00 
  800747:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  80074e:	e8 11 0f 00 00       	call   801664 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800753:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800756:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800759:	89 ec                	mov    %ebp,%esp
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	89 1c 24             	mov    %ebx,(%esp)
  800766:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80076a:	ba 00 00 00 00       	mov    $0x0,%edx
  80076f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800774:	89 d1                	mov    %edx,%ecx
  800776:	89 d3                	mov    %edx,%ebx
  800778:	89 d7                	mov    %edx,%edi
  80077a:	51                   	push   %ecx
  80077b:	52                   	push   %edx
  80077c:	53                   	push   %ebx
  80077d:	54                   	push   %esp
  80077e:	55                   	push   %ebp
  80077f:	56                   	push   %esi
  800780:	57                   	push   %edi
  800781:	54                   	push   %esp
  800782:	5d                   	pop    %ebp
  800783:	8d 35 8b 07 80 00    	lea    0x80078b,%esi
  800789:	0f 34                	sysenter 
  80078b:	5f                   	pop    %edi
  80078c:	5e                   	pop    %esi
  80078d:	5d                   	pop    %ebp
  80078e:	5c                   	pop    %esp
  80078f:	5b                   	pop    %ebx
  800790:	5a                   	pop    %edx
  800791:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800792:	8b 1c 24             	mov    (%esp),%ebx
  800795:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800799:	89 ec                	mov    %ebp,%esp
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	89 1c 24             	mov    %ebx,(%esp)
  8007a6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8007aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007af:	b8 04 00 00 00       	mov    $0x4,%eax
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ba:	89 df                	mov    %ebx,%edi
  8007bc:	51                   	push   %ecx
  8007bd:	52                   	push   %edx
  8007be:	53                   	push   %ebx
  8007bf:	54                   	push   %esp
  8007c0:	55                   	push   %ebp
  8007c1:	56                   	push   %esi
  8007c2:	57                   	push   %edi
  8007c3:	54                   	push   %esp
  8007c4:	5d                   	pop    %ebp
  8007c5:	8d 35 cd 07 80 00    	lea    0x8007cd,%esi
  8007cb:	0f 34                	sysenter 
  8007cd:	5f                   	pop    %edi
  8007ce:	5e                   	pop    %esi
  8007cf:	5d                   	pop    %ebp
  8007d0:	5c                   	pop    %esp
  8007d1:	5b                   	pop    %ebx
  8007d2:	5a                   	pop    %edx
  8007d3:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8007d4:	8b 1c 24             	mov    (%esp),%ebx
  8007d7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007db:	89 ec                	mov    %ebp,%esp
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	89 1c 24             	mov    %ebx,(%esp)
  8007e8:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8007ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f1:	b8 02 00 00 00       	mov    $0x2,%eax
  8007f6:	89 d1                	mov    %edx,%ecx
  8007f8:	89 d3                	mov    %edx,%ebx
  8007fa:	89 d7                	mov    %edx,%edi
  8007fc:	51                   	push   %ecx
  8007fd:	52                   	push   %edx
  8007fe:	53                   	push   %ebx
  8007ff:	54                   	push   %esp
  800800:	55                   	push   %ebp
  800801:	56                   	push   %esi
  800802:	57                   	push   %edi
  800803:	54                   	push   %esp
  800804:	5d                   	pop    %ebp
  800805:	8d 35 0d 08 80 00    	lea    0x80080d,%esi
  80080b:	0f 34                	sysenter 
  80080d:	5f                   	pop    %edi
  80080e:	5e                   	pop    %esi
  80080f:	5d                   	pop    %ebp
  800810:	5c                   	pop    %esp
  800811:	5b                   	pop    %ebx
  800812:	5a                   	pop    %edx
  800813:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800814:	8b 1c 24             	mov    (%esp),%ebx
  800817:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80081b:	89 ec                	mov    %ebp,%esp
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 28             	sub    $0x28,%esp
  800825:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800828:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80082b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800830:	b8 03 00 00 00       	mov    $0x3,%eax
  800835:	8b 55 08             	mov    0x8(%ebp),%edx
  800838:	89 cb                	mov    %ecx,%ebx
  80083a:	89 cf                	mov    %ecx,%edi
  80083c:	51                   	push   %ecx
  80083d:	52                   	push   %edx
  80083e:	53                   	push   %ebx
  80083f:	54                   	push   %esp
  800840:	55                   	push   %ebp
  800841:	56                   	push   %esi
  800842:	57                   	push   %edi
  800843:	54                   	push   %esp
  800844:	5d                   	pop    %ebp
  800845:	8d 35 4d 08 80 00    	lea    0x80084d,%esi
  80084b:	0f 34                	sysenter 
  80084d:	5f                   	pop    %edi
  80084e:	5e                   	pop    %esi
  80084f:	5d                   	pop    %ebp
  800850:	5c                   	pop    %esp
  800851:	5b                   	pop    %ebx
  800852:	5a                   	pop    %edx
  800853:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800854:	85 c0                	test   %eax,%eax
  800856:	7e 28                	jle    800880 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800858:	89 44 24 10          	mov    %eax,0x10(%esp)
  80085c:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800863:	00 
  800864:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  80086b:	00 
  80086c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800873:	00 
  800874:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  80087b:	e8 e4 0d 00 00       	call   801664 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800880:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800883:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800886:	89 ec                	mov    %ebp,%esp
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    
  80088a:	00 00                	add    %al,(%eax)
  80088c:	00 00                	add    %al,(%eax)
	...

00800890 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	05 00 00 00 30       	add    $0x30000000,%eax
  80089b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	89 04 24             	mov    %eax,(%esp)
  8008ac:	e8 df ff ff ff       	call   800890 <fd2num>
  8008b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8008b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	57                   	push   %edi
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8008c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8008c9:	a8 01                	test   $0x1,%al
  8008cb:	74 36                	je     800903 <fd_alloc+0x48>
  8008cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8008d2:	a8 01                	test   $0x1,%al
  8008d4:	74 2d                	je     800903 <fd_alloc+0x48>
  8008d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8008db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8008e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8008e5:	89 c3                	mov    %eax,%ebx
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	c1 ea 16             	shr    $0x16,%edx
  8008ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8008ef:	f6 c2 01             	test   $0x1,%dl
  8008f2:	74 14                	je     800908 <fd_alloc+0x4d>
  8008f4:	89 c2                	mov    %eax,%edx
  8008f6:	c1 ea 0c             	shr    $0xc,%edx
  8008f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8008fc:	f6 c2 01             	test   $0x1,%dl
  8008ff:	75 10                	jne    800911 <fd_alloc+0x56>
  800901:	eb 05                	jmp    800908 <fd_alloc+0x4d>
  800903:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800908:	89 1f                	mov    %ebx,(%edi)
  80090a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80090f:	eb 17                	jmp    800928 <fd_alloc+0x6d>
  800911:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800916:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80091b:	75 c8                	jne    8008e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80091d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800923:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	83 f8 1f             	cmp    $0x1f,%eax
  800936:	77 36                	ja     80096e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800938:	05 00 00 0d 00       	add    $0xd0000,%eax
  80093d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800940:	89 c2                	mov    %eax,%edx
  800942:	c1 ea 16             	shr    $0x16,%edx
  800945:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80094c:	f6 c2 01             	test   $0x1,%dl
  80094f:	74 1d                	je     80096e <fd_lookup+0x41>
  800951:	89 c2                	mov    %eax,%edx
  800953:	c1 ea 0c             	shr    $0xc,%edx
  800956:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80095d:	f6 c2 01             	test   $0x1,%dl
  800960:	74 0c                	je     80096e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
  800965:	89 02                	mov    %eax,(%edx)
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80096c:	eb 05                	jmp    800973 <fd_lookup+0x46>
  80096e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80097b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80097e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 a0 ff ff ff       	call   80092d <fd_lookup>
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 0e                	js     80099f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800991:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	89 50 04             	mov    %edx,0x4(%eax)
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	83 ec 10             	sub    $0x10,%esp
  8009a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8009af:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009b9:	be f4 28 80 00       	mov    $0x8028f4,%esi
		if (devtab[i]->dev_id == dev_id) {
  8009be:	39 08                	cmp    %ecx,(%eax)
  8009c0:	75 10                	jne    8009d2 <dev_lookup+0x31>
  8009c2:	eb 04                	jmp    8009c8 <dev_lookup+0x27>
  8009c4:	39 08                	cmp    %ecx,(%eax)
  8009c6:	75 0a                	jne    8009d2 <dev_lookup+0x31>
			*dev = devtab[i];
  8009c8:	89 03                	mov    %eax,(%ebx)
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8009cf:	90                   	nop
  8009d0:	eb 31                	jmp    800a03 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009d2:	83 c2 01             	add    $0x1,%edx
  8009d5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8009d8:	85 c0                	test   %eax,%eax
  8009da:	75 e8                	jne    8009c4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009dc:	a1 40 50 80 00       	mov    0x805040,%eax
  8009e1:	8b 40 48             	mov    0x48(%eax),%eax
  8009e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ec:	c7 04 24 78 28 80 00 	movl   $0x802878,(%esp)
  8009f3:	e8 25 0d 00 00       	call   80171d <cprintf>
	*dev = 0;
  8009f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8009fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800a03:	83 c4 10             	add    $0x10,%esp
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	83 ec 24             	sub    $0x24,%esp
  800a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	89 04 24             	mov    %eax,(%esp)
  800a21:	e8 07 ff ff ff       	call   80092d <fd_lookup>
  800a26:	85 c0                	test   %eax,%eax
  800a28:	78 53                	js     800a7d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a34:	8b 00                	mov    (%eax),%eax
  800a36:	89 04 24             	mov    %eax,(%esp)
  800a39:	e8 63 ff ff ff       	call   8009a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	78 3b                	js     800a7d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800a42:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a4a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  800a4e:	74 2d                	je     800a7d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800a50:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a53:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800a5a:	00 00 00 
	stat->st_isdir = 0;
  800a5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a64:	00 00 00 
	stat->st_dev = dev;
  800a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a6a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800a70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a77:	89 14 24             	mov    %edx,(%esp)
  800a7a:	ff 50 14             	call   *0x14(%eax)
}
  800a7d:	83 c4 24             	add    $0x24,%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	53                   	push   %ebx
  800a87:	83 ec 24             	sub    $0x24,%esp
  800a8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a94:	89 1c 24             	mov    %ebx,(%esp)
  800a97:	e8 91 fe ff ff       	call   80092d <fd_lookup>
  800a9c:	85 c0                	test   %eax,%eax
  800a9e:	78 5f                	js     800aff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aaa:	8b 00                	mov    (%eax),%eax
  800aac:	89 04 24             	mov    %eax,(%esp)
  800aaf:	e8 ed fe ff ff       	call   8009a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	78 47                	js     800aff <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ab8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800abb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800abf:	75 23                	jne    800ae4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800ac1:	a1 40 50 80 00       	mov    0x805040,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800ac6:	8b 40 48             	mov    0x48(%eax),%eax
  800ac9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad1:	c7 04 24 98 28 80 00 	movl   $0x802898,(%esp)
  800ad8:	e8 40 0c 00 00       	call   80171d <cprintf>
  800add:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800ae2:	eb 1b                	jmp    800aff <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae7:	8b 48 18             	mov    0x18(%eax),%ecx
  800aea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800aef:	85 c9                	test   %ecx,%ecx
  800af1:	74 0c                	je     800aff <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afa:	89 14 24             	mov    %edx,(%esp)
  800afd:	ff d1                	call   *%ecx
}
  800aff:	83 c4 24             	add    $0x24,%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	53                   	push   %ebx
  800b09:	83 ec 24             	sub    $0x24,%esp
  800b0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b16:	89 1c 24             	mov    %ebx,(%esp)
  800b19:	e8 0f fe ff ff       	call   80092d <fd_lookup>
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	78 66                	js     800b88 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b2c:	8b 00                	mov    (%eax),%eax
  800b2e:	89 04 24             	mov    %eax,(%esp)
  800b31:	e8 6b fe ff ff       	call   8009a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b36:	85 c0                	test   %eax,%eax
  800b38:	78 4e                	js     800b88 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b3d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800b41:	75 23                	jne    800b66 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b43:	a1 40 50 80 00       	mov    0x805040,%eax
  800b48:	8b 40 48             	mov    0x48(%eax),%eax
  800b4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b53:	c7 04 24 b9 28 80 00 	movl   $0x8028b9,(%esp)
  800b5a:	e8 be 0b 00 00       	call   80171d <cprintf>
  800b5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800b64:	eb 22                	jmp    800b88 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b69:	8b 48 0c             	mov    0xc(%eax),%ecx
  800b6c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b71:	85 c9                	test   %ecx,%ecx
  800b73:	74 13                	je     800b88 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b75:	8b 45 10             	mov    0x10(%ebp),%eax
  800b78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b83:	89 14 24             	mov    %edx,(%esp)
  800b86:	ff d1                	call   *%ecx
}
  800b88:	83 c4 24             	add    $0x24,%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	53                   	push   %ebx
  800b92:	83 ec 24             	sub    $0x24,%esp
  800b95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9f:	89 1c 24             	mov    %ebx,(%esp)
  800ba2:	e8 86 fd ff ff       	call   80092d <fd_lookup>
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	78 6b                	js     800c16 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb5:	8b 00                	mov    (%eax),%eax
  800bb7:	89 04 24             	mov    %eax,(%esp)
  800bba:	e8 e2 fd ff ff       	call   8009a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	78 53                	js     800c16 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800bc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bc6:	8b 42 08             	mov    0x8(%edx),%eax
  800bc9:	83 e0 03             	and    $0x3,%eax
  800bcc:	83 f8 01             	cmp    $0x1,%eax
  800bcf:	75 23                	jne    800bf4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bd1:	a1 40 50 80 00       	mov    0x805040,%eax
  800bd6:	8b 40 48             	mov    0x48(%eax),%eax
  800bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be1:	c7 04 24 d6 28 80 00 	movl   $0x8028d6,(%esp)
  800be8:	e8 30 0b 00 00       	call   80171d <cprintf>
  800bed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800bf2:	eb 22                	jmp    800c16 <read+0x88>
	}
	if (!dev->dev_read)
  800bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf7:	8b 48 08             	mov    0x8(%eax),%ecx
  800bfa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800bff:	85 c9                	test   %ecx,%ecx
  800c01:	74 13                	je     800c16 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800c03:	8b 45 10             	mov    0x10(%ebp),%eax
  800c06:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c11:	89 14 24             	mov    %edx,(%esp)
  800c14:	ff d1                	call   *%ecx
}
  800c16:	83 c4 24             	add    $0x24,%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 1c             	sub    $0x1c,%esp
  800c25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c28:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3a:	85 f6                	test   %esi,%esi
  800c3c:	74 29                	je     800c67 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c3e:	89 f0                	mov    %esi,%eax
  800c40:	29 d0                	sub    %edx,%eax
  800c42:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c46:	03 55 0c             	add    0xc(%ebp),%edx
  800c49:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c4d:	89 3c 24             	mov    %edi,(%esp)
  800c50:	e8 39 ff ff ff       	call   800b8e <read>
		if (m < 0)
  800c55:	85 c0                	test   %eax,%eax
  800c57:	78 0e                	js     800c67 <readn+0x4b>
			return m;
		if (m == 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	74 08                	je     800c65 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c5d:	01 c3                	add    %eax,%ebx
  800c5f:	89 da                	mov    %ebx,%edx
  800c61:	39 f3                	cmp    %esi,%ebx
  800c63:	72 d9                	jb     800c3e <readn+0x22>
  800c65:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c67:	83 c4 1c             	add    $0x1c,%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 20             	sub    $0x20,%esp
  800c77:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800c7a:	89 34 24             	mov    %esi,(%esp)
  800c7d:	e8 0e fc ff ff       	call   800890 <fd2num>
  800c82:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c85:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c89:	89 04 24             	mov    %eax,(%esp)
  800c8c:	e8 9c fc ff ff       	call   80092d <fd_lookup>
  800c91:	89 c3                	mov    %eax,%ebx
  800c93:	85 c0                	test   %eax,%eax
  800c95:	78 05                	js     800c9c <fd_close+0x2d>
  800c97:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800c9a:	74 0c                	je     800ca8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800c9c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800ca0:	19 c0                	sbb    %eax,%eax
  800ca2:	f7 d0                	not    %eax
  800ca4:	21 c3                	and    %eax,%ebx
  800ca6:	eb 3d                	jmp    800ce5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ca8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800caf:	8b 06                	mov    (%esi),%eax
  800cb1:	89 04 24             	mov    %eax,(%esp)
  800cb4:	e8 e8 fc ff ff       	call   8009a1 <dev_lookup>
  800cb9:	89 c3                	mov    %eax,%ebx
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	78 16                	js     800cd5 <fd_close+0x66>
		if (dev->dev_close)
  800cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc2:	8b 40 10             	mov    0x10(%eax),%eax
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	74 07                	je     800cd5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800cce:	89 34 24             	mov    %esi,(%esp)
  800cd1:	ff d0                	call   *%eax
  800cd3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800cd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ce0:	e8 31 f9 ff ff       	call   800616 <sys_page_unmap>
	return r;
}
  800ce5:	89 d8                	mov    %ebx,%eax
  800ce7:	83 c4 20             	add    $0x20,%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800cf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	89 04 24             	mov    %eax,(%esp)
  800d01:	e8 27 fc ff ff       	call   80092d <fd_lookup>
  800d06:	85 c0                	test   %eax,%eax
  800d08:	78 13                	js     800d1d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800d0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800d11:	00 
  800d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d15:	89 04 24             	mov    %eax,(%esp)
  800d18:	e8 52 ff ff ff       	call   800c6f <fd_close>
}
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    

00800d1f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 18             	sub    $0x18,%esp
  800d25:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d28:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d32:	00 
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	89 04 24             	mov    %eax,(%esp)
  800d39:	e8 79 03 00 00       	call   8010b7 <open>
  800d3e:	89 c3                	mov    %eax,%ebx
  800d40:	85 c0                	test   %eax,%eax
  800d42:	78 1b                	js     800d5f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800d44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4b:	89 1c 24             	mov    %ebx,(%esp)
  800d4e:	e8 b7 fc ff ff       	call   800a0a <fstat>
  800d53:	89 c6                	mov    %eax,%esi
	close(fd);
  800d55:	89 1c 24             	mov    %ebx,(%esp)
  800d58:	e8 91 ff ff ff       	call   800cee <close>
  800d5d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800d5f:	89 d8                	mov    %ebx,%eax
  800d61:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d64:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d67:	89 ec                	mov    %ebp,%esp
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 14             	sub    $0x14,%esp
  800d72:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800d77:	89 1c 24             	mov    %ebx,(%esp)
  800d7a:	e8 6f ff ff ff       	call   800cee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800d7f:	83 c3 01             	add    $0x1,%ebx
  800d82:	83 fb 20             	cmp    $0x20,%ebx
  800d85:	75 f0                	jne    800d77 <close_all+0xc>
		close(i);
}
  800d87:	83 c4 14             	add    $0x14,%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 58             	sub    $0x58,%esp
  800d93:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d96:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d99:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800d9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800da2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	89 04 24             	mov    %eax,(%esp)
  800dac:	e8 7c fb ff ff       	call   80092d <fd_lookup>
  800db1:	89 c3                	mov    %eax,%ebx
  800db3:	85 c0                	test   %eax,%eax
  800db5:	0f 88 e0 00 00 00    	js     800e9b <dup+0x10e>
		return r;
	close(newfdnum);
  800dbb:	89 3c 24             	mov    %edi,(%esp)
  800dbe:	e8 2b ff ff ff       	call   800cee <close>

	newfd = INDEX2FD(newfdnum);
  800dc3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800dc9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dcf:	89 04 24             	mov    %eax,(%esp)
  800dd2:	e8 c9 fa ff ff       	call   8008a0 <fd2data>
  800dd7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800dd9:	89 34 24             	mov    %esi,(%esp)
  800ddc:	e8 bf fa ff ff       	call   8008a0 <fd2data>
  800de1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800de4:	89 da                	mov    %ebx,%edx
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	c1 e8 16             	shr    $0x16,%eax
  800deb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800df2:	a8 01                	test   $0x1,%al
  800df4:	74 43                	je     800e39 <dup+0xac>
  800df6:	c1 ea 0c             	shr    $0xc,%edx
  800df9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e00:	a8 01                	test   $0x1,%al
  800e02:	74 35                	je     800e39 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800e04:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e0b:	25 07 0e 00 00       	and    $0xe07,%eax
  800e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800e17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e22:	00 
  800e23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e2e:	e8 4f f8 ff ff       	call   800682 <sys_page_map>
  800e33:	89 c3                	mov    %eax,%ebx
  800e35:	85 c0                	test   %eax,%eax
  800e37:	78 3f                	js     800e78 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	c1 ea 0c             	shr    $0xc,%edx
  800e41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e48:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800e4e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e52:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e5d:	00 
  800e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e69:	e8 14 f8 ff ff       	call   800682 <sys_page_map>
  800e6e:	89 c3                	mov    %eax,%ebx
  800e70:	85 c0                	test   %eax,%eax
  800e72:	78 04                	js     800e78 <dup+0xeb>
  800e74:	89 fb                	mov    %edi,%ebx
  800e76:	eb 23                	jmp    800e9b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800e78:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e83:	e8 8e f7 ff ff       	call   800616 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800e88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e96:	e8 7b f7 ff ff       	call   800616 <sys_page_unmap>
	return r;
}
  800e9b:	89 d8                	mov    %ebx,%eax
  800e9d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea6:	89 ec                	mov    %ebp,%esp
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    
	...

00800eac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 18             	sub    $0x18,%esp
  800eb2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800eb5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800eb8:	89 c3                	mov    %eax,%ebx
  800eba:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800ebc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ec3:	75 11                	jne    800ed6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ec5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ecc:	e8 6f 15 00 00       	call   802440 <ipc_find_env>
  800ed1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ed6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800edd:	00 
  800ede:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800ee5:	00 
  800ee6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eea:	a1 00 40 80 00       	mov    0x804000,%eax
  800eef:	89 04 24             	mov    %eax,(%esp)
  800ef2:	e8 94 15 00 00       	call   80248b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ef7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800efe:	00 
  800eff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0a:	e8 fa 15 00 00       	call   802509 <ipc_recv>
}
  800f0f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f12:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800f15:	89 ec                	mov    %ebp,%esp
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	8b 40 0c             	mov    0xc(%eax),%eax
  800f25:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  800f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f32:	ba 00 00 00 00       	mov    $0x0,%edx
  800f37:	b8 02 00 00 00       	mov    $0x2,%eax
  800f3c:	e8 6b ff ff ff       	call   800eac <fsipc>
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	8b 40 0c             	mov    0xc(%eax),%eax
  800f4f:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  800f54:	ba 00 00 00 00       	mov    $0x0,%edx
  800f59:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5e:	e8 49 ff ff ff       	call   800eac <fsipc>
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f70:	b8 08 00 00 00       	mov    $0x8,%eax
  800f75:	e8 32 ff ff ff       	call   800eac <fsipc>
}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    

00800f7c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 14             	sub    $0x14,%esp
  800f83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f86:	8b 45 08             	mov    0x8(%ebp),%eax
  800f89:	8b 40 0c             	mov    0xc(%eax),%eax
  800f8c:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f91:	ba 00 00 00 00       	mov    $0x0,%edx
  800f96:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9b:	e8 0c ff ff ff       	call   800eac <fsipc>
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 2b                	js     800fcf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800fa4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800fab:	00 
  800fac:	89 1c 24             	mov    %ebx,(%esp)
  800faf:	e8 96 10 00 00       	call   80204a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800fb4:	a1 80 60 80 00       	mov    0x806080,%eax
  800fb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fbf:	a1 84 60 80 00       	mov    0x806084,%eax
  800fc4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800fcf:	83 c4 14             	add    $0x14,%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 18             	sub    $0x18,%esp
  800fdb:	8b 45 10             	mov    0x10(%ebp),%eax
  800fde:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800fe3:	76 05                	jbe    800fea <devfile_write+0x15>
  800fe5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800fea:	8b 55 08             	mov    0x8(%ebp),%edx
  800fed:	8b 52 0c             	mov    0xc(%edx),%edx
  800ff0:	89 15 00 60 80 00    	mov    %edx,0x806000
        fsipcbuf.write.req_n = n;
  800ff6:	a3 04 60 80 00       	mov    %eax,0x806004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800ffb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801002:	89 44 24 04          	mov    %eax,0x4(%esp)
  801006:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80100d:	e8 23 12 00 00       	call   802235 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  801012:	ba 00 00 00 00       	mov    $0x0,%edx
  801017:	b8 04 00 00 00       	mov    $0x4,%eax
  80101c:	e8 8b fe ff ff       	call   800eac <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	53                   	push   %ebx
  801027:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	8b 40 0c             	mov    0xc(%eax),%eax
  801030:	a3 00 60 80 00       	mov    %eax,0x806000
        fsipcbuf.read.req_n = n;
  801035:	8b 45 10             	mov    0x10(%ebp),%eax
  801038:	a3 04 60 80 00       	mov    %eax,0x806004
        r = fsipc(FSREQ_READ,NULL);
  80103d:	ba 00 00 00 00       	mov    $0x0,%edx
  801042:	b8 03 00 00 00       	mov    $0x3,%eax
  801047:	e8 60 fe ff ff       	call   800eac <fsipc>
  80104c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 17                	js     801069 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  801052:	89 44 24 08          	mov    %eax,0x8(%esp)
  801056:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80105d:	00 
  80105e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801061:	89 04 24             	mov    %eax,(%esp)
  801064:	e8 cc 11 00 00       	call   802235 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  801069:	89 d8                	mov    %ebx,%eax
  80106b:	83 c4 14             	add    $0x14,%esp
  80106e:	5b                   	pop    %ebx
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	53                   	push   %ebx
  801075:	83 ec 14             	sub    $0x14,%esp
  801078:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80107b:	89 1c 24             	mov    %ebx,(%esp)
  80107e:	e8 7d 0f 00 00       	call   802000 <strlen>
  801083:	89 c2                	mov    %eax,%edx
  801085:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  80108a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801090:	7f 1f                	jg     8010b1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801096:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80109d:	e8 a8 0f 00 00       	call   80204a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8010a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a7:	b8 07 00 00 00       	mov    $0x7,%eax
  8010ac:	e8 fb fd ff ff       	call   800eac <fsipc>
}
  8010b1:	83 c4 14             	add    $0x14,%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 28             	sub    $0x28,%esp
  8010bd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010c0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8010c3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  8010c6:	89 34 24             	mov    %esi,(%esp)
  8010c9:	e8 32 0f 00 00       	call   802000 <strlen>
  8010ce:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8010d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010d8:	7f 6d                	jg     801147 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  8010da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dd:	89 04 24             	mov    %eax,(%esp)
  8010e0:	e8 d6 f7 ff ff       	call   8008bb <fd_alloc>
  8010e5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 5c                	js     801147 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  8010eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ee:	a3 00 64 80 00       	mov    %eax,0x806400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  8010f3:	89 34 24             	mov    %esi,(%esp)
  8010f6:	e8 05 0f 00 00       	call   802000 <strlen>
  8010fb:	83 c0 01             	add    $0x1,%eax
  8010fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801102:	89 74 24 04          	mov    %esi,0x4(%esp)
  801106:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80110d:	e8 23 11 00 00       	call   802235 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801112:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801115:	b8 01 00 00 00       	mov    $0x1,%eax
  80111a:	e8 8d fd ff ff       	call   800eac <fsipc>
  80111f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801121:	85 c0                	test   %eax,%eax
  801123:	79 15                	jns    80113a <open+0x83>
             fd_close(fd,0);
  801125:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80112c:	00 
  80112d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801130:	89 04 24             	mov    %eax,(%esp)
  801133:	e8 37 fb ff ff       	call   800c6f <fd_close>
             return r;
  801138:	eb 0d                	jmp    801147 <open+0x90>
        }
        return fd2num(fd);
  80113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113d:	89 04 24             	mov    %eax,(%esp)
  801140:	e8 4b f7 ff ff       	call   800890 <fd2num>
  801145:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801147:	89 d8                	mov    %ebx,%eax
  801149:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80114c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80114f:	89 ec                	mov    %ebp,%esp
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    
	...

00801160 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801166:	c7 44 24 04 00 29 80 	movl   $0x802900,0x4(%esp)
  80116d:	00 
  80116e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801171:	89 04 24             	mov    %eax,(%esp)
  801174:	e8 d1 0e 00 00       	call   80204a <strcpy>
	return 0;
}
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80118a:	89 1c 24             	mov    %ebx,(%esp)
  80118d:	e8 ea 13 00 00       	call   80257c <pageref>
  801192:	89 c2                	mov    %eax,%edx
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
  801199:	83 fa 01             	cmp    $0x1,%edx
  80119c:	75 0b                	jne    8011a9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80119e:	8b 43 0c             	mov    0xc(%ebx),%eax
  8011a1:	89 04 24             	mov    %eax,(%esp)
  8011a4:	e8 b9 02 00 00       	call   801462 <nsipc_close>
	else
		return 0;
}
  8011a9:	83 c4 14             	add    $0x14,%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8011b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011bc:	00 
  8011bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8011d1:	89 04 24             	mov    %eax,(%esp)
  8011d4:	e8 c5 02 00 00       	call   80149e <nsipc_send>
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8011e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011e8:	00 
  8011e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8011fd:	89 04 24             	mov    %eax,(%esp)
  801200:	e8 0c 03 00 00       	call   801511 <nsipc_recv>
}
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 20             	sub    $0x20,%esp
  80120f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	89 04 24             	mov    %eax,(%esp)
  801217:	e8 9f f6 ff ff       	call   8008bb <fd_alloc>
  80121c:	89 c3                	mov    %eax,%ebx
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 21                	js     801243 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801222:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801229:	00 
  80122a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801231:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801238:	e8 b3 f4 ff ff       	call   8006f0 <sys_page_alloc>
  80123d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80123f:	85 c0                	test   %eax,%eax
  801241:	79 0a                	jns    80124d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801243:	89 34 24             	mov    %esi,(%esp)
  801246:	e8 17 02 00 00       	call   801462 <nsipc_close>
		return r;
  80124b:	eb 28                	jmp    801275 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80124d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801253:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801256:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801262:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801265:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801268:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 1d f6 ff ff       	call   800890 <fd2num>
  801273:	89 c3                	mov    %eax,%ebx
}
  801275:	89 d8                	mov    %ebx,%eax
  801277:	83 c4 20             	add    $0x20,%esp
  80127a:	5b                   	pop    %ebx
  80127b:	5e                   	pop    %esi
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801284:	8b 45 10             	mov    0x10(%ebp),%eax
  801287:	89 44 24 08          	mov    %eax,0x8(%esp)
  80128b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	89 04 24             	mov    %eax,(%esp)
  801298:	e8 79 01 00 00       	call   801416 <nsipc_socket>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 05                	js     8012a6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8012a1:	e8 61 ff ff ff       	call   801207 <alloc_sockfd>
}
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8012ae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012b5:	89 04 24             	mov    %eax,(%esp)
  8012b8:	e8 70 f6 ff ff       	call   80092d <fd_lookup>
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 15                	js     8012d6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8012c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c4:	8b 0a                	mov    (%edx),%ecx
  8012c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012cb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  8012d1:	75 03                	jne    8012d6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8012d3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012de:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e1:	e8 c2 ff ff ff       	call   8012a8 <fd2sockid>
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 0f                	js     8012f9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8012ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012f1:	89 04 24             	mov    %eax,(%esp)
  8012f4:	e8 47 01 00 00       	call   801440 <nsipc_listen>
}
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801301:	8b 45 08             	mov    0x8(%ebp),%eax
  801304:	e8 9f ff ff ff       	call   8012a8 <fd2sockid>
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 16                	js     801323 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80130d:	8b 55 10             	mov    0x10(%ebp),%edx
  801310:	89 54 24 08          	mov    %edx,0x8(%esp)
  801314:	8b 55 0c             	mov    0xc(%ebp),%edx
  801317:	89 54 24 04          	mov    %edx,0x4(%esp)
  80131b:	89 04 24             	mov    %eax,(%esp)
  80131e:	e8 6e 02 00 00       	call   801591 <nsipc_connect>
}
  801323:	c9                   	leave  
  801324:	c3                   	ret    

00801325 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80132b:	8b 45 08             	mov    0x8(%ebp),%eax
  80132e:	e8 75 ff ff ff       	call   8012a8 <fd2sockid>
  801333:	85 c0                	test   %eax,%eax
  801335:	78 0f                	js     801346 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801337:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	e8 36 01 00 00       	call   80147c <nsipc_shutdown>
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80134e:	8b 45 08             	mov    0x8(%ebp),%eax
  801351:	e8 52 ff ff ff       	call   8012a8 <fd2sockid>
  801356:	85 c0                	test   %eax,%eax
  801358:	78 16                	js     801370 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80135a:	8b 55 10             	mov    0x10(%ebp),%edx
  80135d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801361:	8b 55 0c             	mov    0xc(%ebp),%edx
  801364:	89 54 24 04          	mov    %edx,0x4(%esp)
  801368:	89 04 24             	mov    %eax,(%esp)
  80136b:	e8 60 02 00 00       	call   8015d0 <nsipc_bind>
}
  801370:	c9                   	leave  
  801371:	c3                   	ret    

00801372 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	e8 28 ff ff ff       	call   8012a8 <fd2sockid>
  801380:	85 c0                	test   %eax,%eax
  801382:	78 1f                	js     8013a3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801384:	8b 55 10             	mov    0x10(%ebp),%edx
  801387:	89 54 24 08          	mov    %edx,0x8(%esp)
  80138b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801392:	89 04 24             	mov    %eax,(%esp)
  801395:	e8 75 02 00 00       	call   80160f <nsipc_accept>
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 05                	js     8013a3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80139e:	e8 64 fe ff ff       	call   801207 <alloc_sockfd>
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    
	...

008013b0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 14             	sub    $0x14,%esp
  8013b7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8013b9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8013c0:	75 11                	jne    8013d3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8013c2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8013c9:	e8 72 10 00 00       	call   802440 <ipc_find_env>
  8013ce:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8013d3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013da:	00 
  8013db:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8013e2:	00 
  8013e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ec:	89 04 24             	mov    %eax,(%esp)
  8013ef:	e8 97 10 00 00       	call   80248b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8013f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013fb:	00 
  8013fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801403:	00 
  801404:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140b:	e8 f9 10 00 00       	call   802509 <ipc_recv>
}
  801410:	83 c4 14             	add    $0x14,%esp
  801413:	5b                   	pop    %ebx
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    

00801416 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801424:	8b 45 0c             	mov    0xc(%ebp),%eax
  801427:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80142c:	8b 45 10             	mov    0x10(%ebp),%eax
  80142f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801434:	b8 09 00 00 00       	mov    $0x9,%eax
  801439:	e8 72 ff ff ff       	call   8013b0 <nsipc>
}
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801446:	8b 45 08             	mov    0x8(%ebp),%eax
  801449:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80144e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801451:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801456:	b8 06 00 00 00       	mov    $0x6,%eax
  80145b:	e8 50 ff ff ff       	call   8013b0 <nsipc>
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801468:	8b 45 08             	mov    0x8(%ebp),%eax
  80146b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801470:	b8 04 00 00 00       	mov    $0x4,%eax
  801475:	e8 36 ff ff ff       	call   8013b0 <nsipc>
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80148a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801492:	b8 03 00 00 00       	mov    $0x3,%eax
  801497:	e8 14 ff ff ff       	call   8013b0 <nsipc>
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 14             	sub    $0x14,%esp
  8014a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8014b0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8014b6:	7e 24                	jle    8014dc <nsipc_send+0x3e>
  8014b8:	c7 44 24 0c 0c 29 80 	movl   $0x80290c,0xc(%esp)
  8014bf:	00 
  8014c0:	c7 44 24 08 18 29 80 	movl   $0x802918,0x8(%esp)
  8014c7:	00 
  8014c8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8014cf:	00 
  8014d0:	c7 04 24 2d 29 80 00 	movl   $0x80292d,(%esp)
  8014d7:	e8 88 01 00 00       	call   801664 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8014dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8014ee:	e8 42 0d 00 00       	call   802235 <memmove>
	nsipcbuf.send.req_size = size;
  8014f3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8014f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801501:	b8 08 00 00 00       	mov    $0x8,%eax
  801506:	e8 a5 fe ff ff       	call   8013b0 <nsipc>
}
  80150b:	83 c4 14             	add    $0x14,%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
  801516:	83 ec 10             	sub    $0x10,%esp
  801519:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80151c:	8b 45 08             	mov    0x8(%ebp),%eax
  80151f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801524:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80152a:	8b 45 14             	mov    0x14(%ebp),%eax
  80152d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801532:	b8 07 00 00 00       	mov    $0x7,%eax
  801537:	e8 74 fe ff ff       	call   8013b0 <nsipc>
  80153c:	89 c3                	mov    %eax,%ebx
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 46                	js     801588 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801542:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801547:	7f 04                	jg     80154d <nsipc_recv+0x3c>
  801549:	39 c6                	cmp    %eax,%esi
  80154b:	7d 24                	jge    801571 <nsipc_recv+0x60>
  80154d:	c7 44 24 0c 39 29 80 	movl   $0x802939,0xc(%esp)
  801554:	00 
  801555:	c7 44 24 08 18 29 80 	movl   $0x802918,0x8(%esp)
  80155c:	00 
  80155d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801564:	00 
  801565:	c7 04 24 2d 29 80 00 	movl   $0x80292d,(%esp)
  80156c:	e8 f3 00 00 00       	call   801664 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801571:	89 44 24 08          	mov    %eax,0x8(%esp)
  801575:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80157c:	00 
  80157d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801580:	89 04 24             	mov    %eax,(%esp)
  801583:	e8 ad 0c 00 00       	call   802235 <memmove>
	}

	return r;
}
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    

00801591 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	53                   	push   %ebx
  801595:	83 ec 14             	sub    $0x14,%esp
  801598:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80159b:	8b 45 08             	mov    0x8(%ebp),%eax
  80159e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8015a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ae:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8015b5:	e8 7b 0c 00 00       	call   802235 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8015ba:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8015c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c5:	e8 e6 fd ff ff       	call   8013b0 <nsipc>
}
  8015ca:	83 c4 14             	add    $0x14,%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 14             	sub    $0x14,%esp
  8015d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8015da:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8015e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ed:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8015f4:	e8 3c 0c 00 00       	call   802235 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8015f9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8015ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801604:	e8 a7 fd ff ff       	call   8013b0 <nsipc>
}
  801609:	83 c4 14             	add    $0x14,%esp
  80160c:	5b                   	pop    %ebx
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    

0080160f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 18             	sub    $0x18,%esp
  801615:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801618:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80161b:	8b 45 08             	mov    0x8(%ebp),%eax
  80161e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801623:	b8 01 00 00 00       	mov    $0x1,%eax
  801628:	e8 83 fd ff ff       	call   8013b0 <nsipc>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 25                	js     801658 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801633:	be 10 70 80 00       	mov    $0x807010,%esi
  801638:	8b 06                	mov    (%esi),%eax
  80163a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80163e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801645:	00 
  801646:	8b 45 0c             	mov    0xc(%ebp),%eax
  801649:	89 04 24             	mov    %eax,(%esp)
  80164c:	e8 e4 0b 00 00       	call   802235 <memmove>
		*addrlen = ret->ret_addrlen;
  801651:	8b 16                	mov    (%esi),%edx
  801653:	8b 45 10             	mov    0x10(%ebp),%eax
  801656:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801658:	89 d8                	mov    %ebx,%eax
  80165a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80165d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801660:	89 ec                	mov    %ebp,%esp
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	56                   	push   %esi
  801668:	53                   	push   %ebx
  801669:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80166c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80166f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801675:	e8 65 f1 ff ff       	call   8007df <sys_getenvid>
  80167a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801681:	8b 55 08             	mov    0x8(%ebp),%edx
  801684:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801688:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80168c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801690:	c7 04 24 50 29 80 00 	movl   $0x802950,(%esp)
  801697:	e8 81 00 00 00       	call   80171d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80169c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 11 00 00 00       	call   8016bc <vcprintf>
	cprintf("\n");
  8016ab:	c7 04 24 f0 28 80 00 	movl   $0x8028f0,(%esp)
  8016b2:	e8 66 00 00 00       	call   80171d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8016b7:	cc                   	int3   
  8016b8:	eb fd                	jmp    8016b7 <_panic+0x53>
	...

008016bc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8016c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016cc:	00 00 00 
	b.cnt = 0;
  8016cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f1:	c7 04 24 37 17 80 00 	movl   $0x801737,(%esp)
  8016f8:	e8 cf 01 00 00       	call   8018cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8016fd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801703:	89 44 24 04          	mov    %eax,0x4(%esp)
  801707:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80170d:	89 04 24             	mov    %eax,(%esp)
  801710:	e8 df ea ff ff       	call   8001f4 <sys_cputs>

	return b.cnt;
}
  801715:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801723:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	89 04 24             	mov    %eax,(%esp)
  801730:	e8 87 ff ff ff       	call   8016bc <vcprintf>
	va_end(ap);

	return cnt;
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 14             	sub    $0x14,%esp
  80173e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801741:	8b 03                	mov    (%ebx),%eax
  801743:	8b 55 08             	mov    0x8(%ebp),%edx
  801746:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80174a:	83 c0 01             	add    $0x1,%eax
  80174d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80174f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801754:	75 19                	jne    80176f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801756:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80175d:	00 
  80175e:	8d 43 08             	lea    0x8(%ebx),%eax
  801761:	89 04 24             	mov    %eax,(%esp)
  801764:	e8 8b ea ff ff       	call   8001f4 <sys_cputs>
		b->idx = 0;
  801769:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80176f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801773:	83 c4 14             	add    $0x14,%esp
  801776:	5b                   	pop    %ebx
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    
  801779:	00 00                	add    %al,(%eax)
  80177b:	00 00                	add    %al,(%eax)
  80177d:	00 00                	add    %al,(%eax)
	...

00801780 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	57                   	push   %edi
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 4c             	sub    $0x4c,%esp
  801789:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80178c:	89 d6                	mov    %edx,%esi
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801794:	8b 55 0c             	mov    0xc(%ebp),%edx
  801797:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80179a:	8b 45 10             	mov    0x10(%ebp),%eax
  80179d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8017a0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8017a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8017a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017ab:	39 d1                	cmp    %edx,%ecx
  8017ad:	72 07                	jb     8017b6 <printnum_v2+0x36>
  8017af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8017b2:	39 d0                	cmp    %edx,%eax
  8017b4:	77 5f                	ja     801815 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8017b6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8017ba:	83 eb 01             	sub    $0x1,%ebx
  8017bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8017c9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8017cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8017d0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8017d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8017d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017e1:	00 
  8017e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8017e5:	89 04 24             	mov    %eax,(%esp)
  8017e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8017eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017ef:	e8 cc 0d 00 00       	call   8025c0 <__udivdi3>
  8017f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8017f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8017fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	89 54 24 04          	mov    %edx,0x4(%esp)
  801809:	89 f2                	mov    %esi,%edx
  80180b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80180e:	e8 6d ff ff ff       	call   801780 <printnum_v2>
  801813:	eb 1e                	jmp    801833 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801815:	83 ff 2d             	cmp    $0x2d,%edi
  801818:	74 19                	je     801833 <printnum_v2+0xb3>
		while (--width > 0)
  80181a:	83 eb 01             	sub    $0x1,%ebx
  80181d:	85 db                	test   %ebx,%ebx
  80181f:	90                   	nop
  801820:	7e 11                	jle    801833 <printnum_v2+0xb3>
			putch(padc, putdat);
  801822:	89 74 24 04          	mov    %esi,0x4(%esp)
  801826:	89 3c 24             	mov    %edi,(%esp)
  801829:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80182c:	83 eb 01             	sub    $0x1,%ebx
  80182f:	85 db                	test   %ebx,%ebx
  801831:	7f ef                	jg     801822 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801833:	89 74 24 04          	mov    %esi,0x4(%esp)
  801837:	8b 74 24 04          	mov    0x4(%esp),%esi
  80183b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80183e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801842:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801849:	00 
  80184a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80184d:	89 14 24             	mov    %edx,(%esp)
  801850:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801853:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801857:	e8 94 0e 00 00       	call   8026f0 <__umoddi3>
  80185c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801860:	0f be 80 73 29 80 00 	movsbl 0x802973(%eax),%eax
  801867:	89 04 24             	mov    %eax,(%esp)
  80186a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80186d:	83 c4 4c             	add    $0x4c,%esp
  801870:	5b                   	pop    %ebx
  801871:	5e                   	pop    %esi
  801872:	5f                   	pop    %edi
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801878:	83 fa 01             	cmp    $0x1,%edx
  80187b:	7e 0e                	jle    80188b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80187d:	8b 10                	mov    (%eax),%edx
  80187f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801882:	89 08                	mov    %ecx,(%eax)
  801884:	8b 02                	mov    (%edx),%eax
  801886:	8b 52 04             	mov    0x4(%edx),%edx
  801889:	eb 22                	jmp    8018ad <getuint+0x38>
	else if (lflag)
  80188b:	85 d2                	test   %edx,%edx
  80188d:	74 10                	je     80189f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80188f:	8b 10                	mov    (%eax),%edx
  801891:	8d 4a 04             	lea    0x4(%edx),%ecx
  801894:	89 08                	mov    %ecx,(%eax)
  801896:	8b 02                	mov    (%edx),%eax
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	eb 0e                	jmp    8018ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80189f:	8b 10                	mov    (%eax),%edx
  8018a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018a4:	89 08                	mov    %ecx,(%eax)
  8018a6:	8b 02                	mov    (%edx),%eax
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8018b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8018b9:	8b 10                	mov    (%eax),%edx
  8018bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8018be:	73 0a                	jae    8018ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8018c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c3:	88 0a                	mov    %cl,(%edx)
  8018c5:	83 c2 01             	add    $0x1,%edx
  8018c8:	89 10                	mov    %edx,(%eax)
}
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	57                   	push   %edi
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 6c             	sub    $0x6c,%esp
  8018d5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8018d8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8018df:	eb 1a                	jmp    8018fb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	0f 84 66 06 00 00    	je     801f4f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8018e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018f0:	89 04 24             	mov    %eax,(%esp)
  8018f3:	ff 55 08             	call   *0x8(%ebp)
  8018f6:	eb 03                	jmp    8018fb <vprintfmt+0x2f>
  8018f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8018fb:	0f b6 07             	movzbl (%edi),%eax
  8018fe:	83 c7 01             	add    $0x1,%edi
  801901:	83 f8 25             	cmp    $0x25,%eax
  801904:	75 db                	jne    8018e1 <vprintfmt+0x15>
  801906:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80190a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80190f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801916:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80191b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801922:	be 00 00 00 00       	mov    $0x0,%esi
  801927:	eb 06                	jmp    80192f <vprintfmt+0x63>
  801929:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80192d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192f:	0f b6 17             	movzbl (%edi),%edx
  801932:	0f b6 c2             	movzbl %dl,%eax
  801935:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801938:	8d 47 01             	lea    0x1(%edi),%eax
  80193b:	83 ea 23             	sub    $0x23,%edx
  80193e:	80 fa 55             	cmp    $0x55,%dl
  801941:	0f 87 60 05 00 00    	ja     801ea7 <vprintfmt+0x5db>
  801947:	0f b6 d2             	movzbl %dl,%edx
  80194a:	ff 24 95 60 2b 80 00 	jmp    *0x802b60(,%edx,4)
  801951:	b9 01 00 00 00       	mov    $0x1,%ecx
  801956:	eb d5                	jmp    80192d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801958:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80195b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80195e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801961:	8d 7a d0             	lea    -0x30(%edx),%edi
  801964:	83 ff 09             	cmp    $0x9,%edi
  801967:	76 08                	jbe    801971 <vprintfmt+0xa5>
  801969:	eb 40                	jmp    8019ab <vprintfmt+0xdf>
  80196b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80196f:	eb bc                	jmp    80192d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801971:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801974:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  801977:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80197b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80197e:	8d 7a d0             	lea    -0x30(%edx),%edi
  801981:	83 ff 09             	cmp    $0x9,%edi
  801984:	76 eb                	jbe    801971 <vprintfmt+0xa5>
  801986:	eb 23                	jmp    8019ab <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801988:	8b 55 14             	mov    0x14(%ebp),%edx
  80198b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80198e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801991:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  801993:	eb 16                	jmp    8019ab <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  801995:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801998:	c1 fa 1f             	sar    $0x1f,%edx
  80199b:	f7 d2                	not    %edx
  80199d:	21 55 d8             	and    %edx,-0x28(%ebp)
  8019a0:	eb 8b                	jmp    80192d <vprintfmt+0x61>
  8019a2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8019a9:	eb 82                	jmp    80192d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8019ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019af:	0f 89 78 ff ff ff    	jns    80192d <vprintfmt+0x61>
  8019b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8019b8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8019bb:	e9 6d ff ff ff       	jmp    80192d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8019c0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8019c3:	e9 65 ff ff ff       	jmp    80192d <vprintfmt+0x61>
  8019c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8019cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ce:	8d 50 04             	lea    0x4(%eax),%edx
  8019d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019db:	8b 00                	mov    (%eax),%eax
  8019dd:	89 04 24             	mov    %eax,(%esp)
  8019e0:	ff 55 08             	call   *0x8(%ebp)
  8019e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8019e6:	e9 10 ff ff ff       	jmp    8018fb <vprintfmt+0x2f>
  8019eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8019ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f1:	8d 50 04             	lea    0x4(%eax),%edx
  8019f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8019f7:	8b 00                	mov    (%eax),%eax
  8019f9:	89 c2                	mov    %eax,%edx
  8019fb:	c1 fa 1f             	sar    $0x1f,%edx
  8019fe:	31 d0                	xor    %edx,%eax
  801a00:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a02:	83 f8 0f             	cmp    $0xf,%eax
  801a05:	7f 0b                	jg     801a12 <vprintfmt+0x146>
  801a07:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  801a0e:	85 d2                	test   %edx,%edx
  801a10:	75 26                	jne    801a38 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801a12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a16:	c7 44 24 08 84 29 80 	movl   $0x802984,0x8(%esp)
  801a1d:	00 
  801a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a21:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a28:	89 1c 24             	mov    %ebx,(%esp)
  801a2b:	e8 a7 05 00 00       	call   801fd7 <printfmt>
  801a30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a33:	e9 c3 fe ff ff       	jmp    8018fb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801a38:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a3c:	c7 44 24 08 2a 29 80 	movl   $0x80292a,0x8(%esp)
  801a43:	00 
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a4e:	89 14 24             	mov    %edx,(%esp)
  801a51:	e8 81 05 00 00       	call   801fd7 <printfmt>
  801a56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a59:	e9 9d fe ff ff       	jmp    8018fb <vprintfmt+0x2f>
  801a5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a61:	89 c7                	mov    %eax,%edi
  801a63:	89 d9                	mov    %ebx,%ecx
  801a65:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a68:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801a6b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6e:	8d 50 04             	lea    0x4(%eax),%edx
  801a71:	89 55 14             	mov    %edx,0x14(%ebp)
  801a74:	8b 30                	mov    (%eax),%esi
  801a76:	85 f6                	test   %esi,%esi
  801a78:	75 05                	jne    801a7f <vprintfmt+0x1b3>
  801a7a:	be 8d 29 80 00       	mov    $0x80298d,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  801a7f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  801a83:	7e 06                	jle    801a8b <vprintfmt+0x1bf>
  801a85:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  801a89:	75 10                	jne    801a9b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a8b:	0f be 06             	movsbl (%esi),%eax
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	0f 85 a2 00 00 00    	jne    801b38 <vprintfmt+0x26c>
  801a96:	e9 92 00 00 00       	jmp    801b2d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a9b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a9f:	89 34 24             	mov    %esi,(%esp)
  801aa2:	e8 74 05 00 00       	call   80201b <strnlen>
  801aa7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  801aaa:	29 c2                	sub    %eax,%edx
  801aac:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801aaf:	85 d2                	test   %edx,%edx
  801ab1:	7e d8                	jle    801a8b <vprintfmt+0x1bf>
					putch(padc, putdat);
  801ab3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  801ab7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  801aba:	89 d3                	mov    %edx,%ebx
  801abc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801abf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  801ac2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ac5:	89 ce                	mov    %ecx,%esi
  801ac7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801acb:	89 34 24             	mov    %esi,(%esp)
  801ace:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ad1:	83 eb 01             	sub    $0x1,%ebx
  801ad4:	85 db                	test   %ebx,%ebx
  801ad6:	7f ef                	jg     801ac7 <vprintfmt+0x1fb>
  801ad8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  801adb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801ade:	8b 7d bc             	mov    -0x44(%ebp),%edi
  801ae1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801ae8:	eb a1                	jmp    801a8b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801aea:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801aee:	74 1b                	je     801b0b <vprintfmt+0x23f>
  801af0:	8d 50 e0             	lea    -0x20(%eax),%edx
  801af3:	83 fa 5e             	cmp    $0x5e,%edx
  801af6:	76 13                	jbe    801b0b <vprintfmt+0x23f>
					putch('?', putdat);
  801af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aff:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b06:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b09:	eb 0d                	jmp    801b18 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b12:	89 04 24             	mov    %eax,(%esp)
  801b15:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b18:	83 ef 01             	sub    $0x1,%edi
  801b1b:	0f be 06             	movsbl (%esi),%eax
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	74 05                	je     801b27 <vprintfmt+0x25b>
  801b22:	83 c6 01             	add    $0x1,%esi
  801b25:	eb 1a                	jmp    801b41 <vprintfmt+0x275>
  801b27:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801b2a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b2d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801b31:	7f 1f                	jg     801b52 <vprintfmt+0x286>
  801b33:	e9 c0 fd ff ff       	jmp    8018f8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b38:	83 c6 01             	add    $0x1,%esi
  801b3b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801b3e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801b41:	85 db                	test   %ebx,%ebx
  801b43:	78 a5                	js     801aea <vprintfmt+0x21e>
  801b45:	83 eb 01             	sub    $0x1,%ebx
  801b48:	79 a0                	jns    801aea <vprintfmt+0x21e>
  801b4a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801b4d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b50:	eb db                	jmp    801b2d <vprintfmt+0x261>
  801b52:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b58:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801b5b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b5e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b62:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801b69:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b6b:	83 eb 01             	sub    $0x1,%ebx
  801b6e:	85 db                	test   %ebx,%ebx
  801b70:	7f ec                	jg     801b5e <vprintfmt+0x292>
  801b72:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801b75:	e9 81 fd ff ff       	jmp    8018fb <vprintfmt+0x2f>
  801b7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b7d:	83 fe 01             	cmp    $0x1,%esi
  801b80:	7e 10                	jle    801b92 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801b82:	8b 45 14             	mov    0x14(%ebp),%eax
  801b85:	8d 50 08             	lea    0x8(%eax),%edx
  801b88:	89 55 14             	mov    %edx,0x14(%ebp)
  801b8b:	8b 18                	mov    (%eax),%ebx
  801b8d:	8b 70 04             	mov    0x4(%eax),%esi
  801b90:	eb 26                	jmp    801bb8 <vprintfmt+0x2ec>
	else if (lflag)
  801b92:	85 f6                	test   %esi,%esi
  801b94:	74 12                	je     801ba8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801b96:	8b 45 14             	mov    0x14(%ebp),%eax
  801b99:	8d 50 04             	lea    0x4(%eax),%edx
  801b9c:	89 55 14             	mov    %edx,0x14(%ebp)
  801b9f:	8b 18                	mov    (%eax),%ebx
  801ba1:	89 de                	mov    %ebx,%esi
  801ba3:	c1 fe 1f             	sar    $0x1f,%esi
  801ba6:	eb 10                	jmp    801bb8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801ba8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bab:	8d 50 04             	lea    0x4(%eax),%edx
  801bae:	89 55 14             	mov    %edx,0x14(%ebp)
  801bb1:	8b 18                	mov    (%eax),%ebx
  801bb3:	89 de                	mov    %ebx,%esi
  801bb5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  801bb8:	83 f9 01             	cmp    $0x1,%ecx
  801bbb:	75 1e                	jne    801bdb <vprintfmt+0x30f>
                               if((long long)num > 0){
  801bbd:	85 f6                	test   %esi,%esi
  801bbf:	78 1a                	js     801bdb <vprintfmt+0x30f>
  801bc1:	85 f6                	test   %esi,%esi
  801bc3:	7f 05                	jg     801bca <vprintfmt+0x2fe>
  801bc5:	83 fb 00             	cmp    $0x0,%ebx
  801bc8:	76 11                	jbe    801bdb <vprintfmt+0x30f>
                                   putch('+',putdat);
  801bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bd1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  801bd8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  801bdb:	85 f6                	test   %esi,%esi
  801bdd:	78 13                	js     801bf2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801bdf:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  801be2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  801be5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801be8:	b8 0a 00 00 00       	mov    $0xa,%eax
  801bed:	e9 da 00 00 00       	jmp    801ccc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  801bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801c00:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801c03:	89 da                	mov    %ebx,%edx
  801c05:	89 f1                	mov    %esi,%ecx
  801c07:	f7 da                	neg    %edx
  801c09:	83 d1 00             	adc    $0x0,%ecx
  801c0c:	f7 d9                	neg    %ecx
  801c0e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801c11:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801c14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c17:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c1c:	e9 ab 00 00 00       	jmp    801ccc <vprintfmt+0x400>
  801c21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c24:	89 f2                	mov    %esi,%edx
  801c26:	8d 45 14             	lea    0x14(%ebp),%eax
  801c29:	e8 47 fc ff ff       	call   801875 <getuint>
  801c2e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801c31:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801c34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c37:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  801c3c:	e9 8b 00 00 00       	jmp    801ccc <vprintfmt+0x400>
  801c41:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c47:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c4b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c52:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801c55:	89 f2                	mov    %esi,%edx
  801c57:	8d 45 14             	lea    0x14(%ebp),%eax
  801c5a:	e8 16 fc ff ff       	call   801875 <getuint>
  801c5f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801c62:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801c65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c68:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  801c6d:	eb 5d                	jmp    801ccc <vprintfmt+0x400>
  801c6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c79:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c80:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c87:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c8e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801c91:	8b 45 14             	mov    0x14(%ebp),%eax
  801c94:	8d 50 04             	lea    0x4(%eax),%edx
  801c97:	89 55 14             	mov    %edx,0x14(%ebp)
  801c9a:	8b 10                	mov    (%eax),%edx
  801c9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ca1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801ca4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801ca7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801caa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801caf:	eb 1b                	jmp    801ccc <vprintfmt+0x400>
  801cb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801cb4:	89 f2                	mov    %esi,%edx
  801cb6:	8d 45 14             	lea    0x14(%ebp),%eax
  801cb9:	e8 b7 fb ff ff       	call   801875 <getuint>
  801cbe:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801cc1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801cc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801cc7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ccc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  801cd0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801cd3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801cd6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  801cda:	77 09                	ja     801ce5 <vprintfmt+0x419>
  801cdc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  801cdf:	0f 82 ac 00 00 00    	jb     801d91 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801ce5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801ce8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801cec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801cef:	83 ea 01             	sub    $0x1,%edx
  801cf2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cfa:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfe:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d02:	89 45 c0             	mov    %eax,-0x40(%ebp)
  801d05:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801d08:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d16:	00 
  801d17:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801d1a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801d1d:	89 0c 24             	mov    %ecx,(%esp)
  801d20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d24:	e8 97 08 00 00       	call   8025c0 <__udivdi3>
  801d29:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  801d2c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801d2f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d33:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d37:	89 04 24             	mov    %eax,(%esp)
  801d3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d41:	8b 45 08             	mov    0x8(%ebp),%eax
  801d44:	e8 37 fa ff ff       	call   801780 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801d49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d50:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d54:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801d57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d5b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d62:	00 
  801d63:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801d66:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801d69:	89 14 24             	mov    %edx,(%esp)
  801d6c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d70:	e8 7b 09 00 00       	call   8026f0 <__umoddi3>
  801d75:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d79:	0f be 80 73 29 80 00 	movsbl 0x802973(%eax),%eax
  801d80:	89 04 24             	mov    %eax,(%esp)
  801d83:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801d86:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801d8a:	74 54                	je     801de0 <vprintfmt+0x514>
  801d8c:	e9 67 fb ff ff       	jmp    8018f8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801d91:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	0f 84 2a 01 00 00    	je     801ec8 <vprintfmt+0x5fc>
		while (--width > 0)
  801d9e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801da1:	83 ef 01             	sub    $0x1,%edi
  801da4:	85 ff                	test   %edi,%edi
  801da6:	0f 8e 5e 01 00 00    	jle    801f0a <vprintfmt+0x63e>
  801dac:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801daf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801db2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801db5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801db8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801dbb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  801dbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc2:	89 1c 24             	mov    %ebx,(%esp)
  801dc5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  801dc8:	83 ef 01             	sub    $0x1,%edi
  801dcb:	85 ff                	test   %edi,%edi
  801dcd:	7f ef                	jg     801dbe <vprintfmt+0x4f2>
  801dcf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801dd2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801dd5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801dd8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801ddb:	e9 2a 01 00 00       	jmp    801f0a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801de0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801de3:	83 eb 01             	sub    $0x1,%ebx
  801de6:	85 db                	test   %ebx,%ebx
  801de8:	0f 8e 0a fb ff ff    	jle    8018f8 <vprintfmt+0x2c>
  801dee:	8b 75 0c             	mov    0xc(%ebp),%esi
  801df1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801df4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  801df7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dfb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801e02:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801e04:	83 eb 01             	sub    $0x1,%ebx
  801e07:	85 db                	test   %ebx,%ebx
  801e09:	7f ec                	jg     801df7 <vprintfmt+0x52b>
  801e0b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801e0e:	e9 e8 fa ff ff       	jmp    8018fb <vprintfmt+0x2f>
  801e13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801e16:	8b 45 14             	mov    0x14(%ebp),%eax
  801e19:	8d 50 04             	lea    0x4(%eax),%edx
  801e1c:	89 55 14             	mov    %edx,0x14(%ebp)
  801e1f:	8b 00                	mov    (%eax),%eax
  801e21:	85 c0                	test   %eax,%eax
  801e23:	75 2a                	jne    801e4f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801e25:	c7 44 24 0c a8 2a 80 	movl   $0x802aa8,0xc(%esp)
  801e2c:	00 
  801e2d:	c7 44 24 08 2a 29 80 	movl   $0x80292a,0x8(%esp)
  801e34:	00 
  801e35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e38:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3f:	89 0c 24             	mov    %ecx,(%esp)
  801e42:	e8 90 01 00 00       	call   801fd7 <printfmt>
  801e47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e4a:	e9 ac fa ff ff       	jmp    8018fb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  801e4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e52:	8b 13                	mov    (%ebx),%edx
  801e54:	83 fa 7f             	cmp    $0x7f,%edx
  801e57:	7e 29                	jle    801e82 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801e59:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  801e5b:	c7 44 24 0c e0 2a 80 	movl   $0x802ae0,0xc(%esp)
  801e62:	00 
  801e63:	c7 44 24 08 2a 29 80 	movl   $0x80292a,0x8(%esp)
  801e6a:	00 
  801e6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e72:	89 04 24             	mov    %eax,(%esp)
  801e75:	e8 5d 01 00 00       	call   801fd7 <printfmt>
  801e7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e7d:	e9 79 fa ff ff       	jmp    8018fb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801e82:	88 10                	mov    %dl,(%eax)
  801e84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e87:	e9 6f fa ff ff       	jmp    8018fb <vprintfmt+0x2f>
  801e8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e95:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e99:	89 14 24             	mov    %edx,(%esp)
  801e9c:	ff 55 08             	call   *0x8(%ebp)
  801e9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801ea2:	e9 54 fa ff ff       	jmp    8018fb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ea7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801eaa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801eb5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801eb8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801ebb:	80 38 25             	cmpb   $0x25,(%eax)
  801ebe:	0f 84 37 fa ff ff    	je     8018fb <vprintfmt+0x2f>
  801ec4:	89 c7                	mov    %eax,%edi
  801ec6:	eb f0                	jmp    801eb8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecf:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ed3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801ed6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801eda:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ee1:	00 
  801ee2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801ee5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801ee8:	89 04 24             	mov    %eax,(%esp)
  801eeb:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eef:	e8 fc 07 00 00       	call   8026f0 <__umoddi3>
  801ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef8:	0f be 80 73 29 80 00 	movsbl 0x802973(%eax),%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	ff 55 08             	call   *0x8(%ebp)
  801f05:	e9 d6 fe ff ff       	jmp    801de0 <vprintfmt+0x514>
  801f0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f11:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f15:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801f18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f1c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f23:	00 
  801f24:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801f27:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801f2a:	89 04 24             	mov    %eax,(%esp)
  801f2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f31:	e8 ba 07 00 00       	call   8026f0 <__umoddi3>
  801f36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f3a:	0f be 80 73 29 80 00 	movsbl 0x802973(%eax),%eax
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	ff 55 08             	call   *0x8(%ebp)
  801f47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f4a:	e9 ac f9 ff ff       	jmp    8018fb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801f4f:	83 c4 6c             	add    $0x6c,%esp
  801f52:	5b                   	pop    %ebx
  801f53:	5e                   	pop    %esi
  801f54:	5f                   	pop    %edi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	83 ec 28             	sub    $0x28,%esp
  801f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f60:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801f63:	85 c0                	test   %eax,%eax
  801f65:	74 04                	je     801f6b <vsnprintf+0x14>
  801f67:	85 d2                	test   %edx,%edx
  801f69:	7f 07                	jg     801f72 <vsnprintf+0x1b>
  801f6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f70:	eb 3b                	jmp    801fad <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f75:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801f79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801f7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f83:	8b 45 14             	mov    0x14(%ebp),%eax
  801f86:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f91:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f98:	c7 04 24 af 18 80 00 	movl   $0x8018af,(%esp)
  801f9f:	e8 28 f9 ff ff       	call   8018cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801fa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fa7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    

00801faf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801fb5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801fb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbc:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fca:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcd:	89 04 24             	mov    %eax,(%esp)
  801fd0:	e8 82 ff ff ff       	call   801f57 <vsnprintf>
	va_end(ap);

	return rc;
}
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801fdd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801fe0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fe4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801feb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff5:	89 04 24             	mov    %eax,(%esp)
  801ff8:	e8 cf f8 ff ff       	call   8018cc <vprintfmt>
	va_end(ap);
}
  801ffd:	c9                   	leave  
  801ffe:	c3                   	ret    
	...

00802000 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802006:	b8 00 00 00 00       	mov    $0x0,%eax
  80200b:	80 3a 00             	cmpb   $0x0,(%edx)
  80200e:	74 09                	je     802019 <strlen+0x19>
		n++;
  802010:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802013:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802017:	75 f7                	jne    802010 <strlen+0x10>
		n++;
	return n;
}
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	53                   	push   %ebx
  80201f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802022:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802025:	85 c9                	test   %ecx,%ecx
  802027:	74 19                	je     802042 <strnlen+0x27>
  802029:	80 3b 00             	cmpb   $0x0,(%ebx)
  80202c:	74 14                	je     802042 <strnlen+0x27>
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  802033:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802036:	39 c8                	cmp    %ecx,%eax
  802038:	74 0d                	je     802047 <strnlen+0x2c>
  80203a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80203e:	75 f3                	jne    802033 <strnlen+0x18>
  802040:	eb 05                	jmp    802047 <strnlen+0x2c>
  802042:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  802047:	5b                   	pop    %ebx
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    

0080204a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	53                   	push   %ebx
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802054:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802059:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80205d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  802060:	83 c2 01             	add    $0x1,%edx
  802063:	84 c9                	test   %cl,%cl
  802065:	75 f2                	jne    802059 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  802067:	5b                   	pop    %ebx
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    

0080206a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	53                   	push   %ebx
  80206e:	83 ec 08             	sub    $0x8,%esp
  802071:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802074:	89 1c 24             	mov    %ebx,(%esp)
  802077:	e8 84 ff ff ff       	call   802000 <strlen>
	strcpy(dst + len, src);
  80207c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80207f:	89 54 24 04          	mov    %edx,0x4(%esp)
  802083:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  802086:	89 04 24             	mov    %eax,(%esp)
  802089:	e8 bc ff ff ff       	call   80204a <strcpy>
	return dst;
}
  80208e:	89 d8                	mov    %ebx,%eax
  802090:	83 c4 08             	add    $0x8,%esp
  802093:	5b                   	pop    %ebx
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    

00802096 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	56                   	push   %esi
  80209a:	53                   	push   %ebx
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8020a4:	85 f6                	test   %esi,%esi
  8020a6:	74 18                	je     8020c0 <strncpy+0x2a>
  8020a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8020ad:	0f b6 1a             	movzbl (%edx),%ebx
  8020b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8020b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8020b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8020b9:	83 c1 01             	add    $0x1,%ecx
  8020bc:	39 ce                	cmp    %ecx,%esi
  8020be:	77 ed                	ja     8020ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8020c0:	5b                   	pop    %ebx
  8020c1:	5e                   	pop    %esi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    

008020c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	56                   	push   %esi
  8020c8:	53                   	push   %ebx
  8020c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8020cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8020d2:	89 f0                	mov    %esi,%eax
  8020d4:	85 c9                	test   %ecx,%ecx
  8020d6:	74 27                	je     8020ff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8020d8:	83 e9 01             	sub    $0x1,%ecx
  8020db:	74 1d                	je     8020fa <strlcpy+0x36>
  8020dd:	0f b6 1a             	movzbl (%edx),%ebx
  8020e0:	84 db                	test   %bl,%bl
  8020e2:	74 16                	je     8020fa <strlcpy+0x36>
			*dst++ = *src++;
  8020e4:	88 18                	mov    %bl,(%eax)
  8020e6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8020e9:	83 e9 01             	sub    $0x1,%ecx
  8020ec:	74 0e                	je     8020fc <strlcpy+0x38>
			*dst++ = *src++;
  8020ee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8020f1:	0f b6 1a             	movzbl (%edx),%ebx
  8020f4:	84 db                	test   %bl,%bl
  8020f6:	75 ec                	jne    8020e4 <strlcpy+0x20>
  8020f8:	eb 02                	jmp    8020fc <strlcpy+0x38>
  8020fa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8020fc:	c6 00 00             	movb   $0x0,(%eax)
  8020ff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80210b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80210e:	0f b6 01             	movzbl (%ecx),%eax
  802111:	84 c0                	test   %al,%al
  802113:	74 15                	je     80212a <strcmp+0x25>
  802115:	3a 02                	cmp    (%edx),%al
  802117:	75 11                	jne    80212a <strcmp+0x25>
		p++, q++;
  802119:	83 c1 01             	add    $0x1,%ecx
  80211c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80211f:	0f b6 01             	movzbl (%ecx),%eax
  802122:	84 c0                	test   %al,%al
  802124:	74 04                	je     80212a <strcmp+0x25>
  802126:	3a 02                	cmp    (%edx),%al
  802128:	74 ef                	je     802119 <strcmp+0x14>
  80212a:	0f b6 c0             	movzbl %al,%eax
  80212d:	0f b6 12             	movzbl (%edx),%edx
  802130:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    

00802134 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	53                   	push   %ebx
  802138:	8b 55 08             	mov    0x8(%ebp),%edx
  80213b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80213e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  802141:	85 c0                	test   %eax,%eax
  802143:	74 23                	je     802168 <strncmp+0x34>
  802145:	0f b6 1a             	movzbl (%edx),%ebx
  802148:	84 db                	test   %bl,%bl
  80214a:	74 25                	je     802171 <strncmp+0x3d>
  80214c:	3a 19                	cmp    (%ecx),%bl
  80214e:	75 21                	jne    802171 <strncmp+0x3d>
  802150:	83 e8 01             	sub    $0x1,%eax
  802153:	74 13                	je     802168 <strncmp+0x34>
		n--, p++, q++;
  802155:	83 c2 01             	add    $0x1,%edx
  802158:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80215b:	0f b6 1a             	movzbl (%edx),%ebx
  80215e:	84 db                	test   %bl,%bl
  802160:	74 0f                	je     802171 <strncmp+0x3d>
  802162:	3a 19                	cmp    (%ecx),%bl
  802164:	74 ea                	je     802150 <strncmp+0x1c>
  802166:	eb 09                	jmp    802171 <strncmp+0x3d>
  802168:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80216d:	5b                   	pop    %ebx
  80216e:	5d                   	pop    %ebp
  80216f:	90                   	nop
  802170:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802171:	0f b6 02             	movzbl (%edx),%eax
  802174:	0f b6 11             	movzbl (%ecx),%edx
  802177:	29 d0                	sub    %edx,%eax
  802179:	eb f2                	jmp    80216d <strncmp+0x39>

0080217b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	8b 45 08             	mov    0x8(%ebp),%eax
  802181:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802185:	0f b6 10             	movzbl (%eax),%edx
  802188:	84 d2                	test   %dl,%dl
  80218a:	74 18                	je     8021a4 <strchr+0x29>
		if (*s == c)
  80218c:	38 ca                	cmp    %cl,%dl
  80218e:	75 0a                	jne    80219a <strchr+0x1f>
  802190:	eb 17                	jmp    8021a9 <strchr+0x2e>
  802192:	38 ca                	cmp    %cl,%dl
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	74 0f                	je     8021a9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80219a:	83 c0 01             	add    $0x1,%eax
  80219d:	0f b6 10             	movzbl (%eax),%edx
  8021a0:	84 d2                	test   %dl,%dl
  8021a2:	75 ee                	jne    802192 <strchr+0x17>
  8021a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    

008021ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8021b5:	0f b6 10             	movzbl (%eax),%edx
  8021b8:	84 d2                	test   %dl,%dl
  8021ba:	74 18                	je     8021d4 <strfind+0x29>
		if (*s == c)
  8021bc:	38 ca                	cmp    %cl,%dl
  8021be:	75 0a                	jne    8021ca <strfind+0x1f>
  8021c0:	eb 12                	jmp    8021d4 <strfind+0x29>
  8021c2:	38 ca                	cmp    %cl,%dl
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	74 0a                	je     8021d4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8021ca:	83 c0 01             	add    $0x1,%eax
  8021cd:	0f b6 10             	movzbl (%eax),%edx
  8021d0:	84 d2                	test   %dl,%dl
  8021d2:	75 ee                	jne    8021c2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 0c             	sub    $0xc,%esp
  8021dc:	89 1c 24             	mov    %ebx,(%esp)
  8021df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8021e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8021f0:	85 c9                	test   %ecx,%ecx
  8021f2:	74 30                	je     802224 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8021f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8021fa:	75 25                	jne    802221 <memset+0x4b>
  8021fc:	f6 c1 03             	test   $0x3,%cl
  8021ff:	75 20                	jne    802221 <memset+0x4b>
		c &= 0xFF;
  802201:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802204:	89 d3                	mov    %edx,%ebx
  802206:	c1 e3 08             	shl    $0x8,%ebx
  802209:	89 d6                	mov    %edx,%esi
  80220b:	c1 e6 18             	shl    $0x18,%esi
  80220e:	89 d0                	mov    %edx,%eax
  802210:	c1 e0 10             	shl    $0x10,%eax
  802213:	09 f0                	or     %esi,%eax
  802215:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  802217:	09 d8                	or     %ebx,%eax
  802219:	c1 e9 02             	shr    $0x2,%ecx
  80221c:	fc                   	cld    
  80221d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80221f:	eb 03                	jmp    802224 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802221:	fc                   	cld    
  802222:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802224:	89 f8                	mov    %edi,%eax
  802226:	8b 1c 24             	mov    (%esp),%ebx
  802229:	8b 74 24 04          	mov    0x4(%esp),%esi
  80222d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802231:	89 ec                	mov    %ebp,%esp
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 08             	sub    $0x8,%esp
  80223b:	89 34 24             	mov    %esi,(%esp)
  80223e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802242:	8b 45 08             	mov    0x8(%ebp),%eax
  802245:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  802248:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80224b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80224d:	39 c6                	cmp    %eax,%esi
  80224f:	73 35                	jae    802286 <memmove+0x51>
  802251:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802254:	39 d0                	cmp    %edx,%eax
  802256:	73 2e                	jae    802286 <memmove+0x51>
		s += n;
		d += n;
  802258:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80225a:	f6 c2 03             	test   $0x3,%dl
  80225d:	75 1b                	jne    80227a <memmove+0x45>
  80225f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802265:	75 13                	jne    80227a <memmove+0x45>
  802267:	f6 c1 03             	test   $0x3,%cl
  80226a:	75 0e                	jne    80227a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80226c:	83 ef 04             	sub    $0x4,%edi
  80226f:	8d 72 fc             	lea    -0x4(%edx),%esi
  802272:	c1 e9 02             	shr    $0x2,%ecx
  802275:	fd                   	std    
  802276:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802278:	eb 09                	jmp    802283 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80227a:	83 ef 01             	sub    $0x1,%edi
  80227d:	8d 72 ff             	lea    -0x1(%edx),%esi
  802280:	fd                   	std    
  802281:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802283:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802284:	eb 20                	jmp    8022a6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802286:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80228c:	75 15                	jne    8022a3 <memmove+0x6e>
  80228e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802294:	75 0d                	jne    8022a3 <memmove+0x6e>
  802296:	f6 c1 03             	test   $0x3,%cl
  802299:	75 08                	jne    8022a3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80229b:	c1 e9 02             	shr    $0x2,%ecx
  80229e:	fc                   	cld    
  80229f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022a1:	eb 03                	jmp    8022a6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8022a3:	fc                   	cld    
  8022a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8022a6:	8b 34 24             	mov    (%esp),%esi
  8022a9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022ad:	89 ec                	mov    %ebp,%esp
  8022af:	5d                   	pop    %ebp
  8022b0:	c3                   	ret    

008022b1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8022b1:	55                   	push   %ebp
  8022b2:	89 e5                	mov    %esp,%ebp
  8022b4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8022b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8022ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c8:	89 04 24             	mov    %eax,(%esp)
  8022cb:	e8 65 ff ff ff       	call   802235 <memmove>
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	57                   	push   %edi
  8022d6:	56                   	push   %esi
  8022d7:	53                   	push   %ebx
  8022d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8022db:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8022e1:	85 c9                	test   %ecx,%ecx
  8022e3:	74 36                	je     80231b <memcmp+0x49>
		if (*s1 != *s2)
  8022e5:	0f b6 06             	movzbl (%esi),%eax
  8022e8:	0f b6 1f             	movzbl (%edi),%ebx
  8022eb:	38 d8                	cmp    %bl,%al
  8022ed:	74 20                	je     80230f <memcmp+0x3d>
  8022ef:	eb 14                	jmp    802305 <memcmp+0x33>
  8022f1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8022f6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8022fb:	83 c2 01             	add    $0x1,%edx
  8022fe:	83 e9 01             	sub    $0x1,%ecx
  802301:	38 d8                	cmp    %bl,%al
  802303:	74 12                	je     802317 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  802305:	0f b6 c0             	movzbl %al,%eax
  802308:	0f b6 db             	movzbl %bl,%ebx
  80230b:	29 d8                	sub    %ebx,%eax
  80230d:	eb 11                	jmp    802320 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80230f:	83 e9 01             	sub    $0x1,%ecx
  802312:	ba 00 00 00 00       	mov    $0x0,%edx
  802317:	85 c9                	test   %ecx,%ecx
  802319:	75 d6                	jne    8022f1 <memcmp+0x1f>
  80231b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802320:	5b                   	pop    %ebx
  802321:	5e                   	pop    %esi
  802322:	5f                   	pop    %edi
  802323:	5d                   	pop    %ebp
  802324:	c3                   	ret    

00802325 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802325:	55                   	push   %ebp
  802326:	89 e5                	mov    %esp,%ebp
  802328:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80232b:	89 c2                	mov    %eax,%edx
  80232d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802330:	39 d0                	cmp    %edx,%eax
  802332:	73 15                	jae    802349 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802334:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  802338:	38 08                	cmp    %cl,(%eax)
  80233a:	75 06                	jne    802342 <memfind+0x1d>
  80233c:	eb 0b                	jmp    802349 <memfind+0x24>
  80233e:	38 08                	cmp    %cl,(%eax)
  802340:	74 07                	je     802349 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802342:	83 c0 01             	add    $0x1,%eax
  802345:	39 c2                	cmp    %eax,%edx
  802347:	77 f5                	ja     80233e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802349:	5d                   	pop    %ebp
  80234a:	c3                   	ret    

0080234b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	57                   	push   %edi
  80234f:	56                   	push   %esi
  802350:	53                   	push   %ebx
  802351:	83 ec 04             	sub    $0x4,%esp
  802354:	8b 55 08             	mov    0x8(%ebp),%edx
  802357:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80235a:	0f b6 02             	movzbl (%edx),%eax
  80235d:	3c 20                	cmp    $0x20,%al
  80235f:	74 04                	je     802365 <strtol+0x1a>
  802361:	3c 09                	cmp    $0x9,%al
  802363:	75 0e                	jne    802373 <strtol+0x28>
		s++;
  802365:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802368:	0f b6 02             	movzbl (%edx),%eax
  80236b:	3c 20                	cmp    $0x20,%al
  80236d:	74 f6                	je     802365 <strtol+0x1a>
  80236f:	3c 09                	cmp    $0x9,%al
  802371:	74 f2                	je     802365 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  802373:	3c 2b                	cmp    $0x2b,%al
  802375:	75 0c                	jne    802383 <strtol+0x38>
		s++;
  802377:	83 c2 01             	add    $0x1,%edx
  80237a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802381:	eb 15                	jmp    802398 <strtol+0x4d>
	else if (*s == '-')
  802383:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80238a:	3c 2d                	cmp    $0x2d,%al
  80238c:	75 0a                	jne    802398 <strtol+0x4d>
		s++, neg = 1;
  80238e:	83 c2 01             	add    $0x1,%edx
  802391:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802398:	85 db                	test   %ebx,%ebx
  80239a:	0f 94 c0             	sete   %al
  80239d:	74 05                	je     8023a4 <strtol+0x59>
  80239f:	83 fb 10             	cmp    $0x10,%ebx
  8023a2:	75 18                	jne    8023bc <strtol+0x71>
  8023a4:	80 3a 30             	cmpb   $0x30,(%edx)
  8023a7:	75 13                	jne    8023bc <strtol+0x71>
  8023a9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8023ad:	8d 76 00             	lea    0x0(%esi),%esi
  8023b0:	75 0a                	jne    8023bc <strtol+0x71>
		s += 2, base = 16;
  8023b2:	83 c2 02             	add    $0x2,%edx
  8023b5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8023ba:	eb 15                	jmp    8023d1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8023bc:	84 c0                	test   %al,%al
  8023be:	66 90                	xchg   %ax,%ax
  8023c0:	74 0f                	je     8023d1 <strtol+0x86>
  8023c2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8023c7:	80 3a 30             	cmpb   $0x30,(%edx)
  8023ca:	75 05                	jne    8023d1 <strtol+0x86>
		s++, base = 8;
  8023cc:	83 c2 01             	add    $0x1,%edx
  8023cf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8023d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8023d6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8023d8:	0f b6 0a             	movzbl (%edx),%ecx
  8023db:	89 cf                	mov    %ecx,%edi
  8023dd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8023e0:	80 fb 09             	cmp    $0x9,%bl
  8023e3:	77 08                	ja     8023ed <strtol+0xa2>
			dig = *s - '0';
  8023e5:	0f be c9             	movsbl %cl,%ecx
  8023e8:	83 e9 30             	sub    $0x30,%ecx
  8023eb:	eb 1e                	jmp    80240b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8023ed:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8023f0:	80 fb 19             	cmp    $0x19,%bl
  8023f3:	77 08                	ja     8023fd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8023f5:	0f be c9             	movsbl %cl,%ecx
  8023f8:	83 e9 57             	sub    $0x57,%ecx
  8023fb:	eb 0e                	jmp    80240b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8023fd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  802400:	80 fb 19             	cmp    $0x19,%bl
  802403:	77 15                	ja     80241a <strtol+0xcf>
			dig = *s - 'A' + 10;
  802405:	0f be c9             	movsbl %cl,%ecx
  802408:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80240b:	39 f1                	cmp    %esi,%ecx
  80240d:	7d 0b                	jge    80241a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80240f:	83 c2 01             	add    $0x1,%edx
  802412:	0f af c6             	imul   %esi,%eax
  802415:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  802418:	eb be                	jmp    8023d8 <strtol+0x8d>
  80241a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80241c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802420:	74 05                	je     802427 <strtol+0xdc>
		*endptr = (char *) s;
  802422:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802425:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802427:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80242b:	74 04                	je     802431 <strtol+0xe6>
  80242d:	89 c8                	mov    %ecx,%eax
  80242f:	f7 d8                	neg    %eax
}
  802431:	83 c4 04             	add    $0x4,%esp
  802434:	5b                   	pop    %ebx
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    
  802439:	00 00                	add    %al,(%eax)
  80243b:	00 00                	add    %al,(%eax)
  80243d:	00 00                	add    %al,(%eax)
	...

00802440 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802446:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80244c:	b8 01 00 00 00       	mov    $0x1,%eax
  802451:	39 ca                	cmp    %ecx,%edx
  802453:	75 04                	jne    802459 <ipc_find_env+0x19>
  802455:	b0 00                	mov    $0x0,%al
  802457:	eb 12                	jmp    80246b <ipc_find_env+0x2b>
  802459:	89 c2                	mov    %eax,%edx
  80245b:	c1 e2 07             	shl    $0x7,%edx
  80245e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802465:	8b 12                	mov    (%edx),%edx
  802467:	39 ca                	cmp    %ecx,%edx
  802469:	75 10                	jne    80247b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80246b:	89 c2                	mov    %eax,%edx
  80246d:	c1 e2 07             	shl    $0x7,%edx
  802470:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802477:	8b 00                	mov    (%eax),%eax
  802479:	eb 0e                	jmp    802489 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80247b:	83 c0 01             	add    $0x1,%eax
  80247e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802483:	75 d4                	jne    802459 <ipc_find_env+0x19>
  802485:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802489:	5d                   	pop    %ebp
  80248a:	c3                   	ret    

0080248b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80248b:	55                   	push   %ebp
  80248c:	89 e5                	mov    %esp,%ebp
  80248e:	57                   	push   %edi
  80248f:	56                   	push   %esi
  802490:	53                   	push   %ebx
  802491:	83 ec 1c             	sub    $0x1c,%esp
  802494:	8b 75 08             	mov    0x8(%ebp),%esi
  802497:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80249a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80249d:	85 db                	test   %ebx,%ebx
  80249f:	74 19                	je     8024ba <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8024a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8024a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024b0:	89 34 24             	mov    %esi,(%esp)
  8024b3:	e8 d9 df ff ff       	call   800491 <sys_ipc_try_send>
  8024b8:	eb 1b                	jmp    8024d5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8024ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8024bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024c1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8024c8:	ee 
  8024c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024cd:	89 34 24             	mov    %esi,(%esp)
  8024d0:	e8 bc df ff ff       	call   800491 <sys_ipc_try_send>
           if(ret == 0)
  8024d5:	85 c0                	test   %eax,%eax
  8024d7:	74 28                	je     802501 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8024d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024dc:	74 1c                	je     8024fa <ipc_send+0x6f>
              panic("ipc send error");
  8024de:	c7 44 24 08 00 2d 80 	movl   $0x802d00,0x8(%esp)
  8024e5:	00 
  8024e6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8024ed:	00 
  8024ee:	c7 04 24 0f 2d 80 00 	movl   $0x802d0f,(%esp)
  8024f5:	e8 6a f1 ff ff       	call   801664 <_panic>
           sys_yield();
  8024fa:	e8 5e e2 ff ff       	call   80075d <sys_yield>
        }
  8024ff:	eb 9c                	jmp    80249d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802501:	83 c4 1c             	add    $0x1c,%esp
  802504:	5b                   	pop    %ebx
  802505:	5e                   	pop    %esi
  802506:	5f                   	pop    %edi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    

00802509 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	56                   	push   %esi
  80250d:	53                   	push   %ebx
  80250e:	83 ec 10             	sub    $0x10,%esp
  802511:	8b 75 08             	mov    0x8(%ebp),%esi
  802514:	8b 45 0c             	mov    0xc(%ebp),%eax
  802517:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80251a:	85 c0                	test   %eax,%eax
  80251c:	75 0e                	jne    80252c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80251e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802525:	e8 fc de ff ff       	call   800426 <sys_ipc_recv>
  80252a:	eb 08                	jmp    802534 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80252c:	89 04 24             	mov    %eax,(%esp)
  80252f:	e8 f2 de ff ff       	call   800426 <sys_ipc_recv>
        if(ret == 0){
  802534:	85 c0                	test   %eax,%eax
  802536:	75 26                	jne    80255e <ipc_recv+0x55>
           if(from_env_store)
  802538:	85 f6                	test   %esi,%esi
  80253a:	74 0a                	je     802546 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80253c:	a1 40 50 80 00       	mov    0x805040,%eax
  802541:	8b 40 78             	mov    0x78(%eax),%eax
  802544:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802546:	85 db                	test   %ebx,%ebx
  802548:	74 0a                	je     802554 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80254a:	a1 40 50 80 00       	mov    0x805040,%eax
  80254f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802552:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802554:	a1 40 50 80 00       	mov    0x805040,%eax
  802559:	8b 40 74             	mov    0x74(%eax),%eax
  80255c:	eb 14                	jmp    802572 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80255e:	85 f6                	test   %esi,%esi
  802560:	74 06                	je     802568 <ipc_recv+0x5f>
              *from_env_store = 0;
  802562:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802568:	85 db                	test   %ebx,%ebx
  80256a:	74 06                	je     802572 <ipc_recv+0x69>
              *perm_store = 0;
  80256c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802572:	83 c4 10             	add    $0x10,%esp
  802575:	5b                   	pop    %ebx
  802576:	5e                   	pop    %esi
  802577:	5d                   	pop    %ebp
  802578:	c3                   	ret    
  802579:	00 00                	add    %al,(%eax)
	...

0080257c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80257c:	55                   	push   %ebp
  80257d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80257f:	8b 45 08             	mov    0x8(%ebp),%eax
  802582:	89 c2                	mov    %eax,%edx
  802584:	c1 ea 16             	shr    $0x16,%edx
  802587:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80258e:	f6 c2 01             	test   $0x1,%dl
  802591:	74 20                	je     8025b3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802593:	c1 e8 0c             	shr    $0xc,%eax
  802596:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80259d:	a8 01                	test   $0x1,%al
  80259f:	74 12                	je     8025b3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025a1:	c1 e8 0c             	shr    $0xc,%eax
  8025a4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025a9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025ae:	0f b7 c0             	movzwl %ax,%eax
  8025b1:	eb 05                	jmp    8025b8 <pageref+0x3c>
  8025b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025b8:	5d                   	pop    %ebp
  8025b9:	c3                   	ret    
  8025ba:	00 00                	add    %al,(%eax)
  8025bc:	00 00                	add    %al,(%eax)
	...

008025c0 <__udivdi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	89 e5                	mov    %esp,%ebp
  8025c3:	57                   	push   %edi
  8025c4:	56                   	push   %esi
  8025c5:	83 ec 10             	sub    $0x10,%esp
  8025c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8025cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8025d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025d4:	85 c0                	test   %eax,%eax
  8025d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8025d9:	75 35                	jne    802610 <__udivdi3+0x50>
  8025db:	39 fe                	cmp    %edi,%esi
  8025dd:	77 61                	ja     802640 <__udivdi3+0x80>
  8025df:	85 f6                	test   %esi,%esi
  8025e1:	75 0b                	jne    8025ee <__udivdi3+0x2e>
  8025e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e8:	31 d2                	xor    %edx,%edx
  8025ea:	f7 f6                	div    %esi
  8025ec:	89 c6                	mov    %eax,%esi
  8025ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8025f1:	31 d2                	xor    %edx,%edx
  8025f3:	89 f8                	mov    %edi,%eax
  8025f5:	f7 f6                	div    %esi
  8025f7:	89 c7                	mov    %eax,%edi
  8025f9:	89 c8                	mov    %ecx,%eax
  8025fb:	f7 f6                	div    %esi
  8025fd:	89 c1                	mov    %eax,%ecx
  8025ff:	89 fa                	mov    %edi,%edx
  802601:	89 c8                	mov    %ecx,%eax
  802603:	83 c4 10             	add    $0x10,%esp
  802606:	5e                   	pop    %esi
  802607:	5f                   	pop    %edi
  802608:	5d                   	pop    %ebp
  802609:	c3                   	ret    
  80260a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802610:	39 f8                	cmp    %edi,%eax
  802612:	77 1c                	ja     802630 <__udivdi3+0x70>
  802614:	0f bd d0             	bsr    %eax,%edx
  802617:	83 f2 1f             	xor    $0x1f,%edx
  80261a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80261d:	75 39                	jne    802658 <__udivdi3+0x98>
  80261f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802622:	0f 86 a0 00 00 00    	jbe    8026c8 <__udivdi3+0x108>
  802628:	39 f8                	cmp    %edi,%eax
  80262a:	0f 82 98 00 00 00    	jb     8026c8 <__udivdi3+0x108>
  802630:	31 ff                	xor    %edi,%edi
  802632:	31 c9                	xor    %ecx,%ecx
  802634:	89 c8                	mov    %ecx,%eax
  802636:	89 fa                	mov    %edi,%edx
  802638:	83 c4 10             	add    $0x10,%esp
  80263b:	5e                   	pop    %esi
  80263c:	5f                   	pop    %edi
  80263d:	5d                   	pop    %ebp
  80263e:	c3                   	ret    
  80263f:	90                   	nop
  802640:	89 d1                	mov    %edx,%ecx
  802642:	89 fa                	mov    %edi,%edx
  802644:	89 c8                	mov    %ecx,%eax
  802646:	31 ff                	xor    %edi,%edi
  802648:	f7 f6                	div    %esi
  80264a:	89 c1                	mov    %eax,%ecx
  80264c:	89 fa                	mov    %edi,%edx
  80264e:	89 c8                	mov    %ecx,%eax
  802650:	83 c4 10             	add    $0x10,%esp
  802653:	5e                   	pop    %esi
  802654:	5f                   	pop    %edi
  802655:	5d                   	pop    %ebp
  802656:	c3                   	ret    
  802657:	90                   	nop
  802658:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80265c:	89 f2                	mov    %esi,%edx
  80265e:	d3 e0                	shl    %cl,%eax
  802660:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802663:	b8 20 00 00 00       	mov    $0x20,%eax
  802668:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80266b:	89 c1                	mov    %eax,%ecx
  80266d:	d3 ea                	shr    %cl,%edx
  80266f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802673:	0b 55 ec             	or     -0x14(%ebp),%edx
  802676:	d3 e6                	shl    %cl,%esi
  802678:	89 c1                	mov    %eax,%ecx
  80267a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80267d:	89 fe                	mov    %edi,%esi
  80267f:	d3 ee                	shr    %cl,%esi
  802681:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802685:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802688:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80268b:	d3 e7                	shl    %cl,%edi
  80268d:	89 c1                	mov    %eax,%ecx
  80268f:	d3 ea                	shr    %cl,%edx
  802691:	09 d7                	or     %edx,%edi
  802693:	89 f2                	mov    %esi,%edx
  802695:	89 f8                	mov    %edi,%eax
  802697:	f7 75 ec             	divl   -0x14(%ebp)
  80269a:	89 d6                	mov    %edx,%esi
  80269c:	89 c7                	mov    %eax,%edi
  80269e:	f7 65 e8             	mull   -0x18(%ebp)
  8026a1:	39 d6                	cmp    %edx,%esi
  8026a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026a6:	72 30                	jb     8026d8 <__udivdi3+0x118>
  8026a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026af:	d3 e2                	shl    %cl,%edx
  8026b1:	39 c2                	cmp    %eax,%edx
  8026b3:	73 05                	jae    8026ba <__udivdi3+0xfa>
  8026b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8026b8:	74 1e                	je     8026d8 <__udivdi3+0x118>
  8026ba:	89 f9                	mov    %edi,%ecx
  8026bc:	31 ff                	xor    %edi,%edi
  8026be:	e9 71 ff ff ff       	jmp    802634 <__udivdi3+0x74>
  8026c3:	90                   	nop
  8026c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c8:	31 ff                	xor    %edi,%edi
  8026ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8026cf:	e9 60 ff ff ff       	jmp    802634 <__udivdi3+0x74>
  8026d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8026db:	31 ff                	xor    %edi,%edi
  8026dd:	89 c8                	mov    %ecx,%eax
  8026df:	89 fa                	mov    %edi,%edx
  8026e1:	83 c4 10             	add    $0x10,%esp
  8026e4:	5e                   	pop    %esi
  8026e5:	5f                   	pop    %edi
  8026e6:	5d                   	pop    %ebp
  8026e7:	c3                   	ret    
	...

008026f0 <__umoddi3>:
  8026f0:	55                   	push   %ebp
  8026f1:	89 e5                	mov    %esp,%ebp
  8026f3:	57                   	push   %edi
  8026f4:	56                   	push   %esi
  8026f5:	83 ec 20             	sub    $0x20,%esp
  8026f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8026fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  802701:	8b 75 0c             	mov    0xc(%ebp),%esi
  802704:	85 d2                	test   %edx,%edx
  802706:	89 c8                	mov    %ecx,%eax
  802708:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80270b:	75 13                	jne    802720 <__umoddi3+0x30>
  80270d:	39 f7                	cmp    %esi,%edi
  80270f:	76 3f                	jbe    802750 <__umoddi3+0x60>
  802711:	89 f2                	mov    %esi,%edx
  802713:	f7 f7                	div    %edi
  802715:	89 d0                	mov    %edx,%eax
  802717:	31 d2                	xor    %edx,%edx
  802719:	83 c4 20             	add    $0x20,%esp
  80271c:	5e                   	pop    %esi
  80271d:	5f                   	pop    %edi
  80271e:	5d                   	pop    %ebp
  80271f:	c3                   	ret    
  802720:	39 f2                	cmp    %esi,%edx
  802722:	77 4c                	ja     802770 <__umoddi3+0x80>
  802724:	0f bd ca             	bsr    %edx,%ecx
  802727:	83 f1 1f             	xor    $0x1f,%ecx
  80272a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80272d:	75 51                	jne    802780 <__umoddi3+0x90>
  80272f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802732:	0f 87 e0 00 00 00    	ja     802818 <__umoddi3+0x128>
  802738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80273b:	29 f8                	sub    %edi,%eax
  80273d:	19 d6                	sbb    %edx,%esi
  80273f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802745:	89 f2                	mov    %esi,%edx
  802747:	83 c4 20             	add    $0x20,%esp
  80274a:	5e                   	pop    %esi
  80274b:	5f                   	pop    %edi
  80274c:	5d                   	pop    %ebp
  80274d:	c3                   	ret    
  80274e:	66 90                	xchg   %ax,%ax
  802750:	85 ff                	test   %edi,%edi
  802752:	75 0b                	jne    80275f <__umoddi3+0x6f>
  802754:	b8 01 00 00 00       	mov    $0x1,%eax
  802759:	31 d2                	xor    %edx,%edx
  80275b:	f7 f7                	div    %edi
  80275d:	89 c7                	mov    %eax,%edi
  80275f:	89 f0                	mov    %esi,%eax
  802761:	31 d2                	xor    %edx,%edx
  802763:	f7 f7                	div    %edi
  802765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802768:	f7 f7                	div    %edi
  80276a:	eb a9                	jmp    802715 <__umoddi3+0x25>
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	89 c8                	mov    %ecx,%eax
  802772:	89 f2                	mov    %esi,%edx
  802774:	83 c4 20             	add    $0x20,%esp
  802777:	5e                   	pop    %esi
  802778:	5f                   	pop    %edi
  802779:	5d                   	pop    %ebp
  80277a:	c3                   	ret    
  80277b:	90                   	nop
  80277c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802780:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802784:	d3 e2                	shl    %cl,%edx
  802786:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802789:	ba 20 00 00 00       	mov    $0x20,%edx
  80278e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802791:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802794:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802798:	89 fa                	mov    %edi,%edx
  80279a:	d3 ea                	shr    %cl,%edx
  80279c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8027a3:	d3 e7                	shl    %cl,%edi
  8027a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027ac:	89 f2                	mov    %esi,%edx
  8027ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8027b1:	89 c7                	mov    %eax,%edi
  8027b3:	d3 ea                	shr    %cl,%edx
  8027b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8027bc:	89 c2                	mov    %eax,%edx
  8027be:	d3 e6                	shl    %cl,%esi
  8027c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027c4:	d3 ea                	shr    %cl,%edx
  8027c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027ca:	09 d6                	or     %edx,%esi
  8027cc:	89 f0                	mov    %esi,%eax
  8027ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8027d1:	d3 e7                	shl    %cl,%edi
  8027d3:	89 f2                	mov    %esi,%edx
  8027d5:	f7 75 f4             	divl   -0xc(%ebp)
  8027d8:	89 d6                	mov    %edx,%esi
  8027da:	f7 65 e8             	mull   -0x18(%ebp)
  8027dd:	39 d6                	cmp    %edx,%esi
  8027df:	72 2b                	jb     80280c <__umoddi3+0x11c>
  8027e1:	39 c7                	cmp    %eax,%edi
  8027e3:	72 23                	jb     802808 <__umoddi3+0x118>
  8027e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027e9:	29 c7                	sub    %eax,%edi
  8027eb:	19 d6                	sbb    %edx,%esi
  8027ed:	89 f0                	mov    %esi,%eax
  8027ef:	89 f2                	mov    %esi,%edx
  8027f1:	d3 ef                	shr    %cl,%edi
  8027f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027f7:	d3 e0                	shl    %cl,%eax
  8027f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027fd:	09 f8                	or     %edi,%eax
  8027ff:	d3 ea                	shr    %cl,%edx
  802801:	83 c4 20             	add    $0x20,%esp
  802804:	5e                   	pop    %esi
  802805:	5f                   	pop    %edi
  802806:	5d                   	pop    %ebp
  802807:	c3                   	ret    
  802808:	39 d6                	cmp    %edx,%esi
  80280a:	75 d9                	jne    8027e5 <__umoddi3+0xf5>
  80280c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80280f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802812:	eb d1                	jmp    8027e5 <__umoddi3+0xf5>
  802814:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802818:	39 f2                	cmp    %esi,%edx
  80281a:	0f 82 18 ff ff ff    	jb     802738 <__umoddi3+0x48>
  802820:	e9 1d ff ff ff       	jmp    802742 <__umoddi3+0x52>
