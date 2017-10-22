
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
  80003a:	c7 44 24 04 a0 06 80 	movl   $0x8006a0,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 97 02 00 00       	call   8002e5 <sys_env_set_pgfault_upcall>
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
  80006e:	e8 7f 05 00 00       	call   8005f2 <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	89 c2                	mov    %eax,%edx
  80007a:	c1 e2 07             	shl    $0x7,%edx
  80007d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800084:	a3 04 40 80 00       	mov    %eax,0x804004
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
  8000b6:	e8 f0 0a 00 00       	call   800bab <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 6b 05 00 00       	call   800632 <sys_env_destroy>
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

0080014b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
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
  800158:	b8 10 00 00 00       	mov    $0x10,%eax
  80015d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800160:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800166:	8b 55 08             	mov    0x8(%ebp),%edx
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
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800181:	8b 1c 24             	mov    (%esp),%ebx
  800184:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800188:	89 ec                	mov    %ebp,%esp
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 28             	sub    $0x28,%esp
  800192:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800195:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800198:	bb 00 00 00 00       	mov    $0x0,%ebx
  80019d:	b8 0f 00 00 00       	mov    $0xf,%eax
  8001a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	89 df                	mov    %ebx,%edi
  8001aa:	51                   	push   %ecx
  8001ab:	52                   	push   %edx
  8001ac:	53                   	push   %ebx
  8001ad:	54                   	push   %esp
  8001ae:	55                   	push   %ebp
  8001af:	56                   	push   %esi
  8001b0:	57                   	push   %edi
  8001b1:	54                   	push   %esp
  8001b2:	5d                   	pop    %ebp
  8001b3:	8d 35 bb 01 80 00    	lea    0x8001bb,%esi
  8001b9:	0f 34                	sysenter 
  8001bb:	5f                   	pop    %edi
  8001bc:	5e                   	pop    %esi
  8001bd:	5d                   	pop    %ebp
  8001be:	5c                   	pop    %esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5a                   	pop    %edx
  8001c1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	7e 28                	jle    8001ee <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ca:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8001d1:	00 
  8001d2:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  8001e9:	e8 a6 0d 00 00       	call   800f94 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8001ee:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001f4:	89 ec                	mov    %ebp,%esp
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
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
  800205:	b9 00 00 00 00       	mov    $0x0,%ecx
  80020a:	b8 11 00 00 00       	mov    $0x11,%eax
  80020f:	8b 55 08             	mov    0x8(%ebp),%edx
  800212:	89 cb                	mov    %ecx,%ebx
  800214:	89 cf                	mov    %ecx,%edi
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

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80022e:	8b 1c 24             	mov    (%esp),%ebx
  800231:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800235:	89 ec                	mov    %ebp,%esp
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
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
  800245:	b9 00 00 00 00       	mov    $0x0,%ecx
  80024a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	89 cb                	mov    %ecx,%ebx
  800254:	89 cf                	mov    %ecx,%edi
  800256:	51                   	push   %ecx
  800257:	52                   	push   %edx
  800258:	53                   	push   %ebx
  800259:	54                   	push   %esp
  80025a:	55                   	push   %ebp
  80025b:	56                   	push   %esi
  80025c:	57                   	push   %edi
  80025d:	54                   	push   %esp
  80025e:	5d                   	pop    %ebp
  80025f:	8d 35 67 02 80 00    	lea    0x800267,%esi
  800265:	0f 34                	sysenter 
  800267:	5f                   	pop    %edi
  800268:	5e                   	pop    %esi
  800269:	5d                   	pop    %ebp
  80026a:	5c                   	pop    %esp
  80026b:	5b                   	pop    %ebx
  80026c:	5a                   	pop    %edx
  80026d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80026e:	85 c0                	test   %eax,%eax
  800270:	7e 28                	jle    80029a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800272:	89 44 24 10          	mov    %eax,0x10(%esp)
  800276:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80027d:	00 
  80027e:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  800285:	00 
  800286:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80028d:	00 
  80028e:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  800295:	e8 fa 0c 00 00       	call   800f94 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80029a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80029d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002a0:	89 ec                	mov    %ebp,%esp
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    

008002a4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	89 1c 24             	mov    %ebx,(%esp)
  8002ad:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
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

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002da:	8b 1c 24             	mov    (%esp),%ebx
  8002dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002e1:	89 ec                	mov    %ebp,%esp
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 28             	sub    $0x28,%esp
  8002eb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002ee:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80031b:	85 c0                	test   %eax,%eax
  80031d:	7e 28                	jle    800347 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80031f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800323:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80032a:	00 
  80032b:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  800332:	00 
  800333:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80033a:	00 
  80033b:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  800342:	e8 4d 0c 00 00       	call   800f94 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800347:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80034a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80034d:	89 ec                	mov    %ebp,%esp
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 28             	sub    $0x28,%esp
  800357:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80035a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80035d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800362:	b8 0a 00 00 00       	mov    $0xa,%eax
  800367:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036a:	8b 55 08             	mov    0x8(%ebp),%edx
  80036d:	89 df                	mov    %ebx,%edi
  80036f:	51                   	push   %ecx
  800370:	52                   	push   %edx
  800371:	53                   	push   %ebx
  800372:	54                   	push   %esp
  800373:	55                   	push   %ebp
  800374:	56                   	push   %esi
  800375:	57                   	push   %edi
  800376:	54                   	push   %esp
  800377:	5d                   	pop    %ebp
  800378:	8d 35 80 03 80 00    	lea    0x800380,%esi
  80037e:	0f 34                	sysenter 
  800380:	5f                   	pop    %edi
  800381:	5e                   	pop    %esi
  800382:	5d                   	pop    %ebp
  800383:	5c                   	pop    %esp
  800384:	5b                   	pop    %ebx
  800385:	5a                   	pop    %edx
  800386:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800387:	85 c0                	test   %eax,%eax
  800389:	7e 28                	jle    8003b3 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80038f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800396:	00 
  800397:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  80039e:	00 
  80039f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8003a6:	00 
  8003a7:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  8003ae:	e8 e1 0b 00 00       	call   800f94 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003b3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003b9:	89 ec                	mov    %ebp,%esp
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	83 ec 28             	sub    $0x28,%esp
  8003c3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003c6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ce:	b8 09 00 00 00       	mov    $0x9,%eax
  8003d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d9:	89 df                	mov    %ebx,%edi
  8003db:	51                   	push   %ecx
  8003dc:	52                   	push   %edx
  8003dd:	53                   	push   %ebx
  8003de:	54                   	push   %esp
  8003df:	55                   	push   %ebp
  8003e0:	56                   	push   %esi
  8003e1:	57                   	push   %edi
  8003e2:	54                   	push   %esp
  8003e3:	5d                   	pop    %ebp
  8003e4:	8d 35 ec 03 80 00    	lea    0x8003ec,%esi
  8003ea:	0f 34                	sysenter 
  8003ec:	5f                   	pop    %edi
  8003ed:	5e                   	pop    %esi
  8003ee:	5d                   	pop    %ebp
  8003ef:	5c                   	pop    %esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5a                   	pop    %edx
  8003f2:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	7e 28                	jle    80041f <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003fb:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800402:	00 
  800403:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  80040a:	00 
  80040b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800412:	00 
  800413:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  80041a:	e8 75 0b 00 00       	call   800f94 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80041f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800422:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800425:	89 ec                	mov    %ebp,%esp
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 28             	sub    $0x28,%esp
  80042f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800432:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800435:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043a:	b8 07 00 00 00       	mov    $0x7,%eax
  80043f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800442:	8b 55 08             	mov    0x8(%ebp),%edx
  800445:	89 df                	mov    %ebx,%edi
  800447:	51                   	push   %ecx
  800448:	52                   	push   %edx
  800449:	53                   	push   %ebx
  80044a:	54                   	push   %esp
  80044b:	55                   	push   %ebp
  80044c:	56                   	push   %esi
  80044d:	57                   	push   %edi
  80044e:	54                   	push   %esp
  80044f:	5d                   	pop    %ebp
  800450:	8d 35 58 04 80 00    	lea    0x800458,%esi
  800456:	0f 34                	sysenter 
  800458:	5f                   	pop    %edi
  800459:	5e                   	pop    %esi
  80045a:	5d                   	pop    %ebp
  80045b:	5c                   	pop    %esp
  80045c:	5b                   	pop    %ebx
  80045d:	5a                   	pop    %edx
  80045e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80045f:	85 c0                	test   %eax,%eax
  800461:	7e 28                	jle    80048b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800463:	89 44 24 10          	mov    %eax,0x10(%esp)
  800467:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80046e:	00 
  80046f:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  800476:	00 
  800477:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80047e:	00 
  80047f:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  800486:	e8 09 0b 00 00       	call   800f94 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80048b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80048e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800491:	89 ec                	mov    %ebp,%esp
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    

00800495 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	83 ec 28             	sub    $0x28,%esp
  80049b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80049e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004a1:	8b 7d 18             	mov    0x18(%ebp),%edi
  8004a4:	0b 7d 14             	or     0x14(%ebp),%edi
  8004a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8004ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b5:	51                   	push   %ecx
  8004b6:	52                   	push   %edx
  8004b7:	53                   	push   %ebx
  8004b8:	54                   	push   %esp
  8004b9:	55                   	push   %ebp
  8004ba:	56                   	push   %esi
  8004bb:	57                   	push   %edi
  8004bc:	54                   	push   %esp
  8004bd:	5d                   	pop    %ebp
  8004be:	8d 35 c6 04 80 00    	lea    0x8004c6,%esi
  8004c4:	0f 34                	sysenter 
  8004c6:	5f                   	pop    %edi
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	5c                   	pop    %esp
  8004ca:	5b                   	pop    %ebx
  8004cb:	5a                   	pop    %edx
  8004cc:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	7e 28                	jle    8004f9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004d5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8004dc:	00 
  8004dd:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  8004e4:	00 
  8004e5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004ec:	00 
  8004ed:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  8004f4:	e8 9b 0a 00 00       	call   800f94 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8004f9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004ff:	89 ec                	mov    %ebp,%esp
  800501:	5d                   	pop    %ebp
  800502:	c3                   	ret    

00800503 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	83 ec 28             	sub    $0x28,%esp
  800509:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80050c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80050f:	bf 00 00 00 00       	mov    $0x0,%edi
  800514:	b8 05 00 00 00       	mov    $0x5,%eax
  800519:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80051c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80051f:	8b 55 08             	mov    0x8(%ebp),%edx
  800522:	51                   	push   %ecx
  800523:	52                   	push   %edx
  800524:	53                   	push   %ebx
  800525:	54                   	push   %esp
  800526:	55                   	push   %ebp
  800527:	56                   	push   %esi
  800528:	57                   	push   %edi
  800529:	54                   	push   %esp
  80052a:	5d                   	pop    %ebp
  80052b:	8d 35 33 05 80 00    	lea    0x800533,%esi
  800531:	0f 34                	sysenter 
  800533:	5f                   	pop    %edi
  800534:	5e                   	pop    %esi
  800535:	5d                   	pop    %ebp
  800536:	5c                   	pop    %esp
  800537:	5b                   	pop    %ebx
  800538:	5a                   	pop    %edx
  800539:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80053a:	85 c0                	test   %eax,%eax
  80053c:	7e 28                	jle    800566 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80053e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800542:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800549:	00 
  80054a:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  800551:	00 
  800552:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800559:	00 
  80055a:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  800561:	e8 2e 0a 00 00       	call   800f94 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800566:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800569:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80056c:	89 ec                	mov    %ebp,%esp
  80056e:	5d                   	pop    %ebp
  80056f:	c3                   	ret    

00800570 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	89 1c 24             	mov    %ebx,(%esp)
  800579:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80057d:	ba 00 00 00 00       	mov    $0x0,%edx
  800582:	b8 0c 00 00 00       	mov    $0xc,%eax
  800587:	89 d1                	mov    %edx,%ecx
  800589:	89 d3                	mov    %edx,%ebx
  80058b:	89 d7                	mov    %edx,%edi
  80058d:	51                   	push   %ecx
  80058e:	52                   	push   %edx
  80058f:	53                   	push   %ebx
  800590:	54                   	push   %esp
  800591:	55                   	push   %ebp
  800592:	56                   	push   %esi
  800593:	57                   	push   %edi
  800594:	54                   	push   %esp
  800595:	5d                   	pop    %ebp
  800596:	8d 35 9e 05 80 00    	lea    0x80059e,%esi
  80059c:	0f 34                	sysenter 
  80059e:	5f                   	pop    %edi
  80059f:	5e                   	pop    %esi
  8005a0:	5d                   	pop    %ebp
  8005a1:	5c                   	pop    %esp
  8005a2:	5b                   	pop    %ebx
  8005a3:	5a                   	pop    %edx
  8005a4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8005a5:	8b 1c 24             	mov    (%esp),%ebx
  8005a8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005ac:	89 ec                	mov    %ebp,%esp
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	89 1c 24             	mov    %ebx,(%esp)
  8005b9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c2:	b8 04 00 00 00       	mov    $0x4,%eax
  8005c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	51                   	push   %ecx
  8005d0:	52                   	push   %edx
  8005d1:	53                   	push   %ebx
  8005d2:	54                   	push   %esp
  8005d3:	55                   	push   %ebp
  8005d4:	56                   	push   %esi
  8005d5:	57                   	push   %edi
  8005d6:	54                   	push   %esp
  8005d7:	5d                   	pop    %ebp
  8005d8:	8d 35 e0 05 80 00    	lea    0x8005e0,%esi
  8005de:	0f 34                	sysenter 
  8005e0:	5f                   	pop    %edi
  8005e1:	5e                   	pop    %esi
  8005e2:	5d                   	pop    %ebp
  8005e3:	5c                   	pop    %esp
  8005e4:	5b                   	pop    %ebx
  8005e5:	5a                   	pop    %edx
  8005e6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8005e7:	8b 1c 24             	mov    (%esp),%ebx
  8005ea:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005ee:	89 ec                	mov    %ebp,%esp
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	89 1c 24             	mov    %ebx,(%esp)
  8005fb:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800604:	b8 02 00 00 00       	mov    $0x2,%eax
  800609:	89 d1                	mov    %edx,%ecx
  80060b:	89 d3                	mov    %edx,%ebx
  80060d:	89 d7                	mov    %edx,%edi
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

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800627:	8b 1c 24             	mov    (%esp),%ebx
  80062a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80062e:	89 ec                	mov    %ebp,%esp
  800630:	5d                   	pop    %ebp
  800631:	c3                   	ret    

00800632 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	83 ec 28             	sub    $0x28,%esp
  800638:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80063b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80063e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800643:	b8 03 00 00 00       	mov    $0x3,%eax
  800648:	8b 55 08             	mov    0x8(%ebp),%edx
  80064b:	89 cb                	mov    %ecx,%ebx
  80064d:	89 cf                	mov    %ecx,%edi
  80064f:	51                   	push   %ecx
  800650:	52                   	push   %edx
  800651:	53                   	push   %ebx
  800652:	54                   	push   %esp
  800653:	55                   	push   %ebp
  800654:	56                   	push   %esi
  800655:	57                   	push   %edi
  800656:	54                   	push   %esp
  800657:	5d                   	pop    %ebp
  800658:	8d 35 60 06 80 00    	lea    0x800660,%esi
  80065e:	0f 34                	sysenter 
  800660:	5f                   	pop    %edi
  800661:	5e                   	pop    %esi
  800662:	5d                   	pop    %ebp
  800663:	5c                   	pop    %esp
  800664:	5b                   	pop    %ebx
  800665:	5a                   	pop    %edx
  800666:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800667:	85 c0                	test   %eax,%eax
  800669:	7e 28                	jle    800693 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80066b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80066f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800676:	00 
  800677:	c7 44 24 08 8a 21 80 	movl   $0x80218a,0x8(%esp)
  80067e:	00 
  80067f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800686:	00 
  800687:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  80068e:	e8 01 09 00 00       	call   800f94 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800693:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800696:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800699:	89 ec                	mov    %ebp,%esp
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    
  80069d:	00 00                	add    %al,(%eax)
	...

008006a0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8006a0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8006a1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8006a6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8006a8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 0x28(%esp),%eax
  8006ab:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 0x30(%esp),%ecx
  8006af:	8b 4c 24 30          	mov    0x30(%esp),%ecx
        subl $0x4,%ecx
  8006b3:	83 e9 04             	sub    $0x4,%ecx
        movl %eax,(%ecx)
  8006b6:	89 01                	mov    %eax,(%ecx)
        movl %ecx,0x30(%esp)
  8006b8:	89 4c 24 30          	mov    %ecx,0x30(%esp)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8,%esp
  8006bc:	83 c4 08             	add    $0x8,%esp
        popal
  8006bf:	61                   	popa   
        addl $0x4,%esp
  8006c0:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        popfl
  8006c3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8006c4:	5c                   	pop    %esp
        //subl $0x4,%esp   //CAN'T SUB HERE BECAUSE OF EFLAGS
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8006c5:	c3                   	ret    
	...

008006d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8006db:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8006de:	5d                   	pop    %ebp
  8006df:	c3                   	ret    

008006e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	89 04 24             	mov    %eax,(%esp)
  8006ec:	e8 df ff ff ff       	call   8006d0 <fd2num>
  8006f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8006f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	57                   	push   %edi
  8006ff:	56                   	push   %esi
  800700:	53                   	push   %ebx
  800701:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800704:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800709:	a8 01                	test   $0x1,%al
  80070b:	74 36                	je     800743 <fd_alloc+0x48>
  80070d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800712:	a8 01                	test   $0x1,%al
  800714:	74 2d                	je     800743 <fd_alloc+0x48>
  800716:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80071b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800720:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800725:	89 c3                	mov    %eax,%ebx
  800727:	89 c2                	mov    %eax,%edx
  800729:	c1 ea 16             	shr    $0x16,%edx
  80072c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80072f:	f6 c2 01             	test   $0x1,%dl
  800732:	74 14                	je     800748 <fd_alloc+0x4d>
  800734:	89 c2                	mov    %eax,%edx
  800736:	c1 ea 0c             	shr    $0xc,%edx
  800739:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80073c:	f6 c2 01             	test   $0x1,%dl
  80073f:	75 10                	jne    800751 <fd_alloc+0x56>
  800741:	eb 05                	jmp    800748 <fd_alloc+0x4d>
  800743:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800748:	89 1f                	mov    %ebx,(%edi)
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80074f:	eb 17                	jmp    800768 <fd_alloc+0x6d>
  800751:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800756:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80075b:	75 c8                	jne    800725 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80075d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800763:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800768:	5b                   	pop    %ebx
  800769:	5e                   	pop    %esi
  80076a:	5f                   	pop    %edi
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	83 f8 1f             	cmp    $0x1f,%eax
  800776:	77 36                	ja     8007ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800778:	05 00 00 0d 00       	add    $0xd0000,%eax
  80077d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800780:	89 c2                	mov    %eax,%edx
  800782:	c1 ea 16             	shr    $0x16,%edx
  800785:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80078c:	f6 c2 01             	test   $0x1,%dl
  80078f:	74 1d                	je     8007ae <fd_lookup+0x41>
  800791:	89 c2                	mov    %eax,%edx
  800793:	c1 ea 0c             	shr    $0xc,%edx
  800796:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80079d:	f6 c2 01             	test   $0x1,%dl
  8007a0:	74 0c                	je     8007ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a5:	89 02                	mov    %eax,(%edx)
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8007ac:	eb 05                	jmp    8007b3 <fd_lookup+0x46>
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	89 04 24             	mov    %eax,(%esp)
  8007c8:	e8 a0 ff ff ff       	call   80076d <fd_lookup>
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 0e                	js     8007df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8007d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d7:	89 50 04             	mov    %edx,0x4(%eax)
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	83 ec 10             	sub    $0x10,%esp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  8007ef:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8007f4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007f9:	be 34 22 80 00       	mov    $0x802234,%esi
		if (devtab[i]->dev_id == dev_id) {
  8007fe:	39 08                	cmp    %ecx,(%eax)
  800800:	75 10                	jne    800812 <dev_lookup+0x31>
  800802:	eb 04                	jmp    800808 <dev_lookup+0x27>
  800804:	39 08                	cmp    %ecx,(%eax)
  800806:	75 0a                	jne    800812 <dev_lookup+0x31>
			*dev = devtab[i];
  800808:	89 03                	mov    %eax,(%ebx)
  80080a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80080f:	90                   	nop
  800810:	eb 31                	jmp    800843 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800812:	83 c2 01             	add    $0x1,%edx
  800815:	8b 04 96             	mov    (%esi,%edx,4),%eax
  800818:	85 c0                	test   %eax,%eax
  80081a:	75 e8                	jne    800804 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80081c:	a1 04 40 80 00       	mov    0x804004,%eax
  800821:	8b 40 48             	mov    0x48(%eax),%eax
  800824:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082c:	c7 04 24 b8 21 80 00 	movl   $0x8021b8,(%esp)
  800833:	e8 15 08 00 00       	call   80104d <cprintf>
	*dev = 0;
  800838:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80083e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	83 ec 24             	sub    $0x24,%esp
  800851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800854:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	89 04 24             	mov    %eax,(%esp)
  800861:	e8 07 ff ff ff       	call   80076d <fd_lookup>
  800866:	85 c0                	test   %eax,%eax
  800868:	78 53                	js     8008bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	8b 00                	mov    (%eax),%eax
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	e8 63 ff ff ff       	call   8007e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 3b                	js     8008bd <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800882:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800887:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80088a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80088e:	74 2d                	je     8008bd <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800890:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800893:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80089a:	00 00 00 
	stat->st_isdir = 0;
  80089d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a4:	00 00 00 
	stat->st_dev = dev;
  8008a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008aa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008b7:	89 14 24             	mov    %edx,(%esp)
  8008ba:	ff 50 14             	call   *0x14(%eax)
}
  8008bd:	83 c4 24             	add    $0x24,%esp
  8008c0:	5b                   	pop    %ebx
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	83 ec 24             	sub    $0x24,%esp
  8008ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d4:	89 1c 24             	mov    %ebx,(%esp)
  8008d7:	e8 91 fe ff ff       	call   80076d <fd_lookup>
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	78 5f                	js     80093f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ea:	8b 00                	mov    (%eax),%eax
  8008ec:	89 04 24             	mov    %eax,(%esp)
  8008ef:	e8 ed fe ff ff       	call   8007e1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008f4:	85 c0                	test   %eax,%eax
  8008f6:	78 47                	js     80093f <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008fb:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8008ff:	75 23                	jne    800924 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800901:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800906:	8b 40 48             	mov    0x48(%eax),%eax
  800909:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80090d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800911:	c7 04 24 d8 21 80 00 	movl   $0x8021d8,(%esp)
  800918:	e8 30 07 00 00       	call   80104d <cprintf>
  80091d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800922:	eb 1b                	jmp    80093f <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800927:	8b 48 18             	mov    0x18(%eax),%ecx
  80092a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80092f:	85 c9                	test   %ecx,%ecx
  800931:	74 0c                	je     80093f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	89 14 24             	mov    %edx,(%esp)
  80093d:	ff d1                	call   *%ecx
}
  80093f:	83 c4 24             	add    $0x24,%esp
  800942:	5b                   	pop    %ebx
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	53                   	push   %ebx
  800949:	83 ec 24             	sub    $0x24,%esp
  80094c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80094f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800952:	89 44 24 04          	mov    %eax,0x4(%esp)
  800956:	89 1c 24             	mov    %ebx,(%esp)
  800959:	e8 0f fe ff ff       	call   80076d <fd_lookup>
  80095e:	85 c0                	test   %eax,%eax
  800960:	78 66                	js     8009c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096c:	8b 00                	mov    (%eax),%eax
  80096e:	89 04 24             	mov    %eax,(%esp)
  800971:	e8 6b fe ff ff       	call   8007e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800976:	85 c0                	test   %eax,%eax
  800978:	78 4e                	js     8009c8 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80097a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80097d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800981:	75 23                	jne    8009a6 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800983:	a1 04 40 80 00       	mov    0x804004,%eax
  800988:	8b 40 48             	mov    0x48(%eax),%eax
  80098b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80098f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800993:	c7 04 24 f9 21 80 00 	movl   $0x8021f9,(%esp)
  80099a:	e8 ae 06 00 00       	call   80104d <cprintf>
  80099f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8009a4:	eb 22                	jmp    8009c8 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8009a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a9:	8b 48 0c             	mov    0xc(%eax),%ecx
  8009ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8009b1:	85 c9                	test   %ecx,%ecx
  8009b3:	74 13                	je     8009c8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8009b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c3:	89 14 24             	mov    %edx,(%esp)
  8009c6:	ff d1                	call   *%ecx
}
  8009c8:	83 c4 24             	add    $0x24,%esp
  8009cb:	5b                   	pop    %ebx
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	83 ec 24             	sub    $0x24,%esp
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009df:	89 1c 24             	mov    %ebx,(%esp)
  8009e2:	e8 86 fd ff ff       	call   80076d <fd_lookup>
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	78 6b                	js     800a56 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f5:	8b 00                	mov    (%eax),%eax
  8009f7:	89 04 24             	mov    %eax,(%esp)
  8009fa:	e8 e2 fd ff ff       	call   8007e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009ff:	85 c0                	test   %eax,%eax
  800a01:	78 53                	js     800a56 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a03:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a06:	8b 42 08             	mov    0x8(%edx),%eax
  800a09:	83 e0 03             	and    $0x3,%eax
  800a0c:	83 f8 01             	cmp    $0x1,%eax
  800a0f:	75 23                	jne    800a34 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a11:	a1 04 40 80 00       	mov    0x804004,%eax
  800a16:	8b 40 48             	mov    0x48(%eax),%eax
  800a19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	c7 04 24 16 22 80 00 	movl   $0x802216,(%esp)
  800a28:	e8 20 06 00 00       	call   80104d <cprintf>
  800a2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800a32:	eb 22                	jmp    800a56 <read+0x88>
	}
	if (!dev->dev_read)
  800a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a37:	8b 48 08             	mov    0x8(%eax),%ecx
  800a3a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800a3f:	85 c9                	test   %ecx,%ecx
  800a41:	74 13                	je     800a56 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a43:	8b 45 10             	mov    0x10(%ebp),%eax
  800a46:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a51:	89 14 24             	mov    %edx,(%esp)
  800a54:	ff d1                	call   *%ecx
}
  800a56:	83 c4 24             	add    $0x24,%esp
  800a59:	5b                   	pop    %ebx
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	83 ec 1c             	sub    $0x1c,%esp
  800a65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a68:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	85 f6                	test   %esi,%esi
  800a7c:	74 29                	je     800aa7 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a7e:	89 f0                	mov    %esi,%eax
  800a80:	29 d0                	sub    %edx,%eax
  800a82:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a86:	03 55 0c             	add    0xc(%ebp),%edx
  800a89:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8d:	89 3c 24             	mov    %edi,(%esp)
  800a90:	e8 39 ff ff ff       	call   8009ce <read>
		if (m < 0)
  800a95:	85 c0                	test   %eax,%eax
  800a97:	78 0e                	js     800aa7 <readn+0x4b>
			return m;
		if (m == 0)
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	74 08                	je     800aa5 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a9d:	01 c3                	add    %eax,%ebx
  800a9f:	89 da                	mov    %ebx,%edx
  800aa1:	39 f3                	cmp    %esi,%ebx
  800aa3:	72 d9                	jb     800a7e <readn+0x22>
  800aa5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800aa7:	83 c4 1c             	add    $0x1c,%esp
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 20             	sub    $0x20,%esp
  800ab7:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800aba:	89 34 24             	mov    %esi,(%esp)
  800abd:	e8 0e fc ff ff       	call   8006d0 <fd2num>
  800ac2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ac5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac9:	89 04 24             	mov    %eax,(%esp)
  800acc:	e8 9c fc ff ff       	call   80076d <fd_lookup>
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 05                	js     800adc <fd_close+0x2d>
  800ad7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ada:	74 0c                	je     800ae8 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800adc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800ae0:	19 c0                	sbb    %eax,%eax
  800ae2:	f7 d0                	not    %eax
  800ae4:	21 c3                	and    %eax,%ebx
  800ae6:	eb 3d                	jmp    800b25 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ae8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aef:	8b 06                	mov    (%esi),%eax
  800af1:	89 04 24             	mov    %eax,(%esp)
  800af4:	e8 e8 fc ff ff       	call   8007e1 <dev_lookup>
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	85 c0                	test   %eax,%eax
  800afd:	78 16                	js     800b15 <fd_close+0x66>
		if (dev->dev_close)
  800aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b02:	8b 40 10             	mov    0x10(%eax),%eax
  800b05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	74 07                	je     800b15 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800b0e:	89 34 24             	mov    %esi,(%esp)
  800b11:	ff d0                	call   *%eax
  800b13:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800b15:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b20:	e8 04 f9 ff ff       	call   800429 <sys_page_unmap>
	return r;
}
  800b25:	89 d8                	mov    %ebx,%eax
  800b27:	83 c4 20             	add    $0x20,%esp
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	89 04 24             	mov    %eax,(%esp)
  800b41:	e8 27 fc ff ff       	call   80076d <fd_lookup>
  800b46:	85 c0                	test   %eax,%eax
  800b48:	78 13                	js     800b5d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800b4a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800b51:	00 
  800b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b55:	89 04 24             	mov    %eax,(%esp)
  800b58:	e8 52 ff ff ff       	call   800aaf <fd_close>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	83 ec 18             	sub    $0x18,%esp
  800b65:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b68:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b72:	00 
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	89 04 24             	mov    %eax,(%esp)
  800b79:	e8 79 03 00 00       	call   800ef7 <open>
  800b7e:	89 c3                	mov    %eax,%ebx
  800b80:	85 c0                	test   %eax,%eax
  800b82:	78 1b                	js     800b9f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8b:	89 1c 24             	mov    %ebx,(%esp)
  800b8e:	e8 b7 fc ff ff       	call   80084a <fstat>
  800b93:	89 c6                	mov    %eax,%esi
	close(fd);
  800b95:	89 1c 24             	mov    %ebx,(%esp)
  800b98:	e8 91 ff ff ff       	call   800b2e <close>
  800b9d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800b9f:	89 d8                	mov    %ebx,%eax
  800ba1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ba4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800ba7:	89 ec                	mov    %ebp,%esp
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	83 ec 14             	sub    $0x14,%esp
  800bb2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800bb7:	89 1c 24             	mov    %ebx,(%esp)
  800bba:	e8 6f ff ff ff       	call   800b2e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800bbf:	83 c3 01             	add    $0x1,%ebx
  800bc2:	83 fb 20             	cmp    $0x20,%ebx
  800bc5:	75 f0                	jne    800bb7 <close_all+0xc>
		close(i);
}
  800bc7:	83 c4 14             	add    $0x14,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	83 ec 58             	sub    $0x58,%esp
  800bd3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bd6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800bdc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800bdf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
  800be9:	89 04 24             	mov    %eax,(%esp)
  800bec:	e8 7c fb ff ff       	call   80076d <fd_lookup>
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	0f 88 e0 00 00 00    	js     800cdb <dup+0x10e>
		return r;
	close(newfdnum);
  800bfb:	89 3c 24             	mov    %edi,(%esp)
  800bfe:	e8 2b ff ff ff       	call   800b2e <close>

	newfd = INDEX2FD(newfdnum);
  800c03:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800c09:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0f:	89 04 24             	mov    %eax,(%esp)
  800c12:	e8 c9 fa ff ff       	call   8006e0 <fd2data>
  800c17:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800c19:	89 34 24             	mov    %esi,(%esp)
  800c1c:	e8 bf fa ff ff       	call   8006e0 <fd2data>
  800c21:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800c24:	89 da                	mov    %ebx,%edx
  800c26:	89 d8                	mov    %ebx,%eax
  800c28:	c1 e8 16             	shr    $0x16,%eax
  800c2b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800c32:	a8 01                	test   $0x1,%al
  800c34:	74 43                	je     800c79 <dup+0xac>
  800c36:	c1 ea 0c             	shr    $0xc,%edx
  800c39:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c40:	a8 01                	test   $0x1,%al
  800c42:	74 35                	je     800c79 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800c44:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800c4b:	25 07 0e 00 00       	and    $0xe07,%eax
  800c50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c62:	00 
  800c63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c6e:	e8 22 f8 ff ff       	call   800495 <sys_page_map>
  800c73:	89 c3                	mov    %eax,%ebx
  800c75:	85 c0                	test   %eax,%eax
  800c77:	78 3f                	js     800cb8 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c7c:	89 c2                	mov    %eax,%edx
  800c7e:	c1 ea 0c             	shr    $0xc,%edx
  800c81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800c88:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800c8e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c92:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c9d:	00 
  800c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ca9:	e8 e7 f7 ff ff       	call   800495 <sys_page_map>
  800cae:	89 c3                	mov    %eax,%ebx
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	78 04                	js     800cb8 <dup+0xeb>
  800cb4:	89 fb                	mov    %edi,%ebx
  800cb6:	eb 23                	jmp    800cdb <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800cb8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cc3:	e8 61 f7 ff ff       	call   800429 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800cc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ccf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cd6:	e8 4e f7 ff ff       	call   800429 <sys_page_unmap>
	return r;
}
  800cdb:	89 d8                	mov    %ebx,%eax
  800cdd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce6:	89 ec                	mov    %ebp,%esp
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    
	...

00800cec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 18             	sub    $0x18,%esp
  800cf2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800cf5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800cf8:	89 c3                	mov    %eax,%ebx
  800cfa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800cfc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d03:	75 11                	jne    800d16 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d05:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800d0c:	e8 af 10 00 00       	call   801dc0 <ipc_find_env>
  800d11:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d16:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800d25:	00 
  800d26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d2a:	a1 00 40 80 00       	mov    0x804000,%eax
  800d2f:	89 04 24             	mov    %eax,(%esp)
  800d32:	e8 d4 10 00 00       	call   801e0b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d3e:	00 
  800d3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d4a:	e8 3a 11 00 00       	call   801e89 <ipc_recv>
}
  800d4f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d52:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d55:	89 ec                	mov    %ebp,%esp
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	8b 40 0c             	mov    0xc(%eax),%eax
  800d65:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d72:	ba 00 00 00 00       	mov    $0x0,%edx
  800d77:	b8 02 00 00 00       	mov    $0x2,%eax
  800d7c:	e8 6b ff ff ff       	call   800cec <fsipc>
}
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    

00800d83 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	8b 40 0c             	mov    0xc(%eax),%eax
  800d8f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d94:	ba 00 00 00 00       	mov    $0x0,%edx
  800d99:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9e:	e8 49 ff ff ff       	call   800cec <fsipc>
}
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    

00800da5 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800dab:	ba 00 00 00 00       	mov    $0x0,%edx
  800db0:	b8 08 00 00 00       	mov    $0x8,%eax
  800db5:	e8 32 ff ff ff       	call   800cec <fsipc>
}
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    

00800dbc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 14             	sub    $0x14,%esp
  800dc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	8b 40 0c             	mov    0xc(%eax),%eax
  800dcc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800dd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddb:	e8 0c ff ff ff       	call   800cec <fsipc>
  800de0:	85 c0                	test   %eax,%eax
  800de2:	78 2b                	js     800e0f <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800de4:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800deb:	00 
  800dec:	89 1c 24             	mov    %ebx,(%esp)
  800def:	e8 86 0b 00 00       	call   80197a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800df4:	a1 80 50 80 00       	mov    0x805080,%eax
  800df9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dff:	a1 84 50 80 00       	mov    0x805084,%eax
  800e04:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800e0a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800e0f:	83 c4 14             	add    $0x14,%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 18             	sub    $0x18,%esp
  800e1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e23:	76 05                	jbe    800e2a <devfile_write+0x15>
  800e25:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	8b 52 0c             	mov    0xc(%edx),%edx
  800e30:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800e36:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800e3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e46:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800e4d:	e8 13 0d 00 00       	call   801b65 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800e52:	ba 00 00 00 00       	mov    $0x0,%edx
  800e57:	b8 04 00 00 00       	mov    $0x4,%eax
  800e5c:	e8 8b fe ff ff       	call   800cec <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800e61:	c9                   	leave  
  800e62:	c3                   	ret    

00800e63 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	53                   	push   %ebx
  800e67:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e70:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800e75:	8b 45 10             	mov    0x10(%ebp),%eax
  800e78:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  800e7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e82:	b8 03 00 00 00       	mov    $0x3,%eax
  800e87:	e8 60 fe ff ff       	call   800cec <fsipc>
  800e8c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 17                	js     800ea9 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800e92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e96:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800e9d:	00 
  800e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea1:	89 04 24             	mov    %eax,(%esp)
  800ea4:	e8 bc 0c 00 00       	call   801b65 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800ea9:	89 d8                	mov    %ebx,%eax
  800eab:	83 c4 14             	add    $0x14,%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 14             	sub    $0x14,%esp
  800eb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800ebb:	89 1c 24             	mov    %ebx,(%esp)
  800ebe:	e8 6d 0a 00 00       	call   801930 <strlen>
  800ec3:	89 c2                	mov    %eax,%edx
  800ec5:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800eca:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800ed0:	7f 1f                	jg     800ef1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800ed2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ed6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800edd:	e8 98 0a 00 00       	call   80197a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800ee2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee7:	b8 07 00 00 00       	mov    $0x7,%eax
  800eec:	e8 fb fd ff ff       	call   800cec <fsipc>
}
  800ef1:	83 c4 14             	add    $0x14,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 28             	sub    $0x28,%esp
  800efd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800f00:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800f03:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  800f06:	89 34 24             	mov    %esi,(%esp)
  800f09:	e8 22 0a 00 00       	call   801930 <strlen>
  800f0e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f13:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f18:	7f 6d                	jg     800f87 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  800f1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1d:	89 04 24             	mov    %eax,(%esp)
  800f20:	e8 d6 f7 ff ff       	call   8006fb <fd_alloc>
  800f25:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	78 5c                	js     800f87 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  800f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2e:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  800f33:	89 34 24             	mov    %esi,(%esp)
  800f36:	e8 f5 09 00 00       	call   801930 <strlen>
  800f3b:	83 c0 01             	add    $0x1,%eax
  800f3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f42:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f46:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800f4d:	e8 13 0c 00 00       	call   801b65 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  800f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f55:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5a:	e8 8d fd ff ff       	call   800cec <fsipc>
  800f5f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 15                	jns    800f7a <open+0x83>
             fd_close(fd,0);
  800f65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6c:	00 
  800f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f70:	89 04 24             	mov    %eax,(%esp)
  800f73:	e8 37 fb ff ff       	call   800aaf <fd_close>
             return r;
  800f78:	eb 0d                	jmp    800f87 <open+0x90>
        }
        return fd2num(fd);
  800f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7d:	89 04 24             	mov    %eax,(%esp)
  800f80:	e8 4b f7 ff ff       	call   8006d0 <fd2num>
  800f85:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  800f87:	89 d8                	mov    %ebx,%eax
  800f89:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f8c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800f8f:	89 ec                	mov    %ebp,%esp
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    
	...

00800f94 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f9c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f9f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800fa5:	e8 48 f6 ff ff       	call   8005f2 <sys_getenvid>
  800faa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fad:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fb8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc0:	c7 04 24 3c 22 80 00 	movl   $0x80223c,(%esp)
  800fc7:	e8 81 00 00 00       	call   80104d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fcc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd3:	89 04 24             	mov    %eax,(%esp)
  800fd6:	e8 11 00 00 00       	call   800fec <vcprintf>
	cprintf("\n");
  800fdb:	c7 04 24 30 22 80 00 	movl   $0x802230,(%esp)
  800fe2:	e8 66 00 00 00       	call   80104d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fe7:	cc                   	int3   
  800fe8:	eb fd                	jmp    800fe7 <_panic+0x53>
	...

00800fec <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800ff5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ffc:	00 00 00 
	b.cnt = 0;
  800fff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801006:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801010:	8b 45 08             	mov    0x8(%ebp),%eax
  801013:	89 44 24 08          	mov    %eax,0x8(%esp)
  801017:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80101d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801021:	c7 04 24 67 10 80 00 	movl   $0x801067,(%esp)
  801028:	e8 cf 01 00 00       	call   8011fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80102d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801033:	89 44 24 04          	mov    %eax,0x4(%esp)
  801037:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80103d:	89 04 24             	mov    %eax,(%esp)
  801040:	e8 c7 f0 ff ff       	call   80010c <sys_cputs>

	return b.cnt;
}
  801045:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801053:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801056:	89 44 24 04          	mov    %eax,0x4(%esp)
  80105a:	8b 45 08             	mov    0x8(%ebp),%eax
  80105d:	89 04 24             	mov    %eax,(%esp)
  801060:	e8 87 ff ff ff       	call   800fec <vcprintf>
	va_end(ap);

	return cnt;
}
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	53                   	push   %ebx
  80106b:	83 ec 14             	sub    $0x14,%esp
  80106e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801071:	8b 03                	mov    (%ebx),%eax
  801073:	8b 55 08             	mov    0x8(%ebp),%edx
  801076:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80107a:	83 c0 01             	add    $0x1,%eax
  80107d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80107f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801084:	75 19                	jne    80109f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801086:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80108d:	00 
  80108e:	8d 43 08             	lea    0x8(%ebx),%eax
  801091:	89 04 24             	mov    %eax,(%esp)
  801094:	e8 73 f0 ff ff       	call   80010c <sys_cputs>
		b->idx = 0;
  801099:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80109f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010a3:	83 c4 14             	add    $0x14,%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    
  8010a9:	00 00                	add    %al,(%eax)
  8010ab:	00 00                	add    %al,(%eax)
  8010ad:	00 00                	add    %al,(%eax)
	...

008010b0 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 4c             	sub    $0x4c,%esp
  8010b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010bc:	89 d6                	mov    %edx,%esi
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8010ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8010cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010d0:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  8010d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010db:	39 d1                	cmp    %edx,%ecx
  8010dd:	72 07                	jb     8010e6 <printnum_v2+0x36>
  8010df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8010e2:	39 d0                	cmp    %edx,%eax
  8010e4:	77 5f                	ja     801145 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8010e6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8010ea:	83 eb 01             	sub    $0x1,%ebx
  8010ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010f9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8010fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801100:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801103:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801106:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80110a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801111:	00 
  801112:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80111b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80111f:	e8 dc 0d 00 00       	call   801f00 <__udivdi3>
  801124:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801127:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80112a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80112e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801132:	89 04 24             	mov    %eax,(%esp)
  801135:	89 54 24 04          	mov    %edx,0x4(%esp)
  801139:	89 f2                	mov    %esi,%edx
  80113b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80113e:	e8 6d ff ff ff       	call   8010b0 <printnum_v2>
  801143:	eb 1e                	jmp    801163 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801145:	83 ff 2d             	cmp    $0x2d,%edi
  801148:	74 19                	je     801163 <printnum_v2+0xb3>
		while (--width > 0)
  80114a:	83 eb 01             	sub    $0x1,%ebx
  80114d:	85 db                	test   %ebx,%ebx
  80114f:	90                   	nop
  801150:	7e 11                	jle    801163 <printnum_v2+0xb3>
			putch(padc, putdat);
  801152:	89 74 24 04          	mov    %esi,0x4(%esp)
  801156:	89 3c 24             	mov    %edi,(%esp)
  801159:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80115c:	83 eb 01             	sub    $0x1,%ebx
  80115f:	85 db                	test   %ebx,%ebx
  801161:	7f ef                	jg     801152 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801163:	89 74 24 04          	mov    %esi,0x4(%esp)
  801167:	8b 74 24 04          	mov    0x4(%esp),%esi
  80116b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80116e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801172:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801179:	00 
  80117a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80117d:	89 14 24             	mov    %edx,(%esp)
  801180:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801183:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801187:	e8 a4 0e 00 00       	call   802030 <__umoddi3>
  80118c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801190:	0f be 80 5f 22 80 00 	movsbl 0x80225f(%eax),%eax
  801197:	89 04 24             	mov    %eax,(%esp)
  80119a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80119d:	83 c4 4c             	add    $0x4c,%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011a8:	83 fa 01             	cmp    $0x1,%edx
  8011ab:	7e 0e                	jle    8011bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011ad:	8b 10                	mov    (%eax),%edx
  8011af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011b2:	89 08                	mov    %ecx,(%eax)
  8011b4:	8b 02                	mov    (%edx),%eax
  8011b6:	8b 52 04             	mov    0x4(%edx),%edx
  8011b9:	eb 22                	jmp    8011dd <getuint+0x38>
	else if (lflag)
  8011bb:	85 d2                	test   %edx,%edx
  8011bd:	74 10                	je     8011cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011bf:	8b 10                	mov    (%eax),%edx
  8011c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c4:	89 08                	mov    %ecx,(%eax)
  8011c6:	8b 02                	mov    (%edx),%eax
  8011c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cd:	eb 0e                	jmp    8011dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011cf:	8b 10                	mov    (%eax),%edx
  8011d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011d4:	89 08                	mov    %ecx,(%eax)
  8011d6:	8b 02                	mov    (%edx),%eax
  8011d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e9:	8b 10                	mov    (%eax),%edx
  8011eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ee:	73 0a                	jae    8011fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f3:	88 0a                	mov    %cl,(%edx)
  8011f5:	83 c2 01             	add    $0x1,%edx
  8011f8:	89 10                	mov    %edx,(%eax)
}
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	57                   	push   %edi
  801200:	56                   	push   %esi
  801201:	53                   	push   %ebx
  801202:	83 ec 6c             	sub    $0x6c,%esp
  801205:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801208:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80120f:	eb 1a                	jmp    80122b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801211:	85 c0                	test   %eax,%eax
  801213:	0f 84 66 06 00 00    	je     80187f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  801219:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801220:	89 04 24             	mov    %eax,(%esp)
  801223:	ff 55 08             	call   *0x8(%ebp)
  801226:	eb 03                	jmp    80122b <vprintfmt+0x2f>
  801228:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80122b:	0f b6 07             	movzbl (%edi),%eax
  80122e:	83 c7 01             	add    $0x1,%edi
  801231:	83 f8 25             	cmp    $0x25,%eax
  801234:	75 db                	jne    801211 <vprintfmt+0x15>
  801236:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80123a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801246:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80124b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801252:	be 00 00 00 00       	mov    $0x0,%esi
  801257:	eb 06                	jmp    80125f <vprintfmt+0x63>
  801259:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80125d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125f:	0f b6 17             	movzbl (%edi),%edx
  801262:	0f b6 c2             	movzbl %dl,%eax
  801265:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801268:	8d 47 01             	lea    0x1(%edi),%eax
  80126b:	83 ea 23             	sub    $0x23,%edx
  80126e:	80 fa 55             	cmp    $0x55,%dl
  801271:	0f 87 60 05 00 00    	ja     8017d7 <vprintfmt+0x5db>
  801277:	0f b6 d2             	movzbl %dl,%edx
  80127a:	ff 24 95 40 24 80 00 	jmp    *0x802440(,%edx,4)
  801281:	b9 01 00 00 00       	mov    $0x1,%ecx
  801286:	eb d5                	jmp    80125d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801288:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80128b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80128e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801291:	8d 7a d0             	lea    -0x30(%edx),%edi
  801294:	83 ff 09             	cmp    $0x9,%edi
  801297:	76 08                	jbe    8012a1 <vprintfmt+0xa5>
  801299:	eb 40                	jmp    8012db <vprintfmt+0xdf>
  80129b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80129f:	eb bc                	jmp    80125d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012a1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8012a4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8012a7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8012ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8012ae:	8d 7a d0             	lea    -0x30(%edx),%edi
  8012b1:	83 ff 09             	cmp    $0x9,%edi
  8012b4:	76 eb                	jbe    8012a1 <vprintfmt+0xa5>
  8012b6:	eb 23                	jmp    8012db <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012bb:	8d 5a 04             	lea    0x4(%edx),%ebx
  8012be:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8012c1:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  8012c3:	eb 16                	jmp    8012db <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  8012c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012c8:	c1 fa 1f             	sar    $0x1f,%edx
  8012cb:	f7 d2                	not    %edx
  8012cd:	21 55 d8             	and    %edx,-0x28(%ebp)
  8012d0:	eb 8b                	jmp    80125d <vprintfmt+0x61>
  8012d2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8012d9:	eb 82                	jmp    80125d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  8012db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8012df:	0f 89 78 ff ff ff    	jns    80125d <vprintfmt+0x61>
  8012e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8012e8:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  8012eb:	e9 6d ff ff ff       	jmp    80125d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012f0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8012f3:	e9 65 ff ff ff       	jmp    80125d <vprintfmt+0x61>
  8012f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fe:	8d 50 04             	lea    0x4(%eax),%edx
  801301:	89 55 14             	mov    %edx,0x14(%ebp)
  801304:	8b 55 0c             	mov    0xc(%ebp),%edx
  801307:	89 54 24 04          	mov    %edx,0x4(%esp)
  80130b:	8b 00                	mov    (%eax),%eax
  80130d:	89 04 24             	mov    %eax,(%esp)
  801310:	ff 55 08             	call   *0x8(%ebp)
  801313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801316:	e9 10 ff ff ff       	jmp    80122b <vprintfmt+0x2f>
  80131b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80131e:	8b 45 14             	mov    0x14(%ebp),%eax
  801321:	8d 50 04             	lea    0x4(%eax),%edx
  801324:	89 55 14             	mov    %edx,0x14(%ebp)
  801327:	8b 00                	mov    (%eax),%eax
  801329:	89 c2                	mov    %eax,%edx
  80132b:	c1 fa 1f             	sar    $0x1f,%edx
  80132e:	31 d0                	xor    %edx,%eax
  801330:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801332:	83 f8 0f             	cmp    $0xf,%eax
  801335:	7f 0b                	jg     801342 <vprintfmt+0x146>
  801337:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80133e:	85 d2                	test   %edx,%edx
  801340:	75 26                	jne    801368 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  801342:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801346:	c7 44 24 08 70 22 80 	movl   $0x802270,0x8(%esp)
  80134d:	00 
  80134e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801351:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801355:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801358:	89 1c 24             	mov    %ebx,(%esp)
  80135b:	e8 a7 05 00 00       	call   801907 <printfmt>
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801363:	e9 c3 fe ff ff       	jmp    80122b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801368:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80136c:	c7 44 24 08 79 22 80 	movl   $0x802279,0x8(%esp)
  801373:	00 
  801374:	8b 45 0c             	mov    0xc(%ebp),%eax
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137b:	8b 55 08             	mov    0x8(%ebp),%edx
  80137e:	89 14 24             	mov    %edx,(%esp)
  801381:	e8 81 05 00 00       	call   801907 <printfmt>
  801386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801389:	e9 9d fe ff ff       	jmp    80122b <vprintfmt+0x2f>
  80138e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801391:	89 c7                	mov    %eax,%edi
  801393:	89 d9                	mov    %ebx,%ecx
  801395:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801398:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80139b:	8b 45 14             	mov    0x14(%ebp),%eax
  80139e:	8d 50 04             	lea    0x4(%eax),%edx
  8013a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a4:	8b 30                	mov    (%eax),%esi
  8013a6:	85 f6                	test   %esi,%esi
  8013a8:	75 05                	jne    8013af <vprintfmt+0x1b3>
  8013aa:	be 7c 22 80 00       	mov    $0x80227c,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8013af:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8013b3:	7e 06                	jle    8013bb <vprintfmt+0x1bf>
  8013b5:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8013b9:	75 10                	jne    8013cb <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013bb:	0f be 06             	movsbl (%esi),%eax
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	0f 85 a2 00 00 00    	jne    801468 <vprintfmt+0x26c>
  8013c6:	e9 92 00 00 00       	jmp    80145d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013cf:	89 34 24             	mov    %esi,(%esp)
  8013d2:	e8 74 05 00 00       	call   80194b <strnlen>
  8013d7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8013da:	29 c2                	sub    %eax,%edx
  8013dc:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8013df:	85 d2                	test   %edx,%edx
  8013e1:	7e d8                	jle    8013bb <vprintfmt+0x1bf>
					putch(padc, putdat);
  8013e3:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8013e7:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8013ea:	89 d3                	mov    %edx,%ebx
  8013ec:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8013ef:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8013f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013f5:	89 ce                	mov    %ecx,%esi
  8013f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013fb:	89 34 24             	mov    %esi,(%esp)
  8013fe:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801401:	83 eb 01             	sub    $0x1,%ebx
  801404:	85 db                	test   %ebx,%ebx
  801406:	7f ef                	jg     8013f7 <vprintfmt+0x1fb>
  801408:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  80140b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80140e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  801411:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801418:	eb a1                	jmp    8013bb <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80141a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80141e:	74 1b                	je     80143b <vprintfmt+0x23f>
  801420:	8d 50 e0             	lea    -0x20(%eax),%edx
  801423:	83 fa 5e             	cmp    $0x5e,%edx
  801426:	76 13                	jbe    80143b <vprintfmt+0x23f>
					putch('?', putdat);
  801428:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801436:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801439:	eb 0d                	jmp    801448 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80143b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801442:	89 04 24             	mov    %eax,(%esp)
  801445:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801448:	83 ef 01             	sub    $0x1,%edi
  80144b:	0f be 06             	movsbl (%esi),%eax
  80144e:	85 c0                	test   %eax,%eax
  801450:	74 05                	je     801457 <vprintfmt+0x25b>
  801452:	83 c6 01             	add    $0x1,%esi
  801455:	eb 1a                	jmp    801471 <vprintfmt+0x275>
  801457:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80145a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80145d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801461:	7f 1f                	jg     801482 <vprintfmt+0x286>
  801463:	e9 c0 fd ff ff       	jmp    801228 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801468:	83 c6 01             	add    $0x1,%esi
  80146b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80146e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801471:	85 db                	test   %ebx,%ebx
  801473:	78 a5                	js     80141a <vprintfmt+0x21e>
  801475:	83 eb 01             	sub    $0x1,%ebx
  801478:	79 a0                	jns    80141a <vprintfmt+0x21e>
  80147a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80147d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801480:	eb db                	jmp    80145d <vprintfmt+0x261>
  801482:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801485:	8b 75 0c             	mov    0xc(%ebp),%esi
  801488:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80148b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80148e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801492:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801499:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80149b:	83 eb 01             	sub    $0x1,%ebx
  80149e:	85 db                	test   %ebx,%ebx
  8014a0:	7f ec                	jg     80148e <vprintfmt+0x292>
  8014a2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8014a5:	e9 81 fd ff ff       	jmp    80122b <vprintfmt+0x2f>
  8014aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ad:	83 fe 01             	cmp    $0x1,%esi
  8014b0:	7e 10                	jle    8014c2 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  8014b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b5:	8d 50 08             	lea    0x8(%eax),%edx
  8014b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014bb:	8b 18                	mov    (%eax),%ebx
  8014bd:	8b 70 04             	mov    0x4(%eax),%esi
  8014c0:	eb 26                	jmp    8014e8 <vprintfmt+0x2ec>
	else if (lflag)
  8014c2:	85 f6                	test   %esi,%esi
  8014c4:	74 12                	je     8014d8 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  8014c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c9:	8d 50 04             	lea    0x4(%eax),%edx
  8014cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8014cf:	8b 18                	mov    (%eax),%ebx
  8014d1:	89 de                	mov    %ebx,%esi
  8014d3:	c1 fe 1f             	sar    $0x1f,%esi
  8014d6:	eb 10                	jmp    8014e8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014db:	8d 50 04             	lea    0x4(%eax),%edx
  8014de:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e1:	8b 18                	mov    (%eax),%ebx
  8014e3:	89 de                	mov    %ebx,%esi
  8014e5:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  8014e8:	83 f9 01             	cmp    $0x1,%ecx
  8014eb:	75 1e                	jne    80150b <vprintfmt+0x30f>
                               if((long long)num > 0){
  8014ed:	85 f6                	test   %esi,%esi
  8014ef:	78 1a                	js     80150b <vprintfmt+0x30f>
  8014f1:	85 f6                	test   %esi,%esi
  8014f3:	7f 05                	jg     8014fa <vprintfmt+0x2fe>
  8014f5:	83 fb 00             	cmp    $0x0,%ebx
  8014f8:	76 11                	jbe    80150b <vprintfmt+0x30f>
                                   putch('+',putdat);
  8014fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014fd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801501:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  801508:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  80150b:	85 f6                	test   %esi,%esi
  80150d:	78 13                	js     801522 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80150f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  801512:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  801515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801518:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151d:	e9 da 00 00 00       	jmp    8015fc <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  801522:	8b 45 0c             	mov    0xc(%ebp),%eax
  801525:	89 44 24 04          	mov    %eax,0x4(%esp)
  801529:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801530:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801533:	89 da                	mov    %ebx,%edx
  801535:	89 f1                	mov    %esi,%ecx
  801537:	f7 da                	neg    %edx
  801539:	83 d1 00             	adc    $0x0,%ecx
  80153c:	f7 d9                	neg    %ecx
  80153e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801541:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801547:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154c:	e9 ab 00 00 00       	jmp    8015fc <vprintfmt+0x400>
  801551:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801554:	89 f2                	mov    %esi,%edx
  801556:	8d 45 14             	lea    0x14(%ebp),%eax
  801559:	e8 47 fc ff ff       	call   8011a5 <getuint>
  80155e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801561:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801567:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80156c:	e9 8b 00 00 00       	jmp    8015fc <vprintfmt+0x400>
  801571:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801574:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801577:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80157b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801582:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801585:	89 f2                	mov    %esi,%edx
  801587:	8d 45 14             	lea    0x14(%ebp),%eax
  80158a:	e8 16 fc ff ff       	call   8011a5 <getuint>
  80158f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801592:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801598:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80159d:	eb 5d                	jmp    8015fc <vprintfmt+0x400>
  80159f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8015a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8015b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8015b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8015be:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8015c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c4:	8d 50 04             	lea    0x4(%eax),%edx
  8015c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8015ca:	8b 10                	mov    (%eax),%edx
  8015cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d1:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8015d4:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8015d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015da:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015df:	eb 1b                	jmp    8015fc <vprintfmt+0x400>
  8015e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015e4:	89 f2                	mov    %esi,%edx
  8015e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e9:	e8 b7 fb ff ff       	call   8011a5 <getuint>
  8015ee:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8015f1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8015f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015f7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015fc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  801600:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801603:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801606:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  80160a:	77 09                	ja     801615 <vprintfmt+0x419>
  80160c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  80160f:	0f 82 ac 00 00 00    	jb     8016c1 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801615:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801618:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80161c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80161f:	83 ea 01             	sub    $0x1,%edx
  801622:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801626:	89 44 24 08          	mov    %eax,0x8(%esp)
  80162a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80162e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801632:	89 45 c0             	mov    %eax,-0x40(%ebp)
  801635:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801638:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80163b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80163f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801646:	00 
  801647:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80164a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  80164d:	89 0c 24             	mov    %ecx,(%esp)
  801650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801654:	e8 a7 08 00 00       	call   801f00 <__udivdi3>
  801659:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80165c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80165f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801663:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801667:	89 04 24             	mov    %eax,(%esp)
  80166a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80166e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801671:	8b 45 08             	mov    0x8(%ebp),%eax
  801674:	e8 37 fa ff ff       	call   8010b0 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80167c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801680:	8b 74 24 04          	mov    0x4(%esp),%esi
  801684:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801687:	89 44 24 08          	mov    %eax,0x8(%esp)
  80168b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801692:	00 
  801693:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801696:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801699:	89 14 24             	mov    %edx,(%esp)
  80169c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016a0:	e8 8b 09 00 00       	call   802030 <__umoddi3>
  8016a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a9:	0f be 80 5f 22 80 00 	movsbl 0x80225f(%eax),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  8016b6:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8016ba:	74 54                	je     801710 <vprintfmt+0x514>
  8016bc:	e9 67 fb ff ff       	jmp    801228 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8016c1:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  8016c5:	8d 76 00             	lea    0x0(%esi),%esi
  8016c8:	0f 84 2a 01 00 00    	je     8017f8 <vprintfmt+0x5fc>
		while (--width > 0)
  8016ce:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8016d1:	83 ef 01             	sub    $0x1,%edi
  8016d4:	85 ff                	test   %edi,%edi
  8016d6:	0f 8e 5e 01 00 00    	jle    80183a <vprintfmt+0x63e>
  8016dc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8016df:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8016e2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8016e5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8016e8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016eb:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  8016ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016f2:	89 1c 24             	mov    %ebx,(%esp)
  8016f5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8016f8:	83 ef 01             	sub    $0x1,%edi
  8016fb:	85 ff                	test   %edi,%edi
  8016fd:	7f ef                	jg     8016ee <vprintfmt+0x4f2>
  8016ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801702:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801705:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801708:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  80170b:	e9 2a 01 00 00       	jmp    80183a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801710:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801713:	83 eb 01             	sub    $0x1,%ebx
  801716:	85 db                	test   %ebx,%ebx
  801718:	0f 8e 0a fb ff ff    	jle    801228 <vprintfmt+0x2c>
  80171e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801721:	89 7d d8             	mov    %edi,-0x28(%ebp)
  801724:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  801727:	89 74 24 04          	mov    %esi,0x4(%esp)
  80172b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801732:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  801734:	83 eb 01             	sub    $0x1,%ebx
  801737:	85 db                	test   %ebx,%ebx
  801739:	7f ec                	jg     801727 <vprintfmt+0x52b>
  80173b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80173e:	e9 e8 fa ff ff       	jmp    80122b <vprintfmt+0x2f>
  801743:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  801746:	8b 45 14             	mov    0x14(%ebp),%eax
  801749:	8d 50 04             	lea    0x4(%eax),%edx
  80174c:	89 55 14             	mov    %edx,0x14(%ebp)
  80174f:	8b 00                	mov    (%eax),%eax
  801751:	85 c0                	test   %eax,%eax
  801753:	75 2a                	jne    80177f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801755:	c7 44 24 0c 98 23 80 	movl   $0x802398,0xc(%esp)
  80175c:	00 
  80175d:	c7 44 24 08 79 22 80 	movl   $0x802279,0x8(%esp)
  801764:	00 
  801765:	8b 55 0c             	mov    0xc(%ebp),%edx
  801768:	89 54 24 04          	mov    %edx,0x4(%esp)
  80176c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176f:	89 0c 24             	mov    %ecx,(%esp)
  801772:	e8 90 01 00 00       	call   801907 <printfmt>
  801777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177a:	e9 ac fa ff ff       	jmp    80122b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80177f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801782:	8b 13                	mov    (%ebx),%edx
  801784:	83 fa 7f             	cmp    $0x7f,%edx
  801787:	7e 29                	jle    8017b2 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801789:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80178b:	c7 44 24 0c d0 23 80 	movl   $0x8023d0,0xc(%esp)
  801792:	00 
  801793:	c7 44 24 08 79 22 80 	movl   $0x802279,0x8(%esp)
  80179a:	00 
  80179b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	e8 5d 01 00 00       	call   801907 <printfmt>
  8017aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ad:	e9 79 fa ff ff       	jmp    80122b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  8017b2:	88 10                	mov    %dl,(%eax)
  8017b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017b7:	e9 6f fa ff ff       	jmp    80122b <vprintfmt+0x2f>
  8017bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017c9:	89 14 24             	mov    %edx,(%esp)
  8017cc:	ff 55 08             	call   *0x8(%ebp)
  8017cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8017d2:	e9 54 fa ff ff       	jmp    80122b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8017eb:	80 38 25             	cmpb   $0x25,(%eax)
  8017ee:	0f 84 37 fa ff ff    	je     80122b <vprintfmt+0x2f>
  8017f4:	89 c7                	mov    %eax,%edi
  8017f6:	eb f0                	jmp    8017e8 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ff:	8b 74 24 04          	mov    0x4(%esp),%esi
  801803:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801806:	89 54 24 08          	mov    %edx,0x8(%esp)
  80180a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801811:	00 
  801812:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801815:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80181f:	e8 0c 08 00 00       	call   802030 <__umoddi3>
  801824:	89 74 24 04          	mov    %esi,0x4(%esp)
  801828:	0f be 80 5f 22 80 00 	movsbl 0x80225f(%eax),%eax
  80182f:	89 04 24             	mov    %eax,(%esp)
  801832:	ff 55 08             	call   *0x8(%ebp)
  801835:	e9 d6 fe ff ff       	jmp    801710 <vprintfmt+0x514>
  80183a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80183d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801841:	8b 74 24 04          	mov    0x4(%esp),%esi
  801845:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801848:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80184c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801853:	00 
  801854:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801857:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80185a:	89 04 24             	mov    %eax,(%esp)
  80185d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801861:	e8 ca 07 00 00       	call   802030 <__umoddi3>
  801866:	89 74 24 04          	mov    %esi,0x4(%esp)
  80186a:	0f be 80 5f 22 80 00 	movsbl 0x80225f(%eax),%eax
  801871:	89 04 24             	mov    %eax,(%esp)
  801874:	ff 55 08             	call   *0x8(%ebp)
  801877:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80187a:	e9 ac f9 ff ff       	jmp    80122b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80187f:	83 c4 6c             	add    $0x6c,%esp
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	5f                   	pop    %edi
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	83 ec 28             	sub    $0x28,%esp
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801893:	85 c0                	test   %eax,%eax
  801895:	74 04                	je     80189b <vsnprintf+0x14>
  801897:	85 d2                	test   %edx,%edx
  801899:	7f 07                	jg     8018a2 <vsnprintf+0x1b>
  80189b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018a0:	eb 3b                	jmp    8018dd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8018a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8018a5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8018a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8018ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8018b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8018bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8018c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c8:	c7 04 24 df 11 80 00 	movl   $0x8011df,(%esp)
  8018cf:	e8 28 f9 ff ff       	call   8011fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8018d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8018d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8018da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8018e5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8018e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	89 04 24             	mov    %eax,(%esp)
  801900:	e8 82 ff ff ff       	call   801887 <vsnprintf>
	va_end(ap);

	return rc;
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80190d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801910:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801914:	8b 45 10             	mov    0x10(%ebp),%eax
  801917:	89 44 24 08          	mov    %eax,0x8(%esp)
  80191b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	89 04 24             	mov    %eax,(%esp)
  801928:	e8 cf f8 ff ff       	call   8011fc <vprintfmt>
	va_end(ap);
}
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    
	...

00801930 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
  80193b:	80 3a 00             	cmpb   $0x0,(%edx)
  80193e:	74 09                	je     801949 <strlen+0x19>
		n++;
  801940:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801943:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801947:	75 f7                	jne    801940 <strlen+0x10>
		n++;
	return n;
}
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	53                   	push   %ebx
  80194f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801955:	85 c9                	test   %ecx,%ecx
  801957:	74 19                	je     801972 <strnlen+0x27>
  801959:	80 3b 00             	cmpb   $0x0,(%ebx)
  80195c:	74 14                	je     801972 <strnlen+0x27>
  80195e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801963:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801966:	39 c8                	cmp    %ecx,%eax
  801968:	74 0d                	je     801977 <strnlen+0x2c>
  80196a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80196e:	75 f3                	jne    801963 <strnlen+0x18>
  801970:	eb 05                	jmp    801977 <strnlen+0x2c>
  801972:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801977:	5b                   	pop    %ebx
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	53                   	push   %ebx
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801984:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801989:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80198d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801990:	83 c2 01             	add    $0x1,%edx
  801993:	84 c9                	test   %cl,%cl
  801995:	75 f2                	jne    801989 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801997:	5b                   	pop    %ebx
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	53                   	push   %ebx
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8019a4:	89 1c 24             	mov    %ebx,(%esp)
  8019a7:	e8 84 ff ff ff       	call   801930 <strlen>
	strcpy(dst + len, src);
  8019ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019af:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8019b6:	89 04 24             	mov    %eax,(%esp)
  8019b9:	e8 bc ff ff ff       	call   80197a <strcpy>
	return dst;
}
  8019be:	89 d8                	mov    %ebx,%eax
  8019c0:	83 c4 08             	add    $0x8,%esp
  8019c3:	5b                   	pop    %ebx
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019d4:	85 f6                	test   %esi,%esi
  8019d6:	74 18                	je     8019f0 <strncpy+0x2a>
  8019d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8019dd:	0f b6 1a             	movzbl (%edx),%ebx
  8019e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8019e3:	80 3a 01             	cmpb   $0x1,(%edx)
  8019e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8019e9:	83 c1 01             	add    $0x1,%ecx
  8019ec:	39 ce                	cmp    %ecx,%esi
  8019ee:	77 ed                	ja     8019dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a02:	89 f0                	mov    %esi,%eax
  801a04:	85 c9                	test   %ecx,%ecx
  801a06:	74 27                	je     801a2f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801a08:	83 e9 01             	sub    $0x1,%ecx
  801a0b:	74 1d                	je     801a2a <strlcpy+0x36>
  801a0d:	0f b6 1a             	movzbl (%edx),%ebx
  801a10:	84 db                	test   %bl,%bl
  801a12:	74 16                	je     801a2a <strlcpy+0x36>
			*dst++ = *src++;
  801a14:	88 18                	mov    %bl,(%eax)
  801a16:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a19:	83 e9 01             	sub    $0x1,%ecx
  801a1c:	74 0e                	je     801a2c <strlcpy+0x38>
			*dst++ = *src++;
  801a1e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a21:	0f b6 1a             	movzbl (%edx),%ebx
  801a24:	84 db                	test   %bl,%bl
  801a26:	75 ec                	jne    801a14 <strlcpy+0x20>
  801a28:	eb 02                	jmp    801a2c <strlcpy+0x38>
  801a2a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a2c:	c6 00 00             	movb   $0x0,(%eax)
  801a2f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801a3e:	0f b6 01             	movzbl (%ecx),%eax
  801a41:	84 c0                	test   %al,%al
  801a43:	74 15                	je     801a5a <strcmp+0x25>
  801a45:	3a 02                	cmp    (%edx),%al
  801a47:	75 11                	jne    801a5a <strcmp+0x25>
		p++, q++;
  801a49:	83 c1 01             	add    $0x1,%ecx
  801a4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801a4f:	0f b6 01             	movzbl (%ecx),%eax
  801a52:	84 c0                	test   %al,%al
  801a54:	74 04                	je     801a5a <strcmp+0x25>
  801a56:	3a 02                	cmp    (%edx),%al
  801a58:	74 ef                	je     801a49 <strcmp+0x14>
  801a5a:	0f b6 c0             	movzbl %al,%eax
  801a5d:	0f b6 12             	movzbl (%edx),%edx
  801a60:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	53                   	push   %ebx
  801a68:	8b 55 08             	mov    0x8(%ebp),%edx
  801a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801a71:	85 c0                	test   %eax,%eax
  801a73:	74 23                	je     801a98 <strncmp+0x34>
  801a75:	0f b6 1a             	movzbl (%edx),%ebx
  801a78:	84 db                	test   %bl,%bl
  801a7a:	74 25                	je     801aa1 <strncmp+0x3d>
  801a7c:	3a 19                	cmp    (%ecx),%bl
  801a7e:	75 21                	jne    801aa1 <strncmp+0x3d>
  801a80:	83 e8 01             	sub    $0x1,%eax
  801a83:	74 13                	je     801a98 <strncmp+0x34>
		n--, p++, q++;
  801a85:	83 c2 01             	add    $0x1,%edx
  801a88:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801a8b:	0f b6 1a             	movzbl (%edx),%ebx
  801a8e:	84 db                	test   %bl,%bl
  801a90:	74 0f                	je     801aa1 <strncmp+0x3d>
  801a92:	3a 19                	cmp    (%ecx),%bl
  801a94:	74 ea                	je     801a80 <strncmp+0x1c>
  801a96:	eb 09                	jmp    801aa1 <strncmp+0x3d>
  801a98:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a9d:	5b                   	pop    %ebx
  801a9e:	5d                   	pop    %ebp
  801a9f:	90                   	nop
  801aa0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801aa1:	0f b6 02             	movzbl (%edx),%eax
  801aa4:	0f b6 11             	movzbl (%ecx),%edx
  801aa7:	29 d0                	sub    %edx,%eax
  801aa9:	eb f2                	jmp    801a9d <strncmp+0x39>

00801aab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ab5:	0f b6 10             	movzbl (%eax),%edx
  801ab8:	84 d2                	test   %dl,%dl
  801aba:	74 18                	je     801ad4 <strchr+0x29>
		if (*s == c)
  801abc:	38 ca                	cmp    %cl,%dl
  801abe:	75 0a                	jne    801aca <strchr+0x1f>
  801ac0:	eb 17                	jmp    801ad9 <strchr+0x2e>
  801ac2:	38 ca                	cmp    %cl,%dl
  801ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ac8:	74 0f                	je     801ad9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801aca:	83 c0 01             	add    $0x1,%eax
  801acd:	0f b6 10             	movzbl (%eax),%edx
  801ad0:	84 d2                	test   %dl,%dl
  801ad2:	75 ee                	jne    801ac2 <strchr+0x17>
  801ad4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ae5:	0f b6 10             	movzbl (%eax),%edx
  801ae8:	84 d2                	test   %dl,%dl
  801aea:	74 18                	je     801b04 <strfind+0x29>
		if (*s == c)
  801aec:	38 ca                	cmp    %cl,%dl
  801aee:	75 0a                	jne    801afa <strfind+0x1f>
  801af0:	eb 12                	jmp    801b04 <strfind+0x29>
  801af2:	38 ca                	cmp    %cl,%dl
  801af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af8:	74 0a                	je     801b04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801afa:	83 c0 01             	add    $0x1,%eax
  801afd:	0f b6 10             	movzbl (%eax),%edx
  801b00:	84 d2                	test   %dl,%dl
  801b02:	75 ee                	jne    801af2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 0c             	sub    $0xc,%esp
  801b0c:	89 1c 24             	mov    %ebx,(%esp)
  801b0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b20:	85 c9                	test   %ecx,%ecx
  801b22:	74 30                	je     801b54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b2a:	75 25                	jne    801b51 <memset+0x4b>
  801b2c:	f6 c1 03             	test   $0x3,%cl
  801b2f:	75 20                	jne    801b51 <memset+0x4b>
		c &= 0xFF;
  801b31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b34:	89 d3                	mov    %edx,%ebx
  801b36:	c1 e3 08             	shl    $0x8,%ebx
  801b39:	89 d6                	mov    %edx,%esi
  801b3b:	c1 e6 18             	shl    $0x18,%esi
  801b3e:	89 d0                	mov    %edx,%eax
  801b40:	c1 e0 10             	shl    $0x10,%eax
  801b43:	09 f0                	or     %esi,%eax
  801b45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801b47:	09 d8                	or     %ebx,%eax
  801b49:	c1 e9 02             	shr    $0x2,%ecx
  801b4c:	fc                   	cld    
  801b4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b4f:	eb 03                	jmp    801b54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b51:	fc                   	cld    
  801b52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b54:	89 f8                	mov    %edi,%eax
  801b56:	8b 1c 24             	mov    (%esp),%ebx
  801b59:	8b 74 24 04          	mov    0x4(%esp),%esi
  801b5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b61:	89 ec                	mov    %ebp,%esp
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
  801b6b:	89 34 24             	mov    %esi,(%esp)
  801b6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b72:	8b 45 08             	mov    0x8(%ebp),%eax
  801b75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801b78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801b7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801b7d:	39 c6                	cmp    %eax,%esi
  801b7f:	73 35                	jae    801bb6 <memmove+0x51>
  801b81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b84:	39 d0                	cmp    %edx,%eax
  801b86:	73 2e                	jae    801bb6 <memmove+0x51>
		s += n;
		d += n;
  801b88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b8a:	f6 c2 03             	test   $0x3,%dl
  801b8d:	75 1b                	jne    801baa <memmove+0x45>
  801b8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b95:	75 13                	jne    801baa <memmove+0x45>
  801b97:	f6 c1 03             	test   $0x3,%cl
  801b9a:	75 0e                	jne    801baa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801b9c:	83 ef 04             	sub    $0x4,%edi
  801b9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ba2:	c1 e9 02             	shr    $0x2,%ecx
  801ba5:	fd                   	std    
  801ba6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ba8:	eb 09                	jmp    801bb3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801baa:	83 ef 01             	sub    $0x1,%edi
  801bad:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bb0:	fd                   	std    
  801bb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bb3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801bb4:	eb 20                	jmp    801bd6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bbc:	75 15                	jne    801bd3 <memmove+0x6e>
  801bbe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801bc4:	75 0d                	jne    801bd3 <memmove+0x6e>
  801bc6:	f6 c1 03             	test   $0x3,%cl
  801bc9:	75 08                	jne    801bd3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801bcb:	c1 e9 02             	shr    $0x2,%ecx
  801bce:	fc                   	cld    
  801bcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bd1:	eb 03                	jmp    801bd6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bd3:	fc                   	cld    
  801bd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bd6:	8b 34 24             	mov    (%esp),%esi
  801bd9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801bdd:	89 ec                	mov    %ebp,%esp
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801be7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bea:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf8:	89 04 24             	mov    %eax,(%esp)
  801bfb:	e8 65 ff ff ff       	call   801b65 <memmove>
}
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	57                   	push   %edi
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	8b 75 08             	mov    0x8(%ebp),%esi
  801c0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c11:	85 c9                	test   %ecx,%ecx
  801c13:	74 36                	je     801c4b <memcmp+0x49>
		if (*s1 != *s2)
  801c15:	0f b6 06             	movzbl (%esi),%eax
  801c18:	0f b6 1f             	movzbl (%edi),%ebx
  801c1b:	38 d8                	cmp    %bl,%al
  801c1d:	74 20                	je     801c3f <memcmp+0x3d>
  801c1f:	eb 14                	jmp    801c35 <memcmp+0x33>
  801c21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801c26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801c2b:	83 c2 01             	add    $0x1,%edx
  801c2e:	83 e9 01             	sub    $0x1,%ecx
  801c31:	38 d8                	cmp    %bl,%al
  801c33:	74 12                	je     801c47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801c35:	0f b6 c0             	movzbl %al,%eax
  801c38:	0f b6 db             	movzbl %bl,%ebx
  801c3b:	29 d8                	sub    %ebx,%eax
  801c3d:	eb 11                	jmp    801c50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c3f:	83 e9 01             	sub    $0x1,%ecx
  801c42:	ba 00 00 00 00       	mov    $0x0,%edx
  801c47:	85 c9                	test   %ecx,%ecx
  801c49:	75 d6                	jne    801c21 <memcmp+0x1f>
  801c4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801c50:	5b                   	pop    %ebx
  801c51:	5e                   	pop    %esi
  801c52:	5f                   	pop    %edi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c5b:	89 c2                	mov    %eax,%edx
  801c5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801c60:	39 d0                	cmp    %edx,%eax
  801c62:	73 15                	jae    801c79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801c68:	38 08                	cmp    %cl,(%eax)
  801c6a:	75 06                	jne    801c72 <memfind+0x1d>
  801c6c:	eb 0b                	jmp    801c79 <memfind+0x24>
  801c6e:	38 08                	cmp    %cl,(%eax)
  801c70:	74 07                	je     801c79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c72:	83 c0 01             	add    $0x1,%eax
  801c75:	39 c2                	cmp    %eax,%edx
  801c77:	77 f5                	ja     801c6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	57                   	push   %edi
  801c7f:	56                   	push   %esi
  801c80:	53                   	push   %ebx
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	8b 55 08             	mov    0x8(%ebp),%edx
  801c87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c8a:	0f b6 02             	movzbl (%edx),%eax
  801c8d:	3c 20                	cmp    $0x20,%al
  801c8f:	74 04                	je     801c95 <strtol+0x1a>
  801c91:	3c 09                	cmp    $0x9,%al
  801c93:	75 0e                	jne    801ca3 <strtol+0x28>
		s++;
  801c95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c98:	0f b6 02             	movzbl (%edx),%eax
  801c9b:	3c 20                	cmp    $0x20,%al
  801c9d:	74 f6                	je     801c95 <strtol+0x1a>
  801c9f:	3c 09                	cmp    $0x9,%al
  801ca1:	74 f2                	je     801c95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ca3:	3c 2b                	cmp    $0x2b,%al
  801ca5:	75 0c                	jne    801cb3 <strtol+0x38>
		s++;
  801ca7:	83 c2 01             	add    $0x1,%edx
  801caa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801cb1:	eb 15                	jmp    801cc8 <strtol+0x4d>
	else if (*s == '-')
  801cb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801cba:	3c 2d                	cmp    $0x2d,%al
  801cbc:	75 0a                	jne    801cc8 <strtol+0x4d>
		s++, neg = 1;
  801cbe:	83 c2 01             	add    $0x1,%edx
  801cc1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cc8:	85 db                	test   %ebx,%ebx
  801cca:	0f 94 c0             	sete   %al
  801ccd:	74 05                	je     801cd4 <strtol+0x59>
  801ccf:	83 fb 10             	cmp    $0x10,%ebx
  801cd2:	75 18                	jne    801cec <strtol+0x71>
  801cd4:	80 3a 30             	cmpb   $0x30,(%edx)
  801cd7:	75 13                	jne    801cec <strtol+0x71>
  801cd9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801cdd:	8d 76 00             	lea    0x0(%esi),%esi
  801ce0:	75 0a                	jne    801cec <strtol+0x71>
		s += 2, base = 16;
  801ce2:	83 c2 02             	add    $0x2,%edx
  801ce5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cea:	eb 15                	jmp    801d01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cec:	84 c0                	test   %al,%al
  801cee:	66 90                	xchg   %ax,%ax
  801cf0:	74 0f                	je     801d01 <strtol+0x86>
  801cf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801cf7:	80 3a 30             	cmpb   $0x30,(%edx)
  801cfa:	75 05                	jne    801d01 <strtol+0x86>
		s++, base = 8;
  801cfc:	83 c2 01             	add    $0x1,%edx
  801cff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
  801d06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d08:	0f b6 0a             	movzbl (%edx),%ecx
  801d0b:	89 cf                	mov    %ecx,%edi
  801d0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801d10:	80 fb 09             	cmp    $0x9,%bl
  801d13:	77 08                	ja     801d1d <strtol+0xa2>
			dig = *s - '0';
  801d15:	0f be c9             	movsbl %cl,%ecx
  801d18:	83 e9 30             	sub    $0x30,%ecx
  801d1b:	eb 1e                	jmp    801d3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801d1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801d20:	80 fb 19             	cmp    $0x19,%bl
  801d23:	77 08                	ja     801d2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801d25:	0f be c9             	movsbl %cl,%ecx
  801d28:	83 e9 57             	sub    $0x57,%ecx
  801d2b:	eb 0e                	jmp    801d3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801d2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801d30:	80 fb 19             	cmp    $0x19,%bl
  801d33:	77 15                	ja     801d4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801d35:	0f be c9             	movsbl %cl,%ecx
  801d38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801d3b:	39 f1                	cmp    %esi,%ecx
  801d3d:	7d 0b                	jge    801d4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801d3f:	83 c2 01             	add    $0x1,%edx
  801d42:	0f af c6             	imul   %esi,%eax
  801d45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801d48:	eb be                	jmp    801d08 <strtol+0x8d>
  801d4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801d4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d50:	74 05                	je     801d57 <strtol+0xdc>
		*endptr = (char *) s;
  801d52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801d57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801d5b:	74 04                	je     801d61 <strtol+0xe6>
  801d5d:	89 c8                	mov    %ecx,%eax
  801d5f:	f7 d8                	neg    %eax
}
  801d61:	83 c4 04             	add    $0x4,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	00 00                	add    %al,(%eax)
	...

00801d6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d72:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d79:	75 30                	jne    801dab <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
                uint32_t ret = sys_page_alloc(0,(void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_U|PTE_W);
  801d7b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d82:	00 
  801d83:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801d8a:	ee 
  801d8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d92:	e8 6c e7 ff ff       	call   800503 <sys_page_alloc>
                if(ret < 0)
                  return;
                sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  801d97:	c7 44 24 04 a0 06 80 	movl   $0x8006a0,0x4(%esp)
  801d9e:	00 
  801d9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da6:	e8 3a e5 ff ff       	call   8002e5 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    
	...

00801dc0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801dc6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801dcc:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd1:	39 ca                	cmp    %ecx,%edx
  801dd3:	75 04                	jne    801dd9 <ipc_find_env+0x19>
  801dd5:	b0 00                	mov    $0x0,%al
  801dd7:	eb 12                	jmp    801deb <ipc_find_env+0x2b>
  801dd9:	89 c2                	mov    %eax,%edx
  801ddb:	c1 e2 07             	shl    $0x7,%edx
  801dde:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801de5:	8b 12                	mov    (%edx),%edx
  801de7:	39 ca                	cmp    %ecx,%edx
  801de9:	75 10                	jne    801dfb <ipc_find_env+0x3b>
			return envs[i].env_id;
  801deb:	89 c2                	mov    %eax,%edx
  801ded:	c1 e2 07             	shl    $0x7,%edx
  801df0:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801df7:	8b 00                	mov    (%eax),%eax
  801df9:	eb 0e                	jmp    801e09 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dfb:	83 c0 01             	add    $0x1,%eax
  801dfe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e03:	75 d4                	jne    801dd9 <ipc_find_env+0x19>
  801e05:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    

00801e0b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	57                   	push   %edi
  801e0f:	56                   	push   %esi
  801e10:	53                   	push   %ebx
  801e11:	83 ec 1c             	sub    $0x1c,%esp
  801e14:	8b 75 08             	mov    0x8(%ebp),%esi
  801e17:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801e1d:	85 db                	test   %ebx,%ebx
  801e1f:	74 19                	je     801e3a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801e21:	8b 45 14             	mov    0x14(%ebp),%eax
  801e24:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e28:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e2c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e30:	89 34 24             	mov    %esi,(%esp)
  801e33:	e8 6c e4 ff ff       	call   8002a4 <sys_ipc_try_send>
  801e38:	eb 1b                	jmp    801e55 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801e3a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e41:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801e48:	ee 
  801e49:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e4d:	89 34 24             	mov    %esi,(%esp)
  801e50:	e8 4f e4 ff ff       	call   8002a4 <sys_ipc_try_send>
           if(ret == 0)
  801e55:	85 c0                	test   %eax,%eax
  801e57:	74 28                	je     801e81 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801e59:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e5c:	74 1c                	je     801e7a <ipc_send+0x6f>
              panic("ipc send error");
  801e5e:	c7 44 24 08 e0 25 80 	movl   $0x8025e0,0x8(%esp)
  801e65:	00 
  801e66:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801e6d:	00 
  801e6e:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  801e75:	e8 1a f1 ff ff       	call   800f94 <_panic>
           sys_yield();
  801e7a:	e8 f1 e6 ff ff       	call   800570 <sys_yield>
        }
  801e7f:	eb 9c                	jmp    801e1d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801e81:	83 c4 1c             	add    $0x1c,%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5f                   	pop    %edi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	56                   	push   %esi
  801e8d:	53                   	push   %ebx
  801e8e:	83 ec 10             	sub    $0x10,%esp
  801e91:	8b 75 08             	mov    0x8(%ebp),%esi
  801e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	75 0e                	jne    801eac <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801e9e:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801ea5:	e8 8f e3 ff ff       	call   800239 <sys_ipc_recv>
  801eaa:	eb 08                	jmp    801eb4 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801eac:	89 04 24             	mov    %eax,(%esp)
  801eaf:	e8 85 e3 ff ff       	call   800239 <sys_ipc_recv>
        if(ret == 0){
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	75 26                	jne    801ede <ipc_recv+0x55>
           if(from_env_store)
  801eb8:	85 f6                	test   %esi,%esi
  801eba:	74 0a                	je     801ec6 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801ebc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec1:	8b 40 78             	mov    0x78(%eax),%eax
  801ec4:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801ec6:	85 db                	test   %ebx,%ebx
  801ec8:	74 0a                	je     801ed4 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801eca:	a1 04 40 80 00       	mov    0x804004,%eax
  801ecf:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ed2:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801ed4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed9:	8b 40 74             	mov    0x74(%eax),%eax
  801edc:	eb 14                	jmp    801ef2 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801ede:	85 f6                	test   %esi,%esi
  801ee0:	74 06                	je     801ee8 <ipc_recv+0x5f>
              *from_env_store = 0;
  801ee2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801ee8:	85 db                	test   %ebx,%ebx
  801eea:	74 06                	je     801ef2 <ipc_recv+0x69>
              *perm_store = 0;
  801eec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    
  801ef9:	00 00                	add    %al,(%eax)
  801efb:	00 00                	add    %al,(%eax)
  801efd:	00 00                	add    %al,(%eax)
	...

00801f00 <__udivdi3>:
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	83 ec 10             	sub    $0x10,%esp
  801f08:	8b 45 14             	mov    0x14(%ebp),%eax
  801f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  801f0e:	8b 75 10             	mov    0x10(%ebp),%esi
  801f11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f14:	85 c0                	test   %eax,%eax
  801f16:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801f19:	75 35                	jne    801f50 <__udivdi3+0x50>
  801f1b:	39 fe                	cmp    %edi,%esi
  801f1d:	77 61                	ja     801f80 <__udivdi3+0x80>
  801f1f:	85 f6                	test   %esi,%esi
  801f21:	75 0b                	jne    801f2e <__udivdi3+0x2e>
  801f23:	b8 01 00 00 00       	mov    $0x1,%eax
  801f28:	31 d2                	xor    %edx,%edx
  801f2a:	f7 f6                	div    %esi
  801f2c:	89 c6                	mov    %eax,%esi
  801f2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801f31:	31 d2                	xor    %edx,%edx
  801f33:	89 f8                	mov    %edi,%eax
  801f35:	f7 f6                	div    %esi
  801f37:	89 c7                	mov    %eax,%edi
  801f39:	89 c8                	mov    %ecx,%eax
  801f3b:	f7 f6                	div    %esi
  801f3d:	89 c1                	mov    %eax,%ecx
  801f3f:	89 fa                	mov    %edi,%edx
  801f41:	89 c8                	mov    %ecx,%eax
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	5e                   	pop    %esi
  801f47:	5f                   	pop    %edi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    
  801f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f50:	39 f8                	cmp    %edi,%eax
  801f52:	77 1c                	ja     801f70 <__udivdi3+0x70>
  801f54:	0f bd d0             	bsr    %eax,%edx
  801f57:	83 f2 1f             	xor    $0x1f,%edx
  801f5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801f5d:	75 39                	jne    801f98 <__udivdi3+0x98>
  801f5f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801f62:	0f 86 a0 00 00 00    	jbe    802008 <__udivdi3+0x108>
  801f68:	39 f8                	cmp    %edi,%eax
  801f6a:	0f 82 98 00 00 00    	jb     802008 <__udivdi3+0x108>
  801f70:	31 ff                	xor    %edi,%edi
  801f72:	31 c9                	xor    %ecx,%ecx
  801f74:	89 c8                	mov    %ecx,%eax
  801f76:	89 fa                	mov    %edi,%edx
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    
  801f7f:	90                   	nop
  801f80:	89 d1                	mov    %edx,%ecx
  801f82:	89 fa                	mov    %edi,%edx
  801f84:	89 c8                	mov    %ecx,%eax
  801f86:	31 ff                	xor    %edi,%edi
  801f88:	f7 f6                	div    %esi
  801f8a:	89 c1                	mov    %eax,%ecx
  801f8c:	89 fa                	mov    %edi,%edx
  801f8e:	89 c8                	mov    %ecx,%eax
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	5e                   	pop    %esi
  801f94:	5f                   	pop    %edi
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    
  801f97:	90                   	nop
  801f98:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f9c:	89 f2                	mov    %esi,%edx
  801f9e:	d3 e0                	shl    %cl,%eax
  801fa0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fa3:	b8 20 00 00 00       	mov    $0x20,%eax
  801fa8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801fab:	89 c1                	mov    %eax,%ecx
  801fad:	d3 ea                	shr    %cl,%edx
  801faf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fb3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801fb6:	d3 e6                	shl    %cl,%esi
  801fb8:	89 c1                	mov    %eax,%ecx
  801fba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801fbd:	89 fe                	mov    %edi,%esi
  801fbf:	d3 ee                	shr    %cl,%esi
  801fc1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fc5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fcb:	d3 e7                	shl    %cl,%edi
  801fcd:	89 c1                	mov    %eax,%ecx
  801fcf:	d3 ea                	shr    %cl,%edx
  801fd1:	09 d7                	or     %edx,%edi
  801fd3:	89 f2                	mov    %esi,%edx
  801fd5:	89 f8                	mov    %edi,%eax
  801fd7:	f7 75 ec             	divl   -0x14(%ebp)
  801fda:	89 d6                	mov    %edx,%esi
  801fdc:	89 c7                	mov    %eax,%edi
  801fde:	f7 65 e8             	mull   -0x18(%ebp)
  801fe1:	39 d6                	cmp    %edx,%esi
  801fe3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fe6:	72 30                	jb     802018 <__udivdi3+0x118>
  801fe8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801feb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801fef:	d3 e2                	shl    %cl,%edx
  801ff1:	39 c2                	cmp    %eax,%edx
  801ff3:	73 05                	jae    801ffa <__udivdi3+0xfa>
  801ff5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801ff8:	74 1e                	je     802018 <__udivdi3+0x118>
  801ffa:	89 f9                	mov    %edi,%ecx
  801ffc:	31 ff                	xor    %edi,%edi
  801ffe:	e9 71 ff ff ff       	jmp    801f74 <__udivdi3+0x74>
  802003:	90                   	nop
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80200f:	e9 60 ff ff ff       	jmp    801f74 <__udivdi3+0x74>
  802014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802018:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80201b:	31 ff                	xor    %edi,%edi
  80201d:	89 c8                	mov    %ecx,%eax
  80201f:	89 fa                	mov    %edi,%edx
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
	...

00802030 <__umoddi3>:
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	57                   	push   %edi
  802034:	56                   	push   %esi
  802035:	83 ec 20             	sub    $0x20,%esp
  802038:	8b 55 14             	mov    0x14(%ebp),%edx
  80203b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80203e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802041:	8b 75 0c             	mov    0xc(%ebp),%esi
  802044:	85 d2                	test   %edx,%edx
  802046:	89 c8                	mov    %ecx,%eax
  802048:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80204b:	75 13                	jne    802060 <__umoddi3+0x30>
  80204d:	39 f7                	cmp    %esi,%edi
  80204f:	76 3f                	jbe    802090 <__umoddi3+0x60>
  802051:	89 f2                	mov    %esi,%edx
  802053:	f7 f7                	div    %edi
  802055:	89 d0                	mov    %edx,%eax
  802057:	31 d2                	xor    %edx,%edx
  802059:	83 c4 20             	add    $0x20,%esp
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    
  802060:	39 f2                	cmp    %esi,%edx
  802062:	77 4c                	ja     8020b0 <__umoddi3+0x80>
  802064:	0f bd ca             	bsr    %edx,%ecx
  802067:	83 f1 1f             	xor    $0x1f,%ecx
  80206a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80206d:	75 51                	jne    8020c0 <__umoddi3+0x90>
  80206f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802072:	0f 87 e0 00 00 00    	ja     802158 <__umoddi3+0x128>
  802078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207b:	29 f8                	sub    %edi,%eax
  80207d:	19 d6                	sbb    %edx,%esi
  80207f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802085:	89 f2                	mov    %esi,%edx
  802087:	83 c4 20             	add    $0x20,%esp
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    
  80208e:	66 90                	xchg   %ax,%ax
  802090:	85 ff                	test   %edi,%edi
  802092:	75 0b                	jne    80209f <__umoddi3+0x6f>
  802094:	b8 01 00 00 00       	mov    $0x1,%eax
  802099:	31 d2                	xor    %edx,%edx
  80209b:	f7 f7                	div    %edi
  80209d:	89 c7                	mov    %eax,%edi
  80209f:	89 f0                	mov    %esi,%eax
  8020a1:	31 d2                	xor    %edx,%edx
  8020a3:	f7 f7                	div    %edi
  8020a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a8:	f7 f7                	div    %edi
  8020aa:	eb a9                	jmp    802055 <__umoddi3+0x25>
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	83 c4 20             	add    $0x20,%esp
  8020b7:	5e                   	pop    %esi
  8020b8:	5f                   	pop    %edi
  8020b9:	5d                   	pop    %ebp
  8020ba:	c3                   	ret    
  8020bb:	90                   	nop
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020c4:	d3 e2                	shl    %cl,%edx
  8020c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8020ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8020d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	d3 ea                	shr    %cl,%edx
  8020dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8020e3:	d3 e7                	shl    %cl,%edi
  8020e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8020e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020ec:	89 f2                	mov    %esi,%edx
  8020ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8020f1:	89 c7                	mov    %eax,%edi
  8020f3:	d3 ea                	shr    %cl,%edx
  8020f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8020f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020fc:	89 c2                	mov    %eax,%edx
  8020fe:	d3 e6                	shl    %cl,%esi
  802100:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802104:	d3 ea                	shr    %cl,%edx
  802106:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80210a:	09 d6                	or     %edx,%esi
  80210c:	89 f0                	mov    %esi,%eax
  80210e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802111:	d3 e7                	shl    %cl,%edi
  802113:	89 f2                	mov    %esi,%edx
  802115:	f7 75 f4             	divl   -0xc(%ebp)
  802118:	89 d6                	mov    %edx,%esi
  80211a:	f7 65 e8             	mull   -0x18(%ebp)
  80211d:	39 d6                	cmp    %edx,%esi
  80211f:	72 2b                	jb     80214c <__umoddi3+0x11c>
  802121:	39 c7                	cmp    %eax,%edi
  802123:	72 23                	jb     802148 <__umoddi3+0x118>
  802125:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802129:	29 c7                	sub    %eax,%edi
  80212b:	19 d6                	sbb    %edx,%esi
  80212d:	89 f0                	mov    %esi,%eax
  80212f:	89 f2                	mov    %esi,%edx
  802131:	d3 ef                	shr    %cl,%edi
  802133:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802137:	d3 e0                	shl    %cl,%eax
  802139:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80213d:	09 f8                	or     %edi,%eax
  80213f:	d3 ea                	shr    %cl,%edx
  802141:	83 c4 20             	add    $0x20,%esp
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	39 d6                	cmp    %edx,%esi
  80214a:	75 d9                	jne    802125 <__umoddi3+0xf5>
  80214c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80214f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802152:	eb d1                	jmp    802125 <__umoddi3+0xf5>
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	0f 82 18 ff ff ff    	jb     802078 <__umoddi3+0x48>
  802160:	e9 1d ff ff ff       	jmp    802082 <__umoddi3+0x52>
