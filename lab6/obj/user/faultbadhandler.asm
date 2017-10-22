
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 ce 05 00 00       	call   800624 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 9c 03 00 00       	call   800406 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80008a:	e8 84 06 00 00       	call   800713 <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	89 c2                	mov    %eax,%edx
  800096:	c1 e2 07             	shl    $0x7,%edx
  800099:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000a0:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a5:	85 f6                	test   %esi,%esi
  8000a7:	7e 07                	jle    8000b0 <libmain+0x38>
		binaryname = argv[0];
  8000a9:	8b 03                	mov    (%ebx),%eax
  8000ab:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b4:	89 34 24             	mov    %esi,(%esp)
  8000b7:	e8 78 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bc:	e8 0b 00 00 00       	call   8000cc <exit>
}
  8000c1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c7:	89 ec                	mov    %ebp,%esp
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000d2:	e8 c4 0b 00 00       	call   800c9b <close_all>
	sys_env_destroy(0);
  8000d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000de:	e8 70 06 00 00       	call   800753 <sys_env_destroy>
}
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    
  8000e5:	00 00                	add    %al,(%eax)
	...

008000e8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	89 1c 24             	mov    %ebx,(%esp)
  8000f1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ff:	89 d1                	mov    %edx,%ecx
  800101:	89 d3                	mov    %edx,%ebx
  800103:	89 d7                	mov    %edx,%edi
  800105:	51                   	push   %ecx
  800106:	52                   	push   %edx
  800107:	53                   	push   %ebx
  800108:	54                   	push   %esp
  800109:	55                   	push   %ebp
  80010a:	56                   	push   %esi
  80010b:	57                   	push   %edi
  80010c:	54                   	push   %esp
  80010d:	5d                   	pop    %ebp
  80010e:	8d 35 16 01 80 00    	lea    0x800116,%esi
  800114:	0f 34                	sysenter 
  800116:	5f                   	pop    %edi
  800117:	5e                   	pop    %esi
  800118:	5d                   	pop    %ebp
  800119:	5c                   	pop    %esp
  80011a:	5b                   	pop    %ebx
  80011b:	5a                   	pop    %edx
  80011c:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011d:	8b 1c 24             	mov    (%esp),%ebx
  800120:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800124:	89 ec                	mov    %ebp,%esp
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	89 1c 24             	mov    %ebx,(%esp)
  800131:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800135:	b8 00 00 00 00       	mov    $0x0,%eax
  80013a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80013d:	8b 55 08             	mov    0x8(%ebp),%edx
  800140:	89 c3                	mov    %eax,%ebx
  800142:	89 c7                	mov    %eax,%edi
  800144:	51                   	push   %ecx
  800145:	52                   	push   %edx
  800146:	53                   	push   %ebx
  800147:	54                   	push   %esp
  800148:	55                   	push   %ebp
  800149:	56                   	push   %esi
  80014a:	57                   	push   %edi
  80014b:	54                   	push   %esp
  80014c:	5d                   	pop    %ebp
  80014d:	8d 35 55 01 80 00    	lea    0x800155,%esi
  800153:	0f 34                	sysenter 
  800155:	5f                   	pop    %edi
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	5c                   	pop    %esp
  800159:	5b                   	pop    %ebx
  80015a:	5a                   	pop    %edx
  80015b:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80015c:	8b 1c 24             	mov    (%esp),%ebx
  80015f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800163:	89 ec                	mov    %ebp,%esp
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	89 1c 24             	mov    %ebx,(%esp)
  800170:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800174:	b9 00 00 00 00       	mov    $0x0,%ecx
  800179:	b8 13 00 00 00       	mov    $0x13,%eax
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	89 cb                	mov    %ecx,%ebx
  800183:	89 cf                	mov    %ecx,%edi
  800185:	51                   	push   %ecx
  800186:	52                   	push   %edx
  800187:	53                   	push   %ebx
  800188:	54                   	push   %esp
  800189:	55                   	push   %ebp
  80018a:	56                   	push   %esi
  80018b:	57                   	push   %edi
  80018c:	54                   	push   %esp
  80018d:	5d                   	pop    %ebp
  80018e:	8d 35 96 01 80 00    	lea    0x800196,%esi
  800194:	0f 34                	sysenter 
  800196:	5f                   	pop    %edi
  800197:	5e                   	pop    %esi
  800198:	5d                   	pop    %ebp
  800199:	5c                   	pop    %esp
  80019a:	5b                   	pop    %ebx
  80019b:	5a                   	pop    %edx
  80019c:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  80019d:	8b 1c 24             	mov    (%esp),%ebx
  8001a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001a4:	89 ec                	mov    %ebp,%esp
  8001a6:	5d                   	pop    %ebp
  8001a7:	c3                   	ret    

008001a8 <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	89 1c 24             	mov    %ebx,(%esp)
  8001b1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ba:	b8 12 00 00 00       	mov    $0x12,%eax
  8001bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c5:	89 df                	mov    %ebx,%edi
  8001c7:	51                   	push   %ecx
  8001c8:	52                   	push   %edx
  8001c9:	53                   	push   %ebx
  8001ca:	54                   	push   %esp
  8001cb:	55                   	push   %ebp
  8001cc:	56                   	push   %esi
  8001cd:	57                   	push   %edi
  8001ce:	54                   	push   %esp
  8001cf:	5d                   	pop    %ebp
  8001d0:	8d 35 d8 01 80 00    	lea    0x8001d8,%esi
  8001d6:	0f 34                	sysenter 
  8001d8:	5f                   	pop    %edi
  8001d9:	5e                   	pop    %esi
  8001da:	5d                   	pop    %ebp
  8001db:	5c                   	pop    %esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5a                   	pop    %edx
  8001de:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8001df:	8b 1c 24             	mov    (%esp),%ebx
  8001e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001e6:	89 ec                	mov    %ebp,%esp
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	89 1c 24             	mov    %ebx,(%esp)
  8001f3:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fc:	b8 11 00 00 00       	mov    $0x11,%eax
  800201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800204:	8b 55 08             	mov    0x8(%ebp),%edx
  800207:	89 df                	mov    %ebx,%edi
  800209:	51                   	push   %ecx
  80020a:	52                   	push   %edx
  80020b:	53                   	push   %ebx
  80020c:	54                   	push   %esp
  80020d:	55                   	push   %ebp
  80020e:	56                   	push   %esi
  80020f:	57                   	push   %edi
  800210:	54                   	push   %esp
  800211:	5d                   	pop    %ebp
  800212:	8d 35 1a 02 80 00    	lea    0x80021a,%esi
  800218:	0f 34                	sysenter 
  80021a:	5f                   	pop    %edi
  80021b:	5e                   	pop    %esi
  80021c:	5d                   	pop    %ebp
  80021d:	5c                   	pop    %esp
  80021e:	5b                   	pop    %ebx
  80021f:	5a                   	pop    %edx
  800220:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800221:	8b 1c 24             	mov    (%esp),%ebx
  800224:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800228:	89 ec                	mov    %ebp,%esp
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	89 1c 24             	mov    %ebx,(%esp)
  800235:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800239:	b8 10 00 00 00       	mov    $0x10,%eax
  80023e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800241:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	51                   	push   %ecx
  80024b:	52                   	push   %edx
  80024c:	53                   	push   %ebx
  80024d:	54                   	push   %esp
  80024e:	55                   	push   %ebp
  80024f:	56                   	push   %esi
  800250:	57                   	push   %edi
  800251:	54                   	push   %esp
  800252:	5d                   	pop    %ebp
  800253:	8d 35 5b 02 80 00    	lea    0x80025b,%esi
  800259:	0f 34                	sysenter 
  80025b:	5f                   	pop    %edi
  80025c:	5e                   	pop    %esi
  80025d:	5d                   	pop    %ebp
  80025e:	5c                   	pop    %esp
  80025f:	5b                   	pop    %ebx
  800260:	5a                   	pop    %edx
  800261:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800262:	8b 1c 24             	mov    (%esp),%ebx
  800265:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800269:	89 ec                	mov    %ebp,%esp
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 28             	sub    $0x28,%esp
  800273:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800276:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800279:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800286:	8b 55 08             	mov    0x8(%ebp),%edx
  800289:	89 df                	mov    %ebx,%edi
  80028b:	51                   	push   %ecx
  80028c:	52                   	push   %edx
  80028d:	53                   	push   %ebx
  80028e:	54                   	push   %esp
  80028f:	55                   	push   %ebp
  800290:	56                   	push   %esi
  800291:	57                   	push   %edi
  800292:	54                   	push   %esp
  800293:	5d                   	pop    %ebp
  800294:	8d 35 9c 02 80 00    	lea    0x80029c,%esi
  80029a:	0f 34                	sysenter 
  80029c:	5f                   	pop    %edi
  80029d:	5e                   	pop    %esi
  80029e:	5d                   	pop    %ebp
  80029f:	5c                   	pop    %esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5a                   	pop    %edx
  8002a2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8002a3:	85 c0                	test   %eax,%eax
  8002a5:	7e 28                	jle    8002cf <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ab:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8002b2:	00 
  8002b3:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  8002ba:	00 
  8002bb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8002c2:	00 
  8002c3:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  8002ca:	e8 c5 12 00 00       	call   801594 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8002cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002d2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002d5:	89 ec                	mov    %ebp,%esp
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 08             	sub    $0x8,%esp
  8002df:	89 1c 24             	mov    %ebx,(%esp)
  8002e2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	b8 15 00 00 00       	mov    $0x15,%eax
  8002f0:	89 d1                	mov    %edx,%ecx
  8002f2:	89 d3                	mov    %edx,%ebx
  8002f4:	89 d7                	mov    %edx,%edi
  8002f6:	51                   	push   %ecx
  8002f7:	52                   	push   %edx
  8002f8:	53                   	push   %ebx
  8002f9:	54                   	push   %esp
  8002fa:	55                   	push   %ebp
  8002fb:	56                   	push   %esi
  8002fc:	57                   	push   %edi
  8002fd:	54                   	push   %esp
  8002fe:	5d                   	pop    %ebp
  8002ff:	8d 35 07 03 80 00    	lea    0x800307,%esi
  800305:	0f 34                	sysenter 
  800307:	5f                   	pop    %edi
  800308:	5e                   	pop    %esi
  800309:	5d                   	pop    %ebp
  80030a:	5c                   	pop    %esp
  80030b:	5b                   	pop    %ebx
  80030c:	5a                   	pop    %edx
  80030d:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80030e:	8b 1c 24             	mov    (%esp),%ebx
  800311:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800315:	89 ec                	mov    %ebp,%esp
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	89 1c 24             	mov    %ebx,(%esp)
  800322:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800326:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032b:	b8 14 00 00 00       	mov    $0x14,%eax
  800330:	8b 55 08             	mov    0x8(%ebp),%edx
  800333:	89 cb                	mov    %ecx,%ebx
  800335:	89 cf                	mov    %ecx,%edi
  800337:	51                   	push   %ecx
  800338:	52                   	push   %edx
  800339:	53                   	push   %ebx
  80033a:	54                   	push   %esp
  80033b:	55                   	push   %ebp
  80033c:	56                   	push   %esi
  80033d:	57                   	push   %edi
  80033e:	54                   	push   %esp
  80033f:	5d                   	pop    %ebp
  800340:	8d 35 48 03 80 00    	lea    0x800348,%esi
  800346:	0f 34                	sysenter 
  800348:	5f                   	pop    %edi
  800349:	5e                   	pop    %esi
  80034a:	5d                   	pop    %ebp
  80034b:	5c                   	pop    %esp
  80034c:	5b                   	pop    %ebx
  80034d:	5a                   	pop    %edx
  80034e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80034f:	8b 1c 24             	mov    (%esp),%ebx
  800352:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800356:	89 ec                	mov    %ebp,%esp
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	83 ec 28             	sub    $0x28,%esp
  800360:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800363:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800366:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800370:	8b 55 08             	mov    0x8(%ebp),%edx
  800373:	89 cb                	mov    %ecx,%ebx
  800375:	89 cf                	mov    %ecx,%edi
  800377:	51                   	push   %ecx
  800378:	52                   	push   %edx
  800379:	53                   	push   %ebx
  80037a:	54                   	push   %esp
  80037b:	55                   	push   %ebp
  80037c:	56                   	push   %esi
  80037d:	57                   	push   %edi
  80037e:	54                   	push   %esp
  80037f:	5d                   	pop    %ebp
  800380:	8d 35 88 03 80 00    	lea    0x800388,%esi
  800386:	0f 34                	sysenter 
  800388:	5f                   	pop    %edi
  800389:	5e                   	pop    %esi
  80038a:	5d                   	pop    %ebp
  80038b:	5c                   	pop    %esp
  80038c:	5b                   	pop    %ebx
  80038d:	5a                   	pop    %edx
  80038e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80038f:	85 c0                	test   %eax,%eax
  800391:	7e 28                	jle    8003bb <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800393:	89 44 24 10          	mov    %eax,0x10(%esp)
  800397:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80039e:	00 
  80039f:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  8003a6:	00 
  8003a7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8003ae:	00 
  8003af:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  8003b6:	e8 d9 11 00 00       	call   801594 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003bb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003be:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003c1:	89 ec                	mov    %ebp,%esp
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	89 1c 24             	mov    %ebx,(%esp)
  8003ce:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003d2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e3:	51                   	push   %ecx
  8003e4:	52                   	push   %edx
  8003e5:	53                   	push   %ebx
  8003e6:	54                   	push   %esp
  8003e7:	55                   	push   %ebp
  8003e8:	56                   	push   %esi
  8003e9:	57                   	push   %edi
  8003ea:	54                   	push   %esp
  8003eb:	5d                   	pop    %ebp
  8003ec:	8d 35 f4 03 80 00    	lea    0x8003f4,%esi
  8003f2:	0f 34                	sysenter 
  8003f4:	5f                   	pop    %edi
  8003f5:	5e                   	pop    %esi
  8003f6:	5d                   	pop    %ebp
  8003f7:	5c                   	pop    %esp
  8003f8:	5b                   	pop    %ebx
  8003f9:	5a                   	pop    %edx
  8003fa:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003fb:	8b 1c 24             	mov    (%esp),%ebx
  8003fe:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800402:	89 ec                	mov    %ebp,%esp
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 28             	sub    $0x28,%esp
  80040c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80040f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800412:	bb 00 00 00 00       	mov    $0x0,%ebx
  800417:	b8 0b 00 00 00       	mov    $0xb,%eax
  80041c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041f:	8b 55 08             	mov    0x8(%ebp),%edx
  800422:	89 df                	mov    %ebx,%edi
  800424:	51                   	push   %ecx
  800425:	52                   	push   %edx
  800426:	53                   	push   %ebx
  800427:	54                   	push   %esp
  800428:	55                   	push   %ebp
  800429:	56                   	push   %esi
  80042a:	57                   	push   %edi
  80042b:	54                   	push   %esp
  80042c:	5d                   	pop    %ebp
  80042d:	8d 35 35 04 80 00    	lea    0x800435,%esi
  800433:	0f 34                	sysenter 
  800435:	5f                   	pop    %edi
  800436:	5e                   	pop    %esi
  800437:	5d                   	pop    %ebp
  800438:	5c                   	pop    %esp
  800439:	5b                   	pop    %ebx
  80043a:	5a                   	pop    %edx
  80043b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80043c:	85 c0                	test   %eax,%eax
  80043e:	7e 28                	jle    800468 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800440:	89 44 24 10          	mov    %eax,0x10(%esp)
  800444:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80044b:	00 
  80044c:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  800453:	00 
  800454:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80045b:	00 
  80045c:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  800463:	e8 2c 11 00 00       	call   801594 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800468:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80046b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80046e:	89 ec                	mov    %ebp,%esp
  800470:	5d                   	pop    %ebp
  800471:	c3                   	ret    

00800472 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	83 ec 28             	sub    $0x28,%esp
  800478:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80047b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80047e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800483:	b8 0a 00 00 00       	mov    $0xa,%eax
  800488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048b:	8b 55 08             	mov    0x8(%ebp),%edx
  80048e:	89 df                	mov    %ebx,%edi
  800490:	51                   	push   %ecx
  800491:	52                   	push   %edx
  800492:	53                   	push   %ebx
  800493:	54                   	push   %esp
  800494:	55                   	push   %ebp
  800495:	56                   	push   %esi
  800496:	57                   	push   %edi
  800497:	54                   	push   %esp
  800498:	5d                   	pop    %ebp
  800499:	8d 35 a1 04 80 00    	lea    0x8004a1,%esi
  80049f:	0f 34                	sysenter 
  8004a1:	5f                   	pop    %edi
  8004a2:	5e                   	pop    %esi
  8004a3:	5d                   	pop    %ebp
  8004a4:	5c                   	pop    %esp
  8004a5:	5b                   	pop    %ebx
  8004a6:	5a                   	pop    %edx
  8004a7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	7e 28                	jle    8004d4 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004b0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8004b7:	00 
  8004b8:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  8004bf:	00 
  8004c0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004c7:	00 
  8004c8:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  8004cf:	e8 c0 10 00 00       	call   801594 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8004d4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004d7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004da:	89 ec                	mov    %ebp,%esp
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	83 ec 28             	sub    $0x28,%esp
  8004e4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004e7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ef:	b8 09 00 00 00       	mov    $0x9,%eax
  8004f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fa:	89 df                	mov    %ebx,%edi
  8004fc:	51                   	push   %ecx
  8004fd:	52                   	push   %edx
  8004fe:	53                   	push   %ebx
  8004ff:	54                   	push   %esp
  800500:	55                   	push   %ebp
  800501:	56                   	push   %esi
  800502:	57                   	push   %edi
  800503:	54                   	push   %esp
  800504:	5d                   	pop    %ebp
  800505:	8d 35 0d 05 80 00    	lea    0x80050d,%esi
  80050b:	0f 34                	sysenter 
  80050d:	5f                   	pop    %edi
  80050e:	5e                   	pop    %esi
  80050f:	5d                   	pop    %ebp
  800510:	5c                   	pop    %esp
  800511:	5b                   	pop    %ebx
  800512:	5a                   	pop    %edx
  800513:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800514:	85 c0                	test   %eax,%eax
  800516:	7e 28                	jle    800540 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800518:	89 44 24 10          	mov    %eax,0x10(%esp)
  80051c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800523:	00 
  800524:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  80052b:	00 
  80052c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800533:	00 
  800534:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  80053b:	e8 54 10 00 00       	call   801594 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800540:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800543:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800546:	89 ec                	mov    %ebp,%esp
  800548:	5d                   	pop    %ebp
  800549:	c3                   	ret    

0080054a <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	83 ec 28             	sub    $0x28,%esp
  800550:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800553:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800556:	bb 00 00 00 00       	mov    $0x0,%ebx
  80055b:	b8 07 00 00 00       	mov    $0x7,%eax
  800560:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800563:	8b 55 08             	mov    0x8(%ebp),%edx
  800566:	89 df                	mov    %ebx,%edi
  800568:	51                   	push   %ecx
  800569:	52                   	push   %edx
  80056a:	53                   	push   %ebx
  80056b:	54                   	push   %esp
  80056c:	55                   	push   %ebp
  80056d:	56                   	push   %esi
  80056e:	57                   	push   %edi
  80056f:	54                   	push   %esp
  800570:	5d                   	pop    %ebp
  800571:	8d 35 79 05 80 00    	lea    0x800579,%esi
  800577:	0f 34                	sysenter 
  800579:	5f                   	pop    %edi
  80057a:	5e                   	pop    %esi
  80057b:	5d                   	pop    %ebp
  80057c:	5c                   	pop    %esp
  80057d:	5b                   	pop    %ebx
  80057e:	5a                   	pop    %edx
  80057f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800580:	85 c0                	test   %eax,%eax
  800582:	7e 28                	jle    8005ac <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800584:	89 44 24 10          	mov    %eax,0x10(%esp)
  800588:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80058f:	00 
  800590:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  800597:	00 
  800598:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80059f:	00 
  8005a0:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  8005a7:	e8 e8 0f 00 00       	call   801594 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8005ac:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005af:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005b2:	89 ec                	mov    %ebp,%esp
  8005b4:	5d                   	pop    %ebp
  8005b5:	c3                   	ret    

008005b6 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005b6:	55                   	push   %ebp
  8005b7:	89 e5                	mov    %esp,%ebp
  8005b9:	83 ec 28             	sub    $0x28,%esp
  8005bc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005bf:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005c2:	8b 7d 18             	mov    0x18(%ebp),%edi
  8005c5:	0b 7d 14             	or     0x14(%ebp),%edi
  8005c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8005cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d6:	51                   	push   %ecx
  8005d7:	52                   	push   %edx
  8005d8:	53                   	push   %ebx
  8005d9:	54                   	push   %esp
  8005da:	55                   	push   %ebp
  8005db:	56                   	push   %esi
  8005dc:	57                   	push   %edi
  8005dd:	54                   	push   %esp
  8005de:	5d                   	pop    %ebp
  8005df:	8d 35 e7 05 80 00    	lea    0x8005e7,%esi
  8005e5:	0f 34                	sysenter 
  8005e7:	5f                   	pop    %edi
  8005e8:	5e                   	pop    %esi
  8005e9:	5d                   	pop    %ebp
  8005ea:	5c                   	pop    %esp
  8005eb:	5b                   	pop    %ebx
  8005ec:	5a                   	pop    %edx
  8005ed:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	7e 28                	jle    80061a <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005f6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005fd:	00 
  8005fe:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  800605:	00 
  800606:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80060d:	00 
  80060e:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  800615:	e8 7a 0f 00 00       	call   801594 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  80061a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80061d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800620:	89 ec                	mov    %ebp,%esp
  800622:	5d                   	pop    %ebp
  800623:	c3                   	ret    

00800624 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	83 ec 28             	sub    $0x28,%esp
  80062a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80062d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800630:	bf 00 00 00 00       	mov    $0x0,%edi
  800635:	b8 05 00 00 00       	mov    $0x5,%eax
  80063a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80063d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800640:	8b 55 08             	mov    0x8(%ebp),%edx
  800643:	51                   	push   %ecx
  800644:	52                   	push   %edx
  800645:	53                   	push   %ebx
  800646:	54                   	push   %esp
  800647:	55                   	push   %ebp
  800648:	56                   	push   %esi
  800649:	57                   	push   %edi
  80064a:	54                   	push   %esp
  80064b:	5d                   	pop    %ebp
  80064c:	8d 35 54 06 80 00    	lea    0x800654,%esi
  800652:	0f 34                	sysenter 
  800654:	5f                   	pop    %edi
  800655:	5e                   	pop    %esi
  800656:	5d                   	pop    %ebp
  800657:	5c                   	pop    %esp
  800658:	5b                   	pop    %ebx
  800659:	5a                   	pop    %edx
  80065a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80065b:	85 c0                	test   %eax,%eax
  80065d:	7e 28                	jle    800687 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80065f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800663:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80066a:	00 
  80066b:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  800672:	00 
  800673:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80067a:	00 
  80067b:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  800682:	e8 0d 0f 00 00       	call   801594 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800687:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80068a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80068d:	89 ec                	mov    %ebp,%esp
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	89 1c 24             	mov    %ebx,(%esp)
  80069a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80069e:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8006a8:	89 d1                	mov    %edx,%ecx
  8006aa:	89 d3                	mov    %edx,%ebx
  8006ac:	89 d7                	mov    %edx,%edi
  8006ae:	51                   	push   %ecx
  8006af:	52                   	push   %edx
  8006b0:	53                   	push   %ebx
  8006b1:	54                   	push   %esp
  8006b2:	55                   	push   %ebp
  8006b3:	56                   	push   %esi
  8006b4:	57                   	push   %edi
  8006b5:	54                   	push   %esp
  8006b6:	5d                   	pop    %ebp
  8006b7:	8d 35 bf 06 80 00    	lea    0x8006bf,%esi
  8006bd:	0f 34                	sysenter 
  8006bf:	5f                   	pop    %edi
  8006c0:	5e                   	pop    %esi
  8006c1:	5d                   	pop    %ebp
  8006c2:	5c                   	pop    %esp
  8006c3:	5b                   	pop    %ebx
  8006c4:	5a                   	pop    %edx
  8006c5:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8006c6:	8b 1c 24             	mov    (%esp),%ebx
  8006c9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006cd:	89 ec                	mov    %ebp,%esp
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	89 1c 24             	mov    %ebx,(%esp)
  8006da:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e3:	b8 04 00 00 00       	mov    $0x4,%eax
  8006e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ee:	89 df                	mov    %ebx,%edi
  8006f0:	51                   	push   %ecx
  8006f1:	52                   	push   %edx
  8006f2:	53                   	push   %ebx
  8006f3:	54                   	push   %esp
  8006f4:	55                   	push   %ebp
  8006f5:	56                   	push   %esi
  8006f6:	57                   	push   %edi
  8006f7:	54                   	push   %esp
  8006f8:	5d                   	pop    %ebp
  8006f9:	8d 35 01 07 80 00    	lea    0x800701,%esi
  8006ff:	0f 34                	sysenter 
  800701:	5f                   	pop    %edi
  800702:	5e                   	pop    %esi
  800703:	5d                   	pop    %ebp
  800704:	5c                   	pop    %esp
  800705:	5b                   	pop    %ebx
  800706:	5a                   	pop    %edx
  800707:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800708:	8b 1c 24             	mov    (%esp),%ebx
  80070b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80070f:	89 ec                	mov    %ebp,%esp
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	89 1c 24             	mov    %ebx,(%esp)
  80071c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800720:	ba 00 00 00 00       	mov    $0x0,%edx
  800725:	b8 02 00 00 00       	mov    $0x2,%eax
  80072a:	89 d1                	mov    %edx,%ecx
  80072c:	89 d3                	mov    %edx,%ebx
  80072e:	89 d7                	mov    %edx,%edi
  800730:	51                   	push   %ecx
  800731:	52                   	push   %edx
  800732:	53                   	push   %ebx
  800733:	54                   	push   %esp
  800734:	55                   	push   %ebp
  800735:	56                   	push   %esi
  800736:	57                   	push   %edi
  800737:	54                   	push   %esp
  800738:	5d                   	pop    %ebp
  800739:	8d 35 41 07 80 00    	lea    0x800741,%esi
  80073f:	0f 34                	sysenter 
  800741:	5f                   	pop    %edi
  800742:	5e                   	pop    %esi
  800743:	5d                   	pop    %ebp
  800744:	5c                   	pop    %esp
  800745:	5b                   	pop    %ebx
  800746:	5a                   	pop    %edx
  800747:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800748:	8b 1c 24             	mov    (%esp),%ebx
  80074b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80074f:	89 ec                	mov    %ebp,%esp
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 28             	sub    $0x28,%esp
  800759:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80075c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80075f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800764:	b8 03 00 00 00       	mov    $0x3,%eax
  800769:	8b 55 08             	mov    0x8(%ebp),%edx
  80076c:	89 cb                	mov    %ecx,%ebx
  80076e:	89 cf                	mov    %ecx,%edi
  800770:	51                   	push   %ecx
  800771:	52                   	push   %edx
  800772:	53                   	push   %ebx
  800773:	54                   	push   %esp
  800774:	55                   	push   %ebp
  800775:	56                   	push   %esi
  800776:	57                   	push   %edi
  800777:	54                   	push   %esp
  800778:	5d                   	pop    %ebp
  800779:	8d 35 81 07 80 00    	lea    0x800781,%esi
  80077f:	0f 34                	sysenter 
  800781:	5f                   	pop    %edi
  800782:	5e                   	pop    %esi
  800783:	5d                   	pop    %ebp
  800784:	5c                   	pop    %esp
  800785:	5b                   	pop    %ebx
  800786:	5a                   	pop    %edx
  800787:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800788:	85 c0                	test   %eax,%eax
  80078a:	7e 28                	jle    8007b4 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80078c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800790:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800797:	00 
  800798:	c7 44 24 08 6a 27 80 	movl   $0x80276a,0x8(%esp)
  80079f:	00 
  8007a0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8007a7:	00 
  8007a8:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  8007af:	e8 e0 0d 00 00       	call   801594 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8007b4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8007b7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8007ba:	89 ec                	mov    %ebp,%esp
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    
	...

008007c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8007cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	89 04 24             	mov    %eax,(%esp)
  8007dc:	e8 df ff ff ff       	call   8007c0 <fd2num>
  8007e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8007e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    

008007eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	57                   	push   %edi
  8007ef:	56                   	push   %esi
  8007f0:	53                   	push   %ebx
  8007f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8007f4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8007f9:	a8 01                	test   $0x1,%al
  8007fb:	74 36                	je     800833 <fd_alloc+0x48>
  8007fd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800802:	a8 01                	test   $0x1,%al
  800804:	74 2d                	je     800833 <fd_alloc+0x48>
  800806:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80080b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800810:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800815:	89 c3                	mov    %eax,%ebx
  800817:	89 c2                	mov    %eax,%edx
  800819:	c1 ea 16             	shr    $0x16,%edx
  80081c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80081f:	f6 c2 01             	test   $0x1,%dl
  800822:	74 14                	je     800838 <fd_alloc+0x4d>
  800824:	89 c2                	mov    %eax,%edx
  800826:	c1 ea 0c             	shr    $0xc,%edx
  800829:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80082c:	f6 c2 01             	test   $0x1,%dl
  80082f:	75 10                	jne    800841 <fd_alloc+0x56>
  800831:	eb 05                	jmp    800838 <fd_alloc+0x4d>
  800833:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800838:	89 1f                	mov    %ebx,(%edi)
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80083f:	eb 17                	jmp    800858 <fd_alloc+0x6d>
  800841:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800846:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80084b:	75 c8                	jne    800815 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80084d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800853:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5f                   	pop    %edi
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	83 f8 1f             	cmp    $0x1f,%eax
  800866:	77 36                	ja     80089e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800868:	05 00 00 0d 00       	add    $0xd0000,%eax
  80086d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800870:	89 c2                	mov    %eax,%edx
  800872:	c1 ea 16             	shr    $0x16,%edx
  800875:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80087c:	f6 c2 01             	test   $0x1,%dl
  80087f:	74 1d                	je     80089e <fd_lookup+0x41>
  800881:	89 c2                	mov    %eax,%edx
  800883:	c1 ea 0c             	shr    $0xc,%edx
  800886:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80088d:	f6 c2 01             	test   $0x1,%dl
  800890:	74 0c                	je     80089e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
  800895:	89 02                	mov    %eax,(%edx)
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80089c:	eb 05                	jmp    8008a3 <fd_lookup+0x46>
  80089e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	89 04 24             	mov    %eax,(%esp)
  8008b8:	e8 a0 ff ff ff       	call   80085d <fd_lookup>
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	78 0e                	js     8008cf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c7:	89 50 04             	mov    %edx,0x4(%eax)
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	56                   	push   %esi
  8008d5:	53                   	push   %ebx
  8008d6:	83 ec 10             	sub    $0x10,%esp
  8008d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8008df:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8008e4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008e9:	be 14 28 80 00       	mov    $0x802814,%esi
		if (devtab[i]->dev_id == dev_id) {
  8008ee:	39 08                	cmp    %ecx,(%eax)
  8008f0:	75 10                	jne    800902 <dev_lookup+0x31>
  8008f2:	eb 04                	jmp    8008f8 <dev_lookup+0x27>
  8008f4:	39 08                	cmp    %ecx,(%eax)
  8008f6:	75 0a                	jne    800902 <dev_lookup+0x31>
			*dev = devtab[i];
  8008f8:	89 03                	mov    %eax,(%ebx)
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8008ff:	90                   	nop
  800900:	eb 31                	jmp    800933 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	8b 04 96             	mov    (%esi,%edx,4),%eax
  800908:	85 c0                	test   %eax,%eax
  80090a:	75 e8                	jne    8008f4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80090c:	a1 08 40 80 00       	mov    0x804008,%eax
  800911:	8b 40 48             	mov    0x48(%eax),%eax
  800914:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091c:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  800923:	e8 25 0d 00 00       	call   80164d <cprintf>
	*dev = 0;
  800928:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80092e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	83 ec 24             	sub    $0x24,%esp
  800941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800944:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	89 04 24             	mov    %eax,(%esp)
  800951:	e8 07 ff ff ff       	call   80085d <fd_lookup>
  800956:	85 c0                	test   %eax,%eax
  800958:	78 53                	js     8009ad <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80095a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80095d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800961:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800964:	8b 00                	mov    (%eax),%eax
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	e8 63 ff ff ff       	call   8008d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80096e:	85 c0                	test   %eax,%eax
  800970:	78 3b                	js     8009ad <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800972:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800977:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80097a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80097e:	74 2d                	je     8009ad <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800980:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800983:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80098a:	00 00 00 
	stat->st_isdir = 0;
  80098d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800994:	00 00 00 
	stat->st_dev = dev;
  800997:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009a7:	89 14 24             	mov    %edx,(%esp)
  8009aa:	ff 50 14             	call   *0x14(%eax)
}
  8009ad:	83 c4 24             	add    $0x24,%esp
  8009b0:	5b                   	pop    %ebx
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	53                   	push   %ebx
  8009b7:	83 ec 24             	sub    $0x24,%esp
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c4:	89 1c 24             	mov    %ebx,(%esp)
  8009c7:	e8 91 fe ff ff       	call   80085d <fd_lookup>
  8009cc:	85 c0                	test   %eax,%eax
  8009ce:	78 5f                	js     800a2f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009da:	8b 00                	mov    (%eax),%eax
  8009dc:	89 04 24             	mov    %eax,(%esp)
  8009df:	e8 ed fe ff ff       	call   8008d1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	78 47                	js     800a2f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009eb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8009ef:	75 23                	jne    800a14 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8009f1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8009f6:	8b 40 48             	mov    0x48(%eax),%eax
  8009f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a01:	c7 04 24 b8 27 80 00 	movl   $0x8027b8,(%esp)
  800a08:	e8 40 0c 00 00       	call   80164d <cprintf>
  800a0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a12:	eb 1b                	jmp    800a2f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a17:	8b 48 18             	mov    0x18(%eax),%ecx
  800a1a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a1f:	85 c9                	test   %ecx,%ecx
  800a21:	74 0c                	je     800a2f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2a:	89 14 24             	mov    %edx,(%esp)
  800a2d:	ff d1                	call   *%ecx
}
  800a2f:	83 c4 24             	add    $0x24,%esp
  800a32:	5b                   	pop    %ebx
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	53                   	push   %ebx
  800a39:	83 ec 24             	sub    $0x24,%esp
  800a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a46:	89 1c 24             	mov    %ebx,(%esp)
  800a49:	e8 0f fe ff ff       	call   80085d <fd_lookup>
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	78 66                	js     800ab8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a5c:	8b 00                	mov    (%eax),%eax
  800a5e:	89 04 24             	mov    %eax,(%esp)
  800a61:	e8 6b fe ff ff       	call   8008d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a66:	85 c0                	test   %eax,%eax
  800a68:	78 4e                	js     800ab8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a6d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800a71:	75 23                	jne    800a96 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a73:	a1 08 40 80 00       	mov    0x804008,%eax
  800a78:	8b 40 48             	mov    0x48(%eax),%eax
  800a7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a83:	c7 04 24 d9 27 80 00 	movl   $0x8027d9,(%esp)
  800a8a:	e8 be 0b 00 00       	call   80164d <cprintf>
  800a8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800a94:	eb 22                	jmp    800ab8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a99:	8b 48 0c             	mov    0xc(%eax),%ecx
  800a9c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800aa1:	85 c9                	test   %ecx,%ecx
  800aa3:	74 13                	je     800ab8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800aa5:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab3:	89 14 24             	mov    %edx,(%esp)
  800ab6:	ff d1                	call   *%ecx
}
  800ab8:	83 c4 24             	add    $0x24,%esp
  800abb:	5b                   	pop    %ebx
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	53                   	push   %ebx
  800ac2:	83 ec 24             	sub    $0x24,%esp
  800ac5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ac8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acf:	89 1c 24             	mov    %ebx,(%esp)
  800ad2:	e8 86 fd ff ff       	call   80085d <fd_lookup>
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	78 6b                	js     800b46 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae5:	8b 00                	mov    (%eax),%eax
  800ae7:	89 04 24             	mov    %eax,(%esp)
  800aea:	e8 e2 fd ff ff       	call   8008d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800aef:	85 c0                	test   %eax,%eax
  800af1:	78 53                	js     800b46 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800af6:	8b 42 08             	mov    0x8(%edx),%eax
  800af9:	83 e0 03             	and    $0x3,%eax
  800afc:	83 f8 01             	cmp    $0x1,%eax
  800aff:	75 23                	jne    800b24 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b01:	a1 08 40 80 00       	mov    0x804008,%eax
  800b06:	8b 40 48             	mov    0x48(%eax),%eax
  800b09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b11:	c7 04 24 f6 27 80 00 	movl   $0x8027f6,(%esp)
  800b18:	e8 30 0b 00 00       	call   80164d <cprintf>
  800b1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800b22:	eb 22                	jmp    800b46 <read+0x88>
	}
	if (!dev->dev_read)
  800b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b27:	8b 48 08             	mov    0x8(%eax),%ecx
  800b2a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b2f:	85 c9                	test   %ecx,%ecx
  800b31:	74 13                	je     800b46 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b33:	8b 45 10             	mov    0x10(%ebp),%eax
  800b36:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b41:	89 14 24             	mov    %edx,(%esp)
  800b44:	ff d1                	call   *%ecx
}
  800b46:	83 c4 24             	add    $0x24,%esp
  800b49:	5b                   	pop    %ebx
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	83 ec 1c             	sub    $0x1c,%esp
  800b55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b58:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6a:	85 f6                	test   %esi,%esi
  800b6c:	74 29                	je     800b97 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b6e:	89 f0                	mov    %esi,%eax
  800b70:	29 d0                	sub    %edx,%eax
  800b72:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b76:	03 55 0c             	add    0xc(%ebp),%edx
  800b79:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b7d:	89 3c 24             	mov    %edi,(%esp)
  800b80:	e8 39 ff ff ff       	call   800abe <read>
		if (m < 0)
  800b85:	85 c0                	test   %eax,%eax
  800b87:	78 0e                	js     800b97 <readn+0x4b>
			return m;
		if (m == 0)
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	74 08                	je     800b95 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b8d:	01 c3                	add    %eax,%ebx
  800b8f:	89 da                	mov    %ebx,%edx
  800b91:	39 f3                	cmp    %esi,%ebx
  800b93:	72 d9                	jb     800b6e <readn+0x22>
  800b95:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b97:	83 c4 1c             	add    $0x1c,%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 20             	sub    $0x20,%esp
  800ba7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800baa:	89 34 24             	mov    %esi,(%esp)
  800bad:	e8 0e fc ff ff       	call   8007c0 <fd2num>
  800bb2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bb9:	89 04 24             	mov    %eax,(%esp)
  800bbc:	e8 9c fc ff ff       	call   80085d <fd_lookup>
  800bc1:	89 c3                	mov    %eax,%ebx
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	78 05                	js     800bcc <fd_close+0x2d>
  800bc7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800bca:	74 0c                	je     800bd8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800bcc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800bd0:	19 c0                	sbb    %eax,%eax
  800bd2:	f7 d0                	not    %eax
  800bd4:	21 c3                	and    %eax,%ebx
  800bd6:	eb 3d                	jmp    800c15 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800bd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdf:	8b 06                	mov    (%esi),%eax
  800be1:	89 04 24             	mov    %eax,(%esp)
  800be4:	e8 e8 fc ff ff       	call   8008d1 <dev_lookup>
  800be9:	89 c3                	mov    %eax,%ebx
  800beb:	85 c0                	test   %eax,%eax
  800bed:	78 16                	js     800c05 <fd_close+0x66>
		if (dev->dev_close)
  800bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf2:	8b 40 10             	mov    0x10(%eax),%eax
  800bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	74 07                	je     800c05 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800bfe:	89 34 24             	mov    %esi,(%esp)
  800c01:	ff d0                	call   *%eax
  800c03:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800c05:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c10:	e8 35 f9 ff ff       	call   80054a <sys_page_unmap>
	return r;
}
  800c15:	89 d8                	mov    %ebx,%eax
  800c17:	83 c4 20             	add    $0x20,%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	89 04 24             	mov    %eax,(%esp)
  800c31:	e8 27 fc ff ff       	call   80085d <fd_lookup>
  800c36:	85 c0                	test   %eax,%eax
  800c38:	78 13                	js     800c4d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800c3a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800c41:	00 
  800c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c45:	89 04 24             	mov    %eax,(%esp)
  800c48:	e8 52 ff ff ff       	call   800b9f <fd_close>
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 18             	sub    $0x18,%esp
  800c55:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800c58:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c62:	00 
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	89 04 24             	mov    %eax,(%esp)
  800c69:	e8 79 03 00 00       	call   800fe7 <open>
  800c6e:	89 c3                	mov    %eax,%ebx
  800c70:	85 c0                	test   %eax,%eax
  800c72:	78 1b                	js     800c8f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800c74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7b:	89 1c 24             	mov    %ebx,(%esp)
  800c7e:	e8 b7 fc ff ff       	call   80093a <fstat>
  800c83:	89 c6                	mov    %eax,%esi
	close(fd);
  800c85:	89 1c 24             	mov    %ebx,(%esp)
  800c88:	e8 91 ff ff ff       	call   800c1e <close>
  800c8d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800c8f:	89 d8                	mov    %ebx,%eax
  800c91:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800c94:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800c97:	89 ec                	mov    %ebp,%esp
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 14             	sub    $0x14,%esp
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800ca7:	89 1c 24             	mov    %ebx,(%esp)
  800caa:	e8 6f ff ff ff       	call   800c1e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800caf:	83 c3 01             	add    $0x1,%ebx
  800cb2:	83 fb 20             	cmp    $0x20,%ebx
  800cb5:	75 f0                	jne    800ca7 <close_all+0xc>
		close(i);
}
  800cb7:	83 c4 14             	add    $0x14,%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	83 ec 58             	sub    $0x58,%esp
  800cc3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ccc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ccf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	89 04 24             	mov    %eax,(%esp)
  800cdc:	e8 7c fb ff ff       	call   80085d <fd_lookup>
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	0f 88 e0 00 00 00    	js     800dcb <dup+0x10e>
		return r;
	close(newfdnum);
  800ceb:	89 3c 24             	mov    %edi,(%esp)
  800cee:	e8 2b ff ff ff       	call   800c1e <close>

	newfd = INDEX2FD(newfdnum);
  800cf3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800cf9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800cfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cff:	89 04 24             	mov    %eax,(%esp)
  800d02:	e8 c9 fa ff ff       	call   8007d0 <fd2data>
  800d07:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800d09:	89 34 24             	mov    %esi,(%esp)
  800d0c:	e8 bf fa ff ff       	call   8007d0 <fd2data>
  800d11:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800d14:	89 da                	mov    %ebx,%edx
  800d16:	89 d8                	mov    %ebx,%eax
  800d18:	c1 e8 16             	shr    $0x16,%eax
  800d1b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d22:	a8 01                	test   $0x1,%al
  800d24:	74 43                	je     800d69 <dup+0xac>
  800d26:	c1 ea 0c             	shr    $0xc,%edx
  800d29:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d30:	a8 01                	test   $0x1,%al
  800d32:	74 35                	je     800d69 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800d34:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d3b:	25 07 0e 00 00       	and    $0xe07,%eax
  800d40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d44:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d52:	00 
  800d53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d5e:	e8 53 f8 ff ff       	call   8005b6 <sys_page_map>
  800d63:	89 c3                	mov    %eax,%ebx
  800d65:	85 c0                	test   %eax,%eax
  800d67:	78 3f                	js     800da8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d6c:	89 c2                	mov    %eax,%edx
  800d6e:	c1 ea 0c             	shr    $0xc,%edx
  800d71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d78:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d7e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d82:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d8d:	00 
  800d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d99:	e8 18 f8 ff ff       	call   8005b6 <sys_page_map>
  800d9e:	89 c3                	mov    %eax,%ebx
  800da0:	85 c0                	test   %eax,%eax
  800da2:	78 04                	js     800da8 <dup+0xeb>
  800da4:	89 fb                	mov    %edi,%ebx
  800da6:	eb 23                	jmp    800dcb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800da8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800db3:	e8 92 f7 ff ff       	call   80054a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800db8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dc6:	e8 7f f7 ff ff       	call   80054a <sys_page_unmap>
	return r;
}
  800dcb:	89 d8                	mov    %ebx,%eax
  800dcd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd6:	89 ec                	mov    %ebp,%esp
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    
	...

00800ddc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 18             	sub    $0x18,%esp
  800de2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800de5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800de8:	89 c3                	mov    %eax,%ebx
  800dea:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800dec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800df3:	75 11                	jne    800e06 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800df5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800dfc:	e8 6f 15 00 00       	call   802370 <ipc_find_env>
  800e01:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e06:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e15:	00 
  800e16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e1a:	a1 00 40 80 00       	mov    0x804000,%eax
  800e1f:	89 04 24             	mov    %eax,(%esp)
  800e22:	e8 94 15 00 00       	call   8023bb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e2e:	00 
  800e2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e3a:	e8 fa 15 00 00       	call   802439 <ipc_recv>
}
  800e3f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e42:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800e45:	89 ec                	mov    %ebp,%esp
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	8b 40 0c             	mov    0xc(%eax),%eax
  800e55:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e62:	ba 00 00 00 00       	mov    $0x0,%edx
  800e67:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6c:	e8 6b ff ff ff       	call   800ddc <fsipc>
}
  800e71:	c9                   	leave  
  800e72:	c3                   	ret    

00800e73 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	8b 40 0c             	mov    0xc(%eax),%eax
  800e7f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8e:	e8 49 ff ff ff       	call   800ddc <fsipc>
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea0:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea5:	e8 32 ff ff ff       	call   800ddc <fsipc>
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 14             	sub    $0x14,%esp
  800eb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	8b 40 0c             	mov    0xc(%eax),%eax
  800ebc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ec1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ecb:	e8 0c ff ff ff       	call   800ddc <fsipc>
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	78 2b                	js     800eff <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ed4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800edb:	00 
  800edc:	89 1c 24             	mov    %ebx,(%esp)
  800edf:	e8 96 10 00 00       	call   801f7a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ee4:	a1 80 50 80 00       	mov    0x805080,%eax
  800ee9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800eef:	a1 84 50 80 00       	mov    0x805084,%eax
  800ef4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800eff:	83 c4 14             	add    $0x14,%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 18             	sub    $0x18,%esp
  800f0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f13:	76 05                	jbe    800f1a <devfile_write+0x15>
  800f15:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1d:	8b 52 0c             	mov    0xc(%edx),%edx
  800f20:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800f26:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800f2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f36:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f3d:	e8 23 12 00 00       	call   802165 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800f42:	ba 00 00 00 00       	mov    $0x0,%edx
  800f47:	b8 04 00 00 00       	mov    $0x4,%eax
  800f4c:	e8 8b fe ff ff       	call   800ddc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	53                   	push   %ebx
  800f57:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800f60:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800f65:	8b 45 10             	mov    0x10(%ebp),%eax
  800f68:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  800f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f72:	b8 03 00 00 00       	mov    $0x3,%eax
  800f77:	e8 60 fe ff ff       	call   800ddc <fsipc>
  800f7c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 17                	js     800f99 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800f82:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f86:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800f8d:	00 
  800f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f91:	89 04 24             	mov    %eax,(%esp)
  800f94:	e8 cc 11 00 00       	call   802165 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800f99:	89 d8                	mov    %ebx,%eax
  800f9b:	83 c4 14             	add    $0x14,%esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 14             	sub    $0x14,%esp
  800fa8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800fab:	89 1c 24             	mov    %ebx,(%esp)
  800fae:	e8 7d 0f 00 00       	call   801f30 <strlen>
  800fb3:	89 c2                	mov    %eax,%edx
  800fb5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800fba:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800fc0:	7f 1f                	jg     800fe1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800fc2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fc6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800fcd:	e8 a8 0f 00 00       	call   801f7a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800fd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fdc:	e8 fb fd ff ff       	call   800ddc <fsipc>
}
  800fe1:	83 c4 14             	add    $0x14,%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 28             	sub    $0x28,%esp
  800fed:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ff0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800ff3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  800ff6:	89 34 24             	mov    %esi,(%esp)
  800ff9:	e8 32 0f 00 00       	call   801f30 <strlen>
  800ffe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801003:	3d 00 04 00 00       	cmp    $0x400,%eax
  801008:	7f 6d                	jg     801077 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80100a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	e8 d6 f7 ff ff       	call   8007eb <fd_alloc>
  801015:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801017:	85 c0                	test   %eax,%eax
  801019:	78 5c                	js     801077 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80101b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801023:	89 34 24             	mov    %esi,(%esp)
  801026:	e8 05 0f 00 00       	call   801f30 <strlen>
  80102b:	83 c0 01             	add    $0x1,%eax
  80102e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801032:	89 74 24 04          	mov    %esi,0x4(%esp)
  801036:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80103d:	e8 23 11 00 00       	call   802165 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801042:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801045:	b8 01 00 00 00       	mov    $0x1,%eax
  80104a:	e8 8d fd ff ff       	call   800ddc <fsipc>
  80104f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801051:	85 c0                	test   %eax,%eax
  801053:	79 15                	jns    80106a <open+0x83>
             fd_close(fd,0);
  801055:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80105c:	00 
  80105d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801060:	89 04 24             	mov    %eax,(%esp)
  801063:	e8 37 fb ff ff       	call   800b9f <fd_close>
             return r;
  801068:	eb 0d                	jmp    801077 <open+0x90>
        }
        return fd2num(fd);
  80106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106d:	89 04 24             	mov    %eax,(%esp)
  801070:	e8 4b f7 ff ff       	call   8007c0 <fd2num>
  801075:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801077:	89 d8                	mov    %ebx,%eax
  801079:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80107c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80107f:	89 ec                	mov    %ebp,%esp
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    
	...

00801090 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801096:	c7 44 24 04 20 28 80 	movl   $0x802820,0x4(%esp)
  80109d:	00 
  80109e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a1:	89 04 24             	mov    %eax,(%esp)
  8010a4:	e8 d1 0e 00 00       	call   801f7a <strcpy>
	return 0;
}
  8010a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 14             	sub    $0x14,%esp
  8010b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8010ba:	89 1c 24             	mov    %ebx,(%esp)
  8010bd:	e8 ea 13 00 00       	call   8024ac <pageref>
  8010c2:	89 c2                	mov    %eax,%edx
  8010c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c9:	83 fa 01             	cmp    $0x1,%edx
  8010cc:	75 0b                	jne    8010d9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8010ce:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010d1:	89 04 24             	mov    %eax,(%esp)
  8010d4:	e8 b9 02 00 00       	call   801392 <nsipc_close>
	else
		return 0;
}
  8010d9:	83 c4 14             	add    $0x14,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8010e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010ec:	00 
  8010ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801101:	89 04 24             	mov    %eax,(%esp)
  801104:	e8 c5 02 00 00       	call   8013ce <nsipc_send>
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801118:	00 
  801119:	8b 45 10             	mov    0x10(%ebp),%eax
  80111c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801120:	8b 45 0c             	mov    0xc(%ebp),%eax
  801123:	89 44 24 04          	mov    %eax,0x4(%esp)
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
  80112a:	8b 40 0c             	mov    0xc(%eax),%eax
  80112d:	89 04 24             	mov    %eax,(%esp)
  801130:	e8 0c 03 00 00       	call   801441 <nsipc_recv>
}
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 20             	sub    $0x20,%esp
  80113f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801144:	89 04 24             	mov    %eax,(%esp)
  801147:	e8 9f f6 ff ff       	call   8007eb <fd_alloc>
  80114c:	89 c3                	mov    %eax,%ebx
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 21                	js     801173 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801152:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801159:	00 
  80115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801168:	e8 b7 f4 ff ff       	call   800624 <sys_page_alloc>
  80116d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80116f:	85 c0                	test   %eax,%eax
  801171:	79 0a                	jns    80117d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801173:	89 34 24             	mov    %esi,(%esp)
  801176:	e8 17 02 00 00       	call   801392 <nsipc_close>
		return r;
  80117b:	eb 28                	jmp    8011a5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80117d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801183:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801186:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801195:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119b:	89 04 24             	mov    %eax,(%esp)
  80119e:	e8 1d f6 ff ff       	call   8007c0 <fd2num>
  8011a3:	89 c3                	mov    %eax,%ebx
}
  8011a5:	89 d8                	mov    %ebx,%eax
  8011a7:	83 c4 20             	add    $0x20,%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8011b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 79 01 00 00       	call   801346 <nsipc_socket>
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 05                	js     8011d6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8011d1:	e8 61 ff ff ff       	call   801137 <alloc_sockfd>
}
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8011de:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011e5:	89 04 24             	mov    %eax,(%esp)
  8011e8:	e8 70 f6 ff ff       	call   80085d <fd_lookup>
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 15                	js     801206 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8011f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f4:	8b 0a                	mov    (%edx),%ecx
  8011f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011fb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801201:	75 03                	jne    801206 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801203:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80120e:	8b 45 08             	mov    0x8(%ebp),%eax
  801211:	e8 c2 ff ff ff       	call   8011d8 <fd2sockid>
  801216:	85 c0                	test   %eax,%eax
  801218:	78 0f                	js     801229 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80121a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801221:	89 04 24             	mov    %eax,(%esp)
  801224:	e8 47 01 00 00       	call   801370 <nsipc_listen>
}
  801229:	c9                   	leave  
  80122a:	c3                   	ret    

0080122b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801231:	8b 45 08             	mov    0x8(%ebp),%eax
  801234:	e8 9f ff ff ff       	call   8011d8 <fd2sockid>
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 16                	js     801253 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80123d:	8b 55 10             	mov    0x10(%ebp),%edx
  801240:	89 54 24 08          	mov    %edx,0x8(%esp)
  801244:	8b 55 0c             	mov    0xc(%ebp),%edx
  801247:	89 54 24 04          	mov    %edx,0x4(%esp)
  80124b:	89 04 24             	mov    %eax,(%esp)
  80124e:	e8 6e 02 00 00       	call   8014c1 <nsipc_connect>
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	e8 75 ff ff ff       	call   8011d8 <fd2sockid>
  801263:	85 c0                	test   %eax,%eax
  801265:	78 0f                	js     801276 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80126e:	89 04 24             	mov    %eax,(%esp)
  801271:	e8 36 01 00 00       	call   8013ac <nsipc_shutdown>
}
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	e8 52 ff ff ff       	call   8011d8 <fd2sockid>
  801286:	85 c0                	test   %eax,%eax
  801288:	78 16                	js     8012a0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80128a:	8b 55 10             	mov    0x10(%ebp),%edx
  80128d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801291:	8b 55 0c             	mov    0xc(%ebp),%edx
  801294:	89 54 24 04          	mov    %edx,0x4(%esp)
  801298:	89 04 24             	mov    %eax,(%esp)
  80129b:	e8 60 02 00 00       	call   801500 <nsipc_bind>
}
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ab:	e8 28 ff ff ff       	call   8011d8 <fd2sockid>
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 1f                	js     8012d3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8012b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8012b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c2:	89 04 24             	mov    %eax,(%esp)
  8012c5:	e8 75 02 00 00       	call   80153f <nsipc_accept>
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 05                	js     8012d3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8012ce:	e8 64 fe ff ff       	call   801137 <alloc_sockfd>
}
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    
	...

008012e0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 14             	sub    $0x14,%esp
  8012e7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8012e9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8012f0:	75 11                	jne    801303 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8012f2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8012f9:	e8 72 10 00 00       	call   802370 <ipc_find_env>
  8012fe:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801303:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80130a:	00 
  80130b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801312:	00 
  801313:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801317:	a1 04 40 80 00       	mov    0x804004,%eax
  80131c:	89 04 24             	mov    %eax,(%esp)
  80131f:	e8 97 10 00 00       	call   8023bb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801324:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80132b:	00 
  80132c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801333:	00 
  801334:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133b:	e8 f9 10 00 00       	call   802439 <ipc_recv>
}
  801340:	83 c4 14             	add    $0x14,%esp
  801343:	5b                   	pop    %ebx
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80134c:	8b 45 08             	mov    0x8(%ebp),%eax
  80134f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801354:	8b 45 0c             	mov    0xc(%ebp),%eax
  801357:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80135c:	8b 45 10             	mov    0x10(%ebp),%eax
  80135f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801364:	b8 09 00 00 00       	mov    $0x9,%eax
  801369:	e8 72 ff ff ff       	call   8012e0 <nsipc>
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
  801379:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80137e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801381:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801386:	b8 06 00 00 00       	mov    $0x6,%eax
  80138b:	e8 50 ff ff ff       	call   8012e0 <nsipc>
}
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801398:	8b 45 08             	mov    0x8(%ebp),%eax
  80139b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8013a0:	b8 04 00 00 00       	mov    $0x4,%eax
  8013a5:	e8 36 ff ff ff       	call   8012e0 <nsipc>
}
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8013ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8013c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8013c7:	e8 14 ff ff ff       	call   8012e0 <nsipc>
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 14             	sub    $0x14,%esp
  8013d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8013e0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8013e6:	7e 24                	jle    80140c <nsipc_send+0x3e>
  8013e8:	c7 44 24 0c 2c 28 80 	movl   $0x80282c,0xc(%esp)
  8013ef:	00 
  8013f0:	c7 44 24 08 38 28 80 	movl   $0x802838,0x8(%esp)
  8013f7:	00 
  8013f8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8013ff:	00 
  801400:	c7 04 24 4d 28 80 00 	movl   $0x80284d,(%esp)
  801407:	e8 88 01 00 00       	call   801594 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80140c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801410:	8b 45 0c             	mov    0xc(%ebp),%eax
  801413:	89 44 24 04          	mov    %eax,0x4(%esp)
  801417:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80141e:	e8 42 0d 00 00       	call   802165 <memmove>
	nsipcbuf.send.req_size = size;
  801423:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801429:	8b 45 14             	mov    0x14(%ebp),%eax
  80142c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801431:	b8 08 00 00 00       	mov    $0x8,%eax
  801436:	e8 a5 fe ff ff       	call   8012e0 <nsipc>
}
  80143b:	83 c4 14             	add    $0x14,%esp
  80143e:	5b                   	pop    %ebx
  80143f:	5d                   	pop    %ebp
  801440:	c3                   	ret    

00801441 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	83 ec 10             	sub    $0x10,%esp
  801449:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801454:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80145a:	8b 45 14             	mov    0x14(%ebp),%eax
  80145d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801462:	b8 07 00 00 00       	mov    $0x7,%eax
  801467:	e8 74 fe ff ff       	call   8012e0 <nsipc>
  80146c:	89 c3                	mov    %eax,%ebx
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 46                	js     8014b8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801472:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801477:	7f 04                	jg     80147d <nsipc_recv+0x3c>
  801479:	39 c6                	cmp    %eax,%esi
  80147b:	7d 24                	jge    8014a1 <nsipc_recv+0x60>
  80147d:	c7 44 24 0c 59 28 80 	movl   $0x802859,0xc(%esp)
  801484:	00 
  801485:	c7 44 24 08 38 28 80 	movl   $0x802838,0x8(%esp)
  80148c:	00 
  80148d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801494:	00 
  801495:	c7 04 24 4d 28 80 00 	movl   $0x80284d,(%esp)
  80149c:	e8 f3 00 00 00       	call   801594 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8014a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8014ac:	00 
  8014ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b0:	89 04 24             	mov    %eax,(%esp)
  8014b3:	e8 ad 0c 00 00       	call   802165 <memmove>
	}

	return r;
}
  8014b8:	89 d8                	mov    %ebx,%eax
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	5b                   	pop    %ebx
  8014be:	5e                   	pop    %esi
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 14             	sub    $0x14,%esp
  8014c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8014cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ce:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8014d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014de:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8014e5:	e8 7b 0c 00 00       	call   802165 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8014ea:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8014f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f5:	e8 e6 fd ff ff       	call   8012e0 <nsipc>
}
  8014fa:	83 c4 14             	add    $0x14,%esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	53                   	push   %ebx
  801504:	83 ec 14             	sub    $0x14,%esp
  801507:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80150a:	8b 45 08             	mov    0x8(%ebp),%eax
  80150d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801512:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801516:	8b 45 0c             	mov    0xc(%ebp),%eax
  801519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801524:	e8 3c 0c 00 00       	call   802165 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801529:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80152f:	b8 02 00 00 00       	mov    $0x2,%eax
  801534:	e8 a7 fd ff ff       	call   8012e0 <nsipc>
}
  801539:	83 c4 14             	add    $0x14,%esp
  80153c:	5b                   	pop    %ebx
  80153d:	5d                   	pop    %ebp
  80153e:	c3                   	ret    

0080153f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 18             	sub    $0x18,%esp
  801545:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801548:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80154b:	8b 45 08             	mov    0x8(%ebp),%eax
  80154e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801553:	b8 01 00 00 00       	mov    $0x1,%eax
  801558:	e8 83 fd ff ff       	call   8012e0 <nsipc>
  80155d:	89 c3                	mov    %eax,%ebx
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 25                	js     801588 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801563:	be 10 60 80 00       	mov    $0x806010,%esi
  801568:	8b 06                	mov    (%esi),%eax
  80156a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80156e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801575:	00 
  801576:	8b 45 0c             	mov    0xc(%ebp),%eax
  801579:	89 04 24             	mov    %eax,(%esp)
  80157c:	e8 e4 0b 00 00       	call   802165 <memmove>
		*addrlen = ret->ret_addrlen;
  801581:	8b 16                	mov    (%esi),%edx
  801583:	8b 45 10             	mov    0x10(%ebp),%eax
  801586:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80158d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801590:	89 ec                	mov    %ebp,%esp
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	56                   	push   %esi
  801598:	53                   	push   %ebx
  801599:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80159c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80159f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8015a5:	e8 69 f1 ff ff       	call   800713 <sys_getenvid>
  8015aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c0:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  8015c7:	e8 81 00 00 00       	call   80164d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d3:	89 04 24             	mov    %eax,(%esp)
  8015d6:	e8 11 00 00 00       	call   8015ec <vcprintf>
	cprintf("\n");
  8015db:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  8015e2:	e8 66 00 00 00       	call   80164d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015e7:	cc                   	int3   
  8015e8:	eb fd                	jmp    8015e7 <_panic+0x53>
	...

008015ec <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8015f5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015fc:	00 00 00 
	b.cnt = 0;
  8015ff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801606:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801609:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	89 44 24 08          	mov    %eax,0x8(%esp)
  801617:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80161d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801621:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  801628:	e8 cf 01 00 00       	call   8017fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80162d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801633:	89 44 24 04          	mov    %eax,0x4(%esp)
  801637:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80163d:	89 04 24             	mov    %eax,(%esp)
  801640:	e8 e3 ea ff ff       	call   800128 <sys_cputs>

	return b.cnt;
}
  801645:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801653:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	89 04 24             	mov    %eax,(%esp)
  801660:	e8 87 ff ff ff       	call   8015ec <vcprintf>
	va_end(ap);

	return cnt;
}
  801665:	c9                   	leave  
  801666:	c3                   	ret    

00801667 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	53                   	push   %ebx
  80166b:	83 ec 14             	sub    $0x14,%esp
  80166e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801671:	8b 03                	mov    (%ebx),%eax
  801673:	8b 55 08             	mov    0x8(%ebp),%edx
  801676:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80167a:	83 c0 01             	add    $0x1,%eax
  80167d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80167f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801684:	75 19                	jne    80169f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801686:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80168d:	00 
  80168e:	8d 43 08             	lea    0x8(%ebx),%eax
  801691:	89 04 24             	mov    %eax,(%esp)
  801694:	e8 8f ea ff ff       	call   800128 <sys_cputs>
		b->idx = 0;
  801699:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80169f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016a3:	83 c4 14             	add    $0x14,%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    
  8016a9:	00 00                	add    %al,(%eax)
  8016ab:	00 00                	add    %al,(%eax)
  8016ad:	00 00                	add    %al,(%eax)
	...

008016b0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	57                   	push   %edi
  8016b4:	56                   	push   %esi
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 4c             	sub    $0x4c,%esp
  8016b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016bc:	89 d6                	mov    %edx,%esi
  8016be:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8016ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8016cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8016d0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8016d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016db:	39 d1                	cmp    %edx,%ecx
  8016dd:	72 07                	jb     8016e6 <printnum_v2+0x36>
  8016df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016e2:	39 d0                	cmp    %edx,%eax
  8016e4:	77 5f                	ja     801745 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8016e6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8016ea:	83 eb 01             	sub    $0x1,%ebx
  8016ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8016f9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8016fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801700:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801703:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801706:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80170a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801711:	00 
  801712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801715:	89 04 24             	mov    %eax,(%esp)
  801718:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80171b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80171f:	e8 cc 0d 00 00       	call   8024f0 <__udivdi3>
  801724:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801727:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80172a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80172e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801732:	89 04 24             	mov    %eax,(%esp)
  801735:	89 54 24 04          	mov    %edx,0x4(%esp)
  801739:	89 f2                	mov    %esi,%edx
  80173b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173e:	e8 6d ff ff ff       	call   8016b0 <printnum_v2>
  801743:	eb 1e                	jmp    801763 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801745:	83 ff 2d             	cmp    $0x2d,%edi
  801748:	74 19                	je     801763 <printnum_v2+0xb3>
		while (--width > 0)
  80174a:	83 eb 01             	sub    $0x1,%ebx
  80174d:	85 db                	test   %ebx,%ebx
  80174f:	90                   	nop
  801750:	7e 11                	jle    801763 <printnum_v2+0xb3>
			putch(padc, putdat);
  801752:	89 74 24 04          	mov    %esi,0x4(%esp)
  801756:	89 3c 24             	mov    %edi,(%esp)
  801759:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80175c:	83 eb 01             	sub    $0x1,%ebx
  80175f:	85 db                	test   %ebx,%ebx
  801761:	7f ef                	jg     801752 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801763:	89 74 24 04          	mov    %esi,0x4(%esp)
  801767:	8b 74 24 04          	mov    0x4(%esp),%esi
  80176b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80176e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801772:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801779:	00 
  80177a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80177d:	89 14 24             	mov    %edx,(%esp)
  801780:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801783:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801787:	e8 94 0e 00 00       	call   802620 <__umoddi3>
  80178c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801790:	0f be 80 93 28 80 00 	movsbl 0x802893(%eax),%eax
  801797:	89 04 24             	mov    %eax,(%esp)
  80179a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80179d:	83 c4 4c             	add    $0x4c,%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5f                   	pop    %edi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017a8:	83 fa 01             	cmp    $0x1,%edx
  8017ab:	7e 0e                	jle    8017bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017ad:	8b 10                	mov    (%eax),%edx
  8017af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017b2:	89 08                	mov    %ecx,(%eax)
  8017b4:	8b 02                	mov    (%edx),%eax
  8017b6:	8b 52 04             	mov    0x4(%edx),%edx
  8017b9:	eb 22                	jmp    8017dd <getuint+0x38>
	else if (lflag)
  8017bb:	85 d2                	test   %edx,%edx
  8017bd:	74 10                	je     8017cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017bf:	8b 10                	mov    (%eax),%edx
  8017c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017c4:	89 08                	mov    %ecx,(%eax)
  8017c6:	8b 02                	mov    (%edx),%eax
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	eb 0e                	jmp    8017dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017cf:	8b 10                	mov    (%eax),%edx
  8017d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017d4:	89 08                	mov    %ecx,(%eax)
  8017d6:	8b 02                	mov    (%edx),%eax
  8017d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017e9:	8b 10                	mov    (%eax),%edx
  8017eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8017ee:	73 0a                	jae    8017fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8017f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f3:	88 0a                	mov    %cl,(%edx)
  8017f5:	83 c2 01             	add    $0x1,%edx
  8017f8:	89 10                	mov    %edx,(%eax)
}
  8017fa:	5d                   	pop    %ebp
  8017fb:	c3                   	ret    

008017fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	57                   	push   %edi
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	83 ec 6c             	sub    $0x6c,%esp
  801805:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801808:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80180f:	eb 1a                	jmp    80182b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801811:	85 c0                	test   %eax,%eax
  801813:	0f 84 66 06 00 00    	je     801e7f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  801819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801820:	89 04 24             	mov    %eax,(%esp)
  801823:	ff 55 08             	call   *0x8(%ebp)
  801826:	eb 03                	jmp    80182b <vprintfmt+0x2f>
  801828:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80182b:	0f b6 07             	movzbl (%edi),%eax
  80182e:	83 c7 01             	add    $0x1,%edi
  801831:	83 f8 25             	cmp    $0x25,%eax
  801834:	75 db                	jne    801811 <vprintfmt+0x15>
  801836:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80183a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80183f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801846:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80184b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801852:	be 00 00 00 00       	mov    $0x0,%esi
  801857:	eb 06                	jmp    80185f <vprintfmt+0x63>
  801859:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80185d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185f:	0f b6 17             	movzbl (%edi),%edx
  801862:	0f b6 c2             	movzbl %dl,%eax
  801865:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801868:	8d 47 01             	lea    0x1(%edi),%eax
  80186b:	83 ea 23             	sub    $0x23,%edx
  80186e:	80 fa 55             	cmp    $0x55,%dl
  801871:	0f 87 60 05 00 00    	ja     801dd7 <vprintfmt+0x5db>
  801877:	0f b6 d2             	movzbl %dl,%edx
  80187a:	ff 24 95 80 2a 80 00 	jmp    *0x802a80(,%edx,4)
  801881:	b9 01 00 00 00       	mov    $0x1,%ecx
  801886:	eb d5                	jmp    80185d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801888:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80188b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80188e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801891:	8d 7a d0             	lea    -0x30(%edx),%edi
  801894:	83 ff 09             	cmp    $0x9,%edi
  801897:	76 08                	jbe    8018a1 <vprintfmt+0xa5>
  801899:	eb 40                	jmp    8018db <vprintfmt+0xdf>
  80189b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80189f:	eb bc                	jmp    80185d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018a1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8018a4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8018a7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8018ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8018ae:	8d 7a d0             	lea    -0x30(%edx),%edi
  8018b1:	83 ff 09             	cmp    $0x9,%edi
  8018b4:	76 eb                	jbe    8018a1 <vprintfmt+0xa5>
  8018b6:	eb 23                	jmp    8018db <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8018bb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8018be:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8018c1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8018c3:	eb 16                	jmp    8018db <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8018c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018c8:	c1 fa 1f             	sar    $0x1f,%edx
  8018cb:	f7 d2                	not    %edx
  8018cd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8018d0:	eb 8b                	jmp    80185d <vprintfmt+0x61>
  8018d2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8018d9:	eb 82                	jmp    80185d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8018db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018df:	0f 89 78 ff ff ff    	jns    80185d <vprintfmt+0x61>
  8018e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8018e8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8018eb:	e9 6d ff ff ff       	jmp    80185d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018f0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8018f3:	e9 65 ff ff ff       	jmp    80185d <vprintfmt+0x61>
  8018f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fe:	8d 50 04             	lea    0x4(%eax),%edx
  801901:	89 55 14             	mov    %edx,0x14(%ebp)
  801904:	8b 55 0c             	mov    0xc(%ebp),%edx
  801907:	89 54 24 04          	mov    %edx,0x4(%esp)
  80190b:	8b 00                	mov    (%eax),%eax
  80190d:	89 04 24             	mov    %eax,(%esp)
  801910:	ff 55 08             	call   *0x8(%ebp)
  801913:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801916:	e9 10 ff ff ff       	jmp    80182b <vprintfmt+0x2f>
  80191b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80191e:	8b 45 14             	mov    0x14(%ebp),%eax
  801921:	8d 50 04             	lea    0x4(%eax),%edx
  801924:	89 55 14             	mov    %edx,0x14(%ebp)
  801927:	8b 00                	mov    (%eax),%eax
  801929:	89 c2                	mov    %eax,%edx
  80192b:	c1 fa 1f             	sar    $0x1f,%edx
  80192e:	31 d0                	xor    %edx,%eax
  801930:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801932:	83 f8 0f             	cmp    $0xf,%eax
  801935:	7f 0b                	jg     801942 <vprintfmt+0x146>
  801937:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  80193e:	85 d2                	test   %edx,%edx
  801940:	75 26                	jne    801968 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801942:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801946:	c7 44 24 08 a4 28 80 	movl   $0x8028a4,0x8(%esp)
  80194d:	00 
  80194e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801951:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801958:	89 1c 24             	mov    %ebx,(%esp)
  80195b:	e8 a7 05 00 00       	call   801f07 <printfmt>
  801960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801963:	e9 c3 fe ff ff       	jmp    80182b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801968:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80196c:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  801973:	00 
  801974:	8b 45 0c             	mov    0xc(%ebp),%eax
  801977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197b:	8b 55 08             	mov    0x8(%ebp),%edx
  80197e:	89 14 24             	mov    %edx,(%esp)
  801981:	e8 81 05 00 00       	call   801f07 <printfmt>
  801986:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801989:	e9 9d fe ff ff       	jmp    80182b <vprintfmt+0x2f>
  80198e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801991:	89 c7                	mov    %eax,%edi
  801993:	89 d9                	mov    %ebx,%ecx
  801995:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801998:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80199b:	8b 45 14             	mov    0x14(%ebp),%eax
  80199e:	8d 50 04             	lea    0x4(%eax),%edx
  8019a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a4:	8b 30                	mov    (%eax),%esi
  8019a6:	85 f6                	test   %esi,%esi
  8019a8:	75 05                	jne    8019af <vprintfmt+0x1b3>
  8019aa:	be ad 28 80 00       	mov    $0x8028ad,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8019af:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8019b3:	7e 06                	jle    8019bb <vprintfmt+0x1bf>
  8019b5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8019b9:	75 10                	jne    8019cb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019bb:	0f be 06             	movsbl (%esi),%eax
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	0f 85 a2 00 00 00    	jne    801a68 <vprintfmt+0x26c>
  8019c6:	e9 92 00 00 00       	jmp    801a5d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019cf:	89 34 24             	mov    %esi,(%esp)
  8019d2:	e8 74 05 00 00       	call   801f4b <strnlen>
  8019d7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8019da:	29 c2                	sub    %eax,%edx
  8019dc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8019df:	85 d2                	test   %edx,%edx
  8019e1:	7e d8                	jle    8019bb <vprintfmt+0x1bf>
					putch(padc, putdat);
  8019e3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8019e7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8019ea:	89 d3                	mov    %edx,%ebx
  8019ec:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8019ef:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8019f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019f5:	89 ce                	mov    %ecx,%esi
  8019f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019fb:	89 34 24             	mov    %esi,(%esp)
  8019fe:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a01:	83 eb 01             	sub    $0x1,%ebx
  801a04:	85 db                	test   %ebx,%ebx
  801a06:	7f ef                	jg     8019f7 <vprintfmt+0x1fb>
  801a08:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  801a0b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801a0e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  801a11:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801a18:	eb a1                	jmp    8019bb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a1a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801a1e:	74 1b                	je     801a3b <vprintfmt+0x23f>
  801a20:	8d 50 e0             	lea    -0x20(%eax),%edx
  801a23:	83 fa 5e             	cmp    $0x5e,%edx
  801a26:	76 13                	jbe    801a3b <vprintfmt+0x23f>
					putch('?', putdat);
  801a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801a36:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a39:	eb 0d                	jmp    801a48 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a42:	89 04 24             	mov    %eax,(%esp)
  801a45:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a48:	83 ef 01             	sub    $0x1,%edi
  801a4b:	0f be 06             	movsbl (%esi),%eax
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	74 05                	je     801a57 <vprintfmt+0x25b>
  801a52:	83 c6 01             	add    $0x1,%esi
  801a55:	eb 1a                	jmp    801a71 <vprintfmt+0x275>
  801a57:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a5a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a5d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a61:	7f 1f                	jg     801a82 <vprintfmt+0x286>
  801a63:	e9 c0 fd ff ff       	jmp    801828 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a68:	83 c6 01             	add    $0x1,%esi
  801a6b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801a6e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801a71:	85 db                	test   %ebx,%ebx
  801a73:	78 a5                	js     801a1a <vprintfmt+0x21e>
  801a75:	83 eb 01             	sub    $0x1,%ebx
  801a78:	79 a0                	jns    801a1a <vprintfmt+0x21e>
  801a7a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a7d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801a80:	eb db                	jmp    801a5d <vprintfmt+0x261>
  801a82:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a88:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a92:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a99:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a9b:	83 eb 01             	sub    $0x1,%ebx
  801a9e:	85 db                	test   %ebx,%ebx
  801aa0:	7f ec                	jg     801a8e <vprintfmt+0x292>
  801aa2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801aa5:	e9 81 fd ff ff       	jmp    80182b <vprintfmt+0x2f>
  801aaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801aad:	83 fe 01             	cmp    $0x1,%esi
  801ab0:	7e 10                	jle    801ac2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab5:	8d 50 08             	lea    0x8(%eax),%edx
  801ab8:	89 55 14             	mov    %edx,0x14(%ebp)
  801abb:	8b 18                	mov    (%eax),%ebx
  801abd:	8b 70 04             	mov    0x4(%eax),%esi
  801ac0:	eb 26                	jmp    801ae8 <vprintfmt+0x2ec>
	else if (lflag)
  801ac2:	85 f6                	test   %esi,%esi
  801ac4:	74 12                	je     801ad8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801ac6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac9:	8d 50 04             	lea    0x4(%eax),%edx
  801acc:	89 55 14             	mov    %edx,0x14(%ebp)
  801acf:	8b 18                	mov    (%eax),%ebx
  801ad1:	89 de                	mov    %ebx,%esi
  801ad3:	c1 fe 1f             	sar    $0x1f,%esi
  801ad6:	eb 10                	jmp    801ae8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801ad8:	8b 45 14             	mov    0x14(%ebp),%eax
  801adb:	8d 50 04             	lea    0x4(%eax),%edx
  801ade:	89 55 14             	mov    %edx,0x14(%ebp)
  801ae1:	8b 18                	mov    (%eax),%ebx
  801ae3:	89 de                	mov    %ebx,%esi
  801ae5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  801ae8:	83 f9 01             	cmp    $0x1,%ecx
  801aeb:	75 1e                	jne    801b0b <vprintfmt+0x30f>
                               if((long long)num > 0){
  801aed:	85 f6                	test   %esi,%esi
  801aef:	78 1a                	js     801b0b <vprintfmt+0x30f>
  801af1:	85 f6                	test   %esi,%esi
  801af3:	7f 05                	jg     801afa <vprintfmt+0x2fe>
  801af5:	83 fb 00             	cmp    $0x0,%ebx
  801af8:	76 11                	jbe    801b0b <vprintfmt+0x30f>
                                   putch('+',putdat);
  801afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b01:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  801b08:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  801b0b:	85 f6                	test   %esi,%esi
  801b0d:	78 13                	js     801b22 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b0f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  801b12:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  801b15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b18:	b8 0a 00 00 00       	mov    $0xa,%eax
  801b1d:	e9 da 00 00 00       	jmp    801bfc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  801b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b29:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801b30:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801b33:	89 da                	mov    %ebx,%edx
  801b35:	89 f1                	mov    %esi,%ecx
  801b37:	f7 da                	neg    %edx
  801b39:	83 d1 00             	adc    $0x0,%ecx
  801b3c:	f7 d9                	neg    %ecx
  801b3e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801b41:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801b44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b47:	b8 0a 00 00 00       	mov    $0xa,%eax
  801b4c:	e9 ab 00 00 00       	jmp    801bfc <vprintfmt+0x400>
  801b51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b54:	89 f2                	mov    %esi,%edx
  801b56:	8d 45 14             	lea    0x14(%ebp),%eax
  801b59:	e8 47 fc ff ff       	call   8017a5 <getuint>
  801b5e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801b61:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801b64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b67:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  801b6c:	e9 8b 00 00 00       	jmp    801bfc <vprintfmt+0x400>
  801b71:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b77:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b7b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b82:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801b85:	89 f2                	mov    %esi,%edx
  801b87:	8d 45 14             	lea    0x14(%ebp),%eax
  801b8a:	e8 16 fc ff ff       	call   8017a5 <getuint>
  801b8f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801b92:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801b95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b98:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  801b9d:	eb 5d                	jmp    801bfc <vprintfmt+0x400>
  801b9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801ba2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ba5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801bb0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801bb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bb7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801bbe:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801bc1:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc4:	8d 50 04             	lea    0x4(%eax),%edx
  801bc7:	89 55 14             	mov    %edx,0x14(%ebp)
  801bca:	8b 10                	mov    (%eax),%edx
  801bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801bd1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801bd4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801bd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bda:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801bdf:	eb 1b                	jmp    801bfc <vprintfmt+0x400>
  801be1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801be4:	89 f2                	mov    %esi,%edx
  801be6:	8d 45 14             	lea    0x14(%ebp),%eax
  801be9:	e8 b7 fb ff ff       	call   8017a5 <getuint>
  801bee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801bf1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801bf4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bf7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bfc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  801c00:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c03:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801c06:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  801c0a:	77 09                	ja     801c15 <vprintfmt+0x419>
  801c0c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  801c0f:	0f 82 ac 00 00 00    	jb     801cc1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801c15:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801c18:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801c1c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801c1f:	83 ea 01             	sub    $0x1,%edx
  801c22:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c26:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c2a:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c2e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801c32:	89 45 c0             	mov    %eax,-0x40(%ebp)
  801c35:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801c38:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801c3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c3f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c46:	00 
  801c47:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801c4a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801c4d:	89 0c 24             	mov    %ecx,(%esp)
  801c50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c54:	e8 97 08 00 00       	call   8024f0 <__udivdi3>
  801c59:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  801c5c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801c5f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c63:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c67:	89 04 24             	mov    %eax,(%esp)
  801c6a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c71:	8b 45 08             	mov    0x8(%ebp),%eax
  801c74:	e8 37 fa ff ff       	call   8016b0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c80:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c84:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801c87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c8b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c92:	00 
  801c93:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801c96:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801c99:	89 14 24             	mov    %edx,(%esp)
  801c9c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ca0:	e8 7b 09 00 00       	call   802620 <__umoddi3>
  801ca5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca9:	0f be 80 93 28 80 00 	movsbl 0x802893(%eax),%eax
  801cb0:	89 04 24             	mov    %eax,(%esp)
  801cb3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801cb6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801cba:	74 54                	je     801d10 <vprintfmt+0x514>
  801cbc:	e9 67 fb ff ff       	jmp    801828 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801cc1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	0f 84 2a 01 00 00    	je     801df8 <vprintfmt+0x5fc>
		while (--width > 0)
  801cce:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801cd1:	83 ef 01             	sub    $0x1,%edi
  801cd4:	85 ff                	test   %edi,%edi
  801cd6:	0f 8e 5e 01 00 00    	jle    801e3a <vprintfmt+0x63e>
  801cdc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801cdf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801ce2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801ce5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801ce8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801ceb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  801cee:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cf2:	89 1c 24             	mov    %ebx,(%esp)
  801cf5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  801cf8:	83 ef 01             	sub    $0x1,%edi
  801cfb:	85 ff                	test   %edi,%edi
  801cfd:	7f ef                	jg     801cee <vprintfmt+0x4f2>
  801cff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d02:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801d05:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801d08:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801d0b:	e9 2a 01 00 00       	jmp    801e3a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801d10:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801d13:	83 eb 01             	sub    $0x1,%ebx
  801d16:	85 db                	test   %ebx,%ebx
  801d18:	0f 8e 0a fb ff ff    	jle    801828 <vprintfmt+0x2c>
  801d1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d21:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801d24:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  801d27:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801d32:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801d34:	83 eb 01             	sub    $0x1,%ebx
  801d37:	85 db                	test   %ebx,%ebx
  801d39:	7f ec                	jg     801d27 <vprintfmt+0x52b>
  801d3b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801d3e:	e9 e8 fa ff ff       	jmp    80182b <vprintfmt+0x2f>
  801d43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801d46:	8b 45 14             	mov    0x14(%ebp),%eax
  801d49:	8d 50 04             	lea    0x4(%eax),%edx
  801d4c:	89 55 14             	mov    %edx,0x14(%ebp)
  801d4f:	8b 00                	mov    (%eax),%eax
  801d51:	85 c0                	test   %eax,%eax
  801d53:	75 2a                	jne    801d7f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801d55:	c7 44 24 0c c8 29 80 	movl   $0x8029c8,0xc(%esp)
  801d5c:	00 
  801d5d:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  801d64:	00 
  801d65:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d68:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6f:	89 0c 24             	mov    %ecx,(%esp)
  801d72:	e8 90 01 00 00       	call   801f07 <printfmt>
  801d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d7a:	e9 ac fa ff ff       	jmp    80182b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  801d7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d82:	8b 13                	mov    (%ebx),%edx
  801d84:	83 fa 7f             	cmp    $0x7f,%edx
  801d87:	7e 29                	jle    801db2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801d89:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  801d8b:	c7 44 24 0c 00 2a 80 	movl   $0x802a00,0xc(%esp)
  801d92:	00 
  801d93:	c7 44 24 08 4a 28 80 	movl   $0x80284a,0x8(%esp)
  801d9a:	00 
  801d9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801da2:	89 04 24             	mov    %eax,(%esp)
  801da5:	e8 5d 01 00 00       	call   801f07 <printfmt>
  801daa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dad:	e9 79 fa ff ff       	jmp    80182b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801db2:	88 10                	mov    %dl,(%eax)
  801db4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801db7:	e9 6f fa ff ff       	jmp    80182b <vprintfmt+0x2f>
  801dbc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801dbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801dc9:	89 14 24             	mov    %edx,(%esp)
  801dcc:	ff 55 08             	call   *0x8(%ebp)
  801dcf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801dd2:	e9 54 fa ff ff       	jmp    80182b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801dd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dde:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801de5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801de8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801deb:	80 38 25             	cmpb   $0x25,(%eax)
  801dee:	0f 84 37 fa ff ff    	je     80182b <vprintfmt+0x2f>
  801df4:	89 c7                	mov    %eax,%edi
  801df6:	eb f0                	jmp    801de8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dff:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e03:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801e06:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e11:	00 
  801e12:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801e15:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801e18:	89 04 24             	mov    %eax,(%esp)
  801e1b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e1f:	e8 fc 07 00 00       	call   802620 <__umoddi3>
  801e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e28:	0f be 80 93 28 80 00 	movsbl 0x802893(%eax),%eax
  801e2f:	89 04 24             	mov    %eax,(%esp)
  801e32:	ff 55 08             	call   *0x8(%ebp)
  801e35:	e9 d6 fe ff ff       	jmp    801d10 <vprintfmt+0x514>
  801e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e41:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e45:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e4c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e53:	00 
  801e54:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801e57:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801e5a:	89 04 24             	mov    %eax,(%esp)
  801e5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e61:	e8 ba 07 00 00       	call   802620 <__umoddi3>
  801e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e6a:	0f be 80 93 28 80 00 	movsbl 0x802893(%eax),%eax
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	ff 55 08             	call   *0x8(%ebp)
  801e77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e7a:	e9 ac f9 ff ff       	jmp    80182b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801e7f:	83 c4 6c             	add    $0x6c,%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5f                   	pop    %edi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 28             	sub    $0x28,%esp
  801e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e90:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801e93:	85 c0                	test   %eax,%eax
  801e95:	74 04                	je     801e9b <vsnprintf+0x14>
  801e97:	85 d2                	test   %edx,%edx
  801e99:	7f 07                	jg     801ea2 <vsnprintf+0x1b>
  801e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ea0:	eb 3b                	jmp    801edd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ea2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ea5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801eac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801eb3:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eba:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec8:	c7 04 24 df 17 80 00 	movl   $0x8017df,(%esp)
  801ecf:	e8 28 f9 ff ff       	call   8017fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ed7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801ee5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801ee8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eec:	8b 45 10             	mov    0x10(%ebp),%eax
  801eef:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efa:	8b 45 08             	mov    0x8(%ebp),%eax
  801efd:	89 04 24             	mov    %eax,(%esp)
  801f00:	e8 82 ff ff ff       	call   801e87 <vsnprintf>
	va_end(ap);

	return rc;
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801f0d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801f10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f14:	8b 45 10             	mov    0x10(%ebp),%eax
  801f17:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	89 04 24             	mov    %eax,(%esp)
  801f28:	e8 cf f8 ff ff       	call   8017fc <vprintfmt>
	va_end(ap);
}
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    
	...

00801f30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801f36:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3b:	80 3a 00             	cmpb   $0x0,(%edx)
  801f3e:	74 09                	je     801f49 <strlen+0x19>
		n++;
  801f40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801f43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801f47:	75 f7                	jne    801f40 <strlen+0x10>
		n++;
	return n;
}
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	53                   	push   %ebx
  801f4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801f55:	85 c9                	test   %ecx,%ecx
  801f57:	74 19                	je     801f72 <strnlen+0x27>
  801f59:	80 3b 00             	cmpb   $0x0,(%ebx)
  801f5c:	74 14                	je     801f72 <strnlen+0x27>
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801f63:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801f66:	39 c8                	cmp    %ecx,%eax
  801f68:	74 0d                	je     801f77 <strnlen+0x2c>
  801f6a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801f6e:	75 f3                	jne    801f63 <strnlen+0x18>
  801f70:	eb 05                	jmp    801f77 <strnlen+0x2c>
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801f77:	5b                   	pop    %ebx
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	53                   	push   %ebx
  801f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f84:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801f89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801f8d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801f90:	83 c2 01             	add    $0x1,%edx
  801f93:	84 c9                	test   %cl,%cl
  801f95:	75 f2                	jne    801f89 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801f97:	5b                   	pop    %ebx
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	53                   	push   %ebx
  801f9e:	83 ec 08             	sub    $0x8,%esp
  801fa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801fa4:	89 1c 24             	mov    %ebx,(%esp)
  801fa7:	e8 84 ff ff ff       	call   801f30 <strlen>
	strcpy(dst + len, src);
  801fac:	8b 55 0c             	mov    0xc(%ebp),%edx
  801faf:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fb3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801fb6:	89 04 24             	mov    %eax,(%esp)
  801fb9:	e8 bc ff ff ff       	call   801f7a <strcpy>
	return dst;
}
  801fbe:	89 d8                	mov    %ebx,%eax
  801fc0:	83 c4 08             	add    $0x8,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    

00801fc6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	56                   	push   %esi
  801fca:	53                   	push   %ebx
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801fd4:	85 f6                	test   %esi,%esi
  801fd6:	74 18                	je     801ff0 <strncpy+0x2a>
  801fd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801fdd:	0f b6 1a             	movzbl (%edx),%ebx
  801fe0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801fe3:	80 3a 01             	cmpb   $0x1,(%edx)
  801fe6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801fe9:	83 c1 01             	add    $0x1,%ecx
  801fec:	39 ce                	cmp    %ecx,%esi
  801fee:	77 ed                	ja     801fdd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ff0:	5b                   	pop    %ebx
  801ff1:	5e                   	pop    %esi
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    

00801ff4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	56                   	push   %esi
  801ff8:	53                   	push   %ebx
  801ff9:	8b 75 08             	mov    0x8(%ebp),%esi
  801ffc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802002:	89 f0                	mov    %esi,%eax
  802004:	85 c9                	test   %ecx,%ecx
  802006:	74 27                	je     80202f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  802008:	83 e9 01             	sub    $0x1,%ecx
  80200b:	74 1d                	je     80202a <strlcpy+0x36>
  80200d:	0f b6 1a             	movzbl (%edx),%ebx
  802010:	84 db                	test   %bl,%bl
  802012:	74 16                	je     80202a <strlcpy+0x36>
			*dst++ = *src++;
  802014:	88 18                	mov    %bl,(%eax)
  802016:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802019:	83 e9 01             	sub    $0x1,%ecx
  80201c:	74 0e                	je     80202c <strlcpy+0x38>
			*dst++ = *src++;
  80201e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802021:	0f b6 1a             	movzbl (%edx),%ebx
  802024:	84 db                	test   %bl,%bl
  802026:	75 ec                	jne    802014 <strlcpy+0x20>
  802028:	eb 02                	jmp    80202c <strlcpy+0x38>
  80202a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80202c:	c6 00 00             	movb   $0x0,(%eax)
  80202f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    

00802035 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80203b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80203e:	0f b6 01             	movzbl (%ecx),%eax
  802041:	84 c0                	test   %al,%al
  802043:	74 15                	je     80205a <strcmp+0x25>
  802045:	3a 02                	cmp    (%edx),%al
  802047:	75 11                	jne    80205a <strcmp+0x25>
		p++, q++;
  802049:	83 c1 01             	add    $0x1,%ecx
  80204c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80204f:	0f b6 01             	movzbl (%ecx),%eax
  802052:	84 c0                	test   %al,%al
  802054:	74 04                	je     80205a <strcmp+0x25>
  802056:	3a 02                	cmp    (%edx),%al
  802058:	74 ef                	je     802049 <strcmp+0x14>
  80205a:	0f b6 c0             	movzbl %al,%eax
  80205d:	0f b6 12             	movzbl (%edx),%edx
  802060:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    

00802064 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	53                   	push   %ebx
  802068:	8b 55 08             	mov    0x8(%ebp),%edx
  80206b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80206e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  802071:	85 c0                	test   %eax,%eax
  802073:	74 23                	je     802098 <strncmp+0x34>
  802075:	0f b6 1a             	movzbl (%edx),%ebx
  802078:	84 db                	test   %bl,%bl
  80207a:	74 25                	je     8020a1 <strncmp+0x3d>
  80207c:	3a 19                	cmp    (%ecx),%bl
  80207e:	75 21                	jne    8020a1 <strncmp+0x3d>
  802080:	83 e8 01             	sub    $0x1,%eax
  802083:	74 13                	je     802098 <strncmp+0x34>
		n--, p++, q++;
  802085:	83 c2 01             	add    $0x1,%edx
  802088:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80208b:	0f b6 1a             	movzbl (%edx),%ebx
  80208e:	84 db                	test   %bl,%bl
  802090:	74 0f                	je     8020a1 <strncmp+0x3d>
  802092:	3a 19                	cmp    (%ecx),%bl
  802094:	74 ea                	je     802080 <strncmp+0x1c>
  802096:	eb 09                	jmp    8020a1 <strncmp+0x3d>
  802098:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80209d:	5b                   	pop    %ebx
  80209e:	5d                   	pop    %ebp
  80209f:	90                   	nop
  8020a0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020a1:	0f b6 02             	movzbl (%edx),%eax
  8020a4:	0f b6 11             	movzbl (%ecx),%edx
  8020a7:	29 d0                	sub    %edx,%eax
  8020a9:	eb f2                	jmp    80209d <strncmp+0x39>

008020ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020b5:	0f b6 10             	movzbl (%eax),%edx
  8020b8:	84 d2                	test   %dl,%dl
  8020ba:	74 18                	je     8020d4 <strchr+0x29>
		if (*s == c)
  8020bc:	38 ca                	cmp    %cl,%dl
  8020be:	75 0a                	jne    8020ca <strchr+0x1f>
  8020c0:	eb 17                	jmp    8020d9 <strchr+0x2e>
  8020c2:	38 ca                	cmp    %cl,%dl
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	74 0f                	je     8020d9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8020ca:	83 c0 01             	add    $0x1,%eax
  8020cd:	0f b6 10             	movzbl (%eax),%edx
  8020d0:	84 d2                	test   %dl,%dl
  8020d2:	75 ee                	jne    8020c2 <strchr+0x17>
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8020d9:	5d                   	pop    %ebp
  8020da:	c3                   	ret    

008020db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020e5:	0f b6 10             	movzbl (%eax),%edx
  8020e8:	84 d2                	test   %dl,%dl
  8020ea:	74 18                	je     802104 <strfind+0x29>
		if (*s == c)
  8020ec:	38 ca                	cmp    %cl,%dl
  8020ee:	75 0a                	jne    8020fa <strfind+0x1f>
  8020f0:	eb 12                	jmp    802104 <strfind+0x29>
  8020f2:	38 ca                	cmp    %cl,%dl
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	74 0a                	je     802104 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8020fa:	83 c0 01             	add    $0x1,%eax
  8020fd:	0f b6 10             	movzbl (%eax),%edx
  802100:	84 d2                	test   %dl,%dl
  802102:	75 ee                	jne    8020f2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  802104:	5d                   	pop    %ebp
  802105:	c3                   	ret    

00802106 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	83 ec 0c             	sub    $0xc,%esp
  80210c:	89 1c 24             	mov    %ebx,(%esp)
  80210f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802113:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802117:	8b 7d 08             	mov    0x8(%ebp),%edi
  80211a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802120:	85 c9                	test   %ecx,%ecx
  802122:	74 30                	je     802154 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802124:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80212a:	75 25                	jne    802151 <memset+0x4b>
  80212c:	f6 c1 03             	test   $0x3,%cl
  80212f:	75 20                	jne    802151 <memset+0x4b>
		c &= 0xFF;
  802131:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802134:	89 d3                	mov    %edx,%ebx
  802136:	c1 e3 08             	shl    $0x8,%ebx
  802139:	89 d6                	mov    %edx,%esi
  80213b:	c1 e6 18             	shl    $0x18,%esi
  80213e:	89 d0                	mov    %edx,%eax
  802140:	c1 e0 10             	shl    $0x10,%eax
  802143:	09 f0                	or     %esi,%eax
  802145:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  802147:	09 d8                	or     %ebx,%eax
  802149:	c1 e9 02             	shr    $0x2,%ecx
  80214c:	fc                   	cld    
  80214d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80214f:	eb 03                	jmp    802154 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802151:	fc                   	cld    
  802152:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802154:	89 f8                	mov    %edi,%eax
  802156:	8b 1c 24             	mov    (%esp),%ebx
  802159:	8b 74 24 04          	mov    0x4(%esp),%esi
  80215d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802161:	89 ec                	mov    %ebp,%esp
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    

00802165 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	83 ec 08             	sub    $0x8,%esp
  80216b:	89 34 24             	mov    %esi,(%esp)
  80216e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802172:	8b 45 08             	mov    0x8(%ebp),%eax
  802175:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  802178:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80217b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80217d:	39 c6                	cmp    %eax,%esi
  80217f:	73 35                	jae    8021b6 <memmove+0x51>
  802181:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802184:	39 d0                	cmp    %edx,%eax
  802186:	73 2e                	jae    8021b6 <memmove+0x51>
		s += n;
		d += n;
  802188:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80218a:	f6 c2 03             	test   $0x3,%dl
  80218d:	75 1b                	jne    8021aa <memmove+0x45>
  80218f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802195:	75 13                	jne    8021aa <memmove+0x45>
  802197:	f6 c1 03             	test   $0x3,%cl
  80219a:	75 0e                	jne    8021aa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80219c:	83 ef 04             	sub    $0x4,%edi
  80219f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021a2:	c1 e9 02             	shr    $0x2,%ecx
  8021a5:	fd                   	std    
  8021a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021a8:	eb 09                	jmp    8021b3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021aa:	83 ef 01             	sub    $0x1,%edi
  8021ad:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021b0:	fd                   	std    
  8021b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021b3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021b4:	eb 20                	jmp    8021d6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8021bc:	75 15                	jne    8021d3 <memmove+0x6e>
  8021be:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8021c4:	75 0d                	jne    8021d3 <memmove+0x6e>
  8021c6:	f6 c1 03             	test   $0x3,%cl
  8021c9:	75 08                	jne    8021d3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8021cb:	c1 e9 02             	shr    $0x2,%ecx
  8021ce:	fc                   	cld    
  8021cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021d1:	eb 03                	jmp    8021d6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021d3:	fc                   	cld    
  8021d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021d6:	8b 34 24             	mov    (%esp),%esi
  8021d9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021dd:	89 ec                	mov    %ebp,%esp
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8021e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f8:	89 04 24             	mov    %eax,(%esp)
  8021fb:	e8 65 ff ff ff       	call   802165 <memmove>
}
  802200:	c9                   	leave  
  802201:	c3                   	ret    

00802202 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	57                   	push   %edi
  802206:	56                   	push   %esi
  802207:	53                   	push   %ebx
  802208:	8b 75 08             	mov    0x8(%ebp),%esi
  80220b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80220e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802211:	85 c9                	test   %ecx,%ecx
  802213:	74 36                	je     80224b <memcmp+0x49>
		if (*s1 != *s2)
  802215:	0f b6 06             	movzbl (%esi),%eax
  802218:	0f b6 1f             	movzbl (%edi),%ebx
  80221b:	38 d8                	cmp    %bl,%al
  80221d:	74 20                	je     80223f <memcmp+0x3d>
  80221f:	eb 14                	jmp    802235 <memcmp+0x33>
  802221:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  802226:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80222b:	83 c2 01             	add    $0x1,%edx
  80222e:	83 e9 01             	sub    $0x1,%ecx
  802231:	38 d8                	cmp    %bl,%al
  802233:	74 12                	je     802247 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  802235:	0f b6 c0             	movzbl %al,%eax
  802238:	0f b6 db             	movzbl %bl,%ebx
  80223b:	29 d8                	sub    %ebx,%eax
  80223d:	eb 11                	jmp    802250 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80223f:	83 e9 01             	sub    $0x1,%ecx
  802242:	ba 00 00 00 00       	mov    $0x0,%edx
  802247:	85 c9                	test   %ecx,%ecx
  802249:	75 d6                	jne    802221 <memcmp+0x1f>
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    

00802255 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80225b:	89 c2                	mov    %eax,%edx
  80225d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802260:	39 d0                	cmp    %edx,%eax
  802262:	73 15                	jae    802279 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802264:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  802268:	38 08                	cmp    %cl,(%eax)
  80226a:	75 06                	jne    802272 <memfind+0x1d>
  80226c:	eb 0b                	jmp    802279 <memfind+0x24>
  80226e:	38 08                	cmp    %cl,(%eax)
  802270:	74 07                	je     802279 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802272:	83 c0 01             	add    $0x1,%eax
  802275:	39 c2                	cmp    %eax,%edx
  802277:	77 f5                	ja     80226e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    

0080227b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	57                   	push   %edi
  80227f:	56                   	push   %esi
  802280:	53                   	push   %ebx
  802281:	83 ec 04             	sub    $0x4,%esp
  802284:	8b 55 08             	mov    0x8(%ebp),%edx
  802287:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80228a:	0f b6 02             	movzbl (%edx),%eax
  80228d:	3c 20                	cmp    $0x20,%al
  80228f:	74 04                	je     802295 <strtol+0x1a>
  802291:	3c 09                	cmp    $0x9,%al
  802293:	75 0e                	jne    8022a3 <strtol+0x28>
		s++;
  802295:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802298:	0f b6 02             	movzbl (%edx),%eax
  80229b:	3c 20                	cmp    $0x20,%al
  80229d:	74 f6                	je     802295 <strtol+0x1a>
  80229f:	3c 09                	cmp    $0x9,%al
  8022a1:	74 f2                	je     802295 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8022a3:	3c 2b                	cmp    $0x2b,%al
  8022a5:	75 0c                	jne    8022b3 <strtol+0x38>
		s++;
  8022a7:	83 c2 01             	add    $0x1,%edx
  8022aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8022b1:	eb 15                	jmp    8022c8 <strtol+0x4d>
	else if (*s == '-')
  8022b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8022ba:	3c 2d                	cmp    $0x2d,%al
  8022bc:	75 0a                	jne    8022c8 <strtol+0x4d>
		s++, neg = 1;
  8022be:	83 c2 01             	add    $0x1,%edx
  8022c1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022c8:	85 db                	test   %ebx,%ebx
  8022ca:	0f 94 c0             	sete   %al
  8022cd:	74 05                	je     8022d4 <strtol+0x59>
  8022cf:	83 fb 10             	cmp    $0x10,%ebx
  8022d2:	75 18                	jne    8022ec <strtol+0x71>
  8022d4:	80 3a 30             	cmpb   $0x30,(%edx)
  8022d7:	75 13                	jne    8022ec <strtol+0x71>
  8022d9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	75 0a                	jne    8022ec <strtol+0x71>
		s += 2, base = 16;
  8022e2:	83 c2 02             	add    $0x2,%edx
  8022e5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022ea:	eb 15                	jmp    802301 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022ec:	84 c0                	test   %al,%al
  8022ee:	66 90                	xchg   %ax,%ax
  8022f0:	74 0f                	je     802301 <strtol+0x86>
  8022f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8022f7:	80 3a 30             	cmpb   $0x30,(%edx)
  8022fa:	75 05                	jne    802301 <strtol+0x86>
		s++, base = 8;
  8022fc:	83 c2 01             	add    $0x1,%edx
  8022ff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802301:	b8 00 00 00 00       	mov    $0x0,%eax
  802306:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802308:	0f b6 0a             	movzbl (%edx),%ecx
  80230b:	89 cf                	mov    %ecx,%edi
  80230d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802310:	80 fb 09             	cmp    $0x9,%bl
  802313:	77 08                	ja     80231d <strtol+0xa2>
			dig = *s - '0';
  802315:	0f be c9             	movsbl %cl,%ecx
  802318:	83 e9 30             	sub    $0x30,%ecx
  80231b:	eb 1e                	jmp    80233b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80231d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  802320:	80 fb 19             	cmp    $0x19,%bl
  802323:	77 08                	ja     80232d <strtol+0xb2>
			dig = *s - 'a' + 10;
  802325:	0f be c9             	movsbl %cl,%ecx
  802328:	83 e9 57             	sub    $0x57,%ecx
  80232b:	eb 0e                	jmp    80233b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80232d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  802330:	80 fb 19             	cmp    $0x19,%bl
  802333:	77 15                	ja     80234a <strtol+0xcf>
			dig = *s - 'A' + 10;
  802335:	0f be c9             	movsbl %cl,%ecx
  802338:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80233b:	39 f1                	cmp    %esi,%ecx
  80233d:	7d 0b                	jge    80234a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80233f:	83 c2 01             	add    $0x1,%edx
  802342:	0f af c6             	imul   %esi,%eax
  802345:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  802348:	eb be                	jmp    802308 <strtol+0x8d>
  80234a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80234c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802350:	74 05                	je     802357 <strtol+0xdc>
		*endptr = (char *) s;
  802352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802355:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802357:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80235b:	74 04                	je     802361 <strtol+0xe6>
  80235d:	89 c8                	mov    %ecx,%eax
  80235f:	f7 d8                	neg    %eax
}
  802361:	83 c4 04             	add    $0x4,%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5f                   	pop    %edi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    
  802369:	00 00                	add    %al,(%eax)
  80236b:	00 00                	add    %al,(%eax)
  80236d:	00 00                	add    %al,(%eax)
	...

00802370 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802376:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80237c:	b8 01 00 00 00       	mov    $0x1,%eax
  802381:	39 ca                	cmp    %ecx,%edx
  802383:	75 04                	jne    802389 <ipc_find_env+0x19>
  802385:	b0 00                	mov    $0x0,%al
  802387:	eb 12                	jmp    80239b <ipc_find_env+0x2b>
  802389:	89 c2                	mov    %eax,%edx
  80238b:	c1 e2 07             	shl    $0x7,%edx
  80238e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802395:	8b 12                	mov    (%edx),%edx
  802397:	39 ca                	cmp    %ecx,%edx
  802399:	75 10                	jne    8023ab <ipc_find_env+0x3b>
			return envs[i].env_id;
  80239b:	89 c2                	mov    %eax,%edx
  80239d:	c1 e2 07             	shl    $0x7,%edx
  8023a0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  8023a7:	8b 00                	mov    (%eax),%eax
  8023a9:	eb 0e                	jmp    8023b9 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023ab:	83 c0 01             	add    $0x1,%eax
  8023ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023b3:	75 d4                	jne    802389 <ipc_find_env+0x19>
  8023b5:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8023b9:	5d                   	pop    %ebp
  8023ba:	c3                   	ret    

008023bb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
  8023be:	57                   	push   %edi
  8023bf:	56                   	push   %esi
  8023c0:	53                   	push   %ebx
  8023c1:	83 ec 1c             	sub    $0x1c,%esp
  8023c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8023c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8023cd:	85 db                	test   %ebx,%ebx
  8023cf:	74 19                	je     8023ea <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8023d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8023d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023e0:	89 34 24             	mov    %esi,(%esp)
  8023e3:	e8 dd df ff ff       	call   8003c5 <sys_ipc_try_send>
  8023e8:	eb 1b                	jmp    802405 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8023ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8023ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023f1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8023f8:	ee 
  8023f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023fd:	89 34 24             	mov    %esi,(%esp)
  802400:	e8 c0 df ff ff       	call   8003c5 <sys_ipc_try_send>
           if(ret == 0)
  802405:	85 c0                	test   %eax,%eax
  802407:	74 28                	je     802431 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802409:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80240c:	74 1c                	je     80242a <ipc_send+0x6f>
              panic("ipc send error");
  80240e:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  802415:	00 
  802416:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80241d:	00 
  80241e:	c7 04 24 2f 2c 80 00 	movl   $0x802c2f,(%esp)
  802425:	e8 6a f1 ff ff       	call   801594 <_panic>
           sys_yield();
  80242a:	e8 62 e2 ff ff       	call   800691 <sys_yield>
        }
  80242f:	eb 9c                	jmp    8023cd <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802431:	83 c4 1c             	add    $0x1c,%esp
  802434:	5b                   	pop    %ebx
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    

00802439 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802439:	55                   	push   %ebp
  80243a:	89 e5                	mov    %esp,%ebp
  80243c:	56                   	push   %esi
  80243d:	53                   	push   %ebx
  80243e:	83 ec 10             	sub    $0x10,%esp
  802441:	8b 75 08             	mov    0x8(%ebp),%esi
  802444:	8b 45 0c             	mov    0xc(%ebp),%eax
  802447:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80244a:	85 c0                	test   %eax,%eax
  80244c:	75 0e                	jne    80245c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80244e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802455:	e8 00 df ff ff       	call   80035a <sys_ipc_recv>
  80245a:	eb 08                	jmp    802464 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80245c:	89 04 24             	mov    %eax,(%esp)
  80245f:	e8 f6 de ff ff       	call   80035a <sys_ipc_recv>
        if(ret == 0){
  802464:	85 c0                	test   %eax,%eax
  802466:	75 26                	jne    80248e <ipc_recv+0x55>
           if(from_env_store)
  802468:	85 f6                	test   %esi,%esi
  80246a:	74 0a                	je     802476 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80246c:	a1 08 40 80 00       	mov    0x804008,%eax
  802471:	8b 40 78             	mov    0x78(%eax),%eax
  802474:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802476:	85 db                	test   %ebx,%ebx
  802478:	74 0a                	je     802484 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80247a:	a1 08 40 80 00       	mov    0x804008,%eax
  80247f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802482:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802484:	a1 08 40 80 00       	mov    0x804008,%eax
  802489:	8b 40 74             	mov    0x74(%eax),%eax
  80248c:	eb 14                	jmp    8024a2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80248e:	85 f6                	test   %esi,%esi
  802490:	74 06                	je     802498 <ipc_recv+0x5f>
              *from_env_store = 0;
  802492:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802498:	85 db                	test   %ebx,%ebx
  80249a:	74 06                	je     8024a2 <ipc_recv+0x69>
              *perm_store = 0;
  80249c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  8024a2:	83 c4 10             	add    $0x10,%esp
  8024a5:	5b                   	pop    %ebx
  8024a6:	5e                   	pop    %esi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	00 00                	add    %al,(%eax)
	...

008024ac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024ac:	55                   	push   %ebp
  8024ad:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8024af:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b2:	89 c2                	mov    %eax,%edx
  8024b4:	c1 ea 16             	shr    $0x16,%edx
  8024b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024be:	f6 c2 01             	test   $0x1,%dl
  8024c1:	74 20                	je     8024e3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8024c3:	c1 e8 0c             	shr    $0xc,%eax
  8024c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024cd:	a8 01                	test   $0x1,%al
  8024cf:	74 12                	je     8024e3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024d1:	c1 e8 0c             	shr    $0xc,%eax
  8024d4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8024d9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8024de:	0f b7 c0             	movzwl %ax,%eax
  8024e1:	eb 05                	jmp    8024e8 <pageref+0x3c>
  8024e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024e8:	5d                   	pop    %ebp
  8024e9:	c3                   	ret    
  8024ea:	00 00                	add    %al,(%eax)
  8024ec:	00 00                	add    %al,(%eax)
	...

008024f0 <__udivdi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	57                   	push   %edi
  8024f4:	56                   	push   %esi
  8024f5:	83 ec 10             	sub    $0x10,%esp
  8024f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8024fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8024fe:	8b 75 10             	mov    0x10(%ebp),%esi
  802501:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802504:	85 c0                	test   %eax,%eax
  802506:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802509:	75 35                	jne    802540 <__udivdi3+0x50>
  80250b:	39 fe                	cmp    %edi,%esi
  80250d:	77 61                	ja     802570 <__udivdi3+0x80>
  80250f:	85 f6                	test   %esi,%esi
  802511:	75 0b                	jne    80251e <__udivdi3+0x2e>
  802513:	b8 01 00 00 00       	mov    $0x1,%eax
  802518:	31 d2                	xor    %edx,%edx
  80251a:	f7 f6                	div    %esi
  80251c:	89 c6                	mov    %eax,%esi
  80251e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802521:	31 d2                	xor    %edx,%edx
  802523:	89 f8                	mov    %edi,%eax
  802525:	f7 f6                	div    %esi
  802527:	89 c7                	mov    %eax,%edi
  802529:	89 c8                	mov    %ecx,%eax
  80252b:	f7 f6                	div    %esi
  80252d:	89 c1                	mov    %eax,%ecx
  80252f:	89 fa                	mov    %edi,%edx
  802531:	89 c8                	mov    %ecx,%eax
  802533:	83 c4 10             	add    $0x10,%esp
  802536:	5e                   	pop    %esi
  802537:	5f                   	pop    %edi
  802538:	5d                   	pop    %ebp
  802539:	c3                   	ret    
  80253a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802540:	39 f8                	cmp    %edi,%eax
  802542:	77 1c                	ja     802560 <__udivdi3+0x70>
  802544:	0f bd d0             	bsr    %eax,%edx
  802547:	83 f2 1f             	xor    $0x1f,%edx
  80254a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80254d:	75 39                	jne    802588 <__udivdi3+0x98>
  80254f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802552:	0f 86 a0 00 00 00    	jbe    8025f8 <__udivdi3+0x108>
  802558:	39 f8                	cmp    %edi,%eax
  80255a:	0f 82 98 00 00 00    	jb     8025f8 <__udivdi3+0x108>
  802560:	31 ff                	xor    %edi,%edi
  802562:	31 c9                	xor    %ecx,%ecx
  802564:	89 c8                	mov    %ecx,%eax
  802566:	89 fa                	mov    %edi,%edx
  802568:	83 c4 10             	add    $0x10,%esp
  80256b:	5e                   	pop    %esi
  80256c:	5f                   	pop    %edi
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    
  80256f:	90                   	nop
  802570:	89 d1                	mov    %edx,%ecx
  802572:	89 fa                	mov    %edi,%edx
  802574:	89 c8                	mov    %ecx,%eax
  802576:	31 ff                	xor    %edi,%edi
  802578:	f7 f6                	div    %esi
  80257a:	89 c1                	mov    %eax,%ecx
  80257c:	89 fa                	mov    %edi,%edx
  80257e:	89 c8                	mov    %ecx,%eax
  802580:	83 c4 10             	add    $0x10,%esp
  802583:	5e                   	pop    %esi
  802584:	5f                   	pop    %edi
  802585:	5d                   	pop    %ebp
  802586:	c3                   	ret    
  802587:	90                   	nop
  802588:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80258c:	89 f2                	mov    %esi,%edx
  80258e:	d3 e0                	shl    %cl,%eax
  802590:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802593:	b8 20 00 00 00       	mov    $0x20,%eax
  802598:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80259b:	89 c1                	mov    %eax,%ecx
  80259d:	d3 ea                	shr    %cl,%edx
  80259f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8025a6:	d3 e6                	shl    %cl,%esi
  8025a8:	89 c1                	mov    %eax,%ecx
  8025aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8025ad:	89 fe                	mov    %edi,%esi
  8025af:	d3 ee                	shr    %cl,%esi
  8025b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025bb:	d3 e7                	shl    %cl,%edi
  8025bd:	89 c1                	mov    %eax,%ecx
  8025bf:	d3 ea                	shr    %cl,%edx
  8025c1:	09 d7                	or     %edx,%edi
  8025c3:	89 f2                	mov    %esi,%edx
  8025c5:	89 f8                	mov    %edi,%eax
  8025c7:	f7 75 ec             	divl   -0x14(%ebp)
  8025ca:	89 d6                	mov    %edx,%esi
  8025cc:	89 c7                	mov    %eax,%edi
  8025ce:	f7 65 e8             	mull   -0x18(%ebp)
  8025d1:	39 d6                	cmp    %edx,%esi
  8025d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025d6:	72 30                	jb     802608 <__udivdi3+0x118>
  8025d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025df:	d3 e2                	shl    %cl,%edx
  8025e1:	39 c2                	cmp    %eax,%edx
  8025e3:	73 05                	jae    8025ea <__udivdi3+0xfa>
  8025e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8025e8:	74 1e                	je     802608 <__udivdi3+0x118>
  8025ea:	89 f9                	mov    %edi,%ecx
  8025ec:	31 ff                	xor    %edi,%edi
  8025ee:	e9 71 ff ff ff       	jmp    802564 <__udivdi3+0x74>
  8025f3:	90                   	nop
  8025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	31 ff                	xor    %edi,%edi
  8025fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8025ff:	e9 60 ff ff ff       	jmp    802564 <__udivdi3+0x74>
  802604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802608:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80260b:	31 ff                	xor    %edi,%edi
  80260d:	89 c8                	mov    %ecx,%eax
  80260f:	89 fa                	mov    %edi,%edx
  802611:	83 c4 10             	add    $0x10,%esp
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
	...

00802620 <__umoddi3>:
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	57                   	push   %edi
  802624:	56                   	push   %esi
  802625:	83 ec 20             	sub    $0x20,%esp
  802628:	8b 55 14             	mov    0x14(%ebp),%edx
  80262b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80262e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802631:	8b 75 0c             	mov    0xc(%ebp),%esi
  802634:	85 d2                	test   %edx,%edx
  802636:	89 c8                	mov    %ecx,%eax
  802638:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80263b:	75 13                	jne    802650 <__umoddi3+0x30>
  80263d:	39 f7                	cmp    %esi,%edi
  80263f:	76 3f                	jbe    802680 <__umoddi3+0x60>
  802641:	89 f2                	mov    %esi,%edx
  802643:	f7 f7                	div    %edi
  802645:	89 d0                	mov    %edx,%eax
  802647:	31 d2                	xor    %edx,%edx
  802649:	83 c4 20             	add    $0x20,%esp
  80264c:	5e                   	pop    %esi
  80264d:	5f                   	pop    %edi
  80264e:	5d                   	pop    %ebp
  80264f:	c3                   	ret    
  802650:	39 f2                	cmp    %esi,%edx
  802652:	77 4c                	ja     8026a0 <__umoddi3+0x80>
  802654:	0f bd ca             	bsr    %edx,%ecx
  802657:	83 f1 1f             	xor    $0x1f,%ecx
  80265a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80265d:	75 51                	jne    8026b0 <__umoddi3+0x90>
  80265f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802662:	0f 87 e0 00 00 00    	ja     802748 <__umoddi3+0x128>
  802668:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80266b:	29 f8                	sub    %edi,%eax
  80266d:	19 d6                	sbb    %edx,%esi
  80266f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802675:	89 f2                	mov    %esi,%edx
  802677:	83 c4 20             	add    $0x20,%esp
  80267a:	5e                   	pop    %esi
  80267b:	5f                   	pop    %edi
  80267c:	5d                   	pop    %ebp
  80267d:	c3                   	ret    
  80267e:	66 90                	xchg   %ax,%ax
  802680:	85 ff                	test   %edi,%edi
  802682:	75 0b                	jne    80268f <__umoddi3+0x6f>
  802684:	b8 01 00 00 00       	mov    $0x1,%eax
  802689:	31 d2                	xor    %edx,%edx
  80268b:	f7 f7                	div    %edi
  80268d:	89 c7                	mov    %eax,%edi
  80268f:	89 f0                	mov    %esi,%eax
  802691:	31 d2                	xor    %edx,%edx
  802693:	f7 f7                	div    %edi
  802695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802698:	f7 f7                	div    %edi
  80269a:	eb a9                	jmp    802645 <__umoddi3+0x25>
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 c8                	mov    %ecx,%eax
  8026a2:	89 f2                	mov    %esi,%edx
  8026a4:	83 c4 20             	add    $0x20,%esp
  8026a7:	5e                   	pop    %esi
  8026a8:	5f                   	pop    %edi
  8026a9:	5d                   	pop    %ebp
  8026aa:	c3                   	ret    
  8026ab:	90                   	nop
  8026ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026b4:	d3 e2                	shl    %cl,%edx
  8026b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8026be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8026c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026c8:	89 fa                	mov    %edi,%edx
  8026ca:	d3 ea                	shr    %cl,%edx
  8026cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8026d3:	d3 e7                	shl    %cl,%edi
  8026d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026dc:	89 f2                	mov    %esi,%edx
  8026de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8026e1:	89 c7                	mov    %eax,%edi
  8026e3:	d3 ea                	shr    %cl,%edx
  8026e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026ec:	89 c2                	mov    %eax,%edx
  8026ee:	d3 e6                	shl    %cl,%esi
  8026f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026f4:	d3 ea                	shr    %cl,%edx
  8026f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026fa:	09 d6                	or     %edx,%esi
  8026fc:	89 f0                	mov    %esi,%eax
  8026fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802701:	d3 e7                	shl    %cl,%edi
  802703:	89 f2                	mov    %esi,%edx
  802705:	f7 75 f4             	divl   -0xc(%ebp)
  802708:	89 d6                	mov    %edx,%esi
  80270a:	f7 65 e8             	mull   -0x18(%ebp)
  80270d:	39 d6                	cmp    %edx,%esi
  80270f:	72 2b                	jb     80273c <__umoddi3+0x11c>
  802711:	39 c7                	cmp    %eax,%edi
  802713:	72 23                	jb     802738 <__umoddi3+0x118>
  802715:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802719:	29 c7                	sub    %eax,%edi
  80271b:	19 d6                	sbb    %edx,%esi
  80271d:	89 f0                	mov    %esi,%eax
  80271f:	89 f2                	mov    %esi,%edx
  802721:	d3 ef                	shr    %cl,%edi
  802723:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802727:	d3 e0                	shl    %cl,%eax
  802729:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80272d:	09 f8                	or     %edi,%eax
  80272f:	d3 ea                	shr    %cl,%edx
  802731:	83 c4 20             	add    $0x20,%esp
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
  802738:	39 d6                	cmp    %edx,%esi
  80273a:	75 d9                	jne    802715 <__umoddi3+0xf5>
  80273c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80273f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802742:	eb d1                	jmp    802715 <__umoddi3+0xf5>
  802744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802748:	39 f2                	cmp    %esi,%edx
  80274a:	0f 82 18 ff ff ff    	jb     802668 <__umoddi3+0x48>
  802750:	e9 1d ff ff ff       	jmp    802672 <__umoddi3+0x52>
