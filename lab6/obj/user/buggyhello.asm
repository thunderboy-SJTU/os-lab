
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 b2 00 00 00       	call   800100 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800062:	e8 84 06 00 00       	call   8006eb <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	89 c2                	mov    %eax,%edx
  80006e:	c1 e2 07             	shl    $0x7,%edx
  800071:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800078:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x38>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000aa:	e8 cc 0b 00 00       	call   800c7b <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 70 06 00 00       	call   80072b <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	51                   	push   %ecx
  8000de:	52                   	push   %edx
  8000df:	53                   	push   %ebx
  8000e0:	54                   	push   %esp
  8000e1:	55                   	push   %ebp
  8000e2:	56                   	push   %esi
  8000e3:	57                   	push   %edi
  8000e4:	54                   	push   %esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	8d 35 ee 00 80 00    	lea    0x8000ee,%esi
  8000ec:	0f 34                	sysenter 
  8000ee:	5f                   	pop    %edi
  8000ef:	5e                   	pop    %esi
  8000f0:	5d                   	pop    %ebp
  8000f1:	5c                   	pop    %esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5a                   	pop    %edx
  8000f4:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	8b 1c 24             	mov    (%esp),%ebx
  8000f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000fc:	89 ec                	mov    %ebp,%esp
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	89 1c 24             	mov    %ebx,(%esp)
  800109:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80010d:	b8 00 00 00 00       	mov    $0x0,%eax
  800112:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 c3                	mov    %eax,%ebx
  80011a:	89 c7                	mov    %eax,%edi
  80011c:	51                   	push   %ecx
  80011d:	52                   	push   %edx
  80011e:	53                   	push   %ebx
  80011f:	54                   	push   %esp
  800120:	55                   	push   %ebp
  800121:	56                   	push   %esi
  800122:	57                   	push   %edi
  800123:	54                   	push   %esp
  800124:	5d                   	pop    %ebp
  800125:	8d 35 2d 01 80 00    	lea    0x80012d,%esi
  80012b:	0f 34                	sysenter 
  80012d:	5f                   	pop    %edi
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	5c                   	pop    %esp
  800131:	5b                   	pop    %ebx
  800132:	5a                   	pop    %edx
  800133:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800134:	8b 1c 24             	mov    (%esp),%ebx
  800137:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80013b:	89 ec                	mov    %ebp,%esp
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
  800145:	89 1c 24             	mov    %ebx,(%esp)
  800148:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80014c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800151:	b8 13 00 00 00       	mov    $0x13,%eax
  800156:	8b 55 08             	mov    0x8(%ebp),%edx
  800159:	89 cb                	mov    %ecx,%ebx
  80015b:	89 cf                	mov    %ecx,%edi
  80015d:	51                   	push   %ecx
  80015e:	52                   	push   %edx
  80015f:	53                   	push   %ebx
  800160:	54                   	push   %esp
  800161:	55                   	push   %ebp
  800162:	56                   	push   %esi
  800163:	57                   	push   %edi
  800164:	54                   	push   %esp
  800165:	5d                   	pop    %ebp
  800166:	8d 35 6e 01 80 00    	lea    0x80016e,%esi
  80016c:	0f 34                	sysenter 
  80016e:	5f                   	pop    %edi
  80016f:	5e                   	pop    %esi
  800170:	5d                   	pop    %ebp
  800171:	5c                   	pop    %esp
  800172:	5b                   	pop    %ebx
  800173:	5a                   	pop    %edx
  800174:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800175:	8b 1c 24             	mov    (%esp),%ebx
  800178:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80017c:	89 ec                	mov    %ebp,%esp
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	89 1c 24             	mov    %ebx,(%esp)
  800189:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80018d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800192:	b8 12 00 00 00       	mov    $0x12,%eax
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	89 df                	mov    %ebx,%edi
  80019f:	51                   	push   %ecx
  8001a0:	52                   	push   %edx
  8001a1:	53                   	push   %ebx
  8001a2:	54                   	push   %esp
  8001a3:	55                   	push   %ebp
  8001a4:	56                   	push   %esi
  8001a5:	57                   	push   %edi
  8001a6:	54                   	push   %esp
  8001a7:	5d                   	pop    %ebp
  8001a8:	8d 35 b0 01 80 00    	lea    0x8001b0,%esi
  8001ae:	0f 34                	sysenter 
  8001b0:	5f                   	pop    %edi
  8001b1:	5e                   	pop    %esi
  8001b2:	5d                   	pop    %ebp
  8001b3:	5c                   	pop    %esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5a                   	pop    %edx
  8001b6:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8001b7:	8b 1c 24             	mov    (%esp),%ebx
  8001ba:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001be:	89 ec                	mov    %ebp,%esp
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    

008001c2 <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	89 1c 24             	mov    %ebx,(%esp)
  8001cb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d4:	b8 11 00 00 00       	mov    $0x11,%eax
  8001d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	89 df                	mov    %ebx,%edi
  8001e1:	51                   	push   %ecx
  8001e2:	52                   	push   %edx
  8001e3:	53                   	push   %ebx
  8001e4:	54                   	push   %esp
  8001e5:	55                   	push   %ebp
  8001e6:	56                   	push   %esi
  8001e7:	57                   	push   %edi
  8001e8:	54                   	push   %esp
  8001e9:	5d                   	pop    %ebp
  8001ea:	8d 35 f2 01 80 00    	lea    0x8001f2,%esi
  8001f0:	0f 34                	sysenter 
  8001f2:	5f                   	pop    %edi
  8001f3:	5e                   	pop    %esi
  8001f4:	5d                   	pop    %ebp
  8001f5:	5c                   	pop    %esp
  8001f6:	5b                   	pop    %ebx
  8001f7:	5a                   	pop    %edx
  8001f8:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8001f9:	8b 1c 24             	mov    (%esp),%ebx
  8001fc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800200:	89 ec                	mov    %ebp,%esp
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	89 1c 24             	mov    %ebx,(%esp)
  80020d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800211:	b8 10 00 00 00       	mov    $0x10,%eax
  800216:	8b 7d 14             	mov    0x14(%ebp),%edi
  800219:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80021c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021f:	8b 55 08             	mov    0x8(%ebp),%edx
  800222:	51                   	push   %ecx
  800223:	52                   	push   %edx
  800224:	53                   	push   %ebx
  800225:	54                   	push   %esp
  800226:	55                   	push   %ebp
  800227:	56                   	push   %esi
  800228:	57                   	push   %edi
  800229:	54                   	push   %esp
  80022a:	5d                   	pop    %ebp
  80022b:	8d 35 33 02 80 00    	lea    0x800233,%esi
  800231:	0f 34                	sysenter 
  800233:	5f                   	pop    %edi
  800234:	5e                   	pop    %esi
  800235:	5d                   	pop    %ebp
  800236:	5c                   	pop    %esp
  800237:	5b                   	pop    %ebx
  800238:	5a                   	pop    %edx
  800239:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  80023a:	8b 1c 24             	mov    (%esp),%ebx
  80023d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800241:	89 ec                	mov    %ebp,%esp
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    

00800245 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 28             	sub    $0x28,%esp
  80024b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80024e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 0f 00 00 00       	mov    $0xf,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	51                   	push   %ecx
  800264:	52                   	push   %edx
  800265:	53                   	push   %ebx
  800266:	54                   	push   %esp
  800267:	55                   	push   %ebp
  800268:	56                   	push   %esi
  800269:	57                   	push   %edi
  80026a:	54                   	push   %esp
  80026b:	5d                   	pop    %ebp
  80026c:	8d 35 74 02 80 00    	lea    0x800274,%esi
  800272:	0f 34                	sysenter 
  800274:	5f                   	pop    %edi
  800275:	5e                   	pop    %esi
  800276:	5d                   	pop    %ebp
  800277:	5c                   	pop    %esp
  800278:	5b                   	pop    %ebx
  800279:	5a                   	pop    %edx
  80027a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7e 28                	jle    8002a7 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800283:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80028a:	00 
  80028b:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  800292:	00 
  800293:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80029a:	00 
  80029b:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  8002a2:	e8 cd 12 00 00       	call   801574 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8002a7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002ad:	89 ec                	mov    %ebp,%esp
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	89 1c 24             	mov    %ebx,(%esp)
  8002ba:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	b8 15 00 00 00       	mov    $0x15,%eax
  8002c8:	89 d1                	mov    %edx,%ecx
  8002ca:	89 d3                	mov    %edx,%ebx
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	51                   	push   %ecx
  8002cf:	52                   	push   %edx
  8002d0:	53                   	push   %ebx
  8002d1:	54                   	push   %esp
  8002d2:	55                   	push   %ebp
  8002d3:	56                   	push   %esi
  8002d4:	57                   	push   %edi
  8002d5:	54                   	push   %esp
  8002d6:	5d                   	pop    %ebp
  8002d7:	8d 35 df 02 80 00    	lea    0x8002df,%esi
  8002dd:	0f 34                	sysenter 
  8002df:	5f                   	pop    %edi
  8002e0:	5e                   	pop    %esi
  8002e1:	5d                   	pop    %ebp
  8002e2:	5c                   	pop    %esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5a                   	pop    %edx
  8002e5:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002e6:	8b 1c 24             	mov    (%esp),%ebx
  8002e9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002ed:	89 ec                	mov    %ebp,%esp
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	89 1c 24             	mov    %ebx,(%esp)
  8002fa:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800303:	b8 14 00 00 00       	mov    $0x14,%eax
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	89 cb                	mov    %ecx,%ebx
  80030d:	89 cf                	mov    %ecx,%edi
  80030f:	51                   	push   %ecx
  800310:	52                   	push   %edx
  800311:	53                   	push   %ebx
  800312:	54                   	push   %esp
  800313:	55                   	push   %ebp
  800314:	56                   	push   %esi
  800315:	57                   	push   %edi
  800316:	54                   	push   %esp
  800317:	5d                   	pop    %ebp
  800318:	8d 35 20 03 80 00    	lea    0x800320,%esi
  80031e:	0f 34                	sysenter 
  800320:	5f                   	pop    %edi
  800321:	5e                   	pop    %esi
  800322:	5d                   	pop    %ebp
  800323:	5c                   	pop    %esp
  800324:	5b                   	pop    %ebx
  800325:	5a                   	pop    %edx
  800326:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800327:	8b 1c 24             	mov    (%esp),%ebx
  80032a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80032e:	89 ec                	mov    %ebp,%esp
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	83 ec 28             	sub    $0x28,%esp
  800338:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80033b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80033e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800343:	b8 0e 00 00 00       	mov    $0xe,%eax
  800348:	8b 55 08             	mov    0x8(%ebp),%edx
  80034b:	89 cb                	mov    %ecx,%ebx
  80034d:	89 cf                	mov    %ecx,%edi
  80034f:	51                   	push   %ecx
  800350:	52                   	push   %edx
  800351:	53                   	push   %ebx
  800352:	54                   	push   %esp
  800353:	55                   	push   %ebp
  800354:	56                   	push   %esi
  800355:	57                   	push   %edi
  800356:	54                   	push   %esp
  800357:	5d                   	pop    %ebp
  800358:	8d 35 60 03 80 00    	lea    0x800360,%esi
  80035e:	0f 34                	sysenter 
  800360:	5f                   	pop    %edi
  800361:	5e                   	pop    %esi
  800362:	5d                   	pop    %ebp
  800363:	5c                   	pop    %esp
  800364:	5b                   	pop    %ebx
  800365:	5a                   	pop    %edx
  800366:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800367:	85 c0                	test   %eax,%eax
  800369:	7e 28                	jle    800393 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036f:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800376:	00 
  800377:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  80037e:	00 
  80037f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800386:	00 
  800387:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80038e:	e8 e1 11 00 00       	call   801574 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800393:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800396:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800399:	89 ec                	mov    %ebp,%esp
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	89 1c 24             	mov    %ebx,(%esp)
  8003a6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003aa:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bb:	51                   	push   %ecx
  8003bc:	52                   	push   %edx
  8003bd:	53                   	push   %ebx
  8003be:	54                   	push   %esp
  8003bf:	55                   	push   %ebp
  8003c0:	56                   	push   %esi
  8003c1:	57                   	push   %edi
  8003c2:	54                   	push   %esp
  8003c3:	5d                   	pop    %ebp
  8003c4:	8d 35 cc 03 80 00    	lea    0x8003cc,%esi
  8003ca:	0f 34                	sysenter 
  8003cc:	5f                   	pop    %edi
  8003cd:	5e                   	pop    %esi
  8003ce:	5d                   	pop    %ebp
  8003cf:	5c                   	pop    %esp
  8003d0:	5b                   	pop    %ebx
  8003d1:	5a                   	pop    %edx
  8003d2:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003d3:	8b 1c 24             	mov    (%esp),%ebx
  8003d6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003da:	89 ec                	mov    %ebp,%esp
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 28             	sub    $0x28,%esp
  8003e4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003e7:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ef:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fa:	89 df                	mov    %ebx,%edi
  8003fc:	51                   	push   %ecx
  8003fd:	52                   	push   %edx
  8003fe:	53                   	push   %ebx
  8003ff:	54                   	push   %esp
  800400:	55                   	push   %ebp
  800401:	56                   	push   %esi
  800402:	57                   	push   %edi
  800403:	54                   	push   %esp
  800404:	5d                   	pop    %ebp
  800405:	8d 35 0d 04 80 00    	lea    0x80040d,%esi
  80040b:	0f 34                	sysenter 
  80040d:	5f                   	pop    %edi
  80040e:	5e                   	pop    %esi
  80040f:	5d                   	pop    %ebp
  800410:	5c                   	pop    %esp
  800411:	5b                   	pop    %ebx
  800412:	5a                   	pop    %edx
  800413:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800414:	85 c0                	test   %eax,%eax
  800416:	7e 28                	jle    800440 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800418:	89 44 24 10          	mov    %eax,0x10(%esp)
  80041c:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  800423:	00 
  800424:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  80042b:	00 
  80042c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800433:	00 
  800434:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80043b:	e8 34 11 00 00       	call   801574 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800440:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800443:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800446:	89 ec                	mov    %ebp,%esp
  800448:	5d                   	pop    %ebp
  800449:	c3                   	ret    

0080044a <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	83 ec 28             	sub    $0x28,%esp
  800450:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800453:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800456:	bb 00 00 00 00       	mov    $0x0,%ebx
  80045b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800460:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800463:	8b 55 08             	mov    0x8(%ebp),%edx
  800466:	89 df                	mov    %ebx,%edi
  800468:	51                   	push   %ecx
  800469:	52                   	push   %edx
  80046a:	53                   	push   %ebx
  80046b:	54                   	push   %esp
  80046c:	55                   	push   %ebp
  80046d:	56                   	push   %esi
  80046e:	57                   	push   %edi
  80046f:	54                   	push   %esp
  800470:	5d                   	pop    %ebp
  800471:	8d 35 79 04 80 00    	lea    0x800479,%esi
  800477:	0f 34                	sysenter 
  800479:	5f                   	pop    %edi
  80047a:	5e                   	pop    %esi
  80047b:	5d                   	pop    %ebp
  80047c:	5c                   	pop    %esp
  80047d:	5b                   	pop    %ebx
  80047e:	5a                   	pop    %edx
  80047f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800480:	85 c0                	test   %eax,%eax
  800482:	7e 28                	jle    8004ac <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800484:	89 44 24 10          	mov    %eax,0x10(%esp)
  800488:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80048f:	00 
  800490:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  800497:	00 
  800498:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80049f:	00 
  8004a0:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  8004a7:	e8 c8 10 00 00       	call   801574 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8004ac:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004af:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004b2:	89 ec                	mov    %ebp,%esp
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    

008004b6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 28             	sub    $0x28,%esp
  8004bc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004bf:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004c7:	b8 09 00 00 00       	mov    $0x9,%eax
  8004cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d2:	89 df                	mov    %ebx,%edi
  8004d4:	51                   	push   %ecx
  8004d5:	52                   	push   %edx
  8004d6:	53                   	push   %ebx
  8004d7:	54                   	push   %esp
  8004d8:	55                   	push   %ebp
  8004d9:	56                   	push   %esi
  8004da:	57                   	push   %edi
  8004db:	54                   	push   %esp
  8004dc:	5d                   	pop    %ebp
  8004dd:	8d 35 e5 04 80 00    	lea    0x8004e5,%esi
  8004e3:	0f 34                	sysenter 
  8004e5:	5f                   	pop    %edi
  8004e6:	5e                   	pop    %esi
  8004e7:	5d                   	pop    %ebp
  8004e8:	5c                   	pop    %esp
  8004e9:	5b                   	pop    %ebx
  8004ea:	5a                   	pop    %edx
  8004eb:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	7e 28                	jle    800518 <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004f4:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8004fb:	00 
  8004fc:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  800503:	00 
  800504:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80050b:	00 
  80050c:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  800513:	e8 5c 10 00 00       	call   801574 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800518:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80051b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80051e:	89 ec                	mov    %ebp,%esp
  800520:	5d                   	pop    %ebp
  800521:	c3                   	ret    

00800522 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	83 ec 28             	sub    $0x28,%esp
  800528:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80052b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80052e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800533:	b8 07 00 00 00       	mov    $0x7,%eax
  800538:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80053b:	8b 55 08             	mov    0x8(%ebp),%edx
  80053e:	89 df                	mov    %ebx,%edi
  800540:	51                   	push   %ecx
  800541:	52                   	push   %edx
  800542:	53                   	push   %ebx
  800543:	54                   	push   %esp
  800544:	55                   	push   %ebp
  800545:	56                   	push   %esi
  800546:	57                   	push   %edi
  800547:	54                   	push   %esp
  800548:	5d                   	pop    %ebp
  800549:	8d 35 51 05 80 00    	lea    0x800551,%esi
  80054f:	0f 34                	sysenter 
  800551:	5f                   	pop    %edi
  800552:	5e                   	pop    %esi
  800553:	5d                   	pop    %ebp
  800554:	5c                   	pop    %esp
  800555:	5b                   	pop    %ebx
  800556:	5a                   	pop    %edx
  800557:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800558:	85 c0                	test   %eax,%eax
  80055a:	7e 28                	jle    800584 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80055c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800560:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800567:	00 
  800568:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  80056f:	00 
  800570:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800577:	00 
  800578:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80057f:	e8 f0 0f 00 00       	call   801574 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800584:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800587:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80058a:	89 ec                	mov    %ebp,%esp
  80058c:	5d                   	pop    %ebp
  80058d:	c3                   	ret    

0080058e <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80058e:	55                   	push   %ebp
  80058f:	89 e5                	mov    %esp,%ebp
  800591:	83 ec 28             	sub    $0x28,%esp
  800594:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800597:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80059a:	8b 7d 18             	mov    0x18(%ebp),%edi
  80059d:	0b 7d 14             	or     0x14(%ebp),%edi
  8005a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8005a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ae:	51                   	push   %ecx
  8005af:	52                   	push   %edx
  8005b0:	53                   	push   %ebx
  8005b1:	54                   	push   %esp
  8005b2:	55                   	push   %ebp
  8005b3:	56                   	push   %esi
  8005b4:	57                   	push   %edi
  8005b5:	54                   	push   %esp
  8005b6:	5d                   	pop    %ebp
  8005b7:	8d 35 bf 05 80 00    	lea    0x8005bf,%esi
  8005bd:	0f 34                	sysenter 
  8005bf:	5f                   	pop    %edi
  8005c0:	5e                   	pop    %esi
  8005c1:	5d                   	pop    %ebp
  8005c2:	5c                   	pop    %esp
  8005c3:	5b                   	pop    %ebx
  8005c4:	5a                   	pop    %edx
  8005c5:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	7e 28                	jle    8005f2 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005ce:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005d5:	00 
  8005d6:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  8005dd:	00 
  8005de:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8005e5:	00 
  8005e6:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  8005ed:	e8 82 0f 00 00       	call   801574 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8005f2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005f8:	89 ec                	mov    %ebp,%esp
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    

008005fc <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	83 ec 28             	sub    $0x28,%esp
  800602:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800605:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800608:	bf 00 00 00 00       	mov    $0x0,%edi
  80060d:	b8 05 00 00 00       	mov    $0x5,%eax
  800612:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800615:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800618:	8b 55 08             	mov    0x8(%ebp),%edx
  80061b:	51                   	push   %ecx
  80061c:	52                   	push   %edx
  80061d:	53                   	push   %ebx
  80061e:	54                   	push   %esp
  80061f:	55                   	push   %ebp
  800620:	56                   	push   %esi
  800621:	57                   	push   %edi
  800622:	54                   	push   %esp
  800623:	5d                   	pop    %ebp
  800624:	8d 35 2c 06 80 00    	lea    0x80062c,%esi
  80062a:	0f 34                	sysenter 
  80062c:	5f                   	pop    %edi
  80062d:	5e                   	pop    %esi
  80062e:	5d                   	pop    %ebp
  80062f:	5c                   	pop    %esp
  800630:	5b                   	pop    %ebx
  800631:	5a                   	pop    %edx
  800632:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800633:	85 c0                	test   %eax,%eax
  800635:	7e 28                	jle    80065f <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800637:	89 44 24 10          	mov    %eax,0x10(%esp)
  80063b:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800642:	00 
  800643:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  80064a:	00 
  80064b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800652:	00 
  800653:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80065a:	e8 15 0f 00 00       	call   801574 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80065f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800662:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800665:	89 ec                	mov    %ebp,%esp
  800667:	5d                   	pop    %ebp
  800668:	c3                   	ret    

00800669 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800669:	55                   	push   %ebp
  80066a:	89 e5                	mov    %esp,%ebp
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	89 1c 24             	mov    %ebx,(%esp)
  800672:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800676:	ba 00 00 00 00       	mov    $0x0,%edx
  80067b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800680:	89 d1                	mov    %edx,%ecx
  800682:	89 d3                	mov    %edx,%ebx
  800684:	89 d7                	mov    %edx,%edi
  800686:	51                   	push   %ecx
  800687:	52                   	push   %edx
  800688:	53                   	push   %ebx
  800689:	54                   	push   %esp
  80068a:	55                   	push   %ebp
  80068b:	56                   	push   %esi
  80068c:	57                   	push   %edi
  80068d:	54                   	push   %esp
  80068e:	5d                   	pop    %ebp
  80068f:	8d 35 97 06 80 00    	lea    0x800697,%esi
  800695:	0f 34                	sysenter 
  800697:	5f                   	pop    %edi
  800698:	5e                   	pop    %esi
  800699:	5d                   	pop    %ebp
  80069a:	5c                   	pop    %esp
  80069b:	5b                   	pop    %ebx
  80069c:	5a                   	pop    %edx
  80069d:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80069e:	8b 1c 24             	mov    (%esp),%ebx
  8006a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006a5:	89 ec                	mov    %ebp,%esp
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	89 1c 24             	mov    %ebx,(%esp)
  8006b2:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8006c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c6:	89 df                	mov    %ebx,%edi
  8006c8:	51                   	push   %ecx
  8006c9:	52                   	push   %edx
  8006ca:	53                   	push   %ebx
  8006cb:	54                   	push   %esp
  8006cc:	55                   	push   %ebp
  8006cd:	56                   	push   %esi
  8006ce:	57                   	push   %edi
  8006cf:	54                   	push   %esp
  8006d0:	5d                   	pop    %ebp
  8006d1:	8d 35 d9 06 80 00    	lea    0x8006d9,%esi
  8006d7:	0f 34                	sysenter 
  8006d9:	5f                   	pop    %edi
  8006da:	5e                   	pop    %esi
  8006db:	5d                   	pop    %ebp
  8006dc:	5c                   	pop    %esp
  8006dd:	5b                   	pop    %ebx
  8006de:	5a                   	pop    %edx
  8006df:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8006e0:	8b 1c 24             	mov    (%esp),%ebx
  8006e3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006e7:	89 ec                	mov    %ebp,%esp
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	89 1c 24             	mov    %ebx,(%esp)
  8006f4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fd:	b8 02 00 00 00       	mov    $0x2,%eax
  800702:	89 d1                	mov    %edx,%ecx
  800704:	89 d3                	mov    %edx,%ebx
  800706:	89 d7                	mov    %edx,%edi
  800708:	51                   	push   %ecx
  800709:	52                   	push   %edx
  80070a:	53                   	push   %ebx
  80070b:	54                   	push   %esp
  80070c:	55                   	push   %ebp
  80070d:	56                   	push   %esi
  80070e:	57                   	push   %edi
  80070f:	54                   	push   %esp
  800710:	5d                   	pop    %ebp
  800711:	8d 35 19 07 80 00    	lea    0x800719,%esi
  800717:	0f 34                	sysenter 
  800719:	5f                   	pop    %edi
  80071a:	5e                   	pop    %esi
  80071b:	5d                   	pop    %ebp
  80071c:	5c                   	pop    %esp
  80071d:	5b                   	pop    %ebx
  80071e:	5a                   	pop    %edx
  80071f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800720:	8b 1c 24             	mov    (%esp),%ebx
  800723:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800727:	89 ec                	mov    %ebp,%esp
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 28             	sub    $0x28,%esp
  800731:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800734:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	b8 03 00 00 00       	mov    $0x3,%eax
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
  800744:	89 cb                	mov    %ecx,%ebx
  800746:	89 cf                	mov    %ecx,%edi
  800748:	51                   	push   %ecx
  800749:	52                   	push   %edx
  80074a:	53                   	push   %ebx
  80074b:	54                   	push   %esp
  80074c:	55                   	push   %ebp
  80074d:	56                   	push   %esi
  80074e:	57                   	push   %edi
  80074f:	54                   	push   %esp
  800750:	5d                   	pop    %ebp
  800751:	8d 35 59 07 80 00    	lea    0x800759,%esi
  800757:	0f 34                	sysenter 
  800759:	5f                   	pop    %edi
  80075a:	5e                   	pop    %esi
  80075b:	5d                   	pop    %ebp
  80075c:	5c                   	pop    %esp
  80075d:	5b                   	pop    %ebx
  80075e:	5a                   	pop    %edx
  80075f:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800760:	85 c0                	test   %eax,%eax
  800762:	7e 28                	jle    80078c <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800764:	89 44 24 10          	mov    %eax,0x10(%esp)
  800768:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80076f:	00 
  800770:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  800777:	00 
  800778:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80077f:	00 
  800780:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  800787:	e8 e8 0d 00 00       	call   801574 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80078c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80078f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800792:	89 ec                	mov    %ebp,%esp
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    
	...

008007a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8007ab:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	89 04 24             	mov    %eax,(%esp)
  8007bc:	e8 df ff ff ff       	call   8007a0 <fd2num>
  8007c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8007c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	57                   	push   %edi
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8007d4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8007d9:	a8 01                	test   $0x1,%al
  8007db:	74 36                	je     800813 <fd_alloc+0x48>
  8007dd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8007e2:	a8 01                	test   $0x1,%al
  8007e4:	74 2d                	je     800813 <fd_alloc+0x48>
  8007e6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8007eb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8007f0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8007f5:	89 c3                	mov    %eax,%ebx
  8007f7:	89 c2                	mov    %eax,%edx
  8007f9:	c1 ea 16             	shr    $0x16,%edx
  8007fc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8007ff:	f6 c2 01             	test   $0x1,%dl
  800802:	74 14                	je     800818 <fd_alloc+0x4d>
  800804:	89 c2                	mov    %eax,%edx
  800806:	c1 ea 0c             	shr    $0xc,%edx
  800809:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80080c:	f6 c2 01             	test   $0x1,%dl
  80080f:	75 10                	jne    800821 <fd_alloc+0x56>
  800811:	eb 05                	jmp    800818 <fd_alloc+0x4d>
  800813:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800818:	89 1f                	mov    %ebx,(%edi)
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80081f:	eb 17                	jmp    800838 <fd_alloc+0x6d>
  800821:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800826:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80082b:	75 c8                	jne    8007f5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80082d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800833:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5f                   	pop    %edi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	83 f8 1f             	cmp    $0x1f,%eax
  800846:	77 36                	ja     80087e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800848:	05 00 00 0d 00       	add    $0xd0000,%eax
  80084d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800850:	89 c2                	mov    %eax,%edx
  800852:	c1 ea 16             	shr    $0x16,%edx
  800855:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80085c:	f6 c2 01             	test   $0x1,%dl
  80085f:	74 1d                	je     80087e <fd_lookup+0x41>
  800861:	89 c2                	mov    %eax,%edx
  800863:	c1 ea 0c             	shr    $0xc,%edx
  800866:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80086d:	f6 c2 01             	test   $0x1,%dl
  800870:	74 0c                	je     80087e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
  800875:	89 02                	mov    %eax,(%edx)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80087c:	eb 05                	jmp    800883 <fd_lookup+0x46>
  80087e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80088b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80088e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	89 04 24             	mov    %eax,(%esp)
  800898:	e8 a0 ff ff ff       	call   80083d <fd_lookup>
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 0e                	js     8008af <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a7:	89 50 04             	mov    %edx,0x4(%eax)
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	83 ec 10             	sub    $0x10,%esp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8008bf:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8008c4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008c9:	be f4 27 80 00       	mov    $0x8027f4,%esi
		if (devtab[i]->dev_id == dev_id) {
  8008ce:	39 08                	cmp    %ecx,(%eax)
  8008d0:	75 10                	jne    8008e2 <dev_lookup+0x31>
  8008d2:	eb 04                	jmp    8008d8 <dev_lookup+0x27>
  8008d4:	39 08                	cmp    %ecx,(%eax)
  8008d6:	75 0a                	jne    8008e2 <dev_lookup+0x31>
			*dev = devtab[i];
  8008d8:	89 03                	mov    %eax,(%ebx)
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8008df:	90                   	nop
  8008e0:	eb 31                	jmp    800913 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008e2:	83 c2 01             	add    $0x1,%edx
  8008e5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	75 e8                	jne    8008d4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8008f1:	8b 40 48             	mov    0x48(%eax),%eax
  8008f4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fc:	c7 04 24 78 27 80 00 	movl   $0x802778,(%esp)
  800903:	e8 25 0d 00 00       	call   80162d <cprintf>
	*dev = 0;
  800908:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80090e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	53                   	push   %ebx
  80091e:	83 ec 24             	sub    $0x24,%esp
  800921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800924:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	89 04 24             	mov    %eax,(%esp)
  800931:	e8 07 ff ff ff       	call   80083d <fd_lookup>
  800936:	85 c0                	test   %eax,%eax
  800938:	78 53                	js     80098d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80093a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800944:	8b 00                	mov    (%eax),%eax
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	e8 63 ff ff ff       	call   8008b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80094e:	85 c0                	test   %eax,%eax
  800950:	78 3b                	js     80098d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800952:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800957:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80095a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80095e:	74 2d                	je     80098d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800960:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800963:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80096a:	00 00 00 
	stat->st_isdir = 0;
  80096d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800974:	00 00 00 
	stat->st_dev = dev;
  800977:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800980:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800984:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800987:	89 14 24             	mov    %edx,(%esp)
  80098a:	ff 50 14             	call   *0x14(%eax)
}
  80098d:	83 c4 24             	add    $0x24,%esp
  800990:	5b                   	pop    %ebx
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	53                   	push   %ebx
  800997:	83 ec 24             	sub    $0x24,%esp
  80099a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80099d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a4:	89 1c 24             	mov    %ebx,(%esp)
  8009a7:	e8 91 fe ff ff       	call   80083d <fd_lookup>
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	78 5f                	js     800a0f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ba:	8b 00                	mov    (%eax),%eax
  8009bc:	89 04 24             	mov    %eax,(%esp)
  8009bf:	e8 ed fe ff ff       	call   8008b1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009c4:	85 c0                	test   %eax,%eax
  8009c6:	78 47                	js     800a0f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009cb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8009cf:	75 23                	jne    8009f4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8009d1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8009d6:	8b 40 48             	mov    0x48(%eax),%eax
  8009d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e1:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  8009e8:	e8 40 0c 00 00       	call   80162d <cprintf>
  8009ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8009f2:	eb 1b                	jmp    800a0f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f7:	8b 48 18             	mov    0x18(%eax),%ecx
  8009fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8009ff:	85 c9                	test   %ecx,%ecx
  800a01:	74 0c                	je     800a0f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0a:	89 14 24             	mov    %edx,(%esp)
  800a0d:	ff d1                	call   *%ecx
}
  800a0f:	83 c4 24             	add    $0x24,%esp
  800a12:	5b                   	pop    %ebx
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	83 ec 24             	sub    $0x24,%esp
  800a1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a26:	89 1c 24             	mov    %ebx,(%esp)
  800a29:	e8 0f fe ff ff       	call   80083d <fd_lookup>
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 66                	js     800a98 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a3c:	8b 00                	mov    (%eax),%eax
  800a3e:	89 04 24             	mov    %eax,(%esp)
  800a41:	e8 6b fe ff ff       	call   8008b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a46:	85 c0                	test   %eax,%eax
  800a48:	78 4e                	js     800a98 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a4d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800a51:	75 23                	jne    800a76 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a53:	a1 08 40 80 00       	mov    0x804008,%eax
  800a58:	8b 40 48             	mov    0x48(%eax),%eax
  800a5b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a63:	c7 04 24 b9 27 80 00 	movl   $0x8027b9,(%esp)
  800a6a:	e8 be 0b 00 00       	call   80162d <cprintf>
  800a6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800a74:	eb 22                	jmp    800a98 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a79:	8b 48 0c             	mov    0xc(%eax),%ecx
  800a7c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 13                	je     800a98 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800a85:	8b 45 10             	mov    0x10(%ebp),%eax
  800a88:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a93:	89 14 24             	mov    %edx,(%esp)
  800a96:	ff d1                	call   *%ecx
}
  800a98:	83 c4 24             	add    $0x24,%esp
  800a9b:	5b                   	pop    %ebx
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 24             	sub    $0x24,%esp
  800aa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800aa8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aaf:	89 1c 24             	mov    %ebx,(%esp)
  800ab2:	e8 86 fd ff ff       	call   80083d <fd_lookup>
  800ab7:	85 c0                	test   %eax,%eax
  800ab9:	78 6b                	js     800b26 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800abb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800abe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac5:	8b 00                	mov    (%eax),%eax
  800ac7:	89 04 24             	mov    %eax,(%esp)
  800aca:	e8 e2 fd ff ff       	call   8008b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	78 53                	js     800b26 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ad3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ad6:	8b 42 08             	mov    0x8(%edx),%eax
  800ad9:	83 e0 03             	and    $0x3,%eax
  800adc:	83 f8 01             	cmp    $0x1,%eax
  800adf:	75 23                	jne    800b04 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ae1:	a1 08 40 80 00       	mov    0x804008,%eax
  800ae6:	8b 40 48             	mov    0x48(%eax),%eax
  800ae9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af1:	c7 04 24 d6 27 80 00 	movl   $0x8027d6,(%esp)
  800af8:	e8 30 0b 00 00       	call   80162d <cprintf>
  800afd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800b02:	eb 22                	jmp    800b26 <read+0x88>
	}
	if (!dev->dev_read)
  800b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b07:	8b 48 08             	mov    0x8(%eax),%ecx
  800b0a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b0f:	85 c9                	test   %ecx,%ecx
  800b11:	74 13                	je     800b26 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b13:	8b 45 10             	mov    0x10(%ebp),%eax
  800b16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b21:	89 14 24             	mov    %edx,(%esp)
  800b24:	ff d1                	call   *%ecx
}
  800b26:	83 c4 24             	add    $0x24,%esp
  800b29:	5b                   	pop    %ebx
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 1c             	sub    $0x1c,%esp
  800b35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b38:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4a:	85 f6                	test   %esi,%esi
  800b4c:	74 29                	je     800b77 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b4e:	89 f0                	mov    %esi,%eax
  800b50:	29 d0                	sub    %edx,%eax
  800b52:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b56:	03 55 0c             	add    0xc(%ebp),%edx
  800b59:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b5d:	89 3c 24             	mov    %edi,(%esp)
  800b60:	e8 39 ff ff ff       	call   800a9e <read>
		if (m < 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	78 0e                	js     800b77 <readn+0x4b>
			return m;
		if (m == 0)
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	74 08                	je     800b75 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b6d:	01 c3                	add    %eax,%ebx
  800b6f:	89 da                	mov    %ebx,%edx
  800b71:	39 f3                	cmp    %esi,%ebx
  800b73:	72 d9                	jb     800b4e <readn+0x22>
  800b75:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b77:	83 c4 1c             	add    $0x1c,%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 20             	sub    $0x20,%esp
  800b87:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800b8a:	89 34 24             	mov    %esi,(%esp)
  800b8d:	e8 0e fc ff ff       	call   8007a0 <fd2num>
  800b92:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800b95:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b99:	89 04 24             	mov    %eax,(%esp)
  800b9c:	e8 9c fc ff ff       	call   80083d <fd_lookup>
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	78 05                	js     800bac <fd_close+0x2d>
  800ba7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800baa:	74 0c                	je     800bb8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800bac:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800bb0:	19 c0                	sbb    %eax,%eax
  800bb2:	f7 d0                	not    %eax
  800bb4:	21 c3                	and    %eax,%ebx
  800bb6:	eb 3d                	jmp    800bf5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800bb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbf:	8b 06                	mov    (%esi),%eax
  800bc1:	89 04 24             	mov    %eax,(%esp)
  800bc4:	e8 e8 fc ff ff       	call   8008b1 <dev_lookup>
  800bc9:	89 c3                	mov    %eax,%ebx
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	78 16                	js     800be5 <fd_close+0x66>
		if (dev->dev_close)
  800bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd2:	8b 40 10             	mov    0x10(%eax),%eax
  800bd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	74 07                	je     800be5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800bde:	89 34 24             	mov    %esi,(%esp)
  800be1:	ff d0                	call   *%eax
  800be3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800be5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bf0:	e8 2d f9 ff ff       	call   800522 <sys_page_unmap>
	return r;
}
  800bf5:	89 d8                	mov    %ebx,%eax
  800bf7:	83 c4 20             	add    $0x20,%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	89 04 24             	mov    %eax,(%esp)
  800c11:	e8 27 fc ff ff       	call   80083d <fd_lookup>
  800c16:	85 c0                	test   %eax,%eax
  800c18:	78 13                	js     800c2d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800c1a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800c21:	00 
  800c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c25:	89 04 24             	mov    %eax,(%esp)
  800c28:	e8 52 ff ff ff       	call   800b7f <fd_close>
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 18             	sub    $0x18,%esp
  800c35:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800c38:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c42:	00 
  800c43:	8b 45 08             	mov    0x8(%ebp),%eax
  800c46:	89 04 24             	mov    %eax,(%esp)
  800c49:	e8 79 03 00 00       	call   800fc7 <open>
  800c4e:	89 c3                	mov    %eax,%ebx
  800c50:	85 c0                	test   %eax,%eax
  800c52:	78 1b                	js     800c6f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800c54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5b:	89 1c 24             	mov    %ebx,(%esp)
  800c5e:	e8 b7 fc ff ff       	call   80091a <fstat>
  800c63:	89 c6                	mov    %eax,%esi
	close(fd);
  800c65:	89 1c 24             	mov    %ebx,(%esp)
  800c68:	e8 91 ff ff ff       	call   800bfe <close>
  800c6d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800c6f:	89 d8                	mov    %ebx,%eax
  800c71:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800c74:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800c77:	89 ec                	mov    %ebp,%esp
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 14             	sub    $0x14,%esp
  800c82:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800c87:	89 1c 24             	mov    %ebx,(%esp)
  800c8a:	e8 6f ff ff ff       	call   800bfe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800c8f:	83 c3 01             	add    $0x1,%ebx
  800c92:	83 fb 20             	cmp    $0x20,%ebx
  800c95:	75 f0                	jne    800c87 <close_all+0xc>
		close(i);
}
  800c97:	83 c4 14             	add    $0x14,%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 58             	sub    $0x58,%esp
  800ca3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ca9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cac:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800caf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	89 04 24             	mov    %eax,(%esp)
  800cbc:	e8 7c fb ff ff       	call   80083d <fd_lookup>
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	0f 88 e0 00 00 00    	js     800dab <dup+0x10e>
		return r;
	close(newfdnum);
  800ccb:	89 3c 24             	mov    %edi,(%esp)
  800cce:	e8 2b ff ff ff       	call   800bfe <close>

	newfd = INDEX2FD(newfdnum);
  800cd3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800cd9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800cdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cdf:	89 04 24             	mov    %eax,(%esp)
  800ce2:	e8 c9 fa ff ff       	call   8007b0 <fd2data>
  800ce7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800ce9:	89 34 24             	mov    %esi,(%esp)
  800cec:	e8 bf fa ff ff       	call   8007b0 <fd2data>
  800cf1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800cf4:	89 da                	mov    %ebx,%edx
  800cf6:	89 d8                	mov    %ebx,%eax
  800cf8:	c1 e8 16             	shr    $0x16,%eax
  800cfb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d02:	a8 01                	test   $0x1,%al
  800d04:	74 43                	je     800d49 <dup+0xac>
  800d06:	c1 ea 0c             	shr    $0xc,%edx
  800d09:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d10:	a8 01                	test   $0x1,%al
  800d12:	74 35                	je     800d49 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800d14:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d1b:	25 07 0e 00 00       	and    $0xe07,%eax
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d32:	00 
  800d33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d3e:	e8 4b f8 ff ff       	call   80058e <sys_page_map>
  800d43:	89 c3                	mov    %eax,%ebx
  800d45:	85 c0                	test   %eax,%eax
  800d47:	78 3f                	js     800d88 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d4c:	89 c2                	mov    %eax,%edx
  800d4e:	c1 ea 0c             	shr    $0xc,%edx
  800d51:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d58:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d5e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d62:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d6d:	00 
  800d6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d79:	e8 10 f8 ff ff       	call   80058e <sys_page_map>
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	85 c0                	test   %eax,%eax
  800d82:	78 04                	js     800d88 <dup+0xeb>
  800d84:	89 fb                	mov    %edi,%ebx
  800d86:	eb 23                	jmp    800dab <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800d88:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d93:	e8 8a f7 ff ff       	call   800522 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800d98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800da6:	e8 77 f7 ff ff       	call   800522 <sys_page_unmap>
	return r;
}
  800dab:	89 d8                	mov    %ebx,%eax
  800dad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db6:	89 ec                	mov    %ebp,%esp
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    
	...

00800dbc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 18             	sub    $0x18,%esp
  800dc2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800dc5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800dc8:	89 c3                	mov    %eax,%ebx
  800dca:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800dcc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800dd3:	75 11                	jne    800de6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800dd5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ddc:	e8 6f 15 00 00       	call   802350 <ipc_find_env>
  800de1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800de6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ded:	00 
  800dee:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800df5:	00 
  800df6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dfa:	a1 00 40 80 00       	mov    0x804000,%eax
  800dff:	89 04 24             	mov    %eax,(%esp)
  800e02:	e8 94 15 00 00       	call   80239b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e0e:	00 
  800e0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e1a:	e8 fa 15 00 00       	call   802419 <ipc_recv>
}
  800e1f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e22:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800e25:	89 ec                	mov    %ebp,%esp
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	8b 40 0c             	mov    0xc(%eax),%eax
  800e35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e42:	ba 00 00 00 00       	mov    $0x0,%edx
  800e47:	b8 02 00 00 00       	mov    $0x2,%eax
  800e4c:	e8 6b ff ff ff       	call   800dbc <fsipc>
}
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	8b 40 0c             	mov    0xc(%eax),%eax
  800e5f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e64:	ba 00 00 00 00       	mov    $0x0,%edx
  800e69:	b8 06 00 00 00       	mov    $0x6,%eax
  800e6e:	e8 49 ff ff ff       	call   800dbc <fsipc>
}
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    

00800e75 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 08 00 00 00       	mov    $0x8,%eax
  800e85:	e8 32 ff ff ff       	call   800dbc <fsipc>
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	53                   	push   %ebx
  800e90:	83 ec 14             	sub    $0x14,%esp
  800e93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	8b 40 0c             	mov    0xc(%eax),%eax
  800e9c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ea1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea6:	b8 05 00 00 00       	mov    $0x5,%eax
  800eab:	e8 0c ff ff ff       	call   800dbc <fsipc>
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 2b                	js     800edf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800eb4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ebb:	00 
  800ebc:	89 1c 24             	mov    %ebx,(%esp)
  800ebf:	e8 96 10 00 00       	call   801f5a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ec4:	a1 80 50 80 00       	mov    0x805080,%eax
  800ec9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ecf:	a1 84 50 80 00       	mov    0x805084,%eax
  800ed4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800edf:	83 c4 14             	add    $0x14,%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 18             	sub    $0x18,%esp
  800eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  800eee:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800ef3:	76 05                	jbe    800efa <devfile_write+0x15>
  800ef5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
  800efd:	8b 52 0c             	mov    0xc(%edx),%edx
  800f00:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800f06:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800f0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f16:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f1d:	e8 23 12 00 00       	call   802145 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800f22:	ba 00 00 00 00       	mov    $0x0,%edx
  800f27:	b8 04 00 00 00       	mov    $0x4,%eax
  800f2c:	e8 8b fe ff ff       	call   800dbc <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	53                   	push   %ebx
  800f37:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3d:	8b 40 0c             	mov    0xc(%eax),%eax
  800f40:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800f45:	8b 45 10             	mov    0x10(%ebp),%eax
  800f48:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  800f4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f52:	b8 03 00 00 00       	mov    $0x3,%eax
  800f57:	e8 60 fe ff ff       	call   800dbc <fsipc>
  800f5c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 17                	js     800f79 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800f62:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f66:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800f6d:	00 
  800f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f71:	89 04 24             	mov    %eax,(%esp)
  800f74:	e8 cc 11 00 00       	call   802145 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800f79:	89 d8                	mov    %ebx,%eax
  800f7b:	83 c4 14             	add    $0x14,%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	53                   	push   %ebx
  800f85:	83 ec 14             	sub    $0x14,%esp
  800f88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800f8b:	89 1c 24             	mov    %ebx,(%esp)
  800f8e:	e8 7d 0f 00 00       	call   801f10 <strlen>
  800f93:	89 c2                	mov    %eax,%edx
  800f95:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800f9a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800fa0:	7f 1f                	jg     800fc1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800fa2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fa6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800fad:	e8 a8 0f 00 00       	call   801f5a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800fb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbc:	e8 fb fd ff ff       	call   800dbc <fsipc>
}
  800fc1:	83 c4 14             	add    $0x14,%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 28             	sub    $0x28,%esp
  800fcd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800fd0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800fd3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  800fd6:	89 34 24             	mov    %esi,(%esp)
  800fd9:	e8 32 0f 00 00       	call   801f10 <strlen>
  800fde:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800fe3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800fe8:	7f 6d                	jg     801057 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  800fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fed:	89 04 24             	mov    %eax,(%esp)
  800ff0:	e8 d6 f7 ff ff       	call   8007cb <fd_alloc>
  800ff5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 5c                	js     801057 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  800ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffe:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  801003:	89 34 24             	mov    %esi,(%esp)
  801006:	e8 05 0f 00 00       	call   801f10 <strlen>
  80100b:	83 c0 01             	add    $0x1,%eax
  80100e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801012:	89 74 24 04          	mov    %esi,0x4(%esp)
  801016:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80101d:	e8 23 11 00 00       	call   802145 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  801022:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801025:	b8 01 00 00 00       	mov    $0x1,%eax
  80102a:	e8 8d fd ff ff       	call   800dbc <fsipc>
  80102f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  801031:	85 c0                	test   %eax,%eax
  801033:	79 15                	jns    80104a <open+0x83>
             fd_close(fd,0);
  801035:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80103c:	00 
  80103d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801040:	89 04 24             	mov    %eax,(%esp)
  801043:	e8 37 fb ff ff       	call   800b7f <fd_close>
             return r;
  801048:	eb 0d                	jmp    801057 <open+0x90>
        }
        return fd2num(fd);
  80104a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104d:	89 04 24             	mov    %eax,(%esp)
  801050:	e8 4b f7 ff ff       	call   8007a0 <fd2num>
  801055:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  801057:	89 d8                	mov    %ebx,%eax
  801059:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80105c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80105f:	89 ec                	mov    %ebp,%esp
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    
	...

00801070 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801076:	c7 44 24 04 00 28 80 	movl   $0x802800,0x4(%esp)
  80107d:	00 
  80107e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801081:	89 04 24             	mov    %eax,(%esp)
  801084:	e8 d1 0e 00 00       	call   801f5a <strcpy>
	return 0;
}
  801089:	b8 00 00 00 00       	mov    $0x0,%eax
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	53                   	push   %ebx
  801094:	83 ec 14             	sub    $0x14,%esp
  801097:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80109a:	89 1c 24             	mov    %ebx,(%esp)
  80109d:	e8 ea 13 00 00       	call   80248c <pageref>
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a9:	83 fa 01             	cmp    $0x1,%edx
  8010ac:	75 0b                	jne    8010b9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8010ae:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010b1:	89 04 24             	mov    %eax,(%esp)
  8010b4:	e8 b9 02 00 00       	call   801372 <nsipc_close>
	else
		return 0;
}
  8010b9:	83 c4 14             	add    $0x14,%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8010c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010cc:	00 
  8010cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
  8010de:	8b 40 0c             	mov    0xc(%eax),%eax
  8010e1:	89 04 24             	mov    %eax,(%esp)
  8010e4:	e8 c5 02 00 00       	call   8013ae <nsipc_send>
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8010f1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010f8:	00 
  8010f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8010fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801100:	8b 45 0c             	mov    0xc(%ebp),%eax
  801103:	89 44 24 04          	mov    %eax,0x4(%esp)
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	8b 40 0c             	mov    0xc(%eax),%eax
  80110d:	89 04 24             	mov    %eax,(%esp)
  801110:	e8 0c 03 00 00       	call   801421 <nsipc_recv>
}
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	83 ec 20             	sub    $0x20,%esp
  80111f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801124:	89 04 24             	mov    %eax,(%esp)
  801127:	e8 9f f6 ff ff       	call   8007cb <fd_alloc>
  80112c:	89 c3                	mov    %eax,%ebx
  80112e:	85 c0                	test   %eax,%eax
  801130:	78 21                	js     801153 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801132:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801139:	00 
  80113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801148:	e8 af f4 ff ff       	call   8005fc <sys_page_alloc>
  80114d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 0a                	jns    80115d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801153:	89 34 24             	mov    %esi,(%esp)
  801156:	e8 17 02 00 00       	call   801372 <nsipc_close>
		return r;
  80115b:	eb 28                	jmp    801185 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80115d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801163:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801166:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801175:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117b:	89 04 24             	mov    %eax,(%esp)
  80117e:	e8 1d f6 ff ff       	call   8007a0 <fd2num>
  801183:	89 c3                	mov    %eax,%ebx
}
  801185:	89 d8                	mov    %ebx,%eax
  801187:	83 c4 20             	add    $0x20,%esp
  80118a:	5b                   	pop    %ebx
  80118b:	5e                   	pop    %esi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801194:	8b 45 10             	mov    0x10(%ebp),%eax
  801197:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a5:	89 04 24             	mov    %eax,(%esp)
  8011a8:	e8 79 01 00 00       	call   801326 <nsipc_socket>
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	78 05                	js     8011b6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8011b1:	e8 61 ff ff ff       	call   801117 <alloc_sockfd>
}
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8011be:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 70 f6 ff ff       	call   80083d <fd_lookup>
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 15                	js     8011e6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8011d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d4:	8b 0a                	mov    (%edx),%ecx
  8011d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011db:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  8011e1:	75 03                	jne    8011e6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8011e3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f1:	e8 c2 ff ff ff       	call   8011b8 <fd2sockid>
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	78 0f                	js     801209 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8011fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801201:	89 04 24             	mov    %eax,(%esp)
  801204:	e8 47 01 00 00       	call   801350 <nsipc_listen>
}
  801209:	c9                   	leave  
  80120a:	c3                   	ret    

0080120b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801211:	8b 45 08             	mov    0x8(%ebp),%eax
  801214:	e8 9f ff ff ff       	call   8011b8 <fd2sockid>
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 16                	js     801233 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80121d:	8b 55 10             	mov    0x10(%ebp),%edx
  801220:	89 54 24 08          	mov    %edx,0x8(%esp)
  801224:	8b 55 0c             	mov    0xc(%ebp),%edx
  801227:	89 54 24 04          	mov    %edx,0x4(%esp)
  80122b:	89 04 24             	mov    %eax,(%esp)
  80122e:	e8 6e 02 00 00       	call   8014a1 <nsipc_connect>
}
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
  80123e:	e8 75 ff ff ff       	call   8011b8 <fd2sockid>
  801243:	85 c0                	test   %eax,%eax
  801245:	78 0f                	js     801256 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80124e:	89 04 24             	mov    %eax,(%esp)
  801251:	e8 36 01 00 00       	call   80138c <nsipc_shutdown>
}
  801256:	c9                   	leave  
  801257:	c3                   	ret    

00801258 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80125e:	8b 45 08             	mov    0x8(%ebp),%eax
  801261:	e8 52 ff ff ff       	call   8011b8 <fd2sockid>
  801266:	85 c0                	test   %eax,%eax
  801268:	78 16                	js     801280 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80126a:	8b 55 10             	mov    0x10(%ebp),%edx
  80126d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801271:	8b 55 0c             	mov    0xc(%ebp),%edx
  801274:	89 54 24 04          	mov    %edx,0x4(%esp)
  801278:	89 04 24             	mov    %eax,(%esp)
  80127b:	e8 60 02 00 00       	call   8014e0 <nsipc_bind>
}
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801288:	8b 45 08             	mov    0x8(%ebp),%eax
  80128b:	e8 28 ff ff ff       	call   8011b8 <fd2sockid>
  801290:	85 c0                	test   %eax,%eax
  801292:	78 1f                	js     8012b3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801294:	8b 55 10             	mov    0x10(%ebp),%edx
  801297:	89 54 24 08          	mov    %edx,0x8(%esp)
  80129b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012a2:	89 04 24             	mov    %eax,(%esp)
  8012a5:	e8 75 02 00 00       	call   80151f <nsipc_accept>
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 05                	js     8012b3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8012ae:	e8 64 fe ff ff       	call   801117 <alloc_sockfd>
}
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    
	...

008012c0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 14             	sub    $0x14,%esp
  8012c7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8012c9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8012d0:	75 11                	jne    8012e3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8012d2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8012d9:	e8 72 10 00 00       	call   802350 <ipc_find_env>
  8012de:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8012e3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8012ea:	00 
  8012eb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8012f2:	00 
  8012f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8012fc:	89 04 24             	mov    %eax,(%esp)
  8012ff:	e8 97 10 00 00       	call   80239b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801304:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80130b:	00 
  80130c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801313:	00 
  801314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80131b:	e8 f9 10 00 00       	call   802419 <ipc_recv>
}
  801320:	83 c4 14             	add    $0x14,%esp
  801323:	5b                   	pop    %ebx
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801334:	8b 45 0c             	mov    0xc(%ebp),%eax
  801337:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80133c:	8b 45 10             	mov    0x10(%ebp),%eax
  80133f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801344:	b8 09 00 00 00       	mov    $0x9,%eax
  801349:	e8 72 ff ff ff       	call   8012c0 <nsipc>
}
  80134e:	c9                   	leave  
  80134f:	c3                   	ret    

00801350 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801356:	8b 45 08             	mov    0x8(%ebp),%eax
  801359:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80135e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801361:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801366:	b8 06 00 00 00       	mov    $0x6,%eax
  80136b:	e8 50 ff ff ff       	call   8012c0 <nsipc>
}
  801370:	c9                   	leave  
  801371:	c3                   	ret    

00801372 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801380:	b8 04 00 00 00       	mov    $0x4,%eax
  801385:	e8 36 ff ff ff       	call   8012c0 <nsipc>
}
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80139a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8013a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8013a7:	e8 14 ff ff ff       	call   8012c0 <nsipc>
}
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 14             	sub    $0x14,%esp
  8013b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8013c0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8013c6:	7e 24                	jle    8013ec <nsipc_send+0x3e>
  8013c8:	c7 44 24 0c 0c 28 80 	movl   $0x80280c,0xc(%esp)
  8013cf:	00 
  8013d0:	c7 44 24 08 18 28 80 	movl   $0x802818,0x8(%esp)
  8013d7:	00 
  8013d8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8013df:	00 
  8013e0:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  8013e7:	e8 88 01 00 00       	call   801574 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8013ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8013fe:	e8 42 0d 00 00       	call   802145 <memmove>
	nsipcbuf.send.req_size = size;
  801403:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801409:	8b 45 14             	mov    0x14(%ebp),%eax
  80140c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801411:	b8 08 00 00 00       	mov    $0x8,%eax
  801416:	e8 a5 fe ff ff       	call   8012c0 <nsipc>
}
  80141b:	83 c4 14             	add    $0x14,%esp
  80141e:	5b                   	pop    %ebx
  80141f:	5d                   	pop    %ebp
  801420:	c3                   	ret    

00801421 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	56                   	push   %esi
  801425:	53                   	push   %ebx
  801426:	83 ec 10             	sub    $0x10,%esp
  801429:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801434:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80143a:	8b 45 14             	mov    0x14(%ebp),%eax
  80143d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801442:	b8 07 00 00 00       	mov    $0x7,%eax
  801447:	e8 74 fe ff ff       	call   8012c0 <nsipc>
  80144c:	89 c3                	mov    %eax,%ebx
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 46                	js     801498 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801452:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801457:	7f 04                	jg     80145d <nsipc_recv+0x3c>
  801459:	39 c6                	cmp    %eax,%esi
  80145b:	7d 24                	jge    801481 <nsipc_recv+0x60>
  80145d:	c7 44 24 0c 39 28 80 	movl   $0x802839,0xc(%esp)
  801464:	00 
  801465:	c7 44 24 08 18 28 80 	movl   $0x802818,0x8(%esp)
  80146c:	00 
  80146d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801474:	00 
  801475:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  80147c:	e8 f3 00 00 00       	call   801574 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801481:	89 44 24 08          	mov    %eax,0x8(%esp)
  801485:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80148c:	00 
  80148d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801490:	89 04 24             	mov    %eax,(%esp)
  801493:	e8 ad 0c 00 00       	call   802145 <memmove>
	}

	return r;
}
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	5b                   	pop    %ebx
  80149e:	5e                   	pop    %esi
  80149f:	5d                   	pop    %ebp
  8014a0:	c3                   	ret    

008014a1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 14             	sub    $0x14,%esp
  8014a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8014b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014be:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8014c5:	e8 7b 0c 00 00       	call   802145 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8014ca:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8014d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d5:	e8 e6 fd ff ff       	call   8012c0 <nsipc>
}
  8014da:	83 c4 14             	add    $0x14,%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 14             	sub    $0x14,%esp
  8014e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8014f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fd:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801504:	e8 3c 0c 00 00       	call   802145 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801509:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80150f:	b8 02 00 00 00       	mov    $0x2,%eax
  801514:	e8 a7 fd ff ff       	call   8012c0 <nsipc>
}
  801519:	83 c4 14             	add    $0x14,%esp
  80151c:	5b                   	pop    %ebx
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    

0080151f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	83 ec 18             	sub    $0x18,%esp
  801525:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801528:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801533:	b8 01 00 00 00       	mov    $0x1,%eax
  801538:	e8 83 fd ff ff       	call   8012c0 <nsipc>
  80153d:	89 c3                	mov    %eax,%ebx
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 25                	js     801568 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801543:	be 10 60 80 00       	mov    $0x806010,%esi
  801548:	8b 06                	mov    (%esi),%eax
  80154a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80154e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801555:	00 
  801556:	8b 45 0c             	mov    0xc(%ebp),%eax
  801559:	89 04 24             	mov    %eax,(%esp)
  80155c:	e8 e4 0b 00 00       	call   802145 <memmove>
		*addrlen = ret->ret_addrlen;
  801561:	8b 16                	mov    (%esi),%edx
  801563:	8b 45 10             	mov    0x10(%ebp),%eax
  801566:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801568:	89 d8                	mov    %ebx,%eax
  80156a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80156d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801570:	89 ec                	mov    %ebp,%esp
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	56                   	push   %esi
  801578:	53                   	push   %ebx
  801579:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80157c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80157f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801585:	e8 61 f1 ff ff       	call   8006eb <sys_getenvid>
  80158a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801591:	8b 55 08             	mov    0x8(%ebp),%edx
  801594:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801598:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80159c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a0:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  8015a7:	e8 81 00 00 00       	call   80162d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015b3:	89 04 24             	mov    %eax,(%esp)
  8015b6:	e8 11 00 00 00       	call   8015cc <vcprintf>
	cprintf("\n");
  8015bb:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  8015c2:	e8 66 00 00 00       	call   80162d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015c7:	cc                   	int3   
  8015c8:	eb fd                	jmp    8015c7 <_panic+0x53>
	...

008015cc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8015d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015dc:	00 00 00 
	b.cnt = 0;
  8015df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801601:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  801608:	e8 cf 01 00 00       	call   8017dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80160d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801613:	89 44 24 04          	mov    %eax,0x4(%esp)
  801617:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80161d:	89 04 24             	mov    %eax,(%esp)
  801620:	e8 db ea ff ff       	call   800100 <sys_cputs>

	return b.cnt;
}
  801625:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80162b:	c9                   	leave  
  80162c:	c3                   	ret    

0080162d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801633:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	8b 45 08             	mov    0x8(%ebp),%eax
  80163d:	89 04 24             	mov    %eax,(%esp)
  801640:	e8 87 ff ff ff       	call   8015cc <vcprintf>
	va_end(ap);

	return cnt;
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
  80164e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801651:	8b 03                	mov    (%ebx),%eax
  801653:	8b 55 08             	mov    0x8(%ebp),%edx
  801656:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80165a:	83 c0 01             	add    $0x1,%eax
  80165d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80165f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801664:	75 19                	jne    80167f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801666:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80166d:	00 
  80166e:	8d 43 08             	lea    0x8(%ebx),%eax
  801671:	89 04 24             	mov    %eax,(%esp)
  801674:	e8 87 ea ff ff       	call   800100 <sys_cputs>
		b->idx = 0;
  801679:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80167f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801683:	83 c4 14             	add    $0x14,%esp
  801686:	5b                   	pop    %ebx
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    
  801689:	00 00                	add    %al,(%eax)
  80168b:	00 00                	add    %al,(%eax)
  80168d:	00 00                	add    %al,(%eax)
	...

00801690 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	57                   	push   %edi
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 4c             	sub    $0x4c,%esp
  801699:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80169c:	89 d6                	mov    %edx,%esi
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8016aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8016b0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8016b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016bb:	39 d1                	cmp    %edx,%ecx
  8016bd:	72 07                	jb     8016c6 <printnum_v2+0x36>
  8016bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016c2:	39 d0                	cmp    %edx,%eax
  8016c4:	77 5f                	ja     801725 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8016c6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8016ca:	83 eb 01             	sub    $0x1,%ebx
  8016cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8016d9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8016dd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8016e0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8016e3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8016e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016f1:	00 
  8016f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8016fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016ff:	e8 cc 0d 00 00       	call   8024d0 <__udivdi3>
  801704:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801707:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80170a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80170e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801712:	89 04 24             	mov    %eax,(%esp)
  801715:	89 54 24 04          	mov    %edx,0x4(%esp)
  801719:	89 f2                	mov    %esi,%edx
  80171b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171e:	e8 6d ff ff ff       	call   801690 <printnum_v2>
  801723:	eb 1e                	jmp    801743 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801725:	83 ff 2d             	cmp    $0x2d,%edi
  801728:	74 19                	je     801743 <printnum_v2+0xb3>
		while (--width > 0)
  80172a:	83 eb 01             	sub    $0x1,%ebx
  80172d:	85 db                	test   %ebx,%ebx
  80172f:	90                   	nop
  801730:	7e 11                	jle    801743 <printnum_v2+0xb3>
			putch(padc, putdat);
  801732:	89 74 24 04          	mov    %esi,0x4(%esp)
  801736:	89 3c 24             	mov    %edi,(%esp)
  801739:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80173c:	83 eb 01             	sub    $0x1,%ebx
  80173f:	85 db                	test   %ebx,%ebx
  801741:	7f ef                	jg     801732 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801743:	89 74 24 04          	mov    %esi,0x4(%esp)
  801747:	8b 74 24 04          	mov    0x4(%esp),%esi
  80174b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80174e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801752:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801759:	00 
  80175a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80175d:	89 14 24             	mov    %edx,(%esp)
  801760:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801763:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801767:	e8 94 0e 00 00       	call   802600 <__umoddi3>
  80176c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801770:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
  801777:	89 04 24             	mov    %eax,(%esp)
  80177a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80177d:	83 c4 4c             	add    $0x4c,%esp
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5f                   	pop    %edi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801788:	83 fa 01             	cmp    $0x1,%edx
  80178b:	7e 0e                	jle    80179b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80178d:	8b 10                	mov    (%eax),%edx
  80178f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801792:	89 08                	mov    %ecx,(%eax)
  801794:	8b 02                	mov    (%edx),%eax
  801796:	8b 52 04             	mov    0x4(%edx),%edx
  801799:	eb 22                	jmp    8017bd <getuint+0x38>
	else if (lflag)
  80179b:	85 d2                	test   %edx,%edx
  80179d:	74 10                	je     8017af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80179f:	8b 10                	mov    (%eax),%edx
  8017a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017a4:	89 08                	mov    %ecx,(%eax)
  8017a6:	8b 02                	mov    (%edx),%eax
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ad:	eb 0e                	jmp    8017bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017af:	8b 10                	mov    (%eax),%edx
  8017b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017b4:	89 08                	mov    %ecx,(%eax)
  8017b6:	8b 02                	mov    (%edx),%eax
  8017b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017c9:	8b 10                	mov    (%eax),%edx
  8017cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8017ce:	73 0a                	jae    8017da <sprintputch+0x1b>
		*b->buf++ = ch;
  8017d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d3:	88 0a                	mov    %cl,(%edx)
  8017d5:	83 c2 01             	add    $0x1,%edx
  8017d8:	89 10                	mov    %edx,(%eax)
}
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	57                   	push   %edi
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 6c             	sub    $0x6c,%esp
  8017e5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8017e8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8017ef:	eb 1a                	jmp    80180b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	0f 84 66 06 00 00    	je     801e5f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8017f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801800:	89 04 24             	mov    %eax,(%esp)
  801803:	ff 55 08             	call   *0x8(%ebp)
  801806:	eb 03                	jmp    80180b <vprintfmt+0x2f>
  801808:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80180b:	0f b6 07             	movzbl (%edi),%eax
  80180e:	83 c7 01             	add    $0x1,%edi
  801811:	83 f8 25             	cmp    $0x25,%eax
  801814:	75 db                	jne    8017f1 <vprintfmt+0x15>
  801816:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80181a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80181f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801826:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80182b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801832:	be 00 00 00 00       	mov    $0x0,%esi
  801837:	eb 06                	jmp    80183f <vprintfmt+0x63>
  801839:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80183d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183f:	0f b6 17             	movzbl (%edi),%edx
  801842:	0f b6 c2             	movzbl %dl,%eax
  801845:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801848:	8d 47 01             	lea    0x1(%edi),%eax
  80184b:	83 ea 23             	sub    $0x23,%edx
  80184e:	80 fa 55             	cmp    $0x55,%dl
  801851:	0f 87 60 05 00 00    	ja     801db7 <vprintfmt+0x5db>
  801857:	0f b6 d2             	movzbl %dl,%edx
  80185a:	ff 24 95 60 2a 80 00 	jmp    *0x802a60(,%edx,4)
  801861:	b9 01 00 00 00       	mov    $0x1,%ecx
  801866:	eb d5                	jmp    80183d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801868:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80186b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80186e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801871:	8d 7a d0             	lea    -0x30(%edx),%edi
  801874:	83 ff 09             	cmp    $0x9,%edi
  801877:	76 08                	jbe    801881 <vprintfmt+0xa5>
  801879:	eb 40                	jmp    8018bb <vprintfmt+0xdf>
  80187b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80187f:	eb bc                	jmp    80183d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801881:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801884:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  801887:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80188b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80188e:	8d 7a d0             	lea    -0x30(%edx),%edi
  801891:	83 ff 09             	cmp    $0x9,%edi
  801894:	76 eb                	jbe    801881 <vprintfmt+0xa5>
  801896:	eb 23                	jmp    8018bb <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801898:	8b 55 14             	mov    0x14(%ebp),%edx
  80189b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80189e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8018a1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8018a3:	eb 16                	jmp    8018bb <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8018a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018a8:	c1 fa 1f             	sar    $0x1f,%edx
  8018ab:	f7 d2                	not    %edx
  8018ad:	21 55 d8             	and    %edx,-0x28(%ebp)
  8018b0:	eb 8b                	jmp    80183d <vprintfmt+0x61>
  8018b2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8018b9:	eb 82                	jmp    80183d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8018bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018bf:	0f 89 78 ff ff ff    	jns    80183d <vprintfmt+0x61>
  8018c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8018c8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8018cb:	e9 6d ff ff ff       	jmp    80183d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018d0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8018d3:	e9 65 ff ff ff       	jmp    80183d <vprintfmt+0x61>
  8018d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018db:	8b 45 14             	mov    0x14(%ebp),%eax
  8018de:	8d 50 04             	lea    0x4(%eax),%edx
  8018e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018eb:	8b 00                	mov    (%eax),%eax
  8018ed:	89 04 24             	mov    %eax,(%esp)
  8018f0:	ff 55 08             	call   *0x8(%ebp)
  8018f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8018f6:	e9 10 ff ff ff       	jmp    80180b <vprintfmt+0x2f>
  8018fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801901:	8d 50 04             	lea    0x4(%eax),%edx
  801904:	89 55 14             	mov    %edx,0x14(%ebp)
  801907:	8b 00                	mov    (%eax),%eax
  801909:	89 c2                	mov    %eax,%edx
  80190b:	c1 fa 1f             	sar    $0x1f,%edx
  80190e:	31 d0                	xor    %edx,%eax
  801910:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801912:	83 f8 0f             	cmp    $0xf,%eax
  801915:	7f 0b                	jg     801922 <vprintfmt+0x146>
  801917:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  80191e:	85 d2                	test   %edx,%edx
  801920:	75 26                	jne    801948 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801922:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801926:	c7 44 24 08 84 28 80 	movl   $0x802884,0x8(%esp)
  80192d:	00 
  80192e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801931:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801935:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801938:	89 1c 24             	mov    %ebx,(%esp)
  80193b:	e8 a7 05 00 00       	call   801ee7 <printfmt>
  801940:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801943:	e9 c3 fe ff ff       	jmp    80180b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801948:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80194c:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  801953:	00 
  801954:	8b 45 0c             	mov    0xc(%ebp),%eax
  801957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195b:	8b 55 08             	mov    0x8(%ebp),%edx
  80195e:	89 14 24             	mov    %edx,(%esp)
  801961:	e8 81 05 00 00       	call   801ee7 <printfmt>
  801966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801969:	e9 9d fe ff ff       	jmp    80180b <vprintfmt+0x2f>
  80196e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801971:	89 c7                	mov    %eax,%edi
  801973:	89 d9                	mov    %ebx,%ecx
  801975:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801978:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80197b:	8b 45 14             	mov    0x14(%ebp),%eax
  80197e:	8d 50 04             	lea    0x4(%eax),%edx
  801981:	89 55 14             	mov    %edx,0x14(%ebp)
  801984:	8b 30                	mov    (%eax),%esi
  801986:	85 f6                	test   %esi,%esi
  801988:	75 05                	jne    80198f <vprintfmt+0x1b3>
  80198a:	be 8d 28 80 00       	mov    $0x80288d,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80198f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  801993:	7e 06                	jle    80199b <vprintfmt+0x1bf>
  801995:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  801999:	75 10                	jne    8019ab <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80199b:	0f be 06             	movsbl (%esi),%eax
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	0f 85 a2 00 00 00    	jne    801a48 <vprintfmt+0x26c>
  8019a6:	e9 92 00 00 00       	jmp    801a3d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019af:	89 34 24             	mov    %esi,(%esp)
  8019b2:	e8 74 05 00 00       	call   801f2b <strnlen>
  8019b7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8019ba:	29 c2                	sub    %eax,%edx
  8019bc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8019bf:	85 d2                	test   %edx,%edx
  8019c1:	7e d8                	jle    80199b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8019c3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8019c7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8019ca:	89 d3                	mov    %edx,%ebx
  8019cc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8019cf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8019d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019d5:	89 ce                	mov    %ecx,%esi
  8019d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019db:	89 34 24             	mov    %esi,(%esp)
  8019de:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019e1:	83 eb 01             	sub    $0x1,%ebx
  8019e4:	85 db                	test   %ebx,%ebx
  8019e6:	7f ef                	jg     8019d7 <vprintfmt+0x1fb>
  8019e8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8019eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8019ee:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8019f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8019f8:	eb a1                	jmp    80199b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019fa:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8019fe:	74 1b                	je     801a1b <vprintfmt+0x23f>
  801a00:	8d 50 e0             	lea    -0x20(%eax),%edx
  801a03:	83 fa 5e             	cmp    $0x5e,%edx
  801a06:	76 13                	jbe    801a1b <vprintfmt+0x23f>
					putch('?', putdat);
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801a16:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a19:	eb 0d                	jmp    801a28 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a22:	89 04 24             	mov    %eax,(%esp)
  801a25:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a28:	83 ef 01             	sub    $0x1,%edi
  801a2b:	0f be 06             	movsbl (%esi),%eax
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	74 05                	je     801a37 <vprintfmt+0x25b>
  801a32:	83 c6 01             	add    $0x1,%esi
  801a35:	eb 1a                	jmp    801a51 <vprintfmt+0x275>
  801a37:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a3a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a3d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a41:	7f 1f                	jg     801a62 <vprintfmt+0x286>
  801a43:	e9 c0 fd ff ff       	jmp    801808 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a48:	83 c6 01             	add    $0x1,%esi
  801a4b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801a4e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801a51:	85 db                	test   %ebx,%ebx
  801a53:	78 a5                	js     8019fa <vprintfmt+0x21e>
  801a55:	83 eb 01             	sub    $0x1,%ebx
  801a58:	79 a0                	jns    8019fa <vprintfmt+0x21e>
  801a5a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a5d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801a60:	eb db                	jmp    801a3d <vprintfmt+0x261>
  801a62:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a68:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a6b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a72:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a79:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a7b:	83 eb 01             	sub    $0x1,%ebx
  801a7e:	85 db                	test   %ebx,%ebx
  801a80:	7f ec                	jg     801a6e <vprintfmt+0x292>
  801a82:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801a85:	e9 81 fd ff ff       	jmp    80180b <vprintfmt+0x2f>
  801a8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a8d:	83 fe 01             	cmp    $0x1,%esi
  801a90:	7e 10                	jle    801aa2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801a92:	8b 45 14             	mov    0x14(%ebp),%eax
  801a95:	8d 50 08             	lea    0x8(%eax),%edx
  801a98:	89 55 14             	mov    %edx,0x14(%ebp)
  801a9b:	8b 18                	mov    (%eax),%ebx
  801a9d:	8b 70 04             	mov    0x4(%eax),%esi
  801aa0:	eb 26                	jmp    801ac8 <vprintfmt+0x2ec>
	else if (lflag)
  801aa2:	85 f6                	test   %esi,%esi
  801aa4:	74 12                	je     801ab8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801aa6:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa9:	8d 50 04             	lea    0x4(%eax),%edx
  801aac:	89 55 14             	mov    %edx,0x14(%ebp)
  801aaf:	8b 18                	mov    (%eax),%ebx
  801ab1:	89 de                	mov    %ebx,%esi
  801ab3:	c1 fe 1f             	sar    $0x1f,%esi
  801ab6:	eb 10                	jmp    801ac8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  801abb:	8d 50 04             	lea    0x4(%eax),%edx
  801abe:	89 55 14             	mov    %edx,0x14(%ebp)
  801ac1:	8b 18                	mov    (%eax),%ebx
  801ac3:	89 de                	mov    %ebx,%esi
  801ac5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  801ac8:	83 f9 01             	cmp    $0x1,%ecx
  801acb:	75 1e                	jne    801aeb <vprintfmt+0x30f>
                               if((long long)num > 0){
  801acd:	85 f6                	test   %esi,%esi
  801acf:	78 1a                	js     801aeb <vprintfmt+0x30f>
  801ad1:	85 f6                	test   %esi,%esi
  801ad3:	7f 05                	jg     801ada <vprintfmt+0x2fe>
  801ad5:	83 fb 00             	cmp    $0x0,%ebx
  801ad8:	76 11                	jbe    801aeb <vprintfmt+0x30f>
                                   putch('+',putdat);
  801ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801add:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ae1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  801ae8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  801aeb:	85 f6                	test   %esi,%esi
  801aed:	78 13                	js     801b02 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801aef:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  801af2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  801af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801af8:	b8 0a 00 00 00       	mov    $0xa,%eax
  801afd:	e9 da 00 00 00       	jmp    801bdc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  801b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801b10:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801b13:	89 da                	mov    %ebx,%edx
  801b15:	89 f1                	mov    %esi,%ecx
  801b17:	f7 da                	neg    %edx
  801b19:	83 d1 00             	adc    $0x0,%ecx
  801b1c:	f7 d9                	neg    %ecx
  801b1e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801b21:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801b24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b27:	b8 0a 00 00 00       	mov    $0xa,%eax
  801b2c:	e9 ab 00 00 00       	jmp    801bdc <vprintfmt+0x400>
  801b31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b34:	89 f2                	mov    %esi,%edx
  801b36:	8d 45 14             	lea    0x14(%ebp),%eax
  801b39:	e8 47 fc ff ff       	call   801785 <getuint>
  801b3e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801b41:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801b44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b47:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  801b4c:	e9 8b 00 00 00       	jmp    801bdc <vprintfmt+0x400>
  801b51:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b57:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b5b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b62:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801b65:	89 f2                	mov    %esi,%edx
  801b67:	8d 45 14             	lea    0x14(%ebp),%eax
  801b6a:	e8 16 fc ff ff       	call   801785 <getuint>
  801b6f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801b72:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801b75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b78:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  801b7d:	eb 5d                	jmp    801bdc <vprintfmt+0x400>
  801b7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801b82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b89:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b90:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801b93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b97:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801b9e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801ba1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ba4:	8d 50 04             	lea    0x4(%eax),%edx
  801ba7:	89 55 14             	mov    %edx,0x14(%ebp)
  801baa:	8b 10                	mov    (%eax),%edx
  801bac:	b9 00 00 00 00       	mov    $0x0,%ecx
  801bb1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801bb4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801bb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bba:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801bbf:	eb 1b                	jmp    801bdc <vprintfmt+0x400>
  801bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bc4:	89 f2                	mov    %esi,%edx
  801bc6:	8d 45 14             	lea    0x14(%ebp),%eax
  801bc9:	e8 b7 fb ff ff       	call   801785 <getuint>
  801bce:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801bd1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801bd4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bd7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bdc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  801be0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801be3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801be6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  801bea:	77 09                	ja     801bf5 <vprintfmt+0x419>
  801bec:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  801bef:	0f 82 ac 00 00 00    	jb     801ca1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801bf5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801bf8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801bfc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801bff:	83 ea 01             	sub    $0x1,%edx
  801c02:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c06:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0a:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c0e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801c12:	89 45 c0             	mov    %eax,-0x40(%ebp)
  801c15:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801c18:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801c1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c26:	00 
  801c27:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801c2a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801c2d:	89 0c 24             	mov    %ecx,(%esp)
  801c30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c34:	e8 97 08 00 00       	call   8024d0 <__udivdi3>
  801c39:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  801c3c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801c3f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c43:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c47:	89 04 24             	mov    %eax,(%esp)
  801c4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c51:	8b 45 08             	mov    0x8(%ebp),%eax
  801c54:	e8 37 fa ff ff       	call   801690 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c60:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c64:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801c67:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c6b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c72:	00 
  801c73:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801c76:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801c79:	89 14 24             	mov    %edx,(%esp)
  801c7c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c80:	e8 7b 09 00 00       	call   802600 <__umoddi3>
  801c85:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c89:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
  801c90:	89 04 24             	mov    %eax,(%esp)
  801c93:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801c96:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801c9a:	74 54                	je     801cf0 <vprintfmt+0x514>
  801c9c:	e9 67 fb ff ff       	jmp    801808 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801ca1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	0f 84 2a 01 00 00    	je     801dd8 <vprintfmt+0x5fc>
		while (--width > 0)
  801cae:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801cb1:	83 ef 01             	sub    $0x1,%edi
  801cb4:	85 ff                	test   %edi,%edi
  801cb6:	0f 8e 5e 01 00 00    	jle    801e1a <vprintfmt+0x63e>
  801cbc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801cbf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801cc2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801cc5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801cc8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801ccb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  801cce:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd2:	89 1c 24             	mov    %ebx,(%esp)
  801cd5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  801cd8:	83 ef 01             	sub    $0x1,%edi
  801cdb:	85 ff                	test   %edi,%edi
  801cdd:	7f ef                	jg     801cce <vprintfmt+0x4f2>
  801cdf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ce2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ce5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801ce8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801ceb:	e9 2a 01 00 00       	jmp    801e1a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801cf0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801cf3:	83 eb 01             	sub    $0x1,%ebx
  801cf6:	85 db                	test   %ebx,%ebx
  801cf8:	0f 8e 0a fb ff ff    	jle    801808 <vprintfmt+0x2c>
  801cfe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d01:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801d04:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  801d07:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801d12:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801d14:	83 eb 01             	sub    $0x1,%ebx
  801d17:	85 db                	test   %ebx,%ebx
  801d19:	7f ec                	jg     801d07 <vprintfmt+0x52b>
  801d1b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801d1e:	e9 e8 fa ff ff       	jmp    80180b <vprintfmt+0x2f>
  801d23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801d26:	8b 45 14             	mov    0x14(%ebp),%eax
  801d29:	8d 50 04             	lea    0x4(%eax),%edx
  801d2c:	89 55 14             	mov    %edx,0x14(%ebp)
  801d2f:	8b 00                	mov    (%eax),%eax
  801d31:	85 c0                	test   %eax,%eax
  801d33:	75 2a                	jne    801d5f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801d35:	c7 44 24 0c a8 29 80 	movl   $0x8029a8,0xc(%esp)
  801d3c:	00 
  801d3d:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  801d44:	00 
  801d45:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d48:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4f:	89 0c 24             	mov    %ecx,(%esp)
  801d52:	e8 90 01 00 00       	call   801ee7 <printfmt>
  801d57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d5a:	e9 ac fa ff ff       	jmp    80180b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  801d5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d62:	8b 13                	mov    (%ebx),%edx
  801d64:	83 fa 7f             	cmp    $0x7f,%edx
  801d67:	7e 29                	jle    801d92 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801d69:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  801d6b:	c7 44 24 0c e0 29 80 	movl   $0x8029e0,0xc(%esp)
  801d72:	00 
  801d73:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  801d7a:	00 
  801d7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d82:	89 04 24             	mov    %eax,(%esp)
  801d85:	e8 5d 01 00 00       	call   801ee7 <printfmt>
  801d8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d8d:	e9 79 fa ff ff       	jmp    80180b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801d92:	88 10                	mov    %dl,(%eax)
  801d94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d97:	e9 6f fa ff ff       	jmp    80180b <vprintfmt+0x2f>
  801d9c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801da9:	89 14 24             	mov    %edx,(%esp)
  801dac:	ff 55 08             	call   *0x8(%ebp)
  801daf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801db2:	e9 54 fa ff ff       	jmp    80180b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801db7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dbe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801dc5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801dc8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801dcb:	80 38 25             	cmpb   $0x25,(%eax)
  801dce:	0f 84 37 fa ff ff    	je     80180b <vprintfmt+0x2f>
  801dd4:	89 c7                	mov    %eax,%edi
  801dd6:	eb f0                	jmp    801dc8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddf:	8b 74 24 04          	mov    0x4(%esp),%esi
  801de3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801de6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801df1:	00 
  801df2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801df5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801df8:	89 04 24             	mov    %eax,(%esp)
  801dfb:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dff:	e8 fc 07 00 00       	call   802600 <__umoddi3>
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
  801e0f:	89 04 24             	mov    %eax,(%esp)
  801e12:	ff 55 08             	call   *0x8(%ebp)
  801e15:	e9 d6 fe ff ff       	jmp    801cf0 <vprintfmt+0x514>
  801e1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e21:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e25:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e33:	00 
  801e34:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801e37:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801e3a:	89 04 24             	mov    %eax,(%esp)
  801e3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e41:	e8 ba 07 00 00       	call   802600 <__umoddi3>
  801e46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e4a:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
  801e51:	89 04 24             	mov    %eax,(%esp)
  801e54:	ff 55 08             	call   *0x8(%ebp)
  801e57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e5a:	e9 ac f9 ff ff       	jmp    80180b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801e5f:	83 c4 6c             	add    $0x6c,%esp
  801e62:	5b                   	pop    %ebx
  801e63:	5e                   	pop    %esi
  801e64:	5f                   	pop    %edi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 28             	sub    $0x28,%esp
  801e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e70:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801e73:	85 c0                	test   %eax,%eax
  801e75:	74 04                	je     801e7b <vsnprintf+0x14>
  801e77:	85 d2                	test   %edx,%edx
  801e79:	7f 07                	jg     801e82 <vsnprintf+0x1b>
  801e7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e80:	eb 3b                	jmp    801ebd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801e82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e85:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801e89:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801e8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801e93:	8b 45 14             	mov    0x14(%ebp),%eax
  801e96:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ea4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea8:	c7 04 24 bf 17 80 00 	movl   $0x8017bf,(%esp)
  801eaf:	e8 28 f9 ff ff       	call   8017dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801eb7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801ec5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801ec8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ecf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	89 04 24             	mov    %eax,(%esp)
  801ee0:	e8 82 ff ff ff       	call   801e67 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ee5:	c9                   	leave  
  801ee6:	c3                   	ret    

00801ee7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801eed:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801ef0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ef4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801efb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f02:	8b 45 08             	mov    0x8(%ebp),%eax
  801f05:	89 04 24             	mov    %eax,(%esp)
  801f08:	e8 cf f8 ff ff       	call   8017dc <vprintfmt>
	va_end(ap);
}
  801f0d:	c9                   	leave  
  801f0e:	c3                   	ret    
	...

00801f10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801f16:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1b:	80 3a 00             	cmpb   $0x0,(%edx)
  801f1e:	74 09                	je     801f29 <strlen+0x19>
		n++;
  801f20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801f23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801f27:	75 f7                	jne    801f20 <strlen+0x10>
		n++;
	return n;
}
  801f29:	5d                   	pop    %ebp
  801f2a:	c3                   	ret    

00801f2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	53                   	push   %ebx
  801f2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801f35:	85 c9                	test   %ecx,%ecx
  801f37:	74 19                	je     801f52 <strnlen+0x27>
  801f39:	80 3b 00             	cmpb   $0x0,(%ebx)
  801f3c:	74 14                	je     801f52 <strnlen+0x27>
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801f43:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801f46:	39 c8                	cmp    %ecx,%eax
  801f48:	74 0d                	je     801f57 <strnlen+0x2c>
  801f4a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801f4e:	75 f3                	jne    801f43 <strnlen+0x18>
  801f50:	eb 05                	jmp    801f57 <strnlen+0x2c>
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801f57:	5b                   	pop    %ebx
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	53                   	push   %ebx
  801f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f64:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801f69:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801f6d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801f70:	83 c2 01             	add    $0x1,%edx
  801f73:	84 c9                	test   %cl,%cl
  801f75:	75 f2                	jne    801f69 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801f77:	5b                   	pop    %ebx
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 08             	sub    $0x8,%esp
  801f81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801f84:	89 1c 24             	mov    %ebx,(%esp)
  801f87:	e8 84 ff ff ff       	call   801f10 <strlen>
	strcpy(dst + len, src);
  801f8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f93:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801f96:	89 04 24             	mov    %eax,(%esp)
  801f99:	e8 bc ff ff ff       	call   801f5a <strcpy>
	return dst;
}
  801f9e:	89 d8                	mov    %ebx,%eax
  801fa0:	83 c4 08             	add    $0x8,%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    

00801fa6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	56                   	push   %esi
  801faa:	53                   	push   %ebx
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801fb4:	85 f6                	test   %esi,%esi
  801fb6:	74 18                	je     801fd0 <strncpy+0x2a>
  801fb8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801fbd:	0f b6 1a             	movzbl (%edx),%ebx
  801fc0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801fc3:	80 3a 01             	cmpb   $0x1,(%edx)
  801fc6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801fc9:	83 c1 01             	add    $0x1,%ecx
  801fcc:	39 ce                	cmp    %ecx,%esi
  801fce:	77 ed                	ja     801fbd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    

00801fd4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	56                   	push   %esi
  801fd8:	53                   	push   %ebx
  801fd9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801fe2:	89 f0                	mov    %esi,%eax
  801fe4:	85 c9                	test   %ecx,%ecx
  801fe6:	74 27                	je     80200f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801fe8:	83 e9 01             	sub    $0x1,%ecx
  801feb:	74 1d                	je     80200a <strlcpy+0x36>
  801fed:	0f b6 1a             	movzbl (%edx),%ebx
  801ff0:	84 db                	test   %bl,%bl
  801ff2:	74 16                	je     80200a <strlcpy+0x36>
			*dst++ = *src++;
  801ff4:	88 18                	mov    %bl,(%eax)
  801ff6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ff9:	83 e9 01             	sub    $0x1,%ecx
  801ffc:	74 0e                	je     80200c <strlcpy+0x38>
			*dst++ = *src++;
  801ffe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802001:	0f b6 1a             	movzbl (%edx),%ebx
  802004:	84 db                	test   %bl,%bl
  802006:	75 ec                	jne    801ff4 <strlcpy+0x20>
  802008:	eb 02                	jmp    80200c <strlcpy+0x38>
  80200a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80200c:	c6 00 00             	movb   $0x0,(%eax)
  80200f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80201b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80201e:	0f b6 01             	movzbl (%ecx),%eax
  802021:	84 c0                	test   %al,%al
  802023:	74 15                	je     80203a <strcmp+0x25>
  802025:	3a 02                	cmp    (%edx),%al
  802027:	75 11                	jne    80203a <strcmp+0x25>
		p++, q++;
  802029:	83 c1 01             	add    $0x1,%ecx
  80202c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80202f:	0f b6 01             	movzbl (%ecx),%eax
  802032:	84 c0                	test   %al,%al
  802034:	74 04                	je     80203a <strcmp+0x25>
  802036:	3a 02                	cmp    (%edx),%al
  802038:	74 ef                	je     802029 <strcmp+0x14>
  80203a:	0f b6 c0             	movzbl %al,%eax
  80203d:	0f b6 12             	movzbl (%edx),%edx
  802040:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	53                   	push   %ebx
  802048:	8b 55 08             	mov    0x8(%ebp),%edx
  80204b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80204e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  802051:	85 c0                	test   %eax,%eax
  802053:	74 23                	je     802078 <strncmp+0x34>
  802055:	0f b6 1a             	movzbl (%edx),%ebx
  802058:	84 db                	test   %bl,%bl
  80205a:	74 25                	je     802081 <strncmp+0x3d>
  80205c:	3a 19                	cmp    (%ecx),%bl
  80205e:	75 21                	jne    802081 <strncmp+0x3d>
  802060:	83 e8 01             	sub    $0x1,%eax
  802063:	74 13                	je     802078 <strncmp+0x34>
		n--, p++, q++;
  802065:	83 c2 01             	add    $0x1,%edx
  802068:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80206b:	0f b6 1a             	movzbl (%edx),%ebx
  80206e:	84 db                	test   %bl,%bl
  802070:	74 0f                	je     802081 <strncmp+0x3d>
  802072:	3a 19                	cmp    (%ecx),%bl
  802074:	74 ea                	je     802060 <strncmp+0x1c>
  802076:	eb 09                	jmp    802081 <strncmp+0x3d>
  802078:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80207d:	5b                   	pop    %ebx
  80207e:	5d                   	pop    %ebp
  80207f:	90                   	nop
  802080:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802081:	0f b6 02             	movzbl (%edx),%eax
  802084:	0f b6 11             	movzbl (%ecx),%edx
  802087:	29 d0                	sub    %edx,%eax
  802089:	eb f2                	jmp    80207d <strncmp+0x39>

0080208b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802095:	0f b6 10             	movzbl (%eax),%edx
  802098:	84 d2                	test   %dl,%dl
  80209a:	74 18                	je     8020b4 <strchr+0x29>
		if (*s == c)
  80209c:	38 ca                	cmp    %cl,%dl
  80209e:	75 0a                	jne    8020aa <strchr+0x1f>
  8020a0:	eb 17                	jmp    8020b9 <strchr+0x2e>
  8020a2:	38 ca                	cmp    %cl,%dl
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	74 0f                	je     8020b9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8020aa:	83 c0 01             	add    $0x1,%eax
  8020ad:	0f b6 10             	movzbl (%eax),%edx
  8020b0:	84 d2                	test   %dl,%dl
  8020b2:	75 ee                	jne    8020a2 <strchr+0x17>
  8020b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8020b9:	5d                   	pop    %ebp
  8020ba:	c3                   	ret    

008020bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020c5:	0f b6 10             	movzbl (%eax),%edx
  8020c8:	84 d2                	test   %dl,%dl
  8020ca:	74 18                	je     8020e4 <strfind+0x29>
		if (*s == c)
  8020cc:	38 ca                	cmp    %cl,%dl
  8020ce:	75 0a                	jne    8020da <strfind+0x1f>
  8020d0:	eb 12                	jmp    8020e4 <strfind+0x29>
  8020d2:	38 ca                	cmp    %cl,%dl
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	74 0a                	je     8020e4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8020da:	83 c0 01             	add    $0x1,%eax
  8020dd:	0f b6 10             	movzbl (%eax),%edx
  8020e0:	84 d2                	test   %dl,%dl
  8020e2:	75 ee                	jne    8020d2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8020e4:	5d                   	pop    %ebp
  8020e5:	c3                   	ret    

008020e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	83 ec 0c             	sub    $0xc,%esp
  8020ec:	89 1c 24             	mov    %ebx,(%esp)
  8020ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020f3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8020f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802100:	85 c9                	test   %ecx,%ecx
  802102:	74 30                	je     802134 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802104:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80210a:	75 25                	jne    802131 <memset+0x4b>
  80210c:	f6 c1 03             	test   $0x3,%cl
  80210f:	75 20                	jne    802131 <memset+0x4b>
		c &= 0xFF;
  802111:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802114:	89 d3                	mov    %edx,%ebx
  802116:	c1 e3 08             	shl    $0x8,%ebx
  802119:	89 d6                	mov    %edx,%esi
  80211b:	c1 e6 18             	shl    $0x18,%esi
  80211e:	89 d0                	mov    %edx,%eax
  802120:	c1 e0 10             	shl    $0x10,%eax
  802123:	09 f0                	or     %esi,%eax
  802125:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  802127:	09 d8                	or     %ebx,%eax
  802129:	c1 e9 02             	shr    $0x2,%ecx
  80212c:	fc                   	cld    
  80212d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80212f:	eb 03                	jmp    802134 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802131:	fc                   	cld    
  802132:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802134:	89 f8                	mov    %edi,%eax
  802136:	8b 1c 24             	mov    (%esp),%ebx
  802139:	8b 74 24 04          	mov    0x4(%esp),%esi
  80213d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802141:	89 ec                	mov    %ebp,%esp
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 08             	sub    $0x8,%esp
  80214b:	89 34 24             	mov    %esi,(%esp)
  80214e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802152:	8b 45 08             	mov    0x8(%ebp),%eax
  802155:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  802158:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80215b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80215d:	39 c6                	cmp    %eax,%esi
  80215f:	73 35                	jae    802196 <memmove+0x51>
  802161:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802164:	39 d0                	cmp    %edx,%eax
  802166:	73 2e                	jae    802196 <memmove+0x51>
		s += n;
		d += n;
  802168:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80216a:	f6 c2 03             	test   $0x3,%dl
  80216d:	75 1b                	jne    80218a <memmove+0x45>
  80216f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802175:	75 13                	jne    80218a <memmove+0x45>
  802177:	f6 c1 03             	test   $0x3,%cl
  80217a:	75 0e                	jne    80218a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80217c:	83 ef 04             	sub    $0x4,%edi
  80217f:	8d 72 fc             	lea    -0x4(%edx),%esi
  802182:	c1 e9 02             	shr    $0x2,%ecx
  802185:	fd                   	std    
  802186:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802188:	eb 09                	jmp    802193 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80218a:	83 ef 01             	sub    $0x1,%edi
  80218d:	8d 72 ff             	lea    -0x1(%edx),%esi
  802190:	fd                   	std    
  802191:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802193:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802194:	eb 20                	jmp    8021b6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802196:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80219c:	75 15                	jne    8021b3 <memmove+0x6e>
  80219e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8021a4:	75 0d                	jne    8021b3 <memmove+0x6e>
  8021a6:	f6 c1 03             	test   $0x3,%cl
  8021a9:	75 08                	jne    8021b3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8021ab:	c1 e9 02             	shr    $0x2,%ecx
  8021ae:	fc                   	cld    
  8021af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b1:	eb 03                	jmp    8021b6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021b3:	fc                   	cld    
  8021b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021b6:	8b 34 24             	mov    (%esp),%esi
  8021b9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021bd:	89 ec                	mov    %ebp,%esp
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    

008021c1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8021c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d8:	89 04 24             	mov    %eax,(%esp)
  8021db:	e8 65 ff ff ff       	call   802145 <memmove>
}
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	57                   	push   %edi
  8021e6:	56                   	push   %esi
  8021e7:	53                   	push   %ebx
  8021e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021eb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8021f1:	85 c9                	test   %ecx,%ecx
  8021f3:	74 36                	je     80222b <memcmp+0x49>
		if (*s1 != *s2)
  8021f5:	0f b6 06             	movzbl (%esi),%eax
  8021f8:	0f b6 1f             	movzbl (%edi),%ebx
  8021fb:	38 d8                	cmp    %bl,%al
  8021fd:	74 20                	je     80221f <memcmp+0x3d>
  8021ff:	eb 14                	jmp    802215 <memcmp+0x33>
  802201:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  802206:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80220b:	83 c2 01             	add    $0x1,%edx
  80220e:	83 e9 01             	sub    $0x1,%ecx
  802211:	38 d8                	cmp    %bl,%al
  802213:	74 12                	je     802227 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  802215:	0f b6 c0             	movzbl %al,%eax
  802218:	0f b6 db             	movzbl %bl,%ebx
  80221b:	29 d8                	sub    %ebx,%eax
  80221d:	eb 11                	jmp    802230 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80221f:	83 e9 01             	sub    $0x1,%ecx
  802222:	ba 00 00 00 00       	mov    $0x0,%edx
  802227:	85 c9                	test   %ecx,%ecx
  802229:	75 d6                	jne    802201 <memcmp+0x1f>
  80222b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80223b:	89 c2                	mov    %eax,%edx
  80223d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802240:	39 d0                	cmp    %edx,%eax
  802242:	73 15                	jae    802259 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802244:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  802248:	38 08                	cmp    %cl,(%eax)
  80224a:	75 06                	jne    802252 <memfind+0x1d>
  80224c:	eb 0b                	jmp    802259 <memfind+0x24>
  80224e:	38 08                	cmp    %cl,(%eax)
  802250:	74 07                	je     802259 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802252:	83 c0 01             	add    $0x1,%eax
  802255:	39 c2                	cmp    %eax,%edx
  802257:	77 f5                	ja     80224e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	57                   	push   %edi
  80225f:	56                   	push   %esi
  802260:	53                   	push   %ebx
  802261:	83 ec 04             	sub    $0x4,%esp
  802264:	8b 55 08             	mov    0x8(%ebp),%edx
  802267:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80226a:	0f b6 02             	movzbl (%edx),%eax
  80226d:	3c 20                	cmp    $0x20,%al
  80226f:	74 04                	je     802275 <strtol+0x1a>
  802271:	3c 09                	cmp    $0x9,%al
  802273:	75 0e                	jne    802283 <strtol+0x28>
		s++;
  802275:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802278:	0f b6 02             	movzbl (%edx),%eax
  80227b:	3c 20                	cmp    $0x20,%al
  80227d:	74 f6                	je     802275 <strtol+0x1a>
  80227f:	3c 09                	cmp    $0x9,%al
  802281:	74 f2                	je     802275 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  802283:	3c 2b                	cmp    $0x2b,%al
  802285:	75 0c                	jne    802293 <strtol+0x38>
		s++;
  802287:	83 c2 01             	add    $0x1,%edx
  80228a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802291:	eb 15                	jmp    8022a8 <strtol+0x4d>
	else if (*s == '-')
  802293:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80229a:	3c 2d                	cmp    $0x2d,%al
  80229c:	75 0a                	jne    8022a8 <strtol+0x4d>
		s++, neg = 1;
  80229e:	83 c2 01             	add    $0x1,%edx
  8022a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022a8:	85 db                	test   %ebx,%ebx
  8022aa:	0f 94 c0             	sete   %al
  8022ad:	74 05                	je     8022b4 <strtol+0x59>
  8022af:	83 fb 10             	cmp    $0x10,%ebx
  8022b2:	75 18                	jne    8022cc <strtol+0x71>
  8022b4:	80 3a 30             	cmpb   $0x30,(%edx)
  8022b7:	75 13                	jne    8022cc <strtol+0x71>
  8022b9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi
  8022c0:	75 0a                	jne    8022cc <strtol+0x71>
		s += 2, base = 16;
  8022c2:	83 c2 02             	add    $0x2,%edx
  8022c5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022ca:	eb 15                	jmp    8022e1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022cc:	84 c0                	test   %al,%al
  8022ce:	66 90                	xchg   %ax,%ax
  8022d0:	74 0f                	je     8022e1 <strtol+0x86>
  8022d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8022d7:	80 3a 30             	cmpb   $0x30,(%edx)
  8022da:	75 05                	jne    8022e1 <strtol+0x86>
		s++, base = 8;
  8022dc:	83 c2 01             	add    $0x1,%edx
  8022df:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022e8:	0f b6 0a             	movzbl (%edx),%ecx
  8022eb:	89 cf                	mov    %ecx,%edi
  8022ed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8022f0:	80 fb 09             	cmp    $0x9,%bl
  8022f3:	77 08                	ja     8022fd <strtol+0xa2>
			dig = *s - '0';
  8022f5:	0f be c9             	movsbl %cl,%ecx
  8022f8:	83 e9 30             	sub    $0x30,%ecx
  8022fb:	eb 1e                	jmp    80231b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8022fd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  802300:	80 fb 19             	cmp    $0x19,%bl
  802303:	77 08                	ja     80230d <strtol+0xb2>
			dig = *s - 'a' + 10;
  802305:	0f be c9             	movsbl %cl,%ecx
  802308:	83 e9 57             	sub    $0x57,%ecx
  80230b:	eb 0e                	jmp    80231b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80230d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  802310:	80 fb 19             	cmp    $0x19,%bl
  802313:	77 15                	ja     80232a <strtol+0xcf>
			dig = *s - 'A' + 10;
  802315:	0f be c9             	movsbl %cl,%ecx
  802318:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80231b:	39 f1                	cmp    %esi,%ecx
  80231d:	7d 0b                	jge    80232a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80231f:	83 c2 01             	add    $0x1,%edx
  802322:	0f af c6             	imul   %esi,%eax
  802325:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  802328:	eb be                	jmp    8022e8 <strtol+0x8d>
  80232a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80232c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802330:	74 05                	je     802337 <strtol+0xdc>
		*endptr = (char *) s;
  802332:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802335:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802337:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80233b:	74 04                	je     802341 <strtol+0xe6>
  80233d:	89 c8                	mov    %ecx,%eax
  80233f:	f7 d8                	neg    %eax
}
  802341:	83 c4 04             	add    $0x4,%esp
  802344:	5b                   	pop    %ebx
  802345:	5e                   	pop    %esi
  802346:	5f                   	pop    %edi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    
  802349:	00 00                	add    %al,(%eax)
  80234b:	00 00                	add    %al,(%eax)
  80234d:	00 00                	add    %al,(%eax)
	...

00802350 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
  802353:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802356:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80235c:	b8 01 00 00 00       	mov    $0x1,%eax
  802361:	39 ca                	cmp    %ecx,%edx
  802363:	75 04                	jne    802369 <ipc_find_env+0x19>
  802365:	b0 00                	mov    $0x0,%al
  802367:	eb 12                	jmp    80237b <ipc_find_env+0x2b>
  802369:	89 c2                	mov    %eax,%edx
  80236b:	c1 e2 07             	shl    $0x7,%edx
  80236e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802375:	8b 12                	mov    (%edx),%edx
  802377:	39 ca                	cmp    %ecx,%edx
  802379:	75 10                	jne    80238b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80237b:	89 c2                	mov    %eax,%edx
  80237d:	c1 e2 07             	shl    $0x7,%edx
  802380:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802387:	8b 00                	mov    (%eax),%eax
  802389:	eb 0e                	jmp    802399 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80238b:	83 c0 01             	add    $0x1,%eax
  80238e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802393:	75 d4                	jne    802369 <ipc_find_env+0x19>
  802395:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802399:	5d                   	pop    %ebp
  80239a:	c3                   	ret    

0080239b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80239b:	55                   	push   %ebp
  80239c:	89 e5                	mov    %esp,%ebp
  80239e:	57                   	push   %edi
  80239f:	56                   	push   %esi
  8023a0:	53                   	push   %ebx
  8023a1:	83 ec 1c             	sub    $0x1c,%esp
  8023a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8023a7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  8023ad:	85 db                	test   %ebx,%ebx
  8023af:	74 19                	je     8023ca <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8023b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8023b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023c0:	89 34 24             	mov    %esi,(%esp)
  8023c3:	e8 d5 df ff ff       	call   80039d <sys_ipc_try_send>
  8023c8:	eb 1b                	jmp    8023e5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8023ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8023cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8023d8:	ee 
  8023d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023dd:	89 34 24             	mov    %esi,(%esp)
  8023e0:	e8 b8 df ff ff       	call   80039d <sys_ipc_try_send>
           if(ret == 0)
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	74 28                	je     802411 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8023e9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023ec:	74 1c                	je     80240a <ipc_send+0x6f>
              panic("ipc send error");
  8023ee:	c7 44 24 08 00 2c 80 	movl   $0x802c00,0x8(%esp)
  8023f5:	00 
  8023f6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8023fd:	00 
  8023fe:	c7 04 24 0f 2c 80 00 	movl   $0x802c0f,(%esp)
  802405:	e8 6a f1 ff ff       	call   801574 <_panic>
           sys_yield();
  80240a:	e8 5a e2 ff ff       	call   800669 <sys_yield>
        }
  80240f:	eb 9c                	jmp    8023ad <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802411:	83 c4 1c             	add    $0x1c,%esp
  802414:	5b                   	pop    %ebx
  802415:	5e                   	pop    %esi
  802416:	5f                   	pop    %edi
  802417:	5d                   	pop    %ebp
  802418:	c3                   	ret    

00802419 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802419:	55                   	push   %ebp
  80241a:	89 e5                	mov    %esp,%ebp
  80241c:	56                   	push   %esi
  80241d:	53                   	push   %ebx
  80241e:	83 ec 10             	sub    $0x10,%esp
  802421:	8b 75 08             	mov    0x8(%ebp),%esi
  802424:	8b 45 0c             	mov    0xc(%ebp),%eax
  802427:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80242a:	85 c0                	test   %eax,%eax
  80242c:	75 0e                	jne    80243c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80242e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802435:	e8 f8 de ff ff       	call   800332 <sys_ipc_recv>
  80243a:	eb 08                	jmp    802444 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80243c:	89 04 24             	mov    %eax,(%esp)
  80243f:	e8 ee de ff ff       	call   800332 <sys_ipc_recv>
        if(ret == 0){
  802444:	85 c0                	test   %eax,%eax
  802446:	75 26                	jne    80246e <ipc_recv+0x55>
           if(from_env_store)
  802448:	85 f6                	test   %esi,%esi
  80244a:	74 0a                	je     802456 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80244c:	a1 08 40 80 00       	mov    0x804008,%eax
  802451:	8b 40 78             	mov    0x78(%eax),%eax
  802454:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802456:	85 db                	test   %ebx,%ebx
  802458:	74 0a                	je     802464 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80245a:	a1 08 40 80 00       	mov    0x804008,%eax
  80245f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802462:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802464:	a1 08 40 80 00       	mov    0x804008,%eax
  802469:	8b 40 74             	mov    0x74(%eax),%eax
  80246c:	eb 14                	jmp    802482 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80246e:	85 f6                	test   %esi,%esi
  802470:	74 06                	je     802478 <ipc_recv+0x5f>
              *from_env_store = 0;
  802472:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802478:	85 db                	test   %ebx,%ebx
  80247a:	74 06                	je     802482 <ipc_recv+0x69>
              *perm_store = 0;
  80247c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802482:	83 c4 10             	add    $0x10,%esp
  802485:	5b                   	pop    %ebx
  802486:	5e                   	pop    %esi
  802487:	5d                   	pop    %ebp
  802488:	c3                   	ret    
  802489:	00 00                	add    %al,(%eax)
	...

0080248c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80248c:	55                   	push   %ebp
  80248d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80248f:	8b 45 08             	mov    0x8(%ebp),%eax
  802492:	89 c2                	mov    %eax,%edx
  802494:	c1 ea 16             	shr    $0x16,%edx
  802497:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80249e:	f6 c2 01             	test   $0x1,%dl
  8024a1:	74 20                	je     8024c3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8024a3:	c1 e8 0c             	shr    $0xc,%eax
  8024a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024ad:	a8 01                	test   $0x1,%al
  8024af:	74 12                	je     8024c3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024b1:	c1 e8 0c             	shr    $0xc,%eax
  8024b4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8024b9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8024be:	0f b7 c0             	movzwl %ax,%eax
  8024c1:	eb 05                	jmp    8024c8 <pageref+0x3c>
  8024c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024c8:	5d                   	pop    %ebp
  8024c9:	c3                   	ret    
  8024ca:	00 00                	add    %al,(%eax)
  8024cc:	00 00                	add    %al,(%eax)
	...

008024d0 <__udivdi3>:
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	57                   	push   %edi
  8024d4:	56                   	push   %esi
  8024d5:	83 ec 10             	sub    $0x10,%esp
  8024d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8024db:	8b 55 08             	mov    0x8(%ebp),%edx
  8024de:	8b 75 10             	mov    0x10(%ebp),%esi
  8024e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024e4:	85 c0                	test   %eax,%eax
  8024e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8024e9:	75 35                	jne    802520 <__udivdi3+0x50>
  8024eb:	39 fe                	cmp    %edi,%esi
  8024ed:	77 61                	ja     802550 <__udivdi3+0x80>
  8024ef:	85 f6                	test   %esi,%esi
  8024f1:	75 0b                	jne    8024fe <__udivdi3+0x2e>
  8024f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	f7 f6                	div    %esi
  8024fc:	89 c6                	mov    %eax,%esi
  8024fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802501:	31 d2                	xor    %edx,%edx
  802503:	89 f8                	mov    %edi,%eax
  802505:	f7 f6                	div    %esi
  802507:	89 c7                	mov    %eax,%edi
  802509:	89 c8                	mov    %ecx,%eax
  80250b:	f7 f6                	div    %esi
  80250d:	89 c1                	mov    %eax,%ecx
  80250f:	89 fa                	mov    %edi,%edx
  802511:	89 c8                	mov    %ecx,%eax
  802513:	83 c4 10             	add    $0x10,%esp
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    
  80251a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802520:	39 f8                	cmp    %edi,%eax
  802522:	77 1c                	ja     802540 <__udivdi3+0x70>
  802524:	0f bd d0             	bsr    %eax,%edx
  802527:	83 f2 1f             	xor    $0x1f,%edx
  80252a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80252d:	75 39                	jne    802568 <__udivdi3+0x98>
  80252f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802532:	0f 86 a0 00 00 00    	jbe    8025d8 <__udivdi3+0x108>
  802538:	39 f8                	cmp    %edi,%eax
  80253a:	0f 82 98 00 00 00    	jb     8025d8 <__udivdi3+0x108>
  802540:	31 ff                	xor    %edi,%edi
  802542:	31 c9                	xor    %ecx,%ecx
  802544:	89 c8                	mov    %ecx,%eax
  802546:	89 fa                	mov    %edi,%edx
  802548:	83 c4 10             	add    $0x10,%esp
  80254b:	5e                   	pop    %esi
  80254c:	5f                   	pop    %edi
  80254d:	5d                   	pop    %ebp
  80254e:	c3                   	ret    
  80254f:	90                   	nop
  802550:	89 d1                	mov    %edx,%ecx
  802552:	89 fa                	mov    %edi,%edx
  802554:	89 c8                	mov    %ecx,%eax
  802556:	31 ff                	xor    %edi,%edi
  802558:	f7 f6                	div    %esi
  80255a:	89 c1                	mov    %eax,%ecx
  80255c:	89 fa                	mov    %edi,%edx
  80255e:	89 c8                	mov    %ecx,%eax
  802560:	83 c4 10             	add    $0x10,%esp
  802563:	5e                   	pop    %esi
  802564:	5f                   	pop    %edi
  802565:	5d                   	pop    %ebp
  802566:	c3                   	ret    
  802567:	90                   	nop
  802568:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80256c:	89 f2                	mov    %esi,%edx
  80256e:	d3 e0                	shl    %cl,%eax
  802570:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802573:	b8 20 00 00 00       	mov    $0x20,%eax
  802578:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80257b:	89 c1                	mov    %eax,%ecx
  80257d:	d3 ea                	shr    %cl,%edx
  80257f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802583:	0b 55 ec             	or     -0x14(%ebp),%edx
  802586:	d3 e6                	shl    %cl,%esi
  802588:	89 c1                	mov    %eax,%ecx
  80258a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80258d:	89 fe                	mov    %edi,%esi
  80258f:	d3 ee                	shr    %cl,%esi
  802591:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802595:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802598:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80259b:	d3 e7                	shl    %cl,%edi
  80259d:	89 c1                	mov    %eax,%ecx
  80259f:	d3 ea                	shr    %cl,%edx
  8025a1:	09 d7                	or     %edx,%edi
  8025a3:	89 f2                	mov    %esi,%edx
  8025a5:	89 f8                	mov    %edi,%eax
  8025a7:	f7 75 ec             	divl   -0x14(%ebp)
  8025aa:	89 d6                	mov    %edx,%esi
  8025ac:	89 c7                	mov    %eax,%edi
  8025ae:	f7 65 e8             	mull   -0x18(%ebp)
  8025b1:	39 d6                	cmp    %edx,%esi
  8025b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025b6:	72 30                	jb     8025e8 <__udivdi3+0x118>
  8025b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025bf:	d3 e2                	shl    %cl,%edx
  8025c1:	39 c2                	cmp    %eax,%edx
  8025c3:	73 05                	jae    8025ca <__udivdi3+0xfa>
  8025c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8025c8:	74 1e                	je     8025e8 <__udivdi3+0x118>
  8025ca:	89 f9                	mov    %edi,%ecx
  8025cc:	31 ff                	xor    %edi,%edi
  8025ce:	e9 71 ff ff ff       	jmp    802544 <__udivdi3+0x74>
  8025d3:	90                   	nop
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	31 ff                	xor    %edi,%edi
  8025da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8025df:	e9 60 ff ff ff       	jmp    802544 <__udivdi3+0x74>
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8025eb:	31 ff                	xor    %edi,%edi
  8025ed:	89 c8                	mov    %ecx,%eax
  8025ef:	89 fa                	mov    %edi,%edx
  8025f1:	83 c4 10             	add    $0x10,%esp
  8025f4:	5e                   	pop    %esi
  8025f5:	5f                   	pop    %edi
  8025f6:	5d                   	pop    %ebp
  8025f7:	c3                   	ret    
	...

00802600 <__umoddi3>:
  802600:	55                   	push   %ebp
  802601:	89 e5                	mov    %esp,%ebp
  802603:	57                   	push   %edi
  802604:	56                   	push   %esi
  802605:	83 ec 20             	sub    $0x20,%esp
  802608:	8b 55 14             	mov    0x14(%ebp),%edx
  80260b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80260e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802611:	8b 75 0c             	mov    0xc(%ebp),%esi
  802614:	85 d2                	test   %edx,%edx
  802616:	89 c8                	mov    %ecx,%eax
  802618:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80261b:	75 13                	jne    802630 <__umoddi3+0x30>
  80261d:	39 f7                	cmp    %esi,%edi
  80261f:	76 3f                	jbe    802660 <__umoddi3+0x60>
  802621:	89 f2                	mov    %esi,%edx
  802623:	f7 f7                	div    %edi
  802625:	89 d0                	mov    %edx,%eax
  802627:	31 d2                	xor    %edx,%edx
  802629:	83 c4 20             	add    $0x20,%esp
  80262c:	5e                   	pop    %esi
  80262d:	5f                   	pop    %edi
  80262e:	5d                   	pop    %ebp
  80262f:	c3                   	ret    
  802630:	39 f2                	cmp    %esi,%edx
  802632:	77 4c                	ja     802680 <__umoddi3+0x80>
  802634:	0f bd ca             	bsr    %edx,%ecx
  802637:	83 f1 1f             	xor    $0x1f,%ecx
  80263a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80263d:	75 51                	jne    802690 <__umoddi3+0x90>
  80263f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802642:	0f 87 e0 00 00 00    	ja     802728 <__umoddi3+0x128>
  802648:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264b:	29 f8                	sub    %edi,%eax
  80264d:	19 d6                	sbb    %edx,%esi
  80264f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802652:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802655:	89 f2                	mov    %esi,%edx
  802657:	83 c4 20             	add    $0x20,%esp
  80265a:	5e                   	pop    %esi
  80265b:	5f                   	pop    %edi
  80265c:	5d                   	pop    %ebp
  80265d:	c3                   	ret    
  80265e:	66 90                	xchg   %ax,%ax
  802660:	85 ff                	test   %edi,%edi
  802662:	75 0b                	jne    80266f <__umoddi3+0x6f>
  802664:	b8 01 00 00 00       	mov    $0x1,%eax
  802669:	31 d2                	xor    %edx,%edx
  80266b:	f7 f7                	div    %edi
  80266d:	89 c7                	mov    %eax,%edi
  80266f:	89 f0                	mov    %esi,%eax
  802671:	31 d2                	xor    %edx,%edx
  802673:	f7 f7                	div    %edi
  802675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802678:	f7 f7                	div    %edi
  80267a:	eb a9                	jmp    802625 <__umoddi3+0x25>
  80267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	83 c4 20             	add    $0x20,%esp
  802687:	5e                   	pop    %esi
  802688:	5f                   	pop    %edi
  802689:	5d                   	pop    %ebp
  80268a:	c3                   	ret    
  80268b:	90                   	nop
  80268c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802690:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802694:	d3 e2                	shl    %cl,%edx
  802696:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802699:	ba 20 00 00 00       	mov    $0x20,%edx
  80269e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8026a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026a8:	89 fa                	mov    %edi,%edx
  8026aa:	d3 ea                	shr    %cl,%edx
  8026ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8026b3:	d3 e7                	shl    %cl,%edi
  8026b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026bc:	89 f2                	mov    %esi,%edx
  8026be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8026c1:	89 c7                	mov    %eax,%edi
  8026c3:	d3 ea                	shr    %cl,%edx
  8026c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026cc:	89 c2                	mov    %eax,%edx
  8026ce:	d3 e6                	shl    %cl,%esi
  8026d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026d4:	d3 ea                	shr    %cl,%edx
  8026d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026da:	09 d6                	or     %edx,%esi
  8026dc:	89 f0                	mov    %esi,%eax
  8026de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8026e1:	d3 e7                	shl    %cl,%edi
  8026e3:	89 f2                	mov    %esi,%edx
  8026e5:	f7 75 f4             	divl   -0xc(%ebp)
  8026e8:	89 d6                	mov    %edx,%esi
  8026ea:	f7 65 e8             	mull   -0x18(%ebp)
  8026ed:	39 d6                	cmp    %edx,%esi
  8026ef:	72 2b                	jb     80271c <__umoddi3+0x11c>
  8026f1:	39 c7                	cmp    %eax,%edi
  8026f3:	72 23                	jb     802718 <__umoddi3+0x118>
  8026f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026f9:	29 c7                	sub    %eax,%edi
  8026fb:	19 d6                	sbb    %edx,%esi
  8026fd:	89 f0                	mov    %esi,%eax
  8026ff:	89 f2                	mov    %esi,%edx
  802701:	d3 ef                	shr    %cl,%edi
  802703:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802707:	d3 e0                	shl    %cl,%eax
  802709:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80270d:	09 f8                	or     %edi,%eax
  80270f:	d3 ea                	shr    %cl,%edx
  802711:	83 c4 20             	add    $0x20,%esp
  802714:	5e                   	pop    %esi
  802715:	5f                   	pop    %edi
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    
  802718:	39 d6                	cmp    %edx,%esi
  80271a:	75 d9                	jne    8026f5 <__umoddi3+0xf5>
  80271c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80271f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802722:	eb d1                	jmp    8026f5 <__umoddi3+0xf5>
  802724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	0f 82 18 ff ff ff    	jb     802648 <__umoddi3+0x48>
  802730:	e9 1d ff ff ff       	jmp    802652 <__umoddi3+0x52>
