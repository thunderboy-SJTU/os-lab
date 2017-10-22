
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004e:	e8 ca 04 00 00       	call   80051d <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	89 c2                	mov    %eax,%edx
  80005a:	c1 e2 07             	shl    $0x7,%edx
  80005d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x38>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800078:	89 34 24             	mov    %esi,(%esp)
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
}
  800085:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800088:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008b:	89 ec                	mov    %ebp,%esp
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 bb 04 00 00       	call   80055d <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bb:	89 d1                	mov    %edx,%ecx
  8000bd:	89 d3                	mov    %edx,%ebx
  8000bf:	89 d7                	mov    %edx,%edi
  8000c1:	51                   	push   %ecx
  8000c2:	52                   	push   %edx
  8000c3:	53                   	push   %ebx
  8000c4:	54                   	push   %esp
  8000c5:	55                   	push   %ebp
  8000c6:	56                   	push   %esi
  8000c7:	57                   	push   %edi
  8000c8:	54                   	push   %esp
  8000c9:	5d                   	pop    %ebp
  8000ca:	8d 35 d2 00 80 00    	lea    0x8000d2,%esi
  8000d0:	0f 34                	sysenter 
  8000d2:	5f                   	pop    %edi
  8000d3:	5e                   	pop    %esi
  8000d4:	5d                   	pop    %ebp
  8000d5:	5c                   	pop    %esp
  8000d6:	5b                   	pop    %ebx
  8000d7:	5a                   	pop    %edx
  8000d8:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d9:	8b 1c 24             	mov    (%esp),%ebx
  8000dc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000e0:	89 ec                	mov    %ebp,%esp
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 08             	sub    $0x8,%esp
  8000ea:	89 1c 24             	mov    %ebx,(%esp)
  8000ed:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	89 c3                	mov    %eax,%ebx
  8000fe:	89 c7                	mov    %eax,%edi
  800100:	51                   	push   %ecx
  800101:	52                   	push   %edx
  800102:	53                   	push   %ebx
  800103:	54                   	push   %esp
  800104:	55                   	push   %ebp
  800105:	56                   	push   %esi
  800106:	57                   	push   %edi
  800107:	54                   	push   %esp
  800108:	5d                   	pop    %ebp
  800109:	8d 35 11 01 80 00    	lea    0x800111,%esi
  80010f:	0f 34                	sysenter 
  800111:	5f                   	pop    %edi
  800112:	5e                   	pop    %esi
  800113:	5d                   	pop    %ebp
  800114:	5c                   	pop    %esp
  800115:	5b                   	pop    %ebx
  800116:	5a                   	pop    %edx
  800117:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800118:	8b 1c 24             	mov    (%esp),%ebx
  80011b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80011f:	89 ec                	mov    %ebp,%esp
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 28             	sub    $0x28,%esp
  800129:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80012c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80012f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800134:	b8 0e 00 00 00       	mov    $0xe,%eax
  800139:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80013c:	8b 55 08             	mov    0x8(%ebp),%edx
  80013f:	89 df                	mov    %ebx,%edi
  800141:	51                   	push   %ecx
  800142:	52                   	push   %edx
  800143:	53                   	push   %ebx
  800144:	54                   	push   %esp
  800145:	55                   	push   %ebp
  800146:	56                   	push   %esi
  800147:	57                   	push   %edi
  800148:	54                   	push   %esp
  800149:	5d                   	pop    %ebp
  80014a:	8d 35 52 01 80 00    	lea    0x800152,%esi
  800150:	0f 34                	sysenter 
  800152:	5f                   	pop    %edi
  800153:	5e                   	pop    %esi
  800154:	5d                   	pop    %ebp
  800155:	5c                   	pop    %esp
  800156:	5b                   	pop    %ebx
  800157:	5a                   	pop    %edx
  800158:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800159:	85 c0                	test   %eax,%eax
  80015b:	7e 28                	jle    800185 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80015d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800161:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800168:	00 
  800169:	c7 44 24 08 4a 16 80 	movl   $0x80164a,0x8(%esp)
  800170:	00 
  800171:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800178:	00 
  800179:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  800180:	e8 43 04 00 00       	call   8005c8 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800185:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800188:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80018b:	89 ec                	mov    %ebp,%esp
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	89 1c 24             	mov    %ebx,(%esp)
  800198:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80019c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	89 cb                	mov    %ecx,%ebx
  8001ab:	89 cf                	mov    %ecx,%edi
  8001ad:	51                   	push   %ecx
  8001ae:	52                   	push   %edx
  8001af:	53                   	push   %ebx
  8001b0:	54                   	push   %esp
  8001b1:	55                   	push   %ebp
  8001b2:	56                   	push   %esi
  8001b3:	57                   	push   %edi
  8001b4:	54                   	push   %esp
  8001b5:	5d                   	pop    %ebp
  8001b6:	8d 35 be 01 80 00    	lea    0x8001be,%esi
  8001bc:	0f 34                	sysenter 
  8001be:	5f                   	pop    %edi
  8001bf:	5e                   	pop    %esi
  8001c0:	5d                   	pop    %ebp
  8001c1:	5c                   	pop    %esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5a                   	pop    %edx
  8001c4:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001c5:	8b 1c 24             	mov    (%esp),%ebx
  8001c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001cc:	89 ec                	mov    %ebp,%esp
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 28             	sub    $0x28,%esp
  8001d6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001d9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8001e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e9:	89 cb                	mov    %ecx,%ebx
  8001eb:	89 cf                	mov    %ecx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800205:	85 c0                	test   %eax,%eax
  800207:	7e 28                	jle    800231 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800209:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800214:	00 
  800215:	c7 44 24 08 4a 16 80 	movl   $0x80164a,0x8(%esp)
  80021c:	00 
  80021d:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800224:	00 
  800225:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  80022c:	e8 97 03 00 00       	call   8005c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800231:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800234:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800237:	89 ec                	mov    %ebp,%esp
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 08             	sub    $0x8,%esp
  800241:	89 1c 24             	mov    %ebx,(%esp)
  800244:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800248:	b8 0c 00 00 00       	mov    $0xc,%eax
  80024d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800250:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	51                   	push   %ecx
  80025a:	52                   	push   %edx
  80025b:	53                   	push   %ebx
  80025c:	54                   	push   %esp
  80025d:	55                   	push   %ebp
  80025e:	56                   	push   %esi
  80025f:	57                   	push   %edi
  800260:	54                   	push   %esp
  800261:	5d                   	pop    %ebp
  800262:	8d 35 6a 02 80 00    	lea    0x80026a,%esi
  800268:	0f 34                	sysenter 
  80026a:	5f                   	pop    %edi
  80026b:	5e                   	pop    %esi
  80026c:	5d                   	pop    %ebp
  80026d:	5c                   	pop    %esp
  80026e:	5b                   	pop    %ebx
  80026f:	5a                   	pop    %edx
  800270:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800271:	8b 1c 24             	mov    (%esp),%ebx
  800274:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800278:	89 ec                	mov    %ebp,%esp
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 28             	sub    $0x28,%esp
  800282:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800285:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	51                   	push   %ecx
  80029b:	52                   	push   %edx
  80029c:	53                   	push   %ebx
  80029d:	54                   	push   %esp
  80029e:	55                   	push   %ebp
  80029f:	56                   	push   %esi
  8002a0:	57                   	push   %edi
  8002a1:	54                   	push   %esp
  8002a2:	5d                   	pop    %ebp
  8002a3:	8d 35 ab 02 80 00    	lea    0x8002ab,%esi
  8002a9:	0f 34                	sysenter 
  8002ab:	5f                   	pop    %edi
  8002ac:	5e                   	pop    %esi
  8002ad:	5d                   	pop    %ebp
  8002ae:	5c                   	pop    %esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5a                   	pop    %edx
  8002b1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 28                	jle    8002de <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ba:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 08 4a 16 80 	movl   $0x80164a,0x8(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8002d1:	00 
  8002d2:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  8002d9:	e8 ea 02 00 00       	call   8005c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e4:	89 ec                	mov    %ebp,%esp
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 28             	sub    $0x28,%esp
  8002ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002f1:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800301:	8b 55 08             	mov    0x8(%ebp),%edx
  800304:	89 df                	mov    %ebx,%edi
  800306:	51                   	push   %ecx
  800307:	52                   	push   %edx
  800308:	53                   	push   %ebx
  800309:	54                   	push   %esp
  80030a:	55                   	push   %ebp
  80030b:	56                   	push   %esi
  80030c:	57                   	push   %edi
  80030d:	54                   	push   %esp
  80030e:	5d                   	pop    %ebp
  80030f:	8d 35 17 03 80 00    	lea    0x800317,%esi
  800315:	0f 34                	sysenter 
  800317:	5f                   	pop    %edi
  800318:	5e                   	pop    %esi
  800319:	5d                   	pop    %ebp
  80031a:	5c                   	pop    %esp
  80031b:	5b                   	pop    %ebx
  80031c:	5a                   	pop    %edx
  80031d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80031e:	85 c0                	test   %eax,%eax
  800320:	7e 28                	jle    80034a <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800322:	89 44 24 10          	mov    %eax,0x10(%esp)
  800326:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80032d:	00 
  80032e:	c7 44 24 08 4a 16 80 	movl   $0x80164a,0x8(%esp)
  800335:	00 
  800336:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80033d:	00 
  80033e:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  800345:	e8 7e 02 00 00       	call   8005c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80034a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80034d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800350:	89 ec                	mov    %ebp,%esp
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 28             	sub    $0x28,%esp
  80035a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80035d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800360:	bb 00 00 00 00       	mov    $0x0,%ebx
  800365:	b8 07 00 00 00       	mov    $0x7,%eax
  80036a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036d:	8b 55 08             	mov    0x8(%ebp),%edx
  800370:	89 df                	mov    %ebx,%edi
  800372:	51                   	push   %ecx
  800373:	52                   	push   %edx
  800374:	53                   	push   %ebx
  800375:	54                   	push   %esp
  800376:	55                   	push   %ebp
  800377:	56                   	push   %esi
  800378:	57                   	push   %edi
  800379:	54                   	push   %esp
  80037a:	5d                   	pop    %ebp
  80037b:	8d 35 83 03 80 00    	lea    0x800383,%esi
  800381:	0f 34                	sysenter 
  800383:	5f                   	pop    %edi
  800384:	5e                   	pop    %esi
  800385:	5d                   	pop    %ebp
  800386:	5c                   	pop    %esp
  800387:	5b                   	pop    %ebx
  800388:	5a                   	pop    %edx
  800389:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80038a:	85 c0                	test   %eax,%eax
  80038c:	7e 28                	jle    8003b6 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800392:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800399:	00 
  80039a:	c7 44 24 08 4a 16 80 	movl   $0x80164a,0x8(%esp)
  8003a1:	00 
  8003a2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8003a9:	00 
  8003aa:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  8003b1:	e8 12 02 00 00       	call   8005c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8003b6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003b9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003bc:	89 ec                	mov    %ebp,%esp
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	83 ec 28             	sub    $0x28,%esp
  8003c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003c9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003cc:	8b 7d 18             	mov    0x18(%ebp),%edi
  8003cf:	0b 7d 14             	or     0x14(%ebp),%edi
  8003d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8003d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e0:	51                   	push   %ecx
  8003e1:	52                   	push   %edx
  8003e2:	53                   	push   %ebx
  8003e3:	54                   	push   %esp
  8003e4:	55                   	push   %ebp
  8003e5:	56                   	push   %esi
  8003e6:	57                   	push   %edi
  8003e7:	54                   	push   %esp
  8003e8:	5d                   	pop    %ebp
  8003e9:	8d 35 f1 03 80 00    	lea    0x8003f1,%esi
  8003ef:	0f 34                	sysenter 
  8003f1:	5f                   	pop    %edi
  8003f2:	5e                   	pop    %esi
  8003f3:	5d                   	pop    %ebp
  8003f4:	5c                   	pop    %esp
  8003f5:	5b                   	pop    %ebx
  8003f6:	5a                   	pop    %edx
  8003f7:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	7e 28                	jle    800424 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800400:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800407:	00 
  800408:	c7 44 24 08 4a 16 80 	movl   $0x80164a,0x8(%esp)
  80040f:	00 
  800410:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800417:	00 
  800418:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  80041f:	e8 a4 01 00 00       	call   8005c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  800424:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800427:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80042a:	89 ec                	mov    %ebp,%esp
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 28             	sub    $0x28,%esp
  800434:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800437:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80043a:	bf 00 00 00 00       	mov    $0x0,%edi
  80043f:	b8 05 00 00 00       	mov    $0x5,%eax
  800444:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800447:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044a:	8b 55 08             	mov    0x8(%ebp),%edx
  80044d:	51                   	push   %ecx
  80044e:	52                   	push   %edx
  80044f:	53                   	push   %ebx
  800450:	54                   	push   %esp
  800451:	55                   	push   %ebp
  800452:	56                   	push   %esi
  800453:	57                   	push   %edi
  800454:	54                   	push   %esp
  800455:	5d                   	pop    %ebp
  800456:	8d 35 5e 04 80 00    	lea    0x80045e,%esi
  80045c:	0f 34                	sysenter 
  80045e:	5f                   	pop    %edi
  80045f:	5e                   	pop    %esi
  800460:	5d                   	pop    %ebp
  800461:	5c                   	pop    %esp
  800462:	5b                   	pop    %ebx
  800463:	5a                   	pop    %edx
  800464:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800465:	85 c0                	test   %eax,%eax
  800467:	7e 28                	jle    800491 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800469:	89 44 24 10          	mov    %eax,0x10(%esp)
  80046d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800474:	00 
  800475:	c7 44 24 08 4a 16 80 	movl   $0x80164a,0x8(%esp)
  80047c:	00 
  80047d:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800484:	00 
  800485:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  80048c:	e8 37 01 00 00       	call   8005c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800491:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800494:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800497:	89 ec                	mov    %ebp,%esp
  800499:	5d                   	pop    %ebp
  80049a:	c3                   	ret    

0080049b <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	89 1c 24             	mov    %ebx,(%esp)
  8004a4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ad:	b8 0b 00 00 00       	mov    $0xb,%eax
  8004b2:	89 d1                	mov    %edx,%ecx
  8004b4:	89 d3                	mov    %edx,%ebx
  8004b6:	89 d7                	mov    %edx,%edi
  8004b8:	51                   	push   %ecx
  8004b9:	52                   	push   %edx
  8004ba:	53                   	push   %ebx
  8004bb:	54                   	push   %esp
  8004bc:	55                   	push   %ebp
  8004bd:	56                   	push   %esi
  8004be:	57                   	push   %edi
  8004bf:	54                   	push   %esp
  8004c0:	5d                   	pop    %ebp
  8004c1:	8d 35 c9 04 80 00    	lea    0x8004c9,%esi
  8004c7:	0f 34                	sysenter 
  8004c9:	5f                   	pop    %edi
  8004ca:	5e                   	pop    %esi
  8004cb:	5d                   	pop    %ebp
  8004cc:	5c                   	pop    %esp
  8004cd:	5b                   	pop    %ebx
  8004ce:	5a                   	pop    %edx
  8004cf:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8004d0:	8b 1c 24             	mov    (%esp),%ebx
  8004d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004d7:	89 ec                	mov    %ebp,%esp
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	89 1c 24             	mov    %ebx,(%esp)
  8004e4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ed:	b8 04 00 00 00       	mov    $0x4,%eax
  8004f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f8:	89 df                	mov    %ebx,%edi
  8004fa:	51                   	push   %ecx
  8004fb:	52                   	push   %edx
  8004fc:	53                   	push   %ebx
  8004fd:	54                   	push   %esp
  8004fe:	55                   	push   %ebp
  8004ff:	56                   	push   %esi
  800500:	57                   	push   %edi
  800501:	54                   	push   %esp
  800502:	5d                   	pop    %ebp
  800503:	8d 35 0b 05 80 00    	lea    0x80050b,%esi
  800509:	0f 34                	sysenter 
  80050b:	5f                   	pop    %edi
  80050c:	5e                   	pop    %esi
  80050d:	5d                   	pop    %ebp
  80050e:	5c                   	pop    %esp
  80050f:	5b                   	pop    %ebx
  800510:	5a                   	pop    %edx
  800511:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800512:	8b 1c 24             	mov    (%esp),%ebx
  800515:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800519:	89 ec                	mov    %ebp,%esp
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	89 1c 24             	mov    %ebx,(%esp)
  800526:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80052a:	ba 00 00 00 00       	mov    $0x0,%edx
  80052f:	b8 02 00 00 00       	mov    $0x2,%eax
  800534:	89 d1                	mov    %edx,%ecx
  800536:	89 d3                	mov    %edx,%ebx
  800538:	89 d7                	mov    %edx,%edi
  80053a:	51                   	push   %ecx
  80053b:	52                   	push   %edx
  80053c:	53                   	push   %ebx
  80053d:	54                   	push   %esp
  80053e:	55                   	push   %ebp
  80053f:	56                   	push   %esi
  800540:	57                   	push   %edi
  800541:	54                   	push   %esp
  800542:	5d                   	pop    %ebp
  800543:	8d 35 4b 05 80 00    	lea    0x80054b,%esi
  800549:	0f 34                	sysenter 
  80054b:	5f                   	pop    %edi
  80054c:	5e                   	pop    %esi
  80054d:	5d                   	pop    %ebp
  80054e:	5c                   	pop    %esp
  80054f:	5b                   	pop    %ebx
  800550:	5a                   	pop    %edx
  800551:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800552:	8b 1c 24             	mov    (%esp),%ebx
  800555:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800559:	89 ec                	mov    %ebp,%esp
  80055b:	5d                   	pop    %ebp
  80055c:	c3                   	ret    

0080055d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	83 ec 28             	sub    $0x28,%esp
  800563:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800566:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800569:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056e:	b8 03 00 00 00       	mov    $0x3,%eax
  800573:	8b 55 08             	mov    0x8(%ebp),%edx
  800576:	89 cb                	mov    %ecx,%ebx
  800578:	89 cf                	mov    %ecx,%edi
  80057a:	51                   	push   %ecx
  80057b:	52                   	push   %edx
  80057c:	53                   	push   %ebx
  80057d:	54                   	push   %esp
  80057e:	55                   	push   %ebp
  80057f:	56                   	push   %esi
  800580:	57                   	push   %edi
  800581:	54                   	push   %esp
  800582:	5d                   	pop    %ebp
  800583:	8d 35 8b 05 80 00    	lea    0x80058b,%esi
  800589:	0f 34                	sysenter 
  80058b:	5f                   	pop    %edi
  80058c:	5e                   	pop    %esi
  80058d:	5d                   	pop    %ebp
  80058e:	5c                   	pop    %esp
  80058f:	5b                   	pop    %ebx
  800590:	5a                   	pop    %edx
  800591:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800592:	85 c0                	test   %eax,%eax
  800594:	7e 28                	jle    8005be <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800596:	89 44 24 10          	mov    %eax,0x10(%esp)
  80059a:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8005a1:	00 
  8005a2:	c7 44 24 08 4a 16 80 	movl   $0x80164a,0x8(%esp)
  8005a9:	00 
  8005aa:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8005b1:	00 
  8005b2:	c7 04 24 67 16 80 00 	movl   $0x801667,(%esp)
  8005b9:	e8 0a 00 00 00       	call   8005c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8005be:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005c4:	89 ec                	mov    %ebp,%esp
  8005c6:	5d                   	pop    %ebp
  8005c7:	c3                   	ret    

008005c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005c8:	55                   	push   %ebp
  8005c9:	89 e5                	mov    %esp,%ebp
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8005d0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8005d3:	a1 08 20 80 00       	mov    0x802008,%eax
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	74 10                	je     8005ec <_panic+0x24>
		cprintf("%s: ", argv0);
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	c7 04 24 75 16 80 00 	movl   $0x801675,(%esp)
  8005e7:	e8 ad 00 00 00       	call   800699 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ec:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8005f2:	e8 26 ff ff ff       	call   80051d <sys_getenvid>
  8005f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fa:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800601:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800605:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060d:	c7 04 24 7c 16 80 00 	movl   $0x80167c,(%esp)
  800614:	e8 80 00 00 00       	call   800699 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800619:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061d:	8b 45 10             	mov    0x10(%ebp),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	e8 10 00 00 00       	call   800638 <vcprintf>
	cprintf("\n");
  800628:	c7 04 24 7a 16 80 00 	movl   $0x80167a,(%esp)
  80062f:	e8 65 00 00 00       	call   800699 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800634:	cc                   	int3   
  800635:	eb fd                	jmp    800634 <_panic+0x6c>
	...

00800638 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800641:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800648:	00 00 00 
	b.cnt = 0;
  80064b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800652:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800655:	8b 45 0c             	mov    0xc(%ebp),%eax
  800658:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800663:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	c7 04 24 b3 06 80 00 	movl   $0x8006b3,(%esp)
  800674:	e8 d3 01 00 00       	call   80084c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800679:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80067f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800683:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	e8 53 fa ff ff       	call   8000e4 <sys_cputs>

	return b.cnt;
}
  800691:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800697:	c9                   	leave  
  800698:	c3                   	ret    

00800699 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80069f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a9:	89 04 24             	mov    %eax,(%esp)
  8006ac:	e8 87 ff ff ff       	call   800638 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	53                   	push   %ebx
  8006b7:	83 ec 14             	sub    $0x14,%esp
  8006ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006bd:	8b 03                	mov    (%ebx),%eax
  8006bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006c6:	83 c0 01             	add    $0x1,%eax
  8006c9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006cb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006d0:	75 19                	jne    8006eb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8006d2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8006d9:	00 
  8006da:	8d 43 08             	lea    0x8(%ebx),%eax
  8006dd:	89 04 24             	mov    %eax,(%esp)
  8006e0:	e8 ff f9 ff ff       	call   8000e4 <sys_cputs>
		b->idx = 0;
  8006e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8006eb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006ef:	83 c4 14             	add    $0x14,%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    
	...

00800700 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	57                   	push   %edi
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	83 ec 4c             	sub    $0x4c,%esp
  800709:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070c:	89 d6                	mov    %edx,%esi
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
  800717:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800720:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800723:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	39 d1                	cmp    %edx,%ecx
  80072d:	72 07                	jb     800736 <printnum_v2+0x36>
  80072f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800732:	39 d0                	cmp    %edx,%eax
  800734:	77 5f                	ja     800795 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800736:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80073a:	83 eb 01             	sub    $0x1,%ebx
  80073d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800741:	89 44 24 08          	mov    %eax,0x8(%esp)
  800745:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800749:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80074d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800750:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800753:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800756:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80075a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800761:	00 
  800762:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80076b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076f:	e8 4c 0c 00 00       	call   8013c0 <__udivdi3>
  800774:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800777:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80077a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80077e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800782:	89 04 24             	mov    %eax,(%esp)
  800785:	89 54 24 04          	mov    %edx,0x4(%esp)
  800789:	89 f2                	mov    %esi,%edx
  80078b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80078e:	e8 6d ff ff ff       	call   800700 <printnum_v2>
  800793:	eb 1e                	jmp    8007b3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800795:	83 ff 2d             	cmp    $0x2d,%edi
  800798:	74 19                	je     8007b3 <printnum_v2+0xb3>
		while (--width > 0)
  80079a:	83 eb 01             	sub    $0x1,%ebx
  80079d:	85 db                	test   %ebx,%ebx
  80079f:	90                   	nop
  8007a0:	7e 11                	jle    8007b3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8007a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a6:	89 3c 24             	mov    %edi,(%esp)
  8007a9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007ac:	83 eb 01             	sub    $0x1,%ebx
  8007af:	85 db                	test   %ebx,%ebx
  8007b1:	7f ef                	jg     8007a2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007c9:	00 
  8007ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cd:	89 14 24             	mov    %edx,(%esp)
  8007d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007d7:	e8 14 0d 00 00       	call   8014f0 <__umoddi3>
  8007dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e0:	0f be 80 9f 16 80 00 	movsbl 0x80169f(%eax),%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007ed:	83 c4 4c             	add    $0x4c,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007f8:	83 fa 01             	cmp    $0x1,%edx
  8007fb:	7e 0e                	jle    80080b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800802:	89 08                	mov    %ecx,(%eax)
  800804:	8b 02                	mov    (%edx),%eax
  800806:	8b 52 04             	mov    0x4(%edx),%edx
  800809:	eb 22                	jmp    80082d <getuint+0x38>
	else if (lflag)
  80080b:	85 d2                	test   %edx,%edx
  80080d:	74 10                	je     80081f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80080f:	8b 10                	mov    (%eax),%edx
  800811:	8d 4a 04             	lea    0x4(%edx),%ecx
  800814:	89 08                	mov    %ecx,(%eax)
  800816:	8b 02                	mov    (%edx),%eax
  800818:	ba 00 00 00 00       	mov    $0x0,%edx
  80081d:	eb 0e                	jmp    80082d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80081f:	8b 10                	mov    (%eax),%edx
  800821:	8d 4a 04             	lea    0x4(%edx),%ecx
  800824:	89 08                	mov    %ecx,(%eax)
  800826:	8b 02                	mov    (%edx),%eax
  800828:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800835:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800839:	8b 10                	mov    (%eax),%edx
  80083b:	3b 50 04             	cmp    0x4(%eax),%edx
  80083e:	73 0a                	jae    80084a <sprintputch+0x1b>
		*b->buf++ = ch;
  800840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800843:	88 0a                	mov    %cl,(%edx)
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	89 10                	mov    %edx,(%eax)
}
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	57                   	push   %edi
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	83 ec 6c             	sub    $0x6c,%esp
  800855:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800858:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80085f:	eb 1a                	jmp    80087b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800861:	85 c0                	test   %eax,%eax
  800863:	0f 84 66 06 00 00    	je     800ecf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800870:	89 04 24             	mov    %eax,(%esp)
  800873:	ff 55 08             	call   *0x8(%ebp)
  800876:	eb 03                	jmp    80087b <vprintfmt+0x2f>
  800878:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80087b:	0f b6 07             	movzbl (%edi),%eax
  80087e:	83 c7 01             	add    $0x1,%edi
  800881:	83 f8 25             	cmp    $0x25,%eax
  800884:	75 db                	jne    800861 <vprintfmt+0x15>
  800886:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80088a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800896:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80089b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008a2:	be 00 00 00 00       	mov    $0x0,%esi
  8008a7:	eb 06                	jmp    8008af <vprintfmt+0x63>
  8008a9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8008ad:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008af:	0f b6 17             	movzbl (%edi),%edx
  8008b2:	0f b6 c2             	movzbl %dl,%eax
  8008b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008b8:	8d 47 01             	lea    0x1(%edi),%eax
  8008bb:	83 ea 23             	sub    $0x23,%edx
  8008be:	80 fa 55             	cmp    $0x55,%dl
  8008c1:	0f 87 60 05 00 00    	ja     800e27 <vprintfmt+0x5db>
  8008c7:	0f b6 d2             	movzbl %dl,%edx
  8008ca:	ff 24 95 e0 17 80 00 	jmp    *0x8017e0(,%edx,4)
  8008d1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8008d6:	eb d5                	jmp    8008ad <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008db:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8008de:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8008e1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8008e4:	83 ff 09             	cmp    $0x9,%edi
  8008e7:	76 08                	jbe    8008f1 <vprintfmt+0xa5>
  8008e9:	eb 40                	jmp    80092b <vprintfmt+0xdf>
  8008eb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8008ef:	eb bc                	jmp    8008ad <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008f1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8008f4:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  8008f7:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  8008fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8008fe:	8d 7a d0             	lea    -0x30(%edx),%edi
  800901:	83 ff 09             	cmp    $0x9,%edi
  800904:	76 eb                	jbe    8008f1 <vprintfmt+0xa5>
  800906:	eb 23                	jmp    80092b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800908:	8b 55 14             	mov    0x14(%ebp),%edx
  80090b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80090e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800911:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800913:	eb 16                	jmp    80092b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800915:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800918:	c1 fa 1f             	sar    $0x1f,%edx
  80091b:	f7 d2                	not    %edx
  80091d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800920:	eb 8b                	jmp    8008ad <vprintfmt+0x61>
  800922:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800929:	eb 82                	jmp    8008ad <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80092b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80092f:	0f 89 78 ff ff ff    	jns    8008ad <vprintfmt+0x61>
  800935:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800938:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80093b:	e9 6d ff ff ff       	jmp    8008ad <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800940:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800943:	e9 65 ff ff ff       	jmp    8008ad <vprintfmt+0x61>
  800948:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80094b:	8b 45 14             	mov    0x14(%ebp),%eax
  80094e:	8d 50 04             	lea    0x4(%eax),%edx
  800951:	89 55 14             	mov    %edx,0x14(%ebp)
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095b:	8b 00                	mov    (%eax),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	ff 55 08             	call   *0x8(%ebp)
  800963:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800966:	e9 10 ff ff ff       	jmp    80087b <vprintfmt+0x2f>
  80096b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80096e:	8b 45 14             	mov    0x14(%ebp),%eax
  800971:	8d 50 04             	lea    0x4(%eax),%edx
  800974:	89 55 14             	mov    %edx,0x14(%ebp)
  800977:	8b 00                	mov    (%eax),%eax
  800979:	89 c2                	mov    %eax,%edx
  80097b:	c1 fa 1f             	sar    $0x1f,%edx
  80097e:	31 d0                	xor    %edx,%eax
  800980:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800982:	83 f8 08             	cmp    $0x8,%eax
  800985:	7f 0b                	jg     800992 <vprintfmt+0x146>
  800987:	8b 14 85 40 19 80 00 	mov    0x801940(,%eax,4),%edx
  80098e:	85 d2                	test   %edx,%edx
  800990:	75 26                	jne    8009b8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  800992:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800996:	c7 44 24 08 b0 16 80 	movl   $0x8016b0,0x8(%esp)
  80099d:	00 
  80099e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a8:	89 1c 24             	mov    %ebx,(%esp)
  8009ab:	e8 a7 05 00 00       	call   800f57 <printfmt>
  8009b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009b3:	e9 c3 fe ff ff       	jmp    80087b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009bc:	c7 44 24 08 b9 16 80 	movl   $0x8016b9,0x8(%esp)
  8009c3:	00 
  8009c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ce:	89 14 24             	mov    %edx,(%esp)
  8009d1:	e8 81 05 00 00       	call   800f57 <printfmt>
  8009d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009d9:	e9 9d fe ff ff       	jmp    80087b <vprintfmt+0x2f>
  8009de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	89 d9                	mov    %ebx,%ecx
  8009e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ee:	8d 50 04             	lea    0x4(%eax),%edx
  8009f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f4:	8b 30                	mov    (%eax),%esi
  8009f6:	85 f6                	test   %esi,%esi
  8009f8:	75 05                	jne    8009ff <vprintfmt+0x1b3>
  8009fa:	be bc 16 80 00       	mov    $0x8016bc,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  8009ff:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800a03:	7e 06                	jle    800a0b <vprintfmt+0x1bf>
  800a05:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800a09:	75 10                	jne    800a1b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0b:	0f be 06             	movsbl (%esi),%eax
  800a0e:	85 c0                	test   %eax,%eax
  800a10:	0f 85 a2 00 00 00    	jne    800ab8 <vprintfmt+0x26c>
  800a16:	e9 92 00 00 00       	jmp    800aad <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a1b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a1f:	89 34 24             	mov    %esi,(%esp)
  800a22:	e8 74 05 00 00       	call   800f9b <strnlen>
  800a27:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800a2a:	29 c2                	sub    %eax,%edx
  800a2c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800a2f:	85 d2                	test   %edx,%edx
  800a31:	7e d8                	jle    800a0b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800a33:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800a37:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800a3a:	89 d3                	mov    %edx,%ebx
  800a3c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a3f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800a42:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a45:	89 ce                	mov    %ecx,%esi
  800a47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a4b:	89 34 24             	mov    %esi,(%esp)
  800a4e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a51:	83 eb 01             	sub    $0x1,%ebx
  800a54:	85 db                	test   %ebx,%ebx
  800a56:	7f ef                	jg     800a47 <vprintfmt+0x1fb>
  800a58:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800a5b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a5e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800a61:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a68:	eb a1                	jmp    800a0b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a6a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a6e:	74 1b                	je     800a8b <vprintfmt+0x23f>
  800a70:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a73:	83 fa 5e             	cmp    $0x5e,%edx
  800a76:	76 13                	jbe    800a8b <vprintfmt+0x23f>
					putch('?', putdat);
  800a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a86:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a89:	eb 0d                	jmp    800a98 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a92:	89 04 24             	mov    %eax,(%esp)
  800a95:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a98:	83 ef 01             	sub    $0x1,%edi
  800a9b:	0f be 06             	movsbl (%esi),%eax
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	74 05                	je     800aa7 <vprintfmt+0x25b>
  800aa2:	83 c6 01             	add    $0x1,%esi
  800aa5:	eb 1a                	jmp    800ac1 <vprintfmt+0x275>
  800aa7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800aaa:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ab1:	7f 1f                	jg     800ad2 <vprintfmt+0x286>
  800ab3:	e9 c0 fd ff ff       	jmp    800878 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab8:	83 c6 01             	add    $0x1,%esi
  800abb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800abe:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800ac1:	85 db                	test   %ebx,%ebx
  800ac3:	78 a5                	js     800a6a <vprintfmt+0x21e>
  800ac5:	83 eb 01             	sub    $0x1,%ebx
  800ac8:	79 a0                	jns    800a6a <vprintfmt+0x21e>
  800aca:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800acd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800ad0:	eb db                	jmp    800aad <vprintfmt+0x261>
  800ad2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800adb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ade:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ae2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ae9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aeb:	83 eb 01             	sub    $0x1,%ebx
  800aee:	85 db                	test   %ebx,%ebx
  800af0:	7f ec                	jg     800ade <vprintfmt+0x292>
  800af2:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800af5:	e9 81 fd ff ff       	jmp    80087b <vprintfmt+0x2f>
  800afa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800afd:	83 fe 01             	cmp    $0x1,%esi
  800b00:	7e 10                	jle    800b12 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8d 50 08             	lea    0x8(%eax),%edx
  800b08:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0b:	8b 18                	mov    (%eax),%ebx
  800b0d:	8b 70 04             	mov    0x4(%eax),%esi
  800b10:	eb 26                	jmp    800b38 <vprintfmt+0x2ec>
	else if (lflag)
  800b12:	85 f6                	test   %esi,%esi
  800b14:	74 12                	je     800b28 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800b16:	8b 45 14             	mov    0x14(%ebp),%eax
  800b19:	8d 50 04             	lea    0x4(%eax),%edx
  800b1c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1f:	8b 18                	mov    (%eax),%ebx
  800b21:	89 de                	mov    %ebx,%esi
  800b23:	c1 fe 1f             	sar    $0x1f,%esi
  800b26:	eb 10                	jmp    800b38 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800b28:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2b:	8d 50 04             	lea    0x4(%eax),%edx
  800b2e:	89 55 14             	mov    %edx,0x14(%ebp)
  800b31:	8b 18                	mov    (%eax),%ebx
  800b33:	89 de                	mov    %ebx,%esi
  800b35:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800b38:	83 f9 01             	cmp    $0x1,%ecx
  800b3b:	75 1e                	jne    800b5b <vprintfmt+0x30f>
                               if((long long)num > 0){
  800b3d:	85 f6                	test   %esi,%esi
  800b3f:	78 1a                	js     800b5b <vprintfmt+0x30f>
  800b41:	85 f6                	test   %esi,%esi
  800b43:	7f 05                	jg     800b4a <vprintfmt+0x2fe>
  800b45:	83 fb 00             	cmp    $0x0,%ebx
  800b48:	76 11                	jbe    800b5b <vprintfmt+0x30f>
                                   putch('+',putdat);
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b51:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800b58:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  800b5b:	85 f6                	test   %esi,%esi
  800b5d:	78 13                	js     800b72 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b5f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800b62:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800b65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b68:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6d:	e9 da 00 00 00       	jmp    800c4c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b79:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b80:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b83:	89 da                	mov    %ebx,%edx
  800b85:	89 f1                	mov    %esi,%ecx
  800b87:	f7 da                	neg    %edx
  800b89:	83 d1 00             	adc    $0x0,%ecx
  800b8c:	f7 d9                	neg    %ecx
  800b8e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800b91:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800b94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9c:	e9 ab 00 00 00       	jmp    800c4c <vprintfmt+0x400>
  800ba1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ba4:	89 f2                	mov    %esi,%edx
  800ba6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba9:	e8 47 fc ff ff       	call   8007f5 <getuint>
  800bae:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800bb1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800bb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bb7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800bbc:	e9 8b 00 00 00       	jmp    800c4c <vprintfmt+0x400>
  800bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bcb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bd2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800bd5:	89 f2                	mov    %esi,%edx
  800bd7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bda:	e8 16 fc ff ff       	call   8007f5 <getuint>
  800bdf:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800be2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800be5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800be8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  800bed:	eb 5d                	jmp    800c4c <vprintfmt+0x400>
  800bef:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800bf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bf9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c00:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800c03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c07:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c0e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800c11:	8b 45 14             	mov    0x14(%ebp),%eax
  800c14:	8d 50 04             	lea    0x4(%eax),%edx
  800c17:	89 55 14             	mov    %edx,0x14(%ebp)
  800c1a:	8b 10                	mov    (%eax),%edx
  800c1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c21:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800c24:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800c27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c2a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c2f:	eb 1b                	jmp    800c4c <vprintfmt+0x400>
  800c31:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c34:	89 f2                	mov    %esi,%edx
  800c36:	8d 45 14             	lea    0x14(%ebp),%eax
  800c39:	e8 b7 fb ff ff       	call   8007f5 <getuint>
  800c3e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800c41:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800c44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c47:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c4c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800c50:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800c53:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800c56:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800c5a:	77 09                	ja     800c65 <vprintfmt+0x419>
  800c5c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800c5f:	0f 82 ac 00 00 00    	jb     800d11 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800c65:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800c68:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800c6c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800c6f:	83 ea 01             	sub    $0x1,%edx
  800c72:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c76:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7a:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c7e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800c82:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800c85:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800c88:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c8f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800c96:	00 
  800c97:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800c9a:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800c9d:	89 0c 24             	mov    %ecx,(%esp)
  800ca0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ca4:	e8 17 07 00 00       	call   8013c0 <__udivdi3>
  800ca9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800cac:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800caf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cb7:	89 04 24             	mov    %eax,(%esp)
  800cba:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc4:	e8 37 fa ff ff       	call   800700 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800cc9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ccc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800cd7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cdb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ce2:	00 
  800ce3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800ce6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800ce9:	89 14 24             	mov    %edx,(%esp)
  800cec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cf0:	e8 fb 07 00 00       	call   8014f0 <__umoddi3>
  800cf5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf9:	0f be 80 9f 16 80 00 	movsbl 0x80169f(%eax),%eax
  800d00:	89 04 24             	mov    %eax,(%esp)
  800d03:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800d06:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800d0a:	74 54                	je     800d60 <vprintfmt+0x514>
  800d0c:	e9 67 fb ff ff       	jmp    800878 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800d11:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800d15:	8d 76 00             	lea    0x0(%esi),%esi
  800d18:	0f 84 2a 01 00 00    	je     800e48 <vprintfmt+0x5fc>
		while (--width > 0)
  800d1e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d21:	83 ef 01             	sub    $0x1,%edi
  800d24:	85 ff                	test   %edi,%edi
  800d26:	0f 8e 5e 01 00 00    	jle    800e8a <vprintfmt+0x63e>
  800d2c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800d2f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800d32:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d35:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800d38:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800d3b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800d3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d42:	89 1c 24             	mov    %ebx,(%esp)
  800d45:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800d48:	83 ef 01             	sub    $0x1,%edi
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	7f ef                	jg     800d3e <vprintfmt+0x4f2>
  800d4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d52:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d55:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800d58:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800d5b:	e9 2a 01 00 00       	jmp    800e8a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800d60:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800d63:	83 eb 01             	sub    $0x1,%ebx
  800d66:	85 db                	test   %ebx,%ebx
  800d68:	0f 8e 0a fb ff ff    	jle    800878 <vprintfmt+0x2c>
  800d6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d71:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800d74:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800d77:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800d82:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800d84:	83 eb 01             	sub    $0x1,%ebx
  800d87:	85 db                	test   %ebx,%ebx
  800d89:	7f ec                	jg     800d77 <vprintfmt+0x52b>
  800d8b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d8e:	e9 e8 fa ff ff       	jmp    80087b <vprintfmt+0x2f>
  800d93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800d96:	8b 45 14             	mov    0x14(%ebp),%eax
  800d99:	8d 50 04             	lea    0x4(%eax),%edx
  800d9c:	89 55 14             	mov    %edx,0x14(%ebp)
  800d9f:	8b 00                	mov    (%eax),%eax
  800da1:	85 c0                	test   %eax,%eax
  800da3:	75 2a                	jne    800dcf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800da5:	c7 44 24 0c 58 17 80 	movl   $0x801758,0xc(%esp)
  800dac:	00 
  800dad:	c7 44 24 08 b9 16 80 	movl   $0x8016b9,0x8(%esp)
  800db4:	00 
  800db5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbf:	89 0c 24             	mov    %ecx,(%esp)
  800dc2:	e8 90 01 00 00       	call   800f57 <printfmt>
  800dc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800dca:	e9 ac fa ff ff       	jmp    80087b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800dcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd2:	8b 13                	mov    (%ebx),%edx
  800dd4:	83 fa 7f             	cmp    $0x7f,%edx
  800dd7:	7e 29                	jle    800e02 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800dd9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800ddb:	c7 44 24 0c 90 17 80 	movl   $0x801790,0xc(%esp)
  800de2:	00 
  800de3:	c7 44 24 08 b9 16 80 	movl   $0x8016b9,0x8(%esp)
  800dea:	00 
  800deb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
  800df2:	89 04 24             	mov    %eax,(%esp)
  800df5:	e8 5d 01 00 00       	call   800f57 <printfmt>
  800dfa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800dfd:	e9 79 fa ff ff       	jmp    80087b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800e02:	88 10                	mov    %dl,(%eax)
  800e04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e07:	e9 6f fa ff ff       	jmp    80087b <vprintfmt+0x2f>
  800e0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e15:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e19:	89 14 24             	mov    %edx,(%esp)
  800e1c:	ff 55 08             	call   *0x8(%ebp)
  800e1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800e22:	e9 54 fa ff ff       	jmp    80087b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e2e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e35:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e38:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e3b:	80 38 25             	cmpb   $0x25,(%eax)
  800e3e:	0f 84 37 fa ff ff    	je     80087b <vprintfmt+0x2f>
  800e44:	89 c7                	mov    %eax,%edi
  800e46:	eb f0                	jmp    800e38 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800e48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e53:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e56:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e5a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e61:	00 
  800e62:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800e65:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800e68:	89 04 24             	mov    %eax,(%esp)
  800e6b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e6f:	e8 7c 06 00 00       	call   8014f0 <__umoddi3>
  800e74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e78:	0f be 80 9f 16 80 00 	movsbl 0x80169f(%eax),%eax
  800e7f:	89 04 24             	mov    %eax,(%esp)
  800e82:	ff 55 08             	call   *0x8(%ebp)
  800e85:	e9 d6 fe ff ff       	jmp    800d60 <vprintfmt+0x514>
  800e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e91:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e95:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea3:	00 
  800ea4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800ea7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800eaa:	89 04 24             	mov    %eax,(%esp)
  800ead:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eb1:	e8 3a 06 00 00       	call   8014f0 <__umoddi3>
  800eb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eba:	0f be 80 9f 16 80 00 	movsbl 0x80169f(%eax),%eax
  800ec1:	89 04 24             	mov    %eax,(%esp)
  800ec4:	ff 55 08             	call   *0x8(%ebp)
  800ec7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800eca:	e9 ac f9 ff ff       	jmp    80087b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ecf:	83 c4 6c             	add    $0x6c,%esp
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 28             	sub    $0x28,%esp
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	74 04                	je     800eeb <vsnprintf+0x14>
  800ee7:	85 d2                	test   %edx,%edx
  800ee9:	7f 07                	jg     800ef2 <vsnprintf+0x1b>
  800eeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef0:	eb 3b                	jmp    800f2d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ef2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ef5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ef9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800efc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f03:	8b 45 14             	mov    0x14(%ebp),%eax
  800f06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f11:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f18:	c7 04 24 2f 08 80 00 	movl   $0x80082f,(%esp)
  800f1f:	e8 28 f9 ff ff       	call   80084c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800f35:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800f38:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4d:	89 04 24             	mov    %eax,(%esp)
  800f50:	e8 82 ff ff ff       	call   800ed7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800f5d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800f60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f64:	8b 45 10             	mov    0x10(%ebp),%eax
  800f67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
  800f75:	89 04 24             	mov    %eax,(%esp)
  800f78:	e8 cf f8 ff ff       	call   80084c <vprintfmt>
	va_end(ap);
}
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    
	...

00800f80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f86:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8b:	80 3a 00             	cmpb   $0x0,(%edx)
  800f8e:	74 09                	je     800f99 <strlen+0x19>
		n++;
  800f90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f97:	75 f7                	jne    800f90 <strlen+0x10>
		n++;
	return n;
}
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	53                   	push   %ebx
  800f9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa5:	85 c9                	test   %ecx,%ecx
  800fa7:	74 19                	je     800fc2 <strnlen+0x27>
  800fa9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800fac:	74 14                	je     800fc2 <strnlen+0x27>
  800fae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800fb3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fb6:	39 c8                	cmp    %ecx,%eax
  800fb8:	74 0d                	je     800fc7 <strnlen+0x2c>
  800fba:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800fbe:	75 f3                	jne    800fb3 <strnlen+0x18>
  800fc0:	eb 05                	jmp    800fc7 <strnlen+0x2c>
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800fc7:	5b                   	pop    %ebx
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	53                   	push   %ebx
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fd4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fd9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800fdd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fe0:	83 c2 01             	add    $0x1,%edx
  800fe3:	84 c9                	test   %cl,%cl
  800fe5:	75 f2                	jne    800fd9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fe7:	5b                   	pop    %ebx
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	53                   	push   %ebx
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ff4:	89 1c 24             	mov    %ebx,(%esp)
  800ff7:	e8 84 ff ff ff       	call   800f80 <strlen>
	strcpy(dst + len, src);
  800ffc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fff:	89 54 24 04          	mov    %edx,0x4(%esp)
  801003:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801006:	89 04 24             	mov    %eax,(%esp)
  801009:	e8 bc ff ff ff       	call   800fca <strcpy>
	return dst;
}
  80100e:	89 d8                	mov    %ebx,%eax
  801010:	83 c4 08             	add    $0x8,%esp
  801013:	5b                   	pop    %ebx
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
  80101e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801021:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801024:	85 f6                	test   %esi,%esi
  801026:	74 18                	je     801040 <strncpy+0x2a>
  801028:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80102d:	0f b6 1a             	movzbl (%edx),%ebx
  801030:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801033:	80 3a 01             	cmpb   $0x1,(%edx)
  801036:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801039:	83 c1 01             	add    $0x1,%ecx
  80103c:	39 ce                	cmp    %ecx,%esi
  80103e:	77 ed                	ja     80102d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	8b 75 08             	mov    0x8(%ebp),%esi
  80104c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801052:	89 f0                	mov    %esi,%eax
  801054:	85 c9                	test   %ecx,%ecx
  801056:	74 27                	je     80107f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801058:	83 e9 01             	sub    $0x1,%ecx
  80105b:	74 1d                	je     80107a <strlcpy+0x36>
  80105d:	0f b6 1a             	movzbl (%edx),%ebx
  801060:	84 db                	test   %bl,%bl
  801062:	74 16                	je     80107a <strlcpy+0x36>
			*dst++ = *src++;
  801064:	88 18                	mov    %bl,(%eax)
  801066:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801069:	83 e9 01             	sub    $0x1,%ecx
  80106c:	74 0e                	je     80107c <strlcpy+0x38>
			*dst++ = *src++;
  80106e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801071:	0f b6 1a             	movzbl (%edx),%ebx
  801074:	84 db                	test   %bl,%bl
  801076:	75 ec                	jne    801064 <strlcpy+0x20>
  801078:	eb 02                	jmp    80107c <strlcpy+0x38>
  80107a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80107c:	c6 00 00             	movb   $0x0,(%eax)
  80107f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80108e:	0f b6 01             	movzbl (%ecx),%eax
  801091:	84 c0                	test   %al,%al
  801093:	74 15                	je     8010aa <strcmp+0x25>
  801095:	3a 02                	cmp    (%edx),%al
  801097:	75 11                	jne    8010aa <strcmp+0x25>
		p++, q++;
  801099:	83 c1 01             	add    $0x1,%ecx
  80109c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80109f:	0f b6 01             	movzbl (%ecx),%eax
  8010a2:	84 c0                	test   %al,%al
  8010a4:	74 04                	je     8010aa <strcmp+0x25>
  8010a6:	3a 02                	cmp    (%edx),%al
  8010a8:	74 ef                	je     801099 <strcmp+0x14>
  8010aa:	0f b6 c0             	movzbl %al,%eax
  8010ad:	0f b6 12             	movzbl (%edx),%edx
  8010b0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	53                   	push   %ebx
  8010b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010be:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	74 23                	je     8010e8 <strncmp+0x34>
  8010c5:	0f b6 1a             	movzbl (%edx),%ebx
  8010c8:	84 db                	test   %bl,%bl
  8010ca:	74 25                	je     8010f1 <strncmp+0x3d>
  8010cc:	3a 19                	cmp    (%ecx),%bl
  8010ce:	75 21                	jne    8010f1 <strncmp+0x3d>
  8010d0:	83 e8 01             	sub    $0x1,%eax
  8010d3:	74 13                	je     8010e8 <strncmp+0x34>
		n--, p++, q++;
  8010d5:	83 c2 01             	add    $0x1,%edx
  8010d8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010db:	0f b6 1a             	movzbl (%edx),%ebx
  8010de:	84 db                	test   %bl,%bl
  8010e0:	74 0f                	je     8010f1 <strncmp+0x3d>
  8010e2:	3a 19                	cmp    (%ecx),%bl
  8010e4:	74 ea                	je     8010d0 <strncmp+0x1c>
  8010e6:	eb 09                	jmp    8010f1 <strncmp+0x3d>
  8010e8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010ed:	5b                   	pop    %ebx
  8010ee:	5d                   	pop    %ebp
  8010ef:	90                   	nop
  8010f0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8010f1:	0f b6 02             	movzbl (%edx),%eax
  8010f4:	0f b6 11             	movzbl (%ecx),%edx
  8010f7:	29 d0                	sub    %edx,%eax
  8010f9:	eb f2                	jmp    8010ed <strncmp+0x39>

008010fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801105:	0f b6 10             	movzbl (%eax),%edx
  801108:	84 d2                	test   %dl,%dl
  80110a:	74 18                	je     801124 <strchr+0x29>
		if (*s == c)
  80110c:	38 ca                	cmp    %cl,%dl
  80110e:	75 0a                	jne    80111a <strchr+0x1f>
  801110:	eb 17                	jmp    801129 <strchr+0x2e>
  801112:	38 ca                	cmp    %cl,%dl
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	74 0f                	je     801129 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80111a:	83 c0 01             	add    $0x1,%eax
  80111d:	0f b6 10             	movzbl (%eax),%edx
  801120:	84 d2                	test   %dl,%dl
  801122:	75 ee                	jne    801112 <strchr+0x17>
  801124:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801135:	0f b6 10             	movzbl (%eax),%edx
  801138:	84 d2                	test   %dl,%dl
  80113a:	74 18                	je     801154 <strfind+0x29>
		if (*s == c)
  80113c:	38 ca                	cmp    %cl,%dl
  80113e:	75 0a                	jne    80114a <strfind+0x1f>
  801140:	eb 12                	jmp    801154 <strfind+0x29>
  801142:	38 ca                	cmp    %cl,%dl
  801144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801148:	74 0a                	je     801154 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80114a:	83 c0 01             	add    $0x1,%eax
  80114d:	0f b6 10             	movzbl (%eax),%edx
  801150:	84 d2                	test   %dl,%dl
  801152:	75 ee                	jne    801142 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	89 1c 24             	mov    %ebx,(%esp)
  80115f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801163:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801167:	8b 7d 08             	mov    0x8(%ebp),%edi
  80116a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801170:	85 c9                	test   %ecx,%ecx
  801172:	74 30                	je     8011a4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801174:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80117a:	75 25                	jne    8011a1 <memset+0x4b>
  80117c:	f6 c1 03             	test   $0x3,%cl
  80117f:	75 20                	jne    8011a1 <memset+0x4b>
		c &= 0xFF;
  801181:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801184:	89 d3                	mov    %edx,%ebx
  801186:	c1 e3 08             	shl    $0x8,%ebx
  801189:	89 d6                	mov    %edx,%esi
  80118b:	c1 e6 18             	shl    $0x18,%esi
  80118e:	89 d0                	mov    %edx,%eax
  801190:	c1 e0 10             	shl    $0x10,%eax
  801193:	09 f0                	or     %esi,%eax
  801195:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801197:	09 d8                	or     %ebx,%eax
  801199:	c1 e9 02             	shr    $0x2,%ecx
  80119c:	fc                   	cld    
  80119d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80119f:	eb 03                	jmp    8011a4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011a1:	fc                   	cld    
  8011a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011a4:	89 f8                	mov    %edi,%eax
  8011a6:	8b 1c 24             	mov    (%esp),%ebx
  8011a9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011ad:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011b1:	89 ec                	mov    %ebp,%esp
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	89 34 24             	mov    %esi,(%esp)
  8011be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8011c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8011cb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8011cd:	39 c6                	cmp    %eax,%esi
  8011cf:	73 35                	jae    801206 <memmove+0x51>
  8011d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8011d4:	39 d0                	cmp    %edx,%eax
  8011d6:	73 2e                	jae    801206 <memmove+0x51>
		s += n;
		d += n;
  8011d8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011da:	f6 c2 03             	test   $0x3,%dl
  8011dd:	75 1b                	jne    8011fa <memmove+0x45>
  8011df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011e5:	75 13                	jne    8011fa <memmove+0x45>
  8011e7:	f6 c1 03             	test   $0x3,%cl
  8011ea:	75 0e                	jne    8011fa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8011ec:	83 ef 04             	sub    $0x4,%edi
  8011ef:	8d 72 fc             	lea    -0x4(%edx),%esi
  8011f2:	c1 e9 02             	shr    $0x2,%ecx
  8011f5:	fd                   	std    
  8011f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011f8:	eb 09                	jmp    801203 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8011fa:	83 ef 01             	sub    $0x1,%edi
  8011fd:	8d 72 ff             	lea    -0x1(%edx),%esi
  801200:	fd                   	std    
  801201:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801203:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801204:	eb 20                	jmp    801226 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801206:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80120c:	75 15                	jne    801223 <memmove+0x6e>
  80120e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801214:	75 0d                	jne    801223 <memmove+0x6e>
  801216:	f6 c1 03             	test   $0x3,%cl
  801219:	75 08                	jne    801223 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80121b:	c1 e9 02             	shr    $0x2,%ecx
  80121e:	fc                   	cld    
  80121f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801221:	eb 03                	jmp    801226 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801223:	fc                   	cld    
  801224:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801226:	8b 34 24             	mov    (%esp),%esi
  801229:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80122d:	89 ec                	mov    %ebp,%esp
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801237:	8b 45 10             	mov    0x10(%ebp),%eax
  80123a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801241:	89 44 24 04          	mov    %eax,0x4(%esp)
  801245:	8b 45 08             	mov    0x8(%ebp),%eax
  801248:	89 04 24             	mov    %eax,(%esp)
  80124b:	e8 65 ff ff ff       	call   8011b5 <memmove>
}
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	8b 75 08             	mov    0x8(%ebp),%esi
  80125b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80125e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801261:	85 c9                	test   %ecx,%ecx
  801263:	74 36                	je     80129b <memcmp+0x49>
		if (*s1 != *s2)
  801265:	0f b6 06             	movzbl (%esi),%eax
  801268:	0f b6 1f             	movzbl (%edi),%ebx
  80126b:	38 d8                	cmp    %bl,%al
  80126d:	74 20                	je     80128f <memcmp+0x3d>
  80126f:	eb 14                	jmp    801285 <memcmp+0x33>
  801271:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801276:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80127b:	83 c2 01             	add    $0x1,%edx
  80127e:	83 e9 01             	sub    $0x1,%ecx
  801281:	38 d8                	cmp    %bl,%al
  801283:	74 12                	je     801297 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801285:	0f b6 c0             	movzbl %al,%eax
  801288:	0f b6 db             	movzbl %bl,%ebx
  80128b:	29 d8                	sub    %ebx,%eax
  80128d:	eb 11                	jmp    8012a0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80128f:	83 e9 01             	sub    $0x1,%ecx
  801292:	ba 00 00 00 00       	mov    $0x0,%edx
  801297:	85 c9                	test   %ecx,%ecx
  801299:	75 d6                	jne    801271 <memcmp+0x1f>
  80129b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012b0:	39 d0                	cmp    %edx,%eax
  8012b2:	73 15                	jae    8012c9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8012b8:	38 08                	cmp    %cl,(%eax)
  8012ba:	75 06                	jne    8012c2 <memfind+0x1d>
  8012bc:	eb 0b                	jmp    8012c9 <memfind+0x24>
  8012be:	38 08                	cmp    %cl,(%eax)
  8012c0:	74 07                	je     8012c9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8012c2:	83 c0 01             	add    $0x1,%eax
  8012c5:	39 c2                	cmp    %eax,%edx
  8012c7:	77 f5                	ja     8012be <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	57                   	push   %edi
  8012cf:	56                   	push   %esi
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012da:	0f b6 02             	movzbl (%edx),%eax
  8012dd:	3c 20                	cmp    $0x20,%al
  8012df:	74 04                	je     8012e5 <strtol+0x1a>
  8012e1:	3c 09                	cmp    $0x9,%al
  8012e3:	75 0e                	jne    8012f3 <strtol+0x28>
		s++;
  8012e5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012e8:	0f b6 02             	movzbl (%edx),%eax
  8012eb:	3c 20                	cmp    $0x20,%al
  8012ed:	74 f6                	je     8012e5 <strtol+0x1a>
  8012ef:	3c 09                	cmp    $0x9,%al
  8012f1:	74 f2                	je     8012e5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8012f3:	3c 2b                	cmp    $0x2b,%al
  8012f5:	75 0c                	jne    801303 <strtol+0x38>
		s++;
  8012f7:	83 c2 01             	add    $0x1,%edx
  8012fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801301:	eb 15                	jmp    801318 <strtol+0x4d>
	else if (*s == '-')
  801303:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80130a:	3c 2d                	cmp    $0x2d,%al
  80130c:	75 0a                	jne    801318 <strtol+0x4d>
		s++, neg = 1;
  80130e:	83 c2 01             	add    $0x1,%edx
  801311:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801318:	85 db                	test   %ebx,%ebx
  80131a:	0f 94 c0             	sete   %al
  80131d:	74 05                	je     801324 <strtol+0x59>
  80131f:	83 fb 10             	cmp    $0x10,%ebx
  801322:	75 18                	jne    80133c <strtol+0x71>
  801324:	80 3a 30             	cmpb   $0x30,(%edx)
  801327:	75 13                	jne    80133c <strtol+0x71>
  801329:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80132d:	8d 76 00             	lea    0x0(%esi),%esi
  801330:	75 0a                	jne    80133c <strtol+0x71>
		s += 2, base = 16;
  801332:	83 c2 02             	add    $0x2,%edx
  801335:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80133a:	eb 15                	jmp    801351 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80133c:	84 c0                	test   %al,%al
  80133e:	66 90                	xchg   %ax,%ax
  801340:	74 0f                	je     801351 <strtol+0x86>
  801342:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801347:	80 3a 30             	cmpb   $0x30,(%edx)
  80134a:	75 05                	jne    801351 <strtol+0x86>
		s++, base = 8;
  80134c:	83 c2 01             	add    $0x1,%edx
  80134f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801351:	b8 00 00 00 00       	mov    $0x0,%eax
  801356:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801358:	0f b6 0a             	movzbl (%edx),%ecx
  80135b:	89 cf                	mov    %ecx,%edi
  80135d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801360:	80 fb 09             	cmp    $0x9,%bl
  801363:	77 08                	ja     80136d <strtol+0xa2>
			dig = *s - '0';
  801365:	0f be c9             	movsbl %cl,%ecx
  801368:	83 e9 30             	sub    $0x30,%ecx
  80136b:	eb 1e                	jmp    80138b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80136d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801370:	80 fb 19             	cmp    $0x19,%bl
  801373:	77 08                	ja     80137d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801375:	0f be c9             	movsbl %cl,%ecx
  801378:	83 e9 57             	sub    $0x57,%ecx
  80137b:	eb 0e                	jmp    80138b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80137d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801380:	80 fb 19             	cmp    $0x19,%bl
  801383:	77 15                	ja     80139a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801385:	0f be c9             	movsbl %cl,%ecx
  801388:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80138b:	39 f1                	cmp    %esi,%ecx
  80138d:	7d 0b                	jge    80139a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80138f:	83 c2 01             	add    $0x1,%edx
  801392:	0f af c6             	imul   %esi,%eax
  801395:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801398:	eb be                	jmp    801358 <strtol+0x8d>
  80139a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80139c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013a0:	74 05                	je     8013a7 <strtol+0xdc>
		*endptr = (char *) s;
  8013a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013a5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8013a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013ab:	74 04                	je     8013b1 <strtol+0xe6>
  8013ad:	89 c8                	mov    %ecx,%eax
  8013af:	f7 d8                	neg    %eax
}
  8013b1:	83 c4 04             	add    $0x4,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5f                   	pop    %edi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    
  8013b9:	00 00                	add    %al,(%eax)
  8013bb:	00 00                	add    %al,(%eax)
  8013bd:	00 00                	add    %al,(%eax)
	...

008013c0 <__udivdi3>:
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	57                   	push   %edi
  8013c4:	56                   	push   %esi
  8013c5:	83 ec 10             	sub    $0x10,%esp
  8013c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8013d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8013d9:	75 35                	jne    801410 <__udivdi3+0x50>
  8013db:	39 fe                	cmp    %edi,%esi
  8013dd:	77 61                	ja     801440 <__udivdi3+0x80>
  8013df:	85 f6                	test   %esi,%esi
  8013e1:	75 0b                	jne    8013ee <__udivdi3+0x2e>
  8013e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e8:	31 d2                	xor    %edx,%edx
  8013ea:	f7 f6                	div    %esi
  8013ec:	89 c6                	mov    %eax,%esi
  8013ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8013f1:	31 d2                	xor    %edx,%edx
  8013f3:	89 f8                	mov    %edi,%eax
  8013f5:	f7 f6                	div    %esi
  8013f7:	89 c7                	mov    %eax,%edi
  8013f9:	89 c8                	mov    %ecx,%eax
  8013fb:	f7 f6                	div    %esi
  8013fd:	89 c1                	mov    %eax,%ecx
  8013ff:	89 fa                	mov    %edi,%edx
  801401:	89 c8                	mov    %ecx,%eax
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	5e                   	pop    %esi
  801407:	5f                   	pop    %edi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    
  80140a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801410:	39 f8                	cmp    %edi,%eax
  801412:	77 1c                	ja     801430 <__udivdi3+0x70>
  801414:	0f bd d0             	bsr    %eax,%edx
  801417:	83 f2 1f             	xor    $0x1f,%edx
  80141a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80141d:	75 39                	jne    801458 <__udivdi3+0x98>
  80141f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801422:	0f 86 a0 00 00 00    	jbe    8014c8 <__udivdi3+0x108>
  801428:	39 f8                	cmp    %edi,%eax
  80142a:	0f 82 98 00 00 00    	jb     8014c8 <__udivdi3+0x108>
  801430:	31 ff                	xor    %edi,%edi
  801432:	31 c9                	xor    %ecx,%ecx
  801434:	89 c8                	mov    %ecx,%eax
  801436:	89 fa                	mov    %edi,%edx
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    
  80143f:	90                   	nop
  801440:	89 d1                	mov    %edx,%ecx
  801442:	89 fa                	mov    %edi,%edx
  801444:	89 c8                	mov    %ecx,%eax
  801446:	31 ff                	xor    %edi,%edi
  801448:	f7 f6                	div    %esi
  80144a:	89 c1                	mov    %eax,%ecx
  80144c:	89 fa                	mov    %edi,%edx
  80144e:	89 c8                	mov    %ecx,%eax
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	5e                   	pop    %esi
  801454:	5f                   	pop    %edi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    
  801457:	90                   	nop
  801458:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80145c:	89 f2                	mov    %esi,%edx
  80145e:	d3 e0                	shl    %cl,%eax
  801460:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801463:	b8 20 00 00 00       	mov    $0x20,%eax
  801468:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80146b:	89 c1                	mov    %eax,%ecx
  80146d:	d3 ea                	shr    %cl,%edx
  80146f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801473:	0b 55 ec             	or     -0x14(%ebp),%edx
  801476:	d3 e6                	shl    %cl,%esi
  801478:	89 c1                	mov    %eax,%ecx
  80147a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80147d:	89 fe                	mov    %edi,%esi
  80147f:	d3 ee                	shr    %cl,%esi
  801481:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801485:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801488:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148b:	d3 e7                	shl    %cl,%edi
  80148d:	89 c1                	mov    %eax,%ecx
  80148f:	d3 ea                	shr    %cl,%edx
  801491:	09 d7                	or     %edx,%edi
  801493:	89 f2                	mov    %esi,%edx
  801495:	89 f8                	mov    %edi,%eax
  801497:	f7 75 ec             	divl   -0x14(%ebp)
  80149a:	89 d6                	mov    %edx,%esi
  80149c:	89 c7                	mov    %eax,%edi
  80149e:	f7 65 e8             	mull   -0x18(%ebp)
  8014a1:	39 d6                	cmp    %edx,%esi
  8014a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014a6:	72 30                	jb     8014d8 <__udivdi3+0x118>
  8014a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014af:	d3 e2                	shl    %cl,%edx
  8014b1:	39 c2                	cmp    %eax,%edx
  8014b3:	73 05                	jae    8014ba <__udivdi3+0xfa>
  8014b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8014b8:	74 1e                	je     8014d8 <__udivdi3+0x118>
  8014ba:	89 f9                	mov    %edi,%ecx
  8014bc:	31 ff                	xor    %edi,%edi
  8014be:	e9 71 ff ff ff       	jmp    801434 <__udivdi3+0x74>
  8014c3:	90                   	nop
  8014c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014c8:	31 ff                	xor    %edi,%edi
  8014ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8014cf:	e9 60 ff ff ff       	jmp    801434 <__udivdi3+0x74>
  8014d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8014db:	31 ff                	xor    %edi,%edi
  8014dd:	89 c8                	mov    %ecx,%eax
  8014df:	89 fa                	mov    %edi,%edx
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    
	...

008014f0 <__umoddi3>:
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	57                   	push   %edi
  8014f4:	56                   	push   %esi
  8014f5:	83 ec 20             	sub    $0x20,%esp
  8014f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8014fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801501:	8b 75 0c             	mov    0xc(%ebp),%esi
  801504:	85 d2                	test   %edx,%edx
  801506:	89 c8                	mov    %ecx,%eax
  801508:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80150b:	75 13                	jne    801520 <__umoddi3+0x30>
  80150d:	39 f7                	cmp    %esi,%edi
  80150f:	76 3f                	jbe    801550 <__umoddi3+0x60>
  801511:	89 f2                	mov    %esi,%edx
  801513:	f7 f7                	div    %edi
  801515:	89 d0                	mov    %edx,%eax
  801517:	31 d2                	xor    %edx,%edx
  801519:	83 c4 20             	add    $0x20,%esp
  80151c:	5e                   	pop    %esi
  80151d:	5f                   	pop    %edi
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    
  801520:	39 f2                	cmp    %esi,%edx
  801522:	77 4c                	ja     801570 <__umoddi3+0x80>
  801524:	0f bd ca             	bsr    %edx,%ecx
  801527:	83 f1 1f             	xor    $0x1f,%ecx
  80152a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80152d:	75 51                	jne    801580 <__umoddi3+0x90>
  80152f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801532:	0f 87 e0 00 00 00    	ja     801618 <__umoddi3+0x128>
  801538:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153b:	29 f8                	sub    %edi,%eax
  80153d:	19 d6                	sbb    %edx,%esi
  80153f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801545:	89 f2                	mov    %esi,%edx
  801547:	83 c4 20             	add    $0x20,%esp
  80154a:	5e                   	pop    %esi
  80154b:	5f                   	pop    %edi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    
  80154e:	66 90                	xchg   %ax,%ax
  801550:	85 ff                	test   %edi,%edi
  801552:	75 0b                	jne    80155f <__umoddi3+0x6f>
  801554:	b8 01 00 00 00       	mov    $0x1,%eax
  801559:	31 d2                	xor    %edx,%edx
  80155b:	f7 f7                	div    %edi
  80155d:	89 c7                	mov    %eax,%edi
  80155f:	89 f0                	mov    %esi,%eax
  801561:	31 d2                	xor    %edx,%edx
  801563:	f7 f7                	div    %edi
  801565:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801568:	f7 f7                	div    %edi
  80156a:	eb a9                	jmp    801515 <__umoddi3+0x25>
  80156c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801570:	89 c8                	mov    %ecx,%eax
  801572:	89 f2                	mov    %esi,%edx
  801574:	83 c4 20             	add    $0x20,%esp
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    
  80157b:	90                   	nop
  80157c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801580:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801584:	d3 e2                	shl    %cl,%edx
  801586:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801589:	ba 20 00 00 00       	mov    $0x20,%edx
  80158e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801591:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801594:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801598:	89 fa                	mov    %edi,%edx
  80159a:	d3 ea                	shr    %cl,%edx
  80159c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8015a3:	d3 e7                	shl    %cl,%edi
  8015a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015ac:	89 f2                	mov    %esi,%edx
  8015ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8015b1:	89 c7                	mov    %eax,%edi
  8015b3:	d3 ea                	shr    %cl,%edx
  8015b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015bc:	89 c2                	mov    %eax,%edx
  8015be:	d3 e6                	shl    %cl,%esi
  8015c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015c4:	d3 ea                	shr    %cl,%edx
  8015c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015ca:	09 d6                	or     %edx,%esi
  8015cc:	89 f0                	mov    %esi,%eax
  8015ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015d1:	d3 e7                	shl    %cl,%edi
  8015d3:	89 f2                	mov    %esi,%edx
  8015d5:	f7 75 f4             	divl   -0xc(%ebp)
  8015d8:	89 d6                	mov    %edx,%esi
  8015da:	f7 65 e8             	mull   -0x18(%ebp)
  8015dd:	39 d6                	cmp    %edx,%esi
  8015df:	72 2b                	jb     80160c <__umoddi3+0x11c>
  8015e1:	39 c7                	cmp    %eax,%edi
  8015e3:	72 23                	jb     801608 <__umoddi3+0x118>
  8015e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015e9:	29 c7                	sub    %eax,%edi
  8015eb:	19 d6                	sbb    %edx,%esi
  8015ed:	89 f0                	mov    %esi,%eax
  8015ef:	89 f2                	mov    %esi,%edx
  8015f1:	d3 ef                	shr    %cl,%edi
  8015f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015f7:	d3 e0                	shl    %cl,%eax
  8015f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015fd:	09 f8                	or     %edi,%eax
  8015ff:	d3 ea                	shr    %cl,%edx
  801601:	83 c4 20             	add    $0x20,%esp
  801604:	5e                   	pop    %esi
  801605:	5f                   	pop    %edi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    
  801608:	39 d6                	cmp    %edx,%esi
  80160a:	75 d9                	jne    8015e5 <__umoddi3+0xf5>
  80160c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80160f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801612:	eb d1                	jmp    8015e5 <__umoddi3+0xf5>
  801614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801618:	39 f2                	cmp    %esi,%edx
  80161a:	0f 82 18 ff ff ff    	jb     801538 <__umoddi3+0x48>
  801620:	e9 1d ff ff ff       	jmp    801542 <__umoddi3+0x52>
