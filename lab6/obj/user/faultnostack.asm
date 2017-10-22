
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 a4 07 80 	movl   $0x8007a4,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 9c 03 00 00       	call   8003ea <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006e:	e8 84 06 00 00       	call   8006f7 <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	89 c2                	mov    %eax,%edx
  80007a:	c1 e2 07             	shl    $0x7,%edx
  80007d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800084:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x38>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 f0 0b 00 00       	call   800cab <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 70 06 00 00       	call   800737 <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	89 1c 24             	mov    %ebx,(%esp)
  8000d5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000de:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e3:	89 d1                	mov    %edx,%ecx
  8000e5:	89 d3                	mov    %edx,%ebx
  8000e7:	89 d7                	mov    %edx,%edi
  8000e9:	51                   	push   %ecx
  8000ea:	52                   	push   %edx
  8000eb:	53                   	push   %ebx
  8000ec:	54                   	push   %esp
  8000ed:	55                   	push   %ebp
  8000ee:	56                   	push   %esi
  8000ef:	57                   	push   %edi
  8000f0:	54                   	push   %esp
  8000f1:	5d                   	pop    %ebp
  8000f2:	8d 35 fa 00 80 00    	lea    0x8000fa,%esi
  8000f8:	0f 34                	sysenter 
  8000fa:	5f                   	pop    %edi
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	5c                   	pop    %esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5a                   	pop    %edx
  800100:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800101:	8b 1c 24             	mov    (%esp),%ebx
  800104:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800108:	89 ec                	mov    %ebp,%esp
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    

0080010c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 08             	sub    $0x8,%esp
  800112:	89 1c 24             	mov    %ebx,(%esp)
  800115:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800119:	b8 00 00 00 00       	mov    $0x0,%eax
  80011e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	89 c3                	mov    %eax,%ebx
  800126:	89 c7                	mov    %eax,%edi
  800128:	51                   	push   %ecx
  800129:	52                   	push   %edx
  80012a:	53                   	push   %ebx
  80012b:	54                   	push   %esp
  80012c:	55                   	push   %ebp
  80012d:	56                   	push   %esi
  80012e:	57                   	push   %edi
  80012f:	54                   	push   %esp
  800130:	5d                   	pop    %ebp
  800131:	8d 35 39 01 80 00    	lea    0x800139,%esi
  800137:	0f 34                	sysenter 
  800139:	5f                   	pop    %edi
  80013a:	5e                   	pop    %esi
  80013b:	5d                   	pop    %ebp
  80013c:	5c                   	pop    %esp
  80013d:	5b                   	pop    %ebx
  80013e:	5a                   	pop    %edx
  80013f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800140:	8b 1c 24             	mov    (%esp),%ebx
  800143:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	89 1c 24             	mov    %ebx,(%esp)
  800154:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800158:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015d:	b8 13 00 00 00       	mov    $0x13,%eax
  800162:	8b 55 08             	mov    0x8(%ebp),%edx
  800165:	89 cb                	mov    %ecx,%ebx
  800167:	89 cf                	mov    %ecx,%edi
  800169:	51                   	push   %ecx
  80016a:	52                   	push   %edx
  80016b:	53                   	push   %ebx
  80016c:	54                   	push   %esp
  80016d:	55                   	push   %ebp
  80016e:	56                   	push   %esi
  80016f:	57                   	push   %edi
  800170:	54                   	push   %esp
  800171:	5d                   	pop    %ebp
  800172:	8d 35 7a 01 80 00    	lea    0x80017a,%esi
  800178:	0f 34                	sysenter 
  80017a:	5f                   	pop    %edi
  80017b:	5e                   	pop    %esi
  80017c:	5d                   	pop    %ebp
  80017d:	5c                   	pop    %esp
  80017e:	5b                   	pop    %ebx
  80017f:	5a                   	pop    %edx
  800180:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800181:	8b 1c 24             	mov    (%esp),%ebx
  800184:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800188:	89 ec                	mov    %ebp,%esp
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	89 1c 24             	mov    %ebx,(%esp)
  800195:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800199:	bb 00 00 00 00       	mov    $0x0,%ebx
  80019e:	b8 12 00 00 00       	mov    $0x12,%eax
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	89 df                	mov    %ebx,%edi
  8001ab:	51                   	push   %ecx
  8001ac:	52                   	push   %edx
  8001ad:	53                   	push   %ebx
  8001ae:	54                   	push   %esp
  8001af:	55                   	push   %ebp
  8001b0:	56                   	push   %esi
  8001b1:	57                   	push   %edi
  8001b2:	54                   	push   %esp
  8001b3:	5d                   	pop    %ebp
  8001b4:	8d 35 bc 01 80 00    	lea    0x8001bc,%esi
  8001ba:	0f 34                	sysenter 
  8001bc:	5f                   	pop    %edi
  8001bd:	5e                   	pop    %esi
  8001be:	5d                   	pop    %ebp
  8001bf:	5c                   	pop    %esp
  8001c0:	5b                   	pop    %ebx
  8001c1:	5a                   	pop    %edx
  8001c2:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8001c3:	8b 1c 24             	mov    (%esp),%ebx
  8001c6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001ca:	89 ec                	mov    %ebp,%esp
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    

008001ce <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	89 1c 24             	mov    %ebx,(%esp)
  8001d7:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e0:	b8 11 00 00 00       	mov    $0x11,%eax
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	89 df                	mov    %ebx,%edi
  8001ed:	51                   	push   %ecx
  8001ee:	52                   	push   %edx
  8001ef:	53                   	push   %ebx
  8001f0:	54                   	push   %esp
  8001f1:	55                   	push   %ebp
  8001f2:	56                   	push   %esi
  8001f3:	57                   	push   %edi
  8001f4:	54                   	push   %esp
  8001f5:	5d                   	pop    %ebp
  8001f6:	8d 35 fe 01 80 00    	lea    0x8001fe,%esi
  8001fc:	0f 34                	sysenter 
  8001fe:	5f                   	pop    %edi
  8001ff:	5e                   	pop    %esi
  800200:	5d                   	pop    %ebp
  800201:	5c                   	pop    %esp
  800202:	5b                   	pop    %ebx
  800203:	5a                   	pop    %edx
  800204:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  800205:	8b 1c 24             	mov    (%esp),%ebx
  800208:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80020c:	89 ec                	mov    %ebp,%esp
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    

00800210 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 08             	sub    $0x8,%esp
  800216:	89 1c 24             	mov    %ebx,(%esp)
  800219:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80021d:	b8 10 00 00 00       	mov    $0x10,%eax
  800222:	8b 7d 14             	mov    0x14(%ebp),%edi
  800225:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	51                   	push   %ecx
  80022f:	52                   	push   %edx
  800230:	53                   	push   %ebx
  800231:	54                   	push   %esp
  800232:	55                   	push   %ebp
  800233:	56                   	push   %esi
  800234:	57                   	push   %edi
  800235:	54                   	push   %esp
  800236:	5d                   	pop    %ebp
  800237:	8d 35 3f 02 80 00    	lea    0x80023f,%esi
  80023d:	0f 34                	sysenter 
  80023f:	5f                   	pop    %edi
  800240:	5e                   	pop    %esi
  800241:	5d                   	pop    %ebp
  800242:	5c                   	pop    %esp
  800243:	5b                   	pop    %ebx
  800244:	5a                   	pop    %edx
  800245:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800246:	8b 1c 24             	mov    (%esp),%ebx
  800249:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80024d:	89 ec                	mov    %ebp,%esp
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 28             	sub    $0x28,%esp
  800257:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80025a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80025d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800262:	b8 0f 00 00 00       	mov    $0xf,%eax
  800267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	89 df                	mov    %ebx,%edi
  80026f:	51                   	push   %ecx
  800270:	52                   	push   %edx
  800271:	53                   	push   %ebx
  800272:	54                   	push   %esp
  800273:	55                   	push   %ebp
  800274:	56                   	push   %esi
  800275:	57                   	push   %edi
  800276:	54                   	push   %esp
  800277:	5d                   	pop    %ebp
  800278:	8d 35 80 02 80 00    	lea    0x800280,%esi
  80027e:	0f 34                	sysenter 
  800280:	5f                   	pop    %edi
  800281:	5e                   	pop    %esi
  800282:	5d                   	pop    %ebp
  800283:	5c                   	pop    %esp
  800284:	5b                   	pop    %ebx
  800285:	5a                   	pop    %edx
  800286:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800287:	85 c0                	test   %eax,%eax
  800289:	7e 28                	jle    8002b3 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028f:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  800296:	00 
  800297:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  80029e:	00 
  80029f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8002a6:	00 
  8002a7:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  8002ae:	e8 f1 12 00 00       	call   8015a4 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8002b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002b9:	89 ec                	mov    %ebp,%esp
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	89 1c 24             	mov    %ebx,(%esp)
  8002c6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cf:	b8 15 00 00 00       	mov    $0x15,%eax
  8002d4:	89 d1                	mov    %edx,%ecx
  8002d6:	89 d3                	mov    %edx,%ebx
  8002d8:	89 d7                	mov    %edx,%edi
  8002da:	51                   	push   %ecx
  8002db:	52                   	push   %edx
  8002dc:	53                   	push   %ebx
  8002dd:	54                   	push   %esp
  8002de:	55                   	push   %ebp
  8002df:	56                   	push   %esi
  8002e0:	57                   	push   %edi
  8002e1:	54                   	push   %esp
  8002e2:	5d                   	pop    %ebp
  8002e3:	8d 35 eb 02 80 00    	lea    0x8002eb,%esi
  8002e9:	0f 34                	sysenter 
  8002eb:	5f                   	pop    %edi
  8002ec:	5e                   	pop    %esi
  8002ed:	5d                   	pop    %ebp
  8002ee:	5c                   	pop    %esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5a                   	pop    %edx
  8002f1:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002f2:	8b 1c 24             	mov    (%esp),%ebx
  8002f5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f9:	89 ec                	mov    %ebp,%esp
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	89 1c 24             	mov    %ebx,(%esp)
  800306:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80030a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030f:	b8 14 00 00 00       	mov    $0x14,%eax
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	89 cb                	mov    %ecx,%ebx
  800319:	89 cf                	mov    %ecx,%edi
  80031b:	51                   	push   %ecx
  80031c:	52                   	push   %edx
  80031d:	53                   	push   %ebx
  80031e:	54                   	push   %esp
  80031f:	55                   	push   %ebp
  800320:	56                   	push   %esi
  800321:	57                   	push   %edi
  800322:	54                   	push   %esp
  800323:	5d                   	pop    %ebp
  800324:	8d 35 2c 03 80 00    	lea    0x80032c,%esi
  80032a:	0f 34                	sysenter 
  80032c:	5f                   	pop    %edi
  80032d:	5e                   	pop    %esi
  80032e:	5d                   	pop    %ebp
  80032f:	5c                   	pop    %esp
  800330:	5b                   	pop    %ebx
  800331:	5a                   	pop    %edx
  800332:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800333:	8b 1c 24             	mov    (%esp),%ebx
  800336:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80033a:	89 ec                	mov    %ebp,%esp
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 28             	sub    $0x28,%esp
  800344:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800347:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80034a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800354:	8b 55 08             	mov    0x8(%ebp),%edx
  800357:	89 cb                	mov    %ecx,%ebx
  800359:	89 cf                	mov    %ecx,%edi
  80035b:	51                   	push   %ecx
  80035c:	52                   	push   %edx
  80035d:	53                   	push   %ebx
  80035e:	54                   	push   %esp
  80035f:	55                   	push   %ebp
  800360:	56                   	push   %esi
  800361:	57                   	push   %edi
  800362:	54                   	push   %esp
  800363:	5d                   	pop    %ebp
  800364:	8d 35 6c 03 80 00    	lea    0x80036c,%esi
  80036a:	0f 34                	sysenter 
  80036c:	5f                   	pop    %edi
  80036d:	5e                   	pop    %esi
  80036e:	5d                   	pop    %ebp
  80036f:	5c                   	pop    %esp
  800370:	5b                   	pop    %ebx
  800371:	5a                   	pop    %edx
  800372:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800373:	85 c0                	test   %eax,%eax
  800375:	7e 28                	jle    80039f <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800377:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037b:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800382:	00 
  800383:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  80038a:	00 
  80038b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800392:	00 
  800393:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  80039a:	e8 05 12 00 00       	call   8015a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80039f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003a2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a5:	89 ec                	mov    %ebp,%esp
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	89 1c 24             	mov    %ebx,(%esp)
  8003b2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003b6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c7:	51                   	push   %ecx
  8003c8:	52                   	push   %edx
  8003c9:	53                   	push   %ebx
  8003ca:	54                   	push   %esp
  8003cb:	55                   	push   %ebp
  8003cc:	56                   	push   %esi
  8003cd:	57                   	push   %edi
  8003ce:	54                   	push   %esp
  8003cf:	5d                   	pop    %ebp
  8003d0:	8d 35 d8 03 80 00    	lea    0x8003d8,%esi
  8003d6:	0f 34                	sysenter 
  8003d8:	5f                   	pop    %edi
  8003d9:	5e                   	pop    %esi
  8003da:	5d                   	pop    %ebp
  8003db:	5c                   	pop    %esp
  8003dc:	5b                   	pop    %ebx
  8003dd:	5a                   	pop    %edx
  8003de:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003df:	8b 1c 24             	mov    (%esp),%ebx
  8003e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003e6:	89 ec                	mov    %ebp,%esp
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 28             	sub    $0x28,%esp
  8003f0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003f3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003fb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800400:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800403:	8b 55 08             	mov    0x8(%ebp),%edx
  800406:	89 df                	mov    %ebx,%edi
  800408:	51                   	push   %ecx
  800409:	52                   	push   %edx
  80040a:	53                   	push   %ebx
  80040b:	54                   	push   %esp
  80040c:	55                   	push   %ebp
  80040d:	56                   	push   %esi
  80040e:	57                   	push   %edi
  80040f:	54                   	push   %esp
  800410:	5d                   	pop    %ebp
  800411:	8d 35 19 04 80 00    	lea    0x800419,%esi
  800417:	0f 34                	sysenter 
  800419:	5f                   	pop    %edi
  80041a:	5e                   	pop    %esi
  80041b:	5d                   	pop    %ebp
  80041c:	5c                   	pop    %esp
  80041d:	5b                   	pop    %ebx
  80041e:	5a                   	pop    %edx
  80041f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800420:	85 c0                	test   %eax,%eax
  800422:	7e 28                	jle    80044c <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800424:	89 44 24 10          	mov    %eax,0x10(%esp)
  800428:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80042f:	00 
  800430:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  800437:	00 
  800438:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80043f:	00 
  800440:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  800447:	e8 58 11 00 00       	call   8015a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80044c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80044f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800452:	89 ec                	mov    %ebp,%esp
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	83 ec 28             	sub    $0x28,%esp
  80045c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80045f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800462:	bb 00 00 00 00       	mov    $0x0,%ebx
  800467:	b8 0a 00 00 00       	mov    $0xa,%eax
  80046c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046f:	8b 55 08             	mov    0x8(%ebp),%edx
  800472:	89 df                	mov    %ebx,%edi
  800474:	51                   	push   %ecx
  800475:	52                   	push   %edx
  800476:	53                   	push   %ebx
  800477:	54                   	push   %esp
  800478:	55                   	push   %ebp
  800479:	56                   	push   %esi
  80047a:	57                   	push   %edi
  80047b:	54                   	push   %esp
  80047c:	5d                   	pop    %ebp
  80047d:	8d 35 85 04 80 00    	lea    0x800485,%esi
  800483:	0f 34                	sysenter 
  800485:	5f                   	pop    %edi
  800486:	5e                   	pop    %esi
  800487:	5d                   	pop    %ebp
  800488:	5c                   	pop    %esp
  800489:	5b                   	pop    %ebx
  80048a:	5a                   	pop    %edx
  80048b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80048c:	85 c0                	test   %eax,%eax
  80048e:	7e 28                	jle    8004b8 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800490:	89 44 24 10          	mov    %eax,0x10(%esp)
  800494:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80049b:	00 
  80049c:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  8004a3:	00 
  8004a4:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004ab:	00 
  8004ac:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  8004b3:	e8 ec 10 00 00       	call   8015a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8004b8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004be:	89 ec                	mov    %ebp,%esp
  8004c0:	5d                   	pop    %ebp
  8004c1:	c3                   	ret    

008004c2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	83 ec 28             	sub    $0x28,%esp
  8004c8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004cb:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004d3:	b8 09 00 00 00       	mov    $0x9,%eax
  8004d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004db:	8b 55 08             	mov    0x8(%ebp),%edx
  8004de:	89 df                	mov    %ebx,%edi
  8004e0:	51                   	push   %ecx
  8004e1:	52                   	push   %edx
  8004e2:	53                   	push   %ebx
  8004e3:	54                   	push   %esp
  8004e4:	55                   	push   %ebp
  8004e5:	56                   	push   %esi
  8004e6:	57                   	push   %edi
  8004e7:	54                   	push   %esp
  8004e8:	5d                   	pop    %ebp
  8004e9:	8d 35 f1 04 80 00    	lea    0x8004f1,%esi
  8004ef:	0f 34                	sysenter 
  8004f1:	5f                   	pop    %edi
  8004f2:	5e                   	pop    %esi
  8004f3:	5d                   	pop    %ebp
  8004f4:	5c                   	pop    %esp
  8004f5:	5b                   	pop    %ebx
  8004f6:	5a                   	pop    %edx
  8004f7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	7e 28                	jle    800524 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800500:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800507:	00 
  800508:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  80050f:	00 
  800510:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800517:	00 
  800518:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  80051f:	e8 80 10 00 00       	call   8015a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800524:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800527:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80052a:	89 ec                	mov    %ebp,%esp
  80052c:	5d                   	pop    %ebp
  80052d:	c3                   	ret    

0080052e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	83 ec 28             	sub    $0x28,%esp
  800534:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800537:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80053a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80053f:	b8 07 00 00 00       	mov    $0x7,%eax
  800544:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800547:	8b 55 08             	mov    0x8(%ebp),%edx
  80054a:	89 df                	mov    %ebx,%edi
  80054c:	51                   	push   %ecx
  80054d:	52                   	push   %edx
  80054e:	53                   	push   %ebx
  80054f:	54                   	push   %esp
  800550:	55                   	push   %ebp
  800551:	56                   	push   %esi
  800552:	57                   	push   %edi
  800553:	54                   	push   %esp
  800554:	5d                   	pop    %ebp
  800555:	8d 35 5d 05 80 00    	lea    0x80055d,%esi
  80055b:	0f 34                	sysenter 
  80055d:	5f                   	pop    %edi
  80055e:	5e                   	pop    %esi
  80055f:	5d                   	pop    %ebp
  800560:	5c                   	pop    %esp
  800561:	5b                   	pop    %ebx
  800562:	5a                   	pop    %edx
  800563:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800564:	85 c0                	test   %eax,%eax
  800566:	7e 28                	jle    800590 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800568:	89 44 24 10          	mov    %eax,0x10(%esp)
  80056c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800573:	00 
  800574:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  80057b:	00 
  80057c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800583:	00 
  800584:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  80058b:	e8 14 10 00 00       	call   8015a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800590:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800593:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800596:	89 ec                	mov    %ebp,%esp
  800598:	5d                   	pop    %ebp
  800599:	c3                   	ret    

0080059a <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80059a:	55                   	push   %ebp
  80059b:	89 e5                	mov    %esp,%ebp
  80059d:	83 ec 28             	sub    $0x28,%esp
  8005a0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005a3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005a6:	8b 7d 18             	mov    0x18(%ebp),%edi
  8005a9:	0b 7d 14             	or     0x14(%ebp),%edi
  8005ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8005b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ba:	51                   	push   %ecx
  8005bb:	52                   	push   %edx
  8005bc:	53                   	push   %ebx
  8005bd:	54                   	push   %esp
  8005be:	55                   	push   %ebp
  8005bf:	56                   	push   %esi
  8005c0:	57                   	push   %edi
  8005c1:	54                   	push   %esp
  8005c2:	5d                   	pop    %ebp
  8005c3:	8d 35 cb 05 80 00    	lea    0x8005cb,%esi
  8005c9:	0f 34                	sysenter 
  8005cb:	5f                   	pop    %edi
  8005cc:	5e                   	pop    %esi
  8005cd:	5d                   	pop    %ebp
  8005ce:	5c                   	pop    %esp
  8005cf:	5b                   	pop    %ebx
  8005d0:	5a                   	pop    %edx
  8005d1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8005d2:	85 c0                	test   %eax,%eax
  8005d4:	7e 28                	jle    8005fe <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005da:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005e1:	00 
  8005e2:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  8005e9:	00 
  8005ea:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8005f1:	00 
  8005f2:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  8005f9:	e8 a6 0f 00 00       	call   8015a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8005fe:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800601:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800604:	89 ec                	mov    %ebp,%esp
  800606:	5d                   	pop    %ebp
  800607:	c3                   	ret    

00800608 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	83 ec 28             	sub    $0x28,%esp
  80060e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800611:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800614:	bf 00 00 00 00       	mov    $0x0,%edi
  800619:	b8 05 00 00 00       	mov    $0x5,%eax
  80061e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800621:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800624:	8b 55 08             	mov    0x8(%ebp),%edx
  800627:	51                   	push   %ecx
  800628:	52                   	push   %edx
  800629:	53                   	push   %ebx
  80062a:	54                   	push   %esp
  80062b:	55                   	push   %ebp
  80062c:	56                   	push   %esi
  80062d:	57                   	push   %edi
  80062e:	54                   	push   %esp
  80062f:	5d                   	pop    %ebp
  800630:	8d 35 38 06 80 00    	lea    0x800638,%esi
  800636:	0f 34                	sysenter 
  800638:	5f                   	pop    %edi
  800639:	5e                   	pop    %esi
  80063a:	5d                   	pop    %ebp
  80063b:	5c                   	pop    %esp
  80063c:	5b                   	pop    %ebx
  80063d:	5a                   	pop    %edx
  80063e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80063f:	85 c0                	test   %eax,%eax
  800641:	7e 28                	jle    80066b <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800643:	89 44 24 10          	mov    %eax,0x10(%esp)
  800647:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80064e:	00 
  80064f:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  800656:	00 
  800657:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80065e:	00 
  80065f:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  800666:	e8 39 0f 00 00       	call   8015a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80066b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80066e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800671:	89 ec                	mov    %ebp,%esp
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	89 1c 24             	mov    %ebx,(%esp)
  80067e:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800682:	ba 00 00 00 00       	mov    $0x0,%edx
  800687:	b8 0c 00 00 00       	mov    $0xc,%eax
  80068c:	89 d1                	mov    %edx,%ecx
  80068e:	89 d3                	mov    %edx,%ebx
  800690:	89 d7                	mov    %edx,%edi
  800692:	51                   	push   %ecx
  800693:	52                   	push   %edx
  800694:	53                   	push   %ebx
  800695:	54                   	push   %esp
  800696:	55                   	push   %ebp
  800697:	56                   	push   %esi
  800698:	57                   	push   %edi
  800699:	54                   	push   %esp
  80069a:	5d                   	pop    %ebp
  80069b:	8d 35 a3 06 80 00    	lea    0x8006a3,%esi
  8006a1:	0f 34                	sysenter 
  8006a3:	5f                   	pop    %edi
  8006a4:	5e                   	pop    %esi
  8006a5:	5d                   	pop    %ebp
  8006a6:	5c                   	pop    %esp
  8006a7:	5b                   	pop    %ebx
  8006a8:	5a                   	pop    %edx
  8006a9:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8006aa:	8b 1c 24             	mov    (%esp),%ebx
  8006ad:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006b1:	89 ec                	mov    %ebp,%esp
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	89 1c 24             	mov    %ebx,(%esp)
  8006be:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8006cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d2:	89 df                	mov    %ebx,%edi
  8006d4:	51                   	push   %ecx
  8006d5:	52                   	push   %edx
  8006d6:	53                   	push   %ebx
  8006d7:	54                   	push   %esp
  8006d8:	55                   	push   %ebp
  8006d9:	56                   	push   %esi
  8006da:	57                   	push   %edi
  8006db:	54                   	push   %esp
  8006dc:	5d                   	pop    %ebp
  8006dd:	8d 35 e5 06 80 00    	lea    0x8006e5,%esi
  8006e3:	0f 34                	sysenter 
  8006e5:	5f                   	pop    %edi
  8006e6:	5e                   	pop    %esi
  8006e7:	5d                   	pop    %ebp
  8006e8:	5c                   	pop    %esp
  8006e9:	5b                   	pop    %ebx
  8006ea:	5a                   	pop    %edx
  8006eb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8006ec:	8b 1c 24             	mov    (%esp),%ebx
  8006ef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006f3:	89 ec                	mov    %ebp,%esp
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	89 1c 24             	mov    %ebx,(%esp)
  800700:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800704:	ba 00 00 00 00       	mov    $0x0,%edx
  800709:	b8 02 00 00 00       	mov    $0x2,%eax
  80070e:	89 d1                	mov    %edx,%ecx
  800710:	89 d3                	mov    %edx,%ebx
  800712:	89 d7                	mov    %edx,%edi
  800714:	51                   	push   %ecx
  800715:	52                   	push   %edx
  800716:	53                   	push   %ebx
  800717:	54                   	push   %esp
  800718:	55                   	push   %ebp
  800719:	56                   	push   %esi
  80071a:	57                   	push   %edi
  80071b:	54                   	push   %esp
  80071c:	5d                   	pop    %ebp
  80071d:	8d 35 25 07 80 00    	lea    0x800725,%esi
  800723:	0f 34                	sysenter 
  800725:	5f                   	pop    %edi
  800726:	5e                   	pop    %esi
  800727:	5d                   	pop    %ebp
  800728:	5c                   	pop    %esp
  800729:	5b                   	pop    %ebx
  80072a:	5a                   	pop    %edx
  80072b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80072c:	8b 1c 24             	mov    (%esp),%ebx
  80072f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800733:	89 ec                	mov    %ebp,%esp
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	83 ec 28             	sub    $0x28,%esp
  80073d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800740:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800743:	b9 00 00 00 00       	mov    $0x0,%ecx
  800748:	b8 03 00 00 00       	mov    $0x3,%eax
  80074d:	8b 55 08             	mov    0x8(%ebp),%edx
  800750:	89 cb                	mov    %ecx,%ebx
  800752:	89 cf                	mov    %ecx,%edi
  800754:	51                   	push   %ecx
  800755:	52                   	push   %edx
  800756:	53                   	push   %ebx
  800757:	54                   	push   %esp
  800758:	55                   	push   %ebp
  800759:	56                   	push   %esi
  80075a:	57                   	push   %edi
  80075b:	54                   	push   %esp
  80075c:	5d                   	pop    %ebp
  80075d:	8d 35 65 07 80 00    	lea    0x800765,%esi
  800763:	0f 34                	sysenter 
  800765:	5f                   	pop    %edi
  800766:	5e                   	pop    %esi
  800767:	5d                   	pop    %ebp
  800768:	5c                   	pop    %esp
  800769:	5b                   	pop    %ebx
  80076a:	5a                   	pop    %edx
  80076b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80076c:	85 c0                	test   %eax,%eax
  80076e:	7e 28                	jle    800798 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800770:	89 44 24 10          	mov    %eax,0x10(%esp)
  800774:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80077b:	00 
  80077c:	c7 44 24 08 ca 27 80 	movl   $0x8027ca,0x8(%esp)
  800783:	00 
  800784:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80078b:	00 
  80078c:	c7 04 24 e7 27 80 00 	movl   $0x8027e7,(%esp)
  800793:	e8 0c 0e 00 00       	call   8015a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800798:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80079b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80079e:	89 ec                	mov    %ebp,%esp
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    
	...

008007a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8007a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8007a5:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8007aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8007ac:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8007af:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8007b3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8007b7:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8007ba:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8007bc:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8007c0:	83 c4 08             	add    $0x8,%esp
        popal
  8007c3:	61                   	popa   
        addl $0x4,%esp
  8007c4:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8007c7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8007c8:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8007c9:	c3                   	ret    
  8007ca:	00 00                	add    %al,(%eax)
  8007cc:	00 00                	add    %al,(%eax)
	...

008007d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8007db:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	89 04 24             	mov    %eax,(%esp)
  8007ec:	e8 df ff ff ff       	call   8007d0 <fd2num>
  8007f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8007f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	57                   	push   %edi
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800804:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800809:	a8 01                	test   $0x1,%al
  80080b:	74 36                	je     800843 <fd_alloc+0x48>
  80080d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800812:	a8 01                	test   $0x1,%al
  800814:	74 2d                	je     800843 <fd_alloc+0x48>
  800816:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80081b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800820:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800825:	89 c3                	mov    %eax,%ebx
  800827:	89 c2                	mov    %eax,%edx
  800829:	c1 ea 16             	shr    $0x16,%edx
  80082c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80082f:	f6 c2 01             	test   $0x1,%dl
  800832:	74 14                	je     800848 <fd_alloc+0x4d>
  800834:	89 c2                	mov    %eax,%edx
  800836:	c1 ea 0c             	shr    $0xc,%edx
  800839:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80083c:	f6 c2 01             	test   $0x1,%dl
  80083f:	75 10                	jne    800851 <fd_alloc+0x56>
  800841:	eb 05                	jmp    800848 <fd_alloc+0x4d>
  800843:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800848:	89 1f                	mov    %ebx,(%edi)
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80084f:	eb 17                	jmp    800868 <fd_alloc+0x6d>
  800851:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800856:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80085b:	75 c8                	jne    800825 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80085d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800863:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5f                   	pop    %edi
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	83 f8 1f             	cmp    $0x1f,%eax
  800876:	77 36                	ja     8008ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800878:	05 00 00 0d 00       	add    $0xd0000,%eax
  80087d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800880:	89 c2                	mov    %eax,%edx
  800882:	c1 ea 16             	shr    $0x16,%edx
  800885:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80088c:	f6 c2 01             	test   $0x1,%dl
  80088f:	74 1d                	je     8008ae <fd_lookup+0x41>
  800891:	89 c2                	mov    %eax,%edx
  800893:	c1 ea 0c             	shr    $0xc,%edx
  800896:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80089d:	f6 c2 01             	test   $0x1,%dl
  8008a0:	74 0c                	je     8008ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a5:	89 02                	mov    %eax,(%edx)
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8008ac:	eb 05                	jmp    8008b3 <fd_lookup+0x46>
  8008ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	89 04 24             	mov    %eax,(%esp)
  8008c8:	e8 a0 ff ff ff       	call   80086d <fd_lookup>
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	78 0e                	js     8008df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d7:	89 50 04             	mov    %edx,0x4(%eax)
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    

008008e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	83 ec 10             	sub    $0x10,%esp
  8008e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8008ef:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8008f4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008f9:	be 74 28 80 00       	mov    $0x802874,%esi
		if (devtab[i]->dev_id == dev_id) {
  8008fe:	39 08                	cmp    %ecx,(%eax)
  800900:	75 10                	jne    800912 <dev_lookup+0x31>
  800902:	eb 04                	jmp    800908 <dev_lookup+0x27>
  800904:	39 08                	cmp    %ecx,(%eax)
  800906:	75 0a                	jne    800912 <dev_lookup+0x31>
			*dev = devtab[i];
  800908:	89 03                	mov    %eax,(%ebx)
  80090a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80090f:	90                   	nop
  800910:	eb 31                	jmp    800943 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800912:	83 c2 01             	add    $0x1,%edx
  800915:	8b 04 96             	mov    (%esi,%edx,4),%eax
  800918:	85 c0                	test   %eax,%eax
  80091a:	75 e8                	jne    800904 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80091c:	a1 08 40 80 00       	mov    0x804008,%eax
  800921:	8b 40 48             	mov    0x48(%eax),%eax
  800924:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092c:	c7 04 24 f8 27 80 00 	movl   $0x8027f8,(%esp)
  800933:	e8 25 0d 00 00       	call   80165d <cprintf>
	*dev = 0;
  800938:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80093e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800943:	83 c4 10             	add    $0x10,%esp
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	83 ec 24             	sub    $0x24,%esp
  800951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800954:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	89 04 24             	mov    %eax,(%esp)
  800961:	e8 07 ff ff ff       	call   80086d <fd_lookup>
  800966:	85 c0                	test   %eax,%eax
  800968:	78 53                	js     8009bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80096a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80096d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800971:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800974:	8b 00                	mov    (%eax),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 63 ff ff ff       	call   8008e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80097e:	85 c0                	test   %eax,%eax
  800980:	78 3b                	js     8009bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800982:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800987:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80098a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80098e:	74 2d                	je     8009bd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800990:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800993:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80099a:	00 00 00 
	stat->st_isdir = 0;
  80099d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009a4:	00 00 00 
	stat->st_dev = dev;
  8009a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009aa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b7:	89 14 24             	mov    %edx,(%esp)
  8009ba:	ff 50 14             	call   *0x14(%eax)
}
  8009bd:	83 c4 24             	add    $0x24,%esp
  8009c0:	5b                   	pop    %ebx
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	53                   	push   %ebx
  8009c7:	83 ec 24             	sub    $0x24,%esp
  8009ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	89 1c 24             	mov    %ebx,(%esp)
  8009d7:	e8 91 fe ff ff       	call   80086d <fd_lookup>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 5f                	js     800a3f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ea:	8b 00                	mov    (%eax),%eax
  8009ec:	89 04 24             	mov    %eax,(%esp)
  8009ef:	e8 ed fe ff ff       	call   8008e1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	78 47                	js     800a3f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009fb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8009ff:	75 23                	jne    800a24 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a01:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a06:	8b 40 48             	mov    0x48(%eax),%eax
  800a09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a11:	c7 04 24 18 28 80 00 	movl   $0x802818,(%esp)
  800a18:	e8 40 0c 00 00       	call   80165d <cprintf>
  800a1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a22:	eb 1b                	jmp    800a3f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a27:	8b 48 18             	mov    0x18(%eax),%ecx
  800a2a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a2f:	85 c9                	test   %ecx,%ecx
  800a31:	74 0c                	je     800a3f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3a:	89 14 24             	mov    %edx,(%esp)
  800a3d:	ff d1                	call   *%ecx
}
  800a3f:	83 c4 24             	add    $0x24,%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	53                   	push   %ebx
  800a49:	83 ec 24             	sub    $0x24,%esp
  800a4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a56:	89 1c 24             	mov    %ebx,(%esp)
  800a59:	e8 0f fe ff ff       	call   80086d <fd_lookup>
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	78 66                	js     800ac8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a6c:	8b 00                	mov    (%eax),%eax
  800a6e:	89 04 24             	mov    %eax,(%esp)
  800a71:	e8 6b fe ff ff       	call   8008e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a76:	85 c0                	test   %eax,%eax
  800a78:	78 4e                	js     800ac8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a7d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800a81:	75 23                	jne    800aa6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a83:	a1 08 40 80 00       	mov    0x804008,%eax
  800a88:	8b 40 48             	mov    0x48(%eax),%eax
  800a8b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a93:	c7 04 24 39 28 80 00 	movl   $0x802839,(%esp)
  800a9a:	e8 be 0b 00 00       	call   80165d <cprintf>
  800a9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800aa4:	eb 22                	jmp    800ac8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aa9:	8b 48 0c             	mov    0xc(%eax),%ecx
  800aac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800ab1:	85 c9                	test   %ecx,%ecx
  800ab3:	74 13                	je     800ac8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ab5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac3:	89 14 24             	mov    %edx,(%esp)
  800ac6:	ff d1                	call   *%ecx
}
  800ac8:	83 c4 24             	add    $0x24,%esp
  800acb:	5b                   	pop    %ebx
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 24             	sub    $0x24,%esp
  800ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ad8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adf:	89 1c 24             	mov    %ebx,(%esp)
  800ae2:	e8 86 fd ff ff       	call   80086d <fd_lookup>
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	78 6b                	js     800b56 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af5:	8b 00                	mov    (%eax),%eax
  800af7:	89 04 24             	mov    %eax,(%esp)
  800afa:	e8 e2 fd ff ff       	call   8008e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800aff:	85 c0                	test   %eax,%eax
  800b01:	78 53                	js     800b56 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b03:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b06:	8b 42 08             	mov    0x8(%edx),%eax
  800b09:	83 e0 03             	and    $0x3,%eax
  800b0c:	83 f8 01             	cmp    $0x1,%eax
  800b0f:	75 23                	jne    800b34 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b11:	a1 08 40 80 00       	mov    0x804008,%eax
  800b16:	8b 40 48             	mov    0x48(%eax),%eax
  800b19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b21:	c7 04 24 56 28 80 00 	movl   $0x802856,(%esp)
  800b28:	e8 30 0b 00 00       	call   80165d <cprintf>
  800b2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800b32:	eb 22                	jmp    800b56 <read+0x88>
	}
	if (!dev->dev_read)
  800b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b37:	8b 48 08             	mov    0x8(%eax),%ecx
  800b3a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b3f:	85 c9                	test   %ecx,%ecx
  800b41:	74 13                	je     800b56 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b43:	8b 45 10             	mov    0x10(%ebp),%eax
  800b46:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b51:	89 14 24             	mov    %edx,(%esp)
  800b54:	ff d1                	call   *%ecx
}
  800b56:	83 c4 24             	add    $0x24,%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 1c             	sub    $0x1c,%esp
  800b65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b68:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	85 f6                	test   %esi,%esi
  800b7c:	74 29                	je     800ba7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b7e:	89 f0                	mov    %esi,%eax
  800b80:	29 d0                	sub    %edx,%eax
  800b82:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b86:	03 55 0c             	add    0xc(%ebp),%edx
  800b89:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b8d:	89 3c 24             	mov    %edi,(%esp)
  800b90:	e8 39 ff ff ff       	call   800ace <read>
		if (m < 0)
  800b95:	85 c0                	test   %eax,%eax
  800b97:	78 0e                	js     800ba7 <readn+0x4b>
			return m;
		if (m == 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	74 08                	je     800ba5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b9d:	01 c3                	add    %eax,%ebx
  800b9f:	89 da                	mov    %ebx,%edx
  800ba1:	39 f3                	cmp    %esi,%ebx
  800ba3:	72 d9                	jb     800b7e <readn+0x22>
  800ba5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800ba7:	83 c4 1c             	add    $0x1c,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 20             	sub    $0x20,%esp
  800bb7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800bba:	89 34 24             	mov    %esi,(%esp)
  800bbd:	e8 0e fc ff ff       	call   8007d0 <fd2num>
  800bc2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bc5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc9:	89 04 24             	mov    %eax,(%esp)
  800bcc:	e8 9c fc ff ff       	call   80086d <fd_lookup>
  800bd1:	89 c3                	mov    %eax,%ebx
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	78 05                	js     800bdc <fd_close+0x2d>
  800bd7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800bda:	74 0c                	je     800be8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800bdc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800be0:	19 c0                	sbb    %eax,%eax
  800be2:	f7 d0                	not    %eax
  800be4:	21 c3                	and    %eax,%ebx
  800be6:	eb 3d                	jmp    800c25 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800be8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bef:	8b 06                	mov    (%esi),%eax
  800bf1:	89 04 24             	mov    %eax,(%esp)
  800bf4:	e8 e8 fc ff ff       	call   8008e1 <dev_lookup>
  800bf9:	89 c3                	mov    %eax,%ebx
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	78 16                	js     800c15 <fd_close+0x66>
		if (dev->dev_close)
  800bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c02:	8b 40 10             	mov    0x10(%eax),%eax
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	74 07                	je     800c15 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800c0e:	89 34 24             	mov    %esi,(%esp)
  800c11:	ff d0                	call   *%eax
  800c13:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800c15:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c20:	e8 09 f9 ff ff       	call   80052e <sys_page_unmap>
	return r;
}
  800c25:	89 d8                	mov    %ebx,%eax
  800c27:	83 c4 20             	add    $0x20,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	89 04 24             	mov    %eax,(%esp)
  800c41:	e8 27 fc ff ff       	call   80086d <fd_lookup>
  800c46:	85 c0                	test   %eax,%eax
  800c48:	78 13                	js     800c5d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800c4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800c51:	00 
  800c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c55:	89 04 24             	mov    %eax,(%esp)
  800c58:	e8 52 ff ff ff       	call   800baf <fd_close>
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	83 ec 18             	sub    $0x18,%esp
  800c65:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800c68:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c72:	00 
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
  800c76:	89 04 24             	mov    %eax,(%esp)
  800c79:	e8 79 03 00 00       	call   800ff7 <open>
  800c7e:	89 c3                	mov    %eax,%ebx
  800c80:	85 c0                	test   %eax,%eax
  800c82:	78 1b                	js     800c9f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800c84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8b:	89 1c 24             	mov    %ebx,(%esp)
  800c8e:	e8 b7 fc ff ff       	call   80094a <fstat>
  800c93:	89 c6                	mov    %eax,%esi
	close(fd);
  800c95:	89 1c 24             	mov    %ebx,(%esp)
  800c98:	e8 91 ff ff ff       	call   800c2e <close>
  800c9d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800c9f:	89 d8                	mov    %ebx,%eax
  800ca1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ca4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800ca7:	89 ec                	mov    %ebp,%esp
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	83 ec 14             	sub    $0x14,%esp
  800cb2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800cb7:	89 1c 24             	mov    %ebx,(%esp)
  800cba:	e8 6f ff ff ff       	call   800c2e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800cbf:	83 c3 01             	add    $0x1,%ebx
  800cc2:	83 fb 20             	cmp    $0x20,%ebx
  800cc5:	75 f0                	jne    800cb7 <close_all+0xc>
		close(i);
}
  800cc7:	83 c4 14             	add    $0x14,%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	83 ec 58             	sub    $0x58,%esp
  800cd3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cdc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800cdf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	89 04 24             	mov    %eax,(%esp)
  800cec:	e8 7c fb ff ff       	call   80086d <fd_lookup>
  800cf1:	89 c3                	mov    %eax,%ebx
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	0f 88 e0 00 00 00    	js     800ddb <dup+0x10e>
		return r;
	close(newfdnum);
  800cfb:	89 3c 24             	mov    %edi,(%esp)
  800cfe:	e8 2b ff ff ff       	call   800c2e <close>

	newfd = INDEX2FD(newfdnum);
  800d03:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800d09:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800d0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d0f:	89 04 24             	mov    %eax,(%esp)
  800d12:	e8 c9 fa ff ff       	call   8007e0 <fd2data>
  800d17:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800d19:	89 34 24             	mov    %esi,(%esp)
  800d1c:	e8 bf fa ff ff       	call   8007e0 <fd2data>
  800d21:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800d24:	89 da                	mov    %ebx,%edx
  800d26:	89 d8                	mov    %ebx,%eax
  800d28:	c1 e8 16             	shr    $0x16,%eax
  800d2b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d32:	a8 01                	test   $0x1,%al
  800d34:	74 43                	je     800d79 <dup+0xac>
  800d36:	c1 ea 0c             	shr    $0xc,%edx
  800d39:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d40:	a8 01                	test   $0x1,%al
  800d42:	74 35                	je     800d79 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800d44:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d4b:	25 07 0e 00 00       	and    $0xe07,%eax
  800d50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d62:	00 
  800d63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d6e:	e8 27 f8 ff ff       	call   80059a <sys_page_map>
  800d73:	89 c3                	mov    %eax,%ebx
  800d75:	85 c0                	test   %eax,%eax
  800d77:	78 3f                	js     800db8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d7c:	89 c2                	mov    %eax,%edx
  800d7e:	c1 ea 0c             	shr    $0xc,%edx
  800d81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d88:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d8e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d92:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d9d:	00 
  800d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800da9:	e8 ec f7 ff ff       	call   80059a <sys_page_map>
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 04                	js     800db8 <dup+0xeb>
  800db4:	89 fb                	mov    %edi,%ebx
  800db6:	eb 23                	jmp    800ddb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800db8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dc3:	e8 66 f7 ff ff       	call   80052e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800dc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dd6:	e8 53 f7 ff ff       	call   80052e <sys_page_unmap>
	return r;
}
  800ddb:	89 d8                	mov    %ebx,%eax
  800ddd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de6:	89 ec                	mov    %ebp,%esp
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
	...

00800dec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 18             	sub    $0x18,%esp
  800df2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800df5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800df8:	89 c3                	mov    %eax,%ebx
  800dfa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800dfc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e03:	75 11                	jne    800e16 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e05:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800e0c:	e8 bf 15 00 00       	call   8023d0 <ipc_find_env>
  800e11:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e16:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e25:	00 
  800e26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e2a:	a1 00 40 80 00       	mov    0x804000,%eax
  800e2f:	89 04 24             	mov    %eax,(%esp)
  800e32:	e8 e4 15 00 00       	call   80241b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e3e:	00 
  800e3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4a:	e8 4a 16 00 00       	call   802499 <ipc_recv>
}
  800e4f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e52:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800e55:	89 ec                	mov    %ebp,%esp
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	8b 40 0c             	mov    0xc(%eax),%eax
  800e65:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7c:	e8 6b ff ff ff       	call   800dec <fsipc>
}
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	8b 40 0c             	mov    0xc(%eax),%eax
  800e8f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e94:	ba 00 00 00 00       	mov    $0x0,%edx
  800e99:	b8 06 00 00 00       	mov    $0x6,%eax
  800e9e:	e8 49 ff ff ff       	call   800dec <fsipc>
}
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800eab:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb5:	e8 32 ff ff ff       	call   800dec <fsipc>
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 14             	sub    $0x14,%esp
  800ec3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec9:	8b 40 0c             	mov    0xc(%eax),%eax
  800ecc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ed1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed6:	b8 05 00 00 00       	mov    $0x5,%eax
  800edb:	e8 0c ff ff ff       	call   800dec <fsipc>
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 2b                	js     800f0f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ee4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800eeb:	00 
  800eec:	89 1c 24             	mov    %ebx,(%esp)
  800eef:	e8 96 10 00 00       	call   801f8a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ef4:	a1 80 50 80 00       	mov    0x805080,%eax
  800ef9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800eff:	a1 84 50 80 00       	mov    0x805084,%eax
  800f04:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800f0f:	83 c4 14             	add    $0x14,%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 18             	sub    $0x18,%esp
  800f1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f23:	76 05                	jbe    800f2a <devfile_write+0x15>
  800f25:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2d:	8b 52 0c             	mov    0xc(%edx),%edx
  800f30:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800f36:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800f3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f46:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f4d:	e8 23 12 00 00       	call   802175 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800f52:	ba 00 00 00 00       	mov    $0x0,%edx
  800f57:	b8 04 00 00 00       	mov    $0x4,%eax
  800f5c:	e8 8b fe ff ff       	call   800dec <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	53                   	push   %ebx
  800f67:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800f70:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800f75:	8b 45 10             	mov    0x10(%ebp),%eax
  800f78:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  800f7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f82:	b8 03 00 00 00       	mov    $0x3,%eax
  800f87:	e8 60 fe ff ff       	call   800dec <fsipc>
  800f8c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 17                	js     800fa9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800f92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f96:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800f9d:	00 
  800f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa1:	89 04 24             	mov    %eax,(%esp)
  800fa4:	e8 cc 11 00 00       	call   802175 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800fa9:	89 d8                	mov    %ebx,%eax
  800fab:	83 c4 14             	add    $0x14,%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 14             	sub    $0x14,%esp
  800fb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800fbb:	89 1c 24             	mov    %ebx,(%esp)
  800fbe:	e8 7d 0f 00 00       	call   801f40 <strlen>
  800fc3:	89 c2                	mov    %eax,%edx
  800fc5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800fca:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800fd0:	7f 1f                	jg     800ff1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800fd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fd6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800fdd:	e8 a8 0f 00 00       	call   801f8a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800fe2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fec:	e8 fb fd ff ff       	call   800dec <fsipc>
}
  800ff1:	83 c4 14             	add    $0x14,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 28             	sub    $0x28,%esp
  800ffd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801000:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801003:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  801006:	89 34 24             	mov    %esi,(%esp)
  801009:	e8 32 0f 00 00       	call   801f40 <strlen>
  80100e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801013:	3d 00 04 00 00       	cmp    $0x400,%eax
  801018:	7f 6d                	jg     801087 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  80101a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101d:	89 04 24             	mov    %eax,(%esp)
  801020:	e8 d6 f7 ff ff       	call   8007fb <fd_alloc>
  801025:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  801027:	85 c0                	test   %eax,%eax
  801029:	78 5c                	js     801087 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  80102b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801033:	89 34 24             	mov    %esi,(%esp)
  801036:	e8 05 0f 00 00       	call   801f40 <strlen>
  80103b:	83 c0 01             	add    $0x1,%eax
  80103e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801042:	89 74 24 04          	mov    %esi,0x4(%esp)
  801046:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80104d:	e8 23 11 00 00       	call   802175 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801052:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801055:	b8 01 00 00 00       	mov    $0x1,%eax
  80105a:	e8 8d fd ff ff       	call   800dec <fsipc>
  80105f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801061:	85 c0                	test   %eax,%eax
  801063:	79 15                	jns    80107a <open+0x83>
             fd_close(fd,0);
  801065:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80106c:	00 
  80106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801070:	89 04 24             	mov    %eax,(%esp)
  801073:	e8 37 fb ff ff       	call   800baf <fd_close>
             return r;
  801078:	eb 0d                	jmp    801087 <open+0x90>
        }
        return fd2num(fd);
  80107a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	e8 4b f7 ff ff       	call   8007d0 <fd2num>
  801085:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801087:	89 d8                	mov    %ebx,%eax
  801089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80108c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80108f:	89 ec                	mov    %ebp,%esp
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    
	...

008010a0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8010a6:	c7 44 24 04 80 28 80 	movl   $0x802880,0x4(%esp)
  8010ad:	00 
  8010ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b1:	89 04 24             	mov    %eax,(%esp)
  8010b4:	e8 d1 0e 00 00       	call   801f8a <strcpy>
	return 0;
}
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	53                   	push   %ebx
  8010c4:	83 ec 14             	sub    $0x14,%esp
  8010c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8010ca:	89 1c 24             	mov    %ebx,(%esp)
  8010cd:	e8 3a 14 00 00       	call   80250c <pageref>
  8010d2:	89 c2                	mov    %eax,%edx
  8010d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d9:	83 fa 01             	cmp    $0x1,%edx
  8010dc:	75 0b                	jne    8010e9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8010de:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010e1:	89 04 24             	mov    %eax,(%esp)
  8010e4:	e8 b9 02 00 00       	call   8013a2 <nsipc_close>
	else
		return 0;
}
  8010e9:	83 c4 14             	add    $0x14,%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8010f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010fc:	00 
  8010fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801100:	89 44 24 08          	mov    %eax,0x8(%esp)
  801104:	8b 45 0c             	mov    0xc(%ebp),%eax
  801107:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	8b 40 0c             	mov    0xc(%eax),%eax
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	e8 c5 02 00 00       	call   8013de <nsipc_send>
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801121:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801128:	00 
  801129:	8b 45 10             	mov    0x10(%ebp),%eax
  80112c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801130:	8b 45 0c             	mov    0xc(%ebp),%eax
  801133:	89 44 24 04          	mov    %eax,0x4(%esp)
  801137:	8b 45 08             	mov    0x8(%ebp),%eax
  80113a:	8b 40 0c             	mov    0xc(%eax),%eax
  80113d:	89 04 24             	mov    %eax,(%esp)
  801140:	e8 0c 03 00 00       	call   801451 <nsipc_recv>
}
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	56                   	push   %esi
  80114b:	53                   	push   %ebx
  80114c:	83 ec 20             	sub    $0x20,%esp
  80114f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801151:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801154:	89 04 24             	mov    %eax,(%esp)
  801157:	e8 9f f6 ff ff       	call   8007fb <fd_alloc>
  80115c:	89 c3                	mov    %eax,%ebx
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 21                	js     801183 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801162:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801169:	00 
  80116a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801171:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801178:	e8 8b f4 ff ff       	call   800608 <sys_page_alloc>
  80117d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80117f:	85 c0                	test   %eax,%eax
  801181:	79 0a                	jns    80118d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801183:	89 34 24             	mov    %esi,(%esp)
  801186:	e8 17 02 00 00       	call   8013a2 <nsipc_close>
		return r;
  80118b:	eb 28                	jmp    8011b5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80118d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801196:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8011a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8011a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ab:	89 04 24             	mov    %eax,(%esp)
  8011ae:	e8 1d f6 ff ff       	call   8007d0 <fd2num>
  8011b3:	89 c3                	mov    %eax,%ebx
}
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	83 c4 20             	add    $0x20,%esp
  8011ba:	5b                   	pop    %ebx
  8011bb:	5e                   	pop    %esi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8011c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d5:	89 04 24             	mov    %eax,(%esp)
  8011d8:	e8 79 01 00 00       	call   801356 <nsipc_socket>
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 05                	js     8011e6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8011e1:	e8 61 ff ff ff       	call   801147 <alloc_sockfd>
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8011ee:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011f5:	89 04 24             	mov    %eax,(%esp)
  8011f8:	e8 70 f6 ff ff       	call   80086d <fd_lookup>
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 15                	js     801216 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801201:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801204:	8b 0a                	mov    (%edx),%ecx
  801206:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80120b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801211:	75 03                	jne    801216 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801213:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
  801221:	e8 c2 ff ff ff       	call   8011e8 <fd2sockid>
  801226:	85 c0                	test   %eax,%eax
  801228:	78 0f                	js     801239 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80122a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801231:	89 04 24             	mov    %eax,(%esp)
  801234:	e8 47 01 00 00       	call   801380 <nsipc_listen>
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801241:	8b 45 08             	mov    0x8(%ebp),%eax
  801244:	e8 9f ff ff ff       	call   8011e8 <fd2sockid>
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 16                	js     801263 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80124d:	8b 55 10             	mov    0x10(%ebp),%edx
  801250:	89 54 24 08          	mov    %edx,0x8(%esp)
  801254:	8b 55 0c             	mov    0xc(%ebp),%edx
  801257:	89 54 24 04          	mov    %edx,0x4(%esp)
  80125b:	89 04 24             	mov    %eax,(%esp)
  80125e:	e8 6e 02 00 00       	call   8014d1 <nsipc_connect>
}
  801263:	c9                   	leave  
  801264:	c3                   	ret    

00801265 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	e8 75 ff ff ff       	call   8011e8 <fd2sockid>
  801273:	85 c0                	test   %eax,%eax
  801275:	78 0f                	js     801286 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801277:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80127e:	89 04 24             	mov    %eax,(%esp)
  801281:	e8 36 01 00 00       	call   8013bc <nsipc_shutdown>
}
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	e8 52 ff ff ff       	call   8011e8 <fd2sockid>
  801296:	85 c0                	test   %eax,%eax
  801298:	78 16                	js     8012b0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80129a:	8b 55 10             	mov    0x10(%ebp),%edx
  80129d:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012a8:	89 04 24             	mov    %eax,(%esp)
  8012ab:	e8 60 02 00 00       	call   801510 <nsipc_bind>
}
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    

008012b2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bb:	e8 28 ff ff ff       	call   8011e8 <fd2sockid>
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 1f                	js     8012e3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8012c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8012c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012d2:	89 04 24             	mov    %eax,(%esp)
  8012d5:	e8 75 02 00 00       	call   80154f <nsipc_accept>
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 05                	js     8012e3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8012de:	e8 64 fe ff ff       	call   801147 <alloc_sockfd>
}
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    
	...

008012f0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 14             	sub    $0x14,%esp
  8012f7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8012f9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801300:	75 11                	jne    801313 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801302:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801309:	e8 c2 10 00 00       	call   8023d0 <ipc_find_env>
  80130e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801313:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80131a:	00 
  80131b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801322:	00 
  801323:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801327:	a1 04 40 80 00       	mov    0x804004,%eax
  80132c:	89 04 24             	mov    %eax,(%esp)
  80132f:	e8 e7 10 00 00       	call   80241b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801334:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80133b:	00 
  80133c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801343:	00 
  801344:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80134b:	e8 49 11 00 00       	call   802499 <ipc_recv>
}
  801350:	83 c4 14             	add    $0x14,%esp
  801353:	5b                   	pop    %ebx
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80135c:	8b 45 08             	mov    0x8(%ebp),%eax
  80135f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801364:	8b 45 0c             	mov    0xc(%ebp),%eax
  801367:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80136c:	8b 45 10             	mov    0x10(%ebp),%eax
  80136f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801374:	b8 09 00 00 00       	mov    $0x9,%eax
  801379:	e8 72 ff ff ff       	call   8012f0 <nsipc>
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
  801389:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80138e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801391:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801396:	b8 06 00 00 00       	mov    $0x6,%eax
  80139b:	e8 50 ff ff ff       	call   8012f0 <nsipc>
}
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8013a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ab:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8013b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8013b5:	e8 36 ff ff ff       	call   8012f0 <nsipc>
}
  8013ba:	c9                   	leave  
  8013bb:	c3                   	ret    

008013bc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8013c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8013ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8013d2:	b8 03 00 00 00       	mov    $0x3,%eax
  8013d7:	e8 14 ff ff ff       	call   8012f0 <nsipc>
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 14             	sub    $0x14,%esp
  8013e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8013e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013eb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8013f0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8013f6:	7e 24                	jle    80141c <nsipc_send+0x3e>
  8013f8:	c7 44 24 0c 8c 28 80 	movl   $0x80288c,0xc(%esp)
  8013ff:	00 
  801400:	c7 44 24 08 98 28 80 	movl   $0x802898,0x8(%esp)
  801407:	00 
  801408:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80140f:	00 
  801410:	c7 04 24 ad 28 80 00 	movl   $0x8028ad,(%esp)
  801417:	e8 88 01 00 00       	call   8015a4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80141c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801420:	8b 45 0c             	mov    0xc(%ebp),%eax
  801423:	89 44 24 04          	mov    %eax,0x4(%esp)
  801427:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80142e:	e8 42 0d 00 00       	call   802175 <memmove>
	nsipcbuf.send.req_size = size;
  801433:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801439:	8b 45 14             	mov    0x14(%ebp),%eax
  80143c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801441:	b8 08 00 00 00       	mov    $0x8,%eax
  801446:	e8 a5 fe ff ff       	call   8012f0 <nsipc>
}
  80144b:	83 c4 14             	add    $0x14,%esp
  80144e:	5b                   	pop    %ebx
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
  801456:	83 ec 10             	sub    $0x10,%esp
  801459:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80145c:	8b 45 08             	mov    0x8(%ebp),%eax
  80145f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801464:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80146a:	8b 45 14             	mov    0x14(%ebp),%eax
  80146d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801472:	b8 07 00 00 00       	mov    $0x7,%eax
  801477:	e8 74 fe ff ff       	call   8012f0 <nsipc>
  80147c:	89 c3                	mov    %eax,%ebx
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 46                	js     8014c8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801482:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801487:	7f 04                	jg     80148d <nsipc_recv+0x3c>
  801489:	39 c6                	cmp    %eax,%esi
  80148b:	7d 24                	jge    8014b1 <nsipc_recv+0x60>
  80148d:	c7 44 24 0c b9 28 80 	movl   $0x8028b9,0xc(%esp)
  801494:	00 
  801495:	c7 44 24 08 98 28 80 	movl   $0x802898,0x8(%esp)
  80149c:	00 
  80149d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8014a4:	00 
  8014a5:	c7 04 24 ad 28 80 00 	movl   $0x8028ad,(%esp)
  8014ac:	e8 f3 00 00 00       	call   8015a4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8014b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8014bc:	00 
  8014bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c0:	89 04 24             	mov    %eax,(%esp)
  8014c3:	e8 ad 0c 00 00       	call   802175 <memmove>
	}

	return r;
}
  8014c8:	89 d8                	mov    %ebx,%eax
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	5b                   	pop    %ebx
  8014ce:	5e                   	pop    %esi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 14             	sub    $0x14,%esp
  8014d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8014db:	8b 45 08             	mov    0x8(%ebp),%eax
  8014de:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8014e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ee:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8014f5:	e8 7b 0c 00 00       	call   802175 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8014fa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801500:	b8 05 00 00 00       	mov    $0x5,%eax
  801505:	e8 e6 fd ff ff       	call   8012f0 <nsipc>
}
  80150a:	83 c4 14             	add    $0x14,%esp
  80150d:	5b                   	pop    %ebx
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    

00801510 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	53                   	push   %ebx
  801514:	83 ec 14             	sub    $0x14,%esp
  801517:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
  80151d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801522:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801526:	8b 45 0c             	mov    0xc(%ebp),%eax
  801529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801534:	e8 3c 0c 00 00       	call   802175 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801539:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80153f:	b8 02 00 00 00       	mov    $0x2,%eax
  801544:	e8 a7 fd ff ff       	call   8012f0 <nsipc>
}
  801549:	83 c4 14             	add    $0x14,%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 18             	sub    $0x18,%esp
  801555:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801558:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801563:	b8 01 00 00 00       	mov    $0x1,%eax
  801568:	e8 83 fd ff ff       	call   8012f0 <nsipc>
  80156d:	89 c3                	mov    %eax,%ebx
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 25                	js     801598 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801573:	be 10 60 80 00       	mov    $0x806010,%esi
  801578:	8b 06                	mov    (%esi),%eax
  80157a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801585:	00 
  801586:	8b 45 0c             	mov    0xc(%ebp),%eax
  801589:	89 04 24             	mov    %eax,(%esp)
  80158c:	e8 e4 0b 00 00       	call   802175 <memmove>
		*addrlen = ret->ret_addrlen;
  801591:	8b 16                	mov    (%esi),%edx
  801593:	8b 45 10             	mov    0x10(%ebp),%eax
  801596:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80159d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015a0:	89 ec                	mov    %ebp,%esp
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8015ac:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015af:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8015b5:	e8 3d f1 ff ff       	call   8006f7 <sys_getenvid>
  8015ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d0:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  8015d7:	e8 81 00 00 00       	call   80165d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015e3:	89 04 24             	mov    %eax,(%esp)
  8015e6:	e8 11 00 00 00       	call   8015fc <vcprintf>
	cprintf("\n");
  8015eb:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  8015f2:	e8 66 00 00 00       	call   80165d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015f7:	cc                   	int3   
  8015f8:	eb fd                	jmp    8015f7 <_panic+0x53>
	...

008015fc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801605:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80160c:	00 00 00 
	b.cnt = 0;
  80160f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801616:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801619:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	89 44 24 08          	mov    %eax,0x8(%esp)
  801627:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80162d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801631:	c7 04 24 77 16 80 00 	movl   $0x801677,(%esp)
  801638:	e8 cf 01 00 00       	call   80180c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80163d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801643:	89 44 24 04          	mov    %eax,0x4(%esp)
  801647:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80164d:	89 04 24             	mov    %eax,(%esp)
  801650:	e8 b7 ea ff ff       	call   80010c <sys_cputs>

	return b.cnt;
}
  801655:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801663:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166a:	8b 45 08             	mov    0x8(%ebp),%eax
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	e8 87 ff ff ff       	call   8015fc <vcprintf>
	va_end(ap);

	return cnt;
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 14             	sub    $0x14,%esp
  80167e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801681:	8b 03                	mov    (%ebx),%eax
  801683:	8b 55 08             	mov    0x8(%ebp),%edx
  801686:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80168a:	83 c0 01             	add    $0x1,%eax
  80168d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80168f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801694:	75 19                	jne    8016af <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801696:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80169d:	00 
  80169e:	8d 43 08             	lea    0x8(%ebx),%eax
  8016a1:	89 04 24             	mov    %eax,(%esp)
  8016a4:	e8 63 ea ff ff       	call   80010c <sys_cputs>
		b->idx = 0;
  8016a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8016af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016b3:	83 c4 14             	add    $0x14,%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    
  8016b9:	00 00                	add    %al,(%eax)
  8016bb:	00 00                	add    %al,(%eax)
  8016bd:	00 00                	add    %al,(%eax)
	...

008016c0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	57                   	push   %edi
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 4c             	sub    $0x4c,%esp
  8016c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016cc:	89 d6                	mov    %edx,%esi
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8016da:	8b 45 10             	mov    0x10(%ebp),%eax
  8016dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8016e0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8016e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016eb:	39 d1                	cmp    %edx,%ecx
  8016ed:	72 07                	jb     8016f6 <printnum_v2+0x36>
  8016ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016f2:	39 d0                	cmp    %edx,%eax
  8016f4:	77 5f                	ja     801755 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8016f6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8016fa:	83 eb 01             	sub    $0x1,%ebx
  8016fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801701:	89 44 24 08          	mov    %eax,0x8(%esp)
  801705:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801709:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80170d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801710:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801713:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801716:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801721:	00 
  801722:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801725:	89 04 24             	mov    %eax,(%esp)
  801728:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80172b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80172f:	e8 1c 0e 00 00       	call   802550 <__udivdi3>
  801734:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801737:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80173a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80173e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801742:	89 04 24             	mov    %eax,(%esp)
  801745:	89 54 24 04          	mov    %edx,0x4(%esp)
  801749:	89 f2                	mov    %esi,%edx
  80174b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80174e:	e8 6d ff ff ff       	call   8016c0 <printnum_v2>
  801753:	eb 1e                	jmp    801773 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801755:	83 ff 2d             	cmp    $0x2d,%edi
  801758:	74 19                	je     801773 <printnum_v2+0xb3>
		while (--width > 0)
  80175a:	83 eb 01             	sub    $0x1,%ebx
  80175d:	85 db                	test   %ebx,%ebx
  80175f:	90                   	nop
  801760:	7e 11                	jle    801773 <printnum_v2+0xb3>
			putch(padc, putdat);
  801762:	89 74 24 04          	mov    %esi,0x4(%esp)
  801766:	89 3c 24             	mov    %edi,(%esp)
  801769:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80176c:	83 eb 01             	sub    $0x1,%ebx
  80176f:	85 db                	test   %ebx,%ebx
  801771:	7f ef                	jg     801762 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801773:	89 74 24 04          	mov    %esi,0x4(%esp)
  801777:	8b 74 24 04          	mov    0x4(%esp),%esi
  80177b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80177e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801782:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801789:	00 
  80178a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80178d:	89 14 24             	mov    %edx,(%esp)
  801790:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801793:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801797:	e8 e4 0e 00 00       	call   802680 <__umoddi3>
  80179c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a0:	0f be 80 f3 28 80 00 	movsbl 0x8028f3(%eax),%eax
  8017a7:	89 04 24             	mov    %eax,(%esp)
  8017aa:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8017ad:	83 c4 4c             	add    $0x4c,%esp
  8017b0:	5b                   	pop    %ebx
  8017b1:	5e                   	pop    %esi
  8017b2:	5f                   	pop    %edi
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017b8:	83 fa 01             	cmp    $0x1,%edx
  8017bb:	7e 0e                	jle    8017cb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017bd:	8b 10                	mov    (%eax),%edx
  8017bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017c2:	89 08                	mov    %ecx,(%eax)
  8017c4:	8b 02                	mov    (%edx),%eax
  8017c6:	8b 52 04             	mov    0x4(%edx),%edx
  8017c9:	eb 22                	jmp    8017ed <getuint+0x38>
	else if (lflag)
  8017cb:	85 d2                	test   %edx,%edx
  8017cd:	74 10                	je     8017df <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017cf:	8b 10                	mov    (%eax),%edx
  8017d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017d4:	89 08                	mov    %ecx,(%eax)
  8017d6:	8b 02                	mov    (%edx),%eax
  8017d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dd:	eb 0e                	jmp    8017ed <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017df:	8b 10                	mov    (%eax),%edx
  8017e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017e4:	89 08                	mov    %ecx,(%eax)
  8017e6:	8b 02                	mov    (%edx),%eax
  8017e8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017f9:	8b 10                	mov    (%eax),%edx
  8017fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8017fe:	73 0a                	jae    80180a <sprintputch+0x1b>
		*b->buf++ = ch;
  801800:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801803:	88 0a                	mov    %cl,(%edx)
  801805:	83 c2 01             	add    $0x1,%edx
  801808:	89 10                	mov    %edx,(%eax)
}
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	57                   	push   %edi
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	83 ec 6c             	sub    $0x6c,%esp
  801815:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801818:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80181f:	eb 1a                	jmp    80183b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801821:	85 c0                	test   %eax,%eax
  801823:	0f 84 66 06 00 00    	je     801e8f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  801829:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801830:	89 04 24             	mov    %eax,(%esp)
  801833:	ff 55 08             	call   *0x8(%ebp)
  801836:	eb 03                	jmp    80183b <vprintfmt+0x2f>
  801838:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80183b:	0f b6 07             	movzbl (%edi),%eax
  80183e:	83 c7 01             	add    $0x1,%edi
  801841:	83 f8 25             	cmp    $0x25,%eax
  801844:	75 db                	jne    801821 <vprintfmt+0x15>
  801846:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80184a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80184f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801856:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80185b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801862:	be 00 00 00 00       	mov    $0x0,%esi
  801867:	eb 06                	jmp    80186f <vprintfmt+0x63>
  801869:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80186d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186f:	0f b6 17             	movzbl (%edi),%edx
  801872:	0f b6 c2             	movzbl %dl,%eax
  801875:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801878:	8d 47 01             	lea    0x1(%edi),%eax
  80187b:	83 ea 23             	sub    $0x23,%edx
  80187e:	80 fa 55             	cmp    $0x55,%dl
  801881:	0f 87 60 05 00 00    	ja     801de7 <vprintfmt+0x5db>
  801887:	0f b6 d2             	movzbl %dl,%edx
  80188a:	ff 24 95 e0 2a 80 00 	jmp    *0x802ae0(,%edx,4)
  801891:	b9 01 00 00 00       	mov    $0x1,%ecx
  801896:	eb d5                	jmp    80186d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801898:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80189b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80189e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8018a1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8018a4:	83 ff 09             	cmp    $0x9,%edi
  8018a7:	76 08                	jbe    8018b1 <vprintfmt+0xa5>
  8018a9:	eb 40                	jmp    8018eb <vprintfmt+0xdf>
  8018ab:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8018af:	eb bc                	jmp    80186d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018b1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8018b4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8018b7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8018bb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8018be:	8d 7a d0             	lea    -0x30(%edx),%edi
  8018c1:	83 ff 09             	cmp    $0x9,%edi
  8018c4:	76 eb                	jbe    8018b1 <vprintfmt+0xa5>
  8018c6:	eb 23                	jmp    8018eb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8018cb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8018ce:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8018d1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8018d3:	eb 16                	jmp    8018eb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8018d5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018d8:	c1 fa 1f             	sar    $0x1f,%edx
  8018db:	f7 d2                	not    %edx
  8018dd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8018e0:	eb 8b                	jmp    80186d <vprintfmt+0x61>
  8018e2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8018e9:	eb 82                	jmp    80186d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8018eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ef:	0f 89 78 ff ff ff    	jns    80186d <vprintfmt+0x61>
  8018f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8018f8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8018fb:	e9 6d ff ff ff       	jmp    80186d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801900:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  801903:	e9 65 ff ff ff       	jmp    80186d <vprintfmt+0x61>
  801908:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80190b:	8b 45 14             	mov    0x14(%ebp),%eax
  80190e:	8d 50 04             	lea    0x4(%eax),%edx
  801911:	89 55 14             	mov    %edx,0x14(%ebp)
  801914:	8b 55 0c             	mov    0xc(%ebp),%edx
  801917:	89 54 24 04          	mov    %edx,0x4(%esp)
  80191b:	8b 00                	mov    (%eax),%eax
  80191d:	89 04 24             	mov    %eax,(%esp)
  801920:	ff 55 08             	call   *0x8(%ebp)
  801923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801926:	e9 10 ff ff ff       	jmp    80183b <vprintfmt+0x2f>
  80192b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80192e:	8b 45 14             	mov    0x14(%ebp),%eax
  801931:	8d 50 04             	lea    0x4(%eax),%edx
  801934:	89 55 14             	mov    %edx,0x14(%ebp)
  801937:	8b 00                	mov    (%eax),%eax
  801939:	89 c2                	mov    %eax,%edx
  80193b:	c1 fa 1f             	sar    $0x1f,%edx
  80193e:	31 d0                	xor    %edx,%eax
  801940:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801942:	83 f8 0f             	cmp    $0xf,%eax
  801945:	7f 0b                	jg     801952 <vprintfmt+0x146>
  801947:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  80194e:	85 d2                	test   %edx,%edx
  801950:	75 26                	jne    801978 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801952:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801956:	c7 44 24 08 04 29 80 	movl   $0x802904,0x8(%esp)
  80195d:	00 
  80195e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801961:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801965:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801968:	89 1c 24             	mov    %ebx,(%esp)
  80196b:	e8 a7 05 00 00       	call   801f17 <printfmt>
  801970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801973:	e9 c3 fe ff ff       	jmp    80183b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801978:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80197c:	c7 44 24 08 aa 28 80 	movl   $0x8028aa,0x8(%esp)
  801983:	00 
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
  801987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198b:	8b 55 08             	mov    0x8(%ebp),%edx
  80198e:	89 14 24             	mov    %edx,(%esp)
  801991:	e8 81 05 00 00       	call   801f17 <printfmt>
  801996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801999:	e9 9d fe ff ff       	jmp    80183b <vprintfmt+0x2f>
  80199e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019a1:	89 c7                	mov    %eax,%edi
  8019a3:	89 d9                	mov    %ebx,%ecx
  8019a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019a8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ae:	8d 50 04             	lea    0x4(%eax),%edx
  8019b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b4:	8b 30                	mov    (%eax),%esi
  8019b6:	85 f6                	test   %esi,%esi
  8019b8:	75 05                	jne    8019bf <vprintfmt+0x1b3>
  8019ba:	be 0d 29 80 00       	mov    $0x80290d,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8019bf:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8019c3:	7e 06                	jle    8019cb <vprintfmt+0x1bf>
  8019c5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8019c9:	75 10                	jne    8019db <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019cb:	0f be 06             	movsbl (%esi),%eax
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	0f 85 a2 00 00 00    	jne    801a78 <vprintfmt+0x26c>
  8019d6:	e9 92 00 00 00       	jmp    801a6d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019df:	89 34 24             	mov    %esi,(%esp)
  8019e2:	e8 74 05 00 00       	call   801f5b <strnlen>
  8019e7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8019ea:	29 c2                	sub    %eax,%edx
  8019ec:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8019ef:	85 d2                	test   %edx,%edx
  8019f1:	7e d8                	jle    8019cb <vprintfmt+0x1bf>
					putch(padc, putdat);
  8019f3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8019f7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8019fa:	89 d3                	mov    %edx,%ebx
  8019fc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8019ff:	89 7d bc             	mov    %edi,-0x44(%ebp)
  801a02:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a05:	89 ce                	mov    %ecx,%esi
  801a07:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a0b:	89 34 24             	mov    %esi,(%esp)
  801a0e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a11:	83 eb 01             	sub    $0x1,%ebx
  801a14:	85 db                	test   %ebx,%ebx
  801a16:	7f ef                	jg     801a07 <vprintfmt+0x1fb>
  801a18:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  801a1b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801a1e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  801a21:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801a28:	eb a1                	jmp    8019cb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a2a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  801a2e:	74 1b                	je     801a4b <vprintfmt+0x23f>
  801a30:	8d 50 e0             	lea    -0x20(%eax),%edx
  801a33:	83 fa 5e             	cmp    $0x5e,%edx
  801a36:	76 13                	jbe    801a4b <vprintfmt+0x23f>
					putch('?', putdat);
  801a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801a46:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a49:	eb 0d                	jmp    801a58 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a52:	89 04 24             	mov    %eax,(%esp)
  801a55:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a58:	83 ef 01             	sub    $0x1,%edi
  801a5b:	0f be 06             	movsbl (%esi),%eax
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	74 05                	je     801a67 <vprintfmt+0x25b>
  801a62:	83 c6 01             	add    $0x1,%esi
  801a65:	eb 1a                	jmp    801a81 <vprintfmt+0x275>
  801a67:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a6a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a6d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a71:	7f 1f                	jg     801a92 <vprintfmt+0x286>
  801a73:	e9 c0 fd ff ff       	jmp    801838 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a78:	83 c6 01             	add    $0x1,%esi
  801a7b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801a7e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801a81:	85 db                	test   %ebx,%ebx
  801a83:	78 a5                	js     801a2a <vprintfmt+0x21e>
  801a85:	83 eb 01             	sub    $0x1,%ebx
  801a88:	79 a0                	jns    801a2a <vprintfmt+0x21e>
  801a8a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a8d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801a90:	eb db                	jmp    801a6d <vprintfmt+0x261>
  801a92:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801a95:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a98:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a9b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801aa9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801aab:	83 eb 01             	sub    $0x1,%ebx
  801aae:	85 db                	test   %ebx,%ebx
  801ab0:	7f ec                	jg     801a9e <vprintfmt+0x292>
  801ab2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801ab5:	e9 81 fd ff ff       	jmp    80183b <vprintfmt+0x2f>
  801aba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801abd:	83 fe 01             	cmp    $0x1,%esi
  801ac0:	7e 10                	jle    801ad2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801ac2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac5:	8d 50 08             	lea    0x8(%eax),%edx
  801ac8:	89 55 14             	mov    %edx,0x14(%ebp)
  801acb:	8b 18                	mov    (%eax),%ebx
  801acd:	8b 70 04             	mov    0x4(%eax),%esi
  801ad0:	eb 26                	jmp    801af8 <vprintfmt+0x2ec>
	else if (lflag)
  801ad2:	85 f6                	test   %esi,%esi
  801ad4:	74 12                	je     801ae8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801ad6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad9:	8d 50 04             	lea    0x4(%eax),%edx
  801adc:	89 55 14             	mov    %edx,0x14(%ebp)
  801adf:	8b 18                	mov    (%eax),%ebx
  801ae1:	89 de                	mov    %ebx,%esi
  801ae3:	c1 fe 1f             	sar    $0x1f,%esi
  801ae6:	eb 10                	jmp    801af8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801ae8:	8b 45 14             	mov    0x14(%ebp),%eax
  801aeb:	8d 50 04             	lea    0x4(%eax),%edx
  801aee:	89 55 14             	mov    %edx,0x14(%ebp)
  801af1:	8b 18                	mov    (%eax),%ebx
  801af3:	89 de                	mov    %ebx,%esi
  801af5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  801af8:	83 f9 01             	cmp    $0x1,%ecx
  801afb:	75 1e                	jne    801b1b <vprintfmt+0x30f>
                               if((long long)num > 0){
  801afd:	85 f6                	test   %esi,%esi
  801aff:	78 1a                	js     801b1b <vprintfmt+0x30f>
  801b01:	85 f6                	test   %esi,%esi
  801b03:	7f 05                	jg     801b0a <vprintfmt+0x2fe>
  801b05:	83 fb 00             	cmp    $0x0,%ebx
  801b08:	76 11                	jbe    801b1b <vprintfmt+0x30f>
                                   putch('+',putdat);
  801b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b11:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  801b18:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  801b1b:	85 f6                	test   %esi,%esi
  801b1d:	78 13                	js     801b32 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b1f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  801b22:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  801b25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b28:	b8 0a 00 00 00       	mov    $0xa,%eax
  801b2d:	e9 da 00 00 00       	jmp    801c0c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  801b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b39:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801b40:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801b43:	89 da                	mov    %ebx,%edx
  801b45:	89 f1                	mov    %esi,%ecx
  801b47:	f7 da                	neg    %edx
  801b49:	83 d1 00             	adc    $0x0,%ecx
  801b4c:	f7 d9                	neg    %ecx
  801b4e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801b51:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801b54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b57:	b8 0a 00 00 00       	mov    $0xa,%eax
  801b5c:	e9 ab 00 00 00       	jmp    801c0c <vprintfmt+0x400>
  801b61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b64:	89 f2                	mov    %esi,%edx
  801b66:	8d 45 14             	lea    0x14(%ebp),%eax
  801b69:	e8 47 fc ff ff       	call   8017b5 <getuint>
  801b6e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801b71:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801b74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b77:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  801b7c:	e9 8b 00 00 00       	jmp    801c0c <vprintfmt+0x400>
  801b81:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b87:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b8b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b92:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801b95:	89 f2                	mov    %esi,%edx
  801b97:	8d 45 14             	lea    0x14(%ebp),%eax
  801b9a:	e8 16 fc ff ff       	call   8017b5 <getuint>
  801b9f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801ba2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801ba5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ba8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  801bad:	eb 5d                	jmp    801c0c <vprintfmt+0x400>
  801baf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801bb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bb9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801bc0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801bc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801bce:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801bd1:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd4:	8d 50 04             	lea    0x4(%eax),%edx
  801bd7:	89 55 14             	mov    %edx,0x14(%ebp)
  801bda:	8b 10                	mov    (%eax),%edx
  801bdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801be1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801be4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801be7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bea:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801bef:	eb 1b                	jmp    801c0c <vprintfmt+0x400>
  801bf1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bf4:	89 f2                	mov    %esi,%edx
  801bf6:	8d 45 14             	lea    0x14(%ebp),%eax
  801bf9:	e8 b7 fb ff ff       	call   8017b5 <getuint>
  801bfe:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801c01:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801c04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c07:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c0c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  801c10:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c13:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801c16:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  801c1a:	77 09                	ja     801c25 <vprintfmt+0x419>
  801c1c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  801c1f:	0f 82 ac 00 00 00    	jb     801cd1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801c25:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801c28:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801c2c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801c2f:	83 ea 01             	sub    $0x1,%edx
  801c32:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c36:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3a:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c3e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801c42:	89 45 c0             	mov    %eax,-0x40(%ebp)
  801c45:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801c48:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801c4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c4f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c56:	00 
  801c57:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801c5a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801c5d:	89 0c 24             	mov    %ecx,(%esp)
  801c60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c64:	e8 e7 08 00 00       	call   802550 <__udivdi3>
  801c69:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  801c6c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801c6f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c73:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c77:	89 04 24             	mov    %eax,(%esp)
  801c7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	e8 37 fa ff ff       	call   8016c0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c90:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c94:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801c97:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ca2:	00 
  801ca3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801ca6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801ca9:	89 14 24             	mov    %edx,(%esp)
  801cac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cb0:	e8 cb 09 00 00       	call   802680 <__umoddi3>
  801cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb9:	0f be 80 f3 28 80 00 	movsbl 0x8028f3(%eax),%eax
  801cc0:	89 04 24             	mov    %eax,(%esp)
  801cc3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801cc6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801cca:	74 54                	je     801d20 <vprintfmt+0x514>
  801ccc:	e9 67 fb ff ff       	jmp    801838 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801cd1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	0f 84 2a 01 00 00    	je     801e08 <vprintfmt+0x5fc>
		while (--width > 0)
  801cde:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801ce1:	83 ef 01             	sub    $0x1,%edi
  801ce4:	85 ff                	test   %edi,%edi
  801ce6:	0f 8e 5e 01 00 00    	jle    801e4a <vprintfmt+0x63e>
  801cec:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801cef:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801cf2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801cf5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801cf8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801cfb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  801cfe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d02:	89 1c 24             	mov    %ebx,(%esp)
  801d05:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  801d08:	83 ef 01             	sub    $0x1,%edi
  801d0b:	85 ff                	test   %edi,%edi
  801d0d:	7f ef                	jg     801cfe <vprintfmt+0x4f2>
  801d0f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d12:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801d15:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801d18:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801d1b:	e9 2a 01 00 00       	jmp    801e4a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801d20:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801d23:	83 eb 01             	sub    $0x1,%ebx
  801d26:	85 db                	test   %ebx,%ebx
  801d28:	0f 8e 0a fb ff ff    	jle    801838 <vprintfmt+0x2c>
  801d2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d31:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801d34:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  801d37:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801d42:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801d44:	83 eb 01             	sub    $0x1,%ebx
  801d47:	85 db                	test   %ebx,%ebx
  801d49:	7f ec                	jg     801d37 <vprintfmt+0x52b>
  801d4b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801d4e:	e9 e8 fa ff ff       	jmp    80183b <vprintfmt+0x2f>
  801d53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801d56:	8b 45 14             	mov    0x14(%ebp),%eax
  801d59:	8d 50 04             	lea    0x4(%eax),%edx
  801d5c:	89 55 14             	mov    %edx,0x14(%ebp)
  801d5f:	8b 00                	mov    (%eax),%eax
  801d61:	85 c0                	test   %eax,%eax
  801d63:	75 2a                	jne    801d8f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801d65:	c7 44 24 0c 28 2a 80 	movl   $0x802a28,0xc(%esp)
  801d6c:	00 
  801d6d:	c7 44 24 08 aa 28 80 	movl   $0x8028aa,0x8(%esp)
  801d74:	00 
  801d75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d78:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7f:	89 0c 24             	mov    %ecx,(%esp)
  801d82:	e8 90 01 00 00       	call   801f17 <printfmt>
  801d87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d8a:	e9 ac fa ff ff       	jmp    80183b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  801d8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d92:	8b 13                	mov    (%ebx),%edx
  801d94:	83 fa 7f             	cmp    $0x7f,%edx
  801d97:	7e 29                	jle    801dc2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801d99:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  801d9b:	c7 44 24 0c 60 2a 80 	movl   $0x802a60,0xc(%esp)
  801da2:	00 
  801da3:	c7 44 24 08 aa 28 80 	movl   $0x8028aa,0x8(%esp)
  801daa:	00 
  801dab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801daf:	8b 45 08             	mov    0x8(%ebp),%eax
  801db2:	89 04 24             	mov    %eax,(%esp)
  801db5:	e8 5d 01 00 00       	call   801f17 <printfmt>
  801dba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dbd:	e9 79 fa ff ff       	jmp    80183b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801dc2:	88 10                	mov    %dl,(%eax)
  801dc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dc7:	e9 6f fa ff ff       	jmp    80183b <vprintfmt+0x2f>
  801dcc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801dcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801dd9:	89 14 24             	mov    %edx,(%esp)
  801ddc:	ff 55 08             	call   *0x8(%ebp)
  801ddf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801de2:	e9 54 fa ff ff       	jmp    80183b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801de7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801df5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801df8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801dfb:	80 38 25             	cmpb   $0x25,(%eax)
  801dfe:	0f 84 37 fa ff ff    	je     80183b <vprintfmt+0x2f>
  801e04:	89 c7                	mov    %eax,%edi
  801e06:	eb f0                	jmp    801df8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801e08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0f:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e13:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801e16:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e21:	00 
  801e22:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801e25:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801e28:	89 04 24             	mov    %eax,(%esp)
  801e2b:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e2f:	e8 4c 08 00 00       	call   802680 <__umoddi3>
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	0f be 80 f3 28 80 00 	movsbl 0x8028f3(%eax),%eax
  801e3f:	89 04 24             	mov    %eax,(%esp)
  801e42:	ff 55 08             	call   *0x8(%ebp)
  801e45:	e9 d6 fe ff ff       	jmp    801d20 <vprintfmt+0x514>
  801e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e51:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e55:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e5c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e63:	00 
  801e64:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801e67:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801e6a:	89 04 24             	mov    %eax,(%esp)
  801e6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e71:	e8 0a 08 00 00       	call   802680 <__umoddi3>
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	0f be 80 f3 28 80 00 	movsbl 0x8028f3(%eax),%eax
  801e81:	89 04 24             	mov    %eax,(%esp)
  801e84:	ff 55 08             	call   *0x8(%ebp)
  801e87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e8a:	e9 ac f9 ff ff       	jmp    80183b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801e8f:	83 c4 6c             	add    $0x6c,%esp
  801e92:	5b                   	pop    %ebx
  801e93:	5e                   	pop    %esi
  801e94:	5f                   	pop    %edi
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	83 ec 28             	sub    $0x28,%esp
  801e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	74 04                	je     801eab <vsnprintf+0x14>
  801ea7:	85 d2                	test   %edx,%edx
  801ea9:	7f 07                	jg     801eb2 <vsnprintf+0x1b>
  801eab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801eb0:	eb 3b                	jmp    801eed <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801eb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801eb5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801ebc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ec3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eca:	8b 45 10             	mov    0x10(%ebp),%eax
  801ecd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ed1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed8:	c7 04 24 ef 17 80 00 	movl   $0x8017ef,(%esp)
  801edf:	e8 28 f9 ff ff       	call   80180c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ee7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801ef5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801ef8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801efc:	8b 45 10             	mov    0x10(%ebp),%eax
  801eff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0d:	89 04 24             	mov    %eax,(%esp)
  801f10:	e8 82 ff ff ff       	call   801e97 <vsnprintf>
	va_end(ap);

	return rc;
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801f1d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801f20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f24:	8b 45 10             	mov    0x10(%ebp),%eax
  801f27:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f32:	8b 45 08             	mov    0x8(%ebp),%eax
  801f35:	89 04 24             	mov    %eax,(%esp)
  801f38:	e8 cf f8 ff ff       	call   80180c <vprintfmt>
	va_end(ap);
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    
	...

00801f40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4b:	80 3a 00             	cmpb   $0x0,(%edx)
  801f4e:	74 09                	je     801f59 <strlen+0x19>
		n++;
  801f50:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801f53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801f57:	75 f7                	jne    801f50 <strlen+0x10>
		n++;
	return n;
}
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    

00801f5b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	53                   	push   %ebx
  801f5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801f65:	85 c9                	test   %ecx,%ecx
  801f67:	74 19                	je     801f82 <strnlen+0x27>
  801f69:	80 3b 00             	cmpb   $0x0,(%ebx)
  801f6c:	74 14                	je     801f82 <strnlen+0x27>
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801f73:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801f76:	39 c8                	cmp    %ecx,%eax
  801f78:	74 0d                	je     801f87 <strnlen+0x2c>
  801f7a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801f7e:	75 f3                	jne    801f73 <strnlen+0x18>
  801f80:	eb 05                	jmp    801f87 <strnlen+0x2c>
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801f87:	5b                   	pop    %ebx
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	53                   	push   %ebx
  801f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f94:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801f99:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801f9d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801fa0:	83 c2 01             	add    $0x1,%edx
  801fa3:	84 c9                	test   %cl,%cl
  801fa5:	75 f2                	jne    801f99 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801fa7:	5b                   	pop    %ebx
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <strcat>:

char *
strcat(char *dst, const char *src)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	53                   	push   %ebx
  801fae:	83 ec 08             	sub    $0x8,%esp
  801fb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801fb4:	89 1c 24             	mov    %ebx,(%esp)
  801fb7:	e8 84 ff ff ff       	call   801f40 <strlen>
	strcpy(dst + len, src);
  801fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fbf:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fc3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801fc6:	89 04 24             	mov    %eax,(%esp)
  801fc9:	e8 bc ff ff ff       	call   801f8a <strcpy>
	return dst;
}
  801fce:	89 d8                	mov    %ebx,%eax
  801fd0:	83 c4 08             	add    $0x8,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    

00801fd6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	56                   	push   %esi
  801fda:	53                   	push   %ebx
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801fe4:	85 f6                	test   %esi,%esi
  801fe6:	74 18                	je     802000 <strncpy+0x2a>
  801fe8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801fed:	0f b6 1a             	movzbl (%edx),%ebx
  801ff0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ff3:	80 3a 01             	cmpb   $0x1,(%edx)
  801ff6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ff9:	83 c1 01             	add    $0x1,%ecx
  801ffc:	39 ce                	cmp    %ecx,%esi
  801ffe:	77 ed                	ja     801fed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802000:	5b                   	pop    %ebx
  802001:	5e                   	pop    %esi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    

00802004 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	56                   	push   %esi
  802008:	53                   	push   %ebx
  802009:	8b 75 08             	mov    0x8(%ebp),%esi
  80200c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802012:	89 f0                	mov    %esi,%eax
  802014:	85 c9                	test   %ecx,%ecx
  802016:	74 27                	je     80203f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  802018:	83 e9 01             	sub    $0x1,%ecx
  80201b:	74 1d                	je     80203a <strlcpy+0x36>
  80201d:	0f b6 1a             	movzbl (%edx),%ebx
  802020:	84 db                	test   %bl,%bl
  802022:	74 16                	je     80203a <strlcpy+0x36>
			*dst++ = *src++;
  802024:	88 18                	mov    %bl,(%eax)
  802026:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802029:	83 e9 01             	sub    $0x1,%ecx
  80202c:	74 0e                	je     80203c <strlcpy+0x38>
			*dst++ = *src++;
  80202e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802031:	0f b6 1a             	movzbl (%edx),%ebx
  802034:	84 db                	test   %bl,%bl
  802036:	75 ec                	jne    802024 <strlcpy+0x20>
  802038:	eb 02                	jmp    80203c <strlcpy+0x38>
  80203a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80203c:	c6 00 00             	movb   $0x0,(%eax)
  80203f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80204b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80204e:	0f b6 01             	movzbl (%ecx),%eax
  802051:	84 c0                	test   %al,%al
  802053:	74 15                	je     80206a <strcmp+0x25>
  802055:	3a 02                	cmp    (%edx),%al
  802057:	75 11                	jne    80206a <strcmp+0x25>
		p++, q++;
  802059:	83 c1 01             	add    $0x1,%ecx
  80205c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80205f:	0f b6 01             	movzbl (%ecx),%eax
  802062:	84 c0                	test   %al,%al
  802064:	74 04                	je     80206a <strcmp+0x25>
  802066:	3a 02                	cmp    (%edx),%al
  802068:	74 ef                	je     802059 <strcmp+0x14>
  80206a:	0f b6 c0             	movzbl %al,%eax
  80206d:	0f b6 12             	movzbl (%edx),%edx
  802070:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	53                   	push   %ebx
  802078:	8b 55 08             	mov    0x8(%ebp),%edx
  80207b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80207e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  802081:	85 c0                	test   %eax,%eax
  802083:	74 23                	je     8020a8 <strncmp+0x34>
  802085:	0f b6 1a             	movzbl (%edx),%ebx
  802088:	84 db                	test   %bl,%bl
  80208a:	74 25                	je     8020b1 <strncmp+0x3d>
  80208c:	3a 19                	cmp    (%ecx),%bl
  80208e:	75 21                	jne    8020b1 <strncmp+0x3d>
  802090:	83 e8 01             	sub    $0x1,%eax
  802093:	74 13                	je     8020a8 <strncmp+0x34>
		n--, p++, q++;
  802095:	83 c2 01             	add    $0x1,%edx
  802098:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80209b:	0f b6 1a             	movzbl (%edx),%ebx
  80209e:	84 db                	test   %bl,%bl
  8020a0:	74 0f                	je     8020b1 <strncmp+0x3d>
  8020a2:	3a 19                	cmp    (%ecx),%bl
  8020a4:	74 ea                	je     802090 <strncmp+0x1c>
  8020a6:	eb 09                	jmp    8020b1 <strncmp+0x3d>
  8020a8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8020ad:	5b                   	pop    %ebx
  8020ae:	5d                   	pop    %ebp
  8020af:	90                   	nop
  8020b0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020b1:	0f b6 02             	movzbl (%edx),%eax
  8020b4:	0f b6 11             	movzbl (%ecx),%edx
  8020b7:	29 d0                	sub    %edx,%eax
  8020b9:	eb f2                	jmp    8020ad <strncmp+0x39>

008020bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020c5:	0f b6 10             	movzbl (%eax),%edx
  8020c8:	84 d2                	test   %dl,%dl
  8020ca:	74 18                	je     8020e4 <strchr+0x29>
		if (*s == c)
  8020cc:	38 ca                	cmp    %cl,%dl
  8020ce:	75 0a                	jne    8020da <strchr+0x1f>
  8020d0:	eb 17                	jmp    8020e9 <strchr+0x2e>
  8020d2:	38 ca                	cmp    %cl,%dl
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	74 0f                	je     8020e9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8020da:	83 c0 01             	add    $0x1,%eax
  8020dd:	0f b6 10             	movzbl (%eax),%edx
  8020e0:	84 d2                	test   %dl,%dl
  8020e2:	75 ee                	jne    8020d2 <strchr+0x17>
  8020e4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8020e9:	5d                   	pop    %ebp
  8020ea:	c3                   	ret    

008020eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020f5:	0f b6 10             	movzbl (%eax),%edx
  8020f8:	84 d2                	test   %dl,%dl
  8020fa:	74 18                	je     802114 <strfind+0x29>
		if (*s == c)
  8020fc:	38 ca                	cmp    %cl,%dl
  8020fe:	75 0a                	jne    80210a <strfind+0x1f>
  802100:	eb 12                	jmp    802114 <strfind+0x29>
  802102:	38 ca                	cmp    %cl,%dl
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	74 0a                	je     802114 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80210a:	83 c0 01             	add    $0x1,%eax
  80210d:	0f b6 10             	movzbl (%eax),%edx
  802110:	84 d2                	test   %dl,%dl
  802112:	75 ee                	jne    802102 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	83 ec 0c             	sub    $0xc,%esp
  80211c:	89 1c 24             	mov    %ebx,(%esp)
  80211f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802123:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802127:	8b 7d 08             	mov    0x8(%ebp),%edi
  80212a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802130:	85 c9                	test   %ecx,%ecx
  802132:	74 30                	je     802164 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802134:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80213a:	75 25                	jne    802161 <memset+0x4b>
  80213c:	f6 c1 03             	test   $0x3,%cl
  80213f:	75 20                	jne    802161 <memset+0x4b>
		c &= 0xFF;
  802141:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802144:	89 d3                	mov    %edx,%ebx
  802146:	c1 e3 08             	shl    $0x8,%ebx
  802149:	89 d6                	mov    %edx,%esi
  80214b:	c1 e6 18             	shl    $0x18,%esi
  80214e:	89 d0                	mov    %edx,%eax
  802150:	c1 e0 10             	shl    $0x10,%eax
  802153:	09 f0                	or     %esi,%eax
  802155:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  802157:	09 d8                	or     %ebx,%eax
  802159:	c1 e9 02             	shr    $0x2,%ecx
  80215c:	fc                   	cld    
  80215d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80215f:	eb 03                	jmp    802164 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802161:	fc                   	cld    
  802162:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802164:	89 f8                	mov    %edi,%eax
  802166:	8b 1c 24             	mov    (%esp),%ebx
  802169:	8b 74 24 04          	mov    0x4(%esp),%esi
  80216d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802171:	89 ec                	mov    %ebp,%esp
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    

00802175 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 08             	sub    $0x8,%esp
  80217b:	89 34 24             	mov    %esi,(%esp)
  80217e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802182:	8b 45 08             	mov    0x8(%ebp),%eax
  802185:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  802188:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80218b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80218d:	39 c6                	cmp    %eax,%esi
  80218f:	73 35                	jae    8021c6 <memmove+0x51>
  802191:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802194:	39 d0                	cmp    %edx,%eax
  802196:	73 2e                	jae    8021c6 <memmove+0x51>
		s += n;
		d += n;
  802198:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80219a:	f6 c2 03             	test   $0x3,%dl
  80219d:	75 1b                	jne    8021ba <memmove+0x45>
  80219f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8021a5:	75 13                	jne    8021ba <memmove+0x45>
  8021a7:	f6 c1 03             	test   $0x3,%cl
  8021aa:	75 0e                	jne    8021ba <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8021ac:	83 ef 04             	sub    $0x4,%edi
  8021af:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021b2:	c1 e9 02             	shr    $0x2,%ecx
  8021b5:	fd                   	std    
  8021b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b8:	eb 09                	jmp    8021c3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021ba:	83 ef 01             	sub    $0x1,%edi
  8021bd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021c0:	fd                   	std    
  8021c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021c3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021c4:	eb 20                	jmp    8021e6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8021cc:	75 15                	jne    8021e3 <memmove+0x6e>
  8021ce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8021d4:	75 0d                	jne    8021e3 <memmove+0x6e>
  8021d6:	f6 c1 03             	test   $0x3,%cl
  8021d9:	75 08                	jne    8021e3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8021db:	c1 e9 02             	shr    $0x2,%ecx
  8021de:	fc                   	cld    
  8021df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021e1:	eb 03                	jmp    8021e6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021e3:	fc                   	cld    
  8021e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021e6:	8b 34 24             	mov    (%esp),%esi
  8021e9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021ed:	89 ec                	mov    %ebp,%esp
  8021ef:	5d                   	pop    %ebp
  8021f0:	c3                   	ret    

008021f1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8021f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8021fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802201:	89 44 24 04          	mov    %eax,0x4(%esp)
  802205:	8b 45 08             	mov    0x8(%ebp),%eax
  802208:	89 04 24             	mov    %eax,(%esp)
  80220b:	e8 65 ff ff ff       	call   802175 <memmove>
}
  802210:	c9                   	leave  
  802211:	c3                   	ret    

00802212 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802212:	55                   	push   %ebp
  802213:	89 e5                	mov    %esp,%ebp
  802215:	57                   	push   %edi
  802216:	56                   	push   %esi
  802217:	53                   	push   %ebx
  802218:	8b 75 08             	mov    0x8(%ebp),%esi
  80221b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80221e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802221:	85 c9                	test   %ecx,%ecx
  802223:	74 36                	je     80225b <memcmp+0x49>
		if (*s1 != *s2)
  802225:	0f b6 06             	movzbl (%esi),%eax
  802228:	0f b6 1f             	movzbl (%edi),%ebx
  80222b:	38 d8                	cmp    %bl,%al
  80222d:	74 20                	je     80224f <memcmp+0x3d>
  80222f:	eb 14                	jmp    802245 <memcmp+0x33>
  802231:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  802236:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80223b:	83 c2 01             	add    $0x1,%edx
  80223e:	83 e9 01             	sub    $0x1,%ecx
  802241:	38 d8                	cmp    %bl,%al
  802243:	74 12                	je     802257 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  802245:	0f b6 c0             	movzbl %al,%eax
  802248:	0f b6 db             	movzbl %bl,%ebx
  80224b:	29 d8                	sub    %ebx,%eax
  80224d:	eb 11                	jmp    802260 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80224f:	83 e9 01             	sub    $0x1,%ecx
  802252:	ba 00 00 00 00       	mov    $0x0,%edx
  802257:	85 c9                	test   %ecx,%ecx
  802259:	75 d6                	jne    802231 <memcmp+0x1f>
  80225b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802260:	5b                   	pop    %ebx
  802261:	5e                   	pop    %esi
  802262:	5f                   	pop    %edi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    

00802265 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802265:	55                   	push   %ebp
  802266:	89 e5                	mov    %esp,%ebp
  802268:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80226b:	89 c2                	mov    %eax,%edx
  80226d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802270:	39 d0                	cmp    %edx,%eax
  802272:	73 15                	jae    802289 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802274:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  802278:	38 08                	cmp    %cl,(%eax)
  80227a:	75 06                	jne    802282 <memfind+0x1d>
  80227c:	eb 0b                	jmp    802289 <memfind+0x24>
  80227e:	38 08                	cmp    %cl,(%eax)
  802280:	74 07                	je     802289 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802282:	83 c0 01             	add    $0x1,%eax
  802285:	39 c2                	cmp    %eax,%edx
  802287:	77 f5                	ja     80227e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802289:	5d                   	pop    %ebp
  80228a:	c3                   	ret    

0080228b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	57                   	push   %edi
  80228f:	56                   	push   %esi
  802290:	53                   	push   %ebx
  802291:	83 ec 04             	sub    $0x4,%esp
  802294:	8b 55 08             	mov    0x8(%ebp),%edx
  802297:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80229a:	0f b6 02             	movzbl (%edx),%eax
  80229d:	3c 20                	cmp    $0x20,%al
  80229f:	74 04                	je     8022a5 <strtol+0x1a>
  8022a1:	3c 09                	cmp    $0x9,%al
  8022a3:	75 0e                	jne    8022b3 <strtol+0x28>
		s++;
  8022a5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8022a8:	0f b6 02             	movzbl (%edx),%eax
  8022ab:	3c 20                	cmp    $0x20,%al
  8022ad:	74 f6                	je     8022a5 <strtol+0x1a>
  8022af:	3c 09                	cmp    $0x9,%al
  8022b1:	74 f2                	je     8022a5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8022b3:	3c 2b                	cmp    $0x2b,%al
  8022b5:	75 0c                	jne    8022c3 <strtol+0x38>
		s++;
  8022b7:	83 c2 01             	add    $0x1,%edx
  8022ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8022c1:	eb 15                	jmp    8022d8 <strtol+0x4d>
	else if (*s == '-')
  8022c3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8022ca:	3c 2d                	cmp    $0x2d,%al
  8022cc:	75 0a                	jne    8022d8 <strtol+0x4d>
		s++, neg = 1;
  8022ce:	83 c2 01             	add    $0x1,%edx
  8022d1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022d8:	85 db                	test   %ebx,%ebx
  8022da:	0f 94 c0             	sete   %al
  8022dd:	74 05                	je     8022e4 <strtol+0x59>
  8022df:	83 fb 10             	cmp    $0x10,%ebx
  8022e2:	75 18                	jne    8022fc <strtol+0x71>
  8022e4:	80 3a 30             	cmpb   $0x30,(%edx)
  8022e7:	75 13                	jne    8022fc <strtol+0x71>
  8022e9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	75 0a                	jne    8022fc <strtol+0x71>
		s += 2, base = 16;
  8022f2:	83 c2 02             	add    $0x2,%edx
  8022f5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022fa:	eb 15                	jmp    802311 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022fc:	84 c0                	test   %al,%al
  8022fe:	66 90                	xchg   %ax,%ax
  802300:	74 0f                	je     802311 <strtol+0x86>
  802302:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802307:	80 3a 30             	cmpb   $0x30,(%edx)
  80230a:	75 05                	jne    802311 <strtol+0x86>
		s++, base = 8;
  80230c:	83 c2 01             	add    $0x1,%edx
  80230f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802311:	b8 00 00 00 00       	mov    $0x0,%eax
  802316:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802318:	0f b6 0a             	movzbl (%edx),%ecx
  80231b:	89 cf                	mov    %ecx,%edi
  80231d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802320:	80 fb 09             	cmp    $0x9,%bl
  802323:	77 08                	ja     80232d <strtol+0xa2>
			dig = *s - '0';
  802325:	0f be c9             	movsbl %cl,%ecx
  802328:	83 e9 30             	sub    $0x30,%ecx
  80232b:	eb 1e                	jmp    80234b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80232d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  802330:	80 fb 19             	cmp    $0x19,%bl
  802333:	77 08                	ja     80233d <strtol+0xb2>
			dig = *s - 'a' + 10;
  802335:	0f be c9             	movsbl %cl,%ecx
  802338:	83 e9 57             	sub    $0x57,%ecx
  80233b:	eb 0e                	jmp    80234b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80233d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  802340:	80 fb 19             	cmp    $0x19,%bl
  802343:	77 15                	ja     80235a <strtol+0xcf>
			dig = *s - 'A' + 10;
  802345:	0f be c9             	movsbl %cl,%ecx
  802348:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80234b:	39 f1                	cmp    %esi,%ecx
  80234d:	7d 0b                	jge    80235a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80234f:	83 c2 01             	add    $0x1,%edx
  802352:	0f af c6             	imul   %esi,%eax
  802355:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  802358:	eb be                	jmp    802318 <strtol+0x8d>
  80235a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80235c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802360:	74 05                	je     802367 <strtol+0xdc>
		*endptr = (char *) s;
  802362:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802365:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802367:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80236b:	74 04                	je     802371 <strtol+0xe6>
  80236d:	89 c8                	mov    %ecx,%eax
  80236f:	f7 d8                	neg    %eax
}
  802371:	83 c4 04             	add    $0x4,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	00 00                	add    %al,(%eax)
	...

0080237c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80237c:	55                   	push   %ebp
  80237d:	89 e5                	mov    %esp,%ebp
  80237f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802382:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802389:	75 30                	jne    8023bb <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  80238b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802392:	00 
  802393:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80239a:	ee 
  80239b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023a2:	e8 61 e2 ff ff       	call   800608 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8023a7:	c7 44 24 04 a4 07 80 	movl   $0x8007a4,0x4(%esp)
  8023ae:	00 
  8023af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b6:	e8 2f e0 ff ff       	call   8003ea <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023be:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023c3:	c9                   	leave  
  8023c4:	c3                   	ret    
	...

008023d0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8023d6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8023dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e1:	39 ca                	cmp    %ecx,%edx
  8023e3:	75 04                	jne    8023e9 <ipc_find_env+0x19>
  8023e5:	b0 00                	mov    $0x0,%al
  8023e7:	eb 12                	jmp    8023fb <ipc_find_env+0x2b>
  8023e9:	89 c2                	mov    %eax,%edx
  8023eb:	c1 e2 07             	shl    $0x7,%edx
  8023ee:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  8023f5:	8b 12                	mov    (%edx),%edx
  8023f7:	39 ca                	cmp    %ecx,%edx
  8023f9:	75 10                	jne    80240b <ipc_find_env+0x3b>
			return envs[i].env_id;
  8023fb:	89 c2                	mov    %eax,%edx
  8023fd:	c1 e2 07             	shl    $0x7,%edx
  802400:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802407:	8b 00                	mov    (%eax),%eax
  802409:	eb 0e                	jmp    802419 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80240b:	83 c0 01             	add    $0x1,%eax
  80240e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802413:	75 d4                	jne    8023e9 <ipc_find_env+0x19>
  802415:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802419:	5d                   	pop    %ebp
  80241a:	c3                   	ret    

0080241b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80241b:	55                   	push   %ebp
  80241c:	89 e5                	mov    %esp,%ebp
  80241e:	57                   	push   %edi
  80241f:	56                   	push   %esi
  802420:	53                   	push   %ebx
  802421:	83 ec 1c             	sub    $0x1c,%esp
  802424:	8b 75 08             	mov    0x8(%ebp),%esi
  802427:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80242a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80242d:	85 db                	test   %ebx,%ebx
  80242f:	74 19                	je     80244a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  802431:	8b 45 14             	mov    0x14(%ebp),%eax
  802434:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802438:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80243c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802440:	89 34 24             	mov    %esi,(%esp)
  802443:	e8 61 df ff ff       	call   8003a9 <sys_ipc_try_send>
  802448:	eb 1b                	jmp    802465 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  80244a:	8b 45 14             	mov    0x14(%ebp),%eax
  80244d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802451:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802458:	ee 
  802459:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80245d:	89 34 24             	mov    %esi,(%esp)
  802460:	e8 44 df ff ff       	call   8003a9 <sys_ipc_try_send>
           if(ret == 0)
  802465:	85 c0                	test   %eax,%eax
  802467:	74 28                	je     802491 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  802469:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80246c:	74 1c                	je     80248a <ipc_send+0x6f>
              panic("ipc send error");
  80246e:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  802475:	00 
  802476:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  80247d:	00 
  80247e:	c7 04 24 8f 2c 80 00 	movl   $0x802c8f,(%esp)
  802485:	e8 1a f1 ff ff       	call   8015a4 <_panic>
           sys_yield();
  80248a:	e8 e6 e1 ff ff       	call   800675 <sys_yield>
        }
  80248f:	eb 9c                	jmp    80242d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802491:	83 c4 1c             	add    $0x1c,%esp
  802494:	5b                   	pop    %ebx
  802495:	5e                   	pop    %esi
  802496:	5f                   	pop    %edi
  802497:	5d                   	pop    %ebp
  802498:	c3                   	ret    

00802499 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802499:	55                   	push   %ebp
  80249a:	89 e5                	mov    %esp,%ebp
  80249c:	56                   	push   %esi
  80249d:	53                   	push   %ebx
  80249e:	83 ec 10             	sub    $0x10,%esp
  8024a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8024a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  8024aa:	85 c0                	test   %eax,%eax
  8024ac:	75 0e                	jne    8024bc <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  8024ae:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8024b5:	e8 84 de ff ff       	call   80033e <sys_ipc_recv>
  8024ba:	eb 08                	jmp    8024c4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  8024bc:	89 04 24             	mov    %eax,(%esp)
  8024bf:	e8 7a de ff ff       	call   80033e <sys_ipc_recv>
        if(ret == 0){
  8024c4:	85 c0                	test   %eax,%eax
  8024c6:	75 26                	jne    8024ee <ipc_recv+0x55>
           if(from_env_store)
  8024c8:	85 f6                	test   %esi,%esi
  8024ca:	74 0a                	je     8024d6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  8024cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8024d1:	8b 40 78             	mov    0x78(%eax),%eax
  8024d4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  8024d6:	85 db                	test   %ebx,%ebx
  8024d8:	74 0a                	je     8024e4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  8024da:	a1 08 40 80 00       	mov    0x804008,%eax
  8024df:	8b 40 7c             	mov    0x7c(%eax),%eax
  8024e2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  8024e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8024e9:	8b 40 74             	mov    0x74(%eax),%eax
  8024ec:	eb 14                	jmp    802502 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  8024ee:	85 f6                	test   %esi,%esi
  8024f0:	74 06                	je     8024f8 <ipc_recv+0x5f>
              *from_env_store = 0;
  8024f2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  8024f8:	85 db                	test   %ebx,%ebx
  8024fa:	74 06                	je     802502 <ipc_recv+0x69>
              *perm_store = 0;
  8024fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802502:	83 c4 10             	add    $0x10,%esp
  802505:	5b                   	pop    %ebx
  802506:	5e                   	pop    %esi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    
  802509:	00 00                	add    %al,(%eax)
	...

0080250c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80250c:	55                   	push   %ebp
  80250d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80250f:	8b 45 08             	mov    0x8(%ebp),%eax
  802512:	89 c2                	mov    %eax,%edx
  802514:	c1 ea 16             	shr    $0x16,%edx
  802517:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80251e:	f6 c2 01             	test   $0x1,%dl
  802521:	74 20                	je     802543 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802523:	c1 e8 0c             	shr    $0xc,%eax
  802526:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80252d:	a8 01                	test   $0x1,%al
  80252f:	74 12                	je     802543 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802531:	c1 e8 0c             	shr    $0xc,%eax
  802534:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802539:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80253e:	0f b7 c0             	movzwl %ax,%eax
  802541:	eb 05                	jmp    802548 <pageref+0x3c>
  802543:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802548:	5d                   	pop    %ebp
  802549:	c3                   	ret    
  80254a:	00 00                	add    %al,(%eax)
  80254c:	00 00                	add    %al,(%eax)
	...

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	57                   	push   %edi
  802554:	56                   	push   %esi
  802555:	83 ec 10             	sub    $0x10,%esp
  802558:	8b 45 14             	mov    0x14(%ebp),%eax
  80255b:	8b 55 08             	mov    0x8(%ebp),%edx
  80255e:	8b 75 10             	mov    0x10(%ebp),%esi
  802561:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802564:	85 c0                	test   %eax,%eax
  802566:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802569:	75 35                	jne    8025a0 <__udivdi3+0x50>
  80256b:	39 fe                	cmp    %edi,%esi
  80256d:	77 61                	ja     8025d0 <__udivdi3+0x80>
  80256f:	85 f6                	test   %esi,%esi
  802571:	75 0b                	jne    80257e <__udivdi3+0x2e>
  802573:	b8 01 00 00 00       	mov    $0x1,%eax
  802578:	31 d2                	xor    %edx,%edx
  80257a:	f7 f6                	div    %esi
  80257c:	89 c6                	mov    %eax,%esi
  80257e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802581:	31 d2                	xor    %edx,%edx
  802583:	89 f8                	mov    %edi,%eax
  802585:	f7 f6                	div    %esi
  802587:	89 c7                	mov    %eax,%edi
  802589:	89 c8                	mov    %ecx,%eax
  80258b:	f7 f6                	div    %esi
  80258d:	89 c1                	mov    %eax,%ecx
  80258f:	89 fa                	mov    %edi,%edx
  802591:	89 c8                	mov    %ecx,%eax
  802593:	83 c4 10             	add    $0x10,%esp
  802596:	5e                   	pop    %esi
  802597:	5f                   	pop    %edi
  802598:	5d                   	pop    %ebp
  802599:	c3                   	ret    
  80259a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a0:	39 f8                	cmp    %edi,%eax
  8025a2:	77 1c                	ja     8025c0 <__udivdi3+0x70>
  8025a4:	0f bd d0             	bsr    %eax,%edx
  8025a7:	83 f2 1f             	xor    $0x1f,%edx
  8025aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8025ad:	75 39                	jne    8025e8 <__udivdi3+0x98>
  8025af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8025b2:	0f 86 a0 00 00 00    	jbe    802658 <__udivdi3+0x108>
  8025b8:	39 f8                	cmp    %edi,%eax
  8025ba:	0f 82 98 00 00 00    	jb     802658 <__udivdi3+0x108>
  8025c0:	31 ff                	xor    %edi,%edi
  8025c2:	31 c9                	xor    %ecx,%ecx
  8025c4:	89 c8                	mov    %ecx,%eax
  8025c6:	89 fa                	mov    %edi,%edx
  8025c8:	83 c4 10             	add    $0x10,%esp
  8025cb:	5e                   	pop    %esi
  8025cc:	5f                   	pop    %edi
  8025cd:	5d                   	pop    %ebp
  8025ce:	c3                   	ret    
  8025cf:	90                   	nop
  8025d0:	89 d1                	mov    %edx,%ecx
  8025d2:	89 fa                	mov    %edi,%edx
  8025d4:	89 c8                	mov    %ecx,%eax
  8025d6:	31 ff                	xor    %edi,%edi
  8025d8:	f7 f6                	div    %esi
  8025da:	89 c1                	mov    %eax,%ecx
  8025dc:	89 fa                	mov    %edi,%edx
  8025de:	89 c8                	mov    %ecx,%eax
  8025e0:	83 c4 10             	add    $0x10,%esp
  8025e3:	5e                   	pop    %esi
  8025e4:	5f                   	pop    %edi
  8025e5:	5d                   	pop    %ebp
  8025e6:	c3                   	ret    
  8025e7:	90                   	nop
  8025e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025ec:	89 f2                	mov    %esi,%edx
  8025ee:	d3 e0                	shl    %cl,%eax
  8025f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8025f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8025f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8025fb:	89 c1                	mov    %eax,%ecx
  8025fd:	d3 ea                	shr    %cl,%edx
  8025ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802603:	0b 55 ec             	or     -0x14(%ebp),%edx
  802606:	d3 e6                	shl    %cl,%esi
  802608:	89 c1                	mov    %eax,%ecx
  80260a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80260d:	89 fe                	mov    %edi,%esi
  80260f:	d3 ee                	shr    %cl,%esi
  802611:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802615:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802618:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80261b:	d3 e7                	shl    %cl,%edi
  80261d:	89 c1                	mov    %eax,%ecx
  80261f:	d3 ea                	shr    %cl,%edx
  802621:	09 d7                	or     %edx,%edi
  802623:	89 f2                	mov    %esi,%edx
  802625:	89 f8                	mov    %edi,%eax
  802627:	f7 75 ec             	divl   -0x14(%ebp)
  80262a:	89 d6                	mov    %edx,%esi
  80262c:	89 c7                	mov    %eax,%edi
  80262e:	f7 65 e8             	mull   -0x18(%ebp)
  802631:	39 d6                	cmp    %edx,%esi
  802633:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802636:	72 30                	jb     802668 <__udivdi3+0x118>
  802638:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80263b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80263f:	d3 e2                	shl    %cl,%edx
  802641:	39 c2                	cmp    %eax,%edx
  802643:	73 05                	jae    80264a <__udivdi3+0xfa>
  802645:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802648:	74 1e                	je     802668 <__udivdi3+0x118>
  80264a:	89 f9                	mov    %edi,%ecx
  80264c:	31 ff                	xor    %edi,%edi
  80264e:	e9 71 ff ff ff       	jmp    8025c4 <__udivdi3+0x74>
  802653:	90                   	nop
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	31 ff                	xor    %edi,%edi
  80265a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80265f:	e9 60 ff ff ff       	jmp    8025c4 <__udivdi3+0x74>
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80266b:	31 ff                	xor    %edi,%edi
  80266d:	89 c8                	mov    %ecx,%eax
  80266f:	89 fa                	mov    %edi,%edx
  802671:	83 c4 10             	add    $0x10,%esp
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
	...

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	57                   	push   %edi
  802684:	56                   	push   %esi
  802685:	83 ec 20             	sub    $0x20,%esp
  802688:	8b 55 14             	mov    0x14(%ebp),%edx
  80268b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80268e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802691:	8b 75 0c             	mov    0xc(%ebp),%esi
  802694:	85 d2                	test   %edx,%edx
  802696:	89 c8                	mov    %ecx,%eax
  802698:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80269b:	75 13                	jne    8026b0 <__umoddi3+0x30>
  80269d:	39 f7                	cmp    %esi,%edi
  80269f:	76 3f                	jbe    8026e0 <__umoddi3+0x60>
  8026a1:	89 f2                	mov    %esi,%edx
  8026a3:	f7 f7                	div    %edi
  8026a5:	89 d0                	mov    %edx,%eax
  8026a7:	31 d2                	xor    %edx,%edx
  8026a9:	83 c4 20             	add    $0x20,%esp
  8026ac:	5e                   	pop    %esi
  8026ad:	5f                   	pop    %edi
  8026ae:	5d                   	pop    %ebp
  8026af:	c3                   	ret    
  8026b0:	39 f2                	cmp    %esi,%edx
  8026b2:	77 4c                	ja     802700 <__umoddi3+0x80>
  8026b4:	0f bd ca             	bsr    %edx,%ecx
  8026b7:	83 f1 1f             	xor    $0x1f,%ecx
  8026ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8026bd:	75 51                	jne    802710 <__umoddi3+0x90>
  8026bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8026c2:	0f 87 e0 00 00 00    	ja     8027a8 <__umoddi3+0x128>
  8026c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026cb:	29 f8                	sub    %edi,%eax
  8026cd:	19 d6                	sbb    %edx,%esi
  8026cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8026d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026d5:	89 f2                	mov    %esi,%edx
  8026d7:	83 c4 20             	add    $0x20,%esp
  8026da:	5e                   	pop    %esi
  8026db:	5f                   	pop    %edi
  8026dc:	5d                   	pop    %ebp
  8026dd:	c3                   	ret    
  8026de:	66 90                	xchg   %ax,%ax
  8026e0:	85 ff                	test   %edi,%edi
  8026e2:	75 0b                	jne    8026ef <__umoddi3+0x6f>
  8026e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e9:	31 d2                	xor    %edx,%edx
  8026eb:	f7 f7                	div    %edi
  8026ed:	89 c7                	mov    %eax,%edi
  8026ef:	89 f0                	mov    %esi,%eax
  8026f1:	31 d2                	xor    %edx,%edx
  8026f3:	f7 f7                	div    %edi
  8026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f8:	f7 f7                	div    %edi
  8026fa:	eb a9                	jmp    8026a5 <__umoddi3+0x25>
  8026fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 f2                	mov    %esi,%edx
  802704:	83 c4 20             	add    $0x20,%esp
  802707:	5e                   	pop    %esi
  802708:	5f                   	pop    %edi
  802709:	5d                   	pop    %ebp
  80270a:	c3                   	ret    
  80270b:	90                   	nop
  80270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802710:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802714:	d3 e2                	shl    %cl,%edx
  802716:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802719:	ba 20 00 00 00       	mov    $0x20,%edx
  80271e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802721:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802724:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802728:	89 fa                	mov    %edi,%edx
  80272a:	d3 ea                	shr    %cl,%edx
  80272c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802730:	0b 55 f4             	or     -0xc(%ebp),%edx
  802733:	d3 e7                	shl    %cl,%edi
  802735:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802739:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80273c:	89 f2                	mov    %esi,%edx
  80273e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802741:	89 c7                	mov    %eax,%edi
  802743:	d3 ea                	shr    %cl,%edx
  802745:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802749:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80274c:	89 c2                	mov    %eax,%edx
  80274e:	d3 e6                	shl    %cl,%esi
  802750:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802754:	d3 ea                	shr    %cl,%edx
  802756:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80275a:	09 d6                	or     %edx,%esi
  80275c:	89 f0                	mov    %esi,%eax
  80275e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802761:	d3 e7                	shl    %cl,%edi
  802763:	89 f2                	mov    %esi,%edx
  802765:	f7 75 f4             	divl   -0xc(%ebp)
  802768:	89 d6                	mov    %edx,%esi
  80276a:	f7 65 e8             	mull   -0x18(%ebp)
  80276d:	39 d6                	cmp    %edx,%esi
  80276f:	72 2b                	jb     80279c <__umoddi3+0x11c>
  802771:	39 c7                	cmp    %eax,%edi
  802773:	72 23                	jb     802798 <__umoddi3+0x118>
  802775:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802779:	29 c7                	sub    %eax,%edi
  80277b:	19 d6                	sbb    %edx,%esi
  80277d:	89 f0                	mov    %esi,%eax
  80277f:	89 f2                	mov    %esi,%edx
  802781:	d3 ef                	shr    %cl,%edi
  802783:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802787:	d3 e0                	shl    %cl,%eax
  802789:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80278d:	09 f8                	or     %edi,%eax
  80278f:	d3 ea                	shr    %cl,%edx
  802791:	83 c4 20             	add    $0x20,%esp
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    
  802798:	39 d6                	cmp    %edx,%esi
  80279a:	75 d9                	jne    802775 <__umoddi3+0xf5>
  80279c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80279f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8027a2:	eb d1                	jmp    802775 <__umoddi3+0xf5>
  8027a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a8:	39 f2                	cmp    %esi,%edx
  8027aa:	0f 82 18 ff ff ff    	jb     8026c8 <__umoddi3+0x48>
  8027b0:	e9 1d ff ff ff       	jmp    8026d2 <__umoddi3+0x52>
