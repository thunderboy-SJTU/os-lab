
obj/user/softint.debug:     file format elf32-i386


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
  80004e:	e8 7f 05 00 00       	call   8005d2 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	89 c2                	mov    %eax,%edx
  80005a:	c1 e2 07             	shl    $0x7,%edx
  80005d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004
        //cprintf("ENVX sys_get_envid(): %d\n",ENVX(sys_getenvid()));
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x38>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800096:	e8 c0 0a 00 00       	call   800b5b <close_all>
	sys_env_destroy(0);
  80009b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a2:	e8 6b 05 00 00       	call   800612 <sys_env_destroy>
}
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    
  8000a9:	00 00                	add    %al,(%eax)
	...

008000ac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 08             	sub    $0x8,%esp
  8000b2:	89 1c 24             	mov    %ebx,(%esp)
  8000b5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000be:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c3:	89 d1                	mov    %edx,%ecx
  8000c5:	89 d3                	mov    %edx,%ebx
  8000c7:	89 d7                	mov    %edx,%edi
  8000c9:	51                   	push   %ecx
  8000ca:	52                   	push   %edx
  8000cb:	53                   	push   %ebx
  8000cc:	54                   	push   %esp
  8000cd:	55                   	push   %ebp
  8000ce:	56                   	push   %esi
  8000cf:	57                   	push   %edi
  8000d0:	54                   	push   %esp
  8000d1:	5d                   	pop    %ebp
  8000d2:	8d 35 da 00 80 00    	lea    0x8000da,%esi
  8000d8:	0f 34                	sysenter 
  8000da:	5f                   	pop    %edi
  8000db:	5e                   	pop    %esi
  8000dc:	5d                   	pop    %ebp
  8000dd:	5c                   	pop    %esp
  8000de:	5b                   	pop    %ebx
  8000df:	5a                   	pop    %edx
  8000e0:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	8b 1c 24             	mov    (%esp),%ebx
  8000e4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000e8:	89 ec                	mov    %ebp,%esp
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	89 1c 24             	mov    %ebx,(%esp)
  8000f5:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800101:	8b 55 08             	mov    0x8(%ebp),%edx
  800104:	89 c3                	mov    %eax,%ebx
  800106:	89 c7                	mov    %eax,%edi
  800108:	51                   	push   %ecx
  800109:	52                   	push   %edx
  80010a:	53                   	push   %ebx
  80010b:	54                   	push   %esp
  80010c:	55                   	push   %ebp
  80010d:	56                   	push   %esi
  80010e:	57                   	push   %edi
  80010f:	54                   	push   %esp
  800110:	5d                   	pop    %ebp
  800111:	8d 35 19 01 80 00    	lea    0x800119,%esi
  800117:	0f 34                	sysenter 
  800119:	5f                   	pop    %edi
  80011a:	5e                   	pop    %esi
  80011b:	5d                   	pop    %ebp
  80011c:	5c                   	pop    %esp
  80011d:	5b                   	pop    %ebx
  80011e:	5a                   	pop    %edx
  80011f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800120:	8b 1c 24             	mov    (%esp),%ebx
  800123:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800127:	89 ec                	mov    %ebp,%esp
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_exec>:
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	89 1c 24             	mov    %ebx,(%esp)
  800134:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800138:	b8 10 00 00 00       	mov    $0x10,%eax
  80013d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800140:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800146:	8b 55 08             	mov    0x8(%ebp),%edx
  800149:	51                   	push   %ecx
  80014a:	52                   	push   %edx
  80014b:	53                   	push   %ebx
  80014c:	54                   	push   %esp
  80014d:	55                   	push   %ebp
  80014e:	56                   	push   %esi
  80014f:	57                   	push   %edi
  800150:	54                   	push   %esp
  800151:	5d                   	pop    %ebp
  800152:	8d 35 5a 01 80 00    	lea    0x80015a,%esi
  800158:	0f 34                	sysenter 
  80015a:	5f                   	pop    %edi
  80015b:	5e                   	pop    %esi
  80015c:	5d                   	pop    %ebp
  80015d:	5c                   	pop    %esp
  80015e:	5b                   	pop    %ebx
  80015f:	5a                   	pop    %edx
  800160:	59                   	pop    %ecx
}

int 
sys_exec(void* vph, uint32_t phnum, uint32_t esp, uint32_t eip){
         return syscall(SYS_exec, 0, (uint32_t)vph, phnum, esp, eip, 0);
}
  800161:	8b 1c 24             	mov    (%esp),%ebx
  800164:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800168:	89 ec                	mov    %ebp,%esp
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_env_set_prior>:
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 28             	sub    $0x28,%esp
  800172:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800175:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800178:	bb 00 00 00 00       	mov    $0x0,%ebx
  80017d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	89 df                	mov    %ebx,%edi
  80018a:	51                   	push   %ecx
  80018b:	52                   	push   %edx
  80018c:	53                   	push   %ebx
  80018d:	54                   	push   %esp
  80018e:	55                   	push   %ebp
  80018f:	56                   	push   %esi
  800190:	57                   	push   %edi
  800191:	54                   	push   %esp
  800192:	5d                   	pop    %ebp
  800193:	8d 35 9b 01 80 00    	lea    0x80019b,%esi
  800199:	0f 34                	sysenter 
  80019b:	5f                   	pop    %edi
  80019c:	5e                   	pop    %esi
  80019d:	5d                   	pop    %ebp
  80019e:	5c                   	pop    %esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5a                   	pop    %edx
  8001a1:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	7e 28                	jle    8001ce <sys_env_set_prior+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001aa:	c7 44 24 0c 0f 00 00 	movl   $0xf,0xc(%esp)
  8001b1:	00 
  8001b2:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  8001b9:	00 
  8001ba:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8001c1:	00 
  8001c2:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  8001c9:	e8 76 0d 00 00       	call   800f44 <_panic>
}

int 
sys_env_set_prior(envid_t envid, uint32_t prior){
         return syscall(SYS_env_set_prior,1,envid, prior, 0, 0, 0);
}
  8001ce:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d4:	89 ec                	mov    %ebp,%esp
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    

008001d8 <sys_sbrk>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

int
sys_sbrk(uint32_t inc)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	89 1c 24             	mov    %ebx,(%esp)
  8001e1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ea:	b8 11 00 00 00       	mov    $0x11,%eax
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	89 cb                	mov    %ecx,%ebx
  8001f4:	89 cf                	mov    %ecx,%edi
  8001f6:	51                   	push   %ecx
  8001f7:	52                   	push   %edx
  8001f8:	53                   	push   %ebx
  8001f9:	54                   	push   %esp
  8001fa:	55                   	push   %ebp
  8001fb:	56                   	push   %esi
  8001fc:	57                   	push   %edi
  8001fd:	54                   	push   %esp
  8001fe:	5d                   	pop    %ebp
  8001ff:	8d 35 07 02 80 00    	lea    0x800207,%esi
  800205:	0f 34                	sysenter 
  800207:	5f                   	pop    %edi
  800208:	5e                   	pop    %esi
  800209:	5d                   	pop    %ebp
  80020a:	5c                   	pop    %esp
  80020b:	5b                   	pop    %ebx
  80020c:	5a                   	pop    %edx
  80020d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80020e:	8b 1c 24             	mov    (%esp),%ebx
  800211:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800215:	89 ec                	mov    %ebp,%esp
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 28             	sub    $0x28,%esp
  80021f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800222:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800225:	b9 00 00 00 00       	mov    $0x0,%ecx
  80022a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	89 cb                	mov    %ecx,%ebx
  800234:	89 cf                	mov    %ecx,%edi
  800236:	51                   	push   %ecx
  800237:	52                   	push   %edx
  800238:	53                   	push   %ebx
  800239:	54                   	push   %esp
  80023a:	55                   	push   %ebp
  80023b:	56                   	push   %esi
  80023c:	57                   	push   %edi
  80023d:	54                   	push   %esp
  80023e:	5d                   	pop    %ebp
  80023f:	8d 35 47 02 80 00    	lea    0x800247,%esi
  800245:	0f 34                	sysenter 
  800247:	5f                   	pop    %edi
  800248:	5e                   	pop    %esi
  800249:	5d                   	pop    %ebp
  80024a:	5c                   	pop    %esp
  80024b:	5b                   	pop    %ebx
  80024c:	5a                   	pop    %edx
  80024d:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 28                	jle    80027a <sys_ipc_recv+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	89 44 24 10          	mov    %eax,0x10(%esp)
  800256:	c7 44 24 0c 0e 00 00 	movl   $0xe,0xc(%esp)
  80025d:	00 
  80025e:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  800265:	00 
  800266:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80026d:	00 
  80026e:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  800275:	e8 ca 0c 00 00       	call   800f44 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80027a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80027d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800280:	89 ec                	mov    %ebp,%esp
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	89 1c 24             	mov    %ebx,(%esp)
  80028d:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800291:	b8 0d 00 00 00       	mov    $0xd,%eax
  800296:	8b 7d 14             	mov    0x14(%ebp),%edi
  800299:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80029c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029f:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a2:	51                   	push   %ecx
  8002a3:	52                   	push   %edx
  8002a4:	53                   	push   %ebx
  8002a5:	54                   	push   %esp
  8002a6:	55                   	push   %ebp
  8002a7:	56                   	push   %esi
  8002a8:	57                   	push   %edi
  8002a9:	54                   	push   %esp
  8002aa:	5d                   	pop    %ebp
  8002ab:	8d 35 b3 02 80 00    	lea    0x8002b3,%esi
  8002b1:	0f 34                	sysenter 
  8002b3:	5f                   	pop    %edi
  8002b4:	5e                   	pop    %esi
  8002b5:	5d                   	pop    %ebp
  8002b6:	5c                   	pop    %esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5a                   	pop    %edx
  8002b9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ba:	8b 1c 24             	mov    (%esp),%ebx
  8002bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c1:	89 ec                	mov    %ebp,%esp
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	83 ec 28             	sub    $0x28,%esp
  8002cb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002ce:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002de:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e1:	89 df                	mov    %ebx,%edi
  8002e3:	51                   	push   %ecx
  8002e4:	52                   	push   %edx
  8002e5:	53                   	push   %ebx
  8002e6:	54                   	push   %esp
  8002e7:	55                   	push   %ebp
  8002e8:	56                   	push   %esi
  8002e9:	57                   	push   %edi
  8002ea:	54                   	push   %esp
  8002eb:	5d                   	pop    %ebp
  8002ec:	8d 35 f4 02 80 00    	lea    0x8002f4,%esi
  8002f2:	0f 34                	sysenter 
  8002f4:	5f                   	pop    %edi
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	5c                   	pop    %esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5a                   	pop    %edx
  8002fa:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8002fb:	85 c0                	test   %eax,%eax
  8002fd:	7e 28                	jle    800327 <sys_env_set_pgfault_upcall+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800303:	c7 44 24 0c 0b 00 00 	movl   $0xb,0xc(%esp)
  80030a:	00 
  80030b:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  800312:	00 
  800313:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80031a:	00 
  80031b:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  800322:	e8 1d 0c 00 00       	call   800f44 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800327:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80032a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80032d:	89 ec                	mov    %ebp,%esp
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	83 ec 28             	sub    $0x28,%esp
  800337:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80033a:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80033d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800342:	b8 0a 00 00 00       	mov    $0xa,%eax
  800347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034a:	8b 55 08             	mov    0x8(%ebp),%edx
  80034d:	89 df                	mov    %ebx,%edi
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
  800369:	7e 28                	jle    800393 <sys_env_set_trapframe+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800376:	00 
  800377:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  80037e:	00 
  80037f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800386:	00 
  800387:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  80038e:	e8 b1 0b 00 00       	call   800f44 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800393:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800396:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800399:	89 ec                	mov    %ebp,%esp
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	83 ec 28             	sub    $0x28,%esp
  8003a3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8003a6:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8003b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b9:	89 df                	mov    %ebx,%edi
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
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	7e 28                	jle    8003ff <sys_env_set_status+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003db:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003e2:	00 
  8003e3:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  8003ea:	00 
  8003eb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8003f2:	00 
  8003f3:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  8003fa:	e8 45 0b 00 00       	call   800f44 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8003ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800402:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800405:	89 ec                	mov    %ebp,%esp
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	83 ec 28             	sub    $0x28,%esp
  80040f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800412:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800415:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041a:	b8 07 00 00 00       	mov    $0x7,%eax
  80041f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800422:	8b 55 08             	mov    0x8(%ebp),%edx
  800425:	89 df                	mov    %ebx,%edi
  800427:	51                   	push   %ecx
  800428:	52                   	push   %edx
  800429:	53                   	push   %ebx
  80042a:	54                   	push   %esp
  80042b:	55                   	push   %ebp
  80042c:	56                   	push   %esi
  80042d:	57                   	push   %edi
  80042e:	54                   	push   %esp
  80042f:	5d                   	pop    %ebp
  800430:	8d 35 38 04 80 00    	lea    0x800438,%esi
  800436:	0f 34                	sysenter 
  800438:	5f                   	pop    %edi
  800439:	5e                   	pop    %esi
  80043a:	5d                   	pop    %ebp
  80043b:	5c                   	pop    %esp
  80043c:	5b                   	pop    %ebx
  80043d:	5a                   	pop    %edx
  80043e:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80043f:	85 c0                	test   %eax,%eax
  800441:	7e 28                	jle    80046b <sys_page_unmap+0x62>
		panic("syscall %d returned %d (> 0)", num, ret);
  800443:	89 44 24 10          	mov    %eax,0x10(%esp)
  800447:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80044e:	00 
  80044f:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  800456:	00 
  800457:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80045e:	00 
  80045f:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  800466:	e8 d9 0a 00 00       	call   800f44 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80046b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80046e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800471:	89 ec                	mov    %ebp,%esp
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
  800478:	83 ec 28             	sub    $0x28,%esp
  80047b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80047e:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800481:	8b 7d 18             	mov    0x18(%ebp),%edi
  800484:	0b 7d 14             	or     0x14(%ebp),%edi
  800487:	b8 06 00 00 00       	mov    $0x6,%eax
  80048c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80048f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800492:	8b 55 08             	mov    0x8(%ebp),%edx
  800495:	51                   	push   %ecx
  800496:	52                   	push   %edx
  800497:	53                   	push   %ebx
  800498:	54                   	push   %esp
  800499:	55                   	push   %ebp
  80049a:	56                   	push   %esi
  80049b:	57                   	push   %edi
  80049c:	54                   	push   %esp
  80049d:	5d                   	pop    %ebp
  80049e:	8d 35 a6 04 80 00    	lea    0x8004a6,%esi
  8004a4:	0f 34                	sysenter 
  8004a6:	5f                   	pop    %edi
  8004a7:	5e                   	pop    %esi
  8004a8:	5d                   	pop    %ebp
  8004a9:	5c                   	pop    %esp
  8004aa:	5b                   	pop    %ebx
  8004ab:	5a                   	pop    %edx
  8004ac:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	7e 28                	jle    8004d9 <sys_page_map+0x64>
		panic("syscall %d returned %d (> 0)", num, ret);
  8004b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004b5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8004bc:	00 
  8004bd:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  8004c4:	00 
  8004c5:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8004cc:	00 
  8004cd:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  8004d4:	e8 6b 0a 00 00       	call   800f44 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, ((uint32_t) dstva)|perm, perm);
}
  8004d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8004dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004df:	89 ec                	mov    %ebp,%esp
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	83 ec 28             	sub    $0x28,%esp
  8004e9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004ec:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8004ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8004f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8004f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800502:	51                   	push   %ecx
  800503:	52                   	push   %edx
  800504:	53                   	push   %ebx
  800505:	54                   	push   %esp
  800506:	55                   	push   %ebp
  800507:	56                   	push   %esi
  800508:	57                   	push   %edi
  800509:	54                   	push   %esp
  80050a:	5d                   	pop    %ebp
  80050b:	8d 35 13 05 80 00    	lea    0x800513,%esi
  800511:	0f 34                	sysenter 
  800513:	5f                   	pop    %edi
  800514:	5e                   	pop    %esi
  800515:	5d                   	pop    %ebp
  800516:	5c                   	pop    %esp
  800517:	5b                   	pop    %ebx
  800518:	5a                   	pop    %edx
  800519:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  80051a:	85 c0                	test   %eax,%eax
  80051c:	7e 28                	jle    800546 <sys_page_alloc+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800522:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800529:	00 
  80052a:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  800531:	00 
  800532:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800539:	00 
  80053a:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  800541:	e8 fe 09 00 00       	call   800f44 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800546:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800549:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80054c:	89 ec                	mov    %ebp,%esp
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	89 1c 24             	mov    %ebx,(%esp)
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80055d:	ba 00 00 00 00       	mov    $0x0,%edx
  800562:	b8 0c 00 00 00       	mov    $0xc,%eax
  800567:	89 d1                	mov    %edx,%ecx
  800569:	89 d3                	mov    %edx,%ebx
  80056b:	89 d7                	mov    %edx,%edi
  80056d:	51                   	push   %ecx
  80056e:	52                   	push   %edx
  80056f:	53                   	push   %ebx
  800570:	54                   	push   %esp
  800571:	55                   	push   %ebp
  800572:	56                   	push   %esi
  800573:	57                   	push   %edi
  800574:	54                   	push   %esp
  800575:	5d                   	pop    %ebp
  800576:	8d 35 7e 05 80 00    	lea    0x80057e,%esi
  80057c:	0f 34                	sysenter 
  80057e:	5f                   	pop    %edi
  80057f:	5e                   	pop    %esi
  800580:	5d                   	pop    %ebp
  800581:	5c                   	pop    %esp
  800582:	5b                   	pop    %ebx
  800583:	5a                   	pop    %edx
  800584:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800585:	8b 1c 24             	mov    (%esp),%ebx
  800588:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80058c:	89 ec                	mov    %ebp,%esp
  80058e:	5d                   	pop    %ebp
  80058f:	c3                   	ret    

00800590 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	89 1c 24             	mov    %ebx,(%esp)
  800599:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80059d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8005a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ad:	89 df                	mov    %ebx,%edi
  8005af:	51                   	push   %ecx
  8005b0:	52                   	push   %edx
  8005b1:	53                   	push   %ebx
  8005b2:	54                   	push   %esp
  8005b3:	55                   	push   %ebp
  8005b4:	56                   	push   %esi
  8005b5:	57                   	push   %edi
  8005b6:	54                   	push   %esp
  8005b7:	5d                   	pop    %ebp
  8005b8:	8d 35 c0 05 80 00    	lea    0x8005c0,%esi
  8005be:	0f 34                	sysenter 
  8005c0:	5f                   	pop    %edi
  8005c1:	5e                   	pop    %esi
  8005c2:	5d                   	pop    %ebp
  8005c3:	5c                   	pop    %esp
  8005c4:	5b                   	pop    %ebx
  8005c5:	5a                   	pop    %edx
  8005c6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8005c7:	8b 1c 24             	mov    (%esp),%ebx
  8005ca:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005ce:	89 ec                	mov    %ebp,%esp
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	89 1c 24             	mov    %ebx,(%esp)
  8005db:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8005df:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8005e9:	89 d1                	mov    %edx,%ecx
  8005eb:	89 d3                	mov    %edx,%ebx
  8005ed:	89 d7                	mov    %edx,%edi
  8005ef:	51                   	push   %ecx
  8005f0:	52                   	push   %edx
  8005f1:	53                   	push   %ebx
  8005f2:	54                   	push   %esp
  8005f3:	55                   	push   %ebp
  8005f4:	56                   	push   %esi
  8005f5:	57                   	push   %edi
  8005f6:	54                   	push   %esp
  8005f7:	5d                   	pop    %ebp
  8005f8:	8d 35 00 06 80 00    	lea    0x800600,%esi
  8005fe:	0f 34                	sysenter 
  800600:	5f                   	pop    %edi
  800601:	5e                   	pop    %esi
  800602:	5d                   	pop    %ebp
  800603:	5c                   	pop    %esp
  800604:	5b                   	pop    %ebx
  800605:	5a                   	pop    %edx
  800606:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800607:	8b 1c 24             	mov    (%esp),%ebx
  80060a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80060e:	89 ec                	mov    %ebp,%esp
  800610:	5d                   	pop    %ebp
  800611:	c3                   	ret    

00800612 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800612:	55                   	push   %ebp
  800613:	89 e5                	mov    %esp,%ebp
  800615:	83 ec 28             	sub    $0x28,%esp
  800618:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80061b:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800623:	b8 03 00 00 00       	mov    $0x3,%eax
  800628:	8b 55 08             	mov    0x8(%ebp),%edx
  80062b:	89 cb                	mov    %ecx,%ebx
  80062d:	89 cf                	mov    %ecx,%edi
  80062f:	51                   	push   %ecx
  800630:	52                   	push   %edx
  800631:	53                   	push   %ebx
  800632:	54                   	push   %esp
  800633:	55                   	push   %ebp
  800634:	56                   	push   %esi
  800635:	57                   	push   %edi
  800636:	54                   	push   %esp
  800637:	5d                   	pop    %ebp
  800638:	8d 35 40 06 80 00    	lea    0x800640,%esi
  80063e:	0f 34                	sysenter 
  800640:	5f                   	pop    %edi
  800641:	5e                   	pop    %esi
  800642:	5d                   	pop    %ebp
  800643:	5c                   	pop    %esp
  800644:	5b                   	pop    %ebx
  800645:	5a                   	pop    %edx
  800646:	59                   	pop    %ecx
                   "d" (a1),
                   "c" (a2),
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");
	if(check && ret > 0)
  800647:	85 c0                	test   %eax,%eax
  800649:	7e 28                	jle    800673 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  80064b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80064f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800656:	00 
  800657:	c7 44 24 08 ea 20 80 	movl   $0x8020ea,0x8(%esp)
  80065e:	00 
  80065f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800666:	00 
  800667:	c7 04 24 07 21 80 00 	movl   $0x802107,(%esp)
  80066e:	e8 d1 08 00 00       	call   800f44 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800673:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800676:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800679:	89 ec                	mov    %ebp,%esp
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    
  80067d:	00 00                	add    %al,(%eax)
	...

00800680 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	8b 45 08             	mov    0x8(%ebp),%eax
  800686:	05 00 00 00 30       	add    $0x30000000,%eax
  80068b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80068e:	5d                   	pop    %ebp
  80068f:	c3                   	ret    

00800690 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	89 04 24             	mov    %eax,(%esp)
  80069c:	e8 df ff ff ff       	call   800680 <fd2num>
  8006a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8006a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	57                   	push   %edi
  8006af:	56                   	push   %esi
  8006b0:	53                   	push   %ebx
  8006b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8006b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8006b9:	a8 01                	test   $0x1,%al
  8006bb:	74 36                	je     8006f3 <fd_alloc+0x48>
  8006bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8006c2:	a8 01                	test   $0x1,%al
  8006c4:	74 2d                	je     8006f3 <fd_alloc+0x48>
  8006c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8006cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8006d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8006d5:	89 c3                	mov    %eax,%ebx
  8006d7:	89 c2                	mov    %eax,%edx
  8006d9:	c1 ea 16             	shr    $0x16,%edx
  8006dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8006df:	f6 c2 01             	test   $0x1,%dl
  8006e2:	74 14                	je     8006f8 <fd_alloc+0x4d>
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	c1 ea 0c             	shr    $0xc,%edx
  8006e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8006ec:	f6 c2 01             	test   $0x1,%dl
  8006ef:	75 10                	jne    800701 <fd_alloc+0x56>
  8006f1:	eb 05                	jmp    8006f8 <fd_alloc+0x4d>
  8006f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8006f8:	89 1f                	mov    %ebx,(%edi)
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8006ff:	eb 17                	jmp    800718 <fd_alloc+0x6d>
  800701:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800706:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80070b:	75 c8                	jne    8006d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80070d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800713:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800718:	5b                   	pop    %ebx
  800719:	5e                   	pop    %esi
  80071a:	5f                   	pop    %edi
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	83 f8 1f             	cmp    $0x1f,%eax
  800726:	77 36                	ja     80075e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800728:	05 00 00 0d 00       	add    $0xd0000,%eax
  80072d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800730:	89 c2                	mov    %eax,%edx
  800732:	c1 ea 16             	shr    $0x16,%edx
  800735:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80073c:	f6 c2 01             	test   $0x1,%dl
  80073f:	74 1d                	je     80075e <fd_lookup+0x41>
  800741:	89 c2                	mov    %eax,%edx
  800743:	c1 ea 0c             	shr    $0xc,%edx
  800746:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80074d:	f6 c2 01             	test   $0x1,%dl
  800750:	74 0c                	je     80075e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800752:	8b 55 0c             	mov    0xc(%ebp),%edx
  800755:	89 02                	mov    %eax,(%edx)
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80075c:	eb 05                	jmp    800763 <fd_lookup+0x46>
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80076b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80076e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800772:	8b 45 08             	mov    0x8(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 a0 ff ff ff       	call   80071d <fd_lookup>
  80077d:	85 c0                	test   %eax,%eax
  80077f:	78 0e                	js     80078f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800781:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
  800787:	89 50 04             	mov    %edx,0x4(%eax)
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	56                   	push   %esi
  800795:	53                   	push   %ebx
  800796:	83 ec 10             	sub    $0x10,%esp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
// File functions
// --------------------------------------------------------------

static struct Dev *devtab[] =
{
	&devfile,
  80079f:	b8 04 30 80 00       	mov    $0x803004,%eax
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8007a4:	ba 00 00 00 00       	mov    $0x0,%edx

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007a9:	be 94 21 80 00       	mov    $0x802194,%esi
		if (devtab[i]->dev_id == dev_id) {
  8007ae:	39 08                	cmp    %ecx,(%eax)
  8007b0:	75 10                	jne    8007c2 <dev_lookup+0x31>
  8007b2:	eb 04                	jmp    8007b8 <dev_lookup+0x27>
  8007b4:	39 08                	cmp    %ecx,(%eax)
  8007b6:	75 0a                	jne    8007c2 <dev_lookup+0x31>
			*dev = devtab[i];
  8007b8:	89 03                	mov    %eax,(%ebx)
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8007bf:	90                   	nop
  8007c0:	eb 31                	jmp    8007f3 <dev_lookup+0x62>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8007c8:	85 c0                	test   %eax,%eax
  8007ca:	75 e8                	jne    8007b4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8007d1:	8b 40 48             	mov    0x48(%eax),%eax
  8007d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dc:	c7 04 24 18 21 80 00 	movl   $0x802118,(%esp)
  8007e3:	e8 15 08 00 00       	call   800ffd <cprintf>
	*dev = 0;
  8007e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8007ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8007f3:	83 c4 10             	add    $0x10,%esp
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	83 ec 24             	sub    $0x24,%esp
  800801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	e8 07 ff ff ff       	call   80071d <fd_lookup>
  800816:	85 c0                	test   %eax,%eax
  800818:	78 53                	js     80086d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800824:	8b 00                	mov    (%eax),%eax
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	e8 63 ff ff ff       	call   800791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082e:	85 c0                	test   %eax,%eax
  800830:	78 3b                	js     80086d <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800832:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800837:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083a:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  80083e:	74 2d                	je     80086d <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800840:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800843:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80084a:	00 00 00 
	stat->st_isdir = 0;
  80084d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800854:	00 00 00 
	stat->st_dev = dev;
  800857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800860:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800864:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800867:	89 14 24             	mov    %edx,(%esp)
  80086a:	ff 50 14             	call   *0x14(%eax)
}
  80086d:	83 c4 24             	add    $0x24,%esp
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	83 ec 24             	sub    $0x24,%esp
  80087a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80087d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800880:	89 44 24 04          	mov    %eax,0x4(%esp)
  800884:	89 1c 24             	mov    %ebx,(%esp)
  800887:	e8 91 fe ff ff       	call   80071d <fd_lookup>
  80088c:	85 c0                	test   %eax,%eax
  80088e:	78 5f                	js     8008ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800893:	89 44 24 04          	mov    %eax,0x4(%esp)
  800897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089a:	8b 00                	mov    (%eax),%eax
  80089c:	89 04 24             	mov    %eax,(%esp)
  80089f:	e8 ed fe ff ff       	call   800791 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	78 47                	js     8008ef <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008ab:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8008af:	75 23                	jne    8008d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008b1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008b6:	8b 40 48             	mov    0x48(%eax),%eax
  8008b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c1:	c7 04 24 38 21 80 00 	movl   $0x802138,(%esp)
  8008c8:	e8 30 07 00 00       	call   800ffd <cprintf>
  8008cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008d2:	eb 1b                	jmp    8008ef <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8008d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d7:	8b 48 18             	mov    0x18(%eax),%ecx
  8008da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008df:	85 c9                	test   %ecx,%ecx
  8008e1:	74 0c                	je     8008ef <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	89 14 24             	mov    %edx,(%esp)
  8008ed:	ff d1                	call   *%ecx
}
  8008ef:	83 c4 24             	add    $0x24,%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	83 ec 24             	sub    $0x24,%esp
  8008fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800902:	89 44 24 04          	mov    %eax,0x4(%esp)
  800906:	89 1c 24             	mov    %ebx,(%esp)
  800909:	e8 0f fe ff ff       	call   80071d <fd_lookup>
  80090e:	85 c0                	test   %eax,%eax
  800910:	78 66                	js     800978 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800912:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800915:	89 44 24 04          	mov    %eax,0x4(%esp)
  800919:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091c:	8b 00                	mov    (%eax),%eax
  80091e:	89 04 24             	mov    %eax,(%esp)
  800921:	e8 6b fe ff ff       	call   800791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800926:	85 c0                	test   %eax,%eax
  800928:	78 4e                	js     800978 <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80092a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80092d:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800931:	75 23                	jne    800956 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800933:	a1 04 40 80 00       	mov    0x804004,%eax
  800938:	8b 40 48             	mov    0x48(%eax),%eax
  80093b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80093f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800943:	c7 04 24 59 21 80 00 	movl   $0x802159,(%esp)
  80094a:	e8 ae 06 00 00       	call   800ffd <cprintf>
  80094f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800954:	eb 22                	jmp    800978 <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800959:	8b 48 0c             	mov    0xc(%eax),%ecx
  80095c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800961:	85 c9                	test   %ecx,%ecx
  800963:	74 13                	je     800978 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800965:	8b 45 10             	mov    0x10(%ebp),%eax
  800968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	89 14 24             	mov    %edx,(%esp)
  800976:	ff d1                	call   *%ecx
}
  800978:	83 c4 24             	add    $0x24,%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	83 ec 24             	sub    $0x24,%esp
  800985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80098b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098f:	89 1c 24             	mov    %ebx,(%esp)
  800992:	e8 86 fd ff ff       	call   80071d <fd_lookup>
  800997:	85 c0                	test   %eax,%eax
  800999:	78 6b                	js     800a06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a5:	8b 00                	mov    (%eax),%eax
  8009a7:	89 04 24             	mov    %eax,(%esp)
  8009aa:	e8 e2 fd ff ff       	call   800791 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	78 53                	js     800a06 <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b6:	8b 42 08             	mov    0x8(%edx),%eax
  8009b9:	83 e0 03             	and    $0x3,%eax
  8009bc:	83 f8 01             	cmp    $0x1,%eax
  8009bf:	75 23                	jne    8009e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c6:	8b 40 48             	mov    0x48(%eax),%eax
  8009c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d1:	c7 04 24 76 21 80 00 	movl   $0x802176,(%esp)
  8009d8:	e8 20 06 00 00       	call   800ffd <cprintf>
  8009dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8009e2:	eb 22                	jmp    800a06 <read+0x88>
	}
	if (!dev->dev_read)
  8009e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e7:	8b 48 08             	mov    0x8(%eax),%ecx
  8009ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8009ef:	85 c9                	test   %ecx,%ecx
  8009f1:	74 13                	je     800a06 <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8009f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a01:	89 14 24             	mov    %edx,(%esp)
  800a04:	ff d1                	call   *%ecx
}
  800a06:	83 c4 24             	add    $0x24,%esp
  800a09:	5b                   	pop    %ebx
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	83 ec 1c             	sub    $0x1c,%esp
  800a15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a18:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	85 f6                	test   %esi,%esi
  800a2c:	74 29                	je     800a57 <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a2e:	89 f0                	mov    %esi,%eax
  800a30:	29 d0                	sub    %edx,%eax
  800a32:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a36:	03 55 0c             	add    0xc(%ebp),%edx
  800a39:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a3d:	89 3c 24             	mov    %edi,(%esp)
  800a40:	e8 39 ff ff ff       	call   80097e <read>
		if (m < 0)
  800a45:	85 c0                	test   %eax,%eax
  800a47:	78 0e                	js     800a57 <readn+0x4b>
			return m;
		if (m == 0)
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	74 08                	je     800a55 <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a4d:	01 c3                	add    %eax,%ebx
  800a4f:	89 da                	mov    %ebx,%edx
  800a51:	39 f3                	cmp    %esi,%ebx
  800a53:	72 d9                	jb     800a2e <readn+0x22>
  800a55:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a57:	83 c4 1c             	add    $0x1c,%esp
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	83 ec 20             	sub    $0x20,%esp
  800a67:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a6a:	89 34 24             	mov    %esi,(%esp)
  800a6d:	e8 0e fc ff ff       	call   800680 <fd2num>
  800a72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800a75:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a79:	89 04 24             	mov    %eax,(%esp)
  800a7c:	e8 9c fc ff ff       	call   80071d <fd_lookup>
  800a81:	89 c3                	mov    %eax,%ebx
  800a83:	85 c0                	test   %eax,%eax
  800a85:	78 05                	js     800a8c <fd_close+0x2d>
  800a87:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a8a:	74 0c                	je     800a98 <fd_close+0x39>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800a8c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800a90:	19 c0                	sbb    %eax,%eax
  800a92:	f7 d0                	not    %eax
  800a94:	21 c3                	and    %eax,%ebx
  800a96:	eb 3d                	jmp    800ad5 <fd_close+0x76>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9f:	8b 06                	mov    (%esi),%eax
  800aa1:	89 04 24             	mov    %eax,(%esp)
  800aa4:	e8 e8 fc ff ff       	call   800791 <dev_lookup>
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	85 c0                	test   %eax,%eax
  800aad:	78 16                	js     800ac5 <fd_close+0x66>
		if (dev->dev_close)
  800aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab2:	8b 40 10             	mov    0x10(%eax),%eax
  800ab5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aba:	85 c0                	test   %eax,%eax
  800abc:	74 07                	je     800ac5 <fd_close+0x66>
			r = (*dev->dev_close)(fd);
  800abe:	89 34 24             	mov    %esi,(%esp)
  800ac1:	ff d0                	call   *%eax
  800ac3:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ac5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ac9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad0:	e8 34 f9 ff ff       	call   800409 <sys_page_unmap>
	return r;
}
  800ad5:	89 d8                	mov    %ebx,%eax
  800ad7:	83 c4 20             	add    $0x20,%esp
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ae4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	89 04 24             	mov    %eax,(%esp)
  800af1:	e8 27 fc ff ff       	call   80071d <fd_lookup>
  800af6:	85 c0                	test   %eax,%eax
  800af8:	78 13                	js     800b0d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800afa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800b01:	00 
  800b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b05:	89 04 24             	mov    %eax,(%esp)
  800b08:	e8 52 ff ff ff       	call   800a5f <fd_close>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 18             	sub    $0x18,%esp
  800b15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800b1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b22:	00 
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	89 04 24             	mov    %eax,(%esp)
  800b29:	e8 79 03 00 00       	call   800ea7 <open>
  800b2e:	89 c3                	mov    %eax,%ebx
  800b30:	85 c0                	test   %eax,%eax
  800b32:	78 1b                	js     800b4f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3b:	89 1c 24             	mov    %ebx,(%esp)
  800b3e:	e8 b7 fc ff ff       	call   8007fa <fstat>
  800b43:	89 c6                	mov    %eax,%esi
	close(fd);
  800b45:	89 1c 24             	mov    %ebx,(%esp)
  800b48:	e8 91 ff ff ff       	call   800ade <close>
  800b4d:	89 f3                	mov    %esi,%ebx
	return r;
}
  800b4f:	89 d8                	mov    %ebx,%eax
  800b51:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b54:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b57:	89 ec                	mov    %ebp,%esp
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	53                   	push   %ebx
  800b5f:	83 ec 14             	sub    $0x14,%esp
  800b62:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800b67:	89 1c 24             	mov    %ebx,(%esp)
  800b6a:	e8 6f ff ff ff       	call   800ade <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b6f:	83 c3 01             	add    $0x1,%ebx
  800b72:	83 fb 20             	cmp    $0x20,%ebx
  800b75:	75 f0                	jne    800b67 <close_all+0xc>
		close(i);
}
  800b77:	83 c4 14             	add    $0x14,%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	83 ec 58             	sub    $0x58,%esp
  800b83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b96:	8b 45 08             	mov    0x8(%ebp),%eax
  800b99:	89 04 24             	mov    %eax,(%esp)
  800b9c:	e8 7c fb ff ff       	call   80071d <fd_lookup>
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	0f 88 e0 00 00 00    	js     800c8b <dup+0x10e>
		return r;
	close(newfdnum);
  800bab:	89 3c 24             	mov    %edi,(%esp)
  800bae:	e8 2b ff ff ff       	call   800ade <close>

	newfd = INDEX2FD(newfdnum);
  800bb3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800bb9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bbf:	89 04 24             	mov    %eax,(%esp)
  800bc2:	e8 c9 fa ff ff       	call   800690 <fd2data>
  800bc7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800bc9:	89 34 24             	mov    %esi,(%esp)
  800bcc:	e8 bf fa ff ff       	call   800690 <fd2data>
  800bd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800bd4:	89 da                	mov    %ebx,%edx
  800bd6:	89 d8                	mov    %ebx,%eax
  800bd8:	c1 e8 16             	shr    $0x16,%eax
  800bdb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800be2:	a8 01                	test   $0x1,%al
  800be4:	74 43                	je     800c29 <dup+0xac>
  800be6:	c1 ea 0c             	shr    $0xc,%edx
  800be9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800bf0:	a8 01                	test   $0x1,%al
  800bf2:	74 35                	je     800c29 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bf4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800bfb:	25 07 0e 00 00       	and    $0xe07,%eax
  800c00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c12:	00 
  800c13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c1e:	e8 52 f8 ff ff       	call   800475 <sys_page_map>
  800c23:	89 c3                	mov    %eax,%ebx
  800c25:	85 c0                	test   %eax,%eax
  800c27:	78 3f                	js     800c68 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2c:	89 c2                	mov    %eax,%edx
  800c2e:	c1 ea 0c             	shr    $0xc,%edx
  800c31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800c38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800c3e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c42:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c4d:	00 
  800c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c59:	e8 17 f8 ff ff       	call   800475 <sys_page_map>
  800c5e:	89 c3                	mov    %eax,%ebx
  800c60:	85 c0                	test   %eax,%eax
  800c62:	78 04                	js     800c68 <dup+0xeb>
  800c64:	89 fb                	mov    %edi,%ebx
  800c66:	eb 23                	jmp    800c8b <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c68:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c73:	e8 91 f7 ff ff       	call   800409 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c86:	e8 7e f7 ff ff       	call   800409 <sys_page_unmap>
	return r;
}
  800c8b:	89 d8                	mov    %ebx,%eax
  800c8d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c90:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c93:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c96:	89 ec                	mov    %ebp,%esp
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    
	...

00800c9c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 18             	sub    $0x18,%esp
  800ca2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ca5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800ca8:	89 c3                	mov    %eax,%ebx
  800caa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800cac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cb3:	75 11                	jne    800cc6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800cbc:	e8 5f 10 00 00       	call   801d20 <ipc_find_env>
  800cc1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cc6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ccd:	00 
  800cce:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800cd5:	00 
  800cd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cda:	a1 00 40 80 00       	mov    0x804000,%eax
  800cdf:	89 04 24             	mov    %eax,(%esp)
  800ce2:	e8 84 10 00 00       	call   801d6b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ce7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800cee:	00 
  800cef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cfa:	e8 ea 10 00 00       	call   801de9 <ipc_recv>
}
  800cff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d05:	89 ec                	mov    %ebp,%esp
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	8b 40 0c             	mov    0xc(%eax),%eax
  800d15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
  800d27:	b8 02 00 00 00       	mov    $0x2,%eax
  800d2c:	e8 6b ff ff ff       	call   800c9c <fsipc>
}
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	8b 40 0c             	mov    0xc(%eax),%eax
  800d3f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d44:	ba 00 00 00 00       	mov    $0x0,%edx
  800d49:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4e:	e8 49 ff ff ff       	call   800c9c <fsipc>
}
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    

00800d55 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 08 00 00 00       	mov    $0x8,%eax
  800d65:	e8 32 ff ff ff       	call   800c9c <fsipc>
}
  800d6a:	c9                   	leave  
  800d6b:	c3                   	ret    

00800d6c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 14             	sub    $0x14,%esp
  800d73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	8b 40 0c             	mov    0xc(%eax),%eax
  800d7c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d81:	ba 00 00 00 00       	mov    $0x0,%edx
  800d86:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8b:	e8 0c ff ff ff       	call   800c9c <fsipc>
  800d90:	85 c0                	test   %eax,%eax
  800d92:	78 2b                	js     800dbf <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d94:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800d9b:	00 
  800d9c:	89 1c 24             	mov    %ebx,(%esp)
  800d9f:	e8 86 0b 00 00       	call   80192a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800da4:	a1 80 50 80 00       	mov    0x805080,%eax
  800da9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800daf:	a1 84 50 80 00       	mov    0x805084,%eax
  800db4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800dbf:	83 c4 14             	add    $0x14,%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	83 ec 18             	sub    $0x18,%esp
  800dcb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800dd3:	76 05                	jbe    800dda <devfile_write+0x15>
  800dd5:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	// bytes than requested.
	// LAB 5: Your code here
        int r;
        if(n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
        fsipcbuf.write.req_fileid = fd->fd_file.id;
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	8b 52 0c             	mov    0xc(%edx),%edx
  800de0:	89 15 00 50 80 00    	mov    %edx,0x805000
        fsipcbuf.write.req_n = n;
  800de6:	a3 04 50 80 00       	mov    %eax,0x805004
        memmove(fsipcbuf.write.req_buf,buf,n);  
  800deb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800def:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df6:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800dfd:	e8 13 0d 00 00       	call   801b15 <memmove>
        r = fsipc(FSREQ_WRITE,NULL);
  800e02:	ba 00 00 00 00       	mov    $0x0,%edx
  800e07:	b8 04 00 00 00       	mov    $0x4,%eax
  800e0c:	e8 8b fe ff ff       	call   800c9c <fsipc>
        return r;
	//panic("devfile_write not implemented");
}
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	53                   	push   %ebx
  800e17:	83 ec 14             	sub    $0x14,%esp
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
        int r;
        fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e20:	a3 00 50 80 00       	mov    %eax,0x805000
        fsipcbuf.read.req_n = n;
  800e25:	8b 45 10             	mov    0x10(%ebp),%eax
  800e28:	a3 04 50 80 00       	mov    %eax,0x805004
        r = fsipc(FSREQ_READ,NULL);
  800e2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e32:	b8 03 00 00 00       	mov    $0x3,%eax
  800e37:	e8 60 fe ff ff       	call   800c9c <fsipc>
  800e3c:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	78 17                	js     800e59 <devfile_read+0x46>
           return r;
        memmove(buf,fsipcbuf.readRet.ret_buf,r);
  800e42:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e46:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800e4d:	00 
  800e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e51:	89 04 24             	mov    %eax,(%esp)
  800e54:	e8 bc 0c 00 00       	call   801b15 <memmove>
        return r;
	//panic("devfile_read not implemented");
}
  800e59:	89 d8                	mov    %ebx,%eax
  800e5b:	83 c4 14             	add    $0x14,%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	53                   	push   %ebx
  800e65:	83 ec 14             	sub    $0x14,%esp
  800e68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800e6b:	89 1c 24             	mov    %ebx,(%esp)
  800e6e:	e8 6d 0a 00 00       	call   8018e0 <strlen>
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800e7a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800e80:	7f 1f                	jg     800ea1 <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800e82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e86:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800e8d:	e8 98 0a 00 00       	call   80192a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800e92:	ba 00 00 00 00       	mov    $0x0,%edx
  800e97:	b8 07 00 00 00       	mov    $0x7,%eax
  800e9c:	e8 fb fd ff ff       	call   800c9c <fsipc>
}
  800ea1:	83 c4 14             	add    $0x14,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 28             	sub    $0x28,%esp
  800ead:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800eb0:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800eb3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
        struct Fd* fd;
        if(strlen(path) > MAXPATHLEN)
  800eb6:	89 34 24             	mov    %esi,(%esp)
  800eb9:	e8 22 0a 00 00       	call   8018e0 <strlen>
  800ebe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800ec3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ec8:	7f 6d                	jg     800f37 <open+0x90>
            return -E_BAD_PATH;
        int r;
        r = fd_alloc(&fd);
  800eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecd:	89 04 24             	mov    %eax,(%esp)
  800ed0:	e8 d6 f7 ff ff       	call   8006ab <fd_alloc>
  800ed5:	89 c3                	mov    %eax,%ebx
        if(r < 0)
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	78 5c                	js     800f37 <open+0x90>
           return r;
        fsipcbuf.open.req_omode = mode;
  800edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ede:	a3 00 54 80 00       	mov    %eax,0x805400
        memmove(fsipcbuf.open.req_path,path,strlen(path)+1);
  800ee3:	89 34 24             	mov    %esi,(%esp)
  800ee6:	e8 f5 09 00 00       	call   8018e0 <strlen>
  800eeb:	83 c0 01             	add    $0x1,%eax
  800eee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800efd:	e8 13 0c 00 00       	call   801b15 <memmove>
        r = fsipc(FSREQ_OPEN,(void*)fd);
  800f02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f05:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0a:	e8 8d fd ff ff       	call   800c9c <fsipc>
  800f0f:	89 c3                	mov    %eax,%ebx
        if(r < 0){
  800f11:	85 c0                	test   %eax,%eax
  800f13:	79 15                	jns    800f2a <open+0x83>
             fd_close(fd,0);
  800f15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f1c:	00 
  800f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f20:	89 04 24             	mov    %eax,(%esp)
  800f23:	e8 37 fb ff ff       	call   800a5f <fd_close>
             return r;
  800f28:	eb 0d                	jmp    800f37 <open+0x90>
        }
        return fd2num(fd);
  800f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2d:	89 04 24             	mov    %eax,(%esp)
  800f30:	e8 4b f7 ff ff       	call   800680 <fd2num>
  800f35:	89 c3                	mov    %eax,%ebx
	//panic("open not implemented");
}
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800f3c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800f3f:	89 ec                	mov    %ebp,%esp
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
	...

00800f44 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f4c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f4f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800f55:	e8 78 f6 ff ff       	call   8005d2 <sys_getenvid>
  800f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f70:	c7 04 24 9c 21 80 00 	movl   $0x80219c,(%esp)
  800f77:	e8 81 00 00 00       	call   800ffd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f80:	8b 45 10             	mov    0x10(%ebp),%eax
  800f83:	89 04 24             	mov    %eax,(%esp)
  800f86:	e8 11 00 00 00       	call   800f9c <vcprintf>
	cprintf("\n");
  800f8b:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
  800f92:	e8 66 00 00 00       	call   800ffd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f97:	cc                   	int3   
  800f98:	eb fd                	jmp    800f97 <_panic+0x53>
	...

00800f9c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800fa5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800fac:	00 00 00 
	b.cnt = 0;
  800faf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800fb6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd1:	c7 04 24 17 10 80 00 	movl   $0x801017,(%esp)
  800fd8:	e8 cf 01 00 00       	call   8011ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800fdd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800fed:	89 04 24             	mov    %eax,(%esp)
  800ff0:	e8 f7 f0 ff ff       	call   8000ec <sys_cputs>

	return b.cnt;
}
  800ff5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801003:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801006:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	e8 87 ff ff ff       	call   800f9c <vcprintf>
	va_end(ap);

	return cnt;
}
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	53                   	push   %ebx
  80101b:	83 ec 14             	sub    $0x14,%esp
  80101e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801021:	8b 03                	mov    (%ebx),%eax
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80102a:	83 c0 01             	add    $0x1,%eax
  80102d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80102f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801034:	75 19                	jne    80104f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801036:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80103d:	00 
  80103e:	8d 43 08             	lea    0x8(%ebx),%eax
  801041:	89 04 24             	mov    %eax,(%esp)
  801044:	e8 a3 f0 ff ff       	call   8000ec <sys_cputs>
		b->idx = 0;
  801049:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80104f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801053:	83 c4 14             	add    $0x14,%esp
  801056:	5b                   	pop    %ebx
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    
  801059:	00 00                	add    %al,(%eax)
  80105b:	00 00                	add    %al,(%eax)
  80105d:	00 00                	add    %al,(%eax)
	...

00801060 <printnum_v2>:
 */

static void 
printnum_v2(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	83 ec 4c             	sub    $0x4c,%esp
  801069:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80106c:	89 d6                	mov    %edx,%esi
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
  801071:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801074:	8b 55 0c             	mov    0xc(%ebp),%edx
  801077:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80107a:	8b 45 10             	mov    0x10(%ebp),%eax
  80107d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801080:	8b 7d 18             	mov    0x18(%ebp),%edi
    if (num >= base) {
  801083:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801086:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108b:	39 d1                	cmp    %edx,%ecx
  80108d:	72 07                	jb     801096 <printnum_v2+0x36>
  80108f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801092:	39 d0                	cmp    %edx,%eax
  801094:	77 5f                	ja     8010f5 <printnum_v2+0x95>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  801096:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80109a:	83 eb 01             	sub    $0x1,%ebx
  80109d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010a9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8010ad:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8010b0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8010b3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8010b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010c1:	00 
  8010c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010c5:	89 04 24             	mov    %eax,(%esp)
  8010c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010cf:	e8 8c 0d 00 00       	call   801e60 <__udivdi3>
  8010d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8010d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8010da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010e2:	89 04 24             	mov    %eax,(%esp)
  8010e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010e9:	89 f2                	mov    %esi,%edx
  8010eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ee:	e8 6d ff ff ff       	call   801060 <printnum_v2>
  8010f3:	eb 1e                	jmp    801113 <printnum_v2+0xb3>
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  8010f5:	83 ff 2d             	cmp    $0x2d,%edi
  8010f8:	74 19                	je     801113 <printnum_v2+0xb3>
		while (--width > 0)
  8010fa:	83 eb 01             	sub    $0x1,%ebx
  8010fd:	85 db                	test   %ebx,%ebx
  8010ff:	90                   	nop
  801100:	7e 11                	jle    801113 <printnum_v2+0xb3>
			putch(padc, putdat);
  801102:	89 74 24 04          	mov    %esi,0x4(%esp)
  801106:	89 3c 24             	mov    %edi,(%esp)
  801109:	ff 55 e4             	call   *-0x1c(%ebp)
    if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  80110c:	83 eb 01             	sub    $0x1,%ebx
  80110f:	85 db                	test   %ebx,%ebx
  801111:	7f ef                	jg     801102 <printnum_v2+0xa2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801113:	89 74 24 04          	mov    %esi,0x4(%esp)
  801117:	8b 74 24 04          	mov    0x4(%esp),%esi
  80111b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80111e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801122:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801129:	00 
  80112a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80112d:	89 14 24             	mov    %edx,(%esp)
  801130:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801133:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801137:	e8 54 0e 00 00       	call   801f90 <__umoddi3>
  80113c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801140:	0f be 80 bf 21 80 00 	movsbl 0x8021bf(%eax),%eax
  801147:	89 04 24             	mov    %eax,(%esp)
  80114a:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80114d:	83 c4 4c             	add    $0x4c,%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801158:	83 fa 01             	cmp    $0x1,%edx
  80115b:	7e 0e                	jle    80116b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80115d:	8b 10                	mov    (%eax),%edx
  80115f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801162:	89 08                	mov    %ecx,(%eax)
  801164:	8b 02                	mov    (%edx),%eax
  801166:	8b 52 04             	mov    0x4(%edx),%edx
  801169:	eb 22                	jmp    80118d <getuint+0x38>
	else if (lflag)
  80116b:	85 d2                	test   %edx,%edx
  80116d:	74 10                	je     80117f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80116f:	8b 10                	mov    (%eax),%edx
  801171:	8d 4a 04             	lea    0x4(%edx),%ecx
  801174:	89 08                	mov    %ecx,(%eax)
  801176:	8b 02                	mov    (%edx),%eax
  801178:	ba 00 00 00 00       	mov    $0x0,%edx
  80117d:	eb 0e                	jmp    80118d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80117f:	8b 10                	mov    (%eax),%edx
  801181:	8d 4a 04             	lea    0x4(%edx),%ecx
  801184:	89 08                	mov    %ecx,(%eax)
  801186:	8b 02                	mov    (%edx),%eax
  801188:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801195:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801199:	8b 10                	mov    (%eax),%edx
  80119b:	3b 50 04             	cmp    0x4(%eax),%edx
  80119e:	73 0a                	jae    8011aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8011a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a3:	88 0a                	mov    %cl,(%edx)
  8011a5:	83 c2 01             	add    $0x1,%edx
  8011a8:	89 10                	mov    %edx,(%eax)
}
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	57                   	push   %edi
  8011b0:	56                   	push   %esi
  8011b1:	53                   	push   %ebx
  8011b2:	83 ec 6c             	sub    $0x6c,%esp
  8011b5:	8b 7d 10             	mov    0x10(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8011b8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8011bf:	eb 1a                	jmp    8011db <vprintfmt+0x2f>
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	0f 84 66 06 00 00    	je     80182f <vprintfmt+0x683>
				return;
			putch(ch, putdat);
  8011c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011d0:	89 04 24             	mov    %eax,(%esp)
  8011d3:	ff 55 08             	call   *0x8(%ebp)
  8011d6:	eb 03                	jmp    8011db <vprintfmt+0x2f>
  8011d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag,signflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011db:	0f b6 07             	movzbl (%edi),%eax
  8011de:	83 c7 01             	add    $0x1,%edi
  8011e1:	83 f8 25             	cmp    $0x25,%eax
  8011e4:	75 db                	jne    8011c1 <vprintfmt+0x15>
  8011e6:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
  8011ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ef:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8011f6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8011fb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801202:	be 00 00 00 00       	mov    $0x0,%esi
  801207:	eb 06                	jmp    80120f <vprintfmt+0x63>
  801209:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80120d:	89 c7                	mov    %eax,%edi
		precision = -1;
		lflag = 0;
		altflag = 0;
                signflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80120f:	0f b6 17             	movzbl (%edi),%edx
  801212:	0f b6 c2             	movzbl %dl,%eax
  801215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801218:	8d 47 01             	lea    0x1(%edi),%eax
  80121b:	83 ea 23             	sub    $0x23,%edx
  80121e:	80 fa 55             	cmp    $0x55,%dl
  801221:	0f 87 60 05 00 00    	ja     801787 <vprintfmt+0x5db>
  801227:	0f b6 d2             	movzbl %dl,%edx
  80122a:	ff 24 95 a0 23 80 00 	jmp    *0x8023a0(,%edx,4)
  801231:	b9 01 00 00 00       	mov    $0x1,%ecx
  801236:	eb d5                	jmp    80120d <vprintfmt+0x61>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801238:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80123b:	83 eb 30             	sub    $0x30,%ebx
				ch = *fmt;
  80123e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801241:	8d 7a d0             	lea    -0x30(%edx),%edi
  801244:	83 ff 09             	cmp    $0x9,%edi
  801247:	76 08                	jbe    801251 <vprintfmt+0xa5>
  801249:	eb 40                	jmp    80128b <vprintfmt+0xdf>
  80124b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
                        signflag = 1;
                        goto reswitch;
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
			goto reswitch;
  80124f:	eb bc                	jmp    80120d <vprintfmt+0x61>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801251:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  801254:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
  801257:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
  80125b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80125e:	8d 7a d0             	lea    -0x30(%edx),%edi
  801261:	83 ff 09             	cmp    $0x9,%edi
  801264:	76 eb                	jbe    801251 <vprintfmt+0xa5>
  801266:	eb 23                	jmp    80128b <vprintfmt+0xdf>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801268:	8b 55 14             	mov    0x14(%ebp),%edx
  80126b:	8d 5a 04             	lea    0x4(%edx),%ebx
  80126e:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801271:	8b 1a                	mov    (%edx),%ebx
			goto process_precision;
  801273:	eb 16                	jmp    80128b <vprintfmt+0xdf>

		case '.':
			if (width < 0)
  801275:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801278:	c1 fa 1f             	sar    $0x1f,%edx
  80127b:	f7 d2                	not    %edx
  80127d:	21 55 d8             	and    %edx,-0x28(%ebp)
  801280:	eb 8b                	jmp    80120d <vprintfmt+0x61>
  801282:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801289:	eb 82                	jmp    80120d <vprintfmt+0x61>

		process_precision:
			if (width < 0)
  80128b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80128f:	0f 89 78 ff ff ff    	jns    80120d <vprintfmt+0x61>
  801295:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  801298:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  80129b:	e9 6d ff ff ff       	jmp    80120d <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012a0:	83 c6 01             	add    $0x1,%esi
			goto reswitch;
  8012a3:	e9 65 ff ff ff       	jmp    80120d <vprintfmt+0x61>
  8012a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ae:	8d 50 04             	lea    0x4(%eax),%edx
  8012b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8012b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012bb:	8b 00                	mov    (%eax),%eax
  8012bd:	89 04 24             	mov    %eax,(%esp)
  8012c0:	ff 55 08             	call   *0x8(%ebp)
  8012c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  8012c6:	e9 10 ff ff ff       	jmp    8011db <vprintfmt+0x2f>
  8012cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8012ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d1:	8d 50 04             	lea    0x4(%eax),%edx
  8012d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8012d7:	8b 00                	mov    (%eax),%eax
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	c1 fa 1f             	sar    $0x1f,%edx
  8012de:	31 d0                	xor    %edx,%eax
  8012e0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012e2:	83 f8 0f             	cmp    $0xf,%eax
  8012e5:	7f 0b                	jg     8012f2 <vprintfmt+0x146>
  8012e7:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8012ee:	85 d2                	test   %edx,%edx
  8012f0:	75 26                	jne    801318 <vprintfmt+0x16c>
				printfmt(putch, putdat, "error %d", err);
  8012f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f6:	c7 44 24 08 d0 21 80 	movl   $0x8021d0,0x8(%esp)
  8012fd:	00 
  8012fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801301:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801305:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801308:	89 1c 24             	mov    %ebx,(%esp)
  80130b:	e8 a7 05 00 00       	call   8018b7 <printfmt>
  801310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801313:	e9 c3 fe ff ff       	jmp    8011db <vprintfmt+0x2f>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801318:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80131c:	c7 44 24 08 d9 21 80 	movl   $0x8021d9,0x8(%esp)
  801323:	00 
  801324:	8b 45 0c             	mov    0xc(%ebp),%eax
  801327:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132b:	8b 55 08             	mov    0x8(%ebp),%edx
  80132e:	89 14 24             	mov    %edx,(%esp)
  801331:	e8 81 05 00 00       	call   8018b7 <printfmt>
  801336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801339:	e9 9d fe ff ff       	jmp    8011db <vprintfmt+0x2f>
  80133e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801341:	89 c7                	mov    %eax,%edi
  801343:	89 d9                	mov    %ebx,%ecx
  801345:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801348:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80134b:	8b 45 14             	mov    0x14(%ebp),%eax
  80134e:	8d 50 04             	lea    0x4(%eax),%edx
  801351:	89 55 14             	mov    %edx,0x14(%ebp)
  801354:	8b 30                	mov    (%eax),%esi
  801356:	85 f6                	test   %esi,%esi
  801358:	75 05                	jne    80135f <vprintfmt+0x1b3>
  80135a:	be dc 21 80 00       	mov    $0x8021dc,%esi
				p = "(null)";
			if (width > 0 && padc != '-')
  80135f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  801363:	7e 06                	jle    80136b <vprintfmt+0x1bf>
  801365:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  801369:	75 10                	jne    80137b <vprintfmt+0x1cf>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80136b:	0f be 06             	movsbl (%esi),%eax
  80136e:	85 c0                	test   %eax,%eax
  801370:	0f 85 a2 00 00 00    	jne    801418 <vprintfmt+0x26c>
  801376:	e9 92 00 00 00       	jmp    80140d <vprintfmt+0x261>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80137b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80137f:	89 34 24             	mov    %esi,(%esp)
  801382:	e8 74 05 00 00       	call   8018fb <strnlen>
  801387:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80138a:	29 c2                	sub    %eax,%edx
  80138c:	89 55 d8             	mov    %edx,-0x28(%ebp)
  80138f:	85 d2                	test   %edx,%edx
  801391:	7e d8                	jle    80136b <vprintfmt+0x1bf>
					putch(padc, putdat);
  801393:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  801397:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  80139a:	89 d3                	mov    %edx,%ebx
  80139c:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80139f:	89 7d bc             	mov    %edi,-0x44(%ebp)
  8013a2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013a5:	89 ce                	mov    %ecx,%esi
  8013a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ab:	89 34 24             	mov    %esi,(%esp)
  8013ae:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b1:	83 eb 01             	sub    $0x1,%ebx
  8013b4:	85 db                	test   %ebx,%ebx
  8013b6:	7f ef                	jg     8013a7 <vprintfmt+0x1fb>
  8013b8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8013bb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8013be:	8b 7d bc             	mov    -0x44(%ebp),%edi
  8013c1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8013c8:	eb a1                	jmp    80136b <vprintfmt+0x1bf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013ca:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8013ce:	74 1b                	je     8013eb <vprintfmt+0x23f>
  8013d0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8013d3:	83 fa 5e             	cmp    $0x5e,%edx
  8013d6:	76 13                	jbe    8013eb <vprintfmt+0x23f>
					putch('?', putdat);
  8013d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013df:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8013e6:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013e9:	eb 0d                	jmp    8013f8 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8013eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f2:	89 04 24             	mov    %eax,(%esp)
  8013f5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013f8:	83 ef 01             	sub    $0x1,%edi
  8013fb:	0f be 06             	movsbl (%esi),%eax
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 05                	je     801407 <vprintfmt+0x25b>
  801402:	83 c6 01             	add    $0x1,%esi
  801405:	eb 1a                	jmp    801421 <vprintfmt+0x275>
  801407:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80140a:	8b 7d cc             	mov    -0x34(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80140d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801411:	7f 1f                	jg     801432 <vprintfmt+0x286>
  801413:	e9 c0 fd ff ff       	jmp    8011d8 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801418:	83 c6 01             	add    $0x1,%esi
  80141b:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80141e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801421:	85 db                	test   %ebx,%ebx
  801423:	78 a5                	js     8013ca <vprintfmt+0x21e>
  801425:	83 eb 01             	sub    $0x1,%ebx
  801428:	79 a0                	jns    8013ca <vprintfmt+0x21e>
  80142a:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80142d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801430:	eb db                	jmp    80140d <vprintfmt+0x261>
  801432:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801435:	8b 75 0c             	mov    0xc(%ebp),%esi
  801438:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80143b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80143e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801442:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801449:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80144b:	83 eb 01             	sub    $0x1,%ebx
  80144e:	85 db                	test   %ebx,%ebx
  801450:	7f ec                	jg     80143e <vprintfmt+0x292>
  801452:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801455:	e9 81 fd ff ff       	jmp    8011db <vprintfmt+0x2f>
  80145a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80145d:	83 fe 01             	cmp    $0x1,%esi
  801460:	7e 10                	jle    801472 <vprintfmt+0x2c6>
		return va_arg(*ap, long long);
  801462:	8b 45 14             	mov    0x14(%ebp),%eax
  801465:	8d 50 08             	lea    0x8(%eax),%edx
  801468:	89 55 14             	mov    %edx,0x14(%ebp)
  80146b:	8b 18                	mov    (%eax),%ebx
  80146d:	8b 70 04             	mov    0x4(%eax),%esi
  801470:	eb 26                	jmp    801498 <vprintfmt+0x2ec>
	else if (lflag)
  801472:	85 f6                	test   %esi,%esi
  801474:	74 12                	je     801488 <vprintfmt+0x2dc>
		return va_arg(*ap, long);
  801476:	8b 45 14             	mov    0x14(%ebp),%eax
  801479:	8d 50 04             	lea    0x4(%eax),%edx
  80147c:	89 55 14             	mov    %edx,0x14(%ebp)
  80147f:	8b 18                	mov    (%eax),%ebx
  801481:	89 de                	mov    %ebx,%esi
  801483:	c1 fe 1f             	sar    $0x1f,%esi
  801486:	eb 10                	jmp    801498 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801488:	8b 45 14             	mov    0x14(%ebp),%eax
  80148b:	8d 50 04             	lea    0x4(%eax),%edx
  80148e:	89 55 14             	mov    %edx,0x14(%ebp)
  801491:	8b 18                	mov    (%eax),%ebx
  801493:	89 de                	mov    %ebx,%esi
  801495:	c1 fe 1f             	sar    $0x1f,%esi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
                        if(signflag == 1){
  801498:	83 f9 01             	cmp    $0x1,%ecx
  80149b:	75 1e                	jne    8014bb <vprintfmt+0x30f>
                               if((long long)num > 0){
  80149d:	85 f6                	test   %esi,%esi
  80149f:	78 1a                	js     8014bb <vprintfmt+0x30f>
  8014a1:	85 f6                	test   %esi,%esi
  8014a3:	7f 05                	jg     8014aa <vprintfmt+0x2fe>
  8014a5:	83 fb 00             	cmp    $0x0,%ebx
  8014a8:	76 11                	jbe    8014bb <vprintfmt+0x30f>
                                   putch('+',putdat);
  8014aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ad:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014b1:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
  8014b8:	ff 55 08             	call   *0x8(%ebp)
                               }
                        }
			if ((long long) num < 0) {
  8014bb:	85 f6                	test   %esi,%esi
  8014bd:	78 13                	js     8014d2 <vprintfmt+0x326>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014bf:	89 5d b0             	mov    %ebx,-0x50(%ebp)
  8014c2:	89 75 b4             	mov    %esi,-0x4c(%ebp)
  8014c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014cd:	e9 da 00 00 00       	jmp    8015ac <vprintfmt+0x400>
                               if((long long)num > 0){
                                   putch('+',putdat);
                               }
                        }
			if ((long long) num < 0) {
				putch('-', putdat);
  8014d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8014e0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8014e3:	89 da                	mov    %ebx,%edx
  8014e5:	89 f1                	mov    %esi,%ecx
  8014e7:	f7 da                	neg    %edx
  8014e9:	83 d1 00             	adc    $0x0,%ecx
  8014ec:	f7 d9                	neg    %ecx
  8014ee:	89 55 b0             	mov    %edx,-0x50(%ebp)
  8014f1:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  8014f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fc:	e9 ab 00 00 00       	jmp    8015ac <vprintfmt+0x400>
  801501:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801504:	89 f2                	mov    %esi,%edx
  801506:	8d 45 14             	lea    0x14(%ebp),%eax
  801509:	e8 47 fc ff ff       	call   801155 <getuint>
  80150e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801511:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801514:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801517:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80151c:	e9 8b 00 00 00       	jmp    8015ac <vprintfmt+0x400>
  801521:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  801524:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801527:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80152b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801532:	ff 55 08             	call   *0x8(%ebp)
			num = getuint(&ap,lflag);
  801535:	89 f2                	mov    %esi,%edx
  801537:	8d 45 14             	lea    0x14(%ebp),%eax
  80153a:	e8 16 fc ff ff       	call   801155 <getuint>
  80153f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  801542:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  801545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801548:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
			goto number;
  80154d:	eb 5d                	jmp    8015ac <vprintfmt+0x400>
  80154f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  801552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801555:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801559:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801560:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801563:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801567:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80156e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  801571:	8b 45 14             	mov    0x14(%ebp),%eax
  801574:	8d 50 04             	lea    0x4(%eax),%edx
  801577:	89 55 14             	mov    %edx,0x14(%ebp)
  80157a:	8b 10                	mov    (%eax),%edx
  80157c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801581:	89 55 b0             	mov    %edx,-0x50(%ebp)
  801584:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
  801587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80158a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80158f:	eb 1b                	jmp    8015ac <vprintfmt+0x400>
  801591:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801594:	89 f2                	mov    %esi,%edx
  801596:	8d 45 14             	lea    0x14(%ebp),%eax
  801599:	e8 b7 fb ff ff       	call   801155 <getuint>
  80159e:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8015a1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8015a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015a7:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015ac:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8015b0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015b3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8015b6:	83 7d b4 00          	cmpl   $0x0,-0x4c(%ebp)
  8015ba:	77 09                	ja     8015c5 <vprintfmt+0x419>
  8015bc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  8015bf:	0f 82 ac 00 00 00    	jb     801671 <vprintfmt+0x4c5>
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
  8015c5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8015c8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8015cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8015cf:	83 ea 01             	sub    $0x1,%edx
  8015d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015da:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015de:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015e2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8015e5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8015e8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8015eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015f6:	00 
  8015f7:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  8015fa:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  8015fd:	89 0c 24             	mov    %ecx,(%esp)
  801600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801604:	e8 57 08 00 00       	call   801e60 <__udivdi3>
  801609:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80160c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  80160f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801613:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801617:	89 04 24             	mov    %eax,(%esp)
  80161a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80161e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	e8 37 fa ff ff       	call   801060 <printnum_v2>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801629:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80162c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801630:	8b 74 24 04          	mov    0x4(%esp),%esi
  801634:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801637:	89 44 24 08          	mov    %eax,0x8(%esp)
  80163b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801642:	00 
  801643:	8b 55 b0             	mov    -0x50(%ebp),%edx
  801646:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
  801649:	89 14 24             	mov    %edx,(%esp)
  80164c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801650:	e8 3b 09 00 00       	call   801f90 <__umoddi3>
  801655:	89 74 24 04          	mov    %esi,0x4(%esp)
  801659:	0f be 80 bf 21 80 00 	movsbl 0x8021bf(%eax),%eax
  801660:	89 04 24             	mov    %eax,(%esp)
  801663:	ff 55 08             	call   *0x8(%ebp)
        if(padc == '-'){
  801666:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  80166a:	74 54                	je     8016c0 <vprintfmt+0x514>
  80166c:	e9 67 fb ff ff       	jmp    8011d8 <vprintfmt+0x2c>
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
  801671:	83 7d d0 2d          	cmpl   $0x2d,-0x30(%ebp)
  801675:	8d 76 00             	lea    0x0(%esi),%esi
  801678:	0f 84 2a 01 00 00    	je     8017a8 <vprintfmt+0x5fc>
		while (--width > 0)
  80167e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  801681:	83 ef 01             	sub    $0x1,%edi
  801684:	85 ff                	test   %edi,%edi
  801686:	0f 8e 5e 01 00 00    	jle    8017ea <vprintfmt+0x63e>
  80168c:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  80168f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
  801692:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801695:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801698:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80169b:	8b 75 0c             	mov    0xc(%ebp),%esi
			putch(padc, putdat);
  80169e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a2:	89 1c 24             	mov    %ebx,(%esp)
  8016a5:	ff 55 08             	call   *0x8(%ebp)
	if (num >= base) {
		printnum_v2(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
                if(padc != '-'){
		while (--width > 0)
  8016a8:	83 ef 01             	sub    $0x1,%edi
  8016ab:	85 ff                	test   %edi,%edi
  8016ad:	7f ef                	jg     80169e <vprintfmt+0x4f2>
  8016af:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8016b5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  8016b8:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  8016bb:	e9 2a 01 00 00       	jmp    8017ea <vprintfmt+0x63e>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8016c0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8016c3:	83 eb 01             	sub    $0x1,%ebx
  8016c6:	85 db                	test   %ebx,%ebx
  8016c8:	0f 8e 0a fb ff ff    	jle    8011d8 <vprintfmt+0x2c>
  8016ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016d1:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8016d4:	8b 7d 08             	mov    0x8(%ebp),%edi
			putch(' ', putdat);
  8016d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8016e2:	ff d7                	call   *%edi
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
        if(padc == '-'){
           while (--width > 0)
  8016e4:	83 eb 01             	sub    $0x1,%ebx
  8016e7:	85 db                	test   %ebx,%ebx
  8016e9:	7f ec                	jg     8016d7 <vprintfmt+0x52b>
  8016eb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8016ee:	e9 e8 fa ff ff       	jmp    8011db <vprintfmt+0x2f>
  8016f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
            char* n;
            if ((n = va_arg(ap, char *)) == NULL)
  8016f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f9:	8d 50 04             	lea    0x4(%eax),%edx
  8016fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ff:	8b 00                	mov    (%eax),%eax
  801701:	85 c0                	test   %eax,%eax
  801703:	75 2a                	jne    80172f <vprintfmt+0x583>
		  printfmt(putch,putdat,"%s",null_error);
  801705:	c7 44 24 0c f8 22 80 	movl   $0x8022f8,0xc(%esp)
  80170c:	00 
  80170d:	c7 44 24 08 d9 21 80 	movl   $0x8021d9,0x8(%esp)
  801714:	00 
  801715:	8b 55 0c             	mov    0xc(%ebp),%edx
  801718:	89 54 24 04          	mov    %edx,0x4(%esp)
  80171c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171f:	89 0c 24             	mov    %ecx,(%esp)
  801722:	e8 90 01 00 00       	call   8018b7 <printfmt>
  801727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80172a:	e9 ac fa ff ff       	jmp    8011db <vprintfmt+0x2f>
            else if((*(int*)putdat) > 127){
  80172f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801732:	8b 13                	mov    (%ebx),%edx
  801734:	83 fa 7f             	cmp    $0x7f,%edx
  801737:	7e 29                	jle    801762 <vprintfmt+0x5b6>
                  *n = *(int*)putdat;
  801739:	88 10                	mov    %dl,(%eax)
                  printfmt(putch,putdat,"%s",overflow_error);
  80173b:	c7 44 24 0c 30 23 80 	movl   $0x802330,0xc(%esp)
  801742:	00 
  801743:	c7 44 24 08 d9 21 80 	movl   $0x8021d9,0x8(%esp)
  80174a:	00 
  80174b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	e8 5d 01 00 00       	call   8018b7 <printfmt>
  80175a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80175d:	e9 79 fa ff ff       	jmp    8011db <vprintfmt+0x2f>
            }
            else
                  *n = *(int*)putdat;
  801762:	88 10                	mov    %dl,(%eax)
  801764:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801767:	e9 6f fa ff ff       	jmp    8011db <vprintfmt+0x2f>
  80176c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80176f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }
		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801775:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801779:	89 14 24             	mov    %edx,(%esp)
  80177c:	ff 55 08             	call   *0x8(%ebp)
  80177f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;
  801782:	e9 54 fa ff ff       	jmp    8011db <vprintfmt+0x2f>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801787:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80178a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80178e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801795:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801798:	8d 47 ff             	lea    -0x1(%edi),%eax
  80179b:	80 38 25             	cmpb   $0x25,(%eax)
  80179e:	0f 84 37 fa ff ff    	je     8011db <vprintfmt+0x2f>
  8017a4:	89 c7                	mov    %eax,%edi
  8017a6:	eb f0                	jmp    801798 <vprintfmt+0x5ec>
			putch(padc, putdat);
                }
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017af:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017b3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8017b6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017c1:	00 
  8017c2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8017c5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  8017c8:	89 04 24             	mov    %eax,(%esp)
  8017cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017cf:	e8 bc 07 00 00       	call   801f90 <__umoddi3>
  8017d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017d8:	0f be 80 bf 21 80 00 	movsbl 0x8021bf(%eax),%eax
  8017df:	89 04 24             	mov    %eax,(%esp)
  8017e2:	ff 55 08             	call   *0x8(%ebp)
  8017e5:	e9 d6 fe ff ff       	jmp    8016c0 <vprintfmt+0x514>
  8017ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017f1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017f5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801803:	00 
  801804:	8b 45 b0             	mov    -0x50(%ebp),%eax
  801807:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  80180a:	89 04 24             	mov    %eax,(%esp)
  80180d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801811:	e8 7a 07 00 00       	call   801f90 <__umoddi3>
  801816:	89 74 24 04          	mov    %esi,0x4(%esp)
  80181a:	0f be 80 bf 21 80 00 	movsbl 0x8021bf(%eax),%eax
  801821:	89 04 24             	mov    %eax,(%esp)
  801824:	ff 55 08             	call   *0x8(%ebp)
  801827:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80182a:	e9 ac f9 ff ff       	jmp    8011db <vprintfmt+0x2f>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80182f:	83 c4 6c             	add    $0x6c,%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5f                   	pop    %edi
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	83 ec 28             	sub    $0x28,%esp
  80183d:	8b 45 08             	mov    0x8(%ebp),%eax
  801840:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801843:	85 c0                	test   %eax,%eax
  801845:	74 04                	je     80184b <vsnprintf+0x14>
  801847:	85 d2                	test   %edx,%edx
  801849:	7f 07                	jg     801852 <vsnprintf+0x1b>
  80184b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801850:	eb 3b                	jmp    80188d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801852:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801855:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801859:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80185c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801863:	8b 45 14             	mov    0x14(%ebp),%eax
  801866:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186a:	8b 45 10             	mov    0x10(%ebp),%eax
  80186d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801871:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801874:	89 44 24 04          	mov    %eax,0x4(%esp)
  801878:	c7 04 24 8f 11 80 00 	movl   $0x80118f,(%esp)
  80187f:	e8 28 f9 ff ff       	call   8011ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801884:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801887:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80188a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801895:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801898:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80189c:	8b 45 10             	mov    0x10(%ebp),%eax
  80189f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	89 04 24             	mov    %eax,(%esp)
  8018b0:	e8 82 ff ff ff       	call   801837 <vsnprintf>
	va_end(ap);

	return rc;
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8018bd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8018c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	89 04 24             	mov    %eax,(%esp)
  8018d8:	e8 cf f8 ff ff       	call   8011ac <vprintfmt>
	va_end(ap);
}
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    
	...

008018e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8018e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8018ee:	74 09                	je     8018f9 <strlen+0x19>
		n++;
  8018f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8018f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8018f7:	75 f7                	jne    8018f0 <strlen+0x10>
		n++;
	return n;
}
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801905:	85 c9                	test   %ecx,%ecx
  801907:	74 19                	je     801922 <strnlen+0x27>
  801909:	80 3b 00             	cmpb   $0x0,(%ebx)
  80190c:	74 14                	je     801922 <strnlen+0x27>
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801913:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801916:	39 c8                	cmp    %ecx,%eax
  801918:	74 0d                	je     801927 <strnlen+0x2c>
  80191a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80191e:	75 f3                	jne    801913 <strnlen+0x18>
  801920:	eb 05                	jmp    801927 <strnlen+0x2c>
  801922:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801927:	5b                   	pop    %ebx
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	53                   	push   %ebx
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801934:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801939:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80193d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801940:	83 c2 01             	add    $0x1,%edx
  801943:	84 c9                	test   %cl,%cl
  801945:	75 f2                	jne    801939 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801947:	5b                   	pop    %ebx
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801954:	89 1c 24             	mov    %ebx,(%esp)
  801957:	e8 84 ff ff ff       	call   8018e0 <strlen>
	strcpy(dst + len, src);
  80195c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801963:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801966:	89 04 24             	mov    %eax,(%esp)
  801969:	e8 bc ff ff ff       	call   80192a <strcpy>
	return dst;
}
  80196e:	89 d8                	mov    %ebx,%eax
  801970:	83 c4 08             	add    $0x8,%esp
  801973:	5b                   	pop    %ebx
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    

00801976 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	56                   	push   %esi
  80197a:	53                   	push   %ebx
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801981:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801984:	85 f6                	test   %esi,%esi
  801986:	74 18                	je     8019a0 <strncpy+0x2a>
  801988:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80198d:	0f b6 1a             	movzbl (%edx),%ebx
  801990:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801993:	80 3a 01             	cmpb   $0x1,(%edx)
  801996:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801999:	83 c1 01             	add    $0x1,%ecx
  80199c:	39 ce                	cmp    %ecx,%esi
  80199e:	77 ed                	ja     80198d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8019b2:	89 f0                	mov    %esi,%eax
  8019b4:	85 c9                	test   %ecx,%ecx
  8019b6:	74 27                	je     8019df <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8019b8:	83 e9 01             	sub    $0x1,%ecx
  8019bb:	74 1d                	je     8019da <strlcpy+0x36>
  8019bd:	0f b6 1a             	movzbl (%edx),%ebx
  8019c0:	84 db                	test   %bl,%bl
  8019c2:	74 16                	je     8019da <strlcpy+0x36>
			*dst++ = *src++;
  8019c4:	88 18                	mov    %bl,(%eax)
  8019c6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8019c9:	83 e9 01             	sub    $0x1,%ecx
  8019cc:	74 0e                	je     8019dc <strlcpy+0x38>
			*dst++ = *src++;
  8019ce:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8019d1:	0f b6 1a             	movzbl (%edx),%ebx
  8019d4:	84 db                	test   %bl,%bl
  8019d6:	75 ec                	jne    8019c4 <strlcpy+0x20>
  8019d8:	eb 02                	jmp    8019dc <strlcpy+0x38>
  8019da:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8019dc:	c6 00 00             	movb   $0x0,(%eax)
  8019df:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8019ee:	0f b6 01             	movzbl (%ecx),%eax
  8019f1:	84 c0                	test   %al,%al
  8019f3:	74 15                	je     801a0a <strcmp+0x25>
  8019f5:	3a 02                	cmp    (%edx),%al
  8019f7:	75 11                	jne    801a0a <strcmp+0x25>
		p++, q++;
  8019f9:	83 c1 01             	add    $0x1,%ecx
  8019fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8019ff:	0f b6 01             	movzbl (%ecx),%eax
  801a02:	84 c0                	test   %al,%al
  801a04:	74 04                	je     801a0a <strcmp+0x25>
  801a06:	3a 02                	cmp    (%edx),%al
  801a08:	74 ef                	je     8019f9 <strcmp+0x14>
  801a0a:	0f b6 c0             	movzbl %al,%eax
  801a0d:	0f b6 12             	movzbl (%edx),%edx
  801a10:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    

00801a14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	53                   	push   %ebx
  801a18:	8b 55 08             	mov    0x8(%ebp),%edx
  801a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a1e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801a21:	85 c0                	test   %eax,%eax
  801a23:	74 23                	je     801a48 <strncmp+0x34>
  801a25:	0f b6 1a             	movzbl (%edx),%ebx
  801a28:	84 db                	test   %bl,%bl
  801a2a:	74 25                	je     801a51 <strncmp+0x3d>
  801a2c:	3a 19                	cmp    (%ecx),%bl
  801a2e:	75 21                	jne    801a51 <strncmp+0x3d>
  801a30:	83 e8 01             	sub    $0x1,%eax
  801a33:	74 13                	je     801a48 <strncmp+0x34>
		n--, p++, q++;
  801a35:	83 c2 01             	add    $0x1,%edx
  801a38:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801a3b:	0f b6 1a             	movzbl (%edx),%ebx
  801a3e:	84 db                	test   %bl,%bl
  801a40:	74 0f                	je     801a51 <strncmp+0x3d>
  801a42:	3a 19                	cmp    (%ecx),%bl
  801a44:	74 ea                	je     801a30 <strncmp+0x1c>
  801a46:	eb 09                	jmp    801a51 <strncmp+0x3d>
  801a48:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801a4d:	5b                   	pop    %ebx
  801a4e:	5d                   	pop    %ebp
  801a4f:	90                   	nop
  801a50:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a51:	0f b6 02             	movzbl (%edx),%eax
  801a54:	0f b6 11             	movzbl (%ecx),%edx
  801a57:	29 d0                	sub    %edx,%eax
  801a59:	eb f2                	jmp    801a4d <strncmp+0x39>

00801a5b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801a65:	0f b6 10             	movzbl (%eax),%edx
  801a68:	84 d2                	test   %dl,%dl
  801a6a:	74 18                	je     801a84 <strchr+0x29>
		if (*s == c)
  801a6c:	38 ca                	cmp    %cl,%dl
  801a6e:	75 0a                	jne    801a7a <strchr+0x1f>
  801a70:	eb 17                	jmp    801a89 <strchr+0x2e>
  801a72:	38 ca                	cmp    %cl,%dl
  801a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a78:	74 0f                	je     801a89 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801a7a:	83 c0 01             	add    $0x1,%eax
  801a7d:	0f b6 10             	movzbl (%eax),%edx
  801a80:	84 d2                	test   %dl,%dl
  801a82:	75 ee                	jne    801a72 <strchr+0x17>
  801a84:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801a95:	0f b6 10             	movzbl (%eax),%edx
  801a98:	84 d2                	test   %dl,%dl
  801a9a:	74 18                	je     801ab4 <strfind+0x29>
		if (*s == c)
  801a9c:	38 ca                	cmp    %cl,%dl
  801a9e:	75 0a                	jne    801aaa <strfind+0x1f>
  801aa0:	eb 12                	jmp    801ab4 <strfind+0x29>
  801aa2:	38 ca                	cmp    %cl,%dl
  801aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801aa8:	74 0a                	je     801ab4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801aaa:	83 c0 01             	add    $0x1,%eax
  801aad:	0f b6 10             	movzbl (%eax),%edx
  801ab0:	84 d2                	test   %dl,%dl
  801ab2:	75 ee                	jne    801aa2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	89 1c 24             	mov    %ebx,(%esp)
  801abf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ad0:	85 c9                	test   %ecx,%ecx
  801ad2:	74 30                	je     801b04 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ad4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ada:	75 25                	jne    801b01 <memset+0x4b>
  801adc:	f6 c1 03             	test   $0x3,%cl
  801adf:	75 20                	jne    801b01 <memset+0x4b>
		c &= 0xFF;
  801ae1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ae4:	89 d3                	mov    %edx,%ebx
  801ae6:	c1 e3 08             	shl    $0x8,%ebx
  801ae9:	89 d6                	mov    %edx,%esi
  801aeb:	c1 e6 18             	shl    $0x18,%esi
  801aee:	89 d0                	mov    %edx,%eax
  801af0:	c1 e0 10             	shl    $0x10,%eax
  801af3:	09 f0                	or     %esi,%eax
  801af5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801af7:	09 d8                	or     %ebx,%eax
  801af9:	c1 e9 02             	shr    $0x2,%ecx
  801afc:	fc                   	cld    
  801afd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801aff:	eb 03                	jmp    801b04 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b01:	fc                   	cld    
  801b02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b04:	89 f8                	mov    %edi,%eax
  801b06:	8b 1c 24             	mov    (%esp),%ebx
  801b09:	8b 74 24 04          	mov    0x4(%esp),%esi
  801b0d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b11:	89 ec                	mov    %ebp,%esp
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 08             	sub    $0x8,%esp
  801b1b:	89 34 24             	mov    %esi,(%esp)
  801b1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
  801b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801b28:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801b2b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801b2d:	39 c6                	cmp    %eax,%esi
  801b2f:	73 35                	jae    801b66 <memmove+0x51>
  801b31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b34:	39 d0                	cmp    %edx,%eax
  801b36:	73 2e                	jae    801b66 <memmove+0x51>
		s += n;
		d += n;
  801b38:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b3a:	f6 c2 03             	test   $0x3,%dl
  801b3d:	75 1b                	jne    801b5a <memmove+0x45>
  801b3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b45:	75 13                	jne    801b5a <memmove+0x45>
  801b47:	f6 c1 03             	test   $0x3,%cl
  801b4a:	75 0e                	jne    801b5a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801b4c:	83 ef 04             	sub    $0x4,%edi
  801b4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801b52:	c1 e9 02             	shr    $0x2,%ecx
  801b55:	fd                   	std    
  801b56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b58:	eb 09                	jmp    801b63 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801b5a:	83 ef 01             	sub    $0x1,%edi
  801b5d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801b60:	fd                   	std    
  801b61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801b63:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b64:	eb 20                	jmp    801b86 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801b6c:	75 15                	jne    801b83 <memmove+0x6e>
  801b6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b74:	75 0d                	jne    801b83 <memmove+0x6e>
  801b76:	f6 c1 03             	test   $0x3,%cl
  801b79:	75 08                	jne    801b83 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801b7b:	c1 e9 02             	shr    $0x2,%ecx
  801b7e:	fc                   	cld    
  801b7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b81:	eb 03                	jmp    801b86 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801b83:	fc                   	cld    
  801b84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801b86:	8b 34 24             	mov    (%esp),%esi
  801b89:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b8d:	89 ec                	mov    %ebp,%esp
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801b97:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba8:	89 04 24             	mov    %eax,(%esp)
  801bab:	e8 65 ff ff ff       	call   801b15 <memmove>
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801bc1:	85 c9                	test   %ecx,%ecx
  801bc3:	74 36                	je     801bfb <memcmp+0x49>
		if (*s1 != *s2)
  801bc5:	0f b6 06             	movzbl (%esi),%eax
  801bc8:	0f b6 1f             	movzbl (%edi),%ebx
  801bcb:	38 d8                	cmp    %bl,%al
  801bcd:	74 20                	je     801bef <memcmp+0x3d>
  801bcf:	eb 14                	jmp    801be5 <memcmp+0x33>
  801bd1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801bd6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801bdb:	83 c2 01             	add    $0x1,%edx
  801bde:	83 e9 01             	sub    $0x1,%ecx
  801be1:	38 d8                	cmp    %bl,%al
  801be3:	74 12                	je     801bf7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801be5:	0f b6 c0             	movzbl %al,%eax
  801be8:	0f b6 db             	movzbl %bl,%ebx
  801beb:	29 d8                	sub    %ebx,%eax
  801bed:	eb 11                	jmp    801c00 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801bef:	83 e9 01             	sub    $0x1,%ecx
  801bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf7:	85 c9                	test   %ecx,%ecx
  801bf9:	75 d6                	jne    801bd1 <memcmp+0x1f>
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c0b:	89 c2                	mov    %eax,%edx
  801c0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801c10:	39 d0                	cmp    %edx,%eax
  801c12:	73 15                	jae    801c29 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801c18:	38 08                	cmp    %cl,(%eax)
  801c1a:	75 06                	jne    801c22 <memfind+0x1d>
  801c1c:	eb 0b                	jmp    801c29 <memfind+0x24>
  801c1e:	38 08                	cmp    %cl,(%eax)
  801c20:	74 07                	je     801c29 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c22:	83 c0 01             	add    $0x1,%eax
  801c25:	39 c2                	cmp    %eax,%edx
  801c27:	77 f5                	ja     801c1e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	57                   	push   %edi
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	83 ec 04             	sub    $0x4,%esp
  801c34:	8b 55 08             	mov    0x8(%ebp),%edx
  801c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c3a:	0f b6 02             	movzbl (%edx),%eax
  801c3d:	3c 20                	cmp    $0x20,%al
  801c3f:	74 04                	je     801c45 <strtol+0x1a>
  801c41:	3c 09                	cmp    $0x9,%al
  801c43:	75 0e                	jne    801c53 <strtol+0x28>
		s++;
  801c45:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c48:	0f b6 02             	movzbl (%edx),%eax
  801c4b:	3c 20                	cmp    $0x20,%al
  801c4d:	74 f6                	je     801c45 <strtol+0x1a>
  801c4f:	3c 09                	cmp    $0x9,%al
  801c51:	74 f2                	je     801c45 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c53:	3c 2b                	cmp    $0x2b,%al
  801c55:	75 0c                	jne    801c63 <strtol+0x38>
		s++;
  801c57:	83 c2 01             	add    $0x1,%edx
  801c5a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801c61:	eb 15                	jmp    801c78 <strtol+0x4d>
	else if (*s == '-')
  801c63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801c6a:	3c 2d                	cmp    $0x2d,%al
  801c6c:	75 0a                	jne    801c78 <strtol+0x4d>
		s++, neg = 1;
  801c6e:	83 c2 01             	add    $0x1,%edx
  801c71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c78:	85 db                	test   %ebx,%ebx
  801c7a:	0f 94 c0             	sete   %al
  801c7d:	74 05                	je     801c84 <strtol+0x59>
  801c7f:	83 fb 10             	cmp    $0x10,%ebx
  801c82:	75 18                	jne    801c9c <strtol+0x71>
  801c84:	80 3a 30             	cmpb   $0x30,(%edx)
  801c87:	75 13                	jne    801c9c <strtol+0x71>
  801c89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801c8d:	8d 76 00             	lea    0x0(%esi),%esi
  801c90:	75 0a                	jne    801c9c <strtol+0x71>
		s += 2, base = 16;
  801c92:	83 c2 02             	add    $0x2,%edx
  801c95:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c9a:	eb 15                	jmp    801cb1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801c9c:	84 c0                	test   %al,%al
  801c9e:	66 90                	xchg   %ax,%ax
  801ca0:	74 0f                	je     801cb1 <strtol+0x86>
  801ca2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801ca7:	80 3a 30             	cmpb   $0x30,(%edx)
  801caa:	75 05                	jne    801cb1 <strtol+0x86>
		s++, base = 8;
  801cac:	83 c2 01             	add    $0x1,%edx
  801caf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cb8:	0f b6 0a             	movzbl (%edx),%ecx
  801cbb:	89 cf                	mov    %ecx,%edi
  801cbd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801cc0:	80 fb 09             	cmp    $0x9,%bl
  801cc3:	77 08                	ja     801ccd <strtol+0xa2>
			dig = *s - '0';
  801cc5:	0f be c9             	movsbl %cl,%ecx
  801cc8:	83 e9 30             	sub    $0x30,%ecx
  801ccb:	eb 1e                	jmp    801ceb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801ccd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801cd0:	80 fb 19             	cmp    $0x19,%bl
  801cd3:	77 08                	ja     801cdd <strtol+0xb2>
			dig = *s - 'a' + 10;
  801cd5:	0f be c9             	movsbl %cl,%ecx
  801cd8:	83 e9 57             	sub    $0x57,%ecx
  801cdb:	eb 0e                	jmp    801ceb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801cdd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801ce0:	80 fb 19             	cmp    $0x19,%bl
  801ce3:	77 15                	ja     801cfa <strtol+0xcf>
			dig = *s - 'A' + 10;
  801ce5:	0f be c9             	movsbl %cl,%ecx
  801ce8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801ceb:	39 f1                	cmp    %esi,%ecx
  801ced:	7d 0b                	jge    801cfa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801cef:	83 c2 01             	add    $0x1,%edx
  801cf2:	0f af c6             	imul   %esi,%eax
  801cf5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801cf8:	eb be                	jmp    801cb8 <strtol+0x8d>
  801cfa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801cfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d00:	74 05                	je     801d07 <strtol+0xdc>
		*endptr = (char *) s;
  801d02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d05:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801d07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801d0b:	74 04                	je     801d11 <strtol+0xe6>
  801d0d:	89 c8                	mov    %ecx,%eax
  801d0f:	f7 d8                	neg    %eax
}
  801d11:	83 c4 04             	add    $0x4,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5f                   	pop    %edi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    
  801d19:	00 00                	add    %al,(%eax)
  801d1b:	00 00                	add    %al,(%eax)
  801d1d:	00 00                	add    %al,(%eax)
	...

00801d20 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d26:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801d2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d31:	39 ca                	cmp    %ecx,%edx
  801d33:	75 04                	jne    801d39 <ipc_find_env+0x19>
  801d35:	b0 00                	mov    $0x0,%al
  801d37:	eb 12                	jmp    801d4b <ipc_find_env+0x2b>
  801d39:	89 c2                	mov    %eax,%edx
  801d3b:	c1 e2 07             	shl    $0x7,%edx
  801d3e:	8d 94 82 50 00 c0 ee 	lea    -0x113fffb0(%edx,%eax,4),%edx
  801d45:	8b 12                	mov    (%edx),%edx
  801d47:	39 ca                	cmp    %ecx,%edx
  801d49:	75 10                	jne    801d5b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d4b:	89 c2                	mov    %eax,%edx
  801d4d:	c1 e2 07             	shl    $0x7,%edx
  801d50:	8d 84 82 48 00 c0 ee 	lea    -0x113fffb8(%edx,%eax,4),%eax
  801d57:	8b 00                	mov    (%eax),%eax
  801d59:	eb 0e                	jmp    801d69 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d5b:	83 c0 01             	add    $0x1,%eax
  801d5e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d63:	75 d4                	jne    801d39 <ipc_find_env+0x19>
  801d65:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	57                   	push   %edi
  801d6f:	56                   	push   %esi
  801d70:	53                   	push   %ebx
  801d71:	83 ec 1c             	sub    $0x1c,%esp
  801d74:	8b 75 08             	mov    0x8(%ebp),%esi
  801d77:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        while(1){
           if(pg)
  801d7d:	85 db                	test   %ebx,%ebx
  801d7f:	74 19                	je     801d9a <ipc_send+0x2f>
              ret = sys_ipc_try_send(to_env,val,pg,perm);
  801d81:	8b 45 14             	mov    0x14(%ebp),%eax
  801d84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d8c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d90:	89 34 24             	mov    %esi,(%esp)
  801d93:	e8 ec e4 ff ff       	call   800284 <sys_ipc_try_send>
  801d98:	eb 1b                	jmp    801db5 <ipc_send+0x4a>
           else
              ret = sys_ipc_try_send(to_env,val,(void*)UTOP,perm);
  801d9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801da1:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801da8:	ee 
  801da9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dad:	89 34 24             	mov    %esi,(%esp)
  801db0:	e8 cf e4 ff ff       	call   800284 <sys_ipc_try_send>
           if(ret == 0)
  801db5:	85 c0                	test   %eax,%eax
  801db7:	74 28                	je     801de1 <ipc_send+0x76>
              return;
           if(ret != -E_IPC_NOT_RECV)
  801db9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dbc:	74 1c                	je     801dda <ipc_send+0x6f>
              panic("ipc send error");
  801dbe:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  801dc5:	00 
  801dc6:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  801dcd:	00 
  801dce:	c7 04 24 4f 25 80 00 	movl   $0x80254f,(%esp)
  801dd5:	e8 6a f1 ff ff       	call   800f44 <_panic>
           sys_yield();
  801dda:	e8 71 e7 ff ff       	call   800550 <sys_yield>
        }
  801ddf:	eb 9c                	jmp    801d7d <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801de1:	83 c4 1c             	add    $0x1c,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    

00801de9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	83 ec 10             	sub    $0x10,%esp
  801df1:	8b 75 08             	mov    0x8(%ebp),%esi
  801df4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        int ret;
        if(!pg)
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	75 0e                	jne    801e0c <ipc_recv+0x23>
           ret = sys_ipc_recv((void*)UTOP);
  801dfe:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e05:	e8 0f e4 ff ff       	call   800219 <sys_ipc_recv>
  801e0a:	eb 08                	jmp    801e14 <ipc_recv+0x2b>
        else
           ret = sys_ipc_recv(pg);
  801e0c:	89 04 24             	mov    %eax,(%esp)
  801e0f:	e8 05 e4 ff ff       	call   800219 <sys_ipc_recv>
        if(ret == 0){
  801e14:	85 c0                	test   %eax,%eax
  801e16:	75 26                	jne    801e3e <ipc_recv+0x55>
           if(from_env_store)
  801e18:	85 f6                	test   %esi,%esi
  801e1a:	74 0a                	je     801e26 <ipc_recv+0x3d>
              *from_env_store = thisenv->env_ipc_from;
  801e1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e21:	8b 40 78             	mov    0x78(%eax),%eax
  801e24:	89 06                	mov    %eax,(%esi)
           if(perm_store)
  801e26:	85 db                	test   %ebx,%ebx
  801e28:	74 0a                	je     801e34 <ipc_recv+0x4b>
              *perm_store = thisenv->env_ipc_perm;
  801e2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e32:	89 03                	mov    %eax,(%ebx)
           return thisenv->env_ipc_value;
  801e34:	a1 04 40 80 00       	mov    0x804004,%eax
  801e39:	8b 40 74             	mov    0x74(%eax),%eax
  801e3c:	eb 14                	jmp    801e52 <ipc_recv+0x69>
        }
        else{
           if(from_env_store)
  801e3e:	85 f6                	test   %esi,%esi
  801e40:	74 06                	je     801e48 <ipc_recv+0x5f>
              *from_env_store = 0;
  801e42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
           if(perm_store)
  801e48:	85 db                	test   %ebx,%ebx
  801e4a:	74 06                	je     801e52 <ipc_recv+0x69>
              *perm_store = 0;
  801e4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
           return ret;
        }
	//panic("ipc_recv not implemented");
	return 0;
}
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    
  801e59:	00 00                	add    %al,(%eax)
  801e5b:	00 00                	add    %al,(%eax)
  801e5d:	00 00                	add    %al,(%eax)
	...

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	57                   	push   %edi
  801e64:	56                   	push   %esi
  801e65:	83 ec 10             	sub    $0x10,%esp
  801e68:	8b 45 14             	mov    0x14(%ebp),%eax
  801e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  801e6e:	8b 75 10             	mov    0x10(%ebp),%esi
  801e71:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e74:	85 c0                	test   %eax,%eax
  801e76:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801e79:	75 35                	jne    801eb0 <__udivdi3+0x50>
  801e7b:	39 fe                	cmp    %edi,%esi
  801e7d:	77 61                	ja     801ee0 <__udivdi3+0x80>
  801e7f:	85 f6                	test   %esi,%esi
  801e81:	75 0b                	jne    801e8e <__udivdi3+0x2e>
  801e83:	b8 01 00 00 00       	mov    $0x1,%eax
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	f7 f6                	div    %esi
  801e8c:	89 c6                	mov    %eax,%esi
  801e8e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801e91:	31 d2                	xor    %edx,%edx
  801e93:	89 f8                	mov    %edi,%eax
  801e95:	f7 f6                	div    %esi
  801e97:	89 c7                	mov    %eax,%edi
  801e99:	89 c8                	mov    %ecx,%eax
  801e9b:	f7 f6                	div    %esi
  801e9d:	89 c1                	mov    %eax,%ecx
  801e9f:	89 fa                	mov    %edi,%edx
  801ea1:	89 c8                	mov    %ecx,%eax
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	5e                   	pop    %esi
  801ea7:	5f                   	pop    %edi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    
  801eaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801eb0:	39 f8                	cmp    %edi,%eax
  801eb2:	77 1c                	ja     801ed0 <__udivdi3+0x70>
  801eb4:	0f bd d0             	bsr    %eax,%edx
  801eb7:	83 f2 1f             	xor    $0x1f,%edx
  801eba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801ebd:	75 39                	jne    801ef8 <__udivdi3+0x98>
  801ebf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ec2:	0f 86 a0 00 00 00    	jbe    801f68 <__udivdi3+0x108>
  801ec8:	39 f8                	cmp    %edi,%eax
  801eca:	0f 82 98 00 00 00    	jb     801f68 <__udivdi3+0x108>
  801ed0:	31 ff                	xor    %edi,%edi
  801ed2:	31 c9                	xor    %ecx,%ecx
  801ed4:	89 c8                	mov    %ecx,%eax
  801ed6:	89 fa                	mov    %edi,%edx
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    
  801edf:	90                   	nop
  801ee0:	89 d1                	mov    %edx,%ecx
  801ee2:	89 fa                	mov    %edi,%edx
  801ee4:	89 c8                	mov    %ecx,%eax
  801ee6:	31 ff                	xor    %edi,%edi
  801ee8:	f7 f6                	div    %esi
  801eea:	89 c1                	mov    %eax,%ecx
  801eec:	89 fa                	mov    %edi,%edx
  801eee:	89 c8                	mov    %ecx,%eax
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	5e                   	pop    %esi
  801ef4:	5f                   	pop    %edi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    
  801ef7:	90                   	nop
  801ef8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801efc:	89 f2                	mov    %esi,%edx
  801efe:	d3 e0                	shl    %cl,%eax
  801f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f03:	b8 20 00 00 00       	mov    $0x20,%eax
  801f08:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801f0b:	89 c1                	mov    %eax,%ecx
  801f0d:	d3 ea                	shr    %cl,%edx
  801f0f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f13:	0b 55 ec             	or     -0x14(%ebp),%edx
  801f16:	d3 e6                	shl    %cl,%esi
  801f18:	89 c1                	mov    %eax,%ecx
  801f1a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801f1d:	89 fe                	mov    %edi,%esi
  801f1f:	d3 ee                	shr    %cl,%esi
  801f21:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f25:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f2b:	d3 e7                	shl    %cl,%edi
  801f2d:	89 c1                	mov    %eax,%ecx
  801f2f:	d3 ea                	shr    %cl,%edx
  801f31:	09 d7                	or     %edx,%edi
  801f33:	89 f2                	mov    %esi,%edx
  801f35:	89 f8                	mov    %edi,%eax
  801f37:	f7 75 ec             	divl   -0x14(%ebp)
  801f3a:	89 d6                	mov    %edx,%esi
  801f3c:	89 c7                	mov    %eax,%edi
  801f3e:	f7 65 e8             	mull   -0x18(%ebp)
  801f41:	39 d6                	cmp    %edx,%esi
  801f43:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801f46:	72 30                	jb     801f78 <__udivdi3+0x118>
  801f48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f4b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801f4f:	d3 e2                	shl    %cl,%edx
  801f51:	39 c2                	cmp    %eax,%edx
  801f53:	73 05                	jae    801f5a <__udivdi3+0xfa>
  801f55:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801f58:	74 1e                	je     801f78 <__udivdi3+0x118>
  801f5a:	89 f9                	mov    %edi,%ecx
  801f5c:	31 ff                	xor    %edi,%edi
  801f5e:	e9 71 ff ff ff       	jmp    801ed4 <__udivdi3+0x74>
  801f63:	90                   	nop
  801f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f68:	31 ff                	xor    %edi,%edi
  801f6a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801f6f:	e9 60 ff ff ff       	jmp    801ed4 <__udivdi3+0x74>
  801f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f78:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801f7b:	31 ff                	xor    %edi,%edi
  801f7d:	89 c8                	mov    %ecx,%eax
  801f7f:	89 fa                	mov    %edi,%edx
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
	...

00801f90 <__umoddi3>:
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	57                   	push   %edi
  801f94:	56                   	push   %esi
  801f95:	83 ec 20             	sub    $0x20,%esp
  801f98:	8b 55 14             	mov    0x14(%ebp),%edx
  801f9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f9e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801fa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa4:	85 d2                	test   %edx,%edx
  801fa6:	89 c8                	mov    %ecx,%eax
  801fa8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fab:	75 13                	jne    801fc0 <__umoddi3+0x30>
  801fad:	39 f7                	cmp    %esi,%edi
  801faf:	76 3f                	jbe    801ff0 <__umoddi3+0x60>
  801fb1:	89 f2                	mov    %esi,%edx
  801fb3:	f7 f7                	div    %edi
  801fb5:	89 d0                	mov    %edx,%eax
  801fb7:	31 d2                	xor    %edx,%edx
  801fb9:	83 c4 20             	add    $0x20,%esp
  801fbc:	5e                   	pop    %esi
  801fbd:	5f                   	pop    %edi
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    
  801fc0:	39 f2                	cmp    %esi,%edx
  801fc2:	77 4c                	ja     802010 <__umoddi3+0x80>
  801fc4:	0f bd ca             	bsr    %edx,%ecx
  801fc7:	83 f1 1f             	xor    $0x1f,%ecx
  801fca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801fcd:	75 51                	jne    802020 <__umoddi3+0x90>
  801fcf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801fd2:	0f 87 e0 00 00 00    	ja     8020b8 <__umoddi3+0x128>
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	29 f8                	sub    %edi,%eax
  801fdd:	19 d6                	sbb    %edx,%esi
  801fdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe5:	89 f2                	mov    %esi,%edx
  801fe7:	83 c4 20             	add    $0x20,%esp
  801fea:	5e                   	pop    %esi
  801feb:	5f                   	pop    %edi
  801fec:	5d                   	pop    %ebp
  801fed:	c3                   	ret    
  801fee:	66 90                	xchg   %ax,%ax
  801ff0:	85 ff                	test   %edi,%edi
  801ff2:	75 0b                	jne    801fff <__umoddi3+0x6f>
  801ff4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff9:	31 d2                	xor    %edx,%edx
  801ffb:	f7 f7                	div    %edi
  801ffd:	89 c7                	mov    %eax,%edi
  801fff:	89 f0                	mov    %esi,%eax
  802001:	31 d2                	xor    %edx,%edx
  802003:	f7 f7                	div    %edi
  802005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802008:	f7 f7                	div    %edi
  80200a:	eb a9                	jmp    801fb5 <__umoddi3+0x25>
  80200c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 c8                	mov    %ecx,%eax
  802012:	89 f2                	mov    %esi,%edx
  802014:	83 c4 20             	add    $0x20,%esp
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    
  80201b:	90                   	nop
  80201c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802020:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802024:	d3 e2                	shl    %cl,%edx
  802026:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802029:	ba 20 00 00 00       	mov    $0x20,%edx
  80202e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802031:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802034:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802038:	89 fa                	mov    %edi,%edx
  80203a:	d3 ea                	shr    %cl,%edx
  80203c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802040:	0b 55 f4             	or     -0xc(%ebp),%edx
  802043:	d3 e7                	shl    %cl,%edi
  802045:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802049:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80204c:	89 f2                	mov    %esi,%edx
  80204e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802051:	89 c7                	mov    %eax,%edi
  802053:	d3 ea                	shr    %cl,%edx
  802055:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802059:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80205c:	89 c2                	mov    %eax,%edx
  80205e:	d3 e6                	shl    %cl,%esi
  802060:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802064:	d3 ea                	shr    %cl,%edx
  802066:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80206a:	09 d6                	or     %edx,%esi
  80206c:	89 f0                	mov    %esi,%eax
  80206e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802071:	d3 e7                	shl    %cl,%edi
  802073:	89 f2                	mov    %esi,%edx
  802075:	f7 75 f4             	divl   -0xc(%ebp)
  802078:	89 d6                	mov    %edx,%esi
  80207a:	f7 65 e8             	mull   -0x18(%ebp)
  80207d:	39 d6                	cmp    %edx,%esi
  80207f:	72 2b                	jb     8020ac <__umoddi3+0x11c>
  802081:	39 c7                	cmp    %eax,%edi
  802083:	72 23                	jb     8020a8 <__umoddi3+0x118>
  802085:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802089:	29 c7                	sub    %eax,%edi
  80208b:	19 d6                	sbb    %edx,%esi
  80208d:	89 f0                	mov    %esi,%eax
  80208f:	89 f2                	mov    %esi,%edx
  802091:	d3 ef                	shr    %cl,%edi
  802093:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802097:	d3 e0                	shl    %cl,%eax
  802099:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80209d:	09 f8                	or     %edi,%eax
  80209f:	d3 ea                	shr    %cl,%edx
  8020a1:	83 c4 20             	add    $0x20,%esp
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	39 d6                	cmp    %edx,%esi
  8020aa:	75 d9                	jne    802085 <__umoddi3+0xf5>
  8020ac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8020af:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8020b2:	eb d1                	jmp    802085 <__umoddi3+0xf5>
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	0f 82 18 ff ff ff    	jb     801fd8 <__umoddi3+0x48>
  8020c0:	e9 1d ff ff ff       	jmp    801fe2 <__umoddi3+0x52>
