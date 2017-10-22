
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80004d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800050:	8b 75 08             	mov    0x8(%ebp),%esi
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800056:	e8 84 06 00 00       	call   8006df <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	89 c2                	mov    %eax,%edx
  800062:	c1 e2 07             	shl    $0x7,%edx
  800065:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80006c:	a3 08 40 80 00       	mov    %eax,0x804008
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 07                	jle    80007c <libmain+0x38>
		binaryname = argv[0];
  800075:	8b 03                	mov    (%ebx),%eax
  800077:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	89 34 24             	mov    %esi,(%esp)
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 0b 00 00 00       	call   800098 <exit>
}
  80008d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800090:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800093:	89 ec                	mov    %ebp,%esp
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009e:	e8 c8 0b 00 00       	call   800c6b <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 70 06 00 00       	call   80071f <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    
  8000b1:	00 00                	add    %al,(%eax)
	...

008000b4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	89 1c 24             	mov    %ebx,(%esp)
  8000bd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cb:	89 d1                	mov    %edx,%ecx
  8000cd:	89 d3                	mov    %edx,%ebx
  8000cf:	89 d7                	mov    %edx,%edi
  8000d1:	51                   	push   %ecx
  8000d2:	52                   	push   %edx
  8000d3:	53                   	push   %ebx
  8000d4:	54                   	push   %esp
  8000d5:	55                   	push   %ebp
  8000d6:	56                   	push   %esi
  8000d7:	57                   	push   %edi
  8000d8:	54                   	push   %esp
  8000d9:	5d                   	pop    %ebp
  8000da:	8d 35 e2 00 80 00    	lea    0x8000e2,%esi
  8000e0:	0f 34                	sysenter 
  8000e2:	5f                   	pop    %edi
  8000e3:	5e                   	pop    %esi
  8000e4:	5d                   	pop    %ebp
  8000e5:	5c                   	pop    %esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5a                   	pop    %edx
  8000e8:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e9:	8b 1c 24             	mov    (%esp),%ebx
  8000ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000f0:	89 ec                	mov    %ebp,%esp
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	89 1c 24             	mov    %ebx,(%esp)
  8000fd:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800101:	b8 00 00 00 00       	mov    $0x0,%eax
  800106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800109:	8b 55 08             	mov    0x8(%ebp),%edx
  80010c:	89 c3                	mov    %eax,%ebx
  80010e:	89 c7                	mov    %eax,%edi
  800110:	51                   	push   %ecx
  800111:	52                   	push   %edx
  800112:	53                   	push   %ebx
  800113:	54                   	push   %esp
  800114:	55                   	push   %ebp
  800115:	56                   	push   %esi
  800116:	57                   	push   %edi
  800117:	54                   	push   %esp
  800118:	5d                   	pop    %ebp
  800119:	8d 35 21 01 80 00    	lea    0x800121,%esi
  80011f:	0f 34                	sysenter 
  800121:	5f                   	pop    %edi
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	5c                   	pop    %esp
  800125:	5b                   	pop    %ebx
  800126:	5a                   	pop    %edx
  800127:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800128:	8b 1c 24             	mov    (%esp),%ebx
  80012b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_get_mac>:
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_get_mac(uint8_t* macaddr){
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	89 1c 24             	mov    %ebx,(%esp)
  80013c:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800140:	b9 00 00 00 00       	mov    $0x0,%ecx
  800145:	b8 13 00 00 00       	mov    $0x13,%eax
  80014a:	8b 55 08             	mov    0x8(%ebp),%edx
  80014d:	89 cb                	mov    %ecx,%ebx
  80014f:	89 cf                	mov    %ecx,%edi
  800151:	51                   	push   %ecx
  800152:	52                   	push   %edx
  800153:	53                   	push   %ebx
  800154:	54                   	push   %esp
  800155:	55                   	push   %ebp
  800156:	56                   	push   %esi
  800157:	57                   	push   %edi
  800158:	54                   	push   %esp
  800159:	5d                   	pop    %ebp
  80015a:	8d 35 62 01 80 00    	lea    0x800162,%esi
  800160:	0f 34                	sysenter 
  800162:	5f                   	pop    %edi
  800163:	5e                   	pop    %esi
  800164:	5d                   	pop    %ebp
  800165:	5c                   	pop    %esp
  800166:	5b                   	pop    %ebx
  800167:	5a                   	pop    %edx
  800168:	59                   	pop    %ecx
}

int 
sys_get_mac(uint8_t* macaddr){
         return syscall(SYS_get_mac,0,(uint32_t)macaddr,0,0,0,0);
}
  800169:	8b 1c 24             	mov    (%esp),%ebx
  80016c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_receive_packet>:
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}

int 
sys_receive_packet(uint32_t addr,int* len){
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 08             	sub    $0x8,%esp
  80017a:	89 1c 24             	mov    %ebx,(%esp)
  80017d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	b8 12 00 00 00       	mov    $0x12,%eax
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	89 df                	mov    %ebx,%edi
  800193:	51                   	push   %ecx
  800194:	52                   	push   %edx
  800195:	53                   	push   %ebx
  800196:	54                   	push   %esp
  800197:	55                   	push   %ebp
  800198:	56                   	push   %esi
  800199:	57                   	push   %edi
  80019a:	54                   	push   %esp
  80019b:	5d                   	pop    %ebp
  80019c:	8d 35 a4 01 80 00    	lea    0x8001a4,%esi
  8001a2:	0f 34                	sysenter 
  8001a4:	5f                   	pop    %edi
  8001a5:	5e                   	pop    %esi
  8001a6:	5d                   	pop    %ebp
  8001a7:	5c                   	pop    %esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5a                   	pop    %edx
  8001aa:	59                   	pop    %ecx
}

int 
sys_receive_packet(uint32_t addr,int* len){
         return syscall(SYS_receive_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8001ab:	8b 1c 24             	mov    (%esp),%ebx
  8001ae:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001b2:	89 ec                	mov    %ebp,%esp
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <sys_transmit_packet>:
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}

int 
sys_transmit_packet(uint32_t addr,int len){
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	89 1c 24             	mov    %ebx,(%esp)
  8001bf:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c8:	b8 11 00 00 00       	mov    $0x11,%eax
  8001cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	89 df                	mov    %ebx,%edi
  8001d5:	51                   	push   %ecx
  8001d6:	52                   	push   %edx
  8001d7:	53                   	push   %ebx
  8001d8:	54                   	push   %esp
  8001d9:	55                   	push   %ebp
  8001da:	56                   	push   %esi
  8001db:	57                   	push   %edi
  8001dc:	54                   	push   %esp
  8001dd:	5d                   	pop    %ebp
  8001de:	8d 35 e6 01 80 00    	lea    0x8001e6,%esi
  8001e4:	0f 34                	sysenter 
  8001e6:	5f                   	pop    %edi
  8001e7:	5e                   	pop    %esi
  8001e8:	5d                   	pop    %ebp
  8001e9:	5c                   	pop    %esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5a                   	pop    %edx
  8001ec:	59                   	pop    %ecx
}

int 
sys_transmit_packet(uint32_t addr,int len){
         return syscall(SYS_transmit_packet,0,(uint32_t)addr,(uint32_t)len,0,0,0);
}
  8001ed:	8b 1c 24             	mov    (%esp),%ebx
  8001f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001f4:	89 ec                	mov    %ebp,%esp
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	89 1c 24             	mov    %ebx,(%esp)
  800201:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800205:	b8 10 00 00 00       	mov    $0x10,%eax
  80020a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80020d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800213:	8b 55 08             	mov    0x8(%ebp),%edx
  800216:	51                   	push   %ecx
  800217:	52                   	push   %edx
  800218:	53                   	push   %ebx
  800219:	54                   	push   %esp
  80021a:	55                   	push   %ebp
  80021b:	56                   	push   %esi
  80021c:	57                   	push   %edi
  80021d:	54                   	push   %esp
  80021e:	5d                   	pop    %ebp
  80021f:	8d 35 27 02 80 00    	lea    0x800227,%esi
  800225:	0f 34                	sysenter 
  800227:	5f                   	pop    %edi
  800228:	5e                   	pop    %esi
  800229:	5d                   	pop    %ebp
  80022a:	5c                   	pop    %esp
  80022b:	5b                   	pop    %ebx
  80022c:	5a                   	pop    %edx
  80022d:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  80022e:	8b 1c 24             	mov    (%esp),%ebx
  800231:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800235:	89 ec                	mov    %ebp,%esp
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sys_env_set_prior>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 28             	sub    $0x28,%esp
  80023f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800242:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80024f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	89 df                	mov    %ebx,%edi
  800257:	51                   	push   %ecx
  800258:	52                   	push   %edx
  800259:	53                   	push   %ebx
  80025a:	54                   	push   %esp
  80025b:	55                   	push   %ebp
  80025c:	56                   	push   %esi
  80025d:	57                   	push   %edi
  80025e:	54                   	push   %esp
  80025f:	5d                   	pop    %ebp
  800260:	8d 35 68 02 80 00    	lea    0x800268,%esi
  800266:	0f 34                	sysenter 
  800268:	5f                   	pop    %edi
  800269:	5e                   	pop    %esi
  80026a:	5d                   	pop    %ebp
  80026b:	5c                   	pop    %esp
  80026c:	5b                   	pop    %ebx
  80026d:	5a                   	pop    %edx
  80026e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80026f:	85 c0                	test   %eax,%eax
  800271:	7e 28                	jle    80029b <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	89 44 24 10          	mov    %eax,0x10(%esp)
  800277:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  80027e:	00 
  80027f:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  800286:	00 
  800287:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80028e:	00 
  80028f:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  800296:	e8 c9 12 00 00       	call   801564 <_panic>


int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  80029b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80029e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002a1:	89 ec                	mov    %ebp,%esp
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_time_msec>:
}


unsigned int
sys_time_msec(void)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	89 1c 24             	mov    %ebx,(%esp)
  8002ae:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	b8 15 00 00 00       	mov    $0x15,%eax
  8002bc:	89 d1                	mov    %edx,%ecx
  8002be:	89 d3                	mov    %edx,%ebx
  8002c0:	89 d7                	mov    %edx,%edi
  8002c2:	51                   	push   %ecx
  8002c3:	52                   	push   %edx
  8002c4:	53                   	push   %ebx
  8002c5:	54                   	push   %esp
  8002c6:	55                   	push   %ebp
  8002c7:	56                   	push   %esi
  8002c8:	57                   	push   %edi
  8002c9:	54                   	push   %esp
  8002ca:	5d                   	pop    %ebp
  8002cb:	8d 35 d3 02 80 00    	lea    0x8002d3,%esi
  8002d1:	0f 34                	sysenter 
  8002d3:	5f                   	pop    %edi
  8002d4:	5e                   	pop    %esi
  8002d5:	5d                   	pop    %ebp
  8002d6:	5c                   	pop    %esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5a                   	pop    %edx
  8002d9:	59                   	pop    %ecx

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002da:	8b 1c 24             	mov    (%esp),%ebx
  8002dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002e1:	89 ec                	mov    %ebp,%esp
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	89 1c 24             	mov    %ebx,(%esp)
  8002ee:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f7:	b8 14 00 00 00       	mov    $0x14,%eax
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	89 cb                	mov    %ecx,%ebx
  800301:	89 cf                	mov    %ecx,%edi
  800303:	51                   	push   %ecx
  800304:	52                   	push   %edx
  800305:	53                   	push   %ebx
  800306:	54                   	push   %esp
  800307:	55                   	push   %ebp
  800308:	56                   	push   %esi
  800309:	57                   	push   %edi
  80030a:	54                   	push   %esp
  80030b:	5d                   	pop    %ebp
  80030c:	8d 35 14 03 80 00    	lea    0x800314,%esi
  800312:	0f 34                	sysenter 
  800314:	5f                   	pop    %edi
  800315:	5e                   	pop    %esi
  800316:	5d                   	pop    %ebp
  800317:	5c                   	pop    %esp
  800318:	5b                   	pop    %ebx
  800319:	5a                   	pop    %edx
  80031a:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80031b:	8b 1c 24             	mov    (%esp),%ebx
  80031e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800322:	89 ec                	mov    %ebp,%esp
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	83 ec 28             	sub    $0x28,%esp
  80032c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80032f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
  800337:	b8 0e 00 00 00       	mov    $0xe,%eax
  80033c:	8b 55 08             	mov    0x8(%ebp),%edx
  80033f:	89 cb                	mov    %ecx,%ebx
  800341:	89 cf                	mov    %ecx,%edi
  800343:	51                   	push   %ecx
  800344:	52                   	push   %edx
  800345:	53                   	push   %ebx
  800346:	54                   	push   %esp
  800347:	55                   	push   %ebp
  800348:	56                   	push   %esi
  800349:	57                   	push   %edi
  80034a:	54                   	push   %esp
  80034b:	5d                   	pop    %ebp
  80034c:	8d 35 54 03 80 00    	lea    0x800354,%esi
  800352:	0f 34                	sysenter 
  800354:	5f                   	pop    %edi
  800355:	5e                   	pop    %esi
  800356:	5d                   	pop    %ebp
  800357:	5c                   	pop    %esp
  800358:	5b                   	pop    %ebx
  800359:	5a                   	pop    %edx
  80035a:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80035b:	85 c0                	test   %eax,%eax
  80035d:	7e 28                	jle    800387 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800363:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80036a:	00 
  80036b:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  800372:	00 
  800373:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80037a:	00 
  80037b:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  800382:	e8 dd 11 00 00       	call   801564 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800387:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80038a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80038d:	89 ec                	mov    %ebp,%esp
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 08             	sub    $0x8,%esp
  800397:	89 1c 24             	mov    %ebx,(%esp)
  80039a:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80039e:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8003af:	51                   	push   %ecx
  8003b0:	52                   	push   %edx
  8003b1:	53                   	push   %ebx
  8003b2:	54                   	push   %esp
  8003b3:	55                   	push   %ebp
  8003b4:	56                   	push   %esi
  8003b5:	57                   	push   %edi
  8003b6:	54                   	push   %esp
  8003b7:	5d                   	pop    %ebp
  8003b8:	8d 35 c0 03 80 00    	lea    0x8003c0,%esi
  8003be:	0f 34                	sysenter 
  8003c0:	5f                   	pop    %edi
  8003c1:	5e                   	pop    %esi
  8003c2:	5d                   	pop    %ebp
  8003c3:	5c                   	pop    %esp
  8003c4:	5b                   	pop    %ebx
  8003c5:	5a                   	pop    %edx
  8003c6:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003c7:	8b 1c 24             	mov    (%esp),%ebx
  8003ca:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003ce:	89 ec                	mov    %ebp,%esp
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	83 ec 28             	sub    $0x28,%esp
  8003d8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003db:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ee:	89 df                	mov    %ebx,%edi
  8003f0:	51                   	push   %ecx
  8003f1:	52                   	push   %edx
  8003f2:	53                   	push   %ebx
  8003f3:	54                   	push   %esp
  8003f4:	55                   	push   %ebp
  8003f5:	56                   	push   %esi
  8003f6:	57                   	push   %edi
  8003f7:	54                   	push   %esp
  8003f8:	5d                   	pop    %ebp
  8003f9:	8d 35 01 04 80 00    	lea    0x800401,%esi
  8003ff:	0f 34                	sysenter 
  800401:	5f                   	pop    %edi
  800402:	5e                   	pop    %esi
  800403:	5d                   	pop    %ebp
  800404:	5c                   	pop    %esp
  800405:	5b                   	pop    %ebx
  800406:	5a                   	pop    %edx
  800407:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800408:	85 c0                	test   %eax,%eax
  80040a:	7e 28                	jle    800434 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800410:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  800417:	00 
  800418:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  80041f:	00 
  800420:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80042f:	e8 30 11 00 00       	call   801564 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800434:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800437:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80043a:	89 ec                	mov    %ebp,%esp
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 28             	sub    $0x28,%esp
  800444:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800447:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80044a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800454:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800457:	8b 55 08             	mov    0x8(%ebp),%edx
  80045a:	89 df                	mov    %ebx,%edi
  80045c:	51                   	push   %ecx
  80045d:	52                   	push   %edx
  80045e:	53                   	push   %ebx
  80045f:	54                   	push   %esp
  800460:	55                   	push   %ebp
  800461:	56                   	push   %esi
  800462:	57                   	push   %edi
  800463:	54                   	push   %esp
  800464:	5d                   	pop    %ebp
  800465:	8d 35 6d 04 80 00    	lea    0x80046d,%esi
  80046b:	0f 34                	sysenter 
  80046d:	5f                   	pop    %edi
  80046e:	5e                   	pop    %esi
  80046f:	5d                   	pop    %ebp
  800470:	5c                   	pop    %esp
  800471:	5b                   	pop    %ebx
  800472:	5a                   	pop    %edx
  800473:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800474:	85 c0                	test   %eax,%eax
  800476:	7e 28                	jle    8004a0 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800478:	89 44 24 10          	mov    %eax,0x10(%esp)
  80047c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800483:	00 
  800484:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  80048b:	00 
  80048c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800493:	00 
  800494:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80049b:	e8 c4 10 00 00       	call   801564 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8004a0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004a3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004a6:	89 ec                	mov    %ebp,%esp
  8004a8:	5d                   	pop    %ebp
  8004a9:	c3                   	ret    

008004aa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	83 ec 28             	sub    $0x28,%esp
  8004b0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004b3:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004bb:	b8 09 00 00 00       	mov    $0x9,%eax
  8004c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c6:	89 df                	mov    %ebx,%edi
  8004c8:	51                   	push   %ecx
  8004c9:	52                   	push   %edx
  8004ca:	53                   	push   %ebx
  8004cb:	54                   	push   %esp
  8004cc:	55                   	push   %ebp
  8004cd:	56                   	push   %esi
  8004ce:	57                   	push   %edi
  8004cf:	54                   	push   %esp
  8004d0:	5d                   	pop    %ebp
  8004d1:	8d 35 d9 04 80 00    	lea    0x8004d9,%esi
  8004d7:	0f 34                	sysenter 
  8004d9:	5f                   	pop    %edi
  8004da:	5e                   	pop    %esi
  8004db:	5d                   	pop    %ebp
  8004dc:	5c                   	pop    %esp
  8004dd:	5b                   	pop    %ebx
  8004de:	5a                   	pop    %edx
  8004df:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	7e 28                	jle    80050c <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004e8:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  8004f7:	00 
  8004f8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004ff:	00 
  800500:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  800507:	e8 58 10 00 00       	call   801564 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80050c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80050f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800512:	89 ec                	mov    %ebp,%esp
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 28             	sub    $0x28,%esp
  80051c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80051f:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800522:	bb 00 00 00 00       	mov    $0x0,%ebx
  800527:	b8 07 00 00 00       	mov    $0x7,%eax
  80052c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80052f:	8b 55 08             	mov    0x8(%ebp),%edx
  800532:	89 df                	mov    %ebx,%edi
  800534:	51                   	push   %ecx
  800535:	52                   	push   %edx
  800536:	53                   	push   %ebx
  800537:	54                   	push   %esp
  800538:	55                   	push   %ebp
  800539:	56                   	push   %esi
  80053a:	57                   	push   %edi
  80053b:	54                   	push   %esp
  80053c:	5d                   	pop    %ebp
  80053d:	8d 35 45 05 80 00    	lea    0x800545,%esi
  800543:	0f 34                	sysenter 
  800545:	5f                   	pop    %edi
  800546:	5e                   	pop    %esi
  800547:	5d                   	pop    %ebp
  800548:	5c                   	pop    %esp
  800549:	5b                   	pop    %ebx
  80054a:	5a                   	pop    %edx
  80054b:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80054c:	85 c0                	test   %eax,%eax
  80054e:	7e 28                	jle    800578 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800550:	89 44 24 10          	mov    %eax,0x10(%esp)
  800554:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80055b:	00 
  80055c:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  800563:	00 
  800564:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80056b:	00 
  80056c:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  800573:	e8 ec 0f 00 00       	call   801564 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800578:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80057b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80057e:	89 ec                	mov    %ebp,%esp
  800580:	5d                   	pop    %ebp
  800581:	c3                   	ret    

00800582 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	83 ec 28             	sub    $0x28,%esp
  800588:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80058b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80058e:	8b 7d 18             	mov    0x18(%ebp),%edi
  800591:	0b 7d 14             	or     0x14(%ebp),%edi
  800594:	b8 06 00 00 00       	mov    $0x6,%eax
  800599:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80059f:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a2:	51                   	push   %ecx
  8005a3:	52                   	push   %edx
  8005a4:	53                   	push   %ebx
  8005a5:	54                   	push   %esp
  8005a6:	55                   	push   %ebp
  8005a7:	56                   	push   %esi
  8005a8:	57                   	push   %edi
  8005a9:	54                   	push   %esp
  8005aa:	5d                   	pop    %ebp
  8005ab:	8d 35 b3 05 80 00    	lea    0x8005b3,%esi
  8005b1:	0f 34                	sysenter 
  8005b3:	5f                   	pop    %edi
  8005b4:	5e                   	pop    %esi
  8005b5:	5d                   	pop    %ebp
  8005b6:	5c                   	pop    %esp
  8005b7:	5b                   	pop    %ebx
  8005b8:	5a                   	pop    %edx
  8005b9:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8005ba:	85 c0                	test   %eax,%eax
  8005bc:	7e 28                	jle    8005e6 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005c2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8005c9:	00 
  8005ca:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  8005d1:	00 
  8005d2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8005d9:	00 
  8005da:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  8005e1:	e8 7e 0f 00 00       	call   801564 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8005e6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005ec:	89 ec                	mov    %ebp,%esp
  8005ee:	5d                   	pop    %ebp
  8005ef:	c3                   	ret    

008005f0 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005f0:	55                   	push   %ebp
  8005f1:	89 e5                	mov    %esp,%ebp
  8005f3:	83 ec 28             	sub    $0x28,%esp
  8005f6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005f9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005fc:	bf 00 00 00 00       	mov    $0x0,%edi
  800601:	b8 05 00 00 00       	mov    $0x5,%eax
  800606:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800609:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80060c:	8b 55 08             	mov    0x8(%ebp),%edx
  80060f:	51                   	push   %ecx
  800610:	52                   	push   %edx
  800611:	53                   	push   %ebx
  800612:	54                   	push   %esp
  800613:	55                   	push   %ebp
  800614:	56                   	push   %esi
  800615:	57                   	push   %edi
  800616:	54                   	push   %esp
  800617:	5d                   	pop    %ebp
  800618:	8d 35 20 06 80 00    	lea    0x800620,%esi
  80061e:	0f 34                	sysenter 
  800620:	5f                   	pop    %edi
  800621:	5e                   	pop    %esi
  800622:	5d                   	pop    %ebp
  800623:	5c                   	pop    %esp
  800624:	5b                   	pop    %ebx
  800625:	5a                   	pop    %edx
  800626:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800627:	85 c0                	test   %eax,%eax
  800629:	7e 28                	jle    800653 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80062b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062f:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800636:	00 
  800637:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  80063e:	00 
  80063f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800646:	00 
  800647:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80064e:	e8 11 0f 00 00       	call   801564 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800653:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800656:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800659:	89 ec                	mov    %ebp,%esp
  80065b:	5d                   	pop    %ebp
  80065c:	c3                   	ret    

0080065d <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  80065d:	55                   	push   %ebp
  80065e:	89 e5                	mov    %esp,%ebp
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	89 1c 24             	mov    %ebx,(%esp)
  800666:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80066a:	ba 00 00 00 00       	mov    $0x0,%edx
  80066f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800674:	89 d1                	mov    %edx,%ecx
  800676:	89 d3                	mov    %edx,%ebx
  800678:	89 d7                	mov    %edx,%edi
  80067a:	51                   	push   %ecx
  80067b:	52                   	push   %edx
  80067c:	53                   	push   %ebx
  80067d:	54                   	push   %esp
  80067e:	55                   	push   %ebp
  80067f:	56                   	push   %esi
  800680:	57                   	push   %edi
  800681:	54                   	push   %esp
  800682:	5d                   	pop    %ebp
  800683:	8d 35 8b 06 80 00    	lea    0x80068b,%esi
  800689:	0f 34                	sysenter 
  80068b:	5f                   	pop    %edi
  80068c:	5e                   	pop    %esi
  80068d:	5d                   	pop    %ebp
  80068e:	5c                   	pop    %esp
  80068f:	5b                   	pop    %ebx
  800690:	5a                   	pop    %edx
  800691:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800692:	8b 1c 24             	mov    (%esp),%ebx
  800695:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800699:	89 ec                	mov    %ebp,%esp
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	89 1c 24             	mov    %ebx,(%esp)
  8006a6:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006af:	b8 04 00 00 00       	mov    $0x4,%eax
  8006b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ba:	89 df                	mov    %ebx,%edi
  8006bc:	51                   	push   %ecx
  8006bd:	52                   	push   %edx
  8006be:	53                   	push   %ebx
  8006bf:	54                   	push   %esp
  8006c0:	55                   	push   %ebp
  8006c1:	56                   	push   %esi
  8006c2:	57                   	push   %edi
  8006c3:	54                   	push   %esp
  8006c4:	5d                   	pop    %ebp
  8006c5:	8d 35 cd 06 80 00    	lea    0x8006cd,%esi
  8006cb:	0f 34                	sysenter 
  8006cd:	5f                   	pop    %edi
  8006ce:	5e                   	pop    %esi
  8006cf:	5d                   	pop    %ebp
  8006d0:	5c                   	pop    %esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5a                   	pop    %edx
  8006d3:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8006d4:	8b 1c 24             	mov    (%esp),%ebx
  8006d7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006db:	89 ec                	mov    %ebp,%esp
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	89 1c 24             	mov    %ebx,(%esp)
  8006e8:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8006ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f1:	b8 02 00 00 00       	mov    $0x2,%eax
  8006f6:	89 d1                	mov    %edx,%ecx
  8006f8:	89 d3                	mov    %edx,%ebx
  8006fa:	89 d7                	mov    %edx,%edi
  8006fc:	51                   	push   %ecx
  8006fd:	52                   	push   %edx
  8006fe:	53                   	push   %ebx
  8006ff:	54                   	push   %esp
  800700:	55                   	push   %ebp
  800701:	56                   	push   %esi
  800702:	57                   	push   %edi
  800703:	54                   	push   %esp
  800704:	5d                   	pop    %ebp
  800705:	8d 35 0d 07 80 00    	lea    0x80070d,%esi
  80070b:	0f 34                	sysenter 
  80070d:	5f                   	pop    %edi
  80070e:	5e                   	pop    %esi
  80070f:	5d                   	pop    %ebp
  800710:	5c                   	pop    %esp
  800711:	5b                   	pop    %ebx
  800712:	5a                   	pop    %edx
  800713:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800714:	8b 1c 24             	mov    (%esp),%ebx
  800717:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80071b:	89 ec                	mov    %ebp,%esp
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 28             	sub    $0x28,%esp
  800725:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800728:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80072b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800730:	b8 03 00 00 00       	mov    $0x3,%eax
  800735:	8b 55 08             	mov    0x8(%ebp),%edx
  800738:	89 cb                	mov    %ecx,%ebx
  80073a:	89 cf                	mov    %ecx,%edi
  80073c:	51                   	push   %ecx
  80073d:	52                   	push   %edx
  80073e:	53                   	push   %ebx
  80073f:	54                   	push   %esp
  800740:	55                   	push   %ebp
  800741:	56                   	push   %esi
  800742:	57                   	push   %edi
  800743:	54                   	push   %esp
  800744:	5d                   	pop    %ebp
  800745:	8d 35 4d 07 80 00    	lea    0x80074d,%esi
  80074b:	0f 34                	sysenter 
  80074d:	5f                   	pop    %edi
  80074e:	5e                   	pop    %esi
  80074f:	5d                   	pop    %ebp
  800750:	5c                   	pop    %esp
  800751:	5b                   	pop    %ebx
  800752:	5a                   	pop    %edx
  800753:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800754:	85 c0                	test   %eax,%eax
  800756:	7e 28                	jle    800780 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800758:	89 44 24 10          	mov    %eax,0x10(%esp)
  80075c:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800763:	00 
  800764:	c7 44 24 08 4a 27 80 	movl   $0x80274a,0x8(%esp)
  80076b:	00 
  80076c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800773:	00 
  800774:	c7 04 24 67 27 80 00 	movl   $0x802767,(%esp)
  80077b:	e8 e4 0d 00 00       	call   801564 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800780:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800783:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800786:	89 ec                	mov    %ebp,%esp
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    
  80078a:	00 00                	add    %al,(%eax)
  80078c:	00 00                	add    %al,(%eax)
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
  8008b9:	be f4 27 80 00       	mov    $0x8027f4,%esi
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
  8008dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8008e1:	8b 40 48             	mov    0x48(%eax),%eax
  8008e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ec:	c7 04 24 78 27 80 00 	movl   $0x802778,(%esp)
  8008f3:	e8 25 0d 00 00       	call   80161d <cprintf>
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
  8009c1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8009c6:	8b 40 48             	mov    0x48(%eax),%eax
  8009c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d1:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  8009d8:	e8 40 0c 00 00       	call   80161d <cprintf>
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
  800a43:	a1 08 40 80 00       	mov    0x804008,%eax
  800a48:	8b 40 48             	mov    0x48(%eax),%eax
  800a4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a53:	c7 04 24 b9 27 80 00 	movl   $0x8027b9,(%esp)
  800a5a:	e8 be 0b 00 00       	call   80161d <cprintf>
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
  800ad1:	a1 08 40 80 00       	mov    0x804008,%eax
  800ad6:	8b 40 48             	mov    0x48(%eax),%eax
  800ad9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800add:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae1:	c7 04 24 d6 27 80 00 	movl   $0x8027d6,(%esp)
  800ae8:	e8 30 0b 00 00       	call   80161d <cprintf>
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
  800be0:	e8 31 f9 ff ff       	call   800516 <sys_page_unmap>
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
  800d2e:	e8 4f f8 ff ff       	call   800582 <sys_page_map>
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
  800d69:	e8 14 f8 ff ff       	call   800582 <sys_page_map>
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
  800d83:	e8 8e f7 ff ff       	call   800516 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800d88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d96:	e8 7b f7 ff ff       	call   800516 <sys_page_unmap>
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
  800dcc:	e8 6f 15 00 00       	call   802340 <ipc_find_env>
  800dd1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800dd6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ddd:	00 
  800dde:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800de5:	00 
  800de6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dea:	a1 00 40 80 00       	mov    0x804000,%eax
  800def:	89 04 24             	mov    %eax,(%esp)
  800df2:	e8 94 15 00 00       	call   80238b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800df7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dfe:	00 
  800dff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e0a:	e8 fa 15 00 00       	call   802409 <ipc_recv>
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
  800e25:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2d:	a3 04 50 80 00       	mov    %eax,0x805004
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
  800e4f:	a3 00 50 80 00       	mov    %eax,0x805000
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
  800e8c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e91:	ba 00 00 00 00       	mov    $0x0,%edx
  800e96:	b8 05 00 00 00       	mov    $0x5,%eax
  800e9b:	e8 0c ff ff ff       	call   800dac <fsipc>
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	78 2b                	js     800ecf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ea4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800eab:	00 
  800eac:	89 1c 24             	mov    %ebx,(%esp)
  800eaf:	e8 96 10 00 00       	call   801f4a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800eb4:	a1 80 50 80 00       	mov    0x805080,%eax
  800eb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ebf:	a1 84 50 80 00       	mov    0x805084,%eax
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
  800ef0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800ef6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800efb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f06:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f0d:	e8 23 12 00 00       	call   802135 <memmove>
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
  800f30:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800f35:	8b 45 10             	mov    0x10(%ebp),%eax
  800f38:	a3 04 50 80 00       	mov    %eax,0x805004
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
  800f56:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800f5d:	00 
  800f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f61:	89 04 24             	mov    %eax,(%esp)
  800f64:	e8 cc 11 00 00       	call   802135 <memmove>
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
  800f7e:	e8 7d 0f 00 00       	call   801f00 <strlen>
  800f83:	89 c2                	mov    %eax,%edx
  800f85:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800f8a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800f90:	7f 1f                	jg     800fb1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800f92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f96:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800f9d:	e8 a8 0f 00 00       	call   801f4a <strcpy>
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
  800fc9:	e8 32 0f 00 00       	call   801f00 <strlen>
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
  800fee:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  800ff3:	89 34 24             	mov    %esi,(%esp)
  800ff6:	e8 05 0f 00 00       	call   801f00 <strlen>
  800ffb:	83 c0 01             	add    $0x1,%eax
  800ffe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801002:	89 74 24 04          	mov    %esi,0x4(%esp)
  801006:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80100d:	e8 23 11 00 00       	call   802135 <memmove>
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

00801060 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801066:	c7 44 24 04 00 28 80 	movl   $0x802800,0x4(%esp)
  80106d:	00 
  80106e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801071:	89 04 24             	mov    %eax,(%esp)
  801074:	e8 d1 0e 00 00       	call   801f4a <strcpy>
	return 0;
}
  801079:	b8 00 00 00 00       	mov    $0x0,%eax
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	53                   	push   %ebx
  801084:	83 ec 14             	sub    $0x14,%esp
  801087:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80108a:	89 1c 24             	mov    %ebx,(%esp)
  80108d:	e8 ea 13 00 00       	call   80247c <pageref>
  801092:	89 c2                	mov    %eax,%edx
  801094:	b8 00 00 00 00       	mov    $0x0,%eax
  801099:	83 fa 01             	cmp    $0x1,%edx
  80109c:	75 0b                	jne    8010a9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80109e:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010a1:	89 04 24             	mov    %eax,(%esp)
  8010a4:	e8 b9 02 00 00       	call   801362 <nsipc_close>
	else
		return 0;
}
  8010a9:	83 c4 14             	add    $0x14,%esp
  8010ac:	5b                   	pop    %ebx
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8010b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010bc:	00 
  8010bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8010c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8010d1:	89 04 24             	mov    %eax,(%esp)
  8010d4:	e8 c5 02 00 00       	call   80139e <nsipc_send>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8010e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e8:	00 
  8010e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8010fd:	89 04 24             	mov    %eax,(%esp)
  801100:	e8 0c 03 00 00       	call   801411 <nsipc_recv>
}
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	56                   	push   %esi
  80110b:	53                   	push   %ebx
  80110c:	83 ec 20             	sub    $0x20,%esp
  80110f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801111:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801114:	89 04 24             	mov    %eax,(%esp)
  801117:	e8 9f f6 ff ff       	call   8007bb <fd_alloc>
  80111c:	89 c3                	mov    %eax,%ebx
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 21                	js     801143 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801122:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801129:	00 
  80112a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801138:	e8 b3 f4 ff ff       	call   8005f0 <sys_page_alloc>
  80113d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80113f:	85 c0                	test   %eax,%eax
  801141:	79 0a                	jns    80114d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801143:	89 34 24             	mov    %esi,(%esp)
  801146:	e8 17 02 00 00       	call   801362 <nsipc_close>
		return r;
  80114b:	eb 28                	jmp    801175 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80114d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801156:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801165:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	89 04 24             	mov    %eax,(%esp)
  80116e:	e8 1d f6 ff ff       	call   800790 <fd2num>
  801173:	89 c3                	mov    %eax,%ebx
}
  801175:	89 d8                	mov    %ebx,%eax
  801177:	83 c4 20             	add    $0x20,%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801184:	8b 45 10             	mov    0x10(%ebp),%eax
  801187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	e8 79 01 00 00       	call   801316 <nsipc_socket>
  80119d:	85 c0                	test   %eax,%eax
  80119f:	78 05                	js     8011a6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8011a1:	e8 61 ff ff ff       	call   801107 <alloc_sockfd>
}
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8011ae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011b5:	89 04 24             	mov    %eax,(%esp)
  8011b8:	e8 70 f6 ff ff       	call   80082d <fd_lookup>
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 15                	js     8011d6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8011c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c4:	8b 0a                	mov    (%edx),%ecx
  8011c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011cb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  8011d1:	75 03                	jne    8011d6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8011d3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8011d6:	c9                   	leave  
  8011d7:	c3                   	ret    

008011d8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	e8 c2 ff ff ff       	call   8011a8 <fd2sockid>
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 0f                	js     8011f9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8011ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011f1:	89 04 24             	mov    %eax,(%esp)
  8011f4:	e8 47 01 00 00       	call   801340 <nsipc_listen>
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801201:	8b 45 08             	mov    0x8(%ebp),%eax
  801204:	e8 9f ff ff ff       	call   8011a8 <fd2sockid>
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 16                	js     801223 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80120d:	8b 55 10             	mov    0x10(%ebp),%edx
  801210:	89 54 24 08          	mov    %edx,0x8(%esp)
  801214:	8b 55 0c             	mov    0xc(%ebp),%edx
  801217:	89 54 24 04          	mov    %edx,0x4(%esp)
  80121b:	89 04 24             	mov    %eax,(%esp)
  80121e:	e8 6e 02 00 00       	call   801491 <nsipc_connect>
}
  801223:	c9                   	leave  
  801224:	c3                   	ret    

00801225 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	e8 75 ff ff ff       	call   8011a8 <fd2sockid>
  801233:	85 c0                	test   %eax,%eax
  801235:	78 0f                	js     801246 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80123e:	89 04 24             	mov    %eax,(%esp)
  801241:	e8 36 01 00 00       	call   80137c <nsipc_shutdown>
}
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80124e:	8b 45 08             	mov    0x8(%ebp),%eax
  801251:	e8 52 ff ff ff       	call   8011a8 <fd2sockid>
  801256:	85 c0                	test   %eax,%eax
  801258:	78 16                	js     801270 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80125a:	8b 55 10             	mov    0x10(%ebp),%edx
  80125d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801261:	8b 55 0c             	mov    0xc(%ebp),%edx
  801264:	89 54 24 04          	mov    %edx,0x4(%esp)
  801268:	89 04 24             	mov    %eax,(%esp)
  80126b:	e8 60 02 00 00       	call   8014d0 <nsipc_bind>
}
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801278:	8b 45 08             	mov    0x8(%ebp),%eax
  80127b:	e8 28 ff ff ff       	call   8011a8 <fd2sockid>
  801280:	85 c0                	test   %eax,%eax
  801282:	78 1f                	js     8012a3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801284:	8b 55 10             	mov    0x10(%ebp),%edx
  801287:	89 54 24 08          	mov    %edx,0x8(%esp)
  80128b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801292:	89 04 24             	mov    %eax,(%esp)
  801295:	e8 75 02 00 00       	call   80150f <nsipc_accept>
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 05                	js     8012a3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80129e:	e8 64 fe ff ff       	call   801107 <alloc_sockfd>
}
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    
	...

008012b0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 14             	sub    $0x14,%esp
  8012b7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8012b9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8012c0:	75 11                	jne    8012d3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8012c2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8012c9:	e8 72 10 00 00       	call   802340 <ipc_find_env>
  8012ce:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8012d3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8012da:	00 
  8012db:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8012e2:	00 
  8012e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ec:	89 04 24             	mov    %eax,(%esp)
  8012ef:	e8 97 10 00 00       	call   80238b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8012f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801303:	00 
  801304:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80130b:	e8 f9 10 00 00       	call   802409 <ipc_recv>
}
  801310:	83 c4 14             	add    $0x14,%esp
  801313:	5b                   	pop    %ebx
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80131c:	8b 45 08             	mov    0x8(%ebp),%eax
  80131f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801324:	8b 45 0c             	mov    0xc(%ebp),%eax
  801327:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80132c:	8b 45 10             	mov    0x10(%ebp),%eax
  80132f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801334:	b8 09 00 00 00       	mov    $0x9,%eax
  801339:	e8 72 ff ff ff       	call   8012b0 <nsipc>
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801346:	8b 45 08             	mov    0x8(%ebp),%eax
  801349:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80134e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801351:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801356:	b8 06 00 00 00       	mov    $0x6,%eax
  80135b:	e8 50 ff ff ff       	call   8012b0 <nsipc>
}
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801368:	8b 45 08             	mov    0x8(%ebp),%eax
  80136b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801370:	b8 04 00 00 00       	mov    $0x4,%eax
  801375:	e8 36 ff ff ff       	call   8012b0 <nsipc>
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801382:	8b 45 08             	mov    0x8(%ebp),%eax
  801385:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80138a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801392:	b8 03 00 00 00       	mov    $0x3,%eax
  801397:	e8 14 ff ff ff       	call   8012b0 <nsipc>
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 14             	sub    $0x14,%esp
  8013a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8013a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ab:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8013b0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8013b6:	7e 24                	jle    8013dc <nsipc_send+0x3e>
  8013b8:	c7 44 24 0c 0c 28 80 	movl   $0x80280c,0xc(%esp)
  8013bf:	00 
  8013c0:	c7 44 24 08 18 28 80 	movl   $0x802818,0x8(%esp)
  8013c7:	00 
  8013c8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8013cf:	00 
  8013d0:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  8013d7:	e8 88 01 00 00       	call   801564 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8013dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8013ee:	e8 42 0d 00 00       	call   802135 <memmove>
	nsipcbuf.send.req_size = size;
  8013f3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8013f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801401:	b8 08 00 00 00       	mov    $0x8,%eax
  801406:	e8 a5 fe ff ff       	call   8012b0 <nsipc>
}
  80140b:	83 c4 14             	add    $0x14,%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	56                   	push   %esi
  801415:	53                   	push   %ebx
  801416:	83 ec 10             	sub    $0x10,%esp
  801419:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801424:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80142a:	8b 45 14             	mov    0x14(%ebp),%eax
  80142d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801432:	b8 07 00 00 00       	mov    $0x7,%eax
  801437:	e8 74 fe ff ff       	call   8012b0 <nsipc>
  80143c:	89 c3                	mov    %eax,%ebx
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 46                	js     801488 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801442:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801447:	7f 04                	jg     80144d <nsipc_recv+0x3c>
  801449:	39 c6                	cmp    %eax,%esi
  80144b:	7d 24                	jge    801471 <nsipc_recv+0x60>
  80144d:	c7 44 24 0c 39 28 80 	movl   $0x802839,0xc(%esp)
  801454:	00 
  801455:	c7 44 24 08 18 28 80 	movl   $0x802818,0x8(%esp)
  80145c:	00 
  80145d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801464:	00 
  801465:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  80146c:	e8 f3 00 00 00       	call   801564 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801471:	89 44 24 08          	mov    %eax,0x8(%esp)
  801475:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80147c:	00 
  80147d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801480:	89 04 24             	mov    %eax,(%esp)
  801483:	e8 ad 0c 00 00       	call   802135 <memmove>
	}

	return r;
}
  801488:	89 d8                	mov    %ebx,%eax
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5e                   	pop    %esi
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	53                   	push   %ebx
  801495:	83 ec 14             	sub    $0x14,%esp
  801498:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8014a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ae:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8014b5:	e8 7b 0c 00 00       	call   802135 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8014ba:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8014c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c5:	e8 e6 fd ff ff       	call   8012b0 <nsipc>
}
  8014ca:	83 c4 14             	add    $0x14,%esp
  8014cd:	5b                   	pop    %ebx
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 14             	sub    $0x14,%esp
  8014d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8014da:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8014e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ed:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8014f4:	e8 3c 0c 00 00       	call   802135 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8014f9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8014ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801504:	e8 a7 fd ff ff       	call   8012b0 <nsipc>
}
  801509:	83 c4 14             	add    $0x14,%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 18             	sub    $0x18,%esp
  801515:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801518:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801523:	b8 01 00 00 00       	mov    $0x1,%eax
  801528:	e8 83 fd ff ff       	call   8012b0 <nsipc>
  80152d:	89 c3                	mov    %eax,%ebx
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 25                	js     801558 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801533:	be 10 60 80 00       	mov    $0x806010,%esi
  801538:	8b 06                	mov    (%esi),%eax
  80153a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80153e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801545:	00 
  801546:	8b 45 0c             	mov    0xc(%ebp),%eax
  801549:	89 04 24             	mov    %eax,(%esp)
  80154c:	e8 e4 0b 00 00       	call   802135 <memmove>
		*addrlen = ret->ret_addrlen;
  801551:	8b 16                	mov    (%esi),%edx
  801553:	8b 45 10             	mov    0x10(%ebp),%eax
  801556:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801558:	89 d8                	mov    %ebx,%eax
  80155a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80155d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801560:	89 ec                	mov    %ebp,%esp
  801562:	5d                   	pop    %ebp
  801563:	c3                   	ret    

00801564 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80156c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80156f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801575:	e8 65 f1 ff ff       	call   8006df <sys_getenvid>
  80157a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801581:	8b 55 08             	mov    0x8(%ebp),%edx
  801584:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801588:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80158c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801590:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  801597:	e8 81 00 00 00       	call   80161d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80159c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015a3:	89 04 24             	mov    %eax,(%esp)
  8015a6:	e8 11 00 00 00       	call   8015bc <vcprintf>
	cprintf("\n");
  8015ab:	c7 04 24 f0 27 80 00 	movl   $0x8027f0,(%esp)
  8015b2:	e8 66 00 00 00       	call   80161d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015b7:	cc                   	int3   
  8015b8:	eb fd                	jmp    8015b7 <_panic+0x53>
	...

008015bc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8015c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015cc:	00 00 00 
	b.cnt = 0;
  8015cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f1:	c7 04 24 37 16 80 00 	movl   $0x801637,(%esp)
  8015f8:	e8 cf 01 00 00       	call   8017cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015fd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801603:	89 44 24 04          	mov    %eax,0x4(%esp)
  801607:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80160d:	89 04 24             	mov    %eax,(%esp)
  801610:	e8 df ea ff ff       	call   8000f4 <sys_cputs>

	return b.cnt;
}
  801615:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801623:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162a:	8b 45 08             	mov    0x8(%ebp),%eax
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	e8 87 ff ff ff       	call   8015bc <vcprintf>
	va_end(ap);

	return cnt;
}
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 14             	sub    $0x14,%esp
  80163e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801641:	8b 03                	mov    (%ebx),%eax
  801643:	8b 55 08             	mov    0x8(%ebp),%edx
  801646:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80164a:	83 c0 01             	add    $0x1,%eax
  80164d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80164f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801654:	75 19                	jne    80166f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801656:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80165d:	00 
  80165e:	8d 43 08             	lea    0x8(%ebx),%eax
  801661:	89 04 24             	mov    %eax,(%esp)
  801664:	e8 8b ea ff ff       	call   8000f4 <sys_cputs>
		b->idx = 0;
  801669:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80166f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801673:	83 c4 14             	add    $0x14,%esp
  801676:	5b                   	pop    %ebx
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    
  801679:	00 00                	add    %al,(%eax)
  80167b:	00 00                	add    %al,(%eax)
  80167d:	00 00                	add    %al,(%eax)
	...

00801680 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	57                   	push   %edi
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	83 ec 4c             	sub    $0x4c,%esp
  801689:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80168c:	89 d6                	mov    %edx,%esi
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801694:	8b 55 0c             	mov    0xc(%ebp),%edx
  801697:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80169a:	8b 45 10             	mov    0x10(%ebp),%eax
  80169d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8016a0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8016a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ab:	39 d1                	cmp    %edx,%ecx
  8016ad:	72 07                	jb     8016b6 <printnum_v2+0x36>
  8016af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016b2:	39 d0                	cmp    %edx,%eax
  8016b4:	77 5f                	ja     801715 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8016b6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8016ba:	83 eb 01             	sub    $0x1,%ebx
  8016bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8016c9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8016cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8016d0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8016d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8016d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016e1:	00 
  8016e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016e5:	89 04 24             	mov    %eax,(%esp)
  8016e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8016eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016ef:	e8 cc 0d 00 00       	call   8024c0 <__udivdi3>
  8016f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8016f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8016fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801702:	89 04 24             	mov    %eax,(%esp)
  801705:	89 54 24 04          	mov    %edx,0x4(%esp)
  801709:	89 f2                	mov    %esi,%edx
  80170b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80170e:	e8 6d ff ff ff       	call   801680 <printnum_v2>
  801713:	eb 1e                	jmp    801733 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801715:	83 ff 2d             	cmp    $0x2d,%edi
  801718:	74 19                	je     801733 <printnum_v2+0xb3>
		while (--width > 0)
  80171a:	83 eb 01             	sub    $0x1,%ebx
  80171d:	85 db                	test   %ebx,%ebx
  80171f:	90                   	nop
  801720:	7e 11                	jle    801733 <printnum_v2+0xb3>
			putch(padc, putdat);
  801722:	89 74 24 04          	mov    %esi,0x4(%esp)
  801726:	89 3c 24             	mov    %edi,(%esp)
  801729:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80172c:	83 eb 01             	sub    $0x1,%ebx
  80172f:	85 db                	test   %ebx,%ebx
  801731:	7f ef                	jg     801722 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801733:	89 74 24 04          	mov    %esi,0x4(%esp)
  801737:	8b 74 24 04          	mov    0x4(%esp),%esi
  80173b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80173e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801742:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801749:	00 
  80174a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80174d:	89 14 24             	mov    %edx,(%esp)
  801750:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801753:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801757:	e8 94 0e 00 00       	call   8025f0 <__umoddi3>
  80175c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801760:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
  801767:	89 04 24             	mov    %eax,(%esp)
  80176a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80176d:	83 c4 4c             	add    $0x4c,%esp
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5f                   	pop    %edi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801778:	83 fa 01             	cmp    $0x1,%edx
  80177b:	7e 0e                	jle    80178b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80177d:	8b 10                	mov    (%eax),%edx
  80177f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801782:	89 08                	mov    %ecx,(%eax)
  801784:	8b 02                	mov    (%edx),%eax
  801786:	8b 52 04             	mov    0x4(%edx),%edx
  801789:	eb 22                	jmp    8017ad <getuint+0x38>
	else if (lflag)
  80178b:	85 d2                	test   %edx,%edx
  80178d:	74 10                	je     80179f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80178f:	8b 10                	mov    (%eax),%edx
  801791:	8d 4a 04             	lea    0x4(%edx),%ecx
  801794:	89 08                	mov    %ecx,(%eax)
  801796:	8b 02                	mov    (%edx),%eax
  801798:	ba 00 00 00 00       	mov    $0x0,%edx
  80179d:	eb 0e                	jmp    8017ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80179f:	8b 10                	mov    (%eax),%edx
  8017a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017a4:	89 08                	mov    %ecx,(%eax)
  8017a6:	8b 02                	mov    (%edx),%eax
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017b9:	8b 10                	mov    (%eax),%edx
  8017bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8017be:	73 0a                	jae    8017ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8017c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c3:	88 0a                	mov    %cl,(%edx)
  8017c5:	83 c2 01             	add    $0x1,%edx
  8017c8:	89 10                	mov    %edx,(%eax)
}
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	57                   	push   %edi
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 6c             	sub    $0x6c,%esp
  8017d5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8017d8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8017df:	eb 1a                	jmp    8017fb <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	0f 84 66 06 00 00    	je     801e4f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8017e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017f0:	89 04 24             	mov    %eax,(%esp)
  8017f3:	ff 55 08             	call   *0x8(%ebp)
  8017f6:	eb 03                	jmp    8017fb <vprintfmt+0x2f>
  8017f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017fb:	0f b6 07             	movzbl (%edi),%eax
  8017fe:	83 c7 01             	add    $0x1,%edi
  801801:	83 f8 25             	cmp    $0x25,%eax
  801804:	75 db                	jne    8017e1 <vprintfmt+0x15>
  801806:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80180a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80180f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801816:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80181b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801822:	be 00 00 00 00       	mov    $0x0,%esi
  801827:	eb 06                	jmp    80182f <vprintfmt+0x63>
  801829:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80182d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182f:	0f b6 17             	movzbl (%edi),%edx
  801832:	0f b6 c2             	movzbl %dl,%eax
  801835:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801838:	8d 47 01             	lea    0x1(%edi),%eax
  80183b:	83 ea 23             	sub    $0x23,%edx
  80183e:	80 fa 55             	cmp    $0x55,%dl
  801841:	0f 87 60 05 00 00    	ja     801da7 <vprintfmt+0x5db>
  801847:	0f b6 d2             	movzbl %dl,%edx
  80184a:	ff 24 95 60 2a 80 00 	jmp    *0x802a60(,%edx,4)
  801851:	b9 01 00 00 00       	mov    $0x1,%ecx
  801856:	eb d5                	jmp    80182d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801858:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80185b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80185e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801861:	8d 7a d0             	lea    -0x30(%edx),%edi
  801864:	83 ff 09             	cmp    $0x9,%edi
  801867:	76 08                	jbe    801871 <vprintfmt+0xa5>
  801869:	eb 40                	jmp    8018ab <vprintfmt+0xdf>
  80186b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80186f:	eb bc                	jmp    80182d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801871:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801874:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  801877:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80187b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80187e:	8d 7a d0             	lea    -0x30(%edx),%edi
  801881:	83 ff 09             	cmp    $0x9,%edi
  801884:	76 eb                	jbe    801871 <vprintfmt+0xa5>
  801886:	eb 23                	jmp    8018ab <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801888:	8b 55 14             	mov    0x14(%ebp),%edx
  80188b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80188e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801891:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  801893:	eb 16                	jmp    8018ab <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  801895:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801898:	c1 fa 1f             	sar    $0x1f,%edx
  80189b:	f7 d2                	not    %edx
  80189d:	21 55 d8             	and    %edx,-0x28(%ebp)
  8018a0:	eb 8b                	jmp    80182d <vprintfmt+0x61>
  8018a2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8018a9:	eb 82                	jmp    80182d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8018ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018af:	0f 89 78 ff ff ff    	jns    80182d <vprintfmt+0x61>
  8018b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8018b8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8018bb:	e9 6d ff ff ff       	jmp    80182d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018c0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8018c3:	e9 65 ff ff ff       	jmp    80182d <vprintfmt+0x61>
  8018c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ce:	8d 50 04             	lea    0x4(%eax),%edx
  8018d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8018d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018db:	8b 00                	mov    (%eax),%eax
  8018dd:	89 04 24             	mov    %eax,(%esp)
  8018e0:	ff 55 08             	call   *0x8(%ebp)
  8018e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8018e6:	e9 10 ff ff ff       	jmp    8017fb <vprintfmt+0x2f>
  8018eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f1:	8d 50 04             	lea    0x4(%eax),%edx
  8018f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f7:	8b 00                	mov    (%eax),%eax
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	c1 fa 1f             	sar    $0x1f,%edx
  8018fe:	31 d0                	xor    %edx,%eax
  801900:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801902:	83 f8 0f             	cmp    $0xf,%eax
  801905:	7f 0b                	jg     801912 <vprintfmt+0x146>
  801907:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  80190e:	85 d2                	test   %edx,%edx
  801910:	75 26                	jne    801938 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801912:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801916:	c7 44 24 08 84 28 80 	movl   $0x802884,0x8(%esp)
  80191d:	00 
  80191e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801921:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801925:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801928:	89 1c 24             	mov    %ebx,(%esp)
  80192b:	e8 a7 05 00 00       	call   801ed7 <printfmt>
  801930:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801933:	e9 c3 fe ff ff       	jmp    8017fb <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801938:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80193c:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  801943:	00 
  801944:	8b 45 0c             	mov    0xc(%ebp),%eax
  801947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194b:	8b 55 08             	mov    0x8(%ebp),%edx
  80194e:	89 14 24             	mov    %edx,(%esp)
  801951:	e8 81 05 00 00       	call   801ed7 <printfmt>
  801956:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801959:	e9 9d fe ff ff       	jmp    8017fb <vprintfmt+0x2f>
  80195e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801961:	89 c7                	mov    %eax,%edi
  801963:	89 d9                	mov    %ebx,%ecx
  801965:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801968:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80196b:	8b 45 14             	mov    0x14(%ebp),%eax
  80196e:	8d 50 04             	lea    0x4(%eax),%edx
  801971:	89 55 14             	mov    %edx,0x14(%ebp)
  801974:	8b 30                	mov    (%eax),%esi
  801976:	85 f6                	test   %esi,%esi
  801978:	75 05                	jne    80197f <vprintfmt+0x1b3>
  80197a:	be 8d 28 80 00       	mov    $0x80288d,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80197f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  801983:	7e 06                	jle    80198b <vprintfmt+0x1bf>
  801985:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  801989:	75 10                	jne    80199b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80198b:	0f be 06             	movsbl (%esi),%eax
  80198e:	85 c0                	test   %eax,%eax
  801990:	0f 85 a2 00 00 00    	jne    801a38 <vprintfmt+0x26c>
  801996:	e9 92 00 00 00       	jmp    801a2d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80199b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80199f:	89 34 24             	mov    %esi,(%esp)
  8019a2:	e8 74 05 00 00       	call   801f1b <strnlen>
  8019a7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8019aa:	29 c2                	sub    %eax,%edx
  8019ac:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8019af:	85 d2                	test   %edx,%edx
  8019b1:	7e d8                	jle    80198b <vprintfmt+0x1bf>
					putch(padc, putdat);
  8019b3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8019b7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8019ba:	89 d3                	mov    %edx,%ebx
  8019bc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8019bf:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8019c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019c5:	89 ce                	mov    %ecx,%esi
  8019c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019cb:	89 34 24             	mov    %esi,(%esp)
  8019ce:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019d1:	83 eb 01             	sub    $0x1,%ebx
  8019d4:	85 db                	test   %ebx,%ebx
  8019d6:	7f ef                	jg     8019c7 <vprintfmt+0x1fb>
  8019d8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8019db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8019de:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8019e1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8019e8:	eb a1                	jmp    80198b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019ea:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8019ee:	74 1b                	je     801a0b <vprintfmt+0x23f>
  8019f0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8019f3:	83 fa 5e             	cmp    $0x5e,%edx
  8019f6:	76 13                	jbe    801a0b <vprintfmt+0x23f>
					putch('?', putdat);
  8019f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ff:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801a06:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a09:	eb 0d                	jmp    801a18 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a18:	83 ef 01             	sub    $0x1,%edi
  801a1b:	0f be 06             	movsbl (%esi),%eax
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	74 05                	je     801a27 <vprintfmt+0x25b>
  801a22:	83 c6 01             	add    $0x1,%esi
  801a25:	eb 1a                	jmp    801a41 <vprintfmt+0x275>
  801a27:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a2a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a2d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a31:	7f 1f                	jg     801a52 <vprintfmt+0x286>
  801a33:	e9 c0 fd ff ff       	jmp    8017f8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a38:	83 c6 01             	add    $0x1,%esi
  801a3b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801a3e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801a41:	85 db                	test   %ebx,%ebx
  801a43:	78 a5                	js     8019ea <vprintfmt+0x21e>
  801a45:	83 eb 01             	sub    $0x1,%ebx
  801a48:	79 a0                	jns    8019ea <vprintfmt+0x21e>
  801a4a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a4d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801a50:	eb db                	jmp    801a2d <vprintfmt+0x261>
  801a52:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801a55:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a58:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801a5b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a5e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a62:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a69:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a6b:	83 eb 01             	sub    $0x1,%ebx
  801a6e:	85 db                	test   %ebx,%ebx
  801a70:	7f ec                	jg     801a5e <vprintfmt+0x292>
  801a72:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801a75:	e9 81 fd ff ff       	jmp    8017fb <vprintfmt+0x2f>
  801a7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a7d:	83 fe 01             	cmp    $0x1,%esi
  801a80:	7e 10                	jle    801a92 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801a82:	8b 45 14             	mov    0x14(%ebp),%eax
  801a85:	8d 50 08             	lea    0x8(%eax),%edx
  801a88:	89 55 14             	mov    %edx,0x14(%ebp)
  801a8b:	8b 18                	mov    (%eax),%ebx
  801a8d:	8b 70 04             	mov    0x4(%eax),%esi
  801a90:	eb 26                	jmp    801ab8 <vprintfmt+0x2ec>
	else if (lflag)
  801a92:	85 f6                	test   %esi,%esi
  801a94:	74 12                	je     801aa8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801a96:	8b 45 14             	mov    0x14(%ebp),%eax
  801a99:	8d 50 04             	lea    0x4(%eax),%edx
  801a9c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a9f:	8b 18                	mov    (%eax),%ebx
  801aa1:	89 de                	mov    %ebx,%esi
  801aa3:	c1 fe 1f             	sar    $0x1f,%esi
  801aa6:	eb 10                	jmp    801ab8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801aa8:	8b 45 14             	mov    0x14(%ebp),%eax
  801aab:	8d 50 04             	lea    0x4(%eax),%edx
  801aae:	89 55 14             	mov    %edx,0x14(%ebp)
  801ab1:	8b 18                	mov    (%eax),%ebx
  801ab3:	89 de                	mov    %ebx,%esi
  801ab5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  801ab8:	83 f9 01             	cmp    $0x1,%ecx
  801abb:	75 1e                	jne    801adb <vprintfmt+0x30f>
                               if((long long)num > 0){
  801abd:	85 f6                	test   %esi,%esi
  801abf:	78 1a                	js     801adb <vprintfmt+0x30f>
  801ac1:	85 f6                	test   %esi,%esi
  801ac3:	7f 05                	jg     801aca <vprintfmt+0x2fe>
  801ac5:	83 fb 00             	cmp    $0x0,%ebx
  801ac8:	76 11                	jbe    801adb <vprintfmt+0x30f>
                                   putch('+',putdat);
  801aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ad1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  801ad8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  801adb:	85 f6                	test   %esi,%esi
  801add:	78 13                	js     801af2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801adf:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  801ae2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  801ae5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ae8:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aed:	e9 da 00 00 00       	jmp    801bcc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  801af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801b00:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801b03:	89 da                	mov    %ebx,%edx
  801b05:	89 f1                	mov    %esi,%ecx
  801b07:	f7 da                	neg    %edx
  801b09:	83 d1 00             	adc    $0x0,%ecx
  801b0c:	f7 d9                	neg    %ecx
  801b0e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801b11:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b17:	b8 0a 00 00 00       	mov    $0xa,%eax
  801b1c:	e9 ab 00 00 00       	jmp    801bcc <vprintfmt+0x400>
  801b21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b24:	89 f2                	mov    %esi,%edx
  801b26:	8d 45 14             	lea    0x14(%ebp),%eax
  801b29:	e8 47 fc ff ff       	call   801775 <getuint>
  801b2e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801b31:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801b34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b37:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  801b3c:	e9 8b 00 00 00       	jmp    801bcc <vprintfmt+0x400>
  801b41:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b47:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b4b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b52:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801b55:	89 f2                	mov    %esi,%edx
  801b57:	8d 45 14             	lea    0x14(%ebp),%eax
  801b5a:	e8 16 fc ff ff       	call   801775 <getuint>
  801b5f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801b62:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801b65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b68:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  801b6d:	eb 5d                	jmp    801bcc <vprintfmt+0x400>
  801b6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801b72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b79:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b80:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801b83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b87:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801b8e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801b91:	8b 45 14             	mov    0x14(%ebp),%eax
  801b94:	8d 50 04             	lea    0x4(%eax),%edx
  801b97:	89 55 14             	mov    %edx,0x14(%ebp)
  801b9a:	8b 10                	mov    (%eax),%edx
  801b9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ba1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801ba4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801ba7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801baa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801baf:	eb 1b                	jmp    801bcc <vprintfmt+0x400>
  801bb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bb4:	89 f2                	mov    %esi,%edx
  801bb6:	8d 45 14             	lea    0x14(%ebp),%eax
  801bb9:	e8 b7 fb ff ff       	call   801775 <getuint>
  801bbe:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801bc1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801bc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bc7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bcc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  801bd0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bd3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801bd6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  801bda:	77 09                	ja     801be5 <vprintfmt+0x419>
  801bdc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  801bdf:	0f 82 ac 00 00 00    	jb     801c91 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801be5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801be8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801bec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801bef:	83 ea 01             	sub    $0x1,%edx
  801bf2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801bf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bfa:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bfe:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801c02:	89 45 c0             	mov    %eax,-0x40(%ebp)
  801c05:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801c08:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801c0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c0f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c16:	00 
  801c17:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801c1a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801c1d:	89 0c 24             	mov    %ecx,(%esp)
  801c20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c24:	e8 97 08 00 00       	call   8024c0 <__udivdi3>
  801c29:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  801c2c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801c2f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c33:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c37:	89 04 24             	mov    %eax,(%esp)
  801c3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	e8 37 fa ff ff       	call   801680 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c50:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c54:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801c57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c5b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c62:	00 
  801c63:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801c66:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801c69:	89 14 24             	mov    %edx,(%esp)
  801c6c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c70:	e8 7b 09 00 00       	call   8025f0 <__umoddi3>
  801c75:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c79:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
  801c80:	89 04 24             	mov    %eax,(%esp)
  801c83:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801c86:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801c8a:	74 54                	je     801ce0 <vprintfmt+0x514>
  801c8c:	e9 67 fb ff ff       	jmp    8017f8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801c91:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801c95:	8d 76 00             	lea    0x0(%esi),%esi
  801c98:	0f 84 2a 01 00 00    	je     801dc8 <vprintfmt+0x5fc>
		while (--width > 0)
  801c9e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801ca1:	83 ef 01             	sub    $0x1,%edi
  801ca4:	85 ff                	test   %edi,%edi
  801ca6:	0f 8e 5e 01 00 00    	jle    801e0a <vprintfmt+0x63e>
  801cac:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  801caf:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801cb2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801cb5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801cb8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801cbb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  801cbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc2:	89 1c 24             	mov    %ebx,(%esp)
  801cc5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  801cc8:	83 ef 01             	sub    $0x1,%edi
  801ccb:	85 ff                	test   %edi,%edi
  801ccd:	7f ef                	jg     801cbe <vprintfmt+0x4f2>
  801ccf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801cd2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801cd5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801cd8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801cdb:	e9 2a 01 00 00       	jmp    801e0a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801ce0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801ce3:	83 eb 01             	sub    $0x1,%ebx
  801ce6:	85 db                	test   %ebx,%ebx
  801ce8:	0f 8e 0a fb ff ff    	jle    8017f8 <vprintfmt+0x2c>
  801cee:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801cf4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  801cf7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801d02:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801d04:	83 eb 01             	sub    $0x1,%ebx
  801d07:	85 db                	test   %ebx,%ebx
  801d09:	7f ec                	jg     801cf7 <vprintfmt+0x52b>
  801d0b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801d0e:	e9 e8 fa ff ff       	jmp    8017fb <vprintfmt+0x2f>
  801d13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801d16:	8b 45 14             	mov    0x14(%ebp),%eax
  801d19:	8d 50 04             	lea    0x4(%eax),%edx
  801d1c:	89 55 14             	mov    %edx,0x14(%ebp)
  801d1f:	8b 00                	mov    (%eax),%eax
  801d21:	85 c0                	test   %eax,%eax
  801d23:	75 2a                	jne    801d4f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801d25:	c7 44 24 0c a8 29 80 	movl   $0x8029a8,0xc(%esp)
  801d2c:	00 
  801d2d:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  801d34:	00 
  801d35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d38:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3f:	89 0c 24             	mov    %ecx,(%esp)
  801d42:	e8 90 01 00 00       	call   801ed7 <printfmt>
  801d47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d4a:	e9 ac fa ff ff       	jmp    8017fb <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  801d4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d52:	8b 13                	mov    (%ebx),%edx
  801d54:	83 fa 7f             	cmp    $0x7f,%edx
  801d57:	7e 29                	jle    801d82 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801d59:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  801d5b:	c7 44 24 0c e0 29 80 	movl   $0x8029e0,0xc(%esp)
  801d62:	00 
  801d63:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  801d6a:	00 
  801d6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	89 04 24             	mov    %eax,(%esp)
  801d75:	e8 5d 01 00 00       	call   801ed7 <printfmt>
  801d7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d7d:	e9 79 fa ff ff       	jmp    8017fb <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801d82:	88 10                	mov    %dl,(%eax)
  801d84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d87:	e9 6f fa ff ff       	jmp    8017fb <vprintfmt+0x2f>
  801d8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d95:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d99:	89 14 24             	mov    %edx,(%esp)
  801d9c:	ff 55 08             	call   *0x8(%ebp)
  801d9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801da2:	e9 54 fa ff ff       	jmp    8017fb <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801da7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801daa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801db5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801db8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801dbb:	80 38 25             	cmpb   $0x25,(%eax)
  801dbe:	0f 84 37 fa ff ff    	je     8017fb <vprintfmt+0x2f>
  801dc4:	89 c7                	mov    %eax,%edi
  801dc6:	eb f0                	jmp    801db8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcf:	8b 74 24 04          	mov    0x4(%esp),%esi
  801dd3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801dd6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dda:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801de1:	00 
  801de2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801de5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801de8:	89 04 24             	mov    %eax,(%esp)
  801deb:	89 54 24 04          	mov    %edx,0x4(%esp)
  801def:	e8 fc 07 00 00       	call   8025f0 <__umoddi3>
  801df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df8:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
  801dff:	89 04 24             	mov    %eax,(%esp)
  801e02:	ff 55 08             	call   *0x8(%ebp)
  801e05:	e9 d6 fe ff ff       	jmp    801ce0 <vprintfmt+0x514>
  801e0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e11:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e15:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e1c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e23:	00 
  801e24:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801e27:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801e2a:	89 04 24             	mov    %eax,(%esp)
  801e2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e31:	e8 ba 07 00 00       	call   8025f0 <__umoddi3>
  801e36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3a:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
  801e41:	89 04 24             	mov    %eax,(%esp)
  801e44:	ff 55 08             	call   *0x8(%ebp)
  801e47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e4a:	e9 ac f9 ff ff       	jmp    8017fb <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801e4f:	83 c4 6c             	add    $0x6c,%esp
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5f                   	pop    %edi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 28             	sub    $0x28,%esp
  801e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e60:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801e63:	85 c0                	test   %eax,%eax
  801e65:	74 04                	je     801e6b <vsnprintf+0x14>
  801e67:	85 d2                	test   %edx,%edx
  801e69:	7f 07                	jg     801e72 <vsnprintf+0x1b>
  801e6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e70:	eb 3b                	jmp    801ead <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801e72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e75:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801e79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801e7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801e83:	8b 45 14             	mov    0x14(%ebp),%eax
  801e86:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e91:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801e94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e98:	c7 04 24 af 17 80 00 	movl   $0x8017af,(%esp)
  801e9f:	e8 28 f9 ff ff       	call   8017cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ea4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ea7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801eb5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801eb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecd:	89 04 24             	mov    %eax,(%esp)
  801ed0:	e8 82 ff ff ff       	call   801e57 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ed5:	c9                   	leave  
  801ed6:	c3                   	ret    

00801ed7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801edd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801ee0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ee4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef5:	89 04 24             	mov    %eax,(%esp)
  801ef8:	e8 cf f8 ff ff       	call   8017cc <vprintfmt>
	va_end(ap);
}
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    
	...

00801f00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801f06:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0b:	80 3a 00             	cmpb   $0x0,(%edx)
  801f0e:	74 09                	je     801f19 <strlen+0x19>
		n++;
  801f10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801f13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801f17:	75 f7                	jne    801f10 <strlen+0x10>
		n++;
	return n;
}
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    

00801f1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	53                   	push   %ebx
  801f1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801f25:	85 c9                	test   %ecx,%ecx
  801f27:	74 19                	je     801f42 <strnlen+0x27>
  801f29:	80 3b 00             	cmpb   $0x0,(%ebx)
  801f2c:	74 14                	je     801f42 <strnlen+0x27>
  801f2e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801f33:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801f36:	39 c8                	cmp    %ecx,%eax
  801f38:	74 0d                	je     801f47 <strnlen+0x2c>
  801f3a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801f3e:	75 f3                	jne    801f33 <strnlen+0x18>
  801f40:	eb 05                	jmp    801f47 <strnlen+0x2c>
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801f47:	5b                   	pop    %ebx
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	53                   	push   %ebx
  801f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f54:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801f59:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801f5d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801f60:	83 c2 01             	add    $0x1,%edx
  801f63:	84 c9                	test   %cl,%cl
  801f65:	75 f2                	jne    801f59 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801f67:	5b                   	pop    %ebx
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	53                   	push   %ebx
  801f6e:	83 ec 08             	sub    $0x8,%esp
  801f71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801f74:	89 1c 24             	mov    %ebx,(%esp)
  801f77:	e8 84 ff ff ff       	call   801f00 <strlen>
	strcpy(dst + len, src);
  801f7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f7f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f83:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801f86:	89 04 24             	mov    %eax,(%esp)
  801f89:	e8 bc ff ff ff       	call   801f4a <strcpy>
	return dst;
}
  801f8e:	89 d8                	mov    %ebx,%eax
  801f90:	83 c4 08             	add    $0x8,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5d                   	pop    %ebp
  801f95:	c3                   	ret    

00801f96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fa1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801fa4:	85 f6                	test   %esi,%esi
  801fa6:	74 18                	je     801fc0 <strncpy+0x2a>
  801fa8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801fad:	0f b6 1a             	movzbl (%edx),%ebx
  801fb0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801fb3:	80 3a 01             	cmpb   $0x1,(%edx)
  801fb6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801fb9:	83 c1 01             	add    $0x1,%ecx
  801fbc:	39 ce                	cmp    %ecx,%esi
  801fbe:	77 ed                	ja     801fad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801fc0:	5b                   	pop    %ebx
  801fc1:	5e                   	pop    %esi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801fd2:	89 f0                	mov    %esi,%eax
  801fd4:	85 c9                	test   %ecx,%ecx
  801fd6:	74 27                	je     801fff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801fd8:	83 e9 01             	sub    $0x1,%ecx
  801fdb:	74 1d                	je     801ffa <strlcpy+0x36>
  801fdd:	0f b6 1a             	movzbl (%edx),%ebx
  801fe0:	84 db                	test   %bl,%bl
  801fe2:	74 16                	je     801ffa <strlcpy+0x36>
			*dst++ = *src++;
  801fe4:	88 18                	mov    %bl,(%eax)
  801fe6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801fe9:	83 e9 01             	sub    $0x1,%ecx
  801fec:	74 0e                	je     801ffc <strlcpy+0x38>
			*dst++ = *src++;
  801fee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ff1:	0f b6 1a             	movzbl (%edx),%ebx
  801ff4:	84 db                	test   %bl,%bl
  801ff6:	75 ec                	jne    801fe4 <strlcpy+0x20>
  801ff8:	eb 02                	jmp    801ffc <strlcpy+0x38>
  801ffa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ffc:	c6 00 00             	movb   $0x0,(%eax)
  801fff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802001:	5b                   	pop    %ebx
  802002:	5e                   	pop    %esi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80200b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80200e:	0f b6 01             	movzbl (%ecx),%eax
  802011:	84 c0                	test   %al,%al
  802013:	74 15                	je     80202a <strcmp+0x25>
  802015:	3a 02                	cmp    (%edx),%al
  802017:	75 11                	jne    80202a <strcmp+0x25>
		p++, q++;
  802019:	83 c1 01             	add    $0x1,%ecx
  80201c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80201f:	0f b6 01             	movzbl (%ecx),%eax
  802022:	84 c0                	test   %al,%al
  802024:	74 04                	je     80202a <strcmp+0x25>
  802026:	3a 02                	cmp    (%edx),%al
  802028:	74 ef                	je     802019 <strcmp+0x14>
  80202a:	0f b6 c0             	movzbl %al,%eax
  80202d:	0f b6 12             	movzbl (%edx),%edx
  802030:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	53                   	push   %ebx
  802038:	8b 55 08             	mov    0x8(%ebp),%edx
  80203b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80203e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  802041:	85 c0                	test   %eax,%eax
  802043:	74 23                	je     802068 <strncmp+0x34>
  802045:	0f b6 1a             	movzbl (%edx),%ebx
  802048:	84 db                	test   %bl,%bl
  80204a:	74 25                	je     802071 <strncmp+0x3d>
  80204c:	3a 19                	cmp    (%ecx),%bl
  80204e:	75 21                	jne    802071 <strncmp+0x3d>
  802050:	83 e8 01             	sub    $0x1,%eax
  802053:	74 13                	je     802068 <strncmp+0x34>
		n--, p++, q++;
  802055:	83 c2 01             	add    $0x1,%edx
  802058:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80205b:	0f b6 1a             	movzbl (%edx),%ebx
  80205e:	84 db                	test   %bl,%bl
  802060:	74 0f                	je     802071 <strncmp+0x3d>
  802062:	3a 19                	cmp    (%ecx),%bl
  802064:	74 ea                	je     802050 <strncmp+0x1c>
  802066:	eb 09                	jmp    802071 <strncmp+0x3d>
  802068:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80206d:	5b                   	pop    %ebx
  80206e:	5d                   	pop    %ebp
  80206f:	90                   	nop
  802070:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802071:	0f b6 02             	movzbl (%edx),%eax
  802074:	0f b6 11             	movzbl (%ecx),%edx
  802077:	29 d0                	sub    %edx,%eax
  802079:	eb f2                	jmp    80206d <strncmp+0x39>

0080207b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	8b 45 08             	mov    0x8(%ebp),%eax
  802081:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802085:	0f b6 10             	movzbl (%eax),%edx
  802088:	84 d2                	test   %dl,%dl
  80208a:	74 18                	je     8020a4 <strchr+0x29>
		if (*s == c)
  80208c:	38 ca                	cmp    %cl,%dl
  80208e:	75 0a                	jne    80209a <strchr+0x1f>
  802090:	eb 17                	jmp    8020a9 <strchr+0x2e>
  802092:	38 ca                	cmp    %cl,%dl
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	74 0f                	je     8020a9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80209a:	83 c0 01             	add    $0x1,%eax
  80209d:	0f b6 10             	movzbl (%eax),%edx
  8020a0:	84 d2                	test   %dl,%dl
  8020a2:	75 ee                	jne    802092 <strchr+0x17>
  8020a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020b5:	0f b6 10             	movzbl (%eax),%edx
  8020b8:	84 d2                	test   %dl,%dl
  8020ba:	74 18                	je     8020d4 <strfind+0x29>
		if (*s == c)
  8020bc:	38 ca                	cmp    %cl,%dl
  8020be:	75 0a                	jne    8020ca <strfind+0x1f>
  8020c0:	eb 12                	jmp    8020d4 <strfind+0x29>
  8020c2:	38 ca                	cmp    %cl,%dl
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	74 0a                	je     8020d4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8020ca:	83 c0 01             	add    $0x1,%eax
  8020cd:	0f b6 10             	movzbl (%eax),%edx
  8020d0:	84 d2                	test   %dl,%dl
  8020d2:	75 ee                	jne    8020c2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8020d4:	5d                   	pop    %ebp
  8020d5:	c3                   	ret    

008020d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	83 ec 0c             	sub    $0xc,%esp
  8020dc:	89 1c 24             	mov    %ebx,(%esp)
  8020df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8020e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8020f0:	85 c9                	test   %ecx,%ecx
  8020f2:	74 30                	je     802124 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8020f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8020fa:	75 25                	jne    802121 <memset+0x4b>
  8020fc:	f6 c1 03             	test   $0x3,%cl
  8020ff:	75 20                	jne    802121 <memset+0x4b>
		c &= 0xFF;
  802101:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802104:	89 d3                	mov    %edx,%ebx
  802106:	c1 e3 08             	shl    $0x8,%ebx
  802109:	89 d6                	mov    %edx,%esi
  80210b:	c1 e6 18             	shl    $0x18,%esi
  80210e:	89 d0                	mov    %edx,%eax
  802110:	c1 e0 10             	shl    $0x10,%eax
  802113:	09 f0                	or     %esi,%eax
  802115:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  802117:	09 d8                	or     %ebx,%eax
  802119:	c1 e9 02             	shr    $0x2,%ecx
  80211c:	fc                   	cld    
  80211d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80211f:	eb 03                	jmp    802124 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802121:	fc                   	cld    
  802122:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802124:	89 f8                	mov    %edi,%eax
  802126:	8b 1c 24             	mov    (%esp),%ebx
  802129:	8b 74 24 04          	mov    0x4(%esp),%esi
  80212d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802131:	89 ec                	mov    %ebp,%esp
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    

00802135 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	83 ec 08             	sub    $0x8,%esp
  80213b:	89 34 24             	mov    %esi,(%esp)
  80213e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802142:	8b 45 08             	mov    0x8(%ebp),%eax
  802145:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  802148:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80214b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80214d:	39 c6                	cmp    %eax,%esi
  80214f:	73 35                	jae    802186 <memmove+0x51>
  802151:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802154:	39 d0                	cmp    %edx,%eax
  802156:	73 2e                	jae    802186 <memmove+0x51>
		s += n;
		d += n;
  802158:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80215a:	f6 c2 03             	test   $0x3,%dl
  80215d:	75 1b                	jne    80217a <memmove+0x45>
  80215f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802165:	75 13                	jne    80217a <memmove+0x45>
  802167:	f6 c1 03             	test   $0x3,%cl
  80216a:	75 0e                	jne    80217a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80216c:	83 ef 04             	sub    $0x4,%edi
  80216f:	8d 72 fc             	lea    -0x4(%edx),%esi
  802172:	c1 e9 02             	shr    $0x2,%ecx
  802175:	fd                   	std    
  802176:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802178:	eb 09                	jmp    802183 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80217a:	83 ef 01             	sub    $0x1,%edi
  80217d:	8d 72 ff             	lea    -0x1(%edx),%esi
  802180:	fd                   	std    
  802181:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802183:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802184:	eb 20                	jmp    8021a6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802186:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80218c:	75 15                	jne    8021a3 <memmove+0x6e>
  80218e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802194:	75 0d                	jne    8021a3 <memmove+0x6e>
  802196:	f6 c1 03             	test   $0x3,%cl
  802199:	75 08                	jne    8021a3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80219b:	c1 e9 02             	shr    $0x2,%ecx
  80219e:	fc                   	cld    
  80219f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021a1:	eb 03                	jmp    8021a6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021a3:	fc                   	cld    
  8021a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021a6:	8b 34 24             	mov    (%esp),%esi
  8021a9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021ad:	89 ec                	mov    %ebp,%esp
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8021b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c8:	89 04 24             	mov    %eax,(%esp)
  8021cb:	e8 65 ff ff ff       	call   802135 <memmove>
}
  8021d0:	c9                   	leave  
  8021d1:	c3                   	ret    

008021d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8021d2:	55                   	push   %ebp
  8021d3:	89 e5                	mov    %esp,%ebp
  8021d5:	57                   	push   %edi
  8021d6:	56                   	push   %esi
  8021d7:	53                   	push   %ebx
  8021d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021db:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8021e1:	85 c9                	test   %ecx,%ecx
  8021e3:	74 36                	je     80221b <memcmp+0x49>
		if (*s1 != *s2)
  8021e5:	0f b6 06             	movzbl (%esi),%eax
  8021e8:	0f b6 1f             	movzbl (%edi),%ebx
  8021eb:	38 d8                	cmp    %bl,%al
  8021ed:	74 20                	je     80220f <memcmp+0x3d>
  8021ef:	eb 14                	jmp    802205 <memcmp+0x33>
  8021f1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8021f6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8021fb:	83 c2 01             	add    $0x1,%edx
  8021fe:	83 e9 01             	sub    $0x1,%ecx
  802201:	38 d8                	cmp    %bl,%al
  802203:	74 12                	je     802217 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  802205:	0f b6 c0             	movzbl %al,%eax
  802208:	0f b6 db             	movzbl %bl,%ebx
  80220b:	29 d8                	sub    %ebx,%eax
  80220d:	eb 11                	jmp    802220 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80220f:	83 e9 01             	sub    $0x1,%ecx
  802212:	ba 00 00 00 00       	mov    $0x0,%edx
  802217:	85 c9                	test   %ecx,%ecx
  802219:	75 d6                	jne    8021f1 <memcmp+0x1f>
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5f                   	pop    %edi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80222b:	89 c2                	mov    %eax,%edx
  80222d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802230:	39 d0                	cmp    %edx,%eax
  802232:	73 15                	jae    802249 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802234:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  802238:	38 08                	cmp    %cl,(%eax)
  80223a:	75 06                	jne    802242 <memfind+0x1d>
  80223c:	eb 0b                	jmp    802249 <memfind+0x24>
  80223e:	38 08                	cmp    %cl,(%eax)
  802240:	74 07                	je     802249 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802242:	83 c0 01             	add    $0x1,%eax
  802245:	39 c2                	cmp    %eax,%edx
  802247:	77 f5                	ja     80223e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    

0080224b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	57                   	push   %edi
  80224f:	56                   	push   %esi
  802250:	53                   	push   %ebx
  802251:	83 ec 04             	sub    $0x4,%esp
  802254:	8b 55 08             	mov    0x8(%ebp),%edx
  802257:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80225a:	0f b6 02             	movzbl (%edx),%eax
  80225d:	3c 20                	cmp    $0x20,%al
  80225f:	74 04                	je     802265 <strtol+0x1a>
  802261:	3c 09                	cmp    $0x9,%al
  802263:	75 0e                	jne    802273 <strtol+0x28>
		s++;
  802265:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802268:	0f b6 02             	movzbl (%edx),%eax
  80226b:	3c 20                	cmp    $0x20,%al
  80226d:	74 f6                	je     802265 <strtol+0x1a>
  80226f:	3c 09                	cmp    $0x9,%al
  802271:	74 f2                	je     802265 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  802273:	3c 2b                	cmp    $0x2b,%al
  802275:	75 0c                	jne    802283 <strtol+0x38>
		s++;
  802277:	83 c2 01             	add    $0x1,%edx
  80227a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802281:	eb 15                	jmp    802298 <strtol+0x4d>
	else if (*s == '-')
  802283:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80228a:	3c 2d                	cmp    $0x2d,%al
  80228c:	75 0a                	jne    802298 <strtol+0x4d>
		s++, neg = 1;
  80228e:	83 c2 01             	add    $0x1,%edx
  802291:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802298:	85 db                	test   %ebx,%ebx
  80229a:	0f 94 c0             	sete   %al
  80229d:	74 05                	je     8022a4 <strtol+0x59>
  80229f:	83 fb 10             	cmp    $0x10,%ebx
  8022a2:	75 18                	jne    8022bc <strtol+0x71>
  8022a4:	80 3a 30             	cmpb   $0x30,(%edx)
  8022a7:	75 13                	jne    8022bc <strtol+0x71>
  8022a9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	75 0a                	jne    8022bc <strtol+0x71>
		s += 2, base = 16;
  8022b2:	83 c2 02             	add    $0x2,%edx
  8022b5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022ba:	eb 15                	jmp    8022d1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022bc:	84 c0                	test   %al,%al
  8022be:	66 90                	xchg   %ax,%ax
  8022c0:	74 0f                	je     8022d1 <strtol+0x86>
  8022c2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8022c7:	80 3a 30             	cmpb   $0x30,(%edx)
  8022ca:	75 05                	jne    8022d1 <strtol+0x86>
		s++, base = 8;
  8022cc:	83 c2 01             	add    $0x1,%edx
  8022cf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022d8:	0f b6 0a             	movzbl (%edx),%ecx
  8022db:	89 cf                	mov    %ecx,%edi
  8022dd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8022e0:	80 fb 09             	cmp    $0x9,%bl
  8022e3:	77 08                	ja     8022ed <strtol+0xa2>
			dig = *s - '0';
  8022e5:	0f be c9             	movsbl %cl,%ecx
  8022e8:	83 e9 30             	sub    $0x30,%ecx
  8022eb:	eb 1e                	jmp    80230b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8022ed:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8022f0:	80 fb 19             	cmp    $0x19,%bl
  8022f3:	77 08                	ja     8022fd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8022f5:	0f be c9             	movsbl %cl,%ecx
  8022f8:	83 e9 57             	sub    $0x57,%ecx
  8022fb:	eb 0e                	jmp    80230b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8022fd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  802300:	80 fb 19             	cmp    $0x19,%bl
  802303:	77 15                	ja     80231a <strtol+0xcf>
			dig = *s - 'A' + 10;
  802305:	0f be c9             	movsbl %cl,%ecx
  802308:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80230b:	39 f1                	cmp    %esi,%ecx
  80230d:	7d 0b                	jge    80231a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80230f:	83 c2 01             	add    $0x1,%edx
  802312:	0f af c6             	imul   %esi,%eax
  802315:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  802318:	eb be                	jmp    8022d8 <strtol+0x8d>
  80231a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80231c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802320:	74 05                	je     802327 <strtol+0xdc>
		*endptr = (char *) s;
  802322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802325:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802327:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80232b:	74 04                	je     802331 <strtol+0xe6>
  80232d:	89 c8                	mov    %ecx,%eax
  80232f:	f7 d8                	neg    %eax
}
  802331:	83 c4 04             	add    $0x4,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	00 00                	add    %al,(%eax)
  80233b:	00 00                	add    %al,(%eax)
  80233d:	00 00                	add    %al,(%eax)
	...

00802340 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802346:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80234c:	b8 01 00 00 00       	mov    $0x1,%eax
  802351:	39 ca                	cmp    %ecx,%edx
  802353:	75 04                	jne    802359 <ipc_find_env+0x19>
  802355:	b0 00                	mov    $0x0,%al
  802357:	eb 12                	jmp    80236b <ipc_find_env+0x2b>
  802359:	89 c2                	mov    %eax,%edx
  80235b:	c1 e2 07             	shl    $0x7,%edx
  80235e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  802365:	8b 12                	mov    (%edx),%edx
  802367:	39 ca                	cmp    %ecx,%edx
  802369:	75 10                	jne    80237b <ipc_find_env+0x3b>
			return envs[i].env_id;
  80236b:	89 c2                	mov    %eax,%edx
  80236d:	c1 e2 07             	shl    $0x7,%edx
  802370:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  802377:	8b 00                	mov    (%eax),%eax
  802379:	eb 0e                	jmp    802389 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80237b:	83 c0 01             	add    $0x1,%eax
  80237e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802383:	75 d4                	jne    802359 <ipc_find_env+0x19>
  802385:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    

0080238b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
  80238e:	57                   	push   %edi
  80238f:	56                   	push   %esi
  802390:	53                   	push   %ebx
  802391:	83 ec 1c             	sub    $0x1c,%esp
  802394:	8b 75 08             	mov    0x8(%ebp),%esi
  802397:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80239a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  80239d:	85 db                	test   %ebx,%ebx
  80239f:	74 19                	je     8023ba <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  8023a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8023a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023b0:	89 34 24             	mov    %esi,(%esp)
  8023b3:	e8 d9 df ff ff       	call   800391 <sys_ipc_try_send>
  8023b8:	eb 1b                	jmp    8023d5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  8023ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8023bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023c1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8023c8:	ee 
  8023c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023cd:	89 34 24             	mov    %esi,(%esp)
  8023d0:	e8 bc df ff ff       	call   800391 <sys_ipc_try_send>
           if(ret == 0)
  8023d5:	85 c0                	test   %eax,%eax
  8023d7:	74 28                	je     802401 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  8023d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023dc:	74 1c                	je     8023fa <ipc_send+0x6f>
              panic("ipc send error");
  8023de:	c7 44 24 08 00 2c 80 	movl   $0x802c00,0x8(%esp)
  8023e5:	00 
  8023e6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  8023ed:	00 
  8023ee:	c7 04 24 0f 2c 80 00 	movl   $0x802c0f,(%esp)
  8023f5:	e8 6a f1 ff ff       	call   801564 <_panic>
           sys_yield();
  8023fa:	e8 5e e2 ff ff       	call   80065d <sys_yield>
        }
  8023ff:	eb 9c                	jmp    80239d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802401:	83 c4 1c             	add    $0x1c,%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    

00802409 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	56                   	push   %esi
  80240d:	53                   	push   %ebx
  80240e:	83 ec 10             	sub    $0x10,%esp
  802411:	8b 75 08             	mov    0x8(%ebp),%esi
  802414:	8b 45 0c             	mov    0xc(%ebp),%eax
  802417:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  80241a:	85 c0                	test   %eax,%eax
  80241c:	75 0e                	jne    80242c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  80241e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802425:	e8 fc de ff ff       	call   800326 <sys_ipc_recv>
  80242a:	eb 08                	jmp    802434 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  80242c:	89 04 24             	mov    %eax,(%esp)
  80242f:	e8 f2 de ff ff       	call   800326 <sys_ipc_recv>
        if(ret == 0){
  802434:	85 c0                	test   %eax,%eax
  802436:	75 26                	jne    80245e <ipc_recv+0x55>
           if(from_env_store)
  802438:	85 f6                	test   %esi,%esi
  80243a:	74 0a                	je     802446 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  80243c:	a1 08 40 80 00       	mov    0x804008,%eax
  802441:	8b 40 78             	mov    0x78(%eax),%eax
  802444:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  802446:	85 db                	test   %ebx,%ebx
  802448:	74 0a                	je     802454 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  80244a:	a1 08 40 80 00       	mov    0x804008,%eax
  80244f:	8b 40 7c             	mov    0x7c(%eax),%eax
  802452:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  802454:	a1 08 40 80 00       	mov    0x804008,%eax
  802459:	8b 40 74             	mov    0x74(%eax),%eax
  80245c:	eb 14                	jmp    802472 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  80245e:	85 f6                	test   %esi,%esi
  802460:	74 06                	je     802468 <ipc_recv+0x5f>
              *from_env_store = 0;
  802462:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  802468:	85 db                	test   %ebx,%ebx
  80246a:	74 06                	je     802472 <ipc_recv+0x69>
              *perm_store = 0;
  80246c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	5b                   	pop    %ebx
  802476:	5e                   	pop    %esi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    
  802479:	00 00                	add    %al,(%eax)
	...

0080247c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80247f:	8b 45 08             	mov    0x8(%ebp),%eax
  802482:	89 c2                	mov    %eax,%edx
  802484:	c1 ea 16             	shr    $0x16,%edx
  802487:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80248e:	f6 c2 01             	test   $0x1,%dl
  802491:	74 20                	je     8024b3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802493:	c1 e8 0c             	shr    $0xc,%eax
  802496:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80249d:	a8 01                	test   $0x1,%al
  80249f:	74 12                	je     8024b3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024a1:	c1 e8 0c             	shr    $0xc,%eax
  8024a4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8024a9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8024ae:	0f b7 c0             	movzwl %ax,%eax
  8024b1:	eb 05                	jmp    8024b8 <pageref+0x3c>
  8024b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024b8:	5d                   	pop    %ebp
  8024b9:	c3                   	ret    
  8024ba:	00 00                	add    %al,(%eax)
  8024bc:	00 00                	add    %al,(%eax)
	...

008024c0 <__udivdi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	57                   	push   %edi
  8024c4:	56                   	push   %esi
  8024c5:	83 ec 10             	sub    $0x10,%esp
  8024c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8024cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8024ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8024d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024d4:	85 c0                	test   %eax,%eax
  8024d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8024d9:	75 35                	jne    802510 <__udivdi3+0x50>
  8024db:	39 fe                	cmp    %edi,%esi
  8024dd:	77 61                	ja     802540 <__udivdi3+0x80>
  8024df:	85 f6                	test   %esi,%esi
  8024e1:	75 0b                	jne    8024ee <__udivdi3+0x2e>
  8024e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	f7 f6                	div    %esi
  8024ec:	89 c6                	mov    %eax,%esi
  8024ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8024f1:	31 d2                	xor    %edx,%edx
  8024f3:	89 f8                	mov    %edi,%eax
  8024f5:	f7 f6                	div    %esi
  8024f7:	89 c7                	mov    %eax,%edi
  8024f9:	89 c8                	mov    %ecx,%eax
  8024fb:	f7 f6                	div    %esi
  8024fd:	89 c1                	mov    %eax,%ecx
  8024ff:	89 fa                	mov    %edi,%edx
  802501:	89 c8                	mov    %ecx,%eax
  802503:	83 c4 10             	add    $0x10,%esp
  802506:	5e                   	pop    %esi
  802507:	5f                   	pop    %edi
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    
  80250a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802510:	39 f8                	cmp    %edi,%eax
  802512:	77 1c                	ja     802530 <__udivdi3+0x70>
  802514:	0f bd d0             	bsr    %eax,%edx
  802517:	83 f2 1f             	xor    $0x1f,%edx
  80251a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80251d:	75 39                	jne    802558 <__udivdi3+0x98>
  80251f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802522:	0f 86 a0 00 00 00    	jbe    8025c8 <__udivdi3+0x108>
  802528:	39 f8                	cmp    %edi,%eax
  80252a:	0f 82 98 00 00 00    	jb     8025c8 <__udivdi3+0x108>
  802530:	31 ff                	xor    %edi,%edi
  802532:	31 c9                	xor    %ecx,%ecx
  802534:	89 c8                	mov    %ecx,%eax
  802536:	89 fa                	mov    %edi,%edx
  802538:	83 c4 10             	add    $0x10,%esp
  80253b:	5e                   	pop    %esi
  80253c:	5f                   	pop    %edi
  80253d:	5d                   	pop    %ebp
  80253e:	c3                   	ret    
  80253f:	90                   	nop
  802540:	89 d1                	mov    %edx,%ecx
  802542:	89 fa                	mov    %edi,%edx
  802544:	89 c8                	mov    %ecx,%eax
  802546:	31 ff                	xor    %edi,%edi
  802548:	f7 f6                	div    %esi
  80254a:	89 c1                	mov    %eax,%ecx
  80254c:	89 fa                	mov    %edi,%edx
  80254e:	89 c8                	mov    %ecx,%eax
  802550:	83 c4 10             	add    $0x10,%esp
  802553:	5e                   	pop    %esi
  802554:	5f                   	pop    %edi
  802555:	5d                   	pop    %ebp
  802556:	c3                   	ret    
  802557:	90                   	nop
  802558:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80255c:	89 f2                	mov    %esi,%edx
  80255e:	d3 e0                	shl    %cl,%eax
  802560:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802563:	b8 20 00 00 00       	mov    $0x20,%eax
  802568:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80256b:	89 c1                	mov    %eax,%ecx
  80256d:	d3 ea                	shr    %cl,%edx
  80256f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802573:	0b 55 ec             	or     -0x14(%ebp),%edx
  802576:	d3 e6                	shl    %cl,%esi
  802578:	89 c1                	mov    %eax,%ecx
  80257a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80257d:	89 fe                	mov    %edi,%esi
  80257f:	d3 ee                	shr    %cl,%esi
  802581:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802585:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802588:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80258b:	d3 e7                	shl    %cl,%edi
  80258d:	89 c1                	mov    %eax,%ecx
  80258f:	d3 ea                	shr    %cl,%edx
  802591:	09 d7                	or     %edx,%edi
  802593:	89 f2                	mov    %esi,%edx
  802595:	89 f8                	mov    %edi,%eax
  802597:	f7 75 ec             	divl   -0x14(%ebp)
  80259a:	89 d6                	mov    %edx,%esi
  80259c:	89 c7                	mov    %eax,%edi
  80259e:	f7 65 e8             	mull   -0x18(%ebp)
  8025a1:	39 d6                	cmp    %edx,%esi
  8025a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025a6:	72 30                	jb     8025d8 <__udivdi3+0x118>
  8025a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025af:	d3 e2                	shl    %cl,%edx
  8025b1:	39 c2                	cmp    %eax,%edx
  8025b3:	73 05                	jae    8025ba <__udivdi3+0xfa>
  8025b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8025b8:	74 1e                	je     8025d8 <__udivdi3+0x118>
  8025ba:	89 f9                	mov    %edi,%ecx
  8025bc:	31 ff                	xor    %edi,%edi
  8025be:	e9 71 ff ff ff       	jmp    802534 <__udivdi3+0x74>
  8025c3:	90                   	nop
  8025c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c8:	31 ff                	xor    %edi,%edi
  8025ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8025cf:	e9 60 ff ff ff       	jmp    802534 <__udivdi3+0x74>
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8025db:	31 ff                	xor    %edi,%edi
  8025dd:	89 c8                	mov    %ecx,%eax
  8025df:	89 fa                	mov    %edi,%edx
  8025e1:	83 c4 10             	add    $0x10,%esp
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
	...

008025f0 <__umoddi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	57                   	push   %edi
  8025f4:	56                   	push   %esi
  8025f5:	83 ec 20             	sub    $0x20,%esp
  8025f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8025fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  802601:	8b 75 0c             	mov    0xc(%ebp),%esi
  802604:	85 d2                	test   %edx,%edx
  802606:	89 c8                	mov    %ecx,%eax
  802608:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80260b:	75 13                	jne    802620 <__umoddi3+0x30>
  80260d:	39 f7                	cmp    %esi,%edi
  80260f:	76 3f                	jbe    802650 <__umoddi3+0x60>
  802611:	89 f2                	mov    %esi,%edx
  802613:	f7 f7                	div    %edi
  802615:	89 d0                	mov    %edx,%eax
  802617:	31 d2                	xor    %edx,%edx
  802619:	83 c4 20             	add    $0x20,%esp
  80261c:	5e                   	pop    %esi
  80261d:	5f                   	pop    %edi
  80261e:	5d                   	pop    %ebp
  80261f:	c3                   	ret    
  802620:	39 f2                	cmp    %esi,%edx
  802622:	77 4c                	ja     802670 <__umoddi3+0x80>
  802624:	0f bd ca             	bsr    %edx,%ecx
  802627:	83 f1 1f             	xor    $0x1f,%ecx
  80262a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80262d:	75 51                	jne    802680 <__umoddi3+0x90>
  80262f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802632:	0f 87 e0 00 00 00    	ja     802718 <__umoddi3+0x128>
  802638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80263b:	29 f8                	sub    %edi,%eax
  80263d:	19 d6                	sbb    %edx,%esi
  80263f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802645:	89 f2                	mov    %esi,%edx
  802647:	83 c4 20             	add    $0x20,%esp
  80264a:	5e                   	pop    %esi
  80264b:	5f                   	pop    %edi
  80264c:	5d                   	pop    %ebp
  80264d:	c3                   	ret    
  80264e:	66 90                	xchg   %ax,%ax
  802650:	85 ff                	test   %edi,%edi
  802652:	75 0b                	jne    80265f <__umoddi3+0x6f>
  802654:	b8 01 00 00 00       	mov    $0x1,%eax
  802659:	31 d2                	xor    %edx,%edx
  80265b:	f7 f7                	div    %edi
  80265d:	89 c7                	mov    %eax,%edi
  80265f:	89 f0                	mov    %esi,%eax
  802661:	31 d2                	xor    %edx,%edx
  802663:	f7 f7                	div    %edi
  802665:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802668:	f7 f7                	div    %edi
  80266a:	eb a9                	jmp    802615 <__umoddi3+0x25>
  80266c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802670:	89 c8                	mov    %ecx,%eax
  802672:	89 f2                	mov    %esi,%edx
  802674:	83 c4 20             	add    $0x20,%esp
  802677:	5e                   	pop    %esi
  802678:	5f                   	pop    %edi
  802679:	5d                   	pop    %ebp
  80267a:	c3                   	ret    
  80267b:	90                   	nop
  80267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802680:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802684:	d3 e2                	shl    %cl,%edx
  802686:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802689:	ba 20 00 00 00       	mov    $0x20,%edx
  80268e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802691:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802694:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802698:	89 fa                	mov    %edi,%edx
  80269a:	d3 ea                	shr    %cl,%edx
  80269c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8026a3:	d3 e7                	shl    %cl,%edi
  8026a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026ac:	89 f2                	mov    %esi,%edx
  8026ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8026b1:	89 c7                	mov    %eax,%edi
  8026b3:	d3 ea                	shr    %cl,%edx
  8026b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026bc:	89 c2                	mov    %eax,%edx
  8026be:	d3 e6                	shl    %cl,%esi
  8026c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026c4:	d3 ea                	shr    %cl,%edx
  8026c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026ca:	09 d6                	or     %edx,%esi
  8026cc:	89 f0                	mov    %esi,%eax
  8026ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8026d1:	d3 e7                	shl    %cl,%edi
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	f7 75 f4             	divl   -0xc(%ebp)
  8026d8:	89 d6                	mov    %edx,%esi
  8026da:	f7 65 e8             	mull   -0x18(%ebp)
  8026dd:	39 d6                	cmp    %edx,%esi
  8026df:	72 2b                	jb     80270c <__umoddi3+0x11c>
  8026e1:	39 c7                	cmp    %eax,%edi
  8026e3:	72 23                	jb     802708 <__umoddi3+0x118>
  8026e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026e9:	29 c7                	sub    %eax,%edi
  8026eb:	19 d6                	sbb    %edx,%esi
  8026ed:	89 f0                	mov    %esi,%eax
  8026ef:	89 f2                	mov    %esi,%edx
  8026f1:	d3 ef                	shr    %cl,%edi
  8026f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026f7:	d3 e0                	shl    %cl,%eax
  8026f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026fd:	09 f8                	or     %edi,%eax
  8026ff:	d3 ea                	shr    %cl,%edx
  802701:	83 c4 20             	add    $0x20,%esp
  802704:	5e                   	pop    %esi
  802705:	5f                   	pop    %edi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    
  802708:	39 d6                	cmp    %edx,%esi
  80270a:	75 d9                	jne    8026e5 <__umoddi3+0xf5>
  80270c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80270f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802712:	eb d1                	jmp    8026e5 <__umoddi3+0xf5>
  802714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802718:	39 f2                	cmp    %esi,%edx
  80271a:	0f 82 18 ff ff ff    	jb     802638 <__umoddi3+0x48>
  802720:	e9 1d ff ff ff       	jmp    802642 <__umoddi3+0x52>
