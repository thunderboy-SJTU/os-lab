
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 40 	movl   $0x801640,0x802000
  800041:	16 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 62 04 00 00       	call   8004ab <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800055:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005e:	e8 ca 04 00 00       	call   80052d <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	89 c2                	mov    %eax,%edx
  80006a:	c1 e2 07             	shl    $0x7,%edx
  80006d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800074:	a3 04 20 80 00       	mov    %eax,0x802004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x38>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 bb 04 00 00       	call   80056d <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

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

00800133 <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 28             	sub    $0x28,%esp
  800139:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80013c:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80013f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800144:	b8 0e 00 00 00       	mov    $0xe,%eax
  800149:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80014c:	8b 55 08             	mov    0x8(%ebp),%edx
  80014f:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800169:	85 c0                	test   %eax,%eax
  80016b:	7e 28                	jle    800195 <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800171:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  800178:	00 
  800179:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  800180:	00 
  800181:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800188:	00 
  800189:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  800190:	e8 43 04 00 00       	call   8005d8 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	89 1c 24             	mov    %ebx,(%esp)
  8001a8:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	89 cb                	mov    %ecx,%ebx
  8001bb:	89 cf                	mov    %ecx,%edi
  8001bd:	51                   	push   %ecx
  8001be:	52                   	push   %edx
  8001bf:	53                   	push   %ebx
  8001c0:	54                   	push   %esp
  8001c1:	55                   	push   %ebp
  8001c2:	56                   	push   %esi
  8001c3:	57                   	push   %edi
  8001c4:	54                   	push   %esp
  8001c5:	5d                   	pop    %ebp
  8001c6:	8d 35 ce 01 80 00    	lea    0x8001ce,%esi
  8001cc:	0f 34                	sysenter 
  8001ce:	5f                   	pop    %edi
  8001cf:	5e                   	pop    %esi
  8001d0:	5d                   	pop    %ebp
  8001d1:	5c                   	pop    %esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5a                   	pop    %edx
  8001d4:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001d5:	8b 1c 24             	mov    (%esp),%ebx
  8001d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001dc:	89 ec                	mov    %ebp,%esp
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 28             	sub    $0x28,%esp
  8001e6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001e9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001f1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	89 cb                	mov    %ecx,%ebx
  8001fb:	89 cf                	mov    %ecx,%edi
  8001fd:	51                   	push   %ecx
  8001fe:	52                   	push   %edx
  8001ff:	53                   	push   %ebx
  800200:	54                   	push   %esp
  800201:	55                   	push   %ebp
  800202:	56                   	push   %esi
  800203:	57                   	push   %edi
  800204:	54                   	push   %esp
  800205:	5d                   	pop    %ebp
  800206:	8d 35 0e 02 80 00    	lea    0x80020e,%esi
  80020c:	0f 34                	sysenter 
  80020e:	5f                   	pop    %edi
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	5c                   	pop    %esp
  800212:	5b                   	pop    %ebx
  800213:	5a                   	pop    %edx
  800214:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800215:	85 c0                	test   %eax,%eax
  800217:	7e 28                	jle    800241 <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800219:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800224:	00 
  800225:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  80023c:	e8 97 03 00 00       	call   8005d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800241:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800244:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800247:	89 ec                	mov    %ebp,%esp
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	89 1c 24             	mov    %ebx,(%esp)
  800254:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800258:	b8 0c 00 00 00       	mov    $0xc,%eax
  80025d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800260:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800266:	8b 55 08             	mov    0x8(%ebp),%edx
  800269:	51                   	push   %ecx
  80026a:	52                   	push   %edx
  80026b:	53                   	push   %ebx
  80026c:	54                   	push   %esp
  80026d:	55                   	push   %ebp
  80026e:	56                   	push   %esi
  80026f:	57                   	push   %edi
  800270:	54                   	push   %esp
  800271:	5d                   	pop    %ebp
  800272:	8d 35 7a 02 80 00    	lea    0x80027a,%esi
  800278:	0f 34                	sysenter 
  80027a:	5f                   	pop    %edi
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	5c                   	pop    %esp
  80027e:	5b                   	pop    %ebx
  80027f:	5a                   	pop    %edx
  800280:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800281:	8b 1c 24             	mov    (%esp),%ebx
  800284:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800288:	89 ec                	mov    %ebp,%esp
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 28             	sub    $0x28,%esp
  800292:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800295:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	51                   	push   %ecx
  8002ab:	52                   	push   %edx
  8002ac:	53                   	push   %ebx
  8002ad:	54                   	push   %esp
  8002ae:	55                   	push   %ebp
  8002af:	56                   	push   %esi
  8002b0:	57                   	push   %edi
  8002b1:	54                   	push   %esp
  8002b2:	5d                   	pop    %ebp
  8002b3:	8d 35 bb 02 80 00    	lea    0x8002bb,%esi
  8002b9:	0f 34                	sysenter 
  8002bb:	5f                   	pop    %edi
  8002bc:	5e                   	pop    %esi
  8002bd:	5d                   	pop    %ebp
  8002be:	5c                   	pop    %esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5a                   	pop    %edx
  8002c1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	7e 28                	jle    8002ee <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8002d1:	00 
  8002d2:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  8002d9:	00 
  8002da:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8002e1:	00 
  8002e2:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  8002e9:	e8 ea 02 00 00       	call   8005d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ee:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f4:	89 ec                	mov    %ebp,%esp
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 28             	sub    $0x28,%esp
  8002fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800301:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800304:	bb 00 00 00 00       	mov    $0x0,%ebx
  800309:	b8 09 00 00 00       	mov    $0x9,%eax
  80030e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800311:	8b 55 08             	mov    0x8(%ebp),%edx
  800314:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80032e:	85 c0                	test   %eax,%eax
  800330:	7e 28                	jle    80035a <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800332:	89 44 24 10          	mov    %eax,0x10(%esp)
  800336:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80033d:	00 
  80033e:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  800345:	00 
  800346:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80034d:	00 
  80034e:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  800355:	e8 7e 02 00 00       	call   8005d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80035a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80035d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800360:	89 ec                	mov    %ebp,%esp
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	83 ec 28             	sub    $0x28,%esp
  80036a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80036d:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800370:	bb 00 00 00 00       	mov    $0x0,%ebx
  800375:	b8 07 00 00 00       	mov    $0x7,%eax
  80037a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037d:	8b 55 08             	mov    0x8(%ebp),%edx
  800380:	89 df                	mov    %ebx,%edi
  800382:	51                   	push   %ecx
  800383:	52                   	push   %edx
  800384:	53                   	push   %ebx
  800385:	54                   	push   %esp
  800386:	55                   	push   %ebp
  800387:	56                   	push   %esi
  800388:	57                   	push   %edi
  800389:	54                   	push   %esp
  80038a:	5d                   	pop    %ebp
  80038b:	8d 35 93 03 80 00    	lea    0x800393,%esi
  800391:	0f 34                	sysenter 
  800393:	5f                   	pop    %edi
  800394:	5e                   	pop    %esi
  800395:	5d                   	pop    %ebp
  800396:	5c                   	pop    %esp
  800397:	5b                   	pop    %ebx
  800398:	5a                   	pop    %edx
  800399:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80039a:	85 c0                	test   %eax,%eax
  80039c:	7e 28                	jle    8003c6 <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  8003b1:	00 
  8003b2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8003b9:	00 
  8003ba:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  8003c1:	e8 12 02 00 00       	call   8005d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8003c6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8003c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003cc:	89 ec                	mov    %ebp,%esp
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	83 ec 28             	sub    $0x28,%esp
  8003d6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003d9:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003dc:	8b 7d 18             	mov    0x18(%ebp),%edi
  8003df:	0b 7d 14             	or     0x14(%ebp),%edi
  8003e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8003e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ed:	8b 55 08             	mov    0x8(%ebp),%edx
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
  80040a:	7e 28                	jle    800434 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800410:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800417:	00 
  800418:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  80041f:	00 
  800420:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  80042f:	e8 a4 01 00 00       	call   8005d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  800434:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800437:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80043a:	89 ec                	mov    %ebp,%esp
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  80044a:	bf 00 00 00 00       	mov    $0x0,%edi
  80044f:	b8 05 00 00 00       	mov    $0x5,%eax
  800454:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800457:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045a:	8b 55 08             	mov    0x8(%ebp),%edx
  80045d:	51                   	push   %ecx
  80045e:	52                   	push   %edx
  80045f:	53                   	push   %ebx
  800460:	54                   	push   %esp
  800461:	55                   	push   %ebp
  800462:	56                   	push   %esi
  800463:	57                   	push   %edi
  800464:	54                   	push   %esp
  800465:	5d                   	pop    %ebp
  800466:	8d 35 6e 04 80 00    	lea    0x80046e,%esi
  80046c:	0f 34                	sysenter 
  80046e:	5f                   	pop    %edi
  80046f:	5e                   	pop    %esi
  800470:	5d                   	pop    %ebp
  800471:	5c                   	pop    %esp
  800472:	5b                   	pop    %ebx
  800473:	5a                   	pop    %edx
  800474:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800475:	85 c0                	test   %eax,%eax
  800477:	7e 28                	jle    8004a1 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800479:	89 44 24 10          	mov    %eax,0x10(%esp)
  80047d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800484:	00 
  800485:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  80048c:	00 
  80048d:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800494:	00 
  800495:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  80049c:	e8 37 01 00 00       	call   8005d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8004a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004a4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004a7:	89 ec                	mov    %ebp,%esp
  8004a9:	5d                   	pop    %ebp
  8004aa:	c3                   	ret    

008004ab <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	89 1c 24             	mov    %ebx,(%esp)
  8004b4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8004c2:	89 d1                	mov    %edx,%ecx
  8004c4:	89 d3                	mov    %edx,%ebx
  8004c6:	89 d7                	mov    %edx,%edi
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

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8004e0:	8b 1c 24             	mov    (%esp),%ebx
  8004e3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004e7:	89 ec                	mov    %ebp,%esp
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	89 1c 24             	mov    %ebx,(%esp)
  8004f4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004fd:	b8 04 00 00 00       	mov    $0x4,%eax
  800502:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800505:	8b 55 08             	mov    0x8(%ebp),%edx
  800508:	89 df                	mov    %ebx,%edi
  80050a:	51                   	push   %ecx
  80050b:	52                   	push   %edx
  80050c:	53                   	push   %ebx
  80050d:	54                   	push   %esp
  80050e:	55                   	push   %ebp
  80050f:	56                   	push   %esi
  800510:	57                   	push   %edi
  800511:	54                   	push   %esp
  800512:	5d                   	pop    %ebp
  800513:	8d 35 1b 05 80 00    	lea    0x80051b,%esi
  800519:	0f 34                	sysenter 
  80051b:	5f                   	pop    %edi
  80051c:	5e                   	pop    %esi
  80051d:	5d                   	pop    %ebp
  80051e:	5c                   	pop    %esp
  80051f:	5b                   	pop    %ebx
  800520:	5a                   	pop    %edx
  800521:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800522:	8b 1c 24             	mov    (%esp),%ebx
  800525:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800529:	89 ec                	mov    %ebp,%esp
  80052b:	5d                   	pop    %ebp
  80052c:	c3                   	ret    

0080052d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	89 1c 24             	mov    %ebx,(%esp)
  800536:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80053a:	ba 00 00 00 00       	mov    $0x0,%edx
  80053f:	b8 02 00 00 00       	mov    $0x2,%eax
  800544:	89 d1                	mov    %edx,%ecx
  800546:	89 d3                	mov    %edx,%ebx
  800548:	89 d7                	mov    %edx,%edi
  80054a:	51                   	push   %ecx
  80054b:	52                   	push   %edx
  80054c:	53                   	push   %ebx
  80054d:	54                   	push   %esp
  80054e:	55                   	push   %ebp
  80054f:	56                   	push   %esi
  800550:	57                   	push   %edi
  800551:	54                   	push   %esp
  800552:	5d                   	pop    %ebp
  800553:	8d 35 5b 05 80 00    	lea    0x80055b,%esi
  800559:	0f 34                	sysenter 
  80055b:	5f                   	pop    %edi
  80055c:	5e                   	pop    %esi
  80055d:	5d                   	pop    %ebp
  80055e:	5c                   	pop    %esp
  80055f:	5b                   	pop    %ebx
  800560:	5a                   	pop    %edx
  800561:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800562:	8b 1c 24             	mov    (%esp),%ebx
  800565:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800569:	89 ec                	mov    %ebp,%esp
  80056b:	5d                   	pop    %ebp
  80056c:	c3                   	ret    

0080056d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	83 ec 28             	sub    $0x28,%esp
  800573:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800576:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800579:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057e:	b8 03 00 00 00       	mov    $0x3,%eax
  800583:	8b 55 08             	mov    0x8(%ebp),%edx
  800586:	89 cb                	mov    %ecx,%ebx
  800588:	89 cf                	mov    %ecx,%edi
  80058a:	51                   	push   %ecx
  80058b:	52                   	push   %edx
  80058c:	53                   	push   %ebx
  80058d:	54                   	push   %esp
  80058e:	55                   	push   %ebp
  80058f:	56                   	push   %esi
  800590:	57                   	push   %edi
  800591:	54                   	push   %esp
  800592:	5d                   	pop    %ebp
  800593:	8d 35 9b 05 80 00    	lea    0x80059b,%esi
  800599:	0f 34                	sysenter 
  80059b:	5f                   	pop    %edi
  80059c:	5e                   	pop    %esi
  80059d:	5d                   	pop    %ebp
  80059e:	5c                   	pop    %esp
  80059f:	5b                   	pop    %ebx
  8005a0:	5a                   	pop    %edx
  8005a1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	7e 28                	jle    8005ce <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005aa:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8005b1:	00 
  8005b2:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  8005b9:	00 
  8005ba:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8005c1:	00 
  8005c2:	c7 04 24 6c 16 80 00 	movl   $0x80166c,(%esp)
  8005c9:	e8 0a 00 00 00       	call   8005d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8005ce:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8005d4:	89 ec                	mov    %ebp,%esp
  8005d6:	5d                   	pop    %ebp
  8005d7:	c3                   	ret    

008005d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	56                   	push   %esi
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8005e0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8005e3:	a1 08 20 80 00       	mov    0x802008,%eax
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	74 10                	je     8005fc <_panic+0x24>
		cprintf("%s: ", argv0);
  8005ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f0:	c7 04 24 7a 16 80 00 	movl   $0x80167a,(%esp)
  8005f7:	e8 ad 00 00 00       	call   8006a9 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005fc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800602:	e8 26 ff ff ff       	call   80052d <sys_getenvid>
  800607:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80060e:	8b 55 08             	mov    0x8(%ebp),%edx
  800611:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800615:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061d:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  800624:	e8 80 00 00 00       	call   8006a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800629:	89 74 24 04          	mov    %esi,0x4(%esp)
  80062d:	8b 45 10             	mov    0x10(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 10 00 00 00       	call   800648 <vcprintf>
	cprintf("\n");
  800638:	c7 04 24 7f 16 80 00 	movl   $0x80167f,(%esp)
  80063f:	e8 65 00 00 00       	call   8006a9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800644:	cc                   	int3   
  800645:	eb fd                	jmp    800644 <_panic+0x6c>
	...

00800648 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800651:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800658:	00 00 00 
	b.cnt = 0;
  80065b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800662:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800665:	8b 45 0c             	mov    0xc(%ebp),%eax
  800668:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80066c:	8b 45 08             	mov    0x8(%ebp),%eax
  80066f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800673:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067d:	c7 04 24 c3 06 80 00 	movl   $0x8006c3,(%esp)
  800684:	e8 d3 01 00 00       	call   80085c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800689:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80068f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800693:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800699:	89 04 24             	mov    %eax,(%esp)
  80069c:	e8 53 fa ff ff       	call   8000f4 <sys_cputs>

	return b.cnt;
}
  8006a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    

008006a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8006af:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b9:	89 04 24             	mov    %eax,(%esp)
  8006bc:	e8 87 ff ff ff       	call   800648 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 14             	sub    $0x14,%esp
  8006ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006cd:	8b 03                	mov    (%ebx),%eax
  8006cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006d6:	83 c0 01             	add    $0x1,%eax
  8006d9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006e0:	75 19                	jne    8006fb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8006e2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8006e9:	00 
  8006ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8006ed:	89 04 24             	mov    %eax,(%esp)
  8006f0:	e8 ff f9 ff ff       	call   8000f4 <sys_cputs>
		b->idx = 0;
  8006f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8006fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006ff:	83 c4 14             	add    $0x14,%esp
  800702:	5b                   	pop    %ebx
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    
	...

00800710 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	57                   	push   %edi
  800714:	56                   	push   %esi
  800715:	53                   	push   %ebx
  800716:	83 ec 4c             	sub    $0x4c,%esp
  800719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071c:	89 d6                	mov    %edx,%esi
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800724:	8b 55 0c             	mov    0xc(%ebp),%edx
  800727:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80072a:	8b 45 10             	mov    0x10(%ebp),%eax
  80072d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800730:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  800733:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800736:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073b:	39 d1                	cmp    %edx,%ecx
  80073d:	72 07                	jb     800746 <printnum_v2+0x36>
  80073f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800742:	39 d0                	cmp    %edx,%eax
  800744:	77 5f                	ja     8007a5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800746:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80074a:	83 eb 01             	sub    $0x1,%ebx
  80074d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800751:	89 44 24 08          	mov    %eax,0x8(%esp)
  800755:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800759:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80075d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800760:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800763:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800766:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80076a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800771:	00 
  800772:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80077b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077f:	e8 4c 0c 00 00       	call   8013d0 <__udivdi3>
  800784:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800787:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80078a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800792:	89 04 24             	mov    %eax,(%esp)
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	89 f2                	mov    %esi,%edx
  80079b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80079e:	e8 6d ff ff ff       	call   800710 <printnum_v2>
  8007a3:	eb 1e                	jmp    8007c3 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8007a5:	83 ff 2d             	cmp    $0x2d,%edi
  8007a8:	74 19                	je     8007c3 <printnum_v2+0xb3>
		while (--width > 0)
  8007aa:	83 eb 01             	sub    $0x1,%ebx
  8007ad:	85 db                	test   %ebx,%ebx
  8007af:	90                   	nop
  8007b0:	7e 11                	jle    8007c3 <printnum_v2+0xb3>
			putch(padc, putdat);
  8007b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b6:	89 3c 24             	mov    %edi,(%esp)
  8007b9:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8007bc:	83 eb 01             	sub    $0x1,%ebx
  8007bf:	85 db                	test   %ebx,%ebx
  8007c1:	7f ef                	jg     8007b2 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007d9:	00 
  8007da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007dd:	89 14 24             	mov    %edx,(%esp)
  8007e0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007e3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e7:	e8 14 0d 00 00       	call   801500 <__umoddi3>
  8007ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f0:	0f be 80 a7 16 80 00 	movsbl 0x8016a7(%eax),%eax
  8007f7:	89 04 24             	mov    %eax,(%esp)
  8007fa:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007fd:	83 c4 4c             	add    $0x4c,%esp
  800800:	5b                   	pop    %ebx
  800801:	5e                   	pop    %esi
  800802:	5f                   	pop    %edi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800808:	83 fa 01             	cmp    $0x1,%edx
  80080b:	7e 0e                	jle    80081b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80080d:	8b 10                	mov    (%eax),%edx
  80080f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800812:	89 08                	mov    %ecx,(%eax)
  800814:	8b 02                	mov    (%edx),%eax
  800816:	8b 52 04             	mov    0x4(%edx),%edx
  800819:	eb 22                	jmp    80083d <getuint+0x38>
	else if (lflag)
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 10                	je     80082f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80081f:	8b 10                	mov    (%eax),%edx
  800821:	8d 4a 04             	lea    0x4(%edx),%ecx
  800824:	89 08                	mov    %ecx,(%eax)
  800826:	8b 02                	mov    (%edx),%eax
  800828:	ba 00 00 00 00       	mov    $0x0,%edx
  80082d:	eb 0e                	jmp    80083d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	8d 4a 04             	lea    0x4(%edx),%ecx
  800834:	89 08                	mov    %ecx,(%eax)
  800836:	8b 02                	mov    (%edx),%eax
  800838:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800845:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	3b 50 04             	cmp    0x4(%eax),%edx
  80084e:	73 0a                	jae    80085a <sprintputch+0x1b>
		*b->buf++ = ch;
  800850:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800853:	88 0a                	mov    %cl,(%edx)
  800855:	83 c2 01             	add    $0x1,%edx
  800858:	89 10                	mov    %edx,(%eax)
}
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	57                   	push   %edi
  800860:	56                   	push   %esi
  800861:	53                   	push   %ebx
  800862:	83 ec 6c             	sub    $0x6c,%esp
  800865:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800868:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80086f:	eb 1a                	jmp    80088b <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800871:	85 c0                	test   %eax,%eax
  800873:	0f 84 66 06 00 00    	je     800edf <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800880:	89 04 24             	mov    %eax,(%esp)
  800883:	ff 55 08             	call   *0x8(%ebp)
  800886:	eb 03                	jmp    80088b <vprintfmt+0x2f>
  800888:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80088b:	0f b6 07             	movzbl (%edi),%eax
  80088e:	83 c7 01             	add    $0x1,%edi
  800891:	83 f8 25             	cmp    $0x25,%eax
  800894:	75 db                	jne    800871 <vprintfmt+0x15>
  800896:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  80089a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80089f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8008a6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8008ab:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008b2:	be 00 00 00 00       	mov    $0x0,%esi
  8008b7:	eb 06                	jmp    8008bf <vprintfmt+0x63>
  8008b9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8008bd:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bf:	0f b6 17             	movzbl (%edi),%edx
  8008c2:	0f b6 c2             	movzbl %dl,%eax
  8008c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008c8:	8d 47 01             	lea    0x1(%edi),%eax
  8008cb:	83 ea 23             	sub    $0x23,%edx
  8008ce:	80 fa 55             	cmp    $0x55,%dl
  8008d1:	0f 87 60 05 00 00    	ja     800e37 <vprintfmt+0x5db>
  8008d7:	0f b6 d2             	movzbl %dl,%edx
  8008da:	ff 24 95 e0 17 80 00 	jmp    *0x8017e0(,%edx,4)
  8008e1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8008e6:	eb d5                	jmp    8008bd <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008eb:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  8008ee:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8008f1:	8d 7a d0             	lea    -0x30(%edx),%edi
  8008f4:	83 ff 09             	cmp    $0x9,%edi
  8008f7:	76 08                	jbe    800901 <vprintfmt+0xa5>
  8008f9:	eb 40                	jmp    80093b <vprintfmt+0xdf>
  8008fb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  8008ff:	eb bc                	jmp    8008bd <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800901:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800904:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  800907:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80090b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80090e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800911:	83 ff 09             	cmp    $0x9,%edi
  800914:	76 eb                	jbe    800901 <vprintfmt+0xa5>
  800916:	eb 23                	jmp    80093b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800918:	8b 55 14             	mov    0x14(%ebp),%edx
  80091b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80091e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800921:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  800923:	eb 16                	jmp    80093b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  800925:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800928:	c1 fa 1f             	sar    $0x1f,%edx
  80092b:	f7 d2                	not    %edx
  80092d:	21 55 d8             	and    %edx,-0x28(%ebp)
  800930:	eb 8b                	jmp    8008bd <vprintfmt+0x61>
  800932:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800939:	eb 82                	jmp    8008bd <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80093b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80093f:	0f 89 78 ff ff ff    	jns    8008bd <vprintfmt+0x61>
  800945:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800948:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80094b:	e9 6d ff ff ff       	jmp    8008bd <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800950:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  800953:	e9 65 ff ff ff       	jmp    8008bd <vprintfmt+0x61>
  800958:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80095b:	8b 45 14             	mov    0x14(%ebp),%eax
  80095e:	8d 50 04             	lea    0x4(%eax),%edx
  800961:	89 55 14             	mov    %edx,0x14(%ebp)
  800964:	8b 55 0c             	mov    0xc(%ebp),%edx
  800967:	89 54 24 04          	mov    %edx,0x4(%esp)
  80096b:	8b 00                	mov    (%eax),%eax
  80096d:	89 04 24             	mov    %eax,(%esp)
  800970:	ff 55 08             	call   *0x8(%ebp)
  800973:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800976:	e9 10 ff ff ff       	jmp    80088b <vprintfmt+0x2f>
  80097b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80097e:	8b 45 14             	mov    0x14(%ebp),%eax
  800981:	8d 50 04             	lea    0x4(%eax),%edx
  800984:	89 55 14             	mov    %edx,0x14(%ebp)
  800987:	8b 00                	mov    (%eax),%eax
  800989:	89 c2                	mov    %eax,%edx
  80098b:	c1 fa 1f             	sar    $0x1f,%edx
  80098e:	31 d0                	xor    %edx,%eax
  800990:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800992:	83 f8 08             	cmp    $0x8,%eax
  800995:	7f 0b                	jg     8009a2 <vprintfmt+0x146>
  800997:	8b 14 85 40 19 80 00 	mov    0x801940(,%eax,4),%edx
  80099e:	85 d2                	test   %edx,%edx
  8009a0:	75 26                	jne    8009c8 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8009a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a6:	c7 44 24 08 b8 16 80 	movl   $0x8016b8,0x8(%esp)
  8009ad:	00 
  8009ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b8:	89 1c 24             	mov    %ebx,(%esp)
  8009bb:	e8 a7 05 00 00       	call   800f67 <printfmt>
  8009c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009c3:	e9 c3 fe ff ff       	jmp    80088b <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009cc:	c7 44 24 08 c1 16 80 	movl   $0x8016c1,0x8(%esp)
  8009d3:	00 
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009db:	8b 55 08             	mov    0x8(%ebp),%edx
  8009de:	89 14 24             	mov    %edx,(%esp)
  8009e1:	e8 81 05 00 00       	call   800f67 <printfmt>
  8009e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009e9:	e9 9d fe ff ff       	jmp    80088b <vprintfmt+0x2f>
  8009ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	89 d9                	mov    %ebx,%ecx
  8009f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009f8:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fe:	8d 50 04             	lea    0x4(%eax),%edx
  800a01:	89 55 14             	mov    %edx,0x14(%ebp)
  800a04:	8b 30                	mov    (%eax),%esi
  800a06:	85 f6                	test   %esi,%esi
  800a08:	75 05                	jne    800a0f <vprintfmt+0x1b3>
  800a0a:	be c4 16 80 00       	mov    $0x8016c4,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  800a0f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800a13:	7e 06                	jle    800a1b <vprintfmt+0x1bf>
  800a15:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800a19:	75 10                	jne    800a2b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1b:	0f be 06             	movsbl (%esi),%eax
  800a1e:	85 c0                	test   %eax,%eax
  800a20:	0f 85 a2 00 00 00    	jne    800ac8 <vprintfmt+0x26c>
  800a26:	e9 92 00 00 00       	jmp    800abd <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a2b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a2f:	89 34 24             	mov    %esi,(%esp)
  800a32:	e8 74 05 00 00       	call   800fab <strnlen>
  800a37:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800a3a:	29 c2                	sub    %eax,%edx
  800a3c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800a3f:	85 d2                	test   %edx,%edx
  800a41:	7e d8                	jle    800a1b <vprintfmt+0x1bf>
					putch(padc, putdat);
  800a43:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800a47:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800a4a:	89 d3                	mov    %edx,%ebx
  800a4c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a4f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  800a52:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a55:	89 ce                	mov    %ecx,%esi
  800a57:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a5b:	89 34 24             	mov    %esi,(%esp)
  800a5e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	83 eb 01             	sub    $0x1,%ebx
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	7f ef                	jg     800a57 <vprintfmt+0x1fb>
  800a68:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800a6b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a6e:	8b 7d bc             	mov    -0x44(%ebp),%edi
  800a71:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a78:	eb a1                	jmp    800a1b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a7a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a7e:	74 1b                	je     800a9b <vprintfmt+0x23f>
  800a80:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a83:	83 fa 5e             	cmp    $0x5e,%edx
  800a86:	76 13                	jbe    800a9b <vprintfmt+0x23f>
					putch('?', putdat);
  800a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a96:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a99:	eb 0d                	jmp    800aa8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa2:	89 04 24             	mov    %eax,(%esp)
  800aa5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa8:	83 ef 01             	sub    $0x1,%edi
  800aab:	0f be 06             	movsbl (%esi),%eax
  800aae:	85 c0                	test   %eax,%eax
  800ab0:	74 05                	je     800ab7 <vprintfmt+0x25b>
  800ab2:	83 c6 01             	add    $0x1,%esi
  800ab5:	eb 1a                	jmp    800ad1 <vprintfmt+0x275>
  800ab7:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800aba:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800abd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ac1:	7f 1f                	jg     800ae2 <vprintfmt+0x286>
  800ac3:	e9 c0 fd ff ff       	jmp    800888 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ac8:	83 c6 01             	add    $0x1,%esi
  800acb:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800ace:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800ad1:	85 db                	test   %ebx,%ebx
  800ad3:	78 a5                	js     800a7a <vprintfmt+0x21e>
  800ad5:	83 eb 01             	sub    $0x1,%ebx
  800ad8:	79 a0                	jns    800a7a <vprintfmt+0x21e>
  800ada:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800add:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800ae0:	eb db                	jmp    800abd <vprintfmt+0x261>
  800ae2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae8:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800aeb:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800af2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800af9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800afb:	83 eb 01             	sub    $0x1,%ebx
  800afe:	85 db                	test   %ebx,%ebx
  800b00:	7f ec                	jg     800aee <vprintfmt+0x292>
  800b02:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800b05:	e9 81 fd ff ff       	jmp    80088b <vprintfmt+0x2f>
  800b0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b0d:	83 fe 01             	cmp    $0x1,%esi
  800b10:	7e 10                	jle    800b22 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  800b12:	8b 45 14             	mov    0x14(%ebp),%eax
  800b15:	8d 50 08             	lea    0x8(%eax),%edx
  800b18:	89 55 14             	mov    %edx,0x14(%ebp)
  800b1b:	8b 18                	mov    (%eax),%ebx
  800b1d:	8b 70 04             	mov    0x4(%eax),%esi
  800b20:	eb 26                	jmp    800b48 <vprintfmt+0x2ec>
	else if (lflag)
  800b22:	85 f6                	test   %esi,%esi
  800b24:	74 12                	je     800b38 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  800b26:	8b 45 14             	mov    0x14(%ebp),%eax
  800b29:	8d 50 04             	lea    0x4(%eax),%edx
  800b2c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2f:	8b 18                	mov    (%eax),%ebx
  800b31:	89 de                	mov    %ebx,%esi
  800b33:	c1 fe 1f             	sar    $0x1f,%esi
  800b36:	eb 10                	jmp    800b48 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 50 04             	lea    0x4(%eax),%edx
  800b3e:	89 55 14             	mov    %edx,0x14(%ebp)
  800b41:	8b 18                	mov    (%eax),%ebx
  800b43:	89 de                	mov    %ebx,%esi
  800b45:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  800b48:	83 f9 01             	cmp    $0x1,%ecx
  800b4b:	75 1e                	jne    800b6b <vprintfmt+0x30f>
                               if((long long)num > 0){
  800b4d:	85 f6                	test   %esi,%esi
  800b4f:	78 1a                	js     800b6b <vprintfmt+0x30f>
  800b51:	85 f6                	test   %esi,%esi
  800b53:	7f 05                	jg     800b5a <vprintfmt+0x2fe>
  800b55:	83 fb 00             	cmp    $0x0,%ebx
  800b58:	76 11                	jbe    800b6b <vprintfmt+0x30f>
                                   putch('+',putdat);
  800b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b61:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  800b68:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  800b6b:	85 f6                	test   %esi,%esi
  800b6d:	78 13                	js     800b82 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b6f:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  800b72:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  800b75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7d:	e9 da 00 00 00       	jmp    800c5c <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  800b82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b89:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b90:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b93:	89 da                	mov    %ebx,%edx
  800b95:	89 f1                	mov    %esi,%ecx
  800b97:	f7 da                	neg    %edx
  800b99:	83 d1 00             	adc    $0x0,%ecx
  800b9c:	f7 d9                	neg    %ecx
  800b9e:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800ba1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800ba4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ba7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bac:	e9 ab 00 00 00       	jmp    800c5c <vprintfmt+0x400>
  800bb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bb4:	89 f2                	mov    %esi,%edx
  800bb6:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb9:	e8 47 fc ff ff       	call   800805 <getuint>
  800bbe:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800bc1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800bc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bc7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800bcc:	e9 8b 00 00 00       	jmp    800c5c <vprintfmt+0x400>
  800bd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bdb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800be2:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  800be5:	89 f2                	mov    %esi,%edx
  800be7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bea:	e8 16 fc ff ff       	call   800805 <getuint>
  800bef:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800bf2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800bf5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bf8:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  800bfd:	eb 5d                	jmp    800c5c <vprintfmt+0x400>
  800bff:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800c02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c09:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c10:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800c13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c17:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c1e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800c21:	8b 45 14             	mov    0x14(%ebp),%eax
  800c24:	8d 50 04             	lea    0x4(%eax),%edx
  800c27:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2a:	8b 10                	mov    (%eax),%edx
  800c2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c31:	89 55 b0             	mov    %edx,-0x50(%ebp)
  800c34:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  800c37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c3a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c3f:	eb 1b                	jmp    800c5c <vprintfmt+0x400>
  800c41:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c44:	89 f2                	mov    %esi,%edx
  800c46:	8d 45 14             	lea    0x14(%ebp),%eax
  800c49:	e8 b7 fb ff ff       	call   800805 <getuint>
  800c4e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800c51:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800c54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c57:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c5c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800c60:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800c63:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800c66:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  800c6a:	77 09                	ja     800c75 <vprintfmt+0x419>
  800c6c:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  800c6f:	0f 82 ac 00 00 00    	jb     800d21 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  800c75:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800c78:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800c7c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800c7f:	83 ea 01             	sub    $0x1,%edx
  800c82:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c86:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8a:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c8e:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800c92:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800c95:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800c98:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c9f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ca6:	00 
  800ca7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800caa:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800cad:	89 0c 24             	mov    %ecx,(%esp)
  800cb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cb4:	e8 17 07 00 00       	call   8013d0 <__udivdi3>
  800cb9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800cbc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800cbf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cc7:	89 04 24             	mov    %eax,(%esp)
  800cca:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	e8 37 fa ff ff       	call   800710 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800cd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cdc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce0:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ce4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ce7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ceb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800cf2:	00 
  800cf3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  800cf6:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  800cf9:	89 14 24             	mov    %edx,(%esp)
  800cfc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d00:	e8 fb 07 00 00       	call   801500 <__umoddi3>
  800d05:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d09:	0f be 80 a7 16 80 00 	movsbl 0x8016a7(%eax),%eax
  800d10:	89 04 24             	mov    %eax,(%esp)
  800d13:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  800d16:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800d1a:	74 54                	je     800d70 <vprintfmt+0x514>
  800d1c:	e9 67 fb ff ff       	jmp    800888 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  800d21:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  800d25:	8d 76 00             	lea    0x0(%esi),%esi
  800d28:	0f 84 2a 01 00 00    	je     800e58 <vprintfmt+0x5fc>
		while (--width > 0)
  800d2e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d31:	83 ef 01             	sub    $0x1,%edi
  800d34:	85 ff                	test   %edi,%edi
  800d36:	0f 8e 5e 01 00 00    	jle    800e9a <vprintfmt+0x63e>
  800d3c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  800d3f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  800d42:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d45:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800d48:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800d4b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  800d4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d52:	89 1c 24             	mov    %ebx,(%esp)
  800d55:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  800d58:	83 ef 01             	sub    $0x1,%edi
  800d5b:	85 ff                	test   %edi,%edi
  800d5d:	7f ef                	jg     800d4e <vprintfmt+0x4f2>
  800d5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d62:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d65:	89 45 b0             	mov    %eax,-0x50(%ebp)
  800d68:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  800d6b:	e9 2a 01 00 00       	jmp    800e9a <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800d70:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800d73:	83 eb 01             	sub    $0x1,%ebx
  800d76:	85 db                	test   %ebx,%ebx
  800d78:	0f 8e 0a fb ff ff    	jle    800888 <vprintfmt+0x2c>
  800d7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d81:	89 7d d8             	mov    %edi,-0x28(%ebp)
  800d84:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  800d87:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800d92:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  800d94:	83 eb 01             	sub    $0x1,%ebx
  800d97:	85 db                	test   %ebx,%ebx
  800d99:	7f ec                	jg     800d87 <vprintfmt+0x52b>
  800d9b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d9e:	e9 e8 fa ff ff       	jmp    80088b <vprintfmt+0x2f>
  800da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  800da6:	8b 45 14             	mov    0x14(%ebp),%eax
  800da9:	8d 50 04             	lea    0x4(%eax),%edx
  800dac:	89 55 14             	mov    %edx,0x14(%ebp)
  800daf:	8b 00                	mov    (%eax),%eax
  800db1:	85 c0                	test   %eax,%eax
  800db3:	75 2a                	jne    800ddf <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  800db5:	c7 44 24 0c 60 17 80 	movl   $0x801760,0xc(%esp)
  800dbc:	00 
  800dbd:	c7 44 24 08 c1 16 80 	movl   $0x8016c1,0x8(%esp)
  800dc4:	00 
  800dc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcf:	89 0c 24             	mov    %ecx,(%esp)
  800dd2:	e8 90 01 00 00       	call   800f67 <printfmt>
  800dd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800dda:	e9 ac fa ff ff       	jmp    80088b <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  800ddf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800de2:	8b 13                	mov    (%ebx),%edx
  800de4:	83 fa 7f             	cmp    $0x7f,%edx
  800de7:	7e 29                	jle    800e12 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  800de9:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  800deb:	c7 44 24 0c 98 17 80 	movl   $0x801798,0xc(%esp)
  800df2:	00 
  800df3:	c7 44 24 08 c1 16 80 	movl   $0x8016c1,0x8(%esp)
  800dfa:	00 
  800dfb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	89 04 24             	mov    %eax,(%esp)
  800e05:	e8 5d 01 00 00       	call   800f67 <printfmt>
  800e0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e0d:	e9 79 fa ff ff       	jmp    80088b <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  800e12:	88 10                	mov    %dl,(%eax)
  800e14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e17:	e9 6f fa ff ff       	jmp    80088b <vprintfmt+0x2f>
  800e1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e29:	89 14 24             	mov    %edx,(%esp)
  800e2c:	ff 55 08             	call   *0x8(%ebp)
  800e2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  800e32:	e9 54 fa ff ff       	jmp    80088b <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e3e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e45:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e48:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e4b:	80 38 25             	cmpb   $0x25,(%eax)
  800e4e:	0f 84 37 fa ff ff    	je     80088b <vprintfmt+0x2f>
  800e54:	89 c7                	mov    %eax,%edi
  800e56:	eb f0                	jmp    800e48 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5f:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e63:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800e66:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e71:	00 
  800e72:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800e75:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800e78:	89 04 24             	mov    %eax,(%esp)
  800e7b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e7f:	e8 7c 06 00 00       	call   801500 <__umoddi3>
  800e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e88:	0f be 80 a7 16 80 00 	movsbl 0x8016a7(%eax),%eax
  800e8f:	89 04 24             	mov    %eax,(%esp)
  800e92:	ff 55 08             	call   *0x8(%ebp)
  800e95:	e9 d6 fe ff ff       	jmp    800d70 <vprintfmt+0x514>
  800e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ea1:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ea5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800ea8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eb3:	00 
  800eb4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800eb7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  800eba:	89 04 24             	mov    %eax,(%esp)
  800ebd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ec1:	e8 3a 06 00 00       	call   801500 <__umoddi3>
  800ec6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eca:	0f be 80 a7 16 80 00 	movsbl 0x8016a7(%eax),%eax
  800ed1:	89 04 24             	mov    %eax,(%esp)
  800ed4:	ff 55 08             	call   *0x8(%ebp)
  800ed7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800eda:	e9 ac f9 ff ff       	jmp    80088b <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800edf:	83 c4 6c             	add    $0x6c,%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 28             	sub    $0x28,%esp
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	74 04                	je     800efb <vsnprintf+0x14>
  800ef7:	85 d2                	test   %edx,%edx
  800ef9:	7f 07                	jg     800f02 <vsnprintf+0x1b>
  800efb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f00:	eb 3b                	jmp    800f3d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f05:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800f09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f13:	8b 45 14             	mov    0x14(%ebp),%eax
  800f16:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f21:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f28:	c7 04 24 3f 08 80 00 	movl   $0x80083f,(%esp)
  800f2f:	e8 28 f9 ff ff       	call   80085c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f37:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800f45:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800f48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5d:	89 04 24             	mov    %eax,(%esp)
  800f60:	e8 82 ff ff ff       	call   800ee7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    

00800f67 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800f6d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800f70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f74:	8b 45 10             	mov    0x10(%ebp),%eax
  800f77:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f82:	8b 45 08             	mov    0x8(%ebp),%eax
  800f85:	89 04 24             	mov    %eax,(%esp)
  800f88:	e8 cf f8 ff ff       	call   80085c <vprintfmt>
	va_end(ap);
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    
	...

00800f90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f96:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9b:	80 3a 00             	cmpb   $0x0,(%edx)
  800f9e:	74 09                	je     800fa9 <strlen+0x19>
		n++;
  800fa0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fa3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fa7:	75 f7                	jne    800fa0 <strlen+0x10>
		n++;
	return n;
}
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	53                   	push   %ebx
  800faf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fb5:	85 c9                	test   %ecx,%ecx
  800fb7:	74 19                	je     800fd2 <strnlen+0x27>
  800fb9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800fbc:	74 14                	je     800fd2 <strnlen+0x27>
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800fc3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fc6:	39 c8                	cmp    %ecx,%eax
  800fc8:	74 0d                	je     800fd7 <strnlen+0x2c>
  800fca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800fce:	75 f3                	jne    800fc3 <strnlen+0x18>
  800fd0:	eb 05                	jmp    800fd7 <strnlen+0x2c>
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800fd7:	5b                   	pop    %ebx
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	53                   	push   %ebx
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fe4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800fe9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800fed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ff0:	83 c2 01             	add    $0x1,%edx
  800ff3:	84 c9                	test   %cl,%cl
  800ff5:	75 f2                	jne    800fe9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ff7:	5b                   	pop    %ebx
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801004:	89 1c 24             	mov    %ebx,(%esp)
  801007:	e8 84 ff ff ff       	call   800f90 <strlen>
	strcpy(dst + len, src);
  80100c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801013:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801016:	89 04 24             	mov    %eax,(%esp)
  801019:	e8 bc ff ff ff       	call   800fda <strcpy>
	return dst;
}
  80101e:	89 d8                	mov    %ebx,%eax
  801020:	83 c4 08             	add    $0x8,%esp
  801023:	5b                   	pop    %ebx
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	56                   	push   %esi
  80102a:	53                   	push   %ebx
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801031:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801034:	85 f6                	test   %esi,%esi
  801036:	74 18                	je     801050 <strncpy+0x2a>
  801038:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80103d:	0f b6 1a             	movzbl (%edx),%ebx
  801040:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801043:	80 3a 01             	cmpb   $0x1,(%edx)
  801046:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801049:	83 c1 01             	add    $0x1,%ecx
  80104c:	39 ce                	cmp    %ecx,%esi
  80104e:	77 ed                	ja     80103d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	8b 75 08             	mov    0x8(%ebp),%esi
  80105c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801062:	89 f0                	mov    %esi,%eax
  801064:	85 c9                	test   %ecx,%ecx
  801066:	74 27                	je     80108f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801068:	83 e9 01             	sub    $0x1,%ecx
  80106b:	74 1d                	je     80108a <strlcpy+0x36>
  80106d:	0f b6 1a             	movzbl (%edx),%ebx
  801070:	84 db                	test   %bl,%bl
  801072:	74 16                	je     80108a <strlcpy+0x36>
			*dst++ = *src++;
  801074:	88 18                	mov    %bl,(%eax)
  801076:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801079:	83 e9 01             	sub    $0x1,%ecx
  80107c:	74 0e                	je     80108c <strlcpy+0x38>
			*dst++ = *src++;
  80107e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801081:	0f b6 1a             	movzbl (%edx),%ebx
  801084:	84 db                	test   %bl,%bl
  801086:	75 ec                	jne    801074 <strlcpy+0x20>
  801088:	eb 02                	jmp    80108c <strlcpy+0x38>
  80108a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80108c:	c6 00 00             	movb   $0x0,(%eax)
  80108f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80109e:	0f b6 01             	movzbl (%ecx),%eax
  8010a1:	84 c0                	test   %al,%al
  8010a3:	74 15                	je     8010ba <strcmp+0x25>
  8010a5:	3a 02                	cmp    (%edx),%al
  8010a7:	75 11                	jne    8010ba <strcmp+0x25>
		p++, q++;
  8010a9:	83 c1 01             	add    $0x1,%ecx
  8010ac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8010af:	0f b6 01             	movzbl (%ecx),%eax
  8010b2:	84 c0                	test   %al,%al
  8010b4:	74 04                	je     8010ba <strcmp+0x25>
  8010b6:	3a 02                	cmp    (%edx),%al
  8010b8:	74 ef                	je     8010a9 <strcmp+0x14>
  8010ba:	0f b6 c0             	movzbl %al,%eax
  8010bd:	0f b6 12             	movzbl (%edx),%edx
  8010c0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	53                   	push   %ebx
  8010c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	74 23                	je     8010f8 <strncmp+0x34>
  8010d5:	0f b6 1a             	movzbl (%edx),%ebx
  8010d8:	84 db                	test   %bl,%bl
  8010da:	74 25                	je     801101 <strncmp+0x3d>
  8010dc:	3a 19                	cmp    (%ecx),%bl
  8010de:	75 21                	jne    801101 <strncmp+0x3d>
  8010e0:	83 e8 01             	sub    $0x1,%eax
  8010e3:	74 13                	je     8010f8 <strncmp+0x34>
		n--, p++, q++;
  8010e5:	83 c2 01             	add    $0x1,%edx
  8010e8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010eb:	0f b6 1a             	movzbl (%edx),%ebx
  8010ee:	84 db                	test   %bl,%bl
  8010f0:	74 0f                	je     801101 <strncmp+0x3d>
  8010f2:	3a 19                	cmp    (%ecx),%bl
  8010f4:	74 ea                	je     8010e0 <strncmp+0x1c>
  8010f6:	eb 09                	jmp    801101 <strncmp+0x3d>
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010fd:	5b                   	pop    %ebx
  8010fe:	5d                   	pop    %ebp
  8010ff:	90                   	nop
  801100:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801101:	0f b6 02             	movzbl (%edx),%eax
  801104:	0f b6 11             	movzbl (%ecx),%edx
  801107:	29 d0                	sub    %edx,%eax
  801109:	eb f2                	jmp    8010fd <strncmp+0x39>

0080110b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801115:	0f b6 10             	movzbl (%eax),%edx
  801118:	84 d2                	test   %dl,%dl
  80111a:	74 18                	je     801134 <strchr+0x29>
		if (*s == c)
  80111c:	38 ca                	cmp    %cl,%dl
  80111e:	75 0a                	jne    80112a <strchr+0x1f>
  801120:	eb 17                	jmp    801139 <strchr+0x2e>
  801122:	38 ca                	cmp    %cl,%dl
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	74 0f                	je     801139 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80112a:	83 c0 01             	add    $0x1,%eax
  80112d:	0f b6 10             	movzbl (%eax),%edx
  801130:	84 d2                	test   %dl,%dl
  801132:	75 ee                	jne    801122 <strchr+0x17>
  801134:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801145:	0f b6 10             	movzbl (%eax),%edx
  801148:	84 d2                	test   %dl,%dl
  80114a:	74 18                	je     801164 <strfind+0x29>
		if (*s == c)
  80114c:	38 ca                	cmp    %cl,%dl
  80114e:	75 0a                	jne    80115a <strfind+0x1f>
  801150:	eb 12                	jmp    801164 <strfind+0x29>
  801152:	38 ca                	cmp    %cl,%dl
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	74 0a                	je     801164 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80115a:	83 c0 01             	add    $0x1,%eax
  80115d:	0f b6 10             	movzbl (%eax),%edx
  801160:	84 d2                	test   %dl,%dl
  801162:	75 ee                	jne    801152 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 0c             	sub    $0xc,%esp
  80116c:	89 1c 24             	mov    %ebx,(%esp)
  80116f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801173:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801177:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801180:	85 c9                	test   %ecx,%ecx
  801182:	74 30                	je     8011b4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801184:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80118a:	75 25                	jne    8011b1 <memset+0x4b>
  80118c:	f6 c1 03             	test   $0x3,%cl
  80118f:	75 20                	jne    8011b1 <memset+0x4b>
		c &= 0xFF;
  801191:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801194:	89 d3                	mov    %edx,%ebx
  801196:	c1 e3 08             	shl    $0x8,%ebx
  801199:	89 d6                	mov    %edx,%esi
  80119b:	c1 e6 18             	shl    $0x18,%esi
  80119e:	89 d0                	mov    %edx,%eax
  8011a0:	c1 e0 10             	shl    $0x10,%eax
  8011a3:	09 f0                	or     %esi,%eax
  8011a5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8011a7:	09 d8                	or     %ebx,%eax
  8011a9:	c1 e9 02             	shr    $0x2,%ecx
  8011ac:	fc                   	cld    
  8011ad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011af:	eb 03                	jmp    8011b4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011b1:	fc                   	cld    
  8011b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011b4:	89 f8                	mov    %edi,%eax
  8011b6:	8b 1c 24             	mov    (%esp),%ebx
  8011b9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011bd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011c1:	89 ec                	mov    %ebp,%esp
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	89 34 24             	mov    %esi,(%esp)
  8011ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8011d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8011db:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8011dd:	39 c6                	cmp    %eax,%esi
  8011df:	73 35                	jae    801216 <memmove+0x51>
  8011e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8011e4:	39 d0                	cmp    %edx,%eax
  8011e6:	73 2e                	jae    801216 <memmove+0x51>
		s += n;
		d += n;
  8011e8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011ea:	f6 c2 03             	test   $0x3,%dl
  8011ed:	75 1b                	jne    80120a <memmove+0x45>
  8011ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011f5:	75 13                	jne    80120a <memmove+0x45>
  8011f7:	f6 c1 03             	test   $0x3,%cl
  8011fa:	75 0e                	jne    80120a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8011fc:	83 ef 04             	sub    $0x4,%edi
  8011ff:	8d 72 fc             	lea    -0x4(%edx),%esi
  801202:	c1 e9 02             	shr    $0x2,%ecx
  801205:	fd                   	std    
  801206:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801208:	eb 09                	jmp    801213 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80120a:	83 ef 01             	sub    $0x1,%edi
  80120d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801210:	fd                   	std    
  801211:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801213:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801214:	eb 20                	jmp    801236 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801216:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80121c:	75 15                	jne    801233 <memmove+0x6e>
  80121e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801224:	75 0d                	jne    801233 <memmove+0x6e>
  801226:	f6 c1 03             	test   $0x3,%cl
  801229:	75 08                	jne    801233 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80122b:	c1 e9 02             	shr    $0x2,%ecx
  80122e:	fc                   	cld    
  80122f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801231:	eb 03                	jmp    801236 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801233:	fc                   	cld    
  801234:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801236:	8b 34 24             	mov    (%esp),%esi
  801239:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80123d:	89 ec                	mov    %ebp,%esp
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801247:	8b 45 10             	mov    0x10(%ebp),%eax
  80124a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80124e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801251:	89 44 24 04          	mov    %eax,0x4(%esp)
  801255:	8b 45 08             	mov    0x8(%ebp),%eax
  801258:	89 04 24             	mov    %eax,(%esp)
  80125b:	e8 65 ff ff ff       	call   8011c5 <memmove>
}
  801260:	c9                   	leave  
  801261:	c3                   	ret    

00801262 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	8b 75 08             	mov    0x8(%ebp),%esi
  80126b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80126e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801271:	85 c9                	test   %ecx,%ecx
  801273:	74 36                	je     8012ab <memcmp+0x49>
		if (*s1 != *s2)
  801275:	0f b6 06             	movzbl (%esi),%eax
  801278:	0f b6 1f             	movzbl (%edi),%ebx
  80127b:	38 d8                	cmp    %bl,%al
  80127d:	74 20                	je     80129f <memcmp+0x3d>
  80127f:	eb 14                	jmp    801295 <memcmp+0x33>
  801281:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801286:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80128b:	83 c2 01             	add    $0x1,%edx
  80128e:	83 e9 01             	sub    $0x1,%ecx
  801291:	38 d8                	cmp    %bl,%al
  801293:	74 12                	je     8012a7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801295:	0f b6 c0             	movzbl %al,%eax
  801298:	0f b6 db             	movzbl %bl,%ebx
  80129b:	29 d8                	sub    %ebx,%eax
  80129d:	eb 11                	jmp    8012b0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80129f:	83 e9 01             	sub    $0x1,%ecx
  8012a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a7:	85 c9                	test   %ecx,%ecx
  8012a9:	75 d6                	jne    801281 <memcmp+0x1f>
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8012bb:	89 c2                	mov    %eax,%edx
  8012bd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012c0:	39 d0                	cmp    %edx,%eax
  8012c2:	73 15                	jae    8012d9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8012c8:	38 08                	cmp    %cl,(%eax)
  8012ca:	75 06                	jne    8012d2 <memfind+0x1d>
  8012cc:	eb 0b                	jmp    8012d9 <memfind+0x24>
  8012ce:	38 08                	cmp    %cl,(%eax)
  8012d0:	74 07                	je     8012d9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8012d2:	83 c0 01             	add    $0x1,%eax
  8012d5:	39 c2                	cmp    %eax,%edx
  8012d7:	77 f5                	ja     8012ce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	57                   	push   %edi
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012ea:	0f b6 02             	movzbl (%edx),%eax
  8012ed:	3c 20                	cmp    $0x20,%al
  8012ef:	74 04                	je     8012f5 <strtol+0x1a>
  8012f1:	3c 09                	cmp    $0x9,%al
  8012f3:	75 0e                	jne    801303 <strtol+0x28>
		s++;
  8012f5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012f8:	0f b6 02             	movzbl (%edx),%eax
  8012fb:	3c 20                	cmp    $0x20,%al
  8012fd:	74 f6                	je     8012f5 <strtol+0x1a>
  8012ff:	3c 09                	cmp    $0x9,%al
  801301:	74 f2                	je     8012f5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801303:	3c 2b                	cmp    $0x2b,%al
  801305:	75 0c                	jne    801313 <strtol+0x38>
		s++;
  801307:	83 c2 01             	add    $0x1,%edx
  80130a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801311:	eb 15                	jmp    801328 <strtol+0x4d>
	else if (*s == '-')
  801313:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80131a:	3c 2d                	cmp    $0x2d,%al
  80131c:	75 0a                	jne    801328 <strtol+0x4d>
		s++, neg = 1;
  80131e:	83 c2 01             	add    $0x1,%edx
  801321:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801328:	85 db                	test   %ebx,%ebx
  80132a:	0f 94 c0             	sete   %al
  80132d:	74 05                	je     801334 <strtol+0x59>
  80132f:	83 fb 10             	cmp    $0x10,%ebx
  801332:	75 18                	jne    80134c <strtol+0x71>
  801334:	80 3a 30             	cmpb   $0x30,(%edx)
  801337:	75 13                	jne    80134c <strtol+0x71>
  801339:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80133d:	8d 76 00             	lea    0x0(%esi),%esi
  801340:	75 0a                	jne    80134c <strtol+0x71>
		s += 2, base = 16;
  801342:	83 c2 02             	add    $0x2,%edx
  801345:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80134a:	eb 15                	jmp    801361 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80134c:	84 c0                	test   %al,%al
  80134e:	66 90                	xchg   %ax,%ax
  801350:	74 0f                	je     801361 <strtol+0x86>
  801352:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801357:	80 3a 30             	cmpb   $0x30,(%edx)
  80135a:	75 05                	jne    801361 <strtol+0x86>
		s++, base = 8;
  80135c:	83 c2 01             	add    $0x1,%edx
  80135f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801361:	b8 00 00 00 00       	mov    $0x0,%eax
  801366:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801368:	0f b6 0a             	movzbl (%edx),%ecx
  80136b:	89 cf                	mov    %ecx,%edi
  80136d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801370:	80 fb 09             	cmp    $0x9,%bl
  801373:	77 08                	ja     80137d <strtol+0xa2>
			dig = *s - '0';
  801375:	0f be c9             	movsbl %cl,%ecx
  801378:	83 e9 30             	sub    $0x30,%ecx
  80137b:	eb 1e                	jmp    80139b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80137d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801380:	80 fb 19             	cmp    $0x19,%bl
  801383:	77 08                	ja     80138d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801385:	0f be c9             	movsbl %cl,%ecx
  801388:	83 e9 57             	sub    $0x57,%ecx
  80138b:	eb 0e                	jmp    80139b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80138d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801390:	80 fb 19             	cmp    $0x19,%bl
  801393:	77 15                	ja     8013aa <strtol+0xcf>
			dig = *s - 'A' + 10;
  801395:	0f be c9             	movsbl %cl,%ecx
  801398:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80139b:	39 f1                	cmp    %esi,%ecx
  80139d:	7d 0b                	jge    8013aa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80139f:	83 c2 01             	add    $0x1,%edx
  8013a2:	0f af c6             	imul   %esi,%eax
  8013a5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8013a8:	eb be                	jmp    801368 <strtol+0x8d>
  8013aa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8013ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013b0:	74 05                	je     8013b7 <strtol+0xdc>
		*endptr = (char *) s;
  8013b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013b5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8013b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013bb:	74 04                	je     8013c1 <strtol+0xe6>
  8013bd:	89 c8                	mov    %ecx,%eax
  8013bf:	f7 d8                	neg    %eax
}
  8013c1:	83 c4 04             	add    $0x4,%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5e                   	pop    %esi
  8013c6:	5f                   	pop    %edi
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    
  8013c9:	00 00                	add    %al,(%eax)
  8013cb:	00 00                	add    %al,(%eax)
  8013cd:	00 00                	add    %al,(%eax)
	...

008013d0 <__udivdi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	83 ec 10             	sub    $0x10,%esp
  8013d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013db:	8b 55 08             	mov    0x8(%ebp),%edx
  8013de:	8b 75 10             	mov    0x10(%ebp),%esi
  8013e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8013e9:	75 35                	jne    801420 <__udivdi3+0x50>
  8013eb:	39 fe                	cmp    %edi,%esi
  8013ed:	77 61                	ja     801450 <__udivdi3+0x80>
  8013ef:	85 f6                	test   %esi,%esi
  8013f1:	75 0b                	jne    8013fe <__udivdi3+0x2e>
  8013f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f8:	31 d2                	xor    %edx,%edx
  8013fa:	f7 f6                	div    %esi
  8013fc:	89 c6                	mov    %eax,%esi
  8013fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801401:	31 d2                	xor    %edx,%edx
  801403:	89 f8                	mov    %edi,%eax
  801405:	f7 f6                	div    %esi
  801407:	89 c7                	mov    %eax,%edi
  801409:	89 c8                	mov    %ecx,%eax
  80140b:	f7 f6                	div    %esi
  80140d:	89 c1                	mov    %eax,%ecx
  80140f:	89 fa                	mov    %edi,%edx
  801411:	89 c8                	mov    %ecx,%eax
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	5e                   	pop    %esi
  801417:	5f                   	pop    %edi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    
  80141a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801420:	39 f8                	cmp    %edi,%eax
  801422:	77 1c                	ja     801440 <__udivdi3+0x70>
  801424:	0f bd d0             	bsr    %eax,%edx
  801427:	83 f2 1f             	xor    $0x1f,%edx
  80142a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80142d:	75 39                	jne    801468 <__udivdi3+0x98>
  80142f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801432:	0f 86 a0 00 00 00    	jbe    8014d8 <__udivdi3+0x108>
  801438:	39 f8                	cmp    %edi,%eax
  80143a:	0f 82 98 00 00 00    	jb     8014d8 <__udivdi3+0x108>
  801440:	31 ff                	xor    %edi,%edi
  801442:	31 c9                	xor    %ecx,%ecx
  801444:	89 c8                	mov    %ecx,%eax
  801446:	89 fa                	mov    %edi,%edx
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
  801450:	89 d1                	mov    %edx,%ecx
  801452:	89 fa                	mov    %edi,%edx
  801454:	89 c8                	mov    %ecx,%eax
  801456:	31 ff                	xor    %edi,%edi
  801458:	f7 f6                	div    %esi
  80145a:	89 c1                	mov    %eax,%ecx
  80145c:	89 fa                	mov    %edi,%edx
  80145e:	89 c8                	mov    %ecx,%eax
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	5e                   	pop    %esi
  801464:	5f                   	pop    %edi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    
  801467:	90                   	nop
  801468:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80146c:	89 f2                	mov    %esi,%edx
  80146e:	d3 e0                	shl    %cl,%eax
  801470:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801473:	b8 20 00 00 00       	mov    $0x20,%eax
  801478:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80147b:	89 c1                	mov    %eax,%ecx
  80147d:	d3 ea                	shr    %cl,%edx
  80147f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801483:	0b 55 ec             	or     -0x14(%ebp),%edx
  801486:	d3 e6                	shl    %cl,%esi
  801488:	89 c1                	mov    %eax,%ecx
  80148a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80148d:	89 fe                	mov    %edi,%esi
  80148f:	d3 ee                	shr    %cl,%esi
  801491:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801495:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801498:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80149b:	d3 e7                	shl    %cl,%edi
  80149d:	89 c1                	mov    %eax,%ecx
  80149f:	d3 ea                	shr    %cl,%edx
  8014a1:	09 d7                	or     %edx,%edi
  8014a3:	89 f2                	mov    %esi,%edx
  8014a5:	89 f8                	mov    %edi,%eax
  8014a7:	f7 75 ec             	divl   -0x14(%ebp)
  8014aa:	89 d6                	mov    %edx,%esi
  8014ac:	89 c7                	mov    %eax,%edi
  8014ae:	f7 65 e8             	mull   -0x18(%ebp)
  8014b1:	39 d6                	cmp    %edx,%esi
  8014b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014b6:	72 30                	jb     8014e8 <__udivdi3+0x118>
  8014b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014bf:	d3 e2                	shl    %cl,%edx
  8014c1:	39 c2                	cmp    %eax,%edx
  8014c3:	73 05                	jae    8014ca <__udivdi3+0xfa>
  8014c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8014c8:	74 1e                	je     8014e8 <__udivdi3+0x118>
  8014ca:	89 f9                	mov    %edi,%ecx
  8014cc:	31 ff                	xor    %edi,%edi
  8014ce:	e9 71 ff ff ff       	jmp    801444 <__udivdi3+0x74>
  8014d3:	90                   	nop
  8014d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	31 ff                	xor    %edi,%edi
  8014da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8014df:	e9 60 ff ff ff       	jmp    801444 <__udivdi3+0x74>
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8014eb:	31 ff                	xor    %edi,%edi
  8014ed:	89 c8                	mov    %ecx,%eax
  8014ef:	89 fa                	mov    %edi,%edx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	5e                   	pop    %esi
  8014f5:	5f                   	pop    %edi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    
	...

00801500 <__umoddi3>:
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	83 ec 20             	sub    $0x20,%esp
  801508:	8b 55 14             	mov    0x14(%ebp),%edx
  80150b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801511:	8b 75 0c             	mov    0xc(%ebp),%esi
  801514:	85 d2                	test   %edx,%edx
  801516:	89 c8                	mov    %ecx,%eax
  801518:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80151b:	75 13                	jne    801530 <__umoddi3+0x30>
  80151d:	39 f7                	cmp    %esi,%edi
  80151f:	76 3f                	jbe    801560 <__umoddi3+0x60>
  801521:	89 f2                	mov    %esi,%edx
  801523:	f7 f7                	div    %edi
  801525:	89 d0                	mov    %edx,%eax
  801527:	31 d2                	xor    %edx,%edx
  801529:	83 c4 20             	add    $0x20,%esp
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    
  801530:	39 f2                	cmp    %esi,%edx
  801532:	77 4c                	ja     801580 <__umoddi3+0x80>
  801534:	0f bd ca             	bsr    %edx,%ecx
  801537:	83 f1 1f             	xor    $0x1f,%ecx
  80153a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80153d:	75 51                	jne    801590 <__umoddi3+0x90>
  80153f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801542:	0f 87 e0 00 00 00    	ja     801628 <__umoddi3+0x128>
  801548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154b:	29 f8                	sub    %edi,%eax
  80154d:	19 d6                	sbb    %edx,%esi
  80154f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801555:	89 f2                	mov    %esi,%edx
  801557:	83 c4 20             	add    $0x20,%esp
  80155a:	5e                   	pop    %esi
  80155b:	5f                   	pop    %edi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    
  80155e:	66 90                	xchg   %ax,%ax
  801560:	85 ff                	test   %edi,%edi
  801562:	75 0b                	jne    80156f <__umoddi3+0x6f>
  801564:	b8 01 00 00 00       	mov    $0x1,%eax
  801569:	31 d2                	xor    %edx,%edx
  80156b:	f7 f7                	div    %edi
  80156d:	89 c7                	mov    %eax,%edi
  80156f:	89 f0                	mov    %esi,%eax
  801571:	31 d2                	xor    %edx,%edx
  801573:	f7 f7                	div    %edi
  801575:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801578:	f7 f7                	div    %edi
  80157a:	eb a9                	jmp    801525 <__umoddi3+0x25>
  80157c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801580:	89 c8                	mov    %ecx,%eax
  801582:	89 f2                	mov    %esi,%edx
  801584:	83 c4 20             	add    $0x20,%esp
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    
  80158b:	90                   	nop
  80158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801590:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801594:	d3 e2                	shl    %cl,%edx
  801596:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801599:	ba 20 00 00 00       	mov    $0x20,%edx
  80159e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8015a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015a8:	89 fa                	mov    %edi,%edx
  8015aa:	d3 ea                	shr    %cl,%edx
  8015ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8015b3:	d3 e7                	shl    %cl,%edi
  8015b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015bc:	89 f2                	mov    %esi,%edx
  8015be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	d3 ea                	shr    %cl,%edx
  8015c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	d3 e6                	shl    %cl,%esi
  8015d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015d4:	d3 ea                	shr    %cl,%edx
  8015d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015da:	09 d6                	or     %edx,%esi
  8015dc:	89 f0                	mov    %esi,%eax
  8015de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015e1:	d3 e7                	shl    %cl,%edi
  8015e3:	89 f2                	mov    %esi,%edx
  8015e5:	f7 75 f4             	divl   -0xc(%ebp)
  8015e8:	89 d6                	mov    %edx,%esi
  8015ea:	f7 65 e8             	mull   -0x18(%ebp)
  8015ed:	39 d6                	cmp    %edx,%esi
  8015ef:	72 2b                	jb     80161c <__umoddi3+0x11c>
  8015f1:	39 c7                	cmp    %eax,%edi
  8015f3:	72 23                	jb     801618 <__umoddi3+0x118>
  8015f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015f9:	29 c7                	sub    %eax,%edi
  8015fb:	19 d6                	sbb    %edx,%esi
  8015fd:	89 f0                	mov    %esi,%eax
  8015ff:	89 f2                	mov    %esi,%edx
  801601:	d3 ef                	shr    %cl,%edi
  801603:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801607:	d3 e0                	shl    %cl,%eax
  801609:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80160d:	09 f8                	or     %edi,%eax
  80160f:	d3 ea                	shr    %cl,%edx
  801611:	83 c4 20             	add    $0x20,%esp
  801614:	5e                   	pop    %esi
  801615:	5f                   	pop    %edi
  801616:	5d                   	pop    %ebp
  801617:	c3                   	ret    
  801618:	39 d6                	cmp    %edx,%esi
  80161a:	75 d9                	jne    8015f5 <__umoddi3+0xf5>
  80161c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80161f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801622:	eb d1                	jmp    8015f5 <__umoddi3+0xf5>
  801624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801628:	39 f2                	cmp    %esi,%edx
  80162a:	0f 82 18 ff ff ff    	jb     801548 <__umoddi3+0x48>
  801630:	e9 1d ff ff ff       	jmp    801552 <__umoddi3+0x52>
